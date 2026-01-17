#!/usr/bin/env bash
#
# Integration Tests for auto-continue.sh
# Tests context threshold detection, checkpoint signaling, and autonomous execution
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-framework.sh"

# Path to auto-continue hook
AUTO_CONTINUE="${HOME}/.claude/hooks/auto-continue.sh"

# ============================================================================
# Test Setup and Teardown
# ============================================================================

setup() {
    # Create test directory
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    mkdir -p .claude

    # Initialize git repo for git-aware tests
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "test" > test.txt
    git add .
    git commit -q -m "Initial commit"
}

teardown() {
    # Clean up test directory
    if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# ============================================================================
# Helper function to create mock hook input
# ============================================================================

create_hook_input() {
    local input_tokens="${1:-10000}"
    local context_size="${2:-200000}"
    local transcript_path="${3:-}"

    jq -n \
        --argjson input_tokens "$input_tokens" \
        --argjson context_size "$context_size" \
        --arg transcript_path "$transcript_path" \
        '{
            "context_window": {
                "context_window_size": $context_size,
                "current_usage": {
                    "input_tokens": $input_tokens,
                    "cache_creation_input_tokens": 0,
                    "cache_read_input_tokens": 0
                }
            },
            "transcript_path": $transcript_path
        }'
}

# Create transcript file with user message
create_transcript() {
    local message="$1"
    local file="${TEST_DIR}/transcript.json"

    cat > "$file" <<EOF
{"role":"user","message":{"content":[{"text":"$message"}]}}
EOF
    echo "$file"
}

# ============================================================================
# Test 1: Below threshold should exit 0 without blocking
# ============================================================================

test_below_threshold_exits_cleanly() {
    # 39% usage (below 40% threshold)
    local hook_input=$(create_hook_input 78000 200000)
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo "")

    # Below threshold should exit cleanly with no output
    assert_empty "$result" "Below threshold should produce no output (exit 0)"
}

# ============================================================================
# Test 2: At threshold should output JSON with "decision": "block"
# ============================================================================

test_at_threshold_blocks() {
    # 40% usage (at threshold)
    local hook_input=$(create_hook_input 80000 200000)
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null)

    assert_json_valid "$result" "At threshold should return valid JSON"
    assert_json_has_key "$result" "decision" "Result should have decision field"

    local decision=$(echo "$result" | jq -r '.decision')
    assert_equals "block" "$decision" "At threshold should block"
}

# ============================================================================
# Test 3: Above threshold (60%) should trigger checkpoint signal
# ============================================================================

test_above_threshold_triggers_checkpoint() {
    # 60% usage
    local hook_input=$(create_hook_input 120000 200000)
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null)

    assert_json_valid "$result" "Above threshold should return valid JSON"

    local decision=$(echo "$result" | jq -r '.decision')
    assert_equals "block" "$decision" "60% usage should block"

    # Should contain checkpoint instruction in reason
    local reason=$(echo "$result" | jq -r '.reason // ""')
    assert_not_empty "$reason" "Should have a reason/continuation prompt"
}

# ============================================================================
# Test 4: Stop words should allow normal exit
# ============================================================================

test_stop_words_allow_exit() {
    local transcript_file=$(create_transcript "Please stop")

    # 50% usage but with stop word
    local hook_input=$(create_hook_input 100000 200000 "$transcript_file")
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo "")

    # Stop word should cause early exit with no blocking
    assert_empty "$result" "Stop word should allow normal exit"
}

test_pause_word_allows_exit() {
    local transcript_file=$(create_transcript "pause for a moment")

    local hook_input=$(create_hook_input 100000 200000 "$transcript_file")
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo "")

    assert_empty "$result" "Pause word should allow normal exit"
}

test_quit_word_allows_exit() {
    local transcript_file=$(create_transcript "quit this session")

    local hook_input=$(create_hook_input 100000 200000 "$transcript_file")
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo "")

    assert_empty "$result" "Quit word should allow normal exit"
}

test_wait_word_allows_exit() {
    local transcript_file=$(create_transcript "wait a second")

    local hook_input=$(create_hook_input 100000 200000 "$transcript_file")
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo "")

    assert_empty "$result" "Wait word should allow normal exit"
}

test_hold_word_allows_exit() {
    local transcript_file=$(create_transcript "hold on please")

    local hook_input=$(create_hook_input 100000 200000 "$transcript_file")
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo "")

    assert_empty "$result" "Hold word should allow normal exit"
}

# ============================================================================
# Test 5: Disabled file should skip auto-continue
# ============================================================================

test_disabled_file_skips() {
    # Create disabled file
    touch .claude/auto-continue-disabled

    # 50% usage - would normally trigger
    local hook_input=$(create_hook_input 100000 200000)
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo "")

    assert_empty "$result" "Disabled file should skip auto-continue"

    # Clean up
    rm -f .claude/auto-continue-disabled
}

# ============================================================================
# Test 6: Custom threshold environment variable
# ============================================================================

test_custom_threshold_works() {
    # Set custom threshold to 30%
    export CLAUDE_CONTEXT_THRESHOLD=30

    # 35% usage - above custom threshold
    local hook_input=$(create_hook_input 70000 200000)
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null)

    assert_json_valid "$result" "Custom threshold should return valid JSON when exceeded"

    local decision=$(echo "$result" | jq -r '.decision')
    assert_equals "block" "$decision" "35% should block when threshold is 30%"

    # Clean up
    unset CLAUDE_CONTEXT_THRESHOLD
}

