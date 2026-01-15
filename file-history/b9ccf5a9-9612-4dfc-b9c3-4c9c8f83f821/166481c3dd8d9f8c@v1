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
  return ids.map(id => getProductById(id)).filter((p): p is Product => p !== undefined);
}
