/**
 * Analysis Functions and Constants for Results
 * Extracted from ResultsContext.tsx
 *
 * Contains:
 * - STRENGTH_GROUPINGS: Metric grouping definitions for creating multi-ratio strengths
 * - FLAW_GROUPINGS: Metric grouping definitions for creating multi-ratio flaws
 * - PROCEDURE_DATABASE: 30+ procedure configurations with targeting metadata
 * - generateStrengthsFromAnalysis: Creates strengths from harmony analysis
 * - generateFlawsFromAnalysis: Creates flaws from harmony analysis
 * - generateRecommendations: Matches procedures to flaws
 * - calculateRelevanceScore: Scores procedure-flaw matches
 * - calculateExpectedImprovement: Bezier-based improvement estimation
 */

import { HarmonyAnalysis, METRIC_CONFIGS, scoreMeasurement, Ethnicity, Gender } from '@/lib/harmony-scoring';
import { Strength, Flaw, Recommendation, Ratio } from '@/types/results';

// ============================================
// STRENGTH GROUPINGS
// ============================================

/**
 * Metric groupings for creating multi-ratio strengths.
 * When 2+ metrics in a group score >= 7.5, they're combined into a grouped strength.
 */
export const STRENGTH_GROUPINGS: Record<string, {
  name: string;
  category: string;
  description: string;
  metrics: string[];
}> = {
  // Lip Proportions
  lipProportions: {
    name: 'Well Proportioned Lips',
    category: 'Lips',
    description: 'The lips demonstrate excellent proportions with balanced upper-to-lower lip ratio and appropriate projection.',
    metrics: ['lipRatio', 'philtrumLength', 'upperLipProjection', 'lowerLipProjection', 'lipChinDistance'],
  },
  // Eye Proportions
  eyeProportions: {
    name: 'Harmonious Eye Proportions',
    category: 'Eyes',
    description: 'The eyes display balanced proportions with attractive shape and ideal spacing.',
    metrics: ['lateralCanthalTilt', 'eyeAspectRatio', 'intercanthalWidth', 'eyeSeparationRatio', 'eyebrowHeight'],
  },
  // Nose Proportions
  noseProportions: {
    name: 'Balanced Nasal Proportions',
    category: 'Nose',
    description: 'The nose exhibits well-balanced width, height, and angles that harmonize with facial features.',
    metrics: ['nasalIndex', 'nasofrontalAngle', 'nasofacialAngle', 'nasomentaAngle', 'intercanthalNasalRatio', 'noseBridgeWidth'],
  },
  // Jaw Definition
  jawDefinition: {
    name: 'Well-Defined Jawline',
    category: 'Jaw Shape',
    description: 'The jawline displays strong definition with balanced angles and proportionate width.',
    metrics: ['gonialAngle', 'jawWidthRatio', 'bigonialWidth', 'mandibularPlaneAngle', 'jawFrontalAngle', 'jawSlope'],
  },
  // Chin Proportions
  chinProportions: {
    name: 'Balanced Chin Projection',
    category: 'Chin',
    description: 'The chin demonstrates ideal projection and proportions relative to the face.',
    metrics: ['chinPhiltrumRatio', 'chinHeight', 'facialDepthToHeight', 'anteriorFacialDepth'],
  },
  // Facial Thirds
  facialThirds: {
    name: 'Balanced Facial Thirds',
    category: 'Face Proportions',
    description: 'The face displays well-balanced vertical proportions across upper, middle, and lower thirds.',
    metrics: ['faceWidthToHeight', 'upperThirdProportion', 'middleThirdProportion', 'lowerThirdProportion'],
  },
  // Midface
  midfaceBalance: {
    name: 'Harmonious Midface',
    category: 'Midface/Face Shape',
    description: 'The midface shows balanced proportions with well-positioned cheekbones.',
    metrics: ['midfaceRatio', 'cheekboneHeight', 'cheekboneWidth', 'totalFacialWidthToHeight'],
  },
  // Forehead
  foreheadBalance: {
    name: 'Well-Proportioned Forehead',
    category: 'Forehead',
    description: 'The forehead displays ideal proportions in height and shape.',
    metrics: ['foreheadHeight', 'foreheadWidth', 'templeWidth'],
  },
};

// ============================================
// FLAW GROUPINGS
// ============================================

/**
 * Flaw groupings - similar to strength groupings but for areas of improvement.
 * When 2+ metrics in a group score < 6, they're combined into a grouped flaw.
 */
export const FLAW_GROUPINGS: Record<string, {
  name: string;
  category: string;
  description: string;
  metrics: string[];
}> = {
  // Lip Issues
  lipIssues: {
    name: 'Lip Proportion Concerns',
    category: 'Lips',
    description: 'The lip proportions show deviation from ideal ratios, affecting lower face harmony.',
    metrics: ['lipRatio', 'philtrumLength', 'upperLipProjection', 'lowerLipProjection', 'lipChinDistance'],
  },
  // Eye Issues
  eyeIssues: {
    name: 'Eye Shape Considerations',
    category: 'Eyes',
    description: 'The eye proportions or positioning could benefit from enhancement.',
    metrics: ['lateralCanthalTilt', 'eyeAspectRatio', 'intercanthalWidth', 'eyeSeparationRatio', 'eyebrowHeight'],
  },
  // Nose Issues
  noseIssues: {
    name: 'Nasal Proportion Concerns',
    category: 'Nose',
    description: 'The nasal proportions show deviations that affect facial harmony.',
    metrics: ['nasalIndex', 'nasofrontalAngle', 'nasofacialAngle', 'nasomentaAngle', 'intercanthalNasalRatio', 'noseBridgeWidth'],
  },
  // Jaw Issues
  jawIssues: {
    name: 'Jawline Definition Concerns',
    category: 'Jaw Shape',
    description: 'The jawline structure shows areas that could be enhanced for better definition.',
    metrics: ['gonialAngle', 'jawWidthRatio', 'bigonialWidth', 'mandibularPlaneAngle', 'jawFrontalAngle', 'jawSlope'],
  },
  // Chin Issues
  chinIssues: {
    name: 'Chin Projection Concerns',
    category: 'Chin',
    description: 'The chin proportions deviate from ideal, affecting facial profile balance.',
    metrics: ['chinPhiltrumRatio', 'chinHeight', 'facialDepthToHeight', 'anteriorFacialDepth'],
  },
  // Face Proportion Issues
  proportionIssues: {
    name: 'Facial Proportion Imbalance',
    category: 'Face Proportions',
    description: 'The vertical face proportions show imbalance between facial thirds.',
    metrics: ['faceWidthToHeight', 'upperThirdProportion', 'middleThirdProportion', 'lowerThirdProportion'],
  },
  // Midface Issues
  midfaceIssues: {
    name: 'Midface Development Concerns',
    category: 'Midface/Face Shape',
    description: 'The midface shows areas that could benefit from enhanced projection or balance.',
    metrics: ['midfaceRatio', 'cheekboneHeight', 'cheekboneWidth', 'totalFacialWidthToHeight'],
  },
};

