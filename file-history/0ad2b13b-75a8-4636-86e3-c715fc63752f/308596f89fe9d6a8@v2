/**
 * AI-Generated Descriptions for Facial Metrics
 * Generates personalized explanations based on actual values vs ideal ranges
 */

import { SeverityLevel } from '@/lib/faceiq-scoring';

// ============================================
// TYPES
// ============================================

export interface MetricDescription {
  reasoning: string;
  impact: string;
  recommendation?: string;
}

export interface FlawDetail {
  category: string;
  flawName: string;
  confidence: 'confirmed' | 'likely' | 'possible';
  actualValue: string;
  idealRange: string;
  deviation: string;
  deviationPercent: number;
  score: number;
  severity: SeverityLevel;
  reasoning: string;
}

// ============================================
// DEVIATION CALCULATION
// ============================================

export function calculateDeviation(
  value: number,
  idealMin: number,
  idealMax: number,
  unit: string
): { deviation: string; percent: number; direction: 'above' | 'below' | 'within' } {
  const idealRange = idealMax - idealMin;

  if (value >= idealMin && value <= idealMax) {
    return { deviation: 'Within ideal range', percent: 0, direction: 'within' };
  }

  if (value < idealMin) {
    const diff = idealMin - value;
    const percent = (diff / idealRange) * 100;
    const unitSymbol = unit === 'percent' ? '%' : unit === 'degrees' ? '°' : unit === 'mm' ? 'mm' : '';
    return {
      deviation: `${diff.toFixed(2)}${unitSymbol} below ideal`,
      percent: Math.min(percent, 200),
      direction: 'below',
    };
  }

  const diff = value - idealMax;
  const percent = (diff / idealRange) * 100;
  const unitSymbol = unit === 'percent' ? '%' : unit === 'degrees' ? '°' : unit === 'mm' ? 'mm' : '';
  return {
    deviation: `${diff.toFixed(2)}${unitSymbol} above ideal`,
    percent: Math.min(percent, 200),
    direction: 'above',
  };
}

export function getSeverityFromScore(score: number): SeverityLevel {
  if (score >= 9) return 'optimal';
  if (score >= 7.5) return 'minor';
  if (score >= 6) return 'moderate';
  if (score >= 4) return 'major';
  if (score >= 2) return 'severe';
  return 'extremely_severe';
}

export function getConfidenceFromScore(score: number): 'confirmed' | 'likely' | 'possible' {
  if (score < 4) return 'confirmed';
  if (score < 6) return 'likely';
  return 'possible';
}

// ============================================
// METRIC-SPECIFIC DESCRIPTIONS
// ============================================

interface DescriptionTemplate {
  low: string;
  high: string;
  ideal: string;
  impact: {
    low: string;
    high: string;
  };
  flawNames: {
    low: string[];
    high: string[];
  };
}

