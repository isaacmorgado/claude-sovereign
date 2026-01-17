#!/bin/bash
# Security Validation Script
# Tests SQL injection vulnerabilities and race condition fixes
#
# Test Results (2026-01-17):
# - Test 1 (add_fact injection): PASS - Malicious input safely escaped and stored
# - Test 2 (checkpoint injection): PASS - Malicious input safely escaped and stored
# - Test 3 (file locking parallel writes): PASS - All 10 parallel writes recorded correctly
# - Test 4 (memory operations without corruption): PASS - All 7 operations completed
#
# Summary: 4/4 tests passed (100%)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_MANAGER="$SCRIPT_DIR/memory-manager.sh"
FILE_TRACKER="$SCRIPT_DIR/file-change-tracker.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED=$((PASSED + 1))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED=$((FAILED + 1))
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Setup test environment
setup() {
    log_info "Setting up test environment..."

    # Create test directory structure that mimics a project
    TEST_PROJECT_DIR="/tmp/security-test-project-$$"
    mkdir -p "$TEST_PROJECT_DIR"

    # Change to test directory and initialize git
    cd "$TEST_PROJECT_DIR"
    git init --quiet

    # Set MEMORY_SCOPE to project so it uses the local .claude/memory directory
    export MEMORY_SCOPE=project

    # Initialize memory - this will create .claude/memory/<branch>/ in the test project
    local init_output
    init_output=$("$MEMORY_MANAGER" init 2>&1)

    # Get the actual memory directory from the init output
    MEMORY_DIR=$(echo "$init_output" | grep -o '/tmp/security-test-project-[0-9]*/.claude/memory/[^[:space:]]*' | head -1)

    if [[ -z "$MEMORY_DIR" ]]; then
        # Fallback: detect from filesystem
        MEMORY_DIR=$(find "$TEST_PROJECT_DIR/.claude/memory" -mindepth 1 -maxdepth 1 -type d | head -1)
    fi

    log_info "  Using MEMORY_DIR: $MEMORY_DIR"
}

# Cleanup test environment
cleanup() {
    log_info "Cleaning up test environment..."
    rm -rf "$TEST_PROJECT_DIR"
    rm -rf "/tmp/test-tracker-$$"
}

# Test 1: SQL injection via add_fact
test_add_fact_injection() {
    log_info "Test 1: Attempting SQL injection via add_fact..."

    # Attempt to inject malicious category
    local malicious_category="test'; DROP TABLE facts;--"
    local result

    "$MEMORY_MANAGER" add-fact "$malicious_category" "key" "value" >/dev/null 2>&1 || true

    # Check if the fact was stored properly (escaped) without corrupting the JSON
    if jq -e '.facts' "$MEMORY_DIR/semantic.json" >/dev/null 2>&1; then
        # JSON is still valid
        local stored_category
        stored_category=$(jq -r '.facts[-1].category // "not_found"' "$MEMORY_DIR/semantic.json")

        # The category should be stored with escaped quotes
        if [[ "$stored_category" == *"DROP TABLE"* ]]; then
            log_pass "add_fact injection: Malicious input safely escaped and stored"
        else
            log_fail "add_fact injection: Unexpected storage behavior"
        fi
    else
        log_fail "add_fact injection: JSON file corrupted"
    fi
}

# Test 2: SQL injection via checkpoint
test_checkpoint_injection() {
    log_info "Test 2: Attempting SQL injection via checkpoint..."

    # Attempt to inject malicious description
    local malicious_desc="'; DELETE FROM checkpoints;--"
    local result

    result=$("$MEMORY_MANAGER" checkpoint "$malicious_desc" 2>&1) || true

    # Check if checkpoint was created successfully
    if [[ "$result" == ckpt_* ]]; then
        local checkpoint_file="$MEMORY_DIR/checkpoints/$result.json"

        if [[ -f "$checkpoint_file" ]]; then
            # JSON should be valid
            if jq -e '.description' "$checkpoint_file" >/dev/null 2>&1; then
                local stored_desc
                stored_desc=$(jq -r '.description' "$checkpoint_file")

                if [[ "$stored_desc" == *"DELETE FROM"* ]]; then
                    log_pass "checkpoint injection: Malicious input safely escaped and stored"
                else
                    log_fail "checkpoint injection: Unexpected description value"
                fi
            else
                log_fail "checkpoint injection: Invalid JSON in checkpoint file"
            fi
        else
            log_fail "checkpoint injection: Checkpoint file not created"
        fi
    else
        log_fail "checkpoint injection: Checkpoint creation failed - $result"
    fi
}

