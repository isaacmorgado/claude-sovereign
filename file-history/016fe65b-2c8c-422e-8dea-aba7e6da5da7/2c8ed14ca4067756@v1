/**
 * PSL (Pretty Scale Level) Type Definitions
 *
 * Comprehensive types for the PSL scoring system including:
 * - Height input and rating
 * - Body composition analysis
 * - PSL calculation results
 * - Tier classification
 */

// ============================================
// INPUT TYPES
// ============================================

export type Gender = 'male' | 'female';

export type MuscleLevel = 'low' | 'medium' | 'medium-high' | 'high' | 'very-high' | 'extreme';

export interface BodyAnalysis {
  bodyFatPercent: number;
  muscleLevel: MuscleLevel;
  weightKg?: number;        // Weight for FFMI calculation
}

// Claude Vision qualitative data for PSL bonuses/penalties
export interface PSLVisionData {
  skin?: { clarity?: number };
  hair?: { hairline_nw?: number };
  teeth?: { alignment?: string };
  facial_features?: { hollow_cheeks?: number };
}

export interface PSLInput {
  faceScore: number;        // 0-10 from harmony analysis
  heightCm: number;         // User input height in cm
  gender: Gender;
  bodyAnalysis?: BodyAnalysis;  // From AI vision (paid)
  weightKg?: number;        // Weight for FFMI calculation (can be separate from bodyAnalysis)
  failos?: string[];        // Detected major failos
  vision?: PSLVisionData;   // Claude Vision qualitative data
}

// ============================================
// BREAKDOWN TYPES
// ============================================

export interface ComponentScore {
  raw: number;              // Original 0-10 score
  weighted: number;         // After applying weight (e.g., × 0.75)
}

export interface BonusBreakdown {
  threshold: number;        // Face/Height/Body threshold bonuses
  synergy: number;          // Pair/Triple synergy bonuses
  total: number;            // Sum of all bonuses
}

export interface FFMIData {
  ffmi: number;
  normalizedFFMI: number;
  leanMassKg: number;
  rating: number;
  category: string;
}

export interface BodyScoreInfo {
  method: 'ffmi' | 'table' | 'default';  // How body score was calculated
  ffmiData?: FFMIData;                    // FFMI details when method is 'ffmi'
}

export interface PSLBreakdown {
  face: ComponentScore;
  height: ComponentScore;
  body: ComponentScore;
  bodyInfo?: BodyScoreInfo;              // Body score calculation details
  bonuses: BonusBreakdown;
  penalties: number;
}

// ============================================
// TIER TYPES
// ============================================

export type PSLTier =
  | 'Deformity'
  | 'Subhuman'
  | 'Incel'
  | 'LTN'
  | 'MTN'
  | 'HTN'
  | 'Chadlite'
  | 'Chad'
  | 'Gigachad'
  | 'True Mogger';

export interface TierInfo {
  name: PSLTier;
  minScore: number;
  maxScore: number;
  percentile: number;
  description: string;
  color: string;
}

// ============================================
// RESULT TYPES
// ============================================

export interface PSLResult {
  score: number;            // Final PSL 0-10
  tier: PSLTier;            // Tier name
  percentile: number;       // Population percentile
  breakdown: PSLBreakdown;
  potential: number;        // Estimated max with improvements
}

// ============================================
// HEIGHT RATING TABLES
// ============================================

export interface HeightRatingEntry {
  heightCm: number;
  rating: number;
  displayHeight: string;    // e.g., "5'10\" (178cm)"
}

// ============================================
// BODY RATING TABLES
// ============================================

export interface BodyRatingEntry {
  bodyFatMin: number;
  bodyFatMax: number;
  muscleLevel: MuscleLevel;
  rating: number;
  description: string;
}

// ============================================
// CONSTANTS
// ============================================

export const PSL_WEIGHTS = {
  face: 0.75,
  height: 0.20,
  body: 0.05,
} as const;

export const THRESHOLD_BONUSES = {
  face: 0.30,      // Face >= 8.5
  height: 0.20,    // Height >= 8.5
  body: 0.10,      // Body >= 8.5
} as const;

export const SYNERGY_BONUSES = {
  faceHeight: 0.15,    // Face + Height >= 8.5
  faceBody: 0.10,      // Face + Body >= 8.5
  heightBody: 0.05,    // Height + Body >= 8.5
  triple: 0.35,        // All three >= 8.5 (replaces pair bonuses)
} as const;

export const TIER_DEFINITIONS: TierInfo[] = [
  { name: 'Deformity', minScore: 0.0, maxScore: 1.0, percentile: 0.01, description: 'Medical intervention territory', color: '#4a0000' },
  { name: 'Subhuman', minScore: 1.25, maxScore: 1.75, percentile: 0.1, description: 'Genetic outlier', color: '#7f0000' },
  { name: 'Incel', minScore: 2.0, maxScore: 3.0, percentile: 2.5, description: 'Visibly below average', color: '#b91c1c' },
  { name: 'LTN', minScore: 3.5, maxScore: 4.5, percentile: 13.59, description: 'Low Tier Normie', color: '#dc2626' },
  { name: 'MTN', minScore: 4.75, maxScore: 5.25, percentile: 50.0, description: 'Mid Tier Normie - Average', color: '#f59e0b' },
  { name: 'HTN', minScore: 5.5, maxScore: 6.5, percentile: 86.41, description: 'High Tier Normie', color: '#84cc16' },
  { name: 'Chadlite', minScore: 7.0, maxScore: 8.0, percentile: 97.5, description: 'Attractive, local star', color: '#22c55e' },
  { name: 'Chad', minScore: 8.25, maxScore: 8.75, percentile: 99.9, description: 'Very attractive, elite', color: '#06b6d4' },
  { name: 'Gigachad', minScore: 9.0, maxScore: 9.5, percentile: 99.99, description: 'Mythical tier', color: '#8b5cf6' },
  { name: 'True Mogger', minScore: 9.5, maxScore: 10.0, percentile: 99.999, description: 'Theoretical limit', color: '#ec4899' },
];

