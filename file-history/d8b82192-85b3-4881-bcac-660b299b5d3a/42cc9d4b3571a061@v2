/**
 * Archetype Classifier
 *
 * Classifies facial features into archetype categories based on
 * facial metrics from harmony-scoring.ts
 */

import archetypeData from '@/data/archetypes.json';
import { Ratio } from '@/types/results';
import { Ethnicity, Gender } from '@/lib/harmony-scoring';

// ============================================
// TYPES
// ============================================

export type DimorphismLevel =
  | 'low'
  | 'low-balanced'
  | 'balanced'
  | 'above-average'
  | 'high'
  | 'very-high';

export type ArchetypeCategory =
  | 'Softboy'
  | 'Prettyboy'
  | 'RobustPrettyboy'
  | 'Chad'
  | 'Hypermasculine'
  | 'Exotic';

export interface SubArchetypeStyle {
  clothing: string[];
  hair: string[];
  colors: string[];
}

export interface SubArchetype {
  id: string;
  name: string;
  traits: string[];
  style: SubArchetypeStyle;
  examples: string[];
  ethnicityBonus?: string[];
  requiresHollowCheeks?: boolean;
  requiresMuscularBuild?: boolean;
}

export interface ArchetypeDefinition {
  id: string;
  name: string;
  description: string;
  traits: string[];
  idealMetrics: {
    gonialAngle: { min: number; max: number };
    fwhr: { min: number; max: number };
    lateralCanthalTilt: { min: number; max: number };
  };
  subArchetypes: SubArchetype[];
}

export interface ArchetypeScoreResult {
  category: ArchetypeCategory;
  score: number;
  confidence: number;
  matchedTraits: string[];
}

export interface ArchetypeClassification {
  primary: {
    category: ArchetypeCategory;
    subArchetype: string;
    confidence: number;
    traits: string[];
  };
  secondary: {
    category: ArchetypeCategory;
    subArchetype: string;
    confidence: number;
    traits: string[];
  } | null;
  allScores: ArchetypeScoreResult[];
  dimorphismLevel: DimorphismLevel;
  styleGuide: SubArchetypeStyle;
  transitionPath: {
    target: string;
    requirements: string[];
  } | null;
}

export interface ClassificationInput {
  // From front ratios
  gonialAngle?: number;
  fwhr?: number;                    // Face Width-Height Ratio
  lateralCanthalTilt?: number;      // Eye tilt
  cheekboneHeight?: number;
  browRidgeProminence?: number;
  jawWidthRatio?: number;
  midfaceRatio?: number;

  // From side ratios
  nasofrontalAngle?: number;
  gonialAngleSide?: number;
  facialConvexity?: number;
  chinProjection?: number;

  // User input
  gender: Gender;
  ethnicity: Ethnicity;

  // Optional physique data
  hollowCheeks?: number;           // 0-10 score
  bodyType?: 'ectomorphic' | 'ecto-mesomorphic' | 'mesomorphic' | 'endo-mesomorphic' | 'meso-endomorphic';
  frameSize?: 'small' | 'medium' | 'large' | 'very-large';
}

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Extract metric value from ratios array by metric ID
 */
function getMetricValue(ratios: Ratio[], metricId: string): number | undefined {
  const metric = ratios.find((r) => r.id === metricId || r.id.toLowerCase() === metricId.toLowerCase());
  return metric?.value;
}

/**
 * Convert front/side ratios to classification input
 */
export function ratiosToClassificationInput(
  frontRatios: Ratio[],
  sideRatios: Ratio[],
  gender: Gender,
  ethnicity: Ethnicity
): ClassificationInput {
  return {
    // Front metrics
    gonialAngle: getMetricValue(frontRatios, 'jawFrontalAngle') ||
                 getMetricValue(sideRatios, 'gonialAngle'),
    fwhr: getMetricValue(frontRatios, 'faceWidthToHeight') ||
          getMetricValue(frontRatios, 'totalFacialWidthToHeight'),
    lateralCanthalTilt: getMetricValue(frontRatios, 'lateralCanthalTilt'),
    cheekboneHeight: getMetricValue(frontRatios, 'cheekboneHeight'),
    browRidgeProminence: getMetricValue(frontRatios, 'eyebrowLowSetedness'),
    jawWidthRatio: getMetricValue(frontRatios, 'jawWidthRatio') ||
                   getMetricValue(frontRatios, 'bigonialWidth'),
    midfaceRatio: getMetricValue(frontRatios, 'midfaceRatio'),

    // Side metrics
    nasofrontalAngle: getMetricValue(sideRatios, 'nasofrontalAngle'),
    gonialAngleSide: getMetricValue(sideRatios, 'gonialAngle'),
    facialConvexity: getMetricValue(sideRatios, 'facialConvexityGlabella') ||
                     getMetricValue(sideRatios, 'facialConvexityNasion'),
    chinProjection: getMetricValue(sideRatios, 'chinProjection'),

    // User data
    gender,
    ethnicity,
  };
}