// ============================================
// PROCEDURE DATABASE TYPES
// ============================================

/**
 * Configuration for a cosmetic/surgical procedure.
 */
export interface ProcedureConfig {
  ref_id: string;
  name: string;
  description: string;
  phase: 'Surgical' | 'Minimally Invasive' | 'Foundational';
  baseImpact: number;
  coverage: number;
  percentage: string;
  expectedImprovementRange: { min: number; max: number };
  targetMetrics: string[];      // Specific metric IDs this treatment addresses
  targetCategories: string[];   // Category names this treatment addresses
  targetKeywords: string[];     // Flaw name keywords to match
  timeline: {
    effect_start: 'immediate' | 'delayed' | 'gradual';
    full_results_weeks: number;
    full_results_weeks_max?: number;
  };
  cost: {
    type: 'flat' | 'per_session' | 'per_month';
    min: number;
    max: number;
    currency: string;
  };
  risks_side_effects: string;
  warnings: string[];
  gender: 'male' | 'female' | 'both';
}

// ============================================
// PROCEDURE DATABASE
// ============================================

/**
 * Comprehensive procedure database with metric-specific targeting.
 * Contains 30+ procedures across Surgical, Minimally Invasive, and Foundational categories.
 */
export const PROCEDURE_DATABASE: ProcedureConfig[] = [
  // ==========================================
  // SURGICAL TREATMENTS
  // ==========================================
  {
    ref_id: 'SUR-01',
    name: 'Sliding Genioplasty',
    description: 'Chin bone repositioning surgery that can move the chin forward, backward, up, or down for optimal projection and facial balance.',
    phase: 'Surgical',
    baseImpact: 0.90,
    coverage: 8,
    percentage: '15-25%',
    expectedImprovementRange: { min: 0.5, max: 1.5 },
    targetMetrics: ['chinPhiltrumRatio', 'facialDepthToHeight', 'anteriorFacialDepth', 'nasomentaAngle'],
    targetCategories: ['Chin', 'Occlusion/Jaw Growth'],
    targetKeywords: ['chin', 'recessed', 'weak', 'short chin', 'long chin', 'pogonion'],
    timeline: { effect_start: 'delayed', full_results_weeks: 12, full_results_weeks_max: 24 },
    cost: { type: 'flat', min: 5000, max: 15000, currency: 'USD' },
    risks_side_effects: 'Temporary numbness, swelling, bruising. Rare: infection, nerve damage, bone resorption.',
    warnings: [],
    gender: 'both',
  },
  {
    ref_id: 'SUR-02',
    name: 'Reduction Rhinoplasty',
    description: 'Surgical reduction of nose size, hump removal, and tip refinement to improve nasal proportions.',
    phase: 'Surgical',
    baseImpact: 0.85,
    coverage: 6,
    percentage: '10-20%',
    expectedImprovementRange: { min: 0.5, max: 1.0 },
    targetMetrics: ['nasalIndex', 'nasofrontalAngle', 'nasofacialAngle', 'nasomentaAngle', 'intercanthalNasalRatio', 'noseBridgeWidth'],
    targetCategories: ['Nose'],
    targetKeywords: ['wide nose', 'large nose', 'dorsal hump', 'bulbous', 'nasal', 'nose bridge'],
    timeline: { effect_start: 'delayed', full_results_weeks: 24, full_results_weeks_max: 52 },
    cost: { type: 'flat', min: 7000, max: 20000, currency: 'USD' },
    risks_side_effects: 'Swelling for 6-12 months, numbness, possible revision needed.',
    warnings: [],
    gender: 'both',
  },
  {
    ref_id: 'SUR-03',
    name: 'Jaw Angle Implants',
    description: 'Custom or standard silicone/PEEK implants to enhance jaw width, definition, and angularity.',
    phase: 'Surgical',
    baseImpact: 0.80,
    coverage: 5,
    percentage: '10-15%',
    expectedImprovementRange: { min: 0.4, max: 1.0 },
    targetMetrics: ['bigonialWidth', 'jawFrontalAngle', 'jawWidthRatio', 'jawSlope', 'gonialAngle'],
    targetCategories: ['Jaw Shape'],
    targetKeywords: ['narrow jaw', 'weak jaw', 'soft jaw', 'jaw angle', 'gonial', 'mandible'],
    timeline: { effect_start: 'delayed', full_results_weeks: 8, full_results_weeks_max: 16 },
    cost: { type: 'flat', min: 8000, max: 25000, currency: 'USD' },
    risks_side_effects: 'Swelling, asymmetry risk, implant migration, infection, bone erosion.',
    warnings: [],
    gender: 'both',
  },
  {
    ref_id: 'SUR-04',
    name: 'Bimaxillary Osteotomy (Bimax)',
    description: 'Double jaw surgery to reposition both upper and lower jaws for optimal occlusion and facial balance.',
    phase: 'Surgical',
    baseImpact: 0.95,
    coverage: 12,
    percentage: '20-35%',
    expectedImprovementRange: { min: 1.0, max: 2.0 },
    targetMetrics: ['midfaceRatio', 'facialDepthToHeight', 'mandibularPlaneAngle', 'lowerThirdProportion', 'nasofacialAngle'],
    targetCategories: ['Occlusion/Jaw Growth', 'Midface/Face Shape'],
    targetKeywords: ['maxillary recession', 'mandibular', 'hyper-divergent', 'bite', 'occlusion', 'midface recession'],
    timeline: { effect_start: 'delayed', full_results_weeks: 24, full_results_weeks_max: 52 },
    cost: { type: 'flat', min: 20000, max: 60000, currency: 'USD' },
    risks_side_effects: 'Extended recovery, numbness (temporary to permanent), dietary restrictions.',
    warnings: ['Major surgery - requires orthodontic preparation'],
    gender: 'both',
  },
  {
    ref_id: 'SUR-05',
    name: 'Canthoplasty',
    description: 'Surgical eye corner modification to improve canthal tilt and eye shape.',
    phase: 'Surgical',
    baseImpact: 0.75,
    coverage: 3,
    percentage: '8-15%',
    expectedImprovementRange: { min: 0.3, max: 0.8 },
    targetMetrics: ['lateralCanthalTilt', 'eyeAspectRatio'],
    targetCategories: ['Eyes'],
    targetKeywords: ['canthal tilt', 'negative tilt', 'drooping eyes', 'eye shape', 'eye angle'],
    timeline: { effect_start: 'delayed', full_results_weeks: 8, full_results_weeks_max: 16 },
    cost: { type: 'flat', min: 4000, max: 12000, currency: 'USD' },
    risks_side_effects: 'Scarring, asymmetry, dry eyes, ectropion.',
    warnings: ['Difficult to reverse'],
    gender: 'both',
  },
  {
    ref_id: 'SUR-06',
    name: 'Cheek/Malar Implants',
    description: 'Solid implants placed over the cheekbones to enhance midface projection and width.',
    phase: 'Surgical',
    baseImpact: 0.75,
    coverage: 4,
    percentage: '10-18%',
    expectedImprovementRange: { min: 0.4, max: 0.9 },
    targetMetrics: ['cheekboneHeight', 'midfaceRatio', 'totalFacialWidthToHeight'],
    targetCategories: ['Midface/Face Shape'],
    targetKeywords: ['flat cheeks', 'low cheekbones', 'midface', 'zygomatic', 'malar'],
    timeline: { effect_start: 'delayed', full_results_weeks: 6, full_results_weeks_max: 12 },
    cost: { type: 'flat', min: 6000, max: 15000, currency: 'USD' },
    risks_side_effects: 'Swelling, asymmetry, implant shifting, nerve damage.',
    warnings: [],
    gender: 'both',
  },
  {
    ref_id: 'SUR-07',
    name: 'Neck Liposuction / Submentoplasty',
    description: 'Fat removal and skin tightening under the chin and neck area.',
    phase: 'Surgical',
    baseImpact: 0.65,
    coverage: 3,
    percentage: '8-12%',
    expectedImprovementRange: { min: 0.3, max: 0.7 },
    targetMetrics: ['submentalCervicalAngle', 'neckWidthRatio'],
    targetCategories: ['Neck'],
    targetKeywords: ['round neck', 'double chin', 'submental', 'cervical', 'neck definition'],
    timeline: { effect_start: 'delayed', full_results_weeks: 8, full_results_weeks_max: 16 },
    cost: { type: 'flat', min: 3000, max: 8000, currency: 'USD' },
    risks_side_effects: 'Swelling, bruising, skin irregularity, numbness.',
    warnings: [],
    gender: 'both',
  },
  {
    ref_id: 'SUR-08',
    name: 'Brow Bone Reduction/Augmentation',
    description: 'Surgical reshaping of the brow ridge for improved upper third harmony.',
    phase: 'Surgical',
    baseImpact: 0.70,
    coverage: 3,
    percentage: '8-15%',
    expectedImprovementRange: { min: 0.3, max: 0.7 },
    targetMetrics: ['nasofrontalAngle', 'bitemporalWidth', 'upperThirdProportion'],
    targetCategories: ['Upper Third'],
    targetKeywords: ['brow ridge', 'forehead', 'nasofrontal', 'upper third', 'glabella'],
    timeline: { effect_start: 'delayed', full_results_weeks: 12, full_results_weeks_max: 24 },
    cost: { type: 'flat', min: 8000, max: 20000, currency: 'USD' },
    risks_side_effects: 'Swelling, numbness, scarring (if coronal incision).',
    warnings: [],
    gender: 'both',
  },

  // ==========================================
  // MINIMALLY INVASIVE TREATMENTS
  // ==========================================
  {
    ref_id: 'MIN-01',
    name: 'Chin/Jawline Filler',
    description: 'Hyaluronic acid injections to enhance chin projection and jawline definition. Reversible and temporary.',
    phase: 'Minimally Invasive',
    baseImpact: 0.45,
    coverage: 4,
    percentage: '5-10%',
    expectedImprovementRange: { min: 0.2, max: 0.5 },
    targetMetrics: ['chinPhiltrumRatio', 'jawFrontalAngle', 'bigonialWidth'],
    targetCategories: ['Chin', 'Jaw Shape'],
    targetKeywords: ['weak chin', 'recessed chin', 'soft jaw', 'jawline'],
    timeline: { effect_start: 'immediate', full_results_weeks: 1 },
    cost: { type: 'per_session', min: 800, max: 2500, currency: 'USD' },
    risks_side_effects: 'Bruising, swelling, rare vascular occlusion.',
    warnings: ['Results temporary (12-18 months)', 'Requires maintenance'],
    gender: 'both',
  },
  {
    ref_id: 'MIN-02',
    name: 'Cheek Filler',
    description: 'HA filler to enhance cheekbone projection and midface volume.',
    phase: 'Minimally Invasive',
    baseImpact: 0.40,
    coverage: 3,
    percentage: '5-8%',
    expectedImprovementRange: { min: 0.2, max: 0.4 },
    targetMetrics: ['cheekboneHeight', 'midfaceRatio'],
    targetCategories: ['Midface/Face Shape'],
    targetKeywords: ['flat cheeks', 'low cheekbones', 'midface volume'],
    timeline: { effect_start: 'immediate', full_results_weeks: 1 },
    cost: { type: 'per_session', min: 600, max: 1800, currency: 'USD' },
    risks_side_effects: 'Bruising, swelling, asymmetry.',
    warnings: ['Results temporary (12-18 months)'],
    gender: 'both',
  },
  {
    ref_id: 'MIN-03',
    name: 'Lip Filler',
    description: 'Hyaluronic acid to enhance lip volume and proportions.',
    phase: 'Minimally Invasive',
    baseImpact: 0.35,
    coverage: 2,
    percentage: '3-6%',
    expectedImprovementRange: { min: 0.1, max: 0.3 },
    targetMetrics: ['lowerUpperLipRatio', 'mouthNoseWidthRatio'],
    targetCategories: ['Lips'],
    targetKeywords: ['thin lip', 'lip ratio', 'lip volume', 'upper lip', 'lower lip'],
    timeline: { effect_start: 'immediate', full_results_weeks: 1 },
    cost: { type: 'per_session', min: 400, max: 1200, currency: 'USD' },
    risks_side_effects: 'Bruising, swelling, lumps.',
    warnings: ['Results temporary (6-12 months)'],
    gender: 'both',
  },
  {
    ref_id: 'MIN-04',
    name: 'PDO Thread Lift',
    description: 'Dissolvable threads to lift and tighten skin, particularly for canthal tilt improvement.',
    phase: 'Minimally Invasive',
    baseImpact: 0.35,
    coverage: 3,
    percentage: '4-8%',
    expectedImprovementRange: { min: 0.1, max: 0.4 },
    targetMetrics: ['lateralCanthalTilt', 'eyebrowLowSetedness'],
    targetCategories: ['Eyes', 'Upper Third'],
    targetKeywords: ['canthal tilt', 'drooping', 'sagging', 'eyebrow position'],
    timeline: { effect_start: 'immediate', full_results_weeks: 4, full_results_weeks_max: 12 },
    cost: { type: 'per_session', min: 1500, max: 4000, currency: 'USD' },
    risks_side_effects: 'Bruising, asymmetry, thread visibility, infection.',
    warnings: ['Results temporary (12-18 months)'],
    gender: 'both',
  },
  {
    ref_id: 'MIN-05',
    name: 'Masseter Botox',
    description: 'Botulinum toxin to slim the lower face by relaxing masseter muscles.',
    phase: 'Minimally Invasive',
    baseImpact: 0.40,
    coverage: 2,
    percentage: '4-8%',
    expectedImprovementRange: { min: 0.2, max: 0.4 },
    targetMetrics: ['bigonialWidth', 'jawWidthRatio', 'faceWidthToHeight'],
    targetCategories: ['Jaw Shape', 'Midface/Face Shape'],
    targetKeywords: ['wide jaw', 'square jaw', 'masseter', 'bruxism'],
    timeline: { effect_start: 'delayed', full_results_weeks: 4, full_results_weeks_max: 12 },
    cost: { type: 'per_session', min: 400, max: 1000, currency: 'USD' },
    risks_side_effects: 'Temporary weakness, asymmetry, difficulty chewing.',
    warnings: ['Results temporary (4-6 months)', 'Requires regular maintenance'],
    gender: 'both',
  },
  {
    ref_id: 'MIN-06',
    name: 'Kybella (Submental Fat Dissolving)',
    description: 'Injectable deoxycholic acid to permanently destroy fat cells under the chin.',
    phase: 'Minimally Invasive',
    baseImpact: 0.45,
    coverage: 2,
    percentage: '5-10%',
    expectedImprovementRange: { min: 0.2, max: 0.5 },
    targetMetrics: ['submentalCervicalAngle', 'neckWidthRatio'],
    targetCategories: ['Neck'],
    targetKeywords: ['double chin', 'submental fat', 'neck definition'],
    timeline: { effect_start: 'delayed', full_results_weeks: 12, full_results_weeks_max: 24 },
    cost: { type: 'per_session', min: 1200, max: 1800, currency: 'USD' },
    risks_side_effects: 'Swelling, bruising, numbness, difficulty swallowing (temporary).',
    warnings: ['Requires 2-4 sessions'],
    gender: 'both',
  },

  // ==========================================
  // FOUNDATIONAL TREATMENTS
  // ==========================================
  {
    ref_id: 'FND-01',
    name: 'Mewing / Proper Tongue Posture',
    description: 'Maintaining correct tongue posture on the palate to potentially influence facial development over time.',
    phase: 'Foundational',
    baseImpact: 0.25,
    coverage: 5,
    percentage: '2-5%',
    expectedImprovementRange: { min: 0.1, max: 0.3 },
    targetMetrics: ['midfaceRatio', 'bigonialWidth', 'facialDepthToHeight'],
    targetCategories: ['Midface/Face Shape', 'Jaw Shape', 'Occlusion/Jaw Growth'],
    targetKeywords: ['midface', 'palate', 'recession', 'jaw development'],
    timeline: { effect_start: 'gradual', full_results_weeks: 104, full_results_weeks_max: 260 },
    cost: { type: 'flat', min: 0, max: 0, currency: 'USD' },
    risks_side_effects: 'None if done correctly. Jaw pain if excessive.',
    warnings: ['Results vary significantly', 'Most effective in younger individuals'],
    gender: 'both',
  },
  {
    ref_id: 'FND-02',
    name: 'Body Recomposition (Leanmaxxing)',
    description: 'Reducing body fat percentage to enhance facial definition and reveal underlying bone structure.',
    phase: 'Foundational',
    baseImpact: 0.35,
    coverage: 6,
    percentage: '5-12%',
    expectedImprovementRange: { min: 0.2, max: 0.5 },
    targetMetrics: ['bigonialWidth', 'submentalCervicalAngle', 'cheekboneHeight'],
    targetCategories: ['Jaw Shape', 'Neck', 'Midface/Face Shape'],
    targetKeywords: ['soft jaw', 'undefined', 'round', 'facial definition'],
    timeline: { effect_start: 'gradual', full_results_weeks: 12, full_results_weeks_max: 52 },
    cost: { type: 'per_month', min: 50, max: 200, currency: 'USD' },
    risks_side_effects: 'None if done healthily.',
    warnings: [],
    gender: 'both',
  },
  {
    ref_id: 'FND-03',
    name: 'Posture Correction',
    description: 'Improving head and neck posture to optimize facial appearance and reduce forward head posture effects.',
    phase: 'Foundational',
    baseImpact: 0.20,
    coverage: 3,
    percentage: '2-5%',
    expectedImprovementRange: { min: 0.1, max: 0.2 },
    targetMetrics: ['submentalCervicalAngle', 'anteriorFacialDepth'],
    targetCategories: ['Neck', 'Occlusion/Jaw Growth'],
    targetKeywords: ['neck', 'posture', 'forward head'],
    timeline: { effect_start: 'gradual', full_results_weeks: 12, full_results_weeks_max: 52 },
    cost: { type: 'flat', min: 0, max: 100, currency: 'USD' },
    risks_side_effects: 'None.',
    warnings: [],
    gender: 'both',
  },
  {
    ref_id: 'FND-04',
    name: 'Skincare Routine (Retinoid + SPF)',
    description: 'Medical-grade skincare to improve skin quality, texture, and reduce aging signs.',
    phase: 'Foundational',
    baseImpact: 0.20,
    coverage: 2,
    percentage: '2-5%',
    expectedImprovementRange: { min: 0.1, max: 0.3 },
    targetMetrics: [],
    targetCategories: [],
    targetKeywords: ['skin', 'texture', 'aging'],
    timeline: { effect_start: 'gradual', full_results_weeks: 12, full_results_weeks_max: 26 },
    cost: { type: 'per_month', min: 30, max: 150, currency: 'USD' },
    risks_side_effects: 'Initial irritation, sun sensitivity.',
    warnings: [],
    gender: 'both',
  },
  {
    ref_id: 'FND-05',
    name: 'Eyebrow Grooming / Microblading',
    description: 'Professional shaping or semi-permanent tattooing to optimize eyebrow shape and position.',
    phase: 'Foundational',
    baseImpact: 0.25,
    coverage: 2,
    percentage: '3-6%',
    expectedImprovementRange: { min: 0.1, max: 0.3 },
    targetMetrics: ['eyebrowTilt', 'eyebrowLowSetedness', 'browLengthRatio'],
    targetCategories: ['Upper Third'],
    targetKeywords: ['eyebrow', 'brow', 'upper third'],
    timeline: { effect_start: 'immediate', full_results_weeks: 1 },
    cost: { type: 'flat', min: 20, max: 600, currency: 'USD' },
    risks_side_effects: 'Minimal for grooming. Microblading: infection risk, color fading.',
    warnings: [],
    gender: 'both',
  },
];

