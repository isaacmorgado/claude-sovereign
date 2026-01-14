#!/bin/bash
# Meta-Reflection - Reflect on Learning and Decision Making
# Meta-cognitive reflection on what was learned and how decisions were made
# Usage: meta-reflection.sh reflect | analyze | improve

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/meta-reflection.log"
STATE_FILE="${HOME}/.claude/meta-reflection-state.json"

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
    "reflections": [],
    "learning_insights": [],
    "decision_patterns": {},
    "meta_knowledge": {
        "effective_strategies": [],
        "common_mistakes": [],
        "improvement_areas": []
    }
}
EOF
    fi
}

# Create a reflection
reflect() {
    local what_learned="${1:-}"
    local task="${2:-}"
    local outcome="${3:-}"
    local context="${4:-}"

    init_state
    log "Creating meta-reflection: $what_learned (task: $task, outcome: $outcome)"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Extract insights from what was learned
    local insights=()

    if [[ -n "$what_learned" ]]; then
        insights+=("Learned: $what_learned")
    fi

    if [[ -n "$task" ]]; then
        insights+=("Task: $task")
    fi

    if [[ -n "$outcome" ]]; then
        insights+=("Outcome: $outcome")
    fi

    if [[ -n "$context" ]]; then
        insights+=("Context: $context")
    fi

    # Create reflection
    local reflection
    reflection=$(jq -n \
        --arg what_learned "$what_learned" \
        --arg task "$task" \
        --arg outcome "$outcome" \
        --arg context "$context" \
        --arg timestamp "$timestamp" \
        --argjson insights "$(printf '%s\n' "${insights[@]}" | jq -R '.' | jq -s '.')" \
        '{
            what_learned: $what_learned,
            task: $task,
            outcome: $outcome,
            context: $context,
            insights: $insights,
            timestamp: $timestamp
        }')

    jq ".reflections += [$reflection]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Meta-reflection created"

    # Output result
    jq -n \
        --arg what_learned "$what_learned" \
        --arg task "$task" \
        --arg outcome "$outcome" \
        --arg timestamp "$timestamp" \
        '{
            what_learned: $what_learned,
            task: $task,
            outcome: $outcome,
            timestamp: $timestamp,
            message: "Meta-reflection recorded"
        }'
}

# Analyze reflection patterns
analyze() {
    init_state
    log "Analyzing reflection patterns"

    # Get recent reflections
    local reflections
    reflections=$(jq '.reflections[-20:]' "$STATE_FILE")

    local count
    count=$(echo "$reflections" | jq 'length')

    if [[ $count -eq 0 ]]; then
        jq -n \
            '{
                count: 0,
                message: "No reflections to analyze"
            }'
        return
    fi

    # Extract learning insights
    local learning_insights=()
    local successful_outcomes=()
    local failed_outcomes=()

    while IFS= read -r reflection; do
        local outcome
        outcome=$(echo "$reflection" | jq -r '.outcome // ""')

        if [[ "$outcome" =~ (success|complete|done) ]]; then
            successful_outcomes+=("$reflection")
        elif [[ "$outcome" =~ (fail|error|abort) ]]; then
            failed_outcomes+=("$reflection")
        fi
    done < <(echo "$reflections" | jq -c '.[]')

    # Analyze patterns
    local success_rate
    success_rate=$(echo "scale=2; ${#successful_outcomes[@]} / $count * 100" | bc)

    local common_themes
    common_themes=$(echo "$reflections" | jq -r '[.[].what_learned] | group_by(.) | map({theme: .[0], count: length}) | sort_by(-.count) | .[0:5]')

    log "Analysis complete: $count reflections, $success_rate% success rate"

    # Output result
    jq -n \
        --argjson count "$count" \
        --argjson success_rate "$success_rate" \
        --argjson successful "${#successful_outcomes[@]}" \
        --argjson failed "${#failed_outcomes[@]}" \
        --argjson themes "$common_themes" \
        '{
            reflection_count: $count,
            success_rate: ($success_rate / 100),
            successful_outcomes: $successful,
            failed_outcomes: $failed,
            common_themes: $themes,
            recommendation: (if $success_rate > 80 then "Learning patterns are effective"
                          elif $success_rate > 50 then "Some improvement needed"
                          else "Major review of learning process needed" end)
        }'
}

# Get improvement suggestions
improve() {
    init_state
    log "Generating improvement suggestions"

    # Get reflections
    local reflections
    reflections=$(jq '.reflections' "$STATE_FILE")

    local suggestions=()

    # Suggestion 1: Analyze failed outcomes
    local failed_count
    failed_count=$(echo "$reflections" | jq '[.[] | select(.outcome | test("fail|error"; "i"))] | length')

    if [[ $failed_count -gt 0 ]]; then
        suggestions+=('{
            "type": "analyze_failures",
            "priority": "high",
            "suggestion": "Review '"$failed_count"' failed outcomes to identify patterns",
            "action": "Extract common failure themes and create prevention strategies"
        }')
    fi

    # Suggestion 2: Check learning consistency
    local learning_count
    learning_count=$(echo "$reflections" | jq '[.[] | select(.what_learned != "") | .what_learned] | unique | length')

    if [[ $learning_count -lt 5 ]]; then
        suggestions+=('{
            "type": "diversify_learning",
            "priority": "medium",
            "suggestion": "Increase learning diversity (currently '"$learning_count"' unique insights)",
            "action": "Explore different task types and strategies"
        }')
    fi

    # Suggestion 3: Review decision patterns
    local reflection_count
    reflection_count=$(echo "$reflections" | jq 'length')

    if [[ $reflection_count -lt 10 ]]; then
        suggestions+=('{
            "type": "increase_reflections",
            "priority": "low",
            "suggestion": "Increase reflection frequency (currently '"$reflection_count"' reflections)",
            "action": "Reflect after each task to build meta-knowledge"
        }')
    fi

    # Convert to JSON
    local suggestions_json
    suggestions_json=$(printf '%s\n' "${suggestions[@]}" | jq -s '.')

    log "Generated ${#suggestions[@]} improvement suggestions"

    # Output result
    jq -n \
        --argjson suggestions "$suggestions_json" \
        --argjson count "${#suggestions[@]}" \
        '{
            suggestions: $suggestions,
            count: $count,
            message: "Generated " + ($count | tostring) + " improvement suggestions"
        }'
}

# Get reflection history
history() {
    local limit="${1:-10}"

    init_state

    jq ".reflections[-$limit:]" "$STATE_FILE"
}

# Get meta-knowledge
knowledge() {
    init_state

    jq '.meta_knowledge' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Meta-reflection state initialized"
        ;;
    reflect)
        reflect "${2:-}" "${3:-}" "${4:-}" "${5:-}"
        ;;
    analyze)
        analyze
        ;;
    improve)
        improve
        ;;
    history)
        history "${2:-10}"
        ;;
    knowledge)
        knowledge
        ;;
    help|*)
        cat <<EOF
Meta-Reflection - Reflect on Learning and Decision Making

Usage:
  $0 reflect <what_learned> [task] [outcome] [context]  Create reflection
  $0 analyze                                           Analyze reflection patterns
  $0 improve                                           Get improvement suggestions
  $0 history [limit]                                    Get reflection history
  $0 knowledge                                          Get meta-knowledge

Reflection Types:
  what_learned     - Key insight or lesson learned
  task             - Task that was performed
  outcome           - Result of the task
  context           - Additional context or conditions

Examples:
  $0 reflect "Incremental testing reduces bugs" "implement feature" "success"
  $0 analyze
  $0 improve
  $0 history 20
  $0 knowledge
EOF
        ;;
esac
