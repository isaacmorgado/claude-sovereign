/**
 * FaceIQ-Style Facial Analysis Scoring System
 * Complete replication of FaceIQ Labs scoring algorithms
 *
 * Features:
 * - Exponential decay scoring with per-metric decay rates
 * - Bezier curve custom scoring for non-linear measurements
 * - 70+ facial measurements (front + side profiles)
 * - Quality tiers: Ideal, Excellent, Good
 * - 5-tier severity: Extremely Severe, Severe, Major, Moderate, Minor
 */

import { LandmarkPoint } from './landmarks';

// ============================================
// CORE TYPES
// ============================================

export interface Point {
  x: number;
  y: number;
}

export type QualityTier = 'ideal' | 'excellent' | 'good' | 'below_average';
export type SeverityLevel = 'extremely_severe' | 'severe' | 'major' | 'moderate' | 'minor' | 'optimal';
export type MeasurementUnit = 'ratio' | 'percent' | 'degrees' | 'mm' | 'none';

export interface MetricConfig {
  id: string;
  name: string;
  category: string;
  unit: MeasurementUnit;
  idealMin: number;
  idealMax: number;
  rangeMin: number;
  rangeMax: number;
  decayRate: number;
  maxScore: number;
  weight: number;
  description: string;
  profileType: 'front' | 'side';
  customCurve?: BezierCurveConfig;
}

export interface BezierCurveConfig {
  mode: 'custom' | 'exponential';
  points: CurvePoint[];
}

export interface CurvePoint {
  x: number;
  y: number;
  leftHandleX?: number;
  leftHandleY?: number;
  rightHandleX?: number;
  rightHandleY?: number;
  fixed?: boolean;
}

export interface FaceIQScoreResult {
  metricId: string;
  name: string;
  value: number;
  score: number;  // 0-10 scale
  standardizedScore: number;
  qualityTier: QualityTier;
  severity: SeverityLevel;
  idealMin: number;
  idealMax: number;
  deviation: number;
  deviationDirection: 'above' | 'below' | 'within';
  unit: MeasurementUnit;
  category: string;
  percentile?: number;
}

export interface HarmonyAnalysis {
  overallScore: number;  // 0-10 scale
  standardizedScore: number;
  qualityTier: QualityTier;
  percentile: number;
  frontScore: number;
  sideScore: number;
  categoryScores: Record<string, number>;
  measurements: FaceIQScoreResult[];
  flaws: FlawAssessment[];
  strengths: StrengthAssessment[];
}

export interface FlawAssessment {
  category: string;
  metricId: string;
  metricName: string;
  severity: SeverityLevel;
  deviation: string;
  reasoning: string;
  confidence: 'confirmed' | 'likely' | 'possible';
}

export interface StrengthAssessment {
  category: string;
  metricId: string;
  metricName: string;
  qualityTier: QualityTier;
  value: number;
  reasoning: string;
}

// ============================================
// DEMOGRAPHIC TYPES & OVERRIDES
// ============================================

export type Ethnicity =
  | 'east_asian'
  | 'south_asian'
  | 'black'
  | 'hispanic'
  | 'middle_eastern'
  | 'native_american'
  | 'pacific_islander'
  | 'white'
  | 'other';

export type Gender = 'male' | 'female';

export type DemographicKey = `${Ethnicity}_${Gender}` | Gender | Ethnicity;

export interface DemographicOverride {
  idealMin: number;
  idealMax: number;
}

/**
 * Demographic-specific ideal ranges based on anthropometric research.
 * FaceIQ uses universal scoring, but this gives more accurate assessments
 * by adjusting ideals based on ethnicity and gender.
 */
export const DEMOGRAPHIC_OVERRIDES: Record<string, Partial<Record<DemographicKey, DemographicOverride>>> = {
  // ==========================================
  // NOSE METRICS - Highest ethnicity variation
  // ==========================================
  nasalIndex: {
    // Nasal Index = (Nose Width / Nose Height) × 100
    // Research: African/Pacific Islander tend platyrrhine (85-100), Asian mesorrhine (75-88), European leptorrhine (65-75)
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
    native_american_female: { idealMin: 70, idealMax: 80 },
    pacific_islander_male: { idealMin: 82, idealMax: 95 },
    pacific_islander_female: { idealMin: 80, idealMax: 93 },
  },

  nasolabialAngle: {
    // Ideal nasolabial angle varies by ethnicity
    // African: slightly more obtuse, European: slightly more acute
    black_male: { idealMin: 95, idealMax: 110 },
    black_female: { idealMin: 100, idealMax: 115 },
    east_asian_male: { idealMin: 90, idealMax: 105 },
    east_asian_female: { idealMin: 95, idealMax: 110 },
    // Gender-only fallbacks
    male: { idealMin: 90, idealMax: 100 },
    female: { idealMin: 100, idealMax: 110 },
  },

  nasalProjection: {
    // Nose projection relative to face depth
    // East Asian/African: typically less projection is ideal
    east_asian: { idealMin: 0.54, idealMax: 0.60 },
    black: { idealMin: 0.52, idealMax: 0.58 },
    south_asian: { idealMin: 0.56, idealMax: 0.62 },
    middle_eastern: { idealMin: 0.62, idealMax: 0.68 },
    white: { idealMin: 0.60, idealMax: 0.67 },
    pacific_islander: { idealMin: 0.52, idealMax: 0.58 },
  },

  // ==========================================
  // JAW METRICS - Clear gender dimorphism
  // ==========================================
  bigonialWidth: {
    // Jaw width as % of bizygomatic width
    // Males: wider, more angular; Females: narrower, softer
    male: { idealMin: 90, idealMax: 95 },
    female: { idealMin: 85, idealMax: 90 },
  },

  jawFrontalAngle: {
    // More angular in males, softer in females
    male: { idealMin: 88, idealMax: 95 },
    female: { idealMin: 82, idealMax: 90 },
  },

  jawWidthRatio: {
    // Males have stronger jaw width preference
    male: { idealMin: 0.78, idealMax: 0.85 },
    female: { idealMin: 0.72, idealMax: 0.80 },
  },

  gonialAngle: {
    // Males: more acute (sharper jaw); Females: more obtuse (softer)
    male: { idealMin: 115, idealMax: 125 },
    female: { idealMin: 120, idealMax: 135 },
  },

  // ==========================================
  // EYE METRICS - Ethnic variation
  // ==========================================
  lateralCanthalTilt: {
    // East Asian: naturally higher positive tilt
    east_asian_male: { idealMin: 8, idealMax: 12 },
    east_asian_female: { idealMin: 9, idealMax: 13 },
    south_asian_male: { idealMin: 6, idealMax: 10 },
    south_asian_female: { idealMin: 7, idealMax: 11 },
    // Default for others is 6-8 (already in FACEIQ_METRICS)
  },

  eyeAspectRatio: {
    // East Asian eyes often have different aspect ratio due to epicanthal fold
    east_asian_male: { idealMin: 2.6, idealMax: 3.2 },
    east_asian_female: { idealMin: 2.7, idealMax: 3.3 },
    // Larger eyes in females considered more attractive
    male: { idealMin: 2.9, idealMax: 3.4 },
    female: { idealMin: 3.1, idealMax: 3.6 },
  },

  // ==========================================
  // FACE PROPORTIONS - Gender variation
  // ==========================================
  faceWidthToHeight: {
    // Males: slightly wider face preferred; Females: slightly narrower
    male: { idealMin: 1.98, idealMax: 2.02 },
    female: { idealMin: 1.94, idealMax: 1.98 },
  },

  totalFacialWidthToHeight: {
    male: { idealMin: 1.35, idealMax: 1.40 },
    female: { idealMin: 1.32, idealMax: 1.37 },
  },

  midfaceRatio: {
    // Females often have more compact midface
    male: { idealMin: 0.98, idealMax: 1.02 },
    female: { idealMin: 0.95, idealMax: 1.00 },
  },

  // ==========================================
  // LIP METRICS - Ethnicity variation
  // ==========================================
  lipRatio: {
    // African/Hispanic: fuller lips natural
    black_male: { idealMin: 1.6, idealMax: 2.2 },
    black_female: { idealMin: 1.7, idealMax: 2.3 },
    hispanic_male: { idealMin: 1.4, idealMax: 2.0 },
    hispanic_female: { idealMin: 1.5, idealMax: 2.1 },
    // East Asian: less full lips
    east_asian_male: { idealMin: 1.2, idealMax: 1.7 },
    east_asian_female: { idealMin: 1.3, idealMax: 1.8 },
    // Default
    male: { idealMin: 1.3, idealMax: 1.8 },
    female: { idealMin: 1.4, idealMax: 2.0 },
  },

  upperLipRatio: {
    // Fuller upper lip in African phenotypes
    black: { idealMin: 0.38, idealMax: 0.48 },
    hispanic: { idealMin: 0.36, idealMax: 0.45 },
    east_asian: { idealMin: 0.32, idealMax: 0.40 },
    female: { idealMin: 0.34, idealMax: 0.42 },
  },

  // ==========================================
  // PROFILE METRICS - Gender & ethnicity
  // ==========================================
  chinProjection: {
    // Males: more projected chin ideal
    male: { idealMin: 0, idealMax: 3 },
    female: { idealMin: -2, idealMax: 2 },
  },

  nasofrontalAngle: {
    // Higher brow ridge in males
    male: { idealMin: 128, idealMax: 138 },
    female: { idealMin: 132, idealMax: 142 },
  },
};

/**
 * Get metric configuration with demographic-specific overrides applied.
 * Lookup priority: ethnicity_gender > gender > ethnicity > default
 */
export function getMetricConfigForDemographics(
  metricId: string,
  gender: Gender,
  ethnicity: Ethnicity = 'other'
): MetricConfig | null {
  const baseConfig = FACEIQ_METRICS[metricId];
  if (!baseConfig) return null;

  const overrides = DEMOGRAPHIC_OVERRIDES[metricId];
  if (!overrides) return baseConfig;

  // Try specific combo first (e.g., "east_asian_male")
  const specificKey = `${ethnicity}_${gender}` as DemographicKey;
  const override = overrides[specificKey] || overrides[gender] || overrides[ethnicity];

  if (!override) return baseConfig;

  return {
    ...baseConfig,
    idealMin: override.idealMin,
    idealMax: override.idealMax,
  };
}

// ============================================
// FACEIQ MEASUREMENT CONFIGURATIONS (70+)
// ============================================

