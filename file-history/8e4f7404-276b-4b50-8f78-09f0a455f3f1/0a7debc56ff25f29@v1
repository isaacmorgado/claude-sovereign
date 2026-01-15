/**
 * Looksmaxxing Recommendation System
 *
 * A comprehensive system for analyzing facial metrics and generating
 * personalized treatment recommendations.
 *
 * @module recommendations
 */

// Types
export * from './types';

// Treatment Databases
export { SOFTMAXXING_TREATMENTS, getSoftmaxxingByIssue, getSoftmaxxingByMetric, getSoftmaxxingByCategory, getSoftmaxxingByEffectiveness } from './softmaxxing';
export { SURGICAL_TREATMENTS, getSurgeryByIssue, getSurgeryByMetric, getSurgeriesByRiskLevel, getSurgeriesByCostLevel, getSurgeriesByRegion, getMostEffectiveSurgeries } from './hardmaxxing';
export { SUPPLEMENTS, getSupplementsByCategory, getSupplementsByBenefit, getSupplementsByEvidence, getSupplementsByEffectiveness, getOTCSupplements, getSupplementStack } from './supplements';
export { NON_SURGICAL_TREATMENTS, getNonSurgicalByIssue, getNonSurgicalByMetric, getNonSurgicalByCategory, getFillerTreatments, getBotoxTreatments, getSkinTreatments, getLowRiskTreatments, getByDowntime } from './nonSurgical';

// Severity Classification
export {
  SEVERITY_THRESHOLDS,
  METRIC_ISSUE_MAPPINGS,
  classifyByScore,
  getSeverityThreshold,
  classifyMetricValue,
  calculateDeviation,
  getIssueForMetric,
  getTreatmentIdsForMetric,
  getOverallSeverity,
  prioritizeMetrics,
  harmonyToPSL,
  estimatePotentialPSL,
} from './severity';

// Recommendation Engine
export {
  analyzeMetric,
  analyzeAllMetrics,
  findTreatment,
  findTreatmentsForIssue,
  findTreatmentsForMetric,
  getRecommendationsForMetric,
  generateRecommendationPlan,
  getTopRecommendations,
  getRecommendationsByCost,
  getNoDowntimeRecommendations,
  formatCost,
  getPlanSummary,
} from './engine';
export type { MetricInput } from './engine';
