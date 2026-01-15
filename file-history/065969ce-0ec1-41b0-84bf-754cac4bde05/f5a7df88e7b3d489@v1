# Integrating Gemini Web Miner with Roo Code

This guide shows how to integrate the Gemini Web Miner `/crawl` command into Roo Code (VS Code extension) using MCP servers.

---

## 🎯 What This Integration Does

After integration, you can use web scraping directly within Roo Code:

```
Use crawl to extract all product prices from https://example.com/products
```

The AI will automatically:
1. Scrape the website using Gemini AI
2. Extract the requested information
3. Return clean, structured data

---

## 📋 Prerequisites

### Option 1: Docker (Recommended)
```bash
# Verify Docker is installed
docker --version
```

### Option 2: Python with uv
```bash
# Install uv package manager
pip install uv
```

### Option 3: Node.js
```bash
# Verify Node.js is installed
node --version
npm --version
```

---

## 🚀 Quick Setup (Docker Method)

### Step 1: Access MCP Settings in Roo Code

1. Open VS Code with Roo Code extension
2. Click the Roo Code icon in the sidebar
3. Click the settings gear icon
4. Scroll to the bottom → **"MCP Settings"**
5. Click **"Edit Global MCP"** (for all projects) or **"Edit Project MCP"** (current project only)

### Step 2: Add Crawl4AI Configuration

Add this to your `mcp_settings.json` (global) or `.roo/mcp.json` (project):

```json
{
  "mcpServers": {
    "gemini-web-miner": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--volume",
        "/tmp/crawl4ai-crawls:/app/crawls",
        "uysalsadi/crawl4ai-mcp-server:latest"
      ],
      "env": {
        "CRAWL4AI_MCP_LOG": "INFO"
      },
      "alwaysAllow": ["crawl", "scrape"],
      "disabled": false
    }
  }
}
```

### Step 3: Enable and Start the Server

1. Save the configuration file
2. Return to Roo Code MCP settings
3. Ensure **"Enable MCP Servers"** is ON
4. Toggle the `gemini-web-miner` server to start it
5. Wait for "Connected" status

### Step 4: Test the Integration

In Roo Code chat, try:
```
Use crawl to get the main heading from https://example.com
```

---

## ⚙️ Alternative Setup Methods

### Option A: Python uv Runner

**Best for**: Direct Python integration without Docker

1. Clone the server:
```bash
git clone https://github.com/BjornMelin/crawl4ai-mcp-server.git ~/crawl4ai-mcp-server
```

2. Add to MCP configuration:
```json
{
  "mcpServers": {
    "gemini-web-miner": {
      "command": "uv",
      "args": [
        "--directory",
        "/Users/imorgado/crawl4ai-mcp-server",
        "run",
        "main.py"
      ],
      "alwaysAllow": ["crawl", "scrape"]
    }
  }
}
```

### Option B: Node.js with Running Crawl4AI Service

**Best for**: Node.js workflows with persistent service

1. Start Crawl4AI service:
```bash
# Start service on port 11235
cd ~/Desktop/Tools/crawl4ai-scripts
python3 -m crawl4ai.server --port 11235
```

2. Add to MCP configuration:
```json
{
  "mcpServers": {
    "gemini-web-miner": {
      "command": "npx",
      "args": ["mcp-crawl4ai-ts"],
      "env": {
        "CRAWL4AI_BASE_URL": "http://localhost:11235",
        "CRAWL4AI_API_KEY": "your-api-key",
        "SERVER_NAME": "gemini-web-miner",
        "SERVER_VERSION": "2.0.0"
      }
    }
  }
}
```

---

## 🔧 Configuration Options

### Basic Configuration

```json
{
  "mcpServers": {
    "gemini-web-miner": {
      "command": "docker",
      "args": ["run", "--rm", "-i", "uysalsadi/crawl4ai-mcp-server:latest"],
      "disabled": false
    }
  }
}
```

### Advanced Configuration

