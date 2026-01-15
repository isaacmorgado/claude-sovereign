# Leaderboard System Implementation Plan

## Overview
Add a leaderboard system to rank users by their facial harmony score using PostgreSQL materialized views.

## Key Requirements
- **GDPR Compliant**: Anonymous usernames (e.g., "User_a1b2c3")
- **Auth Required**: Must be logged in to view AND submit
- **Auto-Enrollment**: Users automatically join leaderboard on account creation (per T&C)
- **Profile Preview**: Clicking a user shows their face photo, score, 3 strengths, 3 areas to improve
- **Tab Position**: Between Side Ratios and Plan tabs
- **Persistent Score Display**: User's score visible on Overview, Front Ratios, Side Ratios, and Options tabs
- **Persistent Rank Badge**: User's rank (#X) always visible in top-right corner

---

## Architecture Decision
**PostgreSQL Native + Materialized View** (chosen because):
- Already have PostgreSQL on Railway (zero new infrastructure)
- Facial analysis scores don't change frequently
- Simple to implement in existing FastAPI backend
- Refresh every 10 minutes with pg_cron

---

## Database Schema

### Table: `leaderboard_scores`
```sql
CREATE TABLE leaderboard_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    analysis_id UUID REFERENCES analyses(id) ON DELETE SET NULL,
    score DECIMAL(4, 2) NOT NULL CHECK (score >= 0 AND score <= 10),
    gender VARCHAR(10) NOT NULL,
    ethnicity VARCHAR(30),
    anonymous_name VARCHAR(20) NOT NULL,  -- e.g., "User_a1b2c3"
    face_photo_url TEXT,                   -- S3/storage URL for face photo
    top_strengths JSONB,                   -- ["Jawline", "Eye spacing", "Nose width"]
    top_improvements JSONB,                -- ["Lip fullness", "Brow position", "Chin projection"]
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX idx_leaderboard_scores_score_desc ON leaderboard_scores(score DESC);
CREATE INDEX idx_leaderboard_scores_gender ON leaderboard_scores(gender);
```

### Materialized View: `leaderboard_rankings`
```sql
CREATE MATERIALIZED VIEW leaderboard_rankings AS
SELECT
    ls.*,
    DENSE_RANK() OVER (ORDER BY ls.score DESC) as global_rank,
    DENSE_RANK() OVER (PARTITION BY ls.gender ORDER BY ls.score DESC) as gender_rank,
    PERCENT_RANK() OVER (ORDER BY ls.score DESC) * 100 as percentile,
    COUNT(*) OVER () as total_users,
    COUNT(*) OVER (PARTITION BY ls.gender) as gender_total
FROM leaderboard_scores ls;

CREATE UNIQUE INDEX idx_leaderboard_rankings_user ON leaderboard_rankings(user_id);
CREATE INDEX idx_leaderboard_rankings_rank ON leaderboard_rankings(global_rank);

-- Refresh every 10 minutes via pg_cron
SELECT cron.schedule('*/10 * * * *', 'REFRESH MATERIALIZED VIEW CONCURRENTLY leaderboard_rankings');
```

---

## Backend Changes (FastAPI)

### New Files
| File | Purpose |
|------|---------|
| `app/models/leaderboard.py` | LeaderboardScore SQLAlchemy model |
| `app/routers/leaderboard.py` | API endpoints |

### API Endpoints (all require auth)
| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/leaderboard/score` | Submit/update user's score with face photo |
| `GET` | `/leaderboard/rank` | Get current user's rank |
| `GET` | `/leaderboard` | Get top N leaderboard entries |
| `GET` | `/leaderboard/around-me` | Get entries around user's rank |
| `GET` | `/leaderboard/user/{user_id}` | Get user profile (face, score, strengths) |

### Response Schemas
```python
class LeaderboardEntry(BaseModel):
    rank: int
    score: float
    anonymous_name: str          # "User_a1b2c3"
    gender: str
    face_photo_url: str | None
    is_current_user: bool

class UserProfile(BaseModel):
    rank: int
    score: float
    anonymous_name: str
    gender: str
    face_photo_url: str | None
    top_strengths: list[str]     # ["Jawline", "Eye spacing", "Nose width"]
    top_improvements: list[str]  # ["Lip fullness", "Brow position", "Chin projection"]
