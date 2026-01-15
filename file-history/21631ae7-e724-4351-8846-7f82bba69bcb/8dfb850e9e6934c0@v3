#!/usr/bin/env npx ts-node
/**
 * Scoring Accuracy Test Script
 * Tests the FaceIQ-compatible scoring system with mock landmark data
 *
 * Run with: npx ts-node scripts/test-scoring.ts
 */

/* eslint-disable @typescript-eslint/no-require-imports */
const {
  analyzeFrontProfile,
  analyzeSideProfile,
  analyzeHarmony,
  calculateFaceIQScore,
  getMetricConfigForDemographics,
} = require('../src/lib/faceiq-scoring');

type Gender = 'male' | 'female';
type Ethnicity = 'white' | 'black' | 'east_asian' | 'south_asian' | 'hispanic' | 'middle_eastern' | 'native_american' | 'pacific_islander' | 'other';

// Direct type definitions
interface LandmarkPoint {
  id: string;
  label: string;
  medicalTerm: string;
  description: string;
  x: number;
  y: number;
  category: string;
}

// ============================================
// MOCK LANDMARK DATA (from landmarks-3d-2.json 2D coords)
// Converted to LandmarkPoint format
// ============================================

const MOCK_FRONT_LANDMARKS: LandmarkPoint[] = [
  // Head
  { id: 'trichion', label: 'Hairline', medicalTerm: 'Trichion', description: '', x: 509, y: 180, category: 'Head' },

  // Eyes - Left (NOTE: In 2D coordinates, left/right are flipped from viewer perspective)
  { id: 'left_pupila', label: 'Left Pupil', medicalTerm: 'Left Pupila', description: '', x: 422, y: 339, category: 'Eyes - Left' },
  { id: 'left_canthus_medialis', label: 'Left Medial Canthus', medicalTerm: '', description: '', x: 458, y: 343, category: 'Eyes - Left' },
  { id: 'left_canthus_lateralis', label: 'Left Lateral Canthus', medicalTerm: '', description: '', x: 382, y: 339, category: 'Eyes - Left' },
  { id: 'left_palpebra_superior', label: 'Left Upper Eyelid', medicalTerm: '', description: '', x: 420, y: 330, category: 'Eyes - Left' },
  { id: 'left_palpebra_inferior', label: 'Left Lower Eyelid', medicalTerm: '', description: '', x: 420, y: 348, category: 'Eyes - Left' },

  // Eyes - Right
  { id: 'right_pupila', label: 'Right Pupil', medicalTerm: 'Right Pupila', description: '', x: 603, y: 340, category: 'Eyes - Right' },
  { id: 'right_canthus_medialis', label: 'Right Medial Canthus', medicalTerm: '', description: '', x: 568, y: 341, category: 'Eyes - Right' },
  { id: 'right_canthus_lateralis', label: 'Right Lateral Canthus', medicalTerm: '', description: '', x: 641, y: 337, category: 'Eyes - Right' },
  { id: 'right_palpebra_superior', label: 'Right Upper Eyelid', medicalTerm: '', description: '', x: 605, y: 331, category: 'Eyes - Right' },
  { id: 'right_palpebra_inferior', label: 'Right Lower Eyelid', medicalTerm: '', description: '', x: 605, y: 349, category: 'Eyes - Right' },

  // Nose
  { id: 'nasal_base', label: 'Nasal Base', medicalTerm: '', description: '', x: 513, y: 360, category: 'Nose' },
  { id: 'subnasale', label: 'Subnasale', medicalTerm: '', description: '', x: 513, y: 450, category: 'Nose' },
  { id: 'left_ala_nasi', label: 'Left Nose Side', medicalTerm: '', description: '', x: 465, y: 448, category: 'Nose' },
  { id: 'right_ala_nasi', label: 'Right Nose Side', medicalTerm: '', description: '', x: 563, y: 451, category: 'Nose' },

  // Mouth
  { id: 'labrale_superius', label: "Cupid's Bow", medicalTerm: '', description: '', x: 513, y: 490, category: 'Mouth' },
  { id: 'labrale_inferius', label: 'Lower Lip', medicalTerm: '', description: '', x: 513, y: 535, category: 'Mouth' },
  { id: 'left_cheilion', label: 'Left Mouth Corner', medicalTerm: '', description: '', x: 442, y: 531, category: 'Mouth' },
  { id: 'right_cheilion', label: 'Right Mouth Corner', medicalTerm: '', description: '', x: 584, y: 532, category: 'Mouth' },

  // Jaw
  { id: 'left_gonion_superior', label: 'Left Upper Jaw Angle', medicalTerm: '', description: '', x: 320, y: 480, category: 'Jaw' },
  { id: 'right_gonion_superior', label: 'Right Upper Jaw Angle', medicalTerm: '', description: '', x: 706, y: 482, category: 'Jaw' },
  { id: 'left_gonion_inferior', label: 'Left Lower Jaw Angle', medicalTerm: '', description: '', x: 351, y: 553, category: 'Jaw' },
  { id: 'right_gonion_inferior', label: 'Right Lower Jaw Angle', medicalTerm: '', description: '', x: 678, y: 546, category: 'Jaw' },

  // Chin
  { id: 'menton', label: 'Chin Bottom', medicalTerm: '', description: '', x: 512, y: 644, category: 'Chin' },
  { id: 'left_mentum_lateralis', label: 'Left Chin', medicalTerm: '', description: '', x: 438, y: 631, category: 'Chin' },
  { id: 'right_mentum_lateralis', label: 'Right Chin', medicalTerm: '', description: '', x: 593, y: 620, category: 'Chin' },

  // Face Width
  { id: 'left_zygion', label: 'Left Cheekbone', medicalTerm: '', description: '', x: 308, y: 355, category: 'Face Width' },
  { id: 'right_zygion', label: 'Right Cheekbone', medicalTerm: '', description: '', x: 717, y: 361, category: 'Face Width' },
  { id: 'left_temporal', label: 'Left Temple', medicalTerm: '', description: '', x: 330, y: 280, category: 'Face Width' },
  { id: 'right_temporal', label: 'Right Temple', medicalTerm: '', description: '', x: 695, y: 282, category: 'Face Width' },
];

