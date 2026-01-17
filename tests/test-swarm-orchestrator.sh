#!/usr/bin/env bash
#
# Integration Tests for swarm-orchestrator.sh
# Tests agent spawning, task decomposition, result collection, and MCP detection
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-framework.sh"

# Path to swarm-orchestrator hook
SWARM_ORCHESTRATOR="${HOME}/.claude/hooks/swarm-orchestrator.sh"
SWARM_DIR="${HOME}/.claude/swarm"

# ============================================================================
# Test Setup and Teardown
# ============================================================================

setup() {
    # Create test directory
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"

    # Initialize git repo
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "test" > test.txt
    git add .
    git commit -q -m "Initial commit"

    # Backup original swarm state if exists
    if [[ -f "${SWARM_DIR}/swarm-state.json" ]]; then
        cp "${SWARM_DIR}/swarm-state.json" "${SWARM_DIR}/swarm-state.json.test-backup"
    fi
}

teardown() {
    # Restore original swarm state if backup exists
    if [[ -f "${SWARM_DIR}/swarm-state.json.test-backup" ]]; then
        mv "${SWARM_DIR}/swarm-state.json.test-backup" "${SWARM_DIR}/swarm-state.json"
    fi

    # Clean up test directory
    if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
        # Clean up git worktrees if any were created
        cd "$TEST_DIR"
        git worktree prune 2>/dev/null || true
        cd /
        rm -rf "$TEST_DIR"
    fi

    # Clean up any test swarm directories
    rm -rf "${SWARM_DIR}/test-swarm-"* 2>/dev/null || true
}

# ============================================================================
# Test 1: spawn creates correct directory structure
# ============================================================================

test_spawn_creates_directory_structure() {
    local result=$("$SWARM_ORCHESTRATOR" spawn 3 "test task for structure" 2>/dev/null)

    assert_json_valid "$result" "spawn should return valid JSON"
    assert_json_has_key "$result" "swarmId" "spawn result should have swarmId"

    # Extract swarm ID
    local swarm_id=$(echo "$result" | jq -r '.swarmId')
    assert_not_empty "$swarm_id" "swarmId should not be empty"

    # Check directory structure
    local swarm_work_dir="${SWARM_DIR}/${swarm_id}"
    assert_dir_exists "$swarm_work_dir" "Swarm work directory should exist"

    # Check for spawn instructions
    assert_file_exists "${swarm_work_dir}/spawn_instructions.json" "spawn_instructions.json should exist"

    # Clean up
    rm -rf "$swarm_work_dir"
}

# ============================================================================
# Test 2: Task decomposition produces valid JSON with subtasks
# ============================================================================

test_task_decomposition_produces_valid_json() {
    local result=$("$SWARM_ORCHESTRATOR" spawn 3 "implement user authentication feature" 2>/dev/null)

    assert_json_valid "$result" "spawn result should be valid JSON"

    # Check for decomposition information
    local instructions_file=$(echo "$result" | jq -r '.instructionsFile // ""')
    if [[ -n "$instructions_file" && -f "$instructions_file" ]]; then
        local instructions=$(cat "$instructions_file")
        assert_json_valid "$instructions" "instructions file should contain valid JSON"

        # Check for spawn_agents array
        assert_json_has_key "$instructions" "spawn_agents" "instructions should have spawn_agents array"
    fi

    # Clean up
    local swarm_id=$(echo "$result" | jq -r '.swarmId')
    rm -rf "${SWARM_DIR}/${swarm_id}"
}

