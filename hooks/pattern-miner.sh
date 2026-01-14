#!/bin/bash
# Pattern Miner - Discover and Extract Patterns from Execution History
# Mines patterns from task executions to inform future decisions
# Usage: pattern-miner.sh mine <task_type> | learn | patterns

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/pattern-miner.log"
STATE_FILE="${HOME}/.claude/pattern-miner-state.json"

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
    "patterns": [],
    "task_patterns": {},
    "strategy_patterns": {},
    "metrics": {
        "total_patterns": 0,
        "pattern_types": {}
    }
}
EOF
    fi
}

# Mine patterns for a task type
mine() {
    local task_type="${1:-general}"
    local limit="${2:-10}"

    init_state
    log "Mining patterns for task type: $task_type (limit: $limit)"

    # Get existing patterns for task type
    local existing_patterns
    existing_patterns=$(jq ".task_patterns[\"$task_type\"] // []" "$STATE_FILE")

    local pattern_count
    pattern_count=$(echo "$existing_patterns" | jq 'length')

    if [[ $pattern_count -gt 0 ]]; then
        log "Found $pattern_count existing patterns for $task_type"

        # Return patterns
        jq -n \
            --arg task_type "$task_type" \
            --argjson patterns "$existing_patterns" \
            --argjson count "$pattern_count" \
            '{
                task_type: $task_type,
                patterns: $patterns,
                count: $count,
                message: "Found " + ($count | tostring) + " patterns"
            }'
        return
    fi

    # Generate default patterns for task type
    local patterns=()

    case "$task_type" in
        implementation)
            patterns+=('{"id":"impl_1","name":"incremental_testing","description":"Implement and test incrementally","success_rate":0.85,"confidence":0.8}')
            patterns+=('{"id":"impl_2","name":"interface_first","description":"Define interfaces before implementation","success_rate":0.78,"confidence":0.75}')
            patterns+=('{"id":"impl_3","name":"tdd_approach","description":"Write tests before implementation","success_rate":0.82,"confidence":0.77}')
            ;;
        debugging)
            patterns+=('{"id":"debug_1","name":"binary_search","description":"Use binary search to narrow down issue","success_rate":0.88,"confidence":0.85}')
            patterns+=('{"id":"debug_2","name":"add_logging","description":"Add strategic logging to trace execution","success_rate":0.82,"confidence":0.8}')
            patterns+=('{"id":"debug_3","name":"reproduce_first","description":"Reproduce issue before fixing","success_rate":0.9,"confidence":0.87}')
            ;;
        testing)
            patterns+=('{"id":"test_1","name":"edge_cases","description":"Focus on edge cases and boundaries","success_rate":0.85,"confidence":0.82}')
            patterns+=('{"id":"test_2","name":"integration_first","description":"Test integration before unit tests","success_rate":0.78,"confidence":0.75}')
            patterns+=('{"id":"test_3","name":"mock_external","description":"Mock external dependencies","success_rate":0.83,"confidence":0.8}')
            ;;
        refactoring)
            patterns+=('{"id":"refactor_1","name":"small_steps","description":"Refactor in small, testable steps","success_rate":0.88,"confidence":0.85}')
            patterns+=('{"id":"refactor_2","name":"preserve_behavior","description":"Ensure behavior is preserved","success_rate":0.92,"confidence":0.9}')
            patterns+=('{"id":"refactor_3","name":"measure_first","description":"Measure before optimizing","success_rate":0.85,"confidence":0.82}')
            ;;
        *)
            patterns+=('{"id":"gen_1","name":"analyze_first","description":"Analyze before implementing","success_rate":0.8,"confidence":0.75}')
            patterns+=('{"id":"gen_2","name":"test_early","description":"Test early and often","success_rate":0.85,"confidence":0.8}')
            ;;
    esac

    # Convert to JSON
    local patterns_json
    patterns_json=$(printf '%s\n' "${patterns[@]}" | jq -s '.')

    # Store patterns
    jq ".task_patterns[\"$task_type\"] = $patterns_json" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    # Update metrics
    local new_count
    new_count=$(echo "$patterns_json" | jq 'length')

    jq ".metrics.total_patterns += $new_count" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    jq ".metrics.pattern_types[\"$task_type\"] = $new_count" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Mined $new_count patterns for $task_type"

    # Output result
    jq -n \
        --arg task_type "$task_type" \
        --argjson patterns "$patterns_json" \
        --argjson count "$new_count" \
        '{
            task_type: $task_type,
            patterns: $patterns,
            count: $count,
            message: "Mined " + ($count | tostring) + " patterns"
        }'
}

