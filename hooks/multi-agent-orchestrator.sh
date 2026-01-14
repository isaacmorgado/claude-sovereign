#!/bin/bash
# Multi-Agent Orchestrator - Specialist Agent Routing
# Routes tasks to specialist agents based on task type
# Usage: multi-agent-orchestrator.sh route <task>
#        multi-agent-orchestrator.sh orchestrate <task>
#        multi-agent-orchestrator.sh agents

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/multi-agent-orchestrator.log"
STATE_FILE="${HOME}/.claude/multi-agent-state.json"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Define specialist agents
init_agents() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "agents": {
        "code_writer": {
            "name": "Code Writer",
            "description": "Writes clean, efficient code following best practices",
            "expertise": ["implementation", "refactoring", "code_quality"],
            "keywords": ["implement", "write", "code", "function", "class", "module"]
        },
        "test_engineer": {
            "name": "Test Engineer",
            "description": "Creates comprehensive test suites and validates functionality",
            "expertise": ["testing", "validation", "tdd", "test_frameworks"],
            "keywords": ["test", "validate", "verify", "assert", "mock", "stub"]
        },
        "security_auditor": {
            "name": "Security Auditor",
            "description": "Reviews code for security vulnerabilities and compliance issues",
            "expertise": ["security", "auth", "encryption", "owasp", "compliance"],
            "keywords": ["security", "auth", "vulnerability", "encrypt", "sanitize", "validate"]
        },
        "performance_optimizer": {
            "name": "Performance Optimizer",
            "description": "Optimizes code for performance and scalability",
            "expertise": ["performance", "optimization", "caching", "profiling", "scalability"],
            "keywords": ["optimize", "performance", "cache", "scale", "profile", "latency"]
        },
        "documentation_writer": {
            "name": "Documentation Writer",
            "description": "Creates clear, comprehensive documentation",
            "expertise": ["documentation", "api_docs", "readme", "technical_writing"],
            "keywords": ["document", "readme", "api", "docs", "comment", "guide"]
        },
        "debugger": {
            "name": "Debugger",
            "description": "Investigates and fixes bugs and issues",
            "expertise": ["debugging", "troubleshooting", "error_analysis", "root_cause"],
            "keywords": ["debug", "fix", "bug", "error", "issue", "troubleshoot"]
        }
    },
    "routing_history": []
}
EOF
    fi
}

# Route task to appropriate specialist agent
route() {
    local task="$1"

    init_agents
    log "Routing task: $task"

    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Score each agent based on keyword matches
    local best_agent="general"
    local best_score=0
    local routing_confidence=0.5

    local agents_json
    agents_json=$(jq -r '.agents' "$STATE_FILE")

    # Analyze task and find best match
    for agent_key in code_writer test_engineer security_auditor performance_optimizer documentation_writer debugger; do
        local agent_info
        agent_info=$(echo "$agents_json" | jq -r ".[\"$agent_key\"]")

        local agent_name
        agent_name=$(echo "$agent_info" | jq -r '.name')

        local keywords
        keywords=$(echo "$agent_info" | jq -r '.keywords | join(" ")')

        # Calculate match score
        local score=0
        for keyword in $keywords; do
            if [[ "$task_lower" == *"$keyword"* ]]; then
                score=$((score + 1))
            fi
        done

        if [[ $score -gt $best_score ]]; then
            best_score=$score
            best_agent="$agent_key"
            routing_confidence=$(echo "scale=2; $score / 5" | bc -l 2>/dev/null || echo "0.6")
        fi
    done

    # Get agent details
    local selected_agent
    selected_agent=$(echo "$agents_json" | jq -r ".[\"$best_agent\"]")

    # Log routing decision
    local temp_file
    temp_file=$(mktemp)

    jq --arg task "$task" \
       --arg agent "$best_agent" \
       --argjson confidence "$routing_confidence" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '.routing_history += [{
           task: $task,
           selected_agent: $agent,
           confidence: $confidence,
           routed_at: $ts
       }] |
       .routing_history |= .[0:50]' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Routed to: $agent_name (confidence: $routing_confidence)"

    # Output routing result
    jq -n \
        --arg task "$task" \
        --arg agent "$best_agent" \
        --argjson info "$selected_agent" \
        --argjson confidence "$routing_confidence" \
        '{
            task: $task,
            selected_agent: $agent,
            agent_info: $info,
            routing_confidence: $confidence,
            alternative_agents: (.agents | keys | map(select(. != $agent)))
        }'
}