export const FACEIQ_METRICS: Record<string, MetricConfig> = {
  // ==========================================
  // FRONT PROFILE - FACIAL PROPORTIONS (32)
  // ==========================================

  faceWidthToHeight: {
    id: 'faceWidthToHeight',
    name: 'Face Width to Height Ratio',
    category: 'Midface/Face Shape',
    unit: 'ratio',
    idealMin: 1.96,
    idealMax: 2.0,
    rangeMin: 1.4,
    rangeMax: 2.5,
    decayRate: 6.4,
    maxScore: 30,  // FaceIQ: highest priority metric
    weight: 0.06,
    description: 'Ratio of bizygomatic width to upper face height',
    profileType: 'front',
  },

  lowerThirdProportion: {
    id: 'lowerThirdProportion',
    name: 'Lower Third Proportion',
    category: 'Midface/Face Shape',
    unit: 'percent',
    idealMin: 31,
    idealMax: 33.5,
    rangeMin: 24,
    rangeMax: 40,
    decayRate: 1.86,
    maxScore: 10,
    weight: 0.03,
    description: 'Percentage of face occupied by lower third (subnasale to menton)',
    profileType: 'front',
  },

  middleThirdProportion: {
    id: 'middleThirdProportion',
    name: 'Middle Third Proportion',
    category: 'Midface/Face Shape',
    unit: 'percent',
    idealMin: 31.4,
    idealMax: 33.4,
    rangeMin: 24,
    rangeMax: 42,
    decayRate: 1.5,
    maxScore: 10,
    weight: 0.03,
    description: 'Percentage of face occupied by middle third',
    profileType: 'front',
  },

  upperThirdProportion: {
    id: 'upperThirdProportion',
    name: 'Upper Third Proportion',
    category: 'Midface/Face Shape',
    unit: 'percent',
    idealMin: 30,
    idealMax: 32,
    rangeMin: 24,
    rangeMax: 42,
    decayRate: 1.2,
    maxScore: 10,
    weight: 0.02,
    description: 'Percentage of face occupied by upper third (trichion to glabella)',
    profileType: 'front',
  },

  bitemporalWidth: {
    id: 'bitemporalWidth',
    name: 'Bitemporal Width',
    category: 'Midface/Face Shape',
    unit: 'percent',
    idealMin: 86.5,
    idealMax: 92.5,
    rangeMin: 75,
    rangeMax: 100,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.02,
    description: 'Temple width as percentage of bizygomatic width',
    profileType: 'front',
  },

  cheekboneHeight: {
    id: 'cheekboneHeight',
    name: 'Cheekbone Height',
    category: 'Midface/Face Shape',
    unit: 'percent',
    idealMin: 83,
    idealMax: 100,
    rangeMin: 30,
    rangeMax: 140,
    decayRate: 0.5,
    maxScore: 15,  // FaceIQ: higher priority
    weight: 0.03,
    description: 'Vertical position of cheekbones relative to face height',
    profileType: 'front',
  },

  totalFacialWidthToHeight: {
    id: 'totalFacialWidthToHeight',
    name: 'Total Facial Width to Height Ratio',
    category: 'Midface/Face Shape',
    unit: 'ratio',
    idealMin: 1.34,
    idealMax: 1.37,
    rangeMin: 1.0,
    rangeMax: 1.7,
    decayRate: 13.2,
    maxScore: 25,  // Special: higher max score
    weight: 0.05,
    description: 'Total face height divided by cheek width',
    profileType: 'front',
    customCurve: {
      mode: 'custom',
      points: [
        { x: 1.05, y: 0 },
        { x: 1.17, y: 1.41 },
        { x: 1.25, y: 3.86 },
        { x: 1.29, y: 6.01 },
        { x: 1.32, y: 8.88 },
        { x: 1.34, y: 10, fixed: true },
        { x: 1.37, y: 10, fixed: true },
        { x: 1.39, y: 8.88 },
        { x: 1.42, y: 6.01 },
        { x: 1.46, y: 3.86 },
        { x: 1.54, y: 1.41 },
        { x: 1.66, y: 0 },
      ],
    },
  },

  midfaceRatio: {
    id: 'midfaceRatio',
    name: 'Midface Ratio',
    category: 'Midface/Face Shape',
    unit: 'ratio',
    idealMin: 0.97,
    idealMax: 1.0,
    rangeMin: 0.5,
    rangeMax: 1.5,
    decayRate: 31.6,
    maxScore: 12.5,  // FaceIQ: medium-high priority
    weight: 0.04,
    description: 'Midface width to height ratio for facial balance',
    profileType: 'front',
  },

  // JAW MEASUREMENTS
  jawSlope: {
    id: 'jawSlope',
    name: 'Jaw Slope',
    category: 'Jaw Shape',
    unit: 'degrees',
    idealMin: 140,
    idealMax: 142.5,
    rangeMin: 120,
    rangeMax: 160,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.03,
    description: 'Angle of the jawline from gonion to chin',
    profileType: 'front',
  },

  jawFrontalAngle: {
    id: 'jawFrontalAngle',
    name: 'Jaw Frontal Angle',
    category: 'Jaw Shape',
    unit: 'degrees',
    idealMin: 86.5,
    idealMax: 92.5,
    rangeMin: 35,
    rangeMax: 140,
    decayRate: 0.6,
    maxScore: 20,  // FaceIQ: high priority
    weight: 0.04,
    description: 'Angle of jaw corners from frontal view',
    profileType: 'front',
  },

  bigonialWidth: {
    id: 'bigonialWidth',
    name: 'Bigonial Width',
    category: 'Jaw Shape',
    unit: 'percent',
    idealMin: 87.75,
    idealMax: 91.75,
    rangeMin: 60.25,
    rangeMax: 120.25,
    decayRate: 0.9,
    maxScore: 15,  // FaceIQ: higher priority
    weight: 0.03,
    description: 'Jaw width as percentage of bizygomatic width',
    profileType: 'front',
  },

  jawWidthRatio: {
    id: 'jawWidthRatio',
    name: 'Jaw Width to Face Width Ratio',
    category: 'Jaw Shape',
    unit: 'ratio',
    idealMin: 0.75,
    idealMax: 0.82,
    rangeMin: 0.6,
    rangeMax: 0.95,
    decayRate: 25.0,
    maxScore: 10,
    weight: 0.03,
    description: 'Bigonial width divided by bizygomatic width',
    profileType: 'front',
  },

  // EYE MEASUREMENTS
  lateralCanthalTilt: {
    id: 'lateralCanthalTilt',
    name: 'Lateral Canthal Tilt',
    category: 'Eyes',
    unit: 'degrees',
    idealMin: 6.1,
    idealMax: 7.8,
    rangeMin: -5,
    rangeMax: 20,
    decayRate: 2.5,
    maxScore: 10,
    weight: 0.04,
    description: 'Angle of eye from inner to outer canthus',
    profileType: 'front',
  },

  eyeAspectRatio: {
    id: 'eyeAspectRatio',
    name: 'Eye Aspect Ratio',
    category: 'Eyes',
    unit: 'ratio',
    idealMin: 3.0,
    idealMax: 3.5,
    rangeMin: 0.8,
    rangeMax: 6,
    decayRate: 2.0,
    maxScore: 15,  // FaceIQ: higher priority
    weight: 0.03,
    description: 'Eye width divided by eye height',
    profileType: 'front',
  },

  eyeSeparationRatio: {
    id: 'eyeSeparationRatio',
    name: 'Eye Separation Ratio',
    category: 'Eyes',
    unit: 'percent',
    idealMin: 45.7,
    idealMax: 46.8,
    rangeMin: 35,
    rangeMax: 55,
    decayRate: 2.5,
    maxScore: 10,
    weight: 0.03,
    description: 'Intercanthal distance as percentage of bizygomatic width',
    profileType: 'front',
  },

  interpupillaryRatio: {
    id: 'interpupillaryRatio',
    name: 'Interpupillary Distance Ratio',
    category: 'Eyes',
    unit: 'percent',
    idealMin: 44,
    idealMax: 48,
    rangeMin: 38,
    rangeMax: 54,
    decayRate: 1.8,
    maxScore: 10,
    weight: 0.02,
    description: 'IPD as percentage of bizygomatic width',
    profileType: 'front',
  },

  interpupillaryMouthWidthRatio: {
    id: 'interpupillaryMouthWidthRatio',
    name: 'Interpupillary-Mouth Width Ratio',
    category: 'Eyes',
    unit: 'ratio',
    idealMin: 0.83,
    idealMax: 0.87,
    rangeMin: 0.6,
    rangeMax: 1.1,
    decayRate: 12.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Mouth width divided by interpupillary distance',
    profileType: 'front',
  },

  oneEyeApartTest: {
    id: 'oneEyeApartTest',
    name: 'One Eye Apart Test',
    category: 'Eyes',
    unit: 'ratio',
    idealMin: 0.95,
    idealMax: 1.0,
    rangeMin: 0.7,
    rangeMax: 1.3,
    decayRate: 20.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Intercanthal distance should equal one eye width',
    profileType: 'front',
  },

  // EYEBROW MEASUREMENTS
  browLengthRatio: {
    id: 'browLengthRatio',
    name: 'Brow Length to Face Width Ratio',
    category: 'Upper Third',
    unit: 'percent',
    idealMin: 28,
    idealMax: 32,
    rangeMin: 20,
    rangeMax: 40,
    decayRate: 1.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Eyebrow length as percentage of face width',
    profileType: 'front',
  },

  eyebrowTilt: {
    id: 'eyebrowTilt',
    name: 'Eyebrow Tilt',
    category: 'Upper Third',
    unit: 'degrees',
    idealMin: 6.5,
    idealMax: 11,
    rangeMin: -5,
    rangeMax: 25,
    decayRate: 1.2,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle of eyebrow from head to tail',
    profileType: 'front',
  },

  eyebrowLowSetedness: {
    id: 'eyebrowLowSetedness',
    name: 'Eyebrow Low Setedness',
    category: 'Upper Third',
    unit: 'ratio',
    idealMin: 0,
    idealMax: 0.45,
    rangeMin: -0.2,
    rangeMax: 1.0,
    decayRate: 8.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Distance from brow to eye relative to eye height',
    profileType: 'front',
  },

  // NOSE MEASUREMENTS (FRONT)
  nasalIndex: {
    id: 'nasalIndex',
    name: 'Nasal Index',
    category: 'Nose',
    unit: 'percent',
    idealMin: 70,
    idealMax: 85,
    rangeMin: 55,
    rangeMax: 100,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Nose width divided by nose height × 100',
    profileType: 'front',
  },

  intercanthalNasalRatio: {
    id: 'intercanthalNasalRatio',
    name: 'Intercanthal-Nasal Width Ratio',
    category: 'Nose',
    unit: 'ratio',
    idealMin: 1.04,
    idealMax: 1.16,
    rangeMin: 0.7,
    rangeMax: 1.5,
    decayRate: 12.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Alar width should roughly equal intercanthal distance',
    profileType: 'front',
  },

  noseBridgeWidth: {
    id: 'noseBridgeWidth',
    name: 'Nose Bridge to Nose Width',
    category: 'Nose',
    unit: 'ratio',
    idealMin: 0.6,
    idealMax: 0.75,
    rangeMin: 0.4,
    rangeMax: 0.9,
    decayRate: 15.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Ratio of nose bridge width to alar base width',
    profileType: 'front',
  },

  noseTipPosition: {
    id: 'noseTipPosition',
    name: 'Nose Tip Position',
    category: 'Nose',
    unit: 'mm',
    idealMin: 0.5,
    idealMax: 3.5,
    rangeMin: -7.5,
    rangeMax: 12.5,
    decayRate: 1.5,
    maxScore: 2.5,  // FaceIQ: low priority
    weight: 0.01,
    description: 'Nose tip deviation from facial midline',
    profileType: 'front',
  },

  // MOUTH/LIP MEASUREMENTS
  mouthWidthToNoseRatio: {
    id: 'mouthWidthToNoseRatio',
    name: 'Mouth Width to Nose Width Ratio',
    category: 'Lips',
    unit: 'ratio',
    idealMin: 1.43,
    idealMax: 1.51,
    rangeMin: 0.96,
    rangeMax: 1.91,
    decayRate: 18.0,
    maxScore: 10,
    weight: 0.03,
    description: 'Mouth width divided by nose width',
    profileType: 'front',
  },

  lowerToUpperLipRatio: {
    id: 'lowerToUpperLipRatio',
    name: 'Lower Lip to Upper Lip Ratio',
    category: 'Lips',
    unit: 'ratio',
    idealMin: 1.58,
    idealMax: 1.88,
    rangeMin: -0.98,
    rangeMax: 4.03,
    decayRate: 8.0,
    maxScore: 7.5,  // FaceIQ: medium priority
    weight: 0.02,
    description: 'Lower lip height divided by upper lip height',
    profileType: 'front',
  },

  cupidsBowDepth: {
    id: 'cupidsBowDepth',
    name: "Cupid's Bow Depth",
    category: 'Lips',
    unit: 'mm',
    idealMin: 2.3,
    idealMax: 4,
    rangeMin: 0,
    rangeMax: 7,
    decayRate: 2.0,
    maxScore: 10,
    weight: 0.01,
    description: "Depth of the cupid's bow curve",
    profileType: 'front',
  },

  mouthCornerPosition: {
    id: 'mouthCornerPosition',
    name: 'Mouth Corner Position',
    category: 'Lips',
    unit: 'mm',
    idealMin: 0,
    idealMax: 4,
    rangeMin: -5,
    rangeMax: 10,
    decayRate: 3.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Mouth corner vertical position relative to lip center',
    profileType: 'front',
  },

  // CHIN MEASUREMENTS (FRONT)
  chinToPhiltrumRatio: {
    id: 'chinToPhiltrumRatio',
    name: 'Chin to Philtrum Ratio',
    category: 'Chin',
    unit: 'ratio',
    idealMin: 2.15,
    idealMax: 2.45,
    rangeMin: 0.3,
    rangeMax: 4.5,
    decayRate: 10.0,
    maxScore: 12.5,  // FaceIQ: medium-high priority
    weight: 0.02,
    description: 'Chin height divided by philtrum length',
    profileType: 'front',
  },

  // OTHER FRONT MEASUREMENTS
  iaaJfaDeviation: {
    id: 'iaaJfaDeviation',
    name: 'Deviation of IAA & JFA',
    category: 'Jaw Shape',
    unit: 'degrees',
    idealMin: 0,
    idealMax: 2.5,
    rangeMin: -25,
    rangeMax: 30,
    decayRate: 1.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Deviation between Ipsilateral Alar Angle and Jaw Frontal Angle',
    profileType: 'front',
  },

  ipsilateralAlarAngle: {
    id: 'ipsilateralAlarAngle',
    name: 'Ipsilateral Alar Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 86.5,
    idealMax: 92.5,
    rangeMin: 60,
    rangeMax: 125,
    decayRate: 0.6,
    maxScore: 2.5,  // FaceIQ: low priority
    weight: 0.01,
    description: 'Angle of alar base relative to facial plane',
    profileType: 'front',
  },

  earProtrusionAngle: {
    id: 'earProtrusionAngle',
    name: 'Ear Protrusion Angle',
    category: 'Ears',
    unit: 'degrees',
    idealMin: 10,
    idealMax: 11.5,
    rangeMin: -25,
    rangeMax: 40,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Angle of ear protrusion from head',
    profileType: 'front',
  },

  earProtrusionRatio: {
    id: 'earProtrusionRatio',
    name: 'Ear Protrusion Ratio',
    category: 'Ears',
    unit: 'percent',
    idealMin: 8,
    idealMax: 12,
    rangeMin: -20,
    rangeMax: 40,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.01,
    description: 'Ear protrusion as percentage of head width',
    profileType: 'front',
  },

  neckWidth: {
    id: 'neckWidth',
    name: 'Neck Width',
    category: 'Neck',
    unit: 'percent',
    idealMin: 92,
    idealMax: 98,
    rangeMin: 60,
    rangeMax: 120,
    decayRate: 0.6,
    maxScore: 10,
    weight: 0.01,
    description: 'Neck width as percentage of jaw width',
    profileType: 'front',
  },

  // ==========================================
  // SIDE PROFILE MEASUREMENTS (38)
  // ==========================================

  gonialAngle: {
    id: 'gonialAngle',
    name: 'Gonial Angle',
    category: 'Occlusion/Jaw Growth',
    unit: 'degrees',
    idealMin: 120,
    idealMax: 130,
    rangeMin: 105,
    rangeMax: 145,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.04,
    description: 'Angle at the jaw corner (gonion)',
    profileType: 'side',
  },

  nasolabialAngle: {
    id: 'nasolabialAngle',
    name: 'Nasolabial Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 90,
    idealMax: 105,
    rangeMin: 75,
    rangeMax: 120,
    decayRate: 0.6,
    maxScore: 10,
    weight: 0.03,
    description: 'Angle between columella and upper lip',
    profileType: 'side',
  },

  nasofrontalAngle: {
    id: 'nasofrontalAngle',
    name: 'Nasofrontal Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 116,
    idealMax: 128,
    rangeMin: 90,
    rangeMax: 160,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle at the bridge of nose (nasion)',
    profileType: 'side',
  },

  nasofacialAngle: {
    id: 'nasofacialAngle',
    name: 'Nasofacial Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 31,
    idealMax: 35,
    rangeMin: 15,
    rangeMax: 50,
    decayRate: 1.2,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle between nose and face plane',
    profileType: 'side',
  },

  nasomentaAngle: {
    id: 'nasomentaAngle',
    name: 'Nasomental Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 126,
    idealMax: 131,
    rangeMin: 105,
    rangeMax: 155,
    decayRate: 0.7,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle from nasion to nose tip to chin',
    profileType: 'side',
  },

  nasalTipAngle: {
    id: 'nasalTipAngle',
    name: 'Nasal Tip Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 85,
    idealMax: 105,
    rangeMin: 70,
    rangeMax: 120,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle of the nose tip',
    profileType: 'side',
  },

  nasalProjection: {
    id: 'nasalProjection',
    name: 'Nasal Projection',
    category: 'Nose',
    unit: 'ratio',
    idealMin: 0.55,
    idealMax: 0.6,
    rangeMin: 0.4,
    rangeMax: 0.75,
    decayRate: 20.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Nose projection relative to nasal length (Goode ratio)',
    profileType: 'side',
  },

  nasalWToHRatio: {
    id: 'nasalWToHRatio',
    name: 'Nasal W to H Ratio',
    category: 'Nose',
    unit: 'ratio',
    idealMin: 0.67,
    idealMax: 0.78,
    rangeMin: 0.5,
    rangeMax: 0.95,
    decayRate: 15.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Nose width to height ratio from side view',
    profileType: 'side',
  },

  noseTipRotationAngle: {
    id: 'noseTipRotationAngle',
    name: 'Nose Tip Rotation Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 95,
    idealMax: 110,
    rangeMin: 80,
    rangeMax: 125,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.01,
    description: 'Angle of nose tip rotation',
    profileType: 'side',
  },

  frankfortTipAngle: {
    id: 'frankfortTipAngle',
    name: 'Frankfort-Tip Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 28,
    idealMax: 34,
    rangeMin: 20,
    rangeMax: 42,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Angle between Frankfort plane and nose tip',
    profileType: 'side',
  },

  mentolabialAngle: {
    id: 'mentolabialAngle',
    name: 'Mentolabial Angle',
    category: 'Lips',
    unit: 'degrees',
    idealMin: 120,
    idealMax: 140,
    rangeMin: 100,
    rangeMax: 160,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle at the labiomental fold',
    profileType: 'side',
  },

  zAngle: {
    id: 'zAngle',
    name: 'Z Angle',
    category: 'Occlusion/Jaw Growth',
    unit: 'degrees',
    idealMin: 75,
    idealMax: 85,
    rangeMin: 60,
    rangeMax: 100,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.02,
    description: 'Merrifield Z-Angle for profile assessment',
    profileType: 'side',
  },

  submentalCervicalAngle: {
    id: 'submentalCervicalAngle',
    name: 'Submental Cervical Angle',
    category: 'Neck',
    unit: 'degrees',
    idealMin: 94,
    idealMax: 106,
    rangeMin: 70,
    rangeMax: 140,
    decayRate: 0.6,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle between chin and neck',
    profileType: 'side',
  },

  facialConvexityGlabella: {
    id: 'facialConvexityGlabella',
    name: 'Facial Convexity (Glabella)',
    category: 'Midface/Face Shape',
    unit: 'degrees',
    idealMin: 165,
    idealMax: 175,
    rangeMin: 150,
    rangeMax: 185,
    decayRate: 0.4,
    maxScore: 10,
    weight: 0.03,
    description: 'Facial convexity angle using glabella',
    profileType: 'side',
  },

  facialConvexityNasion: {
    id: 'facialConvexityNasion',
    name: 'Facial Convexity (Nasion)',
    category: 'Midface/Face Shape',
    unit: 'degrees',
    idealMin: 168,
    idealMax: 178,
    rangeMin: 155,
    rangeMax: 190,
    decayRate: 0.4,
    maxScore: 10,
    weight: 0.02,
    description: 'Facial convexity angle using nasion',
    profileType: 'side',
  },

  totalFacialConvexity: {
    id: 'totalFacialConvexity',
    name: 'Total Facial Convexity',
    category: 'Midface/Face Shape',
    unit: 'degrees',
    idealMin: 135,
    idealMax: 145,
    rangeMin: 120,
    rangeMax: 160,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.03,
    description: 'Complete facial profile convexity measurement',
    profileType: 'side',
  },

  facialDepthToHeight: {
    id: 'facialDepthToHeight',
    name: 'Facial Depth to Height Ratio',
    category: 'Midface/Face Shape',
    unit: 'ratio',
    idealMin: 1.3,
    idealMax: 1.44,
    rangeMin: 0.7,
    rangeMax: 1.8,
    decayRate: 8.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Facial depth divided by facial height',
    profileType: 'side',
  },

  anteriorFacialDepth: {
    id: 'anteriorFacialDepth',
    name: 'Anterior Facial Depth',
    category: 'Midface/Face Shape',
    unit: 'degrees',
    idealMin: 64.5,
    idealMax: 67.5,
    rangeMin: 45,
    rangeMax: 95,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.01,
    description: 'Anterior facial projection angle',
    profileType: 'side',
  },

  interiorMidfaceProjectionAngle: {
    id: 'interiorMidfaceProjectionAngle',
    name: 'Interior Midface Projection Angle',
    category: 'Midface/Face Shape',
    unit: 'degrees',
    idealMin: 50,
    idealMax: 56,
    rangeMin: 30,
    rangeMax: 100,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Interior midface projection from side profile',
    profileType: 'side',
  },

  recessionFromFrankfort: {
    id: 'recessionFromFrankfort',
    name: 'Recession Relative to Frankfort Plane',
    category: 'Occlusion/Jaw Growth',
    unit: 'mm',
    idealMin: 1.5,
    idealMax: 15,
    rangeMin: -30,
    rangeMax: 30,
    decayRate: 0.3,
    maxScore: 10,
    weight: 0.02,
    description: 'Chin position relative to Frankfort plane',
    profileType: 'side',
  },

  mandibularPlaneAngle: {
    id: 'mandibularPlaneAngle',
    name: 'Mandibular Plane Angle',
    category: 'Occlusion/Jaw Growth',
    unit: 'degrees',
    idealMin: 22,
    idealMax: 28,
    rangeMin: 15,
    rangeMax: 38,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.03,
    description: 'Angle of mandibular plane to Frankfort plane',
    profileType: 'side',
  },

  ramusToMandibleRatio: {
    id: 'ramusToMandibleRatio',
    name: 'Ramus to Mandible Ratio',
    category: 'Occlusion/Jaw Growth',
    unit: 'ratio',
    idealMin: 0.65,
    idealMax: 0.75,
    rangeMin: 0.5,
    rangeMax: 0.9,
    decayRate: 15.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Ramus height divided by mandible length',
    profileType: 'side',
  },

  gonionToMouthLine: {
    id: 'gonionToMouthLine',
    name: 'Gonion to Mouth Line',
    category: 'Jaw Shape',
    unit: 'mm',
    idealMin: -5,
    idealMax: 5,
    rangeMin: -20,
    rangeMax: 20,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Distance from gonion to mouth level line',
    profileType: 'side',
  },

  // E-LINE MEASUREMENTS
  eLineUpperLip: {
    id: 'eLineUpperLip',
    name: 'Upper Lip E-Line Position',
    category: 'Lips',
    unit: 'mm',
    idealMin: -4,
    idealMax: -2,
    rangeMin: -10,
    rangeMax: 4,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Upper lip distance from E-line (Ricketts)',
    profileType: 'side',
  },

  eLineLowerLip: {
    id: 'eLineLowerLip',
    name: 'Lower Lip E-Line Position',
    category: 'Lips',
    unit: 'mm',
    idealMin: -2,
    idealMax: 0,
    rangeMin: -8,
    rangeMax: 6,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Lower lip distance from E-line (Ricketts)',
    profileType: 'side',
  },

  // S-LINE MEASUREMENTS
  sLineUpperLip: {
    id: 'sLineUpperLip',
    name: 'Upper Lip S-Line Position',
    category: 'Lips',
    unit: 'mm',
    idealMin: 0,
    idealMax: 3,
    rangeMin: -5,
    rangeMax: 8,
    decayRate: 1.2,
    maxScore: 10,
    weight: 0.01,
    description: 'Upper lip distance from S-line (Steiner)',
    profileType: 'side',
  },

  sLineLowerLip: {
    id: 'sLineLowerLip',
    name: 'Lower Lip S-Line Position',
    category: 'Lips',
    unit: 'mm',
    idealMin: -0.4,
    idealMax: 0.4,
    rangeMin: -8,
    rangeMax: 6,
    decayRate: 3.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Lower lip distance from S-line (Steiner)',
    profileType: 'side',
  },

  // BURSTONE LINE
  burstoneUpperLip: {
    id: 'burstoneUpperLip',
    name: 'Upper Lip Burstone Line',
    category: 'Lips',
    unit: 'mm',
    idealMin: 2,
    idealMax: 4,
    rangeMin: -2,
    rangeMax: 8,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Upper lip to Burstone line distance',
    profileType: 'side',
  },

  burstoneLowerLip: {
    id: 'burstoneLowerLip',
    name: 'Lower Lip Burstone Line',
    category: 'Lips',
    unit: 'mm',
    idealMin: 1,
    idealMax: 3,
    rangeMin: -3,
    rangeMax: 7,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Lower lip to Burstone line distance',
    profileType: 'side',
  },

  // H LINE
  holdawayHLine: {
    id: 'holdawayHLine',
    name: 'Holdaway H Line',
    category: 'Lips',
    unit: 'mm',
    idealMin: 0,
    idealMax: 4,
    rangeMin: -5,
    rangeMax: 10,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.01,
    description: 'Holdaway H-line soft tissue assessment',
    profileType: 'side',
  },

  // CHIN MEASUREMENTS (SIDE)
  chinProjection: {
    id: 'chinProjection',
    name: 'Chin Projection',
    category: 'Chin',
    unit: 'mm',
    idealMin: -3,
    idealMax: 3,
    rangeMin: -12,
    rangeMax: 12,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.02,
    description: 'Chin projection relative to ideal position',
    profileType: 'side',
  },

  recessionRelativeToFrankfort: {
    id: 'recessionRelativeToFrankfort',
    name: 'Recession Relative to Frankfort Plane',
    category: 'Chin',
    unit: 'mm',
    idealMin: -2,
    idealMax: 2,
    rangeMin: -10,
    rangeMax: 10,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.02,
    description: 'Chin recession relative to Frankfort horizontal',
    profileType: 'side',
  },

  // FOREHEAD
  browridgeInclinationAngle: {
    id: 'browridgeInclinationAngle',
    name: 'Browridge Inclination Angle',
    category: 'Upper Third',
    unit: 'degrees',
    idealMin: 10,
    idealMax: 18,
    rangeMin: 0,
    rangeMax: 28,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle of the brow ridge from profile',
    profileType: 'side',
  },

  upperForeheadSlope: {
    id: 'upperForeheadSlope',
    name: 'Upper Forehead Slope',
    category: 'Upper Third',
    unit: 'degrees',
    idealMin: 5,
    idealMax: 12,
    rangeMin: 0,
    rangeMax: 20,
    decayRate: 1.2,
    maxScore: 10,
    weight: 0.01,
    description: 'Slope angle of the upper forehead',
    profileType: 'side',
  },

  // MIDFACE PROJECTION
  midfaceProjectionAngle: {
    id: 'midfaceProjectionAngle',
    name: 'Interior Midface Projection Angle',
    category: 'Midface/Face Shape',
    unit: 'degrees',
    idealMin: 85,
    idealMax: 95,
    rangeMin: 75,
    rangeMax: 105,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle of midface projection from profile',
    profileType: 'side',
  },

  orbitalVector: {
    id: 'orbitalVector',
    name: 'Orbital Vector',
    category: 'Eyes',
    unit: 'mm',
    idealMin: 0,
    idealMax: 4,
    rangeMin: -6,
    rangeMax: 10,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Relationship of globe to orbital rim',
    profileType: 'side',
  },

};

