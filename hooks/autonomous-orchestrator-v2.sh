#!/bin/bash
# Autonomous Orchestrator V2 - Smart orchestration with learning and auto-execution
# Integrates: learning-engine, task-queue, agent-loop, plan-execute, reflexion-agent

set -e

CLAUDE_DIR="${HOME}/.claude"
MEMORY_MANAGER="${CLAUDE_DIR}/hooks/memory-manager.sh"
LEARNING_ENGINE="${CLAUDE_DIR}/hooks/learning-engine.sh"
TASK_QUEUE="${CLAUDE_DIR}/hooks/task-queue.sh"
COORDINATOR="${CLAUDE_DIR}/hooks/coordinator.sh"
AGENT_LOOP="${CLAUDE_DIR}/hooks/agent-loop.sh"
PLAN_EXECUTE="${CLAUDE_DIR}/hooks/plan-execute.sh"
SELF_HEALING="${CLAUDE_DIR}/hooks/self-healing.sh"
RE_TOOL_DETECTOR="${CLAUDE_DIR}/hooks/re-tool-detector.sh"
PROJECT_DIR="${PWD}"
LOG_FILE="${CLAUDE_DIR}/orchestrator.log"

# Feature flag: Enable ReflexionAgent integration (default: off)
# Set ENABLE_REFLEXION_AGENT=1 to use ReflexionAgent for complex tasks
ENABLE_REFLEXION_AGENT="${ENABLE_REFLEXION_AGENT:-0}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Log feature flag status at initialization
if [[ "$ENABLE_REFLEXION_AGENT" == "1" ]]; then
    log "ReflexionAgent integration: ENABLED"
else
    log "ReflexionAgent integration: DISABLED (set ENABLE_REFLEXION_AGENT=1 to enable)"
fi

# =============================================================================
# STATE DETECTION (same as v1)
# =============================================================================

check_buildguide() {
    if [[ -f "${PROJECT_DIR}/buildguide.md" ]]; then
        if grep -q '^\s*- \[ \]' "${PROJECT_DIR}/buildguide.md" 2>/dev/null; then
            echo "buildguide_found"
            return 0
        fi
    fi
    echo "no_buildguide"
    return 1
}

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

check_continuation() {
    local cont_file="${PROJECT_DIR}/.claude/continuation-prompt.md"
    if [[ -f "$cont_file" ]]; then
        echo "continuation_found"
        return 0
    fi

    if [[ -f "${CLAUDE_DIR}/continuation-prompt.md" ]]; then
        echo "global_continuation_found"
        return 0
    fi

    echo "no_continuation"
    return 1
}

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
# SMART TASK ANALYSIS (NEW)
# =============================================================================

# Extract tasks from buildguide and populate task queue
populate_task_queue() {
    if [[ ! -f "${PROJECT_DIR}/buildguide.md" ]]; then
        return
    fi

    if [[ ! -x "$TASK_QUEUE" ]]; then
        return
    fi

    # Extract unchecked sections
    local tasks
    tasks=$(grep '^\s*- \[ \]' "${PROJECT_DIR}/buildguide.md" | sed 's/- \[ \] //' || true)

    if [[ -z "$tasks" ]]; then
        return
    fi

    # Add each task to queue with priority
    local priority=2
    while IFS= read -r task; do
        # Check if task already in queue
        local existing
        existing=$("$TASK_QUEUE" list pending 2>/dev/null | jq -r --arg name "$task" '.[] | select(.name == $name) | .id' 2>/dev/null || echo "")

        if [[ -z "$existing" ]]; then
            "$TASK_QUEUE" add "$task" "$priority" "from buildguide.md" "" 2>/dev/null || true
            log "Added task to queue: $task"
        fi

        # Increment priority (lower number = higher priority)
        priority=$((priority + 1))
        [[ $priority -gt 5 ]] && priority=5
    done <<< "$tasks"
}

# Analyze task and get recommended strategy
# =============================================================================
# AUTO-RESEARCH: Detect unfamiliar libraries and recommend GitHub search
# =============================================================================

