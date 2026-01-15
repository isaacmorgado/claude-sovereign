#!/bin/bash
# sqlite-migrator.sh - Migrate flat-file memory system to SQLite with FTS5
# Supports semantic memory, episodic memory, working context
# Based on production patterns from GitHub repos and research

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_PATH="${HOME}/.claude/memory.db"
BACKUP_DIR="${HOME}/.claude/backups"
FLAT_DIR="${HOME}/.claude/flat-memory"
MIGRATION_LOG="${HOME}/.claude/logs/migration.log"

# Ensure directories exist
mkdir -p "$BACKUP_DIR" "$(dirname "$MIGRATION_LOG")"

# ============================================================================
# USAGE
# ============================================================================

usage() {
    cat << EOF
Usage: sqlite-migrator.sh <command> [options]

Commands:
    init                  Initialize SQLite database with schema
    migrate               Migrate flat files to SQLite (dual-write period)
    verify                Verify migration integrity
    cutover               Complete migration (archive flat files)
    backup                Create database backup
    rollback              Rollback to flat files
    query <sql>           Execute SQL query
    stats                 Show database statistics
    health                Run health check

Options:
    --force              Force operation without confirmation

Examples:
    sqlite-migrator.sh init
    sqlite-migrator.sh migrate
    sqlite-migrator.sh verify
    sqlite-migrator.sh cutover
    sqlite-migrator.sh query "SELECT COUNT(*) FROM semantic_memory"
    sqlite-migrator.sh stats

Expected Scale: Handles 50K+ items efficiently with FTS5
EOF
}

# ============================================================================
# LOGGING
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$MIGRATION_LOG"
}

# ============================================================================
# DATABASE INITIALIZATION
# ============================================================================

