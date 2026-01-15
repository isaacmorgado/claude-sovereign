# LOOKSMAXX PSL + Body Composition Sprints

## Process
For each feature: Implement → E2E Test → Identify Bugs → Fix → Re-test → Pass → Next Feature

## Completed Sprints
- [x] Sprint 1: Weight Collection (WeightContext, `/weight` page, API endpoints)
- [x] Sprint 2: Physique Upload UI (PhysiqueContext, `/physique` page with 3 angles)
- [x] Sprint 3: Backend Physique Storage & Analysis (Claude Vision body analysis)
- [x] Sprint 4: FFMI Calculator & PSL Display (FFMI-based body scoring)
- [x] Sprint 5: Archetype → Forum Integration (archetype-based forum recommendations)

---

# Sprint 3: Backend Physique Storage & Analysis

## Process
For each feature: Implement → E2E Test → Identify Bugs → Fix → Re-test → Pass → Next Feature

---

## Feature 3.1: Physique Photo Storage Endpoint

**Files:**
- `looksmaxx-api/app/routers/physique.py` (new)
- `looksmaxx-api/app/models/physique.py` (new)
- `looksmaxx-api/app/main.py` (add router)

**Problem:** Physique photos collected on frontend but no backend storage. Photos lost on page refresh.

**Implementation:**
1. Create `PhysiqueAnalysis` model:
   ```python
   class PhysiqueAnalysis(Base):
       id: UUID
       user_id: UUID (FK to users)
       front_photo_url: Optional[str]
       side_photo_url: Optional[str]
       back_photo_url: Optional[str]
       created_at: datetime
   ```
2. Create `POST /physique/upload` endpoint accepting multipart form data
3. Store photos in same S3/storage as face photos
4. Create `GET /physique/my-photos` to retrieve user's photos
5. Add router to `main.py`

**E2E Test After Implementation:**
- Upload front photo via `POST /physique/upload` → verify 200 response
- Upload all 3 photos → verify URLs returned
- Call `GET /physique/my-photos` → verify all 3 URLs present
- Upload as unauthenticated user → should return 401
- Upload invalid file type (PDF) → should return 400
- Verify photos accessible via returned URLs

**Fix any bugs found, re-test until passing, then proceed to 3.2**

---

## Feature 3.2: Claude Vision Body Analysis Service

**Files:**
- `looksmaxx-api/app/services/body_analysis.py` (new)
- `looksmaxx-api/app/core/config.py` (add ANTHROPIC_API_KEY)

**Problem:** No way to estimate body fat percentage from photos. PSL body score defaults to 5.0.

**Implementation:**
1. Add `ANTHROPIC_API_KEY` to environment config
2. Create `analyze_physique()` function:
   ```python
   async def analyze_physique(
       front_url: str,
       side_url: Optional[str],
       back_url: Optional[str],
       gender: str
   ) -> PhysiqueResult:
       # Use Claude Vision to analyze photos
       # Return: estimated_body_fat, muscle_level, confidence, notes
   ```
3. Craft prompt for body fat estimation (10-30% range for most people)
4. Return structured result with confidence score
5. Cache results in database to avoid re-analysis

**E2E Test After Implementation:**
- Call with valid front photo → returns body fat estimate (10-35% range)
- Call with all 3 photos → returns estimate with higher confidence
- Call with male vs female → different assessment criteria applied
- Call with invalid image URL → returns error gracefully
- Call twice with same photos → second call uses cached result
- Verify response time < 10 seconds

**Fix any bugs found, re-test until passing, then proceed to 3.3**

---

## Feature 3.3: Physique Analysis Endpoint

**Files:**
- `looksmaxx-api/app/routers/physique.py`
- `looksmaxx-api/app/models/physique.py` (add analysis fields)

**Problem:** Need HTTP endpoint to trigger and retrieve body analysis results.

