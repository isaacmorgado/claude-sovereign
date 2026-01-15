'use client';

import React, { createContext, useContext, useState, useMemo, useCallback, ReactNode } from 'react';
import { LandmarkPoint } from '@/lib/landmarks';
import {
  analyzeFrontProfile,
  analyzeSideProfile,
  analyzeHarmony,
  HarmonyAnalysis,
  MetricScoreResult,
  METRIC_CONFIGS,
  Ethnicity,
  Gender,
} from '@/lib/harmony-scoring';
import {
  calculateHarmonyScore,
  getTopMetrics,
  getBottomMetrics,
  HarmonyScoreResult,
  RankedMetric,
} from '@/lib/looksmax-scoring';
import { harmonyToPSL } from '@/lib/recommendations/severity';
import {
  classifyInsights,
  convertToStrength,
  convertToFlaw,
  INSIGHTS_DEFINITIONS,
} from '@/lib/insights-engine';
import { classifyMetric } from '@/lib/taxonomy';
import {
  Ratio,
  Strength,
  Flaw,
  Recommendation,
  ResultsTab,
  FullHarmonyAnalysis,
} from '@/types/results';
import { generateRecommendations } from '@/lib/results/analysis';

// ============================================
// CONTEXT TYPES
// ============================================

interface ResultsContextType {
  // Raw data
  frontLandmarks: LandmarkPoint[];
  sideLandmarks: LandmarkPoint[];
  gender: Gender;
  ethnicity: Ethnicity;
  frontPhoto: string;
  sidePhoto: string | null;

  // Computed results
  harmonyAnalysis: FullHarmonyAnalysis | null;
  frontRatios: Ratio[];
  sideRatios: Ratio[];
  strengths: Strength[];
  flaws: Flaw[];
  recommendations: Recommendation[];

  // Scores (now using weighted harmony from looksmax_engine.py)
  overallScore: number;
  frontScore: number;
  sideScore: number;

  // Weighted Harmony Score (from looksmax_engine.py)
  harmonyScoreResult: HarmonyScoreResult | null;
  harmonyPercentage: number;  // 0-100% weighted harmony

  // Top 3 strengths and bottom 3 areas to improve with advice
  topMetrics: RankedMetric[];
  bottomMetrics: RankedMetric[];

  // PSL Rating (1-10 scale)
  pslRating: {
    psl: number;
    tier: string;
    percentile: number;
    description: string;
  };

  // UI state
  activeTab: ResultsTab;
  setActiveTab: (tab: ResultsTab) => void;
  expandedMeasurementId: string | null;
  setExpandedMeasurementId: (id: string | null) => void;
  selectedVisualizationMetric: string | null;
  setSelectedVisualizationMetric: (id: string | null) => void;
  categoryFilter: string | null;
  setCategoryFilter: (category: string | null) => void;
  showLandmarkOverlay: boolean;
  setShowLandmarkOverlay: (show: boolean) => void;

  // Actions
  setResultsData: (data: ResultsInputData) => void;
}

interface ResultsInputData {
  frontLandmarks: LandmarkPoint[];
  sideLandmarks: LandmarkPoint[];
  frontPhoto: string;
  sidePhoto?: string;
  gender: Gender;
  ethnicity?: Ethnicity;
}

// ============================================
// HELPER FUNCTIONS
// ============================================

function convertUnitToRatioUnit(unit: string): 'x' | 'mm' | '%' | '°' {
  switch (unit) {
    case 'ratio': return 'x';
    case 'percent': return '%';
    case 'degrees': return '°';
    case 'mm': return 'mm';
    default: return 'x';
  }
}

function transformToRatio(result: MetricScoreResult, landmarks: LandmarkPoint[]): Ratio {
  const metricConfig = METRIC_CONFIGS[result.metricId];

  // Generate illustration based on metric
  const illustration = generateIllustration(result.metricId, landmarks);

  // Get flaw/strength mappings
  const { mayIndicateFlaws, mayIndicateStrengths } = getFlawStrengthMappings(result);

  // Classify metric using Harmony taxonomy
  const taxonomyClassification = classifyMetric(result.name, result.category);

  return {
    id: result.metricId,
    name: result.name,
    value: result.value,
    score: result.standardizedScore,  // Use standardized 0-10 score for UI display
    standardizedScore: result.standardizedScore,
    unit: convertUnitToRatioUnit(result.unit),
    idealMin: result.idealMin,
    idealMax: result.idealMax,
    rangeMin: metricConfig?.rangeMin || result.idealMin - 0.5,
    rangeMax: metricConfig?.rangeMax || result.idealMax + 0.5,
    description: metricConfig?.description || '',
    category: result.category,
    qualityLevel: result.qualityTier,
    severity: result.severity,
    illustration,
    mayIndicateFlaws,
    mayIndicateStrengths,
    usedLandmarks: getUsedLandmarks(result.metricId),
    scoringCurveConfig: metricConfig ? {
      decayRate: metricConfig.decayRate,
      maxScore: metricConfig.maxScore,
    } : undefined,
    taxonomyPrimary: taxonomyClassification?.primary,
    taxonomySecondary: taxonomyClassification?.secondary,
  };
}

// Enhanced illustration configuration type
interface IllustrationConfig {
  points: string[];
  lines: Array<{
    from: string;
    to: string;
    label?: string;
    color?: string;
    labelPosition?: 'start' | 'middle' | 'end';  // Matches IllustrationLine type
  }>;
}

