---
description: Perform deep root cause analysis for a specific bug
argument-hint: "<error description>"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Task", "WebSearch"]
---

# /rootcause Command

When the user types `/rootcause` followed by a description of an error/bug/troubleshooting issue, you must act like a senior/staff engineer performing **structured root cause analysis** on that specific problem.

Example invocation (user message):
`/rootcause The /invoices endpoint is returning 500s in staging when called from the web app but not from Postman…`

Your job: take that description and run a disciplined, step-by-step root cause analysis (RCA), not random guessing.

## Instructions

1. Treat everything after `/rootcause` as the **bug report + context**:
   - Natural language description
   - Error messages / stack traces
   - Logs, diffs, or code snippets (if present)

2. Run a **systematic debugging process**:
   - Turn the vague problem into a precise **bug statement**
   - Derive or propose **reproduction steps**
   - Extract and interpret **signals** (logs, stack traces, metrics, recent changes)
   - Use **divide & conquer** reasoning to narrow down where the problem lives
   - Generate explicit **hypotheses** and describe concrete **experiments** to test them
   - Identify the **true root cause** if possible (or the most likely causes, clearly labeled)
   - Propose a **fix plan** and **regression tests** so it doesn't happen again
   - Capture **follow-ups** to harden the system

3. Be explicit about:
   - What you **know** (facts from the bug description/code)
   - What you are **inferring**
   - What you **still need** to be 100% sure (if anything)

4. If some info is missing:
   - Do **not** stall.
   - Make reasonable assumptions and clearly label them: "Assumption: …"
   - Propose what additional data/logs/tests the engineer should collect.

---

## What to Extract from the /rootcause Message

Read the user's `/rootcause ...` text and extract:

1. **Bug Statement**
   - What is broken (symptom)?
   - Expected vs actual behavior.
   - Where the bug manifests (endpoint, component, function, service).
   - When it happens (always / intermittent, envs, specific inputs).

2. **Context / Environment**
   - Environment(s) mentioned: local, dev, staging, prod, CI.
   - Branch/commit/version if given.
   - Config/feature flags mentioned.
   - Any related services or modules named.

3. **Reproduction Info**
   - Steps the user gave (URLs, actions, payloads).
   - Inputs: request body, user state, DB state (if described).
   - Whether repro is:
     - Always / intermittent / unclear.

4. **Signals**
   - Error messages / stack traces.
   - Logs or log snippets.
   - Observed metrics (timeouts, high CPU, memory, DB errors).
   - "We changed X recently…" or "It started happening after Y…"

5. **Suspected Areas**
   - Functions, classes, files, modules, or services explicitly mentioned.
   - Any implied boundaries (frontend vs backend, API vs DB, etc.).

---

## Output Format

Output a **single root cause analysis summary** in this exact structure, wrapped in a code block for easy copying:

```markdown
## Root Cause Analysis

**Bug Summary**:
- [1–3 sentence summary of what is broken, where, and when]
- Expected: [expected behavior]
- Actual: [actual behavior]

**Environment / Context**:
- Environment(s): [local/dev/staging/prod as applicable]
- Branch/Commit: [if given, or "not specified"]
- Relevant Config / Flags: [feature flags, env vars, special config]
- Affected Area(s): [component/service/module/function names]

**Reproduction Steps (Inferred or Given)**:
1. [step 1 with concrete URL/action/input]
2. [step 2]
3. [etc.]
- Reproducibility: [always / intermittent / unclear]
- Minimal Repro Case: [your best attempt at a minimal repro, or "not enough data"]

**Observations & Signals**:
- Logs / Errors:
  - [key error messages / stack trace lines]
- Metrics / Behavior:
  - [any performance/latency/failure rate clues]
- Recent Changes:
  - [any mentioned changes that correlate with the bug]
- Working vs Failing:
  - [differences in inputs/env/paths between working and broken cases]

**Narrowed Scope**:
- Confirmed Correct:
  - [layers/modules/functions that appear to behave as expected]
- Suspected Area:
  - [specific modules/functions/queries/configs most likely involved]
- Boundary of Failure:
  - [where behavior switches from correct to incorrect]

**Hypotheses**:
- H1: [hypothesis 1]
  - Rationale: [why this might be the cause, referencing signals]
- H2: [hypothesis 2]
  - Rationale: [...]
- H3: [optional further hypotheses]

**Experiments / Checks to Run**:
- For H1:
  - [Experiment 1]: [what to do, what you expect to see, and how it confirms/refutes H1]
  - [Experiment 2]: [...]
- For H2:
  - [Experiment 1]: [...]
- Additional Checks:
  - [e.g. add a log at X, check DB row Y, hit endpoint with payload Z]

**Most Likely Root Cause**:
- [single clear statement; if not 100% certain, mark as "most likely"]
- Explanation:
  - [step-by-step chain from input → code path → faulty logic/config → observable bug]
- Contributing Factors (if any):
  - [secondary causes, e.g. missing validation, ambiguous API, weak typing]

**Fix Plan**:
- Code Changes:
  - [where to edit (files/functions) and what to change conceptually]
- Data / Migration:
  - [any data fix/backfill/migration needed]
- Rollout Strategy:
  - [feature flag / canary / staged rollout if relevant]
- Risks / Things to Watch:
  - [possible side effects and how to mitigate them]

**Regression Tests & Guardrails**:
- Tests to Add/Update:
  - [test 1: area + what scenario it covers]
  - [test 2]
- Observability:
  - [logs/metrics/traces to add or refine for earlier detection next time]
- Additional Guards:
  - [input validation, stronger types, invariants, assertions]

**Follow-ups / Improvements**:
- [small refactors to make this area safer/clearer]
- [documentation/runbook updates]
- [any process or checklist updates (e.g. "always test scenario X before release")]
```
