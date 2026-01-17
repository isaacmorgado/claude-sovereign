#!/bin/bash
# File Change Tracker - Tracks file modifications for auto-checkpoint
# Auto-triggers /checkpoint every 10 file changes

set -e

CLAUDE_DIR="${HOME}/.claude"
PROJECT_DIR="${PWD}"
TRACKER_FILE="${PROJECT_DIR}/.claude/file-changes.json"
LOCK_DIR="${TRACKER_FILE}.lockdir"
LOG_FILE="${CLAUDE_DIR}/file-change-tracker.log"
CHECKPOINT_THRESHOLD=${CHECKPOINT_FILE_THRESHOLD:-10}

# Cross-platform file locking using mkdir (atomic on all systems)
acquire_lock() {
    local max_attempts=50
    local attempt=0
    while ! mkdir "$LOCK_DIR" 2>/dev/null; do
        attempt=$((attempt + 1))
        if [[ $attempt -ge $max_attempts ]]; then
            echo "Error: Could not acquire lock after $max_attempts attempts" >&2
            return 1
        fi
        sleep 0.1
    done
    return 0
}

release_lock() {
    rmdir "$LOCK_DIR" 2>/dev/null || true
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_tracker() {
    mkdir -p "${PROJECT_DIR}/.claude"
    if [[ ! -f "$TRACKER_FILE" ]]; then
        cat > "$TRACKER_FILE" <<'EOF'
{
  "session_start": "",
  "last_checkpoint": "",
  "files_changed": [],
  "change_count": 0,
  "checkpoint_count": 0
}
EOF
    fi
}

# Record a file change
record_change() {
    local file_path="$1"
    local change_type="${2:-modified}"  # created, modified, deleted

    init_tracker

    # Use file locking for concurrent access safety in swarm mode
    acquire_lock || return 1
    trap 'release_lock' EXIT

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Check if session just started
    local session_start
    session_start=$(jq -r '.session_start' "$TRACKER_FILE")
    if [[ -z "$session_start" || "$session_start" == "null" || "$session_start" == "" ]]; then
        jq --arg ts "$timestamp" '.session_start = $ts' "$TRACKER_FILE" > "${TRACKER_FILE}.tmp"
        mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"
    fi

    # Add file change
    jq --arg file "$file_path" \
       --arg type "$change_type" \
       --arg ts "$timestamp" \
       '
       .files_changed += [{
           file: $file,
           type: $type,
           timestamp: $ts
       }] |
       .change_count += 1
       ' "$TRACKER_FILE" > "${TRACKER_FILE}.tmp"

    mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"

    local count
    count=$(jq -r '.change_count' "$TRACKER_FILE")

    log "Recorded change: $file_path ($change_type) - Total: $count"

    release_lock
    trap - EXIT

    # Check if threshold reached
    if [[ $count -ge $CHECKPOINT_THRESHOLD ]]; then
        echo "CHECKPOINT_NEEDED:${count}"
    else
        echo "OK:${count}"
    fi
}

# Check if checkpoint needed
should_checkpoint() {
    init_tracker

    local count
    count=$(jq -r '.change_count' "$TRACKER_FILE")

    if [[ $count -ge $CHECKPOINT_THRESHOLD ]]; then
        echo "true:${count}"
    else
        echo "false:${count}"
    fi
}

# Reset counter after checkpoint
reset_counter() {
    init_tracker

    # Use file locking for concurrent access safety in swarm mode
    acquire_lock || return 1
    trap 'release_lock' EXIT

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local checkpoint_count
    checkpoint_count=$(jq -r '.checkpoint_count' "$TRACKER_FILE")
    checkpoint_count=$((checkpoint_count + 1))

    jq --arg ts "$timestamp" \
       --argjson count "$checkpoint_count" \
       '
       .last_checkpoint = $ts |
       .checkpoint_count = $count |
       .change_count = 0 |
       .files_changed = []
       ' "$TRACKER_FILE" > "${TRACKER_FILE}.tmp"

    mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"

    log "Counter reset after checkpoint (checkpoint #${checkpoint_count})"

    release_lock
    trap - EXIT
}

# Get status
get_status() {
    init_tracker

    local count
    count=$(jq -r '.change_count' "$TRACKER_FILE")

    local last_checkpoint
    last_checkpoint=$(jq -r '.last_checkpoint // "never"' "$TRACKER_FILE")

    local checkpoint_count
    checkpoint_count=$(jq -r '.checkpoint_count' "$TRACKER_FILE")

    cat <<EOF
File Change Tracker Status:
  Changes since last checkpoint: $count / $CHECKPOINT_THRESHOLD
  Last checkpoint: $last_checkpoint
  Total checkpoints this session: $checkpoint_count
  Checkpoint needed: $(if [[ $count -ge $CHECKPOINT_THRESHOLD ]]; then echo "YES"; else echo "no"; fi)
EOF
}

# Get recent changes
get_recent() {
    init_tracker

    jq -r '.files_changed[-10:] | .[] | "  \(.timestamp) [\(.type)] \(.file)"' "$TRACKER_FILE"
}

# Command interface
case "${1:-help}" in
    record)
        record_change "${2:-unknown}" "${3:-modified}"
        ;;
    check)
        should_checkpoint
        ;;
    reset)
        reset_counter
        ;;
    status)
        get_status
        ;;
    recent)
        get_recent
        ;;
    init)
        init_tracker
        echo "Tracker initialized"
        ;;
    *)
        echo "File Change Tracker - Auto-checkpoint trigger"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  record <file> [type]  - Record a file change (type: created|modified|deleted)"
        echo "  check                 - Check if checkpoint is needed"
        echo "  reset                 - Reset counter after checkpoint"
        echo "  status                - Show current status"
        echo "  recent                - Show recent changes"
        echo "  init                  - Initialize tracker"
        echo ""
        echo "Threshold: $CHECKPOINT_THRESHOLD files (set CHECKPOINT_FILE_THRESHOLD to change)"
        ;;
esac
