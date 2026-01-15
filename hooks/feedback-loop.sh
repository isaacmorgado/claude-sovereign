#!/bin/bash
# Feedback Loop - Captures outcomes and feeds back to learning
# Continuously improves system by learning from every operation

set -uo pipefail

FEEDBACK_DIR="${HOME}/.claude/feedback"
OUTCOMES_FILE="$FEEDBACK_DIR/outcomes.jsonl"
AGGREGATED_FILE="$FEEDBACK_DIR/aggregated.json"
LOG_FILE="${HOME}/.claude/feedback-loop.log"

# Integration with other hooks
LEARNING_ENGINE="${HOME}/.claude/hooks/learning-engine.sh"
MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_feedback() {
    mkdir -p "$FEEDBACK_DIR"
    [[ -f "$OUTCOMES_FILE" ]] || touch "$OUTCOMES_FILE"

    if [[ ! -f "$AGGREGATED_FILE" ]]; then
        echo '{"total":0,"successes":0,"failures":0,"improvements":[]}' > "$AGGREGATED_FILE"
    fi
}

# =============================================================================
# OUTCOME CAPTURE
# =============================================================================

# Record an outcome (success or failure)
record_outcome() {
    local operation="$1"
    local task_type="$2"
    local strategy="$3"
    local result="$4"  # success or failure
    local duration="${5:-0}"
    local error_class="${6:-}"
    local context="${7:-}"

    init_feedback

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local outcome_id
    outcome_id="outcome_$(date +%s%N | cut -c1-13)"

    # Create outcome record
    local outcome
    outcome=$(jq -n \
        --arg id "$outcome_id" \
        --arg op "$operation" \
        --arg type "$task_type" \
        --arg strategy "$strategy" \
        --arg result "$result" \
        --argjson duration "$duration" \
        --arg error "$error_class" \
        --arg ctx "$context" \
        --arg ts "$timestamp" \
        '{
            id: $id,
            operation: $op,
            taskType: $type,
            strategy: $strategy,
            result: $result,
            duration: $duration,
            errorClass: $error,
            context: $ctx,
            timestamp: $ts
        }')

    # Append to outcomes log (JSONL format)
    echo "$outcome" >> "$OUTCOMES_FILE"

    log "Recorded $result outcome: $operation ($task_type/$strategy)"

    # Trigger learning
    feed_to_learning "$outcome"

    # Update aggregated statistics
    update_aggregated "$result"

    echo "$outcome_id"
}

# =============================================================================
# LEARNING INTEGRATION
# =============================================================================

# Feed outcome to learning engine
feed_to_learning() {
    local outcome="$1"

    if [[ ! -x "$LEARNING_ENGINE" ]]; then
        return
    fi

    local task_type
    task_type=$(echo "$outcome" | jq -r '.taskType')
    local strategy
    strategy=$(echo "$outcome" | jq -r '.strategy')
    local result
    result=$(echo "$outcome" | jq -r '.result')
    local duration
    duration=$(echo "$outcome" | jq -r '.duration')
    local error_class
    error_class=$(echo "$outcome" | jq -r '.errorClass // empty')
    local context
    context=$(echo "$outcome" | jq -r '.context // empty')

    if [[ "$result" == "success" ]]; then
        "$LEARNING_ENGINE" learn-success "$task_type" "$strategy" "$duration" "$context" 2>/dev/null || true
        log "Fed success to learning engine"
    else
        "$LEARNING_ENGINE" learn-failure "$task_type" "$strategy" "$error_class" "$context" 2>/dev/null || true
        log "Fed failure to learning engine"
    fi
}

# Feed outcome to memory as episodic memory
feed_to_memory() {
    local outcome="$1"

    if [[ ! -x "$MEMORY_MANAGER" ]]; then
        return
    fi

    local operation
    operation=$(echo "$outcome" | jq -r '.operation')
    local task_type
    task_type=$(echo "$outcome" | jq -r '.taskType')
    local result
    result=$(echo "$outcome" | jq -r '.result')
    local context
    context=$(echo "$outcome" | jq -r '.context // empty')

    local description="$operation ($task_type): $result"

    "$MEMORY_MANAGER" record "$task_type" "$description" "$result" "$context" 2>/dev/null || true
    log "Fed outcome to memory"
}

# =============================================================================
# AGGREGATION & ANALYSIS
# =============================================================================

