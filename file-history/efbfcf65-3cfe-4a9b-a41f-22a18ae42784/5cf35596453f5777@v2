/**
 * Demographic-specific ideal ranges based on anthropometric research.
 * Universal scoring, but this gives more accurate assessments
 * by adjusting ideals based on ethnicity and gender.
 *
 * Extracted from harmony-scoring.ts for modularity.
 */

import type {
  DemographicKey,
  DemographicOverride,
  Ethnicity,
  Gender,
  MetricConfig,
} from '@/lib/scoring/types';
import { METRIC_CONFIGS } from './metric-configs';

// Re-export types for convenience
export type { DemographicKey, DemographicOverride, Ethnicity, Gender };

/**
 * Demographic-specific ideal ranges based on anthropometric research.
 * Universal scoring, but this gives more accurate assessments
 * by adjusting ideals based on ethnicity and gender.
 */
export const DEMOGRAPHIC_OVERRIDES: Record<string, Partial<Record<DemographicKey, DemographicOverride>>> = {
  // ==========================================
  // NOSE METRICS - Highest ethnicity variation
  // ==========================================
  nasalIndex: {
    // Nasal Index = (Nose Width / Nose Height) × 100
    // Research: African/Pacific Islander tend platyrrhine (85-100), Asian mesorrhine (75-88), European leptorrhine (65-75)
    east_asian_male: { idealMin: 78, idealMax: 88 },
    east_asian_female: { idealMin: 76, idealMax: 86 },
    south_asian_male: { idealMin: 72, idealMax: 82 },
    south_asian_female: { idealMin: 70, idealMax: 80 },
    black_male: { idealMin: 85, idealMax: 100 },
    black_female: { idealMin: 83, idealMax: 98 },
    hispanic_male: { idealMin: 75, idealMax: 87 },
    hispanic_female: { idealMin: 73, idealMax: 85 },
    middle_eastern_male: { idealMin: 68, idealMax: 78 },
    middle_eastern_female: { idealMin: 66, idealMax: 76 },
    white_male: { idealMin: 65, idealMax: 75 },
    white_female: { idealMin: 63, idealMax: 73 },
    native_american_male: { idealMin: 72, idealMax: 82 },
    native_american_female: { idealMin: 70, idealMax: 80 },
    pacific_islander_male: { idealMin: 82, idealMax: 95 },
    pacific_islander_female: { idealMin: 80, idealMax: 93 },
  },

  nasolabialAngle: {
    // Ideal nasolabial angle varies by ethnicity
    // African: slightly more obtuse, European: slightly more acute
    // Middle Eastern: Penalizes droopy tip (<90°) - common flaw is "Hooked Nose"
    // Ethnicity-specific override Male:MiddleEastern.htc
    black_male: { idealMin: 95, idealMax: 110 },
    black_female: { idealMin: 100, idealMax: 115 },
    east_asian_male: { idealMin: 90, idealMax: 105 },
    east_asian_female: { idealMin: 95, idealMax: 110 },
    middle_eastern_male: { idealMin: 90, idealMax: 100 },  // Strict on droopy tip
    middle_eastern_female: { idealMin: 95, idealMax: 105 },
    // Gender-only fallbacks
    male: { idealMin: 90, idealMax: 100 },
    female: { idealMin: 100, idealMax: 110 },
  },

  nasalProjection: {
    // Nose projection relative to face depth
    // East Asian/African: typically less projection is ideal
    // Middle Eastern: Accepts stronger projection (bigger nose) than White model
    // Ethnicity-specific override Male:MiddleEastern.htc
    east_asian: { idealMin: 0.54, idealMax: 0.60 },
    black: { idealMin: 0.52, idealMax: 0.58 },
    south_asian: { idealMin: 0.56, idealMax: 0.62 },
    middle_eastern: { idealMin: 0.62, idealMax: 0.70 },  // Higher tolerance for larger noses
    white: { idealMin: 0.60, idealMax: 0.67 },
    pacific_islander: { idealMin: 0.52, idealMax: 0.58 },
  },

  intercanthalNasalRatio: {
    // Alar width (nose width) relative to intercanthal distance (inner eye spacing)
    // White: Neoclassical standard - STRICT 1:1 ratio (nose width = inner eye spacing)
    // Research: Wider nose base is standard in African phenotypes
    // South Asian Female: Accepts slightly wider base (1.00-1.08) but demands higher tip definition
    // Pacific Islander: Similar to Black model, accepts wide nasal base
    // Black Female: Wider than White Female, narrower than Black Male - balance of width and refinement
    // Hispanic Female: Intermediate tolerance - slightly wider base acceptable with bridge definition
    // Ethnicity-specific override Male:White.htc (Neoclassical), BlackAfrican.htc, Female:African.htc, Female:Hispanic.htc, Female:SouthAsian.htc and Male:Pacific Islander.htc logic
    white_male: { idealMin: 0.98, idealMax: 1.05 },  // Neoclassical - strictest nasal width standard
    white_female: { idealMin: 0.98, idealMax: 1.05 },  // Strict "Rule of Fifths" (1:1 with eye width)
    east_asian_male: { idealMin: 1.10, idealMax: 1.15 },
    east_asian_female: { idealMin: 1.08, idealMax: 1.13 },
    south_asian_male: { idealMin: 1.05, idealMax: 1.08 },  // Hybrid: between White and East Asian
    south_asian_female: { idealMin: 1.00, idealMax: 1.08 },  // Wider tolerance - accepts broader base
    black_male: { idealMin: 1.15, idealMax: 1.25 },  // WIDEST - completely inverts White standard
    black_female: { idealMin: 1.05, idealMax: 1.15 },  // Wider than White Female, narrower than Black Male
    hispanic_male: { idealMin: 1.00, idealMax: 1.12 },  // "Bridge" tolerance - between White and Black
    hispanic_female: { idealMin: 1.00, idealMax: 1.10 },  // Intermediate - between White and Black Female standards
    native_american_female: { idealMin: 1.00, idealMax: 1.10 },  // Simpler/Sharper nose
    pacific_islander_male: { idealMin: 1.10, idealMax: 1.20 },  // Wide tolerance, similar to Black model
    pacific_islander_female: { idealMin: 1.05, idealMax: 1.15 },  // Wider tolerance for nasal base
  },

  // ==========================================
  // JAW METRICS - Clear gender dimorphism
  // ==========================================
  bigonialWidth: {
    // Jaw width as % of bizygomatic width
    // Males: wider, more angular; Females: narrower, softer
    // Pacific Islander: Extremely wide jaw preferred - "Warrior Skull" robustness
    // Ethnicity-specific override Male:Pacific Islander.htc
    male: { idealMin: 90, idealMax: 95 },
    female: { idealMin: 85, idealMax: 90 },
    pacific_islander_male: { idealMin: 92, idealMax: 98 },  // Jaw width rivals cheekbone width - extreme robustness
    pacific_islander_female: { idealMin: 88, idealMax: 94 },
  },

  jawFrontalAngle: {
    // More angular in males, softer in females
    male: { idealMin: 88, idealMax: 95 },
    female: { idealMin: 82, idealMax: 90 },
  },

  jawWidthRatio: {
    // Males have stronger jaw width preference
    male: { idealMin: 0.78, idealMax: 0.85 },
    female: { idealMin: 0.72, idealMax: 0.80 },
  },

  gonialAngle: {
    // White: Neoclassical standard - square, vertically robust jaw (115-125°)
    // Males: more acute (sharper jaw); Females: more obtuse (softer)
    // East Asian Female: Prefers softer, V-shaped jawline (120-126°) - "Doll Face" aesthetic
    // Black Female: Soft/feminine jaw standard - similar to general female range
    // Ethnicity-specific override Male:White.htc, Female:East Asian.htc, and Female:African.htc
    white_male: { idealMin: 115, idealMax: 125 },  // Neoclassical square jaw - less tolerant of soft/V-shaped jaws
    white_female: { idealMin: 122.0, idealMax: 130.0 },  // Soft, tapered jawline (V-shape)
    east_asian_female: { idealMin: 120, idealMax: 126 },  // Narrower tolerance - penalizes square jaws more
    black_female: { idealMin: 120.0, idealMax: 130.0 },  // Soft/feminine jaw preference
    native_american_female: { idealMin: 115.0, idealMax: 125.0 },  // Strong, defined jawline
    pacific_islander_female: { idealMin: 115.0, idealMax: 128.0 },  // Strong but allows slightly softer definition
    male: { idealMin: 115, idealMax: 125 },
    female: { idealMin: 120, idealMax: 135 },
  },

  // ==========================================
  // EYE METRICS - Ethnic variation
  // ==========================================
  lateralCanthalTilt: {
    // White: Neoclassical standard - neutral to slightly positive tilt (4-8°)
    // East Asian: naturally higher positive tilt
    // Hispanic: Strong preference for positive tilt (almond eyes), penalizes neutral/negative more harshly
    // Hispanic Female: STRONGEST "Almond/Cat Eye" preference - rewards positive tilt heavily
    // Middle Eastern: Strong preference for "Hunter Eyes" (Dark Triad look)
    // Ethnicity-specific override Male:White.htc (Neoclassical baseline), Male:MiddleEastern.htc, and Female:Hispanic.htc
    white_male: { idealMin: 4.0, idealMax: 8.0 },  // Neoclassical - neutral to slightly positive
    white_female: { idealMin: 4.0, idealMax: 9.0 },  // Neutral to slightly positive
    east_asian_male: { idealMin: 8, idealMax: 12 },
    east_asian_female: { idealMin: 9, idealMax: 13 },
    south_asian_male: { idealMin: 6, idealMax: 10 },
    south_asian_female: { idealMin: 7, idealMax: 11 },
    hispanic_male: { idealMin: 6.0, idealMax: 12.0 },  // Wide range, heavily rewards positive tilt
    hispanic_female: { idealMin: 6.0, idealMax: 12.0 },  // "Cat Eye/Almond" ideal - strongest preference among female demographics
    middle_eastern_male: { idealMin: 4.0, idealMax: 10.0 },  // Almond/Hunter eye preference
    middle_eastern_female: { idealMin: 5.0, idealMax: 10.0 },  // Preference for "Foxy/Hunter" feminine eyes
    native_american_female: { idealMin: 5.0, idealMax: 11.0 },  // Positive tilt (Hunter/Almond)
    // Default for others is 4-8 (already in METRIC_CONFIGS)
  },

  eyeAspectRatio: {
    // East Asian eyes often have different aspect ratio due to epicanthal fold
    east_asian_male: { idealMin: 2.6, idealMax: 3.2 },
    east_asian_female: { idealMin: 2.7, idealMax: 3.3 },
    // Larger eyes in females considered more attractive
    male: { idealMin: 2.9, idealMax: 3.4 },
    female: { idealMin: 3.1, idealMax: 3.6 },
  },

  tearTroughDepth: {
    // Under-eye hollowing and dark circles (infraorbital depression)
    // South Asian: MUCH stricter penalty due to genetic hyperpigmentation
    // Ethnicity-specific override Male:SouthAsian.htc and Female:SouthAsian.htc - biggest difference vs White model
    white_male: { idealMin: 0.0, idealMax: 1.5 },
    white_female: { idealMin: 0.0, idealMax: 1.3 },
    south_asian_male: { idealMin: 0.0, idealMax: 0.5 },  // VERY strict - 0.5+ triggers "Tired/Aged Eyes" flaw
    south_asian_female: { idealMin: 0.0, idealMax: 0.5 },  // Even minor shadows trigger "Dark Circles" flaw
    east_asian_male: { idealMin: 0.0, idealMax: 1.2 },
    east_asian_female: { idealMin: 0.0, idealMax: 1.0 },
  },

  upperEyelidExposure: {
    // Visible eyelid platform (space between eyelash and crease)
    // South Asian ideal: prefers visible lid platform, penalizes hooded eyes more than White model
    // Ethnicity-specific override Male:SouthAsian.htc
    white_male: { idealMin: 0.3, idealMax: 2.5 },
    white_female: { idealMin: 0.5, idealMax: 3.0 },
    south_asian_male: { idealMin: 0.5, idealMax: 2.0 },  // Prefers visible lid, penalizes hooding
    south_asian_female: { idealMin: 0.7, idealMax: 2.2 },
    east_asian_male: { idealMin: 0.0, idealMax: 1.5 },  // More tolerance for less exposure
    east_asian_female: { idealMin: 0.2, idealMax: 1.8 },
    middle_eastern_female: { idealMin: 0.5, idealMax: 1.5 },  // Low exposure (Almond shape)
  },

  eyeSeparationRatio: {
    // East Asian Female: Wider tolerance for "Doll Eyes" (wide-set eyes) - neotenous preference
    // Wide-set eyes (46.3-47.5%) are ideal in East Asian female beauty standards
    // Ethnicity-specific override Female:East Asian.htc
    east_asian_female: { idealMin: 46.3, idealMax: 47.5 },  // Wide-set eyes are preferred for youthful look
  },

  // ==========================================
  // FACE PROPORTIONS - Gender variation
  // ==========================================
  faceWidthToHeight: {
    // White: Neoclassical standard - balanced, moderate width (1.98-2.02)
    // Males: slightly wider face preferred; Females: slightly narrower
    // Hispanic: Allows broader "Mesoprosopic" faces (Mestizo/Indigenous bone structure)
    // Hispanic Female: "Mestiza" face shape tolerance - broader than White (~1.45) but feminine, celebrates facial harmony
    // Pacific Islander: "Warrior Skull" - extremely broad face preferred (highest FWHR of any demographic)
    // Ethnicity-specific override Male:White.htc (Neoclassical baseline), Male:Pacific Islander.htc, and Female:Hispanic.htc
    white_male: { idealMin: 1.98, idealMax: 2.02 },  // Neoclassical - moderate width baseline
    white_female: { idealMin: 1.45, idealMax: 1.53 },  // Preference for Oval/Narrow shapes
    male: { idealMin: 1.98, idealMax: 2.02 },
    female: { idealMin: 1.94, idealMax: 1.98 },
    hispanic_male: { idealMin: 1.95, idealMax: 2.10 },  // Rewards broader, robust face shapes
    hispanic_female: { idealMin: 1.50, idealMax: 1.62 },  // Broader than White (~1.45) but not masculine - heart/round-square shapes
    native_american_female: { idealMin: 1.52, idealMax: 1.65 },  // Wide/Heart shape (High skeletal width)
    pacific_islander_male: { idealMin: 2.10, idealMax: 2.30 },  // "Warrior Skull" - extremely broad, square face
    pacific_islander_female: { idealMin: 1.55, idealMax: 1.70 },  // The widest female ideal (Skeletal + Volume)
  },

  totalFacialWidthToHeight: {
    male: { idealMin: 1.35, idealMax: 1.40 },
    female: { idealMin: 1.32, idealMax: 1.37 },
  },

  midfaceRatio: {
    // Females often have more compact midface
    // White: Neoclassical standard - strict compact midface preference
    // Middle Eastern: Similar to White model - compact is better
    // Ethnicity-specific override Male:White.htc (Neoclassical baseline) and Male:MiddleEastern.htc
    white_male: { idealMin: 0.95, idealMax: 1.02 },  // Neoclassical - penalizes long midface heavily
    white_female: { idealMin: 0.93, idealMax: 1.00 },
    male: { idealMin: 0.98, idealMax: 1.02 },
    female: { idealMin: 0.95, idealMax: 1.00 },
    middle_eastern_male: { idealMin: 0.95, idealMax: 1.02 },  // Slightly wider tolerance, compact preferred
    middle_eastern_female: { idealMin: 0.93, idealMax: 0.99 },
  },

  lowerThirdProportion: {
    // East Asian Female: Prefers smaller, more compact lower face (Heart/Oval face shape ideal)
    // Smaller lower third contributes to "Cute" or "Doll Face" aesthetic
    // Ethnicity-specific override Female:East Asian.htc
    east_asian_female: { idealMin: 29.6, idealMax: 32.7 },  // Penalizes long/masculine chin
  },

  // ==========================================
  // LIP METRICS - Ethnicity variation
  // ==========================================
  lowerToUpperLipRatio: {
    // African/Hispanic: fuller lips natural
    // Black Female: Highest fullness requirement in the app - thin lips heavily penalized
    // Ethnicity-specific override Female:African.htc - combines neoteny with phenotypic lip fullness
    black_male: { idealMin: 1.6, idealMax: 2.2 },
    black_female: { idealMin: 1.3, idealMax: 1.6 },  // HIGHEST fullness standard in the app
    hispanic_male: { idealMin: 1.4, idealMax: 2.0 },
    hispanic_female: { idealMin: 1.1, idealMax: 1.35 },  // Voluptuous but balanced
    // East Asian: less full lips
    east_asian_male: { idealMin: 1.2, idealMax: 1.7 },
    east_asian_female: { idealMin: 1.3, idealMax: 1.8 },
    // Pacific Islander: Explicit preference for full lips
    pacific_islander_female: { idealMin: 1.25, idealMax: 1.50 },
    // Default
    male: { idealMin: 1.3, idealMax: 1.8 },
    female: { idealMin: 1.4, idealMax: 2.0 },
  },

  upperLipRatio: {
    // Fuller upper lip in African phenotypes
    black: { idealMin: 0.38, idealMax: 0.48 },
    hispanic: { idealMin: 0.36, idealMax: 0.45 },
    east_asian: { idealMin: 0.32, idealMax: 0.40 },
    female: { idealMin: 0.34, idealMax: 0.42 },
  },

  // ==========================================
  // PROFILE METRICS - Gender & ethnicity
  // ==========================================
  chinProjection: {
    // Males: more projected chin ideal
    // Black/African: Adjusted for bimaxillary prognathism (forward mouth projection)
    // Black Female: Allows forward projection - less likely to trigger "Recessed Chin"
    // Ethnicity-specific override BlackAfrican.htc and Female:African.htc logic
    male: { idealMin: 0, idealMax: 3 },
    female: { idealMin: -2, idealMax: 2 },
    black_male: { idealMin: 0, idealMax: 4 },  // Accommodates natural forward projection
    black_female: { idealMin: 0.0, idealMax: 5.0 },  // Wide tolerance for forward projection
  },

  nasofrontalAngle: {
    // Higher brow ridge in males
    male: { idealMin: 128, idealMax: 138 },
    female: { idealMin: 132, idealMax: 142 },
  },

  chinToPhiltrumRatio: {
    // White: Neoclassical standard - strict balance between chin and philtrum
    // Black/African: Fuller lips naturally shorten visible philtrum
    // Ethnicity-specific override Male:White.htc (Neoclassical) and BlackAfrican.htc
    // Higher ratio = shorter philtrum (more acceptable in Black phenotype)
    white_male: { idealMin: 2.10, idealMax: 2.30 },  // Neoclassical - strict lower face balance
    white_female: { idealMin: 2.0, idealMax: 2.2 },  // Classical Golden Ratio
    black_male: { idealMin: 2.15, idealMax: 2.70 },  // Accommodates shorter philtrum
    black_female: { idealMin: 2.10, idealMax: 2.65 },
  },

  // ==========================================
  // SKIN QUALITY - Ethnicity variation
  // ==========================================
  skinUniformity: {
    // South Asian: Stricter standards due to genetic hyperpigmentation tendency
    // Hispanic: Similar to South Asian - penalizes hyperpigmentation more than White model
    // Ethnicity-specific override Male:Hispanic.htc - "Bridge Model"
    white_male: { idealMin: 0.88, idealMax: 1.00 },
    white_female: { idealMin: 0.90, idealMax: 1.00 },
    south_asian_male: { idealMin: 0.90, idealMax: 1.00 },  // Stricter - hyperpigmentation common
    south_asian_female: { idealMin: 0.92, idealMax: 1.00 },
    east_asian_male: { idealMin: 0.92, idealMax: 1.00 },  // High skin quality standards
    east_asian_female: { idealMin: 0.94, idealMax: 1.00 },
    black_male: { idealMin: 0.85, idealMax: 1.00 },  // More tolerance for melanin variation
    black_female: { idealMin: 0.87, idealMax: 1.00 },
    hispanic_male: { idealMin: 0.85, idealMax: 1.00 },  // Bridge: more tolerance than South Asian, less than White
    hispanic_female: { idealMin: 0.87, idealMax: 1.00 },
  },

  // ==========================================
  // EYEBROW METRICS - Ethnicity variation
  // ==========================================
  eyebrowThickness: {
    // Middle Eastern: Heavily favors thick, dense eyebrows ("Dark Triad" look with deep-set eyes)
    // Ethnicity-specific override Male:MiddleEastern.htc - STRICTEST eyebrow requirements
    middle_eastern_male: { idealMin: 2.5, idealMax: 5.0 },  // Prefers significantly thicker/darker brows
    middle_eastern_female: { idealMin: 1.5, idealMax: 3.0 },  // Thick, high-contrast brows are ideal
    east_asian_male: { idealMin: 1.5, idealMax: 3.0 },  // Typically less thick
    east_asian_female: { idealMin: 1.3, idealMax: 2.5 },
    male: { idealMin: 2.0, idealMax: 4.0 },
    female: { idealMin: 1.8, idealMax: 3.5 },
  },

  eyebrowDistance: {
    // Middle Eastern: "Kill Switch" for unibrow (synophrys)
    // Ethnicity-specific override Male:MiddleEastern.htc
    // While thick brows are favored, unibrow is a critical flaw if distance < 15mm
    middle_eastern_male: { idealMin: 15, idealMax: 25 },  // Stricter minimum to avoid unibrow
    middle_eastern_female: { idealMin: 18, idealMax: 28 },
    male: { idealMin: 15, idealMax: 25 },
    female: { idealMin: 16, idealMax: 26 },
  },

  orbitalVector: {
    // Middle Eastern: Favors deep-set eyes (lower/negative orbital vector)
    // Part of the "Dark Triad" look with heavy brows
    // Ethnicity-specific override Male:MiddleEastern.htc
    middle_eastern_male: { idealMin: -2, idealMax: 3 },  // Allows more deep-set eyes
    middle_eastern_female: { idealMin: -1, idealMax: 4 },
    male: { idealMin: 0, idealMax: 4 },
    female: { idealMin: 1, idealMax: 5 },
  },

  eyebrowLowSetedness: {
    // East Asian Female: Prefers higher-set, softer brows (less aggressive/masculine)
    // Lower values = higher brow position (more feminine)
    // Ethnicity-specific override Female:East Asian.htc
    east_asian_female: { idealMin: 0.85, idealMax: 1.30 },  // "Soft Brow" preference - penalizes low-set aggressive brows
  },

  cheekFullness: {
    // South Asian: Rewards youthful midface volume, penalizes "Gaunt/Hollow" look more than "Chubby"
    // White: Prefers leaner, "Model" look with defined cheekbones (hollow cheeks acceptable)
    // East Asian Female: Similar to South Asian - neoteny/youthful fullness preference
    // Ethnicity-specific override Female:SouthAsian.htc
    white_male: { idealMin: 0.8, idealMax: 1.5 },  // Accepts hollow cheeks (model/athletic look)
    white_female: { idealMin: 0.9, idealMax: 1.6 },
    south_asian_male: { idealMin: 1.0, idealMax: 1.8 },  // Rewards facial volume
    south_asian_female: { idealMin: 1.0, idealMax: 2.0 },  // Youthful fullness highly valued
    east_asian_female: { idealMin: 1.0, idealMax: 1.9 },  // Neoteny preference - "Doll Face" fullness
    pacific_islander_female: { idealMin: 1.2, idealMax: 2.5 },  // VOLUME is key here (Softness/Health)
    male: { idealMin: 0.9, idealMax: 1.6 },
    female: { idealMin: 1.0, idealMax: 1.8 },
  },

  cheekboneHeight: {
    // Native American Female: High/defined cheekbones are key to facial structure
    // Pacific Islander Female: Similar preference for prominent cheekbones
    native_american_female: { idealMin: 1.5, idealMax: 2.5 },  // DEFINITION is key here (High Zygomas)
    pacific_islander_female: { idealMin: 1.3, idealMax: 2.3 },  // Prominence with volume
  },
};