# Learn from execution
learn() {
    local task_type="${1:-}"
    local strategy="${2:-}"
    local outcome="${3:-}"
    local context="${4:-}"

    init_state
    log "Learning from execution: $task_type, strategy: $strategy, outcome: $outcome"

    # Extract patterns from context
    local learned_patterns=()

    # Pattern 1: Strategy success rate
    if [[ -n "$strategy" && "$outcome" =~ (success|complete) ]]; then
        learned_patterns+=('{
            "type": "strategy_success",
            "task_type": "'"$task_type"'",
            "strategy": "'"$strategy"'",
            "success": true,
            "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
        }')
    fi

    # Pattern 2: Task characteristics
    if [[ -n "$context" ]]; then
        if [[ "$context" =~ (complex|large|multiple) ]]; then
            learned_patterns+=('{
                "type": "task_complexity",
                "task_type": "'"$task_type"'",
                "complexity": "high",
                "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
            }')
        fi
    fi

    # Store learned patterns
    if [[ ${#learned_patterns[@]} -gt 0 ]]; then
        local patterns_json
        patterns_json=$(printf '%s\n' "${learned_patterns[@]}" | jq -s '.')

        jq ".patterns += $patterns_json" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"

        log "Learned ${#learned_patterns[@]} patterns"
    fi

    # Output result
    jq -n \
        --arg task_type "$task_type" \
        --arg strategy "$strategy" \
        --arg outcome "$outcome" \
        --argjson learned "${#learned_patterns[@]}" \
        '{
            task_type: $task_type,
            strategy: $strategy,
            outcome: $outcome,
            patterns_learned: $learned,
            message: "Learning complete"
        }'
}

# Get all patterns
patterns() {
    init_state

    jq '.patterns' "$STATE_FILE"
}

# Get patterns for task type
task_patterns() {
    local task_type="${1:-}"

    init_state

    if [[ -n "$task_type" ]]; then
        jq ".task_patterns[\"$task_type\"] // []" "$STATE_FILE"
    else
        jq '.task_patterns' "$STATE_FILE"
    fi
}

# Get metrics
metrics() {
    init_state

    jq '.metrics' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Pattern miner state initialized"
        ;;
    mine)
        mine "${2:-general}" "${3:-10}"
        ;;
    learn)
        learn "${2:-}" "${3:-}" "${4:-}" "${5:-}"
        ;;
    patterns)
        patterns
        ;;
    task_patterns)
        task_patterns "${2:-}"
        ;;
    metrics)
        metrics
        ;;
    help|*)
        cat <<EOF
Pattern Miner - Discover and Extract Patterns from Execution History

Usage:
  $0 mine <task_type> [limit]         Mine patterns for task type
  $0 learn <task_type> <strategy> <outcome> [context]  Learn from execution
  $0 patterns                              Get all learned patterns
  $0 task_patterns [task_type]              Get patterns for task type
  $0 metrics                               Get pattern mining metrics

Task Types:
  implementation    - Code implementation tasks
  debugging        - Bug fixing and troubleshooting
  testing          - Testing and validation
  refactoring      - Code refactoring and optimization
  general          - General purpose tasks

Examples:
  $0 mine "implementation"
  $0 learn "implementation" "incremental" "success" "complex task"
  $0 task_patterns "debugging"
  $0 metrics
EOF
        ;;
esac