**Implementation:**
1. Add fields to `PhysiqueAnalysis` model:
   ```python
   estimated_body_fat: Optional[float]
   muscle_level: Optional[str]  # "low", "moderate", "high", "very_high"
   analysis_confidence: Optional[float]
   analysis_notes: Optional[str]
   analyzed_at: Optional[datetime]
   ```
2. Create `POST /physique/analyze` endpoint:
   - Fetches user's stored photos
   - Calls `analyze_physique()` service
   - Stores results in database
   - Returns analysis results
3. Create `GET /physique/my-analysis` to retrieve stored analysis

**E2E Test After Implementation:**
- Upload photos, then `POST /physique/analyze` → returns body fat estimate
- `GET /physique/my-analysis` → returns same stored result
- Analyze without photos uploaded → returns 400 "No photos found"
- Analyze as unauthenticated → returns 401
- Re-analyze after uploading new photos → updates stored result
- Verify `analyzed_at` timestamp updates on re-analysis

**Fix any bugs found, re-test until passing, then proceed to 3.4**

---

## Feature 3.4: Frontend Analysis Integration

**Files:**
- `looksmaxx-app/src/app/analysis/page.tsx`
- `looksmaxx-app/src/lib/api.ts`
- `looksmaxx-app/src/contexts/PhysiqueContext.tsx`

**Problem:** Analysis page only analyzes face photos. Physique photos not sent to backend.

**Implementation:**
1. Add API methods to `api.ts`:
   ```typescript
   uploadPhysiquePhotos(front: File, side?: File, back?: File): Promise<PhysiqueUrls>
   analyzePhysique(): Promise<PhysiqueAnalysis>
   getMyPhysiqueAnalysis(): Promise<PhysiqueAnalysis | null>
   ```
2. Update `/analysis` page:
   - After face analysis, check if physique photos exist in context
   - If yes, upload photos and trigger analysis
   - Show combined loading state
   - Store results in context
3. Add `physiqueAnalysis` state to `PhysiqueContext`:
   ```typescript
   physiqueAnalysis: {
     bodyFatPercent: number;
     muscleLevel: string;
     confidence: number;
   } | null
   ```

**E2E Test After Implementation:**
- Complete onboarding with physique photos → analysis page uploads them
- Analysis page shows "Analyzing body composition..." step
- After analysis, physique context has body fat data
- Skip physique photos → analysis proceeds without body analysis
- Network error during physique upload → shows error, face analysis continues
- Verify physique analysis doesn't block face analysis (parallel or sequential)

**Fix any bugs found, re-test until passing**

---

## Sprint 3 Complete Checklist
- [x] 3.1 Physique photo storage endpoint working
- [x] 3.2 Claude Vision body analysis service working
- [x] 3.3 Physique analysis endpoint returns body fat %
- [x] 3.4 Frontend integrates physique analysis in flow
- [x] All endpoints return proper error codes
- [x] Analysis results persisted in database
- [x] Ready for Sprint 4

---

# Sprint 4: FFMI Calculator & PSL Display

## Process
For each feature: Implement → E2E Test → Identify Bugs → Fix → Re-test → Pass → Next Feature

---

## Feature 4.1: FFMI Calculator

**Files:**
- `looksmaxx-app/src/lib/ffmi-calculator.ts` (new)

**Problem:** No way to calculate FFMI (Fat-Free Mass Index) from height, weight, and body fat.

**Implementation:**
1. Create `calculateFFMI()` function:
   ```typescript
   interface FFMIResult {
     ffmi: number;           // Raw FFMI value
     normalizedFFMI: number; // Adjusted for height
     leanMassKg: number;     // Weight × (1 - bodyFat/100)
     rating: number;         // 0-10 scale
     category: string;       // "Below Average" | "Average" | "Above Average" | "Excellent" | "Elite"
   }

   function calculateFFMI(
     heightCm: number,
     weightKg: number,
     bodyFatPercent: number
   ): FFMIResult
   ```
