/**
 * Insights Engine
 *
 * Processes insight definitions from insights.json and classifies them
 * as strengths or areas of improvement based on user's metric scores.
 *
 * Logic:
 * - For each insight definition, calculate average score of affected metrics
 * - Weakness: if avg score < threshold → classify with severity label
 * - Strength: if avg score > threshold → classify with grade label
 *
 * Z-Score Based Severity Logic (NEW):
 * - Ideal (Green): User is inside the ideal range
 * - Good (Blue): Within 1 Standard Deviation of the mean (|z| < 1)
 * - Moderate (Yellow): Between 1 and 2 Standard Deviations (1 ≤ |z| < 2)
 * - Severe (Red): More than 2 Standard Deviations away (|z| ≥ 2)
 *
 * Severity Labels (Weaknesses):
 *   0-3 = "Severe"
 *   3-5 = "Moderate"
 *   5-7 = "Minor"
 *
 * Grade Labels (Strengths):
 *   8-9   = "Good"
 *   9-9.5 = "Excellent"
 *   9.5-10 = "Ideal"
 */

import { Strength, Flaw } from '@/types/results';
import { FaceIQScoreResult, FACEIQ_METRICS, isValueAcceptable } from '@/lib/faceiq-scoring';

// ============================================
// MASTER SCORING DATABASE (Z-Score Based)
// ============================================

export type SeverityLevel = 'ideal' | 'good' | 'moderate' | 'severe';
export type Gender = 'male' | 'female';
export type Ethnicity = 'white' | 'black' | 'east_asian' | 'south_asian' | 'hispanic' | 'middle_eastern' | 'native_american' | 'pacific_islander';

export interface MasterMetricConfig {
  ideal: [number, number];  // [min, max] ideal range
  mean: number;             // Population mean
  std_dev: number;          // Standard deviation
  flaws?: {
    low?: string[];         // Flaws when value is too low
    high?: string[];        // Flaws when value is too high
  };
}

// Base/Default standards (White Male baseline)
export const MASTER_SCORING_DB: Record<string, MasterMetricConfig> = {
  // MIDFACE & PROPORTIONS
  "midface_ratio": {
    ideal: [0.97, 1.00],
    mean: 1.0,
    std_dev: 0.115,
    flaws: { low: ["Long midface", "Long upper jaw"] }
  },
  "faceWidthToHeight": {
    ideal: [1.30, 1.45],
    mean: 1.38,
    std_dev: 0.08,
    flaws: {
      low: ["Overly long face", "Narrow face"],
      high: ["Wide face", "Short face"]
    }
  },
  "totalFacialWidthToHeight": {
    ideal: [1.25, 1.40],
    mean: 1.33,
    std_dev: 0.075,
    flaws: {
      low: ["Long face shape"],
      high: ["Wide face shape"]
    }
  },
  "upperThirdProportion": {
    ideal: [0.30, 0.36],
    mean: 0.33,
    std_dev: 0.03,
    flaws: {
      low: ["Short forehead"],
      high: ["Long forehead"]
    }
  },
  "middleThirdProportion": {
    ideal: [0.30, 0.36],
    mean: 0.33,
    std_dev: 0.03,
    flaws: {
      low: ["Short midface"],
      high: ["Long midface"]
    }
  },
  "lowerThirdProportion": {
    ideal: [0.30, 0.36],
    mean: 0.33,
    std_dev: 0.03,
    flaws: {
      low: ["Short lower face"],
      high: ["Long lower face"]
    }
  },

  // EYE SPACING & IPD
  "eye_separation_ratio": {
    ideal: [0.45, 0.47],
    mean: 0.46,
    std_dev: 0.03,
    flaws: {
      low: ["Close-set eyes"],
      high: ["Wide-set eyes"]
    }
  },
  "interpupillaryRatio": {
    ideal: [0.44, 0.48],
    mean: 0.46,
    std_dev: 0.025,
    flaws: {
      low: ["Close-set eyes"],
      high: ["Wide-set eyes"]
    }
  },
  "oneEyeApartTest": {
    ideal: [0.95, 1.05],
    mean: 1.0,
    std_dev: 0.08,
    flaws: {
      low: ["Close-set eyes"],
      high: ["Wide-set eyes"]
    }
  },
  "intercanthalWidth": {
    ideal: [30, 35],
    mean: 32.5,
    std_dev: 2.5,
    flaws: {
      low: ["Narrow eye spacing"],
      high: ["Wide eye spacing"]
    }
  },

  // EYE SHAPE & FEATURES
  "lateralCanthalTilt": {
    ideal: [6, 8],
    mean: 5.0,
    std_dev: 3.5,
    flaws: {
      low: ["Negative canthal tilt", "Downturned eyes"],
      high: ["Excessively upturned eyes"]
    }
  },
  "eyeAspectRatio": {
    ideal: [0.30, 0.35],
    mean: 0.32,
    std_dev: 0.04,
    flaws: {
      low: ["Narrow eyes"],
      high: ["Round eyes"]
    }
  },
  "palpebralFissureLength": {
    ideal: [28, 32],
    mean: 30.0,
    std_dev: 2.5,
    flaws: {
      low: ["Small eyes"],
      high: ["Large eyes"]
    }
  },
  "eyeWidth": {
    ideal: [28, 32],
    mean: 30.0,
    std_dev: 2.0,
    flaws: {
      low: ["Narrow eyes"],
      high: ["Wide eyes"]
    }
  },
  "upperEyelidExposure": {
    ideal: [0.5, 1.2],
    mean: 0.85,
    std_dev: 0.35,
    flaws: {
      low: ["Hooded eyes"],
      high: ["Excessive upper lid exposure"]
    }
  },
  "tearTroughDepth": {
    ideal: [0.0, 0.3],
    mean: 0.15,
    std_dev: 0.15,
    flaws: {
      high: ["Dark circles / Tear troughs", "Under-eye hollowness"]
    }
  },

  // JAW ANGLES & STRUCTURE
  "gonial_angle": {
    ideal: [115, 125],
    mean: 118.0,
    std_dev: 6.5,
    flaws: {
      high: ["Weak/soft jaw structure", "Rounded jaw"]
    }
  },
  "mandibularPlaneAngle": {
    ideal: [20, 28],
    mean: 24.0,
    std_dev: 4.0,
    flaws: {
      low: ["Flat mandibular plane"],
      high: ["Steep mandibular plane", "Hyper-divergent jaw"]
    }
  },
  "jawFrontalAngle": {
    ideal: [125, 135],
    mean: 130.0,
    std_dev: 5.0,
    flaws: {
      low: ["Steep jaw"],
      high: ["Flat jaw angle"]
    }
  },
  "jawSlope": {
    ideal: [25, 35],
    mean: 30.0,
    std_dev: 5.0,
    flaws: {
      low: ["Flat jawline"],
      high: ["Steep jawline"]
    }
  },

  // JAW WIDTH
  "jawWidthRatio": {
    ideal: [0.85, 0.95],
    mean: 0.90,
    std_dev: 0.05,
    flaws: {
      low: ["Narrow jaw"],
      high: ["Wide jaw"]
    }
  },
  "bigonialWidth": {
    ideal: [110, 125],
    mean: 117.5,
    std_dev: 7.5,
    flaws: {
      low: ["Narrow jaw width"],
      high: ["Excessively wide jaw"]
    }
  },

  // CHEEKBONES
  "cheekbone_height": {
    ideal: [83.0, 100.0],
    mean: 85.0,
    std_dev: 5.0,
    flaws: {
      low: ["Low-set cheekbones", "Flat midface"]
    }
  },
  "cheekboneWidth": {
    ideal: [130, 145],
    mean: 137.5,
    std_dev: 7.5,
    flaws: {
      low: ["Narrow cheekbones"],
      high: ["Wide cheekbones"]
    }
  },

  // CHIN
  "chinPhiltrumRatio": {
    ideal: [1.8, 2.2],
    mean: 2.0,
    std_dev: 0.2,
    flaws: {
      low: ["Recessed chin", "Short chin"],
      high: ["Long chin", "Projected chin"]
    }
  },
  "chinHeight": {
    ideal: [35, 45],
    mean: 40.0,
    std_dev: 5.0,
    flaws: {
      low: ["Short chin"],
      high: ["Long chin"]
    }
  },
  "chinWidth": {
    ideal: [35, 45],
    mean: 40.0,
    std_dev: 5.0,
    flaws: {
      low: ["Pointed/Narrow chin"],
      high: ["Wide chin"]
    }
  },

  // NOSE ANGLES
  "nasalTipAngle": {
    ideal: [95, 115],
    mean: 105.0,
    std_dev: 10.0,
    flaws: {
      low: ["Droopy nasal tip"],
      high: ["Upturned nasal tip"]
    }
  },
  "nasolabialAngle": {
    ideal: [95, 110],
    mean: 102.5,
    std_dev: 7.5,
    flaws: {
      low: ["Droopy nasal tip"],
      high: ["Upturned nose"]
    }
  },
  "nasofrontalAngle": {
    ideal: [115, 135],
    mean: 125.0,
    std_dev: 10.0,
    flaws: {
      low: ["Deep nasal root"],
      high: ["Flat nasal root"]
    }
  },
  "nasofacialAngle": {
    ideal: [30, 40],
    mean: 35.0,
    std_dev: 5.0,
    flaws: {
      low: ["Flat nose profile"],
      high: ["Overprojected nose"]
    }
  },
  "nasomentaAngle": {
    ideal: [120, 135],
    mean: 127.5,
    std_dev: 7.5,
    flaws: {
      low: ["Convex profile"],
      high: ["Concave profile"]
    }
  },

  // NOSE WIDTH & PROPORTIONS
  "nasalIndex": {
    ideal: [65, 75],
    mean: 70.0,
    std_dev: 5.0,
    flaws: {
      low: ["Narrow nose"],
      high: ["Wide nose", "Bulbous nose"]
    }
  },
  "noseWidth": {
    ideal: [35, 42],
    mean: 38.5,
    std_dev: 3.5,
    flaws: {
      low: ["Narrow nose"],
      high: ["Wide nasal base"]
    }
  },
  "noseBridgeWidth": {
    ideal: [12, 18],
    mean: 15.0,
    std_dev: 3.0,
    flaws: {
      low: ["Narrow nose bridge"],
      high: ["Wide nose bridge"]
    }
  },
  "nasalProjection": {
    ideal: [16, 22],
    mean: 19.0,
    std_dev: 3.0,
    flaws: {
      low: ["Underprojected nose"],
      high: ["Overprojected nose"]
    }
  },
  "noseLengthRatio": {
    ideal: [0.45, 0.55],
    mean: 0.50,
    std_dev: 0.05,
    flaws: {
      low: ["Short nose"],
      high: ["Long nose"]
    }
  },

  // LIPS & PHILTRUM
  "lipRatio": {
    ideal: [1.4, 1.6],
    mean: 1.5,
    std_dev: 0.15,
    flaws: {
      low: ["Thin upper lip"],
      high: ["Thick upper lip"]
    }
  },
  "philtrumLength": {
    ideal: [11, 15],
    mean: 13.0,
    std_dev: 2.0,
    flaws: {
      low: ["Short philtrum"],
      high: ["Long philtrum"]
    }
  },
  "upperLipHeight": {
    ideal: [18, 24],
    mean: 21.0,
    std_dev: 3.0,
    flaws: {
      low: ["Thin upper lip"],
      high: ["Thick upper lip"]
    }
  },
  "lipChinDistance": {
    ideal: [40, 50],
    mean: 45.0,
    std_dev: 5.0,
    flaws: {
      low: ["Short lower third"],
      high: ["Long lower third"]
    }
  },
  "upperLipProjection": {
    ideal: [-2, 2],
    mean: 0.0,
    std_dev: 2.0,
    flaws: {
      low: ["Recessed upper lip"],
      high: ["Protruding upper lip"]
    }
  },
  "lowerLipProjection": {
    ideal: [-1, 3],
    mean: 1.0,
    std_dev: 2.0,
    flaws: {
      low: ["Recessed lower lip"],
      high: ["Protruding lower lip"]
    }
  },
  "cupidsBowDepth": {
    ideal: [3, 6],
    mean: 4.5,
    std_dev: 1.5,
    flaws: {
      low: ["Flat cupid's bow"],
      high: ["Pronounced cupid's bow"]
    }
  },

  // EYEBROWS
  "eyebrowHeight": {
    ideal: [8, 14],
    mean: 11.0,
    std_dev: 3.0,
    flaws: {
      low: ["Low-set eyebrows"],
      high: ["High eyebrows"]
    }
  },
  "browLengthRatio": {
    ideal: [0.50, 0.60],
    mean: 0.55,
    std_dev: 0.05,
    flaws: {
      low: ["Short eyebrows"],
      high: ["Long eyebrows"]
    }
  },
  "browLengthToFaceWidth": {
    ideal: [0.30, 0.38],
    mean: 0.34,
    std_dev: 0.04,
    flaws: {
      low: ["Short eyebrows"],
      high: ["Long eyebrows"]
    }
  },
  "browridgeInclinationAngle": {
    ideal: [10, 20],
    mean: 15.0,
    std_dev: 5.0,
    flaws: {
      low: ["Flat brow ridge"],
      high: ["Prominent brow ridge"]
    }
  },
  "eyebrowThickness": {
    ideal: [1.5, 3.0],
    mean: 2.25,
    std_dev: 0.75,
    flaws: {
      low: ["Sparse/Weak eyebrows"],
      high: ["Overly thick eyebrows"]
    }
  },

  // FOREHEAD
  "foreheadHeight": {
    ideal: [55, 70],
    mean: 62.5,
    std_dev: 7.5,
    flaws: {
      low: ["Short forehead"],
      high: ["Tall forehead"]
    }
  },
  "bitemporalWidth": {
    ideal: [120, 135],
    mean: 127.5,
    std_dev: 7.5,
    flaws: {
      low: ["Narrow forehead"],
      high: ["Wide forehead"]
    }
  },

  // PROFILE & DEPTH
  "facialDepthToHeight": {
    ideal: [0.75, 0.85],
    mean: 0.80,
    std_dev: 0.05,
    flaws: {
      low: ["Flat facial profile"],
      high: ["Overprojected profile"]
    }
  },
  "anteriorFacialDepth": {
    ideal: [115, 130],
    mean: 122.5,
    std_dev: 7.5,
    flaws: {
      low: ["Shallow face depth"],
      high: ["Deep face projection"]
    }
  },
  "totalProfileAngle": {
    ideal: [165, 175],
    mean: 170.0,
    std_dev: 5.0,
    flaws: {
      low: ["Convex profile"],
      high: ["Concave profile"]
    }
  },

  // ASYMMETRY
  "facialAsymmetryIndex": {
    ideal: [0, 3],
    mean: 2.0,
    std_dev: 1.5,
    flaws: {
      high: ["Facial asymmetry"]
    }
  },
  "eyeAsymmetry": {
    ideal: [0, 2],
    mean: 1.0,
    std_dev: 1.0,
    flaws: {
      high: ["Eye asymmetry"]
    }
  },
  "jawAsymmetry": {
    ideal: [0, 3],
    mean: 1.5,
    std_dev: 1.5,
    flaws: {
      high: ["Jaw asymmetry"]
    }
  },

  // OTHER
  "recessionFrankfort": {
    ideal: [-2, 2],
    mean: 0.0,
    std_dev: 2.0,
    flaws: {
      low: ["Maxillary recession"],
      high: ["Maxillary protrusion"]
    }
  },
  "neckWidth": {
    ideal: [110, 130],
    mean: 120.0,
    std_dev: 10.0,
    flaws: {
      low: ["Narrow neck"],
      high: ["Wide neck"]
    }
  },
  "neckToJawRatio": {
    ideal: [0.90, 1.10],
    mean: 1.0,
    std_dev: 0.10,
    flaws: {
      low: ["Narrow neck"],
      high: ["Thick neck"]
    }
  }
};

