#!/bin/bash
# Tree of Thoughts - Multi-Branch Reasoning
# Generates multiple solution paths and selects the best one
# Usage: tree-of-thoughts.sh generate <problem> <context> [branches]
#        tree-of-thoughts.sh evaluate <branches_json>
#        tree-of-thoughts.sh select <ranked_json> [criterion]

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/tree-of-thoughts.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Generate multiple solution branches
generate() {
    local problem="$1"
    local context="${2:-}"
    local branches="${3:-3}"

    log "Generating Tree of Thoughts for: $problem (branches: $branches)"

    # Generate diverse approaches
    local approaches=""

    case "$branches" in
        3)
            approaches='
    {
        "branch_id": 1,
        "strategy": "incremental",
        "description": "Build solution incrementally, testing each component",
        "steps": [
            "Identify core components",
            "Implement and test each component",
            "Integrate components incrementally",
            "Verify integration points"
        ],
        "estimated_effort": "medium",
        "risk_level": "low"
    },
    {
        "branch_id": 2,
        "strategy": "top_down",
        "description": "Design complete solution first, then implement",
        "steps": [
            "Analyze requirements thoroughly",
            "Design complete architecture",
            "Implement according to design",
            "Validate against requirements"
        ],
        "estimated_effort": "high",
        "risk_level": "medium"
    },
    {
        "branch_id": 3,
        "strategy": "iterative_refinement",
        "description": "Create working solution, then refine iteratively",
        "steps": [
            "Create minimal viable solution",
            "Identify areas for improvement",
            "Refine and extend solution",
            "Polish and optimize"
        ],
        "estimated_effort": "medium",
        "risk_level": "low"
    }'
            ;;
        5)
            approaches='
    {
        "branch_id": 1,
        "strategy": "incremental",
        "description": "Build solution incrementally, testing each component",
        "steps": ["Identify core components", "Implement and test each component", "Integrate components incrementally", "Verify integration points"],
        "estimated_effort": "medium",
        "risk_level": "low"
    },
    {
        "branch_id": 2,
        "strategy": "top_down",
        "description": "Design complete solution first, then implement",
        "steps": ["Analyze requirements thoroughly", "Design complete architecture", "Implement according to design", "Validate against requirements"],
        "estimated_effort": "high",
        "risk_level": "medium"
    },
    {
        "branch_id": 3,
        "strategy": "iterative_refinement",
        "description": "Create working solution, then refine iteratively",
        "steps": ["Create minimal viable solution", "Identify areas for improvement", "Refine and extend solution", "Polish and optimize"],
        "estimated_effort": "medium",
        "risk_level": "low"
    },
    {
        "branch_id": 4,
        "strategy": "parallel_development",
        "description": "Develop components in parallel, then integrate",
        "steps": ["Split into independent components", "Develop in parallel", "Integrate all components", "Test integration"],
        "estimated_effort": "high",
        "risk_level": "high"
    },
    {
        "branch_id": 5,
        "strategy": "prototype_first",
        "description": "Build quick prototype, validate, then implement fully",
        "steps": ["Create quick prototype", "Validate key assumptions", "Implement based on learnings", "Finalize and polish"],
        "estimated_effort": "medium",
        "risk_level": "medium"
    }'
            ;;
        *)
            # Default to 3 branches
            approaches='
    {
        "branch_id": 1,
        "strategy": "incremental",
        "description": "Build solution incrementally, testing each component",
        "steps": ["Identify core components", "Implement and test each component", "Integrate components incrementally", "Verify integration points"],
        "estimated_effort": "medium",
        "risk_level": "low"
    },
    {
        "branch_id": 2,
        "strategy": "top_down",
        "description": "Design complete solution first, then implement",
        "steps": ["Analyze requirements thoroughly", "Design complete architecture", "Implement according to design", "Validate against requirements"],
        "estimated_effort": "high",
        "risk_level": "medium"
    },
    {
        "branch_id": 3,
        "strategy": "iterative_refinement",
        "description": "Create working solution, then refine iteratively",
        "steps": ["Create minimal viable solution", "Identify areas for improvement", "Refine and extend solution", "Polish and optimize"],
        "estimated_effort": "medium",
        "risk_level": "low"
    }'
            ;;
    esac

    # Build JSON with all branches
    jq -n \
        --arg problem "$problem" \
        --arg context "$context" \
        --argjson branches "$approaches" \
        '{
            problem: $problem,
            context: $context,
            branches: $branches,
            generated_at: (now | todateiso8601)
        }'

    log "Generated $branches branches for Tree of Thoughts"
}

