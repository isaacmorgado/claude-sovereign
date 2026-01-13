# Komplete Kontrol CLI (Claude Sovereign + TypeScript Migration)

Autonomous AI operation system being migrated from bash hooks to TypeScript/Bun. Goal: Integrate Roo Code SPARC methodology, /auto autonomy features, and multi-provider support into a unified modern CLI.

## Current Focus
Section: TypeScript Core Safety & Autonomy Features
Files: src/core/safety/bounded-autonomy/, src/core/agents/swarm/

## Last Session (2026-01-13)
- Implemented Bounded Autonomy safety system (5 modules: Prohibitions, Checker, Escalator, Approvals, index)
- Implemented Swarm Orchestration system (6 modules: Decomposer, Spawner, Coordinator, Merger, GitIntegration, index)
- Both systems fully typed, compile successfully, ready for LLM integration
- Committed and pushed to GitHub (65967b5)
- Stopped at: Core autonomy structures complete, need Debug Orchestrator next

## Next Steps
1. Implement Debug Orchestrator with regression detection (src/core/debug/orchestrator/)
2. Create LLM integration layer (provider router, streaming support)
3. Add first working CLI commands (/sparc, /auto, /reflect, /swarm)
4. Implement specialized commands (/research, /rootcause, /security-check)

## Project Structure

```
komplete-kontrol-cli/
├── hooks/                           # Legacy bash hooks (still functional)
├── src/                             # NEW: TypeScript implementation
│   ├── index.ts                         # CLI entry point
│   ├── core/
│   │   ├── workflows/sparc/             # SPARC methodology
│   │   ├── agents/reflexion/            # ReAct+Reflexion
│   │   ├── quality/judge/               # LLM-as-Judge
│   │   ├── safety/constitutional/       # Constitutional AI
│   │   └── reasoning/tree-of-thoughts/  # Tree of Thoughts
│   ├── cli/                             # CLI commands (TODO)
│   ├── commands/                        # Specialized commands (TODO)
│   └── agents/                          # Specialized agents (TODO)
├── dist/                            # Built CLI output
├── package.json, tsconfig.json      # TypeScript project config
└── plans/ULTIMATE-TOOL-INTEGRATION-PLAN.md  # Full roadmap
```

## Organization Rules

**Keep autonomous system modular:**
- Core orchestration → `/hooks` (coordinator, swarm-orchestrator, router)
- Memory management → `memory-manager.sh` (single source of truth)
- Validation gates → `comprehensive-validation.sh`, `post-edit-quality.sh`
- Navigation → `project-navigator.sh` (token efficiency)

**Skill command definitions:**
- One command per `.md` file in `/commands`
- Clear usage examples and trigger conditions
- Document autonomous execution patterns

**Hook script principles:**
- Single responsibility per script
- Executable permissions required (`chmod +x`)
- State stored in `~/.claude/` not project directory
- Clear naming: `action-noun.sh` or `action-noun-version.sh`

## Code Quality - Zero Tolerance

After editing ANY bash script, run ALL checks:

```bash
# 1. Syntax validation (required)
bash -n hooks/[script-name].sh

# 2. ShellCheck linting (if installed)
shellcheck hooks/[script-name].sh || echo "⚠️  ShellCheck not installed"

# 3. Comprehensive validation suite (74 tests)
./hooks/comprehensive-validation.sh
```

Fix ALL errors before continuing. No exceptions.

**Hook-specific requirements:**
- Verify executable: `chmod +x hooks/[script-name].sh`
- Test integration: Run in test mode if available
- Check logs: `~/.claude/logs/[script-name].log`
- Verify no regressions: Memory channels, Git operations, triggers
