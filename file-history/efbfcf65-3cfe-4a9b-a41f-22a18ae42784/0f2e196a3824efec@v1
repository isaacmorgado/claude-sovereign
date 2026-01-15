/**
 * Scoring Calculator
 * Core scoring algorithm functions extracted from harmony-scoring.ts
 *
 * Features:
 * - Exponential decay scoring with per-metric decay rates
 * - Bezier curve custom scoring for non-linear measurements
 * - Directional/Dimorphic scoring (polarity support)
 * - Quality tiers and severity levels
 */

import {
  Point,
  QualityTier,
  SeverityLevel,
  MeasurementUnit,
  MetricConfig,
  CurvePoint,
  FlawMapping,
} from './types';
import { BEZIER_CURVES } from '@/lib/bezier-curves';

// ============================================
// FLAW MAPPINGS
// ============================================

export const METRIC_FLAW_MAPPINGS: Record<string, FlawMapping[]> = {
  anteriorFacialDepth: [
    { category: 'Midface/Face Shape', flawName: 'Underprojected midface', confidence: 'confirmed', reasoning: 'The Anterior Facial Depth measurement is above the ideal range. This disrupts facial harmony by creating a sunken and unprominent appearance to the midface.' },
  ],
  bitemporalWidth: [
    { category: 'Upper Third', flawName: 'Narrow forehead', confidence: 'confirmed', reasoning: 'Reduced bitemporal width indicates a narrower than ideal forehead relative to the cheekbones. This disrupts facial harmony by creating a compressed hairline and forehead, altering the overall shape of the face.' },
  ],
  cheekboneHeight: [
    { category: 'Midface/Face Shape', flawName: 'Low-set cheekbones', confidence: 'confirmed', reasoning: 'Reduced cheekbone height indicates that the cheekbones are positioned lower than ideal. This disrupts facial harmony by creating an unpronounced appearance to the cheekbones and facial structure.' },
  ],
  cheekFullness: [
    { category: 'Midface/Face Shape', flawName: 'Hollow/Gaunt midface', confidence: 'confirmed', reasoning: 'Reduced cheek fullness indicates volume loss or hollow cheeks. This disrupts facial harmony by creating a gaunt or aged appearance, particularly important in South Asian and East Asian beauty standards.' },
  ],
  eyeAspectRatio: [
    { category: 'Eyes', flawName: 'Overly round eye shape', confidence: 'confirmed', reasoning: 'A reduced eye aspect ratio indicates overly narrow eyes relative to their height. This disrupts facial harmony by creating an overly surprised appearance and reducing angular definition.' },
  ],
  eyeSeparationRatio: [
    { category: 'Eyes', flawName: 'Close-set eyes', confidence: 'confirmed', reasoning: 'Reduced eye separation indicates close-set eyes. This disrupts facial harmony by making the eye area appear too compressed.' },
  ],
  eyebrowLowSetedness: [
    { category: 'Eyes', flawName: 'Medium-set eyebrows', confidence: 'confirmed', reasoning: 'Increased eyebrow low setedness indicates eyebrows that are positioned higher than ideal. This disrupts facial harmony by reducing the overall visual impact of the eyebrows and framing of the eyes.' },
  ],
  faceWidthToHeight: [
    { category: 'Midface/Face Shape', flawName: 'Long midface', confidence: 'confirmed', reasoning: 'A reduced face width to height ratio indicates an overly long midface relative to its height. This disrupts facial harmony by overemphasizing the middle of the face.' },
  ],
  facialDepthToHeight: [
    { category: 'Occlusion/Jaw Growth', flawName: 'Maxillary recession', confidence: 'confirmed', reasoning: 'Reduced facial depth to height ratio indicates insufficient mid-face projection relative to height. This disrupts facial harmony by creating the appearance of a flat midface.' },
  ],
  gonialAngle: [
    { category: 'Jaw Shape', flawName: 'Weak/soft jaw structure', confidence: 'confirmed', reasoning: 'A wider gonial angle indicates a softer, less defined jawline with reduced angularity. This disrupts facial harmony in the lower face.' },
    { category: 'Jaw Shape', flawName: 'Steep jaw', confidence: 'confirmed', reasoning: 'A wider gonial angle indicates a softer, less defined jawline with reduced angularity. This disrupts facial harmony by creating a narrow or pointed chin effect.' },
  ],
  holdawayHLine: [
    { category: 'Lips', flawName: 'Overly full lower lip', confidence: 'confirmed', reasoning: 'Decreased H-line indicates the lips are positioned too far in front of the line. This disrupts facial harmony by drawing attention to the lower lip and creating an imbalance between the lower lip, chin, and nose.' },
  ],
  interiorMidfaceProjectionAngle: [
    { category: 'Midface/Face Shape', flawName: 'Underprojected midface', confidence: 'confirmed', reasoning: 'The Interior Midface Projection Angle measurement is above the ideal range. This disrupts facial harmony by creating a sunken and unprominent appearance to the midface.' },
  ],
  ipsilateralAlarAngle: [
    { category: 'Midface/Face Shape', flawName: 'Long midface', confidence: 'confirmed', reasoning: 'A decreased ipsilateral alar angle indicates an overly narrow interior midface. This disrupts facial harmony by overemphasizing the middle of the face.' },
  ],
  jawFrontalAngle: [
    { category: 'Jaw Shape', flawName: 'Steep jaw', confidence: 'confirmed', reasoning: 'A narrower jaw frontal angle indicates a steeper jawline or overly wide chin. This disrupts facial harmony by creating a narrow or pointed chin effect.' },
  ],
  jawSlope: [
    { category: 'Jaw Shape', flawName: 'Weak/soft jaw structure', confidence: 'confirmed', reasoning: 'The Jaw Slope measurement is above the ideal range. This disrupts facial harmony in the lower face.' },
  ],
  lateralCanthalTilt: [
    { category: 'Eyes', flawName: 'Insufficient eye tilt', confidence: 'confirmed', reasoning: 'A decreased lateral canthal tilt indicates insufficiently upturned eyes. This disrupts facial harmony by creating a less alert and youthful appearance.' },
  ],
  burstoneLowerLip: [
    { category: 'Lips', flawName: 'Overly full lower lip', confidence: 'confirmed', reasoning: 'The lower lip is positioned excessively in front of the Burstone line. This disrupts facial harmony by drawing attention to the lower lip and creating an imbalance between the lower lip, chin, and nose.' },
  ],
  eLineLowerLip: [
    { category: 'Lips', flawName: 'Overly full lower lip', confidence: 'confirmed', reasoning: 'The lower lip is positioned too far in front of the E-line. This disrupts facial harmony by drawing attention to the lower lip and creating an imbalance between the lower lip, chin, and nose.' },
  ],
  sLineLowerLip: [
    { category: 'Lips', flawName: 'Overly full lower lip', confidence: 'confirmed', reasoning: 'The lower lip is positioned excessively in front of the S-line. This disrupts facial harmony by drawing attention to the lower lip and creating an imbalance between the lower lip, chin, and nose.' },
  ],
  lowerThirdProportion: [
    { category: 'Midface/Face Shape', flawName: 'Long upper jaw', confidence: 'confirmed', reasoning: 'The upper jaw is too long relative to lower jaw, possibly from a long upper jaw or short lower jaw, or a combination of both. This disrupts facial harmony by overemphasizing the upper jaw relative to the lower jaw.' },
  ],
  mandibularPlaneAngle: [
    { category: 'Occlusion/Jaw Growth', flawName: 'Hyper-divergent jaw growth', confidence: 'confirmed', reasoning: 'A steeper mandibular plane angle indicates vertical overgrowth, elongating the lower face and potentially indicating malocclusion. This disrupts facial harmony by elongating the lower face.' },
    { category: 'Jaw Shape', flawName: 'Weak/soft jaw structure', confidence: 'confirmed', reasoning: 'A steeper mandibular plane angle indicates vertical overgrowth, elongating the lower face and potentially indicating malocclusion. This disrupts facial harmony in the lower face.' },
    { category: 'Jaw Shape', flawName: 'Steep jaw', confidence: 'confirmed', reasoning: 'A steeper mandibular plane angle indicates vertical overgrowth, elongating the lower face and potentially indicating malocclusion. This disrupts facial harmony by creating a narrow or pointed chin effect.' },
  ],
  midfaceRatio: [
    { category: 'Midface/Face Shape', flawName: 'Long midface', confidence: 'confirmed', reasoning: 'A reduced midface ratio indicates an overly narrow interior midface relative to its height. This disrupts facial harmony by overemphasizing the middle of the face.' },
    { category: 'Midface/Face Shape', flawName: 'Long upper jaw', confidence: 'confirmed', reasoning: 'A reduced midface ratio indicates an overly narrow interior midface relative to its height. This disrupts facial harmony by overemphasizing the upper jaw relative to the lower jaw.' },
  ],
  nasofacialAngle: [
    { category: 'Occlusion/Jaw Growth', flawName: 'Maxillary recession', confidence: 'confirmed', reasoning: 'A smaller nasofacial angle suggests reduced projection of the nose and midface region, or an overprojected chin. This disrupts facial harmony by creating the appearance of a flat midface.' },
  ],
  nasofrontalAngle: [
    { category: 'Upper Third', flawName: 'Soft and weak brow ridge', confidence: 'confirmed', reasoning: 'An increased nasofrontal angle indicates reduced brow ridge prominence and angularity. This disrupts facial harmony by creating a less defined upper face.' },
  ],
  nasomentaAngle: [
    { category: 'Occlusion/Jaw Growth', flawName: 'Maxillary recession', confidence: 'confirmed', reasoning: 'A larger nasomental angle suggests reduced projection of the nose and midface region, or an overprojected chin. This disrupts facial harmony by creating the appearance of a flat midface.' },
  ],
  noseBridgeWidth: [
    { category: 'Nose', flawName: 'Overly narrow nose bridge', confidence: 'confirmed', reasoning: 'The Nose Bridge to Nose Width measurement is above the ideal range. This disrupts facial harmony by creating an unbalanced nasal profile.' },
  ],
  orbitalVector: [
    { category: 'Eyes', flawName: 'Sunken orbital region', confidence: 'confirmed', reasoning: 'A decreased orbital vector indicates insufficient projection and volume underneath the eye. This disrupts facial harmony due to the lacking volume underneath the eyes, reducing vibrancy and youthfulness.' },
  ],
  ramusToMandibleRatio: [
    { category: 'Jaw Shape', flawName: 'Short ramus', confidence: 'confirmed', reasoning: 'A reduced ramus-to-mandible ratio indicates a shorter than ideal vertical jawbone (ramus) when compared to the mandible. This disrupts facial harmony by reducing jaw height and definition.' },
  ],
  submentalCervicalAngle: [
    { category: 'Neck', flawName: 'Round neck region', confidence: 'confirmed', reasoning: 'An increased submental cervical angle indicates a round neck region, possibly from excess submental fat or tissue. This disrupts facial harmony by reducing neck definition.' },
  ],
  totalFacialWidthToHeight: [
    { category: 'Midface/Face Shape', flawName: 'Overly long face shape', confidence: 'confirmed', reasoning: 'An increased total facial width to height ratio indicates an overly long face relative to its height. This disrupts facial harmony by creating a vertically stretched appearance to the face.' },
  ],
};