// Comprehensive illustration configurations for all metrics
const ILLUSTRATION_CONFIGS: Record<string, IllustrationConfig> = {
  // ==========================================
  // FACE SHAPE / PROPORTIONS
  // ==========================================
  faceWidthToHeight: {
    points: ['left_zygion', 'right_zygion', 'trichion', 'menton'],
    lines: [
      { from: 'left_zygion', to: 'right_zygion', label: 'Width', color: '#67e8f9', labelPosition: 'middle' },
      { from: 'trichion', to: 'menton', label: 'Height', color: '#a78bfa', labelPosition: 'end' },
    ],
  },
  totalFacialWidthToHeight: {
    points: ['left_zygion', 'right_zygion', 'trichion', 'menton'],
    lines: [
      { from: 'left_zygion', to: 'right_zygion', label: 'Cheek Width', color: '#67e8f9' },
      { from: 'trichion', to: 'menton', label: 'Total Height', color: '#a78bfa' },
    ],
  },
  lowerThirdProportion: {
    points: ['subnasale', 'menton', 'trichion'],
    lines: [
      { from: 'subnasale', to: 'menton', label: 'Lower Third', color: '#f97316', labelPosition: 'end' },
      { from: 'trichion', to: 'menton', label: 'Full Height', color: '#67e8f9', labelPosition: 'start' },
    ],
  },
  middleThirdProportion: {
    points: ['nasal_base', 'subnasale', 'trichion', 'menton'],
    lines: [
      { from: 'nasal_base', to: 'subnasale', label: 'Middle Third', color: '#22c55e', labelPosition: 'end' },
      { from: 'trichion', to: 'menton', label: 'Full Height', color: '#67e8f9', labelPosition: 'start' },
    ],
  },
  upperThirdProportion: {
    points: ['trichion', 'nasal_base', 'menton'],
    lines: [
      { from: 'trichion', to: 'nasal_base', label: 'Upper Third', color: '#fbbf24', labelPosition: 'end' },
      { from: 'trichion', to: 'menton', label: 'Full Height', color: '#67e8f9', labelPosition: 'start' },
    ],
  },
  bitemporalWidth: {
    points: ['left_temporal', 'right_temporal', 'left_zygion', 'right_zygion'],
    lines: [
      { from: 'left_temporal', to: 'right_temporal', label: 'Temple', color: '#fbbf24' },
      { from: 'left_zygion', to: 'right_zygion', label: 'Cheek', color: '#67e8f9' },
    ],
  },
  cheekboneHeight: {
    points: ['left_zygion', 'right_zygion', 'left_canthus_lateralis', 'right_canthus_lateralis', 'menton'],
    lines: [
      { from: 'left_zygion', to: 'right_zygion', label: 'Cheekbone', color: '#ec4899' },
      { from: 'left_canthus_lateralis', to: 'left_zygion', color: '#67e8f9' },
    ],
  },
  midfaceRatio: {
    points: ['left_zygion', 'right_zygion', 'left_canthus_medialis', 'right_canthus_medialis', 'subnasale'],
    lines: [
      { from: 'left_canthus_medialis', to: 'right_canthus_medialis', label: 'Midface Width', color: '#67e8f9' },
      { from: 'left_canthus_medialis', to: 'subnasale', label: 'Midface Height', color: '#a78bfa' },
    ],
  },

  // ==========================================
  // JAW MEASUREMENTS
  // ==========================================
  jawSlope: {
    points: ['left_gonion_inferior', 'left_mentum_lateralis', 'menton', 'right_mentum_lateralis', 'right_gonion_inferior'],
    lines: [
      { from: 'left_gonion_inferior', to: 'left_mentum_lateralis', label: 'Jaw Slope', color: '#f97316' },
      { from: 'right_gonion_inferior', to: 'right_mentum_lateralis', color: '#f97316' },
    ],
  },
  jawFrontalAngle: {
    points: ['left_gonion_inferior', 'menton', 'right_gonion_inferior'],
    lines: [
      { from: 'left_gonion_inferior', to: 'menton', label: 'Jaw Angle', color: '#f97316' },
      { from: 'menton', to: 'right_gonion_inferior', color: '#f97316' },
    ],
  },
  bigonialWidth: {
    points: ['left_gonion_inferior', 'right_gonion_inferior', 'left_zygion', 'right_zygion'],
    lines: [
      { from: 'left_gonion_inferior', to: 'right_gonion_inferior', label: 'Jaw Width', color: '#f97316' },
      { from: 'left_zygion', to: 'right_zygion', label: 'Cheek Width', color: '#67e8f9' },
    ],
  },
  jawWidthRatio: {
    points: ['left_gonion_inferior', 'right_gonion_inferior', 'left_zygion', 'right_zygion'],
    lines: [
      { from: 'left_gonion_inferior', to: 'right_gonion_inferior', label: 'Jaw', color: '#f97316' },
      { from: 'left_zygion', to: 'right_zygion', label: 'Face', color: '#67e8f9' },
    ],
  },

  // ==========================================
  // EYE MEASUREMENTS
  // ==========================================
  lateralCanthalTilt: {
    points: ['left_canthus_medialis', 'left_canthus_lateralis', 'right_canthus_medialis', 'right_canthus_lateralis'],
    lines: [
      { from: 'left_canthus_medialis', to: 'left_canthus_lateralis', label: 'Tilt', color: '#06b6d4', labelPosition: 'end' },
      { from: 'right_canthus_medialis', to: 'right_canthus_lateralis', color: '#06b6d4' },
    ],
  },
  eyeAspectRatio: {
    points: ['left_canthus_medialis', 'left_canthus_lateralis', 'left_palpebra_superior', 'left_palpebra_inferior'],
    lines: [
      { from: 'left_canthus_medialis', to: 'left_canthus_lateralis', label: 'Width', color: '#06b6d4' },
      { from: 'left_palpebra_superior', to: 'left_palpebra_inferior', label: 'Height', color: '#a78bfa' },
    ],
  },
  eyeSeparationRatio: {
    points: ['left_canthus_medialis', 'right_canthus_medialis', 'left_zygion', 'right_zygion'],
    lines: [
      { from: 'left_canthus_medialis', to: 'right_canthus_medialis', label: 'Intercanthal', color: '#06b6d4' },
      { from: 'left_zygion', to: 'right_zygion', label: 'Face Width', color: '#67e8f9' },
    ],
  },
  interpupillaryRatio: {
    points: ['left_pupila', 'right_pupila', 'left_zygion', 'right_zygion'],
    lines: [
      { from: 'left_pupila', to: 'right_pupila', label: 'IPD', color: '#06b6d4' },
      { from: 'left_zygion', to: 'right_zygion', label: 'Face Width', color: '#67e8f9' },
    ],
  },
  interpupillaryMouthWidthRatio: {
    points: ['left_pupila', 'right_pupila', 'left_cheilion', 'right_cheilion'],
    lines: [
      { from: 'left_pupila', to: 'right_pupila', label: 'IPD', color: '#06b6d4' },
      { from: 'left_cheilion', to: 'right_cheilion', label: 'Mouth', color: '#ec4899' },
    ],
  },
  oneEyeApartTest: {
    points: ['left_canthus_medialis', 'right_canthus_medialis', 'left_canthus_lateralis'],
    lines: [
      { from: 'left_canthus_medialis', to: 'right_canthus_medialis', label: 'Between Eyes', color: '#06b6d4' },
      { from: 'left_canthus_medialis', to: 'left_canthus_lateralis', label: 'Eye Width', color: '#a78bfa' },
    ],
  },

  // ==========================================
  // EYEBROW MEASUREMENTS
  // ==========================================
  browLengthRatio: {
    points: ['left_supercilium_medialis', 'left_supercilium_lateralis', 'left_zygion', 'right_zygion'],
    lines: [
      { from: 'left_supercilium_medialis', to: 'left_supercilium_lateralis', label: 'Brow', color: '#84cc16' },
      { from: 'left_zygion', to: 'right_zygion', label: 'Face Width', color: '#67e8f9' },
    ],
  },
  eyebrowTilt: {
    points: ['left_supercilium_medialis', 'left_supercilium_apex', 'left_supercilium_lateralis'],
    lines: [
      { from: 'left_supercilium_medialis', to: 'left_supercilium_apex', label: 'Tilt', color: '#84cc16' },
      { from: 'left_supercilium_apex', to: 'left_supercilium_lateralis', color: '#84cc16' },
    ],
  },
  eyebrowLowSetedness: {
    points: ['left_supercilium_medialis', 'left_palpebra_superior', 'left_canthus_medialis'],
    lines: [
      { from: 'left_supercilium_medialis', to: 'left_palpebra_superior', label: 'Brow-Eye Gap', color: '#84cc16' },
    ],
  },

  // ==========================================
  // NOSE MEASUREMENTS (FRONT)
  // ==========================================
  nasalIndex: {
    points: ['left_ala_nasi', 'right_ala_nasi', 'nasal_base', 'subnasale'],
    lines: [
      { from: 'left_ala_nasi', to: 'right_ala_nasi', label: 'Width', color: '#fbbf24' },
      { from: 'nasal_base', to: 'subnasale', label: 'Height', color: '#a78bfa' },
    ],
  },
  intercanthalNasalRatio: {
    points: ['left_ala_nasi', 'right_ala_nasi', 'left_canthus_medialis', 'right_canthus_medialis'],
    lines: [
      { from: 'left_ala_nasi', to: 'right_ala_nasi', label: 'Nose Width', color: '#fbbf24' },
      { from: 'left_canthus_medialis', to: 'right_canthus_medialis', label: 'Intercanthal', color: '#06b6d4' },
    ],
  },
  noseBridgeWidth: {
    points: ['left_dorsum_nasi', 'right_dorsum_nasi', 'left_ala_nasi', 'right_ala_nasi'],
    lines: [
      { from: 'left_dorsum_nasi', to: 'right_dorsum_nasi', label: 'Bridge', color: '#fbbf24' },
      { from: 'left_ala_nasi', to: 'right_ala_nasi', label: 'Base', color: '#f97316' },
    ],
  },
  noseTipPosition: {
    points: ['subnasale', 'left_ala_nasi', 'right_ala_nasi'],
    lines: [
      { from: 'left_ala_nasi', to: 'right_ala_nasi', label: 'Tip Position', color: '#fbbf24' },
    ],
  },

  // ==========================================
  // MOUTH/LIP MEASUREMENTS
  // ==========================================
  mouthNoseWidthRatio: {
    points: ['left_cheilion', 'right_cheilion', 'left_ala_nasi', 'right_ala_nasi'],
    lines: [
      { from: 'left_cheilion', to: 'right_cheilion', label: 'Mouth', color: '#ec4899' },
      { from: 'left_ala_nasi', to: 'right_ala_nasi', label: 'Nose', color: '#fbbf24' },
    ],
  },
  lowerUpperLipRatio: {
    points: ['labrale_superius', 'mouth_middle', 'labrale_inferius'],
    lines: [
      { from: 'labrale_superius', to: 'mouth_middle', label: 'Upper', color: '#ec4899' },
      { from: 'mouth_middle', to: 'labrale_inferius', label: 'Lower', color: '#f97316' },
    ],
  },
  chinPhiltrumRatio: {
    points: ['subnasale', 'labrale_superius', 'labrale_inferius', 'menton'],
    lines: [
      { from: 'subnasale', to: 'labrale_superius', label: 'Philtrum', color: '#ec4899' },
      { from: 'labrale_inferius', to: 'menton', label: 'Chin', color: '#ef4444' },
    ],
  },
  mouthWidth: {
    points: ['left_cheilion', 'right_cheilion'],
    lines: [{ from: 'left_cheilion', to: 'right_cheilion', label: 'Mouth Width', color: '#ec4899' }],
  },

  // ==========================================
  // CHIN MEASUREMENTS
  // ==========================================
  chinHeight: {
    points: ['labrale_inferius', 'menton'],
    lines: [{ from: 'labrale_inferius', to: 'menton', label: 'Chin Height', color: '#ef4444' }],
  },

  // ==========================================
  // NECK MEASUREMENTS
  // ==========================================
  neckWidthRatio: {
    points: ['left_cervical_lateralis', 'right_cervical_lateralis', 'left_gonion_inferior', 'right_gonion_inferior'],
    lines: [
      { from: 'left_cervical_lateralis', to: 'right_cervical_lateralis', label: 'Neck', color: '#14b8a6' },
      { from: 'left_gonion_inferior', to: 'right_gonion_inferior', label: 'Jaw', color: '#f97316' },
    ],
  },

  // ==========================================
  // SIDE PROFILE MEASUREMENTS
  // ==========================================
  gonialAngle: {
    points: ['tragus', 'gonionBottom', 'menton'],
    lines: [
      { from: 'tragus', to: 'gonionBottom', label: 'Ramus', color: '#f97316' },
      { from: 'gonionBottom', to: 'menton', label: 'Mandible', color: '#ef4444' },
    ],
  },
  nasofrontalAngle: {
    points: ['glabella', 'nasion', 'pronasale'],
    lines: [
      { from: 'glabella', to: 'nasion', label: 'Forehead', color: '#84cc16' },
      { from: 'nasion', to: 'pronasale', label: 'Nose', color: '#fbbf24' },
    ],
  },
  nasofacialAngle: {
    points: ['nasion', 'pronasale', 'pogonion'],
    lines: [
      { from: 'nasion', to: 'pronasale', color: '#fbbf24' },
      { from: 'pronasale', to: 'pogonion', color: '#67e8f9' },
    ],
  },
  nasomentaAngle: {
    points: ['nasion', 'pronasale', 'pogonion'],
    lines: [
      { from: 'nasion', to: 'pronasale', label: 'Nose', color: '#fbbf24' },
      { from: 'pronasale', to: 'pogonion', label: 'To Chin', color: '#ef4444' },
    ],
  },
  submentalCervicalAngle: {
    points: ['menton', 'cervicalPoint', 'neckPoint'],
    lines: [
      { from: 'menton', to: 'cervicalPoint', label: 'Submental', color: '#14b8a6' },
      { from: 'cervicalPoint', to: 'neckPoint', label: 'Cervical', color: '#06b6d4' },
    ],
  },
  facialDepthToHeight: {
    points: ['pronasale', 'tragus', 'nasion', 'menton'],
    lines: [
      { from: 'pronasale', to: 'tragus', label: 'Depth', color: '#67e8f9' },
      { from: 'nasion', to: 'menton', label: 'Height', color: '#a78bfa' },
    ],
  },
  anteriorFacialDepth: {
    points: ['glabella', 'pronasale', 'pogonion'],
    lines: [
      { from: 'glabella', to: 'pronasale', color: '#67e8f9' },
      { from: 'pronasale', to: 'pogonion', color: '#a78bfa' },
    ],
  },
  mandibularPlaneAngle: {
    points: ['gonionBottom', 'menton', 'orbitale', 'porion'],
    lines: [
      { from: 'gonionBottom', to: 'menton', label: 'Mandibular', color: '#f97316' },
      { from: 'orbitale', to: 'porion', label: 'Frankfort', color: '#67e8f9' },
    ],
  },
  ramusToMandibleRatio: {
    points: ['gonionTop', 'gonionBottom', 'menton'],
    lines: [
      { from: 'gonionTop', to: 'gonionBottom', label: 'Ramus', color: '#f97316' },
      { from: 'gonionBottom', to: 'menton', label: 'Mandible', color: '#ef4444' },
    ],
  },
  orbitalVector: {
    points: ['cornealApex', 'orbitale', 'cheekbone'],
    lines: [
      { from: 'cornealApex', to: 'cheekbone', label: 'Orbital Vector', color: '#06b6d4' },
    ],
  },
  eLineLowerLip: {
    points: ['pronasale', 'pogonion', 'labraleInferius'],
    lines: [
      { from: 'pronasale', to: 'pogonion', label: 'E-Line', color: '#67e8f9' },
    ],
  },
  sLineLowerLip: {
    points: ['pronasale', 'pogonion', 'labraleInferius'],
    lines: [
      { from: 'pronasale', to: 'pogonion', label: 'S-Line', color: '#a78bfa' },
    ],
  },
  holdawayHLine: {
    points: ['pronasale', 'pogonion', 'labraleSuperius', 'labraleInferius'],
    lines: [
      { from: 'pronasale', to: 'pogonion', label: 'H-Line', color: '#ec4899' },
    ],
  },
  burstoneLowerLip: {
    points: ['subnasale', 'pogonion', 'labraleInferius'],
    lines: [
      { from: 'subnasale', to: 'pogonion', label: 'Burstone', color: '#fbbf24' },
    ],
  },

  // ==========================================
  // ADDITIONAL FRONT PROFILE METRICS
  // ==========================================
  cupidsBowDepth: {
    points: ['labrale_superius', 'cupids_bow_left', 'cupids_bow_right', 'cupids_bow_center'],
    lines: [
      { from: 'cupids_bow_left', to: 'cupids_bow_center', label: 'Bow', color: '#ec4899' },
      { from: 'cupids_bow_center', to: 'cupids_bow_right', color: '#ec4899' },
    ],
  },
  mouthCornerPosition: {
    points: ['left_cheilion', 'right_cheilion', 'left_pupila', 'right_pupila'],
    lines: [
      { from: 'left_cheilion', to: 'right_cheilion', label: 'Mouth Width', color: '#ec4899' },
      { from: 'left_pupila', to: 'right_pupila', label: 'IPD', color: '#06b6d4', labelPosition: 'start' },
    ],
  },
  iaaJfaDeviation: {
    points: ['left_ala_nasi', 'right_ala_nasi', 'left_gonion_inferior', 'menton', 'right_gonion_inferior'],
    lines: [
      { from: 'left_ala_nasi', to: 'right_ala_nasi', label: 'IAA', color: '#fbbf24' },
      { from: 'left_gonion_inferior', to: 'menton', label: 'JFA', color: '#f97316' },
      { from: 'menton', to: 'right_gonion_inferior', color: '#f97316' },
    ],
  },
  ipsilateralAlarAngle: {
    points: ['left_ala_nasi', 'subnasale', 'right_ala_nasi'],
    lines: [
      { from: 'left_ala_nasi', to: 'subnasale', label: 'Alar Angle', color: '#fbbf24' },
      { from: 'subnasale', to: 'right_ala_nasi', color: '#fbbf24' },
    ],
  },
  earProtrusionAngle: {
    points: ['left_ear_helix', 'left_ear_attachment', 'left_tragus'],
    lines: [
      { from: 'left_ear_helix', to: 'left_ear_attachment', label: 'Protrusion', color: '#a78bfa' },
    ],
  },
  earProtrusionRatio: {
    points: ['left_ear_helix', 'left_ear_attachment', 'left_ear_lobule'],
    lines: [
      { from: 'left_ear_helix', to: 'left_ear_attachment', label: 'Distance', color: '#a78bfa' },
      { from: 'left_ear_attachment', to: 'left_ear_lobule', label: 'Length', color: '#67e8f9' },
    ],
  },
  mouthWidthToNoseRatio: {
    points: ['left_cheilion', 'right_cheilion', 'left_ala_nasi', 'right_ala_nasi'],
    lines: [
      { from: 'left_cheilion', to: 'right_cheilion', label: 'Mouth', color: '#ec4899' },
      { from: 'left_ala_nasi', to: 'right_ala_nasi', label: 'Nose', color: '#fbbf24' },
    ],
  },
  lowerToUpperLipRatio: {
    points: ['labrale_superius', 'mouth_middle', 'labrale_inferius'],
    lines: [
      { from: 'labrale_superius', to: 'mouth_middle', label: 'Upper', color: '#ec4899' },
      { from: 'mouth_middle', to: 'labrale_inferius', label: 'Lower', color: '#f97316' },
    ],
  },
  chinToPhiltrumRatio: {
    points: ['subnasale', 'labrale_superius', 'labrale_inferius', 'menton'],
    lines: [
      { from: 'subnasale', to: 'labrale_superius', label: 'Philtrum', color: '#ec4899' },
      { from: 'labrale_inferius', to: 'menton', label: 'Chin', color: '#ef4444' },
    ],
  },

  // ==========================================
  // ADDITIONAL SIDE PROFILE METRICS
  // ==========================================
  nasolabialAngle: {
    points: ['columella', 'subnasale', 'labraleSuperius'],
    lines: [
      { from: 'columella', to: 'subnasale', label: 'Columella', color: '#fbbf24' },
      { from: 'subnasale', to: 'labraleSuperius', label: 'Upper Lip', color: '#ec4899' },
    ],
  },
  nasalTipAngle: {
    points: ['nasion', 'pronasale', 'columella'],
    lines: [
      { from: 'nasion', to: 'pronasale', label: 'Dorsum', color: '#fbbf24' },
      { from: 'pronasale', to: 'columella', label: 'Tip', color: '#f97316' },
    ],
  },
  nasalProjection: {
    points: ['alar_crease', 'pronasale', 'subnasale'],
    lines: [
      { from: 'alar_crease', to: 'pronasale', label: 'Projection', color: '#fbbf24' },
    ],
  },
  nasalWToHRatio: {
    points: ['alar_crease', 'pronasale', 'nasion', 'subnasale'],
    lines: [
      { from: 'alar_crease', to: 'pronasale', label: 'Width', color: '#fbbf24' },
      { from: 'nasion', to: 'subnasale', label: 'Height', color: '#a78bfa' },
    ],
  },
  noseTipRotationAngle: {
    points: ['columella', 'subnasale', 'labraleSuperius'],
    lines: [
      { from: 'columella', to: 'subnasale', label: 'Rotation', color: '#fbbf24' },
    ],
  },
  frankfortTipAngle: {
    points: ['porion', 'orbitale', 'pronasale'],
    lines: [
      { from: 'porion', to: 'orbitale', label: 'Frankfort', color: '#67e8f9' },
      { from: 'orbitale', to: 'pronasale', label: 'To Tip', color: '#fbbf24' },
    ],
  },
  mentolabialAngle: {
    points: ['labraleInferius', 'mentolabialSulcus', 'pogonion'],
    lines: [
      { from: 'labraleInferius', to: 'mentolabialSulcus', label: 'Lip', color: '#ec4899' },
      { from: 'mentolabialSulcus', to: 'pogonion', label: 'Chin', color: '#ef4444' },
    ],
  },
  zAngle: {
    points: ['pogonion', 'labraleSuperius', 'frankfortHorizontal'],
    lines: [
      { from: 'pogonion', to: 'labraleSuperius', label: 'Z-Line', color: '#a78bfa' },
    ],
  },
  facialConvexityGlabella: {
    points: ['glabella', 'subnasale', 'pogonion'],
    lines: [
      { from: 'glabella', to: 'subnasale', label: 'Upper', color: '#84cc16' },
      { from: 'subnasale', to: 'pogonion', label: 'Lower', color: '#ef4444' },
    ],
  },
  facialConvexityNasion: {
    points: ['nasion', 'subnasale', 'pogonion'],
    lines: [
      { from: 'nasion', to: 'subnasale', label: 'Midface', color: '#22c55e' },
      { from: 'subnasale', to: 'pogonion', label: 'Lower', color: '#ef4444' },
    ],
  },
  totalFacialConvexity: {
    points: ['glabella', 'pronasale', 'pogonion'],
    lines: [
      { from: 'glabella', to: 'pronasale', label: 'Upper', color: '#84cc16' },
      { from: 'pronasale', to: 'pogonion', label: 'Lower', color: '#ef4444' },
    ],
  },
  interiorMidfaceProjectionAngle: {
    points: ['orbitale', 'subnasale', 'pronasale'],
    lines: [
      { from: 'orbitale', to: 'subnasale', label: 'Orbital', color: '#06b6d4' },
      { from: 'subnasale', to: 'pronasale', label: 'Midface', color: '#67e8f9' },
    ],
  },
  recessionFromFrankfort: {
    points: ['porion', 'orbitale', 'pogonion'],
    lines: [
      { from: 'porion', to: 'orbitale', label: 'Frankfort', color: '#67e8f9' },
      { from: 'orbitale', to: 'pogonion', label: 'Recession', color: '#ef4444' },
    ],
  },
  gonionToMouthLine: {
    points: ['gonionBottom', 'cheilion', 'tragus'],
    lines: [
      { from: 'gonionBottom', to: 'cheilion', label: 'Gonion-Mouth', color: '#f97316' },
    ],
  },
  eLineUpperLip: {
    points: ['pronasale', 'pogonion', 'labraleSuperius'],
    lines: [
      { from: 'pronasale', to: 'pogonion', label: 'E-Line', color: '#67e8f9' },
    ],
  },
  sLineUpperLip: {
    points: ['pronasale', 'pogonion', 'labraleSuperius'],
    lines: [
      { from: 'pronasale', to: 'pogonion', label: 'S-Line', color: '#a78bfa' },
    ],
  },
  burstoneUpperLip: {
    points: ['subnasale', 'pogonion', 'labraleSuperius'],
    lines: [
      { from: 'subnasale', to: 'pogonion', label: 'Burstone', color: '#fbbf24' },
    ],
  },
  chinProjection: {
    points: ['subnasale', 'pogonion', 'menton', 'frankfortHorizontal'],
    lines: [
      { from: 'subnasale', to: 'pogonion', label: 'Chin Proj', color: '#ef4444' },
    ],
  },
  recessionRelativeToFrankfort: {
    points: ['porion', 'orbitale', 'pogonion', 'menton'],
    lines: [
      { from: 'porion', to: 'orbitale', label: 'Frankfort', color: '#67e8f9' },
      { from: 'pogonion', to: 'menton', label: 'Recession', color: '#ef4444' },
    ],
  },
  browridgeInclinationAngle: {
    points: ['glabella', 'trichion', 'nasion'],
    lines: [
      { from: 'glabella', to: 'trichion', label: 'Brow Ridge', color: '#84cc16' },
      { from: 'glabella', to: 'nasion', color: '#67e8f9' },
    ],
  },
  upperForeheadSlope: {
    points: ['trichion', 'glabella', 'frankfortHorizontal'],
    lines: [
      { from: 'trichion', to: 'glabella', label: 'Forehead', color: '#84cc16' },
    ],
  },
  midfaceProjectionAngle: {
    points: ['orbitale', 'subnasale', 'pronasale'],
    lines: [
      { from: 'orbitale', to: 'subnasale', color: '#67e8f9' },
      { from: 'subnasale', to: 'pronasale', label: 'Projection', color: '#22c55e' },
    ],
  },
};

