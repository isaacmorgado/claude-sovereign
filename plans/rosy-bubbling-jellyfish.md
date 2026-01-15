# Custom Premiere Pro Razor API - Implementation Plan

## Overview
Create a custom API for Premiere Pro that exposes razor tool functionality (missing from UXP) and enables external automation, AI/ML integration, and batch processing.

**Architecture:** UXP Plugin + Node.js Keystroke Server (No CEP required!)

## Quick Reference: Key Repositories

| Repo | Purpose | URL |
|------|---------|-----|
| **adb-mcp** ⭐ | MCP + Proxy + UXP for Premiere | [github.com/mikechambers/adb-mcp](https://github.com/mikechambers/adb-mcp) |
| **Bolt UXP** | Modern UXP framework (Vite/TS/React/Vue) | [github.com/hyperbrew/bolt-uxp](https://github.com/hyperbrew/bolt-uxp) |
| **UXP Premiere Samples** | Official Adobe UXP samples | [github.com/AdobeDocs/uxp-premiere-pro-samples](https://github.com/AdobeDocs/uxp-premiere-pro-samples) |
| **node-osascript** | Execute AppleScript from Node.js | [npmjs.com/package/node-osascript](https://www.npmjs.com/package/node-osascript) |

## Key Findings: Why We Use Keyboard Simulation

### UXP API Limitations (Confirmed by Adobe)
- **No razor/cut API exists in UXP** - Adobe confirmed: "There is not yet any UXP API that mimics the razor tool"
- **`createSetInPointAction` and `createSetOutPointAction` are BROKEN** as of v25.4.0
- Clone+Trim workaround is not viable due to broken APIs
- UXP can only make **outbound** WebSocket connections (cannot host servers)

### Solution: Keyboard Simulation via osascript
Since there's no API for cuts, we trigger the native Cmd+K shortcut via macOS automation:
- UXP plugin connects to a local Node.js WebSocket server
- Server executes osascript to send keystrokes to Premiere Pro
- This approach requires no CEP and is future-proof

## Architecture: UXP + Node.js + osascript (No CEP!)

```
┌─────────────────┐    WebSocket     ┌──────────────────┐    osascript    ┌─────────────────┐
│   UXP Plugin    │─────────────────>│  Node.js Server  │────────────────>│  Premiere Pro   │
│   (UI + Logic)  │    (outbound)    │  (localhost:8080)│    (Cmd+K)      │  (receives key) │
└─────────────────┘                  └──────────────────┘                 └─────────────────┘
        │                                    ▲
        │ UXP API                            │ HTTP/WebSocket
        ▼                                    │
┌─────────────────┐                  ┌───────────────────┐
│  Premiere Pro   │                  │  External Clients │
│  (Get info via  │                  │  (Python, AI, CLI)│
│   UXP APIs)     │                  └───────────────────┘
└─────────────────┘
```

**Why this architecture:**
1. **No CEP required** - Future-proof, no Sept 2026 deprecation concern
2. **UXP for data access** - Get sequence info, clip positions, playhead via UXP APIs
3. **Keyboard simulation for cuts** - Cmd+K via osascript (the only way that works)
4. **External API** - Python/AI can connect to the same Node.js server

## Requirements
- macOS (osascript is macOS-only; Windows would need AutoHotkey alternative)
- Node.js for the keystroke server
- Accessibility permissions for Terminal/Node in System Settings > Privacy & Security > Accessibility
- Premiere Pro 25.1+ for UXP support

---

## Components to Build

### 1. UXP Plugin (Main UI + WebSocket Client)
**Purpose:** User interface panel + WebSocket client to keystroke server + Premiere API access

**Location:** Load via UXP Developer Tool or package for distribution

**Key Files:**
```
com.yourname.premiere-razor/
├── manifest.json             # UXP manifest v5
├── index.html                # Entry point
├── main.js                   # Plugin logic + UI
├── ws-client.js              # WebSocket client to keystroke server
├── premiere-api.js           # Wrapper for Premiere UXP APIs
├── package.json              # Dependencies
└── icons/
    ├── dark.png              # 23x23
    └── light.png             # 23x23
```

**manifest.json:**
```json
{
  "id": "com.yourname.premiere-razor",
  "name": "Razor API",
  "version": "1.0.0",
  "main": "index.html",
  "manifestVersion": 5,
  "host": { "app": "premierepro", "minVersion": "25.1.0" },
  "requiredPermissions": {
    "network": { "domains": ["ws://localhost:8080"] }
  },
  "entrypoints": [{
    "id": "razorpanel",
    "type": "panel",
    "label": { "default": "Razor API" }
  }]
}
```

**UXP Plugin Code (main.js):**
```javascript
const premiere = require('premiere');

// WebSocket connection to keystroke server
let ws = null;

function connectToServer() {
    ws = new WebSocket('ws://localhost:8080');
    ws.onopen = () => console.log('Connected to keystroke server');
    ws.onmessage = (event) => {
        const response = JSON.parse(event.data);
        console.log('Server response:', response);
    };
    ws.onerror = (error) => console.error('WebSocket error:', error);
    ws.onclose = () => setTimeout(connectToServer, 3000); // Reconnect
}

// Premiere Pro API functions
async function getPlayheadPosition() {
    const project = await premiere.project.getActiveProject();
    const sequence = await project.getActiveSequence();
    const position = await sequence.getPlayerPosition();
    return position.seconds;
}

async function setPlayheadPosition(seconds) {
    const project = await premiere.project.getActiveProject();
    const sequence = await project.getActiveSequence();
    const tickTime = await premiere.TickTime.createWithSeconds(seconds);
    await sequence.setPlayerPosition(tickTime);
}

async function getSequenceInfo() {
    const project = await premiere.project.getActiveProject();
    const sequence = await project.getActiveSequence();
    return {
        name: await sequence.getName(),
        duration: (await sequence.getEndTime()).seconds,
        videoTrackCount: (await sequence.getVideoTracks()).length,
        audioTrackCount: (await sequence.getAudioTracks()).length
    };
}

// UI Button handlers
async function cutAtPlayhead() {
    if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send('cut-at-playhead');
    }
}

async function batchCut(times) {
    for (const time of times) {
        await setPlayheadPosition(time);
        await new Promise(resolve => setTimeout(resolve, 500)); // Wait for Premiere
        ws.send('cut-at-playhead');
        await new Promise(resolve => setTimeout(resolve, 500)); // Wait for cut
    }
}

// Initialize on plugin load
connectToServer();
```

---

### 2. Keystroke Server (Node.js + osascript)
**Purpose:** Execute keyboard shortcuts in Premiere Pro via macOS automation

**Location:** Standalone Node.js process (run in background)

**Key Files:**
```
keystroke-server/
├── index.js                  # WebSocket server + osascript execution
├── package.json              # Dependencies (ws)
├── shortcuts.js              # Keyboard shortcut definitions
└── README.md                 # Setup instructions
```

**package.json:**
```json
{
  "name": "premiere-keystroke-server",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "ws": "^8.14.0"
  }
}
```

**index.js:**
```javascript
const WebSocket = require('ws');
const { exec } = require('child_process');

const PORT = 8080;
const wss = new WebSocket.Server({ port: PORT });

// Keyboard shortcuts mapping
const shortcuts = {
    'cut-at-playhead': 'keystroke "k" using command down',
    'cut-all-tracks': 'keystroke "k" using {command down, shift down}',
    'razor-tool': 'keystroke "c"',
    'selection-tool': 'keystroke "v"',
    'delete-selection': 'key code 51', // Backspace
    'ripple-delete': 'key code 51 using shift down',
    'save': 'keystroke "s" using command down',
    'undo': 'keystroke "z" using command down',
    'redo': 'keystroke "z" using {command down, shift down}'
};

// Get Premiere Pro app name (handles different versions)
const PREMIERE_APP = 'Adobe Premiere Pro';

wss.on('connection', (ws, req) => {
    console.log(`Client connected from ${req.socket.remoteAddress}`);

    ws.on('message', (message) => {
        const cmd = message.toString().trim();
        console.log(`Received command: ${cmd}`);

        // Handle set-playhead command (forwarded back to UXP)
        if (cmd.startsWith('set-playhead:')) {
            ws.send(JSON.stringify({ type: 'set-playhead', time: cmd.split(':')[1] }));
            return;
        }

        const keystroke = shortcuts[cmd];
        if (keystroke) {
            // Activate Premiere, wait, then send keystroke
            const script = `
                tell application "${PREMIERE_APP}" to activate
                delay 0.3
                tell application "System Events" to ${keystroke}
            `;

            exec(`osascript -e '${script}'`, (error, stdout, stderr) => {
                if (error) {
                    console.error(`Error: ${error.message}`);
                    ws.send(JSON.stringify({ success: false, error: error.message }));
                } else {
                    ws.send(JSON.stringify({ success: true, command: cmd }));
                }
            });
        } else {
            ws.send(JSON.stringify({ success: false, error: `Unknown command: ${cmd}` }));
        }
    });

    ws.on('close', () => console.log('Client disconnected'));
});

console.log(`Keystroke server running on ws://localhost:${PORT}`);
console.log('Available commands:', Object.keys(shortcuts).join(', '));
```

---

### 3. Python Client Library (for AI/ML)
**Purpose:** Easy Python access for AI/ML workflows

```python
# premiere_api.py
import asyncio
import websockets
import json

class PremiereAPI:
    def __init__(self, ws_url="ws://localhost:8080"):
        self.ws_url = ws_url
        self.ws = None

    async def connect(self):
        self.ws = await websockets.connect(self.ws_url)
        print("Connected to Premiere keystroke server")

    async def disconnect(self):
        if self.ws:
            await self.ws.close()

    async def send_command(self, command: str) -> dict:
        await self.ws.send(command)
        response = await self.ws.recv()
        return json.loads(response)

    async def cut_at_playhead(self) -> dict:
        """Trigger Cmd+K to cut at current playhead position"""
        return await self.send_command("cut-at-playhead")

    async def cut_all_tracks(self) -> dict:
        """Trigger Shift+Cmd+K to cut all tracks"""
        return await self.send_command("cut-all-tracks")

    async def undo(self) -> dict:
        """Trigger Cmd+Z to undo"""
        return await self.send_command("undo")

    async def save(self) -> dict:
        """Trigger Cmd+S to save"""
        return await self.send_command("save")


# Synchronous wrapper for simple usage
class PremiereAPISync:
    def __init__(self, ws_url="ws://localhost:8080"):
        self.api = PremiereAPI(ws_url)

    def __enter__(self):
        asyncio.get_event_loop().run_until_complete(self.api.connect())
        return self

    def __exit__(self, *args):
        asyncio.get_event_loop().run_until_complete(self.api.disconnect())

    def cut_at_playhead(self):
        return asyncio.get_event_loop().run_until_complete(self.api.cut_at_playhead())


# Usage example
if __name__ == "__main__":
    with PremiereAPISync() as api:
        result = api.cut_at_playhead()
        print(result)
```

---

## Implementation Steps

### Phase 1: Keystroke Server
1. Create `keystroke-server/` directory
2. Initialize npm project and install `ws` dependency
3. Implement WebSocket server with osascript execution
4. Test with simple WebSocket client (wscat or browser)
5. Grant Accessibility permissions to Terminal/Node

### Phase 2: UXP Plugin
1. Create UXP plugin folder structure
2. Write manifest.json with network permissions
3. Implement WebSocket client connecting to keystroke server
4. Add Premiere API wrappers (getPlayheadPosition, setPlayheadPosition)
5. Create UI with buttons for cut operations
6. Load plugin via UXP Developer Tool and test

### Phase 3: Batch Processing
1. Implement batch cut logic in UXP (loop with setPlayhead + cut)
2. Add queue management for multiple operations
3. Handle timing/delays between operations
4. Add progress UI feedback

### Phase 4: Python Client & AI Integration
1. Create Python client library with websockets
2. Add async and sync wrappers
3. Create example scripts for common workflows
4. Document API for external tools

### Phase 5: Polish & Distribution
1. Add error handling and reconnection logic
2. Create installer/setup script for keystroke server
3. Package UXP plugin for distribution
4. Write documentation

---

## Files to Create

### Keystroke Server
- `keystroke-server/index.js`
- `keystroke-server/package.json`
- `keystroke-server/README.md`

### UXP Plugin
- `com.yourname.premiere-razor/manifest.json`
- `com.yourname.premiere-razor/index.html`
- `com.yourname.premiere-razor/main.js`
- `com.yourname.premiere-razor/ws-client.js`
- `com.yourname.premiere-razor/premiere-api.js`
- `com.yourname.premiere-razor/styles.css`
- `com.yourname.premiere-razor/icons/dark.png`
- `com.yourname.premiere-razor/icons/light.png`

### Python Client
- `python-client/premiere_api.py`
- `python-client/requirements.txt`
- `python-client/examples/batch_cut.py`

---

## Technical Notes

### Accessibility Permissions (Required!)
1. Open System Settings > Privacy & Security > Accessibility
2. Click the lock to make changes
3. Add Terminal (or your Node.js app) to the list
4. Toggle it ON
5. You may need to restart Terminal after granting permission

### Premiere Pro App Name
Different versions have different app names:
- `Adobe Premiere Pro 2024`
- `Adobe Premiere Pro 2025`
- `Adobe Premiere Pro`

Use the generic name or detect dynamically:
```javascript
const { exec } = require('child_process');
exec("osascript -e 'tell application \"System Events\" to name of first process whose name contains \"Premiere\"'");
```

### Timing Considerations
- Add 0.3-0.5 second delay after activating Premiere before sending keystrokes
- Add 0.5 second delay between batch operations for Premiere to process
- Longer sequences may need larger delays

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Premiere loses focus | Always activate Premiere before sending keystroke |
| Keystroke too fast | Add configurable delays |
| Connection drops | Auto-reconnect in UXP plugin |
| macOS only (osascript) | Document Windows alternative (AutoHotkey) |
| UXP API changes | Monitor Adobe UXP changelog |

---

## Success Criteria
- [ ] Keystroke server runs and accepts WebSocket connections
- [ ] Cut at playhead works from UXP panel button
- [ ] Cut works from Python script
- [ ] Batch cuts work with proper timing
- [ ] Server auto-starts on login (optional)
