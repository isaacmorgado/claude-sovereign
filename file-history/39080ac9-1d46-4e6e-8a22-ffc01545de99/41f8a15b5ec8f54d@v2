---
description: Toggle auto-continue mode (hands-off context management)
argument-hint: "[on|off|status]"
allowed-tools: ["Read", "Write", "Edit", "Bash"]
---

# Auto-Continue Command

Manage hands-off mode where Claude automatically:
1. Monitors context usage
2. Saves state to CLAUDE.md at threshold
3. Compacts and continues with a continuation prompt
4. Runs indefinitely until task is complete

## Usage

- `/auto-continue on` - Enable auto-continue (default 40% threshold)
- `/auto-continue off` - Disable auto-continue
- `/auto-continue status` - Show current state
- `/auto-continue 60` - Set threshold to 60%

## Instructions

Parse the argument: $ARGUMENTS

### If "on" or empty:
```bash
rm -f .claude/auto-continue-disabled 2>/dev/null
echo "✅ Auto-continue enabled"
echo "Threshold: ${CLAUDE_CONTEXT_THRESHOLD:-40}%"
echo ""
echo "Claude will now automatically:"
echo "  • Monitor context usage"
echo "  • At threshold: save state → compact → continue"
echo "  • Run until task complete or you say 'stop'"
echo ""
echo "To disable: /auto-continue off"
```

### If "off":
```bash
mkdir -p .claude
touch .claude/auto-continue-disabled
rm -f .claude/auto-continue.local.md 2>/dev/null
echo "⏹️  Auto-continue disabled"
echo "Claude will stop normally at end of responses."
```

### If "status":
```bash
if [[ -f .claude/auto-continue-disabled ]]; then
    echo "⏹️  Auto-continue: DISABLED"
else
    echo "✅ Auto-continue: ENABLED"
    echo "Threshold: ${CLAUDE_CONTEXT_THRESHOLD:-40}%"
    if [[ -f .claude/auto-continue.local.md ]]; then
        echo ""
        echo "State:"
        cat .claude/auto-continue.local.md
    fi
fi
```

### If numeric (e.g., "60"):
```bash
export CLAUDE_CONTEXT_THRESHOLD=$ARGUMENTS
rm -f .claude/auto-continue-disabled 2>/dev/null
echo "✅ Auto-continue enabled at ${ARGUMENTS}% threshold"
```

## How It Works

The Stop hook (`~/.claude/hooks/auto-continue.sh`) runs after every Claude response:

1. **Check context %** - Calculates current token usage
2. **Below threshold** - Allows normal stop
3. **Above threshold** - Returns `{"decision": "block", "reason": "continuation prompt"}`
4. **Claude receives** the continuation prompt as new input
5. **Loop continues** until task complete

The hook reads CLAUDE.md and buildguide.md to create context-aware continuation prompts.

## Stopping

To stop the loop:
- Say "stop" or "pause" in your message
- Run `/auto-continue off`
- Create `.claude/auto-continue-disabled` file
