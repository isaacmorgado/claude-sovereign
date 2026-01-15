#!/bin/bash
# Multi-Agent Orchestrator - Coordinate specialist agents
# Based on: ragapp AgentOrchestrator, mistralai agent patterns
# Implements specialist swarm with task routing

set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
AGENTS_DIR="${CLAUDE_DIR}/agents"
LOG_FILE="${CLAUDE_DIR}/multi-agent-orchestrator.log"

mkdir -p "$AGENTS_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Agent registry
get_agent_registry() {
    cat << 'EOF'
{
    "agents": {
        "code_writer": {
            "expertise": ["implementation", "coding", "refactoring"],
            "description": "Focused on writing high-quality code",
            "priority_for": ["implement", "code", "write", "refactor"]
        },
        "test_engineer": {
            "expertise": ["testing", "validation", "quality_assurance"],
            "description": "Focused on writing and running tests",
            "priority_for": ["test", "validate", "check", "verify"]
        },
        "security_auditor": {
            "expertise": ["security", "vulnerabilities", "auditing"],
            "description": "Focused on finding security issues",
            "priority_for": ["security", "vulnerability", "audit", "exploit"]
        },
        "performance_optimizer": {
            "expertise": ["performance", "optimization", "profiling"],
            "description": "Focused on improving performance",
            "priority_for": ["performance", "optimize", "speed", "profile"]
        },
        "documentation_writer": {
            "expertise": ["documentation", "explanations", "guides"],
            "description": "Focused on creating clear documentation",
            "priority_for": ["document", "explain", "guide", "readme"]
        },
        "debugger": {
            "expertise": ["debugging", "troubleshooting", "root_cause"],
            "description": "Focused on finding and fixing bugs",
            "priority_for": ["debug", "fix", "bug", "error", "troubleshoot"]
        }
    }
}
EOF
}

# Route task to appropriate agent
route_task() {
    local task="$1"

    log "Routing task: $task"

    local registry
    registry=$(get_agent_registry)

    # Find best matching agent
    local best_agent="code_writer"
    local best_score=0

    while IFS= read -r agent_name; do
        local keywords
        keywords=$(echo "$registry" | jq -r ".agents.$agent_name.priority_for[]" 2>/dev/null)

        local score=0
        while IFS= read -r keyword; do
            if echo "$task" | grep -qi "$keyword"; then
                score=$((score + 1))
            fi
        done <<< "$keywords"

        if (( score > best_score )); then
            best_score=$score
            best_agent="$agent_name"
        fi
    done < <(echo "$registry" | jq -r '.agents | keys[]')

    echo "$registry" | jq --arg agent "$best_agent" '{
        selected_agent: $agent,
        agent_info: .agents[$agent],
        routing_confidence: (if '"$best_score"' > 0 then '"$best_score"' * 20 else 10 end)
    }'
}

# Orchestrate multi-agent collaboration
orchestrate() {
    local task="$1"
    local require_all="${2:-false}"

    log "Orchestrating multi-agent task: $task"

    cat << EOF
{
    "task": "$task",
    "orchestration_strategy": "$(if [[ "$require_all" == "true" ]]; then echo "parallel_all"; else echo "sequential_specialists"; fi)",
    "workflow": [
        {
            "phase": "planning",
            "agents": ["code_writer"],
            "action": "Break down task into subtasks"
        },
        {
            "phase": "implementation",
            "agents": ["code_writer", "debugger"],
            "action": "Implement solution with error handling"
        },
        {
            "phase": "validation",
            "agents": ["test_engineer", "security_auditor"],
            "action": "Run tests and security checks in parallel",
            "parallel": true
        },
        {
            "phase": "optimization",
            "agents": ["performance_optimizer"],
            "action": "Profile and optimize if needed",
            "conditional": "if performance issues detected"
        },
        {
            "phase": "documentation",
            "agents": ["documentation_writer"],
            "action": "Document completed feature"
        }
    ]
}
EOF
}

case "${1:-help}" in
    route)
        route_task "${2:-task}"
        ;;
    orchestrate)
        orchestrate "${2:-task}" "${3:-false}"
        ;;
    agents)
        get_agent_registry
        ;;
    help|*)
        echo "Multi-Agent Orchestrator"
        echo "Usage: $0 <command> [args]"
        echo "  route <task>              - Route task to best agent"
        echo "  orchestrate <task> [all]  - Coordinate multi-agent workflow"
        echo "  agents                    - List available agents"
        ;;
esac
