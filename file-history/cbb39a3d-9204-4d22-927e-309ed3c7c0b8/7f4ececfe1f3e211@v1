/**
 * PSL (Pretty Scale Level) Calculator
 *
 * Implements the PSL scoring formula:
 * PSL = (Face × 0.75) + (Height × 0.20) + (Body × 0.05) + Bonuses - Penalties
 */

import {
  PSLInput,
  PSLResult,
  PSLBreakdown,
  PSLTier,
  Gender,
  MuscleLevel,
  PSL_WEIGHTS,
  THRESHOLD_BONUSES,
  SYNERGY_BONUSES,
  TIER_DEFINITIONS,
  MALE_HEIGHT_RATINGS,
  FEMALE_HEIGHT_RATINGS,
  BODY_RATINGS,
  TierInfo,
} from '@/types/psl';
import { calculateFFMI, FFMIResult } from './ffmi-calculator';

// ============================================
// HEIGHT RATING
// ============================================

/**
 * Get height rating (0-10) based on height in cm and gender
 * Uses linear interpolation between defined points
 */
export function getHeightRating(heightCm: number, gender: Gender): number {
  const table = gender === 'male' ? MALE_HEIGHT_RATINGS : FEMALE_HEIGHT_RATINGS;

  // Handle below minimum
  if (heightCm <= table[0].heightCm) {
    return table[0].rating;
  }

  // Handle above maximum
  const lastEntry = table[table.length - 1];
  if (heightCm >= lastEntry.heightCm) {
    return lastEntry.rating;
  }

  // Find the two entries to interpolate between
  for (let i = 0; i < table.length - 1; i++) {
    const lower = table[i];
    const upper = table[i + 1];

    if (heightCm >= lower.heightCm && heightCm < upper.heightCm) {
      // Linear interpolation
      const ratio = (heightCm - lower.heightCm) / (upper.heightCm - lower.heightCm);
      return lower.rating + ratio * (upper.rating - lower.rating);
    }
  }

  return 5.0; // Default fallback
}

/**
 * Get display string for height
 */
export function formatHeightDisplay(heightCm: number, gender: Gender): string {
  const table = gender === 'male' ? MALE_HEIGHT_RATINGS : FEMALE_HEIGHT_RATINGS;

  // Find closest entry
  let closest = table[0];
  let minDiff = Math.abs(heightCm - table[0].heightCm);

  for (const entry of table) {
    const diff = Math.abs(heightCm - entry.heightCm);
    if (diff < minDiff) {
      minDiff = diff;
      closest = entry;
    }
  }

  return closest.displayHeight;
}

// ============================================
// BODY RATING
// ============================================

/**
 * Get body rating (0-10) based on body fat % and muscle level
 */
export function getBodyRating(bodyFatPercent: number, muscleLevel: MuscleLevel): number {
  // Default if no body analysis available
  if (bodyFatPercent === undefined || muscleLevel === undefined) {
    return 5.0;
  }

  // Find matching entry based on body fat and muscle level
  const matchingEntry = BODY_RATINGS.find(
    (entry) =>
      bodyFatPercent >= entry.bodyFatMin &&
      bodyFatPercent < entry.bodyFatMax &&
      entry.muscleLevel === muscleLevel
  );

  if (matchingEntry) {
    return matchingEntry.rating;
  }

  // Fallback: find by body fat only
  const byBodyFat = BODY_RATINGS.find(
    (entry) => bodyFatPercent >= entry.bodyFatMin && bodyFatPercent < entry.bodyFatMax
  );

  if (byBodyFat) {
    return byBodyFat.rating;
  }

  // Default average
  return 5.0;
}

/**
 * Get body rating using FFMI calculation (more accurate when weight is available)
 * Returns the FFMI result along with the rating for display purposes
 */
export function getBodyRatingFromFFMI(
  heightCm: number,
  weightKg: number,
  bodyFatPercent: number,
  gender: Gender
): { rating: number; ffmiResult: FFMIResult } {
  const ffmiResult = calculateFFMI(heightCm, weightKg, bodyFatPercent, gender);
  return {
    rating: ffmiResult.rating,
    ffmiResult,
  };
}

/**
 * Calculate body score with FFMI when possible, fallback to body fat/muscle level
 * Returns both the rating and optional FFMI data for display
 */
export function calculateBodyScore(
  heightCm: number,
  gender: Gender,
  bodyFatPercent?: number,
  muscleLevel?: MuscleLevel,
  weightKg?: number
): { rating: number; ffmiResult?: FFMIResult; method: 'ffmi' | 'table' | 'default' } {
  // Priority 1: Use FFMI if we have all required data
  if (weightKg !== undefined && bodyFatPercent !== undefined) {
    const { rating, ffmiResult } = getBodyRatingFromFFMI(
      heightCm,
      weightKg,
      bodyFatPercent,
      gender
    );
    return { rating, ffmiResult, method: 'ffmi' };
  }

  // Priority 2: Use body fat + muscle level table
  if (bodyFatPercent !== undefined && muscleLevel !== undefined) {
    const rating = getBodyRating(bodyFatPercent, muscleLevel);
    return { rating, method: 'table' };
  }

  // Default: 5.0 (average)
  return { rating: 5.0, method: 'default' };
}

