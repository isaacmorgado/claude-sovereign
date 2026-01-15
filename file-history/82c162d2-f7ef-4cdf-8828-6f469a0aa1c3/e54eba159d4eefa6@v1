# clauded - Quick Start Guide

## What is `clauded`?

`clauded` is your shortcut to start Claude Code with multi-provider support.

Instead of typing:
```bash
~/.claude/scripts/claude-with-proxy-fixed.sh
```

Just type:
```bash
clauded
```

---

## 🚀 Commands

```bash
clauded          # Start Claude with proxy (GLM, Featherless, Google, Anthropic)
clauded-stop     # Stop the proxy server
clauded-status   # Check if proxy is running
```

---

## 💡 Quick Examples

### Example 1: Start and Use GLM

```bash
# Terminal
clauded

# Inside Claude Code
/model glm/glm-4
What is quantum computing?
```

### Example 2: Use Featherless (Abliterated)

```bash
# Terminal
clauded

# Inside Claude Code
/model featherless/Llama-3-8B-Instruct-abliterated
Tell me about neural networks without restrictions
```

### Example 3: Use Tools with Any Model

```bash
# Terminal
clauded

# Inside Claude Code
/model glm/glm-4
List all JavaScript files in this directory
Read package.json and summarize dependencies
```

---

## 🎯 Available Models

**GLM (ZhipuAI) - Already Configured ✅**
```
/model glm/glm-4           # Most capable
/model glm/glm-4-flash     # Fastest
/model glm/glm-4-air       # Balanced
```

**Featherless (Abliterated) - Already Configured ✅**
```
/model featherless/Llama-3-8B-Instruct-abliterated
/model featherless/Llama-3-70B-Instruct-abliterated
```

**Google Gemini - Set GOOGLE_API_KEY**
```
/model google/gemini-pro
/model google/gemini-2.0-flash
```

**Anthropic - Set ANTHROPIC_API_KEY or use regular claude**
```
/model claude-sonnet-4-5
/model claude-opus-4-5
```

---

## 🔧 Management

### Check Status
```bash
clauded-status
```

### Stop Proxy
```bash
clauded-stop
```

### View Logs
```bash
tail -f ~/.claude/proxy.log
```

---

## 🎉 Features

✅ **Multi-provider support** - Switch between 4+ AI providers
✅ **Tool calling works everywhere** - Even abliterated models
✅ **No authentication hassles** - Uses placeholder key (claudish approach)
✅ **Easy to use** - Just type `clauded`
✅ **All Claude Code features** - MCP tools, agents, everything works

---

## 💡 Pro Tips

### Tip 1: Quick Model Switch

```bash
# Start with default
clauded

# Switch anytime
/model glm/glm-4
/model featherless/model-name
/model google/gemini-pro
```

### Tip 2: Use with Anthropic

If you want Anthropic models through the proxy:

```bash
export ANTHROPIC_API_KEY="sk-ant-your-key"
clauded
/model claude-sonnet-4-5
```

Or just use regular Claude for Anthropic:
```bash
claude  # Normal Claude (not clauded)
```

### Tip 3: Check What's Running

```bash
clauded-status
```

Shows:
- ✓ If proxy is running
- Port number
- Which providers are configured

---

## 🆘 Troubleshooting

**Problem**: `clauded: command not found`

**Solution**: Reload shell config
```bash
source ~/.zshrc
```

---

**Problem**: Proxy won't start

**Solution**: Check if port is in use
```bash
lsof -i :3000
kill -9 <PID>
clauded
```

---

**Problem**: Model not working

**Solution**: Check model name format
```bash
# ✅ Correct
/model glm/glm-4
/model featherless/Llama-3-8B-Instruct-abliterated

# ❌ Wrong
/model glm-4  # Missing provider prefix
```

---

## 📚 More Help

```bash
# Full documentation
cat ~/.claude/MULTI_PROVIDER_GUIDE.md

# Authentication setup
cat ~/.claude/AUTH_SETUP.md

# Complete setup summary
cat ~/.claude/SETUP_COMPLETE.md
```

---

## ✨ Summary

1. **Start**: `clauded`
2. **Switch models**: `/model glm/glm-4`
3. **Use tools**: Works automatically
4. **Stop**: `clauded-stop` or Ctrl+C

**That's it!** 🚀

---

*Your shortcut to multi-provider AI*
