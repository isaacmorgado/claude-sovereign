# Quickstart: Using /auto Command

**Status**: ✅ Functional as of 2026-01-13
**Capability**: 60% (simple tasks work, complex tasks need enhancements)

## What Works Now

The `/auto` command can now:
- ✅ Create files with real content
- ✅ Generate TypeScript code using LLM
- ✅ Execute bash commands (tsc, git, etc.)
- ✅ Edit existing files with regex patterns
- ✅ Run for 1-50 iterations with progressive work
- ✅ Works with GLM 4.7 (free tier) or Claude Sonnet

## Quick Examples

### Example 1: Simple File Creation (3 iterations)
```bash
bun run dist/index.js auto "Create a simple hello.ts file with a hello world function" -i 3 -v
```

**Result**: Creates `hello.ts` with:
```typescript
export function hello(): string {
  return "Hello, World";
}
```

### Example 2: Utility Function (5 iterations)
```bash
bun run dist/index.js auto "Create utils.ts with a function to format dates" -i 5 -v
```

### Example 3: TypeScript Interface (5 iterations)
```bash
bun run dist/index.js auto "Create types.ts with User and Product interfaces" -i 5 -v
```

### Example 4: Test File (10 iterations)
```bash
bun run dist/index.js auto "Create hello.test.ts with unit tests for hello function" -i 10 -v
```

## Command Options

```bash
bun run dist/index.js auto "<goal>" [options]

Options:
  -i, --iterations <N>    Max iterations (default: 50)
  -v, --verbose          Show detailed cycle information
  --model <model>        Use specific model (e.g., "glm-4.7", "claude-sonnet-4.5")
```

## Understanding Iterations

Each iteration follows the **ReAct + Reflexion** pattern:

1. **THINK**: LLM generates reasoning about next step
2. **ACT**: ActionExecutor executes real file operation/command
3. **OBSERVE**: System records result of action
4. **REFLECT**: Agent learns from outcome

**Example iteration output**:
```
Iteration 1:
  Thought: Need to create hello.ts with Hello World function
  Action: file_write({"path":"hello.ts","content":"..."})
  Result: ✅ File written: hello.ts (72 bytes)
  Reflection: File successfully created/updated
```

## What to Expect

### Successful Tasks (1-10 iterations)
- Single file creation
- Simple function generation
- TypeScript interface definitions
- Basic utility functions

### May Need Multiple Attempts (10-30 iterations)
- Multi-file projects
- Complex class implementations
- Integration with existing code
- Test file generation

### Not Yet Recommended (>30 iterations)
- Full feature implementations
- Complex refactoring across multiple files
- Production-ready code (needs testing integration)

## Current Limitations

1. **No state awareness** - May recreate files that already exist
2. **No testing integration** - Doesn't run tsc or tests after generation
3. **Limited context** - Doesn't see filesystem state between iterations
4. **Simple goal detection** - May not know when truly complete

## Troubleshooting

### "Max iterations reached without achieving goal"
- **Cause**: Goal too complex or iterations too low
- **Fix**: Increase iterations with `-i 50` or simplify goal

### Files created but with errors
- **Cause**: No TypeScript compilation check
- **Fix**: Manually run `tsc --noEmit` after completion

### Same file created multiple times
- **Cause**: No state awareness yet
- **Fix**: Expected behavior, will be improved in next version

### "LLM verification unavailable"
- **Cause**: Rate limit or API issue
- **Fix**: Agent uses heuristic fallback (3 successful cycles = goal achieved)

## Tips for Best Results

### Write Clear Goals
✅ **Good**: "Create hello.ts with a hello world function"
❌ **Bad**: "Make a file"

✅ **Good**: "Create User interface with name, email, and age fields"
❌ **Bad**: "Do the types"

### Start Small
Begin with 3-5 iterations for simple tasks, then increase for complex ones.

### Use Verbose Mode
Add `-v` to see detailed reasoning and actions:
```bash
bun run dist/index.js auto "your goal" -i 5 -v
```

### Specify File Paths
Include paths in your goal for clarity:
```bash
"Create src/utils/formatDate.ts with date formatting function"
```

## Next Session Enhancements

Planned improvements:
1. **State awareness** - Check if files exist before creating
2. **Testing integration** - Run `tsc --noEmit` after file creation
3. **MCP tool integration** - Use Read/Write/Edit tools
4. **Smarter goal detection** - Verify files exist and compile
5. **Multi-step planning** - Break complex goals into phases

## Advanced Usage

### Custom Model Selection
```bash
# Use Claude Sonnet (if API key available)
bun run dist/index.js auto "task" --model "anthropic/claude-sonnet-4.5"

# Use GLM 4.7 (default)
bun run dist/index.js auto "task" --model "glm-4.7"
```

### Combine with Other Commands

```bash
# Create code with /auto, then checkpoint
bun run dist/index.js auto "Create logger.ts" -i 10
bun run dist/index.js checkpoint "Created logger implementation"

# Test compilation after /auto
bun run dist/index.js auto "Create types.ts" -i 5
tsc --noEmit
```

## Examples to Try

**Beginner** (3-5 iterations):
```bash
bun run dist/index.js auto "Create math.ts with add and multiply functions" -i 5 -v
```

**Intermediate** (10-20 iterations):
```bash
bun run dist/index.js auto "Create Logger class with info, warn, error methods" -i 15 -v
```

**Advanced** (30-50 iterations):
```bash
bun run dist/index.js auto "Create complete user authentication module" -i 50 -v
```

## Verification

After `/auto` completes, verify your code:

```bash
# Check TypeScript compilation
tsc --noEmit

# Run tests (if created)
bun test

# View created files
ls -lh *.ts
```

## Need Help?

- **Root cause analysis**: `AUTO-COMMAND-BLOCKING-ANALYSIS.md`
- **Fix verification**: `AUTO-COMMAND-FIX-VERIFIED.md`
- **Full test results**: `SMOKE-TEST-RESULTS.md`

---

**Ready to test?** Start with a simple goal and 5 iterations:
```bash
bun run dist/index.js auto "Create greet.ts with a greeting function" -i 5 -v
```