// ============================================
// TIER CLASSIFICATION
// ============================================

/**
 * Classify score into PSL tier
 */
export function classifyTier(
  score: number,
  heightRating: number,
  failos?: string[]
): TierInfo {
  // Apply constraints
  let effectiveScore = score;

  // Height constraint: Cannot reach Gigachad without height rating >= 8.0
  if (heightRating < 8.0 && score >= 9.0) {
    effectiveScore = Math.min(effectiveScore, 8.75);
  }

  // Major failo constraint: caps tier
  const hasMajorFailo = failos?.some((f) =>
    ['severe_asymmetry', 'deformed', 'major_recession'].includes(f)
  );
  if (hasMajorFailo && effectiveScore >= 7.0) {
    effectiveScore = Math.min(effectiveScore, 6.5);
  }

  // Find matching tier
  for (const tier of [...TIER_DEFINITIONS].reverse()) {
    if (effectiveScore >= tier.minScore) {
      return tier;
    }
  }

  return TIER_DEFINITIONS[0]; // Lowest tier
}

/**
 * Get tier color for UI
 */
export function getTierColor(tier: PSLTier): string {
  const tierInfo = TIER_DEFINITIONS.find((t) => t.name === tier);
  return tierInfo?.color || '#6b7280';
}

/**
 * Get tier percentile
 */
export function getTierPercentile(tier: PSLTier): number {
  const tierInfo = TIER_DEFINITIONS.find((t) => t.name === tier);
  return tierInfo?.percentile || 50;
}

// ============================================
// PSL CALCULATION
// ============================================

/**
 * Calculate threshold bonuses
 */
function calculateThresholdBonuses(
  faceScore: number,
  heightRating: number,
  bodyRating: number
): number {
  let bonus = 0;

  if (faceScore >= 8.5) bonus += THRESHOLD_BONUSES.face;
  if (heightRating >= 8.5) bonus += THRESHOLD_BONUSES.height;
  if (bodyRating >= 8.5) bonus += THRESHOLD_BONUSES.body;

  return bonus;
}

/**
 * Calculate synergy bonuses
 */
function calculateSynergyBonuses(
  faceScore: number,
  heightRating: number,
  bodyRating: number
): number {
  const highScores = [faceScore, heightRating, bodyRating].filter((s) => s >= 8.5);
  const highCount = highScores.length;

  if (highCount === 3) {
    // Triple synergy replaces pair bonuses
    return SYNERGY_BONUSES.triple;
  }

  let bonus = 0;
  if (highCount >= 2) {
    if (faceScore >= 8.5 && heightRating >= 8.5) bonus += SYNERGY_BONUSES.faceHeight;
    if (faceScore >= 8.5 && bodyRating >= 8.5) bonus += SYNERGY_BONUSES.faceBody;
    if (heightRating >= 8.5 && bodyRating >= 8.5) bonus += SYNERGY_BONUSES.heightBody;
  }

  return bonus;
}

/**
 * Calculate penalties from failos and low body score
 */
function calculatePenalties(bodyRating: number, failos?: string[]): number {
  let penalty = 0;

  // Body below 5.0 penalty
  if (bodyRating < 5.0) {
    penalty += 0.3;
  }

  // Failo penalties
  if (failos) {
    if (failos.includes('severe_asymmetry')) penalty += 0.5;
    if (failos.includes('negative_canthal_tilt')) penalty += 0.3;
    if (failos.includes('receding_chin')) penalty += 0.4;
  }

  return penalty;
}

/**
 * Estimate potential score with improvements
 */
function estimatePotential(input: PSLInput): number {
  const { faceScore, heightCm, gender, bodyAnalysis } = input;

  // Face potential: assume minor improvements (skincare, grooming) = +0.3-0.5
  const facePotential = Math.min(10, faceScore + 0.4);

  // Height is fixed
  const heightRating = getHeightRating(heightCm, gender);

  // Body potential: assume optimal physique = 8.0
  const currentBodyRating = bodyAnalysis
    ? getBodyRating(bodyAnalysis.bodyFatPercent, bodyAnalysis.muscleLevel)
    : 5.0;
  const bodyPotential = Math.max(currentBodyRating, 7.5);

  // Calculate potential PSL
  const basePotential =
    facePotential * PSL_WEIGHTS.face +
    heightRating * PSL_WEIGHTS.height +
    bodyPotential * PSL_WEIGHTS.body;

  // Add potential bonuses (optimistic)
  const thresholdBonus = calculateThresholdBonuses(facePotential, heightRating, bodyPotential);
  const synergyBonus = calculateSynergyBonuses(facePotential, heightRating, bodyPotential);

  return Math.min(10, basePotential + thresholdBonus + synergyBonus);
}

