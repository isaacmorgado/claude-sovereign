#!/bin/bash
# Agent Loop - Autonomous execution with context budget enforcement
# Based on patterns from: Roo-Code AgentLoopState, UI-TARS AgentComposer, PraisonAI, TanStack

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="${SCRIPT_DIR}/../.claude/agent"
AGENT_STATE="$AGENT_DIR/state.json"
EXECUTION_LOG="$AGENT_DIR/execution.log"
LOG_FILE="${SCRIPT_DIR}/../.claude/agent-loop.log"

# Memory integration
MEMORY_MANAGER="${SCRIPT_DIR}/memory-manager.sh"
MEMORY_AVAILABLE="false"
MEMORY_WARNING_SHOWN="false"

# Context budget settings
ITERATION_CONTEXT=0
MAX_ITERATION_CONTEXT="${MAX_ITERATION_CONTEXT:-10000}"  # tokens per iteration (chars / 4)
TOTAL_CONTEXT=0
MAX_TOTAL_CONTEXT="${MAX_TOTAL_CONTEXT:-100000}"  # total tokens for session

# Loop control
MAX_ITERATIONS="${MAX_ITERATIONS:-50}"
MAX_CONSECUTIVE_FAILURES="${MAX_CONSECUTIVE_FAILURES:-3}"

# Ensure directories exist
mkdir -p "$AGENT_DIR" 2>/dev/null || true
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

show_memory_advisory() {
    if [[ "$MEMORY_WARNING_SHOWN" == "false" ]]; then
        echo "Running stateless - memory disabled" >&2
        log "Memory manager unavailable - running stateless"
        MEMORY_WARNING_SHOWN="true"
    fi
}

# =============================================================================
# CONTEXT BUDGET MANAGEMENT
# =============================================================================

# Estimate token count from text (chars / 4 approximation)
estimate_tokens() {
    local text="$1"
    local char_count=${#text}
    echo $((char_count / 4))
}

# Track context accumulation
track_context() {
    local text="$1"
    local tokens
    tokens=$(estimate_tokens "$text")

    ITERATION_CONTEXT=$((ITERATION_CONTEXT + tokens))
    TOTAL_CONTEXT=$((TOTAL_CONTEXT + tokens))

    log "Context: iteration=$ITERATION_CONTEXT/$MAX_ITERATION_CONTEXT, total=$TOTAL_CONTEXT/$MAX_TOTAL_CONTEXT"
}

# Check if context budget is exceeded and trigger compact if needed
check_context_budget() {
    if [[ $ITERATION_CONTEXT -gt $MAX_ITERATION_CONTEXT ]]; then
        log "Iteration context budget exceeded ($ITERATION_CONTEXT > $MAX_ITERATION_CONTEXT), triggering compact"

        if [[ -x "$MEMORY_MANAGER" ]]; then
            "$MEMORY_MANAGER" context-compact 2>/dev/null || true
        fi

        ITERATION_CONTEXT=0
        return 1  # Indicate budget was exceeded
    fi

    if [[ $TOTAL_CONTEXT -gt $MAX_TOTAL_CONTEXT ]]; then
        log "Total context budget exceeded ($TOTAL_CONTEXT > $MAX_TOTAL_CONTEXT), triggering checkpoint"

        # Trigger auto-continue checkpoint
        local AUTO_CONTINUE="${SCRIPT_DIR}/auto-continue.sh"
        if [[ -x "$AUTO_CONTINUE" ]]; then
            local context_percent=$((TOTAL_CONTEXT * 100 / MAX_TOTAL_CONTEXT))
            "$AUTO_CONTINUE" "$context_percent" 2>/dev/null || true
        fi

        return 2  # Indicate total budget exceeded
    fi

    return 0
}

# Reset iteration context (called at start of each iteration)
reset_iteration_context() {
    ITERATION_CONTEXT=0
    log "Iteration context reset"
}

# Get current context status
get_context_status() {
    jq -n \
        --argjson iteration "$ITERATION_CONTEXT" \
        --argjson max_iteration "$MAX_ITERATION_CONTEXT" \
        --argjson total "$TOTAL_CONTEXT" \
        --argjson max_total "$MAX_TOTAL_CONTEXT" \
        '{
            iterationContext: $iteration,
            maxIterationContext: $max_iteration,
            iterationPercent: (if $max_iteration > 0 then ($iteration * 100 / $max_iteration) else 0 end),
            totalContext: $total,
            maxTotalContext: $max_total,
            totalPercent: (if $max_total > 0 then ($total * 100 / $max_total) else 0 end)
        }'
}

