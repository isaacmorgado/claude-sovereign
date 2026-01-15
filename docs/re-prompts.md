# Reverse Engineering Prompts Library

> Copy-paste prompts for Claude Code. Based on Ken Kai's Hacker courses.
> Use with: /re command, /research-api, or directly in conversation.

---

## Chrome Extensions

### Extract Extension
```
I have a CRX file at [path]. Extract it to a folder so I can read the source code. CRX files are ZIP files with a header - you may need to strip the header or just rename to .zip and unzip.
```

### Analyze Extension
```
I extracted a Chrome extension to [folder path]. Read the manifest.json and explain:
1. What permissions does it request and why?
2. What does the background script do?
3. What content scripts are injected and on which sites?
4. Are there any privacy concerns?
```

### Find Extension ID
```
Help me find the extension ID for [extension name]. I need to locate its source files in ~/Library/Application Support/Google/Chrome/Default/Extensions/
```

---

## Electron Apps

### Extract App
```
Find the Electron app bundle for [App Name] in /Applications, locate the app.asar file, and extract it to ~/Desktop/[app-name]-source so I can analyze it.
```

### Analyze Electron Source
```
I extracted an Electron app to [folder path]. Read the package.json and main entry files. Explain:
1. What is the app's architecture?
2. What are the main features based on the code structure?
3. What interesting patterns or techniques does it use?
```

### Find Main Entry
```
I extracted an Electron app to [path]. Find the main entry point from package.json and trace through the initialization code. What does this app do on startup?
```

---

## JavaScript Deobfuscation

### Beautify Code
```
I have a minified JavaScript file at [path]. Beautify it and make it readable. Add meaningful variable names where you can infer the purpose from context.
```

### Deep Analysis
```
Analyze this obfuscated JavaScript file at [path]. Focus on:
1. What does the code do? Trace the main execution flow.
2. Identify any API calls, URLs, or external communications
3. Find any interesting functions or logic patterns
4. Suggest better variable names based on usage
```

### Find Hidden Functionality
```
This JavaScript code appears obfuscated. Search for:
1. Hidden API endpoints or URLs
2. Encoded/encrypted strings that might be decoded at runtime
3. eval() or Function() calls that execute dynamic code
4. Any anti-debugging or detection code
```

### Reconstruct Logic
```
I have partially deobfuscated code at [path]. Help me understand this specific function: [function name or code block]. What is it doing step by step?
```

---

## macOS Apps

### Explore Bundle
```
I want to explore the macOS app at [path]. Show me its bundle structure, find any interesting resources, config files, or embedded assets. Look in Contents/Resources and Contents/Frameworks.
```

### Extract Resources
```
Extract all image assets, config files, and other resources from the macOS app at [path]. Organize them by type in ~/Desktop/[app-name]-resources/
```

### Analyze Info.plist
```
Read the Info.plist from [app path]. What permissions does this app request? What URL schemes does it handle? Any interesting configuration?
```

---

## Reverse Engineering Tools

### Setup Ghidra Analysis
```
Help me set up Ghidra to analyze [binary path]. I want to:
1. Import and auto-analyze the binary
2. Find the main function
3. Search for interesting strings (passwords, URLs, API keys)
4. Understand the overall program flow
```

### Frida Hook Script
```
Write a Frida script to hook [function/class] in [app name]. I want to:
1. Log all calls to this function with arguments
2. Optionally modify the return value
3. Print a stack trace to see who's calling it
```

### SSL Pinning Bypass
```
Help me bypass SSL pinning for [app name] so I can intercept its traffic. Suggest the best approach (Frida script, Objection, or manual patching) based on the app type.
```

---

## Terminal Scripts & Automation

### DNS Benchmark
```
Build a script that benchmarks DNS servers (Cloudflare 1.1.1.1, Google 8.8.8.8, Quad9 9.9.9.9, and my ISP's) from my location. Run multiple queries and report average response times.
```

### Network Diagnostics
```
Create a comprehensive network diagnostic script that checks:
1. Internet connectivity
2. DNS resolution
3. Default gateway
4. Current IP (local and public)
5. Active connections
6. Port scan for common services
```

### System Info Script
```
Build a system information script that collects:
1. Hardware specs (CPU, RAM, storage)
2. OS version and updates
3. Running processes and resource usage
4. Installed applications
5. Network configuration
Export to a readable report.
```

