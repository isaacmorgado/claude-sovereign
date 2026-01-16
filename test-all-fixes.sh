#!/bin/bash
# Comprehensive verification suite for autonomous operation fixes
# Tests: Direct checkpoint execution, unlimited loop, auto-feed mechanism

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0
TOTAL_TESTS=0

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

warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

test_header() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Test $TOTAL_TESTS: $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Comprehensive Autonomous Operation Verification Suite    ║"
echo "║  Testing all fixes: direct execution, unlimited loop, etc  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

#------------------------------------------------------------------------------
# Test 1: Verify Direct Checkpoint Execution Function Exists
#------------------------------------------------------------------------------
test_header "Direct Checkpoint Execution Function Exists"

if grep -q "execute_checkpoint_directly()" ~/.claude/hooks/auto-continue.sh; then
    pass "execute_checkpoint_directly() function found in auto-continue.sh"

    # Check function has all required components
    if grep -q "git rev-parse --git-dir" ~/.claude/hooks/auto-continue.sh && \
       grep -q "git add CLAUDE.md" ~/.claude/hooks/auto-continue.sh && \
       grep -q "git commit" ~/.claude/hooks/auto-continue.sh && \
       grep -q "git push origin HEAD" ~/.claude/hooks/auto-continue.sh; then
        pass "Function includes git operations (check, add, commit, push)"
    else
        fail "Function missing some git operations"
    fi
else
    fail "execute_checkpoint_directly() function NOT found"
fi

#------------------------------------------------------------------------------
# Test 2: Verify Unlimited Loop Configuration
#------------------------------------------------------------------------------
test_header "Unlimited Loop Configuration"

max_restarts=$(grep "^MAX_RESTARTS=" ~/.claude/bin/claude-loop.sh | cut -d= -f2 | sed 's/ *#.*//' | tr -d ' ')
info "MAX_RESTARTS value: $max_restarts"

if [[ "$max_restarts" -ge 999999999 ]]; then
    pass "Loop configured for unlimited restarts ($max_restarts)"
else
    fail "Loop still limited to $max_restarts restarts (expected >= 999999999)"
fi

# Check help text updated
if grep -q "unlimited restarts" ~/.claude/bin/claude-loop.sh; then
    pass "Help text mentions unlimited restarts"
else
    warn "Help text doesn't mention unlimited restarts"
fi

# Check stop mechanisms documented
if grep -q "/auto stop" ~/.claude/bin/claude-loop.sh; then
    pass "Help text includes /auto stop command"
else
    warn "Help text doesn't mention /auto stop"
fi

#------------------------------------------------------------------------------
# Test 3: Verify Continuation Prompt Auto-Feed Mechanism
#------------------------------------------------------------------------------
test_header "Continuation Prompt Auto-Feed Mechanism"

# Check claude-loop.sh has auto-feed logic
if grep -q "cat \"\$PROMPT_FILE\"" ~/.claude/bin/claude-loop.sh && \
   grep -q "echo \"\$PROMPT\".*claude.*--dangerously-skip-permissions" ~/.claude/bin/claude-loop.sh; then
    pass "claude-loop.sh has prompt auto-feed via stdin piping"
else
    fail "Auto-feed mechanism not found in claude-loop.sh"
fi

# Check continuation prompt file path is correct
if grep -q "PROMPT_FILE=\"\${HOME}/.claude/continuation-prompt.md\"" ~/.claude/bin/claude-loop.sh; then
    pass "Continuation prompt file path correctly configured"
else
    fail "Continuation prompt file path incorrect or missing"
fi

# Check file deletion after consumption
if grep -q "rm -f \"\$PROMPT_FILE\"" ~/.claude/bin/claude-loop.sh; then
    pass "Prompt file deleted after consumption (prevents reuse)"
else
    warn "Prompt file may not be deleted after consumption"
fi

#------------------------------------------------------------------------------
# Test 4: Verify Checkpoint Execution in Hook
#------------------------------------------------------------------------------
test_header "Checkpoint Execution Trigger Logic"

# Check if auto-continue calls execute_checkpoint_directly
if grep -q "if execute_checkpoint_directly; then" ~/.claude/hooks/auto-continue.sh; then
    pass "auto-continue.sh calls execute_checkpoint_directly()"
else
    fail "auto-continue.sh doesn't call execute_checkpoint_directly()"
fi

# Check if CHECKPOINT_EXECUTED flag is set
if grep -q "CHECKPOINT_EXECUTED=\"true\"" ~/.claude/hooks/auto-continue.sh; then
    pass "Checkpoint execution status tracked (CHECKPOINT_EXECUTED flag)"
else
    fail "Checkpoint execution status not tracked"
fi

# Check JSON output includes execution metadata
if grep -q "executed_directly.*true" ~/.claude/hooks/auto-continue.sh; then
    pass "Hook outputs execution metadata in JSON"
else
    warn "Hook may not indicate direct execution in JSON output"
fi

#------------------------------------------------------------------------------
# Test 5: Verify Python Regex for CLAUDE.md Update
#------------------------------------------------------------------------------
test_header "CLAUDE.md Update Mechanism (Python Regex)"

