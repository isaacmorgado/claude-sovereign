# GLM Quick Reference Card

## 🚀 Quick Start
```bash
# 1. Restart Claude Code
claude

# 2. Use GLM in prompts
"Use glm_chat to explain quantum computing"
```

## 📋 Models

| Model | Use Case |
|-------|----------|
| `glm-4` | 🏆 Most capable (default) |
| `glm-4-flash` | ⚡ Fastest |
| `glm-4-air` | ⚖️ Balanced |
| `glm-4-airx` | 🚄 Ultra-fast (8K) |
| `glm-3-turbo` | 📦 Legacy |

## 🛠️ MCP Tools

### glm_chat
```
"Use glm_chat with model glm-4 to [your task]"

Parameters:
- prompt (required)
- model (optional, default: glm-4)
- temperature (optional, 0-1, default: 0.7)
- max_tokens (optional, default: 2048)
```

### glm_list_models
```
"List GLM models using glm_list_models"
```

## 🔧 Management

```bash
# Check status
~/.claude/scripts/glm-helper.sh status

# List models
~/.claude/scripts/glm-helper.sh models

# Enable/disable
~/.claude/scripts/glm-helper.sh enable
~/.claude/scripts/glm-helper.sh disable

# Test server
~/.claude/scripts/glm-helper.sh test
```

## 💡 Example Prompts

```
1. "Use glm_chat to explain neural networks"

2. "Use glm_chat with model glm-4-flash to write a haiku"

3. "Use glm_chat with temperature 0.9 to write a creative story"

4. "List available GLM models"
```

## 📁 Important Files

- Server: `~/.claude/glm-proxy-server.js`
- Config: `~/.claude/mcp_servers.json`
- Helper: `~/.claude/scripts/glm-helper.sh`
- Full Guide: `~/.claude/GLM_INTEGRATION_GUIDE.md`

## ⚡ One-Liner

```bash
# Check everything is working
~/.claude/scripts/glm-helper.sh status && echo "✅ GLM Ready!"
```

---

**API Key:** `9a58c7331504f3cbaef3f2f95cb375b.BrfNpV8TbeF5tCaK`
**Endpoint:** `https://open.bigmodel.cn/api/paas/v4`