// ============================================
// ANALYSIS FUNCTIONS
// ============================================

/**
 * Generate strengths from harmony analysis by grouping related high-scoring metrics.
 *
 * First pass: Creates grouped strengths from related high-scoring metrics (2+ metrics >= 7.5).
 * Second pass: Adds remaining individual strengths that weren't grouped.
 *
 * @param analysis - HarmonyAnalysis containing measurements and strengths
 * @returns Array of Strength objects sorted by contributing ratios count then score
 */
export function generateStrengthsFromAnalysis(analysis: HarmonyAnalysis): Strength[] {
  const strengths: Strength[] = [];
  const usedMetricIds = new Set<string>();

  // First pass: Create grouped strengths from related high-scoring metrics
  Object.entries(STRENGTH_GROUPINGS).forEach(([groupId, groupConfig]) => {
    // Find all high-scoring measurements that belong to this group
    const groupMeasurements = analysis.measurements.filter(m =>
      groupConfig.metrics.includes(m.metricId) &&
      m.score >= 7.5 &&
      !usedMetricIds.has(m.metricId)
    );

    // Only create a grouped strength if we have 2+ metrics with good scores
    if (groupMeasurements.length >= 2) {
      const avgScore = groupMeasurements.reduce((sum, m) => sum + m.score, 0) / groupMeasurements.length;
      const bestQuality = avgScore >= 9 ? 'excellent' : avgScore >= 8 ? 'good' : 'below_average';

      // Mark these metrics as used
      groupMeasurements.forEach(m => usedMetricIds.add(m.metricId));

      // Create grouped strength with multiple contributing ratios
      strengths.push({
        id: `strength_group_${groupId}`,
        strengthName: groupConfig.name,
        summary: groupConfig.description,
        avgScore,
        qualityLevel: bestQuality,
        categoryName: groupConfig.category,
        responsibleRatios: groupMeasurements.map(m => ({
          ratioName: m.name,
          ratioId: m.metricId,
          score: m.score,
          value: m.value,
          idealMin: m.idealMin,
          idealMax: m.idealMax,
          unit: m.unit,
          category: m.category,
        })),
      });
    }
  });

  // Second pass: Add remaining individual strengths that weren't grouped
  analysis.strengths.forEach((s, i) => {
    if (usedMetricIds.has(s.metricId)) return; // Skip if already used in a group

    const matchingMeasurement = analysis.measurements.find(m => m.metricId === s.metricId);

    strengths.push({
      id: `strength_${i}`,
      strengthName: s.metricName,
      summary: s.reasoning,
      avgScore: matchingMeasurement?.score || 8,
      qualityLevel: s.qualityTier,
      categoryName: s.category,
      responsibleRatios: [{
        ratioName: s.metricName,
        ratioId: s.metricId,
        score: matchingMeasurement?.score || 8,
        value: s.value,
        idealMin: matchingMeasurement?.idealMin || 0,
        idealMax: matchingMeasurement?.idealMax || 1,
        unit: matchingMeasurement?.unit || 'ratio',
        category: s.category,
      }],
    });
  });

  // Sort by average score (highest first) then by number of contributing ratios
  return strengths.sort((a, b) => {
    if (b.responsibleRatios.length !== a.responsibleRatios.length) {
      return b.responsibleRatios.length - a.responsibleRatios.length;
    }
    const bScore = typeof b.avgScore === 'number' ? b.avgScore : 0;
    const aScore = typeof a.avgScore === 'number' ? a.avgScore : 0;
    return bScore - aScore;
  });
}

