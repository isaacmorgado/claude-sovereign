# Checkpoint Automation - How It Actually Works

**Date**: 2026-01-12
**Context**: Understanding what happens automatically vs. manually

---

## TL;DR

**What's Automatic:**
- ✅ Internal memory checkpoints (via memory-manager.sh)
- ✅ File change tracking
- ✅ Context usage monitoring
- ✅ Continuation prompt generation (at 40% context)

**What's Manual:**
- ❌ /checkpoint skill execution (updates CLAUDE.md, buildguide.md, git commits)
- ❌ You must run `/checkpoint` when you see the advisory

---

## The Two Types of Checkpoints

### 1. Memory Checkpoints (Automatic)
**What**: Internal memory state snapshots
**When**: Triggered by file changes or context usage
**Created by**: `memory-manager.sh checkpoint`
**Stores**: Working context, task state, recent actions
**Location**: `~/.claude/memory/checkpoints/`

### 2. /checkpoint Skill (Manual)
**What**: Full project checkpoint with documentation updates
**When**: You explicitly run `/checkpoint`
**Created by**: `.claude/commands/checkpoint.md` skill
**Updates**: CLAUDE.md, buildguide.md, creates continuation prompt
**May include**: Git commits (if requested)

---

## What You're Seeing

When you see this advisory:
```
CHECKPOINT_RECOMMENDED: true
REASON: changes_threshold
CHANGES_SINCE_LAST: 144
FILES_MODIFIED: 1
ACTION: Run /checkpoint now to save progress
```

**What happened:**
1. ✅ 144 file changes detected by file-change-tracker.sh
2. ✅ Internal memory checkpoint created automatically
3. ⚠️  Advisory displayed: telling YOU to run /checkpoint
4. ❌ /checkpoint skill NOT executed (waiting for you)

---

## Automatic Checkpoint Triggers

### Trigger 1: File Change Threshold (10 files)
**Hook**: `post-edit-quality.sh` (PostToolUse)
**Config**: `CHECKPOINT_FILE_THRESHOLD` (default: 10)
**Behavior**:
```bash
# After 10 file edits:
1. memory-manager.sh checkpoint "Auto-checkpoint after 10 file changes"
2. Output advisory: "Run /checkpoint now"
3. Reset counter
```

### Trigger 2: Context Usage (40% full)
**Hook**: `auto-continue.sh` (Stop)
**Config**: `CLAUDE_CONTEXT_THRESHOLD` (default: 40)
**Behavior**:
```bash
# When context hits 80,000 / 200,000 tokens (40%):
1. memory-manager.sh checkpoint "Auto-checkpoint at 40% context"
2. memory-manager.sh context-compact (if memory is full)
3. Generate continuation prompt
4. Feed continuation prompt back to Claude
```

---

## Why /checkpoint Isn't Automatic

The `/checkpoint` skill does heavy operations:
- Updates CLAUDE.md with session summary
- Updates buildguide.md with progress
- Creates detailed continuation prompt
- Optionally commits to git

**Design decision**: These operations should be explicit because:
- User might want to review changes before documenting
- Git commits require user approval
- Heavy disk I/O that could interrupt flow
- User controls when to save "official" progress

---

## Current Configuration

From `~/.claude/settings.json`:

### PostToolUse Hooks (Every File Edit)
```json
{
  "matcher": "Write|Edit|MultiEdit",
  "hooks": [
    "post-edit-quality.sh",           // Quality checks + file tracking
    "auto-checkpoint-trigger.sh record",  // Record file change
    "auto-checkpoint-trigger.sh recommend" // Output advisory if threshold hit
  ]
}
```

### Stop Hooks (End of Turn)
```json
{
  "hooks": [
    "graceful-shutdown.sh cleanup",
    "auto-continue.sh"  // Checks context %, creates checkpoint, generates continuation
  ]
}
```

### PreCompact Hooks (Before Context Compaction)
```json
{
  "hooks": [
    {
      "type": "prompt",
      "prompt": "...instructions to update CLAUDE.md before compaction..."
    }
  ]
}
```

---

## How to Use

### Normal Workflow
1. Work on tasks (files get edited)
2. When you see "CHECKPOINT_RECOMMENDED": Run `/checkpoint`
3. Continue working
4. At 40% context: Auto-continue creates internal checkpoint + continuation prompt
5. Run `/checkpoint` periodically to save official progress

### In /auto Mode
1. Autonomous agent works (many file edits)
2. Internal memory checkpoints created automatically
3. Advisories displayed but agent continues
4. At 40% context: Auto-continue triggers, creates continuation
5. Agent keeps running until task complete
6. User should run `/checkpoint` after auto mode completes

---

## Configuring Thresholds

### File Change Threshold
Edit `~/.claude/hooks/post-edit-quality.sh`:
```bash
# Line ~116
CHECKPOINT_FILE_THRESHOLD=${CHECKPOINT_FILE_THRESHOLD:-10}  # Change to 5, 20, etc.
```

Or set environment variable:
```bash
export CHECKPOINT_FILE_THRESHOLD=20
```

### Context Usage Threshold
Edit `~/.claude/hooks/auto-continue.sh`:
```bash
# Line 11
THRESHOLD=${CLAUDE_CONTEXT_THRESHOLD:-40}  # Change to 30, 50, etc.
```

Or set environment variable:
```bash
export CLAUDE_CONTEXT_THRESHOLD=50  # Trigger at 50% instead of 40%
```

---

## Testing

### Test File Change Tracking
```bash
# Make some edits and check counter
~/.claude/hooks/file-change-tracker.sh stats
```

### Test Context Monitoring
```bash
# Check current context usage (would need hook input)
# This is monitored automatically during conversation
```

### Test Memory Checkpoints
```bash
# List memory checkpoints
~/.claude/hooks/memory-manager.sh list-checkpoints

# View checkpoint details
~/.claude/hooks/memory-manager.sh restore <checkpoint_id> --dry-run
```

---

## Troubleshooting

### "Why am I seeing CHECKPOINT_RECOMMENDED?"
- You've edited 10+ files since last checkpoint
- Run `/checkpoint` to reset the counter and save official progress

### "Is auto-continue working?"
- Check logs: `tail -f ~/.claude/auto-continue.log`
- It only triggers at 40% context usage (80K tokens)
- Current context must be shown in advisories

### "How do I know if context is being compacted?"
- Check auto-continue.log for "compacting memory" messages
- Check continuation-prompt.md for generated prompts

---

## Summary

**Your question**: "Is it automatically running /checkpoint and compacting at 40%?"

**Answer**:
- ✅ YES: Internal memory checkpoint created at 40%
- ✅ YES: Memory compaction triggered if needed
- ✅ YES: Continuation prompt generated
- ❌ NO: /checkpoint skill NOT run automatically
- ⚠️  YOU: Must run `/checkpoint` manually when you see advisory

The system is working as designed - it creates internal state checkpoints automatically, but waits for your explicit command to update official documentation (CLAUDE.md) and create git commits.

---

## Next Steps

1. **When you see "CHECKPOINT_RECOMMENDED"**: Run `/checkpoint`
2. **To change thresholds**: Set environment variables or edit hook scripts
3. **To monitor**: Check logs in `~/.claude/logs/` and `~/.claude/*.log`
4. **In /auto mode**: Internal checkpoints work automatically, run `/checkpoint` after completion

---

**Status**: All automatic checkpointing is working ✅
**Manual action**: You control when to run `/checkpoint` skill ✅