/**
 * Determine dimorphism level based on gonial angle
 */
function getDimorphismLevel(gonialAngle: number | undefined): DimorphismLevel {
  if (!gonialAngle) return 'balanced';

  if (gonialAngle >= 130) return 'low';
  if (gonialAngle >= 125) return 'low-balanced';
  if (gonialAngle >= 118) return 'balanced';
  if (gonialAngle >= 115) return 'above-average';
  if (gonialAngle >= 110) return 'high';
  return 'very-high';
}

/**
 * Calculate how close a value is to ideal range (0-1)
 */
function calculateRangeScore(
  value: number | undefined,
  range: { min: number; max: number }
): number {
  if (value === undefined) return 0.5; // Neutral if unknown

  const idealMid = (range.min + range.max) / 2;
  const idealWidth = range.max - range.min;

  if (value >= range.min && value <= range.max) {
    // Inside range: score based on distance from center
    const distFromCenter = Math.abs(value - idealMid);
    return 1 - (distFromCenter / idealWidth) * 0.2; // 0.8-1.0 within range
  }

  // Outside range: penalize based on distance
  const distFromRange = value < range.min
    ? range.min - value
    : value - range.max;

  return Math.max(0, 0.8 - (distFromRange / idealWidth) * 0.5);
}

// ============================================
// SCORING FUNCTIONS
// ============================================

/**
 * Score Softboy archetype
 */
function scoreSoftboy(input: ClassificationInput): ArchetypeScoreResult {
  let score = 0;
  const matchedTraits: string[] = [];
  const archetype = archetypeData.archetypes.Softboy;

  // Gonial angle (prefer higher = softer jaw)
  if (input.gonialAngle !== undefined) {
    if (input.gonialAngle >= 130) {
      score += 25;
      matchedTraits.push('Soft jawline');
    } else if (input.gonialAngle >= 125) {
      score += 15;
    }
  }

  // FWHR (prefer higher = more youthful proportions)
  const fwhrScore = calculateRangeScore(input.fwhr, archetype.idealMetrics.fwhr);
  score += fwhrScore * 20;
  if (fwhrScore > 0.8) matchedTraits.push('Youthful proportions');

  // Canthal tilt (moderate positive)
  const tiltScore = calculateRangeScore(input.lateralCanthalTilt, archetype.idealMetrics.lateralCanthalTilt);
  score += tiltScore * 15;
  if (tiltScore > 0.8) matchedTraits.push('Harmonious eye shape');

  // Low brow ridge preference
  if (input.browRidgeProminence !== undefined) {
    if (input.browRidgeProminence < 5) {
      score += 15;
      matchedTraits.push('Delicate brow');
    }
  }

  // Ethnicity bonus for K-pop sub-archetype
  if (input.ethnicity === 'east_asian' || input.ethnicity === 'south_asian') {
    score += 10;
    matchedTraits.push('K-pop aesthetic potential');
  }

  // Dimorphism level check
  const dimorphism = getDimorphismLevel(input.gonialAngle);
  if (dimorphism === 'low' || dimorphism === 'low-balanced') {
    score += 10;
    matchedTraits.push('Low dimorphism');
  }

  return {
    category: 'Softboy',
    score: Math.min(100, score),
    confidence: score / 100,
    matchedTraits,
  };
}

/**
 * Score Prettyboy archetype
 */