function generateIllustration(metricId: string, landmarks: LandmarkPoint[]): Ratio['illustration'] {
  const landmarkMap: Record<string, LandmarkPoint> = {};
  landmarks.forEach(l => { landmarkMap[l.id] = l; });

  const config = ILLUSTRATION_CONFIGS[metricId];
  const points: Record<string, { type: 'landmark'; landmarkId: string }> = {};
  const lines: Record<string, { from: string; to: string; color: string; label?: string; labelPosition?: 'start' | 'middle' | 'end' }> = {};

  if (config) {
    config.points.forEach((pointId, i) => {
      if (landmarkMap[pointId]) {
        points[`point_${i}`] = { type: 'landmark', landmarkId: pointId };
      }
    });
    config.lines.forEach((line, i) => {
      lines[`line_${i}`] = {
        from: line.from,
        to: line.to,
        color: line.color || '#67e8f9',
        label: line.label,
        labelPosition: line.labelPosition,
      };
    });
  }

  return { points, lines };
}

function getUsedLandmarks(metricId: string): string[] {
  const landmarkMappings: Record<string, string[]> = {
    faceWidthToHeight: ['left_zygion', 'right_zygion', 'trichion', 'menton'],
    lateralCanthalTilt: ['left_canthus_medialis', 'left_canthus_lateralis'],
    nasalIndex: ['left_ala_nasi', 'right_ala_nasi', 'nasal_base', 'subnasale'],
    ipd: ['left_pupila', 'right_pupila'],
    mouthWidth: ['left_cheilion', 'right_cheilion'],
    jawWidth: ['left_gonion_inferior', 'right_gonion_inferior'],
    chinHeight: ['labrale_inferius', 'menton'],
    gonialAngle: ['tragus', 'gonionBottom', 'menton'],
  };
  return landmarkMappings[metricId] || [];
}

