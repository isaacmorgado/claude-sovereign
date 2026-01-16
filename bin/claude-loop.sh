#!/bin/bash
# Claude Infinite Loop - True Autonomy
# Runs Claude indefinitely, auto-resuming on exit
#
# Usage: 
#   ~/.claude/bin/claude-loop.sh                  # Resume latest session
#   ~/.claude/bin/claude-loop.sh "initial prompt" # Start with a prompt
#   ~/.claude/bin/claude-loop.sh --help           # Show help

# set -e # Disabled to prevent loop exit on Claude error
PROMPT_FILE="${HOME}/.claude/continuation-prompt.md"
LOG_FILE="${HOME}/.claude/loop.log"
MAX_RESTARTS=999999999  # Effectively unlimited - use /auto stop to stop
SESSION_TIMEOUT="${CLAUDE_SESSION_TIMEOUT:-600}"  # 10 minutes default
HEARTBEAT_INTERVAL="${CLAUDE_HEARTBEAT_INTERVAL:-30}"  # Log progress every 30s
DISABLE_MCP="${CLAUDE_DISABLE_MCP:-0}"  # Disable MCP servers for faster startup
export CLAUDE_LOOP_ACTIVE=1  # Signal hooks that we are in a loop

# Build Claude command with optional MCP disable
CLAUDE_CMD="claude --dangerously-skip-permissions"
if [[ "$DISABLE_MCP" == "1" ]]; then
    log "🚀 MCP servers disabled for faster startup"
    # Note: claude-code doesn't have --no-mcp flag yet, but we log this for future support
    # For now, we rely on environment manipulation or config
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

show_help() {
    cat << 'EOF'
Claude Infinite Loop - True Autonomy

USAGE:
    claude-loop.sh                  # Resume latest session
    claude-loop.sh "prompt"         # Start with initial prompt
    claude-loop.sh --help           # Show this help

ENVIRONMENT:
    CLAUDE_LOOP_MAX_RESTARTS=999999999  # Maximum restart iterations (default: unlimited)
    CLAUDE_LOOP_DELAY=2                 # Seconds between restarts
    CLAUDE_SESSION_TIMEOUT=600          # Max session duration in seconds (default: 10 min)
    CLAUDE_HEARTBEAT_INTERVAL=30        # Progress logging interval in seconds (default: 30s)
    CLAUDE_DISABLE_MCP=0                # Set to 1 to disable MCP servers for faster startup

FILES:
    ~/.claude/continuation-prompt.md  # Handoff file from auto-continue.sh
    ~/.claude/loop.log                # Loop activity log
    ~/.claude/stop-loop               # Create this file to stop (or use /auto stop)

STOP:
    Use /auto stop command (recommended)
    Or: touch ~/.claude/stop-loop
    Or: Press Ctrl+C to stop gracefully
EOF
    exit 0
}

# Session timeout monitor (runs in background)
session_timeout_monitor() {
    local claude_pid=$1
    local timeout=$2
    local session_num=$3

    sleep "$timeout"

    # Check if process still running
    if kill -0 "$claude_pid" 2>/dev/null; then
        log "⏰ Session #$session_num exceeded ${timeout}s timeout - forcing checkpoint"
        # Send SIGTERM to trigger graceful shutdown
        kill -TERM "$claude_pid" 2>/dev/null
        sleep 5
        # If still running, force kill
        if kill -0 "$claude_pid" 2>/dev/null; then
            log "⚠️  Force killing session #$session_num after timeout"
            kill -9 "$claude_pid" 2>/dev/null
        fi
    fi
}

# Heartbeat monitor (logs progress periodically)
heartbeat_monitor() {
    local claude_pid=$1
    local interval=$2
    local session_num=$3

    local elapsed=0
    while kill -0 "$claude_pid" 2>/dev/null; do
        sleep "$interval"
        elapsed=$((elapsed + interval))
        if kill -0 "$claude_pid" 2>/dev/null; then
            log "💓 Session #$session_num still active (${elapsed}s elapsed)"
        fi
    done
}

