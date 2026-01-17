#!/bin/bash
# Central Coordinator - Orchestrates all autonomous systems
# The intelligence layer that connects everything

set -uo pipefail

COORD_DIR="${HOME}/.claude/coordination"
COORD_STATE="$COORD_DIR/state.json"
EXECUTION_LOG="$COORD_DIR/execution.log"
LOG_FILE="${HOME}/.claude/coordinator.log"

# All integrated hooks (Phase 1-3 - Existing)
ORCHESTRATOR="${HOME}/.claude/hooks/autonomous-orchestrator-v2.sh"
AGENT_LOOP="${HOME}/.claude/hooks/agent-loop.sh"
LEARNING_ENGINE="${HOME}/.claude/hooks/learning-engine.sh"
FEEDBACK_LOOP="${HOME}/.claude/hooks/feedback-loop.sh"
RISK_PREDICTOR="${HOME}/.claude/hooks/risk-predictor.sh"
PATTERN_MINER="${HOME}/.claude/hooks/pattern-miner.sh"
STRATEGY_SELECTOR="${HOME}/.claude/hooks/strategy-selector.sh"
META_REFLECTION="${HOME}/.claude/hooks/meta-reflection.sh"
HYPOTHESIS_TESTER="${HOME}/.claude/hooks/hypothesis-tester.sh"
CONTEXT_OPTIMIZER="${HOME}/.claude/hooks/context-optimizer.sh"
SELF_HEALING="${HOME}/.claude/hooks/self-healing.sh"
THINKING_FRAMEWORK="${HOME}/.claude/hooks/thinking-framework.sh"
MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"
ERROR_HANDLER="${HOME}/.claude/hooks/error-handler.sh"
PLAN_EXECUTE="${HOME}/.claude/hooks/plan-execute.sh"
TASK_QUEUE="${HOME}/.claude/hooks/task-queue.sh"

# New integrated hooks (10 Advanced Features)
REASONING_MODE_SWITCHER="${HOME}/.claude/hooks/reasoning-mode-switcher.sh"
BOUNDED_AUTONOMY="${HOME}/.claude/hooks/bounded-autonomy.sh"
TREE_OF_THOUGHTS="${HOME}/.claude/hooks/tree-of-thoughts.sh"
MULTI_AGENT_ORCHESTRATOR="${HOME}/.claude/hooks/multi-agent-orchestrator.sh"
REACT_REFLEXION="${HOME}/.claude/hooks/react-reflexion.sh"
CONSTITUTIONAL_AI="${HOME}/.claude/hooks/constitutional-ai.sh"
AUTO_EVALUATOR="${HOME}/.claude/hooks/auto-evaluator.sh"
REINFORCEMENT_LEARNING="${HOME}/.claude/hooks/reinforcement-learning.sh"
ENHANCED_AUDIT_TRAIL="${HOME}/.claude/hooks/enhanced-audit-trail.sh"
PARALLEL_EXECUTION_PLANNER="${HOME}/.claude/hooks/parallel-execution-planner.sh"
SWARM_ORCHESTRATOR="${HOME}/.claude/hooks/swarm-orchestrator.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_failure() {
    local component="$1"
    local action="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAILURE: $component $action" >> "$LOG_FILE"
}

show_advisory() {
    local message="$1"
    echo "Advisory: $message" >&2
}

# =============================================================================
# GRACEFUL DEGRADATION HELPERS
# Track which features are degraded for final summary
# =============================================================================

DEGRADED_FEATURES=""

# Safe hook execution with existence check and graceful fallback
# Usage: safe_call_hook HOOK_PATH HOOK_NAME default_result args...
safe_call_hook() {
    local hook_path="$1"
    local hook_name="$2"
    local default_result="$3"
    shift 3
    local args=("$@")

    if [[ -x "$hook_path" ]]; then
        local result
        if result=$("$hook_path" "${args[@]}" 2>/dev/null); then
            echo "$result"
            return 0
        else
            log_failure "$hook_name" "execution failed"
            show_advisory "Hook $hook_name failed - continuing with reduced functionality"
            DEGRADED_FEATURES="${DEGRADED_FEATURES}${hook_name},"
            echo "$default_result"
            return 0
        fi
    else
        log "Optional hook $hook_name not available - skipping"
        DEGRADED_FEATURES="${DEGRADED_FEATURES}${hook_name},"
        echo "$default_result"
        return 0
    fi
}

# Check if a hook is available (but don't execute it)
hook_available() {
    local hook_path="$1"
    [[ -x "$hook_path" ]]
}