### File Automation
```
Create a script to [describe automation]. For example:
- Organize downloads by file type
- Rename files in bulk with pattern
- Find and remove duplicate files
- Sync folders with rsync
```

---

## Web Scraping

### Simple Scraper
```
Build a scraper for [website URL] that extracts [data description]. Handle pagination if needed and export to CSV/JSON.
```

### Authenticated Scraper
```
I need to scrape data from [website] but it requires login. Build a scraper using Playwright that:
1. Logs in with credentials from .env
2. Navigates to [target page]
3. Extracts [data fields]
4. Handles pagination
5. Exports to [format]
```

### Handle Dynamic Content
```
The website at [URL] loads content dynamically with JavaScript. Build a scraper that:
1. Waits for content to load
2. Scrolls to load infinite scroll content
3. Handles AJAX requests
4. Extracts the data I need: [fields]
```

### Anti-Detection Scraper
```
The website is blocking my scraper. Rebuild it with stealth measures:
- Random delays between requests (2-5 seconds)
- Rotate user agents from a realistic list
- Use puppeteer-stealth or undetected-chromedriver
- Respect robots.txt rate limits
- Add realistic mouse movements
```

---

## API Reverse Engineering

### Traffic Capture Setup
```
I want to understand how [app/website] communicates with its API. Help me set up mitmproxy to capture traffic, then analyze the requests and responses to document the API.
```

### Analyze Captured Traffic
```
I captured API traffic from [app]. The base URL is [url]. Analyze these requests and:
1. Document all endpoints discovered
2. Identify the authentication mechanism
3. Map request/response schemas
4. Note any rate limits or restrictions
```

### Build API Client
```
Based on my API research for [service], create a Python client that can:
1. Authenticate using [method]
2. Call the main endpoints I discovered
3. Handle rate limiting appropriately
4. Include error handling
```

### Decode Binary Protocol
```
I captured binary data from [source]. It might be protobuf or a custom format. Help me:
1. Try decoding with protoc --decode_raw
2. Identify the message structure
3. Create a .proto schema if possible
4. Build a decoder for this protocol
```

---

## Browser Automation

### Generic Automation
```
Build a Playwright automation that [describes workflow]. Include:
- Login handling if needed
- Screenshots at key steps for debugging
- Error handling with retries
- Logging of actions taken
```

### Login + Action
```
Automate: Login to [site] with credentials from .env, then [describe actions], finally [describe output/download].
```

### Monitoring Script
```
Build a monitoring script that:
1. Checks [URL/element] every [interval]
2. Extracts [data]
3. Compares to previous value
4. Alerts me if [condition]
5. Logs history to CSV
```

### Form Automation
```
Automate form submission at [URL]:
1. Fill fields: [list fields and values or source]
2. Handle any CAPTCHAs manually (pause and wait)
3. Submit and capture confirmation
4. Export results
```

### PDF/Report Download
```
Automate: Login to [site], navigate to [reports section], generate report for [date range], download PDF, save with naming pattern [pattern] to [folder].
```

---

## Quick Commands

```bash
# Find Chrome extensions
ls ~/Library/Application\ Support/Google/Chrome/Default/Extensions/

# Extract Electron app
asar extract /Applications/App.app/Contents/Resources/app.asar ./output

# Beautify JS
npx js-beautify input.min.js -o output.js

# Start mitmproxy
mitmproxy -p 8080

# Decode protobuf
cat data.bin | protoc --decode_raw

# Frida list processes
frida-ps -U

# SSL pinning bypass
objection -g "App Name" explore --startup-command "android sslpinning disable"
```

---

## Troubleshooting Prompts

### General Debug
```
I'm trying to [goal] but getting [error/problem]. Here's what I've tried: [attempts]. What should I try next?
```

### Extension Issues
```
I extracted a Chrome extension but the folder is empty/missing key files. The extension ID is [id]. Help me find alternative ways to get the source code.
```

### Code Still Obfuscated
```
I ran the deobfuscator but the code is still hard to read. Here's a sample: [code block]. Can you help me understand what this specific part does?
```

### Scraper Blocked
```
My scraper to [site] is being blocked. I'm getting [error/response]. My current approach: [describe]. How can I bypass this?
```

### API Auth Failing
```
I'm trying to call [endpoint] but getting auth errors. The original app uses [observed auth method]. Help me replicate the authentication flow.
```

---

## Advanced Patterns (from GitHub Code Search)