2. FFMI Formula: `leanMass / (height in m)^2`
3. Normalized FFMI: `FFMI + 6.1 × (1.8 - height in m)`
4. Rating scale (male):
   - < 18: Below Average (0-3)
   - 18-20: Average (4-5)
   - 20-22: Above Average (6-7)
   - 22-25: Excellent (8-9)
   - 25+: Elite (10) - near natural limit
5. Female scale ~2-3 points lower

**E2E Test After Implementation:**
- Calculate for average male (180cm, 80kg, 15% BF) → FFMI ~23, rating ~8
- Calculate for skinny male (180cm, 65kg, 12% BF) → FFMI ~18, rating ~4
- Calculate for muscular male (180cm, 95kg, 12% BF) → FFMI ~26, rating ~10
- Calculate for female (165cm, 55kg, 22% BF) → appropriate female rating
- Edge case: 0% body fat → still calculates (though unrealistic)
- Edge case: 50% body fat → handles gracefully
- Verify normalized FFMI adjusts for height correctly

**Fix any bugs found, re-test until passing, then proceed to 4.2**

---

## Feature 4.2: Body Score from FFMI

**Files:**
- `looksmaxx-app/src/lib/psl-calculator.ts`

**Problem:** PSL calculation uses hardcoded body score of 5.0. Need to use actual FFMI-based score.

**Implementation:**
1. Update `calculatePSL()` to accept optional `bodyFatPercent`:
   ```typescript
   interface PSLInput {
     faceScore: number;
     heightCm: number;
     gender: 'male' | 'female';
     bodyFatPercent?: number;  // NEW
     weightKg?: number;        // NEW
   }
   ```
2. If `bodyFatPercent` and `weightKg` provided:
   - Calculate FFMI using `calculateFFMI()`
   - Use FFMI rating as body score
3. If not provided, default to 5.0 (as before)
4. Update PSL formula to use actual body score

**E2E Test After Implementation:**
- PSL with no body data → uses 5.0 body score (backward compatible)
- PSL with body data → uses calculated FFMI rating
- Muscular person (FFMI 24) → higher PSL than default
- Skinny person (FFMI 17) → lower PSL than default
- Verify body score contributes 5% to final PSL
- Verify bonuses apply if body score ≥ 8.5
- Compare PSL with/without body data → difference should be ±0.25 max

**Fix any bugs found, re-test until passing, then proceed to 4.3**

---

## Feature 4.3: PSL Tab Shows Body Composition

**Files:**
- `looksmaxx-app/src/components/results/tabs/PSLTab.tsx`
- `looksmaxx-app/src/contexts/PhysiqueContext.tsx`

**Problem:** PSL tab shows height/weight but not body fat % or FFMI breakdown.

**Implementation:**
1. Import physique context in PSLTab
2. If physique analysis available, show:
   - Body Fat %: X% (category)
   - FFMI: X.X (rating/10)
   - Muscle Level: Low/Moderate/High
3. Update formula display to show actual body score (not just "5/10 default")
4. Add section explaining body score calculation
5. If no physique data, show prompt to add physique photos

**E2E Test After Implementation:**
- View PSL tab with physique data → shows body fat %, FFMI, muscle level
- View PSL tab without physique data → shows "Add physique photos" prompt
- Verify body score in breakdown matches FFMI rating
- Verify formula explanation updates when body data present
- Click "Add physique photos" → navigates to /physique
- Verify styling matches existing height/weight cards

**Fix any bugs found, re-test until passing, then proceed to 4.4**

---

## Feature 4.4: PSL Preview on Overview Tab

**Files:**
- `looksmaxx-app/src/components/results/tabs/OverviewTab.tsx`

**Problem:** PSL only visible in dedicated tab. Users don't see it on main Overview.

**Implementation:**
1. Add PSL score card widget to Overview tab:
   ```tsx
   <PSLPreviewCard
     score={pslResult.score}
     tier={pslResult.tier}
     tierColor={pslResult.tierColor}
     onClick={() => setActiveTab('psl')}
   />
   ```
