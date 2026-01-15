#!/bin/bash
# ReAct + Reflexion Framework - Reasoning + Acting + Self-Reflection
# Based on: langchain reflection patterns, DocsGPT ReActAgent, llama_index ReActAgent
# Implements think → act → observe → reflect loop

set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
MEMORY_MANAGER="${CLAUDE_DIR}/hooks/memory-manager.sh"
LOG_FILE="${CLAUDE_DIR}/react-reflexion.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =============================================================================
# REACT CYCLE: Thought → Action → Observation
# =============================================================================

# Generate reasoning before action (based on ReAct pattern)
generate_thought() {
    local goal="$1"
    local context="$2"
    local iteration="${3:-1}"

    log "Generating thought for: $goal (iteration $iteration)"

    # Retrieve relevant memories
    local memories=""
    if [[ -x "$MEMORY_MANAGER" ]]; then
        memories=$("$MEMORY_MANAGER" remember-scored "$goal" 3 2>/dev/null || echo "[]")
    fi

    local reasoning_prompt="Before I act, let me think through this step-by-step:\\n\\n1. What is the goal? $goal\\n2. What do I know? $context\\n3. What have I learned from similar situations?\\n4. What are my options?\\n5. What is the best approach and why?\\n6. What could go wrong?\\n7. How will I know if I succeeded?\\n\\nMy reasoning:"

    jq -n \
        --arg goal "$goal" \
        --arg context "$context" \
        --argjson iteration "$iteration" \
        --argjson memories "${memories:-[]}" \
        --arg prompt "$reasoning_prompt" \
        '{
            goal: $goal,
            context: $context,
            iteration: $iteration,
            relevant_memories: $memories,
            reasoning_prompt: $prompt,
            thought: ""
        }'
}

# Record the action taken
record_action() {
    local thought="$1"
    local action="$2"
    local action_input="$3"

    log "Recording action: $action"

    jq -n \
        --arg thought "$thought" \
        --arg action "$action" \
        --arg input "$action_input" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            thought: $thought,
            action: $action,
            action_input: $input,
            timestamp: $ts
        }'
}

# Record the observation/result
record_observation() {
    local action="$1"
    local result="$2"
    local success="${3:-unknown}"

    log "Recording observation: success=$success"

    jq -n \
        --arg action "$action" \
        --arg result "$result" \
        --arg success "$success" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            action: $action,
            result: $result,
            success: $success,
            timestamp: $ts
        }'
}

# =============================================================================
# REFLEXION: Self-Critique and Learning
# =============================================================================

# Generate self-reflection on the action taken (based on Reflexion paper)
generate_reflection() {
    local thought="$1"
    local action="$2"
    local observation="$3"
    local success="${4:-unknown}"

    log "Generating reflection on action: $action (success=$success)"

    local reflection_prompt="Let me critically evaluate what I just did:\\n\\n**What I thought:** $thought\\n\\n**What I did:** $action\\n\\n**What happened:** $observation\\n\\n**Outcome:** $success\\n\\n**Self-Critique Questions:**\\n\\n1. **Quality Assessment (1-10):** How well did my approach work?\\n   - If success: What made it work? Can I do it faster/better?\\n   - If failure: What went wrong? What didn't I consider?\\n\\n2. **Alternative Approaches:** What other options did I have?\\n\\n3. **Learning Extraction:** What pattern can I extract from this?\\n\\n4. **Root Cause Analysis:** What was the TRUE reason for success/failure?\\n\\n5. **Improvement Plan:** How can I do better next time?\\n\\n**My Reflection:**"

    jq -n \
        --arg prompt "$reflection_prompt" \
        '{
            reflection_prompt: $prompt,
            quality_score: null,
            lessons_learned: [],
            alternative_approaches: [],
            pattern_extracted: null,
            improvement_suggestions: []
        }'
}

# Extract lessons from reflection and store in memory
extract_and_store_lessons() {
    local reflection_json="$1"
    local success="${2:-unknown}"

    if [[ ! -x "$MEMORY_MANAGER" ]]; then
        return 0
    fi

    log "Extracting and storing lessons from reflection"

    # Extract quality score
    local quality_score
    quality_score=$(echo "$reflection_json" | jq -r '.quality_score // 5' 2>/dev/null)

    # Extract lessons learned
    local lessons
    lessons=$(echo "$reflection_json" | jq -r '.lessons_learned[]? // empty' 2>/dev/null)

    if [[ -n "$lessons" ]]; then
        while IFS= read -r lesson; do
            "$MEMORY_MANAGER" add-context "Lesson: $lesson" "$quality_score" 2>/dev/null || true
        done <<< "$lessons"
    fi

    # Extract and store pattern
    local pattern
    pattern=$(echo "$reflection_json" | jq -r '.pattern_extracted // empty' 2>/dev/null)

    if [[ -n "$pattern" && "$pattern" != "null" ]]; then
        local trigger
        local solution
        trigger=$(echo "$pattern" | jq -r '.trigger // empty' 2>/dev/null)
        solution=$(echo "$pattern" | jq -r '.solution // empty' 2>/dev/null)

        if [[ -n "$trigger" && -n "$solution" ]]; then
            local pattern_type="optimization"
            [[ "$success" == "false" ]] && pattern_type="error_fix"

            "$MEMORY_MANAGER" add-pattern "$pattern_type" "$trigger" "$solution" 2>/dev/null || true
        fi
    fi

    # Create reflection in memory
    local thought
    local action
    thought=$(echo "$reflection_json" | jq -r '.thought // empty' 2>/dev/null)
    action=$(echo "$reflection_json" | jq -r '.action // empty' 2>/dev/null)

    "$MEMORY_MANAGER" reflect "action_evaluation" "Evaluated: $action" "Score: $quality_score/10. $lessons" 2>/dev/null || true

    log "Stored lessons and patterns in memory"
}