### Ghidra Headless Analysis
```
Set up Ghidra headless analysis for [binary path]. I want to:
1. Run automated analysis without GUI
2. Export all function signatures to JSON
3. Decompile interesting functions to C
4. Find strings containing [pattern]
Create the analyzeHeadless command and any needed Python scripts.
```

### mitmproxy Container Setup
```
Create a Docker-based mitmproxy setup for intercepting traffic from [app/device]. Include:
1. docker-compose.yml with web interface
2. Python addon to log all API endpoints discovered
3. Volume mounts for certs and captured flows
4. Instructions for configuring the target device
```

### JADX Deep Analysis
```
Decompile [app.apk] with JADX and analyze it:
1. Use deobfuscation options for readable output
2. Search for API endpoints and hardcoded secrets
3. Find authentication and certificate pinning code
4. Map the app's network communication patterns
```

### Protobuf Without Schema
```
I captured binary data that looks like protobuf at [path]. Help me:
1. Decode it with protoc --decode_raw
2. Reconstruct a .proto schema from the field structure
3. Write a Python decoder for future messages
4. Create test messages for the API
```

### Puppeteer Stealth Scraper
```
Build a Puppeteer scraper with full stealth mode for [site]. Include:
1. puppeteer-extra with stealth plugin
2. Adblocker plugin
3. Custom user-agent and viewport
4. navigator.webdriver bypass
5. Realistic delays between actions
```

### Frida Crypto Interception
```
Write a Frida script to intercept all crypto operations in [app name]:
1. Hook SecretKeySpec to capture AES/DES keys
2. Hook Cipher.doFinal to see plaintext and ciphertext
3. For iOS, also hook CCCrypt
4. Log everything with timestamps for correlation
```

### Frida Anti-Detection Bypass
```
The app [name] is detecting Frida and crashing. Create a bypass script that:
1. Hooks dlopen to hide Frida libraries
2. Hooks dlsym to hide Frida symbols
3. Bypasses common Frida detection checks
4. Hides from /proc/self/maps scanning
```

### iOS Keychain Dump
```
Write a Frida script to dump all keychain items from [iOS app]:
1. Hook SecItemCopyMatching and SecItemAdd
2. Log the query parameters and results
3. Extract any stored tokens or credentials
4. Format output for easy analysis
```

---

## Professional RE Tools (50+ Tools)

> Copy-paste prompts for the complete professional toolkit

### Network & API Interception

#### Kiterunner (Shadow API Discovery)
```
Use Kiterunner to discover hidden/undocumented endpoints for [target API]:
1. Run kr scan with the apiroutes wordlist
2. Try the 210328 wordlist with 5000+ common API patterns
3. Identify shadow APIs not in public documentation
4. Test discovered endpoints for unauthorized access
Command: kr scan https://api.target.com -A apiroutes-210328:5000
```

#### RESTler (Stateful API Fuzzing)
```
Set up RESTler to fuzz [API] using the OpenAPI spec at [path]:
1. Compile the OpenAPI spec to RESTler grammar
2. Run test mode to find bugs and violations
3. Focus on authentication and authorization bugs
4. Export results with reproduce steps
Command: restler compile --api_spec swagger.json && restler test
```

#### Schemathesis (OpenAPI Testing)
```
Run comprehensive OpenAPI tests on [API URL]:
1. Load the OpenAPI/Swagger spec
2. Generate hypothesis-based test cases
3. Test all endpoints with various payloads
4. Report schema violations and crashes
Command: schemathesis run https://api.target.com/openapi.json
```

#### Burp Suite Extensions
```
Recommend Burp Suite extensions for [specific task]:
- Use Turbo Intruder for race conditions and high-speed attacks
- Use InQL for GraphQL testing
- Use Blackbox Protobuf for binary protocol testing
- Use Logger++ for advanced request logging
Provide setup instructions and example workflows.
```

#### Charles Proxy (Mobile Traffic)
```
Set up Charles Proxy for intercepting [iOS/Android] traffic:
1. Install Charles CA certificate on device
2. Configure device proxy settings
3. Enable SSL Proxying for target domains
4. Record and analyze API traffic
5. Export flows for analysis
```

#### JA3 Fingerprint Analysis
```
Analyze my TLS fingerprint to understand bot detection:
1. Check my current JA3 fingerprint at ja3er.com
2. Compare to real browser fingerprints
3. Identify what's flagging my requests as bot traffic
4. Recommend changes to match browser behavior
```

