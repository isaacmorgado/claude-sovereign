#!/bin/bash
# GLM Helper Script for Claude Code Integration
# Usage: ./glm-helper.sh [command] [options]

set -e

CLAUDE_DIR="${HOME}/.claude"
GLM_SERVER="${CLAUDE_DIR}/glm-proxy-server.js"
MCP_CONFIG="${CLAUDE_DIR}/mcp_servers.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_usage() {
    cat <<EOF
${BLUE}GLM Helper Script for Claude Code${NC}

${GREEN}Usage:${NC}
  ./glm-helper.sh [command] [options]

${GREEN}Commands:${NC}
  ${YELLOW}status${NC}        Check GLM integration status
  ${YELLOW}test${NC}          Test GLM server functionality
  ${YELLOW}enable${NC}        Enable GLM MCP server
  ${YELLOW}disable${NC}       Disable GLM MCP server
  ${YELLOW}logs${NC}          Show GLM server logs (if available)
  ${YELLOW}models${NC}        List available GLM models
  ${YELLOW}chat${NC}          Interactive chat with GLM
  ${YELLOW}help${NC}          Show this help message

${GREEN}Examples:${NC}
  ./glm-helper.sh status          # Check if GLM is configured
  ./glm-helper.sh test            # Test GLM connection
  ./glm-helper.sh models          # List available models
  ./glm-helper.sh chat            # Start interactive chat

${GREEN}Environment:${NC}
  GLM_API_KEY    Your GLM API key (set in mcp_servers.json)
  GLM_BASE_URL   GLM API endpoint (default: https://open.bigmodel.cn/api/paas/v4)

${GREEN}Integration:${NC}
  Use Claude Code's MCP tools to access GLM:
  - glm_chat: Chat with GLM models
  - glm_list_models: List available models

  Example in Claude Code:
    "Please use the glm_chat tool with glm-4 to explain quantum computing"

EOF
}

check_status() {
    echo -e "${BLUE}=== GLM Integration Status ===${NC}\n"

    # Check if server file exists
    if [ -f "$GLM_SERVER" ]; then
        echo -e "${GREEN}✓${NC} GLM proxy server found: ${GLM_SERVER}"
    else
        echo -e "${RED}✗${NC} GLM proxy server not found: ${GLM_SERVER}"
        return 1
    fi

    # Check if server is executable
    if [ -x "$GLM_SERVER" ]; then
        echo -e "${GREEN}✓${NC} Server is executable"
    else
        echo -e "${YELLOW}⚠${NC} Server is not executable (run: chmod +x ${GLM_SERVER})"
    fi

    # Check MCP configuration
    if [ -f "$MCP_CONFIG" ]; then
        echo -e "${GREEN}✓${NC} MCP configuration found: ${MCP_CONFIG}"

        if grep -q '"glm"' "$MCP_CONFIG"; then
            echo -e "${GREEN}✓${NC} GLM server is configured in MCP"

            # Check if disabled
            if jq -e '.mcpServers.glm.disabled // false' "$MCP_CONFIG" | grep -q true; then
                echo -e "${YELLOW}⚠${NC} GLM server is DISABLED"
            else
                echo -e "${GREEN}✓${NC} GLM server is ENABLED"
            fi
        else
            echo -e "${RED}✗${NC} GLM server not found in MCP configuration"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} MCP configuration not found"
        return 1
    fi

    # Check API key
    local api_key=$(jq -r '.mcpServers.glm.env.GLM_API_KEY // empty' "$MCP_CONFIG" 2>/dev/null)
    if [ -n "$api_key" ]; then
        echo -e "${GREEN}✓${NC} API key is configured (${api_key:0:20}...)"
    else
        echo -e "${RED}✗${NC} API key not configured"
        return 1
    fi

    echo -e "\n${GREEN}All checks passed!${NC}"
    echo -e "\n${BLUE}To use GLM in Claude Code:${NC}"
    echo -e "  Restart Claude Code if it's running"
    echo -e "  Use MCP tools: glm_chat, glm_list_models"
    echo -e "  Example: \"Use glm_chat to explain quantum computing\""
}

