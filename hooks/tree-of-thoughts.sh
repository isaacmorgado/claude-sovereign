#!/bin/bash
# Tree of Thoughts - Explore multiple solution paths, evaluate, select best
# Based on: kyegomez/tree-of-thoughts, strategic-debate-tot, ToT papers
# Implements branching reasoning with evaluation and selection

set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
MEMORY_MANAGER="${CLAUDE_DIR}/hooks/memory-manager.sh"
LOG_FILE="${CLAUDE_DIR}/tree-of-thoughts.log"
TOT_STATE_DIR="${CLAUDE_DIR}/.tot"

mkdir -p "$TOT_STATE_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =============================================================================
# TREE OF THOUGHTS: Generate multiple solution paths
# =============================================================================

# Generate N different approaches to a problem
generate_thought_branches() {
    local problem="$1"
    local context="$2"
    local num_branches="${3:-3}"
    local depth="${4:-0}"

    log "Generating $num_branches thought branches for: $problem (depth=$depth)"

    # Search for similar problems in memory
    local similar_solutions="[]"
    if [[ -x "$MEMORY_MANAGER" ]]; then
        similar_solutions=$("$MEMORY_MANAGER" remember-scored "$problem" 3 2>/dev/null || echo '[]')
    fi

    local generation_prompt="I need to solve this problem: $problem\\n\\nContext: $context\\n\\nDepth in tree: $depth\\n\\nPlease generate $num_branches DISTINCT approaches to solve this problem.\\nEach approach should be meaningfully different (not just minor variations).\\n\\nFor EACH approach, provide:\\n\\n1. **Approach Name**: Short descriptive name\\n2. **Core Strategy**: What's the main idea?\\n3. **Steps**: High-level steps (3-5 bullet points)\\n4. **Pros**: What are the advantages?\\n5. **Cons**: What are the drawbacks/risks?\\n6. **Feasibility Score (1-10)**: How practical is this?\\n7. **Risk Score (1-10)**: How risky is this approach?\\n8. **Estimated Effort (1-10)**: How much work is required?\\n9. **Expected Quality (1-10)**: What quality outcome do we expect?\\n\\nFormat as JSON with branches array.\\n\\nGenerate $num_branches diverse approaches now:"

    local tree_id="tot_$(date +%s)_$$"

    jq -n \
        --arg problem "$problem" \
        --arg context "$context" \
        --argjson depth "$depth" \
        --argjson num_branches "$num_branches" \
        --argjson similar_solutions "${similar_solutions}" \
        --arg prompt "$generation_prompt" \
        --arg tree_id "$tree_id" \
        '{
            problem: $problem,
            context: $context,
            depth: $depth,
            num_branches: $num_branches,
            similar_solutions: $similar_solutions,
            generation_prompt: $prompt,
            tree_id: $tree_id
        }'
}

# =============================================================================
# BRANCH EVALUATION: Score and rank approaches
# =============================================================================

# Evaluate a single branch
evaluate_branch() {
    local branch_json="$1"
    local weights="${2:-feasibility:0.3,quality:0.3,risk:0.2,effort:0.2}"

    log "Evaluating branch: $(echo "$branch_json" | jq -r '.name // "unknown"')"

    # Parse weights (using sed for macOS compatibility)
    local w_feasibility=$(echo "$weights" | sed -n 's/.*feasibility:\([0-9.]*\).*/\1/p' || echo "0.3")
    [[ -z "$w_feasibility" ]] && w_feasibility="0.3"
    local w_quality=$(echo "$weights" | sed -n 's/.*quality:\([0-9.]*\).*/\1/p' || echo "0.3")
    [[ -z "$w_quality" ]] && w_quality="0.3"
    local w_risk=$(echo "$weights" | sed -n 's/.*risk:\([0-9.]*\).*/\1/p' || echo "0.2")
    [[ -z "$w_risk" ]] && w_risk="0.2"
    local w_effort=$(echo "$weights" | sed -n 's/.*effort:\([0-9.]*\).*/\1/p' || echo "0.2")
    [[ -z "$w_effort" ]] && w_effort="0.2"

    # Extract scores
    local feasibility=$(echo "$branch_json" | jq -r '.scores.feasibility // 5')
    local quality=$(echo "$branch_json" | jq -r '.scores.quality // 5')
    local risk=$(echo "$branch_json" | jq -r '.scores.risk // 5')
    local effort=$(echo "$branch_json" | jq -r '.scores.effort // 5')

    # Calculate weighted score (invert risk and effort - lower is better)
    local weighted_score=$(echo "scale=2; ($feasibility * $w_feasibility) + ($quality * $w_quality) + ((10 - $risk) * $w_risk) + ((10 - $effort) * $w_effort)" | bc)

    # Add evaluation to branch
    echo "$branch_json" | jq --argjson score "$weighted_score" '. + {
        weighted_score: $score,
        evaluated_at: (now | todate)
    }'
}

