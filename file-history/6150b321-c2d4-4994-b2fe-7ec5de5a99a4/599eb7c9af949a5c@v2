/**
 * Facial Analysis Scoring Functions
 *
 * This module now uses the FaceIQ-style scoring system with:
 * - Exponential decay scoring with per-metric decay rates
 * - 70+ facial measurements (front + side profiles)
 * - Quality tiers: Ideal, Excellent, Good
 * - 5-tier severity: Extremely Severe, Severe, Major, Moderate, Minor
 *
 * Backward compatible with existing API
 */

// Re-export everything from the new FaceIQ scoring system
export * from './faceiq-scoring';

// Import for backward compatibility wrappers
import {
  analyzeFrontProfile as faceiqFrontAnalysis,
  analyzeSideProfile as faceiqSideAnalysis,
  FaceIQScoreResult,
  QualityTier,
  FACEIQ_METRICS,
} from './faceiq-scoring';

import {
  LandmarkPoint,
  ScoringConfig,
  FACEIQ_SCORING_CONFIGS,
  FACEIQ_IDEAL_VALUES,
  PopulationStats,
  POPULATION_STATS,
} from './landmarks';

// ============================================
// BACKWARD COMPATIBILITY TYPES
// ============================================

export interface Point {
  x: number;
  y: number;
}

export interface ScoreResult {
  value: number;
  score: number;
  idealRange: { min: number; max: number };
  rating: 'excellent' | 'good' | 'average' | 'below_average';
}

export interface EnhancedScoreResult extends ScoreResult {
  bellCurveScore: number;
  percentile: number;
  idealValue: number;
  deviation: number;
}

export interface BellCurvePoint {
  x: number;
  y: number;
}

export interface BellCurveData {
  points: BellCurvePoint[];
  userValue: number;
  userPercentile: number;
  mean: number;
  standardDeviation: number;
  idealValue?: number;
}

// ============================================
// BACKWARD COMPATIBILITY: OLD ANALYSIS INTERFACES
// ============================================

export interface FrontAnalysisResults {
  facialThirds: {
    upper: ScoreResult;
    middle: ScoreResult;
    lower: ScoreResult;
    overall: ScoreResult;
  } | null;
  fwhr: ScoreResult | null;
  ipdRatio: ScoreResult | null;
  nasalIndex: ScoreResult | null;
  leftCanthalTilt: ScoreResult | null;
  rightCanthalTilt: ScoreResult | null;
  mouthNoseRatio: ScoreResult | null;
  jawRatio: ScoreResult | null;
  overallScore: number;
}

export interface SideAnalysisResults {
  gonialAngle: ScoreResult | null;
  nasolabialAngle: ScoreResult | null;
  eLine: {
    upperLip: ScoreResult;
    lowerLip: ScoreResult;
    combined: ScoreResult;
  } | null;
  mentolabialAngle: ScoreResult | null;
  nasofrontalAngle: ScoreResult | null;
  overallScore: number;
}

export interface ComprehensiveFrontAnalysis extends FrontAnalysisResults {
  bellCurveScores: Record<string, number>;
  percentiles: Record<string, number>;
  harmonyScore: number;
}

export interface ComprehensiveSideAnalysis extends SideAnalysisResults {
  bellCurveScores: Record<string, number>;
  percentiles: Record<string, number>;
  harmonyScore: number;
}

// ============================================
// BACKWARD COMPATIBILITY: RATING CONVERSION
// ============================================

function qualityToRating(tier: QualityTier): 'excellent' | 'good' | 'average' | 'below_average' {
  switch (tier) {
    case 'ideal': return 'excellent';
    case 'excellent': return 'good';
    case 'good': return 'average';
    default: return 'below_average';
  }
}

function faceiqToScoreResult(result: FaceIQScoreResult): ScoreResult {
  return {
    value: result.value,
    score: result.standardizedScore * 10, // Convert 0-10 to 0-100
    idealRange: { min: result.idealMin, max: result.idealMax },
    rating: qualityToRating(result.qualityTier),
  };
}

// ============================================
// BACKWARD COMPATIBILITY: FRONT ANALYSIS
// ============================================

// Kept for potential future use in backward compatibility layer
function _getLandmark(landmarks: LandmarkPoint[], id: string): Point | null {
  const lm = landmarks.find((l) => l.id === id);
  return lm ? { x: lm.x, y: lm.y } : null;
}
void _getLandmark; // Suppress unused warning

