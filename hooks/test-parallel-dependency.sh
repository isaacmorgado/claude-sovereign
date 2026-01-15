#!/bin/bash
# Comprehensive tests for parallel execution planner and dependency tracking
# Tests Issues #3 and #10 from audit

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLANNER="$SCRIPT_DIR/parallel-execution-planner.sh"
SWARM="$SCRIPT_DIR/swarm-orchestrator.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_test() {
    echo -e "${YELLOW}TEST $TESTS_RUN:${NC} $1"
}

pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

run_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
}

# ============================================================================
# Test 1: Parallel Execution Planner - Multi-task Pattern
# ============================================================================
run_test
log_test "Parallel planner detects multi-task pattern (3+ groups)"

result=$("$PLANNER" analyze "Implement user authentication and admin panel and notification system" 2>/dev/null)
can_parallelize=$(echo "$result" | jq -r '.canParallelize')
group_count=$(echo "$result" | jq -r '.analysis.groupCount')
pattern=$(echo "$result" | jq -r '.analysis.pattern')

if [[ "$can_parallelize" == "true" ]] && [[ $group_count -ge 3 ]] && [[ "$pattern" == "multi_task" ]]; then
    pass "Multi-task pattern detected: $group_count groups, can parallelize"
else
    fail "Expected canParallelize=true, groups>=3, pattern=multi_task; got: $can_parallelize, $group_count, $pattern"
fi

# ============================================================================
# Test 2: Parallel Execution Planner - Testing Pattern
# ============================================================================
run_test
log_test "Parallel planner detects testing pattern"

result=$("$PLANNER" analyze "Run comprehensive tests" 2>/dev/null)
can_parallelize=$(echo "$result" | jq -r '.canParallelize')
group_count=$(echo "$result" | jq -r '.analysis.groupCount')
pattern=$(echo "$result" | jq -r '.analysis.pattern')

if [[ "$can_parallelize" == "true" ]] && [[ $group_count -ge 3 ]] && [[ "$pattern" == "testing" ]]; then
    pass "Testing pattern detected: $group_count groups"
else
    fail "Expected testing pattern with 3+ groups; got: $pattern, $group_count groups"
fi

# ============================================================================
# Test 3: Parallel Execution Planner - Research Pattern
# ============================================================================
run_test
log_test "Parallel planner detects research pattern"

result=$("$PLANNER" analyze "Research security vulnerabilities" 2>/dev/null)
can_parallelize=$(echo "$result" | jq -r '.canParallelize')
group_count=$(echo "$result" | jq -r '.analysis.groupCount')
pattern=$(echo "$result" | jq -r '.analysis.pattern')

if [[ "$can_parallelize" == "true" ]] && [[ $group_count -ge 3 ]] && [[ "$pattern" == "research" ]]; then
    pass "Research pattern detected: $group_count groups"
else
    fail "Expected research pattern with 3+ groups; got: $pattern, $group_count groups"
fi

# ============================================================================
# Test 4: Parallel Execution Planner - Dependency Detection
# ============================================================================
run_test
log_test "Parallel planner detects dependencies (should NOT parallelize)"

result=$("$PLANNER" analyze "First implement auth, then add permissions" 2>/dev/null)
can_parallelize=$(echo "$result" | jq -r '.canParallelize')
has_deps=$(echo "$result" | jq -r '.analysis.hasDependencies')

if [[ "$can_parallelize" == "false" ]] && [[ "$has_deps" == "true" ]]; then
    pass "Dependencies detected correctly, parallelization disabled"
else
    fail "Expected canParallelize=false, hasDependencies=true; got: $can_parallelize, $has_deps"
fi

# ============================================================================
# Test 5: Parallel Execution Planner - Swarm Auto-spawn Threshold
# ============================================================================
run_test
log_test "Parallel planner recommends swarm for 3+ groups"

result=$("$PLANNER" analyze "Implement auth and admin and notifications and reports and analytics" 2>/dev/null)
group_count=$(echo "$result" | jq -r '.analysis.groupCount')
recommendations=$(echo "$result" | jq -r '.recommendations | join(" ")')

if [[ $group_count -ge 3 ]] && echo "$recommendations" | grep -q "swarm"; then
    pass "Swarm auto-spawn recommended for $group_count groups"
