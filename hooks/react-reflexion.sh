#!/bin/bash
# ReAct + Reflexion - Think, Act, Observe, Reflect Loop
# Implements the core reasoning cycle for autonomous agents
# Usage: react-reflexion.sh think <goal> <context> <iteration>
#        react-reflexion.sh reflect <thought> <action> <observation> <success>

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/react-reflexion.log"
STATE_FILE="${HOME}/.claude/react-reflexion-state.json"

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
    "cycles": [],
    "current_iteration": 0,
    "quality_history": []
}
EOF
    fi
}

# Generate thought for next action
think() {
    local goal="$1"
    local context="${2:-}"
    local iteration="${3:-1}"

    init_state
    log "Generating thought for iteration $iteration: $goal"

    # Get recent cycles for context
    local recent_cycles
    recent_cycles=$(jq -r '.cycles | reverse | .[0:5]' "$STATE_FILE")

    # Build thought prompt
    local thought_prompt="Goal: $goal

Context:
$context

Recent Actions and Results:
$recent_cycles

Based on the above, think through:
1. What has been accomplished so far?
2. What remains to be done?
3. What is the best next action?
4. What are the potential risks?
5. What information do I need?

Provide your reasoning and proposed action."

    # Output thought for LLM to process
    jq -n \
        --arg goal "$goal" \
        --arg context "$context" \
        --argjson iteration "$iteration" \
        --arg prompt "$thought_prompt" \
        '{
            iteration: $iteration,
            goal: $goal,
            context: $context,
            thought_prompt: $prompt,
            type: "think"
        }'

    log "Thought prompt generated for iteration $iteration"
}

# Reflect on action outcome
reflect() {
    local thought="$1"
    local action="$2"
    local observation="$3"
    local success="${4:-false}"

    init_state
    log "Reflecting on: action=$action, success=$success"

    # Calculate quality score
    local quality_score=7.0

    if [[ "$success" == "true" ]]; then
        # Success factors
        quality_score=8.0
        [[ "$observation" =~ (success|completed|achieved|passed) ]] && quality_score=$((quality_score + 1))
        [[ ! "$observation" =~ (error|failed|issue|problem) ]] && quality_score=$((quality_score + 1))
    else
        # Failure factors
        quality_score=5.0
        [[ "$observation" =~ (error|failed|issue|problem) ]] && quality_score=$((quality_score - 1))
    fi

    # Normalize to 0-10
    if [[ $quality_score -gt 10 ]]; then
        quality_score=10
    elif [[ $quality_score -lt 0 ]]; then
        quality_score=0
    fi

    # Create reflection
    local reflection="Action '$action' based on thought '$thought' resulted in: $observation"

    # Store cycle
    local cycle_id="cycle_$(date +%s%N | cut -c1-13)"

    local temp_file
    temp_file=$(mktemp)

    jq --arg id "$cycle_id" \
       --arg thought "$thought" \
       --arg action "$action" \
       --arg observation "$observation" \
       --argjson success "$success" \
       --argjson score "$quality_score" \
       --arg reflection "$reflection" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       .cycles += [{
           id: $id,
           thought: $thought,
           action: $action,
           observation: $observation,
           success: $success,
           quality_score: $score,
           reflection: $reflection,
           timestamp: $ts
       }] |
       .current_iteration += 1 |
       .quality_history += [$score]
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Cycle recorded: $cycle_id (quality: $quality_score/10)"

    # Output reflection result
    jq -n \
        --arg id "$cycle_id" \
        --argjson score "$quality_score" \
        --arg reflection "$reflection" \
        '{
            cycle_id: $id,
            quality_score: $score,
            reflection: $reflection,
            should_revise: ($score < 7.0),
            recommendation: (if $score < 7.0 then "Revise approach" else "Continue with current strategy" end)
        }'
}

