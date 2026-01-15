# Multi-Provider Integration Guide for Claude Code

## Overview

This guide explains how to use **GLM**, **Featherless.ai**, **Google Gemini**, and **Anthropic** models seamlessly with Claude Code through an intelligent proxy server that:

- ✅ **Translates API formats** automatically
- ✅ **Emulates tool calling** for abliterated models
- ✅ **Preserves all Claude Code features** (MCP tools, agents, etc.)
- ✅ **Enables instant model switching** with `/model` command

---

## 🚀 Quick Start

### 1. Start Claude Code with Proxy

```bash
# Easy way - use the wrapper script
~/.claude/scripts/claude-with-proxy.sh

# Manual way - set the base URL
ANTHROPIC_BASE_URL=http://127.0.0.1:3000 claude
```

The proxy server will automatically start and you'll see:

```
╔═══════════════════════════════════════════════════════════════╗
║   Claude Code with Multi-Provider Proxy                      ║
║   GLM · Featherless · Google · Anthropic                      ║
╚═══════════════════════════════════════════════════════════════╝

🚀 Server running on http://127.0.0.1:3000

Supported Providers:
  ✓ GLM (ZhipuAI)     - glm/glm-4
  ✗ Featherless.ai   - featherless/model-name (tool emulation)
  ✗ Google Gemini    - google/gemini-pro
  ✗ Anthropic        - anthropic/claude-sonnet-4-5
```

### 2. Switch Models

Inside Claude Code, use the `/model` command:

```
/model glm/glm-4
/model featherless/Llama-3-8B-Instruct-abliterated
/model google/gemini-pro
/model anthropic/claude-opus-4-5
```

### 3. Use Tools Normally

All Claude Code tools work automatically, even with abliterated models:

```
Can you read the file README.md and then search for "installation"?
```

The proxy will automatically:
- Inject tool definitions into the prompt for abliterated models
- Parse tool calls from the model's response
- Convert them back to Claude Code's expected format

---

## 📋 Supported Providers

### 1. GLM (ZhipuAI) - ✅ CONFIGURED

**Status**: Ready to use
**API Key**: Configured
**Models**:
- `glm/glm-4` - Most capable (128K context)
- `glm/glm-4-air` - Balanced (128K context)
- `glm/glm-4-airx` - Ultra-fast (8K context)
- `glm/glm-4-flash` - Fastest (128K context)
- `glm/glm-3-turbo` - Legacy (128K context)

**Tool Support**: Native (glm-4, glm-4-plus) or emulated (others)

**Example**:
```
/model glm/glm-4
Write a Python function to calculate fibonacci numbers
```

---

### 2. Featherless.ai - ⚠️ NEEDS API KEY

**Status**: Configured but needs API key
**API Key**: Set `FEATHERLESS_API_KEY` environment variable
**Models**: Any model from Featherless catalog

**Popular Abliterated Models**:
- `featherless/Llama-3-8B-Instruct-abliterated`
- `featherless/Llama-3-70B-Instruct-abliterated`
- `featherless/Nous-Hermes-2-Mixtral-8x7B-DPO`

**Tool Support**: Emulated (automatic XML-based tool calling)

**Setup**:
```bash
export FEATHERLESS_API_KEY="your-api-key-here"
```

**Example**:
```
/model featherless/Llama-3-8B-Instruct-abliterated
List files in the current directory using MCP tools
```

---

### 3. Google Gemini - ⚠️ NEEDS API KEY

**Status**: Configured but needs API key
**API Key**: Set `GOOGLE_API_KEY` environment variable
**Models**:
- `google/gemini-pro`
- `google/gemini-1.5-pro`
- `google/gemini-2.0-flash`

**Tool Support**: Native

**Setup**:
```bash
export GOOGLE_API_KEY="your-api-key-here"
```

Get API key: https://makersuite.google.com/app/apikey

**Example**:
```
/model google/gemini-pro
Summarize this codebase using MCP tools
```

---

### 4. Anthropic - ⚠️ NEEDS API KEY

**Status**: Configured but needs API key
**API Key**: Set `ANTHROPIC_API_KEY` environment variable
**Models**:
- `anthropic/claude-opus-4-5`
- `anthropic/claude-sonnet-4-5`
- `anthropic/claude-haiku-4-5`
- Or use without prefix (default)

**Tool Support**: Native

**Setup**:
```bash
export ANTHROPIC_API_KEY="your-anthropic-key"
```

**Example**:
```
/model anthropic/claude-opus-4-5
Use MCP tools to analyze this repository
```

---

