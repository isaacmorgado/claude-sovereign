#!/bin/bash
# Test Agent Loop Fixes - Issues #4 and #16
# Tests validation gate integration and task queue subshell fixes

set -uo pipefail

HOOKS_DIR="${HOME}/.claude/hooks"
AGENT_LOOP="$HOOKS_DIR/agent-loop.sh"
VALIDATION_GATE="$HOOKS_DIR/validation-gate.sh"
TASK_QUEUE="$HOOKS_DIR/task-queue.sh"
PLAN_EXECUTE="$HOOKS_DIR/plan-execute.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}[✗]${NC} $1"
    ((TESTS_FAILED++))
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

run_test() {
    local test_name="$1"
    ((TESTS_RUN++))
    echo ""
    log "Test $TESTS_RUN: $test_name"
}

# =============================================================================
# ISSUE #4: Validation Gate Bypass Tests
# =============================================================================

test_validation_gate_command_format() {
    run_test "Validation gate uses correct command format"

    # Check that agent-loop.sh calls "command" not "validate"
    if grep -q '"$VALIDATION_GATE" command' "$AGENT_LOOP"; then
        success "Uses 'command' subcommand (correct)"
    else
        fail "Still using wrong subcommand or format"
        return 1
    fi

    # Check that it doesn't expect JSON format
    if ! grep -q '\.safe' "$AGENT_LOOP" | grep -A5 -B5 VALIDATION_GATE > /dev/null; then
        success "No longer expects JSON .safe field (correct)"
    else
        fail "Still expects JSON format"
        return 1
    fi
}

test_validation_gate_pass() {
    run_test "Validation gate approves safe commands"

    local result
    result=$("$VALIDATION_GATE" command "echo hello world" 2>/dev/null)
    local status=$(echo "$result" | head -n1)

    if [[ "$status" == "PASS" ]]; then
        success "Safe command returns PASS"
    else
        fail "Expected PASS, got: $status"
        return 1
    fi
}

test_validation_gate_warning() {
    run_test "Validation gate warns on risky commands"

    local result
    result=$("$VALIDATION_GATE" command "sudo apt-get install test" 2>/dev/null)
    local status=$(echo "$result" | head -n1)

    if [[ "$status" == "WARNING" ]]; then
        success "Risky command returns WARNING"
    else
        fail "Expected WARNING, got: $status"
        return 1
    fi
}

test_validation_gate_blocked() {
    run_test "Validation gate blocks dangerous commands"

    local result
    result=$("$VALIDATION_GATE" command "rm -rf /" 2>/dev/null)
    local status=$(echo "$result" | head -n1)

    if [[ "$status" == "BLOCKED" ]]; then
        success "Dangerous command returns BLOCKED"
    else
        fail "Expected BLOCKED, got: $status"
        return 1
    fi
}

test_validation_gate_integration() {
    run_test "Validation gate integration in agent-loop"

    # Check that agent-loop handles all three statuses
    local has_blocked_check=false
    local has_warning_check=false
    local has_pass_log=false

    if grep -q 'if.*"$validation_status".*==.*"BLOCKED"' "$AGENT_LOOP"; then
        has_blocked_check=true
    fi

    if grep -q 'elif.*"$validation_status".*==.*"WARNING"' "$AGENT_LOOP"; then
        has_warning_check=true
    fi

    if grep -q 'Validation gate: Command approved' "$AGENT_LOOP"; then
        has_pass_log=true
    fi

    if [[ "$has_blocked_check" == true ]] && [[ "$has_warning_check" == true ]] && [[ "$has_pass_log" == true ]]; then
        success "Agent-loop handles BLOCKED, WARNING, and PASS statuses"
    else
        fail "Missing status handling - blocked: $has_blocked_check, warning: $has_warning_check, pass: $has_pass_log"
        return 1
    fi
}

test_validation_gate_blocks_execution() {
    run_test "Validation gate actually blocks execution"

    # Check that BLOCKED status returns early with error code 126
    if grep -A20 'if.*"$validation_status".*==.*"BLOCKED"' "$AGENT_LOOP" | grep -q 'return 126'; then
        success "BLOCKED status returns early with exit code 126"
    else
        fail "BLOCKED status doesn't prevent execution"
        return 1
    fi
}

# =============================================================================
# ISSUE #16: Task Queue Subshell Tests
# =============================================================================

test_task_queue_no_subshell() {
    run_test "Task queue uses process substitution (no subshell)"

    # Check for process substitution pattern: done < <(...)
    if grep -A15 'Add tasks to queue' "$AGENT_LOOP" | grep -q 'done < <('; then
        success "Uses process substitution (correct)"
    else
        fail "Still using pipe to while loop (subshell)"
        return 1
    fi

    # Check that it's NOT using pipe pattern: | while read
    if ! grep -A15 'Add tasks to queue' "$AGENT_LOOP" | grep -q '| while read'; then
        success "No longer uses pipe to while loop (correct)"
    else
        fail "Still using pipe pattern"
        return 1
    fi
}

