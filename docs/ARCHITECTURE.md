---
type: architecture
title: System Architecture
created: 2026-01-17
tags:
  - architecture
  - design
  - system
related:
  - "[[API]]"
  - "[[Coordinator]]"
  - "[[Memory-System]]"
  - "[[Swarm-Orchestrator]]"
---

# Claude Sovereign System Architecture

This document describes the architecture of the Claude Sovereign autonomous system, including component relationships, data flow, hook execution order, memory system architecture, and swarm coordination model.

## Table of Contents

1. [High-Level Architecture](#high-level-architecture)
2. [Component Relationships](#component-relationships)
3. [Execution Flow](#execution-flow)
4. [Hook Execution Order](#hook-execution-order)
5. [Memory System Architecture](#memory-system-architecture)
6. [Swarm Coordination Model](#swarm-coordination-model)
7. [Data Flow](#data-flow)
8. [Component Catalog](#component-catalog)

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USER INTERFACE                                  │
│                                                                             │
│    /auto ──────► autonomous-mode.active flag                                │
│    /checkpoint ─► Skill tool execution                                      │
│    /build ──────► Autonomous feature builder                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         COMMAND ROUTING LAYER                               │
│                                                                             │
│    autonomous-command-router.sh                                             │
│    ├── Analyzes context (trigger type, autonomous mode, project state)      │
│    ├── Decision matrix for checkpoint_files, checkpoint_context, build      │
│    └── Returns JSON: {command, reason, auto_execute}                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CENTRAL COORDINATOR                                  │
│                                                                             │
│    coordinator.sh                                                           │
│    ├── Initializes all subsystems                                           │
│    ├── Orchestrates task execution through full pipeline                    │
│    ├── Integrates 25+ specialized hooks                                     │
│    └── Reports structured JSON status                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
              ┌──────────────────────┼──────────────────────┐
              ▼                      ▼                      ▼
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   AGENT EXECUTION   │  │   SWARM PARALLEL    │  │   QUALITY/SAFETY    │
│                     │  │                     │  │                     │
│  agent-loop.sh      │  │  swarm-orchestrator │  │  constitutional-ai  │
│  ├─ State machine   │  │  ├─ Git worktrees   │  │  ├─ Safety validation│
│  ├─ Tool calling    │  │  ├─ LangGraph coord │  │  ├─ Auto-revision    │
│  ├─ Memory access   │  │  ├─ 2-100+ agents   │  │  └─ Principle checks│
│  └─ Iteration ctrl  │  │  └─ Result merge    │  │                     │
│                     │  │                     │  │  validation-gate    │
│  plan-execute.sh    │  │                     │  │  ├─ Block dangerous │
│  task-queue.sh      │  │                     │  │  └─ Pre-exec checks │
│  thinking-framework │  │                     │  │                     │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
              │                      │                      │
              └──────────────────────┼──────────────────────┘
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MEMORY & PERSISTENCE                                 │
│                                                                             │
│    memory-manager.sh (SQLite-backed)                                        │
│    ├── Working memory (current task context)                                │
│    ├── Episodic memory (past experiences)                                   │
│    ├── Semantic memory (facts & patterns)                                   │
│    ├── 4-signal RRF hybrid search (BM25, semantic, recency, importance)     │
│    ├── Checkpoint/restore system                                            │
│    └── File change detection (SHA-256)                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONTEXT MANAGEMENT                                   │
│                                                                             │
│    auto-continue.sh          file-change-tracker.sh                         │
│    ├─ 40% context trigger    ├─ Track file modifications                   │
│    ├─ Memory compaction      ├─ 10-file checkpoint trigger                 │
│    ├─ Continuation prompts   └─ Atomic counter with flock                  │
│    └─ Autonomous execution                                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ERROR & RECOVERY                                     │
│                                                                             │
│    error-handler.sh              self-healing.sh                            │
│    ├─ Error classification       ├─ Health checks                          │
│    ├─ Exponential backoff        ├─ Auto-recovery                          │
│    ├─ Known fix lookup           └─ System status                          │
│    └─ Memory-based learning                                                 │
│                                                                             │
│    debug-orchestrator.sh                                                    │
│    ├─ Regression detection                                                  │
│    ├─ Before/after snapshots                                                │
│    └─ Smart debug + verify-fix                                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Relationships

```
                        ┌────────────────────────────┐
                        │      coordinator.sh        │
                        │   (Central Intelligence)   │
                        └────────────────────────────┘
                                     │
        ┌────────────────────────────┼────────────────────────────┐
        │                            │                            │
        ▼                            ▼                            ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│ ORCHESTRATOR  │          │   LEARNING    │          │   QUALITY     │
│ SUBSYSTEM     │          │   SUBSYSTEM   │          │   SUBSYSTEM   │
├───────────────┤          ├───────────────┤          ├───────────────┤
│ autonomous-   │          │ learning-     │          │ constitutional│
│ orchestrator  │◄────────►│ engine        │◄────────►│ -ai           │
│ -v2           │          │               │          │               │
├───────────────┤          │ pattern-miner │          │ validation-   │
│ agent-loop    │          │               │          │ gate          │
├───────────────┤          │ meta-         │          │               │
│ swarm-        │          │ reflection    │          │ auto-evaluator│
│ orchestrator  │          │               │          │               │
├───────────────┤          │ hypothesis-   │          │ react-        │
│ multi-agent-  │          │ tester        │          │ reflexion     │
│ orchestrator  │          │               │          │               │
└───────────────┘          │ reinforcement-│          └───────────────┘
        │                  │ learning      │                  │
        │                  └───────────────┘                  │
        │                            │                        │
        └────────────────────────────┼────────────────────────┘
                                     │
                                     ▼
                        ┌────────────────────────────┐
                        │      memory-manager.sh     │
                        │   (Persistent Storage)     │
                        └────────────────────────────┘
                                     │
        ┌────────────────────────────┼────────────────────────────┐
        │                            │                            │
        ▼                            ▼                            ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│   Working     │          │   Episodic    │          │   Semantic    │
│   Memory      │          │   Memory      │          │   Memory      │
├───────────────┤          ├───────────────┤          ├───────────────┤
│ Current task  │          │ Past actions  │          │ Facts         │
│ Session state │          │ Experiences   │          │ Patterns      │
│ File caches   │          │ Reflections   │          │ Solutions     │
└───────────────┘          └───────────────┘          └───────────────┘
```

---

## Execution Flow

### Autonomous Task Execution

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. USER INPUT                                                               │
│    "Implement authentication feature"                                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. REASONING MODE SELECTION (reasoning-mode-switcher.sh)                    │
│    Analyzes: complexity, urgency, risk                                      │
│    Selects: reflexive (fast) | deliberate (thorough) | reactive (urgent)   │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. THINKING FRAMEWORK (thinking-framework.sh)                               │
│    Chain-of-thought reasoning                                               │
│    Problem decomposition                                                    │
│    Strategy formulation                                                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. PLAN CREATION (plan-execute.sh)                                          │
│    Task decomposition into steps                                            │
│    Dependency ordering                                                      │
│    Resource estimation                                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 5. AGENT ROUTING (multi-agent-orchestrator.sh)                              │
│    Routes to specialist: code_writer | test_engineer | security_auditor |  │
│                          documentation | performance | general             │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 6. VALIDATION GATE (validation-gate.sh)                                     │
│    Pre-execution safety checks                                              │
│    Block dangerous commands                                                 │
│    Exit code 126 if blocked                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 7. AGENT LOOP EXECUTION (agent-loop.sh)                                     │
│    State: idle → planning → executing → validating → reflecting → completed│
│                                                                             │
│    ┌─────────────────────────────────────────────────────────────────┐     │
│    │ Loop Iteration:                                                  │     │
│    │   on-start → execute tool → check result → iterate → on-end     │     │
│    │                    │                                             │     │
│    │              ┌─────┴─────┐                                       │     │
│    │              ▼           ▼                                       │     │
│    │          success      failure                                    │     │
│    │              │           │                                       │     │
│    │              │     error-handler.sh                             │     │
│    │              │     ├─ Classify error                            │     │
│    │              │     ├─ Check known fixes                         │     │
│    │              │     └─ Calculate backoff                         │     │
│    │              │                                                   │     │
│    │              └─────┬─────┘                                       │     │
│    │                    ▼                                             │     │
│    │              should-continue?                                    │     │
│    └─────────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 8. POST-EXECUTION (post-edit-quality.sh)                                    │
│    Auto-lint and typecheck                                                  │
│    Track file changes                                                       │
│    Trigger UI tests if React component                                      │
│    Trigger checkpoint if 10 files changed                                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 9. QUALITY VALIDATION (react-reflexion.sh + constitutional-ai.sh)           │
│    Reflexion scoring                                                        │
│    Constitutional principle checking                                        │
│    Auto-revision if needed (max 2 attempts)                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 10. LEARNING & MEMORY (memory-manager.sh + reinforcement-learning.sh)       │
│     Record episode                                                          │
│     Update patterns                                                         │
│     Reinforcement signal                                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Hook Execution Order

### Startup Sequence

```
1. session-start-handler.sh
   └─► Initialize session state

2. coordinator.sh init
   ├─► learning-engine.sh init
   ├─► memory-manager.sh init
   ├─► agent-loop.sh (state: idle)
   └─► Update system status

3. autonomous-mode.active check
   └─► If present: enable autonomous execution
```

### Per-Task Sequence

```
1. coordinator.sh coordinate <task> [type] [context]
   │
   ├─► 2. reasoning-mode-switcher.sh
   │       └─► Determine: reflexive | deliberate | reactive
   │
   ├─► 3. thinking-framework.sh
   │       └─► Chain-of-thought analysis
   │
   ├─► 4. plan-execute.sh
   │       └─► Task decomposition
   │
   ├─► 5. task-queue.sh
   │       └─► Prioritize subtasks
   │
   ├─► 6. parallel-execution-planner.sh
   │       └─► Identify parallelizable work
   │
   ├─► 7. multi-agent-orchestrator.sh
   │       ├─► Route to specialist
   │       └─► OR spawn swarm
   │
   ├─► 8. validation-gate.sh
   │       └─► Pre-execution safety
   │
   ├─► 9. agent-loop.sh start <goal>
   │       │
   │       ├─► Tool execution loop
   │       │   ├─► execute (read_file, shell, etc.)
   │       │   ├─► error-handler.sh (on failure)
   │       │   └─► debug-orchestrator.sh (regression check)
   │       │
   │       └─► Memory operations
   │           ├─► memory-context (retrieve)
   │           ├─► memory-record (store)
   │           └─► memory-learn (patterns)
   │
   ├─► 10. post-edit-quality.sh (after each file edit)
   │        ├─► Lint/typecheck
   │        ├─► file-change-tracker.sh record
   │        └─► ui-test-framework.sh (if React)
   │
   ├─► 11. react-reflexion.sh
   │        └─► Score execution quality
   │
   ├─► 12. constitutional-ai.sh
   │        └─► Safety validation
   │
   └─► 13. reinforcement-learning.sh
           └─► Record outcome signal
```

### Context Management Triggers

```
TRIGGER: Context reaches 40%
┌────────────────────────────────────────────────┐
│ auto-continue.sh                               │
│   ├─► Check if build in progress               │
│   ├─► memory-manager.sh context-compact        │
│   ├─► autonomous-command-router.sh analyze     │
│   │     └─► Return {command, auto_execute}     │
│   ├─► Generate continuation prompt             │
│   └─► Execute /checkpoint (if autonomous)      │
└────────────────────────────────────────────────┘

TRIGGER: 10 file changes
┌────────────────────────────────────────────────┐
│ file-change-tracker.sh check                   │
│   ├─► Returns "true:10"                        │
│   └─► Trigger /checkpoint                      │
└────────────────────────────────────────────────┘
```

---

## Memory System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          MEMORY MANAGER                                      │
│                     ~/.claude/hooks/memory-manager.sh                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SQLITE DATABASE                                      │
│                       ~/.claude/memory.db                                    │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │  semantic_facts │  │    episodes     │  │    patterns     │              │
│  ├─────────────────┤  ├─────────────────┤  ├─────────────────┤              │
│  │ key TEXT        │  │ type TEXT       │  │ type TEXT       │              │
│  │ value TEXT      │  │ description TEXT│  │ trigger TEXT    │              │
│  │ category TEXT   │  │ status TEXT     │  │ solution TEXT   │              │
│  │ confidence REAL │  │ details TEXT    │  │ success_rate    │              │
│  │ created_at      │  │ timestamp       │  │ last_used       │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │  working_memory │  │   checkpoints   │  │   file_cache    │              │
│  ├─────────────────┤  ├─────────────────┤  ├─────────────────┤              │
│  │ goal TEXT       │  │ id TEXT         │  │ path TEXT       │              │
│  │ context TEXT    │  │ description TEXT│  │ hash TEXT       │              │
│  │ session_id TEXT │  │ state_blob BLOB │  │ timestamp       │              │
│  │ updated_at      │  │ created_at      │  │ project TEXT    │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
│                                                                             │
│  FTS5 Virtual Tables (BM25 search):                                         │
│  ┌─────────────────────────────────────────────────────────────┐            │
│  │  semantic_facts_fts  │  episodes_fts  │  patterns_fts      │            │
│  └─────────────────────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      4-SIGNAL RRF HYBRID SEARCH                              │
│                                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │    BM25      │  │   Semantic   │  │   Recency    │  │  Importance  │    │
│  │   (FTS5)     │  │  (cosine)    │  │  (decay)     │  │  (confidence)│    │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘    │
│         │                  │                 │                 │            │
│         └──────────────────┼─────────────────┼─────────────────┘            │
│                            ▼                                                │
│                    ┌──────────────┐                                         │
│                    │  RRF Fusion  │                                         │
│                    │  k=60        │                                         │
│                    └──────────────┘                                         │
│                            │                                                │
│                            ▼                                                │
│                    Ranked Results with                                      │
│                    signal metadata                                          │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      GIT CHANNEL ORGANIZATION                                │
│                                                                             │
│  ~/.claude/memory/                                                          │
│  ├── master/                 ◄── Default channel                            │
│  │   ├── working.json                                                       │
│  │   ├── episodic.json                                                      │
│  │   ├── semantic.json                                                      │
│  │   └── checkpoints/                                                       │
│  │       ├── ckpt_1234567890.json                                           │
│  │       └── ckpt_1234567890.actions.jsonl                                  │
│  │                                                                          │
│  ├── feature-auth/          ◄── Feature branch channel                      │
│  │   ├── working.json                                                       │
│  │   └── ...                                                                │
│  │                                                                          │
│  └── develop/               ◄── Another branch channel                      │
│      └── ...                                                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CONTEXT BUDGETING                                       │
│                                                                             │
│  context-usage [percent]    →    Returns: active | warning | critical      │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────┐       │
│  │   0%                60%              80%               100%     │       │
│  │   │─────────────────│────────────────│─────────────────│        │       │
│  │   │     ACTIVE      │    WARNING     │    CRITICAL     │        │       │
│  │   │                 │                │                 │        │       │
│  │   │ Normal ops      │ Compact memory │ Aggressive      │        │       │
│  │   │                 │ on next write  │ compaction +    │        │       │
│  │   │                 │                │ checkpoint      │        │       │
│  └─────────────────────────────────────────────────────────────────┘       │
│                                                                             │
│  context-compact [mode]                                                     │
│    warning    →  Prune old episodes, compact patterns                       │
│    aggressive →  Above + summarize working memory + checkpoint              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Swarm Coordination Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SWARM ORCHESTRATOR                                      │
│                  ~/.claude/hooks/swarm-orchestrator.sh                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ SPAWN COMMAND: swarm-orchestrator.sh spawn <count> <task>                   │
│                                                                             │
│ 1. Task Decomposition (Auto-detect strategy):                               │
│    ┌────────────────────────────────────────────────────────────┐          │
│    │ Pattern          │ Strategy   │ Decomposition              │          │
│    ├───────────────────┼────────────┼────────────────────────────┤          │
│    │ implement, build  │ feature    │ design→implement→test      │          │
│    │ test, validate    │ testing    │ parallel independent tests │          │
│    │ refactor          │ refactor   │ sequential modules         │          │
│    │ research, analyze │ research   │ parallel investigation     │          │
│    │ (default)         │ generic    │ parallel equal parts       │          │
│    └────────────────────────────────────────────────────────────┘          │
│                                                                             │
│ 2. Git Worktree Isolation:                                                  │
│    Main repo: /project                                                      │
│    ├── .git/worktrees/                                                      │
│    │   ├── agent_1/                                                         │
│    │   ├── agent_2/                                                         │
│    │   └── agent_N/                                                         │
│    │                                                                        │
│    Each agent gets:                                                         │
│    - Isolated working directory                                             │
│    - Own branch (swarm_<id>_agent_<n>)                                      │
│    - Full git history access                                                │
│    - Independent file modifications                                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      LANGGRAPH COORDINATOR                                   │
│                   ~/.claude/swarm/langgraph-coordinator.py                   │
│                                                                             │
│  StateGraph:                                                                │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                                                                  │      │
│  │    ┌─────────┐     ┌─────────┐     ┌─────────┐                   │      │
│  │    │ pending │────►│ running │────►│completed│                   │      │
│  │    └─────────┘     └────┬────┘     └─────────┘                   │      │
│  │                         │                                        │      │
│  │                         ▼                                        │      │
│  │                    ┌─────────┐                                   │      │
│  │                    │ failed  │                                   │      │
│  │                    └─────────┘                                   │      │
│  │                                                                  │      │
│  │  State per agent:                                                │      │
│  │  {agent_id, task, status, result, worktree_path, start_time}     │      │
│  │                                                                  │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
│  Consensus Methods:                                                         │
│  - voting: Majority agreement on results                                    │
│  - merge: Combine all results                                               │
│  - quality: Highest quality score wins                                      │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      RESULT COLLECTION                                       │
│                                                                             │
│ COLLECT COMMAND: swarm-orchestrator.sh collect                              │
│                                                                             │
│ 1. Wait for all agents to complete (or timeout)                             │
│ 2. Gather results from each worktree                                        │
│ 3. Apply consensus method                                                   │
│ 4. Merge branches back to main                                              │
│ 5. Resolve conflicts (auto or manual)                                       │
│ 6. Clean up worktrees                                                       │
│                                                                             │
│ Result Aggregation:                                                         │
│ ┌────────────────────────────────────────────────────────────────┐         │
│ │  Agent 1 Result  │  Agent 2 Result  │  Agent N Result          │         │
│ │       ↓                ↓                    ↓                  │         │
│ │  ┌─────────────────────────────────────────────────────────┐   │         │
│ │  │              Consensus Engine                           │   │         │
│ │  │  (voting | merge | quality)                             │   │         │
│ │  └─────────────────────────────────────────────────────────┘   │         │
│ │                          ↓                                     │         │
│ │                   Final Result                                 │         │
│ └────────────────────────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      REAL-TIME DASHBOARD                                     │
│                    ~/.claude/swarm/dashboard.py                              │
│                    http://localhost:5000                                     │
│                                                                             │
│ ┌────────────────────────────────────────────────────────────────────────┐ │
│ │  Swarm Status: swarm_1234567890                                        │ │
│ │  Task: Implement comprehensive auth system                             │ │
│ │  Strategy: feature                                                     │ │
│ │  ─────────────────────────────────────────────────────────────────     │ │
│ │                                                                        │ │
│ │  Agent 1 [████████████████████] 100% - completed                       │ │
│ │  Agent 2 [██████████░░░░░░░░░░]  50% - running                         │ │
│ │  Agent 3 [████████░░░░░░░░░░░░]  40% - running                         │ │
│ │  Agent 4 [░░░░░░░░░░░░░░░░░░░░]   0% - pending                         │ │
│ │  Agent 5 [████████████████████] 100% - completed                       │ │
│ │                                                                        │ │
│ │  ─────────────────────────────────────────────────────────────────     │ │
│ │  Completed: 2/5  |  Running: 2  |  Pending: 1                          │ │
│ │  [Auto-refresh: 5s]                                                    │ │
│ └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### Task Execution Data Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INPUT                                           │
│                                                                             │
│  User Command: "Implement user authentication with JWT"                      │
│       ↓                                                                      │
│  coordinator.sh coordinate "Implement user auth" feature                     │
└─────────────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           INTELLIGENCE LAYER                                 │
│                                                                             │
│  ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐    │
│  │ Memory Query     │────►│ Strategy Select  │────►│ Risk Assessment  │    │
│  │ remember-hybrid  │     │ strategy-selector│     │ risk-predictor   │    │
│  │ "auth patterns"  │     │ returns:         │     │ returns:         │    │
│  │                  │     │ {strategy: jwt,  │     │ {level: low,     │    │
│  │ returns:         │     │  confidence: 0.8}│     │  score: 15}      │    │
│  │ [past patterns]  │     │                  │     │                  │    │
│  └──────────────────┘     └──────────────────┘     └──────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PLANNING LAYER                                     │
│                                                                             │
│  thinking-framework.sh                                                       │
│  {                                                                          │
│    "analysis": "Need JWT auth with login/register endpoints",               │
│    "approach": "1. Create auth module 2. Add routes 3. Test",               │
│    "risks": ["Token expiry handling", "Password hashing"]                   │
│  }                                                                          │
│       ↓                                                                      │
│  plan-execute.sh                                                            │
│  {                                                                          │
│    "steps": [                                                               │
│      {"id": 1, "task": "Create User model", "deps": []},                    │
│      {"id": 2, "task": "Create auth controller", "deps": [1]},              │
│      {"id": 3, "task": "Add JWT middleware", "deps": [2]},                  │
│      {"id": 4, "task": "Write tests", "deps": [3]}                          │
│    ]                                                                        │
│  }                                                                          │
└─────────────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           EXECUTION LAYER                                    │
│                                                                             │
│  agent-loop.sh                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │  Iteration 1: Create User model                                    │    │
│  │  ├─ execute read_file "src/models/index.ts"                        │    │
│  │  ├─ execute shell "touch src/models/User.ts"                       │    │
│  │  └─ Result: {success: true, file: "src/models/User.ts"}            │    │
│  │                                                                    │    │
│  │  Iteration 2: Create auth controller                               │    │
│  │  ├─ execute shell "npm install jsonwebtoken bcrypt"                │    │
│  │  ├─ execute read_file "src/controllers/index.ts"                   │    │
│  │  └─ Result: {success: true}                                        │    │
│  │                                                                    │    │
│  │  ... (continues for each step)                                     │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│       ↓                                                                      │
│  post-edit-quality.sh (after each file change)                              │
│  {                                                                          │
│    "lint": "passed",                                                        │
│    "typecheck": "passed",                                                   │
│    "filesChanged": 3                                                        │
│  }                                                                          │
└─────────────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           QUALITY LAYER                                      │
│                                                                             │
│  react-reflexion.sh                                                         │
│  {                                                                          │
│    "score": 8.5,                                                            │
│    "strengths": ["Clean implementation", "Good error handling"],            │
│    "improvements": ["Add rate limiting"]                                    │
│  }                                                                          │
│       ↓                                                                      │
│  constitutional-ai.sh                                                        │
│  {                                                                          │
│    "validation": "passed",                                                  │
│    "principles_checked": ["security", "privacy", "safety"],                 │
│    "violations": []                                                         │
│  }                                                                          │
└─────────────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           LEARNING LAYER                                     │
│                                                                             │
│  memory-manager.sh record task_complete "Implemented JWT auth" success      │
│  memory-manager.sh add-pattern auth_setup "JWT implementation" "solution"   │
│       ↓                                                                      │
│  reinforcement-learning.sh                                                   │
│  {                                                                          │
│    "signal": "positive",                                                    │
│    "reward": 0.8,                                                           │
│    "strategy_update": "jwt_auth confidence +0.1"                            │
│  }                                                                          │
└─────────────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              OUTPUT                                          │
│                                                                             │
│  coordinator.sh returns:                                                    │
│  {                                                                          │
│    "task": "Implement user auth",                                           │
│    "execution": {"result": "completed", "duration": 45},                    │
│    "intelligence": {"strategy": "jwt", "riskLevel": "low"},                 │
│    "quality": {"reflexionScore": 8.5, "constitutionalValidation": "passed"},│
│    "learning": {"reinforcementLearning": "recorded", "patternsAdded": 2}    │
│  }                                                                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Catalog

### Core Components (81 hooks)

| Component | File | Purpose |
|-----------|------|---------|
| **Coordinator** | `coordinator.sh` | Central orchestration |
| **Agent Loop** | `agent-loop.sh` | Autonomous execution |
| **Swarm Orchestrator** | `swarm-orchestrator.sh` | Multi-agent swarms |
| **Memory Manager** | `memory-manager.sh` | Persistent memory |
| **Auto Continue** | `auto-continue.sh` | Context management |
| **Error Handler** | `error-handler.sh` | Error recovery |

### Intelligence Components

| Component | File | Purpose |
|-----------|------|---------|
| **Reasoning Mode** | `reasoning-mode-switcher.sh` | Mode selection |
| **Thinking Framework** | `thinking-framework.sh` | Chain-of-thought |
| **Plan Execute** | `plan-execute.sh` | Task decomposition |
| **Tree of Thoughts** | `tree-of-thoughts.sh` | Multi-path exploration |
| **Strategy Selector** | `strategy-selector.sh` | Strategy selection |

### Quality Components

| Component | File | Purpose |
|-----------|------|---------|
| **Constitutional AI** | `constitutional-ai.sh` | Safety validation |
| **Validation Gate** | `validation-gate.sh` | Pre-exec safety |
| **React Reflexion** | `react-reflexion.sh` | Quality scoring |
| **Auto Evaluator** | `auto-evaluator.sh` | Automated evaluation |

### Learning Components

| Component | File | Purpose |
|-----------|------|---------|
| **Learning Engine** | `learning-engine.sh` | Learning coordination |
| **Pattern Miner** | `pattern-miner.sh` | Pattern extraction |
| **Meta Reflection** | `meta-reflection.sh` | Meta-learning |
| **Reinforcement Learning** | `reinforcement-learning.sh` | Reward signals |

### Utility Components

| Component | File | Purpose |
|-----------|------|---------|
| **File Change Tracker** | `file-change-tracker.sh` | Track modifications |
| **Post Edit Quality** | `post-edit-quality.sh` | Post-edit hooks |
| **Self Healing** | `self-healing.sh` | Auto-recovery |
| **Debug Orchestrator** | `debug-orchestrator.sh` | Debugging |

---

*Documentation generated: 2026-01-17*
*Version: Claude Sovereign v2.0*
