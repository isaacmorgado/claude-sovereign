# Ken Kai - Hacker / Reverse Engineering Courses

**Source:** https://www.kenkais.com/exclusive

These courses contain prompts and step-by-step guides for reverse engineering tasks using Claude Code.

---

# Extract Chrome Extensions

EXTRACT CHROME EXTENSIONS
MARK COMPLETE
Learn how to extract, analyze, and understand Chrome extensions. Get the source code from any installed extension or download extensions for offline analysis.
1
FIND INSTALLED EXTENSIONS ON MACOS
Chrome stores installed extensions in your user Library folder.
1
Open Finder
2
Press Cmd+Shift+G to open "Go to Folder"
3
Paste the extensions path
4
Each folder is an extension (named by its ID)
~/Library/Application Support/Google/Chrome/Default/Extensions
The folder name is the extension ID. You can find this in chrome://extensions with Developer mode enabled.
2
MATCH EXTENSION IDS TO NAMES
1
Open Chrome and go to chrome://extensions
2
Enable "Developer mode" in the top right
3
Each extension now shows its ID
4
Match the ID to the folder name in Finder
Copy the ID and use Cmd+F in Finder to quickly find the right folder.
3
DOWNLOAD CRX FILES USING CRX EXTRACTOR
To get extensions you haven't installed, use the CRX Extractor extension.
1
Install CRX Extractor from Chrome Web Store
2
Go to any extension page on the Chrome Web Store
3
Click the CRX Extractor icon in your toolbar
4
Choose "Download as CRX" or "Download as ZIP"
ZIP is easier to work with. CRX is just a ZIP with a special header.
4
USE ONLINE CRX VIEWER
For quick analysis without downloading, use crxviewer.com.
1
Go to https://robwu.nl/crxviewer/
2
Paste the Chrome Web Store URL
3
Browse the source code directly in browser
4
Download individual files or the full ZIP
https://robwu.nl/crxviewer/
Great for quick checks before installing an extension.
5
UNPACK A CRX FILE MANUALLY
A CRX file is just a ZIP with extra bytes at the start. Ask your coding agent to help extract it.
I have a CRX file at [path]. Extract it to a folder so I can read the source code. CRX files are ZIP files with a header - you may need to strip the header or just rename to .zip and unzip.
6
UNDERSTAND EXTENSION STRUCTURE
Every extension has these key files:
1
manifest.json - The extension's configuration, permissions, and entry points
2
background.js or service-worker.js - Background script that runs persistently
3
content.js - Scripts injected into web pages
4
popup.html - The popup UI when you click the extension icon
Start with manifest.json to understand what the extension does and what permissions it requests.
7
ANALYZE EXTENSION WITH YOUR CODING AGENT
Once extracted, ask your coding agent to analyze the extension code.
I extracted a Chrome extension to [folder path]. Read the manifest.json and explain:
1. What permissions does it request and why?
2. What does the background script do?
3. What content scripts are injected and on which sites?
4. Are there any privacy concerns?
Pay attention to permissions like "tabs", "webRequest", and "<all_urls>" - these give extensions significant access.
Progress: 0 / 7 steps completed

---

# Extract Electron Apps

