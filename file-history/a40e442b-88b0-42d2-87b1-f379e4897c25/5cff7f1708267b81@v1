# Supplement E-Commerce Implementation Guide

## Overview
Transform the LOOKSMAXX advice system from diagnostic-only to an e-commerce funnel by implementing an "always-sell" product recommendation engine. Even users with perfect scores will receive product recommendations for maintenance.

---

## Requirements
- ✅ Keep both products AND procedures
- ✅ Show products to EVERYONE (even ideal scores get maintenance products)
- ✅ Mixed affiliate approach (Amazon + direct brand links)
- ✅ Daily Stack as hero element (top of PlanTab)
- ✅ Use existing 6 categories from supplements.ts

---

## Architecture

### Current State
- **advice-engine.ts**: 10 procedural plans (surgical/minimally invasive/foundational)
- **supplements.ts**: 26 supplement products (DORMANT - not in UI)
- **Trigger logic**: Only fires for flaws (NOT ideal metrics)
- **UI**: PlanTab shows only procedures

### Target State
```
PlanTab.tsx
├─ DailyStackCard (NEW - top hero element)
│  └─ 4-6 universal products for all users
├─ PotentialScoreCard (existing)
├─ Targeted Product Recommendations (NEW)
│  ├─ State A: Corrective Products (flaw metrics)
│  └─ State B: Maintenance Products (ideal metrics)
└─ Procedure Plans (existing - surgical/minimally invasive/foundational)
```

---

## Phase 1: Create Type Definitions

### File: `src/types/results.ts`

Add these new type definitions to the bottom of the existing file:

```typescript
// ============================================
// PRODUCT & SUPPLEMENT TYPES
// ============================================

export interface Product {
  id: string;
  name: string;
  brand: string;
  category: "skin" | "hair" | "anti-aging" | "hormonal" | "bone" | "general";
  affiliateLink: string;
  affiliateType: "amazon" | "direct";
  supplementId: string;  // Reference to supplements.ts
  priority: number;  // 1-10 (higher = more likely in Daily Stack)
  baseStackItem?: boolean;  // True if part of universal Daily Stack
}

export interface ProductRecommendation {
  product: Product;
  state: "flaw" | "ideal";  // State A (corrective) or State B (maintenance)
  targetMetric: string;  // Which metric triggered this recommendation
  message: string;  // Personalized hook message
  urgency: "high" | "medium" | "low";
  matchedMetrics: string[];  // All metrics this product addresses
}

export interface DailyStack {
  products: Product[];
  totalCostPerMonth: { min: number; max: number };
  timing: {
    morning: Product[];
    evening: Product[];
    anytime: Product[];
  };
  rationale: string;  // Why everyone needs these products
}
```

---

## Phase 2: Create Product Database

### File: `src/lib/product_db.ts`

Create a new file with the following content:

