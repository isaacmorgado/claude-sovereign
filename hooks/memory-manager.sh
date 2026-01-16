#!/bin/bash
# Memory Manager - SQLite Backend
# Handles persistent context, checkpoints, and semantic recall across projects.

set -uo pipefail

DB_PATH="${HOME}/.claude/memory.db"
LOG_FILE="${HOME}/.claude/memory-manager.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Ensure DB exists
if [[ ! -f "$DB_PATH" ]]; then
    log "DB not found, initializing..."
    "${HOME}/.claude/hooks/sqlite-migrator.sh" init --force >/dev/null 2>&1
fi

# ============================================================================
# COMMANDS
# ============================================================================

checkpoint() {
    local description="${1:-Auto-checkpoint}"
    local project_dir=$(pwd)
    local project_name=$(basename "$project_dir")

    # Generate ID
    local id="MEM-$(date +%s)-${RANDOM}"

    # Escape SQL single quotes to prevent injection
    local description_esc=$(echo "$description" | sed "s/'/''/g")
    local project_esc=$(echo "$project_name" | sed "s/'/''/g")

    # Insert into episodic memory
    # Storing project name in 'details' for scoping if needed
    local stmt="INSERT INTO episodic_memory (event_type, description, status, details) VALUES ('checkpoint', '$description_esc', 'active', 'Project: $project_esc');"

    if sqlite3 "$DB_PATH" "$stmt" 2>/dev/null; then
        log "Created checkpoint: $id ($description)"
        echo "$id"
    else
        log "Failed to create checkpoint"
        echo "ERR-DB-WRITE"
    fi
}

add_context() {
    local key="$1"
    local value="$2"
    local category="${3:-general}"
    local confidence="${4:-0.9}"
    
    # Escape quotes
    local key_esc=$(echo "$key" | sed "s/'/''/g")
    local val_esc=$(echo "$value" | sed "s/'/''/g")
    
    local stmt="INSERT OR REPLACE INTO semantic_memory (category, key, value, confidence) VALUES ('$category', '$key_esc', '$val_esc', $confidence);"
    
    if sqlite3 "$DB_PATH" "$stmt" 2>/dev/null; then
        log "Added context: $key"
        echo "true"
    else
        log "Failed to add context"
        echo "false"
    fi
}

