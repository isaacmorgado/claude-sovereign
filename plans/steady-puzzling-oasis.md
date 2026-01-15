# Phase 14: Claude Subscription Provider (via CLI)

## Overview
Add a new "claude-subscription" provider that routes requests through the Claude CLI, allowing users to leverage their Claude Pro/Max subscription instead of paying for API credits.

## How It Works
```
Your App → claude-subscription provider → Claude CLI → User's Subscription → Claude
```

The Claude CLI (`@anthropic-ai/claude-code`) handles OAuth authentication and billing through the user's existing subscription.

---

## Implementation Steps

### 1. Add Provider Type

**File: `packages/types/src/provider-settings.ts`**
- Add `"claude-subscription"` to `providerNames` array
- Add settings schema:
```typescript
const claudeSubscriptionSchema = apiModelIdProviderModelSchema.extend({
  claudeSubscriptionModel: z.enum(["sonnet", "opus", "haiku"]).optional(),
  claudeSubscriptionTimeout: z.number().optional(), // Default 120s
})
```

### 2. Create Provider Handler

**File: `src/api/providers/claude-subscription.ts`**

```typescript
import { execa } from "execa"
import { BaseProvider } from "./base-provider"
import { ApiStream } from "../transform/stream"

export class ClaudeSubscriptionHandler extends BaseProvider {
  private model: string
  private timeout: number

  constructor(options: ApiHandlerOptions) {
    super()
    this.model = options.claudeSubscriptionModel ?? "sonnet"
    this.timeout = options.claudeSubscriptionTimeout ?? 120000
  }

  override async *createMessage(
    systemPrompt: string,
    messages: Anthropic.Messages.MessageParam[],
    metadata?: ApiHandlerCreateMessageMetadata,
  ): ApiStream {
    // 1. Convert messages to single prompt string
    const prompt = this.formatPrompt(systemPrompt, messages)

    // 2. Spawn CLI with streaming
    const subprocess = execa("claude", [
      "-p", prompt,
      "--model", this.model,
      "--output-format", "stream-json", // If supported, else parse text
    ], {
      timeout: this.timeout,
      reject: false,
    })

    // 3. Stream output chunks
    for await (const chunk of subprocess.stdout) {
      yield { type: "text", text: chunk.toString() }
    }

    // 4. Handle errors
    const result = await subprocess
    if (result.exitCode !== 0) {
      throw new Error(`Claude CLI error: ${result.stderr}`)
    }

    // 5. Yield usage (estimated)
    yield { type: "usage", inputTokens: 0, outputTokens: 0 }
  }

  override getModel() {
    return {
      id: `claude-subscription-${this.model}`,
      info: {
        maxTokens: 8192,
        contextWindow: 200000,
        supportsImages: true,
        supportsPromptCache: false,
      }
    }
  }

  private formatPrompt(system: string, messages: MessageParam[]): string {
    // Convert Anthropic message format to single prompt
    let prompt = `System: ${system}\n\n`
    for (const msg of messages) {
      const role = msg.role === "user" ? "Human" : "Assistant"
      const content = typeof msg.content === "string"
        ? msg.content
        : msg.content.map(c => c.type === "text" ? c.text : "[image]").join("")
      prompt += `${role}: ${content}\n\n`
    }
    return prompt
  }
}
```

### 3. Register Provider

**File: `src/api/index.ts`**
```typescript
import { ClaudeSubscriptionHandler } from "./providers/claude-subscription"

// In buildApiHandler():
case "claude-subscription":
  return new ClaudeSubscriptionHandler(options)
```

**File: `src/api/providers/index.ts`**
```typescript
export { ClaudeSubscriptionHandler } from "./claude-subscription"
```

### 4. Add CLI Check Utility

**File: `src/api/providers/claude-subscription.ts`** (add to class)
```typescript
static async checkCliStatus(): Promise<{
  installed: boolean
  authenticated: boolean
  error?: string
}> {
  try {
    const result = await execa("claude", ["--version"], { reject: false })
    if (result.exitCode !== 0) {
      return { installed: false, authenticated: false, error: "CLI not found" }
    }

    // Check auth by running a simple command
    const authCheck = await execa("claude", ["-p", "hi", "--max-tokens", "1"], {
      reject: false,
      timeout: 10000
    })

    if (authCheck.stderr?.includes("not authenticated")) {
      return { installed: true, authenticated: false, error: "Not authenticated" }
    }

    return { installed: true, authenticated: true }
  } catch (e) {
    return { installed: false, authenticated: false, error: String(e) }
  }
}
```

