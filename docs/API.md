---
type: reference
title: Claude Sovereign API Reference
created: 2026-01-17
tags:
  - api
  - reference
  - hooks
related:
  - "[[Memory-System]]"
  - "[[Swarm-Orchestrator]]"
  - "[[Coordinator]]"
---

# Claude Sovereign API Reference

This document provides comprehensive API documentation for all hooks in the Claude Sovereign autonomous system. Each hook's CLI interface is documented with commands, arguments, output formats, exit codes, and examples.

## Table of Contents

1. [Core Orchestration](#core-orchestration)
   - [coordinator.sh](#coordinatorsh)
   - [agent-loop.sh](#agent-loopsh)
   - [swarm-orchestrator.sh](#swarm-orchestratorsh)
2. [Memory Management](#memory-management)
   - [memory-manager.sh](#memory-managersh)
3. [Context Management](#context-management)
   - [auto-continue.sh](#auto-continuesh)
   - [file-change-tracker.sh](#file-change-trackersh)
4. [Error Handling](#error-handling)
   - [error-handler.sh](#error-handlersh)
5. [Environment Variables](#environment-variables)

---

## Core Orchestration

### coordinator.sh

**Purpose**: Central intelligence layer that orchestrates all autonomous systems. Integrates reasoning, planning, multi-agent routing, and quality validation.

**Location**: `~/.claude/hooks/coordinator.sh`

#### Commands

| Command | Arguments | Description |
|---------|-----------|-------------|
| `init` | - | Initialize coordinator and all subsystems |
| `coordinate` | `<task> [type] [context]` | Coordinate a single task through the full pipeline |
| `orchestrate` | - | Run autonomous orchestration from buildguide |
| `status` | - | Get coordinator state JSON |

#### Arguments

- **task** (required): Description of the task to coordinate
- **type** (optional): Task type for strategy selection. Default: `general`. Options: `feature`, `bugfix`, `refactor`, `research`, `security`
- **context** (optional): Additional context string for the task

#### Output Format

**JSON** for `coordinate`:
```json
{
  "task": "implement auth",
  "autoResearch": {},
  "execution": {
    "agentId": "agent_1234",
    "planId": "plan_1234",
    "thinkingId": "think_1234",
    "result": "started",
    "duration": 5
  },
  "intelligence": {
    "strategy": "default",
    "strategyConfidence": 0.8,
    "riskLevel": "low",
    "riskScore": 10,
    "patternsFound": 3,
    "reasoningMode": "deliberate",
    "assignedAgent": "code_writer",
    "totSelectedApproach": ""
  },
  "quality": {
    "reflexionScore": 7.5,
    "evaluatorScore": 7.5,
    "decision": "continue",
    "constitutionalValidation": "completed"
  },
  "learning": {
    "reinforcementLearning": "recorded",
    "reflexionLessons": "extracted",
    "auditTrail": "logged"
  },
  "timestamp": "2026-01-17T12:00:00Z"
}
```

#### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Orchestrator unavailable or task prohibited |

#### Examples

```bash
# Initialize coordinator
coordinator.sh init

# Coordinate a feature task
coordinator.sh coordinate "implement user authentication" feature

# Run autonomous orchestration
coordinator.sh orchestrate

# Check status
coordinator.sh status
```

---

### agent-loop.sh

**Purpose**: Autonomous execution loop with tool calling, state machine, and memory integration. Based on patterns from Roo-Code, UI-TARS, and TanStack.

**Location**: `~/.claude/hooks/agent-loop.sh`

#### Commands

##### Lifecycle

| Command | Arguments | Description |
|---------|-----------|-------------|
| `start` | `<goal> [context]` | Start a new agent with specified goal |
| `transition` | `<state> [reason]` | Change agent state |
| `complete` | `<result> [summary]` | Complete agent execution |

##### Loop Control

| Command | Arguments | Description |
|---------|-----------|-------------|
| `should-continue` | - | Check if loop should continue |
| `iterate` | - | Increment iteration counter |
| `failure` | `<error>` | Record a failure |
| `success` | `<result>` | Record a success |
| `pause` | - | Request pause |
| `resume` | - | Resume from pause |
| `stop` | - | Request stop |

##### Tool Execution

| Command | Arguments | Description |
|---------|-----------|-------------|
| `execute` | `<tool> [args...]` | Execute a tool |

Available tools: `read_file`, `search_code`, `run_tests`, `lint_code`, `typecheck`, `shell`

##### Lifecycle Hooks

| Command | Description |
|---------|-------------|
| `on-start` | Call at loop iteration start |
| `on-end` | Call at loop iteration end |

##### Status

| Command | Description |
|---------|-------------|
| `status` | Get full status JSON |
| `summary` | Get human-readable summary |

##### Memory Integration

| Command | Arguments | Description |
|---------|-----------|-------------|
| `memory-init` | - | Initialize memory system |
| `memory-context` | `<query> [limit]` | Retrieve relevant memories |
| `memory-patterns` | `<query> [limit]` | Find known patterns |
| `memory-learn` | `<type> <trigger> <solution> [rate]` | Learn a new pattern |
| `memory-record` | `<type> <desc> [details]` | Record to memory |
| `memory-reflect` | `<focus> <content> [insights]` | Create reflection |
| `memory-stats` | - | Get memory statistics |

#### Agent States

- `idle` - No active task
- `planning` - Creating execution plan
- `executing` - Running tools
- `validating` - Checking results
- `reflecting` - Learning from execution
- `paused` - Temporarily suspended
- `completed` - Task finished successfully
- `failed` - Task failed

#### Output Format

**`should-continue`** returns: `<boolean>:<reason>`
```
true:continue
false:max_iterations
false:consecutive_failures
```

**`execute`** returns JSON:
```json
{
  "id": "tool_1234567890",
  "name": "shell",
  "success": true,
  "result": "command output",
  "exitCode": 0,
  "durationMs": 150
}
```

#### Examples

```bash
# Start a new agent
agent-loop.sh start "implement login feature" "context about auth"

# Execute a tool
agent-loop.sh execute shell "npm test"

# Check if should continue
agent-loop.sh should-continue

# Get status
agent-loop.sh summary
```

---

### swarm-orchestrator.sh

**Purpose**: Distributed multi-agent swarms with git worktree isolation and LangGraph coordination. Enables TRUE parallel execution with 2-100+ agents.

**Location**: `~/.claude/hooks/swarm-orchestrator.sh`

#### Commands

##### Spawn & Manage

| Command | Arguments | Description |
|---------|-----------|-------------|
| `spawn` | `<count> <task>` | Spawn N agents with git worktree isolation |
| `mark-spawned` | `<swarm_id> <agent_id> <task_id>` | Mark agent as spawned |
| `mark-completed` | `<swarm_id> <agent_id> [result_file]` | Mark agent as completed |
| `get-instructions` | `[swarm_id]` | Get spawn instructions |

##### Status & Results

| Command | Arguments | Description |
|---------|-----------|-------------|
| `status` | - | Show swarm status and agent states |
| `langgraph-status` | `[swarm_id] [agent_id]` | Show LangGraph coordinator status |
| `collect` | - | Collect and aggregate results |
| `visualize` | `[swarm_id] [output.png]` | Generate graph visualization |
| `terminate` | - | Stop all agents |
| `cleanup-worktrees` | `[swarm_id]` | Clean up git worktrees |

##### Diagnostics

| Command | Description |
|---------|-------------|
| `check-deps` | Check dependencies (jq, git, python3, LangGraph) |
| `mcp-status` | Show MCP detection status |

#### Decomposition Strategies

The swarm automatically detects task patterns and applies appropriate decomposition:

| Strategy | Pattern | Description |
|----------|---------|-------------|
| `feature` | implement, build, create | Phase-based: design → implement → test → integrate |
| `testing` | test, validate, check | Parallel independent tests |
| `refactor` | refactor, reorganize | Sequential modules with dependencies |
| `research` | research, analyze, explore | Parallel independent investigation |
| `generic` | (default) | Parallel equal parts |

#### Output Format

**`spawn`** outputs structured spawn instructions followed by JSON:
```json
{
  "swarm_id": "swarm_1234567890",
  "task": "Implement auth system",
  "agent_count": 5,
  "work_dir": "~/.claude/swarm/swarm_1234567890",
  "mcp_available": {
    "github": true,
    "chrome": false
  },
  "spawn_phases": {
    "parallel": [...],
    "sequential": [...]
  }
}
```

**`status`** returns JSON:
```json
{
  "swarmId": "swarm_1234567890",
  "task": "Implement auth",
  "agentCount": 5,
  "status": "active",
  "startedAt": "2026-01-17T12:00:00Z",
  "agents": [
    {"agentId": 1, "status": "running"},
    {"agentId": 2, "status": "pending"}
  ],
  "completedCount": 0,
  "pendingCount": 5
}
```

#### Examples

```bash
# Spawn 5 agents for a feature
swarm-orchestrator.sh spawn 5 "Implement comprehensive auth system"

# Check status
swarm-orchestrator.sh status

# Collect results
swarm-orchestrator.sh collect

# Clean up
swarm-orchestrator.sh cleanup-worktrees
swarm-orchestrator.sh terminate
```

---

## Memory Management

### memory-manager.sh

**Purpose**: SQLite-backed persistent memory system with hybrid search (BM25 + semantic + recency + importance), checkpoints, and file change detection.

**Location**: `~/.claude/hooks/memory-manager.sh`

#### Commands

##### Core Memory

| Command | Arguments | Description |
|---------|-----------|-------------|
| `init` | - | Initialize memory subsystem |
| `checkpoint` | `[description]` | Create a checkpoint |
| `add-context` | `<key> <value> [category] [confidence]` | Add semantic context |
| `search` | `<query> [limit]` | FTS5/BM25 search |
| `context-usage` | `[percent]` | Check context budget status |
| `stats` | - | Get memory statistics |

##### Legacy API (Compatibility)

| Command | Arguments | Description |
|---------|-----------|-------------|
| `set-task` | `<goal> [context]` | Set current task in working memory |
| `add-fact` | `<category> <key> <value> [confidence]` | Store a fact |
| `add-pattern` | `<type> <trigger> <solution> [success_rate]` | Learn a pattern |
| `record` | `<type> <description> [status] [details]` | Record an episode |
| `reflect` | `<focus> <content> [insights]` | Create a reflection |
| `remember-hybrid` | `<query> [limit]` | 4-signal RRF hybrid search |
| `find-patterns` | `<query> [limit]` | Search for matching patterns |
| `log-action` | `<type> <description> <status> [metadata]` | Log an action |
| `get-working` | - | Get current working context |
| `list-checkpoints` | - | List recent checkpoints |
| `remember-scored` | `<query> [limit]` | Alias for search with scoring |

##### Phase 1: Git Channel Organization

| Command | Description |
|---------|-------------|
| `scope` | Show memory scope (location, git channel, project root) |

##### Phase 1: Checkpoint/Restore

| Command | Arguments | Description |
|---------|-----------|-------------|
| `checkpoint-full` | `[description]` | Create full state snapshot |
| `restore` | `<checkpoint_id>` | Restore from checkpoint |
| `list-checkpoints-full` | - | List all checkpoints with metadata |
| `prune-checkpoints` | `[keep_count]` | Keep only N most recent checkpoints |

##### Phase 1: File Change Detection

| Command | Arguments | Description |
|---------|-----------|-------------|
| `cache-file` | `<path>` | Cache file hash |
| `file-changed` | `<path>` | Check if file changed (true/false) |
| `list-cached` | - | List all cached files |
| `prune-cache` | - | Remove entries for deleted files |

##### Phase 3: AST-based Chunking

| Command | Arguments | Description |
|---------|-----------|-------------|
| `chunk-file` | `<path> [max_tokens]` | Chunk file for context |
| `detect-language` | `<path>` | Detect file language |
| `find-boundaries` | `<path>` | Find function/class boundaries |

##### Phase 4: Context Budgeting

| Command | Arguments | Description |
|---------|-----------|-------------|
| `context-remaining` | - | Get remaining context budget |
| `context-compact` | `[mode]` | Compact memory (mode: warning/aggressive) |
| `set-context-limit` | `<type> <value>` | Set context limit |

#### Output Formats

**`search`** returns JSON array:
```json
[
  {"key": "auth_implementation", "value": "Use JWT...", "category": "patterns", "confidence": 0.9}
]
```

**`remember-hybrid`** returns JSON with RRF metadata:
```json
[
  {
    "id": "mem_123",
    "text": "Relevant memory content",
    "signals": ["bm25", "recency", "importance"],
    "signal_count": 3,
    "rrf_score": 0.045,
    "retrievalScore": 0.045,
    "retrievalMethod": "rrf_4signal"
  }
]
```

**`context-usage`** returns JSON:
```json
{
  "status": "warning",
  "usage_pct": 65,
  "backend": "sqlite"
}
```

Status values: `active` (<60%), `warning` (60-80%), `critical` (>80%)

**`stats`** returns JSON:
```json
{
  "checkpoints": 5,
  "facts": 42,
  "patterns": 12,
  "episodes": 156
}
```

#### Examples

```bash
# Initialize memory
memory-manager.sh init

# Set current task
memory-manager.sh set-task "Implement auth" "Using JWT tokens"

# Store a pattern
memory-manager.sh add-pattern "error_fix" "ECONNREFUSED" "Check if server running" 0.95

# Hybrid search
memory-manager.sh remember-hybrid "authentication error" 5

# Create checkpoint
memory-manager.sh checkpoint "Before major refactor"

# Check context budget
memory-manager.sh context-usage 45

# Compact memory when needed
memory-manager.sh context-compact aggressive
```

---

## Context Management

### auto-continue.sh

**Purpose**: Fully automated context management with quality awareness. Triggers checkpoint at configurable threshold (default 40%), compacts memory, and creates continuation prompts.

**Location**: `~/.claude/hooks/auto-continue.sh`

#### Trigger Mechanism

This hook is called automatically by Claude Code when context usage reaches threshold. It:
1. Checks if build is in progress
2. Runs validation before checkpoint
3. Saves state and creates continuation prompt
4. Optionally executes checkpoint directly (in autonomous mode)

#### Input Format

Receives JSON from Claude Code:
```json
{
  "context_window": {
    "context_window_size": 200000,
    "current_usage": {
      "input_tokens": 50000,
      "cache_creation_input_tokens": 10000,
      "cache_read_input_tokens": 20000
    }
  },
  "transcript_path": "/path/to/transcript.json"
}
```

#### Output Format

Returns JSON to Claude Code:
```json
{
  "decision": "block",
  "reason": "Continuation prompt text...",
  "systemMessage": "Auto-continue: Context 45% compacted",
  "autonomous_execution": {
    "enabled": true,
    "skill": "checkpoint",
    "reason": "context_threshold",
    "executed_directly": true,
    "router_decision": {...}
  }
}
```

#### State Files

- `.claude/auto-continue.local.md` - Session state
- `.claude/current-build.local.md` - Active build tracking
- `~/.claude/continuation-prompt.md` - Handoff prompt for loop

---

### file-change-tracker.sh

**Purpose**: Tracks file modifications and triggers checkpoint every N file changes (default 10).

**Location**: `~/.claude/hooks/file-change-tracker.sh`

#### Commands

| Command | Arguments | Description |
|---------|-----------|-------------|
| `record` | `<file> [type]` | Record a file change |
| `check` | - | Check if checkpoint needed |
| `reset` | - | Reset counter after checkpoint |
| `status` | - | Show current status |
| `recent` | - | Show recent changes |
| `init` | - | Initialize tracker |

#### Arguments

- **file**: Path to changed file
- **type**: Change type. Options: `created`, `modified`, `deleted`. Default: `modified`

#### Output Format

**`record`** returns:
```
CHECKPOINT_NEEDED:10   # When threshold reached
OK:5                   # Normal tracking
ERROR:0                # On lock failure
```

**`check`** returns:
```
true:10    # Checkpoint needed
false:5    # Below threshold
```

**`status`** returns text:
```
File Change Tracker Status:
  Changes since last checkpoint: 5 / 10
  Last checkpoint: 2026-01-17T12:00:00Z
  Total checkpoints this session: 3
  Checkpoint needed: no
```

#### Examples

```bash
# Record a file change
file-change-tracker.sh record "src/auth.ts" "modified"

# Check if checkpoint needed
file-change-tracker.sh check

# Reset after checkpoint
file-change-tracker.sh reset

# View status
file-change-tracker.sh status
```

---

## Error Handling

### error-handler.sh

**Purpose**: Smart retry with exponential backoff and error classification. Integrates with memory for known fixes and debug orchestrator for regression detection.

**Location**: `~/.claude/hooks/error-handler.sh`

#### Commands

| Command | Arguments | Description |
|---------|-----------|-------------|
| `handle` | `<error_msg> [attempt] [max_retries] [context]` | Handle an error |
| `record-fix` | `<error_msg> <fix_applied>` | Record successful fix to memory |

#### Error Classifications

| Classification | Description | Retryable |
|---------------|-------------|-----------|
| `TRANSIENT` | Network timeouts, connection resets | Yes |
| `RATE_LIMIT` | API rate limits (429) | Yes (longer backoff) |
| `CLIENT_ERROR` | Syntax errors, validation failures | No |
| `BUILD_ERROR` | Compilation failures, lint errors | No |
| `DATABASE_ERROR` | Database connection issues | Yes |
| `UNKNOWN` | Unclassified errors | Once |

#### Backoff Strategy

- Base delay: 1000ms (5000ms for rate limits)
- Formula: `base * 2^attempt`
- Max delay: 30000ms (60000ms for rate limits)

#### Output Format

**`handle`** returns JSON:
```json
{
  "classification": "TRANSIENT",
  "shouldRetry": true,
  "backoffMs": 2000,
  "attempt": 1,
  "error": "ECONNRESET",
  "hasKnownFix": false
}
```

When known fix found:
```json
{
  "classification": "BUILD_ERROR",
  "shouldRetry": false,
  "hasKnownFix": true,
  "knownFix": "npm install missing-package",
  "fixApplied": true,
  "recommendation": "Known fix applied successfully",
  "error": "Cannot find module 'missing-package'"
}
```

#### Examples

```bash
# Handle a transient error
error-handler.sh handle "ECONNRESET: Connection reset" 0 3

# Record a successful fix
error-handler.sh record-fix "Cannot find module X" "npm install X"
```

---

## Environment Variables

### Core Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_CONTEXT_THRESHOLD` | `40` | Context % to trigger auto-continue |
| `CHECKPOINT_FILE_THRESHOLD` | `10` | File changes to trigger checkpoint |
| `MAX_ITERATIONS` | `50` | Max agent loop iterations |
| `MAX_CONSECUTIVE_FAILURES` | `3` | Max failures before agent stops |

### Swarm Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SWARM_MAX_AGENTS` | `10` | Maximum agents per swarm |
| `SWARM_COLLECT_TIMEOUT` | `30` | Seconds to wait for results |
| `SWARM_SHARED_MEMORY` | `true` | Enable shared memory |
| `SWARM_CONSENSUS_METHOD` | `voting` | Consensus method |
| `GITHUB_MCP_ENABLED` | `false` | Force enable GitHub MCP |
| `CHROME_MCP_ENABLED` | `false` | Force enable Chrome MCP |

### Memory Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_PATH` | `~/.claude/memory.db` | SQLite database path |
| `MEMORY_DEBUG` | `false` | Enable debug logging |

### Loop Control

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_LOOP_ACTIVE` | `0` | Set to `1` when in loop mode |

---

## Exit Codes Reference

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General failure |
| 126 | Command blocked by validation gate |

---

## Integration Examples

### Full Autonomous Workflow

```bash
# 1. Initialize all systems
coordinator.sh init

# 2. Start agent loop for a task
agent_id=$(agent-loop.sh start "Implement auth feature" "Using JWT")

# 3. Main loop
while [[ $(agent-loop.sh should-continue | cut -d: -f1) == "true" ]]; do
    agent-loop.sh on-start

    # Execute work
    result=$(agent-loop.sh execute shell "npm test")
    exit_code=$(echo "$result" | jq -r '.exitCode')

    if [[ $exit_code -eq 0 ]]; then
        agent-loop.sh success
    else
        error_msg=$(echo "$result" | jq -r '.result')
        agent-loop.sh failure "$error_msg"
    fi

    agent-loop.sh iterate
    agent-loop.sh on-end
done

# 4. Complete
agent-loop.sh complete "success" "Auth feature implemented"
```

### Swarm for Parallel Testing

```bash
# Spawn 5 agents for comprehensive testing
swarm-orchestrator.sh spawn 5 "Run comprehensive test suite"

# Wait for completion and collect
swarm-orchestrator.sh collect

# Clean up
swarm-orchestrator.sh cleanup-worktrees
```

### Memory-Enhanced Error Handling

```bash
# Handle error with memory lookup
result=$(error-handler.sh handle "$error_msg" 0 3 "building auth")

should_retry=$(echo "$result" | jq -r '.shouldRetry')
known_fix=$(echo "$result" | jq -r '.hasKnownFix')

if [[ "$known_fix" == "true" ]]; then
    echo "Applied known fix from memory"
elif [[ "$should_retry" == "true" ]]; then
    backoff=$(echo "$result" | jq -r '.backoffMs')
    sleep $((backoff / 1000))
    # Retry...
fi
```

---

*Documentation generated: 2026-01-17*
*Version: Claude Sovereign v2.0*
