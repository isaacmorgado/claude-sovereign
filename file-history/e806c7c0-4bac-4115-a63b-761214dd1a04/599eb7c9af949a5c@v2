/**
 * Facial Analysis Scoring Functions
 * Uses correct landmark IDs from landmarks.ts
 * Includes FaceIQ-style bell curve scoring and percentile ranking
 */

import {
  LandmarkPoint,
  ScoringConfig,
  FACEIQ_SCORING_CONFIGS,
  FACEIQ_IDEAL_VALUES,
  PopulationStats,
  POPULATION_STATS,
} from './landmarks';

// ============================================
// UTILITY TYPES & FUNCTIONS
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

/**
 * Calculate distance between two points
 */
export function distance(p1: Point, p2: Point): number {
  return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
}

/**
 * Calculate angle at vertex point (in degrees)
 * Angle is formed by points: p1 -> vertex -> p2
 */
export function calculateAngle(p1: Point, vertex: Point, p2: Point): number {
  const v1 = { x: p1.x - vertex.x, y: p1.y - vertex.y };
  const v2 = { x: p2.x - vertex.x, y: p2.y - vertex.y };

  const dot = v1.x * v2.x + v1.y * v2.y;
  const cross = v1.x * v2.y - v1.y * v2.x;

  const angle = Math.atan2(cross, dot) * (180 / Math.PI);
  return Math.abs(angle);
}

/**
 * Calculate perpendicular distance from point to line
 * Positive = in front of line, Negative = behind line
 */
export function perpendicularDistance(
  point: Point,
  lineStart: Point,
  lineEnd: Point
): number {
  const A = point.x - lineStart.x;
  const B = point.y - lineStart.y;
  const C = lineEnd.x - lineStart.x;
  const D = lineEnd.y - lineStart.y;

  const dot = A * C + B * D;
  const lenSq = C * C + D * D;
  const param = lenSq !== 0 ? dot / lenSq : -1;

  let xx: number, yy: number;

  if (param < 0) {
    xx = lineStart.x;
    yy = lineStart.y;
  } else if (param > 1) {
    xx = lineEnd.x;
    yy = lineEnd.y;
  } else {
    xx = lineStart.x + param * C;
    yy = lineStart.y + param * D;
  }

  const dx = point.x - xx;
  const dy = point.y - yy;

  // Determine sign (positive = in front of line, negative = behind)
  const sign =
    (lineEnd.y - lineStart.y) * point.x -
      (lineEnd.x - lineStart.x) * point.y +
      lineEnd.x * lineStart.y -
      lineEnd.y * lineStart.x >=
    0
      ? 1
      : -1;

  return sign * Math.sqrt(dx * dx + dy * dy);
}

/**
 * Get rating from score
 */
function getRating(score: number): ScoreResult['rating'] {
  if (score >= 90) return 'excellent';
  if (score >= 75) return 'good';
  if (score >= 50) return 'average';
  return 'below_average';
}

/**
 * Helper to get landmark by ID from array
 */
function getLandmark(landmarks: LandmarkPoint[], id: string): Point | null {
  const lm = landmarks.find((l) => l.id === id);
  return lm ? { x: lm.x, y: lm.y } : null;
}

// ============================================
// SIDE PROFILE SCORING (uses _side suffix landmarks)
// ============================================

/**
 * Gonial Angle - Jaw angle measurement
 * Uses: tragus, gonionBottom, menton
 * Ideal: 120° - 130° (male), 125° - 135° (female)
 */
export function calculateGonialAngle(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): ScoreResult | null {
  const tragion = getLandmark(sideLandmarks, 'tragus');
  const gonion_inferior = getLandmark(sideLandmarks, 'gonionBottom');
  const menton = getLandmark(sideLandmarks, 'menton');

  if (!tragion || !gonion_inferior || !menton) return null;

  const angle = calculateAngle(tragion, gonion_inferior, menton);

  const idealMin = gender === 'male' ? 120 : 125;
  const idealMax = gender === 'male' ? 130 : 135;

  let score: number;
  if (angle >= idealMin && angle <= idealMax) {
    score = 100;
  } else {
    const deviation = angle < idealMin ? idealMin - angle : angle - idealMax;
    score = Math.max(0, 100 - deviation * 5);
  }

  return {
    value: angle,
    score,
    idealRange: { min: idealMin, max: idealMax },
    rating: getRating(score),
  };
}