### 5. Add UI Settings

**File: `webview-ui/src/components/settings/ApiOptions.tsx`**
Add case for `claude-subscription`:
- Model selector: Sonnet (default), Opus, Haiku
- Status indicator: CLI installed / authenticated
- Help text: "Requires Claude CLI: `npm i -g @anthropic-ai/claude-code`"
- Link to authenticate: "Run `claude` in terminal to login"

### 6. Add to useSelectedModel Hook

**File: `webview-ui/src/components/ui/hooks/useSelectedModel.ts`**
```typescript
case "claude-subscription": {
  const model = apiConfiguration.claudeSubscriptionModel ?? "sonnet"
  const info = {
    maxTokens: 8192,
    contextWindow: 200000,
    supportsImages: true,
    supportsPromptCache: false,
  }
  return { id: `claude-subscription-${model}`, info }
}
```

### 7. Add i18n Translations

**File: `webview-ui/src/i18n/locales/en/settings.json`**
```json
{
  "providers": {
    "claude-subscription": {
      "name": "Claude Subscription",
      "description": "Use your Claude Pro/Max subscription via CLI"
    }
  }
}
```

---

## Files to Create
1. `src/api/providers/claude-subscription.ts` - Main provider handler

## Files to Modify
1. `packages/types/src/provider-settings.ts` - Add provider type and schema
2. `src/api/index.ts` - Register handler in buildApiHandler
3. `src/api/providers/index.ts` - Export handler
4. `webview-ui/src/components/ui/hooks/useSelectedModel.ts` - Add case
5. `webview-ui/src/components/settings/ApiOptions.tsx` - Add UI
6. `webview-ui/src/i18n/locales/en/settings.json` - Add translations

---

## Error Handling
- **CLI not installed**: Show message with install command
- **Not authenticated**: Show message to run `claude` to login
- **Rate limited**: Parse CLI error and show subscription tier info
- **Timeout**: Configurable timeout with sensible default (120s)

---

## Limitations
- **No native tool calling**: CLI may not support structured tool responses
- **Token counting**: Estimated only (no direct API access)
- **Images**: Depends on CLI support for image input

---

## Build Commands
```bash
pnpm run check-types  # TypeScript validation
pnpm run lint         # ESLint
pnpm run test         # Unit tests
```

---

# Phase 11: Google OAuth & Claude-in-Chrome Integration

## Overview
Add Google OAuth for Gemini subscriptions and integrate Claude-in-Chrome as an MCP server for browser automation.

## Key Decisions
- **Claude-in-Chrome**: Configure as external MCP server via `bundled-servers.json` (simpler, follows existing patterns)
- **Google OAuth**: Support both OAuth for subscription detection AND API key fallback
- **Browser Extension**: No new extension needed - use existing Claude-in-Chrome MCP which connects to Claude Chrome extension

---

## Implementation Steps

### 1. Google OAuth Integration

#### 1.1 Create `src/integrations/google/oauth.ts`
Mirror the Claude Code OAuth pattern:
- PKCE flow with Google OAuth 2.0 endpoints
- Local HTTP callback server on port 54546
- Token storage in VS Code secrets
- Token refresh logic with 5-minute buffer

```typescript
// Key exports:
export const GOOGLE_OAUTH_CONFIG = {
  authorizationEndpoint: "https://accounts.google.com/o/oauth2/v2/auth",
  tokenEndpoint: "https://oauth2.googleapis.com/token",
  clientId: "<registered-client-id>",
  redirectUri: "http://localhost:54546/callback",
  scopes: "openid email https://www.googleapis.com/auth/cloud-platform",
}
export class GoogleOAuthManager { ... }
export const googleOAuthManager = new GoogleOAuthManager()
```

#### 1.2 Create `src/integrations/google/subscription.ts`
Subscription tier detection:
- `checkGeminiSubscription()` - query Google API for subscription status
- Support Free, Pro, Max tiers
- Cache subscription status with TTL

#### 1.3 Create `src/integrations/google/index.ts`
Export unified interface for Google auth:
- `getGeminiCredentials()` - returns OAuth token OR API key
- `isGeminiMaxSubscriber()` - check subscription tier

---

### 2. Update Gemini Provider

