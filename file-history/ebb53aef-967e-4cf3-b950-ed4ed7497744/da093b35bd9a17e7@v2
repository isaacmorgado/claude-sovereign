# LOOKSMAXX Frontend

Next.js 14 facial metrics analysis app with harmony-based scoring.

## Live URL
https://looksmaxx-app.vercel.app

## Code Quality

```bash
npm run lint && npx tsc --noEmit
```

## Feature Parity Status: 100% Complete ✅

### Scoring System (Verified 2025-12-25)

| Component | Count | File | Details |
|-----------|-------|------|---------|
| **Bezier Curves** | 67 | `src/lib/bezier-curves.ts` | Complete cubic Bezier interpolation with 10-15 control points each |
| **Decay Rates** | 80+ | `src/lib/data/metric-configs.ts` | 0.08-1.0 range (ratios: 0.08-0.30, angles: 0.5-1.0) |
| **Ethnicity Overrides** | 16 demographics | `src/lib/data/demographic-overrides.ts` | 8 ethnicities × 2 genders = 16 combos with 130+ metric overrides |
| **Severity Tiers (Raw)** | 6 | `src/lib/scoring/types.ts` | extremely_severe/severe/major/moderate/minor/optimal |
| **Severity Tiers (Insights)** | 5 | `src/lib/insights-engine.ts` | Z-score based: ideal/good/fair/moderate/severe |
| **Quality Tiers** | 4 | `src/lib/scoring/types.ts` | ideal/excellent/good/below_average |
| **PSL Rating** | 10 tiers | `src/lib/psl-calculator.ts` | 1-10 scale with percentile mapping |
| **Total Metrics** | 80+ | `src/lib/data/metric-configs.ts` | Front + side profile measurements |

### Treatment/Recommendation System (Verified 2025-12-25)

| Component | Count | File | Details |
|-----------|-------|------|---------|
| **Procedure Impact Tables** | 30+ | `src/lib/advice-engine.ts` | Quantitative % changes per metric |
| **Treatment Metadata** | Full | `src/lib/advice-engine.ts` | priority_score, effectiveness, ratios_impacted, pillars |
| **Potential Score Prediction** | Yes | `src/lib/recommendations/severity.ts:644-693` | `estimatePotentialPSL()` with diminishing returns (20% reduction per treatment) |
| **Multi-Procedure Plans** | 5 phases | `src/lib/recommendations/engine.ts` | Lifestyle → Softmaxxing → Non-Surgical → Minimally Invasive → Surgical |
| **Order of Operations** | Yes | `src/lib/recommendations/engine.ts:517-577` | `generateOrderOfOperations()` with prerequisites |
| **Gender-Specific Treatments** | Yes | `src/lib/advice-engine.ts` | V-line Surgery, Masseter Botox (female-only) |

### FaceIQ Parity Features (Implemented 2025-12-26) ✅

| Feature | File | Details |
|---------|------|---------|
| **Confidence Levels** | `src/lib/insights-engine.ts` | `calculateFlawConfidence()` - Z-score based: \|z\|>=2=confirmed, 1-2=likely, 0.5-1=possible |
| **ConfidenceBadge** | `src/components/results/cards/*.tsx` | UI badges in StrengthFlawCards, KeyStrengthsFlaws, WeakPointCard |
| **Exclusive Categories** | `src/lib/advice-engine.ts` | `TREATMENT_EXCLUSIVITY` - 10 categories, 20+ treatment mappings |
| **Conflict Detection** | `src/lib/recommendations/engine.ts` | `findTreatmentConflicts()`, `filterConflictingRecommendations()`, `validateTreatmentSelection()` |
| **Conflict UI** | `src/components/results/cards/TreatmentConflictWarning.tsx` | ConflictCard, TreatmentConflictList, SelectionWarningModal |
| **Landmarks Per Metric** | `src/lib/data/metric-configs.ts` | `usedLandmarks: string[]` on 30 key metrics |
| **Dual Curve System** | `src/lib/bezier-curves.ts` | `DISPLAY_CURVES`, `getScoringCurve()`, `getDisplayCurve()`, `hasDisplayCurve()` |