```json
{
  "mcpServers": {
    "gemini-web-miner": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--volume",
        "/tmp/crawl4ai-crawls:/app/crawls",
        "--memory",
        "2g",
        "--cpus",
        "2",
        "uysalsadi/crawl4ai-mcp-server:latest"
      ],
      "env": {
        "CRAWL4AI_MCP_LOG": "DEBUG",
        "GEMINI_API_KEY": "${env:GEMINI_API_KEY}"
      },
      "alwaysAllow": ["crawl", "scrape", "search"],
      "cwd": "/tmp/crawl4ai-crawls",
      "disabled": false
    }
  }
}
```

### Configuration Parameters Reference

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `command` | string | Executable to run | `"docker"`, `"npx"`, `"python"` |
| `args` | array | Command arguments | `["run", "--rm", "-i"]` |
| `env` | object | Environment variables | `{"LOG_LEVEL": "INFO"}` |
| `cwd` | string | Working directory | `"/tmp/crawls"` |
| `alwaysAllow` | array | Auto-approved tools | `["crawl", "scrape"]` |
| `disabled` | boolean | Disable server | `false` |

---

## 💡 Using Environment Variables

For sensitive data (API keys), use environment variable syntax:

```json
{
  "mcpServers": {
    "gemini-web-miner": {
      "command": "docker",
      "args": ["..."],
      "env": {
        "GEMINI_API_KEY": "${env:GEMINI_API_KEY}",
        "CRAWL4AI_API_KEY": "${env:CRAWL4AI_API_KEY}"
      }
    }
  }
}
```

Then set in your shell:
```bash
# Add to ~/.zshrc or ~/.bashrc
export GEMINI_API_KEY="AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"
export CRAWL4AI_API_KEY="your-crawl4ai-key"
```

---

## 🎯 Usage Examples in Roo Code

### Basic Scraping
```
Use crawl to extract the main content from https://example.com
```

### Structured Data Extraction
```
Use crawl to get all product names, prices, and ratings from https://shop.example.com
```

### Deep Crawling
```
Use crawl with depth 2 to extract all documentation pages from https://docs.example.com
```

### With Authentication (if supported)
```
Use crawl with authentication to extract dashboard data from https://app.example.com
Login: user@example.com
Password: (will prompt securely)
```

---

## 🔍 Available Tools

After configuration, these tools are available in Roo Code:

| Tool | Description | Example |
|------|-------------|---------|
| `crawl` | Crawl websites with depth control | `crawl https://example.com --depth 2` |
| `scrape` | Single-page scraping | `scrape https://example.com` |
| `search` | Search crawled content | `search "pricing" in crawled data` |
| `extract` | Extract structured data | `extract products from https://shop.example.com` |

---

## 🐛 Troubleshooting

### Server Won't Start

**Issue**: Server shows "disconnected" or errors

**Solutions**:
1. Check Docker is running: `docker ps`
2. Verify configuration JSON syntax is valid
3. Check logs in MCP panel for error messages
4. Ensure port is not in use: `lsof -i :11235`

### Permission Denied Errors

**Issue**: Docker volume mount permission errors

**Solution**: Use absolute paths and ensure directory exists:
```bash
mkdir -p /tmp/crawl4ai-crawls
chmod 755 /tmp/crawl4ai-crawls
```

### Tools Not Appearing

**Issue**: Crawl tools not showing in Roo Code

**Solutions**:
1. Reload VS Code window: `Cmd+Shift+P` → "Reload Window"
2. Check server status is "Connected"
3. Verify `alwaysAllow` includes tool names
4. Check MCP is enabled in settings

### Rate Limit Errors

**Issue**: Gemini API rate limits

**Solution**: See [GEMINI_INTEGRATION_SUMMARY.md](./GEMINI_INTEGRATION_SUMMARY.md) for rate limit handling

---

## 📂 Project-Level vs Global Configuration