// ============================================
// FLAW MAPPINGS (Extracted from FaceIQ)
// ============================================

export interface FlawMapping {
  category: string;
  flawName: string;
  confidence: 'confirmed' | 'likely' | 'possible';
  reasoning: string;
}

export const METRIC_FLAW_MAPPINGS: Record<string, FlawMapping[]> = {
  anteriorFacialDepth: [
    { category: 'Midface/Face Shape', flawName: 'Underprojected midface', confidence: 'confirmed', reasoning: 'The Anterior Facial Depth measurement is above the ideal range. This disrupts facial harmony by creating a sunken and unprominent appearance to the midface.' },
  ],
  bitemporalWidth: [
    { category: 'Upper Third', flawName: 'Narrow forehead', confidence: 'confirmed', reasoning: 'Reduced bitemporal width indicates a narrower than ideal forehead relative to the cheekbones. This disrupts facial harmony by creating a compressed hairline and forehead, altering the overall shape of the face.' },
  ],
  cheekboneHeight: [
    { category: 'Midface/Face Shape', flawName: 'Low-set cheekbones', confidence: 'confirmed', reasoning: 'Reduced cheekbone height indicates that the cheekbones are positioned lower than ideal. This disrupts facial harmony by creating an unpronounced appearance to the cheekbones and facial structure.' },
  ],
  eyeAspectRatio: [
    { category: 'Eyes', flawName: 'Overly round eye shape', confidence: 'confirmed', reasoning: 'A reduced eye aspect ratio indicates overly narrow eyes relative to their height. This disrupts facial harmony by creating an overly surprised appearance and reducing angular definition.' },
  ],
  eyeSeparationRatio: [
    { category: 'Eyes', flawName: 'Close-set eyes', confidence: 'confirmed', reasoning: 'Reduced eye separation indicates close-set eyes. This disrupts facial harmony by making the eye area appear too compressed.' },
  ],
  eyebrowLowSetedness: [
    { category: 'Eyes', flawName: 'Medium-set eyebrows', confidence: 'confirmed', reasoning: 'Increased eyebrow low setedness indicates eyebrows that are positioned higher than ideal. This disrupts facial harmony by reducing the overall visual impact of the eyebrows and framing of the eyes.' },
  ],
  faceWidthToHeight: [
    { category: 'Midface/Face Shape', flawName: 'Long midface', confidence: 'confirmed', reasoning: 'A reduced face width to height ratio indicates an overly long midface relative to its height. This disrupts facial harmony by overemphasizing the middle of the face.' },
  ],
  facialDepthToHeight: [
    { category: 'Occlusion/Jaw Growth', flawName: 'Maxillary recession', confidence: 'confirmed', reasoning: 'Reduced facial depth to height ratio indicates insufficient mid-face projection relative to height. This disrupts facial harmony by creating the appearance of a flat midface.' },
  ],
  gonialAngle: [
    { category: 'Jaw Shape', flawName: 'Weak/soft jaw structure', confidence: 'confirmed', reasoning: 'A wider gonial angle indicates a softer, less defined jawline with reduced angularity. This disrupts facial harmony in the lower face.' },
    { category: 'Jaw Shape', flawName: 'Steep jaw', confidence: 'confirmed', reasoning: 'A wider gonial angle indicates a softer, less defined jawline with reduced angularity. This disrupts facial harmony by creating a narrow or pointed chin effect.' },
  ],
  holdawayHLine: [
    { category: 'Lips', flawName: 'Overly full lower lip', confidence: 'confirmed', reasoning: 'Decreased H-line indicates the lips are positioned too far in front of the line. This disrupts facial harmony by drawing attention to the lower lip and creating an imbalance between the lower lip, chin, and nose.' },
  ],
  interiorMidfaceProjectionAngle: [
    { category: 'Midface/Face Shape', flawName: 'Underprojected midface', confidence: 'confirmed', reasoning: 'The Interior Midface Projection Angle measurement is above the ideal range. This disrupts facial harmony by creating a sunken and unprominent appearance to the midface.' },
  ],
  ipsilateralAlarAngle: [
    { category: 'Midface/Face Shape', flawName: 'Long midface', confidence: 'confirmed', reasoning: 'A decreased ipsilateral alar angle indicates an overly narrow interior midface. This disrupts facial harmony by overemphasizing the middle of the face.' },
  ],
  jawFrontalAngle: [
    { category: 'Jaw Shape', flawName: 'Steep jaw', confidence: 'confirmed', reasoning: 'A narrower jaw frontal angle indicates a steeper jawline or overly wide chin. This disrupts facial harmony by creating a narrow or pointed chin effect.' },
  ],
  jawSlope: [
    { category: 'Jaw Shape', flawName: 'Weak/soft jaw structure', confidence: 'confirmed', reasoning: 'The Jaw Slope measurement is above the ideal range. This disrupts facial harmony in the lower face.' },
  ],
  lateralCanthalTilt: [
    { category: 'Eyes', flawName: 'Insufficient eye tilt', confidence: 'confirmed', reasoning: 'A decreased lateral canthal tilt indicates insufficiently upturned eyes. This disrupts facial harmony by creating a less alert and youthful appearance.' },
  ],
  burstoneLowerLip: [
    { category: 'Lips', flawName: 'Overly full lower lip', confidence: 'confirmed', reasoning: 'The lower lip is positioned excessively in front of the Burstone line. This disrupts facial harmony by drawing attention to the lower lip and creating an imbalance between the lower lip, chin, and nose.' },
  ],
  eLineLowerLip: [
    { category: 'Lips', flawName: 'Overly full lower lip', confidence: 'confirmed', reasoning: 'The lower lip is positioned too far in front of the E-line. This disrupts facial harmony by drawing attention to the lower lip and creating an imbalance between the lower lip, chin, and nose.' },
  ],
  sLineLowerLip: [
    { category: 'Lips', flawName: 'Overly full lower lip', confidence: 'confirmed', reasoning: 'The lower lip is positioned excessively in front of the S-line. This disrupts facial harmony by drawing attention to the lower lip and creating an imbalance between the lower lip, chin, and nose.' },
  ],
  lowerThirdProportion: [
    { category: 'Midface/Face Shape', flawName: 'Long upper jaw', confidence: 'confirmed', reasoning: 'The upper jaw is too long relative to lower jaw, possibly from a long upper jaw or short lower jaw, or a combination of both. This disrupts facial harmony by overemphasizing the upper jaw relative to the lower jaw.' },
  ],
  mandibularPlaneAngle: [
    { category: 'Occlusion/Jaw Growth', flawName: 'Hyper-divergent jaw growth', confidence: 'confirmed', reasoning: 'A steeper mandibular plane angle indicates vertical overgrowth, elongating the lower face and potentially indicating malocclusion. This disrupts facial harmony by elongating the lower face.' },
    { category: 'Jaw Shape', flawName: 'Weak/soft jaw structure', confidence: 'confirmed', reasoning: 'A steeper mandibular plane angle indicates vertical overgrowth, elongating the lower face and potentially indicating malocclusion. This disrupts facial harmony in the lower face.' },
    { category: 'Jaw Shape', flawName: 'Steep jaw', confidence: 'confirmed', reasoning: 'A steeper mandibular plane angle indicates vertical overgrowth, elongating the lower face and potentially indicating malocclusion. This disrupts facial harmony by creating a narrow or pointed chin effect.' },
  ],
  midfaceRatio: [
    { category: 'Midface/Face Shape', flawName: 'Long midface', confidence: 'confirmed', reasoning: 'A reduced midface ratio indicates an overly narrow interior midface relative to its height. This disrupts facial harmony by overemphasizing the middle of the face.' },
    { category: 'Midface/Face Shape', flawName: 'Long upper jaw', confidence: 'confirmed', reasoning: 'A reduced midface ratio indicates an overly narrow interior midface relative to its height. This disrupts facial harmony by overemphasizing the upper jaw relative to the lower jaw.' },
  ],
  nasofacialAngle: [
    { category: 'Occlusion/Jaw Growth', flawName: 'Maxillary recession', confidence: 'confirmed', reasoning: 'A smaller nasofacial angle suggests reduced projection of the nose and midface region, or an overprojected chin. This disrupts facial harmony by creating the appearance of a flat midface.' },
  ],
  nasofrontalAngle: [
    { category: 'Upper Third', flawName: 'Soft and weak brow ridge', confidence: 'confirmed', reasoning: 'An increased nasofrontal angle indicates reduced brow ridge prominence and angularity. This disrupts facial harmony by creating a less defined upper face.' },
  ],
  nasomentaAngle: [
    { category: 'Occlusion/Jaw Growth', flawName: 'Maxillary recession', confidence: 'confirmed', reasoning: 'A larger nasomental angle suggests reduced projection of the nose and midface region, or an overprojected chin. This disrupts facial harmony by creating the appearance of a flat midface.' },
  ],
  noseBridgeWidth: [
    { category: 'Nose', flawName: 'Overly narrow nose bridge', confidence: 'confirmed', reasoning: 'The Nose Bridge to Nose Width measurement is above the ideal range. This disrupts facial harmony by creating an unbalanced nasal profile.' },
  ],
  orbitalVector: [
    { category: 'Eyes', flawName: 'Sunken orbital region', confidence: 'confirmed', reasoning: 'A decreased orbital vector indicates insufficient projection and volume underneath the eye. This disrupts facial harmony due to the lacking volume underneath the eyes, reducing vibrancy and youthfulness.' },
  ],
  ramusToMandibleRatio: [
    { category: 'Jaw Shape', flawName: 'Short ramus', confidence: 'confirmed', reasoning: 'A reduced ramus-to-mandible ratio indicates a shorter than ideal vertical jawbone (ramus) when compared to the mandible. This disrupts facial harmony by reducing jaw height and definition.' },
  ],
  submentalCervicalAngle: [
    { category: 'Neck', flawName: 'Round neck region', confidence: 'confirmed', reasoning: 'An increased submental cervical angle indicates a round neck region, possibly from excess submental fat or tissue. This disrupts facial harmony by reducing neck definition.' },
  ],
  totalFacialWidthToHeight: [
    { category: 'Midface/Face Shape', flawName: 'Overly long face shape', confidence: 'confirmed', reasoning: 'An increased total facial width to height ratio indicates an overly long face relative to its height. This disrupts facial harmony by creating a vertically stretched appearance to the face.' },
  ],
};