# Process reflection and learn from it
process() {
    local reflection_result="$1"
    local success="${2:-true}"

    init_state
    log "Processing reflection: success=$success"

    # Extract lessons learned
    local quality_score
    quality_score=$(echo "$reflection_result" | jq -r '.quality_score')

    local lessons="[]"

    if [[ "$success" == "true" ]] && [[ $quality_score -ge 8 ]]; then
        lessons='["Successful pattern identified", "Quality approach validated"]'
    elif [[ "$success" == "false" ]]; then
        lessons='["Failure analyzed", "Root cause identified", "Alternative approaches needed"]'
    elif [[ $quality_score -lt 7 ]]; then
        lessons='["Quality below threshold", "Improvement needed", "Consider different strategy"]'
    fi

    # Update state with lessons
    local temp_file
    temp_file=$(mktemp)

    jq --argjson lessons "$lessons" \
       '.lessons_learned = $lessons + (.lessons_learned // [])' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Lessons learned: $lessons"

    echo '{"status": "processed", "lessons": '"$lessons"'}'
}

# Get cycle history
history() {
    init_state

    local limit="${1:-10}"

    jq '.cycles | reverse | .[0:'"$limit"']' "$STATE_FILE"
}

# Get quality metrics
metrics() {
    init_state

    jq '{
        total_cycles: (.cycles | length),
        successful_cycles: (.cycles | map(select(.success == true)) | length),
        failed_cycles: (.cycles | map(select(.success == false)) | length),
        average_quality: (.quality_history | add / length),
        quality_trend: (.quality_history | .[-10:])
    }' "$STATE_FILE"
}

# Run complete cycle (think -> act -> observe -> reflect)
cycle() {
    local goal="$1"
    local context="${2:-}"
    local iteration="${3:-1}"

    log "Starting ReAct+Reflexion cycle $iteration for goal: $goal"

    # Step 1: Think
    local thought_output
    thought_output=$(think "$goal" "$context" "$iteration")

    # Step 2: Act (would be executed by caller)
    # This returns the thought prompt for the caller to act on
    jq -n \
        --arg goal "$goal" \
        --argjson iteration "$iteration" \
        --arg thought_prompt "$(echo "$thought_output" | jq -r '.thought_prompt')" \
        '{
            phase: "think",
            iteration: $iteration,
            goal: $goal,
            thought_prompt: $thought_prompt,
            next_step: "Execute action based on this thought"
        }'
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "ReAct+Reflexion state initialized"
        ;;
    think)
        think "${2:-goal}" "${3:-}" "${4:-1}"
        ;;
    reflect)
        reflect "${2:-thought}" "${3:-action}" "${4:-observation}" "${5:-false}"
        ;;
    process)
        process "${2:-reflection_result}" "${3:-true}"
        ;;
    cycle)
        cycle "${2:-goal}" "${3:-}" "${4:-1}"
        ;;
    history)
        history "${2:-10}"
        ;;
    metrics)
        metrics
        ;;
    help|*)
        cat <<EOF
ReAct + Reflexion - Think, Act, Observe, Reflect Loop

Usage:
  $0 init                              Initialize state
  $0 think <goal> [context] [iteration]  Generate thought for next action
  $0 reflect <thought> <action> <observation> [success]  Reflect on outcome
  $0 process <reflection_result> [success]     Process and learn from reflection
  $0 cycle <goal> [context] [iteration]   Run complete cycle
  $0 history [limit]                      Get cycle history
  $0 metrics                            Get quality metrics

The Loop:
  1. THINK    - Generate reasoning for next action
  2. ACT      - Execute the action
  3. OBSERVE  - Capture the outcome
  4. REFLECT  - Analyze what worked/didn't work

Quality Scoring:
  - 0-4: Poor, needs major revision
  - 5-6: Acceptable, some improvements needed
  - 7-8: Good, continue with current approach
  - 9-10: Excellent, pattern validated

Examples:
  $0 think "implement auth" "using OAuth2" 1
  $0 reflect "Write auth code" "git commit" "Success: code committed" true
  $0 metrics
  $0 history 5
EOF
        ;;
esac
