#!/bin/bash
# RE Tool Auto-Detector
# Automatically detects when RE tools should be used based on task patterns
# Integrates with coordinator.sh for autonomous tool selection

set -uo pipefail

DETECTION_LOG="${HOME}/.claude/logs/re-tool-detection.log"
DETECTION_PATTERNS_DOC="${HOME}/.claude/docs/rag-system/re-tool-detection.md"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$DETECTION_LOG"
}

# Detect RE tool from task description and context
detect() {
    local task="$1"
    local context="${2:-}"
    local files="${3:-}"  # JSON array of files in context

    local task_lower
    task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Parse files array if provided (compatible with bash 3.2+ on macOS)
    local file_extensions=""
    if [[ -n "$files" && "$files" != "[]" ]]; then
        file_extensions=$(echo "$files" | jq -r '.[] // empty' 2>/dev/null || echo "")
    fi

    # =========================
    # NETWORK & API DETECTION
    # =========================

    # mitmproxy
    if echo "$task_lower" | grep -qE "(intercept|capture traffic|proxy|https)"; then
        emit_detection "mitmproxy" 0.9 "mitmproxy -p 8080" \
            "~/.claude/commands/re.md#mitmproxy" \
            "Python HTTPS proxy for traffic interception"
        return 0
    fi

    # Kiterunner
    if echo "$task_lower" | grep -qE "(shadow api|hidden endpoints|api discovery|undocumented endpoints)"; then
        emit_detection "kiterunner" 0.95 "kr scan https://api.target.com -A apiroutes" \
            "~/.claude/commands/re.md#kiterunner" \
            "API fuzzer for discovering shadow/undocumented endpoints"
        return 0
    fi

    # Schemathesis/RESTler
    if echo "$task_lower" | grep -qE "(fuzz api|test api endpoints|openapi testing)"; then
        # Check for OpenAPI files
        if echo "$file_extensions" | grep -qE "(swagger\.json|openapi\.yaml|\.json)"; then
            emit_detection "schemathesis" 0.9 "schemathesis run spec.json" \
                "~/.claude/commands/research-api.md#schemathesis" \
                "OpenAPI/Swagger API testing and fuzzing"
            return 0
        fi
        emit_detection "restler" 0.85 "restler compile --api_spec swagger.json" \
            "~/.claude/commands/research-api.md#restler" \
            "Stateful API fuzzer from Microsoft"
        return 0
    fi

    # =========================
    # PROTOCOL ANALYSIS
    # =========================

    # Protobuf tools
    if echo "$task_lower" | grep -qE "(decode protobuf|binary protocol|\.proto file|protobuf message)"; then
        # Check for .proto files
        if echo "$file_extensions" | grep -qE "\.proto$"; then
            emit_detection "protoc" 0.95 "protoc --decode_raw < data.bin" \
                "~/.claude/commands/research-api.md#protoc" \
                "Protobuf compiler and decoder"
            return 0
        fi
        emit_detection "pbtk" 0.9 "pbtk extract app.apk -o protos/" \
            "~/.claude/commands/re.md#pbtk" \
            "Protobuf reverse engineering toolkit"
        return 0
    fi

    # gRPC tools
    if echo "$task_lower" | grep -qE "(grpc service|grpc reflection|grpc api)"; then
        emit_detection "grpcurl" 0.9 "grpcurl -plaintext localhost:50051 list" \
            "~/.claude/commands/research-api.md#grpcurl" \
            "gRPC service testing and reflection"
        return 0
    fi

    # GraphQL tools
    if echo "$task_lower" | grep -qE "(graphql api|graphql schema|introspection disabled|graphql endpoint)"; then
        if echo "$task_lower" | grep -q "introspection disabled"; then
            emit_detection "clairvoyance" 0.95 "python clairvoyance.py -t https://target.com/graphql" \
                "~/.claude/commands/research-api.md#clairvoyance" \
                "GraphQL schema reconstruction when introspection is disabled"
            return 0
        else
            emit_detection "inql" 0.85 "Use InQL Burp extension" \
                "~/.claude/commands/re.md#inql" \
                "GraphQL introspection and vulnerability scanning"
            return 0
        fi
    fi

    # =========================
    # MOBILE & BINARY ANALYSIS
    # =========================

    # Android APK analysis
    if echo "$file_extensions" | grep -qE "\.apk$" || echo "$task_lower" | grep -qE "(android apk|decompile app)"; then
        emit_detection "jadx" 0.95 "jadx -d output app.apk" \
            "~/.claude/commands/re.md#jadx" \
            "Android APK decompiler"
        return 0
    fi

    # SSL pinning bypass
    if echo "$task_lower" | grep -qE "(ssl pinning|bypass pinning|mobile app reverse)"; then
        emit_detection "objection" 0.95 'objection -g "App" explore --startup-command "android sslpinning disable"' \
            "~/.claude/commands/re.md#objection" \
            "Mobile exploration and SSL pinning bypass with Frida"
        return 0
    fi

    # Frida hooks
    if echo "$task_lower" | grep -qE "(hook function|dynamic instrumentation|inject script|runtime modification)"; then
        emit_detection "frida" 0.9 "frida -U -f com.app.package -l hook.js" \
            "~/.claude/commands/re.md#frida" \
            "Dynamic instrumentation for runtime code modification"
        return 0
    fi

    # Binary analysis (ELF, PE, Mach-O)
    if echo "$file_extensions" | grep -qE "\.(exe|elf|dll|so|dylib)$" || echo "$task_lower" | grep -qE "(disassemble|binary analysis|reverse binary|assembly code)"; then
        # Check for .NET assemblies
        if (echo "$file_extensions" | grep -qE "\.(dll|exe)$") && echo "$task_lower" | grep -qE "(\.net|c#|csharp)"; then
            emit_detection "ilspy" 0.9 "ilspycmd assembly.dll -o output_dir" \
                "~/.claude/commands/re.md#ilspy" \
                ".NET decompiler"
            return 0
        else
            emit_detection "ghidra" 0.85 "analyzeHeadless project -import binary.bin" \
                "~/.claude/commands/re.md#ghidra" \
                "NSA reverse engineering suite"
            return 0
        fi
    fi

    # WebAssembly
    if echo "$file_extensions" | grep -qE "\.wasm$" || echo "$task_lower" | grep -qE "(webassembly|\.wasm file|wasm to c)"; then
        emit_detection "wabt" 0.95 "wasm2c input.wasm output.c" \
            "~/.claude/commands/re.md#wabt" \
            "WebAssembly toolkit"
        return 0
    fi

    # =========================
    # OS & KERNEL ANALYSIS
    # =========================

    # Memory dumps
    if echo "$file_extensions" | grep -qE "\.(dump|dmp|mem|raw)$" || echo "$task_lower" | grep -qE "(memory dump|ram analysis|memory forensics)"; then
        emit_detection "volatility3" 0.95 "volatility3 -f memory.dump pslist" \
            "~/.claude/commands/re.md#volatility3" \
            "Memory forensics framework"
        return 0
    fi

    # Firmware analysis
    if (echo "$file_extensions" | grep -qE "\.bin$") && echo "$task_lower" | grep -qE "(firmware|extract firmware|router firmware|embedded system)"; then
        emit_detection "binwalk" 0.9 "binwalk -e firmware.bin" \
            "~/.claude/commands/re.md#binwalk" \
            "Firmware extraction and analysis"
        return 0
    fi

    # QEMU/GDB for emulation
    if echo "$task_lower" | grep -qE "(emulate os|kernel debugging|system emulation|debug kernel)"; then
        emit_detection "qemu" 0.85 "qemu-system-x86_64 -enable-kvm -kernel bzImage" \
            "~/.claude/commands/research-api.md#qemu" \
            "System emulation and kernel debugging"
        return 0
    fi

    # Windows crash dumps
    if echo "$file_extensions" | grep -qE "\.(dmp|mdmp)$" || echo "$task_lower" | grep -qE "(windows debugging|crash dump|time travel debug)"; then
        emit_detection "windbg" 0.9 "windbg -z crashdump.dmp" \
            "~/.claude/commands/re.md#windbg" \
            "Windows debugger with Time Travel Debugging"
        return 0
    fi

    # =========================
    # WEB FRONTEND & AI
    # =========================

    # Bot detection bypass
    if echo "$task_lower" | grep -qE "(bypass bot detection|hide automation|headless detection|scraper detected)"; then
        emit_detection "puppeteer-stealth" 0.9 "Use puppeteer-extra-plugin-stealth" \
            "~/.claude/commands/re.md#puppeteer-stealth" \
            "Hide Puppeteer automation from bot detection"
        return 0
    fi

    # JavaScript deobfuscation
    if echo "$file_extensions" | grep -qE "\.min\.js$" || echo "$task_lower" | grep -qE "(deobfuscate javascript|obfuscated code|minified code)"; then
        emit_detection "babel" 0.85 "Use @babel/traverse with visitor pattern" \
            "~/.claude/commands/re.md#babel" \
            "JavaScript AST manipulation for deobfuscation"
        return 0
    fi

    # Screenshot to code
    if (echo "$file_extensions" | grep -qE "\.(png|jpg|jpeg)$") && echo "$task_lower" | grep -qE "(ui to code|screenshot to html|clone design|generate code from image)"; then
        emit_detection "screenshot-to-code" 0.9 "python run.py --url screenshot.png" \
            "~/.claude/commands/re.md#screenshot-to-code" \
            "AI-powered UI screenshot to code generation"
        return 0
    fi

    # Chrome DevTools Protocol
    if echo "$task_lower" | grep -qE "(chrome automation|devtools protocol|browser debugging|cdp)"; then
        emit_detection "chrome-devtools-protocol" 0.85 "CDP client with Network.enable" \
            "~/.claude/commands/re.md#chrome-devtools-protocol" \
            "Programmatic browser control and debugging"
        return 0
    fi

    # =========================
    # GENERAL RE PATTERNS
    # =========================

    # Chrome extension extraction
    if echo "$task_lower" | grep -qE "(chrome extension|\.crx file|extract extension)"; then
        emit_detection "re_chrome_extension" 0.9 "/re chrome <path>" \
            "~/.claude/commands/re.md#target-chrome-extension" \
            "Extract and analyze Chrome extension source code"
        return 0
    fi

    # Electron app extraction
    if echo "$task_lower" | grep -qE "(electron app|app\.asar|extract electron)"; then
        emit_detection "re_electron" 0.9 "/re electron <app_path>" \
            "~/.claude/commands/re.md#target-electron-app" \
            "Extract Electron app source code from ASAR archive"
        return 0
    fi

    # API reverse engineering
    if echo "$task_lower" | grep -qE "(reverse engineer api|api research|figure out api|understand api)"; then
        emit_detection "research_api" 0.85 "/research-api web <url>" \
            "~/.claude/commands/research-api.md" \
            "Comprehensive API reverse engineering workflow"
        return 0
    fi

    # No RE tool detected
    log "No RE tool detected for task: $task"
    echo "{}"
    return 1
}

# Emit detection result in JSON format
emit_detection() {
    local tool="$1"
    local confidence="$2"
    local command="$3"
    local doc_ref="$4"
    local description="$5"

    log "✓ Detected RE tool: $tool (confidence: $confidence)"

    # Output JSON for coordinator to consume
    cat <<EOF
{
  "tool": "$tool",
  "confidence": $confidence,
  "command": "$command",
  "doc_ref": "$doc_ref",
  "description": "$description",
  "detection_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

# Main command router
case "${1:-detect}" in
    detect)
        detect "${2:-}" "${3:-}" "${4:-[]}"
        ;;
    *)
        echo "Usage: $0 detect <task> [context] [files_json]"
        exit 1
        ;;
esac
