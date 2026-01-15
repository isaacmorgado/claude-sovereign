#!/bin/bash
# Simulate auto-continue handoff flow
# This tests the actual flow without running Claude

set -e

PROMPT_FILE="${HOME}/.claude/continuation-prompt.md"
AUTO_CONTINUE="${HOME}/.claude/hooks/auto-continue.sh"

echo "=== Simulating Auto-Continue Handoff ==="
echo ""

# Create mock input simulating 45% context usage
MOCK_INPUT='{
  "context_window": {
    "context_window_size": 100000,
    "current_usage": {
      "input_tokens": 45000,
      "cache_creation_input_tokens": 0,
      "cache_read_input_tokens": 0
    }
  },
  "transcript_path": "/tmp/mock_transcript"
}'

echo "1. Feeding mock 45% context to auto-continue.sh..."
OUTPUT=$(echo "$MOCK_INPUT" | CLAUDE_CONTEXT_THRESHOLD=40 bash "$AUTO_CONTINUE" 2>/dev/null || true)

echo "2. Checking JSON output..."
DECISION=$(echo "$OUTPUT" | jq -r '.decision // "none"' 2>/dev/null || echo "parse_error")
echo "   Decision: $DECISION"

if [[ "$DECISION" == "block" ]]; then
    echo "   ✓ Hook correctly blocked stop"
else
    echo "   ✗ Expected 'block', got '$DECISION'"
fi

echo ""
echo "3. Checking continuation prompt file..."
if [[ -f "$PROMPT_FILE" ]]; then
    echo "   ✓ Prompt file created at $PROMPT_FILE"
    echo "   Content preview:"
    head -5 "$PROMPT_FILE" | sed 's/^/   | /'
    echo ""
    
    # Simulate loop picking up the file
    echo "4. Simulating loop handoff..."
    PROMPT_CONTENT=$(cat "$PROMPT_FILE")
    rm -f "$PROMPT_FILE"
    echo "   ✓ Prompt consumed (file deleted)"
    echo "   Would feed to next Claude session: ${#PROMPT_CONTENT} chars"
else
    echo "   ✗ Prompt file not created"
fi

echo ""
echo "=== Handoff Simulation Complete ==="
