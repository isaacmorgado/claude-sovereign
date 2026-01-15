---
description: Reverse engineer APIs, protocols, and binaries when documentation is lacking
argument-hint: "[target-type] [target] --depth [quick|deep|forensic]"
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep", "Task", "mcp__grep__searchGitHub", "WebSearch"]
---

# API & Protocol Research Command

> When official docs fail, reverse engineer the truth.

Use this when:
- API is undocumented or partially documented
- Need to understand mobile app's API calls
- Dealing with binary protocols (Protobuf, gRPC)
- Rate limited or bot-detected
- Hidden endpoints suspected

## Usage

```
/research-api web https://api.target.com          # Web API research
/research-api mobile com.target.app               # Mobile app analysis
/research-api protocol grpc://service:50051       # Protocol analysis
/research-api binary ./plugin.dll                 # Binary analysis
/research-api stealth https://target.com          # Anti-detection research
```

## Instructions

Parse arguments: $ARGUMENTS

### Step 0: Load Toolkit Reference

Read the comprehensive toolkit guide and prompts:
```bash
cat ~/.claude/docs/reverse-engineering-toolkit.md
cat ~/.claude/docs/re-prompts.md
```

This contains:
- Tool selection flowchart
- Command examples for each tool
- When to use each approach
- Copy-paste prompts for Claude Code (Ken Kai method)

**Quick alternative:** Use `/re api [target]` for simpler API research tasks.

### Step 1: Classify the Target

Determine research approach:

| Target Type | Primary Tools | Secondary Tools |
|-------------|---------------|-----------------|
| REST API | mitmproxy, Burp | Kiterunner, Schemathesis |
| GraphQL | InQL, Clairvoyance | Apollo DevTools |
| gRPC/Protobuf | pbtk, protoc | mitmproxy-grpc, BloomRPC |
| Mobile (Android) | JADX, Frida | Objection, Charles |
| Mobile (iOS) | Frida, Objection | Charles |
| Binary/Native | Ghidra, Radare2 | Frida, WinDbg |
| Web Frontend | DevTools, AST | Puppeteer-stealth |

### Step 2: Search for Existing Research

Before manual analysis, search for existing knowledge:

```
1. GitHub code search for API patterns:
   mcp__grep__searchGitHub: "[target] api" OR "[target] endpoint"

2. GitHub issues for undocumented features:
   WebSearch: "[target] api undocumented site:github.com"

3. Security research/writeups:
   WebSearch: "[target] api reverse engineering"
   WebSearch: "[target] security research"

4. Protocol buffers/schemas:
   mcp__grep__searchGitHub: "[target].proto" OR "[target] protobuf"
```

### Step 3: Execute Research Plan

#### For Web APIs:

```markdown
## Research: [API Name]

### 1. Traffic Capture
```bash
# Start mitmproxy
mitmproxy -p 8080 -w capture.flow

# Or with filtering
mitmdump -p 8080 -w capture.flow --set block_global=false
```

### 2. Endpoint Discovery
```bash
# Use Kiterunner for shadow APIs
kr scan https://api.target.com -w routes-large.kite -o results.json

# Or brute force common paths
kr brute https://api.target.com -w api-wordlist.txt
```

### 3. Schema Analysis
```bash
# If OpenAPI available
schemathesis run https://api.target.com/openapi.json

# Generate test cases
schemathesis run spec.json --hypothesis-phases=generate
```

### 4. Document Findings
- Endpoints discovered: [list]
- Auth mechanism: [bearer/api-key/oauth]
- Rate limits: [requests/window]
- Required headers: [list]
```

#### For GraphQL:

```markdown
### 1. Introspection Check
```graphql
{
  __schema {
    types { name fields { name type { name } } }
  }
}
```

### 2. If Introspection Disabled
```bash
# Use Clairvoyance
python clairvoyance.py -t https://target.com/graphql -w wordlist.txt -o schema.json
```

### 3. Schema Reconstruction
- Types discovered: [list]
- Mutations available: [list]
- Queries available: [list]
```

