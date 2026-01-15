# Claude Code Memory Systems - Complete Architecture Guide

Based on research from: Generative Agents (Stanford), MemGPT/Letta, Mem0, LangChain, CrewAI, MetaGPT, SWE-agent

---

## Memory Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        MEMORY SYSTEM                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────┐    ┌─────────────────────────────────────┐   │
│  │  WORKING MEMORY     │    │  ACTION LOG                         │   │
│  │  (In-Context)       │    │  (Append-Only JSONL)                │   │
│  │                     │    │                                     │   │
│  │  • Current task     │    │  • Tool calls                       │   │
│  │  • Active context   │    │  • Edits/writes                     │   │
│  │  • Scratchpad       │    │  • Searches                         │   │
│  │  • Pending items    │    │  • Results                          │   │
│  └─────────────────────┘    └─────────────────────────────────────┘   │
│           │                              │                             │
│           ▼                              ▼                             │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                    EPISODIC MEMORY                               │  │
│  │                    (Past Experiences)                            │  │
│  │                                                                  │  │
│  │  • Task completions     • Error resolutions                     │  │
│  │  • Research findings    • Pattern discoveries                   │  │
│  │  • Importance scores    • Access counts                         │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│           │                                                            │
│           ▼ (Consolidation)                                           │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                    SEMANTIC MEMORY                               │  │
│  │                    (Facts & Patterns)                            │  │
│  │                                                                  │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │  │
│  │  │   FACTS     │  │  PATTERNS   │  │ PREFERENCES │             │  │
│  │  │ project/api │  │ error→fix   │  │ user prefs  │             │  │
│  │  │ tool/config │  │ workflow    │  │ style/fmt   │             │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘             │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│           │                                                            │
│           ▼ (Reflection)                                              │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                    REFLECTIONS                                   │  │
│  │                    (Meta-insights)                               │  │
│  │                                                                  │  │
│  │  • Session summaries    • Learned strategies                    │  │
│  │  • Error analyses       • Progress assessments                  │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Generative Agents Memory Model (Stanford)

The gold standard for cognitive memory in AI agents.

### Memory Stream Architecture

```python
# ConceptNode structure (from associative_memory.py)
class ConceptNode:
    node_id: str              # Unique identifier
    node_type: str            # "event", "thought", "chat"
    created: datetime         # When created
    expiration: datetime      # Default 30 days

    # Subject-Predicate-Object triple
    subject: str
    predicate: str
    object: str

    # For thought depth tracking
    depth: int                # How deep in reasoning chain

    # Importance scoring
    poignancy: float          # Emotional/importance score (0-1)

    # For retrieval
    embedding: List[float]    # Semantic embedding vector
    keywords: Set[str]        # For fast filtering

    # Usage tracking
    access_count: int
    last_accessed: datetime
```

### Three-Factor Retrieval Scoring

```python
def retrieve_memories(query: str, top_k: int = 10):
    """
    Combine recency, relevance, and importance for retrieval.
    Based on Generative Agents (Park et al., 2023)
    """
    query_embedding = embed(query)
    scores = []

    for node in memory_stream:
        # 1. Recency: exponential decay
        hours_ago = (now - node.last_accessed).hours
        recency = DECAY_RATE ** hours_ago  # default 0.995

        # 2. Relevance: semantic similarity
        relevance = cosine_similarity(query_embedding, node.embedding)

        # 3. Importance: pre-computed poignancy
        importance = node.poignancy

        # Normalize each dimension
        recency_norm = normalize_min_max(recency, all_recencies)
        relevance_norm = normalize_min_max(relevance, all_relevances)
        importance_norm = normalize_min_max(importance, all_importances)

        # Weighted combination (configurable)
        # Default: relevance > importance > recency
        score = (
            RECENCY_WEIGHT * recency_norm +      # 0.5
            RELEVANCE_WEIGHT * relevance_norm +   # 3.0
            IMPORTANCE_WEIGHT * importance_norm   # 2.0
        )
        scores.append((node, score))

    return sorted(scores, key=lambda x: -x[1])[:top_k]
```

### Reflection Mechanism

