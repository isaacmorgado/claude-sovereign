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
MAX_RESTARTS=100  # Safety limit
export CLAUDE_LOOP_ACTIVE=1  # Signal hooks that we are in a loop

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
    CLAUDE_LOOP_MAX_RESTARTS=100    # Maximum restart iterations
    CLAUDE_LOOP_DELAY=2             # Seconds between restarts

FILES:
    ~/.claude/continuation-prompt.md  # Handoff file from auto-continue.sh
    ~/.claude/loop.log                # Loop activity log

STOP:
    Press Ctrl+C to stop the loop gracefully.
EOF
    exit 0
}

# Handle Ctrl+C gracefully
trap 'log "Loop stopped by user"; exit 0' INT TERM

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

log "🤖 Starting Claude infinite loop (max $MAX restarts)"

while [[ $RESTART_COUNT -lt $MAX ]]; do
    RESTART_COUNT=$((RESTART_COUNT + 1))
    log "📍 Session #${RESTART_COUNT}"
    
    # Determine how to start Claude
    if [[ -n "$INITIAL_PROMPT" ]]; then
        # First run with user-provided prompt
        log "Starting with initial prompt"
        echo "$INITIAL_PROMPT" | claude --dangerously-skip-permissions || true
        INITIAL_PROMPT=""  # Clear for subsequent runs
        
    elif [[ -f "$PROMPT_FILE" ]]; then
        # Continuation prompt from auto-continue.sh
        log "Found continuation prompt, feeding to Claude"
        PROMPT=$(cat "$PROMPT_FILE")
        rm -f "$PROMPT_FILE"
        echo "$PROMPT" | claude --dangerously-skip-permissions || true
        
    else
        # Resume latest session
        log "Resuming latest session (claude -c)"
        claude -c --dangerously-skip-permissions || true
    fi
    
    EXIT_CODE=$?
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

log "Loop complete after $RESTART_COUNT sessions"