# =============================================================================
# MEMORY INTEGRATION
# =============================================================================

memory_init() {
    if [[ -x "$MEMORY_MANAGER" ]]; then
        if "$MEMORY_MANAGER" init 2>/dev/null; then
            MEMORY_AVAILABLE="true"
            log "Memory system initialized"
        else
            show_memory_advisory
        fi
    else
        show_memory_advisory
    fi
}

memory_set_task() {
    local goal="$1"
    local context="${2:-}"

    if [[ -x "$MEMORY_MANAGER" ]]; then
        if "$MEMORY_MANAGER" set-task "$goal" "$context" 2>/dev/null; then
            log "Memory: Set task - $goal"
        else
            show_memory_advisory
        fi
    else
        show_memory_advisory
    fi
}

memory_retrieve_context() {
    local query="$1"
    local limit="${2:-5}"

    if [[ -x "$MEMORY_MANAGER" ]]; then
        local memories
        memories=$("$MEMORY_MANAGER" remember-hybrid "$query" "$limit" 2>/dev/null || echo "[]")

        if [[ -n "$memories" && "$memories" != "[]" ]]; then
            # Track context from memories
            track_context "$memories"
            echo "$memories"
            log "Memory: Retrieved $(echo "$memories" | jq 'length') relevant memories"
        fi
    fi
}

memory_record_success() {
    local action_type="$1"
    local description="$2"
    local details="${3:-}"

    if [[ -x "$MEMORY_MANAGER" ]]; then
        "$MEMORY_MANAGER" record "$action_type" "$description" "success" "$details" 2>/dev/null || true
        "$MEMORY_MANAGER" log-action "$action_type" "$description" "success" '{"outcome":"success"}' 2>/dev/null || true
        log "Memory: Recorded success - $description"
    fi
}

memory_record_failure() {
    local action_type="$1"
    local description="$2"
    local error="${3:-}"

    if [[ -x "$MEMORY_MANAGER" ]]; then
        "$MEMORY_MANAGER" record "failure" "$description" "failure" "$error" 2>/dev/null || true
        "$MEMORY_MANAGER" log-action "$action_type" "$description" "$error" '{"outcome":"failure"}' 2>/dev/null || true
        log "Memory: Recorded failure - $description"
    fi
}

# =============================================================================
# AGENT STATE MACHINE
# =============================================================================

init_agent() {
    mkdir -p "$AGENT_DIR"

    # Initialize tool registry if not exists
    if [[ ! -f "$AGENT_DIR/tools.json" ]]; then
        cat > "$AGENT_DIR/tools.json" << 'EOF'
{
    "tools": {
        "read_file": {"description": "Read file contents", "command": "cat", "requiresPath": true},
        "search_code": {"description": "Search in codebase", "command": "grep -r", "requiresPattern": true},
        "run_tests": {"description": "Run test suite", "command": "npm test || pytest || go test ./...", "requiresPath": false},
        "lint_code": {"description": "Run linter", "command": "npm run lint || ruff check .", "requiresPath": false},
        "shell": {"description": "Execute shell command", "command": "bash -c", "requiresCommand": true}
    }
}
EOF
    fi
}