// ============================================
// ETHNICITY-SPECIFIC OVERRIDES
// ============================================

/**
 * Ethnicity and gender-specific metric standards
 * These override the base MASTER_SCORING_DB values for specific populations
 */
export const ETHNICITY_OVERRIDES: Record<string, Record<string, Partial<MasterMetricConfig>>> = {
  // ========================================
  // MALE WHITE STANDARDS (Neoclassical Baseline)
  // ========================================
  "male_white": {
    // NOSE WIDTH - Strict 1:1 ratio (Eye Width = Nose Width)
    "noseWidth": {
      ideal: [35, 42],  // Corresponds to alar_base_ratio [0.98, 1.05]
      mean: 38.5,
      std_dev: 3.5,
      flaws: {
        high: ["Wide nasal base"]
      }
    },

    // MIDFACE - Prefers compact midface (Hunter look)
    "midface_ratio": {
      ideal: [0.95, 1.02],
      mean: 0.985,
      std_dev: 0.035,
      flaws: {
        low: ["Long midface"]
      }
    },

    // JAW - Square/Robust jaw preference
    "gonial_angle": {
      ideal: [115.0, 125.0],
      mean: 120.0,
      std_dev: 5.0,
      flaws: {
        high: ["Weak/Soft jaw structure"]
      }
    },

    // FACE WIDTH - Standard Mesoprosopic range
    "faceWidthToHeight": {
      ideal: [1.90, 2.05],
      mean: 1.975,
      std_dev: 0.075,
      flaws: {
        low: ["Narrow face"],
        high: ["Short/Wide face"]
      }
    },

    // EYE TILT - Neutral to slightly positive
    "lateralCanthalTilt": {
      ideal: [4.0, 8.0],
      mean: 6.0,
      std_dev: 2.0,
      flaws: {
        low: ["Negative canthal tilt"]
      }
    },

    // LOWER FACE BALANCE
    "chinPhiltrumRatio": {
      ideal: [2.10, 2.30],
      mean: 2.20,
      std_dev: 0.10,
      flaws: {
        low: ["Long philtrum / Short chin"]
      }
    }
  },

  // ========================================
  // MALE BLACK / AFRICAN STANDARDS
  // ========================================
  "male_black": {
    // NOSE WIDTH - Significantly wider tolerance
    "noseWidth": {
      ideal: [40, 50],  // Wider range (corresponds to alar_base_ratio [1.12, 1.25])
      mean: 45.0,
      std_dev: 5.0,
      flaws: {
        high: ["Wide nasal base"]
      }
    },
    "nasalIndex": {
      ideal: [80, 95],  // Wider nasal index
      mean: 87.5,
      std_dev: 7.5,
      flaws: {
        high: ["Wide nose"]
      }
    },

    // LIPS - Prefers fuller lips
    "lipRatio": {
      ideal: [1.2, 1.5],
      mean: 1.35,
      std_dev: 0.15,
      flaws: {
        low: ["Thin lips"]
      }
    },

    // PHILTRUM - Shorter visible philtrum is ideal
    "philtrumLength": {
      ideal: [11.0, 14.0],
      mean: 12.5,
      std_dev: 1.5,
      flaws: {
        high: ["Long philtrum"]
      }
    },

    // CHIN - Adjusts for natural forward mouth projection (Prognathism)
    "chinPhiltrumRatio": {
      ideal: [1.80, 2.10],  // Lower range to account for prognathism
      mean: 1.95,
      std_dev: 0.15,
      flaws: {
        low: ["Recessed chin"]
      }
    }
  },

  // ========================================
  // MALE EAST ASIAN STANDARDS
  // ========================================
  "male_east_asian": {
    // EYE SPACING - Shifted WIDER for East Asian males
    "eye_separation_ratio": {
      ideal: [0.48, 0.53],  // Shifted wider (0.46 is "close-set" here)
      mean: 0.505,
      std_dev: 0.025,
      flaws: {
        low: ["Close-set eyes"],
        high: ["Wide-set eyes"]
      }
    },
    "interpupillaryRatio": {
      ideal: [0.48, 0.53],
      mean: 0.505,
      std_dev: 0.025,
      flaws: {
        low: ["Close-set eyes"],
        high: ["Wide-set eyes"]
      }
    },

    // EYE SHAPE - Prefers narrower/longer eyes (Hunter Eyes)
    "eyeAspectRatio": {
      ideal: [0.25, 0.29],  // Lower ratio = more elongated
      mean: 0.27,
      std_dev: 0.02,
      flaws: {
        low: ["Overly narrow eyes"],
        high: ["Overly round eye shape"]
      }
    },
    "palpebralFissureLength": {
      ideal: [29, 33],
      mean: 31.0,
      std_dev: 2.0,
      flaws: {
        low: ["Small eyes"],
        high: ["Large eyes"]
      }
    },

    // NOSE - Asian noses typically allowed to be wider
    "nasalIndex": {
      ideal: [75, 85],
      mean: 80.0,
      std_dev: 5.0,
      flaws: {
        high: ["Wide nose"]
      }
    },
    "noseWidth": {
      ideal: [38, 45],
      mean: 41.5,
      std_dev: 3.5,
      flaws: {
        low: ["Narrow nose"],
        high: ["Very wide nasal base"]
      }
    },
    "noseBridgeWidth": {
      ideal: [14, 20],
      mean: 17.0,
      std_dev: 3.0,
      flaws: {
        low: ["Narrow nose bridge"],
        high: ["Wide nose bridge"]
      }
    },

    // CHEEKS - Rewards slightly fuller cheeks (Youth/K-Pop aesthetic)
    "cheekbone_height": {
      ideal: [80.0, 95.0],
      mean: 87.5,
      std_dev: 7.5,
      flaws: {
        low: ["Gaunt/Hollow face"]
      }
    },

    // JAW - Slightly softer angles acceptable
    "gonial_angle": {
      ideal: [118, 128],
      mean: 123.0,
      std_dev: 5.0,
      flaws: {
        high: ["Weak/soft jaw structure"]
      }
    },
    "mandibularPlaneAngle": {
      ideal: [20, 30],
      mean: 25.0,
      std_dev: 5.0,
      flaws: {
        low: ["Flat mandibular plane"],
        high: ["Steep mandibular plane"]
      }
    },

    // FACIAL PROPORTIONS - Wider faces more common
    "faceWidthToHeight": {
      ideal: [1.35, 1.50],
      mean: 1.425,
      std_dev: 0.075,
      flaws: {
        low: ["Long face"],
        high: ["Very wide face"]
      }
    },
    "totalFacialWidthToHeight": {
      ideal: [1.30, 1.45],
      mean: 1.375,
      std_dev: 0.075,
      flaws: {
        low: ["Long face shape"],
        high: ["Wide face shape"]
      }
    }
  },

  // ========================================
  // MALE SOUTH ASIAN STANDARDS
  // ========================================
  "male_south_asian": {
    // NOSE WIDTH - Slightly wider tolerance than White
    "noseWidth": {
      ideal: [36, 43],  // alar_base_ratio [1.00, 1.08]
      mean: 39.5,
      std_dev: 3.5,
      flaws: {
        high: ["Wide nasal base"]
      }
    },

    // TEAR TROUGH - VERY STRICT. High penalty for dark circles
    "tearTroughDepth": {
      ideal: [0.0, 0.5],
      mean: 0.25,
      std_dev: 0.25,
      flaws: {
        high: ["Dark circles / Tear troughs"]
      }
    },

    // UPPER EYELID - Often prefers visible lid platform
    "upperEyelidExposure": {
      ideal: [0.5, 2.0],
      mean: 1.25,
      std_dev: 0.75,
      flaws: {
        low: ["Hooded eyes"]
      }
    },

    // CHEEKS - Penalizes "Gaunt" looks heavily
    "cheekbone_height": {
      ideal: [83.0, 95.0],
      mean: 89.0,
      std_dev: 6.0,
      flaws: {
        low: ["Volume loss / Gauntness"]
      }
    }
  },

  // ========================================
  // MALE HISPANIC STANDARDS ("The Bridge Model")
  // ========================================
  "male_hispanic": {
    // FACE WIDTH - Rewards broader, more robust face shapes (Mestizo)
    "faceWidthToHeight": {
      ideal: [1.95, 2.10],
      mean: 2.025,
      std_dev: 0.075,
      flaws: {
        low: ["Long/Narrow face"]
      }
    },

    // NOSE WIDTH - Bridge tolerance (Wider than White, narrower than Black)
    "noseWidth": {
      ideal: [36, 44],  // alar_base_ratio [1.00, 1.12]
      mean: 40.0,
      std_dev: 4.0,
      flaws: {
        high: ["Wide nasal base"]
      }
    },

    // EYE TILT - Strong preference for positive tilt
    "lateralCanthalTilt": {
      ideal: [6.0, 12.0],
      mean: 9.0,
      std_dev: 3.0,
      flaws: {
        low: ["Negative/Neutral canthal tilt"]
      }
    }
  },

  // ========================================
  // MALE MIDDLE EASTERN STANDARDS
  // ========================================
  "male_middle_eastern": {
    // EYEBROW THICKNESS - Prefers significantly thicker/darker brows
    "eyebrowThickness": {
      ideal: [2.0, 4.0],
      mean: 3.0,
      std_dev: 1.0,
      flaws: {
        low: ["Sparse/Weak eyebrows"],
        high: ["Unibrow"]
      }
    },

    // NASOLABIAL ANGLE - Penalizes droopy tip (<90) or hooked noses
    "nasolabialAngle": {
      ideal: [90.0, 100.0],
      mean: 95.0,
      std_dev: 5.0,
      flaws: {
        low: ["Droopy nose tip / Hooked nose"]
      }
    },

    // EYE TILT - Strong preference for Almond/Hunter eye shape
    "lateralCanthalTilt": {
      ideal: [4.0, 10.0],
      mean: 7.0,
      std_dev: 3.0,
      flaws: {
        low: ["Downturned eyes"]
      }
    },

    // MIDFACE - Similar to White model (Compact is better)
    "midface_ratio": {
      ideal: [0.95, 1.02],
      mean: 0.985,
      std_dev: 0.035,
      flaws: {
        low: ["Long midface"]
      }
    }
  },

  // ========================================
  // MALE PACIFIC ISLANDER STANDARDS ("The Warrior Skull")
  // ========================================
  "male_pacific_islander": {
    // FACE WIDTH - The Highest Width Standard (Very broad)
    "faceWidthToHeight": {
      ideal: [2.10, 2.30],
      mean: 2.20,
      std_dev: 0.10,
      flaws: {
        low: ["Narrow/Long face"]
      }
    },

    // NOSE WIDTH - Wide tolerance
    "noseWidth": {
      ideal: [38, 48],  // alar_base_ratio [1.05, 1.20]
      mean: 43.0,
      std_dev: 5.0,
      flaws: {
        high: ["Wide nasal base"]
      }
    },

    // CHEEKS - Rewards high mass/robustness
    "cheekbone_height": {
      ideal: [85.0, 100.0],
      mean: 92.5,
      std_dev: 7.5,
      flaws: {
        low: ["Gaunt/Weak face structure"]
      }
    },

    // CHIN WIDTH - Prefers a very broad, square chin
    "chinWidth": {
      ideal: [40.0, 50.0],
      mean: 45.0,
      std_dev: 5.0,
      flaws: {
        low: ["Pointed/Narrow chin"]
      }
    }
  },

  // ========================================
  // FEMALE ETHNICITIES (The "Missing Link")
  // ========================================

  "female_white": {
    // NOSE WIDTH - Strict Rule of Fifths for feminine harmony
    "alar_base_ratio": {
      ideal: [0.98, 1.05],
      mean: 1.015,
      std_dev: 0.035,
      flaws: {
        high: ["Wide nasal base"]
      }
    },

    // FACE WIDTH - Prefers oval/narrow feminine proportions
    "fwhr": {
      ideal: [1.45, 1.53],
      mean: 1.49,
      std_dev: 0.04,
      flaws: {
        low: ["Long/Narrow face"],
        high: ["Wide face"]
      }
    },

    // JAW - Soft, tapered feminine jawline
    "gonial_angle": {
      ideal: [122.0, 130.0],
      mean: 126.0,
      std_dev: 4.0,
      flaws: {
        low: ["Sharp/Masculine jaw angle"],
        high: ["Weak/Overly soft jawline"]
      }
    },

    // EYE TILT - Neutral to positive preferred
    "canthal_tilt": {
      ideal: [4.0, 9.0],
      mean: 6.5,
      std_dev: 2.5,
      flaws: {
        low: ["Negative/Downturned eyes"]
      }
    },

    // CHIN-PHILTRUM - Golden Ratio balance
    "chin_philtrum_ratio": {
      ideal: [2.0, 2.2],
      mean: 2.1,
      std_dev: 0.1,
      flaws: {
        low: ["Recessed chin"],
        high: ["Protruding chin"]
      }
    }
  },

  "female_black": {
    // LIPS - High volume preference (fuller lips)
    "lipRatio": {
      ideal: [1.3, 1.6],
      mean: 1.45,
      std_dev: 0.15,
      flaws: {
        low: ["Thin lips"]
      }
    },

    // NOSE WIDTH - Wider tolerance for ethnic variation
    "alar_base_ratio": {
      ideal: [1.05, 1.15],
      mean: 1.10,
      std_dev: 0.05,
      flaws: {
        high: ["Very wide nasal base"]
      }
    },

    // CHIN - Allows forward projection (natural prognathism)
    "chin_projection": {
      ideal: [0.0, 5.0],
      mean: 2.5,
      std_dev: 2.5,
      flaws: {
        high: ["Excessive chin projection"]
      }
    },

    // JAW - Soft feminine jawline
    "gonial_angle": {
      ideal: [120.0, 130.0],
      mean: 125.0,
      std_dev: 5.0,
      flaws: {
        low: ["Sharp jaw angle"],
        high: ["Weak jawline"]
      }
    }
  },

  "female_east_asian": {
    // EYE SPACING - Wide-set neotenous preference
    "eye_separation_ratio": {
      ideal: [46.3, 47.5],
      mean: 46.9,
      std_dev: 0.6,
      flaws: {
        low: ["Close-set eyes"],
        high: ["Very wide-set eyes"]
      }
    },

    // JAW - Tapered V-shape feminine ideal
    "gonial_angle": {
      ideal: [120.0, 126.0],
      mean: 123.0,
      std_dev: 3.0,
      flaws: {
        low: ["Sharp V-line jaw"],
        high: ["Weak/Square jawline"]
      }
    },

    // EYEBROWS - Higher set brows (youthful feminine)
    "eyebrow_height": {
      ideal: [0.85, 1.30],
      mean: 1.075,
      std_dev: 0.225,
      flaws: {
        low: ["Low-set/Heavy brows"],
        high: ["Very high-arched brows"]
      }
    },

    // LOWER FACE - Compact lower third (neotenous)
    "lower_third_ratio": {
      ideal: [29.6, 32.7],
      mean: 31.15,
      std_dev: 1.55,
      flaws: {
        low: ["Very short lower face"],
        high: ["Long lower face"]
      }
    }
  },

  "female_south_asian": {
    // TEAR TROUGHS - Very strict on dark circles
    "tear_trough_depth": {
      ideal: [0.0, 0.5],
      mean: 0.25,
      std_dev: 0.25,
      flaws: {
        high: ["Dark circles / Deep tear troughs"]
      }
    },

    // CHEEKS - Rewards midface volume (youthful fullness)
    "cheek_fullness": {
      ideal: [1.0, 2.0],
      mean: 1.5,
      std_dev: 0.5,
      flaws: {
        low: ["Gaunt/Hollow cheeks"]
      }
    },

    // SKIN - High penalty for uneven skin tone
    "skin_uniformity": {
      ideal: [0.92, 1.0],
      mean: 0.96,
      std_dev: 0.04,
      flaws: {
        low: ["Uneven skin tone / Pigmentation"]
      }
    },

    // NOSE WIDTH - Intermediate tolerance
    "alar_base_ratio": {
      ideal: [1.00, 1.08],
      mean: 1.04,
      std_dev: 0.04,
      flaws: {
        high: ["Wide nasal base"]
      }
    }
  },

  "female_hispanic": {
    // FACE WIDTH - Broader Mestiza tolerance
    "fwhr": {
      ideal: [1.50, 1.62],
      mean: 1.56,
      std_dev: 0.06,
      flaws: {
        low: ["Long/Narrow face"],
        high: ["Very wide face"]
      }
    },

    // EYE TILT - Strong almond eye preference
    "canthal_tilt": {
      ideal: [6.0, 12.0],
      mean: 9.0,
      std_dev: 3.0,
      flaws: {
        low: ["Neutral/Downturned eyes"]
      }
    },

    // NOSE WIDTH - Intermediate width tolerance
    "alar_base_ratio": {
      ideal: [1.00, 1.10],
      mean: 1.05,
      std_dev: 0.05,
      flaws: {
        high: ["Wide nasal base"]
      }
    },

    // LIPS - Voluptuous preference
    "lipRatio": {
      ideal: [1.1, 1.35],
      mean: 1.225,
      std_dev: 0.125,
      flaws: {
        low: ["Thin lips"]
      }
    }
  },

  "female_middle_eastern": {
    // EYEBROWS - Dense/Thick brows preference
    "eyebrow_thickness": {
      ideal: [1.5, 3.0],
      mean: 2.25,
      std_dev: 0.75,
      flaws: {
        low: ["Sparse/Thin eyebrows"],
        high: ["Unibrow"]
      }
    },

    // NOSE - Refined/Upturned tip
    "nasolabial_angle": {
      ideal: [95.0, 105.0],
      mean: 100.0,
      std_dev: 5.0,
      flaws: {
        low: ["Droopy nose tip"],
        high: ["Overly upturned nose"]
      }
    },

    // EYE TILT - Foxy/Hunter feminine eye shape
    "canthal_tilt": {
      ideal: [5.0, 10.0],
      mean: 7.5,
      std_dev: 2.5,
      flaws: {
        low: ["Downturned eyes"]
      }
    },

    // EYELID - Low exposure preferred
    "upper_eyelid_exposure": {
      ideal: [0.5, 1.5],
      mean: 1.0,
      std_dev: 0.5,
      flaws: {
        low: ["Hooded eyes"],
        high: ["Excessive eyelid exposure"]
      }
    }
  },

  "female_native_american": {
    // FACE WIDTH - Wide/High cheekbone structure
    "fwhr": {
      ideal: [1.52, 1.65],
      mean: 1.585,
      std_dev: 0.065,
      flaws: {
        low: ["Narrow face"],
        high: ["Very wide face"]
      }
    },

    // CHEEKBONES - High definition/prominence
    "cheekbone_prominence": {
      ideal: [1.5, 2.5],
      mean: 2.0,
      std_dev: 0.5,
      flaws: {
        low: ["Flat cheekbones"],
        high: ["Overly prominent cheekbones"]
      }
    },

    // JAW - Stronger jaw tolerance
    "gonial_angle": {
      ideal: [115.0, 125.0],
      mean: 120.0,
      std_dev: 5.0,
      flaws: {
        low: ["Very sharp jaw"],
        high: ["Weak jawline"]
      }
    },

    // EYE TILT - Positive tilt preference
    "canthal_tilt": {
      ideal: [5.0, 11.0],
      mean: 8.0,
      std_dev: 3.0,
      flaws: {
        low: ["Downturned eyes"]
      }
    }
  },

  "female_pacific_islander": {
    // FACE WIDTH - Widest/Robust facial structure
    "fwhr": {
      ideal: [1.55, 1.70],
      mean: 1.625,
      std_dev: 0.075,
      flaws: {
        low: ["Narrow face"],
        high: ["Very wide face"]
      }
    },

    // CHEEKS - High volume/softness preference
    "cheek_fullness": {
      ideal: [1.2, 2.5],
      mean: 1.85,
      std_dev: 0.65,
      flaws: {
        low: ["Gaunt/Hollow cheeks"]
      }
    },

    // NOSE WIDTH - Wide nose tolerance
    "alar_base_ratio": {
      ideal: [1.05, 1.15],
      mean: 1.10,
      std_dev: 0.05,
      flaws: {
        high: ["Very wide nasal base"]
      }
    },

    // LIPS - Full lips preference
    "lipRatio": {
      ideal: [1.25, 1.50],
      mean: 1.375,
      std_dev: 0.125,
      flaws: {
        low: ["Thin lips"]
      }
    }
  }
};