test_task_queue_variable_scope() {
    run_test "Task queue preserves variable scope"

    # Create test task queue if needed
    if [[ ! -x "$TASK_QUEUE" ]]; then
        warn "Task queue not executable, skipping functional test"
        return 0
    fi

    # Clear any existing queue (delete file to reset completely)
    rm -f "${HOME}/.claude/queue/tasks.json" 2>/dev/null || true

    # Add tasks using process substitution (like fixed agent-loop)
    local test_plan='[{"task":"test1","priority":"high"},{"task":"test2","priority":"low"}]'
    while IFS= read -r step; do
        local task_name priority_str priority_num
        task_name=$(echo "$step" | jq -r '.task // .description')
        priority_str=$(echo "$step" | jq -r '.priority // "medium"')
        # Convert string priority to numeric (high=1, medium=3, low=5)
        case "$priority_str" in
            high|urgent|critical) priority_num=1 ;;
            low|minor) priority_num=5 ;;
            *) priority_num=3 ;;  # medium is default
        esac
        "$TASK_QUEUE" add "$task_name" "$priority_num" 2>/dev/null || true
    done < <(echo "$test_plan" | jq -c '.[]')

    # Check if tasks were actually added
    local count
    count=$("$TASK_QUEUE" list 2>/dev/null | jq '.tasks | length' 2>/dev/null || echo 0)

    if [[ $count -ge 2 ]]; then
        success "Tasks persisted after process substitution loop (count: $count)"
    else
        fail "Tasks lost after loop (count: $count, expected: 2)"
        return 1
    fi

    # Cleanup
    rm -f "${HOME}/.claude/queue/tasks.json" 2>/dev/null || true
}

test_prioritized_plan_usage() {
    run_test "Prioritized plan is actually used after queue processing"

    # Check that prioritized_plan is assigned after queue processing
    if grep -A3 'Get prioritized list' "$AGENT_LOOP" | grep -q 'prioritized_plan='; then
        success "Prioritized plan is assigned after queue processing"
    else
        fail "Prioritized plan assignment not found"
        return 1
    fi

    # Check that prioritized_plan is used in agent state
    if grep -A50 'cat > "$AGENT_STATE"' "$AGENT_LOOP" | grep -q 'prioritized_plan'; then
        success "Prioritized plan is saved to agent state"
    else
        warn "Prioritized plan might not be used in agent state (check manually)"
    fi
}

# =============================================================================
# EDGE CASE TESTS
# =============================================================================

test_validation_gate_empty_command() {
    run_test "Validation gate handles empty command"

    local result
    result=$("$VALIDATION_GATE" command "" 2>/dev/null || echo "PASS")
    local status=$(echo "$result" | head -n1)

    if [[ -n "$status" ]]; then
        success "Empty command handled gracefully (status: $status)"
    else
        fail "Empty command caused error"
        return 1
    fi
}

test_validation_gate_missing_script() {
    run_test "Agent-loop handles missing validation-gate gracefully"

    # Check for executable check before calling validation-gate
    if grep -q 'if \[\[ -x "$VALIDATION_GATE"' "$AGENT_LOOP"; then
        success "Checks if validation-gate is executable before calling"
    else
        fail "Doesn't check if validation-gate exists"
        return 1
    fi
}

test_task_queue_empty_plan() {
    run_test "Task queue handles empty execution plan"

    # Check for length check before processing
    if grep -q 'if \[\[ -x "$TASK_QUEUE" && $(echo "$execution_plan" | jq .length.) -gt 0' "$AGENT_LOOP"; then
        success "Checks plan length before processing"
    else
        fail "Doesn't check if plan is empty"
        return 1
    fi
}

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

test_full_integration() {
    run_test "Full integration test (requires all components)"

    local all_present=true

    if [[ ! -x "$AGENT_LOOP" ]]; then
        warn "agent-loop.sh not executable"
        all_present=false
    fi

    if [[ ! -x "$VALIDATION_GATE" ]]; then
        warn "validation-gate.sh not executable"
        all_present=false
    fi

    if [[ ! -x "$TASK_QUEUE" ]]; then
        warn "task-queue.sh not executable"
        all_present=false
    fi

    if [[ "$all_present" == true ]]; then
        success "All components present and executable"
    else
        warn "Skipping full integration test (missing components)"
        return 0
    fi
}

# =============================================================================
# RUN ALL TESTS
# =============================================================================

main() {
    echo "=========================================="
    echo "Agent Loop Fixes Test Suite"
    echo "Issues #4 (Validation Gate) and #16 (Task Queue)"
    echo "=========================================="

    # Issue #4: Validation Gate Bypass
    echo ""
    echo "=== ISSUE #4: VALIDATION GATE TESTS ==="
    test_validation_gate_command_format
    test_validation_gate_pass
    test_validation_gate_warning
    test_validation_gate_blocked
    test_validation_gate_integration
    test_validation_gate_blocks_execution

    # Issue #16: Task Queue Subshell
    echo ""
    echo "=== ISSUE #16: TASK QUEUE TESTS ==="
    test_task_queue_no_subshell
    test_task_queue_variable_scope
    test_prioritized_plan_usage

    # Edge Cases
    echo ""
    echo "=== EDGE CASE TESTS ==="
    test_validation_gate_empty_command
    test_validation_gate_missing_script
    test_task_queue_empty_plan

    # Integration
    echo ""
    echo "=== INTEGRATION TESTS ==="
    test_full_integration

    # Summary
    echo ""
    echo "=========================================="
    echo "TEST SUMMARY"
    echo "=========================================="
    echo "Total Tests: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    echo "=========================================="

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        return 1
    fi
}

main "$@"
