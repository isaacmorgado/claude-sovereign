#!/bin/bash
# Context Optimizer - Predicts and optimizes context window usage

set -uo pipefail

CONTEXT_DIR="${HOME}/.claude/context"
USAGE_HISTORY="$CONTEXT_DIR/usage_history.jsonl"
PREDICTIONS="$CONTEXT_DIR/predictions.json"
LOG_FILE="${HOME}/.claude/context-optimizer.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_context() {
    mkdir -p "$CONTEXT_DIR"
    [[ -f "$USAGE_HISTORY" ]] || touch "$USAGE_HISTORY"
    [[ -f "$PREDICTIONS" ]] || echo '{}' > "$PREDICTIONS"
}

# Record context usage
record_usage() {
    local operation="$1"
    local tokens_used="$2"
    local files_loaded="${3:-0}"

    init_context

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local record
    record=$(jq -n \
        --arg op "$operation" \
        --argjson tokens "$tokens_used" \
        --argjson files "$files_loaded" \
        --arg ts "$timestamp" \
        '{operation: $op, tokens: $tokens, files: $files, timestamp: $ts}')

    echo "$record" >> "$USAGE_HISTORY"
    log "Recorded: $operation used $tokens_used tokens"
}

# Predict tokens needed for operation
predict_tokens() {
    local operation="$1"
    local file_count="${2:-1}"

    init_context

    # Get historical average for this operation
    local avg_tokens
    avg_tokens=$(grep "\"operation\":\"$operation\"" "$USAGE_HISTORY" 2>/dev/null | \
        jq -s 'if length > 0 then ([.[].tokens] | add / length | floor) else 5000 end')

    # Adjust for file count (rough estimate: 1000 tokens per file)
    local predicted
    predicted=$((avg_tokens + (file_count * 1000)))

    echo "{\"operation\":\"$operation\",\"predictedTokens\":$predicted,\"confidence\":\"medium\"}"
}

# Check if operation will exceed threshold
will_exceed_threshold() {
    local current_usage="$1"
    local operation="$2"
    local threshold="${3:-80}"  # percentage
    local max_tokens="${4:-200000}"

    local prediction
    prediction=$(predict_tokens "$operation")
    local predicted_tokens
    predicted_tokens=$(echo "$prediction" | jq -r '.predictedTokens')

    local total_after
    total_after=$((current_usage + predicted_tokens))
    local percent_after
    percent_after=$((total_after * 100 / max_tokens))

    if [[ $percent_after -gt $threshold ]]; then
        echo "{\"willExceed\":true,\"percentAfter\":$percent_after,\"recommendation\":\"Consider compacting context first\"}"
    else
        echo "{\"willExceed\":false,\"percentAfter\":$percent_after,\"recommendation\":\"Safe to proceed\"}"
    fi
}

# Optimize context by identifying low-value content
optimize() {
    local current_files="$1"  # JSON array of loaded files

    # Score files by relevance (placeholder - real impl would use embeddings)
    echo "$current_files" | jq '[
        .[] |
        . + {relevanceScore: (if .lastAccessed then 70 else 30 end)}
    ] | sort_by(-.relevanceScore)'
}

case "${1:-help}" in
    record) record_usage "${2:-op}" "${3:-0}" "${4:-0}" ;;
    predict) predict_tokens "${2:-op}" "${3:-1}" ;;
    check-threshold) will_exceed_threshold "${2:-0}" "${3:-op}" "${4:-80}" "${5:-200000}" ;;
    optimize) optimize "${2:-[]}" ;;
    *) echo "Usage: $0 {record|predict|check-threshold|optimize} [args]" ;;
esac
