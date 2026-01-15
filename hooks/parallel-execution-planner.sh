#!/bin/bash
# Parallel Execution Planner - Analyzes tasks for parallel execution opportunities
# Returns JSON with canParallelize flag and groups of independent tasks

set -eo pipefail

LOG_FILE="${HOME}/.claude/logs/parallel-planner.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ============================================================================
# Pattern Detection - Identify parallelizable task types
# ============================================================================

detect_parallelizable_pattern() {
    local task="$1"
    local context="$2"
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # PATTERN 1: Testing/Validation (multiple independent test suites)
    if echo "$task_lower" | grep -qiE 'test|validate|check|verify|spec|unit|integration|e2e'; then
        echo "testing"
        return 0
    fi

    # PATTERN 2: Research/Analysis (multiple independent aspects)
    if echo "$task_lower" | grep -qiE 'research|analyze|investigate|explore|study|audit|review'; then
        echo "research"
        return 0
    fi

    # PATTERN 3: Code generation for multiple components
    if echo "$task_lower" | grep -qiE 'implement.*modules|create.*components|build.*features|generate.*functions'; then
        echo "multi_component"
        return 0
    fi

    # PATTERN 4: Documentation (multiple docs)
    if echo "$task_lower" | grep -qiE 'document|write.*docs|create.*documentation'; then
        echo "documentation"
        return 0
    fi

    # PATTERN 5: Data processing (batch operations)
    if echo "$task_lower" | grep -qiE 'process.*files|convert.*data|batch.*process|transform.*all'; then
        echo "batch_processing"
        return 0
    fi

    # PATTERN 6: Multiple distinct tasks (comma or 'and' separated)
    if echo "$task_lower" | grep -qiE '\s+(and|,)\s+'; then
        echo "multi_task"
        return 0
    fi

    # Not parallelizable
    echo "none"
    return 0
}

# ============================================================================
# Dependency Analysis - Check for task dependencies
# ============================================================================

has_dependencies() {
    local task="$1"
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Keywords that suggest sequential dependency (with word boundaries)
    local dep_keywords=('\bthen\b' '\bafter\b' '\bbefore\b' 'followed by' 'depends on' '\brequires\b' '\bsequential\b' 'step 1' 'step 2' 'first\b.*\bthen\b')

    for keyword in "${dep_keywords[@]}"; do
        if echo "$task_lower" | grep -qiE "$keyword"; then
            return 0  # Has dependencies
        fi
    done

    return 1  # No dependencies
}

# ============================================================================
# Generate Groups - Create parallelizable task groups
# ============================================================================

generate_test_groups() {
    local task="$1"
    local context="$2"

    # Extract potential test types from task
    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    local groups_json='['

    # Default test types
    local test_groups=(
        "Unit tests"
        "Integration tests"
        "E2E tests"
        "Performance tests"
        "Security tests"
    )

    # Customized based on task content
    if echo "$task_lower" | grep -qiE 'api|rest|graphql'; then
        test_groups=(
            "API endpoint tests"
            "Schema validation tests"
            "Authentication tests"
            "Rate limiting tests"
        )
    elif echo "$task_lower" | grep -qiE 'ui|frontend|react|vue'; then
        test_groups=(
            "Component tests"
            "User flow tests"
            "Accessibility tests"
            "Responsiveness tests"
        )
    elif echo "$task_lower" | grep -qiE 'database|sql|mongo|postgres'; then
        test_groups=(
            "Schema tests"
            "Query tests"
            "Migration tests"
            "Performance tests"
        )
    fi

    # Generate groups
    local first=true
    for group in "${test_groups[@]}"; do
        if ! $first; then
            groups_json+=','
        fi
        groups_json+=$(jq -n \
            --arg name "$group" \
            --arg task "$task" \
            '{
                id: ($name | gsub(" "; "_") | ascii_downcase),
                name: $name,
                description: "Run '"$group"' for: " + $task,
                tasks: [$task + " - " + $name],
                dependencies: [],
                estimatedEffort: "medium",
                ioBound: true
            }')
        first=false
    done

    groups_json+=']'
    echo "$groups_json"
}

generate_research_groups() {
    local task="$1"
    local context="$2"

    local task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    local groups_json='['
    local research_groups=(
        "Codebase patterns analysis"
        "External solutions research"
        "Architecture review"
        "Dependency mapping"
        "Performance analysis"
    )

    # Customize based on task
    if echo "$task_lower" | grep -qiE 'security|auth|vulnerability'; then
        research_groups=(
            "Security patterns research"
            "Known vulnerabilities check"
            "Authentication mechanisms review"
            "Authorization flows analysis"
            "Best practices research"
        )
    elif echo "$task_lower" | grep -qiE 'performance|optimization|speed'; then
        research_groups=(
            "Performance bottlenecks analysis"
            "Caching strategies research"
            "Database optimization review"
            "Network patterns research"
        )
    fi

    local first=true
    for group in "${research_groups[@]}"; do
        if ! $first; then
            groups_json+=','
        fi
        groups_json+=$(jq -n \
            --arg name "$group" \
            --arg task "$task" \
            '{
                id: ($name | gsub(" "; "_") | gsub("[^a-z0-9_]"; "") | ascii_downcase),
                name: $name,
                description: $name + " for: " + $task,
                tasks: [$task + " - " + $name],
                dependencies: [],
                estimatedEffort: "medium",
                ioBound: true
            }')
        first=false
    done

    groups_json+=']'
    echo "$groups_json"
}

