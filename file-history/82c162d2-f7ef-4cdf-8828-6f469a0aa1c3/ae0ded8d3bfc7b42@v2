#!/bin/bash
# Claude Code Startup Script with Multi-Provider Proxy (v2)
# Handles authentication properly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
PROXY_SERVER="${CLAUDE_DIR}/model-proxy-server.js"
PROXY_PORT="${CLAUDISH_PORT:-3000}"
PROXY_PID_FILE="${CLAUDE_DIR}/.proxy.pid"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Check if proxy is already running
check_proxy_running() {
    if [ -f "$PROXY_PID_FILE" ]; then
        local pid=$(cat "$PROXY_PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            rm -f "$PROXY_PID_FILE"
            return 1
        fi
    fi
    return 1
}

# Start proxy server in background
start_proxy() {
    echo -e "${BLUE}Starting multi-provider proxy server...${NC}"

    if ! [ -f "$PROXY_SERVER" ]; then
        echo -e "${RED}Error: Proxy server not found at ${PROXY_SERVER}${NC}"
        exit 1
    fi

    # Start proxy in background
    node "$PROXY_SERVER" "$PROXY_PORT" > "${CLAUDE_DIR}/proxy.log" 2>&1 &
    local pid=$!
    echo "$pid" > "$PROXY_PID_FILE"

    # Wait for proxy to be ready
    echo -e "${YELLOW}Waiting for proxy to start...${NC}"
    local max_attempts=10
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${PROXY_PORT}/v1/messages" | grep -q "404\|400"; then
            echo -e "${GREEN}✓ Proxy server started on port ${PROXY_PORT}${NC}"
            return 0
        fi
        sleep 0.5
        attempt=$((attempt + 1))
    done

    echo -e "${RED}✗ Proxy server failed to start${NC}"
    echo -e "${YELLOW}Check logs: ${CLAUDE_DIR}/proxy.log${NC}"
    rm -f "$PROXY_PID_FILE"
    exit 1
}

# Stop proxy server
stop_proxy() {
    if [ -f "$PROXY_PID_FILE" ]; then
        local pid=$(cat "$PROXY_PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo -e "${YELLOW}Stopping proxy server (PID: ${pid})...${NC}"
            kill "$pid" 2>/dev/null || true
            sleep 1
            # Force kill if still running
            if ps -p "$pid" > /dev/null 2>&1; then
                kill -9 "$pid" 2>/dev/null || true
            fi
        fi
        rm -f "$PROXY_PID_FILE"
        echo -e "${GREEN}✓ Proxy server stopped${NC}"
    fi
}

# Cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}Cleaning up...${NC}"
    stop_proxy
}

# Register cleanup
trap cleanup EXIT INT TERM

# Check authentication
check_auth() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Authentication Check                                       ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo -e "${YELLOW}⚠  ANTHROPIC_API_KEY not set${NC}"
        echo ""
        echo -e "${BLUE}The proxy needs your Anthropic API key to forward requests.${NC}"
        echo -e "${BLUE}Claude Code's built-in auth doesn't work through proxies.${NC}"
        echo ""
        echo -e "${YELLOW}Options:${NC}"
        echo ""
        echo -e "${GREEN}1. Set API key for this session:${NC}"
        echo -e "   export ANTHROPIC_API_KEY='your-key-here'"
        echo -e "   $0"
        echo ""
        echo -e "${GREEN}2. Set permanently in ~/.zshrc:${NC}"
        echo -e "   echo 'export ANTHROPIC_API_KEY=\"your-key\"' >> ~/.zshrc"
        echo -e "   source ~/.zshrc"
        echo ""
        echo -e "${GREEN}3. Use proxy ONLY for other models (not Claude):${NC}"
        echo -e "   ${MAGENTA}# Start normal Claude Code (without proxy)${NC}"
        echo -e "   ${MAGENTA}claude${NC}"
        echo -e ""
        echo -e "   ${MAGENTA}# When you want to use GLM/Featherless:${NC}"
        echo -e "   ${MAGENTA}/model glm/glm-4${NC}"
        echo -e "   ${MAGENTA}(won't work - need to start with proxy)${NC}"
        echo ""
        echo -e "${BLUE}Get your API key: ${YELLOW}https://console.anthropic.com/settings/keys${NC}"
        echo ""
        read -p "Press Enter to continue anyway (Anthropic models won't work) or Ctrl+C to exit..."
    else
        echo -e "${GREEN}✓ ANTHROPIC_API_KEY is set${NC}"
        echo -e "${GREEN}  Key prefix: ${ANTHROPIC_API_KEY:0:20}...${NC}"
    fi
    echo ""
}