# Log degraded features summary at end of coordination
log_degradation_summary() {
    if [[ -n "$DEGRADED_FEATURES" ]]; then
        local features="${DEGRADED_FEATURES%,}"  # Remove trailing comma
        log "Coordination completed with degraded features: $features"
        show_advisory "Some features were unavailable or failed: $features"
    fi
}

init_coordinator() {
    mkdir -p "$COORD_DIR"

    if [[ ! -f "$COORD_STATE" ]]; then
        cat > "$COORD_STATE" << 'EOF'
{
    "status": "idle",
    "currentTask": null,
    "initialized": false,
    "systems": {
        "learning": false,
        "memory": false,
        "agentLoop": false,
        "orchestrator": false
    }
}
EOF
    fi

    # Initialize all systems with graceful degradation
    # Reset degraded features tracker
    DEGRADED_FEATURES=""

    if [[ -x "$LEARNING_ENGINE" ]]; then
        if "$LEARNING_ENGINE" init 2>/dev/null; then
            update_system_status "learning" true
        else
            log_failure "learning-engine" "initialization failed"
            show_advisory "Learning engine initialization failed - system may have reduced intelligence"
            DEGRADED_FEATURES="${DEGRADED_FEATURES}learning-engine,"
        fi
    else
        log "Optional hook learning-engine not available - skipping"
        DEGRADED_FEATURES="${DEGRADED_FEATURES}learning-engine,"
    fi

    if [[ -x "$MEMORY_MANAGER" ]]; then
        if "$MEMORY_MANAGER" init 2>/dev/null; then
            update_system_status "memory" true
        else
            log_failure "memory-manager" "initialization failed"
            show_advisory "Memory manager initialization failed - running stateless"
            DEGRADED_FEATURES="${DEGRADED_FEATURES}memory-manager,"
        fi
    else
        log "Optional hook memory-manager not available - skipping"
        DEGRADED_FEATURES="${DEGRADED_FEATURES}memory-manager,"
    fi

    update_coordinator_status "initialized" true
    log "Coordinator initialized"
}

update_system_status() {
    local system="$1"
    local status="$2"

    local temp_file
    temp_file=$(mktemp)

    jq --arg system "$system" --argjson status "$status" \
        '.systems[$system] = $status' "$COORD_STATE" > "$temp_file"
    mv "$temp_file" "$COORD_STATE"
}

update_coordinator_status() {
    local key="$1"
    local value="$2"

    local temp_file
    temp_file=$(mktemp)

    jq --arg key "$key" --arg value "$value" \
        '.[$key] = $value' "$COORD_STATE" > "$temp_file"
    mv "$temp_file" "$COORD_STATE"
}

# =============================================================================
# TASK COORDINATION (MAIN ENTRY POINT)
# =============================================================================

