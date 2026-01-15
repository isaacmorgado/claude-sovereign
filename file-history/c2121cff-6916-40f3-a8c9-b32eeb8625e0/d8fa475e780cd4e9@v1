# FaceIQ HAR Analysis & Ethnicity/Gender Scoring Changes

## Discovery Summary

After analyzing the FaceIQ HAR capture (396MB, 3,305 entries, 104 JSON responses), I discovered:

**FaceIQ does NOT use different ideal ranges per ethnicity/gender in their scoring algorithm.** Their scoring is universal for everyone.

### Evidence from HAR Analysis

1. **API Responses**: `/api/faces` returns `gender` and `race` fields but no ethnicity/gender-specific scoring parameters
2. **Client-Side Scoring**: The formula `score = minScore + (maxScore - minScore) * exp(-decayRate * deviation)` uses `t.idealMin` and `t.idealMax` directly - no demographic lookup
3. **No Conditional Logic**: Searched 2.2MB of FaceIQ JavaScript for patterns like `gender === "male"` near ideal values - none found
4. **Landmark-Only Variation**: Found `getFrontLandmarkList(gender, ethnicity)` and `getSideLandmarkList(gender, ethnicity)` - these only affect which landmarks to **display**, not scoring

### What FaceIQ Uses Demographics For

| Feature | Uses Demographics? |
|---------|-------------------|
| Ideal value ranges | NO - same for all |
| Scoring formula | NO - universal |
| Landmark visualization | YES - different display lists |
| Metric descriptions | YES - text mentions differences |
| UI selection | YES - collected but unused |

---

## FaceIQ Demographics

### Ethnicities (9 total)
- `east_asian`
- `south_asian`
- `black`
- `hispanic`
- `middle_eastern`
- `native_american`
- `pacific_islander`
- `white`
- `other`

### Genders (2)
- `male`
- `female`

---

## Implementation: Improve Beyond FaceIQ

User chose to implement actual ethnicity/gender-specific ideal ranges based on anthropometric research.

### Data Structure

```typescript
type Ethnicity = 'east_asian' | 'south_asian' | 'black' | 'hispanic' |
                 'middle_eastern' | 'native_american' | 'pacific_islander' | 'white';
type Gender = 'male' | 'female';
type DemographicKey = `${Ethnicity}_${Gender}` | Gender | Ethnicity;

export const DEMOGRAPHIC_OVERRIDES: Record<string, Partial<Record<DemographicKey, { idealMin: number; idealMax: number }>>> = {
  // Nose metrics - significant ethnic variation
  nasalIndex: {
    east_asian_male: { idealMin: 78, idealMax: 88 },
    east_asian_female: { idealMin: 76, idealMax: 86 },
    south_asian_male: { idealMin: 72, idealMax: 82 },
    south_asian_female: { idealMin: 70, idealMax: 80 },
    black_male: { idealMin: 85, idealMax: 100 },
    black_female: { idealMin: 83, idealMax: 98 },
    hispanic_male: { idealMin: 75, idealMax: 87 },
    hispanic_female: { idealMin: 73, idealMax: 85 },
    middle_eastern_male: { idealMin: 68, idealMax: 78 },
    middle_eastern_female: { idealMin: 66, idealMax: 76 },
    white_male: { idealMin: 65, idealMax: 75 },
    white_female: { idealMin: 63, idealMax: 73 },
    native_american_male: { idealMin: 72, idealMax: 82 },
    pacific_islander_male: { idealMin: 82, idealMax: 95 },
  },

  // Jaw metrics - gender variation
  bigonialWidth: {
    male: { idealMin: 90, idealMax: 95 },
    female: { idealMin: 85, idealMax: 90 },
  },

  // Eye tilt - ethnic variation
  lateralCanthalTilt: {
    east_asian_male: { idealMin: 8, idealMax: 12 },
    east_asian_female: { idealMin: 9, idealMax: 13 },
    // Other ethnicities use default (6.1-7.8)
  },
};
```

### Helper Function

```typescript
export function getMetricConfigForDemographics(
  metricId: string,
  gender: Gender,
  ethnicity: Ethnicity
): MetricConfig {
  const baseConfig = FACEIQ_METRICS[metricId];
  if (!baseConfig) return baseConfig;

  const overrides = DEMOGRAPHIC_OVERRIDES[metricId];
  if (!overrides) return baseConfig;

  // Try specific combo first, then gender-only, then ethnicity-only
  const demographicKey = `${ethnicity}_${gender}` as DemographicKey;
  const override = overrides[demographicKey] || overrides[gender] || overrides[ethnicity];

  if (!override) return baseConfig;

  return {
    ...baseConfig,
    idealMin: override.idealMin,
    idealMax: override.idealMax,
  };
}
```

