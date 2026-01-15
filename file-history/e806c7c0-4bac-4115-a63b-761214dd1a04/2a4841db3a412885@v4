# Plan: Unified Railway Backend for LOOKSMAXX

## Key Finding: FaceIQ Architecture Analysis

**FaceIQ's calculation architecture:**
- **Client-side (Browser):** ALL ratio/score calculations happen in JavaScript
- **Server-side:** Only handles side landmark detection, auth, payments, storage

**What the server returns:**
```json
{
  "landmarks": [...467 coordinates...],
  "rotationAngle": -0.41,
  "direction": "right",
  "center": {"x": 381, "y": 479}
}
```

**The server does NOT calculate:**
- Facial ratios
- Harmony scores
- Symmetry metrics
- Final scores

**All scoring happens in the browser JS bundles!**

---

## Overview

Build a single Railway backend that handles:
- User authentication (NextAuth pattern)
- Stripe payments
- Data persistence (PostgreSQL)
- Image storage (S3/R2)
- Side profile landmark detection only (InsightFace)

## What This Means For Us

| Component | FaceIQ | Our Implementation |
|-----------|--------|-------------------|
| Front face detection | MediaPipe (browser) | MediaPipe (browser) ✅ Already done |
| Side face detection | Server API | InsightFace on Railway |
| Ratio calculations | Browser JS | Browser JS (src/lib/scoring.ts) ✅ Already done |
| Harmony scores | Browser JS | Browser JS ✅ Already done |
| Auth | NextAuth + Google | NextAuth + Google |
| Payments | Stripe | Stripe |
| Storage | Vercel Blob | S3/R2 |

**Key insight:** We already have the scoring logic in `src/lib/scoring.ts`. The server just needs to:
1. Detect side profile landmarks (InsightFace)
2. Store user data + analyses
3. Handle auth and payments

---

## Railway Resource Requirements

### Can Railway Handle It?

| Component | RAM | CPU | Railway Support |
|-----------|-----|-----|-----------------|
| FastAPI server | 256MB | Low | ✅ |
| PostgreSQL | 256MB | Low | ✅ (Railway add-on) |
| InsightFace model | **1.5-2GB** | Medium burst | ✅ (need Pro plan) |
| Stripe SDK | Negligible | Low | ✅ |
| S3 client | Negligible | Low | ✅ |

**Total RAM needed:** ~2.5GB minimum
**Railway Pro plan:** Supports up to 32GB RAM, $20/month base + usage

### Cost Estimate

| Users | Analyses/mo | Est. Cost |
|-------|-------------|-----------|
| 0-100 | 500 | ~$25/mo |
| 100-500 | 2,500 | ~$35/mo |
| 500-1000 | 5,000 | ~$50/mo |

