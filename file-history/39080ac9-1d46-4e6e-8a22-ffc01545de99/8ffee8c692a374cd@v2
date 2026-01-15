---
description: Auto-generate documentation for completed features
argument-hint: "[feature-name] [--update-readme]"
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep"]
---

# Document Command

Automatically generate or update documentation after a feature is complete and working.

## Usage

```
/document                    # Document the last completed feature
/document auth-system        # Document specific feature
/document --update-readme    # Also update README.md
```

## Instructions

Parse arguments: $ARGUMENTS

### Step 1: Identify What to Document

**If feature name provided:**
- Find that section in buildguide.md

**If no feature name:**
- Find the most recently completed (`[x]`) section in buildguide.md
- Or check `.claude/current-build.local.md` for just-completed feature

### Step 2: Gather Feature Information

Read from multiple sources:

**From buildguide.md:**
- Section Overview
- Implementation Approach
- Architecture Fit

**From debug-log.md:**
- Issues encountered
- Patterns discovered
- Key solutions

**From the actual code:**
- Main files created/modified
- Public API/exports
- Key functions and their purposes

**From CLAUDE.md:**
- Context about the implementation
- Decisions made

### Step 3: Generate Feature Documentation

Create/update `.claude/docs/features/[feature-name].md`:

```markdown
# [Feature Name]

> Completed: [date]
> Status: ✅ Working

## Overview
[What this feature does - from buildguide.md]

## Usage

### Basic Usage
```[lang]
[Example code showing how to use the feature]
```

### API Reference

#### [Function/Class Name]
```[lang]
[Signature]
```
**Parameters:**
- `param1`: [description]
- `param2`: [description]

**Returns:** [description]

**Example:**
```[lang]
[usage example]
```

## Architecture

### Files
| File | Purpose |
|------|---------|
| [path] | [description] |

### Dependencies
- [dependency 1]
- [dependency 2]

### Integration Points
[How this connects to other parts of the system]

## Implementation Notes

### Key Decisions
[From CLAUDE.md and debug-log.md]

### Patterns Used
[From debug-log.md Patterns Discovered]

### Known Limitations
[Any constraints or edge cases]

## Troubleshooting

### Common Issues
[From debug-log.md resolved issues]

| Issue | Solution |
|-------|----------|
| [Error] | [Fix] |

## Testing

```bash
# Run tests for this feature
[test command]
```

## Changelog
- [date]: Initial implementation
```

### Step 4: Update Central Documentation

**Update `.claude/docs/index.md`** (create if not exists):

```markdown
# Project Documentation

## Features

| Feature | Status | Docs |
|---------|--------|------|
| [Feature 1] | ✅ | [Link](features/feature-1.md) |
| [Feature 2] | ✅ | [Link](features/feature-2.md) |
| [Feature 3] | 🚧 | In Progress |
```

### Step 5: If --update-readme Flag

**Update README.md** with feature information:

1. Find or create "## Features" section
2. Add the new feature to the list
3. Add usage example if not already present

```markdown
## Features

- **[Feature Name]**: [One-line description]
  - [Key capability 1]
  - [Key capability 2]
```

### Step 6: Update buildguide.md Completed Sections

Move detailed implementation notes to the Completed Sections:

```markdown
## Completed Sections

### [Feature Name] (Completed: [date])

**Summary:** [What was built]

**Key Files:**
- [file 1]
- [file 2]

**Documentation:** See `.claude/docs/features/[feature].md`

**Lessons Learned:**
- [Key insight 1]
- [Key insight 2]
```

### Step 7: Summary Output

```
✅ Documentation generated for: [Feature Name]

Created/Updated:
- .claude/docs/features/[feature].md
- .claude/docs/index.md
- buildguide.md (Completed Sections)
[If --update-readme]: - README.md

Documentation includes:
- Usage examples
- API reference
- Architecture notes
- Troubleshooting guide
```

## Integration with /build

After `/build` completes a feature:
1. Quality gates pass
2. `/checkpoint` saves state
3. **`/document` auto-runs** to generate docs
4. Continue to next feature

## Auto-Documentation Trigger

Add to `/build` Step 9 (Mark Complete):

```
After quality gates pass and before /checkpoint:
1. Run /document for the completed feature
2. Commit documentation with the feature
```
