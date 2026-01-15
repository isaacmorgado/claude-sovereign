#!/bin/bash
# =============================================================================
# TEST SUITE: Deep Debug & Auto-Research Verification
# Purpose: Comprehensively test 'smart_debug', 'extract_error_signature', and 
#          'expand_search_horizons' across various edge cases.
# =============================================================================

# Load the orchestrator directly to access internal functions for unit testing
source ~/.claude/hooks/debug-orchestrator.sh

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

LOG_FILE="test_deep_debug_results.log"
rm -f "$LOG_FILE"

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1" | tee -a "$LOG_FILE"
}

pass() {
    echo -e "${GREEN}[PASS]${NC} $1" | tee -a "$LOG_FILE"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1" | tee -a "$LOG_FILE"
}

# Mock Environment
export GITHUB_MCP_AVAILABLE="true"
mkdir -p ./mock_codebase/src
mkdir -p ./mock_codebase/server

# Create mock files for Grep MCP to find
echo "function authenticateUser(token) { if (!token) throw new Error('Invalid Token'); }" > ./mock_codebase/src/auth.js
echo "def calculate_risk(data): raise ValueError('Data corrupted')" > ./mock_codebase/server/risk.py
echo "dummy binary content" > ./mock_codebase/unknown.bin

# =============================================================================
# SCENARIO 1: Specific Console Error (Stack Trace)
# =============================================================================
log_test "Scenario 1: Specific Console Error (Stack Trace Extraction)"

error_input="Error: Invalid Token in ./mock_codebase/src/auth.js:1"

# 1. Test Extraction Logic
extracted_json=$(extract_error_signature "$error_input" | grep "^{" | jq '.' || echo "{}")
path_found=$(echo "$extracted_json" | jq -r '.file_location // empty')
error_found=$(echo "$extracted_json" | jq -r '.extracted_error // empty')
context_found=$(echo "$extracted_json" | jq -r '.codebase_context // empty')

if [[ "$path_found" == *"auth.js:1"* ]]; then
    pass "Correctly extracted file path: $path_found"
else
    fail "Failed to extract path. Got: $path_found"
fi

if [[ "$context_found" == *"authenticateUser"* ]]; then
    pass "Grep MCP simulation found code context!"
else
    fail "Grep MCP failed to find context. Got: $context_found"
fi

# =============================================================================
# SCENARIO 2: UI/Frontend Issue (Vague Description)
# =============================================================================
log_test "Scenario 2: UI/Frontend Issue (Smart Web Search Query)"

# Calling expand_search directly to verify query construction
search_results=$(expand_search_horizons "The login button is not clickable" "React Frontend" | grep "^{" | jq '.')
web_query=$(echo "$search_results" | jq -r '.deep_search_results.web_search_recommendation.query')

if [[ "$web_query" == *"React Frontend"* ]]; then
    pass "Web query correctly included context: $web_query"
else
    fail "Web query missing context. Got: $web_query"
fi

# =============================================================================
# SCENARIO 3: Middleware/Backend (GitHub Issue Search)
# =============================================================================
log_test "Scenario 3: Middleware/Backend (GitHub Issue Integration)"

# We expect the system to attempt a GitHub search.
# Since we might not have 'gh' in this sanitized test env, we check the JSON stru# Scenario 3
debug_output=$(smart_debug "Middleware timeout" "Backend" "echo test" "Express.js" | grep "^{" | jq '.' || echo "{}")
issues_field=$(echo "$debug_output" | jq -r '.deep_search_results.github_issues')

if [[ "$issues_field" != "null" ]]; then
    pass "GitHub issues field is present in output"
else
    fail "GitHub issues field missing"
fi

# =============================================================================
# SCENARIO 4: Reverse Engineering / Unknown Error
# =============================================================================
log_test "Scenario 4: Reverse Engineering / Unknown Error"

# Simulate a weird binary parsing error
re_error="panic: runtime error: invalid memory address or nil pointer dereference"
re_json=$(extract_error_signature "$re_error" | grep "^{" | jq '.')
extracted_panic=$(echo "$re_json" | jq -r '.extracted_error')

if [[ "$extracted_panic" == *"panic: runtime error"* ]]; then
    pass "Correctly identified Panic signature"
else
    fail "Failed to identify panic. Got: $extracted_panic"
fi

# =============================================================================
# SCENARIO 5: Specific App Context Error (User Example)
# =============================================================================
log_test "Scenario 5: Specific App Context ('select a clip in the sequence')"

app_context="Premiere Pro"
specific_error="select a clip in the sequence"

# Test Web Search Query Construction
search_results_app=$(expand_search_horizons "$specific_error" "$app_context" | grep "^{" | jq '.')
app_query=$(echo "$search_results_app" | jq -r '.deep_search_results.web_search_recommendation.query')
is_specific=$(echo "$search_results_app" | jq -r '.deep_search_results.web_search_recommendation.is_error_search')

if [[ "$app_query" == *"Premiere Pro select a clip"* ]]; then
    pass "Query includes App Context + Error"
else
    fail "Query malformed. Got: $app_query"
fi

if [[ "$is_specific" == "true" ]]; then
    pass "Heuristic correctly identified specific error message (long string)"
else
    fail "Heuristic failed to identify specific error"
fi


# =============================================================================
# SCENARIO 6: Full Report Generation
# =============================================================================
log_test "Scenario 6: Full Visual Report Generation"

report_output=$(smart_debug "ReferenceError: x is not defined" "JS Error" "true" "Node.js context" | grep "^{" | jq '.')
markdown_report=$(generate_debug_report "$report_output")

echo "--- REPORT SAMPLE ---"
echo "$markdown_report"
echo "---------------------"

if [[ "$markdown_report" == *"# 🐞 Debug Report"* ]]; then
    pass "Markdown report header generated"
else
    fail "Markdown report missing header"
fi

if [[ "$markdown_report" == *"GitHub Issues"* ]]; then
    pass "Report includes GitHub section"
else
    fail "Report missing GitHub section"
fi

# Cleanup
rm -rf ./mock_codebase
echo -e "${YELLOW}Tests Completed. See $LOG_FILE for details.${NC}"
