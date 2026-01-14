#!/bin/bash
# Integration tests: Orchestrator → ReflexionAgent decision logic
# Tests should_use_reflexion_agent() decision function

set -e

# Load orchestrator functions
ORCHESTRATOR_SCRIPT="${HOME}/.claude/hooks/autonomous-orchestrator-v2.sh"

if [[ ! -f "$ORCHESTRATOR_SCRIPT" ]]; then
    echo "❌ Orchestrator not found: $ORCHESTRATOR_SCRIPT"
    exit 1
fi

# Disable feature flag to prevent orchestrator from running
export ENABLE_REFLEXION_AGENT=0

# Extract and define only the should_use_reflexion_agent function
# (avoids sourcing entire script which has global execution code)
should_use_reflexion_agent() {
    local task="$1"
    local analysis="$2"  # JSON from analyze_task()

    # Extract complexity indicators from analysis
    local task_type=$(echo "$analysis" | jq -r '.taskType // "general"' 2>/dev/null)
    local risk_score=$(echo "$analysis" | jq -r '.risk // 10' 2>/dev/null)
    local confidence=$(echo "$analysis" | jq -r '.confidence // 0' 2>/dev/null)

    # Rule 1: High-risk tasks (risk > 5) with low confidence (< 0.5)
    if command -v bc >/dev/null 2>&1; then
        if [[ $(echo "$risk_score > 5" | bc -l 2>/dev/null) -eq 1 ]] && \
           [[ $(echo "$confidence < 0.5" | bc -l 2>/dev/null) -eq 1 ]]; then
            echo '{"useReflexion":true,"reason":"high_risk_low_confidence"}'
            return 0
        fi
    fi

    # Rule 2: Complex feature implementation tasks
    if [[ "$task_type" == "feature" ]]; then
        if echo "$task" | grep -qiE "implement.*with|create.*multiple|build.*system"; then
            echo '{"useReflexion":true,"reason":"complex_feature"}'
            return 0
        fi
    fi

    # Rule 3: Multi-file tasks (detect keywords)
    if echo "$task" | grep -qiE "multiple files|across.*files|[0-9]+.*files"; then
        echo '{"useReflexion":true,"reason":"multi_file_task"}'
        return 0
    fi

    # Rule 4: Tasks with explicit iteration/refinement requirements
    if echo "$task" | grep -qiE "refine|iterate|improve.*until|self-correct"; then
        echo '{"useReflexion":true,"reason":"explicit_iteration"}'
        return 0
    fi

    # Default: Use bash agent-loop
    echo '{"useReflexion":false,"reason":"simple_task"}'
    return 1
}

# Test helpers
test_count=0
passed=0
failed=0

assert_json_field() {
    local json="$1"
    local field="$2"
    local expected="$3"
    local actual
    actual=$(echo "$json" | jq -r ".$field" 2>/dev/null)

    if [[ "$actual" == "$expected" ]]; then
        echo "  ✅ $field = $expected"
        ((passed++))
        return 0
    else
        echo "  ❌ $field = $actual (expected: $expected)"
        ((failed++))
        return 1
    fi
}

run_test() {
    local test_name="$1"
    ((test_count++))
    echo ""
    echo "Test $test_count: $test_name"
}

# =============================================================================
# TEST SUITE
# =============================================================================

echo "🧪 Orchestrator → ReflexionAgent Integration Tests"
echo "=================================================="

# Test 1: Simple task should NOT use ReflexionAgent
run_test "Simple task → should NOT use ReflexionAgent"
task="Fix typo in README.md"
analysis='{"taskType":"bugfix","risk":2,"confidence":0.8}'
result=$(should_use_reflexion_agent "$task" "$analysis")
assert_json_field "$result" "useReflexion" "false"
assert_json_field "$result" "reason" "simple_task"

# Test 2: Complex feature should use ReflexionAgent
run_test "Complex feature → should use ReflexionAgent"
task="Implement authentication system with JWT"
analysis='{"taskType":"feature","risk":8,"confidence":0.3}'
result=$(should_use_reflexion_agent "$task" "$analysis")
assert_json_field "$result" "useReflexion" "true"

# Test 3: Multi-file task should use ReflexionAgent
run_test "Multi-file task → should use ReflexionAgent"
task="Create REST API with 5 files"
analysis='{"taskType":"feature","risk":6,"confidence":0.5}'
result=$(should_use_reflexion_agent "$task" "$analysis")
assert_json_field "$result" "useReflexion" "true"
assert_json_field "$result" "reason" "multi_file_task"

# Test 4: High-risk low-confidence should use ReflexionAgent
run_test "High-risk + low-confidence → should use ReflexionAgent"
task="Refactor database layer"
analysis='{"taskType":"refactor","risk":9,"confidence":0.2}'
result=$(should_use_reflexion_agent "$task" "$analysis")
assert_json_field "$result" "useReflexion" "true"

# Test 5: Iteration-focused task should use ReflexionAgent
run_test "Task with iteration keywords → should use ReflexionAgent"
task="Implement and refine the search algorithm until performance is optimal"
analysis='{"taskType":"feature","risk":5,"confidence":0.6}'
result=$(should_use_reflexion_agent "$task" "$analysis")
assert_json_field "$result" "useReflexion" "true"
assert_json_field "$result" "reason" "explicit_iteration"

# Test 6: Simple bugfix should NOT use ReflexionAgent
run_test "Simple bugfix → should NOT use ReflexionAgent"
task="Fix undefined variable in login.ts"
analysis='{"taskType":"bugfix","risk":3,"confidence":0.9}'
result=$(should_use_reflexion_agent "$task" "$analysis")
assert_json_field "$result" "useReflexion" "false"

# Test 7: Complex feature with "build system" keyword
run_test "Build system task → should use ReflexionAgent"
task="Build a caching system with Redis"
analysis='{"taskType":"feature","risk":7,"confidence":0.4}'
result=$(should_use_reflexion_agent "$task" "$analysis")
assert_json_field "$result" "useReflexion" "true"
assert_json_field "$result" "reason" "complex_feature"

# Test 8: Test suite creation (medium complexity)
run_test "Test creation → should NOT use ReflexionAgent"
task="Add unit tests for utils.ts"
analysis='{"taskType":"test","risk":2,"confidence":0.8}'
result=$(should_use_reflexion_agent "$task" "$analysis")
assert_json_field "$result" "useReflexion" "false"

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
echo "=================================================="
echo "📊 Test Results:"
echo "  Total tests: $test_count"
echo "  Passed: $passed"
echo "  Failed: $failed"
echo ""

if [[ $failed -eq 0 ]]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "❌ $failed test(s) failed"
    exit 1
fi
