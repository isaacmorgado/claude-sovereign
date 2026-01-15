/**
 * Product Recommendation Engine
 * Maps facial metrics to supplement product recommendations
 */

import { ProductRecommendation } from '@/types/results';
import { PRODUCTS } from './product_db';
import { SUPPLEMENTS } from './recommendations/supplements';

// ============================================
// METRIC TO PRODUCT MAPPING
// ============================================

const METRIC_TO_PRODUCTS: Record<string, string[]> = {
  // Skin quality metrics -> skin products
  "Skin Texture Score": ["collagen_peptides", "vitamin_c_oral", "astaxanthin", "vitamin_e"],
  "Under Eye Area": ["collagen_peptides", "hyaluronic_acid_oral", "vitamin_e", "coq10"],
  "Skin Quality": ["collagen_peptides", "astaxanthin", "vitamin_c_oral", "omega_3"],

  // Bone/structure metrics -> bone + muscle products
  "Gonial Angle": ["creatine", "vitamin_d3", "vitamin_k2", "magnesium"],
  "Bigonial Width": ["creatine", "vitamin_d3", "vitamin_k2"],
  "Jaw Projection": ["creatine", "vitamin_d3", "magnesium"],
  "Cheekbone Height": ["collagen_peptides", "vitamin_k2", "silica", "vitamin_d3"],
  "Cheekbone Prominence": ["collagen_peptides", "vitamin_k2", "vitamin_d3"],
  "Chin Projection": ["creatine", "vitamin_d3", "vitamin_k2"],

  // Eye metrics -> general anti-aging
  "Canthal Tilt": ["collagen_peptides", "vitamin_c_oral", "astaxanthin"],
  "Eye Spacing Ratio": ["collagen_peptides", "vitamin_c_oral"],
  "Palpebral Fissure Height": ["collagen_peptides", "vitamin_c_oral"],

  // Hair metrics -> hair products
  "Hairline Position": ["biotin", "vitamin_d3", "iron", "saw_palmetto"],
  "Hairline Recession": ["biotin", "saw_palmetto", "iron", "vitamin_d3"],

  // Nose metrics -> collagen + structure
  "Nasal Tip Angle": ["collagen_peptides", "vitamin_c_oral"],
  "Nasal Bridge Width": ["collagen_peptides", "vitamin_c_oral"],

  // Lips -> collagen
  "Lip Fullness": ["collagen_peptides", "hyaluronic_acid_oral", "vitamin_c_oral"],
  "Upper Lip Height": ["collagen_peptides", "vitamin_c_oral"],

  // Neck -> posture + muscle
  "Neck Posture": ["magnesium", "vitamin_d3", "creatine"],
  "Cervicomental Angle": ["creatine", "magnesium"],

  // General harmony -> comprehensive stack
  "Overall Facial Harmony": ["omega_3", "coq10", "collagen_peptides", "vitamin_d3"],
  "Facial Symmetry": ["omega_3", "magnesium", "vitamin_d3"],

  // Age-related -> anti-aging
  "Facial Aging Score": ["nad_precursor", "resveratrol", "coq10", "collagen_peptides"],
  "Skin Laxity": ["collagen_peptides", "vitamin_c_oral", "astaxanthin", "coq10"],
};

// Category fallbacks (if specific metric not found)
const CATEGORY_TO_PRODUCTS: Record<string, string[]> = {
  "skin": ["collagen_peptides", "vitamin_c_oral", "astaxanthin", "vitamin_e"],
  "bone": ["vitamin_d3", "vitamin_k2", "creatine", "magnesium", "silica", "msm"],
  "hair": ["biotin", "iron", "saw_palmetto", "vitamin_d3", "zinc"],
  "anti-aging": ["nad_precursor", "coq10", "resveratrol", "omega_3"],
  "hormonal": ["ashwagandha", "tongkat_ali", "dim", "vitamin_d3"],
  "general": ["omega_3", "magnesium", "vitamin_d3", "creatine"],
};

