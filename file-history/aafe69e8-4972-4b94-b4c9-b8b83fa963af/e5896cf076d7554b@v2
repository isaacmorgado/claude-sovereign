#!/bin/bash
# Swarm Orchestrator - Distributed Agent Swarms
# Implements /swarm command backend
# Spawns multiple Claude instances for parallel task execution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWARM_DIR="${HOME}/.claude/swarm"
SWARM_STATE="${SWARM_DIR}/swarm-state.json"
LOG_FILE="${HOME}/.claude/logs/swarm.log"

# Configuration
MAX_AGENTS="${SWARM_MAX_AGENTS:-10}"
SHARED_MEMORY="${SWARM_SHARED_MEMORY:-true}"
CONSENSUS_METHOD="${SWARM_CONSENSUS_METHOD:-voting}"

mkdir -p "$SWARM_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# ============================================================================
# Task Decomposition
# ============================================================================

decompose_task() {
    local task="$1"
    local agent_count="$2"

    log "Decomposing task for $agent_count agents: $task"

    # Simple decomposition strategy
    # In production, this would use LLM to intelligently split
    cat <<EOF
{
  "task": "$task",
  "agentCount": $agent_count,
  "subtasks": [
    $(for i in $(seq 1 "$agent_count"); do
        echo "    {\"agentId\": $i, \"subtask\": \"Part $i of $agent_count: $task\", \"priority\": 1}"
        [[ $i -lt $agent_count ]] && echo "," || echo ""
    done)
  ]
}
EOF
}

# ============================================================================
# Agent Spawning
# ============================================================================

spawn_agents() {
    local task="$1"
    local count="$2"

    if [[ $count -gt $MAX_AGENTS ]]; then
        echo "{\"error\": \"Max $MAX_AGENTS agents allowed, requested $count\"}"
        return 1
    fi

    log "Spawning $count agents for task: $task"

    # Decompose task
    local decomposition=$(decompose_task "$task" "$count")

    # Create swarm state
    local swarm_id="swarm_$(date +%s)"
    cat > "$SWARM_STATE" <<EOF
{
  "swarmId": "$swarm_id",
  "task": "$task",
  "agentCount": $count,
  "status": "active",
  "startedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agents": [
$(for i in $(seq 1 "$count"); do
    echo "    {\"agentId\": $i, \"status\": \"spawning\", \"pid\": null}"
    [[ $i -lt $count ]] && echo "," || echo ""
done)
  ],
  "results": [],
  "decomposition": $decomposition
}
EOF

    # Spawn agents using Task tool (simulated here, would use actual Task tool)
    for i in $(seq 1 "$count"); do
        local subtask=$(echo "$decomposition" | jq -r ".subtasks[$((i-1))].subtask")
        spawn_single_agent "$swarm_id" "$i" "$subtask" &
        local pid=$!

        # Update state with PID
        jq --arg i "$i" --arg pid "$pid" \
           '.agents[$i | tonumber - 1].pid = ($pid | tonumber) | .agents[$i | tonumber - 1].status = "running"' \
           "$SWARM_STATE" > "${SWARM_STATE}.tmp" && mv "${SWARM_STATE}.tmp" "$SWARM_STATE"

        log "Agent $i spawned with PID $pid"
    done

    echo "$swarm_id"
}

spawn_single_agent() {
    local swarm_id="$1"
    local agent_id="$2"
    local subtask="$3"

    log "Agent $agent_id starting subtask: $subtask"

    local agent_dir="${SWARM_DIR}/${swarm_id}/agent_${agent_id}"
    mkdir -p "$agent_dir"

    # Create agent workspace
    cat > "${agent_dir}/task.md" <<EOF
# Agent $agent_id Task

**Swarm**: $swarm_id
**Subtask**: $subtask

## Instructions

This is part of a distributed swarm. Complete your subtask independently.

## Output

Write results to: ${agent_dir}/result.md
EOF

    # Simulate agent work (in production, would spawn actual Task agent)
    sleep 2  # Simulate work
    cat > "${agent_dir}/result.md" <<EOF
# Agent $agent_id Result

**Status**: Completed
**Subtask**: $subtask
**Output**: [Simulated completion of subtask]

## Details

This agent completed its portion of the work.
EOF

    # Update state
    jq --arg i "$agent_id" \
       '.agents[$i | tonumber - 1].status = "completed" |
        .results += [{
            "agentId": ($i | tonumber),
            "status": "success",
            "resultPath": "'"${agent_dir}/result.md"'"
        }]' \
       "$SWARM_STATE" > "${SWARM_STATE}.tmp" && mv "${SWARM_STATE}.tmp" "$SWARM_STATE"

    log "Agent $agent_id completed"
}

