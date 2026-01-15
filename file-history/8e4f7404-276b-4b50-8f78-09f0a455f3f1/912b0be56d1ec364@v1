/**
 * Recommendation System Types
 * Comprehensive type definitions for looksmaxxing recommendations
 */

// ============================================
// ENUMS & BASIC TYPES
// ============================================

export type Severity = 'optimal' | 'mild' | 'moderate' | 'severe';

export type TreatmentCategory =
  | 'lifestyle'
  | 'softmaxxing'
  | 'non_surgical'
  | 'minimally_invasive'
  | 'surgical';

export type CostLevel = 'free' | 'low' | 'medium' | 'high' | 'very_high';

export type EvidenceLevel = 'strong' | 'moderate' | 'weak' | 'anecdotal';

export type RiskLevel = 'none' | 'very_low' | 'low' | 'medium' | 'high' | 'very_high';

export type Gender = 'male' | 'female';

export type ProfileType = 'front' | 'side';

// ============================================
// TREATMENT TYPES
// ============================================

export interface Treatment {
  id: string;
  name: string;
  category: TreatmentCategory;
  description: string;
  howItWorks: string;

  // Effectiveness
  effectiveness: number; // 1-10
  evidenceLevel: EvidenceLevel;
  pslImprovement: { min: number; max: number };

  // Costs
  costLevel: CostLevel;
  costRange: { min: number; max: number; currency: string };
  costFrequency: 'one-time' | 'monthly' | 'per-session' | 'annual';

  // Timeline
  timelineToResults: string;
  resultsDuration: string;
  maintenanceRequired: boolean;
  maintenanceFrequency?: string;

  // Recovery
  recoveryTime: string;
  downtime: string;
  painLevel: 'none' | 'low' | 'moderate' | 'high';

  // Risk
  riskLevel: RiskLevel;
  sideEffects: string[];
  contraindications: string[];

  // Applicability
  targetMetrics: string[];
  targetIssues: string[];
  genderSpecific?: Gender;
  ageRestrictions?: { min?: number; max?: number };

  // Additional info
  notes?: string[];
  sources?: string[];
}

export interface Surgery extends Treatment {
  category: 'surgical';
  surgeonRecommendations?: SurgeonInfo[];
  regionalCosts: RegionalCost[];
  revisionRate?: number;
  permanence: 'permanent' | 'semi-permanent' | 'temporary';
  hospitalStay?: string;
  anesthesiaType: 'local' | 'sedation' | 'general';
}

export interface SurgeonInfo {
  name: string;
  location: string;
  specialty: string;
  costRange: string;
  notes?: string;
}

export interface RegionalCost {
  region: string;
  min: number;
  max: number;
  currency: string;
  notes?: string;
}

export interface Supplement {
  id: string;
  name: string;
  category: 'skin' | 'hair' | 'bone' | 'hormonal' | 'anti-aging' | 'general';
  description: string;

  // Dosage
  dosage: string;
  frequency: string;
  timing?: string; // e.g., "with meals", "before bed"

  // Effectiveness
  effectiveness: number; // 1-10
  evidenceLevel: EvidenceLevel;

  // Cost
  costPerMonth: { min: number; max: number };

  // Timeline
  timelineToResults: string;

  // Safety
  riskLevel: RiskLevel;
  sideEffects: string[];
  interactions: string[];
  contraindications: string[];

  // Applicability
  targetBenefits: string[];
  requiresPrescription: boolean;

  notes?: string[];
  sources?: string[];
}

// ============================================
// SEVERITY & SCORING
// ============================================

export interface SeverityThreshold {
  metric: string;
  optimal: { min: number; max: number };
  mild: { min: number; max: number };
  moderate: { min: number; max: number };
  severe: { min: number; max: number };
  unit: string;
  higherIsBetter?: boolean;
}

export interface SeverityResult {
  severity: Severity;
  label: string;
  color: string;
  icon: string;
  description: string;
}

// ============================================
// RECOMMENDATION ENGINE TYPES
// ============================================

export interface MetricAnalysis {
  metricId: string;
  metricName: string;
  currentValue: number;
  idealValue: number;
  idealRange: { min: number; max: number };
  deviation: number;
  deviationPercent: number;
  score: number;
  severity: SeverityResult;
  issue?: string;
  profileType: ProfileType;
}

export interface TreatmentRecommendation {
  treatment: Treatment | Surgery | Supplement;
  priority: 'high' | 'medium' | 'low';
  relevanceScore: number; // 0-100
  targetMetrics: string[];
  estimatedImprovement: number;
  reasoning: string;
}

export interface RecommendationPlan {
  // Summary
  overallScore: number;
  overallSeverity: SeverityResult;
  harmonyScore: number;
  percentile: number;

  // Analysis
  metricAnalyses: MetricAnalysis[];
  strengths: MetricAnalysis[];
  weaknesses: MetricAnalysis[];

  // Recommendations by category
  lifestyle: TreatmentRecommendation[];
  softmaxxing: TreatmentRecommendation[];
  nonSurgical: TreatmentRecommendation[];
  minimallyInvasive: TreatmentRecommendation[];
  surgical: TreatmentRecommendation[];
  supplements: TreatmentRecommendation[];

  // Potential
  currentPSL: number;
  potentialPSL: number;
  potentialImprovement: number;

  // Order of operations
  orderOfOperations: OrderOfOperation[];
}

export interface OrderOfOperation {
  step: number;
  category: TreatmentCategory;
  treatment: Treatment | Surgery;
  reasoning: string;
  prerequisites?: string[];
  waitTime?: string;
}

// ============================================
// METRIC TO ISSUE MAPPING
// ============================================

export interface MetricIssueMapping {
  metric: string;
  lowIssue: string;
  highIssue: string;
  lowTreatments: string[];
  highTreatments: string[];
}

// ============================================
// PSL RATING SYSTEM
// ============================================

export interface PSLRating {
  score: number;
  tier: string;
  percentile: number;
  description: string;
}

export const PSL_TIERS: PSLRating[] = [
  { score: 7.5, tier: 'Top Model', percentile: 99.99, description: 'Near perfection - world-class genetics' },
  { score: 7.0, tier: 'Chad', percentile: 99.87, description: 'Exceptional - top 0.1%' },
  { score: 6.5, tier: 'Chadlite', percentile: 99.0, description: 'Very attractive - top 1%' },
  { score: 6.0, tier: 'High Tier Normie+', percentile: 97.25, description: 'Notably attractive - top 3%' },
  { score: 5.5, tier: 'High Tier Normie', percentile: 90.0, description: 'Above average - top 10%' },
  { score: 5.0, tier: 'Mid Tier Normie+', percentile: 84.15, description: 'Slightly above average' },
  { score: 4.5, tier: 'Mid Tier Normie', percentile: 65.0, description: 'Average' },
  { score: 4.0, tier: 'Low Tier Normie', percentile: 50.0, description: 'Median' },
  { score: 3.5, tier: 'Below Average', percentile: 30.0, description: 'Below average' },
  { score: 3.0, tier: 'Subpar', percentile: 15.0, description: 'Noticeably below average' },
];
