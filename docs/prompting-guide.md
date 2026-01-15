# Prompting Guide

> Source: Ken Kai's Exclusive - Adapted for Claude Code automation

## Core Principles

1. **Short > Long** - Laser-focused prompts beat essays. Your agent is smart.
2. **Don't Dump** - Never paste huge docs/specs. Summarize or reference.
3. **Manage Context** - Clear context when switching topics or at 40%.
4. **Focused Sets** - Work on related tasks together, not scattered.
5. **Describe What You See** - "The button that says Submit" not "line 47".
6. **Direction, Not Detail** - Say what, let agent figure out how.

## Communication Types

### Design Speak (Styling)
Use these terms to describe visuals:
- **Layout**: container, flexbox, grid, centered, full-width
- **Spacing**: padding, margin, gap, tight, spacious
- **Colors**: primary, accent, muted, contrast, dark mode
- **Typography**: heading, body text, monospace, bold, light
- **Responsive**: mobile-first, breakpoint, stack on mobile

### Code Speak (Logic)
Use these terms to describe functionality:
- **Data**: variable, array, object, state, props
- **Actions**: function, callback, handler, async, await
- **Flow**: conditional, loop, return early, guard clause
- **Structure**: component, module, service, utility
- **Errors**: try/catch, validate, fallback, throw

## Effective Prompts

**Good:**
```
Add a dark mode toggle to the settings page.
Store preference in localStorage.
```

**Bad:**
```
I want you to implement a comprehensive theming system with support
for light and dark modes. Please create a context provider that wraps
the application and provides theme state. The toggle should be
accessible and follow WCAG guidelines. Store the preference...
[300 more words]
```

## Feedback Patterns

When something's wrong:
```
The submit button isn't working - clicking it does nothing.
Expected: form submits and shows success message.
```

Not:
```
I tried clicking the button but it seems like maybe there's an issue
with the event handler or possibly the form validation isn't passing...
```

## Context Management

- **Start fresh**: Clear context for new features
- **Reference existing**: "Building on the auth from earlier..."
- **Checkpoint at 40%**: Save state, compact, continue
- **One focus per session**: Don't mix auth + payments + UI overhaul