#### For Mobile Apps:

```markdown
### 1. APK Analysis
```bash
# Decompile
jadx -d output/ app.apk

# Search for endpoints
grep -r "api\." output/
grep -r "https://" output/
grep -r "endpoint" output/
```

### 2. Runtime Interception
```bash
# SSL Pinning Bypass
objection -g "App Name" explore --startup-command "android sslpinning disable"

# Hook API calls
frida -U -n "App Name" -l api_hook.js
```

### 3. Traffic Analysis
- Base URL: [discovered]
- Auth flow: [described]
- Interesting endpoints: [list]
```

#### For Binary Protocols:

```markdown
### 1. Protocol Identification
```bash
# Raw decode attempt
cat response.bin | protoc --decode_raw

# Check for gRPC
# Header: application/grpc
```

### 2. Schema Recovery
```bash
# From APK
pbtk extract app.apk -o protos/

# From binary blob
pbtk recover response.bin -o recovered.proto
```

### 3. Documentation
- Message types: [list]
- Field mappings: [list]
- Service definitions: [list]
```

### Step 4: Handle Detection/Rate Limiting

If being blocked or detected:

```markdown
### Anti-Detection Checklist

1. **TLS Fingerprinting**
   - Check JA3: `curl https://ja3er.com/json`
   - Solution: Use browser automation or curl-impersonate

2. **Bot Detection**
   - Puppeteer stealth plugin
   - Realistic mouse movements
   - Human-like timing delays

3. **Rate Limiting**
   - Identify limit: X requests per Y seconds
   - Implement exponential backoff
   - Rotate IPs if needed
   - Check for rate limit headers: X-RateLimit-*

4. **Headers Required**
   - User-Agent (match browser)
   - Accept-Language
   - Referer (if checking)
   - Custom headers (X-App-Version, etc.)
```

### Step 5: Document Findings

Create `.claude/docs/api-research/[target].md`:

```markdown
# [Target] API Research

## Overview
- Base URL:
- Auth:
- Protocol:

## Endpoints

### GET /endpoint
- Purpose:
- Headers:
- Response:

## Rate Limits
- Limit:
- Window:
- Bypass:

## Notes
-

## Tools Used
-

## Date: [timestamp]
```

### Step 6: Integration

Add findings to project:

1. **Create API client** based on discovered endpoints
2. **Add to .env.example** any required keys/configs
3. **Update architecture.md** with API integration notes
4. **Add to debug-log.md** research history

## Professional Toolkit (Quick Reference)

### Network & API Interception
```bash
# mitmproxy - Python HTTPS proxy with scripting
mitmproxy -p 8080                                    # Start interactive proxy
mitmweb -p 8080                                      # Web UI version
mitmdump -s addon.py -p 8080                        # Run with custom addon

# Burp Suite - Full-featured web proxy
# Use Montoya API for extensions (Java)

# Kiterunner - Discover shadow APIs
kr scan https://api.target.com -A apiroutes-210328:5000
kr brute https://api.target.com -w routes.kite

# RESTler - Stateful API fuzzer
restler compile --api_spec swagger.json
restler test --grammar_file grammar.py

# Schemathesis - OpenAPI testing
schemathesis run https://api.target.com/openapi.json

# Charles Proxy / Caido - Alternative proxies for mobile
```

### Protocols (gRPC, GraphQL, Protobuf)
```bash
# Decode Protobuf without schema
cat data.bin | protoc --decode_raw

# Extract .proto definitions from APK
pbtk                                                 # GUI tool

# gRPC reflection and testing
grpcurl -plaintext localhost:50051 list
grpcurl -plaintext localhost:50051 service/method

# GraphQL schema reconstruction
python clairvoyance.py -t https://target.com/graphql -o schema.json
python clairvoyance.py -w wordlist.txt -o schema.json

# GraphQL introspection (when enabled)
curl -X POST https://api/graphql -d '{"query": "{ __schema { types { name } } }"}'

