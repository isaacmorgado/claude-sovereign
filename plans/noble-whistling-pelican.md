# Fix: Score Showing as 15/10 in Eye Section

## Root Cause

The bug is a mismatch between the documented score range (0-10) and the actual score values being passed.

### Data Flow:

1. **Metric config** (`faceiq-scoring.ts:854`): `eyeAspectRatio` has `maxScore: 15`
2. **`scoreMeasurement()`** (`faceiq-scoring.ts:3465-3480`):
   ```typescript
   const score = calculateFaceIQScore(value, config);  // Returns 0-15 for eyeAspectRatio
   const standardizedScore = standardizeScore(score, config.maxScore);  // Correctly returns 0-10
   return {
     score,  // BUG: Raw score (0-15), not standardized!
     standardizedScore,  // This is correct (0-10)
   };
   ```
3. **`convertToRatio()`** (`ResultsContext.tsx:128`): Uses `result.score` (the raw 0-15 value)
4. **`MeasurementCard.tsx:70`**: Displays `ratio.score.toFixed(1)` showing "15.0"

### The Problem:
- Interface comments say `score` is 0-10, but it actually contains 0-maxScore (raw)
- UI components display `score` instead of `standardizedScore`
- Only `eyeAspectRatio`, `cheekboneHeight`, `bigonialWidth`, `midfaceRatio`, and `totalFacialWidthToHeight` have maxScore > 10, so only these metrics show incorrect values

## Fix Strategy

Use `standardizedScore` instead of `score` in UI display. This is the minimal, targeted fix.

## Files to Modify

### 1. `src/contexts/ResultsContext.tsx:128`
Change the Ratio creation to use standardized score for display:
```typescript
// Before
score: result.score,

// After
score: result.standardizedScore,
```

This single change propagates to all UI components since they all use `ratio.score`.

## Alternative Considered (Not Recommended)

Could fix at the source in `faceiq-scoring.ts:3480` to make `score` actually be 0-10 - but this could break other code that depends on the raw score for calculations. The minimal fix is safer.

## Verification

After the fix:
- All metric scores should display between 0-10
- `eyeAspectRatio` with maxScore=15 and raw score 15 should display as 10.0/10
- Color coding (using `getScoreColor()`) will work correctly since it expects 0-10

## Testing

1. Run `npm run lint && npx tsc --noEmit` to verify no type errors
2. Start the app and check eye metrics display correct 0-10 scores
3. Verify `eyeAspectRatio` no longer shows 15/10

## Affected Metrics (maxScore > 10)

| Metric | maxScore | Line |
|--------|----------|------|
| eyeAspectRatio | 15 | 854 |
| cheekboneHeight | 15 | (check) |
| bigonialWidth | 15 | (check) |
| midfaceRatio | 12.5 | (check) |
| totalFacialWidthToHeight | 25 | (check) |
