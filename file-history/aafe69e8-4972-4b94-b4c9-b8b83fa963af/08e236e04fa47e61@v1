# 🚀 Quick Start Guide

Get Claude Sovereign running in 5 minutes.

## Prerequisites

- [Claude Code](https://claude.ai/code) installed
- Git installed
- GitHub account (for auto-push features)

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/claude-sovereign.git
cd claude-sovereign

# Run the installer
./install.sh
```

The installer will:
- ✓ Detect Claude Code
- ✓ Install hooks to `~/.claude/hooks/`
- ✓ Install commands to `~/.claude/commands/`
- ✓ Install documentation to `~/.claude/docs/`
- ✓ Configure autonomous operation

## First Use

### 1. Start Autonomous Mode

In Claude Code, run:
```
/auto
```

You'll see:
```
🤖 AUTONOMOUS MODE ACTIVATED

I will now work fully autonomously:
- Execute tasks without asking for confirmation
- Auto-checkpoint progress every 10 changes
- Auto-fix errors (retry up to 3 times)
- Continue until task is complete or blocked

To stop: Say "stop" or run `/auto stop`
```

### 2. Give Claude a Task

Try something simple first:

**Example 1: Create Documentation**
```
Create a technical architecture document for a microservices
e-commerce platform. Include API design, database schema,
deployment strategy, and scaling considerations.
```

**Example 2: Implement a Feature**
```
Implement user authentication with OAuth2. Use best practices,
include tests, and document the API endpoints.
```

**Example 3: Bug Investigation**
```
Debug why the payment processing is failing for transactions
over $1000. Fix the bug and add regression tests.
```

### 3. Walk Away

Claude will now:
- ✅ Research via GitHub MCP
- ✅ Read project structure (token-efficient)
- ✅ Make intelligent decisions
- ✅ Auto-checkpoint every 10 files
- ✅ Auto-checkpoint at 40% context
- ✅ Push everything to GitHub
- ✅ Continue until complete

**You can literally leave your computer.**

### 4. Return to Finished Work

Come back to find:
- ✅ Task completed
- ✅ All changes checkpointed
- ✅ Everything pushed to GitHub
- ✅ Full history in git log

## What Happens Automatically

### At 40% Context (80K / 200K tokens)

```
1. Memory compaction (prune old info)
2. Internal checkpoint created
3. Router signals /checkpoint
4. Claude executes /checkpoint immediately
5. Updates CLAUDE.md + buildguide.md
6. git commit + push to GitHub
7. Continues working (no stopping)
```

### After 10 File Changes

```
1. File tracker hits threshold
2. Router signals /checkpoint
3. Project index regenerated
4. /checkpoint executes
5. git push to GitHub
6. Continues working
```

## Verifying Installation

Run the comprehensive test suite:

```bash
~/.claude/hooks/comprehensive-validation.sh
```

Expected output:
```
Total Tests: 74
Passed: 70+
Failed: 0-4
Pass Rate: 95%+

✅ EXCELLENT - System is production ready!
```

## Common Commands

```bash
# Start autonomous mode
/auto

# Stop autonomous mode
/auto stop

# Check status
/auto status

# Run validation tests
~/.claude/hooks/comprehensive-validation.sh

# View logs
tail -f ~/.claude/auto-continue.log
tail -f ~/.claude/logs/command-router.log
```

## Configuration

### Change Context Threshold (Default: 40%)

```bash
export CLAUDE_CONTEXT_THRESHOLD=50  # Trigger at 50%
```

### Change File Threshold (Default: 10 files)

```bash
export CHECKPOINT_FILE_THRESHOLD=15  # After 15 files
```

## Troubleshooting

### "Claude is asking permission instead of executing"

**Check autonomous mode is active:**
```bash
ls ~/.claude/autonomous-mode.active  # Should exist
```

**If not, activate it:**
```bash
/auto
```

### "Checkpoint not auto-executing"

**Check router output:**
```bash
~/.claude/hooks/autonomous-command-router.sh execute checkpoint_context "80000/200000"

# Should output:
# {"execute_skill": "checkpoint", "reason": "context_threshold", "autonomous": true}
```

### "Git push failing"

**Check git setup:**
```bash
git rev-parse --git-dir  # Should show: .git
git remote -v            # Should show origin
git push origin HEAD     # Try manual push
```

## Next Steps

### 1. Read Full Documentation

- [100% Hands-Off Operation](docs/100-PERCENT-HANDS-OFF-OPERATION.md) - Complete guide
- [40% Flow Verified](docs/40-PERCENT-FLOW-VERIFIED.md) - Context management
- [Project Navigator](docs/PROJECT-NAVIGATOR-GUIDE.md) - Token optimization
- [GitHub Integration](docs/GITHUB-PUSH-AND-NAVIGATION-COMPLETE.md) - Auto-push

### 2. Try Advanced Features

**Multi-Agent Orchestration:**
```
Create a complete REST API with:
- Authentication service
- User management service
- Payment processing service
Use microservices architecture with Docker.
```

**Reverse Engineering:**
```
Reverse engineer this Chrome extension and document its API:
[extension URL or local path]
```

**Architecture Document:**
```
Create a complete system architecture document for a
real-time chat application with 1M+ concurrent users.
Include infrastructure, scaling, monitoring, security.
```

### 3. Customize Your Setup

Edit `~/.claude/CLAUDE.md` to:
- Add project-specific patterns
- Configure memory behavior
- Set custom thresholds
- Add custom hooks

### 4. Join the Community

- ⭐ Star the repo
- 🐛 Report issues
- 💡 Share use cases
- 🤝 Contribute improvements

## Success Metrics

After using Claude Sovereign, you should see:

✅ **Time Saved**
- No manual checkpoints (100+ per day)
- No manual git pushes (50+ per day)
- No context management (10+ times per day)
- **Result: 2-3 hours saved per day**

✅ **Quality Improved**
- Perfect memory across sessions
- Consistent pattern application
- No forgotten context
- **Result: Fewer bugs, better code**

✅ **Productivity Increased**
- Can work on other things while Claude works
- Complete complex tasks overnight
- Zero babysitting required
- **Result: 3-5x productivity boost**

## Support

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/yourusername/claude-sovereign/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/claude-sovereign/discussions)

---

**You're ready! 🚀**

Run `/auto` and give Claude a challenging task. Watch it work autonomously.

**⚡ Claude Sovereign - The AI that governs itself ⚡**