# Check if Python is used for multi-line handling
if grep -q "python3 <<" ~/.claude/hooks/auto-continue.sh && \
   grep -q "import re" ~/.claude/hooks/auto-continue.sh; then
    pass "Uses Python for reliable multi-line CLAUDE.md updates"
else
    fail "Python regex not found for CLAUDE.md updates"
fi

# Check regex pattern handles optional date
if grep -q "## Last Session\[" ~/.claude/hooks/auto-continue.sh; then
    pass "Regex pattern handles '## Last Session' with optional date"
else
    warn "Regex pattern may not handle date variations"
fi

#------------------------------------------------------------------------------
# Test 6: Verify CLAUDE_LOOP_ACTIVE Environment Variable
#------------------------------------------------------------------------------
test_header "Loop Active Signal (CLAUDE_LOOP_ACTIVE)"

if grep -q "export CLAUDE_LOOP_ACTIVE=1" ~/.claude/bin/claude-loop.sh; then
    pass "Loop sets CLAUDE_LOOP_ACTIVE=1 environment variable"
else
    fail "CLAUDE_LOOP_ACTIVE not set by loop"
fi

# Check if auto-continue respects this variable
if grep -q "CLAUDE_LOOP_ACTIVE" ~/.claude/hooks/auto-continue.sh; then
    pass "auto-continue.sh checks CLAUDE_LOOP_ACTIVE"
else
    warn "auto-continue.sh may not respond to CLAUDE_LOOP_ACTIVE"
fi

#------------------------------------------------------------------------------
# Test 7: Verify Stop Mechanism
#------------------------------------------------------------------------------
test_header "Stop Mechanism (/auto stop)"

# Check if stop signal file is checked
if grep -q "stop-loop" ~/.claude/bin/claude-loop.sh; then
    pass "Loop checks for stop-loop signal file"
else
    fail "Stop signal mechanism not found"
fi

# Check if /auto stop creates signal
if [[ -f ~/.claude/skills/auto.sh ]] && grep -q "stop-loop" ~/.claude/skills/auto.sh; then
    pass "/auto stop command creates stop signal"
else
    warn "/auto stop may not create stop signal correctly"
fi

#------------------------------------------------------------------------------
# Test 8: Verify Test Suite Exists
#------------------------------------------------------------------------------
test_header "Test Suite Availability"

if [[ -x ~/.claude/hooks/test-direct-checkpoint.sh ]]; then
    pass "Direct checkpoint test suite exists and is executable"

    # Run the test suite
    info "Running direct checkpoint test suite..."
    if ~/.claude/hooks/test-direct-checkpoint.sh > /tmp/test-output.log 2>&1; then
        pass "Direct checkpoint test suite passes"
    else
        fail "Direct checkpoint test suite failed"
        warn "See /tmp/test-output.log for details"
    fi
else
    warn "Test suite not found at ~/.claude/hooks/test-direct-checkpoint.sh"
fi

#------------------------------------------------------------------------------
# Test 9: Verify Documentation Exists
#------------------------------------------------------------------------------
test_header "Documentation Completeness"

docs_to_check=(
    "~/.claude/docs/DIRECT-CHECKPOINT-EXECUTION.md"
    "~/.claude/docs/UNLIMITED-LOOP-CONFIGURATION.md"
)

for doc in "${docs_to_check[@]}"; do
    doc_expanded="${doc/#\~/$HOME}"
    if [[ -f "$doc_expanded" ]]; then
        pass "Documentation exists: $(basename $doc)"
    else
        warn "Documentation missing: $doc"
    fi
done

#------------------------------------------------------------------------------
# Test 10: Verify State Files and Directories
#------------------------------------------------------------------------------
test_header "State Files and Directory Structure"

# Check required directories
if [[ -d ~/.claude/hooks ]]; then
    pass "~/.claude/hooks directory exists"
else
    fail "~/.claude/hooks directory missing"
fi

if [[ -d ~/.claude/bin ]]; then
    pass "~/.claude/bin directory exists"
else
    fail "~/.claude/bin directory missing"
fi

# Check log files exist (or can be created)
if [[ -f ~/.claude/auto-continue.log ]] || touch ~/.claude/auto-continue.log 2>/dev/null; then
    pass "auto-continue.log exists or can be created"
else
    fail "Cannot create auto-continue.log"
fi

if [[ -f ~/.claude/loop.log ]] || touch ~/.claude/loop.log 2>/dev/null; then
    pass "loop.log exists or can be created"
else
    fail "Cannot create loop.log"
fi

#------------------------------------------------------------------------------
# Test 11: Verify Git Integration
#------------------------------------------------------------------------------
test_header "Git Integration in Direct Checkpoint"

# Check if checkpoint.md has Bash tool enabled
if grep -q '"Bash"' ~/.claude/commands/checkpoint.md 2>/dev/null; then
    pass "checkpoint.md has Bash tool enabled"
else
    warn "checkpoint.md may not have Bash tool enabled"
fi

