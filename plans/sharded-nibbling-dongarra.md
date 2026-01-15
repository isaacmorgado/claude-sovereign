# SPLICE - Complete Specification Document

> AI-powered Premiere Pro plugin for detecting takes, removing silences, and accelerating video editing workflows.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Constraints](#2-constraints)
3. [Architecture](#3-architecture)
4. [Database Schema](#4-database-schema)
5. [API Endpoints](#5-api-endpoints)
6. [Project Structure](#6-project-structure)
7. [User Flow](#7-user-flow)
8. [MVP vs Later Features](#8-mvp-vs-later-features)
9. [Vertical Slices](#9-vertical-slices)

---

## 1. Overview

### What SPLICE Does

1. User selects clip(s) in Premiere Pro timeline
2. Plugin exports audio to temp file
3. Audio uploaded to cloud API
4. Groq Whisper transcribes with word-level timestamps
5. GPT-4o-mini analyzes transcript to detect takes, false starts, silences
6. Plugin receives structured data
7. Plugin applies markers, colors, or auto-edits to timeline

### Tech Stack

| Layer | Technology |
|-------|------------|
| Plugin | UXP (React + TypeScript) |
| Frontend | Next.js on Vercel |
| Backend | Next.js API on Railway |
| Database | PostgreSQL on Railway |
| Storage | Cloudflare R2 |
| AI | Groq (Whisper), OpenAI (GPT-4o-mini) |
| Payments | Stripe |
| Auth | Custom JWT |

---

## 2. Constraints

### Platform Constraints (Premiere Pro UXP)

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| No direct audio access | Cannot read waveform data | Export via `exportAsMediaDirect()` to temp file |
| HTTPS only (bug in v25.6.3) | HTTP requests fail | Use HTTPS for all API calls |
| Labels attach to ProjectItem | All TrackItem instances share labels | Fine for take detection use case |
| ExtendScript deprecated Sept 2026 | Must use UXP APIs | Build on UXP from start |
| Manifest network permissions | Must whitelist domains | Declare in manifest.json |

### Backend Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| Groq file limit: 25MB | Long recordings may exceed | Chunk audio or use URL param |
| Replicate URLs expire in 1hr | Must download immediately | Download in webhook handler (if using Demucs) |
| Serverless timeouts | Vercel: 300s max | Synchronous flow fits within limit |
| Rate limits | Groq: 20 req/min (free) | Implement backoff, upgrade plan |

### Business Constraints

| Constraint | Decision |
|------------|----------|
| Usage-based pricing | Track minutes processed per user |
| Multi-tenant | Row-level isolation by user_id |
| No Demucs by default | Skip vocal isolation (60-120s), add as optional later |

---

## 3. Architecture

### System Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         SPLICE ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐         ┌──────────────┐         ┌────────────┐  │
│  │  PREMIERE    │         │   VERCEL     │         │  RAILWAY   │  │
│  │  UXP PLUGIN  │         │   FRONTEND   │         │  BACKEND   │  │
│  │              │         │              │         │            │  │
│  │  • Export    │         │  • Landing   │         │  • API     │  │
│  │  • Upload    │────────▶│  • Dashboard │────────▶│  • Auth    │  │
│  │  • Display   │         │  • Billing   │         │  • Usage   │  │
│  │  • Apply     │         │  • Account   │         │  • DB      │  │
│  └──────────────┘         └──────────────┘         └─────┬──────┘  │
│         │                                                 │         │
│         │                                                 │         │
│         ▼                                                 ▼         │
│  ┌──────────────┐                                ┌───────────────┐  │
│  │ CLOUDFLARE   │                                │   EXTERNAL    │  │
│  │     R2       │                                │   SERVICES    │  │
│  │              │                                │               │  │
│  │  • Audio     │◀───────────────────────────────│  • Groq       │  │
│  │    uploads   │                                │  • OpenAI     │  │
│  └──────────────┘                                │  • Stripe     │  │
│                                                  └───────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Flow (Happy Path)

```
PLUGIN                          BACKEND                         EXTERNAL
──────                          ───────                         ────────

[1] Export audio (MP3 16kHz mono)
         │
         ▼
[2] POST /api/upload/presign ──► Generate R2 presigned URL
         │                              │
         ▼                              │
[3] PUT to R2 URL ──────────────────────────────────────────────► R2 Bucket
         │
         ▼
[4] POST /api/analyze ─────────► [5] Check usage limit
    {audioUrl, duration}                │
                                        ▼
                                 [6] Fetch audio from R2
                                        │
                                        ▼
                                 [7] POST to Groq Whisper ──────► Whisper
                                     (verbose_json, word timestamps)
                                        │
                                        ▼
                                 [8] POST to GPT-4o-mini ───────► GPT-4o
                                     (structured output)
                                        │
                                        ▼
                                 [9] Record usage
                                        │
         ◀──────────────────────────────┘
         │
[10] Receive {takes, markers, silences}
         │
         ▼
[11] Apply to timeline (markers, colors)
```

### Processing Time Budget

| Step | Duration | Cumulative |
|------|----------|------------|
| Export (5min clip) | ~10s | 10s |
| Upload (5MB) | ~3s | 13s |
| Groq Whisper | ~5s | 18s |
| GPT-4o-mini | ~5s | 23s |
| Apply markers | ~2s | **25s total** |

---

## 4. Database Schema

### Tables

```sql
-- ═══════════════════════════════════════════════════════════════
-- USERS
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  tier TEXT NOT NULL DEFAULT 'free',        -- free | pro | enterprise
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_stripe_customer ON users(stripe_customer_id);

-- ═══════════════════════════════════════════════════════════════
-- USAGE
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  action TEXT NOT NULL,                     -- 'analyze'
  audio_seconds INTEGER NOT NULL,           -- Duration processed
  metadata JSONB,                           -- {takesFound, groupsFound, etc}
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_usage_user_created ON usage(user_id, created_at);

-- ═══════════════════════════════════════════════════════════════
-- API_KEYS (for future programmatic access)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  key_hash TEXT NOT NULL,                   -- Hashed API key
  name TEXT NOT NULL,                       -- User-provided name
  last_used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  revoked_at TIMESTAMPTZ
);

CREATE INDEX idx_api_keys_user ON api_keys(user_id);
CREATE INDEX idx_api_keys_hash ON api_keys(key_hash);
```

### Tier Limits (Constants)

```typescript
export const TIER_LIMITS = {
  free: {
    monthlyMinutes: 30,
    maxFileSizeMB: 50,
    maxDurationMinutes: 10,
    priceMonthly: 0
  },
  pro: {
    monthlyMinutes: 300,
    maxFileSizeMB: 500,
    maxDurationMinutes: 30,
    priceMonthly: 19
  },
  enterprise: {
    monthlyMinutes: 3000,
    maxFileSizeMB: 2000,
    maxDurationMinutes: 120,
    priceMonthly: 99
  }
} as const
```

---

## 5. API Endpoints

### Summary Table

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/register` | No | Create account |
| POST | `/api/auth/login` | No | Get JWT token |
| GET | `/api/auth/me` | Yes | Get current user |
| POST | `/api/upload/presign` | Yes | Get presigned upload URL |
| POST | `/api/analyze` | Yes | Transcribe + analyze audio |
| GET | `/api/usage` | Yes | Get usage stats |
| POST | `/api/webhooks/stripe` | Sig | Handle Stripe events |

### Detailed Specifications

#### POST /api/auth/register

```typescript
// Request
{
  "email": "user@example.com",
  "password": "min8characters"
}

// Response 201
{
  "user": { "id": "uuid", "email": "user@example.com", "tier": "free" },
  "token": "eyJhbG..."
}

// Response 409
{ "error": "Email already registered", "code": "EMAIL_EXISTS" }

// Response 422
{ "error": "Password must be at least 8 characters", "code": "VALIDATION_ERROR" }
```

#### POST /api/auth/login

```typescript
// Request
{
  "email": "user@example.com",
  "password": "password123"
}

// Response 200
{
  "user": { "id": "uuid", "email": "user@example.com", "tier": "pro" },
  "token": "eyJhbG..."
}

// Response 401
{ "error": "Invalid credentials", "code": "INVALID_CREDENTIALS" }
```

#### GET /api/auth/me

```typescript
// Headers: Authorization: Bearer <token>

// Response 200
{
  "id": "uuid",
  "email": "user@example.com",
  "tier": "pro",
  "createdAt": "2025-01-15T10:00:00Z"
}

// Response 401
{ "error": "Unauthorized", "code": "UNAUTHORIZED" }
```

#### POST /api/upload/presign

```typescript
// Headers: Authorization: Bearer <token>

// Request
{
  "filename": "audio_export_1234.mp3",
  "contentType": "audio/mpeg",
  "fileSizeBytes": 5242880
}

// Response 200
{
  "uploadUrl": "https://bucket.r2.cloudflarestorage.com/...?X-Amz-Signature=...",
  "fileUrl": "https://uploads.splice.app/user-uuid/audio_export_1234.mp3",
  "expiresIn": 3600
}

// Response 413
{ "error": "File size exceeds limit for your tier", "code": "FILE_TOO_LARGE" }
```

#### POST /api/analyze (Main Endpoint)

```typescript
// Headers: Authorization: Bearer <token>

// Request
{
  "audioUrl": "https://uploads.splice.app/user-uuid/audio.mp3",
  "durationSeconds": 245.5,
  "options": {
    "detectTakes": true,
    "detectSilence": true,
    "silenceThresholdMs": 500,
    "language": "en"
  }
}

// Response 200
{
  "id": "analysis_uuid",
  "status": "completed",
  "duration": {
    "audio": 245.5,
    "processing": 8.2
  },
  "transcript": {
    "text": "Full transcript...",
    "segments": [
      { "id": 0, "start": 0.0, "end": 5.2, "text": "Okay, take one.", "confidence": 0.95 }
    ],
    "words": [
      { "word": "Okay", "start": 0.0, "end": 0.3 },
      { "word": "take", "start": 0.35, "end": 0.6 }
    ]
  },
  "analysis": {
    "takes": [
      {
        "takeNumber": 1,
        "startTime": 0.0,
        "endTime": 5.0,
        "transcript": "Okay, take one.",
        "type": "slate",
        "quality": "marker"
      },
      {
        "takeNumber": 2,
        "startTime": 6.1,
        "endTime": 45.3,
        "transcript": "In the morning light...",
        "type": "full",
        "quality": "good"
      }
    ],
    "groups": [
      {
        "groupId": 1,
        "label": "Verse 1",
        "takes": [2, 3, 4],
        "bestTake": 4
      }
    ],
    "silences": [
      { "start": 45.3, "end": 47.0, "duration": 1.7 }
    ],
    "suggestedMarkers": [
      { "time": 0.0, "label": "Take 1 - Slate", "color": "yellow" },
      { "time": 6.1, "label": "Take 2 - Verse 1", "color": "green" }
    ]
  },
  "usage": {
    "minutesCharged": 4.1,
    "minutesRemaining": 250.4
  }
}

// Response 402
{
  "error": "Monthly usage limit reached",
  "code": "USAGE_LIMIT_EXCEEDED",
  "usage": { "minutesUsed": 300, "minutesLimit": 300, "tier": "pro" },
  "upgradeUrl": "https://splice.app/upgrade"
}

// Response 422
{ "error": "Audio duration exceeds maximum for your tier", "code": "AUDIO_TOO_LONG" }
```

#### GET /api/usage

```typescript
// Headers: Authorization: Bearer <token>

// Response 200
{
  "tier": "pro",
  "period": {
    "start": "2025-01-01T00:00:00Z",
    "end": "2025-01-31T23:59:59Z"
  },
  "usage": {
    "minutesUsed": 45.5,
    "minutesLimit": 300,
    "minutesRemaining": 254.5,
    "percentUsed": 15.2
  },
  "limits": {
    "maxFileSizeMB": 500,
    "maxDurationMinutes": 30
  },
  "history": [
    { "date": "2025-01-15", "minutes": 12.3, "count": 3 }
  ]
}
```

---

## 6. Project Structure

### Plugin (splice-plugin/)

```
splice-plugin/
├── manifest.json              # UXP metadata, permissions
├── package.json
├── tsconfig.json
│
├── src/
│   ├── index.tsx              # Entry point
│   ├── App.tsx                # Main app, routing
│   │
│   ├── panels/
│   │   ├── MainPanel.tsx      # Analyze UI, results
│   │   └── LoginPanel.tsx     # Auth UI
│   │
│   ├── components/
│   │   ├── AnalyzeButton.tsx  # Export + analyze trigger
│   │   ├── ProgressBar.tsx    # Processing status
│   │   ├── TakeList.tsx       # Results display
│   │   ├── TakeItem.tsx       # Single take row
│   │   ├── UsageMeter.tsx     # Remaining minutes
│   │   └── ErrorBanner.tsx    # Error display
│   │
│   ├── hooks/
│   │   ├── usePremiere.ts     # Premiere API wrapper
│   │   ├── useAuth.ts         # Token management
│   │   ├── useAnalyze.ts      # Analysis orchestration
│   │   └── useUsage.ts        # Usage display
│   │
│   ├── services/
│   │   ├── api.ts             # HTTP client
│   │   ├── premiere/
│   │   │   ├── export.ts      # Audio export
│   │   │   ├── markers.ts     # Marker CRUD
│   │   │   ├── colors.ts      # Clip colors
│   │   │   └── clips.ts       # Clip info
│   │   └── storage.ts         # Local persistence
│   │
│   ├── types/
│   │   ├── api.ts
│   │   ├── premiere.ts
│   │   └── analysis.ts
│   │
│   └── utils/
│       ├── time.ts            # Ticks <-> seconds
│       ├── upload.ts          # Presigned upload
│       └── constants.ts       # Config
│
├── styles/
│   └── main.css
│
└── dist/                      # Built .ccx
```

### Backend (splice-api/)

```
splice-api/
├── package.json
├── tsconfig.json
├── next.config.js
├── drizzle.config.ts
├── Dockerfile
│
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   │
│   │   └── api/
│   │       ├── auth/
│   │       │   ├── register/route.ts
│   │       │   ├── login/route.ts
│   │       │   └── me/route.ts
│   │       │
│   │       ├── upload/
│   │       │   └── presign/route.ts
│   │       │
│   │       ├── analyze/
│   │       │   └── route.ts
│   │       │
│   │       ├── usage/
│   │       │   └── route.ts
│   │       │
│   │       └── webhooks/
│   │           └── stripe/route.ts
│   │
│   ├── lib/
│   │   ├── db/
│   │   │   ├── index.ts       # Drizzle client
│   │   │   ├── schema.ts      # Table definitions
│   │   │   └── migrations/
│   │   │
│   │   ├── auth/
│   │   │   ├── jwt.ts
│   │   │   ├── password.ts
│   │   │   └── middleware.ts
│   │   │
│   │   ├── services/
│   │   │   ├── groq.ts
│   │   │   ├── openai.ts
│   │   │   ├── r2.ts
│   │   │   └── stripe.ts
│   │   │
│   │   ├── usage/
│   │   │   ├── check.ts
│   │   │   ├── record.ts
│   │   │   └── limits.ts
│   │   │
│   │   └── utils/
│   │       ├── errors.ts
│   │       ├── response.ts
│   │       └── validate.ts
│   │
│   └── types/
│       ├── api.ts
│       └── analysis.ts
│
└── .env.example
```

### Frontend (splice-web/)

```
splice-web/
├── package.json
├── next.config.js
│
├── src/
│   ├── app/
│   │   ├── layout.tsx
│   │   ├── page.tsx           # Landing
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   ├── dashboard/
│   │   │   ├── page.tsx       # Usage overview
│   │   │   └── settings/page.tsx
│   │   └── pricing/page.tsx
│   │
│   ├── components/
│   │   ├── Header.tsx
│   │   ├── PricingTable.tsx
│   │   └── UsageChart.tsx
│   │
│   └── lib/
│       ├── api.ts
│       └── auth.ts
│
└── .env.example
```

---

## 7. User Flow

### First-Time User

```
1. DISCOVERY
   └── User finds SPLICE (website, Adobe Exchange, word of mouth)

2. SIGNUP
   ├── Visit splice.app
   ├── Click "Get Started Free"
   ├── Enter email + password
   └── Account created (free tier: 30 min/month)

3. INSTALL PLUGIN
   ├── Download .ccx from website
   ├── Double-click to install (or via Creative Cloud)
   └── Restart Premiere Pro

4. FIRST USE
   ├── Open Premiere Pro project
   ├── Window > Extensions > SPLICE
   ├── Login with email/password
   └── See "30 minutes remaining"

5. ANALYZE
   ├── Select clip(s) on timeline
   ├── Click "Analyze"
   ├── Wait ~25 seconds
   └── See detected takes, silences

6. APPLY
   ├── Review detected takes
   ├── Click "Apply Markers"
   └── See markers appear on timeline

7. UPGRADE (when limit hit)
   ├── See "Monthly limit reached"
   ├── Click "Upgrade to Pro"
   ├── Enter payment (Stripe checkout)
   └── Resume editing with 300 min/month
```

### Returning User

```
1. Open Premiere Pro project
2. Open SPLICE panel (already logged in via stored token)
3. Select clip → Analyze → Apply
4. Check usage in panel footer
```

---

## 8. MVP vs Later Features

### MVP (v1.0) - Ship First

| Feature | Priority | Rationale |
|---------|----------|-----------|
| User auth (email/password) | P0 | Required for usage tracking |
| Audio export from timeline | P0 | Core functionality |
| Groq Whisper transcription | P0 | Core functionality |
| GPT-4o-mini take detection | P0 | Core value proposition |
| Add markers to timeline | P0 | Primary output |
| Usage tracking + limits | P0 | Business model |
| Stripe payments (Pro tier) | P0 | Revenue |
| Basic web dashboard | P0 | Account management |

### Post-MVP (v1.x) - Iterate

| Feature | Priority | Rationale |
|---------|----------|-----------|
| Set clip colors by take quality | P1 | Visual feedback |
| Auto-remove silences (ripple edit) | P1 | Major time saver |
| Batch analyze multiple clips | P1 | Workflow efficiency |
| Export analysis as JSON/CSV | P2 | Integration |
| Demucs vocal isolation (optional) | P2 | Noisy audio edge case |
| API keys for automation | P2 | Power users |
| Team accounts | P2 | Enterprise |
| DaVinci Resolve plugin | P3 | Market expansion |
| Final Cut Pro plugin | P3 | Market expansion |

### Explicitly Not in MVP

- Social auth (Google, Adobe ID)
- Real-time collaboration
- Cloud project storage
- Mobile app
- Custom AI model training

---

## 9. Vertical Slices

Each slice is a deployable increment with test criteria.

### Slice 0: Project Scaffolding

**Build:**
- [ ] Initialize splice-api (Next.js, TypeScript, Drizzle)
- [ ] Initialize splice-plugin (UXP, React, TypeScript)
- [ ] Initialize splice-web (Next.js, Tailwind)
- [ ] Set up Railway project + Postgres
- [ ] Set up Cloudflare R2 bucket
- [ ] Configure environment variables

**Test Criteria:**
- `npm run dev` works in all three projects
- Backend connects to Postgres
- R2 bucket accepts uploads via AWS SDK
- Plugin loads in Premiere Pro (blank panel)

**Dependencies:** None
**Risk:** Low
**Time:** Foundation

---

### Slice 1: Backend Auth

**Build:**
- [ ] Database schema (users table)
- [ ] POST /api/auth/register
- [ ] POST /api/auth/login
- [ ] GET /api/auth/me
- [ ] JWT sign/verify utilities
- [ ] Password hashing (bcrypt)
- [ ] Auth middleware

**Test Criteria:**
```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}'
# Returns: {user, token}

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}'
# Returns: {user, token}

# Me (with token)
curl http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer <token>"
# Returns: {id, email, tier}
```

**Dependencies:** Slice 0
**Risk:** Low (standard patterns)
**Time:** Foundation

---

### Slice 2: Plugin Auth UI

**Build:**
- [ ] API client service (api.ts)
- [ ] Token storage (localStorage)
- [ ] LoginPanel component
- [ ] useAuth hook
- [ ] Manifest network permissions

**Test Criteria:**
- Open plugin in Premiere Pro
- Enter email/password
- Click Login
- See "Logged in as user@test.com"
- Close/reopen plugin → still logged in

**Dependencies:** Slice 1
**Risk:** Medium (UXP networking quirks)
**Time:** Core flow

---

### Slice 3: File Upload Pipeline

**Build:**
- [ ] POST /api/upload/presign endpoint
- [ ] R2 presigned URL generation
- [ ] Plugin upload utility
- [ ] Test with dummy file

**Test Criteria:**
```bash
# Get presigned URL
curl -X POST http://localhost:3000/api/upload/presign \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"filename":"test.mp3","contentType":"audio/mpeg"}'
# Returns: {uploadUrl, fileUrl}

# Upload file to presigned URL
curl -X PUT "<uploadUrl>" \
  -H "Content-Type: audio/mpeg" \
  --data-binary @test.mp3
# Returns: 200 OK
```

- Plugin can upload file and receive public URL

**Dependencies:** Slice 1
**Risk:** Medium (R2 configuration, CORS)
**Time:** Core flow

---

### Slice 4: Premiere Audio Export

**Build:**
- [ ] premiere/export.ts service
- [ ] Get sequence in/out points
- [ ] Export to temp directory
- [ ] Return file path + duration
- [ ] AnalyzeButton component (triggers export)

**Test Criteria:**
- Select clip in Premiere Pro
- Click "Export Audio" test button
- File appears in temp directory
- Console logs duration in seconds
- MP3 file is playable

**Dependencies:** Slice 2
**Risk:** HIGH (UXP/Premiere API learning curve)
**Time:** Critical path validation

---

### Slice 5: Transcription Service

**Build:**
- [ ] Groq client wrapper (lib/services/groq.ts)
- [ ] Fetch audio from URL
- [ ] Call Whisper with word timestamps
- [ ] Return structured transcript
- [ ] Test endpoint (temporary)

**Test Criteria:**
```bash
# Test transcription directly
curl -X POST http://localhost:3000/api/test/transcribe \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"audioUrl":"https://example.com/test.mp3"}'
# Returns: {text, segments, words}
```

- Words array has start/end timestamps
- Segment confidence scores present

**Dependencies:** Slice 3
**Risk:** Low (Groq API is straightforward)
**Time:** Core value

---

### Slice 6: Analysis Service

**Build:**
- [ ] OpenAI client wrapper (lib/services/openai.ts)
- [ ] Zod schema for analysis output
- [ ] GPT-4o-mini prompt for take detection
- [ ] Structured output parsing
- [ ] Test endpoint (temporary)

**Test Criteria:**
```bash
# Test analysis with sample transcript
curl -X POST http://localhost:3000/api/test/analyze \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"transcript":{...}}'
# Returns: {takes, groups, silences, suggestedMarkers}
```

- Takes have correct types (slate, full, false_start)
- Groups reference valid take numbers
- Suggested markers have colors

**Dependencies:** Slice 5
**Risk:** Medium (prompt engineering iteration)
**Time:** Core value

---

### Slice 7: Main Analyze Endpoint

**Build:**
- [ ] POST /api/analyze endpoint
- [ ] Chain: validate → transcribe → analyze
- [ ] Return combined response
- [ ] Error handling

**Test Criteria:**
```bash
curl -X POST http://localhost:3000/api/analyze \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"audioUrl":"...","durationSeconds":120}'
# Returns full analysis response
```

- Response includes transcript + analysis
- Processing time < 30s for 2min audio
- Errors return proper codes

**Dependencies:** Slices 5, 6
**Risk:** Low (integration)
**Time:** Core value

---

### Slice 8: Plugin Full Flow (No Markers)

**Build:**
- [ ] useAnalyze hook
- [ ] Connect export → upload → analyze
- [ ] Display results in TakeList
- [ ] ProgressBar during processing
- [ ] Error handling UI

**Test Criteria:**
- Select clip in Premiere
- Click Analyze
- See progress bar
- See list of detected takes
- Each take shows: number, time range, type, quality

**Dependencies:** Slices 4, 7
**Risk:** Medium (UX polish)
**Time:** First usable product

---

### Slice 9: Apply Markers

**Build:**
- [ ] premiere/markers.ts service
- [ ] Add markers at specified times
- [ ] Set marker colors
- [ ] "Apply Markers" button in UI

**Test Criteria:**
- After analysis, click "Apply Markers"
- Markers appear on timeline at take start times
- Marker names match take labels
- Colors match quality (green=good, red=bad)

**Dependencies:** Slice 8
**Risk:** Medium (Premiere API)
**Time:** Core value delivery

---

### Slice 10: Usage Tracking

**Build:**
- [ ] usage table + queries
- [ ] checkUsageLimit() before processing
- [ ] recordUsage() after success
- [ ] GET /api/usage endpoint
- [ ] UsageMeter component in plugin
- [ ] 402 error handling in plugin

**Test Criteria:**
- Free user sees "30 minutes remaining"
- After 4-min analysis, shows "26 minutes remaining"
- After 30 minutes total, analysis blocked
- Plugin shows upgrade prompt

**Dependencies:** Slice 7
**Risk:** Low
**Time:** Business model

---

### Slice 11: Stripe Integration

**Build:**
- [ ] Stripe product/price setup
- [ ] Checkout session creation
- [ ] Webhook handler (subscription events)
- [ ] Upgrade flow in web dashboard
- [ ] Tier update in database

**Test Criteria:**
- Free user clicks "Upgrade to Pro"
- Redirected to Stripe checkout
- After payment, tier updates to "pro"
- Plugin shows 300 minutes limit

**Dependencies:** Slice 10
**Risk:** Medium (Stripe webhook complexity)
**Time:** Revenue

---

### Slice 12: Web Dashboard

**Build:**
- [ ] Landing page
- [ ] Login/register pages
- [ ] Dashboard with usage chart
- [ ] Settings page
- [ ] Pricing page

**Test Criteria:**
- User can register/login via web
- Dashboard shows usage history
- Can upgrade from web
- Download plugin button works

**Dependencies:** Slices 1, 10, 11
**Risk:** Low
**Time:** Polish

---

### Slice 13: Production Hardening

**Build:**
- [ ] Rate limiting
- [ ] Input validation (all endpoints)
- [ ] Error logging (Sentry or similar)
- [ ] CORS configuration
- [ ] Security headers
- [ ] Database indexes

**Test Criteria:**
- Cannot exceed rate limits
- Invalid inputs return 422
- Errors logged with context
- No CORS errors from plugin
- Load test: 10 concurrent requests

**Dependencies:** All previous
**Risk:** Low
**Time:** Ship readiness

---

## Build Order Summary

```
Week 1: Foundation
├── Slice 0: Scaffolding
├── Slice 1: Backend Auth
└── Slice 4: Premiere Export ← HIGHEST RISK, validate early

Week 2: Core Pipeline
├── Slice 2: Plugin Auth UI
├── Slice 3: File Upload
├── Slice 5: Transcription
└── Slice 6: Analysis

Week 3: Integration
├── Slice 7: Analyze Endpoint
├── Slice 8: Plugin Full Flow
└── Slice 9: Apply Markers ← FIRST USABLE PRODUCT

Week 4: Business
├── Slice 10: Usage Tracking
├── Slice 11: Stripe
└── Slice 12: Dashboard

Week 5: Ship
├── Slice 13: Hardening
└── Launch MVP
```

---

## Environment Variables

### Backend (.env)

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/splice

# Auth
JWT_SECRET=<256-bit-secret>
JWT_EXPIRY=7d

# AI Services
GROQ_API_KEY=gsk_xxx
OPENAI_API_KEY=sk-xxx

# Storage (Cloudflare R2)
R2_ACCOUNT_ID=xxx
R2_ACCESS_KEY_ID=xxx
R2_SECRET_ACCESS_KEY=xxx
R2_BUCKET_NAME=splice-uploads
R2_PUBLIC_URL=https://uploads.splice.app

# Payments
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
STRIPE_PRICE_PRO=price_xxx
STRIPE_PRICE_ENTERPRISE=price_xxx

# App
API_URL=https://api.splice.app
NODE_ENV=production
```

### Frontend (.env)

```bash
NEXT_PUBLIC_API_URL=https://api.splice.app
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_xxx
```

### Plugin (constants.ts)

```typescript
export const API_URL = "https://api.splice.app"
```

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| UXP audio export doesn't work as expected | Medium | High | Validate in Slice 4 first |
| Premiere API changes | Low | High | Pin to specific PPro version |
| Groq rate limits | Medium | Medium | Implement backoff, upgrade plan |
| GPT-4o-mini output quality | Medium | Medium | Iterate prompts, add examples |
| R2 CORS issues | Medium | Low | Test early, configure properly |
| Stripe webhook failures | Low | Medium | Implement retry logic |

---

## Success Metrics (MVP)

| Metric | Target |
|--------|--------|
| Time to first analysis | < 2 minutes after install |
| Analysis accuracy | > 90% takes correctly identified |
| Processing time | < 30s for 5-min clip |
| Conversion (free → paid) | > 5% |
| Monthly churn | < 10% |

---

*Document version: 1.0*
*Last updated: 2025-01-18*
