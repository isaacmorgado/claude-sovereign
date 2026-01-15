---
description: Pre-production security audit - finds vulnerabilities before deploy
allowed-tools: ["Bash", "Read", "Grep", "Glob", "Task"]
---

# Security Pre-Production Check

> Source: Adapted from Ken Kai's Security Checklist

Automated security audit before deployment. Finds common vulnerabilities.

## Run Audit

### 1. Secrets Exposure Check

```bash
# Check for exposed secrets in code
echo "=== Checking for exposed secrets ==="

# API keys, tokens, passwords in code
grep -rn --include="*.{js,ts,tsx,jsx,py,go,rs}" \
  -E "(api_key|apikey|secret|password|token|auth).*['\"][a-zA-Z0-9]{16,}" . 2>/dev/null || true

# .env files that shouldn't be committed
find . -name ".env*" -not -name ".env.example" -not -name ".env.local.example" 2>/dev/null

# Check if .env is in .gitignore
if ! grep -q "^\.env" .gitignore 2>/dev/null; then
  echo "WARNING: .env not in .gitignore!"
fi
```

### 2. Hardcoded Credentials

Search for hardcoded values:
```
Use Grep with pattern: (password|secret|key)\s*[:=]\s*['"][^'"]+['"]
Report all matches for manual review
```

### 3. SQL Injection Vectors

```
Search for string concatenation in queries:
- Pattern: "SELECT.*\+.*" or f"SELECT.*{"
- Pattern: "query(" without parameterized values
Flag all direct string interpolation in SQL
```

### 4. XSS Vulnerabilities

```
React/JSX: Search for dangerouslySetInnerHTML
Vue: Search for v-html
General: Search for innerHTML assignment
Flag unsanitized user input rendering
```

### 5. Auth Checks

```
Check protected routes have auth middleware:
- API routes should check session/token
- Admin routes should verify role
- File uploads should validate user
```

### 6. Input Validation

```
Search for:
- req.body used without validation
- request.json() without schema
- User input passed directly to shell commands
- eval() or exec() with user input
```

### 7. Environment Variables

```bash
# Verify required env vars are documented
echo "=== Environment Variables Check ==="

# Check for .env.example
if [[ ! -f .env.example ]]; then
  echo "WARNING: No .env.example file"
fi

# Compare .env to .env.example
if [[ -f .env ]] && [[ -f .env.example ]]; then
  echo "Undocumented vars in .env:"
  comm -23 <(grep -E "^[A-Z]" .env | cut -d= -f1 | sort) \
           <(grep -E "^[A-Z]" .env.example | cut -d= -f1 | sort) 2>/dev/null || true
fi
```

### 8. Dependency Vulnerabilities

```bash
# Check for known vulnerabilities
echo "=== Dependency Security Check ==="

if [[ -f package.json ]]; then
  npm audit --audit-level=high 2>/dev/null || echo "Run: npm audit"
fi

if [[ -f requirements.txt ]] || [[ -f pyproject.toml ]]; then
  pip-audit 2>/dev/null || echo "Install: pip install pip-audit"
fi
```

## Output Format

```markdown
# Security Audit Report

## Critical (Fix Before Deploy)
- [ ] Issue 1: [description] - [file:line]
- [ ] Issue 2: [description] - [file:line]

## High Priority
- [ ] Issue 3: [description]

## Recommendations
- [ ] Consider: [suggestion]

## Passed Checks
- [x] No hardcoded secrets found
- [x] .env properly gitignored
- [x] Dependencies up to date
```

## Auto-Fix Common Issues

If issues found, offer to fix:
1. Move hardcoded secrets to .env
2. Add .env to .gitignore
3. Wrap dangerous HTML in sanitizer
4. Add input validation schemas
5. Update vulnerable dependencies
