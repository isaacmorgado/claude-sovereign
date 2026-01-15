#!/bin/bash
# Learning Engine - Continuous learning from patterns and outcomes
# Implements: Reinforcement learning, pattern aggregation, predictive modeling
# Based on patterns from: agent-loop, memory-manager, error-handler

set -uo pipefail

LEARNING_DIR="${HOME}/.claude/learning"
MODELS_FILE="$LEARNING_DIR/models.json"
STATISTICS_FILE="$LEARNING_DIR/statistics.json"
PREDICTIONS_FILE="$LEARNING_DIR/predictions.json"
LOG_FILE="${HOME}/.claude/learning-engine.log"

# Memory integration
MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_learning() {
    mkdir -p "$LEARNING_DIR"

    if [[ ! -f "$MODELS_FILE" ]]; then
        cat > "$MODELS_FILE" << 'EOF'
{
    "strategies": {},
    "errorPatterns": {},
    "successPatterns": {},
    "taskTypes": {},
    "version": "1.0"
}
EOF
    fi

    if [[ ! -f "$STATISTICS_FILE" ]]; then
        cat > "$STATISTICS_FILE" << 'EOF'
{
    "totalTasks": 0,
    "successfulTasks": 0,
    "failedTasks": 0,
    "strategiesUsed": {},
    "errorTypes": {},
    "averageTime": {},
    "lastUpdated": null
}
EOF
    fi

    if [[ ! -f "$PREDICTIONS_FILE" ]]; then
        echo '{"predictions":[]}' > "$PREDICTIONS_FILE"
    fi

    log "Learning engine initialized"
}

# =============================================================================
# PATTERN LEARNING (from memory and execution history)
# =============================================================================

# Learn from successful execution
learn_success() {
    local task_type="$1"
    local strategy="$2"
    local duration="${3:-0}"
    local context="${4:-}"

    init_learning

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Update success patterns
    jq --arg type "$task_type" \
       --arg strategy "$strategy" \
       --argjson duration "$duration" \
       --arg ts "$timestamp" \
       --arg ctx "$context" \
       '
       .successPatterns[$type] = (.successPatterns[$type] // {
           "count": 0,
           "strategies": {},
           "avgDuration": 0,
           "totalDuration": 0
       }) |
       .successPatterns[$type].count += 1 |
       .successPatterns[$type].strategies[$strategy] = (
           (.successPatterns[$type].strategies[$strategy] // 0) + 1
       ) |
       .successPatterns[$type].totalDuration += $duration |
       .successPatterns[$type].avgDuration = (
           .successPatterns[$type].totalDuration / .successPatterns[$type].count
       ) |
       .successPatterns[$type].lastSuccess = $ts
       ' "$MODELS_FILE" > "$temp_file"

    mv "$temp_file" "$MODELS_FILE"

    # Update statistics
    update_statistics "success" "$task_type" "$strategy" "$duration"

    log "Learned success: $task_type using $strategy (${duration}ms)"
}

