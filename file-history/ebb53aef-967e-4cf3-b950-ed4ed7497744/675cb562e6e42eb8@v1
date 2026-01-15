/**
 * Guides Data Index
 * Central export for all guide-related data
 * 27 Guides across 7 categories
 */

import { Guide, GuideCategory } from '@/types/guides';

// Product Registry
export {
  GUIDE_PRODUCTS,
  getGuideProductById,
  getGuideProductsByCategory,
  getBaseStackProducts,
  getGuideProductsByPriority,
  getProductCategories,
  getGuideProductsByIds,
  searchGuideProducts,
  getTotalProductCount,
  getCategoryDisplayInfo,
} from './products-registry';

// Individual Guides - Original 9
export { mindsetGuide } from './mindset';
export { maintenanceGuide } from './maintenance';
export { bodyFatGuide } from './body-fat';
export { vTaperGuide } from './v-taper';
export { trainingGuide } from './training';
export { coreNeckGuide } from './core-neck';
export { cardioGuide } from './cardio';
export { dietGuide } from './diet';
export { skincareGuide } from './skincare';

// Male-Specific Guides (5)
export { hairLossGuide } from './hair-loss';
export { beardGrowthGuide } from './beard-growth';
export { mewingJawlineGuide } from './mewing-jawline';
export { gynecomastiaGuide } from './gynecomastia';
export { neckTrainingGuide } from './neck-training';

// Female-Specific Guides (6)
export { antiAgingWomenGuide } from './anti-aging-women';
export { glassSkinGuide } from './glass-skin';
export { hormonalSkinGuide } from './hormonal-skin';
export { bodyContouringWomenGuide } from './body-contouring-women';
export { postpartumRecoveryGuide } from './postpartum-recovery';
export { feminineFeaturesGuide } from './feminine-features';

// Surgery Guides (4)
export { rhinoplastyGuide } from './rhinoplasty';
export { jawSurgeryGuide } from './jaw-surgery';
export { facialProceduresGuide } from './facial-procedures';
export { bodySurgeryGuide } from './body-surgery';

// Unisex Guides (3)
export { teethSmileGuide } from './teeth-smile';
export { fillerBotoxGuide } from './filler-botox';
export { accutaneGuide } from './accutane';

// ============================================
// GUIDE REGISTRY
// ============================================

import { mindsetGuide } from './mindset';
import { maintenanceGuide } from './maintenance';
import { bodyFatGuide } from './body-fat';
import { vTaperGuide } from './v-taper';
import { trainingGuide } from './training';
import { coreNeckGuide } from './core-neck';
import { cardioGuide } from './cardio';
import { dietGuide } from './diet';
import { skincareGuide } from './skincare';

// Male-Specific
import { hairLossGuide } from './hair-loss';
import { beardGrowthGuide } from './beard-growth';
import { mewingJawlineGuide } from './mewing-jawline';
import { gynecomastiaGuide } from './gynecomastia';
import { neckTrainingGuide } from './neck-training';

// Female-Specific
import { antiAgingWomenGuide } from './anti-aging-women';
import { glassSkinGuide } from './glass-skin';
import { hormonalSkinGuide } from './hormonal-skin';
import { bodyContouringWomenGuide } from './body-contouring-women';
import { postpartumRecoveryGuide } from './postpartum-recovery';
import { feminineFeaturesGuide } from './feminine-features';

// Surgery
import { rhinoplastyGuide } from './rhinoplasty';
import { jawSurgeryGuide } from './jaw-surgery';
import { facialProceduresGuide } from './facial-procedures';
import { bodySurgeryGuide } from './body-surgery';

// Unisex
import { teethSmileGuide } from './teeth-smile';
import { fillerBotoxGuide } from './filler-botox';
import { accutaneGuide } from './accutane';

/**
 * All guides in display order
 */
export const ALL_GUIDES: Guide[] = [
  // Original 9
  mindsetGuide,
  maintenanceGuide,
  bodyFatGuide,
  vTaperGuide,
  trainingGuide,
  coreNeckGuide,
  cardioGuide,
  dietGuide,
  skincareGuide,
  // Male-Specific
  hairLossGuide,
  beardGrowthGuide,
  mewingJawlineGuide,
  gynecomastiaGuide,
  neckTrainingGuide,
  // Female-Specific
  antiAgingWomenGuide,
  glassSkinGuide,
  hormonalSkinGuide,
  bodyContouringWomenGuide,
  postpartumRecoveryGuide,
  feminineFeaturesGuide,
  // Surgery
  rhinoplastyGuide,
  jawSurgeryGuide,
  facialProceduresGuide,
  bodySurgeryGuide,
  // Unisex
  teethSmileGuide,
  fillerBotoxGuide,
  accutaneGuide,
].sort((a, b) => a.order - b.order);

/**
 * Guide lookup by ID
 */
export const GUIDES_BY_ID: Record<string, Guide> = ALL_GUIDES.reduce(
  (acc, guide) => {
    acc[guide.id] = guide;
    return acc;
  },
  {} as Record<string, Guide>
);

/**
 * Guide lookup by slug
 */