EXTRACT ELECTRON APPS
MARK COMPLETE
Learn how to extract and explore the source code of Electron apps like VS Code, Discord, Slack, and more. Understand how these apps work under the hood.
1
INSTALL THE ASAR CLI
ASAR (Atom Shell Archive) is the format Electron uses to bundle app code. Install the CLI to extract it.
npm install -g @electron/asar
This gives you the asar command globally.
2
FIND THE APP BUNDLE ON MACOS
1
Right-click the app in Applications
2
Select "Show Package Contents"
3
Navigate to Contents/Resources
4
Look for app.asar or an app folder
Some apps use app.asar, others have an app folder directly. VS Code uses the app folder.
3
EXTRACT THE ASAR ARCHIVE
Use the asar CLI to extract the archive to a folder you can browse.
# Navigate to the Resources folder first
cd /Applications/AppName.app/Contents/Resources
# Extract to a folder
asar extract app.asar ./app-extracted
You can extract to any location. Use your Desktop or a temp folder for easy access.
4
EXTRACT USING YOUR CODING AGENT
Ask your coding agent to find and extract the app for you.
Find the Electron app bundle for [App Name] in /Applications, locate the app.asar file, and extract it to ~/Desktop/[app-name]-source so I can analyze it.
5
EXPLORE THE SOURCE CODE
Once extracted, you'll find:
1
package.json - App metadata and entry point
2
main.js or similar - Main process code
3
renderer/ or src/ - Frontend code
4
node_modules/ - Dependencies
Start with package.json to find the main entry point.
6
ANALYZE WITH YOUR CODING AGENT
Ask your coding agent to explain what you found.
I extracted an Electron app to [folder path]. Read the package.json and main entry files. Explain:
1. What is the app's architecture?
2. What are the main features based on the code structure?
3. What interesting patterns or techniques does it use?
7
COMMON ELECTRON APPS TO EXPLORE
These popular apps are built with Electron:
1
VS Code - /Applications/Visual Studio Code.app
2
Discord - /Applications/Discord.app
3
Slack - /Applications/Slack.app
4
Figma Desktop - /Applications/Figma.app
5
Notion - /Applications/Notion.app
6
Obsidian - /Applications/Obsidian.app
VS Code is particularly interesting because it's open source anyway, so you can compare the bundled code to the GitHub repo.
Progress: 0 / 7 steps completed

---

# JavaScript Deobfuscation

JAVASCRIPT DEOBFUSCATION
MARK COMPLETE
Learn techniques to make obfuscated, minified, or bundled JavaScript code readable. Essential for understanding extracted code from extensions and apps.
1
UNDERSTAND MINIFICATION VS OBFUSCATION
Minification removes whitespace and shortens names for smaller file size. Obfuscation intentionally makes code hard to understand.
1
Minified: function a(b,c){return b+c} - Just shortened
2
Obfuscated: var _0x1234=['\x72\x65\x74\x75\x72\x6e']; - Intentionally confusing
Minified code is easy to beautify. Obfuscated code requires more effort.
2
BEAUTIFY MINIFIED CODE
Start by formatting the code so it's readable.
1
Go to beautifier.io
2
Paste your minified JavaScript
3
Click "Beautify"
4
Copy the formatted result
https://beautifier.io/
This adds whitespace and indentation but doesn't change the code logic.
3
USE YOUR CODING AGENT TO BEAUTIFY
Ask your coding agent to format the code and explain what it does.
I have this minified JavaScript code:
[paste code here]
Beautify it with proper formatting, then explain what the code does.
4
DEOBFUSCATE WITH ONLINE TOOLS
For obfuscated code, use dedicated deobfuscation tools.
1
deobfuscate.io - Best for common obfuscation patterns
2
de4js - Another good option
3
jsnice.org - Adds meaningful variable names (legacy tool, HTTP only)
https://deobfuscate.io/
https://lelinhtinh.github.io/de4js/
http://jsnice.org/
Try multiple tools. Different obfuscators need different deobfuscators.
5
IDENTIFY COMMON OBFUSCATION PATTERNS
Learn to recognize these patterns:
1
Hex strings: '\x48\x65\x6c\x6c\x6f' = "Hello"
2
Array string lookup: var _0x1234=['log','Hello'];console[_0x1234[0]](_0x1234[1])
3
Base64 encoding: atob('SGVsbG8=') = "Hello"
4
Eval wrappers: eval(atob('...encoded code...'))
Obfuscators often combine multiple techniques. Work through them layer by layer.
6
USE YOUR CODING AGENT FOR ANALYSIS
Your coding agent can help identify patterns and explain obfuscated code.
I have this obfuscated JavaScript code:
[paste code here]
1. Identify what obfuscation techniques are being used
2. Deobfuscate it step by step
3. Explain what the deobfuscated code does
7
WORK WITH SOURCE MAPS
Some bundled code includes source maps that reveal original structure.
1
Look for //# sourceMappingURL=file.js.map at the end of JS files
2
Download the .map file if it exists
3
Use source-map-visualization or browser dev tools to view original code
https://sokra.github.io/source-map-visualization/
Source maps are often removed in production, but sometimes developers forget.
8
RENAME VARIABLES FOR CLARITY
After beautifying, ask your coding agent to rename variables based on their usage.
Here's some deobfuscated JavaScript where variables have meaningless names like a, b, _0x1234:
[paste code here]
Analyze what each variable/function does and rename them to meaningful names. Add comments explaining the code.
Progress: 0 / 8 steps completed

