# Quick Reference - Agent Loop Fixes

## What Was Fixed

✅ **Issue #4**: Validation gate now actually blocks dangerous commands
✅ **Issue #16**: Task queue properly prioritizes and persists tasks

## Test Suite

```bash
# Run all tests
~/.claude/hooks/test-agent-loop-fixes.sh

# Expected output: 16/16 tests passed
```

## Validation Gate Testing

```bash
GATE=~/.claude/hooks/validation-gate.sh

# Safe command (PASS)
$GATE command "echo hello world"

# Risky command (WARNING)
$GATE command "sudo apt-get install test"

# Dangerous command (BLOCKED)
$GATE command "rm -rf /"
```

## Task Queue Testing

```bash
QUEUE=~/.claude/hooks/task-queue.sh

# Clear queue
rm -f ~/.claude/queue/tasks.json

# Add tasks with numeric priorities (1=high, 3=medium, 5=low)
$QUEUE add "urgent task" 1
$QUEUE add "normal task" 3
$QUEUE add "low priority" 5

# List all tasks
$QUEUE list | jq '.tasks | sort_by(.priority)'
```

## What Changed

### agent-loop.sh

**Line 590** - Validation gate integration:
- Changed: `validate` → `command` subcommand
- Changed: JSON parsing → plain text parsing
- Added: `return 126` to actually block dangerous commands
- Added: WARNING status handling and logging

**Line 325** - Task queue loop:
- Changed: `| while read` → `done < <(...)` (no subshell)
- Added: String to numeric priority conversion
- Fixed: Variable scope issues

## Dangerous Commands (Now Blocked)

These patterns are now blocked by validation gate:

```bash
rm -rf /                    # Recursive delete on root
rm -rf ~                    # Recursive delete on home
rm -rf $HOME               # Recursive delete on home
curl URL | sh              # Pipe to shell
wget URL | sh              # Pipe to shell
>> /etc/file               # Write to system directory
chmod 777 file             # Insecure permissions (warning)
sudo command               # Elevated privileges (warning)
eval untrusted             # Code evaluation (warning)
```

## Priority Conversion

String priorities are automatically converted:

| Input String | Numeric Value | Order |
|-------------|---------------|-------|
| high, urgent, critical | 1 | First |
| medium (default) | 3 | Second |
| low, minor | 5 | Third |

## Monitoring

Check logs for blocked commands:

```bash
# View validation gate log
tail -f ~/.claude/validation-gate.log

# View agent loop log
tail -f ~/.claude/agent-loop.log

# Search for blocked commands
grep "BLOCKED" ~/.claude/validation-gate.log
grep "Validation gate blocked" ~/.claude/agent-loop.log
```

## Rollback

If issues occur, revert to previous version:

```bash
cd ~/.claude/hooks
git diff agent-loop.sh  # Review changes
git checkout HEAD~1 -- agent-loop.sh  # Revert if needed
```

## Files Modified

1. `~/.claude/hooks/agent-loop.sh` - Main integration logic
2. `~/.claude/hooks/test-agent-loop-fixes.sh` - Test suite (new)
3. `~/.claude/hooks/AGENT-LOOP-FIXES-SUMMARY.md` - Summary (new)
4. `~/.claude/hooks/BEFORE-AFTER-COMPARISON.md` - Detailed comparison (new)

## Next Steps

1. Monitor validation gate in production
2. Tune validation rules based on false positives
3. Add metrics for blocked commands
4. Consider adding custom validation rules

## Support

Run diagnostics:

```bash
# Check validation gate
~/.claude/hooks/validation-gate.sh command "test"

# Check task queue
~/.claude/hooks/task-queue.sh status

# Check agent loop
grep -c "Validation gate" ~/.claude/agent-loop.log
```

Report issues to the autonomous system maintainer.
