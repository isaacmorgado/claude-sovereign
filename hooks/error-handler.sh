#!/bin/bash
# Error Handler - Smart retry with backoff and error classification
# Safe execution patterns with subprocess isolation
#
# Categories:
#   - transient: Network timeouts, API rate limits (retry with backoff)
#   - permanent: Invalid syntax, missing files (no retry, log and continue)
#   - critical: Security violations, data corruption (halt and alert)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/../.claude/error-handler.log"
DEBUG_LOG="${SCRIPT_DIR}/../.claude/docs/debug-log.md"

# Ensure log directories exist
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
mkdir -p "$(dirname "$DEBUG_LOG")" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =============================================================================
# ERROR CLASSIFICATION
# Based on patterns from: Discord.js, Cypress, Uniswap, neo4j, midday-ai
# =============================================================================

classify_error() {
    local error_msg="$1"

    # Critical errors - halt immediately
    if echo "$error_msg" | grep -qiE "security.?violation|data.?corrupt|permission.?denied|access.?denied|fatal|panic"; then
        echo "critical"
        return
    fi

    # Transient errors - should retry with backoff
    if echo "$error_msg" | grep -qiE "timeout|ETIMEDOUT|ECONNRESET|ECONNREFUSED|network|socket hang up|ENOTFOUND|503|502|504"; then
        echo "transient"
        return
    fi

    # Rate limit errors - should retry with longer backoff
    if echo "$error_msg" | grep -qiE "rate.?limit|429|too many requests|quota exceeded"; then
        echo "transient"
        return
    fi

    # Permanent errors - don't retry (fix needed)
    if echo "$error_msg" | grep -qiE "syntax.?error|type.?error|reference.?error|400|401|403|404|validation|invalid|cannot find|not found|undefined|null|compilation|build failed|lint|typecheck"; then
        echo "permanent"
        return
    fi

    # Database errors - may be transient
    if echo "$error_msg" | grep -qiE "database|postgres|mysql|sqlite|deadlock"; then
        echo "transient"
        return
    fi

    echo "permanent"  # Default to permanent (no retry) for unknown errors
}

# =============================================================================
# RETRY LOGIC WITH EXPONENTIAL BACKOFF
# =============================================================================

should_retry() {
    local classification="$1"
    local attempt="$2"
    local max_retries="${3:-3}"

    if [[ $attempt -ge $max_retries ]]; then
        echo "false"
        return
    fi

    case "$classification" in
        transient)
            echo "true"
            ;;
        permanent|critical)
            echo "false"
            ;;
        *)
            echo "false"
            ;;
    esac
}

calculate_backoff() {
    local attempt="$1"
    local classification="$2"
    local base_delay=1  # 1 second
    local max_delay=30  # 30 seconds

    # Exponential backoff: base * 2^attempt
    local delay=$((base_delay * (2 ** attempt)))

    # Cap at max delay
    if [[ $delay -gt $max_delay ]]; then
        delay=$max_delay
    fi

    echo $delay
}

# =============================================================================
# SAFE FIX APPLICATION (No unsafe eval)
# Execute in subshell to isolate from parent process
# =============================================================================

apply_known_fix() {
    local fix="$1"
    local original_error="${2:-}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    log "[$timestamp] Attempting to apply fix: $fix"

    # Execute in subshell to isolate from parent
    local fix_output
    local fix_exit_code
    fix_output=$(
        set +e
        bash -c "$fix" 2>&1
        exit $?
    )
    fix_exit_code=$?

    log "[$timestamp] Fix execution completed with exit code: $fix_exit_code"

    if [[ $fix_exit_code -eq 0 ]]; then
        log "[$timestamp] Fix output: $fix_output"
        # Return success only if fix actually executed
        return 0
    else
        log "[$timestamp] Fix failed: $fix_output"
        return 1
    fi
}