---

# Extract macOS Apps

EXTRACT MACOS APPS
MARK COMPLETE
Learn how to explore macOS application bundles, extract resources, and understand app structure. Works for native apps, not just Electron.
1
UNDERSTAND APP BUNDLE STRUCTURE
macOS apps are actually folders with a specific structure:
1
AppName.app/ - The bundle itself
2
Contents/ - Main container
3
Contents/MacOS/ - The actual executable
4
Contents/Resources/ - Assets, icons, data files
5
Contents/Info.plist - App metadata
6
Contents/Frameworks/ - Embedded libraries
The Finder shows .app bundles as single files, but they're really folders.
2
SHOW PACKAGE CONTENTS
1
Right-click any .app in Finder
2
Select "Show Package Contents"
3
Navigate the folder structure
4
Or use the command line
# Open the app bundle in Finder
open /Applications/AppName.app/Contents
This is a manual step. Navigate in Finder or use Terminal.
3
READ INFO.PLIST FOR APP DETAILS
Info.plist contains app metadata. Ask your coding agent to read and explain it.
Read the Info.plist file at /Applications/[AppName].app/Contents/Info.plist and explain:
1. What is the app's bundle identifier?
2. What version is this?
3. What frameworks or capabilities does it require?
4. Any interesting configuration?
4
EXPLORE RESOURCES FOLDER
The Resources folder contains assets, localizations, and data files. Ask your coding agent to help explore.
List and categorize the contents of /Applications/[AppName].app/Contents/Resources. Tell me:
1. What types of files are included?
2. Are there any interesting data files or configurations?
3. What localizations are supported?
5
EXTRACT DMG INSTALLER CONTENTS
DMG files are disk images. You can mount and explore them.
1
Double-click the DMG to mount it
2
Open the mounted volume in Finder
3
Copy files or explore contents
4
Eject when done
# Mount DMG from command line
hdiutil attach /path/to/file.dmg
# List mounted volumes
ls /Volumes/
# Unmount when done
hdiutil detach /Volumes/VolumeName
This is a manual step. Mount the DMG through Finder or Terminal.
6
EXTRACT PKG INSTALLER CONTENTS
PKG files are installer packages. You can extract without installing.
I have a .pkg installer file at [path]. Extract its contents to ~/Desktop/pkg-contents without running the installer. I want to see what files it would install.
7
FIND EMBEDDED BINARIES AND FRAMEWORKS
Apps often include helper executables and frameworks.
Find all executable files and frameworks inside /Applications/[AppName].app and list what they are. Check Contents/MacOS, Contents/Frameworks, and Contents/Helpers.
8
VIEW APP ENTITLEMENTS
Entitlements show what system permissions the app has.
Show me the entitlements for /Applications/[AppName].app/Contents/MacOS/[AppName] using codesign. Explain what each entitlement allows the app to do.
Progress: 0 / 8 steps completed

---

# Reverse Engineering Tools

