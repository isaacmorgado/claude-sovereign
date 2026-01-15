/**
 * LOOKSMAX Scoring Engine
 * Ported from looksmax_engine.py - Presentation Layer
 *
 * Features:
 * - Weighted Harmony Score calculation (3.0x, 2.0x, 1.0x tiers)
 * - Metric-specific advice generation
 * - Gaussian scoring with exponential decay
 */

import type { FaceIQScoreResult, QualityTier, SeverityLevel } from './faceiq-scoring';

// =============================================================================
// HARMONY SCORE WEIGHTS
// =============================================================================

/**
 * High Impact Metrics (3.0x weight)
 * Core facial harmony indicators that have the greatest effect on overall attractiveness
 */
export const HIGH_IMPACT_METRICS = new Set([
  'faceWidthToHeight',
  'midfaceRatio',
  'lateralCanthalTilt',
  'gonialAngle',
  'mandibularPlaneAngle',
  'chinToPhiltrumRatio',
]);

/**
 * Medium Impact Metrics (2.0x weight)
 * Secondary aesthetic factors
 */
export const MEDIUM_IMPACT_METRICS = new Set([
  'noseBridgeToNoseWidth',
  'nasolabialAngle',
  'cheekboneHeight',
  'ramusToMandibleRatio',
]);

/**
 * Get the weight multiplier for a metric
 */
export function getMetricWeight(metricId: string): number {
  if (HIGH_IMPACT_METRICS.has(metricId)) return 3.0;
  if (MEDIUM_IMPACT_METRICS.has(metricId)) return 2.0;
  return 1.0;
}

/**
 * Get weight tier name for display
 */
export function getWeightTier(metricId: string): 'high' | 'medium' | 'standard' {
  if (HIGH_IMPACT_METRICS.has(metricId)) return 'high';
  if (MEDIUM_IMPACT_METRICS.has(metricId)) return 'medium';
  return 'standard';
}

// =============================================================================
// WEIGHTED HARMONY SCORE CALCULATION
// =============================================================================

export interface HarmonyScoreResult {
  /** Weighted harmony percentage (0-100%) */
  harmonyPercentage: number;
  /** Weighted average score (0-10 scale) */
  weightedAverage: number;
  /** Unweighted average for comparison */
  unweightedAverage: number;
  /** Breakdown by weight tier */
  weightDistribution: {
    highImpact: { count: number; avgScore: number };
    mediumImpact: { count: number; avgScore: number };
    standard: { count: number; avgScore: number };
  };
}

/**
 * Calculate the weighted Harmony Score from scored measurements.
 * Uses 3-tier weighting: High (3x), Medium (2x), Standard (1x)
 *
 * Formula: Σ(Score × Weight) / Σ(Weights) → percentage
 */
export function calculateHarmonyScore(
  measurements: Array<{ metricId: string; standardizedScore: number }>
): HarmonyScoreResult {
  let totalWeightedScore = 0;
  let totalWeight = 0;
  let unweightedTotal = 0;

  const tiers = {
    high: { total: 0, count: 0 },
    medium: { total: 0, count: 0 },
    standard: { total: 0, count: 0 },
  };

  for (const m of measurements) {
    const weight = getMetricWeight(m.metricId);
    const tier = getWeightTier(m.metricId);

    totalWeightedScore += m.standardizedScore * weight;
    totalWeight += weight;
    unweightedTotal += m.standardizedScore;

    tiers[tier].total += m.standardizedScore;
    tiers[tier].count++;
  }

  const weightedAverage = totalWeight > 0 ? totalWeightedScore / totalWeight : 0;
  const unweightedAverage = measurements.length > 0 ? unweightedTotal / measurements.length : 0;
  const harmonyPercentage = (weightedAverage / 10) * 100;

  return {
    harmonyPercentage,
    weightedAverage,
    unweightedAverage,
    weightDistribution: {
      highImpact: {
        count: tiers.high.count,
        avgScore: tiers.high.count > 0 ? tiers.high.total / tiers.high.count : 0,
      },
      mediumImpact: {
        count: tiers.medium.count,
        avgScore: tiers.medium.count > 0 ? tiers.medium.total / tiers.medium.count : 0,
      },
      standard: {
        count: tiers.standard.count,
        avgScore: tiers.standard.count > 0 ? tiers.standard.total / tiers.standard.count : 0,
      },
    },
  };
}