const MOCK_SIDE_LANDMARKS: LandmarkPoint[] = [
  // Ear
  { id: 'tragus', label: 'Tragus', medicalTerm: '', description: '', x: 509, y: 395, category: 'Ear' },
  { id: 'intertragicNotch', label: 'Intertragic Notch', medicalTerm: '', description: '', x: 511, y: 412, category: 'Ear' },
  { id: 'porion', label: 'Porion', medicalTerm: '', description: '', x: 505, y: 380, category: 'Ear' },

  // Forehead
  { id: 'glabella', label: 'Glabella', medicalTerm: '', description: '', x: 819, y: 288, category: 'Forehead' },
  { id: 'trichion', label: 'Hairline', medicalTerm: '', description: '', x: 780, y: 200, category: 'Cranium' },

  // Nose
  { id: 'nasion', label: 'Nasion', medicalTerm: '', description: '', x: 814, y: 342, category: 'Nose' },
  { id: 'pronasale', label: 'Nose Tip', medicalTerm: '', description: '', x: 870, y: 460, category: 'Nose' },
  { id: 'subnasale', label: 'Subnasale', medicalTerm: '', description: '', x: 823, y: 483, category: 'Nose' },
  { id: 'columella', label: 'Columella', medicalTerm: '', description: '', x: 845, y: 475, category: 'Nose' },
  { id: 'rhinion', label: 'Rhinion', medicalTerm: '', description: '', x: 835, y: 400, category: 'Nose' },
  { id: 'supratip', label: 'Supratip', medicalTerm: '', description: '', x: 855, y: 445, category: 'Nose' },
  { id: 'infratip', label: 'Infratip', medicalTerm: '', description: '', x: 860, y: 470, category: 'Nose' },

  // Eye Region
  { id: 'orbitale', label: 'Orbitale', medicalTerm: '', description: '', x: 780, y: 370, category: 'Eye Region' },
  { id: 'cornealApex', label: 'Corneal Apex', medicalTerm: '', description: '', x: 800, y: 350, category: 'Eye Region' },

  // Lips
  { id: 'labraleSuperius', label: 'Upper Lip', medicalTerm: '', description: '', x: 835, y: 510, category: 'Lips' },
  { id: 'labraleInferius', label: 'Lower Lip', medicalTerm: '', description: '', x: 830, y: 540, category: 'Lips' },
  { id: 'sublabiale', label: 'Sublabiale', medicalTerm: '', description: '', x: 784, y: 584, category: 'Lips' },
  { id: 'cheilion', label: 'Mouth Corner', medicalTerm: '', description: '', x: 750, y: 525, category: 'Lips' },

  // Chin
  { id: 'pogonion', label: 'Chin Point', medicalTerm: '', description: '', x: 810, y: 620, category: 'Chin' },
  { id: 'menton', label: 'Chin Bottom', medicalTerm: '', description: '', x: 747, y: 648, category: 'Chin' },

  // Jaw
  { id: 'gonionTop', label: 'Gonion Top', medicalTerm: '', description: '', x: 524, y: 517, category: 'Jaw' },
  { id: 'gonionBottom', label: 'Gonion Bottom', medicalTerm: '', description: '', x: 577, y: 587, category: 'Jaw' },

  // Neck
  { id: 'cervicalPoint', label: 'Cervical Point', medicalTerm: '', description: '', x: 631, y: 646, category: 'Neck' },
  { id: 'neckPoint', label: 'Neck Point', medicalTerm: '', description: '', x: 562, y: 804, category: 'Neck' },
];