/**
 * Get the appropriate metric configuration for a given gender and ethnicity
 * Falls back to base config if no override exists
 */
export function getMetricConfig(
  metricId: string,
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'white'
): MasterMetricConfig | undefined {
  const key = `${gender}_${ethnicity}`;
  const override = ETHNICITY_OVERRIDES[key]?.[metricId];
  const baseConfig = MASTER_SCORING_DB[metricId];

  if (!baseConfig) return undefined;

  // Merge override with base config
  if (override) {
    return {
      ...baseConfig,
      ...override,
      flaws: {
        ...baseConfig.flaws,
        ...override.flaws
      }
    } as MasterMetricConfig;
  }

  return baseConfig;
}

// ============================================
// Z-SCORE SEVERITY FUNCTIONS
// ============================================

/**
 * Calculate Z-score for a given value
 * Z = (value - mean) / std_dev
 */
export function calculateZScore(value: number, mean: number, stdDev: number): number {
  if (stdDev === 0) return 0;
  return Math.abs((value - mean) / stdDev);
}

/**
 * Determine severity level based on Z-score and ideal range
 * - Ideal: Value is within ideal range
 * - Good: |z| < 1 (within 1 standard deviation)
 * - Moderate: 1 ≤ |z| < 2 (between 1-2 standard deviations)
 * - Severe: |z| ≥ 2 (more than 2 standard deviations away)
 */
