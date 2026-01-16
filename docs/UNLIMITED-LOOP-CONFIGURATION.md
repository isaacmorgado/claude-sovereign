# Unlimited Claude Loop Configuration

**Date**: 2026-01-16
**Change**: Modified claude-loop.sh to run indefinitely until `/auto stop` is used

## What Changed

**Before**: Loop stopped after 100 restarts (safety limit)
**After**: Loop runs indefinitely until manually stopped with `/auto stop`

## Configuration

### Default Behavior (New)
```bash
MAX_RESTARTS=999999999  # Effectively unlimited
```

This means the loop will run for 999,999,999 sessions before stopping - effectively never stopping in normal use.

### How to Stop

**Method 1: Use /auto stop (Recommended)**
```bash
/auto stop
```
This will:
- Kill the loop process gracefully
- Create stop signal file
- Deactivate autonomous mode
- Clean up state files

**Method 2: Stop Signal File**
```bash
touch ~/.claude/stop-loop
```
The loop checks for this file after each session and stops if found.

**Method 3: Kill Process**
```bash
# Find the PID
cat ~/.claude/loop.pid

# Kill it
kill $(cat ~/.claude/loop.pid)

# Clean up
rm ~/.claude/loop.pid ~/.claude/stop-loop
```

## Why This Change

### Problem
- Loop hit 100-restart safety limit during testing
- Caused unexpected stops during autonomous operation
- Users had to manually restart the loop

### Solution
- Changed default to 999,999,999 (effectively unlimited)
- Added clear documentation for stopping via `/auto stop`
- Improved help text to explain stop mechanisms

## Safety Considerations

**Built-in Safety**:
1. **Stop signal** checked after every session (line 94-98)
2. **Exit code** logged for debugging (line 90-91)
3. **Graceful shutdown** on Ctrl+C (line 44)
4. **2-second delay** between restarts (prevents runaway)

**No safety concerns with unlimited**:
- Loop only runs when explicitly started by user
- Can be stopped at any time with `/auto stop`
- Each session is isolated (not cumulative)
- Context is cleared at 40% to prevent memory issues

## Usage

### Start Unlimited Loop
```bash
# Start with /auto command (recommended)
/auto start

# Or start loop directly
~/.claude/bin/claude-loop.sh &

# Verify running
ps aux | grep claude-loop.sh
```

### Monitor Loop
```bash
# Watch log in real-time
tail -f ~/.claude/loop.log

# Check current session count
grep "Session #" ~/.claude/loop.log | tail -1

# Check if continuation prompts are being fed
grep "continuation prompt" ~/.claude/loop.log | tail -5
```

### Stop Loop
```bash
# Clean stop (recommended)
/auto stop

# Verify stopped
ps aux | grep claude-loop.sh | grep -v grep
# Should return nothing
```

## Environment Variables

You can still override the default:

```bash
# Set custom limit (if needed)
export CLAUDE_LOOP_MAX_RESTARTS=500
~/.claude/bin/claude-loop.sh &

# Set unlimited explicitly
export CLAUDE_LOOP_MAX_RESTARTS=999999999
~/.claude/bin/claude-loop.sh &

# Set custom delay between restarts
export CLAUDE_LOOP_DELAY=5  # 5 seconds instead of 2
~/.claude/bin/claude-loop.sh &
```

## Testing

Verify the unlimited loop works:

```bash
# Start loop in foreground (for testing)
~/.claude/bin/claude-loop.sh

# Watch for log message
# Should say: "Starting Claude infinite loop (unlimited restarts - use /auto stop to stop)"

# Stop with Ctrl+C after a few sessions

# Check log
tail ~/.claude/loop.log
# Should NOT see "Max restarts (100) reached"
```

## Integration with /auto Command

The `/auto` command now starts an unlimited loop by default:

```bash
# This now runs indefinitely
/auto start

# Stop with
/auto stop
```

No configuration needed - it just works!

## Files Modified

1. `/Users/imorgado/.claude/bin/claude-loop.sh`
   - Line 13: Changed `MAX_RESTARTS=100` to `MAX_RESTARTS=999999999`
   - Lines 30-38: Updated help text with new stop instructions
   - Lines 64-67: Added conditional log message for unlimited loops

## Backward Compatibility

✅ **Fully backward compatible**:
- Environment variable `CLAUDE_LOOP_MAX_RESTARTS` still works
- Can set custom limits if desired
- Stop mechanisms unchanged
- All existing scripts work as before

## Production Ready

✅ Tested and verified:
- Loop starts with unlimited restarts
- Log message indicates unlimited mode
- `/auto stop` cleanly stops the loop
- Stop signal file mechanism works
- No safety issues identified

---

**Status**: Production Ready ✅
**Risk**: Low (same mechanisms, just higher limit)
**Impact**: True unlimited autonomous operation
