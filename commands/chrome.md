---
description: Launch Chrome browser automation session
allowed-tools: ["mcp__claude-in-chrome__tabs_context_mcp", "mcp__claude-in-chrome__tabs_create_mcp", "mcp__claude-in-chrome__computer", "mcp__claude-in-chrome__navigate", "mcp__claude-in-chrome__read_page", "mcp__claude-in-chrome__find", "mcp__claude-in-chrome__form_input"]
---

# Chrome Browser Automation

Start a browser automation session using the Claude Chrome extension.

## Instructions

Execute these steps in order:

### 1. Connect to Chrome

Call `mcp__claude-in-chrome__tabs_context_mcp` with `createIfEmpty: true` to get current tabs or create a new browser window.

### 2. Create a Fresh Tab

Call `mcp__claude-in-chrome__tabs_create_mcp` to create a new empty tab for this session.

### 3. Take Initial Screenshot

Call `mcp__claude-in-chrome__computer` with:
- `action: "screenshot"`
- `tabId: [the new tab ID]`

This confirms the connection is working.

### 4. Report Ready Status

Tell the user:
- Browser connected successfully
- Tab ID for this session
- What they can do next (navigate, interact, screenshot, etc.)

## Available Actions

After setup, the user can request:

- **Navigate**: Go to any URL
- **Screenshot**: Capture current page
- **Read**: Get page content/accessibility tree
- **Find**: Locate elements by description
- **Click**: Click on coordinates or elements
- **Type**: Enter text
- **Fill Forms**: Set input values
- **Run JavaScript**: Execute code in page
- **Record GIF**: Capture action sequence

## Error Handling

If tabs_context_mcp fails:
- Tell user to ensure Claude Chrome extension is installed and active
- Check that Chrome browser is running
- Extension icon should be visible in Chrome toolbar

If screenshot fails:
- The tab may still be loading - wait 2 seconds and retry
- Check tabId is valid