/**
 * Nasolabial Angle - Angle between columella and upper lip
 * Uses: columella, subnasale, labraleSuperius
 * Ideal: 90° - 105° (male), 95° - 115° (female)
 */
export function calculateNasolabialAngle(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): ScoreResult | null {
  const columella = getLandmark(sideLandmarks, 'columella');
  const subnasale = getLandmark(sideLandmarks, 'subnasale');
  const labrale_superius = getLandmark(sideLandmarks, 'labraleSuperius');

  if (!columella || !subnasale || !labrale_superius) return null;

  const angle = calculateAngle(columella, subnasale, labrale_superius);

  const idealMin = gender === 'male' ? 90 : 95;
  const idealMax = gender === 'male' ? 105 : 115;

  let score: number;
  if (angle >= idealMin && angle <= idealMax) {
    score = 100;
  } else {
    const deviation = angle < idealMin ? idealMin - angle : angle - idealMax;
    score = Math.max(0, 100 - deviation * 4);
  }

  return {
    value: angle,
    score,
    idealRange: { min: idealMin, max: idealMax },
    rating: getRating(score),
  };
}

/**
 * E-Line (Ricketts' Esthetic Line) - Lip protrusion analysis
 * Uses: pronasale, pogonion, labraleSuperius, labraleInferius
 * Ideal: Upper lip 4mm behind (male) / 2mm behind (female)
 *        Lower lip 2mm behind (male) / 0mm (female)
 */
export function calculateELine(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): { upperLip: ScoreResult; lowerLip: ScoreResult; combined: ScoreResult } | null {
  const pronasale = getLandmark(sideLandmarks, 'pronasale');
  const pogonion = getLandmark(sideLandmarks, 'pogonion');
  const labrale_superius = getLandmark(sideLandmarks, 'labraleSuperius');
  const labrale_inferius = getLandmark(sideLandmarks, 'labraleInferius');

  if (!pronasale || !pogonion || !labrale_superius || !labrale_inferius) return null;

  const upperLipDistance = perpendicularDistance(labrale_superius, pronasale, pogonion);
  const lowerLipDistance = perpendicularDistance(labrale_inferius, pronasale, pogonion);

  // Ideal values (negative = behind the line, which is desirable)
  const idealUpperLip = gender === 'male' ? -4 : -2;
  const idealLowerLip = gender === 'male' ? -2 : 0;
  const tolerance = 2;

  // Upper lip scoring
  const upperDeviation = Math.abs(upperLipDistance - idealUpperLip);
  const upperScore =
    upperDeviation <= tolerance
      ? 100
      : Math.max(0, 100 - (upperDeviation - tolerance) * 10);

  // Lower lip scoring
  const lowerDeviation = Math.abs(lowerLipDistance - idealLowerLip);
  const lowerScore =
    lowerDeviation <= tolerance
      ? 100
      : Math.max(0, 100 - (lowerDeviation - tolerance) * 10);

  const combinedScore = (upperScore + lowerScore) / 2;

  return {
    upperLip: {
      value: upperLipDistance,
      score: upperScore,
      idealRange: { min: idealUpperLip - tolerance, max: idealUpperLip + tolerance },
      rating: getRating(upperScore),
    },
    lowerLip: {
      value: lowerLipDistance,
      score: lowerScore,
      idealRange: { min: idealLowerLip - tolerance, max: idealLowerLip + tolerance },
      rating: getRating(lowerScore),
    },
    combined: {
      value: (upperLipDistance + lowerLipDistance) / 2,
      score: combinedScore,
      idealRange: { min: -6, max: 2 },
      rating: getRating(combinedScore),
    },
  };
}

/**
 * Mentolabial Angle - Angle at the labiomental fold
 * Uses: labraleInferius, sublabiale, pogonion
 * Ideal: 120° - 140°
 */
