#!/bin/bash
# File Change Tracker - Tracks file modifications for auto-checkpoint
# Auto-triggers /checkpoint every 10 file changes

set -e

CLAUDE_DIR="${HOME}/.claude"
PROJECT_DIR="${PWD}"
TRACKER_FILE="${PROJECT_DIR}/.claude/file-changes.json"
LOG_FILE="${CLAUDE_DIR}/file-change-tracker.log"
CHECKPOINT_THRESHOLD=${CHECKPOINT_FILE_THRESHOLD:-10}

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

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Use portable locking mechanism (works on macOS and Linux)
    local lock_file="${TRACKER_FILE}.lock"
    local lock_timeout=10
    local lock_acquired=false

    # Clean stale lock (older than 60 seconds)
    if [[ -d "$lock_file" ]]; then
        local lock_age=$(($(date +%s) - $(stat -f %m "$lock_file" 2>/dev/null || stat -c %Y "$lock_file" 2>/dev/null || echo 0)))
        if [[ $lock_age -gt 60 ]]; then
            log "Removing stale lock (age: ${lock_age}s)"
            rmdir "$lock_file" 2>/dev/null || true
        fi
    fi

    # Try to acquire lock with timeout
    for ((i=0; i<lock_timeout; i++)); do
        if mkdir "$lock_file" 2>/dev/null; then
            lock_acquired=true
            break
        fi
        sleep 0.1
    done

    if [[ "$lock_acquired" != "true" ]]; then
        log "Failed to acquire lock after ${lock_timeout}s"
        echo "ERROR:0"
        return 1
    fi

    # Ensure lock is released on exit
    trap "rmdir '$lock_file' 2>/dev/null || true" EXIT INT TERM

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

    # Release lock
    rmdir "$lock_file" 2>/dev/null || true
    trap - EXIT INT TERM

    # Check if threshold reached
    if [[ $count -ge $CHECKPOINT_THRESHOLD ]]; then
        echo "CHECKPOINT_NEEDED:${count}"
        return 0
    fi

    echo "OK:${count}"
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

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Use portable locking mechanism (works on macOS and Linux)
    local lock_file="${TRACKER_FILE}.lock"
    local lock_timeout=10
    local lock_acquired=false

    # Clean stale lock (older than 60 seconds)
    if [[ -d "$lock_file" ]]; then
        local lock_age=$(($(date +%s) - $(stat -f %m "$lock_file" 2>/dev/null || stat -c %Y "$lock_file" 2>/dev/null || echo 0)))
        if [[ $lock_age -gt 60 ]]; then
            log "Removing stale lock (age: ${lock_age}s)"
            rmdir "$lock_file" 2>/dev/null || true
        fi
    fi

    # Try to acquire lock with timeout
    for ((i=0; i<lock_timeout; i++)); do
        if mkdir "$lock_file" 2>/dev/null; then
            lock_acquired=true
            break
        fi
        sleep 0.1
    done

    if [[ "$lock_acquired" != "true" ]]; then
        log "Failed to acquire lock after ${lock_timeout}s"
        return 1
    fi

    # Ensure lock is released on exit
    trap "rmdir '$lock_file' 2>/dev/null || true" EXIT INT TERM

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

    # Release lock
    rmdir "$lock_file" 2>/dev/null || true
    trap - EXIT INT TERM
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
