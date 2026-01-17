#!/usr/bin/env bash
# Claude Sovereign Installer
# Installs the 100% autonomous operation system for Claude Code

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# COMPATIBILITY CHECKS
# ============================================================================

# Check Bash version (3.2+ required for macOS compatibility)
BASH_MAJOR="${BASH_VERSION%%.*}"
BASH_MINOR="${BASH_VERSION#*.}"
BASH_MINOR="${BASH_MINOR%%.*}"

if [[ -z "$BASH_MAJOR" ]] || [[ "$BASH_MAJOR" -lt 3 ]]; then
    echo -e "${RED}Error: Bash 3.2+ required (found ${BASH_VERSION:-unknown})${NC}"
    echo "Please upgrade your bash installation."
    exit 1
fi

if [[ "$BASH_MAJOR" -eq 3 ]] && [[ "$BASH_MINOR" -lt 2 ]]; then
    echo -e "${RED}Error: Bash 3.2+ required (found $BASH_VERSION)${NC}"
    echo "Please upgrade your bash installation."
    exit 1
fi

# Check for jq (required for JSON processing in hooks)
JQ_AVAILABLE=true
if ! command -v jq &>/dev/null; then
    JQ_AVAILABLE=false
    echo -e "${YELLOW}Warning: jq not found - some features will be limited${NC}"
    echo "  Memory manager JSON operations will use fallbacks"
    echo "  Swarm orchestration may have reduced functionality"
    echo ""
    echo "  Install with:"
    echo "    macOS:  brew install jq"
    echo "    Ubuntu: sudo apt install jq"
    echo "    Fedora: sudo dnf install jq"
    echo ""
fi

# Check git version for worktree support (2.5+ required for swarms)
GIT_WORKTREE_SUPPORTED=true
if command -v git &>/dev/null; then
    GIT_VERSION=$(git --version | sed 's/git version //' | cut -d. -f1-2)
    GIT_MAJOR=$(echo "$GIT_VERSION" | cut -d. -f1)
    GIT_MINOR=$(echo "$GIT_VERSION" | cut -d. -f2)

    if [[ "$GIT_MAJOR" -lt 2 ]] || { [[ "$GIT_MAJOR" -eq 2 ]] && [[ "$GIT_MINOR" -lt 5 ]]; }; then
        GIT_WORKTREE_SUPPORTED=false
        echo -e "${YELLOW}Warning: Git 2.5+ required for swarm worktrees (found $GIT_VERSION)${NC}"
        echo "  Multi-agent swarms will run without git worktree isolation"
        echo "  Upgrade git for full swarm functionality"
        echo ""
    fi
else
    GIT_WORKTREE_SUPPORTED=false
    echo -e "${YELLOW}Warning: git not found${NC}"
    echo "  Version control features will not work"
    echo "  Install git for full functionality"
    echo ""
fi

# ============================================================================
# INSTALLATION
# ============================================================================

