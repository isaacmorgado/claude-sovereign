---
description: Perform root cause analysis with regression detection
argument-hint: "<action> [options]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Task", "TodoWrite", "mcp__grep__searchGitHub"]
---

# Root Cause Command

Perform intelligent root cause analysis with before/after snapshots, regression detection, and memory-based fix suggestions.

## Usage

```bash
# Analyze a bug
komplete rootcause analyze --bug-description "Error: Cannot read property 'id'" --bug-type "type_error"

# Verify a fix
komplete rootcause verify --before-snapshot-id "snapshot_123" --test-command "npm test" --fix-description "Added null check"
```

## Actions

### analyze

Analyze a bug and generate fix suggestions:
- Creates before snapshot of current state
- Searches memory for similar bugs and fixes
- Searches GitHub for similar issues
- Generates fix prompt with context

**Options:**
- `--bug-description` - Description of the bug (required)
- `--bug-type` - Type of bug (default: general)
- `--test-command` - Command to reproduce the bug (default: "echo 'No tests configured'")

### verify

Verify a fix and detect regressions:
- Creates after snapshot of current state
- Runs test command to verify fix
- Compares before/after snapshots for regressions
- Generates recommendations

**Options:**
- `--before-snapshot-id` - ID of before snapshot (required)
- `--test-command` - Command to run for verification (required)
- `--fix-description` - Description of the fix applied (optional)

## What It Does

### Analyze Action

1. **Creates snapshot** - Captures current state before investigation
2. **Searches memory** - Finds similar bugs and their fixes
3. **Searches GitHub** - Finds similar issues in public repositories
4. **Generates fix prompt** - Provides context-aware fix suggestions
5. **Records findings** - Saves analysis to memory for future reference

### Verify Action

1. **Creates after snapshot** - Captures state after fix is applied
2. **Runs tests** - Executes test command to verify functionality
3. **Detects regressions** - Compares snapshots to find broken functionality
4. **Provides recommendations** - Suggests actions based on results
5. **Records verification** - Saves verification results to memory

## Integration

The rootcause command integrates with:
- **Debug Orchestrator** - Core analysis engine in [`src/core/debug/orchestrator`](src/core/debug/orchestrator/index.ts)
- **Memory Manager** - Records bug fixes and learns from past solutions
- **GitHub MCP** - Searches for similar issues via [`mcp__grep__searchGitHub`](mcp__grep__searchGitHub)
- **Snapshot System** - Stores before/after states for regression detection

## When to Use

Use `/rootcause analyze` when:
- Debugging complex or intermittent bugs
- Need to understand root cause before fixing
- Want to learn from similar past bugs
- Need to search for existing solutions
- Fix may have wide-ranging impact

Use `/rootcause verify` when:
- After applying a fix
- Need to ensure fix doesn't break other functionality
- Want to detect regressions early
- Working on critical systems
- Need evidence that fix works

## Best Practices

### Before Analyzing

- **Reproduce the bug** - Ensure you can consistently trigger the issue
- **Gather context** - Include error messages, logs, and reproduction steps
- **Use specific bug types** - Helps find similar patterns in memory
- **Include test command** - Enables verification workflow

### Before Verifying

- **Know your snapshot ID** - Use the ID from analyze output
- **Have a test command** - Ready to run tests for verification
- **Document the fix** - Clear description helps verify correct changes
- **Test thoroughly** - Run tests multiple times if needed

### Regression Detection

- **Review all changes** - Understand what the fix modified
- **Test related functionality** - Bugs often break related features
- **Check edge cases** - Regressions often appear in boundary conditions
- **Monitor performance** - Some fixes introduce performance issues

## Output

### Analyze Output

```
🔍 Analyzing bug
Description: Error: Cannot read property 'id'
Type: type_error
Test Command: npm test

✓ Created before snapshot: snapshot_20250113_143022
✓ Searched memory: Found 2 similar bugs
✓ Searched GitHub: Found 5 similar issues
✓ Generated fix prompt with context

Before Snapshot: snapshot_20250113_143022

Similar Bugs from Memory:
  1. [2025-01-10] TypeError: undefined property - Fixed by adding optional chaining
  2. [2025-01-15] Type error: null property - Fixed by adding null check

GitHub Solutions:
  1. Repository: typescript-eslint/typescript-eslint
     Issue: TypeError: undefined property access
     Solution: Use optional chaining (obj?.prop)
  2. Repository: facebook/react
     Issue: Cannot read property of undefined
     Solution: Add null checks before property access

Fix Prompt:
[Context from similar bugs and GitHub solutions]
[Detailed fix instructions based on analysis]
```

### Verify Output

```
✅ Verifying fix
Before Snapshot: snapshot_20250113_143022
Test Command: npm test
Fix Description: Added null check for property access

✓ Created after snapshot: snapshot_20250113_143100
✓ Running tests...
✓ Tests completed: 15 passed, 0 failed

Regression Detection:
  ✓ No regressions detected
  ✓ All functionality working as expected

Recommendation: Fix verified successfully, no action needed
```

## Related Commands

- [`/auto`](auto.md) - Autonomous mode uses rootcause for debugging
- [`/reflect`](reflect.md) - Use reflection to iterate on fix attempts
- [`/research`](research.md) - Research solutions before applying fixes

## Notes

- Snapshots are stored in `~/.claude/.debug/snapshots/`
- Memory of bug fixes helps find solutions faster for common issues
- GitHub search requires GitHub MCP to be configured
- Regression detection compares test results between before/after snapshots
- The orchestrator provides smart recommendations based on analysis
- Use `--verbose` flag for detailed analysis output