// ============================================
// CUSTOM BEZIER CURVES (Ethnicity-specific override)
// ============================================

export const METRIC_CUSTOM_CURVES: Record<string, CurvePoint[]> = {
  faceWidthToHeight: [
    { x: 1.49, y: 0, leftHandleX: 1.44, leftHandleY: 0, rightHandleX: 1.55, rightHandleY: 0 },
    { x: 1.68, y: 1.05, leftHandleX: 1.62, leftHandleY: 0.36, rightHandleX: 1.71, rightHandleY: 1.58 },
    { x: 1.77, y: 3.07, leftHandleX: 1.74, leftHandleY: 2.15, rightHandleX: 1.79, rightHandleY: 3.88 },
    { x: 1.83, y: 5.83, leftHandleX: 1.8, leftHandleY: 4.64, rightHandleX: 1.84, rightHandleY: 6.85 },
    { x: 1.89, y: 8.7, leftHandleX: 1.88, leftHandleY: 8.3, rightHandleX: 1.92, rightHandleY: 9.5 },
    { x: 1.96, y: 10, leftHandleX: 1.96, leftHandleY: 10, rightHandleX: 1.96, rightHandleY: 10, fixed: true },
    { x: 2, y: 10, leftHandleX: 2, leftHandleY: 10, rightHandleX: 2, rightHandleY: 10 },
    { x: 2.07, y: 8.7, leftHandleX: 2.04, leftHandleY: 9.5, rightHandleX: 2.08, rightHandleY: 8.3 },
    { x: 2.13, y: 5.83, leftHandleX: 2.12, leftHandleY: 6.85, rightHandleX: 2.16, rightHandleY: 4.64 },
    { x: 2.19, y: 3.07, leftHandleX: 2.17, leftHandleY: 3.88, rightHandleX: 2.22, rightHandleY: 2.15 },
    { x: 2.28, y: 1.05, leftHandleX: 2.25, leftHandleY: 1.58, rightHandleX: 2.34, rightHandleY: 0.36 },
    { x: 2.47, y: 0, leftHandleX: 2.41, leftHandleY: 0, rightHandleX: 2.52, rightHandleY: 0 },
  ],
  lowerThirdProportion: [
    { x: 25.6, y: 0, leftHandleX: 24.8, leftHandleY: 0, rightHandleX: 26.4, rightHandleY: 0 },
    { x: 28.01, y: 1.58, leftHandleX: 27.23, leftHandleY: 0.53, rightHandleX: 28.27, rightHandleY: 1.97 },
    { x: 28.83, y: 3.21, leftHandleX: 28.62, leftHandleY: 2.59, rightHandleX: 29.03, rightHandleY: 3.76 },
    { x: 29.63, y: 5.85, leftHandleX: 29.38, leftHandleY: 4.64, rightHandleX: 29.84, rightHandleY: 6.61 },
    { x: 30.27, y: 8.56, leftHandleX: 30.1, leftHandleY: 7.71, rightHandleX: 30.52, rightHandleY: 9.42 },
    { x: 31, y: 10, leftHandleX: 30.88, leftHandleY: 10, rightHandleX: 31.13, rightHandleY: 10, fixed: true },
    { x: 33.5, y: 10, leftHandleX: 33.38, leftHandleY: 10, rightHandleX: 33.63, rightHandleY: 10 },
    { x: 34.23, y: 8.56, leftHandleX: 33.98, leftHandleY: 9.42, rightHandleX: 34.4, rightHandleY: 7.71 },
    { x: 34.87, y: 5.85, leftHandleX: 34.66, leftHandleY: 6.61, rightHandleX: 35.12, rightHandleY: 4.64 },
    { x: 35.67, y: 3.21, leftHandleX: 35.47, leftHandleY: 3.76, rightHandleX: 35.88, rightHandleY: 2.59 },
    { x: 36.49, y: 1.58, leftHandleX: 36.23, leftHandleY: 1.97, rightHandleX: 37.27, rightHandleY: 0.53 },
    { x: 38.9, y: 0, leftHandleX: 38.1, leftHandleY: 0, rightHandleX: 39.7, rightHandleY: 0 },
  ],
  eyeAspectRatio: [
    { x: 1.44, y: 0, leftHandleX: 1.18, leftHandleY: 0, rightHandleX: 1.75, rightHandleY: 0.38 },
    { x: 2.07, y: 1.66, leftHandleX: 1.96, leftHandleY: 1.08, rightHandleX: 2.24, rightHandleY: 2.63 },
    { x: 2.42, y: 4.34, leftHandleX: 2.35, leftHandleY: 3.6, rightHandleX: 2.52, rightHandleY: 5.5 },
    { x: 2.71, y: 7.96, leftHandleX: 2.65, leftHandleY: 7.13, rightHandleX: 2.8, rightHandleY: 9.08 },
    { x: 3, y: 10, leftHandleX: 2.98, leftHandleY: 10, rightHandleX: 3.03, rightHandleY: 10, fixed: true },
    { x: 3.5, y: 10, leftHandleX: 3.48, leftHandleY: 10, rightHandleX: 3.53, rightHandleY: 10 },
    { x: 3.79, y: 7.96, leftHandleX: 3.7, leftHandleY: 9.08, rightHandleX: 3.85, rightHandleY: 7.13 },
    { x: 4.08, y: 4.34, leftHandleX: 3.98, leftHandleY: 5.5, rightHandleX: 4.15, rightHandleY: 3.6 },
    { x: 4.43, y: 1.66, leftHandleX: 4.26, leftHandleY: 2.63, rightHandleX: 4.54, rightHandleY: 1.08 },
    { x: 5.06, y: 0, leftHandleX: 4.75, leftHandleY: 0.38, rightHandleX: 5.32, rightHandleY: 0 },
  ],
  // Note: Additional curves can be added from METRIC_CUSTOM_CURVES in harmony-scoring.ts
};

