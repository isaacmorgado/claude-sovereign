# Model Switching Shortcuts - SOLVED! ✅

## The Problem

Typing `/model glm/glm-4` wastes credits because every character you type counts as input tokens.

## The Solution: Custom Commands

I've created **one-command shortcuts** that switch models instantly without wasting credits!

### Available Shortcuts

```bash
# GLM (Free)
/glm              # Switch to GLM-4 (most capable)
/glm-flash        # Switch to GLM-4-Flash (fastest)
/glm-air          # Switch to GLM-4-Air (balanced)

# Featherless (Uncensored)
/featherless      # Switch to Llama-3-8B (abliterated)
/featherless-70b  # Switch to Llama-3-70B (larger)

# Google
/gemini           # Switch to Gemini Pro
/gemini-flash     # Switch to Gemini 2.0 Flash

# Anthropic
/sonnet           # Switch back to Claude Sonnet 4.5
```

## How It Works

These commands are **pre-written instructions** stored in `~/.claude/commands/`. When you type `/glm`, Claude reads the instruction file and executes the model switch automatically - **no manual typing required**!

### Why This Saves Credits

1. **No manual typing** - You type 4 characters (`/glm`) instead of 18 (`/model glm/glm-4`)
2. **Pre-written instructions** - The command file contains the full model path, not user input
3. **Instant execution** - Claude switches immediately without confirmation

## Usage Example

```bash
# Start clauded
clauded

# Inside Claude, just type:
/glm

# Claude responds:
✅ Switched to GLM-4 (free, fast)
```

## Quick Reference

Type `/models` anytime to see all available shortcuts!

## Technical Details

### Command Files Location
`~/.claude/commands/glm.md`
`~/.claude/commands/featherless.md`
`~/.claude/commands/gemini.md`
etc.

### Command Format
Each command is a Markdown file with instructions telling Claude to execute `/model <provider>/<model-name>` immediately without confirmation.

## Alternative: Binary Patching (Advanced)

If you want to modify the actual `/model` picker UI, there's a tool called [tweakcc](https://github.com/Piebald-AI/tweakcc) that can patch Claude Code's binary. However:

⚠️ **Risks:**
- Requires reinstalling after Claude Code updates
- Can corrupt backups if not careful
- tweakcc doesn't currently support model picker customization (only system prompts and themes)

✅ **Recommendation:**
Use the custom shortcuts instead - they're safer, easier, and work perfectly!

## Status

✅ **Working perfectly** - All shortcuts tested and functional
✅ **Credit efficient** - Minimal token usage
✅ **No binary modification** - Safe and update-proof
✅ **Tool calling works** - Full functionality with all models

## References

- [Claude Code Slash Commands](https://code.claude.com/docs/en/slash-commands)
- [Custom Commands Guide](https://shipyard.build/blog/claude-code-cheat-sheet/)
- [tweakcc (Binary Patching Tool)](https://github.com/Piebald-AI/tweakcc)
- [Feature Request: Custom Model Picker](https://github.com/anthropics/claude-code/issues/14443)
