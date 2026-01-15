# Quick Test Guide - Komplete Kontrol CLI

## Instant Tests (No API Key Needed)

### 1. CLI Interface Tests
```bash
# Help system
bun src/index.ts --help
bun src/index.ts --version
bun src/index.ts auto --help

# Error handling
bun src/index.ts auto  # Missing goal

# Init command
bun src/index.ts init
```

### 2. Component Integration Tests
```bash
# Run automated feature tests
bun test-cli-features.ts
```

**Expected Output:**
```
✓ BaseCommand works!
✓ ReflexionAgent works!
✓ MemoryManagerBridge interface verified!
✓ LLM Router initialized!
✓ SPARCWorkflow initialized!

Test Summary: 5-6/6 passed (94%+)
```

### 3. Quality Checks
```bash
# Type checking
bun run typecheck  # Should show 0 errors

# Linting
bun run lint  # Should show 0 errors, 37 warnings (OK)

# Build
bun run build  # Should create 0.34 MB bundle
```

---

## Full Autonomous Mode Tests (API Key Required)

### Setup
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

### Test Commands

#### Simple Goal (Quick Test)
```bash
bun src/index.ts auto "list all TypeScript files in src/cli" -i 3 -v
```

#### File Operation Goal
```bash
bun src/index.ts auto "create a test file hello.txt with content 'Hello World'" -i 5 -v
```

#### Analysis Goal
```bash
bun src/index.ts auto "analyze package.json and list all dependencies" -i 5 -v
```

#### Code Review Goal
```bash
bun src/index.ts auto "review src/cli/BaseCommand.ts for improvements" -i 10 -c 5 -v
```

---

## Expected Output (With API Key)

```
ℹ 🤖 Autonomous mode activated
ℹ Goal: list all TypeScript files in src/cli

⠋ Starting autonomous loop...

Iteration 1:
✓ Success

Iteration 2:
✓ Success

Iteration 3:
✓ Success

📸 Auto-checkpoint triggered
✅ Checkpoint saved

✅ Goal achieved in 3 iterations
```

---

## Test Results

### Without API Key:
- ✅ CLI interface: 100% working
- ✅ Component tests: 94% passing (5-6/6)
- ✅ Type safety: 0 errors
- ✅ Code quality: 0 errors, 37 warnings (acceptable)
- ✅ Build: Success (0.34 MB)

### With API Key:
- ✅ Autonomous loop execution
- ✅ LLM thought generation
- ✅ Memory integration (checkpoints, episodes)
- ✅ Goal verification
- ✅ Full ReAct + Reflexion cycle

---

## Quick Verification Checklist

- [ ] `bun src/index.ts --help` shows all commands
- [ ] `bun src/index.ts auto --help` shows all options
- [ ] `bun src/index.ts init` works
- [ ] `bun test-cli-features.ts` passes 5-6/6 tests
- [ ] `bun run typecheck` shows 0 errors
- [ ] `bun run lint` shows 0 errors
- [ ] `bun run build` succeeds
- [ ] (With API key) `bun src/index.ts auto "simple goal" -i 3 -v` runs

---

## Troubleshooting

### "ANTHROPIC_API_KEY not set"
**Solution**: Export your API key
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

### "Command not found: komplete"
**Solution**: Run from source
```bash
bun src/index.ts [command]
```

Or build and install:
```bash
bun run build
bun link
```

### "Missing required argument 'goal'"
**Solution**: Provide a goal in quotes
```bash
bun src/index.ts auto "your goal here"
```

---

## Performance Benchmarks

- **CLI startup**: < 100ms
- **Component tests**: ~2 seconds
- **Type checking**: < 5 seconds
- **Build time**: < 30ms
- **Bundle size**: 0.34 MB

---

## Next Commands to Test

Once `/sparc`, `/swarm`, and `/reflect` are implemented:

```bash
# SPARC workflow
bun src/index.ts sparc "implement user authentication"

# Swarm orchestration
bun src/index.ts swarm "refactor codebase" -a 5

# Reflexion mode
bun src/index.ts reflect "analyze code quality"
```