export function getSeverityFromZScore(
  value: number,
  config: MasterMetricConfig
): { severity: SeverityLevel; zScore: number; isInIdeal: boolean } {
  const { ideal, mean, std_dev } = config;
  const isInIdeal = value >= ideal[0] && value <= ideal[1];
  const zScore = calculateZScore(value, mean, std_dev);

  let severity: SeverityLevel;
  if (isInIdeal) {
    severity = 'ideal';
  } else if (zScore < 1) {
    severity = 'good';
  } else if (zScore < 2) {
    severity = 'moderate';
  } else {
    severity = 'severe';
  }

  return { severity, zScore, isInIdeal };
}

/**
 * Get severity for a metric value with ethnicity/gender awareness
 */
export function getSeverityForMetric(
  metricId: string,
  value: number,
  gender: Gender = 'male',
  ethnicity: Ethnicity = 'white'
): { severity: SeverityLevel; zScore: number; isInIdeal: boolean; config: MasterMetricConfig } | null {
  const config = getMetricConfig(metricId, gender, ethnicity);
  if (!config) return null;

  const result = getSeverityFromZScore(value, config);
  return { ...result, config };
}

/**
 * Get badge color for severity level
 */
export function getSeverityColor(severity: SeverityLevel): string {
  switch (severity) {
    case 'ideal': return 'green';
    case 'good': return 'blue';
    case 'moderate': return 'yellow';
    case 'severe': return 'red';
    default: return 'gray';
  }
}