# =============================================================================
# FULL REACT-REFLEXION CYCLE
# =============================================================================

# Run a complete cycle: Think → Act → Observe → Reflect
run_cycle() {
    local goal="$1"
    local context="$2"
    local action="$3"
    local action_input="$4"
    local iteration="${5:-1}"

    log "Starting ReAct-Reflexion cycle $iteration for goal: $goal"

    # 1. THINK: Generate reasoning
    local thought_json
    thought_json=$(generate_thought "$goal" "$context" "$iteration")

    # 2. ACT: Record the action (actual execution happens outside)
    local action_json
    action_json=$(record_action "reasoning_generated" "$action" "$action_input")

    # Return the thought for Claude to use
    echo "$thought_json"
}

# Run reflection after action completes
run_reflection() {
    local thought="$1"
    local action="$2"
    local observation="$3"
    local success="${4:-unknown}"

    log "Starting reflection on completed action: $action"

    # Generate reflection prompt
    local reflection_json
    reflection_json=$(generate_reflection "$thought" "$action" "$observation" "$success")

    echo "$reflection_json"
}

# Process completed reflection (store lessons)
process_reflection() {
    local reflection_result="$1"
    local success="${2:-unknown}"

    log "Processing reflection results"

    extract_and_store_lessons "$reflection_result" "$success"

    echo '{"status":"reflection_processed","stored_to_memory":true}'
}

# =============================================================================
# REFLEXION HISTORY: Track improvement over time
# =============================================================================

# Get reflection history for a goal
get_reflection_history() {
    local goal="$1"
    local limit="${2:-5}"

    if [[ ! -x "$MEMORY_MANAGER" ]]; then
        echo '[]'
        return
    fi

    "$MEMORY_MANAGER" search-reflections "$goal" "$limit" 2>/dev/null || echo '[]'
}

# Get learned patterns relevant to current goal
get_relevant_patterns() {
    local goal="$1"
    local limit="${2:-3}"

    if [[ ! -x "$MEMORY_MANAGER" ]]; then
        echo '[]'
        return
    fi

    "$MEMORY_MANAGER" find-patterns "$goal" "$limit" 2>/dev/null || echo '[]'
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    think)
        # Generate reasoning before action
        generate_thought "${2:-goal}" "${3:-context}" "${4:-1}"
        ;;
    act)
        # Record action taken
        record_action "${2:-thought}" "${3:-action}" "${4:-input}"
        ;;
    observe)
        # Record observation/result
        record_observation "${2:-action}" "${3:-result}" "${4:-unknown}"
        ;;
    reflect)
        # Generate self-reflection
        generate_reflection "${2:-thought}" "${3:-action}" "${4:-observation}" "${5:-unknown}"
        ;;
    cycle)
        # Run full ReAct cycle (think → act)
        run_cycle "${2:-goal}" "${3:-context}" "${4:-action}" "${5:-input}" "${6:-1}"
        ;;
    run-reflection)
        # Run reflection after action
        run_reflection "${2:-thought}" "${3:-action}" "${4:-observation}" "${5:-unknown}"
        ;;
    process)
        # Process and store reflection
        process_reflection "${2:-reflection_json}" "${3:-unknown}"
        ;;
    history)
        # Get reflection history
        get_reflection_history "${2:-goal}" "${3:-5}"
        ;;
    patterns)
        # Get relevant patterns
        get_relevant_patterns "${2:-goal}" "${3:-3}"
        ;;
    help|*)
        echo "ReAct + Reflexion Framework - Think → Act → Observe → Reflect"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "ReAct Cycle:"
        echo "  think <goal> <context> [iteration]     - Generate reasoning before action"
        echo "  act <thought> <action> <input>         - Record action taken"
        echo "  observe <action> <result> [success]    - Record observation"
        echo "  cycle <goal> <context> <action> <input> [iteration]"
        echo "                                         - Run full think→act cycle"
        echo ""
        echo "Reflexion:"
        echo "  reflect <thought> <action> <observation> [success]"
        echo "                                         - Generate self-reflection"
        echo "  run-reflection <thought> <action> <observation> [success]"
        echo "                                         - Run reflection after action"
        echo "  process <reflection_json> [success]    - Process and store reflection"
        echo ""
        echo "History:"
        echo "  history <goal> [limit]                 - Get reflection history"
        echo "  patterns <goal> [limit]                - Get learned patterns"
        echo ""
        echo "Example workflow:"
        echo "  1. $0 cycle 'fix bug' 'error in auth' 'edit_file' 'auth.js'"
        echo "  2. [Execute the action]"
        echo "  3. $0 run-reflection 'reasoning' 'edit_file' 'fixed' 'true'"
        echo "  4. $0 process '{reflection}' 'true'"
        ;;
esac