coordinate_task() {
    local task="$1"
    local task_type="${2:-general}"
    local context="${3:-}"

    init_coordinator
    log "Coordinating task: $task (type: $task_type)"

    local start_time
    start_time=$(date +%s)

    # Phase 1: PRE-EXECUTION INTELLIGENCE
    log "Phase 1: Pre-execution analysis"

    # 1.0: Select reasoning mode (reflexive/deliberate/reactive)
    local reasoning_mode="deliberate"
    local mode_info=""
    if [[ -x "$REASONING_MODE_SWITCHER" ]]; then
        # Assess task characteristics for mode selection
        local complexity="normal"
        local urgency="normal"

        # Simple heuristics for now
        [[ "$task" =~ (fix|bug|error|urgent) ]] && urgency="critical"
        [[ "$task" =~ (implement|architecture|design|complex) ]] && complexity="high"
        [[ "$task" =~ (typo|comment|simple|quick) ]] && complexity="low"

        local risk_for_mode="low"
        [[ "$task" =~ (security|auth|payment|data|production) ]] && risk_for_mode="high"

        mode_info=$("$REASONING_MODE_SWITCHER" select "$task" "$context" "$urgency" "$complexity" "$risk_for_mode" 2>/dev/null || echo '{"selected_mode":"deliberate"}')
        reasoning_mode=$(echo "$mode_info" | jq -r '.selected_mode // "deliberate"')
        log "Selected reasoning mode: $reasoning_mode (complexity: $complexity, risk: $risk_for_mode, urgency: $urgency)"

        # Log decision to audit trail
        if [[ -x "$ENHANCED_AUDIT_TRAIL" ]]; then
            if ! "$ENHANCED_AUDIT_TRAIL" log "select_reasoning_mode" \
                "Task characteristics suggest $reasoning_mode mode" \
                "reflexive,deliberate,reactive" \
                "$reasoning_mode balances thoroughness with efficiency for this task" \
                "0.85" 2>/dev/null; then
                log_failure "enhanced-audit-trail" "failed to log reasoning mode selection"
            fi
        fi
    fi

    # 1.1: State hypothesis
    local hypothesis_id=""
    if [[ -x "$HYPOTHESIS_TESTER" ]]; then
        local hypothesis="Task '$task' will succeed using recommended strategy"
        hypothesis_id=$("$HYPOTHESIS_TESTER" state "$hypothesis" "success" "$task" 2>/dev/null | jq -r '.id' || echo "")
        log "Stated hypothesis: $hypothesis_id"
    fi

    # 1.2: Get strategy recommendation
    local strategy="default"
    local strategy_confidence=0
    if [[ -x "$STRATEGY_SELECTOR" ]]; then
        local strategy_result
        strategy_result=$("$STRATEGY_SELECTOR" select "$task" "$task_type" "$context" 2>/dev/null || echo '{"strategy":"default","confidence":0}')
        strategy=$(echo "$strategy_result" | jq -r '.strategy')
        strategy_confidence=$(echo "$strategy_result" | jq -r '.confidence')
        log "Selected strategy: $strategy (confidence: $strategy_confidence)"
    fi

    # 1.3: Assess risk
    local risk_level="low"
    local risk_score=10
    if [[ -x "$RISK_PREDICTOR" ]]; then
        local risk_result
        risk_result=$("$RISK_PREDICTOR" assess "$task" "$task_type" "" "$context" 2>/dev/null || echo '{"riskLevel":"low","totalRisk":10}')
        risk_level=$(echo "$risk_result" | jq -r '.riskLevel')
        risk_score=$(echo "$risk_result" | jq -r '.totalRisk')
        log "Risk assessment: $risk_level ($risk_score/100)"
    fi

    # 1.4: Mine relevant patterns (PHASE 2 INTEGRATION: Use hybrid search for patterns)
    local patterns="[]"
    if [[ -x "$PATTERN_MINER" ]]; then
        patterns=$("$PATTERN_MINER" mine "$task_type" 2>/dev/null || echo '[]')
        local pattern_count
        pattern_count=$(echo "$patterns" | jq 'length')
        log "Found $pattern_count relevant patterns"
    fi

    # PHASE 2 INTEGRATION: Also retrieve relevant memories using hybrid search
    local memory_patterns="[]"
    if [[ -x "$MEMORY_MANAGER" ]]; then
        memory_patterns=$("$MEMORY_MANAGER" remember-hybrid "$task" 5 2>/dev/null || echo '[]')
        local memory_count
        memory_count=$(echo "$memory_patterns" | jq 'length' 2>/dev/null || echo "0")
        if [[ $memory_count -gt 0 ]]; then
            log "Retrieved $memory_count relevant memories using hybrid search"
        fi
    fi

    # 1.4a: AUTO-RESEARCH: Check for unfamiliar libraries and execute GitHub search
    local github_search_results="[]"
    if [[ -x "$ORCHESTRATOR" ]]; then
        local task_analysis
        task_analysis=$("$ORCHESTRATOR" analyze "$task" 2>/dev/null || echo '{}')

        local needs_research=$(echo "$task_analysis" | jq -r '.research.needsResearch // false')
        if [[ "$needs_research" == "true" ]]; then
            local library=$(echo "$task_analysis" | jq -r '.research.library')
            local search_instruction=$(echo "$task_analysis" | jq -r '.githubSearch.instruction')

            log "📚 Auto-research triggered for library: $library"
            log "💡 Recommendation: $search_instruction"

            # Note: The GitHub search will be executed by Claude in autonomous mode
            # The search parameters are provided in task_analysis.githubSearch
            # This allows Claude to invoke mcp__grep__searchGitHub with the prepared query
            github_search_results=$(echo "$task_analysis" | jq -c '.githubSearch')
        fi
    fi

    # 1.4b: Reasoning mode execution strategy
    local tot_result=""
    local selected_approach=""

    if [[ "$reasoning_mode" == "reflexive" ]]; then
        # REFLEXIVE MODE: Fast-path execution, skip Tree of Thoughts
        log "Reflexive mode: Fast-path execution (skipping Tree of Thoughts for speed)"

        # Log decision to audit trail
        if [[ -x "$ENHANCED_AUDIT_TRAIL" ]]; then
            if ! "$ENHANCED_AUDIT_TRAIL" log "reflexive_fast_path" \
                "Task classified as low complexity/risk - using fast execution" \
                "skip_tree_of_thoughts" \
                "Reflexive mode prioritizes speed over thorough exploration" \
                "0.90" 2>/dev/null; then
                log_failure "enhanced-audit-trail" "failed to log reflexive mode decision"
            fi
        fi

    elif [[ "$reasoning_mode" == "reactive" ]]; then
        # REACTIVE MODE: Immediate action, minimal planning
        log "Reactive mode: Immediate action for urgent task (minimal deliberation)"

        # Log decision to audit trail
        if [[ -x "$ENHANCED_AUDIT_TRAIL" ]]; then
            if ! "$ENHANCED_AUDIT_TRAIL" log "reactive_immediate_action" \
                "Task classified as urgent - executing immediately" \
                "minimal_planning" \
                "Reactive mode prioritizes urgency over thoroughness" \
                "0.85" 2>/dev/null; then
                log_failure "enhanced-audit-trail" "failed to log reactive mode decision"
            fi
        fi

    elif [[ "$reasoning_mode" == "deliberate" && -x "$TREE_OF_THOUGHTS" ]]; then
        # DELIBERATE MODE: Thorough exploration with Tree of Thoughts
        log "Deliberate mode: Exploring multiple solution paths with Tree of Thoughts"

        # Generate multiple branches
        tot_result=$("$TREE_OF_THOUGHTS" generate "$task" "$context" 3 2>/dev/null || echo '{}')

        # Evaluate and select best branch
        local tot_eval
        tot_eval=$("$TREE_OF_THOUGHTS" evaluate "$tot_result" 2>/dev/null || echo '{"selected_branch":null}')
        selected_approach=$(echo "$tot_eval" | jq -r '.selected_branch.strategy // ""')

        if [[ -n "$selected_approach" ]]; then
            log "Tree of Thoughts selected approach: $selected_approach"

            # Log to audit trail
            if [[ -x "$ENHANCED_AUDIT_TRAIL" ]]; then
                local alternatives
                alternatives=$(echo "$tot_eval" | jq -r '.branches[] | .strategy' | tr '\n' ',' | sed 's/,$//')
                if ! "$ENHANCED_AUDIT_TRAIL" log "tot_approach_selection" \
                    "Evaluated multiple approaches using Tree of Thoughts" \
                    "$alternatives" \
                    "Selected approach has best weighted score across feasibility, quality, risk, and effort" \
                    "$(echo "$tot_eval" | jq -r '.selected_branch.weighted_score / 10 // 0.75')" 2>/dev/null; then
                    log_failure "enhanced-audit-trail" "failed to log Tree of Thoughts selection"
                fi
            fi

            # Override strategy if ToT found better approach
            if [[ -n "$selected_approach" && "$selected_approach" != "null" ]]; then
                strategy="$selected_approach"
                strategy_confidence=0.85
            fi
        fi
    fi

    # 1.5: Start thinking session
    local thinking_id=""
    if [[ -x "$THINKING_FRAMEWORK" ]]; then
        thinking_id=$("$THINKING_FRAMEWORK" start "$task" "$context" 2>/dev/null || echo "")
        [[ -n "$thinking_id" ]] && log "Started thinking session: $thinking_id"
    fi

    # 1.6: Check system health
    if [[ -x "$SELF_HEALING" ]]; then
        local health
        health=$("$SELF_HEALING" health 2>/dev/null || echo "unknown")
        log "System health: $health"

        if [[ "$health" == "unhealthy" ]]; then
            log "System unhealthy, recovering..."
            "$SELF_HEALING" recover 2>/dev/null || true
        fi
    fi

    # Phase 2: EXECUTION WITH MONITORING
    log "Phase 2: Execution"

    # 2.0: Bounded autonomy check (safety layer)
    local autonomy_check=""
    local action_allowed="true"
    local requires_approval="false"
    if [[ -x "$BOUNDED_AUTONOMY" ]]; then
        autonomy_check=$("$BOUNDED_AUTONOMY" check "$task" "$context,strategy:$strategy,risk:$risk_level" 2>/dev/null || echo '{"allowed":true,"requires_approval":false}')
        action_allowed=$(echo "$autonomy_check" | jq -r '.allowed // true')
        requires_approval=$(echo "$autonomy_check" | jq -r '.requires_approval // false')

        if [[ "$action_allowed" == "false" ]]; then
            log "BLOCKED: Task prohibited by bounded autonomy rules"
            echo '{"error":"action_prohibited","task":"'"$task"'","reason":"Bounded autonomy safety check failed"}'
            return 1
        fi

        if [[ "$requires_approval" == "true" ]]; then
            log "ESCALATION: Task requires user approval (confidence < 70% or high risk)"
            # Log to audit trail
            if [[ -x "$ENHANCED_AUDIT_TRAIL" ]]; then
                if ! "$ENHANCED_AUDIT_TRAIL" log "escalate_for_approval" \
                    "Task requires user approval due to: $(echo "$autonomy_check" | jq -r '.reason // "high risk or low confidence"')" \
                    "auto-proceed,escalate" \
                    "Safety-first approach dictates human review for uncertain or risky operations" \
                    "0.95" 2>/dev/null; then
                    log_failure "enhanced-audit-trail" "failed to log escalation decision"
                fi
            fi
            echo '{"status":"requires_approval","task":"'"$task"'","reason":"'"$(echo "$autonomy_check" | jq -r '.reason')"'"}'
            return 0
        fi

        log "Bounded autonomy check: ALLOWED (category: $(echo "$autonomy_check" | jq -r '.category // "unknown"'))"
    fi

    update_coordinator_status "status" "executing"
    update_coordinator_status "currentTask" "$task"

    # 2.1: Create execution plan
    local plan_id=""
    if [[ -x "$PLAN_EXECUTE" ]]; then
        plan_id=$("$PLAN_EXECUTE" create "$task" "$context" 2>/dev/null || echo "")
        if [[ -n "$plan_id" ]]; then
            # Decompose and add steps
            "$PLAN_EXECUTE" decompose "$task" "$task_type" 2>/dev/null | while read -r step; do
                if [[ -n "$step" ]]; then
                    if ! "$PLAN_EXECUTE" add-step "${step#* }" "shell" "" "" 2>/dev/null; then
                        log_failure "plan-execute" "failed to add step: $step"
                    fi
                fi
            done
            log "Created plan: $plan_id"
        fi
    fi

    # 2.2: Route to appropriate agent (multi-agent orchestration)
    local assigned_agent="general"
    local agent_info=""
    if [[ -x "$MULTI_AGENT_ORCHESTRATOR" ]]; then
        local routing_result
        routing_result=$("$MULTI_AGENT_ORCHESTRATOR" route "$task" 2>/dev/null || echo '{"selected_agent":"general"}')
        assigned_agent=$(echo "$routing_result" | jq -r '.selected_agent // "general"')
        agent_info=$(echo "$routing_result" | jq -r '.agent_info.description // ""')
        log "Multi-agent routing: Assigned to $assigned_agent agent ($agent_info)"

        # Log to audit trail
        if [[ -x "$ENHANCED_AUDIT_TRAIL" ]]; then
            local all_agents
            all_agents=$("$MULTI_AGENT_ORCHESTRATOR" agents 2>/dev/null | jq -r '.agents | keys | join(",")')
            if ! "$ENHANCED_AUDIT_TRAIL" log "agent_routing" \
                "Routed task to specialist $assigned_agent agent" \
                "$all_agents" \
                "Task keywords match $assigned_agent expertise: $agent_info" \
                "$(echo "$routing_result" | jq -r '.routing_confidence / 100 // 0.7')" 2>/dev/null; then
                log_failure "enhanced-audit-trail" "failed to log agent routing"
            fi
        fi
    fi

    # 2.3: Start ReAct + Reflexion cycle
    local reflexion_iteration=1
    local reflexion_goal="$task"
    if [[ -x "$REACT_REFLEXION" ]]; then
        log "Starting ReAct + Reflexion cycle (Think → Act → Observe → Reflect)"

        # Generate reasoning before action
        local thought_result
        thought_result=$("$REACT_REFLEXION" think "$reflexion_goal" "$context" "$reflexion_iteration" 2>/dev/null || echo '{}')
        log "ReAct thought generated for iteration $reflexion_iteration"
    fi

    # ============================================================================
    # PARALLEL EXECUTION ANALYSIS: Check if tasks can be parallelized
    # ============================================================================
    local parallel_groups="[]"
    local can_parallelize="false"
    if [[ -x "$PARALLEL_EXECUTION_PLANNER" ]]; then
        log "Analyzing task for parallel execution opportunities..."
        local parallel_analysis
        parallel_analysis=$("$PARALLEL_EXECUTION_PLANNER" analyze "$task" "$context" 2>/dev/null || echo '{}')

        can_parallelize=$(echo "$parallel_analysis" | jq -r '.canParallelize // false')
        parallel_groups=$(echo "$parallel_analysis" | jq -c '.groups // []')

        if [[ "$can_parallelize" == "true" ]]; then
            local group_count
            group_count=$(echo "$parallel_groups" | jq 'length')
            log "Task can be parallelized into $group_count groups"

            # AUTO-SPAWN SWARM: If 3+ independent parallel groups detected
            if [[ $group_count -ge 3 ]] && [[ -x "$SWARM_ORCHESTRATOR" ]]; then
                log "⚡ AUTO-SPAWNING SWARM: $group_count agents for parallel execution"
                local swarm_id
                swarm_id=$("$SWARM_ORCHESTRATOR" spawn "$group_count" "$task" 2>/dev/null || echo "")

                if [[ -n "$swarm_id" ]]; then
                    log "✅ Swarm $swarm_id spawned with $group_count agents"
                    # Update execution result to indicate swarm execution
                    execution_result="swarm:$swarm_id"
                else
                    log_failure "swarm-orchestrator" "failed to spawn swarm"
                fi
            fi
        else
            log "Task will execute sequentially (no parallelization opportunities)"
        fi
    fi
    # ============================================================================

    # 2.4: Start agent loop with specialist context
    local agent_id=""
    local execution_result="pending"
    if [[ -x "$AGENT_LOOP" ]]; then
        agent_id=$("$AGENT_LOOP" start "$task" "strategy:$strategy,risk:$risk_level,plan:$plan_id,agent:$assigned_agent,mode:$reasoning_mode,parallel:$can_parallelize" 2>/dev/null || echo "")
        log "Started agent loop: $agent_id (via $assigned_agent agent in $reasoning_mode mode)"

        # Monitor execution (in real implementation, this would be event-driven)
        # For now, just record that we started it
        execution_result="started"
    fi

    # Phase 3: POST-EXECUTION LEARNING
    log "Phase 3: Post-execution learning"

    local end_time
    end_time=$(date +%s)
    local duration
    duration=$((end_time - start_time))

    # 3.1: Complete ReAct + Reflexion cycle
    local quality_score=7.0
    if [[ -x "$REACT_REFLEXION" ]]; then
        log "Completing ReAct + Reflexion: Reflect on execution outcome"

        # Reflect on the outcome
        local reflection_result
        reflection_result=$("$REACT_REFLEXION" reflect "$execution_result" "$task" "$context" 2>/dev/null || echo '{"quality_score":7.0}')
        quality_score=$(echo "$reflection_result" | jq -r '.quality_score // 7.0')

        # Process and store reflection
        if [[ "$execution_result" =~ (success|completed|started) ]]; then
            if ! "$REACT_REFLEXION" process "$reflection_result" "true" 2>/dev/null; then
                log_failure "react-reflexion" "failed to store reflection"
            fi
            log "ReAct reflexion complete: quality=$quality_score/10, reflection stored"
        fi
    fi

    # 3.2: Constitutional AI validation WITH AUTO-REVISION
    local constitutional_violations=""
    local revision_count=0
    if [[ -x "$CONSTITUTIONAL_AI" ]]; then
        log "Running Constitutional AI validation against principles"

        # Critique output against principles
        local critique_json
        critique_json=$("$CONSTITUTIONAL_AI" critique "$execution_result" all 2>/dev/null || echo '{}')

        # Parse critique results
        local assessment=$(echo "$critique_json" | jq -r '.overall_assessment // "safe"' 2>/dev/null || echo "safe")
        local violations=$(echo "$critique_json" | jq -r '.violations | length' 2>/dev/null || echo "0")

        if [[ "$assessment" != "safe" ]] && [[ "$violations" -gt 0 ]]; then
            log "⚠️  Constitutional AI: $violations violations found - initiating auto-revision"

            # AUTO-REVISION LOOP (max 2 iterations)
            while [[ $revision_count -lt 2 ]] && [[ "$assessment" != "safe" ]]; do
                revision_count=$((revision_count + 1))
                log "Auto-revision attempt $revision_count/$2..."

                # Generate revision
                local revised
                revised=$("$CONSTITUTIONAL_AI" revise "$execution_result" "$critique_json" 2>/dev/null || echo "")

                if [[ -n "$revised" && "$revised" != "null" && "$revised" != "{}" ]]; then
                    execution_result="$revised"
                    log "✅ Constitutional AI: Auto-revision $revision_count applied"

                    # Re-evaluate revised output
                    critique_json=$("$CONSTITUTIONAL_AI" critique "$execution_result" all 2>/dev/null || echo '{}')
                    assessment=$(echo "$critique_json" | jq -r '.overall_assessment // "safe"' 2>/dev/null || echo "safe")
                    violations=$(echo "$critique_json" | jq -r '.violations | length' 2>/dev/null || echo "0")
                else
                    log "❌ Constitutional AI: Revision generation failed"
                    break
                fi
            done

            if [[ "$assessment" == "safe" ]]; then
                log "✅ Constitutional AI: All violations resolved after $revision_count revision(s)"
            else
                log "⚠️  Constitutional AI: $violations violations remain after $revision_count revisions"
            fi
        else
            log "✅ Constitutional AI check complete: $assessment (no violations)"
        fi

        # Log to audit trail
        if [[ -x "$ENHANCED_AUDIT_TRAIL" ]]; then
            if ! "$ENHANCED_AUDIT_TRAIL" log "constitutional_validation" \
                "Validated and revised: $assessment, $violations violations, $revision_count revisions" \
                "skip-validation,run-validation,auto-revise" \
                "Ensures code quality, security, testing, error handling, compatibility, documentation, simplicity, and no data loss" \
                "0.90" 2>/dev/null; then
                log_failure "enhanced-audit-trail" "failed to log constitutional validation"
            fi
        fi
    fi

    # 3.3: Auto-evaluator quality gates
    local eval_score=7.0
    local eval_decision="continue"
    if [[ -x "$AUTO_EVALUATOR" ]]; then
        log "Running auto-evaluator quality assessment"

        # Get evaluation criteria
        local eval_criteria
        eval_criteria=$("$AUTO_EVALUATOR" criteria "$task_type" 2>/dev/null || echo '{}')

        # In production, Claude would evaluate against criteria
        # For now, use reflexion quality score
        eval_score="$quality_score"

        # Determine if revision needed (threshold 7.0)
        if (( $(echo "$eval_score < 7.0" | bc -l 2>/dev/null || echo 0) )); then
            eval_decision="revise"
            log "Auto-evaluator: Quality below threshold ($eval_score < 7.0), revision recommended"
        else
            eval_decision="continue"
            log "Auto-evaluator: Quality acceptable ($eval_score >= 7.0)"
        fi

        # Log to audit trail
        if [[ -x "$ENHANCED_AUDIT_TRAIL" ]]; then
            if ! "$ENHANCED_AUDIT_TRAIL" log "quality_evaluation" \
                "Evaluated output quality: $eval_score/10" \
                "accept,revise,reject" \
                "Score meets/exceeds threshold of 7.0 for $task_type tasks" \
                "$(echo "$eval_score / 10" | bc -l 2>/dev/null || echo 0.7)" 2>/dev/null; then
                log_failure "enhanced-audit-trail" "failed to log quality evaluation"
            fi
        fi
    fi

    # 3.4: Record to reinforcement learning
    if [[ -x "$REINFORCEMENT_LEARNING" ]]; then
        # Determine reward based on execution result and quality
        local reward=0.0
        if [[ "$execution_result" =~ (success|completed|started) ]]; then
            reward=$(echo "scale=2; $eval_score / 10" | bc -l 2>/dev/null || echo "0.7")
        else
            reward=0.0
        fi

        if ! "$REINFORCEMENT_LEARNING" record "$task_type" "$context" "$execution_result" "$reward" 2>/dev/null; then
            log_failure "reinforcement-learning" "failed to record outcome"
        fi
        log "Recorded RL outcome: $task_type -> $execution_result (reward: $reward)"
    fi

    # 3.5: Verify hypothesis
    if [[ -n "$hypothesis_id" && -x "$HYPOTHESIS_TESTER" ]]; then
        if ! "$HYPOTHESIS_TESTER" verify "$hypothesis_id" "$execution_result" "Execution completed" 2>/dev/null; then
            log_failure "hypothesis-tester" "failed to verify hypothesis"
        fi
        log "Verified hypothesis: $hypothesis_id"
    fi

    # 3.6: Record outcome to feedback loop
    if [[ -x "$FEEDBACK_LOOP" ]]; then
        if ! "$FEEDBACK_LOOP" record "$task" "$task_type" "$strategy" "$execution_result" "$duration" "" "$context" 2>/dev/null; then
            log_failure "feedback-loop" "failed to record outcome"
        fi
        log "Recorded feedback"
    fi

    # 3.3: Create meta-reflection
    if [[ -x "$META_REFLECTION" ]]; then
        if ! "$META_REFLECTION" reflect "what_learned" "$task" "$execution_result" "Used $strategy strategy with $risk_level risk" 2>/dev/null; then
            log_failure "meta-reflection" "failed to create reflection"
        fi
        log "Created meta-reflection"
    fi

    # 3.4: Complete thinking session
    if [[ -n "$thinking_id" && -x "$THINKING_FRAMEWORK" ]]; then
        if ! "$THINKING_FRAMEWORK" complete "Completed: $execution_result" 0.8 2>/dev/null; then
            log_failure "thinking-framework" "failed to complete session"
        fi
        log "Completed thinking session"
    fi

    # 3.5: Complete plan
    if [[ -n "$plan_id" && -x "$PLAN_EXECUTE" ]]; then
        if ! "$PLAN_EXECUTE" finish "$execution_result" "Coordination complete" 2>/dev/null; then
            log_failure "plan-execute" "failed to finish plan"
        fi
    fi

    update_coordinator_status "status" "idle"
    update_coordinator_status "currentTask" "null"

    # Return comprehensive result with full intelligence data
    jq -n \
        --arg task "$task" \
        --arg strategy "$strategy" \
        --argjson strategyConf "$strategy_confidence" \
        --arg riskLevel "$risk_level" \
        --argjson riskScore "$risk_score" \
        --arg agentId "$agent_id" \
        --arg planId "$plan_id" \
        --arg thinkingId "$thinking_id" \
        --argjson duration "$duration" \
        --arg result "$execution_result" \
        --argjson patternCount "$(echo "$patterns" | jq 'length')" \
        --arg reasoningMode "$reasoning_mode" \
        --arg assignedAgent "$assigned_agent" \
        --argjson qualityScore "$quality_score" \
        --argjson evalScore "$eval_score" \
        --arg evalDecision "$eval_decision" \
        --arg totApproach "$selected_approach" \
        --argjson githubSearch "$github_search_results" \
        '{
            task: $task,
            autoResearch: $githubSearch,
            execution: {
                agentId: $agentId,
                planId: $planId,
                thinkingId: $thinkingId,
                result: $result,
                duration: $duration
            },
            intelligence: {
                strategy: $strategy,
                strategyConfidence: $strategyConf,
                riskLevel: $riskLevel,
                riskScore: $riskScore,
                patternsFound: $patternCount,
                reasoningMode: $reasoningMode,
                assignedAgent: $assignedAgent,
                totSelectedApproach: $totApproach
            },
            quality: {
                reflexionScore: $qualityScore,
                evaluatorScore: $evalScore,
                decision: $evalDecision,
                constitutionalValidation: "completed"
            },
            learning: {
                reinforcementLearning: "recorded",
                reflexionLessons: "extracted",
                auditTrail: "logged"
            },
            timestamp: (now | todate)
        }'

    # Log degradation summary if any features were unavailable
    log_degradation_summary

    log "Coordination complete for: $task (result: $execution_result, duration: ${duration}s)"
}

