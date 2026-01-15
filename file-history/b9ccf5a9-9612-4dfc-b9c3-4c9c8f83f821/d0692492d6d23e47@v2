/**
 * Daily Stack Generator
 * Generates universal supplement stack shown to ALL users
 */

import { DailyStack } from '@/types/results';
import { getBaseStackProducts, getProductById } from './product_db';
import { SUPPLEMENTS } from './recommendations/supplements';

export function generateDailyStack(
  gender: 'male' | 'female',
  age?: number
): DailyStack {
  // Get base 6 products that everyone needs
  let stackProducts = getBaseStackProducts();

  // Add gender-specific boosters
  if (gender === 'male') {
    const ashwagandha = getProductById('ashwagandha_now');
    if (ashwagandha) {
      stackProducts = [...stackProducts, ashwagandha];
    }
  }

  // Add age-specific boosters (30+)
  if (age && age >= 30) {
    const nmn = getProductById('nmn_prohealth');
    if (nmn) {
      stackProducts = [...stackProducts, nmn];
    }
  }

  // Calculate total cost
  const totalCostMin = stackProducts.reduce((sum, product) => {
    const supplement = SUPPLEMENTS.find(s => s.id === product.supplementId);
    return sum + (supplement?.costPerMonth.min || 0);
  }, 0);

  const totalCostMax = stackProducts.reduce((sum, product) => {
    const supplement = SUPPLEMENTS.find(s => s.id === product.supplementId);
    return sum + (supplement?.costPerMonth.max || 0);
  }, 0);

  // Organize by timing
  const morningIds = ['vitamin_c_now', 'd3_k2_sports_research', 'creatine_optimum', 'ashwagandha_now', 'nmn_prohealth'];
  const eveningIds = ['magnesium_doctors_best', 'omega3_nordic'];

  const timing = {
    morning: stackProducts.filter(p => morningIds.includes(p.id)),
    evening: stackProducts.filter(p => eveningIds.includes(p.id)),
    anytime: stackProducts.filter(p =>
      !morningIds.includes(p.id) && !eveningIds.includes(p.id)
    ),
  };

  // Rationale message
  const rationale = gender === 'male'
    ? "This foundation stack supports skin elasticity, bone structure, hormonal balance, and inflammation control - the pillars of facial aesthetics and long-term appearance preservation."
    : "This foundation stack supports collagen production, bone density, skin health, and hormonal balance - essential for maintaining facial aesthetics and preventing age-related changes.";

  return {
    products: stackProducts,
    totalCostPerMonth: {
      min: Math.round(totalCostMin),
      max: Math.round(totalCostMax),
    },
    timing,
    rationale,
  };
}

// Helper to get supplement details for a product
export function getSupplementDetails(supplementId: string) {
  return SUPPLEMENTS.find(s => s.id === supplementId);
}