### Global Configuration
**File**: Access via "Edit Global MCP" in Roo Code settings
**Scope**: All VS Code workspaces
**Use when**: You want crawl available everywhere

### Project-Level Configuration
**File**: `.roo/mcp.json` in project root
**Scope**: Current workspace only
**Use when**: Project-specific crawl settings

**Priority**: Project-level overrides global settings

---

## 🔐 Security Best Practices

### 1. Never Commit API Keys
Add to `.gitignore`:
```
.roo/mcp.json
mcp_settings.json
*.env
```

### 2. Use Environment Variables
```json
{
  "env": {
    "API_KEY": "${env:API_KEY}"
  }
}
```

### 3. Limit Tool Permissions
Only add necessary tools to `alwaysAllow`:
```json
{
  "alwaysAllow": ["crawl"]  // Not ["crawl", "scrape", "delete"]
}
```

### 4. Use Docker Isolation
Docker containers provide isolation and security boundaries.

---

## 🚀 Advanced Features

### Custom Crawl Configurations

Create project-specific `.roo/mcp.json`:

```json
{
  "mcpServers": {
    "gemini-web-miner": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--volume",
        "${workspaceFolder}/crawls:/app/crawls",
        "uysalsadi/crawl4ai-mcp-server:latest"
      ],
      "env": {
        "CRAWL4AI_MCP_LOG": "DEBUG",
        "GEMINI_MODEL": "gemini-2.0-flash-exp",
        "MAX_DEPTH": "3"
      },
      "alwaysAllow": ["crawl", "scrape"]
    }
  }
}
```

### Multiple MCP Servers

Combine crawl with other MCP servers:

```json
{
  "mcpServers": {
    "gemini-web-miner": {
      "command": "docker",
      "args": ["run", "--rm", "-i", "uysalsadi/crawl4ai-mcp-server:latest"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "cognee": {
      "type": "sse",
      "url": "http://localhost:8000/sse"
    }
  }
}
```

---

## 📚 Resources

### Documentation
- **Roo Code MCP Guide**: https://docs.roocode.com/features/mcp/using-mcp-in-roo
- **MCP Server Transports**: https://docs.roocode.com/features/mcp/server-transports
- **Gemini Web Miner**: [FINAL_SUMMARY.md](./FINAL_SUMMARY.md)

### Repositories
- **Crawl4AI MCP (Docker)**: https://github.com/sadiuysal/crawl4ai-mcp-server
- **Crawl4AI MCP (Python)**: https://github.com/BjornMelin/crawl4ai-mcp-server
- **Crawl4AI MCP (Node)**: https://github.com/coleam00/mcp-crawl4ai-rag

### Support
- Roo Code Issues: https://github.com/RooCodeInc/Roo-Code/issues
- Crawl4AI Issues: https://github.com/unclecode/crawl4ai/issues

---

## ✅ Verification Checklist

After setup, verify:

- [ ] Docker is running (if using Docker method)
- [ ] MCP configuration file is valid JSON
- [ ] Server shows "Connected" in Roo Code MCP panel
- [ ] Tools appear in Roo Code tool list
- [ ] Test crawl works: `Use crawl to get https://example.com`
- [ ] API keys are set via environment variables (not hardcoded)
- [ ] Logs show successful connections

---

**Integration Complete!** 🎉

You can now use natural language web scraping directly in Roo Code powered by Gemini AI.

---

## Sources

- [Using MCP in Roo Code | Roo Code Documentation](https://docs.roocode.com/features/mcp/using-mcp-in-roo)
- [Recommended MCP Servers | Roo Code Documentation](https://docs.roocode.com/features/mcp/recommended-mcp-servers)
- [How to Use MCP Servers with Roo Code](https://apidog.com/blog/mcp-server-roo-code/)
- [Crawl4AI MCP Server Guide](https://onedollarvps.com/blogs/how-to-set-up-and-use-crawl4ai-mcp)

**Last Updated**: 2026-01-12
**Integration Version**: 2.0.0