**Verdict:** Railway can absolutely handle this. The InsightFace model is the main resource hog, but Railway Pro handles it fine.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Railway Platform                      │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐              │
│  │  FastAPI        │  │  PostgreSQL     │              │
│  │  (Python)       │◄─┤  (Railway DB)   │              │
│  │                 │  └─────────────────┘              │
│  │  - Auth         │                                   │
│  │  - Payments     │  ┌─────────────────┐              │
│  │  - Detection    │──┤  S3 / R2        │              │
│  │  - CRUD APIs    │  │  (Image Store)  │              │
│  └─────────────────┘  └─────────────────┘              │
└─────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────┐
│              Next.js Frontend (Vercel)                   │
│  - Calls /api/* endpoints on Railway                    │
│  - MediaPipe for front profile (unchanged)              │
└─────────────────────────────────────────────────────────┘
```

---

## Implementation Plan

### Phase 1: Core Backend Setup

**1.1 Project Structure**
```
looksmaxx-api/
├── app/
│   ├── main.py              # FastAPI app
│   ├── config.py            # Environment config
│   ├── database.py          # SQLAlchemy setup
│   ├── models/              # Database models
│   │   ├── user.py
│   │   ├── analysis.py
│   │   └── payment.py
│   ├── routers/             # API endpoints
│   │   ├── auth.py          # Login, register, JWT
│   │   ├── users.py         # User profile
│   │   ├── analyses.py      # CRUD analyses
│   │   ├── detection.py     # InsightFace
│   │   └── payments.py      # Stripe webhooks
│   ├── services/
│   │   ├── auth.py          # JWT, password hashing
│   │   ├── stripe.py        # Payment processing
│   │   ├── storage.py       # S3 uploads
│   │   └── detection.py     # InsightFace wrapper
│   └── schemas/             # Pydantic models
├── requirements.txt
├── Dockerfile
└── railway.json
```

**1.2 Database Schema**
```sql
-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR UNIQUE NOT NULL,
  password_hash VARCHAR NOT NULL,
  plan VARCHAR DEFAULT 'free',  -- free, basic, pro
  stripe_customer_id VARCHAR,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Analyses
CREATE TABLE analyses (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  front_image_url VARCHAR,
  side_image_url VARCHAR,
  front_landmarks JSONB,
  side_landmarks JSONB,
  scores JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Payments
CREATE TABLE payments (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  stripe_payment_id VARCHAR,
  amount INTEGER,
  status VARCHAR,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Phase 2: API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/register` | POST | Create account |
| `/auth/login` | POST | Get JWT token |
| `/auth/me` | GET | Get current user |
| `/analyses` | GET | List user's analyses |
| `/analyses` | POST | Create new analysis |
| `/analyses/{id}` | GET | Get specific analysis |
| `/detection/side` | POST | Detect side landmarks |
| `/images/upload` | POST | Upload to S3 |
| `/payments/checkout` | POST | Create Stripe session |
| `/payments/webhook` | POST | Stripe webhook |

### Phase 3: Face Detection Integration

Move existing InsightFace code into `/app/services/detection.py`:
- Load model on startup (singleton pattern)
- Endpoint accepts image, returns 106 landmarks + 28 mapped
- Calculate Frankfort Plane server-side
- Return full response to frontend

### Phase 4: Frontend Integration

Update Next.js app to:
1. Add authentication context
2. Store JWT token
3. Call Railway API instead of local API routes
4. Handle login/logout flow
5. Save analyses to backend

---

## Files to Create

### Backend (new repo: looksmaxx-api)
1. `app/main.py` - FastAPI with all routers
2. `app/database.py` - SQLAlchemy + PostgreSQL
3. `app/models/*.py` - Database models
4. `app/routers/auth.py` - JWT authentication
5. `app/routers/detection.py` - InsightFace endpoint
6. `app/routers/payments.py` - Stripe integration
7. `app/services/detection.py` - InsightFace wrapper
8. `requirements.txt` - Dependencies
9. `Dockerfile` - Railway deployment

### Frontend Updates
1. `src/contexts/AuthContext.tsx` - Auth state management
2. `src/lib/api.ts` - API client for Railway backend
3. Update `src/app/login/page.tsx` - Real login
4. Update detection to call Railway API

---

## Dependencies

```txt
# API Framework
fastapi==0.109.0
uvicorn[standard]==0.27.0

# Database
sqlalchemy==2.0.25
asyncpg==0.29.0
alembic==1.13.1

# Authentication
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4

# Payments
stripe==7.8.0

# Face Detection
insightface==0.7.3
onnxruntime==1.16.3
opencv-python-headless==4.9.0.80

# Storage
boto3==1.34.25

# Utilities
python-multipart==0.0.6
pydantic==2.5.3
pydantic-settings==2.1.0
```

---

## Environment Variables

```env
# Database
DATABASE_URL=postgresql://...

# Auth
JWT_SECRET=...
JWT_ALGORITHM=HS256

# Stripe
STRIPE_SECRET_KEY=sk_...
STRIPE_WEBHOOK_SECRET=whsec_...

# S3 Storage
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
S3_BUCKET=looksmaxx-images

# Frontend
FRONTEND_URL=https://looksmaxx.app
```

---

## Railway Setup

1. Create new Railway project
2. Add PostgreSQL database (Railway add-on)
3. Deploy Python service with Dockerfile
4. Configure environment variables
5. Set up custom domain

**Estimated deployment time:** 1-2 hours for basic setup
