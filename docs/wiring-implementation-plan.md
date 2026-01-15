# /auto Feature Wiring Implementation Plan

**Date**: 2026-01-12
**Purpose**: Wire all documented-but-orphaned features into active execution
**Priority**: High - Make `/auto` work as documented

---

## Summary of Gaps Found

| Feature | Status | Priority | Wiring Needed |
|---------|--------|----------|---------------|
| ✅ ReAct+Reflexion | ACTIVE | - | None - working |
| ✅ Auto-checkpoint at 40% | ENHANCED | - | None - fixed |
| ❌ File change tracking (10 files) | ORPHANED | HIGH | post-edit-quality.sh |
| ❌ Constitutional AI auto-revision | PARTIAL | HIGH | coordinator.sh |
| ❌ Debug Orchestrator | ORPHANED | HIGH | error-handler.sh |
| ⚠️ MCP grep/GitHub | MANUAL | MED | orchestrator heuristics |
| ⏳ UI Testing | TBD | MED | Awaiting audit |
| ⏳ Lint/Typecheck | TBD | MED | Awaiting audit |

---

## Implementation Plan

### 🔴 PRIORITY 1: File Change Tracking

**Current**: `file-change-tracker.sh` exists but never called
**Goal**: Auto-checkpoint every 10 file changes

**File**: `/Users/imorgado/.claude/hooks/post-edit-quality.sh`

**Add after line 50** (after linting logic):

```bash
# 4. File Change Tracking
FILE_CHANGE_TRACKER="${HOME}/.claude/hooks/file-change-tracker.sh"

if [[ -x "$FILE_CHANGE_TRACKER" ]]; then
    # Record file change
    result=$("$FILE_CHANGE_TRACKER" record "$file_path" "modified" 2>/dev/null)

    # Check if checkpoint needed
    if echo "$result" | grep -q "CHECKPOINT_NEEDED"; then
        count=$(echo "$result" | cut -d':' -f2)
        echo "[file-change-tracker] 10 files changed - checkpoint recommended"
        echo "::claude::suggest_checkpoint::File change count reached ${count}/10"

        # Log for manual review or trigger /checkpoint
        log "Checkpoint recommended: $count files changed"
    fi
fi
```

**Test**:
```bash
# Make 10 file edits
for i in {1..10}; do
    echo "test $i" > /tmp/test$i.txt
done

# Check status
~/.claude/hooks/file-change-tracker.sh status
```

---

### 🔴 PRIORITY 2: Constitutional AI Auto-Revision

**Current**: Critique runs, revisions never applied
**Goal**: Auto-revise code when quality < 7.0

**File**: `/Users/imorgado/.claude/hooks/coordinator.sh`

**Replace lines 366-375** (after quality evaluation):

```bash
# OLD CODE (observational only):
critique_prompt=$("$CONSTITUTIONAL_AI" critique "$execution_result" 2>/dev/null || echo '{}')
log "Constitutional AI check complete (8 principles validated)"

# NEW CODE (with auto-revision):
critique_json=$("$CONSTITUTIONAL_AI" critique "$execution_result" all 2>/dev/null || echo '{}')
assessment=$(echo "$critique_json" | jq -r '.overall_assessment // "safe"')
violations=$(echo "$critique_json" | jq -r '.violations | length' 2>/dev/null || echo "0")

if [[ "$assessment" != "safe" ]] && [[ "$violations" -gt 0 ]]; then
    log "Constitutional AI: $violations violations found - initiating auto-revision"

    # Generate revision
    revised=$("$CONSTITUTIONAL_AI" revise "$execution_result" "$critique_json" 2>/dev/null)

    if [[ -n "$revised" && "$revised" != "null" ]]; then
        execution_result="$revised"
        log "Constitutional AI: Auto-revision applied"

        # Re-evaluate quality (max 2 revisions)
        if [[ ${revision_count:-0} -lt 2 ]]; then
            revision_count=$((${revision_count:-0} + 1))
            # Re-run quality check
            eval_score=$("$AUTO_EVALUATOR" evaluate-score "$revised" 2>/dev/null || echo "7.5")
        fi
    else
        log "Constitutional AI: Revision generation failed"
    fi
else
    log "Constitutional AI check complete: $assessment (no violations)"
fi
```

**Test**:
```bash
# Create low-quality code
cat > /tmp/badcode.js <<'EOF'
function f(x){return x+1}  // no spacing, no types, no error handling
EOF

# Run through coordinator
~/.claude/hooks/coordinator.sh coordinate "test revision" <context>
```

