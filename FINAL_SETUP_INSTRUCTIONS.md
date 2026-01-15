# 🎉 Complete Setup Guide - Claude Code Customizations

**Date**: 2026-01-12
**Status**: ✅ All customizations ready to apply

---

## 📋 What Was Completed

### ✅ 1. Featherless API Key Configuration
- **API Key**: Stored in `~/.zshrc`
- **Status**: Configured and exported for current session
- **Models Available**: 6 uncensored models (Dolphin-3, Qwen 2.5, WhiteRabbitNeo, Llama-3 variants)

### ✅ 2. tweakcc Customizations
Built and ready to apply:

#### A. Custom CLAUDE ASCII Art with Horns 🦌
- Replaces default "Clawd" character
- Custom "CLAUDE" text with horn decorations from C and E
- ASCII art design:
```
     ▲                                        ▲
    ▐█▌                                      ▐█▌
   ▐███▌    ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗
  ▐█████▌  ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝
   ▐███▌   ██║     ██║     ███████║██║   ██║██║  ██║█████╗
    ▐█▌    ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝
     ▲     ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗
            ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
```

#### B. Matrix Green Color Theme 🟢
- Replaces all orange colors (#FF8800, #FFA500, etc.)
- New color: Matrix green (#00FF41)
- Applies to: UI elements, borders, highlights, status indicators

#### C. Status Line Enhancements 📊
- Attempts to make project directory always visible
- Attempts to make model name always visible
- Uses pattern matching on minified code
- Falls back gracefully if patterns not found

### ✅ 3. Google OAuth Implementation 🔐
- **Location**: `~/.claude/lib/gemini-oauth.js`
- **Proxy Server**: Updated at `~/.claude/model-proxy-server.js`
- **Features**:
  - Browser-based OAuth login
  - No need to manually copy API keys
  - Auto-refresh expired tokens
  - Secure token storage (0600 permissions)
  - Fallback to GOOGLE_API_KEY if OAuth not configured

---

## 🚀 How to Apply Everything

### Step 1: Apply tweakcc Patches (CLI Customizations)

Run the prepared script:

```bash
/tmp/apply-tweakcc.sh
```

**Or manually**:
```bash
cd /tmp/tweakcc && sudo bun run dist/index.mjs --apply
```

This will:
1. Request your sudo password
2. Backup original Claude Code binary
3. Apply all customizations (ASCII art, colors, status line)

### Step 2: Test the Customizations

Start Claude Code to see the changes:

```bash
clauded
```

**You should see**:
- ✅ Custom "CLAUDE" ASCII art with horns
- ✅ Matrix green color scheme (instead of orange)
- ✅ Potentially enhanced status line (if patterns matched)

### Step 3: Set Up Google OAuth (Optional but Recommended)

#### A. Test Current Setup
First, verify your model proxy server is working:

```bash
# If not already running, start it
node ~/.claude/model-proxy-server.js 3000 &

# In another terminal, start Claude Code with proxy
ANTHROPIC_BASE_URL=http://localhost:3000 clauded
```

#### B. Login with OAuth
Run the OAuth login command:

```bash
node ~/.claude/model-proxy-server.js --gemini-login
```

This will:
1. Open your browser to Google's consent page
2. Ask you to authorize the application
3. Save OAuth tokens to `~/.claude/gemini-oauth.json`
4. Display success message

#### C. Use Google Models
After OAuth setup:

```bash
# Start Claude Code with proxy (if not already)
ANTHROPIC_BASE_URL=http://localhost:3000 clauded

# Switch to a Google model
/model google/gemini-2.0-flash
```

**No GOOGLE_API_KEY required!** 🎉

---

## 📁 Files Created/Modified

### New Files
```
~/.claude/lib/gemini-oauth.js          # OAuth implementation
~/.claude/FINAL_SETUP_INSTRUCTIONS.md  # This file
~/.claude/GOOGLE_OAUTH_IMPLEMENTATION.md  # OAuth technical docs
/tmp/apply-tweakcc.sh                  # Patch application script
/tmp/add-oauth-to-proxy.js             # OAuth integration script
```

### Modified Files
```
~/.zshrc                               # Added FEATHERLESS_API_KEY
~/.claude/model-proxy-server.js        # Added OAuth support
~/.tweakcc/config.json                 # Enabled custom patches
/tmp/tweakcc/src/patches/customStartupArt.ts      # ASCII art patch
/tmp/tweakcc/src/patches/customStatusLine.ts      # Status line patch
/tmp/tweakcc/src/patches/index.ts      # Registered patches
/tmp/tweakcc/src/types.ts              # Added type definitions
/tmp/tweakcc/src/defaultSettings.ts    # Added defaults
/tmp/tweakcc/src/ui/components/MiscView.tsx  # Added UI toggles
```

### Backups
```
~/.claude/model-proxy-server.js.pre-oauth  # Pre-OAuth backup
~/.claude/model-proxy-server.js.backup     # Original backup
```

---

## 🔑 Environment Variables

Add these to your `~/.zshrc` (already done for Featherless):

```bash
# Featherless API (6 uncensored models) - ✅ CONFIGURED
export FEATHERLESS_API_KEY="rc_0d2c186ee945d2e0a15310e7630233b1b3bd5448fdf0d587ab5dc71cf5994fa3"

# Google API Key (optional - OAuth preferred)
# export GOOGLE_API_KEY="your-key-here"

# Other providers (optional)
# export ANTHROPIC_API_KEY="your-anthropic-key"
```

Reload your shell:
```bash
source ~/.zshrc
```

---

## 🎨 Customization Toggle (After Applying)

You can toggle customizations via tweakcc UI:

```bash
cd /tmp/tweakcc && bun run dist/index.mjs
```

Then navigate to: **Misc → Custom CLAUDE ASCII art with horns**

Or edit `~/.tweakcc/config.json` directly:
```json
{
  "misc": {
    "customStartupArt": true,      // CLAUDE art with horns
    "matrixGreenColors": true,     // Matrix green theme
    "customStatusLine": true       // Always show project/model
  }
}
```

After changing, reapply:
```bash
cd /tmp/tweakcc && sudo bun run dist/index.mjs --apply
```

---

## 🔧 Troubleshooting

### Issue: "sudo: a terminal is required"
**Solution**: Run commands in an interactive terminal, not via automation

### Issue: Google OAuth login doesn't open browser
**Solution**: Copy the URL from terminal and paste into browser manually

### Issue: tweakcc patches don't apply
**Solution**:
1. Check if Claude Code is running: `pkill -f claude`
2. Re-run: `cd /tmp/tweakcc && sudo bun run dist/index.mjs --apply`

### Issue: Status line customization doesn't work
**Reason**: Minified code patterns may have changed
**Solution**: The patch safely returns original code if patterns aren't found, so nothing breaks. This feature is experimental.

### Issue: OAuth tokens expired
**Solution**: Tokens auto-refresh. If issues persist:
```bash
node ~/.claude/model-proxy-server.js --gemini-logout
node ~/.claude/model-proxy-server.js --gemini-login
```

---

## 📚 Model Access Summary

After setup, you'll have access to:

### Anthropic (Native)
- Claude Opus 4.5
- Claude Sonnet 4.5
- Claude Haiku 3.5

### GLM/ZhipuAI (Free, Chinese)
- glm/glm-4
- glm/glm-4-flash
- glm/glm-4-air

### Google Gemini (OAuth or API Key)
- google/gemini-2.0-flash
- google/gemini-pro
- google/gemini-1.5-pro

### Featherless (Uncensored, $10/mo unlimited)
- featherless/dolphin-3-24b (32K context)
- featherless/qwen-2.5-72b (128K context)
- featherless/whiterabbitneo-8b (8K context)
- featherless/llama-3-70b (8K context)
- featherless/llama-3-8b-v3 (8K context)
- featherless/llama-3-8b-v2 (8K context)

**Total**: 14+ models across 4 providers!

---

## 🎯 Quick Start Commands

```bash
# 1. Apply tweakcc customizations
/tmp/apply-tweakcc.sh

# 2. Start model proxy (in background)
node ~/.claude/model-proxy-server.js 3000 &

# 3. Setup Google OAuth (optional)
node ~/.claude/model-proxy-server.js --gemini-login

# 4. Start Claude Code with proxy
ANTHROPIC_BASE_URL=http://localhost:3000 clauded

# 5. Switch models
/model featherless/dolphin-3-24b
/model google/gemini-2.0-flash
/model glm/glm-4
```

---

## 📖 Additional Documentation

- `~/.claude/GOOGLE_OAUTH_IMPLEMENTATION.md` - Technical OAuth details
- `~/.claude/FINAL_SETUP_SUMMARY.md` - Previous multi-model setup
- `~/.claude/CONTEXT_WINDOW_SOLUTIONS.md` - Managing small context models
- `/tmp/tweakcc/src/patches/` - Patch source code

---

## 🎉 Summary

**Everything is ready!** Just run:

```bash
# Apply the CLI customizations
/tmp/apply-tweakcc.sh

# Then start using your customized Claude Code!
clauded
```

You'll see:
- 🦌 Custom CLAUDE ASCII art with horns
- 🟢 Beautiful matrix green color scheme
- 🔐 Google OAuth login (no more manual API keys!)
- 🌍 Access to 14+ models across 4 providers

**Enjoy your customized Claude Code experience!**

---

*Setup completed: 2026-01-12*
*All changes are reversible via tweakcc restore or backups*
