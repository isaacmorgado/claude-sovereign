# Phase 05: Bash Portability & Documentation

This phase addresses bash compatibility issues and creates comprehensive documentation. macOS ships with Bash 3.2 by default, but some scripts use Bash 4+ features like associative arrays. By the end of this phase, all scripts will work on both macOS and Linux, and documentation will be complete for users and contributors.

## Tasks

- [x] Audit all scripts for Bash 4+ features and fix compatibility:
  - Search all .sh files for Bash 4+ specific features:
    - `declare -A` (associative arrays) - replace with parallel indexed arrays
    - `${var,,}` and `${var^^}` (case modification) - replace with `tr`
    - `|&` (pipe stderr) - replace with `2>&1 |`
    - `mapfile` / `readarray` - replace with while-read loop
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/test-bash-compat.sh`:
    - Check each script with `bash --posix` for POSIX compliance hints
    - Test on Bash 3.2 syntax (if available) or document known issues
    - List any features that require Bash 4+ with justification
  - Fix all compatibility issues found:
    - Replace associative arrays with named files or JSON objects via jq
    - Replace case modification with `tr '[:upper:]' '[:lower:]'`
    - Ensure all scripts work on macOS default bash

  **Completed 2026-01-17**: Audited 81 scripts in ~/.claude/hooks/. No Bash 4+ features found (declare -A, ${var,,}, ${var^^}, |&, mapfile/readarray). Created test-bash-compat.sh that checks for 8 different Bash 4+ features with auto-fix capability. All scripts verified compatible with Bash 3.2.57 (macOS default).

- [x] Add shebang portability to all scripts:
  - Change all `#!/bin/bash` to `#!/usr/bin/env bash` for better portability
  - This allows the system to find bash in non-standard locations
  - Update scripts:
    - memory-manager.sh
    - auto-continue.sh
    - file-change-tracker.sh
    - swarm-orchestrator.sh
    - coordinator.sh
    - All other .sh files in hooks/

  **Completed 2026-01-17**: Updated 79 scripts from `#!/bin/bash` to `#!/usr/bin/env bash`. All 81 scripts now pass compatibility test (2 already had portable shebangs).

- [x] Create comprehensive API documentation:
  - Create `/Users/imorgado/Desktop/claude-sovereign/docs/API.md` with front matter:
    ```yaml
    ---
    type: reference
    title: Claude Sovereign API Reference
    created: [today's date]
    tags:
      - api
      - reference
      - hooks
    related:
      - "[[Memory-System]]"
      - "[[Swarm-Orchestrator]]"
      - "[[Coordinator]]"
    ---
    ```
  - Document each hook's CLI interface:
    - Command: name and syntax
    - Arguments: required and optional with types
    - Output: JSON schema or text format
    - Exit codes: meaning of each code
    - Examples: common usage patterns
  - Document each command's purpose and usage
  - Document environment variables and their effects

  **Completed 2026-01-17**: Created comprehensive API.md (~500 lines) documenting 6 major hooks:
  - coordinator.sh: Central orchestration with coordinate/orchestrate commands
  - agent-loop.sh: Autonomous execution with 25+ commands for lifecycle, tools, memory
  - swarm-orchestrator.sh: Multi-agent swarms with spawn/collect/status commands
  - memory-manager.sh: SQLite-backed memory with 30+ commands for Phase 1-4 features
  - auto-continue.sh: Context management hook with JSON I/O documentation
  - file-change-tracker.sh: File change tracking with checkpoint triggers
  - error-handler.sh: Error classification with retry strategies
  Also documented: all environment variables, exit codes, integration examples.

- [ ] Create architecture documentation with diagrams:
  - Create `/Users/imorgado/Desktop/claude-sovereign/docs/ARCHITECTURE.md` with front matter:
    ```yaml
    ---
    type: architecture
    title: System Architecture
    created: [today's date]
    tags:
      - architecture
      - design
      - system
    related:
      - "[[API]]"
      - "[[Coordinator]]"
    ---
    ```
  - ASCII diagram of component relationships:
    ```
    User → /auto → autonomous-command-router
                        ↓
                   coordinator.sh
                        ↓
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
    memory-manager  swarm-orchestrator  error-handler
        ↓               ↓               ↓
    checkpoint      Task agents     recovery
    ```
  - Data flow documentation
  - Hook execution order
  - Memory system architecture
  - Swarm coordination model

- [ ] Create troubleshooting guide:
  - Create `/Users/imorgado/Desktop/claude-sovereign/docs/TROUBLESHOOTING.md` with front matter:
    ```yaml
    ---
    type: reference
    title: Troubleshooting Guide
    created: [today's date]
    tags:
      - troubleshooting
      - debugging
      - support
    related:
      - "[[API]]"
      - "[[Architecture]]"
    ---
    ```
  - Common issues and solutions:
    - "Checkpoint not triggering at 40%" → Check CLAUDE_CONTEXT_THRESHOLD
    - "Git push failing" → Verify origin remote exists
    - "Memory retrieval slow" → Run memory compaction
    - "Swarm agents not spawning" → Check jq availability
    - "Scripts fail on macOS" → Ensure bash 3.2 compatibility
  - Debug logging instructions
  - How to file an issue with proper diagnostics

- [ ] Update install.sh with compatibility checks:
  - Add bash version check at start:
    ```bash
    BASH_MAJOR=$(echo $BASH_VERSION | cut -d. -f1)
    if [[ $BASH_MAJOR -lt 3 ]]; then
        echo "Error: Bash 3.2+ required (found $BASH_VERSION)"
        exit 1
    fi
    ```
  - Add jq installation check with helpful message:
    ```bash
    if ! command -v jq &>/dev/null; then
        echo "Warning: jq not found - some features will be limited"
        echo "Install with: brew install jq (macOS) or apt install jq (Linux)"
    fi
    ```
  - Add git version check for worktree support (swarms require git 2.5+)
  - Test installer on clean system simulation

- [ ] Run final validation and create release checklist:
  - Execute all test suites from Phase 02
  - Verify all security fixes from Phase 01 still pass
  - Run bash compatibility test
  - Create `/Users/imorgado/Desktop/claude-sovereign/docs/RELEASE-CHECKLIST.md`:
    - Front matter: `type: reference`, `title: Release Checklist`, `tags: [release, qa]`
    - [ ] All tests pass
    - [ ] Security validation passes
    - [ ] Bash 3.2 compatibility verified
    - [ ] Documentation complete
    - [ ] Install.sh works on clean system
    - [ ] README.md updated with any new features
    - [ ] CHANGELOG.md updated
  - Mark release as ready when all items checked