generate_multi_component_groups() {
    local task="$1"
    local context="$2"

    local groups_json='['
    local component_groups=(
        "Backend implementation"
        "Frontend implementation"
        "API layer"
        "Data models"
        "Tests"
    )

    local first=true
    for group in "${component_groups[@]}"; do
        if ! $first; then
            groups_json+=','
        fi
        groups_json+=$(jq -n \
            --arg name "$group" \
            --arg task "$task" \
            '{
                id: ($name | gsub(" "; "_") | ascii_downcase),
                name: $name,
                description: $name + " for: " + $task,
                tasks: [$task + " - " + $name],
                dependencies: [],
                estimatedEffort: "medium",
                ioBound: false
            }')
        first=false
    done

    groups_json+=']'
    echo "$groups_json"
}

generate_documentation_groups() {
    local task="$1"
    local context="$2"

    local groups_json='['
    local doc_groups=(
        "API documentation"
        "User guide"
        "Developer documentation"
        "Installation guide"
        "Examples and tutorials"
    )

    local first=true
    for group in "${doc_groups[@]}"; do
        if ! $first; then
            groups_json+=','
        fi
        groups_json+=$(jq -n \
            --arg name "$group" \
            --arg task "$task" \
            '{
                id: ($name | gsub(" "; "_") | ascii_downcase),
                name: $name,
                description: "Create " + $name + " for: " + $task,
                tasks: [$task + " - " + $name],
                dependencies: [],
                estimatedEffort: "low",
                ioBound: true
            }')
        first=false
    done

    groups_json+=']'
    echo "$groups_json"
}

generate_batch_processing_groups() {
    local task="$1"
    local context="$2"

    # Try to extract file patterns from context
    local file_count=4
    if [[ -n "$context" ]]; then
        # Count files mentioned or in current directory
        if command -v jq &>/dev/null; then
            file_count=$(echo "$context" | jq -r 'length // 4' 2>/dev/null || echo "4")
            if [[ $file_count -gt 10 ]]; then
                file_count=10  # Cap at 10 groups
            elif [[ $file_count -lt 2 ]]; then
                file_count=2
            fi
        fi
    fi

    local groups_json='['
    local first=true

    for ((i=1; i<=file_count; i++)); do
        if ! $first; then
            groups_json+=','
        fi
        groups_json+=$(jq -n \
            --arg i "$i" \
            --arg total "$file_count" \
            --arg task "$task" \
            '{
                id: ("batch_\($i)"),
                name: "Batch \($i) of \($total)",
                description: "Process batch \($i)/\($total) for: " + $task,
                tasks: [$task + " - batch " + $i],
                dependencies: [],
                estimatedEffort: "medium",
                ioBound: true
            }')
        first=false
    done

    groups_json+=']'
    echo "$groups_json"
}