/**
 * Get severity label for display
 */
export function getSeverityLabel(severity: SeverityLevel): string {
  switch (severity) {
    case 'ideal': return 'Ideal';
    case 'good': return 'Good';
    case 'moderate': return 'Moderate';
    case 'severe': return 'Severe';
    default: return 'Unknown';
  }
}

// ============================================
// INSIGHT DEFINITION TYPES
// ============================================

export interface InsightSeverityLogic {
  metrics: string[];  // Display names of metrics (e.g., "Face Width to Height Ratio")
  threshold: number;  // Score threshold for classification
}

export interface WeaknessSeverityLabels {
  minor: string;
  moderate: string;
  severe: string;
}

export interface StrengthGradeLabels {
  good: string;
  excellent: string;
  ideal: string;
}

export interface InsightContent {
  description: string;
  severity_labels?: WeaknessSeverityLabels;  // For weaknesses
  grade_labels?: StrengthGradeLabels;        // For strengths
}

export interface InsightDefinition {
  id: string;
  title: string;
  type: 'weakness' | 'strength';
  severity_logic: InsightSeverityLogic;
  content: InsightContent;
}

// ============================================
// CLASSIFICATION RESULT TYPES
// ============================================

export type WeaknessSeverity = 'severe' | 'moderate' | 'minor';
export type StrengthGrade = 'ideal' | 'excellent' | 'good';

export interface ClassifiedWeakness {
  insightId: string;
  title: string;
  description: string;
  severity: WeaknessSeverity;
  severityLabel: string;  // Custom label from definition (e.g., "Extremely Long")
  avgScore: number;
  matchedMetrics: MatchedMetric[];
}

export interface ClassifiedStrength {
  insightId: string;
  title: string;
  description: string;
  grade: StrengthGrade;
  gradeLabel: string;  // Custom label from definition (e.g., "Ideal")
  avgScore: number;
  matchedMetrics: MatchedMetric[];
}

export interface MatchedMetric {
  metricId: string;
  metricName: string;
  score: number;
  value: number;
  idealMin: number;
  idealMax: number;
  unit: string;
  category: string;
}

export interface InsightClassificationResult {
  strengths: ClassifiedStrength[];
  weaknesses: ClassifiedWeakness[];
}

// ============================================
// INSIGHTS DATABASE
// ============================================

