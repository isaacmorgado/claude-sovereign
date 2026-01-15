# Codebase Architecture Extraction Report

**Date:** 2026-01-11  
**Target Codebases:**
- **Claudish**: /Users/imorgado/Desktop/Development/Projects/claudish/
- **Roo-Code (KOMPLETE-KONTROL)**: /Users/imorgado/Projects/Roo-Code/

---

## Executive Summary

This exploration extracted implementation patterns, architectural designs, and reusable code from two sophisticated AI coding tools:

1. **Claudish** - A CLI proxy that enables Claude Code to work with any model (OpenRouter, Ollama, Gemini, etc.)
2. **Roo-Code/KOMPLETE-KONTROL** - A feature-rich VSCode extension with 40+ AI providers, agent delegation, and automation

### Key Findings

**What Makes These Tools Powerful:**
- Advanced model routing and provider abstraction
- Intelligent context management (condensation + truncation)
- Multi-agent/task delegation systems
- Model-specific adapters for quirky providers
- Comprehensive transform layers (Claude ↔ OpenAI ↔ Model-specific formats)
- Abliterated/uncensored model support via Featherless.ai

---

## Part 1: Claudish Architecture

**Repository:** github.com/MadAppGang/claudish  
**Purpose:** Run Claude Code with any model via OpenRouter, Ollama, local providers

### 1.1 Model Router Architecture

**Core Concept:** Dynamic model switching with model aliasing

```typescript
// proxy-server.ts - Model aliases for quick swapping
const MODEL_ALIASES: Record<string, string> = {
  'coding': 'fl/huihui-ai/DeepSeek-R1-Distill-Qwen-32B-abliterated',
  'reasoning': 'fl/huihui-ai/DeepSeek-R1-Distill-Qwen-32B-abliterated',
  'planning': 'fl/huihui-ai/DeepSeek-R1-Distill-Qwen-32B-abliterated',
  'security': 'fl/huihui-ai/DeepSeek-R1-Distill-Qwen-32B-abliterated',
  'reverse': 'fl/DeepHat/DeepHat-V1-7B'
};

// Runtime model swapping via >>swap command
state.model = newModel; // Mutable state for swapping
```

**Files:**
- `/src/proxy-server.ts` (400 lines) - Main routing logic
- `/src/model-selector.ts` (12k+ lines) - Fuzzy search model picker
- `/src/model-loader.ts` (7.7k lines) - OpenRouter model fetching

**Key Pattern:**  
Handler registry pattern with dynamic selection:
```typescript
const nativeHandler = new NativeHandler(anthropicApiKey);
const openRouterHandlers = new Map<string, ModelHandler>();
const localProviderHandlers = new Map<string, ModelHandler>();
const remoteProviderHandlers = new Map<string, ModelHandler>();

// Get or create handler for specific model
const getOpenRouterHandler = (targetModel: string): ModelHandler => {
  if (!openRouterHandlers.has(targetModel)) {
    openRouterHandlers.set(
      targetModel,
      new OpenRouterHandler(targetModel, openrouterApiKey, port)
    );
  }
  return openRouterHandlers.get(targetModel)!;
};
```

### 1.2 Provider Registry System

**File:** `/src/providers/provider-registry.ts` (193 lines)

**Local Provider Configuration:**
```typescript
export interface LocalProvider {
  name: string;
  baseUrl: string;
  apiPath: string;
  envVar: string;
  prefixes: string[];
  capabilities: ProviderCapabilities;
}

const getProviders = (): LocalProvider[] => [
  {
    name: "ollama",
    baseUrl: process.env.OLLAMA_HOST || "http://localhost:11434",
    apiPath: "/v1/chat/completions",
    envVar: "OLLAMA_BASE_URL",
    prefixes: ["ollama/", "ollama:"],
    capabilities: {
      supportsTools: true,
      supportsVision: false,
      supportsStreaming: true,
      supportsJsonMode: true,
    },
  },
  // ... lmstudio, vllm, mlx
];
```

**URL-based Model Support:**
```typescript
// Supports: http://localhost:11434/modelname
export function parseUrlModel(modelId: string): UrlParsedModel | null {
  if (!modelId.startsWith("http://") && !modelId.startsWith("https://")) {
    return null;
  }
  const url = new URL(modelId);
  const pathParts = url.pathname.split("/").filter(Boolean);
  const modelName = pathParts[pathParts.length - 1];
  const baseUrl = `${url.protocol}//${url.host}`;
  return { baseUrl, modelName };
}
```

### 1.3 Model Adapter System

**Purpose:** Handle model-specific quirks (Grok XML functions, Gemini formats, etc.)

**Base Adapter:** `/src/adapters/base-adapter.ts`
```typescript
export abstract class BaseModelAdapter {
  abstract processTextContent(
    textContent: string, 
    accumulatedText: string
  ): AdapterResult;
  
  abstract shouldHandle(modelId: string): boolean;
  abstract getName(): string;
  
  // Request preparation (e.g., thinking budget → reasoning_effort)
  prepareRequest(request: any, originalRequest: any): any {
    return request;
  }
  
  reset(): void {} // State cleanup between requests
}
```

**Available Adapters:**
- `grok-adapter.ts` - Parses XML function calls from Grok
- `gemini-adapter.ts` - Handles Gemini-specific formatting
- `deepseek-adapter.ts` - DeepSeek R1 reasoning extraction
- `qwen-adapter.ts` - Qwen model quirks
- `openai-adapter.ts` - O-series extended thinking
- `minimax-adapter.ts` - MiniMax model adaptations

**Adapter Manager:** `/src/adapters/adapter-manager.ts`
```typescript
export class AdapterManager {
  private adapters: BaseModelAdapter[] = [
    new GrokAdapter(),
    new GeminiAdapter(),
    new DeepSeekAdapter(),
    new QwenAdapter(),
    new OpenAIAdapter(),
    new MinimaxAdapter(),
  ];
  
