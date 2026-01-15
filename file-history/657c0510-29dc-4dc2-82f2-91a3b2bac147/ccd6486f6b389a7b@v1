# Kimi K2 Capabilities Reference

## Overview

Kimi K2 is fully integrated with tool emulation, enabling it to use all Claude Code features including MCP tools, agent spawning, and skill invocation.

**Model ID**: `featherless/moonshotai/Kimi-K2-Instruct`

**Key Stats**:
- 1 trillion parameter MoE (32B activated)
- 128K context window
- 65.8% on SWE-bench Verified (beats Claude Sonnet 4 and GPT-4.1)
- Optimized for agentic coding and autonomous problem-solving

## Supported Capabilities

### ✅ 1. MCP Tools
Kimi K2 can use ALL MCP tools through XML-based tool emulation:

**Examples**:
- `mcp__claude-in-chrome__*` - Browser automation
- `mcp__gemini__*` - Google Gemini integration
- `mcp__grep__searchGitHub` - GitHub code search
- All other registered MCP servers

**How it works**:
```xml
<tool_call>
{"name": "mcp__claude-in-chrome__computer", "arguments": {"action": "screenshot", "tabId": 12345}}
</tool_call>
```

### ✅ 2. Agent Spawning (Task Tool)
Kimi K2 can spawn specialized sub-agents in parallel:

**Available Agent Types**:
- `Bash` - Command execution
- `Explore` - Codebase exploration
- `Plan` - Implementation planning
- `claude-code-guide` - Documentation lookup
- `Root-cause-analyzer` - Debugging
- `build-researcher` - Research & architecture
- And 10+ more specialist agents

**Example - Parallel Agent Spawning**:
```xml
<tool_call>
{"name": "Task", "arguments": {"subagent_type": "Explore", "description": "Explore codebase", "prompt": "Analyze directory structure"}}
</tool_call>
<tool_call>
{"name": "Task", "arguments": {"subagent_type": "Root-cause-analyzer", "description": "Debug error", "prompt": "Find root cause of auth failure"}}
</tool_call>
```

### ✅ 3. Skills & Slash Commands
Kimi K2 can invoke all skills through the Skill tool:

**Available Skills**:
- `/research` - Code example search
- `/build` - Autonomous feature builder
- `/chrome` - Browser automation session
- `/checkpoint` - Save session state
- `/validate` - Run quality gates
- `/rootcause` - Root cause analysis
- `/re` - Reverse engineering
- And all other registered skills

**Example - Skill Invocation**:
```xml
<tool_call>
{"name": "Skill", "arguments": {"skill": "research", "args": "authentication patterns"}}
</tool_call>
```

### ✅ 4. Parallel Execution
Kimi K2 is optimized for parallel tool execution:

**Example - Multiple Operations in Parallel**:
```xml
<tool_call>
{"name": "Read", "arguments": {"file_path": "/path/to/file1.ts"}}
</tool_call>
<tool_call>
{"name": "Read", "arguments": {"file_path": "/path/to/file2.ts"}}
</tool_call>
<tool_call>
{"name": "Grep", "arguments": {"pattern": "class.*Component", "path": "src/"}}
</tool_call>
```

## How Tool Emulation Works

### System Prompt Injection
When Kimi K2 is invoked with tools, the proxy server automatically:

1. **Detects Featherless Provider** - Routes to `handleFeatherless()`
2. **Enables Tool Emulation** - Sets `emulateTools = true`
3. **Injects Instructions** - Adds comprehensive tool usage guide to system prompt
4. **Parses Responses** - Extracts `<tool_call>` XML tags from output
5. **Converts to Anthropic Format** - Returns proper tool_use blocks to Claude Code

### XML Format Requirements
Kimi K2 must respond with tools in this exact format:

```xml
<tool_call>
{"name": "tool_name", "arguments": {"param": "value"}}
</tool_call>
```

**Multiple Tools (Parallel)**:
```xml
<tool_call>
{"name": "tool1", "arguments": {...}}
</tool_call>
<tool_call>
{"name": "tool2", "arguments": {...}}
</tool_call>
```

### Tool Call Parsing
The proxy server uses regex to extract tool calls:
```javascript
/<tool_call>\s*(\{[\s\S]*?\})\s*<\/tool_call>/g
```

