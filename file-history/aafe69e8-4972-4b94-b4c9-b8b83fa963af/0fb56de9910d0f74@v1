# RE Tool Auto-Detection System

> Automatic detection logic for when /auto should use RE tools

Based on Ken's Prompting Guide: **Reference docs, don't dump them**.

## Detection Patterns

### Network & API Interception Tools

**mitmproxy / Burp Suite**
- **Trigger words**: "intercept traffic", "capture HTTPS", "proxy requests", "analyze API calls"
- **File patterns**: None (real-time traffic)
- **Auto-use when**: User mentions inspecting live HTTP/HTTPS traffic
- **Doc reference**: `~/.claude/docs/reverse-engineering-toolkit.md` section "Network Interception"

**Kiterunner**
- **Trigger words**: "find hidden endpoints", "shadow APIs", "API discovery", "undocumented endpoints"
- **File patterns**: None
- **Auto-use when**: User wants to discover API endpoints without documentation
- **Command**: `kr scan https://api.target.com -A apiroutes-210328:5000`

**RESTler / Schemathesis**
- **Trigger words**: "fuzz API", "test API endpoints", "OpenAPI testing", "API fuzzing"
- **File patterns**: `*.json` (OpenAPI/Swagger files), `swagger.json`, `openapi.yaml`
- **Auto-use when**: Swagger/OpenAPI spec found + user wants comprehensive testing
- **Commands**: `restler compile --api_spec`, `schemathesis run`

### Protocol Analysis Tools

**protoc / pbtk**
- **Trigger words**: "decode protobuf", "binary protocol", ".proto file", "protobuf message"
- **File patterns**: `*.proto`, `*.pb`, binary files with protobuf headers
- **Auto-use when**: Encounters binary data that looks like protobuf
- **Command**: `protoc --decode_raw < data.bin`

**grpcurl / mitmproxy-grpc**
- **Trigger words**: "gRPC service", "gRPC reflection", "gRPC API", ".proto definition"
- **File patterns**: `*.proto` files
- **Auto-use when**: gRPC endpoint detected (port 50051 common)
- **Command**: `grpcurl -plaintext localhost:50051 list`

**Clairvoyance / InQL**
- **Trigger words**: "GraphQL API", "GraphQL schema", "introspection disabled", "GraphQL endpoint"
- **File patterns**: `/graphql` endpoint, GraphQL query files
- **Auto-use when**: GraphQL endpoint found + introspection query fails
- **Command**: `python clairvoyance.py -t https://target.com/graphql`

### Mobile & Binary Analysis

**JADX / Objection**
- **Trigger words**: "Android APK", "decompile app", "SSL pinning", "mobile app reverse", ".apk file"
- **File patterns**: `*.apk`, `classes.dex`
- **Auto-use when**: APK file found + user wants source code or needs SSL bypass
- **Commands**:
  - `jadx -d output app.apk`
  - `objection -g "App" explore --startup-command "android sslpinning disable"`

**Frida**
- **Trigger words**: "hook function", "dynamic instrumentation", "inject script", "runtime modification"
- **File patterns**: `*.js` (Frida scripts)
- **Auto-use when**: User needs to modify running app behavior
- **Command**: `frida -U -f com.app.package -l hook.js`

**Ghidra / Binary Ninja / Radare2**
- **Trigger words**: "disassemble", "binary analysis", "reverse binary", "assembly code", "decompile binary"
- **File patterns**: ELF binaries, PE files, Mach-O files, no extension binaries
- **Auto-use when**: Binary executable found + user wants to understand internals
- **Commands**:
  - `analyzeHeadless project -import binary.bin`
  - `r2 -c "aaa; pdf @ main" binary`

**WABT (WebAssembly)**
- **Trigger words**: "WebAssembly", ".wasm file", "wasm to C", "analyze wasm"
- **File patterns**: `*.wasm`
- **Auto-use when**: WASM file found
- **Command**: `wasm2c input.wasm output.c`

**dnSpy / ILSpy**
- **Trigger words**: ".NET assembly", "C# decompile", ".dll decompile", "IL code"
- **File patterns**: `*.dll`, `*.exe` (with .NET headers)
- **Auto-use when**: .NET assembly detected
- **Command**: `ilspycmd assembly.dll -o output_dir`

### OS & Kernel Analysis

**Volatility 3**
- **Trigger words**: "memory dump", "RAM analysis", "memory forensics", ".dump file", "memory image"
- **File patterns**: `*.dump`, `*.dmp`, `*.mem`, `*.raw`
- **Auto-use when**: Memory dump file found
- **Commands**: `volatility3 -f memory.dump pslist`

**Binwalk**
- **Trigger words**: "firmware", "extract firmware", "router firmware", "embedded system"
- **File patterns**: `*.bin` (firmware images), `*.img`
- **Auto-use when**: Firmware file found + user wants file extraction
- **Command**: `binwalk -e firmware.bin`

