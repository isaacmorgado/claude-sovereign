# Autonomous Orchestrator V2 → ReflexionAgent Integration Design

**Date**: 2026-01-13 22:13
**Status**: Design Phase
**Purpose**: Design integration strategy for calling ReflexionCommand from autonomous-orchestrator-v2.sh

---

## Overview

This document details how to integrate the ReflexionCommand CLI into autonomous-orchestrator-v2.sh's task execution decision tree. The goal is to use ReflexionAgent for complex tasks requiring self-correction while keeping bash hooks for simple coordination.

---

## Current Architecture Analysis

### Orchestrator Flow (autonomous-orchestrator-v2.sh)

```
orchestrate()
  ├─ check_continuation() → Priority 1: Continuation prompts
  ├─ check_current_build() → Priority 2: In-progress builds
  ├─ check_buildguide() → Priority 3: Buildguide tasks
  │   ├─ populate_task_queue() → Extract tasks from buildguide
  │   ├─ analyze_task() → Analyze task complexity/type
  │   └─ start_agent_loop() → Execute via agent-loop.sh
  └─ check_active_task() → Priority 4: Active memory tasks
```

### Key Functions

1. **analyze_task()** (lines 171-331):
   - Determines task type (feature/bugfix/refactor/test)
   - Detects unfamiliar libraries (auto-research)
   - Detects RE tools needed
   - Returns JSON recommendation with strategy/confidence/risk

2. **start_agent_loop()** (lines 338-363):
   - Starts agent-loop.sh for task execution
   - Returns agent ID for tracking

3. **execute_actions()** (lines 497-548):
   - Parses orchestrator decisions
   - Executes corresponding actions

### ReflexionCommand Interface (src/cli/commands/ReflexionCommand.ts)

```bash
bun run src/index.ts reflexion execute \
  --goal "task description" \
  --max-iterations 30 \
  --preferred-model glm-4.7 \
  --output-json
```

**Output Format**:
```json
{
  "status": "complete",
  "iterations": 12,
  "metrics": {
    "filesCreated": 3,
    "filesModified": 2,
    "linesChanged": 145,
    "iterations": 12,
    "goalAlignment": true
  }
}
```

---

## Integration Strategy

### Decision Logic: When to Use ReflexionAgent?

Add `should_use_reflexion_agent()` function to determine execution strategy:

```bash
should_use_reflexion_agent() {
    local task="$1"
    local analysis="$2"  # JSON from analyze_task()

    # Extract complexity indicators from analysis
    local task_type=$(echo "$analysis" | jq -r '.taskType')
    local risk_score=$(echo "$analysis" | jq -r '.risk // 10')
    local confidence=$(echo "$analysis" | jq -r '.confidence // 0')

    # Use ReflexionAgent if:
    # 1. Complex implementation tasks (multi-file, logic-heavy)
    # 2. Tasks requiring self-correction (high risk, low confidence)
    # 3. Tasks with explicit iteration requirements
    # 4. Feature implementations (not simple bugfixes)

    # Rule 1: High-risk tasks (risk > 5) with low confidence (< 50)
    if [[ $(echo "$risk_score > 5" | bc -l) -eq 1 ]] && \
       [[ $(echo "$confidence < 0.5" | bc -l) -eq 1 ]]; then
        echo '{"useReflexion":true,"reason":"high_risk_low_confidence"}'
        return 0
    fi

    # Rule 2: Feature implementation tasks
    if [[ "$task_type" == "feature" ]]; then
        # Check for complexity indicators
        if echo "$task" | grep -qiE "implement.*with|create.*multiple|build.*system"; then
            echo '{"useReflexion":true,"reason":"complex_feature"}'
            return 0
        fi
    fi

    # Rule 3: Multi-file tasks (detect keywords)
    if echo "$task" | grep -qiE "multiple files|across.*files|[0-9]+.*files"; then
        echo '{"useReflexion":true,"reason":"multi_file_task"}'
        return 0
    fi

    # Rule 4: Tasks with explicit iteration/refinement requirements
    if echo "$task" | grep -qiE "refine|iterate|improve.*until|self-correct"; then
        echo '{"useReflexion":true,"reason":"explicit_iteration"}'
        return 0
    fi

    # Default: Use bash agent-loop
    echo '{"useReflexion":false,"reason":"simple_task"}'
    return 1
}
```

