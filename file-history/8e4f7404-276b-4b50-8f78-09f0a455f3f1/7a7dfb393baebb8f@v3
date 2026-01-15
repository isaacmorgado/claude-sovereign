/**
 * Recommendation Engine
 * Analyzes facial metrics and generates personalized treatment recommendations
 */

import {
  Treatment,
  Surgery,
  Supplement,
  TreatmentRecommendation,
  MetricAnalysis,
  RecommendationPlan,
  OrderOfOperation,
  TreatmentCategory,
  Gender,
  ProfileType,
} from './types';
import { SOFTMAXXING_TREATMENTS } from './softmaxxing';
import { SURGICAL_TREATMENTS } from './hardmaxxing';
import { SUPPLEMENTS } from './supplements';
import { NON_SURGICAL_TREATMENTS } from './nonSurgical';
import {
  classifyMetricValue,
  calculateDeviation,
  getIssueForMetric,
  getTreatmentIdsForMetric,
  getOverallSeverity,
  harmonyToPSL,
  estimatePotentialPSL,
} from './severity';

// ============================================
// ALL TREATMENTS COMBINED
// ============================================

const ALL_TREATMENTS: (Treatment | Surgery)[] = [
  ...SOFTMAXXING_TREATMENTS,
  ...NON_SURGICAL_TREATMENTS,
  ...SURGICAL_TREATMENTS,
];

// ============================================
// METRIC ANALYSIS
// ============================================

export interface MetricInput {
  metricId: string;
  metricName: string;
  currentValue: number;
  idealValue: number;
  idealRange: { min: number; max: number };
  score: number;
  profileType: ProfileType;
}

/**
 * Analyze a single metric and determine severity
 */
export function analyzeMetric(
  input: MetricInput,
  gender?: Gender
): MetricAnalysis {
  const { deviation, deviationPercent, direction } = calculateDeviation(
    input.metricId,
    input.currentValue
  );

  const severity = classifyMetricValue(input.metricId, input.currentValue, gender);
  const issue = getIssueForMetric(input.metricId, direction);

  return {
    metricId: input.metricId,
    metricName: input.metricName,
    currentValue: input.currentValue,
    idealValue: input.idealValue,
    idealRange: input.idealRange,
    deviation,
    deviationPercent,
    score: input.score,
    severity,
    issue: issue || undefined,
    profileType: input.profileType,
  };
}

/**
 * Analyze all metrics and sort by severity
 */
export function analyzeAllMetrics(
  metrics: MetricInput[],
  gender?: Gender
): MetricAnalysis[] {
  const analyses = metrics.map(m => analyzeMetric(m, gender));

  // Sort by severity (severe first) then by score (lowest first)
  const severityOrder = { severe: 0, moderate: 1, mild: 2, optimal: 3 };

  return analyses.sort((a, b) => {
    const severityDiff = severityOrder[a.severity.severity] - severityOrder[b.severity.severity];
    if (severityDiff !== 0) return severityDiff;
    return a.score - b.score;
  });
}

// ============================================
// TREATMENT MATCHING
// ============================================

/**
 * Find treatment by ID
 */
export function findTreatment(id: string): Treatment | Surgery | Supplement | undefined {
  const treatment = ALL_TREATMENTS.find(t => t.id === id);
  if (treatment) return treatment;

  return SUPPLEMENTS.find(s => s.id === id);
}

/**
 * Find treatments that target a specific issue
 */
export function findTreatmentsForIssue(issue: string): (Treatment | Surgery)[] {
  return ALL_TREATMENTS.filter(t =>
    t.targetIssues.some(i =>
      i.toLowerCase().includes(issue.toLowerCase()) ||
      issue.toLowerCase().includes(i.toLowerCase())
    )
  );
}

/**
 * Find treatments that target a specific metric
 */
export function findTreatmentsForMetric(metricId: string): (Treatment | Surgery)[] {
  return ALL_TREATMENTS.filter(t =>
    t.targetMetrics.some(m =>
      m.toLowerCase().includes(metricId.toLowerCase()) ||
      metricId.toLowerCase().includes(m.toLowerCase())
    )
  );
}

/**
 * Score treatment relevance for a metric analysis
 */