**QEMU / GDB**
- **Trigger words**: "emulate OS", "kernel debugging", "system emulation", "debug kernel"
- **File patterns**: `bzImage`, kernel images, `vmlinuz`
- **Auto-use when**: User wants to run/debug OS in emulation
- **Commands**:
  - `qemu-system-x86_64 -enable-kvm -kernel bzImage`
  - `gdb -ex "target remote :1234"`

**WinDbg**
- **Trigger words**: "Windows debugging", "crash dump", "Time Travel Debug", ".dmp file"
- **File patterns**: `*.dmp`, `*.mdmp`
- **Auto-use when**: Windows crash dump found
- **Command**: `windbg -z crashdump.dmp`

### Web Frontend & AI

**puppeteer-stealth**
- **Trigger words**: "bypass bot detection", "hide automation", "headless detection", "scraper detected"
- **File patterns**: `*.js` (Puppeteer scripts)
- **Auto-use when**: User reports bot detection or wants stealth scraping
- **Code**: Add stealth plugin to Puppeteer

**Babel / AST Explorer**
- **Trigger words**: "deobfuscate JavaScript", "obfuscated code", "minified code", "AST transform"
- **File patterns**: `*.min.js`, obfuscated JS files
- **Auto-use when**: Minified/obfuscated JS found + user wants readable version
- **Code**: Babel traverse with visitor pattern

**Chrome DevTools Protocol**
- **Trigger words**: "Chrome automation", "DevTools protocol", "browser debugging", "CDP"
- **File patterns**: None (browser automation)
- **Auto-use when**: User needs programmatic browser control
- **Code**: CDP client with `Network.enable`, `Debugger.enable`

**screenshot-to-code**
- **Trigger words**: "UI to code", "screenshot to HTML", "clone design", "generate code from image"
- **File patterns**: `*.png`, `*.jpg` (UI screenshots)
- **Auto-use when**: UI screenshot provided + user wants code generation
- **Command**: `python run.py --url screenshot.png`

---

## Auto-Detection Logic (Pseudocode)

```python
def detect_re_tool(task: str, context: str, files: list) -> dict:
    """
    Detect which RE tool to use based on task description and context.
    Returns: {tool: str, confidence: float, command: str, doc_ref: str}
    """

    task_lower = task.lower()

    # Network & API
    if any(word in task_lower for word in ["intercept", "capture traffic", "proxy"]):
        return {
            "tool": "mitmproxy",
            "confidence": 0.9,
            "command": "mitmproxy -p 8080",
            "doc_ref": "~/.claude/docs/reverse-engineering-toolkit.md#network-interception"
        }

    if "shadow api" in task_lower or "hidden endpoints" in task_lower:
        return {
            "tool": "kiterunner",
            "confidence": 0.95,
            "command": "kr scan https://api.target.com -A apiroutes",
            "doc_ref": "~/.claude/commands/re.md#kiterunner"
        }

    # Protocol Analysis
    if any(file.endswith('.proto') for file in files) or "protobuf" in task_lower:
        return {
            "tool": "protoc",
            "confidence": 0.9,
            "command": "protoc --decode_raw < data.bin",
            "doc_ref": "~/.claude/commands/re.md#protoc"
        }

    if "grpc" in task_lower:
        return {
            "tool": "grpcurl",
            "confidence": 0.85,
            "command": "grpcurl -plaintext localhost:50051 list",
            "doc_ref": "~/.claude/commands/re.md#grpc-tools"
        }

    if "graphql" in task_lower:
        if "introspection disabled" in task_lower:
            return {
                "tool": "clairvoyance",
                "confidence": 0.9,
                "command": "python clairvoyance.py -t https://target.com/graphql",
                "doc_ref": "~/.claude/commands/re.md#clairvoyance"
            }
        else:
            return {
                "tool": "InQL",
                "confidence": 0.8,
                "command": "Use InQL Burp extension",
                "doc_ref": "~/.claude/commands/re.md#inql"
            }

    # Mobile & Binary
    if any(file.endswith('.apk') for file in files) or "android apk" in task_lower:
        return {
            "tool": "jadx",
            "confidence": 0.95,
            "command": "jadx -d output app.apk",
            "doc_ref": "~/.claude/commands/re.md#jadx"
        }

    if "ssl pinning" in task_lower or "bypass pinning" in task_lower:
        return {
            "tool": "objection",
            "confidence": 0.95,
            "command": 'objection -g "App" explore --startup-command "android sslpinning disable"',
            "doc_ref": "~/.claude/commands/re.md#objection"
        }

    if "hook function" in task_lower or "frida" in task_lower:
        return {
            "tool": "frida",
            "confidence": 0.9,
            "command": "frida -U -f com.app.package -l hook.js",
            "doc_ref": "~/.claude/commands/re.md#frida"
        }

    # Check for binary files
    binary_extensions = ['.exe', '.elf', '.dll', '.so', '.dylib']
    if any(any(file.endswith(ext) for ext in binary_extensions) for file in files):
        if any(file.endswith('.dll') for file in files) and "c#" in task_lower or ".net" in task_lower:
            return {
                "tool": "ilspy",
                "confidence": 0.9,
                "command": "ilspycmd assembly.dll -o output_dir",
                "doc_ref": "~/.claude/commands/re.md#ilspy"
            }
        else:
            return {
                "tool": "ghidra",
                "confidence": 0.85,
                "command": "analyzeHeadless project -import binary.bin",
                "doc_ref": "~/.claude/commands/re.md#ghidra"
            }

    if any(file.endswith('.wasm') for file in files) or "webassembly" in task_lower:
        return {
            "tool": "wabt",
            "confidence": 0.95,
            "command": "wasm2c input.wasm output.c",
            "doc_ref": "~/.claude/commands/re.md#wabt"
        }

    # OS & Kernel
    if any(file.endswith(('.dump', '.dmp', '.mem', '.raw')) for file in files) or "memory dump" in task_lower:
        return {
            "tool": "volatility3",
            "confidence": 0.95,
            "command": "volatility3 -f memory.dump pslist",
            "doc_ref": "~/.claude/commands/re.md#volatility"
        }

    if any(file.endswith('.bin') for file in files) and ("firmware" in task_lower or "extract" in task_lower):
        return {
            "tool": "binwalk",
            "confidence": 0.9,
            "command": "binwalk -e firmware.bin",
            "doc_ref": "~/.claude/commands/re.md#binwalk"
        }

    # Web Frontend
    if "bot detection" in task_lower or "headless detected" in task_lower:
        return {
            "tool": "puppeteer-stealth",
            "confidence": 0.9,
            "command": "Use puppeteer-extra-plugin-stealth",
            "doc_ref": "~/.claude/commands/re.md#puppeteer-stealth"
        }

    if any(file.endswith('.min.js') for file in files) or "deobfuscate" in task_lower:
        return {
            "tool": "babel",
            "confidence": 0.85,
            "command": "Use @babel/traverse with visitor pattern",
            "doc_ref": "~/.claude/commands/re.md#babel"
        }

    if any(file.endswith(('.png', '.jpg', '.jpeg')) for file in files) and ("ui to code" in task_lower or "screenshot to code" in task_lower):
        return {
            "tool": "screenshot-to-code",
            "confidence": 0.9,
            "command": "python run.py --url screenshot.png",
            "doc_ref": "~/.claude/commands/re.md#screenshot-to-code"
        }

    return None  # No RE tool detected
```

