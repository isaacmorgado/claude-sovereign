---
description: Perform a holistic root cause and health analysis across the entire application
argument-hint: "[focus-area]"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Task", "WebSearch"]
---

# System-wide Root Cause Analysis Command

Analyze the entire application (codebase, architecture, configs, tests, logs, and metrics) and perform a **holistic root cause and health analysis** as a senior/staff engineer.

This is not just about one bug. Your job is to:
- Identify clusters of issues, systemic patterns, and risk hotspots.
- Infer **underlying root causes at the system level** (design, process, testing, observability, etc.).
- Produce a prioritized, actionable improvement plan.

## Instructions

Given the current repository, architecture description, and any available operational signals (logs/metrics/incidents):

1. Build a mental model of the **overall system** (modules, services, key flows).
2. Identify **visible symptoms** across the app: bugs, performance issues, security smells, test gaps, DX problems.
3. Group these symptoms into **patterns** and infer deeper **systemic root causes** (e.g. missing boundaries, poor ownership, lack of tests, bad abstractions).
4. Assess **risk and impact** for each area.
5. Propose a **prioritized remediation roadmap** (phases, milestones, refactors, tests, observability work).
6. Call out **quick wins vs. deep work**.
7. Capture **principles and guardrails** so the system stays healthy going forward.

You are performing a "technical health + root cause" audit for the entire app, not a single incident.

### What to Analyze

1. **Architecture & Boundaries**
   - Main components/services and how they communicate.
   - Coupling vs cohesion (modules tangled? clear boundaries?).
   - Data flow: where data originates, how it moves, where it's persisted.
   - Cross-cutting concerns (auth, logging, error handling, caching).

2. **Code Quality & Structure**
   - Overly large "god" modules/classes.
   - Duplicated patterns / copy-paste logic.
   - Mixed concerns (business logic in controllers, SQL in views, etc.).
   - Use of types/contracts, validation, and clear interfaces.

3. **Defects & Reliability**
   - Known bugs / TODOs / FIXME comments.
   - Areas with frequent changes or regressions.
   - Exception hotspots in logs or crash reports.
   - Flaky behavior (intermittent failures, race conditions, timeouts).

4. **Performance**
   - Slow endpoints or UI interactions.
   - Expensive DB queries or N+1 patterns.
   - Inefficient loops, synchronous I/O in hot paths.
   - Caching strategy and its weaknesses (or absence).

5. **Security & Compliance (high-level)**
   - Obvious security smells (hard-coded secrets, lack of validation).
   - Missing auth checks, overly broad permissions, direct object references.
   - Use of outdated or vulnerable dependencies (if visible).

6. **Testing & Observability**
   - Test coverage patterns (critical areas untested?).
   - Quality of tests (happy-path only vs edge cases).
   - Logging quality (too little, too noisy, missing context).
   - Metrics/tracing: can we trace a request end-to-end? Are there SLOs?

7. **Process & Ownership Signals**
   - Files with many authors vs no clear owner.
   - Modules that change constantly vs stable ones.
   - Signs of rushed work: "temporary hack", "quick fix", "TODO: refactor".

### Output Format

Output a single, well-structured **system-wide analysis report** wrapped in a code block for easy copying:

```markdown
## System-wide Root Cause & Health Analysis

**Application Overview**:
- Domain / Purpose: [what this app does]
- Major Components/Services: [high-level list]
- Tech Stack: [frameworks, languages, DBs, infra]

---

### 1. Visible Symptoms & Hotspots

**Functional / Reliability Issues**:
- [symptom 1: location, brief description]
- [symptom 2]
- [...]

**Performance Symptoms**:
- [slow endpoint/flow + context]
- [...]

**Security/Integrity Concerns**:
- [potential vulnerability / smell]
- [...]

**DX / Maintainability Issues**:
- [pain points for developers: confusing modules, brittle code, etc.]

---

### 2. Structural Findings (By Area)

**Area A: [module/service/path]**
- Role: [short description]
- Issues:
  - [issue 1]
  - [issue 2]
- Impact:
  - [how it affects users/teams]
- Local Root Causes:
  - [suspected underlying causes in this area]

**Area B: [module/service/path]**
- Role: [...]
- Issues:
  - [...]
- Impact:
  - [...]
- Local Root Causes:
  - [...]

[Repeat for other key areas, focusing on the most critical 3–7]

---

### 3. Systemic Root Causes

These are the **deeper, cross-cutting causes** that explain multiple symptoms:

- **Root Cause 1**: [e.g. "Lack of clear module boundaries"]
  - Evidence:
    - [symptom/area 1 it explains]
    - [symptom/area 2 it explains]
  - Effect:
    - [how it slows development / causes bugs / increases risk]

- **Root Cause 2**: [e.g. "Insufficient tests around critical flows"]
  - Evidence:
    - [...]
  - Effect:
    - [...]

- **Root Cause 3**: [e.g. "Weak observability and logging"]
  - Evidence:
    - [...]
  - Effect:
    - [...]

[Add more if needed, but keep them high-signal and non-overlapping]

---

### 4. Risk Assessment

**Highest-Risk Areas (Top 3–5)**:
1. [area + why it's risky (user impact, outage risk, data loss, etc.)]
2. [area + risk]
3. [area + risk]

**Short-term vs Long-term Risk**:
- Short-term:
  - [what could break "soon" if left as-is]
- Long-term:
  - [how debt and structure will slow future development or scaling]

---

### 5. Prioritized Remediation Roadmap

**Phase 0 – Immediate Safeguards (Now–1 week)**:
- [ ] [quick win fix or guardrail 1 – e.g. add logging, feature flag, simple validation]
- [ ] [quick win fix 2]
- Goal: [stabilize X / reduce risk of Y]

**Phase 1 – High-impact Fixes (1–4 weeks)**:
- [ ] [refactor or redesign 1 – area + brief description]
- [ ] [hardening tests around critical path X]
- [ ] [fix specific performance hotspot]
- Goal: [improve reliability / performance / clarity in core flows]

**Phase 2 – Structural Improvements (1–3 months)**:
- [ ] [larger refactor / boundary extraction]
- [ ] [introduce patterns (e.g. service layer, DTOs, stronger types)]
- [ ] [observability upgrade: tracing, better logs, dashboards]
- Goal: [reduce long-term tech debt and scale safely]

**Phase 3 – Ongoing Maintenance & Governance**:
- [ ] [define code ownership for critical modules]
- [ ] [regular "tech debt" or "fix-it" days]
- [ ] [review & enforce coding & testing standards]

---

### 6. Testing & Observability Gaps

**Critical Flows Lacking Tests**:
- [flow 1: what's missing, suggested tests]
- [flow 2]

**Testing Recommendations**:
- [unit/integration/e2e tests to add and where]
- [areas where mocks/stubs are hiding real issues]

**Observability Improvements**:
- Logging:
  - [what to log, where, and with what structure]
- Metrics:
  - [key counters/gauges/histograms]
- Tracing:
  - [which flows need spans, what to tag]

---

### 7. Security & Data Protection Notes (High-level)

- [notable security smells + suggested mitigations]
- [sensitive data flows that need extra care]
- [dependency or configuration risks]

---

### 8. Principles & Guardrails Going Forward

- [principle/guardrail 1 – e.g. "No business logic in controllers; use service layer"]
- [principle/guardrail 2 – e.g. "All new features must ship with at least X tests"]
- [principle/guardrail 3 – e.g. "All externally facing endpoints must validate input via …"]

These are the **rules of thumb** to prevent similar systemic issues in the future.
```