// ============================================
// CUSTOM BEZIER CURVES (Extracted from FaceIQ)
// ============================================

export const METRIC_CUSTOM_CURVES: Record<string, CurvePoint[]> = {
  faceWidthToHeight: [
    { x: 1.49, y: 0, leftHandleX: 1.44, leftHandleY: 0, rightHandleX: 1.55, rightHandleY: 0 },
    { x: 1.68, y: 1.05, leftHandleX: 1.62, leftHandleY: 0.36, rightHandleX: 1.71, rightHandleY: 1.58 },
    { x: 1.77, y: 3.07, leftHandleX: 1.74, leftHandleY: 2.15, rightHandleX: 1.79, rightHandleY: 3.88 },
    { x: 1.83, y: 5.83, leftHandleX: 1.80, leftHandleY: 4.64, rightHandleX: 1.84, rightHandleY: 6.85 },
    { x: 1.89, y: 8.70, leftHandleX: 1.88, leftHandleY: 8.30, rightHandleX: 1.92, rightHandleY: 9.50 },
    { x: 1.96, y: 10, leftHandleX: 1.96, leftHandleY: 10, rightHandleX: 1.96, rightHandleY: 10, fixed: true },
    { x: 2.00, y: 10, leftHandleX: 2.00, leftHandleY: 10, rightHandleX: 2.00, rightHandleY: 10, fixed: true },
    { x: 2.07, y: 8.70, leftHandleX: 2.04, leftHandleY: 9.50, rightHandleX: 2.08, rightHandleY: 8.30 },
    { x: 2.13, y: 5.83, leftHandleX: 2.12, leftHandleY: 6.85, rightHandleX: 2.16, rightHandleY: 4.64 },
    { x: 2.19, y: 3.07, leftHandleX: 2.17, leftHandleY: 3.88, rightHandleX: 2.22, rightHandleY: 2.15 },
    { x: 2.28, y: 1.05, leftHandleX: 2.25, leftHandleY: 1.58, rightHandleX: 2.34, rightHandleY: 0.36 },
    { x: 2.47, y: 0, leftHandleX: 2.41, leftHandleY: 0, rightHandleX: 2.52, rightHandleY: 0 },
  ],
  lowerThirdProportion: [
    { x: 25.6, y: 0, leftHandleX: 24.8, leftHandleY: 0, rightHandleX: 26.4, rightHandleY: 0 },
    { x: 28.01, y: 1.58, leftHandleX: 27.23, leftHandleY: 0.53, rightHandleX: 28.27, rightHandleY: 1.97 },
    { x: 28.83, y: 3.21, leftHandleX: 28.60, leftHandleY: 2.60, rightHandleX: 29.10, rightHandleY: 3.90 },
    { x: 29.63, y: 5.85, leftHandleX: 29.40, leftHandleY: 4.90, rightHandleX: 29.85, rightHandleY: 6.80 },
    { x: 30.27, y: 8.56, leftHandleX: 30.05, leftHandleY: 7.80, rightHandleX: 30.50, rightHandleY: 9.30 },
    { x: 31, y: 10, leftHandleX: 30.95, leftHandleY: 10, rightHandleX: 31.05, rightHandleY: 10, fixed: true },
    { x: 33.5, y: 10, leftHandleX: 33.45, leftHandleY: 10, rightHandleX: 33.55, rightHandleY: 10, fixed: true },
    { x: 34.23, y: 8.56, leftHandleX: 34.00, leftHandleY: 9.30, rightHandleX: 34.45, rightHandleY: 7.80 },
    { x: 34.87, y: 5.85, leftHandleX: 34.65, leftHandleY: 6.80, rightHandleX: 35.10, rightHandleY: 4.90 },
    { x: 35.67, y: 3.21, leftHandleX: 35.40, leftHandleY: 3.90, rightHandleX: 35.90, rightHandleY: 2.60 },
    { x: 36.49, y: 1.58, leftHandleX: 36.23, leftHandleY: 1.97, rightHandleX: 37.27, rightHandleY: 0.53 },
    { x: 38.9, y: 0, leftHandleX: 38.1, leftHandleY: 0, rightHandleX: 39.7, rightHandleY: 0 },
  ],
  lateralCanthalTilt: [
    { x: -4.5, y: 0, leftHandleX: -5.5, leftHandleY: 0, rightHandleX: -3.5, rightHandleY: 0 },
    { x: 0.5, y: 1.2, leftHandleX: -0.8, leftHandleY: 0.4, rightHandleX: 1.5, rightHandleY: 1.8 },
    { x: 2.8, y: 3.5, leftHandleX: 2.2, leftHandleY: 2.5, rightHandleX: 3.4, rightHandleY: 4.3 },
    { x: 4.5, y: 6.8, leftHandleX: 4.0, leftHandleY: 5.5, rightHandleX: 5.0, rightHandleY: 7.8 },
    { x: 5.8, y: 9.2, leftHandleX: 5.4, leftHandleY: 8.5, rightHandleX: 5.95, rightHandleY: 9.7 },
    { x: 6.1, y: 10, leftHandleX: 6.05, leftHandleY: 10, rightHandleX: 6.15, rightHandleY: 10, fixed: true },
    { x: 7.8, y: 10, leftHandleX: 7.75, leftHandleY: 10, rightHandleX: 7.85, rightHandleY: 10, fixed: true },
    { x: 8.1, y: 9.2, leftHandleX: 7.95, leftHandleY: 9.7, rightHandleX: 8.5, rightHandleY: 8.5 },
    { x: 9.4, y: 6.8, leftHandleX: 8.9, leftHandleY: 7.8, rightHandleX: 9.9, rightHandleY: 5.5 },
    { x: 11.1, y: 3.5, leftHandleX: 10.5, leftHandleY: 4.3, rightHandleX: 11.7, rightHandleY: 2.5 },
    { x: 13.4, y: 1.2, leftHandleX: 12.4, leftHandleY: 1.8, rightHandleX: 14.7, rightHandleY: 0.4 },
    { x: 18.4, y: 0, leftHandleX: 17.4, leftHandleY: 0, rightHandleX: 19.4, rightHandleY: 0 },
  ],
  gonialAngle: [
    { x: 105, y: 0, leftHandleX: 102, leftHandleY: 0, rightHandleX: 108, rightHandleY: 0 },
    { x: 112, y: 1.5, leftHandleX: 110, leftHandleY: 0.5, rightHandleX: 114, rightHandleY: 2.3 },
    { x: 116, y: 4.2, leftHandleX: 114.5, leftHandleY: 3.0, rightHandleX: 117.5, rightHandleY: 5.2 },
    { x: 118.5, y: 7.5, leftHandleX: 117.5, leftHandleY: 6.3, rightHandleX: 119.5, rightHandleY: 8.5 },
    { x: 120, y: 10, leftHandleX: 119.7, leftHandleY: 10, rightHandleX: 120.3, rightHandleY: 10, fixed: true },
    { x: 130, y: 10, leftHandleX: 129.7, leftHandleY: 10, rightHandleX: 130.3, rightHandleY: 10, fixed: true },
    { x: 131.5, y: 7.5, leftHandleX: 130.5, leftHandleY: 8.5, rightHandleX: 132.5, rightHandleY: 6.3 },
    { x: 134, y: 4.2, leftHandleX: 132.5, leftHandleY: 5.2, rightHandleX: 135.5, rightHandleY: 3.0 },
    { x: 138, y: 1.5, leftHandleX: 136, leftHandleY: 2.3, rightHandleX: 140, rightHandleY: 0.5 },
    { x: 145, y: 0, leftHandleX: 142, leftHandleY: 0, rightHandleX: 148, rightHandleY: 0 },
  ],
  nasolabialAngle: [
    { x: 75, y: 0, leftHandleX: 72, leftHandleY: 0, rightHandleX: 78, rightHandleY: 0 },
    { x: 82, y: 2.0, leftHandleX: 79.5, leftHandleY: 0.7, rightHandleX: 84, rightHandleY: 3.0 },
    { x: 86, y: 5.5, leftHandleX: 84.5, leftHandleY: 4.2, rightHandleX: 87.5, rightHandleY: 6.8 },
    { x: 89, y: 8.8, leftHandleX: 88, leftHandleY: 7.8, rightHandleX: 89.7, rightHandleY: 9.5 },
    { x: 90, y: 10, leftHandleX: 89.8, leftHandleY: 10, rightHandleX: 90.2, rightHandleY: 10, fixed: true },
    { x: 105, y: 10, leftHandleX: 104.8, leftHandleY: 10, rightHandleX: 105.2, rightHandleY: 10, fixed: true },
    { x: 106, y: 8.8, leftHandleX: 105.3, leftHandleY: 9.5, rightHandleX: 107, rightHandleY: 7.8 },
    { x: 109, y: 5.5, leftHandleX: 107.5, leftHandleY: 6.8, rightHandleX: 110.5, rightHandleY: 4.2 },
    { x: 113, y: 2.0, leftHandleX: 111, leftHandleY: 3.0, rightHandleX: 115.5, rightHandleY: 0.7 },
    { x: 120, y: 0, leftHandleX: 117, leftHandleY: 0, rightHandleX: 123, rightHandleY: 0 },
  ],
  // Middle Third Proportion curve (ideal: 31.4-33.4%)
  middleThirdProportion: [
    { x: 21.44, y: 0, leftHandleX: 20.29, leftHandleY: 0, rightHandleX: 23.19, rightHandleY: 0.15 },
    { x: 25.5, y: 1.35, leftHandleX: 24.18, leftHandleY: 0.53, rightHandleX: 26.17, rightHandleY: 1.79 },
    { x: 27.34, y: 3.18, leftHandleX: 26.84, leftHandleY: 2.42, rightHandleX: 27.73, rightHandleY: 3.81 },
    { x: 28.65, y: 5.88, leftHandleX: 28.33, leftHandleY: 4.91, rightHandleX: 28.98, rightHandleY: 6.65 },
    { x: 29.95, y: 8.55, leftHandleX: 29.41, leftHandleY: 7.58, rightHandleX: 30.45, rightHandleY: 9.35 },
    { x: 31.4, y: 10, leftHandleX: 31.3, leftHandleY: 10, rightHandleX: 31.5, rightHandleY: 10, fixed: true },
    { x: 33.4, y: 10, leftHandleX: 33.3, leftHandleY: 10, rightHandleX: 33.5, rightHandleY: 10, fixed: true },
    { x: 34.85, y: 8.55, leftHandleX: 34.35, leftHandleY: 9.35, rightHandleX: 35.39, rightHandleY: 7.58 },
    { x: 36.15, y: 5.88, leftHandleX: 35.82, leftHandleY: 6.65, rightHandleX: 36.47, rightHandleY: 4.91 },
    { x: 37.46, y: 3.18, leftHandleX: 37.07, leftHandleY: 3.81, rightHandleX: 37.96, rightHandleY: 2.42 },
    { x: 39.3, y: 1.35, leftHandleX: 38.63, leftHandleY: 1.79, rightHandleX: 40.62, rightHandleY: 0.53 },
    { x: 43.36, y: 0, leftHandleX: 41.61, leftHandleY: 0.15, rightHandleX: 44.51, rightHandleY: 0 },
  ],
  // Upper Third Proportion curve (ideal: 30-32%)
  upperThirdProportion: [
    { x: 18.75, y: 0.02, leftHandleX: 17.15, leftHandleY: 0.02, rightHandleX: 20.35, rightHandleY: 0.02 },
    { x: 23.82, y: 1.52, leftHandleX: 22.35, leftHandleY: 0.8, rightHandleX: 24.73, rightHandleY: 2.06 },
    { x: 26.05, y: 4.06, leftHandleX: 25.48, leftHandleY: 2.86, rightHandleX: 26.41, rightHandleY: 4.99 },
    { x: 27.19, y: 6.79, leftHandleX: 26.96, leftHandleY: 6.16, rightHandleX: 27.66, rightHandleY: 7.85 },
    { x: 28.54, y: 9.08, leftHandleX: 28.02, leftHandleY: 8.5, rightHandleX: 28.93, rightHandleY: 9.54 },
    { x: 30, y: 10, leftHandleX: 29.9, leftHandleY: 10, rightHandleX: 30.1, rightHandleY: 10, fixed: true },
    { x: 32, y: 10, leftHandleX: 31.9, leftHandleY: 10, rightHandleX: 32.1, rightHandleY: 10, fixed: true },
    { x: 33.46, y: 9.08, leftHandleX: 33.07, leftHandleY: 9.54, rightHandleX: 33.98, rightHandleY: 8.5 },
    { x: 34.81, y: 6.79, leftHandleX: 34.34, leftHandleY: 7.85, rightHandleX: 35.04, rightHandleY: 6.16 },
    { x: 35.95, y: 4.06, leftHandleX: 35.59, leftHandleY: 4.99, rightHandleX: 36.52, rightHandleY: 2.86 },
    { x: 38.18, y: 1.52, leftHandleX: 37.27, leftHandleY: 2.06, rightHandleX: 39.65, rightHandleY: 0.8 },
    { x: 43.25, y: 0.02, leftHandleX: 41.65, leftHandleY: 0.02, rightHandleX: 44.85, rightHandleY: 0.02 },
  ],
  // Eye Separation Ratio curve (ideal: 45.7-46.8%)
  eyeSeparationRatio: [
    { x: 36.54, y: 0, leftHandleX: 35.44, leftHandleY: 0, rightHandleX: 37.40, rightHandleY: 0.04 },
    { x: 39.04, y: 0.63, leftHandleX: 38.16, leftHandleY: 0.21, rightHandleX: 39.77, rightHandleY: 1.05 },
    { x: 41.08, y: 2.17, leftHandleX: 40.57, leftHandleY: 1.71, rightHandleX: 41.62, rightHandleY: 2.76 },
    { x: 42.71, y: 4.74, leftHandleX: 42.26, leftHandleY: 3.81, rightHandleX: 43.08, rightHandleY: 5.52 },
    { x: 43.94, y: 7.37, leftHandleX: 43.65, leftHandleY: 6.79, rightHandleX: 44.17, rightHandleY: 7.77 },
    { x: 44.86, y: 9.02, leftHandleX: 44.54, leftHandleY: 8.56, rightHandleX: 45.08, rightHandleY: 9.5 },
    { x: 45.7, y: 10, leftHandleX: 45.65, leftHandleY: 10, rightHandleX: 45.76, rightHandleY: 10, fixed: true },
    { x: 46.8, y: 10, leftHandleX: 46.75, leftHandleY: 10, rightHandleX: 46.86, rightHandleY: 10, fixed: true },
    { x: 47.64, y: 9.02, leftHandleX: 47.42, leftHandleY: 9.5, rightHandleX: 47.96, rightHandleY: 8.56 },
    { x: 48.56, y: 7.37, leftHandleX: 48.33, leftHandleY: 7.77, rightHandleX: 48.85, rightHandleY: 6.79 },
    { x: 49.79, y: 4.74, leftHandleX: 49.42, leftHandleY: 5.52, rightHandleX: 50.24, rightHandleY: 3.81 },
    { x: 51.42, y: 2.17, leftHandleX: 50.88, leftHandleY: 2.76, rightHandleX: 51.93, rightHandleY: 1.71 },
    { x: 53.46, y: 0.63, leftHandleX: 52.73, leftHandleY: 1.05, rightHandleX: 54.34, rightHandleY: 0.21 },
    { x: 55.96, y: 0, leftHandleX: 55.10, leftHandleY: 0.04, rightHandleX: 57.06, rightHandleY: 0 },
  ],
  // Eyebrow Low Setedness curve (ideal: 0-0.45)
  eyebrowLowSetedness: [
    { x: -2.78, y: 0, leftHandleX: -3.11, leftHandleY: 0, rightHandleX: -2.67, rightHandleY: 0 },
    { x: -1.94, y: 0.4, leftHandleX: -2.08, leftHandleY: 0.11, rightHandleX: -1.81, rightHandleY: 0.57 },
    { x: -1.18, y: 2.25, leftHandleX: -1.36, leftHandleY: 1.5, rightHandleX: -1.05, rightHandleY: 2.72 },
    { x: -0.79, y: 4.06, leftHandleX: -0.88, leftHandleY: 3.43, rightHandleX: -0.68, rightHandleY: 4.84 },
    { x: -0.55, y: 6.21, leftHandleX: -0.58, leftHandleY: 5.55, rightHandleX: -0.47, rightHandleY: 6.92 },
    { x: -0.28, y: 8.76, leftHandleX: -0.37, leftHandleY: 8.23, rightHandleX: -0.23, rightHandleY: 9.22 },
    { x: 0, y: 10, leftHandleX: -0.02, leftHandleY: 10, rightHandleX: 0.02, rightHandleY: 10, fixed: true },
    { x: 0.45, y: 10, leftHandleX: 0.43, leftHandleY: 10, rightHandleX: 0.47, rightHandleY: 10, fixed: true },
    { x: 0.73, y: 8.76, leftHandleX: 0.68, leftHandleY: 9.22, rightHandleX: 0.82, rightHandleY: 8.23 },
    { x: 1, y: 6.21, leftHandleX: 0.92, leftHandleY: 6.92, rightHandleX: 1.03, rightHandleY: 5.55 },
    { x: 1.24, y: 4.06, leftHandleX: 1.13, leftHandleY: 4.84, rightHandleX: 1.33, rightHandleY: 3.43 },
    { x: 1.63, y: 2.25, leftHandleX: 1.50, leftHandleY: 2.72, rightHandleX: 1.81, rightHandleY: 1.5 },
    { x: 2.39, y: 0.4, leftHandleX: 2.26, leftHandleY: 0.57, rightHandleX: 2.53, rightHandleY: 0.11 },
    { x: 3.23, y: 0, leftHandleX: 3.12, leftHandleY: 0, rightHandleX: 3.56, rightHandleY: 0 },
  ],
  // Submental Cervical Angle curve (ideal: 94-106°)
  submentalCervicalAngle: [
    { x: 50.48, y: 0, leftHandleX: 44.48, leftHandleY: 0, rightHandleX: 56.48, rightHandleY: 0 },
    { x: 68.31, y: 1.31, leftHandleX: 62.07, leftHandleY: 0.32, rightHandleX: 72.89, rightHandleY: 2.13 },
    { x: 77.76, y: 3.71, leftHandleX: 76.00, leftHandleY: 2.89, rightHandleX: 80.39, rightHandleY: 4.59 },
    { x: 83.99, y: 6.53, leftHandleX: 82.63, leftHandleY: 5.85, rightHandleX: 85.16, rightHandleY: 7.12 },
    { x: 88.28, y: 8.86, leftHandleX: 86.43, leftHandleY: 7.85, rightHandleX: 89.95, rightHandleY: 9.71 },
    { x: 94, y: 10, leftHandleX: 93.4, leftHandleY: 10, rightHandleX: 94.6, rightHandleY: 10, fixed: true },
    { x: 106, y: 10, leftHandleX: 105.4, leftHandleY: 10, rightHandleX: 106.6, rightHandleY: 10, fixed: true },
    { x: 111.72, y: 8.86, leftHandleX: 110.05, leftHandleY: 9.71, rightHandleX: 113.57, rightHandleY: 7.85 },
    { x: 116.01, y: 6.53, leftHandleX: 114.84, leftHandleY: 7.12, rightHandleX: 117.37, rightHandleY: 5.85 },
    { x: 122.24, y: 3.71, leftHandleX: 119.61, leftHandleY: 4.59, rightHandleX: 124.00, rightHandleY: 2.89 },
    { x: 131.69, y: 1.31, leftHandleX: 127.11, leftHandleY: 2.13, rightHandleX: 137.93, rightHandleY: 0.32 },
    { x: 149.52, y: 0, leftHandleX: 143.52, leftHandleY: 0, rightHandleX: 155.52, rightHandleY: 0 },
  ],
  // Facial Convexity (Glabella) curve (ideal: 169-174°)
  facialConvexityGlabella: [
    { x: 149.21, y: 0, leftHandleX: 146.21, leftHandleY: 0, rightHandleX: 152.21, rightHandleY: 0 },
    { x: 158.07, y: 1.41, leftHandleX: 156.03, leftHandleY: 0.74, rightHandleX: 159.63, rightHandleY: 2 },
    { x: 162.12, y: 4.09, leftHandleX: 161.34, leftHandleY: 3.31, rightHandleX: 163.09, rightHandleY: 5.03 },
    { x: 165.14, y: 7.76, leftHandleX: 164.46, leftHandleY: 6.56, rightHandleX: 165.54, rightHandleY: 8.29 },
    { x: 166.65, y: 9.14, leftHandleX: 165.92, leftHandleY: 8.72, rightHandleX: 167.43, rightHandleY: 9.67 },
    { x: 169, y: 10, leftHandleX: 168.75, leftHandleY: 10, rightHandleX: 169.25, rightHandleY: 10, fixed: true },
    { x: 174, y: 10, leftHandleX: 173.75, leftHandleY: 10, rightHandleX: 174.25, rightHandleY: 10, fixed: true },
    { x: 176.35, y: 9.14, leftHandleX: 175.57, leftHandleY: 9.67, rightHandleX: 177.08, rightHandleY: 8.72 },
    { x: 177.86, y: 7.76, leftHandleX: 177.46, leftHandleY: 8.29, rightHandleX: 178.54, rightHandleY: 6.56 },
    { x: 180.88, y: 4.09, leftHandleX: 179.91, leftHandleY: 5.03, rightHandleX: 181.66, rightHandleY: 3.31 },
    { x: 184.93, y: 1.41, leftHandleX: 183.37, leftHandleY: 2, rightHandleX: 186.97, rightHandleY: 0.74 },
    { x: 193.79, y: 0, leftHandleX: 190.79, leftHandleY: 0, rightHandleX: 196.79, rightHandleY: 0 },
  ],
};