# Update aggregated statistics
update_aggregated() {
    local result="$1"

    init_feedback

    local temp_file
    temp_file=$(mktemp)

    jq --arg result "$result" '
        .total += 1 |
        if $result == "success" then
            .successes += 1
        else
            .failures += 1
        end |
        .successRate = (
            if .total > 0 then
                (.successes / .total * 100) | floor
            else
                0
            end
        )
    ' "$AGGREGATED_FILE" > "$temp_file"

    mv "$temp_file" "$AGGREGATED_FILE"
}

# Analyze recent outcomes for patterns
analyze_recent() {
    local limit="${1:-100}"

    init_feedback

    # Check if file has content
    if [[ ! -s "$OUTCOMES_FILE" ]]; then
        echo '{"total":0,"successes":0,"failures":0,"successRate":0,"avgDuration":0,"topErrors":[],"topStrategies":[]}'
        return
    fi

    # Get last N outcomes
    local recent
    recent=$(tail -n "$limit" "$OUTCOMES_FILE" | jq -s '.' 2>/dev/null || echo '[]')

    # If empty or invalid, return empty stats
    if [[ "$recent" == "[]" || -z "$recent" ]]; then
        echo '{"total":0,"successes":0,"failures":0,"successRate":0,"avgDuration":0,"topErrors":[],"topStrategies":[]}'
        return
    fi

    # Calculate statistics
    local stats
    stats=$(echo "$recent" | jq '{
        total: length,
        successes: [.[] | select(.result == "success")] | length,
        failures: [.[] | select(.result == "failure")] | length,
        successRate: (
            if length > 0 then
                ([.[] | select(.result == "success")] | length) / length * 100 | floor
            else
                0
            end
        ),
        avgDuration: (
            if length > 0 and ([.[] | .duration] | length) > 0 then
                [.[] | .duration] | add / length | floor
            else
                0
            end
        ),
        topErrors: (
            [.[] | select(.result == "failure") | .errorClass] |
            group_by(.) |
            map({error: .[0], count: length}) |
            sort_by(-.count) |
            .[:5]
        ),
        topStrategies: (
            [.[] | .strategy] |
            group_by(.) |
            map({strategy: .[0], count: length}) |
            sort_by(-.count) |
            .[:5]
        )
    }' 2>/dev/null || echo '{"total":0,"successes":0,"failures":0,"successRate":0,"avgDuration":0,"topErrors":[],"topStrategies":[]}')

    echo "$stats"
}

