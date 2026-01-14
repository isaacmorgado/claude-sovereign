#!/bin/bash
# Auto-Evaluator - Quality Gate Assessment
# Evaluates outputs against task-specific criteria
# Usage: auto-evaluator.sh criteria <task_type>
#        auto-evaluator.sh evaluate <task> <output> <type> <context>

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/auto-evaluator.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Define evaluation criteria by task type
get_criteria() {
    local task_type="$1"

    case "$task_type" in
        implementation)
            echo '{
                "name": "Implementation Quality",
                "criteria": [
                    {"name": "correctness", "weight": 0.3, "description": "Code produces correct output"},
                    {"name": "completeness", "weight": 0.25, "description": "All requirements implemented"},
                    {"name": "efficiency", "weight": 0.2, "description": "Optimal performance and resource usage"},
                    {"name": "maintainability", "weight": 0.15, "description": "Clean, well-structured code"},
                    {"name": "testing", "weight": 0.1, "description": "Adequate test coverage"}
                ],
                "threshold": 7.0
            }'
            ;;
        debugging)
            echo '{
                "name": "Debugging Quality",
                "criteria": [
                    {"name": "root_cause_identified", "weight": 0.3, "description": "Root cause correctly identified"},
                    {"name": "fix_effectiveness", "weight": 0.3, "description": "Fix resolves the issue"},
                    {"name": "no_regressions", "weight": 0.2, "description": "No new issues introduced"},
                    {"name": "test_coverage", "weight": 0.1, "description": "Tests added to prevent recurrence"},
                    {"name": "documentation", "weight": 0.1, "description": "Issue documented for future reference"}
                ],
                "threshold": 7.0
            }'
            ;;
        testing)
            echo '{
                "name": "Testing Quality",
                "criteria": [
                    {"name": "test_completeness", "weight": 0.3, "description": "Tests cover all scenarios"},
                    {"name": "test_correctness", "weight": 0.3, "description": "Tests validate correct behavior"},
                    {"name": "edge_cases", "weight": 0.2, "description": "Edge cases handled"},
                    {"name": "maintainability", "weight": 0.1, "description": "Tests are clear and maintainable"},
                    {"name": "performance", "weight": 0.1, "description": "Tests run efficiently"}
                ],
                "threshold": 7.0
            }'
            ;;
        documentation)
            echo '{
                "name": "Documentation Quality",
                "criteria": [
                    {"name": "completeness", "weight": 0.3, "description": "All features documented"},
                    {"name": "clarity", "weight": 0.3, "description": "Clear and understandable"},
                    {"name": "accuracy", "weight": 0.2, "description": "Information is correct"},
                    {"name": "examples", "weight": 0.1, "description": "Usage examples provided"},
                    {"name": "structure", "weight": 0.1, "description": "Well-organized structure"}
                ],
                "threshold": 7.0
            }'
            ;;
        refactoring)
            echo '{
                "name": "Refactoring Quality",
                "criteria": [
                    {"name": "improvement", "weight": 0.3, "description": "Code quality improved"},
                    {"name": "functionality_preserved", "weight": 0.3, "description": "All functionality still works"},
                    {"name": "performance", "weight": 0.2, "description": "Performance not degraded"},
                    {"name": "readability", "weight": 0.1, "description": "Code is more readable"},
                    {"name": "tests_pass", "weight": 0.1, "description": "All tests still pass"}
                ],
                "threshold": 7.0
            }'
            ;;
        research)
            echo '{
                "name": "Research Quality",
                "criteria": [
                    {"name": "completeness", "weight": 0.3, "description": "All aspects researched"},
                    {"name": "accuracy", "weight": 0.3, "description": "Information is accurate"},
                    {"name": "sources", "weight": 0.2, "description": "Reliable sources cited"},
                    {"name": "relevance", "weight": 0.1, "description": "Findings are relevant to task"},
                    {"name": "actionable", "weight": 0.1, "description": "Clear recommendations provided"}
                ],
                "threshold": 7.0
            }'
            ;;
        *)
            # Default general criteria
            echo '{
                "name": "General Quality",
                "criteria": [
                    {"name": "correctness", "weight": 0.3, "description": "Output is correct"},
                    {"name": "completeness", "weight": 0.3, "description": "All requirements met"},
                    {"name": "clarity", "weight": 0.2, "description": "Clear and understandable"},
                    {"name": "efficiency", "weight": 0.2, "description": "Efficient approach"}
                ],
                "threshold": 7.0
            }'
            ;;
    esac
}

