# Reverse Engineering Toolkit

> Reference guide for API analysis, traffic interception, and binary reverse engineering.
> Use when: stuck on undocumented APIs, need to understand protocols, bypass restrictions.

## Quick Start

**For copy-paste Claude Code prompts, see:** `~/.claude/docs/re-prompts.md`
**For the /re skill command, run:** `/re [target-type] [path]`

### Common Tasks (Ken Kai Method)

| Task | Command |
|------|---------|
| Extract Chrome extension | `/re chrome ~/Downloads/ext.crx` |
| Extract Electron app | `/re electron /Applications/Discord.app` |
| Deobfuscate JavaScript | `/re deobfuscate ./bundle.min.js` |
| Explore macOS app | `/re macos /Applications/App.app` |
| Reverse engineer API | `/re api https://api.target.com` |
| Build web scraper | `/re scrape https://target.com` |
| Browser automation | `/re automate "login and download"` |

## When to Use This Guide

| Situation | Start Here |
|-----------|------------|
| Undocumented API | Network Interception → API Fuzzing |
| Mobile app API | Mobile Analysis → Traffic Intercept |
| Binary protocol | Protocol Analysis → Protobuf/gRPC |
| Obfuscated JS | Web Frontend → AST Analysis |
| Hidden endpoints | API Fuzzing → Shadow API Discovery |
| Rate limiting | Fingerprint Analysis → Stealth |
| Binary/native code | Binary Analysis → Ghidra/Frida |

---

## 1. Network & API Interception

### mitmproxy (CLI Proxy)
**When**: Intercept HTTPS, script automated modifications, analyze API flows
```bash
# Basic intercept
mitmproxy -p 8080

# Dump all traffic to file
mitmdump -w traffic.flow

# Script to modify responses
mitmdump -s modify_response.py

# Reverse proxy mode (for APIs)
mitmproxy --mode reverse:https://api.target.com

# Filter specific hosts
mitmproxy --set block_global=false -p 8080
```

**Python script example**:
```python
# modify_response.py
from mitmproxy import http

def response(flow: http.HTTPFlow):
    if "api.target.com" in flow.request.pretty_host:
        # Log the response
        print(f"[{flow.request.method}] {flow.request.path}")
        print(flow.response.text[:500])

        # Modify response
        flow.response.text = flow.response.text.replace('"premium":false', '"premium":true')
```

### Burp Suite Professional
**When**: Deep manual inspection, Repeater for replay, Intruder for fuzzing
```
1. Proxy → Intercept → Capture request
2. Send to Repeater → Modify and resend
3. Send to Intruder → Fuzz parameters
4. Scanner → Find vulnerabilities automatically
```

**Key extensions**:
- Turbo Intruder: Race condition testing, massive request volumes
- Blackbox Protobuf: Auto-decode protobuf in proxy
- InQL: GraphQL schema discovery

### Charles Proxy
**When**: iOS/Android traffic, user-friendly SSL setup
```
1. Install Charles CA on device
2. Set device proxy to Charles IP:8888
3. Enable SSL Proxying for target hosts
4. Record → Export → HAR format for analysis
```

### Wireshark
**When**: Deep packet analysis, non-HTTP protocols, TCP/UDP inspection
```bash
# Capture on interface
wireshark -i en0 -k

# Filter HTTP traffic
http.request.method == "GET"

# Filter by host
http.host contains "api.target.com"

# Follow TCP stream
Right-click packet → Follow → TCP Stream
```

### JA3 Fingerprint Analysis
**When**: Server detecting you as bot based on TLS handshake
```bash
# Check your JA3 fingerprint
curl -s https://ja3er.com/json | jq

# Common fingerprints:
# - Chrome: specific JA3 hash
# - Python requests: different hash (detectable)
# - curl: another hash

# Solution: Use browser automation or spoof TLS
```

---

## 2. API Discovery & Fuzzing