test_custom_high_threshold_allows_passage() {
    # Set custom threshold to 70%
    export CLAUDE_CONTEXT_THRESHOLD=70

    # 50% usage - below custom threshold
    local hook_input=$(create_hook_input 100000 200000)
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo "")

    assert_empty "$result" "50% should pass when threshold is 70%"

    # Clean up
    unset CLAUDE_CONTEXT_THRESHOLD
}

# ============================================================================
# Test 7: State file creation
# ============================================================================

test_state_file_created() {
    # 50% usage - triggers auto-continue
    local hook_input=$(create_hook_input 100000 200000)
    echo "$hook_input" | "$AUTO_CONTINUE" >/dev/null 2>/dev/null

    assert_file_exists ".claude/auto-continue.local.md" "State file should be created"

    # Verify state file contains iteration
    local state_content=$(cat .claude/auto-continue.local.md)
    assert_contains "$state_content" "iteration:" "State file should have iteration"
}

# ============================================================================
# Test 8: Null usage data allows stop
# ============================================================================

test_null_usage_allows_stop() {
    local hook_input='{"context_window": {"context_window_size": 200000, "current_usage": null}}'
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo "")

    assert_empty "$result" "Null usage data should allow stop"
}

# ============================================================================
# Test 9: Continuation prompt file created
# ============================================================================

test_continuation_prompt_file_created() {
    # 50% usage - triggers auto-continue
    local hook_input=$(create_hook_input 100000 200000)
    echo "$hook_input" | "$AUTO_CONTINUE" >/dev/null 2>/dev/null

    assert_file_exists "${HOME}/.claude/continuation-prompt.md" "Continuation prompt file should be created"
}

# ============================================================================
# Test 10: JSON output structure
# ============================================================================

test_json_output_has_required_fields() {
    # 50% usage - triggers auto-continue
    local hook_input=$(create_hook_input 100000 200000)
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null)

    assert_json_valid "$result" "Output should be valid JSON"
    assert_json_has_key "$result" "decision" "Output should have decision field"
    assert_json_has_key "$result" "reason" "Output should have reason field"
    assert_json_has_key "$result" "systemMessage" "Output should have systemMessage field"
}

# ============================================================================
# Test 11: Iteration increments on subsequent runs
# ============================================================================

test_iteration_increments() {
    # First run
    local hook_input=$(create_hook_input 100000 200000)
    echo "$hook_input" | "$AUTO_CONTINUE" >/dev/null 2>/dev/null

    local first_iteration=$(grep 'iteration:' .claude/auto-continue.local.md | sed 's/.*: *//')

    # Second run
    echo "$hook_input" | "$AUTO_CONTINUE" >/dev/null 2>/dev/null

    local second_iteration=$(grep 'iteration:' .claude/auto-continue.local.md | sed 's/.*: *//')

    assert_equals "$((first_iteration + 1))" "$second_iteration" "Iteration should increment"
}

# ============================================================================
# Test 12: High usage (90%) correctly calculated
# ============================================================================

test_high_usage_percentage() {
    # 90% usage
    local hook_input=$(create_hook_input 180000 200000)
    local result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null)

    assert_json_valid "$result" "High usage should return valid JSON"

    # Check system message mentions percentage
    local sys_msg=$(echo "$result" | jq -r '.systemMessage // ""')
    assert_contains "$sys_msg" "90" "System message should mention 90%"
}

# ============================================================================
# Main Test Suite
# ============================================================================

main() {
    test_suite_start "Auto-Continue Integration Tests"

    # Test 1: Below threshold
    setup
    run_test "Below threshold (39%) exits cleanly" test_below_threshold_exits_cleanly
    teardown

    # Test 2: At threshold
    setup
    run_test "At threshold (40%) outputs blocking JSON" test_at_threshold_blocks
    teardown

    # Test 3: Above threshold
    setup
    run_test "Above threshold (60%) triggers checkpoint" test_above_threshold_triggers_checkpoint
    teardown

    # Test 4: Stop words
    setup
    run_test "Stop word 'stop' allows exit" test_stop_words_allow_exit
    teardown

    setup
    run_test "Stop word 'pause' allows exit" test_pause_word_allows_exit
    teardown

    setup
    run_test "Stop word 'quit' allows exit" test_quit_word_allows_exit
    teardown

    setup
    run_test "Stop word 'wait' allows exit" test_wait_word_allows_exit
    teardown

    setup
    run_test "Stop word 'hold' allows exit" test_hold_word_allows_exit
    teardown

    # Test 5: Disabled file
    setup
    run_test "Disabled file skips auto-continue" test_disabled_file_skips
    teardown

    # Test 6: Custom threshold
    setup
    run_test "Custom threshold 30% triggers at 35%" test_custom_threshold_works
    teardown

    setup
    run_test "Custom threshold 70% allows 50%" test_custom_high_threshold_allows_passage
    teardown

    # Test 7: State file
    setup
    run_test "State file created on trigger" test_state_file_created
    teardown

    # Test 8: Null usage
    setup
    run_test "Null usage data allows stop" test_null_usage_allows_stop
    teardown

    # Test 9: Continuation prompt
    setup
    run_test "Continuation prompt file created" test_continuation_prompt_file_created
    teardown

    # Test 10: JSON structure
    setup
    run_test "JSON output has required fields" test_json_output_has_required_fields
    teardown

    # Test 11: Iteration
    setup
    run_test "Iteration increments on subsequent runs" test_iteration_increments
    teardown

    # Test 12: High usage
    setup
    run_test "High usage (90%) correctly calculated" test_high_usage_percentage
    teardown

    # Summary
    test_suite_end
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
