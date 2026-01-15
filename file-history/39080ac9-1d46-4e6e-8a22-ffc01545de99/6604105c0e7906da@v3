#!/bin/bash
# Plan and Execute - Task decomposition and autonomous execution
# Based on patterns from: langchainjs PlanAndExecuteAgentExecutor, n8n, AgentGPT, obsidian-copilot

set -uo pipefail

PLAN_DIR="${HOME}/.claude/plans"
CURRENT_PLAN="$PLAN_DIR/current.json"
PLAN_HISTORY="$PLAN_DIR/history.json"
LOG_FILE="${HOME}/.claude/plan-execute.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_plans() {
    mkdir -p "$PLAN_DIR"
    if [[ ! -f "$PLAN_HISTORY" ]]; then
        echo '{"plans":[]}' > "$PLAN_HISTORY"
    fi
}

# =============================================================================
# PLAN CREATION (from langchainjs patterns)
# =============================================================================

# Create a new plan for a goal
create_plan() {
    local goal="$1"
    local context="${2:-}"

    init_plans

    local plan_id
    plan_id="plan_$(date +%s)"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    cat > "$CURRENT_PLAN" << EOF
{
    "id": "$plan_id",
    "goal": "$goal",
    "context": "$context",
    "status": "planning",
    "createdAt": "$timestamp",
    "steps": [],
    "currentStepIndex": 0,
    "completedSteps": [],
    "failedSteps": [],
    "replanning": {
        "count": 0,
        "maxReplans": 3,
        "reasons": []
    }
}
EOF

    log "Created plan: $plan_id for goal: $goal"
    echo "$plan_id"
}

# Add a step to the plan
add_step() {
    local description="$1"
    local tool="${2:-shell}"
    local args="${3:-}"
    local dependencies="${4:-}"

    if [[ ! -f "$CURRENT_PLAN" ]]; then
        log "No active plan"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local step_id
    step_id="step_$(date +%s%N | cut -c1-13)"

    jq --arg id "$step_id" \
       --arg desc "$description" \
       --arg tool "$tool" \
       --arg args "$args" \
       --arg deps "$dependencies" \
       '
       .steps += [{
           id: $id,
           description: $desc,
           tool: $tool,
           args: $args,
           dependencies: ($deps | split(",") | map(select(. != ""))),
           status: "pending",
           result: null
       }]
       ' "$CURRENT_PLAN" > "$temp_file"

    mv "$temp_file" "$CURRENT_PLAN"

    log "Added step: $description (id: $step_id)"
    echo "$step_id"
}

# Decompose a complex task into steps
decompose_task() {
    local task="$1"
    local task_type="${2:-general}"

    # Predefined decomposition patterns
    case "$task_type" in
        feature)
            echo "1. Analyze requirements and existing code"
            echo "2. Design implementation approach"
            echo "3. Write core functionality"
            echo "4. Add error handling"
            echo "5. Write tests"
            echo "6. Run lint and typecheck"
            echo "7. Run tests"
            echo "8. Document changes"
            ;;
        bugfix)
            echo "1. Reproduce the bug"
            echo "2. Identify root cause"
            echo "3. Design fix"
            echo "4. Implement fix"
            echo "5. Verify fix resolves issue"
            echo "6. Run regression tests"
            echo "7. Document fix"
            ;;
        refactor)
            echo "1. Identify code to refactor"
            echo "2. Ensure test coverage exists"
            echo "3. Make incremental changes"
            echo "4. Run tests after each change"
            echo "5. Verify behavior unchanged"
            echo "6. Update documentation"
            ;;
        test)
            echo "1. Identify untested code"
            echo "2. Design test cases"
            echo "3. Write unit tests"
            echo "4. Write integration tests"
            echo "5. Run full test suite"
            echo "6. Check coverage metrics"
            ;;
        general|*)
            echo "1. Understand the task"
            echo "2. Research and gather information"
            echo "3. Plan the approach"
            echo "4. Execute the plan"
            echo "5. Validate results"
            echo "6. Document outcome"
            ;;
    esac
}

# =============================================================================
# PLAN EXECUTION (from n8n/AgentGPT patterns)
# =============================================================================

# Get next executable step
get_next_step() {
    if [[ ! -f "$CURRENT_PLAN" ]]; then
        echo "no_plan"
        return 1
    fi

    jq -r '
        .steps as $steps |
        .currentStepIndex as $idx |
        if $idx >= ($steps | length) then
            "plan_complete"
        else
            $steps[$idx] |
            if .status == "pending" then
                # Check dependencies
                .dependencies as $deps |
                if ($deps | length) == 0 then
                    "\(.id):\(.description)"
                else
                    # Check if all dependencies are completed
                    ($deps | all(. as $dep | $steps | any(.id == $dep and .status == "completed"))) as $ready |
                    if $ready then
                        "\(.id):\(.description)"
                    else
                        "waiting_for_dependencies"
                    end
                end
            elif .status == "in_progress" then
                "step_in_progress:\(.id)"
            else
                "unexpected_state:\(.status)"
            end
        end
    ' "$CURRENT_PLAN"
}