# Main
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Claude Code with Multi-Provider Proxy                      ║${NC}"
    echo -e "${BLUE}║   GLM · Featherless · Google · Anthropic                      ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Check authentication
    check_auth

    # Check if proxy is already running
    if check_proxy_running; then
        echo -e "${YELLOW}⚠ Proxy server already running (PID: $(cat $PROXY_PID_FILE))${NC}"
        echo -e "${YELLOW}Using existing proxy on port ${PROXY_PORT}${NC}"
        echo ""
    else
        start_proxy
        echo ""
    fi

    # Show available providers
    echo -e "${BLUE}Available Model Providers:${NC}"
    echo -e "  ${GREEN}glm/${NC}model-name          - GLM (ZhipuAI)"
    echo -e "  ${GREEN}featherless/${NC}model-name  - Featherless.ai (abliterated)"
    echo -e "  ${GREEN}google/${NC}model-name       - Google Gemini"
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        echo -e "  ${GREEN}claude-*${NC} or ${GREEN}anthropic/${NC}   - Anthropic (your API key)"
    else
        echo -e "  ${YELLOW}claude-*${NC} or ${YELLOW}anthropic/${NC}   - Anthropic (needs API key)"
    fi
    echo ""

    echo -e "${BLUE}Example commands in Claude Code:${NC}"
    echo -e "  ${YELLOW}/model glm/glm-4${NC}"
    echo -e "  ${YELLOW}/model featherless/Llama-3-8B-Instruct-abliterated${NC}"
    echo -e "  ${YELLOW}/model google/gemini-pro${NC}"
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        echo -e "  ${YELLOW}/model claude-sonnet-4-5${NC}"
    fi
    echo ""

    echo -e "${GREEN}Starting Claude Code...${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Start Claude Code with proxy
    ANTHROPIC_BASE_URL="http://127.0.0.1:${PROXY_PORT}" claude "$@"
}

# Parse arguments
case "${1:-}" in
    stop)
        stop_proxy
        exit 0
        ;;
    status)
        if check_proxy_running; then
            echo -e "${GREEN}✓ Proxy server is running (PID: $(cat $PROXY_PID_FILE))${NC}"
            echo -e "  Port: ${PROXY_PORT}"
            echo -e "  URL: http://127.0.0.1:${PROXY_PORT}"
            if [ -n "$ANTHROPIC_API_KEY" ]; then
                echo -e "  Anthropic auth: ${GREEN}✓ Configured${NC}"
            else
                echo -e "  Anthropic auth: ${YELLOW}⚠ Not configured${NC}"
            fi
        else
            echo -e "${RED}✗ Proxy server is not running${NC}"
        fi
        exit 0
        ;;
    help|--help|-h)
        cat <<EOF
${BLUE}Claude Code with Multi-Provider Proxy${NC}

${GREEN}Usage:${NC}
  $0 [command]

${GREEN}Commands:${NC}
  ${YELLOW}(none)${NC}   Start proxy and launch Claude Code
  ${YELLOW}stop${NC}     Stop the proxy server
  ${YELLOW}status${NC}   Check if proxy is running
  ${YELLOW}help${NC}     Show this help message

${GREEN}Authentication:${NC}
  Set ANTHROPIC_API_KEY in environment for Anthropic models:
  export ANTHROPIC_API_KEY="your-key-here"

${GREEN}Examples:${NC}
  $0              # Start Claude Code with proxy
  $0 stop         # Stop the proxy server
  $0 status       # Check proxy status

${GREEN}Model Switching in Claude Code:${NC}
  /model glm/glm-4
  /model featherless/Llama-3-8B-Instruct-abliterated
  /model google/gemini-pro
  /model claude-sonnet-4-5

${GREEN}Logs:${NC}
  Proxy logs: ~/.claude/proxy.log

EOF
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