  processChunk(chunk: string, accumulated: string): AdapterResult {
    for (const adapter of this.adapters) {
      if (adapter.shouldHandle(this.modelId)) {
        return adapter.processTextContent(chunk, accumulated);
      }
    }
    return new DefaultAdapter().processTextContent(chunk, accumulated);
  }
}
```

### 1.4 Transform Layer (Claude ↔ OpenAI)

**File:** `/src/transform.ts` (150+ lines shown)

**Request Transformation:**
```typescript
// Sanitize OpenAI params to Claude format
export function sanitizeRoot(req: any): DroppedParams {
  // Rename stop → stop_sequences
  if (req.stop !== undefined) {
    req.stop_sequences = Array.isArray(req.stop) ? req.stop : [req.stop];
    delete req.stop;
  }
  
  // Drop unsupported params
  const DROP_KEYS = [
    "n", "presence_penalty", "frequency_penalty", 
    "logit_bias", "seed", "response_format",
    "parallel_tool_calls", "reasoning_effort"
  ];
  
  for (const key of DROP_KEYS) {
    if (key in req) {
      dropped.push(key);
      delete req[key];
    }
  }
  
  // Ensure max_tokens is set (Claude requirement)
  if (req.max_tokens == null) {
    req.max_tokens = 4096;
  }
  
  return { keys: dropped };
}
```

**Tool Mapping:**
```typescript
export function mapTools(req: any): void {
  const openAITools = (req.tools ?? []).concat(
    (req.functions ?? []).map((f: any) => ({
      type: "function",
      function: f,
    }))
  );
  
  req.tools = openAITools.map((t: any) => ({
    name: t.function?.name ?? t.name,
    description: t.function?.description ?? t.description,
    input_schema: removeUriFormat(t.function?.parameters ?? t.input_schema),
  }));
  
  delete req.functions;
}
```

### 1.5 Abliterated Models Support (Featherless.ai)

**Design Document:** `/FEATHERLESS_PROVIDER_DESIGN.md` (599 lines)

**Key Innovation:** Tool calling via system prompt injection for models without native tool support

**Architecture:**
```
Claude Code → Claudish → Tool-to-Prompt Injector → Featherless API
                ↑                                            ↓
                └── Tool Call Reconstructor ← Response Parser
```

**Model Family Detection:**
```typescript
enum ModelFamily {
  QWEN = "qwen",      // Qwen, Qwen2, Qwen3
  LLAMA = "llama",    // Llama-2, Llama-3
  DEEPSEEK = "deepseek", // DeepSeek models
  MISTRAL = "mistral",
  UNKNOWN = "unknown"
}

function detectModelFamily(modelName: string): ModelFamily {
  const lower = modelName.toLowerCase();
  if (lower.includes('qwen')) return ModelFamily.QWEN;
  if (lower.includes('llama')) return ModelFamily.LLAMA;
  if (lower.includes('deepseek')) return ModelFamily.DEEPSEEK;
  // ...
}
```

**System Prompt Injection (Qwen Example):**
```
You have access to the following tools:

{tool_definitions}

When you need to call a tool, respond with ONLY a JSON object in this exact format:
<|im_start|>tool_call
{"name": "tool_name", "arguments": {"param1": "value1"}}
<|im_end|>

Do not include any other text when making a tool call.
```

**Tool Call Extraction Patterns:**
```typescript
const TOOL_CALL_PATTERNS = {
  // Qwen/ChatML style
  IM_START: {
    regex: /<\|im_start\|>tool_call\s*([\s\S]*?)<\|im_end\|>/gi,
    source: "featherless_qwen"
  },
  
  // XML-style tool_call
  XML_TOOL_CALL: {
    regex: /<tool_call>\s*([\s\S]*?)<\/tool_call>/gi,
    source: "xml_text"
  },
  
  // JSON in code block
  JSON_BLOCK: {
    regex: /```(?:json)?\s*(\{[\s\S]*?\})\s*```/gi,
    source: "json_block"
  },
  
  // Direct JSON
  JSON_DIRECT: {
    regex: /\{\s*"name"\s*:\s*"([^"]+)"\s*,\s*"arguments"\s*:\s*(\{[\s\S]*?\})\s*\}/gi,
    source: "json_direct"
  }
};
```

**Abliterated Model Examples:**
- `fl/huihui-ai/DeepSeek-R1-Distill-Qwen-32B-abliterated` - 128K context, no censorship
- `fl/DeepHat/DeepHat-V1-7B` - Specialized for reverse engineering

### 1.6 Configuration System

**File:** `/src/config.ts` (108 lines)

**Environment Variables (Priority Order):**
```typescript
export const ENV = {
  // Model selection (highest priority)
  CLAUDISH_MODEL: "CLAUDISH_MODEL",
  
  // Model mapping overrides
  CLAUDISH_MODEL_OPUS: "CLAUDISH_MODEL_OPUS",
  CLAUDISH_MODEL_SONNET: "CLAUDISH_MODEL_SONNET",
  CLAUDISH_MODEL_HAIKU: "CLAUDISH_MODEL_HAIKU",
  CLAUDISH_MODEL_SUBAGENT: "CLAUDISH_MODEL_SUBAGENT",
  
  // Fallback to Claude Code standard
  ANTHROPIC_DEFAULT_OPUS_MODEL: "ANTHROPIC_DEFAULT_OPUS_MODEL",
  ANTHROPIC_DEFAULT_SONNET_MODEL: "ANTHROPIC_DEFAULT_SONNET_MODEL",
  ANTHROPIC_DEFAULT_HAIKU_MODEL: "ANTHROPIC_DEFAULT_HAIKU_MODEL",
  CLAUDE_CODE_SUBAGENT_MODEL: "CLAUDE_CODE_SUBAGENT_MODEL",
  
  // API keys
  OPENROUTER_API_KEY: "OPENROUTER_API_KEY",
  GEMINI_API_KEY: "GEMINI_API_KEY",
  OPENAI_API_KEY: "OPENAI_API_KEY",
  
  // Local providers
  OLLAMA_BASE_URL: "OLLAMA_BASE_URL",
  LMSTUDIO_BASE_URL: "LMSTUDIO_BASE_URL",
  VLLM_BASE_URL: "VLLM_BASE_URL",
  
  // Optimizations
  CLAUDISH_SUMMARIZE_TOOLS: "CLAUDISH_SUMMARIZE_TOOLS",
} as const;
```

**Model Info Structure:**
```typescript
export const MODEL_INFO: Record<
  OpenRouterModel,
  { name: string; description: string; priority: number; provider: string }