# Start executing a step
start_step() {
    local step_id="$1"

    if [[ ! -f "$CURRENT_PLAN" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg id "$step_id" \
       --arg ts "$timestamp" \
       '
       .steps = [.steps[] |
           if .id == $id then
               . + {status: "in_progress", startedAt: $ts}
           else . end
       ]
       ' "$CURRENT_PLAN" > "$temp_file"

    mv "$temp_file" "$CURRENT_PLAN"

    log "Started step: $step_id"
}

# Complete a step
complete_step() {
    local step_id="$1"
    local result="${2:-success}"
    local output="${3:-}"

    if [[ ! -f "$CURRENT_PLAN" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg id "$step_id" \
       --arg result "$result" \
       --arg output "$output" \
       --arg ts "$timestamp" \
       '
       .steps = [.steps[] |
           if .id == $id then
               . + {
                   status: "completed",
                   result: $result,
                   output: $output,
                   completedAt: $ts
               }
           else . end
       ] |
       .completedSteps += [$id] |
       .currentStepIndex += 1
       ' "$CURRENT_PLAN" > "$temp_file"

    mv "$temp_file" "$CURRENT_PLAN"

    log "Completed step: $step_id with result: $result"
}

# Fail a step
fail_step() {
    local step_id="$1"
    local error="${2:-unknown error}"

    if [[ ! -f "$CURRENT_PLAN" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg id "$step_id" \
       --arg error "$error" \
       --arg ts "$timestamp" \
       '
       .steps = [.steps[] |
           if .id == $id then
               . + {
                   status: "failed",
                   error: $error,
                   failedAt: $ts
               }
           else . end
       ] |
       .failedSteps += [$id]
       ' "$CURRENT_PLAN" > "$temp_file"

    mv "$temp_file" "$CURRENT_PLAN"

    log "Failed step: $step_id with error: $error"
}

# =============================================================================
# REPLANNING (from obsidian-copilot/AgentGPT patterns)
# =============================================================================

# Check if replanning is needed
should_replan() {
    if [[ ! -f "$CURRENT_PLAN" ]]; then
        echo "no_plan"
        return 1
    fi

    jq -r '
        .replanning as $rp |
        .failedSteps | length as $failures |
        if $failures > 0 and $rp.count < $rp.maxReplans then
            "replan_needed:\($failures) failures"
        elif $rp.count >= $rp.maxReplans then
            "max_replans_reached"
        else
            "continue"
        end
    ' "$CURRENT_PLAN"
}

# Trigger replanning
replan() {
    local reason="$1"

    if [[ ! -f "$CURRENT_PLAN" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg reason "$reason" \
       --arg ts "$timestamp" \
       '
       .replanning.count += 1 |
       .replanning.reasons += [{reason: $reason, timestamp: $ts}] |
       .status = "replanning" |
       # Reset failed steps to pending for retry
       .steps = [.steps[] |
           if .status == "failed" then
               . + {status: "pending", retryCount: ((.retryCount // 0) + 1)}
           else . end
       ] |
       .failedSteps = []
       ' "$CURRENT_PLAN" > "$temp_file"

    mv "$temp_file" "$CURRENT_PLAN"

    log "Triggered replan: $reason"
}

# Add new steps during replanning
insert_step() {
    local after_step_id="$1"
    local description="$2"
    local tool="${3:-shell}"

    if [[ ! -f "$CURRENT_PLAN" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local step_id
    step_id="step_$(date +%s%N | cut -c1-13)"

    jq --arg after "$after_step_id" \
       --arg id "$step_id" \
       --arg desc "$description" \
       --arg tool "$tool" \
       '
       .steps as $steps |
       ($steps | to_entries | map(select(.value.id == $after)) | .[0].key // -1) as $idx |
       if $idx >= 0 then
           .steps = ($steps[:$idx+1] + [{
               id: $id,
               description: $desc,
               tool: $tool,
               status: "pending",
               insertedDuringReplan: true
           }] + $steps[$idx+1:])
       else
           .steps += [{
               id: $id,
               description: $desc,
               tool: $tool,
               status: "pending",
               insertedDuringReplan: true
           }]
       end
       ' "$CURRENT_PLAN" > "$temp_file"

    mv "$temp_file" "$CURRENT_PLAN"

    log "Inserted step after $after_step_id: $description"
    echo "$step_id"
}

# =============================================================================
# PLAN COMPLETION
# =============================================================================

# Check plan status
check_plan_status() {
    if [[ ! -f "$CURRENT_PLAN" ]]; then
        echo "no_plan"
        return 1
    fi

    jq -r '
        .steps | length as $total |
        [.[] | select(.status == "completed")] | length as $completed |
        [.[] | select(.status == "failed")] | length as $failed |
        [.[] | select(.status == "pending")] | length as $pending |
        [.[] | select(.status == "in_progress")] | length as $in_progress |
        {
            total: $total,
            completed: $completed,
            failed: $failed,
            pending: $pending,
            in_progress: $in_progress,
            progress: (if $total > 0 then ($completed * 100 / $total) else 0 end)
        } |
        "total:\(.total) completed:\(.completed) failed:\(.failed) pending:\(.pending) progress:\(.progress)%"
    ' "$CURRENT_PLAN"
}

# Complete the plan
complete_plan() {
    local outcome="${1:-success}"
    local summary="${2:-}"

    if [[ ! -f "$CURRENT_PLAN" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg outcome "$outcome" \
       --arg summary "$summary" \
       --arg ts "$timestamp" \
       '
       .status = "completed" |
       .outcome = $outcome |
       .summary = $summary |
       .completedAt = $ts |
       .duration = (
           (($ts | fromdate) - (.createdAt | fromdate)) | floor
       )
       ' "$CURRENT_PLAN" > "$temp_file"

    mv "$temp_file" "$CURRENT_PLAN"

    # Add to history
    local history_temp
    history_temp=$(mktemp)

    jq --slurpfile plan "$CURRENT_PLAN" \
       '.plans = [$plan[0]] + .plans | .plans = .plans[:50]' \
       "$PLAN_HISTORY" > "$history_temp"

    mv "$history_temp" "$PLAN_HISTORY"

    # Archive
    local archive_file="$PLAN_DIR/archive/$(jq -r '.id' "$CURRENT_PLAN").json"
    mkdir -p "$PLAN_DIR/archive"
    mv "$CURRENT_PLAN" "$archive_file"

    log "Completed plan with outcome: $outcome"
    echo "$archive_file"
}

# Get plan state
get_state() {
    if [[ -f "$CURRENT_PLAN" ]]; then
        jq '.' "$CURRENT_PLAN"
    else
        echo '{"status":"no_active_plan"}'
    fi
}

# Get plan summary
get_summary() {
    if [[ ! -f "$CURRENT_PLAN" ]]; then
        echo "No active plan"
        return
    fi

    jq -r '
        "=== Plan Summary ===" +
        "\nGoal: \(.goal)" +
        "\nStatus: \(.status)" +
        "\nSteps: \(.steps | length)" +
        "\nCompleted: \(.completedSteps | length)" +
        "\nFailed: \(.failedSteps | length)" +
        "\nReplans: \(.replanning.count)/\(.replanning.maxReplans)" +
        "\n\n--- Steps ---" +
        "\n" + (.steps | map(
            "[\(.status | .[0:1] | ascii_upcase)] \(.description)"
        ) | join("\n"))
    ' "$CURRENT_PLAN"
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    create)
        create_plan "${2:-goal}" "${3:-}"
        ;;
    add-step)
        add_step "${2:-step description}" "${3:-shell}" "${4:-}" "${5:-}"
        ;;
    decompose)
        decompose_task "${2:-task}" "${3:-general}"
        ;;
    next)
        get_next_step
        ;;
    start)
        start_step "${2:-step_id}"
        ;;
    complete)
        complete_step "${2:-step_id}" "${3:-success}" "${4:-}"
        ;;
    fail)
        fail_step "${2:-step_id}" "${3:-error}"
        ;;
    should-replan)
        should_replan
        ;;
    replan)
        replan "${2:-reason}"
        ;;
    insert)
        insert_step "${2:-after_step}" "${3:-description}" "${4:-shell}"
        ;;
    status)
        check_plan_status
        ;;
    finish)
        complete_plan "${2:-success}" "${3:-}"
        ;;
    state)
        get_state
        ;;
    summary)
        get_summary
        ;;
    help|*)
        echo "Plan and Execute - Task Decomposition System"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Plan Commands:"
        echo "  create <goal> [context]           - Create new plan"
        echo "  add-step <desc> [tool] [args] [deps] - Add step to plan"
        echo "  decompose <task> [type]           - Get decomposition template"
        echo "    Types: feature, bugfix, refactor, test, general"
        echo ""
        echo "Execution Commands:"
        echo "  next                              - Get next executable step"
        echo "  start <step_id>                   - Start executing step"
        echo "  complete <step_id> [result] [out] - Complete step"
        echo "  fail <step_id> [error]            - Mark step as failed"
        echo ""
        echo "Replanning Commands:"
        echo "  should-replan                     - Check if replan needed"
        echo "  replan <reason>                   - Trigger replanning"
        echo "  insert <after_id> <desc> [tool]   - Insert new step"
        echo ""
        echo "Status Commands:"
        echo "  status                            - Get progress stats"
        echo "  finish [outcome] [summary]        - Complete the plan"
        echo "  state                             - Get full state JSON"
        echo "  summary                           - Get human-readable summary"
        ;;
esac