export const INSIGHTS_DEFINITIONS: InsightDefinition[] = [
  {
    id: "long_midface",
    title: "Long Midface",
    type: "weakness",
    severity_logic: {
      metrics: ["Face Width to Height Ratio", "Midface Ratio", "Ipsilateral Alar Angle"],
      threshold: 6.0
    },
    content: {
      description: "The middle of the face is elongated, creating an unbalanced vertical proportion.",
      severity_labels: { minor: "Slightly Long", moderate: "Long", severe: "Extremely Long" }
    }
  },
  {
    id: "short_midface",
    title: "Short Midface",
    type: "strength",
    severity_logic: {
      metrics: ["Face Width to Height Ratio", "Midface Ratio"],
      threshold: 8.0
    },
    content: {
      description: "The midface has ideal vertical proportions, contributing to facial harmony.",
      grade_labels: { good: "Proportionate", excellent: "Well-Balanced", ideal: "Ideal" }
    }
  },
  {
    id: "weak_jaw",
    title: "Weak/Soft Jaw Structure",
    type: "weakness",
    severity_logic: {
      metrics: ["Gonial Angle", "Mandibular Plane Angle", "Chin to Philtrum Ratio", "Jaw Slope"],
      threshold: 5.0
    },
    content: {
      description: "The jaw has a softer, rounder shape, often less angular and robust than the ideal.",
      severity_labels: { minor: "Soft", moderate: "Recessed", severe: "Weak" }
    }
  },
  {
    id: "strong_jaw",
    title: "Strong Jaw Definition",
    type: "strength",
    severity_logic: {
      metrics: ["Gonial Angle", "Mandibular Plane Angle", "Jaw Width Ratio", "Bigonial Width"],
      threshold: 8.0
    },
    content: {
      description: "The jaw displays strong definition with well-defined angles and proportionate width.",
      grade_labels: { good: "Defined", excellent: "Strong", ideal: "Ideal Angular" }
    }
  },
  {
    id: "refined_nasal_tip",
    title: "Refined Nasal Tip",
    type: "strength",
    severity_logic: {
      metrics: ["Nasal Tip Angle", "Nose Tip Position", "Frankfort-tip Angle"],
      threshold: 8.5
    },
    content: {
      description: "This contributes to a harmonious nasal profile due to the nasal tip being well-defined and proportionate.",
      grade_labels: { good: "Good", excellent: "Excellent", ideal: "Ideal" }
    }
  },
  {
    id: "bulbous_nose",
    title: "Bulbous Nasal Tip",
    type: "weakness",
    severity_logic: {
      metrics: ["Nasal Index", "Nose Width", "Nasal Tip Angle"],
      threshold: 5.5
    },
    content: {
      description: "The nasal tip appears rounded and less defined, affecting nasal aesthetics.",
      severity_labels: { minor: "Slightly Rounded", moderate: "Rounded", severe: "Bulbous" }
    }
  },
  {
    id: "ideal_upper_lip",
    title: "Well-Positioned Upper Lip",
    type: "strength",
    severity_logic: {
      metrics: ["Upper Lip E-Line Position", "Upper Lip S-Line Position", "Nasolabial Angle"],
      threshold: 9.0
    },
    content: {
      description: "This contributes to a harmonious mouth region due to the upper lip sitting neither too far forward nor too far back.",
      grade_labels: { good: "Good", excellent: "Excellent", ideal: "Ideal" }
    }
  },
  {
    id: "negative_canthal_tilt",
    title: "Negative Canthal Tilt",
    type: "weakness",
    severity_logic: {
      metrics: ["Lateral Canthal Tilt", "Eye Aspect Ratio"],
      threshold: 5.0
    },
    content: {
      description: "The outer corners of the eyes sit lower than the inner corners, creating a downturned appearance.",
      severity_labels: { minor: "Slight Downturn", moderate: "Noticeable", severe: "Pronounced" }
    }
  },
  {
    id: "positive_canthal_tilt",
    title: "Positive Canthal Tilt",
    type: "strength",
    severity_logic: {
      metrics: ["Lateral Canthal Tilt", "Eye Aspect Ratio"],
      threshold: 8.0
    },
    content: {
      description: "The outer corners of the eyes are elevated, creating an attractive upswept eye shape.",
      grade_labels: { good: "Slight Upturn", excellent: "Well-Tilted", ideal: "Hunter Eyes" }
    }
  },
  {
    id: "balanced_facial_thirds",
    title: "Balanced Facial Thirds",
    type: "strength",
    severity_logic: {
      metrics: ["Upper Third Proportion", "Middle Third Proportion", "Lower Third Proportion"],
      threshold: 8.5
    },
    content: {
      description: "The face displays well-balanced vertical proportions across all three facial thirds.",
      grade_labels: { good: "Balanced", excellent: "Harmonious", ideal: "Perfectly Proportioned" }
    }
  },
  {
    id: "imbalanced_thirds",
    title: "Facial Third Imbalance",
    type: "weakness",
    severity_logic: {
      metrics: ["Upper Third Proportion", "Middle Third Proportion", "Lower Third Proportion"],
      threshold: 5.5
    },
    content: {
      description: "The vertical face proportions show imbalance between the three facial thirds.",
      severity_labels: { minor: "Slight Imbalance", moderate: "Noticeable Disproportion", severe: "Significant Imbalance" }
    }
  },
  {
    id: "high_cheekbones",
    title: "High Cheekbones",
    type: "strength",
    severity_logic: {
      metrics: ["Cheekbone Height", "Cheekbone Width", "Midface Ratio"],
      threshold: 8.5
    },
    content: {
      description: "Well-positioned cheekbones that create attractive facial contours and catch light beautifully.",
      grade_labels: { good: "Visible", excellent: "Prominent", ideal: "Model-Tier" }
    }
  },
  {
    id: "flat_midface",
    title: "Flat Midface",
    type: "weakness",
    severity_logic: {
      metrics: ["Cheekbone Height", "Midface Ratio", "Total Facial Width to Height"],
      threshold: 5.0
    },
    content: {
      description: "The midface lacks forward projection, resulting in flatter facial contours.",
      severity_labels: { minor: "Slightly Flat", moderate: "Underprojected", severe: "Recessed" }
    }
  },
  {
    id: "ideal_lip_ratio",
    title: "Ideal Lip Proportions",
    type: "strength",
    severity_logic: {
      metrics: ["Lip Ratio", "Philtrum Length", "Lip Chin Distance"],
      threshold: 8.5
    },
    content: {
      description: "The lips demonstrate excellent proportions with balanced upper-to-lower lip ratio.",
      grade_labels: { good: "Balanced", excellent: "Well-Proportioned", ideal: "Perfect Ratio" }
    }
  },
  {
    id: "thin_lips",
    title: "Thin Lip Profile",
    type: "weakness",
    severity_logic: {
      metrics: ["Lip Ratio", "Upper Lip Projection", "Lower Lip Projection"],
      threshold: 5.0
    },
    content: {
      description: "The lips appear thinner than ideal proportions, affecting lower face harmony.",
      severity_labels: { minor: "Slightly Thin", moderate: "Thin", severe: "Very Thin" }
    }
  },
  {
    id: "ideal_ipd",
    title: "Ideal Eye Spacing",
    type: "strength",
    severity_logic: {
      metrics: ["Interpupillary Ratio", "Eye Separation Ratio", "One Eye Apart Test"],
      threshold: 8.5
    },
    content: {
      description: "The eyes are ideally spaced, creating facial balance and attractiveness.",
      grade_labels: { good: "Good Spacing", excellent: "Ideal Distance", ideal: "Perfect IPD" }
    }
  },
  {
    id: "wide_set_eyes",
    title: "Wide-Set Eyes",
    type: "weakness",
    severity_logic: {
      metrics: ["Interpupillary Ratio", "Eye Separation Ratio", "One Eye Apart Test"],
      threshold: 5.5
    },
    content: {
      description: "The eyes are spaced wider apart than the aesthetic ideal.",
      severity_labels: { minor: "Slightly Wide", moderate: "Noticeably Wide", severe: "Very Wide" }
    }
  },
  {
    id: "close_set_eyes",
    title: "Close-Set Eyes",
    type: "weakness",
    severity_logic: {
      metrics: ["Interpupillary Ratio", "Eye Separation Ratio", "Intercanthal Width"],
      threshold: 5.5
    },
    content: {
      description: "The eyes are positioned closer together than the aesthetic ideal.",
      severity_labels: { minor: "Slightly Close", moderate: "Noticeably Close", severe: "Very Close" }
    }
  },
  {
    id: "ideal_nose_projection",
    title: "Ideal Nasal Projection",
    type: "strength",
    severity_logic: {
      metrics: ["Nasofrontal Angle", "Nasofacial Angle", "Nasomenta Angle"],
      threshold: 8.5
    },
    content: {
      description: "The nose has ideal forward projection relative to the face, creating profile harmony.",
      grade_labels: { good: "Good", excellent: "Well-Projected", ideal: "Perfect Projection" }
    }
  },
  {
    id: "recessed_chin",
    title: "Recessed Chin",
    type: "weakness",
    severity_logic: {
      metrics: ["Chin to Philtrum Ratio", "Chin Height", "Facial Depth to Height"],
      threshold: 5.0
    },
    content: {
      description: "The chin sits behind the ideal position, affecting profile balance.",
      severity_labels: { minor: "Slightly Recessed", moderate: "Recessed", severe: "Severely Recessed" }
    }
  },
  {
    id: "ideal_chin_projection",
    title: "Ideal Chin Projection",
    type: "strength",
    severity_logic: {
      metrics: ["Chin to Philtrum Ratio", "Chin Height", "Anterior Facial Depth"],
      threshold: 8.5
    },
    content: {
      description: "The chin demonstrates ideal projection and proportions relative to the face.",
      grade_labels: { good: "Good", excellent: "Well-Projected", ideal: "Perfect" }
    }
  },
  {
    id: "long_philtrum",
    title: "Long Philtrum",
    type: "weakness",
    severity_logic: {
      metrics: ["Philtrum Length", "Lip Chin Distance", "Upper Lip Height"],
      threshold: 5.5
    },
    content: {
      description: "The distance between nose and upper lip is longer than ideal.",
      severity_labels: { minor: "Slightly Long", moderate: "Long", severe: "Very Long" }
    }
  },
  {
    id: "short_philtrum",
    title: "Short Philtrum",
    type: "strength",
    severity_logic: {
      metrics: ["Philtrum Length", "Upper Lip Height"],
      threshold: 8.0
    },
    content: {
      description: "The philtrum has ideal or shorter length, considered youthful and attractive.",
      grade_labels: { good: "Good Length", excellent: "Short", ideal: "Ideal" }
    }
  },
  {
    id: "wide_nose",
    title: "Wide Nasal Base",
    type: "weakness",
    severity_logic: {
      metrics: ["Nasal Index", "Intercanthal Nasal Ratio", "Nose Bridge Width"],
      threshold: 5.0
    },
    content: {
      description: "The base of the nose is wider than the aesthetic ideal for facial harmony.",
      severity_labels: { minor: "Slightly Wide", moderate: "Wide", severe: "Very Wide" }
    }
  },
  {
    id: "ideal_brow_position",
    title: "Ideal Brow Position",
    type: "strength",
    severity_logic: {
      metrics: ["Eyebrow Height", "Brow Length Ratio"],
      threshold: 8.0
    },
    content: {
      description: "The eyebrows are ideally positioned relative to the eyes and facial structure.",
      grade_labels: { good: "Good Position", excellent: "Well-Arched", ideal: "Perfect Frame" }
    }
  },
  {
    id: "narrow_jaw",
    title: "Narrow Jaw",
    type: "weakness",
    severity_logic: {
      metrics: ["Jaw Width Ratio", "Bigonial Width", "Jaw Frontal Angle"],
      threshold: 5.0
    },
    content: {
      description: "The jaw is narrower than ideal, affecting lower face width and definition.",
      severity_labels: { minor: "Slightly Narrow", moderate: "Narrow", severe: "Very Narrow" }
    }
  },
  {
    id: "steep_mandibular_plane",
    title: "Steep Mandibular Plane",
    type: "weakness",
    severity_logic: {
      metrics: ["Mandibular Plane Angle", "Gonial Angle", "Lower Third Proportion"],
      threshold: 5.0
    },
    content: {
      description: "The mandibular plane angle is steeper than ideal, often indicating vertical growth pattern.",
      severity_labels: { minor: "Slightly Steep", moderate: "Steep", severe: "Very Steep" }
    }
  },
  // ============================================
  // SCRAPED FROM FACEIQ (element.html / element1.html)
  // ============================================
  // --- WEAKNESSES ---
  {
    id: "steep_jaw",
    title: "Steep Jaw",
    type: "weakness",
    severity_logic: {
      metrics: ["Mandibular Plane Angle", "Gonial Angle", "Jaw Frontal Angle"],
      threshold: 6.0
    },
    content: {
      description: "The jaw angles sharply downward, creating a narrow or pointed chin effect.",
      severity_labels: { minor: "Slightly Steep", moderate: "Steep", severe: "Very Steep" }
    }
  },
  {
    id: "maxillary_recession",
    title: "Maxillary Recession",
    type: "weakness",
    severity_logic: {
      metrics: ["Nasofacial Angle", "Nasomental Angle", "Facial Depth to Height Ratio"],
      threshold: 6.0
    },
    content: {
      description: "The upper jaw is less forward than ideal, reducing midface projection and facial harmony.",
      severity_labels: { minor: "Slight Recession", moderate: "Noticeable Recession", severe: "Severe Recession" }
    }
  },
  {
    id: "mandibular_recession",
    title: "Mandibular Recession",
    type: "weakness",
    severity_logic: {
      metrics: ["Recession Relative to Frankfort Plane", "Chin to Philtrum Ratio"],
      threshold: 6.0
    },
    content: {
      description: "The lower jaw is set back, creating a less prominent chin and an unbalanced profile.",
      severity_labels: { minor: "Slight Recession", moderate: "Noticeable Recession", severe: "Severe Recession" }
    }
  },
  {
    id: "underprojected_chin",
    title: "Underprojected Chin",
    type: "weakness",
    severity_logic: {
      metrics: ["Recession Relative to Frankfort Plane", "Chin to Philtrum Ratio", "Chin Height"],
      threshold: 6.0
    },
    content: {
      description: "The chin lacks forward projection, creating a weak lower face appearance.",
      severity_labels: { minor: "Slightly Weak", moderate: "Underprojected", severe: "Severely Underprojected" }
    }
  },
  {
    id: "overly_long_face",
    title: "Overly Long Face Shape",
    type: "weakness",
    severity_logic: {
      metrics: ["Total Facial Width to Height Ratio", "Face Width to Height Ratio"],
      threshold: 6.0
    },
    content: {
      description: "The face is excessively tall and narrow, creating an elongated appearance.",
      severity_labels: { minor: "Slightly Long", moderate: "Long", severe: "Very Long" }
    }
  },
  {
    id: "hyper_divergent_jaw",
    title: "Hyper-Divergent Jaw Growth",
    type: "weakness",
    severity_logic: {
      metrics: ["Mandibular Plane Angle", "Gonial Angle", "Lower Third Proportion"],
      threshold: 5.5
    },
    content: {
      description: "The jaw grows with an overly steep angle, resulting in a long or narrow lower face. This can indicate malocclusion.",
      severity_labels: { minor: "Mildly Divergent", moderate: "Divergent", severe: "Hyper-Divergent" }
    }
  },
  {
    id: "weak_brow_ridge",
    title: "Soft/Weak Brow Ridge",
    type: "weakness",
    severity_logic: {
      metrics: ["Browridge Inclination Angle", "Eyebrow Height"],
      threshold: 5.5
    },
    content: {
      description: "The forehead has a softer, less prominent ridge than the ideal, reducing masculine definition.",
      severity_labels: { minor: "Slightly Soft", moderate: "Soft", severe: "Very Weak" }
    }
  },
  {
    id: "droopy_nasal_tip",
    title: "Droopy Nasal Tip",
    type: "weakness",
    severity_logic: {
      metrics: ["Nasolabial Angle", "Nasal Tip Angle", "Nasofacial Angle"],
      threshold: 5.5
    },
    content: {
      description: "The nasal tip points downward more than ideal, creating a drooping appearance.",
      severity_labels: { minor: "Slightly Droopy", moderate: "Droopy", severe: "Very Droopy" }
    }
  },
  {
    id: "overprojected_nose",
    title: "Overprojected Nose",
    type: "weakness",
    severity_logic: {
      metrics: ["Nasal Projection", "Nasofacial Angle", "Nose Length Ratio"],
      threshold: 5.5
    },
    content: {
      description: "The nose projects too far forward relative to the face, creating imbalance.",
      severity_labels: { minor: "Slightly Projected", moderate: "Overprojected", severe: "Very Overprojected" }
    }
  },
  {
    id: "small_eyes",
    title: "Small Eyes",
    type: "weakness",
    severity_logic: {
      metrics: ["Eye Aspect Ratio", "Palpebral Fissure Length", "Eye Width"],
      threshold: 5.5
    },
    content: {
      description: "The eyes appear smaller than the aesthetic ideal relative to the face.",
      severity_labels: { minor: "Slightly Small", moderate: "Small", severe: "Very Small" }
    }
  },
  {
    id: "low_set_eyebrows",
    title: "Low-Set Eyebrows",
    type: "weakness",
    severity_logic: {
      metrics: ["Eyebrow Height", "Brow to Hairline Distance"],
      threshold: 5.5
    },
    content: {
      description: "The eyebrows sit lower than ideal, reducing the visible upper eyelid space.",
      severity_labels: { minor: "Slightly Low", moderate: "Low", severe: "Very Low" }
    }
  },
  {
    id: "asymmetrical_face",
    title: "Facial Asymmetry",
    type: "weakness",
    severity_logic: {
      metrics: ["Facial Asymmetry Index", "Eye Asymmetry", "Jaw Asymmetry"],
      threshold: 5.5
    },
    content: {
      description: "The left and right sides of the face show noticeable differences in proportion or position.",
      severity_labels: { minor: "Slight Asymmetry", moderate: "Noticeable Asymmetry", severe: "Significant Asymmetry" }
    }
  },
  // --- STRENGTHS ---
  {
    id: "good_jaw_width",
    title: "Good Jaw Width",
    type: "strength",
    severity_logic: {
      metrics: ["Bigonial Width", "Jaw Width Ratio", "Jaw Frontal Angle"],
      threshold: 8.5
    },
    content: {
      description: "This contributes to a pleasant jaw contour due to the jaw being neither too wide nor too narrow.",
      grade_labels: { good: "Good Width", excellent: "Well-Proportioned", ideal: "Ideal Width" }
    }
  },
  {
    id: "good_forehead_slope",
    title: "Good Forehead Slope",
    type: "strength",
    severity_logic: {
      metrics: ["Browridge Inclination Angle", "Forehead Height"],
      threshold: 8.5
    },
    content: {
      description: "This contributes to a pleasant forehead contour by indicating that the forehead is neither too steep nor too flat.",
      grade_labels: { good: "Good Slope", excellent: "Well-Angled", ideal: "Ideal Slope" }
    }
  },
  {
    id: "good_cupids_bow",
    title: "Good Cupid's Bow Depth",
    type: "strength",
    severity_logic: {
      metrics: ["Cupids Bow Depth", "Upper Lip Height"],
      threshold: 8.5
    },
    content: {
      description: "This contributes to a harmonious lip region due to the cupid's bow having ideal definition and depth.",
      grade_labels: { good: "Defined", excellent: "Well-Defined", ideal: "Perfectly Defined" }
    }
  },
  {
    id: "good_eyebrow_length",
    title: "Good Eyebrow Length",
    type: "strength",
    severity_logic: {
      metrics: ["Brow Length to Face Width Ratio", "Brow Length Ratio"],
      threshold: 8.5
    },
    content: {
      description: "This contributes to a harmonious eye region due to the eyebrows having ideal horizontal length relative to face width.",
      grade_labels: { good: "Good Length", excellent: "Well-Proportioned", ideal: "Ideal Length" }
    }
  },
  {
    id: "good_neck_width",
    title: "Good Neck Width",
    type: "strength",
    severity_logic: {
      metrics: ["Neck Width", "Neck to Jaw Ratio"],
      threshold: 8.5
    },
    content: {
      description: "This contributes to a harmonious lower face due to the neck being neither too wide nor too thin.",
      grade_labels: { good: "Good Width", excellent: "Well-Proportioned", ideal: "Ideal Width" }
    }
  },
  {
    id: "ideal_nasolabial_angle",
    title: "Ideal Nasolabial Angle",
    type: "strength",
    severity_logic: {
      metrics: ["Nasolabial Angle", "Nasal Tip Angle"],
      threshold: 8.5
    },
    content: {
      description: "The angle between nose and upper lip is in the ideal range, creating profile harmony.",
      grade_labels: { good: "Good Angle", excellent: "Well-Angled", ideal: "Perfect Angle" }
    }
  },
  {
    id: "ideal_facial_depth",
    title: "Ideal Facial Depth",
    type: "strength",
    severity_logic: {
      metrics: ["Facial Depth to Height Ratio", "Anterior Facial Depth"],
      threshold: 8.5
    },
    content: {
      description: "The face has ideal forward projection creating attractive three-dimensional contours.",
      grade_labels: { good: "Good Depth", excellent: "Well-Projected", ideal: "Ideal Projection" }
    }
  },
  {
    id: "ideal_eye_shape",
    title: "Ideal Eye Shape",
    type: "strength",
    severity_logic: {
      metrics: ["Eye Aspect Ratio", "Lateral Canthal Tilt", "Palpebral Fissure Length"],
      threshold: 8.5
    },
    content: {
      description: "The eyes have an attractive almond shape with ideal proportions and tilt.",
      grade_labels: { good: "Attractive", excellent: "Well-Shaped", ideal: "Hunter Eyes" }
    }
  },
  {
    id: "harmonious_profile",
    title: "Harmonious Profile",
    type: "strength",
    severity_logic: {
      metrics: ["Nasofacial Angle", "Nasomental Angle", "Total Profile Angle"],
      threshold: 8.5
    },
    content: {
      description: "The facial profile shows excellent balance between nose, lips, and chin positions.",
      grade_labels: { good: "Balanced", excellent: "Harmonious", ideal: "Perfect Profile" }
    }
  },
  {
    id: "good_facial_symmetry",
    title: "Good Facial Symmetry",
    type: "strength",
    severity_logic: {
      metrics: ["Facial Asymmetry Index", "Eye Asymmetry", "Jaw Asymmetry"],
      threshold: 8.5
    },
    content: {
      description: "The face displays excellent bilateral symmetry, a key component of attractiveness.",
      grade_labels: { good: "Symmetric", excellent: "Very Symmetric", ideal: "Near-Perfect Symmetry" }
    }
  }
];

