#!/bin/bash
# Learning Engine - Pattern Mining and Strategy Selection
# Mines patterns from past executions and selects best strategies
# Usage: learning-engine.sh learn <task_type> <context> <outcome>
#        learning-engine.h recommend <task> <context> [options_json]

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/learning-engine.log"
STATE_FILE="${HOME}/.claude/learning-engine-state.json"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize learning engine state
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "patterns": [],
    "strategies": {},
    "statistics": {
        "total_learnings": 0,
        "successful_applications": 0,
        "average_confidence": 0.0
    }
}
EOF
    fi
}

# Learn from an execution outcome
learn() {
    local task_type="$1"
    local context="${2:-}"
    local outcome="${3:-success}"
    local success_rate="${4:-1.0}"

    init_state
    log "Learning from: task_type=$task_type, outcome=$outcome, success_rate=$success_rate"

    # Create pattern key
    local pattern_key="${task_type}_${outcome}"

    local temp_file
    temp_file=$(mktemp)

    jq --arg key "$pattern_key" \
       --arg context "$context" \
       --argjson success_rate "$success_rate" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       .patterns[$key] = {
           context: $context,
           success_rate: $success_rate,
           last_seen: $ts,
           application_count: (.patterns[$key].application_count // 0) + 1
       } |
       .statistics.total_learnings += 1 |
       (if $outcome == "success" then .statistics.successful_applications += 1 end) |
       .average_confidence = ((.statistics.average_confidence * (.statistics.total_learnings - 1) + $success_rate) / .statistics.total_learnings)
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Pattern learned: $pattern_key"

    echo '{"status": "learned", "pattern_key": "'"$pattern_key"'"}'
}

# Recommend best strategy based on learned patterns
recommend() {
    local task="$1"
    local context="${2:-}"
    local options_json="${3:-[]}"

    init_state
    log "Recommending strategy for: $task"

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

        # Check for matching patterns
        while IFS= read -r pattern_entry; do
            local pattern_context
            local pattern_success_rate
            local pattern_application_count

            pattern_key=$(echo "$pattern_entry" | jq -r 'keys | .[0]')
            pattern_context=$(echo "$pattern_entry" | jq -r ".[$pattern_key].context // \"\"")
            pattern_success_rate=$(echo "$pattern_entry" | jq -r ".[$pattern_key].success_rate // 1.0")
            pattern_application_count=$(echo "$pattern_entry" | jq -r ".[$pattern_key].application_count // 0")

            # Match context
            if [[ -n "$pattern_context" ]] && [[ "$option_text" =~ "$pattern_context" ]]; then
                # Higher weight for more applications
                local application_weight
                application_weight=$(echo "scale=2; 1 + ($pattern_application_count / 10)" | bc -l 2>/dev/null || echo "1.5")

                local combined_score
                combined_score=$(echo "scale=2; ($pattern_success_rate * 0.7) + ($application_weight * 0.3)" | bc -l 2>/dev/null || echo "0.7")

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
        --arg task "$task" \
        --arg context "$context" \
        --argjson best "$best_recommendation" \
        --argjson all "$recommendations" \
        '{
            task: $task,
            context: $context,
            recommended_strategy: $best,
            confidence: ($best.score * 100),
            all_strategies: $all
        }'
}

# Get learned patterns
patterns() {
    init_state

    jq '.patterns' "$STATE_FILE"
}

# Get strategies
strategies() {
    init_state

    jq '.strategies' "$STATE_FILE"
}

# Get statistics
statistics() {
    init_state

    jq '.statistics' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Learning engine state initialized"
        ;;
    learn)
        learn "${2:-task}" "${3:-}" "${4:-success}" "${5:-1.0}"
        ;;
    recommend)
        recommend "${2:-}" "${3:-}" "${4:-[]}"
        ;;
    patterns)
        patterns
        ;;
    strategies)
        strategies
        ;;
    statistics)
        statistics
        ;;
    help|*)
        cat <<EOF
Learning Engine - Pattern Mining and Strategy Selection

Usage:
  $0 init                              Initialize learning engine state
  $0 learn <task_type> [context] [outcome] [success_rate]
      Learn from execution outcome
  $0 recommend <task> [context] [options_json]
      Recommend best strategy based on patterns
  $0 patterns                           Get learned patterns
  $0 strategies                         Get strategy definitions
  $0 statistics                         Get learning statistics

Learning Metrics:
  - Pattern application count
  - Success rate tracking
  - Confidence scoring
  - Strategy effectiveness

Examples:
  $0 learn "implementation" "using OAuth2" "success" "0.9"
  $0 recommend "database query" "cache context" '[{"text": "use cache"}, {"text": "use index"}]'
  $0 statistics
EOF
        ;;
esac
