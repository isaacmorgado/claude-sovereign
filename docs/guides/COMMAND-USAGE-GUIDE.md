# 📖 V2 Command Usage Guide

When and how to use each V2 command automatically in `/auto` mode.

---

## 🤖 Automatic Command Selection

Claude should detect these patterns and use appropriate commands **without asking**:

---

### `/swarm spawn N <task>`

**When to use automatically**:

✅ **Parallel Testing**
```
User: "Run comprehensive tests across all modules"
Claude: Detects "comprehensive" + "all modules" → /swarm spawn 5
```

✅ **Multiple Independent Features**
```
User: "Implement user auth, profile page, and settings"
Claude: Detects 3 independent features → /swarm spawn 3
```

✅ **Documentation Generation**
```
User: "Generate complete docs for the project"
Claude: Detects multiple doc types → /swarm spawn 4
```

**Detection Rules**:
```javascript
if (task.includes('comprehensive') ||
    task.includes('all ') ||
    task.match(/(\d+)\s+(features?|modules?|tests?)/)) {

    count = detectParallelizableCount(task)
    if (count >= 3) {
        execute: /swarm spawn ${count} "${task}"
    }
}
```

**Example Triggers**:
- "Run all tests"
- "Implement multiple features"
- "Generate docs for all modules"
- "Comprehensive security audit"
- "Test all endpoints"

**Don't Use When**:
- Sequential dependencies
- Single focused task
- Real-time collaboration needed

---

### `/multi-repo <command>`

**When to use automatically**:

✅ **Cross-Service Updates**
```
User: "Update authentication across all microservices"
Claude: Detects "across all" + multiple repos → /multi-repo sync
```

✅ **Synchronized Changes**
```
User: "Bump version to 2.0 in all repos"
Claude: Detects multiple repos + sync → /multi-repo exec "update version"
```

**Detection Rules**:
```javascript
if (task.includes('microservices') ||
    task.includes('all repos') ||
    task.includes('synchronized') ||
    task.includes('across services')) {

    if (multipleReposDetected()) {
        execute: /multi-repo sync
        // Make changes
        execute: /multi-repo checkpoint "message"
    }
}
```

**Example Triggers**:
- "Update across all services"
- "Sync configuration in microservices"
- "Deploy to all repositories"
- "Version bump across repos"

**Don't Use When**:
- Single repository
- Independent repo changes
- No coordination needed

---

### `/personality load <name>`

**When to use automatically**:

✅ **Security Tasks**
```
User: "Audit the codebase for vulnerabilities"
Claude: Detects "vulnerabilities" → /personality load security-expert
```

✅ **Performance Tasks**
```
User: "Optimize the application performance"
Claude: Detects "optimize" + "performance" → /personality load performance-optimizer
```

✅ **API Design**
```
User: "Design a REST API for user management"
Claude: Detects "API" + "design" → /personality load api-architect
```

**Detection Rules**:
```javascript
const personalityMap = {
    security: /security|vulnerabilit|exploit|xss|injection|audit/i,
    performance: /optimize|performance|slow|faster|cache|scale/i,
    api: /api.*design|rest|graphql|endpoint/i,
    frontend: /ui|ux|component|react|vue|angular/i,
    devops: /deploy|ci\/cd|docker|kubernetes|pipeline/i,
    data: /data.*analysis|machine learning|ml|statistics/i
}

for (let [personality, pattern] of Object.entries(personalityMap)) {
    if (pattern.test(task)) {
        execute: /personality load ${personality}-expert
        break
    }
}
```

**Available Personalities**:
1. `security-expert` - Security, vulnerabilities, secure coding
2. `performance-optimizer` - Performance, scalability, optimization
3. `api-architect` - API design, REST, GraphQL
4. `frontend-specialist` - UI/UX, React, component design
5. `devops-engineer` - CI/CD, deployment, infrastructure
6. `data-scientist` - Data analysis, ML, statistics

**Example Triggers**:

| Task Contains | Load Personality |
|---------------|------------------|
| "security audit" | security-expert |
| "optimize performance" | performance-optimizer |
| "design API" | api-architect |
| "build UI" | frontend-specialist |
| "deploy to production" | devops-engineer |
| "analyze data" | data-scientist |

**Don't Use When**:
- General development task
- Already loaded appropriate personality
- Task doesn't match any domain

---

### `/voice` (Manual Only)

**Never auto-activate**. User must explicitly request:
```
User: "/voice start" or "Enable voice control"
```

**Why**: Privacy, resource usage, user preference

---

### `/collab` (Manual Only)

**Never auto-activate**. User must explicitly request:
```
User: "/collab start session-name"
User: "/collab join session-id"
```

**Why**: Multi-user coordination, session management

---

## 🎯 Decision Tree for Autonomous Mode