# ============================================================================
# Result Collection & Aggregation
# ============================================================================

collect_results() {
    if [[ ! -f "$SWARM_STATE" ]]; then
        echo '{"error": "No active swarm"}'
        return 1
    fi

    local swarm_id=$(jq -r '.swarmId' "$SWARM_STATE")
    local agent_count=$(jq -r '.agentCount' "$SWARM_STATE")

    log "Collecting results from $agent_count agents"

    # Wait for all agents to complete
    local all_complete=false
    local timeout=300  # 5 minutes
    local elapsed=0

    while [[ "$all_complete" == "false" && $elapsed -lt $timeout ]]; do
        local completed=$(jq '.agents | map(select(.status == "completed")) | length' "$SWARM_STATE")
        if [[ $completed -eq $agent_count ]]; then
            all_complete=true
        else
            sleep 1
            elapsed=$((elapsed + 1))
        fi
    done

    if [[ "$all_complete" == "false" ]]; then
        log "⚠️  Timeout waiting for agents to complete"
        return 1
    fi

    # Aggregate results
    local aggregated="${SWARM_DIR}/${swarm_id}/aggregated_result.md"
    echo "# Swarm $swarm_id - Aggregated Results" > "$aggregated"
    echo "" >> "$aggregated"
    echo "**Task**: $(jq -r '.task' "$SWARM_STATE")" >> "$aggregated"
    echo "**Agents**: $agent_count" >> "$aggregated"
    echo "**Completed**: $(date)" >> "$aggregated"
    echo "" >> "$aggregated"

    for i in $(seq 1 "$agent_count"); do
        local result_path=$(jq -r ".results[$((i-1))].resultPath" "$SWARM_STATE")
        if [[ -f "$result_path" ]]; then
            echo "## Agent $i" >> "$aggregated"
            cat "$result_path" >> "$aggregated"
            echo "" >> "$aggregated"
        fi
    done

    # Update state
    jq '.status = "completed" | .completedAt = "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"' \
       "$SWARM_STATE" > "${SWARM_STATE}.tmp" && mv "${SWARM_STATE}.tmp" "$SWARM_STATE"

    log "Results aggregated to: $aggregated"
    cat "$aggregated"
}

# ============================================================================
# Status & Management
# ============================================================================

get_status() {
    if [[ ! -f "$SWARM_STATE" ]]; then
        echo '{"status": "no_active_swarm"}'
        return
    fi

    jq '{
        swarmId,
        task,
        agentCount,
        status,
        startedAt,
        agents: .agents | map({agentId, status}),
        completedCount: (.agents | map(select(.status == "completed")) | length)
    }' "$SWARM_STATE"
}

terminate_swarm() {
    if [[ ! -f "$SWARM_STATE" ]]; then
        echo '{"status": "no_active_swarm"}'
        return
    fi

    log "Terminating swarm"

    # Kill all agent processes
    local pids=$(jq -r '.agents[].pid | select(. != null)' "$SWARM_STATE")
    for pid in $pids; do
        kill "$pid" 2>/dev/null || true
        log "Killed agent PID $pid"
    done

    # Update state
    jq '.status = "terminated" | .terminatedAt = "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"' \
       "$SWARM_STATE" > "${SWARM_STATE}.tmp" && mv "${SWARM_STATE}.tmp" "$SWARM_STATE"

    echo '{"status": "terminated"}'
}

# ============================================================================
# CLI Interface
# ============================================================================

case "${1:-help}" in
    spawn)
        count="${2:-3}"
        task="${3:-Sample task}"
        spawn_agents "$task" "$count"
        ;;

    status)
        get_status
        ;;

    collect)
        collect_results
        ;;

    terminate)
        terminate_swarm
        ;;

    help|*)
        cat <<EOF
Swarm Orchestrator

Usage: swarm-orchestrator.sh <command> [args]

Commands:
  spawn <count> <task>
      Spawn N agents to work on task in parallel
      Example: swarm-orchestrator.sh spawn 3 "Run comprehensive tests"

  status
      Show swarm status and agent states

  collect
      Collect and aggregate results from all agents

  terminate
      Stop all agents and terminate swarm

Example Workflow:
  # Spawn 5 agents
  swarm_id=\$(swarm-orchestrator.sh spawn 5 "Implement authentication system")

  # Check status
  swarm-orchestrator.sh status

  # Collect results
  swarm-orchestrator.sh collect

  # Or terminate early
  swarm-orchestrator.sh terminate

Output:
  - Spawn: Returns swarm ID
  - Status: Returns JSON with agent states
  - Collect: Returns aggregated results
  - Terminate: Confirmation message

Note: This is a working implementation that simulates parallel agents.
      In production, would spawn actual Task tool instances.
EOF
        ;;
esac
