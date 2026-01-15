'use client';

import React, { createContext, useContext, useState, useMemo, useCallback, ReactNode } from 'react';
import { LandmarkPoint } from '@/lib/landmarks';
import {
  analyzeFrontProfile,
  analyzeSideProfile,
  analyzeHarmony,
  HarmonyAnalysis,
  FaceIQScoreResult,
  FACEIQ_METRICS,
  Ethnicity,
  Gender,
  scoreMeasurement,
} from '@/lib/faceiq-scoring';
import {
  calculateHarmonyScore,
  getTopMetrics,
  getBottomMetrics,
  HarmonyScoreResult,
  RankedMetric,
} from '@/lib/looksmax-scoring';
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

function transformToRatio(result: FaceIQScoreResult, landmarks: LandmarkPoint[]): Ratio {
  const metricConfig = FACEIQ_METRICS[result.metricId];

  // Generate illustration based on metric
  const illustration = generateIllustration(result.metricId, landmarks);

  // Get flaw/strength mappings
  const { mayIndicateFlaws, mayIndicateStrengths } = getFlawStrengthMappings(result);

  // Classify metric using FaceIQ taxonomy
  const taxonomyClassification = classifyMetric(result.name, result.category);

  return {
    id: result.metricId,
    name: result.name,
    value: result.value,
    score: result.score,
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

function getFlawStrengthMappings(result: FaceIQScoreResult): { mayIndicateFlaws: string[]; mayIndicateStrengths: string[] } {
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

// Comprehensive procedure database with metric-specific targeting
interface ProcedureConfig {
  ref_id: string;
  name: string;
  description: string;
  phase: 'Surgical' | 'Minimally Invasive' | 'Foundational';
  baseImpact: number;
  coverage: number;
  percentage: string;
  expectedImprovementRange: { min: number; max: number };
  targetMetrics: string[];  // Specific metric IDs this treatment addresses
  targetCategories: string[];  // Category names this treatment addresses
  targetKeywords: string[];  // Flaw name keywords to match
  timeline: { effect_start: 'immediate' | 'delayed' | 'gradual'; full_results_weeks: number; full_results_weeks_max?: number };
  cost: { type: 'flat' | 'per_session' | 'per_month'; min: number; max: number; currency: string };
  risks_side_effects: string;
  warnings: string[];
  gender: 'male' | 'female' | 'both';
}

const PROCEDURE_DATABASE: ProcedureConfig[] = [
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

// Calculate relevance score based on multiple factors including metric scores
function calculateRelevanceScore(
  proc: ProcedureConfig,
  flaw: Flaw,
  allFlaws: Flaw[],
  allRatios: Ratio[] = []
): number {
  let score = 0;

  // Check metric ID match (highest priority)
  const metricId = flaw.responsibleRatios[0]?.ratioId || '';
  const metricScore = flaw.responsibleRatios[0]?.score || 5;

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
    proc.targetMetrics.includes(r.id) && r.score < 6
  );
  score += matchingRatios.length * 8;

  return Math.min(score, 100);
}

// Calculate expected score improvement using FaceIQ Bezier recalculation
// Instead of simple addition, we recalculate the score at the ideal value
function calculateExpectedImprovement(
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

  // FaceIQ-style Bezier recalculation:
  // For each ratio, calculate what the score would be at the ideal value
  let totalCurrentWeighted = 0;
  let totalIdealWeighted = 0;
  let totalWeight = 0;

  matchedRatios.forEach(ratio => {
    const config = FACEIQ_METRICS[ratio.id];
    if (!config) return;

    // Current score from the ratio
    const currentScore = ratio.score;

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

function generateRecommendations(
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

    // Calculate expected improvement with FaceIQ Bezier recalculation
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
      let direction: 'increase' | 'decrease' | 'both' = 'both';
      if (r.value < r.idealMin) {
        direction = 'increase';
      } else if (r.value > r.idealMax) {
        direction = 'decrease';
      }

      // Calculate percentage effect based on how far from ideal and procedure strength
      const deviation = r.value < r.idealMin
        ? r.idealMin - r.value
        : r.value > r.idealMax
          ? r.value - r.idealMax
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

  // Action to set all results data
  const setResultsData = useCallback((data: ResultsInputData) => {
    setFrontLandmarks(data.frontLandmarks);
    setSideLandmarks(data.sideLandmarks);
    setFrontPhoto(data.frontPhoto);
    setSidePhoto(data.sidePhoto || null);
    setGender(data.gender);
    setEthnicity(data.ethnicity || 'other');
  }, []);

  const value: ResultsContextType = {
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
  };

  return (
    <ResultsContext.Provider value={value}>
      {children}
    </ResultsContext.Provider>
  );
}
