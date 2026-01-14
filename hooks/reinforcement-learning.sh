#!/bin/bash
# Reinforcement Learning - Learn from Outcomes
# Records and learns from task outcomes for better future decisions
# Usage: reinforcement-learning.sh record <task_type> <context> <outcome> <reward>
#        reinforcement-learning.sh recommend <context> <options_json>

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/reinforcement-learning.log"
STATE_FILE="${HOME}/.claude/reinforcement-learning-state.json"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize RL state
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "episodes": [],
    "patterns": [],
    "strategies": {},
    "statistics": {
        "total_episodes": 0,
        "successful_episodes": 0,
        "average_reward": 0.0
    }
}
EOF
    fi
}

# Record an episode (task execution)
record() {
    local task_type="$1"
    local context="${2:-}"
    local outcome="${3:-success}"
    local reward="${4:-0.0}"

    init_state
    log "Recording episode: task_type=$task_type, outcome=$outcome, reward=$reward"

    # Create episode
    local episode_id="ep_$(date +%s%N | cut -c1-13)"

    local temp_file
    temp_file=$(mktemp)

    jq --arg id "$episode_id" \
       --arg type "$task_type" \
       --arg context "$context" \
       --arg outcome "$outcome" \
       --argjson reward "$reward" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       .episodes += [{
           id: $id,
           task_type: $type,
           context: $context,
           outcome: $outcome,
           reward: $reward,
           timestamp: $ts
       }] |
       .statistics.total_episodes += 1 |
       (if $outcome == "success" then .statistics.successful_episodes += 1 end) |
       .statistics.average_reward = ((.statistics.average_reward * (.statistics.total_episodes - 1) + $reward) / .statistics.total_episodes)
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Episode recorded: $episode_id"

    # Update patterns based on outcome
    if [[ "$outcome" == "success" ]]; then
        update_patterns "$task_type" "$context" "success"
    else
        update_patterns "$task_type" "$context" "failure"
    fi

    echo '{"status": "recorded", "episode_id": "'"$episode_id"'"}'
}

# Update learned patterns
update_patterns() {
    local task_type="$1"
    local context="${2:-}"
    local outcome="${3:-success}"

    log "Updating patterns for: task_type=$task_type, outcome=$outcome"

    local pattern_key="${task_type}_${outcome}"

    local temp_file
    temp_file=$(mktemp)

    jq --arg key "$pattern_key" \
       --arg context "$context" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       .patterns[$key] = {
           context: $context,
           last_seen: $ts,
           outcome_count: (.patterns[$key].outcome_count // 0) + 1,
           success_rate: (if .patterns[$key].success_rate then .patterns[$key].success_rate else 0.5)
       }
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Pattern updated: $pattern_key"
}

# Recommend best strategy based on learned patterns
recommend() {
    local context="${1:-}"
    local options_json="${2:-[]}"

    init_state
    log "Recommending strategy for context: $context"

    # Get relevant patterns
    local patterns
    patterns=$(jq -r '.patterns' "$STATE_FILE")

    # Score each option based on historical success
    local recommendations="[]"

    while IFS= read -r option; do
        if [[ -z "$option" || "$option" == "null" ]]; then
            continue
        fi

        local option_text
        option_text=$(echo "$option" | jq -r '.text // .')

        # Calculate score based on patterns
        local score=0.5

        # Check for success patterns
        while IFS= read -r pattern_entry; do
            local pattern_key
            local pattern_context
            local outcome_count
            local success_rate

            pattern_key=$(echo "$pattern_entry" | jq -r 'keys | .[0]')
            pattern_context=$(echo "$pattern_entry" | jq -r ".[$pattern_key].context // \"\"")
            outcome_count=$(echo "$pattern_entry" | jq -r ".[$pattern_key].outcome_count // 0")
            success_rate=$(echo "$pattern_entry" | jq -r ".[$pattern_key].success_rate // 0.5")

            # Match context
            if [[ -n "$pattern_context" ]] && [[ "$option_text" =~ "$pattern_context" ]]; then
                # Higher weight for more occurrences
                local weight
                weight=$(echo "scale=2; 1 + ($outcome_count / 10)" | bc -l 2>/dev/null || echo "1.5")

                # Combine success rate and occurrence weight
                local combined_score
                combined_score=$(echo "scale=2; ($success_rate * 0.7) + ($weight * 0.3)" | bc -l 2>/dev/null || echo "0.6")

                if (( $(echo "$combined_score > $score" | bc -l 2>/dev/null || echo "0") )); then
                    score=$combined_score
                fi
            fi
        done < <(echo "$patterns" | jq -c '.[]')

        # Add to recommendations
        recommendations=$(echo "$recommendations" | jq --arg option "$option" --argjson score "$score" '. + [{option: $option, score: $score}]')
    done < <(echo "$options_json" | jq -c '.[]')

    # Sort by score and return top recommendation
    local best_recommendation
    best_recommendation=$(echo "$recommendations" | jq 'sort_by(.score) | reverse | .[0]')

    log "Best recommendation: $(echo "$best_recommendation" | jq -r '.option')"

    # Output recommendation
    jq -n \
        --arg context "$context" \
        --argjson best "$best_recommendation" \
        --argjson all "$recommendations" \
        '{
            context: $context,
            recommended_strategy: $best,
            confidence: ($best.score * 100),
            all_strategies: $all
        }'
}

# Get statistics
statistics() {
    init_state

    jq '.statistics' "$STATE_FILE"
}

# Get episode history
history() {
    init_state

    local limit="${1:-20}"

    jq '.episodes | reverse | .[0:'"$limit"']' "$STATE_FILE"
}

# Get learned patterns
patterns() {
    init_state

    jq '.patterns' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Reinforcement learning state initialized"
        ;;
    record)
        record "${2:-task}" "${3:-}" "${4:-success}" "${5:-0.0}"
        ;;
    recommend)
        recommend "${2:-}" "${3:-[]}"
        ;;
    statistics)
        statistics
        ;;
    history)
        history "${2:-20}"
        ;;
    patterns)
        patterns
        ;;
    help|*)
        cat <<EOF
Reinforcement Learning - Learn from Outcomes

Usage:
  $0 init                              Initialize RL state
  $0 record <task_type> [context] [outcome] [reward]
      Record task execution episode
  $0 recommend <context> [options_json]
      Recommend best strategy based on learned patterns
  $0 statistics                         Get learning statistics
  $0 history [limit]                    Get episode history
  $0 patterns                            Get learned patterns

Reward Values:
  - 0.0-0.3: Poor, significant issues
  - 0.4-0.6: Below average, needs improvement
  - 0.7-0.9: Good, acceptable quality
  - 1.0: Excellent, optimal outcome

Examples:
  $0 record "implementation" "using OAuth2" "success" "0.8"
  $0 recommend "database query" '[{"text": "use cache"}, {"text": "use index"}]'
  $0 statistics
  $0 history 10
EOF
        ;;
esac