// ============================================
// CATEGORY DEFINITIONS
// ============================================

export const MEASUREMENT_CATEGORIES = {
  'Midface/Face Shape': { color: '#67e8f9', weight: 0.20 },
  'Occlusion/Jaw Growth': { color: '#a78bfa', weight: 0.15 },
  'Jaw Shape': { color: '#f97316', weight: 0.13 },
  'Upper Third': { color: '#84cc16', weight: 0.08 },
  'Eyes': { color: '#06b6d4', weight: 0.12 },
  'Nose': { color: '#fbbf24', weight: 0.10 },
  'Lips': { color: '#ec4899', weight: 0.10 },
  'Chin': { color: '#ef4444', weight: 0.06 },
  'Neck': { color: '#14b8a6', weight: 0.03 },
  'Other': { color: '#6b7280', weight: 0.03 },
};

// ============================================
// CORE SCORING FUNCTIONS
// ============================================

/**
 * FaceIQ Exponential Decay Scoring Algorithm
 * score = maxScore × e^(-decayRate × deviation)
 */
export function calculateFaceIQScore(
  value: number,
  config: MetricConfig
): number {
  const { idealMin, idealMax, decayRate, maxScore, customCurve } = config;

  // Use custom curve if available
  if (customCurve && customCurve.mode === 'custom') {
    return interpolateCustomCurve(value, customCurve.points, maxScore);
  }

  // Perfect score within ideal range
  if (value >= idealMin && value <= idealMax) {
    return maxScore;
  }

  // Calculate deviation from ideal range
  const deviation = value < idealMin
    ? idealMin - value
    : value - idealMax;

  // Exponential decay
  const score = maxScore * Math.exp(-decayRate * deviation);

  return Math.max(0, Math.min(maxScore, score));
}