```python
def maybe_reflect():
    """
    Trigger reflection when importance accumulates past threshold.
    Creates higher-level insights from recent memories.
    """
    accumulated = sum(node.poignancy for node in recent_nodes)

    if accumulated >= REFLECTION_THRESHOLD:  # default: 150
        # 1. Generate focal points
        focal_points = generate_focal_points(recent_nodes, k=3)

        # 2. For each focal point, retrieve relevant memories
        for focal in focal_points:
            relevant = retrieve_memories(focal, top_k=100)

            # 3. Generate insight via LLM
            insight = llm.generate(
                f"What high-level insights can you infer from these memories "
                f"about {focal}?\n\n{format_memories(relevant)}"
            )

            # 4. Store as thought with evidence links
            store_thought(
                content=insight,
                evidence=[m.node_id for m in relevant[:5]],
                poignancy=calculate_importance(insight)
            )

        # Reset accumulator
        reset_importance_accumulator()
```

---

## 2. MemGPT/Letta Architecture

Hierarchical memory with explicit editing capabilities.

### Three-Tier Memory

```
┌─────────────────────────────────────────────────────────────┐
│                    CORE MEMORY                              │
│                    (In-Context, Editable)                   │
│                                                             │
│  ┌───────────────────┐  ┌────────────────────────────────┐ │
│  │    PERSONA        │  │         HUMAN                   │ │
│  │                   │  │                                 │ │
│  │  Agent identity,  │  │  User info, preferences,       │ │
│  │  personality,     │  │  context, relationship         │ │
│  │  capabilities     │  │  history                        │ │
│  │                   │  │                                 │ │
│  │  [2000 char max]  │  │  [2000 char max]               │ │
│  └───────────────────┘  └────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    RECALL MEMORY                            │
│                    (Conversation History)                   │
│                                                             │
│  Complete message history, searchable by message_id         │
│  Retrieved via conversation_search(query) tool              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   ARCHIVAL MEMORY                           │
│                   (Long-term Vector Store)                  │
│                                                             │
│  Unlimited storage, semantic search via embeddings          │
│  Retrieved via archival_memory_search(query) tool           │
│  Inserted via archival_memory_insert(content) tool          │
└─────────────────────────────────────────────────────────────┘
```

### Memory Block Schema

```python
class Block(BaseModel):
    """Core memory block with character limit enforcement."""

    value: str
    limit: int = 2000  # CORE_MEMORY_BLOCK_CHAR_LIMIT
    label: str         # "persona", "human", etc.
    read_only: bool = False

    @model_validator
    def validate_limit(cls, values):
        if len(values['value']) > values['limit']:
            raise ValueError(
                f"Block '{values['label']}' exceeds {values['limit']} "
                f"character limit ({len(values['value'])} chars)"
            )
        return values
```

### Summarization Trigger

```python
def summarize_messages_inplace():
    """
    Compress old messages when context exceeds threshold.
    """
    # Calculate where to cut
    token_count = count_tokens(messages)
    if token_count > MAX_CONTEXT_TOKENS:
        cutoff = find_cutoff_point(messages, target_tokens=MAX_CONTEXT_TOKENS * 0.7)

        # Summarize messages before cutoff
        old_messages = messages[:cutoff]
        summary = llm.summarize(old_messages)

        # Replace with summary
        messages = [
            SystemMessage(content=f"[Previous conversation summary]\n{summary}")
        ] + messages[cutoff:]
```

---

## 3. Mem0 Consolidation Pipeline

Production-ready memory with intelligent deduplication.

### Memory Actions

```python
class MemoryAction(Enum):
    ADD = "add"       # New unique memory
    UPDATE = "update" # Modify existing memory
    DELETE = "delete" # Remove outdated memory
    NONE = "none"     # No action needed
```

### Consolidation Pipeline