/**
 * Generate flaws from harmony analysis by grouping related low-scoring metrics.
 *
 * First pass: Creates grouped flaws from related low-scoring metrics (2+ metrics < 6).
 * Second pass: Adds remaining individual flaws that weren't grouped.
 *
 * @param analysis - HarmonyAnalysis containing measurements and flaws
 * @returns Array of Flaw objects sorted by contributing ratios count then impact
 */
export function generateFlawsFromAnalysis(analysis: HarmonyAnalysis): Flaw[] {
  const flaws: Flaw[] = [];
  const usedMetricIds = new Set<string>();
  let rollingLost = 0;

  // First pass: Create grouped flaws from related low-scoring metrics
  Object.entries(FLAW_GROUPINGS).forEach(([groupId, groupConfig]) => {
    // Find all low-scoring measurements that belong to this group
    const groupMeasurements = analysis.measurements.filter(m =>
      groupConfig.metrics.includes(m.metricId) &&
      m.score < 6 &&
      !usedMetricIds.has(m.metricId)
    );

    // Only create a grouped flaw if we have 2+ metrics with low scores
    if (groupMeasurements.length >= 2) {
      // Mark these metrics as used
      groupMeasurements.forEach(m => usedMetricIds.add(m.metricId));

      // Calculate total impact from all metrics in this group
      const totalImpact = groupMeasurements.reduce((sum, m) => sum + (10 - m.score) * 0.4, 0);
      rollingLost += totalImpact;

      // Create grouped flaw with multiple contributing ratios
      flaws.push({
        id: `flaw_group_${groupId}`,
        flawName: groupConfig.name,
        summary: groupConfig.description,
        harmonyPercentageLost: totalImpact,
        standardizedImpact: totalImpact / 10,
        categoryName: groupConfig.category,
        responsibleRatios: groupMeasurements.map(m => ({
          ratioName: m.name,
          ratioId: m.metricId,
          score: m.score,
          value: m.value,
          idealMin: m.idealMin,
          idealMax: m.idealMax,
          unit: m.unit,
          category: m.category,
        })),
        rollingPointsDeducted: rollingLost,
        rollingHarmonyPercentageLost: rollingLost,
        rollingStandardizedImpact: rollingLost / 10,
      });
    }
  });

  // Second pass: Add remaining individual flaws that weren't grouped
  analysis.flaws.forEach((f, i) => {
    if (usedMetricIds.has(f.metricId)) return; // Skip if already used in a group

    const matchingMeasurement = analysis.measurements.find(m => m.metricId === f.metricId);
    const impact = matchingMeasurement ? (10 - matchingMeasurement.score) * 0.5 : 2;
    rollingLost += impact;

    flaws.push({
      id: `flaw_${i}`,
      flawName: f.metricName,
      summary: f.reasoning,
      harmonyPercentageLost: impact,
      standardizedImpact: impact / 10,
      categoryName: f.category,
      responsibleRatios: [{
        ratioName: f.metricName,
        ratioId: f.metricId,
        score: matchingMeasurement?.score || 3,
        value: matchingMeasurement?.value || 0,
        idealMin: matchingMeasurement?.idealMin || 0,
        idealMax: matchingMeasurement?.idealMax || 1,
        unit: matchingMeasurement?.unit || 'ratio',
        category: f.category,
      }],
      rollingPointsDeducted: rollingLost,
      rollingHarmonyPercentageLost: rollingLost,
      rollingStandardizedImpact: rollingLost / 10,
    });
  });

  // Sort by impact (highest first) then by number of contributing ratios
  return flaws.sort((a, b) => {
    if (b.responsibleRatios.length !== a.responsibleRatios.length) {
      return b.responsibleRatios.length - a.responsibleRatios.length;
    }
    return b.harmonyPercentageLost - a.harmonyPercentageLost;
  });
}