function scorePrettyboy(input: ClassificationInput): ArchetypeScoreResult {
  let score = 0;
  const matchedTraits: string[] = [];
  const archetype = archetypeData.archetypes.Prettyboy;

  // Balanced gonial angle
  const gonialScore = calculateRangeScore(input.gonialAngle, archetype.idealMetrics.gonialAngle);
  score += gonialScore * 25;
  if (gonialScore > 0.8) matchedTraits.push('Balanced jaw');

  // Ideal FWHR
  const fwhrScore = calculateRangeScore(input.fwhr, archetype.idealMetrics.fwhr);
  score += fwhrScore * 25;
  if (fwhrScore > 0.8) matchedTraits.push('Harmonious proportions');

  // Positive canthal tilt
  const tiltScore = calculateRangeScore(input.lateralCanthalTilt, archetype.idealMetrics.lateralCanthalTilt);
  score += tiltScore * 20;
  if (tiltScore > 0.8) matchedTraits.push('Attractive eye shape');

  // Good midface ratio
  if (input.midfaceRatio !== undefined) {
    if (input.midfaceRatio >= 0.95 && input.midfaceRatio <= 1.05) {
      score += 15;
      matchedTraits.push('Balanced midface');
    }
  }

  // Balanced dimorphism
  const dimorphism = getDimorphismLevel(input.gonialAngle);
  if (dimorphism === 'balanced' || dimorphism === 'low-balanced') {
    score += 10;
    matchedTraits.push('Balanced dimorphism');
  }

  return {
    category: 'Prettyboy',
    score: Math.min(100, score),
    confidence: score / 100,
    matchedTraits,
  };
}

/**
 * Score Robust Prettyboy archetype
 */
function scoreRobustPrettyboy(input: ClassificationInput): ArchetypeScoreResult {
  let score = 0;
  const matchedTraits: string[] = [];
  const archetype = archetypeData.archetypes.RobustPrettyboy;

  // Slightly masculine gonial angle
  const gonialScore = calculateRangeScore(input.gonialAngle, archetype.idealMetrics.gonialAngle);
  score += gonialScore * 25;
  if (gonialScore > 0.8) matchedTraits.push('Defined jaw');

  // Good FWHR
  const fwhrScore = calculateRangeScore(input.fwhr, archetype.idealMetrics.fwhr);
  score += fwhrScore * 20;
  if (fwhrScore > 0.8) matchedTraits.push('Strong proportions');

  // Strong positive canthal tilt
  const tiltScore = calculateRangeScore(input.lateralCanthalTilt, archetype.idealMetrics.lateralCanthalTilt);
  score += tiltScore * 20;
  if (tiltScore > 0.8) matchedTraits.push('Hunter eyes');

  // High cheekbones
  if (input.cheekboneHeight !== undefined && input.cheekboneHeight >= 7) {
    score += 15;
    matchedTraits.push('High cheekbones');
  }

  // Moderate brow ridge
  if (input.browRidgeProminence !== undefined) {
    if (input.browRidgeProminence >= 5 && input.browRidgeProminence <= 7) {
      score += 10;
      matchedTraits.push('Defined brow');
    }
  }

  // Above-average dimorphism
  const dimorphism = getDimorphismLevel(input.gonialAngle);
  if (dimorphism === 'above-average' || dimorphism === 'balanced') {
    score += 10;
    matchedTraits.push('Above-average dimorphism');
  }

  return {
    category: 'RobustPrettyboy',
    score: Math.min(100, score),
    confidence: score / 100,
    matchedTraits,
  };
}

/**
 * Score Chad archetype
 */
function scoreChad(input: ClassificationInput): ArchetypeScoreResult {
  let score = 0;
  const matchedTraits: string[] = [];
  const archetype = archetypeData.archetypes.Chad;

  // Strong gonial angle
  const gonialScore = calculateRangeScore(input.gonialAngle, archetype.idealMetrics.gonialAngle);
  score += gonialScore * 25;
  if (gonialScore > 0.8) matchedTraits.push('Strong jawline');

  // Good FWHR
  const fwhrScore = calculateRangeScore(input.fwhr, archetype.idealMetrics.fwhr);
  score += fwhrScore * 20;
  if (fwhrScore > 0.8) matchedTraits.push('Masculine proportions');

  // Positive canthal tilt
  const tiltScore = calculateRangeScore(input.lateralCanthalTilt, archetype.idealMetrics.lateralCanthalTilt);
  score += tiltScore * 15;
  if (tiltScore > 0.8) matchedTraits.push('Attractive eyes');

  // High jaw width ratio
  if (input.jawWidthRatio !== undefined && input.jawWidthRatio >= 0.85) {
    score += 15;
    matchedTraits.push('Wide jaw');
  }

  // Good brow ridge
  if (input.browRidgeProminence !== undefined && input.browRidgeProminence >= 6) {
    score += 10;
    matchedTraits.push('Prominent brow');
  }

  // High dimorphism
  const dimorphism = getDimorphismLevel(input.gonialAngle);
  if (dimorphism === 'high' || dimorphism === 'above-average') {
    score += 15;
    matchedTraits.push('High dimorphism');
  }

  // Hollow cheeks bonus (for Vampire sub-archetype)
  if (input.hollowCheeks !== undefined && input.hollowCheeks >= 7) {
    score += 5;
    matchedTraits.push('Hollow cheeks');
  }

  return {
    category: 'Chad',
    score: Math.min(100, score),
    confidence: score / 100,
    matchedTraits,
  };
}