// ============================================
// CORE SCORING FUNCTIONS
// ============================================

/**
 * Exponential Decay Scoring Algorithm with Directional/Dimorphic Support
 *
 * Standard: score = maxScore * e^(-decayRate * deviation)
 *
 * Directional scoring (polarity):
 * - 'higher_is_better': Values above safeFloor but below ideal get softZoneScore
 *   Example: Canthal Tilt of 3 degrees is still positive/good, just not peak ideal (6-8 degrees)
 * - 'lower_is_better': Values below safeCeiling but above ideal get softZoneScore
 *   Example: Short philtrum is still attractive even if shorter than "ideal"
 */
export function calculateMetricScore(
  value: number,
  config: MetricConfig
): number {
  const {
    id,
    idealMin,
    idealMax,
    decayRate,
    maxScore,
    customCurve,
    polarity = 'balanced',
    safeFloor,
    safeCeiling,
    softZoneScore = 8.0, // Default "Good" score for acceptable-but-not-ideal values
  } = config;

  // IMPORTANT: Check demographic-adjusted ideal range FIRST
  // This ensures that demographic overrides are respected even when Bezier curves exist
  // (Bezier curves are optimized for base ranges and don't auto-adjust for demographics)
  if (value >= idealMin && value <= idealMax) {
    return maxScore;
  }

  // Use custom curve if available in config
  if (customCurve && customCurve.mode === 'custom') {
    return interpolateCustomCurve(value, customCurve.points, maxScore);
  }

  // Check for pre-defined Bezier curve from harmony curves (66 metrics)
  const bezierCurve = BEZIER_CURVES[id];
  if (bezierCurve && bezierCurve.mode === 'custom') {
    return interpolateCustomCurve(value, bezierCurve.points, maxScore);
  }

  // Handle directional/dimorphic scoring
  if (polarity === 'higher_is_better' && safeFloor !== undefined) {
    // Higher values are good. Only values below safeFloor are true weaknesses.
    if (value >= safeFloor && value < idealMin) {
      // Value is in the "acceptable but not ideal" zone
      // Give a passing score that decreases linearly as we approach the floor
      const zoneRange = idealMin - safeFloor;
      const distanceFromIdeal = idealMin - value;
      const t = zoneRange > 0 ? distanceFromIdeal / zoneRange : 0;
      // Linear interpolation: idealMin -> maxScore, safeFloor -> softZoneScore
      return maxScore - t * (maxScore - softZoneScore);
    }
    if (value >= idealMax) {
      // Values above ideal are still excellent for 'higher_is_better'
      // Apply gentler decay (1/3 the normal rate)
      const deviation = value - idealMax;
      const gentleDecay = decayRate / 3;
      return Math.max(softZoneScore, maxScore * Math.exp(-gentleDecay * deviation));
    }
    // Below safeFloor - apply normal (or harsher) exponential decay
    if (value < safeFloor) {
      const deviation = safeFloor - value;
      return Math.max(0, softZoneScore * Math.exp(-decayRate * deviation));
    }
  }

  if (polarity === 'lower_is_better' && safeCeiling !== undefined) {
    // Lower values are good. Only values above safeCeiling are true weaknesses.
    if (value <= safeCeiling && value > idealMax) {
      // Value is in the "acceptable but not ideal" zone
      const zoneRange = safeCeiling - idealMax;
      const distanceFromIdeal = value - idealMax;
      const t = zoneRange > 0 ? distanceFromIdeal / zoneRange : 0;
      // Linear interpolation: idealMax -> maxScore, safeCeiling -> softZoneScore
      return maxScore - t * (maxScore - softZoneScore);
    }
    if (value <= idealMin) {
      // Values below ideal are still excellent for 'lower_is_better'
      // Apply gentler decay (1/3 the normal rate)
      const deviation = idealMin - value;
      const gentleDecay = decayRate / 3;
      return Math.max(softZoneScore, maxScore * Math.exp(-gentleDecay * deviation));
    }
    // Above safeCeiling - apply normal exponential decay
    if (value > safeCeiling) {
      const deviation = value - safeCeiling;
      return Math.max(0, softZoneScore * Math.exp(-decayRate * deviation));
    }
  }

  // Default balanced scoring: deviation in either direction is equally bad
  const deviation = value < idealMin
    ? idealMin - value
    : value - idealMax;

  // Exponential decay
  const score = maxScore * Math.exp(-decayRate * deviation);

  return Math.max(0, Math.min(maxScore, score));
}