else
    fail "Expected swarm recommendation for 3+ groups; got: $group_count groups, recommendations: $recommendations"
fi

# ============================================================================
# Test 6: Swarm Orchestrator - Task Decomposition with Dependencies
# ============================================================================
run_test
log_test "Swarm orchestrator creates task decomposition"

# Clean up any existing swarm state
rm -f ~/.claude/swarm/swarm-state.json 2>/dev/null

decomposition=$("$SWARM" spawn 3 "Implement user authentication" 2>/dev/null | tail -1)
if [[ -n "$decomposition" ]] && [[ "$decomposition" =~ swarm_ ]]; then
    pass "Swarm spawned successfully: $decomposition"
    SWARM_ID="$decomposition"
else
    fail "Swarm spawn failed; expected swarm_<id>, got: $decomposition"
    SWARM_ID=""
fi

# ============================================================================
# Test 7: Swarm Orchestrator - Dependency Information in Decomposition
# ============================================================================
run_test
log_test "Swarm decomposition includes dependency information"

if [[ -n "$SWARM_ID" ]] && [[ -f ~/.claude/swarm/swarm-state.json ]]; then
    subtasks=$(jq -r '.decomposition.subtasks' ~/.claude/swarm/swarm-state.json 2>/dev/null)
    dep_count=$(echo "$subtasks" | jq '[.[] | select(.dependencies | length > 0)] | length' 2>/dev/null || echo "0")

    if [[ -n "$subtasks" ]] && jq -e '.decomposition.subtasks[0].dependencies' ~/.claude/swarm/swarm-state.json >/dev/null 2>&1; then
        pass "Decomposition includes dependency arrays (found $dep_count agents with dependencies)"
    else
        fail "Decomposition missing dependency information"
    fi
else
    fail "No swarm state file found"
fi

# ============================================================================
# Test 8: Swarm Orchestrator - Agent Status Tracking
# ============================================================================
run_test
log_test "Swarm tracks agent status (spawning → running → completed)"

if [[ -f ~/.claude/swarm/swarm-state.json ]]; then
    # Wait briefly for agents to update status
    sleep 1

    running_count=$(jq '[.agents[] | select(.status == "running")] | length' ~/.claude/swarm/swarm-state.json 2>/dev/null || echo "0")
    completed_count=$(jq '[.agents[] | select(.status == "completed")] | length' ~/.claude/swarm/swarm-state.json 2>/dev/null || echo "0")

    if [[ $running_count -gt 0 ]] || [[ $completed_count -gt 0 ]]; then
        pass "Agent status tracking working: $running_count running, $completed_count completed"
    else
        fail "No agents in running or completed status"
    fi
else
    fail "No swarm state file found"
fi

# ============================================================================
# Test 9: Dependency Enforcement - Log Verification
# ============================================================================
run_test
log_test "Swarm logs show dependency-aware spawning"

if [[ -f ~/.claude/logs/swarm.log ]]; then
    if grep -q "Starting dependency-aware agent spawning" ~/.claude/logs/swarm.log; then
        pass "Dependency-aware spawning logged"
    else
        fail "Dependency-aware spawning not found in logs"
    fi
else
    fail "Swarm log file not found"
fi

# ============================================================================
# Test 10: Integration Test - Coordinator Auto-spawns Swarm
# ============================================================================
run_test
log_test "Integration: Verify planner output format for coordinator"

result=$("$PLANNER" analyze "Test API endpoints and UI components and database queries" 2>/dev/null)
can_parallelize=$(echo "$result" | jq -r '.canParallelize')
groups=$(echo "$result" | jq -r '.groups')
strategy=$(echo "$result" | jq -r '.strategy')

if [[ "$can_parallelize" == "true" ]] && [[ -n "$groups" ]] && [[ -n "$strategy" ]]; then
    pass "Planner output format correct for coordinator integration"
else
    fail "Planner output format invalid"
fi

# ============================================================================
# Test Summary
# ============================================================================
echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "Total tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
else
    echo -e "Failed: $TESTS_FAILED"
fi
echo "========================================="

# Cleanup
if [[ -n "${SWARM_ID:-}" ]]; then
    "$SWARM" terminate >/dev/null 2>&1 || true
fi

if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
else
    exit 0
fi