> = {
  "x-ai/grok-code-fast-1": {
    name: "Ultra-fast coding",
    priority: 1,
    provider: "xAI",
  },
  "minimax/minimax-m2.1": {
    name: "Compact high-efficiency v2.1",
    priority: 2,
    provider: "MiniMax",
  },
  // ...
};
```

---

## Part 2: Roo-Code (KOMPLETE-KONTROL) Architecture

**Repository:** /Users/imorgado/Projects/Roo-Code  
**Purpose:** Feature-rich VSCode extension with 40+ AI providers, task delegation, automation

### 2.1 Provider Ecosystem (40+ Providers)

**File:** `/src/api/index.ts` (200+ lines)

**Provider Factory Pattern:**
```typescript
export function buildApiHandler(configuration: ProviderSettings): ApiHandler {
  const { apiProvider, ...options } = configuration

  switch (apiProvider) {
    case "anthropic":
      return new AnthropicHandler(options)
    case "claude-code":
      return new ClaudeCodeHandler(options)
    case "openrouter":
      return new OpenRouterHandler(options)
    case "gemini":
      // OAuth auto-detection
      if (hasGeminiOAuthCredentials()) {
        return new GeminiCliHandler(options)
      }
      return new GeminiHandler(options)
    case "zai":
      return new ZAiHandler(options) // Zhipu GLM-4
    // ... 40+ providers
  }
}

// OAuth credential detection
function hasGeminiOAuthCredentials(): boolean {
  return existsSync(path.join(os.homedir(), ".gemini", "oauth_creds.json"))
}
```

**Available Providers:**
- Core: Anthropic, OpenAI, OpenRouter
- Cloud: Bedrock, Vertex, Azure
- Specialized: Gemini, DeepSeek, Groq, Fireworks, DeepInfra
- Chinese: Zhipu (ZAi), Moonshot, Doubao, QwenCode
- Local: Ollama, LMStudio
- Research: HuggingFace, Baseten, Cerebras
- OAuth-enabled: Claude Code, Gemini

### 2.2 Transform System (Universal Format Conversion)

**File:** `/src/api/transform/openai-format.ts` (200+ lines shown)

**Key Innovation:** `mergeToolResultText` option for reasoning models

```typescript
export interface ConvertToOpenAiMessagesOptions {
  normalizeToolCallId?: (id: string) => string
  
  // CRITICAL for DeepSeek-reasoner, GLM-4.7 thinking models
  // User message after tool results causes model to drop reasoning_content
  mergeToolResultText?: boolean
}

export function convertToOpenAiMessages(
  anthropicMessages: Anthropic.Messages.MessageParam[],
  options?: ConvertToOpenAiMessagesOptions,
): OpenAI.Chat.ChatCompletionMessageParam[] {
  // ... conversion logic
  
  // Check if we should merge text into last tool message
  const shouldMergeIntoToolMessage =
    options?.mergeToolResultText && hasToolMessages && hasOnlyTextContent
  
  if (shouldMergeIntoToolMessage) {
    const lastToolMessage = openAiMessages[
      openAiMessages.length - 1
    ] as OpenAI.Chat.ChatCompletionToolMessageParam
    
    if (lastToolMessage?.role === "tool") {
      const additionalText = nonToolMessages
        .map((part) => (part as Anthropic.TextBlockParam).text)
        .join("\n")
      lastToolMessage.content = `${lastToolMessage.content}\n\n${additionalText}`
    }
  }
}
```

**Reasoning Details Preservation:**
```typescript
const mapReasoningDetails = (details: unknown): any[] | undefined => {
  if (!Array.isArray(details)) return undefined
  
  return details.map((detail: any) => {
    // Strip `id` from openai-responses-v1 blocks
    // OpenAI Responses API requires `store: true` to persist reasoning
    if (detail?.format === "openai-responses-v1" && detail?.id) {
      const { id, ...rest } = detail
      return rest
    }
    return detail
  })
}
```

### 2.3 Task Delegation System

**Files:**
- `/src/core/task/Task.ts` (4000+ lines)
- `/src/core/tools/NewTaskTool.ts` (160 lines)
- `/src/core/webview/ClineProvider.ts` (delegation logic)

**Task Options:**
```typescript
export interface TaskOptions extends CreateTaskOptions {
  provider: ClineProvider
  apiConfiguration: ProviderSettings
  enableDiff?: boolean
  enableCheckpoints?: boolean
  checkpointTimeout?: number
  enableBridge?: boolean
  fuzzyMatchThreshold?: number
  consecutiveMistakeLimit?: number
  task?: string
  images?: string[]
  historyItem?: HistoryItem
  experiments?: Record<string, boolean>
  startTask?: boolean
  rootTask?: Task
  parentTask?: Task
  taskNumber?: number
  onCreated?: (task: Task) => void
  initialTodos?: TodoItem[]
  workspacePath?: string
  initialStatus?: "active" | "delegated" | "completed"
}
```

**New Task Tool Implementation:**
```typescript
export class NewTaskTool extends BaseTool<"new_task"> {
  async execute(params: NewTaskParams, task: Task, callbacks: ToolCallbacks) {
    const { mode, message, todos } = params
    
    // Parse todos if provided
    let todoItems: TodoItem[] = []
    if (todos) {
      todoItems = parseMarkdownChecklist(todos)
    }
    
    // Verify mode exists
    const targetMode = getModeBySlug(mode, state?.customModes)
    if (!targetMode) {
      pushToolResult(formatResponse.toolError(`Invalid mode: ${mode}`))
      return
    }
    
    // Checkpoint before delegation
    if (task.enableCheckpoints) {
      task.checkpointSave(true)
    }
    
    // Delegate parent and open child as sole active task
    const child = await provider.delegateParentAndOpenChild({
      parentTaskId: task.taskId,
      message: unescapedMessage,
      initialTodos: todoItems,
      mode,
    })
    
    pushToolResult(`Delegated to child task ${child.taskId}`)
  }
}
```

**Current Limitation (Sequential Only):**
```typescript
// Task.ts line 3897
const parallelToolCallsEnabled = false  // Hardcoded disabled
```

### 2.4 Context Management System

**Files:**
- `/src/core/condense/index.ts` (200+ lines)
- `/src/core/context-management/index.ts` (150+ lines)

**Dual Strategy: Condensation + Truncation**

**1. Intelligent Condensation:**
```typescript
export async function summarizeConversation(
  messages: ApiMessage[],
  apiHandler: ApiHandler,
  systemPrompt: string,
  taskId: string,
  prevContextTokens: number,
  isAutomaticTrigger?: boolean,
  customCondensingPrompt?: string,
  condensingApiHandler?: ApiHandler,
  useNativeTools?: boolean,
): Promise<SummarizeResponse> {
  // Use separate API handler for condensing (e.g., fast model)
  const condensingHandler = condensingApiHandler ?? apiHandler
  
  // Custom prompt or default summary template
  const promptToUse = customCondensingPrompt || SUMMARY_PROMPT
  
  // Call LLM to generate summary
  const summaryResponse = await condensingHandler.createMessage(
    promptToUse,
    messagesToSummarize
  )
  
  // Replace old messages with summary + keep recent N messages
  const { keepMessages, toolUseBlocksToPreserve, reasoningBlocksToPreserve } = 
    getKeepMessagesWithToolBlocks(messages, N_MESSAGES_TO_KEEP)
  
  // Build summary message with preserved tool_use blocks
  const summaryMessage: ApiMessage = {
    role: "assistant",
    content: [
      { type: "text", text: summaryText },
      ...toolUseBlocksToPreserve,
      ...reasoningBlocksToPreserve, // For DeepSeek/Z.ai thinking
    ],
    ts: firstKeptMessage.ts - 1,
    condenseId
  }
  
  return {
    messages: [summaryMessage, ...keepMessages],
    summary: summaryText,
    cost: summaryCost,
    condenseId
  }
}
```

**Summary Prompt Structure:**
```
Your task is to create a detailed summary:

