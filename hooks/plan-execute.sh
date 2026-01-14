#!/bin/bash
# Plan-Execute - Plan Creation and Execution Management
# Creates execution plans, manages steps, and tracks progress
# Usage: plan-execute.sh create | decompose | add-step | execute | finish

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/plan-execute.log"
STATE_FILE="${HOME}/.claude/plan-execute-state.json"

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
    "plans": {},
    "active_plan": null,
    "templates": {
        "implementation": ["analyze_requirements", "design_solution", "implement_code", "write_tests", "integrate"],
        "debugging": ["reproduce_issue", "identify_root_cause", "implement_fix", "verify_fix"],
        "testing": ["setup_environment", "write_test_cases", "execute_tests", "analyze_results"],
        "refactoring": ["analyze_code", "identify_improvements", "refactor_code", "verify_behavior"]
    }
}
EOF
    fi
}

# Create a new plan
create() {
    local task="${1:-}"
    local context="${2:-}"

    init_state
    log "Creating plan for task: $task"

    if [[ -z "$task" ]]; then
        echo '{"error":"task_required"}' | jq '.'
        return 1
    fi

    local plan_id
    plan_id="plan_$(date +%s)_$(shuf -i 1000-9999 -n 1)"

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Create plan
    local plan
    plan=$(jq -n \
        --arg id "$plan_id" \
        --arg task "$task" \
        --arg context "$context" \
        --arg timestamp "$timestamp" \
        '{
            id: $id,
            task: $task,
            context: $context,
            timestamp: $timestamp,
            status: "created",
            steps: [],
            completed_steps: 0,
            total_steps: 0
        }')

    jq ".plans[\"$plan_id\"] = $plan" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    jq ".active_plan = \"$plan_id\"" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Plan created: $plan_id"

    # Output result
    jq -n \
        --arg plan_id "$plan_id" \
        --arg task "$task" \
        --arg timestamp "$timestamp" \
        '{
            plan_id: $plan_id,
            task: $task,
            timestamp: $timestamp,
            status: "created",
            message: "Plan created successfully"
        }'
}

# Decompose task into steps
decompose() {
    local task="${1:-}"
    local task_type="${2:-general}"

    init_state
    log "Decomposing task: $task (type: $task_type)"

    if [[ -z "$task" ]]; then
        echo '{"error":"task_required"}' | jq '.'
        return 1
    fi

    # Get template for task type
    local template
    template=$(jq -r ".templates[\"$task_type\"] // []" "$STATE_FILE")

    # Generate steps based on task
    local steps=()

    if [[ "$template" != "[]" ]]; then
        # Use template steps
        while IFS= read -r step; do
            steps+=("$step")
        done < <(echo "$template" | jq -r '.[]')
    else
        # Generate default steps
        steps+=("Analyze task requirements")
        steps+=("Plan approach")
        steps+=("Implement solution")
        steps+=("Test implementation")
        steps+=("Verify results")
    fi

    # Add steps to active plan
    local active_plan_id
    active_plan_id=$(jq -r '.active_plan' "$STATE_FILE")

    if [[ "$active_plan_id" != "null" && -n "$active_plan_id" ]]; then
        local steps_json
        steps_json=$(printf '%s\n' "${steps[@]}" | jq -R '.' | jq -s 'map({id: ("step_" + tostring), description: .})')

        # Update plan with steps
        jq ".plans[\"$active_plan_id\"].steps = $steps_json | .plans[\"$active_plan_id\"].total_steps = ($steps_json | length)" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"

        log "Decomposed task into ${#steps[@]} steps"

        # Output result
        jq -n \
            --arg plan_id "$active_plan_id" \
            --argjson steps "$steps_json" \
            --argjson count "${#steps[@]}" \
            '{
                plan_id: $plan_id,
                steps: $steps,
                count: $count,
                message: "Task decomposed into " + ($count | tostring) + " steps"
            }'
    else
        echo '{"error":"no_active_plan"}' | jq '.'
        return 1
    fi
}

