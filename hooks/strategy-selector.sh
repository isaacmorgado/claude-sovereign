#!/bin/bash
# Strategy Selector - Choose Best Approach
# Selects optimal strategy based on task type and context
# Usage: strategy-selector.sh select <task> [task_type] [context]

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/strategy-selector.log"
STATE_FILE="${HOME}/.claude/strategy-selector-state.json"

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
    "strategies": {
        "incremental": {
            "name": "Incremental",
            "description": "Build solution piece by piece, testing each component",
            "use_cases": ["simple_features", "quick_wins", "early_validation"],
            "avoid": ["complex_dependencies", "big_bang", "major_refactor"]
        },
        "top_down": {
            "name": "Top-Down Design",
            "description": "Design complete solution first, then implement",
            "use_cases": ["complex_features", "new_systems", "architecture_heavy"],
            "avoid": ["unclear_requirements", "changing_scope", "technical_debt"]
        },
        "iterative": {
            "name": "Iterative Refinement",
            "description": "Create working solution, then refine iteratively",
            "use_cases": ["learning_curve", "research_tasks", "evolving_requirements"],
            "avoid": ["over_engineering", "premature_optimization", "feature_creep"]
        },
        "prototype_first": {
            "name": "Prototype First",
            "description": "Build quick prototype, validate, then implement fully",
            "use_cases": ["unclear_requirements", "new_technologies", "user_validation"],
            "avoid": ["production_quality", "security_critical", "data_integrity"]
        }
    },
    "test_driven": {
            "name": "Test-Driven Development",
            "description": "Write tests first, then implement to pass",
            "use_cases": ["well_defined_requirements", "critical_quality", "regression_prone"],
            "avoid": ["testing_after", "manual_testing_only", "no_automation"]
        },
        "data_driven": {
            "name": "Data-Driven Approach",
            "description": "Analyze data to inform decisions",
            "use_cases": ["analytics", "performance_optimization", "a_b_testing"],
            "avoid": ["gut_feelings", "assumptions", "no_validation"]
        }
    },
    "minimal_viable": {
            "name": "Minimal Viable Product",
            "description": "Simplest solution that meets core requirements",
            "use_cases": ["time_pressure", "resource_constraints", "simple_requirements"],
            "avoid": ["feature_bloat", "over_engineering", "complex_abstractions"]
        }
    },
    "risk_first": {
            "name": "Risk-First Approach",
            "description": "Address highest risks first, then proceed",
            "use_cases": ["security_critical", "production_deployment", "data_migration"],
            "avoid": ["optimization_first", "feature_addition", "technical_debt"]
        }
    },
    "spike": {
            "name": "Spike",
            "description": "Time-boxed investigation to answer specific question",
            "use_cases": ["technical_unknown", "architecture_decision", "tool_evaluation"],
            "avoid": ["production_code", "long_term_commitment"]
        }
    },
    "parallel": {
        "name": "Parallel Development",
            "description": "Execute independent tasks simultaneously",
            "use_cases": ["independent_components", "no_dependencies", "resource_intensive"],
            "avoid": ["shared_state", "sequential_dependencies", "coordination_overhead"]
        }
    },
    "divide_conquer": {
            "name": "Divide and Conquer",
            "description": "Break problem into independent sub-problems",
            "use_cases": ["complex_algorithms", "large_systems", "team_development"],
            "avoid": ["tightly_coupled", "shared_mutable_state", "integration_complexity"]
        }
    }
}
EOF
    fi
}

