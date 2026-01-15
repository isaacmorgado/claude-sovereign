#!/bin/bash
# Pattern Miner - Mines successful patterns from memory and history
# Uses: memory, learning-engine, feedback-loop

set -uo pipefail

PATTERNS_DIR="${HOME}/.claude/patterns"
MINED_PATTERNS="$PATTERNS_DIR/mined.json"
LOG_FILE="${HOME}/.claude/pattern-miner.log"

MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"
LEARNING_ENGINE="${HOME}/.claude/hooks/learning-engine.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_patterns() {
    mkdir -p "$PATTERNS_DIR"
    [[ -f "$MINED_PATTERNS" ]] || echo '{"patterns":[]}' > "$MINED_PATTERNS"
}

# Mine patterns from memory
mine_from_memory() {
    local query="$1"
    local limit="${2:-10}"

    [[ ! -x "$MEMORY_MANAGER" ]] && echo '[]' && return

    # Query episodic memory for successful tasks
    local episodes
    episodes=$("$MEMORY_MANAGER" remember-scored "$query" "$limit" 2>/dev/null || echo '[]')

    # Extract patterns
    echo "$episodes" | jq '[
        .[] |
        select(.type == "episode" and (.metadata.outcome // "unknown") == "success") |
        {
            description: .content,
            approach: .metadata.action_type,
            details: .metadata.details,
            timestamp: .timestamp,
            source: "memory"
        }
    ]'
}

# Mine patterns from learning engine
mine_from_learning() {
    local task_type="$1"

    [[ ! -x "$LEARNING_ENGINE" ]] && echo '[]' && return

    "$LEARNING_ENGINE" mine-patterns "$task_type" 10 2>/dev/null || echo '[]'
}

# Mine all patterns
mine_all() {
    local task_type="${1:-}"

    init_patterns

    local memory_patterns
    memory_patterns=$(mine_from_memory "$task_type" 10)

    local learning_patterns
    learning_patterns=$(mine_from_learning "$task_type")

    # Combine and deduplicate
    jq -s '.[0] + .[1] | unique_by(.description)' \
        <(echo "$memory_patterns") \
        <(echo "$learning_patterns")
}

# Get best practices for task type
get_best_practices() {
    local task_type="$1"

    local patterns
    patterns=$(mine_all "$task_type")

    # Score patterns by frequency and recency
    echo "$patterns" | jq '
        group_by(.approach) |
        map({
            approach: .[0].approach,
            count: length,
            examples: [.[] | {description, details}] | .[:3],
            recommendation: "Use \(.[0].approach) approach - successful in \(length) cases"
        }) |
        sort_by(-.count)
    '
}

case "${1:-help}" in
    mine) mine_all "${2:-}" ;;
    best-practices) get_best_practices "${2:-general}" ;;
    *) echo "Usage: $0 {mine|best-practices} [task_type]" ;;
esac
