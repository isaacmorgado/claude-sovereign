/**
 * FaceIQ Taxonomy - Hierarchical Classification System
 * Based on FACEIQ_TAXONOMY.md
 */

export interface TaxonomyCategory {
  id: string;
  name: string;
  description: string;
  weight?: number; // Primary category weight
  subcategories?: TaxonomySubcategory[];
}

export interface TaxonomySubcategory {
  id: string;
  name: string;
  description: string;
  metricPatterns: string[]; // Patterns to match metric names/categories
}

/**
 * Primary FaceIQ Categories
 */
export const FACEIQ_PRIMARY_CATEGORIES: TaxonomyCategory[] = [
  {
    id: 'harmony',
    name: 'Harmony',
    description: 'Mathematical balance and proportionality of facial features',
    weight: 0.36, // 32-40% average
    subcategories: [
      {
        id: 'facial-proportions',
        name: 'Facial Proportions',
        description: 'Facial thirds, FWHR, face width/height ratios',
        metricPatterns: ['facial third', 'fwhr', 'face width', 'face height', 'midface', 'golden ratio'],
      },
      {
        id: 'width-relationships',
        name: 'Width Relationships',
        description: 'Bigonial, bizygomatic, bitemporal, neck widths',
        metricPatterns: ['bigonial', 'bizygomatic', 'bitemporal', 'neck width', 'jaw width', 'cheekbone'],
      },
      {
        id: 'eye-harmony',
        name: 'Eye Harmony',
        description: 'Eye spacing, separation ratio, IPD, canthal measurements',
        metricPatterns: ['eye spacing', 'eye separation', 'ipd', 'interpupillary', 'canthal', 'inner canthal', 'outer canthal'],
      },
      {
        id: 'eyebrow-harmony',
        name: 'Eyebrow Harmony',
        description: 'Eyebrow tilt, position, height relative to eyes',
        metricPatterns: ['eyebrow', 'brow'],
      },
      {
        id: 'nose-harmony',
        name: 'Nose Harmony',
        description: 'Nasal width/height, nose/mouth ratios, nose/zygo ratio',
        metricPatterns: ['nasal width', 'nasal height', 'nose width', 'nose height', 'nose.*ratio', 'alar'],
      },
      {
        id: 'lip-harmony',
        name: 'Lip Harmony',
        description: 'Upper/lower lip ratio, lip proportions',
        metricPatterns: ['lip ratio', 'upper.*lip', 'lower.*lip'],
      },
      {
        id: 'chin-harmony',
        name: 'Chin & Lower Third',
        description: 'Chin to philtrum ratio, jaw angles, lower third proportions',
        metricPatterns: ['chin', 'philtrum', 'jaw frontal', 'ipsilateral', 'eye-mouth'],
      },
      {
        id: 'angular-harmony',
        name: 'Angular Measurements (Profile)',
        description: 'Gonial, mandibular, nasofrontal, nasolabial angles',
        metricPatterns: ['angle', 'gonial', 'mandibular plane', 'nasofrontal', 'nasolabial', 'nasomental', 'mentolabial'],
      },
      {
        id: 'convexity-harmony',
        name: 'Convexity (Profile)',
        description: 'Facial convexity and profile curvature',
        metricPatterns: ['convexity'],
      },
      {
        id: 'projection-harmony',
        name: 'Projection & Ratios (Profile)',
        description: 'Nasal projection, ramus/mandible ratio, orbital vector',
        metricPatterns: ['projection', 'ramus', 'mandible ratio', 'orbital vector'],
      },
      {
        id: 'lip-position-harmony',
        name: 'Lip Position (Profile)',
        description: 'E-line relationships for upper and lower lips',
        metricPatterns: ['e-line', 'e line', 'lip position'],
      },
    ],
  },
  {
    id: 'dimorphism',
    name: 'Dimorphism',
    description: 'Degree of masculine or feminine sexual characteristics',
    weight: 0.20,
    subcategories: [
      {
        id: 'masculine-features',
        name: 'Masculine Indicators',
        description: 'Brow ridge, jaw width, chin projection, ramus height',
        metricPatterns: ['brow ridge', 'supraorbital', 'jaw width', 'mandible width', 'ramus', 'chin projection'],
      },
      {
        id: 'feminine-features',
        name: 'Feminine Indicators',
        description: 'Higher cheekbones, softer angles, fuller lips',
        metricPatterns: ['cheekbone height', 'lip fullness'],
      },
      {
        id: 'dimorphic-ratios',
        name: 'Dimorphic Ratios',
        description: 'Bizygomatic width, fWHR, lower face length',
        metricPatterns: ['bizygomatic', 'fwhr', 'lower face length'],
      },
    ],
  },
  {
    id: 'angularity',
    name: 'Angularity',
    description: 'Sharpness, definition, and three-dimensionality of facial contours',
    weight: 0.19, // 15-22% average
    subcategories: [
      {
        id: 'jaw-definition',
        name: 'Jaw Definition',
        description: 'Mandible visibility, gonion sharpness, jawline clarity',
        metricPatterns: ['jaw definition', 'mandible', 'gonion', 'jawline'],
      },
      {
        id: 'cheekbone-definition',
        name: 'Cheekbone Definition',
        description: 'Cheekbone projection and visibility',
        metricPatterns: ['cheekbone projection', 'cheek projection'],
      },
      {
        id: 'overall-definition',
        name: 'Overall Definition',
        description: 'Face angularity, 3D depth, leanness',
        metricPatterns: ['angular', 'definition', '3d depth'],
      },
    ],
  },
  {
    id: 'features',
    name: 'Features',
    description: 'Individual feature quality and aesthetics',
    weight: 0.25,
    subcategories: [
      {
        id: 'skin-quality',
        name: 'Skin Quality',
        description: 'Texture, blemishes, scarring, wrinkles, tone',
        metricPatterns: ['skin', 'texture', 'acne', 'blemish', 'scar', 'wrinkle'],
      },
      {
        id: 'eye-features',
        name: 'Eye Features',
        description: 'Eyelid shape, scleral show, UEE, PFL, lashes, limbal rings',
        metricPatterns: ['eyelid', 'scleral', 'uee', 'pfl', 'palpebral', 'eyelash', 'limbal', 'under.*eye'],
      },
      {
        id: 'colouring',
        name: 'Colouring',
        description: 'Skin tone, lip color, eye contrast, complexion',
        metricPatterns: ['color', 'tone', 'complexion', 'contrast'],
      },
      {
        id: 'lower-third-features',
        name: 'Lower Third Features',
        description: 'Gonion shape, chin structure, jaw definition',
        metricPatterns: ['gonion shape', 'chin structure', 'lower third'],
      },
      {
        id: 'lip-features',
        name: 'Lip Features',
        description: 'Lip width, philtrum length, fullness, health',
        metricPatterns: ['lip width', 'lip fullness', 'philtrum length', 'commissure'],
      },
      {
        id: 'nose-features',
        name: 'Nose Features',
        description: 'Alar width, bulbosity, tip definition, nostril show',
        metricPatterns: ['alar width', 'nasal tip', 'nostril', 'dorsum', 'columella'],
      },
      {
        id: 'other-features',
        name: 'Other Features',
        description: 'Ears, symmetry, forehead, hairline',
        metricPatterns: ['ear', 'symmetry', 'forehead', 'hairline'],
      },
    ],
  },
];