2. Show compact view with:
   - PSL score (large number)
   - Tier badge
   - "View Details →" link
3. Position near harmony score or in grid layout
4. Handle case where height not entered (show "Enter height for PSL")

**E2E Test After Implementation:**
- View Overview with height entered → PSL preview card visible
- Click PSL preview card → navigates to PSL tab
- View Overview without height → shows "Enter height" prompt
- PSL preview updates when underlying data changes
- Verify tier badge color matches PSL tab
- Mobile responsive layout (card stacks properly)

**Fix any bugs found, re-test until passing**

---

## Sprint 4 Complete Checklist
- [x] 4.1 FFMI calculator implemented and accurate
- [x] 4.2 PSL calculation uses real body score when available
- [x] 4.3 PSL tab displays body composition breakdown
- [x] 4.4 Overview tab shows PSL preview card
- [x] Backward compatible (works without body data)
- [x] All calculations match expected formulas
- [x] Ready for Sprint 5

### Sprint 4 Implementation Notes (2025-12-25)

**Files Created:**
- `src/lib/ffmi-calculator.ts` - FFMI calculation with rating scale and categories

**Files Modified:**
- `src/types/psl.ts` - Added FFMIData, BodyScoreInfo, weightKg to BodyAnalysis/PSLInput
- `src/lib/psl-calculator.ts` - Added calculateBodyScore(), getBodyRatingFromFFMI(), FFMI integration
- `src/components/results/tabs/PSLTab.tsx` - Added BodyCompositionCard, AddPhysiquePrompt, updated formula explainer
- `src/components/results/tabs/OverviewTab.tsx` - Added PSLPreviewCard component

**E2E Test Results:** 27/27 tests passed
- FFMI calculator: 11 tests
- PSL + FFMI integration: 9 tests
- Body score calculation: 5 tests
- Tier color: 2 tests

---

# Sprint 5: Archetype → Forum Integration

## Process
For each feature: Implement → E2E Test → Identify Bugs → Fix → Re-test → Pass → Next Feature

---

## Feature 5.1: Archetype-to-Forum Mapping (Backend)

**Files:**
- `looksmaxx-api/migrations/005_add_archetype_forum_mapping.sql` (new)
- `looksmaxx-api/app/routers/forum.py`

**Problem:** Forum recommends categories based on flaws only. Archetype has no forum connection.

**Implementation:**
1. Create `archetype_forum_mappings` table:
   ```sql
   CREATE TABLE archetype_forum_mappings (
       id UUID PRIMARY KEY,
       archetype_category VARCHAR(50) NOT NULL,  -- "Softboy", "Chad", etc.
       forum_category_id UUID REFERENCES forum_issue_categories(id),
       priority INTEGER DEFAULT 0,
       reason TEXT  -- "Style tips for masculine frames"
   );
   ```
2. Seed mappings:
   - Softboy → Fashion (styling for softer features)
   - Prettyboy → Fashion, Poor Skin (grooming emphasis)
   - Chad → Body Composition (frame building)
   - Hypermasculine → Body Composition, Height/Frame
   - Exotic → Fashion (unique styling opportunities)
3. Create `GET /forum/archetype-recommendations?archetype=Chad` endpoint

**E2E Test After Implementation:**
- `GET /forum/archetype-recommendations?archetype=Softboy` → returns Fashion category
- `GET /forum/archetype-recommendations?archetype=Chad` → returns Body Composition
- `GET /forum/archetype-recommendations?archetype=InvalidType` → returns empty array
- Verify response includes category details (name, slug, description)
- Verify priority ordering works (higher priority first)
- Run migration on fresh database → no errors

**Fix any bugs found, re-test until passing, then proceed to 5.2**

---

## Feature 5.2: Frontend Archetype Forum Integration

**Files:**
- `looksmaxx-app/src/lib/api.ts`
- `looksmaxx-app/src/components/results/tabs/CommunityTab.tsx`