# Identify improvements needed
identify_improvements() {
    init_feedback

    local recent_stats
    recent_stats=$(analyze_recent 50)

    local improvements=()

    # Check success rate
    local success_rate
    success_rate=$(echo "$recent_stats" | jq -r '.successRate')
    if [[ $success_rate -lt 70 ]]; then
        improvements+=("{\"type\":\"low_success_rate\",\"value\":$success_rate,\"recommendation\":\"Review failed strategies and error patterns\"}")
    fi

    # Check for repeated errors
    local top_error_count
    top_error_count=$(echo "$recent_stats" | jq -r '.topErrors[0].count // 0')
    if [[ $top_error_count -gt 5 ]]; then
        local top_error
        top_error=$(echo "$recent_stats" | jq -r '.topErrors[0].error')
        improvements+=("{\"type\":\"repeated_error\",\"error\":\"$top_error\",\"count\":$top_error_count,\"recommendation\":\"Add specific handling for $top_error\"}")
    fi

    # Check average duration trend
    local avg_duration
    avg_duration=$(echo "$recent_stats" | jq -r '.avgDuration')
    if [[ $avg_duration -gt 30000 ]]; then
        improvements+=("{\"type\":\"slow_execution\",\"avgDuration\":$avg_duration,\"recommendation\":\"Optimize commonly used operations\"}")
    fi

    # Output improvements
    if [[ ${#improvements[@]} -gt 0 ]]; then
        printf '%s\n' "${improvements[@]}" | jq -s '.'
    else
        echo '[]'
    fi
}

# =============================================================================
# CONTINUOUS IMPROVEMENT
# =============================================================================

# Suggest strategy changes based on feedback
suggest_strategy_changes() {
    local task_type="$1"

    init_feedback

    # Get outcomes for this task type
    local task_outcomes
    task_outcomes=$(grep "\"taskType\":\"$task_type\"" "$OUTCOMES_FILE" | jq -s '.')

    # Find best and worst strategies
    local strategy_analysis
    strategy_analysis=$(echo "$task_outcomes" | jq '
        group_by(.strategy) |
        map({
            strategy: .[0].strategy,
            total: length,
            successes: [.[] | select(.result == "success")] | length,
            failures: [.[] | select(.result == "failure")] | length,
            successRate: (
                ([.[] | select(.result == "success")] | length) / length * 100 | floor
            ),
            avgDuration: (
                [.[] | select(.result == "success") | .duration] |
                if length > 0 then (add / length | floor) else 0 end
            )
        }) |
        sort_by(-.successRate)
    ')

    echo "$strategy_analysis"
}

# Auto-correct strategies that consistently fail
auto_correct() {
    init_feedback

    local corrections=0

    # Get task types with low success rates
    local problem_tasks
    problem_tasks=$(grep "\"result\":\"failure\"" "$OUTCOMES_FILE" | tail -100 | jq -s '
        group_by(.taskType) |
        map({
            taskType: .[0].taskType,
            failures: length
        }) |
        sort_by(-.failures) |
        .[:5]
    ')

    # For each problem task, find alternative strategies
    echo "$problem_tasks" | jq -r '.[].taskType' | while read -r task_type; do
        local suggestions
        suggestions=$(suggest_strategy_changes "$task_type")

        local best_strategy
        best_strategy=$(echo "$suggestions" | jq -r '.[0].strategy // empty')

        if [[ -n "$best_strategy" && "$best_strategy" != "null" ]]; then
            log "Auto-correction: Recommend $best_strategy for $task_type"
            corrections=$((corrections + 1))

            # Update learning engine
            if [[ -x "$LEARNING_ENGINE" ]]; then
                # This is informational - learning engine will pick it up from future successes
                log "Learning engine will adapt based on feedback"
            fi
        fi
    done

    echo "{\"corrections\":$corrections}"
}

# =============================================================================
# REPORTING
# =============================================================================

# Generate feedback report
generate_report() {
    local period="${1:-7}"  # days

    init_feedback

    local since_date
    since_date=$(date -u -v-${period}d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u --date="$period days ago" +%Y-%m-%dT%H:%M:%SZ)

    # Get outcomes since date
    local period_outcomes
    period_outcomes=$(jq -s --arg since "$since_date" '
        [.[] | select(.timestamp >= $since)]
    ' "$OUTCOMES_FILE")

    # Generate report
    echo "$period_outcomes" | jq --arg period "$period" '{
        period: ($period + " days"),
        summary: {
            total: length,
            successes: [.[] | select(.result == "success")] | length,
            failures: [.[] | select(.result == "failure")] | length,
            successRate: (
                if length > 0 then
                    ([.[] | select(.result == "success")] | length) / length * 100 | floor
                else
                    0
                end
            )
        },
        byTaskType: (
            group_by(.taskType) |
            map({
                taskType: .[0].taskType,
                total: length,
                successes: [.[] | select(.result == "success")] | length,
                successRate: (
                    ([.[] | select(.result == "success")] | length) / length * 100 | floor
                )
            }) |
            sort_by(-.total)
        ),
        topErrors: (
            [.[] | select(.result == "failure") | .errorClass] |
            group_by(.) |
            map({error: .[0], count: length}) |
            sort_by(-.count) |
            .[:10]
        ),
        improvements: (
            [.[] | select(.result == "success")] |
            [.[].duration] |
            if length > 0 then {
                avgDuration: (add / length | floor),
                trend: "improving"
            } else {} end
        )
    }'
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    record)
        record_outcome "${2:-operation}" "${3:-general}" "${4:-default}" "${5:-success}" "${6:-0}" "${7:-}" "${8:-}"
        ;;
    analyze)
        analyze_recent "${2:-100}"
        ;;
    improvements)
        identify_improvements
        ;;
    suggest)
        suggest_strategy_changes "${2:-general}"
        ;;
    auto-correct)
        auto_correct
        ;;
    report)
        generate_report "${2:-7}"
        ;;
    statistics)
        cat "$AGGREGATED_FILE"
        ;;
    help|*)
        echo "Feedback Loop - Outcome Capture & Continuous Improvement"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Capture Commands:"
        echo "  record <op> <type> <strategy> <result> [dur] [error] [ctx]"
        echo "                                  - Record operation outcome"
        echo "    result: success or failure"
        echo ""
        echo "Analysis Commands:"
        echo "  analyze [limit]                 - Analyze recent outcomes"
        echo "  improvements                    - Identify needed improvements"
        echo "  suggest <task_type>             - Suggest strategy changes"
        echo "  auto-correct                    - Auto-correct failing strategies"
        echo ""
        echo "Reporting Commands:"
        echo "  report [days]                   - Generate feedback report"
        echo "  statistics                      - Get aggregated statistics"
        echo ""
        echo "Examples:"
        echo "  $0 record build_feature feature incremental success 5000"
        echo "  $0 analyze 50                   # Analyze last 50 outcomes"
        echo "  $0 suggest bugfix               # Get strategy suggestions"
        ;;
esac