# Select best strategy
select() {
    local task="$1"
    local task_type="${2:-general}"
    local context="${3:-}"

    init_state
    log "Selecting strategy for: $task (type: $task_type)"

    # Get strategies
    local strategies_json
    strategies_json=$(jq -r '.strategies' "$STATE_FILE")

    # Analyze task characteristics
    local task_lower
    task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    local selected_strategy="incremental"
    local confidence=0.7
    local reasoning=""

    # Strategy selection logic
    case "$task_type" in
        implementation)
            if [[ "$task_lower" =~ (simple|quick|minor|typo|comment|small) ]]; then
                selected_strategy="incremental"
                confidence=0.85
                reasoning="Simple task - build incrementally with testing"
            elif [[ "$task_lower" =~ (complex|system|architecture|integration) ]]; then
                selected_strategy="top_down"
                confidence=0.8
                reasoning="Complex task - design first, then implement"
            elif [[ "$task_lower" =~ (new|feature|experimental) ]]; then
                selected_strategy="prototype_first"
                confidence=0.75
                reasoning="New feature - prototype to validate approach"
            else
                selected_strategy="iterative"
                confidence=0.7
                reasoning="Standard implementation - iterate to refine"
            fi
            ;;
        debugging)
            if [[ "$task_lower" =~ (urgent|critical|hotfix|production) ]]; then
                selected_strategy="risk_first"
                confidence=0.9
                reasoning="Urgent/critical issue - address risks first"
            else
                selected_strategy="test_driven"
                confidence=0.8
                reasoning="Debug task - write tests to validate fix"
            fi
            ;;
        testing)
            selected_strategy="test_driven"
            confidence=0.85
            reasoning="Testing task - test-driven development approach"
            ;;
        refactoring)
            if [[ "$task_lower" =~ (performance|optimization|scale|efficiency) ]]; then
                selected_strategy="data_driven"
                confidence=0.8
                reasoning="Performance task - use data to drive optimization"
            else
                selected_strategy="incremental"
                confidence=0.75
                reasoning="Refactoring - incremental approach with validation"
            fi
            ;;
        research)
            if [[ "$task_lower" =~ (investigate|explore|analyze|study) ]]; then
                selected_strategy="spike"
                confidence=0.7
                reasoning="Research task - use spike to investigate"
            else
                selected_strategy="data_driven"
                confidence=0.7
                reasoning="Research - analyze data to inform approach"
            fi
            ;;
        *)
            # Default
            selected_strategy="incremental"
            confidence=0.7
            reasoning="Default strategy - incremental approach"
            ;;
    esac

    # Get strategy details
    local strategy_info
    strategy_info=$(echo "$strategies_json" | jq -r ".[\"$selected_strategy\"]")

    local strategy_name
    strategy_name=$(echo "$strategy_info" | jq -r '.name')

    local strategy_desc
    strategy_desc=$(echo "$strategy_info" | jq -r '.description')

    log "Selected strategy: $strategy_name (confidence: $confidence)"

    # Output selection result
    jq -n \
        --arg task "$task" \
        --arg type "$task_type" \
        --arg context "$context" \
        --arg strategy "$selected_strategy" \
        --argjson confidence "$confidence" \
        --arg strategy_name "$strategy_name" \
        --arg strategy_desc "$strategy_desc" \
        --arg reasoning "$reasoning" \
        '{
            task: $task,
            task_type: $type,
            context: $context,
            selected_strategy: $strategy,
            strategy_name: $strategy_name,
            strategy_description: $strategy_desc,
            confidence: $confidence,
            reasoning: $reasoning,
            alternative_strategies: (.strategies | keys | map(select(. != $strategy)))
        }'
}

# Get available strategies
strategies() {
    init_state

    jq '.strategies | to_entries | map({id: .key, name: .value.name, description: .value.description})' "$STATE_FILE"
}

# Get strategy usage history
history() {
    init_state

    # This would track strategy selection over time
    jq '{
        selection_history: [],
        strategy_effectiveness: {}
    }' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Strategy selector state initialized"
        ;;
    select)
        select "${2:-task}" "${3:-general}" "${4:-}"
        ;;
    strategies)
        strategies
        ;;
    history)
        history
        ;;
    help|*)
        cat <<EOF
Strategy Selector - Choose Best Approach

Usage:
  $0 select <task> [task_type] [context]
      Select optimal strategy for task
  $0 strategies                         List available strategies
  $0 history                             Get strategy selection history

Strategies:
  incremental         - Build piece by piece with testing
  top_down           - Design first, then implement
  iterative           - Create MVP, then refine
  prototype_first     - Quick prototype, validate, then implement
  test_driven        - Write tests first, then implement
  data_driven        - Analyze data to inform decisions
  minimal_viable     - Simplest solution for core requirements
  risk_first          - Address highest risks first
  spike              - Time-boxed investigation
  parallel            - Execute independent tasks simultaneously
  divide_conquer     - Break into independent sub-problems

Strategy Selection Factors:
  - Task type and complexity
  - Time constraints and urgency
  - Resource availability
  - Risk tolerance
  - Quality requirements

Examples:
  $0 select "implement auth system" "implementation"
  $0 select "fix critical bug" "debugging"
  $0 strategies
EOF
        ;;
esac
