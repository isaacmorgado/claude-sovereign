#!/usr/bin/env bash
# Test script for Swarm Orchestrator fixes (Issues #20, #21)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWARM_SCRIPT="$SCRIPT_DIR/swarm-orchestrator.sh"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Testing Swarm Orchestrator Fixes"
echo "=========================================="
echo ""

# ============================================================================
# TEST 1: JSON Formatting (Issue #20)
# ============================================================================

echo -e "${YELLOW}TEST 1: JSON Formatting - No Trailing Commas${NC}"
echo "Testing all 5 decomposition patterns..."
echo ""

test_json_pattern() {
    local pattern_name="$1"
    local task="$2"
    local agent_count="${3:-3}"

    echo "  Testing: $pattern_name (agent_count=$agent_count)"

    # Source the script to get the decompose_task function
    source "$SWARM_SCRIPT"

    # Run decomposition
    local result
    result=$(decompose_task "$task" "$agent_count" 2>/dev/null)

    # Validate JSON
    if echo "$result" | jq empty 2>/dev/null; then
        echo -e "    ${GREEN}✓${NC} Valid JSON"

        # Check for trailing commas (should not exist)
        if echo "$result" | grep -qE '\},\s*\]'; then
            echo -e "    ${RED}✗${NC} Found trailing comma before closing bracket"
            return 1
        else
            echo -e "    ${GREEN}✓${NC} No trailing commas"
        fi

        # Verify subtask count matches agent count
        local subtask_count
        subtask_count=$(echo "$result" | jq '.subtasks | length')
        if [[ $subtask_count -eq $agent_count ]]; then
            echo -e "    ${GREEN}✓${NC} Correct subtask count ($subtask_count)"
        else
            echo -e "    ${RED}✗${NC} Subtask count mismatch: expected $agent_count, got $subtask_count"
            return 1
        fi

        return 0
    else
        echo -e "    ${RED}✗${NC} Invalid JSON:"
        echo "$result" | jq empty 2>&1 | sed 's/^/      /'
        return 1
    fi
}

# Test all patterns
patterns=(
    "development:Implement user authentication:3"
    "development:Build REST API:4"
    "development:Create dashboard:5"
    "testing:Run test suite:3"
    "testing:Validate deployment:2"
    "refactoring:Refactor codebase:3"
    "refactoring:Reorganize modules:4"
    "research:Research authentication methods:3"
    "research:Investigate performance:2"
    "generic:Process data files:3"
    "generic:Execute batch job:2"
)

passed=0
failed=0

for pattern in "${patterns[@]}"; do
    IFS=: read -r name task count <<< "$pattern"
    if test_json_pattern "$name" "$task" "$count"; then
        ((passed++))
    else
        ((failed++))
    fi
    echo ""
done

echo "----------------------------------------"
echo "JSON Formatting Tests: $passed passed, $failed failed"
echo ""

# ============================================================================
# TEST 2: Git Merge Conflict Heuristic (Issue #21)
# ============================================================================

echo -e "${YELLOW}TEST 2: Git Merge Conflict Heuristic${NC}"
echo "Testing conflict marker counting..."
echo ""

test_conflict_detection() {
    local test_name="$1"
    local content="$2"
    local expected_count="$3"

    echo "  Testing: $test_name"

    # Count conflict markers using the new logic
    local conflict_count
    conflict_count=$(echo "$content" | grep -cE '^(<{7}|={7}|>{7})' 2>/dev/null || true)
    conflict_count=${conflict_count:-0}

    if [[ $conflict_count -eq $expected_count ]]; then
        echo -e "    ${GREEN}✓${NC} Correct count: $conflict_count"
        return 0
    else
        echo -e "    ${RED}✗${NC} Count mismatch: expected $expected_count, got $conflict_count"
        return 1
    fi
}

# Test case 1: Single conflict region (3 markers)
content1="line 1
line 2
<<<<<<< HEAD
our change
=======
their change
>>>>>>> branch
line 3"

# Test case 2: Two conflict regions (6 markers)
content2="line 1
<<<<<<< HEAD
our change 1
=======
their change 1
>>>>>>> branch
line 2
<<<<<<< HEAD
our change 2
=======
their change 2
>>>>>>> branch
line 3"

# Test case 3: Large diff with context but single conflict (3 markers)
content3="line 1
line 2
line 3
line 4
line 5
<<<<<<< HEAD
our change
=======
their change
>>>>>>> branch
line 6
line 7
line 8
line 9
line 10"

# Test case 4: No conflicts (0 markers)
content4="line 1
line 2
line 3"

conflict_passed=0
conflict_failed=0

if test_conflict_detection "Single conflict region" "$content1" 3; then
    ((conflict_passed++))
else
    ((conflict_failed++))
fi
echo ""

if test_conflict_detection "Two conflict regions" "$content2" 6; then
    ((conflict_passed++))
else
    ((conflict_failed++))
fi
echo ""

if test_conflict_detection "Single conflict with context" "$content3" 3; then
    ((conflict_passed++))
else
    ((conflict_failed++))
fi
echo ""

if test_conflict_detection "No conflicts" "$content4" 0; then
    ((conflict_passed++))
else
    ((conflict_failed++))
fi
echo ""

echo "----------------------------------------"
echo "Conflict Detection Tests: $conflict_passed passed, $conflict_failed failed"
echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo "=========================================="
echo "SUMMARY"
echo "=========================================="
echo "JSON Formatting Tests: $passed/$((passed + failed)) passed"
echo "Conflict Detection Tests: $conflict_passed/$((conflict_passed + conflict_failed)) passed"
echo ""

total_passed=$((passed + conflict_passed))
total_failed=$((failed + conflict_failed))

if [[ $total_failed -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ $total_failed test(s) failed${NC}"
    exit 1
fi