### New Function: execute_with_reflexion_agent()

```bash
execute_with_reflexion_agent() {
    local goal="$1"
    local max_iterations="${2:-30}"
    local preferred_model="${3:-glm-4.7}"  # Default to GLM-4.7 to avoid Kimi rate limits

    log "Executing with ReflexionAgent: $goal (max: $max_iterations, model: $preferred_model)"

    # Change to project directory (ReflexionAgent uses cwd for file operations)
    cd "$PROJECT_DIR" || return 1

    # Execute ReflexionCommand
    local output
    output=$(bun run src/index.ts reflexion execute \
        --goal "$goal" \
        --max-iterations "$max_iterations" \
        --preferred-model "$preferred_model" \
        --output-json 2>&1)

    local exit_code=$?

    # Check for rate limit errors
    if echo "$output" | grep -q "concurrency limit\|rate limit\|quota"; then
        log "⚠️  Rate limit hit, falling back to bash agent-loop"
        return 1  # Signal fallback needed
    fi

    # Parse JSON output (last line should be final metrics)
    local metrics
    metrics=$(echo "$output" | tail -1 | jq '.' 2>/dev/null)

    if [[ $exit_code -eq 0 ]] && [[ -n "$metrics" ]]; then
        log "✅ ReflexionAgent completed successfully"
        echo "$metrics" | jq -c '{
            executor: "reflexion_agent",
            status: .status,
            iterations: .iterations,
            metrics: .metrics
        }'
        return 0
    else
        log "❌ ReflexionAgent failed (exit: $exit_code)"
        return 1  # Signal fallback needed
    fi
}
```

### Modified execute_actions() Integration

Update `execute_actions()` to call ReflexionAgent when appropriate:

```bash
execute_actions() {
    local actions_json="$1"

    # Parse and execute each action
    echo "$actions_json" | jq -r '.actions[]' | while read -r action; do
        case "$action" in
            start_task:*)
                # Extract task ID and name
                local task_id=$(echo "$action" | cut -d: -f2)
                local task_name=$(echo "$action" | cut -d: -f3-)

                # Mark task as started
                [[ -x "$TASK_QUEUE" ]] && "$TASK_QUEUE" start "$task_id" 2>/dev/null || true

                # Analyze task
                local analysis=$(analyze_task "$task_name")

                # ===== NEW DECISION POINT =====
                local reflexion_decision=$(should_use_reflexion_agent "$task_name" "$analysis")
                local use_reflexion=$(echo "$reflexion_decision" | jq -r '.useReflexion')

                if [[ "$use_reflexion" == "true" ]] && [[ "$ENABLE_REFLEXION_AGENT" == "1" ]]; then
                    log "Using ReflexionAgent for: $task_name"

                    # Execute with ReflexionAgent
                    local reflexion_result
                    reflexion_result=$(execute_with_reflexion_agent "$task_name" 30 "glm-4.7")

                    if [[ $? -eq 0 ]]; then
                        # Success - mark task complete
                        [[ -x "$TASK_QUEUE" ]] && "$TASK_QUEUE" complete "$task_id" 2>/dev/null || true
                        log "Task completed via ReflexionAgent: $task_name"
                    else
                        # Fallback to bash agent-loop
                        log "Falling back to bash agent-loop for: $task_name"
                        local agent_id=$(start_agent_loop "$task_name" "fallback from reflexion")
                    fi
                else
                    # Use traditional bash agent-loop
                    log "Using bash agent-loop for: $task_name"
                    local task_type=$(echo "$analysis" | jq -r '.taskType')
                    local plan_id=$(create_execution_plan "$task_name" "$task_type")
                    local agent_id=$(start_agent_loop "$task_name" "plan:$plan_id")
                fi
                ;;

            # ... other cases unchanged ...
        esac
    done
}
```

