---
description: Search for code examples and error solutions using grep MCP and web search
argument-hint: "<query> [--error] [--examples] [--lang typescript|python|go|rust]"
allowed-tools: ["mcp__grep__searchGitHub", "WebSearch", "Read", "Write"]
---

# Research Command

Search for working code examples or error solutions from real codebases.

## Usage

```
/research useState loading       # Find React useState patterns with loading
/research --error "Cannot find module"   # Search for error solutions
/research --examples prisma transaction  # Find Prisma transaction examples
/research --lang python fastapi middleware  # Python-specific search
```

## Instructions

Parse arguments: $ARGUMENTS

Extract:
- `query`: The search terms
- `--error`: Flag indicating this is an error to solve
- `--examples`: Flag indicating we want code examples
- `--lang`: Language filter (typescript, python, go, rust, etc.)

### Mode 1: Code Examples (default or --examples)

Use the mcp__grep__searchGitHub tool to find real working code:

```
Search for: [query]
Language filter: [lang if specified]
```

**Search Strategy:**
1. First search for the exact pattern
2. If few results, try related patterns
3. Look for usage in tests (often clearest examples)

**For each result found:**
- Show the repository and file path
- Show the relevant code snippet
- Note any patterns or best practices observed

**Log to debug-log.md:**
```markdown
### Research: [query]
**Time**: [timestamp]
**Type**: Code examples
**Results**: [count] examples found
**Key patterns**:
- [Pattern 1 from results]
- [Pattern 2 from results]
```

### Mode 2: Error Solutions (--error)

**Step 1: Search GitHub for similar errors**
```
Use mcp__grep__searchGitHub to find:
- The exact error message
- Related error patterns
- Fix commits mentioning the error
```

**Step 2: If GitHub search insufficient, use WebSearch**
```
Search: "[error message]" solution OR fix OR resolve
Focus on: Stack Overflow, GitHub Issues, official docs
```

**Step 3: Synthesize solutions**
- List all potential fixes found
- Order by frequency/upvotes
- Note which solutions worked in similar contexts

**Log to debug-log.md:**
```markdown
### Error Research: [error message]
**Time**: [timestamp]
**Sources searched**:
- GitHub code: [count] results
- Web search: [sources]

**Potential solutions**:
1. [Solution 1] - Source: [where found]
2. [Solution 2] - Source: [where found]

**Recommended approach**: [most promising solution]
```

### Mode 3: Implementation Research

When researching how to implement a feature:

**Step 1: Search for similar implementations**
```
mcp__grep__searchGitHub:
- query: "[feature] implementation"
- language: [detected or specified]
```

**Step 2: Search for library usage**
```
mcp__grep__searchGitHub:
- query: "[library name]("
- language: [lang]
```

**Step 3: Search for patterns in test files**
```
mcp__grep__searchGitHub:
- query: "[feature]"
- path: "test" or "*test*" or "*spec*"
```

### Output Format

```markdown
## Research Results: [query]

### Code Examples Found

**1. [repo/path]**
```[lang]
[code snippet]
```
*Pattern*: [what this demonstrates]

**2. [repo/path]**
```[lang]
[code snippet]
```
*Pattern*: [what this demonstrates]

### Key Takeaways
- [Pattern 1 to follow]
- [Pattern 2 to follow]
- [Anti-pattern to avoid]

### Recommended Implementation
Based on [X] examples reviewed:
1. [Step 1]
2. [Step 2]
3. [Step 3]
```

### Integration with /build

When /build encounters something to implement:
1. Auto-run `/research --examples [feature] --lang [project-lang]`
2. Use found patterns to guide implementation
3. Log research to debug-log.md

When /build encounters an error:
1. Auto-run `/research --error "[error message]"`
2. Try solutions in order
3. Log each attempt to debug-log.md
