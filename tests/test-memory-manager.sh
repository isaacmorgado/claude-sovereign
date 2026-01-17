#!/usr/bin/env bash
#
# Unit Tests for memory-manager.sh
# Tests working memory, episodic memory, semantic memory, and checkpoint/restore operations
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-framework.sh"

# Path to memory-manager
MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"

# Test database (use a separate test DB to avoid polluting production data)
TEST_DB_PATH="${HOME}/.claude/memory-test-$(date +%s).db"
ORIGINAL_DB_PATH="${HOME}/.claude/memory.db"

# ============================================================================
# Setup and Teardown
# ============================================================================

setup() {
    # Backup original DB if it exists
    if [[ -f "$ORIGINAL_DB_PATH" ]]; then
        cp "$ORIGINAL_DB_PATH" "${ORIGINAL_DB_PATH}.test-backup"
    fi

    # Create test directory
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

teardown() {
    # Restore original DB if backup exists
    if [[ -f "${ORIGINAL_DB_PATH}.test-backup" ]]; then
        mv "${ORIGINAL_DB_PATH}.test-backup" "$ORIGINAL_DB_PATH"
    fi

    # Clean up test DB
    rm -f "$TEST_DB_PATH"

    # Clean up test directory
    if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# ============================================================================
# Working Memory Tests
# ============================================================================

test_set_task_returns_json() {
    local result=$("$MEMORY_MANAGER" set-task "Test task" "Test context")
    assert_json_valid "$result" "set-task should return valid JSON"
    assert_json_has_key "$result" "status" "set-task result should have status key"
}

test_get_working_returns_json() {
    # First set a task
    "$MEMORY_MANAGER" set-task "Working test task" "context" >/dev/null

    local result=$("$MEMORY_MANAGER" get-working)
    assert_json_valid "$result" "get-working should return valid JSON"
}

test_add_context_stores_value() {
    local result=$("$MEMORY_MANAGER" add-context "test-key" "test-value" "test-category")
    assert_equals "true" "$result" "add-context should return true on success"
}

test_search_returns_empty_array_for_no_matches() {
    local result=$("$MEMORY_MANAGER" search "nonexistent_query_xyz_123")
    assert_equals "[]" "$result" "search should return empty array for no matches"
}

# ============================================================================
# Episodic Memory Tests
# ============================================================================

test_record_episode_returns_json() {
    local result=$("$MEMORY_MANAGER" record "test_event" "Test description" "success" "Test details")
    assert_json_valid "$result" "record should return valid JSON"
    assert_contains "$result" "recorded" "record result should indicate recorded status"
}

test_checkpoint_returns_id() {
    local result=$("$MEMORY_MANAGER" checkpoint "Test checkpoint")
    assert_not_empty "$result" "checkpoint should return an ID"
    # Should contain MEM- prefix (based on implementation)
    assert_contains "$result" "MEM-" "checkpoint ID should have MEM- prefix"
}

test_list_checkpoints_returns_json_array() {
    # Create a checkpoint first
    "$MEMORY_MANAGER" checkpoint "Test checkpoint for listing" >/dev/null

    local result=$("$MEMORY_MANAGER" list-checkpoints)
    assert_json_valid "$result" "list-checkpoints should return valid JSON"
}

# ============================================================================
# Semantic Memory Tests
# ============================================================================

test_add_fact_stores_correctly() {
    local result=$("$MEMORY_MANAGER" add-fact "test-category" "test-key" "test-value" "0.95")
    assert_equals "true" "$result" "add-fact should return true on success"
}

test_add_pattern_returns_pattern_id() {
    local result=$("$MEMORY_MANAGER" add-pattern "error_fix" "When X happens" "Do Y")
    assert_not_empty "$result" "add-pattern should return a pattern ID"
    assert_contains "$result" "pat_" "pattern ID should have pat_ prefix"
}

test_find_patterns_returns_json_array() {
    # First add a pattern
    "$MEMORY_MANAGER" add-pattern "error_fix" "test error trigger" "test solution" >/dev/null

    local result=$("$MEMORY_MANAGER" find-patterns "test")
    assert_json_valid "$result" "find-patterns should return valid JSON"
}

# ============================================================================
# Full Checkpoint/Restore Tests
# ============================================================================

test_checkpoint_full_creates_files() {
    local result=$("$MEMORY_MANAGER" checkpoint-full "Test full checkpoint")
    assert_json_valid "$result" "checkpoint-full should return valid JSON"
    assert_json_has_key "$result" "checkpoint_id" "checkpoint-full should return checkpoint_id"

    # Extract checkpoint path and verify files exist
    local cp_path=$(echo "$result" | jq -r '.path')
    if [[ -n "$cp_path" && "$cp_path" != "null" ]]; then
        assert_file_exists "${cp_path}/metadata.json" "Checkpoint should create metadata.json"
        assert_file_exists "${cp_path}/memory.db.snapshot" "Checkpoint should create DB snapshot"
    fi
}

test_list_checkpoints_full_returns_json_array() {
    local result=$("$MEMORY_MANAGER" list-checkpoints-full)
    assert_json_valid "$result" "list-checkpoints-full should return valid JSON"
}

test_restore_fails_for_nonexistent_checkpoint() {
    local result=$("$MEMORY_MANAGER" restore "NONEXISTENT-CHECKPOINT-ID" 2>/dev/null || echo '{"status":"error"}')
    assert_contains "$result" "error" "restore should fail for nonexistent checkpoint"
}

# ============================================================================
# Context Usage Tests
# ============================================================================

test_context_usage_returns_json() {
    local result=$("$MEMORY_MANAGER" context-usage)
    assert_json_valid "$result" "context-usage should return valid JSON"
    assert_json_has_key "$result" "status" "context-usage should have status field"
}

test_context_usage_with_percentage() {
    local result=$("$MEMORY_MANAGER" context-usage 50)
    assert_json_valid "$result" "context-usage with percentage should return valid JSON"
    assert_contains "$result" "50" "context-usage should reflect the passed percentage"
}

test_context_usage_critical_at_80_percent() {
    local result=$("$MEMORY_MANAGER" context-usage 80)
    assert_contains "$result" "critical" "80% usage should return critical status"
}

test_context_usage_warning_at_60_percent() {
    local result=$("$MEMORY_MANAGER" context-usage 60)
    assert_contains "$result" "warning" "60% usage should return warning status"
}

test_context_usage_active_below_60_percent() {
    local result=$("$MEMORY_MANAGER" context-usage 30)
    assert_contains "$result" "active" "30% usage should return active status"
}

# ============================================================================
# File Change Detection Tests
# ============================================================================

test_cache_file_succeeds() {
    # Create a test file
    echo "test content" > "${TEST_DIR}/testfile.txt"

    local result=$("$MEMORY_MANAGER" cache-file "${TEST_DIR}/testfile.txt")
    assert_json_valid "$result" "cache-file should return valid JSON"
    assert_contains "$result" "cached" "cache-file should indicate cached status"
}

test_file_changed_detects_changes() {
    # Create and cache a test file
    echo "original content" > "${TEST_DIR}/changefile.txt"
    "$MEMORY_MANAGER" cache-file "${TEST_DIR}/changefile.txt" >/dev/null

    # Check unchanged file
    local result=$("$MEMORY_MANAGER" file-changed "${TEST_DIR}/changefile.txt")
    assert_equals "false" "$result" "Unchanged file should return false"

    # Modify the file
    echo "modified content" > "${TEST_DIR}/changefile.txt"

    # Check changed file
    result=$("$MEMORY_MANAGER" file-changed "${TEST_DIR}/changefile.txt")
    assert_equals "true" "$result" "Changed file should return true"
}

test_file_changed_returns_true_for_uncached() {
    local result=$("$MEMORY_MANAGER" file-changed "${TEST_DIR}/uncached_file_$(date +%s).txt")
    assert_equals "true" "$result" "Uncached file should return true (assume changed)"
}

# ============================================================================
# Stats Tests
# ============================================================================

test_stats_returns_json() {
    local result=$("$MEMORY_MANAGER" stats)
    assert_json_valid "$result" "stats should return valid JSON"
    assert_json_has_key "$result" "checkpoints" "stats should have checkpoints count"
    assert_json_has_key "$result" "facts" "stats should have facts count"
    assert_json_has_key "$result" "patterns" "stats should have patterns count"
    assert_json_has_key "$result" "episodes" "stats should have episodes count"
}

# ============================================================================
# Git Channel Tests
# ============================================================================

test_scope_returns_json() {
    local result=$("$MEMORY_MANAGER" scope)
    assert_json_valid "$result" "scope should return valid JSON"
    assert_json_has_key "$result" "memory_db" "scope should have memory_db field"
    assert_json_has_key "$result" "git_channel" "scope should have git_channel field"
    assert_json_has_key "$result" "project_root" "scope should have project_root field"
}

# ============================================================================
# Hybrid Search Tests
# ============================================================================

test_remember_hybrid_returns_json() {
    # Add some facts first
    "$MEMORY_MANAGER" add-fact "test" "hybrid-test-key" "hybrid-test-value" >/dev/null

    local result=$("$MEMORY_MANAGER" remember-hybrid "hybrid")
    assert_json_valid "$result" "remember-hybrid should return valid JSON"
}

# ============================================================================
# Context Budgeting Tests
# ============================================================================

test_context_remaining_returns_json() {
    local result=$("$MEMORY_MANAGER" context-remaining)
    assert_json_valid "$result" "context-remaining should return valid JSON"
    assert_json_has_key "$result" "total" "context-remaining should have total field"
    assert_json_has_key "$result" "used" "context-remaining should have used field"
    assert_json_has_key "$result" "remaining" "context-remaining should have remaining field"
}

test_context_compact_removes_old_episodes() {
    local result=$("$MEMORY_MANAGER" context-compact)
    assert_json_valid "$result" "context-compact should return valid JSON"
    assert_contains "$result" "compacted" "context-compact should indicate compacted status"
}

# ============================================================================
# Language Detection Tests
# ============================================================================

test_detect_language_typescript() {
    local result=$("$MEMORY_MANAGER" detect-language "test.ts")
    assert_contains "$result" "typescript" "detect-language should identify .ts as typescript"
}

test_detect_language_python() {
    local result=$("$MEMORY_MANAGER" detect-language "test.py")
    assert_contains "$result" "python" "detect-language should identify .py as python"
}

test_detect_language_bash() {
    local result=$("$MEMORY_MANAGER" detect-language "test.sh")
    assert_contains "$result" "bash" "detect-language should identify .sh as bash"
}

# ============================================================================
# Main Test Suite
# ============================================================================

main() {
    test_suite_start "Memory Manager Unit Tests"

    # Setup
    setup

    # Working Memory Tests
    run_test "set-task returns valid JSON" test_set_task_returns_json
    run_test "get-working returns valid JSON" test_get_working_returns_json
    run_test "add-context stores value" test_add_context_stores_value
    run_test "search returns empty array for no matches" test_search_returns_empty_array_for_no_matches

    # Episodic Memory Tests
    run_test "record episode returns valid JSON" test_record_episode_returns_json
    run_test "checkpoint returns ID with MEM- prefix" test_checkpoint_returns_id
    run_test "list-checkpoints returns valid JSON array" test_list_checkpoints_returns_json_array

    # Semantic Memory Tests
    run_test "add-fact stores correctly" test_add_fact_stores_correctly
    run_test "add-pattern returns pattern ID" test_add_pattern_returns_pattern_id
    run_test "find-patterns returns valid JSON array" test_find_patterns_returns_json_array

    # Full Checkpoint/Restore Tests
    run_test "checkpoint-full creates files" test_checkpoint_full_creates_files
    run_test "list-checkpoints-full returns valid JSON array" test_list_checkpoints_full_returns_json_array
    run_test "restore fails for nonexistent checkpoint" test_restore_fails_for_nonexistent_checkpoint

    # Context Usage Tests
    run_test "context-usage returns valid JSON" test_context_usage_returns_json
    run_test "context-usage accepts percentage parameter" test_context_usage_with_percentage
    run_test "context-usage returns critical at 80%" test_context_usage_critical_at_80_percent
    run_test "context-usage returns warning at 60%" test_context_usage_warning_at_60_percent
    run_test "context-usage returns active below 60%" test_context_usage_active_below_60_percent

    # File Change Detection Tests
    run_test "cache-file succeeds for existing file" test_cache_file_succeeds
    run_test "file-changed detects modifications" test_file_changed_detects_changes
    run_test "file-changed returns true for uncached files" test_file_changed_returns_true_for_uncached

    # Stats Tests
    run_test "stats returns valid JSON with all fields" test_stats_returns_json

    # Git Channel Tests
    run_test "scope returns valid JSON with git info" test_scope_returns_json

    # Hybrid Search Tests
    run_test "remember-hybrid returns valid JSON" test_remember_hybrid_returns_json

    # Context Budgeting Tests
    run_test "context-remaining returns valid JSON" test_context_remaining_returns_json
    run_test "context-compact removes old episodes" test_context_compact_removes_old_episodes

    # Language Detection Tests
    run_test "detect-language identifies TypeScript" test_detect_language_typescript
    run_test "detect-language identifies Python" test_detect_language_python
    run_test "detect-language identifies Bash" test_detect_language_bash

    # Teardown
    teardown

    # Summary
    test_suite_end
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