const METRIC_DESCRIPTIONS: Record<string, DescriptionTemplate> = {
  // FACE SHAPE
  faceWidthToHeight: {
    low: 'Your face appears narrower relative to its height, creating a more elongated vertical appearance. This can reduce perceived facial harmony and may affect how balanced your features appear.',
    high: 'Your face is wider relative to its height, creating a more horizontally expanded appearance. While this can convey strength, extreme values may reduce overall facial balance.',
    ideal: 'Your facial width-to-height ratio falls within the ideal range, contributing to a balanced and harmonious facial appearance.',
    impact: {
      low: 'A narrow face can make the midface appear longer and may reduce perceived masculinity in males.',
      high: 'A wider face can appear less refined and may create imbalance with other features.',
    },
    flawNames: {
      low: ['Narrow face', 'Vertically elongated face', 'Long face syndrome'],
      high: ['Wide face', 'Horizontally expanded face', 'Facial width excess'],
    },
  },

  lowerThirdProportion: {
    low: 'Your lower third (chin to base of nose) is shorter than ideal, which can make the midface appear longer and reduce jaw prominence.',
    high: 'Your lower third is longer than ideal, indicating possible hyper-divergent growth pattern. This elongates the lower face and can disrupt vertical facial harmony.',
    ideal: 'Your lower third proportion is well-balanced, contributing to harmonious vertical facial thirds.',
    impact: {
      low: 'A short lower third can indicate underdevelopment of the mandible or a recessed chin position.',
      high: 'A long lower third often indicates vertical maxillary excess or hyper-divergent jaw growth, which can significantly impact facial aesthetics.',
    },
    flawNames: {
      low: ['Short lower third', 'Deficient mandible', 'Vertical deficiency'],
      high: ['Long lower third', 'Hyper-divergent jaw growth', 'Vertical maxillary excess'],
    },
  },

  middleThirdProportion: {
    low: 'Your middle third (nose to brow) is shorter than ideal, which can make the upper face appear more dominant.',
    high: 'Your middle third is longer than ideal, which can create an elongated midface appearance and reduce harmony.',
    ideal: 'Your middle third proportion is balanced, contributing to proper vertical facial harmony.',
    impact: {
      low: 'A short midface can make the nose appear relatively larger and affect eye positioning perception.',
      high: 'A long midface can create a tired or aged appearance and affect overall facial balance.',
    },
    flawNames: {
      low: ['Short midface', 'Compressed middle third'],
      high: ['Long midface', 'Elongated middle third', 'Midface excess'],
    },
  },

  lateralCanthalTilt: {
    low: 'Your lateral canthal tilt is negative or insufficient, meaning your outer eye corners sit at or below the inner corners. This creates a downward-sloping eye appearance.',
    high: 'Your lateral canthal tilt is excessive, with outer corners significantly higher than inner corners. While some positive tilt is ideal, extreme values can appear unnatural.',
    ideal: 'Your lateral canthal tilt is within the ideal positive range, contributing to an alert and youthful eye appearance.',
    impact: {
      low: 'Negative canthal tilt can create a tired, sad, or aged appearance and is one of the most impactful eye metrics.',
      high: 'Excessive canthal tilt can appear unnatural or create asymmetric eye appearance.',
    },
    flawNames: {
      low: ['Negative canthal tilt', 'Drooping eyes', 'Downward-sloping palpebral fissure'],
      high: ['Excessive positive tilt', 'Over-tilted eyes'],
    },
  },

  gonialAngle: {
    low: 'Your gonial angle is too acute (steep), which can create an overly defined but potentially harsh jaw appearance.',
    high: 'Your gonial angle is too obtuse (flat), resulting in a weak or undefined jaw angle. This reduces mandibular definition.',
    ideal: 'Your gonial angle is within the ideal range, providing good jaw definition without appearing overly harsh.',
    impact: {
      low: 'A steep gonial angle can make the face appear overly angular or masculine in females.',
      high: 'A flat gonial angle significantly reduces jaw definition and is a common area of concern.',
    },
    flawNames: {
      low: ['Steep mandibular plane', 'Acute gonial angle'],
      high: ['Flat gonial angle', 'Weak jaw definition', 'Obtuse mandibular angle'],
    },
  },

  bigonialWidth: {
    low: 'Your jaw width (bigonial width) is narrower than ideal relative to your face width, creating a less defined lower face.',
    high: 'Your jaw width is wider than ideal, which can create an overly square or blocky facial appearance.',
    ideal: 'Your jaw width is well-proportioned to your face width, contributing to balanced facial structure.',
    impact: {
      low: 'Narrow jaw width can reduce facial definition and create a less masculine appearance in males.',
      high: 'Excessive jaw width can appear masculine in females or create imbalance.',
    },
    flawNames: {
      low: ['Narrow jaw', 'Deficient bigonial width', 'Weak mandibular width'],
      high: ['Wide jaw', 'Excessive bigonial width', 'Square jaw'],
    },
  },

  nasalIndex: {
    low: 'Your nose is narrower than the ideal proportion relative to its height, which may appear pinched or overly refined.',
    high: 'Your nose is wider than ideal relative to its height, which can reduce nasal refinement and affect facial balance.',
    ideal: 'Your nasal proportions are balanced, with width harmonizing well with nasal height.',
    impact: {
      low: 'A very narrow nose can appear pinched and may create breathing issues.',
      high: 'A wide nose can dominate the midface and reduce overall facial refinement.',
    },
    flawNames: {
      low: ['Narrow nose', 'Leptorrhine nose', 'Pinched nose'],
      high: ['Wide nose', 'Platyrrhine nose', 'Broad nasal base'],
    },
  },

  eyeAspectRatio: {
    low: 'Your eyes appear narrower/more closed, with a lower height-to-width ratio. This can create a squinting or less open appearance.',
    high: 'Your eyes have a high height-to-width ratio, appearing very round. While not necessarily negative, this differs from the almond-shaped ideal.',
    ideal: 'Your eye aspect ratio falls within the ideal range, creating an attractive almond-shaped appearance.',
    impact: {
      low: 'Narrow eyes can appear less open and may reduce perceived attractiveness.',
      high: 'Very round eyes can appear surprised or less refined.',
    },
    flawNames: {
      low: ['Narrow eyes', 'Low eye aperture', 'Closed eye appearance'],
      high: ['Round eyes', 'Excessive eye aperture'],
    },
  },

  chinPhiltrumRatio: {
    low: 'Your chin height is short relative to your philtrum length, which can indicate a recessed or underdeveloped chin.',
    high: 'Your chin is long relative to your philtrum, which can create a bottom-heavy lower face appearance.',
    ideal: 'Your chin-to-philtrum ratio is balanced, contributing to harmonious lower third proportions.',
    impact: {
      low: 'A short chin relative to philtrum can make the face appear weak or recessed from the side.',
      high: 'An excessively long chin can dominate the lower face and appear unfeminine in females.',
    },
    flawNames: {
      low: ['Short chin', 'Recessed chin', 'Weak chin projection'],
      high: ['Long chin', 'Excessive chin height', 'Macrogenia'],
    },
  },

  submentalCervicalAngle: {
    low: 'Your submental-cervical angle is too acute, which is generally not a concern as it indicates good neck definition.',
    high: 'Your submental-cervical angle is too obtuse, indicating poor neck definition or excess submental fat.',
    ideal: 'Your submental-cervical angle is well-defined, contributing to a clean jawline-to-neck transition.',
    impact: {
      low: 'An overly acute angle is rare and usually not aesthetically concerning.',
      high: 'An obtuse angle creates a "double chin" appearance and reduces jawline definition.',
    },
    flawNames: {
      low: ['Overly defined neck angle'],
      high: ['Poor neck definition', 'Double chin', 'Obtuse cervicomental angle'],
    },
  },

  // Side profile metrics
  nasofrontalAngle: {
    low: 'Your nasofrontal angle is too acute, creating a sharp transition between forehead and nose that may appear harsh.',
    high: 'Your nasofrontal angle is too obtuse, creating a flattened transition between forehead and nose.',
    ideal: 'Your nasofrontal angle creates a smooth, aesthetically pleasing transition from forehead to nose.',
    impact: {
      low: 'A sharp nasofrontal angle can make the nose appear to project suddenly from the face.',
      high: 'A flat nasofrontal angle can reduce the nose\'s definition from the profile.',
    },
    flawNames: {
      low: ['Sharp nasofrontal transition', 'Acute nasofrontal angle'],
      high: ['Flat nasofrontal angle', 'Poor forehead-nose transition'],
    },
  },

  nasolabialAngle: {
    low: 'Your nasolabial angle is too acute, indicating a downturned nasal tip that can create a droopy appearance.',
    high: 'Your nasolabial angle is too obtuse, indicating an upturned nose that may appear overly rotated.',
    ideal: 'Your nasolabial angle is balanced, with appropriate nasal tip rotation for your gender.',
    impact: {
      low: 'A droopy nasal tip can age the face and create a less refined profile.',
      high: 'An overly upturned nose can appear piggy or infantile.',
    },
    flawNames: {
      low: ['Drooping nasal tip', 'Acute nasolabial angle', 'Ptotic nose'],
      high: ['Upturned nose', 'Over-rotated nasal tip', 'Obtuse nasolabial angle'],
    },
  },
};

