/**
 * FFMI (Fat-Free Mass Index) Calculator
 *
 * FFMI is a measure of lean body mass relative to height, commonly used
 * to assess muscularity independent of body fat.
 *
 * Formula:
 * - Lean Mass = weight × (1 - bodyFat/100)
 * - FFMI = leanMass / height²  (height in meters)
 * - Normalized FFMI = FFMI + 6.1 × (1.8 - height)
 */

export interface FFMIResult {
  ffmi: number;           // Raw FFMI value
  normalizedFFMI: number; // Adjusted for height
  leanMassKg: number;     // Weight × (1 - bodyFat/100)
  rating: number;         // 0-10 scale
  category: FFMICategory;
}

export type FFMICategory =
  | 'Below Average'
  | 'Average'
  | 'Above Average'
  | 'Excellent'
  | 'Elite';

export type Gender = 'male' | 'female';

/**
 * FFMI thresholds for males
 * Based on natural bodybuilding research
 */
const MALE_THRESHOLDS = {
  belowAverage: 18,   // < 18: Below Average
  average: 20,        // 18-20: Average
  aboveAverage: 22,   // 20-22: Above Average
  excellent: 25,      // 22-25: Excellent
  elite: 25,          // 25+: Elite (near natural limit ~25-26)
} as const;

/**
 * FFMI thresholds for females (~2-3 points lower)
 * Women naturally carry less muscle mass
 */
const FEMALE_THRESHOLDS = {
  belowAverage: 15,   // < 15: Below Average
  average: 17,        // 15-17: Average
  aboveAverage: 19,   // 17-19: Above Average
  excellent: 22,      // 19-22: Excellent
  elite: 22,          // 22+: Elite (near natural limit)
} as const;

/**
 * Calculate FFMI and return detailed results
 *
 * @param heightCm - Height in centimeters
 * @param weightKg - Weight in kilograms
 * @param bodyFatPercent - Body fat percentage (0-100)
 * @param gender - 'male' or 'female' for appropriate thresholds
 * @returns FFMIResult with FFMI, normalized FFMI, lean mass, rating, and category
 */
export function calculateFFMI(
  heightCm: number,
  weightKg: number,
  bodyFatPercent: number,
  gender: Gender = 'male'
): FFMIResult {
  // Input validation
  if (heightCm <= 0 || weightKg <= 0) {
    throw new Error('Height and weight must be positive values');
  }

  // Clamp body fat to reasonable range (0-100)
  const clampedBodyFat = Math.max(0, Math.min(100, bodyFatPercent));

  // Convert height to meters
  const heightM = heightCm / 100;

  // Calculate lean mass
  const leanMassKg = weightKg * (1 - clampedBodyFat / 100);

  // Calculate raw FFMI
  const ffmi = leanMassKg / (heightM * heightM);

  // Calculate normalized FFMI (adjusts for height variance)
  // This formula corrects for the fact that taller people have naturally lower FFMI
  const normalizedFFMI = ffmi + 6.1 * (1.8 - heightM);

  // Get rating and category based on gender
  const { rating, category } = getRatingAndCategory(normalizedFFMI, gender);

  return {
    ffmi: roundTo2(ffmi),
    normalizedFFMI: roundTo2(normalizedFFMI),
    leanMassKg: roundTo2(leanMassKg),
    rating,
    category,
  };
}

/**
 * Get rating (0-10) and category based on normalized FFMI and gender
 */
function getRatingAndCategory(
  normalizedFFMI: number,
  gender: Gender
): { rating: number; category: FFMICategory } {
  const thresholds = gender === 'male' ? MALE_THRESHOLDS : FEMALE_THRESHOLDS;

  let category: FFMICategory;
  let rating: number;

  if (normalizedFFMI < thresholds.belowAverage) {
    // Below Average: 0-3 rating
    category = 'Below Average';
    // Linear interpolation from 0 (FFMI=10) to 3 (FFMI=threshold)
    const minFFMI = gender === 'male' ? 10 : 8;
    rating = interpolate(normalizedFFMI, minFFMI, thresholds.belowAverage, 0, 3);
  } else if (normalizedFFMI < thresholds.average) {
    // Average: 4-5 rating
    category = 'Average';
    rating = interpolate(
      normalizedFFMI,
      thresholds.belowAverage,
      thresholds.average,
      4,
      5
    );
  } else if (normalizedFFMI < thresholds.aboveAverage) {
    // Above Average: 6-7 rating
    category = 'Above Average';
    rating = interpolate(
      normalizedFFMI,
      thresholds.average,
      thresholds.aboveAverage,
      6,
      7
    );
  } else if (normalizedFFMI < thresholds.excellent) {
    // Excellent: 8-9 rating
    category = 'Excellent';
    rating = interpolate(
      normalizedFFMI,
      thresholds.aboveAverage,
      thresholds.excellent,
      8,
      9
    );
  } else {
    // Elite: 10 rating
    category = 'Elite';
    rating = 10;
  }

  // Clamp rating to 0-10
  return {
    rating: Math.max(0, Math.min(10, roundTo1(rating))),
    category,
  };
}

/**
 * Linear interpolation between two ranges
 */
function interpolate(
  value: number,
  inMin: number,
  inMax: number,
  outMin: number,
  outMax: number
): number {
  const ratio = (value - inMin) / (inMax - inMin);
  return outMin + ratio * (outMax - outMin);
}

/**
 * Round to 2 decimal places
 */
function roundTo2(num: number): number {
  return Math.round(num * 100) / 100;
}

/**
 * Round to 1 decimal place
 */
function roundTo1(num: number): number {
  return Math.round(num * 10) / 10;
}

/**
 * Get descriptive text for an FFMI category
 */
export function getFFMICategoryDescription(category: FFMICategory, gender: Gender): string {
  const descriptions: Record<FFMICategory, { male: string; female: string }> = {
    'Below Average': {
      male: 'Lower than average muscle mass. Consider strength training and adequate protein intake.',
      female: 'Lower than average muscle mass. Consider resistance training and adequate nutrition.',
    },
    'Average': {
      male: 'Average muscle development for a man. Room for improvement with consistent training.',
      female: 'Average muscle development for a woman. Room for growth with progressive overload.',
    },
    'Above Average': {
      male: 'Above average muscularity. Good progress with training.',
      female: 'Above average muscularity. Excellent progress for natural training.',
    },
    'Excellent': {
      male: 'Excellent muscle development. Approaching upper limits for natural athletes.',
      female: 'Exceptional muscle development. Near the top for natural female athletes.',
    },
    'Elite': {
      male: 'Elite level muscularity. At or near the natural limit (~25-26 FFMI for men).',
      female: 'Elite level muscularity. At or near the natural limit for women.',
    },
  };

  return descriptions[category][gender];
}

/**
 * Get color associated with FFMI category for UI
 */
export function getFFMICategoryColor(category: FFMICategory): string {
  const colors: Record<FFMICategory, string> = {
    'Below Average': '#EF4444', // red-500
    'Average': '#F59E0B',       // amber-500
    'Above Average': '#3B82F6', // blue-500
    'Excellent': '#10B981',     // emerald-500
    'Elite': '#8B5CF6',         // violet-500
  };

  return colors[category];
}
