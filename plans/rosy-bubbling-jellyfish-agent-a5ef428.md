# UXP Extension Research for Adobe Premiere Pro

## Summary

This document contains research findings on UXP (Unified Extensibility Platform) extension architecture for Adobe Premiere Pro, including file structures, manifest format, network capabilities, and remote control solutions.

---

## 1. Key GitHub Repositories

### Official Adobe Samples
| Repository | Description | URL |
|------------|-------------|-----|
| **AdobeDocs/uxp-premiere-pro-samples** | Official Adobe sample panels | https://github.com/AdobeDocs/uxp-premiere-pro-samples |
| **AdobeDocs/uxp-premiere-pro** | Documentation repository | https://github.com/AdobeDocs/uxp-premiere-pro |
| **AdobeDocs/uxp-photoshop-plugin-samples** | Photoshop samples (WebSocket example) | https://github.com/AdobeDocs/uxp-photoshop-plugin-samples |

### Third-Party Remote Control Solutions
| Repository | Description | URL |
|------------|-------------|-----|
| **mikechambers/adb-mcp** | MCP agent for AI control of Adobe apps (Premiere, Photoshop, InDesign) | https://github.com/mikechambers/adb-mcp |
| **sebinside/PremiereRemote** | CEP-based HTTP/WebSocket remote control framework | https://github.com/sebinside/PremiereRemote |

---

## 2. UXP Extension File Structure

### Basic Premiere Pro UXP Plugin Structure
```
my-uxp-plugin/
├── manifest.json          # Plugin configuration (required)
├── index.html             # Main entry point
├── index.ts / index.js    # Main JavaScript/TypeScript
├── package.json           # npm dependencies
├── tsconfig.json          # TypeScript config (if using TS)
├── types.d.ts             # Type definitions
├── icons/
│   ├── dark.png           # Dark theme icon (23x23)
│   ├── light.png          # Light theme icon (23x23)
│   └── plugin-icon.png    # Plugin list icon (48x48)
├── src/                   # Source files
├── scripts/               # Compiled scripts
└── assets/                # Static assets
```

### Adobe Official Sample Structure
From `uxp-premiere-pro-samples/sample-panels/premiere-api/html/`:
```
html/
├── assets/
├── scripts/
├── src/
├── index.html
├── index.ts
├── manifest.json
├── package-lock.json
├── package.json
├── tsconfig.json
└── types.d.ts
```

---

## 3. Manifest.json Format (Version 5)

### Complete Example for Premiere Pro
```json
{
  "id": "com.adobe.ppro.samples",
  "name": "PremierePro UXP plugin Sample Project",
  "shortname": "3psample",
  "version": "1.0.0",
  "main": "index.html",
  "manifestVersion": 5,
  "host": {
    "app": "premierepro",
    "minVersion": "25.1.0"
  },
  "requiredPermissions": {
    "localFileSystem": "request",
    "clipboard": "readAndWrite",
    "network": {
      "domains": "all"
    }
  },
  "entrypoints": [
    {
      "id": "samplepanel",
      "type": "panel",
      "minimumSize": { "width": 430, "height": 500 },
      "maximumSize": { "width": 2000, "height": 2000 },
      "preferredDockedSize": { "width": 230, "height": 300 },
      "preferredFloatingSize": { "width": 400, "height": 300 },
      "label": { "default": "My Plugin Panel" },
      "icons": [
        {
          "width": 23, "height": 23,
          "path": "icons/dark.png",
          "scale": [1, 2],
          "theme": ["darkest", "dark", "medium"]
        },
        {
          "width": 23, "height": 23,
          "path": "icons/light.png",
          "scale": [1, 2],
          "theme": ["lightest", "light"]
        }
      ]
    }
  ],
  "icons": [
    {
      "width": 48, "height": 48,
      "path": "icons/plugin-icon.png",
      "scale": [1, 2],
      "theme": ["darkest", "dark", "medium", "lightest", "light", "all"],
      "species": ["pluginList"]
    }
  ]
}
```

### Required Fields for Development
| Field | Description | Example |
|-------|-------------|---------|
| `id` | Unique plugin identifier | `"com.mycompany.myplugin"` |
| `name` | Display name | `"My Plugin"` |
| `version` | Semantic version | `"1.0.0"` |
| `main` | Entry point file | `"index.html"` |
| `manifestVersion` | Schema version (use 5) | `5` |
| `host.app` | Target application | `"premierepro"` |
| `host.minVersion` | Minimum app version | `"25.1.0"` |
| `entrypoints` | Panel/command definitions | Array of entrypoint objects |

### Permission Options
```json
{
  "requiredPermissions": {
    "localFileSystem": "request" | "fullAccess",
    "clipboard": "read" | "readAndWrite",
    "network": {
      "domains": "all" | ["https://api.example.com", "wss://ws.example.com"]
    },
    "launchProcess": {
      "schemes": ["https", "http"]
    },
    "allowCodeGenerationFromStrings": true
  }
}
```

---

## 4. Network Requests in UXP

### Available APIs (Global Scope)
UXP provides these network APIs globally (no require/import needed):
- **fetch()** - Modern HTTP requests
- **XMLHttpRequest (XHR)** - Traditional AJAX
- **WebSocket** - Real-time bidirectional communication

### WebSocket Client Example
```javascript
// manifest.json must include network permission
const ws = new WebSocket("wss://example.com/socket");

ws.onopen = () => {
  console.log("Connected");
  ws.send("Hello Server");
};

ws.onmessage = (event) => {
  console.log("Received:", event.data);
};

ws.onerror = (error) => {
  console.error("WebSocket error:", error);
};

ws.onclose = () => {
  console.log("Disconnected");
};
```

