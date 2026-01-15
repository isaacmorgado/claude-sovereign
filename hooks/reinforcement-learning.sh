#!/bin/bash
set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
RL_DATA="${CLAUDE_DIR}/.rl/outcomes.jsonl"
LOG_FILE="${CLAUDE_DIR}/rl-tracker.log"

mkdir -p "$(dirname "$RL_DATA")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

record_outcome() {
    local action_type="$1"
    local context="$2"
    local outcome="$3"
    local reward="${4:-0}"
    
    log "Recording: $action_type -> $outcome"
    
    jq -n \
        --arg type "$action_type" \
        --arg ctx "$context" \
        --arg outcome "$outcome" \
        --arg reward "$reward" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{timestamp: $ts, action_type: $type, context: $ctx, outcome: $outcome, reward: ($reward | tonumber)}' >> "$RL_DATA"
    
    echo '{"status":"recorded"}'
}

get_success_rate() {
    local action_type="$1"
    local window="${2:-20}"
    
    if [[ ! -f "$RL_DATA" ]]; then
        echo '{"success_rate":0.5,"confidence":"low","sample_size":0}'
        return
    fi
    
    tail -n 100 "$RL_DATA" | jq -s --arg type "$action_type" --argjson window "$window" '
        map(select(.action_type == $type)) | .[-$window:] | 
        {total: length, successes: (map(select(.outcome == "success")) | length)} |
        . + {success_rate: (if .total > 0 then .successes / .total else 0.5 end), 
             confidence: (if .total >= 10 then "high" elif .total >= 5 then "medium" else "low" end),
             sample_size: .total}'
}

case "${1:-help}" in
    record) record_outcome "${2:-action}" "${3:-ctx}" "${4:-success}" "${5:-0}" ;;
    success-rate) get_success_rate "${2:-action}" "${3:-20}" ;;
    *) echo "Usage: $0 {record|success-rate}" ;;
esac
