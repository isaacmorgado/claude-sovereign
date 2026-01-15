#!/bin/bash
# Strategy Selector - Chooses optimal strategy based on task characteristics

set -uo pipefail

STRATEGY_DIR="${HOME}/.claude/strategies"
SELECTION_LOG="$STRATEGY_DIR/selections.jsonl"
LOG_FILE="${HOME}/.claude/strategy-selector.log"

LEARNING_ENGINE="${HOME}/.claude/hooks/learning-engine.sh"
RISK_PREDICTOR="${HOME}/.claude/hooks/risk-predictor.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_strategies() {
    mkdir -p "$STRATEGY_DIR"
    [[ -f "$SELECTION_LOG" ]] || touch "$SELECTION_LOG"
}

# Select best strategy for task
select_strategy() {
    local task="$1"
    local task_type="${2:-general}"
    local context="${3:-}"

    init_strategies

    # Get recommendation from learning engine
    local recommendation='{"strategy":"default","confidence":0}'
    if [[ -x "$LEARNING_ENGINE" ]]; then
        local rec_result
        rec_result=$("$LEARNING_ENGINE" recommend "$task_type" "$context" 2>/dev/null || echo '{"strategy":"default","confidence":0}')
        if [[ -n "$rec_result" && "$rec_result" != "null" ]]; then
            recommendation="$rec_result"
        fi
    fi

    # Get risk assessment
    local risk='{"riskScore":10,"riskLevel":"low"}'
    if [[ -x "$RISK_PREDICTOR" ]]; then
        local risk_result
        risk_result=$("$RISK_PREDICTOR" assess "$task" "$task_type" "" "$context" 2>/dev/null || echo '{"components":{"historicalFailures":{"riskScore":10,"riskLevel":"low"}}}')
        if [[ -n "$risk_result" && "$risk_result" != "null" && "$risk_result" != "{}" ]]; then
            local hist_risk
            hist_risk=$(echo "$risk_result" | jq -c '.components.historicalFailures // {"riskScore":10,"riskLevel":"low"}' 2>/dev/null || echo '{"riskScore":10,"riskLevel":"low"}')
            if [[ -n "$hist_risk" && "$hist_risk" != "null" ]]; then
                risk="$hist_risk"
            fi
        fi
    fi

    local strategy
    strategy=$(echo "$recommendation" | jq -r '.strategy // "default"')
    local confidence
    confidence=$(echo "$recommendation" | jq -r '.confidence // 0')
    local risk_level
    risk_level=$(echo "$risk" | jq -r '.riskLevel // "low"')

    # Adjust strategy based on risk
    if [[ "$risk_level" == "high" && "$strategy" == "default" ]]; then
        strategy="incremental"  # Safer approach for high risk
    fi

    # Ensure confidence is a valid number
    [[ -z "$confidence" || "$confidence" == "null" ]] && confidence=0

    # Log selection
    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local selection
    selection=$(jq -n \
        --arg task "$task" \
        --arg type "$task_type" \
        --arg strategy "$strategy" \
        --argjson confidence "$confidence" \
        --arg risk "$risk_level" \
        --arg ts "$timestamp" \
        '{task: $task, taskType: $type, strategy: $strategy, confidence: $confidence, risk: $risk, timestamp: $ts}' 2>/dev/null || echo '{}')

    if [[ -n "$selection" && "$selection" != "{}" ]]; then
        echo "$selection" >> "$SELECTION_LOG"
    fi

    jq -n \
        --arg strategy "$strategy" \
        --argjson confidence "$confidence" \
        --arg risk "$risk_level" \
        '{strategy: $strategy, confidence: $confidence, riskLevel: $risk, reasoning: "Based on historical success rate and risk assessment"}'
}

case "${1:-help}" in
    select) select_strategy "${2:-task}" "${3:-general}" "${4:-}" ;;
    *) echo "Usage: $0 select <task> [type] [context]" ;;
esac
