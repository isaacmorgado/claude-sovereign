/**
 * Scoring Accuracy Test API Route
 * Tests the FaceIQ-compatible scoring system with mock landmark data
 *
 * GET /api/test-scoring
 */

import { NextResponse } from 'next/server';
import { LandmarkPoint } from '@/lib/landmarks';
import {
  analyzeFrontProfile,
  analyzeSideProfile,
  analyzeHarmony,
  calculateFaceIQScore,
  getMetricConfigForDemographics,
  Gender,
  Ethnicity,
} from '@/lib/faceiq-scoring';

// ============================================
// MOCK LANDMARK DATA (from landmarks-3d-2.json 2D coords)
// ============================================

// Idealized mock landmarks with proper proportions
// Total face height ~450 (trichion to menton), divided into thirds:
// - Upper third (trichion to nasal_base): ~150 (33%)
// - Middle third (nasal_base to subnasale): ~150 (33%)
// - Lower third (subnasale to menton): ~150 (33%)
// Bizygomatic width: ~300 (for FWHR ~2.0)
const MOCK_FRONT_LANDMARKS: LandmarkPoint[] = [
  // Head - y=100 is top
  { id: 'trichion', label: 'Hairline', medicalTerm: 'Trichion', description: '', x: 512, y: 100, category: 'Head' },

  // Eyes at y ~280 - corrected for realistic proportions
  // Bizygomatic width = 360px (692-332)
  // Eye separation ratio ideal = 0.45-0.50 → intercanthal = 360 * 0.47 = 170px
  // One eye apart test ideal = 1.0 → eye width = intercanthal = 170px... too wide
  // Compromise: eye width = 55px, intercanthal = 55px (one eye apart = 1.0)
  // This gives eye sep ratio = 55/360 = 0.15... still low
  // Actually need: intercanthal 162px for 0.45 ratio, but eye width 55px for realism
  // So one eye apart = 162/55 = 2.9... also unrealistic
  // Real human: intercanthal ~30mm, eye width ~28mm, bizygomatic ~140mm
  // Ratio: 30/140 = 0.21, one eye apart = 30/28 = 1.07
  // Scale to our 360px bizygomatic: intercanthal = 77px, eye width = 72px
  // Left eye: center at 512 - 77/2 - 36 = 437, spans 401-473
  // Right eye: center at 512 + 77/2 + 36 = 587, spans 551-623
  { id: 'left_pupila', label: 'Left Pupil', medicalTerm: 'Left Pupila', description: '', x: 437, y: 280, category: 'Eyes - Left' },
  { id: 'left_canthus_medialis', label: 'Left Medial Canthus', medicalTerm: '', description: '', x: 473, y: 282, category: 'Eyes - Left' },
  { id: 'left_canthus_lateralis', label: 'Left Lateral Canthus', medicalTerm: '', description: '', x: 401, y: 278, category: 'Eyes - Left' },
  { id: 'left_palpebra_superior', label: 'Left Upper Eyelid', medicalTerm: '', description: '', x: 437, y: 268, category: 'Eyes - Left' },
  { id: 'left_palpebra_inferior', label: 'Left Lower Eyelid', medicalTerm: '', description: '', x: 437, y: 292, category: 'Eyes - Left' },

  { id: 'right_pupila', label: 'Right Pupil', medicalTerm: 'Right Pupila', description: '', x: 587, y: 280, category: 'Eyes - Right' },
  { id: 'right_canthus_medialis', label: 'Right Medial Canthus', medicalTerm: '', description: '', x: 551, y: 282, category: 'Eyes - Right' },
  { id: 'right_canthus_lateralis', label: 'Right Lateral Canthus', medicalTerm: '', description: '', x: 623, y: 278, category: 'Eyes - Right' },
  { id: 'right_palpebra_superior', label: 'Right Upper Eyelid', medicalTerm: '', description: '', x: 587, y: 268, category: 'Eyes - Right' },
  { id: 'right_palpebra_inferior', label: 'Right Lower Eyelid', medicalTerm: '', description: '', x: 587, y: 292, category: 'Eyes - Right' },

  // Nose - nasal_base at y=250 (upper/middle third boundary)
  { id: 'nasal_base', label: 'Nasal Base', medicalTerm: '', description: '', x: 512, y: 250, category: 'Nose' },
  // subnasale at y=400 (middle/lower third boundary)
  { id: 'subnasale', label: 'Subnasale', medicalTerm: '', description: '', x: 512, y: 400, category: 'Nose' },
  { id: 'left_ala_nasi', label: 'Left Nose Side', medicalTerm: '', description: '', x: 475, y: 395, category: 'Nose' },
  { id: 'right_ala_nasi', label: 'Right Nose Side', medicalTerm: '', description: '', x: 549, y: 395, category: 'Nose' },

  // Mouth
  { id: 'labrale_superius', label: "Cupid's Bow", medicalTerm: '', description: '', x: 512, y: 430, category: 'Mouth' },
  { id: 'labrale_inferius', label: 'Lower Lip', medicalTerm: '', description: '', x: 512, y: 470, category: 'Mouth' },
  { id: 'left_cheilion', label: 'Left Mouth Corner', medicalTerm: '', description: '', x: 460, y: 450, category: 'Mouth' },
  { id: 'right_cheilion', label: 'Right Mouth Corner', medicalTerm: '', description: '', x: 564, y: 450, category: 'Mouth' },

  // Jaw
  { id: 'left_gonion_superior', label: 'Left Upper Jaw Angle', medicalTerm: '', description: '', x: 340, y: 420, category: 'Jaw' },
  { id: 'right_gonion_superior', label: 'Right Upper Jaw Angle', medicalTerm: '', description: '', x: 684, y: 420, category: 'Jaw' },
  { id: 'left_gonion_inferior', label: 'Left Lower Jaw Angle', medicalTerm: '', description: '', x: 370, y: 490, category: 'Jaw' },
  { id: 'right_gonion_inferior', label: 'Right Lower Jaw Angle', medicalTerm: '', description: '', x: 654, y: 490, category: 'Jaw' },

  // Chin - menton at y=550 (bottom of face)
  { id: 'menton', label: 'Chin Bottom', medicalTerm: '', description: '', x: 512, y: 550, category: 'Chin' },
  { id: 'left_mentum_lateralis', label: 'Left Chin', medicalTerm: '', description: '', x: 450, y: 530, category: 'Chin' },
  { id: 'right_mentum_lateralis', label: 'Right Chin', medicalTerm: '', description: '', x: 574, y: 530, category: 'Chin' },

  // Face Width - bizygomatic at ~300 width for FWHR ~2.0
  // Upper face height = nasal_base to labrale_superius = 430-250 = 180
  // So width should be 180 * 2 = 360 for FWHR 2.0
  { id: 'left_zygion', label: 'Left Cheekbone', medicalTerm: '', description: '', x: 332, y: 320, category: 'Face Width' },
  { id: 'right_zygion', label: 'Right Cheekbone', medicalTerm: '', description: '', x: 692, y: 320, category: 'Face Width' },
  { id: 'left_temporal', label: 'Left Temple', medicalTerm: '', description: '', x: 350, y: 230, category: 'Face Width' },
  { id: 'right_temporal', label: 'Right Temple', medicalTerm: '', description: '', x: 674, y: 230, category: 'Face Width' },
];

