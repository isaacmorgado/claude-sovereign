#!/bin/bash
# Risk Predictor - Task Risk Assessment
# Assesses risk level for tasks before execution
# Usage: risk-predictor.sh assess <task> [task_type] [context]

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/risk-predictor.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Assess task risk
assess() {
    local task="$1"
    local task_type="${2:-general}"
    local context="${3:-}"

    log "Assessing risk for: $task (type: $task_type)"

    # Base risk score
    local risk_score=10
    local risk_factors="[]"

    # Analyze task for risk factors
    local task_lower
    task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Factor 1: Task complexity
    local complexity="low"
    if [[ "$task_lower" =~ (complex|architecture|system|comprehensive|integration|multiple) ]]; then
        complexity="high"
        risk_score=$((risk_score + 20))
    elif [[ "$task_lower" =~ (implement|build|create|feature|module) ]]; then
        complexity="medium"
        risk_score=$((risk_score + 10))
    fi
    risk_factors=$(echo "$risk_factors" | jq --arg factor "complexity" --argjson score "$risk_score" --arg desc "$complexity: $complexity" '. + [{factor: "complexity", score: $risk_score, description: $desc}]')

    # Factor 2: Data sensitivity
    local data_risk="low"
    if [[ "$task_lower" =~ (database|data|storage|file|delete|truncate|drop) ]]; then
        data_risk="high"
        risk_score=$((risk_score + 30))
    elif [[ "$task_lower" =~ (user|auth|password|secret|key|token|credential) ]]; then
        data_risk="medium"
        risk_score=$((risk_score + 15))
    fi
    risk_factors=$(echo "$risk_factors" | jq --arg factor "data_sensitivity" --argjson score "$risk_score" --arg desc "$data_risk: $data_risk" '. + [{factor: "data_sensitivity", score: $risk_score, description: $desc}]')

    # Factor 3: Production impact
    local production_risk="low"
    if [[ "$task_lower" =~ (deploy|production|release|live|prod) ]]; then
        production_risk="high"
        risk_score=$((risk_score + 25))
    elif [[ "$task_lower" =~ (api|endpoint|service|route) ]]; then
        production_risk="medium"
        risk_score=$((risk_score + 15))
    fi
    risk_factors=$(echo "$risk_factors" | jq --arg factor "production_impact" --argjson score "$risk_score" --arg desc "$production_risk" '. + [{factor: "production_impact", score: $risk_score, description: $desc}]')

    # Factor 4: Reversibility
    local reversibility="low"
    if [[ "$task_lower" =~ (delete|remove|drop|truncate|overwrite|force) ]]; then
        reversibility="high"
        risk_score=$((risk_score + 20))
    elif [[ "$task_lower" =~ (modify|update|change|refactor) ]]; then
        reversibility="medium"
        risk_score=$((risk_score + 10))
    fi
    risk_factors=$(echo "$risk_factors" | jq --arg factor "reversibility" --argjson score "$risk_score" --arg desc "$reversibility" '. + [{factor: "reversibility", score: $risk_score, description: $desc}]')

    # Factor 5: Dependencies
    local dependency_risk="low"
    if [[ "$task_lower" =~ (integration|api|external|third.party|library) ]]; then
        dependency_risk="high"
        risk_score=$((risk_score + 15))
    elif [[ "$task_lower" =~ (git|version|upgrade|migration) ]]; then
        dependency_risk="medium"
        risk_score=$((risk_score + 10))
    fi
    risk_factors=$(echo "$risk_factors" | jq --arg factor "dependencies" --argjson score "$risk_score" --arg desc "$dependency_risk" '. + [{factor: "dependencies", score: $risk_score, description: $desc}]')

    # Factor 6: Testing requirements
    local testing_risk="low"
    if [[ "$task_lower" =~ (test|validate|verify) ]]; then
        testing_risk="low"
        risk_score=$((risk_score - 5))
    elif [[ "$task_lower" =~ (no.test|skip.test|manual.test) ]]; then
        testing_risk="high"
        risk_score=$((risk_score + 20))
    fi
    risk_factors=$(echo "$risk_factors" | jq --arg factor "testing" --argjson score "$risk_score" --arg desc "$testing_risk" '. + [{factor: "testing", score: $risk_score, description: $desc}]')

    # Normalize score to 0-100
    if [[ $risk_score -gt 100 ]]; then
        risk_score=100
    fi

    # Determine risk level
    local risk_level="low"
    if [[ $risk_score -ge 70 ]]; then
        risk_level="high"
    elif [[ $risk_score -ge 40 ]]; then
        risk_level="medium"
    fi

    # Calculate confidence
    local confidence=0.9
    if [[ $risk_level == "high" ]]; then
        confidence=0.7
    elif [[ $risk_level == "medium" ]]; then
        confidence=0.8
    fi

    log "Risk assessment complete: score=$risk_score, level=$risk_level"

    # Output assessment result
    jq -n \
        --arg task "$task" \
        --arg type "$task_type" \
        --argjson score "$risk_score" \
        --arg level "$risk_level" \
        --argjson confidence "$confidence" \
        --argjson factors "$risk_factors" \
        '{
            task: $task,
            task_type: $type,
            riskScore: $score,
            riskLevel: $level,
            confidence: $confidence,
            riskFactors: $factors,
            recommendation: (if $level == "high" then "Extra caution and review required" elif $level == "medium" then "Proceed with standard safeguards" else "Low risk - proceed normally" end)
        }'
}

# Main CLI
case "${1:-help}" in
    assess)
        assess "${2:-task}" "${3:-general}" "${4:-}"
        ;;
    help|*)
        cat <<EOF
Risk Predictor - Task Risk Assessment

Usage:
  $0 assess <task> [task_type] [context]
      Assess task risk level

Risk Factors:
  1. Complexity        - Task complexity (low/medium/high)
  2. Data Sensitivity - Data handling (low/medium/high)
  3. Production Impact - Production environment impact (low/medium/high)
  4. Reversibility   - Can changes be undone (low/medium/high)
  5. Dependencies     - External dependencies (low/medium/high)
  6. Testing          - Testing requirements (low/medium/high)

Risk Levels:
  - Low (0-39):    Proceed normally
  - Medium (40-69):  Standard safeguards
  - High (70-100): Extra caution and review

Examples:
  $0 assess "delete production database" "database"
  $0 assess "implement auth system" "implementation"
  $0 assess "deploy to production" "deployment"
EOF
        ;;
esac