# Evaluate branches and rank them
evaluate() {
    local branches_json="$1"

    log "Evaluating Tree of Thoughts branches"

    # Calculate scores for each branch
    echo "$branches_json" | jq '
        .branches |= map(
            . + {
                # Feasibility score (0-1)
                feasibility_score: (
                    if .risk_level == "low" then 0.9
                    elif .risk_level == "medium" then 0.7
                    else 0.5
                    end
                ),
                # Quality score (0-1)
                quality_score: (
                    if .strategy == "incremental" or .strategy == "iterative_refinement" then 0.85
                    elif .strategy == "top_down" then 0.8
                    else 0.75
                    end
                ),
                # Effort score (0-1, inverted - lower effort = higher score)
                effort_score: (
                    if .estimated_effort == "low" then 1.0
                    elif .estimated_effort == "medium" then 0.7
                    else 0.5
                    end
                )
            } |
            . + {
                # Weighted score (adjustable weights)
                weighted_score: (.feasibility_score * 0.4) + (.quality_score * 0.4) + (.effort_score * 0.2)
            }
        ) |
        {
            branches: [.[] | sort_by(.branch_id)],
            selected_branch: (.[] | sort_by(.weighted_score) | reverse | .[0]),
            evaluation_criteria: {
                feasibility_weight: 0.4,
                quality_weight: 0.4,
                effort_weight: 0.2
            }
        }
    '

    log "Branches evaluated and ranked"
}

# Select best branch based on criterion
select() {
    local ranked_json="$1"
    local criterion="${2:-weighted_score}"

    log "Selecting best branch by criterion: $criterion"

    # Select based on criterion
    case "$criterion" in
        weighted_score)
            echo "$ranked_json" | jq '.selected_branch'
            ;;
        feasibility)
            echo "$ranked_json" | jq '.branches | sort_by(.feasibility_score) | reverse | .[0]'
            ;;
        quality)
            echo "$ranked_json" | jq '.branches | sort_by(.quality_score) | reverse | .[0]'
            ;;
        effort)
            echo "$ranked_json" | jq '.branches | sort_by(.effort_score) | reverse | .[0]'
            ;;
        *)
            echo "$ranked_json" | jq '.selected_branch'
            ;;
    esac
}

# Main CLI
case "${1:-help}" in
    generate)
        generate "${2:-problem}" "${3:-}" "${4:-3}"
        ;;
    evaluate)
        evaluate "${2:-branches_json}"
        ;;
    select)
        select "${2:-ranked_json}" "${3:-weighted_score}"
        ;;
    help|*)
        cat <<EOF
Tree of Thoughts - Multi-Branch Reasoning

Usage:
  $0 generate <problem> [context] [branches]
      Generate multiple solution branches
  $0 evaluate <branches_json>
      Evaluate and rank branches
  $0 select <ranked_json> [criterion]
      Select best branch

Strategies:
  incremental           - Build incrementally, test each component
  top_down            - Design first, then implement
  iterative_refinement - Create MVP, then refine
  parallel_development   - Develop in parallel, then integrate
  prototype_first       - Quick prototype, validate, then implement

Evaluation Criteria:
  weighted_score        - Weighted combination (default)
  feasibility          - Most feasible approach
  quality              - Highest quality approach
  effort               - Lowest effort approach

Examples:
  $0 generate "implement authentication" "using OAuth2" 5
  $0 evaluate '["branches": [...]'
  $0 select '["selected_branch": {...]}' "feasibility"
EOF
        ;;
esac