echo -e "${BLUE}"
cat << "EOF"
   ____ _                 _       ____                          _
  / ___| | __ _ _   _  __| | ___ / ___|  _____   _____ _ __ ___(_) __ _ _ __
 | |   | |/ _` | | | |/ _` |/ _ \\___ \ / _ \ \ / / _ \ '__/ _ \ |/ _` | '_ \
 | |___| | (_| | |_| | (_| |  __/___) | (_) \ V /  __/ | |  __/ | (_| | | | |
  \____|_|\__,_|\__,_|\__,_|\___|____/ \___/ \_/ \___|_|  \___|_|\__, |_| |_|
                                                                   |___/
  100% Autonomous AI Operation System
EOF
echo -e "${NC}"

echo ""
echo "======================================================================"
echo "  Installing Claude Sovereign..."
echo "======================================================================"
echo ""

# Check if Claude Code is installed
if [[ ! -d "${HOME}/.claude" ]]; then
    echo -e "${RED}Error: Claude Code not found at ~/.claude${NC}"
    echo "Please install Claude Code first: https://claude.ai/code"
    exit 1
fi

echo -e "${GREEN}✓${NC} Claude Code detected"

# Create directories
echo "Creating directories..."
mkdir -p ~/.claude/hooks
mkdir -p ~/.claude/commands
mkdir -p ~/.claude/docs
mkdir -p ~/.claude/logs
mkdir -p ~/.claude/cache

# Install hooks
echo "Installing hooks..."
cp -v hooks/* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
echo -e "${GREEN}✓${NC} Hooks installed and made executable"

# Install commands
echo "Installing commands..."
cp -v commands/* ~/.claude/commands/
echo -e "${GREEN}✓${NC} Commands installed"

# Install docs
echo "Installing documentation..."
cp -v docs/* ~/.claude/docs/
echo -e "${GREEN}✓${NC} Documentation installed"

# Backup existing CLAUDE.md if it exists
if [[ -f ~/.claude/CLAUDE.md ]]; then
    echo -e "${YELLOW}Warning: Existing CLAUDE.md found${NC}"
    BACKUP="~/.claude/CLAUDE.md.backup.$(date +%s)"
    cp ~/.claude/CLAUDE.md "$BACKUP"
    echo -e "${YELLOW}Backed up to: $BACKUP${NC}"
fi

# Install config
echo "Installing configuration..."
cp -v config/CLAUDE.md ~/.claude/CLAUDE.md
echo -e "${GREEN}✓${NC} Configuration installed"

# Validate installation
echo ""
echo "======================================================================"
echo "  Validating installation..."
echo "======================================================================"
echo ""

errors=0

# Check hooks
for hook in autonomous-command-router.sh auto-continue.sh memory-manager.sh project-navigator.sh; do
    if [[ -x ~/.claude/hooks/$hook ]]; then
        echo -e "${GREEN}✓${NC} $hook"
    else
        echo -e "${RED}✗${NC} $hook"
        errors=$((errors + 1))
    fi
done

# Check commands
for cmd in auto.md checkpoint.md; do
    if [[ -f ~/.claude/commands/$cmd ]]; then
        echo -e "${GREEN}✓${NC} $cmd"
    else
        echo -e "${RED}✗${NC} $cmd"
        errors=$((errors + 1))
    fi
done

# Check docs
if [[ -f ~/.claude/docs/100-PERCENT-HANDS-OFF-OPERATION.md ]]; then
    echo -e "${GREEN}✓${NC} Documentation"
else
    echo -e "${RED}✗${NC} Documentation"
    errors=$((errors + 1))
fi

echo ""

# Show compatibility summary
echo "======================================================================"
echo "  Compatibility Summary"
echo "======================================================================"
echo ""
echo -e "  Bash version:    ${GREEN}✓${NC} $BASH_VERSION (3.2+ required)"
if [[ "$JQ_AVAILABLE" == "true" ]]; then
    echo -e "  jq:              ${GREEN}✓${NC} installed"
else
    echo -e "  jq:              ${YELLOW}○${NC} not found (optional)"
fi
if [[ "$GIT_WORKTREE_SUPPORTED" == "true" ]]; then
    echo -e "  git worktrees:   ${GREEN}✓${NC} supported (git $GIT_VERSION)"
elif command -v git &>/dev/null; then
    echo -e "  git worktrees:   ${YELLOW}○${NC} git $GIT_VERSION (2.5+ recommended)"
else
    echo -e "  git worktrees:   ${YELLOW}○${NC} git not found"
fi
echo ""

if [[ $errors -eq 0 ]]; then
    echo -e "${GREEN}======================================================================"
    echo "  ✓ Installation successful!"
    echo "======================================================================${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Start autonomous mode:"
    echo "   ${BLUE}/auto${NC}"
    echo ""
    echo "2. Give Claude a task:"
    echo "   ${BLUE}\"Create a complete architecture document for...\"${NC}"
    echo ""
    echo "3. Walk away - Claude will:"
    echo "   • Work completely autonomously"
    echo "   • Auto-checkpoint at 40% context"
    echo "   • Auto-checkpoint after 10 files"
    echo "   • Push all changes to GitHub"
    echo "   • Continue until complete"
    echo ""
    echo "4. Stop anytime:"
    echo "   ${BLUE}/auto stop${NC}"
    echo ""
    echo "Documentation: ~/.claude/docs/100-PERCENT-HANDS-OFF-OPERATION.md"
    echo "Test suite: ~/.claude/hooks/comprehensive-validation.sh"
    echo ""
    echo -e "${GREEN}⚡ You now have a self-governing AI! ⚡${NC}"
    echo ""
else
    echo -e "${RED}======================================================================"
    echo "  ✗ Installation failed with $errors errors"
    echo "======================================================================${NC}"
    echo ""
    echo "Please check the errors above and try again."
    exit 1
fi