1. Previous Conversation: High level details about the entire conversation flow
2. Current Work: What was being worked on prior to this summary request
3. Key Technical Concepts: Technologies, frameworks, coding conventions
4. Relevant Files and Code: Files examined, modified, or created
5. Problem Solving: Problems solved and ongoing troubleshooting
6. Pending Tasks and Next Steps: Outstanding work with direct quotes
```

**2. Sliding Window Truncation (Fallback):**
```typescript
export function truncateConversation(
  messages: ApiMessage[], 
  fracToRemove: number, 
  taskId: string
): TruncationResult {
  const truncationId = crypto.randomUUID()
  
  // Filter to only visible messages (not already truncated)
  const visibleIndices: number[] = []
  messages.forEach((msg, index) => {
    if (!msg.truncationParent && !msg.isTruncationMarker) {
      visibleIndices.push(index)
    }
  })
  
  // Calculate messages to truncate (excluding first, rounded to even)
  const rawMessagesToRemove = Math.floor((visibleCount - 1) * fracToRemove)
  const messagesToRemove = rawMessagesToRemove - (rawMessagesToRemove % 2)
  
  // Tag messages as hidden instead of deleting
  const taggedMessages = messages.map((msg, index) => {
    if (indicesToTruncate.has(index)) {
      return { ...msg, truncationParent: truncationId }
    }
    return msg
  })
  
  // Insert truncation marker
  const truncationMarker: ApiMessage = {
    role: "user",
    content: `[Sliding window truncation: ${messagesToRemove} messages hidden]`,
    ts: firstKeptTs - 1,
    isTruncationMarker: true,
    truncationId,
  }
  
  return {
    messages: [...taggedMessages.slice(0, insertPosition), truncationMarker, ...taggedMessages.slice(insertPosition)],
    truncationId,
    messagesRemoved: messagesToRemove,
  }
}
```

**Tool Preservation Logic:**
```typescript
export function getKeepMessagesWithToolBlocks(
  messages: ApiMessage[], 
  keepCount: number
): KeepMessagesResult {
  const startIndex = messages.length - keepCount
  const keepMessages = messages.slice(startIndex)
  
  // Check if first kept message has tool_result blocks
  if (keepMessages.length > 0 && hasToolResultBlocks(keepMessages[0])) {
    const precedingIndex = startIndex - 1
    if (precedingIndex >= 0) {
      const precedingMessage = messages[precedingIndex]
      const toolUseBlocks = getToolUseBlocks(precedingMessage)
      const reasoningBlocks = getReasoningBlocks(precedingMessage)
      
      // Return tool_use AND reasoning blocks for DeepSeek/Z.ai
      return {
        keepMessages,
        toolUseBlocksToPreserve: toolUseBlocks,
        reasoningBlocksToPreserve: reasoningBlocks,
      }
    }
  }
  
  return { keepMessages, toolUseBlocksToPreserve: [], reasoningBlocksToPreserve: [] }
}
```

### 2.5 Automation System (Fully Implemented)

**Status:** ✅ PRODUCTION READY (December 2025)

**Files:**
- `/src/services/automation/AutomationManager.ts` (323 lines)
- `/src/services/automation/AutomationConfigLoader.ts` (YAML loader)
- `/src/services/automation/AutomationExecutor.ts` (Task execution)
- `/src/services/automation/TriggerRegistry.ts` (Lifecycle management)
- `/src/services/automation/triggers/` (All trigger types)

**Trigger Types:**
```typescript
// FileWatcherTrigger.ts - VS Code FileSystemWatcher integration
export class FileWatcherTrigger extends BaseTrigger {
  private watcher?: vscode.FileSystemWatcher
  