function scoreTreatmentRelevance(
  treatment: Treatment | Surgery,
  analysis: MetricAnalysis
): number {
  let score = 0;

  // Check if treatment targets this metric
  const targetsMetric = treatment.targetMetrics.some(m =>
    m.toLowerCase().includes(analysis.metricId.toLowerCase())
  );
  if (targetsMetric) score += 30;

  // Check if treatment addresses the issue
  if (analysis.issue) {
    const addressesIssue = treatment.targetIssues.some(i =>
      i.toLowerCase().includes(analysis.issue!.toLowerCase()) ||
      analysis.issue!.toLowerCase().includes(i.toLowerCase())
    );
    if (addressesIssue) score += 40;
  }

  // Factor in severity
  const severityMultiplier = {
    severe: 1.5,
    moderate: 1.2,
    mild: 1.0,
    optimal: 0.3,
  };
  score *= severityMultiplier[analysis.severity.severity];

  // Factor in treatment effectiveness
  score += treatment.effectiveness * 2;

  // Factor in PSL improvement potential
  const avgPSLImprovement = (treatment.pslImprovement.min + treatment.pslImprovement.max) / 2;
  score += avgPSLImprovement * 10;

  return Math.round(score);
}

/**
 * Generate treatment recommendations for a metric analysis
 */
export function getRecommendationsForMetric(
  analysis: MetricAnalysis,
  gender?: Gender,
  maxRecommendations: number = 5
): TreatmentRecommendation[] {
  if (analysis.severity.severity === 'optimal') {
    return []; // No treatment needed for optimal metrics
  }

  // Get treatment IDs from mapping
  const { direction } = calculateDeviation(analysis.metricId, analysis.currentValue);
  const treatmentIds = getTreatmentIdsForMetric(analysis.metricId, direction);

  // Find matching treatments
  let treatments: (Treatment | Surgery)[] = [];

  // First, add treatments from the mapping
  for (const id of treatmentIds) {
    const treatment = findTreatment(id);
    if (treatment && 'category' in treatment && treatment.category !== undefined) {
      treatments.push(treatment as Treatment | Surgery);
    }
  }

  // Then, find additional treatments that target this metric or issue
  const additionalTreatments = [
    ...findTreatmentsForMetric(analysis.metricId),
    ...(analysis.issue ? findTreatmentsForIssue(analysis.issue) : []),
  ];

  // Remove duplicates
  const seenIds = treatments.map(t => t.id);
  for (const t of additionalTreatments) {
    if (!seenIds.includes(t.id)) {
      seenIds.push(t.id);
      treatments.push(t);
    }
  }

  // Filter by gender if specified
  if (gender) {
    treatments = treatments.filter(t =>
      !t.genderSpecific || t.genderSpecific === gender
    );
  }

  // Score and rank treatments
  const scoredTreatments = treatments.map(treatment => ({
    treatment,
    relevanceScore: scoreTreatmentRelevance(treatment, analysis),
  }));

  // Sort by relevance score
  scoredTreatments.sort((a, b) => b.relevanceScore - a.relevanceScore);

  // Create recommendations
  return scoredTreatments.slice(0, maxRecommendations).map(({ treatment, relevanceScore }) => {
    const avgPSLImprovement = (treatment.pslImprovement.min + treatment.pslImprovement.max) / 2;

    return {
      treatment,
      priority: relevanceScore >= 60 ? 'high' as const :
                relevanceScore >= 40 ? 'medium' as const :
                'low' as const,
      relevanceScore,
      targetMetrics: [analysis.metricId],
      estimatedImprovement: avgPSLImprovement,
      reasoning: generateReasoning(treatment, analysis),
    };
  });
}

/**
 * Generate human-readable reasoning for a recommendation
 */
function generateReasoning(
  treatment: Treatment | Surgery,
  analysis: MetricAnalysis
): string {
  const parts: string[] = [];

  // Issue description
  if (analysis.issue) {
    parts.push(`Addresses ${analysis.issue.replace(/_/g, ' ')}`);
  }

  // Effectiveness
  parts.push(`Effectiveness: ${treatment.effectiveness}/10`);

  // PSL improvement
  const pslRange = `${treatment.pslImprovement.min}-${treatment.pslImprovement.max}`;
  parts.push(`Expected improvement: ${pslRange} PSL points`);

  // Timeline
  parts.push(`Results in: ${treatment.timelineToResults}`);

  return parts.join('. ') + '.';
}

// ============================================
// RECOMMENDATION PLAN GENERATION
// ============================================

/**
 * Generate a comprehensive recommendation plan
 */
