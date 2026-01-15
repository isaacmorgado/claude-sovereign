# Ken Kai - Hacker / Reverse Engineering Courses

**Source:** https://www.kenkais.com/exclusive

---

## 1. Extract Chrome Extensions

Learn how to extract, analyze, and understand Chrome extensions. Get the source code from any installed extension or download extensions for offline analysis.

### What This Is
A guide to extracting Chrome extension source code. Covers finding installed extensions, downloading CRX files, unpacking extension bundles, and understanding extension structure.

### What You'll Learn
- Locating installed extensions on your system
- Downloading CRX files from the Chrome Web Store
- Unpacking and exploring extension source code
- Understanding manifest.json and extension structure
- Using your coding agent to analyze extension code

### Why It Matters
Understanding how extensions work helps you learn from others, audit extensions for privacy/security, and build your own. Sometimes you need to check what an extension actually does before trusting it with your data.

---

## 2. Extract Electron Apps

Learn how to extract and explore the source code of Electron apps like VS Code, Discord, Slack, and more. Understand how these apps work under the hood.

### What This Is
A guide to unpacking Electron applications. Electron apps bundle HTML, CSS, and JavaScript inside an ASAR archive. This course teaches you how to extract and analyze that code.

### What You'll Learn
- Understanding Electron app structure
- Extracting ASAR archives with the asar CLI
- Finding the source code inside app bundles
- Analyzing Electron app code with your coding agent
- Common locations for Electron app resources

### Why It Matters
Many popular apps are built with Electron. Understanding their structure helps you learn modern JavaScript practices, debug issues, customize behavior, and understand what apps are really doing on your system.

---

## 3. JavaScript Deobfuscation

Learn techniques to make obfuscated, minified, or bundled JavaScript code readable. Essential for understanding extracted code from extensions and apps.

### What This Is
A guide to reversing JavaScript obfuscation and minification. Covers beautification, deobfuscation tools, understanding common obfuscation patterns, and using your coding agent to help analyze transformed code.

### What You'll Learn
- Beautifying minified JavaScript
- Using online deobfuscation tools
- Recognizing common obfuscation patterns
- Using your coding agent to analyze obfuscated code
- Working with source maps when available

### Why It Matters
Most production JavaScript is minified or obfuscated. To understand extracted code from extensions, Electron apps, or websites, you need to know how to make it readable again.

---

## 4. Extract macOS Apps

Learn how to explore macOS application bundles, extract resources, and understand app structure. Works for native apps, not just Electron.

### What This Is
A guide to exploring macOS application bundles. Covers the .app bundle structure, extracting resources, viewing embedded files, and understanding how native macOS apps are packaged.

### What You'll Learn
- Understanding .app bundle structure
- Using "Show Package Contents" effectively
- Finding and extracting embedded resources
- Working with DMG and PKG installers
- Using command-line tools for extraction

### Why It Matters
Understanding app bundles helps you find resources, troubleshoot issues, understand how apps work, and learn about macOS app development patterns.

---

## 5. Reverse Engineering Tools

An overview of professional reverse engineering tools for analyzing binaries, apps, and software. From free options like Ghidra to commercial tools like Hopper.

### What This Is
A guide to reverse engineering tools and techniques. Covers disassemblers, debuggers, and analysis tools for understanding compiled binaries and applications.

### What You'll Learn
- Overview of popular reverse engineering tools
- When to use each type of tool
- Setting up Ghidra for binary analysis
- Using Hopper Disassembler for macOS apps
- Understanding what these tools can and cannot do

### Why It Matters
Reverse engineering helps you understand how software works, analyze malware, audit security, and learn from existing implementations. These are professional tools used by security researchers.

---

## 6. Terminal Scripts & Hacks

Practical scripts your coding agent can build and run. DNS benchmarking, network diagnostics, system optimization, and more.

