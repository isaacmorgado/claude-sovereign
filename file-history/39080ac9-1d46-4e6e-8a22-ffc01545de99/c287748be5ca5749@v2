#!/bin/bash
# Graceful Shutdown Handler - Clean shutdown with state preservation
# Based on patterns from: medusa GracefulShutdownServer, n8n, firecrawl, backstage

set -uo pipefail

STATE_DIR=".claude"
SHUTDOWN_FILE="$STATE_DIR/shutdown.json"
LOG_FILE="${HOME}/.claude/graceful-shutdown.log"

# Shutdown timeout in seconds
SHUTDOWN_TIMEOUT="${SHUTDOWN_TIMEOUT:-30}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =============================================================================
# SHUTDOWN MANAGEMENT (from medusa/n8n patterns)
# =============================================================================

# Register shutdown handler
register_handler() {
    local callback="${1:-}"

    # Create shutdown state
    mkdir -p "$STATE_DIR"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    cat > "$SHUTDOWN_FILE" << EOF
{
    "registered": true,
    "pid": $$,
    "registeredAt": "$timestamp",
    "callback": "$callback",
    "status": "running"
}
EOF

    log "Registered shutdown handler for PID $$"
}

# Save current state before shutdown
save_state() {
    local state_name="${1:-auto}"
    local state_data="${2:-}"

    mkdir -p "$STATE_DIR/shutdown-states"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local state_file="$STATE_DIR/shutdown-states/${state_name}_$(date +%Y%m%d_%H%M%S).json"

    # Gather current state from various sources
    local build_state="{}"
    if [[ -f "$STATE_DIR/current-build.local.md" ]]; then
        # Extract YAML frontmatter
        build_state=$(sed -n '/^---$/,/^---$/p' "$STATE_DIR/current-build.local.md" | grep -v "^---$" | yq -o json 2>/dev/null || echo '{}')
    fi

    local progress_state="{}"
    if [[ -f "${HOME}/.claude/progress/current.json" ]]; then
        progress_state=$(cat "${HOME}/.claude/progress/current.json")
    fi

    local queue_state="{}"
    if [[ -f "${HOME}/.claude/queue/tasks.json" ]]; then
        queue_state=$(jq '{pending: [.tasks[] | select(.status == "pending")] | length, in_progress: [.tasks[] | select(.status == "in_progress")] | length}' "${HOME}/.claude/queue/tasks.json")
    fi

    # Create state snapshot
    jq -n \
        --arg name "$state_name" \
        --arg ts "$timestamp" \
        --arg data "$state_data" \
        --argjson build "$build_state" \
        --argjson progress "$progress_state" \
        --argjson queue "$queue_state" \
        '{
            name: $name,
            timestamp: $ts,
            customData: $data,
            build: $build,
            progress: $progress,
            queue: $queue
        }' > "$state_file"

    log "Saved state: $state_file"
    echo "$state_file"
}

# Initiate graceful shutdown
initiate_shutdown() {
    local reason="${1:-user_request}"
    local force="${2:-false}"

    if [[ ! -f "$SHUTDOWN_FILE" ]]; then
        log "No shutdown handler registered"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg reason "$reason" \
       --arg ts "$timestamp" \
       --arg force "$force" \
       '
       .status = "shutting_down" |
       .reason = $reason |
       .initiatedAt = $ts |
       .force = ($force == "true")
       ' "$SHUTDOWN_FILE" > "$temp_file"

    mv "$temp_file" "$SHUTDOWN_FILE"

    log "Initiated shutdown: $reason (force: $force)"

    # Run cleanup tasks
    cleanup_tasks "$force"
}

# Run cleanup tasks
cleanup_tasks() {
    local force="${1:-false}"

    log "Running cleanup tasks..."

    # 1. Save current state
    save_state "shutdown" "graceful_shutdown" 2>/dev/null || true

    # 2. Release any held locks
    if [[ -x "${HOME}/.claude/hooks/lock-manager.sh" ]]; then
        "${HOME}/.claude/hooks/lock-manager.sh" cleanup 2>/dev/null || true
        log "Released locks"
    fi

    # 3. End metrics session
    if [[ -x "${HOME}/.claude/hooks/metrics-collector.sh" ]]; then
        "${HOME}/.claude/hooks/metrics-collector.sh" end 2>/dev/null || true
        log "Ended metrics session"
    fi

    # 4. Finish progress tracking
    if [[ -x "${HOME}/.claude/hooks/progress-tracker.sh" ]]; then
        "${HOME}/.claude/hooks/progress-tracker.sh" finish "interrupted" "Graceful shutdown" 2>/dev/null || true
        log "Finished progress tracking"
    fi

    # 5. Save checkpoint
    if [[ -x "${HOME}/.claude/hooks/self-healing.sh" ]]; then
        "${HOME}/.claude/hooks/self-healing.sh" checkpoint "shutdown" 2>/dev/null || true
        log "Saved checkpoint"
    fi

    # 6. Update debug log
    if [[ -f "$STATE_DIR/docs/debug-log.md" ]]; then
        echo "" >> "$STATE_DIR/docs/debug-log.md"
        echo "### Shutdown: $(date '+%Y-%m-%d %H:%M:%S')" >> "$STATE_DIR/docs/debug-log.md"
        echo "Session ended via graceful shutdown" >> "$STATE_DIR/docs/debug-log.md"
    fi

    log "Cleanup tasks complete"
}

