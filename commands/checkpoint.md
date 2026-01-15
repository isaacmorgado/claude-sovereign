---
description: Save progress to CLAUDE.md AND generate continuation prompt
argument-hint: "[summary]"
allowed-tools: ["Read", "Write", "Edit"]
---

# Session Checkpoint Command

Save current session state to CLAUDE.md for long-term persistence AND output a continuation prompt for immediate use. Also updates buildguide.md if it exists.

## Instructions

Do THREE things:

### 0. Check for Pipeline State (Do This First)

Read CLAUDE.md. If a `## Pipeline State` section exists, this is a **pipeline-aware checkpoint**.

Extract:
- **Phase**: bug-hunt, debugging, refactor-hunt, refactoring, or build
- **Feature**: The feature being worked on
- **Tier**: high, medium, or low (if applicable)
- **Tier-Status**: pending, in-progress, or complete
- **Reports**: Paths to bugs, fixes, and/or refactors reports

If Pipeline State exists, read the most recent report to extract the **Scope** (file list).

**Advance the Pipeline State** based on what work was just completed:

| Current State | Next State |
|---------------|------------|
| debugging, high, in-progress | debugging, medium, pending |
| debugging, medium, in-progress | debugging, low, pending |
| debugging, low, in-progress | refactor-hunt, -, - |
| refactoring, high, in-progress | refactoring, medium, pending |
| refactoring, medium, in-progress | refactoring, low, pending |
| refactoring, low, in-progress | build, -, - |

Update the Pipeline State section in CLAUDE.md with the new tier/phase.

Then proceed to steps 0.5, 1 and 2 below, using the **Pipeline-Aware Continuation Prompt** format.

### 0.5. Update buildguide.md (If It Exists)

Check if `buildguide.md` exists in the project root.

**If buildguide.md exists:**

#### A. Scan for New Documentation

Launch an Explore agent to find any new docs since last update:

```
Scan for new or modified documentation:
- .claude/plans/*.md
- .claude/docs/*.md
- docs/**/*.md
- *.md in project root
- research/, notes/ directories

Compare against what's already in buildguide.md.
Return list of NEW documentation not yet integrated.
```

#### B. Identify and Mark Section Complete

1. **Identify current section** - Ask the user or infer from the work done:
   > "Which section did you complete? [list unchecked sections from buildguide.md]"

2. **Mark section complete** - In the `## Build Sections` checklist:
   - Change `- [ ] Section Name` to `- [x] Section Name`

3. **Move to Completed Sections** - Take the research/documentation under that section and move it to `## Completed Sections` with:
   ```markdown
   ### [Section Name] (Completed: [today's date])

   **Implementation:** [Brief summary of what was built]

   **Key Files:**
   - [List of files created/modified]

   **Notes:**
   - [Any important implementation details]

   [Original research content, condensed if needed]
   ```

#### C. Integrate New Documentation

If the explore agent found new docs:
- Add them to appropriate pending sections
- Or note them in the continuation prompt for next `/collect`

#### D. Update and Identify Next

1. **Update metadata** - Change `Last Updated: [today's date]`

2. **Identify next section** - Find the first unchecked `- [ ]` item in the Sections list. Include this in the continuation prompt.

3. **Note any new docs** - If new documentation was found, mention it:
   > "New docs found: [list]. Run /collect to integrate them into the build plan."

**If buildguide.md doesn't exist:** Skip this step.

### 1. Update CLAUDE.md (KEEP IT LEAN)

Read the existing CLAUDE.md in the project root. Apply these rules strictly:

**Last Session** - REPLACE entirely (do NOT nest "Previous Session" blocks):
- Delete the old Last Session content completely
- Write only the current session's summary
- Keep it to 5-10 lines max

**Next Steps** - REMOVE completed items (do NOT use strikethrough):
- Delete any items that are done
- Keep only pending/future items
- Renumber the list

**Current Focus** - Update if it changed

**Session Log / History sections** - DELETE if they exist:
- Remove any `## Session Log` section
- Remove any accumulated history
- That's what git is for

**Preserve only**: Project description, Current Focus, Pipeline State, Last Session, Next Steps

Write the changes.

### 1.5. Push to GitHub (if in git repo)

After updating CLAUDE.md, check if we're in a git repository and push changes:

```bash
# Check if git repo exists
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Check if there are changes to commit
    if ! git diff --quiet || ! git diff --cached --quiet; then
        # Stage the checkpoint files
        git add CLAUDE.md buildguide.md 2>/dev/null || git add CLAUDE.md

        # Commit with checkpoint message
        git commit -m "checkpoint: $(date '+%Y-%m-%d %H:%M') - session progress saved"

        # Push to remote (if remote exists)
        if git remote | grep -q 'origin'; then
            git push origin HEAD 2>/dev/null || echo "Note: Push failed, may need authentication"
        fi
    fi
fi
```

**Important**: This only runs if:
- We're in a git repository
- There are actual changes to commit
- The `origin` remote exists

