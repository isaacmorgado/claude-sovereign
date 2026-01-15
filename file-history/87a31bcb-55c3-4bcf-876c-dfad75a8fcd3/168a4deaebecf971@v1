/**
 * Harmony-Style Results Page Types
 * Complete type definitions for the results UI
 */

import { QualityTier, SeverityLevel, MeasurementUnit, ConfidenceLevel } from '@/lib/harmony-scoring';

// ============================================
// ILLUSTRATION TYPES
// ============================================

export interface IllustrationPoint {
  type: 'landmark' | 'calculated';
  landmarkId?: string;
  x?: number;
  y?: number;
  label?: string;
}

export interface IllustrationLine {
  from: string;
  to: string;
  color: string;
  style?: 'solid' | 'dashed';
  label?: string;
  labelColor?: string;
  labelPosition?: 'start' | 'middle' | 'end';
}

export interface RatioIllustration {
  points: Record<string, IllustrationPoint>;
  lines: Record<string, IllustrationLine>;
}

// ============================================
// RATIO/MEASUREMENT TYPES
// ============================================

export interface Ratio {
  id: string;
  name: string;
  value: number | string;
  score: number | string;  // 0-10 scale or Greek text
  standardizedScore: number | string;
  unit: 'x' | 'mm' | '%' | '°';
  idealMin: number;
  idealMax: number;
  rangeMin: number;
  rangeMax: number;
  description: string;
  category: string;
  qualityLevel: QualityTier;
  severity: SeverityLevel;
  illustration: RatioIllustration;
  mayIndicateFlaws: string[];
  mayIndicateStrengths: string[];
  usedLandmarks: string[];
  scoringCurveConfig?: {
    decayRate: number;
    maxScore: number;
  };
  // Harmony Taxonomy classification
  taxonomyPrimary?: string;    // 'harmony' | 'dimorphism' | 'angularity' | 'features'
  taxonomySecondary?: string;  // Subcategory ID
}

// ============================================
// STRENGTH/FLAW TYPES
// ============================================

export interface ResponsibleRatio {
  ratioName: string;
  ratioId: string;
  score: number | string;
  value: number | string;
  isObfuscated?: boolean;
  // Additional properties for AI descriptions
  idealMin: number;
  idealMax: number;
  unit: string;
  category?: string;
}

export interface Strength {
  id: string;
  strengthName: string;
  summary: string;
  avgScore: number | string;
  qualityLevel: QualityTier;
  categoryName: string;
  responsibleRatios: ResponsibleRatio[];
}

export interface Flaw {
  id: string;
  flawName: string;
  summary: string;
  harmonyPercentageLost: number;
  standardizedImpact: number;
  categoryName: string;
  isOther?: boolean;
  responsibleRatios: ResponsibleRatio[];
  rollingPointsDeducted?: number;
  rollingHarmonyPercentageLost?: number;
  rollingStandardizedImpact?: number;
  /**
   * Confidence level based on Z-score magnitude:
   * - confirmed: |z| >= 2 (statistically significant)
   * - likely: 1 <= |z| < 2
   * - possible: 0.5 <= |z| < 1
   */
  confidence?: ConfidenceLevel;
}

// ============================================
// RECOMMENDATION TYPES
// ============================================

export type RecommendationPhase = 'Surgical' | 'Minimally Invasive' | 'Foundational';

export interface RecommendationTimeline {
  effect_start: 'immediate' | 'delayed' | 'gradual';
  full_results_weeks: number;
  full_results_weeks_max?: number;
}

export interface RecommendationCost {
  type: 'flat' | 'per_month' | 'per_session';
  min: number;
  max: number;
  currency: string;
}

export interface RatioImpact {
  ratioId: string;
  ratioName: string;
  direction: 'increase' | 'decrease' | 'both';
  percentageEffect: number;
}

export interface Recommendation {
  ref_id: string;
  name: string;
  description: string;
  phase: RecommendationPhase;
  impact: number;  // 0-1 effectiveness score
  coverage: number;  // Number of metrics improved
  percentage: string;  // e.g., "10-20%"
  expectedImprovementRange?: { min: number; max: number };
  matchedFlaws: string[];
  matchedRatios: string[];
  ratios_impacted: RatioImpact[];
  timeline: RecommendationTimeline;
  cost: RecommendationCost;
  risks_side_effects: string | null;
  warnings: string[];
  gender: 'male' | 'female' | 'both';
}

// ============================================
// HARMONY ANALYSIS TYPES
// ============================================

export interface ProfileAnalysis {
  standardizedScore: number;
  ratios: Ratio[];
  overallAIDescription?: string | null;
}

export interface FullHarmonyAnalysis {
  standardizedScore: number;
  front: ProfileAnalysis;
  side: ProfileAnalysis;
  strengths: Strength[];
  flaws: Flaw[];
}

// ============================================
// FACE DATA TYPES
// ============================================

export interface FaceData {
  id: string;
  userId?: string;
  frontPhotoUrl: string;
  sidePhotoUrl?: string;
  harmonyScore: number | null;
  frontHarmonyScore: number | null;
  sideHarmonyScore: number | null;
  gender: 'male' | 'female';
  race?: string;
  unlocked: boolean;
  actionPlanUnlocked: boolean;
  harmonyAnalysis: FullHarmonyAnalysis;
}

// ============================================
// UI STATE TYPES
// ============================================

export type ResultsTab =
  | 'overview'
  | 'front-ratios'
  | 'side-ratios'
  | 'leaderboard'
  | 'psl'
  | 'archetype'
  | 'plan'
  | 'guides'
  | 'shop'
  | 'community'
  | 'referrals'
  | 'options'
  | 'support';