```
User provides task
    ↓
┌─────────────────────────────────────┐
│ Can task be parallelized into 3+   │
│ independent parts?                  │
└──────────┬──────────────────────────┘
           ↓ YES
    /swarm spawn N
           ↓ NO
┌─────────────────────────────────────┐
│ Does task involve multiple repos?   │
└──────────┬──────────────────────────┘
           ↓ YES
    /multi-repo sync
           ↓ NO
┌─────────────────────────────────────┐
│ Does task match domain expertise?   │
└──────────┬──────────────────────────┘
           ↓ YES
    /personality load <domain>
           ↓ NO
    Proceed with default autonomous mode
```

---

## 💡 Example Scenarios

### Scenario 1: Comprehensive Testing

**User Input**:
```
"Run comprehensive tests across the entire application"
```

**Claude's Decision**:
1. Detects: "comprehensive" + "entire application"
2. Identifies parallelizable parts: unit, integration, e2e, performance, security tests
3. **Automatically executes**: `/swarm spawn 5 "Comprehensive testing"`
4. Spawns 5 agents for parallel test execution
5. Collects and aggregates results

**No user confirmation needed** - autonomous mode handles it.

---

### Scenario 2: Security Audit

**User Input**:
```
"Perform a security audit on the authentication system"
```

**Claude's Decision**:
1. Detects: "security audit"
2. **Automatically executes**: `/personality load security-expert`
3. Now focuses on:
   - SQL injection vulnerabilities
   - XSS protection
   - Authentication bypass attempts
   - Session management
   - Password policies
4. Provides security-focused analysis

**No user confirmation needed** - personality switched automatically.

---

### Scenario 3: Microservices Update

**User Input**:
```
"Update the logging configuration across all microservices"
```

**Claude's Decision**:
1. Detects: "across all microservices"
2. **Automatically executes**: `/multi-repo sync`
3. Identifies all related repositories
4. Makes synchronized changes
5. **Automatically executes**: `/multi-repo checkpoint "Updated logging config"`
6. Pushes changes to all repos

**No user confirmation needed** - multi-repo coordination automatic.

---

### Scenario 4: API Performance

**User Input**:
```
"Design a high-performance REST API for the user service"
```

**Claude's Decision**:
1. Detects: "REST API" + "high-performance"
2. **First**: `/personality load api-architect` (for API design)
3. Designs API structure
4. **Then**: `/personality load performance-optimizer` (for optimization)
5. Optimizes for performance
6. Delivers highly-performant API design

**No user confirmation needed** - personality switching automatic.

---

## 🚫 When NOT to Use Commands

### Don't Use `/swarm` When:
- Task has sequential dependencies
- Only 1-2 independent parts
- Real-time collaboration needed
- Task requires single context

**Example**:
```
❌ "Implement login flow" - Sequential steps, single context
✅ "Run all test suites" - Independent parallel tests
```

### Don't Use `/multi-repo` When:
- Single repository involved
- Independent changes per repo
- No coordination needed

**Example**:
```
❌ "Update README in this repo" - Single repo
✅ "Sync configs across microservices" - Multiple repos
```

### Don't Use `/personality` When:
- General development task
- No specific domain expertise needed
- Already loaded appropriate personality

**Example**:
```
❌ "Write a function to sort array" - General task
✅ "Audit for SQL injection" - Needs security-expert
```

---

## 📋 Integration Checklist for /auto

Update `/auto` command to include:

- [x] Detection rules for `/swarm`
- [x] Detection rules for `/multi-repo`
- [x] Detection rules for `/personality`
- [x] Decision tree documented
- [x] Example scenarios provided
- [x] Integration in auto.md

---

## 🎓 Training Examples for Claude

Add to autonomous mode training:

```markdown
**Example 1: Automatic Swarm**
User: "Generate complete documentation"
You: [Detect parallelizable] → /swarm spawn 4 "Documentation generation"

**Example 2: Automatic Personality**
User: "Find security vulnerabilities"
You: [Detect security domain] → /personality load security-expert → [Audit]

**Example 3: Automatic Multi-Repo**
User: "Update dependencies in all services"
You: [Detect multi-repo] → /multi-repo sync → [Update] → /multi-repo checkpoint

**Example 4: Combined**
User: "Security audit across all microservices"
You: [Detect both] → /personality load security-expert → /multi-repo sync → [Audit]
```

---

## ✅ Summary

**Automatic Commands** (No confirmation needed):
- `/swarm spawn N` - When 3+ parallel parts detected
- `/multi-repo` - When multiple repos involved
- `/personality load` - When domain expertise needed

**Manual Commands** (User must request):
- `/voice` - Voice control
- `/collab` - Collaboration sessions

**Detection**: Pattern matching on user input
**Execution**: Automatic in `/auto` mode
**Fallback**: Default autonomous behavior if no patterns match