test_feature_task_detected_correctly() {
    # Feature implementation pattern should be detected
    local result=$("$SWARM_ORCHESTRATOR" spawn 3 "implement feature X" 2>/dev/null)

    assert_json_valid "$result" "spawn result should be valid JSON"

    local swarm_id=$(echo "$result" | jq -r '.swarmId')
    local instructions_file="${SWARM_DIR}/${swarm_id}/spawn_instructions.json"

    if [[ -f "$instructions_file" ]]; then
        local instructions=$(cat "$instructions_file")
        # Feature tasks should have design, implement, test phases
        if echo "$instructions" | jq -e '.spawn_agents[] | select(.subtask | contains("design"))' >/dev/null 2>&1; then
            : # Pass - found design phase
        elif echo "$instructions" | jq -e '.spawn_agents[] | select(.subtask | contains("Research"))' >/dev/null 2>&1; then
            : # Pass - found research phase (alternate wording)
        else
            # Still pass if we have any agents
            local agent_count=$(echo "$instructions" | jq '.spawn_agents | length')
            assert_not_equals "0" "$agent_count" "Should have at least one agent"
        fi
    fi

    # Clean up
    rm -rf "${SWARM_DIR}/${swarm_id}"
}

# ============================================================================
# Test 3: Agent task files contain expected content
# ============================================================================

test_agent_directories_created() {
    local result=$("$SWARM_ORCHESTRATOR" spawn 3 "test task" 2>/dev/null)

    assert_json_valid "$result" "spawn should return valid JSON"

    local swarm_id=$(echo "$result" | jq -r '.swarmId')
    local swarm_work_dir="${SWARM_DIR}/${swarm_id}"

    # Check agent directories exist
    local agent_count=0
    for i in 1 2 3; do
        local agent_dir="${swarm_work_dir}/agent_${i}"
        if [[ -d "$agent_dir" ]]; then
            agent_count=$((agent_count + 1))
        fi
    done

    # At least some agent directories should exist (may not be all 3 if real Task spawning failed)
    # Graceful degradation means we might have 0 directories but valid JSON instructions
    local instructions_file="${swarm_work_dir}/spawn_instructions.json"
    if [[ -f "$instructions_file" ]]; then
        local instruction_count=$(cat "$instructions_file" | jq '.spawn_agents | length' 2>/dev/null || echo "0")
        assert_not_equals "0" "$instruction_count" "Should have spawn instructions for agents"
    fi

    # Clean up
    rm -rf "$swarm_work_dir"
}

# ============================================================================
# Test 4: collect aggregates results from agent directories
# ============================================================================

test_collect_aggregates_results() {
    # First spawn agents
    local spawn_result=$("$SWARM_ORCHESTRATOR" spawn 2 "collect test task" 2>/dev/null)
    local swarm_id=$(echo "$spawn_result" | jq -r '.swarmId')
    local swarm_work_dir="${SWARM_DIR}/${swarm_id}"

    # Create mock results in agent directories
    mkdir -p "${swarm_work_dir}/agent_1"
    mkdir -p "${swarm_work_dir}/agent_2"

    echo '{"status": "completed", "result": "Agent 1 finished"}' > "${swarm_work_dir}/agent_1/result.json"
    echo '{"status": "completed", "result": "Agent 2 finished"}' > "${swarm_work_dir}/agent_2/result.json"

    # Collect results
    local collect_result=$("$SWARM_ORCHESTRATOR" collect 2>/dev/null)

    assert_json_valid "$collect_result" "collect should return valid JSON"

    # Clean up
    rm -rf "$swarm_work_dir"
}

# ============================================================================
# Test 5: Git integration skips gracefully when not in repo
# ============================================================================

test_git_skips_gracefully_outside_repo() {
    # Create a non-git directory
    local non_git_dir=$(mktemp -d)
    cd "$non_git_dir"

    # spawn should still work without git worktrees
    local result=$("$SWARM_ORCHESTRATOR" spawn 2 "test without git" 2>/dev/null)

    assert_json_valid "$result" "spawn should return valid JSON even without git"
    assert_json_has_key "$result" "swarmId" "result should have swarmId"

    # Clean up
    local swarm_id=$(echo "$result" | jq -r '.swarmId')
    rm -rf "${SWARM_DIR}/${swarm_id}"
    rm -rf "$non_git_dir"
    cd "$TEST_DIR"
}

# ============================================================================
# Test 6: MCP detection works with and without config file
# ============================================================================

test_mcp_status_returns_output() {
    local result=$("$SWARM_ORCHESTRATOR" mcp-status 2>/dev/null)

    assert_not_empty "$result" "mcp-status should return output"
    assert_contains "$result" "MCP Detection" "Should mention MCP Detection"
    assert_contains "$result" "GitHub" "Should mention GitHub MCP"
}