/**
 * Check if a metric value is in an "acceptable" zone (not a true weakness).
 * Used by InsightsEngine to prevent false positives.
 */
export function isValueAcceptable(
  value: number,
  config: MetricConfig
): { acceptable: boolean; reason: string } {
  const {
    idealMin,
    idealMax,
    polarity = 'balanced',
    safeFloor,
    safeCeiling,
  } = config;

  // Within ideal range is always acceptable
  if (value >= idealMin && value <= idealMax) {
    return { acceptable: true, reason: 'within_ideal' };
  }

  // Check directional acceptability
  if (polarity === 'higher_is_better') {
    if (value >= idealMax) {
      return { acceptable: true, reason: 'above_ideal_higher_is_better' };
    }
    if (safeFloor !== undefined && value >= safeFloor) {
      return { acceptable: true, reason: 'above_safe_floor' };
    }
    // Below safe floor - true weakness
    return { acceptable: false, reason: 'below_safe_floor' };
  }

  if (polarity === 'lower_is_better') {
    if (value <= idealMin) {
      return { acceptable: true, reason: 'below_ideal_lower_is_better' };
    }
    if (safeCeiling !== undefined && value <= safeCeiling) {
      return { acceptable: true, reason: 'below_safe_ceiling' };
    }
    // Above safe ceiling - true weakness
    return { acceptable: false, reason: 'above_safe_ceiling' };
  }

  // Balanced polarity - outside ideal is not acceptable
  return { acceptable: false, reason: 'outside_ideal_balanced' };
}

