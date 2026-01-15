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
| **GuidesTab** | `src/components/results/tabs/GuidesTab.tsx` | Full guide browsing UI |
| **GuideStatsCard** | `src/components/results/tabs/GuidesTab.tsx` | Shows 9 guides, 95 min reading time |
| **GuideCard** | `src/components/results/tabs/GuidesTab.tsx` | Individual guide display with hover effects |
| **CategorySection** | `src/components/results/tabs/GuidesTab.tsx` | Color-coded category grouping |
| **SearchBar** | `src/components/results/tabs/GuidesTab.tsx` | Real-time guide search |
| **Tab Integration** | `src/components/results/Results.tsx` | Wired into results page navigation |

**Features:**
- 3 color-coded categories (cyan/purple/amber)
- Search by title, description, subtitle, tags
- Guide cards with: icon, title, subtitle, description, sections, products, read time
- Responsive grid (1 col mobile, 2 cols desktop)
- Smooth hover animations

## Remaining Tasks

### High Priority
1. Test full payment flow with referral discount

### In Progress
2. Product Guides Implementation (Phase 5-7 remaining)
   - Phase 5: Guide detail pages with product integration
   - Phase 6-7: Polish, QA, and Launch

### Completed
3. Forum link to main navigation ✅
4. Product Guides Phase 0-4 ✅ (Types, Products, Content, UI)
5. Auth endpoints verified working ✅ (23/23 API tests pass)
6. Score clamping bug fixed ✅ (scores now always 0-10)