### Protocol Analysis

#### pbtk (Protobuf Toolkit)
```
Extract and analyze protobuf definitions from [app.apk or binary]:
1. Use pbtk to extract .proto files
2. Reconstruct message schemas from captured data
3. Build a decoder for the protocol
4. Create test messages for fuzzing
```

#### Blackbox Protobuf (Burp Extension)
```
Intercept and modify protobuf messages in Burp without schema:
1. Install Blackbox Protobuf extension
2. Capture protobuf traffic from [app]
3. Decode messages using type inference
4. Modify and replay messages for testing
```

#### grpcurl (gRPC Testing)
```
Test the gRPC service at [host:port]:
1. List all services using reflection
2. Describe service methods and message types
3. Call methods with test payloads
4. Analyze responses and errors
Command: grpcurl -plaintext localhost:50051 list && grpcurl -plaintext localhost:50051 describe Service
```

#### mitmproxy with gRPC
```
Intercept gRPC traffic with mitmproxy:
1. Set up mitmproxy with grpc addon
2. Configure proto directory for decoding
3. Capture and inspect gRPC streams
4. Modify requests/responses in real-time
```

#### Clairvoyance (GraphQL Schema Recovery)
```
Reconstruct GraphQL schema when introspection is disabled at [URL]:
1. Run clairvoyance with wordlist of common types
2. Use query-based enumeration to find fields
3. Build a complete schema.json
4. Test discovered queries and mutations
Command: python clairvoyance.py -t https://target.com/graphql -w wordlist.txt -o schema.json
```

#### InQL (GraphQL Burp Extension)
```
Analyze GraphQL endpoint at [URL] using InQL:
1. Run introspection query if enabled
2. Generate all possible queries and mutations
3. Test for authorization bypasses
4. Find hidden/deprecated fields
5. Export query templates for testing
```

#### Apollo DevTools
```
Debug GraphQL queries in [app] using Apollo DevTools:
1. Install Apollo DevTools browser extension
2. Inspect Apollo cache and queries
3. Replay queries with different variables
4. Analyze query performance and caching
```

### Binary & Executable Analysis

#### Radare2 (Binary Analysis)
```
Analyze [binary] with radare2:
1. Auto-analyze with 'aaa' command
2. Disassemble main function: pdf @ main
3. Search for strings and xrefs
4. Decompile key functions
5. Create function call graph
Command: r2 -c "aaa; pdf @ main" binary
```

#### Binary Ninja (Modern Disassembler)
```
Set up Binary Ninja for [binary analysis]:
1. Load binary and run auto-analysis
2. Use medium-level IL for readable decompilation
3. Write Python script to extract [specific data]
4. Create cross-references for interesting functions
5. Export decompiled code
```

#### ILSpy (.NET Decompiler)
```
Decompile .NET assembly [assembly.dll]:
1. Use ilspycmd for CLI decompilation
2. Export all classes to organized folder structure
3. Search for hardcoded secrets and API keys
4. Analyze authentication logic
Command: ilspycmd assembly.dll -o output_dir
```

#### dnSpy (.NET Debugger)
```
Debug and modify .NET assembly [app.exe]:
1. Load assembly in dnSpy
2. Set breakpoints in key methods
3. Step through execution
4. Modify IL code to bypass checks
5. Save patched assembly
```

#### WABT (WebAssembly Toolkit)
```
Analyze WebAssembly module at [path.wasm]:
1. Decompile WASM to readable C code
2. Analyze exported functions
3. Find interesting logic or vulnerabilities
4. Reconstruct high-level algorithm
Command: wasm2c input.wasm output.c && cat output.c
```

### OS & Kernel Analysis

#### Volatility 3 (Memory Forensics)
```
Analyze memory dump [memory.dump]:
1. List running processes: pslist
2. Scan network connections: netscan
3. Extract processes and DLLs
4. Find suspicious processes or injections
5. Dump credentials from memory
Command: volatility3 -f memory.dump pslist && volatility3 -f memory.dump netscan
```

#### Binwalk (Firmware Extraction)
```
Extract and analyze firmware [firmware.bin]:
1. Scan for embedded file systems and archives
2. Extract all found files automatically
3. Analyze the filesystem structure
4. Look for hardcoded credentials and keys
5. Identify the OS and architecture
Command: binwalk -e firmware.bin && binwalk --dd='.*' firmware.bin
```