detect_unfamiliar_library() {
    local task="$1"

    # Common library/framework/API keywords that suggest research needed
    # Pattern: (action).*(library) where action = implement|integrate|use|add|create|build|setup
    local unfamiliar_patterns=(
        "(implement|integrate|use|add|create|build|setup).*(stripe|payment)"
        "(implement|integrate|use|add|create|build|setup).*(oauth|auth|authentication)"
        "(implement|integrate|use|add|create|build|setup).*(firebase)"
        "(implement|integrate|use|add|create|build|setup).*(graphql)"
        "(implement|integrate|use|add|create|build|setup).*(websocket|ws)"
        "(implement|integrate|use|add|create|build|setup).*(redis)"
        "(implement|integrate|use|add|create|build|setup).*(jwt|token)"
        "(implement|integrate|use|add|create|build|setup).*(postgres|postgresql)"
        "(implement|integrate|use|add|create|build|setup).*(mongodb|mongo)"
        "(implement|integrate|use|add|create|build|setup).*(grpc)"
        "(implement|integrate|use|add|create|build|setup).*(kafka)"
        "(implement|integrate|use|add|create|build|setup).*(twilio)"
        "(implement|integrate|use|add|create|build|setup).*(sendgrid)"
        "(implement|integrate|use|add|create|build|setup).*(s3|aws)"
        "(implement|integrate|use|add|create|build|setup).*(lambda)"
        # Deep Search Triggers
        "(search|find|lookup|grep).*(mcp|vercel|github|code)"
        "(debug|fix|solve).*(deep|obscure|hard|complex)"
        "(research|analyze|investigate).*(gemini|ai|articles|forums)"
    )

    for pattern in "${unfamiliar_patterns[@]}"; do
        if echo "$task" | grep -qiE "$pattern"; then
            # Extract library/tool name
            local library
            library=$(echo "$task" | grep -oiE "(stripe|payment|oauth|auth|authentication|firebase|graphql|websocket|ws|redis|jwt|token|postgres|postgresql|mongodb|mongo|grpc|kafka|twilio|sendgrid|s3|aws|lambda|grep|mcp|vercel|github|gemini|articles|forums)" | head -1)
            
            if [[ -n "$library" ]]; then
                # Normalize library names
                case "$library" in
                    auth|authentication) library="oauth" ;;
                    ws) library="websocket" ;;
                    token) library="jwt" ;;
                    postgresql) library="postgres" ;;
                    mongo) library="mongodb" ;;
                    aws) library="s3" ;;
                    grep|mcp|vercel|github|code) library="grep_mcp" ;;
                    gemini|ai|articles|forums) library="deep_research" ;;
                esac
                echo "{\"needsResearch\":true,\"library\":\"$library\",\"reason\":\"Unfamiliar library or Deep Search requested\"}"
                return 0
            fi
        fi
    done

    echo '{"needsResearch":false}'
    return 1
}