// ============================================
// LEADERBOARD TYPES
// ============================================

export interface UserRank {
  userId: string;
  score: number;
  globalRank: number;
  genderRank: number;
  percentile: number;
  totalUsers: number;
  genderTotal: number;
  anonymousName: string;
  updatedAt: string;
}

export interface LeaderboardEntry {
  userId: string;
  rank: number;
  score: number;
  anonymousName: string;
  gender: 'male' | 'female';
  facePhotoUrl: string | null;
  isCurrentUser: boolean;
  topStrengths: string[];
  topImprovements: string[];
}

export interface UserProfile extends Omit<LeaderboardEntry, 'isCurrentUser'> {
  topStrengths: string[];
  topImprovements: string[];
}

export interface LeaderboardData {
  entries: LeaderboardEntry[];
  totalCount: number;
  userRank: UserRank | null;
}

export interface ResultsUIState {
  activeTab: ResultsTab;
  expandedMeasurementId: string | null;
  selectedVisualizationMetric: string | null;
  categoryFilter: string | null;
  showLandmarkOverlay: boolean;
}

// ============================================
// CATEGORY TYPES
// ============================================

export interface MeasurementCategory {
  id: string;
  name: string;
  color: string;
  description: string;
}

export const MEASUREMENT_CATEGORIES: MeasurementCategory[] = [
  { id: 'midface', name: 'Midface/Face Shape', color: '#67e8f9', description: 'Facial proportions and overall shape' },
  { id: 'jaw-growth', name: 'Occlusion/Jaw Growth', color: '#a78bfa', description: 'Jaw development and bite alignment' },
  { id: 'jaw-shape', name: 'Jaw Shape', color: '#f97316', description: 'Jawline contour and angles' },
  { id: 'upper-third', name: 'Upper Third', color: '#84cc16', description: 'Forehead and hairline proportions' },
  { id: 'eyes', name: 'Eyes', color: '#06b6d4', description: 'Eye shape, spacing, and canthal tilt' },
  { id: 'nose', name: 'Nose', color: '#fbbf24', description: 'Nasal proportions and angles' },
  { id: 'lips', name: 'Lips', color: '#ec4899', description: 'Lip proportions and projection' },
  { id: 'chin', name: 'Chin', color: '#ef4444', description: 'Chin projection and shape' },
  { id: 'neck', name: 'Neck', color: '#14b8a6', description: 'Neck angle and throat definition' },
  { id: 'other', name: 'Other', color: '#6b7280', description: 'Additional measurements' },
];

// ============================================
// SCORE COLOR HELPERS
// ============================================

export function getScoreColor(score: number): string {
  if (score >= 8) return '#67e8f9';  // Cyan - ideal
  if (score >= 6) return '#22c55e';  // Green - good
  if (score >= 4) return '#fbbf24';  // Yellow - fair
  return 'rgb(227, 67, 67)';         // Red - poor
}

export function getQualityColor(quality: QualityTier): string {
  switch (quality) {
    case 'ideal': return '#67e8f9';
    case 'excellent': return '#22c55e';
    case 'good': return '#fbbf24';
    case 'below_average': return 'rgb(227, 67, 67)';
    default: return '#6b7280';
  }
}

export function getSeverityColor(severity: SeverityLevel): string {
  switch (severity) {
    case 'optimal': return '#67e8f9';
    case 'minor': return '#22c55e';
    case 'moderate': return '#fbbf24';
    case 'major': return '#f97316';
    case 'severe': return '#ef4444';
    case 'extremely_severe': return '#dc2626';
    default: return '#6b7280';
  }
}

export function getCategoryColor(categoryName: string): string {
  const cat = MEASUREMENT_CATEGORIES.find(c =>
    c.name.toLowerCase().includes(categoryName.toLowerCase()) ||
    categoryName.toLowerCase().includes(c.name.toLowerCase())
  );
  return cat?.color || '#6b7280';
}

// ============================================
// UNIT FORMATTING
// ============================================

export function formatUnit(unit: 'x' | 'mm' | '%' | '°' | MeasurementUnit): string {
  switch (unit) {
    case 'x':
    case 'ratio': return 'x';
    case 'mm': return 'mm';
    case '%':
    case 'percent': return '%';
    case '°':
    case 'degrees': return '°';
    default: return '';
  }
}

export function formatValue(value: number | string, unit: 'x' | 'mm' | '%' | '°' | MeasurementUnit): string {
  // Handle obfuscated string values
  if (typeof value === 'string') {
    return value;
  }
  const unitStr = formatUnit(unit);
  if (unit === '%' || unit === 'percent') {
    return `${value.toFixed(1)}${unitStr}`;
  }
  if (unit === '°' || unit === 'degrees') {
    return `${value.toFixed(1)}${unitStr}`;
  }
  return `${value.toFixed(2)}${unitStr}`;
}

// ============================================
// PRODUCT & SUPPLEMENT TYPES
// ============================================

export interface Product {
  id: string;
  name: string;
  brand: string;
  category: "skin" | "hair" | "anti-aging" | "hormonal" | "bone" | "general" | "jawline" | "tools" | "dental";
  affiliateLink: string;
  affiliateType: "amazon" | "direct";
  supplementId: string;
  priority: number;
  baseStackItem?: boolean;
  description?: string;
}

export interface ProductRecommendation {
  product: Product;
  state: "flaw" | "ideal";
  targetMetric: string;
  message: string;
  urgency: "high" | "medium" | "low";
  matchedMetrics: string[];
}

export interface DailyStack {
  products: Product[];
  totalCostPerMonth: { min: number; max: number };
  timing: {
    morning: Product[];
    evening: Product[];
    anytime: Product[];
  };
  rationale: string;
}