### Kiterunner (Shadow API Discovery)
**When**: Find hidden/forgotten endpoints
```bash
# Install
go install github.com/assetnote/kiterunner/cmd/kr@latest

# Scan with wordlist
kr scan https://api.target.com -w routes-large.kite

# Brute force common API paths
kr brute https://api.target.com -w api-wordlist.txt

# Output formats
kr scan https://api.target.com -o json > results.json
```

### RESTler (Stateful API Fuzzing)
**When**: Need to test API logic sequences, find crash bugs
```bash
# Compile API spec
restler compile --api_spec openapi.json

# Fuzz
restler fuzz --grammar_file Compile/grammar.py --dictionary_file Compile/dict.json

# Test mode (safer)
restler test --grammar_file Compile/grammar.py
```

### Schemathesis
**When**: Have OpenAPI spec, want automated testing
```bash
# Install
pip install schemathesis

# Run against spec
schemathesis run https://api.target.com/openapi.json

# With authentication
schemathesis run https://api.target.com/openapi.json -H "Authorization: Bearer TOKEN"

# Generate test cases
schemathesis run spec.json --hypothesis-phases=generate
```

---

## 3. Protocol Analysis (gRPC, GraphQL, Protobuf)

### Protobuf Reverse Engineering

**pbtk (Protobuf Toolkit)**
```bash
# Extract .proto from APK
pbtk extract app.apk -o protos/

# Recover from binary data
pbtk recover binary_response.bin -o recovered.proto
```

**protoc --decode_raw**
```bash
# Decode unknown protobuf
cat response.bin | protoc --decode_raw

# With known message type
protoc --decode=MyMessage my.proto < response.bin

# Encode test data
echo "1: 123 2: \"test\"" | protoc --encode=MyMessage my.proto > request.bin
```

**Blackbox Protobuf (Burp)**
```
1. Install from BApp Store
2. Intercept protobuf request
3. Auto-decodes to editable format
4. Modify fields → Forward
```

### gRPC Analysis

**mitmproxy-grpc**
```python
# grpc_intercept.py
from mitmproxy import http
import grpc_tools

def request(flow: http.HTTPFlow):
    if flow.request.headers.get("content-type", "").startswith("application/grpc"):
        # Decode gRPC
        decoded = grpc_tools.decode(flow.request.content)
        print(f"gRPC Request: {decoded}")
```

**BloomRPC / Kreya**
```
1. Import .proto files
2. Connect to gRPC endpoint
3. GUI to call methods with test data
4. Inspect responses
```

### GraphQL Analysis

**InQL Scanner**
```
1. Load in Burp Suite
2. Point at GraphQL endpoint
3. Auto-discovers schema via introspection
4. Generates queries for all types
```

**Clairvoyance (Schema Reconstruction)**
```bash
# When introspection is disabled
python clairvoyance.py -t https://target.com/graphql -w wordlist.txt

# With custom wordlist
python clairvoyance.py -t https://target.com/graphql -w custom_fields.txt -o schema.json
```

**Apollo DevTools Injection**
```javascript
// Inject in browser console
window.__APOLLO_CLIENT__.query({
    query: gql`{ __schema { types { name fields { name type { name } } } } }`
}).then(console.log)
```

---

## 4. Mobile App Analysis

### APK Decompilation

**JADX-GUI**
```bash
# Open APK
jadx-gui app.apk

# CLI export
jadx -d output/ app.apk

# Search for:
# - API endpoints: "api.", "https://", "/v1/"
# - API keys: "key", "secret", "token"
# - Auth logic: "authenticate", "login", "bearer"
```

**Key locations in decompiled APK**:
```
res/values/strings.xml    # Hardcoded strings, API URLs
assets/                   # Config files, certs
lib/                      # Native libraries (.so)
smali/                    # Dalvik bytecode
```

### Runtime Instrumentation

