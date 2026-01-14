#!/bin/bash
# Agent Loop - Main Autonomous Execution Loop
# Manages the continuous execution loop for autonomous agents
# Usage: agent-loop.sh start <goal> [context] [agent_type]

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/agent-loop.log"
STATE_FILE="${HOME}/.claude/agent-loop-state.json"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize agent loop state
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "active": false,
    "current_goal": null,
    "agent_type": "general",
    "iteration": 0,
    "status": "idle",
    "loop_stats": {
        "total_iterations": 0,
        "successful_iterations": 0,
        "failed_iterations": 0
    }
}
EOF
    fi
}

# Start the autonomous agent loop
start() {
    local goal="$1"
    local context="${2:-}"
    local agent_type="${3:-general}"

    init_state
    log "Starting agent loop: goal=$goal, agent_type=$agent_type"

    local temp_file
    temp_file=$(mktemp)

    jq --arg goal "$goal" \
       --arg context "$context" \
       --arg agent_type "$agent_type" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       .active = true |
       .current_goal = $goal |
       .agent_type = $agent_type |
       .iteration = 0 |
       .status = "running" |
       .started_at = $ts
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Agent loop started"

    echo '{"status": "started", "goal": "'"$goal"'", "agent_type": "'"$agent_type"'"}'
}

# Execute one iteration of the agent loop
iterate() {
    log "Executing iteration"

    local state
    state=$(cat "$STATE_FILE")

    local iteration
    iteration=$(echo "$state" | jq -r '.iteration')
    local goal
    goal=$(echo "$state" | jq -r '.current_goal')

    local next_iteration=$((iteration + 1))

    log "Iteration $next_iteration for goal: $goal"

    # Update state
    local temp_file
    temp_file=$(mktemp)

    jq --argjson iter "$next_iteration" \
       '
       .iteration = $iter |
       .loop_stats.total_iterations += 1
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    # Output iteration instruction
    jq -n \
        --argjson iter "$next_iteration" \
        --arg goal "$goal" \
        '{
            iteration: $iter,
            goal: $goal,
            instruction: "Execute this iteration using the agent framework",
            next_action: "Think -> Act -> Observe -> Reflect"
        }'

    log "Iteration $next_iteration queued"
}

# Stop the agent loop
stop() {
    log "Stopping agent loop"

    local temp_file
    temp_file=$(mktemp)

    jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       .active = false |
       .status = "stopped" |
       .stopped_at = $ts
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    echo '{"status": "stopped", "stopped_at": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}'
}

# Record iteration result
record_result() {
    local success="${1:-true}"
    local output="${2:-}"
    local error="${3:-}"

    log "Recording iteration result: success=$success"

    local temp_file
    temp_file=$(mktemp)

    jq --arg success "$success" \
       --arg output "$output" \
       --arg error "$error" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       (if $success == "true" then .loop_stats.successful_iterations += 1 else .loop_stats.failed_iterations += 1 end) |
       .last_result = {
           success: ($success == "true"),
           output: $output,
           error: $error,
           timestamp: $ts
       }
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    echo '{"status": "recorded", "success": "'"$success"'"}'
}

# Get loop status
status() {
    local state
    state=$(cat "$STATE_FILE")

    jq '{
        active: .active,
        status: .status,
        current_goal: .current_goal,
        agent_type: .agent_type,
        iteration: .iteration,
        loop_stats: .loop_stats
    }' "$STATE_FILE"
}

# Get loop statistics
stats() {
    local state
    state=$(cat "$STATE_FILE")

    jq '.loop_stats' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Agent loop state initialized"
        ;;
    start)
        start "${2:-goal}" "${3:-}" "${4:-general}"
        ;;
    iterate)
        iterate
        ;;
    stop)
        stop
        ;;
    record_result)
        record_result "${2:-true}" "${3:-}" "${4:-}"
        ;;
    status)
        status
        ;;
    stats)
        stats
        ;;
    help|*)
        cat <<EOF
Agent Loop - Main Autonomous Execution Loop

Usage:
  $0 init                              Initialize loop state
  $0 start <goal> [context] [agent_type]  Start autonomous loop
  $0 iterate                           Execute one iteration
  $0 record_result <success> [output] [error]
      Record iteration result
  $0 stop                               Stop the loop
  $0 status                             Get current loop status
  $0 stats                              Get loop statistics

Agent Types:
  general       - General purpose agent
  researcher     - Research and investigation
  implementer   - Code implementation
  tester        - Testing and validation
  optimizer     - Performance optimization

Loop Statistics:
  total_iterations        - Total iterations executed
  successful_iterations   - Successful iterations
  failed_iterations      - Failed iterations

Examples:
  $0 start "implement auth system" "using OAuth2" "implementer"
  $0 iterate
  $0 record_result true "Code implemented successfully"
  $0 stats
EOF
        ;;
esac