# Check if shutdown is in progress
is_shutting_down() {
    if [[ ! -f "$SHUTDOWN_FILE" ]]; then
        echo "false"
        return 1
    fi

    local status
    status=$(jq -r '.status // "unknown"' "$SHUTDOWN_FILE")

    if [[ "$status" == "shutting_down" ]]; then
        echo "true"
        return 0
    fi

    echo "false"
    return 1
}

# Get shutdown status
get_status() {
    if [[ -f "$SHUTDOWN_FILE" ]]; then
        jq '.' "$SHUTDOWN_FILE"
    else
        echo '{"registered":false,"status":"not_registered"}'
    fi
}

# Create continuation prompt for next session
create_continuation() {
    local state_file="${1:-}"

    mkdir -p "$STATE_DIR"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Load saved state if provided
    local context=""
    if [[ -n "$state_file" ]] && [[ -f "$state_file" ]]; then
        context=$(jq -r '
            "Previous session ended at \(.timestamp).\n" +
            "Build state: \(.build | tostring)\n" +
            "Progress: \(.progress.progress // 0)% complete\n" +
            "Pending tasks: \(.queue.pending // 0)"
        ' "$state_file")
    fi

    cat > "$STATE_DIR/continue.md" << EOF
# Continuation Prompt

> Generated: $timestamp

## Previous Session State

$context

## Resume Instructions

To continue from where you left off:
1. Run \`/build\` to resume the current build
2. Check \`.claude/current-build.local.md\` for build state
3. Review \`.claude/docs/debug-log.md\` for any stuck issues

## Quick Actions

- Resume build: \`/build\`
- Check health: Run \`~/.claude/hooks/self-healing.sh status\`
- View progress: Run \`~/.claude/hooks/progress-tracker.sh summary\`
EOF

    log "Created continuation prompt"
    echo "$STATE_DIR/continue.md"
}

# Restore from last state
restore_state() {
    local state_dir="$STATE_DIR/shutdown-states"

    if [[ ! -d "$state_dir" ]]; then
        log "No saved states found"
        return 1
    fi

    # Find most recent state file
    local latest_state
    latest_state=$(ls -t "$state_dir"/*.json 2>/dev/null | head -1)

    if [[ -z "$latest_state" ]]; then
        log "No state files found"
        return 1
    fi

    log "Found state to restore: $latest_state"
    cat "$latest_state"
}

# Clear shutdown state
clear() {
    rm -f "$SHUTDOWN_FILE"
    log "Cleared shutdown state"
}

# =============================================================================
# SIGNAL HANDLERS (from firecrawl pattern)
# =============================================================================

# Setup signal handlers (call from main script)
setup_signals() {
    trap 'handle_signal SIGINT' SIGINT
    trap 'handle_signal SIGTERM' SIGTERM
    trap 'handle_signal SIGHUP' SIGHUP

    log "Signal handlers registered"
}

# Handle incoming signal
handle_signal() {
    local signal="$1"
    log "Received signal: $signal"

    case "$signal" in
        SIGINT|SIGTERM)
            initiate_shutdown "signal:$signal"
            ;;
        SIGHUP)
            # Reload configuration
            log "Reload requested (SIGHUP)"
            ;;
    esac
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    register)
        register_handler "${2:-}"
        ;;
    save)
        save_state "${2:-auto}" "${3:-}"
        ;;
    shutdown)
        initiate_shutdown "${2:-user_request}" "${3:-false}"
        ;;
    is-shutting-down)
        is_shutting_down
        ;;
    status)
        get_status
        ;;
    continue)
        create_continuation "${2:-}"
        ;;
    restore)
        restore_state
        ;;
    clear)
        clear
        ;;
    setup-signals)
        setup_signals
        ;;
    help|*)
        echo "Graceful Shutdown Handler"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  register [callback]        - Register shutdown handler"
        echo "  save [name] [data]         - Save current state"
        echo "  shutdown [reason] [force]  - Initiate graceful shutdown"
        echo "  is-shutting-down           - Check if shutdown in progress"
        echo "  status                     - Get shutdown status"
        echo "  continue [state_file]      - Create continuation prompt"
        echo "  restore                    - Restore from last saved state"
        echo "  clear                      - Clear shutdown state"
        echo "  setup-signals              - Setup signal handlers"
        echo ""
        echo "Environment:"
        echo "  SHUTDOWN_TIMEOUT - Shutdown timeout in seconds (default: 30)"
        ;;
esac
