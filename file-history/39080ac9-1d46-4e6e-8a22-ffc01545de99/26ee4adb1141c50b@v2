#!/bin/bash
# Lock Manager - Prevent concurrent builds and operations
# Based on patterns from: vscode tryAcquireLock, joplin LockHandler, medusa acquireLockStep

set -uo pipefail

LOCK_DIR="${HOME}/.claude/locks"
LOG_FILE="${HOME}/.claude/lock-manager.log"

# Lock timeout in seconds (stale lock cleanup)
LOCK_TIMEOUT="${LOCK_TIMEOUT:-3600}"  # 1 hour default

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_locks() {
    mkdir -p "$LOCK_DIR"
}

# =============================================================================
# LOCK MANAGEMENT (from vscode/joplin patterns)
# =============================================================================

# Get lock file path
get_lock_file() {
    local lock_name="$1"
    echo "$LOCK_DIR/${lock_name}.lock"
}

# Try to acquire a lock (non-blocking)
try_acquire() {
    local lock_name="$1"
    local owner="${2:-$$}"
    local timeout="${3:-$LOCK_TIMEOUT}"

    init_locks

    local lock_file
    lock_file=$(get_lock_file "$lock_name")

    # Check if lock exists
    if [[ -f "$lock_file" ]]; then
        # Read lock info
        local lock_pid lock_time lock_owner
        lock_pid=$(jq -r '.pid // 0' "$lock_file" 2>/dev/null || echo "0")
        lock_time=$(jq -r '.timestamp // 0' "$lock_file" 2>/dev/null || echo "0")
        lock_owner=$(jq -r '.owner // ""' "$lock_file" 2>/dev/null || echo "")

        local now
        now=$(date +%s)
        local age=$((now - lock_time))

        # Check if lock is stale (process dead or timeout)
        if [[ $lock_pid -ne 0 ]] && ! kill -0 "$lock_pid" 2>/dev/null; then
            log "Lock $lock_name held by dead process $lock_pid, removing"
            rm -f "$lock_file"
        elif [[ $age -gt $timeout ]]; then
            log "Lock $lock_name expired (age: ${age}s > ${timeout}s), removing"
            rm -f "$lock_file"
        else
            # Lock is valid and held by another process
            log "Lock $lock_name held by $lock_owner (pid: $lock_pid, age: ${age}s)"
            echo "locked:$lock_owner:$lock_pid"
            return 1
        fi
    fi

    # Create lock
    local timestamp
    timestamp=$(date +%s)

    cat > "$lock_file" << EOF
{
    "name": "$lock_name",
    "pid": $$,
    "owner": "$owner",
    "timestamp": $timestamp,
    "acquired": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    log "Acquired lock: $lock_name (owner: $owner, pid: $$)"
    echo "acquired:$owner:$$"
    return 0
}

# Acquire lock with retry (blocking)
acquire() {
    local lock_name="$1"
    local owner="${2:-$$}"
    local max_wait="${3:-300}"  # Max 5 minutes wait
    local retry_interval="${4:-2}"

    local elapsed=0

    while [[ $elapsed -lt $max_wait ]]; do
        if try_acquire "$lock_name" "$owner"; then
            return 0
        fi

        sleep "$retry_interval"
        elapsed=$((elapsed + retry_interval))
        log "Waiting for lock $lock_name (${elapsed}s/${max_wait}s)"
    done

    log "Failed to acquire lock $lock_name after ${max_wait}s"
    return 1
}

# Release a lock
release() {
    local lock_name="$1"
    local owner="${2:-$$}"

    local lock_file
    lock_file=$(get_lock_file "$lock_name")

    if [[ ! -f "$lock_file" ]]; then
        log "Lock $lock_name not found"
        return 0
    fi

    # Verify ownership before releasing
    local lock_pid lock_owner
    lock_pid=$(jq -r '.pid // 0' "$lock_file" 2>/dev/null || echo "0")
    lock_owner=$(jq -r '.owner // ""' "$lock_file" 2>/dev/null || echo "")

    if [[ "$lock_pid" != "$$" ]] && [[ "$lock_owner" != "$owner" ]]; then
        log "Cannot release lock $lock_name: owned by $lock_owner (pid: $lock_pid)"
        return 1
    fi

    rm -f "$lock_file"
    log "Released lock: $lock_name"
    return 0
}

# Force release (admin)
force_release() {
    local lock_name="$1"

    local lock_file
    lock_file=$(get_lock_file "$lock_name")

    if [[ -f "$lock_file" ]]; then
        local lock_info
        lock_info=$(cat "$lock_file")
        rm -f "$lock_file"
        log "Force released lock: $lock_name (was: $lock_info)"
    fi
}

# Check if lock is held
is_locked() {
    local lock_name="$1"

    local lock_file
    lock_file=$(get_lock_file "$lock_name")

    if [[ ! -f "$lock_file" ]]; then
        echo "unlocked"
        return 1
    fi

    # Check if lock is valid
    local lock_pid lock_time
    lock_pid=$(jq -r '.pid // 0' "$lock_file" 2>/dev/null || echo "0")
    lock_time=$(jq -r '.timestamp // 0' "$lock_file" 2>/dev/null || echo "0")

    local now
    now=$(date +%s)
    local age=$((now - lock_time))

    # Check if stale
    if [[ $lock_pid -ne 0 ]] && ! kill -0 "$lock_pid" 2>/dev/null; then
        echo "stale:dead_process"
        return 1
    elif [[ $age -gt $LOCK_TIMEOUT ]]; then
        echo "stale:timeout"
        return 1
    fi

    local lock_owner
    lock_owner=$(jq -r '.owner // "unknown"' "$lock_file")
    echo "locked:$lock_owner:$lock_pid"
    return 0
}

# Get lock info
get_info() {
    local lock_name="$1"

    local lock_file
    lock_file=$(get_lock_file "$lock_name")

    if [[ -f "$lock_file" ]]; then
        jq '.' "$lock_file"
    else
        echo '{"status":"unlocked"}'
    fi
}

# List all locks
list_locks() {
    init_locks

    echo "{"
    echo '  "locks": ['

    local first=true
    local lock_files
    lock_files=$(ls "$LOCK_DIR"/*.lock 2>/dev/null || true)

    for lock_file in $lock_files; do
        if [[ -f "$lock_file" ]]; then
            if [[ "$first" != "true" ]]; then
                echo ","
            fi
            first=false
            cat "$lock_file"
        fi
    done

    echo '  ]'
    echo "}"
}

# Cleanup stale locks
cleanup() {
    init_locks

    local cleaned=0
    local lock_files
    lock_files=$(ls "$LOCK_DIR"/*.lock 2>/dev/null || true)

    for lock_file in $lock_files; do
        if [[ -f "$lock_file" ]]; then
            local lock_name
            lock_name=$(basename "$lock_file" .lock)

            local status
            status=$(is_locked "$lock_name")

            if [[ "$status" == stale:* ]]; then
                rm -f "$lock_file"
                log "Cleaned up stale lock: $lock_name ($status)"
                cleaned=$((cleaned + 1))
            fi
        fi
    done

    echo "Cleaned up $cleaned stale locks"
}

# Execute with lock (convenience wrapper)
with_lock() {
    local lock_name="$1"
    shift
    local command=("$@")

    if ! acquire "$lock_name" "$$" 60 2; then
        echo "Failed to acquire lock: $lock_name" >&2
        return 1
    fi

    # Execute command
    local result
    set +e
    "${command[@]}"
    result=$?
    set -e

    # Always release lock
    release "$lock_name" "$$"

    return $result
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    try)
        try_acquire "${2:-default}" "${3:-$$}" "${4:-$LOCK_TIMEOUT}"
        ;;
    acquire)
        acquire "${2:-default}" "${3:-$$}" "${4:-300}" "${5:-2}"
        ;;
    release)
        release "${2:-default}" "${3:-$$}"
        ;;
    force-release)
        force_release "${2:-default}"
        ;;
    check)
        is_locked "${2:-default}"
        ;;
    info)
        get_info "${2:-default}"
        ;;
    list)
        list_locks
        ;;
    cleanup)
        cleanup
        ;;
    with)
        lock_name="${2:-default}"
        shift 2
        with_lock "$lock_name" "$@"
        ;;
    help|*)
        echo "Lock Manager"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  try <name> [owner] [timeout]      - Try to acquire lock (non-blocking)"
        echo "  acquire <name> [owner] [max_wait] [interval] - Acquire with retry"
        echo "  release <name> [owner]            - Release a lock"
        echo "  force-release <name>              - Force release (admin)"
        echo "  check <name>                      - Check if lock is held"
        echo "  info <name>                       - Get lock details"
        echo "  list                              - List all locks"
        echo "  cleanup                           - Remove stale locks"
        echo "  with <name> <command...>          - Execute command with lock"
        echo ""
        echo "Environment:"
        echo "  LOCK_TIMEOUT - Lock timeout in seconds (default: 3600)"
        ;;
esac
