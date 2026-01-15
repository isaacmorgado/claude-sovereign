#!/bin/bash
# Enhanced Audit Trail - Simple working version
set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
AUDIT_LOG="${CLAUDE_DIR}/.audit/decisions.jsonl"
LOG_FILE="${CLAUDE_DIR}/audit-trail.log"

mkdir -p "$(dirname "$AUDIT_LOG")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_decision() {
    local action="$1"
    local reasoning="$2"
    local alternatives="$3"
    local why_chosen="$4"
    local confidence="${5:-0.8}"

    local record
    record=$(jq -n \
        --arg action "$action" \
        --arg reasoning "$reasoning" \
        --arg alternatives "$alternatives" \
        --arg why "$why_chosen" \
        --arg conf "$confidence" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            timestamp: $ts,
            action: $action,
            reasoning: $reasoning,
            alternatives_considered: $alternatives,
            why_chosen: $why,
            confidence: ($conf | tonumber)
        }')

    echo "$record" >> "$AUDIT_LOG"

    log "Logged decision: $action (confidence: $confidence)"
    echo "$record"
}

get_history() {
    local limit="${1:-10}"

    if [[ ! -f "$AUDIT_LOG" ]]; then
        echo '[]'
        return
    fi

    tail -n "$limit" "$AUDIT_LOG" | jq -s '.'
}

case "${1:-help}" in
    log)
        log_decision "${2:-action}" "${3:-reasoning}" "${4:-alternatives}" "${5:-why}" "${6:-0.8}"
        ;;
    history)
        get_history "${2:-10}"
        ;;
    *)
        echo "Usage: $0 {log|history}"
        ;;
esac