  async start(): Promise<void> {
    const pattern = new vscode.RelativePattern(
      this.workspaceRoot,
      this.config.watch.glob
    )
    
    this.watcher = vscode.workspace.createFileSystemWatcher(pattern)
    
    this.watcher.onDidChange(uri => this.handleChange(uri))
    this.watcher.onDidCreate(uri => this.handleCreate(uri))
    this.watcher.onDidDelete(uri => this.handleDelete(uri))
  }
}

// CronTrigger.ts - node-cron scheduled tasks
import cron from 'node-cron'

export class CronTrigger extends BaseTrigger {
  private task?: cron.ScheduledTask
  
  async start(): Promise<void> {
    this.task = cron.schedule(this.config.schedule, () => {
      this.emit('triggered', {
        type: 'cron',
        schedule: this.config.schedule,
      })
    })
  }
}

// GitHookTrigger.ts - VS Code Git API integration
export class GitHookTrigger extends BaseTrigger {
  async start(): Promise<void> {
    const gitExtension = vscode.extensions.getExtension('vscode.git')
    const git = gitExtension?.exports.getAPI(1)
    
    git.repositories.forEach(repo => {
      repo.state.onDidChange(() => {
        if (this.shouldTrigger(repo.state)) {
          this.emit('triggered', { type: 'git', event: 'commit' })
        }
      })
    })
  }
}
```

**YAML Configuration:**
```yaml
# .multiagent/automations.yaml
automations:
  - name: "test-on-save"
    enabled: true
    trigger:
      type: "file-watcher"
      watch:
        glob: "**/*.test.ts"
        events: ["change"]
    action:
      type: "task"
      mode: "architect"
      message: "Run tests for {{file_path}}"
      todos:
        - "Execute test file"
        - "Report results"
  
  - name: "daily-review"
    trigger:
      type: "cron"
      schedule: "0 9 * * *"  # 9 AM daily
    action:
      type: "task"
      mode: "code"
      message: "Review pending PRs"
```

**VSCode Integration:**
```typescript
// activate/registerCommands.ts
vscode.commands.registerCommand('komplete-kontrol.automationTrigger', 
  async (automationName: string) => {
    const manager = AutomationManager.getInstance()
    await manager.triggerManual(automationName)
  }
)

vscode.commands.registerCommand('komplete-kontrol.automationReload',
  async () => {
    const manager = AutomationManager.getInstance()
    await manager.reload()
  }
)

vscode.commands.registerCommand('komplete-kontrol.automationStats',
  async () => {
    const manager = AutomationManager.getInstance()
    const stats = manager.getStatistics()
    vscode.window.showInformationMessage(
      `Automations: ${stats.total}, Active: ${stats.active}`
    )
  }
)
```

---

## Part 3: Reusable Code Patterns

### 3.1 Provider Registry Pattern

**Use Case:** Dynamic provider selection without hardcoding

**Reusable Template:**
```typescript
interface Provider {
  name: string
  baseUrl: string
  apiPath: string
  prefixes: string[]
  capabilities: {
    supportsTools: boolean
    supportsVision: boolean
    supportsStreaming: boolean
  }
}

class ProviderRegistry {
  private providers: Provider[] = []
  private handlers = new Map<string, Handler>()
  
  register(provider: Provider) {
    this.providers.push(provider)
  }
  
  resolve(modelId: string): Provider | null {
    for (const provider of this.providers) {
      for (const prefix of provider.prefixes) {
        if (modelId.startsWith(prefix)) {
          return provider
        }
      }
    }
    return null
  }
  
  getOrCreateHandler(modelId: string): Handler {
    const provider = this.resolve(modelId)
    if (!provider) throw new Error(`Unknown provider for ${modelId}`)
    
    if (!this.handlers.has(modelId)) {
      this.handlers.set(modelId, new Handler(provider, modelId))
    }
    
    return this.handlers.get(modelId)!
  }
}
```

### 3.2 Model Adapter Pattern

**Use Case:** Handle model-specific response formats

**Reusable Template:**
```typescript
abstract class BaseAdapter {
  abstract shouldHandle(modelId: string): boolean
  abstract processChunk(chunk: string, accumulated: string): {
    cleanedText: string
    extractedToolCalls: ToolCall[]
    wasTransformed: boolean
  }
  abstract getName(): string
  
  // Optional: Request preprocessing
  prepareRequest(request: any, original: any): any {
    return request
  }
  
  // Optional: State reset
  reset(): void {}
}

class AdapterManager {
  private adapters: BaseAdapter[] = []
  
  register(adapter: BaseAdapter) {
    this.adapters.push(adapter)
  }
  
  processChunk(modelId: string, chunk: string, accumulated: string) {
    for (const adapter of this.adapters) {
      if (adapter.shouldHandle(modelId)) {
        return adapter.processChunk(chunk, accumulated)
      }
    }
    return new DefaultAdapter().processChunk(chunk, accumulated)
  }
}

// Example: Grok XML Function Call Adapter
class GrokAdapter extends BaseAdapter {
  shouldHandle(modelId: string): boolean {
    return modelId.includes('grok')
  }
  
  processChunk(chunk: string, accumulated: string) {
    const pattern = /<function=([^>]+)>([\s\S]*?)(?=<function=|$)/gi
    const toolCalls: ToolCall[] = []
    let cleanedText = chunk
    
    let match
    while ((match = pattern.exec(accumulated + chunk)) !== null) {
      const [fullMatch, functionName, argsJson] = match
      try {
        toolCalls.push({
          id: crypto.randomUUID(),
          name: functionName,
          arguments: JSON.parse(argsJson)
        })
        cleanedText = cleanedText.replace(fullMatch, '')
      } catch {}
    }
    
    return {
      cleanedText,
      extractedToolCalls: toolCalls,
      wasTransformed: toolCalls.length > 0
    }
  }
  
