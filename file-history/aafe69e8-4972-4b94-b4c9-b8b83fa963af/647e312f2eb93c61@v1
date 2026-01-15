# Autonomous Checkpoint System

**Date**: 2026-01-12
**Status**: ✅ Production Ready

---

## TL;DR

**Before (Manual):**
- Hooks created internal memory checkpoints
- Outputted advisories: "Run /checkpoint to save progress"
- User had to manually run `/checkpoint`

**After (Autonomous):**
- Hooks use intelligent command router
- Router decides: advisory vs auto-execute
- In `/auto` mode: Claude executes `/checkpoint` automatically
- In normal mode: Claude outputs advisory, waits for user

---

## Architecture

### Components

#### 1. Intelligent Command Router (`autonomous-command-router.sh`)
**Location**: `~/.claude/hooks/autonomous-command-router.sh`

**Purpose**: Analyzes context and decides whether to:
- Output advisory (normal mode)
- Signal auto-execution (autonomous mode)

**Decision Logic**:
```bash
if autonomous_mode_active; then
  echo '{"execute_skill": "checkpoint", "reason": "...", "autonomous": true}'
else
  echo '{"advisory": "Run /checkpoint to save progress"}'
fi
```

**Triggers**:
- `checkpoint_files`: After N file changes (default: 10)
- `checkpoint_context`: At context threshold (default: 40%)
- `build_section_complete`: After completing build section
- `manual`: User explicit request

#### 2. Modified Hooks

**`post-edit-quality.sh`** (After every file edit):
```bash
# Create internal memory checkpoint (state tracking)
checkpoint_id=$(memory-manager.sh checkpoint "Auto-checkpoint after N files")

# Use router to decide next action
router_decision=$(autonomous-command-router.sh execute checkpoint_files)

# Output router decision (advisory OR execute_skill signal)
echo "$router_decision"
```

**`auto-continue.sh`** (At 40% context usage):
```bash
# Create internal memory checkpoint (state tracking)
checkpoint_id=$(memory-manager.sh checkpoint "Auto-checkpoint at 40% context")

# Use router to decide next action
router_decision=$(autonomous-command-router.sh execute checkpoint_context)

# Include router decision in continuation prompt
jq -n '{
  "decision": "block",
  "reason": $prompt,
  "router_decision": $router
}'
```

#### 3. Updated `/auto` Skill

**Recognition Pattern**:
When Claude sees hook output with `"execute_skill"` field:
```json
{
  "execute_skill": "checkpoint",
  "reason": "file_threshold",
  "autonomous": true,
  "checkpoint_id": "cp_12345"
}
```

**Claude's Response (Autonomous Mode)**:
1. Recognize the signal
2. Execute `Skill(skill="checkpoint")` immediately
3. Follow checkpoint.md instructions
4. Continue working

**Claude's Response (Normal Mode)**:
1. See advisory message
2. Output to user: "Run /checkpoint to save progress"
3. Wait for user command

---

## Flow Diagrams

### Autonomous Mode Flow

```
User: /auto
Claude: [Starts autonomous work]
       ↓
[Edit 10 files]
       ↓
post-edit-quality.sh hook:
  1. Create internal checkpoint (memory-manager)
  2. Call router → {"execute_skill": "checkpoint"}
  3. Output signal to Claude
       ↓
Claude sees: {"execute_skill": "checkpoint", "autonomous": true}
       ↓
Claude: [Executes Skill(skill="checkpoint") automatically]
       ↓
checkpoint.md instructions:
  1. Scan for new docs (explore agent)
  2. Update buildguide.md (mark complete, next section)
  3. Update CLAUDE.md (replace Last Session)
  4. Output continuation prompt
       ↓
Claude: "Checkpoint complete, continuing work..."
       ↓
[Continue autonomous work]
```

### Normal Mode Flow