```python
def consolidate_memory(new_content: str) -> MemoryAction:
    """
    Intelligent memory consolidation with deduplication.
    """
    # 1. Extract facts from content
    facts = llm.extract_facts(new_content)

    for fact in facts:
        # 2. Embed and find similar existing memories
        embedding = embed(fact)
        similar = vector_store.search(embedding, top_k=5)

        # 3. Determine action via LLM
        action = llm.determine_action(
            new_fact=fact,
            existing_memories=similar,
            prompt="""
            Given this new fact and existing memories, determine:
            - ADD: if fact is new and unique
            - UPDATE: if fact updates existing memory (return memory_id)
            - DELETE: if fact contradicts/obsoletes existing (return memory_id)
            - NONE: if fact is duplicate or not worth storing
            """
        )

        # 4. Execute action
        if action.type == "ADD":
            vector_store.add(fact, embedding, metadata)
        elif action.type == "UPDATE":
            vector_store.update(action.memory_id, fact)
        elif action.type == "DELETE":
            vector_store.delete(action.memory_id)
```

### Scoring Formula

```python
def score_memory(memory, query):
    """Composite scoring for retrieval."""
    time_decay = 0.99 ** hours_since_created(memory)
    length_factor = min(len(memory.content) / 500, 1.0)
    relevance = keyword_overlap(query, memory.content)

    return 0.7 * time_decay * length_factor + 0.3 * relevance
```

---

## 4. File-Based Memory Patterns

### LangChain FileChatMessageHistory

```python
from pathlib import Path
import json

class FileChatMessageHistory:
    """Simple persistent chat history."""

    def __init__(self, file_path: str):
        self.file_path = Path(file_path)
        if not self.file_path.exists():
            self.file_path.write_text("[]")

    @property
    def messages(self) -> List[Message]:
        items = json.loads(self.file_path.read_text())
        return [Message.from_dict(item) for item in items]

    def add_message(self, message: Message) -> None:
        messages = self.messages + [message]
        self.file_path.write_text(json.dumps([m.to_dict() for m in messages]))

    def clear(self) -> None:
        self.file_path.write_text("[]")
```

### Session Factory Pattern

```python
def create_session_factory(base_dir: str):
    """Create per-user/session memory stores."""
    base_dir = Path(base_dir)
    base_dir.mkdir(parents=True, exist_ok=True)

    def get_history(session_id: str) -> FileChatMessageHistory:
        file_path = base_dir / f"{session_id}.json"
        return FileChatMessageHistory(str(file_path))

    return get_history
```

---

## 5. Vector Database Integration

### ChromaDB Pattern (Most Common)

```python
import chromadb
from chromadb.config import Settings

class ChromaMemory:
    def __init__(self, collection_name: str, persist_dir: str = "./chroma_db"):
        self.client = chromadb.PersistentClient(path=persist_dir)
        self.collection = self.client.get_or_create_collection(
            name=collection_name,
            metadata={"hnsw:space": "cosine"}
        )

    def add(self, content: str, metadata: dict = None):
        doc_id = f"mem_{int(time.time() * 1000)}"
        self.collection.add(
            documents=[content],
            ids=[doc_id],
            metadatas=[metadata or {}]
        )
        return doc_id

    def search(self, query: str, limit: int = 5):
        results = self.collection.query(
            query_texts=[query],
            n_results=limit
        )
        return results
```

### Qdrant Pattern

```python
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams

class QdrantMemory:
    def __init__(self, collection_name: str, url: str = "localhost:6333"):
        self.client = QdrantClient(url=url)
        self.collection_name = collection_name

        # Create collection if not exists
        self.client.recreate_collection(
            collection_name=collection_name,
            vectors_config=VectorParams(
                size=384,  # depends on embedding model
                distance=Distance.COSINE
            )
        )

    def store(self, content: str, embedding: List[float], metadata: dict):
        self.client.upsert(
            collection_name=self.collection_name,
            points=[{
                "id": str(uuid4()),
                "vector": embedding,
                "payload": {"content": content, **metadata}
            }]
        )

    def find(self, query_embedding: List[float], limit: int = 5):
        return self.client.search(
            collection_name=self.collection_name,
            query_vector=query_embedding,
            limit=limit
        )
```

---

## 6. MCP Memory Server Options