### What This Is
A collection of practical scripts and automation that your coding agent can build and execute directly in your terminal. These aren't theoretical exercises - they're tools that solve real problems. Test which DNS server is fastest for you, monitor your network, automate tedious tasks, and more.

### What You'll Learn
- How to ask your coding agent to build and run diagnostic scripts
- DNS benchmarking to find the fastest servers for your location
- Network monitoring and troubleshooting tools
- System information and optimization scripts
- Automation for repetitive tasks

### Why It Matters
Most people don't realize their coding agent can do more than write code - it can run scripts, analyze output, and iterate until the problem is solved. These examples show you what's possible when you start thinking of your agent as a tool that can interact with your system.

---

## 7. Web Scraping & Data Extraction

Have your coding agent build scrapers for any website. Extract data, handle pagination, export to CSV/JSON.

### What This Is
Web scraping is extracting data from websites programmatically. Instead of manually copying information, your coding agent can build scripts that pull exactly the data you need - product prices, job listings, contact info, research data, whatever. The agent handles the technical complexity while you describe what you want.

### What You'll Learn
- How to describe scraping tasks to your coding agent
- Extracting structured data from any website
- Handling pagination, authentication, and dynamic content
- Exporting data to CSV, JSON, or databases
- Respecting rate limits and robots.txt

### Why It Matters
Data is everywhere, but it's often trapped in websites without APIs. Scraping lets you unlock that data for analysis, monitoring, research, or building your own tools. With a coding agent, you don't need to learn the technical details - you just describe what data you want.

---

## 8. API Reverse Engineering

Figure out how apps communicate with their servers. Discover undocumented APIs and build your own clients.

### What This Is
Every app that shows you data is fetching it from somewhere. API reverse engineering is figuring out how apps talk to their servers - what endpoints they hit, what data they send, what comes back. Once you understand the API, your coding agent can build tools that interact with it directly.

### What You'll Learn
- Intercepting network traffic with proxy tools
- Understanding API request/response patterns
- Authenticating with undocumented APIs
- Building custom clients for any service
- When to use this vs official APIs or scraping

### Why It Matters
Official APIs are limited or don't exist for many services. But if there's an app, there's an API behind it. Reverse engineering lets you access data and functionality that isn't officially exposed - building integrations, automations, or tools the company never intended.

---

## 9. Browser Automation

Automate anything you do in a browser. Your coding agent builds Playwright scripts that click, type, and navigate for you.

### What This Is
Browser automation is scripting a real browser to do things automatically - clicking buttons, filling forms, navigating pages, taking screenshots. Tools like Playwright control Chrome/Firefox/Safari programmatically. Your coding agent writes the scripts. You just describe what you want to automate.

### What You'll Learn
- Describing browser tasks for your coding agent
- Automating repetitive web workflows
- Handling logins, forms, and dynamic content
- Taking screenshots and generating PDFs
- Running automations on a schedule

### Why It Matters
We spend hours doing repetitive browser tasks - checking things, filling forms, downloading reports, updating spreadsheets. Browser automation handles the tedium so you can focus on work that matters. If you can do it manually, your agent can automate it.

---

## Quick Reference

| Course | Focus | Tools |
|--------|-------|-------|
| Extract Chrome Extensions | CRX files, manifest.json | Chrome DevTools, CRX Extractor |
| Extract Electron Apps | ASAR archives | asar CLI, npx |
| JavaScript Deobfuscation | Minified/obfuscated JS | Beautifiers, deobfuscators |
| Extract macOS Apps | .app bundles, DMG | Terminal, Finder |
| Reverse Engineering Tools | Binary analysis | Ghidra, Hopper, Frida |
| Terminal Scripts & Hacks | System automation | Bash, Python |
| Web Scraping | Data extraction | Playwright, BeautifulSoup |
| API Reverse Engineering | Traffic interception | Charles, mitmproxy |
| Browser Automation | Web automation | Playwright, Puppeteer |