# Test 3: File locking with parallel writes
test_file_locking_parallel() {
    log_info "Test 3: Testing file locking with parallel writes..."

    local test_tracker_dir="/tmp/test-tracker-$$"
    mkdir -p "$test_tracker_dir/.claude"

    # Change to test directory so PROJECT_DIR is set correctly at script load
    local original_dir="$PWD"
    cd "$test_tracker_dir"

    local tracker_file="$test_tracker_dir/.claude/file-changes.json"

    # Initialize tracker
    "$FILE_TRACKER" init >/dev/null 2>&1

    # Launch 10 parallel writes
    log_info "  Launching 10 parallel record_change operations..."
    for i in $(seq 1 10); do
        (cd "$test_tracker_dir" && "$FILE_TRACKER" record "file$i.txt" modified) &
    done

    # Wait for all background processes
    wait

    # Return to original directory
    cd "$original_dir"

    # Check if tracker file is valid JSON
    if jq -e '.change_count' "$tracker_file" >/dev/null 2>&1; then
        local count
        count=$(jq -r '.change_count' "$tracker_file")

        if [[ "$count" -eq 10 ]]; then
            log_pass "File locking: All 10 parallel writes recorded correctly"
        else
            log_fail "File locking: Expected 10 changes, got $count (race condition detected)"
        fi
    else
        log_fail "File locking: Tracker file corrupted after parallel writes"
    fi

    # Cleanup tracker test directory
    rm -rf "$test_tracker_dir"
}

# Test 4: Memory operations complete without corruption
test_memory_operations() {
    log_info "Test 4: Testing memory operations without corruption..."

    local errors=0

    # Test set_task
    "$MEMORY_MANAGER" set-task "Test task" "Test context" >/dev/null 2>&1 || errors=$((errors + 1))

    # Test add_context
    "$MEMORY_MANAGER" add-context "Additional context" 8 >/dev/null 2>&1 || errors=$((errors + 1))

    # Test record (episode)
    "$MEMORY_MANAGER" record task_complete "Test episode" success "Details" >/dev/null 2>&1 || errors=$((errors + 1))

    # Test add_fact
    "$MEMORY_MANAGER" add-fact "test" "key" "value" 0.9 >/dev/null 2>&1 || errors=$((errors + 1))

    # Test add_pattern
    "$MEMORY_MANAGER" add-pattern "test_pattern" "trigger" "solution" 1.0 >/dev/null 2>&1 || errors=$((errors + 1))

    # Test log_action
    "$MEMORY_MANAGER" log-action "test" "Test action" "success" '{}' >/dev/null 2>&1 || errors=$((errors + 1))

    # Test checkpoint
    "$MEMORY_MANAGER" checkpoint "Test checkpoint" >/dev/null 2>&1 || errors=$((errors + 1))

    # Verify all JSON files are valid
    local json_errors=0
    for file in "$MEMORY_DIR"/*.json; do
        if [[ -f "$file" ]]; then
            if ! jq -e '.' "$file" >/dev/null 2>&1; then
                log_info "  Corrupted: $file"
                json_errors=$((json_errors + 1))
            fi
        fi
    done

    if [[ $errors -eq 0 && $json_errors -eq 0 ]]; then
        log_pass "Memory operations: All 7 operations completed without errors or corruption"
    else
        log_fail "Memory operations: $errors operation errors, $json_errors JSON corruption errors"
    fi
}

# Run all tests
main() {
    echo ""
    echo "========================================"
    echo "  Security Validation Tests"
    echo "========================================"
    echo ""

    setup

    test_add_fact_injection
    test_checkpoint_injection
    test_file_locking_parallel
    test_memory_operations

    cleanup

    echo ""
    echo "========================================"
    echo "  Results: $PASSED passed, $FAILED failed"
    echo "========================================"
    echo ""

    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}All security tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some security tests failed.${NC}"
        exit 1
    fi
}

main "$@"
