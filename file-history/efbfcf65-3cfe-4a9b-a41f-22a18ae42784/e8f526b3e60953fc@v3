/**
 * Severity Classification System
 * Classifies metric deviations into severity levels with treatment recommendations
 */

import { Severity, SeverityResult, SeverityThreshold, MetricIssueMapping, Gender } from './types';

// ============================================
// SEVERITY THRESHOLDS BY METRIC
// ============================================

export const SEVERITY_THRESHOLDS: SeverityThreshold[] = [
  // FRONT PROFILE METRICS
  {
    metric: 'fwhr',
    optimal: { min: 1.80, max: 2.00 },
    mild: { min: 1.65, max: 2.15 },
    moderate: { min: 1.55, max: 2.25 },
    severe: { min: 0, max: Infinity },
    unit: 'ratio',
    higherIsBetter: false, // mid-range is ideal
  },
  {
    metric: 'canthalTilt',
    optimal: { min: 4, max: 8 },
    mild: { min: 0, max: 10 },
    moderate: { min: -2, max: 12 },
    severe: { min: -Infinity, max: Infinity },
    unit: 'degrees',
    higherIsBetter: true,
  },
  {
    metric: 'facialThirdsUpper',
    optimal: { min: 30, max: 36 },
    mild: { min: 27, max: 39 },
    moderate: { min: 24, max: 42 },
    severe: { min: 0, max: Infinity },
    unit: 'percent',
  },
  {
    metric: 'facialThirdsMiddle',
    optimal: { min: 30, max: 36 },
    mild: { min: 27, max: 39 },
    moderate: { min: 24, max: 42 },
    severe: { min: 0, max: Infinity },
    unit: 'percent',
  },
  {
    metric: 'facialThirdsLower',
    optimal: { min: 30, max: 36 },
    mild: { min: 27, max: 39 },
    moderate: { min: 24, max: 42 },
    severe: { min: 0, max: Infinity },
    unit: 'percent',
  },
  {
    metric: 'nasalIndex',
    optimal: { min: 70, max: 85 },
    mild: { min: 65, max: 90 },
    moderate: { min: 60, max: 95 },
    severe: { min: 0, max: Infinity },
    unit: 'ratio',
  },
  {
    metric: 'interpupillaryDistance',
    optimal: { min: 44, max: 48 },
    mild: { min: 42, max: 50 },
    moderate: { min: 40, max: 52 },
    severe: { min: 0, max: Infinity },
    unit: 'percent',
  },
  {
    metric: 'mouthWidth',
    optimal: { min: 48, max: 54 },
    mild: { min: 44, max: 58 },
    moderate: { min: 40, max: 62 },
    severe: { min: 0, max: Infinity },
    unit: 'percent',
  },
  {
    metric: 'lipRatio',
    optimal: { min: 1.5, max: 2.0 },
    mild: { min: 1.2, max: 2.3 },
    moderate: { min: 1.0, max: 2.6 },
    severe: { min: 0, max: Infinity },
    unit: 'ratio',
  },
  {
    metric: 'jawWidthRatio',
    optimal: { min: 0.75, max: 0.80 },
    mild: { min: 0.72, max: 0.83 },
    moderate: { min: 0.68, max: 0.87 },
    severe: { min: 0, max: Infinity },
    unit: 'ratio',
  },
  {
    metric: 'facialSymmetry',
    optimal: { min: 95, max: 100 },
    mild: { min: 90, max: 100 },
    moderate: { min: 85, max: 100 },
    severe: { min: 0, max: 100 },
    unit: 'percent',
    higherIsBetter: true,
  },
  {
    metric: 'eyeSpacing',
    optimal: { min: 0.95, max: 1.05 },
    mild: { min: 0.90, max: 1.10 },
    moderate: { min: 0.85, max: 1.15 },
    severe: { min: 0, max: Infinity },
    unit: 'ratio',
  },
  {
    metric: 'noseWidth',
    optimal: { min: 0.95, max: 1.05 },
    mild: { min: 0.90, max: 1.10 },
    moderate: { min: 0.85, max: 1.15 },
    severe: { min: 0, max: Infinity },
    unit: 'ratio',
  },
  {
    metric: 'cheekboneWidth',
    optimal: { min: 0.85, max: 0.92 },
    mild: { min: 0.80, max: 0.97 },
    moderate: { min: 0.75, max: 1.02 },
    severe: { min: 0, max: Infinity },
    unit: 'ratio',
  },

  // SIDE PROFILE METRICS
  {
    metric: 'gonialAngle',
    optimal: { min: 120, max: 130 },
    mild: { min: 115, max: 135 },
    moderate: { min: 110, max: 140 },
    severe: { min: 0, max: Infinity },
    unit: 'degrees',
  },
  {
    metric: 'nasolabialAngle',
    optimal: { min: 95, max: 110 }, // Gender-adjusted in functions
    mild: { min: 85, max: 115 },
    moderate: { min: 80, max: 120 },
    severe: { min: 0, max: Infinity },
    unit: 'degrees',
  },
  {
    metric: 'nasofrontalAngle',
    optimal: { min: 130, max: 140 },
    mild: { min: 125, max: 145 },
    moderate: { min: 120, max: 150 },
    severe: { min: 0, max: Infinity },
    unit: 'degrees',
  },
  {
    metric: 'chinProjection',
    optimal: { min: -4, max: 2 },
    mild: { min: -6, max: 4 },
    moderate: { min: -8, max: 6 },
    severe: { min: -Infinity, max: Infinity },
    unit: 'mm',
  },
  {
    metric: 'mentoLabialAngle',
    optimal: { min: 110, max: 130 },
    mild: { min: 100, max: 140 },
    moderate: { min: 90, max: 150 },
    severe: { min: 0, max: Infinity },
    unit: 'degrees',
  },
  {
    metric: 'facialConvexity',
    optimal: { min: 165, max: 175 },
    mild: { min: 160, max: 180 },
    moderate: { min: 155, max: 185 },
    severe: { min: 0, max: Infinity },
    unit: 'degrees',
  },
  {
    metric: 'eLineUpperLip',
    optimal: { min: -4, max: -1 },
    mild: { min: -6, max: 1 },
    moderate: { min: -8, max: 3 },
    severe: { min: -Infinity, max: Infinity },
    unit: 'mm',
  },
  {
    metric: 'eLineLowerLip',
    optimal: { min: -2, max: 1 },
    mild: { min: -4, max: 3 },
    moderate: { min: -6, max: 5 },
    severe: { min: -Infinity, max: Infinity },
    unit: 'mm',
  },
  {
    metric: 'submCervicalAngle',
    optimal: { min: 100, max: 120 },
    mild: { min: 90, max: 130 },
    moderate: { min: 80, max: 140 },
    severe: { min: 0, max: Infinity },
    unit: 'degrees',
  },
  {
    metric: 'totalFacialConvexity',
    optimal: { min: 135, max: 145 },
    mild: { min: 130, max: 150 },
    moderate: { min: 125, max: 155 },
    severe: { min: 0, max: Infinity },
    unit: 'degrees',
  },
];