# Learn from failure
learn_failure() {
    local task_type="$1"
    local strategy="$2"
    local error_class="$3"
    local error_msg="${4:-}"

    init_learning

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Update error patterns
    jq --arg type "$task_type" \
       --arg strategy "$strategy" \
       --arg errorClass "$error_class" \
       --arg errorMsg "$error_msg" \
       --arg ts "$timestamp" \
       '
       .errorPatterns[$type] = (.errorPatterns[$type] // {
           "count": 0,
           "errors": {},
           "failedStrategies": {}
       }) |
       .errorPatterns[$type].count += 1 |
       .errorPatterns[$type].errors[$errorClass] = (
           (.errorPatterns[$type].errors[$errorClass] // 0) + 1
       ) |
       .errorPatterns[$type].failedStrategies[$strategy] = (
           (.errorPatterns[$type].failedStrategies[$strategy] // 0) + 1
       ) |
       .errorPatterns[$type].lastError = {
           "class": $errorClass,
           "message": $errorMsg,
           "timestamp": $ts
       }
       ' "$MODELS_FILE" > "$temp_file"

    mv "$temp_file" "$MODELS_FILE"

    # Update statistics
    update_statistics "failure" "$task_type" "$strategy" "0"

    log "Learned failure: $task_type using $strategy (error: $error_class)"
}

# Update overall statistics
update_statistics() {
    local outcome="$1"  # success or failure
    local task_type="$2"
    local strategy="$3"
    local duration="$4"

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg outcome "$outcome" \
       --arg type "$task_type" \
       --arg strategy "$strategy" \
       --argjson duration "$duration" \
       --arg ts "$timestamp" \
       '
       .totalTasks += 1 |
       if $outcome == "success" then
           .successfulTasks += 1
       else
           .failedTasks += 1
       end |
       .strategiesUsed[$strategy] = ((.strategiesUsed[$strategy] // 0) + 1) |
       .averageTime[$type] = (
           if .averageTime[$type] then
               ((.averageTime[$type].total + $duration) / (.averageTime[$type].count + 1))
           else
               $duration
           end
       ) |
       .lastUpdated = $ts
       ' "$STATISTICS_FILE" > "$temp_file"

    mv "$temp_file" "$STATISTICS_FILE"
}

# =============================================================================
# STRATEGY RECOMMENDATION (predictive)
# =============================================================================

# Recommend best strategy for task type
recommend_strategy() {
    local task_type="$1"
    local context="${2:-}"

    init_learning

    # Get success patterns for this task type
    local strategies
    strategies=$(jq -r --arg type "$task_type" '
        .successPatterns[$type].strategies // {} |
        to_entries |
        sort_by(-.value) |
        map({strategy: .key, count: .value}) |
        if length > 0 then
            .[0].strategy
        else
            "default"
        end
    ' "$MODELS_FILE")

    if [[ "$strategies" == "null" || "$strategies" == "default" ]]; then
        # No learned patterns, use memory
        if [[ -x "$MEMORY_MANAGER" ]]; then
            local memories
            memories=$("$MEMORY_MANAGER" find-patterns "$task_type" 3 2>/dev/null)
            if [[ -n "$memories" && "$memories" != "[]" ]]; then
                strategies=$(echo "$memories" | jq -r '.[0].solution // "default"')
            fi
        fi
    fi

    # Calculate confidence
    local confidence
    confidence=$(jq -r --arg type "$task_type" '
        .successPatterns[$type] as $pattern |
        .totalTasks as $total |
        if $pattern and $total and $total > 0 then
            ($pattern.count / $total * 100) | floor
        else
            0
        end
    ' "$STATISTICS_FILE" 2>/dev/null || echo "0")

    # Ensure confidence is a valid number
    [[ -z "$confidence" || "$confidence" == "null" ]] && confidence=0

    jq -n --arg strategy "$strategies" --argjson confidence "$confidence" \
        '{strategy: $strategy, confidence: $confidence}'
    log "Recommended strategy for $task_type: $strategies (confidence: $confidence%)"
}

# =============================================================================
# RISK ASSESSMENT (predictive)
# =============================================================================

# Predict failure risk for task/strategy combination
predict_risk() {
    local task_type="$1"
    local strategy="$2"

    init_learning

    # Calculate failure rate for this combination
    local risk_score
    risk_score=$(jq -r --arg type "$task_type" --arg strategy "$strategy" '
        .errorPatterns[$type] as $errors |
        .successPatterns[$type] as $success |
        if $errors and $success then
            # Calculate failure rate for this strategy
            ($errors.failedStrategies[$strategy] // 0) as $failures |
            ($success.strategies[$strategy] // 0) as $successes |
            ($failures + $successes) as $total |
            if $total > 0 then
                ($failures / $total * 100) | floor
            else
                10  # Default low risk for unknown
            end
        elif $errors then
            # Only failures known
            50
        else
            # No data
            10
        end
    ' "$MODELS_FILE")

    # Categorize risk
    local risk_level
    if [[ $risk_score -lt 20 ]]; then
        risk_level="low"
    elif [[ $risk_score -lt 50 ]]; then
        risk_level="medium"
    else
        risk_level="high"
    fi

    echo "{\"riskScore\":$risk_score,\"riskLevel\":\"$risk_level\"}"
    log "Risk prediction for $task_type/$strategy: $risk_level ($risk_score%)"
}

# =============================================================================
# PATTERN MINING (from memory)
# =============================================================================

# Mine memory for successful patterns
mine_patterns() {
    local task_query="$1"
    local limit="${2:-5}"

    if [[ ! -x "$MEMORY_MANAGER" ]]; then
        echo "[]"
        return
    fi

    # Query episodic memory for successful similar tasks
    local similar_tasks
    similar_tasks=$("$MEMORY_MANAGER" remember-scored "$task_query" "$limit" 2>/dev/null || echo "[]")

    # Extract patterns from successful tasks
    local patterns
    patterns=$(echo "$similar_tasks" | jq -c '
        [.[] | select(.type == "episode" and .metadata.outcome == "success")] |
        map({
            description: .content,
            approach: .metadata.action_type,
            context: .metadata.details,
            timestamp: .timestamp
        })
    ')

    log "Mined $(echo "$patterns" | jq 'length') patterns for: $task_query"
    echo "$patterns"
}

# =============================================================================
# QUALITY SCORING (adaptive)
# =============================================================================

# Calculate quality score for a completed task
calculate_quality() {
    local task_type="$1"
    local duration="$2"
    local errors_encountered="$3"
    local retries="$4"

    init_learning

    # Get average duration for this task type
    local avg_duration
    avg_duration=$(jq -r --arg type "$task_type" '
        .averageTime[$type] // 10000
    ' "$STATISTICS_FILE")

    # Score components (0-100 each)
    local speed_score
    if [[ $duration -le $avg_duration ]]; then
        speed_score=100
    else
        speed_score=$(( 100 - (duration - avg_duration) * 100 / avg_duration ))
        [[ $speed_score -lt 0 ]] && speed_score=0
    fi

    local error_score
    error_score=$(( 100 - errors_encountered * 20 ))
    [[ $error_score -lt 0 ]] && error_score=0

    local retry_score
    retry_score=$(( 100 - retries * 15 ))
    [[ $retry_score -lt 0 ]] && retry_score=0

    # Weighted average
    local quality_score
    quality_score=$(( (speed_score * 30 + error_score * 40 + retry_score * 30) / 100 ))

    echo "{\"qualityScore\":$quality_score,\"speedScore\":$speed_score,\"errorScore\":$error_score,\"retryScore\":$retry_score}"
    log "Quality score for $task_type: $quality_score/100"
}

# =============================================================================
# LEARNING ANALYTICS
# =============================================================================

# Get learning statistics
get_statistics() {
    init_learning

    local stats
    stats=$(jq '.' "$STATISTICS_FILE")

    # Add success rate
    stats=$(echo "$stats" | jq '
        .successRate = (
            if .totalTasks > 0 then
                (.successfulTasks / .totalTasks * 100) | floor
            else
                0
            end
        )
    ')

    echo "$stats"
}

# Get best performing strategies
get_best_strategies() {
    local limit="${1:-10}"

    init_learning

    jq -r --argjson limit "$limit" '
        .successPatterns |
        to_entries |
        map({
            taskType: .key,
            totalSuccesses: .value.count,
            avgDuration: .value.avgDuration,
            topStrategy: (
                .value.strategies |
                to_entries |
                sort_by(-.value) |
                .[0].key
            )
        }) |
        sort_by(-.totalSuccesses) |
        .[:$limit]
    ' "$MODELS_FILE"
}

# Export learning data for analysis
export_learning_data() {
    local output_file="${1:-$LEARNING_DIR/export_$(date +%Y%m%d_%H%M%S).json}"

    init_learning

    jq -n \
        --slurpfile models "$MODELS_FILE" \
        --slurpfile stats "$STATISTICS_FILE" \
        '{
            models: $models[0],
            statistics: $stats[0],
            exportedAt: (now | todate)
        }' > "$output_file"

    log "Exported learning data to: $output_file"
    echo "$output_file"
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    init)
        init_learning
        ;;
    learn-success)
        learn_success "${2:-general}" "${3:-default}" "${4:-0}" "${5:-}"
        ;;
    learn-failure)
        learn_failure "${2:-general}" "${3:-default}" "${4:-UNKNOWN}" "${5:-}"
        ;;
    recommend)
        recommend_strategy "${2:-general}" "${3:-}"
        ;;
    predict-risk)
        predict_risk "${2:-general}" "${3:-default}"
        ;;
    mine-patterns)
        mine_patterns "${2:-}" "${3:-5}"
        ;;
    calculate-quality)
        calculate_quality "${2:-general}" "${3:-0}" "${4:-0}" "${5:-0}"
        ;;
    statistics)
        get_statistics
        ;;
    best-strategies)
        get_best_strategies "${2:-10}"
        ;;
    export)
        export_learning_data "${2:-}"
        ;;
    help|*)
        echo "Learning Engine - Continuous Learning System"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Learning Commands:"
        echo "  learn-success <type> <strategy> [duration] [context]"
        echo "                                  - Learn from successful execution"
        echo "  learn-failure <type> <strategy> <error> [msg]"
        echo "                                  - Learn from failure"
        echo ""
        echo "Prediction Commands:"
        echo "  recommend <task_type> [context] - Recommend best strategy"
        echo "  predict-risk <type> <strategy>  - Predict failure risk (0-100)"
        echo "  mine-patterns <query> [limit]   - Mine memory for patterns"
        echo "  calculate-quality <type> <dur> <errors> <retries>"
        echo "                                  - Calculate quality score"
        echo ""
        echo "Analytics Commands:"
        echo "  statistics                      - Get learning statistics"
        echo "  best-strategies [limit]         - Get top performing strategies"
        echo "  export [file]                   - Export learning data"
        echo ""
        echo "Examples:"
        echo "  $0 recommend feature_implementation"
        echo "  $0 predict-risk bugfix incremental"
        echo "  $0 mine-patterns 'authentication fix'"
        ;;
esac