# Compare and rank all branches
rank_branches() {
    local branches_json="$1"
    local weights="${2:-feasibility:0.3,quality:0.3,risk:0.2,effort:0.2}"

    log "Ranking branches"
    log "Branches JSON received: ${branches_json:0:100}..."

    # Parse weights once
    local w_feasibility=$(echo "$weights" | sed -n 's/.*feasibility:\([0-9.]*\).*/\1/p' || echo "0.3")
    [[ -z "$w_feasibility" ]] && w_feasibility="0.3"
    local w_quality=$(echo "$weights" | sed -n 's/.*quality:\([0-9.]*\).*/\1/p' || echo "0.3")
    [[ -z "$w_quality" ]] && w_quality="0.3"
    local w_risk=$(echo "$weights" | sed -n 's/.*risk:\([0-9.]*\).*/\1/p' || echo "0.2")
    [[ -z "$w_risk" ]] && w_risk="0.2"
    local w_effort=$(echo "$weights" | sed -n 's/.*effort:\([0-9.]*\).*/\1/p' || echo "0.2")
    [[ -z "$w_effort" ]] && w_effort="0.2"

    log "Weights: feas=$w_feasibility, qual=$w_quality, risk=$w_risk, effort=$w_effort"

    # Evaluate and rank in a single jq pass (avoids subshell issues)
    jq \
        --argjson w_feas "$w_feasibility" \
        --argjson w_qual "$w_quality" \
        --argjson w_risk "$w_risk" \
        --argjson w_effort "$w_effort" \
        '
        .branches | map(
            . + {
                weighted_score: (
                    (.scores.feasibility * $w_feas) +
                    (.scores.quality * $w_qual) +
                    ((10 - .scores.risk) * $w_risk) +
                    ((10 - .scores.effort) * $w_effort)
                ),
                evaluated_at: (now | todate)
            }
        ) | sort_by(-.weighted_score)
        ' <<< "$branches_json"
}

# =============================================================================
# DECISION MAKING: Select best approach
# =============================================================================

# Select the best branch
select_best_branch() {
    local ranked_branches="$1"
    local selection_strategy="${2:-highest_score}"

    log "Selecting best branch (strategy: $selection_strategy)"

    case "$selection_strategy" in
        highest_score)
            # Simply pick the highest scoring branch
            echo "$ranked_branches" | jq '.[0]'
            ;;
        risk_averse)
            # Pick highest score among low-risk options (risk <= 5)
            echo "$ranked_branches" | jq '[.[] | select(.scores.risk <= 5)] | .[0]'
            ;;
        quick_win)
            # Pick lowest effort option that scores >= 7, or just lowest effort if none qualify
            local result
            result=$(echo "$ranked_branches" | jq '[.[] | select(.weighted_score >= 7)] | sort_by(.scores.effort) | .[0]')
            if [[ "$result" == "null" ]]; then
                # No branch scores >= 7, just pick lowest effort
                result=$(echo "$ranked_branches" | jq 'sort_by(.scores.effort) | .[0]')
            fi
            echo "$result"
            ;;
        high_quality)
            # Pick highest quality option regardless of effort
            echo "$ranked_branches" | jq 'sort_by(-.scores.quality) | .[0]'
            ;;
        *)
            # Default to highest score
            echo "$ranked_branches" | jq '.[0]'
            ;;
    esac
}

