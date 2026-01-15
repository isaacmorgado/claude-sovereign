#!/bin/bash
# Auto-Checkpoint Trigger - Detects when to automatically checkpoint
# Triggers checkpoint after significant changes

CLAUDE_DIR="${HOME}/.claude"
PROJECT_DIR="${PWD}"
CHECKPOINT_STATE="${PROJECT_DIR}/.claude/checkpoint-state.json"

# Ensure .claude dir exists in project
mkdir -p "${PROJECT_DIR}/.claude" 2>/dev/null

# Initialize state file if not exists
if [[ ! -f "$CHECKPOINT_STATE" ]]; then
    echo '{"last_checkpoint": 0, "changes_since": 0, "files_modified": []}' > "$CHECKPOINT_STATE"
fi

# Record a file change
record_change() {
    local file="$1"
    local current_time=$(date +%s)

    # Update state
    local state=$(cat "$CHECKPOINT_STATE")
    local changes=$(echo "$state" | jq -r '.changes_since // 0')
    changes=$((changes + 1))

    # Add file to modified list (unique)
    echo "$state" | jq --arg file "$file" --arg changes "$changes" \
        '.changes_since = ($changes | tonumber) | .files_modified = (.files_modified + [$file] | unique)' \
        > "$CHECKPOINT_STATE"

    echo "$changes"
}

# Check if checkpoint is needed
should_checkpoint() {
    local state=$(cat "$CHECKPOINT_STATE" 2>/dev/null || echo '{"changes_since": 0}')
    local changes=$(echo "$state" | jq -r '.changes_since // 0')
    local last_checkpoint=$(echo "$state" | jq -r '.last_checkpoint // 0')
    local current_time=$(date +%s)
    local time_since=$((current_time - last_checkpoint))

    # Checkpoint if:
    # - More than 10 file changes since last checkpoint
    # - More than 30 minutes since last checkpoint (and at least 1 change)

    if [[ "$changes" -ge 10 ]]; then
        echo "changes_threshold"
        return 0
    fi

    if [[ "$time_since" -ge 1800 && "$changes" -ge 1 ]]; then
        echo "time_threshold"
        return 0
    fi

    echo "no"
    return 1
}

# Mark checkpoint as done
mark_checkpointed() {
    local current_time=$(date +%s)
    echo "{\"last_checkpoint\": $current_time, \"changes_since\": 0, \"files_modified\": []}" > "$CHECKPOINT_STATE"
}

# Get checkpoint recommendation for Claude
get_recommendation() {
    local reason=$(should_checkpoint)
    local state=$(cat "$CHECKPOINT_STATE" 2>/dev/null || echo '{}')
    local changes=$(echo "$state" | jq -r '.changes_since // 0')
    local files=$(echo "$state" | jq -r '.files_modified | length // 0')

    if [[ "$reason" != "no" ]]; then
        cat << EOF
CHECKPOINT_RECOMMENDED: true
REASON: ${reason}
CHANGES_SINCE_LAST: ${changes}
FILES_MODIFIED: ${files}
ACTION: Run /checkpoint now to save progress
EOF
    else
        echo "CHECKPOINT_RECOMMENDED: false"
        echo "CHANGES_SINCE_LAST: ${changes}"
    fi
}

# Command handling
case "${1:-check}" in
    record)
        record_change "$2"
        ;;
    check)
        should_checkpoint
        ;;
    recommend)
        get_recommendation
        ;;
    done)
        mark_checkpointed
        ;;
    status)
        cat "$CHECKPOINT_STATE" 2>/dev/null || echo "{}"
        ;;
    *)
        echo "Usage: $0 {record <file>|check|recommend|done|status}"
        exit 1
        ;;
esac
