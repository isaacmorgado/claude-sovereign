---
description: List available agent skills and tools
argument-hint: ""
allowed-tools: ["Bash", "Glob", "Read"]
---

# Skills Command

List all available skills and commands that the agent can use.

## Instructions

1. **List Commands**:
   List all markdown files in `~/.claude/commands/`:
   ```bash
   ls ~/.claude/commands/*.md | xargs -n 1 basename | sed 's/\.md$//'
   ```

2. **List Scripts**:
   List all scripts in `~/.claude/skills/`:
   ```bash
   ls ~/.claude/skills/*.sh | xargs -n 1 basename | sed 's/\.sh$//'
   ```

3. **Report**:
   Present the list of skills to the user, grouped by category if possible (Commands vs implementations).
