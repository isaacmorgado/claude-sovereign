# Multi-Provider Claude Code - Quick Start

## 🚀 Start in 30 Seconds

```bash
# 1. Start Claude Code with proxy
~/.claude/scripts/claude-with-proxy.sh

# 2. Switch models inside Claude
/model glm/glm-4
/model featherless/Llama-3-8B-Instruct-abliterated
/model google/gemini-pro
/model anthropic/claude-opus-4-5

# 3. Use tools normally - they work with ALL models!
Can you read package.json and list dependencies?
```

---

## 📋 Supported Providers

| Provider | Prefix | Status | Tool Support |
|----------|--------|--------|--------------|
| **GLM** | `glm/` | ✅ Ready | Native + Emulated |
| **Featherless** | `featherless/` | ⚠️ Need Key | ✅ Emulated |
| **Google** | `google/` | ⚠️ Need Key | ✅ Native |
| **Anthropic** | `anthropic/` | ⚠️ Need Key | ✅ Native |

---

## ⚙️ Setup API Keys (Optional)

Add to `~/.zshrc`:

```bash
export FEATHERLESS_API_KEY="your-key"
export GOOGLE_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"

# Quick launch alias
alias claude-proxy='~/.claude/scripts/claude-with-proxy.sh'
```

Then: `source ~/.zshrc`

---

## 🎯 Popular Models

**GLM (Free - Already Configured)**
- `glm/glm-4` - Most capable, 128K context
- `glm/glm-4-flash` - Fastest response

**Featherless (Need API Key)**
- `featherless/Llama-3-8B-Instruct-abliterated`
- `featherless/Llama-3-70B-Instruct-abliterated`

**Google (Need API Key)**
- `google/gemini-pro`
- `google/gemini-2.0-flash`

**Anthropic (Need API Key)**
- `anthropic/claude-opus-4-5`
- `anthropic/claude-sonnet-4-5`

---

## 💡 Example Session

```bash
# Start
~/.claude/scripts/claude-with-proxy.sh

# Try GLM (free)
/model glm/glm-4
Write a Python function to calculate fibonacci

# Try abliterated model (after setting FEATHERLESS_API_KEY)
/model featherless/Llama-3-8B-Instruct-abliterated
Tell me about quantum computing without restrictions

# Use tools
/model glm/glm-4
List all JavaScript files in src/ using MCP tools
```

---

## 🔧 Commands

```bash
# Start
~/.claude/scripts/claude-with-proxy.sh

# Stop proxy
~/.claude/scripts/claude-with-proxy.sh stop

# Check status
~/.claude/scripts/claude-with-proxy.sh status

# View logs
tail -f ~/.claude/proxy.log
```

---

## ❓ Troubleshooting

**Proxy won't start**
```bash
# Check if port 3000 is in use
lsof -i :3000

# Use different port
CLAUDISH_PORT=8080 ~/.claude/scripts/claude-with-proxy.sh
```

**API key error**
```bash
# Verify key is set
echo $FEATHERLESS_API_KEY

# Set it
export FEATHERLESS_API_KEY="your-key"
```

**Tools not working**
- Check proxy logs: `tail -f ~/.claude/proxy.log`
- Look for `(tool emulation)` confirmation
- Try different model

---

## 📚 Full Documentation

- **Complete Guide**: `~/.claude/MULTI_PROVIDER_GUIDE.md`
- **GLM Guide**: `~/.claude/GLM_INTEGRATION_GUIDE.md`
- **Proxy Server**: `~/.claude/model-proxy-server.js`
- **Wrapper Script**: `~/.claude/scripts/claude-with-proxy.sh`

---

## 🎉 Key Features

✅ **4 AI Providers** in one CLI
✅ **Tool calling works everywhere** (even abliterated models)
✅ **Instant model switching** with `/model`
✅ **All Claude Code features** preserved
✅ **Easy management** with wrapper script

Get started now:
```bash
~/.claude/scripts/claude-with-proxy.sh
```