const MOCK_SIDE_LANDMARKS: LandmarkPoint[] = [
  { id: 'tragus', label: 'Tragus', medicalTerm: '', description: '', x: 509, y: 395, category: 'Ear' },
  { id: 'intertragicNotch', label: 'Intertragic Notch', medicalTerm: '', description: '', x: 511, y: 412, category: 'Ear' },
  { id: 'porion', label: 'Porion', medicalTerm: '', description: '', x: 505, y: 380, category: 'Ear' },
  { id: 'glabella', label: 'Glabella', medicalTerm: '', description: '', x: 819, y: 288, category: 'Forehead' },
  { id: 'trichion', label: 'Hairline', medicalTerm: '', description: '', x: 780, y: 200, category: 'Cranium' },
  { id: 'nasion', label: 'Nasion', medicalTerm: '', description: '', x: 814, y: 342, category: 'Nose' },
  { id: 'pronasale', label: 'Nose Tip', medicalTerm: '', description: '', x: 870, y: 460, category: 'Nose' },
  { id: 'subnasale', label: 'Subnasale', medicalTerm: '', description: '', x: 823, y: 483, category: 'Nose' },
  { id: 'columella', label: 'Columella', medicalTerm: '', description: '', x: 845, y: 475, category: 'Nose' },
  { id: 'rhinion', label: 'Rhinion', medicalTerm: '', description: '', x: 835, y: 400, category: 'Nose' },
  { id: 'supratip', label: 'Supratip', medicalTerm: '', description: '', x: 855, y: 445, category: 'Nose' },
  { id: 'infratip', label: 'Infratip', medicalTerm: '', description: '', x: 860, y: 470, category: 'Nose' },
  { id: 'orbitale', label: 'Orbitale', medicalTerm: '', description: '', x: 780, y: 370, category: 'Eye Region' },
  { id: 'cornealApex', label: 'Corneal Apex', medicalTerm: '', description: '', x: 800, y: 350, category: 'Eye Region' },
  { id: 'labraleSuperius', label: 'Upper Lip', medicalTerm: '', description: '', x: 835, y: 510, category: 'Lips' },
  { id: 'labraleInferius', label: 'Lower Lip', medicalTerm: '', description: '', x: 830, y: 540, category: 'Lips' },
  { id: 'sublabiale', label: 'Sublabiale', medicalTerm: '', description: '', x: 784, y: 584, category: 'Lips' },
  { id: 'cheilion', label: 'Mouth Corner', medicalTerm: '', description: '', x: 750, y: 525, category: 'Lips' },
  { id: 'pogonion', label: 'Chin Point', medicalTerm: '', description: '', x: 810, y: 620, category: 'Chin' },
  { id: 'menton', label: 'Chin Bottom', medicalTerm: '', description: '', x: 747, y: 648, category: 'Chin' },
  { id: 'gonionTop', label: 'Gonion Top', medicalTerm: '', description: '', x: 524, y: 517, category: 'Jaw' },
  { id: 'gonionBottom', label: 'Gonion Bottom', medicalTerm: '', description: '', x: 577, y: 587, category: 'Jaw' },
  { id: 'cervicalPoint', label: 'Cervical Point', medicalTerm: '', description: '', x: 631, y: 646, category: 'Neck' },
  { id: 'neckPoint', label: 'Neck Point', medicalTerm: '', description: '', x: 562, y: 804, category: 'Neck' },
];

