#!/bin/bash
# LLM-as-Judge Auto-Evaluator - Simplified with proper JSON
set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
EVAL_HISTORY="${CLAUDE_DIR}/.evaluator/history.jsonl"
LOG_FILE="${CLAUDE_DIR}/auto-evaluator.log"

mkdir -p "$(dirname "$EVAL_HISTORY")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Get evaluation criteria
get_evaluation_criteria() {
    local eval_type="${1:-code}"
    
    case "$eval_type" in
        code)
            echo '{"criteria":{"correctness":{"description":"Solves problem correctly","weight":0.30},"quality":{"description":"Well-written and maintainable","weight":0.25},"safety":{"description":"Avoids vulnerabilities","weight":0.20},"efficiency":{"description":"Performant","weight":0.15},"completeness":{"description":"Handles edge cases","weight":0.10}},"scale":"1-10","pass_threshold":7.0}'
            ;;
        test)
            echo '{"criteria":{"coverage":{"description":"Tests all scenarios","weight":0.35},"correctness":{"description":"Assertions are correct","weight":0.30},"maintainability":{"description":"Test code is clear","weight":0.20},"isolation":{"description":"Properly isolated","weight":0.15}},"scale":"1-10","pass_threshold":7.0}'
            ;;
        *)
            echo '{"criteria":{"quality":{"description":"Overall quality","weight":0.50},"correctness":{"description":"Meets requirements","weight":0.30},"completeness":{"description":"Complete and thorough","weight":0.20}},"scale":"1-10","pass_threshold":7.0}'
            ;;
    esac
}

# Generate evaluation prompt - returns plain text prompt for Claude
evaluate_output() {
    local task="$1"
    local output="$2"
    local eval_type="${3:-code}"
    
    log "Generating evaluation prompt for: $task"
    
    local criteria
    criteria=$(get_evaluation_criteria "$eval_type")
    
    echo "EVALUATION REQUEST: Evaluate this $eval_type output for task: $task"
    echo ""
    echo "OUTPUT TO EVALUATE:"
    echo "$output"
    echo ""
    echo "CRITERIA: $criteria"
    echo ""
    echo "Please provide JSON response with: weighted_score (1-10), pass (bool), critical_issues (array), improvement_suggestions (array), revision_required (bool)"
}

# Process evaluation result
process_evaluation_result() {
    local eval_result="$1"
    local task="$2"
    
    log "Processing evaluation result for: $task"
    
    local score
    local pass_status
    
    score=$(echo "$eval_result" | jq -r '.weighted_score // 5' 2>/dev/null || echo "5")
    pass_status=$(echo "$eval_result" | jq -r '.pass // false' 2>/dev/null || echo "false")
    
    # Record to history
    echo "$eval_result" | jq -c ". + {task: \"$task\", timestamp: \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >> "$EVAL_HISTORY" 2>/dev/null || true
    
    local action="continue"
    if (( $(echo "$score < 7" | bc -l 2>/dev/null || echo 1) )); then
        action="revise"
    fi
    
    jq -n \
        --arg action "$action" \
        --arg score "$score" \
        --arg pass "$pass_status" \
        "{action: \$action, score: (\$score | tonumber), pass: (\$pass == \"true\")}"
}

# Get stats
get_evaluation_stats() {
    local limit="${1:-20}"
    
    if [[ ! -f "$EVAL_HISTORY" ]]; then
        echo '{"total":0,"avg_score":0}'
        return
    fi
    
    tail -n "$limit" "$EVAL_HISTORY" | jq -s '{total: length, avg_score: (map(.weighted_score // 5) | add / length)}'
}

case "${1:-help}" in
    evaluate)
        evaluate_output "${2:-task}" "${3:-output}" "${4:-code}"
        ;;
    process)
        process_evaluation_result "${2:-{}}" "${3:-task}"
        ;;
    criteria)
        get_evaluation_criteria "${2:-code}"
        ;;
    stats)
        get_evaluation_stats "${2:-20}"
        ;;
    help|*)
        echo "LLM-as-Judge Auto-Evaluator"
        echo "Usage: $0 <command> [args]"
        echo "  evaluate <task> <output> [type]  - Generate evaluation prompt"
        echo "  process <result> <task>          - Process evaluation result"
        echo "  criteria [type]                  - Get criteria (code/test/general)"
        echo "  stats [limit]                    - Get statistics"
        ;;
esac
