#!/bin/bash
# Task Queue - Manage and Prioritize Task Execution
# Provides task queueing, prioritization, and execution management
# Usage: task-queue.sh enqueue | dequeue | peek | status

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/task-queue.log"
STATE_FILE="${HOME}/.claude/task-queue-state.json"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize state
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "queue": [],
    "processing": null,
    "completed": [],
    "metrics": {
        "total_enqueued": 0,
        "total_completed": 0,
        "total_failed": 0,
        "average_wait_time": 0
    }
}
EOF
    fi
}

# Enqueue a task
enqueue() {
    local task="${1:-}"
    local priority="${2:-normal}"  # critical, high, normal, low
    local task_type="${3:-general}"
    local context="${4:-}"

    init_state
    log "Enqueueing task: $task (priority: $priority)"

    if [[ -z "$task" ]]; then
        echo '{"error":"task_required"}' | jq '.'
        return 1
    fi

    local task_id
    task_id="task_$(date +%s)_$(shuf -i 1000-9999 -n 1)"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Priority values
    local priority_value
    case "$priority" in
        critical) priority_value=4 ;;
        high) priority_value=3 ;;
        normal) priority_value=2 ;;
        low) priority_value=1 ;;
        *) priority_value=2 ;;
    esac

    # Create task
    local task_record
    task_record=$(jq -n \
        --arg id "$task_id" \
        --arg task "$task" \
        --arg priority "$priority" \
        --argjson priority_value "$priority_value" \
        --arg task_type "$task_type" \
        --arg context "$context" \
        --arg timestamp "$timestamp" \
        '{
            id: $id,
            task: $task,
            priority: $priority,
            priority_value: $priority_value,
            task_type: $task_type,
            context: $context,
            timestamp: $timestamp,
            status: "queued",
            attempts: 0,
            enqueued_at: $timestamp
        }')

    # Add to queue (sorted by priority)
    jq ".queue += [$task_record] | .queue |= sort_by(-.priority_value, .timestamp)" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    # Update metrics
    jq ".metrics.total_enqueued += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Task enqueued: $task_id"

    # Output result
    jq -n \
        --arg task_id "$task_id" \
        --arg task "$task" \
        --arg priority "$priority" \
        --arg timestamp "$timestamp" \
        '{
            task_id: $task_id,
            task: $task,
            priority: $priority,
            timestamp: $timestamp,
            queue_position: (.queue | length),
            message: "Task enqueued successfully"
        }'
}

# Dequeue next task
dequeue() {
    init_state
    log "Dequeuing next task"

    # Check if already processing
    local processing
    processing=$(jq -r '.processing' "$STATE_FILE")

    if [[ "$processing" != "null" ]]; then
        echo '{"error":"already_processing","task_id":"'"$processing"'"}' | jq '.'
        return 1
    fi

    # Get next task (highest priority)
    local next_task
    next_task=$(jq '.queue[0]' "$STATE_FILE")

    if [[ "$next_task" == "null" ]]; then
        echo '{"queue":"empty","message":"No tasks in queue"}' | jq '.'
        return 0
    fi

    local task_id
    task_id=$(echo "$next_task" | jq -r '.id')

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Move to processing
    jq ".processing = \"$task_id\" | .queue |= .[1:]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Task dequeued: $task_id"

    # Output result
    jq -n \
        --arg task_id "$task_id" \
        --arg task "$(echo "$next_task" | jq -r '.task')" \
        --arg priority "$(echo "$next_task" | jq -r '.priority')" \
        --arg timestamp "$timestamp" \
        '{
            task_id: $task_id,
            task: $task,
            priority: $priority,
            timestamp: $timestamp,
            message: "Task dequeued for processing"
        }'
}

# Peek at next task
peek() {
    init_state
    log "Peeking at next task"

    local next_task
    next_task=$(jq '.queue[0]' "$STATE_FILE")

    if [[ "$next_task" == "null" ]]; then
        echo '{"queue":"empty","message":"No tasks in queue"}' | jq '.'
    else
        echo "$next_task"
    fi
}

