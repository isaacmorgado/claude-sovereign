#!/bin/bash
# Task Queue System - Priority-based task management
# Based on patterns from: DataDog browser-sdk, claude-flow orchestrator, piscina

set -uo pipefail

QUEUE_DIR="${HOME}/.claude/queue"
QUEUE_FILE="$QUEUE_DIR/tasks.json"
LOG_FILE="${HOME}/.claude/task-queue.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_queue() {
    mkdir -p "$QUEUE_DIR"
    if [[ ! -f "$QUEUE_FILE" ]]; then
        echo '{"tasks":[],"completed":[],"failed":[]}' > "$QUEUE_FILE"
    fi
}

# =============================================================================
# TASK MANAGEMENT (from DataDog/piscina patterns)
# =============================================================================

# Add task to queue with priority
# Priority: 1 (highest) to 5 (lowest)
add_task() {
    local name="$1"
    local priority="${2:-3}"
    local context="${3:-}"
    local depends_on="${4:-}"

    init_queue

    local task_id
    task_id="task_$(date +%s)_$$"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local temp_file
    temp_file=$(mktemp)

    jq --arg id "$task_id" \
       --arg name "$name" \
       --argjson priority "$priority" \
       --arg context "$context" \
       --arg depends "$depends_on" \
       --arg ts "$timestamp" \
       '.tasks += [{
           id: $id,
           name: $name,
           priority: $priority,
           context: $context,
           dependsOn: $depends,
           status: "pending",
           createdAt: $ts,
           attempts: 0
       }]' "$QUEUE_FILE" > "$temp_file"

    mv "$temp_file" "$QUEUE_FILE"

    log "Added task: $name (id: $task_id, priority: $priority)"
    echo "$task_id"
}

# Get next task by priority (lower number = higher priority)
get_next_task() {
    init_queue

    # Get highest priority pending task with no unmet dependencies
    local next_task
    next_task=$(jq -r '
        .tasks
        | map(select(.status == "pending"))
        | map(select(
            .dependsOn == "" or
            .dependsOn == null or
            (.dependsOn as $dep |
                (input_filename | . as $f |
                    ($f | .completed | map(.name) | index($dep)) != null
                )
            )
        ))
        | sort_by(.priority, .createdAt)
        | first
        | .id // empty
    ' "$QUEUE_FILE" 2>/dev/null || echo "")

    # Simpler fallback - just get highest priority pending
    if [[ -z "$next_task" ]]; then
        next_task=$(jq -r '
            .tasks
            | map(select(.status == "pending"))
            | sort_by(.priority, .createdAt)
            | first
            | .id // empty
        ' "$QUEUE_FILE")
    fi

    echo "$next_task"
}

# Start a task (mark as in_progress)
start_task() {
    local task_id="$1"

    init_queue

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg id "$task_id" \
       --arg ts "$timestamp" \
       '.tasks = [.tasks[] | if .id == $id then
           .status = "in_progress" | .startedAt = $ts | .attempts += 1
       else . end]' "$QUEUE_FILE" > "$temp_file"

    mv "$temp_file" "$QUEUE_FILE"

    log "Started task: $task_id"
}

# Complete a task
complete_task() {
    local task_id="$1"
    local result="${2:-success}"

    init_queue

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Move to completed array
    jq --arg id "$task_id" \
       --arg ts "$timestamp" \
       --arg result "$result" \
       '
       (.tasks | map(select(.id == $id)) | first) as $task |
       if $task then
           .completed += [$task + {completedAt: $ts, result: $result, status: "completed"}] |
           .tasks = [.tasks[] | select(.id != $id)]
       else . end
       ' "$QUEUE_FILE" > "$temp_file"

    mv "$temp_file" "$QUEUE_FILE"

    log "Completed task: $task_id (result: $result)"
}

# Fail a task
fail_task() {
    local task_id="$1"
    local error="${2:-unknown}"
    local max_retries="${3:-3}"

    init_queue

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Check attempts and either retry or move to failed
    local attempts
    attempts=$(jq -r --arg id "$task_id" '.tasks[] | select(.id == $id) | .attempts' "$QUEUE_FILE")
    attempts=$((attempts + 0))

    if [[ $attempts -lt $max_retries ]]; then
        # Reset to pending for retry
        jq --arg id "$task_id" \
           --arg ts "$timestamp" \
           --arg err "$error" \
           '.tasks = [.tasks[] | if .id == $id then
               .status = "pending" | .lastError = $err | .lastFailedAt = $ts
           else . end]' "$QUEUE_FILE" > "$temp_file"

        log "Task $task_id failed (attempt $attempts/$max_retries), will retry"
    else
        # Move to failed array
        jq --arg id "$task_id" \
           --arg ts "$timestamp" \
           --arg err "$error" \
           '
           (.tasks | map(select(.id == $id)) | first) as $task |
           if $task then
               .failed += [$task + {failedAt: $ts, error: $err, status: "failed"}] |
               .tasks = [.tasks[] | select(.id != $id)]
           else . end
           ' "$QUEUE_FILE" > "$temp_file"

        log "Task $task_id permanently failed after $attempts attempts"
    fi

    mv "$temp_file" "$QUEUE_FILE"
}