**Frida**
```bash
# Install
pip install frida-tools

# List running apps
frida-ps -U

# Attach to app
frida -U -n "Target App" -l script.js

# Spawn with script
frida -U -f com.target.app -l script.js --no-pause
```

**Common Frida scripts**:
```javascript
// Bypass SSL pinning
Java.perform(function() {
    var TrustManager = Java.use('javax.net.ssl.X509TrustManager');
    TrustManager.checkServerTrusted.implementation = function() {
        console.log('[+] SSL check bypassed');
    };
});

// Hook function
Java.perform(function() {
    var MainActivity = Java.use('com.target.app.MainActivity');
    MainActivity.secretFunction.implementation = function(arg) {
        console.log('[+] secretFunction called with: ' + arg);
        return this.secretFunction(arg);
    };
});

// Dump API responses
Interceptor.attach(Module.findExportByName('libssl.so', 'SSL_read'), {
    onLeave: function(retval) {
        console.log(Memory.readUtf8String(this.buf, retval.toInt32()));
    }
});
```

**Objection (SSL Pinning Bypass)**
```bash
# One-command SSL bypass
objection -g "Target App" explore --startup-command "android sslpinning disable"

# iOS version
objection -g "Target App" explore --startup-command "ios sslpinning disable"

# Explore app
objection -g com.target.app explore
> android hooking list classes
> android hooking search methods api
> android heap search instances com.target.app.User
```

---

## 5. Binary Analysis

### Ghidra
```bash
# Launch
ghidraRun

# Auto-analysis workflow:
1. Import binary (File → Import)
2. Auto-analyze (Yes to all)
3. Find functions: Window → Functions
4. Search strings: Search → For Strings
5. Decompile: Window → Decompile
6. Cross-references: Right-click → References
```

**Key analysis patterns**:
```
# Find crypto functions
Search → For Strings → "AES", "SHA", "RSA"

# Find network calls
Search → For Strings → "http", "socket", "connect"

# Find auth logic
Search → For Strings → "password", "token", "auth"
```

### Radare2
```bash
# Analyze binary
r2 -A binary

# List functions
afl

# Seek to main
s main

# Disassemble
pdf

# Search strings
iz | grep -i api

# Find cross-references
axt @ sym.target_function
```

### .NET Decompilation (dnSpy/ILSpy)
```
1. Open .exe or .dll
2. Navigate to namespace
3. View decompiled C# code
4. Set breakpoints
5. Debug runtime values
```

---

## 6. Web Frontend Analysis

### Chrome DevTools Deep Dive
```
F12 → Sources:
- Pretty print minified JS (bottom left {})
- Set breakpoints on XHR/fetch
- Conditional breakpoints for specific values
- Event Listener Breakpoints (click, submit)

F12 → Network:
- Filter by XHR
- Copy as cURL
- Throttle to simulate slow network
- Block requests to test fallbacks

F12 → Application:
- Local Storage / Session Storage
- Cookies
- IndexedDB
- Service Workers
```

### Local Overrides
```
1. DevTools → Sources → Overrides
2. Select folder for overrides
3. Right-click JS file → Save for overrides
4. Edit locally → Refresh → Your code runs

Use for:
- Adding console.log to obfuscated code
- Bypassing client-side checks
- Injecting debugging hooks
```

### AST Analysis (Obfuscated JS)
```javascript
// Use AST Explorer (astexplorer.net)
// 1. Paste obfuscated code
// 2. Select parser (babel-eslint)
// 3. Write transform to rename variables

// Example deobfuscation transform:
module.exports = function(babel) {
    return {
        visitor: {
            Identifier(path) {
                // Rename based on usage patterns
                if (path.node.name.match(/^_0x[a-f0-9]+$/)) {
                    // Analyze context and rename
                }
            }
        }
    };
};
```

### Browser Automation Stealth