// =============================================================================
// ADVICE ENGINE - METRIC-SPECIFIC FEEDBACK STRINGS
// =============================================================================

interface AdviceEntry {
  tooHigh: string;
  tooLow: string;
}

/**
 * Comprehensive advice database for all metrics
 * Keys match metric IDs from faceiq-scoring.ts
 */
export const ADVICE_DATABASE: Record<string, AdviceEntry> = {
  // === HIGH IMPACT METRICS ===
  faceWidthToHeight: {
    tooHigh: "Face appears wider. Consider hairstyles that add vertical length.",
    tooLow: "Face is elongated. Hairstyles with side volume can add balance.",
  },
  midfaceRatio: {
    tooHigh: "Midface is elongated. This can project maturity but may benefit from framing.",
    tooLow: "Midface is compact. This is often a dimorphic and youthful trait.",
  },
  lateralCanthalTilt: {
    tooHigh: "Eyes have significant positive tilt. Very dimorphic - no action needed.",
    tooLow: "Eyes have negative tilt. Consider brow-maxxing or temporal area work.",
  },
  gonialAngle: {
    tooHigh: "Jaw angle is steep (obtuse). Lowering body fat or chewing hard gum may improve definition.",
    tooLow: "Jaw angle is very sharp. Strong masculine trait - no action typically needed.",
  },
  mandibularPlaneAngle: {
    tooHigh: "Steep mandibular plane (long face type). May benefit from mewing or jaw work.",
    tooLow: "Flat mandibular plane. This is typically a favorable trait.",
  },
  chinToPhiltrumRatio: {
    tooHigh: "Chin is long relative to philtrum. Generally masculine; no action needed.",
    tooLow: "Philtrum is long relative to chin. Upper lip lifting or chin augmentation options exist.",
  },

  // === MEDIUM IMPACT METRICS ===
  noseBridgeToNoseWidth: {
    tooHigh: "Nose appears narrow relative to bridge. This is typically favorable.",
    tooLow: "Nose is wide relative to bridge. Nostril work can refine proportions.",
  },
  nasolabialAngle: {
    tooHigh: "Nose tip points upward. Can appear more feminine; tip refinement may help.",
    tooLow: "Nose tip points downward (droopy). Tip rotation procedures can improve profile.",
  },
  cheekboneHeight: {
    tooHigh: "Cheekbones are exceptionally high. Very aesthetic - no action needed.",
    tooLow: "Cheekbones are lower set. Malar augmentation or filler can enhance projection.",
  },
  cheekFullness: {
    tooHigh: "Very full cheeks. Consider facial contouring if seeking a leaner look.",
    tooLow: "Hollow or gaunt cheeks. Malar filler or fat grafting can restore volume.",
  },
  ramusToMandibleRatio: {
    tooHigh: "Short mandibular body. Jaw angle implants may improve proportions.",
    tooLow: "Long mandibular body. This is typically favorable for facial width.",
  },

  // === FRONT PROFILE METRICS ===
  jawSlope: {
    tooHigh: "Jaw slopes steeply. Consider gonial angle enhancement.",
    tooLow: "Jaw has minimal slope. Strong horizontal projection is present.",
  },
  totalFacialWidthToHeight: {
    tooHigh: "Face is very wide relative to height. Can appear robust/masculine.",
    tooLow: "Face is very tall relative to width. Hairstyles with width can balance.",
  },
  mouthWidthToNoseRatio: {
    tooHigh: "Wide mouth relative to nose. Typically attractive; no action needed.",
    tooLow: "Narrow mouth relative to nose. Lip exercises may help.",
  },
  lowerThirdProportion: {
    tooHigh: "Lower face is long. May benefit from vertical reduction options.",
    tooLow: "Lower face is short. Chin augmentation can add vertical height.",
  },
  ipsilateralAlarAngle: {
    tooHigh: "Nostril angle is wide. Alar reduction may refine the nose.",
    tooLow: "Nostril angle is narrow. Typically favorable; no action needed.",
  },
  jawFrontalAngle: {
    tooHigh: "Jaw is V-shaped. Gonial angle widening may add presence.",
    tooLow: "Jaw is very U-shaped/wide. Strong masculine trait.",
  },
  eyeAspectRatio: {
    tooHigh: "Eyes are horizontally elongated. Hunter eyes are typically desirable.",
    tooLow: "Eyes are more round. Lateral canthoplasty can elongate.",
  },
  bitemporalWidth: {
    tooHigh: "Wide temples relative to face. Full head of hair can balance.",
    tooLow: "Narrow temples. Can appear more refined/gracile.",
  },
  eyebrowLowSetedness: {
    tooHigh: "Brows are low-set (hooded). Creates intense look; browlift if too heavy.",
    tooLow: "Brows are high-set. More open look; brow products can add fullness.",
  },
  eyeSeparationRatio: {
    tooHigh: "Eyes are widely set. Creates softer look; no action typically needed.",
    tooLow: "Eyes are closely set. Can appear intense; glasses can balance.",
  },
  bigonialWidth: {
    tooHigh: "Wide jaw relative to cheekbones. Strong masculine trait.",
    tooLow: "Narrow jaw relative to cheekbones. Jaw angle widening may add presence.",
  },
  lowerToUpperLipRatio: {
    tooHigh: "Lower lip is much fuller. Very aesthetic; no action needed.",
    tooLow: "Upper lip is fuller. Standard proportion; lip flip may balance.",
  },
  eyebrowTilt: {
    tooHigh: "Brows tilt significantly upward. Can appear expressive.",
    tooLow: "Brows are flat or downturned. Can appear more stoic.",
  },

  // === SIDE PROFILE METRICS ===
  recessionRelativeToFrankfort: {
    tooHigh: "Significant lower jaw recession. Advancement surgery may help.",
    tooLow: "Jaw projects forward strongly. Very masculine; monitor overbite.",
  },
  facialDepthToHeightRatio: {
    tooHigh: "Face is very deep relative to height. Strong forward growth.",
    tooLow: "Face is flat relative to height. May benefit from midface/chin work.",
  },
  interiorMidfaceProjectionAngle: {
    tooHigh: "Midface projects significantly. Strong forward growth.",
    tooLow: "Flat midface. Cheekbone augmentation may improve profile.",
  },
  nasofrontalAngle: {
    tooHigh: "Deep nasofrontal angle. Creates dramatic brow/nose transition.",
    tooLow: "Shallow nasofrontal angle. Brow work may add definition.",
  },
  gonionToMouthLine: {
    tooHigh: "Gonion is low relative to mouth. May appear long-faced.",
    tooLow: "Gonion is high relative to mouth. Compact proportions.",
  },
  lowerLipSLinePosition: {
    tooHigh: "Lower lip protrudes past S-line. May indicate maxillary retrusion.",
    tooLow: "Lower lip is behind S-line. Well-balanced profile.",
  },
  zAngle: {
    tooHigh: "Profile is very upright/vertical. May appear flat.",
    tooLow: "Profile is convex. Standard Western ideal.",
  },
  nasomentaAngle: {
    tooHigh: "Nose-chin line is obtuse. May indicate weak chin.",
    tooLow: "Nose-chin line is acute. Strong chin projection.",
  },
  submentalCervicalAngle: {
    tooHigh: "Weak chin-neck angle. May benefit from submental lipo or implant.",
    tooLow: "Sharp chin-neck angle. Excellent definition.",
  },
  nasofacialAngle: {
    tooHigh: "Large angle between nose and face. Strong nose or recessed face.",
    tooLow: "Small angle. Well-integrated nose.",
  },
  holdawayHLine: {
    tooHigh: "Lips project significantly. Monitor for bimax protrusion.",
    tooLow: "Flat lip line. May appear retruded; filler can add volume.",
  },
  mentolabialAngle: {
    tooHigh: "Deep mentolabial fold. Can appear aged; filler can soften.",
    tooLow: "Shallow mentolabial fold. Youthful and balanced.",
  },
  eLineLowerLip: {
    tooHigh: "Lower lip protrudes past E-line. May benefit from orthodontics.",
    tooLow: "Lower lip is behind E-line. Balanced or retruded.",
  },
  eLineUpperLip: {
    tooHigh: "Upper lip protrudes past E-line. May benefit from orthodontics.",
    tooLow: "Upper lip is behind E-line. Balanced or retruded.",
  },
  nasalTipAngle: {
    tooHigh: "Nose tip is rotated upward. Can appear feminine.",
    tooLow: "Nose tip droops. Tip rotation surgery can improve.",
  },
  nasalProjection: {
    tooHigh: "Large nose projection. Reduction rhinoplasty may refine.",
    tooLow: "Minimal nose projection. Augmentation rhinoplasty may enhance.",
  },
  nasalWToHRatio: {
    tooHigh: "Wide nose relative to height. Narrowing procedures exist.",
    tooLow: "Narrow nose. Typically favorable; no action needed.",
  },
  facialConvexityGlabella: {
    tooHigh: "Convex profile. Strong midface projection.",
    tooLow: "Flat or concave profile. May benefit from augmentation.",
  },
  facialConvexityNasion: {
    tooHigh: "Convex profile from nasion. Good forward growth.",
    tooLow: "Straight or concave profile. May appear flat.",
  },
  totalFacialConvexity: {
    tooHigh: "Very convex total profile. Midface is prominent.",
    tooLow: "Flat total profile. Forward growth options may help.",
  },
  upperForeheadSlope: {
    tooHigh: "Sloped forehead. More masculine/primal appearance.",
    tooLow: "Upright forehead. More neotenous appearance.",
  },
  browridgeInclinationAngle: {
    tooHigh: "Prominent browridge angle. Strong masculine trait.",
    tooLow: "Flat browridge. Implants can add definition.",
  },
  upperThirdProportion: {
    tooHigh: "Upper third is long. Large forehead; can be offset with hair styling.",
    tooLow: "Upper third is short. Compact proportions.",
  },
  middleThirdProportion: {
    tooHigh: "Middle third is long. May appear long-faced.",
    tooLow: "Middle third is short. Compact midface.",
  },
  chinProjection: {
    tooHigh: "Strong chin projection. Very masculine trait.",
    tooLow: "Weak chin projection. Genioplasty or implant can improve.",
  },
  lipRatio: {
    tooHigh: "Full lips. Typically attractive; no action needed.",
    tooLow: "Thin lips. Filler can add volume if desired.",
  },
};