// ============================================
// PRODUCT RECOMMENDATIONS
// ============================================

export function getProductRecommendations(
  metricsDict: Record<string, number>,
  severityDict: Record<string, string>,
  // These parameters are reserved for future gender/ethnicity-specific recommendations
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  gender: 'male' | 'female',
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  ethnicity: string
): ProductRecommendation[] {
  const recommendations: ProductRecommendation[] = [];
  const seenProducts = new Set<string>();

  // Iterate through all metrics
  for (const metricName of Object.keys(metricsDict)) {
    const severity = severityDict[metricName];
    if (!severity) continue;

    // Determine state and urgency
    let state: "flaw" | "ideal";
    let urgency: "high" | "medium" | "low";
    let messageTemplate: string;

    if (severity === "severe" || severity === "extremely_severe") {
      state = "flaw";
      urgency = "high";
      messageTemplate = "Your {metric} is below optimal. Use {product} to IMPROVE it.";
    } else if (severity === "moderate" || severity === "major") {
      state = "flaw";
      urgency = "medium";
      messageTemplate = "Your {metric} needs improvement. Use {product} to optimize it.";
    } else if (severity === "optimal" || severity === "ideal") {
      state = "ideal";
      urgency = "low";
      messageTemplate = "Your {metric} is excellent. Use {product} to MAINTAIN and PROTECT this strength.";
    } else {
      continue; // Skip "minor" or "good" - not compelling enough
    }

    // Find products for this metric
    let productIds = METRIC_TO_PRODUCTS[metricName];

    // If no direct mapping, try category fallback
    if (!productIds || productIds.length === 0) {
      const metricLower = metricName.toLowerCase();
      if (metricLower.includes('skin') || metricLower.includes('texture')) {
        productIds = CATEGORY_TO_PRODUCTS['skin'];
      } else if (metricLower.includes('jaw') || metricLower.includes('chin') || metricLower.includes('bone')) {
        productIds = CATEGORY_TO_PRODUCTS['bone'];
      } else if (metricLower.includes('hair')) {
        productIds = CATEGORY_TO_PRODUCTS['hair'];
      } else {
        productIds = CATEGORY_TO_PRODUCTS['general'];
      }
    }

    // Create recommendations for each product
    for (const supplementId of productIds.slice(0, 2)) {
      // Find product in PRODUCTS by supplementId
      const product = PRODUCTS.find(p => p.supplementId === supplementId);
      if (!product) continue;

      // Skip if already recommended
      if (seenProducts.has(product.id)) {
        // Just add this metric to existing recommendation
        const existing = recommendations.find(r => r.product.id === product.id);
        if (existing && !existing.matchedMetrics.includes(metricName)) {
          existing.matchedMetrics.push(metricName);
        }
        continue;
      }

      // Get supplement details for the product name
      const supplement = SUPPLEMENTS.find(s => s.id === supplementId);
      const productDisplayName = supplement?.name || product.name;

      // Create personalized message
      const message = messageTemplate
        .replace('{metric}', metricName)
        .replace('{product}', productDisplayName);

      recommendations.push({
        product,
        state,
        targetMetric: metricName,
        message,
        urgency,
        matchedMetrics: [metricName],
      });

      seenProducts.add(product.id);
    }
  }

  // Sort recommendations
  // 1. High urgency flaws first
  // 2. Then medium urgency flaws
  // 3. Then ideal maintenance products
  recommendations.sort((a, b) => {
    const urgencyOrder: Record<string, number> = { high: 3, medium: 2, low: 1 };
    const urgencyDiff = urgencyOrder[b.urgency] - urgencyOrder[a.urgency];
    if (urgencyDiff !== 0) return urgencyDiff;

    // Within same urgency, sort by product priority
    return b.product.priority - a.product.priority;
  });

  // Return top 15 recommendations
  return recommendations.slice(0, 15);
}
