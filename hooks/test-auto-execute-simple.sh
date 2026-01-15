#!/bin/bash
# Simple Auto-Execute Flow Test
# Verifies Issue #1 fix: Router → auto-continue → Claude execution signal

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo "=========================================="
echo "Auto-Execute Flow - Simple Test"
echo "=========================================="
echo ""

# ============================================================================
# TEST 1: Router in Autonomous Mode
# ============================================================================
echo "TEST 1: Router Decision (Autonomous Mode)"
touch ~/.claude/autonomous-mode.active
result=$(~/.claude/hooks/autonomous-command-router.sh execute checkpoint_context "80000/200000" 2>/dev/null)

if echo "$result" | jq -e '.execute_skill == "checkpoint"' >/dev/null 2>&1; then
    pass "Router outputs execute_skill=checkpoint"
else
    fail "Router failed: $result"
fi

# ============================================================================
# TEST 2: Router in Normal Mode
# ============================================================================
echo "TEST 2: Router Decision (Normal Mode)"
rm -f ~/.claude/autonomous-mode.active
result=$(~/.claude/hooks/autonomous-command-router.sh execute checkpoint_context "80000/200000" 2>/dev/null)

if echo "$result" | jq -e 'has("execute_skill") | not' >/dev/null 2>&1 && \
   echo "$result" | jq -e '.advisory' >/dev/null 2>&1; then
    pass "Router outputs advisory only (no execution)"
else
    fail "Router failed: $result"
fi

# ============================================================================
# TEST 3: Auto-Continue Integration (Autonomous)
# ============================================================================
echo "TEST 3: Auto-Continue (Autonomous Mode)"
touch ~/.claude/autonomous-mode.active

cat > /tmp/hook-input.json <<'EOF'
{"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":80000,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}},"transcript_path":""}
EOF

result=$(cat /tmp/hook-input.json | ~/.claude/hooks/auto-continue.sh 2>/dev/null)

# Check autonomous_execution.enabled
if echo "$result" | jq -e '.autonomous_execution.enabled == true' >/dev/null 2>&1; then
    pass "Auto-continue signals autonomous execution"
else
    fail "Auto-continue missing autonomous_execution: $(echo "$result" | jq -c '.autonomous_execution // {}')"
fi

# Check skill name
if echo "$result" | jq -e '.autonomous_execution.skill == "checkpoint"' >/dev/null 2>&1; then
    pass "Skill set to 'checkpoint'"
else
    fail "Skill not set correctly"
fi

# Check prompt instructs Claude
prompt=$(echo "$result" | jq -r '.reason')
if echo "$prompt" | grep -q "Skill tool"; then
    pass "Prompt instructs Claude to use Skill tool"
else
    fail "Prompt missing Skill tool instruction"
fi

# ============================================================================
# TEST 4: Auto-Continue Integration (Normal)
# ============================================================================
echo "TEST 4: Auto-Continue (Normal Mode)"
rm -f ~/.claude/autonomous-mode.active

result=$(cat /tmp/hook-input.json | ~/.claude/hooks/auto-continue.sh 2>/dev/null)

# Check that autonomous_execution is NOT enabled
if echo "$result" | jq -e '.autonomous_execution.enabled == true' >/dev/null 2>&1; then
    fail "Auto-continue incorrectly enabled autonomous execution in normal mode"
else
    pass "Auto-continue doesn't enable autonomous execution"
fi

# Check prompt recommends checkpoint
prompt=$(echo "$result" | jq -r '.reason')
if echo "$prompt" | grep -qi "recommendation.*checkpoint\|run /checkpoint"; then
    pass "Prompt recommends checkpoint to user"
else
    fail "Prompt doesn't recommend checkpoint"
fi

# ============================================================================
# TEST 5: End-to-End Flow
# ============================================================================
echo "TEST 5: End-to-End Flow"
touch ~/.claude/autonomous-mode.active

# Simulate full flow
result=$(cat /tmp/hook-input.json | ~/.claude/hooks/auto-continue.sh 2>/dev/null)

# Verify all components present
checks=0

if echo "$result" | jq -e '.decision == "block"' >/dev/null 2>&1; then
    pass "Decision: block (prevents stop)"
    ((checks++))
fi

if echo "$result" | jq -e '.autonomous_execution.router_decision.execute_skill == "checkpoint"' >/dev/null 2>&1; then
    pass "Router decision embedded in output"
    ((checks++))
fi

sys_msg=$(echo "$result" | jq -r '.systemMessage')
if echo "$sys_msg" | grep -q "Auto-executing"; then
    pass "System message indicates autonomous execution"
    ((checks++))
fi

prompt=$(echo "$result" | jq -r '.reason')
if echo "$prompt" | grep -q 'skill="checkpoint"'; then
    pass "Prompt includes skill parameter format"
    ((checks++))
fi

if [[ $checks -eq 4 ]]; then
    pass "All flow components working"
else
    fail "Only $checks/4 components working"
fi

# Cleanup
rm -f ~/.claude/autonomous-mode.active /tmp/hook-input.json

echo ""
echo "=========================================="
echo -e "${GREEN}All tests passed!${NC}"
echo "=========================================="
echo ""
echo "✅ Router correctly signals execution in autonomous mode"
echo "✅ Router outputs advisory only in normal mode"
echo "✅ Auto-continue integrates router decision"
echo "✅ Continuation prompt instructs Claude to call Skill tool"
echo "✅ End-to-end flow complete"
echo ""
echo "Next steps:"
echo "1. Enable autonomous mode: /auto"
echo "2. Work until context hits 40%"
echo "3. Verify /checkpoint executes automatically"
echo ""