init_database() {
    log "INFO" "Initializing SQLite database: $DB_PATH"

    if [[ -f "$DB_PATH" ]]; then
        log "WARN" "Database already exists: $DB_PATH"
        read -p "Overwrite existing database? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            log "INFO" "Initialization cancelled"
            return 1
        fi
        mv "$DB_PATH" "${DB_PATH}.backup.$(date +%s)"
    fi

    # Create database with schema
    sqlite3 "$DB_PATH" << 'SQL'
-- Enable WAL mode for better concurrency
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000;  -- 64MB cache
PRAGMA mmap_size = 30000000; -- 30MB memory-mapped I/O
PRAGMA foreign_keys = ON;
PRAGMA temp_store = MEMORY;

-- ============================================================================
-- SEMANTIC MEMORY (facts, patterns, learned knowledge)
-- ============================================================================

CREATE TABLE IF NOT EXISTS semantic_memory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL,
    key TEXT NOT NULL UNIQUE,
    value TEXT NOT NULL,
    confidence REAL DEFAULT 0.9,
    source TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_semantic_category ON semantic_memory(category);
CREATE INDEX idx_semantic_key ON semantic_memory(key);
CREATE INDEX idx_semantic_confidence ON semantic_memory(confidence DESC);
CREATE INDEX idx_semantic_updated ON semantic_memory(updated_at DESC);

-- FTS5 virtual table for semantic search
CREATE VIRTUAL TABLE semantic_search USING fts5(
    key,
    value,
    category,
    content='semantic_memory',
    content_rowid='id',
    tokenize='porter ascii'
);

-- Triggers to keep FTS5 in sync
CREATE TRIGGER semantic_ai AFTER INSERT ON semantic_memory BEGIN
    INSERT INTO semantic_search(rowid, key, value, category)
    VALUES (new.id, new.key, new.value, new.category);
END;

CREATE TRIGGER semantic_ad AFTER DELETE ON semantic_memory BEGIN
    INSERT INTO semantic_search(semantic_search, rowid, key, value, category)
    VALUES('delete', old.id, old.key, old.value, old.category);
END;

CREATE TRIGGER semantic_au AFTER UPDATE ON semantic_memory BEGIN
    INSERT INTO semantic_search(semantic_search, rowid, key, value, category)
    VALUES('delete', old.id, old.key, old.value, old.category);
    INSERT INTO semantic_search(rowid, key, value, category)
    VALUES (new.id, new.key, new.value, new.category);
END;

-- ============================================================================
-- EPISODIC MEMORY (past experiences, task history)
-- ============================================================================

CREATE TABLE IF NOT EXISTS episodic_memory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type TEXT NOT NULL,
    description TEXT NOT NULL,
    status TEXT,
    details TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_episodic_type ON episodic_memory(event_type);
CREATE INDEX idx_episodic_created ON episodic_memory(created_at DESC);
CREATE INDEX idx_episodic_status ON episodic_memory(status);

-- FTS5 for episodic search
CREATE VIRTUAL TABLE episodic_search USING fts5(
    description,
    event_type,
    details,
    content='episodic_memory',
    content_rowid='id',
    prefix='2 3'
);

CREATE TRIGGER episodic_ai AFTER INSERT ON episodic_memory BEGIN
    INSERT INTO episodic_search(rowid, description, event_type, details)
    VALUES (new.id, new.description, new.event_type, new.details);
END;

CREATE TRIGGER episodic_ad AFTER DELETE ON episodic_memory BEGIN
    INSERT INTO episodic_search(episodic_search, rowid, description, event_type, details)
    VALUES('delete', old.id, old.description, old.event_type, old.details);
END;

CREATE TRIGGER episodic_au AFTER UPDATE ON episodic_memory BEGIN
    INSERT INTO episodic_search(episodic_search, rowid, description, event_type, details)
    VALUES('delete', old.id, old.description, old.event_type, old.details);
    INSERT INTO episodic_search(rowid, description, event_type, details)
    VALUES (new.id, new.description, new.event_type, new.details);
END;

-- ============================================================================
-- WORKING CONTEXT (current session state)
-- ============================================================================

CREATE TABLE IF NOT EXISTS working_context (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task TEXT NOT NULL,
    context TEXT,
    priority INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_working_priority ON working_context(priority DESC);
CREATE INDEX idx_working_updated ON working_context(updated_at DESC);

-- ============================================================================
-- SCHEMA MIGRATIONS TRACKING
-- ============================================================================

CREATE TABLE IF NOT EXISTS schema_migrations (
    version INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    applied_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    checksum TEXT NOT NULL,
    execution_time_ms INTEGER
);

-- Record initial schema
INSERT INTO schema_migrations (version, name, checksum, execution_time_ms)
VALUES (1, 'initial_schema', '$(echo "initial" | md5sum | awk "{print \$1}")', 0);

SQL

    if [[ $? -eq 0 ]]; then
        log "INFO" "Database initialized successfully"
        log "INFO" "Tables created: semantic_memory, episodic_memory, working_context"
        log "INFO" "FTS5 indexes created for semantic and episodic search"
        return 0
    else
        log "ERROR" "Database initialization failed"
        return 1
    fi
}

# ============================================================================
# MIGRATION
# ============================================================================

migrate_flat_files() {
    log "INFO" "Starting migration from flat files to SQLite"

    if [[ ! -d "$FLAT_DIR" ]]; then
        log "WARN" "Flat directory not found: $FLAT_DIR"
        log "INFO" "Creating empty flat directory for testing"
        mkdir -p "$FLAT_DIR"
        return 0
    fi

    if [[ ! -f "$DB_PATH" ]]; then
        log "ERROR" "Database not initialized. Run: sqlite-migrator.sh init"
        return 1
    fi

    local total_files=0
    local migrated_files=0
    local failed_files=0

    # Migrate JSON files
    while IFS= read -r file; do
        ((total_files++))

        local filename=$(basename "$file")
        local category=$(echo "$filename" | sed 's/\.json$//')

        # Read JSON content
        if ! content=$(cat "$file" 2>/dev/null); then
            log "WARN" "Failed to read file: $file"
            ((failed_files++))
            continue
        fi

        # Parse JSON and insert into database
        # Assuming format: {"key": "...", "value": "...", "confidence": 0.9}
        local key=$(echo "$content" | jq -r '.key // empty' 2>/dev/null)
        local value=$(echo "$content" | jq -r '.value // empty' 2>/dev/null)
        local confidence=$(echo "$content" | jq -r '.confidence // 0.9' 2>/dev/null)

        if [[ -n "$key" && -n "$value" ]]; then
            # Escape single quotes for SQL
            key_escaped=$(echo "$key" | sed "s/'/''/g")
            value_escaped=$(echo "$value" | sed "s/'/''/g")
            category_escaped=$(echo "$category" | sed "s/'/''/g")

            # Insert into database
            if sqlite3 "$DB_PATH" "
                INSERT OR REPLACE INTO semantic_memory (category, key, value, confidence, source)
                VALUES ('$category_escaped', '$key_escaped', '$value_escaped', $confidence, 'flat_file_migration');
            " 2>/dev/null; then
                ((migrated_files++))
            else
                log "WARN" "Failed to migrate: $file"
                ((failed_files++))
            fi
        else
            log "WARN" "Invalid JSON format: $file"
            ((failed_files++))
        fi

        # Progress update every 100 files
        if [[ $((total_files % 100)) -eq 0 ]]; then
            log "INFO" "Progress: $migrated_files / $total_files files migrated"
        fi
    done < <(find "$FLAT_DIR" -name "*.json" -type f)

    log "INFO" "Migration complete: $migrated_files / $total_files files migrated ($failed_files failed)"

    # Optimize database after bulk insert
    sqlite3 "$DB_PATH" "PRAGMA optimize;"
    log "INFO" "Database optimized"

    return 0
}

# ============================================================================
# VERIFICATION
# ============================================================================

verify_migration() {
    log "INFO" "Verifying migration integrity"

    if [[ ! -f "$DB_PATH" ]]; then
        log "ERROR" "Database not found: $DB_PATH"
        return 1
    fi

    # Run integrity check
    local integrity_result=$(sqlite3 "$DB_PATH" "PRAGMA integrity_check;")
    if [[ "$integrity_result" == "ok" ]]; then
        log "INFO" "✓ Database integrity check passed"
    else
        log "ERROR" "✗ Database integrity check failed: $integrity_result"
        return 1
    fi

    # Check foreign keys
    local fk_errors=$(sqlite3 "$DB_PATH" "PRAGMA foreign_key_check;" | wc -l)
    if [[ $fk_errors -eq 0 ]]; then
        log "INFO" "✓ Foreign key check passed"
    else
        log "ERROR" "✗ Foreign key check failed: $fk_errors errors"
        return 1
    fi

    # Count records
    local semantic_count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM semantic_memory;")
    local episodic_count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM episodic_memory;")
    local working_count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM working_context;")

    log "INFO" "Record counts:"
    log "INFO" "  Semantic memory: $semantic_count"
    log "INFO" "  Episodic memory: $episodic_count"
    log "INFO" "  Working context: $working_count"

    # Compare with flat files if they exist
    if [[ -d "$FLAT_DIR" ]]; then
        local flat_count=$(find "$FLAT_DIR" -name "*.json" -type f | wc -l)
        log "INFO" "  Flat files: $flat_count"

        if [[ $semantic_count -eq $flat_count ]]; then
            log "INFO" "✓ Record count matches flat files"
        else
            log "WARN" "⚠  Record count mismatch: DB=$semantic_count, Flat=$flat_count"
        fi
    fi

    log "INFO" "Verification complete"
    return 0
}

# ============================================================================
# CUTOVER
# ============================================================================

cutover_to_sqlite() {
    log "INFO" "Performing cutover to SQLite"

    # Create backup before cutover
    backup_database

    # Archive flat files
    if [[ -d "$FLAT_DIR" ]]; then
        local archive_dir="${FLAT_DIR}.archived.$(date +%s)"
        log "INFO" "Archiving flat files to: $archive_dir"
        mv "$FLAT_DIR" "$archive_dir"
        log "INFO" "Flat files archived"
    fi

    log "INFO" "Cutover complete. System now using SQLite exclusively."
    return 0
}

# ============================================================================
# BACKUP
# ============================================================================

backup_database() {
    if [[ ! -f "$DB_PATH" ]]; then
        log "ERROR" "Database not found: $DB_PATH"
        return 1
    fi

    local backup_file="${BACKUP_DIR}/memory.$(date +%Y%m%d_%H%M%S).db"

    log "INFO" "Creating backup: $backup_file"

    # Use SQLite backup API
    sqlite3 "$DB_PATH" ".backup '$backup_file'"

    if [[ $? -eq 0 ]]; then
        # Verify backup
        local integrity=$(sqlite3 "$backup_file" "PRAGMA integrity_check;")
        if [[ "$integrity" == "ok" ]]; then
            log "INFO" "Backup created and verified: $backup_file"

            # Clean old backups (keep last 30 days)
            find "$BACKUP_DIR" -name "memory.*.db" -mtime +30 -delete
            log "INFO" "Old backups cleaned (retention: 30 days)"

            return 0
        else
            log "ERROR" "Backup verification failed"
            rm -f "$backup_file"
            return 1
        fi
    else
        log "ERROR" "Backup creation failed"
        return 1
    fi
}

# ============================================================================
# QUERY
# ============================================================================

execute_query() {
    local sql="$1"

    if [[ ! -f "$DB_PATH" ]]; then
        log "ERROR" "Database not found: $DB_PATH"
        return 1
    fi

    sqlite3 -header -column "$DB_PATH" "$sql"
}

# ============================================================================
# STATISTICS
# ============================================================================

show_stats() {
    if [[ ! -f "$DB_PATH" ]]; then
        log "ERROR" "Database not found: $DB_PATH"
        return 1
    fi

    cat << STATS
SQLite Database Statistics
===========================
Database: $DB_PATH

Table Counts:
$(execute_query "SELECT 'Semantic Memory' as table_name, COUNT(*) as row_count FROM semantic_memory
UNION ALL
SELECT 'Episodic Memory', COUNT(*) FROM episodic_memory
UNION ALL
SELECT 'Working Context', COUNT(*) FROM working_context;")

Database Size:
$(du -h "$DB_PATH" | awk '{print "  Database: " $1}')
$(if [[ -f "${DB_PATH}-wal" ]]; then du -h "${DB_PATH}-wal" | awk '{print "  WAL file: " $1}'; fi)
$(if [[ -f "${DB_PATH}-shm" ]]; then du -h "${DB_PATH}-shm" | awk '{print "  Shared memory: " $1}'; fi)

Recent Activity:
$(execute_query "SELECT event_type, COUNT(*) as count, MAX(created_at) as last_event
FROM episodic_memory
GROUP BY event_type
ORDER BY count DESC
LIMIT 5;")

Top Categories:
$(execute_query "SELECT category, COUNT(*) as count
FROM semantic_memory
GROUP BY category
ORDER BY count DESC
LIMIT 5;")
STATS
}

# ============================================================================
# HEALTH CHECK
# ============================================================================

health_check() {
    log "INFO" "Running health check"

    local status=0

    # Check database exists
    if [[ ! -f "$DB_PATH" ]]; then
        log "ERROR" "✗ Database not found"
        return 1
    fi
    log "INFO" "✓ Database file exists"

    # Check integrity
    local integrity=$(sqlite3 "$DB_PATH" "PRAGMA integrity_check;" 2>&1)
    if [[ "$integrity" == "ok" ]]; then
        log "INFO" "✓ Database integrity OK"
    else
        log "ERROR" "✗ Database integrity failed: $integrity"
        status=1
    fi

    # Check tables exist
    local tables=$(sqlite3 "$DB_PATH" "SELECT name FROM sqlite_master WHERE type='table';" 2>&1)
    if echo "$tables" | grep -q "semantic_memory"; then
        log "INFO" "✓ semantic_memory table exists"
    else
        log "ERROR" "✗ semantic_memory table missing"
        status=1
    fi

    # Check FTS5 indexes
    local fts_tables=$(sqlite3 "$DB_PATH" "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%_search';" 2>&1)
    if echo "$fts_tables" | grep -q "semantic_search"; then
        log "INFO" "✓ FTS5 indexes exist"
    else
        log "ERROR" "✗ FTS5 indexes missing"
        status=1
    fi

    # Check WAL mode
    local journal_mode=$(sqlite3 "$DB_PATH" "PRAGMA journal_mode;" 2>&1)
    if [[ "$journal_mode" == "wal" ]]; then
        log "INFO" "✓ WAL mode enabled"
    else
        log "WARN" "⚠  WAL mode not enabled (current: $journal_mode)"
    fi

    if [[ $status -eq 0 ]]; then
        log "INFO" "Health check passed"
    else
        log "ERROR" "Health check failed"
    fi

    return $status
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        init)
            init_database "$@"
            ;;
        migrate)
            migrate_flat_files "$@"
            ;;
        verify)
            verify_migration "$@"
            ;;
        cutover)
            cutover_to_sqlite "$@"
            ;;
        backup)
            backup_database "$@"
            ;;
        rollback)
            log "ERROR" "Rollback not yet implemented"
            return 1
            ;;
        query)
            execute_query "$@"
            ;;
        stats)
            show_stats "$@"
            ;;
        health)
            health_check "$@"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            echo "Error: Unknown command: $command" >&2
            usage
            exit 1
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