If push fails (authentication, no remote, etc.), continue normally. The local commit is still created.

If CLAUDE.md doesn't exist, create it using this structure:

```markdown
# Project Name

One-line description.

## Current Focus
Section: [current area of work]
Files: [relevant files]

## Last Session ([date])
- What was done
- Stopped at: [where you left off]

## Next Steps
1. [First thing to do]
2. [Second thing]
3. [Third thing]
```

### 2. Output Continuation Prompt

After updating the file, output a ready-to-use continuation prompt for immediate context clearing:

```
## Continuation Prompt

**RESUME**: [Project Name]
**Context**: saved to CLAUDE.md

**Current State**: [where we left off]
**Next**: [very next step]

**Action**:
1. Run `aichat resume` (if installed)
2. OR `/clear` and paste: "Continue work on [Next Step]. Ref: CLAUDE.md"

**Focus**: [file/component]. Don't re-read full codebase.
```

Keep the continuation prompt SHORT (under 15 lines). The detailed state is now in CLAUDE.md — the prompt just needs enough to bridge the context clear.

### Pipeline-Aware Continuation Prompt

If Pipeline State was detected in step 0, use this format based on the NEW state (after advancement):

**For debugging phase (any tier):**
```
## Continuation Prompt

Continue work on [Project Name] at [directory].

**Pipeline Phase**: debugging
**Feature**: [feature name]
**Current Tier**: [tier] - pending

**Scope** (work only on these files):
- [files from bug report]

**Reports**:
- bugs: [path]
- fixes: [path if exists]

**Next Action**: Fix [tier] priority bugs from the bug report

**Approach**: Do NOT explore the codebase. Read only the files in Scope above.
```

**For refactor-hunt phase (transition from debugging):**
```
## Continuation Prompt

Continue work on [Project Name] at [directory].

**Pipeline Phase**: refactor-hunt
**Feature**: [feature name]

**Scope** (work only on these files):
- [files from fixes report]

**Reports**:
- bugs: [path]
- fixes: [path]

**Next Action**: Run /refactor-hunt-checkpoint to analyze for refactoring opportunities

**Approach**: Do NOT explore the codebase. Read only the files in Scope above.
```

**For refactoring phase (any tier):**
```
## Continuation Prompt

Continue work on [Project Name] at [directory].

**Pipeline Phase**: refactoring
**Feature**: [feature name]
**Current Tier**: [tier] - pending

**Scope** (work only on these files):
- [files from refactor report]

**Reports**:
- refactors: [path]

**Next Action**: Execute [tier] priority refactors from the refactor report

**Approach**: Do NOT explore the codebase. Read only the files in Scope above.
```

**For build phase (pipeline complete):**
```
## Continuation Prompt

Continue work on [Project Name] at [directory].

**Pipeline Complete** for feature: [feature name]

**Reports** (for reference):
- bugs: [path]
- fixes: [path]
- refactors: [path]

**Pending Work** (from CLAUDE.md Next Steps):
- [pending items]

**Next Action**: [First pending item, or "Pipeline complete - check with user for next task"]

**Approach**: Read CLAUDE.md for full context. You may explore the codebase as needed.
```

## Workflow

User runs `/checkpoint`. Four things happen:

1. **Scan** - Explore agent checks for new documentation
2. **Update buildguide.md** - Section marked complete, new docs noted, next section identified
3. **Update CLAUDE.md** - Long-term memory saved
4. **Continuation prompt** - Ready for context clear, includes new docs alert if any

User can then:
- **Clear now**: Copy prompt → `/clear` → paste → keep working
- **Stop for the day**: Just close. CLAUDE.md + buildguide.md have everything for next time.
- **Keep working**: Do nothing, state is saved anyway
- **Run /collect**: If new docs were found, integrate them into the build plan

## Integration with /collect

The `/collect` and `/checkpoint` commands work together:

1. **Research phase**: Use `/collect` to gather knowledge into buildguide.md
2. **Build phase**: Implement the section using the collected research
3. **Complete phase**: Use `/checkpoint` to mark section done and advance to next

This creates a research → build → checkpoint → research cycle.

## Adapt to Session Complexity

**Simple session** (quick fix, single task):
- Brief CLAUDE.md update (1-2 bullet points)
- Minimal continuation prompt (5-8 lines)

**Standard session** (feature work, multiple tasks):
- Full CLAUDE.md update
- Standard continuation prompt with all sections

**Complex session** (architecture changes, many files):
- Thorough CLAUDE.md update with decisions documented
- Detailed continuation prompt including key decisions and gotchas

## Guidelines

**CLAUDE.md should stay under 150 lines.** If it's longer, you're doing it wrong.

- REPLACE Last Session, don't append to it
- DELETE completed Next Steps, don't strike them through
- DELETE Session Log / History sections entirely
- Keep the continuation prompt SHORT (under 15 lines)
- Be specific with file paths and function names
- Detailed history belongs in git, not CLAUDE.md