### Official Anthropic Server

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {
        "MEMORY_FILE_PATH": "~/.claude/memory/mcp-memory.jsonl"
      }
    }
  }
}
```

**Tools provided:**
- `create_entities` - Create new entities in knowledge graph
- `create_relations` - Create relations between entities
- `add_observations` - Add observations to entities
- `delete_entities` - Remove entities
- `delete_observations` - Remove observations
- `delete_relations` - Remove relations
- `read_graph` - Read entire knowledge graph
- `search_nodes` - Search for nodes
- `open_nodes` - Get specific nodes

### Mem0 MCP Server

```json
{
  "mcpServers": {
    "mem0": {
      "command": "npx",
      "args": ["-y", "mem0-mcp"],
      "env": {
        "MEM0_API_KEY": "your_api_key"
      }
    }
  }
}
```

### Qdrant MCP Server

```json
{
  "mcpServers": {
    "qdrant": {
      "command": "mcp-server-qdrant",
      "args": [
        "--qdrant-url", "http://localhost:6333",
        "--collection-name", "claude_memory"
      ]
    }
  }
}
```

**Tools provided:**
- `qdrant-store` - Store memory with embedding
- `qdrant-find` - Semantic search

### Basic Memory (Markdown + SQLite)

```json
{
  "mcpServers": {
    "basic-memory": {
      "command": "basic-memory",
      "args": ["serve"]
    }
  }
}
```

---

## 7. Integration with Claude Code Hooks

### Memory-Aware Agent Loop

```bash
# In agent-loop.sh, add memory retrieval before each task

retrieve_context() {
    local task="$1"

    # Get relevant memories
    local memories
    memories=$("$MEMORY_MANAGER" remember "$task" 5)

    # Get relevant patterns
    local patterns
    patterns=$("$MEMORY_MANAGER" find-patterns "$task" 3)

    # Format for context
    echo "## Relevant Past Experience"
    echo "$memories" | jq -r '.episodes[] | "- \(.description) (\(.outcome))"'

    echo ""
    echo "## Known Patterns"
    echo "$patterns" | jq -r '.[] | "- When: \(.trigger)\n  Do: \(.solution)"'
}

# After task completion
record_completion() {
    local task="$1"
    local outcome="$2"
    local details="$3"

    "$MEMORY_MANAGER" record task_complete "$task" "$outcome" "$details"

    # If learned something new, record pattern
    if [[ -n "$4" ]]; then
        "$MEMORY_MANAGER" add-pattern workflow "$task" "$4"
    fi
}
```

### Hook for Automatic Memory Recording

```bash
# ~/.claude/hooks/post-tool-call.sh

record_tool_call() {
    local tool="$1"
    local args="$2"
    local result="$3"

    # Log to action log
    "$MEMORY_MANAGER" log-action "$tool" "$args" "$result"

    # If error, record for learning
    if echo "$result" | grep -qi "error\|failed\|exception"; then
        "$MEMORY_MANAGER" record error_encountered \
            "Error in $tool" "failure" "$result"
    fi
}
```

---

## 8. Best Practices Summary

### Memory Hierarchy (3-tier)
1. **Working Memory**: Current task context, 50 items max
2. **Episodic Memory**: Past experiences, 1000 items max
3. **Semantic Memory**: Facts/patterns, 500 items max

### Retrieval Scoring (3-factor)
- **Recency**: Exponential decay (0.995^hours)
- **Relevance**: Semantic similarity (cosine)
- **Importance**: Pre-computed scores (0-1)
- **Weights**: Relevance (3) > Importance (2) > Recency (0.5)

### Consolidation Triggers
- Importance threshold exceeded
- Context token limit approaching
- Session boundary
- Explicit reflection request

### Storage Patterns
- JSON files for structured data
- JSONL for append-only logs
- Vector DB for semantic search
- SQLite for complex queries

### Data Retention
- Working memory: Current session only
- Episodic memory: 30 days default
- Semantic memory: Permanent until contradicted
- Action log: Infinite (with rotation)

---

## Quick Reference

```bash
# Working Memory
memory-manager.sh set-task "Implement feature X"
memory-manager.sh add-context "Uses React hooks" 8

# Record Experience
memory-manager.sh record task_complete "Implemented feature X" success "Used useState"

# Learn Pattern
memory-manager.sh add-pattern error_fix "TypeError: undefined" "Check null values first"

# Retrieve Context
memory-manager.sh remember "React hooks" 5
memory-manager.sh context

# Reflect
memory-manager.sh reflect progress "Completed 3 tasks today" "React patterns working well"
```
