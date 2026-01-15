---
description: VisionPilot - Autonomous computer control with vision-guided automation
allowed-tools: ["Bash", "Read", "Write", "Glob"]
---

# VisionPilot - Vision-Guided Computer Control

VisionPilot is an autonomous computer control system that uses LLM vision models to see, analyze, and interact with your macOS desktop. It can autonomously complete multi-step tasks by taking screenshots, making decisions, and executing actions.

## Key Capabilities

- **Autonomous Task Execution**: Give natural language goals, VisionPilot completes them
- **Screenshot-Driven Control**: Sees what's on screen and makes intelligent decisions
- **Multi-Provider Support**: Google Gemini (FREE), Claude, GPT-4o, Featherless
- **Adobe Premiere Pro Automation**: Specialized support for video editing workflows
- **Mouse & Keyboard Control**: Click, type, drag, keyboard shortcuts
- **Background Mode Ready**: (Architecture designed for background execution)

## Installation Location

VisionPilot is installed at: `~/.claude/tools/visionpilot/`

## Quick Start

### 1. Activate Virtual Environment

```bash
cd ~/.claude/tools/visionpilot
source venv/bin/activate
```

### 2. Basic Usage

**Run a simple task**:
```bash
python -m src.cli run "Your task description here"
```

**Example tasks**:
```bash
# Take screenshot and analyze
python -m src.cli run "Take a screenshot and tell me what applications are open"

# Adobe Premiere Pro automation
python -m src.cli premiere "Open the Extensions panel and locate SPLICE plugin"

# Launch application
python -m src.cli launch "Adobe Premiere Pro"

# Custom model selection
python -m src.cli run "Your task" --provider gemini --model gemini-2.0-flash-exp
```

### 3. Background Execution

For long-running tasks, use background mode:

```bash
# Start task in background (output to log file)
nohup python -m src.cli -v run "Complex multi-step task" --log-file visionpilot-$(date +%s).log > /tmp/visionpilot-bg.out 2>&1 &

# Save PID for later
echo $! > ~/.claude/tools/visionpilot/visionpilot.pid

# Check logs
tail -f visionpilot-*.log
```

## Available Commands

| Command | Description |
|---------|-------------|
| `run "task"` | Execute autonomous task |
| `premiere "task"` | Premiere Pro specific task |
| `launch "app"` | Launch macOS application |
| `screenshot` | Take single screenshot |
| `info` | Show system & config info |
| `test-permissions` | Check macOS accessibility permissions |

## Command Options

| Option | Description |
|--------|-------------|
| `-v, --verbose` | Enable debug logging |
| `--log-file FILE` | Write logs to file |
| `--provider NAME` | Select provider (gemini/anthropic/openai/featherless) |
| `--model NAME` | Specify model name |
| `--max-iterations N` | Max agent loop iterations (default: 50) |

## LLM Provider Setup

VisionPilot requires an API key for at least one provider. Configure in `~/.claude/tools/visionpilot/.env`:

### Google Gemini (FREE - Recommended)
```bash
GOOGLE_API_KEY=your_api_key_here
GEMINI_MODEL=gemini-2.0-flash-exp
LLM_PROVIDER=auto
```

### Anthropic Claude
```bash
ANTHROPIC_API_KEY=sk-ant-your_key_here
LLM_PROVIDER=anthropic
```

### OpenAI
```bash
OPENAI_API_KEY=sk-your_key_here
LLM_PROVIDER=openai
```

## macOS Permissions Required

VisionPilot needs these permissions (System Preferences > Security & Privacy):

1. **Accessibility**: Control computer via AppleScript
2. **Screen Recording**: Capture screenshots

Grant permissions when prompted on first run.

## How VisionPilot Works

1. **Captures screenshot** of current screen state
2. **Sends to LLM** with task description and available tools
3. **LLM analyzes** screen and decides next action
4. **Executes action** (mouse click, keyboard input, etc.)
5. **Captures result** screenshot
6. **Repeats** until task complete or max iterations reached

## Agent Loop Architecture

```
Screenshot → LLM Vision Analysis → Decision → Action Execution
     ↑                                              ↓
     └──────────────── Repeat Loop ────────────────┘
```

## Screenshot Storage

All screenshots saved to: `~/.claude/tools/visionpilot/screenshots/`

Format: `screenshot_YYYYMMDD_HHMMSS_ffffff.png`

## Examples

### Adobe Premiere Pro Testing

```bash
# Test plugin installation
python -m src.cli premiere "Check if SPLICE plugin is installed in Extensions panel"

# Automated workflow
python -m src.cli premiere "Create new sequence, import media, add SPLICE plugin to panel"
```

### General Desktop Automation

```bash
# File management
python -m src.cli run "Open Finder, navigate to Downloads, delete files older than 30 days"

# Application control
python -m src.cli run "Open Safari, navigate to splice.video, take screenshot"

# Multi-app workflow
python -m src.cli run "Open Terminal, run 'git status', screenshot the output"
```

### Background Automation (Template)

```bash
# Long-running task in background
cd ~/.claude/tools/visionpilot
source venv/bin/activate

# Start with logging
nohup python -m src.cli -v run "Your complex task here" \
  --log-file "task-$(date +%Y%m%d-%H%M%S).log" \
  --max-iterations 100 \
  > /tmp/visionpilot-output.txt 2>&1 &

# Save PID
echo $! > visionpilot.pid

# Monitor progress
tail -f task-*.log

# Kill if needed
kill $(cat visionpilot.pid)
```

## Troubleshooting

### Permission Denied Errors

Grant Accessibility and Screen Recording permissions:
1. System Preferences > Security & Privacy > Privacy
2. Add Terminal/iTerm to Accessibility
3. Add Terminal/iTerm to Screen Recording
4. Restart Terminal

### API Rate Limits

If using free tier (Gemini), reduce iteration speed:
- Use `--max-iterations` to limit
- Add delays between actions in task prompt
- Consider upgrading to paid tier

### Cannot Control Background Apps

Current limitation: PyAutoGUI requires active window focus. Background mode architecture is designed but not yet implemented (see `VISIONPILOT_BACKGROUND_MODE_ANALYSIS.md` in SPLICE project).

### Screenshots Not Saving

Check directory permissions:
```bash
chmod 755 ~/.claude/tools/visionpilot/screenshots/
```

## Advanced Configuration

Edit `~/.claude/tools/visionpilot/.env` for:

- Default provider selection
- Model preferences
- Screenshot quality settings
- Action timing delays
- Debug verbosity levels

See `.env.example` for all available options.

## Integration with Claude Code

When called from `/visionpilot` skill:

1. Automatically activates virtual environment
2. Parses user task description
3. Selects appropriate provider/model
4. Executes in background if task seems long-running
5. Monitors logs and reports progress
6. Returns screenshots and results to user

## Documentation

Full documentation available at:
- Architecture: `~/SPLICE/VISIONPILOT_BACKGROUND_MODE_ANALYSIS.md`
- Quick Reference: `~/SPLICE/VISIONPILOT_BACKGROUND_MODE_QUICK_REFERENCE.md`
- Source code: `~/.claude/tools/visionpilot/src/`

## Notes

- VisionPilot is designed for macOS only
- Requires Python 3.10+
- Best with Google Gemini (free tier available)
- Screenshots persist - clean up periodically
- Background mode architecture ready, implementation pending