## 🛠️ Tool Calling Emulation

### How It Works

For models without native tool calling (abliterated models), the proxy automatically:

1. **Injects tool definitions** into the system prompt as structured XML
2. **Teaches the model** to output tool calls in `<tool_call>` tags
3. **Parses responses** to extract tool calls
4. **Converts to Anthropic format** that Claude Code expects

### Example Flow

**Claude Code sends:**
```json
{
  "model": "featherless/Llama-3-8B-Instruct-abliterated",
  "messages": [...],
  "tools": [
    {
      "name": "read_file",
      "description": "Read a file from disk",
      "input_schema": {...}
    }
  ]
}
```

**Proxy transforms to:**
```json
{
  "model": "Llama-3-8B-Instruct-abliterated",
  "messages": [
    {
      "role": "system",
      "content": "You have access to tools. To use a tool:\n<tool_call>\n{\"name\": \"read_file\", \"arguments\": {...}}\n</tool_call>\n\n## Tool: read_file\nDescription: Read a file from disk\n..."
    },
    ...
  ]
}
```

**Model responds:**
```
I'll read the file for you.
<tool_call>
{"name": "read_file", "arguments": {"path": "README.md"}}
</tool_call>
```

**Proxy converts back:**
```json
{
  "content": [
    {"type": "text", "text": "I'll read the file for you."},
    {"type": "tool_use", "id": "call_123", "name": "read_file", "input": {"path": "README.md"}}
  ]
}
```

**Result**: Claude Code receives the tool call in its expected format!

---

## 🔧 Management Commands

### Wrapper Script

```bash
# Start Claude Code with proxy
~/.claude/scripts/claude-with-proxy.sh

# Stop proxy server
~/.claude/scripts/claude-with-proxy.sh stop

# Check proxy status
~/.claude/scripts/claude-with-proxy.sh status

# Show help
~/.claude/scripts/claude-with-proxy.sh help
```

### Manual Proxy Control

```bash
# Start proxy server directly
node ~/.claude/model-proxy-server.js 3000

# View proxy logs
tail -f ~/.claude/proxy.log

# Kill proxy server
pkill -f model-proxy-server.js
```

---

## 📝 Environment Variables

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Multi-Provider Proxy Configuration
export GLM_API_KEY="9a58c7331504f3cbaef3f2f95cb375b.BrfNpV8TbeF5tCaK"
export FEATHERLESS_API_KEY="your-featherless-key"
export GOOGLE_API_KEY="your-google-key"
export ANTHROPIC_API_KEY="your-anthropic-key"

# Optional: Change proxy port (default: 3000)
export CLAUDISH_PORT=3000

# Alias for easy startup
alias claude-proxy='~/.claude/scripts/claude-with-proxy.sh'
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

---

## 💡 Usage Examples

### Example 1: Switch Between Models

```bash
# Start with GLM
/model glm/glm-4
What's the capital of France?

# Switch to abliterated model
/model featherless/Llama-3-8B-Instruct-abliterated
Tell me about Paris without any content filtering

# Switch to Gemini
/model google/gemini-pro
Translate this to Spanish: "Hello, world!"

# Switch back to default Claude
/model claude-sonnet-4-5
Summarize our conversation
```

### Example 2: Tool Usage with Abliterated Model

```bash
/model featherless/Llama-3-8B-Instruct-abliterated

# All MCP tools work!
Read the file package.json and tell me what dependencies we have
```

Behind the scenes:
1. Claude Code sends tool definitions
2. Proxy injects them as XML in prompt
3. Model generates `<tool_call>` tags
4. Proxy parses and converts to tool_use
5. Claude Code executes the tool
6. Result sent back to model

### Example 3: Multi-Step Agent Task

```bash
/model glm/glm-4

Create a new React component:
1. Read the existing components to understand the pattern
2. Write a new Button component
3. Add TypeScript types
4. Update the index file
```

The agent will use multiple tools across several iterations, all working seamlessly through the proxy.

---

## 🔍 Troubleshooting

### Proxy Won't Start

**Check 1: Port already in use**
```bash
lsof -i :3000
# Kill the process using port 3000
kill -9 <PID>
```

**Check 2: Node.js installed**
```bash
node --version
# Should be >= 18.0.0
```

**Check 3: Proxy logs**
```bash
tail -50 ~/.claude/proxy.log
```

---

### API Key Issues

**Error: "Authentication error"**

Set the required environment variable:
```bash
export FEATHERLESS_API_KEY="your-key"
export GOOGLE_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"
```

