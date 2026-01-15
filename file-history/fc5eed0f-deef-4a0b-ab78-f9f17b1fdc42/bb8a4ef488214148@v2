# Komplete Kontrol CLI - Testing Guide

## Prerequisites

1. **Set up API Key**:
   ```bash
   export ANTHROPIC_API_KEY="your-api-key-here"
   ```

2. **Build the CLI**:
   ```bash
   bun run build
   ```

3. **Make it executable** (optional):
   ```bash
   chmod +x dist/index.js
   # Or link globally
   npm link
   ```

## Testing Commands

### 1. Test `/auto` - Autonomous Mode

```bash
# Basic autonomous task
bun run dist/index.js auto "Create a simple fibonacci function"

# With options
bun run dist/index.js auto "Refactor the main function" -i 10 -v

# With specific model
bun run dist/index.js auto "Debug the authentication logic" -m "claude-sonnet-4-5" -v
```

**Expected behavior**:
- Enters autonomous ReAct + Reflexion loop
- Performs Think → Act → Observe → Reflect cycles
- Checkpoints every 10 iterations (default)
- Auto-compacts context at 80% threshold
- Records episodes to memory

### 2. Test `/sparc` - SPARC Methodology

```bash
# Basic SPARC workflow
bun run dist/index.js sparc "Build a REST API for user management"

# With requirements and constraints
bun run dist/index.js sparc "Design a caching system" \
  -r "Must handle 10k requests/sec" \
  -r "Support TTL expiration" \
  -c "Memory budget: 1GB" \
  -c "No external dependencies" \
  -v
```

**Expected behavior**:
- Phase 1: Generates detailed specification with LLM
- Phase 2: Creates pseudocode and algorithm design
- Phase 3: Designs architecture with components
- Phase 4: Refines architecture with optimizations
- Phase 5: Produces implementation guide
- All phases output structured JSON results

### 3. Test `/swarm` - Distributed Agents

```bash
# Spawn swarm of agents
bun run dist/index.js swarm spawn "Implement user authentication" -n 5 -v

# Check swarm status
bun run dist/index.js swarm status -id <swarm-id>

# Collect and merge results
bun run dist/index.js swarm collect -id <swarm-id> -v

# Clear swarm data
bun run dist/index.js swarm clear -id <swarm-id>
```

**Expected behavior**:
- Spawns N agents with decomposed tasks
- Each agent creates a branch: `swarm-<id>-agent-<n>`
- Git integration detects and auto-resolves conflicts
- Merges all agent results into comprehensive report

**Note**: Requires git repository to test merge functionality

### 4. Test `/reflect` - Reflexion Loops

```bash
# Run reflexion cycles
bun run dist/index.js reflect "Optimize database queries" -i 3 -v

# Shorter cycles for quick test
bun run dist/index.js reflect "Improve error handling" -i 2
```

**Expected behavior**:
- Runs N reflexion cycles (default: 3)
- Each cycle: Think → Act → Observe → Reflect
- LLM generates reflection insights
- Produces summary with success evaluation
- Records to memory

### 5. Test `/research` - Code Research

```bash
# Basic research query
bun run dist/index.js research "How to implement OAuth2"

# With language filter
bun run dist/index.js research "async/await patterns" --lang typescript javascript

# With source selection
bun run dist/index.js research "Redis caching strategies" -s github memory -l 20 -v
```

**Expected behavior**:
- Searches memory for relevant episodes
- Searches GitHub (mock data until MCP configured)
- LLM generates comprehensive summary
- Displays results by source type
- Records findings to memory

### 6. Test `/rootcause` - Root Cause Analysis

```bash
# Analyze a bug
bun run dist/index.js rootcause analyze \
  -b "Authentication fails on refresh" \
  -t "security" \
  -v

# Verify a fix
bun run dist/index.js rootcause verify \
  --test "npm test" \
  --snapshot <snapshot-id> \
  -f "Updated token refresh logic" \
  -v
```

**Expected behavior**:
- Creates before/after snapshots
- Searches memory for similar fixes
- Searches GitHub for solutions (mock)
- LLM generates debug recommendations
- Verifies fix with regression detection

## Quick Smoke Test

Run all commands with minimal arguments to verify they work:

```bash
#!/bin/bash

echo "=== Testing Komplete Kontrol CLI ==="

echo "\n1. Testing /auto..."
bun run dist/index.js auto "Create hello world function" -i 1

echo "\n2. Testing /sparc..."
bun run dist/index.js sparc "Build a simple API"

echo "\n3. Testing /swarm..."
bun run dist/index.js swarm spawn "Test task" -n 2

echo "\n4. Testing /reflect..."
bun run dist/index.js reflect "Optimize code" -i 1

echo "\n5. Testing /research..."
bun run dist/index.js research "TypeScript patterns"

echo "\n6. Testing /rootcause..."
bun run dist/index.js rootcause analyze -b "Sample bug" -t "general"

echo "\n=== All tests complete ==="
```

## Troubleshooting

### "Provider not available: anthropic"

**Cause**: Missing or invalid ANTHROPIC_API_KEY

**Solution**:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

### "GitHub MCP integration not available"

**Cause**: GitHub MCP server not configured

**Solution**: This is expected. ResearchCommand will use mock data for GitHub results.

To enable real GitHub search:
1. Install grep MCP server
2. Configure in `~/.claude/config.json`
3. See ResearchCommand.ts line 156 for integration TODO

### "Command not found: komplete"

**Cause**: CLI not linked globally

**Solution**:
```bash
# Option 1: Use bun directly
bun run dist/index.js <command>

# Option 2: Link globally
npm link
komplete <command>

# Option 3: Add to PATH
export PATH="$PATH:$(pwd)/dist"
./dist/index.js <command>
```

### Build errors

**Cause**: TypeScript errors or missing dependencies

**Solution**:
```bash
bun install
bun run typecheck
bun run build
```

## Expected Output Examples

### Successful SPARC Run:
```
✅ Komplete Kontrol CLI
🎯 Starting SPARC workflow
Task: Build a REST API for user management

Phase: specification
Phase: pseudocode
Phase: architecture
Phase: refinement
Phase: completion

✅ SPARC workflow completed

Result: {
  "problemStatement": "...",
  "components": [...],
  "implementationSteps": [...]
}
```

### Successful Auto Run:
```
🤖 Entering autonomous mode
Goal: Create a simple fibonacci function
Max iterations: 50

Iteration 1/50:
Think: I need to implement a fibonacci function...
Act: Create function with base cases...
Observe: Function created
Reflect: Implementation looks good...

✅ Goal achieved in 1 iteration
```

## Performance Metrics

Expected performance (with API key):
- Simple commands (auto, reflect): 5-15 seconds
- Complex workflows (sparc): 30-60 seconds
- Swarm operations: Depends on agent count
- Research: 10-20 seconds

**Note**: Initial LLM call may be slower due to model initialization.

## Next Steps

After basic testing:
1. Try complex multi-step tasks
2. Test error recovery (invalid inputs)
3. Verify memory persistence across sessions
4. Test context auto-compaction (long conversations)
5. Integrate with real projects