---

### 🔴 PRIORITY 3: Debug Orchestrator Integration

**Current**: `debug-orchestrator.sh` never called during errors
**Goal**: Auto-snapshot before/after fixes, detect regressions

**File**: `/Users/imorgado/.claude/hooks/error-handler.sh`

**Add at line 240** (in the retry_operation function):

```bash
# === Debug Orchestrator Integration ===
DEBUG_ORCHESTRATOR="${HOME}/.claude/hooks/debug-orchestrator.sh"

if [[ -x "$DEBUG_ORCHESTRATOR" ]]; then
    # BEFORE FIX: Create snapshot + search for similar bugs
    log "Running smart-debug before fix attempt..."
    debug_info=$("$DEBUG_ORCHESTRATOR" smart-debug \
        "$error_msg" \
        "$error_type" \
        "$command" \
        "$context" 2>/dev/null || echo "{}")

    snapshot_id=$(echo "$debug_info" | jq -r '.snapshot_id // ""')
    suggestions=$(echo "$debug_info" | jq -r '.suggestions // []')

    log "Debug snapshot created: $snapshot_id"
    log "Found $(echo "$suggestions" | jq 'length') similar bug fixes"
fi

# ... (execute the fix) ...

# AFTER FIX: Verify no regressions
if [[ -x "$DEBUG_ORCHESTRATOR" ]] && [[ -n "$snapshot_id" ]]; then
    log "Running verify-fix to check for regressions..."
    verification=$("$DEBUG_ORCHESTRATOR" verify-fix \
        "$snapshot_id" \
        "$command" \
        "$fix_description" 2>/dev/null || echo "{}")

    regressions=$(echo "$verification" | jq -r '.regressions_detected // false')

    if [[ "$regressions" == "true" ]]; then
        log "⚠️  REGRESSION DETECTED - Fix broke other tests"
        regression_list=$(echo "$verification" | jq -r '.regressions[]')
        log "Regressions: $regression_list"

        # Recommend revert
        echo "::claude::regression_detected::$snapshot_id"
    else
        log "✅ No regressions detected"

        # Record successful fix
        "$DEBUG_ORCHESTRATOR" record-fix "$error_type" "$error_msg" "$fix_description" "success"
    fi
fi
```

**Test**:
```bash
# Simulate error
~/.claude/hooks/error-handler.sh classify "npm ERR! test failed" "test_error"

# Check if snapshot was created
ls -la ~/.claude/.debug/test-snapshots/
```

---

### 🟡 PRIORITY 4: MCP Tool Auto-Invocation (Optional)

**Current**: MCP tools invoked manually by Claude
**Goal**: Auto-search GitHub when encountering unfamiliar APIs

**File**: `/Users/imorgado/.claude/hooks/autonomous-orchestrator.sh`

**Add function** (after line 209):

```bash
# Auto-research heuristic
should_research() {
    local task="$1"

    # Heuristics for when to auto-search GitHub
    if echo "$task" | grep -qiE "(implement|integrate|add|use).*\
(library|package|api|sdk|framework|authentication|oauth|stripe|aws|firebase)"; then
        return 0  # YES - research needed
    fi

    return 1  # NO - proceed without research
}

# In the orchestrate() function, add before RESUME_BUILD:
if should_research "$goal"; then
    decisions+=("AUTO_RESEARCH:github")
fi
```

**In the prompt generation** (line 160), add:

```bash
if echo "$decisions" | grep -q "AUTO_RESEARCH"; then
    cat << 'PROMPT'
### Auto-Research: Unfamiliar API Detected
1. Use mcp__grep__searchGitHub to find production examples
2. Search for: "[library name] [authentication/integration pattern]"
3. Review 3-5 real implementations before coding
4. Adapt patterns to your use case

PROMPT
fi
```

---

### 🟡 PRIORITY 5: Lint/Typecheck After Edit (Awaiting Audit)

**Current Status**: Checking if post-edit-quality.sh runs linting
**Goal**: Auto-lint and auto-typecheck after every file write

**Preliminary Check**:
```bash
grep -A 20 "lint" ~/.claude/hooks/post-edit-quality.sh
```

**If missing, add**:
```bash
# Auto-lint
if command -v eslint &>/dev/null && [[ "$file_path" =~ \.(ts|tsx|js|jsx)$ ]]; then
    eslint --fix "$file_path" 2>&1 | head -20
fi

# Auto-typecheck
if command -v tsc &>/dev/null && [[ "$file_path" =~ \.(ts|tsx)$ ]]; then
    tsc --noEmit "$file_path" 2>&1 | head -20
fi
```