// ============================================
// TEST DEFINITIONS
// ============================================

interface TestResult {
  name: string;
  passed: boolean;
  details: Record<string, unknown>;
  error?: string;
}

interface MetricTest {
  metricId: string;
  description: string;
  testValue: number;
  gender: Gender;
  ethnicity: Ethnicity;
  expectedScoreMin: number;
}

const METRIC_TESTS: MetricTest[] = [
  // FWHR - ideal is ~2.0 for white males
  { metricId: 'faceWidthToHeight', description: 'FWHR at ideal (2.0)', testValue: 2.0, gender: 'male', ethnicity: 'white', expectedScoreMin: 9.0 },
  { metricId: 'faceWidthToHeight', description: 'FWHR slightly low (1.85)', testValue: 1.85, gender: 'male', ethnicity: 'white', expectedScoreMin: 5.0 },
  // Canthal tilt - ideal is 4-8° for most
  { metricId: 'lateralCanthalTilt', description: 'Positive tilt (6°)', testValue: 6, gender: 'male', ethnicity: 'white', expectedScoreMin: 9.0 },
  { metricId: 'lateralCanthalTilt', description: 'Negative tilt (-2°)', testValue: -2, gender: 'male', ethnicity: 'white', expectedScoreMin: 1.0 },
  // Eye aspect ratio - width/height, ideal ~3.0-3.5 (almond eyes)
  { metricId: 'eyeAspectRatio', description: 'Ideal eye aspect (3.2)', testValue: 3.2, gender: 'male', ethnicity: 'white', expectedScoreMin: 9.0 },
  // Nasal index - ethnicity-specific
  { metricId: 'nasalIndex', description: 'White male ideal (70)', testValue: 70, gender: 'male', ethnicity: 'white', expectedScoreMin: 9.0 },
  { metricId: 'nasalIndex', description: 'Black male ideal (92)', testValue: 92, gender: 'male', ethnicity: 'black', expectedScoreMin: 8.0 },
  // Jaw width ratio - ideal ~0.80 for white males
  { metricId: 'jawWidthRatio', description: 'Ideal jaw width (0.80)', testValue: 0.80, gender: 'male', ethnicity: 'white', expectedScoreMin: 8.0 },
];

// ============================================
// TEST RUNNER
// ============================================

