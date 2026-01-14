# Komplete Kontrol CLI (Claude Sovereign + TypeScript Migration)

Autonomous AI operation system being migrated from bash hooks to TypeScript/Bun. Goal: Integrate Roo Code SPARC methodology, /auto autonomy features, and multi-provider support into a unified modern CLI.

## Current Focus
Documentation cleanup complete. Project now has professional-grade organization with 97% reduction in root clutter.

**Documentation Cleanup - Complete**:
- Reorganized 65 markdown files from root into structured /docs directory
- Created categories: features/, integration/, guides/, archive/sessions/, archive/test-reports/
- Root reduced from 65 to 2 files (CLAUDE.md, README.md only)
- Created master DOCUMENTATION-INDEX.md with task-based navigation
- Updated README.md and CLAUDE.md references to new paths
- 108 files moved/modified, zero files lost

## Next Steps
1. Run `./run-edge-case-tests.sh` to validate ReflexionAgent 30-50 iteration performance (after API quota reset)
2. Phase 2B: E2E orchestrator tests with actual ReflexionAgent execution
3. Phase 3: Validation and performance benchmarks
4. Phase 4: Production rollout (enable ENABLE_REFLEXION_AGENT feature flag by default)

## Key Files

**Phase 1 Files**:
- `src/cli/commands/ReflexionCommand.ts` - CLI interface for ReflexionAgent (257 lines)
- `src/index.ts` - CLI router with /reflexion command
- `tests/integration/reflexion-command.test.ts` - Integration test suite (335 lines)
- `docs/features/REFLEXION-COMMAND-INTEGRATION-COMPLETE.md` - Phase 1 documentation (470+ lines)

**Phase 2A Files**:
- `~/.claude/hooks/autonomous-orchestrator-v2.sh` - Modified (+120 lines)
- `docs/integration/ORCHESTRATOR-REFLEXION-INTEGRATION-DESIGN.md` - Integration design (271 lines)
- `tests/orchestrator/UNIT-TEST-RESULTS.md` - Decision logic test results
- `docs/archive/sessions/SESSION-SUMMARY-ORCHESTRATOR-INTEGRATION-2026-01-13.md` - Session summary

**Planning Documents**:
- `docs/integration/REFLEXION-ORCHESTRATOR-INTEGRATION-PLAN.md` - 4-phase integration plan (updated)

**Documentation**:
- `DOCUMENTATION-INDEX.md` - Master documentation index (90+ organized files)

## Key Context

**CLI Usage**:
- Invocation: `bun run src/index.ts reflexion execute --goal "..." --output-json`
- Model: Always use `--preferred-model glm-4.7` to avoid rate limits
- Fallback chain: Kimi-K2 → GLM-4.7 → Llama-70B → Dolphin-3

**Orchestrator Integration**:
- Feature flag: `export ENABLE_REFLEXION_AGENT=1` (default: 0)
- Decision logic: 4 rules route complex tasks to ReflexionAgent
- Automatic fallback: Rate limits or errors trigger bash agent-loop
- Logging: All decisions logged to `~/.claude/orchestrator.log`


## Milestones
- 2026-01-14: Test commit (e8438b7)