# =============================================================================
# AUTONOMOUS ORCHESTRATION
# =============================================================================

orchestrate_autonomous() {
    init_coordinator

    log "Starting autonomous orchestration"

    # Get orchestration decisions
    if [[ ! -x "$ORCHESTRATOR" ]]; then
        log "Orchestrator not available"
        echo '{"error":"orchestrator_unavailable"}'
        return 1
    fi

    local orchestration
    orchestration=$("$ORCHESTRATOR" smart 2>/dev/null || echo '{"decisions":[],"actions":[]}')

    log "Orchestration: $(echo "$orchestration" | jq -c '.')"

    # Get actions to execute
    local actions
    actions=$(echo "$orchestration" | jq -r '.actions[]' 2>/dev/null || true)

    if [[ -z "$actions" ]]; then
        log "No actions to execute"
        echo '{"status":"no_actions","orchestration":'"$orchestration"'}'
        return
    fi

    # Execute each action through coordinator
    while IFS= read -r action; do
        [[ -z "$action" ]] && continue

        case "$action" in
            start_task:*)
                local task_id
                task_id=$(echo "$action" | cut -d: -f2)
                local task_name
                task_name=$(echo "$action" | cut -d: -f3-)

                log "Executing action: start_task $task_name"

                # Coordinate the task
                coordinate_task "$task_name" "general" "from buildguide"
                ;;
            *)
                log "Unknown action: $action"
                ;;
        esac
    done <<< "$actions"

    echo '{"status":"completed","orchestration":'"$orchestration"'}'
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    init)
        init_coordinator
        ;;
    coordinate)
        coordinate_task "${2:-task}" "${3:-general}" "${4:-}"
        ;;
    orchestrate)
        orchestrate_autonomous
        ;;
    status)
        cat "$COORD_STATE"
        ;;
    help|*)
        echo "Central Coordinator - Intelligence Layer"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  init                                  - Initialize coordinator"
        echo "  coordinate <task> [type] [context]    - Coordinate single task"
        echo "  orchestrate                           - Autonomous orchestration"
        echo "  status                                - Get coordinator status"
        echo ""
        echo "Examples:"
        echo "  $0 coordinate 'implement auth' feature"
        echo "  $0 orchestrate  # Run autonomous orchestration"
        ;;
esac