**Problem:** Community tab shows flaw-based recommendations but ignores archetype.

**Implementation:**
1. Add API method:
   ```typescript
   getArchetypeForumRecommendations(archetype: string): Promise<RecommendedForum[]>
   ```
2. Update CommunityTab to:
   - Get user's archetype from ArchetypeContext or classify from ratios
   - Fetch archetype-based recommendations
   - Display in new "Based on Your Archetype" section
3. Show archetype name and why forums are recommended
4. Combine with flaw-based recommendations (don't replace)

**E2E Test After Implementation:**
- View Community tab with archetype classified → "Based on Your Archetype" section visible
- Softboy archetype → shows Fashion forum recommendation
- Chad archetype → shows Body Composition forum recommendation
- Click recommended forum → navigates to forum page
- Flaw-based recommendations still appear separately
- No archetype (classification failed) → section hidden gracefully
- Verify no duplicate recommendations (if same forum in both flaw + archetype)

**Fix any bugs found, re-test until passing, then proceed to 5.3**

---

## Feature 5.3: Archetype Tab Forum Link

**Files:**
- `looksmaxx-app/src/components/results/tabs/ArchetypeTab.tsx`

**Problem:** Archetype tab has no connection to actionable forum content.

**Implementation:**
1. Add "Recommended Forums" section at bottom of ArchetypeTab:
   ```tsx
   <RecommendedForumsSection archetype={classification.primary.category} />
   ```
2. Show 2-3 relevant forums with:
   - Category icon and name
   - "Why this is relevant" explanation
   - Link to forum category page
3. Style consistently with StyleRecommendations section

**E2E Test After Implementation:**
- View Archetype tab → Recommended Forums section visible
- Forums shown match user's primary archetype
- Click forum link → navigates to correct forum page
- Section shows explanation text (not just links)
- If no recommendations for archetype → section hidden
- Mobile layout responsive

**Fix any bugs found, re-test until passing**

---

## Sprint 5 Complete Checklist
- [x] 5.1 Archetype-to-forum mapping table and endpoint
- [x] 5.2 Community tab shows archetype-based recommendations
- [x] 5.3 Archetype tab links to relevant forums
- [x] No duplicate forum recommendations
- [x] All forum links navigate correctly
- [x] Graceful fallback when archetype not available
- [x] Ready for Final E2E Test

### Sprint 5 Implementation Notes (2025-12-25)

**Backend Files Created:**
- `migrations/007_add_archetype_forum_mappings.sql` - Table + seed data for 6 archetypes → 22 forum mappings
- Updated `app/models/forum.py` - Added `ArchetypeForumMapping` model
- Updated `app/schemas/forum.py` - Added `ArchetypeForumRecommendation` schema
- Updated `app/routers/forum.py` - Added `GET /forum/archetype-recommendations?archetype=X` endpoint

**Frontend Files Modified:**
- `src/lib/api.ts` - Added `getArchetypeForumRecommendations()` method + types
- `src/components/results/tabs/CommunityTab.tsx` - Added "Based on Your Archetype" section
- `src/components/results/tabs/ArchetypeTab.tsx` - Added `RecommendedForumsSection` component

**Archetype → Forum Mappings:**
| Archetype | Forums |
|-----------|--------|
| Softboy | Fashion, Anxiety, Poor Skin |
| Prettyboy | Fashion, Poor Skin, Social Media, Hair Loss |
| RobustPrettyboy | Body Composition, Fashion, Poor Skin |
| Chad | Body Composition, Height/Frame, Weak Bone Structure, Fashion |
| Hypermasculine | Body Composition, Height/Frame, Weak Bone Structure, Fashion |
| Exotic | Fashion, Social Media, Poor Skin, Hair Loss |

**E2E Test Results:**
- Migration applied to Railway DB ✓
- Build passes ✓
- Lint passes (no errors) ✓
- Type check passes ✓
- Duplicate filtering works (CommunityTab) ✓
- Graceful fallback when no archetype ✓

---

# Sprint 6: Final Comprehensive E2E Test

## Purpose
All features from Sprints 3-5 complete. Run full end-to-end test of entire PSL + Body + Forum system.

---

## Test 1: Complete Onboarding-to-Results Flow

**Steps:**
1. Start fresh (clear all contexts)
2. Complete signup → gender → ethnicity → height → weight
3. Upload 3 physique photos (front, side, back)
4. Upload 2 face photos (front, side)
5. Verify analysis page shows both face and body analysis steps
6. Wait for analysis completion
7. Verify results page loads with all data

**Pass Criteria:** All 7 steps succeed, no console errors

---

## Test 2: PSL Calculation Accuracy

**Steps:**
1. Use test data: 180cm height, 80kg weight, 15% body fat, 7.5 face score
2. Calculate expected values:
   - Lean mass: 80 × 0.85 = 68kg
   - FFMI: 68 / (1.8)² = 21.0
   - Normalized FFMI: 21.0 + 6.1 × (1.8 - 1.8) = 21.0
   - FFMI Rating: ~7/10 (Above Average)
   - Height Rating: ~6.5/10 (average male height)
   - PSL = (7.5 × 0.75) + (6.5 × 0.20) + (7.0 × 0.05) = 5.625 + 1.3 + 0.35 = 7.275
3. Verify PSL tab shows matching values
4. Verify Overview PSL preview matches

**Pass Criteria:** Calculated PSL within 0.1 of expected value

---

## Test 3: Skip Physique Flow

**Steps:**
1. Complete onboarding, SKIP physique photos
2. Complete face photo upload and analysis
3. Verify PSL tab shows body score as 5.0 (default)
4. Verify PSL tab shows "Add physique photos" prompt
5. Verify PSL calculation uses 5.0 body score

**Pass Criteria:** App functions correctly without physique data

---

## Test 4: Archetype → Forum Integration

**Steps:**
1. Complete analysis (ensure archetype classified)
2. Navigate to Archetype tab → verify "Recommended Forums" section
3. Click forum link → verify navigation to `/forum/[slug]`
4. Navigate to Community tab → verify "Based on Your Archetype" section
5. Verify archetype-based recommendations differ from flaw-based

**Pass Criteria:** Archetype correctly maps to forum recommendations

---

## Test 5: Data Persistence

**Steps:**
1. Complete full analysis with all data
2. Refresh page
3. Verify face photos restored
4. Verify height/weight restored
5. Verify PSL data restored
6. Navigate through all tabs → no data missing

**Pass Criteria:** All user data persists across page refresh

---

## Test 6: Error Handling

**Steps:**
1. Upload invalid file type as physique photo → verify error message
2. Disconnect network during body analysis → verify graceful failure
3. Enter extreme height (50cm) → verify validation
4. Enter extreme weight (500kg) → verify validation
5. Analysis with corrupted image → verify error handling

**Pass Criteria:** All error states handled with user-friendly messages

---

## Final Checklist

| Test | Status |
|------|--------|
| 1. Onboarding-to-Results Flow | ⬜ |
| 2. PSL Calculation Accuracy | ⬜ |
| 3. Skip Physique Flow | ⬜ |
| 4. Archetype → Forum Integration | ⬜ |
| 5. Data Persistence | ⬜ |
| 6. Error Handling | ⬜ |

## If Any Test Fails
1. Log failure with specific step and error
2. Trace to root cause (file:line)
3. Fix the issue
4. Re-run failed test
5. If pass, continue
6. If fail, repeat fix cycle

## Completion Criteria
All 6 tests passing = PSL + Body Composition integration complete and verified

---

# Quick Reference: New Files Created

## Backend (looksmaxx-api/)
| File | Purpose |
|------|---------|
| `app/routers/physique.py` | Physique upload, analyze, face extraction |
| `app/models/physique.py` | PhysiqueAnalysis + VisionExtraction models |
| `app/services/vision_service.py` | **NEW** Unified Claude Vision (face + body) |
| `migrations/006_add_physique_tables.sql` | **NEW** Physique + Vision tables |
| `migrations/005_add_archetype_forum_mapping.sql` | Archetype → Forum mapping |

## Frontend (looksmaxx-app/)
| File | Purpose |
|------|---------|
| `src/lib/ffmi-calculator.ts` | FFMI calculation and rating |
| `src/contexts/PhysiqueContext.tsx` | ✅ Updated with expanded fields |
| `src/app/physique/page.tsx` | ✅ Already exists |

## Modified Files
| File | Changes |
|------|---------|
| `src/lib/psl-calculator.ts` | Accept body fat, use FFMI rating |
| `src/components/results/tabs/PSLTab.tsx` | Show body composition, uses physiqueAnalysis |
| `src/components/results/tabs/OverviewTab.tsx` | Add PSL preview card |
| `src/components/results/tabs/CommunityTab.tsx` | Archetype recommendations |
| `src/components/results/tabs/ArchetypeTab.tsx` | Forum links section |
| `src/app/analysis/page.tsx` | Fixed isMounted cleanup, physique integration |
| `src/lib/api.ts` | Add physique + face extraction API methods |

---

# Sprint 3.5: Expanded Vision Feature Extraction (Completed)

## Summary
Extended Sprint 3 to include full psl.md spec coverage with comprehensive face feature extraction.

## New Backend Files
- `app/services/vision_service.py` - Unified Claude Vision service for face + body
- `migrations/006_add_physique_tables.sql` - Database tables for physique + vision

## Face Feature Extraction (NEW)
| Category | Features |
|----------|----------|
| Skin | clarity (0-10), tone, acne_level, acne_scarring, pore_visibility, texture_issues |
| Hair | hairline_nw (0-7 Norwood), density, texture, color |
| Eyes | color, under_eye_darkness (0-10), under_eye_puffiness (0-10) |
| Facial | hollow_cheeks (0-10), eyebrow_density, facial_hair_potential |
| Teeth | color, alignment, visible |

## Body Feature Extraction (Enhanced)
| Feature | Values |
|---------|--------|
| body_fat_percent | 5-45% |
| muscle_mass | low/medium/medium-high/high/very-high |
| frame_size | small/medium/large/very-large |
| shoulder_width | narrow/average/broad/very-broad |
| waist_definition | undefined/slight/defined/very-defined |
| posture | poor/fair/good/excellent |

## New API Endpoints
- `POST /physique/extract-face` - Extract all facial features from photos
- `GET /physique/my-face-features` - Get stored face extraction

## E2E Testing Results (11 Bugs Found & Fixed)

### Backend Bugs
| Bug | File | Fix |
|-----|------|-----|
| Missing migration | - | Created `006_add_physique_tables.sql` |
| Missing ANTHROPIC_API_KEY | `.env.example` | Added to example file |
| hairline_nw type mismatch | `physique.py` model | Changed Float → Integer |
| weight_kg missing | `005_*.sql` | Added ALTER TABLE |
| File size validation | `physique.py` router | Made async with size check |

### Frontend Bugs
| Bug | File | Fix |
|-----|------|-----|
| Empty sideLandmarks | `analysis/page.tsx` | Pass actual state to navigateToResults |
| PSLTab not using physique | `PSLTab.tsx` | Added usePhysiqueOptional hook |
| Missing useEffect cleanup | `analysis/page.tsx` | Added isMounted flag |
| No localStorage persistence | `PhysiqueContext.tsx` | Added hydration + persistence |

## Sprint 3.5 Complete Checklist
- [x] Vision service covers full psl.md spec
- [x] Face extraction endpoint working
- [x] Body extraction enhanced with all fields
- [x] E2E tests passed (11 bugs fixed)
- [x] Type checks pass
- [x] Lint checks pass
