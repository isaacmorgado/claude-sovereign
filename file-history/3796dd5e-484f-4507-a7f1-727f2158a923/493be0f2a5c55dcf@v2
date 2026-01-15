#!/bin/bash
# Comprehensive Test Suite for Autonomous AI Features

set -e

PASSED=0
FAILED=0

test_script() {
    local name="$1"
    local command="$2"
    local expected_pattern="$3"

    echo "Testing: $name"

    if output=$(eval "$command" 2>&1); then
        if echo "$output" | grep -q "$expected_pattern"; then
            echo "  ✅ PASSED"
            ((PASSED++))
            return 0
        else
            echo "  ❌ FAILED: Output didn't match expected pattern"
            echo "  Output: $output"
            ((FAILED++))
            return 1
        fi
    else
        echo "  ❌ FAILED: Command failed with exit code $?"
        echo "  Output: $output"
        ((FAILED++))
        return 1
    fi
}

echo "========================================="
echo "AUTONOMOUS AI FEATURES TEST SUITE"
echo "========================================="
echo ""

# 1. ReAct + Reflexion
test_script "ReAct - Think" \
    "~/.claude/hooks/react-reflexion.sh think 'test goal' 'context' 1 | jq -r '.goal'" \
    "test goal"

test_script "ReAct - Patterns" \
    "~/.claude/hooks/react-reflexion.sh patterns 'test' | jq -r 'type'" \
    "array"

# 2. LLM-as-Judge Auto-Evaluator
test_script "Auto-Evaluator - Criteria" \
    "~/.claude/hooks/auto-evaluator.sh criteria code | jq -r '.criteria.correctness.description'" \
    "Solves problem correctly"

test_script "Auto-Evaluator - Stats" \
    "~/.claude/hooks/auto-evaluator.sh stats | jq -r '.total'" \
    "[0-9]"

# 3. Tree of Thoughts
test_script "ToT - Generate" \
    "~/.claude/hooks/tree-of-thoughts.sh generate 'problem' 'context' 3 | jq -r '.problem'" \
    "problem"

test_script "ToT - MCTS" \
    "~/.claude/hooks/tree-of-thoughts.sh mcts 'problem' 'context' 3 | jq -r '.algorithm'" \
    "monte_carlo_tree_search"

# 4. Multi-Agent Orchestrator
test_script "Multi-Agent - List Agents" \
    "~/.claude/hooks/multi-agent-orchestrator.sh agents | jq -r '.agents.code_writer.description'" \
    "Focused on writing high-quality code"

test_script "Multi-Agent - Route Task" \
    "~/.claude/hooks/multi-agent-orchestrator.sh route 'write tests' | jq -r '.selected_agent'" \
    "test_engineer"

# 5. Bounded Autonomy
test_script "Bounded Autonomy - Rules" \
    "~/.claude/hooks/bounded-autonomy.sh rules | jq -r '.auto_allowed.description'" \
    "Actions that can be taken without approval"

test_script "Bounded Autonomy - Check Action" \
    "~/.claude/hooks/bounded-autonomy.sh check 'read file' 'context' | jq -r '.allowed'" \
    "true"

# 6. Reasoning Mode Switcher
test_script "Reasoning Modes - List" \
    "~/.claude/hooks/reasoning-mode-switcher.sh modes | jq -r '.modes.reflexive.description'" \
    "Fast, intuitive decision-making for simple tasks"

test_script "Reasoning Modes - Select" \
    "~/.claude/hooks/reasoning-mode-switcher.sh select 'task' 'ctx' normal low low | jq -r '.selected_mode'" \
    "reflexive"

# 7. Reinforcement Learning
test_script "RL - Record Outcome" \
    "~/.claude/hooks/reinforcement-learning.sh record 'test_action' 'ctx' 'success' '1.0' | jq -r '.status'" \
    "recorded"

test_script "RL - Success Rate" \
    "~/.claude/hooks/reinforcement-learning.sh success-rate 'test_action' 10 | jq -r '.success_rate'" \
    "[0-9.]"

# 8. Parallel Execution Planner
test_script "Parallel Planner - Simple Test" \
    "~/.claude/hooks/parallel-execution-planner.sh help" \
    "Usage"

# 9. Constitutional AI
test_script "Constitutional AI - Principles" \
    "~/.claude/hooks/constitutional-ai.sh principles | jq -r '.principles[0].name'" \
    "code_quality"

test_script "Constitutional AI - Count Principles" \
    "~/.claude/hooks/constitutional-ai.sh principles | jq -r '.principles | length'" \
    "8"

# 10. Enhanced Audit Trail
test_script "Audit Trail - Log Decision" \
    "~/.claude/hooks/enhanced-audit-trail.sh log 'action' 'reason' 'alt' 'why' '0.8' | jq -r '.action'" \
    "action"

test_script "Audit Trail - Get History" \
    "~/.claude/hooks/enhanced-audit-trail.sh history 5 | jq -r 'type'" \
    "array"

echo ""
echo "========================================="
echo "TEST SUMMARY"
echo "========================================="
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"
echo "Total: $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED!"
    exit 0
else
    echo "⚠️  SOME TESTS FAILED"
    exit 1
fi