export function generateRecommendationPlan(
  metrics: MetricInput[],
  overallScore: number,
  harmonyPercent: number,
  gender?: Gender
): RecommendationPlan {
  // Analyze all metrics
  const metricAnalyses = analyzeAllMetrics(metrics, gender);

  // Determine strengths and weaknesses
  const strengths = metricAnalyses.filter(m =>
    m.severity.severity === 'optimal' || m.score >= 85
  );
  const weaknesses = metricAnalyses.filter(m =>
    m.severity.severity !== 'optimal' && m.score < 85
  );

  // Get recommendations for each weakness
  const allRecommendations: TreatmentRecommendation[] = [];
  for (const weakness of weaknesses) {
    const recs = getRecommendationsForMetric(weakness, gender);
    allRecommendations.push(...recs);
  }

  // Deduplicate recommendations (same treatment might help multiple metrics)
  const uniqueRecommendations = deduplicateRecommendations(allRecommendations);

  // Categorize recommendations
  const lifestyle = uniqueRecommendations.filter(r =>
    r.treatment.category === 'lifestyle' || r.treatment.category === 'softmaxxing'
  );
  const softmaxxing = uniqueRecommendations.filter(r =>
    r.treatment.category === 'softmaxxing'
  );
  const nonSurgical = uniqueRecommendations.filter(r =>
    r.treatment.category === 'non_surgical'
  );
  const minimallyInvasive = uniqueRecommendations.filter(r =>
    r.treatment.category === 'minimally_invasive'
  );
  const surgical = uniqueRecommendations.filter(r =>
    r.treatment.category === 'surgical'
  );

  // Get supplement recommendations
  const supplements = getSupplementRecommendations(weaknesses, gender);

  // Calculate PSL ratings
  const pslRating = harmonyToPSL(harmonyPercent);
  const treatmentImprovements = uniqueRecommendations.map(r => r.estimatedImprovement);
  const potentialPSL = estimatePotentialPSL(pslRating.psl, treatmentImprovements);

  // Generate order of operations
  const orderOfOperations = generateOrderOfOperations(uniqueRecommendations);

  // Get overall severity
  const overallSeverity = getOverallSeverity(metricAnalyses.map(m => m.severity.severity));

  return {
    overallScore,
    overallSeverity,
    harmonyScore: harmonyPercent,
    percentile: pslRating.percentile,
    metricAnalyses,
    strengths,
    weaknesses,
    lifestyle,
    softmaxxing,
    nonSurgical,
    minimallyInvasive,
    surgical,
    supplements,
    currentPSL: pslRating.psl,
    potentialPSL: potentialPSL.potentialPSL,
    potentialImprovement: potentialPSL.totalImprovement,
    orderOfOperations,
  };
}

/**
 * Deduplicate recommendations, combining target metrics for same treatment
 */
function deduplicateRecommendations(
  recommendations: TreatmentRecommendation[]
): TreatmentRecommendation[] {
  const byId = new Map<string, TreatmentRecommendation>();

  for (const rec of recommendations) {
    const existing = byId.get(rec.treatment.id);
    if (existing) {
      // Combine target metrics (deduplicate using filter)
      const combined = [...existing.targetMetrics, ...rec.targetMetrics];
      existing.targetMetrics = combined.filter((m, i) => combined.indexOf(m) === i);

      // Take higher relevance score
      existing.relevanceScore = Math.max(existing.relevanceScore, rec.relevanceScore);

      // Update priority based on new relevance
      existing.priority = existing.relevanceScore >= 60 ? 'high' :
                         existing.relevanceScore >= 40 ? 'medium' :
                         'low';
    } else {
      byId.set(rec.treatment.id, { ...rec });
    }
  }

  return Array.from(byId.values()).sort((a, b) => b.relevanceScore - a.relevanceScore);
}

/**
 * Get supplement recommendations based on weaknesses
 */