/**
 * Interpolate custom Bezier curve for scoring
 * Uses cubic Bezier interpolation with control handles for smooth curves
 */
export function interpolateCustomCurve(
  value: number,
  points: CurvePoint[],
  maxScore: number
): number {
  void maxScore; // Reserved for future custom curve implementations
  if (points.length === 0) return 0;

  // Sort points by x value
  const sortedPoints = [...points].sort((a, b) => a.x - b.x);

  // Clamp to range
  if (value <= sortedPoints[0].x) return sortedPoints[0].y;
  if (value >= sortedPoints[sortedPoints.length - 1].x) {
    return sortedPoints[sortedPoints.length - 1].y;
  }

  // Find bracketing points
  let lowerIndex = 0;
  for (let i = 0; i < sortedPoints.length - 1; i++) {
    if (value >= sortedPoints[i].x && value <= sortedPoints[i + 1].x) {
      lowerIndex = i;
      break;
    }
  }

  const p0 = sortedPoints[lowerIndex];
  const p3 = sortedPoints[lowerIndex + 1];

  // Check if we have Bezier control handles
  const hasHandles = p0.rightHandleX !== undefined && p3.leftHandleX !== undefined;

  if (hasHandles) {
    // Cubic Bezier interpolation with control points
    const p1x = p0.rightHandleX!;
    const p1y = p0.rightHandleY ?? p0.y;
    const p2x = p3.leftHandleX!;
    const p2y = p3.leftHandleY ?? p3.y;

    // Find t parameter for given x value using Newton-Raphson iteration
    let t = (value - p0.x) / (p3.x - p0.x); // Initial guess

    // Newton-Raphson iterations to find t where B_x(t) = value
    for (let iter = 0; iter < 10; iter++) {
      const bx = cubicBezier(p0.x, p1x, p2x, p3.x, t);
      const bxDerivative = cubicBezierDerivative(p0.x, p1x, p2x, p3.x, t);

      if (Math.abs(bxDerivative) < 1e-10) break;

      const newT = t - (bx - value) / bxDerivative;
      if (Math.abs(newT - t) < 1e-10) break;
      t = Math.max(0, Math.min(1, newT));
    }

    // Calculate y using the found t parameter
    return cubicBezier(p0.y, p1y, p2y, p3.y, t);
  } else {
    // Smooth interpolation using Catmull-Rom spline
    // This provides smoother curves than linear interpolation
    const t = (value - p0.x) / (p3.x - p0.x);

    // Get neighboring points for spline calculation
    const pMinus1 = lowerIndex > 0 ? sortedPoints[lowerIndex - 1] : p0;
    const p4 = lowerIndex + 2 < sortedPoints.length ? sortedPoints[lowerIndex + 2] : p3;

    // Catmull-Rom spline interpolation
    return catmullRomSpline(pMinus1.y, p0.y, p3.y, p4.y, t);
  }
}