// ============================================
// TEST UTILITIES
// ============================================

const PASS = '\x1b[32m✓\x1b[0m';
const FAIL = '\x1b[31m✗\x1b[0m';
const WARN = '\x1b[33m⚠\x1b[0m';

function formatScore(score: number): string {
  if (score >= 9) return `\x1b[32m${score.toFixed(2)}\x1b[0m`; // Green
  if (score >= 7) return `\x1b[33m${score.toFixed(2)}\x1b[0m`; // Yellow
  return `\x1b[31m${score.toFixed(2)}\x1b[0m`; // Red
}

function formatDeviation(deviation: number, direction: string): string {
  const sign = direction === 'above' ? '+' : direction === 'below' ? '-' : '';
  const color = Math.abs(deviation) > 20 ? '\x1b[31m' : Math.abs(deviation) > 10 ? '\x1b[33m' : '\x1b[32m';
  return `${color}${sign}${Math.abs(deviation).toFixed(1)}%\x1b[0m`;
}

// ============================================
// TEST CASES
// ============================================

interface TestCase {
  name: string;
  gender: Gender;
  ethnicity: Ethnicity;
  expectedScoreRange: [number, number]; // [min, max] expected overall score
}

const TEST_CASES: TestCase[] = [
  { name: 'Male - White (Neoclassical ideals)', gender: 'male', ethnicity: 'white', expectedScoreRange: [6, 9] },
  { name: 'Female - White', gender: 'female', ethnicity: 'white', expectedScoreRange: [5, 8.5] },
  { name: 'Male - Black', gender: 'male', ethnicity: 'black', expectedScoreRange: [5, 8] },
  { name: 'Male - East Asian', gender: 'male', ethnicity: 'east_asian', expectedScoreRange: [5, 8] },
  { name: 'Female - East Asian', gender: 'female', ethnicity: 'east_asian', expectedScoreRange: [5, 8] },
];

// ============================================
// INDIVIDUAL METRIC TESTS
// ============================================

interface MetricTest {
  metricId: string;
  description: string;
  testValue: number;
  gender: Gender;
  ethnicity: Ethnicity;
  expectedScoreMin: number; // Minimum acceptable score
}