# Evaluate output against criteria
evaluate() {
    local task="$1"
    local output="$2"
    local type="${3:-code}"
    local context="${4:-}"

    log "Evaluating output for task: $task"

    # Determine task type
    local task_type="general"
    [[ "$task" =~ (implement|build|create|add) ]] && task_type="implementation"
    [[ "$task" =~ (debug|fix|bug|error) ]] && task_type="debugging"
    [[ "$task" =~ (test|validate|verify) ]] && task_type="testing"
    [[ "$task" =~ (document|readme|api.*doc) ]] && task_type="documentation"
    [[ "$task" =~ (refactor|clean|optimize) ]] && task_type="refactoring"
    [[ "$task" =~ (research|investigate|explore) ]] && task_type="research"

    # Get criteria
    local criteria_json
    criteria_json=$(get_criteria "$task_type")

    local criteria
    criteria=$(echo "$criteria_json" | jq -r '.criteria')

    # Evaluate each criterion
    local scores="[]"
    local total_weight=0

    while IFS= read -r criterion; do
        if [[ -z "$criterion" || "$criterion" == "null" ]]; then
            continue
        fi

        local name
        local weight
        local description

        name=$(echo "$criterion" | jq -r '.name')
        weight=$(echo "$criterion" | jq -r '.weight')
        description=$(echo "$criterion" | jq -r '.description')

        total_weight=$((total_weight + $(echo "$weight * 100" | bc -l 2>/dev/null || echo "30"))))

        # Simple heuristic scoring (in production, would use LLM)
        local score=7.0

        # Adjust score based on output content
        case "$name" in
            correctness|completeness|accuracy)
                [[ "$output" =~ (TODO|FIXME|XXX|hack) ]] && score=$((score - 2))
                [[ "$output" =~ (error|fail|issue|problem) ]] && score=$((score - 1))
                ;;
            testing|test_coverage|edge_cases)
                [[ "$output" =~ (test|assert|verify) ]] && score=$((score + 1))
                ;;
            maintainability|readability|clarity)
                [[ "$output" =~ (comment|document|explain) ]] && score=$((score + 1))
                ;;
            efficiency|performance)
                [[ "$output" =~ (optimize|cache|async|parallel) ]] && score=$((score + 1))
                ;;
        esac

        # Normalize score to 0-10
        [[ $score -gt 10 ]] && score=10
        [[ $score -lt 0 ]] && score=0

        scores=$(echo "$scores" | jq --arg name "$name" --argjson score "$score" --argjson weight "$weight" --arg desc "$description" '. + [{"name": $name, "score": $score, "weight": $weight, "description": $desc}]')
    done < <(echo "$criteria" | jq -c '.[]')

    # Calculate weighted average
    local weighted_sum=0
    while IFS= read -r score_entry; do
        local s w
        s=$(echo "$score_entry" | jq -r '.score')
        w=$(echo "$score_entry" | jq -r '.weight')
        weighted_sum=$(echo "$weighted_sum + ($s * $w)" | bc -l 2>/dev/null || echo "0")
    done < <(echo "$scores" | jq -c '.[]')

    local final_score
    final_score=$(echo "scale=2; $weighted_sum / $total_weight" | bc -l 2>/dev/null || echo "7.0")

    # Normalize to 0-10
    final_score=$(echo "scale=2; if ($final_score > 10) then 10 elif ($final_score < 0) then 0 else $final_score end" | bc -l 2>/dev/null || echo "7.0")

    # Get threshold
    local threshold
    threshold=$(echo "$criteria_json" | jq -r '.threshold')

    # Determine decision
    local decision="continue"
    if (( $(echo "$final_score < $threshold" | bc -l 2>/dev/null || echo "0") )); then
        decision="revise"
    fi

    log "Evaluation complete: score=$final_score, decision=$decision"

    # Output evaluation result
    jq -n \
        --arg task "$task" \
        --arg type "$task_type" \
        --argjson score "$final_score" \
        --arg threshold "$threshold" \
        --arg decision "$decision" \
        --argjson scores "$scores" \
        '{
            task: $task,
            task_type: $type,
            overall_score: $score,
            threshold: $threshold,
            decision: $decision,
            criteria_scores: $scores,
            recommendation: (if $decision == "revise" then "Revise output to improve quality" else "Quality acceptable - proceed" end)
        }'
}

# Process evaluation decision
process() {
    local evaluation_json="$1"
    local task="$2"

    log "Processing evaluation decision"

    local decision
    decision=$(echo "$evaluation_json" | jq -r '.decision')

    case "$decision" in
        revise)
            echo '{"status": "needs_revision", "action": "revise", "message": "Output quality below threshold - revise and re-evaluate"}'
            ;;
        continue)
            echo '{"status": "approved", "action": "continue", "message": "Quality acceptable - proceed with task"}'
            ;;
        *)
            echo '{"status": "unknown", "action": "review", "message": "Manual review required"}'
            ;;
    esac
}

# Main CLI
case "${1:-help}" in
    criteria)
        get_criteria "${2:-general}"
        ;;
    evaluate)
        evaluate "${2:-task}" "${3:-output}" "${4:-code}" "${5:-}"
        ;;
    process)
        process "${2:-evaluation_json}" "${3:-task}"
        ;;
    help|*)
        cat <<EOF
Auto-Evaluator - Quality Gate Assessment

Usage:
  $0 criteria <task_type>              Get evaluation criteria for task type
  $0 evaluate <task> <output> [type] [context]
      Evaluate output against criteria
  $0 process <evaluation_json> [task]   Process evaluation decision

Task Types:
  implementation   - Code implementation tasks
  debugging       - Bug fixing and troubleshooting
  testing         - Test creation and validation
  documentation  - Documentation writing
  refactoring     - Code refactoring and cleanup
  research        - Research and investigation

Scoring:
  - Each criterion scored 0-10
  - Weighted average calculated
  - Compared to threshold (default 7.0)
  - Decision: continue (>=7.0) or revise (<7.0)

Examples:
  $0 criteria implementation
  $0 evaluate "implement auth" "code output here" "code"
  $0 process '{"decision": "revise"}' "implement auth"
EOF
        ;;
esac