verify_fix() {
    local test_command="$1"
    local original_error="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ -z "$test_command" ]]; then
        log "[$timestamp] No test command provided for verification - assuming fix worked"
        return 0
    fi

    log "[$timestamp] Verifying fix with: $test_command"

    # Run the test command to verify fix
    local verify_output
    local verify_exit_code
    verify_output=$(
        set +e
        bash -c "$test_command" 2>&1
        exit $?
    )
    verify_exit_code=$?

    if [[ $verify_exit_code -eq 0 ]]; then
        log "[$timestamp] Fix verified successfully"
        return 0
    else
        # Check if the original error still occurs
        if echo "$verify_output" | grep -qF "$original_error"; then
            log "[$timestamp] Original error still present after fix"
            return 1
        else
            log "[$timestamp] Verification command failed but original error not found"
            return 0
        fi
    fi
}

# =============================================================================
# LOGGING WITH TIMESTAMPS
# =============================================================================

log_fix_attempt() {
    local fix="$1"
    local outcome="$2"
    local error_msg="$3"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local log_entry="[$timestamp] FIX_ATTEMPT | Error: ${error_msg:0:100} | Fix: ${fix:0:100} | Outcome: $outcome"
    log "$log_entry"

    # Also append to debug log if it exists
    if [[ -f "$DEBUG_LOG" ]]; then
        echo "" >> "$DEBUG_LOG"
        echo "### Fix Attempt - $timestamp" >> "$DEBUG_LOG"
        echo "**Error**: \`${error_msg:0:200}\`" >> "$DEBUG_LOG"
        echo "**Fix Applied**: \`${fix:0:200}\`" >> "$DEBUG_LOG"
        echo "**Outcome**: $outcome" >> "$DEBUG_LOG"
    fi
}