/**
 * Score Hypermasculine (Warrior) archetype
 */
function scoreHypermasculine(input: ClassificationInput): ArchetypeScoreResult {
  let score = 0;
  const matchedTraits: string[] = [];
  const archetype = archetypeData.archetypes.Hypermasculine;

  // Very strong gonial angle
  const gonialScore = calculateRangeScore(input.gonialAngle, archetype.idealMetrics.gonialAngle);
  score += gonialScore * 30;
  if (gonialScore > 0.8) matchedTraits.push('Extreme jaw definition');

  // High FWHR
  const fwhrScore = calculateRangeScore(input.fwhr, archetype.idealMetrics.fwhr);
  score += fwhrScore * 20;
  if (fwhrScore > 0.8) matchedTraits.push('Hypermasculine proportions');

  // Lower canthal tilt acceptable
  const tiltScore = calculateRangeScore(input.lateralCanthalTilt, archetype.idealMetrics.lateralCanthalTilt);
  score += tiltScore * 10;

  // Heavy brow ridge
  if (input.browRidgeProminence !== undefined && input.browRidgeProminence >= 7) {
    score += 20;
    matchedTraits.push('Heavy brow ridge');
  }

  // Large frame preference
  if (input.frameSize === 'large' || input.frameSize === 'very-large') {
    score += 10;
    matchedTraits.push('Large frame');
  }

  // Very high dimorphism
  const dimorphism = getDimorphismLevel(input.gonialAngle);
  if (dimorphism === 'very-high' || dimorphism === 'high') {
    score += 15;
    matchedTraits.push('Very high dimorphism');
  }

  return {
    category: 'Hypermasculine',
    score: Math.min(100, score),
    confidence: score / 100,
    matchedTraits,
  };
}

/**
 * Score Exotic archetype
 */
function scoreExotic(input: ClassificationInput): ArchetypeScoreResult {
  let score = 0;
  const matchedTraits: string[] = [];
  const archetype = archetypeData.archetypes.Exotic;

  // Wide range acceptable for gonial angle
  const gonialScore = calculateRangeScore(input.gonialAngle, archetype.idealMetrics.gonialAngle);
  score += gonialScore * 20;

  // Wide range for FWHR
  const fwhrScore = calculateRangeScore(input.fwhr, archetype.idealMetrics.fwhr);
  score += fwhrScore * 20;

  // Unique features get bonus
  if (input.lateralCanthalTilt !== undefined) {
    // Both high and low tilts can be exotic
    if (input.lateralCanthalTilt >= 10 || input.lateralCanthalTilt <= 2) {
      score += 15;
      matchedTraits.push('Distinctive eye shape');
    }
  }

  // Ethnicity bonuses for Viking sub-archetype
  if (input.ethnicity === 'white') {
    score += 10;
    matchedTraits.push('Norse features');
  }

  // Large frame for bodybuilder/viking
  if (input.frameSize === 'large' || input.frameSize === 'very-large') {
    score += 15;
    matchedTraits.push('Imposing frame');
  }

  // Muscular build bonus
  if (input.bodyType === 'mesomorphic' || input.bodyType === 'endo-mesomorphic') {
    score += 10;
    matchedTraits.push('Muscular build');
  }

  return {
    category: 'Exotic',
    score: Math.min(100, score),
    confidence: score / 100,
    matchedTraits,
  };
}

// ============================================
// SUB-ARCHETYPE CLASSIFICATION
// ============================================

/**
 * Determine the best sub-archetype within a category
 */
function classifySubArchetype(
  category: ArchetypeCategory,
  input: ClassificationInput
): SubArchetype {
  const archetypes = archetypeData.archetypes as Record<string, ArchetypeDefinition>;
  const categoryDef = archetypes[category];

  if (!categoryDef || !categoryDef.subArchetypes.length) {
    // Fallback to first sub-archetype
    return categoryDef?.subArchetypes[0] || {
      id: 'default',
      name: category,
      traits: [],
      style: { clothing: [], hair: [], colors: [] },
      examples: [],
    };
  }

  let bestMatch = categoryDef.subArchetypes[0];
  let bestScore = 0;

  for (const sub of categoryDef.subArchetypes) {
    let score = 0;

    // Ethnicity bonus
    if (sub.ethnicityBonus?.includes(input.ethnicity)) {
      score += 20;
    }

    // Hollow cheeks requirement
    if (sub.requiresHollowCheeks) {
      if (input.hollowCheeks !== undefined && input.hollowCheeks >= 7) {
        score += 30;
      } else {
        score -= 20; // Penalty if not met
      }
    }

    // Muscular build requirement
    if (sub.requiresMuscularBuild) {
      if (input.bodyType === 'mesomorphic' || input.bodyType === 'endo-mesomorphic') {
        score += 30;
      } else {
        score -= 20; // Penalty if not met
      }
    }

    // Base score for being in the category
    score += 50;

    if (score > bestScore) {
      bestScore = score;
      bestMatch = sub;
    }
  }

  return bestMatch;
}