// ============================================
// METRIC TO ISSUE MAPPINGS
// ============================================

export const METRIC_ISSUE_MAPPINGS: MetricIssueMapping[] = [
  // Front Profile
  {
    metric: 'fwhr',
    lowIssue: 'narrow_face',
    highIssue: 'wide_face',
    lowTreatments: ['cheek_filler', 'cheek_implants', 'jaw_implants'],
    highTreatments: ['botox_masseter', 'buccal_fat_removal', 'zygoma_reduction', 'mandible_reduction'],
  },
  {
    metric: 'canthalTilt',
    lowIssue: 'negative_canthal_tilt',
    highIssue: 'excessive_positive_tilt',
    lowTreatments: ['canthoplasty', 'pdo_threads', 'botox_brow_lift'],
    highTreatments: [], // Rarely treated
  },
  {
    metric: 'nasalIndex',
    lowIssue: 'narrow_nose',
    highIssue: 'wide_nose',
    lowTreatments: ['nose_filler'],
    highTreatments: ['rhinoplasty_reduction', 'nose_filler'],
  },
  {
    metric: 'lipRatio',
    lowIssue: 'thin_lower_lip',
    highIssue: 'thin_upper_lip',
    lowTreatments: ['lip_filler'],
    highTreatments: ['lip_filler', 'lip_lift'],
  },
  {
    metric: 'jawWidthRatio',
    lowIssue: 'narrow_jaw',
    highIssue: 'wide_jaw',
    lowTreatments: ['jaw_implants', 'jawline_filler'],
    highTreatments: ['botox_masseter', 'mandible_reduction'],
  },
  {
    metric: 'facialSymmetry',
    lowIssue: 'facial_asymmetry',
    highIssue: 'optimal',
    lowTreatments: ['filler_correction', 'botox_asymmetry', 'bimax'],
    highTreatments: [],
  },
  {
    metric: 'cheekboneWidth',
    lowIssue: 'flat_cheeks',
    highIssue: 'wide_cheekbones',
    lowTreatments: ['cheek_filler', 'cheek_implants'],
    highTreatments: ['zygoma_reduction'],
  },

  // Side Profile
  {
    metric: 'gonialAngle',
    lowIssue: 'over_prominent_jaw',
    highIssue: 'weak_jaw',
    lowTreatments: ['mandible_reduction'],
    highTreatments: ['jaw_implants', 'jawline_filler', 'bsso'],
  },
  {
    metric: 'nasolabialAngle',
    lowIssue: 'droopy_nose_tip',
    highIssue: 'over_rotated_tip',
    lowTreatments: ['rhinoplasty_tip', 'nose_filler'],
    highTreatments: ['rhinoplasty_tip', 'rhinoplasty_reduction'],
  },
  {
    metric: 'chinProjection',
    lowIssue: 'recessed_chin',
    highIssue: 'prominent_chin',
    lowTreatments: ['genioplasty', 'chin_implant', 'chin_filler'],
    highTreatments: ['genioplasty'],
  },
  {
    metric: 'eLineUpperLip',
    lowIssue: 'lips_retrude',
    highIssue: 'lips_protrude',
    lowTreatments: ['lip_filler', 'bimax'],
    highTreatments: ['bimax', 'lip_reduction'],
  },
  {
    metric: 'eLineLowerLip',
    lowIssue: 'lips_retrude',
    highIssue: 'lips_protrude',
    lowTreatments: ['lip_filler', 'bimax'],
    highTreatments: ['bimax', 'lip_reduction'],
  },
  {
    metric: 'facialConvexity',
    lowIssue: 'concave_profile',
    highIssue: 'convex_profile',
    lowTreatments: ['bimax', 'chin_filler', 'lefort_1'],
    highTreatments: ['bimax', 'rhinoplasty_reduction'],
  },
  {
    metric: 'mentoLabialAngle',
    lowIssue: 'deep_mentolabial_fold',
    highIssue: 'flat_mentolabial_fold',
    lowTreatments: ['chin_filler', 'genioplasty'],
    highTreatments: [],
  },
  {
    metric: 'submCervicalAngle',
    lowIssue: 'undefined_neck_jaw',
    highIssue: 'excessive_neck_angle',
    lowTreatments: ['kybella', 'posture_correction', 'leanmaxxing'],
    highTreatments: [],
  },
];