/**
 * Get metric configuration with demographic-specific overrides applied.
 * Lookup priority: ethnicity_gender > gender > ethnicity > default
 *
 * @param metricId - The metric identifier (e.g., 'nasalIndex', 'gonialAngle')
 * @param gender - The gender ('male' | 'female')
 * @param ethnicity - The ethnicity (defaults to 'other')
 * @param baseConfigs - The base metric configurations to apply overrides to
 * @returns The metric config with demographic-specific ideal ranges applied, or null if not found
 */
export function getMetricConfigForDemographics(
  metricId: string,
  gender: Gender,
  ethnicity: Ethnicity = 'other',
  baseConfigs?: Record<string, MetricConfig>
): MetricConfig | null {
  // Use provided baseConfigs or default to METRIC_CONFIGS
  const configs = baseConfigs || METRIC_CONFIGS;
  const baseConfig = configs[metricId];
  if (!baseConfig) return null;

  const overrides = DEMOGRAPHIC_OVERRIDES[metricId];
  if (!overrides) return baseConfig;

  // Try specific combo first (e.g., "east_asian_male")
  const specificKey = `${ethnicity}_${gender}` as DemographicKey;
  const override = overrides[specificKey] || overrides[gender] || overrides[ethnicity];

  if (!override) return baseConfig;

  return {
    ...baseConfig,
    idealMin: override.idealMin,
    idealMax: override.idealMax,
  };
}