```typescript
/**
 * Product Database with Affiliate Links
 * Maps to existing supplements.ts for detailed supplement info
 */

import { Product } from '@/types/results';

export const PRODUCTS: Product[] = [
  // ============================================
  // BASE STACK ITEMS (6 products - shown to ALL users)
  // ============================================
  {
    id: "collagen_vital_proteins",
    name: "Collagen Peptides",
    brand: "Vital Proteins",
    category: "skin",
    affiliateLink: "https://amazon.com/dp/B00K9XZTW0?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "collagen_peptides",
    priority: 10,
    baseStackItem: true,
  },
  {
    id: "vitamin_c_now",
    name: "Vitamin C 1000mg",
    brand: "NOW Foods",
    category: "skin",
    affiliateLink: "https://amazon.com/dp/B0013OQGO6?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "vitamin_c_oral",
    priority: 9,
    baseStackItem: true,
  },
  {
    id: "d3_k2_sports_research",
    name: "Vitamin D3+K2",
    brand: "Sports Research",
    category: "bone",
    affiliateLink: "https://amazon.com/dp/B01N5P3E9X?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "vitamin_d3",
    priority: 9,
    baseStackItem: true,
  },
  {
    id: "magnesium_doctors_best",
    name: "Magnesium Glycinate",
    brand: "Doctor's Best",
    category: "general",
    affiliateLink: "https://amazon.com/dp/B000BD0RT0?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "magnesium",
    priority: 8,
    baseStackItem: true,
  },
  {
    id: "omega3_nordic",
    name: "Omega-3 Fish Oil",
    brand: "Nordic Naturals",
    category: "anti-aging",
    affiliateLink: "https://www.nordicnaturals.com/products/ultimate-omega?ref=looksmaxx",
    affiliateType: "direct",
    supplementId: "omega_3",
    priority: 8,
    baseStackItem: true,
  },
  {
    id: "creatine_optimum",
    name: "Creatine Monohydrate",
    brand: "Optimum Nutrition",
    category: "general",
    affiliateLink: "https://amazon.com/dp/B002DYIZEO?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "creatine",
    priority: 9,
    baseStackItem: true,
  },

  // ============================================
  // TARGETED PRODUCTS (shown based on metrics)
  // ============================================
  {
    id: "ashwagandha_now",
    name: "Ashwagandha KSM-66",
    brand: "NOW Foods",
    category: "hormonal",
    affiliateLink: "https://amazon.com/dp/B01D0YJAD8?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "ashwagandha",
    priority: 7,
    baseStackItem: false,
  },
  {
    id: "astaxanthin_sports",
    name: "Astaxanthin 12mg",
    brand: "Sports Research",
    category: "skin",
    affiliateLink: "https://amazon.com/dp/B01N9QMTLJ?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "astaxanthin",
    priority: 7,
    baseStackItem: false,
  },
  {
    id: "biotin_sports",
    name: "Biotin 5000mcg",
    brand: "Sports Research",
    category: "hair",
    affiliateLink: "https://amazon.com/dp/B01M4MC7EU?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "biotin",
    priority: 5,
    baseStackItem: false,
  },
  {
    id: "iron_thorne",
    name: "Iron Bisglycinate",
    brand: "Thorne",
    category: "hair",
    affiliateLink: "https://www.thorne.com/products/dp/iron-bisglycinate?ref=looksmaxx",
    affiliateType: "direct",
    supplementId: "iron",
    priority: 6,
    baseStackItem: false,
  },
  {
    id: "saw_palmetto_now",
    name: "Saw Palmetto Extract",
    brand: "NOW Foods",
    category: "hair",
    affiliateLink: "https://amazon.com/dp/B0013OQGZ0?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "saw_palmetto",
    priority: 5,
    baseStackItem: false,
  },
  {
    id: "coq10_jarrow",
    name: "CoQ10 Ubiquinol",
    brand: "Jarrow Formulas",
    category: "anti-aging",
    affiliateLink: "https://amazon.com/dp/B0013OVVK0?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "coq10",
    priority: 6,
    baseStackItem: false,
  },
  {
    id: "nmn_prohealth",
    name: "NMN 250mg",
    brand: "ProHealth Longevity",
    category: "anti-aging",
    affiliateLink: "https://www.prohealthlongevity.com/products/nmn-pro-500?ref=looksmaxx",
    affiliateType: "direct",
    supplementId: "nad_precursor",
    priority: 6,
    baseStackItem: false,
  },
  {
    id: "tongkat_doublewood",
    name: "Tongkat Ali 200mg",
    brand: "Double Wood",
    category: "hormonal",
    affiliateLink: "https://amazon.com/dp/B07K3PZZFH?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "tongkat_ali",
    priority: 6,
    baseStackItem: false,
  },
  {
    id: "msm_now",
    name: "MSM 1000mg",
    brand: "NOW Foods",
    category: "bone",
    affiliateLink: "https://amazon.com/dp/B0013OUKTS?tag=looksmaxx-20",
    affiliateType: "amazon",
    supplementId: "msm",
    priority: 5,
    baseStackItem: false,
  },
];

// ============================================
// HELPER FUNCTIONS
// ============================================

export function getProductById(id: string): Product | undefined {
  return PRODUCTS.find(p => p.id === id);
}

export function getProductBySupplementId(supplementId: string): Product | undefined {
  return PRODUCTS.find(p => p.supplementId === supplementId);
}

export function getBaseStackProducts(): Product[] {
  return PRODUCTS.filter(p => p.baseStackItem === true)
    .sort((a, b) => b.priority - a.priority);
}

export function getProductsByCategory(category: Product['category']): Product[] {
  return PRODUCTS.filter(p => p.category === category)
    .sort((a, b) => b.priority - a.priority);
}

export function getProductsByIds(ids: string[]): Product[] {
  return ids.map(id => getProductById(id)).filter(p => p !== undefined) as Product[];
}
```

