#!/bin/bash
# Custom command hook for clauded
# Adds /models command to show interactive picker

COMMAND="$1"
shift
ARGS="$@"

case "$COMMAND" in
  models)
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Available Models - Quick Shortcuts               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🚀 ONE-COMMAND SHORTCUTS (no typing, no wasted credits!):"
    echo ""
    echo "GLM (Free):"
    echo "  /glm              - GLM-4 (most capable)"
    echo "  /glm-flash        - GLM-4-Flash (fastest)"
    echo "  /glm-air          - GLM-4-Air (balanced)"
    echo ""
    echo "Featherless (Uncensored):"
    echo "  /featherless      - Llama-3-8B (abliterated)"
    echo "  /featherless-70b  - Llama-3-70B (larger, abliterated)"
    echo ""
    echo "Google:"
    echo "  /gemini           - Gemini Pro"
    echo "  /gemini-flash     - Gemini 2.0 Flash"
    echo ""
    echo "Anthropic:"
    echo "  /sonnet           - Claude Sonnet 4.5 (default)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Just type the shortcut command - switches instantly!"
    echo ""
    exit 0
    ;;
esac

# Let other commands pass through
exit 1