// ============================================
// METRIC NAME MAPPING
// ============================================

// Map display names to metric IDs for lookup
const METRIC_NAME_TO_ID: Record<string, string> = {
  // Face Shape/Proportions
  "Face Width to Height Ratio": "faceWidthToHeight",
  "Total Facial Width to Height": "totalFacialWidthToHeight",
  "Total Facial Width to Height Ratio": "totalFacialWidthToHeight",
  "Midface Ratio": "midfaceRatio",
  "Upper Third Proportion": "upperThirdProportion",
  "Middle Third Proportion": "middleThirdProportion",
  "Lower Third Proportion": "lowerThirdProportion",
  "Cheekbone Height": "cheekboneHeight",
  "Cheekbone Width": "cheekboneWidth",
  "Bitemporal Width": "bitemporalWidth",
  "Forehead Height": "foreheadHeight",
  "Facial Asymmetry Index": "facialAsymmetryIndex",

  // Jaw
  "Gonial Angle": "gonialAngle",
  "Mandibular Plane Angle": "mandibularPlaneAngle",
  "Jaw Width Ratio": "jawWidthRatio",
  "Bigonial Width": "bigonialWidth",
  "Jaw Frontal Angle": "jawFrontalAngle",
  "Jaw Slope": "jawSlope",
  "Jaw Asymmetry": "jawAsymmetry",

  // Chin
  "Chin to Philtrum Ratio": "chinPhiltrumRatio",
  "Chin Height": "chinHeight",
  "Facial Depth to Height": "facialDepthToHeight",
  "Facial Depth to Height Ratio": "facialDepthToHeight",
  "Anterior Facial Depth": "anteriorFacialDepth",
  "Recession Relative to Frankfort Plane": "recessionFrankfort",

  // Eyes
  "Lateral Canthal Tilt": "lateralCanthalTilt",
  "Eye Aspect Ratio": "eyeAspectRatio",
  "Eye Separation Ratio": "eyeSeparationRatio",
  "Interpupillary Ratio": "interpupillaryRatio",
  "One Eye Apart Test": "oneEyeApartTest",
  "Intercanthal Width": "intercanthalWidth",
  "Eyebrow Height": "eyebrowHeight",
  "Brow Length Ratio": "browLengthRatio",
  "Brow Length to Face Width Ratio": "browLengthToFaceWidth",
  "Palpebral Fissure Length": "palpebralFissureLength",
  "Eye Width": "eyeWidth",
  "Eye Asymmetry": "eyeAsymmetry",
  "Brow to Hairline Distance": "browToHairlineDistance",

  // Brow
  "Browridge Inclination Angle": "browridgeInclinationAngle",

  // Nose
  "Nasal Index": "nasalIndex",
  "Nasal Tip Angle": "nasalTipAngle",
  "Nose Tip Position": "noseTipPosition",
  "Frankfort-tip Angle": "frankfortTipAngle",
  "Nasofrontal Angle": "nasofrontalAngle",
  "Nasofacial Angle": "nasofacialAngle",
  "Nasomenta Angle": "nasomentaAngle",
  "Nasomental Angle": "nasomentaAngle",
  "Intercanthal Nasal Ratio": "intercanthalNasalRatio",
  "Nose Bridge Width": "noseBridgeWidth",
  "Nose Width": "noseWidth",
  "Nasal Projection": "nasalProjection",
  "Nose Length Ratio": "noseLengthRatio",
  "Ipsilateral Alar Angle": "ipsilateralAlarAngle",

  // Lips
  "Lip Ratio": "lipRatio",
  "Philtrum Length": "philtrumLength",
  "Upper Lip Projection": "upperLipProjection",
  "Lower Lip Projection": "lowerLipProjection",
  "Lip Chin Distance": "lipChinDistance",
  "Upper Lip Height": "upperLipHeight",
  "Upper Lip E-Line Position": "upperLipELine",
  "Upper Lip S-Line Position": "upperLipSLine",
  "Nasolabial Angle": "nasolabialAngle",
  "Cupids Bow Depth": "cupidsBowDepth",

  // Neck
  "Neck Width": "neckWidth",
  "Neck to Jaw Ratio": "neckToJawRatio",

  // Profile
  "Total Profile Angle": "totalProfileAngle",
};