export function calculateMentolabialAngle(
  sideLandmarks: LandmarkPoint[]
): ScoreResult | null {
  const labrale_inferius = getLandmark(sideLandmarks, 'labraleInferius');
  const sublabiale = getLandmark(sideLandmarks, 'sublabiale');
  const pogonion = getLandmark(sideLandmarks, 'pogonion');

  if (!labrale_inferius || !sublabiale || !pogonion) return null;

  const angle = calculateAngle(labrale_inferius, sublabiale, pogonion);

  const idealMin = 120;
  const idealMax = 140;

  let score: number;
  if (angle >= idealMin && angle <= idealMax) {
    score = 100;
  } else {
    const deviation = angle < idealMin ? idealMin - angle : angle - idealMax;
    score = Math.max(0, 100 - deviation * 3);
  }

  return {
    value: angle,
    score,
    idealRange: { min: idealMin, max: idealMax },
    rating: getRating(score),
  };
}

/**
 * Nasofrontal Angle - Angle at the bridge of nose
 * Uses: glabella, nasion, rhinion
 * Ideal: 115° - 135°
 */
export function calculateNasofrontalAngle(
  sideLandmarks: LandmarkPoint[]
): ScoreResult | null {
  const glabella = getLandmark(sideLandmarks, 'glabella');
  const nasion = getLandmark(sideLandmarks, 'nasion');
  const rhinion = getLandmark(sideLandmarks, 'rhinion');

  if (!glabella || !nasion || !rhinion) return null;

  const angle = calculateAngle(glabella, nasion, rhinion);

  const idealMin = 115;
  const idealMax = 135;

  let score: number;
  if (angle >= idealMin && angle <= idealMax) {
    score = 100;
  } else {
    const deviation = angle < idealMin ? idealMin - angle : angle - idealMax;
    score = Math.max(0, 100 - deviation * 3);
  }

  return {
    value: angle,
    score,
    idealRange: { min: idealMin, max: idealMax },
    rating: getRating(score),
  };
}

// ============================================
// FRONT PROFILE SCORING (uses front landmarks)
// ============================================

/**
 * Facial Thirds - Vertical face proportions
 * Uses: trichion, nasal_base, subnasale, menton
 * Ideal: Each third ~33%
 *
 * Upper third: hairline (trichion) to nasal_base
 * Middle third: nasal_base to subnasale (base of nose)
 * Lower third: subnasale to menton (chin)
 */
export function calculateFacialThirds(
  frontLandmarks: LandmarkPoint[]
): { upper: ScoreResult; middle: ScoreResult; lower: ScoreResult; overall: ScoreResult } | null {
  const trichion = getLandmark(frontLandmarks, 'trichion');
  const nasal_base = getLandmark(frontLandmarks, 'nasal_base');
  const subnasale = getLandmark(frontLandmarks, 'subnasale');
  const menton = getLandmark(frontLandmarks, 'menton');

  if (!trichion || !nasal_base || !subnasale || !menton) return null;

  const totalHeight = distance(trichion, menton);
  if (totalHeight === 0) return null;

  const upperThird = (distance(trichion, nasal_base) / totalHeight) * 100;
  const middleThird = (distance(nasal_base, subnasale) / totalHeight) * 100;
  const lowerThird = (distance(subnasale, menton) / totalHeight) * 100;

  const ideal = 33.33;
  const tolerance = 3;

  const scoreThird = (value: number): number => {
    const deviation = Math.abs(value - ideal);
    return deviation <= tolerance ? 100 : Math.max(0, 100 - (deviation - tolerance) * 8);
  };

  const upperScore = scoreThird(upperThird);
  const middleScore = scoreThird(middleThird);
  const lowerScore = scoreThird(lowerThird);
  const overallScore = (upperScore + middleScore + lowerScore) / 3;

  return {
    upper: {
      value: upperThird,
      score: upperScore,
      idealRange: { min: 30, max: 36 },
      rating: getRating(upperScore),
    },
    middle: {
      value: middleThird,
      score: middleScore,
      idealRange: { min: 30, max: 36 },
      rating: getRating(middleScore),
    },
    lower: {
      value: lowerThird,
      score: lowerScore,
      idealRange: { min: 30, max: 36 },
      rating: getRating(lowerScore),
    },
    overall: {
      value: Math.max(Math.abs(upperThird - ideal), Math.abs(middleThird - ideal), Math.abs(lowerThird - ideal)),
      score: overallScore,
      idealRange: { min: 0, max: 3 },
      rating: getRating(overallScore),
    },
  };
}