# Complete a task
complete() {
    local task_id="${1:-}"
    local result="${2:-success}"
    local output="${3:-}"

    init_state
    log "Completing task: $task_id (result: $result)"

    if [[ -z "$task_id" ]]; then
        echo '{"error":"task_id_required"}' | jq '.'
        return 1
    fi

    # Check if task is being processed
    local processing
    processing=$(jq -r '.processing' "$STATE_FILE")

    if [[ "$processing" != "$task_id" ]]; then
        echo '{"error":"task_not_processing"}' | jq '.'
        return 1
    fi

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Get task details
    local task
    task=$(jq ".processing as \$id | .queue[] | select(.id == \$id)" "$STATE_FILE")

    if [[ "$task" == "null" ]]; then
        # Try completed tasks
        task=$(jq ".completed[] | select(.id == \"$task_id\")" "$STATE_FILE")
    fi

    if [[ "$task" != "null" ]]; then
        # Update task with completion
        local completed_task
        completed_task=$(echo "$task" | jq -n \
            --arg result "$result" \
            --arg output "$output" \
            --arg timestamp "$timestamp" \
            '$ARGS.positional[0] | .status = $result | .output = $output | .completed_at = $timestamp')

        # Add to completed
        jq ".completed += [$completed_task]" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"

        # Update metrics
        if [[ "$result" == "success" ]]; then
            jq ".metrics.total_completed += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
            mv "${STATE_FILE}.tmp" "$STATE_FILE"
        else
            jq ".metrics.total_failed += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
            mv "${STATE_FILE}.tmp" "$STATE_FILE"
        fi

        # Clear processing
        jq ".processing = null" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"

        log "Task completed: $task_id"
    fi

    # Output result
    jq -n \
        --arg task_id "$task_id" \
        --arg result "$result" \
        --arg timestamp "$timestamp" \
        '{
            task_id: $task_id,
            result: $result,
            timestamp: $timestamp,
            message: "Task marked as " + $result
        }'
}

# Fail a task
fail() {
    local task_id="${1:-}"
    local reason="${2:-}"

    init_state
    log "Failing task: $task_id (reason: $reason)"

    if [[ -z "$task_id" ]]; then
        echo '{"error":"task_id_required"}' | jq '.'
        return 1
    fi

    # Complete with failure
    complete "$task_id" "failed" "$reason"
}

# Get queue status
status() {
    init_state

    local queue_length
    queue_length=$(jq '.queue | length' "$STATE_FILE")

    local processing
    processing=$(jq -r '.processing' "$STATE_FILE")

    local completed_count
    completed_count=$(jq '.completed | length' "$STATE_FILE")

    jq -n \
        --argjson queue_length "$queue_length" \
        --arg processing "$processing" \
        --argjson completed_count "$completed_count" \
        '{
            queue_length: $queue_length,
            processing: $processing,
            completed_count: $completed_count,
            status: (if $queue_length == 0 then "idle" elif $processing != null then "processing" else "ready" end)
        }'
}

# Get queue contents
list() {
    local limit="${1:-10}"

    init_state

    jq ".queue[0:$limit]" "$STATE_FILE"
}

# Get completed tasks
completed() {
    local limit="${1:-10}"

    init_state

    jq ".completed[-$limit:]" "$STATE_FILE"
}

# Get metrics
metrics() {
    init_state

    jq '.metrics' "$STATE_FILE"
}

# Clear queue
clear() {
    init_state

    jq ".queue = [] | .processing = null" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Queue cleared"

    jq -n '{"message":"Queue cleared"}'
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Task queue state initialized"
        ;;
    enqueue)
        enqueue "${2:-task}" "${3:-normal}" "${4:-general}" "${5:-}"
        ;;
    dequeue)
        dequeue
        ;;
    peek)
        peek
        ;;
    complete)
        complete "${2:-task_id}" "${3:-success}" "${4:-}"
        ;;
    fail)
        fail "${2:-task_id}" "${3:-}"
        ;;
    status)
        status
        ;;
    list)
        list "${2:-10}"
        ;;
    completed)
        completed "${2:-10}"
        ;;
    metrics)
        metrics
        ;;
    clear)
        clear
        ;;
    help|*)
        cat <<EOF
Task Queue - Manage and Prioritize Task Execution

Usage:
  $0 enqueue <task> [priority] [task_type] [context]  Enqueue a task
  $0 dequeue                                      Dequeue next task
  $0 peek                                         Peek at next task
  $0 complete <task_id> [result] [output]        Complete a task
  $0 fail <task_id> [reason]                    Fail a task
  $0 status                                       Get queue status
  $0 list [limit]                                 List queued tasks
  $0 completed [limit]                             List completed tasks
  $0 metrics                                      Get queue metrics
  $0 clear                                        Clear queue

Priority Levels:
  critical   - Highest priority
  high       - High priority
  normal     - Normal priority (default)
  low        - Lowest priority

Task Types:
  implementation    - Code implementation tasks
  debugging        - Bug fixing tasks
  testing          - Testing tasks
  refactoring      - Code refactoring tasks
  general          - General purpose tasks

Examples:
  $0 enqueue "fix critical bug" "critical" "debugging" "production"
  $0 dequeue
  $0 peek
  $0 complete "task_123" "success" "Bug fixed"
  $0 status
  $0 list 20
  $0 metrics
EOF
        ;;
esac
