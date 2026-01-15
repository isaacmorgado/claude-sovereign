#!/bin/bash
# Test Tree of Thoughts Pipeline Fix
# Verifies: generate → rank → select pipeline works correctly

set -uo pipefail

TOT="/Users/imorgado/.claude/hooks/tree-of-thoughts.sh"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

passed=0
failed=0

test_result() {
    if [[ $1 -eq 0 ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        ((passed++))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        ((failed++))
    fi
}

echo "========================================="
echo "Testing Tree of Thoughts Pipeline"
echo "========================================="
echo ""

# Test 1: explore function exists
echo "Test 1: explore function exists"
if  $TOT help | grep -q "explore" || false; then
    test_result 0 "explore command is documented"
else
    test_result 1 "explore command is documented"
fi

# Test 2: complete function exists
echo "Test 2: complete function exists"
if $TOT help | grep -q "complete" || false; then
    test_result 0 "complete command is documented"
else
    test_result 1 "complete command is documented"
fi

# Test 3: explore returns expected structure
echo "Test 3: explore returns generation prompt"
result=$($TOT explore "fix authentication bug" "user login failing" 3 2>/dev/null || echo '{}')
if echo "$result" | jq -e '.generation_prompt' > /dev/null 2>&1; then
    test_result 0 "explore returns generation_prompt"
else
    test_result 1 "explore returns generation_prompt"
    echo "Got: $result"
fi

# Test 4: explore includes tree_id
echo "Test 4: explore includes tree_id"
if echo "$result" | jq -e '.tree_id' > /dev/null 2>&1; then
    test_result 0 "explore returns tree_id"
else
    test_result 1 "explore returns tree_id"
fi

# Test 5: explore includes pipeline metadata
echo "Test 5: explore includes pipeline metadata"
if echo "$result" | jq -e '.pipeline == "generate_rank_select"' > /dev/null 2>&1; then
    test_result 0 "explore indicates correct pipeline"
else
    test_result 1 "explore indicates correct pipeline"
fi

# Test 6: Create mock branches for complete testing
echo "Test 6: complete function with mock branches"
mock_branches='{
  "branches": [
    {
      "name": "Approach 1: Direct Fix",
      "strategy": "Fix the authentication logic directly",
      "steps": ["Step 1", "Step 2", "Step 3"],
      "pros": ["Fast", "Simple"],
      "cons": ["Risky"],
      "scores": {
        "feasibility": 8,
        "quality": 7,
        "risk": 6,
        "effort": 4
      }
    },
    {
      "name": "Approach 2: Refactor",
      "strategy": "Refactor the entire auth module",
      "steps": ["Step A", "Step B", "Step C"],
      "pros": ["Clean", "Maintainable"],
      "cons": ["Time-consuming"],
      "scores": {
        "feasibility": 6,
        "quality": 9,
        "risk": 3,
        "effort": 8
      }
    },
    {
      "name": "Approach 3: Patch",
      "strategy": "Apply a quick patch",
      "steps": ["Step X", "Step Y"],
      "pros": ["Very fast"],
      "cons": ["Not ideal"],
      "scores": {
        "feasibility": 9,
        "quality": 5,
        "risk": 7,
        "effort": 2
      }
    }
  ]
}'

complete_result=$($TOT complete "$mock_branches" "highest_score" 2>/dev/null || echo '{}')

if echo "$complete_result" | jq -e '.selected_branch' > /dev/null 2>&1; then
    test_result 0 "complete returns selected_branch"
else
    test_result 1 "complete returns selected_branch"
    echo "Got: $complete_result"
fi

# Test 7: complete returns alternatives_considered
echo "Test 7: complete returns alternatives_considered"
if echo "$complete_result" | jq -e '.alternatives_considered == 3' > /dev/null 2>&1; then
    test_result 0 "complete returns correct alternatives count"
else
    test_result 1 "complete returns correct alternatives count"
    alternatives=$(echo "$complete_result" | jq -r '.alternatives_considered // "missing"')
    echo "Expected: 3, Got: $alternatives"
fi

# Test 8: selected_branch has required fields
echo "Test 8: selected_branch has required fields"
has_approach=$(echo "$complete_result" | jq -e '.selected_branch.approach' > /dev/null 2>&1 && echo "yes" || echo "no")
has_steps=$(echo "$complete_result" | jq -e '.selected_branch.steps' > /dev/null 2>&1 && echo "yes" || echo "no")
has_score=$(echo "$complete_result" | jq -e '.selected_branch.evaluation_score' > /dev/null 2>&1 && echo "yes" || echo "no")
has_reasoning=$(echo "$complete_result" | jq -e '.selected_branch.reasoning' > /dev/null 2>&1 && echo "yes" || echo "no")

if [[ "$has_approach" == "yes" && "$has_steps" == "yes" && "$has_score" == "yes" && "$has_reasoning" == "yes" ]]; then
    test_result 0 "selected_branch has all required fields (approach, steps, evaluation_score, reasoning)"
else
    test_result 1 "selected_branch has all required fields"
    echo "  approach: $has_approach, steps: $has_steps, score: $has_score, reasoning: $has_reasoning"
fi

# Test 9: Ranking works correctly (highest score selected)
echo "Test 9: Ranking selects highest score"
selected_approach=$(echo "$complete_result" | jq -r '.selected_branch.approach')
if [[ "$selected_approach" == "Approach 1: Direct Fix" ]]; then
    test_result 0 "Highest scoring approach selected (Approach 1)"
else
    test_result 1 "Highest scoring approach selected"
    echo "Expected: 'Approach 1: Direct Fix', Got: '$selected_approach'"
fi

# Test 10: Risk-averse strategy
echo "Test 10: Risk-averse selection strategy"
risk_averse_result=$($TOT complete "$mock_branches" "risk_averse" 2>/dev/null || echo '{}')
risk_averse_approach=$(echo "$risk_averse_result" | jq -r '.selected_branch.approach')
if [[ "$risk_averse_approach" == "Approach 2: Refactor" ]]; then
    test_result 0 "Risk-averse strategy selects low-risk option (Approach 2)"
else
    test_result 1 "Risk-averse strategy"
    echo "Expected: 'Approach 2: Refactor', Got: '$risk_averse_approach'"
fi

# Test 11: Quick-win strategy
echo "Test 11: Quick-win selection strategy"
quick_win_result=$($TOT complete "$mock_branches" "quick_win" 2>/dev/null || echo '{}')
quick_win_approach=$(echo "$quick_win_result" | jq -r '.selected_branch.approach')
if [[ "$quick_win_approach" == "Approach 1: Direct Fix" ]]; then
    test_result 0 "Quick-win strategy selects low-effort option (Approach 1)"
else
    test_result 1 "Quick-win strategy"
    echo "Expected: 'Approach 1: Direct Fix', Got: '$quick_win_approach'"
fi

# Test 12: Verify rank → select pipeline
echo "Test 12: rank → select pipeline integration"
ranked=$($TOT rank "$mock_branches" 2>/dev/null || echo '[]')
if echo "$ranked" | jq -e 'type == "array"' > /dev/null 2>&1; then
    test_result 0 "rank returns array"

    # Verify select works with ranked output
    selected=$($TOT select "$ranked" "highest_score" 2>/dev/null || echo '{}')
    if echo "$selected" | jq -e '.name' > /dev/null 2>&1; then
        test_result 0 "select works with rank output (returns object)"
    else
        test_result 1 "select works with rank output"
        echo "Got: $selected"
    fi
else
    test_result 1 "rank returns array"
    echo "Got: $ranked"
fi

# Test 13: Weighted scoring
echo "Test 13: Custom weighted scoring"
custom_weights="feasibility:0.5,quality:0.3,risk:0.1,effort:0.1"
weighted_result=$($TOT complete "$mock_branches" "highest_score" "$custom_weights" 2>/dev/null || echo '{}')
if echo "$weighted_result" | jq -e '.selected_branch.evaluation_score' > /dev/null 2>&1; then
    test_result 0 "Custom weights applied successfully"
else
    test_result 1 "Custom weights applied"
fi

# Test 14: Verify old functions still work (backward compatibility)
echo "Test 14: Backward compatibility - individual functions"
gen_result=$($TOT generate "test problem" "test context" 3 2>/dev/null || echo '{}')
if echo "$gen_result" | jq -e '.problem' > /dev/null 2>&1; then
    test_result 0 "generate function still works"
else
    test_result 1 "generate function still works"
fi

echo ""
echo "========================================="
echo "Test Results"
echo "========================================="
echo -e "${GREEN}Passed: $passed${NC}"
echo -e "${RED}Failed: $failed${NC}"
echo ""

if [[ $failed -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