# Check if git operations are present
if grep -q "git commit" ~/.claude/hooks/auto-continue.sh && \
   grep -q "git push" ~/.claude/hooks/auto-continue.sh; then
    pass "Direct checkpoint includes git commit and push"
else
    fail "Git operations missing from direct checkpoint"
fi

#------------------------------------------------------------------------------
# Test 12: Integration Test - Simulate Context Threshold
#------------------------------------------------------------------------------
test_header "Integration Test - Simulated Context Threshold"

info "Creating test git repository..."
TEST_DIR="/tmp/claude-integration-test-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

git init > /dev/null 2>&1
git config user.email "test@example.com"
git config user.name "Test User"

# Create test CLAUDE.md
cat > CLAUDE.md <<'EOF'
# Test Project

## Current Focus
Testing autonomous operation

## Last Session (2026-01-16)
- Initial test

## Next Steps
1. Test checkpoint
EOF

git add CLAUDE.md
git commit -m "Initial commit" > /dev/null 2>&1

# Make a change
echo "- Additional work" >> CLAUDE.md

# Test direct checkpoint execution
info "Testing execute_checkpoint_directly() function..."

# Extract the function to a temporary file first
TMP_FUNCTION="/tmp/test-checkpoint-function-$$.sh"
awk '/^execute_checkpoint_directly\(\) \{/,/^}$/ {print}' ~/.claude/hooks/auto-continue.sh > "$TMP_FUNCTION"

# Create test wrapper script that properly sources auto-continue.sh
cat > /tmp/test-checkpoint-wrapper-$$.sh <<WRAPPER_EOF
#!/bin/bash
set -euo pipefail

# Change to test directory first
cd "$TEST_DIR"

# Set up environment variables
export PERCENT=45
export CURRENT_TOKENS=90000
export CONTEXT_SIZE=200000
export ITERATION=1
export BUILD_CONTEXT=""
export CHECKPOINT_ID="TEST-123"
export PROJECT_NAME="test-project"
LOG_FILE="/tmp/test-checkpoint-log-$$.log"

# Define log function (required by execute_checkpoint_directly)
log() {
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] \$1" >> "\$LOG_FILE"
    echo "\$1"  # Also output to stdout for testing
}

# Source the extracted function
source "$TMP_FUNCTION"

# Execute the function
execute_checkpoint_directly
exit_code=\$?

# Output success message if function completed
if [[ \$exit_code -eq 0 ]]; then
    echo "Git commit successful"
fi

exit \$exit_code
WRAPPER_EOF

chmod +x /tmp/test-checkpoint-wrapper-$$.sh

# Run the wrapper script and capture output
/tmp/test-checkpoint-wrapper-$$.sh > /tmp/test-integration-output-$$.log 2>&1
test_exit_code=$?

# Check if the script succeeded (exit code 0)
if [[ $test_exit_code -eq 0 ]]; then
    pass "Integration test: Direct checkpoint executes successfully"

    # Verify commit was created (check in TEST_DIR where the git repo is)
    git_log_output=$(cd "$TEST_DIR" && git log --oneline 2>/dev/null)
    if echo "$git_log_output" | grep -q "checkpoint"; then
        pass "Integration test: Git commit created"
    else
        fail "Integration test: Git commit NOT created"
        info "Debug: Git log output:"
        info "$git_log_output"
    fi

    # Verify CLAUDE.md was updated (check in TEST_DIR)
    if grep -q "Auto-checkpoint triggered" "$TEST_DIR/CLAUDE.md"; then
        pass "Integration test: CLAUDE.md updated"
    else
        fail "Integration test: CLAUDE.md NOT updated"
    fi

    # Verify the output contains success message
    if grep -q "Git commit successful" /tmp/test-integration-output-$$.log; then
        pass "Integration test: Success message found in output"
    fi
else
    fail "Integration test: Direct checkpoint failed to execute (exit code: $test_exit_code)"
    warn "Output saved to /tmp/test-integration-output-$$.log"
fi

# Cleanup
cd /
rm -rf "$TEST_DIR"
rm -f /tmp/test-checkpoint-wrapper-$$.sh /tmp/test-checkpoint-log-$$.log /tmp/test-checkpoint-function-$$.sh

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    VERIFICATION SUMMARY                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          ✓ ALL TESTS PASSED - SYSTEM READY!               ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Your autonomous operation system is fully functional:"
    echo ""
    echo "  Start:  /auto start"
    echo "  Stop:   /auto stop"
    echo "  Status: /auto status"
    echo ""
    echo "The system will:"
    echo "  ✓ Auto-execute checkpoints at 40% context"
    echo "  ✓ Auto-feed continuation prompts (no manual copy/paste)"
    echo "  ✓ Run indefinitely until you stop it"
    echo "  ✓ Commit and push to GitHub automatically"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     ✗ SOME TESTS FAILED - REVIEW NEEDED                   ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Review the failed tests above and check:"
    echo "  - ~/.claude/hooks/auto-continue.sh"
    echo "  - ~/.claude/bin/claude-loop.sh"
    echo "  - ~/.claude/commands/checkpoint.md"
    echo ""
    exit 1
fi