# Get task info
get_task() {
    local task_id="$1"

    init_queue

    jq --arg id "$task_id" '
        (.tasks[] | select(.id == $id)) //
        (.completed[] | select(.id == $id)) //
        (.failed[] | select(.id == $id)) //
        null
    ' "$QUEUE_FILE"
}

# Get queue status
get_status() {
    init_queue

    jq '{
        pending: [.tasks[] | select(.status == "pending")] | length,
        in_progress: [.tasks[] | select(.status == "in_progress")] | length,
        completed: .completed | length,
        failed: .failed | length,
        total: (.tasks | length) + (.completed | length) + (.failed | length)
    }' "$QUEUE_FILE"
}

# Clear completed/failed tasks
clear_history() {
    init_queue

    local temp_file
    temp_file=$(mktemp)

    jq '.completed = [] | .failed = []' "$QUEUE_FILE" > "$temp_file"
    mv "$temp_file" "$QUEUE_FILE"

    log "Cleared task history"
}

# List all tasks
list_tasks() {
    local filter="${1:-all}"

    init_queue

    case "$filter" in
        pending)
            jq '.tasks | map(select(.status == "pending"))' "$QUEUE_FILE"
            ;;
        in_progress)
            jq '.tasks | map(select(.status == "in_progress"))' "$QUEUE_FILE"
            ;;
        completed)
            jq '.completed' "$QUEUE_FILE"
            ;;
        failed)
            jq '.failed' "$QUEUE_FILE"
            ;;
        all|*)
            jq '.' "$QUEUE_FILE"
            ;;
    esac
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    add)
        add_task "${2:-unnamed}" "${3:-3}" "${4:-}" "${5:-}"
        ;;
    next)
        get_next_task
        ;;
    start)
        start_task "${2:-}"
        ;;
    complete)
        complete_task "${2:-}" "${3:-success}"
        ;;
    fail)
        fail_task "${2:-}" "${3:-unknown}" "${4:-3}"
        ;;
    get)
        get_task "${2:-}"
        ;;
    status)
        get_status
        ;;
    list)
        list_tasks "${2:-all}"
        ;;
    clear)
        clear_history
        ;;
    help|*)
        echo "Task Queue System"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  add <name> [priority] [context] [depends_on]  - Add task (priority 1-5)"
        echo "  next                                          - Get next task ID"
        echo "  start <task_id>                               - Mark task as started"
        echo "  complete <task_id> [result]                   - Mark task as complete"
        echo "  fail <task_id> [error] [max_retries]          - Mark task as failed"
        echo "  get <task_id>                                 - Get task details"
        echo "  status                                        - Get queue status"
        echo "  list [pending|in_progress|completed|failed]   - List tasks"
        echo "  clear                                         - Clear history"
        ;;
esac