#### QEMU (System Emulation)
```
Emulate [OS/kernel] in QEMU:
1. Set up QEMU with appropriate architecture
2. Load kernel image and root filesystem
3. Enable KVM for performance
4. Configure network and debugging
5. Attach GDB for kernel debugging
Command: qemu-system-x86_64 -enable-kvm -m 2048 -kernel bzImage -drive file=rootfs.img
```

#### GDB with Python Scripting
```
Debug [binary] with GDB automation:
1. Write GDB Python script to automate analysis
2. Set breakpoints on interesting functions
3. Extract runtime values and memory
4. Hook system calls
5. Generate execution trace
Command: gdb -ex "source script.py" -ex "start" ./binary
```

#### WinDbg (Windows Debugging)
```
Analyze Windows crash dump [crashdump.dmp]:
1. Load dump in WinDbg Preview
2. Analyze exception and crash reason
3. Examine call stack and registers
4. Identify buggy module or driver
5. Use Time Travel Debugging if available
Command: windbg -z crashdump.dmp
```

#### ScyllaHide (Anti-Debug Plugin)
```
Bypass anti-debugging in [app] using ScyllaHide:
1. Load ScyllaHide plugin in x64dbg
2. Enable all anti-debug protections
3. Configure custom options for specific checks
4. Debug the application normally
5. Export configuration for reuse
```

#### Cheat Engine (Memory Scanner)
```
Find and modify [game/app] memory values:
1. Attach Cheat Engine to process
2. Search for specific values (health, score, etc.)
3. Filter and narrow results with changed values
4. Modify memory directly or create Lua script
5. Export memory edits as trainer
```

#### Saleae Logic (Hardware Debugging)
```
Capture and analyze hardware signals with Logic analyzer:
1. Connect to target device pins
2. Configure sampling rate and channels
3. Add protocol analyzers (SPI, I2C, UART, etc.)
4. Capture during target operation
5. Export decoded protocol data
```

### Web Frontend & AI Tools

#### Chrome DevTools Protocol (CDP)
```
Automate Chrome with CDP for [task]:
1. Connect to Chrome with CDP client
2. Enable Network and Debugger domains
3. Intercept and modify requests
4. Execute JavaScript in page context
5. Record all API calls made
```

#### Chrome Local Overrides
```
Override live JavaScript files in [site] for debugging:
1. Enable Local Overrides in DevTools
2. Save file to local workspace
3. Edit and debug modified version
4. Observe behavior changes
5. Export working modifications
```

#### AST Explorer + Babel
```
Deobfuscate JavaScript using AST manipulation:
1. Parse obfuscated code with @babel/parser
2. Traverse AST with visitor pattern
3. Simplify expressions and rename variables
4. Remove dead code and string encoding
5. Generate clean readable output
```

#### Source Map Decoders
```
Reconstruct original source from [minified.js.map]:
1. Load source map file
2. Use @jridgewell/trace-mapping to decode
3. Map minified positions to original
4. Reconstruct full original source if available
5. Export all original files
```

#### screenshot-to-code (AI UI Generator)
```
Generate code from UI screenshot [image.png]:
1. Upload screenshot to screenshot-to-code
2. Use GPT-4 Vision to analyze layout
3. Generate HTML/React/Vue code
4. Refine with additional prompts
5. Export working component
Command: python run.py --url screenshot.png --output-dir ./output
```

#### v0.dev (Vercel Generative UI)
```
Create React component from description:
1. Describe UI component in natural language
2. v0 generates TypeScript/React with Tailwind
3. Preview in browser immediately
4. Iterate with modification requests
5. Export final component code
```

#### puppeteer-stealth (Bot Detection Bypass)
```
Build undetectable Puppeteer scraper for [site]:
1. Install puppeteer-extra with stealth plugin
2. Configure 18+ evasion techniques
3. Add realistic mouse movements and delays
4. Rotate user-agents from real browser pool
5. Test against bot detection services
```

---

## Quick Tool Selection

### "I need to..."

