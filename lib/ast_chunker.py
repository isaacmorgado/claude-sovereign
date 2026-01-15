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