test_server() {
    echo -e "${BLUE}=== Testing GLM Server ===${NC}\n"

    if [ ! -f "$GLM_SERVER" ]; then
        echo -e "${RED}Error: GLM server not found${NC}"
        return 1
    fi

    echo -e "${YELLOW}Testing server initialization...${NC}"

    # Test with a simple request
    echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | node "$GLM_SERVER" 2>&1 &
    local pid=$!

    sleep 2

    if ps -p $pid > /dev/null; then
        echo -e "${GREEN}✓ Server started successfully${NC}"
        kill $pid 2>/dev/null || true
    else
        echo -e "${RED}✗ Server failed to start${NC}"
        return 1
    fi

    echo -e "\n${GREEN}Server test passed!${NC}"
}

enable_server() {
    echo -e "${BLUE}=== Enabling GLM Server ===${NC}\n"

    if [ ! -f "$MCP_CONFIG" ]; then
        echo -e "${RED}Error: MCP configuration not found${NC}"
        return 1
    fi

    # Remove disabled flag using jq
    jq 'del(.mcpServers.glm.disabled)' "$MCP_CONFIG" > "${MCP_CONFIG}.tmp" && mv "${MCP_CONFIG}.tmp" "$MCP_CONFIG"

    echo -e "${GREEN}✓ GLM server enabled${NC}"
    echo -e "${YELLOW}⚠ Please restart Claude Code for changes to take effect${NC}"
}

disable_server() {
    echo -e "${BLUE}=== Disabling GLM Server ===${NC}\n"

    if [ ! -f "$MCP_CONFIG" ]; then
        echo -e "${RED}Error: MCP configuration not found${NC}"
        return 1
    fi

    # Add disabled flag using jq
    jq '.mcpServers.glm.disabled = true' "$MCP_CONFIG" > "${MCP_CONFIG}.tmp" && mv "${MCP_CONFIG}.tmp" "$MCP_CONFIG"

    echo -e "${GREEN}✓ GLM server disabled${NC}"
    echo -e "${YELLOW}⚠ Please restart Claude Code for changes to take effect${NC}"
}

list_models() {
    echo -e "${BLUE}=== Available GLM Models ===${NC}\n"

    cat <<EOF
${GREEN}glm-4${NC}         - Most capable model (128K context)
${GREEN}glm-4-air${NC}     - Faster, cost-effective (128K context)
${GREEN}glm-4-airx${NC}    - Ultra-fast inference (8K context)
${GREEN}glm-4-flash${NC}   - Fastest response (128K context)
${GREEN}glm-3-turbo${NC}   - Legacy model (128K context)

${BLUE}Recommended:${NC}
  - General use: ${GREEN}glm-4${NC}
  - Speed: ${GREEN}glm-4-flash${NC}
  - Balance: ${GREEN}glm-4-air${NC}

${BLUE}Usage in Claude Code:${NC}
  "Use glm_chat with model glm-4 to explain quantum computing"

EOF
}

interactive_chat() {
    echo -e "${BLUE}=== GLM Interactive Chat ===${NC}"
    echo -e "${YELLOW}Type your messages (Ctrl+C to exit)${NC}\n"

    while true; do
        echo -ne "${GREEN}You:${NC} "
        read -r user_input

        if [ -z "$user_input" ]; then
            continue
        fi

        echo -e "${BLUE}GLM:${NC} (This would call GLM API via MCP)"
        echo -e "${YELLOW}Note: For full functionality, use this through Claude Code's MCP system${NC}\n"
    done
}

# Main script
case "${1:-help}" in
    status)
        check_status
        ;;
    test)
        test_server
        ;;
    enable)
        enable_server
        ;;
    disable)
        disable_server
        ;;
    models)
        list_models
        ;;
    chat)
        interactive_chat
        ;;
    help|--help|-h)
        print_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}\n"
        print_usage
        exit 1
        ;;
esac
