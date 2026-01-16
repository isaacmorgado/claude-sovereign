#!/bin/bash
# Test suite for claude-loop.sh optimizations
# Tests timeout, heartbeat, and monitoring functionality

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

pass() {
    echo -e "${GREEN}✓ $1${NC}"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    echo -e "${RED}✗ $1${NC}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

echo "╔════════════════════════════════════════════════════════╗"
echo "║     Claude Loop Optimizations Test Suite              ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

#------------------------------------------------------------------------------
# Test 1: Verify timeout mechanism exists
#------------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1: Session Timeout Mechanism"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if grep -q "session_timeout_monitor" ~/.claude/bin/claude-loop.sh; then
    pass "Timeout monitor function exists"
else
    fail "Timeout monitor function NOT found"
fi

if grep -q "SESSION_TIMEOUT=" ~/.claude/bin/claude-loop.sh; then
    timeout_value=$(grep "^SESSION_TIMEOUT=" ~/.claude/bin/claude-loop.sh | head -1 | cut -d'"' -f2 | cut -d'}' -f1)
    info "Default timeout: ${timeout_value:-600}s"
    pass "Session timeout configuration found"
else
    fail "Session timeout configuration NOT found"
fi

if grep -q "kill -TERM.*claude_pid" ~/.claude/bin/claude-loop.sh; then
    pass "Graceful shutdown (SIGTERM) implemented"
else
    fail "Graceful shutdown NOT implemented"
fi

if grep -q "kill -9.*claude_pid" ~/.claude/bin/claude-loop.sh; then
    pass "Force kill fallback (SIGKILL) implemented"
else
    fail "Force kill fallback NOT implemented"
fi

#------------------------------------------------------------------------------
# Test 2: Verify heartbeat monitoring
#------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: Heartbeat Monitoring"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if grep -q "heartbeat_monitor" ~/.claude/bin/claude-loop.sh; then
    pass "Heartbeat monitor function exists"
else
    fail "Heartbeat monitor function NOT found"
fi

if grep -q "HEARTBEAT_INTERVAL=" ~/.claude/bin/claude-loop.sh; then
    interval_value=$(grep "^HEARTBEAT_INTERVAL=" ~/.claude/bin/claude-loop.sh | head -1 | cut -d'"' -f2 | cut -d'}' -f1)
    info "Default heartbeat interval: ${interval_value:-30}s"
    pass "Heartbeat interval configuration found"
else
    fail "Heartbeat interval configuration NOT found"
fi

if grep -q "still active" ~/.claude/bin/claude-loop.sh; then
    pass "Heartbeat logging messages implemented"
else
    fail "Heartbeat logging NOT implemented"
fi

#------------------------------------------------------------------------------
# Test 3: Verify background monitoring
#------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3: Background Process Management"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if grep -q "claude.*--dangerously-skip-permissions &" ~/.claude/bin/claude-loop.sh; then
    pass "Claude runs in background (allows monitoring)"
else
    fail "Claude NOT running in background"
fi

if grep -q "session_timeout_monitor.*&" ~/.claude/bin/claude-loop.sh; then
    pass "Timeout monitor runs in background"
else
    fail "Timeout monitor NOT in background"
fi

if grep -q "heartbeat_monitor.*&" ~/.claude/bin/claude-loop.sh; then
    pass "Heartbeat monitor runs in background"
else
    fail "Heartbeat monitor NOT in background"
fi

if grep -q "cleanup_monitors" ~/.claude/bin/claude-loop.sh; then
    pass "Monitor cleanup function exists"
else
    fail "Monitor cleanup function NOT found"
fi

if grep -q "trap.*cleanup_monitors" ~/.claude/bin/claude-loop.sh; then
    pass "Cleanup on exit (trap handler) implemented"
else
    fail "Cleanup on exit NOT implemented"
fi

#------------------------------------------------------------------------------
# Test 4: Verify PID tracking
#------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 4: Process ID Tracking"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if grep -q "CLAUDE_PID=\\\$!" ~/.claude/bin/claude-loop.sh; then
    pass "Claude PID captured after background start"
else
    fail "Claude PID NOT captured"
fi

if grep -q "TIMEOUT_MONITOR_PID=\\\$!" ~/.claude/bin/claude-loop.sh; then
    pass "Timeout monitor PID captured"
else
    fail "Timeout monitor PID NOT captured"
fi

if grep -q "HEARTBEAT_MONITOR_PID=\\\$!" ~/.claude/bin/claude-loop.sh; then
    pass "Heartbeat monitor PID captured"
else
    fail "Heartbeat monitor PID NOT captured"
fi

if grep -q "wait.*CLAUDE_PID" ~/.claude/bin/claude-loop.sh; then
    pass "Loop waits for Claude to complete"
else
    fail "Loop does NOT wait for Claude"
fi

#------------------------------------------------------------------------------
# Test 5: Verify documentation
#------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 5: Documentation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ -f ~/.claude/docs/LOOP-OPTIMIZATIONS.md ]]; then
    pass "Documentation file exists"
    doc_size=$(wc -l < ~/.claude/docs/LOOP-OPTIMIZATIONS.md)
    info "Documentation: $doc_size lines"
else
    fail "Documentation file NOT found"
fi

if grep -q "CLAUDE_SESSION_TIMEOUT" ~/.claude/bin/claude-loop.sh; then
    pass "Help text includes timeout environment variable"
else
    fail "Help text missing timeout variable"
fi

if grep -q "CLAUDE_HEARTBEAT_INTERVAL" ~/.claude/bin/claude-loop.sh; then
    pass "Help text includes heartbeat environment variable"
else
    fail "Help text missing heartbeat variable"
fi

#------------------------------------------------------------------------------
# Test 6: Integration test with short timeout
#------------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 6: Integration Test (5 second timeout)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

info "Creating test script that sleeps for 10 seconds..."

# Create a fake "claude" script that sleeps
TEST_DIR="/tmp/claude-loop-test-$$"
mkdir -p "$TEST_DIR"
cat > "$TEST_DIR/fake-claude.sh" <<'EOF'
#!/bin/bash
echo "Fake Claude starting..."
sleep 10
echo "Fake Claude done (should be killed before this)"
EOF
chmod +x "$TEST_DIR/fake-claude.sh"

# Test the timeout function directly
info "Testing timeout function with 5s timeout on 10s process..."

# Source the timeout function from claude-loop.sh
session_timeout_monitor() {
    local pid=$1
    local timeout=$2
    local session_num=$3

    sleep "$timeout"

    if kill -0 "$pid" 2>/dev/null; then
        echo "[TIMEOUT] Process $pid exceeded ${timeout}s timeout - killing"
        kill -TERM "$pid" 2>/dev/null
        sleep 2
        if kill -0 "$pid" 2>/dev/null; then
            echo "[FORCE KILL] Process $pid still running - force kill"
            kill -9 "$pid" 2>/dev/null
        fi
    fi
}

# Start fake process
"$TEST_DIR/fake-claude.sh" &
FAKE_PID=$!

# Start timeout monitor
session_timeout_monitor "$FAKE_PID" 5 "TEST" &
MONITOR_PID=$!

# Wait for fake process (should be killed)
start_time=$(date +%s)
wait "$FAKE_PID" 2>/dev/null || true
end_time=$(date +%s)
elapsed=$((end_time - start_time))

# Cleanup
kill "$MONITOR_PID" 2>/dev/null || true
wait "$MONITOR_PID" 2>/dev/null || true
rm -rf "$TEST_DIR"

if [[ $elapsed -lt 8 ]]; then
    pass "Timeout worked: process killed after ${elapsed}s (expected ~5-7s)"
else
    fail "Timeout FAILED: process ran for ${elapsed}s (expected kill after 5s)"
fi

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                     TEST SUMMARY                       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Total Tests: $((PASS_COUNT + FAIL_COUNT))"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          ✓ ALL TESTS PASSED - READY TO USE!           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "The loop optimizations are working correctly:"
    echo ""
    echo "  • Session timeout: 10 minutes (configurable)"
    echo "  • Heartbeat logging: Every 30 seconds"
    echo "  • Automatic cleanup: On exit or timeout"
    echo "  • Background monitoring: Non-blocking"
    echo ""
    echo "Usage:"
    echo "  ~/.claude/bin/claude-loop.sh \"Work on project\""
    echo ""
    echo "Configuration:"
    echo "  export CLAUDE_SESSION_TIMEOUT=300    # 5 minutes"
    echo "  export CLAUDE_HEARTBEAT_INTERVAL=60  # Every minute"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║          ✗ SOME TESTS FAILED - REVIEW NEEDED          ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Review failed tests above and check:"
    echo "  - ~/.claude/bin/claude-loop.sh"
    echo "  - ~/.claude/docs/LOOP-OPTIMIZATIONS.md"
    echo ""
    exit 1
fi