# mitmproxy-grpc addon for gRPC interception
mitmproxy --set grpc_proto_dir=./protos
```

### Mobile & Binary Analysis
```bash
# Bypass SSL pinning with Objection
objection -g "App Name" explore
objection -g "com.package" explore --startup-command "android sslpinning disable"

# Frida dynamic instrumentation
frida -U -f com.app.package -l hook.js              # USB device
frida -H 192.168.1.100:27042 -f com.app.package    # Network
frida.attach(pid)                                    # Python API

# Decompile Android APK
jadx -d output/ app.apk
jadx-gui app.apk                                     # GUI mode

# Ghidra headless analysis
analyzeHeadless project_dir -import binary.bin -process -postscript analyze.py

# Radare2 binary analysis
r2 -c "aaa; pdf @ main" binary                      # Analyze and disassemble

# WebAssembly to C
wasm2c input.wasm output.c

# .NET decompilation
ilspycmd assembly.dll -o output_dir                  # ILSpy CLI
dnSpy.exe (GUI only)                                 # dnSpy
```

### OS & Kernel Analysis
```bash
# Memory forensics with Volatility
volatility3 -f memory.dump pslist
volatility3 -f memory.dump netscan
volatility3 -f memory.dump vadinfo

# Firmware extraction with Binwalk
binwalk -e firmware.bin                              # Extract all
binwalk --dd='.*' firmware.bin                       # Extract specific

# QEMU system emulation
qemu-system-x86_64 -enable-kvm -m 2048 -kernel bzImage -drive file=rootfs.img

# GDB with Python scripting
gdb -ex "source script.py" -ex "start" ./binary

# WinDbg Time Travel Debugging
windbg.exe -g -G binary.exe                          # GUI
```

### Web Frontend & AI
```bash
# Puppeteer with stealth plugin
const puppeteer = require('puppeteer-extra')
const StealthPlugin = require('puppeteer-extra-plugin-stealth')
puppeteer.use(StealthPlugin())

# Babel AST transformation
import { parse } from '@babel/parser'
import traverse from '@babel/traverse'
import generate from '@babel/generator'

# Chrome DevTools Protocol
const client = await page.context().newCDPSession(page)
await client.send('Network.enable')

# Screenshot to code (AI)
python run.py --url screenshot.png --output-dir ./output

# Source map decoding
import { TraceMap, originalPositionFor } from '@jridgewell/trace-mapping'
```

### Tool Selection Guide

| Scenario | Best Tool | Command |
|----------|-----------|---------|
| **Web API traffic** | mitmproxy/Burp | `mitmproxy -p 8080` |
| **Mobile app API** | mitmproxy + Objection | `objection -g app explore` |
| **gRPC service** | grpcurl / mitmproxy-grpc | `grpcurl -plaintext host:port list` |
| **GraphQL API** | InQL / Clairvoyance | `python clairvoyance.py -t url` |
| **Protobuf decode** | protoc / pbtk | `protoc --decode_raw < data.bin` |
| **Android APK** | JADX + Frida | `jadx -d out app.apk` |
| **iOS app** | Frida + Objection | `frida -U -f bundle.id` |
| **Binary reverse** | Ghidra / Binary Ninja | `analyzeHeadless project -import bin` |
| **Firmware** | Binwalk | `binwalk -e firmware.bin` |
| **Memory dump** | Volatility 3 | `volatility3 -f dump pslist` |
| **JS obfuscated** | AST Explorer / Babel | Babel traverse with visitor |
| **Bot detection** | puppeteer-stealth | See stealth plugin above |
| **TLS fingerprint** | JA3 Inspector | Analyze TLS handshake |
```

## Error Recovery

If research hits a wall:

1. **Can't intercept traffic** → Check SSL pinning, use Frida
2. **Binary protocol** → Try protoc --decode_raw, check for gRPC
3. **Rate limited** → Lower request rate, rotate IPs, add delays
4. **Bot detected** → Use puppeteer-stealth, match TLS fingerprint
5. **Obfuscated client** → AST analysis, local overrides, add logging