# =============================================================================
# TREE EXPANSION: Explore deeper into selected branches
# =============================================================================

# Expand a branch into sub-branches
expand_branch() {
    local branch_json="$1"
    local max_depth="${2:-2}"
    local current_depth="${3:-0}"

    local branch_name
    branch_name=$(echo "$branch_json" | jq -r '.name')

    log "Expanding branch: $branch_name (depth $current_depth/$max_depth)"

    if (( current_depth >= max_depth )); then
        log "Max depth reached, stopping expansion"
        echo "$branch_json"
        return
    fi

    # Create sub-problem for this branch
    local strategy
    strategy=$(echo "$branch_json" | jq -r '.strategy')

    # Generate sub-branches
    local next_depth=$((current_depth + 1))
    local sub_branches_prompt
    sub_branches_prompt=$(generate_thought_branches "$strategy" "Expanding: $branch_name" 3 "$next_depth")

    # Return prompt for sub-generation
    echo "$sub_branches_prompt" | jq --argjson parent "$branch_json" '. + {parent_branch: $parent}'
}

# =============================================================================
# MONTE CARLO TREE SEARCH (MCTS) simulation
# =============================================================================

# Simplified MCTS: Select → Expand → Simulate → Backpropagate
mcts_iteration() {
    local problem="$1"
    local context="$2"
    local iterations="${3:-5}"

    log "Running MCTS for $iterations iterations"

    local mcts_prompt="Using Monte Carlo Tree Search to explore solution space:\\n\\nProblem: $problem\\nContext: $context\\nIterations: $iterations\\n\\nFor each iteration:\\n1. Select the most promising unexplored branch\\n2. Expand it with new sub-approaches\\n3. Simulate outcomes\\n4. Update scores based on results\\n\\nThis explores the solution space more thoroughly than simple branching."

    jq -n \
        --arg algo "monte_carlo_tree_search" \
        --arg problem "$problem" \
        --arg context "$context" \
        --argjson iterations "$iterations" \
        --arg prompt "$mcts_prompt" \
        '{
            algorithm: $algo,
            problem: $problem,
            context: $context,
            iterations: $iterations,
            process: [
                "1. Selection: Choose most promising branch using UCB1",
                "2. Expansion: Generate child branches",
                "3. Simulation: Evaluate potential outcomes",
                "4. Backpropagation: Update branch scores"
            ],
            prompt: $prompt
        }'
}

# =============================================================================
# TREE PERSISTENCE AND VISUALIZATION
# =============================================================================

# Save tree state
save_tree_state() {
    local tree_id="$1"
    local tree_data="$2"

    local tree_file="$TOT_STATE_DIR/${tree_id}.json"

    echo "$tree_data" > "$tree_file"

    log "Saved tree state: $tree_file"

    echo "{\"status\":\"saved\",\"file\":\"$tree_file\"}"
}

# Load tree state
load_tree_state() {
    local tree_id="$1"

    local tree_file="$TOT_STATE_DIR/${tree_id}.json"

    if [[ ! -f "$tree_file" ]]; then
        log "Tree not found: $tree_id"
        echo "{\"error\":\"tree_not_found\"}"
        return 1
    fi

    cat "$tree_file"
}