**Exclusive Categories:** jaw_augmentation, jaw_reduction, chin_augmentation, cheekbone_augmentation, lip_augmentation, lip_reduction, submental_fat_removal, neck_procedures, eye_lateral_canthus, maxillary_surgery

**Metrics with Landmarks:** faceWidthToHeight, gonialAngle, lateralCanthalTilt, nasalIndex, nasolabialAngle, facialConvexity, mandibularPlaneAngle, etc. (30 total)

### Detailed Feature Breakdown

#### Bezier Curves (67 Total)
All metrics use custom cubic Bezier interpolation:
- Facial proportions: faceWidthToHeight (11 points), totalFacialWidthToHeight (12 points)
- Eye measurements: eyeAspectRatio (10 points), lateralCanthalTilt
- Jaw geometry: gonialAngle, bigonialWidth, jawWidthRatio
- Nasal features: nasalIndex, nasolabialAngle, nasalProjection

#### Decay Rate Calibration
Original values were 3-210x too harsh. Now calibrated by metric type:

**Ratios/Proportions (0.08-0.30)** - Lenient scoring:
- `faceWidthToHeight`: 0.12 (was 6.4 - 53x reduction)
- `midfaceRatio`: 0.15 (was 31.6 - 210x reduction)
- `totalFacialWidthToHeight`: 0.15 (was 13.2 - 88x reduction)
- `nasalIndex`: 0.25, `gonialAngle`: 0.08

**Angles/Positions (0.5-1.0)** - Stricter scoring:
- `earProtrusionAngle`: 1.0
- `burstoneUpperLip/LowerLip`: 1.0
- `bigonialWidth`: 0.9, `jawSlope`: 0.8

#### Ethnicity Overrides (8 Ethnicities x 2 Genders)
1. White (Neoclassical standard)
2. Black (African phenotype)
3. East Asian (Asian standard)
4. South Asian (South Asian standard)
5. Hispanic (Latin standard)
6. Middle Eastern
7. Native American
8. Pacific Islander

Each has gender-specific ideal ranges for 15+ metrics.

#### PSL Tiers
| PSL Range | Tier | Percentile |
|-----------|------|------------|
| 7.5+ | Top Model | 99.99% |
| 7.0-7.49 | Chad | 99.87% |
| 6.5-6.99 | Chadlite | 99.0% |
| 6.0-6.49 | High Tier Normie+ | 97.25% |
| 5.5-5.99 | High Tier Normie | 90.0% |
| 5.0-5.49 | Mid Tier Normie+ | 84.15% |
| 4.5-4.99 | Mid Tier Normie | 65.0% |
| 4.0-4.49 | Low Tier Normie | 50.0% |
| 3.5-3.99 | Below Average | 30.0% |
| 3.0-3.49 | Subpar | 15.0% |

#### Procedure Categories (30+)
**Surgical**: Genioplasty, Rhinoplasty, Jaw Implants, Bimaxillary Osteotomy, Canthoplasty, Cheek Implants, Neck Liposuction, Brow Bone, V-Line Surgery

**Minimally Invasive**: Chin Filler, Jawline Filler, Cheek Filler, Lip Filler, PDO Thread Lift, Masseter Botox, Kybella

**Foundational**: Mewing, Body Recomposition, Posture Correction, Skincare, Eyebrow Grooming, Beard Growth

#### Medical Tourism Regions (9) - Full Coverage ✅
All 25 surgeries have pricing for 9 destinations:

| Region | Surgeries | Price Advantage | Notes |
|--------|-----------|-----------------|-------|
| USA | 25 | Base | Gold standard pricing |
| Turkey | 18 | 50-70% cheaper | World capital of hair transplants |
| South Korea | 15 | 40-60% cheaper | V-line & aesthetic jaw surgery leader |
| Mexico | 25 | 35-50% cheaper | Tijuana/Mexico City - border proximity |
| UK | 25 | Similar to USA | Harley Street specialists (GBP) |
| Germany | 25 | Similar to USA | Munich/Berlin (EUR) |
| Spain | 25 | 20-35% cheaper | Barcelona/Madrid - Dr. Alfaro (EUR) |
| Thailand | 25 | 40-60% cheaper | Bangkok medical tourism hub |
| Brazil | 25 | 50-70% cheaper | São Paulo/Rio - world leader in body contouring |