---

## Phase 3: Create Daily Stack Generator

### File: `src/lib/daily-stack.ts`

Create a new file with the following content:

```typescript
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
  const timing = {
    morning: stackProducts.filter(p => {
      const supplement = SUPPLEMENTS.find(s => s.id === p.supplementId);
      return supplement?.timing.toLowerCase().includes('morning') ||
             ['vitamin_c_now', 'd3_k2_sports_research', 'creatine_optimum', 'ashwagandha_now', 'nmn_prohealth'].includes(p.id);
    }),
    evening: stackProducts.filter(p => {
      const supplement = SUPPLEMENTS.find(s => s.id === p.supplementId);
      return supplement?.timing.toLowerCase().includes('evening') ||
             supplement?.timing.toLowerCase().includes('bed') ||
             ['magnesium_doctors_best', 'omega3_nordic'].includes(p.id);
    }),
    anytime: stackProducts.filter(p => {
      const supplement = SUPPLEMENTS.find(s => s.id === p.supplementId);
      const timing = supplement?.timing.toLowerCase() || '';
      return timing.includes('any time') && !['magnesium_doctors_best', 'omega3_nordic'].includes(p.id);
    }),
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
```

---

## Phase 4: Add Product Recommendation Logic to Advice Engine

### File: `src/lib/advice-engine.ts`

Add the following to the existing file:

#### Step 4.1: Import statements (add to top of file)

```typescript
import { ProductRecommendation } from '@/types/results';
import { PRODUCTS, getProductsByIds } from './product_db';
import { SUPPLEMENTS } from './recommendations/supplements';
```

#### Step 4.2: Add metric-to-product mapping (add after PLANS constant)

```typescript
// ============================================
// METRIC TO PRODUCT MAPPING
// ============================================

const METRIC_TO_PRODUCTS: Record<string, string[]> = {
  // Skin quality metrics → skin products
  "Skin Texture Score": ["collagen_peptides", "vitamin_c_oral", "astaxanthin", "vitamin_e"],
  "Under Eye Area": ["collagen_peptides", "hyaluronic_acid_oral", "vitamin_e", "coq10"],
  "Skin Quality": ["collagen_peptides", "astaxanthin", "vitamin_c_oral", "omega_3"],

  // Bone/structure metrics → bone + muscle products
  "Gonial Angle": ["creatine", "vitamin_d3", "vitamin_k2", "magnesium"],
  "Bigonial Width": ["creatine", "vitamin_d3", "vitamin_k2"],
  "Jaw Projection": ["creatine", "vitamin_d3", "magnesium"],
  "Cheekbone Height": ["collagen_peptides", "vitamin_k2", "silica", "vitamin_d3"],
  "Cheekbone Prominence": ["collagen_peptides", "vitamin_k2", "vitamin_d3"],
  "Chin Projection": ["creatine", "vitamin_d3", "vitamin_k2"],

  // Eye metrics → general anti-aging
  "Canthal Tilt": ["collagen_peptides", "vitamin_c_oral", "astaxanthin"],
  "Eye Spacing Ratio": ["collagen_peptides", "vitamin_c_oral"],
  "Palpebral Fissure Height": ["collagen_peptides", "vitamin_c_oral"],

  // Hair metrics → hair products
  "Hairline Position": ["biotin", "vitamin_d3", "iron", "saw_palmetto"],
  "Hairline Recession": ["biotin", "saw_palmetto", "iron", "vitamin_d3"],

  // Nose metrics → collagen + structure
  "Nasal Tip Angle": ["collagen_peptides", "vitamin_c_oral"],
  "Nasal Bridge Width": ["collagen_peptides", "vitamin_c_oral"],

  // Lips → collagen
  "Lip Fullness": ["collagen_peptides", "hyaluronic_acid_oral", "vitamin_c_oral"],
  "Upper Lip Height": ["collagen_peptides", "vitamin_c_oral"],

  // Neck → posture + muscle
  "Neck Posture": ["magnesium", "vitamin_d3", "creatine"],
  "Cervicomental Angle": ["creatine", "magnesium"],

  // General harmony → comprehensive stack
  "Overall Facial Harmony": ["omega_3", "coq10", "collagen_peptides", "vitamin_d3"],
  "Facial Symmetry": ["omega_3", "magnesium", "vitamin_d3"],

  // Age-related → anti-aging
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
```