/**
 * Main PSL calculation function
 */
export function calculatePSL(input: PSLInput): PSLResult {
  const { faceScore, heightCm, gender, bodyAnalysis, weightKg, failos } = input;

  // 1. Get component ratings
  const heightRating = getHeightRating(heightCm, gender);

  // Calculate body score using FFMI when weight is available
  const effectiveWeight = weightKg ?? bodyAnalysis?.weightKg;
  const bodyScoreResult = calculateBodyScore(
    heightCm,
    gender,
    bodyAnalysis?.bodyFatPercent,
    bodyAnalysis?.muscleLevel,
    effectiveWeight
  );
  const bodyRating = bodyScoreResult.rating;

  // 2. Calculate weighted scores
  const faceWeighted = faceScore * PSL_WEIGHTS.face;
  const heightWeighted = heightRating * PSL_WEIGHTS.height;
  const bodyWeighted = bodyRating * PSL_WEIGHTS.body;
  const baseScore = faceWeighted + heightWeighted + bodyWeighted;

  // 3. Calculate bonuses
  const thresholdBonus = calculateThresholdBonuses(faceScore, heightRating, bodyRating);
  const synergyBonus = calculateSynergyBonuses(faceScore, heightRating, bodyRating);
  const totalBonus = thresholdBonus + synergyBonus;

  // 4. Calculate penalties
  const penalties = calculatePenalties(bodyRating, failos);

  // 5. Final score (clamped 0-10)
  const finalScore = Math.min(10, Math.max(0, baseScore + totalBonus - penalties));

  // 6. Classify tier
  const tierInfo = classifyTier(finalScore, heightRating, failos);

  // 7. Build breakdown with FFMI data if available
  const breakdown: PSLBreakdown = {
    face: { raw: faceScore, weighted: faceWeighted },
    height: { raw: heightRating, weighted: heightWeighted },
    body: { raw: bodyRating, weighted: bodyWeighted },
    bodyInfo: {
      method: bodyScoreResult.method,
      ffmiData: bodyScoreResult.ffmiResult
        ? {
            ffmi: bodyScoreResult.ffmiResult.ffmi,
            normalizedFFMI: bodyScoreResult.ffmiResult.normalizedFFMI,
            leanMassKg: bodyScoreResult.ffmiResult.leanMassKg,
            rating: bodyScoreResult.ffmiResult.rating,
            category: bodyScoreResult.ffmiResult.category,
          }
        : undefined,
    },
    bonuses: {
      threshold: thresholdBonus,
      synergy: synergyBonus,
      total: totalBonus,
    },
    penalties,
  };

  // 8. Calculate potential
  const potential = estimatePotential(input);

  return {
    score: Math.round(finalScore * 100) / 100,
    tier: tierInfo.name,
    percentile: tierInfo.percentile,
    breakdown,
    potential: Math.round(potential * 100) / 100,
  };
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

/**
 * Convert height from feet/inches to cm
 */
export function feetInchesToCm(feet: number, inches: number): number {
  const totalInches = feet * 12 + inches;
  return Math.round(totalInches * 2.54);
}

/**
 * Convert height from cm to feet/inches (supports half-inch precision)
 */
export function cmToFeetInches(cm: number): { feet: number; inches: number } {
  const totalInches = cm / 2.54;
  const feet = Math.floor(totalInches / 12);
  // Round to nearest 0.5 inch
  const rawInches = totalInches % 12;
  const inches = Math.round(rawInches * 2) / 2;
  // Handle case where rounding pushes to 12
  if (inches >= 12) {
    return { feet: feet + 1, inches: 0 };
  }
  return { feet, inches };
}

/**
 * Get a descriptive label for the tier
 */
export function getTierDescription(tier: PSLTier): string {
  const tierInfo = TIER_DEFINITIONS.find((t) => t.name === tier);
  return tierInfo?.description || '';
}

/**
 * Check if a tier is above average
 */
export function isAboveAverage(tier: PSLTier): boolean {
  const aboveAverageTiers: PSLTier[] = ['HTN', 'Chadlite', 'Chad', 'Gigachad', 'True Mogger'];
  return aboveAverageTiers.includes(tier);
}

/**
 * Get tier rank (1 = lowest, 10 = highest)
 */
export function getTierRank(tier: PSLTier): number {
  const tierIndex = TIER_DEFINITIONS.findIndex((t) => t.name === tier);
  return tierIndex + 1;
}