/**
 * Maps a metric to its primary and secondary taxonomy categories
 */
export function classifyMetric(
  metricName: string,
  metricCategory?: string
): { primary: string; secondary: string } | null {
  const searchText = `${metricName} ${metricCategory || ''}`.toLowerCase();

  for (const primaryCat of FACEIQ_PRIMARY_CATEGORIES) {
    if (primaryCat.subcategories) {
      for (const subCat of primaryCat.subcategories) {
        // Check if any pattern matches
        const matches = subCat.metricPatterns.some(pattern => {
          const regex = new RegExp(pattern, 'i');
          return regex.test(searchText);
        });

        if (matches) {
          return {
            primary: primaryCat.id,
            secondary: subCat.id,
          };
        }
      }
    }
  }

  // Default fallback to harmony if no match
  return {
    primary: 'harmony',
    secondary: 'facial-proportions',
  };
}

/**
 * Get primary category by ID
 */
export function getPrimaryCategory(id: string): TaxonomyCategory | undefined {
  return FACEIQ_PRIMARY_CATEGORIES.find(cat => cat.id === id);
}

/**
 * Get subcategory by primary and secondary IDs
 */
export function getSubcategory(primaryId: string, secondaryId: string): TaxonomySubcategory | undefined {
  const primary = getPrimaryCategory(primaryId);
  return primary?.subcategories?.find(sub => sub.id === secondaryId);
}

/**
 * Get all metrics that belong to a primary category
 */
export function getMetricsForPrimaryCategory(
  primaryId: string,
  allMetrics: Array<{ name: string; category?: string }>
): Array<{ name: string; category?: string }> {
  return allMetrics.filter(metric => {
    const classification = classifyMetric(metric.name, metric.category);
    return classification?.primary === primaryId;
  });
}

/**
 * Get all metrics that belong to a subcategory
 */
export function getMetricsForSubcategory(
  primaryId: string,
  secondaryId: string,
  allMetrics: Array<{ name: string; category?: string }>
): Array<{ name: string; category?: string }> {
  return allMetrics.filter(metric => {
    const classification = classifyMetric(metric.name, metric.category);
    return classification?.primary === primaryId && classification?.secondary === secondaryId;
  });
}