// ============================================
// SEVERITY CLASSIFICATION FUNCTIONS
// ============================================

/**
 * Classify a score into a severity level
 */
export function classifyByScore(score: number): SeverityResult {
  if (score >= 85) {
    return {
      severity: 'optimal',
      label: 'Optimal',
      color: '#22c55e',
      icon: '✓',
      description: 'Excellent - within ideal range',
    };
  }
  if (score >= 70) {
    return {
      severity: 'mild',
      label: 'Good',
      color: '#84cc16',
      icon: '○',
      description: 'Good - minor deviation from ideal',
    };
  }
  if (score >= 50) {
    return {
      severity: 'moderate',
      label: 'Average',
      color: '#f59e0b',
      icon: '△',
      description: 'Average - noticeable deviation',
    };
  }
  return {
    severity: 'severe',
    label: 'Below Average',
    color: '#ef4444',
    icon: '✗',
    description: 'Below average - significant deviation',
  };
}

/**
 * Get severity threshold for a specific metric
 */
export function getSeverityThreshold(metric: string): SeverityThreshold | undefined {
  return SEVERITY_THRESHOLDS.find(t => t.metric === metric);
}

/**
 * Classify a metric value based on its specific thresholds
 */
export function classifyMetricValue(
  metric: string,
  value: number,
  gender?: Gender
): SeverityResult {
  const threshold = getSeverityThreshold(metric);

  if (!threshold) {
    // Fallback to score-based classification if no threshold defined
    return classifyByScore(value);
  }

  // Apply gender-specific adjustments
  const adjustedThreshold = { ...threshold };
  if (gender && metric === 'nasolabialAngle') {
    if (gender === 'male') {
      adjustedThreshold.optimal = { min: 90, max: 105 };
    } else {
      adjustedThreshold.optimal = { min: 100, max: 115 };
    }
  }

  // Check which range the value falls into
  if (value >= adjustedThreshold.optimal.min && value <= adjustedThreshold.optimal.max) {
    return {
      severity: 'optimal',
      label: 'Optimal',
      color: '#22c55e',
      icon: '✓',
      description: `Within ideal range (${adjustedThreshold.optimal.min}-${adjustedThreshold.optimal.max}${adjustedThreshold.unit})`,
    };
  }

  if (value >= adjustedThreshold.mild.min && value <= adjustedThreshold.mild.max) {
    return {
      severity: 'mild',
      label: 'Good',
      color: '#84cc16',
      icon: '○',
      description: 'Minor deviation from ideal',
    };
  }

  if (value >= adjustedThreshold.moderate.min && value <= adjustedThreshold.moderate.max) {
    return {
      severity: 'moderate',
      label: 'Average',
      color: '#f59e0b',
      icon: '△',
      description: 'Noticeable deviation from ideal',
    };
  }

  return {
    severity: 'severe',
    label: 'Below Average',
    color: '#ef4444',
    icon: '✗',
    description: 'Significant deviation from ideal',
  };
}