```

### Files to Modify
- `app/main.py` - Include leaderboard router
- `app/routers/__init__.py` - Export router
- `app/models/__init__.py` - Export model

---

## Frontend Changes (Next.js)

### New Files
| File | Purpose |
|------|---------|
| `src/contexts/LeaderboardContext.tsx` | State management for rank/leaderboard |
| `src/components/results/tabs/LeaderboardTab.tsx` | Leaderboard tab UI |
| `src/components/results/shared/RankBadge.tsx` | Persistent rank display (top-right) |
| `src/components/results/modals/UserProfileModal.tsx` | Clickable user profile popup |

### Files to Modify

#### 1. `src/types/results.ts` (line ~194)
Add `'leaderboard'` to `ResultsTab` union + leaderboard types:
```typescript
export type ResultsTab =
  | 'overview' | 'front-ratios' | 'side-ratios'
  | 'leaderboard'  // NEW
  | 'plan' | 'options' | 'support';

export interface LeaderboardEntry {
  rank: number;
  score: number;
  anonymousName: string;
  gender: 'male' | 'female';
  facePhotoUrl: string | null;
  isCurrentUser: boolean;
}

export interface UserProfile extends LeaderboardEntry {
  topStrengths: string[];
  topImprovements: string[];
}
```

#### 2. `src/components/results/ResultsLayout.tsx` (line ~31-38)
Update TABS array:
```typescript
import { Trophy } from 'lucide-react';