#### 2.1 Modify `src/api/providers/gemini.ts`
- Add support for OAuth token in addition to API key
- Check subscription tier for feature gating
- Use `googleOAuthManager.getAccessToken()` when OAuth is configured

---

### 3. Claude-in-Chrome MCP Integration

#### 3.1 Update `src/services/mcp/bundled/bundled-servers.json`
Add Claude-in-Chrome as bundled MCP server:
```json
{
  "claude-in-chrome": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/claude-in-chrome"],
    "disabled": true,
    "description": "Browser automation via Claude Chrome extension",
    "documentation": "https://github.com/anthropics/claude-in-chrome"
  }
}
```

#### 3.2 Update `src/services/mcp/bundled/index.ts`
Handle Claude-in-Chrome server lifecycle:
- Start MCP server when enabled
- Connect to existing Chrome extension if running

---

### 4. Extension Wiring

#### 4.1 Update `src/extension.ts`
Initialize Google OAuth manager:
```typescript
import { googleOAuthManager } from "./integrations/google/oauth"
// In activate():
googleOAuthManager.initialize(context)
```

Add settings change listener for Google auth:
```typescript
vscode.workspace.onDidChangeConfiguration((e) => {
  if (e.affectsConfiguration("multi-agent.google.enabled")) {
    // Re-initialize Google services
  }
})
```

---

### 5. VS Code Settings

#### 5.1 Update `src/package.json`
Add configuration properties:
```json
{
  "multi-agent.google.enabled": {
    "type": "boolean",
    "default": false,
    "description": "Enable Google OAuth for Gemini subscription features"
  },
  "multi-agent.google.useOAuth": {
    "type": "boolean",
    "default": false,
    "description": "Use Google OAuth instead of API key for Gemini"
  },
  "multi-agent.bundledMcp.claudeInChrome.enabled": {
    "type": "boolean",
    "default": false,
    "description": "Enable Claude-in-Chrome browser automation MCP server"
  }
}
```

---

## Files to Create
1. `src/integrations/google/oauth.ts` - Google OAuth flow
2. `src/integrations/google/subscription.ts` - Subscription management
3. `src/integrations/google/index.ts` - Unified exports

## Files to Modify
1. `src/services/mcp/bundled/bundled-servers.json` - Add Claude-in-Chrome
2. `src/services/mcp/bundled/index.ts` - Handle new server
3. `src/api/providers/gemini.ts` - Support OAuth token
4. `src/extension.ts` - Initialize Google OAuth
5. `src/package.json` - Add settings

---

## Build Commands
```bash
pnpm run check-types  # TypeScript validation
pnpm run lint         # ESLint
pnpm run test         # Unit tests
```

---

## Notes
- Existing `BrowserExtensionBridge` can be used alongside Claude-in-Chrome MCP for direct WebSocket communication if needed
- Google OAuth requires registering OAuth client in Google Cloud Console
- Claude-in-Chrome MCP handles Chrome extension communication internally

---

# Phase 12: Model Switching & Security Toolkit

## Overview
Add easy model switching, sub-agent model selection, and a comprehensive security/dev toolkit via MCP servers.

## User Requirements
1. **Easy model switching** without signing out
2. **Sub-agents use different models** - `new_task` tool should accept optional model/apiConfigId
3. **Add toolkit of tools**: Ghidra, GhidraMCP, Frida, Radare2, Mitmproxy, Httpie, Ffuf, Screenshot-to-Code, FFmpeg, DuckDB, JQ, Docker

---

## Implementation Steps

### 1. Sub-Agent Model Selection

Current architecture:
- `new_task` tool accepts: `mode`, `message`, `todos`
- `modeApiConfigs` maps modes → apiConfigId
- `delegateParentAndOpenChild()` calls `handleModeSwitch()` which sets the API config from modeApiConfigs

#### 1.1 Add `apiConfigId` parameter to `new_task` tool

**File: `src/core/prompts/tools/native-tools/new_task.ts`**
```typescript
// Add new parameter:
apiConfigId: {
  type: ["string", "null"],
  description: "Optional API configuration ID to use for this task (overrides mode default)"
}
```

**File: `src/core/tools/NewTaskTool.ts`**
```typescript
interface NewTaskParams {
  mode: string
  message: string
  todos?: string
  apiConfigId?: string  // NEW
}
```

#### 1.2 Update `delegateParentAndOpenChild()` to accept apiConfigId