analyze_task() {
    local task="$1"

    if [[ ! -x "$LEARNING_ENGINE" ]]; then
        echo '{"strategy":"default","confidence":0,"risk":10,"needsResearch":false}'
        return
    fi

    # Determine task type
    local task_type="general"
    if echo "$task" | grep -qiE "implement|add|create|build"; then
        task_type="feature"
    elif echo "$task" | grep -qiE "fix|bug|error|issue"; then
        task_type="bugfix"
    elif echo "$task" | grep -qiE "refactor|clean|improve"; then
        task_type="refactor"
    elif echo "$task" | grep -qiE "test|spec|coverage"; then
        task_type="test"
    fi

    # Check if task involves unfamiliar libraries (auto-research recommendation)
    local research_recommendation
    research_recommendation=$(detect_unfamiliar_library "$task")

    # AUTO-DETECT RE TOOLS: Check if task requires reverse engineering tools
    local re_tool_detected="{}"
    if [[ -x "$RE_TOOL_DETECTOR" ]]; then
        log "Checking for RE tool requirements..."
        local file_context="[]"
        # Try to extract file paths from task
        if echo "$task" | grep -qoE '\S+\.(apk|exe|dll|bin|wasm|proto|crx|dmp|dump|mem|min\.js)'; then
            file_context=$(echo "$task" | grep -oE '\S+\.(apk|exe|dll|bin|wasm|proto|crx|dmp|dump|mem|min\.js)' | jq -R . | jq -s . || echo '[]')
        fi

        re_tool_detected=$("$RE_TOOL_DETECTOR" detect "$task" "" "$file_context" 2>&1 | grep -v '^$' | tail -1 || echo '{}')
        # Validate JSON
        if ! echo "$re_tool_detected" | jq empty 2>/dev/null; then
            re_tool_detected='{}'
        fi
        local detected_tool=$(echo "$re_tool_detected" | jq -r '.tool // ""' 2>/dev/null || echo "")
        if [[ -n "$detected_tool" && "$detected_tool" != "null" ]]; then
            local confidence=$(echo "$re_tool_detected" | jq -r '.confidence // 0' 2>/dev/null || echo "0")
            log "🔍 RE Tool Detected: $detected_tool (confidence: $confidence)"
        fi
    fi

    # AUTO-SEARCH: If unfamiliar library detected, automatically search GitHub
    local github_examples='{}'
    local needs_research=$(echo "$research_recommendation" | jq -r '.needsResearch // false')

    if [[ "$needs_research" == "true" ]]; then
        local library=$(echo "$research_recommendation" | jq -r '.library')
        log "Auto-searching GitHub for $library code examples..."

        # Normalize library name
        case "$library" in
            Stripe) library="stripe" ;;
            OAuth|Authentication) library="oauth" ;;
            Firebase) library="firebase" ;;
            GraphQL) library="graphql" ;;
            WebSocket|WS) library="websocket" ;;
            Redis) library="redis" ;;
            JWT) library="jwt" ;;
            PostgreSQL|Postgres) library="postgres" ;;
            MongoDB|Mongo) library="mongodb" ;;
            GRPC|gRPC) library="grpc" ;;
            Kafka) library="kafka" ;;
            Twilio) library="twilio" ;;
            SendGrid) library="sendgrid" ;;
            S3|AWS) library="s3" ;;
            Lambda) library="lambda" ;;
        esac

        # Construct search queries based on library
        local search_query=""
        case "$library" in
            stripe)
                search_query="stripe.checkout.sessions.create|stripe.paymentIntents"
                ;;
            oauth|authentication|auth)
                search_query="OAuth2|passport.authenticate|NextAuth"
                ;;
            firebase)
                search_query="firebase.initializeApp|firestore.collection"
                ;;
            graphql)
                search_query="GraphQLSchema|makeExecutableSchema"
                ;;
            websocket|ws)
                search_query="new WebSocket|ws.on.connection"
                ;;
            redis)
                search_query="redis.createClient|RedisClient.connect"
                ;;
            jwt)
                search_query="jwt.sign|jwt.verify|jsonwebtoken"
                ;;
            postgres|postgresql)
                search_query="pg.Pool|PostgreSQL.query"
                ;;
            mongodb|mongo)
                search_query="MongoClient.connect|mongoose.model"
                ;;
            grpc)
                search_query="grpc.Server|@grpc/grpc-js"
                ;;
            kafka)
                search_query="KafkaProducer|KafkaConsumer"
                ;;
            twilio)
                search_query="twilio.messages.create"
                ;;
            sendgrid)
                search_query="sendgrid.send|@sendgrid/mail"
                ;;
            s3)
                search_query="S3Client|s3.putObject"
                ;;
            lambda)
                search_query="lambda.invoke|AWS.Lambda"
                ;;
            grep_mcp)
                search_query="mcp-server-grep|vercel/mcp|grep code search mcp"
                ;;
            deep_research)
                search_query="debugging complex bugs|advanced troubleshooting patterns"
                ;;
        esac

        # Execute Search based on type
        if [[ "$library" == "grep_mcp" ]]; then
            log "🚀 Triggering Grep MCP Deep Search..."
            echo "{\"needsResearch\":true,\"strategy\":\"deep_search\",\"tool\":\"grep_mcp\",\"query\":\"$search_query\"}"
            return
        elif [[ "$library" == "deep_research" ]]; then
             log "🌐 Triggering Deep Research (Web/Forums)..."
             echo "{\"needsResearch\":true,\"strategy\":\"deep_research\",\"tool\":\"web_search\",\"query\":\"$search_query\"}"
             return
        fi
            *)
                search_query="$library implementation"
                ;;
        esac

        # Call mcp__grep__searchGitHub via Claude (this will be available in autonomous mode)
        # Note: This creates a recommendation for Claude to execute the search
        github_examples=$(jq -n \
            --arg lib "$library" \
            --arg query "$search_query" \
            '{
                action: "search_github",
                tool: "mcp__grep__searchGitHub",
                library: $lib,
                query: $query,
                parameters: {
                    query: $query,
                    useRegexp: true,
                    language: ["TypeScript", "JavaScript", "Python", "Go"]
                },
                instruction: "Search GitHub for \($lib) implementation examples using query: \($query)"
            }')

        log "GitHub search prepared for $library (query: $search_query)"
    fi

    # Get recommendation from learning engine
    local recommendation
    recommendation=$("$LEARNING_ENGINE" recommend "$task_type" "$task" 2>/dev/null || echo '{"strategy":"default","confidence":0}')

    # Get risk assessment
    local strategy
    strategy=$(echo "$recommendation" | jq -r '.strategy')
    local risk
    risk=$("$LEARNING_ENGINE" predict-risk "$task_type" "$strategy" 2>/dev/null || echo '{"riskScore":10,"riskLevel":"low"}')

    # Combine with research recommendation, GitHub search, and RE tool detection
    echo "$recommendation" | jq --argjson risk "$risk" --argjson research "$research_recommendation" --argjson github "$github_examples" --argjson re_tool "$re_tool_detected" \
        '. + {risk: $risk.riskScore, riskLevel: $risk.riskLevel, taskType: "'"$task_type"'", research: $research, githubSearch: $github, reTool: $re_tool}'
}

