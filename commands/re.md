---
description: Automated reverse engineering - extract, analyze, deobfuscate
argument-hint: "<type> <target> [--output name]"
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep", "Task"]
---

# /re - Reverse Engineering Skill

> **Automated extraction and analysis** - not just documentation.
> Execute actual RE commands and return structured results.

## Quick Usage

```
/re chrome ~/Downloads/extension.crx      # Extract Chrome extension
/re electron /Applications/Discord.app    # Extract Electron app source
/re deobfuscate ./bundle.min.js           # Make JS readable
/re macos /Applications/App.app           # Explore macOS app bundle
/re api https://api.target.com            # Start API research
/re analyze ./unknown-target              # Auto-detect and analyze
```

## Instructions

Parse the arguments from: $ARGUMENTS

### Step 1: Execute the RE Skill

The RE skill at `~/.claude/skills/re.sh` handles all extraction and analysis automatically.

**Parse the command type from arguments:**

```bash
# Extract command and target from arguments
ARGS="$ARGUMENTS"
CMD=$(echo "$ARGS" | awk '{print $1}')
TARGET=$(echo "$ARGS" | awk '{print $2}')

# Execute the appropriate RE skill command
~/.claude/skills/re.sh "$CMD" "$TARGET"
```

### Step 2: Report Results

After execution, the skill returns structured JSON with:
- Extraction location
- Analysis results
- Security findings
- Next step recommendations

**Present the key findings to the user in a clear format.**

---

## Command Reference

### Chrome Extension (`/re chrome <path>`)

Extracts and analyzes Chrome extensions from:
- `.crx` files (auto-handles CRX2/CRX3 headers)
- Extension directories
- Installed extension IDs (32-char alphanumeric)

**Output includes:**
- manifest.json analysis
- Permission audit
- Script inventory
- Suspicious pattern detection

```bash
# Examples
~/.claude/skills/re.sh chrome ~/Downloads/ublock.crx
~/.claude/skills/re.sh chrome abcdefghijklmnopqrstuvwxyzabcdef
~/.claude/skills/re.sh chrome ~/path/to/extracted/extension
```

### Electron App (`/re electron <app>`)

Extracts source code from Electron apps (Discord, Slack, VS Code, etc.):
- Automatically locates and extracts `app.asar`
- Parses `package.json` for app structure
- Identifies IPC patterns and preload scripts

**Requires:** `@electron/asar` npm package (auto-uses npx if not installed)

```bash
# Examples
~/.claude/skills/re.sh electron /Applications/Discord.app
~/.claude/skills/re.sh electron /Applications/Slack.app
~/.claude/skills/re.sh electron "/Applications/Visual Studio Code.app"
```

### JavaScript Deobfuscation (`/re deobfuscate <file>`)

Beautifies and analyzes minified/obfuscated JavaScript:
- Formats code for readability
- Extracts URLs and API endpoints
- Identifies dangerous patterns (eval, Function constructor)
- Reports expansion ratio

```bash
# Examples
~/.claude/skills/re.sh deobfuscate ./bundle.min.js
~/.claude/skills/re.sh deobfuscate ./obfuscated-code.js
```

### macOS App (`/re macos <app>`)

Explores macOS application bundles:
- Parses Info.plist (bundle ID, version, executable)
- Lists frameworks and resources
- Detects if app is Electron-based
- Shows binary architecture (arm64/x86_64)
- Extracts URL schemes

```bash
# Examples
~/.claude/skills/re.sh macos /Applications/Safari.app
~/.claude/skills/re.sh macos /Applications/Xcode.app
```

### API Research (`/re api <url>`)

Initializes API reverse engineering project:
- Creates research template
- Sets up config for mitmproxy
- Provides next-step instructions

```bash
# Examples
~/.claude/skills/re.sh api https://api.example.com/v1
~/.claude/skills/re.sh api https://app.service.com/graphql
```

### Auto-Analyze (`/re analyze <path>`)

Auto-detects target type and runs appropriate analysis:
- `.crx` -> Chrome extension
- `.app` -> macOS/Electron app
- `.js` -> Deobfuscation
- `.asar` -> Electron extraction
- Directory -> Check for manifest.json or package.json

```bash
# Examples
~/.claude/skills/re.sh analyze ~/Downloads/unknown.crx
~/.claude/skills/re.sh analyze /Applications/SomeApp.app
```

---

## Output Location

All output goes to: `~/Desktop/re-output/`

```
~/Desktop/re-output/
├── chrome-extensions/
│   └── extension-name/
│       ├── manifest.json
│       ├── *.js, *.html, *.css
│       └── _RE_ANALYSIS.json
├── electron-apps/
│   └── app-name/
│       ├── package.json
│       ├── main.js, ...
│       └── _RE_ANALYSIS.json
├── deobfuscated/
│   └── filename.beautified.js
│   └── filename.analysis.json
├── macos-apps/
│   └── app-name/
│       ├── Info.plist
│       ├── STRUCTURE.txt
│       └── _RE_ANALYSIS.json
└── api-research/
    └── domain/
        ├── research.md
        └── config.json
```

---

## Integration with Coordinator

The RE skill is automatically invoked by the coordinator when RE patterns are detected:

```bash
# Check if task is RE-related
~/.claude/hooks/re-automation.sh is-re "extract chrome extension"
# Returns: true

# Execute RE task automatically
~/.claude/hooks/re-automation.sh execute "reverse engineer /Applications/Slack.app"
# Returns: JSON with extraction results
```

---

## Advanced: Direct Skill Invocation

For scripting or automation, invoke the skill directly:

```bash
# Full help
~/.claude/skills/re.sh help

# Chrome extension with custom output name
~/.claude/skills/re.sh chrome extension.crx my-extension

# All commands
~/.claude/skills/re.sh chrome <source>
~/.claude/skills/re.sh electron <app.app>
~/.claude/skills/re.sh deobfuscate <file.js>
~/.claude/skills/re.sh macos <app.app>
~/.claude/skills/re.sh api <url>
~/.claude/skills/re.sh analyze <path>
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RE_OUTPUT_DIR` | `~/Desktop/re-output` | Where to save extracted files |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| CRX won't extract | Try different CRX format handlers (auto-attempted) |
| ASAR extraction fails | Install: `npm install -g @electron/asar` |
| js-beautify not found | Install: `npm install -g js-beautify` |
| Extension ID not found | Check: `~/Library/Application Support/Google/Chrome/Default/Extensions/` |

---

## See Also

- **Detailed prompts:** `~/.claude/docs/re-prompts.md`
- **Full toolkit (50+ tools):** `~/.claude/docs/reverse-engineering-toolkit.md`
- **API research skill:** `/research-api`