**File: `src/core/webview/ClineProvider.ts`**
```typescript
public async delegateParentAndOpenChild(params: {
  parentTaskId: string
  message: string
  initialTodos: TodoItem[]
  mode: string
  apiConfigId?: string  // NEW - if provided, use this instead of mode's default
}): Promise<Task> {
  // ...
  // If apiConfigId provided, set currentApiConfigName before creating child
  if (params.apiConfigId) {
    await this.updateGlobalState("currentApiConfigName", params.apiConfigId)
  }
  await this.handleModeSwitch(mode as any)
  // ...
}
```

---

### 2. Model Quick Switcher UI

Add a command/keybinding to quickly switch API configs without navigating to settings.

#### 2.1 Add command to package.json
```json
{
  "command.switchApiConfig.title": "Switch Model"
}
```

#### 2.2 Implement quick picker
**File: `src/activate/registerCommands.ts`**
```typescript
vscode.commands.registerCommand('multi-agent.switchApiConfig', async () => {
  const configs = await providerSettingsManager.listApiConfigs()
  const picked = await vscode.window.showQuickPick(
    configs.map(c => ({ label: c.name, description: c.id })),
    { placeHolder: 'Select model configuration' }
  )
  if (picked) {
    await provider.updateApiConfiguration(picked.description)
  }
})
```

---

### 3. Security & Dev Toolkit MCP Servers

Add MCP server entries to `src/services/mcp/bundled/bundled-servers.json`:

```json
{
  "ghidra-mcp": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "ghidra-mcp"],
    "disabled": true,
    "description": "Ghidra reverse engineering via MCP (requires Ghidra installation)",
    "documentation": "https://github.com/LaurieWired/GhidraMCP"
  },
  "frida": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-server-frida"],
    "disabled": true,
    "description": "Frida dynamic instrumentation toolkit via MCP",
    "documentation": "https://frida.re/"
  },
  "radare2": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "mcp-server-radare2"],
    "disabled": true,
    "description": "Radare2 reverse engineering framework via MCP",
    "documentation": "https://rada.re/"
  },
  "mitmproxy": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "mcp-server-mitmproxy"],
    "disabled": true,
    "description": "Mitmproxy HTTP/HTTPS proxy via MCP",
    "documentation": "https://mitmproxy.org/"
  },
  "httpie": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "mcp-server-httpie"],
    "disabled": true,
    "description": "HTTPie HTTP client via MCP",
    "documentation": "https://httpie.io/"
  },
  "ffuf": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "mcp-server-ffuf"],
    "disabled": true,
    "description": "Ffuf web fuzzer via MCP",
    "documentation": "https://github.com/ffuf/ffuf"
  },
  "screenshot-to-code": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "mcp-server-screenshot-to-code"],
    "disabled": true,
    "description": "Screenshot to code conversion via MCP",
    "documentation": "https://github.com/abi/screenshot-to-code"
  },
  "ffmpeg": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "mcp-server-ffmpeg"],
    "disabled": true,
    "description": "FFmpeg media processing via MCP",
    "documentation": "https://ffmpeg.org/"
  },
  "duckdb": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "mcp-server-duckdb"],
    "disabled": true,
    "description": "DuckDB analytics database via MCP",
    "documentation": "https://duckdb.org/"
  },
  "jq": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "mcp-server-jq"],
    "disabled": true,
    "description": "JQ JSON processor via MCP",
    "documentation": "https://stedolan.github.io/jq/"
  }
}
```

**Note**: Docker MCP already exists in bundled-servers.json.

#### 3.1 Add VS Code settings for each tool
**File: `src/package.json`** (configuration section)
Add settings like:
```json
"multi-agent.bundledMcp.ghidraMcp.enabled": { "type": "boolean", "default": false },
"multi-agent.bundledMcp.frida.enabled": { "type": "boolean", "default": false },
// ... etc for each tool
```

---

## Files to Modify

### Core Changes
1. `src/core/prompts/tools/native-tools/new_task.ts` - Add apiConfigId parameter
2. `src/core/tools/NewTaskTool.ts` - Handle apiConfigId parameter
3. `src/core/webview/ClineProvider.ts` - Update delegateParentAndOpenChild signature

### UI Changes
4. `src/package.json` - Add switchApiConfig command
5. `src/activate/registerCommands.ts` - Implement quick picker command

### MCP Toolkit
6. `src/services/mcp/bundled/bundled-servers.json` - Add all toolkit entries
7. `src/package.json` - Add bundledMcp settings for each tool
8. `src/package.nls.json` - Add i18n strings for settings