function getFlawStrengthMappings(result: MetricScoreResult): { mayIndicateFlaws: string[]; mayIndicateStrengths: string[] } {
  const flawMappings: Record<string, { low: string[]; high: string[] }> = {
    faceWidthToHeight: {
      low: ['Narrow face', 'Vertically elongated face'],
      high: ['Wide face', 'Horizontally expanded face'],
    },
    lowerThirdProportion: {
      low: ['Short lower third', 'Deficient mandible'],
      high: ['Long lower third', 'Mandibular excess'],
    },
    lateralCanthalTilt: {
      low: ['Negative canthal tilt', 'Drooping eyes'],
      high: ['Excessive positive canthal tilt'],
    },
    nasalIndex: {
      low: ['Narrow nose', 'Leptorrhine nose'],
      high: ['Wide nose', 'Platyrrhine nose'],
    },
    gonialAngle: {
      low: ['Steep mandibular plane'],
      high: ['Flat mandibular plane', 'Weak jaw definition'],
    },
  };

  const strengthMappings: Record<string, { ideal: string[] }> = {
    faceWidthToHeight: { ideal: ['Balanced facial proportions', 'Harmonious face shape'] },
    lateralCanthalTilt: { ideal: ['Attractive eye shape', 'Positive canthal tilt'] },
    nasalIndex: { ideal: ['Well-proportioned nose', 'Balanced nasal width'] },
    gonialAngle: { ideal: ['Well-defined jawline', 'Strong jaw structure'] },
  };

  const mapping = flawMappings[result.metricId];
  const strengthMapping = strengthMappings[result.metricId];

  let mayIndicateFlaws: string[] = [];
  let mayIndicateStrengths: string[] = [];

  if (result.qualityTier === 'ideal' || result.qualityTier === 'excellent') {
    mayIndicateStrengths = strengthMapping?.ideal || [];
  } else if (mapping) {
    mayIndicateFlaws = result.deviationDirection === 'below' ? mapping.low : mapping.high;
  }

  return { mayIndicateFlaws, mayIndicateStrengths };
}