  getName(): string {
    return 'GrokAdapter'
  }
}
```

### 3.3 Context Management Pattern

**Use Case:** Handle large conversations without hitting token limits

**Reusable Template:**
```typescript
interface ContextManagementOptions {
  totalTokens: number
  contextWindow: number
  condenseThreshold: number  // e.g., 75 (trigger at 75% full)
  truncateThreshold: number  // e.g., 90 (emergency truncate at 90%)
  keepRecentMessages: number // e.g., 3 (always keep last 3)
}

class ContextManager {
  async manage(
    messages: Message[],
    apiHandler: ApiHandler,
    options: ContextManagementOptions
  ): Promise<Message[]> {
    const percentFull = (options.totalTokens / options.contextWindow) * 100
    
    // Strategy 1: Intelligent Condensation (75-90%)
    if (percentFull >= options.condenseThreshold && percentFull < options.truncateThreshold) {
      return await this.condense(messages, apiHandler, options)
    }
    
    // Strategy 2: Sliding Window Truncation (90%+)
    if (percentFull >= options.truncateThreshold) {
      return this.truncate(messages, options)
    }
    
    return messages
  }
  
  private async condense(
    messages: Message[],
    apiHandler: ApiHandler,
    options: ContextManagementOptions
  ): Promise<Message[]> {
    // Keep recent N messages
    const keepMessages = messages.slice(-options.keepRecentMessages)
    const toSummarize = messages.slice(0, -options.keepRecentMessages)
    
    // Call LLM to summarize
    const summary = await apiHandler.createMessage(
      SUMMARY_PROMPT,
      toSummarize
    )
    
    // Create summary message
    const summaryMessage: Message = {
      role: 'assistant',
      content: [{ type: 'text', text: summary }],
      ts: keepMessages[0].ts - 1,
      condenseId: crypto.randomUUID()
    }
    
    return [summaryMessage, ...keepMessages]
  }
  
  private truncate(
    messages: Message[],
    options: ContextManagementOptions
  ): Message[] {
    const keepCount = options.keepRecentMessages
    const startIndex = messages.length - keepCount
    
    // Tag old messages as hidden (non-destructive)
    const truncationId = crypto.randomUUID()
    const tagged = messages.map((msg, i) => {
      if (i < startIndex) {
        return { ...msg, truncationParent: truncationId }
      }
      return msg
    })
    
    // Insert marker
    const marker: Message = {
      role: 'user',
      content: `[Truncated ${startIndex} messages]`,
      isTruncationMarker: true,
      truncationId
    }
    
    return [marker, ...tagged.slice(startIndex)]
  }
}
```

### 3.4 Tool Call Recovery Pattern

**Use Case:** Extract tool calls from text when models don't support native tools

**Reusable Template:**
```typescript
interface ToolCallPattern {
  regex: RegExp
  source: string
  priority: number
}

const PATTERNS: ToolCallPattern[] = [
  {
    regex: /<\|im_start\|>tool_call\s*([\s\S]*?)<\|im_end\|>/gi,
    source: "qwen_style",
    priority: 1
  },
  {
    regex: /```(?:json)?\s*(\{[\s\S]*?\})\s*```/gi,
    source: "json_block",
    priority: 2
  },
  {
    regex: /<tool_call>\s*([\s\S]*?)<\/tool_call>/gi,
    source: "xml_style",
    priority: 3
  }
]

function extractToolCalls(text: string): ToolCall[] {
  const extracted: ToolCall[] = []
  
  for (const pattern of PATTERNS.sort((a, b) => a.priority - b.priority)) {
    let match
    while ((match = pattern.regex.exec(text)) !== null) {
      try {
        const jsonStr = match[1].trim()
        const parsed = JSON.parse(jsonStr)
        
        if (parsed.name) {
          extracted.push({
            id: crypto.randomUUID(),
            name: parsed.name,
            arguments: parsed.arguments || parsed.parameters || {}
          })
        }
      } catch (e) {
        // Try lenient JSON parsing
        const lenient = lenientJsonParse(match[1])
        if (lenient) extracted.push(lenient)
      }
    }
  }
  
  return deduplicateByHash(extracted)
}

function lenientJsonParse(text: string): ToolCall | null {
  try {
    // Remove trailing commas
    let cleaned = text.replace(/,(\s*[}\]])/g, '$1')
    // Fix unquoted keys
    cleaned = cleaned.replace(/(\w+):/g, '"$1":')
    return JSON.parse(cleaned)
  } catch {
    return null
  }
}

function deduplicateByHash(calls: ToolCall[]): ToolCall[] {
  const seen = new Set<string>()
  return calls.filter(call => {
    const hash = `${call.name}:${JSON.stringify(call.arguments)}`
    if (seen.has(hash)) return false
    seen.add(hash)
    return true
  })
}
```

### 3.5 Transform Layer Pattern

**Use Case:** Convert between different API formats (Claude ↔ OpenAI ↔ Custom)

**Reusable Template:**
```typescript
interface Transform {
  from: 'claude' | 'openai' | 'custom'
  to: 'claude' | 'openai' | 'custom'
}

class MessageTransformer {
  transformMessages(
    messages: any[],
    transform: Transform,
    options?: TransformOptions
  ): any[] {
    switch (`${transform.from}->${transform.to}`) {
      case 'claude->openai':
        return this.claudeToOpenAI(messages, options)
      case 'openai->claude':
        return this.openAIToClaude(messages, options)
      default:
        return messages
    }
  }
  
  private claudeToOpenAI(messages: any[], options?: TransformOptions): any[] {
    return messages.map(msg => {
      if (msg.role === 'assistant' && Array.isArray(msg.content)) {
        // Split tool_use and text blocks
        const textBlocks = msg.content.filter(b => b.type === 'text')
        const toolBlocks = msg.content.filter(b => b.type === 'tool_use')
        
        return {
          role: 'assistant',
          content: textBlocks.map(b => b.text).join('\n'),
          tool_calls: toolBlocks.map(b => ({
            id: b.id,
            type: 'function',
            function: {
              name: b.name,
              arguments: JSON.stringify(b.input)
            }
          }))
        }
      }
      
      if (msg.role === 'user' && Array.isArray(msg.content)) {
        // Handle tool_result blocks
        const toolResults = msg.content.filter(b => b.type === 'tool_result')
        const otherContent = msg.content.filter(b => b.type !== 'tool_result')
        
        const converted = []
        
        // Tool results first
        for (const result of toolResults) {
          converted.push({
            role: 'tool',
            tool_call_id: result.tool_use_id,
            content: result.content
          })
        }
        
        // Then user content (if mergeToolResultText is false)
        if (otherContent.length > 0 && !options?.mergeToolResultText) {
          converted.push({
            role: 'user',
            content: otherContent.map(b => 
              b.type === 'text' ? b.text : b
            )
          })
        }
        
        return converted
      }
      
      return msg
    }).flat()
  }
  
