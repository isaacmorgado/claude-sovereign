#!/bin/bash
# Risk Predictor - Pre-execution risk assessment
# Predicts failure probability before executing operations

set -uo pipefail

RISK_DIR="${HOME}/.claude/risk"
RISK_MODELS="$RISK_DIR/models.json"
LOG_FILE="${HOME}/.claude/risk-predictor.log"

# Integration
LEARNING_ENGINE="${HOME}/.claude/hooks/learning-engine.sh"
MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_risk() {
    mkdir -p "$RISK_DIR"
    [[ -f "$RISK_MODELS" ]] || echo '{"codeComplexity":{},"historicalFailures":{},"dependencies":{}}' > "$RISK_MODELS"
}

# =============================================================================
# CODE COMPLEXITY ANALYSIS
# =============================================================================

analyze_code_complexity() {
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        echo '{"complexity":0,"risk":"low"}'
        return
    fi

    local lines
    lines=$(wc -l < "$file_path" 2>/dev/null || echo "0")

    local functions
    functions=$(grep -c "function\|def \|fn \|func " "$file_path" 2>/dev/null || echo "0")

    local nesting
    nesting=$(grep -o "{" "$file_path" 2>/dev/null | wc -l | tr -d ' ')

    # Calculate complexity score (0-100)
    local complexity
    complexity=$(( (lines / 10) + (functions * 5) + (nesting / 2) ))
    [[ $complexity -gt 100 ]] && complexity=100

    local risk="low"
    [[ $complexity -gt 30 ]] && risk="medium"
    [[ $complexity -gt 60 ]] && risk="high"

    echo "{\"complexity\":$complexity,\"lines\":$lines,\"functions\":$functions,\"risk\":\"$risk\"}"
}

# =============================================================================
# HISTORICAL FAILURE ANALYSIS
# =============================================================================

check_historical_failures() {
    local operation_type="$1"
    local context="${2:-}"

    # Query learning engine for historical failures
    if [[ -x "$LEARNING_ENGINE" ]]; then
        "$LEARNING_ENGINE" predict-risk "$operation_type" "$context" 2>/dev/null
    else
        echo '{"riskScore":10,"riskLevel":"low"}'
    fi
}

# =============================================================================
# DEPENDENCY RISK ANALYSIS
# =============================================================================

analyze_dependency_risk() {
    local project_dir="${1:-.}"

    local risk_score=0

    # Check for package.json
    if [[ -f "$project_dir/package.json" ]]; then
        local dep_count
        dep_count=$(jq -r '.dependencies // {} | length' "$project_dir/package.json" 2>/dev/null || echo "0")
        risk_score=$((risk_score + dep_count / 5))
    fi

    # Check for requirements.txt
    if [[ -f "$project_dir/requirements.txt" ]]; then
        local req_count
        req_count=$(wc -l < "$project_dir/requirements.txt" 2>/dev/null || echo "0")
        risk_score=$((risk_score + req_count / 3))
    fi

    # Check for go.mod
    if [[ -f "$project_dir/go.mod" ]]; then
        local mod_count
        mod_count=$(grep "require" "$project_dir/go.mod" 2>/dev/null | wc -l | tr -d ' ')
        risk_score=$((risk_score + mod_count / 4))
    fi

    [[ $risk_score -gt 100 ]] && risk_score=100

    local risk_level="low"
    [[ $risk_score -gt 30 ]] && risk_level="medium"
    [[ $risk_score -gt 60 ]] && risk_level="high"

    echo "{\"dependencyRisk\":$risk_score,\"riskLevel\":\"$risk_level\"}"
}

# =============================================================================
# COMPREHENSIVE RISK ASSESSMENT
# =============================================================================

assess_risk() {
    local operation="$1"
    local task_type="${2:-general}"
    local file_path="${3:-}"
    local context="${4:-}"

    init_risk

    # Component risks
    local code_risk='{"complexity":0,"risk":"low"}'
    [[ -n "$file_path" && -f "$file_path" ]] && code_risk=$(analyze_code_complexity "$file_path")

    local historical_risk
    historical_risk=$(check_historical_failures "$task_type" "$context")

    local dep_risk
    dep_risk=$(analyze_dependency_risk ".")

    # Combine risks (weighted average)
    local code_score
    code_score=$(echo "$code_risk" | jq -r '.complexity')
    local hist_score
    hist_score=$(echo "$historical_risk" | jq -r '.riskScore')
    local dep_score
    dep_score=$(echo "$dep_risk" | jq -r '.dependencyRisk')

    local total_risk
    total_risk=$(( (code_score * 30 + hist_score * 50 + dep_score * 20) / 100 ))

    local risk_level="low"
    [[ $total_risk -gt 30 ]] && risk_level="medium"
    [[ $total_risk -gt 60 ]] && risk_level="high"

    # Generate recommendations
    local recommendations=()
    [[ $code_score -gt 60 ]] && recommendations+=("High code complexity - consider refactoring")
    [[ $hist_score -gt 50 ]] && recommendations+=("High historical failure rate - review past errors")
    [[ $dep_score -gt 50 ]] && recommendations+=("Many dependencies - verify compatibility")

    local recs_json="[]"
    if [[ ${#recommendations[@]} -gt 0 ]]; then
        recs_json=$(printf '%s\n' "${recommendations[@]}" | jq -R . | jq -s .)
    fi

    jq -n \
        --arg op "$operation" \
        --arg type "$task_type" \
        --argjson total "$total_risk" \
        --arg level "$risk_level" \
        --argjson code "$code_risk" \
        --argjson hist "$historical_risk" \
        --argjson dep "$dep_risk" \
        --argjson recs "$recs_json" \
        '{
            operation: $op,
            taskType: $type,
            totalRisk: $total,
            riskLevel: $level,
            components: {
                codeComplexity: $code,
                historicalFailures: $hist,
                dependencies: $dep
            },
            recommendations: $recs
        }'

    log "Risk assessment for $operation: $risk_level ($total_risk/100)"
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    assess)
        assess_risk "${2:-operation}" "${3:-general}" "${4:-}" "${5:-}"
        ;;
    code-complexity)
        analyze_code_complexity "${2:-.}"
        ;;
    historical)
        check_historical_failures "${2:-general}" "${3:-}"
        ;;
    dependencies)
        analyze_dependency_risk "${2:-.}"
        ;;
    help|*)
        echo "Risk Predictor - Pre-execution Risk Assessment"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  assess <op> <type> [file] [ctx] - Comprehensive risk assessment"
        echo "  code-complexity <file>          - Analyze code complexity"
        echo "  historical <type> [ctx]         - Check historical failures"
        echo "  dependencies [dir]              - Analyze dependency risk"
        echo ""
        echo "Examples:"
        echo "  $0 assess build_auth feature src/auth.ts"
        echo "  $0 code-complexity src/complex.ts"
        echo "  $0 historical bugfix"
        ;;
esac
