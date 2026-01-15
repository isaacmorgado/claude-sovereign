#!/bin/bash
# ast-chunker.sh - AST-Based Code Chunking using tree-sitter
# Intelligently chunks code files respecting semantic boundaries (functions, classes, blocks)
# Based on production patterns from supermemoryai/code-chunk and real-world implementations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_HELPER="${SCRIPT_DIR}/../lib/ast_chunker.py"
CACHE_DIR="${HOME}/.claude/cache/ast-chunks"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# ============================================================================
# USAGE
# ============================================================================

usage() {
    cat << EOF
Usage: ast-chunker.sh <command> [options]

Commands:
    chunk <file_path> [max_size]     Chunk a file using AST-based splitting
    batch <directory> [pattern]      Chunk all files matching pattern
    clear-cache                      Clear the chunk cache
    stats                            Show chunking statistics

Options:
    max_size: Maximum chunk size in characters (default: 1024)
    pattern:  File glob pattern (default: **/*.{py,js,ts,tsx})

Examples:
    ast-chunker.sh chunk src/main.py 2048
    ast-chunker.sh batch src/ "**/*.py"
    ast-chunker.sh stats

Expected Context Reduction: 15-20% compared to fixed-size chunking
Quality Improvement: +4.3 Recall@5 on RepoEval benchmark
EOF
}

# ============================================================================
# PYTHON HELPER INTEGRATION
# ============================================================================

ensure_python_helper() {
    if [[ ! -f "$PYTHON_HELPER" ]]; then
        echo "Installing AST chunker Python helper..." >&2
        cat > "$PYTHON_HELPER" << 'PYTHON_EOF'
#!/usr/bin/env python3
"""
AST-Based Code Chunker using tree-sitter
Implements split-then-merge algorithm from production systems
"""

import sys
import json
import hashlib
from pathlib import Path
from typing import List, Dict, Any, Tuple

try:
    from tree_sitter_languages import get_language, get_parser
    TREE_SITTER_AVAILABLE = True
except ImportError:
    TREE_SITTER_AVAILABLE = False
    print("Warning: tree-sitter-languages not installed. Install: pip install tree-sitter-languages", file=sys.stderr)

def get_language_from_extension(file_path: str) -> str:
    """Detect language from file extension."""
    ext_map = {
        '.py': 'python',
        '.js': 'javascript',
        '.ts': 'typescript',
        '.tsx': 'tsx',
        '.jsx': 'javascript',
        '.sh': 'bash',
        '.bash': 'bash',
        '.rs': 'rust',
        '.go': 'go',
        '.java': 'java',
        '.cpp': 'cpp',
        '.c': 'c',
        '.rb': 'ruby',
        '.php': 'php',
    }
    ext = Path(file_path).suffix.lower()
    return ext_map.get(ext, 'python')

def compute_file_hash(content: bytes) -> str:
    """Compute SHA-256 hash of file content."""
    return hashlib.sha256(content).hexdigest()

def split_then_merge_chunks(node, code: bytes, max_size: int, chunks: List[Dict]) -> None:
    """
    Split-then-merge algorithm from code-chunk production implementation.
    Phase 1: Split - traverse AST attempting to fit complete nodes
    Phase 2: Merge - greedily combine adjacent small chunks
    """
    # Get node text
    node_text = code[node.start_byte:node.end_byte]
    node_size = len(node_text)

    # If node fits in max_size, add it as a chunk
    if node_size <= max_size:
        chunks.append({
            'text': node_text.decode('utf-8', errors='ignore'),
            'start_line': node.start_point[0],
            'end_line': node.end_point[0],
            'type': node.type,
            'size': node_size
        })
        return

    # If node is too large, recursively process children
    if node.child_count > 0:
        for child in node.children:
            split_then_merge_chunks(child, code, max_size, chunks)
    else:
        # Leaf node too large - split by lines as fallback
        lines = node_text.decode('utf-8', errors='ignore').split('\n')
        current_chunk = []
        current_size = 0

        for line in lines:
            line_size = len(line) + 1  # +1 for newline
            if current_size + line_size > max_size and current_chunk:
                chunks.append({
                    'text': '\n'.join(current_chunk),
                    'start_line': node.start_point[0],
                    'end_line': node.start_point[0] + len(current_chunk),
                    'type': 'fallback_split',
                    'size': current_size
                })
                current_chunk = []
                current_size = 0

            current_chunk.append(line)
            current_size += line_size

        if current_chunk:
            chunks.append({
                'text': '\n'.join(current_chunk),
                'start_line': node.start_point[0],
                'end_line': node.start_point[0] + len(current_chunk),
                'type': 'fallback_split',
                'size': current_size
            })

def merge_small_chunks(chunks: List[Dict], max_size: int) -> List[Dict]:
    """
    Phase 2: Greedily merge adjacent small chunks to reduce fragmentation.
    Stops merging when approaching size limit.
    """
    if not chunks:
        return chunks

    merged = []
    current_merged = chunks[0].copy()

    for i in range(1, len(chunks)):
        chunk = chunks[i]
        combined_size = current_merged['size'] + chunk['size']

        # If combining would exceed max_size, finalize current and start new
        if combined_size > max_size:
            merged.append(current_merged)
            current_merged = chunk.copy()
        else:
            # Merge chunks
            current_merged['text'] += '\n' + chunk['text']
            current_merged['end_line'] = chunk['end_line']
            current_merged['size'] = combined_size
            current_merged['type'] = 'merged'

    # Add final chunk
    merged.append(current_merged)

    return merged

def extract_metadata(node, code: bytes) -> Dict[str, Any]:
    """Extract function signatures, imports, and scope chain."""
    metadata = {
        'imports': [],
        'functions': [],
        'classes': [],
        'scope_chain': []
    }

    def traverse(n, scope=[]):
        if n.type == 'import_statement' or n.type == 'import_from_statement':
            import_text = code[n.start_byte:n.end_byte].decode('utf-8', errors='ignore')
            metadata['imports'].append(import_text)

        elif n.type == 'function_definition':
            name_node = n.child_by_field_name('name')
            if name_node:
                func_name = code[name_node.start_byte:name_node.end_byte].decode('utf-8', errors='ignore')
                metadata['functions'].append({
                    'name': func_name,
                    'scope': ' > '.join(scope),
                    'line': n.start_point[0]
                })
                new_scope = scope + [func_name]
                for child in n.children:
                    traverse(child, new_scope)
                return

        elif n.type == 'class_definition':
            name_node = n.child_by_field_name('name')
            if name_node:
                class_name = code[name_node.start_byte:name_node.end_byte].decode('utf-8', errors='ignore')
                metadata['classes'].append({
                    'name': class_name,
                    'scope': ' > '.join(scope),
                    'line': n.start_point[0]
                })
                new_scope = scope + [class_name]
                for child in n.children:
                    traverse(child, new_scope)
                return

        # Traverse children
        for child in n.children:
            traverse(child, scope)

    traverse(node)
    return metadata

def chunk_file_ast(file_path: str, max_size: int = 1024) -> Dict[str, Any]:
    """
    Main chunking function using AST-based split-then-merge.
    Returns chunks with metadata for semantic search.
    """
    if not TREE_SITTER_AVAILABLE:
        return {
            'error': 'tree-sitter-languages not installed',
            'file': file_path,
            'chunks': []
        }

    try:
        # Read file
        with open(file_path, 'rb') as f:
            code = f.read()

        # Detect language
        language_name = get_language_from_extension(file_path)
        language = get_language(language_name)
        parser = get_parser(language_name)

        # Parse code
        tree = parser.parse(code)

        # Extract chunks using split-then-merge
        chunks = []
        split_then_merge_chunks(tree.root_node, code, max_size, chunks)

        # Merge small adjacent chunks
        merged_chunks = merge_small_chunks(chunks, max_size)

        # Extract metadata
        metadata = extract_metadata(tree.root_node, code)

        # Compute file hash for caching
        file_hash = compute_file_hash(code)

        return {
            'file': file_path,
            'language': language_name,
            'file_hash': file_hash,
            'total_size': len(code),
            'chunk_count': len(merged_chunks),
            'chunks': merged_chunks,
            'metadata': metadata,
            'avg_chunk_size': sum(c['size'] for c in merged_chunks) / len(merged_chunks) if merged_chunks else 0
        }

    except Exception as e:
        return {
            'error': str(e),
            'file': file_path,
            'chunks': []
        }

def main():
    if len(sys.argv) < 3:
        print("Usage: ast_chunker.py <file_path> <max_size>", file=sys.stderr)
        sys.exit(1)

    file_path = sys.argv[1]
    max_size = int(sys.argv[2])

    result = chunk_file_ast(file_path, max_size)
    print(json.dumps(result, indent=2))

if __name__ == '__main__':
    main()
PYTHON_EOF
        chmod +x "$PYTHON_HELPER"
    fi
}

# ============================================================================
# CHUNK COMMAND
# ============================================================================

chunk_file() {
    local file_path="$1"
    local max_size="${2:-1024}"

    if [[ ! -f "$file_path" ]]; then
        echo "Error: File not found: $file_path" >&2
        return 1
    fi

    # Check cache
    local file_hash=$(sha256sum "$file_path" | awk '{print $1}')
    local cache_file="${CACHE_DIR}/${file_hash}.json"

    if [[ -f "$cache_file" ]]; then
        # Return cached result
        cat "$cache_file"
        return 0
    fi

    # Ensure Python helper exists
    ensure_python_helper

    # Run chunking
    local result=$(python3 "$PYTHON_HELPER" "$file_path" "$max_size" 2>&1)

    if [[ $? -eq 0 ]]; then
        # Cache result
        echo "$result" > "$cache_file"
        echo "$result"
        return 0
    else
        echo "Error chunking file: $result" >&2
        return 1
    fi
}

# ============================================================================
# BATCH COMMAND
# ============================================================================

batch_chunk() {
    local directory="$1"
    local pattern="${2:-**/*.{py,js,ts,tsx}}"
    local max_size="${3:-1024}"

    if [[ ! -d "$directory" ]]; then
        echo "Error: Directory not found: $directory" >&2
        return 1
    fi

    local total_files=0
    local success_count=0
    local total_chunks=0
    local total_size=0
    local chunked_size=0

    # Find files matching pattern
    while IFS= read -r file; do
        ((total_files++))

        result=$(chunk_file "$file" "$max_size")
        if [[ $? -eq 0 ]]; then
            ((success_count++))

            # Extract statistics
            chunk_count=$(echo "$result" | jq -r '.chunk_count // 0')
            file_size=$(echo "$result" | jq -r '.total_size // 0')
            avg_chunk=$(echo "$result" | jq -r '.avg_chunk_size // 0')

            total_chunks=$((total_chunks + chunk_count))
            total_size=$((total_size + file_size))
            chunked_size=$((chunked_size + chunk_count * avg_chunk))

            echo "[✓] $file: $chunk_count chunks (avg: ${avg_chunk} chars)"
        else
            echo "[✗] $file: Failed"
        fi
    done < <(find "$directory" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.sh" \))

    # Summary
    local reduction_pct=0
    if [[ $total_size -gt 0 ]]; then
        reduction_pct=$(echo "scale=2; 100 - ($chunked_size * 100.0 / $total_size)" | bc)
    fi

    cat << SUMMARY

========================================
Batch Chunking Summary
========================================
Files processed:      $success_count / $total_files
Total chunks:         $total_chunks
Original size:        $total_size chars
Effective size:       $chunked_size chars
Context reduction:    ${reduction_pct}%
Average chunk size:   $(echo "scale=0; $chunked_size / $total_chunks" | bc 2>/dev/null || echo 0) chars
========================================
SUMMARY
}

# ============================================================================
# STATS COMMAND
# ============================================================================

show_stats() {
    local cache_files=$(find "$CACHE_DIR" -name "*.json" -type f)
    local total_cached=$(echo "$cache_files" | wc -l)

    if [[ $total_cached -eq 0 ]]; then
        echo "No cached chunks found."
        return 0
    fi

    echo "AST Chunking Statistics"
    echo "======================="
    echo "Cached files: $total_cached"
    echo ""
    echo "Recent chunks:"

    find "$CACHE_DIR" -name "*.json" -type f -mtime -7 | head -10 | while read -r cache_file; do
        local file_name=$(jq -r '.file' "$cache_file" 2>/dev/null || echo "unknown")
        local chunk_count=$(jq -r '.chunk_count' "$cache_file" 2>/dev/null || echo 0)
        local language=$(jq -r '.language' "$cache_file" 2>/dev/null || echo "unknown")

        echo "  - $(basename "$file_name") [$language]: $chunk_count chunks"
    done
}

# ============================================================================
# CLEAR CACHE
# ============================================================================

clear_cache() {
    rm -rf "$CACHE_DIR"/*
    echo "Cache cleared: $CACHE_DIR"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local command="${1:-help}"

    case "$command" in
        chunk)
            shift
            chunk_file "$@"
            ;;
        batch)
            shift
            batch_chunk "$@"
            ;;
        stats)
            show_stats
            ;;
        clear-cache)
            clear_cache
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