/**
 * Generate personalized advice based on metric score and value position.
 *
 * @param metricId - The metric identifier
 * @param score - Score from 0-10
 * @param value - Actual measured value
 * @param idealMin - Minimum of ideal range
 * @param idealMax - Maximum of ideal range
 * @returns Advice string for the metric
 */
export function generateAdvice(
  metricId: string,
  score: number,
  value: number,
  idealMin: number,
  idealMax: number
): string {
  // Perfect score - no action needed
  if (score >= 9.0) {
    return "Ideal proportions. No action needed.";
  }

  // Get advice from database
  const advice = ADVICE_DATABASE[metricId];
  if (advice) {
    if (value > idealMax) {
      return advice.tooHigh;
    } else if (value < idealMin) {
      return advice.tooLow;
    }
  }

  // Default fallback
  if (value > idealMax) {
    return `Value (${value.toFixed(2)}) is above the ideal range of ${idealMin.toFixed(1)}-${idealMax.toFixed(1)}.`;
  } else if (value < idealMin) {
    return `Value (${value.toFixed(2)}) is below the ideal range of ${idealMin.toFixed(1)}-${idealMax.toFixed(1)}.`;
  } else {
    return "Value is within acceptable range but not optimal.";
  }
}

/**
 * Generate advice for a FaceIQ score result
 */
