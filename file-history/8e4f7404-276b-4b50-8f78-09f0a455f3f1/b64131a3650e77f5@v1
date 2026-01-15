import {
  SOFTMAXXING_TREATMENTS,
  SURGICAL_TREATMENTS,
  SUPPLEMENTS,
  NON_SURGICAL_TREATMENTS,
  generateRecommendationPlan,
  harmonyToPSL,
  classifyByScore,
  getSoftmaxxingByIssue,
  getSurgeryByIssue,
} from './src/lib/recommendations';

// Test data - simulated metric analysis results
const testMetrics = [
  {
    metricId: 'fwhr',
    metricName: 'Facial Width-to-Height Ratio',
    currentValue: 1.75,
    idealValue: 1.9,
    idealRange: { min: 1.8, max: 2.0 },
    score: 72,
    profileType: 'front' as const,
  },
  {
    metricId: 'canthalTilt',
    metricName: 'Canthal Tilt',
    currentValue: 2,
    idealValue: 6,
    idealRange: { min: 4, max: 8 },
    score: 55,
    profileType: 'front' as const,
  },
  {
    metricId: 'gonialAngle',
    metricName: 'Gonial Angle',
    currentValue: 138,
    idealValue: 125,
    idealRange: { min: 120, max: 130 },
    score: 60,
    profileType: 'side' as const,
  },
  {
    metricId: 'nasolabialAngle',
    metricName: 'Nasolabial Angle',
    currentValue: 85,
    idealValue: 97.5,
    idealRange: { min: 90, max: 105 },
    score: 70,
    profileType: 'side' as const,
  },
  {
    metricId: 'chinProjection',
    metricName: 'Chin Projection',
    currentValue: -8,
    idealValue: -1,
    idealRange: { min: -4, max: 2 },
    score: 45,
    profileType: 'side' as const,
  },
];

console.log('============================================================');
console.log('LOOKSMAXXING RECOMMENDATION SYSTEM TEST');
console.log('============================================================');

// Test 1: Database counts
console.log('\n📊 DATABASE COUNTS:');
console.log('  Softmaxxing treatments:', SOFTMAXXING_TREATMENTS.length);
console.log('  Surgical procedures:', SURGICAL_TREATMENTS.length);
console.log('  Supplements:', SUPPLEMENTS.length);
console.log('  Non-surgical treatments:', NON_SURGICAL_TREATMENTS.length);
console.log('  TOTAL:', SOFTMAXXING_TREATMENTS.length + SURGICAL_TREATMENTS.length + SUPPLEMENTS.length + NON_SURGICAL_TREATMENTS.length);

// Test 2: PSL Rating
console.log('\n🎯 PSL RATING CONVERSION:');
const testScores = [30, 50, 65, 80, 95];
for (const score of testScores) {
  const psl = harmonyToPSL(score);
  console.log('  Harmony ' + score + '% → PSL ' + psl.psl + ' (' + psl.tier + ', top ' + (100 - psl.percentile).toFixed(2) + '%)');
}

// Test 3: Severity Classification
console.log('\n📈 SEVERITY CLASSIFICATION:');
const scores = [95, 78, 55, 35];
for (const score of scores) {
  const severity = classifyByScore(score);
  console.log('  Score ' + score + ': ' + severity.severity + ' - ' + severity.description);
}

// Test 4: Issue-based recommendations
console.log('\n🔍 ISSUE-BASED RECOMMENDATIONS:');
const issues = ['weak_chin', 'negative_canthal_tilt', 'wide_nose'];
for (const issue of issues) {
  const softmax = getSoftmaxxingByIssue(issue);
  const surgical = getSurgeryByIssue(issue);
  console.log('  "' + issue + '":');
  console.log('    Softmaxxing:', softmax.length > 0 ? softmax.map(t => t.name).slice(0, 2).join(', ') : 'None');
  console.log('    Surgical:', surgical.length > 0 ? surgical.map(t => t.name).slice(0, 2).join(', ') : 'None');
}

// Test 5: Full recommendation plan
console.log('\n📋 FULL RECOMMENDATION PLAN:');
const plan = generateRecommendationPlan(testMetrics, 60, 55, 'male');

console.log('  Overall Score:', plan.overallScore);
console.log('  Current PSL:', plan.currentPSL);
console.log('  Potential PSL:', plan.potentialPSL, '(+' + plan.potentialImprovement + ')');
console.log('  Percentile:', plan.percentile + '%');

console.log('\n  Weaknesses identified:');
for (const weakness of plan.weaknesses.slice(0, 5)) {
  console.log('    -', weakness.metricName + ':', weakness.severity.severity, '(score:', weakness.score + ')');
  if (weakness.issue) console.log('      Issue:', weakness.issue);
}

console.log('\n  Top Lifestyle Recommendations:');
for (const rec of plan.lifestyle.slice(0, 3)) {
  console.log('    -', rec.treatment.name, '(priority:', rec.priority + ', PSL +' + rec.estimatedImprovement + ')');
}

console.log('\n  Top Non-Surgical Recommendations:');
for (const rec of plan.minimallyInvasive.slice(0, 3)) {
  console.log('    -', rec.treatment.name, '(priority:', rec.priority + ', PSL +' + rec.estimatedImprovement + ')');
}

console.log('\n  Top Surgical Recommendations:');
for (const rec of plan.surgical.slice(0, 3)) {
  console.log('    -', rec.treatment.name, '(priority:', rec.priority + ', PSL +' + rec.estimatedImprovement + ')');
}

console.log('\n  Order of Operations:');
for (const op of plan.orderOfOperations.slice(0, 5)) {
  console.log('    ' + op.step + '. [' + op.category + ']', op.treatment.name);
}

console.log('\n============================================================');
console.log('✅ ALL TESTS COMPLETED SUCCESSFULLY');
console.log('============================================================');
