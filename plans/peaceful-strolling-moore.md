# Implementation Plan: Claude Code-Style Agent Architecture for Gemini CLI

## Overview

Enhance Gemini CLI with Claude Code-inspired agent spawning features while leveraging Gemini's existing robust agent infrastructure.

**Current State**: Gemini CLI already has a sophisticated agent system in `@google/gemini-cli-core/src/agents/`:
- `AgentRegistry` - discovers and manages agents
- `AgentExecutor` - runs agent loops with tool execution
- `SubagentInvocation` - executes subagents
- `delegate_to_agent` tool - spawns subagents from parent agents
- `CodebaseInvestigatorAgent` - built-in example agent

**Goal**: Add user-friendly features from Claude Code:
1. File-based agent definitions (`.gemini/agents/*.md`)
2. CLI agent injection (`--agents` flag)
3. Background execution with task management
4. `/agents` slash command for management

---

## Phase 1: File-Based Agent Definitions

### 1.1 Create FileAgentLoader

**File**: `packages/cli/src/services/FileAgentLoader.ts`

```typescript
import { AgentDefinition } from '@google/gemini-cli-core';
import { z } from 'zod';

interface FileAgentLoaderConfig {
  projectPath: string;    // .gemini/agents/
  userPath: string;       // ~/.gemini/agents/
}

export class FileAgentLoader {
  async loadAgents(signal: AbortSignal): Promise<AgentDefinition[]>;
  private parseMarkdownAgent(filePath: string): AgentDefinition;
  private parseFrontmatter(content: string): { meta: AgentMeta, body: string };
}
```

**Agent File Format** (`.gemini/agents/code-reviewer.md`):

```markdown
---
name: code-reviewer
description: Expert code reviewer for quality and security analysis
tools: read_file, glob, grep, shell
model: gemini-2.5-pro
temperature: 0.2
max_turns: 20
max_time_minutes: 10
---

You are a senior code reviewer specializing in security and best practices.

When reviewing code:
1. Check for security vulnerabilities
2. Verify error handling
3. Assess code clarity
4. Suggest improvements

Be thorough but concise in feedback.
```

**Frontmatter Schema**:
```typescript
const AgentMetaSchema = z.object({
  name: z.string().regex(/^[a-z0-9-]+$/),
  description: z.string(),
  tools: z.string().optional(),           // comma-separated tool names
  model: z.string().optional(),           // defaults to current model
  temperature: z.number().min(0).max(2).optional(),
  max_turns: z.number().optional(),
  max_time_minutes: z.number().optional(),
  inputs: z.record(z.object({             // optional typed inputs
    type: z.enum(['string', 'number', 'boolean']),
    description: z.string(),
    required: z.boolean().optional()
  })).optional()
});
```

### 1.2 Integrate with AgentRegistry

**Modify**: `packages/core/src/agents/registry.ts`

```typescript
export class AgentRegistry {
  private readonly fileLoader: FileAgentLoader;

  async initialize(): Promise<void> {
    await this.loadBuiltInAgents();
    await this.loadFileAgents();  // NEW: Load from filesystem
  }

  private async loadFileAgents(): Promise<void> {
    const agents = await this.fileLoader.loadAgents(this.signal);
    for (const agent of agents) {
      this.registerAgent(agent);  // Later sources override earlier
    }
  }
}
```

**Priority Order** (later overrides earlier):
1. Built-in agents (codebase_investigator)
2. User agents (`~/.gemini/agents/`)
3. Project agents (`./.gemini/agents/`)
4. CLI-injected agents (`--agents` flag)

### 1.3 Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `packages/cli/src/services/FileAgentLoader.ts` | CREATE | Load agents from markdown files |
| `packages/core/src/agents/registry.ts` | MODIFY | Add file loading to initialize() |
| `packages/core/src/agents/types.ts` | MODIFY | Add `source` field to AgentDefinition |

---

## Phase 2: CLI Agent Injection

### 2.1 Add `--agents` Flag

**Modify**: `packages/cli/src/config/config.ts`

```typescript
// In parseArguments(), add option:
.option('agents', {
  type: 'string',
  description: 'JSON object defining runtime agents',
  coerce: (val: string) => {
    try {
      return JSON.parse(val);
    } catch {
      throw new Error('--agents must be valid JSON');
    }
  }
})
```

**Usage**:
```bash
gemini --agents '{
  "debugger": {
    "description": "Debug specialist",
    "prompt": "You are an expert debugger...",
    "tools": ["read_file", "shell", "grep"]
  }
}'
```

### 2.2 Process CLI Agents in Config

