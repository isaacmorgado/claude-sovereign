#!/bin/bash
# Thinking Framework - Self-reflection, chain-of-thought, reasoning validation
# Based on patterns from: mcp-think-tank, midday-ai, cipher, TriliumNext, beeai-framework

set -uo pipefail

THINKING_DIR="${HOME}/.claude/thinking"
CURRENT_THOUGHT="$THINKING_DIR/current.json"
THOUGHT_HISTORY="$THINKING_DIR/history.json"
LOG_FILE="${HOME}/.claude/thinking-framework.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_thinking() {
    mkdir -p "$THINKING_DIR"
    if [[ ! -f "$THOUGHT_HISTORY" ]]; then
        echo '{"sessions":[]}' > "$THOUGHT_HISTORY"
    fi
}

# =============================================================================
# CHAIN OF THOUGHT (from midday-ai patterns)
# Step-by-step reasoning for complex tasks
# =============================================================================

# Start a new thinking session
start_thinking() {
    local task="$1"
    local context="${2:-}"

    init_thinking

    local session_id
    session_id="think_$(date +%s)"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    cat > "$CURRENT_THOUGHT" << EOF
{
    "id": "$session_id",
    "task": "$task",
    "context": "$context",
    "status": "in_progress",
    "startedAt": "$timestamp",
    "steps": [],
    "reflections": [],
    "loopDetection": {
        "contentHashes": [],
        "loopDetected": false
    }
}
EOF

    log "Started thinking session: $session_id for task: $task"
    echo "$session_id"
}

# Add a reasoning step
add_step() {
    local step_type="$1"  # analyze, plan, execute, validate, reflect
    local content="$2"
    local confidence="${3:-0.8}"

    if [[ ! -f "$CURRENT_THOUGHT" ]]; then
        log "No active thinking session"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local step_id
    step_id="step_$(date +%s%N | cut -c1-13)"

    # Calculate content hash for loop detection
    local content_hash
    content_hash=$(echo "$content" | md5sum | cut -d' ' -f1)

    # Check for reasoning loop
    local loop_detected
    loop_detected=$(jq -r --arg hash "$content_hash" '
        if (.loopDetection.contentHashes | index($hash)) then "true" else "false" end
    ' "$CURRENT_THOUGHT")

    jq --arg id "$step_id" \
       --arg type "$step_type" \
       --arg content "$content" \
       --argjson conf "$confidence" \
       --arg ts "$timestamp" \
       --arg hash "$content_hash" \
       --arg loop "$loop_detected" \
       '
       .steps += [{
           id: $id,
           type: $type,
           content: $content,
           confidence: $conf,
           timestamp: $ts
       }] |
       .loopDetection.contentHashes += [$hash] |
       .loopDetection.loopDetected = ($loop == "true")
       ' "$CURRENT_THOUGHT" > "$temp_file"

    mv "$temp_file" "$CURRENT_THOUGHT"

    if [[ "$loop_detected" == "true" ]]; then
        log "WARNING: Reasoning loop detected at step $step_id"
        echo "loop_detected"
    else
        log "Added step: $step_type ($step_id)"
        echo "$step_id"
    fi
}

# =============================================================================
# SELF-REFLECTION (from mcp-think-tank patterns)
# Analyze and critique reasoning
# =============================================================================

# Perform self-reflection on current reasoning
reflect() {
    local focus="${1:-quality}"  # quality, completeness, accuracy, alternatives
    local custom_prompt="${2:-}"

    if [[ ! -f "$CURRENT_THOUGHT" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local reflection_id
    reflection_id="reflect_$(date +%s)"

    # Get current steps for analysis
    local steps_summary
    steps_summary=$(jq -r '.steps | map("\(.type): \(.content | .[0:100])") | join("\n")' "$CURRENT_THOUGHT")

    # Build reflection based on focus
    local reflection_content=""
    case "$focus" in
        quality)
            reflection_content="Quality check: Are the reasoning steps logically sound and well-structured?"
            ;;
        completeness)
            reflection_content="Completeness check: Are there any gaps in the reasoning chain?"
            ;;
        accuracy)
            reflection_content="Accuracy check: Are the facts and assumptions correct?"
            ;;
        alternatives)
            reflection_content="Alternatives check: Were other approaches considered?"
            ;;
        custom)
            reflection_content="$custom_prompt"
            ;;
    esac

    jq --arg id "$reflection_id" \
       --arg focus "$focus" \
       --arg content "$reflection_content" \
       --arg ts "$timestamp" \
       '
       .reflections += [{
           id: $id,
           focus: $focus,
           content: $content,
           timestamp: $ts
       }]
       ' "$CURRENT_THOUGHT" > "$temp_file"

    mv "$temp_file" "$CURRENT_THOUGHT"

    log "Added reflection: $focus ($reflection_id)"
    echo "$reflection_id"
}

