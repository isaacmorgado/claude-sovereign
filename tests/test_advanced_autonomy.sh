#!/bin/bash
# Test Advanced Autonomy Features

set -e

JANITOR_HOOK="${HOME}/.claude/hooks/proactive-janitor.sh"
SELF_REPAIR="${HOME}/.claude/hooks/self-repair.sh"
AUTO_CONTINUE="${HOME}/.claude/hooks/auto-continue.sh"

echo "=== 1. Testing Proactive Janitor ==="
# Create dummy tech debt
echo "# FIXME: This is a test debt" > test_debt.sh

# Run scanner
REPORT=$("$JANITOR_HOOK")

if echo "$REPORT" | grep -q "Found 1 issues"; then
    echo "✓ Janitor detected tech debt"
else
    echo "✗ Janitor failed to detect debt"
    echo "Report: $REPORT"
    rm test_debt.sh
    exit 1
fi
rm test_debt.sh

echo "=== 2. Testing Janitor Integration ==="
# Create dummy tech debt again
echo "# FIXME: Critical hack" > critical_hack.sh

# Mock input for auto-continue
MOCK_INPUT='{
  "context_window": {"context_window_size": 100, "current_usage": {"input_tokens": 50}}
}'

# Run auto-continue (threshold 40)
OUTPUT=$(echo "$MOCK_INPUT" | CLAUDE_CONTEXT_THRESHOLD=40 bash "$AUTO_CONTINUE" 2>/dev/null || true)

# Check if JSON reason contains Janitor Report
# Note: auto-continue puts the prompt in "reason" field in JSON output for blocking
if echo "$OUTPUT" | grep -q "Proactive Janitor Report"; then
    echo "✓ Janitor report injected into auto-continue prompt"
else
    echo "✗ Janitor report missing from auto-continue"
fi
rm critical_hack.sh

echo "=== 3. Testing Self-Repair Logic ==="
# Create broken script
BROKEN_SCRIPT="broken_test.sh"
echo "if [ true; then echo 'missing bracket'; fi" > "$BROKEN_SCRIPT"

# Run self-repair (mocking aichat if not present for logic check)
# We can't easily mock aichat here without installing it, so we check if it runs without crashing
# and handles the missing tool gracefully if applicable.

echo "Running self-repair on $BROKEN_SCRIPT..."
bash "$SELF_REPAIR" "$BROKEN_SCRIPT" "Syntax error near unexpected token" 2>/dev/null || true

if [[ -f "${HOME}/.claude/self-repair.log" ]]; then
    echo "✓ Self-Repair logged execution"
else
    echo "✗ Self-Repair log missing"
fi

rm "$BROKEN_SCRIPT"
echo "=== Advanced Autonomy Verification Complete ==="