// Height rating lookup tables
export const MALE_HEIGHT_RATINGS: HeightRatingEntry[] = [
  { heightCm: 157, rating: 1.0, displayHeight: '<5\'3" (<160cm)' },
  { heightCm: 160, rating: 2.0, displayHeight: '5\'3" (160cm)' },
  { heightCm: 165, rating: 3.0, displayHeight: '5\'5" (165cm)' },
  { heightCm: 170, rating: 4.0, displayHeight: '5\'7" (170cm)' },
  { heightCm: 175, rating: 5.0, displayHeight: '5\'9" (175cm)' },
  { heightCm: 178, rating: 5.5, displayHeight: '5\'10" (178cm)' },
  { heightCm: 180, rating: 6.0, displayHeight: '5\'11" (180cm)' },
  { heightCm: 183, rating: 7.0, displayHeight: '6\'0" (183cm)' },
  { heightCm: 185, rating: 7.5, displayHeight: '6\'1" (185cm)' },
  { heightCm: 188, rating: 8.0, displayHeight: '6\'2" (188cm)' },
  { heightCm: 190, rating: 8.5, displayHeight: '6\'3" (190cm)' },
  { heightCm: 193, rating: 9.0, displayHeight: '6\'4" (193cm)' },
  { heightCm: 196, rating: 9.5, displayHeight: '6\'5"+ (196cm+)' },
];

export const FEMALE_HEIGHT_RATINGS: HeightRatingEntry[] = [
  { heightCm: 147, rating: 1.0, displayHeight: '<4\'11" (<150cm)' },
  { heightCm: 150, rating: 2.0, displayHeight: '4\'11" (150cm)' },
  { heightCm: 155, rating: 3.5, displayHeight: '5\'1" (155cm)' },
  { heightCm: 160, rating: 5.0, displayHeight: '5\'3" (160cm)' },
  { heightCm: 165, rating: 6.0, displayHeight: '5\'5" (165cm)' },
  { heightCm: 168, rating: 6.5, displayHeight: '5\'6" (168cm)' },
  { heightCm: 170, rating: 7.0, displayHeight: '5\'7" (170cm)' },
  { heightCm: 173, rating: 7.5, displayHeight: '5\'8" (173cm)' },
  { heightCm: 175, rating: 8.0, displayHeight: '5\'9" (175cm)' },
  { heightCm: 178, rating: 8.5, displayHeight: '5\'10" (178cm)' },
  { heightCm: 180, rating: 9.0, displayHeight: '5\'11" (180cm)' },
  { heightCm: 183, rating: 9.0, displayHeight: '6\'0"+ (183cm+)' }, // Cap at 9.0 for females
];

// Body rating table
export const BODY_RATINGS: BodyRatingEntry[] = [
  { bodyFatMin: 25, bodyFatMax: 100, muscleLevel: 'low', rating: 2.5, description: 'Overweight, no definition' },
  { bodyFatMin: 20, bodyFatMax: 25, muscleLevel: 'low', rating: 4.0, description: 'Soft, minimal definition' },
  { bodyFatMin: 18, bodyFatMax: 22, muscleLevel: 'medium', rating: 5.25, description: 'Average, some definition' },
  { bodyFatMin: 15, bodyFatMax: 18, muscleLevel: 'medium', rating: 6.25, description: 'Lean, visible abs starting' },
  { bodyFatMin: 12, bodyFatMax: 15, muscleLevel: 'medium-high', rating: 7.25, description: 'Athletic, clear definition' },
  { bodyFatMin: 10, bodyFatMax: 12, muscleLevel: 'high', rating: 8.25, description: 'Shredded, competition lean' },
  { bodyFatMin: 8, bodyFatMax: 10, muscleLevel: 'very-high', rating: 9.25, description: 'Elite physique' },
  { bodyFatMin: 0, bodyFatMax: 8, muscleLevel: 'extreme', rating: 9.75, description: 'IFBB Pro tier' },
];

// ============================================
// UTILITY TYPES
// ============================================

export interface HeightInputState {
  heightCm: number | null;
  heightFeet: number | null;
  heightInches: number | null;
  inputMode: 'metric' | 'imperial';
}

export interface PSLContextValue {
  // State
  heightCm: number | null;
  inputMode: 'metric' | 'imperial';
  pslResult: PSLResult | null;

  // Actions
  setHeightCm: (height: number) => void;
  setInputMode: (mode: 'metric' | 'imperial') => void;
  calculatePSL: (faceScore: number, gender: Gender, bodyAnalysis?: BodyAnalysis, failos?: string[]) => PSLResult;
}