**Puppeteer-extra-stealth**
```javascript
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());

const browser = await puppeteer.launch({ headless: true });
const page = await browser.newPage();

// Now undetectable by most bot detection
await page.goto('https://target.com');
```

**Detection bypass checklist**:
```
[ ] navigator.webdriver = false
[ ] Chrome runtime present
[ ] Plugins array populated
[ ] Languages array set
[ ] Permissions realistic
[ ] WebGL vendor/renderer set
[ ] Canvas fingerprint consistent
[ ] Audio context fingerprint
[ ] Font fingerprint
```

**Advanced Puppeteer Stealth Setup (from GitHub patterns)**:
```javascript
// Full stealth setup with adblocker - found in production codebases
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const AdblockerPlugin = require('puppeteer-extra-plugin-adblocker');

// Apply stealth plugin with all evasions
puppeteer.use(StealthPlugin());
puppeteer.use(AdblockerPlugin({ blockTrackers: true }));

(async () => {
    const browser = await puppeteer.launch({
        headless: 'new',  // Use new headless mode
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-blink-features=AutomationControlled',
            '--disable-features=IsolateOrigins,site-per-process'
        ]
    });

    const page = await browser.newPage();

    // Override user-agent
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');

    // Override webdriver detection
    await page.evaluateOnNewDocument(() => {
        Object.defineProperty(navigator, 'webdriver', { get: () => false });
        Object.defineProperty(navigator, 'plugins', { get: () => [1, 2, 3, 4, 5] });
        Object.defineProperty(navigator, 'languages', { get: () => ['en-US', 'en'] });
    });

    await page.goto('https://target.com');
})();
```

---

## 7. Memory & Kernel Analysis

### Volatility 3 (Memory Forensics)
```bash
# List processes
vol -f memory.dmp windows.pslist

# Dump process memory
vol -f memory.dmp windows.memmap --pid 1234 --dump

# Find passwords/keys
vol -f memory.dmp windows.hashdump
vol -f memory.dmp windows.cachedump

# Network connections
vol -f memory.dmp windows.netscan
```

### Cheat Engine (Runtime Memory)
```
1. Attach to process
2. Search for known value (e.g., health=100)
3. Change value in game
4. Search for new value
5. Narrow down to exact address
6. Find what writes to this address
7. Analyze the instruction
```

### WinDbg Time Travel Debugging
```
# Record execution
ttd.exe -launch app.exe -out trace.run

# Open in WinDbg
File → Open Trace File

# Navigate time
!tt 50%           # Go to 50% of execution
g-                # Step backwards
!positions        # Show all threads timeline
```

---

## 8. AI-Assisted Analysis

### screenshot-to-code
```bash
# Convert UI screenshot to React code
npx screenshot-to-code ./screenshot.png -o ./output

# Use for:
# - Cloning UI without access to source
# - Understanding component structure
# - Rapid prototyping
```

### Vision Agents (Canvas Analysis)
```javascript
// For Canvas-based UIs (no DOM)
// Use AI vision to identify elements

// 1. Take screenshot of canvas
const canvas = document.querySelector('canvas');
const dataUrl = canvas.toDataURL();

// 2. Send to vision API for analysis
// 3. Get coordinates of UI elements
// 4. Automate based on pixel positions
```

---

## Quick Reference: Tool Selection

