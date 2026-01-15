#!/bin/bash
# Autonomous Orchestrator - Detects what to do and auto-triggers workflows
# No user intervention needed - fully autonomous operation

set -e

CLAUDE_DIR="${HOME}/.claude"
MEMORY_MANAGER="${CLAUDE_DIR}/hooks/memory-manager.sh"
PROJECT_DIR="${PWD}"

# Output for Claude to read
output_action() {
    local action="$1"
    local details="$2"
    echo "AUTO_ACTION:${action}:${details}"
}

# Check for buildguide.md in current project
check_buildguide() {
    if [[ -f "${PROJECT_DIR}/buildguide.md" ]]; then
        # Check if there are unchecked items
        if grep -q '^\s*- \[ \]' "${PROJECT_DIR}/buildguide.md" 2>/dev/null; then
            echo "buildguide_found"
            return 0
        fi
    fi
    echo "no_buildguide"
    return 1
}

# Check for in-progress build
check_current_build() {
    local build_file="${PROJECT_DIR}/.claude/current-build.local.md"
    if [[ -f "$build_file" ]]; then
        local phase=$(grep -o 'phase: [a-z]*' "$build_file" 2>/dev/null | cut -d' ' -f2)
        if [[ "$phase" != "complete" && -n "$phase" ]]; then
            echo "resume_build:${phase}"
            return 0
        fi
    fi
    echo "no_current_build"
    return 1
}

# Check for continuation prompt
check_continuation() {
    local cont_file="${PROJECT_DIR}/.claude/continuation-prompt.md"
    if [[ -f "$cont_file" ]]; then
        echo "continuation_found"
        return 0
    fi

    # Also check global continuation
    if [[ -f "${CLAUDE_DIR}/continuation-prompt.md" ]]; then
        echo "global_continuation_found"
        return 0
    fi

    echo "no_continuation"
    return 1
}

# Check working memory for active task
check_active_task() {
    if [[ -x "$MEMORY_MANAGER" ]]; then
        local task=$("$MEMORY_MANAGER" get-working 2>/dev/null | jq -r '.currentTask // empty' 2>/dev/null)
        if [[ -n "$task" && "$task" != "null" ]]; then
            echo "active_task:${task}"
            return 0
        fi
    fi
    echo "no_active_task"
    return 1
}

# =============================================================================
# HEALTH CHECK (Pre-orchestration validation)
# =============================================================================

RETRY_WRAPPER="${CLAUDE_DIR}/hooks/retry-wrapper.sh"
COORDINATOR="${CLAUDE_DIR}/hooks/coordinator.sh"