// Metric groupings for creating multi-ratio strengths
const STRENGTH_GROUPINGS: Record<string, {
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

function generateStrengthsFromAnalysis(analysis: HarmonyAnalysis): Strength[] {
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
    return b.avgScore - a.avgScore;
  });
}

// Flaw groupings - similar to strength groupings but for areas of improvement
const FLAW_GROUPINGS: Record<string, {
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

function generateFlawsFromAnalysis(analysis: HarmonyAnalysis): Flaw[] {
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

// NOTE: PROCEDURE_DATABASE, ProcedureConfig, and recommendation generation functions
// have been moved to @/lib/results/analysis.ts to reduce bundle size
// Import generateRecommendations from there instead
// ============================================
// CONTEXT CREATION
// ============================================

const ResultsContext = createContext<ResultsContextType | null>(null);

export function useResults(): ResultsContextType {
  const context = useContext(ResultsContext);
  if (!context) {
    throw new Error('useResults must be used within a ResultsProvider');
  }
  return context;
}

interface ResultsProviderProps {
  children: ReactNode;
  initialData?: ResultsInputData;
}

export function ResultsProvider({ children, initialData }: ResultsProviderProps) {
  // Raw data state
  const [frontLandmarks, setFrontLandmarks] = useState<LandmarkPoint[]>(initialData?.frontLandmarks || []);
  const [sideLandmarks, setSideLandmarks] = useState<LandmarkPoint[]>(initialData?.sideLandmarks || []);
  const [gender, setGender] = useState<Gender>(initialData?.gender || 'male');
  const [ethnicity, setEthnicity] = useState<Ethnicity>(initialData?.ethnicity || 'other');
  const [frontPhoto, setFrontPhoto] = useState<string>(initialData?.frontPhoto || '');
  const [sidePhoto, setSidePhoto] = useState<string | null>(initialData?.sidePhoto || null);

  // UI state
  const [activeTab, setActiveTab] = useState<ResultsTab>('overview');
  const [expandedMeasurementId, setExpandedMeasurementId] = useState<string | null>(null);
  const [selectedVisualizationMetric, setSelectedVisualizationMetric] = useState<string | null>(null);
  const [categoryFilter, setCategoryFilter] = useState<string | null>(null);
  const [showLandmarkOverlay, setShowLandmarkOverlay] = useState(true);

  // Compute analysis results (now with demographic-specific scoring)
  const analysisResults = useMemo(() => {
    if (frontLandmarks.length === 0) {
      return null;
    }

    try {
      const frontAnalysis = analyzeFrontProfile(frontLandmarks, gender, ethnicity);
      const sideAnalysis = sideLandmarks.length > 0
        ? analyzeSideProfile(sideLandmarks, gender, ethnicity)
        : null;
      // analyzeHarmony expects landmarks directly, not analysis results
      const harmony = analyzeHarmony(frontLandmarks, sideLandmarks, gender, ethnicity);

      return { frontAnalysis, sideAnalysis, harmony };
    } catch (error) {
      console.error('Analysis error:', error);
      return null;
    }
  }, [frontLandmarks, sideLandmarks, gender, ethnicity]);

  // Transform to Ratio format
  const frontRatios = useMemo(() => {
    if (!analysisResults?.frontAnalysis) return [];
    return analysisResults.frontAnalysis.measurements.map(m => transformToRatio(m, frontLandmarks));
  }, [analysisResults, frontLandmarks]);

  const sideRatios = useMemo(() => {
    if (!analysisResults?.sideAnalysis) return [];
    return analysisResults.sideAnalysis.measurements.map(m => transformToRatio(m, sideLandmarks));
  }, [analysisResults, sideLandmarks]);

  // Generate strengths and flaws using INSIGHTS-BASED classification
  // This processes insights.json definitions: calculates avg score of affected metrics,
  // then classifies as strength (avg > threshold) or weakness (avg < threshold)
  const { insightStrengths, insightFlaws } = useMemo(() => {
    if (!analysisResults?.harmony) {
      return { insightStrengths: [], insightFlaws: [] };
    }

    try {
      // Classify using insights engine
      const { strengths: classifiedStrengths, weaknesses: classifiedWeaknesses } =
        classifyInsights(analysisResults.harmony.measurements, INSIGHTS_DEFINITIONS);

      // Convert to UI-compatible types
      const insightStrengths = classifiedStrengths.map((s) => convertToStrength(s));

      let rollingLost = 0;
      const insightFlaws = classifiedWeaknesses.map((w, i) => {
        const flaw = convertToFlaw(w, i, rollingLost);
        rollingLost = flaw.rollingPointsDeducted || 0;
        return flaw;
      });

      return { insightStrengths, insightFlaws };
    } catch (error) {
      console.error('[ResultsContext] Error in insights classification:', error);
      return { insightStrengths: [], insightFlaws: [] };
    }
  }, [analysisResults]);

  // Generate grouping-based strengths/flaws (legacy approach for metrics not covered by insights)
  const groupingStrengths = useMemo(() => {
    if (!analysisResults?.harmony) return [];
    return generateStrengthsFromAnalysis(analysisResults.harmony);
  }, [analysisResults]);

  const groupingFlaws = useMemo(() => {
    if (!analysisResults?.harmony) return [];
    return generateFlawsFromAnalysis(analysisResults.harmony);
  }, [analysisResults]);

  // Merge insights + groupings, preferring insights (dedupe by category/metric overlap)
  const strengths = useMemo(() => {
    // Use insights as primary source
    const usedMetricIds = new Set<string>();
    insightStrengths.forEach(s => {
      s.responsibleRatios.forEach(r => usedMetricIds.add(r.ratioId));
    });

    // Add grouping-based strengths that don't overlap
    const nonOverlappingGrouping = groupingStrengths.filter(gs => {
      const overlap = gs.responsibleRatios.some(r => usedMetricIds.has(r.ratioId));
      return !overlap;
    });

    return [...insightStrengths, ...nonOverlappingGrouping];
  }, [insightStrengths, groupingStrengths]);

  const flaws = useMemo(() => {
    // Use insights as primary source
    const usedMetricIds = new Set<string>();
    insightFlaws.forEach(f => {
      f.responsibleRatios.forEach(r => usedMetricIds.add(r.ratioId));
    });

    // Add grouping-based flaws that don't overlap
    const nonOverlappingGrouping = groupingFlaws.filter(gf => {
      const overlap = gf.responsibleRatios.some(r => usedMetricIds.has(r.ratioId));
      return !overlap;
    });

    // Recalculate rolling totals for merged list
    let rollingLost = 0;
    const merged = [...insightFlaws, ...nonOverlappingGrouping];
    return merged.map(f => {
      rollingLost += f.harmonyPercentageLost;
      return {
        ...f,
        rollingPointsDeducted: rollingLost,
        rollingHarmonyPercentageLost: rollingLost,
        rollingStandardizedImpact: rollingLost / 10,
      };
    });
  }, [insightFlaws, groupingFlaws]);

  // Generate recommendations with metric-aware matching and Bezier recalculation
  const recommendations = useMemo(() => {
    return generateRecommendations(flaws, frontRatios, sideRatios, gender, ethnicity);
  }, [flaws, frontRatios, sideRatios, gender, ethnicity]);

  // Build full harmony analysis
  const harmonyAnalysis = useMemo((): FullHarmonyAnalysis | null => {
    if (!analysisResults?.harmony) return null;

    return {
      standardizedScore: analysisResults.harmony.overallScore,
      front: {
        standardizedScore: analysisResults.harmony.frontScore,
        ratios: frontRatios,
      },
      side: {
        standardizedScore: analysisResults.harmony.sideScore,
        ratios: sideRatios,
      },
      strengths,
      flaws,
    };
  }, [analysisResults, frontRatios, sideRatios, strengths, flaws]);

  // Calculate weighted harmony score using looksmax_engine.py algorithm
  const harmonyScoreResult = useMemo((): HarmonyScoreResult | null => {
    if (!analysisResults?.harmony) return null;

    const allMeasurements = analysisResults.harmony.measurements.map(m => ({
      metricId: m.metricId,
      standardizedScore: m.standardizedScore,
    }));

    return calculateHarmonyScore(allMeasurements);
  }, [analysisResults]);

  // Get top 3 and bottom 3 metrics with advice
  const topMetrics = useMemo((): RankedMetric[] => {
    if (!analysisResults?.harmony) return [];
    return getTopMetrics(analysisResults.harmony.measurements, 3);
  }, [analysisResults]);

  const bottomMetrics = useMemo((): RankedMetric[] => {
    if (!analysisResults?.harmony) return [];
    return getBottomMetrics(analysisResults.harmony.measurements, 3);
  }, [analysisResults]);

  // Scores - now using weighted harmony
  const harmonyPercentage = harmonyScoreResult?.harmonyPercentage || 0;
  const overallScore = harmonyScoreResult?.weightedAverage || analysisResults?.harmony?.overallScore || 0;
  const frontScore = analysisResults?.harmony?.frontScore || 0;
  const sideScore = analysisResults?.harmony?.sideScore || 0;

  // PSL Rating (1-10 scale with tier/percentile)
  const pslRating = useMemo(() => {
    return harmonyToPSL(harmonyPercentage);
  }, [harmonyPercentage]);

  // Action to set all results data
  const setResultsData = useCallback((data: ResultsInputData) => {
    setFrontLandmarks(data.frontLandmarks);
    setSideLandmarks(data.sideLandmarks);
    setFrontPhoto(data.frontPhoto);
    setSidePhoto(data.sidePhoto || null);
    setGender(data.gender);
    setEthnicity(data.ethnicity || 'other');
  }, []);

  // Memoize context value to prevent unnecessary re-renders
  const value = useMemo<ResultsContextType>(() => ({
    frontLandmarks,
    sideLandmarks,
    gender,
    ethnicity,
    frontPhoto,
    sidePhoto,
    harmonyAnalysis,
    frontRatios,
    sideRatios,
    strengths,
    flaws,
    recommendations,
    overallScore,
    frontScore,
    sideScore,
    // Weighted harmony from looksmax_engine.py
    harmonyScoreResult,
    harmonyPercentage,
    topMetrics,
    bottomMetrics,
    // PSL Rating
    pslRating,
    // UI state
    activeTab,
    setActiveTab,
    expandedMeasurementId,
    setExpandedMeasurementId,
    selectedVisualizationMetric,
    setSelectedVisualizationMetric,
    categoryFilter,
    setCategoryFilter,
    showLandmarkOverlay,
    setShowLandmarkOverlay,
    setResultsData,
  }), [
    frontLandmarks, sideLandmarks, gender, ethnicity, frontPhoto, sidePhoto,
    harmonyAnalysis, frontRatios, sideRatios, strengths, flaws, recommendations,
    overallScore, frontScore, sideScore, harmonyScoreResult, harmonyPercentage,
    topMetrics, bottomMetrics, pslRating, activeTab, setActiveTab,
    expandedMeasurementId, setExpandedMeasurementId, selectedVisualizationMetric,
    setSelectedVisualizationMetric, categoryFilter, setCategoryFilter,
    showLandmarkOverlay, setShowLandmarkOverlay, setResultsData,
  ]);

  return (
    <ResultsContext.Provider value={value}>
      {children}
    </ResultsContext.Provider>
  );
}
