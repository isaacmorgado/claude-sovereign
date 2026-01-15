# Continuation Prompt: Fix Remaining Gaps

## Context
The autonomous Claude system has been audited. Core components work but these gaps remain:

1. **Reflections not being created** - PreCompact hook doesn't trigger reflection
2. **Metrics not being collected** - No automatic metrics tracking
3. **Debug log empty** - Template exists but not populated
4. **Some hooks not integrated** - graceful-shutdown, progress-tracker not in settings.json

## Tasks

### Task 1: Add Reflection to PreCompact Hook
Update `~/.claude/settings.json` PreCompact hook to include reflection creation:

```json
{
  "matcher": "auto",
  "hooks": [
    {
      "type": "command",
      "command": "${HOME}/.claude/hooks/memory-manager.sh reflect session \"$(cat)\" \"Auto-reflection before compaction\"",
      "timeout": 10
    },
    {
      "type": "prompt",
      "prompt": "Context is being auto-compacted. Before compaction:\n\n1. Create a reflection on this session:\n   - What was accomplished?\n   - What patterns were learned?\n   - What should be remembered?\n\n2. Run: memory-manager.sh reflect session \"<summary>\" \"<insights>\"\n\n3. Update CLAUDE.md with session progress\n\n4. Keep CLAUDE.md under 100 lines"
    }
  ]
}
```

### Task 2: Add Metrics Collection Hook
Add to PostToolUse in settings.json:

```json
{
  "matcher": "Bash|Task",
  "hooks": [
    {
      "type": "command",
      "command": "${HOME}/.claude/hooks/metrics-collector.sh record tool_use",
      "timeout": 5
    }
  ]
}
```

### Task 3: Initialize Debug Log
Create proper debug-log.md template:

```markdown
# Debug Log

> Track all fix attempts, errors encountered, and solutions found.
> Last Updated: [DATE]

## Active Issues
<!-- Issues currently being worked on -->

## Recent Fixes
<!-- Fixes applied in this session -->

## Learned Patterns
<!-- Patterns discovered that should be remembered -->

## Error History
<!-- Past errors and their solutions -->
```

### Task 4: Add Stop Hook for Graceful Shutdown
Update Stop hooks in settings.json to include graceful-shutdown:

```json
"Stop": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "${HOME}/.claude/hooks/graceful-shutdown.sh cleanup",
        "timeout": 10
      },
      {
        "type": "command",
        "command": "${HOME}/.claude/hooks/auto-continue.sh",
        "timeout": 30
      }
    ]
  }
]
```

### Task 5: Verify All Fixes
After making changes:
1. Run `memory-manager.sh reflect test "Testing reflection" "Verifying system"`
2. Run `memory-manager.sh stats` to check memory state
3. Run `self-healing.sh status` to verify health
4. Check settings.json is valid JSON: `jq '.' ~/.claude/settings.json`

## Expected Outcome
- Reflections created automatically before context compaction
- Metrics tracked on tool usage
- Debug log ready for use
- Graceful shutdown on session end
- All hooks properly integrated

## Files to Modify
1. `~/.claude/settings.json` - Add/update hooks
2. `~/.claude/docs/debug-log.md` - Initialize template