/**
 * Cubic Bezier curve evaluation: B(t) = (1-t)^3*P0 + 3*(1-t)^2*t*P1 + 3*(1-t)*t^2*P2 + t^3*P3
 */
export function cubicBezier(p0: number, p1: number, p2: number, p3: number, t: number): number {
  const mt = 1 - t;
  const mt2 = mt * mt;
  const mt3 = mt2 * mt;
  const t2 = t * t;
  const t3 = t2 * t;
  return mt3 * p0 + 3 * mt2 * t * p1 + 3 * mt * t2 * p2 + t3 * p3;
}

/**
 * Cubic Bezier derivative: B'(t) = 3*(1-t)^2*(P1-P0) + 6*(1-t)*t*(P2-P1) + 3*t^2*(P3-P2)
 */
export function cubicBezierDerivative(p0: number, p1: number, p2: number, p3: number, t: number): number {
  const mt = 1 - t;
  return 3 * mt * mt * (p1 - p0) + 6 * mt * t * (p2 - p1) + 3 * t * t * (p3 - p2);
}

/**
 * Catmull-Rom spline interpolation for smooth curves without explicit handles
 */
export function catmullRomSpline(p0: number, p1: number, p2: number, p3: number, t: number): number {
  const t2 = t * t;
  const t3 = t2 * t;

  // Catmull-Rom coefficients with tension = 0.5
  const a = -0.5 * p0 + 1.5 * p1 - 1.5 * p2 + 0.5 * p3;
  const b = p0 - 2.5 * p1 + 2 * p2 - 0.5 * p3;
  const c = -0.5 * p0 + 0.5 * p2;
  const d = p1;

  return a * t3 + b * t2 + c * t + d;
}