**intercept HTTPS traffic** → mitmproxy, Burp Suite, Charles Proxy
**discover hidden APIs** → Kiterunner, Schemathesis, RESTler
**decode protobuf** → protoc --decode_raw, pbtk, Blackbox Protobuf
**test gRPC service** → grpcurl, mitmproxy-grpc, BloomRPC
**reverse GraphQL** → InQL, Clairvoyance, Apollo DevTools
**decompile Android APK** → JADX, apktool, Objection
**bypass SSL pinning** → Objection, Frida, Charles Proxy
**hook functions** → Frida, Xposed, Substrate
**reverse binary** → Ghidra, Radare2, Binary Ninja
**decompile .NET** → ILSpy, dnSpy
**analyze WebAssembly** → WABT (wasm2c)
**memory forensics** → Volatility 3
**firmware extraction** → Binwalk
**kernel debugging** → QEMU + GDB, WinDbg
**bypass anti-debug** → ScyllaHide, Frida anti-detection
**deobfuscate JS** → AST Explorer, Babel, Local Overrides
**hide bot detection** → puppeteer-stealth, undetected-chromedriver
**UI to code** → screenshot-to-code, v0.dev

---

## Tool Combinations (Workflows)

### Mobile App Reverse Engineering
```
Complete workflow for reversing [app.apk]:
1. JADX: Decompile APK to readable Java
2. Frida: Hook SSL_write to bypass pinning
3. mitmproxy: Capture decrypted API traffic
4. pbtk: Extract protobuf schemas if used
5. Objection: Explore app filesystem and memory
Result: Full API documentation + source code
```

### API Reverse Engineering
```
Comprehensive API research for [target]:
1. mitmproxy: Capture initial traffic
2. Kiterunner: Discover shadow endpoints
3. Schemathesis: Fuzz discovered OpenAPI spec
4. Clairvoyance: Reconstruct GraphQL schema if present
5. Build Python client with findings
Result: Complete unofficial API client
```

### Firmware Analysis
```
Full firmware analysis for [device]:
1. Binwalk: Extract filesystem
2. file + strings: Identify binaries and interesting strings
3. Ghidra: Reverse key binaries
4. QEMU: Emulate extracted filesystem
5. Volatility: Analyze memory dumps if available
Result: Complete firmware understanding + vulnerabilities
```

### Binary Protocol Reverse Engineering
```
Decode unknown binary protocol:
1. protoc --decode_raw: Try protobuf decoding
2. pbtk: Extract schemas from related binaries
3. mitmproxy: Capture live traffic
4. Construct .proto file from patterns
5. Build encoder/decoder in Python
Result: Working protocol implementation
```

---

## Sequential Workflows (Tool Chaining)

> Modern RE workflows chain multiple tools together for comprehensive analysis
> Each tool's output feeds into the next for end-to-end documentation

### mitmproxy → mitmproxy2swagger → Postman (HTTP Traffic to API Client)

**Use Case**: Convert captured HTTP traffic into a working Postman collection

```
Complete workflow for [app/website] traffic:
1. Capture traffic with mitmproxy:
   mitmproxy -p 8080 --mode regular --set flow_detail=3
   - Browse/use the app to capture all API calls
   - Save flows: File → Save → traffic.mitm

2. Convert to OpenAPI spec with mitmproxy2swagger:
   mitmproxy2swagger -i traffic.mitm -o swagger.yml -p https://api.target.com -f flow
   - Generates OpenAPI 3.0 specification
   - Includes all endpoints, parameters, responses
   - Auto-detects schemas from JSON payloads

3. Import to Postman:
   - Postman → Import → Upload swagger.yml
   - Auto-creates collection with all endpoints
   - Includes example requests and responses
   - Set up environment variables for auth tokens

4. Test and refine:
   - Run requests in Postman
   - Add authentication headers
   - Save successful requests
   - Export collection for team use

Result: Production-ready API client from traffic capture
```

### HAR Export → mitmproxy2swagger → Postman (Browser DevTools to API Client)

**Use Case**: Convert browser DevTools HAR files to Postman without mitmproxy

```
Workflow for web app API documentation:
1. Capture in Chrome DevTools:
   - Open DevTools → Network tab
   - Interact with web app
   - Right-click → Save all as HAR with content
   - Save as traffic.har

2. Convert HAR to OpenAPI:
   mitmproxy2swagger -i traffic.har -o swagger.yml -p https://api.target.com -f har
   - Processes HAR format directly
   - No need to run mitmproxy proxy
   - Works with any browser's HAR export

3. Import to Postman (same as above)

4. Alternative: Use online converters
   - HAR to Postman Chrome extensions
   - Online HAR analyzers

Result: API documentation from browser traffic
```

### Burp Suite → Burp2API → Postman (Pentesting to API Client)

**Use Case**: Convert Burp Suite traffic to OpenAPI for further testing