# =============================================================================
# AUTO-EXECUTION (NEW)
# =============================================================================

# Start agent loop for a task (via coordinator for full intelligence)
start_agent_loop() {
    local task="$1"
    local context="${2:-}"

    # Check system health first
    if [[ -x "$SELF_HEALING" ]]; then
        local health
        health=$("$SELF_HEALING" health 2>/dev/null || echo "unknown")
        if [[ "$health" == "unhealthy" ]]; then
            log "System unhealthy, attempting recovery before task"
            "$SELF_HEALING" recover 2>/dev/null || true
        fi
    fi

    # Prefer coordinator for full ReAct/Reflexion/Constitutional AI integration
    if [[ -x "$COORDINATOR" ]]; then
        log "Starting task via coordinator (full intelligence): $task"
        local result
        result=$("$COORDINATOR" coordinate_task "$task" "$context" 2>/dev/null || echo "")

        # Coordinator returns JSON with agent_id
        local agent_id
        agent_id=$(echo "$result" | jq -r '.agent_id // empty' 2>/dev/null || echo "")

        if [[ -n "$agent_id" ]]; then
            echo "$agent_id"
            return 0
        else
            log "⚠️ Coordinator failed, falling back to direct agent-loop"
        fi
    fi

    # Fallback to direct agent-loop if coordinator unavailable or failed
    if [[ -x "$AGENT_LOOP" ]]; then
        log "Starting agent loop directly (fallback): $task"
        local agent_id
        agent_id=$("$AGENT_LOOP" start "$task" "$context" 2>/dev/null)
        echo "$agent_id"
    else
        log "❌ Neither coordinator nor agent-loop available"
        return 1
    fi
}

# Create execution plan for task
create_execution_plan() {
    local task="$1"
    local task_type="${2:-general}"

    if [[ ! -x "$PLAN_EXECUTE" ]]; then
        return
    fi

    # Create plan
    local plan_id
    plan_id=$("$PLAN_EXECUTE" create "$task" "autonomous execution" 2>/dev/null)

    # Decompose task into steps
    local steps
    steps=$("$PLAN_EXECUTE" decompose "$task" "$task_type" 2>/dev/null)

    # Add steps to plan
    while IFS= read -r step; do
        if [[ -n "$step" ]]; then
            local description
            description=$(echo "$step" | sed 's/^[0-9]*\. //')
            "$PLAN_EXECUTE" add-step "$description" "shell" "" "" 2>/dev/null || true
        fi
    done <<< "$steps"

    log "Created execution plan: $plan_id for $task"
    echo "$plan_id"
}

# =============================================================================
# REFLEXION AGENT INTEGRATION (NEW)
# =============================================================================

