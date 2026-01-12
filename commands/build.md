---
description: Autonomous feature builder - reads architecture, builds, tests, loops
argument-hint: "[feature-name] [--from architecture.md]"
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep", "Task", "mcp__grep__searchGitHub", "WebSearch"]
---

# Autonomous Build Command

> **Prompting Principles** (keep prompts token-effective):
> - Short, focused prompts > long essays. Agent is smart.
> - Reference docs, don't dump them. Summarize what's needed.
> - Work in focused sets. One feature family per session.
> - Describe what you see, not file paths. Let agent navigate.

Build features autonomously by:
1. Reading architecture documents (summarized, not dumped)
2. **Searching for working code examples** (grep MCP)
3. Implementing incrementally (focused, small steps)
4. **Logging all fix attempts** to debug-log.md
5. **Researching errors online** when stuck
6. Validating after each step
7. **Auto-continuing** until complete or blocked

## Usage

```
/build                           # Continue from buildguide.md next section
/build auth-system               # Build specific feature
/build --from docs/architecture.md   # Use specific architecture doc
```

## Instructions

Parse arguments: $ARGUMENTS

### Step 0: Initialize Debug Log

Ensure `.claude/docs/debug-log.md` exists:

```bash
mkdir -p .claude/docs
if [[ ! -f .claude/docs/debug-log.md ]]; then
    # Create from template or initialize
    cat > .claude/docs/debug-log.md << 'EOF'
# Debug Log

> Last Updated: [DATE]

## Active Issues

## Session: [TODAY]

---

## Resolved Issues

## Patterns Discovered

## Research Cache
EOF
fi
```

Add session header for today if not exists.

### Step 1: Load Architecture Context

**Find and read architecture documents in this order:**

1. If `--from <file>` specified, read that file
2. Otherwise check these locations:
   - `buildguide.md` (preferred - has implementation plan)
   - `ARCHITECTURE.md`
   - `docs/architecture.md`
   - `.claude/docs/architecture.md`
   - `CLAUDE.md` (fallback)

Extract from architecture:
- **Tech stack** (language, framework, tools)
- **Project structure** (directories, patterns)
- **Quality commands** (lint, typecheck, test commands)
- **Current section** to implement (from buildguide.md checklist)

### Step 2: Determine Build Target

**If feature name provided:**
- Find matching section in buildguide.md
- Read its Implementation Approach

**If no feature name:**
- Find first unchecked `- [ ]` section in buildguide.md
- That's the build target

**Extract from section:**
- What to build (Overview)
- How it fits (Architecture Fit)
- Implementation steps (Implementation Approach)
- Files to create/modify

### Step 3: Research Before Building ⭐ NEW

**Before implementing, search for working examples:**

Use `mcp__grep__searchGitHub` to find real-world code:

```
For each key component to implement:

1. Search for the pattern:
   - query: "[library/framework] [feature]"
   - language: [project language]

2. Search for similar implementations:
   - query: "[feature name] implementation"
   - language: [project language]

3. Search in test files for usage examples:
   - query: "[feature]"
   - path: "*test*" or "*spec*"
```

**Log research to debug-log.md:**

```markdown
### Research: [feature name]
**Time**: [timestamp]
**Searches performed**:
1. [query 1] → [X results]
2. [query 2] → [X results]

**Useful patterns found**:
- [Pattern 1 from repo/file]
- [Pattern 2 from repo/file]

**Implementation approach based on research**:
[Summary of best practices discovered]
```

### Step 4: Create Build Plan

Write a `.claude/current-build.local.md` state file:

```markdown
---
feature: [feature name]
phase: implementing
started: [timestamp]
iteration: 1
fix_attempts: 0
research_done: true
---

## Build Target
[What we're building]

## Research Insights
[Key patterns from Step 3]

## Implementation Steps
1. [ ] Step 1
2. [ ] Step 2
...

## Quality Gates
- [ ] Lint passes
- [ ] Types check
- [ ] Tests pass
- [ ] No regressions

## Files to Modify
- [file list from architecture]
```

### Step 5: Implement Incrementally

For each implementation step:

1. **Announce** what you're implementing
2. **Reference** research insights from Step 3
3. **Implement** the code changes following discovered patterns
4. **Auto-quality check** runs via PostToolUse hook (lint, types)
5. **If errors**: Go to Step 6 (Error Resolution)
6. **Mark step complete** in current-build.local.md
7. **Continue** to next step

### Step 6: Smart Error Resolution ⭐ ENHANCED

**Error Classification System** (from Discord.js, neo4j, midday-ai patterns):

| Classification | Retry? | Action |
|---------------|--------|--------|
| TRANSIENT | Yes | Network/timeout - retry with backoff |
| RATE_LIMIT | Yes | Wait longer, then retry |
| CLIENT_ERROR | No | Fix code (syntax, type, validation) |
| BUILD_ERROR | No | Fix code (lint, compile errors) |
| DATABASE_ERROR | Maybe | Check connection, retry once |
| UNKNOWN | Once | Retry once, then investigate |

**6a. Classify the error first:**
```
Look at error message and classify:
- TRANSIENT: timeout, network, 502/503/504
- RATE_LIMIT: 429, "too many requests"
- CLIENT_ERROR: syntax error, type error, 400/401/403
- BUILD_ERROR: "cannot find", lint error, compile failed
- DATABASE_ERROR: connection, postgres, deadlock
```

**6b. If TRANSIENT/RATE_LIMIT - auto retry with backoff:**
```
Retry up to 3 times with exponential backoff:
- Attempt 1: wait 1s
- Attempt 2: wait 2s
- Attempt 3: wait 4s
- RATE_LIMIT: multiply delays by 5
```

**6c. If CLIENT_ERROR/BUILD_ERROR - research and fix:**
```
1. Extract key error pattern (not full message)
2. Search GitHub: mcp__grep__searchGitHub
   - query: "[error code or pattern]"
   - language: [project language]
3. If < 3 results, search web:
   - WebSearch: "[error] [framework] fix"
```

**6d. Log to debug-log.md with classification:**
```markdown
### Issue: [CLASSIFICATION] - [brief description]
**Time**: [timestamp]
**Classification**: [CLIENT_ERROR|BUILD_ERROR|etc]
**Retryable**: [true/false]
**Error**: `[core error message]`
**File**: [file:line if available]
**Research**: [X GitHub results, Y web sources]
**Solution**: [what fixed it or "STUCK"]
```

**6e. Try fixes based on research:**
```
For each potential fix (max 3):
1. Apply fix
2. Run validation
3. If pass → log success, continue
4. If fail → log attempt, try next
```

**6f. After 3 failed fixes:**
- Search web with different terms
- Check GitHub Issues for the library
- Look for version-specific issues

**6g. After 5 failed fixes:**
- Mark as "STUCK - [classification]" in debug-log.md
- **DO NOT BLOCK** - continue to next task
- Agent will revisit stuck issues at end of build

### Step 7: After Implementation Complete

Run full validation:

```bash
# Detect and run quality commands based on project type
if [[ -f package.json ]]; then
    npm run lint 2>&1 || true
    npm run typecheck 2>&1 || npx tsc --noEmit 2>&1 || true
    npm test 2>&1 || true
elif [[ -f pyproject.toml ]] || [[ -f requirements.txt ]]; then
    ruff check . 2>&1 || pylint **/*.py 2>&1 || true
    mypy . 2>&1 || true
    pytest 2>&1 || true
elif [[ -f go.mod ]]; then
    go vet ./... 2>&1 || true
    staticcheck ./... 2>&1 || true
    go test ./... 2>&1 || true
elif [[ -f Cargo.toml ]]; then
    cargo clippy 2>&1 || true
    cargo test 2>&1 || true
fi
```

### Step 8: Handle Validation Failures

**If any quality gate fails:**

1. Parse error output
2. Group errors by type (lint, type, test)
3. **For each error group, research solutions first:**

```
Use mcp__grep__searchGitHub to find how others solved similar issues
Log findings to debug-log.md
```

4. Spawn parallel fix agents WITH research context:

