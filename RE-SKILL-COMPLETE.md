# RE Skill System - Implementation Complete

## Summary

Created a fully automated Reverse Engineering (RE) skill system that executes actual RE operations, not just loads documentation.

## Files Created/Modified

### New Files

1. **`~/.claude/skills/re.sh`** - Main executable RE skill
   - Chrome extension extraction (CRX files, directories, extension IDs)
   - Electron app source extraction (ASAR archives)
   - JavaScript deobfuscation/beautification
   - macOS app bundle exploration
   - API research initialization
   - Auto-detect and analyze unknown targets

2. **`~/.claude/hooks/re-automation.sh`** - Coordinator integration hook
   - Pattern matching for RE tasks
   - Automatic skill invocation
   - Task detection (`is-re`, `recommend`, `execute`)
   - State tracking for executions

3. **`~/.claude/tests/test-re-skill.sh`** - Verification test suite
   - 27 comprehensive tests
   - Tests all target types
   - Validates hook integration
   - 100% pass rate

### Modified Files

1. **`~/.claude/commands/re.md`** - Updated to call executable skill
   - Now invokes `~/.claude/skills/re.sh` directly
   - Clear documentation of all commands
   - Examples and troubleshooting

2. **`~/.claude/hooks/coordinator.sh`** - Added RE automation integration
   - Added `RE_AUTOMATION` and `RE_SKILL` paths
   - Enhanced RE detection logic
   - Auto-executes RE skill when target exists
   - Falls back to RE tool detector for specific tools

## Capabilities

### 1. Chrome Extension Extraction (`/re chrome <path>`)

```bash
~/.claude/skills/re.sh chrome ~/Downloads/extension.crx
~/.claude/skills/re.sh chrome abcdefghijklmnopqrstuvwxyzabcdef
```

**Features:**
- Handles CRX2 and CRX3 formats automatically
- Extracts from installed extensions by ID
- Parses manifest.json (MV2 and MV3)
- Detects suspicious patterns (eval, Function constructor)
- Lists permissions and content scripts

### 2. Electron App Extraction (`/re electron <app>`)

```bash
~/.claude/skills/re.sh electron /Applications/Discord.app
~/.claude/skills/re.sh electron /Applications/Notion.app
```

**Features:**
- Locates and extracts app.asar automatically
- Works with unpacked apps too
- Parses package.json for dependencies
- Detects IPC usage and preload scripts
- Reports Electron version

### 3. JavaScript Deobfuscation (`/re deobfuscate <file>`)

```bash
~/.claude/skills/re.sh deobfuscate ./bundle.min.js
```

**Features:**
- Beautifies minified code
- Extracts URLs and API endpoints
- Detects dangerous patterns
- Reports expansion ratio

### 4. macOS App Exploration (`/re macos <app>`)

```bash
~/.claude/skills/re.sh macos /Applications/Safari.app
```

**Features:**
- Parses Info.plist
- Lists frameworks and resources
- Detects Electron apps (suggests extraction)
- Shows binary architecture (arm64/x86_64)
- Extracts URL schemes

### 5. API Research (`/re api <url>`)

```bash
~/.claude/skills/re.sh api https://api.example.com/v1
```

**Features:**
- Creates research project structure
- Generates research template (research.md)
- Sets up config.json for tools
- Provides next-step instructions

### 6. Auto-Analyze (`/re analyze <path>`)

```bash
~/.claude/skills/re.sh analyze ./unknown-target
```

**Features:**
- Detects target type by extension/structure
- Routes to appropriate extraction method
- Works with CRX, JS, APP, ASAR, directories

## Output Structure

All output goes to `~/Desktop/re-output/`:

```
~/Desktop/re-output/
├── chrome-extensions/
│   └── <name>/
│       ├── manifest.json
│       ├── *.js, *.html, *.css
│       └── _RE_ANALYSIS.json
├── electron-apps/
│   └── <name>/
│       ├── package.json
│       ├── source files...
│       └── _RE_ANALYSIS.json
├── deobfuscated/
│   ├── <name>.beautified.js
│   └── <name>.analysis.json
├── macos-apps/
│   └── <name>/
│       ├── Info.plist
│       ├── STRUCTURE.txt
│       └── _RE_ANALYSIS.json
└── api-research/
    └── <domain>/
        ├── research.md
        └── config.json
```

## Coordinator Integration

The coordinator automatically:

1. Detects RE tasks using `re-automation.sh is-re`
2. Gets recommendations using `re-automation.sh recommend`
3. Auto-executes skill if target path exists
4. Logs to audit trail and memory manager
5. Falls back to `re-tool-detector.sh` for specific tools (mitmproxy, Frida, etc.)

### Pattern Detection

The automation hook recognizes patterns like:
- "extract chrome extension"
- "reverse engineer Slack"
- "deobfuscate bundle.js"
- "explore macOS app"
- "analyze electron source"

## Test Results

```
=== Test Results ===
Passed:  27
Failed:  0
Skipped: 0
Success Rate: 100%
```

All tests passing:
- CRX extraction (4 tests)
- JS deobfuscation (4 tests)
- macOS app exploration (4 tests)
- RE automation hook (6 tests)
- API research (4 tests)
- Auto-analyze (1 test)
- Skill interface (4 tests)

## Usage Examples

### From `/re` command:
```
/re chrome ~/Downloads/extension.crx
/re electron /Applications/Discord.app
/re deobfuscate ./bundle.min.js
/re macos /Applications/Xcode.app
/re api https://api.service.com
/re analyze ./unknown-file.crx
```

### Direct skill invocation:
```bash
~/.claude/skills/re.sh chrome <source>
~/.claude/skills/re.sh electron <app.app>
~/.claude/skills/re.sh deobfuscate <file.js>
~/.claude/skills/re.sh macos <app.app>
~/.claude/skills/re.sh api <url>
~/.claude/skills/re.sh analyze <path>
~/.claude/skills/re.sh help
```

### Automation hook:
```bash
~/.claude/hooks/re-automation.sh is-re "extract extension"      # Returns: true
~/.claude/hooks/re-automation.sh recommend "deobfuscate app.js" # Returns: JSON
~/.claude/hooks/re-automation.sh execute "analyze /path/to/app" # Executes skill
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RE_OUTPUT_DIR` | `~/Desktop/re-output` | Output directory for all extractions |

## Dependencies

- `jq` - JSON processing (required)
- `unzip` - CRX extraction (standard on macOS)
- `@electron/asar` - ASAR extraction (auto-uses npx if not installed)
- `js-beautify` - JS beautification (falls back to basic formatting)
- `plutil`, `PlistBuddy` - plist parsing (standard on macOS)

## Next Steps

1. Use `/re` command for any RE task
2. Check `~/Desktop/re-output/` for extracted files
3. Read `_RE_ANALYSIS.json` for structured results
4. Coordinator auto-invokes RE skill in autonomous mode

---

*Implementation completed: 2026-01-12*
*Tests: 27/27 passed (100%)*
