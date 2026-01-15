#!/usr/bin/env npx tsx
/**
 * Test harmony analysis for all ethnicities
 */

/* eslint-disable @typescript-eslint/no-require-imports */
const { analyzeHarmony } = require('../src/lib/faceiq-scoring');

const MOCK_FRONT = [
  { id: 'trichion', x: 509, y: 180 },
  { id: 'left_pupila', x: 420, y: 339 },
  { id: 'left_canthus_medialis', x: 460, y: 343 },
  { id: 'left_canthus_lateralis', x: 378, y: 336 },
  { id: 'right_pupila', x: 600, y: 340 },
  { id: 'right_canthus_medialis', x: 560, y: 341 },
  { id: 'right_canthus_lateralis', x: 642, y: 334 },
  { id: 'subnasale', x: 510, y: 450 },
  { id: 'left_ala_nasi', x: 475, y: 448 },
  { id: 'right_ala_nasi', x: 545, y: 448 },
  { id: 'labrale_superius', x: 510, y: 485 },
  { id: 'labrale_inferius', x: 510, y: 525 },
  { id: 'left_cheilion', x: 455, y: 510 },
  { id: 'right_cheilion', x: 565, y: 510 },
  { id: 'left_gonion_superior', x: 340, y: 480 },
  { id: 'right_gonion_superior', x: 680, y: 480 },
  { id: 'menton', x: 510, y: 630 },
  { id: 'left_zygion', x: 330, y: 380 },
  { id: 'right_zygion', x: 690, y: 380 },
];

const MOCK_SIDE = [
  { id: 'glabella', x: 380, y: 280 },
  { id: 'nasion', x: 385, y: 320 },
  { id: 'pronasale', x: 340, y: 430 },
  { id: 'subnasale', x: 370, y: 450 },
  { id: 'labrale_superius', x: 365, y: 480 },
  { id: 'labrale_inferius', x: 360, y: 510 },
  { id: 'pogonion', x: 365, y: 580 },
  { id: 'menton', x: 380, y: 620 },
  { id: 'gonion_top', x: 500, y: 480 },
  { id: 'gonion_bottom', x: 490, y: 540 },
  { id: 'tragus', x: 520, y: 380 },
  { id: 'porion', x: 530, y: 340 },
  { id: 'orbitale', x: 420, y: 360 },
  { id: 'trichion', x: 400, y: 180 },
];

const ethnicities = ['pacific_islander', 'native_american', 'middle_eastern', 'south_asian', 'east_asian'];

console.log('Testing Harmony Analysis for Female Ethnicities\n');
console.log('='.repeat(60));

for (const eth of ethnicities) {
  console.log(`\n${eth.toUpperCase()} (female):`);
  try {
    const result = analyzeHarmony(MOCK_FRONT, MOCK_SIDE, 'female', eth);
    console.log(`  ✓ Overall Score: ${result.overallScore.toFixed(2)}`);
    console.log(`  ✓ Quality Tier: ${result.qualityTier}`);
    console.log(`  ✓ Percentile: ${result.percentile.toFixed(1)}%`);
    console.log(`  ✓ Measurements: ${result.measurements.length}`);
    console.log(`  ✓ Flaws: ${result.flaws.length} | Strengths: ${result.strengths.length}`);
  } catch (err: any) {
    console.log(`  ✗ ERROR: ${err.message}`);
  }
}

console.log('\n' + '='.repeat(60));
console.log('All ethnicities tested!');
