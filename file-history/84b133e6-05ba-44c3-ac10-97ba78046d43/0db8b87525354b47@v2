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
import { FACEIQ_BEZIER_CURVES } from './faceiq-bezier-curves';

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

/**
 * Polarity defines how deviation from the ideal range is interpreted:
 * - 'balanced': Default. Deviation in either direction is equally bad.
 * - 'higher_is_better': Values above the ideal are still good. Only values below
 *   the 'safeFloor' are true weaknesses. E.g., Canthal Tilt (positive tilt is good)
 * - 'lower_is_better': Values below the ideal are still good. Only values above
 *   the 'safeCeiling' are true weaknesses. E.g., Philtrum length (shorter is better)
 */
export type MetricPolarity = 'balanced' | 'higher_is_better' | 'lower_is_better';

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
  /**
   * Polarity for directional/dimorphic scoring.
   * Defaults to 'balanced' if not specified.
   */
  polarity?: MetricPolarity;
  /**
   * For 'higher_is_better': minimum value that's still acceptable.
   * Values above this but below idealMin get a passing score (softFloorScore).
   * Values below this are true weaknesses.
   */
  safeFloor?: number;
  /**
   * For 'lower_is_better': maximum value that's still acceptable.
   * Values below this but above idealMax get a passing score (softCeilingScore).
   * Values above this are true weaknesses.
   */
  safeCeiling?: number;
  /**
   * Score given to values in the "acceptable but not ideal" zone.
   * Defaults to 8.0 (Good). Range: 6.0-9.0
   */
  softZoneScore?: number;
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
    // Middle Eastern: Penalizes droopy tip (<90°) - common flaw is "Hooked Nose"
    // Extracted from FaceIQ Male:MiddleEastern.htc
    black_male: { idealMin: 95, idealMax: 110 },
    black_female: { idealMin: 100, idealMax: 115 },
    east_asian_male: { idealMin: 90, idealMax: 105 },
    east_asian_female: { idealMin: 95, idealMax: 110 },
    middle_eastern_male: { idealMin: 90, idealMax: 100 },  // Strict on droopy tip
    middle_eastern_female: { idealMin: 95, idealMax: 105 },
    // Gender-only fallbacks
    male: { idealMin: 90, idealMax: 100 },
    female: { idealMin: 100, idealMax: 110 },
  },

  nasalProjection: {
    // Nose projection relative to face depth
    // East Asian/African: typically less projection is ideal
    // Middle Eastern: Accepts stronger projection (bigger nose) than White model
    // Extracted from FaceIQ Male:MiddleEastern.htc
    east_asian: { idealMin: 0.54, idealMax: 0.60 },
    black: { idealMin: 0.52, idealMax: 0.58 },
    south_asian: { idealMin: 0.56, idealMax: 0.62 },
    middle_eastern: { idealMin: 0.62, idealMax: 0.70 },  // Higher tolerance for larger noses
    white: { idealMin: 0.60, idealMax: 0.67 },
    pacific_islander: { idealMin: 0.52, idealMax: 0.58 },
  },

  intercanthalNasalRatio: {
    // Alar width (nose width) relative to intercanthal distance (inner eye spacing)
    // White: Neoclassical standard - STRICT 1:1 ratio (nose width = inner eye spacing)
    // Research: Wider nose base is standard in African phenotypes
    // South Asian Female: Accepts slightly wider base (1.00-1.08) but demands higher tip definition
    // Pacific Islander: Similar to Black model, accepts wide nasal base
    // Black Female: Wider than White Female, narrower than Black Male - balance of width and refinement
    // Hispanic Female: Intermediate tolerance - slightly wider base acceptable with bridge definition
    // Extracted from FaceIQ Male:White.htc (Neoclassical), BlackAfrican.htc, Female:African.htc, Female:Hispanic.htc, Female:SouthAsian.htc and Male:Pacific Islander.htc logic
    white_male: { idealMin: 0.98, idealMax: 1.05 },  // Neoclassical - strictest nasal width standard
    white_female: { idealMin: 0.98, idealMax: 1.05 },  // Strict "Rule of Fifths" (1:1 with eye width)
    east_asian_male: { idealMin: 1.10, idealMax: 1.15 },
    east_asian_female: { idealMin: 1.08, idealMax: 1.13 },
    south_asian_male: { idealMin: 1.05, idealMax: 1.08 },  // Hybrid: between White and East Asian
    south_asian_female: { idealMin: 1.00, idealMax: 1.08 },  // Wider tolerance - accepts broader base
    black_male: { idealMin: 1.15, idealMax: 1.25 },  // WIDEST - completely inverts White standard
    black_female: { idealMin: 1.05, idealMax: 1.15 },  // Wider than White Female, narrower than Black Male
    hispanic_male: { idealMin: 1.00, idealMax: 1.12 },  // "Bridge" tolerance - between White and Black
    hispanic_female: { idealMin: 1.00, idealMax: 1.10 },  // Intermediate - between White and Black Female standards
    native_american_female: { idealMin: 1.00, idealMax: 1.10 },  // Simpler/Sharper nose
    pacific_islander_male: { idealMin: 1.10, idealMax: 1.20 },  // Wide tolerance, similar to Black model
    pacific_islander_female: { idealMin: 1.05, idealMax: 1.15 },  // Wider tolerance for nasal base
  },

  // ==========================================
  // JAW METRICS - Clear gender dimorphism
  // ==========================================
  bigonialWidth: {
    // Jaw width as % of bizygomatic width
    // Males: wider, more angular; Females: narrower, softer
    // Pacific Islander: Extremely wide jaw preferred - "Warrior Skull" robustness
    // Extracted from FaceIQ Male:Pacific Islander.htc
    male: { idealMin: 90, idealMax: 95 },
    female: { idealMin: 85, idealMax: 90 },
    pacific_islander_male: { idealMin: 92, idealMax: 98 },  // Jaw width rivals cheekbone width - extreme robustness
    pacific_islander_female: { idealMin: 88, idealMax: 94 },
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
    // White: Neoclassical standard - square, vertically robust jaw (115-125°)
    // Males: more acute (sharper jaw); Females: more obtuse (softer)
    // East Asian Female: Prefers softer, V-shaped jawline (120-126°) - "Doll Face" aesthetic
    // Black Female: Soft/feminine jaw standard - similar to general female range
    // Extracted from FaceIQ Male:White.htc, Female:East Asian.htc, and Female:African.htc
    white_male: { idealMin: 115, idealMax: 125 },  // Neoclassical square jaw - less tolerant of soft/V-shaped jaws
    white_female: { idealMin: 122.0, idealMax: 130.0 },  // Soft, tapered jawline (V-shape)
    east_asian_female: { idealMin: 120, idealMax: 126 },  // Narrower tolerance - penalizes square jaws more
    black_female: { idealMin: 120.0, idealMax: 130.0 },  // Soft/feminine jaw preference
    native_american_female: { idealMin: 115.0, idealMax: 125.0 },  // Strong, defined jawline
    pacific_islander_female: { idealMin: 115.0, idealMax: 128.0 },  // Strong but allows slightly softer definition
    male: { idealMin: 115, idealMax: 125 },
    female: { idealMin: 120, idealMax: 135 },
  },

  // ==========================================
  // EYE METRICS - Ethnic variation
  // ==========================================
  lateralCanthalTilt: {
    // White: Neoclassical standard - neutral to slightly positive tilt (4-8°)
    // East Asian: naturally higher positive tilt
    // Hispanic: Strong preference for positive tilt (almond eyes), penalizes neutral/negative more harshly
    // Hispanic Female: STRONGEST "Almond/Cat Eye" preference - rewards positive tilt heavily
    // Middle Eastern: Strong preference for "Hunter Eyes" (Dark Triad look)
    // Extracted from FaceIQ Male:White.htc (Neoclassical baseline), Male:MiddleEastern.htc, and Female:Hispanic.htc
    white_male: { idealMin: 4.0, idealMax: 8.0 },  // Neoclassical - neutral to slightly positive
    white_female: { idealMin: 4.0, idealMax: 9.0 },  // Neutral to slightly positive
    east_asian_male: { idealMin: 8, idealMax: 12 },
    east_asian_female: { idealMin: 9, idealMax: 13 },
    south_asian_male: { idealMin: 6, idealMax: 10 },
    south_asian_female: { idealMin: 7, idealMax: 11 },
    hispanic_male: { idealMin: 6.0, idealMax: 12.0 },  // Wide range, heavily rewards positive tilt
    hispanic_female: { idealMin: 6.0, idealMax: 12.0 },  // "Cat Eye/Almond" ideal - strongest preference among female demographics
    middle_eastern_male: { idealMin: 4.0, idealMax: 10.0 },  // Almond/Hunter eye preference
    middle_eastern_female: { idealMin: 5.0, idealMax: 10.0 },  // Preference for "Foxy/Hunter" feminine eyes
    native_american_female: { idealMin: 5.0, idealMax: 11.0 },  // Positive tilt (Hunter/Almond)
    // Default for others is 4-8 (already in FACEIQ_METRICS)
  },

  eyeAspectRatio: {
    // East Asian eyes often have different aspect ratio due to epicanthal fold
    east_asian_male: { idealMin: 2.6, idealMax: 3.2 },
    east_asian_female: { idealMin: 2.7, idealMax: 3.3 },
    // Larger eyes in females considered more attractive
    male: { idealMin: 2.9, idealMax: 3.4 },
    female: { idealMin: 3.1, idealMax: 3.6 },
  },

  tearTroughDepth: {
    // Under-eye hollowing and dark circles (infraorbital depression)
    // South Asian: MUCH stricter penalty due to genetic hyperpigmentation
    // Extracted from FaceIQ Male:SouthAsian.htc and Female:SouthAsian.htc - biggest difference vs White model
    white_male: { idealMin: 0.0, idealMax: 1.5 },
    white_female: { idealMin: 0.0, idealMax: 1.3 },
    south_asian_male: { idealMin: 0.0, idealMax: 0.5 },  // VERY strict - 0.5+ triggers "Tired/Aged Eyes" flaw
    south_asian_female: { idealMin: 0.0, idealMax: 0.5 },  // Even minor shadows trigger "Dark Circles" flaw
    east_asian_male: { idealMin: 0.0, idealMax: 1.2 },
    east_asian_female: { idealMin: 0.0, idealMax: 1.0 },
  },

  upperEyelidExposure: {
    // Visible eyelid platform (space between eyelash and crease)
    // South Asian ideal: prefers visible lid platform, penalizes hooded eyes more than White model
    // Extracted from FaceIQ Male:SouthAsian.htc
    white_male: { idealMin: 0.3, idealMax: 2.5 },
    white_female: { idealMin: 0.5, idealMax: 3.0 },
    south_asian_male: { idealMin: 0.5, idealMax: 2.0 },  // Prefers visible lid, penalizes hooding
    south_asian_female: { idealMin: 0.7, idealMax: 2.2 },
    east_asian_male: { idealMin: 0.0, idealMax: 1.5 },  // More tolerance for less exposure
    east_asian_female: { idealMin: 0.2, idealMax: 1.8 },
    middle_eastern_female: { idealMin: 0.5, idealMax: 1.5 },  // Low exposure (Almond shape)
  },

  eyeSeparationRatio: {
    // East Asian Female: Wider tolerance for "Doll Eyes" (wide-set eyes) - neotenous preference
    // Wide-set eyes (46.3-47.5%) are ideal in East Asian female beauty standards
    // Extracted from FaceIQ Female:East Asian.htc
    east_asian_female: { idealMin: 46.3, idealMax: 47.5 },  // Wide-set eyes are preferred for youthful look
  },

  // ==========================================
  // FACE PROPORTIONS - Gender variation
  // ==========================================
  faceWidthToHeight: {
    // White: Neoclassical standard - balanced, moderate width (1.98-2.02)
    // Males: slightly wider face preferred; Females: slightly narrower
    // Hispanic: Allows broader "Mesoprosopic" faces (Mestizo/Indigenous bone structure)
    // Hispanic Female: "Mestiza" face shape tolerance - broader than White (~1.45) but feminine, celebrates facial harmony
    // Pacific Islander: "Warrior Skull" - extremely broad face preferred (highest FWHR of any demographic)
    // Extracted from FaceIQ Male:White.htc (Neoclassical baseline), Male:Pacific Islander.htc, and Female:Hispanic.htc
    white_male: { idealMin: 1.98, idealMax: 2.02 },  // Neoclassical - moderate width baseline
    white_female: { idealMin: 1.45, idealMax: 1.53 },  // Preference for Oval/Narrow shapes
    male: { idealMin: 1.98, idealMax: 2.02 },
    female: { idealMin: 1.94, idealMax: 1.98 },
    hispanic_male: { idealMin: 1.95, idealMax: 2.10 },  // Rewards broader, robust face shapes
    hispanic_female: { idealMin: 1.50, idealMax: 1.62 },  // Broader than White (~1.45) but not masculine - heart/round-square shapes
    native_american_female: { idealMin: 1.52, idealMax: 1.65 },  // Wide/Heart shape (High skeletal width)
    pacific_islander_male: { idealMin: 2.10, idealMax: 2.30 },  // "Warrior Skull" - extremely broad, square face
    pacific_islander_female: { idealMin: 1.55, idealMax: 1.70 },  // The widest female ideal (Skeletal + Volume)
  },

  totalFacialWidthToHeight: {
    male: { idealMin: 1.35, idealMax: 1.40 },
    female: { idealMin: 1.32, idealMax: 1.37 },
  },

  midfaceRatio: {
    // Females often have more compact midface
    // White: Neoclassical standard - strict compact midface preference
    // Middle Eastern: Similar to White model - compact is better
    // Extracted from FaceIQ Male:White.htc (Neoclassical baseline) and Male:MiddleEastern.htc
    white_male: { idealMin: 0.95, idealMax: 1.02 },  // Neoclassical - penalizes long midface heavily
    white_female: { idealMin: 0.93, idealMax: 1.00 },
    male: { idealMin: 0.98, idealMax: 1.02 },
    female: { idealMin: 0.95, idealMax: 1.00 },
    middle_eastern_male: { idealMin: 0.95, idealMax: 1.02 },  // Slightly wider tolerance, compact preferred
    middle_eastern_female: { idealMin: 0.93, idealMax: 0.99 },
  },

  lowerThirdProportion: {
    // East Asian Female: Prefers smaller, more compact lower face (Heart/Oval face shape ideal)
    // Smaller lower third contributes to "Cute" or "Doll Face" aesthetic
    // Extracted from FaceIQ Female:East Asian.htc
    east_asian_female: { idealMin: 29.6, idealMax: 32.7 },  // Penalizes long/masculine chin
  },

  // ==========================================
  // LIP METRICS - Ethnicity variation
  // ==========================================
  lipRatio: {
    // African/Hispanic: fuller lips natural
    // Black Female: Highest fullness requirement in the app - thin lips heavily penalized
    // Extracted from FaceIQ Female:African.htc - combines neoteny with phenotypic lip fullness
    black_male: { idealMin: 1.6, idealMax: 2.2 },
    black_female: { idealMin: 1.3, idealMax: 1.6 },  // HIGHEST fullness standard in the app
    hispanic_male: { idealMin: 1.4, idealMax: 2.0 },
    hispanic_female: { idealMin: 1.1, idealMax: 1.35 },  // Voluptuous but balanced
    // East Asian: less full lips
    east_asian_male: { idealMin: 1.2, idealMax: 1.7 },
    east_asian_female: { idealMin: 1.3, idealMax: 1.8 },
    // Pacific Islander: Explicit preference for full lips
    pacific_islander_female: { idealMin: 1.25, idealMax: 1.50 },
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
    // Black/African: Adjusted for bimaxillary prognathism (forward mouth projection)
    // Black Female: Allows forward projection - less likely to trigger "Recessed Chin"
    // Extracted from FaceIQ BlackAfrican.htc and Female:African.htc logic
    male: { idealMin: 0, idealMax: 3 },
    female: { idealMin: -2, idealMax: 2 },
    black_male: { idealMin: 0, idealMax: 4 },  // Accommodates natural forward projection
    black_female: { idealMin: 0.0, idealMax: 5.0 },  // Wide tolerance for forward projection
  },

  nasofrontalAngle: {
    // Higher brow ridge in males
    male: { idealMin: 128, idealMax: 138 },
    female: { idealMin: 132, idealMax: 142 },
  },

  chinToPhiltrumRatio: {
    // White: Neoclassical standard - strict balance between chin and philtrum
    // Black/African: Fuller lips naturally shorten visible philtrum
    // Extracted from FaceIQ Male:White.htc (Neoclassical) and BlackAfrican.htc
    // Higher ratio = shorter philtrum (more acceptable in Black phenotype)
    white_male: { idealMin: 2.10, idealMax: 2.30 },  // Neoclassical - strict lower face balance
    white_female: { idealMin: 2.0, idealMax: 2.2 },  // Classical Golden Ratio
    black_male: { idealMin: 2.15, idealMax: 2.70 },  // Accommodates shorter philtrum
    black_female: { idealMin: 2.10, idealMax: 2.65 },
  },

  // ==========================================
  // SKIN QUALITY - Ethnicity variation
  // ==========================================
  skinUniformity: {
    // South Asian: Stricter standards due to genetic hyperpigmentation tendency
    // Hispanic: Similar to South Asian - penalizes hyperpigmentation more than White model
    // Extracted from FaceIQ Male:Hispanic.htc - "Bridge Model"
    white_male: { idealMin: 0.88, idealMax: 1.00 },
    white_female: { idealMin: 0.90, idealMax: 1.00 },
    south_asian_male: { idealMin: 0.90, idealMax: 1.00 },  // Stricter - hyperpigmentation common
    south_asian_female: { idealMin: 0.92, idealMax: 1.00 },
    east_asian_male: { idealMin: 0.92, idealMax: 1.00 },  // High skin quality standards
    east_asian_female: { idealMin: 0.94, idealMax: 1.00 },
    black_male: { idealMin: 0.85, idealMax: 1.00 },  // More tolerance for melanin variation
    black_female: { idealMin: 0.87, idealMax: 1.00 },
    hispanic_male: { idealMin: 0.85, idealMax: 1.00 },  // Bridge: more tolerance than South Asian, less than White
    hispanic_female: { idealMin: 0.87, idealMax: 1.00 },
  },

  // ==========================================
  // EYEBROW METRICS - Ethnicity variation
  // ==========================================
  eyebrowThickness: {
    // Middle Eastern: Heavily favors thick, dense eyebrows ("Dark Triad" look with deep-set eyes)
    // Extracted from FaceIQ Male:MiddleEastern.htc - STRICTEST eyebrow requirements
    middle_eastern_male: { idealMin: 2.5, idealMax: 5.0 },  // Prefers significantly thicker/darker brows
    middle_eastern_female: { idealMin: 1.5, idealMax: 3.0 },  // Thick, high-contrast brows are ideal
    east_asian_male: { idealMin: 1.5, idealMax: 3.0 },  // Typically less thick
    east_asian_female: { idealMin: 1.3, idealMax: 2.5 },
    male: { idealMin: 2.0, idealMax: 4.0 },
    female: { idealMin: 1.8, idealMax: 3.5 },
  },

  eyebrowDistance: {
    // Middle Eastern: "Kill Switch" for unibrow (synophrys)
    // Extracted from FaceIQ Male:MiddleEastern.htc
    // While thick brows are favored, unibrow is a critical flaw if distance < 15mm
    middle_eastern_male: { idealMin: 15, idealMax: 25 },  // Stricter minimum to avoid unibrow
    middle_eastern_female: { idealMin: 18, idealMax: 28 },
    male: { idealMin: 15, idealMax: 25 },
    female: { idealMin: 16, idealMax: 26 },
  },

  orbitalVector: {
    // Middle Eastern: Favors deep-set eyes (lower/negative orbital vector)
    // Part of the "Dark Triad" look with heavy brows
    // Extracted from FaceIQ Male:MiddleEastern.htc
    middle_eastern_male: { idealMin: -2, idealMax: 3 },  // Allows more deep-set eyes
    middle_eastern_female: { idealMin: -1, idealMax: 4 },
    male: { idealMin: 0, idealMax: 4 },
    female: { idealMin: 1, idealMax: 5 },
  },

  eyebrowLowSetedness: {
    // East Asian Female: Prefers higher-set, softer brows (less aggressive/masculine)
    // Lower values = higher brow position (more feminine)
    // Extracted from FaceIQ Female:East Asian.htc
    east_asian_female: { idealMin: 0.85, idealMax: 1.30 },  // "Soft Brow" preference - penalizes low-set aggressive brows
  },

  cheekFullness: {
    // South Asian: Rewards youthful midface volume, penalizes "Gaunt/Hollow" look more than "Chubby"
    // White: Prefers leaner, "Model" look with defined cheekbones (hollow cheeks acceptable)
    // East Asian Female: Similar to South Asian - neoteny/youthful fullness preference
    // Extracted from FaceIQ Female:SouthAsian.htc
    white_male: { idealMin: 0.8, idealMax: 1.5 },  // Accepts hollow cheeks (model/athletic look)
    white_female: { idealMin: 0.9, idealMax: 1.6 },
    south_asian_male: { idealMin: 1.0, idealMax: 1.8 },  // Rewards facial volume
    south_asian_female: { idealMin: 1.0, idealMax: 2.0 },  // Youthful fullness highly valued
    east_asian_female: { idealMin: 1.0, idealMax: 1.9 },  // Neoteny preference - "Doll Face" fullness
    pacific_islander_female: { idealMin: 1.2, idealMax: 2.5 },  // VOLUME is key here (Softness/Health)
    male: { idealMin: 0.9, idealMax: 1.6 },
    female: { idealMin: 1.0, idealMax: 1.8 },
  },

  cheekboneHeight: {
    // Native American Female: High/defined cheekbones are key to facial structure
    // Pacific Islander Female: Similar preference for prominent cheekbones
    native_american_female: { idealMin: 1.5, idealMax: 2.5 },  // DEFINITION is key here (High Zygomas)
    pacific_islander_female: { idealMin: 1.3, idealMax: 2.3 },  // Prominence with volume
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
    decayRate: 0.12,  // FaceIQ parity: was 6.4 (53x too harsh)
    maxScore: 30,  // FaceIQ: highest priority metric
    weight: 0.06,
    description: 'Ratio of bizygomatic width to upper face height',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.faceWidthToHeight,
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
    decayRate: 0.18,  // FaceIQ parity: was 1.86 (10x too harsh)
    maxScore: 10,
    weight: 0.03,
    description: 'Percentage of face occupied by lower third (subnasale to menton)',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.lowerThirdProportion,
  },

  lowerThirdProportionAlt: {
    id: 'lowerThirdProportionAlt',
    name: 'Lower Third Internal Ratio',
    category: 'Midface/Face Shape',
    unit: 'percent',
    idealMin: 33.9,
    idealMax: 37,
    rangeMin: 25,
    rangeMax: 46,
    decayRate: 0.18,  // FaceIQ parity: was 1.5 (8x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Ratio of upper-lower-third (subnasale to stomion) to total lower third (subnasale to menton)',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.lowerThirdProportionAlt,
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
    decayRate: 0.18,  // FaceIQ parity: was 1.5 (8x too harsh)
    maxScore: 10,
    weight: 0.03,
    description: 'Percentage of face occupied by middle third',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.middleThirdProportion,
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
    decayRate: 0.18,  // FaceIQ parity: was 1.2 (7x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Percentage of face occupied by upper third (trichion to glabella)',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.upperThirdProportion,
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
    customCurve: FACEIQ_BEZIER_CURVES.bitemporalWidth,
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
    customCurve: FACEIQ_BEZIER_CURVES.cheekboneHeight,
  },

  cheekFullness: {
    id: 'cheekFullness',
    name: 'Cheek Fullness',
    category: 'Midface/Face Shape',
    unit: 'ratio',
    idealMin: 1.0,
    idealMax: 1.8,
    rangeMin: 0.3,
    rangeMax: 4.0,
    decayRate: 1.2,
    maxScore: 10,
    weight: 0.02,
    description: 'Malar convexity - measures cheek volume/fullness relative to face width',
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
    decayRate: 0.15,  // FaceIQ parity: was 13.2 (88x too harsh)
    maxScore: 25,  // Special: higher max score
    weight: 0.05,
    description: 'Total face height divided by cheek width',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.totalFacialWidthToHeight,
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
    decayRate: 0.15,  // FaceIQ parity: was 31.6 (210x too harsh!)
    maxScore: 12.5,  // FaceIQ: medium-high priority
    weight: 0.04,
    description: 'Midface width to height ratio for facial balance',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.midfaceRatio,
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
    customCurve: FACEIQ_BEZIER_CURVES.jawSlope,
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
    customCurve: FACEIQ_BEZIER_CURVES.jawFrontalAngle,
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
    customCurve: FACEIQ_BEZIER_CURVES.bigonialWidth,
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
    decayRate: 0.15,  // FaceIQ parity: was 25.0 (167x too harsh)
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
    idealMin: 4.0,   // Updated: 4-8° is peak "hunter eyes"
    idealMax: 8.0,
    rangeMin: -5,
    rangeMax: 20,
    decayRate: 0.15,  // FaceIQ parity: was 1.5 (10x too harsh)
    maxScore: 10,
    weight: 0.04,
    description: 'Angle of eye from inner to outer canthus. Positive tilt is attractive.',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.lateralCanthalTilt,
    // DIRECTIONAL SCORING: Higher (positive) tilt is better
    // - Ideal: 4-8° (attractive upswept eyes / "hunter eyes")
    // - Good: 0-4° (neutral to slight positive - still attractive)
    // - Weak: < 0° (negative/droopy tilt - only this is a true weakness)
    polarity: 'higher_is_better',
    safeFloor: 0.0,       // Neutral tilt - anything above is acceptable
    softZoneScore: 8.0,   // "Good" score for 0-4° range
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
    customCurve: FACEIQ_BEZIER_CURVES.eyeAspectRatio,
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
    decayRate: 0.12,  // FaceIQ parity: was 2.5 (21x too harsh)
    maxScore: 10,
    weight: 0.03,
    description: 'Intercanthal distance as percentage of bizygomatic width',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.eyeSeparationRatio,
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
    decayRate: 0.12,  // FaceIQ parity: was 12.0 (100x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Mouth width divided by interpupillary distance',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.interpupillaryMouthWidthRatio,
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
    decayRate: 0.15,  // FaceIQ parity: was 20.0 (133x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Intercanthal distance should equal one eye width',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.oneEyeApartTest,
  },

  tearTroughDepth: {
    id: 'tearTroughDepth',
    name: 'Tear Trough Depth',
    category: 'Eyes',
    unit: 'mm',
    idealMin: 0.0,
    idealMax: 1.5,
    rangeMin: 0.0,
    rangeMax: 4.0,
    decayRate: 3.0,
    maxScore: 10,
    weight: 0.03,
    description: 'Under-eye hollow depth (infraorbital depression). Lower is better for youthfulness.',
    profileType: 'front',
    polarity: 'lower_is_better',
    safeCeiling: 1.5,  // White standard
    softZoneScore: 7.5,
  },

  upperEyelidExposure: {
    id: 'upperEyelidExposure',
    name: 'Upper Eyelid Exposure',
    category: 'Eyes',
    unit: 'mm',
    idealMin: 0.5,
    idealMax: 2.5,
    rangeMin: 0.0,
    rangeMax: 5.0,
    decayRate: 2.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Visible upper eyelid platform. Too little creates hooded eyes.',
    profileType: 'front',
    polarity: 'balanced',
  },

  // EYEBROW MEASUREMENTS
  eyebrowThickness: {
    id: 'eyebrowThickness',
    name: 'Eyebrow Thickness',
    category: 'Upper Third',
    unit: 'mm',
    idealMin: 2.0,
    idealMax: 4.0,
    rangeMin: 1.0,
    rangeMax: 6.0,
    decayRate: 2.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Eyebrow density and thickness. Higher values indicate fuller, denser brows.',
    profileType: 'front',
    polarity: 'balanced',
  },

  eyebrowDistance: {
    id: 'eyebrowDistance',
    name: 'Inter-Eyebrow Distance',
    category: 'Upper Third',
    unit: 'mm',
    idealMin: 15,
    idealMax: 25,
    rangeMin: 5,
    rangeMax: 40,
    decayRate: 3.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Distance between inner edges of eyebrows. Too low creates unibrow (synophrys).',
    profileType: 'front',
    polarity: 'balanced',
  },

  browLengthRatio: {
    id: 'browLengthRatio',
    name: 'Brow Length to Face Width Ratio',
    category: 'Upper Third',
    unit: 'ratio',  // FaceIQ: ratio not percent
    idealMin: 0.69,
    idealMax: 0.76,
    rangeMin: 0.3,
    rangeMax: 1.1,
    decayRate: 1.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Eyebrow length divided by face width',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.browLengthToFaceWidth,
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
    customCurve: FACEIQ_BEZIER_CURVES.eyebrowTilt,
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
    decayRate: 0.15,  // FaceIQ parity: was 8.0 (53x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Distance from brow to eye relative to eye height',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.eyebrowLowSetedness,
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
    decayRate: 0.25,  // FaceIQ parity: was 0.5 (2x too harsh)
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
    decayRate: 0.12,  // FaceIQ parity: was 12.0 (100x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Alar width should roughly equal intercanthal distance',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.intercanthalNasalRatio,
  },

  noseBridgeWidth: {
    id: 'noseBridgeWidth',
    name: 'Nose Bridge to Nose Width',
    category: 'Nose',
    unit: 'ratio',
    idealMin: 2.06,  // FaceIQ: ratio of bridge to alar width
    idealMax: 2.14,
    rangeMin: 1.05,
    rangeMax: 3.0,
    decayRate: 0.15,  // FaceIQ parity: was 15.0 (100x too harsh)
    maxScore: 10,
    weight: 0.01,
    description: 'Ratio of nose bridge width to alar base width',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.noseBridgeToNoseWidth,
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
    customCurve: FACEIQ_BEZIER_CURVES.noseTipPosition,
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
    decayRate: 0.18,  // FaceIQ parity: was 18.0 (100x too harsh)
    maxScore: 10,
    weight: 0.03,
    description: 'Mouth width divided by nose width',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.mouthToNoseWidthRatio,
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
    decayRate: 0.20,  // FaceIQ parity: was 8.0 (40x too harsh)
    maxScore: 7.5,  // FaceIQ: medium priority
    weight: 0.02,
    description: 'Lower lip height divided by upper lip height',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.lipRatio,
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
    customCurve: FACEIQ_BEZIER_CURVES.cupidsBowDepth,
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
    customCurve: FACEIQ_BEZIER_CURVES.mouthCornerPosition,
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
    decayRate: 0.10,  // FaceIQ parity: was 10.0 (100x too harsh)
    maxScore: 12.5,  // FaceIQ: medium-high priority
    weight: 0.02,
    description: 'Chin height divided by philtrum length',
    profileType: 'front',
    customCurve: FACEIQ_BEZIER_CURVES.chinToPhiltrumRatio,
  },

  chinWidth: {
    id: 'chinWidth',
    name: 'Chin Width',
    category: 'Chin',
    unit: 'percent',
    idealMin: 35,
    idealMax: 45,
    rangeMin: 25,
    rangeMax: 55,
    decayRate: 1.2,
    maxScore: 10,
    weight: 0.02,
    description: 'Horizontal width of the chin (mental protuberance) as percentage of face width',
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
    customCurve: FACEIQ_BEZIER_CURVES.iaaJfaDeviation,
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
    customCurve: FACEIQ_BEZIER_CURVES.ipsilateralAlarAngle,
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
    customCurve: FACEIQ_BEZIER_CURVES.earProtrusionAngle,
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
    customCurve: FACEIQ_BEZIER_CURVES.earProtrusionRatio,
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
    customCurve: FACEIQ_BEZIER_CURVES.neckWidth,
  },

  // ==========================================
  // SIDE PROFILE MEASUREMENTS (38)
  // ==========================================

  gonialAngle: {
    id: 'gonialAngle',
    name: 'Gonial Angle',
    category: 'Occlusion/Jaw Growth',
    unit: 'degrees',
    idealMin: 115,  // FaceIQ: 115-121°
    idealMax: 121,
    rangeMin: 90,
    rangeMax: 145,
    decayRate: 0.08,  // FaceIQ parity: was 0.8 (10x too harsh)
    maxScore: 10,
    weight: 0.04,
    description: 'Angle at the jaw corner (gonion)',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.gonialAngle,
  },

  nasolabialAngle: {
    id: 'nasolabialAngle',
    name: 'Nasolabial Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 97,  // FaceIQ Bezier curve peak: 97-114°
    idealMax: 114,
    rangeMin: 75,
    rangeMax: 120,
    decayRate: 0.15,  // FaceIQ parity: was 0.6 (4x too harsh)
    maxScore: 10,
    weight: 0.03,
    description: 'Angle between columella and upper lip',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.nasolabialAngle,
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
    customCurve: FACEIQ_BEZIER_CURVES.nasofrontalAngle,
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
    customCurve: FACEIQ_BEZIER_CURVES.nasofacialAngle,
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
    customCurve: FACEIQ_BEZIER_CURVES.nasomentalAngle,
  },

  nasalTipAngle: {
    id: 'nasalTipAngle',
    name: 'Nasal Tip Angle',
    category: 'Nose',
    unit: 'degrees',
    idealMin: 128.5,  // FaceIQ: 128.5-138.5°
    idealMax: 138.5,
    rangeMin: 90,
    rangeMax: 170,
    decayRate: 0.8,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle of the nose tip',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.nasalTipAngle,
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
    decayRate: 0.15,  // FaceIQ parity: was 20.0 (133x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Nose projection relative to nasal length (Goode ratio)',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.nasalProjection,
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
    decayRate: 0.20,  // FaceIQ parity: was 15.0 (75x too harsh)
    maxScore: 10,
    weight: 0.01,
    description: 'Nose width to height ratio from side view',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.nasalWToHRatio,
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
    customCurve: FACEIQ_BEZIER_CURVES.noseTipRotationAngle,
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
    customCurve: FACEIQ_BEZIER_CURVES.frankfortTipAngle,
  },

  mentolabialAngle: {
    id: 'mentolabialAngle',
    name: 'Mentolabial Angle',
    category: 'Lips',
    unit: 'degrees',
    idealMin: 111,  // FaceIQ: 111-127°
    idealMax: 127,
    rangeMin: 20,
    rangeMax: 200,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle at the labiomental fold',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.mentolabialAngle,
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
    customCurve: FACEIQ_BEZIER_CURVES.zAngle,
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
    customCurve: FACEIQ_BEZIER_CURVES.submentalCervicalAngle,
  },

  facialConvexityGlabella: {
    id: 'facialConvexityGlabella',
    name: 'Facial Convexity (Glabella)',
    category: 'Midface/Face Shape',
    unit: 'degrees',
    idealMin: 170,  // FaceIQ Bezier curve: 170-175°
    idealMax: 175,
    rangeMin: 150,
    rangeMax: 185,
    decayRate: 0.4,
    maxScore: 10,
    weight: 0.03,
    description: 'Facial convexity angle using glabella',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.facialConvexityGlabella,
  },

  facialConvexityNasion: {
    id: 'facialConvexityNasion',
    name: 'Facial Convexity (Nasion)',
    category: 'Midface/Face Shape',
    unit: 'degrees',
    idealMin: 163,  // FaceIQ: 163-166°
    idealMax: 166,
    rangeMin: 130,
    rangeMax: 190,
    decayRate: 0.4,
    maxScore: 10,
    weight: 0.02,
    description: 'Facial convexity angle using nasion',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.facialConvexityNasion,
  },

  totalFacialConvexity: {
    id: 'totalFacialConvexity',
    name: 'Total Facial Convexity',
    category: 'Midface/Face Shape',
    unit: 'degrees',
    idealMin: 140,  // FaceIQ Bezier curve: 140-147°
    idealMax: 147,
    rangeMin: 120,
    rangeMax: 160,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.03,
    description: 'Complete facial profile convexity measurement',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.totalFacialConvexity,
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
    decayRate: 0.15,  // FaceIQ parity: was 8.0 (53x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Facial depth divided by facial height',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.facialDepthToHeightRatio,
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
    customCurve: FACEIQ_BEZIER_CURVES.anteriorFacialDepth,
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
    customCurve: FACEIQ_BEZIER_CURVES.interiorMidfaceProjectionAngle,
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
    idealMin: 15,  // FaceIQ: 15-22°
    idealMax: 22,
    rangeMin: -15,
    rangeMax: 55,
    decayRate: 0.12,  // FaceIQ parity: was 0.8 (7x too harsh)
    maxScore: 10,
    weight: 0.03,
    description: 'Angle of mandibular plane to Frankfort plane',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.mandibularPlaneAngle,
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
    decayRate: 0.15,  // FaceIQ parity: was 15.0 (100x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Ramus height divided by mandible length',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.ramusToMandibleRatio,
  },

  gonionToMouthLine: {
    id: 'gonionToMouthLine',
    name: 'Gonion to Mouth Line',
    category: 'Jaw Shape',
    unit: 'mm',
    idealMin: 15,  // FaceIQ: 15-45mm
    idealMax: 45,
    rangeMin: -20,
    rangeMax: 65,
    decayRate: 0.5,
    maxScore: 10,
    weight: 0.02,
    description: 'Distance from gonion to mouth level line',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.gonionToMouthLine,
  },

  // E-LINE MEASUREMENTS
  eLineUpperLip: {
    id: 'eLineUpperLip',
    name: 'Upper Lip E-Line Position',
    category: 'Lips',
    unit: 'mm',
    idealMin: 1.5,  // FaceIQ: positive = in front of E-line
    idealMax: 5.5,
    rangeMin: -8,
    rangeMax: 14,
    decayRate: 0.30,  // FaceIQ parity: was 1.0 (3x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Upper lip distance from E-line (Ricketts). Positive = in front.',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.eLineUpperLip,
  },

  eLineLowerLip: {
    id: 'eLineLowerLip',
    name: 'Lower Lip E-Line Position',
    category: 'Lips',
    unit: 'mm',
    idealMin: 1.4,  // FaceIQ: positive = in front of E-line
    idealMax: 4.1,
    rangeMin: -8,
    rangeMax: 12,
    decayRate: 0.30,  // FaceIQ parity: was 1.0 (3x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Lower lip distance from E-line (Ricketts). Positive = in front.',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.eLineLowerLip,
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
    customCurve: FACEIQ_BEZIER_CURVES.sLineUpperLip,
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
    decayRate: 0.25,  // FaceIQ parity: was 3.0 (12x too harsh)
    maxScore: 10,
    weight: 0.01,
    description: 'Lower lip distance from S-line (Steiner)',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.sLineLowerLip,
  },

  // BURSTONE LINE
  burstoneUpperLip: {
    id: 'burstoneUpperLip',
    name: 'Upper Lip Burstone Line',
    category: 'Lips',
    unit: 'mm',
    idealMin: -4.7,  // FaceIQ: negative = behind Burstone line
    idealMax: -2.3,
    rangeMin: -15,
    rangeMax: 10,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Upper lip to Burstone line distance. Negative = behind.',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.burstoneUpperLip,
  },

  burstoneLowerLip: {
    id: 'burstoneLowerLip',
    name: 'Lower Lip Burstone Line',
    category: 'Lips',
    unit: 'mm',
    idealMin: -2.8,  // FaceIQ: negative = behind Burstone line
    idealMax: -1.2,
    rangeMin: -10,
    rangeMax: 10,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.01,
    description: 'Lower lip to Burstone line distance. Negative = behind.',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.burstoneLowerLip,
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
    customCurve: FACEIQ_BEZIER_CURVES.holdawayHLine,
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
    customCurve: FACEIQ_BEZIER_CURVES.recessionRelativeToFrankfort,
  },

  // FOREHEAD
  browridgeInclinationAngle: {
    id: 'browridgeInclinationAngle',
    name: 'Browridge Inclination Angle',
    category: 'Upper Third',
    unit: 'degrees',
    idealMin: 15,  // FaceIQ: 15-22°
    idealMax: 22,
    rangeMin: -5,
    rangeMax: 46,
    decayRate: 1.0,
    maxScore: 10,
    weight: 0.02,
    description: 'Angle of the brow ridge from profile',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.browridgeInclinationAngle,
  },

  upperForeheadSlope: {
    id: 'upperForeheadSlope',
    name: 'Upper Forehead Slope',
    category: 'Upper Third',
    unit: 'degrees',
    idealMin: 0,  // FaceIQ: 0-2°
    idealMax: 2,
    rangeMin: -15,
    rangeMax: 15,
    decayRate: 1.2,
    maxScore: 10,
    weight: 0.01,
    description: 'Slope angle of the upper forehead',
    profileType: 'side',
    customCurve: FACEIQ_BEZIER_CURVES.upperForeheadSlope,
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
    customCurve: FACEIQ_BEZIER_CURVES.orbitalVector,
  },

  skinUniformity: {
    id: 'skinUniformity',
    name: 'Skin Uniformity',
    category: 'Skin Quality',
    unit: 'ratio',
    idealMin: 0.90,
    idealMax: 1.00,
    rangeMin: 0.50,
    rangeMax: 1.00,
    decayRate: 0.20,  // FaceIQ parity: was 5.0 (25x too harsh)
    maxScore: 10,
    weight: 0.02,
    description: 'Skin tone evenness and hyperpigmentation. 1.0 = perfectly uniform.',
    profileType: 'front',
    polarity: 'higher_is_better',
    safeFloor: 0.85,  // Acceptable uniformity threshold
    softZoneScore: 7.5,
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
  cheekFullness: [
    { category: 'Midface/Face Shape', flawName: 'Hollow/Gaunt midface', confidence: 'confirmed', reasoning: 'Reduced cheek fullness indicates volume loss or hollow cheeks. This disrupts facial harmony by creating a gaunt or aged appearance, particularly important in South Asian and East Asian beauty standards.' },
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
    { x: 1.83, y: 5.83, leftHandleX: 1.8, leftHandleY: 4.64, rightHandleX: 1.84, rightHandleY: 6.85 },
    { x: 1.89, y: 8.7, leftHandleX: 1.88, leftHandleY: 8.3, rightHandleX: 1.92, rightHandleY: 9.5 },
    { x: 1.96, y: 10, leftHandleX: 1.96, leftHandleY: 10, rightHandleX: 1.96, rightHandleY: 10, fixed: true },
    { x: 2, y: 10, leftHandleX: 2, leftHandleY: 10, rightHandleX: 2, rightHandleY: 10 },
    { x: 2.07, y: 8.7, leftHandleX: 2.04, leftHandleY: 9.5, rightHandleX: 2.08, rightHandleY: 8.3 },
    { x: 2.13, y: 5.83, leftHandleX: 2.12, leftHandleY: 6.85, rightHandleX: 2.16, rightHandleY: 4.64 },
    { x: 2.19, y: 3.07, leftHandleX: 2.17, leftHandleY: 3.88, rightHandleX: 2.22, rightHandleY: 2.15 },
    { x: 2.28, y: 1.05, leftHandleX: 2.25, leftHandleY: 1.58, rightHandleX: 2.34, rightHandleY: 0.36 },
    { x: 2.47, y: 0, leftHandleX: 2.41, leftHandleY: 0, rightHandleX: 2.52, rightHandleY: 0 },
  ],
  lowerThirdProportion: [
    { x: 25.6, y: 0, leftHandleX: 24.8, leftHandleY: 0, rightHandleX: 26.4, rightHandleY: 0 },
    { x: 28.01, y: 1.58, leftHandleX: 27.23, leftHandleY: 0.53, rightHandleX: 28.27, rightHandleY: 1.97 },
    { x: 28.83, y: 3.21, leftHandleX: 28.62, leftHandleY: 2.59, rightHandleX: 29.03, rightHandleY: 3.76 },
    { x: 29.63, y: 5.85, leftHandleX: 29.38, leftHandleY: 4.64, rightHandleX: 29.84, rightHandleY: 6.61 },
    { x: 30.27, y: 8.56, leftHandleX: 30.1, leftHandleY: 7.71, rightHandleX: 30.52, rightHandleY: 9.42 },
    { x: 31, y: 10, leftHandleX: 30.88, leftHandleY: 10, rightHandleX: 31.13, rightHandleY: 10, fixed: true },
    { x: 33.5, y: 10, leftHandleX: 33.38, leftHandleY: 10, rightHandleX: 33.63, rightHandleY: 10 },
    { x: 34.23, y: 8.56, leftHandleX: 33.98, leftHandleY: 9.42, rightHandleX: 34.4, rightHandleY: 7.71 },
    { x: 34.87, y: 5.85, leftHandleX: 34.66, leftHandleY: 6.61, rightHandleX: 35.12, rightHandleY: 4.64 },
    { x: 35.67, y: 3.21, leftHandleX: 35.47, leftHandleY: 3.76, rightHandleX: 35.88, rightHandleY: 2.59 },
    { x: 36.49, y: 1.58, leftHandleX: 36.23, leftHandleY: 1.97, rightHandleX: 37.27, rightHandleY: 0.53 },
    { x: 38.9, y: 0, leftHandleX: 38.1, leftHandleY: 0, rightHandleX: 39.7, rightHandleY: 0 },
  ],
  eyeAspectRatio: [
    { x: 1.44, y: 0, leftHandleX: 1.18, leftHandleY: 0, rightHandleX: 1.75, rightHandleY: 0.38 },
    { x: 2.07, y: 1.66, leftHandleX: 1.96, leftHandleY: 1.08, rightHandleX: 2.24, rightHandleY: 2.63 },
    { x: 2.42, y: 4.34, leftHandleX: 2.35, leftHandleY: 3.6, rightHandleX: 2.52, rightHandleY: 5.5 },
    { x: 2.71, y: 7.96, leftHandleX: 2.65, leftHandleY: 7.13, rightHandleX: 2.8, rightHandleY: 9.08 },
    { x: 3, y: 10, leftHandleX: 2.98, leftHandleY: 10, rightHandleX: 3.03, rightHandleY: 10, fixed: true },
    { x: 3.5, y: 10, leftHandleX: 3.48, leftHandleY: 10, rightHandleX: 3.53, rightHandleY: 10 },
    { x: 3.79, y: 7.96, leftHandleX: 3.7, leftHandleY: 9.08, rightHandleX: 3.85, rightHandleY: 7.13 },
    { x: 4.08, y: 4.34, leftHandleX: 3.98, leftHandleY: 5.5, rightHandleX: 4.15, rightHandleY: 3.6 },
    { x: 4.43, y: 1.66, leftHandleX: 4.26, leftHandleY: 2.63, rightHandleX: 4.54, rightHandleY: 1.08 },
    { x: 5.06, y: 0, leftHandleX: 4.75, leftHandleY: 0.38, rightHandleX: 5.32, rightHandleY: 0 },
  ],
  totalFacialWidthToHeight: [
    { x: 1.05, y: 0, leftHandleX: 1.01, leftHandleY: 0, rightHandleX: 1.09, rightHandleY: 0.2 },
    { x: 1.17, y: 1.41, leftHandleX: 1.15, leftHandleY: 1, rightHandleX: 1.19, rightHandleY: 1.85 },
    { x: 1.25, y: 3.86, leftHandleX: 1.22, leftHandleY: 2.63, rightHandleX: 1.27, rightHandleY: 4.72 },
    { x: 1.29, y: 6.01, leftHandleX: 1.28, leftHandleY: 5.44, rightHandleX: 1.3, rightHandleY: 7.03 },
    { x: 1.32, y: 8.88, leftHandleX: 1.31, leftHandleY: 8.02, rightHandleX: 1.33, rightHandleY: 9.76 },
    { x: 1.34, y: 10, leftHandleX: 1.34, leftHandleY: 10, rightHandleX: 1.34, rightHandleY: 10, fixed: true },
    { x: 1.37, y: 10, leftHandleX: 1.37, leftHandleY: 10, rightHandleX: 1.37, rightHandleY: 10 },
    { x: 1.39, y: 8.88, leftHandleX: 1.38, leftHandleY: 9.76, rightHandleX: 1.4, rightHandleY: 8.02 },
    { x: 1.42, y: 6.01, leftHandleX: 1.41, leftHandleY: 7.03, rightHandleX: 1.43, rightHandleY: 5.44 },
    { x: 1.46, y: 3.86, leftHandleX: 1.44, leftHandleY: 4.72, rightHandleX: 1.49, rightHandleY: 2.63 },
    { x: 1.54, y: 1.41, leftHandleX: 1.52, leftHandleY: 1.85, rightHandleX: 1.56, rightHandleY: 1 },
    { x: 1.66, y: 0, leftHandleX: 1.62, leftHandleY: 0.2, rightHandleX: 1.7, rightHandleY: 0 },
  ],
  cheekboneHeight: [
    { x: 2.6, y: 0.83, leftHandleX: 2.6, leftHandleY: 0.83, rightHandleX: 2.64, rightHandleY: 0.83 },
    { x: 2.77, y: 6.25, leftHandleX: 2.73, leftHandleY: 6.25, rightHandleX: 2.81, rightHandleY: 6.25 },
    { x: 3.2, y: 6.25, leftHandleX: 3.16, leftHandleY: 6.25, rightHandleX: 3.24, rightHandleY: 6.25 },
    { x: 3.38, y: 0.83, leftHandleX: 3.34, leftHandleY: 0.83, rightHandleX: 3.38, rightHandleY: 0.83 },
    { x: 32, y: 0, leftHandleX: 18.43, leftHandleY: 0, rightHandleX: 29.43, rightHandleY: 0 },
    { x: 44.64, y: 0, leftHandleX: 44.64, leftHandleY: 0, rightHandleX: 50.14, rightHandleY: 0 },
    { x: 58.39, y: 0.93, leftHandleX: 53.04, leftHandleY: 0.25, rightHandleX: 64.02, rightHandleY: 1.71 },
    { x: 70.54, y: 3.66, leftHandleX: 67.68, leftHandleY: 2.7, rightHandleX: 72.33, rightHandleY: 4.65 },
    { x: 74.83, y: 6.25, leftHandleX: 74.11, leftHandleY: 5.56, rightHandleX: 75.63, rightHandleY: 6.82 },
    { x: 78.49, y: 8.38, leftHandleX: 77.6, leftHandleY: 7.77, rightHandleX: 79.83, rightHandleY: 8.97 },
    { x: 83, y: 10, leftHandleX: 82.05, leftHandleY: 10, rightHandleX: 83.95, rightHandleY: 10 },
    { x: 83, y: 10, leftHandleX: 82.15, leftHandleY: 10, rightHandleX: 83.85, rightHandleY: 10 },
    { x: 100, y: 10, leftHandleX: 99.05, leftHandleY: 10, rightHandleX: 100.95, rightHandleY: 10 },
    { x: 100, y: 10, leftHandleX: 99.15, leftHandleY: 10, rightHandleX: 100.85, rightHandleY: 10, fixed: true },
    { x: 104.51, y: 8.38, leftHandleX: 103.17, leftHandleY: 8.97, rightHandleX: 105.4, rightHandleY: 7.77 },
    { x: 108.17, y: 6.25, leftHandleX: 107.37, leftHandleY: 6.82, rightHandleX: 108.89, rightHandleY: 5.56 },
    { x: 112.46, y: 3.66, leftHandleX: 110.67, leftHandleY: 4.65, rightHandleX: 115.32, rightHandleY: 2.7 },
    { x: 124.61, y: 0.93, leftHandleX: 118.98, leftHandleY: 1.71, rightHandleX: 129.96, rightHandleY: 0.25 },
    { x: 138.36, y: 0, leftHandleX: 132.86, leftHandleY: 0, rightHandleX: 138.36, rightHandleY: 0 },
    { x: 151, y: 0, leftHandleX: 153.57, leftHandleY: 0, rightHandleX: 164.57, rightHandleY: 0 },
    { x: 179.62, y: 0.83, leftHandleX: 179.62, leftHandleY: 0.83, rightHandleX: 179.66, rightHandleY: 0.83 },
    { x: 179.8, y: 6.25, leftHandleX: 179.76, leftHandleY: 6.25, rightHandleX: 179.84, rightHandleY: 6.25 },
    { x: 180.23, y: 6.25, leftHandleX: 180.19, leftHandleY: 6.25, rightHandleX: 180.27, rightHandleY: 6.25 },
    { x: 180.4, y: 0.83, leftHandleX: 180.36, leftHandleY: 0.83, rightHandleX: 180.4, rightHandleY: 0.83 },
  ],
  ipsilateralAlarAngle: [
    { x: 67.88, y: 0, leftHandleX: 64.63, leftHandleY: 0, rightHandleX: 71.13, rightHandleY: 0 },
    { x: 75.23, y: 1.12, leftHandleX: 72.77, leftHandleY: 0.42, rightHandleX: 76.44, rightHandleY: 1.55 },
    { x: 78.96, y: 3.39, leftHandleX: 77.96, leftHandleY: 2.33, rightHandleX: 79.8, rightHandleY: 4.16 },
    { x: 81.43, y: 6.17, leftHandleX: 80.69, leftHandleY: 5.12, rightHandleX: 82.16, rightHandleY: 6.95 },
    { x: 83.85, y: 8.74, leftHandleX: 82.9, leftHandleY: 7.79, rightHandleX: 84.48, rightHandleY: 9.42 },
    { x: 86.5, y: 10, leftHandleX: 86.2, leftHandleY: 10, rightHandleX: 86.8, rightHandleY: 10, fixed: true },
    { x: 92.5, y: 10, leftHandleX: 92.2, leftHandleY: 10, rightHandleX: 92.8, rightHandleY: 10 },
    { x: 95.15, y: 8.74, leftHandleX: 94.52, leftHandleY: 9.42, rightHandleX: 96.1, rightHandleY: 7.79 },
    { x: 97.57, y: 6.17, leftHandleX: 96.84, leftHandleY: 6.95, rightHandleX: 98.31, rightHandleY: 5.12 },
    { x: 100.04, y: 3.39, leftHandleX: 99.2, leftHandleY: 4.16, rightHandleX: 101.04, rightHandleY: 2.33 },
    { x: 103.77, y: 1.12, leftHandleX: 102.56, leftHandleY: 1.55, rightHandleX: 106.23, rightHandleY: 0.42 },
    { x: 111.12, y: 0, leftHandleX: 107.87, leftHandleY: 0, rightHandleX: 114.37, rightHandleY: 0 },
  ],
  midfaceRatio: [
    { x: 0.59, y: 0, leftHandleX: 0.54, leftHandleY: 0, rightHandleX: 0.66, rightHandleY: 0.21 },
    { x: 0.75, y: 1.2, leftHandleX: 0.71, leftHandleY: 0.7, rightHandleX: 0.8, rightHandleY: 2 },
    { x: 0.83, y: 3.45, leftHandleX: 0.82, leftHandleY: 2.86, rightHandleX: 0.85, rightHandleY: 4.36 },
    { x: 0.87, y: 5.98, leftHandleX: 0.86, leftHandleY: 5.24, rightHandleX: 0.88, rightHandleY: 6.74 },
    { x: 0.91, y: 8.34, leftHandleX: 0.9, leftHandleY: 7.66, rightHandleX: 0.93, rightHandleY: 9.52 },
    { x: 0.97, y: 10, leftHandleX: 0.97, leftHandleY: 10, rightHandleX: 0.97, rightHandleY: 10, fixed: true },
    { x: 1, y: 10, leftHandleX: 1, leftHandleY: 10, rightHandleX: 1, rightHandleY: 10 },
    { x: 1.06, y: 8.34, leftHandleX: 1.04, leftHandleY: 9.52, rightHandleX: 1.07, rightHandleY: 7.66 },
    { x: 1.1, y: 5.98, leftHandleX: 1.09, leftHandleY: 6.74, rightHandleX: 1.11, rightHandleY: 5.24 },
    { x: 1.14, y: 3.45, leftHandleX: 1.12, leftHandleY: 4.36, rightHandleX: 1.15, rightHandleY: 2.86 },
    { x: 1.22, y: 1.2, leftHandleX: 1.17, leftHandleY: 2, rightHandleX: 1.26, rightHandleY: 0.7 },
    { x: 1.38, y: 0, leftHandleX: 1.31, leftHandleY: 0.21, rightHandleX: 1.43, rightHandleY: 0 },
  ],
  chinToPhiltrumRatio: [
    { x: 0.32, y: 0, leftHandleX: 0.11, leftHandleY: 0, rightHandleX: 0.53, rightHandleY: 0 },
    { x: 1.11, y: 0.53, leftHandleX: 0.9, leftHandleY: 0, rightHandleX: 1.34, rightHandleY: 1.14 },
    { x: 1.65, y: 3.22, leftHandleX: 1.48, leftHandleY: 1.64, rightHandleX: 1.72, rightHandleY: 4.15 },
    { x: 1.82, y: 6.09, leftHandleX: 1.8, leftHandleY: 5.54, rightHandleX: 1.86, rightHandleY: 7.18 },
    { x: 1.97, y: 8.9, leftHandleX: 1.93, leftHandleY: 8.22, rightHandleX: 2.04, rightHandleY: 9.74 },
    { x: 2.15, y: 10, leftHandleX: 2.13, leftHandleY: 10, rightHandleX: 2.17, rightHandleY: 10, fixed: true },
    { x: 2.45, y: 10, leftHandleX: 2.43, leftHandleY: 10, rightHandleX: 2.47, rightHandleY: 10 },
    { x: 2.63, y: 8.9, leftHandleX: 2.56, leftHandleY: 9.74, rightHandleX: 2.67, rightHandleY: 8.22 },
    { x: 2.78, y: 6.09, leftHandleX: 2.74, leftHandleY: 7.18, rightHandleX: 2.8, rightHandleY: 5.54 },
    { x: 2.95, y: 3.22, leftHandleX: 2.88, leftHandleY: 4.15, rightHandleX: 3.12, rightHandleY: 1.64 },
    { x: 3.49, y: 0.53, leftHandleX: 3.26, leftHandleY: 1.14, rightHandleX: 3.7, rightHandleY: 0 },
    { x: 4.28, y: 0, leftHandleX: 4.07, leftHandleY: 0, rightHandleX: 4.49, rightHandleY: 0 },
  ],
  jawSlope: [
    { x: 113.33, y: 0, leftHandleX: 110.33, leftHandleY: 0, rightHandleX: 116.33, rightHandleY: 0 },
    { x: 124.59, y: 1.67, leftHandleX: 121.47, leftHandleY: 0.78, rightHandleX: 126.69, rightHandleY: 2.23 },
    { x: 129.76, y: 3.62, leftHandleX: 128, leftHandleY: 2.79, rightHandleX: 130.83, rightHandleY: 4.12 },
    { x: 133.32, y: 5.91, leftHandleX: 132.24, leftHandleY: 5.06, rightHandleX: 134.29, rightHandleY: 6.55 },
    { x: 137.56, y: 8.84, leftHandleX: 136.24, leftHandleY: 8.08, rightHandleX: 138.43, rightHandleY: 9.42 },
    { x: 140, y: 10, leftHandleX: 139.88, leftHandleY: 10, rightHandleX: 140.13, rightHandleY: 10, fixed: true },
    { x: 142.5, y: 10, leftHandleX: 142.38, leftHandleY: 10, rightHandleX: 142.63, rightHandleY: 10 },
    { x: 144.94, y: 8.84, leftHandleX: 144.07, leftHandleY: 9.42, rightHandleX: 146.26, rightHandleY: 8.08 },
    { x: 149.18, y: 5.91, leftHandleX: 148.21, leftHandleY: 6.55, rightHandleX: 150.26, rightHandleY: 5.06 },
    { x: 152.74, y: 3.62, leftHandleX: 151.67, leftHandleY: 4.12, rightHandleX: 154.5, rightHandleY: 2.79 },
    { x: 157.91, y: 1.67, leftHandleX: 155.81, leftHandleY: 2.23, rightHandleX: 161.03, rightHandleY: 0.78 },
    { x: 169.17, y: 0, leftHandleX: 166.17, leftHandleY: 0, rightHandleX: 172.17, rightHandleY: 0 },
  ],
  lateralCanthalTilt: [
    { x: -4.58, y: 0, leftHandleX: -6.23, leftHandleY: 0, rightHandleX: -2.65, rightHandleY: 0.57 },
    { x: -0.54, y: 2.02, leftHandleX: -1.32, leftHandleY: 1.45, rightHandleX: 0.45, rightHandleY: 2.78 },
    { x: 1.92, y: 4.44, leftHandleX: 1.22, leftHandleY: 3.58, rightHandleX: 2.4, rightHandleY: 5.01 },
    { x: 3.58, y: 6.91, leftHandleX: 3.01, leftHandleY: 6.05, rightHandleX: 3.9, rightHandleY: 7.39 },
    { x: 4.59, y: 8.55, leftHandleX: 4.16, leftHandleY: 7.91, rightHandleX: 5.07, rightHandleY: 9.38 },
    { x: 6, y: 10, leftHandleX: 5.92, leftHandleY: 10, rightHandleX: 6.09, rightHandleY: 10, fixed: true },
    { x: 7.7, y: 10, leftHandleX: 7.61, leftHandleY: 10, rightHandleX: 7.78, rightHandleY: 10 },
    { x: 9.11, y: 8.55, leftHandleX: 8.63, leftHandleY: 9.38, rightHandleX: 9.54, rightHandleY: 7.91 },
    { x: 10.12, y: 6.91, leftHandleX: 9.8, leftHandleY: 7.39, rightHandleX: 10.69, rightHandleY: 6.05 },
    { x: 11.78, y: 4.44, leftHandleX: 11.3, leftHandleY: 5.01, rightHandleX: 12.48, rightHandleY: 3.58 },
    { x: 14.24, y: 2.02, leftHandleX: 13.25, leftHandleY: 2.78, rightHandleX: 15.02, rightHandleY: 1.45 },
    { x: 18.28, y: 0, leftHandleX: 16.35, leftHandleY: 0.57, rightHandleX: 19.93, rightHandleY: 0 },
  ],
  lowerLipToUpperLipRatio: [
    { x: -0.7, y: 0, leftHandleX: -0.95, leftHandleY: 0, rightHandleX: -0.45, rightHandleY: 0 },
    { x: 0.39, y: 1.96, leftHandleX: 0.19, leftHandleY: 1.2, rightHandleX: 0.5, rightHandleY: 2.4 },
    { x: 0.74, y: 3.79, leftHandleX: 0.6, leftHandleY: 2.86, rightHandleX: 0.83, rightHandleY: 4.38 },
    { x: 0.99, y: 5.64, leftHandleX: 0.95, leftHandleY: 5.22, rightHandleX: 1.07, rightHandleY: 6.33 },
    { x: 1.25, y: 8.3, leftHandleX: 1.18, leftHandleY: 7.45, rightHandleX: 1.37, rightHandleY: 9.48 },
    { x: 1.55, y: 10, leftHandleX: 1.54, leftHandleY: 10, rightHandleX: 1.57, rightHandleY: 10, fixed: true },
    { x: 1.85, y: 10, leftHandleX: 1.84, leftHandleY: 10, rightHandleX: 1.87, rightHandleY: 10 },
    { x: 2.15, y: 8.3, leftHandleX: 2.03, leftHandleY: 9.48, rightHandleX: 2.22, rightHandleY: 7.45 },
    { x: 2.41, y: 5.64, leftHandleX: 2.33, leftHandleY: 6.33, rightHandleX: 2.45, rightHandleY: 5.22 },
    { x: 2.66, y: 3.79, leftHandleX: 2.57, leftHandleY: 4.38, rightHandleX: 2.8, rightHandleY: 2.86 },
    { x: 3.01, y: 1.96, leftHandleX: 2.9, leftHandleY: 2.4, rightHandleX: 3.21, rightHandleY: 1.2 },
    { x: 4.1, y: 0, leftHandleX: 3.85, leftHandleY: 0, rightHandleX: 4.35, rightHandleY: 0 },
  ],
  mouthWidthToNoseRatio: [
    { x: 1.04, y: 0, leftHandleX: 0.99, leftHandleY: 0, rightHandleX: 1.1, rightHandleY: 0.04 },
    { x: 1.22, y: 1.37, leftHandleX: 1.18, leftHandleY: 0.9, rightHandleX: 1.25, rightHandleY: 1.87 },
    { x: 1.29, y: 3.33, leftHandleX: 1.28, leftHandleY: 2.73, rightHandleX: 1.31, rightHandleY: 4.06 },
    { x: 1.33, y: 5.6, leftHandleX: 1.32, leftHandleY: 4.93, rightHandleX: 1.34, rightHandleY: 6.51 },
    { x: 1.36, y: 8.62, leftHandleX: 1.34, leftHandleY: 7.49, rightHandleX: 1.38, rightHandleY: 9.54 },
    { x: 1.42, y: 10, leftHandleX: 1.42, leftHandleY: 10, rightHandleX: 1.42, rightHandleY: 10, fixed: true },
    { x: 1.5, y: 10, leftHandleX: 1.5, leftHandleY: 10, rightHandleX: 1.5, rightHandleY: 10 },
    { x: 1.5, y: 10, leftHandleX: 1.5, leftHandleY: 10, rightHandleX: 1.5, rightHandleY: 10, fixed: true },
    { x: 1.56, y: 8.62, leftHandleX: 1.54, leftHandleY: 9.54, rightHandleX: 1.58, rightHandleY: 7.49 },
    { x: 1.59, y: 5.6, leftHandleX: 1.58, leftHandleY: 6.51, rightHandleX: 1.6, rightHandleY: 4.93 },
    { x: 1.63, y: 3.33, leftHandleX: 1.61, leftHandleY: 4.06, rightHandleX: 1.64, rightHandleY: 2.73 },
    { x: 1.7, y: 1.37, leftHandleX: 1.67, leftHandleY: 1.87, rightHandleX: 1.74, rightHandleY: 0.9 },
    { x: 1.88, y: 0, leftHandleX: 1.82, leftHandleY: 0.04, rightHandleX: 1.93, rightHandleY: 0 },
  ],
  jawFrontalAngle: [
    { x: 50.73, y: 0, leftHandleX: 45.48, leftHandleY: 0, rightHandleX: 55.98, rightHandleY: 0 },
    { x: 66.67, y: 1.35, leftHandleX: 62.24, leftHandleY: 0.53, rightHandleX: 70, rightHandleY: 1.9 },
    { x: 75.45, y: 4.55, leftHandleX: 74.18, leftHandleY: 3.73, rightHandleX: 76.99, rightHandleY: 5.45 },
    { x: 80.49, y: 7.89, leftHandleX: 79.05, leftHandleY: 6.84, rightHandleX: 81.77, rightHandleY: 9.05 },
    { x: 86.5, y: 10, leftHandleX: 86.2, leftHandleY: 10, rightHandleX: 86.8, rightHandleY: 10, fixed: true },
    { x: 92.5, y: 10, leftHandleX: 92.2, leftHandleY: 10, rightHandleX: 92.8, rightHandleY: 10 },
    { x: 98.51, y: 7.89, leftHandleX: 97.23, leftHandleY: 9.05, rightHandleX: 99.95, rightHandleY: 6.84 },
    { x: 103.55, y: 4.55, leftHandleX: 102.01, leftHandleY: 5.45, rightHandleX: 104.82, rightHandleY: 3.73 },
    { x: 112.33, y: 1.35, leftHandleX: 109, leftHandleY: 1.9, rightHandleX: 116.76, rightHandleY: 0.53 },
    { x: 128.27, y: 0, leftHandleX: 123.02, leftHandleY: 0, rightHandleX: 133.52, rightHandleY: 0 },
  ],
  noseBridgeToNoseWidth: [
    { x: 1.09, y: 0, leftHandleX: 0.99, leftHandleY: 0, rightHandleX: 1.19, rightHandleY: 0 },
    { x: 1.55, y: 1.86, leftHandleX: 1.48, leftHandleY: 1.18, rightHandleX: 1.62, rightHandleY: 2.37 },
    { x: 1.81, y: 5.42, leftHandleX: 1.77, leftHandleY: 4.56, rightHandleX: 1.85, rightHandleY: 6.04 },
    { x: 1.96, y: 8.86, leftHandleX: 1.94, leftHandleY: 8.12, rightHandleX: 1.99, rightHandleY: 9.75 },
    { x: 2.06, y: 10, leftHandleX: 2.06, leftHandleY: 10, rightHandleX: 2.06, rightHandleY: 10, fixed: true },
    { x: 2.06, y: 10, leftHandleX: 2.06, leftHandleY: 10, rightHandleX: 2.06, rightHandleY: 10 },
    { x: 2.14, y: 10, leftHandleX: 2.14, leftHandleY: 10, rightHandleX: 2.14, rightHandleY: 10 },
    { x: 2.14, y: 10, leftHandleX: 2.14, leftHandleY: 10, rightHandleX: 2.14, rightHandleY: 10 },
    { x: 2.24, y: 8.86, leftHandleX: 2.21, leftHandleY: 9.75, rightHandleX: 2.26, rightHandleY: 8.12 },
    { x: 2.39, y: 5.42, leftHandleX: 2.35, leftHandleY: 6.04, rightHandleX: 2.43, rightHandleY: 4.56 },
    { x: 2.65, y: 1.86, leftHandleX: 2.58, leftHandleY: 2.37, rightHandleX: 2.72, rightHandleY: 1.18 },
    { x: 3.11, y: 0, leftHandleX: 3.01, leftHandleY: 0, rightHandleX: 3.21, rightHandleY: 0 },
  ],
  browLengthToFaceWidthRatio: [
    { x: 0.3, y: 0, leftHandleX: 0.26, leftHandleY: 0, rightHandleX: 0.34, rightHandleY: 0 },
    { x: 0.45, y: 1.08, leftHandleX: 0.43, leftHandleY: 0.72, rightHandleX: 0.47, rightHandleY: 1.41 },
    { x: 0.54, y: 3.01, leftHandleX: 0.52, leftHandleY: 2.45, rightHandleX: 0.56, rightHandleY: 3.6 },
    { x: 0.61, y: 5.85, leftHandleX: 0.6, leftHandleY: 5.14, rightHandleX: 0.62, rightHandleY: 6.57 },
    { x: 0.65, y: 8.82, leftHandleX: 0.64, leftHandleY: 8.06, rightHandleX: 0.66, rightHandleY: 9.7 },
    { x: 0.69, y: 10, leftHandleX: 0.69, leftHandleY: 10, rightHandleX: 0.69, rightHandleY: 10, fixed: true },
    { x: 0.76, y: 10, leftHandleX: 0.76, leftHandleY: 10, rightHandleX: 0.76, rightHandleY: 10 },
    { x: 0.8, y: 8.82, leftHandleX: 0.79, leftHandleY: 9.7, rightHandleX: 0.81, rightHandleY: 8.06 },
    { x: 0.84, y: 5.85, leftHandleX: 0.83, leftHandleY: 6.57, rightHandleX: 0.85, rightHandleY: 5.14 },
    { x: 0.91, y: 3.01, leftHandleX: 0.89, leftHandleY: 3.6, rightHandleX: 0.93, rightHandleY: 2.45 },
    { x: 1, y: 1.08, leftHandleX: 0.98, leftHandleY: 1.41, rightHandleX: 1.02, rightHandleY: 0.72 },
    { x: 1.15, y: 0, leftHandleX: 1.11, leftHandleY: 0, rightHandleX: 1.19, rightHandleY: 0 },
  ],
  cupidsBowDepth: [
    { x: -2.43, y: 0.02, leftHandleX: -3.08, leftHandleY: 0.02, rightHandleX: -1.78, rightHandleY: 0.02 },
    { x: -0.3, y: 2.23, leftHandleX: -0.67, leftHandleY: 1.49, rightHandleX: 0.05, rightHandleY: 2.81 },
    { x: 0.97, y: 5.48, leftHandleX: 0.72, leftHandleY: 4.72, rightHandleX: 1.2, rightHandleY: 6.23 },
    { x: 1.75, y: 8.2, leftHandleX: 1.53, leftHandleY: 7.43, rightHandleX: 2, rightHandleY: 9.18 },
    { x: 2.4, y: 10, leftHandleX: 2.32, leftHandleY: 10, rightHandleX: 2.48, rightHandleY: 10, fixed: true },
    { x: 4, y: 10, leftHandleX: 3.92, leftHandleY: 10, rightHandleX: 4.08, rightHandleY: 10 },
    { x: 4.65, y: 8.2, leftHandleX: 4.4, leftHandleY: 9.18, rightHandleX: 4.87, rightHandleY: 7.43 },
    { x: 5.43, y: 5.48, leftHandleX: 5.2, leftHandleY: 6.23, rightHandleX: 5.68, rightHandleY: 4.72 },
    { x: 6.7, y: 2.23, leftHandleX: 6.35, leftHandleY: 2.81, rightHandleX: 7.07, rightHandleY: 1.49 },
    { x: 8.83, y: 0.02, leftHandleX: 8.18, leftHandleY: 0.02, rightHandleX: 9.48, rightHandleY: 0.02 },
  ],
  neckWidth: [
    { x: 61.73, y: 0, leftHandleX: 57.23, leftHandleY: 0, rightHandleX: 69.11, rightHandleY: 0.27 },
    { x: 62.97, y: 0, leftHandleX: 57.64, leftHandleY: 0, rightHandleX: 66.7, rightHandleY: 0.04 },
    { x: 74.81, y: 0.97, leftHandleX: 72.18, leftHandleY: 0.46, rightHandleX: 76.71, rightHandleY: 1.31 },
    { x: 80.81, y: 2.99, leftHandleX: 79.49, leftHandleY: 2.15, rightHandleX: 82.12, rightHandleY: 3.62 },
    { x: 84.68, y: 5.64, leftHandleX: 83.44, leftHandleY: 4.6, rightHandleX: 85.71, rightHandleY: 6.45 },
    { x: 88.19, y: 8.8, leftHandleX: 86.8, leftHandleY: 7.89, rightHandleX: 89.21, rightHandleY: 9.52 },
    { x: 92, y: 10, leftHandleX: 91.7, leftHandleY: 10, rightHandleX: 92.3, rightHandleY: 10, fixed: true },
    { x: 98, y: 10, leftHandleX: 97.7, leftHandleY: 10, rightHandleX: 98.3, rightHandleY: 10 },
    { x: 101.81, y: 8.8, leftHandleX: 100.79, leftHandleY: 9.52, rightHandleX: 103.2, rightHandleY: 7.89 },
    { x: 105.32, y: 5.64, leftHandleX: 104.29, leftHandleY: 6.45, rightHandleX: 106.56, rightHandleY: 4.6 },
    { x: 109.19, y: 2.99, leftHandleX: 107.88, leftHandleY: 3.62, rightHandleX: 110.51, rightHandleY: 2.15 },
    { x: 115.19, y: 0.97, leftHandleX: 113.29, leftHandleY: 1.31, rightHandleX: 117.82, rightHandleY: 0.46 },
    { x: 127.03, y: 0, leftHandleX: 123.3, leftHandleY: 0.04, rightHandleX: 132.36, rightHandleY: 0 },
    { x: 128.27, y: 0, leftHandleX: 120.89, leftHandleY: 0.27, rightHandleX: 132.77, rightHandleY: 0 },
  ],
  middleThirdProportion: [
    { x: 21.44, y: 0, leftHandleX: 20.29, leftHandleY: 0, rightHandleX: 23.19, rightHandleY: 0.15 },
    { x: 25.5, y: 1.35, leftHandleX: 24.18, leftHandleY: 0.53, rightHandleX: 26.17, rightHandleY: 1.79 },
    { x: 27.34, y: 3.18, leftHandleX: 26.84, leftHandleY: 2.42, rightHandleX: 27.73, rightHandleY: 3.81 },
    { x: 28.65, y: 5.88, leftHandleX: 28.33, leftHandleY: 4.91, rightHandleX: 28.98, rightHandleY: 6.65 },
    { x: 29.95, y: 8.55, leftHandleX: 29.41, leftHandleY: 7.58, rightHandleX: 30.45, rightHandleY: 9.35 },
    { x: 31.4, y: 10, leftHandleX: 31.3, leftHandleY: 10, rightHandleX: 31.5, rightHandleY: 10, fixed: true },
    { x: 33.4, y: 10, leftHandleX: 33.3, leftHandleY: 10, rightHandleX: 33.5, rightHandleY: 10 },
    { x: 34.85, y: 8.55, leftHandleX: 34.35, leftHandleY: 9.35, rightHandleX: 35.39, rightHandleY: 7.58 },
    { x: 36.15, y: 5.88, leftHandleX: 35.82, leftHandleY: 6.65, rightHandleX: 36.47, rightHandleY: 4.91 },
    { x: 37.46, y: 3.18, leftHandleX: 37.07, leftHandleY: 3.81, rightHandleX: 37.96, rightHandleY: 2.42 },
    { x: 39.3, y: 1.35, leftHandleX: 38.63, leftHandleY: 1.79, rightHandleX: 40.62, rightHandleY: 0.53 },
    { x: 43.36, y: 0, leftHandleX: 41.61, leftHandleY: 0.15, rightHandleX: 44.51, rightHandleY: 0 },
  ],
  upperThirdProportion: [
    { x: 18.75, y: 0.02, leftHandleX: 17.15, leftHandleY: 0.02, rightHandleX: 20.35, rightHandleY: 0.02 },
    { x: 23.82, y: 1.52, leftHandleX: 22.35, leftHandleY: 0.8, rightHandleX: 24.73, rightHandleY: 2.06 },
    { x: 26.05, y: 4.06, leftHandleX: 25.48, leftHandleY: 2.86, rightHandleX: 26.41, rightHandleY: 4.99 },
    { x: 27.19, y: 6.79, leftHandleX: 26.96, leftHandleY: 6.16, rightHandleX: 27.66, rightHandleY: 7.85 },
    { x: 28.54, y: 9.08, leftHandleX: 28.02, leftHandleY: 8.5, rightHandleX: 28.93, rightHandleY: 9.54 },
    { x: 30, y: 10, leftHandleX: 29.9, leftHandleY: 10, rightHandleX: 30.1, rightHandleY: 10, fixed: true },
    { x: 32, y: 10, leftHandleX: 31.9, leftHandleY: 10, rightHandleX: 32.1, rightHandleY: 10 },
    { x: 33.46, y: 9.08, leftHandleX: 33.07, leftHandleY: 9.54, rightHandleX: 33.98, rightHandleY: 8.5 },
    { x: 34.81, y: 6.79, leftHandleX: 34.34, leftHandleY: 7.85, rightHandleX: 35.04, rightHandleY: 6.16 },
    { x: 35.95, y: 4.06, leftHandleX: 35.59, leftHandleY: 4.99, rightHandleX: 36.52, rightHandleY: 2.86 },
    { x: 38.18, y: 1.52, leftHandleX: 37.27, leftHandleY: 2.06, rightHandleX: 39.65, rightHandleY: 0.8 },
    { x: 43.25, y: 0.02, leftHandleX: 41.65, leftHandleY: 0.02, rightHandleX: 44.85, rightHandleY: 0.02 },
  ],
  eyebrowLowSetedness: [
    { x: -2.78, y: 0, leftHandleX: -3.11, leftHandleY: 0, rightHandleX: -2.67, rightHandleY: 0 },
    { x: -1.94, y: 0.4, leftHandleX: -2.08, leftHandleY: 0.11, rightHandleX: -1.81, rightHandleY: 0.57 },
    { x: -1.18, y: 2.25, leftHandleX: -1.36, leftHandleY: 1.5, rightHandleX: -1.05, rightHandleY: 2.72 },
    { x: -0.79, y: 4.06, leftHandleX: -0.88, leftHandleY: 3.43, rightHandleX: -0.68, rightHandleY: 4.84 },
    { x: -0.55, y: 6.21, leftHandleX: -0.58, leftHandleY: 5.55, rightHandleX: -0.47, rightHandleY: 6.92 },
    { x: -0.28, y: 8.76, leftHandleX: -0.37, leftHandleY: 8.23, rightHandleX: -0.23, rightHandleY: 9.22 },
    { x: 0, y: 10, leftHandleX: -0.02, leftHandleY: 10, rightHandleX: 0.02, rightHandleY: 10, fixed: true },
    { x: 0.45, y: 10, leftHandleX: 0.43, leftHandleY: 10, rightHandleX: 0.47, rightHandleY: 10 },
    { x: 0.73, y: 8.76, leftHandleX: 0.68, leftHandleY: 9.22, rightHandleX: 0.82, rightHandleY: 8.23 },
    { x: 1, y: 6.21, leftHandleX: 0.92, leftHandleY: 6.92, rightHandleX: 1.03, rightHandleY: 5.55 },
    { x: 1.24, y: 4.06, leftHandleX: 1.13, leftHandleY: 4.84, rightHandleX: 1.33, rightHandleY: 3.43 },
    { x: 1.63, y: 2.25, leftHandleX: 1.5, leftHandleY: 2.72, rightHandleX: 1.81, rightHandleY: 1.5 },
    { x: 2.39, y: 0.4, leftHandleX: 2.26, leftHandleY: 0.57, rightHandleX: 2.53, rightHandleY: 0.11 },
    { x: 3.23, y: 0, leftHandleX: 3.12, leftHandleY: 0, rightHandleX: 3.56, rightHandleY: 0 },
  ],
  bitemporalWidth: [
    { x: 65.16, y: 0, leftHandleX: 62.16, leftHandleY: 0, rightHandleX: 71.26, rightHandleY: 0.21 },
    { x: 74.35, y: 0.86, leftHandleX: 72.49, leftHandleY: 0.21, rightHandleX: 75.73, rightHandleY: 1.23 },
    { x: 79.42, y: 3.29, leftHandleX: 78.31, leftHandleY: 2.37, rightHandleX: 80.09, rightHandleY: 3.74 },
    { x: 81.15, y: 4.96, leftHandleX: 80.67, leftHandleY: 4.34, rightHandleX: 81.38, rightHandleY: 5.28 },
    { x: 82.22, y: 6.27, leftHandleX: 81.91, leftHandleY: 5.81, rightHandleX: 82.98, rightHandleY: 7.29 },
    { x: 84.18, y: 8.86, leftHandleX: 83.64, leftHandleY: 8.16, rightHandleX: 84.89, rightHandleY: 9.6 },
    { x: 86.5, y: 10, leftHandleX: 86.2, leftHandleY: 10, rightHandleX: 86.8, rightHandleY: 10, fixed: true },
    { x: 92.5, y: 10, leftHandleX: 92.2, leftHandleY: 10, rightHandleX: 92.8, rightHandleY: 10 },
    { x: 94.82, y: 8.86, leftHandleX: 94.11, leftHandleY: 9.6, rightHandleX: 95.36, rightHandleY: 8.16 },
    { x: 96.78, y: 6.27, leftHandleX: 96.02, leftHandleY: 7.29, rightHandleX: 97.09, rightHandleY: 5.81 },
    { x: 97.85, y: 4.96, leftHandleX: 97.62, leftHandleY: 5.28, rightHandleX: 98.33, rightHandleY: 4.34 },
    { x: 99.58, y: 3.29, leftHandleX: 98.91, leftHandleY: 3.74, rightHandleX: 100.69, rightHandleY: 2.37 },
    { x: 104.65, y: 0.86, leftHandleX: 103.27, leftHandleY: 1.23, rightHandleX: 106.51, rightHandleY: 0.21 },
    { x: 113.84, y: 0, leftHandleX: 107.74, leftHandleY: 0.21, rightHandleX: 116.84, rightHandleY: 0 },
  ],
  interpupillaryMouthWidthRatio: [
    { x: 0.38, y: 0, leftHandleX: 0.31, leftHandleY: 0, rightHandleX: 0.47, rightHandleY: 0.13 },
    { x: 0.62, y: 1.9, leftHandleX: 0.56, leftHandleY: 0.97, rightHandleX: 0.64, rightHandleY: 2.13 },
    { x: 0.71, y: 4.44, leftHandleX: 0.68, leftHandleY: 2.99, rightHandleX: 0.72, rightHandleY: 4.94 },
    { x: 0.74, y: 6.93, leftHandleX: 0.74, leftHandleY: 6.57, rightHandleX: 0.75, rightHandleY: 7.33 },
    { x: 0.77, y: 8.84, leftHandleX: 0.76, leftHandleY: 8.27, rightHandleX: 0.79, rightHandleY: 9.48 },
    { x: 0.83, y: 10, leftHandleX: 0.83, leftHandleY: 10, rightHandleX: 0.83, rightHandleY: 10, fixed: true },
    { x: 0.87, y: 10, leftHandleX: 0.87, leftHandleY: 10, rightHandleX: 0.87, rightHandleY: 10 },
    { x: 0.93, y: 8.84, leftHandleX: 0.91, leftHandleY: 9.48, rightHandleX: 0.94, rightHandleY: 8.27 },
    { x: 0.96, y: 6.93, leftHandleX: 0.95, leftHandleY: 7.33, rightHandleX: 0.96, rightHandleY: 6.57 },
    { x: 0.99, y: 4.44, leftHandleX: 0.98, leftHandleY: 4.94, rightHandleX: 1.02, rightHandleY: 2.99 },
    { x: 1.08, y: 1.9, leftHandleX: 1.06, leftHandleY: 2.13, rightHandleX: 1.14, rightHandleY: 0.97 },
    { x: 1.32, y: 0, leftHandleX: 1.23, leftHandleY: 0.13, rightHandleX: 1.39, rightHandleY: 0 },
  ],
  eyebrowTilt: [
    { x: -19.06, y: 0, leftHandleX: -21.56, leftHandleY: 0, rightHandleX: -16.56, rightHandleY: 0 },
    { x: -9.84, y: 0.38, leftHandleX: -13.02, leftHandleY: 0.06, rightHandleX: -7.15, rightHandleY: 0.63 },
    { x: -2.76, y: 1.71, leftHandleX: -5.01, leftHandleY: 0.91, rightHandleX: -1.39, rightHandleY: 2.19 },
    { x: 1.03, y: 4, leftHandleX: 0.14, leftHandleY: 3.01, rightHandleX: 1.47, rightHandleY: 4.3 },
    { x: 3.01, y: 6.49, leftHandleX: 2.32, leftHandleY: 5.24, rightHandleX: 3.62, rightHandleY: 7.39 },
    { x: 4.62, y: 8.84, leftHandleX: 4.18, leftHandleY: 8.14, rightHandleX: 5.1, rightHandleY: 9.58 },
    { x: 6.5, y: 10, leftHandleX: 6.28, leftHandleY: 10, rightHandleX: 6.73, rightHandleY: 10, fixed: true },
    { x: 11, y: 10, leftHandleX: 10.78, leftHandleY: 10, rightHandleX: 11.23, rightHandleY: 10 },
    { x: 12.88, y: 8.84, leftHandleX: 12.4, leftHandleY: 9.58, rightHandleX: 13.32, rightHandleY: 8.14 },
    { x: 14.49, y: 6.49, leftHandleX: 13.88, leftHandleY: 7.39, rightHandleX: 15.18, rightHandleY: 5.24 },
    { x: 16.47, y: 4, leftHandleX: 16.03, leftHandleY: 4.3, rightHandleX: 17.36, rightHandleY: 3.01 },
    { x: 20.26, y: 1.71, leftHandleX: 18.89, leftHandleY: 2.19, rightHandleX: 22.51, rightHandleY: 0.91 },
    { x: 27.34, y: 0.38, leftHandleX: 24.65, leftHandleY: 0.63, rightHandleX: 30.52, rightHandleY: 0.06 },
    { x: 36.56, y: 0, leftHandleX: 34.06, leftHandleY: 0, rightHandleX: 39.06, rightHandleY: 0 },
  ],
  earProtrusionAngle: [
    { x: -15.02, y: 0, leftHandleX: -18.27, leftHandleY: 0, rightHandleX: -11.77, rightHandleY: 0 },
    { x: -3.5, y: 1.35, leftHandleX: -7.5, leftHandleY: 0.57, rightHandleX: -0.76, rightHandleY: 1.94 },
    { x: 2.55, y: 3.79, leftHandleX: 1.19, leftHandleY: 2.82, rightHandleX: 3.71, rightHandleY: 4.55 },
    { x: 5.82, y: 6.3, leftHandleX: 5.34, leftHandleY: 5.73, rightHandleX: 6.45, rightHandleY: 6.89 },
    { x: 8.29, y: 8.61, leftHandleX: 7.5, leftHandleY: 7.79, rightHandleX: 8.76, rightHandleY: 9.14 },
    { x: 10, y: 10, leftHandleX: 9.93, leftHandleY: 10, rightHandleX: 10.07, rightHandleY: 10, fixed: true },
    { x: 11.5, y: 10, leftHandleX: 11.43, leftHandleY: 10, rightHandleX: 11.58, rightHandleY: 10 },
    { x: 13.21, y: 8.61, leftHandleX: 12.74, leftHandleY: 9.14, rightHandleX: 14, rightHandleY: 7.79 },
    { x: 15.68, y: 6.3, leftHandleX: 15.05, leftHandleY: 6.89, rightHandleX: 16.16, rightHandleY: 5.73 },
    { x: 18.95, y: 3.79, leftHandleX: 17.79, leftHandleY: 4.55, rightHandleX: 20.31, rightHandleY: 2.82 },
    { x: 25, y: 1.35, leftHandleX: 22.26, leftHandleY: 1.94, rightHandleX: 29, rightHandleY: 0.57 },
    { x: 36.52, y: 0, leftHandleX: 33.27, leftHandleY: 0, rightHandleX: 39.77, rightHandleY: 0 },
  ],
  noseTipPosition: [
    { x: -6.16, y: 0, leftHandleX: -7.16, leftHandleY: 0, rightHandleX: -5.16, rightHandleY: 0 },
    { x: -3.23, y: 1.31, leftHandleX: -4.16, leftHandleY: 0.4, rightHandleX: -2.62, rightHandleY: 2 },
    { x: -1.8, y: 3.54, leftHandleX: -2.12, leftHandleY: 2.78, rightHandleX: -1.65, rightHandleY: 4.02 },
    { x: -1.18, y: 6.19, leftHandleX: -1.34, leftHandleY: 5.37, rightHandleX: -1.04, rightHandleY: 6.93 },
    { x: -0.62, y: 8.76, leftHandleX: -0.84, leftHandleY: 7.96, rightHandleX: -0.43, rightHandleY: 9.43 },
    { x: 0, y: 10, leftHandleX: -0.15, leftHandleY: 10, rightHandleX: 0.15, rightHandleY: 10, fixed: true },
    { x: 3, y: 10, leftHandleX: 2.85, leftHandleY: 10, rightHandleX: 3.15, rightHandleY: 10 },
    { x: 3.62, y: 8.76, leftHandleX: 3.43, leftHandleY: 9.43, rightHandleX: 3.84, rightHandleY: 7.96 },
    { x: 4.18, y: 6.19, leftHandleX: 4.04, leftHandleY: 6.93, rightHandleX: 4.34, rightHandleY: 5.37 },
    { x: 4.8, y: 3.54, leftHandleX: 4.65, leftHandleY: 4.02, rightHandleX: 5.12, rightHandleY: 2.78 },
    { x: 6.23, y: 1.31, leftHandleX: 5.62, leftHandleY: 2, rightHandleX: 7.16, rightHandleY: 0.4 },
    { x: 9.16, y: 0, leftHandleX: 8.16, leftHandleY: 0, rightHandleX: 10.16, rightHandleY: 0 },
  ],
  intercanthalNasalWidthRatio: [
    { x: 0.34, y: 0, leftHandleX: 0.24, leftHandleY: 0, rightHandleX: 0.44, rightHandleY: 0 },
    { x: 0.63, y: 0.78, leftHandleX: 0.49, leftHandleY: 0, rightHandleX: 0.7, rightHandleY: 1.44 },
    { x: 0.79, y: 2.71, leftHandleX: 0.75, leftHandleY: 1.95, rightHandleX: 0.83, rightHandleY: 3.5 },
    { x: 0.9, y: 5.36, leftHandleX: 0.86, leftHandleY: 4.42, rightHandleX: 0.94, rightHandleY: 6.57 },
    { x: 0.99, y: 9.04, leftHandleX: 0.98, leftHandleY: 8.42, rightHandleX: 1.01, rightHandleY: 9.7 },
    { x: 1.04, y: 10, leftHandleX: 1.03, leftHandleY: 10, rightHandleX: 1.05, rightHandleY: 10, fixed: true },
    { x: 1.16, y: 10, leftHandleX: 1.15, leftHandleY: 10, rightHandleX: 1.17, rightHandleY: 10 },
    { x: 1.21, y: 9.04, leftHandleX: 1.19, leftHandleY: 9.7, rightHandleX: 1.22, rightHandleY: 8.42 },
    { x: 1.3, y: 5.36, leftHandleX: 1.26, leftHandleY: 6.57, rightHandleX: 1.34, rightHandleY: 4.42 },
    { x: 1.41, y: 2.71, leftHandleX: 1.37, leftHandleY: 3.5, rightHandleX: 1.45, rightHandleY: 1.95 },
    { x: 1.57, y: 0.78, leftHandleX: 1.5, leftHandleY: 1.44, rightHandleX: 1.71, rightHandleY: 0 },
    { x: 1.86, y: 0, leftHandleX: 1.76, leftHandleY: 0, rightHandleX: 1.96, rightHandleY: 0 },
  ],
  lowerThird: [
    { x: 25.12, y: 0, leftHandleX: 24.12, leftHandleY: 0, rightHandleX: 26.12, rightHandleY: 0 },
    { x: 27.6, y: 0.52, leftHandleX: 26.93, leftHandleY: 0.24, rightHandleX: 28.33, rightHandleY: 0.78 },
    { x: 29.98, y: 2.11, leftHandleX: 29.27, leftHandleY: 1.51, rightHandleX: 30.77, rightHandleY: 2.91 },
    { x: 31.31, y: 4.02, leftHandleX: 31.05, leftHandleY: 3.52, rightHandleX: 31.6, rightHandleY: 4.8 },
    { x: 32.17, y: 6.49, leftHandleX: 31.91, leftHandleY: 5.75, rightHandleX: 32.43, rightHandleY: 7.43 },
    { x: 33.01, y: 9.04, leftHandleX: 32.7, leftHandleY: 8.36, rightHandleX: 33.29, rightHandleY: 9.68 },
    { x: 33.9, y: 10, leftHandleX: 33.74, leftHandleY: 10, rightHandleX: 34.06, rightHandleY: 10, fixed: true },
    { x: 37, y: 10, leftHandleX: 36.85, leftHandleY: 10, rightHandleX: 37.16, rightHandleY: 10 },
    { x: 37.89, y: 9.04, leftHandleX: 37.61, leftHandleY: 9.68, rightHandleX: 38.2, rightHandleY: 8.36 },
    { x: 38.73, y: 6.49, leftHandleX: 38.47, leftHandleY: 7.43, rightHandleX: 38.99, rightHandleY: 5.75 },
    { x: 39.59, y: 4.02, leftHandleX: 39.3, leftHandleY: 4.8, rightHandleX: 39.85, rightHandleY: 3.52 },
    { x: 40.92, y: 2.11, leftHandleX: 40.13, leftHandleY: 2.91, rightHandleX: 41.63, rightHandleY: 1.51 },
    { x: 43.3, y: 0.52, leftHandleX: 42.57, leftHandleY: 0.78, rightHandleX: 43.97, rightHandleY: 0.24 },
    { x: 45.78, y: 0, leftHandleX: 44.78, leftHandleY: 0, rightHandleX: 46.78, rightHandleY: 0 },
  ],
  bigonialWidth: [
    { x: 66.8, y: 0, leftHandleX: 63.8, leftHandleY: 0, rightHandleX: 69.8, rightHandleY: 0 },
    { x: 74.59, y: 1.77, leftHandleX: 72.16, leftHandleY: 0.89, rightHandleX: 76.93, rightHandleY: 2.7 },
    { x: 79.76, y: 4.55, leftHandleX: 78.54, leftHandleY: 3.66, rightHandleX: 81.07, rightHandleY: 5.52 },
    { x: 83.46, y: 7.47, leftHandleX: 82.58, leftHandleY: 6.65, rightHandleX: 85.61, rightHandleY: 9.66 },
    { x: 87.5, y: 10, leftHandleX: 87.3, leftHandleY: 10, rightHandleX: 87.7, rightHandleY: 10, fixed: true },
    { x: 91.5, y: 10, leftHandleX: 91.3, leftHandleY: 10, rightHandleX: 91.7, rightHandleY: 10 },
    { x: 95.54, y: 7.47, leftHandleX: 93.39, leftHandleY: 9.66, rightHandleX: 96.42, rightHandleY: 6.65 },
    { x: 99.24, y: 4.55, leftHandleX: 97.93, leftHandleY: 5.52, rightHandleX: 100.46, rightHandleY: 3.66 },
    { x: 104.41, y: 1.77, leftHandleX: 102.07, leftHandleY: 2.7, rightHandleX: 106.84, rightHandleY: 0.89 },
    { x: 112.2, y: 0, leftHandleX: 109.2, leftHandleY: 0, rightHandleX: 115.2, rightHandleY: 0 },
  ],
  eyeSeparationRatio: [
    { x: 36.54, y: 0, leftHandleX: 35.44, leftHandleY: 0, rightHandleX: 37.4, rightHandleY: 0.04 },
    { x: 39.04, y: 0.63, leftHandleX: 38.16, leftHandleY: 0.21, rightHandleX: 39.77, rightHandleY: 1.05 },
    { x: 41.08, y: 2.17, leftHandleX: 40.57, leftHandleY: 1.71, rightHandleX: 41.62, rightHandleY: 2.76 },
    { x: 42.71, y: 4.74, leftHandleX: 42.26, leftHandleY: 3.81, rightHandleX: 43.08, rightHandleY: 5.52 },
    { x: 43.94, y: 7.37, leftHandleX: 43.65, leftHandleY: 6.79, rightHandleX: 44.17, rightHandleY: 7.77 },
    { x: 44.86, y: 9.02, leftHandleX: 44.54, leftHandleY: 8.56, rightHandleX: 45.08, rightHandleY: 9.5 },
    { x: 45.7, y: 10, leftHandleX: 45.65, leftHandleY: 10, rightHandleX: 45.76, rightHandleY: 10, fixed: true },
    { x: 46.8, y: 10, leftHandleX: 46.75, leftHandleY: 10, rightHandleX: 46.86, rightHandleY: 10 },
    { x: 47.64, y: 9.02, leftHandleX: 47.42, leftHandleY: 9.5, rightHandleX: 47.96, rightHandleY: 8.56 },
    { x: 48.56, y: 7.37, leftHandleX: 48.33, leftHandleY: 7.77, rightHandleX: 48.85, rightHandleY: 6.79 },
    { x: 49.79, y: 4.74, leftHandleX: 49.42, leftHandleY: 5.52, rightHandleX: 50.24, rightHandleY: 3.81 },
    { x: 51.42, y: 2.17, leftHandleX: 50.88, leftHandleY: 2.76, rightHandleX: 51.93, rightHandleY: 1.71 },
    { x: 53.46, y: 0.63, leftHandleX: 52.73, leftHandleY: 1.05, rightHandleX: 54.34, rightHandleY: 0.21 },
    { x: 55.96, y: 0, leftHandleX: 55.1, leftHandleY: 0.04, rightHandleX: 57.06, rightHandleY: 0 },
  ],
  oneEyeApartTest: [
    { x: 0.52, y: 0, leftHandleX: 0.47, leftHandleY: 0, rightHandleX: 0.57, rightHandleY: 0 },
    { x: 0.7, y: 1.16, leftHandleX: 0.65, leftHandleY: 0.3, rightHandleX: 0.75, rightHandleY: 1.81 },
    { x: 0.82, y: 3.76, leftHandleX: 0.79, leftHandleY: 2.75, rightHandleX: 0.83, rightHandleY: 4.16 },
    { x: 0.86, y: 5.91, leftHandleX: 0.85, leftHandleY: 5.2, rightHandleX: 0.88, rightHandleY: 6.67 },
    { x: 0.9, y: 8.46, leftHandleX: 0.89, leftHandleY: 7.55, rightHandleX: 0.92, rightHandleY: 9.46 },
    { x: 0.95, y: 10, leftHandleX: 0.95, leftHandleY: 10, rightHandleX: 0.95, rightHandleY: 10, fixed: true },
    { x: 1, y: 10, leftHandleX: 1, leftHandleY: 10, rightHandleX: 1, rightHandleY: 10 },
    { x: 1.05, y: 8.46, leftHandleX: 1.03, leftHandleY: 9.46, rightHandleX: 1.06, rightHandleY: 7.55 },
    { x: 1.09, y: 5.91, leftHandleX: 1.07, leftHandleY: 6.67, rightHandleX: 1.1, rightHandleY: 5.2 },
    { x: 1.13, y: 3.76, leftHandleX: 1.12, leftHandleY: 4.16, rightHandleX: 1.16, rightHandleY: 2.75 },
    { x: 1.25, y: 1.16, leftHandleX: 1.2, leftHandleY: 1.81, rightHandleX: 1.3, rightHandleY: 0.3 },
    { x: 1.43, y: 0, leftHandleX: 1.38, leftHandleY: 0, rightHandleX: 1.48, rightHandleY: 0 },
  ],
  deviationIaaJfa: [
    { x: -25, y: 0, leftHandleX: -28.49, leftHandleY: 0, rightHandleX: -17.26, rightHandleY: 0 },
    { x: -22.21, y: 0.21, leftHandleX: -24.53, leftHandleY: 0, rightHandleX: -18.79, rightHandleY: 0.38 },
    { x: -12.64, y: 2.15, leftHandleX: -16.92, leftHandleY: 0.89, rightHandleX: -10.64, rightHandleY: 2.91 },
    { x: -7.65, y: 4.42, leftHandleX: -9.12, leftHandleY: 3.71, rightHandleX: -6.49, rightHandleY: 4.97 },
    { x: -4.45, y: 6.65, leftHandleX: -5.43, leftHandleY: 5.75, rightHandleX: -3.73, rightHandleY: 7.39 },
    { x: -2.09, y: 9.07, leftHandleX: -2.62, leftHandleY: 8.51, rightHandleX: -1.46, rightHandleY: 9.52 },
    { x: 0, y: 10, leftHandleX: -0.12, leftHandleY: 10, rightHandleX: 0.13, rightHandleY: 10, fixed: true },
    { x: 2.5, y: 10, leftHandleX: 2.38, leftHandleY: 10, rightHandleX: 2.63, rightHandleY: 10 },
    { x: 4.59, y: 9.07, leftHandleX: 3.96, leftHandleY: 9.52, rightHandleX: 5.12, rightHandleY: 8.51 },
    { x: 6.95, y: 6.65, leftHandleX: 6.23, leftHandleY: 7.39, rightHandleX: 7.88, rightHandleY: 5.56 },
    { x: 9.84, y: 4.3, leftHandleX: 9.13, leftHandleY: 4.93, rightHandleX: 11.22, rightHandleY: 3.58 },
    { x: 14.38, y: 2.02, leftHandleX: 12.47, leftHandleY: 2.82, rightHandleX: 18.03, rightHandleY: 0.57 },
    { x: 24.49, y: 0, leftHandleX: 21.74, leftHandleY: 0, rightHandleX: 27.24, rightHandleY: 0 },
  ],
  earProtrusionRatio: [
    { x: -10.52, y: 0, leftHandleX: -13.52, leftHandleY: 0, rightHandleX: -7.52, rightHandleY: 0 },
    { x: -1.24, y: 1.5, leftHandleX: -4.14, leftHandleY: 0.44, rightHandleX: 0.5, rightHandleY: 2.11 },
    { x: 2.87, y: 3.6, leftHandleX: 2.09, leftHandleY: 2.84, rightHandleX: 3.59, rightHandleY: 4.15 },
    { x: 4.8, y: 5.33, leftHandleX: 4.17, leftHandleY: 4.59, rightHandleX: 5.81, rightHandleY: 6.32 },
    { x: 7.12, y: 8.15, leftHandleX: 6.49, leftHandleY: 7.24, rightHandleX: 7.6, rightHandleY: 8.78 },
    { x: 8, y: 10, leftHandleX: 7.8, leftHandleY: 10, rightHandleX: 8.2, rightHandleY: 10, fixed: true },
    { x: 12, y: 10, leftHandleX: 11.8, leftHandleY: 10, rightHandleX: 12.2, rightHandleY: 10 },
    { x: 12.88, y: 8.15, leftHandleX: 12.4, leftHandleY: 8.78, rightHandleX: 13.51, rightHandleY: 7.24 },
    { x: 15.2, y: 5.33, leftHandleX: 14.19, leftHandleY: 6.32, rightHandleX: 15.83, rightHandleY: 4.59 },
    { x: 17.13, y: 3.6, leftHandleX: 16.41, leftHandleY: 4.15, rightHandleX: 17.91, rightHandleY: 2.84 },
    { x: 21.24, y: 1.5, leftHandleX: 19.5, leftHandleY: 2.11, rightHandleX: 24.14, rightHandleY: 0.44 },
    { x: 30.52, y: 0, leftHandleX: 27.52, leftHandleY: 0, rightHandleX: 33.52, rightHandleY: 0 },
  ],
  mouthCornerPosition: [
    { x: -16.36, y: 0, leftHandleX: -19.36, leftHandleY: 0, rightHandleX: -13.36, rightHandleY: 0 },
    { x: -5.06, y: 1.56, leftHandleX: -7.18, leftHandleY: 0.32, rightHandleX: -3.07, rightHandleY: 2.36 },
    { x: -1.58, y: 5.88, leftHandleX: -2.06, leftHandleY: 4.63, rightHandleX: -0.95, rightHandleY: 7.03 },
    { x: 0, y: 10, leftHandleX: -0.2, leftHandleY: 10, rightHandleX: 0.2, rightHandleY: 10, fixed: true },
    { x: 4, y: 10, leftHandleX: 3.8, leftHandleY: 10, rightHandleX: 4.2, rightHandleY: 10 },
    { x: 5.58, y: 5.88, leftHandleX: 4.95, leftHandleY: 7.03, rightHandleX: 6.06, rightHandleY: 4.63 },
    { x: 9.06, y: 1.56, leftHandleX: 7.07, leftHandleY: 2.36, rightHandleX: 11.18, rightHandleY: 0.32 },
    { x: 20.36, y: 0, leftHandleX: 17.36, leftHandleY: 0, rightHandleX: 23.36, rightHandleY: 0 },
  ],
  nasofrontalAngle: [
    { x: 86.77, y: 0, leftHandleX: 81.77, leftHandleY: 0, rightHandleX: 91.77, rightHandleY: 0 },
    { x: 101.22, y: 2.37, leftHandleX: 96.35, leftHandleY: 0.94, rightHandleX: 102.69, rightHandleY: 2.9 },
    { x: 105.85, y: 4.59, leftHandleX: 104.88, leftHandleY: 3.88, rightHandleX: 107.15, rightHandleY: 5.73 },
    { x: 109.58, y: 7.62, leftHandleX: 108.28, leftHandleY: 6.78, rightHandleX: 111.53, rightHandleY: 8.95 },
    { x: 116, y: 10, leftHandleX: 115.4, leftHandleY: 10, rightHandleX: 116.6, rightHandleY: 10, fixed: true },
    { x: 128, y: 10, leftHandleX: 127.4, leftHandleY: 10, rightHandleX: 128.6, rightHandleY: 10 },
    { x: 134.42, y: 7.62, leftHandleX: 132.47, leftHandleY: 8.95, rightHandleX: 135.72, rightHandleY: 6.78 },
    { x: 138.15, y: 4.59, leftHandleX: 136.85, leftHandleY: 5.73, rightHandleX: 139.12, rightHandleY: 3.88 },
    { x: 142.78, y: 2.37, leftHandleX: 141.31, leftHandleY: 2.9, rightHandleX: 147.65, rightHandleY: 0.94 },
    { x: 157.23, y: 0, leftHandleX: 152.23, leftHandleY: 0, rightHandleX: 162.23, rightHandleY: 0 },
  ],
  facialConvexityNasion: [
    { x: 135.43, y: 0.1, leftHandleX: 132.43, leftHandleY: 0.1, rightHandleX: 138.43, rightHandleY: 0.1 },
    { x: 144.35, y: 0.42, leftHandleX: 140.96, leftHandleY: 0.2, rightHandleX: 147.26, rightHandleY: 0.67 },
    { x: 151.86, y: 1.71, leftHandleX: 150.36, leftHandleY: 1.35, rightHandleX: 153.66, rightHandleY: 2.19 },
    { x: 156.32, y: 3.86, leftHandleX: 155.4, leftHandleY: 3, rightHandleX: 157, rightHandleY: 4.4 },
    { x: 158.46, y: 6.24, leftHandleX: 157.92, leftHandleY: 5.35, rightHandleX: 159.09, rightHandleY: 7.25 },
    { x: 160.44, y: 8.91, leftHandleX: 159.72, leftHandleY: 8.21, rightHandleX: 161.12, rightHandleY: 9.67 },
    { x: 163, y: 10, leftHandleX: 162.85, leftHandleY: 10, rightHandleX: 163.15, rightHandleY: 10, fixed: true },
    { x: 166, y: 10, leftHandleX: 165.85, leftHandleY: 10, rightHandleX: 166.15, rightHandleY: 10 },
    { x: 168.56, y: 8.91, leftHandleX: 167.88, leftHandleY: 9.67, rightHandleX: 169.28, rightHandleY: 8.21 },
    { x: 170.54, y: 6.24, leftHandleX: 169.91, leftHandleY: 7.25, rightHandleX: 171.08, rightHandleY: 5.35 },
    { x: 172.68, y: 3.86, leftHandleX: 172, leftHandleY: 4.4, rightHandleX: 173.6, rightHandleY: 3 },
    { x: 177.14, y: 1.71, leftHandleX: 175.34, leftHandleY: 2.19, rightHandleX: 178.64, rightHandleY: 1.35 },
    { x: 184.65, y: 0.42, leftHandleX: 181.74, leftHandleY: 0.67, rightHandleX: 188.04, rightHandleY: 0.2 },
    { x: 193.57, y: 0.1, leftHandleX: 190.57, leftHandleY: 0.1, rightHandleX: 196.57, rightHandleY: 0.1 },
  ],
  recessionFrankfortPlane: [
    { x: -26.08, y: 0, leftHandleX: -30.03, leftHandleY: 0, rightHandleX: -22.37, rightHandleY: 0.15 },
    { x: -13.99, y: 1.39, leftHandleX: -18.47, leftHandleY: 0.53, rightHandleX: -11.56, rightHandleY: 1.93 },
    { x: -7.34, y: 3.62, leftHandleX: -8.36, leftHandleY: 2.78, rightHandleX: -6.57, rightHandleY: 4.16 },
    { x: -4.9, y: 5.85, leftHandleX: -5.48, leftHandleY: 5.13, rightHandleX: -4.33, rightHandleY: 6.73 },
    { x: -2.41, y: 8.8, leftHandleX: -3.3, leftHandleY: 8, rightHandleX: -1.19, rightHandleY: 9.6 },
    { x: 1.5, y: 10, leftHandleX: 0.9, leftHandleY: 10, rightHandleX: 2.1, rightHandleY: 10, fixed: true },
    { x: 13.5, y: 10, leftHandleX: 12.9, leftHandleY: 10, rightHandleX: 14.1, rightHandleY: 10 },
    { x: 17.41, y: 8.8, leftHandleX: 16.19, leftHandleY: 9.6, rightHandleX: 18.3, rightHandleY: 8 },
    { x: 19.9, y: 5.85, leftHandleX: 19.33, leftHandleY: 6.73, rightHandleX: 20.48, rightHandleY: 5.13 },
    { x: 22.34, y: 3.62, leftHandleX: 21.57, leftHandleY: 4.16, rightHandleX: 23.36, rightHandleY: 2.78 },
    { x: 28.99, y: 1.39, leftHandleX: 26.56, leftHandleY: 1.93, rightHandleX: 33.47, rightHandleY: 0.53 },
    { x: 41.08, y: 0, leftHandleX: 37.37, leftHandleY: 0.15, rightHandleX: 45.03, rightHandleY: 0 },
  ],
  holdawayHLine: [
    { x: -6.63, y: 0, leftHandleX: -7.63, leftHandleY: 0, rightHandleX: -5.63, rightHandleY: 0 },
    { x: -3.33, y: 1.12, leftHandleX: -4.47, leftHandleY: 0.27, rightHandleX: -2.73, rightHandleY: 1.52 },
    { x: -1.56, y: 4.61, leftHandleX: -2.15, leftHandleY: 2.42, rightHandleX: -1.44, rightHandleY: 5.07 },
    { x: -1.07, y: 6.7, leftHandleX: -1.27, leftHandleY: 5.83, rightHandleX: -0.96, rightHandleY: 7.29 },
    { x: -0.59, y: 8.72, leftHandleX: -0.8, leftHandleY: 7.98, rightHandleX: -0.36, rightHandleY: 9.52 },
    { x: 0.1, y: 10, leftHandleX: 0.06, leftHandleY: 10, rightHandleX: 0.14, rightHandleY: 10, fixed: true },
    { x: 0.9, y: 10, leftHandleX: 0.86, leftHandleY: 10, rightHandleX: 0.94, rightHandleY: 10 },
    { x: 1.59, y: 8.72, leftHandleX: 1.36, leftHandleY: 9.52, rightHandleX: 1.8, rightHandleY: 7.98 },
    { x: 2.07, y: 6.7, leftHandleX: 1.96, leftHandleY: 7.29, rightHandleX: 2.27, rightHandleY: 5.83 },
    { x: 2.56, y: 4.61, leftHandleX: 2.44, leftHandleY: 5.07, rightHandleX: 3.15, rightHandleY: 2.42 },
    { x: 4.33, y: 1.12, leftHandleX: 3.73, leftHandleY: 1.52, rightHandleX: 5.47, rightHandleY: 0.27 },
    { x: 7.63, y: 0, leftHandleX: 6.63, leftHandleY: 0, rightHandleX: 8.63, rightHandleY: 0 },
  ],
  facialDepthToHeightRatio: [
    { x: 0.93, y: 0.02, leftHandleX: 0.88, leftHandleY: 0.02, rightHandleX: 0.97, rightHandleY: 0.02 },
    { x: 1.08, y: 1.55, leftHandleX: 1.04, leftHandleY: 0.67, rightHandleX: 1.12, rightHandleY: 2.13 },
    { x: 1.17, y: 3.9, leftHandleX: 1.15, leftHandleY: 3.22, rightHandleX: 1.19, rightHandleY: 4.56 },
    { x: 1.22, y: 6.31, leftHandleX: 1.21, leftHandleY: 5.49, rightHandleX: 1.23, rightHandleY: 7.22 },
    { x: 1.25, y: 8.66, leftHandleX: 1.24, leftHandleY: 8, rightHandleX: 1.27, rightHandleY: 9.37 },
    { x: 1.3, y: 10, leftHandleX: 1.29, leftHandleY: 10, rightHandleX: 1.31, rightHandleY: 10, fixed: true },
    { x: 1.44, y: 10, leftHandleX: 1.43, leftHandleY: 10, rightHandleX: 1.45, rightHandleY: 10 },
    { x: 1.49, y: 8.66, leftHandleX: 1.47, leftHandleY: 9.37, rightHandleX: 1.5, rightHandleY: 8 },
    { x: 1.52, y: 6.31, leftHandleX: 1.51, leftHandleY: 7.22, rightHandleX: 1.53, rightHandleY: 5.49 },
    { x: 1.57, y: 3.9, leftHandleX: 1.55, leftHandleY: 4.56, rightHandleX: 1.59, rightHandleY: 3.22 },
    { x: 1.66, y: 1.55, leftHandleX: 1.62, leftHandleY: 2.13, rightHandleX: 1.7, rightHandleY: 0.67 },
    { x: 1.81, y: 0.02, leftHandleX: 1.77, leftHandleY: 0.02, rightHandleX: 1.86, rightHandleY: 0.02 },
  ],
  lowerLipBurstoneLine: [
    { x: -8.95, y: 0, leftHandleX: -9.95, leftHandleY: 0, rightHandleX: -7.95, rightHandleY: 0 },
    { x: -5.76, y: 2.11, leftHandleX: -6.03, leftHandleY: 1.5, rightHandleX: -5.33, rightHandleY: 2.68 },
    { x: -4.67, y: 4.38, leftHandleX: -4.94, leftHandleY: 3.6, rightHandleX: -4.31, rightHandleY: 5.48 },
    { x: -4, y: 7.18, leftHandleX: -4.17, leftHandleY: 6.23, rightHandleX: -3.88, rightHandleY: 7.73 },
    { x: -3.57, y: 8.8, leftHandleX: -3.71, leftHandleY: 8.34, rightHandleX: -3.3, rightHandleY: 9.5 },
    { x: -2.8, y: 10, leftHandleX: -2.88, leftHandleY: 10, rightHandleX: -2.72, rightHandleY: 10, fixed: true },
    { x: -1.2, y: 10, leftHandleX: -1.28, leftHandleY: 10, rightHandleX: -1.12, rightHandleY: 10 },
    { x: -0.43, y: 8.8, leftHandleX: -0.7, leftHandleY: 9.5, rightHandleX: -0.29, rightHandleY: 8.34 },
    { x: 0, y: 7.18, leftHandleX: -0.12, leftHandleY: 7.73, rightHandleX: 0.17, rightHandleY: 6.23 },
    { x: 0.67, y: 4.38, leftHandleX: 0.31, leftHandleY: 5.48, rightHandleX: 0.94, rightHandleY: 3.6 },
    { x: 1.76, y: 2.11, leftHandleX: 1.33, leftHandleY: 2.68, rightHandleX: 2.03, rightHandleY: 1.5 },
    { x: 4.95, y: 0, leftHandleX: 3.95, leftHandleY: 0, rightHandleX: 5.95, rightHandleY: 0 },
  ],
  gonionToMouthLine: [
    { x: -6.7, y: 0, leftHandleX: -10.95, leftHandleY: 0, rightHandleX: -2.45, rightHandleY: 0 },
    { x: 2.95, y: 3.26, leftHandleX: 0.41, leftHandleY: 1.81, rightHandleX: 3.97, rightHandleY: 3.98 },
    { x: 6.3, y: 5.62, leftHandleX: 5.48, leftHandleY: 4.89, rightHandleX: 7.05, rightHandleY: 6.25 },
    { x: 9.93, y: 8.39, leftHandleX: 8.7, leftHandleY: 7.59, rightHandleX: 11.37, rightHandleY: 9.2 },
    { x: 15, y: 10, leftHandleX: 13.5, leftHandleY: 10, rightHandleX: 16.5, rightHandleY: 10, fixed: true },
    { x: 45, y: 10, leftHandleX: 43.5, leftHandleY: 10, rightHandleX: 46.5, rightHandleY: 10 },
    { x: 50.07, y: 8.39, leftHandleX: 48.63, leftHandleY: 9.2, rightHandleX: 51.3, rightHandleY: 7.59 },
    { x: 53.7, y: 5.62, leftHandleX: 52.95, leftHandleY: 6.25, rightHandleX: 54.52, rightHandleY: 4.89 },
    { x: 57.05, y: 3.26, leftHandleX: 56.03, leftHandleY: 3.98, rightHandleX: 59.59, rightHandleY: 1.81 },
    { x: 66.7, y: 0, leftHandleX: 62.45, leftHandleY: 0, rightHandleX: 70.95, rightHandleY: 0 },
  ],
  interiorMidfaceProjectionAngle: [
    { x: 30, y: 0, leftHandleX: 27.45, leftHandleY: 0, rightHandleX: 31.95, rightHandleY: 0 },
    { x: 35.15, y: 0.56, leftHandleX: 32.93, leftHandleY: 0.02, rightHandleX: 36.87, rightHandleY: 0.9 },
    { x: 41.75, y: 2.91, leftHandleX: 40.15, leftHandleY: 2.11, rightHandleX: 43.28, rightHandleY: 3.68 },
    { x: 46.93, y: 5.83, leftHandleX: 46.05, leftHandleY: 5.14, rightHandleX: 48.13, rightHandleY: 6.63 },
    { x: 50.36, y: 8.82, leftHandleX: 49.59, leftHandleY: 8.04, rightHandleX: 51.16, rightHandleY: 9.76 },
    { x: 53, y: 10, leftHandleX: 52.65, leftHandleY: 10, rightHandleX: 53.35, rightHandleY: 10, fixed: true },
    { x: 56, y: 10, leftHandleX: 55.7, leftHandleY: 10, rightHandleX: 56.3, rightHandleY: 10 },
    { x: 57, y: 10, leftHandleX: 56.7, leftHandleY: 10, rightHandleX: 57.3, rightHandleY: 10 },
    { x: 60, y: 10, leftHandleX: 59.65, leftHandleY: 10, rightHandleX: 60.35, rightHandleY: 10 },
    { x: 62.64, y: 8.82, leftHandleX: 61.84, leftHandleY: 9.76, rightHandleX: 63.41, rightHandleY: 8.04 },
    { x: 66.07, y: 5.83, leftHandleX: 64.87, leftHandleY: 6.63, rightHandleX: 66.95, rightHandleY: 5.14 },
    { x: 71.25, y: 2.91, leftHandleX: 69.72, leftHandleY: 3.68, rightHandleX: 72.85, rightHandleY: 2.11 },
    { x: 77.85, y: 0.56, leftHandleX: 76.13, leftHandleY: 0.9, rightHandleX: 80.07, rightHandleY: 0.02 },
    { x: 83, y: 0, leftHandleX: 81.05, leftHandleY: 0, rightHandleX: 85.55, rightHandleY: 0 },
  ],
  upperLipSLinePosition: [
    { x: -6.54, y: 0, leftHandleX: -7.29, leftHandleY: 0, rightHandleX: -5.79, rightHandleY: 0 },
    { x: -5.17, y: 0, leftHandleX: -5.92, leftHandleY: 0, rightHandleX: -4.42, rightHandleY: 0 },
    { x: -3.38, y: 1.01, leftHandleX: -3.84, leftHandleY: 0.4, rightHandleX: -2.64, rightHandleY: 1.86 },
    { x: -1.86, y: 3.62, leftHandleX: -2.19, leftHandleY: 2.78, rightHandleX: -1.72, rightHandleY: 4.09 },
    { x: -1.2, y: 5.96, leftHandleX: -1.41, leftHandleY: 5.03, rightHandleX: -0.9, rightHandleY: 7.17 },
    { x: -0.39, y: 8.96, leftHandleX: -0.6, leftHandleY: 8.39, rightHandleX: -0.27, rightHandleY: 9.3 },
    { x: 0.1, y: 10, leftHandleX: 0.06, leftHandleY: 10, rightHandleX: 0.14, rightHandleY: 10, fixed: true },
    { x: 0.9, y: 10, leftHandleX: 0.86, leftHandleY: 10, rightHandleX: 0.94, rightHandleY: 10 },
    { x: 1.39, y: 8.96, leftHandleX: 1.27, leftHandleY: 9.3, rightHandleX: 1.6, rightHandleY: 8.39 },
    { x: 2.2, y: 5.96, leftHandleX: 1.9, leftHandleY: 7.17, rightHandleX: 2.41, rightHandleY: 5.03 },
    { x: 2.86, y: 3.62, leftHandleX: 2.72, leftHandleY: 4.09, rightHandleX: 3.19, rightHandleY: 2.78 },
    { x: 4.38, y: 1.01, leftHandleX: 3.64, leftHandleY: 1.86, rightHandleX: 4.84, rightHandleY: 0.4 },
    { x: 6.17, y: 0, leftHandleX: 5.42, leftHandleY: 0, rightHandleX: 6.92, rightHandleY: 0 },
    { x: 7.54, y: 0, leftHandleX: 6.79, leftHandleY: 0, rightHandleX: 8.29, rightHandleY: 0 },
  ],
  ramusToMandibleRatio: [
    { x: 0.06, y: 0.13, leftHandleX: -0.01, leftHandleY: 0.13, rightHandleX: 0.12, rightHandleY: 0.13 },
    { x: 0.25, y: 0.29, leftHandleX: 0.18, leftHandleY: 0, rightHandleX: 0.31, rightHandleY: 0.47 },
    { x: 0.39, y: 1.95, leftHandleX: 0.36, leftHandleY: 1.23, rightHandleX: 0.42, rightHandleY: 2.68 },
    { x: 0.48, y: 4.77, leftHandleX: 0.46, leftHandleY: 3.7, rightHandleX: 0.49, rightHandleY: 5.49 },
    { x: 0.53, y: 7.66, leftHandleX: 0.51, leftHandleY: 6.79, rightHandleX: 0.56, rightHandleY: 9.47 },
    { x: 0.62, y: 10, leftHandleX: 0.61, leftHandleY: 10, rightHandleX: 0.63, rightHandleY: 10, fixed: true },
    { x: 0.75, y: 10, leftHandleX: 0.74, leftHandleY: 10, rightHandleX: 0.76, rightHandleY: 10 },
    { x: 0.84, y: 7.66, leftHandleX: 0.81, leftHandleY: 9.47, rightHandleX: 0.86, rightHandleY: 6.79 },
    { x: 0.89, y: 4.77, leftHandleX: 0.88, leftHandleY: 5.49, rightHandleX: 0.91, rightHandleY: 3.7 },
    { x: 0.98, y: 1.95, leftHandleX: 0.95, leftHandleY: 2.68, rightHandleX: 1.01, rightHandleY: 1.23 },
    { x: 1.12, y: 0.29, leftHandleX: 1.06, leftHandleY: 0.47, rightHandleX: 1.19, rightHandleY: 0 },
    { x: 1.31, y: 0.13, leftHandleX: 1.25, leftHandleY: 0.13, rightHandleX: 1.38, rightHandleY: 0.13 },
  ],
  mentolabialAngle: [
    { x: 48.09, y: 0, leftHandleX: 39.09, leftHandleY: 0, rightHandleX: 57.09, rightHandleY: 0 },
    { x: 77.01, y: 1.31, leftHandleX: 66.69, leftHandleY: 0.34, rightHandleX: 82.68, rightHandleY: 1.94 },
    { x: 91.11, y: 4, leftHandleX: 87.91, leftHandleY: 3.05, rightHandleX: 92.42, rightHandleY: 4.49 },
    { x: 96.21, y: 6.17, leftHandleX: 94.76, leftHandleY: 5.31, rightHandleX: 97.54, rightHandleY: 6.87 },
    { x: 102.76, y: 8.98, leftHandleX: 99.71, leftHandleY: 7.95, rightHandleX: 105.67, rightHandleY: 9.73 },
    { x: 111, y: 10, leftHandleX: 110.2, leftHandleY: 10, rightHandleX: 111.8, rightHandleY: 10, fixed: true },
    { x: 127, y: 10, leftHandleX: 126.2, leftHandleY: 10, rightHandleX: 127.8, rightHandleY: 10 },
    { x: 135.24, y: 8.98, leftHandleX: 132.33, leftHandleY: 9.73, rightHandleX: 138.29, rightHandleY: 7.95 },
    { x: 141.79, y: 6.17, leftHandleX: 140.46, leftHandleY: 6.87, rightHandleX: 143.24, rightHandleY: 5.31 },
    { x: 146.89, y: 4, leftHandleX: 145.58, leftHandleY: 4.49, rightHandleX: 150.09, rightHandleY: 3.05 },
    { x: 160.99, y: 1.31, leftHandleX: 155.32, leftHandleY: 1.94, rightHandleX: 171.31, rightHandleY: 0.34 },
    { x: 189.91, y: 0, leftHandleX: 180.91, leftHandleY: 0, rightHandleX: 198.91, rightHandleY: 0 },
  ],
  nasomentalAngle: [
    { x: 108.15, y: 0, leftHandleX: 105.15, leftHandleY: 0, rightHandleX: 111.15, rightHandleY: 0 },
    { x: 116.68, y: 1.69, leftHandleX: 113.48, leftHandleY: 0.55, rightHandleX: 118.62, rightHandleY: 2.57 },
    { x: 120.02, y: 3.62, leftHandleX: 119.54, leftHandleY: 3.14, rightHandleX: 120.51, rightHandleY: 4.23 },
    { x: 122.01, y: 6.46, leftHandleX: 121.43, leftHandleY: 5.52, rightHandleX: 122.4, rightHandleY: 7.18 },
    { x: 123.02, y: 8.4, leftHandleX: 122.83, leftHandleY: 7.79, rightHandleX: 123.75, rightHandleY: 9.64 },
    { x: 126, y: 10, leftHandleX: 125.75, leftHandleY: 10, rightHandleX: 126.25, rightHandleY: 10, fixed: true },
    { x: 131, y: 10, leftHandleX: 130.75, leftHandleY: 10, rightHandleX: 131.25, rightHandleY: 10 },
    { x: 133.98, y: 8.4, leftHandleX: 133.25, leftHandleY: 9.64, rightHandleX: 134.17, rightHandleY: 7.79 },
    { x: 134.99, y: 6.46, leftHandleX: 134.6, leftHandleY: 7.18, rightHandleX: 135.57, rightHandleY: 5.52 },
    { x: 136.98, y: 3.62, leftHandleX: 136.49, leftHandleY: 4.23, rightHandleX: 137.46, rightHandleY: 3.14 },
    { x: 140.32, y: 1.69, leftHandleX: 138.38, leftHandleY: 2.57, rightHandleX: 143.52, rightHandleY: 0.55 },
    { x: 148.85, y: 0, leftHandleX: 145.85, leftHandleY: 0, rightHandleX: 151.85, rightHandleY: 0 },
  ],
  lowerLipSLinePosition: [
    { x: -5.92, y: 0, leftHandleX: -6.72, leftHandleY: 0, rightHandleX: -5.12, rightHandleY: 0 },
    { x: -3.04, y: 1.18, leftHandleX: -3.73, leftHandleY: 0.49, rightHandleX: -2.55, rightHandleY: 1.69 },
    { x: -1.71, y: 3.03, leftHandleX: -2.07, leftHandleY: 2.13, rightHandleX: -1.52, rightHandleY: 3.52 },
    { x: -1.11, y: 5.79, leftHandleX: -1.25, leftHandleY: 4.89, rightHandleX: -0.98, rightHandleY: 6.46 },
    { x: -0.49, y: 8.84, leftHandleX: -0.68, leftHandleY: 8.04, rightHandleX: -0.34, rightHandleY: 9.52 },
    { x: 0.1, y: 10, leftHandleX: 0.06, leftHandleY: 10, rightHandleX: 0.14, rightHandleY: 10, fixed: true },
    { x: 0.9, y: 10, leftHandleX: 0.86, leftHandleY: 10, rightHandleX: 0.94, rightHandleY: 10 },
    { x: 1.49, y: 8.84, leftHandleX: 1.34, leftHandleY: 9.52, rightHandleX: 1.68, rightHandleY: 8.04 },
    { x: 2.11, y: 5.79, leftHandleX: 1.98, leftHandleY: 6.46, rightHandleX: 2.25, rightHandleY: 4.89 },
    { x: 2.71, y: 3.03, leftHandleX: 2.52, leftHandleY: 3.52, rightHandleX: 3.07, rightHandleY: 2.13 },
    { x: 4.04, y: 1.18, leftHandleX: 3.55, leftHandleY: 1.69, rightHandleX: 4.73, rightHandleY: 0.49 },
    { x: 6.92, y: 0, leftHandleX: 6.12, leftHandleY: 0, rightHandleX: 7.72, rightHandleY: 0 },
  ],
  gonialAngle: [
    { x: 90.28, y: 0, leftHandleX: 87.53, leftHandleY: 0, rightHandleX: 93.03, rightHandleY: 0 },
    { x: 98.59, y: 1.25, leftHandleX: 96.67, leftHandleY: 0.72, rightHandleX: 100.38, rightHandleY: 1.65 },
    { x: 104.53, y: 3.66, leftHandleX: 103.24, leftHandleY: 2.97, rightHandleX: 106.14, rightHandleY: 4.36 },
    { x: 108.82, y: 6.51, leftHandleX: 107.66, leftHandleY: 5.63, rightHandleX: 109.81, rightHandleY: 7.41 },
    { x: 111.55, y: 8.68, leftHandleX: 110.34, leftHandleY: 7.98, rightHandleX: 113.07, rightHandleY: 9.58 },
    { x: 115, y: 10, leftHandleX: 114.7, leftHandleY: 10, rightHandleX: 115.3, rightHandleY: 10, fixed: true },
    { x: 121, y: 10, leftHandleX: 120.7, leftHandleY: 10, rightHandleX: 121.3, rightHandleY: 10 },
    { x: 124.45, y: 8.68, leftHandleX: 122.93, leftHandleY: 9.58, rightHandleX: 125.66, rightHandleY: 7.98 },
    { x: 127.18, y: 6.51, leftHandleX: 126.19, leftHandleY: 7.41, rightHandleX: 128.34, rightHandleY: 5.63 },
    { x: 131.47, y: 3.66, leftHandleX: 129.86, leftHandleY: 4.36, rightHandleX: 132.76, rightHandleY: 2.97 },
    { x: 137.41, y: 1.25, leftHandleX: 135.62, leftHandleY: 1.65, rightHandleX: 139.33, rightHandleY: 0.72 },
    { x: 145.72, y: 0, leftHandleX: 142.97, leftHandleY: 0, rightHandleX: 148.47, rightHandleY: 0 },
  ],
  nasofacialAngle: [
    { x: 15.3, y: 0, leftHandleX: 13.05, leftHandleY: 0, rightHandleX: 17.55, rightHandleY: 0 },
    { x: 22.95, y: 1.35, leftHandleX: 20.88, leftHandleY: 0.68, rightHandleX: 24.69, rightHandleY: 1.98 },
    { x: 25.95, y: 3.26, leftHandleX: 25.66, leftHandleY: 2.8, rightHandleX: 26.57, rightHandleY: 4.02 },
    { x: 27.37, y: 5.58, leftHandleX: 27.19, leftHandleY: 4.97, rightHandleX: 27.73, rightHandleY: 6.51 },
    { x: 28.78, y: 8.65, leftHandleX: 28.2, leftHandleY: 7.71, rightHandleX: 29.36, rightHandleY: 9.71 },
    { x: 31, y: 10, leftHandleX: 30.8, leftHandleY: 10, rightHandleX: 31.2, rightHandleY: 10, fixed: true },
    { x: 35, y: 10, leftHandleX: 34.8, leftHandleY: 10, rightHandleX: 35.2, rightHandleY: 10 },
    { x: 37.22, y: 8.65, leftHandleX: 36.64, leftHandleY: 9.71, rightHandleX: 37.8, rightHandleY: 7.71 },
    { x: 38.63, y: 5.58, leftHandleX: 38.27, leftHandleY: 6.51, rightHandleX: 38.81, rightHandleY: 4.97 },
    { x: 40.05, y: 3.26, leftHandleX: 39.43, leftHandleY: 4.02, rightHandleX: 40.34, rightHandleY: 2.8 },
    { x: 43.05, y: 1.35, leftHandleX: 41.31, leftHandleY: 1.98, rightHandleX: 45.12, rightHandleY: 0.68 },
    { x: 50.7, y: 0, leftHandleX: 48.45, leftHandleY: 0, rightHandleX: 52.95, rightHandleY: 0 },
  ],
  upperLipELinePosition: [
    { x: -5.23, y: 0, leftHandleX: -6.33, leftHandleY: 0, rightHandleX: -4.13, rightHandleY: 0 },
    { x: -2.15, y: 1.12, leftHandleX: -2.93, leftHandleY: 0.44, rightHandleX: -1.56, rightHandleY: 1.71 },
    { x: -0.82, y: 3.14, leftHandleX: -1.03, leftHandleY: 2.42, rightHandleX: -0.55, rightHandleY: 3.86 },
    { x: 0.03, y: 6.17, leftHandleX: -0.18, leftHandleY: 5.27, rightHandleX: 0.19, rightHandleY: 6.76 },
    { x: 0.65, y: 8.92, leftHandleX: 0.46, leftHandleY: 8.02, rightHandleX: 0.86, rightHandleY: 9.62 },
    { x: 1.5, y: 10, leftHandleX: 1.3, leftHandleY: 10, rightHandleX: 1.7, rightHandleY: 10, fixed: true },
    { x: 5.5, y: 10, leftHandleX: 5.3, leftHandleY: 10, rightHandleX: 5.7, rightHandleY: 10 },
    { x: 6.35, y: 8.92, leftHandleX: 6.14, leftHandleY: 9.62, rightHandleX: 6.54, rightHandleY: 8.02 },
    { x: 6.97, y: 6.17, leftHandleX: 6.81, leftHandleY: 6.76, rightHandleX: 7.18, rightHandleY: 5.27 },
    { x: 7.82, y: 3.14, leftHandleX: 7.55, leftHandleY: 3.86, rightHandleX: 8.03, rightHandleY: 2.42 },
    { x: 9.15, y: 1.12, leftHandleX: 8.56, leftHandleY: 1.71, rightHandleX: 9.93, rightHandleY: 0.44 },
    { x: 12.23, y: 0, leftHandleX: 11.13, leftHandleY: 0, rightHandleX: 13.33, rightHandleY: 0 },
  ],
  orbitalVector: [
    { x: -11.53, y: 0, leftHandleX: -14.03, leftHandleY: 0, rightHandleX: -9.03, rightHandleY: 0 },
    { x: -6.02, y: 2.15, leftHandleX: -7.43, leftHandleY: 1.13, rightHandleX: -5.41, rightHandleY: 2.7 },
    { x: -4.12, y: 4.68, leftHandleX: -4.45, leftHandleY: 3.98, rightHandleX: -3.68, rightHandleY: 5.58 },
    { x: -1.79, y: 8.52, leftHandleX: -2.19, leftHandleY: 7.89, rightHandleX: -0.94, rightHandleY: 9.63 },
    { x: 1, y: 10, leftHandleX: 0.65, leftHandleY: 10, rightHandleX: 1.35, rightHandleY: 10, fixed: true },
    { x: 8, y: 10, leftHandleX: 7.65, leftHandleY: 10, rightHandleX: 8.35, rightHandleY: 10 },
    { x: 10.79, y: 8.52, leftHandleX: 9.94, leftHandleY: 9.63, rightHandleX: 11.19, rightHandleY: 7.89 },
    { x: 13.12, y: 4.68, leftHandleX: 12.68, leftHandleY: 5.58, rightHandleX: 13.45, rightHandleY: 3.98 },
    { x: 15.02, y: 2.15, leftHandleX: 14.41, leftHandleY: 2.7, rightHandleX: 16.43, rightHandleY: 1.13 },
    { x: 20.53, y: 0, leftHandleX: 18.03, leftHandleY: 0, rightHandleX: 23.03, rightHandleY: 0 },
  ],
  submentalCervicalAngle: [
    { x: 50.48, y: 0, leftHandleX: 44.48, leftHandleY: 0, rightHandleX: 56.48, rightHandleY: 0 },
    { x: 68.31, y: 1.31, leftHandleX: 62.07, leftHandleY: 0.32, rightHandleX: 72.89, rightHandleY: 2.13 },
    { x: 77.76, y: 3.71, leftHandleX: 76, leftHandleY: 2.89, rightHandleX: 80.39, rightHandleY: 4.59 },
    { x: 83.99, y: 6.53, leftHandleX: 82.63, leftHandleY: 5.85, rightHandleX: 85.16, rightHandleY: 7.12 },
    { x: 88.28, y: 8.86, leftHandleX: 86.43, leftHandleY: 7.85, rightHandleX: 89.95, rightHandleY: 9.71 },
    { x: 94, y: 10, leftHandleX: 93.4, leftHandleY: 10, rightHandleX: 94.6, rightHandleY: 10, fixed: true },
    { x: 106, y: 10, leftHandleX: 105.4, leftHandleY: 10, rightHandleX: 106.6, rightHandleY: 10 },
    { x: 111.72, y: 8.86, leftHandleX: 110.05, leftHandleY: 9.71, rightHandleX: 113.57, rightHandleY: 7.85 },
    { x: 116.01, y: 6.53, leftHandleX: 114.84, leftHandleY: 7.12, rightHandleX: 117.37, rightHandleY: 5.85 },
    { x: 122.24, y: 3.71, leftHandleX: 119.61, leftHandleY: 4.59, rightHandleX: 124, rightHandleY: 2.89 },
    { x: 131.69, y: 1.31, leftHandleX: 127.11, leftHandleY: 2.13, rightHandleX: 137.93, rightHandleY: 0.32 },
    { x: 149.52, y: 0, leftHandleX: 143.52, leftHandleY: 0, rightHandleX: 155.52, rightHandleY: 0 },
  ],
  mandibularPlaneAngle: [
    { x: -7.77, y: 0, leftHandleX: -11.27, leftHandleY: 0, rightHandleX: -4.27, rightHandleY: 0 },
    { x: 2.54, y: 1.79, leftHandleX: 0.22, leftHandleY: 1.03, rightHandleX: 3.91, rightHandleY: 2.32 },
    { x: 6.68, y: 3.81, leftHandleX: 5.72, leftHandleY: 3.2, rightHandleX: 7.99, rightHandleY: 4.51 },
    { x: 10.59, y: 6.72, leftHandleX: 9.52, leftHandleY: 5.73, rightHandleX: 12.29, rightHandleY: 8.25 },
    { x: 15, y: 10, leftHandleX: 14.65, leftHandleY: 10, rightHandleX: 15.35, rightHandleY: 10, fixed: true },
    { x: 22, y: 10, leftHandleX: 21.65, leftHandleY: 10, rightHandleX: 22.35, rightHandleY: 10 },
    { x: 26.41, y: 6.72, leftHandleX: 24.71, leftHandleY: 8.25, rightHandleX: 27.48, rightHandleY: 5.73 },
    { x: 30.32, y: 3.81, leftHandleX: 29.01, leftHandleY: 4.51, rightHandleX: 31.28, rightHandleY: 3.2 },
    { x: 34.46, y: 1.79, leftHandleX: 33.09, leftHandleY: 2.32, rightHandleX: 36.78, rightHandleY: 1.03 },
    { x: 44.77, y: 0, leftHandleX: 41.27, leftHandleY: 0, rightHandleX: 48.27, rightHandleY: 0 },
  ],
  browridgeInclinationAngle: [
    { x: -3.51, y: 0, leftHandleX: -6.06, leftHandleY: 0, rightHandleX: -0.96, rightHandleY: 0 },
    { x: 4.99, y: 1.01, leftHandleX: 3.18, leftHandleY: 0.36, rightHandleX: 7.17, rightHandleY: 1.62 },
    { x: 8.52, y: 3.14, leftHandleX: 7.9, leftHandleY: 2.46, rightHandleX: 9.01, rightHandleY: 3.63 },
    { x: 10.62, y: 6.1, leftHandleX: 10.16, leftHandleY: 5.11, rightHandleX: 11.11, rightHandleY: 6.96 },
    { x: 12.63, y: 8.99, leftHandleX: 11.89, leftHandleY: 8.25, rightHandleX: 13.41, rightHandleY: 9.69 },
    { x: 15, y: 10, leftHandleX: 14.65, leftHandleY: 10, rightHandleX: 15.35, rightHandleY: 10, fixed: true },
    { x: 22, y: 10, leftHandleX: 21.65, leftHandleY: 10, rightHandleX: 22.35, rightHandleY: 10 },
    { x: 24.37, y: 8.99, leftHandleX: 23.59, leftHandleY: 9.69, rightHandleX: 25.11, rightHandleY: 8.25 },
    { x: 26.38, y: 6.1, leftHandleX: 25.89, leftHandleY: 6.96, rightHandleX: 26.84, rightHandleY: 5.11 },
    { x: 28.48, y: 3.14, leftHandleX: 27.99, leftHandleY: 3.63, rightHandleX: 29.1, rightHandleY: 2.46 },
    { x: 32.01, y: 1.01, leftHandleX: 29.83, leftHandleY: 1.62, rightHandleX: 33.82, rightHandleY: 0.36 },
    { x: 40.51, y: 0, leftHandleX: 37.96, leftHandleY: 0, rightHandleX: 43.06, rightHandleY: 0 },
  ],
  nasalTipAngle: [
    { x: 100.09, y: 0, leftHandleX: 96.09, leftHandleY: 0, rightHandleX: 104.09, rightHandleY: 0 },
    { x: 112.56, y: 1.37, leftHandleX: 108.3, leftHandleY: 0.51, rightHandleX: 114.95, rightHandleY: 1.94 },
    { x: 118.83, y: 3.94, leftHandleX: 117.66, leftHandleY: 3.08, rightHandleX: 119.67, rightHandleY: 4.55 },
    { x: 121.15, y: 6.25, leftHandleX: 120.44, leftHandleY: 5.43, rightHandleX: 121.73, rightHandleY: 6.76 },
    { x: 123.99, y: 8.44, leftHandleX: 122.7, leftHandleY: 7.71, rightHandleX: 125.16, rightHandleY: 9.29 },
    { x: 128.5, y: 10, leftHandleX: 128, leftHandleY: 10, rightHandleX: 129, rightHandleY: 10, fixed: true },
    { x: 138.5, y: 10, leftHandleX: 138, leftHandleY: 10, rightHandleX: 139, rightHandleY: 10 },
    { x: 143.01, y: 8.44, leftHandleX: 141.84, leftHandleY: 9.29, rightHandleX: 144.3, rightHandleY: 7.71 },
    { x: 145.85, y: 6.25, leftHandleX: 145.27, leftHandleY: 6.76, rightHandleX: 146.56, rightHandleY: 5.43 },
    { x: 148.17, y: 3.94, leftHandleX: 147.33, leftHandleY: 4.55, rightHandleX: 149.34, rightHandleY: 3.08 },
    { x: 154.44, y: 1.37, leftHandleX: 152.05, leftHandleY: 1.94, rightHandleX: 158.7, rightHandleY: 0.51 },
    { x: 166.91, y: 0, leftHandleX: 162.91, leftHandleY: 0, rightHandleX: 170.91, rightHandleY: 0 },
  ],
  nasolabialAngle: [
    { x: 52.11, y: 0, leftHandleX: 45.11, leftHandleY: 0, rightHandleX: 59.11, rightHandleY: 0 },
    { x: 70.41, y: 0.61, leftHandleX: 65.3, leftHandleY: 0.23, rightHandleX: 75.3, rightHandleY: 1.18 },
    { x: 81.32, y: 2.74, leftHandleX: 78.59, leftHandleY: 1.77, rightHandleX: 82.57, rightHandleY: 3.16 },
    { x: 84.62, y: 4.42, leftHandleX: 83.82, leftHandleY: 3.83, rightHandleX: 85.3, rightHandleY: 5.12 },
    { x: 87.01, y: 6.51, leftHandleX: 86.21, leftHandleY: 5.66, rightHandleX: 88.14, rightHandleY: 7.29 },
    { x: 90.3, y: 8.8, leftHandleX: 89.05, leftHandleY: 8.15, rightHandleX: 92.36, rightHandleY: 9.69 },
    { x: 97, y: 10, leftHandleX: 96.15, leftHandleY: 10, rightHandleX: 97.85, rightHandleY: 10, fixed: true },
    { x: 114, y: 10, leftHandleX: 113.15, leftHandleY: 10, rightHandleX: 114.85, rightHandleY: 10 },
    { x: 120.7, y: 8.8, leftHandleX: 118.64, leftHandleY: 9.69, rightHandleX: 121.95, rightHandleY: 8.15 },
    { x: 123.99, y: 6.51, leftHandleX: 122.86, leftHandleY: 7.29, rightHandleX: 124.79, rightHandleY: 5.66 },
    { x: 126.38, y: 4.42, leftHandleX: 125.7, leftHandleY: 5.12, rightHandleX: 127.18, rightHandleY: 3.83 },
    { x: 129.68, y: 2.74, leftHandleX: 128.43, leftHandleY: 3.16, rightHandleX: 132.41, rightHandleY: 1.77 },
    { x: 140.59, y: 0.61, leftHandleX: 135.7, leftHandleY: 1.18, rightHandleX: 145.7, rightHandleY: 0.23 },
    { x: 158.89, y: 0, leftHandleX: 151.89, leftHandleY: 0, rightHandleX: 165.89, rightHandleY: 0 },
  ],
  facialConvexityGlabella: [
    { x: 150.21, y: 0, leftHandleX: 147.21, leftHandleY: 0, rightHandleX: 153.21, rightHandleY: 0 },
    { x: 159.07, y: 1.41, leftHandleX: 157.03, leftHandleY: 0.74, rightHandleX: 160.63, rightHandleY: 2 },
    { x: 163.12, y: 4.09, leftHandleX: 162.34, leftHandleY: 3.31, rightHandleX: 164.09, rightHandleY: 5.03 },
    { x: 166.14, y: 7.76, leftHandleX: 165.46, leftHandleY: 6.56, rightHandleX: 166.54, rightHandleY: 8.29 },
    { x: 167.65, y: 9.14, leftHandleX: 166.92, leftHandleY: 8.72, rightHandleX: 168.43, rightHandleY: 9.67 },
    { x: 170, y: 10, leftHandleX: 169.75, leftHandleY: 10, rightHandleX: 170.25, rightHandleY: 10, fixed: true },
    { x: 175, y: 10, leftHandleX: 174.75, leftHandleY: 10, rightHandleX: 175.25, rightHandleY: 10 },
    { x: 177.35, y: 9.14, leftHandleX: 176.57, leftHandleY: 9.67, rightHandleX: 178.08, rightHandleY: 8.72 },
    { x: 178.86, y: 7.76, leftHandleX: 178.46, leftHandleY: 8.29, rightHandleX: 179.54, rightHandleY: 6.56 },
    { x: 181.88, y: 4.09, leftHandleX: 180.91, leftHandleY: 5.03, rightHandleX: 182.66, rightHandleY: 3.31 },
    { x: 185.93, y: 1.41, leftHandleX: 184.37, leftHandleY: 2, rightHandleX: 187.97, rightHandleY: 0.74 },
    { x: 194.79, y: 0, leftHandleX: 191.79, leftHandleY: 0, rightHandleX: 197.79, rightHandleY: 0 },
  ],
  totalFacialConvexity: [
    { x: 115.67, y: 0, leftHandleX: 112.17, leftHandleY: 0, rightHandleX: 119.17, rightHandleY: 0 },
    { x: 124.6, y: 1.08, leftHandleX: 121.88, leftHandleY: 0.57, rightHandleX: 127.82, rightHandleY: 1.9 },
    { x: 131.27, y: 3.81, leftHandleX: 130.31, leftHandleY: 2.93, rightHandleX: 132.23, rightHandleY: 4.48 },
    { x: 133.98, y: 6.4, leftHandleX: 133.3, leftHandleY: 5.5, rightHandleX: 134.72, rightHandleY: 7.23 },
    { x: 136.87, y: 9, leftHandleX: 135.68, leftHandleY: 8.22, rightHandleX: 137.32, rightHandleY: 9.44 },
    { x: 140, y: 10, leftHandleX: 139.65, leftHandleY: 10, rightHandleX: 140.35, rightHandleY: 10, fixed: true },
    { x: 147, y: 10, leftHandleX: 146.65, leftHandleY: 10, rightHandleX: 147.35, rightHandleY: 10 },
    { x: 150.13, y: 9, leftHandleX: 149.68, leftHandleY: 9.44, rightHandleX: 151.32, rightHandleY: 8.22 },
    { x: 153.02, y: 6.4, leftHandleX: 152.28, leftHandleY: 7.23, rightHandleX: 153.7, rightHandleY: 5.5 },
    { x: 155.73, y: 3.81, leftHandleX: 154.77, leftHandleY: 4.48, rightHandleX: 156.69, rightHandleY: 2.93 },
    { x: 162.4, y: 1.08, leftHandleX: 159.18, leftHandleY: 1.9, rightHandleX: 165.12, rightHandleY: 0.57 },
    { x: 171.33, y: 0, leftHandleX: 167.83, leftHandleY: 0, rightHandleX: 174.83, rightHandleY: 0 },
  ],
  nasalProjection: [
    { x: 0.13, y: 0, leftHandleX: 0.08, leftHandleY: 0, rightHandleX: 0.16, rightHandleY: 0 },
    { x: 0.23, y: 0.44, leftHandleX: 0.2, leftHandleY: 0.15, rightHandleX: 0.26, rightHandleY: 0.7 },
    { x: 0.35, y: 1.88, leftHandleX: 0.31, leftHandleY: 1.18, rightHandleX: 0.38, rightHandleY: 2.44 },
    { x: 0.42, y: 3.77, leftHandleX: 0.41, leftHandleY: 3.18, rightHandleX: 0.43, rightHandleY: 4.23 },
    { x: 0.46, y: 5.79, leftHandleX: 0.45, leftHandleY: 4.84, rightHandleX: 0.48, rightHandleY: 6.5 },
    { x: 0.51, y: 8.4, leftHandleX: 0.5, leftHandleY: 7.62, rightHandleX: 0.53, rightHandleY: 9.58 },
    { x: 0.58, y: 10, leftHandleX: 0.58, leftHandleY: 10, rightHandleX: 0.58, rightHandleY: 10, fixed: true },
    { x: 0.65, y: 10, leftHandleX: 0.65, leftHandleY: 10, rightHandleX: 0.65, rightHandleY: 10 },
    { x: 0.72, y: 8.4, leftHandleX: 0.7, leftHandleY: 9.58, rightHandleX: 0.73, rightHandleY: 7.62 },
    { x: 0.77, y: 5.79, leftHandleX: 0.75, leftHandleY: 6.5, rightHandleX: 0.78, rightHandleY: 4.84 },
    { x: 0.81, y: 3.77, leftHandleX: 0.8, leftHandleY: 4.23, rightHandleX: 0.82, rightHandleY: 3.18 },
    { x: 0.88, y: 1.88, leftHandleX: 0.85, leftHandleY: 2.44, rightHandleX: 0.92, rightHandleY: 1.18 },
    { x: 1, y: 0.44, leftHandleX: 0.97, leftHandleY: 0.7, rightHandleX: 1.03, rightHandleY: 0.15 },
    { x: 1.1, y: 0, leftHandleX: 1.07, leftHandleY: 0, rightHandleX: 1.15, rightHandleY: 0 },
  ],
  nasalWidthToHeightRatio: [
    { x: 0.22, y: 0, leftHandleX: 0.15, leftHandleY: 0, rightHandleX: 0.3, rightHandleY: 0 },
    { x: 0.41, y: 1.29, leftHandleX: 0.34, leftHandleY: 0.42, rightHandleX: 0.46, rightHandleY: 2.13 },
    { x: 0.5, y: 3.77, leftHandleX: 0.48, leftHandleY: 2.97, rightHandleX: 0.51, rightHandleY: 4.23 },
    { x: 0.54, y: 5.92, leftHandleX: 0.52, leftHandleY: 5.08, rightHandleX: 0.55, rightHandleY: 6.98 },
    { x: 0.59, y: 8.65, leftHandleX: 0.57, leftHandleY: 7.91, rightHandleX: 0.61, rightHandleY: 9.68 },
    { x: 0.67, y: 10, leftHandleX: 0.66, leftHandleY: 10, rightHandleX: 0.68, rightHandleY: 10, fixed: true },
    { x: 0.83, y: 10, leftHandleX: 0.82, leftHandleY: 10, rightHandleX: 0.84, rightHandleY: 10 },
    { x: 0.91, y: 8.65, leftHandleX: 0.89, leftHandleY: 9.68, rightHandleX: 0.93, rightHandleY: 7.91 },
    { x: 0.96, y: 5.92, leftHandleX: 0.95, leftHandleY: 6.98, rightHandleX: 0.98, rightHandleY: 5.08 },
    { x: 1, y: 3.77, leftHandleX: 0.99, leftHandleY: 4.23, rightHandleX: 1.02, rightHandleY: 2.97 },
    { x: 1.09, y: 1.29, leftHandleX: 1.04, leftHandleY: 2.13, rightHandleX: 1.16, rightHandleY: 0.42 },
    { x: 1.28, y: 0, leftHandleX: 1.2, leftHandleY: 0, rightHandleX: 1.35, rightHandleY: 0 },
  ],
  lowerLipELinePosition: [
    { x: -5.87, y: 0, leftHandleX: -6.87, leftHandleY: 0, rightHandleX: -4.87, rightHandleY: 0 },
    { x: -2.71, y: 1.01, leftHandleX: -3.53, leftHandleY: 0.34, rightHandleX: -2.29, rightHandleY: 1.33 },
    { x: -0.97, y: 3.26, leftHandleX: -1.26, leftHandleY: 2.38, rightHandleX: -0.7, rightHandleY: 4.02 },
    { x: -0.35, y: 5.77, leftHandleX: -0.57, leftHandleY: 4.8, rightHandleX: -0.18, rightHandleY: 6.46 },
    { x: 0.38, y: 8.52, leftHandleX: 0.07, leftHandleY: 7.53, rightHandleX: 0.69, rightHandleY: 9.48 },
    { x: 1.4, y: 10, leftHandleX: 1.26, leftHandleY: 10, rightHandleX: 1.54, rightHandleY: 10, fixed: true },
    { x: 4.1, y: 10, leftHandleX: 3.97, leftHandleY: 10, rightHandleX: 4.24, rightHandleY: 10 },
    { x: 5.12, y: 8.52, leftHandleX: 4.81, leftHandleY: 9.48, rightHandleX: 5.43, rightHandleY: 7.53 },
    { x: 5.85, y: 5.77, leftHandleX: 5.68, leftHandleY: 6.46, rightHandleX: 6.07, rightHandleY: 4.8 },
    { x: 6.47, y: 3.26, leftHandleX: 6.2, leftHandleY: 4.02, rightHandleX: 6.76, rightHandleY: 2.38 },
    { x: 8.21, y: 1.01, leftHandleX: 7.79, leftHandleY: 1.33, rightHandleX: 9.03, rightHandleY: 0.34 },
    { x: 11.37, y: 0, leftHandleX: 10.37, leftHandleY: 0, rightHandleX: 12.37, rightHandleY: 0 },
  ],
  upperLipBurstoneLine: [
    { x: -11.75, y: 0, leftHandleX: -13, leftHandleY: 0, rightHandleX: -10.5, rightHandleY: 0 },
    { x: -8.25, y: 1.14, leftHandleX: -9.08, leftHandleY: 0.55, rightHandleX: -7.45, rightHandleY: 1.92 },
    { x: -6.68, y: 3.85, leftHandleX: -6.88, leftHandleY: 2.97, rightHandleX: -6.36, rightHandleY: 5.1 },
    { x: -6.08, y: 6.53, leftHandleX: -6.22, leftHandleY: 5.88, rightHandleX: -5.94, rightHandleY: 7.24 },
    { x: -5.59, y: 8.67, leftHandleX: -5.75, leftHandleY: 8.13, rightHandleX: -5.43, rightHandleY: 9.48 },
    { x: -4.7, y: 10, leftHandleX: -4.82, leftHandleY: 10, rightHandleX: -4.58, rightHandleY: 10, fixed: true },
    { x: -2.3, y: 10, leftHandleX: -2.42, leftHandleY: 10, rightHandleX: -2.18, rightHandleY: 10 },
    { x: -1.41, y: 8.67, leftHandleX: -1.57, leftHandleY: 9.48, rightHandleX: -1.25, rightHandleY: 8.13 },
    { x: -0.92, y: 6.53, leftHandleX: -1.06, leftHandleY: 7.24, rightHandleX: -0.78, rightHandleY: 5.88 },
    { x: -0.32, y: 3.85, leftHandleX: -0.64, leftHandleY: 5.1, rightHandleX: -0.12, rightHandleY: 2.97 },
    { x: 1.25, y: 1.14, leftHandleX: 0.45, leftHandleY: 1.92, rightHandleX: 2.08, rightHandleY: 0.55 },
    { x: 4.75, y: 0, leftHandleX: 3.5, leftHandleY: 0, rightHandleX: 6, rightHandleY: 0 },
  ],
  noseTipRotationAngle: [
    { x: -18.53, y: 0, leftHandleX: -23.08, leftHandleY: 0, rightHandleX: -13.98, rightHandleY: 0 },
    { x: -7.9, y: 0.84, leftHandleX: -10.83, leftHandleY: 0.46, rightHandleX: -3.65, rightHandleY: 1.58 },
    { x: 0.74, y: 3.31, leftHandleX: -0.87, leftHandleY: 2.55, rightHandleX: 2.28, rightHandleY: 3.98 },
    { x: 4.34, y: 6.04, leftHandleX: 3.46, leftHandleY: 4.89, rightHandleX: 5.07, rightHandleY: 6.72 },
    { x: 6.83, y: 8.32, leftHandleX: 5.87, leftHandleY: 7.54, rightHandleX: 7.85, rightHandleY: 9.35 },
    { x: 11.5, y: 10, leftHandleX: 11, leftHandleY: 10, rightHandleX: 12, rightHandleY: 10, fixed: true },
    { x: 21.5, y: 10, leftHandleX: 21, leftHandleY: 10, rightHandleX: 22, rightHandleY: 10 },
    { x: 26.17, y: 8.32, leftHandleX: 25.15, leftHandleY: 9.35, rightHandleX: 27.13, rightHandleY: 7.54 },
    { x: 28.66, y: 6.04, leftHandleX: 27.93, leftHandleY: 6.72, rightHandleX: 29.54, rightHandleY: 4.89 },
    { x: 32.26, y: 3.31, leftHandleX: 30.72, leftHandleY: 3.98, rightHandleX: 33.87, rightHandleY: 2.55 },
    { x: 40.9, y: 0.84, leftHandleX: 36.65, leftHandleY: 1.58, rightHandleX: 43.83, rightHandleY: 0.46 },
    { x: 51.53, y: 0, leftHandleX: 46.98, leftHandleY: 0, rightHandleX: 56.08, rightHandleY: 0 },
  ],
  frankfortTipAngle: [
    { x: 2.77, y: 0, leftHandleX: -1.73, leftHandleY: 0, rightHandleX: 7.27, rightHandleY: 0 },
    { x: 17.34, y: 2, leftHandleX: 13.35, leftHandleY: 0.82, rightHandleX: 19.52, rightHandleY: 2.61 },
    { x: 21.69, y: 3.87, leftHandleX: 20.75, leftHandleY: 3.26, rightHandleX: 22.56, rightHandleY: 4.44 },
    { x: 24.95, y: 6.44, leftHandleX: 23.79, leftHandleY: 5.39, rightHandleX: 25.68, rightHandleY: 7.07 },
    { x: 28.15, y: 8.75, leftHandleX: 26.91, leftHandleY: 8.01, rightHandleX: 29.52, rightHandleY: 9.52 },
    { x: 32, y: 10, leftHandleX: 31.7, leftHandleY: 10, rightHandleX: 32.3, rightHandleY: 10, fixed: true },
    { x: 38, y: 10, leftHandleX: 37.7, leftHandleY: 10, rightHandleX: 38.3, rightHandleY: 10 },
    { x: 41.85, y: 8.75, leftHandleX: 40.48, leftHandleY: 9.52, rightHandleX: 43.09, rightHandleY: 8.01 },
    { x: 45.05, y: 6.44, leftHandleX: 44.32, leftHandleY: 7.07, rightHandleX: 46.21, rightHandleY: 5.39 },
    { x: 48.31, y: 3.87, leftHandleX: 47.44, leftHandleY: 4.44, rightHandleX: 49.25, rightHandleY: 3.26 },
    { x: 52.66, y: 2, leftHandleX: 50.48, leftHandleY: 2.61, rightHandleX: 56.65, rightHandleY: 0.82 },
    { x: 67.23, y: 0, leftHandleX: 62.73, leftHandleY: 0, rightHandleX: 71.73, rightHandleY: 0 },
  ],
  anteriorFacialDepth: [
    { x: 29.05, y: 0, leftHandleX: 25.05, leftHandleY: 0, rightHandleX: 33.05, rightHandleY: 0 },
    { x: 44.91, y: 1.05, leftHandleX: 42.51, leftHandleY: 0.59, rightHandleX: 47.44, rightHandleY: 1.43 },
    { x: 52.58, y: 3.3, leftHandleX: 50.76, leftHandleY: 2.29, rightHandleX: 54.46, rightHandleY: 4.12 },
    { x: 57.26, y: 6.35, leftHandleX: 56.09, leftHandleY: 5.57, rightHandleX: 58.36, rightHandleY: 7.09 },
    { x: 61.55, y: 9, leftHandleX: 59.66, leftHandleY: 8.12, rightHandleX: 63.17, rightHandleY: 9.79 },
    { x: 64.5, y: 10, leftHandleX: 64.35, leftHandleY: 10, rightHandleX: 64.65, rightHandleY: 10, fixed: true },
    { x: 67.5, y: 10, leftHandleX: 67.35, leftHandleY: 10, rightHandleX: 67.65, rightHandleY: 10 },
    { x: 70.45, y: 9, leftHandleX: 68.83, leftHandleY: 9.79, rightHandleX: 72.34, rightHandleY: 8.12 },
    { x: 74.74, y: 6.35, leftHandleX: 73.64, leftHandleY: 7.09, rightHandleX: 75.91, rightHandleY: 5.57 },
    { x: 79.42, y: 3.3, leftHandleX: 77.54, leftHandleY: 4.12, rightHandleX: 81.24, rightHandleY: 2.29 },
    { x: 87.09, y: 1.05, leftHandleX: 84.56, leftHandleY: 1.43, rightHandleX: 89.49, rightHandleY: 0.59 },
    { x: 102.95, y: 0, leftHandleX: 98.95, leftHandleY: 0, rightHandleX: 106.95, rightHandleY: 0 },
  ],
  upperForeheadSlope: [
    { x: -14.3, y: 0.02, leftHandleX: -15.8, leftHandleY: 0.02, rightHandleX: -12.8, rightHandleY: 0.02 },
    { x: -8.76, y: 1.51, leftHandleX: -10.14, leftHandleY: 0.78, rightHandleX: -7.75, rightHandleY: 2.07 },
    { x: -5.74, y: 3.9, leftHandleX: -6.51, leftHandleY: 3.15, rightHandleX: -5.02, rightHandleY: 4.54 },
    { x: -2.53, y: 7.81, leftHandleX: -3.54, leftHandleY: 6.35, rightHandleX: -1.27, rightHandleY: 9.96 },
    { x: 0, y: 10, leftHandleX: -0.1, leftHandleY: 10, rightHandleX: 0.1, rightHandleY: 10, fixed: true },
    { x: 2, y: 10, leftHandleX: 1.9, leftHandleY: 10, rightHandleX: 2.1, rightHandleY: 10 },
    { x: 4.53, y: 7.81, leftHandleX: 3.27, leftHandleY: 9.96, rightHandleX: 5.54, rightHandleY: 6.35 },
    { x: 7.74, y: 3.9, leftHandleX: 7.02, leftHandleY: 4.54, rightHandleX: 8.51, rightHandleY: 3.15 },
    { x: 10.76, y: 1.51, leftHandleX: 9.75, leftHandleY: 2.07, rightHandleX: 12.14, rightHandleY: 0.78 },
    { x: 16.3, y: 0.02, leftHandleX: 14.8, leftHandleY: 0.02, rightHandleX: 17.8, rightHandleY: 0.02 },
  ],
  zAngle: [
    { x: 51.74, y: 0, leftHandleX: 48.74, leftHandleY: 0, rightHandleX: 54.74, rightHandleY: 0 },
    { x: 60.66, y: 1.07, leftHandleX: 58.58, leftHandleY: 0.56, rightHandleX: 63.52, rightHandleY: 1.55 },
    { x: 68.8, y: 3.56, leftHandleX: 67.45, leftHandleY: 2.89, rightHandleX: 70.31, rightHandleY: 4.28 },
    { x: 72.44, y: 5.75, leftHandleX: 71.71, leftHandleY: 5.12, rightHandleX: 73.36, rightHandleY: 6.77 },
    { x: 75.35, y: 8.58, leftHandleX: 74.38, leftHandleY: 7.7, rightHandleX: 76.61, rightHandleY: 9.66 },
    { x: 78, y: 10, leftHandleX: 77.8, leftHandleY: 10, rightHandleX: 78.2, rightHandleY: 10, fixed: true },
    { x: 82, y: 10, leftHandleX: 81.8, leftHandleY: 10, rightHandleX: 82.2, rightHandleY: 10 },
    { x: 84.65, y: 8.58, leftHandleX: 83.39, leftHandleY: 9.66, rightHandleX: 85.62, rightHandleY: 7.7 },
    { x: 87.56, y: 5.75, leftHandleX: 86.64, leftHandleY: 6.77, rightHandleX: 88.29, rightHandleY: 5.12 },
    { x: 91.2, y: 3.56, leftHandleX: 89.69, leftHandleY: 4.28, rightHandleX: 92.55, rightHandleY: 2.89 },
    { x: 99.34, y: 1.07, leftHandleX: 96.48, leftHandleY: 1.55, rightHandleX: 101.42, rightHandleY: 0.56 },
    { x: 108.26, y: 0, leftHandleX: 105.26, leftHandleY: 0, rightHandleX: 111.26, rightHandleY: 0 },
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
 * FaceIQ Exponential Decay Scoring Algorithm with Directional/Dimorphic Support
 *
 * Standard: score = maxScore × e^(-decayRate × deviation)
 *
 * Directional scoring (polarity):
 * - 'higher_is_better': Values above safeFloor but below ideal get softZoneScore
 *   Example: Canthal Tilt of 3° is still positive/good, just not peak ideal (6-8°)
 * - 'lower_is_better': Values below safeCeiling but above ideal get softZoneScore
 *   Example: Short philtrum is still attractive even if shorter than "ideal"
 */
export function calculateFaceIQScore(
  value: number,
  config: MetricConfig
): number {
  const {
    id,
    idealMin,
    idealMax,
    decayRate,
    maxScore,
    customCurve,
    polarity = 'balanced',
    safeFloor,
    safeCeiling,
    softZoneScore = 8.0, // Default "Good" score for acceptable-but-not-ideal values
  } = config;

  // Use custom curve if available in config
  if (customCurve && customCurve.mode === 'custom') {
    return interpolateCustomCurve(value, customCurve.points, maxScore);
  }

  // Check for pre-defined Bezier curve from FaceIQ (66 metrics)
  const bezierCurve = FACEIQ_BEZIER_CURVES[id];
  if (bezierCurve && bezierCurve.mode === 'custom') {
    return interpolateCustomCurve(value, bezierCurve.points, maxScore);
  }

  // Perfect score within ideal range
  if (value >= idealMin && value <= idealMax) {
    return maxScore;
  }

  // Handle directional/dimorphic scoring
  if (polarity === 'higher_is_better' && safeFloor !== undefined) {
    // Higher values are good. Only values below safeFloor are true weaknesses.
    if (value >= safeFloor && value < idealMin) {
      // Value is in the "acceptable but not ideal" zone
      // Give a passing score that decreases linearly as we approach the floor
      const zoneRange = idealMin - safeFloor;
      const distanceFromIdeal = idealMin - value;
      const t = zoneRange > 0 ? distanceFromIdeal / zoneRange : 0;
      // Linear interpolation: idealMin → maxScore, safeFloor → softZoneScore
      return maxScore - t * (maxScore - softZoneScore);
    }
    if (value >= idealMax) {
      // Values above ideal are still excellent for 'higher_is_better'
      // Apply gentler decay (1/3 the normal rate)
      const deviation = value - idealMax;
      const gentleDecay = decayRate / 3;
      return Math.max(softZoneScore, maxScore * Math.exp(-gentleDecay * deviation));
    }
    // Below safeFloor - apply normal (or harsher) exponential decay
    if (value < safeFloor) {
      const deviation = safeFloor - value;
      return Math.max(0, softZoneScore * Math.exp(-decayRate * deviation));
    }
  }

  if (polarity === 'lower_is_better' && safeCeiling !== undefined) {
    // Lower values are good. Only values above safeCeiling are true weaknesses.
    if (value <= safeCeiling && value > idealMax) {
      // Value is in the "acceptable but not ideal" zone
      const zoneRange = safeCeiling - idealMax;
      const distanceFromIdeal = value - idealMax;
      const t = zoneRange > 0 ? distanceFromIdeal / zoneRange : 0;
      // Linear interpolation: idealMax → maxScore, safeCeiling → softZoneScore
      return maxScore - t * (maxScore - softZoneScore);
    }
    if (value <= idealMin) {
      // Values below ideal are still excellent for 'lower_is_better'
      // Apply gentler decay (1/3 the normal rate)
      const deviation = idealMin - value;
      const gentleDecay = decayRate / 3;
      return Math.max(softZoneScore, maxScore * Math.exp(-gentleDecay * deviation));
    }
    // Above safeCeiling - apply normal exponential decay
    if (value > safeCeiling) {
      const deviation = value - safeCeiling;
      return Math.max(0, softZoneScore * Math.exp(-decayRate * deviation));
    }
  }

  // Default balanced scoring: deviation in either direction is equally bad
  const deviation = value < idealMin
    ? idealMin - value
    : value - idealMax;

  // Exponential decay
  const score = maxScore * Math.exp(-decayRate * deviation);

  return Math.max(0, Math.min(maxScore, score));
}

/**
 * Check if a metric value is in an "acceptable" zone (not a true weakness).
 * Used by InsightsEngine to prevent false positives.
 */
export function isValueAcceptable(
  value: number,
  config: MetricConfig
): { acceptable: boolean; reason: string } {
  const {
    idealMin,
    idealMax,
    polarity = 'balanced',
    safeFloor,
    safeCeiling,
  } = config;

  // Within ideal range is always acceptable
  if (value >= idealMin && value <= idealMax) {
    return { acceptable: true, reason: 'within_ideal' };
  }

  // Check directional acceptability
  if (polarity === 'higher_is_better') {
    if (value >= idealMax) {
      return { acceptable: true, reason: 'above_ideal_higher_is_better' };
    }
    if (safeFloor !== undefined && value >= safeFloor) {
      return { acceptable: true, reason: 'above_safe_floor' };
    }
    // Below safe floor - true weakness
    return { acceptable: false, reason: 'below_safe_floor' };
  }

  if (polarity === 'lower_is_better') {
    if (value <= idealMin) {
      return { acceptable: true, reason: 'below_ideal_lower_is_better' };
    }
    if (safeCeiling !== undefined && value <= safeCeiling) {
      return { acceptable: true, reason: 'below_safe_ceiling' };
    }
    // Above safe ceiling - true weakness
    return { acceptable: false, reason: 'above_safe_ceiling' };
  }

  // Balanced polarity - outside ideal is not acceptable
  return { acceptable: false, reason: 'outside_ideal_balanced' };
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

      // Lower Third Internal Ratio (subnasale to stomion / subnasale to menton)
      const stomion = getLandmark(landmarks, 'mouth_middle');
      if (stomion) {
        const subnasaleToStomion = distance(subnasale, stomion);
        const subnasaleToMenton = distance(subnasale, menton);
        if (subnasaleToMenton > 0) {
          const lowerThirdAlt = (subnasaleToStomion / subnasaleToMenton) * 100;
          addMeasurement('lowerThirdProportionAlt', lowerThirdAlt);
        }
      }
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
  // Positive tilt = lateral canthus is higher than medial (lower y in screen coords)
  // Use abs(deltaX) to avoid sign issues between left/right eye
  if (leftCanthusM && leftCanthusL) {
    const deltaY = leftCanthusM.y - leftCanthusL.y;  // positive if lateral is higher
    const deltaX = Math.abs(leftCanthusM.x - leftCanthusL.x);  // eye width (always positive)
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
      if (eyeHeight > 0) {
        // Eye aspect ratio = width / height (ideal ~3.0-3.5 for almond shape)
        addMeasurement('eyeAspectRatio', eyeWidth / eyeHeight);
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

  // CHEEK FULLNESS (Malar Convexity)
  // Measures how much the cheek protrudes outward from the line between zygion and gonion
  // Positive = Full/Youthful cheeks; Negative = Hollow/Gaunt cheeks
  const leftMalar = getLandmark(landmarks, 'left_malar');
  const rightMalar = getLandmark(landmarks, 'right_malar');

  if (leftZygion && rightZygion && leftGonion && rightGonion && leftMalar && rightMalar) {
    // Helper: Calculate signed perpendicular distance from point to line
    const pointLineDistance = (p: Point, a: Point, b: Point): number => {
      // Cross product: (bx - ax)(py - ay) - (by - ay)(px - ax)
      const cross = (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
      const lineLength = Math.sqrt(Math.pow(b.x - a.x, 2) + Math.pow(b.y - a.y, 2));
      return cross / lineLength;
    };

    // Calculate convexity for both sides
    const rightFullness = Math.abs(pointLineDistance(rightMalar, rightZygion, rightGonion));
    const leftFullness = Math.abs(pointLineDistance(leftMalar, leftZygion, leftGonion));

    // Normalize by face width to make scale-invariant
    const faceWidth = distance(leftZygion, rightZygion);
    if (faceWidth > 0) {
      const rawScore = (rightFullness + leftFullness) / 2;
      const normalizedScore = (rawScore / faceWidth) * 100;
      addMeasurement('cheekFullness', normalizedScore);
    }
  }

  // CHIN WIDTH
  // Measures horizontal width of the mental protuberance (chin bone)
  // Uses left/right mentum lateralis landmarks (132, 361 in MediaPipe)
  const leftMentumLat = getLandmark(landmarks, 'left_mentum_lateralis');
  const rightMentumLat = getLandmark(landmarks, 'right_mentum_lateralis');

  if (leftMentumLat && rightMentumLat && leftZygion && rightZygion) {
    const chinWidth = distance(leftMentumLat, rightMentumLat);
    const faceWidth = distance(leftZygion, rightZygion);
    if (faceWidth > 0) {
      const chinWidthPercent = (chinWidth / faceWidth) * 100;
      addMeasurement('chinWidth', chinWidthPercent);
    }
  }

  // EYEBROW THICKNESS
  // Measures vertical height of eyebrow at thickest point
  // Landmarks: brow top (66, 296) and brow bottom (46, 276)
  const leftBrowTop = getLandmark(landmarks, 'left_supercilium_superior');  // 52 in mapping, but we need 66
  const leftBrowBottom = getLandmark(landmarks, 'left_supercilium_apex');  // 105 in mapping, but we need 46
  const rightBrowTop = getLandmark(landmarks, 'right_supercilium_superior');  // 282 in mapping, but we need 296
  const rightBrowBottom = getLandmark(landmarks, 'right_supercilium_apex');  // 334 in mapping, but we need 276

  if (leftBrowTop && leftBrowBottom && rightBrowTop && rightBrowBottom && leftCanthusM && leftCanthusL) {
    const leftThickness = distance(leftBrowTop, leftBrowBottom);
    const rightThickness = distance(rightBrowTop, rightBrowBottom);
    const avgThickness = (leftThickness + rightThickness) / 2;

    // Normalize by eye height to make scale-invariant
    const leftPalpSup = getLandmark(landmarks, 'left_palpebra_superior');
    const leftPalpInf = getLandmark(landmarks, 'left_palpebra_inferior');
    if (leftPalpSup && leftPalpInf) {
      const eyeHeight = distance(leftPalpSup, leftPalpInf);
      if (eyeHeight > 0) {
        const normalizedThickness = (avgThickness / eyeHeight) * 10.0;  // Scale factor
        addMeasurement('eyebrowThickness', normalizedThickness);
      }
    }
  }

  // UPPER EYELID EXPOSURE
  // Measures visible skin between eyelash line and eyelid crease
  // Landmarks: crease (27, 257) and lid top/lash line (159, 386)
  if (leftCanthusM && leftCanthusL) {
    const leftPalpSup = getLandmark(landmarks, 'left_palpebra_superior');
    const leftPalpInf = getLandmark(landmarks, 'left_palpebra_inferior');
    const leftCrease = getLandmark(landmarks, 'left_pretarsal_skin_crease');

    if (leftPalpSup && leftPalpInf && leftCrease) {
      // Distance from brow bone/crease to lash line
      const lidGap = distance(leftCrease, leftPalpSup);

      // Normalize by total eye opening height
      const eyeOpen = distance(leftPalpSup, leftPalpInf);
      if (eyeOpen > 0) {
        const exposure = lidGap / eyeOpen;
        addMeasurement('upperEyelidExposure', exposure);
      }
    }
  }

  // TEAR TROUGH DEPTH
  // Placeholder metric: Default to 0.2 (clean/good) since we can't measure depth from 2D landmarks
  // Future upgrade: Implement OpenCV color sampler to detect darkness under eyes
  // For now, assign a neutral/good value so it doesn't unfairly penalize users
  addMeasurement('tearTroughDepth', 0.2);

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

  // E-LINE MEASUREMENTS (Ricketts)
  // E-line runs from pronasale (nose tip) to soft tissue pogonion (chin)
  // FaceIQ convention: positive = in front of line, negative = behind
  // perpendicularDistance returns positive for behind, so we negate
  if (pronasale && pogonion && labraleSuperius && labraleInferius) {
    const upperLipDist = perpendicularDistance(labraleSuperius, pronasale, pogonion);
    const lowerLipDist = perpendicularDistance(labraleInferius, pronasale, pogonion);
    // Negate to match FaceIQ sign convention (positive = protruding/in front)
    addMeasurement('eLineUpperLip', -upperLipDist);
    addMeasurement('eLineLowerLip', -lowerLipDist);
  }

  // BURSTONE LINE MEASUREMENTS
  // Burstone line runs from subnasale to soft tissue pogonion
  // FaceIQ convention: negative = behind line (ideal is -4.7 to -2.3 for upper, -2.8 to -1.2 for lower)
  if (subnasale && pogonion && labraleSuperius && labraleInferius) {
    const upperLipBurstone = perpendicularDistance(labraleSuperius, subnasale, pogonion);
    const lowerLipBurstone = perpendicularDistance(labraleInferius, subnasale, pogonion);
    // Negate to match FaceIQ sign convention (negative = behind)
    addMeasurement('burstoneUpperLip', -upperLipBurstone);
    addMeasurement('burstoneLowerLip', -lowerLipBurstone);
  }

  // S-LINE MEASUREMENTS (Steiner)
  // S-line runs from columella (or subnasale) to soft tissue pogonion
  // FaceIQ convention: positive = in front of line, negative = behind
  const sLineStart = columella || subnasale;
  if (sLineStart && pogonion && labraleSuperius && labraleInferius) {
    const upperLipSLine = perpendicularDistance(labraleSuperius, sLineStart, pogonion);
    const lowerLipSLine = perpendicularDistance(labraleInferius, sLineStart, pogonion);
    // Negate to match FaceIQ sign convention (positive = protruding/in front)
    addMeasurement('sLineUpperLip', -upperLipSLine);
    addMeasurement('sLineLowerLip', -lowerLipSLine);
  }

  // HOLDAWAY H-LINE MEASUREMENT
  // H-line runs from upper lip (labrale superius) to soft tissue pogonion
  // Measures lower lip distance from this line
  // FaceIQ convention: positive = in front of line (ideal 0-4mm)
  if (labraleSuperius && pogonion && labraleInferius) {
    const lowerLipHLine = perpendicularDistance(labraleInferius, labraleSuperius, pogonion);
    // Negate to match FaceIQ sign convention (positive = protruding/in front)
    addMeasurement('holdawayHLine', -lowerLipHLine);
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
