#!/bin/bash
# Multi-Agent Swarm Setup Script
# Installs dependencies and configures system for 2-100+ parallel agents

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="${SCRIPT_DIR}/../hooks"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║        Multi-Agent Swarm System - Setup                      ║"
echo "║                                                               ║"
echo "║  Features:                                                    ║"
echo "║  ✅ Git worktree isolation (TRUE parallel execution)          ║"
echo "║  ✅ LangGraph StateGraph coordination                         ║"
echo "║  ✅ Real-time dashboard (Flask)                               ║"
echo "║  ✅ 2-100+ parallel agents                                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check bash version
bash_major="${BASH_VERSION%%.*}"
if [[ "$bash_major" -lt 4 ]]; then
    echo "⚠️  Bash 3.x detected (found: $BASH_VERSION)"
    echo "   Bash 4+ recommended for best performance"
    echo "   Install: brew install bash (macOS)"
    echo "   Continuing with Bash 3 compatibility mode..."
else
    echo "✅ Bash $BASH_VERSION"
fi

# Check git
if ! command -v git &>/dev/null; then
    echo "❌ Git not found (required for worktree isolation)"
    exit 1
fi
echo "✅ Git $(git --version | awk '{print $3}')"

# Check jq
if command -v jq &>/dev/null; then
    echo "✅ jq $(jq --version | awk '{print $2}')"
else
    echo "⚠️  jq not found (optional, but highly recommended)"
    echo "   Install: brew install jq (macOS) or apt-get install jq (Linux)"
fi

# Check Python
if ! command -v python3 &>/dev/null; then
    echo "❌ Python3 not found (required for LangGraph coordinator)"
    exit 1
fi
echo "✅ Python $(python3 --version | awk '{print $2}')"

# Check pip
if ! command -v pip3 &>/dev/null; then
    echo "❌ pip3 not found (required for dependencies)"
    exit 1
fi
echo "✅ pip3 $(pip3 --version | awk '{print $2}')"

echo ""
echo "Installing Python dependencies..."

# Optional dependencies
OPTIONAL_DEPS=()

# Check LangGraph
if python3 -c "import langgraph" 2>/dev/null; then
    echo "✅ LangGraph already installed"
else
    echo "📦 Installing LangGraph..."
    OPTIONAL_DEPS+=("langgraph")
fi

# Check Flask
if python3 -c "import flask" 2>/dev/null; then
    echo "✅ Flask already installed"
else
    echo "📦 Installing Flask..."
    OPTIONAL_DEPS+=("flask")
fi

# Install optional dependencies
if [[ ${#OPTIONAL_DEPS[@]} -gt 0 ]]; then
    echo ""
    echo "Installing ${#OPTIONAL_DEPS[@]} packages..."
    pip3 install "${OPTIONAL_DEPS[@]}" --quiet
    echo "✅ Python dependencies installed"
fi

echo ""
echo "Verifying installation..."

# Verify swarm orchestrator
if [[ ! -f "${HOOKS_DIR}/swarm-orchestrator.sh" ]]; then
    echo "❌ swarm-orchestrator.sh not found at ${HOOKS_DIR}/swarm-orchestrator.sh"
    exit 1
fi
echo "✅ swarm-orchestrator.sh"

# Verify LangGraph coordinator
if [[ ! -f "${SCRIPT_DIR}/langgraph-coordinator.py" ]]; then
    echo "❌ langgraph-coordinator.py not found at ${SCRIPT_DIR}/langgraph-coordinator.py"
    exit 1
fi
echo "✅ langgraph-coordinator.py"

# Verify dashboard
if [[ ! -f "${SCRIPT_DIR}/dashboard.py" ]]; then
    echo "❌ dashboard.py not found at ${SCRIPT_DIR}/dashboard.py"
    exit 1
fi
echo "✅ dashboard.py"

# Make scripts executable
chmod +x "${HOOKS_DIR}/swarm-orchestrator.sh"
chmod +x "${SCRIPT_DIR}/langgraph-coordinator.py"
chmod +x "${SCRIPT_DIR}/dashboard.py"

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                 SETUP COMPLETE                                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Quick Start:"
echo ""
echo "1. Spawn a swarm (3-100 agents):"
echo "   ~/.claude/hooks/swarm-orchestrator.sh spawn 10 \"Your task here\""
echo ""
echo "2. Start dashboard (optional):"
echo "   ~/.claude/swarm/dashboard.py"
echo "   Open: http://localhost:5000"
echo ""
echo "3. Collect results:"
echo "   ~/.claude/hooks/swarm-orchestrator.sh collect"
echo ""
echo "Configuration:"
echo "  SWARM_MAX_AGENTS=100       # Max agents (default: 10)"
echo "  SWARM_COLLECT_TIMEOUT=30   # Result timeout in seconds"
echo ""
echo "Documentation:"
echo "  ~/.claude/hooks/swarm-orchestrator.sh help"
echo ""
echo "Testing:"
echo "  # Test with 3 agents"
echo "  ~/.claude/hooks/swarm-orchestrator.sh spawn 3 \"Test task\""
echo ""
echo "  # Test with 50 agents (requires git repo)"
echo "  cd ~/your-project"
echo "  ~/.claude/hooks/swarm-orchestrator.sh spawn 50 \"Comprehensive testing\""
echo ""