# =============================================================================
# REASONING LOOP DETECTION (from cipher patterns)
# Prevent circular reasoning
# =============================================================================

# Check if reasoning is stuck in a loop
check_for_loops() {
    if [[ ! -f "$CURRENT_THOUGHT" ]]; then
        echo "no_session"
        return 1
    fi

    local result
    result=$(jq -r '
        .loopDetection as $ld |
        .steps | length as $stepCount |
        if $ld.loopDetected then
            "loop_detected"
        elif $stepCount > 10 then
            "too_many_steps"
        elif ($ld.contentHashes | unique | length) < ($stepCount * 0.7 | floor) then
            "potential_repetition"
        else
            "ok"
        end
    ' "$CURRENT_THOUGHT")

    echo "$result"
}

# Get suggestions to break out of loop
get_loop_breaker() {
    local loop_type="${1:-loop_detected}"

    case "$loop_type" in
        loop_detected)
            echo "SUGGESTION: Exact reasoning loop detected. Try a different approach or decompose the problem differently."
            ;;
        too_many_steps)
            echo "SUGGESTION: Too many reasoning steps. Consider simplifying or breaking into sub-problems."
            ;;
        potential_repetition)
            echo "SUGGESTION: Repetitive reasoning patterns detected. Step back and reconsider the approach."
            ;;
        *)
            echo "SUGGESTION: Reasoning appears healthy. Continue."
            ;;
    esac
}

# =============================================================================
# THINKING PROCESS MANAGEMENT (from TriliumNext patterns)
# =============================================================================

