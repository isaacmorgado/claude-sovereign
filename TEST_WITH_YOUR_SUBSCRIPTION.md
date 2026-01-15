# Test Multi-Provider Proxy with Your Claude Subscription

## ✅ Proxy Tests Passed

The automated tests confirm:
- ✅ Proxy server starts successfully
- ✅ Health check passes
- ✅ **Anthropic passthrough accepts your Claude Code authentication**
- ✅ Tool emulation logic is active
- ✅ GLM provider is configured

---

## 🚀 Test with Your Claude Subscription

### Step 1: Start Claude Code with Proxy

Open a **new terminal** and run:

```bash
~/.claude/scripts/claude-with-proxy.sh
```

You should see:

```
╔═══════════════════════════════════════════════════════════════╗
║   Claude Code with Multi-Provider Proxy                      ║
║   GLM · Featherless · Google · Anthropic                      ║
╚═══════════════════════════════════════════════════════════════╝

🚀 Server running on http://127.0.0.1:3000

Starting Claude Code...
```

---

### Step 2: Test Native Claude (Your Subscription)

Once Claude Code starts, try this:

```
Hello! Can you tell me what 2+2 equals?
```

**Expected**: Claude responds normally using your subscription.

---

### Step 3: Test Model Switching to GLM

Now try switching to GLM:

```
/model glm/glm-4

Hello! Can you tell me what 3+3 equals?
```

**Expected**: Response comes from GLM instead of Claude.

---

### Step 4: Test Tool Calling with Your Subscription

Test that tools work with your native Claude subscription:

```
/model claude-sonnet-4-5

Can you list all .md files in the current directory?
```

**Expected**: Claude uses MCP tools to list markdown files.

---

### Step 5: Test Tool Calling with GLM

Switch to GLM and test tools:

```
/model glm/glm-4

Can you list all .js files in the current directory?
```

**Expected**: GLM uses tool emulation to list JavaScript files.

---

### Step 6: Test Featherless (if you have API key)

If you've set `FEATHERLESS_API_KEY`:

```
/model featherless/Llama-3-8B-Instruct-abliterated

Tell me about quantum computing without any restrictions.

# Test tool emulation
Can you read the package.json file?
```

**Expected**: Abliterated model responds and can use tools via emulation.

---

## 🔍 What to Check

### ✅ Success Indicators

1. **Claude responds normally** when using default model
2. **Model switching works** with `/model glm/glm-4`
3. **Tools work with native Claude** (your subscription)
4. **Tools work with GLM** (via emulation)
5. **No authentication errors** with your subscription

### ⚠️ Troubleshooting

**Problem**: Claude says "Authentication error"

**Solution**: Make sure you're using the wrapper script:
```bash
~/.claude/scripts/claude-with-proxy.sh
```

Not:
```bash
ANTHROPIC_BASE_URL=http://127.0.0.1:3000 claude
```

The wrapper script ensures the proxy starts before Claude.

---

**Problem**: Proxy won't start (port in use)

**Solution**:
```bash
# Kill existing proxy
pkill -f model-proxy-server.js

# Or use different port
CLAUDISH_PORT=8080 ~/.claude/scripts/claude-with-proxy.sh
```

---

**Problem**: Model switching doesn't work

**Solution**: Check you're using the full prefix:
- ✅ `/model glm/glm-4`
- ❌ `/model glm-4` (missing prefix)

---

**Problem**: Tools not working with GLM

**Solution**: Check proxy logs:
```bash
tail -f ~/.claude/proxy.log
```

Look for: `→ GLM: glm-4 (tool emulation)`

---

## 📊 Expected Proxy Logs

When everything works, you'll see logs like:

```
[16:48:38] POST /v1/messages [anthropic]
[16:48:38] → Anthropic: claude-sonnet-4-5
[16:48:39] ← Anthropic: 200

[16:48:45] POST /v1/messages [glm]
[16:48:45] → GLM: glm-4
[16:48:46] ← GLM: 42 tokens

[16:48:52] POST /v1/messages [glm]
[16:48:52] → GLM: glm-4 (tool emulation)
[16:48:53] ← GLM: 58 tokens
```

---

## 🎯 Verification Checklist

Test each item and mark it:

- [ ] Claude Code starts with proxy
- [ ] Native Claude (your subscription) works
- [ ] Can switch to `/model glm/glm-4`
- [ ] GLM responds correctly
- [ ] Tools work with native Claude
- [ ] Tools work with GLM (emulation)
- [ ] Can switch back to native Claude
- [ ] No authentication errors
- [ ] Proxy logs show correct routing

---

## ✅ If All Tests Pass

**You're ready to use multi-provider Claude Code!**

### Daily Usage:

```bash
# Start Claude with proxy
~/.claude/scripts/claude-with-proxy.sh

# Use normally or switch models
/model glm/glm-4              # Fast, free model
/model claude-sonnet-4-5       # Your subscription
/model featherless/model-name  # Abliterated models

# Stop proxy when done
~/.claude/scripts/claude-with-proxy.sh stop
```

---

## 📚 Next Steps

1. **Add alias** to `~/.zshrc`:
   ```bash
   alias claude-proxy='~/.claude/scripts/claude-with-proxy.sh'
   ```

2. **Set up remaining API keys** (optional):
   ```bash
   export GOOGLE_API_KEY="your-key"
   export ANTHROPIC_API_KEY="your-key"  # Or keep using Claude Code's built-in auth
   ```

3. **Read full guide**:
   ```bash
   cat ~/.claude/MULTI_PROVIDER_GUIDE.md
   ```

---

## 🆘 Get Help

If tests fail:

1. **Check proxy logs**:
   ```bash
   tail -50 ~/.claude/proxy.log
   ```

2. **Test proxy independently**:
   ```bash
   ~/.claude/scripts/test-proxy.sh
   ```

3. **Verify file permissions**:
   ```bash
   ls -la ~/.claude/*.js
   ls -la ~/.claude/scripts/*.sh
   ```

4. **Restart with clean state**:
   ```bash
   pkill -f model-proxy-server.js
   ~/.claude/scripts/claude-with-proxy.sh
   ```

---

## 🎉 Success!

If your tests pass, you now have:

✅ **Multi-provider Claude Code** with tool support
✅ **Seamless model switching**
✅ **Tool calling for all models** (even abliterated)
✅ **Your Claude subscription** works through proxy
✅ **GLM, Featherless, Google, Anthropic** all available

**Start coding with multiple AI providers!** 🚀