Check if set:
```bash
echo $FEATHERLESS_API_KEY
```

---

### Tool Calling Not Working

**For abliterated models**: Tool emulation should be automatic

**Debug steps:**
1. Check proxy logs: `tail -f ~/.claude/proxy.log`
2. Look for `(tool emulation)` in the logs
3. Verify model outputs `<tool_call>` tags

**Manual test:**
```bash
curl -X POST http://127.0.0.1:3000/v1/messages \
  -H "Content-Type: application/json" \
  -d '{
    "model": "featherless/test-model",
    "messages": [{"role": "user", "content": "test"}],
    "tools": [{"name": "test_tool", "description": "Test", "input_schema": {}}]
  }'
```

---

### Model Not Found

**Error: Model doesn't exist**

Check model name format:
- ✅ `glm/glm-4`
- ✅ `featherless/Llama-3-8B-Instruct-abliterated`
- ❌ `glm-4` (missing provider prefix)
- ❌ `glm/` (missing model name)

List available models for each provider:
- **GLM**: https://open.bigmodel.cn/dev/api/normal-model/glm-4
- **Featherless**: https://featherless.ai/models
- **Google**: https://ai.google.dev/gemini-api/docs/models

---

## 🎯 Advanced Usage

### Custom Port

```bash
CLAUDISH_PORT=8080 ~/.claude/scripts/claude-with-proxy.sh
```

### Multiple Claude Sessions

You can run multiple Claude Code instances with the same proxy:

```bash
# Terminal 1
ANTHROPIC_BASE_URL=http://127.0.0.1:3000 claude

# Terminal 2 (same proxy)
ANTHROPIC_BASE_URL=http://127.0.0.1:3000 claude
```

### Proxy-Only Mode

Start just the proxy without Claude:

```bash
node ~/.claude/model-proxy-server.js 3000
```

Use with other tools that support `ANTHROPIC_BASE_URL`.

---

## 📊 Comparison

| Feature | GLM | Featherless | Google | Anthropic |
|---------|-----|-------------|--------|-----------|
| API Key | ✅ Set | ⚠️ Needed | ⚠️ Needed | ⚠️ Needed |
| Native Tools | ✅ Some | ❌ No | ✅ Yes | ✅ Yes |
| Tool Emulation | ✅ Auto | ✅ Auto | N/A | N/A |
| Streaming | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Abliterated | ❌ No | ✅ Yes | ❌ No | ❌ No |
| Cost | Low | Low | Medium | High |
| Speed | Fast | Fast | Fast | Medium |

---

## 🔐 Security Notes

1. **API Keys**: Stored in environment variables, never in code
2. **Local Proxy**: Runs only on 127.0.0.1 (localhost)
3. **No Data Storage**: Proxy doesn't store requests/responses
4. **Logs**: Contain no API keys, only request metadata

### Securing API Keys

```bash
# Add to ~/.zshrc with proper permissions
chmod 600 ~/.zshrc

# Or use a separate env file
echo 'export FEATHERLESS_API_KEY="key"' > ~/.claude/api-keys.env
chmod 600 ~/.claude/api-keys.env
source ~/.claude/api-keys.env
```

---

## 🚀 Next Steps

1. **Get API Keys**: Sign up for Featherless, Google, Anthropic
2. **Set Environment Variables**: Add keys to your shell config
3. **Test Each Provider**: Try switching between models
4. **Explore Models**: Find which models work best for your use case

---

## 📚 Additional Resources

- **GLM API Docs**: https://open.bigmodel.cn/dev/api
- **Featherless Models**: https://featherless.ai/models
- **Google AI Studio**: https://makersuite.google.com/
- **Anthropic API**: https://docs.anthropic.com/
- **Claude Code Docs**: https://github.com/anthropics/claude-code
- **Claudish Project**: https://github.com/MadAppGang/claudish

---

## 🎉 Summary

You now have:

✅ **Multi-provider support** - GLM, Featherless, Google, Anthropic
✅ **Tool calling emulation** - Works with abliterated models
✅ **Easy model switching** - Just use `/model provider/name`
✅ **Full Claude Code features** - All MCP tools work
✅ **Simple management** - Start/stop with wrapper script

**Start using it:**
```bash
~/.claude/scripts/claude-with-proxy.sh
/model glm/glm-4
Hello! Can you list files in the current directory?
```

Happy coding with multiple AI providers! 🚀

---

*Last updated: 2026-01-12*
*Proxy Server: ~/.claude/model-proxy-server.js*
*Wrapper Script: ~/.claude/scripts/claude-with-proxy.sh*