### Feature Flag

Add at top of autonomous-orchestrator-v2.sh:

```bash
# Feature flag: Enable ReflexionAgent integration (default: off)
ENABLE_REFLEXION_AGENT="${ENABLE_REFLEXION_AGENT:-0}"

# Log feature flag status
if [[ "$ENABLE_REFLEXION_AGENT" == "1" ]]; then
    log "ReflexionAgent integration: ENABLED"
else
    log "ReflexionAgent integration: DISABLED (set ENABLE_REFLEXION_AGENT=1 to enable)"
fi
```

---

## Integration Points Summary

### Files to Modify

1. **~/.claude/hooks/autonomous-orchestrator-v2.sh**:
   - Add `ENABLE_REFLEXION_AGENT` feature flag (line ~7)
   - Add `should_use_reflexion_agent()` function (after line 393)
   - Add `execute_with_reflexion_agent()` function (after line 393)
   - Modify `execute_actions()` start_task case (lines 503-528)

### New Dependencies

- None (uses existing Bun installation and ReflexionCommand)

### Configuration

**Enable feature**:
```bash
export ENABLE_REFLEXION_AGENT=1
```

**Default model** (to avoid Kimi-K2 rate limits):
```bash
# Hardcoded in execute_with_reflexion_agent() as glm-4.7
```

---

## Testing Strategy

### Unit Tests

Create `tests/orchestrator/reflexion-integration.test.ts`:

```typescript
describe('Orchestrator → ReflexionAgent Integration', () => {
  test('should_use_reflexion_agent: simple task → false', () => {
    // Task: "Fix typo in README.md"
    // Expected: Use bash agent-loop
  });

  test('should_use_reflexion_agent: complex feature → true', () => {
    // Task: "Implement authentication system with JWT"
    // Expected: Use ReflexionAgent
  });

  test('should_use_reflexion_agent: multi-file task → true', () => {
    // Task: "Create REST API with 5 files"
    // Expected: Use ReflexionAgent
  });

  test('execute_with_reflexion_agent: successful execution', () => {
    // Execute simple task
    // Verify JSON output parsed correctly
  });

  test('execute_with_reflexion_agent: rate limit fallback', () => {
    // Simulate rate limit error
    // Verify falls back to bash agent-loop
  });
});
```

### Integration Tests

Create `tests/orchestrator/end-to-end-reflexion.test.sh`:

```bash
#!/bin/bash
# End-to-end test: Orchestrator uses ReflexionAgent for appropriate tasks

test_orchestrator_reflexion_simple() {
  # Setup: buildguide.md with simple task
  echo "- [ ] Fix typo in test.txt" > buildguide.md

  # Execute orchestrator
  ENABLE_REFLEXION_AGENT=1 \
    ~/.claude/hooks/autonomous-orchestrator-v2.sh orchestrate

  # Verify: Should NOT use ReflexionAgent (simple task)
  grep -q "Using bash agent-loop" ~/.claude/orchestrator.log
}

test_orchestrator_reflexion_complex() {
  # Setup: buildguide.md with complex task
  echo "- [ ] Implement REST API with multiple files" > buildguide.md

  # Execute orchestrator
  ENABLE_REFLEXION_AGENT=1 \
    ~/.claude/hooks/autonomous-orchestrator-v2.sh orchestrate

  # Verify: Should use ReflexionAgent
  grep -q "Using ReflexionAgent" ~/.claude/orchestrator.log
}

test_orchestrator_reflexion_fallback() {
  # Setup: Task that will hit rate limits
  # ... (detailed test for fallback behavior)
}
```

---

## Risk Mitigation

### Risk 1: Rate Limits Block ReflexionAgent

**Mitigation**:
- Default to GLM-4.7 (no concurrency limits)
- Automatic fallback to bash agent-loop on rate limit error
- Log fallback events for monitoring

### Risk 2: ReflexionAgent Slower than Bash

