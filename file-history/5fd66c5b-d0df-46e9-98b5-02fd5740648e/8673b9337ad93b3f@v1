# Checkpoint Auto-Configuration Quick Reference

Fast reference for configuring automatic checkpoint triggers.

---

## TL;DR - Quick Setup

**Add to `~/.zshrc` or `~/.bashrc`:**

```bash
# Checkpoint at 40% context (default)
export CLAUDE_CONTEXT_THRESHOLD=40

# Checkpoint every 10 file changes (default)
export CHECKPOINT_FILE_THRESHOLD=10
```

Then: `source ~/.zshrc` and you're done!

---

## Configuration Variables

### 1. Context Threshold (`CLAUDE_CONTEXT_THRESHOLD`)

**Controls**: When `/checkpoint` runs based on context usage percentage

**Default**: 40 (trigger at 40% context)

**Range**: 1-100

**Quick Presets**:
```bash
# Aggressive (checkpoint often)
export CLAUDE_CONTEXT_THRESHOLD=25

# Balanced (default)
export CLAUDE_CONTEXT_THRESHOLD=40

# Conservative (checkpoint less often)
export CLAUDE_CONTEXT_THRESHOLD=60

# Minimal (only near context limit)
export CLAUDE_CONTEXT_THRESHOLD=80
```

---

### 2. File Change Threshold (`CHECKPOINT_FILE_THRESHOLD`)

**Controls**: When `/checkpoint` runs based on number of files edited

**Default**: 10 (trigger after 10 file changes)

**Range**: 1-∞

**Quick Presets**:
```bash
# Aggressive (checkpoint often)
export CHECKPOINT_FILE_THRESHOLD=5

# Balanced (default)
export CHECKPOINT_FILE_THRESHOLD=10

# Conservative (checkpoint less often)
export CHECKPOINT_FILE_THRESHOLD=20

# Minimal (for mass refactors)
export CHECKPOINT_FILE_THRESHOLD=50
```

---

## Recommended Configurations by Use Case

### For Critical Code / Production Work
```bash
export CLAUDE_CONTEXT_THRESHOLD=30
export CHECKPOINT_FILE_THRESHOLD=5
```
**Why**: Frequent checkpoints ensure no progress is lost

---

### For Feature Development (Default)
```bash
export CLAUDE_CONTEXT_THRESHOLD=40
export CHECKPOINT_FILE_THRESHOLD=10
```
**Why**: Balanced - checkpoints happen regularly without being intrusive

---

### For Exploratory / Experimental Work
```bash
export CLAUDE_CONTEXT_THRESHOLD=60
export CHECKPOINT_FILE_THRESHOLD=20
```
**Why**: Less frequent interruptions for quick iterations

---

### For Large Refactors / Bulk Operations
```bash
export CLAUDE_CONTEXT_THRESHOLD=75
export CHECKPOINT_FILE_THRESHOLD=50
```
**Why**: Minimize interruptions during high-volume changes

---

### For Long Autonomous Sessions
```bash
export CLAUDE_CONTEXT_THRESHOLD=50
export CHECKPOINT_FILE_THRESHOLD=15
```
**Why**: Regular saves without too much overhead

---

## How to Apply

### Option 1: Persistent (Recommended)

Add to shell profile:
```bash
echo 'export CLAUDE_CONTEXT_THRESHOLD=40' >> ~/.zshrc
echo 'export CHECKPOINT_FILE_THRESHOLD=10' >> ~/.zshrc
source ~/.zshrc
```

### Option 2: Per-Session

Run before starting work:
```bash
export CLAUDE_CONTEXT_THRESHOLD=60
export CHECKPOINT_FILE_THRESHOLD=20
# Now run /auto
```

### Option 3: Per-Project

Create `.env` in project root:
```bash
# .env
export CLAUDE_CONTEXT_THRESHOLD=50
export CHECKPOINT_FILE_THRESHOLD=15
```

Then source it:
```bash
cd your-project
source .env
# Now run /auto
```

---

## Verification

### Check Current Settings
```bash
echo "Context: ${CLAUDE_CONTEXT_THRESHOLD:-40}% (default: 40)"
echo "Files: ${CHECKPOINT_FILE_THRESHOLD:-10} (default: 10)"
```

### Check Status
```bash
# Context checkpoint status
tail ~/.claude/auto-continue.log | grep "Context:"

# File checkpoint status
~/.claude/hooks/file-change-tracker.sh status
```