/**
 * Calculate deviation from ideal for a metric
 */
export function calculateDeviation(
  metric: string,
  value: number
): { deviation: number; deviationPercent: number; direction: 'low' | 'high' | 'optimal' } {
  const threshold = getSeverityThreshold(metric);

  if (!threshold) {
    return { deviation: 0, deviationPercent: 0, direction: 'optimal' };
  }

  const idealMidpoint = (threshold.optimal.min + threshold.optimal.max) / 2;
  const deviation = value - idealMidpoint;
  const idealRange = threshold.optimal.max - threshold.optimal.min;
  const deviationPercent = (Math.abs(deviation) / idealRange) * 100;

  let direction: 'low' | 'high' | 'optimal';
  if (value >= threshold.optimal.min && value <= threshold.optimal.max) {
    direction = 'optimal';
  } else if (value < threshold.optimal.min) {
    direction = 'low';
  } else {
    direction = 'high';
  }

  return { deviation, deviationPercent, direction };
}

/**
 * Get the issue name for a metric deviation
 */
export function getIssueForMetric(
  metric: string,
  direction: 'low' | 'high' | 'optimal'
): string | null {
  if (direction === 'optimal') return null;

  const mapping = METRIC_ISSUE_MAPPINGS.find(m => m.metric === metric);
  if (!mapping) return null;

  return direction === 'low' ? mapping.lowIssue : mapping.highIssue;
}

/**
 * Get treatment IDs for a metric deviation
 */
export function getTreatmentIdsForMetric(
  metric: string,
  direction: 'low' | 'high' | 'optimal'
): string[] {
  if (direction === 'optimal') return [];

  const mapping = METRIC_ISSUE_MAPPINGS.find(m => m.metric === metric);
  if (!mapping) return [];

  return direction === 'low' ? mapping.lowTreatments : mapping.highTreatments;
}

/**
 * Get overall severity from multiple metric analyses
 */
export function getOverallSeverity(severities: Severity[]): SeverityResult {
  const severeCount = severities.filter(s => s === 'severe').length;
  const moderateCount = severities.filter(s => s === 'moderate').length;
  const mildCount = severities.filter(s => s === 'mild').length;

  // Weighted scoring
  const score = (
    (severities.filter(s => s === 'optimal').length * 100) +
    (mildCount * 75) +
    (moderateCount * 50) +
    (severeCount * 25)
  ) / severities.length;

  return classifyByScore(score);
}

/**
 * Prioritize metrics by severity and impact
 */
export function prioritizeMetrics(
  metricSeverities: Array<{ metric: string; severity: Severity; impact: number }>
): Array<{ metric: string; severity: Severity; priority: 'high' | 'medium' | 'low' }> {
  const severityWeight: Record<Severity, number> = {
    severe: 4,
    moderate: 3,
    mild: 2,
    optimal: 1,
  };

  return metricSeverities
    .map(m => ({
      ...m,
      score: severityWeight[m.severity] * m.impact,
    }))
    .sort((a, b) => b.score - a.score)
    .map((m, index) => ({
      metric: m.metric,
      severity: m.severity,
      priority: index < 3 ? 'high' as const :
                index < 7 ? 'medium' as const :
                'low' as const,
    }));
}

// ============================================
// PSL RATING CONVERSION
// ============================================

/**
 * Convert harmony score to PSL rating
 */
