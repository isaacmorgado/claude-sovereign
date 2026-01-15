#!/usr/bin/env python3
"""
Token Counter using tiktoken
Based on production patterns from langchain, openinterpreter, and LLM frameworks
"""

import sys
import json
from pathlib import Path

try:
    import tiktoken
    TIKTOKEN_AVAILABLE = True
except ImportError:
    TIKTOKEN_AVAILABLE = False
    print("Warning: tiktoken not installed. Install: pip install tiktoken", file=sys.stderr)

def get_encoder(model: str = "gpt-4"):
    """Get tiktoken encoder with fallback handling."""
    if not TIKTOKEN_AVAILABLE:
        return None

    try:
        # Try model-specific encoder (works for gpt-4, gpt-3.5-turbo, etc.)
        return tiktoken.encoding_for_model(model)
    except KeyError:
        # Fallback to cl100k_base (used by gpt-4, gpt-3.5-turbo-1106, etc.)
        try:
            return tiktoken.get_encoding("cl100k_base")
        except Exception:
            return None

def count_tokens(text: str, model: str = "gpt-4") -> int:
    """Count tokens in text using tiktoken."""
    if not TIKTOKEN_AVAILABLE:
        # Fallback estimation: ~1.33 tokens per word
        words = len(text.split())
        return int(words * 1.33)

    encoder = get_encoder(model)
    if encoder is None:
        # Fallback estimation
        words = len(text.split())
        return int(words * 1.33)

    try:
        return len(encoder.encode(text))
    except Exception as e:
        print(f"Error counting tokens: {e}", file=sys.stderr)
        # Fallback estimation
        words = len(text.split())
        return int(words * 1.33)

def count_tokens_from_file(file_path: str, model: str = "gpt-4") -> int:
    """Count tokens in a file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        return count_tokens(content, model)
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        return 0

def count_messages_tokens(messages: list, model: str = "gpt-4") -> dict:
    """
    Count tokens for message array (OpenAI format).
    Based on https://community.openai.com/t/how-to-calculate-the-tokens-when-using-function-call/266573
    """
    if not TIKTOKEN_AVAILABLE:
        # Fallback: count all message content
        total = 0
        for msg in messages:
            content = msg.get('content', '')
            total += count_tokens(content, model)
        return {
            'total_tokens': total,
            'messages': [{'tokens': count_tokens(m.get('content', ''), model)} for m in messages]
        }

    encoder = get_encoder(model)
    if encoder is None:
        return {'total_tokens': 0, 'messages': []}

    # Message overhead (ChatML format)
    # Every message has 3 tokens overhead
    # If message has 'name', it's -1 token
    tokens_per_message = 3
    tokens_per_name = -1 if model in ["gpt-3.5-turbo-0301", "gpt-4-0314"] else 1

    total_tokens = 0
    message_tokens = []

    for message in messages:
        msg_tokens = tokens_per_message

        # Count role
        role = message.get('role', 'user')
        msg_tokens += len(encoder.encode(role))

        # Count content
        content = message.get('content', '')
        if content:
            msg_tokens += len(encoder.encode(content))

        # Count name if present
        if 'name' in message:
            msg_tokens += tokens_per_name

        message_tokens.append({'tokens': msg_tokens, 'role': role})
        total_tokens += msg_tokens

    # Add 3 tokens for assistant reply priming
    total_tokens += 3

    return {
        'total_tokens': total_tokens,
        'messages': message_tokens,
        'overhead_per_message': tokens_per_message
    }

def prune_messages(messages: list, target_tokens: int, model: str = "gpt-4", preserve_recent: int = 2) -> dict:
    """
    Prune messages to fit within target token budget.
    Strategy: Preserve system message, user query, and last N messages. Remove oldest in middle.
    """
    if not messages:
        return {'messages': [], 'removed_count': 0, 'tokens_saved': 0}

    # Count tokens for all messages
    token_info = count_messages_tokens(messages, model)
    current_tokens = token_info['total_tokens']

    if current_tokens <= target_tokens:
        return {
            'messages': messages,
            'removed_count': 0,
            'tokens_saved': 0,
            'current_tokens': current_tokens
        }

    # Identify system message (always preserve)
    system_indices = [i for i, m in enumerate(messages) if m.get('role') == 'system']

    # Preserve system, first user message, and last N messages
    preserve_indices = set()
    if system_indices:
        preserve_indices.update(system_indices)

    # Preserve first user message
    for i, m in enumerate(messages):
        if m.get('role') == 'user':
            preserve_indices.add(i)
            break

    # Preserve last N messages
    preserve_indices.update(range(max(0, len(messages) - preserve_recent), len(messages)))

    # Remove messages from middle until under budget
    pruned_messages = []
    removed_count = 0
    tokens_saved = 0

    for i, msg in enumerate(messages):
        if i in preserve_indices:
            pruned_messages.append(msg)
        else:
            removed_count += 1
            tokens_saved += token_info['messages'][i]['tokens']

        # Check if we're under budget
        if current_tokens - tokens_saved <= target_tokens:
            # Add remaining preserved messages
            for j in range(i + 1, len(messages)):
                if j in preserve_indices:
                    pruned_messages.append(messages[j])
            break

    # Recount tokens
    final_tokens = count_messages_tokens(pruned_messages, model)['total_tokens']

    return {
        'messages': pruned_messages,
        'removed_count': removed_count,
        'tokens_saved': tokens_saved,
        'current_tokens': final_tokens,
        'target_tokens': target_tokens,
        'under_budget': final_tokens <= target_tokens
    }

def main():
    if len(sys.argv) < 2:
        print("Usage: token_counter.py <command> [args...]", file=sys.stderr)
        print("Commands: count, count_file, count_messages, prune_messages", file=sys.stderr)
        sys.exit(1)

    command = sys.argv[1]

    if command == "count":
        if len(sys.argv) < 3:
            print("Usage: token_counter.py count <text> [model]", file=sys.stderr)
            sys.exit(1)
        text = sys.argv[2]
        model = sys.argv[3] if len(sys.argv) > 3 else "gpt-4"
        tokens = count_tokens(text, model)
        print(json.dumps({'tokens': tokens, 'text_length': len(text)}))

    elif command == "count_file":
        if len(sys.argv) < 3:
            print("Usage: token_counter.py count_file <file_path> [model]", file=sys.stderr)
            sys.exit(1)
        file_path = sys.argv[2]
        model = sys.argv[3] if len(sys.argv) > 3 else "gpt-4"
        tokens = count_tokens_from_file(file_path, model)
        print(json.dumps({'tokens': tokens, 'file': file_path}))

    elif command == "count_messages":
        if len(sys.argv) < 3:
            print("Usage: token_counter.py count_messages <messages_json> [model]", file=sys.stderr)
            sys.exit(1)
        messages_json = sys.argv[2]
        model = sys.argv[3] if len(sys.argv) > 3 else "gpt-4"
        messages = json.loads(messages_json)
        result = count_messages_tokens(messages, model)
        print(json.dumps(result))

    elif command == "prune_messages":
        if len(sys.argv) < 4:
            print("Usage: token_counter.py prune_messages <messages_json> <target_tokens> [model] [preserve_recent]", file=sys.stderr)
            sys.exit(1)
        messages_json = sys.argv[2]
        target_tokens = int(sys.argv[3])
        model = sys.argv[4] if len(sys.argv) > 4 else "gpt-4"
        preserve_recent = int(sys.argv[5]) if len(sys.argv) > 5 else 2
        messages = json.loads(messages_json)
        result = prune_messages(messages, target_tokens, model, preserve_recent)
        print(json.dumps(result))

    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
