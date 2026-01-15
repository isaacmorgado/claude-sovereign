#!/bin/bash
# Install Claude Model Switcher and Clauded Wrapper
# Adds 'm' and 'clauded' commands to shell configuration

set -e

echo "Installing Claude Model Switcher and Clauded Wrapper..."
echo ""

# Determine shell config file
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    echo "⚠ Unknown shell. Please add alias manually:"
    echo "  alias m='~/.claude/scripts/claude-model-switcher.sh'"
    exit 1
fi

# Check if already installed
ALREADY_INSTALLED=0
if grep -q "claude-model-switcher.sh" "$SHELL_CONFIG" 2>/dev/null; then
    echo "✓ Model switcher already installed"
    ALREADY_INSTALLED=1
fi
if grep -q "clauded.sh" "$SHELL_CONFIG" 2>/dev/null; then
    echo "✓ Clauded wrapper already installed"
    ALREADY_INSTALLED=1
fi

if [ $ALREADY_INSTALLED -eq 1 ]; then
    echo ""
    echo "To use immediately: source $SHELL_CONFIG"
    echo "Or open a new terminal"
    exit 0
fi

# Add aliases to shell config
echo "" >> "$SHELL_CONFIG"
echo "# Claude Model Switcher and Clauded Wrapper (added $(date))" >> "$SHELL_CONFIG"
echo "alias m='~/.claude/scripts/claude-model-switcher.sh'" >> "$SHELL_CONFIG"
echo "alias clauded='~/.claude/scripts/clauded.sh'" >> "$SHELL_CONFIG"

echo "✓ Added 'm' and 'clauded' commands to $SHELL_CONFIG"
echo ""
echo "To use immediately, run:"
echo "  source $SHELL_CONFIG"
echo ""
echo "Commands:"
echo "  clauded               # Start Claude with GLM-4.7 (via proxy)"
echo "  clauded /auto         # Start autonomous mode with GLM"
echo "  m list                # See all 14 models"
echo "  m glm                 # Start Claude with GLM-4.7"
echo "  m dolphin             # Start with Dolphin (security)"
echo ""
echo "Note: 'claude' (regular) remains unchanged and uses Anthropic models only"
echo ""