start_agent() {
    local goal="$1"
    local context="${2:-}"

    init_agent
    memory_init

    # Reset context tracking for new agent session
    ITERATION_CONTEXT=0
    TOTAL_CONTEXT=0

    # Check context budget before starting
    if [[ -x "$MEMORY_MANAGER" ]]; then
        log "Checking context budget..."
        "$MEMORY_MANAGER" auto-compact-if-needed 2>/dev/null || true
    fi

    local agent_id
    agent_id="agent_$(date +%s)"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Retrieve relevant memories
    local relevant_memories=""
    if [[ "$MEMORY_AVAILABLE" == "true" ]]; then
        relevant_memories=$(memory_retrieve_context "$goal" 5 2>/dev/null | jq -c '.' 2>/dev/null || echo "[]")
    fi

    cat > "$AGENT_STATE" << EOF
{
    "id": "$agent_id",
    "goal": "$goal",
    "context": "$context",
    "state": "planning",
    "iteration": 0,
    "maxIterations": $MAX_ITERATIONS,
    "consecutiveFailures": 0,
    "startedAt": "$timestamp",
    "plan": [],
    "currentStep": null,
    "executionHistory": [],
    "toolCalls": [],
    "pauseRequested": false,
    "stopRequested": false,
    "relevantMemories": ${relevant_memories:-[]},
    "contextBudget": {
        "iterationTokens": 0,
        "maxIterationTokens": $MAX_ITERATION_CONTEXT,
        "totalTokens": 0,
        "maxTotalTokens": $MAX_TOTAL_CONTEXT
    }
}
EOF

    # Set task in working memory
    memory_set_task "$goal" "$context"

    # Track initial context
    track_context "$goal $context"

    log "Started agent: $agent_id with goal: $goal"
    echo "$agent_id"
}