const TABS: TabConfig[] = [
  { id: 'overview', label: 'Overview', icon: <LayoutDashboard size={18} /> },
  { id: 'front-ratios', label: 'Front Ratios', icon: <User size={18} /> },
  { id: 'side-ratios', label: 'Side Ratios', icon: <ScanFace size={18} /> },
  { id: 'leaderboard', label: 'Leaderboard', icon: <Trophy size={18} /> },  // NEW
  { id: 'plan', label: 'Your Plan', icon: <Sparkles size={18} /> },
  { id: 'options', label: 'Options', icon: <Settings size={18} /> },
  { id: 'support', label: 'Support', icon: <HelpCircle size={18} /> },
];
```

Add RankBadge + Score to:
- **Mobile header** (line ~156-161): Right side shows `[Score: 7.8] [#42]`
- **Desktop sidebar** (line ~92-96): Below profile shows score + rank badge

#### 3. `src/components/results/Results.tsx`
Add case to switch statement:
```typescript
case 'leaderboard':
  return <LeaderboardTab />;
```

#### 4. `src/components/Providers.tsx`
Add LeaderboardProvider to wrapper hierarchy

#### 5. `src/lib/api.ts`
Add methods: `submitScore()`, `getMyRank()`, `getLeaderboard()`, `getUserProfile()`

---

## Persistent Score & Rank Display

The user's **score** and **rank** should be visible across ALL tabs in the dashboard:

### Mobile Header (all tabs)
```
┌──────────────────────────────────────────────┐
│ [≡]    Overview           [7.82] [🏆 #42]   │
└──────────────────────────────────────────────┘
```

### Desktop Sidebar (always visible)
```
┌─────────────────┐
│   [Face Photo]  │
│                 │
│  Harmony Score  │
│     7.82        │
│                 │
│   🏆 Rank #42   │
│   Top 3.4%      │
│                 │
│ ─────────────── │
│ Overview        │
│ Front Ratios    │
│ Side Ratios     │
│ Leaderboard     │  ← NEW TAB
│ Your Plan       │
│ Options         │
│ Support         │
└─────────────────┘
```

### Tabs Where Score/Rank Are Visible
| Tab | Score Visible | Rank Visible |
|-----|---------------|--------------|
| Overview | ✅ (in sidebar + header) | ✅ |
| Front Ratios | ✅ (in sidebar + header) | ✅ |
| Side Ratios | ✅ (in sidebar + header) | ✅ |
| Leaderboard | ✅ (prominent card) | ✅ (prominent card) |
| Your Plan | ✅ (in sidebar + header) | ✅ |
| Options | ✅ (in sidebar + header) | ✅ |
| Support | ✅ (in sidebar + header) | ✅ |

---

## UI Design

### Leaderboard Tab
```
┌─────────────────────────────────────────────┐
│ YOUR RANK                                   │
│ ┌─────────────────────────────────────────┐ │
│ │ #42 of 1,234 users  │  Top 3.4%         │ │
│ │ Score: 7.82         │  #18 among males  │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ [All ▼] [Male] [Female]     Gender Filter   │
│                                             │
│ TOP RANKINGS                                │
│ ┌─────────────────────────────────────────┐ │
│ │ 👑 #1  [photo] User_x7k2  9.45  male   │ │
│ │ 🥈 #2  [photo] User_m3n9  9.21  female │ │
│ │ 🥉 #3  [photo] User_p4q1  9.18  male   │ │
│ │    #4  [photo] User_r2s5  9.02  female │ │
│ │ ...                                     │ │
│ │ → #41 [photo] User_abc1  7.85  male    │ │
│ │ ★ #42 [photo] YOU        7.82  male    │ │  ← highlighted
│ │ → #43 [photo] User_def2  7.79  female  │ │
│ └─────────────────────────────────────────┘ │
│              [Load More]                    │
└─────────────────────────────────────────────┘
```

### User Profile Modal (on click)
```
┌─────────────────────────────────────────────┐
│ User_x7k2                            [X]    │
│ ┌───────────┐                               │
│ │  [FACE]   │  Rank: #1                     │
│ │  [PHOTO]  │  Score: 9.45                  │
│ └───────────┘  Gender: Male                 │
│                                             │
│ TOP STRENGTHS                               │
│ ✓ Jaw definition                            │
│ ✓ Canthal tilt                              │
│ ✓ Facial symmetry                           │
│                                             │
│ AREAS TO IMPROVE                            │
│ • Midface ratio                             │
│ • Lip fullness                              │
│ • Brow ridge                                │
└─────────────────────────────────────────────┘
```

---

## Anonymous Name Generation

Generate on account creation:
```python
import secrets
def generate_anonymous_name() -> str:
    return f"User_{secrets.token_hex(3)}"  # e.g., "User_a1b2c3"
```

---

## Auto-Enrollment Flow

1. User creates account → `anonymous_name` generated
2. User completes analysis → Score calculated
3. System auto-submits to leaderboard:
   - Score (overallScore from ResultsContext)
   - Face photo URL (frontPhoto)
   - Gender/ethnicity
   - Top 3 strengths (from `strengths` array)
   - Top 3 improvements (from `flaws` array)
4. Rank badge appears immediately in header/sidebar

---

## Implementation Order

1. **Database** - Create table + materialized view + pg_cron
2. **Backend Model** - `leaderboard.py` SQLAlchemy model
3. **Backend Router** - All endpoints with auth guards
4. **Frontend Types** - Update `results.ts`
5. **Frontend API** - Add methods to `api.ts`
6. **Frontend Context** - Create `LeaderboardContext.tsx`
7. **Frontend Components**:
   - `RankBadge.tsx` - Persistent display
   - `UserProfileModal.tsx` - Click to view profile
   - `LeaderboardTab.tsx` - Main tab
8. **Integration** - Update `ResultsLayout.tsx`, `Results.tsx`, `Providers.tsx`
9. **Auto-submit** - Hook into analysis completion to submit score

---

## Critical Files Summary

### Backend (CREATE)
- `looksmaxx-api/app/models/leaderboard.py`
- `looksmaxx-api/app/routers/leaderboard.py`

### Backend (MODIFY)
- `looksmaxx-api/app/main.py`
- `looksmaxx-api/app/models/__init__.py`
- `looksmaxx-api/app/routers/__init__.py`

### Frontend (CREATE)
- `looksmaxx-app/src/contexts/LeaderboardContext.tsx`
- `looksmaxx-app/src/components/results/tabs/LeaderboardTab.tsx`
- `looksmaxx-app/src/components/results/shared/RankBadge.tsx`
- `looksmaxx-app/src/components/results/modals/UserProfileModal.tsx`

### Frontend (MODIFY)
- `looksmaxx-app/src/types/results.ts` - Add leaderboard types
- `looksmaxx-app/src/lib/api.ts` - Add API methods
- `looksmaxx-app/src/components/results/ResultsLayout.tsx` - TABS + RankBadge + Score display
- `looksmaxx-app/src/components/results/Results.tsx` - Switch case
- `looksmaxx-app/src/components/Providers.tsx` - Add context

---

## Research Sources

### Real-World Implementations
| Repository | URL | Approach |
|------------|-----|----------|
| **Civitai** | https://github.com/civitai/civitai | PostgreSQL + `ROW_NUMBER() OVER (ORDER BY score DESC)` |
| **Monkeytype** | https://github.com/monkeytypegame/monkeytype | Redis ZREVRANK + daily/weekly resets |
| **redis-rank** | https://github.com/mlomb/redis-rank | npm package for Redis sorted set leaderboards |

### Why PostgreSQL Over Redis
1. Already have PostgreSQL on Railway (zero new infrastructure)
2. Facial analysis scores don't change frequently (not real-time game)
3. Simpler architecture - single database
4. Materialized views provide fast reads with 10-minute staleness (acceptable)
