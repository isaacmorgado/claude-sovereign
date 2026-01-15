# GLM Integration Guide for Claude Code

## Overview

This guide explains how to use GLM (ZhipuAI) models with Claude Code through the MCP (Model Context Protocol) server integration.

Your GLM API key has been successfully configured and is ready to use!

---

## ✅ What's Been Installed

### 1. **GLM MCP Server** (`~/.claude/glm-proxy-server.js`)
   - Standalone Node.js server that bridges GLM API with Claude Code
   - Supports all GLM models: glm-4, glm-4-air, glm-4-airx, glm-4-flash, glm-3-turbo
   - Automatically handles authentication with your API key

### 2. **MCP Configuration** (`~/.claude/mcp_servers.json`)
   - GLM server is registered and **ENABLED** by default
   - API key: `9a58c7331504f3cbaef3f2f95cb375b.BrfNpV8TbeF5tCaK`
   - Ready to use after Claude Code restart

### 3. **Helper Script** (`~/.claude/scripts/glm-helper.sh`)
   - Status checking
   - Server testing
   - Enable/disable GLM server
   - List available models

---

## 🚀 Quick Start

### Step 1: Restart Claude Code

**Important:** You must restart Claude Code for the MCP server to load:

```bash
# If Claude Code is running in terminal, press Ctrl+C to exit
# Then restart it
claude
```

### Step 2: Verify GLM is Available

Once Claude Code starts, the GLM MCP server will automatically load. You'll see MCP servers initializing in the startup logs.

### Step 3: Use GLM in Your Prompts

Simply mention GLM in your prompts to Claude Code:

```
Example prompts:
- "Use glm_chat to explain quantum computing"
- "Call the glm_chat tool with model glm-4 to write a Python function"
- "Use GLM to summarize this article: [paste article]"
- "List available GLM models using glm_list_models"
```

---

## 📋 Available GLM Models

| Model | Description | Context | Best For |
|-------|-------------|---------|----------|
| **glm-4** | Most capable model | 128K | Complex reasoning, detailed analysis |
| **glm-4-air** | Faster, cost-effective | 128K | General use, balanced performance |
| **glm-4-airx** | Ultra-fast inference | 8K | Quick responses, simple tasks |
| **glm-4-flash** | Fastest response | 128K | Speed-critical applications |
| **glm-3-turbo** | Legacy model | 128K | Backward compatibility |

**Recommendations:**
- 🏆 **General use**: `glm-4` (most capable)
- ⚡ **Speed**: `glm-4-flash` (fastest)
- ⚖️ **Balance**: `glm-4-air` (cost-effective)

---

## 🛠️ MCP Tools Available

### 1. `glm_chat`
Chat with any GLM model.

**Parameters:**
- `prompt` (required): Your question or request
- `model` (optional): GLM model to use (default: `glm-4`)
- `temperature` (optional): Sampling temperature 0-1 (default: `0.7`)
- `max_tokens` (optional): Maximum tokens to generate (default: `2048`)

**Example:**
```
"Use glm_chat with model glm-4 and prompt 'Explain quantum entanglement' and temperature 0.3"
```

### 2. `glm_list_models`
List all available GLM models with descriptions.

**Example:**
```
"Show me available GLM models using glm_list_models"
```

---

## 🔧 Management Commands

### Check Status
```bash
~/.claude/scripts/glm-helper.sh status
```

**Output:**
```
=== GLM Integration Status ===

✓ GLM proxy server found
✓ Server is executable
✓ MCP configuration found
✓ GLM server is configured in MCP
✓ GLM server is ENABLED
✓ API key is configured

All checks passed!
```

### Test Server
```bash
~/.claude/scripts/glm-helper.sh test
```

### List Models
```bash
~/.claude/scripts/glm-helper.sh models
```

### Enable/Disable Server
```bash
# Disable GLM server
~/.claude/scripts/glm-helper.sh disable

# Enable GLM server
~/.claude/scripts/glm-helper.sh enable

# Note: Restart Claude Code after enable/disable
```

---

## 💡 Usage Examples

### Example 1: Simple Question
```
Prompt: "Use glm_chat to explain what a neural network is"

Claude Code will:
1. Call glm_chat tool with default glm-4 model
2. Send your prompt to GLM API
3. Return GLM's response
```

### Example 2: Specify Model
```
Prompt: "Use glm_chat with model glm-4-flash to write a haiku about AI"

Result: Uses the fastest GLM model for quick response
```

### Example 3: Control Parameters
```
Prompt: "Use glm_chat with:
- model: glm-4
- prompt: 'Write a creative story about time travel'
- temperature: 0.9
- max_tokens: 1000"

Result: Creative output with higher randomness
```

