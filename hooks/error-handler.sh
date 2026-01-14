#!/bin/bash
# Error Handler - Centralized Error Management and Recovery
# Handles errors, provides recovery strategies, and tracks error patterns
# Usage: error-handler.sh handle | analyze | recover | patterns

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/error-handler.log"
STATE_FILE="${HOME}/.claude/error-handler-state.json"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize state
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "errors": [],
    "error_patterns": {},
    "recovery_strategies": {
        "syntax_error": {
            "name": "Syntax Error",
            "severity": "high",
            "recovery": "Check syntax, fix typos, validate code structure"
        },
        "runtime_error": {
            "name": "Runtime Error",
            "severity": "critical",
            "recovery": "Check inputs, validate state, add error handling"
        },
        "network_error": {
            "name": "Network Error",
            "severity": "medium",
            "recovery": "Check connection, retry, use fallback"
        },
        "file_not_found": {
            "name": "File Not Found",
            "severity": "medium",
            "recovery": "Verify path, check permissions, create if needed"
        },
        "permission_denied": {
            "name": "Permission Denied",
            "severity": "high",
            "recovery": "Check permissions, run with appropriate privileges"
        },
        "timeout": {
            "name": "Timeout",
            "severity": "medium",
            "recovery": "Increase timeout, optimize operation, retry"
        },
        "out_of_memory": {
            "name": "Out of Memory",
            "severity": "critical",
            "recovery": "Free memory, optimize usage, increase allocation"
        }
    },
    "metrics": {
        "total_errors": 0,
        "errors_by_type": {},
        "errors_by_severity": {}
    }
}
EOF
    fi
}

# Handle an error
handle() {
    local error_type="${1:-unknown}"
    local error_message="${2:-}"
    local context="${3:-}"
    local exit_code="${4:-1}"

    init_state
    log "Handling error: $error_type (exit_code: $exit_code)"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Get recovery strategy
    local recovery
    recovery=$(jq -r ".recovery_strategies[\"$error_type\"].recovery // \"Unknown error type\"" "$STATE_FILE")

    local severity
    severity=$(jq -r ".recovery_strategies[\"$error_type\"].severity // \"unknown\"" "$STATE_FILE")

    # Create error record
    local error_record
    error_record=$(jq -n \
        --arg error_type "$error_type" \
        --arg error_message "$error_message" \
        --arg context "$context" \
        --argjson exit_code "$exit_code" \
        --arg severity "$severity" \
        --arg recovery "$recovery" \
        --arg timestamp "$timestamp" \
        '{
            error_type: $error_type,
            error_message: $error_message,
            context: $context,
            exit_code: $exit_code,
            severity: $severity,
            recovery: $recovery,
            timestamp: $timestamp,
            resolved: false
        }')

    jq ".errors += [$error_record]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    # Update metrics
    jq ".metrics.total_errors += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    jq ".metrics.errors_by_type[\"$error_type\"] = ((.metrics.errors_by_type[\"$error_type\"] // 0) + 1)" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    jq ".metrics.errors_by_severity[\"$severity\"] = ((.metrics.errors_by_severity[\"$severity\"] // 0) + 1)" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Error handled: $error_type (severity: $severity)"

    # Output result
    jq -n \
        --arg error_type "$error_type" \
        --arg error_message "$error_message" \
        --arg severity "$severity" \
        --arg recovery "$recovery" \
        --arg timestamp "$timestamp" \
        '{
            error_type: $error_type,
            error_message: $error_message,
            severity: $severity,
            recovery: $recovery,
            timestamp: $timestamp,
            message: "Error handled, recovery strategy provided"
        }'
}