/**
 * Interpolate custom Bezier curve for scoring
 * Uses cubic Bezier interpolation with control handles for smooth curves
 */
function interpolateCustomCurve(
  value: number,
  points: CurvePoint[],
  maxScore: number
): number {
  void maxScore; // Reserved for future custom curve implementations
  if (points.length === 0) return 0;

  // Sort points by x value
  const sortedPoints = [...points].sort((a, b) => a.x - b.x);

  // Clamp to range
  if (value <= sortedPoints[0].x) return sortedPoints[0].y;
  if (value >= sortedPoints[sortedPoints.length - 1].x) {
    return sortedPoints[sortedPoints.length - 1].y;
  }

  // Find bracketing points
  let lowerIndex = 0;
  for (let i = 0; i < sortedPoints.length - 1; i++) {
    if (value >= sortedPoints[i].x && value <= sortedPoints[i + 1].x) {
      lowerIndex = i;
      break;
    }
  }

  const p0 = sortedPoints[lowerIndex];
  const p3 = sortedPoints[lowerIndex + 1];

  // Check if we have Bezier control handles
  const hasHandles = p0.rightHandleX !== undefined && p3.leftHandleX !== undefined;

  if (hasHandles) {
    // Cubic Bezier interpolation with control points
    const p1x = p0.rightHandleX!;
    const p1y = p0.rightHandleY ?? p0.y;
    const p2x = p3.leftHandleX!;
    const p2y = p3.leftHandleY ?? p3.y;

    // Find t parameter for given x value using Newton-Raphson iteration
    let t = (value - p0.x) / (p3.x - p0.x); // Initial guess

    // Newton-Raphson iterations to find t where B_x(t) = value
    for (let iter = 0; iter < 10; iter++) {
      const bx = cubicBezier(p0.x, p1x, p2x, p3.x, t);
      const bxDerivative = cubicBezierDerivative(p0.x, p1x, p2x, p3.x, t);

      if (Math.abs(bxDerivative) < 1e-10) break;

      const newT = t - (bx - value) / bxDerivative;
      if (Math.abs(newT - t) < 1e-10) break;
      t = Math.max(0, Math.min(1, newT));
    }

    // Calculate y using the found t parameter
    return cubicBezier(p0.y, p1y, p2y, p3.y, t);
  } else {
    // Smooth interpolation using Catmull-Rom spline
    // This provides smoother curves than linear interpolation
    const t = (value - p0.x) / (p3.x - p0.x);

    // Get neighboring points for spline calculation
    const pMinus1 = lowerIndex > 0 ? sortedPoints[lowerIndex - 1] : p0;
    const p4 = lowerIndex + 2 < sortedPoints.length ? sortedPoints[lowerIndex + 2] : p3;

    // Catmull-Rom spline interpolation
    return catmullRomSpline(pMinus1.y, p0.y, p3.y, p4.y, t);
  }
}

/**
 * Cubic Bezier curve evaluation: B(t) = (1-t)³P0 + 3(1-t)²tP1 + 3(1-t)t²P2 + t³P3
 */
function cubicBezier(p0: number, p1: number, p2: number, p3: number, t: number): number {
  const mt = 1 - t;
  const mt2 = mt * mt;
  const mt3 = mt2 * mt;
  const t2 = t * t;
  const t3 = t2 * t;
  return mt3 * p0 + 3 * mt2 * t * p1 + 3 * mt * t2 * p2 + t3 * p3;
}

/**
 * Cubic Bezier derivative: B'(t) = 3(1-t)²(P1-P0) + 6(1-t)t(P2-P1) + 3t²(P3-P2)
 */
function cubicBezierDerivative(p0: number, p1: number, p2: number, p3: number, t: number): number {
  const mt = 1 - t;
  return 3 * mt * mt * (p1 - p0) + 6 * mt * t * (p2 - p1) + 3 * t * t * (p3 - p2);
}

/**
 * Catmull-Rom spline interpolation for smooth curves without explicit handles
 */
function catmullRomSpline(p0: number, p1: number, p2: number, p3: number, t: number): number {
  const t2 = t * t;
  const t3 = t2 * t;

  // Catmull-Rom coefficients with tension = 0.5
  const a = -0.5 * p0 + 1.5 * p1 - 1.5 * p2 + 0.5 * p3;
  const b = p0 - 2.5 * p1 + 2 * p2 - 0.5 * p3;
  const c = -0.5 * p0 + 0.5 * p2;
  const d = p1;

  return a * t3 + b * t2 + c * t + d;
}

/**
 * Calculate standardized score (0-10 normalized)
 */
export function standardizeScore(score: number, maxScore: number): number {
  return (score / maxScore) * 10;
}

/**
 * Determine quality tier based on score
 */
export function getQualityTier(score: number, maxScore: number = 10): QualityTier {
  const normalized = (score / maxScore) * 100;

  if (normalized >= 90) return 'ideal';
  if (normalized >= 70) return 'excellent';
  if (normalized >= 50) return 'good';
  return 'below_average';
}

/**
 * Determine severity level based on score
 */
export function getSeverityLevel(score: number, maxScore: number = 10): SeverityLevel {
  const normalized = (score / maxScore) * 100;

  if (normalized >= 85) return 'optimal';
  if (normalized >= 70) return 'minor';
  if (normalized >= 50) return 'moderate';
  if (normalized >= 30) return 'major';
  if (normalized >= 15) return 'severe';
  return 'extremely_severe';
}

/**
 * Calculate deviation description
 */
export function getDeviationDescription(
  value: number,
  idealMin: number,
  idealMax: number,
  unit: MeasurementUnit
): { deviation: number; direction: 'above' | 'below' | 'within'; description: string } {
  if (value >= idealMin && value <= idealMax) {
    return { deviation: 0, direction: 'within', description: 'within ideal range' };
  }

  const unitLabel = getUnitLabel(unit);

  if (value < idealMin) {
    const dev = idealMin - value;
    return {
      deviation: dev,
      direction: 'below',
      description: `${dev.toFixed(2)}${unitLabel} below ideal`,
    };
  }

  const dev = value - idealMax;
  return {
    deviation: dev,
    direction: 'above',
    description: `${dev.toFixed(2)}${unitLabel} above ideal`,
  };
}

function getUnitLabel(unit: MeasurementUnit): string {
  switch (unit) {
    case 'ratio': return 'x';
    case 'percent': return '%';
    case 'degrees': return '°';
    case 'mm': return 'mm';
    default: return '';
  }
}

// ============================================
// MEASUREMENT CALCULATION UTILITIES
// ============================================

/**
 * Calculate distance between two points
 */
export function distance(p1: Point, p2: Point): number {
  return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
}