File: `src/lib/recommendations/hardmaxxing.ts`

## Archetype Classification ✅

| Component | File | Details |
|-----------|------|---------|
| **Archetype Data** | `src/data/archetypes.json` | 6 categories, sub-archetypes, style guides |
| **Classifier** | `src/lib/archetype-classifier.ts` | Scoring based on gonialAngle, FWHR, canthalTilt |
| **ArchetypeCard** | `src/components/psl/archetype/ArchetypeCard.tsx` | Display archetype with confidence, traits |
| **ArchetypeTraits** | `src/components/psl/archetype/ArchetypeTraits.tsx` | Trait badges, dimorphism levels |
| **ArchetypeTab** | `src/components/results/tabs/ArchetypeTab.tsx` | Full archetype analysis page |
| **API Methods** | `src/lib/api.ts` | classifyArchetype, getArchetypeDefinitions |

**Categories**: Softboy, Prettyboy, RobustPrettyboy, Chad, Hypermasculine (Warrior), Exotic

## Female Analysis ✅

| Component | Status | Details |
|-----------|--------|---------|
| **8 Ethnicity Overrides** | ✓ Pass | All female ethnicities have distinct ideal ranges |
| **Sexual Dimorphism** | ✓ Pass | Narrower jaws, softer angles, larger eyes for females |
| **Scoring at Ideal Values** | ✓ Pass | 95.4% test pass rate |
| **Female Treatments** | ✓ Pass | V-line surgery, Masseter Botox (female-only) |
| **Gender Filtering** | ✓ Pass | Engine correctly filters by gender |
| **Insights/Flaws** | ✓ Pass | 8 female overrides with flaws property |

## Key Pages

- `/` - Landing page
- `/signup` - Registration with username, T&C, referral code
- `/login` - Email/password login
- `/forgot-password` - Password reset request
- `/reset-password` - Password reset form (with token)
- `/terms` - Terms & Conditions
- `/gender` - Gender selection
- `/ethnicity` - Ethnicity selection
- `/upload` - Photo upload
- `/analysis` - Face analysis
- `/results` - Results with leaderboard
- `/forum` - Community forum

## UI Components

### Results Page
- Error boundary for graceful error handling
- Debug info display in loading state
- 10 tabs: Overview, Front Ratios, Side Ratios, Leaderboard, PSL, Archetype, Plan, Community, Options, Support

### Visualization
- `BeforeAfterPreview.tsx` - Visual overlay showing potential improvements
- `TreatmentTimeline.tsx` - Phase-based treatment sequencing UI
- `ScoreCircle` - Animated score display
- `RankBadge` - Leaderboard rank indicator

## Product Guides System (In Progress)

### Phase 0: Setup - COMPLETE (2025-12-26)

| Component | File | Details |
|-----------|------|---------|
| **Guide Types** | `src/types/guides.ts` | Region, Product, Guide interfaces + locale/timezone mappings |
| **Region Utility** | `src/lib/region.ts` | detectRegion, getProductLink, buildAmazonUrl, formatPrice |
| **Region Context** | `src/contexts/RegionContext.tsx` | useRegion hook with state, link resolution, price formatting |
| **Provider Integration** | `src/components/Providers.tsx` | RegionProvider wired into app |

**Features:**
- Multi-region affiliate link support (US, UK, DE, FR, AU, Asia)
- Auto-detection via localStorage → navigator.language → timezone → default
- Region-aware price formatting with currency symbols
- Amazon URL builder with affiliate tags

### Phase 1: Product Database - COMPLETE (2025-12-26)

| Component | File | Details |
|-----------|------|---------|
| **Product Registry** | `src/data/guides/products-registry.ts` | 33 products with ASINs |
| **Index Export** | `src/data/guides/index.ts` | Central export for all guide data |
| **E2E Test** | `src/app/api/test-guides/route.ts` | Verification endpoint (21/21 tests pass) |