# Decide whether to use ReflexionAgent for a task
should_use_reflexion_agent() {
    local task="$1"
    local analysis="$2"  # JSON from analyze_task()

    # Extract complexity indicators from analysis
    local task_type=$(echo "$analysis" | jq -r '.taskType // "general"' 2>/dev/null)
    local risk_score=$(echo "$analysis" | jq -r '.risk // 10' 2>/dev/null)
    local confidence=$(echo "$analysis" | jq -r '.confidence // 0' 2>/dev/null)

    # Rule 1: High-risk tasks (risk > 5) with low confidence (< 0.5)
    if command -v bc >/dev/null 2>&1; then
        if [[ $(echo "$risk_score > 5" | bc -l 2>/dev/null) -eq 1 ]] && \
           [[ $(echo "$confidence < 0.5" | bc -l 2>/dev/null) -eq 1 ]]; then
            echo '{"useReflexion":true,"reason":"high_risk_low_confidence"}'
            return 0
        fi
    fi

    # Rule 2: Complex feature implementation tasks
    if [[ "$task_type" == "feature" ]]; then
        if echo "$task" | grep -qiE "implement.*with|create.*multiple|build.*system"; then
            echo '{"useReflexion":true,"reason":"complex_feature"}'
            return 0
        fi
    fi

    # Rule 3: Multi-file tasks (detect keywords)
    if echo "$task" | grep -qiE "multiple files|across.*files|[0-9]+.*files"; then
        echo '{"useReflexion":true,"reason":"multi_file_task"}'
        return 0
    fi

    # Rule 4: Tasks with explicit iteration/refinement requirements
    if echo "$task" | grep -qiE "refine|iterate|improve.*until|self-correct"; then
        echo '{"useReflexion":true,"reason":"explicit_iteration"}'
        return 0
    fi

    # Default: Use bash agent-loop
    echo '{"useReflexion":false,"reason":"simple_task"}'
    return 1
}

# Execute task using ReflexionAgent
execute_with_reflexion_agent() {
    local goal="$1"
    local max_iterations="${2:-30}"
    local preferred_model="${3:-glm-4.7}"  # Default to GLM-4.7 (no rate limits)

    log "Executing with ReflexionAgent: $goal (max: $max_iterations, model: $preferred_model)"

    # Detect komplete-kontrol-cli project directory
    local kk_project_dir=""
    if [[ -f "${PROJECT_DIR}/src/cli/commands/ReflexionCommand.ts" ]]; then
        kk_project_dir="$PROJECT_DIR"
    elif [[ -f "${HOME}/Desktop/Projects/komplete-kontrol-cli/src/cli/commands/ReflexionCommand.ts" ]]; then
        kk_project_dir="${HOME}/Desktop/Projects/komplete-kontrol-cli"
    else
        log "❌ ReflexionCommand not found, falling back to bash agent-loop"
        return 1
    fi

    # Change to project directory for file operations
    local original_dir="$PWD"
    cd "$PROJECT_DIR" || return 1

    # Execute ReflexionCommand
    local output
    output=$(cd "$kk_project_dir" && bun run src/index.ts reflexion execute \
        --goal "$goal" \
        --max-iterations "$max_iterations" \
        --preferred-model "$preferred_model" \
        --output-json 2>&1)

    local exit_code=$?
    cd "$original_dir"

    # Check for rate limit errors
    if echo "$output" | grep -qiE "concurrency limit|rate limit|quota|429"; then
        log "⚠️  Rate limit hit, falling back to bash agent-loop"
        return 1  # Signal fallback needed
    fi

    # Parse JSON output (last line should be final metrics)
    local metrics
    metrics=$(echo "$output" | tail -1 | jq '.' 2>/dev/null)

    if [[ $exit_code -eq 0 ]] && [[ -n "$metrics" ]]; then
        log "✅ ReflexionAgent completed successfully"
        echo "$metrics" | jq -c '{
            executor: "reflexion_agent",
            status: .status,
            iterations: .iterations,
            metrics: .metrics
        }'
        return 0
    else
        log "❌ ReflexionAgent failed (exit: $exit_code)"
        return 1  # Signal fallback needed
    fi
}

# =============================================================================
# SMART ORCHESTRATION (UPGRADED)
# =============================================================================