/**
 * Calculate angle at vertex point (in degrees)
 */
export function calculateAngle(p1: Point, vertex: Point, p2: Point): number {
  const v1 = { x: p1.x - vertex.x, y: p1.y - vertex.y };
  const v2 = { x: p2.x - vertex.x, y: p2.y - vertex.y };

  const dot = v1.x * v2.x + v1.y * v2.y;
  const cross = v1.x * v2.y - v1.y * v2.x;

  const angle = Math.atan2(cross, dot) * (180 / Math.PI);
  return Math.abs(angle);
}

/**
 * Calculate perpendicular distance from point to line (signed)
 */
export function perpendicularDistance(
  point: Point,
  lineStart: Point,
  lineEnd: Point
): number {
  const A = point.x - lineStart.x;
  const B = point.y - lineStart.y;
  const C = lineEnd.x - lineStart.x;
  const D = lineEnd.y - lineStart.y;

  const dot = A * C + B * D;
  const lenSq = C * C + D * D;
  const param = lenSq !== 0 ? dot / lenSq : -1;

  let xx: number, yy: number;

  if (param < 0) {
    xx = lineStart.x;
    yy = lineStart.y;
  } else if (param > 1) {
    xx = lineEnd.x;
    yy = lineEnd.y;
  } else {
    xx = lineStart.x + param * C;
    yy = lineStart.y + param * D;
  }

  const dx = point.x - xx;
  const dy = point.y - yy;

  const sign =
    (lineEnd.y - lineStart.y) * point.x -
      (lineEnd.x - lineStart.x) * point.y +
      lineEnd.x * lineStart.y -
      lineEnd.y * lineStart.x >=
    0
      ? 1
      : -1;

  return sign * Math.sqrt(dx * dx + dy * dy);
}

/**
 * Helper to get landmark by ID
 */
function getLandmark(landmarks: LandmarkPoint[], id: string): Point | null {
  const lm = landmarks.find((l) => l.id === id);
  return lm ? { x: lm.x, y: lm.y } : null;
}

// ============================================
// SCORE A SINGLE MEASUREMENT
// ============================================

export interface DemographicOptions {
  gender?: Gender;
  ethnicity?: Ethnicity;
}

/**
 * Calculate complete score result for a measurement.
 * If demographics provided, uses demographic-specific ideal ranges.
 */
export function scoreMeasurement(
  metricId: string,
  value: number,
  demographics?: DemographicOptions
): FaceIQScoreResult | null {
  // Get config with demographic overrides if provided
  const config = demographics?.gender
    ? getMetricConfigForDemographics(metricId, demographics.gender, demographics.ethnicity || 'other')
    : FACEIQ_METRICS[metricId];

  if (!config) return null;

  const score = calculateFaceIQScore(value, config);
  const standardizedScore = standardizeScore(score, config.maxScore);
  const qualityTier = getQualityTier(score, config.maxScore);
  const severity = getSeverityLevel(score, config.maxScore);
  const { deviation, direction } = getDeviationDescription(
    value,
    config.idealMin,
    config.idealMax,
    config.unit
  );

  return {
    metricId,
    name: config.name,
    value,
    score,
    standardizedScore,
    qualityTier,
    severity,
    idealMin: config.idealMin,
    idealMax: config.idealMax,
    deviation,
    deviationDirection: direction,
    unit: config.unit,
    category: config.category,
  };
}

// ============================================
// FRONT PROFILE ANALYSIS
// ============================================

export interface FrontProfileResults {
  measurements: FaceIQScoreResult[];
  overallScore: number;
  standardizedScore: number;
  qualityTier: QualityTier;
  categoryScores: Record<string, number>;
}

/**
 * Calculate all front profile measurements from landmarks.
 * Now supports ethnicity-specific ideal ranges for more accurate scoring.
 */
export function analyzeFrontProfile(
  landmarks: LandmarkPoint[],
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'other'
): FrontProfileResults {
  const measurements: FaceIQScoreResult[] = [];
  const demographics: DemographicOptions = { gender, ethnicity };

  // Helper to add measurement if landmarks available
  const addMeasurement = (metricId: string, value: number | null) => {
    if (value !== null) {
      const result = scoreMeasurement(metricId, value, demographics);
      if (result) measurements.push(result);
    }
  };

  // Get key landmarks
  const trichion = getLandmark(landmarks, 'trichion');
  const nasalBase = getLandmark(landmarks, 'nasal_base');
  const subnasale = getLandmark(landmarks, 'subnasale');
  const menton = getLandmark(landmarks, 'menton');
  const leftZygion = getLandmark(landmarks, 'left_zygion');
  const rightZygion = getLandmark(landmarks, 'right_zygion');
  const leftGonion = getLandmark(landmarks, 'left_gonion_inferior');
  const rightGonion = getLandmark(landmarks, 'right_gonion_inferior');
  const leftPupil = getLandmark(landmarks, 'left_pupila');
  const rightPupil = getLandmark(landmarks, 'right_pupila');
  const leftCanthusM = getLandmark(landmarks, 'left_canthus_medialis');
  const leftCanthusL = getLandmark(landmarks, 'left_canthus_lateralis');
  const rightCanthusM = getLandmark(landmarks, 'right_canthus_medialis');
  const rightCanthusL = getLandmark(landmarks, 'right_canthus_lateralis');
  void rightCanthusL; // Will be used for asymmetry measurements
  const leftAlaNasi = getLandmark(landmarks, 'left_ala_nasi');
  const rightAlaNasi = getLandmark(landmarks, 'right_ala_nasi');
  const leftCheilion = getLandmark(landmarks, 'left_cheilion');
  const rightCheilion = getLandmark(landmarks, 'right_cheilion');
  const labraleSuperius = getLandmark(landmarks, 'labrale_superius');
  const labraleInferius = getLandmark(landmarks, 'labrale_inferius');

  // FACIAL THIRDS
  if (trichion && nasalBase && subnasale && menton) {
    const totalHeight = distance(trichion, menton);
    if (totalHeight > 0) {
      const upperThird = (distance(trichion, nasalBase) / totalHeight) * 100;
      const middleThird = (distance(nasalBase, subnasale) / totalHeight) * 100;
      const lowerThird = (distance(subnasale, menton) / totalHeight) * 100;

      addMeasurement('upperThirdProportion', upperThird);
      addMeasurement('middleThirdProportion', middleThird);
      addMeasurement('lowerThirdProportion', lowerThird);
    }
  }

  // FACE WIDTH TO HEIGHT RATIO (FWHR)
  if (leftZygion && rightZygion && nasalBase && labraleSuperius) {
    const bizygomaticWidth = distance(leftZygion, rightZygion);
    const upperFaceHeight = distance(nasalBase, labraleSuperius);
    if (upperFaceHeight > 0) {
      addMeasurement('faceWidthToHeight', bizygomaticWidth / upperFaceHeight);
    }
  }

  // TOTAL FACIAL WIDTH TO HEIGHT
  if (leftZygion && rightZygion && trichion && menton) {
    const cheekWidth = distance(leftZygion, rightZygion);
    const totalHeight = distance(trichion, menton);
    if (cheekWidth > 0) {
      addMeasurement('totalFacialWidthToHeight', totalHeight / cheekWidth);
    }
  }

  // JAW WIDTH RATIO
  if (leftGonion && rightGonion && leftZygion && rightZygion) {
    const bigonialWidth = distance(leftGonion, rightGonion);
    const bizygomaticWidth = distance(leftZygion, rightZygion);
    if (bizygomaticWidth > 0) {
      const ratio = bigonialWidth / bizygomaticWidth;
      addMeasurement('jawWidthRatio', ratio);
      addMeasurement('bigonialWidth', ratio * 100);
    }
  }

  // CANTHAL TILT
  if (leftCanthusM && leftCanthusL) {
    const deltaY = leftCanthusM.y - leftCanthusL.y;
    const deltaX = leftCanthusL.x - leftCanthusM.x;
    const angle = Math.atan2(deltaY, deltaX) * (180 / Math.PI);
    addMeasurement('lateralCanthalTilt', angle);
  }

  // EYE ASPECT RATIO
  if (leftCanthusM && leftCanthusL) {
    const leftPalpSup = getLandmark(landmarks, 'left_palpebra_superior');
    const leftPalpInf = getLandmark(landmarks, 'left_palpebra_inferior');
    if (leftPalpSup && leftPalpInf) {
      const eyeWidth = distance(leftCanthusM, leftCanthusL);
      const eyeHeight = distance(leftPalpSup, leftPalpInf);
      if (eyeWidth > 0) {
        addMeasurement('eyeAspectRatio', eyeHeight / eyeWidth);
      }
    }
  }

  // EYE SEPARATION RATIO
  if (leftCanthusM && rightCanthusM && leftZygion && rightZygion) {
    const intercanthal = distance(leftCanthusM, rightCanthusM);
    const bizygomatic = distance(leftZygion, rightZygion);
    if (bizygomatic > 0) {
      addMeasurement('eyeSeparationRatio', intercanthal / bizygomatic);
    }
  }

  // IPD RATIO
  if (leftPupil && rightPupil && leftZygion && rightZygion) {
    const ipd = distance(leftPupil, rightPupil);
    const bizygomatic = distance(leftZygion, rightZygion);
    if (bizygomatic > 0) {
      addMeasurement('interpupillaryRatio', (ipd / bizygomatic) * 100);
    }
  }

  // ONE EYE APART TEST
  if (leftCanthusM && rightCanthusM && leftCanthusL) {
    const intercanthal = distance(leftCanthusM, rightCanthusM);
    const eyeWidth = distance(leftCanthusM, leftCanthusL);
    if (eyeWidth > 0) {
      addMeasurement('oneEyeApartTest', intercanthal / eyeWidth);
    }
  }

  // NASAL INDEX
  if (leftAlaNasi && rightAlaNasi && nasalBase && subnasale) {
    const nasalWidth = distance(leftAlaNasi, rightAlaNasi);
    const nasalHeight = distance(nasalBase, subnasale);
    if (nasalHeight > 0) {
      addMeasurement('nasalIndex', (nasalWidth / nasalHeight) * 100);
    }
  }

  // INTERCANTHAL-NASAL WIDTH RATIO
  if (leftCanthusM && rightCanthusM && leftAlaNasi && rightAlaNasi) {
    const intercanthal = distance(leftCanthusM, rightCanthusM);
    const nasalWidth = distance(leftAlaNasi, rightAlaNasi);
    if (nasalWidth > 0) {
      addMeasurement('intercanthalNasalRatio', intercanthal / nasalWidth);
    }
  }

  // MOUTH TO NOSE RATIO
  if (leftCheilion && rightCheilion && leftAlaNasi && rightAlaNasi) {
    const mouthWidth = distance(leftCheilion, rightCheilion);
    const nasalWidth = distance(leftAlaNasi, rightAlaNasi);
    if (nasalWidth > 0) {
      addMeasurement('mouthWidthToNoseRatio', mouthWidth / nasalWidth);
    }
  }

  // IPD TO MOUTH WIDTH RATIO
  if (leftPupil && rightPupil && leftCheilion && rightCheilion) {
    const ipd = distance(leftPupil, rightPupil);
    const mouthWidth = distance(leftCheilion, rightCheilion);
    if (ipd > 0) {
      addMeasurement('interpupillaryMouthWidthRatio', mouthWidth / ipd);
    }
  }

  // LIP RATIO
  if (labraleSuperius && labraleInferius && subnasale) {
    const mouthMiddle = getLandmark(landmarks, 'mouth_middle');
    if (mouthMiddle) {
      const upperLipHeight = distance(subnasale, labraleSuperius);
      const lowerLipHeight = distance(mouthMiddle, labraleInferius);
      if (upperLipHeight > 0) {
        addMeasurement('lowerToUpperLipRatio', lowerLipHeight / upperLipHeight);
      }
    }
  }

  // MIDFACE RATIO
  if (leftZygion && rightZygion && nasalBase && subnasale) {
    const midfaceWidth = distance(leftZygion, rightZygion);
    const midfaceHeight = distance(nasalBase, subnasale);
    if (midfaceHeight > 0) {
      addMeasurement('midfaceRatio', midfaceWidth / midfaceHeight / 10); // Normalized
    }
  }

  // Calculate category scores
  const categoryScores: Record<string, { total: number; count: number }> = {};
  for (const m of measurements) {
    if (!categoryScores[m.category]) {
      categoryScores[m.category] = { total: 0, count: 0 };
    }
    categoryScores[m.category].total += m.standardizedScore;
    categoryScores[m.category].count++;
  }

  const categoryAvg: Record<string, number> = {};
  for (const [cat, data] of Object.entries(categoryScores)) {
    categoryAvg[cat] = data.count > 0 ? data.total / data.count : 0;
  }

  // Calculate overall score (weighted average)
  let totalWeight = 0;
  let weightedSum = 0;
  for (const m of measurements) {
    const config = FACEIQ_METRICS[m.metricId];
    if (config) {
      weightedSum += m.standardizedScore * config.weight;
      totalWeight += config.weight;
    }
  }

  const overallScore = totalWeight > 0 ? weightedSum / totalWeight : 0;
  const standardizedScore = overallScore;

  return {
    measurements,
    overallScore,
    standardizedScore,
    qualityTier: getQualityTier(overallScore),
    categoryScores: categoryAvg,
  };
}

// ============================================
// SIDE PROFILE ANALYSIS
// ============================================