/**
 * Calculate standardized score (0-10 normalized)
 */
export function standardizeScore(score: number, maxScore: number): number {
  return (score / maxScore) * 10;
}

/**
 * Determine quality tier based on score
 */
export function getQualityTier(score: number, maxScore: number = 10): QualityTier {
  const normalized = (score / maxScore) * 100;

  if (normalized >= 90) return 'ideal';
  if (normalized >= 70) return 'excellent';
  if (normalized >= 50) return 'good';
  return 'below_average';
}

/**
 * Determine severity level based on score
 */
export function getSeverityLevel(score: number, maxScore: number = 10): SeverityLevel {
  const normalized = (score / maxScore) * 100;

  if (normalized >= 85) return 'optimal';
  if (normalized >= 70) return 'minor';
  if (normalized >= 50) return 'moderate';
  if (normalized >= 30) return 'major';
  if (normalized >= 15) return 'severe';
  return 'extremely_severe';
}

/**
 * Calculate deviation description
 */
export function getDeviationDescription(
  value: number,
  idealMin: number,
  idealMax: number,
  unit: MeasurementUnit
): { deviation: number; direction: 'above' | 'below' | 'within'; description: string } {
  if (value >= idealMin && value <= idealMax) {
    return { deviation: 0, direction: 'within', description: 'within ideal range' };
  }

  const unitLabel = getUnitLabel(unit);

  if (value < idealMin) {
    const dev = idealMin - value;
    return {
      deviation: dev,
      direction: 'below',
      description: `${dev.toFixed(2)}${unitLabel} below ideal`,
    };
  }

  const dev = value - idealMax;
  return {
    deviation: dev,
    direction: 'above',
    description: `${dev.toFixed(2)}${unitLabel} above ideal`,
  };
}