---

### 🟡 PRIORITY 6: UI Testing After UI Changes (Awaiting Audit)

**Current Status**: Checking if ui-test-framework.sh exists
**Goal**: Auto-run UI tests after modifying React components

**If ui-test-framework.sh exists**, add to post-edit-quality.sh:

```bash
# Auto UI test
UI_TEST="${HOME}/.claude/hooks/ui-test-framework.sh"

if [[ -x "$UI_TEST" ]] && echo "$file_path" | grep -qE "(components?|pages?|views?)/.*\.(tsx|jsx)$"; then
    log "UI component modified - running UI tests"

    # Find associated test suite
    component_name=$(basename "$file_path" .tsx)
    suite_name="${component_name}_tests"

    # Run test suite if exists
    if "$UI_TEST" list-suites | grep -q "$suite_name"; then
        "$UI_TEST" run-suite "$suite_name" false  # no GIF
    fi
fi
```

---

## Testing Checklist

After implementing all wiring:

### Phase 1: Unit Tests
- [ ] File-change-tracker records changes
- [ ] 10 file edits trigger checkpoint message
- [ ] Constitutional AI generates critiques
- [ ] Low-quality code triggers revision
- [ ] Debug orchestrator creates snapshots
- [ ] Regressions are detected

### Phase 2: Integration Tests
- [ ] /auto mode runs without errors
- [ ] Checkpoint at 40% context works
- [ ] Quality gates block bad code
- [ ] Error handler invokes debug orchestrator
- [ ] Logs show all features active

### Phase 3: End-to-End Test
```bash
# Start /auto mode
/auto

# Make 10 file changes -> should trigger checkpoint
# Introduce bug -> should create snapshot
# Fix bug incorrectly -> should detect regression
# Write low-quality code -> should auto-revise
# Reach 40% context -> should checkpoint and compact
```

---

## Rollback Plan

If any wiring breaks things:

```bash
# Backup before changes
cp -r ~/.claude/hooks ~/.claude/hooks.backup.$(date +%s)

# Rollback if needed
rm -rf ~/.claude/hooks
mv ~/.claude/hooks.backup.XXXXX ~/.claude/hooks
```

---

## Success Criteria

✅ **All features wired when**:
1. File-change-tracker logs show 10-file checkpoint triggers
2. Constitutional AI log shows revisions applied
3. Debug orchestrator creates snapshots and detects regressions
4. post-edit-quality.sh runs lint/typecheck
5. UI tests run after component edits
6. All logs show activity from recent sessions

---

## Next Actions

1. ⏳ Wait for lint/typecheck and UI testing audit results
2. ✍️ Implement Priority 1-3 wiring (file-change, auto-revision, debug)
3. 📋 Update remaining wiring based on audit results
4. 🧪 Run full test suite
5. 📝 Update documentation to reflect active features
6. ✅ Mark all tasks complete

---

## Timeline

- **Immediate** (< 30 min): Priorities 1-3
- **After audits** (< 1 hour): Priorities 4-6
- **Testing** (< 30 min): Full integration test
- **Documentation** (< 15 min): Update CLAUDE.md

**Total**: ~2.5 hours to fully wire everything

---

## Files to Modify

1. `/Users/imorgado/.claude/hooks/post-edit-quality.sh` - Add file-change-tracker
2. `/Users/imorgado/.claude/hooks/coordinator.sh` - Add auto-revision loop
3. `/Users/imorgado/.claude/hooks/error-handler.sh` - Add debug orchestrator
4. `/Users/imorgado/.claude/hooks/autonomous-orchestrator.sh` - Add auto-research (optional)
5. `/Users/imorgado/.claude/CLAUDE.md` - Update feature status
6. `/Users/imorgado/.claude/commands/auto.md` - Mark features as active

---

## Monitoring After Implementation

Watch these logs for activity:
```bash
# Real-time monitoring
tail -f ~/.claude/file-change-tracker.log
tail -f ~/.claude/constitutional-ai.log
tail -f ~/.claude/debug-orchestrator.log
tail -f ~/.claude/post-edit-quality.log

# Check state files
cat ~/.claude/.claude/file-changes.json
ls -la ~/.claude/.debug/test-snapshots/
cat ~/.claude/.debug/regressions.jsonl
```

---

## Done!

This plan wires all documented features into active execution, making `/auto` work as advertised.