export interface SideProfileResults {
  measurements: FaceIQScoreResult[];
  overallScore: number;
  standardizedScore: number;
  qualityTier: QualityTier;
  categoryScores: Record<string, number>;
}

/**
 * Calculate all side profile measurements from landmarks.
 * Now supports ethnicity-specific ideal ranges for more accurate scoring.
 */
export function analyzeSideProfile(
  landmarks: LandmarkPoint[],
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'other'
): SideProfileResults {
  const measurements: FaceIQScoreResult[] = [];
  const demographics: DemographicOptions = { gender, ethnicity };

  const addMeasurement = (metricId: string, value: number | null) => {
    if (value !== null) {
      const result = scoreMeasurement(metricId, value, demographics);
      if (result) measurements.push(result);
    }
  };

  // Get key landmarks
  const glabella = getLandmark(landmarks, 'glabella');
  const nasion = getLandmark(landmarks, 'nasion');
  const rhinion = getLandmark(landmarks, 'rhinion');
  const pronasale = getLandmark(landmarks, 'pronasale');
  const columella = getLandmark(landmarks, 'columella');
  const subnasale = getLandmark(landmarks, 'subnasale');
  const labraleSuperius = getLandmark(landmarks, 'labraleSuperius');
  const labraleInferius = getLandmark(landmarks, 'labraleInferius');
  const sublabiale = getLandmark(landmarks, 'sublabiale');
  const pogonion = getLandmark(landmarks, 'pogonion');
  const menton = getLandmark(landmarks, 'menton');
  const tragus = getLandmark(landmarks, 'tragus');
  const gonionBottom = getLandmark(landmarks, 'gonionBottom');
  const cervicalPoint = getLandmark(landmarks, 'cervicalPoint');
  const orbitale = getLandmark(landmarks, 'orbitale');
  const porion = getLandmark(landmarks, 'porion');

  // GONIAL ANGLE
  if (tragus && gonionBottom && menton) {
    const angle = calculateAngle(tragus, gonionBottom, menton);
    addMeasurement('gonialAngle', angle);
  }

  // NASOLABIAL ANGLE
  if (columella && subnasale && labraleSuperius) {
    const angle = calculateAngle(columella, subnasale, labraleSuperius);
    addMeasurement('nasolabialAngle', angle);
  }

  // NASOFRONTAL ANGLE
  if (glabella && nasion && rhinion) {
    const angle = calculateAngle(glabella, nasion, rhinion);
    addMeasurement('nasofrontalAngle', angle);
  }

  // MENTOLABIAL ANGLE
  if (labraleInferius && sublabiale && pogonion) {
    const angle = calculateAngle(labraleInferius, sublabiale, pogonion);
    addMeasurement('mentolabialAngle', angle);
  }

  // E-LINE MEASUREMENTS
  if (pronasale && pogonion && labraleSuperius && labraleInferius) {
    const upperLipDist = perpendicularDistance(labraleSuperius, pronasale, pogonion);
    const lowerLipDist = perpendicularDistance(labraleInferius, pronasale, pogonion);
    addMeasurement('eLineUpperLip', upperLipDist);
    addMeasurement('eLineLowerLip', lowerLipDist);
  }

  // NASOMENTAL ANGLE
  if (nasion && pronasale && pogonion) {
    const angle = calculateAngle(nasion, pronasale, pogonion);
    addMeasurement('nasomentaAngle', angle);
  }

  // FACIAL CONVEXITY (GLABELLA)
  if (glabella && subnasale && pogonion) {
    const angle = calculateAngle(glabella, subnasale, pogonion);
    addMeasurement('facialConvexityGlabella', angle);
  }

  // FACIAL CONVEXITY (NASION)
  if (nasion && subnasale && pogonion) {
    const angle = calculateAngle(nasion, subnasale, pogonion);
    addMeasurement('facialConvexityNasion', angle);
  }

  // TOTAL FACIAL CONVEXITY
  if (glabella && pronasale && pogonion) {
    const angle = calculateAngle(glabella, pronasale, pogonion);
    addMeasurement('totalFacialConvexity', angle);
  }

  // SUBMENTAL CERVICAL ANGLE
  if (menton && cervicalPoint && pogonion) {
    const neckPoint = getLandmark(landmarks, 'neckPoint');
    if (neckPoint) {
      const angle = calculateAngle(pogonion, menton, neckPoint);
      addMeasurement('submentalCervicalAngle', angle);
    }
  }

  // NASAL PROJECTION (Goode ratio)
  if (pronasale && subnasale && nasion) {
    const projection = distance(pronasale, subnasale);
    const nasalLength = distance(nasion, pronasale);
    if (nasalLength > 0) {
      addMeasurement('nasalProjection', projection / nasalLength);
    }
  }

  // NASOFACIAL ANGLE
  if (nasion && pronasale && pogonion) {
    // Angle between nose dorsum and facial plane
    const nasalDorsum = { x: pronasale.x - nasion.x, y: pronasale.y - nasion.y };
    const facialPlane = { x: pogonion.x - nasion.x, y: pogonion.y - nasion.y };

    const dot = nasalDorsum.x * facialPlane.x + nasalDorsum.y * facialPlane.y;
    const mag1 = Math.sqrt(nasalDorsum.x ** 2 + nasalDorsum.y ** 2);
    const mag2 = Math.sqrt(facialPlane.x ** 2 + facialPlane.y ** 2);

    if (mag1 > 0 && mag2 > 0) {
      const angle = Math.acos(dot / (mag1 * mag2)) * (180 / Math.PI);
      addMeasurement('nasofacialAngle', angle);
    }
  }

  // MANDIBULAR PLANE ANGLE (using Frankfort horizontal)
  if (porion && orbitale && gonionBottom && menton) {
    // Frankfort horizontal is porion to orbitale
    // Mandibular plane is gonion to menton
    const fhAngle = Math.atan2(orbitale.y - porion.y, orbitale.x - porion.x);
    const mpAngle = Math.atan2(menton.y - gonionBottom.y, menton.x - gonionBottom.x);
    const angle = Math.abs(fhAngle - mpAngle) * (180 / Math.PI);
    addMeasurement('mandibularPlaneAngle', angle);
  }

  // CHIN PROJECTION
  if (pogonion && subnasale) {
    // Distance from pogonion to vertical line through subnasale
    const projection = pogonion.x - subnasale.x;
    addMeasurement('chinProjection', projection);
  }

  // Calculate category scores
  const categoryScores: Record<string, { total: number; count: number }> = {};
  for (const m of measurements) {
    if (!categoryScores[m.category]) {
      categoryScores[m.category] = { total: 0, count: 0 };
    }
    categoryScores[m.category].total += m.standardizedScore;
    categoryScores[m.category].count++;
  }

  const categoryAvg: Record<string, number> = {};
  for (const [cat, data] of Object.entries(categoryScores)) {
    categoryAvg[cat] = data.count > 0 ? data.total / data.count : 0;
  }

  // Calculate overall score
  let totalWeight = 0;
  let weightedSum = 0;
  for (const m of measurements) {
    const config = FACEIQ_METRICS[m.metricId];
    if (config) {
      weightedSum += m.standardizedScore * config.weight;
      totalWeight += config.weight;
    }
  }

  const overallScore = totalWeight > 0 ? weightedSum / totalWeight : 0;

  return {
    measurements,
    overallScore,
    standardizedScore: overallScore,
    qualityTier: getQualityTier(overallScore),
    categoryScores: categoryAvg,
  };
}

// ============================================
// COMPLETE HARMONY ANALYSIS
// ============================================

/**
 * Run complete facial harmony analysis.
 * Now supports ethnicity-specific ideal ranges for more accurate scoring.
 */
export function analyzeHarmony(
  frontLandmarks: LandmarkPoint[],
  sideLandmarks: LandmarkPoint[],
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'other'
): HarmonyAnalysis {
  const frontResults = analyzeFrontProfile(frontLandmarks, gender, ethnicity);
  const sideResults = analyzeSideProfile(sideLandmarks, gender, ethnicity);

  const allMeasurements = [...frontResults.measurements, ...sideResults.measurements];

  // Combined category scores
  const allCategories: Record<string, { total: number; count: number }> = {};
  for (const m of allMeasurements) {
    if (!allCategories[m.category]) {
      allCategories[m.category] = { total: 0, count: 0 };
    }
    allCategories[m.category].total += m.standardizedScore;
    allCategories[m.category].count++;
  }

  const categoryScores: Record<string, number> = {};
  for (const [cat, data] of Object.entries(allCategories)) {
    categoryScores[cat] = data.count > 0 ? data.total / data.count : 0;
  }

  // Overall weighted score
  let totalWeight = 0;
  let weightedSum = 0;
  for (const m of allMeasurements) {
    const config = FACEIQ_METRICS[m.metricId];
    if (config) {
      weightedSum += m.standardizedScore * config.weight;
      totalWeight += config.weight;
    }
  }

  const overallScore = totalWeight > 0 ? weightedSum / totalWeight : 0;

  // Identify flaws (below average measurements)
  const flaws: FlawAssessment[] = allMeasurements
    .filter((m) => m.severity !== 'optimal' && m.severity !== 'minor')
    .map((m) => ({
      category: m.category,
      metricId: m.metricId,
      metricName: m.name,
      severity: m.severity,
      deviation: `${m.deviation.toFixed(2)} ${m.deviationDirection} ideal`,
      reasoning: `${m.name} is outside the ideal range`,
      confidence: m.severity === 'extremely_severe' || m.severity === 'severe'
        ? 'confirmed' as const
        : 'likely' as const,
    }))
    .sort((a, b) => {
      const severityOrder = { extremely_severe: 0, severe: 1, major: 2, moderate: 3 };
      return (severityOrder[a.severity as keyof typeof severityOrder] ?? 4) -
             (severityOrder[b.severity as keyof typeof severityOrder] ?? 4);
    });

  // Identify strengths (ideal measurements)
  const strengths: StrengthAssessment[] = allMeasurements
    .filter((m) => m.qualityTier === 'ideal' || m.qualityTier === 'excellent')
    .map((m) => ({
      category: m.category,
      metricId: m.metricId,
      metricName: m.name,
      qualityTier: m.qualityTier,
      value: m.value,
      reasoning: `${m.name} is within the ${m.qualityTier} range`,
    }));

  // Calculate percentile (based on population stats)
  const percentile = calculateHarmonyPercentile(overallScore);

  return {
    overallScore,
    standardizedScore: overallScore,
    qualityTier: getQualityTier(overallScore),
    percentile,
    frontScore: frontResults.overallScore,
    sideScore: sideResults.overallScore,
    categoryScores,
    measurements: allMeasurements,
    flaws,
    strengths,
  };
}

/**
 * Calculate percentile from harmony score
 */
function calculateHarmonyPercentile(score: number): number {
  // Based on normal distribution with mean=5, stdDev=1.5
  const mean = 5;
  const stdDev = 1.5;
  const z = (score - mean) / stdDev;
  return normalCDF(z) * 100;
}

/**
 * Standard normal CDF approximation
 */
function normalCDF(z: number): number {
  const a1 = 0.254829592;
  const a2 = -0.284496736;
  const a3 = 1.421413741;
  const a4 = -1.453152027;
  const a5 = 1.061405429;
  const p = 0.3275911;

  const sign = z < 0 ? -1 : 1;
  const absZ = Math.abs(z) / Math.sqrt(2);

  const t = 1.0 / (1.0 + p * absZ);
  const y = 1.0 - ((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t * Math.exp(-absZ * absZ);

  return 0.5 * (1.0 + sign * y);
}

// ============================================
// PSL RATING CONVERSION
// ============================================

export interface PSLRating {
  score: number;
  tier: string;
  percentile: number;
  description: string;
}

/**
 * Convert harmony score to PSL rating
 */
export function convertToPSL(harmonyScore: number): PSLRating {
  // Convert 0-10 harmony to 3.0-7.5 PSL range
  const psl = 3.0 + (harmonyScore / 10) * 4.5;
  const clampedPSL = Math.max(3.0, Math.min(7.5, psl));

  let tier: string;
  let percentile: number;

  if (clampedPSL >= 7.5) {
    tier = 'Top Model';
    percentile = 99.99;
  } else if (clampedPSL >= 7.0) {
    tier = 'Chad';
    percentile = 99.87;
  } else if (clampedPSL >= 6.5) {
    tier = 'Chadlite';
    percentile = 99.0;
  } else if (clampedPSL >= 6.0) {
    tier = 'High Tier Normie+';
    percentile = 97.25;
  } else if (clampedPSL >= 5.5) {
    tier = 'High Tier Normie';
    percentile = 90.0;
  } else if (clampedPSL >= 5.0) {
    tier = 'Mid Tier Normie+';
    percentile = 84.15;
  } else if (clampedPSL >= 4.5) {
    tier = 'Mid Tier Normie';
    percentile = 65.0;
  } else if (clampedPSL >= 4.0) {
    tier = 'Low Tier Normie';
    percentile = 50.0;
  } else if (clampedPSL >= 3.5) {
    tier = 'Below Average';
    percentile = 30.0;
  } else {
    tier = 'Subpar';
    percentile = 15.0;
  }

  return {
    score: clampedPSL,
    tier,
    percentile,
    description: `${tier} (top ${(100 - percentile).toFixed(1)}%)`,
  };
}

// ============================================
// EXPORTS FOR BACKWARD COMPATIBILITY
// ============================================

export type { LandmarkPoint } from './landmarks';