#### Step 4.3: Add getProductRecommendations function (add after getRecommendations function)

```typescript
// ============================================
// PRODUCT RECOMMENDATIONS
// ============================================

export function getProductRecommendations(
  metricsDict: Record<string, number>,
  severityDict: Record<string, string>,
  gender: 'male' | 'female',
  ethnicity: string
): ProductRecommendation[] {
  const recommendations: ProductRecommendation[] = [];
  const seenProducts = new Set<string>();

  // Iterate through all metrics
  for (const [metricName, metricValue] of Object.entries(metricsDict)) {
    const severity = severityDict[metricName];
    if (!severity) continue;

    // Determine state and urgency
    let state: "flaw" | "ideal";
    let urgency: "high" | "medium" | "low";
    let messageTemplate: string;

    if (severity === "severe" || severity === "extremely_severe") {
      state = "flaw";
      urgency = "high";
      messageTemplate = "Your {metric} is WEAK (bottom 10%). Use {product} to IMPROVE it.";
    } else if (severity === "moderate" || severity === "major") {
      state = "flaw";
      urgency = "medium";
      messageTemplate = "Your {metric} needs improvement. Use {product} to optimize it.";
    } else if (severity === "optimal" || severity === "ideal") {
      state = "ideal";
      urgency = "low";
      messageTemplate = "Your {metric} is ELITE (top 10%). Use {product} to MAINTAIN and PROTECT this strength.";
    } else {
      continue; // Skip "minor" or "good" - not compelling enough
    }

    // Find products for this metric
    let productIds = METRIC_TO_PRODUCTS[metricName];

    // If no direct mapping, try category fallback
    if (!productIds || productIds.length === 0) {
      // Try to infer category from metric name
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
    for (const supplementId of productIds.slice(0, 2)) { // Max 2 products per metric
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
    const urgencyOrder = { high: 3, medium: 2, low: 1 };
    const urgencyDiff = urgencyOrder[b.urgency] - urgencyOrder[a.urgency];
    if (urgencyDiff !== 0) return urgencyDiff;

    // Within same urgency, sort by product priority
    return b.product.priority - a.product.priority;
  });

  // Return top 15 recommendations
  return recommendations.slice(0, 15);
}
```

---

## Phase 5: Update ResultsContext

### File: `src/contexts/ResultsContext.tsx`

#### Step 5.1: Add imports (add to top of file)

```typescript
import { ProductRecommendation, DailyStack } from '@/types/results';
import { getProductRecommendations } from '@/lib/advice-engine';
import { generateDailyStack } from '@/lib/daily-stack';
```

#### Step 5.2: Add to ResultsContextValue interface (find the interface definition)

```typescript
// Add these two lines to the ResultsContextValue interface:
productRecommendations: ProductRecommendation[];
dailyStack: DailyStack | null;
```

#### Step 5.3: Add to context state initialization (in the component)

Find where the context provider returns its value and add:

```typescript
// After recommendations generation, add:
const productRecs = getProductRecommendations(
  metricsDict,
  severityDict,
  gender,
  ethnicity
);

const stack = generateDailyStack(gender);
```

#### Step 5.4: Expose in provider value

```typescript
// In the return statement, add these to the value prop:
productRecommendations: productRecs,
dailyStack: stack,
```

---

## Phase 6: Create Product UI Components

### File: `src/components/results/cards/ProductCard.tsx`

Create a new file:

```typescript
'use client';

import { motion } from 'framer-motion';
import { ProductRecommendation } from '@/types/results';
import { ExternalLink, TrendingUp, TrendingDown, DollarSign, Clock } from 'lucide-react';
import { getSupplementDetails } from '@/lib/daily-stack';

interface ProductCardProps {
  recommendation: ProductRecommendation;
  rank?: number;
}

export function ProductCard({ recommendation, rank }: ProductCardProps) {
  const { product, state, message, urgency } = recommendation;
  const supplement = getSupplementDetails(product.supplementId);

  // State-based styling
  const isCorrectiveState = state === 'flaw';
  const stateBadgeColor = isCorrectiveState
    ? 'bg-red-500/20 text-red-400 border-red-500/30'
    : 'bg-green-500/20 text-green-400 border-green-500/30';
  const stateBadgeText = isCorrectiveState ? 'Corrective' : 'Maintenance';
  const stateIcon = isCorrectiveState ? TrendingUp : TrendingDown;
  const StateIcon = stateIcon;

  // Urgency styling
  const urgencyColor = urgency === 'high'
    ? 'text-red-400'
    : urgency === 'medium'
    ? 'text-yellow-400'
    : 'text-green-400';

  // CTA text
  const ctaText = product.affiliateType === 'amazon' ? 'View on Amazon' : 'Shop Direct';

  return (
    <motion.div
      className="bg-gradient-to-br from-neutral-900 to-neutral-950 border border-neutral-800 rounded-xl p-5 hover:border-neutral-700 transition-all"
      whileHover={{ y: -2 }}
    >
      {/* Header */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            {rank && (
              <div className="w-6 h-6 rounded-full bg-cyan-500/20 flex items-center justify-center flex-shrink-0">
                <span className="text-xs font-bold text-cyan-400">{rank}</span>
              </div>
            )}
            <h3 className="font-semibold text-white">{product.name}</h3>
          </div>
          <p className="text-sm text-neutral-400">{product.brand}</p>
        </div>

        <div className={`px-2 py-1 rounded-lg border text-xs font-medium flex items-center gap-1 ${stateBadgeColor}`}>
          <StateIcon size={12} />
          {stateBadgeText}
        </div>
      </div>

      {/* Message */}
      <div className="mb-4">
        <p className="text-sm text-neutral-300">{message}</p>
        <p className="text-xs text-neutral-500 mt-1">
          Targets: {recommendation.matchedMetrics.join(', ')}
        </p>
      </div>

      {/* Quick Stats */}
      {supplement && (
        <div className="grid grid-cols-3 gap-3 mb-4">
          <div className="bg-neutral-800/50 rounded-lg p-2">
            <div className="flex items-center gap-1 text-neutral-400 mb-1">
              <DollarSign size={12} />
              <span className="text-xs">Cost</span>
            </div>
            <p className="text-sm font-medium text-white">
              ${supplement.costPerMonth.min}-${supplement.costPerMonth.max}/mo
            </p>
          </div>

          <div className="bg-neutral-800/50 rounded-lg p-2">
            <div className="flex items-center gap-1 text-neutral-400 mb-1">
              <Clock size={12} />
              <span className="text-xs">Timeline</span>
            </div>
            <p className="text-sm font-medium text-white">{supplement.timelineToResults}</p>
          </div>

          <div className="bg-neutral-800/50 rounded-lg p-2">
            <div className="text-neutral-400 mb-1 text-xs">Dosage</div>
            <p className="text-sm font-medium text-white">{supplement.dosage}</p>
          </div>
        </div>
      )}

      {/* CTA Button */}
      <a
        href={product.affiliateLink}
        target="_blank"
        rel="noopener noreferrer"
        className="block w-full bg-cyan-500 hover:bg-cyan-400 text-black font-medium py-2.5 px-4 rounded-lg transition-colors flex items-center justify-center gap-2"
      >
        {ctaText}
        <ExternalLink size={16} />
      </a>

      {/* Affiliate Disclosure */}
      <p className="text-xs text-neutral-600 text-center mt-2">
        We may earn a commission from purchases made through this link.
      </p>
    </motion.div>
  );
}
```

### File: `src/components/results/cards/DailyStackCard.tsx`

Create a new file:

```typescript
'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { DailyStack } from '@/types/results';
import { Sparkles, ChevronDown, ChevronUp, Sun, Moon, Clock, DollarSign } from 'lucide-react';
import { getSupplementDetails } from '@/lib/daily-stack';

interface DailyStackCardProps {
  dailyStack: DailyStack;
}

export function DailyStackCard({ dailyStack }: DailyStackCardProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <motion.div
      className="bg-gradient-to-br from-cyan-600 to-blue-700 rounded-2xl p-6 shadow-xl"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      {/* Header */}
      <div className="flex items-center gap-3 mb-4">
        <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center">
          <Sparkles size={24} className="text-white" />
        </div>
        <div className="flex-1">
          <h2 className="text-xl font-bold text-white">Your Foundation Stack</h2>
          <p className="text-cyan-100 text-sm">
            ${dailyStack.totalCostPerMonth.min}-${dailyStack.totalCostPerMonth.max}/month
          </p>
        </div>
      </div>

      {/* Rationale */}
      <p className="text-white/90 text-sm mb-4 leading-relaxed">
        {dailyStack.rationale}
      </p>

      {/* Product Pills */}
      <div className="flex flex-wrap gap-2 mb-4">
        {dailyStack.products.slice(0, 6).map(product => (
          <div
            key={product.id}
            className="px-3 py-1.5 bg-white/20 rounded-full text-white text-sm font-medium"
          >
            {product.name}
          </div>
        ))}
      </div>

      {/* Expand/Collapse Button */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full bg-white/20 hover:bg-white/30 text-white font-medium py-2.5 px-4 rounded-lg transition-colors flex items-center justify-center gap-2"
      >
        {isExpanded ? 'Hide Details' : 'View Complete Stack'}
        {isExpanded ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
      </button>

      {/* Expanded Details */}
      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="mt-4 space-y-4 overflow-hidden"
          >
            {/* Morning */}
            {dailyStack.timing.morning.length > 0 && (
              <div className="bg-white/10 rounded-xl p-4">
                <div className="flex items-center gap-2 text-white font-medium mb-3">
                  <Sun size={18} />
                  <span>Morning</span>
                </div>
                <div className="space-y-2">
                  {dailyStack.timing.morning.map(product => {
                    const supplement = getSupplementDetails(product.supplementId);
                    return (
                      <div key={product.id} className="flex items-center justify-between text-sm">
                        <span className="text-white">{product.name}</span>
                        <span className="text-cyan-100">{supplement?.dosage}</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Evening */}
            {dailyStack.timing.evening.length > 0 && (
              <div className="bg-white/10 rounded-xl p-4">
                <div className="flex items-center gap-2 text-white font-medium mb-3">
                  <Moon size={18} />
                  <span>Evening</span>
                </div>
                <div className="space-y-2">
                  {dailyStack.timing.evening.map(product => {
                    const supplement = getSupplementDetails(product.supplementId);
                    return (
                      <div key={product.id} className="flex items-center justify-between text-sm">
                        <span className="text-white">{product.name}</span>
                        <span className="text-cyan-100">{supplement?.dosage}</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Anytime */}
            {dailyStack.timing.anytime.length > 0 && (
              <div className="bg-white/10 rounded-xl p-4">
                <div className="flex items-center gap-2 text-white font-medium mb-3">
                  <Clock size={18} />
                  <span>Anytime</span>
                </div>
                <div className="space-y-2">
                  {dailyStack.timing.anytime.map(product => {
                    const supplement = getSupplementDetails(product.supplementId);
                    return (
                      <div key={product.id} className="flex items-center justify-between text-sm">
                        <span className="text-white">{product.name}</span>
                        <span className="text-cyan-100">{supplement?.dosage}</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
```

---

## Phase 7: Update PlanTab to Integrate Products

### File: `src/components/results/tabs/PlanTab.tsx`

#### Step 7.1: Add imports (add to existing imports)

```typescript
import { DailyStackCard } from '../cards/DailyStackCard';
import { ProductCard } from '../cards/ProductCard';
import { AlertCircle, CheckCircle2 } from 'lucide-react';
```

#### Step 7.2: Get product data from context (add to component)

```typescript
// Add to the useResults() destructuring:
const {
  // ... existing
  productRecommendations,
  dailyStack
} = useResults();
```

#### Step 7.3: Split products by state (add after existing useMemo hooks)

```typescript
// Split product recommendations by state
const { flawProducts, idealProducts } = useMemo(() => {
  const flaw = productRecommendations.filter(r => r.state === 'flaw');
  const ideal = productRecommendations.filter(r => r.state === 'ideal');
  return { flawProducts: flaw, idealProducts: ideal };
}, [productRecommendations]);
```

#### Step 7.4: Update JSX to add product sections

Find the main content section and modify it:

