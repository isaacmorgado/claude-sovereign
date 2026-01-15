---
description: Automated deployment - runs checks, deploys, verifies
argument-hint: "[vercel|railway|preview] [--prod]"
allowed-tools: ["Bash", "Read", "Write", "Grep", "Task"]
---

# Automated Deploy Command

> Runs security check, quality gates, then deploys

## Usage
```
/deploy              # Preview deploy to Vercel
/deploy --prod       # Production deploy
/deploy railway      # Deploy backend to Railway
/deploy preview      # Preview deploy only
```

## Pre-Deploy Checklist

### 1. Run Security Check
```
Execute /security-check
If critical issues found: STOP and report
If high priority issues: Warn but continue
```

### 2. Run Quality Gates
```bash
# Full quality validation
if [[ -f package.json ]]; then
  npm run lint && npm run typecheck && npm test
elif [[ -f pyproject.toml ]]; then
  ruff check . && mypy . && pytest
fi
```

### 3. Check Environment
```bash
# Verify deployment CLI available
if ! command -v vercel &> /dev/null && ! command -v railway &> /dev/null; then
  echo "No deployment CLI found. Install vercel or railway CLI."
  exit 1
fi

# Check for required env vars
if [[ -f .env.example ]]; then
  echo "Required env vars:"
  grep -E "^[A-Z]" .env.example | cut -d= -f1
fi
```

## Deploy Commands

### Vercel (Frontend/Next.js)
```bash
# Preview deploy
vercel --yes

# Production deploy
vercel --prod --yes

# With environment variables
vercel --prod --yes --env-file .env.production
```

### Railway (Backend/Database)
```bash
# Deploy current directory
railway up

# Deploy with service name
railway up --service api

# Check deployment logs
railway logs
```

## Post-Deploy Verification

### 1. Health Check
```bash
# Get deployment URL from output
DEPLOY_URL=$(vercel ls --json | jq -r '.[0].url')

# Check health endpoint
curl -s "$DEPLOY_URL/api/health" | jq

# Check main page loads
curl -sI "$DEPLOY_URL" | head -1
```

### 2. Smoke Test
```
If tests exist:
- Run e2e tests against deployed URL
- Check critical user flows work
```

### 3. Log Errors
```bash
# Check for deployment errors
vercel logs --follow --output raw 2>&1 | head -50
```

## Rollback on Failure

```bash
# List recent deployments
vercel ls

# Promote previous deployment
vercel rollback [deployment-url]

# Railway rollback
railway rollback
```

## Output

```markdown
# Deploy Report

## Pre-Deploy
- [x] Security check passed
- [x] Lint passed
- [x] Types passed
- [x] Tests passed

## Deployment
- Platform: Vercel
- Environment: Preview/Production
- URL: https://...
- Time: Xs

## Verification
- [x] Health check passed
- [x] Main page loads
- [ ] E2E tests (if configured)

## Next Steps
- [ ] Verify in browser: [URL]
- [ ] Check logs if issues
- [ ] Promote to production (if preview)
```

## Integration

After successful deploy:
1. Update debug-log.md with deploy record
2. If production: Create git tag
3. Notify (if webhook configured)
