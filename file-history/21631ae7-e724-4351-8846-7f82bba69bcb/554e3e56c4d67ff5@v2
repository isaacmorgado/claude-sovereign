#!/usr/bin/env npx tsx
/**
 * Comprehensive Female Analysis Test Suite
 * Tests all 8 female ethnicity overrides and female-specific scoring
 */

/* eslint-disable @typescript-eslint/no-require-imports */
const {
  getMetricConfigForDemographics,
  calculateFaceIQScore,
  analyzeFrontProfile,
  analyzeSideProfile,
  analyzeHarmony,
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

// Key metrics that should have female-specific overrides
const FEMALE_SPECIFIC_METRICS = [
  'nasalIndex',
  'jawWidthRatio',
  'lateralCanthalTilt',
  'gonialAngle',
  'eyeAspectRatio',
  'bigonialWidth',
  'jawFrontalAngle',
  'faceWidthToHeight',
  'lipRatio',
  'nasolabialAngle',
];

interface TestResult {
  metric: string;
  ethnicity: Ethnicity;
  maleRange: string;
  femaleRange: string;
  hasDifference: boolean;
}

function formatRange(min: number, max: number): string {
  return `[${min.toFixed(2)}-${max.toFixed(2)}]`;
}

async function runTests() {
  console.log('\n' + '='.repeat(70));
  console.log('  COMPREHENSIVE FEMALE ANALYSIS TEST SUITE');
  console.log('='.repeat(70) + '\n');

  let passedTests = 0;
  let failedTests = 0;
  let warnings = 0;

  // ========================================
  // TEST 1: Female vs Male Ideal Range Differences
  // ========================================
  console.log('\n📋 TEST 1: Female vs Male Ideal Range Differences\n');
  console.log('-'.repeat(70));

  const results: TestResult[] = [];

  for (const metricId of FEMALE_SPECIFIC_METRICS) {
    console.log(`\n  ${metricId}:`);

    for (const ethnicity of ALL_ETHNICITIES) {
      const maleConfig = getMetricConfigForDemographics(metricId, 'male', ethnicity);
      const femaleConfig = getMetricConfigForDemographics(metricId, 'female', ethnicity);

      if (!maleConfig || !femaleConfig) {
        console.log(`    ${WARN} ${ethnicity}: Config missing`);
        warnings++;
        continue;
      }

      const hasDifference =
        maleConfig.idealMin !== femaleConfig.idealMin ||
        maleConfig.idealMax !== femaleConfig.idealMax;

      results.push({
        metric: metricId,
        ethnicity,
        maleRange: formatRange(maleConfig.idealMin, maleConfig.idealMax),
        femaleRange: formatRange(femaleConfig.idealMin, femaleConfig.idealMax),
        hasDifference,
      });

      if (hasDifference) {
        console.log(`    ${PASS} ${ethnicity}: M${formatRange(maleConfig.idealMin, maleConfig.idealMax)} → F${formatRange(femaleConfig.idealMin, femaleConfig.idealMax)}`);
        passedTests++;
      } else {
        console.log(`    ${WARN} ${ethnicity}: Same range ${formatRange(maleConfig.idealMin, maleConfig.idealMax)}`);
        warnings++;
      }
    }
  }

  // ========================================
  // TEST 2: Female Ethnicity-Specific Variations
  // ========================================
  console.log('\n\n📋 TEST 2: Female Ethnicity-Specific Variations\n');
  console.log('-'.repeat(70));

  const keyMetrics = ['nasalIndex', 'gonialAngle', 'lipRatio', 'lateralCanthalTilt'];

  for (const metricId of keyMetrics) {
    console.log(`\n  ${metricId} across female ethnicities:`);

    const ranges: { ethnicity: Ethnicity; min: number; max: number }[] = [];

    for (const ethnicity of ALL_ETHNICITIES) {
      const config = getMetricConfigForDemographics(metricId, 'female', ethnicity);
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
  // TEST 3: Female Scoring Validation
  // ========================================
  console.log('\n\n📋 TEST 3: Female Scoring at Ideal Values\n');
  console.log('-'.repeat(70));

  const scoringTests = [
    { metric: 'nasalIndex', ethnicity: 'white' as Ethnicity, idealValue: 68 },
    { metric: 'nasalIndex', ethnicity: 'black' as Ethnicity, idealValue: 91 },
    { metric: 'nasalIndex', ethnicity: 'east_asian' as Ethnicity, idealValue: 81 },
    { metric: 'gonialAngle', ethnicity: 'white' as Ethnicity, idealValue: 126 },
    { metric: 'gonialAngle', ethnicity: 'east_asian' as Ethnicity, idealValue: 123 },
    { metric: 'lateralCanthalTilt', ethnicity: 'white' as Ethnicity, idealValue: 6.5 },
    { metric: 'lateralCanthalTilt', ethnicity: 'east_asian' as Ethnicity, idealValue: 11 },
    { metric: 'lowerToUpperLipRatio', ethnicity: 'black' as Ethnicity, idealValue: 1.45 },
    { metric: 'lowerToUpperLipRatio', ethnicity: 'hispanic' as Ethnicity, idealValue: 1.225 },
  ];

  for (const test of scoringTests) {
    const config = getMetricConfigForDemographics(test.metric, 'female', test.ethnicity);
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

    console.log(`  ${passed ? PASS : FAIL} ${test.metric} (${test.ethnicity} female)`);
    console.log(`      Value: ${test.idealValue} | Score: ${score.toFixed(2)}/${config.maxScore} | Range: ${formatRange(config.idealMin, config.idealMax)}`);

    if (passed) passedTests++;
    else failedTests++;
  }

  // ========================================
  // TEST 4: Female Sexual Dimorphism Patterns
  // ========================================
  console.log('\n\n📋 TEST 4: Sexual Dimorphism Patterns\n');
  console.log('-'.repeat(70));

  const dimorphismTests = [
    {
      metric: 'jawWidthRatio',
      expectation: 'female < male',
      check: (f: number, m: number) => f < m,
      description: 'Females prefer narrower jaws'
    },
    {
      metric: 'gonialAngle',
      expectation: 'female > male',
      check: (f: number, m: number) => f > m,
      description: 'Females prefer softer (higher) gonial angles'
    },
    {
      metric: 'eyeAspectRatio',
      expectation: 'female > male',
      check: (f: number, m: number) => f > m,
      description: 'Females prefer larger eyes'
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
      const passed = test.check(femaleMid, maleMid);

      console.log(`    ${passed ? PASS : FAIL} ${ethnicity}: F(${femaleMid.toFixed(2)}) ${test.expectation.includes('>') ? '>' : '<'} M(${maleMid.toFixed(2)})`);

      if (!passed) allPassed = false;
    }

    if (allPassed) passedTests++;
    else failedTests++;
  }

  // ========================================
  // TEST 5: Full Female Harmony Analysis
  // ========================================
  console.log('\n\n📋 TEST 5: Full Female Harmony Analysis\n');
  console.log('-'.repeat(70));

  // Mock female-proportioned landmarks (adjusted for feminine ideals)
  const MOCK_FEMALE_LANDMARKS = [
    { id: 'trichion', label: 'Hairline', medicalTerm: 'Trichion', description: '', x: 509, y: 180, category: 'Head' },
    { id: 'left_pupila', label: 'Left Pupil', medicalTerm: '', description: '', x: 420, y: 339, category: 'Eyes' },
    { id: 'left_canthus_medialis', label: 'Left Medial Canthus', medicalTerm: '', description: '', x: 460, y: 343, category: 'Eyes' },
    { id: 'left_canthus_lateralis', label: 'Left Lateral Canthus', medicalTerm: '', description: '', x: 378, y: 336, category: 'Eyes' },
    { id: 'left_palpebra_superior', label: 'Left Upper Eyelid', medicalTerm: '', description: '', x: 420, y: 328, category: 'Eyes' },
    { id: 'left_palpebra_inferior', label: 'Left Lower Eyelid', medicalTerm: '', description: '', x: 420, y: 350, category: 'Eyes' },
    { id: 'right_pupila', label: 'Right Pupil', medicalTerm: '', description: '', x: 600, y: 340, category: 'Eyes' },
    { id: 'right_canthus_medialis', label: 'Right Medial Canthus', medicalTerm: '', description: '', x: 560, y: 341, category: 'Eyes' },
    { id: 'right_canthus_lateralis', label: 'Right Lateral Canthus', medicalTerm: '', description: '', x: 642, y: 334, category: 'Eyes' },
    { id: 'right_palpebra_superior', label: 'Right Upper Eyelid', medicalTerm: '', description: '', x: 600, y: 329, category: 'Eyes' },
    { id: 'right_palpebra_inferior', label: 'Right Lower Eyelid', medicalTerm: '', description: '', x: 600, y: 351, category: 'Eyes' },
    { id: 'nasal_base', label: 'Nasal Base', medicalTerm: '', description: '', x: 510, y: 360, category: 'Nose' },
    { id: 'subnasale', label: 'Subnasale', medicalTerm: '', description: '', x: 510, y: 450, category: 'Nose' },
    { id: 'left_ala_nasi', label: 'Left Ala', medicalTerm: '', description: '', x: 475, y: 448, category: 'Nose' },
    { id: 'right_ala_nasi', label: 'Right Ala', medicalTerm: '', description: '', x: 545, y: 448, category: 'Nose' },
    { id: 'labrale_superius', label: 'Upper Lip', medicalTerm: '', description: '', x: 510, y: 485, category: 'Mouth' },
    { id: 'labrale_inferius', label: 'Lower Lip', medicalTerm: '', description: '', x: 510, y: 525, category: 'Mouth' },
    { id: 'left_cheilion', label: 'Left Mouth Corner', medicalTerm: '', description: '', x: 455, y: 510, category: 'Mouth' },
    { id: 'right_cheilion', label: 'Right Mouth Corner', medicalTerm: '', description: '', x: 565, y: 510, category: 'Mouth' },
    { id: 'left_gonion_superior', label: 'Left Upper Gonion', medicalTerm: '', description: '', x: 340, y: 480, category: 'Jaw' },
    { id: 'right_gonion_superior', label: 'Right Upper Gonion', medicalTerm: '', description: '', x: 680, y: 480, category: 'Jaw' },
    { id: 'left_gonion_inferior', label: 'Left Lower Gonion', medicalTerm: '', description: '', x: 370, y: 550, category: 'Jaw' },
    { id: 'right_gonion_inferior', label: 'Right Lower Gonion', medicalTerm: '', description: '', x: 650, y: 550, category: 'Jaw' },
    { id: 'menton', label: 'Chin Point', medicalTerm: '', description: '', x: 510, y: 630, category: 'Chin' },
    { id: 'left_zygion', label: 'Left Cheekbone', medicalTerm: '', description: '', x: 330, y: 380, category: 'Face' },
    { id: 'right_zygion', label: 'Right Cheekbone', medicalTerm: '', description: '', x: 690, y: 380, category: 'Face' },
  ];

  const MOCK_SIDE_LANDMARKS = [
    { id: 'glabella', label: 'Glabella', medicalTerm: '', description: '', x: 380, y: 280, category: 'Forehead' },
    { id: 'nasion', label: 'Nasion', medicalTerm: '', description: '', x: 385, y: 320, category: 'Nose' },
    { id: 'pronasale', label: 'Nose Tip', medicalTerm: '', description: '', x: 340, y: 430, category: 'Nose' },
    { id: 'subnasale', label: 'Subnasale', medicalTerm: '', description: '', x: 370, y: 450, category: 'Nose' },
    { id: 'labrale_superius', label: 'Upper Lip', medicalTerm: '', description: '', x: 365, y: 480, category: 'Lips' },
    { id: 'labrale_inferius', label: 'Lower Lip', medicalTerm: '', description: '', x: 360, y: 510, category: 'Lips' },
    { id: 'sublabiale', label: 'Sublabiale', medicalTerm: '', description: '', x: 375, y: 530, category: 'Chin' },
    { id: 'pogonion', label: 'Pogonion', medicalTerm: '', description: '', x: 365, y: 580, category: 'Chin' },
    { id: 'menton', label: 'Menton', medicalTerm: '', description: '', x: 380, y: 620, category: 'Chin' },
    { id: 'gonion_top', label: 'Gonion Top', medicalTerm: '', description: '', x: 500, y: 480, category: 'Jaw' },
    { id: 'gonion_bottom', label: 'Gonion Bottom', medicalTerm: '', description: '', x: 490, y: 540, category: 'Jaw' },
    { id: 'tragus', label: 'Tragus', medicalTerm: '', description: '', x: 520, y: 380, category: 'Ear' },
    { id: 'porion', label: 'Porion', medicalTerm: '', description: '', x: 530, y: 340, category: 'Ear' },
    { id: 'orbitale', label: 'Orbitale', medicalTerm: '', description: '', x: 420, y: 360, category: 'Eye' },
    { id: 'cervical_point', label: 'Cervical Point', medicalTerm: '', description: '', x: 510, y: 600, category: 'Neck' },
    { id: 'trichion', label: 'Hairline', medicalTerm: '', description: '', x: 400, y: 180, category: 'Forehead' },
  ];

  for (const ethnicity of ['white', 'east_asian', 'black', 'hispanic'] as Ethnicity[]) {
    console.log(`\n  Female ${ethnicity}:`);

    try {
      const harmony = analyzeHarmony(MOCK_FEMALE_LANDMARKS, MOCK_SIDE_LANDMARKS, 'female', ethnicity);

      console.log(`    Overall Score: ${harmony.overallScore.toFixed(2)}`);
      console.log(`    Quality Tier: ${harmony.qualityTier}`);
      console.log(`    Percentile: ${harmony.percentile.toFixed(1)}%`);
      console.log(`    Flaws: ${harmony.flaws.length} | Strengths: ${harmony.strengths.length}`);

      if (harmony.overallScore > 0) {
        console.log(`    ${PASS} Analysis completed`);
        passedTests++;
      } else {
        console.log(`    ${FAIL} Invalid score`);
        failedTests++;
      }
    } catch (error) {
      console.log(`    ${FAIL} Error: ${error}`);
      failedTests++;
    }
  }

  // ========================================
  // SUMMARY
  // ========================================
  console.log('\n\n' + '='.repeat(70));
  console.log('  TEST SUMMARY');
  console.log('='.repeat(70) + '\n');

  console.log(`  ${PASS} Passed: ${passedTests}`);
  console.log(`  ${FAIL} Failed: ${failedTests}`);
  console.log(`  ${WARN} Warnings: ${warnings}`);
  console.log(`\n  Total: ${passedTests + failedTests} tests`);
  console.log(`  Success Rate: ${((passedTests / (passedTests + failedTests)) * 100).toFixed(1)}%`);

  if (failedTests === 0) {
    console.log('\n  ✅ All female analysis tests passed!');
  } else {
    console.log('\n  ⚠️  Some tests failed - review output above');
  }
}

runTests().catch(console.error);