function getSupplementRecommendations(
  weaknesses: MetricAnalysis[],
  gender?: Gender
): TreatmentRecommendation[] {
  const recommendations: TreatmentRecommendation[] = [];

  // Map weakness types to supplement categories
  const hasSkinIssues = weaknesses.some(w =>
    w.issue?.includes('skin') || w.metricId.includes('skin')
  );
  const hasHairIssues = weaknesses.some(w =>
    w.issue?.includes('hair') || w.metricId.includes('hairline')
  );
  const hasGeneralAging = weaknesses.some(w =>
    w.issue?.includes('aging') || w.severity.severity === 'moderate' || w.severity.severity === 'severe'
  );

  // Helper to create supplement recommendation
  const createSupplementRec = (
    supp: Supplement,
    priority: 'high' | 'medium' | 'low',
    relevanceScore: number,
    targetMetrics: string[],
    reasoning: string
  ): TreatmentRecommendation => ({
    treatment: {
      id: supp.id,
      name: supp.name,
      category: 'lifestyle',
      description: supp.description,
      howItWorks: `Dosage: ${supp.dosage} ${supp.frequency}`,
      effectiveness: supp.effectiveness,
      evidenceLevel: supp.evidenceLevel,
      pslImprovement: { min: 0.05, max: 0.15 },
      costLevel: supp.costPerMonth.max > 30 ? 'medium' : 'low',
      costRange: { min: supp.costPerMonth.min, max: supp.costPerMonth.max, currency: 'USD' },
      costFrequency: 'monthly',
      timelineToResults: supp.timelineToResults,
      resultsDuration: 'Ongoing with continued use',
      maintenanceRequired: true,
      maintenanceFrequency: supp.frequency,
      recoveryTime: 'None',
      downtime: 'None',
      painLevel: 'none',
      riskLevel: supp.riskLevel,
      sideEffects: supp.sideEffects,
      contraindications: supp.contraindications,
      targetMetrics,
      targetIssues: supp.targetBenefits,
      notes: supp.notes,
      sources: supp.sources,
    },
    priority,
    relevanceScore,
    targetMetrics,
    estimatedImprovement: 0.1,
    reasoning,
  });

  // Add relevant supplements
  if (hasSkinIssues || hasGeneralAging) {
    const skinSupplements = SUPPLEMENTS.filter(s =>
      s.category === 'skin' || s.category === 'anti-aging'
    );
    for (const supp of skinSupplements.slice(0, 3)) {
      recommendations.push(createSupplementRec(
        supp,
        'medium',
        50,
        ['skin_quality'],
        `${supp.name} supports skin health and anti-aging.`
      ));
    }
  }

  if (hasHairIssues && gender === 'male') {
    const hairSupplements = SUPPLEMENTS.filter(s => s.category === 'hair');
    for (const supp of hairSupplements.slice(0, 3)) {
      recommendations.push(createSupplementRec(
        supp,
        'medium',
        45,
        ['hairline'],
        `${supp.name} supports hair health.`
      ));
    }
  }

  // Always recommend foundational supplements
  const foundational = SUPPLEMENTS.filter(s =>
    ['vitamin_d3', 'omega_3', 'magnesium'].includes(s.id)
  );
  for (const supp of foundational) {
    if (!recommendations.some(r => r.treatment.id === supp.id)) {
      recommendations.push(createSupplementRec(
        supp,
        'low',
        30,
        ['general_health'],
        `${supp.name} supports overall health and wellbeing.`
      ));
    }
  }

  return recommendations.slice(0, 10);
}

/**
 * Generate order of operations for treatments
 */
function generateOrderOfOperations(
  recommendations: TreatmentRecommendation[]
): OrderOfOperation[] {
  const operations: OrderOfOperation[] = [];

  // Define category order: lifestyle -> softmaxxing -> non-surgical -> minimally invasive -> surgical
  const categoryOrder: TreatmentCategory[] = [
    'lifestyle',
    'softmaxxing',
    'non_surgical',
    'minimally_invasive',
    'surgical',
  ];

  // Group by category (only for valid treatment categories)
  const validCategories: TreatmentCategory[] = ['lifestyle', 'softmaxxing', 'non_surgical', 'minimally_invasive', 'surgical'];
  const byCategory = new Map<TreatmentCategory, TreatmentRecommendation[]>();
  for (const rec of recommendations) {
    const cat = rec.treatment.category as TreatmentCategory;
    if (validCategories.includes(cat)) {
      if (!byCategory.has(cat)) {
        byCategory.set(cat, []);
      }
      byCategory.get(cat)!.push(rec);
    }
  }

  let step = 1;
  for (const category of categoryOrder) {
    const recs = byCategory.get(category) || [];
    // Sort by priority and relevance
    recs.sort((a, b) => {
      if (a.priority !== b.priority) {
        const priorityOrder = { high: 0, medium: 1, low: 2 };
        return priorityOrder[a.priority] - priorityOrder[b.priority];
      }
      return b.relevanceScore - a.relevanceScore;
    });

    for (const rec of recs.slice(0, 3)) { // Max 3 per category
      const treatment = rec.treatment as Treatment | Surgery;
      const operation: OrderOfOperation = {
        step,
        category,
        treatment,
        reasoning: getStepReasoning(step, category),
      };

      // Add prerequisites for surgical procedures
      if (category === 'surgical') {
        operation.prerequisites = ['Complete non-surgical options first', 'Consult with board-certified surgeon'];
        operation.waitTime = '6-12 months recovery between major procedures';
      }

      operations.push(operation);
      step++;
    }
  }

  return operations;
}

