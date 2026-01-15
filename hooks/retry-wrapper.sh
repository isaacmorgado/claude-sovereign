#!/bin/bash
# Retry Wrapper - Exponential backoff and circuit breaker for /auto hooks
# Provides resilience patterns for autonomous operations
#
# Usage:
#   retry-wrapper.sh exec <command> [args...]     Execute with retry
#   retry-wrapper.sh check <hook>                  Check circuit breaker state
#   retry-wrapper.sh reset <hook>                  Reset circuit breaker
#   retry-wrapper.sh status                        Show all circuit states

set -uo pipefail

CIRCUIT_STATE_DIR="${HOME}/.claude/circuit-breaker"
LOG_FILE="${HOME}/.claude/retry-wrapper.log"
MAX_RETRIES="${MAX_RETRIES:-3}"
BACKOFF_BASE="${BACKOFF_BASE:-1}"
CIRCUIT_THRESHOLD="${CIRCUIT_THRESHOLD:-5}"
CIRCUIT_RESET_SECONDS="${CIRCUIT_RESET_SECONDS:-300}"

mkdir -p "$CIRCUIT_STATE_DIR" "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =============================================================================
# EXPONENTIAL BACKOFF RETRY
# =============================================================================

retry_with_backoff() {
    local cmd="$1"
    shift
    local max="$MAX_RETRIES"
    local delay="$BACKOFF_BASE"
    local attempt=1
    local result=""
    local exit_code=0

    while [[ $attempt -le $max ]]; do
        log "Attempt $attempt/$max: $cmd $*"
        
        # Execute (timeout via background process for macOS compatibility)
        if result=$( (
            "$cmd" "$@" &
            pid=$!
            ( sleep 30; kill $pid 2>/dev/null ) &
            timeout_pid=$!
            wait $pid 2>/dev/null
            exit_status=$?
            kill $timeout_pid 2>/dev/null
            exit $exit_status
        ) 2>&1); then
            log "Success on attempt $attempt"
            echo "$result"
            record_success "$cmd"
            return 0
        else
            exit_code=$?
            log "Attempt $attempt failed (exit: $exit_code)"
        fi

        if [[ $attempt -lt $max ]]; then
            local wait_time=$((delay * (2 ** (attempt - 1))))
            log "Waiting ${wait_time}s before retry..."
            sleep "$wait_time"
        fi

        attempt=$((attempt + 1))
    done

    # All retries exhausted
    log "All $max attempts failed for: $cmd"
    record_failure "$cmd"
    echo "$result"
    return 1
}

# =============================================================================
# CIRCUIT BREAKER
# =============================================================================

get_state_file() {
    local hook="$1"
    local basename
    basename=$(basename "$hook" .sh)
    echo "$CIRCUIT_STATE_DIR/${basename}.json"
}

record_success() {
    local hook="$1"
    local state_file
    state_file=$(get_state_file "$hook")
    
    # Reset failure count on success
    cat > "$state_file" <<EOF
{
  "hook": "$(basename "$hook")",
  "failures": 0,
  "last_success": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "state": "closed"
}
EOF
}

record_failure() {
    local hook="$1"
    local state_file
    state_file=$(get_state_file "$hook")
    
    local failures=0
    if [[ -f "$state_file" ]]; then
        failures=$(jq -r '.failures // 0' "$state_file" 2>/dev/null || echo 0)
    fi
    
    failures=$((failures + 1))
    local state="closed"
    
    if [[ $failures -ge $CIRCUIT_THRESHOLD ]]; then
        state="open"
        log "CIRCUIT OPEN for $(basename "$hook") after $failures failures"
    fi
    
    cat > "$state_file" <<EOF
{
  "hook": "$(basename "$hook")",
  "failures": $failures,
  "last_failure": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "state": "$state"
}
EOF
}