orchestrate_smart() {
    local decisions=()
    local actions=()
    local recommendations=()

    # Initialize learning engine
    [[ -x "$LEARNING_ENGINE" ]] && "$LEARNING_ENGINE" init 2>/dev/null || true

    # Priority 1: Check for continuation prompt
    local cont_status=$(check_continuation)
    if [[ "$cont_status" == "continuation_found" || "$cont_status" == "global_continuation_found" ]]; then
        decisions+=("RESUME_CONTINUATION")
        actions+=("execute_continuation")
    fi

    # Priority 2: Check for in-progress build
    local build_status=$(check_current_build)
    if [[ "$build_status" == resume_build:* ]]; then
        local phase="${build_status#resume_build:}"
        decisions+=("RESUME_BUILD:${phase}")
        actions+=("resume_build:$phase")
    fi

    # Priority 3: Check for buildguide with unchecked items
    local guide_status=$(check_buildguide)
    if [[ "$guide_status" == "buildguide_found" ]]; then
        decisions+=("START_BUILD")

        # Populate task queue from buildguide
        populate_task_queue

        # Get next task from queue
        if [[ -x "$TASK_QUEUE" ]]; then
            local next_task_id
            next_task_id=$("$TASK_QUEUE" next 2>/dev/null || echo "")
            if [[ -n "$next_task_id" ]]; then
                local task_info
                task_info=$("$TASK_QUEUE" get "$next_task_id" 2>/dev/null)
                local task_name
                task_name=$(echo "$task_info" | jq -r '.name' 2>/dev/null || echo "")

                if [[ -n "$task_name" ]]; then
                    # Analyze task
                    local analysis
                    analysis=$(analyze_task "$task_name")
                    recommendations+=("$analysis")

                    actions+=("start_task:$next_task_id:$task_name")
                fi
            fi
        fi
    fi

    # Priority 4: Check for active task in memory
    local task_status=$(check_active_task)
    if [[ "$task_status" == active_task:* ]]; then
        local task="${task_status#active_task:}"
        decisions+=("CONTINUE_TASK:${task}")
        actions+=("continue_task:$task")
    fi

    # Output comprehensive JSON
    local decisions_json="[]"
    if [[ ${#decisions[@]} -gt 0 ]]; then
        decisions_json=$(printf '%s\n' "${decisions[@]}" | jq -R . | jq -s .)
    fi

    local actions_json="[]"
    if [[ ${#actions[@]} -gt 0 ]]; then
        actions_json=$(printf '%s\n' "${actions[@]}" | jq -R . | jq -s .)
    fi

    local recommendations_json="[]"
    if [[ ${#recommendations[@]} -gt 0 ]]; then
        recommendations_json=$(printf '%s\n' "${recommendations[@]}" | jq -s .)
    fi

    jq -n \
        --argjson decisions "$decisions_json" \
        --argjson actions "$actions_json" \
        --argjson recommendations "$recommendations_json" \
        --arg project "$PROJECT_DIR" \
        --argjson has_guide "$([ "$guide_status" == "buildguide_found" ] && echo "true" || echo "false")" \
        --argjson has_cont "$([ "$cont_status" != "no_continuation" ] && echo "true" || echo "false")" \
        --argjson has_build "$([ "$build_status" != "no_current_build" ] && echo "true" || echo "false")" \
        '{
            decisions: $decisions,
            actions: $actions,
            recommendations: $recommendations,
            project_dir: $project,
            has_buildguide: $has_guide,
            has_continuation: $has_cont,
            has_active_build: $has_build,
            version: "2.0"
        }'
}

# Execute actions autonomously
execute_actions() {
    local actions_json="$1"

    # Parse and execute each action
    echo "$actions_json" | jq -r '.actions[]' | while read -r action; do
        case "$action" in
            start_task:*)
                # Extract task ID and name
                local task_id
                task_id=$(echo "$action" | cut -d: -f2)
                local task_name
                task_name=$(echo "$action" | cut -d: -f3-)

                # Mark task as started
                [[ -x "$TASK_QUEUE" ]] && "$TASK_QUEUE" start "$task_id" 2>/dev/null || true

                # Get task analysis
                local analysis
                analysis=$(analyze_task "$task_name")
                local task_type
                task_type=$(echo "$analysis" | jq -r '.taskType')

                # ===== REFLEXION AGENT DECISION POINT =====
                local reflexion_decision
                reflexion_decision=$(should_use_reflexion_agent "$task_name" "$analysis")
                local use_reflexion
                use_reflexion=$(echo "$reflexion_decision" | jq -r '.useReflexion')
                local reflexion_reason
                reflexion_reason=$(echo "$reflexion_decision" | jq -r '.reason')

                if [[ "$use_reflexion" == "true" ]] && [[ "$ENABLE_REFLEXION_AGENT" == "1" ]]; then
                    log "Using ReflexionAgent for: $task_name (reason: $reflexion_reason)"

                    # Execute with ReflexionAgent
                    local reflexion_result
                    reflexion_result=$(execute_with_reflexion_agent "$task_name" 30 "glm-4.7")

                    if [[ $? -eq 0 ]]; then
                        # Success - mark task complete
                        [[ -x "$TASK_QUEUE" ]] && "$TASK_QUEUE" complete "$task_id" 2>/dev/null || true
                        log "Task completed via ReflexionAgent: $task_name"
                        log "Metrics: $reflexion_result"
                    else
                        # Fallback to bash agent-loop
                        log "Falling back to bash agent-loop for: $task_name"
                        local plan_id
                        plan_id=$(create_execution_plan "$task_name" "$task_type")
                        local agent_id
                        agent_id=$(start_agent_loop "$task_name" "plan:$plan_id:fallback_from_reflexion")
                        log "Executed start_task (fallback): $task_name (agent: $agent_id, plan: $plan_id)"
                    fi
                else
                    # Use traditional bash agent-loop
                    local reason_msg="simple task"
                    [[ "$use_reflexion" == "true" ]] && reason_msg="feature disabled"
                    log "Using bash agent-loop for: $task_name (reason: $reason_msg)"

                    # Create plan
                    local plan_id
                    plan_id=$(create_execution_plan "$task_name" "$task_type")

                    # Start agent loop
                    local agent_id
                    agent_id=$(start_agent_loop "$task_name" "plan:$plan_id")

                    log "Executed start_task: $task_name (agent: $agent_id, plan: $plan_id)"
                fi
                ;;

            resume_build:*)
                local phase="${action#resume_build:}"
                log "Resuming build at phase: $phase"
                # Agent loop will be started by Claude based on decision
                ;;

            continue_task:*)
                local task="${action#continue_task:}"
                log "Continuing task: $task"
                # Agent loop will be started by Claude based on decision
                ;;

            execute_continuation)
                log "Executing continuation prompt"
                # Handled by Claude
                ;;
        esac
    done
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-orchestrate}" in
    orchestrate)
        # Original simple orchestration
        decisions=()
        cont_status=$(check_continuation)
        [[ "$cont_status" != "no_continuation" ]] && decisions+=("RESUME_CONTINUATION")

        build_status=$(check_current_build)
        [[ "$build_status" == resume_build:* ]] && decisions+=("RESUME_BUILD:${build_status#resume_build:}")

        guide_status=$(check_buildguide)
        [[ "$guide_status" == "buildguide_found" ]] && decisions+=("START_BUILD")

        task_status=$(check_active_task)
        [[ "$task_status" == active_task:* ]] && decisions+=("CONTINUE_TASK:${task_status#active_task:}")

        # Simple JSON output for backward compatibility
        decisions_json="[]"
        if [[ ${#decisions[@]} -gt 0 ]]; then
            decisions_json=$(printf '%s\n' "${decisions[@]}" | jq -R . | jq -s .)
        fi

        jq -n --argjson decisions "$decisions_json" \
            --arg project "$PROJECT_DIR" \
            '{decisions: $decisions, project_dir: $project}'
        ;;

    smart)
        # New smart orchestration with learning
        orchestrate_smart
        ;;

    execute)
        # Auto-execute actions
        orchestration=$(orchestrate_smart)
        execute_actions "$orchestration"
        echo "$orchestration"
        ;;

    populate-queue)
        # Populate task queue from buildguide
        populate_task_queue
        [[ -x "$TASK_QUEUE" ]] && "$TASK_QUEUE" status
        ;;

    analyze)
        # Analyze a specific task
        analyze_task "${2:-task}"
        ;;

    help|*)
        echo "Autonomous Orchestrator V2 - Smart Orchestration"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  orchestrate           - Simple orchestration (v1 compatible)"
        echo "  smart                 - Smart orchestration with learning"
        echo "  execute               - Auto-execute orchestrated actions"
        echo "  populate-queue        - Populate task queue from buildguide"
        echo "  analyze <task>        - Analyze task and get recommendations"
        echo ""
        echo "Examples:"
        echo "  $0 smart              # Get smart orchestration with recommendations"
        echo "  $0 execute            # Orchestrate and auto-execute"
        echo "  $0 analyze 'implement auth'  # Get strategy recommendation"
        ;;
esac
