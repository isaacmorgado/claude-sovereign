#!/bin/bash
# Test script for direct checkpoint execution in auto-continue.sh
# Verifies that checkpoints are executed directly without Claude signaling

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTO_CONTINUE="${SCRIPT_DIR}/auto-continue.sh"
TEST_DIR="/tmp/claude-checkpoint-test-$$"
LOG_FILE="${HOME}/.claude/auto-continue.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}✓ $1${NC}"
}

fail() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

info() {
    echo "ℹ $1"
}

# Setup test environment
setup_test() {
    info "Setting up test environment in $TEST_DIR"

    # Create test directory
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"

    # Initialize git repo
    git init > /dev/null 2>&1
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Create initial commit
    echo "# Test Project" > README.md
    git add README.md
    git commit -m "Initial commit" > /dev/null 2>&1

    # Create minimal CLAUDE.md
    cat > CLAUDE.md <<'EOF'
# Test Project

Testing auto-checkpoint direct execution.

## Current Focus
Section: Testing
Files: auto-continue.sh

## Last Session (2026-01-16)
- Initial test setup
- Stopped at: About to test checkpoint

## Next Steps
1. Test direct checkpoint execution
2. Verify git commit created
3. Verify CLAUDE.md updated
EOF

    git add CLAUDE.md
    git commit -m "Add CLAUDE.md" > /dev/null 2>&1

    # Create .claude directory
    mkdir -p .claude

    # Enable autonomous mode
    mkdir -p "${HOME}/.claude"
    echo "$(date +%s)" > "${HOME}/.claude/autonomous-mode.active"

    pass "Test environment ready"
}

# Create hook input that triggers checkpoint
create_hook_input() {
    # Simulate 45% context usage (above 40% threshold)
    cat <<'EOF'
{
  "context_window": {
    "context_window_size": 200000,
    "current_usage": {
      "input_tokens": 85000,
      "cache_creation_input_tokens": 5000,
      "cache_read_input_tokens": 0,
      "output_tokens": 0
    }
  },
  "transcript_path": ""
}
EOF
}

# Test direct checkpoint execution
test_direct_execution() {
    info "Testing direct checkpoint execution..."

    # Make a change to trigger a commit
    echo "- Additional test step" >> CLAUDE.md

    # Get current commit count
    local commits_before=$(git rev-list --count HEAD)

    # Get current CLAUDE.md content
    local claude_md_hash_before=$(md5 -q CLAUDE.md 2>/dev/null || md5sum CLAUDE.md | cut -d' ' -f1)

    # Run auto-continue hook with test input
    local hook_output=$(create_hook_input | "$AUTO_CONTINUE" 2>&1)

    # Check if hook executed successfully
    if [[ $? -ne 0 ]]; then
        fail "Hook execution failed: $hook_output"
    fi

    pass "Hook executed successfully"

    # Verify new commit was created
    local commits_after=$(git rev-list --count HEAD)
    if [[ $commits_after -gt $commits_before ]]; then
        pass "New git commit created"
    else
        fail "No new git commit created (before: $commits_before, after: $commits_after)"
    fi

    # Verify CLAUDE.md was updated
    local claude_md_hash_after=$(md5 -q CLAUDE.md 2>/dev/null || md5sum CLAUDE.md | cut -d' ' -f1)
    if [[ "$claude_md_hash_before" != "$claude_md_hash_after" ]]; then
        pass "CLAUDE.md was updated"
    else
        fail "CLAUDE.md was not updated"
    fi

    # Verify commit message
    local commit_msg=$(git log -1 --pretty=%B)
    if echo "$commit_msg" | grep -q "auto-checkpoint"; then
        pass "Commit message contains 'auto-checkpoint'"
    else
        warn "Commit message doesn't contain 'auto-checkpoint': $commit_msg"
    fi

    # Check log file for success message
    if grep -q "Direct checkpoint execution completed successfully" "$LOG_FILE" 2>/dev/null; then
        pass "Log file confirms successful execution"
    else
        warn "Log file doesn't confirm successful execution"
    fi

    # Verify hook output indicates direct execution
    if echo "$hook_output" | grep -q "executed_directly.*true"; then
        pass "Hook output indicates direct execution"
    else
        warn "Hook output doesn't indicate direct execution"
    fi
}

# Test that it works without changes (idempotent)
test_no_changes() {
    info "Testing checkpoint with no changes..."

    local commits_before=$(git rev-list --count HEAD)

    # Run hook again with no changes
    create_hook_input | "$AUTO_CONTINUE" > /dev/null 2>&1

    local commits_after=$(git rev-list --count HEAD)
    if [[ $commits_after -eq $commits_before ]]; then
        pass "No commit created when there are no changes"
    else
        fail "Unnecessary commit created when there were no changes"
    fi
}

# Cleanup
cleanup() {
    info "Cleaning up test environment..."
    cd /
    rm -rf "$TEST_DIR"
    rm -f "${HOME}/.claude/autonomous-mode.active"
    pass "Cleanup complete"
}

# Main test execution
main() {
    echo "========================================="
    echo "Direct Checkpoint Execution Test"
    echo "========================================="
    echo

    # Run tests
    setup_test
    echo
    test_direct_execution
    echo
    test_no_changes
    echo
    cleanup

    echo
    echo "========================================="
    echo -e "${GREEN}All tests passed! ✓${NC}"
    echo "========================================="
}

# Run tests
main
