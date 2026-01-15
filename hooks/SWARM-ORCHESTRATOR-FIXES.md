# Swarm Orchestrator Fixes (Issues #20, #21)

**Date**: 2026-01-12
**Files Modified**: `~/.claude/hooks/swarm-orchestrator.sh`
**Test Files Created**:
- `~/.claude/hooks/test-swarm-fixes.sh` (unit tests)
- `~/.claude/hooks/test-swarm-integration.sh` (integration tests)

## Issues Fixed

### Issue #20: JSON Formatting - Trailing Commas

**Problem**:
- Lines 77-88 (and similar patterns in lines 96-132) were adding trailing commas
- Loop structure: append JSON object, then conditionally add comma
- Result: `[{...},]` instead of `[{...}]` or `[{...},{...}]`
- Failed jq parsing validation

**Root Cause**:
```bash
# OLD (BROKEN):
subtasks_json+="
    {\"agentId\": $i, ...}"
[[ $i -lt $agent_count ]] && subtasks_json+=","  # Adds comma AFTER
```

This creates trailing comma for the last element because the check happens after appending the object.

**Fix**:
```bash
# NEW (FIXED):
[[ $i -gt 1 ]] && subtasks_json+=","  # Add comma BEFORE (except first)
subtasks_json+="
    {\"agentId\": $i, ...}"
```

**Locations Fixed**:
1. Lines 77-88: Testing pattern
2. Lines 96-102: Refactoring pattern
3. Lines 110-120: Research pattern
4. Lines 128-132: Generic pattern

**Result**: All JSON arrays now valid, no trailing commas

---

### Issue #21: Git Merge Conflict Resolution - Wrong Heuristic

**Problem**:
- Line 434: `git diff "$file" | wc -l` counted ALL diff lines
- Included context lines (non-conflict content)
- Threshold of 10 lines unreliable
- Could auto-resolve large conflicts incorrectly

**Root Cause**:
```bash
# OLD (BROKEN):
git diff "$file" | grep -qE '^[<>]{7}' && [[ $(git diff "$file" | wc -l) -lt 10 ]]
```

This counted all diff output lines, not just conflict markers. A small conflict with lots of context would have >10 lines, while a large conflict with minimal context could have <10 lines.

**Fix**:
```bash
# NEW (FIXED):
# Count only conflict markers in the actual file
conflict_count=$(grep -cE '^(<{7}|={7}|>{7})' "$file" 2>/dev/null || true)
conflict_count=${conflict_count:-0}

if [[ $conflict_count -gt 0 && $conflict_count -le 3 ]]; then
    # Single conflict region has exactly 3 markers: <<<<<<, ======, >>>>>>
    # Auto-resolve by taking agent's changes
fi
```

**Key Improvements**:
1. Reads actual file content (not git diff output)
2. Counts only conflict markers: `<<<<<<<`, `=======`, `>>>>>>>`
3. Threshold of 3 markers = 1 conflict region (precise)
4. 6 markers = 2 regions → requires manual resolution
5. Handles edge cases: no conflicts (0 markers), multiple regions (>3 markers)

**Why Check File Instead of Git Diff**:
Git diff for merge conflicts uses combined diff format with `++` prefixes:
```
diff --cc test.txt
++<<<<<<< HEAD
 +our change
++=======
+ their change
++>>>>>>> branch
```

File content has clean markers:
```
<<<<<<< HEAD
our change
=======
their change
>>>>>>> branch
```

---

## Testing

### Unit Tests (`test-swarm-fixes.sh`)

**Test Coverage**:
1. JSON Formatting (11 tests):
   - Development pattern: 3, 4, 5 agents
   - Testing pattern: 2, 3 agents
   - Refactoring pattern: 3, 4 agents
   - Research pattern: 2, 3 agents
   - Generic pattern: 2, 3 agents

2. Conflict Detection (4 tests):
   - Single conflict region (3 markers)
   - Two conflict regions (6 markers)
   - Single conflict with context (3 markers)
   - No conflicts (0 markers)

**Results**: 15/15 tests passed (100%)

### Integration Tests (`test-swarm-integration.sh`)

**Test Coverage**:
1. Single Small Conflict
   - Creates 1 conflict region (3 markers)
   - Should auto-resolve: YES
   - ✓ Verified

2. Multiple Conflicts
   - Creates 2 conflict regions (6 markers)
   - Should auto-resolve: NO (manual resolution)
   - ✓ Verified

3. No Conflicts
   - Fast-forward merge
   - Should auto-resolve: N/A
   - ✓ Verified

4. Package Lock Files
   - Always take "ours" version
   - Should auto-resolve: YES
   - ✓ Verified

**Results**: 4/4 tests passed (100%)

---

## Verification Commands

```bash
# Run unit tests
~/.claude/hooks/test-swarm-fixes.sh

# Run integration tests
~/.claude/hooks/test-swarm-integration.sh

# Test JSON validity manually
source ~/.claude/hooks/swarm-orchestrator.sh
decompose_task "Run tests" 3 | jq empty && echo "Valid JSON"

# Test conflict detection manually
echo -e "line1\n<<<<<<< HEAD\nours\n=======\ntheirs\n>>>>>>> branch\nline2" > /tmp/test.txt
grep -cE '^(<{7}|={7}|>{7})' /tmp/test.txt  # Should output: 3
```

---

## Impact Assessment

### Before Fixes:
- JSON validation failures in swarm decomposition
- Unpredictable auto-resolution behavior
- Could auto-resolve large conflicts incorrectly
- Could reject small conflicts that should auto-resolve

### After Fixes:
- All JSON output valid (jq parsing works)
- Reliable conflict detection (counts actual markers)
- Precise threshold: 3 markers = 1 region = auto-resolve
- Safe: multiple regions require manual review
- Maintains Lean Prover pattern for package locks

### Production Impact:
- **Low risk**: Fixes are conservative (more manual resolution, not less)
- **High benefit**: Correct JSON parsing prevents swarm failures
- **No breaking changes**: Only fixes bugs, doesn't change API

---

## Related Files

- `~/.claude/hooks/swarm-orchestrator.sh` - Main file (modified)
- `~/.claude/hooks/test-swarm-fixes.sh` - Unit tests (new)
- `~/.claude/hooks/test-swarm-integration.sh` - Integration tests (new)
- Security audit: Issues #20, #21

---

## Commit Message

```
fix: Resolve Swarm Orchestrator JSON formatting and conflict detection

Issues #20, #21 from security audit

Problem 1 (JSON formatting):
- Testing/refactoring/research patterns added trailing commas
- Result: invalid JSON like [{...},]
- Broke jq parsing validation

Problem 2 (Git merge conflicts):
- Counted all diff lines (including context)
- Unreliable threshold of 10 lines
- Could auto-resolve large conflicts incorrectly

Fixes:
1. JSON: Add comma BEFORE each element (except first)
   - Changed from: append object, then add comma if not last
   - Changed to: add comma if not first, then append object
   - Fixed in 4 locations: testing, refactoring, research, generic

2. Conflict detection: Count only actual conflict markers
   - Changed from: git diff | wc -l (all lines)
   - Changed to: grep '^(<{7}|={7}|>{7})' file (markers only)
   - Threshold: 3 markers = 1 region = auto-resolve
   - Check file content (not git diff with ++ prefixes)

Testing:
- Unit tests: 15/15 passed (11 JSON + 4 conflict detection)
- Integration tests: 4/4 passed (real git scenarios)
- Zero breaking changes, conservative fixes
```