REVERSE ENGINEERING TOOLS
MARK COMPLETE
An overview of professional reverse engineering tools for analyzing binaries, apps, and software. From free options like Ghidra to commercial tools like Hopper.
1
UNDERSTAND YOUR GOALS
Different tools for different needs:
1
JavaScript/Web code - Use deobfuscation tools (see JS Deobfuscation course)
2
Electron apps - Extract ASAR, read JavaScript (see Extract Electron Apps course)
3
Native macOS/iOS apps - Disassemblers like Ghidra or Hopper
4
Protocol analysis - Wireshark, Charles Proxy
5
Runtime analysis - Frida, LLDB
Start with the simplest approach. Don't use a disassembler if you just need to beautify JavaScript.
2
INSTALL GHIDRA (FREE, OPEN SOURCE)
Ghidra is the NSA's free reverse engineering tool. Powerful and actively maintained.
1
Download from GitHub (github.com/NationalSecurityAgency/ghidra)
2
Requires Java 21+ (install via brew install openjdk@21)
3
Extract the ZIP to /Applications or your preferred location
4
Run ghidraRun to launch
# Install Java if needed
brew install openjdk@21
# Download Ghidra from the official GitHub releases
open https://github.com/NationalSecurityAgency/ghidra/releases
This is a manual step. Download and install from the website.
3
INSTALL HOPPER DISASSEMBLER (MACOS FOCUSED)
Hopper is a commercial disassembler optimized for macOS and iOS binaries. Free demo available.
1
Download from hopperapp.com
2
Free version has limitations but is useful for learning
3
Full license is $99 for personal use
open https://www.hopperapp.com/
This is a manual step. Hopper's interface is more intuitive than Ghidra for beginners.
4
SET UP FRIDA FOR RUNTIME ANALYSIS
Frida lets you inject scripts into running applications to observe and modify behavior.
pip install frida-tools
Frida has a learning curve. Start with static analysis before moving to runtime analysis.
5
LOAD A BINARY IN GHIDRA
1
Launch Ghidra and create a new project
2
File > Import File
3
Select the binary (from Contents/MacOS in an app bundle)
4
Accept the default analysis options
5
Wait for auto-analysis to complete
6
Explore Functions, Strings, and Decompiled code
This is a manual step. Ghidra's analysis takes time but produces good results.
6
USE YOUR CODING AGENT FOR ANALYSIS HELP
While your coding agent can't run Ghidra directly, it can help analyze output.
I'm analyzing a binary in Ghidra and found this decompiled function:
[paste decompiled code]
Explain what this function does. What are the parameters and return value? Is there anything notable about the implementation?
7
INSTALL NETWORK ANALYSIS TOOLS
To understand what apps communicate:
1
Charles Proxy - HTTPS debugging proxy (paid, free trial)
2
Proxyman - Modern macOS alternative to Charles
3
Wireshark - Free and full-featured, but lower level
brew install --cask charles
# or
brew install --cask proxyman
# or
brew install --cask wireshark-app
This is a manual step. HTTPS interception requires trusting a root certificate.
8
USEFUL COMMAND LINE TOOLS
macOS includes several analysis tools:
1
strings - Find readable text in binaries
2
otool - Display object file headers and content
3
nm - List symbols from object files
4
codesign - View signing info and entitlements
5
class-dump - Generate headers from Objective-C binaries
# Find strings in a binary
strings /Applications/AppName.app/Contents/MacOS/AppName | head -100
# View linked libraries
otool -L /Applications/AppName.app/Contents/MacOS/AppName
# View entitlements
codesign -d --entitlements - /Applications/AppName.app
Progress: 0 / 8 steps completed

---

# Terminal Scripts & Hacks