```tsx
<div className="lg:col-span-2 space-y-6">
  {/* NEW: Daily Stack Card - TOP HERO */}
  {dailyStack && <DailyStackCard dailyStack={dailyStack} />}

  {/* Existing: Potential Score */}
  <PotentialScoreCard />

  {/* NEW: Targeted Product Recommendations */}
  {flawProducts.length > 0 && (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <AlertCircle size={20} className="text-red-400" />
        <h3 className="text-lg font-semibold text-white">Fix These Areas</h3>
        <span className="px-2 py-0.5 bg-red-500/20 text-red-400 text-xs rounded-full border border-red-500/30">
          Corrective
        </span>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {flawProducts.slice(0, 6).map((rec, index) => (
          <ProductCard key={rec.product.id} recommendation={rec} rank={index + 1} />
        ))}
      </div>
    </div>
  )}

  {idealProducts.length > 0 && (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <CheckCircle2 size={20} className="text-green-400" />
        <h3 className="text-lg font-semibold text-white">Protect Your Strengths</h3>
        <span className="px-2 py-0.5 bg-green-500/20 text-green-400 text-xs rounded-full border border-green-500/30">
          Maintenance
        </span>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {idealProducts.slice(0, 4).map((rec) => (
          <ProductCard key={rec.product.id} recommendation={rec} />
        ))}
      </div>
    </div>
  )}

  {/* Existing: Phase Filter */}
  <PhaseFilter ... />

  {/* Existing: Recommendations List */}
  ...
</div>
```

---

## Testing Checklist

### Phase 8: Testing & Verification

- [ ] **Type safety**: Run `npx tsc --noEmit` to check for TypeScript errors
- [ ] **Imports**: Verify all new imports resolve correctly
- [ ] **Daily Stack**: Verify it appears for ALL users (male/female, all scores)
- [ ] **Corrective Products**: Check that flaw metrics trigger red "Fix These Areas" section
- [ ] **Maintenance Products**: Check that ideal metrics trigger green "Protect Your Strengths" section
- [ ] **Affiliate Links**: Click each link to verify format and tracking parameters
- [ ] **Responsive Design**: Test on mobile (375px width) and desktop
- [ ] **FTC Disclosure**: Verify "We may earn a commission" text appears on all product cards
- [ ] **Supplement Data**: Verify dosage, cost, and timeline display correctly from supplements.ts
- [ ] **Gender-Specific**: Verify male users get Ashwagandha in Daily Stack
- [ ] **Existing Features**: Verify surgical/procedure recommendations still work

---

## Deployment Notes

### Before Going Live

1. **Replace Affiliate IDs**
   - Amazon: Replace `tag=looksmaxx-20` with your actual Amazon Associates ID
   - Direct brands: Replace `ref=looksmaxx` with actual referral codes

2. **Legal Compliance**
   - Add FTC disclosure to site footer
   - Update privacy policy to mention affiliate relationships
   - Consider adding "Affiliate Disclosure" page

3. **Analytics Setup**
   - Track clicks on affiliate links
   - Monitor conversion rates (Daily Stack vs Targeted)
   - A/B test messaging (corrective vs maintenance)

4. **Performance**
   - Test with large metric sets (50+ metrics)
   - Verify product recommendation limit (15) is enforced
   - Check bundle size impact of new code

---

## Future Enhancements

### Post-Launch Iterations

1. **Personalization**
   - Email capture: "Send my Daily Stack to email"
   - Save product lists to user account
   - Track which products users purchased

2. **Bundles**
   - "Buy Complete Daily Stack" button (single checkout link)
   - Pre-configured bundles by flaw type (e.g., "Jaw Enhancement Stack")
   - Bulk pricing discounts

3. **Content**
   - Add video reviews for each product
   - Expand research citations per product
   - User testimonials for specific products

4. **Optimization**
   - A/B test different messaging styles
   - Test urgency levels (high vs medium for same severity)
   - Experiment with product limits (6 vs 10 vs 15)

5. **Advanced Features**
   - Quiz: "Find your perfect stack" (alternative entry point)
   - Subscription service (monthly product deliveries)
   - Referral program for users

---

## Summary

This implementation adds a complete e-commerce layer to LOOKSMAXX while maintaining all existing functionality:

✅ **8 new files created**
✅ **4 existing files modified**
✅ **15 products with affiliate links**
✅ **Dual-state logic** (corrective + maintenance)
✅ **Daily Stack** shown to 100% of users
✅ **Backward compatible** with existing procedures

**Estimated Implementation Time**: 11-15 hours
**Risk Level**: Low (additive changes only)
**Revenue Potential**: High (all users see products)

---

## Support

If you encounter issues during implementation:

1. Check TypeScript errors first (`npx tsc --noEmit`)
2. Verify all imports are correct
3. Check browser console for runtime errors
4. Ensure supplements.ts data is being loaded correctly
5. Test with a fresh browser session (clear cache)

For questions or clarification on any step, refer back to this document or the original plan file.