```
Workflow using Burp Suite:
1. Capture traffic in Burp:
   - Configure browser proxy to Burp (127.0.0.1:8080)
   - Browse target application
   - All traffic captured in HTTP history

2. Export from Burp:
   - Proxy → HTTP History
   - Select relevant requests (Ctrl+Click)
   - Right-click → Save items
   - Save as burp_traffic.xml

3. Convert with Burp2API:
   python burp2api.py -i burp_traffic.xml -o swagger.yml
   - Parses Burp's XML format
   - Generates OpenAPI 3.0 spec
   - Alternative to mitmproxy workflow

4. Import to Postman or API testing tool

Result: API documentation from pentesting traffic
```

### JADX → Frida → objection → mitmproxy (Mobile App to API Docs)

**Use Case**: Complete mobile app reverse engineering workflow

```
End-to-end mobile RE workflow:
1. JADX - Static Analysis:
   jadx -d output/ app.apk --deobf
   - Decompile APK to Java source
   - Search for API endpoints: grep -r "https://" output/
   - Find SSL pinning code: grep -r "TrustManager\|PinningTrustManager" output/
   - Identify auth mechanisms and tokens

2. Frida - SSL Pinning Bypass:
   frida -U -f com.target.app -l ssl-bypass.js --no-pause
   - Hook SSL/TLS functions to bypass pinning
   - Use universal SSL bypass script
   - Enables traffic interception

3. Objection - Quick SSL Bypass (Alternative):
   objection -g "App Name" explore --startup-command "android sslpinning disable"
   - One-command SSL pinning bypass
   - Includes memory, filesystem, and keystore tools
   - Built on Frida for convenience

4. mitmproxy - Traffic Capture:
   mitmproxy -p 8080 --mode regular
   - Configure device proxy to your machine:8080
   - Install mitmproxy CA cert on device
   - All HTTPS traffic now visible
   - Save flows for analysis

5. mitmproxy2swagger - Documentation:
   mitmproxy2swagger -i mobile_traffic.mitm -o mobile_api.yml -p https://api.target.com
   - Convert captured mobile traffic to OpenAPI
   - Import to Postman for testing

6. pbtk - Protobuf Analysis (if app uses protobuf):
   pbtk extract app.apk -o protos/
   - Extract .proto definitions
   - Decode binary protobuf messages
   - Reconstruct message schemas

Result: Complete mobile app API documentation + source code
```

### mitmproxy → Kiterunner → Schemathesis (Traffic to Shadow API Discovery to Fuzzing)

**Use Case**: Find undocumented endpoints and fuzz them

```
Advanced API discovery workflow:
1. mitmproxy - Baseline Capture:
   mitmproxy -p 8080
   - Capture normal app usage
   - Document known endpoints
   - Save flows: mitmproxy2swagger -i baseline.mitm -o baseline_spec.yml

2. Kiterunner - Shadow API Discovery:
   kr scan https://api.target.com -A apiroutes-210328:5000
   - Discover hidden/undocumented endpoints
   - Test 5000+ common API patterns
   - Find admin, debug, internal APIs
   - Combine with baseline for complete picture

3. Merge OpenAPI Specs:
   - Manually merge baseline_spec.yml + kiterunner findings
   - Add discovered endpoints to spec
   - Document request/response schemas

4. Schemathesis - API Fuzzing:
   schemathesis run merged_spec.yml --checks all --hypothesis-max-examples=1000
   - Fuzz all endpoints with property-based testing
   - Find input validation bugs
   - Test edge cases automatically
   - Generate bug reports

Result: Complete API surface + security findings
```

### Charles Proxy → Postman (macOS/iOS Alternative)

**Use Case**: macOS-native tool for iOS/Mac app traffic capture

```
macOS/iOS workflow:
1. Charles Proxy Setup:
   - Install Charles Proxy (macOS GUI)
   - Help → SSL Proxying → Install Charles Root Certificate
   - On iOS: Help → SSL Proxying → Install on Mobile Device
   - Configure device proxy to Mac IP:8888

2. Capture Traffic:
   - Enable SSL Proxying for target domains
   - Structure → Focus on target host
   - Use app normally to capture requests

3. Export to Postman:
   - File → Export → Postman Collection
   - Direct export to .postman_collection.json
   - Import to Postman

Result: Native macOS workflow without command-line tools
```

### grpcurl → mitmproxy-grpc → Swagger (gRPC to REST Documentation)

