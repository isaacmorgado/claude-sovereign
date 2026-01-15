#!/bin/bash
# Dynamic Reasoning Mode Switcher - Context-aware reasoning strategy selection
# Based on: servicesground agentic patterns, emergentmind ReAct architectures
# Switches between reflexive, deliberate, and reactive modes

set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
LOG_FILE="${CLAUDE_DIR}/reasoning-modes.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Reasoning mode definitions
get_reasoning_modes() {
    cat << 'EOF'
{
    "modes": {
        "reflexive": {
            "description": "Fast, intuitive decision-making for simple tasks",
            "use_when": [
                "Task is straightforward",
                "Similar task succeeded before",
                "Low risk/impact",
                "Time-critical"
            ],
            "characteristics": {
                "speed": "fast",
                "thoroughness": "low",
                "exploration": "minimal"
            },
            "tools": ["direct_execution", "pattern_matching"]
        },
        "deliberate": {
            "description": "Careful, step-by-step reasoning with verification",
            "use_when": [
                "Complex problem",
                "Multiple valid approaches",
                "High risk/impact",
                "Novel situation"
            ],
            "characteristics": {
                "speed": "slow",
                "thoroughness": "high",
                "exploration": "extensive"
            },
            "tools": ["tree_of_thoughts", "chain_of_thought", "self_reflection"]
        },
        "reactive": {
            "description": "Rapid response to immediate needs",
            "use_when": [
                "Emergency/urgent",
                "Clear single path forward",
                "Undo-able action",
                "Low complexity"
            ],
            "characteristics": {
                "speed": "very_fast",
                "thoroughness": "minimal",
                "exploration": "none"
            },
            "tools": ["direct_action"]
        }
    }
}
EOF
}

# Select reasoning mode based on context
select_mode() {
    local task="$1"
    local context="$2"
    local urgency="${3:-normal}"
    local complexity="${4:-medium}"
    local risk="${5:-medium}"

    log "Selecting reasoning mode for: $task (urgency=$urgency, complexity=$complexity, risk=$risk)"

    local selected_mode="deliberate"

    # Decision logic
    if [[ "$urgency" == "high" || "$urgency" == "critical" ]]; then
        selected_mode="reactive"
    elif [[ "$complexity" == "low" && "$risk" == "low" ]]; then
        selected_mode="reflexive"
    elif [[ "$complexity" == "high" || "$risk" == "high" ]]; then
        selected_mode="deliberate"
    fi

    local modes
    modes=$(get_reasoning_modes)

    echo "$modes" | jq --arg mode "$selected_mode" '{
        selected_mode: $mode,
        mode_info: .modes[$mode],
        decision_factors: {
            urgency: "'"$urgency"'",
            complexity: "'"$complexity"'",
            risk: "'"$risk"'"
        }
    }'
}

# Analyze task to determine characteristics
analyze_task_characteristics() {
    local task="$1"

    cat << EOF
{
    "analysis_prompt": "Analyze this task to determine reasoning mode:

**Task:** $task

Rate each dimension (low/medium/high):

1. **Complexity**: How complex is this task?
   - Low: Simple, well-defined
   - Medium: Moderate difficulty, some unknowns
   - High: Complex, multiple approaches, many unknowns

2. **Risk**: What's the impact if we get it wrong?
   - Low: Easy to undo, minimal impact
   - Medium: Some rework needed, moderate impact
   - High: Hard to undo, significant impact

3. **Urgency**: How time-critical is this?
   - Low: Can take time to do it right
   - Normal: Standard timeframe
   - High/Critical: Immediate action needed

4. **Novelty**: How familiar is this task?
   - Familiar: Done similar tasks before
   - Somewhat_novel: Some new aspects
   - Novel: Completely new situation

Return JSON:
{
    \"complexity\": \"low|medium|high\",
    \"risk\": \"low|medium|high\",
    \"urgency\": \"low|normal|high|critical\",
    \"novelty\": \"familiar|somewhat_novel|novel\",
    \"recommended_mode\": \"reflexive|deliberate|reactive\",
    \"reasoning\": \"Why this mode is appropriate\"
}"
}
EOF
}

case "${1:-help}" in
    modes)
        get_reasoning_modes
        ;;
    select)
        select_mode "${2:-task}" "${3:-context}" "${4:-normal}" "${5:-medium}" "${6:-medium}"
        ;;
    analyze)
        analyze_task_characteristics "${2:-task}"
        ;;
    help|*)
        echo "Dynamic Reasoning Mode Switcher"
        echo "Usage: $0 <command> [args]"
        echo "  modes                     - List all reasoning modes"
        echo "  select <task> <context> [urgency] [complexity] [risk]"
        echo "  analyze <task>            - Analyze task characteristics"
        ;;
esac