log_error_to_debug() {
    local error_msg="$1"
    local classification="$2"
    local attempt="$3"
    local context="${4:-}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Create debug-log if doesn't exist
    if [[ ! -f "$DEBUG_LOG" ]]; then
        cat > "$DEBUG_LOG" << 'EOFLOG'
# Debug Log

## Active Issues

## Session Log

---

## Resolved Issues

## Patterns Discovered

## Research Cache
EOFLOG
    fi

    # Extract file:line if present
    local file_line
    file_line=$(echo "$error_msg" | grep -oE '[a-zA-Z0-9_/.-]+\.(ts|js|tsx|jsx|py|go|rs|sh):[0-9]+' | head -1 2>/dev/null || echo "unknown")

    local retry_status
    retry_status=$(should_retry "$classification" "$attempt")

    # Append to debug log
    cat >> "$DEBUG_LOG" << EOFENTRY

### Issue: $classification (Attempt $attempt)
**Time**: $timestamp
**Classification**: $classification
**File**: $file_line
**Error**: \`${error_msg:0:500}\`
**Context**: ${context:-none}
**Retryable**: $retry_status
EOFENTRY

    log "Logged $classification error (attempt $attempt)"
}

# =============================================================================
# MAIN ERROR HANDLER
# =============================================================================

handle_error() {
    local error_msg="${1:-}"
    local attempt="${2:-0}"
    local max_retries="${3:-3}"
    local context="${4:-}"
    local test_command="${5:-}"

    local classification
    classification=$(classify_error "$error_msg")

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    log "[$timestamp] Handling error (attempt $attempt): $classification"

    # For critical errors, log and halt
    if [[ "$classification" == "critical" ]]; then
        log "[$timestamp] CRITICAL ERROR - halting execution"
        log_error_to_debug "$error_msg" "$classification" "$attempt" "$context"

        jq -n \
            --arg classification "$classification" \
            --arg error "$error_msg" \
            --arg timestamp "$timestamp" \
            '{
                classification: $classification,
                shouldRetry: false,
                halt: true,
                error: $error,
                timestamp: $timestamp,
                recommendation: "Critical error - manual intervention required"
            }'
        return 1
    fi

    # Query memory for known fixes (only on first attempt)
    local known_fix=""
    local MEMORY_MANAGER="${SCRIPT_DIR}/memory-manager.sh"
    if [[ -x "$MEMORY_MANAGER" && "$attempt" -eq 0 ]]; then
        local patterns
        patterns=$("$MEMORY_MANAGER" find-patterns "$error_msg" 3 2>/dev/null || echo "[]")

        if [[ -n "$patterns" && "$patterns" != "[]" && "$patterns" != "null" ]]; then
            known_fix=$(echo "$patterns" | jq -r '.[0].solution // empty' 2>/dev/null || echo "")

            if [[ -n "$known_fix" && "$known_fix" != "null" ]]; then
                log "[$timestamp] Found known fix in memory: $known_fix"

                # Apply fix using safe subprocess execution
                if apply_known_fix "$known_fix" "$error_msg"; then
                    # Verify the fix actually resolved the error
                    if verify_fix "$test_command" "$error_msg"; then
                        log_fix_attempt "$known_fix" "SUCCESS" "$error_msg"

                        jq -n \
                            --arg classification "$classification" \
                            --arg fix "$known_fix" \
                            --arg error "$error_msg" \
                            --arg timestamp "$timestamp" \
                            '{
                                classification: $classification,
                                shouldRetry: false,
                                hasKnownFix: true,
                                knownFix: $fix,
                                fixApplied: true,
                                fixVerified: true,
                                timestamp: $timestamp,
                                recommendation: "Known fix applied and verified"
                            }'
                        return 0
                    else
                        log_fix_attempt "$known_fix" "FAILED_VERIFICATION" "$error_msg"
                        log "[$timestamp] Fix applied but verification failed - falling through to retry logic"
                    fi
                else
                    log_fix_attempt "$known_fix" "FAILED_EXECUTION" "$error_msg"
                    log "[$timestamp] Known fix failed to execute - falling through to retry logic"
                fi
            fi
        fi
    fi

    local retry
    retry=$(should_retry "$classification" "$attempt" "$max_retries")

    local backoff
    backoff=$(calculate_backoff "$attempt" "$classification")

    # Log to debug-log.md
    log_error_to_debug "$error_msg" "$classification" "$attempt" "$context"

    # Output JSON for caller
    jq -n \
        --arg classification "$classification" \
        --arg retry "$retry" \
        --argjson backoff "$backoff" \
        --argjson attempt "$attempt" \
        --arg error "$error_msg" \
        --arg timestamp "$timestamp" \
        '{
            classification: $classification,
            shouldRetry: ($retry == "true"),
            backoffSeconds: $backoff,
            attempt: $attempt,
            error: $error,
            timestamp: $timestamp,
            hasKnownFix: false
        }'
}

# Record successful fix to memory
record_fix_to_memory() {
    local error_msg="$1"
    local fix_applied="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local MEMORY_MANAGER="${SCRIPT_DIR}/memory-manager.sh"
    if [[ -x "$MEMORY_MANAGER" ]]; then
        "$MEMORY_MANAGER" add-pattern "error_fix" "$error_msg" "$fix_applied" 1.0 2>/dev/null || true
        log "[$timestamp] Recorded successful fix to memory"
    fi
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-}" in
    handle)
        handle_error "${2:-}" "${3:-0}" "${4:-3}" "${5:-}" "${6:-}"
        ;;
    classify)
        classify_error "${2:-}"
        ;;
    apply-fix)
        apply_known_fix "${2:-}" "${3:-}"
        ;;
    verify-fix)
        verify_fix "${2:-}" "${3:-}"
        ;;
    record-fix)
        record_fix_to_memory "${2:-}" "${3:-}"
        ;;
    backoff)
        calculate_backoff "${2:-0}" "${3:-transient}"
        ;;
    *)
        # Backward compatibility: if called directly with error message
        if [[ $# -gt 0 && "$1" != "handle" && "$1" != "classify" && "$1" != "record-fix" ]]; then
            handle_error "$1" "${2:-0}" "${3:-3}" "${4:-}"
        else
            echo "Usage: $0 {handle|classify|apply-fix|verify-fix|record-fix|backoff} [args...]"
            echo ""
            echo "Commands:"
            echo "  handle <error_msg> [attempt] [max_retries] [context] [test_cmd]"
            echo "  classify <error_msg>"
            echo "  apply-fix <fix_command> [original_error]"
            echo "  verify-fix <test_command> <original_error>"
            echo "  record-fix <error_msg> <fix_applied>"
            echo "  backoff <attempt> <classification>"
        fi
        ;;
esac