This allows Kimi K2 to use tools without native tool calling support.

## Usage Patterns

### Pattern 1: Research with Multiple Agents
```
Task: Research authentication patterns and analyze security

Kimi K2 Response:
<tool_call>
{"name": "Skill", "arguments": {"skill": "research", "args": "authentication OAuth JWT"}}
</tool_call>
<tool_call>
{"name": "Task", "arguments": {"subagent_type": "red-teamer", "description": "Security analysis", "prompt": "Find auth vulnerabilities"}}
</tool_call>
```

### Pattern 2: Codebase Exploration + Code Reading
```
Task: Explore codebase and read key files

Kimi K2 Response:
<tool_call>
{"name": "Task", "arguments": {"subagent_type": "Explore", "description": "Explore structure", "prompt": "Map out project architecture", "model": "haiku"}}
</tool_call>
<tool_call>
{"name": "Read", "arguments": {"file_path": "src/index.ts"}}
</tool_call>
<tool_call>
{"name": "Read", "arguments": {"file_path": "package.json"}}
</tool_call>
```

### Pattern 3: Browser Automation + Research
```
Task: Research API docs and test in browser

Kimi K2 Response:
<tool_call>
{"name": "Skill", "arguments": {"skill": "research", "args": "Stripe API documentation"}}
</tool_call>
<tool_call>
{"name": "mcp__claude-in-chrome__navigate", "arguments": {"url": "https://stripe.com/docs", "tabId": 12345}}
</tool_call>
```

## Comparison with Claude

| Feature | Claude (Native) | Kimi K2 (Emulated) |
|---------|----------------|-------------------|
| MCP Tools | ✅ Native | ✅ XML Emulation |
| Parallel Tools | ✅ Native | ✅ XML Emulation |
| Agent Spawning | ✅ Task Tool | ✅ Task Tool (XML) |
| Skills | ✅ Skill Tool | ✅ Skill Tool (XML) |
| Code Quality | Excellent | Exceptional (SWE-bench) |
| Restrictions | Some | None (Abliterated) |
| Cost | Paid | Free (Featherless) |

## When to Use Kimi K2

### Best For:
1. **Agentic Coding Tasks** - Superior SWE-bench performance
2. **Autonomous Problem-Solving** - Designed for agentic workflows
3. **Unrestricted Analysis** - No content filtering (abliterated)
4. **Complex Coding Tasks** - Specialized for coding intelligence
5. **Cost-Sensitive Projects** - Free on Featherless

### Consider Claude Sonnet Instead If:
1. Native tool calling is critical for performance
2. You need the absolute latest model
3. Task requires Claude-specific optimizations
4. You prefer official Anthropic support

## Testing Kimi K2

Run the test script to verify all capabilities:
```bash
~/.claude/docs/test-kimi-k2-capabilities.sh
```

Expected output: All tests pass (✓)

## Switching to Kimi K2

```bash
# In Claude Code session
/model featherless/moonshotai/Kimi-K2-Instruct

# Or use the short name in MCP server
# (via multi-model-mcp-server.js)
ask_model model=kimi-k2 prompt="Your task here"
```

## Known Limitations

1. **Tool Emulation Latency** - Slight overhead from XML parsing
2. **Context Window** - 128K (vs Claude's variable contexts)
3. **Response Format** - Must follow XML format exactly
4. **Premium Only** - Requires Featherless premium subscription

## Configuration Files

Kimi K2 is configured in:
1. **Proxy Server**: `~/.claude/model-proxy-server.js` (line 1049)
2. **MCP Server**: `~/.claude/multi-model-mcp-server.js` (line 71)
3. **Startup Script**: `~/.claude/scripts/claude-with-proxy-fixed.sh` (line 129)

## References

- [Featherless Kimi K2 Page](https://featherless.ai/models/moonshotai/Kimi-K2-Instruct)
- [Kimi K2 GitHub](https://github.com/MoonshotAI/Kimi-K2)
- [Together AI Blog](https://www.together.ai/blog/kimi-k2-leading-open-source-model-now-available-on-together-ai)
- SWE-bench Verified: 65.8% (beats Claude Sonnet 4 and GPT-4.1)

---

**Last Updated**: 2026-01-12
**Status**: Production Ready ✅