/**
 * Backward compatible front profile analysis
 */
export function analyzeFrontProfile(
  frontLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): FrontAnalysisResults {
  const newResults = faceiqFrontAnalysis(frontLandmarks, gender);

  // Convert FaceIQ results to old format
  const findMeasurement = (id: string) => {
    const m = newResults.measurements.find(m => m.metricId === id);
    return m ? faceiqToScoreResult(m) : null;
  };

  // Build facial thirds from individual measurements
  const upperThird = findMeasurement('upperThirdProportion');
  const middleThird = findMeasurement('middleThirdProportion');
  const lowerThird = findMeasurement('lowerThirdProportion');

  const facialThirds = (upperThird && middleThird && lowerThird) ? {
    upper: upperThird,
    middle: middleThird,
    lower: lowerThird,
    overall: {
      value: (upperThird.score + middleThird.score + lowerThird.score) / 3,
      score: (upperThird.score + middleThird.score + lowerThird.score) / 3,
      idealRange: { min: 30, max: 36 },
      rating: qualityToRating(newResults.qualityTier),
    },
  } : null;

  return {
    facialThirds,
    fwhr: findMeasurement('faceWidthToHeight'),
    ipdRatio: findMeasurement('interpupillaryRatio'),
    nasalIndex: findMeasurement('nasalIndex'),
    leftCanthalTilt: findMeasurement('lateralCanthalTilt'),
    rightCanthalTilt: findMeasurement('lateralCanthalTilt'), // Same measurement
    mouthNoseRatio: findMeasurement('mouthWidthToNoseRatio'),
    jawRatio: findMeasurement('jawWidthRatio'),
    overallScore: newResults.overallScore * 10, // Convert 0-10 to 0-100
  };
}

/**
 * Backward compatible side profile analysis
 */
export function analyzeSideProfile(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): SideAnalysisResults {
  const newResults = faceiqSideAnalysis(sideLandmarks, gender);

  const findMeasurement = (id: string) => {
    const m = newResults.measurements.find(m => m.metricId === id);
    return m ? faceiqToScoreResult(m) : null;
  };

  // Build E-line from individual measurements
  const upperLipELine = findMeasurement('eLineUpperLip');
  const lowerLipELine = findMeasurement('eLineLowerLip');

  const eLine = (upperLipELine && lowerLipELine) ? {
    upperLip: upperLipELine,
    lowerLip: lowerLipELine,
    combined: {
      value: (upperLipELine.value + lowerLipELine.value) / 2,
      score: (upperLipELine.score + lowerLipELine.score) / 2,
      idealRange: { min: -6, max: 2 },
      rating: qualityToRating(newResults.qualityTier),
    },
  } : null;

  return {
    gonialAngle: findMeasurement('gonialAngle'),
    nasolabialAngle: findMeasurement('nasolabialAngle'),
    eLine,
    mentolabialAngle: findMeasurement('mentolabialAngle'),
    nasofrontalAngle: findMeasurement('nasofrontalAngle'),
    overallScore: newResults.overallScore * 10, // Convert 0-10 to 0-100
  };
}

// ============================================
// BACKWARD COMPATIBILITY: COMPREHENSIVE ANALYSIS
// ============================================

/**
 * Run comprehensive front profile analysis with bell curves
 */
export function comprehensiveFrontAnalysis(
  frontLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): ComprehensiveFrontAnalysis {
  const baseAnalysis = analyzeFrontProfile(frontLandmarks, gender);
  const faceiqResults = faceiqFrontAnalysis(frontLandmarks, gender);

  const bellCurveScores: Record<string, number> = {};
  const percentiles: Record<string, number> = {};

  // Convert FaceIQ scores to bell curve format
  for (const m of faceiqResults.measurements) {
    bellCurveScores[m.metricId] = m.standardizedScore * 10;
    percentiles[m.metricId] = calculatePercentileFromScore(m.standardizedScore);
  }

  return {
    ...baseAnalysis,
    bellCurveScores,
    percentiles,
    harmonyScore: faceiqResults.overallScore * 10,
  };
}

/**
 * Run comprehensive side profile analysis with bell curves
 */
