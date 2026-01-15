#!/bin/bash
# Claude Code Startup Script with Multi-Provider Proxy
# Automatically starts the proxy server and launches Claude Code with it

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

# Main
main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Claude Code with Multi-Provider Proxy                      ║${NC}"
    echo -e "${BLUE}║   GLM · Featherless · Google · Anthropic                      ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

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
    echo -e "  ${GREEN}anthropic/${NC}model-name   - Native Anthropic"
    echo ""

    echo -e "${BLUE}Example commands in Claude Code:${NC}"
    echo -e "  ${YELLOW}/model glm/glm-4${NC}"
    echo -e "  ${YELLOW}/model featherless/Llama-3-8B-Instruct-abliterated${NC}"
    echo -e "  ${YELLOW}/model google/gemini-pro${NC}"
    echo -e "  ${YELLOW}/model anthropic/claude-opus-4-5${NC}"
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

${GREEN}Examples:${NC}
  $0              # Start Claude Code with proxy
  $0 stop         # Stop the proxy server
  $0 status       # Check proxy status

${GREEN}Environment Variables:${NC}
  CLAUDISH_PORT           Port for proxy server (default: 3000)
  GLM_API_KEY            Your GLM API key
  FEATHERLESS_API_KEY    Your Featherless API key
  GOOGLE_API_KEY         Your Google API key
  ANTHROPIC_API_KEY      Your Anthropic API key

${GREEN}Model Switching in Claude Code:${NC}
  /model glm/glm-4
  /model featherless/Llama-3-8B-Instruct-abliterated
  /model google/gemini-pro
  /model anthropic/claude-sonnet-4-5

${GREEN}Logs:${NC}
  Proxy logs: ~/.claude/proxy.log

EOF
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