// ============================================
// RECOMMENDATION FUNCTIONS
// ============================================

/**
 * Calculate relevance score based on multiple factors including metric scores.
 *
 * Scoring factors:
 * - Metric ID match (highest priority): +40 base, +0-20 based on metric poorness
 * - Category match: +25
 * - Keyword match: +15 primary (in flaw name), +8 secondary (in summary)
 * - Flaw severity: +0-20 based on harmonyPercentageLost
 * - Multi-flaw coverage: +7 per additional flaw addressed
 * - Below-average ratio targeting: +8 per matching ratio
 *
 * @param proc - Procedure configuration
 * @param flaw - Current flaw being matched
 * @param allFlaws - All flaws for multi-flaw bonus calculation
 * @param allRatios - All ratios for direct metric targeting
 * @returns Relevance score (0-100)
 */
export function calculateRelevanceScore(
  proc: ProcedureConfig,
  flaw: Flaw,
  allFlaws: Flaw[],
  allRatios: Ratio[] = []
): number {
  let score = 0;

  // Check metric ID match (highest priority)
  const metricId = flaw.responsibleRatios[0]?.ratioId || '';
  const rawScore = flaw.responsibleRatios[0]?.score;
  const metricScore = typeof rawScore === 'number' ? rawScore : 5;

  if (proc.targetMetrics.includes(metricId)) {
    // Base score for metric match
    score += 40;

    // Boost based on how poor the metric score is (lower score = more improvement potential)
    // Score of 2 adds +20, score of 8 adds +5
    const metricPoorness = Math.max(0, 10 - metricScore) * 2;
    score += metricPoorness;
  }

  // Check category match
  if (proc.targetCategories.some(cat =>
    flaw.categoryName.toLowerCase().includes(cat.toLowerCase()) ||
    cat.toLowerCase().includes(flaw.categoryName.toLowerCase())
  )) {
    score += 25;
  }

  // Check keyword match with weighted scoring
  const flawLower = flaw.flawName.toLowerCase();
  const summaryLower = flaw.summary.toLowerCase();
  const matchedKeywords = proc.targetKeywords.filter(kw =>
    flawLower.includes(kw.toLowerCase()) || summaryLower.includes(kw.toLowerCase())
  );
  // Primary keyword match (in flaw name) worth more
  const primaryMatches = matchedKeywords.filter(kw => flawLower.includes(kw.toLowerCase()));
  score += primaryMatches.length * 15;
  score += (matchedKeywords.length - primaryMatches.length) * 8;

  // Adjust by flaw severity/impact (more severe = higher priority)
  score += Math.min(flaw.harmonyPercentageLost * 4, 20);

  // Bonus if this procedure addresses multiple flaws
  const otherFlawsAddressed = allFlaws.filter(f =>
    f.id !== flaw.id && (
      proc.targetMetrics.includes(f.responsibleRatios[0]?.ratioId || '') ||
      proc.targetCategories.some(cat => f.categoryName.toLowerCase().includes(cat.toLowerCase()))
    )
  );
  score += otherFlawsAddressed.length * 7;

  // Check if procedure targets any below-average ratios directly
  const matchingRatios = allRatios.filter(r =>
    proc.targetMetrics.includes(r.id) && (typeof r.score === 'number' ? r.score : 0) < 6
  );
  score += matchingRatios.length * 8;

  return Math.min(score, 100);
}