TERMINAL SCRIPTS & HACKS
MARK COMPLETE
Practical scripts your coding agent can build and run. DNS benchmarking, network diagnostics, system optimization, and more.
1
DNS BENCHMARKING
Your internet speed isn't just about bandwidth - DNS resolution speed matters too. Different DNS servers perform differently depending on your location and ISP.
Write a script that tests DNS resolution speed against multiple DNS servers (Cloudflare 1.1.1.1, Google 8.8.8.8, Quad9 9.9.9.9, OpenDNS 208.67.222.222, and my ISP's default). Run 10 iterations for each, measure the response time, and show me the average. Tell me which one is fastest for my connection.
The agent will write a bash or Python script, run it, and analyze the results for you. You might be surprised which DNS is actually fastest from your location.
2
INTERNET CONNECTION QUALITY TEST
Beyond just speed tests, you want to know about latency, jitter, and packet loss - especially if you're on video calls or gaming.
Write a script that monitors my internet connection quality over 5 minutes. Ping multiple reliable servers (Google, Cloudflare, AWS), track latency, jitter, and packet loss. Give me a summary of the connection stability and flag any issues.
Run this when you suspect connection issues. The data helps when complaining to your ISP.
3
PORT SCANNER FOR YOUR NETWORK
See what devices are on your network and what ports they have open. Useful for security audits of your own network.
Scan my local network (192.168.1.0/24 or whatever my range is) and show me all active devices with their IP addresses, MAC addresses if possible, and any open ports. Format it nicely.
Only scan networks you own or have permission to scan. This is for your home/office network security.
4
BULK FILE OPERATIONS
Renaming hundreds of files, converting formats, organizing by date - tedious by hand, trivial for your agent.
Rename files:
Rename all .jpeg files in this folder to .jpg and make the filenames lowercase
Other examples: Move all photos in ~/Downloads to folders organized by year/month based on their creation date or Convert all .png files in this folder to .webp with 80% quality
5
SYSTEM RESOURCE MONITOR
Build a custom dashboard that shows exactly what you care about.
Create a script that runs continuously and shows me: CPU usage, memory usage, disk space, network traffic, and the top 5 processes by CPU. Update every 2 seconds. Make it look clean in the terminal.
You can customize this to monitor specific processes, alert on thresholds, or log to a file.
6
GIT REPOSITORY ANALYZER
Get insights about your codebase that GitHub doesn't show you.
Analyze this git repository and tell me: total lines of code by language, largest files, most frequently changed files, commit frequency over time, and contributors ranked by commits. Show me any files that might be problematic (too large, too many changes).
7
API HEALTH CHECKER
Monitor your APIs or services you depend on.
Create a script that checks these endpoints every 30 seconds: [list your URLs]. Log response times and status codes. Alert me (print to console with timestamp) if any endpoint takes longer than 2 seconds or returns non-200.
Useful for monitoring your own deployed services or third-party APIs you depend on.
8
LOG FILE ANALYZER
When something goes wrong, logs have the answers - if you can find them.
Analyze these log files and find: all errors and warnings (group by type), any patterns in when errors occur, IP addresses making the most requests, and any suspicious activity. Summarize what you find.
9
BACKUP VERIFICATION
Backups are useless if they're corrupted or incomplete.
Compare my backup folder with the source folder. Check that all files exist in the backup, verify file sizes match, and identify any files that are in the backup but deleted from source. Tell me if my backup is complete and current.
10
CUSTOM CLI TOOLS
Build tools that fit your exact workflow. If you can describe it, your agent can build it and run it.
Create a CLI tool that takes a YouTube URL and downloads just the audio as MP3
Other examples: Build a tool that takes a URL, screenshots the page, and saves it with today's date or Make a script that watches a folder and automatically uploads new files to my S3 bucket
Progress: 0 / 10 steps completed

---

# Web Scraping & Data Extraction

WEB SCRAPING & DATA EXTRACTION
MARK COMPLETE
Have your coding agent build scrapers for any website. Extract data, handle pagination, export to CSV/JSON.
1
BASIC PAGE SCRAPING
Start simple - extract data from a single page. Your agent will inspect the page structure and pull out what you need.
Scrape [URL] and extract all the [product names/prices/titles/etc]. Return the data as a JSON array.
Be specific about what data you want. "All the product info" is vague. "Product name, price, and rating" is clear.
2
HANDLING MULTIPLE PAGES
Most useful data spans multiple pages. Your agent can handle pagination automatically.
Scrape all pages of [URL] - it has pagination. Extract [data fields] from each item and combine into a single CSV file.
For sites with "Load More" buttons instead of page numbers, mention that - it requires different handling.
3
SCRAPING SEARCH RESULTS
Search pages are goldmines of structured data. Your agent can scrape results for any query.
Search [site] for "[query]" and scrape the first 100 results. Extract [title, URL, description, etc] and save to a JSON file.
4
EXTRACTING TABLES
Tables are the easiest to scrape - they're already structured. Perfect for financial data, sports stats, research data.
Extract the table from [URL] and convert it to a CSV file. Preserve the column headers.
If there are multiple tables on the page, specify which one: "the second table" or "the table with stock prices".
5
SCRAPING WITH AUTHENTICATION
Some data requires logging in. Your agent can handle authenticated sessions.
Log into [site] with my credentials and scrape [data] from my dashboard/account page. Save my session so I don't have to log in every time.
Never paste passwords directly in chat. Your agent will prompt you to enter credentials securely or use environment variables.
6
HANDLING DYNAMIC CONTENT
Modern sites load content with JavaScript. Your agent can use browser automation to wait for content to load.
This site loads content dynamically with JavaScript. Use a headless browser to scrape [URL] and extract [data] after the page fully loads.
7
MONITORING FOR CHANGES
Set up scrapers that run on a schedule and alert you when something changes.
Create a script that checks [URL] every hour for price changes on [product]. Save the history to a file and alert me if the price drops below [amount].
8
BUILDING A REUSABLE SCRAPER
For sites you scrape regularly, have your agent build a proper tool you can run anytime.
Build a reusable scraper for [site] that I can run with different search queries. Accept the query as a command line argument and output results to CSV.
Ask your agent to add error handling, rate limiting, and retry logic for production use.
Progress: 0 / 8 steps completed

---

# API Reverse Engineering

API REVERSE ENGINEERING
MARK COMPLETE
Figure out how apps communicate with their servers. Discover undocumented APIs and build your own clients.
1
SET UP TRAFFIC INTERCEPTION
First, you need to see what requests an app is making. Charles Proxy or mitmproxy lets you inspect all HTTP traffic.
Help me set up Charles Proxy (or mitmproxy) to intercept HTTPS traffic from my browser and apps. Include SSL certificate installation.
Charles has a free trial. mitmproxy is free and open source but more technical.
2
CAPTURE APP TRAFFIC
With the proxy running, use the app normally. Every action generates API requests you can inspect.
I've captured traffic from [app]. Here are the requests I see: [paste relevant requests]. Help me understand what each endpoint does.
Focus on requests to the app's domain. Ignore analytics, ads, and third-party services.
3
UNDERSTAND AUTHENTICATION
Most APIs require authentication. Figure out how the app authenticates - API keys, OAuth tokens, session cookies.
Here's a request that requires auth: [paste request with headers]. What authentication method is this using? How can I get my own token?
4
MAP THE API ENDPOINTS
Document the endpoints you discover. Your agent can help organize them into a clear reference.
I've captured these endpoints from [app]: [list endpoints]. Help me document them - what each does, required parameters, and response format.
5
REPLAY REQUESTS
Test your understanding by replaying requests. Your agent can use curl or write a script.
Write a script to call this endpoint: [paste request details]. Use my auth token and show me the response.
6
BUILD A CLIENT
Once you understand the API, your agent can build a proper client library or CLI tool.
Build a CLI tool that interacts with [service] API. Include commands for: [list operations]. Handle authentication and error responses.
7
HANDLE API CHANGES
Undocumented APIs can change without notice. Build in version detection and graceful degradation.
Add error handling to the client that detects when the API has changed. Log the unexpected response so I can update the client.
Keep captured requests as reference. When something breaks, compare new traffic to old.
Progress: 0 / 7 steps completed

---

# Browser Automation

BROWSER AUTOMATION
MARK COMPLETE
Automate anything you do in a browser. Your coding agent builds Playwright scripts that click, type, and navigate for you.
1
SET UP PLAYWRIGHT
Playwright is the modern choice for browser automation. Your agent will install it and set up a project.
Set up a Playwright project for browser automation. Install the browsers and create a basic test script that opens a page and takes a screenshot.
2
AUTOMATE A SIMPLE TASK
Start simple - navigate to a page and extract information.
Write a Playwright script that goes to [URL], waits for the page to load, and extracts [specific data]. Print it to the console.
Playwright waits for elements automatically, but dynamic sites may need explicit waits.
3
FILL AND SUBMIT FORMS
Automate data entry - login forms, search boxes, multi-step forms.
Write a script that goes to [URL], fills in [form fields with values], and clicks submit. Handle any confirmation or success page.
4
HANDLE LOGIN SESSIONS
Save authenticated sessions so you don't log in every time.
Create a script that logs into [site], saves the session/cookies to a file, and reuses them in future runs so I don't have to log in every time.
Store credentials in environment variables, not in the script.
5
SCREENSHOT AND PDF GENERATION
Capture pages as images or PDFs. Great for reports, archiving, or monitoring.
Write a script that takes a full-page screenshot of [URL] and saves it with today's date in the filename. Also generate a PDF version.
6
MULTI-STEP WORKFLOWS
Chain actions together for complex workflows - navigate, click, wait, extract, repeat.
Automate this workflow: 1) Log into [site], 2) Navigate to [section], 3) Click [button], 4) Fill [form], 5) Download the generated report.
7
HANDLING DYNAMIC CONTENT
Modern sites load content dynamically. Your agent can wait for specific elements or network requests.
The content on [URL] loads after the initial page. Wait for [specific element or text] to appear before extracting data.
8
RUNNING ON A SCHEDULE
Set up automations to run automatically - hourly, daily, or on specific triggers.
Create a cron job (or scheduled task) that runs this Playwright script every morning at 9am and emails me the results.
9
HANDLING ERRORS GRACEFULLY
Production automations need error handling. Retry failed actions, log issues, alert on failures.
Add error handling to this script: retry failed actions 3 times, take a screenshot on failure, and send me a notification if it fails completely.
Progress: 0 / 9 steps completed

---