```
User: [Regular interaction]
Claude: [Makes edits]
       ↓
[Edit 10 files]
       ↓
post-edit-quality.sh hook:
  1. Create internal checkpoint (memory-manager)
  2. Call router → {"advisory": "Run /checkpoint..."}
  3. Output advisory to Claude
       ↓
Claude sees: {"advisory": "Run /checkpoint to save progress"}
       ↓
Claude to user: "📋 I've created an internal checkpoint after 10 file changes.
                 Run /checkpoint to update CLAUDE.md and buildguide.md"
       ↓
User: "/checkpoint"
       ↓
Claude: [Executes checkpoint.md instructions]
```

### Context Threshold Flow (40%)

```
Context reaches 80,000 / 200,000 tokens (40%)
       ↓
auto-continue.sh hook (Stop hook):
  1. Check memory pressure → may compact
  2. Create internal checkpoint (memory-manager)
  3. Call router → determine action
  4. Generate continuation prompt
  5. Block stop, feed prompt back
       ↓
If Autonomous Mode:
  Router: {"execute_skill": "checkpoint", "autonomous": true}
  Continuation: "⚡ Auto-executing: /checkpoint"
  Claude: [Executes checkpoint immediately]
       ↓
If Normal Mode:
  Router: {"advisory": "Run /checkpoint..."}
  Continuation: "First: Run /checkpoint to save session state"
  Claude: [Waits for user]
```

---

## Configuration

### Autonomous Mode Toggle

```bash
# Activate autonomous mode
echo "$(date +%s)" > ~/.claude/autonomous-mode.active

# Deactivate
rm ~/.claude/autonomous-mode.active

# Check status
if [[ -f ~/.claude/autonomous-mode.active ]]; then
  echo "AUTONOMOUS"
else
  echo "NORMAL"
fi
```

### Thresholds

**File Change Threshold** (default: 10 files):
```bash
# In post-edit-quality.sh (line ~116)
CHECKPOINT_FILE_THRESHOLD=${CHECKPOINT_FILE_THRESHOLD:-10}

# Or set environment variable
export CHECKPOINT_FILE_THRESHOLD=20
```

**Context Usage Threshold** (default: 40%):
```bash
# In auto-continue.sh (line 11)
THRESHOLD=${CLAUDE_CONTEXT_THRESHOLD:-40}

# Or set environment variable
export CLAUDE_CONTEXT_THRESHOLD=50
```

---

## Testing

### Test Router in Normal Mode
```bash
~/.claude/hooks/autonomous-command-router.sh execute checkpoint_files

# Expected output:
# {"advisory": "Run /checkpoint to save progress after multiple file changes"}
```

### Test Router in Autonomous Mode
```bash
# Activate autonomous mode
touch ~/.claude/autonomous-mode.active

# Test router
~/.claude/hooks/autonomous-command-router.sh execute checkpoint_files

# Expected output:
# {"execute_skill": "checkpoint", "reason": "file_threshold", "autonomous": true}

# Cleanup
rm ~/.claude/autonomous-mode.active
```

### Test Hook Integration
```bash
# Simulate file edits (requires actual file operations)
# The hook will fire after 10 edits automatically

# Check logs
tail -f ~/.claude/logs/post-edit-quality.log
tail -f ~/.claude/logs/command-router.log
tail -f ~/.claude/auto-continue.log
```

---

## Decision Matrix

| Trigger | Autonomous Mode | Normal Mode |
|---------|----------------|-------------|
| 10 files edited | Auto-execute /checkpoint | Advisory only |
| 40% context | Auto-execute /checkpoint (or compact+checkpoint) | Advisory in continuation prompt |
| Build section complete | Auto-execute /checkpoint | Advisory only |
| Manual request | Always execute | Always execute |

---

## Benefits

### For Users
- ✅ **Zero manual intervention** in /auto mode
- ✅ **Context never lost** due to missed checkpoints
- ✅ **CLAUDE.md always up-to-date** without thinking about it
- ✅ **buildguide.md tracks progress** automatically
- ✅ **Still have control** in normal mode

