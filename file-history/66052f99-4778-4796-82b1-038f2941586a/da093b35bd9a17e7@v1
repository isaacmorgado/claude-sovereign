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
| **Decay Rates** | 80+ | `src/lib/data/metric-configs.ts` | 0.08-0.30 range (3-210x improvement from original 0.5-31.6) |
| **Ethnicity Overrides** | 16 | `src/lib/data/demographic-overrides.ts` | 8 male + 8 female with 130+ override entries |
| **Severity Tiers** | 5 | `src/lib/insights-engine.ts` | Z-score based: Ideal/Good/Fair/Moderate/Severe |
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
Original values were 3-210x too harsh. Fixed mappings:
- `faceWidthToHeight`: 0.12 (was 6.4 - 53x reduction)
- `midfaceRatio`: 0.15 (was 31.6 - 210x reduction)
- `totalFacialWidthToHeight`: 0.15 (was 13.2 - 88x reduction)
- `nasalIndex`: 0.25
- `gonialAngle`: 0.20

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

## Remaining Tasks

### High Priority
1. Investigate auth endpoints 500 errors
2. Test full payment flow with referral discount

### Future
3. Implement supplement/product e-commerce layer
4. Add forum link to main navigation
