#!/bin/bash
# Status line script - shows context usage percentage
# Enable with: claude config set --global status_line ~/.claude/statusline.sh

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USAGE=$(echo "$input" | jq '.context_window.current_usage // null')

if [ "$USAGE" != "null" ]; then
    INPUT_TOKENS=$(echo "$USAGE" | jq -r '.input_tokens // 0')
    CACHE_CREATE=$(echo "$USAGE" | jq -r '.cache_creation_input_tokens // 0')
    CACHE_READ=$(echo "$USAGE" | jq -r '.cache_read_input_tokens // 0')

    CURRENT=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
    PERCENT=$((CURRENT * 100 / CONTEXT_SIZE))

    # Color coding based on threshold
    if [ "$PERCENT" -ge 70 ]; then
        echo "[$MODEL] ⚠️  ${PERCENT}%"
    elif [ "$PERCENT" -ge 40 ]; then
        echo "[$MODEL] 📍 ${PERCENT}%"
    else
        echo "[$MODEL] ${PERCENT}%"
    fi
else
    echo "[$MODEL]"
fi