---

## Metrics Requiring Demographic Overrides

| Metric | Variation Type | Notes |
|--------|---------------|-------|
| **Nose Metrics** | | |
| `nasalIndex` | Ethnicity (High) | African: 85-100, Asian: 80-90, Caucasian: 70-80 |
| `nasalProjection` | Ethnicity (Medium) | Varies by ethnic background |
| `nasolabialAngle` | Ethnicity (Medium) | Different ideals per ethnicity |
| **Facial Proportions** | | |
| `faceWidthToHeight` | Gender | Males typically wider |
| `bigonialWidth` | Gender | Males have wider jaws |
| `jawFrontalAngle` | Gender | More angular in males |
| **Eye Metrics** | | |
| `lateralCanthalTilt` | Ethnicity | East Asian: higher tilt |
| `eyeAspectRatio` | Ethnicity | Varies by ethnic background |
| **Lip Metrics** | | |
| `lipThickness` | Ethnicity | Varies significantly |

---

## Research-Based Ideal Ranges

### Nasal Index (Nose Width/Height × 100)

| Ethnicity | Male Range | Female Range | Source |
|-----------|------------|--------------|--------|
| East Asian | 78-88 | 76-86 | Anthropometric studies |
| South Asian | 72-82 | 70-80 | Indian cephalometric data |
| Black/African | 85-100 | 83-98 | Sub-Saharan anthropometry |
| Hispanic | 75-87 | 73-85 | Latin American studies |
| Middle Eastern | 68-78 | 66-76 | Middle Eastern cephalometry |
| White/Caucasian | 65-75 | 63-73 | European facial norms |
| Native American | 72-82 | 70-80 | North American indigenous studies |
| Pacific Islander | 82-95 | 80-93 | Oceanian anthropometry |

### Jaw Width (Bigonial Width as % of Bizygomatic)

| Gender | Ideal Range | Notes |
|--------|-------------|-------|
| Male | 90-95% | Wider, more angular preferred |
| Female | 85-90% | Narrower, softer preferred |

### Lateral Canthal Tilt (Eye Angle)

| Ethnicity | Ideal Range | Notes |
|-----------|-------------|-------|
| East Asian | 8-13° | Naturally higher positive tilt |
| Default | 6-8° | Standard positive canthal tilt |

### Face Width to Height Ratio

| Gender | Ideal Range | Notes |
|--------|-------------|-------|
| Male | 1.98-2.02 | Slightly wider preference |
| Female | 1.94-1.98 | Slightly narrower preference |

---

## Files to Modify

### 1. `src/lib/faceiq-scoring.ts`
- Add `DEMOGRAPHIC_OVERRIDES` constant
- Add `getMetricConfigForDemographics()` function
- Update `calculateMetricScore()` signature to include ethnicity
- Update `calculateHarmonyScore()` to pass demographics through

### 2. `src/contexts/ResultsContext.tsx`
- Import and use `EthnicityContext` and `GenderContext`
- Pass demographics to scoring functions
- Recalculate when demographics change

### 3. `src/app/results/page.tsx`
- Ensure ethnicity/gender are passed to scoring pipeline
- Handle demographic changes

---

## Implementation Priority

1. **Nose metrics** - Highest ethnicity variation, most impactful
2. **Jaw metrics** - Clear gender dimorphism
3. **Eye metrics** - Some ethnic variation
4. **Lip metrics** - Ethnic variation
5. **Facial proportions** - Minor variations

---

## HAR Analysis Files Generated

- `/Users/imorgado/Desktop/FACEIQHAR/RACE_GENDER_ANALYSIS/00_RACE_GENDER_SUMMARY.txt`
- `/Users/imorgado/Desktop/FACEIQHAR/RACE_GENDER_ANALYSIS/01_API_CALLS.txt`
- `/Users/imorgado/Desktop/FACEIQHAR/RACE_GENDER_ANALYSIS/02_JSON_RESPONSES.json` (2.1MB)
- `/Users/imorgado/Desktop/FACEIQHAR/RACE_GENDER_ANALYSIS/03_DOMAINS.txt`
- `/Users/imorgado/Desktop/FACEIQPAID/FACEIQ-RACE&GENDER-CLEAN.har` (3.1MB - 99.2% reduction)
- `/Users/imorgado/Desktop/FACEIQHAR/main_scoring.js` (473KB - extracted FaceIQ scoring JS)

---

## Current Implementation Status

| Component | Current Status |
|-----------|----------------|
| Gender context | `GenderContext.tsx` exists - UI only |
| Ethnicity context | `EthnicityContext.tsx` exists - 9 options |
| Scoring function | Has `gender` param but ignores it: `void gender;` |
| Ethnicity in scoring | Not passed at all |