transition_state() {
    local new_state="$1"
    local reason="${2:-}"

    if [[ ! -f "$AGENT_STATE" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local old_state
    old_state=$(jq -r '.state' "$AGENT_STATE")

    jq --arg state "$new_state" \
       --arg reason "$reason" \
       --arg ts "$timestamp" \
       --arg old "$old_state" \
       '
       .state = $state |
       .lastTransition = {
           from: $old,
           to: $state,
           reason: $reason,
           timestamp: $ts
       }
       ' "$AGENT_STATE" > "$temp_file"

    mv "$temp_file" "$AGENT_STATE"

    log "State transition: $old_state -> $new_state (reason: $reason)"
}

# =============================================================================
# LOOP CONTROL
# =============================================================================

should_continue() {
    if [[ ! -f "$AGENT_STATE" ]]; then
        echo "false:no_agent"
        return 1
    fi

    local result
    result=$(jq -r '
        if .stopRequested then
            "false:stop_requested"
        elif .pauseRequested then
            "false:paused"
        elif .state == "completed" then
            "false:completed"
        elif .state == "failed" then
            "false:failed"
        elif .iteration >= .maxIterations then
            "false:max_iterations"
        elif .consecutiveFailures >= '"$MAX_CONSECUTIVE_FAILURES"' then
            "false:consecutive_failures"
        else
            "true:continue"
        end
    ' "$AGENT_STATE")

    echo "$result"
}

increment_iteration() {
    if [[ ! -f "$AGENT_STATE" ]]; then
        return 1
    fi

    # Reset iteration context at start of each iteration
    reset_iteration_context

    local temp_file
    temp_file=$(mktemp)

    jq --argjson iter_ctx "$ITERATION_CONTEXT" \
       --argjson total_ctx "$TOTAL_CONTEXT" \
       '
       .iteration += 1 |
       .contextBudget.iterationTokens = $iter_ctx |
       .contextBudget.totalTokens = $total_ctx
       ' "$AGENT_STATE" > "$temp_file"

    mv "$temp_file" "$AGENT_STATE"
}

record_failure() {
    local error="${1:-unknown}"

    if [[ ! -f "$AGENT_STATE" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local goal
    goal=$(jq -r '.goal' "$AGENT_STATE" 2>/dev/null || echo "")

    # Error handler integration
    local ERROR_HANDLER="${SCRIPT_DIR}/error-handler.sh"
    local error_classification="permanent"
    local should_retry="false"
    local backoff_seconds=1
    local attempt
    attempt=$(jq -r '.consecutiveFailures // 0' "$AGENT_STATE" 2>/dev/null || echo "0")

    if [[ -x "$ERROR_HANDLER" ]]; then
        log "Analyzing error with error-handler..."
        local handler_response
        handler_response=$("$ERROR_HANDLER" handle "$error" "$attempt" 3 "agent-loop:$goal" 2>/dev/null || echo '{}')

        error_classification=$(echo "$handler_response" | jq -r '.classification // "permanent"')
        should_retry=$(echo "$handler_response" | jq -r '.shouldRetry // false')
        backoff_seconds=$(echo "$handler_response" | jq -r '.backoffSeconds // 1')

        log "Error classified as: $error_classification (retry: $should_retry, backoff: ${backoff_seconds}s)"
    fi

    jq --arg error "$error" \
       --arg ts "$timestamp" \
       --arg classification "$error_classification" \
       --arg retry "$should_retry" \
       --argjson backoff "$backoff_seconds" \
       '
       .consecutiveFailures += 1 |
       .lastError = {
           message: $error,
           timestamp: $ts,
           iteration: .iteration,
           classification: $classification,
           shouldRetry: ($retry == "true"),
           backoffSeconds: $backoff
       }
       ' "$AGENT_STATE" > "$temp_file"

    mv "$temp_file" "$AGENT_STATE"

    log "Recorded failure: $error"
    memory_record_failure "execution" "$goal" "$error"
}

record_success() {
    local result="${1:-success}"

    if [[ ! -f "$AGENT_STATE" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg result "$result" \
       --arg ts "$timestamp" \
       '
       .consecutiveFailures = 0 |
       .lastSuccess = {
           result: $result,
           timestamp: $ts,
           iteration: .iteration
       }
       ' "$AGENT_STATE" > "$temp_file"

    mv "$temp_file" "$AGENT_STATE"
}

# =============================================================================
# TOOL EXECUTION
# =============================================================================

execute_tool() {
    local tool_name="$1"
    shift
    local args=("$@")

    if [[ ! -f "$AGENT_STATE" ]]; then
        echo '{"success":false,"error":"no_active_agent"}'
        return 1
    fi

    # Check context budget BEFORE execution
    if ! check_context_budget; then
        log "Context budget exceeded before tool execution"
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local tool_call_id
    tool_call_id="tool_$(date +%s%N 2>/dev/null || date +%s)"

    # Record tool call start
    jq --arg id "$tool_call_id" \
       --arg name "$tool_name" \
       --arg args "${args[*]}" \
       --arg ts "$timestamp" \
       '
       .toolCalls += [{
           id: $id,
           name: $name,
           args: $args,
           startedAt: $ts,
           status: "running"
       }]
       ' "$AGENT_STATE" > "$temp_file"

    mv "$temp_file" "$AGENT_STATE"

    log "Executing tool: $tool_name (id: $tool_call_id)"

    # Execute the tool
    local result
    local exit_code
    local start_time
    start_time=$(date +%s)

    case "$tool_name" in
        read_file)
            result=$(cat "${args[0]}" 2>&1)
            exit_code=$?
            ;;
        search_code)
            result=$(grep -r "${args[0]}" "${args[1]:-.}" 2>&1 | head -50)
            exit_code=$?
            ;;
        run_tests)
            result=$(npm test 2>&1 || pytest 2>&1 || go test ./... 2>&1)
            exit_code=$?
            ;;
        lint_code)
            result=$(npm run lint 2>&1 || ruff check . 2>&1 || go vet ./... 2>&1)
            exit_code=$?
            ;;
        shell)
            result=$(bash -c "${args[*]}" 2>&1)
            exit_code=$?
            ;;
        *)
            result="Unknown tool: $tool_name"
            exit_code=1
            ;;
    esac

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Track context from tool output
    track_context "$result"

    # Truncate result if too long
    if [[ ${#result} -gt 10000 ]]; then
        result="${result:0:10000}... (truncated)"
    fi

    # Update tool call with result
    temp_file=$(mktemp)
    local end_timestamp
    end_timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg id "$tool_call_id" \
       --arg result "$result" \
       --argjson code "$exit_code" \
       --argjson duration "$duration" \
       --arg ts "$end_timestamp" \
       '
       .toolCalls = [.toolCalls[] |
           if .id == $id then
               . + {
                   result: $result,
                   exitCode: $code,
                   durationSeconds: $duration,
                   completedAt: $ts,
                   status: (if $code == 0 then "success" else "failed" end)
               }
           else . end
       ]
       ' "$AGENT_STATE" > "$temp_file"

    mv "$temp_file" "$AGENT_STATE"

    log "Tool completed: $tool_name (exit: $exit_code, duration: ${duration}s)"

    # Return result as JSON
    jq -n \
        --arg id "$tool_call_id" \
        --arg name "$tool_name" \
        --argjson success "$([ $exit_code -eq 0 ] && echo true || echo false)" \
        --arg result "$result" \
        --argjson exitCode "$exit_code" \
        --argjson duration "$duration" \
        '{
            id: $id,
            name: $name,
            success: $success,
            result: $result,
            exitCode: $exitCode,
            durationSeconds: $duration
        }'
}

# =============================================================================
# MAIN AGENT LOOP
# =============================================================================

run_loop() {
    local goal="$1"
    local context="${2:-}"

    # Start agent
    local agent_id
    agent_id=$(start_agent "$goal" "$context")

    if [[ -z "$agent_id" ]]; then
        echo '{"success":false,"error":"failed_to_start_agent"}'
        return 1
    fi

    log "Starting agent loop: $agent_id"
    transition_state "executing" "Loop started"

    local continue_result
    while true; do
        continue_result=$(should_continue)
        local should_run="${continue_result%%:*}"
        local reason="${continue_result##*:}"

        if [[ "$should_run" != "true" ]]; then
            log "Stopping loop: $reason"
            break
        fi

        increment_iteration

        # Check context budget at start of each iteration
        if ! check_context_budget; then
            log "Context budget triggered action"
            # Don't break - just let the budget management handle it
        fi

        # Get current iteration
        local iteration
        iteration=$(jq -r '.iteration' "$AGENT_STATE")

        log "Iteration $iteration of $MAX_ITERATIONS"

        # Add small delay between iterations
        sleep 0.5
    done

    # Final state
    local final_state
    final_state=$(jq -r '.state' "$AGENT_STATE")

    # Get context summary
    local context_summary
    context_summary=$(get_context_status)

    jq -n \
        --arg id "$agent_id" \
        --arg goal "$goal" \
        --arg state "$final_state" \
        --argjson context_budget "$context_summary" \
        '{
            id: $id,
            goal: $goal,
            finalState: $state,
            contextBudget: $context_budget
        }'
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-}" in
    start)
        start_agent "${2:-}" "${3:-}"
        ;;
    run)
        run_loop "${2:-}" "${3:-}"
        ;;
    stop)
        if [[ -f "$AGENT_STATE" ]]; then
            jq '.stopRequested = true' "$AGENT_STATE" > "$AGENT_STATE.tmp"
            mv "$AGENT_STATE.tmp" "$AGENT_STATE"
            echo "Stop requested"
        fi
        ;;
    pause)
        if [[ -f "$AGENT_STATE" ]]; then
            jq '.pauseRequested = true' "$AGENT_STATE" > "$AGENT_STATE.tmp"
            mv "$AGENT_STATE.tmp" "$AGENT_STATE"
            echo "Pause requested"
        fi
        ;;
    resume)
        if [[ -f "$AGENT_STATE" ]]; then
            jq '.pauseRequested = false' "$AGENT_STATE" > "$AGENT_STATE.tmp"
            mv "$AGENT_STATE.tmp" "$AGENT_STATE"
            echo "Resumed"
        fi
        ;;
    status)
        if [[ -f "$AGENT_STATE" ]]; then
            jq '.' "$AGENT_STATE"
        else
            echo '{"status":"no_agent"}'
        fi
        ;;
    context-status)
        get_context_status
        ;;
    execute)
        execute_tool "${2:-}" "${@:3}"
        ;;
    *)
        echo "Usage: $0 {start|run|stop|pause|resume|status|context-status|execute} [args...]"
        echo ""
        echo "Commands:"
        echo "  start <goal> [context]  - Start a new agent"
        echo "  run <goal> [context]    - Run agent loop to completion"
        echo "  stop                    - Request agent stop"
        echo "  pause                   - Pause agent"
        echo "  resume                  - Resume paused agent"
        echo "  status                  - Get agent state"
        echo "  context-status          - Get context budget status"
        echo "  execute <tool> [args]   - Execute a tool"
        ;;
esac
