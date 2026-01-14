#!/bin/bash
# Enhanced Audit Trail - Decision Logging
# Logs all autonomous decisions with reasoning and alternatives
# Usage: enhanced-audit-trail.sh log <action> <reasoning> <alternatives> <why_chosen> <confidence>

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/enhanced-audit-trail.log"
AUDIT_FILE="${HOME}/.claude/audit-trail.jsonl"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$AUDIT_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Log a decision to audit trail
log() {
    local action="$1"
    local reasoning="$2"
    local alternatives="${3:-[]}"
    local why_chosen="${4:-}"
    local confidence="${5:-0.5}"

    log "Logging decision: $action"

    # Create audit entry
    local audit_entry
    audit_entry=$(jq -n \
        --arg action "$action" \
        --arg reasoning "$reasoning" \
        --argjson alternatives "$alternatives" \
        --arg why_chosen "$why_chosen" \
        --argjson confidence "$confidence" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            action: $action,
            reasoning: $reasoning,
            alternatives: $alternatives,
            why_chosen: $why_chosen,
            confidence: ($confidence | tonumber),
            timestamp: $ts
        }')

    # Append to audit trail
    echo "$audit_entry" >> "$AUDIT_FILE"

    log "Audit entry logged"

    echo '{"status": "logged", "action": "'"$action"'"}'
}

# Query audit trail
query() {
    local action_filter="${1:-}"
    local limit="${2:-50}"

    log "Querying audit trail: filter=$action_filter, limit=$limit"

    if [[ ! -f "$AUDIT_FILE" ]]; then
        echo "[]"
        return
    fi

    local results
    if [[ -n "$action_filter" ]]; then
        results=$(tail -n 1000 "$AUDIT_FILE" | jq -s --arg action "$action_filter" 'select(.action == $action)' | jq -s --argjson limit "$limit" '.[0:'"$limit"']')
    else
        results=$(tail -n 1000 "$AUDIT_FILE" | jq -s 'reverse | .[0:'"$limit"']')
    fi

    echo "$results"
}

# Get audit statistics
stats() {
    log "Calculating audit trail statistics"

    if [[ ! -f "$AUDIT_FILE" ]]; then
        echo '{"total_entries": 0}'
        return
    fi

    local total_entries
    total_entries=$(wc -l < "$AUDIT_FILE" 2>/dev/null || echo "0")

    local unique_actions
    unique_actions=$(tail -n 10000 "$AUDIT_FILE" | jq -s 'map(.action) | unique' | jq -s 'length')

    local avg_confidence
    avg_confidence=$(tail -n 10000 "$AUDIT_FILE" | jq -s 'map(.confidence) | add / length' | jq -r 'if . then . else "0.5"')

    local recent_entries
    recent_entries=$(tail -n 1000 "$AUDIT_FILE" | jq -s 'reverse | .[0:10]')

    jq -n \
        --argjson total "$total_entries" \
        --argjson unique "$unique_actions" \
        --argjson avg_confidence "$avg_confidence" \
        --argjson recent "$recent_entries" \
        '{
            total_entries: $total,
            unique_actions: $unique,
            average_confidence: $avg_confidence,
            recent_entries: $recent
        }'
}

# Get recent decisions by action type
recent() {
    local action_type="${1:-}"
    local limit="${2:-10}"

    log "Getting recent decisions: action=$action_type, limit=$limit"

    if [[ ! -f "$AUDIT_FILE" ]]; then
        echo "[]"
        return
    fi

    if [[ -n "$action_type" ]]; then
        tail -n 1000 "$AUDIT_FILE" | jq -s --arg action "$action_type" 'select(.action == $action) | reverse | .[0:'"$limit"']'
    else
        tail -n 1000 "$AUDIT_FILE" | jq -s 'reverse | .[0:'"$limit"']'
    fi
}

# Export audit trail
export() {
    local output_file="${1:-audit-trail-export.json}"
    local format="${2:-json}"

    log "Exporting audit trail to: $output_file"

    if [[ ! -f "$AUDIT_FILE" ]]; then
        echo '{"error": "No audit trail to export"}'
        return
    fi

    case "$format" in
        json)
            tail -n 10000 "$AUDIT_FILE" > "$output_file"
            ;;
        csv)
            echo "action,reasoning,alternatives,why_chosen,confidence,timestamp" > "$output_file"
            tail -n 10000 "$AUDIT_FILE" | jq -r '@csv' >> "$output_file"
            ;;
        markdown)
            echo "# Audit Trail Export" > "$output_file"
            echo "" >> "$output_file"
            echo "Generated: $(date)" >> "$output_file"
            echo "" >> "$output_file"
            echo "| Action | Reasoning | Why Chosen | Confidence | Timestamp |" >> "$output_file"
            echo "|---------|-----------|-------------|------------|" >> "$output_file"
            tail -n 10000 "$AUDIT_FILE" | jq -r '@csv' | while IFS=, read -r action reasoning alternatives why_chosen confidence timestamp; do
                echo "| $action | $reasoning | $why_chosen | $confidence | $timestamp |" >> "$output_file"
            done
            ;;
        *)
            echo '{"error": "Unsupported format: '"$format"'"}'
            return
            ;;
    esac

    log "Exported audit trail to $output_file"

    echo '{"status": "exported", "file": "'"$output_file"'", "format": "'"$format"'"}'
}

# Clear audit trail
clear() {
    log "Clearing audit trail"

    if [[ -f "$AUDIT_FILE" ]]; then
        local backup="${AUDIT_FILE}.backup.$(date +%s)"
        cp "$AUDIT_FILE" "$backup"
        rm "$AUDIT_FILE"
        log "Audit trail cleared (backup: $backup)"
    fi

    echo '{"status": "cleared"}'
}

# Main CLI
case "${1:-help}" in
    log)
        log "${2:-action}" "${3:-reasoning}" "${4:-}" "${5:-why_chosen}" "${6:-0.5}"
        ;;
    query)
        query "${2:-}" "${3:-50}"
        ;;
    stats)
        stats
        ;;
    recent)
        recent "${2:-}" "${3:-10}"
        ;;
    export)
        export "${2:-audit-trail-export.json}" "${3:-json}"
        ;;
    clear)
        clear
        ;;
    help|*)
        cat <<EOF
Enhanced Audit Trail - Decision Logging

Usage:
  $0 log <action> <reasoning> [alternatives] [why_chosen] [confidence]
      Log a decision to audit trail
  $0 query [action_filter] [limit]
      Query audit trail history
  $0 stats                             Get audit statistics
  $0 recent [action_type] [limit]
      Get recent decisions by type
  $0 export <output_file> [format]
      Export audit trail (json|csv|markdown)
  $0 clear                             Clear audit trail (creates backup)

Parameters:
  action           - Action taken (e.g., "deploy", "checkpoint", "compact")
  reasoning         - Reasoning behind the decision
  alternatives      - JSON array of alternatives considered
  why_chosen       - Why this action was chosen
  confidence       - Confidence level (0.0-1.0)

Formats:
  json      - JSON format (default)
  csv       - CSV format for spreadsheet analysis
  markdown   - Markdown table for readability

Examples:
  $0 log "deploy" "Production ready, tests passing" '["deploy_now","wait","cancel"]' "Production ready" 0.9
  $0 query "checkpoint" 20
  $0 stats
  $0 recent "compact" 5
  $0 export audit.md markdown
EOF
        ;;
esac