// Default template for metrics without specific descriptions
const DEFAULT_DESCRIPTION: DescriptionTemplate = {
  low: 'This measurement is below the ideal range, which may affect your facial harmony.',
  high: 'This measurement is above the ideal range, which may affect your facial harmony.',
  ideal: 'This measurement falls within the ideal range, contributing to facial harmony.',
  impact: {
    low: 'Values below ideal can reduce facial balance and proportional harmony.',
    high: 'Values above ideal can create imbalance with other facial features.',
  },
  flawNames: {
    low: ['Below ideal range'],
    high: ['Above ideal range'],
  },
};

// ============================================
// MAIN GENERATOR FUNCTION
// ============================================

export function generateAIDescription(
  metricId: string,
  metricName: string,
  value: number,
  idealMin: number,
  idealMax: number,
  score: number,
  unit: string,
  category: string
): FlawDetail {
  const template = METRIC_DESCRIPTIONS[metricId] || DEFAULT_DESCRIPTION;
  const deviation = calculateDeviation(value, idealMin, idealMax, unit);
  const severity = getSeverityFromScore(score);
  const confidence = getConfidenceFromScore(score);

  // Format actual value with unit
  const unitSymbol = unit === 'percent' ? '%' : unit === 'degrees' ? '°' : unit === 'mm' ? 'mm' : '';
  const actualValue = `${value.toFixed(2)}${unitSymbol}`;
  const idealRange = `${idealMin.toFixed(2)}-${idealMax.toFixed(2)}${unitSymbol}`;

  // Get appropriate reasoning based on deviation direction
  let reasoning: string;
  let flawName: string;

  if (deviation.direction === 'within') {
    reasoning = template.ideal;
    flawName = 'Optimal';
  } else if (deviation.direction === 'below') {
    reasoning = template.low;
    flawName = template.flawNames.low[0] || 'Below ideal';
  } else {
    reasoning = template.high;
    flawName = template.flawNames.high[0] || 'Above ideal';
  }

  // Add impact information for non-ideal values
  if (deviation.direction !== 'within' && score < 7) {
    const impact = deviation.direction === 'below' ? template.impact.low : template.impact.high;
    reasoning += ` ${impact}`;
  }

  return {
    category,
    flawName,
    confidence,
    actualValue,
    idealRange,
    deviation: deviation.deviation,
    deviationPercent: deviation.percent,
    score,
    severity,
    reasoning,
  };
}

// ============================================
// STRENGTH DESCRIPTION GENERATOR
// ============================================

export function generateStrengthDescription(
  metricId: string,
  score: number
): string {
  const template = METRIC_DESCRIPTIONS[metricId] || DEFAULT_DESCRIPTION;

  if (score >= 8) {
    return template.ideal + ' This is one of your strongest facial features.';
  }

  return template.ideal;
}

// ============================================
// FLAW LIST GENERATOR
// ============================================

export function generateFlawsList(
  metricId: string,
  value: number,
  idealMin: number,
  idealMax: number
): string[] {
  const template = METRIC_DESCRIPTIONS[metricId] || DEFAULT_DESCRIPTION;
  const deviation = calculateDeviation(value, idealMin, idealMax, 'ratio');

  if (deviation.direction === 'within') {
    return [];
  }

  return deviation.direction === 'below'
    ? template.flawNames.low
    : template.flawNames.high;
}
