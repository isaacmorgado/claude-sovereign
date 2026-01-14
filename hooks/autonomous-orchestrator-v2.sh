#!/bin/bash
# Autonomous Orchestrator v2 - Smart Orchestration
# Intelligent coordination of autonomous operations
# Usage: autonomous-orchestrator-v2.sh smart
#        autonomous-orchestrator-v2.sh analyze <task>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.claude/logs/autonomous-orchestrator.log"
STATE_FILE="${HOME}/.claude/autonomous-orchestrator-state.json"
MEMORY_MANAGER="${SCRIPT_DIR}/memory-manager.sh"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize orchestrator state
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "active_tasks": [],
    "completed_tasks": [],
    "decisions": [],
    "orchestration_history": []
}
EOF
    fi
}

# Smart orchestration - analyze and make decisions
smart() {
    log "Running smart orchestration"

    # Get current working memory
    local working
    working=$("$MEMORY_MANAGER" get-working 2>/dev/null || echo '{}')

    local current_task
    current_task=$(echo "$working" | jq -r '.currentTask // ""')

    local recent_context
    recent_context=$(echo "$working" | jq -r '.recentContext // []')

    # Analyze situation
    local decisions="[]"

    # Decision 1: Check if task should continue
    if [[ -n "$current_task" ]]; then
        local task_age
        task_age=$(echo "$working" | jq -r '.lastUpdated // "1970-01-01T00:00:00Z"')

        local now
        now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

        local age_seconds
        age_seconds=$(echo "($now - \"$task_age\") / 1000" | bc -l 2>/dev/null || echo "0")

        # If task is old (>1 hour), consider re-evaluating
        if [[ $age_seconds -gt 3600 ]]; then
            decisions=$(echo "$decisions" | jq --arg decision "re_evaluate_task" --arg reason "Task is over 1 hour old" --arg ts "$now" '. + [{decision: $decision, reason: $reason, timestamp: $ts}]')
        fi
    fi

    # Decision 2: Check for GitHub research needs
    local research_needed="false"
    local github_search='{}'

    if [[ -n "$current_task" ]]; then
        local task_lower
        task_lower=$(echo "$current_task" | tr '[:upper:]' '[:lower:]')

        # Check for unfamiliar library patterns
        local libraries=(
            "stripe:payment,checkout,subscription,webhook"
            "oauth:authentication,authorization,token,refresh"
            "firebase:auth,firestore,database,storage"
            "graphql:query,mutation,schema,api"
            "websocket:socket,connection,message"
            "redis:cache,session,store"
            "jwt:token,auth,decode"
            "postgres:database,query,connection"
            "mongodb:database,query,connection"
            "grpc:service,client,server"
            "kafka:message,stream,consumer"
            "twilio:sms,call,notification"
            "sendgrid:email,send,template"
            "s3:storage,bucket,upload"
            "lambda:function,handler,trigger"
        )

        for lib_entry in "${libraries[@]}"; do
            local lib_name
            local lib_keywords
            lib_name=$(echo "$lib_entry" | cut -d: -f1)
            lib_keywords=$(echo "$lib_entry" | cut -d: -f2-)

            if [[ "$task_lower" == *"$lib_name"* ]]; then
                research_needed="true"
                github_search=$(jq -n \
                    --arg action "search_github" \
                    --arg library "$lib_name" \
                    --arg keywords "$lib_keywords" \
                    '{
                        action: $action,
                        library: $library,
                        search_query: "site:github.com language:'"$lib_keywords"'",
                        instruction: "Search GitHub for '"$lib_name"' implementation examples"
                    }')
                break
            fi
        done
    fi

    # Decision 3: Check context budget
    local context_check
    context_check=$("$MEMORY_MANAGER" context-check 2>/dev/null || echo '{"status": "ok"}')

    local context_status
    context_status=$(echo "$context_check" | jq -r '.status')

    if [[ "$context_status" == "critical" ]]; then
        decisions=$(echo "$decisions" | jq --arg decision "compact_memory" --arg reason "Context at critical threshold" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '. + [{decision: $decision, reason: $reason, timestamp: $ts}]')
    fi

    # Decision 4: Check for checkpoint needed
    local file_changes
    file_changes=$(echo "$working" | jq -r '.recentActions | length // 0')

    if [[ $file_changes -ge 10 ]]; then
        decisions=$(echo "$decisions" | jq --arg decision "checkpoint" --arg reason "10+ file changes detected" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '. + [{decision: $decision, reason: $reason, timestamp: $ts}]')
    fi

    # Record decisions to state
    local temp_file
    temp_file=$(mktemp)

    jq --argjson decisions "$decisions" \
       --argjson research "$github_search" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       .decisions = $decisions + .decisions |
       .orchestration_history += [{
           timestamp: $ts,
           decisions: $decisions,
           research_triggered: ($research.action == "search_github")
       }]
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Orchestration complete: $(echo "$decisions" | jq 'length') decisions made"

    # Output orchestration result
    jq -n \
        --argjson decisions "$decisions" \
        --argjson research "$github_search" \
        --argjson context_check "$context_check" \
        '{
            decisions: $decisions,
            research: $research,
            context_status: $context_check,
            next_actions: [.decisions[].decision]
        }'
}

