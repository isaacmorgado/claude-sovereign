---
description: Compact memory and optimize context usage
argument-hint: "[aggressive|conservative]"
allowed-tools: ["Read", "Write", "Edit"]
---

# Memory Compact Command

Compact memory to optimize context usage and reduce token consumption. This command analyzes the current context and creates a condensed summary while preserving critical information.

## Usage

```
/compact              # Standard compaction (balanced)
/compact aggressive    # Aggressive compaction (maximum reduction)
/compact conservative  # Conservative compaction (minimal reduction, more detail)
```

## Instructions

Parse arguments: $ARGUMENTS

### Step 1: Analyze Current Context

Assess the current context state:

1. **Check context usage** (if available):
   ```bash
   # Approximate context size estimation
   context_size=$(wc -c <<< "$CONTEXT" 2>/dev/null || echo "0")
   context_lines=$(wc -l <<< "$CONTEXT" 2>/dev/null || echo "0")
   ```

2. **Determine compaction level**:
   - If argument is "aggressive": Target 60% reduction
   - If argument is "conservative": Target 30% reduction
   - Default (no argument): Target 50% reduction

### Step 2: Extract Critical Information

Create a compacted context that preserves:

**ALWAYS KEEP**:
- Current task/goal (1-2 lines)
- Last 3-5 actions taken
- Current file being edited (if any)
- Pending decisions or choices needed
- Key variables or state

**COMPRESS**:
- Long code blocks → Summarize purpose and key changes
- Multiple similar messages → Consolidate into single summary
- Verbose output → Extract key points only
- Repetitive patterns → Document once with reference

**REMOVE** (in aggressive mode):
- Completed actions older than last 5
- Detailed error messages (keep summary only)
- Duplicate information
- Non-critical context

### Step 3: Generate Compacted Context

Create a structured compacted context:

```markdown
## Compacted Context

**Time**: $(date '+%Y-%m-%d %H:%M:%S')
**Compaction Level**: [aggressive|conservative|standard]
**Original Size**: ~[X] lines
**Compacted Size**: ~[Y] lines

### Current Task
[1-2 lines about what we're doing]

### Recent Actions (Last 5)
1. [Most recent action]
2. [Previous action]
3. [Older action]
4. [Older action]
5. [Oldest recent action]

### Current State
- **File**: [current file if editing]
- **Status**: [working|blocked|waiting|complete]
- **Pending**: [any pending decisions or user input needed]

### Key Context
[Brief summary of critical context needed to continue]

### Next Steps
1. [Immediate next action]
2. [Following action]
```

### Step 4: Save Compacted Context

Save the compacted context to a file:

```bash
mkdir -p ~/.claude/memory
cat > ~/.claude/memory/compacted-context.md <<'EOF'
[Insert compacted context here]
EOF
```

### Step 5: Output Continuation Prompt

After compaction, output a ready-to-use continuation prompt:

```
## Memory Compacted

Context reduced from [X] to [Y] lines ([Z]% reduction).

**Compacted Context**:
[Display compacted context]

**Next Action**: [Continue with the task]

**Approach**: Use the compacted context above. Do not re-explore files already analyzed.
```

## Integration with Auto Mode

When in autonomous mode (`/auto` active):
- The `autonomous-command-router.sh` will trigger `/compact` at 40% context threshold
- After compaction, it will automatically trigger `/checkpoint` to save progress
- This creates a seamless memory management cycle

## Workflow

User runs `/compact`:

1. **Analyze** - Assess current context size and usage
2. **Extract** - Preserve critical information
3. **Compress** - Remove redundant and non-essential content
4. **Save** - Store compacted context to memory
5. **Continue** - Provide continuation prompt for immediate use

## Guidelines

**Standard Mode (default)**:
- Target 50% context reduction
- Balance between detail and brevity
- Keep last 5 actions
- Preserve all code structure references

**Aggressive Mode**:
- Target 60% context reduction
- Maximum compression
- Keep last 3 actions only
- Summarize all code blocks to purpose only

**Conservative Mode**:
- Target 30% context reduction
- Preserve more detail
- Keep last 10 actions
- Keep code blocks for recently edited files

## When to Use

- **Manually**: When you notice context getting long (every 50-100 messages)
- **Automatically**: In `/auto` mode at 40% context threshold
- **Before checkpoint**: To ensure checkpoint contains optimized context
- **After long operations**: After completing complex tasks

## Example Output

```
## Memory Compacted

Context reduced from 247 to 124 lines (50% reduction).

**Compacted Context**:

## Compacted Context

**Time**: 2026-01-13 18:45:00
**Compaction Level**: standard
**Original Size**: ~247 lines
**Compacted Size**: ~124 lines

### Current Task
Implementing user authentication system with JWT tokens and refresh mechanism.

### Recent Actions (Last 5)
1. Created auth service with login/logout endpoints
2. Implemented JWT token generation and validation
3. Added refresh token storage in database
4. Created middleware for protected routes
5. Started implementing token refresh endpoint

### Current State
- **File**: src/auth/refresh.ts (in progress)
- **Status**: working
- **Pending**: Need to handle token rotation logic

### Key Context
- Using bcrypt for password hashing
- JWT secret stored in environment variables
- Refresh tokens expire in 7 days
- Access tokens expire in 15 minutes

### Next Steps
1. Complete token refresh endpoint implementation
2. Add error handling for expired refresh tokens
3. Write unit tests for auth service
4. Update documentation

**Next Action**: Complete the token refresh endpoint in src/auth/refresh.ts

**Approach**: Use the compacted context above. Continue implementing the refresh logic with proper error handling.
```
