# Phase 2 Completion Plan: Weeks 15-20

## Current Status

Most Phase 2 features are **already implemented**:

| Feature Area | Status | Existing Files |
|-------------|--------|----------------|
| Advanced Provider Features | ✅ 95% | caching.ts, fallback.ts, load-balancer.ts, rate-limiter.ts, streaming.ts |
| MCP Integration | ✅ 100% | client.ts, registry.ts, stdio-bridge.ts, types.ts, echo-server.ts |
| Agent Infrastructure | ✅ 95% | registry.ts, lifecycle.ts, communication.ts, coordination.ts |
| Task Execution | ✅ 100% | planner.ts, executor.ts, aggregator.ts, dependency-resolver.ts |

## Remaining Work (Priority Order)

---

## 1. CRITICAL: Fix performTaskExecution() Placeholder

**File**: `src/core/agents/orchestrator.ts` (lines 556-569)

**Current Placeholder:**
```typescript
private async performTaskExecution(task: OrchestratedTask): Promise<AgentTaskResult> {
  // This is a placeholder implementation
  return {
    taskId: task.id,
    success: true,
    output: `Task executed: ${task.description}`,
    metadata: { agentId: task.assignedAgent },
  };
}
```

### Solution: Create Agent Executor

**New File**: `src/core/agents/executor.ts`

```typescript
export interface AgentExecutorConfig {
  defaultProvider: string;
  defaultModel: string;
  maxIterations: number;
  executionTimeoutMs: number;
}

export interface ExecutionContext {
  agentId: string;
  task: AgentTask;
  messages: Message[];
  tools: Tool[];
}

export interface ExecutionResult {
  taskId: string;
  agentId: string;
  success: boolean;
  output: unknown;
  messages: Message[];
  toolCalls: ToolCallRecord[];
  usage: { inputTokens: number; outputTokens: number; };
  durationMs: number;
  error?: Error;
}

export class AgentExecutor {
  // Connect to ProviderRegistry for LLM access
  // Connect to MCPClient for tool execution
  // Connect to ContextWindowManager for context
  // Execute agent with agentic loop (call LLM → tool_use → call tool → repeat)
}
```

### Modifications

| File | Changes |
|------|---------|
| `src/core/agents/orchestrator.ts` | Replace placeholder with real executor call |
| `src/core/agents/index.ts` | Export AgentExecutor |
| `src/types/index.ts` | Add ExecutionResult, ExecutionContext types |

---

## 2. Missing Advanced Provider Features

### New Files to Create

| File | Purpose |
|------|---------|
| `src/core/providers/advanced/token-counter.ts` | Accurate token counting with js-tiktoken for OpenAI |
| `src/core/providers/advanced/embeddings.ts` | Embeddings API for OpenAI and Ollama |
| `src/core/providers/advanced/persistent-cache.ts` | SQLite-backed persistent cache (extends existing caching.ts) |
| `src/core/providers/advanced/cost-tracker.ts` | Per-request cost tracking |

### Modifications

| File | Changes |
|------|---------|
| `src/core/providers/openai.ts` | Use TiktokenCounter for accurate token counting, add `embed()` |
| `src/core/providers/ollama.ts` | Add `embed()` using /api/embeddings |
| `src/core/providers/base.ts` | Add optional `embed()` method signature |
| `src/core/providers/advanced/index.ts` | Export new modules |
| `package.json` | Add `js-tiktoken` dependency |

---

## 3. Write/Expand Tests

### New Test Files

| Test File | Coverage |
|-----------|----------|
| `tests/agent-executor.test.ts` | AgentExecutor execution loop, provider integration, tool execution |
| `tests/token-counter.test.ts` | Tiktoken accuracy for different models |
| `tests/embeddings.test.ts` | Embeddings API for OpenAI/Ollama |
| `tests/persistent-cache.test.ts` | SQLite cache persistence |
| `tests/cost-tracker.test.ts` | Cost calculation and tracking |

### Expand Existing Tests

| Test File | Additions |
|-----------|-----------|
| `tests/task-execution.test.ts` | Add tests for real agent execution (not placeholder) |
| `tests/advanced-provider-features.test.ts` | Add token counting, embeddings tests |

---

## 4. Update Documentation

| File | Updates |
|------|---------|
| `README.md` | Add Phase 2 completion section |
| `docs/PHASE2_SUMMARY.md` (new) | Comprehensive Phase 2 overview |
| `docs/agents.md` (new) | Agent execution model, how tasks flow through system |
| `docs/providers.md` (new) | Advanced provider features, embeddings, cost tracking |

---

## Implementation Order

### Step 1: Agent Executor (CRITICAL)
1. Create `src/core/agents/executor.ts` with AgentExecutor class
2. Add types to `src/types/index.ts`
3. Update `src/core/agents/orchestrator.ts` to use executor
4. Write `tests/agent-executor.test.ts`

### Step 2: Token Counter
5. Create `src/core/providers/advanced/token-counter.ts`
6. Add `js-tiktoken` to package.json
7. Update `src/core/providers/openai.ts` to use accurate counting
8. Write `tests/token-counter.test.ts`

### Step 3: Embeddings
9. Create `src/core/providers/advanced/embeddings.ts`
10. Update `openai.ts` and `ollama.ts` with embed() methods
11. Write `tests/embeddings.test.ts`

### Step 4: Persistent Cache & Cost Tracking
12. Create `src/core/providers/advanced/persistent-cache.ts`
13. Create `src/core/providers/advanced/cost-tracker.ts`
14. Write tests for both

### Step 5: Documentation
15. Create `docs/PHASE2_SUMMARY.md`
16. Create `docs/agents.md`
17. Create `docs/providers.md`
18. Update `README.md`

---

## Critical Files

| File | Priority | Action |
|------|----------|--------|
| `src/core/agents/executor.ts` | **CRITICAL** | CREATE - Real agent execution engine |
| `src/core/agents/orchestrator.ts:556-569` | **CRITICAL** | MODIFY - Replace placeholder |
| `src/core/providers/advanced/token-counter.ts` | HIGH | CREATE - Accurate token counting |
| `src/core/providers/advanced/embeddings.ts` | HIGH | CREATE - Embeddings API |
| `src/types/index.ts` | HIGH | MODIFY - Add execution types |

---

## Dependencies

Add to `package.json`:
```json
{
  "dependencies": {
    "js-tiktoken": "^1.0.8"
  }
}
```

---

## Success Criteria

- [ ] `performTaskExecution()` actually executes tasks with real LLM calls
- [ ] Agents can use MCP tools during execution
- [ ] Token counting uses tiktoken for OpenAI (not 4-char approximation)
- [ ] Embeddings API works for OpenAI and Ollama
- [ ] All new features have tests
- [ ] Documentation updated