**Use Case**: Document gRPC services as REST-like APIs

```
gRPC service documentation workflow:
1. grpcurl - Service Discovery:
   grpcurl -plaintext localhost:50051 list
   grpcurl -plaintext localhost:50051 describe ServiceName
   - List all services and methods
   - Get message schemas via reflection
   - Export service definitions

2. mitmproxy with gRPC addon:
   mitmproxy -p 8080 --mode regular --set grpc_proto_dir=./protos
   - Intercept gRPC traffic
   - Decode with .proto files
   - Inspect streaming requests

3. Manual OpenAPI Conversion:
   - Create OpenAPI spec from gRPC definitions
   - Map RPC methods to REST endpoints
   - Document request/response schemas
   - Add gRPC-Web gateway config

Result: gRPC service documentation in REST format
```

### Ghidra → Frida → mitmproxy (Binary to Network Hooks)

**Use Case**: Find and hook network functions in native apps

```
Native app network analysis:
1. Ghidra - Find Network Functions:
   analyzeHeadless project -import app.exe -postScript find_network.py
   - Search for socket, send, recv, SSL functions
   - Identify API URL construction
   - Find encryption/signing functions

2. Frida - Hook Network Functions:
   frida -U -f com.app -l network-hooks.js
   - Hook functions identified in Ghidra
   - Log plaintext before encryption
   - Modify requests/responses
   - Bypass certificate pinning

3. mitmproxy - Capture Hooked Traffic:
   mitmproxy -p 8080
   - Capture traffic with Frida bypasses enabled
   - Document API with decrypted payloads
   - Convert to OpenAPI spec

Result: Complete API documentation for native apps with custom crypto
```

### InQL → Clairvoyance → Apollo DevTools (GraphQL Discovery)

**Use Case**: Complete GraphQL API discovery and testing

```
GraphQL reverse engineering:
1. InQL - Introspection (if enabled):
   - Install InQL Burp extension
   - Send introspection query
   - Auto-generate all queries and mutations
   - Export to Postman-like format

2. Clairvoyance - Schema Recovery (if introspection disabled):
   python clairvoyance.py -t https://target.com/graphql -w wordlist.txt -o schema.json
   - Brute-force type and field names
   - Reconstruct schema from responses
   - Query-based enumeration

3. Apollo DevTools - Live Testing:
   - Install Apollo DevTools browser extension
   - Inspect queries in real browser
   - Replay with different variables
   - Analyze cache behavior

4. Document Findings:
   - Create GraphQL playground
   - Document all queries/mutations
   - Map authorization rules
   - Export collection for testing

Result: Complete GraphQL API documentation
```

### Workflow Automation Scripts

**Use Case**: Automate common sequential workflows

```
Create automation for [workflow type]:
1. Write orchestration script:
   - Chain tool commands with error handling
   - Validate output at each step
   - Auto-retry on common failures
   - Progress logging and checkpoints

2. Example: traffic-to-postman.sh
   #!/bin/bash
   # Capture → Convert → Import workflow
   echo "Starting mitmproxy (Ctrl+C when done)..."
   mitmproxy -p 8080 -w traffic.mitm

   echo "Converting to OpenAPI..."
   mitmproxy2swagger -i traffic.mitm -o api_spec.yml -p "$1"

   echo "Generated: api_spec.yml"
   echo "Import to Postman: File → Import → api_spec.yml"

3. Save to ~/bin/ and make executable
4. Use: traffic-to-postman.sh https://api.target.com

Result: Reusable workflow automation
```

---

## Advanced Techniques

### Combined Frida + Ghidra Analysis
```
Reverse [app] with static + dynamic analysis:
1. Ghidra: Static analysis to find interesting functions
2. Frida: Hook those functions to see runtime behavior
3. Ghidra: Update analysis with runtime info
4. Frida: Test hypotheses about function behavior
5. Iterate until full understanding
```

### Container-Based RE Environment
```
Set up Docker environment for safe RE work:
1. Create container with all tools: mitmproxy, Frida, JADX, Ghidra
2. Volume mount for sharing files with host
3. Network configuration for proxy
4. X11 forwarding for GUI tools
5. Save as reusable image
```

### Automated Deobfuscation Pipeline
```
Build pipeline for JS deobfuscation:
1. Babel parse → AST
2. Custom visitor to simplify patterns
3. Rename variables based on usage
4. Remove dead code
5. Format with prettier
6. Save to git for diffing
```