  private openAIToClaude(messages: any[], options?: TransformOptions): any[] {
    const converted = []
    let i = 0
    
    while (i < messages.length) {
      const msg = messages[i]
      
      if (msg.role === 'assistant') {
        const content: any[] = []
        
        // Add text content
        if (msg.content) {
          content.push({ type: 'text', text: msg.content })
        }
        
        // Add tool calls
        if (msg.tool_calls) {
          for (const call of msg.tool_calls) {
            content.push({
              type: 'tool_use',
              id: call.id,
              name: call.function.name,
              input: JSON.parse(call.function.arguments)
            })
          }
        }
        
        converted.push({
          role: 'assistant',
          content
        })
      } else if (msg.role === 'tool') {
        // Collect all tool results
        const toolResults: any[] = []
        while (i < messages.length && messages[i].role === 'tool') {
          toolResults.push({
            type: 'tool_result',
            tool_use_id: messages[i].tool_call_id,
            content: messages[i].content
          })
          i++
        }
        
        converted.push({
          role: 'user',
          content: toolResults
        })
        
        continue // Don't increment i again
      } else {
        converted.push(msg)
      }
      
      i++
    }
    
    return converted
  }
}
```

---

## Part 4: Key Learnings & Recommendations

### 4.1 What Makes These Tools Powerful

**Claudish Strengths:**
1. **Model Agnostic Design** - Works with any OpenAI-compatible API
2. **Abliterated Model Support** - Access to uncensored models via Featherless
3. **Dynamic Model Switching** - Runtime model swapping via `>>swap` command
4. **Comprehensive Adapters** - Handles quirks of 9+ model families
5. **Tool Call Recovery** - Extracts tools from text for models without native support

**Roo-Code Strengths:**
1. **40+ Provider Ecosystem** - Comprehensive provider abstraction
2. **Intelligent Context Management** - Dual strategy (condense + truncate)
3. **Task Delegation** - Parent/child task relationships
4. **Automation System** - File watchers, cron, git hooks
5. **Transform System** - Universal format conversion with reasoning preservation

### 4.2 Architecture Patterns to Adopt

**1. Provider Registry System**
- Extensible without code changes
- Dynamic handler instantiation
- Capability-based feature detection

**2. Model Adapter Pattern**
- Isolates model-specific quirks
- Easy to add new models
- Clean separation of concerns

**3. Transform Layer**
- Universal format conversion
- Special handling for reasoning models
- Tool/message preservation logic

**4. Context Management**
- Hybrid approach (intelligent + fallback)
- Non-destructive truncation
- Tool block preservation

**5. Tool Call Recovery**
- Multiple extraction patterns
- Priority-based matching
- Lenient JSON parsing

### 4.3 Recommended Tech Stack

**Core Libraries:**
- `@anthropic-ai/sdk` - Claude API client
- `openai` - OpenAI API client
- `@hono/node-server` - Fast HTTP server (Claudish)
- `undici` - Modern HTTP client
- `zod` - Runtime type validation

**Provider-Specific:**
- `@google/generative-ai` - Gemini API
- `@aws-sdk/client-bedrock-runtime` - AWS Bedrock
- `tiktoken` - Token counting

**Development:**
- `typescript` - Type safety
- `vitest` - Testing framework
- `@biomejs/biome` - Fast linter/formatter

### 4.4 Critical Implementation Details

**1. Tool Block Preservation (CRITICAL)**
When condensing/truncating context, ALWAYS preserve:
- `tool_use` blocks that match `tool_result` blocks
- `reasoning` blocks for DeepSeek/Z.ai thinking models
- First and last messages in conversation

**2. Reasoning Model Support**
Use `mergeToolResultText: true` for:
- DeepSeek-reasoner
- GLM-4.7 thinking mode
- Any model with interleaved reasoning

**3. OAuth Auto-Detection**
Check filesystem for credentials before falling back to API keys:
```typescript
const GEMINI_OAUTH_FILE = path.join(os.homedir(), ".gemini", "oauth_creds.json")
if (existsSync(GEMINI_OAUTH_FILE)) {
  return new GeminiCliHandler(options)
}
return new GeminiHandler(options)
```

**4. Model Family Detection**
Use simple string matching for model families:
```typescript
function detectFamily(model: string): Family {
  const m = model.toLowerCase()
  if (m.includes('qwen')) return 'QWEN'
  if (m.includes('llama')) return 'LLAMA'
  if (m.includes('deepseek')) return 'DEEPSEEK'
  return 'UNKNOWN'
}
```

**5. Environment Variable Priority**
```
1. Tool-specific: CLAUDISH_MODEL_OPUS
2. Tool standard: ANTHROPIC_DEFAULT_OPUS_MODEL
3. General: ANTHROPIC_MODEL
4. Default: claude-3-opus
```

### 4.5 Files to Extract for Reuse

**From Claudish:**
- `src/providers/provider-registry.ts` - Provider abstraction
- `src/adapters/base-adapter.ts` + all adapters - Model quirk handling
- `src/handlers/shared/tool-call-recovery.ts` - Tool extraction patterns
- `src/transform.ts` - Claude ↔ OpenAI conversion
- `FEATHERLESS_PROVIDER_DESIGN.md` - Abliterated model architecture

**From Roo-Code:**
- `src/api/transform/openai-format.ts` - Advanced message conversion
- `src/core/condense/index.ts` - Intelligent summarization
- `src/core/context-management/index.ts` - Hybrid context strategy
- `src/services/automation/` - Full automation system
- `src/core/tools/NewTaskTool.ts` - Task delegation pattern

---

## Part 5: Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Set up provider registry system
- [ ] Implement base adapter pattern
- [ ] Create transform layer (Claude ↔ OpenAI)
- [ ] Add token counting utilities

### Phase 2: Model Support (Week 2)
- [ ] Add OpenRouter handler
- [ ] Add Ollama/local provider handler
- [ ] Implement 3-5 model-specific adapters
- [ ] Add tool call recovery system

### Phase 3: Context Management (Week 3)
- [ ] Implement intelligent condensation
- [ ] Add sliding window truncation
- [ ] Tool block preservation logic
- [ ] Reasoning model support

### Phase 4: Advanced Features (Week 4)
- [ ] Abliterated model support (Featherless)
- [ ] Model aliasing system
- [ ] Runtime model switching
- [ ] OAuth credential detection

### Phase 5: Automation (Week 5)
- [ ] File watcher triggers
- [ ] Cron scheduling
- [ ] Git hook integration
- [ ] Task delegation system

---

## Part 6: Code Snippets for SPLICE Integration

### 6.1 Provider Registry for SPLICE

```typescript
// SPLICE: splice-backend/services/aiProviderRegistry.ts
interface AIProvider {
  name: string
  baseUrl: string
  apiPath: string
  prefixes: string[]
  apiKeyEnvVar: string
  capabilities: {
    supportsTools: boolean
    supportsVision: boolean
    supportsReasoning: boolean
  }
}

