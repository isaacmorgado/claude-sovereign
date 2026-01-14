---
description: Research code patterns, solutions, and best practices
argument-hint: "<query> [options]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Task", "TodoWrite", "mcp__grep__searchGitHub"]
---

# Research Command

Research code patterns, solutions, and best practices using memory and GitHub code search.

## Usage

```bash
komplete research "<query>" [options]
```

### Options

- `--sources` - Sources to search (default: github,memory)
  - Available: `github`, `memory`, `web`
- `--limit` - Maximum number of results per source (default: 10)
- `--language` - Filter by programming language(s)
- `--verbose` - Enable verbose output

### Examples

```bash
# Basic usage
komplete research "React useEffect cleanup patterns"

# Specify sources
komplete research "authentication patterns" --sources github,memory

# Limit results
komplete research "error handling best practices" --limit 20

# Filter by language
komplete research "TypeScript type guards" --language typescript

# Verbose mode
komplete research "API design patterns" --verbose
```

## Research Sources

### Memory Search

Searches local memory for:
- Previous research results
- Bug fix patterns
- Successful approaches
- Code examples stored in memory

### GitHub Code Search

Uses GitHub MCP to search for:
- Code examples and patterns
- Similar implementations
- Best practices from popular repositories
- Solutions to common problems

### Web Search

Uses web search for:
- Documentation and tutorials
- Latest best practices
- Framework-specific guidance
- Community discussions

## What It Does

1. **Searches multiple sources** - Combines memory, GitHub, and web results
2. **Synthesizes findings** - LLM analyzes and summarizes results
3. **Records to memory** - Saves findings for future reference
4. **Provides actionable insights** - Gives recommendations based on research

## Integration

The research command integrates with:
- **Memory Manager** - Searches local memory for relevant information
- **GitHub MCP** - Searches GitHub repositories via [`mcp__grep__searchGitHub`](mcp__grep__searchGitHub)
- **LLM Router** - Provides AI assistance for synthesis and analysis

## When to Use

Use `/research` when:
- Learning new libraries or frameworks
- Finding code patterns and best practices
- Researching solutions to common problems
- Looking for examples before implementation
- Understanding unfamiliar codebases
- Need to gather information from multiple sources

## Best Practices

- **Be specific** - Focused queries return better results
- **Use multiple sources** - Memory and GitHub provide complementary information
- **Review results carefully** - Verify code quality and relevance
- **Filter by language** - Language-specific results are more applicable
- **Save useful findings** - Memory stores successful patterns for reuse

## Output

```
🔬 Researching: React useEffect cleanup patterns
Sources: github, memory

✓ Memory search: Found 3 relevant episodes
✓ GitHub search: Found 12 code examples
✓ Synthesis: Analyzing findings...

Research Summary:

Key Patterns:
  1. useEffect with cleanup functions is the recommended pattern
  2. Empty dependency arrays prevent stale closures
  3. AbortController pattern for async operations

Recommended Approaches:
  - Use cleanup function pattern for all useEffect hooks
  - Consider useReducer for complex state management
  - Test cleanup with React Testing Library

Related Episodes:
  - Previous useEffect cleanup task (2025-01-10)
  - Component lifecycle research (2025-01-08)

Research completed successfully
```

## Related Commands

- [`/auto`](auto.md) - Autonomous mode can use research for unfamiliar libraries
- [`/reflect`](reflect.md) - Use reflection to iterate on research findings
- [`/re`](re.md) - Reverse engineering can benefit from research phase

## Notes

- Research results are automatically saved to memory for future reference
- GitHub search requires GitHub MCP to be configured
- Memory search is always available and provides context-specific results
- The LLM synthesis step provides intelligent analysis combining all sources
- Use `--verbose` to see detailed search process and results
- Language filtering helps find relevant examples in your target language
