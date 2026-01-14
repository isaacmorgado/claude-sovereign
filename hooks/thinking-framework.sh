#!/bin/bash
# Thinking Framework - Structured Thinking and Reasoning
# Provides structured thinking processes for problem solving
# Usage: thinking-framework.sh start | think | complete | sessions

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/thinking-framework.log"
STATE_FILE="${HOME}/.claude/thinking-framework-state.json"

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
    "sessions": [],
    "active_sessions": {},
    "thinking_patterns": {
        "chain_of_thought": {
            "name": "Chain of Thought",
            "description": "Step-by-step reasoning",
            "use_cases": ["complex_problems", "debugging", "analysis"]
        },
        "tree_of_thoughts": {
            "name": "Tree of Thoughts",
            "description": "Multiple solution branches",
            "use_cases": ["design", "architecture", "planning"]
        },
        "reflexion": {
            "name": "Reflexion",
            "description": "Think, Act, Observe, Reflect",
            "use_cases": ["learning", "improvement", "iteration"]
        },
        "react": {
            "name": "ReAct",
            "description": "Reasoning + Acting",
            "use_cases": ["tool_use", "execution", "interaction"]
        }
    }
}
EOF
    fi
}

# Start a thinking session
start() {
    local task="${1:-}"
    local context="${2:-}"
    local pattern="${3:-chain_of_thought}"

    init_state
    log "Starting thinking session: $task (pattern: $pattern)"

    local session_id
    session_id="session_$(date +%s)_$(shuf -i 1000-9999 -n 1)"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Create session
    local session
    session=$(jq -n \
        --arg id "$session_id" \
        --arg task "$task" \
        --arg context "$context" \
        --arg pattern "$pattern" \
        --arg timestamp "$timestamp" \
        '{
            id: $id,
            task: $task,
            context: $context,
            pattern: $pattern,
            timestamp: $timestamp,
            status: "active",
            thoughts: []
        }')

    jq ".active_sessions[\"$session_id\"] = $session" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Thinking session started: $session_id"

    # Output result
    jq -n \
        --arg session_id "$session_id" \
        --arg task "$task" \
        --arg pattern "$pattern" \
        --arg timestamp "$timestamp" \
        '{
            session_id: $session_id,
            task: $task,
            pattern: $pattern,
            timestamp: $timestamp,
            status: "active",
            message: "Thinking session started"
        }'
}

# Add thought to session
think() {
    local session_id="${1:-}"
    local thought="${2:-}"
    local thought_type="${3:-reasoning}"  # reasoning, observation, hypothesis, conclusion

    init_state
    log "Adding thought to session: $session_id"

    if [[ -z "$session_id" ]]; then
        echo '{"error":"session_id_required"}' | jq '.'
        return 1
    fi

    # Check if session exists
    local session_exists
    session_exists=$(jq ".active_sessions[\"$session_id\"]" "$STATE_FILE")

    if [[ "$session_exists" == "null" ]]; then
        echo '{"error":"session_not_found"}' | jq '.'
        return 1
    fi

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Add thought to session
    jq ".active_sessions[\"$session_id\"].thoughts += [{
        type: \"$thought_type\",
        content: \"$thought\",
        timestamp: \"$timestamp\"
    }]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Thought added to session: $session_id"

    # Output result
    jq -n \
        --arg session_id "$session_id" \
        --arg thought "$thought" \
        --arg thought_type "$thought_type" \
        --arg timestamp "$timestamp" \
        '{
            session_id: $session_id,
            thought: $thought,
            thought_type: $thought_type,
            timestamp: $timestamp,
            message: "Thought added to session"
        }'
}

# Complete a thinking session
complete() {
    local session_id="${1:-}"
    local result="${2:-}"
    local quality_score="${3:-0.8}"

    init_state
    log "Completing thinking session: $session_id"

    if [[ -z "$session_id" ]]; then
        echo '{"error":"session_id_required"}' | jq '.'
        return 1
    fi

    # Get session
    local session
    session=$(jq ".active_sessions[\"$session_id\"]" "$STATE_FILE")

    if [[ "$session" == "null" ]]; then
        echo '{"error":"session_not_found"}' | jq '.'
        return 1
    fi

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Update session with completion
    local completed_session
    completed_session=$(echo "$session" | jq -n \
        --arg result "$result" \
        --argjson quality "$quality_score" \
        --arg timestamp "$timestamp" \
        '$ARGS.positional[0] | .status = "completed" | .result = $result | .quality_score = $quality | .completed_at = $timestamp')

    # Move to sessions history
    jq ".sessions += [$completed_session] | del(.active_sessions[\"$session_id\"])" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Thinking session completed: $session_id"

    # Output result
    jq -n \
        --arg session_id "$session_id" \
        --arg result "$result" \
        --argjson quality "$quality_score" \
        --arg timestamp "$timestamp" \
        '{
            session_id: $session_id,
            result: $result,
            quality_score: $quality,
            completed_at: $timestamp,
            message: "Thinking session completed"
        }'
}

# Get thinking patterns
patterns() {
    init_state

    jq '.thinking_patterns' "$STATE_FILE"
}

# Get active sessions
active() {
    init_state

    jq '.active_sessions' "$STATE_FILE"
}

# Get session history
history() {
    local limit="${1:-10}"

    init_state

    jq ".sessions[-$limit:]" "$STATE_FILE"
}

# Get session details
get() {
    local session_id="${1:-}"

    init_state

    if [[ -z "$session_id" ]]; then
        echo '{"error":"session_id_required"}' | jq '.'
        return 1
    fi

    # Check active sessions first
    local session
    session=$(jq ".active_sessions[\"$session_id\"]" "$STATE_FILE")

    if [[ "$session" != "null" ]]; then
        echo "$session"
        return
    fi

    # Check history
    session=$(jq ".sessions[] | select(.id == \"$session_id\")" "$STATE_FILE")

    if [[ "$session" != "null" ]]; then
        echo "$session"
    else
        echo '{"error":"session_not_found"}' | jq '.'
    fi
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Thinking framework state initialized"
        ;;
    start)
        start "${2:-task}" "${3:-}" "${4:-chain_of_thought}"
        ;;
    think)
        think "${2:-session_id}" "${3:-thought}" "${4:-reasoning}"
        ;;
    complete)
        complete "${2:-session_id}" "${3:-}" "${4:-0.8}"
        ;;
    patterns)
        patterns
        ;;
    active)
        active
        ;;
    history)
        history "${2:-10}"
        ;;
    get)
        get "${2:-session_id}"
        ;;
    help|*)
        cat <<EOF
Thinking Framework - Structured Thinking and Reasoning

Usage:
  $0 start <task> [context] [pattern]    Start a thinking session
  $0 think <session_id> <thought> [type]  Add thought to session
  $0 complete <session_id> [result] [quality]  Complete session
  $0 patterns                                 Get thinking patterns
  $0 active                                   Get active sessions
  $0 history [limit]                            Get session history
  $0 get <session_id>                          Get session details

Thinking Patterns:
  chain_of_thought   - Step-by-step reasoning
  tree_of_thoughts    - Multiple solution branches
  reflexion          - Think, Act, Observe, Reflect
  react              - Reasoning + Acting

Thought Types:
  reasoning     - Logical reasoning step
  observation    - Observation or data point
  hypothesis    - Hypothesis or theory
  conclusion     - Conclusion or decision

Examples:
  $0 start "debug auth issue" "production" "chain_of_thought"
  $0 think "session_123" "The issue might be in token validation"
  $0 complete "session_123" "Fixed token expiration bug" 0.9
  $0 history
EOF
        ;;
esac