const METRIC_TESTS: MetricTest[] = [
  // Face proportions - test ideal values
  { metricId: 'faceWidthToHeight', description: 'FWHR at ideal (1.9)', testValue: 1.9, gender: 'male', ethnicity: 'white', expectedScoreMin: 9.0 },
  { metricId: 'faceWidthToHeight', description: 'FWHR slightly low (1.7)', testValue: 1.7, gender: 'male', ethnicity: 'white', expectedScoreMin: 6.0 },

  // Canthal tilt tests
  { metricId: 'lateralCanthalTilt', description: 'Positive tilt (4°)', testValue: 4, gender: 'male', ethnicity: 'white', expectedScoreMin: 8.0 },
  { metricId: 'lateralCanthalTilt', description: 'Negative tilt (-2°)', testValue: -2, gender: 'male', ethnicity: 'white', expectedScoreMin: 4.0 },

  // Eye aspect ratio
  { metricId: 'eyeAspectRatio', description: 'Ideal eye aspect (0.32)', testValue: 0.32, gender: 'male', ethnicity: 'white', expectedScoreMin: 9.0 },

  // Nasal index by ethnicity
  { metricId: 'nasalIndex', description: 'White male ideal (70)', testValue: 70, gender: 'male', ethnicity: 'white', expectedScoreMin: 9.0 },
  { metricId: 'nasalIndex', description: 'Black male ideal (90)', testValue: 90, gender: 'male', ethnicity: 'black', expectedScoreMin: 8.0 },

  // Jaw width ratio
  { metricId: 'jawWidthRatio', description: 'Ideal jaw width (0.75)', testValue: 0.75, gender: 'male', ethnicity: 'white', expectedScoreMin: 8.0 },
];

// ============================================
// MAIN TEST RUNNER
// ============================================