**Mitigation**:
- Use only for complex tasks (simple tasks stay with bash)
- Decision logic filters based on complexity indicators
- Feature flag allows disabling if performance unacceptable

### Risk 3: Integration Bugs

**Mitigation**:
- Comprehensive unit/integration tests
- Feature flag for gradual rollout
- Fallback mechanism ensures orchestrator never blocked

### Risk 4: Model Selection Issues

**Mitigation**:
- Hardcode GLM-4.7 as default (proven reliable in edge case testing)
- Avoid Kimi-K2 for orchestrator-triggered tasks (save quota for interactive use)
- Document model selection rationale

---

## Success Metrics

### Technical Metrics
- [ ] ReflexionAgent triggered for 80%+ of complex tasks
- [ ] Fallback rate < 10% (excluding intentional rate limit scenarios)
- [ ] Performance overhead < 5s per task (acceptable for complex tasks)
- [ ] Zero orchestrator crashes due to ReflexionAgent integration

### Quality Metrics
- [ ] Tasks completed via ReflexionAgent have 90%+ success rate
- [ ] Stagnation detection triggers < 5% of ReflexionAgent runs
- [ ] Files created by ReflexionAgent pass linting/typechecking

---

## Implementation Checklist

### Phase 2A: Code Integration (This Session)
- [ ] Add feature flag to autonomous-orchestrator-v2.sh
- [ ] Implement should_use_reflexion_agent() function
- [ ] Implement execute_with_reflexion_agent() function
- [ ] Modify execute_actions() start_task case
- [ ] Test decision logic with sample tasks

### Phase 2B: Testing (After API Quota Reset)
- [ ] Create orchestrator integration test suite
- [ ] Run unit tests for decision logic
- [ ] Run end-to-end tests with buildguide
- [ ] Validate fallback behavior
- [ ] Performance benchmarking

### Phase 2C: Documentation (This Session)
- [ ] Update REFLEXION-ORCHESTRATOR-INTEGRATION-PLAN.md
- [ ] Document configuration options
- [ ] Add troubleshooting guide
- [ ] Update CLAUDE.md with integration details

---

## Next Actions

**Immediate (This Session)**:
1. Implement functions in autonomous-orchestrator-v2.sh
2. Add feature flag and logging
3. Create orchestrator integration test structure

**After API Quota Reset (~23h)**:
1. Run edge case tests (validate 30-50 iterations)
2. Run orchestrator integration tests
3. End-to-end validation with /auto mode

**Post-Validation**:
1. Enable feature flag by default (ENABLE_REFLEXION_AGENT=1)
2. Monitor production usage
3. Collect metrics for performance analysis

---

## Open Questions

**Q1: Should orchestrator pass task analysis to ReflexionAgent?**
**Answer**: No initially. ReflexionAgent generates its own analysis. Future enhancement could pass context.

**Q2: How to handle partial completion (agent stops mid-task)?**
**Answer**: ReflexionAgent metrics show files created/modified. Orchestrator can detect partial completion and decide to resume or restart.

**Q3: Should we limit max iterations for orchestrator-triggered tasks?**
**Answer**: Yes. Use 30 max iterations (default). Complex tasks typically complete in 15-25 iterations based on testing.

**Q4: What if task analysis says "use ReflexionAgent" but feature flag is off?**
**Answer**: Fall back to bash agent-loop silently. Log the decision for monitoring.

---

## Conclusion

This integration design provides:
- ✅ **Clean separation**: ReflexionAgent for complex tasks, bash for simple coordination
- ✅ **Automatic fallback**: Rate limits/errors trigger bash agent-loop fallback
- ✅ **Feature flag control**: Gradual rollout with ENABLE_REFLEXION_AGENT
- ✅ **Intelligent routing**: Decision logic based on complexity/risk/type
- ✅ **Production-ready**: GLM-4.7 default avoids Kimi-K2 rate limits

**Recommendation**: Proceed with Phase 2A implementation this session.

---

**Document Status**: Design Complete
**Next Phase**: Implementation (Phase 2A)
**Owner**: Autonomous System (/auto mode)
