# Why Custom Models Don't Appear in /model Picker

## The Problem

Claude Code's `/model` command picker is **hardcoded in the CLI binary**. It only shows Anthropic's native models:
- Opus 4.5
- Sonnet 4.5
- Haiku 4.5

**We cannot modify this picker** because:
1. It's compiled into the executable
2. It doesn't fetch from `/v1/models` API endpoint
3. No configuration file controls it

## The Solution

Custom models (GLM, Featherless, Google) **must be typed manually**:

```bash
/model glm/glm-4
/model featherless/Llama-3-8B-Instruct-abliterated
/model google/gemini-pro
```

## Workarounds

### 1. Quick Reference (ALREADY IMPLEMENTED ✅)

Your `clauded` startup script shows all available models:

```
Available Models:
  /model glm/glm-4                              - GLM (free)
  /model featherless/Llama-3-8B-Instruct-abliterated
  /model google/gemini-pro                      - Google
```

**Just copy and paste the command!**

### 2. Custom /models Command (NEW)

I created a custom command. Inside Claude, type:

```
/models
```

This shows a formatted list with copy-paste commands.

**Note:** This requires Claude Code hooks support (may not work in all versions).

### 3. Set Default Model

Edit `~/.claude/settings.json`:

```json
{
  "model": "glm/glm-4"
}
```

Then `clauded` will start with GLM by default.

### 4. Shell Aliases

Add to `~/.zshrc`:

```bash
# Quick model switchers
alias claude-glm='clauded && echo "/model glm/glm-4"'
alias claude-uncensored='clauded && echo "/model featherless/Llama-3-8B-Instruct-abliterated"'
```

### 5. Create Model Switcher Script

```bash
#!/bin/bash
# ~/.claude/scripts/pick-model.sh

echo "Pick a model:"
echo "1) GLM-4 (free)"
echo "2) Featherless Llama 3 8B (uncensored)"
echo "3) Google Gemini Pro"
read -p "Choice: " choice

case $choice in
  1) echo "/model glm/glm-4" ;;
  2) echo "/model featherless/Llama-3-8B-Instruct-abliterated" ;;
  3) echo "/model google/gemini-pro" ;;
esac
```

Then in Claude, paste the output.

## Why This Limitation Exists

Claude Code is **closed-source** and the model picker is:
1. Compiled into the binary
2. Designed for Anthropic models only
3. Not configurable without modifying source

The proxy **works perfectly** - it just can't inject into the UI picker.

## Best Workflow

1. Start clauded: `clauded`
2. Look at the startup message showing available models
3. Copy the `/model` command you want
4. Paste into Claude

Or just memorize your favorites:
- `/model glm/glm-4` (free, fast)
- `/model featherless/Llama-3-8B-Instruct-abliterated` (uncensored)

## Summary

✅ **What works:**
- Proxy routes models correctly
- Tool calling works everywhere
- Model switching works via manual commands
- Startup script shows available models

❌ **What doesn't work:**
- Custom models in built-in `/model` picker
- This is a limitation of Claude Code CLI itself

💡 **Workaround:**
- Type model names manually
- Use startup message as reference
- Set default in settings.json
- Create shell aliases for quick switching

The proxy is working perfectly - the only limitation is the hardcoded UI picker!