### For System
- ✅ **Internal state tracking** (memory checkpoints) separate from documentation updates
- ✅ **Intelligent routing** based on mode
- ✅ **Clear separation** of concerns (state vs docs)
- ✅ **Extensible** for future commands (/compact, /build, /document)

---

## Troubleshooting

### "Claude isn't auto-executing checkpoints"

**Check**:
1. Is autonomous mode active?
   ```bash
   ls ~/.claude/autonomous-mode.active
   ```
2. Is the router executable?
   ```bash
   ls -l ~/.claude/hooks/autonomous-command-router.sh
   ```
3. Check router logs:
   ```bash
   tail ~/.claude/logs/command-router.log
   ```

### "Checkpoints happening too frequently"

**Increase threshold**:
```bash
# In ~/.claude/hooks/post-edit-quality.sh (line ~116)
CHECKPOINT_FILE_THRESHOLD=20  # Increase from 10

# Or set environment variable
export CHECKPOINT_FILE_THRESHOLD=20
```

### "Checkpoints not happening at 40%"

**Check**:
1. Is context actually reaching 40%?
   ```bash
   # Check auto-continue.log for percentage
   tail ~/.claude/auto-continue.log
   ```
2. Is the hook firing?
   ```bash
   # Check settings.json for Stop hook
   grep -A5 '"Stop"' ~/.claude/settings.json
   ```

### "Router returning empty JSON"

**Debug**:
```bash
# Test router directly
~/.claude/hooks/autonomous-command-router.sh execute checkpoint_files

# Check logs
tail ~/.claude/logs/command-router.log

# Ensure jq is installed
which jq
```

---

## Extension Points

The router is designed to support future commands:

### Adding /build Auto-Execution
```bash
# In router (autonomous-command-router.sh)
case "$trigger" in
    build_start)
        if $autonomous && $has_buildguide; then
            echo '{"command": "build", "reason": "buildguide_ready", "auto_execute": true}'
        fi
        ;;
esac
```

### Adding /document Auto-Execution
```bash
# After quality gates pass
if quality_score > 7.0; then
    router execute document_ready
    # → {"execute_skill": "document", "autonomous": true}
fi
```

### Adding /compact Auto-Execution
Already supported! Router outputs:
```json
{"execute_skill": "compact", "then": "checkpoint", "reason": "memory_pressure"}
```

---

## Files Modified

### New Files
- `~/.claude/hooks/autonomous-command-router.sh` - Intelligent decision engine
- `~/.claude/docs/AUTONOMOUS-CHECKPOINT-SYSTEM.md` - This documentation

### Modified Files
- `~/.claude/hooks/post-edit-quality.sh` - Integrated router for file threshold
- `~/.claude/hooks/auto-continue.sh` - Integrated router for context threshold
- `~/.claude/commands/auto.md` - Added autonomous checkpoint execution section

### Unchanged (Still Work)
- `~/.claude/hooks/memory-manager.sh` - Internal state tracking
- `~/.claude/hooks/file-change-tracker.sh` - File change counting
- `~/.claude/commands/checkpoint.md` - Checkpoint skill instructions

---

## Summary

**What Changed**:
- Added intelligent command router
- Modified hooks to call router
- Updated /auto skill to recognize and execute signals
- Maintained backward compatibility (normal mode still works)

**What Stayed the Same**:
- Internal memory checkpoints still created automatically
- /checkpoint skill instructions unchanged
- Manual /checkpoint still works in both modes
- File change tracking unchanged
- Context monitoring unchanged

**Result**:
- **Fully autonomous checkpoint execution** when /auto is active
- **User-controlled checkpointing** when in normal mode
- **Best of both worlds**: automation + control

---

**Status**: ✅ Ready for production use
**Testing**: ✅ Router tested in both modes
**Documentation**: ✅ Complete
**Integration**: ✅ Hooks updated and wired