export function harmonyToPSL(harmonyPercent: number): {
  psl: number;
  tier: string;
  percentile: number;
  description: string;
} {
  // Handle edge cases: NaN, Infinity, undefined, null
  // Treat invalid inputs as 0 (minimum harmony)
  let safeHarmonyPercent = harmonyPercent;
  if (
    typeof harmonyPercent !== 'number' ||
    !Number.isFinite(harmonyPercent) ||
    Number.isNaN(harmonyPercent)
  ) {
    safeHarmonyPercent = 0;
  }

  // Clamp to valid range 0-100
  safeHarmonyPercent = Math.max(0, Math.min(100, safeHarmonyPercent));

  // Based on FaceIQ formula: Harmony % = ((Score - Min) / (Max - Min)) * 100
  // Where Max = 333.71, Min = -337.71

  // Convert harmony percent to approximate PSL
  // Harmony 0% = PSL 3.0, Harmony 100% = PSL 7.5
  const psl = 3.0 + (safeHarmonyPercent / 100) * 4.5;
  const clampedPSL = Math.max(3.0, Math.min(7.5, psl));

  // Determine tier
  let tier: string;
  let percentile: number;
  let description: string;

  if (clampedPSL >= 7.5) {
    tier = 'Top Model';
    percentile = 99.99;
    description = 'Near perfection - world-class genetics';
  } else if (clampedPSL >= 7.0) {
    tier = 'Chad';
    percentile = 99.87;
    description = 'Exceptional - top 0.1%';
  } else if (clampedPSL >= 6.5) {
    tier = 'Chadlite';
    percentile = 99.0;
    description = 'Very attractive - top 1%';
  } else if (clampedPSL >= 6.0) {
    tier = 'High Tier Normie+';
    percentile = 97.25;
    description = 'Notably attractive - top 3%';
  } else if (clampedPSL >= 5.5) {
    tier = 'High Tier Normie';
    percentile = 90.0;
    description = 'Above average - top 10%';
  } else if (clampedPSL >= 5.0) {
    tier = 'Mid Tier Normie+';
    percentile = 84.15;
    description = 'Slightly above average';
  } else if (clampedPSL >= 4.5) {
    tier = 'Mid Tier Normie';
    percentile = 65.0;
    description = 'Average';
  } else if (clampedPSL >= 4.0) {
    tier = 'Low Tier Normie';
    percentile = 50.0;
    description = 'Median';
  } else if (clampedPSL >= 3.5) {
    tier = 'Below Average';
    percentile = 30.0;
    description = 'Below average';
  } else {
    tier = 'Subpar';
    percentile = 15.0;
    description = 'Noticeably below average';
  }

  return {
    psl: Math.round(clampedPSL * 10) / 10,
    tier,
    percentile,
    description,
  };
}

/**
 * Estimate potential PSL improvement from treatments
 */
export function estimatePotentialPSL(
  currentPSL: number,
  treatmentImprovements: number[]
): { potentialPSL: number; totalImprovement: number } {
  // Handle edge cases for currentPSL
  let safePSL = currentPSL;
  if (typeof currentPSL !== 'number' || !Number.isFinite(currentPSL) || Number.isNaN(currentPSL)) {
    safePSL = 3.0; // Default to minimum PSL
  }
  safePSL = Math.max(3.0, Math.min(7.5, safePSL));

  // Handle edge cases for treatmentImprovements array
  if (!Array.isArray(treatmentImprovements) || treatmentImprovements.length === 0) {
    return {
      potentialPSL: Math.round(safePSL * 10) / 10,
      totalImprovement: 0,
    };
  }

  // Filter out invalid improvement values
  const validImprovements = treatmentImprovements.filter(
    (imp) => typeof imp === 'number' && Number.isFinite(imp) && !Number.isNaN(imp) && imp > 0
  );

  if (validImprovements.length === 0) {
    return {
      potentialPSL: Math.round(safePSL * 10) / 10,
      totalImprovement: 0,
    };
  }

  // Sum improvements with diminishing returns
  const sortedImprovements = validImprovements.sort((a, b) => b - a);

  let totalImprovement = 0;
  sortedImprovements.forEach((improvement, index) => {
    // Each subsequent improvement is reduced by 20%
    const diminishingFactor = Math.pow(0.8, index);
    totalImprovement += improvement * diminishingFactor;
  });

  // Cap total improvement at realistic level
  const cappedImprovement = Math.min(totalImprovement, 2.5);
  const potentialPSL = Math.min(7.5, safePSL + cappedImprovement);

  return {
    potentialPSL: Math.round(potentialPSL * 10) / 10,
    totalImprovement: Math.round(cappedImprovement * 10) / 10,
  };
}
