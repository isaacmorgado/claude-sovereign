#!/bin/bash
# Feedback Loop - Collect and Learn from Execution Outcomes
# Records task execution outcomes and provides feedback for improvement
# Usage: feedback-loop.sh record | analyze | patterns

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/feedback-loop.log"
STATE_FILE="${HOME}/.claude/feedback-loop-state.json"

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
    "feedback": [],
    "patterns": {},
    "metrics": {
        "total_feedback": 0,
        "successful_outcomes": 0,
        "failed_outcomes": 0,
        "average_duration": 0
    }
}
EOF
    fi
}

# Record execution feedback
record() {
    local task="$1"
    local task_type="${2:-general}"
    local strategy="${3:-default}"
    local outcome="${4:-unknown}"
    local duration="${5:-0}"
    local errors="${6:-}"
    local context="${7:-}"

    init_state
    log "Recording feedback: $task (outcome: $outcome, duration: ${duration}s)"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local feedback
    feedback=$(jq -n \
        --arg task "$task" \
        --arg task_type "$task_type" \
        --arg strategy "$strategy" \
        --arg outcome "$outcome" \
        --argjson duration "$duration" \
        --arg errors "$errors" \
        --arg context "$context" \
        --arg timestamp "$timestamp" \
        '{
            task: $task,
            task_type: $task_type,
            strategy: $strategy,
            outcome: $outcome,
            duration: $duration,
            errors: $errors,
            context: $context,
            timestamp: $timestamp,
            success: ($outcome | test("success|complete|done"; "i"))
        }')

    jq ".feedback += [$feedback]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    # Update metrics
    jq ".metrics.total_feedback += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    if [[ "$outcome" =~ (success|complete|done) ]]; then
        jq ".metrics.successful_outcomes += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"
    else
        jq ".metrics.failed_outcomes += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi

    log "Feedback recorded successfully"

    # Output result
    jq -n \
        --arg task "$task" \
        --arg outcome "$outcome" \
        --argjson duration "$duration" \
        --arg timestamp "$timestamp" \
        '{
            task: $task,
            outcome: $outcome,
            duration: $duration,
            timestamp: $timestamp,
            message: "Feedback recorded"
        }'
}

# Analyze feedback patterns
analyze() {
    local task_type="${1:-}"

    init_state
    log "Analyzing feedback patterns (task_type: $task_type)"

    # Get feedback for task type
    local feedback_data
    if [[ -n "$task_type" ]]; then
        feedback_data=$(jq ".feedback | map(select(.task_type == \"$task_type\"))" "$STATE_FILE")
    else
        feedback_data=$(jq ".feedback" "$STATE_FILE")
    fi

    local count
    count=$(echo "$feedback_data" | jq 'length')

    if [[ $count -eq 0 ]]; then
        jq -n \
            --arg task_type "$task_type" \
            '{
                task_type: $task_type,
                count: 0,
                message: "No feedback data available"
            }'
        return
    fi

    # Calculate statistics
    local success_rate
    success_rate=$(echo "$feedback_data" | jq '[.[] | select(.success)] | length / length * 100')

    local avg_duration
    avg_duration=$(echo "$feedback_data" | jq '[.[] | .duration] | add / length')

    # Get most successful strategy
    local best_strategy
    best_strategy=$(echo "$feedback_data" | jq -r '[.[] | select(.success)] | group_by(.strategy) | map({strategy: .[0].strategy, count: length}) | max_by(.count) | .strategy // "default"')

    # Get common errors
    local common_errors
    common_errors=$(echo "$feedback_data" | jq '[.[] | select(.errors != "") | .errors] | group_by(.) | map({error: .[0], count: length}) | sort_by(-.count) | .[0:5]')

    log "Analysis complete: $count feedback entries, $success_rate% success rate"

    # Output result
    jq -n \
        --arg task_type "$task_type" \
        --argjson count "$count" \
        --argjson success_rate "$success_rate" \
        --argjson avg_duration "$avg_duration" \
        --arg best_strategy "$best_strategy" \
        --argjson common_errors "$common_errors" \
        '{
            task_type: $task_type,
            count: $count,
            success_rate: ($success_rate * 100 | round / 100),
            average_duration: $avg_duration,
            best_strategy: $best_strategy,
            common_errors: $common_errors,
            recommendation: (if $success_rate > 80 then "Current approach is working well"
                          elif $success_rate > 50 then "Consider alternative strategies"
                          else "Major improvements needed" end)
        }'
}

# Get patterns
patterns() {
    init_state

    jq '.patterns' "$STATE_FILE"
}

# Get feedback history
history() {
    local limit="${1:-10}"

    init_state

    jq ".feedback[-$limit:]" "$STATE_FILE"
}

# Get metrics
metrics() {
    init_state

    jq '.metrics' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Feedback loop state initialized"
        ;;
    record)
        record "${2:-task}" "${3:-general}" "${4:-default}" "${5:-unknown}" "${6:-0}" "${7:-}" "${8:-}"
        ;;
    analyze)
        analyze "${2:-}"
        ;;
    patterns)
        patterns
        ;;
    history)
        history "${2:-10}"
        ;;
    metrics)
        metrics
        ;;
    help|*)
        cat <<EOF
Feedback Loop - Collect and Learn from Execution Outcomes

Usage:
  $0 record <task> <task_type> <strategy> <outcome> <duration> [errors] [context]
      Record execution feedback
  $0 analyze [task_type]              Analyze feedback patterns
  $0 patterns                           Get learned patterns
  $0 history [limit]                    Get feedback history
  $0 metrics                            Get feedback metrics

Outcome Types:
  success    - Task completed successfully
  failed     - Task failed
  partial    - Task partially completed
  unknown    - Outcome unknown

Examples:
  $0 record "implement auth" "implementation" "incremental" "success" 120
  $0 analyze "implementation"
  $0 history 20
  $0 metrics
EOF
        ;;
esac