// ============================================
// CLASSIFICATION FUNCTIONS
// ============================================

/**
 * Get weakness severity based on average score
 * 0-3 = "Severe", 3-5 = "Moderate", 5-7 = "Minor"
 */
function getWeaknessSeverity(avgScore: number): WeaknessSeverity {
  if (avgScore <= 3) return 'severe';
  if (avgScore <= 5) return 'moderate';
  return 'minor';
}

/**
 * Get strength grade based on average score
 * 8-9 = "Good", 9-9.5 = "Excellent", 9.5-10 = "Ideal"
 */
function getStrengthGrade(avgScore: number): StrengthGrade {
  if (avgScore >= 9.5) return 'ideal';
  if (avgScore >= 9) return 'excellent';
  return 'good';
}

/**
 * Find metric by display name from measurements array
 */
function findMetricByName(
  metricName: string,
  measurements: FaceIQScoreResult[]
): FaceIQScoreResult | undefined {
  // First try direct ID mapping
  const metricId = METRIC_NAME_TO_ID[metricName];
  if (metricId) {
    return measurements.find(m => m.metricId === metricId);
  }

  // Fallback: try fuzzy matching on name
  const normalizedName = metricName.toLowerCase().replace(/[^a-z0-9]/g, '');
  return measurements.find(m => {
    const normalizedMetricName = m.name.toLowerCase().replace(/[^a-z0-9]/g, '');
    return normalizedMetricName.includes(normalizedName) ||
           normalizedName.includes(normalizedMetricName);
  });
}

/**
 * Check if a metric should be considered a "false positive" weakness.
 * This handles directional/dimorphic metrics where low scores don't mean weakness.
 *
 * Example: Canthal Tilt of 3° gets a low score (not in 6-8° ideal range)
 * but is still a POSITIVE trait, not a weakness.
 */
function isFalsePositiveWeakness(metric: MatchedMetric): boolean {
  const config = FACEIQ_METRICS[metric.metricId];
  if (!config) return false;

  // Check if the value is actually acceptable based on polarity
  const { acceptable } = isValueAcceptable(metric.value, config);
  return acceptable;
}

/**
 * Process all insight definitions against user's measurements
 */
export function classifyInsights(
  measurements: FaceIQScoreResult[],
  insightDefinitions: InsightDefinition[] = INSIGHTS_DEFINITIONS
): InsightClassificationResult {
  const strengths: ClassifiedStrength[] = [];
  const weaknesses: ClassifiedWeakness[] = [];

  for (const insight of insightDefinitions) {
    const { metrics, threshold } = insight.severity_logic;

    // Find matching measurements for this insight
    const matchedMetrics: MatchedMetric[] = [];
    for (const metricName of metrics) {
      const measurement = findMetricByName(metricName, measurements);
      if (measurement) {
        matchedMetrics.push({
          metricId: measurement.metricId,
          metricName: measurement.name,
          score: measurement.score,
          value: measurement.value,
          idealMin: measurement.idealMin,
          idealMax: measurement.idealMax,
          unit: measurement.unit,
          category: measurement.category,
        });
      }
    }

    // Skip if no metrics matched (need at least 1)
    if (matchedMetrics.length === 0) continue;

    // Calculate average score
    const avgScore = matchedMetrics.reduce((sum, m) => sum + m.score, 0) / matchedMetrics.length;

    // Classify based on type and threshold
    if (insight.type === 'weakness') {
      // Weakness: avg < threshold → add to areas of improvement
      if (avgScore < threshold) {
        // ========== FALSE POSITIVE CHECK ==========
        // Before adding to weaknesses, check if ANY of the matched metrics
        // are actually in an "acceptable" zone based on their polarity.
        // If so, this is a false positive and should be skipped or reclassified.
        const falsePositiveMetrics = matchedMetrics.filter(isFalsePositiveWeakness);

        // If ALL matched metrics are false positives, skip this weakness entirely
        if (falsePositiveMetrics.length === matchedMetrics.length) {
          // This is a false positive weakness - the values are actually acceptable
          // Consider adding to strengths if scores are decent
          if (avgScore >= 6) {
            strengths.push({
              insightId: `${insight.id}_acceptable`,
              title: insight.title.replace('Negative', 'Neutral').replace('Weak', 'Moderate'),
              description: `While not in the peak ideal range, the measured values are within acceptable limits.`,
              grade: 'good',
              gradeLabel: 'Acceptable',
              avgScore,
              matchedMetrics,
            });
          }
          continue; // Skip adding as weakness
        }

        // If SOME metrics are false positives, filter them out
        const trueWeaknessMetrics = matchedMetrics.filter(m => !isFalsePositiveWeakness(m));
        if (trueWeaknessMetrics.length === 0) continue;

        // Recalculate average with only true weakness metrics
        const trueAvgScore = trueWeaknessMetrics.reduce((sum, m) => sum + m.score, 0) / trueWeaknessMetrics.length;

        // Only add as weakness if true average is still below threshold
        if (trueAvgScore < threshold) {
          const severity = getWeaknessSeverity(trueAvgScore);
          const labels = insight.content.severity_labels;
          const severityLabel = labels?.[severity] || severity;

          weaknesses.push({
            insightId: insight.id,
            title: insight.title,
            description: insight.content.description,
            severity,
            severityLabel,
            avgScore: trueAvgScore,
            matchedMetrics: trueWeaknessMetrics,
          });
        }
      }
    } else {
      // Strength: avg > threshold → add to key strengths
      if (avgScore > threshold) {
        const grade = getStrengthGrade(avgScore);
        const labels = insight.content.grade_labels;
        const gradeLabel = labels?.[grade] || grade;

        strengths.push({
          insightId: insight.id,
          title: insight.title,
          description: insight.content.description,
          grade,
          gradeLabel,
          avgScore,
          matchedMetrics,
        });
      }
    }
  }

  // Sort by score (weaknesses by lowest score first, strengths by highest first)
  weaknesses.sort((a, b) => a.avgScore - b.avgScore);
  strengths.sort((a, b) => b.avgScore - a.avgScore);

  return { strengths, weaknesses };
}

/**
 * Convert ClassifiedStrength to Strength type for UI compatibility
 */
export function convertToStrength(classified: ClassifiedStrength): Strength {
  return {
    id: `insight_strength_${classified.insightId}`,
    strengthName: `${classified.title} (${classified.gradeLabel})`,
    summary: classified.description,
    avgScore: classified.avgScore,
    qualityLevel: classified.grade === 'ideal' ? 'ideal' :
                  classified.grade === 'excellent' ? 'excellent' : 'good',
    categoryName: classified.matchedMetrics[0]?.category || 'General',
    responsibleRatios: classified.matchedMetrics.map(m => ({
      ratioName: m.metricName,
      ratioId: m.metricId,
      score: m.score,
      value: m.value,
      idealMin: m.idealMin,
      idealMax: m.idealMax,
      unit: m.unit,
      category: m.category,
    })),
  };
}

/**
 * Convert ClassifiedWeakness to Flaw type for UI compatibility
 */
export function convertToFlaw(classified: ClassifiedWeakness, index: number, rollingLost: number): Flaw {
  const impact = (10 - classified.avgScore) * 0.5;
  const newRollingLost = rollingLost + impact;

  return {
    id: `insight_flaw_${classified.insightId}`,
    flawName: `${classified.title} (${classified.severityLabel})`,
    summary: classified.description,
    harmonyPercentageLost: impact,
    standardizedImpact: impact / 10,
    categoryName: classified.matchedMetrics[0]?.category || 'General',
    responsibleRatios: classified.matchedMetrics.map(m => ({
      ratioName: m.metricName,
      ratioId: m.metricId,
      score: m.score,
      value: m.value,
      idealMin: m.idealMin,
      idealMax: m.idealMax,
      unit: m.unit,
      category: m.category,
    })),
    rollingPointsDeducted: newRollingLost,
    rollingHarmonyPercentageLost: newRollingLost,
    rollingStandardizedImpact: newRollingLost / 10,
  };
}

/**
 * Main function: Generate strengths and flaws from measurements using insights
 */
export function generateInsightBasedResults(
  measurements: FaceIQScoreResult[]
): { strengths: Strength[]; flaws: Flaw[] } {
  const { strengths: classifiedStrengths, weaknesses: classifiedWeaknesses } = classifyInsights(measurements);

  // Convert to UI-compatible types
  const strengths = classifiedStrengths.map((s) => convertToStrength(s));

  let rollingLost = 0;
  const flaws = classifiedWeaknesses.map((w, i) => {
    const flaw = convertToFlaw(w, i, rollingLost);
    rollingLost = flaw.rollingPointsDeducted || 0;
    return flaw;
  });

  return { strengths, flaws };
}
