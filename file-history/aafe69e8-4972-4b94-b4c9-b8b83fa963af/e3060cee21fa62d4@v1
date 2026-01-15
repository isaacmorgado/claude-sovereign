#!/bin/bash
# Claude Sovereign Installer
# Installs the 100% autonomous operation system for Claude Code

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