export function comprehensiveSideAnalysis(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): ComprehensiveSideAnalysis {
  const baseAnalysis = analyzeSideProfile(sideLandmarks, gender);
  const faceiqResults = faceiqSideAnalysis(sideLandmarks, gender);

  const bellCurveScores: Record<string, number> = {};
  const percentiles: Record<string, number> = {};

  for (const m of faceiqResults.measurements) {
    bellCurveScores[m.metricId] = m.standardizedScore * 10;
    percentiles[m.metricId] = calculatePercentileFromScore(m.standardizedScore);
  }

  return {
    ...baseAnalysis,
    bellCurveScores,
    percentiles,
    harmonyScore: faceiqResults.overallScore * 10,
  };
}

// ============================================
// BACKWARD COMPATIBILITY: BELL CURVE FUNCTIONS
// ============================================

/**
 * Calculate percentile from normalized score
 */
function calculatePercentileFromScore(score: number): number {
  // Score is 0-10, map to percentile using normal distribution
  const mean = 5;
  const stdDev = 1.5;
  const z = (score - mean) / stdDev;
  return normalCDF(z) * 100;
}

/**
 * Standard normal CDF approximation
 */
export function normalCDF(z: number): number {
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

/**
 * Calculate percentile for specific measurement
 */
export function calculatePercentile(
  value: number,
  stats: PopulationStats
): number {
  const z = (value - stats.mean) / stats.standardDeviation;
  return normalCDF(z) * 100;
}

/**
 * Generate bell curve data for visualization
 */
export function generateBellCurveData(
  stats: PopulationStats,
  userValue: number,
  idealValue?: number
): BellCurveData {
  const points: BellCurvePoint[] = [];

  // Generate points from -4 to +4 standard deviations
  for (let i = -4; i <= 4; i += 0.1) {
    const x = stats.mean + i * stats.standardDeviation;
    const y =
      (1 / (stats.standardDeviation * Math.sqrt(2 * Math.PI))) *
      Math.exp(
        -0.5 * Math.pow((x - stats.mean) / stats.standardDeviation, 2)
      );
    points.push({ x, y });
  }

  return {
    points,
    userValue,
    userPercentile: calculatePercentile(userValue, stats),
    mean: stats.mean,
    standardDeviation: stats.standardDeviation,
    idealValue,
  };
}

/**
 * Generate bell curve for specific measurement
 */
export function generateMeasurementBellCurve(
  measurementKey: string,
  userValue: number,
  gender?: 'male' | 'female'
): BellCurveData | null {
  const stats = POPULATION_STATS[measurementKey];
  if (!stats) {
    // Create synthetic stats based on FaceIQ config
    const config = FACEIQ_METRICS[measurementKey];
    if (!config) return null;

    const syntheticStats: PopulationStats = {
      mean: (config.idealMin + config.idealMax) / 2,
      standardDeviation: (config.idealMax - config.idealMin) * 2,
      sampleSize: 10000,
    };

    const idealValues = FACEIQ_IDEAL_VALUES[measurementKey];
    const idealValue = idealValues && gender ? idealValues[gender].ideal : syntheticStats.mean;

    return generateBellCurveData(syntheticStats, userValue, idealValue);
  }

  const idealValues = FACEIQ_IDEAL_VALUES[measurementKey];
  const idealValue = idealValues && gender ? idealValues[gender].ideal : undefined;

  return generateBellCurveData(stats, userValue, idealValue);
}

/**
 * Calculate bell curve score
 */
export function calculateBellCurveScore(
  value: number,
  config: ScoringConfig
): number {
  const z = (value - config.idealValue) / config.standardDeviation;
  const bellCurve = Math.exp(-0.5 * z * z);
  return config.minScore + (config.maxScore - config.minScore) * bellCurve;
}

/**
 * Calculate gender-aware bell curve score
 */
export function calculateGenderAwareBellCurveScore(
  value: number,
  measurementKey: string,
  gender: 'male' | 'female'
): number {
  const idealValues = FACEIQ_IDEAL_VALUES[measurementKey];
  const config = FACEIQ_SCORING_CONFIGS[measurementKey];

  if (!idealValues || !config) {
    return 0;
  }

  const genderIdeal = idealValues[gender].ideal;
  const adjustedConfig = {
    ...config,
    idealValue: genderIdeal,
  };

  return calculateBellCurveScore(value, adjustedConfig);
}

/**
 * Calculate harmony score from multiple measurements
 */
export function calculateHarmonyScore(
  scores: Record<string, number>
): number {
  let totalWeight = 0;
  let weightedSum = 0;

  for (const [key, score] of Object.entries(scores)) {
    const config = FACEIQ_SCORING_CONFIGS[key];
    if (config) {
      weightedSum += score * config.weight;
      totalWeight += config.weight;
    }
  }

  return totalWeight > 0 ? weightedSum / totalWeight : 0;
}

// ============================================
// BACKWARD COMPATIBILITY: ENHANCED SCORES
// ============================================

/**
 * Create enhanced score with bell curve and percentile
 */
export function createEnhancedScore(
  value: number,
  measurementKey: string,
  gender: 'male' | 'female' = 'male'
): EnhancedScoreResult | null {
  const config = FACEIQ_SCORING_CONFIGS[measurementKey];
  const idealValues = FACEIQ_IDEAL_VALUES[measurementKey];
  const stats = POPULATION_STATS[measurementKey];

  if (!config) return null;

  const idealValue = idealValues ? idealValues[gender].ideal : config.idealValue;
  const bellCurveScore = calculateBellCurveScore(value, {
    ...config,
    idealValue,
  });
  const percentile = stats ? calculatePercentile(value, stats) : 50;
  const deviation = value - idealValue;

  const rating = bellCurveScore >= 90 ? 'excellent'
    : bellCurveScore >= 75 ? 'good'
    : bellCurveScore >= 50 ? 'average'
    : 'below_average';

  return {
    value,
    score: bellCurveScore,
    idealRange: idealValues
      ? { min: idealValues[gender].range[0], max: idealValues[gender].range[1] }
      : { min: config.idealValue - config.standardDeviation, max: config.idealValue + config.standardDeviation },
    rating,
    bellCurveScore,
    percentile,
    idealValue,
    deviation,
  };
}

// ============================================
// BACKWARD COMPATIBILITY: RECOMMENDATION INTEGRATION
// ============================================

import type { MetricInput } from './recommendations/engine';
import type { RecommendationPlan } from './recommendations/types';

/**
 * Convert front analysis to metric inputs for recommendation engine
 */
export function frontAnalysisToMetricInputs(
  analysis: ComprehensiveFrontAnalysis
): MetricInput[] {
  const inputs: MetricInput[] = [];

  if (analysis.fwhr) {
    inputs.push({
      metricId: 'fwhr',
      metricName: 'Facial Width-to-Height Ratio',
      currentValue: analysis.fwhr.value,
      idealValue: (analysis.fwhr.idealRange.min + analysis.fwhr.idealRange.max) / 2,
      idealRange: analysis.fwhr.idealRange,
      score: analysis.fwhr.score,
      profileType: 'front',
    });
  }

  if (analysis.leftCanthalTilt) {
    inputs.push({
      metricId: 'canthalTilt',
      metricName: 'Canthal Tilt',
      currentValue: analysis.leftCanthalTilt.value,
      idealValue: 6,
      idealRange: analysis.leftCanthalTilt.idealRange,
      score: analysis.leftCanthalTilt.score,
      profileType: 'front',
    });
  }

  if (analysis.nasalIndex) {
    inputs.push({
      metricId: 'nasalIndex',
      metricName: 'Nasal Index',
      currentValue: analysis.nasalIndex.value,
      idealValue: (analysis.nasalIndex.idealRange.min + analysis.nasalIndex.idealRange.max) / 2,
      idealRange: analysis.nasalIndex.idealRange,
      score: analysis.nasalIndex.score,
      profileType: 'front',
    });
  }

  if (analysis.jawRatio) {
    inputs.push({
      metricId: 'jawWidthRatio',
      metricName: 'Jaw Width Ratio',
      currentValue: analysis.jawRatio.value,
      idealValue: (analysis.jawRatio.idealRange.min + analysis.jawRatio.idealRange.max) / 2,
      idealRange: analysis.jawRatio.idealRange,
      score: analysis.jawRatio.score,
      profileType: 'front',
    });
  }

  if (analysis.facialThirds?.upper) {
    inputs.push({
      metricId: 'facialThirdsUpper',
      metricName: 'Upper Facial Third',
      currentValue: analysis.facialThirds.upper.value,
      idealValue: 33.33,
      idealRange: analysis.facialThirds.upper.idealRange,
      score: analysis.facialThirds.upper.score,
      profileType: 'front',
    });
  }

  if (analysis.facialThirds?.middle) {
    inputs.push({
      metricId: 'facialThirdsMiddle',
      metricName: 'Middle Facial Third',
      currentValue: analysis.facialThirds.middle.value,
      idealValue: 33.33,
      idealRange: analysis.facialThirds.middle.idealRange,
      score: analysis.facialThirds.middle.score,
      profileType: 'front',
    });
  }

  if (analysis.facialThirds?.lower) {
    inputs.push({
      metricId: 'facialThirdsLower',
      metricName: 'Lower Facial Third',
      currentValue: analysis.facialThirds.lower.value,
      idealValue: 33.33,
      idealRange: analysis.facialThirds.lower.idealRange,
      score: analysis.facialThirds.lower.score,
      profileType: 'front',
    });
  }

  if (analysis.mouthNoseRatio) {
    inputs.push({
      metricId: 'lipRatio',
      metricName: 'Mouth to Nose Ratio',
      currentValue: analysis.mouthNoseRatio.value,
      idealValue: 1.55,
      idealRange: analysis.mouthNoseRatio.idealRange,
      score: analysis.mouthNoseRatio.score,
      profileType: 'front',
    });
  }

  if (analysis.ipdRatio) {
    inputs.push({
      metricId: 'interpupillaryDistance',
      metricName: 'Interpupillary Distance Ratio',
      currentValue: analysis.ipdRatio.value,
      idealValue: 46,
      idealRange: analysis.ipdRatio.idealRange,
      score: analysis.ipdRatio.score,
      profileType: 'front',
    });
  }

  return inputs;
}

/**
 * Convert side analysis to metric inputs for recommendation engine
 */
export function sideAnalysisToMetricInputs(
  analysis: ComprehensiveSideAnalysis
): MetricInput[] {
  const inputs: MetricInput[] = [];

  if (analysis.gonialAngle) {
    inputs.push({
      metricId: 'gonialAngle',
      metricName: 'Gonial Angle',
      currentValue: analysis.gonialAngle.value,
      idealValue: (analysis.gonialAngle.idealRange.min + analysis.gonialAngle.idealRange.max) / 2,
      idealRange: analysis.gonialAngle.idealRange,
      score: analysis.gonialAngle.score,
      profileType: 'side',
    });
  }

  if (analysis.nasolabialAngle) {
    inputs.push({
      metricId: 'nasolabialAngle',
      metricName: 'Nasolabial Angle',
      currentValue: analysis.nasolabialAngle.value,
      idealValue: (analysis.nasolabialAngle.idealRange.min + analysis.nasolabialAngle.idealRange.max) / 2,
      idealRange: analysis.nasolabialAngle.idealRange,
      score: analysis.nasolabialAngle.score,
      profileType: 'side',
    });
  }

  if (analysis.eLine?.upperLip) {
    inputs.push({
      metricId: 'eLineUpperLip',
      metricName: 'E-Line Upper Lip',
      currentValue: analysis.eLine.upperLip.value,
      idealValue: (analysis.eLine.upperLip.idealRange.min + analysis.eLine.upperLip.idealRange.max) / 2,
      idealRange: analysis.eLine.upperLip.idealRange,
      score: analysis.eLine.upperLip.score,
      profileType: 'side',
    });
  }

  if (analysis.eLine?.lowerLip) {
    inputs.push({
      metricId: 'eLineLowerLip',
      metricName: 'E-Line Lower Lip',
      currentValue: analysis.eLine.lowerLip.value,
      idealValue: (analysis.eLine.lowerLip.idealRange.min + analysis.eLine.lowerLip.idealRange.max) / 2,
      idealRange: analysis.eLine.lowerLip.idealRange,
      score: analysis.eLine.lowerLip.score,
      profileType: 'side',
    });
  }

  if (analysis.mentolabialAngle) {
    inputs.push({
      metricId: 'mentoLabialAngle',
      metricName: 'Mentolabial Angle',
      currentValue: analysis.mentolabialAngle.value,
      idealValue: 130,
      idealRange: analysis.mentolabialAngle.idealRange,
      score: analysis.mentolabialAngle.score,
      profileType: 'side',
    });
  }

  if (analysis.nasofrontalAngle) {
    inputs.push({
      metricId: 'nasofrontalAngle',
      metricName: 'Nasofrontal Angle',
      currentValue: analysis.nasofrontalAngle.value,
      idealValue: 125,
      idealRange: analysis.nasofrontalAngle.idealRange,
      score: analysis.nasofrontalAngle.score,
      profileType: 'side',
    });
  }

  return inputs;
}

/**
 * Generate complete recommendation plan
 */
export async function generateFullRecommendationPlan(
  frontAnalysis: ComprehensiveFrontAnalysis,
  sideAnalysis: ComprehensiveSideAnalysis,
  gender: 'male' | 'female' = 'male'
): Promise<RecommendationPlan> {
  const { generateRecommendationPlan } = await import('./recommendations/engine');

  const frontInputs = frontAnalysisToMetricInputs(frontAnalysis);
  const sideInputs = sideAnalysisToMetricInputs(sideAnalysis);
  const allMetrics = [...frontInputs, ...sideInputs];

  const overallScore = (frontAnalysis.overallScore + sideAnalysis.overallScore) / 2;
  const harmonyPercent = (frontAnalysis.harmonyScore + sideAnalysis.harmonyScore) / 2;

  return generateRecommendationPlan(allMetrics, overallScore, harmonyPercent, gender);
}

// ============================================
// LEGACY INDIVIDUAL MEASUREMENT FUNCTIONS
// ============================================

/**
 * @deprecated Use analyzeFrontProfile or FACEIQ_METRICS directly
 */
export function calculateFWHR(frontLandmarks: LandmarkPoint[]): ScoreResult | null {
  const results = faceiqFrontAnalysis(frontLandmarks);
  const m = results.measurements.find(m => m.metricId === 'faceWidthToHeight');
  return m ? faceiqToScoreResult(m) : null;
}

/**
 * @deprecated Use analyzeSideProfile or FACEIQ_METRICS directly
 */
export function calculateGonialAngle(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): ScoreResult | null {
  const results = faceiqSideAnalysis(sideLandmarks, gender);
  const m = results.measurements.find(m => m.metricId === 'gonialAngle');
  return m ? faceiqToScoreResult(m) : null;
}

/**
 * @deprecated Use analyzeSideProfile or FACEIQ_METRICS directly
 */
export function calculateNasolabialAngle(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): ScoreResult | null {
  const results = faceiqSideAnalysis(sideLandmarks, gender);
  const m = results.measurements.find(m => m.metricId === 'nasolabialAngle');
  return m ? faceiqToScoreResult(m) : null;
}

/**
 * @deprecated Use analyzeFrontProfile or FACEIQ_METRICS directly
 */
export function calculateCanthalTilt(
  frontLandmarks: LandmarkPoint[],
  _side: 'left' | 'right' = 'left'
): ScoreResult | null {
  void _side; // Parameter kept for backward compatibility
  const results = faceiqFrontAnalysis(frontLandmarks);
  const m = results.measurements.find(m => m.metricId === 'lateralCanthalTilt');
  return m ? faceiqToScoreResult(m) : null;
}

/**
 * @deprecated Use analyzeFrontProfile or FACEIQ_METRICS directly
 */
export function calculateNasalIndex(frontLandmarks: LandmarkPoint[]): ScoreResult | null {
  const results = faceiqFrontAnalysis(frontLandmarks);
  const m = results.measurements.find(m => m.metricId === 'nasalIndex');
  return m ? faceiqToScoreResult(m) : null;
}

/**
 * @deprecated Use analyzeFrontProfile or FACEIQ_METRICS directly
 */
export function calculateJawRatio(
  frontLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): ScoreResult | null {
  const results = faceiqFrontAnalysis(frontLandmarks, gender);
  const m = results.measurements.find(m => m.metricId === 'jawWidthRatio');
  return m ? faceiqToScoreResult(m) : null;
}

// Re-export types
export type {
  LandmarkPoint,
  ScoringConfig,
  PopulationStats,
};

export {
  FACEIQ_SCORING_CONFIGS,
  FACEIQ_IDEAL_VALUES,
  POPULATION_STATS,
};