**Products by Category:**
- Hygiene (4): Tongue scraper, cologne, gloves, toothbrush
- Grooming (5): OneBlade, blades, shaving cream, tweezers, trimmer
- Skincare (5): Cleanser, chapstick, moisturizer, sunscreen, tretinoin
- Miscellaneous (9): Water jug, jaw trainer, minoxidil, dermaroller, etc.
- Supplements (10): Creatine, D3+K2, magnesium, omega-3, etc.

**Features:**
- All 33 products with 6-region affiliate links (US/UK/DE/FR/AU/Asia)
- Ross-style taglines for each product
- Priority rankings (1=essential, 2=recommended, 3=optional)
- 15 base stack products identified
- Helper functions: getGuideProductById, getGuideProductsByCategory, getBaseStackProducts, searchGuideProducts

### Phase 2: Guide Content - COMPLETE (2025-12-26)

| Component | File | Details |
|-----------|------|---------|
| **Mindset Guide** | `src/data/guides/mindset.ts` | Beginner mistakes, high humor (30%) |
| **Maintenance Guide** | `src/data/guides/maintenance.ts` | Daily/weekly grooming, high humor (25%) |
| **Body Fat Guide** | `src/data/guides/body-fat.ts` | Fat loss fundamentals, medium-high humor (20%) |
| **V-Taper Guide** | `src/data/guides/v-taper.ts` | Shoulder/lat building, medium humor (15%) |
| **Training Guide** | `src/data/guides/training.ts` | Workout splits, medium humor (15%) |
| **Core & Neck Guide** | `src/data/guides/core-neck.ts` | Neck thickness, core training, medium humor (15%) |
| **Cardio Guide** | `src/data/guides/cardio.ts` | LISS vs HIIT, fat loss cardio, medium humor (15%) |
| **Diet Guide** | `src/data/guides/diet.ts` | Nutrition fundamentals, medium humor (15%) |
| **Skincare Guide** | `src/data/guides/skincare.ts` | Acne, tretinoin, routines, medium humor (15%) |

**Guide System Stats:**
- 9 guides with Ross-style content
- 95 minutes total reading time
- 3 categories: Fundamentals, Physique, Appearance
- 19 unique product references across guides
- Helper functions: getGuideById, getGuideBySlug, getGuidesByCategory, searchGuides, getRelatedGuides

See `docs/PRODUCT_GUIDES_IMPLEMENTATION.md` for full implementation plan.

### Phase 4: UI Components - COMPLETE (2025-12-26)

| Component | File | Details |
|-----------|------|---------|
| **GuidesTab** | `src/components/results/tabs/GuidesTab.tsx` | Full guide browsing UI with gender filtering |
| **GuideStatsCard** | `src/components/results/tabs/GuidesTab.tsx` | Shows 27 guides, 346 min reading time |
| **GuideCard** | `src/components/results/tabs/GuidesTab.tsx` | Individual guide display with hover effects |
| **CategorySection** | `src/components/results/tabs/GuidesTab.tsx` | Color-coded category grouping with gender awareness |
| **SearchBar** | `src/components/results/tabs/GuidesTab.tsx` | Real-time guide search |
| **Tab Integration** | `src/components/results/Results.tsx` | Wired into results page navigation |

**Features:**
- 7 color-coded categories (cyan/purple/amber/pink/emerald/red)
- **Gender-specific filtering**: Male users see male guides, female users see female guides
- Search by title, description, subtitle, tags
- Guide cards with: icon, title, subtitle, description, sections, products, read time
- Responsive grid (1 col mobile, 2 cols desktop)
- Smooth hover animations
- Constrained media sizing (max-h-400px)

### Phase 5: Media & Conversion Features - COMPLETE (2025-12-26)

| Component | File | Details |
|-----------|------|---------|
| **GuideMedia Type** | `src/types/guides.ts` | GIF/image/video support with placement options |
| **MediaRenderer** | `src/components/results/tabs/GuidesTab.tsx` | Renders GIFs (animated) and images (optimized) |
| **ProductCallout** | `src/components/results/tabs/GuidesTab.tsx` | Conversion-optimized affiliate product cards |
| **ForumDiscussionLink** | `src/components/results/tabs/GuidesTab.tsx` | Links guides to forum categories |

