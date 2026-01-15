#!/bin/bash
# Test specific dependency ordering in swarm orchestrator
# Verifies that agents spawn in correct order based on dependencies

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWARM="$SCRIPT_DIR/swarm-orchestrator.sh"
LOG_FILE="${HOME}/.claude/logs/swarm.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Testing Dependency Ordering in Swarm Orchestrator${NC}"
echo "==========================================="

# Clean up
rm -rf ~/.claude/swarm/* 2>/dev/null
rm -f "$LOG_FILE" 2>/dev/null
mkdir -p ~/.claude/logs

# Test 1: Sequential dependency chain (1 → 2 → 3)
echo ""
echo -e "${YELLOW}Test 1: Sequential Chain (agent 2 depends on 1, agent 3 depends on 2)${NC}"

# Create a custom decomposition with sequential dependencies
cat > ~/.claude/swarm/test-decomposition.json <<'EOF'
{
  "task": "Test sequential dependencies",
  "agentCount": 3,
  "decompositionStrategy": "feature",
  "subtasks": [
    {"agentId": 1, "subtask": "Phase 1: Research", "priority": 1, "phase": "research", "dependencies": []},
    {"agentId": 2, "subtask": "Phase 2: Implement", "priority": 2, "phase": "implement", "dependencies": [1]},
    {"agentId": 3, "subtask": "Phase 3: Test", "priority": 3, "phase": "test", "dependencies": [2]}
  ]
}
EOF

# Spawn swarm with feature pattern (has dependencies)
swarm_id=$("$SWARM" spawn 3 "Implement authentication feature" 2>/dev/null | tail -1)
echo "Swarm ID: $swarm_id"

# Wait for completion
sleep 4

# Check logs for spawn order
if [[ -f "$LOG_FILE" ]]; then
    echo ""
    echo "Spawn log analysis:"
    grep "Agent.*spawned with PID" "$LOG_FILE" | tail -3

    # Verify agent 1 spawned first
    agent1_line=$(grep -n "Agent 1 spawned" "$LOG_FILE" | tail -1 | cut -d: -f1)
    agent2_line=$(grep -n "Agent 2 spawned" "$LOG_FILE" | tail -1 | cut -d: -f1)
    agent3_line=$(grep -n "Agent 3 spawned" "$LOG_FILE" | tail -1 | cut -d: -f1)

    echo ""
    if [[ -n "$agent1_line" ]] && [[ -n "$agent2_line" ]] && [[ -n "$agent3_line" ]]; then
        if [[ $agent1_line -lt $agent2_line ]] && [[ $agent2_line -lt $agent3_line ]]; then
            echo -e "${GREEN}✓ PASS${NC}: Agents spawned in correct dependency order (1→2→3)"
        else
            echo -e "${RED}✗ FAIL${NC}: Agents spawned out of order. Lines: 1=$agent1_line, 2=$agent2_line, 3=$agent3_line"
        fi
    else
        echo -e "${YELLOW}⚠ WARN${NC}: Could not find all agent spawn logs"
    fi

    # Check for dependency waiting messages
    echo ""
    echo "Dependency wait messages:"
    grep "waiting for dependency" "$LOG_FILE" | tail -5 || echo "  (none - agents may have completed before dependency checks)"
else
    echo -e "${RED}✗ FAIL${NC}: Log file not found"
fi

# Test 2: Parallel groups with one dependent (1 and 2 parallel, 3 depends on both)
echo ""
echo -e "${YELLOW}Test 2: Diamond Pattern (agents 1,2 parallel, agent 3 depends on both)${NC}"

rm -rf ~/.claude/swarm/* 2>/dev/null
rm -f "$LOG_FILE" 2>/dev/null

cat > ~/.claude/swarm/test-decomposition.json <<'EOF'
{
  "task": "Test parallel with merge",
  "agentCount": 3,
  "decompositionStrategy": "parallel_merge",
  "subtasks": [
    {"agentId": 1, "subtask": "Backend implementation", "priority": 1, "phase": "implement", "dependencies": []},
    {"agentId": 2, "subtask": "Frontend implementation", "priority": 1, "phase": "implement", "dependencies": []},
    {"agentId": 3, "subtask": "Integration testing", "priority": 2, "phase": "test", "dependencies": [1, 2]}
  ]
}
EOF

swarm_id=$("$SWARM" spawn 3 "Build full-stack feature" 2>/dev/null | tail -1)
echo "Swarm ID: $swarm_id"

sleep 4

if [[ -f "$LOG_FILE" ]]; then
    echo ""
    echo "Spawn log analysis:"
    grep "Agent.*spawned with PID" "$LOG_FILE" | tail -3

    agent1_line=$(grep -n "Agent 1 spawned" "$LOG_FILE" | tail -1 | cut -d: -f1)
    agent2_line=$(grep -n "Agent 2 spawned" "$LOG_FILE" | tail -1 | cut -d: -f1)
    agent3_line=$(grep -n "Agent 3 spawned" "$LOG_FILE" | tail -1 | cut -d: -f1)

    echo ""
    if [[ -n "$agent1_line" ]] && [[ -n "$agent2_line" ]] && [[ -n "$agent3_line" ]]; then
        # Agent 3 should spawn after both 1 and 2
        if [[ $agent3_line -gt $agent1_line ]] && [[ $agent3_line -gt $agent2_line ]]; then
            echo -e "${GREEN}✓ PASS${NC}: Agent 3 spawned after dependencies 1 and 2"
            echo "  Agent 1: line $agent1_line"
            echo "  Agent 2: line $agent2_line"
            echo "  Agent 3: line $agent3_line"
        else
            echo -e "${RED}✗ FAIL${NC}: Agent 3 spawned before dependencies completed"
        fi
    else
        echo -e "${YELLOW}⚠ WARN${NC}: Could not find all agent spawn logs"
    fi

    # Check for waiting on multiple dependencies
    echo ""
    echo "Multi-dependency wait messages:"
    grep "Agent 3 waiting" "$LOG_FILE" || echo "  (none found)"
else
    echo -e "${RED}✗ FAIL${NC}: Log file not found"
fi

# Cleanup
"$SWARM" terminate >/dev/null 2>&1 || true
rm -f ~/.claude/swarm/test-decomposition.json 2>/dev/null

echo ""
echo "==========================================="
echo -e "${GREEN}Dependency ordering tests complete${NC}"