generate_multi_task_groups() {
    local task="$1"
    local context="$2"

    # Split task by ' and ', ',', or ' also ' using awk
    # Awk handles word-boundary splitting better than sed
    local normalized
    normalized=$(echo "$task" | awk -v RS=' and | also |,' '{gsub(/^[ \t]+|[ \t]+$/, ""); if (NR>1) printf "\n"; printf "%s", $0} END {printf "\n"}')

    # Read into array
    local tasks=()
    while IFS= read -r line; do
        # Trim whitespace and skip empty lines
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        [[ -n "$line" ]] && tasks+=("$line")
    done <<< "$normalized"

    # If we got 0 or 1 tasks, just use the original task
    if [[ ${#tasks[@]} -le 1 ]]; then
        tasks=("$task")
    fi

    # Limit to 10 groups max
    if [[ ${#tasks[@]} -gt 10 ]]; then
        tasks=("${tasks[@]:0:10}")
    fi

    local groups_json='['
    local first=true

    for t in "${tasks[@]}"; do
        if ! $first; then
            groups_json+=','
        fi
        groups_json+=$(jq -n \
            --arg name "$t" \
            '{
                id: ($name | gsub(" "; "_") | gsub("[^a-z0-9_]"; "") | ascii_downcase),
                name: $name,
                description: "Execute: " + $name,
                tasks: [$name],
                dependencies: [],
                estimatedEffort: "medium",
                ioBound: false
            }')
        first=false
    done

    groups_json+=']'
    echo "$groups_json"
}

# ============================================================================
# Main Analysis Function
# ============================================================================

analyze_task() {
    local task="$1"
    local context="${2:-}"

    log "Analyzing task for parallelization: $task"

    # Step 1: Detect pattern
    local pattern
    pattern=$(detect_parallelizable_pattern "$task" "$context")
    log "Detected pattern: $pattern"

    # Step 2: Check for dependencies
    local has_deps=false
    if has_dependencies "$task"; then
        has_deps=true
        log "Task has dependencies - will return sequential execution"
    fi

    # Step 3: Generate groups based on pattern
    local groups_json="[]"
    local strategy="sequential"

    if [[ "$pattern" == "none" || "$has_deps" == "true" ]]; then
        # Not parallelizable
        groups_json="[]"
        strategy="sequential"
    elif [[ "$pattern" == "testing" ]]; then
        groups_json=$(generate_test_groups "$task" "$context")
        strategy="parallel_independent"
    elif [[ "$pattern" == "research" ]]; then
        groups_json=$(generate_research_groups "$task" "$context")
        strategy="parallel_independent"
    elif [[ "$pattern" == "multi_component" ]]; then
        groups_json=$(generate_multi_component_groups "$task" "$context")
        strategy="parallel_independent"
    elif [[ "$pattern" == "documentation" ]]; then
        groups_json=$(generate_documentation_groups "$task" "$context")
        strategy="parallel_independent"
    elif [[ "$pattern" == "batch_processing" ]]; then
        groups_json=$(generate_batch_processing_groups "$task" "$context")
        strategy="parallel_batch"
    elif [[ "$pattern" == "multi_task" ]]; then
        groups_json=$(generate_multi_task_groups "$task" "$context")
        strategy="parallel_independent"
    fi

    # Step 4: Determine if parallelization is beneficial
    local group_count
    group_count=$(echo "$groups_json" | jq 'length')

    local can_parallelize="false"
    if [[ "$pattern" != "none" ]] && [[ "$has_deps" == "false" ]] && [[ $group_count -ge 2 ]]; then
        can_parallelize="true"
    fi

    # Step 5: Build final result
    local result
    result=$(jq -n \
        --arg task "$task" \
        --argjson canParallelize "$can_parallelize" \
        --argjson groups "$groups_json" \
        --arg strategy "$strategy" \
        --arg pattern "$pattern" \
        --argjson hasDependencies "$has_deps" \
        --argjson groupCount "$group_count" \
        '{
            task: $task,
            canParallelize: $canParallelize,
            groups: $groups,
            strategy: $strategy,
            analysis: {
                pattern: $pattern,
                hasDependencies: $hasDependencies,
                groupCount: $groupCount,
                parallelizable: ($canParallelize and $groupCount >= 2)
            },
            recommendations: (
                if $canParallelize and $groupCount >= 3 then
                    ["Auto-spawn swarm for maximum parallelism", ("Use swarm-orchestrator with " + ($groupCount | tostring) + " agents")]
                elif $canParallelize then
                    ["Execute groups in parallel", "Coordinate results after completion"]
                else
                    ["Execute sequentially", "Task structure does not support parallelization"]
                end
            )
        }')

    log "Analysis complete: parallelize=$can_parallelize, groups=$group_count, strategy=$strategy"
    echo "$result"
}

# ============================================================================
# CLI Interface
# ============================================================================

case "${1:-help}" in
    analyze)
        task="${2:-sample task}"
        context="${3:-}"
        analyze_task "$task" "$context"
        ;;

    *)
        cat <<'HELP'
Parallel Execution Planner

Analyzes tasks for parallel execution opportunities and returns groups of
independent subtasks that can be executed in parallel.

Usage: parallel-execution-planner.sh analyze <task> [context]

Commands:
  analyze <task> [context]
      Analyze task and return parallelization plan
      Returns JSON with:
        - canParallelize: boolean
        - groups: array of task groups
        - strategy: parallelization strategy
        - analysis: detailed analysis
        - recommendations: execution recommendations

Examples:
  parallel-execution-planner.sh analyze "Run comprehensive tests"
  parallel-execution-planner.sh analyze "Research authentication patterns"
  parallel-execution-planner.sh analyze "Implement user module and admin module"

Output Format:
{
  "task": "...",
  "canParallelize": true|false,
  "groups": [
    {
      "id": "...",
      "name": "...",
      "description": "...",
      "tasks": [...],
      "dependencies": [],
      "estimatedEffort": "low|medium|high",
      "ioBound": true|false
    }
  ],
  "strategy": "sequential|parallel_independent|parallel_batch",
  "analysis": {
    "pattern": "...",
    "hasDependencies": true|false,
    "groupCount": N,
    "parallelizable": true|false
  },
  "recommendations": ["..."]
}

Integration:
  Used by coordinator.sh to detect swarm spawning opportunities.
  If canParallelize=true and groups>=3, auto-spawns swarm.
HELP
        ;;
esac