# Analyze error patterns
analyze() {
    init_state
    log "Analyzing error patterns"

    # Get recent errors
    local recent_errors
    recent_errors=$(jq '.errors[-50:]' "$STATE_FILE")

    local error_count
    error_count=$(echo "$recent_errors" | jq 'length')

    if [[ $error_count -eq 0 ]]; then
        jq -n \
            '{
                count: 0,
                message: "No errors to analyze"
            }'
        return
    fi

    # Group by error type
    local by_type
    by_type=$(echo "$recent_errors" | jq 'group_by(.error_type) | map({type: .[0].error_type, count: length}) | sort_by(-.count)')

    # Group by severity
    local by_severity
    by_severity=$(echo "$recent_errors" | jq 'group_by(.severity) | map({severity: .[0].severity, count: length}) | sort_by(-.count)')

    # Find most common error
    local most_common
    most_common=$(echo "$by_type" | jq '.[0] // {type: "none", count: 0}')

    # Find unresolved errors
    local unresolved
    unresolved=$(echo "$recent_errors" | jq '[.[] | select(.resolved == false)] | length')

    log "Analysis complete: $error_count errors, $unresolved unresolved"

    # Output result
    jq -n \
        --argjson count "$error_count" \
        --argjson unresolved "$unresolved" \
        --argjson by_type "$by_type" \
        --argjson by_severity "$by_severity" \
        --argjson most_common "$most_common" \
        '{
            total_errors: $count,
            unresolved_errors: $unresolved,
            errors_by_type: $by_type,
            errors_by_severity: $by_severity,
            most_common_error: $most_common,
            recommendation: (if $unresolved > 10 then "High number of unresolved errors - review recovery strategies"
                          elif $unresolved > 5 then "Some unresolved errors - consider prioritizing resolution"
                          else "Error handling is effective" end)
        }'
}

# Recover from error
recover() {
    local error_id="${1:-}"
    local recovery_action="${2:-}"

    init_state
    log "Recovering from error: $error_id"

    if [[ -z "$error_id" ]]; then
        echo '{"error":"error_id_required"}' | jq '.'
        return 1
    fi

    # Find error
    local error_record
    error_record=$(jq ".errors[] | select(.timestamp == \"$error_id\")" "$STATE_FILE")

    if [[ "$error_record" == "null" ]]; then
        echo '{"error":"error_not_found"}' | jq '.'
        return 1
    fi

    # Mark as resolved
    jq "(.errors[] | select(.timestamp == \"$error_id\")) |= (.resolved = true | .resolved_at = \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\" | .recovery_action = \"$recovery_action\")" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Error resolved: $error_id"

    # Output result
    jq -n \
        --arg error_id "$error_id" \
        --arg recovery_action "$recovery_action" \
        '{
            error_id: $error_id,
            recovery_action: $recovery_action,
            resolved: true,
            message: "Error marked as resolved"
        }'
}

# Get error patterns
patterns() {
    init_state

    jq '.error_patterns' "$STATE_FILE"
}

# Get error history
history() {
    local limit="${1:-10}"

    init_state

    jq ".errors[-$limit:]" "$STATE_FILE"
}

# Get metrics
metrics() {
    init_state

    jq '.metrics' "$STATE_FILE"
}

# Get recovery strategies
strategies() {
    init_state

    jq '.recovery_strategies' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Error handler state initialized"
        ;;
    handle)
        handle "${2:-unknown}" "${3:-}" "${4:-}" "${5:-1}"
        ;;
    analyze)
        analyze
        ;;
    recover)
        recover "${2:-error_id}" "${3:-}"
        ;;
    patterns)
        patterns
        ;;
    history)
        history "${2:-10}"
        ;;
    metrics)
        metrics
        ;;
    strategies)
        strategies
        ;;
    help|*)
        cat <<EOF
Error Handler - Centralized Error Management and Recovery

Usage:
  $0 handle <error_type> [message] [context] [exit_code]  Handle an error
  $0 analyze                                           Analyze error patterns
  $0 recover <error_id> [recovery_action]            Recover from error
  $0 patterns                                           Get error patterns
  $0 history [limit]                                    Get error history
  $0 metrics                                            Get error metrics
  $0 strategies                                          Get recovery strategies

Error Types:
  syntax_error      - Syntax errors in code
  runtime_error    - Runtime errors during execution
  network_error     - Network-related errors
  file_not_found    - Missing file errors
  permission_denied - Permission errors
  timeout          - Timeout errors
  out_of_memory    - Memory exhaustion

Severity Levels:
  critical   - System-critical errors
  high       - High-priority errors
  medium     - Medium-priority errors
  low        - Low-priority errors

Examples:
  $0 handle "syntax_error" "Unexpected token" "parser.ts" 1
  $0 analyze
  $0 recover "2024-01-01T00:00:00Z" "Fixed syntax error"
  $0 history 20
  $0 metrics
EOF
        ;;
esac
