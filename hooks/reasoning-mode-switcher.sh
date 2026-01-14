#!/bin/bash
# Reasoning Mode Switcher
# Selects appropriate reasoning mode (reflexive/deliberate/reactive) based on task characteristics
# Usage: reasoning-mode-switcher.sh select <task> <context> <urgency> <complexity> <risk>

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/reasoning-mode.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Select reasoning mode based on task characteristics
select() {
    local task="$1"
    local context="${2:-}"
    local urgency="${3:-normal}"
    local complexity="${4:-normal}"
    local risk="${5:-low}"

    log "Selecting reasoning mode for: $task (urgency: $urgency, complexity: $complexity, risk: $risk)"

    local selected_mode="deliberate"
    local confidence=0.7
    local reasoning=""

    # Mode selection logic
    if [[ "$urgency" == "critical" ]]; then
        selected_mode="reactive"
        confidence=0.9
        reasoning="Urgent task requires immediate action with minimal deliberation"
    elif [[ "$complexity" == "low" ]]; then
        selected_mode="reflexive"
        confidence=0.85
        reasoning="Simple task can be executed quickly with minimal planning"
    elif [[ "$risk" == "high" ]]; then
        selected_mode="deliberate"
        confidence=0.9
        reasoning="High-risk task requires thorough analysis and planning"
    elif [[ "$complexity" == "high" ]]; then
        selected_mode="deliberate"
        confidence=0.85
        reasoning="Complex task benefits from Tree of Thoughts exploration"
    else
        selected_mode="deliberate"
        confidence=0.7
        reasoning="Standard task uses balanced deliberate approach"
    fi

    log "Selected mode: $selected_mode (confidence: $confidence)"
    log "Reasoning: $reasoning"

    # Output JSON with selection
    jq -n \
        --arg mode "$selected_mode" \
        --argjson confidence "$confidence" \
        --arg reasoning "$reasoning" \
        '{
            selected_mode: $mode,
            confidence: $confidence,
            reasoning: $reasoning,
            available_modes: ["reflexive", "deliberate", "reactive"]
        }'
}

# Analyze task to determine characteristics
analyze() {
    local task="$1"
    local context="${2:-}"

    log "Analyzing task characteristics: $task"

    local urgency="normal"
    local complexity="normal"
    local risk="low"

    # Detect urgency
    if [[ "$task" =~ (fix|bug|error|urgent|critical|emergency) ]]; then
        urgency="critical"
    elif [[ "$task" =~ (asap|soon|quickly|fast) ]]; then
        urgency="high"
    fi

    # Detect complexity
    if [[ "$task" =~ (implement|architecture|design|complex|comprehensive|system) ]]; then
        complexity="high"
    elif [[ "$task" =~ (typo|comment|simple|quick|minor|small) ]]; then
        complexity="low"
    fi

    # Detect risk
    if [[ "$task" =~ (security|auth|payment|data|production|deployment|database|api) ]]; then
        risk="high"
    elif [[ "$task" =~ (test|documentation|refactor|cleanup) ]]; then
        risk="low"
    fi

    jq -n \
        --arg urgency "$urgency" \
        --arg complexity "$complexity" \
        --arg risk "$risk" \
        '{
            urgency: $urgency,
            complexity: $complexity,
            risk: $risk
        }'
}

# Main CLI
case "${1:-help}" in
    select)
        select "${2:-task}" "${3:-}" "${4:-normal}" "${5:-normal}" "${6:-low}"
        ;;
    analyze)
        analyze "${2:-task}" "${3:-}"
        ;;
    help|*)
        cat <<EOF
Reasoning Mode Switcher - Selects appropriate reasoning mode

Usage:
  $0 select <task> [context] [urgency] [complexity] [risk]
      Select reasoning mode for a task
  $0 analyze <task> [context]
      Analyze task characteristics

Modes:
  reflexive   - Fast execution, minimal deliberation (simple tasks)
  deliberate   - Thorough analysis with Tree of Thoughts (complex/risky tasks)
  reactive     - Immediate action for urgent situations

Characteristics:
  Urgency:   normal | high | critical
  Complexity:  low   | normal | high
  Risk:       low   | normal | high

Examples:
  $0 select "fix typo" "" "normal" "low" "low"
  $0 select "implement auth system" "" "normal" "high" "high"
  $0 analyze "urgent bug fix"
EOF
        ;;
esac