```
┌─────────────────────────────────────────────────────────────┐
│                 REVERSE ENGINEERING FLOWCHART                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  START: What are you analyzing?                              │
│                                                              │
│  Web API ──────────────────────────────────────────────────► │
│    │                                                         │
│    ├── REST API → mitmproxy/Burp → Kiterunner → Schemathesis│
│    ├── GraphQL → InQL → Clairvoyance → Apollo DevTools      │
│    └── gRPC → pbtk → mitmproxy-grpc → BloomRPC              │
│                                                              │
│  Mobile App ───────────────────────────────────────────────► │
│    │                                                         │
│    ├── Android → JADX → Frida → Objection                   │
│    └── iOS → Frida → Objection → Charles                    │
│                                                              │
│  Binary/Native ────────────────────────────────────────────► │
│    │                                                         │
│    ├── Windows → Ghidra → WinDbg → Cheat Engine             │
│    ├── Linux → Ghidra → GDB → Radare2                       │
│    └── .NET → dnSpy → ILSpy                                 │
│                                                              │
│  Web Frontend ─────────────────────────────────────────────► │
│    │                                                         │
│    ├── Obfuscated JS → DevTools → AST Explorer              │
│    ├── Canvas UI → screenshot-to-code → Vision Agent        │
│    └── Automation → Puppeteer + Stealth                     │
│                                                              │
│  Protocol ─────────────────────────────────────────────────► │
│    │                                                         │
│    ├── Protobuf → protoc --decode_raw → pbtk                │
│    ├── WebSocket → DevTools → mitmproxy                     │
│    └── Custom TCP → Wireshark → Radare2                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Integration with Build System

When the build system encounters:
- **Undocumented API**: Research using mitmproxy + Kiterunner
- **Mobile app integration**: Extract with JADX, intercept with Frida
- **Binary protocol**: Decode with protoc, analyze with Ghidra
- **Rate limiting/detection**: Apply stealth techniques

```bash
# Add to error resolution workflow
~/.claude/hooks/error-handler.sh "API not documented" 0 3
# → Triggers RE toolkit research
# → mitmproxy capture
# → Kiterunner scan
# → Document findings
```

---

## 9. Advanced Patterns (from GitHub Code Search)

### Ghidra Headless Analysis
```bash
# Source: grep MCP - automated binary analysis scripts

# Basic headless analysis (no GUI)
$GHIDRA_HOME/support/analyzeHeadless /path/to/project ProjectName \
    -import /path/to/binary \
    -postScript MyAnalysisScript.py \
    -scriptPath /path/to/scripts \
    -deleteProject

# With pre/post analysis scripts
analyzeHeadless /tmp/ghidra_project TempProject \
    -import target.exe \
    -preScript SetAnalysisOptions.py \
    -postScript ExportFunctions.py \
    -overwrite

# Export to various formats
analyzeHeadless /project Output \
    -import binary \
    -postScript ExportToC.py  # Decompile to C
    -postScript ExportSymbols.py

# Example analysis script (ExportFunctions.py)
# Place in $GHIDRA_HOME/Ghidra/Features/Base/ghidra_scripts/
```

```python
# ExportFunctions.py - Ghidra Python script
# @category Analysis
# @keybinding
# @menupath
# @toolbar

from ghidra.program.model.symbol import SymbolType
import json

functions = []
fm = currentProgram.getFunctionManager()

for func in fm.getFunctions(True):
    functions.append({
        'name': func.getName(),
        'address': str(func.getEntryPoint()),
        'signature': str(func.getSignature()),
        'size': func.getBody().getNumAddresses()
    })

# Export to JSON
with open('/tmp/functions.json', 'w') as f:
    json.dump(functions, f, indent=2)

print(f"Exported {len(functions)} functions")
```

### mitmproxy Docker Setup
```yaml
# Source: grep MCP - containerized traffic interception
# docker-compose.yml for mitmproxy

version: '3.8'
services:
  mitmproxy:
    image: mitmproxy/mitmproxy:latest
    ports:
      - "8080:8080"   # Proxy port
      - "8081:8081"   # Web interface
    volumes:
      - ./scripts:/scripts
      - ./certs:/root/.mitmproxy
      - ./flows:/flows
    command: >
      mitmweb
      --web-host 0.0.0.0
      --web-port 8081
      --set block_global=false
      --scripts /scripts/modify.py
      -w /flows/traffic.flow
    environment:
      - MITMPROXY_MODE=regular
```

```python
# scripts/modify.py - mitmproxy addon
from mitmproxy import http
import json

