/**
 * Harmony Facial Analysis Scoring System - Barrel Export
 *
 * This file re-exports all scoring functionality from modular files.
 * The actual implementations are split across:
 * - ./scoring/types.ts - Type definitions
 * - ./scoring/calculator.ts - Core scoring algorithms
 * - ./scoring/analyzer.ts - Profile analysis functions
 * - ./data/metric-configs.ts - Metric configurations
 * - ./data/demographic-overrides.ts - Ethnicity/gender overrides
 */

// ============================================
// TYPE EXPORTS
// ============================================
export type {
  Point,
  QualityTier,
  SeverityLevel,
  MeasurementUnit,
  MetricPolarity,
  MetricConfig,
  BezierCurveConfig,
  CurvePoint,
  MetricScoreResult,
  HarmonyAnalysis,
  FlawAssessment,
  StrengthAssessment,
  Ethnicity,
  Gender,
  DemographicKey,
  DemographicOverride,
  DemographicOptions,
  FlawMapping,
  FrontProfileResults,
  SideProfileResults,
  PSLRating,
  LandmarkPoint,
} from './scoring/types';

// ============================================
// CALCULATOR EXPORTS
// ============================================
export {
  calculateMetricScore,
  isValueAcceptable,
  interpolateCustomCurve,
  cubicBezier,
  cubicBezierDerivative,
  catmullRomSpline,
  standardizeScore,
  getQualityTier,
  getSeverityLevel,
  getDeviationDescription,
  getUnitLabel,
  distance,
  calculateAngle,
  perpendicularDistance,
  calculateHarmonyPercentile,
  normalCDF,
  convertToPSL,
  METRIC_FLAW_MAPPINGS,
  METRIC_CUSTOM_CURVES,
} from './scoring/calculator';

// ============================================
// ANALYZER EXPORTS
// ============================================
export {
  getLandmark,
  scoreMeasurement,
  analyzeFrontProfile,
  analyzeSideProfile,
  analyzeHarmony,
} from './scoring/analyzer';

// ============================================
// DATA EXPORTS
// ============================================
export { METRIC_CONFIGS, MEASUREMENT_CATEGORIES } from './data/metric-configs';
export { DEMOGRAPHIC_OVERRIDES, getMetricConfigForDemographics } from './data/demographic-overrides';

// Re-export bezier curves for convenience
export { BEZIER_CURVES } from './bezier-curves';
