#!/bin/bash
# Test regression detection functionality
# Tests Issues #8 and #14 fixes

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
DEBUG_ORCHESTRATOR="${CLAUDE_DIR}/hooks/debug-orchestrator.sh"
TEST_DIR="${SCRIPT_DIR}/regression-test-temp"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Testing Regression Detection (Issues #8, #14)"
echo "========================================="
echo ""

# Setup test directory
mkdir -p "$TEST_DIR"
echo "[DEBUG] Created test directory: $TEST_DIR"
cd "$TEST_DIR"
echo "[DEBUG] Changed to directory: $(pwd)"

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

test_passed() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

test_failed() {
    echo -e "${RED}✗${NC} $1"
    echo "  Details: $2"
    ((TESTS_FAILED++))
}

# Test 1: GitHub MCP Detection
echo "Test 1: GitHub MCP Detection"
echo "----------------------------"
echo "[DEBUG] Checking for MCP detection code..."
if grep -q "type -t mcp__grep__searchGitHub" "$DEBUG_ORCHESTRATOR"; then
    test_passed "GitHub MCP detection code exists"
else
    test_failed "GitHub MCP detection code missing" "Should check for mcp__grep__searchGitHub"
fi

# Check that it's not hardcoded outside of the if/else block
echo "[DEBUG] Checking if MCP is hardcoded..."
HARDCODED_CHECK=$(grep -c -E "^GITHUB_MCP_AVAILABLE=false" "$DEBUG_ORCHESTRATOR" || true)
echo "[DEBUG] Hardcoded check result: $HARDCODED_CHECK"
if [[ "$HARDCODED_CHECK" -gt 0 ]]; then
    test_failed "GitHub MCP still hardcoded to false on its own line" "Should be dynamically detected"
else
    test_passed "GitHub MCP is not hardcoded to false (dynamically detected)"
fi
echo ""

# Test 2: Test Snapshot with Actual Test Parsing
echo "Test 2: Test Snapshot with Actual Test Parsing"
echo "-----------------------------------------------"
echo "[DEBUG] Creating test scripts..."

# Create a fake passing test command
cat > test-pass.sh << 'EOF'
#!/bin/bash
echo "Running tests..."
echo "Tests: 5 passed, 5 total"
echo "PASS"
exit 0
EOF
chmod +x test-pass.sh

# Create a fake failing test command
cat > test-fail.sh << 'EOF'
#!/bin/bash
echo "Running tests..."
echo "Tests: 3 passed, 2 failed, 5 total"
echo "FAIL"
exit 1
EOF
chmod +x test-fail.sh

# Test passing snapshot
echo "Creating snapshot for passing tests..."
SNAPSHOT_PASS=$("$DEBUG_ORCHESTRATOR" snapshot "test_pass_$(date +%s)" "./test-pass.sh" "Passing tests")
if [[ -f "$SNAPSHOT_PASS" ]]; then
    test_passed "Snapshot file created for passing tests"

    # Check if tests_passed is true
    TESTS_PASSED_VALUE=$(jq -r '.tests_passed' "$SNAPSHOT_PASS")
    if [[ "$TESTS_PASSED_VALUE" == "true" ]]; then
        test_passed "Snapshot correctly detected passing tests (tests_passed=true)"
    else
        test_failed "Snapshot failed to detect passing tests" "tests_passed=$TESTS_PASSED_VALUE, expected true"
    fi

    # Check if test_count and failed_count exist
    if jq -e '.test_count' "$SNAPSHOT_PASS" > /dev/null 2>&1; then
        test_passed "Snapshot includes test_count field"
    else
        test_failed "Snapshot missing test_count field" "Should parse test counts from output"
    fi
else
    test_failed "Failed to create snapshot file" "Command: $DEBUG_ORCHESTRATOR snapshot"
fi

# Test failing snapshot
echo "Creating snapshot for failing tests..."
SNAPSHOT_FAIL=$("$DEBUG_ORCHESTRATOR" snapshot "test_fail_$(date +%s)" "./test-fail.sh" "Failing tests")
if [[ -f "$SNAPSHOT_FAIL" ]]; then
    test_passed "Snapshot file created for failing tests"

    # Check if tests_passed is false
    TESTS_PASSED_VALUE=$(jq -r '.tests_passed' "$SNAPSHOT_FAIL")
    if [[ "$TESTS_PASSED_VALUE" == "false" ]]; then
        test_passed "Snapshot correctly detected failing tests (tests_passed=false)"
    else
        test_failed "Snapshot failed to detect failing tests" "tests_passed=$TESTS_PASSED_VALUE, expected false"
    fi
else
    test_failed "Failed to create snapshot file" "Command: $DEBUG_ORCHESTRATOR snapshot"
fi
echo ""

# Test 3: Field Name Consistency (regressions_detected)
echo "Test 3: Field Name Consistency"
echo "-------------------------------"

# Check detect_regression output
BEFORE_SNAPSHOT="$SNAPSHOT_PASS"
AFTER_SNAPSHOT="$SNAPSHOT_FAIL"

echo "Testing regression detection (pass -> fail)..."
REGRESSION_RESULT=$("$DEBUG_ORCHESTRATOR" detect-regression "$BEFORE_SNAPSHOT" "$AFTER_SNAPSHOT")

if echo "$REGRESSION_RESULT" | jq -e '.regressions_detected' > /dev/null 2>&1; then
    test_passed "detect_regression outputs 'regressions_detected' field (not 'regression_detected')"

    REGRESSION_VALUE=$(echo "$REGRESSION_RESULT" | jq -r '.regressions_detected')
    if [[ "$REGRESSION_VALUE" == "true" ]]; then
        test_passed "Regression correctly detected when tests go from passing to failing"
    else
        test_failed "Failed to detect regression" "regressions_detected=$REGRESSION_VALUE, expected true"
    fi
else
    test_failed "detect_regression missing 'regressions_detected' field" "Output: $REGRESSION_RESULT"
fi

# Test no regression case (fail -> fail)
echo "Testing no regression detection (fail -> fail)..."
REGRESSION_RESULT_NO=$("$DEBUG_ORCHESTRATOR" detect-regression "$SNAPSHOT_FAIL" "$SNAPSHOT_FAIL")
REGRESSION_VALUE_NO=$(echo "$REGRESSION_RESULT_NO" | jq -r '.regressions_detected')
if [[ "$REGRESSION_VALUE_NO" == "false" ]]; then
    test_passed "No regression detected when both snapshots fail"
else
    test_failed "False positive regression detection" "regressions_detected=$REGRESSION_VALUE_NO, expected false"
fi
echo ""

# Test 4: Regression Log File Creation
echo "Test 4: Regression Log File Creation"
echo "-------------------------------------"

REGRESSION_LOG="${CLAUDE_DIR}/.debug/regressions.jsonl"

# Clear any existing regression log
rm -f "$REGRESSION_LOG"

# Trigger a regression detection that should log
echo "Triggering regression detection to test log creation..."
"$DEBUG_ORCHESTRATOR" detect-regression "$SNAPSHOT_PASS" "$SNAPSHOT_FAIL" > /dev/null

if [[ -f "$REGRESSION_LOG" ]]; then
    test_passed "Regression log file created at $REGRESSION_LOG"

    # Check log contents
    if grep -q "test_failure" "$REGRESSION_LOG"; then
        test_passed "Regression log contains regression_type: test_failure"
    else
        test_failed "Regression log missing expected content" "Should contain regression_type"
    fi
else
    test_failed "Regression log file not created" "Expected at $REGRESSION_LOG"
fi
echo ""

# Test 5: verify-fix Function Output
echo "Test 5: verify-fix Function Output"
echo "-----------------------------------"

# Create a before snapshot (passing)
BEFORE_ID="verify_before_$(date +%s)"
BEFORE_SNAP=$("$DEBUG_ORCHESTRATOR" snapshot "$BEFORE_ID" "./test-pass.sh" "Before fix")

# Test verify-fix with regression
echo "Testing verify-fix with regression (pass -> fail)..."
VERIFY_RESULT=$("$DEBUG_ORCHESTRATOR" verify-fix "$BEFORE_ID" "./test-fail.sh" "Test fix")

if echo "$VERIFY_RESULT" | jq -e '.regressions_detected' > /dev/null 2>&1; then
    test_passed "verify-fix outputs 'regressions_detected' field"

    VERIFY_REGRESSION=$(echo "$VERIFY_RESULT" | jq -r '.regressions_detected')
    if [[ "$VERIFY_REGRESSION" == "true" ]]; then
        test_passed "verify-fix correctly detects regression"
    else
        test_failed "verify-fix failed to detect regression" "regressions_detected=$VERIFY_REGRESSION"
    fi

    # Check for recommendation
    if echo "$VERIFY_RESULT" | jq -e '.recommendation' > /dev/null 2>&1; then
        test_passed "verify-fix includes recommendation when regression detected"
    fi
else
    test_failed "verify-fix missing 'regressions_detected' field" "Output: $VERIFY_RESULT"
fi

# Test verify-fix without regression
echo "Testing verify-fix without regression (pass -> pass)..."
VERIFY_RESULT_OK=$("$DEBUG_ORCHESTRATOR" verify-fix "$BEFORE_ID" "./test-pass.sh" "Test fix")
VERIFY_REGRESSION_OK=$(echo "$VERIFY_RESULT_OK" | jq -r '.regressions_detected')

if [[ "$VERIFY_REGRESSION_OK" == "false" ]]; then
    test_passed "verify-fix correctly reports no regression when fix is clean"
else
    test_failed "verify-fix false positive" "regressions_detected=$VERIFY_REGRESSION_OK, expected false"
fi
echo ""

# Test 6: GitHub MCP Integration in smart-debug
echo "Test 6: GitHub MCP Integration in smart-debug"
echo "----------------------------------------------"

if grep -q 'GITHUB_MCP_AVAILABLE.*true' "$DEBUG_ORCHESTRATOR"; then
    test_passed "smart-debug checks GITHUB_MCP_AVAILABLE flag"
else
    test_failed "smart-debug doesn't check GITHUB_MCP_AVAILABLE" "Should use MCP when available"
fi

if grep -q 'mcp__grep__searchGitHub' "$DEBUG_ORCHESTRATOR"; then
    test_passed "smart-debug references mcp__grep__searchGitHub tool"
else
    test_failed "smart-debug missing MCP reference" "Should mention mcp__grep__searchGitHub"
fi

if grep -q 'gh search' "$DEBUG_ORCHESTRATOR"; then
    test_passed "smart-debug includes gh CLI fallback"
else
    test_failed "smart-debug missing gh CLI fallback" "Should fallback when MCP not available"
fi
echo ""

# Cleanup
cd - > /dev/null
rm -rf "$TEST_DIR"

# Summary
echo "========================================="
echo "Test Summary"
echo "========================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Issues #8 and #14 are FIXED:"
    echo "  ✓ Regression detection correctly parses test output"
    echo "  ✓ Field names are consistent (regressions_detected)"
    echo "  ✓ Regression log file is created"
    echo "  ✓ GitHub MCP is properly integrated"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    exit 1
fi
