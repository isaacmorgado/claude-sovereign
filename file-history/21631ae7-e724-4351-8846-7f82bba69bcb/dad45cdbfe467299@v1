#!/usr/bin/env npx tsx
/**
 * Comprehensive Male Analysis Test Suite
 * Tests all 8 male ethnicity overrides and male-specific scoring
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
type Ethnicity = 'white' | 'black' | 'east_asian' | 'south_asian' | 'hispanic' | 'middle_eastern' | 'native_american' | 'pacific_islander';

// ANSI color codes
const PASS = '\x1b[32m✓\x1b[0m';
const FAIL = '\x1b[31m✗\x1b[0m';
const WARN = '\x1b[33m⚠\x1b[0m';

const ALL_ETHNICITIES: Ethnicity[] = [
  'white', 'black', 'east_asian', 'south_asian',
  'hispanic', 'middle_eastern', 'native_american', 'pacific_islander'
];

// Key metrics that should have male-specific overrides
const MALE_SPECIFIC_METRICS = [
  'nasalIndex',
  'jawWidthRatio',
  'lateralCanthalTilt',
  'gonialAngle',
  'eyeAspectRatio',
  'bigonialWidth',
  'jawFrontalAngle',
  'faceWidthToHeight',
  'lowerToUpperLipRatio',
  'nasolabialAngle',
];

function formatRange(min: number, max: number): string {
  return `[${min.toFixed(2)}-${max.toFixed(2)}]`;
}

async function runTests() {
  console.log('\n' + '='.repeat(70));
  console.log('  COMPREHENSIVE MALE ANALYSIS TEST SUITE');
  console.log('='.repeat(70) + '\n');

  let passedTests = 0;
  let failedTests = 0;
  let warnings = 0;

  // ========================================
  // TEST 1: Male Ideal Range by Ethnicity
  // ========================================
  console.log('\n📋 TEST 1: Male Ideal Ranges by Ethnicity\n');
  console.log('-'.repeat(70));

  for (const metricId of MALE_SPECIFIC_METRICS) {
    console.log(`\n  ${metricId}:`);

    for (const ethnicity of ALL_ETHNICITIES) {
      const config = getMetricConfigForDemographics(metricId, 'male', ethnicity);

      if (!config) {
        console.log(`    ${WARN} ${ethnicity}: Config missing`);
        warnings++;
        continue;
      }

      console.log(`    ${PASS} ${ethnicity.padEnd(18)}: ${formatRange(config.idealMin, config.idealMax)}`);
      passedTests++;
    }
  }

  // ========================================
  // TEST 2: Male Ethnicity-Specific Variations
  // ========================================
  console.log('\n\n📋 TEST 2: Male Ethnicity-Specific Variations\n');
  console.log('-'.repeat(70));

  const keyMetrics = ['nasalIndex', 'gonialAngle', 'lowerToUpperLipRatio', 'lateralCanthalTilt'];

  for (const metricId of keyMetrics) {
    console.log(`\n  ${metricId} across male ethnicities:`);

    const ranges: { ethnicity: Ethnicity; min: number; max: number }[] = [];

    for (const ethnicity of ALL_ETHNICITIES) {
      const config = getMetricConfigForDemographics(metricId, 'male', ethnicity);
      if (config) {
        ranges.push({ ethnicity, min: config.idealMin, max: config.idealMax });
        console.log(`    ${ethnicity.padEnd(18)}: ${formatRange(config.idealMin, config.idealMax)}`);
      }
    }

    // Check for variation across ethnicities
    const uniqueRanges = new Set(ranges.map(r => `${r.min}-${r.max}`));
    if (uniqueRanges.size > 1) {
      console.log(`    ${PASS} Has ${uniqueRanges.size} distinct ranges across ethnicities`);
      passedTests++;
    } else {
      console.log(`    ${WARN} Same range for all ethnicities`);
      warnings++;
    }
  }

  // ========================================
  // TEST 3: Male Scoring at Ideal Values
  // ========================================
  console.log('\n\n📋 TEST 3: Male Scoring at Ideal Values\n');
  console.log('-'.repeat(70));

  const scoringTests = [
    { metric: 'nasalIndex', ethnicity: 'white' as Ethnicity, idealValue: 70 },
    { metric: 'nasalIndex', ethnicity: 'black' as Ethnicity, idealValue: 92 },
    { metric: 'nasalIndex', ethnicity: 'east_asian' as Ethnicity, idealValue: 83 },
    { metric: 'nasalIndex', ethnicity: 'south_asian' as Ethnicity, idealValue: 77 },
    { metric: 'gonialAngle', ethnicity: 'white' as Ethnicity, idealValue: 120 },
    { metric: 'gonialAngle', ethnicity: 'black' as Ethnicity, idealValue: 120 },
    { metric: 'lateralCanthalTilt', ethnicity: 'white' as Ethnicity, idealValue: 6 },
    { metric: 'lateralCanthalTilt', ethnicity: 'east_asian' as Ethnicity, idealValue: 10 },
    { metric: 'lateralCanthalTilt', ethnicity: 'hispanic' as Ethnicity, idealValue: 9 },
    { metric: 'lowerToUpperLipRatio', ethnicity: 'black' as Ethnicity, idealValue: 1.9 },
    { metric: 'lowerToUpperLipRatio', ethnicity: 'hispanic' as Ethnicity, idealValue: 1.7 },
  ];

  for (const test of scoringTests) {
    const config = getMetricConfigForDemographics(test.metric, 'male', test.ethnicity);
    if (!config) {
      console.log(`  ${FAIL} ${test.metric}/${test.ethnicity}: Config not found`);
      failedTests++;
      continue;
    }

    const score = calculateFaceIQScore(test.idealValue, config);
    // Pass if score equals maxScore (perfect) or >= 80% of maxScore (good)
    const threshold = config.maxScore * 0.8;
    const isPerfect = Math.abs(score - config.maxScore) < 0.01;
    const passed = isPerfect || score >= threshold;

    console.log(`  ${passed ? PASS : FAIL} ${test.metric} (${test.ethnicity} male)`);
    console.log(`      Value: ${test.idealValue} | Score: ${score.toFixed(2)}/${config.maxScore} | Range: ${formatRange(config.idealMin, config.idealMax)}`);

    if (passed) passedTests++;
    else failedTests++;
  }

  // ========================================
  // TEST 4: Male vs Female Dimorphism
  // ========================================
  console.log('\n\n📋 TEST 4: Male vs Female Sexual Dimorphism\n');
  console.log('-'.repeat(70));

  const dimorphismTests = [
    {
      metric: 'jawWidthRatio',
      expectation: 'male > female',
      check: (m: number, f: number) => m > f,
      description: 'Males prefer wider jaws'
    },
    {
      metric: 'gonialAngle',
      expectation: 'male < female',
      check: (m: number, f: number) => m < f,
      description: 'Males prefer sharper (lower) gonial angles'
    },
    {
      metric: 'eyeAspectRatio',
      expectation: 'male < female',
      check: (m: number, f: number) => m < f,
      description: 'Males prefer slightly smaller eyes'
    },
    {
      metric: 'bigonialWidth',
      expectation: 'male > female',
      check: (m: number, f: number) => m > f,
      description: 'Males prefer wider jaw width'
    },
  ];

  for (const test of dimorphismTests) {
    console.log(`\n  ${test.metric}: ${test.description}`);

    let allPassed = true;
    for (const ethnicity of ['white', 'east_asian', 'black'] as Ethnicity[]) {
      const maleConfig = getMetricConfigForDemographics(test.metric, 'male', ethnicity);
      const femaleConfig = getMetricConfigForDemographics(test.metric, 'female', ethnicity);

      if (!maleConfig || !femaleConfig) continue;

      const maleMid = (maleConfig.idealMin + maleConfig.idealMax) / 2;
      const femaleMid = (femaleConfig.idealMin + femaleConfig.idealMax) / 2;
      const passed = test.check(maleMid, femaleMid);

      const symbol = test.expectation.includes('>') ? '>' : '<';
      console.log(`    ${passed ? PASS : FAIL} ${ethnicity}: M(${maleMid.toFixed(2)}) ${symbol} F(${femaleMid.toFixed(2)})`);

      if (!passed) allPassed = false;
    }

    if (allPassed) passedTests++;
    else failedTests++;
  }

  // ========================================
  // TEST 5: Full Male Harmony Analysis
  // ========================================
  console.log('\n\n📋 TEST 5: Full Male Harmony Analysis (All Ethnicities)\n');
  console.log('-'.repeat(70));

  // Mock male-proportioned landmarks
  const MOCK_MALE_LANDMARKS = [
    { id: 'trichion', label: 'Hairline', x: 509, y: 180 },
    { id: 'left_pupila', label: 'Left Pupil', x: 420, y: 339 },
    { id: 'left_canthus_medialis', label: 'Left Medial Canthus', x: 460, y: 343 },
    { id: 'left_canthus_lateralis', label: 'Left Lateral Canthus', x: 378, y: 336 },
    { id: 'right_pupila', label: 'Right Pupil', x: 600, y: 340 },
    { id: 'right_canthus_medialis', label: 'Right Medial Canthus', x: 560, y: 341 },
    { id: 'right_canthus_lateralis', label: 'Right Lateral Canthus', x: 642, y: 334 },
    { id: 'subnasale', label: 'Subnasale', x: 510, y: 450 },
    { id: 'left_ala_nasi', label: 'Left Ala', x: 475, y: 448 },
    { id: 'right_ala_nasi', label: 'Right Ala', x: 545, y: 448 },
    { id: 'labrale_superius', label: 'Upper Lip', x: 510, y: 485 },
    { id: 'labrale_inferius', label: 'Lower Lip', x: 510, y: 525 },
    { id: 'left_cheilion', label: 'Left Mouth Corner', x: 455, y: 510 },
    { id: 'right_cheilion', label: 'Right Mouth Corner', x: 565, y: 510 },
    { id: 'left_gonion_superior', label: 'Left Upper Gonion', x: 320, y: 480 },
    { id: 'right_gonion_superior', label: 'Right Upper Gonion', x: 700, y: 480 },
    { id: 'left_gonion_inferior', label: 'Left Lower Gonion', x: 350, y: 550 },
    { id: 'right_gonion_inferior', label: 'Right Lower Gonion', x: 670, y: 550 },
    { id: 'menton', label: 'Chin Point', x: 510, y: 630 },
    { id: 'left_zygion', label: 'Left Cheekbone', x: 320, y: 380 },
    { id: 'right_zygion', label: 'Right Cheekbone', x: 700, y: 380 },
  ];

  const MOCK_SIDE_LANDMARKS = [
    { id: 'glabella', label: 'Glabella', x: 380, y: 280 },
    { id: 'nasion', label: 'Nasion', x: 385, y: 320 },
    { id: 'pronasale', label: 'Nose Tip', x: 340, y: 430 },
    { id: 'subnasale', label: 'Subnasale', x: 370, y: 450 },
    { id: 'labrale_superius', label: 'Upper Lip', x: 365, y: 480 },
    { id: 'labrale_inferius', label: 'Lower Lip', x: 360, y: 510 },
    { id: 'sublabiale', label: 'Sublabiale', x: 375, y: 530 },
    { id: 'pogonion', label: 'Pogonion', x: 365, y: 580 },
    { id: 'menton', label: 'Menton', x: 380, y: 620 },
    { id: 'gonion_top', label: 'Gonion Top', x: 500, y: 480 },
    { id: 'gonion_bottom', label: 'Gonion Bottom', x: 490, y: 540 },
    { id: 'tragus', label: 'Tragus', x: 520, y: 380 },
    { id: 'porion', label: 'Porion', x: 530, y: 340 },
    { id: 'orbitale', label: 'Orbitale', x: 420, y: 360 },
    { id: 'cervical_point', label: 'Cervical Point', x: 510, y: 600 },
    { id: 'trichion', label: 'Hairline', x: 400, y: 180 },
  ];

  for (const ethnicity of ALL_ETHNICITIES) {
    console.log(`\n  Male ${ethnicity}:`);

    try {
      const harmony = analyzeHarmony(MOCK_MALE_LANDMARKS, MOCK_SIDE_LANDMARKS, 'male', ethnicity);

      console.log(`    Overall Score: ${harmony.overallScore.toFixed(2)}`);
      console.log(`    Quality Tier: ${harmony.qualityTier}`);
      console.log(`    Percentile: ${harmony.percentile.toFixed(1)}%`);
      console.log(`    Measurements: ${harmony.measurements.length}`);
      console.log(`    Flaws: ${harmony.flaws.length} | Strengths: ${harmony.strengths.length}`);

      if (harmony.overallScore > 0) {
        console.log(`    ${PASS} Analysis completed`);
        passedTests++;
      } else {
        console.log(`    ${FAIL} Invalid score`);
        failedTests++;
      }
    } catch (error: any) {
      console.log(`    ${FAIL} Error: ${error.message}`);
      failedTests++;
    }
  }

  // ========================================
  // SUMMARY
  // ========================================
  console.log('\n\n' + '='.repeat(70));
  console.log('  TEST SUMMARY');
  console.log('='.repeat(70) + '\n');

  const total = passedTests + failedTests;
  const successRate = total > 0 ? (passedTests / total * 100).toFixed(1) : '0.0';

  console.log(`  ${PASS} Passed: ${passedTests}`);
  console.log(`  ${FAIL} Failed: ${failedTests}`);
  console.log(`  ${WARN} Warnings: ${warnings}`);
  console.log(`\n  Total: ${total} tests`);
  console.log(`  Success Rate: ${successRate}%`);

  if (failedTests === 0) {
    console.log('\n  ✅ All male analysis tests passed!');
  } else {
    console.log('\n  ⚠️  Some tests failed - review output above');
  }
}

runTests().catch(console.error);
