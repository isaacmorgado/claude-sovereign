#!/bin/bash
# Meta-Reflection - Reflects on own decision-making process

set -uo pipefail

REFLECTION_DIR="${HOME}/.claude/reflections"
REFLECTIONS_FILE="$REFLECTION_DIR/meta_reflections.jsonl"
LOG_FILE="${HOME}/.claude/meta-reflection.log"

MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_reflection() {
    mkdir -p "$REFLECTION_DIR"
    [[ -f "$REFLECTIONS_FILE" ]] || touch "$REFLECTIONS_FILE"
}

# Create reflection after significant work
reflect() {
    local focus="$1"  # why_worked, why_failed, what_learned, alternatives
    local task="$2"
    local outcome="$3"
    local reasoning="${4:-}"

    init_reflection

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local reflection
    case "$focus" in
        why_worked)
            reflection="Task '$task' succeeded. Key factors: $reasoning. This approach should be reused for similar tasks."
            ;;
        why_failed)
            reflection="Task '$task' failed. Root causes: $reasoning. Future tasks should avoid this approach or address these issues first."
            ;;
        what_learned)
            reflection="From task '$task': $reasoning. This insight will improve future decision-making."
            ;;
        alternatives)
            reflection="Task '$task' completed, but alternative approaches considered: $reasoning. May be more efficient for similar future tasks."
            ;;
    esac

    local record
    record=$(jq -n \
        --arg focus "$focus" \
        --arg task "$task" \
        --arg outcome "$outcome" \
        --arg reflection "$reflection" \
        --arg ts "$timestamp" \
        '{focus: $focus, task: $task, outcome: $outcome, reflection: $reflection, timestamp: $ts}' 2>/dev/null || echo '{"focus":"error","task":"error","outcome":"error","reflection":"error","timestamp":"error"}')

    echo "$record" >> "$REFLECTIONS_FILE"

    # Store in memory as semantic knowledge
    [[ -x "$MEMORY_MANAGER" ]] && \
        "$MEMORY_MANAGER" reflect "$focus" "$reflection" "$reasoning" 2>/dev/null || true

    log "Created meta-reflection: $focus for $task"
    echo "$record"
}

# Get insights from reflections
get_insights() {
    local focus="${1:-}"

    init_reflection

    if [[ -n "$focus" ]]; then
        grep "\"focus\":\"$focus\"" "$REFLECTIONS_FILE" 2>/dev/null | jq -s '.' || echo '[]'
    else
        jq -s '.' "$REFLECTIONS_FILE" 2>/dev/null || echo '[]'
    fi
}

case "${1:-help}" in
    reflect) reflect "${2:-what_learned}" "${3:-task}" "${4:-success}" "${5:-}" ;;
    insights) get_insights "${2:-}" ;;
    *) echo "Usage: $0 {reflect|insights} [args]" ;;
esac