export function generateAdviceFromResult(result: FaceIQScoreResult): string {
  return generateAdvice(
    result.metricId,
    result.standardizedScore,
    result.value,
    result.idealMin,
    result.idealMax
  );
}

// =============================================================================
// GAUSSIAN SCORING (matches Python implementation)
// =============================================================================

/**
 * Calculate a score from 0-10 using Gaussian decay.
 * Matches the Python looksmax_engine.py implementation.
 *
 * @param value - The measured value
 * @param minRange - Minimum of ideal range
 * @param maxRange - Maximum of ideal range
 * @returns Score from 0-10
 */
export function calculateGaussianScore(
  value: number,
  minRange: number,
  maxRange: number
): number {
  // Within ideal range = perfect score
  if (value >= minRange && value <= maxRange) {
    return 10.0;
  }

  let deviation: number;
  let target: number;

  if (value < minRange) {
    deviation = minRange - value;
    target = minRange;
  } else {
    deviation = value - maxRange;
    target = maxRange;
  }

  // Prevent division by zero
  if (target === 0) target = 1.0;

  // Sigma is 10% of target value
  let sigma = Math.abs(target) * 0.1;
  if (sigma === 0) sigma = 1.0;

  // Gaussian decay
  const score = 10.0 * Math.exp(-0.5 * Math.pow(deviation / sigma, 2));
  return Math.max(0.0, Math.min(10.0, score));
}