### Network Manifest Configuration
```json
{
  "requiredPermissions": {
    "network": {
      "domains": [
        "https://api.example.com",
        "https://*.myservice.com",
        "wss://ws.example.com",
        "http://localhost:3001"
      ]
    }
  }
}
```

### Important Limitations
- **Domain names required**: IP addresses may not work with UXP network APIs
- **No wildcards in TLDs**: From UXP v7.4.0, `*.com` is not allowed
- **HTTP on macOS**: Photoshop only allows HTTP on Windows, not macOS (verify for Premiere)
- **WebSocket cookies**: HTTP requests can carry cookies, but WebSocket cannot

---

## 5. Server Capabilities: CLIENT ONLY

### Critical Limitation
**UXP extensions CANNOT run a server or listen on ports.** They can only act as clients.

UXP plugins can:
- Make outbound HTTP/HTTPS requests (fetch, XHR)
- Connect to WebSocket servers as a client
- Open external URLs via `launchProcess`

UXP plugins CANNOT:
- Listen on a port
- Accept incoming connections
- Run an HTTP server
- Act as a WebSocket server

### Workaround Architecture
To enable remote control of Premiere Pro via UXP, you need an external proxy server:

```
External App --> Node.js Proxy Server --> UXP Plugin (WebSocket client) --> Premiere Pro
                 (listens on port)        (connects out to proxy)
```

### Hybrid Plugins (Not Available for Premiere)
C++ Hybrid plugins can run servers, but:
- Only supported in Photoshop
- NOT supported in Premiere Pro or InDesign

---

## 6. Remote Control / API Solutions

### Option A: adb-mcp (Modern UXP + MCP)
**Repository**: https://github.com/mikechambers/adb-mcp

Architecture:
```
AI Client (Claude) <--> MCP Server (Python) <--> Node Proxy (ws://localhost:3001) <--> UXP Plugin <--> Premiere Pro
```

File structure for Premiere UXP plugin (`uxp/pr/`):
```
uxp/pr/
├── manifest.json
├── index.html
├── main.js           # WebSocket client using Socket.IO
├── socket.io.js      # Socket.IO client library
├── style.css
└── icons/
```

Key code pattern (main.js):
```javascript
const PROXY_URL = "http://localhost:3001";
const APPLICATION = "premiere";

function connectToServer() {
    socket = io(PROXY_URL, {
        transports: ["websocket"],
    });

    socket.on("connect", () => {
        socket.emit("register", { application: APPLICATION });
    });

    socket.on("command_packet", async (packet) => {
        // Execute Premiere commands and return results
        const result = await executeCommand(packet);
        socket.emit("command_response", result);
    });
}
```

### Option B: PremiereRemote (CEP-based, not UXP)
**Repository**: https://github.com/sebinside/PremiereRemote

Architecture (CEP can run servers via Node.js):
```
External App --> HTTP/WebSocket (localhost:8081/8082) --> CEP Extension --> Premiere Pro
```

Features:
- HTTP endpoints: `http://localhost:8081/functionName?param=value`
- WebSocket server on port 8082
- Swagger UI at `http://localhost:8081/api-docs/`
- AutoHotkey integration example

**Note**: This is CEP (Common Extensibility Platform), not UXP. CEP is being phased out.

---

## 7. Version Compatibility

| Premiere Pro Version | UXP Version | Notes |
|---------------------|-------------|-------|
| 25.1.0 | UXP 8.x | Minimum for samples |
| 25.2.0 | UXP 8.x | OAuth workflow sample |
| 25.3.0 | UXP 8.x | MCP agent requirement |
| 25.6.0 | UXP 8.1 | Latest documented |

**Important**: UXP in Premiere Pro is still in BETA (as of December 2024).

---

## 8. Development Tools

### UXP Developer Tool (UDT)
- Available through Creative Cloud Desktop
- Used to load, debug, and test plugins
- Click "Add Plugin" and select your `manifest.json`

### Build Process
Typical workflow:
```bash
npm install
npm run build    # Compiles TypeScript to JavaScript
# Then load via UDT
```

---

## 9. Key Takeaways for Building a Remote Control Extension

1. **Use WebSocket client pattern**: Your UXP plugin connects OUT to an external server
2. **Run a Node.js proxy server**: This accepts incoming connections and routes to the plugin
3. **Socket.IO works well**: Both adb-mcp and official examples use Socket.IO
4. **Manifest v5 is required**: Use `"manifestVersion": 5`
5. **Network permissions are mandatory**: Declare all domains in `requiredPermissions.network.domains`
6. **UXP is still beta for Premiere**: Expect changes and limitations

---

## Sources

- [Adobe UXP Premiere Pro Samples](https://github.com/AdobeDocs/uxp-premiere-pro-samples)
- [UXP Manifest Documentation](https://developer.adobe.com/premiere-pro/uxp/plugins/concepts/manifest/)
- [Premiere Pro UXP API](https://developer.adobe.com/premiere-pro/uxp/ppro_reference/)
- [adb-mcp Repository](https://github.com/mikechambers/adb-mcp)
- [PremiereRemote Repository](https://github.com/sebinside/PremiereRemote)
- [UXP WebSocket Example](https://github.com/AdobeDocs/uxp-photoshop-plugin-samples/tree/main/io-websocket-example)
- [Hyper Brew: Premiere Pro UXP Beta](https://hyperbrew.co/blog/premiere-pro-uxp-beta/)
- [Adobe Creative Cloud Developer Forums](https://forums.creativeclouddeveloper.com/)