/**
 * Get unit label for display
 */
export function getUnitLabel(unit: MeasurementUnit): string {
  switch (unit) {
    case 'ratio': return 'x';
    case 'percent': return '%';
    case 'degrees': return '\u00B0';
    case 'mm': return 'mm';
    default: return '';
  }
}

// ============================================
// GEOMETRY HELPERS
// ============================================

/**
 * Calculate distance between two points
 */
export function distance(p1: Point, p2: Point): number {
  return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
}

/**
 * Calculate angle at vertex point (in degrees)
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
 * Calculate perpendicular distance from point to line (signed)
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

// ============================================
// PERCENTILE & PSL CONVERSION
// ============================================

/**
 * Calculate percentile from harmony score
 */
export function calculateHarmonyPercentile(score: number): number {
  // Based on normal distribution with mean=5, stdDev=1.5
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

// ============================================
// PSL RATING CONVERSION
// ============================================

export interface PSLRating {
  score: number;
  tier: string;
  percentile: number;
  description: string;
}

/**
 * Convert harmony score to PSL rating
 */
export function convertToPSL(harmonyScore: number): PSLRating {
  // Convert 0-10 harmony to 3.0-7.5 PSL range
  const psl = 3.0 + (harmonyScore / 10) * 4.5;
  const clampedPSL = Math.max(3.0, Math.min(7.5, psl));

  let tier: string;
  let percentile: number;

  if (clampedPSL >= 7.5) {
    tier = 'Top Model';
    percentile = 99.99;
  } else if (clampedPSL >= 7.0) {
    tier = 'Chad';
    percentile = 99.87;
  } else if (clampedPSL >= 6.5) {
    tier = 'Chadlite';
    percentile = 99.0;
  } else if (clampedPSL >= 6.0) {
    tier = 'High Tier Normie+';
    percentile = 97.25;
  } else if (clampedPSL >= 5.5) {
    tier = 'High Tier Normie';
    percentile = 90.0;
  } else if (clampedPSL >= 5.0) {
    tier = 'Mid Tier Normie+';
    percentile = 84.15;
  } else if (clampedPSL >= 4.5) {
    tier = 'Mid Tier Normie';
    percentile = 65.0;
  } else if (clampedPSL >= 4.0) {
    tier = 'Low Tier Normie';
    percentile = 50.0;
  } else if (clampedPSL >= 3.5) {
    tier = 'Below Average';
    percentile = 30.0;
  } else {
    tier = 'Subpar';
    percentile = 15.0;
  }

  return {
    score: clampedPSL,
    tier,
    percentile,
    description: `${tier} (top ${(100 - percentile).toFixed(1)}%)`,
  };
}
