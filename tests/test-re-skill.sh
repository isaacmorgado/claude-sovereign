#!/bin/bash
# RE Skill Verification Test Suite
# Tests all RE automation features

set -uo pipefail

RE_SKILL="${HOME}/.claude/skills/re.sh"
RE_AUTOMATION="${HOME}/.claude/hooks/re-automation.sh"
TEST_DIR="/tmp/re-skill-tests"
RESULTS_FILE="$TEST_DIR/test-results.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

setup() {
    echo -e "${BLUE}=== RE Skill Test Suite ===${NC}"
    echo ""

    mkdir -p "$TEST_DIR"
    rm -rf "$TEST_DIR"/*

    # Check prerequisites
    if [[ ! -x "$RE_SKILL" ]]; then
        echo -e "${RED}ERROR: RE skill not found or not executable at $RE_SKILL${NC}"
        exit 1
    fi

    if [[ ! -x "$RE_AUTOMATION" ]]; then
        echo -e "${YELLOW}WARNING: RE automation hook not found at $RE_AUTOMATION${NC}"
    fi

    echo -e "${GREEN}Prerequisites checked${NC}"
    echo ""
}

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}

# =============================================================================
# TEST 1: Create and Extract Test CRX File
# =============================================================================
test_crx_extraction() {
    echo -e "${BLUE}--- Test 1: Chrome Extension (CRX) Extraction ---${NC}"

    local test_ext_dir="$TEST_DIR/test-extension"
    local test_crx="$TEST_DIR/test-extension.crx"

    # Create a minimal Chrome extension
    mkdir -p "$test_ext_dir"

    cat > "$test_ext_dir/manifest.json" << 'EOF'
{
    "manifest_version": 3,
    "name": "Test Extension",
    "version": "1.0.0",
    "description": "A test extension for RE skill verification",
    "permissions": ["storage", "tabs"],
    "background": {
        "service_worker": "background.js"
    },
    "content_scripts": [{
        "matches": ["<all_urls>"],
        "js": ["content.js"]
    }]
}
EOF

    cat > "$test_ext_dir/background.js" << 'EOF'
// Background service worker
console.log("Test extension loaded");

chrome.runtime.onInstalled.addListener(() => {
    console.log("Extension installed");
});
EOF

    cat > "$test_ext_dir/content.js" << 'EOF'
// Content script
console.log("Content script injected");
// Test for eval detection
// eval("test");
EOF

    # Create CRX (actually just a zip for testing - real CRX has header)
    (cd "$test_ext_dir" && zip -q -r "$test_crx" .)

    # Test 1a: Extract CRX file
    local output
    output=$("$RE_SKILL" chrome "$test_crx" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]] && echo "$output" | grep -q '"name"'; then
        pass "CRX extraction completed"

        # Check analysis JSON
        if echo "$output" | grep -q '"manifestVersion": 3'; then
            pass "Manifest version detected correctly"
        else
            fail "Manifest version not detected"
        fi

        if echo "$output" | grep -q '"permissions"'; then
            pass "Permissions extracted"
        else
            fail "Permissions not extracted"
        fi
    else
        fail "CRX extraction failed (exit code: $exit_code)"
        echo "$output"
    fi

    # Test 1b: Extract from directory
    output=$("$RE_SKILL" chrome "$test_ext_dir" 2>&1)
    if echo "$output" | grep -q '"name": "Test Extension"'; then
        pass "Directory extraction completed"
    else
        fail "Directory extraction failed"
    fi

    echo ""
}

# =============================================================================
# TEST 2: JavaScript Deobfuscation
# =============================================================================
test_js_deobfuscation() {
    echo -e "${BLUE}--- Test 2: JavaScript Deobfuscation ---${NC}"

    local test_js="$TEST_DIR/test.min.js"

    # Create minified JS
    cat > "$test_js" << 'EOF'
function test(){var a=1,b=2,c=a+b;console.log("Result: "+c);return c}function fetchData(){var url="https://api.example.com/v1/data";fetch(url).then(function(r){return r.json()}).then(function(d){console.log(d)})}var apiEndpoint="/api/users";
EOF

    local output
    output=$("$RE_SKILL" deobfuscate "$test_js" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "Deobfuscation completed"

        # Check for URL extraction
        if echo "$output" | grep -q "urlsFound"; then
            pass "URLs extracted from code"
        else
            fail "URLs not extracted"
        fi

        # Check for API endpoint detection
        if echo "$output" | grep -q "apiEndpoints"; then
            pass "API endpoints detected"
        else
            fail "API endpoints not detected"
        fi

        # Check output file created
        if [[ -f ~/Desktop/re-output/deobfuscated/test.beautified.js ]]; then
            local line_count
            line_count=$(wc -l < ~/Desktop/re-output/deobfuscated/test.beautified.js | tr -d ' ')
            if [[ $line_count -gt 1 ]]; then
                pass "Beautified file created ($line_count lines)"
            else
                fail "Beautified file has insufficient lines"
            fi
        else
            fail "Beautified output file not created"
        fi
    else
        fail "Deobfuscation failed (exit code: $exit_code)"
    fi

    echo ""
}

# =============================================================================
# TEST 3: macOS App Exploration
# =============================================================================
test_macos_app() {
    echo -e "${BLUE}--- Test 3: macOS App Exploration ---${NC}"

    # Use Calculator.app as test target (always available on macOS)
    local test_app="/System/Applications/Calculator.app"

    if [[ ! -d "$test_app" ]]; then
        # Try alternative location
        test_app="/Applications/Calculator.app"
    fi

    if [[ ! -d "$test_app" ]]; then
        skip "Calculator.app not found for testing"
        return
    fi

    local output
    output=$("$RE_SKILL" macos "$test_app" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "macOS app exploration completed"

        # Check for bundle ID
        if echo "$output" | grep -q "bundleId"; then
            pass "Bundle ID extracted"
        else
            fail "Bundle ID not extracted"
        fi

        # Check for architecture
        if echo "$output" | grep -q "architecture"; then
            pass "Architecture detected"
        else
            fail "Architecture not detected"
        fi

        # Check for frameworks list
        if echo "$output" | grep -q "frameworks"; then
            pass "Frameworks listed"
        else
            fail "Frameworks not listed"
        fi
    else
        fail "macOS app exploration failed (exit code: $exit_code)"
    fi

    echo ""
}

# =============================================================================
# TEST 4: RE Automation Hook
# =============================================================================
test_re_automation() {
    echo -e "${BLUE}--- Test 4: RE Automation Hook Integration ---${NC}"

    if [[ ! -x "$RE_AUTOMATION" ]]; then
        skip "RE automation hook not available"
        return
    fi

    # Test 4a: is-re detection
    local result
    result=$("$RE_AUTOMATION" is-re "extract chrome extension from file.crx" 2>&1)
    if [[ "$result" == "true" ]]; then
        pass "is-re correctly identifies Chrome extension task"
    else
        fail "is-re failed to identify Chrome extension task"
    fi

    result=$("$RE_AUTOMATION" is-re "reverse engineer /Applications/Slack.app" 2>&1)
    if [[ "$result" == "true" ]]; then
        pass "is-re correctly identifies Electron app task"
    else
        fail "is-re failed to identify Electron app task"
    fi

    result=$("$RE_AUTOMATION" is-re "make breakfast" 2>&1)
    if [[ "$result" == "false" ]]; then
        pass "is-re correctly rejects non-RE task"
    else
        fail "is-re incorrectly identified non-RE task"
    fi

    # Test 4b: recommend functionality
    local recommendation
    recommendation=$("$RE_AUTOMATION" recommend "deobfuscate bundle.min.js" 2>&1)
    if echo "$recommendation" | grep -q '"detected": true' || echo "$recommendation" | grep -q '"detected":true'; then
        pass "recommend returns detection for deobfuscation"

        if echo "$recommendation" | grep -q "deobfuscate"; then
            pass "recommend suggests correct command"
        else
            fail "recommend did not suggest deobfuscate command"
        fi
    else
        fail "recommend failed to detect deobfuscation task"
    fi

    # Test 4c: pattern matching
    local match
    match=$("$RE_AUTOMATION" match "extract electron app /Applications/Discord.app" "" 2>&1)
    if [[ -n "$match" ]] && echo "$match" | grep -q "electron"; then
        pass "Pattern matching works for Electron"
    else
        fail "Pattern matching failed for Electron"
    fi

    echo ""
}

# =============================================================================
# TEST 5: API Research Initialization
# =============================================================================
test_api_research() {
    echo -e "${BLUE}--- Test 5: API Research Initialization ---${NC}"

    local output
    output=$("$RE_SKILL" api "https://api.example.com/v1" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "API research initialized"

        # Check for output directory
        if [[ -d ~/Desktop/re-output/api-research/api.example.com ]]; then
            pass "API research directory created"

            # Check for research.md
            if [[ -f ~/Desktop/re-output/api-research/api.example.com/research.md ]]; then
                pass "Research template created"
            else
                fail "Research template not created"
            fi

            # Check for config.json
            if [[ -f ~/Desktop/re-output/api-research/api.example.com/config.json ]]; then
                pass "Config file created"
            else
                fail "Config file not created"
            fi
        else
            fail "API research directory not created"
        fi
    else
        fail "API research initialization failed (exit code: $exit_code)"
    fi

    echo ""
}

# =============================================================================
# TEST 6: Auto-Analyze Detection
# =============================================================================
test_auto_analyze() {
    echo -e "${BLUE}--- Test 6: Auto-Analyze Type Detection ---${NC}"

    # Create test files
    local test_crx="$TEST_DIR/auto-test.crx"
    local test_js="$TEST_DIR/auto-test.js"

    echo '{}' | zip -q > "$test_crx" 2>/dev/null || echo "test" > "$test_crx"
    echo 'function test(){}' > "$test_js"

    # Test auto-detection of JS file
    local output
    output=$("$RE_SKILL" analyze "$test_js" 2>&1)

    if echo "$output" | grep -qi "beautif\|deobfuscat"; then
        pass "Auto-analyze correctly identifies JS file"
    else
        fail "Auto-analyze failed to identify JS file"
    fi

    echo ""
}

# =============================================================================
# TEST 7: Skill Help and Interface
# =============================================================================
test_skill_interface() {
    echo -e "${BLUE}--- Test 7: Skill Interface ---${NC}"

    # Test help command
    local help_output
    help_output=$("$RE_SKILL" help 2>&1)

    if echo "$help_output" | grep -q "USAGE"; then
        pass "Help command works"
    else
        fail "Help command failed"
    fi

    if echo "$help_output" | grep -q "chrome"; then
        pass "Chrome command documented"
    else
        fail "Chrome command not documented"
    fi

    if echo "$help_output" | grep -q "electron"; then
        pass "Electron command documented"
    else
        fail "Electron command not documented"
    fi

    if echo "$help_output" | grep -q "deobfuscate"; then
        pass "Deobfuscate command documented"
    else
        fail "Deobfuscate command not documented"
    fi

    echo ""
}

# =============================================================================
# CLEANUP AND RESULTS
# =============================================================================
cleanup() {
    # Clean up test directory
    rm -rf "$TEST_DIR"
}

show_results() {
    echo -e "${BLUE}=== Test Results ===${NC}"
    echo ""
    echo -e "Passed:  ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:  ${RED}$TESTS_FAILED${NC}"
    echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
    echo ""

    local total=$((TESTS_PASSED + TESTS_FAILED))
    if [[ $total -gt 0 ]]; then
        local percentage=$((TESTS_PASSED * 100 / total))
        echo -e "Success Rate: ${percentage}%"
    fi

    # Create results JSON
    cat > "$RESULTS_FILE" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "results": {
    "passed": $TESTS_PASSED,
    "failed": $TESTS_FAILED,
    "skipped": $TESTS_SKIPPED,
    "total": $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
  },
  "success_rate": $(if [[ $total -gt 0 ]]; then echo "$((TESTS_PASSED * 100 / total))"; else echo "0"; fi)
}
EOF

    echo ""
    echo "Results saved to: $RESULTS_FILE"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        return 1
    fi
    return 0
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    setup

    test_crx_extraction
    test_js_deobfuscation
    test_macos_app
    test_re_automation
    test_api_research
    test_auto_analyze
    test_skill_interface

    show_results
    local result=$?

    # Don't cleanup so user can inspect
    # cleanup

    exit $result
}

main "$@"
