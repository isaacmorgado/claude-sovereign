---
description: Initialize a new project with architecture docs for autonomous building
argument-hint: "<project-name> [--type node|python|go|rust]"
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob"]
---

# Initialize Project Command

Set up a new project with architecture documentation ready for autonomous building.

## Usage

```
/init-project my-cli-tool --type node
/init-project api-server --type python
/init-project my-service --type go
```

## Instructions

Parse arguments: $ARGUMENTS

Extract:
- `project-name`: First argument
- `--type`: Project type (default: detect from files or ask)

### Step 1: Detect or Confirm Project Type

If `--type` not specified:
- Check for package.json → node
- Check for pyproject.toml/requirements.txt → python
- Check for go.mod → go
- Check for Cargo.toml → rust
- Otherwise ask user

### Step 2: Create Project Structure

```bash
mkdir -p .claude/docs
mkdir -p .claude/plans
mkdir -p docs
```

### Step 3: Create ARCHITECTURE.md

Based on project type, create appropriate architecture template:

**For Node/TypeScript:**

```markdown
# Architecture: [PROJECT_NAME]

## Overview
[One paragraph describing what this project does]

## Tech Stack
- **Runtime**: Node.js / Bun / Deno
- **Language**: TypeScript
- **Framework**: [Express/Fastify/Hono/etc]
- **Database**: [if applicable]
- **Testing**: [Jest/Vitest/etc]

## Project Structure
```
src/
├── index.ts          # Entry point
├── commands/         # CLI commands (if CLI)
├── lib/              # Core logic
├── utils/            # Utilities
└── types/            # TypeScript types
```

## Quality Commands
```bash
npm run lint          # ESLint
npm run typecheck     # tsc --noEmit
npm run test          # Jest/Vitest
npm run build         # Build for production
```

## Patterns
- Use async/await for all async operations
- Export types from types/ directory
- One file per command/feature
- Tests in __tests__ or *.test.ts

## Limitations
- [Known issues or constraints]
```

**For Python:**

```markdown
# Architecture: [PROJECT_NAME]

## Overview
[One paragraph describing what this project does]

## Tech Stack
- **Runtime**: Python 3.11+
- **Framework**: [FastAPI/Flask/Click/etc]
- **Database**: [if applicable]
- **Testing**: pytest

## Project Structure
```
src/
├── __init__.py
├── main.py           # Entry point
├── commands/         # CLI commands (if CLI)
├── core/             # Core logic
├── utils/            # Utilities
└── models/           # Data models
tests/
└── test_*.py
```

## Quality Commands
```bash
ruff check .          # Linting
ruff format .         # Formatting
mypy .                # Type checking
pytest                # Tests
```

## Patterns
- Type hints on all functions
- Pydantic for data validation
- One module per feature
- Tests mirror src structure

## Limitations
- [Known issues or constraints]
```

### Step 4: Create Initial CLAUDE.md

```markdown
# [PROJECT_NAME]

[One-line description]

## Current Focus
Initial project setup

## Architecture
See ARCHITECTURE.md for full system design.

## Quality Gates
All code must pass:
- [ ] Lint (no errors)
- [ ] Type check (no errors)
- [ ] Tests (all passing)

## Last Session
- Project initialized with /init-project
- Architecture docs created

## Next Steps
1. Define features in buildguide.md (run /collect)
2. Start building (run /build)
```

### Step 5: Create Initial buildguide.md

```markdown
# Build Guide: [PROJECT_NAME]

> Created: [date]
> Last Updated: [date]

## Project Overview
[To be filled by /collect]

## Current Architecture
See ARCHITECTURE.md

## Build Sections
- [ ] Project scaffolding
- [ ] Core feature 1
- [ ] Core feature 2
- [ ] Testing setup
- [ ] Documentation

---

## Section: Project Scaffolding

### Overview
Set up the basic project structure, dependencies, and tooling.

### Implementation Approach
1. Initialize package manager (npm/pip/go mod/cargo)
2. Add linting and formatting tools
3. Add type checking
4. Set up test framework
5. Create entry point

### Files to Create
- [entry point file]
- [config files]
- [test setup]

---

## Completed Sections
[Filled by /checkpoint]
```

### Step 6: Initialize Quality Tools

Based on project type, suggest and optionally install quality tools:

**Node:**
```bash
npm init -y
npm install -D typescript eslint @types/node vitest
npx tsc --init
```

**Python:**
```bash
pip install ruff mypy pytest
```

### Step 7: Summary

```
✅ Project initialized: [PROJECT_NAME]

Created:
- ARCHITECTURE.md - System design reference
- CLAUDE.md - Session state tracking
- buildguide.md - Implementation plan

Next steps:
1. Edit ARCHITECTURE.md with your specific design
2. Run /collect to gather research and refine build plan
3. Run /build to start autonomous building

Start with: /build
```