# Generate tree visualization
visualize_tree() {
    local tree_data="$1"

    log "Generating tree visualization"

    local visualization
    visualization=$(echo "$tree_data" | jq -r '
        if .branches then
            "# Tree of Thoughts\n\n" +
            (.branches[] | "## \(.name) (Score: \(.weighted_score // "N/A"))\n\n" +
            "**Strategy:** \(.strategy)\n\n" +
            "**Pros:** \(.pros | join(", "))\n\n" +
            "**Cons:** \(.cons | join(", "))\n\n" +
            "**Scores:**\n" +
            "- Feasibility: \(.scores.feasibility)/10\n" +
            "- Quality: \(.scores.quality)/10\n" +
            "- Risk: \(.scores.risk)/10\n" +
            "- Effort: \(.scores.effort)/10\n\n" +
            "---\n\n")
        else
            "No branches to visualize"
        end
    ')

    echo "$visualization"
}

# =============================================================================
# MAIN EXPLORATION FUNCTION (Used by coordinator)
# =============================================================================

# Main exploration function: generate → rank → select
# Returns the expected format for coordinator integration
explore() {
    local problem="$1"
    local context="$2"
    local num_branches="${3:-3}"
    local selection_strategy="${4:-highest_score}"
    local weights="${5:-feasibility:0.3,quality:0.3,risk:0.2,effort:0.2}"

    log "Starting exploration: $problem"

    # Step 1: Generate thought branches
    local generation_result
    generation_result=$(generate_thought_branches "$problem" "$context" "$num_branches" 0)

    local tree_id
    tree_id=$(echo "$generation_result" | jq -r '.tree_id')

    local generation_prompt
    generation_prompt=$(echo "$generation_result" | jq -r '.generation_prompt')

    log "Generated exploration prompt for tree_id: $tree_id"

    # The generation_result contains a prompt that needs to be sent to Claude
    # This function returns metadata that indicates Claude should generate branches
    # The coordinator will need to:
    # 1. Send generation_prompt to Claude
    # 2. Get branches back from Claude
    # 3. Call rank_branches with the result
    # 4. Call select_best_branch on ranked results

    # For now, we create a placeholder structure showing what's needed
    # The actual branch generation happens in the coordinator/agent loop

    echo "$generation_result" | jq \
        --arg strategy "$selection_strategy" \
        --arg weights "$weights" \
        '. + {
            pipeline: "generate_rank_select",
            next_step: "await_claude_generation",
            selection_strategy: $strategy,
            evaluation_weights: $weights,
            instructions: "Send generation_prompt to Claude, then call rank and select"
        }'
}

# Complete the full pipeline when branches are provided
# This is called by coordinator after Claude generates the branches
complete_exploration() {
    local branches_json="$1"
    local selection_strategy="${2:-highest_score}"
    local weights="${3:-feasibility:0.3,quality:0.3,risk:0.2,effort:0.2}"

    log "Completing exploration pipeline: rank → select"
    log "Input JSON length: ${#branches_json}"

    # Step 2: Rank branches
    local ranked_branches
    ranked_branches=$(rank_branches "$branches_json" "$weights")

    local alternatives_count
    alternatives_count=$(echo "$ranked_branches" | jq 'length')

    log "Ranked $alternatives_count branches"

    # Step 3: Select best branch
    local selected_branch
    selected_branch=$(select_best_branch "$ranked_branches" "$selection_strategy")

    log "Selected best branch: $(echo "$selected_branch" | jq -r '.name // "unknown"')"

    # Return in coordinator-expected format
    jq -n \
        --argjson selected "$selected_branch" \
        --argjson alternatives "$alternatives_count" \
        --argjson all_ranked "$ranked_branches" \
        '{
            selected_branch: {
                approach: $selected.name,
                steps: $selected.steps,
                evaluation_score: $selected.weighted_score,
                reasoning: $selected.strategy,
                scores: $selected.scores,
                pros: $selected.pros,
                cons: $selected.cons
            },
            alternatives_considered: $alternatives,
            all_ranked_branches: $all_ranked
        }'
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