export const GUIDES_BY_SLUG: Record<string, Guide> = ALL_GUIDES.reduce(
  (acc, guide) => {
    acc[guide.slug] = guide;
    return acc;
  },
  {} as Record<string, Guide>
);

// ============================================
// GUIDE CATEGORIES
// ============================================

export const GUIDE_CATEGORIES: GuideCategory[] = [
  {
    id: 'fundamentals',
    name: 'Fundamentals',
    description: 'Start here. The basics everyone needs.',
    icon: 'BookOpen',
    color: 'blue',
    guideIds: ['mindset', 'maintenance', 'body-fat'],
  },
  {
    id: 'physique',
    name: 'Physique',
    description: 'Build the body that commands respect.',
    icon: 'Dumbbell',
    color: 'purple',
    guideIds: ['v-taper', 'training', 'core-neck', 'cardio', 'neck-training'],
  },
  {
    id: 'appearance',
    name: 'Appearance',
    description: 'Dial in the details that matter.',
    icon: 'Sparkles',
    color: 'amber',
    guideIds: ['diet', 'skincare', 'teeth-smile', 'accutane'],
  },
  {
    id: 'male',
    name: 'Male-Specific',
    description: 'Guides tailored for men.',
    icon: 'User',
    color: 'cyan',
    guideIds: ['hair-loss', 'beard-growth', 'mewing-jawline', 'gynecomastia'],
  },
  {
    id: 'female',
    name: 'Female-Specific',
    description: 'Guides tailored for women.',
    icon: 'Heart',
    color: 'pink',
    guideIds: ['anti-aging-women', 'glass-skin', 'hormonal-skin', 'body-contouring-women', 'postpartum-recovery', 'feminine-features'],
  },
  {
    id: 'procedures',
    name: 'Non-Surgical',
    description: 'Injectables, lasers, and non-invasive procedures.',
    icon: 'Syringe',
    color: 'emerald',
    guideIds: ['filler-botox'],
  },
  {
    id: 'surgery',
    name: 'Surgery',
    description: 'When you want permanent change.',
    icon: 'Stethoscope',
    color: 'red',
    guideIds: ['rhinoplasty', 'jaw-surgery', 'facial-procedures', 'body-surgery'],
  },
];

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Get guide by ID
 */
export function getGuideById(id: string): Guide | undefined {
  return GUIDES_BY_ID[id];
}

/**
 * Get guide by slug
 */
export function getGuideBySlug(slug: string): Guide | undefined {
  return GUIDES_BY_SLUG[slug];
}

/**
 * Get all guides in a category
 */
export function getGuidesByCategory(categoryId: string): Guide[] {
  const category = GUIDE_CATEGORIES.find(c => c.id === categoryId);
  if (!category) return [];
  return category.guideIds
    .map(id => GUIDES_BY_ID[id])
    .filter((g): g is Guide => g !== undefined);
}

/**
 * Get related guides for a given guide
 */
export function getRelatedGuides(guideId: string): Guide[] {
  const guide = GUIDES_BY_ID[guideId];
  if (!guide || !guide.relatedGuides) return [];
  return guide.relatedGuides
    .map(id => GUIDES_BY_ID[id])
    .filter((g): g is Guide => g !== undefined);
}

/**
 * Search guides by title or description
 */
export function searchGuides(query: string): Guide[] {
  const lowered = query.toLowerCase();
  return ALL_GUIDES.filter(
    g =>
      g.title.toLowerCase().includes(lowered) ||
      g.description.toLowerCase().includes(lowered) ||
      (g.subtitle && g.subtitle.toLowerCase().includes(lowered)) ||
      (g.tags && g.tags.some(tag => tag.toLowerCase().includes(lowered)))
  );
}

/**
 * Get total guide count
 */
export function getTotalGuideCount(): number {
  return ALL_GUIDES.length;
}

/**
 * Get total estimated reading time
 */
export function getTotalReadTime(): number {
  return ALL_GUIDES.reduce((sum, guide) => sum + guide.estimatedReadTime, 0);
}

/**
 * Get all unique product IDs across all guides
 */
export function getAllGuideProductIds(): string[] {
  const ids = new Set<string>();
  ALL_GUIDES.forEach(guide => {
    guide.productIds?.forEach(id => ids.add(id));
    guide.sections.forEach(section => {
      section.products?.forEach(id => ids.add(id));
    });
  });
  return Array.from(ids);
}

/**
 * Get guides by gender filter
 */
export function getGuidesByGender(gender: 'male' | 'female' | 'all'): Guide[] {
  if (gender === 'all') return ALL_GUIDES;

  const maleGuideIds = ['hair-loss', 'beard-growth', 'mewing-jawline', 'gynecomastia', 'neck-training'];
  const femaleGuideIds = ['anti-aging-women', 'glass-skin', 'hormonal-skin', 'body-contouring-women', 'postpartum-recovery', 'feminine-features'];

  if (gender === 'male') {
    return ALL_GUIDES.filter(g => !femaleGuideIds.includes(g.id));
  } else {
    return ALL_GUIDES.filter(g => !maleGuideIds.includes(g.id));
  }
}