---

## Testing Your Configuration

### Test Context Threshold

Run this command with your desired threshold:
```bash
export CLAUDE_CONTEXT_THRESHOLD=50
cat <<'EOF' | ~/.claude/hooks/auto-continue.sh 2>&1 | jq .
{
  "context_window": {
    "context_window_size": 200000,
    "current_usage": {
      "input_tokens": 100000,
      "cache_creation_input_tokens": 0,
      "cache_read_input_tokens": 0
    }
  },
  "transcript_path": ""
}
EOF
```

**Expected**: Should trigger (show `"decision": "block"`) if tokens match your threshold

---

### Test File Threshold

Run this in a test directory:
```bash
export CHECKPOINT_FILE_THRESHOLD=5
cd /tmp/test-dir && mkdir -p .claude
~/.claude/hooks/file-change-tracker.sh init
for i in {1..5}; do
  ~/.claude/hooks/file-change-tracker.sh record "test$i.txt" modified
done
~/.claude/hooks/file-change-tracker.sh status
```

**Expected**: Should show "Checkpoint needed: YES" after 5 files

---

## Tips & Best Practices

### 1. Match Thresholds to Task Type
- **Critical code**: Lower thresholds (more checkpoints)
- **Exploratory work**: Higher thresholds (fewer interruptions)

### 2. Consider Context Size
- Default context: 200k tokens
- Your threshold % applies to total available context
- 40% of 200k = checkpoint at 80k tokens used

### 3. File Count Depends on Project Size
- Small projects (< 50 files): Use lower threshold (5-10)
- Large projects (1000+ files): Can use higher threshold (20-30)

### 4. Balance Frequency vs Interruption
- Too low: Frequent checkpoints, more interruptions
- Too high: Risk losing work if session crashes
- Sweet spot: 30-50% context, 10-20 files

### 5. Monitor and Adjust
Check logs occasionally:
```bash
tail ~/.claude/auto-continue.log
tail ~/.claude/post-edit-quality.log
```

Adjust thresholds if:
- Checkpoints happening too often → increase thresholds
- Concerned about losing work → decrease thresholds

---

## Troubleshooting

### "Checkpoint not triggering"

1. **Check if variables are set**:
   ```bash
   echo $CLAUDE_CONTEXT_THRESHOLD
   echo $CHECKPOINT_FILE_THRESHOLD
   ```

2. **Ensure they're exported** (not just set):
   ```bash
   export CLAUDE_CONTEXT_THRESHOLD=50  # Include 'export'!
   ```

3. **Check if file tracker is initialized**:
   ```bash
   ls -la .claude/file-changes.json
   ```

4. **View logs**:
   ```bash
   tail -20 ~/.claude/auto-continue.log
   tail -20 ~/.claude/post-edit-quality.log
   ```

---

### "Too many checkpoints"

**Increase thresholds**:
```bash
export CLAUDE_CONTEXT_THRESHOLD=60  # Was: 40
export CHECKPOINT_FILE_THRESHOLD=20  # Was: 10
```

---

### "Not enough checkpoints"

**Decrease thresholds**:
```bash
export CLAUDE_CONTEXT_THRESHOLD=30  # Was: 40
export CHECKPOINT_FILE_THRESHOLD=5   # Was: 10
```

---

## Reset Configuration to Defaults

Remove custom settings:
```bash
unset CLAUDE_CONTEXT_THRESHOLD
unset CHECKPOINT_FILE_THRESHOLD
```

Or in shell profile, comment out:
```bash
# ~/.zshrc
# export CLAUDE_CONTEXT_THRESHOLD=50  # Disabled
# export CHECKPOINT_FILE_THRESHOLD=15  # Disabled
```

Defaults will be used:
- Context: 40%
- Files: 10

---

## Summary

**Two variables control everything**:
1. `CLAUDE_CONTEXT_THRESHOLD` - Context percentage (default: 40)
2. `CHECKPOINT_FILE_THRESHOLD` - File count (default: 10)

**To customize**:
1. Add exports to `~/.zshrc`
2. Reload: `source ~/.zshrc`
3. Verify: `echo $VARIABLE_NAME`

**That's it!** The system handles the rest automatically during `/auto` mode.

---

**Last Updated**: 2026-01-12
**Tested Ranges**: 1-100% for context, 1-50 files (but works with any value)
**Status**: Production Ready ✅