# Analyze a specific task
analyze() {
    local task="$1"

    log "Analyzing task: $task"

    local task_lower
    task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Determine task characteristics
    local characteristics="[]"

    # Check for research needs
    local libraries=(
        "stripe:payment,checkout,subscription,webhook"
        "oauth:authentication,authorization,token,refresh"
        "firebase:auth,firestore,database,storage"
        "graphql:query,mutation,schema,api"
        "websocket:socket,connection,message"
        "redis:cache,session,store"
        "jwt:token,auth,decode"
        "postgres:database,query,connection"
        "mongodb:database,query,connection"
        "grpc:service,client,server"
        "kafka:message,stream,consumer"
        "twilio:sms,call,notification"
        "sendgrid:email,send,template"
        "s3:storage,bucket,upload"
        "lambda:function,handler,trigger"
    )

    local research_needed="false"
    local github_search='{}'

    for lib_entry in "${libraries[@]}"; do
        local lib_name
        local lib_keywords
        lib_name=$(echo "$lib_entry" | cut -d: -f1)
        lib_keywords=$(echo "$lib_entry" | cut -d: -f2)

        if [[ "$task_lower" == *"$lib_name"* ]]; then
            research_needed="true"
            github_search=$(jq -n \
                --arg action "search_github" \
                --arg library "$lib_name" \
                --arg keywords "$lib_keywords" \
                '{
                    action: $action,
                    library: $library,
                    search_query: "site:github.com language:'"$lib_keywords"'",
                    instruction: "Search GitHub for '"$lib_name"' implementation examples"
                }')
            characteristics=$(echo "$characteristics" | jq --arg char "unfamiliar_library" --argjson lib "$lib_name" '. + [$char]')
            break
        fi
    done

    # Add other characteristics
    [[ "$task_lower" =~ (test|validate|verify) ]] && characteristics=$(echo "$characteristics" | jq '. + ["testing_task"]')
    [[ "$task_lower" =~ (implement|build|create) ]] && characteristics=$(echo "$characteristics" | jq '. + ["implementation_task"]')
    [[ "$task_lower" =~ (debug|fix|error) ]] && characteristics=$(echo "$characteristics" | jq '. + ["debugging_task"]')

    jq -n \
        --arg task "$task" \
        --argjson characteristics "$characteristics" \
        --argjson research "$github_search" \
        '{
            task: $task,
            characteristics: $characteristics,
            research_needed: ($research.action == "search_github"),
            research: $research
        }'
}

# Get orchestration status
status() {
    init_state

    jq '{
        active_tasks: .active_tasks,
        completed_tasks: .completed_tasks,
        total_decisions: (.decisions | length),
        recent_decisions: (.decisions | reverse | .[0:10])
    }' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Autonomous orchestrator v2 initialized"
        ;;
    smart)
        smart
        ;;
    analyze)
        analyze "${2:-task}"
        ;;
    status)
        status
        ;;
    help|*)
        cat <<EOF
Autonomous Orchestrator v2 - Smart Orchestration

Usage:
  $0 init                              Initialize orchestrator state
  $0 smart                             Run smart orchestration
  $0 analyze <task>                     Analyze specific task
  $0 status                            Get orchestration status

Smart Orchestration Features:
  - Auto-detects unfamiliar library needs
  - Prepares GitHub search queries
  - Monitors context budget
  - Triggers checkpoint at file change thresholds
  - Re-evaluates long-running tasks

Supported Libraries for Auto-Research:
  stripe, oauth, firebase, graphql, websocket, redis, jwt, postgres,
  mongodb, grpc, kafka, twilio, sendgrid, s3, lambda

Examples:
  $0 smart
  $0 analyze "implement stripe checkout"
  $0 status
EOF
        ;;
esac