/**
 * Facial Width-to-Height Ratio (FWHR)
 * Uses: left_zygion, right_zygion, nasal_base (as upper bound), labrale_superius
 * Ideal: 1.8 - 2.0
 *
 * NOTE: This is the standard FWHR = bizygomatic_width / upper_face_height
 * (Carré & McCormick, 2008). This differs from "Total Facial Width to Height Ratio"
 * in some systems which uses total_height / cheek_width (inverted, ideal 1.33-1.38).
 * Our implementation follows the widely-used FWHR convention.
 */
export function calculateFWHR(frontLandmarks: LandmarkPoint[]): ScoreResult | null {
  const left_zygion = getLandmark(frontLandmarks, 'left_zygion');
  const right_zygion = getLandmark(frontLandmarks, 'right_zygion');
  const nasal_base = getLandmark(frontLandmarks, 'nasal_base');
  const labrale_superius = getLandmark(frontLandmarks, 'labrale_superius');

  if (!left_zygion || !right_zygion || !nasal_base || !labrale_superius) return null;

  const bizygomatic_width = distance(left_zygion, right_zygion);
  const upper_face_height = distance(nasal_base, labrale_superius);

  if (upper_face_height === 0) return null;

  const ratio = bizygomatic_width / upper_face_height;

  const idealMin = 1.8;
  const idealMax = 2.0;

  let score: number;
  if (ratio >= idealMin && ratio <= idealMax) {
    score = 100;
  } else {
    const deviation = ratio < idealMin ? idealMin - ratio : ratio - idealMax;
    score = Math.max(0, 100 - deviation * 50);
  }

  return {
    value: ratio,
    score,
    idealRange: { min: idealMin, max: idealMax },
    rating: getRating(score),
  };
}

/**
 * Interpupillary Distance Ratio
 * Uses: left_pupila, right_pupila, left_zygion, right_zygion
 * Ideal: IPD ~46% of bizygomatic width
 */
export function calculateIPDRatio(frontLandmarks: LandmarkPoint[]): ScoreResult | null {
  const left_pupila = getLandmark(frontLandmarks, 'left_pupila');
  const right_pupila = getLandmark(frontLandmarks, 'right_pupila');
  const left_zygion = getLandmark(frontLandmarks, 'left_zygion');
  const right_zygion = getLandmark(frontLandmarks, 'right_zygion');

  if (!left_pupila || !right_pupila || !left_zygion || !right_zygion) return null;

  const ipd = distance(left_pupila, right_pupila);
  const bizygomatic_width = distance(left_zygion, right_zygion);

  if (bizygomatic_width === 0) return null;

  const ratio = (ipd / bizygomatic_width) * 100;

  const ideal = 46;
  const tolerance = 2;

  const deviation = Math.abs(ratio - ideal);
  const score = deviation <= tolerance ? 100 : Math.max(0, 100 - (deviation - tolerance) * 8);

  return {
    value: ratio,
    score,
    idealRange: { min: 44, max: 48 },
    rating: getRating(score),
  };
}

/**
 * Nasal Index (Nose Width to Height)
 * Uses: left_ala_nasi, right_ala_nasi, nasal_base, subnasale
 * Classification varies by ethnicity
 */
export function calculateNasalIndex(frontLandmarks: LandmarkPoint[]): ScoreResult | null {
  const left_ala_nasi = getLandmark(frontLandmarks, 'left_ala_nasi');
  const right_ala_nasi = getLandmark(frontLandmarks, 'right_ala_nasi');
  const nasal_base = getLandmark(frontLandmarks, 'nasal_base');
  const subnasale = getLandmark(frontLandmarks, 'subnasale');

  if (!left_ala_nasi || !right_ala_nasi || !nasal_base || !subnasale) return null;

  const nasal_width = distance(left_ala_nasi, right_ala_nasi);
  const nasal_height = distance(nasal_base, subnasale);

  if (nasal_height === 0) return null;

  const index = (nasal_width / nasal_height) * 100;

  // Using mesorrhine (medium) as ideal: 70-85
  const idealMin = 70;
  const idealMax = 85;

  let score: number;
  if (index >= idealMin && index <= idealMax) {
    score = 100;
  } else {
    const deviation = index < idealMin ? idealMin - index : index - idealMax;
    score = Math.max(0, 100 - deviation * 3);
  }

  return {
    value: index,
    score,
    idealRange: { min: idealMin, max: idealMax },
    rating: getRating(score),
  };
}

