#!/bin/bash
# Quick test of should_use_reflexion_agent decision logic
# Standalone test without sourcing full orchestrator

set -e

# Define the decision function
should_use_reflexion_agent() {
    local task="$1"
    local analysis="$2"

    local task_type=$(echo "$analysis" | jq -r '.taskType // "general"' 2>/dev/null)
    local risk_score=$(echo "$analysis" | jq -r '.risk // 10' 2>/dev/null)
    local confidence=$(echo "$analysis" | jq -r '.confidence // 0' 2>/dev/null)

    # Rule 1: High-risk + low confidence
    if command -v bc >/dev/null 2>&1; then
        local risk_check=$(echo "$risk_score > 5" | bc -l 2>/dev/null || echo "0")
        local conf_check=$(echo "$confidence < 0.5" | bc -l 2>/dev/null || echo "0")
        if [[ "$risk_check" == "1" ]] && [[ "$conf_check" == "1" ]]; then
            echo '{"useReflexion":true,"reason":"high_risk_low_confidence"}'
            return 0
        fi
    fi

    # Rule 2: Complex feature
    if [[ "$task_type" == "feature" ]]; then
        if echo "$task" | grep -qiE "implement.*with|create.*multiple|build.*system"; then
            echo '{"useReflexion":true,"reason":"complex_feature"}'
            return 0
        fi
    fi

    # Rule 3: Multi-file
    if echo "$task" | grep -qiE "multiple files|across.*files|[0-9]+.*files"; then
        echo '{"useReflexion":true,"reason":"multi_file_task"}'
        return 0
    fi

    # Rule 4: Iteration keywords
    if echo "$task" | grep -qiE "refine|iterate|improve.*until|self-correct"; then
        echo '{"useReflexion":true,"reason":"explicit_iteration"}'
        return 0
    fi

    echo '{"useReflexion":false,"reason":"simple_task"}'
    return 1
}

echo "🧪 Testing ReflexionAgent Decision Logic"
echo "========================================"

# Test 1: Simple bugfix
echo -e "\nTest 1: Simple bugfix"
result=$(should_use_reflexion_agent "Fix typo in README.md" '{"taskType":"bugfix","risk":2,"confidence":0.8}')
expected_use=$(echo "$result" | jq -r '.useReflexion')
if [[ "$expected_use" == "false" ]]; then
    echo "  ✅ Correctly identified as simple task"
else
    echo "  ❌ Failed: useReflexion=$expected_use (expected: false)"
fi

# Test 2: Complex feature
echo -e "\nTest 2: Complex feature"
result=$(should_use_reflexion_agent "Implement authentication with JWT" '{"taskType":"feature","risk":8,"confidence":0.3}')
expected_use=$(echo "$result" | jq -r '.useReflexion')
if [[ "$expected_use" == "true" ]]; then
    echo "  ✅ Correctly identified as complex feature"
else
    echo "  ❌ Failed: useReflexion=$expected_use (expected: true)"
fi

# Test 3: Multi-file task
echo -e "\nTest 3: Multi-file task"
result=$(should_use_reflexion_agent "Create REST API with 5 files" '{"taskType":"feature","risk":6,"confidence":0.5}')
expected_use=$(echo "$result" | jq -r '.useReflexion')
reason=$(echo "$result" | jq -r '.reason')
if [[ "$expected_use" == "true" ]] && [[ "$reason" == "multi_file_task" ]]; then
    echo "  ✅ Correctly identified multi-file task"
else
    echo "  ❌ Failed: useReflexion=$expected_use, reason=$reason"
fi

# Test 4: High risk + low confidence
echo -e "\nTest 4: High risk + low confidence"
result=$(should_use_reflexion_agent "Refactor database layer" '{"taskType":"refactor","risk":9,"confidence":0.2}')
expected_use=$(echo "$result" | jq -r '.useReflexion')
if [[ "$expected_use" == "true" ]]; then
    echo "  ✅ Correctly identified high-risk task"
else
    echo "  ❌ Failed: useReflexion=$expected_use (expected: true)"
fi

# Test 5: Iteration keywords
echo -e "\nTest 5: Iteration keywords"
result=$(should_use_reflexion_agent "Refine the search algorithm until optimal" '{"taskType":"feature","risk":5,"confidence":0.6}')
expected_use=$(echo "$result" | jq -r '.useReflexion')
reason=$(echo "$result" | jq -r '.reason')
if [[ "$expected_use" == "true" ]] && [[ "$reason" == "explicit_iteration" ]]; then
    echo "  ✅ Correctly identified iteration task"
else
    echo "  ❌ Failed: useReflexion=$expected_use, reason=$reason"
fi

echo -e "\n========================================"
echo "✅ Decision logic tests complete"