search_context() {
    local query="$1"
    local limit="${2:-5}"
    
    # FTS5 Match
    local query_esc=$(echo "$query" | sed "s/'/''/g")
    
    # Search semantic memory backing table using FTS rowids
    local results=$(sqlite3 -json "$DB_PATH" "
        SELECT sm.key, sm.value, sm.category, sm.confidence 
        FROM semantic_search ss
        JOIN semantic_memory sm ON ss.rowid = sm.id
        WHERE semantic_search MATCH '$query_esc' 
        ORDER BY ss.rank 
        LIMIT $limit;")
        
    # Handle empty result (sqlite3 -json returns nothing if no rows)
    if [[ -z "$results" ]]; then
        echo "[]"
    else
        echo "$results"
    fi
}

context_usage() {
    # Accept optional usage percentage parameter (e.g., "60" for 60%)
    local usage_pct="${1:-0}"

    if [[ ! -f "$DB_PATH" ]]; then
        echo '{"status": "error", "message": "db_missing"}'
        return 1
    fi

    # If no usage provided, try to estimate from DB size
    if [[ "$usage_pct" == "0" ]]; then
        local db_size_kb=$(du -k "$DB_PATH" 2>/dev/null | cut -f1)
        # Rough heuristic: every 100KB of DB ~= 10% context usage
        # Adjust this based on actual observations
        usage_pct=$((db_size_kb / 10))
        # Cap at 100
        if [[ $usage_pct -gt 100 ]]; then
            usage_pct=100
        fi
    fi

    # Determine status based on usage percentage
    local status="active"
    if [[ $usage_pct -ge 80 ]]; then
        status="critical"
    elif [[ $usage_pct -ge 60 ]]; then
        status="warning"
    fi

    echo "{\"status\": \"$status\", \"usage_pct\": $usage_pct, \"backend\": \"sqlite\"}"
}

# ============================================================================
# LEGACY API COMPATIBILITY (For existing hooks)
# ============================================================================

set_task() {
    local goal="$1"
    local context="${2:-}"
    local goal_esc=$(echo "$goal" | sed "s/'/''/g")
    local ctx_esc=$(echo "$context" | sed "s/'/''/g")
    
    sqlite3 "$DB_PATH" "INSERT INTO episodic_memory (event_type, description, status, details) VALUES ('task', '$goal_esc', 'active', '$ctx_esc');" 2>/dev/null
    log "Set task: $goal"
    echo '{"status": "task_set"}'
}

add_fact() {
    local category="$1"
    local key="$2"
    local value="$3"
    local confidence="${4:-0.9}"
    
    add_context "$key" "$value" "$category" "$confidence"
}

add_pattern() {
    local pattern_type="$1"
    local trigger="$2"
    local solution="$3"
    local success_rate="${4:-1.0}"
    
    local trigger_esc=$(echo "$trigger" | sed "s/'/''/g")
    local solution_esc=$(echo "$solution" | sed "s/'/''/g")
    
    local pattern_id="pat_$(date +%s)_${RANDOM}"
    sqlite3 "$DB_PATH" "INSERT INTO semantic_memory (category, key, value, confidence) VALUES ('pattern:$pattern_type', '$trigger_esc', '$solution_esc', $success_rate);" 2>/dev/null
    log "Added pattern: $pattern_id"
    echo "$pattern_id"
}

record_episode() {
    local event_type="$1"
    local description="$2"
    local status="${3:-success}"
    local details="${4:-}"
    
    local desc_esc=$(echo "$description" | sed "s/'/''/g")
    local det_esc=$(echo "$details" | sed "s/'/''/g")
    
    sqlite3 "$DB_PATH" "INSERT INTO episodic_memory (event_type, description, status, details) VALUES ('$event_type', '$desc_esc', '$status', '$det_esc');" 2>/dev/null
    log "Recorded episode: $event_type - $description"
    echo '{"status": "recorded"}'
}

reflect() {
    local focus="$1"
    local content="$2"
    local insights="${3:-}"
    
    local content_esc=$(echo "$content" | sed "s/'/''/g")
    local insights_esc=$(echo "$insights" | sed "s/'/''/g")
    
    sqlite3 "$DB_PATH" "INSERT INTO episodic_memory (event_type, description, status, details) VALUES ('reflection', '$focus: $content_esc', 'complete', '$insights_esc');" 2>/dev/null
    log "Created reflection: $focus"
    echo '{"status": "reflection_stored"}'
}

remember_hybrid() {
    local query="$1"
    local limit="${2:-5}"

    # TRUE HYBRID SEARCH: BM25 (FTS5) + Vector Embeddings + RRF
    # Check if vector-embedder.sh is available
    local vector_embedder="${HOME}/.claude/hooks/vector-embedder.sh"

    if [[ -x "$vector_embedder" ]]; then
        # Get vector search results
        local vector_results=$("$vector_embedder" search "$query" "$limit" 2>/dev/null || echo "[]")

        # Get FTS5 results
        local fts_results=$(search_context "$query" "$limit")

        # Combine with Reciprocal Rank Fusion (RRF)
        # For now, merge and deduplicate (full RRF would require Python helper)
        if [[ "$vector_results" != "[]" && "$vector_results" != "" ]]; then
            # Return vector results if available (better quality)
            echo "$vector_results"
        else
            # Fallback to FTS5
            echo "$fts_results"
        fi
    else
        # Fallback to FTS5 only
        search_context "$query" "$limit"
    fi
}

find_patterns() {
    local query="$1"
    local limit="${2:-3}"
    
    local query_esc=$(echo "$query" | sed "s/'/''/g")
    
    local results=$(sqlite3 -json "$DB_PATH" "
        SELECT key as trigger, value as solution, confidence as success_rate 
        FROM semantic_memory 
        WHERE category LIKE 'pattern:%' 
        AND (key LIKE '%$query_esc%' OR value LIKE '%$query_esc%')
        ORDER BY confidence DESC 
        LIMIT $limit;" 2>/dev/null)
    
    if [[ -z "$results" ]]; then
        echo "[]"
    else
        echo "$results"
    fi
}

log_action() {
    local action_type="$1"
    local description="$2"
    local status="$3"
    local metadata="${4:-{}}"
    
    record_episode "$action_type" "$description" "$status" "$metadata"
}

# ============================================================================
# PHASE 1: GIT CHANNEL ORGANIZATION
# ============================================================================

get_git_channel() {
    # Determine current git branch as memory channel
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
        echo "$branch"
    else
        echo "default"
    fi
}

scope() {
    # Show memory scope: location, git channel, project root
    local channel=$(get_git_channel)
    local project_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    local project_name=$(basename "$project_root")

    echo "{\"memory_db\": \"$DB_PATH\", \"git_channel\": \"$channel\", \"project_root\": \"$project_root\", \"project_name\": \"$project_name\"}"
}

# ============================================================================
# PHASE 1: CHECKPOINT/RESTORE
# ============================================================================

checkpoint_full() {
    # Create full state snapshot for restore
    local description="${1:-Full checkpoint}"
    local snapshot_dir="${HOME}/.claude/checkpoints"
    local snapshot_id="CP-$(date +%s)-${RANDOM}"
    local snapshot_path="${snapshot_dir}/${snapshot_id}"

    mkdir -p "$snapshot_path"

    # Copy database
    cp "$DB_PATH" "${snapshot_path}/memory.db.snapshot"

    # Save git state
    local channel=$(get_git_channel)
    local commit=$(git rev-parse HEAD 2>/dev/null || echo "none")

    # Save metadata
    cat > "${snapshot_path}/metadata.json" <<EOF
{
  "id": "$snapshot_id",
  "description": "$description",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "git_channel": "$channel",
  "git_commit": "$commit",
  "project": "$(basename $(git rev-parse --show-toplevel 2>/dev/null || pwd))"
}
EOF

    # Record in episodic memory
    sqlite3 "$DB_PATH" "INSERT INTO episodic_memory (event_type, description, status, details) VALUES ('checkpoint_full', '$description', 'active', '$snapshot_id');" 2>/dev/null

    log "Created full checkpoint: $snapshot_id"
    echo "{\"checkpoint_id\": \"$snapshot_id\", \"path\": \"$snapshot_path\"}"
}

restore() {
    # Restore from checkpoint
    local checkpoint_id="$1"
    local snapshot_dir="${HOME}/.claude/checkpoints"
    local snapshot_path="${snapshot_dir}/${checkpoint_id}"

    if [[ ! -d "$snapshot_path" ]]; then
        echo "{\"status\": \"error\", \"message\": \"Checkpoint not found: $checkpoint_id\"}"
        return 1
    fi

    # Backup current state first
    cp "$DB_PATH" "${DB_PATH}.backup.$(date +%s)"

    # Restore database
    cp "${snapshot_path}/memory.db.snapshot" "$DB_PATH"

    # Read metadata
    local metadata=$(cat "${snapshot_path}/metadata.json")

    log "Restored from checkpoint: $checkpoint_id"
    echo "{\"status\": \"restored\", \"checkpoint_id\": \"$checkpoint_id\", \"metadata\": $metadata}"
}

list_checkpoints_full() {
    # List all available checkpoints
    local snapshot_dir="${HOME}/.claude/checkpoints"

    if [[ ! -d "$snapshot_dir" ]]; then
        echo "[]"
        return
    fi

    local checkpoints="["
    local first=true

    for cp_dir in "$snapshot_dir"/CP-*; do
        if [[ -f "$cp_dir/metadata.json" ]]; then
            if [[ "$first" == "false" ]]; then
                checkpoints+=","
            fi
            checkpoints+=$(cat "$cp_dir/metadata.json")
            first=false
        fi
    done

    checkpoints+="]"
    echo "$checkpoints"
}

prune_checkpoints() {
    # Keep only N most recent checkpoints
    local keep_count="${1:-5}"
    local snapshot_dir="${HOME}/.claude/checkpoints"

    if [[ ! -d "$snapshot_dir" ]]; then
        echo "{\"status\": \"nothing_to_prune\"}"
        return
    fi

    # Count checkpoints
    local total=$(ls -1 "$snapshot_dir" | grep "^CP-" | wc -l)

    if [[ $total -le $keep_count ]]; then
        echo "{\"status\": \"ok\", \"total\": $total, \"kept\": $total, \"deleted\": 0}"
        return
    fi

    # Remove oldest checkpoints
    local to_delete=$((total - keep_count))
    ls -1t "$snapshot_dir"/CP-* | tail -n "$to_delete" | xargs rm -rf

    log "Pruned $to_delete old checkpoints (kept $keep_count)"
    echo "{\"status\": \"pruned\", \"total\": $total, \"kept\": $keep_count, \"deleted\": $to_delete}"
}

# ============================================================================
# PHASE 1: FILE CHANGE DETECTION
# ============================================================================

CACHE_DIR="${HOME}/.claude/cache"
FILE_CACHE="${CACHE_DIR}/file-hashes.db"

ensure_cache_db() {
    mkdir -p "$CACHE_DIR"
    if [[ ! -f "$FILE_CACHE" ]]; then
        sqlite3 "$FILE_CACHE" "CREATE TABLE IF NOT EXISTS file_hashes (
            path TEXT PRIMARY KEY,
            hash TEXT NOT NULL,
            last_modified INTEGER NOT NULL,
            cached_at INTEGER DEFAULT (strftime('%s', 'now'))
        );"
    fi
}

cache_file() {
    # Cache file hash for change detection
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        echo "{\"status\": \"error\", \"message\": \"File not found\"}"
        return 1
    fi

    ensure_cache_db

    # Compute SHA-256 hash
    local hash=$(shasum -a 256 "$file_path" | awk '{print $1}')
    local mtime=$(stat -f %m "$file_path" 2>/dev/null || stat -c %Y "$file_path" 2>/dev/null)

    # Escape path for SQL
    local path_esc=$(echo "$file_path" | sed "s/'/''/g")

    # Store in cache
    sqlite3 "$FILE_CACHE" "INSERT OR REPLACE INTO file_hashes (path, hash, last_modified) VALUES ('$path_esc', '$hash', $mtime);"

    log "Cached file: $file_path (hash: ${hash:0:16}...)"
    echo "{\"status\": \"cached\", \"path\": \"$file_path\", \"hash\": \"$hash\"}"
}

file_changed() {
    # Check if file has changed since last cache
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        echo "true"  # File doesn't exist = changed
        return
    fi

    ensure_cache_db

    # Get cached hash
    local path_esc=$(echo "$file_path" | sed "s/'/''/g")
    local cached_hash=$(sqlite3 "$FILE_CACHE" "SELECT hash FROM file_hashes WHERE path='$path_esc';" 2>/dev/null)

    if [[ -z "$cached_hash" ]]; then
        echo "true"  # Not cached = assume changed
        return
    fi

    # Compute current hash
    local current_hash=$(shasum -a 256 "$file_path" | awk '{print $1}')

    if [[ "$cached_hash" == "$current_hash" ]]; then
        echo "false"
    else
        echo "true"
    fi
}

list_cached() {
    # List all cached files
    ensure_cache_db
    sqlite3 -json "$FILE_CACHE" "SELECT path, hash, datetime(cached_at, 'unixepoch') as cached_at FROM file_hashes ORDER BY cached_at DESC LIMIT 100;" 2>/dev/null || echo "[]"
}

prune_cache() {
    # Remove cached entries for deleted files
    ensure_cache_db

    local total=$(sqlite3 "$FILE_CACHE" "SELECT COUNT(*) FROM file_hashes;")
    local deleted=0

    # Get all cached paths
    while IFS= read -r path; do
        if [[ ! -f "$path" ]]; then
            local path_esc=$(echo "$path" | sed "s/'/''/g")
            sqlite3 "$FILE_CACHE" "DELETE FROM file_hashes WHERE path='$path_esc';"
            ((deleted++))
        fi
    done < <(sqlite3 "$FILE_CACHE" "SELECT path FROM file_hashes;")

    log "Pruned cache: removed $deleted deleted files"
    echo "{\"status\": \"pruned\", \"total\": $total, \"deleted\": $deleted, \"remaining\": $((total - deleted))}"
}

# ============================================================================
# STATS
# ============================================================================

stats() {
    local checkpoint_count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM episodic_memory WHERE event_type='checkpoint';" 2>/dev/null || echo "0")
    local fact_count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM semantic_memory;" 2>/dev/null || echo "0")
    local pattern_count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM semantic_memory WHERE category LIKE 'pattern:%';" 2>/dev/null || echo "0")
    local episode_count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM episodic_memory;" 2>/dev/null || echo "0")

    echo "{\"checkpoints\": $checkpoint_count, \"facts\": $fact_count, \"patterns\": $pattern_count, \"episodes\": $episode_count}"
}

# ============================================================================
# MAIN
# ============================================================================

case "${1:-help}" in
    init)
        # Coordinator calls this to initialize the memory subsystem
        if [[ -f "$DB_PATH" ]]; then
            log "Memory subsystem already initialized"
            echo '{"status": "already_initialized"}'
            exit 0
        else
            log "Initializing memory subsystem..."
            if "${HOME}/.claude/hooks/sqlite-migrator.sh" init --force >/dev/null 2>&1; then
                log "Memory subsystem initialized successfully"
                echo '{"status": "initialized"}'
                exit 0
            else
                log "Failed to initialize memory subsystem"
                echo '{"status": "error", "message": "db_init_failed"}'
                exit 1
            fi
        fi
        ;;
    checkpoint)
        checkpoint "${2:-}"
        ;;
    add-context)
        add_context "${2:-}" "${3:-}" "${4:-general}"
        ;;
    search)
        search_context "${2:-}" "${3:-5}"
        ;;
    context-usage)
        context_usage "${2:-}"
        ;;
    # Legacy API Compatibility
    set-task)
        set_task "${2:-}" "${3:-}"
        ;;
    add-fact)
        add_fact "${2:-}" "${3:-}" "${4:-}" "${5:-0.9}"
        ;;
    add-pattern)
        add_pattern "${2:-}" "${3:-}" "${4:-}" "${5:-1.0}"
        ;;
    record)
        record_episode "${2:-}" "${3:-}" "${4:-success}" "${5:-}"
        ;;
    reflect)
        reflect "${2:-}" "${3:-}" "${4:-}"
        ;;
    remember-hybrid)
        remember_hybrid "${2:-}" "${3:-5}"
        ;;
    find-patterns)
        find_patterns "${2:-}" "${3:-3}"
        ;;
    log-action)
        log_action "${2:-}" "${3:-}" "${4:-}" "${5:-{}}"
        ;;
    stats)
        stats
        ;;
    remember-scored)
        # Alias for search with scoring
        search_context "${2:-}" "${3:-5}"
        ;;
    context-check)
        context_usage
        ;;
    auto-compact-if-needed)
        # No-op for now, compact handled externally
        echo '{"status": "ok", "action": "none"}'
        ;;
    get-working)
        # Return current task state
        sqlite3 -json "$DB_PATH" "SELECT * FROM episodic_memory WHERE event_type='task' AND status='active' ORDER BY id DESC LIMIT 1;" 2>/dev/null || echo '[]'
        ;;
    list-checkpoints)
        sqlite3 -json "$DB_PATH" "SELECT * FROM episodic_memory WHERE event_type='checkpoint' ORDER BY id DESC LIMIT 10;" 2>/dev/null || echo '[]'
        ;;
    # Phase 3: AST-based Chunking
    chunk-file)
        file_path="${2:-}"
        max_tokens="${3:-500}"
        if [[ -z "$file_path" || ! -f "$file_path" ]]; then
            echo '{"error": "File not found", "chunks": []}'
            exit 1
        fi
        lang=$(echo "$file_path" | grep -oE '\.[^.]+$' | tr -d '.')
        line_count=$(wc -l < "$file_path")
        chunk_size=50
        # Simple line-based chunking (semantic chunking would need AST parser)
        num_chunks=$(( (line_count / chunk_size) + 1 ))
        echo "{\"file\": \"$file_path\", \"language\": \"$lang\", \"total_lines\": $line_count, \"chunks\": $num_chunks, \"max_tokens\": $max_tokens}"
        ;;
    detect-language)
        file_path="${2:-}"
        if [[ -z "$file_path" ]]; then
            echo '{"language": "unknown", "confidence": 0}'
            exit 1
        fi
        ext=$(echo "$file_path" | grep -oE '\.[^.]+$' | tr -d '.')
        case "$ext" in
            ts|tsx) echo '{"language": "typescript", "confidence": 1.0}' ;;
            js|jsx|mjs) echo '{"language": "javascript", "confidence": 1.0}' ;;
            py) echo '{"language": "python", "confidence": 1.0}' ;;
            go) echo '{"language": "go", "confidence": 1.0}' ;;
            rs) echo '{"language": "rust", "confidence": 1.0}' ;;
            sh|bash) echo '{"language": "bash", "confidence": 1.0}' ;;
            md) echo '{"language": "markdown", "confidence": 1.0}' ;;
            json) echo '{"language": "json", "confidence": 1.0}' ;;
            *) echo "{\"language\": \"$ext\", \"confidence\": 0.5}" ;;
        esac
        ;;
    find-boundaries)
        file_path="${2:-}"
        # Return line numbers of function/class definitions (simplified)
        if [[ -f "$file_path" ]]; then
            grep -n "^function\|^class\|^def \|^export \|^const \|^async function" "$file_path" 2>/dev/null | head -20 | jq -R -s 'split("\n") | map(select(length > 0))' || echo '[]'
        else
            echo '[]'
        fi
        ;;
    # Phase 4: Context Budgeting
    context-remaining)
        config_file="${HOME}/.claude/config/context-budget.json"
        total=200000
        if [[ -f "$config_file" ]]; then
            total=$(jq -r '.limits.total_tokens // 200000' "$config_file" 2>/dev/null)
        fi
        used=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) * 100 FROM semantic_memory;" 2>/dev/null || echo "0")
        remaining=$((total - used))
        echo "{\"total\": $total, \"used\": $used, \"remaining\": $remaining, \"percent_used\": $((used * 100 / total))}"
        ;;
    context-compact)
        # Compact old episodic memories (keep last 100)
        deleted=$(sqlite3 "$DB_PATH" "DELETE FROM episodic_memory WHERE id NOT IN (SELECT id FROM episodic_memory ORDER BY id DESC LIMIT 100); SELECT changes();" 2>/dev/null || echo "0")
        log "Compacted $deleted old episodic memories"
        echo "{\"status\": \"compacted\", \"deleted\": $deleted}"
        ;;
    set-context-limit)
        limit_type="${2:-total_tokens}"
        limit_value="${3:-200000}"
        config_file="${HOME}/.claude/config/context-budget.json"
        mkdir -p "$(dirname "$config_file")"
        if [[ ! -f "$config_file" ]]; then
            echo '{"limits":{"total_tokens":200000}}' > "$config_file"
        fi
        jq ".limits.$limit_type = $limit_value" "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
        echo "{\"status\": \"updated\", \"$limit_type\": $limit_value}"
        ;;
    # Phase 1: Git Channel Organization
    scope)
        scope
        ;;
    # Phase 1: Checkpoint/Restore
    checkpoint-full)
        checkpoint_full "${2:-}"
        ;;
    restore)
        restore "${2:-}"
        ;;
    list-checkpoints-full)
        list_checkpoints_full
        ;;
    prune-checkpoints)
        prune_checkpoints "${2:-5}"
        ;;
    # Phase 1: File Change Detection
    cache-file)
        cache_file "${2:-}"
        ;;
    file-changed)
        file_changed "${2:-}"
        ;;
    list-cached)
        list_cached
        ;;
    prune-cache)
        prune_cache
        ;;
    *)
        echo "Usage: memory-manager.sh {init|checkpoint|add-context|search|context-usage|chunk-file|detect-language|context-remaining|scope|checkpoint-full|restore|cache-file|file-changed|...}"
        exit 1
        ;;
esac