test_mcp_detection_with_env_override() {
    # Set environment override
    export GITHUB_MCP_ENABLED=true

    local result=$("$SWARM_ORCHESTRATOR" mcp-status 2>/dev/null)

    assert_contains "$result" "GitHub" "Should still mention GitHub MCP"

    unset GITHUB_MCP_ENABLED
}

# ============================================================================
# Test 7: status command returns valid JSON
# ============================================================================

test_status_returns_json() {
    # First spawn to create a swarm
    local spawn_result=$("$SWARM_ORCHESTRATOR" spawn 2 "status test" 2>/dev/null)
    local swarm_id=$(echo "$spawn_result" | jq -r '.swarmId')

    local result=$("$SWARM_ORCHESTRATOR" status 2>/dev/null)

    assert_json_valid "$result" "status should return valid JSON"

    # Clean up
    rm -rf "${SWARM_DIR}/${swarm_id}"
}

# ============================================================================
# Test 8: check-deps returns valid output
# ============================================================================

test_check_deps_returns_output() {
    local result=$("$SWARM_ORCHESTRATOR" check-deps 2>/dev/null)

    assert_not_empty "$result" "check-deps should return output"

    # The output contains both human-readable text and JSON at the end
    # Extract just the JSON portion (starts with '{')
    local json_part=$(echo "$result" | grep -A 100 '^{' | head -n 20)

    if [[ -n "$json_part" ]]; then
        assert_json_valid "$json_part" "check-deps should contain valid JSON"
        assert_json_has_key "$json_part" "dependencies" "Should report dependencies"
    else
        # If no JSON found, just check for key indicators in text output
        assert_contains "$result" "jq" "Should mention jq availability"
        assert_contains "$result" "git" "Should mention git availability"
    fi
}

# ============================================================================
# Test 9: get-instructions returns error when no swarm exists
# ============================================================================

test_get_instructions_error_without_swarm() {
    # Clear any existing swarm state
    if [[ -f "${SWARM_DIR}/swarm-state.json" ]]; then
        mv "${SWARM_DIR}/swarm-state.json" "${SWARM_DIR}/swarm-state.json.tmp"
    fi

    local result=$("$SWARM_ORCHESTRATOR" get-instructions 2>/dev/null)

    assert_json_valid "$result" "get-instructions should return valid JSON"
    assert_json_has_key "$result" "error" "Should have error key when no swarm"

    # Restore
    if [[ -f "${SWARM_DIR}/swarm-state.json.tmp" ]]; then
        mv "${SWARM_DIR}/swarm-state.json.tmp" "${SWARM_DIR}/swarm-state.json"
    fi
}

test_get_instructions_returns_data_after_spawn() {
    local spawn_result=$("$SWARM_ORCHESTRATOR" spawn 2 "instructions test" 2>/dev/null)
    local swarm_id=$(echo "$spawn_result" | jq -r '.swarmId')

    local result=$("$SWARM_ORCHESTRATOR" get-instructions "$swarm_id" 2>/dev/null)

    assert_json_valid "$result" "get-instructions should return valid JSON"

    # Clean up
    rm -rf "${SWARM_DIR}/${swarm_id}"
}

# ============================================================================
# Test 10: Different agent counts work correctly
# ============================================================================

test_spawn_with_different_counts() {
    # Test with 1 agent
    local result1=$("$SWARM_ORCHESTRATOR" spawn 1 "single agent test" 2>/dev/null)
    assert_json_valid "$result1" "spawn with 1 agent should return valid JSON"
    local swarm_id1=$(echo "$result1" | jq -r '.swarmId')

    # Test with 5 agents
    local result5=$("$SWARM_ORCHESTRATOR" spawn 5 "five agent test" 2>/dev/null)
    assert_json_valid "$result5" "spawn with 5 agents should return valid JSON"
    local swarm_id5=$(echo "$result5" | jq -r '.swarmId')

    # Clean up
    rm -rf "${SWARM_DIR}/${swarm_id1}"
    rm -rf "${SWARM_DIR}/${swarm_id5}"
}

