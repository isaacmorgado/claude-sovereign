/**
 * Guides Data Index
 * Central export for all guide-related data
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

// Individual Guides
export { mindsetGuide } from './mindset';
export { maintenanceGuide } from './maintenance';
export { bodyFatGuide } from './body-fat';
export { vTaperGuide } from './v-taper';
export { trainingGuide } from './training';
export { coreNeckGuide } from './core-neck';
export { cardioGuide } from './cardio';
export { dietGuide } from './diet';
export { skincareGuide } from './skincare';

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

/**
 * All guides in display order
 */
export const ALL_GUIDES: Guide[] = [
  mindsetGuide,
  maintenanceGuide,
  bodyFatGuide,
  vTaperGuide,
  trainingGuide,
  coreNeckGuide,
  cardioGuide,
  dietGuide,
  skincareGuide,
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
    guideIds: ['v-taper', 'training', 'core-neck', 'cardio'],
  },
  {
    id: 'appearance',
    name: 'Appearance',
    description: 'Dial in the details that matter.',
    icon: 'Sparkles',
    color: 'amber',
    guideIds: ['diet', 'skincare'],
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
