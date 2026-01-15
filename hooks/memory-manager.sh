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
    
    # Insert into episodic memory
    # Storing project name in 'details' for scoping if needed
    local stmt="INSERT INTO episodic_memory (event_type, description, status, details) VALUES ('checkpoint', '$description', 'active', 'Project: $project_name');"
    
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
    # Lightweight check
    if [[ -f "$DB_PATH" ]]; then
        echo '{"status": "active", "backend": "sqlite"}'
    else
        echo '{"status": "error", "message": "db_missing"}'
    fi
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
    
    # For now, just use FTS search (hybrid would require embeddings)
    search_context "$query" "$limit"
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
        context_usage
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
    *)
        echo "Usage: memory-manager.sh {init|checkpoint|add-context|search|context-usage|chunk-file|detect-language|context-remaining|...}"
        exit 1
        ;;
esac