/**
 * Calculate expected score improvement using Bezier recalculation.
 * Instead of simple addition, we recalculate the score at the ideal value.
 *
 * @param proc - Procedure configuration
 * @param matchedRatios - Ratios that this procedure affects
 * @param avgFlawImpact - Average impact of matched flaws
 * @param gender - User's gender for scoring
 * @param ethnicity - User's ethnicity for scoring
 * @returns Object with min, max improvement and potential score
 */
export function calculateExpectedImprovement(
  proc: ProcedureConfig,
  matchedRatios: Ratio[],
  avgFlawImpact: number,
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'other'
): { min: number; max: number; potential: number } {
  // If no matched ratios, use fallback estimation
  if (matchedRatios.length === 0) {
    const baseImprovement = proc.expectedImprovementRange.max * Math.min(avgFlawImpact / 2.5, 1.5);
    return {
      min: Math.round(proc.expectedImprovementRange.min * 100) / 100,
      max: Math.round(baseImprovement * 100) / 100,
      potential: 7.5, // Default to "good" when we can't calculate precisely
    };
  }

  // Harmony-style Bezier recalculation:
  // For each ratio, calculate what the score would be at the ideal value
  let totalCurrentWeighted = 0;
  let totalIdealWeighted = 0;
  let totalWeight = 0;

  matchedRatios.forEach(ratio => {
    const config = METRIC_CONFIGS[ratio.id];
    if (!config) return;

    // Current score from the ratio
    const currentScore = typeof ratio.score === 'number' ? ratio.score : 0;

    // Calculate ideal value (midpoint of ideal range)
    const idealValue = (config.idealMin + config.idealMax) / 2;

    // Use Bezier curve to calculate what the score would be at ideal
    const idealResult = scoreMeasurement(ratio.id, idealValue, { gender, ethnicity });
    const idealScore = idealResult?.standardizedScore || 10;

    // Weight by procedure effectiveness on this metric
    // Procedures that target this metric get more weight
    const isTargeted = proc.targetMetrics.includes(ratio.id);
    const metricWeight = isTargeted ? 1.5 : 1.0;

    // Also weight by how far from ideal (more room to improve = more impact)
    const deviationWeight = Math.max(0.5, (10 - currentScore) / 5);

    const weight = metricWeight * deviationWeight * config.weight;

    totalCurrentWeighted += currentScore * weight;
    totalIdealWeighted += idealScore * weight;
    totalWeight += weight;
  });

  // Calculate weighted average scores
  const avgCurrentScore = totalWeight > 0 ? totalCurrentWeighted / totalWeight : 5;
  const avgIdealScore = totalWeight > 0 ? totalIdealWeighted / totalWeight : 10;

  // The maximum improvement is the gap between current and ideal
  const maxPossibleImprovement = avgIdealScore - avgCurrentScore;

  // Apply procedure effectiveness factor (from expectedImprovementRange)
  // This represents what percentage of the ideal we can realistically achieve
  const effectivenessRatio = proc.expectedImprovementRange.max;

  // Min improvement: conservative estimate
  const minImprovement = maxPossibleImprovement * 0.3 * effectivenessRatio;
  // Max improvement: optimistic but realistic
  const maxImprovement = maxPossibleImprovement * 0.7 * effectivenessRatio;

  // Potential score: current + realistic improvement from Bezier calculation
  const potentialScore = Math.min(10, avgCurrentScore + (maxImprovement * 0.8));

  return {
    min: Math.round(minImprovement * 100) / 100,
    max: Math.round(maxImprovement * 100) / 100,
    potential: Math.round(potentialScore * 10) / 10,
  };
}