/**
 * Generate reasoning for a step in order of operations
 */
function getStepReasoning(
  step: number,
  category: TreatmentCategory
): string {
  if (step === 1) {
    return 'Start with foundational changes before considering more invasive options.';
  }

  if (category === 'lifestyle' || category === 'softmaxxing') {
    return 'Low-risk, reversible changes that can provide noticeable improvement.';
  }

  if (category === 'non_surgical') {
    return 'Non-invasive treatments with minimal downtime to test results before committing to surgery.';
  }

  if (category === 'minimally_invasive') {
    return 'Minimally invasive procedures can provide significant results with less risk than surgery.';
  }

  if (category === 'surgical') {
    return 'Consider surgery only after exhausting less invasive options and with realistic expectations.';
  }

  return '';
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

/**
 * Get top priority recommendations across all categories
 */
export function getTopRecommendations(
  plan: RecommendationPlan,
  count: number = 5
): TreatmentRecommendation[] {
  const all = [
    ...plan.lifestyle,
    ...plan.softmaxxing,
    ...plan.nonSurgical,
    ...plan.minimallyInvasive,
    ...plan.surgical,
  ];

  return all
    .sort((a, b) => b.relevanceScore - a.relevanceScore)
    .slice(0, count);
}

/**
 * Get recommendations filtered by cost level
 */
export function getRecommendationsByCost(
  plan: RecommendationPlan,
  maxCost: 'free' | 'low' | 'medium' | 'high' | 'very_high'
): TreatmentRecommendation[] {
  const costOrder = ['free', 'low', 'medium', 'high', 'very_high'];
  const maxCostIndex = costOrder.indexOf(maxCost);

  const all = [
    ...plan.lifestyle,
    ...plan.softmaxxing,
    ...plan.nonSurgical,
    ...plan.minimallyInvasive,
    ...plan.surgical,
  ];

  return all.filter(r => {
    const treatment = r.treatment as Treatment;
    if ('costLevel' in treatment) {
      return costOrder.indexOf(treatment.costLevel) <= maxCostIndex;
    }
    return true;
  });
}

/**
 * Get recommendations with minimal downtime
 */
export function getNoDowntimeRecommendations(
  plan: RecommendationPlan
): TreatmentRecommendation[] {
  const all = [
    ...plan.lifestyle,
    ...plan.softmaxxing,
    ...plan.nonSurgical,
    ...plan.minimallyInvasive,
  ];

  return all.filter(r => {
    const treatment = r.treatment as Treatment;
    if ('downtime' in treatment) {
      const downtime = treatment.downtime.toLowerCase();
      return downtime.includes('none') || downtime.includes('minimal');
    }
    return true;
  });
}

/**
 * Format cost for display
 */
export function formatCost(treatment: Treatment | Surgery): string {
  const { min, max, currency } = treatment.costRange;
  const symbol = currency === 'USD' ? '$' : currency === 'EUR' ? '€' : currency === 'GBP' ? '£' : currency;

  if (min === max) {
    return `${symbol}${min.toLocaleString()}`;
  }

  return `${symbol}${min.toLocaleString()} - ${symbol}${max.toLocaleString()}`;
}

/**
 * Get summary statistics for a plan
 */
export function getPlanSummary(plan: RecommendationPlan): {
  totalRecommendations: number;
  highPriority: number;
  mediumPriority: number;
  lowPriority: number;
  categoryCounts: Record<string, number>;
  estimatedTotalImprovement: number;
} {
  const all = [
    ...plan.lifestyle,
    ...plan.softmaxxing,
    ...plan.nonSurgical,
    ...plan.minimallyInvasive,
    ...plan.surgical,
  ];

  return {
    totalRecommendations: all.length,
    highPriority: all.filter(r => r.priority === 'high').length,
    mediumPriority: all.filter(r => r.priority === 'medium').length,
    lowPriority: all.filter(r => r.priority === 'low').length,
    categoryCounts: {
      lifestyle: plan.lifestyle.length,
      softmaxxing: plan.softmaxxing.length,
      nonSurgical: plan.nonSurgical.length,
      minimallyInvasive: plan.minimallyInvasive.length,
      surgical: plan.surgical.length,
      supplements: plan.supplements.length,
    },
    estimatedTotalImprovement: plan.potentialImprovement,
  };
}