---

## Build Commands
```bash
pnpm run check-types  # TypeScript validation
pnpm run lint         # ESLint
pnpm run test         # Unit tests
```

---

# Phase 13: RunPod Provider, Shadow/Clone Modes & Browser Tools Panel

## Overview
Create RunPod provider for serverless GPU endpoints, add Shadow and Clone specialized modes, and build a Browser Tools settings panel for easy MCP tool toggling.

## User Requirements
1. **RunPod Provider**: New provider for serverless GPU endpoints (OpenAI-compatible)
2. **Shadow Mode**: Automatically switches to RunPod provider (for uncensored/abliterated models)
3. **Clone Mode**: Optimized for Screenshot → Code tasks (high vision resolution, Tailwind context)
4. **Browser Tools Panel**: Settings section with checkboxes to toggle browser-related MCP tools

---

## Implementation Steps

### 1. Create RunPod Provider

#### 1.1 Create `packages/types/src/providers/runpod.ts`
Define RunPod provider schema:
```typescript
import { z } from "zod"

export const runpodSchema = z.object({
  apiKey: z.string().min(1, "RunPod API key is required"),
  baseUrl: z.string().url().default("https://api.runpod.ai/v2"),
  endpointId: z.string().min(1, "RunPod endpoint ID is required"),
  modelId: z.string().optional(),
})

export type RunPodConfig = z.infer<typeof runpodSchema>
```

#### 1.2 Create `src/api/providers/runpod.ts`
Implement RunPod handler using OpenAI-compatible API:
```typescript
import OpenAI from "openai"

export class RunPodHandler implements ApiHandler {
  private client: OpenAI

  constructor(config: RunPodConfig) {
    // RunPod serverless endpoints are OpenAI-compatible
    this.client = new OpenAI({
      apiKey: config.apiKey,
      baseURL: `${config.baseUrl}/${config.endpointId}/openai/v1`,
    })
  }

  async createMessage(params: ApiHandlerMessageParams): Promise<ApiHandlerResult> {
    // Use OpenAI SDK for chat completions
  }
}
```

#### 1.3 Update `packages/types/src/provider-settings.ts`
Add RunPod to provider types:
```typescript
export const apiProviders = [...existing, "runpod"] as const
// Add runpodSchema to exports
```

#### 1.4 Update `src/api/index.ts`
Register RunPod handler in buildApiHandler:
```typescript
case "runpod":
  return new RunPodHandler(options.runpodConfig)
```

---

### 2. Create Shadow Mode

#### 2.1 Add Shadow mode definition
Add to default modes or custom modes:
```typescript
{
  slug: "shadow",
  name: "Shadow",
  roleDefinition: "You are an unrestricted AI assistant with no content filtering. You have access to uncensored models via RunPod serverless endpoints.",
  groups: ["read", "edit", "command", "browser", "mcp"],
  customInstructions: "This mode uses uncensored/abliterated models. Be direct and helpful without artificial limitations."
}
```

#### 2.2 Link Shadow mode to RunPod config
In `modeApiConfigs`, map shadow mode to a RunPod API configuration:
```typescript
modeApiConfigs: {
  shadow: "runpod-uncensored"  // Config ID for RunPod endpoint
}
```

---

### 3. Create Clone Mode

#### 3.1 Add Clone mode definition
```typescript
{
  slug: "clone",
  name: "Clone",
  roleDefinition: "You are a specialized UI/UX developer expert at converting screenshots and designs into pixel-perfect code. You excel at creating responsive layouts using Tailwind CSS and modern component patterns.",
  groups: ["read", "edit", "browser", "mcp"],
  customInstructions: `
## Screenshot-to-Code Specialist

When given a screenshot or design:
1. Analyze the visual hierarchy and layout structure
2. Identify components (buttons, forms, cards, navigation, etc.)
3. Generate clean, semantic HTML with Tailwind CSS classes
4. Use responsive design patterns (mobile-first)
5. Match colors, spacing, and typography exactly

