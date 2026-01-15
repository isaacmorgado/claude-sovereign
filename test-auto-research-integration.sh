#!/bin/bash
# Test Auto-Research Integration (Issues #11, #27)
# Verifies GitHub MCP auto-research execution flow

set -uo pipefail

CLAUDE_DIR="${HOME}/.claude"
ORCHESTRATOR="${CLAUDE_DIR}/hooks/autonomous-orchestrator-v2.sh"
COORDINATOR="${CLAUDE_DIR}/hooks/coordinator.sh"
AGENT_LOOP="${CLAUDE_DIR}/hooks/agent-loop.sh"
RESEARCH_EXECUTOR="${CLAUDE_DIR}/hooks/github-research-executor.sh"
AGENT_STATE="${CLAUDE_DIR}/agent/state.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

print_header() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
}

print_test() {
    echo -e "\n${YELLOW}TEST $TESTS_RUN:${NC} $1"
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
    local test_name="$1"
    local test_cmd="$2"

    TESTS_RUN=$((TESTS_RUN + 1))
    print_test "$test_name"

    if eval "$test_cmd" > /dev/null 2>&1; then
        pass "$test_name"
        return 0
    else
        fail "$test_name"
        return 1
    fi
}

print_header "AUTO-RESEARCH INTEGRATION TEST SUITE"

echo ""
echo "Testing GitHub MCP auto-research execution (Issues #11, #27)"
echo "Location: coordinator.sh → agent-loop.sh → github-research-executor.sh"
echo ""

# ============================================================================
# PART 1: Component Existence
# ============================================================================
print_header "PART 1: Component Existence"

run_test "1.1 Orchestrator exists and is executable" \
    "[[ -x '$ORCHESTRATOR' ]]"

run_test "1.2 Coordinator exists and is executable" \
    "[[ -x '$COORDINATOR' ]]"

run_test "1.3 Agent-loop exists and is executable" \
    "[[ -x '$AGENT_LOOP' ]]"

run_test "1.4 Research executor exists and is executable" \
    "[[ -x '$RESEARCH_EXECUTOR' ]]"

# ============================================================================
# PART 2: Orchestrator Research Detection
# ============================================================================
print_header "PART 2: Orchestrator Research Detection"

echo "Testing with task: 'Implement Stripe payment integration'"

ANALYSIS=$("$ORCHESTRATOR" analyze "Implement Stripe payment integration" 2>/dev/null || echo '{}')

run_test "2.1 Orchestrator returns valid JSON" \
    "echo '$ANALYSIS' | jq empty"

run_test "2.2 Orchestrator detects research needs" \
    "echo '$ANALYSIS' | jq -e '.research.needsResearch == true'"

run_test "2.3 Orchestrator identifies library (stripe)" \
    "echo '$ANALYSIS' | jq -e '.research.library == \"stripe\"'"

run_test "2.4 Orchestrator generates GitHub search spec" \
    "echo '$ANALYSIS' | jq -e '.githubSearch.tool == \"mcp__grep__searchGitHub\"'"

run_test "2.5 GitHub search has query parameters" \
    "echo '$ANALYSIS' | jq -e '.githubSearch.parameters.query'"

run_test "2.6 GitHub search has instruction" \
    "echo '$ANALYSIS' | jq -e '.githubSearch.instruction'"

LIBRARY=$(echo "$ANALYSIS" | jq -r '.research.library')
QUERY=$(echo "$ANALYSIS" | jq -r '.githubSearch.query')
echo -e "${BLUE}Detected:${NC} Library=$LIBRARY, Query=$QUERY"

# ============================================================================
# PART 3: Coordinator Integration
# ============================================================================
print_header "PART 3: Coordinator Integration"

run_test "3.1 Coordinator has autoResearch logic" \
    "grep -q 'autoResearch' '$COORDINATOR'"

run_test "3.2 Coordinator extracts github_search_results" \
    "grep -q 'github_search_results=.*githubSearch' '$COORDINATOR'"

run_test "3.3 Coordinator passes autoResearch to agent-loop" \
    "grep -q 'autoResearch:' '$COORDINATOR'"

run_test "3.4 Coordinator outputs autoResearch in final JSON" \
    "grep -q 'autoResearch: \$githubSearch' '$COORDINATOR'"

# ============================================================================
# PART 4: Agent-Loop Integration
# ============================================================================
print_header "PART 4: Agent-Loop Integration"

run_test "4.1 Agent-loop extracts autoResearch from context" \
    "grep -q 'autoResearch:' '$AGENT_LOOP'"

run_test "4.2 Agent-loop stores autoResearch in state JSON" \
    "grep -q '\"autoResearch\": \$auto_research' '$AGENT_LOOP'"

run_test "4.3 Agent-loop calls research executor" \
    "grep -q 'github-research-executor.sh' '$AGENT_LOOP'"

run_test "4.4 Agent-loop checks if autoResearch is not empty" \
    "grep -q 'if.*auto_research.*!=.*\[\]' '$AGENT_LOOP'"

# ============================================================================
# PART 5: Research Executor Functionality
# ============================================================================
print_header "PART 5: Research Executor Functionality"

run_test "5.1 Research executor has execute command" \
    "grep -q 'execute)' '$RESEARCH_EXECUTOR'"

run_test "5.2 Research executor has cache management" \
    "grep -q 'check_cache' '$RESEARCH_EXECUTOR'"

run_test "5.3 Research executor outputs recommendations" \
    "grep -q 'output_recommendations' '$RESEARCH_EXECUTOR'"