async function runTests() {
  console.log('\n' + '='.repeat(70));
  console.log('  LOOKSMAXX SCORING ACCURACY TEST SUITE');
  console.log('='.repeat(70) + '\n');

  let passedTests = 0;
  let failedTests = 0;
  let warnings = 0;

  // ========================================
  // TEST 1: Front Profile Analysis
  // ========================================
  console.log('\n📋 TEST 1: Front Profile Analysis\n');
  console.log('-'.repeat(50));

  for (const testCase of TEST_CASES) {
    console.log(`\n  Testing: ${testCase.name}`);

    try {
      const result = analyzeFrontProfile(MOCK_FRONT_LANDMARKS, testCase.gender, testCase.ethnicity);

      console.log(`  Overall Score: ${formatScore(result.overallScore)} (expected: ${testCase.expectedScoreRange[0]}-${testCase.expectedScoreRange[1]})`);
      console.log(`  Measurements calculated: ${result.measurements.length}`);

      // Check score is in expected range
      if (result.overallScore >= testCase.expectedScoreRange[0] && result.overallScore <= testCase.expectedScoreRange[1]) {
        console.log(`  ${PASS} Score within expected range`);
        passedTests++;
      } else {
        console.log(`  ${FAIL} Score outside expected range!`);
        failedTests++;
      }

      // Show top 3 strengths and flaws
      const sorted = [...result.measurements].sort((a, b) => b.score - a.score);
      console.log('\n  Top 3 Strengths:');
      sorted.slice(0, 3).forEach(m => {
        console.log(`    - ${m.name}: ${formatScore(m.score)} (value: ${m.value.toFixed(2)})`);
      });

      console.log('\n  Top 3 Flaws:');
      sorted.slice(-3).reverse().forEach(m => {
        console.log(`    - ${m.name}: ${formatScore(m.score)} ${formatDeviation(m.deviation, m.deviationDirection)}`);
      });

    } catch (error) {
      console.log(`  ${FAIL} Error: ${error}`);
      failedTests++;
    }
  }

  // ========================================
  // TEST 2: Side Profile Analysis
  // ========================================
  console.log('\n\n📋 TEST 2: Side Profile Analysis\n');
  console.log('-'.repeat(50));

  const sideCases = TEST_CASES.slice(0, 2); // Just test male/female white
  for (const testCase of sideCases) {
    console.log(`\n  Testing: ${testCase.name}`);

    try {
      const result = analyzeSideProfile(MOCK_SIDE_LANDMARKS, testCase.gender, testCase.ethnicity);

      console.log(`  Overall Score: ${formatScore(result.overallScore)}`);
      console.log(`  Measurements calculated: ${result.measurements.length}`);

      if (result.measurements.length >= 5) {
        console.log(`  ${PASS} Sufficient measurements calculated`);
        passedTests++;
      } else {
        console.log(`  ${WARN} Only ${result.measurements.length} measurements - may need more landmarks`);
        warnings++;
      }

      // Show key side metrics
      console.log('\n  Key Side Metrics:');
      result.measurements.slice(0, 5).forEach((m: { name: string; score: number; value: number }) => {
        console.log(`    - ${m.name}: ${formatScore(m.score)} (value: ${m.value.toFixed(2)})`);
      });

    } catch (error) {
      console.log(`  ${FAIL} Error: ${error}`);
      failedTests++;
    }
  }

  // ========================================
  // TEST 3: Individual Metric Scoring
  // ========================================
  console.log('\n\n📋 TEST 3: Individual Metric Scoring (calculateFaceIQScore)\n');
  console.log('-'.repeat(50));

  for (const test of METRIC_TESTS) {
    const config = getMetricConfigForDemographics(test.metricId, test.gender, test.ethnicity);

    if (!config) {
      console.log(`  ${FAIL} ${test.description}: Metric config not found for ${test.metricId}`);
      failedTests++;
      continue;
    }

    const score = calculateFaceIQScore(test.testValue, config);
    const passed = score >= test.expectedScoreMin;

    console.log(`  ${passed ? PASS : FAIL} ${test.description}`);
    console.log(`      Value: ${test.testValue} | Score: ${formatScore(score)} | Expected min: ${test.expectedScoreMin}`);
    console.log(`      Ideal range: [${config.idealMin}, ${config.idealMax}]`);

    if (passed) {
      passedTests++;
    } else {
      failedTests++;
    }
  }

  // ========================================
  // TEST 4: Harmony Analysis (Combined)
  // ========================================
  console.log('\n\n📋 TEST 4: Full Harmony Analysis\n');
  console.log('-'.repeat(50));

  try {
    const harmony = analyzeHarmony(MOCK_FRONT_LANDMARKS, MOCK_SIDE_LANDMARKS, 'male', 'white');

    console.log(`\n  Overall Harmony Score: ${formatScore(harmony.overallScore)}`);
    console.log(`  Front Score: ${formatScore(harmony.frontScore)}`);
    console.log(`  Side Score: ${formatScore(harmony.sideScore)}`);
    console.log(`  Quality Tier: ${harmony.qualityTier}`);
    console.log(`  Percentile: ${harmony.percentile.toFixed(1)}%`);

    console.log('\n  Category Scores:');
    Object.entries(harmony.categoryScores).forEach(([cat, score]) => {
      console.log(`    - ${cat}: ${formatScore(score as number)}`);
    });

    console.log(`\n  Flaws identified: ${harmony.flaws.length}`);
    harmony.flaws.slice(0, 3).forEach((flaw: { metricName: string; severity: string; reasoning: string }) => {
      console.log(`    - ${flaw.metricName} (${flaw.severity}): ${flaw.reasoning}`);
    });

    console.log(`\n  Strengths identified: ${harmony.strengths.length}`);
    harmony.strengths.slice(0, 3).forEach((str: { metricName: string; qualityTier: string; reasoning: string }) => {
      console.log(`    - ${str.metricName} (${str.qualityTier}): ${str.reasoning}`);
    });

    if (harmony.overallScore > 0 && harmony.measurements.length > 10) {
      console.log(`\n  ${PASS} Harmony analysis completed successfully`);
      passedTests++;
    } else {
      console.log(`\n  ${FAIL} Harmony analysis incomplete`);
      failedTests++;
    }

  } catch (error) {
    console.log(`  ${FAIL} Error: ${error}`);
    failedTests++;
  }

  // ========================================
  // TEST 5: Bezier Curve Scoring
  // ========================================
  console.log('\n\n📋 TEST 5: Bezier Curve Scoring\n');
  console.log('-'.repeat(50));

  const bezierMetrics = ['faceWidthToHeight', 'lowerThirdProportion', 'eyeAspectRatio', 'totalFacialWidthToHeight', 'cheekboneHeight'];

  for (const metricId of bezierMetrics) {
    const config = getMetricConfigForDemographics(metricId, 'male', 'white');
    if (!config) {
      console.log(`  ${WARN} ${metricId}: Config not found`);
      warnings++;
      continue;
    }

    const hasBezier = config.customCurve?.mode === 'custom';
    const idealMid = (config.idealMin + config.idealMax) / 2;
    const scoreAtIdeal = calculateFaceIQScore(idealMid, config);
    const scoreAtMin = calculateFaceIQScore(config.rangeMin, config);
    const scoreAtMax = calculateFaceIQScore(config.rangeMax, config);

    console.log(`\n  ${metricId}:`);
    console.log(`    Bezier curve: ${hasBezier ? PASS + ' Yes' : WARN + ' No (using exponential)'}`);
    console.log(`    Score at ideal (${idealMid.toFixed(2)}): ${formatScore(scoreAtIdeal)}`);
    console.log(`    Score at min (${config.rangeMin.toFixed(2)}): ${formatScore(scoreAtMin)}`);
    console.log(`    Score at max (${config.rangeMax.toFixed(2)}): ${formatScore(scoreAtMax)}`);

    // Verify scoring curve makes sense
    if (scoreAtIdeal >= 9 && scoreAtMin < scoreAtIdeal && scoreAtMax < scoreAtIdeal) {
      console.log(`    ${PASS} Scoring curve behaves correctly`);
      passedTests++;
    } else {
      console.log(`    ${FAIL} Scoring curve may be incorrect`);
      failedTests++;
    }
  }

  // ========================================
  // TEST 6: Demographic Overrides
  // ========================================
  console.log('\n\n📋 TEST 6: Demographic Overrides\n');
  console.log('-'.repeat(50));

  const testMetrics = ['nasalIndex', 'jawWidthRatio', 'lateralCanthalTilt'];
  const demographics: Array<{ gender: Gender; ethnicity: Ethnicity }> = [
    { gender: 'male', ethnicity: 'white' },
    { gender: 'male', ethnicity: 'black' },
    { gender: 'female', ethnicity: 'white' },
    { gender: 'female', ethnicity: 'east_asian' },
  ];

  for (const metricId of testMetrics) {
    console.log(`\n  ${metricId} ideal ranges by demographic:`);

    let hasVariation = false;
    const ranges: string[] = [];

    for (const demo of demographics) {
      const config = getMetricConfigForDemographics(metricId, demo.gender, demo.ethnicity);
      if (config) {
        ranges.push(`[${config.idealMin.toFixed(1)}-${config.idealMax.toFixed(1)}]`);
        console.log(`    ${demo.gender}/${demo.ethnicity}: [${config.idealMin.toFixed(1)} - ${config.idealMax.toFixed(1)}]`);
      }
    }

    // Check if there's variation between demographics
    hasVariation = new Set(ranges).size > 1;
    if (hasVariation) {
      console.log(`    ${PASS} Demographic-specific ideal ranges working`);
      passedTests++;
    } else {
      console.log(`    ${WARN} No variation between demographics - may need more overrides`);
      warnings++;
    }
  }

  // ========================================
  // SUMMARY
  // ========================================
  console.log('\n\n' + '='.repeat(70));
  console.log('  TEST SUMMARY');
  console.log('='.repeat(70));
  console.log(`\n  ${PASS} Passed: ${passedTests}`);
  console.log(`  ${FAIL} Failed: ${failedTests}`);
  console.log(`  ${WARN} Warnings: ${warnings}`);
  console.log(`\n  Total: ${passedTests + failedTests + warnings} tests`);

  const successRate = (passedTests / (passedTests + failedTests)) * 100;
  console.log(`  Success Rate: ${successRate.toFixed(1)}%`);

  if (failedTests > 0) {
    console.log('\n  ⚠️  Some tests failed - review output above for details');
    process.exit(1);
  } else {
    console.log('\n  ✅ All tests passed!');
    process.exit(0);
  }
}

// Run tests
runTests().catch(console.error);
