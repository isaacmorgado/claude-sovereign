---
name: commit
description: Run checks, commit with AI message, and push
---

1. Run quality checks (fix ALL errors before continuing):
   ```bash
   # Check shell scripts
   find . -name "*.sh" -type f -exec shellcheck {} + 2>/dev/null || echo "⚠️ shellcheck not found (optional)"

   # Check Python files (if any)
   if command -v python3 &>/dev/null && [ -n "$(find . -name "*.py" -type f)" ]; then
     python3 -m py_compile $(find . -name "*.py" -type f) 2>&1 | head -20
   fi
   ```

2. Review changes:
   ```bash
   git status
   git diff --stat
   ```

3. Generate commit message:
   - Start with verb (Add/Update/Fix/Remove/Refactor)
   - Be specific and concise (one line preferred)
   - Example: "Add multi-agent swarms with LangGraph coordination"

4. Commit and push:
   ```bash
   git add -A
   git commit -m "your generated message

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
   git push
   ```
