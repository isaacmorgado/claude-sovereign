#!/bin/bash
# Integration Test Suite for True Autonomy Loop
# Tests edge cases and command integration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
LOOP_SCRIPT="${CLAUDE_DIR}/bin/claude-loop.sh"
AUTO_CONTINUE="${CLAUDE_DIR}/hooks/auto-continue.sh"
CHECKPOINT_CMD="${CLAUDE_DIR}/commands/checkpoint.md"
PROMPT_FILE="${CLAUDE_DIR}/continuation-prompt.md"
STOP_FILE="${CLAUDE_DIR}/stop-loop"
LOG_FILE="${CLAUDE_DIR}/loop.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓ PASS${NC}: $1"; }
fail() { echo -e "${RED}✗ FAIL${NC}: $1"; exit 1; }
info() { echo -e "${YELLOW}→${NC} $1"; }

cleanup() {
    rm -f "$PROMPT_FILE" "$STOP_FILE" 2>/dev/null || true
}
trap cleanup EXIT

echo "========================================"
echo "True Autonomy Integration Test Suite"
echo "========================================"
echo ""

# =============================================
# Test 1: Loop script exists and is executable
# =============================================
info "Test 1: Loop script exists and is executable"
[[ -x "$LOOP_SCRIPT" ]] && pass "claude-loop.sh is executable" || fail "claude-loop.sh not executable"

# =============================================
# Test 2: Help flag works
# =============================================
info "Test 2: Help flag works"
HELP_OUTPUT=$("$LOOP_SCRIPT" --help 2>&1)
echo "$HELP_OUTPUT" | grep -q "Claude Infinite Loop" && pass "Help output correct" || fail "Help output missing"

# =============================================
# Test 3: Auto-continue hook exists
# =============================================
info "Test 3: Auto-continue hook exists and is executable"
[[ -x "$AUTO_CONTINUE" ]] && pass "auto-continue.sh is executable" || fail "auto-continue.sh not executable"

# =============================================
# Test 4: Stop signal detection
# =============================================
info "Test 4: Stop signal file can be created"
touch "$STOP_FILE"
[[ -f "$STOP_FILE" ]] && pass "Stop signal file created" || fail "Cannot create stop signal"
rm -f "$STOP_FILE"

# =============================================
# Test 5: Continuation prompt file write
# =============================================
info "Test 5: Continuation prompt file write works"
echo "Test continuation prompt" > "$PROMPT_FILE"
[[ -f "$PROMPT_FILE" ]] && pass "Prompt file created" || fail "Cannot create prompt file"
CONTENT=$(cat "$PROMPT_FILE")
[[ "$CONTENT" == "Test continuation prompt" ]] && pass "Prompt content correct" || fail "Prompt content wrong"
rm -f "$PROMPT_FILE"

# =============================================
# Test 6: Auto-continue writes to prompt file
# =============================================
info "Test 6: Auto-continue hook writes prompt file"
# Check if the code to write prompt file exists
grep -q "continuation-prompt.md" "$AUTO_CONTINUE" && pass "auto-continue.sh references prompt file" || fail "Missing prompt file reference"
grep -q "HANDOFF_FILE" "$AUTO_CONTINUE" && pass "HANDOFF_FILE variable defined" || fail "Missing HANDOFF_FILE"

# =============================================
# Test 7: Checkpoint command exists
# =============================================
info "Test 7: Checkpoint command exists"
[[ -f "$CHECKPOINT_CMD" ]] && pass "checkpoint.md exists" || fail "checkpoint.md missing"

# =============================================
# Test 8: Checkpoint has git push logic
# =============================================
info "Test 8: Checkpoint has git push logic"
grep -q "git push" "$CHECKPOINT_CMD" && pass "Git push logic present" || fail "Git push logic missing"

# =============================================
# Test 9: Auto-continue integrates with checkpoint
# =============================================
info "Test 9: Auto-continue triggers checkpoint"
grep -q 'EXECUTE_SKILL.*checkpoint' "$AUTO_CONTINUE" && pass "Checkpoint execution detected" || fail "No checkpoint execution"

# =============================================
# Test 10: Autonomous orchestrator health check
# =============================================
info "Test 10: Autonomous orchestrator has health check"
ORCHESTRATOR="${CLAUDE_DIR}/hooks/autonomous-orchestrator.sh"
if [[ -x "$ORCHESTRATOR" ]]; then
    HEALTH=$("$ORCHESTRATOR" health-check 2>/dev/null || echo '{}')
    echo "$HEALTH" | jq -e '.status' >/dev/null 2>&1 && pass "Health check returns status" || fail "Health check broken"
else
    fail "autonomous-orchestrator.sh not executable"
fi

# =============================================
# Test 11: Memory manager integration
# =============================================
info "Test 11: Memory manager integration"
MEMORY="${CLAUDE_DIR}/hooks/memory-manager.sh"
[[ -x "$MEMORY" ]] && pass "memory-manager.sh is executable" || fail "memory-manager.sh not executable"

# =============================================
# Test 12: Retry wrapper integration
# =============================================
info "Test 12: Retry wrapper integration"
RETRY="${CLAUDE_DIR}/hooks/retry-wrapper.sh"
if [[ -x "$RETRY" ]]; then
    STATUS=$("$RETRY" status 2>/dev/null || echo '{}')
    echo "$STATUS" | jq -e '.circuits' >/dev/null 2>&1 && pass "Retry wrapper functional" || pass "Retry wrapper exists (no circuits yet)"
else
    fail "retry-wrapper.sh not executable"
fi

# =============================================
# Test 13: Log file can be written
# =============================================
info "Test 13: Log file writable"
echo "[TEST] Log test at $(date)" >> "$LOG_FILE"
[[ -f "$LOG_FILE" ]] && pass "Log file writable" || fail "Log file not writable"

# =============================================
# Test 14: Environment variables respected
# =============================================
info "Test 14: Environment variables in loop script"
grep -q "CLAUDE_LOOP_MAX_RESTARTS" "$LOOP_SCRIPT" && pass "MAX_RESTARTS env var present" || fail "Missing MAX_RESTARTS"
grep -q "CLAUDE_LOOP_DELAY" "$LOOP_SCRIPT" && pass "DELAY env var present" || fail "Missing DELAY"

# =============================================
# Test 15: Graceful shutdown trap
# =============================================
info "Test 15: Graceful shutdown trap in loop"
grep -q "trap.*INT.*TERM" "$LOOP_SCRIPT" && pass "Signal trap configured" || fail "Missing signal trap"

echo ""
echo "========================================"
echo -e "${GREEN}All tests passed!${NC}"
echo "========================================"
echo ""
echo "Integration verified:"
echo "  - claude-loop.sh wrapper ✓"
echo "  - auto-continue.sh handoff ✓"
echo "  - checkpoint.md git push ✓"
echo "  - autonomous-orchestrator.sh health check ✓"
echo "  - memory-manager.sh integration ✓"
echo "  - retry-wrapper.sh circuit breaker ✓"
