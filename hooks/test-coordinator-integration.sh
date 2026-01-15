#!/bin/bash
# Test coordinator integration with parallel execution planner
# Verifies auto-spawn swarm when 3+ groups detected

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COORDINATOR="$SCRIPT_DIR/coordinator.sh"
PLANNER="$SCRIPT_DIR/parallel-execution-planner.sh"
LOG_FILE="${HOME}/.claude/coordinator.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Testing Coordinator Integration with Parallel Planner${NC}"
echo "==========================================="

# Test 1: Planner analysis triggers swarm recommendation
echo ""
echo -e "${YELLOW}Test 1: Planner recommends swarm for 3+ groups${NC}"

result=$("$PLANNER" analyze "Test API endpoints and validate schemas and check security and verify performance" 2>/dev/null)
can_parallelize=$(echo "$result" | jq -r '.canParallelize')
group_count=$(echo "$result" | jq -r '.analysis.groupCount')
recommendations=$(echo "$result" | jq -r '.recommendations[]' | grep -i swarm || echo "")

echo "Parallelizable: $can_parallelize"
echo "Group count: $group_count"
echo "Recommendations: $recommendations"

if [[ "$can_parallelize" == "true" ]] && [[ $group_count -ge 3 ]] && [[ -n "$recommendations" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Planner correctly recommends swarm for $group_count groups"
else
    echo -e "${RED}✗ FAIL${NC}: Planner should recommend swarm for 3+ groups"
fi

# Test 2: Verify coordinator has correct planner integration
echo ""
echo -e "${YELLOW}Test 2: Coordinator integrates parallel planner${NC}"

if grep -q "PARALLEL_EXECUTION_PLANNER" "$COORDINATOR"; then
    echo -e "${GREEN}✓ PASS${NC}: Coordinator has PARALLEL_EXECUTION_PLANNER defined"
else
    echo -e "${RED}✗ FAIL${NC}: Coordinator missing PARALLEL_EXECUTION_PLANNER"
fi

if grep -q "parallel_analysis" "$COORDINATOR"; then
    echo -e "${GREEN}✓ PASS${NC}: Coordinator performs parallel_analysis"
else
    echo -e "${RED}✗ FAIL${NC}: Coordinator missing parallel_analysis logic"
fi

if grep -q "AUTO-SPAWN SWARM" "$COORDINATOR"; then
    echo -e "${GREEN}✓ PASS${NC}: Coordinator has AUTO-SPAWN SWARM logic"
else
    echo -e "${RED}✗ FAIL${NC}: Coordinator missing AUTO-SPAWN SWARM"
fi

# Test 3: Verify swarm spawn threshold (3+ groups)
echo ""
echo -e "${YELLOW}Test 3: Swarm auto-spawn threshold (3+ groups)${NC}"

threshold_check=$(grep -A 2 "AUTO-SPAWN SWARM" "$COORDINATOR" | grep -E '\[.*-ge 3.*\]' || echo "")
if [[ -n "$threshold_check" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Coordinator checks for 3+ groups before auto-spawning"
    echo "  Found: $threshold_check"
else
    echo -e "${RED}✗ FAIL${NC}: Coordinator threshold check not found or incorrect"
fi

# Test 4: Planner output format compatibility
echo ""
echo -e "${YELLOW}Test 4: Planner output format matches coordinator expectations${NC}"

result=$("$PLANNER" analyze "Build feature A and feature B and feature C" 2>/dev/null)

# Check required fields
has_can_parallelize=$(echo "$result" | jq -e '.canParallelize' >/dev/null 2>&1 && echo "yes" || echo "no")
has_groups=$(echo "$result" | jq -e '.groups' >/dev/null 2>&1 && echo "yes" || echo "no")
has_strategy=$(echo "$result" | jq -e '.strategy' >/dev/null 2>&1 && echo "yes" || echo "no")
has_analysis=$(echo "$result" | jq -e '.analysis' >/dev/null 2>&1 && echo "yes" || echo "no")

echo "  canParallelize field: $has_can_parallelize"
echo "  groups field: $has_groups"
echo "  strategy field: $has_strategy"
echo "  analysis field: $has_analysis"

if [[ "$has_can_parallelize" == "yes" ]] && [[ "$has_groups" == "yes" ]] && [[ "$has_strategy" == "yes" ]] && [[ "$has_analysis" == "yes" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Planner output format complete"
else
    echo -e "${RED}✗ FAIL${NC}: Planner output missing required fields"
fi

# Test 5: End-to-end simulation
echo ""
echo -e "${YELLOW}Test 5: Simulated end-to-end workflow${NC}"

task="Implement authentication and authorization and notifications"
result=$("$PLANNER" analyze "$task" 2>/dev/null)
can_parallelize=$(echo "$result" | jq -r '.canParallelize')
group_count=$(echo "$result" | jq -r '.analysis.groupCount')

echo "Task: $task"
echo "Planner says: canParallelize=$can_parallelize, groups=$group_count"

if [[ "$can_parallelize" == "true" ]] && [[ $group_count -ge 3 ]]; then
    echo -e "${GREEN}✓ PASS${NC}: End-to-end: Task would trigger swarm auto-spawn"
    echo "  Coordinator would spawn $group_count agents"
else
    echo -e "${YELLOW}⚠ WARN${NC}: Task did not meet swarm threshold (needs 3+ groups)"
fi

# Test 6: Verify groups have proper structure
echo ""
echo -e "${YELLOW}Test 6: Group structure validation${NC}"

groups=$(echo "$result" | jq -r '.groups')
if [[ -n "$groups" ]] && [[ "$groups" != "[]" ]]; then
    # Check first group has required fields
    has_id=$(echo "$groups" | jq -e '.[0].id' >/dev/null 2>&1 && echo "yes" || echo "no")
    has_name=$(echo "$groups" | jq -e '.[0].name' >/dev/null 2>&1 && echo "yes" || echo "no")
    has_deps=$(echo "$groups" | jq -e '.[0].dependencies' >/dev/null 2>&1 && echo "yes" || echo "no")

    echo "  Group has id: $has_id"
    echo "  Group has name: $has_name"
    echo "  Group has dependencies: $has_deps"

    if [[ "$has_id" == "yes" ]] && [[ "$has_name" == "yes" ]] && [[ "$has_deps" == "yes" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: Group structure valid"
    else
        echo -e "${RED}✗ FAIL${NC}: Group structure incomplete"
    fi
else
    echo -e "${YELLOW}⚠ WARN${NC}: No groups generated"
fi

echo ""
echo "==========================================="
echo -e "${GREEN}Coordinator integration tests complete${NC}"