/**
 * Generate procedure recommendations based on identified flaws.
 *
 * Process:
 * 1. Match each flaw against all procedures using relevance scoring
 * 2. Aggregate matches to find procedures that address multiple flaws
 * 3. Calculate expected improvement using Bezier recalculation
 * 4. Compute priority scores and sort by effectiveness
 *
 * @param flaws - Array of identified flaws
 * @param frontRatios - Front profile ratios
 * @param sideRatios - Side profile ratios
 * @param gender - User's gender
 * @param ethnicity - User's ethnicity
 * @returns Array of Recommendation objects sorted by priority
 */
export function generateRecommendations(
  flaws: Flaw[],
  frontRatios: Ratio[] = [],
  sideRatios: Ratio[] = [],
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'other'
): Recommendation[] {
  const recommendations: Recommendation[] = [];
  const allRatios = [...frontRatios, ...sideRatios];

  // Track which procedures have been added and their matched flaws
  const procMatches: Map<string, {
    flaws: string[];
    ratios: string[];
    ratioIds: string[];
    maxScore: number;
    totalFlawImpact: number;
  }> = new Map();

  flaws.forEach(flaw => {
    PROCEDURE_DATABASE.forEach(proc => {
      // Pass allRatios to the enhanced relevance scoring
      const relevanceScore = calculateRelevanceScore(proc, flaw, flaws, allRatios);

      if (relevanceScore >= 25) {  // Minimum threshold
        const existing = procMatches.get(proc.ref_id);
        if (existing) {
          existing.flaws.push(flaw.flawName);
          existing.ratios.push(...flaw.responsibleRatios.map(r => r.ratioName));
          existing.ratioIds.push(...flaw.responsibleRatios.map(r => r.ratioId));
          existing.maxScore = Math.max(existing.maxScore, relevanceScore);
          existing.totalFlawImpact += flaw.harmonyPercentageLost;
        } else {
          procMatches.set(proc.ref_id, {
            flaws: [flaw.flawName],
            ratios: flaw.responsibleRatios.map(r => r.ratioName),
            ratioIds: flaw.responsibleRatios.map(r => r.ratioId),
            maxScore: relevanceScore,
            totalFlawImpact: flaw.harmonyPercentageLost,
          });
        }
      }
    });
  });

  // Build recommendations from matched procedures
  procMatches.forEach((match, procId) => {
    const proc = PROCEDURE_DATABASE.find(p => p.ref_id === procId);
    if (!proc) return;

    // Get affected ratios from the actual data (including directly targeted metrics)
    const affectedRatios = allRatios.filter(r =>
      proc.targetMetrics.includes(r.id) ||
      match.ratioIds.includes(r.id) ||
      match.flaws.some(f => f.toLowerCase().includes(r.category.toLowerCase()))
    );

    // Calculate expected improvement with Bezier recalculation
    const avgFlawImpact = match.totalFlawImpact / match.flaws.length;
    const improvement = calculateExpectedImprovement(proc, affectedRatios, avgFlawImpact, gender, ethnicity);

    // Calculate priority score based on multiple factors
    const priorityScore =
      (match.maxScore * 0.4) +  // Relevance weight
      (match.flaws.length * 8) +  // Multi-flaw bonus
      (avgFlawImpact * 3) +  // Severity weight
      (proc.baseImpact * 25);  // Procedure effectiveness

    // Adjust impact based on how well this procedure addresses the specific issues
    const adjustedImpact = Math.min(
      1.0,
      proc.baseImpact * (0.85 + (match.maxScore / 400)) * (1 + (match.flaws.length * 0.05))
    );

    // Calculate direction for each affected ratio
    const ratiosImpacted = affectedRatios.map(r => {
      // Determine direction based on deviation
      const numericValue = typeof r.value === 'number' ? r.value : 0;
      let direction: 'increase' | 'decrease' | 'both' = 'both';
      if (numericValue < r.idealMin) {
        direction = 'increase';
      } else if (numericValue > r.idealMax) {
        direction = 'decrease';
      }

      // Calculate percentage effect based on how far from ideal and procedure strength
      const deviation = numericValue < r.idealMin
        ? r.idealMin - numericValue
        : numericValue > r.idealMax
          ? numericValue - r.idealMax
          : 0;
      const normalizedDeviation = deviation / ((r.rangeMax - r.rangeMin) / 2);
      const percentageEffect = proc.baseImpact * Math.min(normalizedDeviation * 1.5, 1.5);

      return {
        ratioId: r.id,
        ratioName: r.name,
        direction,
        percentageEffect: Math.round(percentageEffect * 100) / 100,
      };
    });

    recommendations.push({
      ref_id: proc.ref_id,
      name: proc.name,
      description: proc.description,
      phase: proc.phase,
      impact: adjustedImpact,
      coverage: match.flaws.length + Math.min(match.ratios.length, 5),
      percentage: proc.percentage,
      expectedImprovementRange: {
        min: improvement.min,
        max: improvement.max,
      },
      matchedFlaws: Array.from(new Set(match.flaws)),
      matchedRatios: Array.from(new Set(match.ratios)),
      ratios_impacted: ratiosImpacted,
      timeline: proc.timeline,
      cost: proc.cost,
      risks_side_effects: proc.risks_side_effects,
      warnings: proc.warnings,
      gender: proc.gender,
      // Add priority score as a sorting key (stored in coverage field calculation)
      _priorityScore: priorityScore,
    } as Recommendation & { _priorityScore: number });
  });

  // Sort by priority score (combines impact, coverage, and severity)
  return recommendations.sort((a, b) => {
    const aScore = (a as Recommendation & { _priorityScore?: number })._priorityScore || (a.impact * 100);
    const bScore = (b as Recommendation & { _priorityScore?: number })._priorityScore || (b.impact * 100);
    const scoreDiff = bScore - aScore;
    if (Math.abs(scoreDiff) > 5) return scoreDiff;
    // Tiebreaker: prefer procedures that address more flaws
    return b.matchedFlaws.length - a.matchedFlaws.length;
  });
}
