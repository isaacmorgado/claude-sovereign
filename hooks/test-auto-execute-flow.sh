#!/bin/bash
# Test Auto-Execute Flow - Verify autonomous checkpoint execution
# Tests Issue #1 fix: Router → auto-continue → Claude skill execution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTO_CONTINUE="${SCRIPT_DIR}/auto-continue.sh"
ROUTER="${SCRIPT_DIR}/autonomous-command-router.sh"
TEST_LOG="/tmp/auto-execute-test-$(date +%s).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$TEST_LOG"
}

pass() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$TEST_LOG"
}

fail() {
    echo -e "${RED}✗${NC} $1" | tee -a "$TEST_LOG"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1" | tee -a "$TEST_LOG"
}

# ============================================================================
# TEST 1: Router Decision in Autonomous Mode
# ============================================================================
test_router_autonomous() {
    log "TEST 1: Router decision in autonomous mode"

    # Enable autonomous mode
    touch "${HOME}/.claude/autonomous-mode.active"

    # Call router
    result=$("$ROUTER" execute checkpoint_context "80000/200000" 2>/dev/null || echo '{}')

    # Check for execute_skill
    execute_skill=$(echo "$result" | jq -r '.execute_skill // ""')
    autonomous=$(echo "$result" | jq -r '.autonomous // ""')

    if [[ "$execute_skill" == "checkpoint" ]] && [[ "$autonomous" == "true" ]]; then
        pass "Router outputs execute_skill=checkpoint in autonomous mode"
        return 0
    else
        fail "Router failed to signal checkpoint execution"
        echo "Router output: $result"
        return 1
    fi
}

# ============================================================================
# TEST 2: Router Decision in Normal Mode
# ============================================================================
test_router_normal() {
    log "TEST 2: Router decision in normal mode"

    # Disable autonomous mode
    rm -f "${HOME}/.claude/autonomous-mode.active"

    # Call router
    result=$("$ROUTER" execute checkpoint_context "80000/200000" 2>/dev/null || echo '{}')

    # Check for advisory (not execute_skill)
    advisory=$(echo "$result" | jq -r '.advisory // ""')
    has_execute=$(echo "$result" | jq 'has("execute_skill")')

    if [[ -n "$advisory" ]] && [[ "$has_execute" == "false" ]]; then
        pass "Router outputs advisory in normal mode (no auto-execute)"
        return 0
    else
        fail "Router incorrectly signaled execution in normal mode"
        echo "Router output: $result"
        echo "Has execute_skill: $has_execute"
        return 1
    fi
}

# ============================================================================
# TEST 3: Auto-Continue Integration (Autonomous Mode)
# ============================================================================
test_auto_continue_autonomous() {
    log "TEST 3: Auto-continue integration in autonomous mode"

    # Enable autonomous mode
    touch "${HOME}/.claude/autonomous-mode.active"

    # Create mock hook input (40% context usage)
    hook_input=$(cat <<'EOF'
{
    "context_window": {
        "context_window_size": 200000,
        "current_usage": {
            "input_tokens": 80000,
            "cache_creation_input_tokens": 0,
            "cache_read_input_tokens": 0
        }
    },
    "transcript_path": ""
}
EOF
)

    # Run auto-continue with mock input
    result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo '{}')

    # Check for autonomous_execution field
    autonomous_enabled=$(echo "$result" | jq -r '.autonomous_execution.enabled // false')
    skill=$(echo "$result" | jq -r '.autonomous_execution.skill // ""')
    prompt=$(echo "$result" | jq -r '.reason // ""')

    if [[ "$autonomous_enabled" == "true" ]] && [[ "$skill" == "checkpoint" ]]; then
        pass "Auto-continue signals autonomous checkpoint execution"

        # Check that prompt instructs Claude to use Skill tool
        if echo "$prompt" | grep -q "Skill tool"; then
            pass "Continuation prompt instructs Claude to call Skill tool"
            return 0
        else
            warn "Prompt doesn't mention Skill tool - Claude may not execute"
            echo "Prompt: $prompt"
            return 1
        fi
    else
        fail "Auto-continue failed to signal autonomous execution"
        echo "Result: $result"
        return 1
    fi
}

# ============================================================================
# TEST 4: Auto-Continue Integration (Normal Mode)
# ============================================================================
test_auto_continue_normal() {
    log "TEST 4: Auto-continue integration in normal mode"

    # Disable autonomous mode
    rm -f "${HOME}/.claude/autonomous-mode.active"

    # Create mock hook input (40% context usage)
    hook_input=$(cat <<'EOF'
{
    "context_window": {
        "context_window_size": 200000,
        "current_usage": {
            "input_tokens": 80000,
            "cache_creation_input_tokens": 0,
            "cache_read_input_tokens": 0
        }
    },
    "transcript_path": ""
}
EOF
)

    # Run auto-continue with mock input
    result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo '{}')

    # Check that autonomous_execution is NOT present
    autonomous_enabled=$(echo "$result" | jq -r '.autonomous_execution.enabled // "not_present"')
    prompt=$(echo "$result" | jq -r '.reason // ""')

    if [[ "$autonomous_enabled" == "not_present" || "$autonomous_enabled" == "false" ]]; then
        pass "Auto-continue doesn't signal autonomous execution in normal mode"

        # Check that prompt suggests checkpoint as recommendation
        if echo "$prompt" | grep -qi "recommendation.*checkpoint"; then
            pass "Continuation prompt recommends checkpoint to user"
            return 0
        else
            warn "Prompt doesn't recommend checkpoint clearly"
            echo "Prompt: $prompt"
            return 1
        fi
    else
        fail "Auto-continue incorrectly signaled autonomous execution in normal mode"
        echo "Result: $result"
        return 1
    fi
}

