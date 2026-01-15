# Ethnicity/Gender-Specific Scoring Implementation Plan

## User Choice: Improve Beyond FaceIQ

User has chosen to implement actual ethnicity/gender-specific ideal ranges based on anthropometric research. This goes beyond what FaceIQ currently offers (universal scoring).

---

## Implementation Overview

### Data Structure

Create a new `DEMOGRAPHIC_OVERRIDES` configuration that specifies which metrics have different ideal ranges per ethnicity/gender combination:

```typescript
type Ethnicity = 'east_asian' | 'south_asian' | 'black' | 'hispanic' |
                 'middle_eastern' | 'native_american' | 'pacific_islander' | 'white';
type Gender = 'male' | 'female';

interface DemographicOverride {
  idealMin: number;
  idealMax: number;
  decayRate?: number;  // Optional - only if decay rate varies
}

type DemographicKey = `${Ethnicity}_${Gender}`;

export const DEMOGRAPHIC_OVERRIDES: Record<string, Partial<Record<DemographicKey, DemographicOverride>>> = {
  // Example structure
  nasalIndex: {
    east_asian_male: { idealMin: 80, idealMax: 90 },
    east_asian_female: { idealMin: 78, idealMax: 88 },
    black_male: { idealMin: 85, idealMax: 100 },
    // ... etc
  },
  jawWidth: {
    male: { idealMin: 0.78, idealMax: 0.85 },  // Males have wider jaws
    female: { idealMin: 0.72, idealMax: 0.80 },
  }
};
```

### Metrics Requiring Ethnicity-Specific Ranges

Based on anthropometric research, these metrics have significant variation:

| Metric | Variation Type | Notes |
|--------|---------------|-------|
| **Nose Metrics** | Ethnicity | Nasal index varies significantly |
| `nasalIndex` | High | African: 85-100, Asian: 80-90, Caucasian: 70-80 |
| `nasalProjection` | Medium | Varies by ethnic background |
| `nasolabialAngle` | Medium | Different ideals per ethnicity |
| **Facial Proportions** | Both | |
| `faceWidthToHeight` | Gender | Males typically wider |
| `bigonialWidth` | Gender | Males have wider jaws |
| `jawFrontalAngle` | Gender | More angular in males |
| **Eye Metrics** | Ethnicity | |
| `lateralCanthalTilt` | Ethnicity | East Asian: higher tilt |
| `eyeAspectRatio` | Ethnicity | Varies by ethnic background |
| **Lip Metrics** | Ethnicity | |
| `lipThickness` | Ethnicity | Varies significantly |

---

## Files to Modify

### 1. `src/lib/faceiq-scoring.ts`
**Changes:**
- Add `DEMOGRAPHIC_OVERRIDES` constant with ethnicity/gender-specific ideal ranges
- Add `getMetricConfigForDemographics(metricId, gender, ethnicity)` function
- Modify `calculateMetricScore()` to accept and use demographics
- Update `calculateHarmonyScore()` to pass demographics through

### 2. `src/contexts/ResultsContext.tsx`
**Changes:**
- Import and use `EthnicityContext` and `GenderContext`
- Pass demographics to scoring functions
- Update analysis results when demographics change

### 3. `src/app/results/page.tsx` (or analysis components)
**Changes:**
- Ensure ethnicity/gender are passed to scoring pipeline
- Re-calculate scores when user changes demographics

---

## Implementation Steps

### Step 1: Add Demographic Override Types and Data
Add to `faceiq-scoring.ts`:
```typescript
// Types
export type Ethnicity = 'east_asian' | 'south_asian' | 'black' | 'hispanic' |
                        'middle_eastern' | 'native_american' | 'pacific_islander' | 'white';
export type Gender = 'male' | 'female';
export type DemographicKey = `${Ethnicity}_${Gender}` | Gender | Ethnicity;

// Override configuration
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

### Step 2: Add Helper Function
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

### Step 3: Update Scoring Function Signatures
```typescript
// Before
export function calculateMetricScore(value: number, metricId: string, gender: string): FaceIQScoreResult

// After
export function calculateMetricScore(
  value: number,
  metricId: string,
  gender: Gender,
  ethnicity: Ethnicity = 'white'
): FaceIQScoreResult
```

### Step 4: Integrate Demographics in Results Pipeline
Update ResultsContext to:
1. Get ethnicity from `EthnicityContext`
2. Get gender from `GenderContext` or stored analysis
3. Pass both to all scoring function calls
4. Recalculate when demographics change

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

### Jaw Width (Gender-Based)
| Gender | Ideal Range | Notes |
|--------|-------------|-------|
| Male | 90-95% of bizygomatic | Wider, more angular preferred |
| Female | 85-90% of bizygomatic | Narrower, softer preferred |

### Lateral Canthal Tilt (Eye Angle)
| Ethnicity | Ideal Range | Notes |
|-----------|-------------|-------|
| East Asian | 8-13° | Naturally higher positive tilt |
| Default | 6-8° | Standard positive canthal tilt |

---

## Testing Strategy

1. Unit test `getMetricConfigForDemographics()` with all combinations
2. Verify score changes appropriately when demographics change
3. Test fallback to default when no override exists
4. Test mixed ethnicity handling (use first ethnicity)

---

## Priority Order

1. **Nose metrics** - Highest ethnicity variation
2. **Jaw metrics** - Clear gender dimorphism
3. **Eye metrics** - Some ethnic variation
4. **Lip metrics** - Ethnic variation
5. **Facial proportions** - Minor variations