/**
 * Eye Canthal Tilt
 * Uses: left_canthus_medialis, left_canthus_lateralis (or right)
 * Ideal: 4° - 8° positive tilt
 */
export function calculateCanthalTilt(
  frontLandmarks: LandmarkPoint[],
  side: 'left' | 'right' = 'left'
): ScoreResult | null {
  const medialId = side === 'left' ? 'left_canthus_medialis' : 'right_canthus_medialis';
  const lateralId = side === 'left' ? 'left_canthus_lateralis' : 'right_canthus_lateralis';

  const canthus_medialis = getLandmark(frontLandmarks, medialId);
  const canthus_lateralis = getLandmark(frontLandmarks, lateralId);

  if (!canthus_medialis || !canthus_lateralis) return null;

  // Y is inverted in screen coordinates
  const deltaY = canthus_medialis.y - canthus_lateralis.y;
  const deltaX = canthus_lateralis.x - canthus_medialis.x;

  const angle = Math.atan2(deltaY, deltaX) * (180 / Math.PI);

  const idealMin = 4;
  const idealMax = 8;

  let score: number;
  if (angle >= idealMin && angle <= idealMax) {
    score = 100;
  } else if (angle < 0) {
    // Negative tilt is worse
    score = Math.max(0, 50 + angle * 5);
  } else {
    const deviation = angle < idealMin ? idealMin - angle : angle - idealMax;
    score = Math.max(0, 100 - deviation * 10);
  }

  return {
    value: angle,
    score,
    idealRange: { min: idealMin, max: idealMax },
    rating: getRating(score),
  };
}

/**
 * Mouth Width to Nose Width Ratio
 * Uses: left_cheilion, right_cheilion, left_ala_nasi, right_ala_nasi
 * Ideal: 1.5 - 1.6
 */
export function calculateMouthNoseRatio(frontLandmarks: LandmarkPoint[]): ScoreResult | null {
  const left_cheilion = getLandmark(frontLandmarks, 'left_cheilion');
  const right_cheilion = getLandmark(frontLandmarks, 'right_cheilion');
  const left_ala_nasi = getLandmark(frontLandmarks, 'left_ala_nasi');
  const right_ala_nasi = getLandmark(frontLandmarks, 'right_ala_nasi');

  if (!left_cheilion || !right_cheilion || !left_ala_nasi || !right_ala_nasi) return null;

  const mouth_width = distance(left_cheilion, right_cheilion);
  const nose_width = distance(left_ala_nasi, right_ala_nasi);

  if (nose_width === 0) return null;

  const ratio = mouth_width / nose_width;

  const idealMin = 1.5;
  const idealMax = 1.6;

  let score: number;
  if (ratio >= idealMin && ratio <= idealMax) {
    score = 100;
  } else {
    const deviation = ratio < idealMin ? idealMin - ratio : ratio - idealMax;
    score = Math.max(0, 100 - deviation * 30);
  }

  return {
    value: ratio,
    score,
    idealRange: { min: idealMin, max: idealMax },
    rating: getRating(score),
  };
}

/**
 * Jaw Width to Face Width Ratio (Bigonial to Bizygomatic)
 * Uses: left_gonion_inferior, right_gonion_inferior, left_zygion, right_zygion
 * Ideal: 0.75 - 0.80 (male), 0.70 - 0.75 (female)
 */
export function calculateJawRatio(
  frontLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): ScoreResult | null {
  const left_gonion = getLandmark(frontLandmarks, 'left_gonion_inferior');
  const right_gonion = getLandmark(frontLandmarks, 'right_gonion_inferior');
  const left_zygion = getLandmark(frontLandmarks, 'left_zygion');
  const right_zygion = getLandmark(frontLandmarks, 'right_zygion');

  if (!left_gonion || !right_gonion || !left_zygion || !right_zygion) return null;

  const bigonial_width = distance(left_gonion, right_gonion);
  const bizygomatic_width = distance(left_zygion, right_zygion);

  if (bizygomatic_width === 0) return null;

  const ratio = bigonial_width / bizygomatic_width;

  const idealMin = gender === 'male' ? 0.75 : 0.7;
  const idealMax = gender === 'male' ? 0.8 : 0.75;

  let score: number;
  if (ratio >= idealMin && ratio <= idealMax) {
    score = 100;
  } else {
    const deviation = ratio < idealMin ? idealMin - ratio : ratio - idealMax;
    score = Math.max(0, 100 - deviation * 100);
  }

  return {
    value: ratio,
    score,
    idealRange: { min: idealMin, max: idealMax },
    rating: getRating(score),
  };
}