---

## Integration with /auto Command

When /auto processes a task:

1. **Analyze task + context + files**
2. **Run detection logic** (`detect_re_tool()`)
3. **If tool detected**:
   - Log decision: `~/.claude/hooks/enhanced-audit-trail.sh log "RE tool detected: {tool}"`
   - **Reference doc** (Ken's principle): Read doc_ref file, cite relevant section
   - **Execute tool** with detected command
   - **Record to memory**: `~/.claude/hooks/memory-manager.sh add-fact "RE tool usage: {tool} for {task}"`
4. **If no tool detected**: Proceed with normal /auto flow

### Example Flow

```
User: "/auto I have an APK file app.apk, extract the source code"

auto-continue.sh orchestrate:
  ↓
detect_re_tool("extract source from APK", "app.apk"):
  → tool: "jadx"
  → confidence: 0.95
  → command: "jadx -d output app.apk"
  → doc_ref: "~/.claude/commands/re.md#jadx"
  ↓
Read ~/.claude/commands/re.md (section: JADX)
  ↓
Execute: jadx -d output app.apk
  ↓
Record success to memory
  ↓
Continue with next step
```

---

## Ken's Prompting Guide Compliance

✅ **Reference docs, don't dump them**
- Detection returns `doc_ref` path
- /auto reads only the relevant section
- Cites documentation instead of regenerating knowledge

✅ **Short > Long**
- Detection logic is concise pattern matching
- Tool recommendations are 1-2 sentences max

✅ **Work focused**
- Auto-executes tool when confidence > 0.8
- No unnecessary explanations during execution
- Log to audit trail, not user output

---

## Testing Checklist

- [ ] APK file → auto-detects JADX
- [ ] .proto file → auto-detects protoc
- [ ] GraphQL endpoint → auto-detects Clairvoyance/InQL
- [ ] Firmware .bin → auto-detects Binwalk
- [ ] Memory .dump → auto-detects Volatility
- [ ] Obfuscated .js → auto-detects Babel
- [ ] gRPC mention → auto-detects grpcurl
- [ ] Bot detection mention → auto-detects puppeteer-stealth
- [ ] .wasm file → auto-detects WABT
- [ ] .NET .dll → auto-detects ILSpy

---

## Future Enhancements

1. **Multi-tool workflows**: Chain tools (JADX → Frida → Objection)
2. **Confidence thresholds**: Ask user if confidence < 0.7
3. **Tool version detection**: Check installed tool versions
4. **Fallback tools**: If primary tool fails, try alternative
5. **Learning**: Track which tools work best for which scenarios