# Complete thinking session and save to history
complete_thinking() {
    local conclusion="$1"
    local quality_score="${2:-0.8}"

    if [[ ! -f "$CURRENT_THOUGHT" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Update current thought
    jq --arg conclusion "$conclusion" \
       --argjson quality "$quality_score" \
       --arg ts "$timestamp" \
       '
       .status = "completed" |
       .conclusion = $conclusion |
       .qualityScore = $quality |
       .completedAt = $ts |
       .duration = (
           (($ts | fromdate) - (.startedAt | fromdate)) | floor
       )
       ' "$CURRENT_THOUGHT" > "$temp_file"

    mv "$temp_file" "$CURRENT_THOUGHT"

    # Add to history
    local history_temp
    history_temp=$(mktemp)

    jq --slurpfile thought "$CURRENT_THOUGHT" \
       '.sessions = [$thought[0]] + .sessions | .sessions = .sessions[:100]' \
       "$THOUGHT_HISTORY" > "$history_temp"

    mv "$history_temp" "$THOUGHT_HISTORY"

    # Archive current thought
    local archive_file="$THINKING_DIR/archive/$(jq -r '.id' "$CURRENT_THOUGHT").json"
    mkdir -p "$THINKING_DIR/archive"
    mv "$CURRENT_THOUGHT" "$archive_file"

    log "Completed thinking session"
    echo "$archive_file"
}

# Get current thinking state
get_state() {
    if [[ -f "$CURRENT_THOUGHT" ]]; then
        jq '.' "$CURRENT_THOUGHT"
    else
        echo '{"status":"no_active_session"}'
    fi
}

# Get thinking summary
get_summary() {
    if [[ ! -f "$CURRENT_THOUGHT" ]]; then
        echo "No active thinking session"
        return
    fi

    jq -r '
        "=== Thinking Session ===\n" +
        "Task: \(.task)\n" +
        "Status: \(.status)\n" +
        "Steps: \(.steps | length)\n" +
        "Reflections: \(.reflections | length)\n" +
        "Loop Status: \(if .loopDetection.loopDetected then "⚠️ LOOP DETECTED" else "✓ OK" end)\n" +
        "\n--- Step Types ---\n" +
        (.steps | group_by(.type) | map("\(.[0].type): \(length)") | join("\n"))
    ' "$CURRENT_THOUGHT"
}

# =============================================================================
# PROMPTS FOR REASONING (from beeai-framework patterns)
# =============================================================================

# Generate chain-of-thought prompt
generate_cot_prompt() {
    local task="$1"
    local context="${2:-}"

    cat << EOF
CHAIN OF THOUGHT REASONING

Task: $task
${context:+Context: $context}

Follow these steps:

1. UNDERSTAND: What exactly is being asked? What are the constraints?
2. ANALYZE: What information do we have? What's missing?
3. PLAN: What approach will solve this? What are the steps?
4. EXECUTE: Work through each step systematically
5. VALIDATE: Does the solution meet all requirements?
6. REFLECT: Is there a better approach? What did we learn?

Begin your reasoning:
EOF
}

# Generate reflection prompt
generate_reflection_prompt() {
    local reasoning="$1"
    local focus="${2:-quality}"

    cat << EOF
SELF-REFLECTION

Review the following reasoning:
---
$reasoning
---

Focus: $focus

Evaluate:
1. Is the logic sound and free of fallacies?
2. Are there any gaps or missing steps?
3. Were assumptions clearly stated and valid?
4. Could this be solved more efficiently?
5. What would improve this reasoning?

Provide your reflection:
EOF
}

# Generate critique prompt
generate_critique_prompt() {
    local solution="$1"
    local requirements="${2:-}"

    cat << EOF
SOLUTION CRITIQUE

Solution:
---
$solution
---

${requirements:+Requirements: $requirements}

Critique this solution:
1. CORRECTNESS: Does it solve the problem correctly?
2. COMPLETENESS: Does it handle all cases?
3. EFFICIENCY: Is there unnecessary complexity?
4. ROBUSTNESS: How does it handle edge cases?
5. MAINTAINABILITY: Is it clear and well-structured?

Provide specific, actionable feedback:
EOF
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    start)
        start_thinking "${2:-task}" "${3:-}"
        ;;
    step)
        add_step "${2:-analyze}" "${3:-step content}" "${4:-0.8}"
        ;;
    reflect)
        reflect "${2:-quality}" "${3:-}"
        ;;
    check-loops)
        check_for_loops
        ;;
    loop-breaker)
        get_loop_breaker "${2:-loop_detected}"
        ;;
    complete)
        complete_thinking "${2:-completed}" "${3:-0.8}"
        ;;
    state)
        get_state
        ;;
    summary)
        get_summary
        ;;
    cot-prompt)
        generate_cot_prompt "${2:-task}" "${3:-}"
        ;;
    reflection-prompt)
        generate_reflection_prompt "${2:-reasoning}" "${3:-quality}"
        ;;
    critique-prompt)
        generate_critique_prompt "${2:-solution}" "${3:-}"
        ;;
    help|*)
        echo "Thinking Framework - Self-reflection & Reasoning"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Session Commands:"
        echo "  start <task> [context]           - Start thinking session"
        echo "  step <type> <content> [conf]     - Add reasoning step"
        echo "    Types: analyze, plan, execute, validate, reflect"
        echo "  reflect <focus> [prompt]         - Add self-reflection"
        echo "    Focus: quality, completeness, accuracy, alternatives, custom"
        echo "  complete <conclusion> [score]    - Complete session"
        echo ""
        echo "Analysis Commands:"
        echo "  check-loops                      - Check for reasoning loops"
        echo "  loop-breaker <type>              - Get suggestion to break loop"
        echo "  state                            - Get current state"
        echo "  summary                          - Get session summary"
        echo ""
        echo "Prompt Generators:"
        echo "  cot-prompt <task> [context]      - Generate chain-of-thought prompt"
        echo "  reflection-prompt <reasoning>    - Generate reflection prompt"
        echo "  critique-prompt <solution>       - Generate critique prompt"
        ;;
esac