// ============================================
// COMPREHENSIVE ANALYSIS
// ============================================

export interface FrontAnalysisResults {
  facialThirds: ReturnType<typeof calculateFacialThirds>;
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
  eLine: ReturnType<typeof calculateELine>;
  mentolabialAngle: ScoreResult | null;
  nasofrontalAngle: ScoreResult | null;
  overallScore: number;
}

/**
 * Run all front profile analyses
 */
export function analyzeFrontProfile(
  frontLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): FrontAnalysisResults {
  const facialThirds = calculateFacialThirds(frontLandmarks);
  const fwhr = calculateFWHR(frontLandmarks);
  const ipdRatio = calculateIPDRatio(frontLandmarks);
  const nasalIndex = calculateNasalIndex(frontLandmarks);
  const leftCanthalTilt = calculateCanthalTilt(frontLandmarks, 'left');
  const rightCanthalTilt = calculateCanthalTilt(frontLandmarks, 'right');
  const mouthNoseRatio = calculateMouthNoseRatio(frontLandmarks);
  const jawRatio = calculateJawRatio(frontLandmarks, gender);

  // Calculate overall score from valid results
  const scores: number[] = [];
  if (facialThirds) scores.push(facialThirds.overall.score);
  if (fwhr) scores.push(fwhr.score);
  if (ipdRatio) scores.push(ipdRatio.score);
  if (nasalIndex) scores.push(nasalIndex.score);
  if (leftCanthalTilt) scores.push(leftCanthalTilt.score);
  if (rightCanthalTilt) scores.push(rightCanthalTilt.score);
  if (mouthNoseRatio) scores.push(mouthNoseRatio.score);
  if (jawRatio) scores.push(jawRatio.score);

  const overallScore = scores.length > 0 ? scores.reduce((a, b) => a + b, 0) / scores.length : 0;

  return {
    facialThirds,
    fwhr,
    ipdRatio,
    nasalIndex,
    leftCanthalTilt,
    rightCanthalTilt,
    mouthNoseRatio,
    jawRatio,
    overallScore,
  };
}

/**
 * Run all side profile analyses
 */
export function analyzeSideProfile(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): SideAnalysisResults {
  const gonialAngle = calculateGonialAngle(sideLandmarks, gender);
  const nasolabialAngle = calculateNasolabialAngle(sideLandmarks, gender);
  const eLine = calculateELine(sideLandmarks, gender);
  const mentolabialAngle = calculateMentolabialAngle(sideLandmarks);
  const nasofrontalAngle = calculateNasofrontalAngle(sideLandmarks);

  // Calculate overall score from valid results
  const scores: number[] = [];
  if (gonialAngle) scores.push(gonialAngle.score);
  if (nasolabialAngle) scores.push(nasolabialAngle.score);
  if (eLine) scores.push(eLine.combined.score);
  if (mentolabialAngle) scores.push(mentolabialAngle.score);
  if (nasofrontalAngle) scores.push(nasofrontalAngle.score);

  const overallScore = scores.length > 0 ? scores.reduce((a, b) => a + b, 0) / scores.length : 0;

  return {
    gonialAngle,
    nasolabialAngle,
    eLine,
    mentolabialAngle,
    nasofrontalAngle,
    overallScore,
  };
}

// ============================================
// FACEIQ-STYLE BELL CURVE SCORING
// ============================================

/**
 * Bell curve scoring function
 * score = e^(-0.5 × ((value-ideal)/stdDev)²) × 100
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
 * Get bell curve score with gender-specific ideal values
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
 * Calculate overall harmony score (weighted average)
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
// PERCENTILE RANKING (Population Comparison)
// ============================================

/**
 * Standard normal CDF approximation (Abramowitz and Stegun formula)
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
  const y =
    1.0 -
    ((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t * Math.exp(-absZ * absZ);

  return 0.5 * (1.0 + sign * y);
}

/**
 * Calculate percentile (where you fall on the bell curve)
 */