// =============================================================================
// TOP/BOTTOM METRICS IDENTIFICATION
// =============================================================================

export interface RankedMetric {
  metricId: string;
  name: string;
  value: number;
  score: number;
  idealMin: number;
  idealMax: number;
  advice: string;
  weightTier: 'high' | 'medium' | 'standard';
  category: string;
}

/**
 * Get the top N metrics (strengths) sorted by score descending
 */
export function getTopMetrics(
  measurements: FaceIQScoreResult[],
  count: number = 3
): RankedMetric[] {
  return [...measurements]
    .sort((a, b) => b.standardizedScore - a.standardizedScore)
    .slice(0, count)
    .map((m) => ({
      metricId: m.metricId,
      name: m.name,
      value: m.value,
      score: m.standardizedScore,
      idealMin: m.idealMin,
      idealMax: m.idealMax,
      advice: generateAdviceFromResult(m),
      weightTier: getWeightTier(m.metricId),
      category: m.category,
    }));
}

/**
 * Get the bottom N metrics (areas to improve) sorted by score ascending
 */
export function getBottomMetrics(
  measurements: FaceIQScoreResult[],
  count: number = 3
): RankedMetric[] {
  return [...measurements]
    .sort((a, b) => a.standardizedScore - b.standardizedScore)
    .slice(0, count)
    .map((m) => ({
      metricId: m.metricId,
      name: m.name,
      value: m.value,
      score: m.standardizedScore,
      idealMin: m.idealMin,
      idealMax: m.idealMax,
      advice: generateAdviceFromResult(m),
      weightTier: getWeightTier(m.metricId),
      category: m.category,
    }));
}

// =============================================================================
// QUALITY & SEVERITY HELPERS
// =============================================================================

/**
 * Get a human-readable quality description
 */
export function getQualityDescription(tier: QualityTier): string {
  switch (tier) {
    case 'ideal': return 'Ideal';
    case 'excellent': return 'Excellent';
    case 'good': return 'Good';
    case 'below_average': return 'Below Average';
  }
}

/**
 * Get a human-readable severity description
 */
export function getSeverityDescription(severity: SeverityLevel): string {
  switch (severity) {
    case 'optimal': return 'Optimal';
    case 'minor': return 'Minor Deviation';
    case 'moderate': return 'Moderate Deviation';
    case 'major': return 'Major Deviation';
    case 'severe': return 'Severe Deviation';
    case 'extremely_severe': return 'Extremely Severe';
  }
}

/**
 * Get severity color for UI display
 */
export function getSeverityColor(severity: SeverityLevel): string {
  switch (severity) {
    case 'optimal': return 'text-green-400';
    case 'minor': return 'text-lime-400';
    case 'moderate': return 'text-yellow-400';
    case 'major': return 'text-orange-400';
    case 'severe': return 'text-red-400';
    case 'extremely_severe': return 'text-red-600';
  }
}

/**
 * Get weight tier badge color
 */
export function getWeightTierColor(tier: 'high' | 'medium' | 'standard'): string {
  switch (tier) {
    case 'high': return 'bg-purple-500/20 text-purple-400 border-purple-500/30';
    case 'medium': return 'bg-blue-500/20 text-blue-400 border-blue-500/30';
    case 'standard': return 'bg-gray-500/20 text-gray-400 border-gray-500/30';
  }
}

/**
 * Get weight tier label
 */
export function getWeightTierLabel(tier: 'high' | 'medium' | 'standard'): string {
  switch (tier) {
    case 'high': return 'High Impact (3x)';
    case 'medium': return 'Medium Impact (2x)';
    case 'standard': return 'Standard';
  }
}
