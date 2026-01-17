#!/usr/bin/env bash
#
# Test Framework for Claude Autonomous System
# Provides assertion functions and test suite management for bash hooks
#
# Usage:
#   source /path/to/test-framework.sh
#   test_suite_start "My Test Suite"
#   run_test "test name" my_test_function
#   test_suite_end
#

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Test counters (bash 3.2 compatible - no declare -g)
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0
CURRENT_SUITE=""
SUITE_START_TIME=0

# Captured output from last run_test
TEST_STDOUT=""
TEST_STDERR=""
TEST_EXIT_CODE=0

#
# test_suite_start - Initialize a test suite
# Arguments:
#   $1 - Suite name
#
test_suite_start() {
    local suite_name="${1:-Unnamed Suite}"
    CURRENT_SUITE="$suite_name"
    TESTS_PASSED=0
    TESTS_FAILED=0
    TESTS_TOTAL=0
    SUITE_START_TIME=$(date +%s)

    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Test Suite: ${suite_name}${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

#
# test_suite_end - Finalize test suite and output summary
# Returns: 0 if all tests passed, 1 if any failed
#
test_suite_end() {
    local end_time=$(date +%s)
    local duration=$((end_time - SUITE_START_TIME))

    echo ""
    echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}  Suite: ${CURRENT_SUITE} - Summary${NC}"
    echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "  ${GREEN}✓ All tests passed!${NC}"
    else
        echo -e "  ${RED}✗ Some tests failed${NC}"
    fi

    echo ""
    echo -e "  Total:  ${TESTS_TOTAL}"
    echo -e "  ${GREEN}Passed: ${TESTS_PASSED}${NC}"
    echo -e "  ${RED}Failed: ${TESTS_FAILED}${NC}"
    echo -e "  Duration: ${duration}s"
    echo ""

    # Return non-zero if any tests failed
    [[ $TESTS_FAILED -eq 0 ]]
}

#
# run_test - Execute a test function with output capture
# Arguments:
#   $1 - Test name (description)
#   $2 - Test function to call (or command)
#   $@ - Additional arguments to pass to the function
#
# Sets global variables:
#   TEST_STDOUT - captured stdout
#   TEST_STDERR - captured stderr
#   TEST_EXIT_CODE - exit code from the test
#
run_test() {
    local test_name="$1"
    shift
    local test_func="$@"

    ((TESTS_TOTAL++)) || true

    # Create temp files for output capture
    local stdout_file=$(mktemp)
    local stderr_file=$(mktemp)

    # Run the test function, capturing output
    TEST_EXIT_CODE=0
    if eval "$test_func" >"$stdout_file" 2>"$stderr_file"; then
        TEST_EXIT_CODE=0
    else
        TEST_EXIT_CODE=$?
    fi

    TEST_STDOUT=$(cat "$stdout_file")
    TEST_STDERR=$(cat "$stderr_file")

    # Clean up temp files
    rm -f "$stdout_file" "$stderr_file"

    # Check result based on exit code
    if [[ $TEST_EXIT_CODE -eq 0 ]]; then
        ((TESTS_PASSED++)) || true
        echo -e "  ${GREEN}✓${NC} ${test_name}"
        return 0
    else
        ((TESTS_FAILED++)) || true
        echo -e "  ${RED}✗${NC} ${test_name}"
        if [[ -n "$TEST_STDERR" ]]; then
            echo -e "    ${YELLOW}stderr:${NC} $TEST_STDERR"
        fi
        return 1
    fi
}

#
# assert_equals - Assert two values are equal
# Arguments:
#   $1 - Expected value
#   $2 - Actual value
#   $3 - Message (optional)
#
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"

    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  Expected: '$expected'" >&2
        echo "  Actual:   '$actual'" >&2
        return 1
    fi
}

#
# assert_not_equals - Assert two values are not equal
# Arguments:
#   $1 - Unexpected value
#   $2 - Actual value
#   $3 - Message (optional)
#
assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal}"

    if [[ "$unexpected" != "$actual" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  Unexpected: '$unexpected'" >&2
        echo "  Actual:     '$actual'" >&2
        return 1
    fi
}

#
# assert_contains - Assert string contains substring
# Arguments:
#   $1 - String to search in
#   $2 - Substring to find
#   $3 - Message (optional)
#
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"

    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  String: '$haystack'" >&2
        echo "  Should contain: '$needle'" >&2
        return 1
    fi
}