# Cleanup background monitors
cleanup_monitors() {
    jobs -p | xargs kill -9 2>/dev/null || true
}

# Handle Ctrl+C gracefully
trap 'log "Loop stopped by user"; cleanup_monitors; exit 0' INT TERM

# Parse arguments
case "${1:-}" in
    --help|-h)
        show_help
        ;;
esac

INITIAL_PROMPT="${1:-}"
RESTART_COUNT=0
DELAY="${CLAUDE_LOOP_DELAY:-2}"
MAX="${CLAUDE_LOOP_MAX_RESTARTS:-$MAX_RESTARTS}"

# Ensure Claude is installed
command -v claude >/dev/null 2>&1 || { 
    echo "❌ Claude CLI not found. Install: npm install -g @anthropic-ai/claude-code"
    exit 1
}

if [[ $MAX -gt 1000000 ]]; then
    log "🤖 Starting Claude infinite loop (unlimited restarts - use /auto stop to stop)"
else
    log "🤖 Starting Claude infinite loop (max $MAX restarts)"
fi

while [[ $RESTART_COUNT -lt $MAX ]]; do
    RESTART_COUNT=$((RESTART_COUNT + 1))
    log "📍 Session #${RESTART_COUNT} (timeout: ${SESSION_TIMEOUT}s)"

    # Determine how to start Claude (in background so we can monitor it)
    if [[ -n "$INITIAL_PROMPT" ]]; then
        # First run with user-provided prompt
        log "Starting with initial prompt"
        echo "$INITIAL_PROMPT" | claude --dangerously-skip-permissions &
        CLAUDE_PID=$!
        INITIAL_PROMPT=""  # Clear for subsequent runs

    elif [[ -f "$PROMPT_FILE" ]]; then
        # Continuation prompt from auto-continue.sh
        log "Found continuation prompt, feeding to Claude"
        PROMPT=$(cat "$PROMPT_FILE")
        rm -f "$PROMPT_FILE"
        echo "$PROMPT" | claude --dangerously-skip-permissions &
        CLAUDE_PID=$!

    else
        # Resume latest session
        log "Resuming latest session (claude -c)"
        claude -c --dangerously-skip-permissions &
        CLAUDE_PID=$!
    fi

    # Start monitoring in background
    session_timeout_monitor "$CLAUDE_PID" "$SESSION_TIMEOUT" "$RESTART_COUNT" &
    TIMEOUT_MONITOR_PID=$!

    heartbeat_monitor "$CLAUDE_PID" "$HEARTBEAT_INTERVAL" "$RESTART_COUNT" &
    HEARTBEAT_MONITOR_PID=$!

    # Wait for Claude to complete
    wait "$CLAUDE_PID" 2>/dev/null || true
    EXIT_CODE=$?

    # Kill monitors (they're no longer needed)
    kill "$TIMEOUT_MONITOR_PID" "$HEARTBEAT_MONITOR_PID" 2>/dev/null || true
    wait "$TIMEOUT_MONITOR_PID" "$HEARTBEAT_MONITOR_PID" 2>/dev/null || true

    log "Claude exited with code $EXIT_CODE"
    
    # Check for stop signal
    if [[ -f "${HOME}/.claude/stop-loop" ]]; then
        log "Stop signal detected, exiting"
        rm -f "${HOME}/.claude/stop-loop"
        break
    fi
    
    # Brief pause before restart
    log "Waiting ${DELAY}s before restart..."
    sleep "$DELAY"
done

if [[ $RESTART_COUNT -ge $MAX ]]; then
    log "⚠️  Max restarts ($MAX) reached, exiting for safety"
fi

# Final cleanup
cleanup_monitors

log "Loop complete after $RESTART_COUNT sessions"