check_circuit() {
    local hook="$1"
    local state_file
    state_file=$(get_state_file "$hook")
    
    if [[ ! -f "$state_file" ]]; then
        echo "closed"
        return 0
    fi
    
    local state
    state=$(jq -r '.state // "closed"' "$state_file" 2>/dev/null || echo "closed")
    
    # Check if circuit should auto-reset
    if [[ "$state" == "open" ]]; then
        local last_failure
        last_failure=$(jq -r '.last_failure // ""' "$state_file" 2>/dev/null)
        
        if [[ -n "$last_failure" ]]; then
            local failure_epoch
            local now_epoch
            failure_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_failure" +%s 2>/dev/null || date +%s)
            now_epoch=$(date +%s)
            
            if [[ $((now_epoch - failure_epoch)) -gt $CIRCUIT_RESET_SECONDS ]]; then
                log "Circuit auto-reset for $(basename "$hook") after ${CIRCUIT_RESET_SECONDS}s"
                state="half-open"
                jq '.state = "half-open"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
            fi
        fi
    fi
    
    echo "$state"
}

reset_circuit() {
    local hook="$1"
    local state_file
    state_file=$(get_state_file "$hook")
    
    if [[ -f "$state_file" ]]; then
        jq '.failures = 0 | .state = "closed"' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        log "Circuit manually reset for $(basename "$hook")"
        echo "Circuit reset for $(basename "$hook")"
    else
        echo "No circuit state found for $(basename "$hook")"
    fi
}

# =============================================================================
# WRAPPED EXECUTION
# =============================================================================

safe_exec() {
    local cmd="$1"
    shift
    
    # Check circuit breaker first
    local circuit_state
    circuit_state=$(check_circuit "$cmd")
    
    if [[ "$circuit_state" == "open" ]]; then
        log "BLOCKED: Circuit open for $(basename "$cmd")"
        echo '{"error":"circuit_open","hook":"'"$(basename "$cmd")"'"}'
        return 1
    fi
    
    # Execute with retry
    retry_with_backoff "$cmd" "$@"
}

# =============================================================================
# STATUS
# =============================================================================

show_status() {
    echo "Circuit Breaker Status"
    echo "======================"
    
    if [[ ! -d "$CIRCUIT_STATE_DIR" ]] || [[ -z "$(ls -A "$CIRCUIT_STATE_DIR" 2>/dev/null)" ]]; then
        echo "No circuit states recorded yet."
        return 0
    fi
    
    for state_file in "$CIRCUIT_STATE_DIR"/*.json; do
        if [[ -f "$state_file" ]]; then
            local hook state failures
            hook=$(jq -r '.hook // "unknown"' "$state_file")
            state=$(jq -r '.state // "unknown"' "$state_file")
            failures=$(jq -r '.failures // 0' "$state_file")
            
            local icon="✓"
            [[ "$state" == "open" ]] && icon="✗"
            [[ "$state" == "half-open" ]] && icon="?"
            
            printf "  %s %-30s %s (failures: %d)\n" "$icon" "$hook" "$state" "$failures"
        fi
    done
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    exec)
        shift
        safe_exec "$@"
        ;;
    check)
        check_circuit "${2:-}"
        ;;
    reset)
        reset_circuit "${2:-}"
        ;;
    status)
        show_status
        ;;
    help|*)
        cat <<'EOF'
Retry Wrapper - Resilience patterns for /auto hooks

USAGE:
    retry-wrapper.sh exec <command> [args...]
    retry-wrapper.sh check <hook>
    retry-wrapper.sh reset <hook>
    retry-wrapper.sh status

ENVIRONMENT:
    MAX_RETRIES=3             Maximum retry attempts
    BACKOFF_BASE=1            Initial backoff delay (seconds)
    CIRCUIT_THRESHOLD=5       Failures before circuit opens
    CIRCUIT_RESET_SECONDS=300 Auto-reset after this many seconds

EXAMPLES:
    # Execute with retry
    retry-wrapper.sh exec ~/.claude/hooks/memory-manager.sh get-working

    # Check circuit state
    retry-wrapper.sh check memory-manager

    # Reset a tripped circuit
    retry-wrapper.sh reset memory-manager
EOF
        ;;
esac
