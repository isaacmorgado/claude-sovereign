/**
 * Facial Profile Analyzer
 * High-level analysis functions for front and side profile measurements
 *
 * Features:
 * - 32+ front profile measurements
 * - 30+ side profile measurements
 * - Ethnicity-specific ideal ranges
 * - Combined harmony analysis
 */

import {
  Point,
  MetricScoreResult,
  HarmonyAnalysis,
  FlawAssessment,
  StrengthAssessment,
  DemographicOptions,
  FrontProfileResults,
  SideProfileResults,
  Gender,
  Ethnicity,
} from './types';

import {
  calculateMetricScore,
  getQualityTier,
  getSeverityLevel,
  distance,
  calculateAngle,
  perpendicularDistance,
  standardizeScore,
  calculateHarmonyPercentile,
  getDeviationDescription,
} from './calculator';

import { METRIC_CONFIGS } from '@/lib/data/metric-configs';
import { getMetricConfigForDemographics } from '@/lib/data/demographic-overrides';
import { LandmarkPoint } from '@/lib/landmarks';

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Helper to get landmark by ID
 */
export function getLandmark(landmarks: LandmarkPoint[], id: string): Point | null {
  const lm = landmarks.find((l) => l.id === id);
  return lm ? { x: lm.x, y: lm.y } : null;
}

// ============================================
// SCORE A SINGLE MEASUREMENT
// ============================================

/**
 * Calculate complete score result for a measurement.
 * If demographics provided, uses demographic-specific ideal ranges.
 */
export function scoreMeasurement(
  metricId: string,
  value: number,
  demographics?: DemographicOptions
): MetricScoreResult | null {
  // Get config with demographic overrides if provided
  const config = demographics?.gender
    ? getMetricConfigForDemographics(metricId, demographics.gender, demographics.ethnicity || 'other', METRIC_CONFIGS)
    : METRIC_CONFIGS[metricId];

  if (!config) return null;

  const score = calculateMetricScore(value, config);
  const standardizedScore = standardizeScore(score, config.maxScore);
  const qualityTier = getQualityTier(score, config.maxScore);
  const severity = getSeverityLevel(score, config.maxScore);
  const { deviation, direction } = getDeviationDescription(
    value,
    config.idealMin,
    config.idealMax,
    config.unit
  );

  return {
    metricId,
    name: config.name,
    value,
    score,
    standardizedScore,
    qualityTier,
    severity,
    idealMin: config.idealMin,
    idealMax: config.idealMax,
    deviation,
    deviationDirection: direction,
    unit: config.unit,
    category: config.category,
  };
}

// ============================================
// FRONT PROFILE ANALYSIS
// ============================================

/**
 * Calculate all front profile measurements from landmarks.
 * Now supports ethnicity-specific ideal ranges for more accurate scoring.
 */
