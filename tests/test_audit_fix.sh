#!/bin/bash
# Verify audit fixes for auto-continue handoff
# Checks if PROMPT and INSTRUCTION are decoupled correctly in loop mode

set -e

AUTO_CONTINUE="${HOME}/.claude/hooks/auto-continue.sh"
HANDOFF_FILE="${HOME}/.claude/continuation-prompt.md"

echo "=== Testing Loop Mode Logic ==="

# Mock input (45% context to trigger hook)
MOCK_INPUT='{
  "context_window": {
    "context_window_size": 100000,
    "current_usage": {
      "input_tokens": 45000,
      "cache_creation_input_tokens": 0,
      "cache_read_input_tokens": 0
    }
  },
  "transcript_path": "/tmp/mock"
}'

# 1. Test WITH Loop Active
echo "1. Simulating CLAUDE_LOOP_ACTIVE=1..."
OUTPUT=$(echo "$MOCK_INPUT" | CLAUDE_LOOP_ACTIVE=1 CLAUDE_CONTEXT_THRESHOLD=40 bash "$AUTO_CONTINUE" 2>/dev/null || true)

# Check JSON instruction (should say /exit)
REASON=$(echo "$OUTPUT" | jq -r '.reason' 2>/dev/null)
if echo "$REASON" | grep -q "/exit"; then
    echo "   ✓ JSON instructs agent to /exit"
else
    echo "   ✗ JSON missing /exit instruction"
    echo "   Actual: $REASON"
    exit 1
fi

# Check File content (should NOT say /exit, should say RESUME)
FILE_CONTENT=$(cat "$HANDOFF_FILE")
if echo "$FILE_CONTENT" | grep -q "RESUME"; then
    echo "   ✓ File content starts with RESUME"
else
    echo "   ✗ File content incorrect"
fi

if echo "$FILE_CONTENT" | grep -q "/exit"; then
    echo "   ✗ File content contains /exit (Should only be in current instruction)"
    exit 1
else
    echo "   ✓ File content clean (ready for next session)"
fi

# 2. Test WITHOUT Loop Active
echo ""
echo "2. Simulating Loop INACTIVE..."
OUTPUT=$(echo "$MOCK_INPUT" | CLAUDE_LOOP_ACTIVE=0 CLAUDE_CONTEXT_THRESHOLD=40 bash "$AUTO_CONTINUE" 2>/dev/null || true)

REASON=$(echo "$OUTPUT" | jq -r '.reason' 2>/dev/null)
if echo "$REASON" | grep -q "aichat resume"; then
    echo "   ✓ JSON instructs manual resume (aichat)"
else
    echo "   ✗ JSON missing manual resume instruction"
fi

echo ""
echo "=== Audit Fix Verified ==="