# Only run the CLI if script is executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
    explore)
        # Main exploration function (used by coordinator)
        explore "${2:-problem}" "${3:-context}" "${4:-3}" "${5:-highest_score}" "${6:-feasibility:0.3,quality:0.3,risk:0.2,effort:0.2}"
        ;;
    complete)
        # Complete exploration after Claude generates branches
        complete_exploration "${2:-{}}" "${3:-highest_score}" "${4:-feasibility:0.3,quality:0.3,risk:0.2,effort:0.2}"
        ;;
    generate)
        # Generate thought branches
        generate_thought_branches "${2:-problem}" "${3:-context}" "${4:-3}" "${5:-0}"
        ;;
    evaluate)
        # Evaluate a single branch
        evaluate_branch "${2:-{}}" "${3:-feasibility:0.3,quality:0.3,risk:0.2,effort:0.2}"
        ;;
    rank)
        # Rank all branches
        rank_branches "${2:-{}}" "${3:-feasibility:0.3,quality:0.3,risk:0.2,effort:0.2}"
        ;;
    select)
        # Select best branch
        select_best_branch "${2:-[]}" "${3:-highest_score}"
        ;;
    expand)
        # Expand a branch
        expand_branch "${2:-{}}" "${3:-2}" "${4:-0}"
        ;;
    mcts)
        # Run MCTS
        mcts_iteration "${2:-problem}" "${3:-context}" "${4:-5}"
        ;;
    save)
        # Save tree state
        save_tree_state "${2:-tree_id}" "${3:-{}}"
        ;;
    load)
        # Load tree state
        load_tree_state "${2:-tree_id}"
        ;;
    visualize)
        # Visualize tree
        visualize_tree "${2:-{}}"
        ;;
    help|*)
        echo "Tree of Thoughts - Multi-Path Reasoning and Selection"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Main Pipeline (for coordinator integration):"
        echo "  explore <problem> <context> [num_branches] [strategy] [weights]"
        echo "                                     - Start exploration (generate → rank → select)"
        echo "                                       Returns generation prompt for Claude"
        echo "  complete <branches_json> [strategy] [weights]"
        echo "                                     - Complete pipeline after Claude generates branches"
        echo "                                       Returns selected_branch + alternatives_considered"
        echo ""
        echo "Individual Steps (for manual use):"
        echo "  generate <problem> <context> [num_branches] [depth]"
        echo "                                     - Generate N different approaches"
        echo ""
        echo "Evaluation:"
        echo "  evaluate <branch_json> [weights]   - Evaluate single branch"
        echo "  rank <branches_json> [weights]     - Rank all branches"
        echo "                                       Weights: 'feasibility:0.3,quality:0.3,risk:0.2,effort:0.2'"
        echo ""
        echo "Selection:"
        echo "  select <ranked_branches> [strategy]"
        echo "                                     - Select best branch"
        echo "                                       Strategies: highest_score, risk_averse,"
        echo "                                                   quick_win, high_quality"
        echo ""
        echo "Tree Expansion:"
        echo "  expand <branch_json> [max_depth] [current_depth]"
        echo "                                     - Expand branch into sub-branches"
        echo "  mcts <problem> <context> [iterations]"
        echo "                                     - Monte Carlo Tree Search"
        echo ""
        echo "Persistence:"
        echo "  save <tree_id> <tree_data>         - Save tree state"
        echo "  load <tree_id>                     - Load tree state"
        echo "  visualize <tree_data>              - Generate markdown visualization"
        echo ""
        echo "Example workflow (coordinator):"
        echo "  1. result=\$($0 explore 'fix bug' 'auth module' 3 highest_score)"
        echo "  2. prompt=\$(echo \"\$result\" | jq -r '.generation_prompt')"
        echo "  3. [Send prompt to Claude, get branches back]"
        echo "  4. final=\$($0 complete \"\$branches\" highest_score)"
        echo "  5. approach=\$(echo \"\$final\" | jq -r '.selected_branch.approach')"
        echo "  6. [Execute the selected approach]"
        echo ""
        echo "Example workflow (manual):"
        echo "  1. prompt=\$($0 generate 'fix bug' 'auth module' 3)"
        echo "  2. [Send to Claude, get branches]"
        echo "  3. ranked=\$($0 rank \"\$branches\")"
        echo "  4. best=\$($0 select \"\$ranked\" highest_score)"
        echo "  5. [Execute the best approach]"
        echo ""
        echo "When to use ToT:"
        echo "  - Tests failing after 2+ attempts"
        echo "  - Complex architectural decisions"
        echo "  - Multiple valid approaches exist"
        echo "  - Need to explore solution space thoroughly"
        ;;
    esac
fi