class AIProviderRegistry {
  private providers: AIProvider[] = [
    {
      name: "openrouter",
      baseUrl: "https://openrouter.ai",
      apiPath: "/api/v1/chat/completions",
      prefixes: ["or/", "openrouter/"],
      apiKeyEnvVar: "OPENROUTER_API_KEY",
      capabilities: {
        supportsTools: true,
        supportsVision: true,
        supportsReasoning: true
      }
    },
    {
      name: "gemini",
      baseUrl: process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com",
      apiPath: "/v1beta/models",
      prefixes: ["g/", "gemini/"],
      apiKeyEnvVar: "GEMINI_API_KEY",
      capabilities: {
        supportsTools: true,
        supportsVision: true,
        supportsReasoning: false
      }
    }
  ]
  
  resolve(modelId: string): AIProvider | null {
    for (const provider of this.providers) {
      for (const prefix of provider.prefixes) {
        if (modelId.startsWith(prefix)) {
          return provider
        }
      }
    }
    return null
  }
}
```

### 6.2 Context Manager for SPLICE

```typescript
// SPLICE: splice-backend/services/contextManager.ts
interface ContextOptions {
  maxTokens: number
  condenseAt: number  // percentage
  truncateAt: number  // percentage
}

class SPLICEContextManager {
  async manageContext(
    messages: any[],
    options: ContextOptions
  ): Promise<any[]> {
    const tokenCount = await this.countTokens(messages)
    const percentFull = (tokenCount / options.maxTokens) * 100
    
    // Use OpenAI for condensing (cheaper than Claude)
    if (percentFull >= options.condenseAt) {
      return await this.condense(messages)
    }
    
    return messages
  }
  
  private async condense(messages: any[]): Promise<any[]> {
    // Keep last 3 messages, summarize the rest
    const keepMessages = messages.slice(-3)
    const toSummarize = messages.slice(0, -3)
    
    const summaryPrompt = `Summarize this conversation focusing on:
1. Technical context and decisions
2. Files modified
3. Pending tasks
Keep it concise but include all critical details.`
    
    const summary = await this.callOpenAI(summaryPrompt, toSummarize)
    
    return [
      {
        role: 'assistant',
        content: `[Summary of previous conversation]\n\n${summary}`
      },
      ...keepMessages
    ]
  }
}
```

### 6.3 Music Generation Context Preservation

```typescript
// SPLICE: splice-backend/services/musicGeneration.ts
class MusicGenerationService {
  async generateMusic(params: MusicParams): Promise<MusicResult> {
    // Extract video context
    const context = await this.extractVideoContext(params.videoPath)
    
    // Use context-aware prompting
    const enrichedPrompt = this.enrichPrompt(params.prompt, context)
    
    // Call AI with full context
    const result = await this.callAI(enrichedPrompt)
    
    return result
  }
  
  private enrichPrompt(userPrompt: string, context: VideoContext): string {
    return `
Video Context:
- Duration: ${context.duration}s
- Mood: ${context.mood}
- Key scenes: ${context.scenes.join(', ')}

User Request: ${userPrompt}

Generate music that matches this context.
`
  }
}
```

---

## Summary

This extraction provides:

1. **Complete Architecture Patterns** from two production-grade tools
2. **40+ Reusable Code Snippets** for immediate implementation
3. **Implementation Roadmap** for building similar capabilities
4. **Critical Learnings** about context management, tool calling, and provider abstraction
5. **SPLICE-specific Integration Examples** ready for splice-backend

### Files Referenced

**Claudish (10+ key files):**
- proxy-server.ts, model-selector.ts, model-loader.ts
- providers/provider-registry.ts, providers/remote-provider-registry.ts
- adapters/base-adapter.ts + 9 model adapters
- transform.ts, config.ts
- FEATHERLESS_PROVIDER_DESIGN.md

**Roo-Code (15+ key files):**
- api/index.ts, api/transform/openai-format.ts
- core/task/Task.ts, core/tools/NewTaskTool.ts
- core/condense/index.ts, core/context-management/index.ts
- services/automation/* (5+ files)
- MULTIAGENT_CONTINUATION.md

### Next Steps

1. Review this extraction report
2. Identify which patterns are most valuable for SPLICE
3. Adapt provider registry for SPLICE's music generation use case
4. Implement context management for long video processing sessions
5. Consider abliterated models for creative music generation

---

**End of Extraction Report**