# ============================================================================
# TEST 5: Prompt Content Verification
# ============================================================================
test_prompt_content() {
    log "TEST 5: Prompt content verification"

    # Enable autonomous mode
    touch "${HOME}/.claude/autonomous-mode.active"

    # Create mock hook input
    hook_input=$(cat <<'EOF'
{
    "context_window": {
        "context_window_size": 200000,
        "current_usage": {
            "input_tokens": 82000,
            "cache_creation_input_tokens": 0,
            "cache_read_input_tokens": 0
        }
    },
    "transcript_path": ""
}
EOF
)

    # Run auto-continue
    result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo '{}')
    prompt=$(echo "$result" | jq -r '.reason // ""')

    # Check for required elements
    checks=0
    if echo "$prompt" | grep -q "Skill tool"; then
        pass "Prompt mentions Skill tool"
        ((checks++))
    else
        fail "Prompt missing Skill tool instruction"
    fi

    if echo "$prompt" | grep -q 'skill="checkpoint"'; then
        pass "Prompt specifies skill=\"checkpoint\""
        ((checks++))
    else
        fail "Prompt missing skill=\"checkpoint\" parameter"
    fi

    if echo "$prompt" | grep -qi "autonomous.*execute\|immediately"; then
        pass "Prompt indicates autonomous execution mode"
        ((checks++))
    else
        warn "Prompt doesn't clearly indicate autonomous mode"
    fi

    if [[ $checks -ge 2 ]]; then
        return 0
    else
        fail "Prompt content insufficient for Claude to execute"
        echo "Prompt: $prompt"
        return 1
    fi
}

# ============================================================================
# TEST 6: End-to-End Flow Simulation
# ============================================================================
test_e2e_flow() {
    log "TEST 6: End-to-end flow simulation"

    # Enable autonomous mode
    touch "${HOME}/.claude/autonomous-mode.active"

    log "  Step 1: Context reaches 40% threshold"
    hook_input=$(cat <<'EOF'
{
    "context_window": {
        "context_window_size": 200000,
        "current_usage": {
            "input_tokens": 80000,
            "cache_creation_input_tokens": 0,
            "cache_read_input_tokens": 0
        }
    },
    "transcript_path": ""
}
EOF
)

    log "  Step 2: Auto-continue hook triggered"
    result=$(echo "$hook_input" | "$AUTO_CONTINUE" 2>/dev/null || echo '{}')

    log "  Step 3: Verify router was called"
    if grep -q "Router decided: Auto-execute /checkpoint" "${HOME}/.claude/auto-continue.log" 2>/dev/null; then
        pass "Router was called and logged decision"
    else
        warn "Router call not logged (may not have been invoked)"
    fi

    log "  Step 4: Verify continuation prompt generated"
    prompt=$(echo "$result" | jq -r '.reason // ""')
    if [[ -n "$prompt" ]]; then
        pass "Continuation prompt generated"
    else
        fail "No continuation prompt in output"
        return 1
    fi

    log "  Step 5: Verify autonomous execution metadata"
    exec_enabled=$(echo "$result" | jq -r '.autonomous_execution.enabled // false')
    if [[ "$exec_enabled" == "true" ]]; then
        pass "Autonomous execution metadata present"
    else
        fail "Autonomous execution metadata missing"
        return 1
    fi

    log "  Step 6: Simulate Claude receiving prompt"
    if echo "$prompt" | grep -q "Skill tool.*checkpoint"; then
        pass "Claude would receive instruction to call Skill tool"
        pass "E2E flow complete: Router → Auto-continue → Claude execution"
        return 0
    else
        fail "Claude prompt insufficient for execution"
        return 1
    fi
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "=========================================="
echo "Auto-Execute Flow Test Suite"
echo "Testing Issue #1 Fix"
echo "=========================================="
echo ""

total=0
passed=0

run_test() {
    local name="$1"
    local func="$2"

    echo ""
    ((total++))
    if $func; then
        ((passed++))
    fi
}

run_test "Router Autonomous Mode" test_router_autonomous
run_test "Router Normal Mode" test_router_normal
run_test "Auto-Continue Autonomous" test_auto_continue_autonomous
run_test "Auto-Continue Normal" test_auto_continue_normal
run_test "Prompt Content" test_prompt_content
run_test "End-to-End Flow" test_e2e_flow

# Cleanup
rm -f "${HOME}/.claude/autonomous-mode.active"

echo ""
echo "=========================================="
echo "Results: $passed/$total tests passed"
echo "=========================================="
echo ""
echo "Test log: $TEST_LOG"

if [[ $passed -eq $total ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo ""
    echo "The autonomous execution mechanism is working:"
    echo "1. ✓ Router detects autonomous mode and outputs execute_skill"
    echo "2. ✓ Auto-continue integrates router decision"
    echo "3. ✓ Continuation prompt instructs Claude to call Skill tool"
    echo "4. ✓ Metadata includes execution context"
    echo ""
    echo "Next: Test in production by:"
    echo "  1. Run: /auto (enable autonomous mode)"
    echo "  2. Work until context hits 40%"
    echo "  3. Verify /checkpoint executes automatically"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    echo "Check log for details: $TEST_LOG"
    exit 1
fi
