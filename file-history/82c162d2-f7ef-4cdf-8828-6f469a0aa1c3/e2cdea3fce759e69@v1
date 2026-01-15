# Quick Reference: Small Context Models (8K-32K)

## Context Window Sizes

```
✅ Safe     : 128K+ (Gemini Pro, GLM-4, Qwen 2.5)
⚠️  Moderate: 32K   (Dolphin-3 24B)
❌ Small    : 8K    (Llama-3, WhiteRabbitNeo)
```

---

## Essential Commands

### Monitor Context Usage
```bash
/context              # Show token usage per MCP server
/mcp                  # Manage MCP servers
@server-name disable  # Disable specific server
```

### Clear Context
```bash
/clear    # Clear conversation history
/init     # Rebuild from CLAUDE.md
/compact  # Manual compaction
```

---

## Memory Keeper (Now Installed ✓)

### Save Important Context
```javascript
mcp_context_save({
  key: 'auth_strategy',
  value: 'Using JWT with 24h expiry, stored in httpOnly cookies',
  category: 'decision',
  priority: 'high'
})

mcp_context_save({
  key: 'db_schema',
  value: 'Users table has email, password_hash, created_at',
  category: 'architecture',
  priority: 'high'
})
```

### Retrieve Context
```javascript
// Get all high priority items
mcp_context_get({ priority: 'high' })

// Get by category
mcp_context_get({ category: 'decision' })

// Get specific key
mcp_context_get({ key: 'auth_strategy' })
```

### Categories
- `decision` - Architectural decisions
- `architecture` - System design
- `bug` - Known issues
- `task` - TODOs
- `learning` - Lessons learned

### Priorities
- `high` - Critical info (auth, security, core logic)
- `medium` - Important but not critical
- `low` - Nice to have

---

## Claude Context (Optional - Install for Code)

### Setup
```bash
# Get API keys first:
# - OpenAI: https://platform.openai.com/api-keys
# - Zilliz: https://cloud.zilliz.com/ (free tier)

bash /tmp/setup-context-management.sh
# Or manually:
# claude mcp add claude-context -e OPENAI_API_KEY=... -e MILVUS_TOKEN=... -- npx @zilliz/claude-context-mcp@latest
```

### Usage
```javascript
// Index codebase (do once per project)
index_codebase()

// Check status
get_indexing_status()

// Search code (instead of reading all files)
search_code("functions that handle user authentication")
search_code("React components that use useState")
search_code("API endpoints for payment processing")

// Clear index
clear_index()
```

### Benefits
- **40% token reduction** with same quality
- Load only relevant code chunks
- Natural language queries

---

## Context7 (Optional - Install for Libraries)

### Setup
```bash
# Get free key: https://context7.com/dashboard
bash /tmp/setup-context-management.sh
# Or: claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_KEY
```

### Usage
```
# Automatic when mentioning libraries
"Show me Next.js App Router server actions"
# Context7 fetches latest docs

# Explicit library reference
"Using /vercel/next.js, how do I implement middleware?"
"With /react/react, show me useEffect cleanup"
```

---

## Workflow for 8K Models (Llama-3, WhiteRabbitNeo)

### Session Start
```bash
1. Start clauded
   $ clauded

2. Switch to small model
   /model featherless/failspy/Meta-Llama-3-8B-Instruct-abliterated-v3

3. Check context usage
   /context

4. Disable heavy MCP servers if needed
   @chrome disable
   @github disable
   # Keep: memory-keeper, grep
```

### During Work
```javascript
// Save decisions immediately
mcp_context_save({
  key: 'approach',
  value: 'Using React Query for data fetching',
  priority: 'high'
})

// Use Grep MCP for code search (lightweight)
mcp__grep__search({
  query: "authentication patterns",
  language: "typescript"
})

// If have Claude Context:
search_code("auth functions")  // Instead of reading all files
```

### When Context Gets Full
```bash
1. Save important info to Memory Keeper first
   mcp_context_save({key: 'current_task', value: '...', priority: 'high'})

2. Clear conversation
   /clear

3. Retrieve saved context
   mcp_context_get({priority: 'high'})

4. Continue with fresh context
```

---

## Workflow for 32K Models (Dolphin-3)

### Session Start
```bash
1. Start clauded
   $ clauded

2. Switch to model
   /model featherless/dphn/Dolphin-Mistral-24B-Venice-Edition

3. Index codebase if using Claude Context
   index_codebase()
```

### During Work
```javascript
// Use Memory Keeper for long-term decisions
mcp_context_save({
  key: 'security_model',
  value: 'RBAC with role inheritance',
  category: 'architecture',
  priority: 'high'
})

// Use Claude Context for code search
search_code("authorization middleware")

// Use Context7 for library docs
"Using /express/express, show me middleware patterns"
```

### Monitor Context
```bash
# Check periodically
/context

# If approaching limit:
/clear
mcp_context_get({priority: 'high'})
```

---

## Best Practices

### DO ✅
- Save architectural decisions to Memory Keeper immediately
- Use search_code() instead of reading multiple files
- Disable unused MCP servers for small models
- Clear context between different tasks
- Use /context to monitor usage
- Retrieve only what you need from Memory Keeper

### DON'T ❌
- Don't load entire files when you need snippets
- Don't keep all MCP servers enabled on 8K models
- Don't ignore context warnings
- Don't lose important decisions during /clear

---

## Troubleshooting

### "Context window full" error
```bash
1. /context                          # See what's using tokens
2. @heavy-server disable             # Disable big MCP servers
3. mcp_context_save({...})           # Save important info
4. /clear                            # Clear conversation
5. mcp_context_get({priority: 'high'}) # Retrieve essentials
```

### Memory Keeper not working
```bash
# Check if installed
claude mcp list | grep memory-keeper

# If not found:
claude mcp add memory-keeper npx mcp-memory-keeper

# Check storage
ls -la ~/mcp-data/memory-keeper/
```

### Claude Context search not working
```bash
# Check if indexed
get_indexing_status()

# If not indexed:
index_codebase()

# If errors, check API keys in settings.json
```

---

## Environment Variables

```bash
# Add to ~/.zshrc or start command

# Limit MCP output (especially for small models)
export MAX_MCP_OUTPUT_TOKENS=5000    # For 8K models
export MAX_MCP_OUTPUT_TOKENS=10000   # For 32K models

# RAG chunk size (if using RAG MCP)
export CHUNK_SIZE=300                # Smaller for 8K models
export CHUNK_SIZE=500                # Default
```

---

## Quick Test

```bash
# Test Memory Keeper
/model featherless/failspy/Meta-Llama-3-8B-Instruct-abliterated-v3
mcp_context_save({key: 'test', value: 'Hello from small model!', priority: 'high'})
/clear
mcp_context_get({key: 'test'})
# Should return: "Hello from small model!"

# Test with long conversation
# ... have 50+ exchanges ...
mcp_context_get({priority: 'high'})
# Should still return all high-priority items
```

---

## Token Savings

| Approach | Tokens | Saving |
|----------|--------|--------|
| Read 10 files | ~50K | Baseline |
| search_code() | ~30K | 40% ✅ |
| Memory Keeper | ~5K | 90% ✅ |
| Context7 docs | ~10K | 80% ✅ |

**Result**: 8K models become viable for real work!

---

## Files

- Full guide: `~/.claude/CONTEXT_WINDOW_SOLUTIONS.md`
- Setup script: `/tmp/setup-context-management.sh`
- This reference: `~/.claude/SMALL_CONTEXT_QUICK_REFERENCE.md`

---

*Quick reference for 8K-32K context models*
*Memory Keeper now installed and ready to use!*
