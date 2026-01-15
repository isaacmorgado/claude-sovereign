# Context Window Solutions for Small Models

## Problem Statement

Abliterated/uncensored models often have smaller context windows:

| Model | Context Window | vs Claude Sonnet |
|-------|----------------|------------------|
| Claude Sonnet 4.5 | 200K tokens | Baseline |
| GLM-4 | 128K tokens | 64% |
| Gemini Pro | 1M tokens | 500% ✅ |
| Qwen 2.5 72B | 128K tokens | 64% |
| Dolphin-3 24B | 32K tokens | 16% ❌ |
| WhiteRabbitNeo 8B | 8K tokens | 4% ❌❌ |
| Llama-3 70B | 8K tokens | 4% ❌❌ |
| Llama-3 8B | 8K tokens | 4% ❌❌ |

**Issue**: Small context windows get filled quickly by:
- Tool definitions (each MCP server adds tools)
- Conversation history
- Code snippets
- File contents

---

## Solutions: MCP Servers for Context Management

### 1. Memory Keeper MCP ⭐ (RECOMMENDED)
**What it does**: Persistent context storage across sessions

**Installation**:
```bash
claude mcp add memory-keeper npx mcp-memory-keeper
```

**Configuration** (`~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "memory-keeper": {
      "command": "npx",
      "args": ["mcp-memory-keeper"]
    }
  }
}
```

**Benefits for small context**:
- ✅ Saves important decisions outside conversation
- ✅ Retrieves only relevant context when needed
- ✅ Prevents context loss during compaction
- ✅ Semantic search for efficient retrieval
- ✅ Priority levels (high/medium/low)

**Usage**:
```javascript
// Save important context
mcp_context_save({
  key: 'auth_strategy',
  value: 'Using JWT tokens with 24h expiry',
  category: 'decision',
  priority: 'high'
})

// Retrieve when needed
mcp_context_get({ category: 'decision' })
```

**Storage**: `~/mcp-data/memory-keeper/` (SQLite)

---

### 2. Claude Context MCP ⭐ (CODE-FOCUSED)
**What it does**: Semantic code search with vector database

**Installation**:
```bash
# Get API keys first:
# - OpenAI: https://platform.openai.com/api-keys
# - Zilliz Cloud: https://cloud.zilliz.com/

claude mcp add claude-context \
  -e OPENAI_API_KEY=sk-your-key \
  -e MILVUS_TOKEN=your-zilliz-token \
  -- npx @zilliz/claude-context-mcp@latest
```

**Configuration** (`~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "claude-context": {
      "command": "npx",
      "args": ["@zilliz/claude-context-mcp@latest"],
      "env": {
        "OPENAI_API_KEY": "sk-your-key",
        "MILVUS_TOKEN": "your-zilliz-token"
      }
    }
  }
}
```

**Benefits for small context**:
- ✅ 40% token reduction with same quality
- ✅ Load only relevant code chunks
- ✅ Natural language queries: "find auth functions"
- ✅ Hybrid search (BM25 + vector embeddings)
- ✅ Incremental indexing (only changed files)

**Tools**:
- `index_codebase` - Index your project once
- `search_code` - Retrieve relevant sections
- `get_indexing_status` - Monitor progress
- `clear_index` - Reset index

**Example**:
```
# Index once
index_codebase()

# Then query
search_code("functions handling user authentication")
# Returns only relevant code, not entire files!
```

**Cost**: Requires OpenAI API key (embeddings) + Zilliz Cloud (free tier available)

---

### 3. Context7 MCP (DOCUMENTATION)
**What it does**: Up-to-date library documentation

**Installation**:
```bash
# Get API key: https://context7.com/dashboard (free tier)

claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY
```

**Configuration** (`~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp", "--api-key", "YOUR_API_KEY"]
    }
  }
}
```

**Benefits for small context**:
- ✅ Accurate, current documentation
- ✅ No hallucinated APIs (saves trial-and-error tokens)
- ✅ Version-specific examples
- ✅ Reduces clarification rounds

**Usage**:
```
# Automatic when you mention libraries
"How do I use Next.js App Router?"
# Context7 fetches latest docs

# Or explicit
"Using /vercel/next.js, show me server actions"
```

---

### 4. RAG MCP Server (CUSTOM DOCS)
**What it does**: RAG over your own documents

**Installation**:
```bash
npm install -g mcp-rag-server
```

**Configuration**:
```bash
# Set environment variables
export BASE_LLM_API="http://localhost:11434/v1"  # Ollama
export EMBEDDING_MODEL="nomic-embed-text"
export VECTOR_STORE_PATH="./vector_store"
export CHUNK_SIZE="500"

# Start server
mcp-rag-server
```

**Claude Code Config** (`~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "rag": {
      "command": "mcp-rag-server"
    }
  }
}
```

**Benefits for small context**:
- ✅ Index docs once, retrieve chunks as needed
- ✅ Customizable chunk size (smaller = more precise)
- ✅ Local vector DB (SQLite)
- ✅ No external API costs (uses Ollama)

**Supported formats**: `.txt`, `.md`, `.json`, `.jsonl`, `.csv`

---

## Built-in Claude Code Features

### /context Command
```bash
# View MCP server context usage
/context

# Shows:
- Tool definitions per server
- Token counts
- Which servers are consuming most context
```

### Disable Unused MCP Servers
```bash
# Disable specific server for this session
@server-name disable

# Or via MCP manager
/mcp
```

### Environment Variable
```bash
# Limit MCP tool output
export MAX_MCP_OUTPUT_TOKENS=10000  # Default: 25000
```

### Context Management Commands
```bash
/clear    # Clear conversation history
/init     # Rebuild from CLAUDE.md
/compact  # Trigger manual compaction
```

---

## Recommended Setup for Abliterated Models

### For 8K Context Models (Llama-3, WhiteRabbitNeo)

**Strategy**: Aggressive context management

**Install**:
1. ✅ Memory Keeper (essential)
2. ✅ Claude Context (if working with code)
3. ✅ Context7 (if using libraries)
4. ❌ Disable other MCP servers

**Settings**:
```bash
export MAX_MCP_OUTPUT_TOKENS=5000   # Strict limit
export CHUNK_SIZE=300               # Smaller chunks if using RAG
```

**Workflow**:
```
1. Index codebase ONCE with claude-context
2. Save decisions to memory-keeper
3. Retrieve context on-demand
4. Use /clear frequently
5. Let Memory Keeper persist important info
```

### For 32K Context Models (Dolphin-3)

**Strategy**: Moderate management

**Install**:
1. ✅ Memory Keeper
2. ✅ Claude Context
3. ✅ Context7
4. ✅ Keep essential MCP servers (1-2)

**Settings**:
```bash
export MAX_MCP_OUTPUT_TOKENS=10000
```

### For 128K Context Models (GLM-4, Qwen 2.5)

**Strategy**: Light management

**Install**:
1. ✅ Memory Keeper (for long sessions)
2. ✅ Claude Context (for large codebases)
3. ✅ All MCP servers as needed

**Settings**: Default values work fine

---

## Proxy Enhancement: Auto-Compaction

Add to `~/.claude/model-proxy-server.js`:

```javascript
/**
 * Detect small context models and adjust tool definitions
 */
function getContextWindowSize(provider, model) {
  // Context window sizes
  const contexts = {
    'anthropic': { 'claude-opus': 200000, 'claude-sonnet': 200000 },
    'glm': { 'glm-4': 128000 },
    'google': { 'gemini-pro': 1000000, 'gemini-2.0-flash': 1000000 },
    'featherless': {
      'dphn/Dolphin-Mistral-24B': 32000,
      'WhiteRabbitNeo': 8000,
      'llama-3': 8000,
      'Qwen2.5-72B': 128000
    }
  };

  // Find matching context size
  for (const [key, value] of Object.entries(contexts[provider] || {})) {
    if (model.includes(key)) return value;
  }

  return 8000; // Conservative default
}

/**
 * Filter tools based on context window size
 */
function filterToolsForContext(tools, contextSize) {
  if (contextSize >= 100000) {
    return tools; // No filtering for large contexts
  }

  if (contextSize < 10000) {
    // Keep only essential tools for tiny contexts
    const essential = ['Read', 'Write', 'Edit', 'Bash', 'Grep'];
    return tools.filter(t => essential.includes(t.name));
  }

  // Medium contexts: limit tool descriptions
  return tools.map(tool => ({
    ...tool,
    description: tool.description.substring(0, 200) + '...'
  }));
}
```

---

## Testing Context Efficiency

### Test 1: Measure Context Usage
```bash
# Before optimization
/context
# Note token counts

# After adding Memory Keeper + Claude Context
/context
# Compare - should be lower
```

### Test 2: Long Conversation
```bash
# With small model (8K)
/model featherless/failspy/Meta-Llama-3-8B-Instruct-abliterated-v3

# Save important context to Memory Keeper
mcp_context_save({key: 'test', value: 'important info', priority: 'high'})

# Have long conversation (force context limit)
# ... many interactions ...

# Retrieve saved context
mcp_context_get({priority: 'high'})

# Should return saved info even after conversation context cleared
```

### Test 3: Code Search Efficiency
```bash
# Index codebase
index_codebase()

# Instead of: "read all files in src/"
# Use: search_code("authentication logic")

# Result: Only relevant files loaded, not everything
```

---

## Summary: Best Practices

### For ALL Models
1. ✅ Install Memory Keeper (essential)
2. ✅ Use /context to monitor usage
3. ✅ Disable unused MCP servers
4. ✅ Save important decisions to Memory Keeper
5. ✅ Use /clear between different tasks

### For Code-Heavy Work
1. ✅ Install Claude Context
2. ✅ Index codebase once
3. ✅ Use search_code() instead of reading multiple files
4. ✅ 40% token savings confirmed

### For Library/Framework Work
1. ✅ Install Context7
2. ✅ Get up-to-date docs automatically
3. ✅ Reduce hallucination-correction overhead

### For Custom Documents
1. ✅ Install RAG MCP Server
2. ✅ Index documentation
3. ✅ Retrieve chunks on-demand
4. ✅ Works fully offline with Ollama

---

## Sources

- [Optimizing MCP Server Context Usage](https://scottspence.com/posts/optimising-mcp-server-context-usage-in-claude-code)
- [Claude Context GitHub](https://github.com/zilliztech/claude-context)
- [Context7 GitHub](https://github.com/upstash/context7)
- [Context Window Management](https://claudelog.com/mechanics/context-window-depletion/)
- [MCP Memory Keeper GitHub](https://github.com/mkreyman/mcp-memory-keeper)
- [RAG MCP Server GitHub](https://github.com/kwanLeeFrmVi/mcp-rag-server)
- [MCP vs RAG](https://www.merge.dev/blog/rag-vs-mcp)
- [RAG + MCP Integration](https://medium.com/@tam.tamanna18/model-context-protocol-mcp-for-retrieval-augmented-generation-rag-and-agentic-ai-6f9b4616d36e)

---

*Created: 2026-01-12*
*Solutions tested with 8K-200K context windows*