```
Use the Task tool to spawn 3 agents in parallel:

Agent 1 (if lint errors):
- Research: Search for "[lint rule]" fix examples
- Fix all lint errors using discovered patterns
- Log each fix attempt to debug-log.md
- Re-run lint to verify

Agent 2 (if type errors):
- Research: Search for the type error pattern
- Fix all type errors
- Log each fix attempt to debug-log.md
- Re-run typecheck to verify

Agent 3 (if test failures):
- Research: Search for similar test failure patterns
- Analyze root cause
- Fix code or update tests
- Log each fix attempt to debug-log.md
- Re-run tests to verify
```

5. After agents complete, run validation again
6. Loop until all gates pass (max 3 iterations)
7. **If still failing after 3 iterations:**
   - Log to debug-log.md as unresolved
   - Continue to next feature (don't block)
   - Mark in buildguide.md with ⚠️

### Step 9: Mark Complete and Continue

When all quality gates pass:

1. **Update current-build.local.md**:
   - Set `phase: complete`
   - Check all quality gates
   - Note total fix_attempts

2. **Update buildguide.md**:
   - Mark section complete: `- [ ]` → `- [x]`

3. **Update debug-log.md**:
   - Move resolved issues to "Resolved Issues" section
   - Add to "Patterns Discovered" if new patterns found
   - Cache useful code examples in "Research Cache"

4. **Run /checkpoint**:
   - Saves state to CLAUDE.md
   - Generates continuation prompt
   - Advances to next section

5. **Check context usage**:
   - If < 40%: Continue to next section automatically
   - If >= 40%: Let auto-continue hook handle compaction

6. **Loop**:
   - Find next unchecked section
   - Go back to Step 2
   - Continue until all sections complete or user says "stop"

### Step 9.5: Revisit Stuck Issues ⭐ NEW

Before completion, revisit any STUCK issues:

```bash
# Check for stuck issues
STUCK_COUNT=$(grep -c "STUCK" .claude/docs/debug-log.md 2>/dev/null || echo "0")
```

**If stuck issues exist:**

1. **Re-attempt with fresh context:**
   - Read the stuck issue from debug-log.md
   - Search GitHub with different query terms
   - Search web for latest solutions (2024/2025)

2. **Try alternative approaches:**
   - If library issue: check for alternative library
   - If type error: try type assertion or any cast (temporary)
   - If test failure: check if test itself is wrong

3. **For each stuck issue, either:**
   - ✅ Fix it and mark resolved
   - ⚠️ Document workaround and continue
   - ❌ Mark as "REQUIRES_HUMAN" with detailed context

4. **Update debug-log.md:**
```markdown
### Revisited: [Issue]
**Original Classification**: [X]
**Second Attempt Result**: [FIXED|WORKAROUND|REQUIRES_HUMAN]
**Resolution**: [what was done]
```

### Step 10: Completion

When all sections in buildguide.md are checked:

```
✅ Build Complete!

All sections implemented:
- [x] Section 1
- [x] Section 2
...

Quality verified:
- Lint: ✅
- Types: ✅
- Tests: ✅

Debug Log Summary:
- Total issues encountered: [N]
- Issues resolved: [N]
- Stuck issues revisited: [N]
- Still requiring human: [N]
- Patterns discovered: [N]

See .claude/docs/debug-log.md for full history.

Run /checkpoint to save final state.
```

## Stopping the Build

Say "stop", "pause", or "hold" to pause autonomous building.
The current state is saved in `.claude/current-build.local.md`.

Resume with `/build` - it will continue from where it stopped.

## Integration

This command integrates with:
- `/collect` - Gathers architecture into buildguide.md
- `/checkpoint` - Saves state after each feature
- `/research` - Deep-dive into specific patterns or errors
- `/log-fix` - Quick fix logging
- Auto-continue hook - Handles context compaction
- PostToolUse hook - Auto-lints after every edit
- **mcp__grep__searchGitHub** - Finds working code examples
- **WebSearch** - Researches error solutions online

## Advanced Infrastructure ⭐ NEW

The build system now includes enterprise-grade infrastructure:

### Task Queue System
```bash
# Priority-based task management (from DataDog, piscina patterns)
~/.claude/hooks/task-queue.sh add "implement-feature" 1  # Priority 1 (highest)
~/.claude/hooks/task-queue.sh next                       # Get next task
~/.claude/hooks/task-queue.sh complete <task_id>         # Mark complete
~/.claude/hooks/task-queue.sh status                     # Queue status
```

### Progress Tracking with ETA
```bash
# Build progress with time estimation (from elizaOS, rancher-desktop patterns)
~/.claude/hooks/progress-tracker.sh start "feature-build" 10  # 10 steps
~/.claude/hooks/progress-tracker.sh update 1 "Step 1" "Implementing..."
~/.claude/hooks/progress-tracker.sh complete-step 1 "Step 1" 30  # 30 seconds
~/.claude/hooks/progress-tracker.sh summary              # Human-readable progress
~/.claude/hooks/progress-tracker.sh eta                  # Estimated completion
```

### Metrics Collection
```bash
# Build and session metrics (from claude-flow, rushstack patterns)
~/.claude/hooks/metrics-collector.sh start               # Start session
~/.claude/hooks/metrics-collector.sh build "feature" "success" 120 5 2
~/.claude/hooks/metrics-collector.sh error "BUILD_ERROR" "type error"
~/.claude/hooks/metrics-collector.sh fix "BUILD_ERROR" "added type annotation"
~/.claude/hooks/metrics-collector.sh research "query" "github" 10 true
~/.claude/hooks/metrics-collector.sh summary             # View metrics
```

### Lock Management
```bash
# Prevent concurrent builds (from vscode, joplin patterns)
~/.claude/hooks/lock-manager.sh acquire "build"          # Acquire lock
~/.claude/hooks/lock-manager.sh check "build"            # Check if locked
~/.claude/hooks/lock-manager.sh release "build"          # Release lock
~/.claude/hooks/lock-manager.sh with "build" npm test    # Execute with lock
```

### Graceful Shutdown
```bash
# Clean shutdown with state preservation (from medusa, n8n patterns)
~/.claude/hooks/graceful-shutdown.sh register            # Register handler
~/.claude/hooks/graceful-shutdown.sh save "checkpoint"   # Save state
~/.claude/hooks/graceful-shutdown.sh shutdown "user"     # Initiate shutdown
~/.claude/hooks/graceful-shutdown.sh continue            # Create continuation
```

### Circuit Breaker & Self-Healing
```bash
# Prevents cascading failures (from claude-flow patterns)
~/.claude/hooks/self-healing.sh health                   # Check health
~/.claude/hooks/self-healing.sh recover                  # Full recovery
~/.claude/hooks/self-healing.sh checkpoint "pre-build"   # Save checkpoint
~/.claude/hooks/self-healing.sh rollback                 # Restore checkpoint
```

### Error Classification & Retry
```bash
# Smart error handling (from Discord.js, neo4j patterns)
~/.claude/hooks/error-handler.sh "timeout error" 0 3     # Classify & retry info
~/.claude/hooks/retry-command.sh 3 npm test              # Retry with backoff
```

## Build Lifecycle with Infrastructure

```
┌─────────────────────────────────────────────────────────────────┐
│                    BUILD LIFECYCLE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. INITIALIZE                                                   │
│     ├── lock-manager.sh acquire "build"                         │
│     ├── metrics-collector.sh start                              │
│     ├── progress-tracker.sh start "build" [steps]               │
│     └── self-healing.sh health                                  │
│                                                                  │
│  2. EXECUTE (for each step)                                      │
│     ├── task-queue.sh add "step-name" [priority]                │
│     ├── progress-tracker.sh update [step] [name]                │
│     ├── [implement step]                                         │
│     ├── error-handler.sh [error] → classify & retry             │
│     ├── metrics-collector.sh error/fix [details]                │
│     └── progress-tracker.sh complete-step [step]                │
│                                                                  │
│  3. VALIDATE                                                     │
│     ├── retry-command.sh 3 npm run lint                         │
│     ├── retry-command.sh 3 npm run typecheck                    │
│     └── retry-command.sh 3 npm test                             │
│                                                                  │
│  4. COMPLETE                                                     │
│     ├── progress-tracker.sh finish "success"                    │
│     ├── metrics-collector.sh build [name] [status] [duration]   │
│     ├── metrics-collector.sh end                                │
│     ├── lock-manager.sh release "build"                         │
│     └── self-healing.sh checkpoint "post-build"                 │
│                                                                  │
│  ON INTERRUPT (SIGINT/SIGTERM):                                  │
│     ├── graceful-shutdown.sh shutdown "interrupt"               │
│     ├── graceful-shutdown.sh save "interrupted"                 │
│     └── graceful-shutdown.sh continue                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Autonomy Framework ⭐ NEW

True autonomous operation with self-reflection, planning, and intelligent execution:

### Thinking Framework
```bash
# Self-reflection and chain-of-thought reasoning (from mcp-think-tank, midday-ai, cipher)
~/.claude/hooks/thinking-framework.sh start "implement feature X"  # Start thinking session
~/.claude/hooks/thinking-framework.sh step "analyze" "Understanding requirements"
~/.claude/hooks/thinking-framework.sh step "plan" "Design implementation approach"
~/.claude/hooks/thinking-framework.sh reflect "quality"            # Self-critique
~/.claude/hooks/thinking-framework.sh check-loops                  # Detect reasoning loops
~/.claude/hooks/thinking-framework.sh complete "implementation done" 0.9  # Complete session
~/.claude/hooks/thinking-framework.sh cot-prompt "task"           # Generate CoT prompt
```

### Agent Loop
```bash
# Autonomous execution with tool calling (from Roo-Code, UI-TARS, TanStack)
~/.claude/hooks/agent-loop.sh start "build feature" "context"     # Start agent
~/.claude/hooks/agent-loop.sh transition "executing" "starting"   # State transition
~/.claude/hooks/agent-loop.sh should-continue                      # Check loop conditions
~/.claude/hooks/agent-loop.sh execute run_tests                    # Execute tool
~/.claude/hooks/agent-loop.sh execute lint_code                    # Execute tool
~/.claude/hooks/agent-loop.sh execute shell "npm run build"        # Shell command
~/.claude/hooks/agent-loop.sh success "tests passed"               # Record success
~/.claude/hooks/agent-loop.sh failure "lint failed"                # Record failure
~/.claude/hooks/agent-loop.sh complete "success" "feature built"   # Complete agent
~/.claude/hooks/agent-loop.sh summary                              # Human-readable summary
```

### Plan and Execute
```bash
# Task decomposition with replanning (from langchainjs, n8n, AgentGPT)
~/.claude/hooks/plan-execute.sh create "implement auth system"     # Create plan
~/.claude/hooks/plan-execute.sh decompose "auth" "feature"         # Get step template
~/.claude/hooks/plan-execute.sh add-step "Design API" "shell"      # Add step
~/.claude/hooks/plan-execute.sh add-step "Write tests" "shell" "" "step1"  # With dependency
~/.claude/hooks/plan-execute.sh next                               # Get next executable step
~/.claude/hooks/plan-execute.sh start "step_123"                   # Start step
~/.claude/hooks/plan-execute.sh complete "step_123" "success"      # Complete step
~/.claude/hooks/plan-execute.sh should-replan                      # Check if replan needed
~/.claude/hooks/plan-execute.sh replan "approach not working"      # Trigger replanning
~/.claude/hooks/plan-execute.sh insert "step_123" "new step"       # Insert during replan
~/.claude/hooks/plan-execute.sh status                             # Progress stats
```

### Code Quality Checker
```bash
# Comprehensive quality checks (from eslint, ruff, golangci-lint patterns)
~/.claude/hooks/code-quality.sh detect                             # Detect project type
~/.claude/hooks/code-quality.sh lint                               # Run linter
~/.claude/hooks/code-quality.sh typecheck                          # Run type checker
~/.claude/hooks/code-quality.sh security                           # Run security scan
~/.claude/hooks/code-quality.sh tests                              # Run test suite
~/.claude/hooks/code-quality.sh complexity                         # Analyze complexity
~/.claude/hooks/code-quality.sh full                               # Full quality report
```

### Validation Gates
```bash
# Pre-execution safety checks (from oracle, langchain guardrails)
~/.claude/hooks/validation-gate.sh command "rm -rf /"              # Validate command → BLOCKED
~/.claude/hooks/validation-gate.sh file write "/etc/passwd"        # Validate file op → BLOCKED
~/.claude/hooks/validation-gate.sh code "eval(input)" "python"     # Validate code → WARNING
~/.claude/hooks/validation-gate.sh gate command "npm test"         # Full gate check
~/.claude/hooks/validation-gate.sh preflight .                     # Pre-build checks
~/.claude/hooks/validation-gate.sh resources 4096 80               # Check resources
~/.claude/hooks/validation-gate.sh stats                           # Gate statistics
```

### Memory Manager ⭐ NEW
```bash
# Persistent memory system (from Generative Agents, MemGPT, Mem0, LangChain)
~/.claude/hooks/memory-manager.sh set-task "implement feature X"   # Set current task
~/.claude/hooks/memory-manager.sh add-context "uses React" 8       # Add context (1-10 importance)

# Episodic Memory (past experiences)
~/.claude/hooks/memory-manager.sh record task_complete "Built auth" success "JWT tokens"
~/.claude/hooks/memory-manager.sh search-episodes "authentication" # Search past work
~/.claude/hooks/memory-manager.sh recent-episodes 5                # Recent history

# Semantic Memory (facts & patterns)
~/.claude/hooks/memory-manager.sh add-fact project api_version "v2"
~/.claude/hooks/memory-manager.sh add-pattern error_fix "CORS error" "Add proxy config"
~/.claude/hooks/memory-manager.sh find-patterns "timeout"          # Find known solutions

# Retrieval (combines recency + relevance + importance)
~/.claude/hooks/memory-manager.sh remember "API errors" 5          # Simple search
~/.claude/hooks/memory-manager.sh remember-scored "API errors" 5   # 3-factor scored search
~/.claude/hooks/memory-manager.sh context                          # Current working context

# Reflection (consolidation)
~/.claude/hooks/memory-manager.sh reflect progress "Session summary" "Key insights"
~/.claude/hooks/memory-manager.sh stats                            # Memory statistics
```

See `~/.claude/docs/memory-systems.md` for complete architecture documentation.

## Autonomous Build Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTONOMOUS BUILD                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  0. REMEMBER (memory-manager.sh)                                 │
│     ├── remember-scored "[feature]" 5                            │
│     ├── find-patterns "[feature]"                                │
│     └── set-task "[feature]"                                     │
│                                                                  │
│  1. THINK (thinking-framework.sh)                                │
│     ├── start "implement [feature]"                              │
│     ├── step "analyze" "Understanding requirements"              │
│     ├── step "plan" "Design approach"                            │
│     ├── check-loops                                              │
│     └── reflect "quality"                                        │
│                                                                  │
│  2. PLAN (plan-execute.sh)                                       │
│     ├── create "[feature]"                                       │
│     ├── decompose "[task]" "feature"                             │
│     ├── add-step [each step with dependencies]                   │
│     └── status                                                   │
│                                                                  │
│  3. VALIDATE (validation-gate.sh)                                │
│     ├── preflight .                                              │
│     ├── resources 4096 80                                        │
│     └── gate command [each planned command]                      │
│                                                                  │
│  4. EXECUTE (agent-loop.sh)                                      │
│     ├── start "[feature]"                                        │
│     ├── while should-continue:                                   │
│     │   ├── plan-execute.sh next → get step                      │
│     │   ├── validation-gate.sh gate command [step]               │
│     │   ├── execute [tool] [args]                                │
│     │   ├── code-quality.sh lint (after code changes)            │
│     │   ├── success/failure [result]                             │
│     │   └── plan-execute.sh complete/fail [step_id]              │
│     ├── transition "validating"                                  │
│     └── code-quality.sh full                                     │
│                                                                  │
│  5. REFLECT (thinking-framework.sh)                              │
│     ├── step "validate" "Checking implementation"                │
│     ├── reflect "completeness"                                   │
│     ├── reflect "quality"                                        │
│     └── complete "[conclusion]" [score]                          │
│                                                                  │
│  6. REPLAN IF NEEDED (plan-execute.sh)                           │
│     ├── should-replan                                            │
│     ├── replan "reason"                                          │
│     └── insert [new steps as needed]                             │
│     → Go back to step 4                                          │
│                                                                  │
│  7. COMPLETE                                                     │
│     ├── plan-execute.sh finish "success"                         │
│     ├── agent-loop.sh complete "success"                         │
│     └── Update buildguide.md                                     │
│                                                                  │
│  8. REMEMBER (memory-manager.sh)                                 │
│     ├── record task_complete "[feature]" success "[details]"     │
│     ├── add-pattern workflow "[trigger]" "[solution]"            │
│     ├── reflect progress "[summary]" "[insights]"                │
│     └── clear-working                                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Summary of Patterns Used

| Component | Source Pattern | Features |
|-----------|---------------|----------|
| Task Queue | DataDog, piscina, claude-flow | Priority, dependencies, retry |
| Progress Tracker | elizaOS, rancher-desktop | ETA calculation, step tracking |
| Metrics Collector | claude-flow, rushstack | Session metrics, aggregates |
| Lock Manager | vscode, joplin, medusa | File locks, stale detection |
| Graceful Shutdown | medusa, n8n, firecrawl | State preservation, signals |
| Circuit Breaker | claude-flow | Failure prevention, reset |
| Error Classification | Discord.js, neo4j | Smart retry, categorization |
| Self-Healing | Roo-Code, aiometadata | Auto-recovery, checkpoints |
| Thinking Framework | mcp-think-tank, midday-ai, cipher | Self-reflection, CoT, loop detection |
| Agent Loop | Roo-Code, UI-TARS, TanStack | State machine, tool execution |
| Plan & Execute | langchainjs, n8n, AgentGPT | Task decomposition, replanning |
| Code Quality | eslint, ruff, golangci-lint | Multi-language quality checks |
| Validation Gates | oracle, langchain guardrails | Pre-execution safety checks |
| Memory Manager | Generative Agents, MemGPT, Mem0 | 3-factor retrieval, patterns, reflection |

## Reverse Engineering Toolkit ⭐ NEW

When dealing with undocumented APIs, mobile apps, or binary protocols:

### Quick Reference
```bash
# Read the full RE toolkit
cat ~/.claude/docs/reverse-engineering-toolkit.md

# Ready-to-use Frida scripts
cat ~/.claude/docs/frida-scripts.md

# API research command
/research-api web https://api.target.com
/research-api mobile com.target.app
/research-api protocol grpc://service:50051
```

### When to Use RE Toolkit
| Situation | Action |
|-----------|--------|
| Undocumented API | mitmproxy → Kiterunner → Schemathesis |
| Mobile app integration | JADX decompile → Frida SSL bypass → traffic capture |
| Binary protocol | protoc --decode_raw → pbtk → schema recovery |
| Rate limited/detected | JA3 fingerprint check → puppeteer-stealth |
| GraphQL without docs | InQL → Clairvoyance → schema reconstruction |
| Hidden endpoints | Kiterunner shadow API scan |

### SSL Pinning Bypass (Quick)
```bash
# Android - one command
objection -g "com.target.app" explore --startup-command "android sslpinning disable"

# iOS - one command
objection -g "App Name" explore --startup-command "ios sslpinning disable"

# With Frida script
frida -U -f com.target.app -l ~/.claude/docs/frida-scripts/ssl_bypass.js --no-pause
```

### Protobuf Decode (Quick)
```bash
# Raw decode unknown protobuf
cat response.bin | protoc --decode_raw

# Extract .proto from APK
pbtk extract app.apk -o protos/
```

### Traffic Capture (Quick)
```bash
# Start mitmproxy
mitmproxy -p 8080

# With script to log/modify
mitmdump -p 8080 -s ~/.claude/hooks/mitm_logger.py
```

### Integration with Error Resolution

When build errors are related to external APIs:

```
Error: "API endpoint not found" or "401 Unauthorized"
  → Check ~/.claude/docs/reverse-engineering-toolkit.md
  → Use /research-api to discover correct endpoints
  → Log findings to debug-log.md

Error: "SSL certificate verification failed"
  → Mobile app with pinning detected
  → Use Frida SSL bypass scripts
  → Capture actual API traffic with mitmproxy

Error: "Unknown binary format" or "protobuf decode failed"
  → Use protoc --decode_raw
  → Extract .proto definitions with pbtk
  → Document discovered schema
```