**Media Features:**
- Hero images for guides (skincare, maintenance, v-taper)
- Inline GIFs for technique demonstrations
- Caption support for media
- Placement options: inline, hero, full-width
- GIF animation preserved (uses img), images optimized (uses next/image)

**Product Callout Features:**
- Region-aware affiliate links via useRegion()
- Product image, name, brand, Ross-style tagline
- "Buy Now" CTA button with ShoppingCart icon
- Gradient background for visual prominence

**Forum Integration:**
- "Discuss This Guide" section at end of each guide
- Links to relevant forum category (skincare → /forum/skincare)
- Guide data includes forumCategory field
- MessageSquare icon for visual consistency

**Guides with Media:**
| Guide | Hero | Section GIFs | Forum Category |
|-------|------|--------------|----------------|
| Skincare | ✅ | Cleansing technique, Tretinoin application, Timeline image | skincare |
| Maintenance | ✅ | Tongue scraping technique | hygiene-grooming |
| V-Taper | ✅ | (None yet) | body-composition |

## Remaining Tasks

### High Priority
1. Test full payment flow with referral discount
2. Add actual GIF/image assets to `/public/guides/` folder

### In Progress
3. Product Guides Implementation (Phase 6-7 remaining)
   - Phase 6-7: Polish, QA, and Launch

### Completed
- Forum link to main navigation ✅
- Product Guides Phase 0-5 ✅ (Types, Products, Content, UI, Media/Conversions)
- Auth endpoints verified working ✅ (23/23 API tests pass)
- Score clamping bug fixed ✅ (scores now always 0-10)
- Side profile orientation bug fixed ✅ (2025-12-26)
- Image downsampling for performance ✅ (2025-12-26) - 4-9x faster detection
- Leaderboard UI enhanced ✅ (2025-12-26)
- Guide media support ✅ (2025-12-26) - GIFs, images, captions, placements
- ProductCallout component ✅ (2025-12-26) - Region-aware affiliate CTAs
- Forum discussion links ✅ (2025-12-26)
- Fix Your Weak Points Flow ✅ (2025-12-26)
- v.toFixed TypeError fixed ✅ (2025-12-26) - Type guards in IdealRangeBar/GradientRangeBar
- Guide image sizing fixed ✅ (2025-12-26) - Constrained to max-h-400px
- Gender-specific guide filtering ✅ (2025-12-26) - Male/female guides filtered by user gender

## Performance Optimizations (2025-12-26) ✅

| Optimization | File | Details |
|--------------|------|---------|
| **MediaPipe Downsampling** | `src/lib/faceDetectionService.ts` | Images downsampled to 640px max before detection |
| **Edge Detection Downsampling** | `src/lib/sideProfileDetection.ts` | Images downsampled to 480px max for edge processing |
| **GPU Delegation** | `src/lib/faceDetectionService.ts` | WebGL acceleration enabled via `delegate: 'GPU'` |

## Bug Fixes (2025-12-26) ✅

| Bug | File | Fix |
|-----|------|-----|
| **Side profile orientation inverted** | `src/lib/sideProfileDetection.ts:199` | Changed `faceOnLeft ? 'right' : 'left'` to `faceOnLeft ? 'left' : 'right'` |
| **Landmarks sticking to left side** | Same as above | Edge detection now correctly identifies which side the face is on |
| **v.toFixed TypeError** | `src/components/results/visualization/IdealRangeBar.tsx`, `GradientRangeBar.tsx` | Added type guards: `if (typeof v !== 'number' \|\| isNaN(v)) return '-'` |
| **Guide images too large** | `src/components/results/tabs/GuidesTab.tsx` | Added `max-h-[400px] object-contain` to constrain media height |
| **Gender guides not filtered** | `src/components/results/tabs/GuidesTab.tsx` | Added `getGuidesByGender()` filtering using ResultsContext gender |

## Fix Your Weak Points Flow (2025-12-26) ✅

Complete conversion-optimized flow for fixing flaws with products and treatments.