# Full orchestration workflow
orchestrate() {
    local task="$1"

    log "Starting full orchestration for: $task"

    # Step 1: Route to specialist
    local routing
    routing=$(route "$task")

    local selected_agent
    selected_agent=$(echo "$routing" | jq -r '.selected_agent')

    # Step 2: Define workflow based on agent
    local workflow=""
    local agent_name
    agent_name=$(echo "$routing" | jq -r '.agent_info.name')

    case "$selected_agent" in
        code_writer)
            workflow='[
                {"phase": "planning", "description": "Analyze requirements and design solution"},
                {"phase": "implementation", "description": "Write clean, efficient code"},
                {"phase": "review", "description": "Self-review code for quality"},
                {"phase": "validation", "description": "Verify against requirements"}
            ]'
            ;;
        test_engineer)
            workflow='[
                {"phase": "test_design", "description": "Design comprehensive test strategy"},
                {"phase": "unit_tests", "description": "Write unit tests"},
                {"phase": "integration_tests", "description": "Write integration tests"},
                {"phase": "validation", "description": "Execute and validate tests"}
            ]'
            ;;
        security_auditor)
            workflow='[
                {"phase": "threat_analysis", "description": "Identify potential security issues"},
                {"phase": "code_review", "description": "Review code for vulnerabilities"},
                {"phase": "remediation", "description": "Apply security fixes"},
                {"phase": "validation", "description": "Verify security improvements"}
            ]'
            ;;
        performance_optimizer)
            workflow='[
                {"phase": "profiling", "description": "Profile current performance"},
                {"phase": "bottleneck_analysis", "description": "Identify bottlenecks"},
                {"phase": "optimization", "description": "Apply optimizations"},
                {"phase": "benchmarking", "description": "Measure improvements"}
            ]'
            ;;
        documentation_writer)
            workflow='[
                {"phase": "structure", "description": "Plan documentation structure"},
                {"phase": "drafting", "description": "Write initial documentation"},
                {"phase": "review", "description": "Review for clarity and completeness"},
                {"phase": "finalization", "description": "Format and publish documentation"}
            ]'
            ;;
        debugger)
            workflow='[
                {"phase": "reproduction", "description": "Reproduce the issue"},
                {"phase": "analysis", "description": "Analyze root cause"},
                {"phase": "fix", "description": "Implement fix"},
                {"phase": "verification", "description": "Verify fix resolves issue"}
            ]'
            ;;
        *)
            # Default workflow
            workflow='[
                {"phase": "analysis", "description": "Analyze task requirements"},
                {"phase": "planning", "description": "Plan approach"},
                {"phase": "execution", "description": "Execute task"},
                {"phase": "validation", "description": "Validate results"}
            ]'
            ;;
    esac

    # Output full orchestration plan
    jq -n \
        --arg task "$task" \
        --arg agent "$agent_name" \
        --argjson workflow "$workflow" \
        '{
            task: $task,
            assigned_agent: $agent,
            workflow: $workflow,
            current_phase: ($workflow[0].phase),
            next_steps: ($workflow | map(.phase) | .[1:])
        }'

    log "Orchestration plan created for $agent_name"
}

# List available agents
agents() {
    init_agents

    jq '.agents | to_entries | map({agent_id: .key, name: .value.name, description: .value.description, expertise: .value.expertise})' "$STATE_FILE"
}

# Get routing history
history() {
    init_agents

    jq '.routing_history | reverse | .[0:20]' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_agents
        echo "Multi-agent orchestrator initialized"
        ;;
    route)
        route "${2:-task}"
        ;;
    orchestrate)
        orchestrate "${2:-task}"
        ;;
    agents)
        agents
        ;;
    history)
        history
        ;;
    help|*)
        cat <<EOF
Multi-Agent Orchestrator - Specialist Agent Routing

Usage:
  $0 init                              Initialize agent definitions
  $0 route <task>                     Route task to specialist agent
  $0 orchestrate <task>                Full orchestration workflow
  $0 agents                             List available specialist agents
  $0 history                             Show routing history

Specialist Agents:
  code_writer          - Writes clean, efficient code
  test_engineer        - Creates comprehensive test suites
  security_auditor      - Reviews for security vulnerabilities
  performance_optimizer   - Optimizes for performance
  documentation_writer  - Creates clear documentation
  debugger             - Investigates and fixes bugs

Routing Logic:
  - Analyzes task keywords
  - Matches against agent expertise
  - Selects agent with highest match score
  - Provides routing confidence score

Examples:
  $0 route "implement authentication"
  $0 orchestrate "optimize database queries"
  $0 agents
  $0 history
EOF
        ;;
esac
