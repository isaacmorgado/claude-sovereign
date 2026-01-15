#!/bin/bash
# Auto-checkpoint hook - triggers when context exceeds threshold
# Reads JSON input from Claude Code, checks context percentage

THRESHOLD=${CLAUDE_CONTEXT_THRESHOLD:-40}
LOG_FILE="${HOME}/.claude/auto-checkpoint.log"

input=$(cat)

# Extract context window info
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USAGE=$(echo "$input" | jq '.context_window.current_usage // null')

if [ "$USAGE" = "null" ]; then
    # No usage data available, allow stop
    exit 0
fi

# Calculate current token usage
INPUT_TOKENS=$(echo "$USAGE" | jq -r '.input_tokens // 0')
CACHE_CREATE=$(echo "$USAGE" | jq -r '.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$USAGE" | jq -r '.cache_read_input_tokens // 0')

CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
PERCENT=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))

# Log for debugging
echo "[$(date)] Context: ${PERCENT}% (${CURRENT_TOKENS}/${CONTEXT_SIZE})" >> "$LOG_FILE"

if [ "$PERCENT" -ge "$THRESHOLD" ]; then
    # Output JSON to block stop and continue with checkpoint instruction
    echo "{\"decision\": \"block\", \"reason\": \"Context at ${PERCENT}% - auto-checkpointing. Run /checkpoint now, then /compact to continue.\"}"
    exit 0
fi

# Allow stop normally
echo "{\"decision\": \"allow\"}"
exit 0