### Components

| Component | File | Details |
|-----------|------|---------|
| **YourPhaseCard** | `src/components/results/tabs/PlanTab.tsx` | Shows bulk/cut/maintain based on body fat % |
| **WeakPointCard** | `src/components/results/cards/WeakPointCard.tsx` | Expandable flaw card with products/treatments |
| **ProgressComparisonCard** | `src/components/results/cards/ProgressComparisonCard.tsx` | Before/after comparison with photo upload |
| **ProductBundleCard** | `src/components/results/tabs/PlanTab.tsx` | Bundled product recommendations CTA |

### Features

**YourPhaseCard:**
- Body fat % from Vision analysis (PhysiqueContext)
- Gender-specific thresholds: Males (12%/18%), Females (18%/25%)
- Phase determination: Bulk (below threshold), Maintain (in range), Cut (above threshold)
- Visual icons and color-coded badges

**WeakPointCard:**
- Expandable cards for top 5 flaws
- Severity-based coloring (red/orange/yellow)
- Contributing metrics display
- Related products (up to 2 per flaw)
- Related treatments (up to 3 per flaw)
- "View Full Fix Plan" CTA

**ProgressComparisonCard:**
- Current vs previous analysis comparison
- Photo upload with preview
- Score difference indicators (trend up/down/same)
- Upload flow with camera capture option

**ProductBundleCard:**
- Bundles 3+ recommended products
- Total cost estimate with range
- Priority sorting by urgency
- "Get Your Fix Bundle" CTA

### Type Fixes

Fixed cascading `string | number` type errors for obfuscated scores across:
- `src/components/results/shared/index.tsx` (ScoreCircle)
- `src/components/results/ResultsLayout.tsx`
- `src/components/results/tabs/OverviewTab.tsx` (ProfileScoreCard, PSL calculation)
- `src/components/results/tabs/PlanTab.tsx`
- `src/components/results/tabs/PSLTab.tsx`
- `src/components/results/visualization/FaceOverlay.tsx`
- `src/components/results/shared/ShareButton.tsx`
- `src/lib/shareResults.ts`
- `src/lib/archetype-classifier.ts`
- `src/lib/results/analysis.ts`

## UX Improvements (2025-12-26) ✅

### Dark Theme Fixes
| Component | File | Details |
|-----------|------|---------|
| **StrengthFlawCards** | `src/components/results/cards/StrengthFlawCards.tsx` | Fixed white backgrounds breaking dark theme |

### Onboarding Enhancements
| Component | File | Details |
|-----------|------|---------|
| **OnboardingProgress** | `src/components/onboarding/OnboardingProgress.tsx` | Global progress bar with 7 steps |
| **Mobile Bottom CTAs** | All onboarding pages | Fixed bottom CTA bar on mobile with gradient backdrop |

### Form Improvements
| Component | File | Details |
|-----------|------|---------|
| **Password Visibility** | `src/app/signup/page.tsx`, `src/app/login/page.tsx` | Toggle to show/hide password |
| **Password Strength** | `src/app/signup/page.tsx` | Real-time password strength indicator |

### Loading States
| Component | File | Details |
|-----------|------|---------|
| **Skeleton Component** | `src/components/ui/Skeleton.tsx` | Reusable skeleton patterns |
| **Leaderboard Skeleton** | `src/components/results/tabs/LeaderboardTab.tsx` | Skeleton loading for leaderboard |
| **Forum Skeleton** | `src/app/forum/page.tsx` | Skeleton loading for forum categories |

### Achievement System
| Component | File | Details |
|-----------|------|---------|
| **Achievement Types** | `src/types/achievements.ts` | Types, tiers, XP calculations |
| **Achievement Data** | `src/data/achievements.ts` | 20+ achievements across 5 categories |
| **AchievementBadge** | `src/components/achievements/AchievementBadge.tsx` | Badge and card components |
| **AchievementsShowcase** | `src/components/achievements/AchievementsShowcase.tsx` | Full showcase with level/XP |