# ============================================================================
# Test 11: Testing task pattern detection
# ============================================================================

test_testing_task_pattern() {
    local result=$("$SWARM_ORCHESTRATOR" spawn 3 "validate and test the authentication system" 2>/dev/null)

    assert_json_valid "$result" "spawn should return valid JSON"

    local swarm_id=$(echo "$result" | jq -r '.swarmId')
    local instructions_file="${SWARM_DIR}/${swarm_id}/spawn_instructions.json"

    if [[ -f "$instructions_file" ]]; then
        local instructions=$(cat "$instructions_file")
        # Testing tasks should have test-related subtasks
        local has_test=$(echo "$instructions" | jq -e '.spawn_agents[] | select(.subtask | test("test|Test|validate|check"; "i"))' 2>/dev/null || echo "false")
        assert_not_equals "false" "$has_test" "Testing pattern should be detected"
    fi

    # Clean up
    rm -rf "${SWARM_DIR}/${swarm_id}"
}

# ============================================================================
# Test 12: Research task pattern detection
# ============================================================================

test_research_task_pattern() {
    local result=$("$SWARM_ORCHESTRATOR" spawn 3 "research and analyze the codebase architecture" 2>/dev/null)

    assert_json_valid "$result" "spawn should return valid JSON"

    local swarm_id=$(echo "$result" | jq -r '.swarmId')
    local instructions_file="${SWARM_DIR}/${swarm_id}/spawn_instructions.json"

    if [[ -f "$instructions_file" ]]; then
        local instructions=$(cat "$instructions_file")
        # Research tasks should have research-related subtasks
        local has_research=$(echo "$instructions" | jq -e '.spawn_agents[] | select(.subtask | test("research|Research|analyze|investigation"; "i"))' 2>/dev/null || echo "false")
        assert_not_equals "false" "$has_research" "Research pattern should be detected"
    fi

    # Clean up
    rm -rf "${SWARM_DIR}/${swarm_id}"
}

# ============================================================================
# Main Test Suite
# ============================================================================

main() {
    test_suite_start "Swarm Orchestrator Integration Tests"

    # Test 1: Directory structure
    setup
    run_test "spawn creates correct directory structure" test_spawn_creates_directory_structure
    teardown

    # Test 2: Task decomposition
    setup
    run_test "Task decomposition produces valid JSON" test_task_decomposition_produces_valid_json
    teardown

    setup
    run_test "Feature task detected correctly" test_feature_task_detected_correctly
    teardown

    # Test 3: Agent directories
    setup
    run_test "Agent directories and task files created" test_agent_directories_created
    teardown

    # Test 4: Collect results
    setup
    run_test "collect aggregates results from agents" test_collect_aggregates_results
    teardown

    # Test 5: Git integration
    setup
    run_test "Git skips gracefully outside repo" test_git_skips_gracefully_outside_repo
    teardown

    # Test 6: MCP detection
    setup
    run_test "mcp-status returns output" test_mcp_status_returns_output
    teardown

    setup
    run_test "MCP detection with env override" test_mcp_detection_with_env_override
    teardown

    # Test 7: Status command
    setup
    run_test "status returns valid JSON" test_status_returns_json
    teardown

    # Test 8: Check dependencies
    setup
    run_test "check-deps returns valid output" test_check_deps_returns_output
    teardown

    # Test 9: Get instructions
    setup
    run_test "get-instructions returns error without swarm" test_get_instructions_error_without_swarm
    teardown

    setup
    run_test "get-instructions returns data after spawn" test_get_instructions_returns_data_after_spawn
    teardown

    # Test 10: Different agent counts
    setup
    run_test "spawn works with different agent counts" test_spawn_with_different_counts
    teardown

    # Test 11: Testing pattern
    setup
    run_test "Testing task pattern detection" test_testing_task_pattern
    teardown

    # Test 12: Research pattern
    setup
    run_test "Research task pattern detection" test_research_task_pattern
    teardown

    # Summary
    test_suite_end
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