**Modify**: `packages/cli/src/config/config.ts`

```typescript
export async function loadCliConfig(...) {
  // After settings load, before config creation:
  const cliAgents = argv.agents ? parseCliAgents(argv.agents) : [];

  return new Config({
    ...existingProps,
    cliAgents,  // Pass to config for registry injection
  });
}
```

### 2.3 Files to Modify

| File | Action | Purpose |
|------|--------|---------|
| `packages/cli/src/config/config.ts` | MODIFY | Add --agents yargs option |
| `packages/cli/src/config/config.d.ts` | MODIFY | Add CliAgents type |
| `packages/core/src/config/config.ts` | MODIFY | Accept cliAgents in constructor |

---

## Phase 3: Background Agent Execution

### 3.1 Create AgentTaskManager

**File**: `packages/core/src/agents/task-manager.ts`

```typescript
export interface AgentTask {
  id: string;
  agentName: string;
  status: 'pending' | 'running' | 'completed' | 'error';
  startedAt: Date;
  completedAt?: Date;
  result?: OutputObject;
  error?: Error;
}

export class AgentTaskManager {
  private tasks: Map<string, AgentTask> = new Map();
  private executors: Map<string, AgentExecutor> = new Map();

  async spawnBackground(
    definition: AgentDefinition,
    inputs: AgentInputs,
    config: Config
  ): Promise<string> {
    const taskId = crypto.randomUUID();
    const task: AgentTask = {
      id: taskId,
      agentName: definition.name,
      status: 'pending',
      startedAt: new Date()
    };

    this.tasks.set(taskId, task);

    // Run in background (don't await)
    this.executeInBackground(taskId, definition, inputs, config);

    return taskId;
  }

  private async executeInBackground(...): Promise<void> {
    const task = this.tasks.get(taskId)!;
    task.status = 'running';

    try {
      const executor = await AgentExecutor.create(definition, config);
      this.executors.set(taskId, executor);

      const result = await executor.run(inputs, this.createSignal(taskId));

      task.status = 'completed';
      task.result = result;
      task.completedAt = new Date();
    } catch (error) {
      task.status = 'error';
      task.error = error;
      task.completedAt = new Date();
    }
  }

  async getOutput(taskId: string, options: {
    block?: boolean;
    timeout?: number;
  }): Promise<AgentTask> {
    const task = this.tasks.get(taskId);
    if (!task) throw new Error(`Task ${taskId} not found`);

    if (options.block && task.status === 'running') {
      await this.waitForCompletion(taskId, options.timeout);
    }

    return task;
  }

  cancelTask(taskId: string): void {
    // Abort the executor's signal
  }

  listTasks(): AgentTask[] {
    return Array.from(this.tasks.values());
  }
}
```

### 3.2 Integrate with delegate_to_agent Tool

**Modify**: `packages/core/src/agents/delegate-to-agent-tool.ts`

Add `run_in_background` parameter:

```typescript
type DelegateParams = {
  agent_name: string;
  run_in_background?: boolean;  // NEW
} & Record<string, unknown>;

// In createInvocation():
if (params.run_in_background) {
  const taskId = await this.taskManager.spawnBackground(
    definition,
    params,
    this.config
  );
  return { taskId, status: 'spawned' };
}
```

### 3.3 Create TaskOutput Tool

**File**: `packages/core/src/agents/task-output-tool.ts`

```typescript
export class TaskOutputTool extends BaseDeclarativeTool {
  schema = z.object({
    task_id: z.string(),
    block: z.boolean().optional().default(true),
    timeout: z.number().optional().default(30000)
  });

  async execute(params): Promise<ToolResult> {
    const task = await this.taskManager.getOutput(params.task_id, {
      block: params.block,
      timeout: params.timeout
    });

    return {
      llmContent: [{ text: JSON.stringify(task, null, 2) }]
    };
  }
}
```

### 3.4 Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `packages/core/src/agents/task-manager.ts` | CREATE | Background task management |
| `packages/core/src/agents/task-output-tool.ts` | CREATE | Query task status |
| `packages/core/src/agents/delegate-to-agent-tool.ts` | MODIFY | Add background support |
| `packages/core/src/tools/tool-registry.ts` | MODIFY | Register TaskOutputTool |

---

## Phase 4: /agents Slash Command

### 4.1 Create Agents Command

**File**: `packages/cli/src/commands/extensions/agentsCommand.ts`