/**
 * Generate transition path to adjacent archetype
 */
function getTransitionPath(
  primary: ArchetypeCategory,
  allScores: ArchetypeScoreResult[]
): { target: string; requirements: string[] } | null {
  // Define natural transition paths
  const transitions: Record<ArchetypeCategory, { target: ArchetypeCategory; requirements: string[] }> = {
    Softboy: {
      target: 'Prettyboy',
      requirements: ['Build more jaw definition', 'Slightly increase muscularity'],
    },
    Prettyboy: {
      target: 'RobustPrettyboy',
      requirements: ['Increase muscularity', 'Develop more intensity'],
    },
    RobustPrettyboy: {
      target: 'Chad',
      requirements: ['Build more muscle mass', 'Maximize jaw definition'],
    },
    Chad: {
      target: 'Hypermasculine',
      requirements: ['Significant muscle gain', 'Frame maximization'],
    },
    Hypermasculine: {
      target: 'Exotic',
      requirements: ['Unique styling', 'Distinctive grooming'],
    },
    Exotic: {
      target: 'Chad',
      requirements: ['Lean out', 'Refine features'],
    },
  };

  const transition = transitions[primary];
  if (!transition) return null;

  // Check if target is achievable (score should be reasonably close)
  const targetScore = allScores.find((s) => s.category === transition.target);
  if (targetScore && targetScore.score >= 40) {
    return transition;
  }

  return null;
}

// ============================================
// MAIN CLASSIFIER
// ============================================

/**
 * Main archetype classification function
 */
export function classifyArchetype(input: ClassificationInput): ArchetypeClassification {
  // Score all categories
  const scores: ArchetypeScoreResult[] = [
    scoreSoftboy(input),
    scorePrettyboy(input),
    scoreRobustPrettyboy(input),
    scoreChad(input),
    scoreHypermasculine(input),
    scoreExotic(input),
  ];

  // Sort by score
  const sorted = [...scores].sort((a, b) => b.score - a.score);

  const primaryResult = sorted[0];
  const secondaryResult = sorted[1];

  // Get sub-archetypes
  const primarySub = classifySubArchetype(primaryResult.category, input);
  const secondarySub = secondaryResult.score >= 30
    ? classifySubArchetype(secondaryResult.category, input)
    : null;

  // Get dimorphism level
  const dimorphismLevel = getDimorphismLevel(input.gonialAngle);

  // Get transition path
  const transitionPath = getTransitionPath(primaryResult.category, scores);

  return {
    primary: {
      category: primaryResult.category,
      subArchetype: primarySub.name,
      confidence: primaryResult.confidence,
      traits: [...primaryResult.matchedTraits, ...primarySub.traits.slice(0, 2)],
    },
    secondary: secondarySub
      ? {
          category: secondaryResult.category,
          subArchetype: secondarySub.name,
          confidence: secondaryResult.confidence,
          traits: secondaryResult.matchedTraits,
        }
      : null,
    allScores: scores,
    dimorphismLevel,
    styleGuide: primarySub.style,
    transitionPath,
  };
}

/**
 * Convenience function to classify from ratios
 */
export function classifyFromRatios(
  frontRatios: Ratio[],
  sideRatios: Ratio[],
  gender: Gender,
  ethnicity: Ethnicity
): ArchetypeClassification {
  const input = ratiosToClassificationInput(frontRatios, sideRatios, gender, ethnicity);
  return classifyArchetype(input);
}

/**
 * Get archetype definition by ID
 */
export function getArchetypeDefinition(categoryId: string): ArchetypeDefinition | undefined {
  const archetypes = archetypeData.archetypes as Record<string, ArchetypeDefinition>;
  return archetypes[categoryId];
}

/**
 * Get all archetype categories
 */
export function getAllArchetypeCategories(): ArchetypeCategory[] {
  return Object.keys(archetypeData.archetypes) as ArchetypeCategory[];
}