export function calculatePercentile(
  value: number,
  stats: PopulationStats
): number {
  const z = (value - stats.mean) / stats.standardDeviation;
  return normalCDF(z) * 100;
}

/**
 * Calculate percentile for a specific measurement
 */
export function calculateMeasurementPercentile(
  value: number,
  measurementKey: string
): number {
  const stats = POPULATION_STATS[measurementKey];
  if (!stats) {
    return 50; // Default to median if no stats available
  }
  return calculatePercentile(value, stats);
}

// ============================================
// BELL CURVE DATA FOR VISUALIZATION
// ============================================

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
 * Generate bell curve data for a specific measurement
 */
export function generateMeasurementBellCurve(
  measurementKey: string,
  userValue: number,
  gender?: 'male' | 'female'
): BellCurveData | null {
  const stats = POPULATION_STATS[measurementKey];
  if (!stats) {
    return null;
  }

  const idealValues = FACEIQ_IDEAL_VALUES[measurementKey];
  const idealValue = idealValues && gender ? idealValues[gender].ideal : undefined;

  return generateBellCurveData(stats, userValue, idealValue);
}

// ============================================
// ENHANCED SCORE RESULTS
// ============================================

export interface EnhancedScoreResult extends ScoreResult {
  bellCurveScore: number;
  percentile: number;
  idealValue: number;
  deviation: number;
}

/**
 * Create enhanced score result with bell curve and percentile
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

  return {
    value,
    score: bellCurveScore,
    idealRange: idealValues
      ? { min: idealValues[gender].range[0], max: idealValues[gender].range[1] }
      : { min: config.idealValue - config.standardDeviation, max: config.idealValue + config.standardDeviation },
    rating: getRating(bellCurveScore),
    bellCurveScore,
    percentile,
    idealValue,
    deviation,
  };
}

// ============================================
// COMPREHENSIVE ANALYSIS WITH BELL CURVES
// ============================================

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

/**
 * Run comprehensive front profile analysis with bell curves
 */
export function comprehensiveFrontAnalysis(
  frontLandmarks: LandmarkPoint[],
  gender: 'male' | 'female' = 'male'
): ComprehensiveFrontAnalysis {
  const baseAnalysis = analyzeFrontProfile(frontLandmarks, gender);

  const bellCurveScores: Record<string, number> = {};
  const percentiles: Record<string, number> = {};

  // Calculate bell curve scores for each measurement
  if (baseAnalysis.fwhr) {
    bellCurveScores.fwhr = calculateGenderAwareBellCurveScore(
      baseAnalysis.fwhr.value,
      'fwhr',
      gender
    );
    percentiles.fwhr = calculateMeasurementPercentile(
      baseAnalysis.fwhr.value,
      'fwhr'
    );
  }

  if (baseAnalysis.leftCanthalTilt) {
    bellCurveScores.canthalTilt = calculateGenderAwareBellCurveScore(
      baseAnalysis.leftCanthalTilt.value,
      'canthalTilt',
      gender
    );
    percentiles.canthalTilt = calculateMeasurementPercentile(
      baseAnalysis.leftCanthalTilt.value,
      'canthalTilt'
    );
  }

  if (baseAnalysis.nasalIndex) {
    bellCurveScores.nasalIndex = calculateGenderAwareBellCurveScore(
      baseAnalysis.nasalIndex.value,
      'nasalIndex',
      gender
    );
  }

  const harmonyScore = calculateHarmonyScore(bellCurveScores);

  return {
    ...baseAnalysis,
    bellCurveScores,
    percentiles,
    harmonyScore,
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

  const bellCurveScores: Record<string, number> = {};
  const percentiles: Record<string, number> = {};

  // Calculate bell curve scores for each measurement
  if (baseAnalysis.gonialAngle) {
    bellCurveScores.gonialAngle = calculateGenderAwareBellCurveScore(
      baseAnalysis.gonialAngle.value,
      'gonialAngle',
      gender
    );
  }

  if (baseAnalysis.nasolabialAngle) {
    bellCurveScores.nasolabialAngle = calculateGenderAwareBellCurveScore(
      baseAnalysis.nasolabialAngle.value,
      'nasolabialAngle',
      gender
    );
  }

  const harmonyScore = calculateHarmonyScore(bellCurveScores);

  return {
    ...baseAnalysis,
    bellCurveScores,
    percentiles,
    harmonyScore,
  };
}