```typescript
import { SlashCommand, CommandContext, CommandResult } from '../types.js';

export function agentsCommand(registry: AgentRegistry): SlashCommand {
  return {
    command: 'agents',
    description: 'Manage available agents',
    subCommands: [
      {
        command: 'list',
        description: 'List all registered agents',
        action: async (ctx) => listAgents(registry, ctx)
      },
      {
        command: 'info',
        description: 'Show details about an agent',
        action: async (ctx) => showAgentInfo(registry, ctx)
      },
      {
        command: 'reload',
        description: 'Reload agents from filesystem',
        action: async (ctx) => reloadAgents(registry, ctx)
      }
    ],
    action: async (ctx) => listAgents(registry, ctx)  // Default: list
  };
}

async function listAgents(registry: AgentRegistry, ctx: CommandContext): Promise<CommandResult> {
  const agents = registry.getAllDefinitions();

  const output = agents.map(a =>
    `- **${a.name}**: ${a.description} [${a.source || 'builtin'}]`
  ).join('\n');

  return {
    type: 'markdown',
    content: `## Available Agents\n\n${output}`
  };
}

async function showAgentInfo(registry: AgentRegistry, ctx: CommandContext): Promise<CommandResult> {
  const agentName = ctx.args[0];
  const agent = registry.getDefinition(agentName);

  if (!agent) {
    return { type: 'error', content: `Agent '${agentName}' not found` };
  }

  return {
    type: 'markdown',
    content: `## ${agent.name}\n\n${agent.description}\n\n**Tools**: ${agent.toolConfig?.tools.join(', ')}\n**Model**: ${agent.modelConfig.model}`
  };
}
```

### 4.2 Register Command

**Modify**: `packages/cli/src/services/BuiltinCommandLoader.ts`

```typescript
import { agentsCommand } from '../commands/extensions/agentsCommand.js';

export class BuiltinCommandLoader implements ICommandLoader {
  async loadCommands(signal: AbortSignal): Promise<SlashCommand[]> {
    return [
      // ... existing commands
      agentsCommand(this.agentRegistry),  // NEW
    ];
  }
}
```

### 4.3 Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `packages/cli/src/commands/extensions/agentsCommand.ts` | CREATE | /agents command |
| `packages/cli/src/services/BuiltinCommandLoader.ts` | MODIFY | Register command |

---

## Phase 5: Testing & Documentation

### 5.1 Test Files to Create

| Test File | Purpose |
|-----------|---------|
| `packages/cli/src/services/FileAgentLoader.test.ts` | Test markdown parsing |
| `packages/core/src/agents/task-manager.test.ts` | Test background execution |
| `packages/cli/src/commands/extensions/agentsCommand.test.ts` | Test slash command |

### 5.2 Documentation Updates

- Update `docs/cli/agents.md` with new agent definition format
- Add examples to `docs/tools/agents.md`
- Update README with agent features

---

## Implementation Order

1. **Phase 1.1-1.2**: FileAgentLoader + Registry integration (foundation)
2. **Phase 4**: /agents command (user visibility)
3. **Phase 2**: CLI --agents flag (power users)
4. **Phase 3**: Background execution (advanced feature)
5. **Phase 5**: Tests and documentation

---

## Critical Files Summary

### Files to Create
```
packages/cli/src/services/FileAgentLoader.ts
packages/core/src/agents/task-manager.ts
packages/core/src/agents/task-output-tool.ts
packages/cli/src/commands/extensions/agentsCommand.ts
```

### Files to Modify
```
packages/core/src/agents/registry.ts
packages/core/src/agents/types.ts
packages/core/src/agents/delegate-to-agent-tool.ts
packages/cli/src/config/config.ts
packages/cli/src/services/BuiltinCommandLoader.ts
packages/core/src/tools/tool-registry.ts
```

---

## Design Decisions

### File Format: Markdown (.md) - Recommended
- Agent prompts are long text, more readable in markdown
- YAML frontmatter is a common, well-supported pattern
- Claude Code proved this pattern works well for agent definitions
- Markdown allows syntax highlighting for the prompt body in editors

### Implementation Location: Fork Gemini CLI - Recommended
- Gemini CLI is open source (Apache 2.0 license)
- Direct modification gives full control over all components
- Can potentially submit as PR to main repo if successful
- Extension system in Gemini CLI is less mature for this use case

### Implementation: Full implementation in order
- Phase 1 (File-based agents) → Phase 4 (/agents command) → Phase 2 (CLI flag) → Phase 3 (Background execution) → Phase 5 (Tests/Docs)

---

## Getting Started

```bash
# Clone Gemini CLI
git clone https://github.com/google-gemini/gemini-cli.git
cd gemini-cli

# Install dependencies
npm install

# Build
npm run build

# Link for local testing
npm link
```