export async function GET() {
  const results: TestResult[] = [];
  let passedTests = 0;
  let failedTests = 0;

  // ========================================
  // TEST 1: Front Profile Analysis
  // ========================================
  const demographicTests: Array<{ name: string; gender: Gender; ethnicity: Ethnicity; expectedRange: [number, number] }> = [
    { name: 'Male - White', gender: 'male', ethnicity: 'white', expectedRange: [5, 9] },
    { name: 'Female - White', gender: 'female', ethnicity: 'white', expectedRange: [4, 9] },
    { name: 'Male - Black', gender: 'male', ethnicity: 'black', expectedRange: [4, 9] },
    { name: 'Male - East Asian', gender: 'male', ethnicity: 'east_asian', expectedRange: [4, 9] },
  ];

  for (const test of demographicTests) {
    try {
      const result = analyzeFrontProfile(MOCK_FRONT_LANDMARKS, test.gender, test.ethnicity);
      const passed = result.overallScore >= test.expectedRange[0] && result.overallScore <= test.expectedRange[1];

      results.push({
        name: `Front Profile: ${test.name}`,
        passed,
        details: {
          overallScore: result.overallScore,
          measurementCount: result.measurements.length,
          expectedRange: test.expectedRange,
          topStrengths: result.measurements
            .sort((a, b) => b.score - a.score)
            .slice(0, 3)
            .map(m => ({ name: m.name, score: m.score, value: m.value })),
          topFlaws: result.measurements
            .sort((a, b) => a.score - b.score)
            .slice(0, 3)
            .map(m => ({ name: m.name, score: m.score, value: m.value, deviation: m.deviation })),
        },
      });

      if (passed) passedTests++;
      else failedTests++;
    } catch (error) {
      results.push({
        name: `Front Profile: ${test.name}`,
        passed: false,
        details: {},
        error: String(error),
      });
      failedTests++;
    }
  }

  // ========================================
  // TEST 2: Side Profile Analysis
  // ========================================
  for (const test of demographicTests.slice(0, 2)) {
    try {
      const result = analyzeSideProfile(MOCK_SIDE_LANDMARKS, test.gender, test.ethnicity);
      const passed = result.measurements.length >= 3; // At least some measurements

      results.push({
        name: `Side Profile: ${test.name}`,
        passed,
        details: {
          overallScore: result.overallScore,
          measurementCount: result.measurements.length,
          measurements: result.measurements.slice(0, 5).map(m => ({
            name: m.name,
            score: m.score,
            value: m.value,
          })),
        },
      });

      if (passed) passedTests++;
      else failedTests++;
    } catch (error) {
      results.push({
        name: `Side Profile: ${test.name}`,
        passed: false,
        details: {},
        error: String(error),
      });
      failedTests++;
    }
  }

  // ========================================
  // TEST 3: Individual Metric Scoring
  // ========================================
  for (const test of METRIC_TESTS) {
    try {
      const config = getMetricConfigForDemographics(test.metricId, test.gender, test.ethnicity);

      if (!config) {
        results.push({
          name: `Metric: ${test.description}`,
          passed: false,
          details: { metricId: test.metricId },
          error: 'Config not found',
        });
        failedTests++;
        continue;
      }

      const score = calculateFaceIQScore(test.testValue, config);
      const passed = score >= test.expectedScoreMin;

      results.push({
        name: `Metric: ${test.description}`,
        passed,
        details: {
          metricId: test.metricId,
          testValue: test.testValue,
          score,
          expectedMin: test.expectedScoreMin,
          idealRange: [config.idealMin, config.idealMax],
          hasBezierCurve: config.customCurve?.mode === 'custom',
        },
      });

      if (passed) passedTests++;
      else failedTests++;
    } catch (error) {
      results.push({
        name: `Metric: ${test.description}`,
        passed: false,
        details: { metricId: test.metricId },
        error: String(error),
      });
      failedTests++;
    }
  }

  // ========================================
  // TEST 4: Full Harmony Analysis
  // ========================================
  try {
    const harmony = analyzeHarmony(MOCK_FRONT_LANDMARKS, MOCK_SIDE_LANDMARKS, 'male', 'white');
    const passed = harmony.overallScore > 0 && harmony.measurements.length > 10;

    results.push({
      name: 'Full Harmony Analysis',
      passed,
      details: {
        overallScore: harmony.overallScore,
        frontScore: harmony.frontScore,
        sideScore: harmony.sideScore,
        qualityTier: harmony.qualityTier,
        percentile: harmony.percentile,
        measurementCount: harmony.measurements.length,
        flawCount: harmony.flaws.length,
        strengthCount: harmony.strengths.length,
        categoryScores: harmony.categoryScores,
        topFlaws: harmony.flaws.slice(0, 3).map(f => ({
          metric: f.metricName,
          severity: f.severity,
          reason: f.reasoning,
        })),
        topStrengths: harmony.strengths.slice(0, 3).map(s => ({
          metric: s.metricName,
          tier: s.qualityTier,
          reason: s.reasoning,
        })),
      },
    });

    if (passed) passedTests++;
    else failedTests++;
  } catch (error) {
    results.push({
      name: 'Full Harmony Analysis',
      passed: false,
      details: {},
      error: String(error),
    });
    failedTests++;
  }

  // ========================================
  // TEST 5: Bezier Curve Verification
  // ========================================
  const bezierMetrics = ['faceWidthToHeight', 'lowerThirdProportion', 'eyeAspectRatio', 'totalFacialWidthToHeight', 'cheekboneHeight'];

  for (const metricId of bezierMetrics) {
    try {
      const config = getMetricConfigForDemographics(metricId, 'male', 'white');

      if (!config) {
        results.push({
          name: `Bezier: ${metricId}`,
          passed: false,
          details: {},
          error: 'Config not found',
        });
        failedTests++;
        continue;
      }

      const hasBezier = config.customCurve?.mode === 'custom';
      const idealMid = (config.idealMin + config.idealMax) / 2;
      const scoreAtIdeal = calculateFaceIQScore(idealMid, config);
      const scoreAtMin = calculateFaceIQScore(config.rangeMin, config);
      const scoreAtMax = calculateFaceIQScore(config.rangeMax, config);

      // Verify curve makes sense: ideal should score highest
      const passed = scoreAtIdeal >= 9 && scoreAtMin < scoreAtIdeal && scoreAtMax < scoreAtIdeal;

      results.push({
        name: `Bezier: ${metricId}`,
        passed,
        details: {
          hasBezierCurve: hasBezier,
          idealRange: [config.idealMin, config.idealMax],
          scoreAtIdeal: { value: idealMid, score: scoreAtIdeal },
          scoreAtMin: { value: config.rangeMin, score: scoreAtMin },
          scoreAtMax: { value: config.rangeMax, score: scoreAtMax },
        },
      });

      if (passed) passedTests++;
      else failedTests++;
    } catch (error) {
      results.push({
        name: `Bezier: ${metricId}`,
        passed: false,
        details: {},
        error: String(error),
      });
      failedTests++;
    }
  }

  // ========================================
  // TEST 6: Demographic Overrides
  // ========================================
  const overrideTestMetrics = ['nasalIndex', 'jawWidthRatio', 'lateralCanthalTilt'];
  const demographics: Array<{ gender: Gender; ethnicity: Ethnicity }> = [
    { gender: 'male', ethnicity: 'white' },
    { gender: 'male', ethnicity: 'black' },
    { gender: 'female', ethnicity: 'white' },
    { gender: 'female', ethnicity: 'east_asian' },
  ];

  for (const metricId of overrideTestMetrics) {
    const ranges: Array<{ demo: string; min: number; max: number }> = [];

    for (const demo of demographics) {
      const config = getMetricConfigForDemographics(metricId, demo.gender, demo.ethnicity);
      if (config) {
        ranges.push({
          demo: `${demo.gender}/${demo.ethnicity}`,
          min: config.idealMin,
          max: config.idealMax,
        });
      }
    }

    // Check if there's variation between demographics
    const uniqueRanges = new Set(ranges.map(r => `${r.min}-${r.max}`));
    const hasVariation = uniqueRanges.size > 1;

    results.push({
      name: `Demographic Override: ${metricId}`,
      passed: hasVariation,
      details: {
        hasVariation,
        ranges,
      },
    });

    if (hasVariation) passedTests++;
    else failedTests++;
  }

  // ========================================
  // SUMMARY
  // ========================================
  const successRate = passedTests / (passedTests + failedTests) * 100;

  return NextResponse.json({
    summary: {
      passed: passedTests,
      failed: failedTests,
      total: passedTests + failedTests,
      successRate: `${successRate.toFixed(1)}%`,
    },
    results,
  });
}