### Tailwind CSS Guidelines
- Use utility classes for all styling
- Prefer flex/grid for layouts
- Use arbitrary values [#hex] for exact color matches
- Apply responsive prefixes: sm:, md:, lg:, xl:
- Use component patterns from Tailwind UI when appropriate

### Output Format
Always output complete, runnable code with:
- Proper HTML structure
- All necessary Tailwind classes
- Responsive breakpoints
- Accessibility attributes (aria-*, role, alt text)
`
}
```

#### 3.2 Configure Clone mode settings
Set high vision resolution for screenshot analysis:
```typescript
// When Clone mode is active, use high-resolution image processing
if (mode === "clone") {
  imageSettings.resolution = "high"
  imageSettings.detail = "high"
}
```

---

### 4. Browser Tools Panel

#### 4.1 Update `packages/types/src/global-settings.ts`
Add browser tool toggle settings:
```typescript
export interface GlobalSettings {
  // ... existing

  // Browser Tools Panel
  browserToolsEnabled: {
    mitmproxy: boolean
    screenshotToCode: boolean
    claudeInChrome: boolean
    httpie: boolean
  }
}
```

#### 4.2 Create `webview-ui/src/components/settings/BrowserToolsPanel.tsx`
New settings panel component:
```typescript
export const BrowserToolsPanel = () => {
  const { settings, updateSettings } = useGlobalSettings()

  const tools = [
    { id: "mitmproxy", name: "Mitmproxy", description: "HTTP/HTTPS proxy for traffic inspection" },
    { id: "screenshotToCode", name: "Screenshot to Code", description: "Convert screenshots to HTML/CSS" },
    { id: "claudeInChrome", name: "Claude in Chrome", description: "Browser automation via Chrome extension" },
    { id: "httpie", name: "HTTPie", description: "HTTP client for API testing" },
  ]

  return (
    <Section title="Browser Tools">
      {tools.map(tool => (
        <Checkbox
          key={tool.id}
          label={tool.name}
          description={tool.description}
          checked={settings.browserToolsEnabled[tool.id]}
          onChange={(checked) => updateSettings({
            browserToolsEnabled: { ...settings.browserToolsEnabled, [tool.id]: checked }
          })}
        />
      ))}
    </Section>
  )
}
```

#### 4.3 Update `webview-ui/src/components/settings/SettingsView.tsx`
Add Browser Tools Panel to settings:
```typescript
import { BrowserToolsPanel } from "./BrowserToolsPanel"

// In render:
<BrowserToolsPanel />
```

#### 4.4 Wire tool toggles to MCP server enable/disable
In `src/services/mcp/bundled/index.ts`:
```typescript
// Watch for browser tool toggle changes
vscode.workspace.onDidChangeConfiguration((e) => {
  if (e.affectsConfiguration("browserToolsEnabled")) {
    syncBrowserToolMcpServers()
  }
})

async function syncBrowserToolMcpServers() {
  const settings = getGlobalSettings()
  const toolToServer = {
    mitmproxy: "mitmproxy",
    screenshotToCode: "screenshot-to-code",
    claudeInChrome: "claude-in-chrome",
    httpie: "httpie",
  }

  for (const [tool, server] of Object.entries(toolToServer)) {
    if (settings.browserToolsEnabled[tool]) {
      await enableMcpServer(server)
    } else {
      await disableMcpServer(server)
    }
  }
}
```

---

### 5. Screenshot-to-Code Quick Action

#### 5.1 Add screenshot capture button to Browser Tools Panel
```typescript
<Button
  icon="camera"
  onClick={async () => {
    // 1. Capture screenshot from active browser tab
    const screenshot = await captureActiveTab()
    // 2. Send to screenshot-to-code MCP server
    const code = await mcpClient.callTool("screenshot-to-code", "convert", { image: screenshot })
    // 3. Insert generated code into editor
    await insertCodeToEditor(code)
  }}
>
  Screenshot → Code
</Button>
```

---

## Files to Create

1. `packages/types/src/providers/runpod.ts` - RunPod schema
2. `src/api/providers/runpod.ts` - RunPod handler
3. `webview-ui/src/components/settings/BrowserToolsPanel.tsx` - Browser tools UI

## Files to Modify

1. `packages/types/src/provider-settings.ts` - Add RunPod provider type
2. `packages/types/src/global-settings.ts` - Add browserToolsEnabled settings
3. `src/api/index.ts` - Register RunPod handler
4. `src/core/config/CustomModesManager.ts` - Add Shadow and Clone modes
5. `src/services/mcp/bundled/index.ts` - Wire tool toggles to MCP servers
6. `webview-ui/src/components/settings/SettingsView.tsx` - Include BrowserToolsPanel

---

## Build Commands
```bash
pnpm run check-types  # TypeScript validation
pnpm run lint         # ESLint
pnpm run test         # Unit tests
```