### Example 4: List Models
```
Prompt: "What GLM models are available? Use glm_list_models"

Result: Shows all available models with descriptions
```

---

## 🔍 Troubleshooting

### GLM Server Not Loading

**Check 1: Verify Configuration**
```bash
~/.claude/scripts/glm-helper.sh status
```

**Check 2: Restart Claude Code**
```bash
# Exit Claude Code (Ctrl+C)
# Restart
claude
```

**Check 3: Check MCP Server Logs**
Claude Code logs MCP server output. Look for GLM-related messages in the startup logs.

### API Key Issues

**Error: "Invalid API key"**

1. Verify your API key in `~/.claude/mcp_servers.json`:
   ```bash
   cat ~/.claude/mcp_servers.json | grep -A 5 '"glm"'
   ```

2. Update if needed:
   ```bash
   # Edit the file
   nano ~/.claude/mcp_servers.json

   # Find the glm section and update GLM_API_KEY
   ```

### Server Not Responding

**Test server independently:**
```bash
~/.claude/scripts/glm-helper.sh test
```

**Check server is executable:**
```bash
ls -l ~/.claude/glm-proxy-server.js
# Should show: -rwxr-xr-x (executable)
```

**Make executable if needed:**
```bash
chmod +x ~/.claude/glm-proxy-server.js
```

---

## 🎯 Advanced Usage

### Custom API Endpoint

If you need to use a different GLM API endpoint, edit the server:

```bash
nano ~/.claude/glm-proxy-server.js

# Change this line:
const GLM_BASE_URL = 'https://open.bigmodel.cn/api/paas/v4';

# To your custom endpoint:
const GLM_BASE_URL = 'https://your-custom-endpoint.com/v4';
```

### Using Environment Variables

Alternative to hardcoding the API key, set it as an environment variable:

```bash
# Add to your ~/.zshrc or ~/.bashrc
export GLM_API_KEY="your-api-key-here"

# Update mcp_servers.json to use the env var
# Change: "GLM_API_KEY": "hardcoded-key"
# To:     "GLM_API_KEY": "${GLM_API_KEY}"
```

### Disable GLM Temporarily

```bash
# Disable without removing configuration
~/.claude/scripts/glm-helper.sh disable

# Restart Claude Code
```

---

## 📚 Integration with Claude Code Features

### Using with Agents

```
"Create an agent that:
1. Uses glm_chat to generate code
2. Validates the code
3. Saves it to a file"
```

### Using with Context

```
"Given this codebase context, use glm_chat to:
1. Analyze the architecture
2. Suggest improvements
3. Generate documentation"
```

### Using with Tools

```
"Use glm_chat along with other MCP tools:
1. Fetch data with fetch tool
2. Process with GLM
3. Store in memory tool"
```

---

## 🔐 Security Notes

1. **API Key Storage**: Your API key is stored in `~/.claude/mcp_servers.json`
   - Make sure this file has restricted permissions:
     ```bash
     chmod 600 ~/.claude/mcp_servers.json
     ```

2. **Network Security**: The GLM server communicates with:
   - `https://open.bigmodel.cn` (official GLM API)
   - Uses HTTPS for all communications

3. **Local Server**: The MCP server runs locally on your machine
   - No data is sent to third parties except GLM API
   - All communication is logged by Claude Code

---

## 📞 Support

### Helper Script Commands
```bash
# Full help
~/.claude/scripts/glm-helper.sh help

# Available commands:
- status   # Check integration status
- test     # Test server functionality
- enable   # Enable GLM server
- disable  # Disable GLM server
- models   # List available models
- help     # Show usage information
```

### Files to Check
- Server: `~/.claude/glm-proxy-server.js`
- Config: `~/.claude/mcp_servers.json`
- Helper: `~/.claude/scripts/glm-helper.sh`
- This Guide: `~/.claude/GLM_INTEGRATION_GUIDE.md`

---

## 🎉 You're All Set!

Your GLM integration is ready to use. Simply:

1. **Restart Claude Code** if it's already running
2. **Use GLM in your prompts**: "Use glm_chat to..."
3. **Check status anytime**: `~/.claude/scripts/glm-helper.sh status`

**Example prompt to try first:**
```
"Use glm_chat to tell me a fun fact about artificial intelligence"
```

Happy coding with GLM! 🚀

---

*Last updated: 2026-01-12*
*API Key: 9a58c7331504f3cbaef3f2f95cb375b.BrfNpV8TbeF5tCaK*
