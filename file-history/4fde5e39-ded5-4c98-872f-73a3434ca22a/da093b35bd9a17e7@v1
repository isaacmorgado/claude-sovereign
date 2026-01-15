# LOOKSMAXX Frontend

Next.js 14 facial metrics analysis app with FaceIQ-compatible scoring.

## Live URL
https://looksmaxx-app.vercel.app

## Code Quality

```bash
npm run lint && npx tsc --noEmit
```

## FaceIQ Parity Status ✅

| Feature | File | Details |
|---------|------|---------|
| **All 66 Bezier Curves** | `src/lib/faceiq-bezier-curves.ts` | Complete cubic Bezier interpolation |
| **30 Procedure Impact Tables** | `src/lib/advice-engine.ts` | Quantitative % changes per metric |
| **Potential Score Prediction** | `src/lib/recommendations/severity.ts:627-652` | `estimatePotentialPSL()` with diminishing returns |
| **Multi-Procedure Plans** | `src/lib/recommendations/engine.ts:295-372` | `generateRecommendationPlan()` with 5-phase ordering |
| **Order of Operations** | `src/lib/recommendations/engine.ts:517-607` | `generateOrderOfOperations()` with prerequisites |
| **16 Ethnicity Overrides** | `src/lib/insights-engine.ts` | 8 male + 8 female with full scoring params |

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
- `/signup` - Registration with username + T&C
- `/login` - Login page
- `/terms` - Terms & Conditions
- `/gender` - Gender selection
- `/ethnicity` - Ethnicity selection
- `/upload` - Photo upload
- `/analysis` - Face analysis
- `/results` - Results with leaderboard

## Remaining

1. Implement supplement/product e-commerce layer (see `supplement_implementation.md`)
2. Debug blank results page issue