class APILogger:
    def __init__(self):
        self.endpoints = set()

    def response(self, flow: http.HTTPFlow):
        # Log all API endpoints
        if "api" in flow.request.pretty_host:
            endpoint = f"{flow.request.method} {flow.request.path}"
            if endpoint not in self.endpoints:
                self.endpoints.add(endpoint)
                print(f"[NEW] {endpoint}")

            # Log response bodies for JSON APIs
            content_type = flow.response.headers.get("content-type", "")
            if "json" in content_type:
                try:
                    data = json.loads(flow.response.text)
                    print(f"  Keys: {list(data.keys()) if isinstance(data, dict) else 'array'}")
                except:
                    pass

addons = [APILogger()]
```

### JADX Advanced Patterns
```bash
# Source: grep MCP - AndroidReverse101 patterns

# Basic decompile with all options
jadx -d output/ \
    --show-bad-code \
    --deobf \
    --deobf-min 3 \
    --deobf-max 64 \
    app.apk

# Export as Gradle project (for Android Studio)
jadx -d output/ \
    --export-gradle \
    --deobf \
    app.apk

# Process specific classes only
jadx -d output/ \
    --class-filter "com.target.*" \
    app.apk

# With resource decoding disabled (faster)
jadx -d output/ \
    --no-res \
    --no-src \
    --only-main-classes \
    app.apk
```

```bash
# Search patterns after decompilation
cd output/

# Find API endpoints
grep -rn "https://" sources/ | grep -v "google\|facebook\|crashlytics"
grep -rn "api\." sources/
grep -rn "/v1/\|/v2/\|/api/" sources/

# Find hardcoded secrets
grep -rn "api_key\|apiKey\|API_KEY" sources/
grep -rn "secret\|password\|token" sources/
grep -rn "Bearer " sources/

# Find auth logic
grep -rn "authenticate\|login\|logout" sources/
grep -rn "SharedPreferences" sources/

# Find network configuration
grep -rn "CertificatePinner\|TrustManager\|HostnameVerifier" sources/
```

### Protobuf Schema Recovery
```bash
# Source: grep MCP - decode and reconstruct protobuf schemas

# Raw decode (no schema needed)
cat response.bin | protoc --decode_raw

# Decode with known message type
protoc --decode=MyMessage schema.proto < response.bin

# Encode test message
echo "1: 123 2: \"test\"" | protoc --encode=MyMessage schema.proto > request.bin

# Extract .proto from APK (if included)
unzip -q app.apk -d extracted/
find extracted/ -name "*.proto" -o -name "*.pb"

# Use pbtk for schema reconstruction
pbtk extract app.apk -o protos/
pbtk recover response.bin -o recovered.proto
```

```python
# Python protobuf decoding without schema
from google.protobuf.internal.decoder import _DecodeVarint
from google.protobuf.internal.wire_format import WIRETYPE_VARINT, WIRETYPE_FIXED64, WIRETYPE_LENGTH_DELIMITED, WIRETYPE_FIXED32

def decode_raw_protobuf(data):
    """Decode protobuf without schema"""
    pos = 0
    fields = {}

    while pos < len(data):
        # Read field tag
        tag, new_pos = _DecodeVarint(data, pos)
        wire_type = tag & 0x7
        field_number = tag >> 3
        pos = new_pos

        if wire_type == WIRETYPE_VARINT:
            value, pos = _DecodeVarint(data, pos)
        elif wire_type == WIRETYPE_FIXED64:
            value = data[pos:pos+8]
            pos += 8
        elif wire_type == WIRETYPE_LENGTH_DELIMITED:
            length, pos = _DecodeVarint(data, pos)
            value = data[pos:pos+length]
            pos += length
        elif wire_type == WIRETYPE_FIXED32:
            value = data[pos:pos+4]
            pos += 4

        fields[field_number] = value

    return fields
```