### Visual Improvements
| Change | Details |
|--------|---------|
| **Softer Cyan** | Updated accent from #00f3ff to cyan-400 (#22d3ee) |
| **Increased Spacing** | More padding in TabContent (p-5/8/10), larger gaps in grids |
| **Social Proof** | Avatar cluster + counter on hero section |

### Utilities
| Utility | File | Details |
|---------|------|---------|
| **cn()** | `src/lib/utils.ts` | Class name merging utility |

## New Features (2025-12-26) ✅

### 1. Face Morphing Visualization
Real-time face morphing that shows treatment effects on facial landmarks.

| Component | File | Details |
|-----------|------|---------|
| **FaceMorphing** | `src/components/results/visualization/FaceMorphing.tsx` | Canvas-based face warping with animation |
| **BeforeAfterPreviewSection** | `src/components/results/tabs/PlanTab.tsx` | Toggle between morphing and static preview |

**Features:**
- Treatment-based landmark displacement
- Animated morph transition (2 seconds)
- Play/pause/reset controls
- Improvement region highlighting
- Glassmorphism UI (content-cat pattern)

### 2. Quota/Rate Limiting System
Plan-based usage limits with visual progress tracking.

| Component | File | Details |
|-----------|------|---------|
| **rate-limit.ts** | `src/lib/rate-limit.ts` | In-memory rate limiting with Redis-ready interface |
| **useQuota** | `src/hooks/useQuota.ts` | React hook for quota management |
| **QuotaDisplay** | `src/components/ui/QuotaDisplay.tsx` | QuotaProgressBar, QuotaCard, QuotaSummary, QuotaGate components |

**Plan Quotas:**
| Plan | Analyses/Mo | Downloads | Forum Posts |
|------|-------------|-----------|-------------|
| Free | 3 | 1 | 5 |
| Basic | 30 | 10 | 50 |
| Pro | 100 | 50 | 200 |
| Plus | Unlimited | Unlimited | Unlimited |

### 3. Analysis History/Versioning
Track and compare analyses over time.

| Component | File | Details |
|-----------|------|---------|
| **useAnalysisHistory** | `src/hooks/useAnalysisHistory.ts` | History management hook with localStorage |
| **AnalysisHistoryCard** | `src/components/results/cards/AnalysisHistoryCard.tsx` | History list with comparison modal |

**Features:**
- Up to 50 analysis snapshots
- Before/after comparison with metric changes
- Progress summary (avg improvement, best score, streak)
- Notes per analysis
- New strengths and resolved flaws tracking

### 4. Surgery Consent Tracking
HIPAA-style consent flow for surgical procedure information.

| Component | File | Details |
|-----------|------|---------|
| **SurgeryConsentModal** | `src/components/results/modals/SurgeryConsentModal.tsx` | Two-step consent form |
| **SurgeryConsentGate** | `src/components/results/modals/SurgeryConsentModal.tsx` | Wrapper that blocks content until consent |

**Consent Requirements:**
- Risk acknowledgment
- Cost acknowledgment
- Recovery requirements
- Consultation requirement
- Informational disclaimer
- Initials + age verification (18+)

## UX Patterns from Content-Cat ✅

Adopted patterns from `/Users/imorgado/content-cat`:

| Pattern | Implementation |
|---------|----------------|
| **Glassmorphism Modals** | `bg-black/60 backdrop-blur-xl border-white/10` |
| **Skeleton Shimmer** | CSS-based skeleton-loader animation |
| **Portal Dropdowns** | Fixed positioning via createPortal |
| **Error Boundaries** | Component and page-level error handling |
| **Form Loading State** | `disabled:animate-pulse` on fieldsets |
| **Cursor Pagination** | useSWRInfinite pattern for infinite scroll |

## E2E Test Results (2025-12-26)

| Test | Status |
|------|--------|
| TypeScript | ✅ No errors |
| ESLint | ✅ Only warnings (img vs Image) |
| Build | ✅ 28 pages compiled |
| Face Morphing | ✅ Canvas rendering, animation works |
| Quota System | ✅ Plan quotas enforced, UI displays correctly |
| Analysis History | ✅ Snapshots saved, comparison works |
| Surgery Consent | ✅ Two-step flow, age verification works |
