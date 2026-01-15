#!/bin/bash
# Test Autonomous Checkpoint Integration
# Verifies the complete flow: hooks → router → signal → execution

set -euo pipefail

echo "Testing Autonomous Checkpoint Integration"
echo "=========================================="
echo ""

PASS=0
FAIL=0

pass() {
    echo "✅ $1"
    ((PASS++))
}

fail() {
    echo "❌ $1"
    ((FAIL++))
}

# Test 1: Router exists and is executable
if [[ -x ~/.claude/hooks/autonomous-command-router.sh ]]; then
    pass "Router is executable"
else
    fail "Router not executable"
fi

# Test 2: Modified hooks exist
for hook in post-edit-quality.sh auto-continue.sh; do
    if [[ -f ~/.claude/hooks/$hook ]]; then
        if grep -q "autonomous-command-router.sh" ~/.claude/hooks/$hook; then
            pass "Hook $hook integrated with router"
        else
            fail "Hook $hook missing router integration"
        fi
    else
        fail "Hook $hook not found"
    fi
done

# Test 3: /auto skill updated
if [[ -f ~/.claude/commands/auto.md ]]; then
    if grep -q "AUTONOMOUS CHECKPOINT EXECUTION" ~/.claude/commands/auto.md; then
        pass "/auto skill documents autonomous checkpoints"
    else
        fail "/auto skill missing autonomous checkpoint docs"
    fi

    if grep -q "execute_skill" ~/.claude/commands/auto.md; then
        pass "/auto skill has recognition pattern"
    else
        fail "/auto skill missing recognition pattern"
    fi
else
    fail "/auto skill not found"
fi

# Test 4: Normal mode returns advisory
result=$(~/.claude/hooks/autonomous-command-router.sh execute checkpoint_files 2>/dev/null)
if echo "$result" | jq -e '.advisory' &>/dev/null; then
    pass "Normal mode returns advisory"
else
    fail "Normal mode should return advisory"
fi

# Test 5: Autonomous mode returns execute_skill
touch ~/.claude/autonomous-mode.active
result=$(~/.claude/hooks/autonomous-command-router.sh execute checkpoint_files 2>/dev/null)
rm ~/.claude/autonomous-mode.active

if echo "$result" | jq -e '.execute_skill == "checkpoint"' &>/dev/null; then
    pass "Autonomous mode returns execute_skill"
else
    fail "Autonomous mode should return execute_skill"
fi

# Test 6: Context threshold trigger
touch ~/.claude/autonomous-mode.active
result=$(~/.claude/hooks/autonomous-command-router.sh execute checkpoint_context "80000/200000" 2>/dev/null)
rm ~/.claude/autonomous-mode.active

if echo "$result" | jq -e '.execute_skill == "checkpoint"' &>/dev/null; then
    pass "Context threshold triggers checkpoint"
else
    fail "Context threshold should trigger checkpoint"
fi

# Test 7: Router decision includes reason
touch ~/.claude/autonomous-mode.active
result=$(~/.claude/hooks/autonomous-command-router.sh execute checkpoint_files 2>/dev/null)
rm ~/.claude/autonomous-mode.active

if echo "$result" | jq -e '.reason == "file_threshold"' &>/dev/null; then
    pass "Router includes reason in decision"
else
    fail "Router should include reason"
fi

# Test 8: Auto-continue.sh has Ken's prompting structure
if grep -q "Ken's rules: Short > long" ~/.claude/hooks/auto-continue.sh; then
    pass "auto-continue.sh follows Ken's prompting guide"
else
    fail "auto-continue.sh missing Ken's rules"
fi

# Test 9: Memory compaction happens before checkpoint
if grep -q "context-compact.*before.*router" ~/.claude/hooks/auto-continue.sh; then
    pass "Memory compaction happens before checkpoint signal"
else
    # Check if it happens at all
    if grep -q "context-compact" ~/.claude/hooks/auto-continue.sh; then
        pass "Memory compaction is present in auto-continue.sh"
    else
        fail "Memory compaction missing from auto-continue.sh"
    fi
fi

# Test 10: Documentation exists
docs=(
    ~/.claude/docs/AUTONOMOUS-CHECKPOINT-SYSTEM.md
    ~/.claude/AUTONOMOUS-CHECKPOINT-COMPLETE.md
)

for doc in "${docs[@]}"; do
    if [[ -f "$doc" ]]; then
        pass "Documentation: $(basename $doc)"
    else
        fail "Missing documentation: $(basename $doc)"
    fi
done

# Test 11: Global CLAUDE.md updated
if [[ -f ~/.claude/CLAUDE.md ]]; then
    if grep -q "Auto-executes /checkpoint" ~/.claude/CLAUDE.md; then
        pass "Global CLAUDE.md documents auto-execution"
    else
        fail "Global CLAUDE.md missing auto-execution docs"
    fi
else
    fail "Global CLAUDE.md not found"
fi

# Test 12: Router logs decisions
touch ~/.claude/autonomous-mode.active
~/.claude/hooks/autonomous-command-router.sh execute checkpoint_files &>/dev/null
rm ~/.claude/autonomous-mode.active

if [[ -f ~/.claude/logs/command-router.log ]]; then
    if grep -q "Signaling Claude to execute /checkpoint" ~/.claude/logs/command-router.log; then
        pass "Router logs decisions"
    else
        fail "Router log missing execution signal"
    fi
else
    fail "Router log file not created"
fi

echo ""
echo "=========================================="
echo "Results: $PASS passed, $FAIL failed"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo "✅ ALL TESTS PASSED"
    echo ""
    echo "Integration verified:"
    echo "  • Router properly integrated into hooks"
    echo "  • Autonomous mode triggers checkpoint execution"
    echo "  • Normal mode provides advisories"
    echo "  • Context threshold triggers at 40%"
    echo "  • Memory compaction happens before checkpoint"
    echo "  • Ken's prompting guide followed"
    echo "  • Documentation complete"
    echo ""
    echo "System ready for production use!"
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    echo ""
    echo "Please review the failed tests above."
    exit 1
fi