# Add a step to the plan
add-step() {
    local step_description="${1:-}"
    local step_type="${2:-manual}"  # manual, command, function
    local dependencies="${3:-}"

    init_state
    log "Adding step to plan: $step_description"

    if [[ -z "$step_description" ]]; then
        echo '{"error":"step_description_required"}' | jq '.'
        return 1
    fi

    # Get active plan
    local active_plan_id
    active_plan_id=$(jq -r '.active_plan' "$STATE_FILE")

    if [[ "$active_plan_id" != "null" && -n "$active_plan_id" ]]; then
        local step_count
        step_count=$(jq -r ".plans[\"$active_plan_id\"].steps | length" "$STATE_FILE")

        local step_id="step_$(date +%s)_$((step_count + 1))"

        # Add step
        local step
        step=$(jq -n \
            --arg id "$step_id" \
            --arg description "$step_description" \
            --arg type "$step_type" \
            --arg dependencies "$dependencies" \
            '{
                id: $id,
                description: $description,
                type: $type,
                dependencies: ($dependencies | split(",")),
                status: "pending",
                timestamp: (now | todateiso8601)
            }')

        jq ".plans[\"$active_plan_id\"].steps += [$step] | .plans[\"$active_plan_id\"].total_steps += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"

        log "Step added: $step_id"

        # Output result
        jq -n \
            --arg step_id "$step_id" \
            --arg description "$step_description" \
            --arg type "$step_type" \
            '{
                step_id: $step_id,
                description: $description,
                type: $type,
                message: "Step added to plan"
            }'
    else
        echo '{"error":"no_active_plan"}' | jq '.'
        return 1
    fi
}

# Execute the plan
execute() {
    local plan_id="${1:-}"

    init_state
    log "Executing plan: $plan_id"

    if [[ -z "$plan_id" ]]; then
        echo '{"error":"plan_id_required"}' | jq '.'
        return 1
    fi

    # Get plan
    local plan
    plan=$(jq ".plans[\"$plan_id\"]" "$STATE_FILE")

    if [[ "$plan" == "null" ]]; then
        echo '{"error":"plan_not_found"}' | jq '.'
        return 1
    fi

    # Update plan status
    jq ".plans[\"$plan_id\"].status = \"executing\"" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Plan execution started"

    # Output result
    jq -n \
        --arg plan_id "$plan_id" \
        --arg task "$(echo "$plan" | jq -r '.task')" \
        --argjson step_count "$(echo "$plan" | jq '.total_steps')" \
        '{
            plan_id: $plan_id,
            task: $task,
            step_count: $step_count,
            status: "executing",
            message: "Plan execution started"
        }'
}

# Mark step as completed
complete-step() {
    local step_id="${1:-}"
    local result="${2:-success}"

    init_state
    log "Completing step: $step_id (result: $result)"

    if [[ -z "$step_id" ]]; then
        echo '{"error":"step_id_required"}' | jq '.'
        return 1
    fi

    # Get active plan
    local active_plan_id
    active_plan_id=$(jq -r '.active_plan' "$STATE_FILE")

    if [[ "$active_plan_id" != "null" && -n "$active_plan_id" ]]; then
        # Update step status
        jq ".plans[\"$active_plan_id\".steps[] |= (if .id == \"$step_id\" then .status = \"$result\" | .completed_at = \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\" else . end)" | .plans[\"$active_plan_id\".completed_steps += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"

        log "Step completed: $step_id"

        # Check if plan is complete
        local total_steps
        total_steps=$(jq -r ".plans[\"$active_plan_id\"].total_steps" "$STATE_FILE")

        local completed_steps
        completed_steps=$(jq -r ".plans[\"$active_plan_id\"].completed_steps" "$STATE_FILE")

        if [[ $completed_steps -ge $total_steps ]]; then
            jq ".plans[\"$active_plan_id\"].status = \"completed\"" "$STATE_FILE" > "${STATE_FILE}.tmp"
            mv "${STATE_FILE}.tmp" "$STATE_FILE"
            log "Plan completed: $active_plan_id"
        fi

        # Output result
        jq -n \
            --arg step_id "$step_id" \
            --arg result "$result" \
            --argjson completed "$completed_steps" \
            --argjson total "$total_steps" \
            --argjson is_complete "$(echo "$completed_steps >= $total_steps" | bc -l)" \
            '{
                step_id: $step_id,
                result: $result,
                completed: $completed,
                total: $total,
                is_complete: $is_complete,
                message: "Step marked as " + $result
            }'
    else
        echo '{"error":"no_active_plan"}' | jq '.'
        return 1
    fi
}