#
# assert_not_contains - Assert string does not contain substring
# Arguments:
#   $1 - String to search in
#   $2 - Substring that should not exist
#   $3 - Message (optional)
#
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should not contain substring}"

    if [[ "$haystack" != *"$needle"* ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  String: '$haystack'" >&2
        echo "  Should NOT contain: '$needle'" >&2
        return 1
    fi
}

#
# assert_file_exists - Assert file exists
# Arguments:
#   $1 - File path
#   $2 - Message (optional)
#
assert_file_exists() {
    local file_path="$1"
    local message="${2:-File should exist}"

    if [[ -f "$file_path" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  File not found: '$file_path'" >&2
        return 1
    fi
}

#
# assert_dir_exists - Assert directory exists
# Arguments:
#   $1 - Directory path
#   $2 - Message (optional)
#
assert_dir_exists() {
    local dir_path="$1"
    local message="${2:-Directory should exist}"

    if [[ -d "$dir_path" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  Directory not found: '$dir_path'" >&2
        return 1
    fi
}

#
# assert_file_not_exists - Assert file does not exist
# Arguments:
#   $1 - File path
#   $2 - Message (optional)
#
assert_file_not_exists() {
    local file_path="$1"
    local message="${2:-File should not exist}"

    if [[ ! -f "$file_path" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  File exists but shouldn't: '$file_path'" >&2
        return 1
    fi
}

#
# assert_exit_code - Assert specific exit code
# Arguments:
#   $1 - Expected exit code
#   $2 - Actual exit code (usually $?)
#   $3 - Message (optional)
#
assert_exit_code() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Exit code should match}"

    if [[ "$expected" -eq "$actual" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  Expected exit code: $expected" >&2
        echo "  Actual exit code:   $actual" >&2
        return 1
    fi
}

#
# assert_json_valid - Assert string is valid JSON
# Arguments:
#   $1 - JSON string
#   $2 - Message (optional)
#
assert_json_valid() {
    local json_string="$1"
    local message="${2:-String should be valid JSON}"

    if echo "$json_string" | jq . >/dev/null 2>&1; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  Invalid JSON: '$json_string'" >&2
        return 1
    fi
}

#
# assert_json_has_key - Assert JSON object has a specific key
# Arguments:
#   $1 - JSON string
#   $2 - Key to check for
#   $3 - Message (optional)
#
assert_json_has_key() {
    local json_string="$1"
    local key="$2"
    local message="${3:-JSON should have key}"

    if echo "$json_string" | jq -e ".$key" >/dev/null 2>&1; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  Key not found: '$key'" >&2
        echo "  JSON: '$json_string'" >&2
        return 1
    fi
}

#
# assert_true - Assert condition is true
# Arguments:
#   $1 - Condition to evaluate
#   $2 - Message (optional)
#
assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"

    if eval "$condition"; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  Condition was false: '$condition'" >&2
        return 1
    fi
}

#
# assert_false - Assert condition is false
# Arguments:
#   $1 - Condition to evaluate
#   $2 - Message (optional)
#
assert_false() {
    local condition="$1"
    local message="${2:-Condition should be false}"

    if ! eval "$condition"; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  Condition was true: '$condition'" >&2
        return 1
    fi
}

#
# assert_empty - Assert string is empty
# Arguments:
#   $1 - String to check
#   $2 - Message (optional)
#
assert_empty() {
    local string="$1"
    local message="${2:-String should be empty}"

    if [[ -z "$string" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  String is not empty: '$string'" >&2
        return 1
    fi
}

#
# assert_not_empty - Assert string is not empty
# Arguments:
#   $1 - String to check
#   $2 - Message (optional)
#
assert_not_empty() {
    local string="$1"
    local message="${2:-String should not be empty}"

    if [[ -n "$string" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        echo "  String is empty" >&2
        return 1
    fi
}

#
# setup_test_env - Create temporary test environment
# Sets: TEST_DIR - path to temporary test directory
#
setup_test_env() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    cd "$TEST_DIR"
}

#
# teardown_test_env - Clean up temporary test environment
#
teardown_test_env() {
    if [[ -n "${TEST_DIR:-}" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Export all functions for use in subshells
export -f test_suite_start test_suite_end run_test
export -f assert_equals assert_not_equals
export -f assert_contains assert_not_contains
export -f assert_file_exists assert_dir_exists assert_file_not_exists
export -f assert_exit_code
export -f assert_json_valid assert_json_has_key
export -f assert_true assert_false
export -f assert_empty assert_not_empty
export -f setup_test_env teardown_test_env
