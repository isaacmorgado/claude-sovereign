# LOOKSMAXX Frontend

Next.js 14 facial metrics analysis app with FaceIQ-compatible scoring.

## Live URL
https://looksmaxx-app.vercel.app

## Code Quality

```bash
npm run lint && npx tsc --noEmit
```

## FaceIQ Parity Status ✅ (Phase 1-5 Complete)

| Feature | File | Details |
|---------|------|---------|
| **All 66 Bezier Curves** | `src/lib/faceiq-bezier-curves.ts` | Complete cubic Bezier interpolation |
| **Decay Rates Fixed** | `src/lib/faceiq-scoring.ts` | 0.08-0.30 range (was 0.5-31.6) |
| **30 Procedure Impact Tables** | `src/lib/advice-engine.ts` | Quantitative % changes per metric |
| **Treatment Metadata** | `src/lib/advice-engine.ts` | priority_score, effectiveness, ratios_impacted, pillars |
| **Potential Score Prediction** | `src/lib/recommendations/severity.ts:627-652` | `estimatePotentialPSL()` with diminishing returns |
| **Multi-Procedure Plans** | `src/lib/recommendations/engine.ts` | `generateRecommendationPlan()` with 3-phase ordering |
| **Order of Operations** | `src/lib/recommendations/engine.ts` | `generateOrderOfOperations()` with prerequisites |
| **16 Ethnicity Overrides** | `src/lib/insights-engine.ts` | 8 male + 8 female with full scoring params |
| **5-Tier Severity** | `src/lib/insights-engine.ts` | Z-score based (Ideal/Good/Fair/Moderate/Severe) |
| **Enhanced UI** | `src/components/results/` | PlanTab with 3-phase ordering, EnhancedRecommendationCard |
| **Side Profile Depth Validation** | `src/lib/mediapipeDetection.ts` | `validateSideProfileDepth()` checks 3D depth variance |
| **Before/After Preview** | `src/components/results/visualization/BeforeAfterPreview.tsx` | Visual overlay showing potential improvements |
| **Treatment Timeline** | `src/components/results/visualization/TreatmentTimeline.tsx` | Phase-based treatment sequencing UI |

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

## Remaining

### High Priority
1. Debug blank results page issue
2. Create influencer referral codes via `/referrals/create` endpoint

### Future
3. Implement supplement/product e-commerce layer (see `supplement_implementation.md`)
