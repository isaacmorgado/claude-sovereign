---
type: reference
title: Troubleshooting Guide
created: 2026-01-17
tags:
  - troubleshooting
  - debugging
  - support
related:
  - "[[API]]"
  - "[[Architecture]]"
  - "[[Memory-System]]"
---

# Claude Sovereign Troubleshooting Guide

This guide helps diagnose and resolve common issues with the Claude Sovereign autonomous system.

## Table of Contents

1. [Quick Diagnostics](#quick-diagnostics)
2. [Common Issues](#common-issues)
   - [Checkpoint Issues](#checkpoint-issues)
   - [Git Push Issues](#git-push-issues)
   - [Memory Issues](#memory-issues)
   - [Swarm Issues](#swarm-issues)
   - [Script Compatibility Issues](#script-compatibility-issues)
3. [Debug Logging](#debug-logging)
4. [Health Monitoring](#health-monitoring)
5. [Filing Issues](#filing-issues)

---

## Quick Diagnostics

Run these commands to quickly assess system health:

```bash
# Check overall system health
~/.claude/hooks/self-healing.sh check

# Check memory system status
~/.claude/hooks/memory-manager.sh scope

# Check file change tracker status
~/.claude/hooks/file-change-tracker.sh status

# Check swarm status (if active)
~/.claude/hooks/swarm-orchestrator.sh status

# Verify jq is available (required for JSON processing)
command -v jq && jq --version

# Check bash version (3.2+ required)
echo "Bash version: $BASH_VERSION"

# Check git version (2.5+ required for swarms)
git --version
```

---

## Common Issues

### Checkpoint Issues

#### "Checkpoint not triggering at 40% context"

**Symptoms**: The autonomous system doesn't run `/checkpoint` when context reaches 40%.

**Diagnosis**:
```bash
# Check current threshold setting
echo "CLAUDE_CONTEXT_THRESHOLD=${CLAUDE_CONTEXT_THRESHOLD:-40}"

# Check if autonomous mode is active
cat ~/.claude/autonomous-mode.active 2>/dev/null || echo "File not found"
```

**Solutions**:

1. **Verify autonomous mode is active**:
   - Run `/auto` to enable autonomous mode
   - Check that `~/.claude/autonomous-mode.active` exists and contains `true`

2. **Adjust the threshold**:
   ```bash
   # Lower threshold to trigger earlier (e.g., 30%)
   export CLAUDE_CONTEXT_THRESHOLD=30
   ```

3. **Check hook permissions**:
   ```bash
   ls -la ~/.claude/hooks/auto-continue.sh
   chmod +x ~/.claude/hooks/auto-continue.sh
   ```

4. **Verify hook is registered** in your Claude Code settings.

---

#### "Checkpoint not triggering after file changes"

**Symptoms**: After editing 10+ files, checkpoint doesn't trigger automatically.

**Diagnosis**:
```bash
# Check current file change count
~/.claude/hooks/file-change-tracker.sh status

# Check threshold setting
echo "CHECKPOINT_FILE_THRESHOLD=${CHECKPOINT_FILE_THRESHOLD:-10}"
```

**Solutions**:

1. **Check the file change counter**:
   ```bash
   cat ~/.claude/.file-change-count 2>/dev/null || echo "0"
   ```

2. **Adjust the threshold**:
   ```bash
   # Trigger checkpoint after fewer file changes
   export CHECKPOINT_FILE_THRESHOLD=5
   ```

3. **Reset the counter** (if stuck):
   ```bash
   ~/.claude/hooks/file-change-tracker.sh reset
   ```

---

### Git Push Issues

#### "Git push failing" / "Commits don't appear on GitHub"

**Symptoms**: Checkpoints create local commits but don't push to GitHub.

**Diagnosis**:
```bash
# Check if origin remote exists
git remote -v

# Check current branch
git branch --show-current

# Check if there are unpushed commits
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || echo "No upstream branch"
```

**Solutions**:

1. **Add origin remote** (if missing):
   ```bash
   git remote add origin https://github.com/username/repo.git
   ```

2. **Set upstream branch**:
   ```bash
   git push -u origin $(git branch --show-current)
   ```

3. **Check authentication**:
   - Ensure GitHub credentials are configured
   - For HTTPS: Check credential helper
   - For SSH: Check SSH key is added to GitHub

4. **Manual push** to verify:
   ```bash
   git push origin HEAD
   ```

---

#### "Push to origin failed (may need authentication or network issue)"

**Symptoms**: Swarm or checkpoint logs show push failed.

**Solutions**:

1. **Test network connectivity**:
   ```bash
   ping github.com -c 3
   ```

2. **Test GitHub API access**:
   ```bash
   gh auth status
   ```

3. **Re-authenticate** if needed:
   ```bash
   gh auth login
   ```

---

### Memory Issues

#### "Memory retrieval slow"

**Symptoms**: Commands like `remember-scored` take several seconds.

**Diagnosis**:
```bash
# Check memory database size
ls -lh ~/.claude/memory/*/memory.db 2>/dev/null

# Check episode count
~/.claude/hooks/memory-manager.sh search-episodes "" | wc -l
```

**Solutions**:

1. **Run memory compaction**:
   ```bash
   # Standard compaction (warning mode)
   ~/.claude/hooks/memory-manager.sh context-compact warning

   # Aggressive compaction (for critical context)
   ~/.claude/hooks/memory-manager.sh context-compact aggressive
   ```

2. **Prune old checkpoints**:
   ```bash
   # Keep only 5 most recent checkpoints
   ~/.claude/hooks/memory-manager.sh prune-checkpoints 5
   ```

3. **Prune file cache**:
   ```bash
   ~/.claude/hooks/memory-manager.sh prune-cache
   ```

---

#### "Memory database locked" / "Database is locked"

**Symptoms**: SQLite errors about database being locked.

**Solutions**:

1. **Check for lock file**:
   ```bash
   ls ~/.claude/memory/*/.memory.lock 2>/dev/null
   ```

2. **Remove stale lock** (if process exited unexpectedly):
   ```bash
   rm ~/.claude/memory/master/.memory.lock
   ```

3. **Wait and retry** - another process may be writing.

---

### Swarm Issues

#### "Swarm agents not spawning"

**Symptoms**: `swarm spawn` command doesn't create agents.

**Diagnosis**:
```bash
# Check jq availability
command -v jq && echo "jq available" || echo "jq NOT FOUND"

# Check swarm status
~/.claude/hooks/swarm-orchestrator.sh status

# Check for error logs
cat ~/.claude/swarm/*.log 2>/dev/null | tail -20
```

**Solutions**:

1. **Install jq** (required for full swarm functionality):
   ```bash
   # macOS
   brew install jq

   # Ubuntu/Debian
   sudo apt install jq

   # Fedora/RHEL
   sudo dnf install jq
   ```

2. **Check git worktree support**:
   ```bash
   git worktree list
   ```

3. **Initialize swarm directory**:
   ```bash
   mkdir -p ~/.claude/swarm
   ```

---

#### "No active swarm" error

**Symptoms**: Status or collect commands fail with "No active swarm".

**Solutions**:

1. **Start a new swarm**:
   ```bash
   ~/.claude/hooks/swarm-orchestrator.sh spawn "task description"
   ```

2. **Check swarm state file**:
   ```bash
   ls ~/.claude/swarm/state.json
   cat ~/.claude/swarm/state.json
   ```

---

### Script Compatibility Issues

#### "Scripts fail on macOS"

**Symptoms**: Syntax errors or unexpected behavior on macOS.

**Diagnosis**:
```bash
# Check bash version
echo $BASH_VERSION  # Should be 3.2.57 or higher

# Run compatibility check
~/.claude/tests/test-bash-compat.sh 2>/dev/null || echo "Compat test not found"
```

**Solutions**:

1. **Ensure portable shebang**: Scripts should use:
   ```bash
   #!/usr/bin/env bash
   ```
   Not:
   ```bash
   #!/bin/bash
   ```

2. **Check for Bash 4+ features** (not available on macOS default bash):
   - `declare -A` (associative arrays)
   - `${var,,}` (lowercase)
   - `${var^^}` (uppercase)
   - `mapfile` / `readarray`
   - `|&` (pipe stderr)

3. **Install newer bash** (optional):
   ```bash
   brew install bash
   ```

---

#### "command not found: jq"

**Symptoms**: JSON processing fails in various hooks.

**Solutions**:

Install jq for your platform:

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt update && sudo apt install jq

# Fedora/RHEL
sudo dnf install jq

# Alpine
apk add jq

# Windows (via Chocolatey)
choco install jq
```

---

## Debug Logging

### Enable Debug Mode

Several components support debug logging:

#### Memory Manager
```bash
export MEMORY_DEBUG=true
~/.claude/hooks/memory-manager.sh remember-scored "query"
```

#### Error Handler
The error handler automatically logs to `.claude/docs/debug-log.md`. View recent errors:
```bash
cat .claude/docs/debug-log.md | tail -50
```

#### Debug Orchestrator
```bash
# View debug directory contents
ls ~/.claude/.debug/

# View bug fix history
cat ~/.claude/.debug/bug-fixes.jsonl | tail -10

# View regression log
cat ~/.claude/.debug/regressions.jsonl | tail -10
```

#### Self-Healing Log
```bash
# View health check history
cat ~/.claude/self-healing.log | tail -50
```

### Trace Script Execution

For detailed script debugging:

```bash
# Trace any script
bash -x ~/.claude/hooks/script-name.sh command args

# Verbose trace (shows all expansions)
bash -xv ~/.claude/hooks/script-name.sh command args
```

### Swarm Logging

```bash
# View swarm orchestrator log
cat ~/.claude/swarm/orchestrator.log

# View specific agent logs
ls ~/.claude/swarm/agents/*/
cat ~/.claude/swarm/agents/agent_*/output.log
```

---

## Health Monitoring

### Self-Healing System

The system includes automatic health monitoring and recovery:

```bash
# Check current health
~/.claude/hooks/self-healing.sh check

# View health history
cat ~/.claude/self-healing.log | tail -20

# Trigger recovery if needed
~/.claude/hooks/self-healing.sh recover
```

**Health Statuses**:
- `healthy` - All systems operational
- `degraded` - Some issues detected (e.g., circuit breakers open)
- `unhealthy` - Critical failures requiring intervention

### Circuit Breakers

The system uses circuit breakers to prevent cascading failures:

```bash
# View circuit breaker state
cat ~/.claude/.circuit-breakers.json 2>/dev/null

# Reset all circuit breakers manually
rm ~/.claude/.circuit-breakers.json
```

---

## Filing Issues

When reporting issues, include the following diagnostics:

### 1. System Information

```bash
echo "=== System Info ==="
echo "OS: $(uname -s) $(uname -r)"
echo "Bash: $BASH_VERSION"
echo "Git: $(git --version)"
echo "jq: $(jq --version 2>/dev/null || echo 'not installed')"
```

### 2. Health Check Output

```bash
echo "=== Health Check ==="
~/.claude/hooks/self-healing.sh check 2>&1
```

### 3. Recent Logs

```bash
echo "=== Self-Healing Log (last 20 lines) ==="
tail -20 ~/.claude/self-healing.log 2>/dev/null

echo "=== Debug Log (last 20 lines) ==="
tail -20 .claude/docs/debug-log.md 2>/dev/null

echo "=== Swarm Log (last 20 lines) ==="
tail -20 ~/.claude/swarm/orchestrator.log 2>/dev/null
```

### 4. Configuration

```bash
echo "=== Environment Variables ==="
echo "CLAUDE_CONTEXT_THRESHOLD=${CLAUDE_CONTEXT_THRESHOLD:-40}"
echo "CHECKPOINT_FILE_THRESHOLD=${CHECKPOINT_FILE_THRESHOLD:-10}"
echo "MEMORY_DEBUG=${MEMORY_DEBUG:-false}"
```

### 5. Reproduce Steps

Include:
1. Exact commands run
2. Expected behavior
3. Actual behavior
4. Any error messages (exact text)

### Where to Report

- **GitHub Issues**: https://github.com/anthropics/claude-code/issues
- Include the diagnostics above
- Use the bug report template if available

---

## Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| Checkpoint not triggering | Check `/auto` is active, verify `CLAUDE_CONTEXT_THRESHOLD` |
| Git push failing | Run `git remote -v`, add origin if missing |
| Memory slow | Run `memory-manager.sh context-compact warning` |
| Swarm not spawning | Install jq: `brew install jq` or `apt install jq` |
| Script syntax error | Check bash version: `echo $BASH_VERSION` |
| Database locked | Remove `~/.claude/memory/*/.memory.lock` |
| Health degraded | Run `self-healing.sh recover` |

---

## Related Documentation

- [[API]] - Complete API reference for all hooks
- [[Architecture]] - System architecture and data flow
- [[Memory-System]] - Memory manager detailed documentation
- [[Swarm-Orchestrator]] - Multi-agent swarm documentation