# Check if critical hooks are available and healthy
pre_orchestrate_health_check() {
    local critical_hooks=(
        "$MEMORY_MANAGER"
        "$COORDINATOR"
    )
    local unhealthy=()
    local circuit_issues=()
    
    for hook in "${critical_hooks[@]}"; do
        local hook_name
        hook_name=$(basename "$hook" .sh)
        
        # Check if hook exists and is executable
        if [[ ! -x "$hook" ]]; then
            unhealthy+=("$hook_name:not_executable")
            continue
        fi
        
        # Check circuit breaker state
        if [[ -x "$RETRY_WRAPPER" ]]; then
            local circuit_state
            circuit_state=$("$RETRY_WRAPPER" check "$hook" 2>/dev/null)
            if [[ "$circuit_state" == "open" ]]; then
                circuit_issues+=("$hook_name:circuit_open")
            fi
        fi
    done
    
    # Output health status as JSON
    local health_status_result="healthy"
    [[ ${#unhealthy[@]} -gt 0 || ${#circuit_issues[@]} -gt 0 ]] && health_status_result="degraded"
    [[ ${#unhealthy[@]} -gt 1 ]] && health_status_result="unhealthy"
    
    cat <<EOF
{
  "status": "$health_status_result",
  "unhealthy_hooks": $(printf '%s\n' "${unhealthy[@]}" | jq -R -s 'split("\n") | map(select(length > 0))' 2>/dev/null || echo '[]'),
  "circuit_issues": $(printf '%s\n' "${circuit_issues[@]}" | jq -R -s 'split("\n") | map(select(length > 0))' 2>/dev/null || echo '[]'),
  "checked_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

# Main orchestration logic
orchestrate() {
    # Pre-flight health check
    local health
    health=$(pre_orchestrate_health_check)
    local health_status
    health_status=$(echo "$health" | jq -r '.status // "unknown"' 2>/dev/null)
    
    if [[ "$health_status" == "unhealthy" ]]; then
        echo "$health"
        return 1
    fi
    
    local decisions=()

    # Priority 1: Check for continuation prompt (resume interrupted work)
    local cont_status=$(check_continuation)
    if [[ "$cont_status" == "continuation_found" || "$cont_status" == "global_continuation_found" ]]; then
        decisions+=("RESUME_CONTINUATION")
    fi

    # Priority 2: Check for in-progress build
    local build_status=$(check_current_build)
    if [[ "$build_status" == resume_build:* ]]; then
        local phase="${build_status#resume_build:}"
        decisions+=("RESUME_BUILD:${phase}")
    fi

    # Priority 3: Check for buildguide with unchecked items
    local guide_status=$(check_buildguide)
    if [[ "$guide_status" == "buildguide_found" ]]; then
        decisions+=("START_BUILD")
    fi

    # Priority 4: Check for active task in memory
    local task_status=$(check_active_task)
    if [[ "$task_status" == active_task:* ]]; then
        local task="${task_status#active_task:}"
        decisions+=("CONTINUE_TASK:${task}")
    fi

    # Output decisions as JSON for Claude to parse
    echo "{"
    echo "  \"decisions\": ["
    local first=true
    for decision in "${decisions[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo ","
        fi
        echo -n "    \"${decision}\""
    done
    echo ""
    echo "  ],"
    echo "  \"project_dir\": \"${PROJECT_DIR}\","
    echo "  \"has_buildguide\": $([ "$guide_status" == "buildguide_found" ] && echo "true" || echo "false"),"
    echo "  \"has_continuation\": $([ "$cont_status" != "no_continuation" ] && echo "true" || echo "false"),"
    echo "  \"has_active_build\": $([ "$build_status" != "no_current_build" ] && echo "true" || echo "false")"
    echo "}"
}

# Generate autonomous prompt for Claude
generate_autonomous_prompt() {
    local decisions=$(orchestrate)

    cat << 'PROMPT'
## Autonomous Mode Active

You are running in FULLY AUTONOMOUS mode. Execute the following without asking for user input:

PROMPT

    # Parse decisions and generate specific instructions
    if echo "$decisions" | grep -q "RESUME_CONTINUATION"; then
        cat << 'PROMPT'
### Priority 1: Resume from Continuation
1. Read the continuation prompt file
2. Execute the instructions in it immediately
3. Continue working autonomously

PROMPT
    fi

    if echo "$decisions" | grep -q "RESUME_BUILD"; then
        cat << 'PROMPT'
### Priority 2: Resume In-Progress Build
1. Read `.claude/current-build.local.md`
2. Find the current phase and step
3. Continue building from where it stopped
4. Run `/checkpoint` after completing each major step

PROMPT
    fi

    if echo "$decisions" | grep -q "START_BUILD"; then
        cat << 'PROMPT'
### Priority 3: Start Building from Guide
1. Read `buildguide.md` in the project
2. Start with the first unchecked `[ ]` section
3. Build autonomously, checking off items as completed
4. Run quality checks after each feature
5. Run `/checkpoint` after completing each section

PROMPT
    fi

    if echo "$decisions" | grep -q "CONTINUE_TASK"; then
        cat << 'PROMPT'
### Priority 4: Continue Active Task
1. Load working memory context
2. Continue the task that was in progress
3. Complete it fully before moving on

PROMPT
    fi

    cat << 'PROMPT'

### Autonomous Behaviors (Always Active)
- **Auto-checkpoint**: Run `/checkpoint` after completing any major feature or section
- **Auto-document**: Run `/document` after features pass quality gates
- **Auto-collect**: If you need research, gather it and continue
- **Auto-fix**: If tests/build fails, fix and retry (up to 3 times)
- **Auto-memory**: Record patterns and reflections as you work

### Error Handling
- If blocked, try alternative approaches before stopping
- Record all fixes to debug-log.md
- If truly stuck after 3 attempts, save state with `/checkpoint` and explain the blocker

### DO NOT:
- Ask for user confirmation
- Wait for user input
- Stop to explain what you're about to do
- Ask clarifying questions

### DO:
- Execute immediately
- Make reasonable decisions autonomously
- Keep working until the task is complete
- Save progress frequently

PROMPT

    echo ""
    echo "### Current State Detection:"
    echo '```json'
    echo "$decisions"
    echo '```'
}

# Command handling
case "${1:-orchestrate}" in
    orchestrate)
        orchestrate
        ;;
    prompt)
        generate_autonomous_prompt
        ;;
    check-build)
        check_buildguide
        ;;
    check-continuation)
        check_continuation
        ;;
    health-check)
        pre_orchestrate_health_check
        ;;
    *)
        echo "Usage: $0 {orchestrate|prompt|check-build|check-continuation|health-check}"
        exit 1
        ;;
esac
