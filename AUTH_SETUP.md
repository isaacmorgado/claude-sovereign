# Setting Up Authentication for Multi-Provider Proxy

## The Issue

When using the proxy (`ANTHROPIC_BASE_URL=http://localhost:3000`), Claude Code's built-in authentication doesn't pass through. You need to set your Anthropic API key explicitly.

---

## ✅ Solution: Set Your API Key

### Option 1: Permanent Setup (Recommended)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
```

Then reload:

```bash
source ~/.zshrc  # or ~/.bashrc
```

---

### Option 2: Session-Only

Set for current session:

```bash
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
~/.claude/scripts/claude-with-proxy-v2.sh
```

---

### Option 3: Use Proxy Only for Other Models

**Start Claude Code normally** (without proxy) for Anthropic:

```bash
claude
```

**When you want GLM/Featherless**, restart with proxy:

```bash
# Stop Claude Code (Ctrl+C)
# Start with proxy and switch models
ANTHROPIC_BASE_URL=http://127.0.0.1:3000 claude
/model glm/glm-4
```

---

## 🔑 Get Your Anthropic API Key

1. Visit: https://console.anthropic.com/settings/keys
2. Create a new key
3. Copy it (starts with `sk-ant-`)
4. Add to your environment

---

## 🚀 Updated Startup Script

I created a new version that checks for authentication:

```bash
~/.claude/scripts/claude-with-proxy-v2.sh
```

This script:
- ✅ Checks if ANTHROPIC_API_KEY is set
- ✅ Shows helpful message if missing
- ✅ Lets you continue without it (GLM/Featherless still work)
- ✅ Gives you options to fix it

---

## 📊 Provider Authentication Status

| Provider | Auth Required | Where to Get Key |
|----------|---------------|------------------|
| **GLM** | ✅ Already set | (using your key) |
| **Featherless** | ✅ Already set | (using your key) |
| **Google** | ⚠️ Need key | https://makersuite.google.com/app/apikey |
| **Anthropic** | ⚠️ Need key | https://console.anthropic.com/settings/keys |

---

## 🎯 Quick Fix

If you just want to test GLM/Featherless without Anthropic:

```bash
# Use the v2 script - it will warn but continue
~/.claude/scripts/claude-with-proxy-v2.sh

# Then switch to non-Anthropic models
/model glm/glm-4
Hello! (uses GLM, no Anthropic key needed)
```

---

## 💡 Why This Happens

Claude Code has two authentication modes:

1. **Direct to Anthropic** (normal `claude` command)
   - Uses Claude Code's built-in auth
   - No ANTHROPIC_API_KEY needed

2. **Through Proxy** (with `ANTHROPIC_BASE_URL`)
   - Proxy intercepts requests
   - Built-in auth doesn't pass through
   - Need explicit ANTHROPIC_API_KEY

This is a limitation of how HTTP proxies work - they need explicit credentials.

---

## ✅ Verification

After setting your API key, verify:

```bash
# Check it's set
echo $ANTHROPIC_API_KEY

# Test with v2 script
~/.claude/scripts/claude-with-proxy-v2.sh status

# Should show:
# ✓ Proxy server is running
# Anthropic auth: ✓ Configured
```

---

## 🆘 Troubleshooting

**Problem**: "ANTHROPIC_API_KEY not set"

**Solution**:
```bash
export ANTHROPIC_API_KEY="your-key-here"
```

**Problem**: Key not persisting

**Solution**: Add to `~/.zshrc`:
```bash
echo 'export ANTHROPIC_API_KEY="your-key"' >> ~/.zshrc
source ~/.zshrc
```

**Problem**: Don't want to set it

**Solution**: Use normal Claude Code for Anthropic, proxy only for others:
```bash
# Without proxy
claude

# With proxy (when you need GLM/Featherless)
# (start fresh session)
```

---

## 🎉 Once Set Up

After adding ANTHROPIC_API_KEY:

```bash
# Start with all providers working
~/.claude/scripts/claude-with-proxy-v2.sh

# Use any model
/model claude-sonnet-4-5    # Your Anthropic key
/model glm/glm-4             # GLM key (already set)
/model featherless/model     # Featherless key (already set)
```

All models + tools work! 🚀
