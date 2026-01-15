# PSL + Body Composition Integration Plan

## Overview
Integrate height, weight, and body composition into the onboarding flow, with Claude Vision analyzing physique photos to estimate body fat and calculate FFMI. PSL will be displayed alongside harmony score.

## Current State
- Height page exists: `src/app/height/page.tsx`
- HeightContext exists: `src/contexts/HeightContext.tsx`
- PSL calculator exists: `src/lib/psl-calculator.ts`
- Backend User model has `height_cm` field
- PSL Tab exists but is separate from Overview

## New Onboarding Flow
```
Signup → Gender → Ethnicity → Height → Weight → Physique Photos → Face Photos → Analysis → Results
```

---

## Phase 1: Weight Collection

### 1.1 Backend - Add weight field to User model
**File:** `looksmaxx-api/app/models/user.py`
- Add `weight_kg: Optional[float]` field

### 1.2 Backend - Weight endpoints
**File:** `looksmaxx-api/app/routers/psl.py`
- Add `PUT /psl/weight` endpoint
- Add `GET /psl/my-weight` endpoint

### 1.3 Frontend - Weight Context
**File:** `src/contexts/WeightContext.tsx` (new)
- Manage weight state with localStorage persistence
- Support kg and lbs input modes

### 1.4 Frontend - Weight Page
**File:** `src/app/weight/page.tsx` (new)
- Input weight in kg or lbs
- Show BMI preview based on height from HeightContext
- Navigate to physique upload next

---

## Phase 2: Physique Photo Upload

### 2.1 Frontend - Physique Upload Page
**File:** `src/app/physique/page.tsx` (new)
- Upload 3 photos: front, side, back
- Instructions for proper lighting/pose
- Store in PhysiqueContext

### 2.2 Frontend - Physique Context
**File:** `src/contexts/PhysiqueContext.tsx` (new)
- Store physique photo URLs/blobs
- Track upload status for each angle

### 2.3 Backend - Physique Storage
**File:** `looksmaxx-api/app/routers/physique.py` (new)
- Store physique photos (same pattern as face photos)

---

## Phase 3: Claude Vision Body Analysis

### 3.1 Backend - Body Analysis Service
**File:** `looksmaxx-api/app/services/body_analysis.py` (new)
- Use Claude Vision API to analyze physique photos
- Prompt engineering for body fat estimation
- Return: estimated body fat %, muscle level, notes

### 3.2 Backend - Body Analysis Endpoint
**File:** `looksmaxx-api/app/routers/physique.py`
- `POST /physique/analyze` - analyze uploaded photos
- Return body composition estimates

### 3.3 Frontend - Analysis Integration
**File:** `src/app/analysis/page.tsx` (modify)
- After face analysis, also run body analysis
- Show combined loading state

---

## Phase 4: FFMI Calculation

### 4.1 Frontend - FFMI Calculator
**File:** `src/lib/ffmi-calculator.ts` (new)
```typescript
// FFMI = (lean mass in kg) / (height in m)^2 + 6.1 × (1.8 - height in m)
// Lean mass = weight × (1 - body_fat_percent/100)
function calculateFFMI(heightCm: number, weightKg: number, bodyFatPercent: number): FFMIResult
```

### 4.2 FFMI Rating Scale
- Natural limit ~25-26 FFMI
- Rating 0-10 based on FFMI relative to natural limit

---

## Phase 5: PSL Display Integration

### 5.1 Update ResultsContext
**File:** `src/contexts/ResultsContext.tsx`
- Include body composition data
- Calculate full PSL with body score
- Expose PSL to Overview tab

### 5.2 PSL Preview on Overview
**File:** `src/components/results/tabs/OverviewTab.tsx`
- Add PSL score card widget
- Show tier badge
- Link to full PSL tab

### 5.3 Enhanced PSL Tab
**File:** `src/components/results/tabs/PSLTab.tsx`
- Show body composition breakdown
- Display FFMI with rating
- Show physique photos with annotations

---

## Phase 6: Database Migration

### 6.1 User Model Updates
```python
# looksmaxx-api/app/models/user.py
weight_kg: Optional[float] = None
body_fat_percent: Optional[float] = None
ffmi: Optional[float] = None
```

### 6.2 Physique Analysis Model
```python
# looksmaxx-api/app/models/physique.py (new)
class PhysiqueAnalysis(Base):
    id: UUID
    user_id: UUID
    front_photo_url: str
    side_photo_url: str
    back_photo_url: str
    estimated_body_fat: float
    muscle_level: str  # "low", "moderate", "high", "very_high"
    notes: str
    created_at: datetime
```

---

## Key Files Summary

### New Files
| File | Purpose |
|------|---------|
| `src/app/weight/page.tsx` | Weight input page |
| `src/app/physique/page.tsx` | Physique photo upload |
| `src/contexts/WeightContext.tsx` | Weight state management |
| `src/contexts/PhysiqueContext.tsx` | Physique photos state |
| `src/lib/ffmi-calculator.ts` | FFMI calculation |
| `looksmaxx-api/app/services/body_analysis.py` | Claude Vision analysis |
| `looksmaxx-api/app/routers/physique.py` | Physique endpoints |
| `looksmaxx-api/app/models/physique.py` | Physique DB model |

### Modified Files
| File | Changes |
|------|---------|
| `looksmaxx-api/app/models/user.py` | Add weight_kg, body_fat_percent, ffmi |
| `looksmaxx-api/app/routers/psl.py` | Add weight endpoints |
| `src/contexts/ResultsContext.tsx` | Include body data, expose PSL |
| `src/components/results/tabs/OverviewTab.tsx` | Add PSL preview card |
| `src/components/results/tabs/PSLTab.tsx` | Enhanced body breakdown |
| `src/app/height/page.tsx` | Navigate to weight next |

---

## Implementation Order

1. **Phase 1**: Weight collection (simpler, establishes pattern)
2. **Phase 2**: Physique photo upload UI
3. **Phase 3**: Claude Vision integration
4. **Phase 4**: FFMI calculation
5. **Phase 5**: PSL display updates
6. **Phase 6**: Database migrations (can be done incrementally)

---

## Decisions Made

1. **Physique photos**: Optional - users can skip, PSL uses default body score (5.0)
2. **Claude Vision API**: Backend proxy - keeps API key secure, allows caching
3. **Photo storage**: Use same S3/storage pattern as face photos
4. **Onboarding skip**: Allow "Skip" button on physique upload page

---

## Development Phases (Execute in Order)

### Sprint 1: Weight Collection (Start Here)
1. Add `weight_kg` to User model + migration
2. Create WeightContext + weight page
3. Add weight API endpoints
4. Update height page to navigate to weight

### Sprint 2: Physique Upload UI
1. Create PhysiqueContext + physique upload page
2. Add skip button + optional flow
3. Backend storage for physique photos

### Sprint 3: Claude Vision Integration
1. Add Anthropic API key to backend config
2. Create body_analysis service with Claude Vision
3. POST /physique/analyze endpoint
4. Frontend integration during analysis

### Sprint 4: FFMI + PSL Display
1. FFMI calculator function
2. Update ResultsContext with body data
3. PSL preview on Overview tab
4. Enhanced PSL tab with body breakdown