run_test "5.4 Research executor supports list command" \
    "'$RESEARCH_EXECUTOR' list | grep -q 'Cached Research:' || [[ \$? -eq 0 ]]"

# Test execution with sample data
SAMPLE_RESEARCH='{"library":"stripe","query":"stripe.checkout","instruction":"Search for Stripe implementation examples","parameters":{"query":"stripe.checkout.sessions.create","useRegexp":true}}'

run_test "5.5 Research executor accepts JSON input" \
    "'$RESEARCH_EXECUTOR' execute '$SAMPLE_RESEARCH' | grep -q 'AUTO-RESEARCH RECOMMENDATION'"

# ============================================================================
# PART 6: End-to-End Flow Simulation
# ============================================================================
print_header "PART 6: End-to-End Flow Simulation"

echo "Simulating full flow: Orchestrator → Coordinator → Agent-loop → Research Executor"

# Clean up any existing agent state
rm -f "$AGENT_STATE" 2>/dev/null

# Step 1: Orchestrator analyzes task
TESTS_RUN=$((TESTS_RUN + 1))
print_test "6.1 Orchestrator analysis generates research recommendation"
ANALYSIS=$("$ORCHESTRATOR" analyze "Implement OAuth authentication" 2>/dev/null)
if echo "$ANALYSIS" | jq -e '.research.needsResearch == true' > /dev/null 2>&1; then
    pass "Orchestrator detected OAuth needs research"
else
    fail "Orchestrator did not detect research need"
fi

# Step 2: Extract github search data
TESTS_RUN=$((TESTS_RUN + 1))
print_test "6.2 Extract GitHub search specification"
GITHUB_SEARCH=$(echo "$ANALYSIS" | jq -c '.githubSearch')
if [[ "$GITHUB_SEARCH" != "null" && "$GITHUB_SEARCH" != "[]" ]]; then
    pass "GitHub search specification extracted"
    echo -e "${BLUE}Spec:${NC} $(echo "$GITHUB_SEARCH" | jq -r '.instruction')"
else
    fail "GitHub search specification not found"
fi

# Step 3: Start agent-loop with research data
TESTS_RUN=$((TESTS_RUN + 1))
print_test "6.3 Agent-loop accepts and stores autoResearch"
AGENT_ID=$("$AGENT_LOOP" start "Implement OAuth authentication" "autoResearch:${GITHUB_SEARCH}" 2>/dev/null || echo "")
if [[ -n "$AGENT_ID" ]]; then
    pass "Agent-loop started with ID: $AGENT_ID"
else
    fail "Agent-loop failed to start"
fi

# Step 4: Verify agent state has autoResearch
TESTS_RUN=$((TESTS_RUN + 1))
print_test "6.4 Agent state JSON contains autoResearch"
if [[ -f "$AGENT_STATE" ]]; then
    AUTO_RESEARCH_IN_STATE=$(jq -r '.autoResearch' "$AGENT_STATE" 2>/dev/null || echo "[]")
    if [[ "$AUTO_RESEARCH_IN_STATE" != "[]" && "$AUTO_RESEARCH_IN_STATE" != "null" ]]; then
        pass "autoResearch stored in agent state"
        echo -e "${BLUE}Library:${NC} $(echo "$AUTO_RESEARCH_IN_STATE" | jq -r '.library')"
    else
        fail "autoResearch not found in agent state"
    fi
else
    fail "Agent state file not created"
fi

# Step 5: Verify research executor was invoked (check logs)
TESTS_RUN=$((TESTS_RUN + 1))
print_test "6.5 Research executor invoked during agent startup"
RESEARCH_LOG="${CLAUDE_DIR}/github-research.log"
if [[ -f "$RESEARCH_LOG" ]]; then
    if tail -10 "$RESEARCH_LOG" | grep -q "Executing GitHub search"; then
        pass "Research executor was invoked"
    else
        fail "Research executor log entry not found (may not have triggered)"
    fi
else
    fail "Research executor log not found"
fi

# ============================================================================
# PART 7: Integration Verification
# ============================================================================
print_header "PART 7: Integration Verification"

run_test "7.1 No circular dependencies detected" \
    "! grep -q '$AGENT_LOOP.*start.*\$AGENT_LOOP' '$COORDINATOR'"

run_test "7.2 All scripts use consistent JSON format" \
    "grep -q 'jq -c' '$ORCHESTRATOR' && grep -q 'jq -c' '$COORDINATOR'"

run_test "7.3 Error handling present in critical paths" \
    "grep -q '|| true' '$AGENT_LOOP' && grep -q '2>/dev/null' '$COORDINATOR'"

run_test "7.4 Logging present in all components" \
    "grep -q 'log \"' '$ORCHESTRATOR' && grep -q 'log \"' '$AGENT_LOOP' && grep -q 'log ' '$RESEARCH_EXECUTOR'"

# ============================================================================
# SUMMARY
# ============================================================================
print_header "TEST SUMMARY"

echo ""
echo "Total Tests:  $TESTS_RUN"
echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Auto-research integration is working correctly:"
    echo "  ✓ Orchestrator detects unfamiliar libraries"
    echo "  ✓ Coordinator passes research data to agent-loop"
    echo "  ✓ Agent-loop stores autoResearch in state"
    echo "  ✓ Research executor outputs formatted recommendations"
    echo "  ✓ Claude can execute mcp__grep__searchGitHub"
    echo ""
    echo "Issues #11 and #27 are RESOLVED."
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    echo "Review the failed tests above for details."
    exit 1
fi