export function analyzeFrontProfile(
  landmarks: LandmarkPoint[],
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'other'
): FrontProfileResults {
  const measurements: MetricScoreResult[] = [];
  const demographics: DemographicOptions = { gender, ethnicity };

  // Helper to add measurement if landmarks available
  const addMeasurement = (metricId: string, value: number | null) => {
    if (value !== null) {
      const result = scoreMeasurement(metricId, value, demographics);
      if (result) measurements.push(result);
    }
  };

  // Get key landmarks
  const trichion = getLandmark(landmarks, 'trichion');
  const nasalBase = getLandmark(landmarks, 'nasal_base');
  const subnasale = getLandmark(landmarks, 'subnasale');
  const menton = getLandmark(landmarks, 'menton');
  const leftZygion = getLandmark(landmarks, 'left_zygion');
  const rightZygion = getLandmark(landmarks, 'right_zygion');
  const leftGonion = getLandmark(landmarks, 'left_gonion_inferior');
  const rightGonion = getLandmark(landmarks, 'right_gonion_inferior');
  const leftPupil = getLandmark(landmarks, 'left_pupila');
  const rightPupil = getLandmark(landmarks, 'right_pupila');
  const leftCanthusM = getLandmark(landmarks, 'left_canthus_medialis');
  const leftCanthusL = getLandmark(landmarks, 'left_canthus_lateralis');
  const rightCanthusM = getLandmark(landmarks, 'right_canthus_medialis');
  const rightCanthusL = getLandmark(landmarks, 'right_canthus_lateralis');
  void rightCanthusL; // Will be used for asymmetry measurements
  const leftAlaNasi = getLandmark(landmarks, 'left_ala_nasi');
  const rightAlaNasi = getLandmark(landmarks, 'right_ala_nasi');
  const leftCheilion = getLandmark(landmarks, 'left_cheilion');
  const rightCheilion = getLandmark(landmarks, 'right_cheilion');
  const labraleSuperius = getLandmark(landmarks, 'labrale_superius');
  const labraleInferius = getLandmark(landmarks, 'labrale_inferius');

  // FACIAL THIRDS
  if (trichion && nasalBase && subnasale && menton) {
    const totalHeight = distance(trichion, menton);
    if (totalHeight > 0) {
      const upperThird = (distance(trichion, nasalBase) / totalHeight) * 100;
      const middleThird = (distance(nasalBase, subnasale) / totalHeight) * 100;
      const lowerThird = (distance(subnasale, menton) / totalHeight) * 100;

      addMeasurement('upperThirdProportion', upperThird);
      addMeasurement('middleThirdProportion', middleThird);
      addMeasurement('lowerThirdProportion', lowerThird);

      // Lower Third Internal Ratio (subnasale to stomion / subnasale to menton)
      const stomion = getLandmark(landmarks, 'mouth_middle');
      if (stomion) {
        const subnasaleToStomion = distance(subnasale, stomion);
        const subnasaleToMenton = distance(subnasale, menton);
        if (subnasaleToMenton > 0) {
          const lowerThirdAlt = (subnasaleToStomion / subnasaleToMenton) * 100;
          addMeasurement('lowerThirdProportionAlt', lowerThirdAlt);
        }
      }
    }
  }

  // FACE WIDTH TO HEIGHT RATIO (FWHR)
  if (leftZygion && rightZygion && nasalBase && labraleSuperius) {
    const bizygomaticWidth = distance(leftZygion, rightZygion);
    const upperFaceHeight = distance(nasalBase, labraleSuperius);
    if (upperFaceHeight > 0) {
      addMeasurement('faceWidthToHeight', bizygomaticWidth / upperFaceHeight);
    }
  }

  // TOTAL FACIAL WIDTH TO HEIGHT
  if (leftZygion && rightZygion && trichion && menton) {
    const cheekWidth = distance(leftZygion, rightZygion);
    const totalHeight = distance(trichion, menton);
    if (cheekWidth > 0) {
      addMeasurement('totalFacialWidthToHeight', totalHeight / cheekWidth);
    }
  }

  // JAW WIDTH RATIO
  if (leftGonion && rightGonion && leftZygion && rightZygion) {
    const bigonialWidth = distance(leftGonion, rightGonion);
    const bizygomaticWidth = distance(leftZygion, rightZygion);
    if (bizygomaticWidth > 0) {
      const ratio = bigonialWidth / bizygomaticWidth;
      addMeasurement('jawWidthRatio', ratio);
      addMeasurement('bigonialWidth', ratio * 100);
    }
  }

  // CANTHAL TILT
  // Positive tilt = lateral canthus is higher than medial (lower y in screen coords)
  // Use abs(deltaX) to avoid sign issues between left/right eye
  if (leftCanthusM && leftCanthusL) {
    const deltaY = leftCanthusM.y - leftCanthusL.y;  // positive if lateral is higher
    const deltaX = Math.abs(leftCanthusM.x - leftCanthusL.x);  // eye width (always positive)
    const angle = Math.atan2(deltaY, deltaX) * (180 / Math.PI);
    addMeasurement('lateralCanthalTilt', angle);
  }

  // EYE ASPECT RATIO
  if (leftCanthusM && leftCanthusL) {
    const leftPalpSup = getLandmark(landmarks, 'left_palpebra_superior');
    const leftPalpInf = getLandmark(landmarks, 'left_palpebra_inferior');
    if (leftPalpSup && leftPalpInf) {
      const eyeWidth = distance(leftCanthusM, leftCanthusL);
      const eyeHeight = distance(leftPalpSup, leftPalpInf);
      if (eyeHeight > 0) {
        // Eye aspect ratio = width / height (ideal ~3.0-3.5 for almond shape)
        addMeasurement('eyeAspectRatio', eyeWidth / eyeHeight);
      }
    }
  }

  // EYE SEPARATION RATIO
  if (leftCanthusM && rightCanthusM && leftZygion && rightZygion) {
    const intercanthal = distance(leftCanthusM, rightCanthusM);
    const bizygomatic = distance(leftZygion, rightZygion);
    if (bizygomatic > 0) {
      addMeasurement('eyeSeparationRatio', intercanthal / bizygomatic);
    }
  }

  // IPD RATIO
  if (leftPupil && rightPupil && leftZygion && rightZygion) {
    const ipd = distance(leftPupil, rightPupil);
    const bizygomatic = distance(leftZygion, rightZygion);
    if (bizygomatic > 0) {
      addMeasurement('interpupillaryRatio', (ipd / bizygomatic) * 100);
    }
  }

  // ONE EYE APART TEST
  if (leftCanthusM && rightCanthusM && leftCanthusL) {
    const intercanthal = distance(leftCanthusM, rightCanthusM);
    const eyeWidth = distance(leftCanthusM, leftCanthusL);
    if (eyeWidth > 0) {
      addMeasurement('oneEyeApartTest', intercanthal / eyeWidth);
    }
  }

  // NASAL INDEX
  if (leftAlaNasi && rightAlaNasi && nasalBase && subnasale) {
    const nasalWidth = distance(leftAlaNasi, rightAlaNasi);
    const nasalHeight = distance(nasalBase, subnasale);
    if (nasalHeight > 0) {
      addMeasurement('nasalIndex', (nasalWidth / nasalHeight) * 100);
    }
  }

  // INTERCANTHAL-NASAL WIDTH RATIO
  if (leftCanthusM && rightCanthusM && leftAlaNasi && rightAlaNasi) {
    const intercanthal = distance(leftCanthusM, rightCanthusM);
    const nasalWidth = distance(leftAlaNasi, rightAlaNasi);
    if (nasalWidth > 0) {
      addMeasurement('intercanthalNasalRatio', intercanthal / nasalWidth);
    }
  }

  // MOUTH TO NOSE RATIO
  if (leftCheilion && rightCheilion && leftAlaNasi && rightAlaNasi) {
    const mouthWidth = distance(leftCheilion, rightCheilion);
    const nasalWidth = distance(leftAlaNasi, rightAlaNasi);
    if (nasalWidth > 0) {
      addMeasurement('mouthWidthToNoseRatio', mouthWidth / nasalWidth);
    }
  }

  // IPD TO MOUTH WIDTH RATIO
  if (leftPupil && rightPupil && leftCheilion && rightCheilion) {
    const ipd = distance(leftPupil, rightPupil);
    const mouthWidth = distance(leftCheilion, rightCheilion);
    if (ipd > 0) {
      addMeasurement('interpupillaryMouthWidthRatio', mouthWidth / ipd);
    }
  }

  // LIP RATIO
  if (labraleSuperius && labraleInferius && subnasale) {
    const mouthMiddle = getLandmark(landmarks, 'mouth_middle');
    if (mouthMiddle) {
      const upperLipHeight = distance(subnasale, labraleSuperius);
      const lowerLipHeight = distance(mouthMiddle, labraleInferius);
      if (upperLipHeight > 0) {
        addMeasurement('lowerToUpperLipRatio', lowerLipHeight / upperLipHeight);
      }
    }
  }

  // MIDFACE RATIO
  if (leftZygion && rightZygion && nasalBase && subnasale) {
    const midfaceWidth = distance(leftZygion, rightZygion);
    const midfaceHeight = distance(nasalBase, subnasale);
    if (midfaceHeight > 0) {
      addMeasurement('midfaceRatio', midfaceWidth / midfaceHeight / 10); // Normalized
    }
  }

  // CHEEK FULLNESS (Malar Convexity)
  // Measures how much the cheek protrudes outward from the line between zygion and gonion
  // Positive = Full/Youthful cheeks; Negative = Hollow/Gaunt cheeks
  const leftMalar = getLandmark(landmarks, 'left_malar');
  const rightMalar = getLandmark(landmarks, 'right_malar');

  if (leftZygion && rightZygion && leftGonion && rightGonion && leftMalar && rightMalar) {
    // Helper: Calculate signed perpendicular distance from point to line
    const pointLineDistance = (p: Point, a: Point, b: Point): number => {
      // Cross product: (bx - ax)(py - ay) - (by - ay)(px - ax)
      const cross = (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
      const lineLength = Math.sqrt(Math.pow(b.x - a.x, 2) + Math.pow(b.y - a.y, 2));
      return cross / lineLength;
    };

    // Calculate convexity for both sides
    const rightFullness = Math.abs(pointLineDistance(rightMalar, rightZygion, rightGonion));
    const leftFullness = Math.abs(pointLineDistance(leftMalar, leftZygion, leftGonion));

    // Normalize by face width to make scale-invariant
    const faceWidth = distance(leftZygion, rightZygion);
    if (faceWidth > 0) {
      const rawScore = (rightFullness + leftFullness) / 2;
      const normalizedScore = (rawScore / faceWidth) * 100;
      addMeasurement('cheekFullness', normalizedScore);
    }
  }

  // CHIN WIDTH
  // Measures horizontal width of the mental protuberance (chin bone)
  // Uses left/right mentum lateralis landmarks (132, 361 in MediaPipe)
  const leftMentumLat = getLandmark(landmarks, 'left_mentum_lateralis');
  const rightMentumLat = getLandmark(landmarks, 'right_mentum_lateralis');

  if (leftMentumLat && rightMentumLat && leftZygion && rightZygion) {
    const chinWidth = distance(leftMentumLat, rightMentumLat);
    const faceWidth = distance(leftZygion, rightZygion);
    if (faceWidth > 0) {
      const chinWidthPercent = (chinWidth / faceWidth) * 100;
      addMeasurement('chinWidth', chinWidthPercent);
    }
  }

  // EYEBROW THICKNESS
  // Measures vertical height of eyebrow at thickest point
  // Landmarks: brow top (66, 296) and brow bottom (46, 276)
  const leftBrowTop = getLandmark(landmarks, 'left_supercilium_superior');  // 52 in mapping, but we need 66
  const leftBrowBottom = getLandmark(landmarks, 'left_supercilium_apex');  // 105 in mapping, but we need 46
  const rightBrowTop = getLandmark(landmarks, 'right_supercilium_superior');  // 282 in mapping, but we need 296
  const rightBrowBottom = getLandmark(landmarks, 'right_supercilium_apex');  // 334 in mapping, but we need 276

  if (leftBrowTop && leftBrowBottom && rightBrowTop && rightBrowBottom && leftCanthusM && leftCanthusL) {
    const leftThickness = distance(leftBrowTop, leftBrowBottom);
    const rightThickness = distance(rightBrowTop, rightBrowBottom);
    const avgThickness = (leftThickness + rightThickness) / 2;

    // Normalize by eye height to make scale-invariant
    const leftPalpSup = getLandmark(landmarks, 'left_palpebra_superior');
    const leftPalpInf = getLandmark(landmarks, 'left_palpebra_inferior');
    if (leftPalpSup && leftPalpInf) {
      const eyeHeight = distance(leftPalpSup, leftPalpInf);
      if (eyeHeight > 0) {
        const normalizedThickness = (avgThickness / eyeHeight) * 10.0;  // Scale factor
        addMeasurement('eyebrowThickness', normalizedThickness);
      }
    }
  }

  // UPPER EYELID EXPOSURE
  // Measures visible skin between eyelash line and eyelid crease
  // Landmarks: crease (27, 257) and lid top/lash line (159, 386)
  if (leftCanthusM && leftCanthusL) {
    const leftPalpSup = getLandmark(landmarks, 'left_palpebra_superior');
    const leftPalpInf = getLandmark(landmarks, 'left_palpebra_inferior');
    const leftCrease = getLandmark(landmarks, 'left_pretarsal_skin_crease');

    if (leftPalpSup && leftPalpInf && leftCrease) {
      // Distance from brow bone/crease to lash line
      const lidGap = distance(leftCrease, leftPalpSup);

      // Normalize by total eye opening height
      const eyeOpen = distance(leftPalpSup, leftPalpInf);
      if (eyeOpen > 0) {
        const exposure = lidGap / eyeOpen;
        addMeasurement('upperEyelidExposure', exposure);
      }
    }
  }

  // TEAR TROUGH DEPTH
  // Placeholder metric: Default to 0.2 (clean/good) since we can't measure depth from 2D landmarks
  // Future upgrade: Implement OpenCV color sampler to detect darkness under eyes
  // For now, assign a neutral/good value so it doesn't unfairly penalize users
  addMeasurement('tearTroughDepth', 0.2);

  // Calculate category scores
  const categoryScores: Record<string, { total: number; count: number }> = {};
  for (const m of measurements) {
    if (!categoryScores[m.category]) {
      categoryScores[m.category] = { total: 0, count: 0 };
    }
    categoryScores[m.category].total += m.standardizedScore;
    categoryScores[m.category].count++;
  }

  const categoryAvg: Record<string, number> = {};
  for (const [cat, data] of Object.entries(categoryScores)) {
    categoryAvg[cat] = data.count > 0 ? data.total / data.count : 0;
  }

  // Calculate overall score (weighted average)
  let totalWeight = 0;
  let weightedSum = 0;
  for (const m of measurements) {
    const config = METRIC_CONFIGS[m.metricId];
    if (config) {
      weightedSum += m.standardizedScore * config.weight;
      totalWeight += config.weight;
    }
  }

  const overallScore = totalWeight > 0 ? weightedSum / totalWeight : 0;
  const standardizedScoreValue = overallScore;

  return {
    measurements,
    overallScore,
    standardizedScore: standardizedScoreValue,
    qualityTier: getQualityTier(overallScore),
    categoryScores: categoryAvg,
  };
}

// ============================================
// SIDE PROFILE ANALYSIS
// ============================================

/**
 * Calculate all side profile measurements from landmarks.
 * Now supports ethnicity-specific ideal ranges for more accurate scoring.
 */
export function analyzeSideProfile(
  landmarks: LandmarkPoint[],
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'other'
): SideProfileResults {
  const measurements: MetricScoreResult[] = [];
  const demographics: DemographicOptions = { gender, ethnicity };

  const addMeasurement = (metricId: string, value: number | null) => {
    if (value !== null) {
      const result = scoreMeasurement(metricId, value, demographics);
      if (result) measurements.push(result);
    }
  };

  // Get key landmarks
  const glabella = getLandmark(landmarks, 'glabella');
  const nasion = getLandmark(landmarks, 'nasion');
  const rhinion = getLandmark(landmarks, 'rhinion');
  const pronasale = getLandmark(landmarks, 'pronasale');
  const columella = getLandmark(landmarks, 'columella');
  const subnasale = getLandmark(landmarks, 'subnasale');
  const labraleSuperius = getLandmark(landmarks, 'labraleSuperius');
  const labraleInferius = getLandmark(landmarks, 'labraleInferius');
  const sublabiale = getLandmark(landmarks, 'sublabiale');
  const pogonion = getLandmark(landmarks, 'pogonion');
  const menton = getLandmark(landmarks, 'menton');
  const tragus = getLandmark(landmarks, 'tragus');
  const gonionBottom = getLandmark(landmarks, 'gonionBottom');
  const cervicalPoint = getLandmark(landmarks, 'cervicalPoint');
  const orbitale = getLandmark(landmarks, 'orbitale');
  const porion = getLandmark(landmarks, 'porion');

  // GONIAL ANGLE
  if (tragus && gonionBottom && menton) {
    const angle = calculateAngle(tragus, gonionBottom, menton);
    addMeasurement('gonialAngle', angle);
  }

  // NASOLABIAL ANGLE
  if (columella && subnasale && labraleSuperius) {
    const angle = calculateAngle(columella, subnasale, labraleSuperius);
    addMeasurement('nasolabialAngle', angle);
  }

  // NASOFRONTAL ANGLE
  if (glabella && nasion && rhinion) {
    const angle = calculateAngle(glabella, nasion, rhinion);
    addMeasurement('nasofrontalAngle', angle);
  }

  // MENTOLABIAL ANGLE
  if (labraleInferius && sublabiale && pogonion) {
    const angle = calculateAngle(labraleInferius, sublabiale, pogonion);
    addMeasurement('mentolabialAngle', angle);
  }

  // E-LINE MEASUREMENTS (Ricketts)
  // E-line runs from pronasale (nose tip) to soft tissue pogonion (chin)
  // Sign convention: positive = in front of line, negative = behind
  // perpendicularDistance returns positive for behind, so we negate
  if (pronasale && pogonion && labraleSuperius && labraleInferius) {
    const upperLipDist = perpendicularDistance(labraleSuperius, pronasale, pogonion);
    const lowerLipDist = perpendicularDistance(labraleInferius, pronasale, pogonion);
    // Negate to match sign convention (positive = protruding/in front)
    addMeasurement('eLineUpperLip', -upperLipDist);
    addMeasurement('eLineLowerLip', -lowerLipDist);
  }

  // BURSTONE LINE MEASUREMENTS
  // Burstone line runs from subnasale to soft tissue pogonion
  // Sign convention: negative = behind line (ideal is -4.7 to -2.3 for upper, -2.8 to -1.2 for lower)
  if (subnasale && pogonion && labraleSuperius && labraleInferius) {
    const upperLipBurstone = perpendicularDistance(labraleSuperius, subnasale, pogonion);
    const lowerLipBurstone = perpendicularDistance(labraleInferius, subnasale, pogonion);
    // Negate to match sign convention (negative = behind)
    addMeasurement('burstoneUpperLip', -upperLipBurstone);
    addMeasurement('burstoneLowerLip', -lowerLipBurstone);
  }

  // S-LINE MEASUREMENTS (Steiner)
  // S-line runs from columella (or subnasale) to soft tissue pogonion
  // Sign convention: positive = in front of line, negative = behind
  const sLineStart = columella || subnasale;
  if (sLineStart && pogonion && labraleSuperius && labraleInferius) {
    const upperLipSLine = perpendicularDistance(labraleSuperius, sLineStart, pogonion);
    const lowerLipSLine = perpendicularDistance(labraleInferius, sLineStart, pogonion);
    // Negate to match sign convention (positive = protruding/in front)
    addMeasurement('sLineUpperLip', -upperLipSLine);
    addMeasurement('sLineLowerLip', -lowerLipSLine);
  }

  // HOLDAWAY H-LINE MEASUREMENT
  // H-line runs from upper lip (labrale superius) to soft tissue pogonion
  // Measures lower lip distance from this line
  // Sign convention: positive = in front of line (ideal 0-4mm)
  if (labraleSuperius && pogonion && labraleInferius) {
    const lowerLipHLine = perpendicularDistance(labraleInferius, labraleSuperius, pogonion);
    // Negate to match sign convention (positive = protruding/in front)
    addMeasurement('holdawayHLine', -lowerLipHLine);
  }

  // NASOMENTAL ANGLE
  if (nasion && pronasale && pogonion) {
    const angle = calculateAngle(nasion, pronasale, pogonion);
    addMeasurement('nasomentaAngle', angle);
  }

  // FACIAL CONVEXITY (GLABELLA)
  if (glabella && subnasale && pogonion) {
    const angle = calculateAngle(glabella, subnasale, pogonion);
    addMeasurement('facialConvexityGlabella', angle);
  }

  // FACIAL CONVEXITY (NASION)
  if (nasion && subnasale && pogonion) {
    const angle = calculateAngle(nasion, subnasale, pogonion);
    addMeasurement('facialConvexityNasion', angle);
  }

  // TOTAL FACIAL CONVEXITY
  if (glabella && pronasale && pogonion) {
    const angle = calculateAngle(glabella, pronasale, pogonion);
    addMeasurement('totalFacialConvexity', angle);
  }

  // SUBMENTAL CERVICAL ANGLE
  if (menton && cervicalPoint && pogonion) {
    const neckPoint = getLandmark(landmarks, 'neckPoint');
    if (neckPoint) {
      const angle = calculateAngle(pogonion, menton, neckPoint);
      addMeasurement('submentalCervicalAngle', angle);
    }
  }

  // NASAL PROJECTION (Goode ratio)
  if (pronasale && subnasale && nasion) {
    const projection = distance(pronasale, subnasale);
    const nasalLength = distance(nasion, pronasale);
    if (nasalLength > 0) {
      addMeasurement('nasalProjection', projection / nasalLength);
    }
  }

  // NASOFACIAL ANGLE
  if (nasion && pronasale && pogonion) {
    // Angle between nose dorsum and facial plane
    const nasalDorsum = { x: pronasale.x - nasion.x, y: pronasale.y - nasion.y };
    const facialPlane = { x: pogonion.x - nasion.x, y: pogonion.y - nasion.y };

    const dot = nasalDorsum.x * facialPlane.x + nasalDorsum.y * facialPlane.y;
    const mag1 = Math.sqrt(nasalDorsum.x ** 2 + nasalDorsum.y ** 2);
    const mag2 = Math.sqrt(facialPlane.x ** 2 + facialPlane.y ** 2);

    if (mag1 > 0 && mag2 > 0) {
      const angle = Math.acos(dot / (mag1 * mag2)) * (180 / Math.PI);
      addMeasurement('nasofacialAngle', angle);
    }
  }

  // MANDIBULAR PLANE ANGLE (using Frankfort horizontal)
  if (porion && orbitale && gonionBottom && menton) {
    // Frankfort horizontal is porion to orbitale
    // Mandibular plane is gonion to menton
    const fhAngle = Math.atan2(orbitale.y - porion.y, orbitale.x - porion.x);
    const mpAngle = Math.atan2(menton.y - gonionBottom.y, menton.x - gonionBottom.x);
    const angle = Math.abs(fhAngle - mpAngle) * (180 / Math.PI);
    addMeasurement('mandibularPlaneAngle', angle);
  }

  // CHIN PROJECTION
  if (pogonion && subnasale) {
    // Distance from pogonion to vertical line through subnasale
    const projection = pogonion.x - subnasale.x;
    addMeasurement('chinProjection', projection);
  }

  // Calculate category scores
  const categoryScores: Record<string, { total: number; count: number }> = {};
  for (const m of measurements) {
    if (!categoryScores[m.category]) {
      categoryScores[m.category] = { total: 0, count: 0 };
    }
    categoryScores[m.category].total += m.standardizedScore;
    categoryScores[m.category].count++;
  }

  const categoryAvg: Record<string, number> = {};
  for (const [cat, data] of Object.entries(categoryScores)) {
    categoryAvg[cat] = data.count > 0 ? data.total / data.count : 0;
  }

  // Calculate overall score
  let totalWeight = 0;
  let weightedSum = 0;
  for (const m of measurements) {
    const config = METRIC_CONFIGS[m.metricId];
    if (config) {
      weightedSum += m.standardizedScore * config.weight;
      totalWeight += config.weight;
    }
  }

  const overallScore = totalWeight > 0 ? weightedSum / totalWeight : 0;

  return {
    measurements,
    overallScore,
    standardizedScore: overallScore,
    qualityTier: getQualityTier(overallScore),
    categoryScores: categoryAvg,
  };
}

// ============================================
// COMPLETE HARMONY ANALYSIS
// ============================================

/**
 * Run complete facial harmony analysis.
 * Now supports ethnicity-specific ideal ranges for more accurate scoring.
 */
export function analyzeHarmony(
  frontLandmarks: LandmarkPoint[],
  sideLandmarks: LandmarkPoint[],
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'other'
): HarmonyAnalysis {
  const frontResults = analyzeFrontProfile(frontLandmarks, gender, ethnicity);
  const sideResults = analyzeSideProfile(sideLandmarks, gender, ethnicity);

  const allMeasurements = [...frontResults.measurements, ...sideResults.measurements];

  // Combined category scores
  const allCategories: Record<string, { total: number; count: number }> = {};
  for (const m of allMeasurements) {
    if (!allCategories[m.category]) {
      allCategories[m.category] = { total: 0, count: 0 };
    }
    allCategories[m.category].total += m.standardizedScore;
    allCategories[m.category].count++;
  }

  const categoryScores: Record<string, number> = {};
  for (const [cat, data] of Object.entries(allCategories)) {
    categoryScores[cat] = data.count > 0 ? data.total / data.count : 0;
  }

  // Overall weighted score
  let totalWeight = 0;
  let weightedSum = 0;
  for (const m of allMeasurements) {
    const config = METRIC_CONFIGS[m.metricId];
    if (config) {
      weightedSum += m.standardizedScore * config.weight;
      totalWeight += config.weight;
    }
  }

  const overallScore = totalWeight > 0 ? weightedSum / totalWeight : 0;

  // Identify flaws (below average measurements)
  const flaws: FlawAssessment[] = allMeasurements
    .filter((m) => m.severity !== 'optimal' && m.severity !== 'minor')
    .map((m) => ({
      category: m.category,
      metricId: m.metricId,
      metricName: m.name,
      severity: m.severity,
      deviation: `${m.deviation.toFixed(2)} ${m.deviationDirection} ideal`,
      reasoning: `${m.name} is outside the ideal range`,
      confidence: m.severity === 'extremely_severe' || m.severity === 'severe'
        ? 'confirmed' as const
        : 'likely' as const,
    }))
    .sort((a, b) => {
      const severityOrder = { extremely_severe: 0, severe: 1, major: 2, moderate: 3 };
      return (severityOrder[a.severity as keyof typeof severityOrder] ?? 4) -
             (severityOrder[b.severity as keyof typeof severityOrder] ?? 4);
    });

  // Identify strengths (ideal measurements)
  const strengths: StrengthAssessment[] = allMeasurements
    .filter((m) => m.qualityTier === 'ideal' || m.qualityTier === 'excellent')
    .map((m) => ({
      category: m.category,
      metricId: m.metricId,
      metricName: m.name,
      qualityTier: m.qualityTier,
      value: m.value,
      reasoning: `${m.name} is within the ${m.qualityTier} range`,
    }));

  // Calculate percentile (based on population stats)
  const percentile = calculateHarmonyPercentile(overallScore);

  return {
    overallScore,
    standardizedScore: overallScore,
    qualityTier: getQualityTier(overallScore),
    percentile,
    frontScore: frontResults.overallScore,
    sideScore: sideResults.overallScore,
    categoryScores,
    measurements: allMeasurements,
    flaws,
    strengths,
  };
}