# Finish a plan
finish() {
    local plan_id="${1:-}"
    local result="${2:-completed}"
    local summary="${3:-}"

    init_state
    log "Finishing plan: $plan_id (result: $result)"

    if [[ -z "$plan_id" ]]; then
        echo '{"error":"plan_id_required"}' | jq '.'
        return 1
    fi

    # Update plan
    jq ".plans[\"$plan_id\"].status = \"$result\" | .plans[\"$plan_id\"].completed_at = \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\" | .plans[\"$plan_id\"].summary = \"$summary\"" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    # Clear active plan
    jq ".active_plan = null" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Plan finished: $plan_id"

    # Output result
    jq -n \
        --arg plan_id "$plan_id" \
        --arg result "$result" \
        --arg summary "$summary" \
        '{
            plan_id: $plan_id,
            result: $result,
            summary: $summary,
            message: "Plan finished with result: " + $result
        }'
}

# Get active plan
active() {
    init_state

    local active_plan_id
    active_plan_id=$(jq -r '.active_plan' "$STATE_FILE")

    if [[ "$active_plan_id" != "null" && -n "$active_plan_id" ]]; then
        jq ".plans[\"$active_plan_id\"]" "$STATE_FILE"
    else
        jq -n '{"active_plan": null, "message": "No active plan"}'
    fi
}

# Get plan details
get() {
    local plan_id="${1:-}"

    init_state

    if [[ -z "$plan_id" ]]; then
        echo '{"error":"plan_id_required"}' | jq '.'
        return 1
    fi

    local plan
    plan=$(jq ".plans[\"$plan_id\"]" "$STATE_FILE")

    if [[ "$plan" != "null" ]]; then
        echo "$plan"
    else
        echo '{"error":"plan_not_found"}' | jq '.'
    fi
}

# Get plan history
history() {
    local limit="${1:-10}"

    init_state

    jq '[.plans[] | .id] | .[-$limit:] | map(. as $id | .plans[$id])' "$STATE_FILE"
}

# Get templates
templates() {
    init_state

    jq '.templates' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Plan-execute state initialized"
        ;;
    create)
        create "${2:-task}" "${3:-}"
        ;;
    decompose)
        decompose "${2:-task}" "${3:-general}"
        ;;
    add-step)
        add-step "${2:-step_description}" "${3:-manual}" "${4:-}"
        ;;
    execute)
        execute "${2:-plan_id}"
        ;;
    complete-step)
        complete-step "${2:-step_id}" "${3:-success}"
        ;;
    finish)
        finish "${2:-plan_id}" "${3:-completed}" "${4:-}"
        ;;
    active)
        active
        ;;
    get)
        get "${2:-plan_id}"
        ;;
    history)
        history "${2:-10}"
        ;;
    templates)
        templates
        ;;
    help|*)
        cat <<EOF
Plan-Execute - Plan Creation and Execution Management

Usage:
  $0 create <task> [context]              Create a new plan
  $0 decompose <task> [task_type]          Decompose task into steps
  $0 add-step <description> [type] [deps]  Add step to plan
  $0 execute <plan_id>                     Execute the plan
  $0 complete-step <step_id> [result]       Mark step as complete
  $0 finish <plan_id> [result] [summary]    Finish the plan
  $0 active                                 Get active plan
  $0 get <plan_id>                         Get plan details
  $0 history [limit]                        Get plan history
  $0 templates                               Get plan templates

Task Types:
  implementation    - Code implementation tasks
  debugging        - Bug fixing tasks
  testing          - Testing tasks
  refactoring      - Code refactoring tasks
  general          - General purpose tasks

Step Types:
  manual     - Manual step
  command     - Command execution
  function    - Function call

Examples:
  $0 create "implement auth system" "user authentication"
  $0 decompose "implement auth system" "implementation"
  $0 add-step "Write auth middleware" "manual" "config.ts"
  $0 execute "plan_123"
  $0 complete-step "step_123" "success"
  $0 finish "plan_123" "completed" "Auth system implemented"
  $0 active
EOF
        ;;
esac
