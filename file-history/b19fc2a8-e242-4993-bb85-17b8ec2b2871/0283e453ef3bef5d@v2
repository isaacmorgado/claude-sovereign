/**
 * Product Registry for Guides System
 * 33 products with multi-region affiliate links and Ross-style taglines
 */

import { GuideProduct, ProductCategory } from '@/types/guides';
import { buildAmazonUrl } from '@/lib/region';

// ============================================
// AMAZON ASIN MAPPING BY REGION
// ============================================

interface ProductASINs {
  us?: string;
  uk?: string;
  de?: string;
  fr?: string;
  au?: string;
}

// Regions that have Amazon stores with ASINs
type AmazonRegion = 'us' | 'uk' | 'de' | 'fr' | 'au';
const AMAZON_REGIONS: AmazonRegion[] = ['us', 'uk', 'de', 'fr', 'au'];

// Helper to build region links from ASINs
function buildRegionLinks(asins: ProductASINs): Record<string, string> {
  const links: Record<string, string> = {};

  AMAZON_REGIONS.forEach(region => {
    const asin = asins[region] || asins.us; // Fallback to US ASIN
    if (asin) {
      links[region] = buildAmazonUrl(asin, region);
    }
  });

  // Asia uses US ASIN on amzn.asia domain
  if (asins.us) {
    links['asia'] = buildAmazonUrl(asins.us, 'asia');
  }

  return links;
}

// ============================================
// PRODUCT DATABASE (33 Products)
// ============================================

export const GUIDE_PRODUCTS: GuideProduct[] = [
  // ============================================
  // HYGIENE (4 products)
  // ============================================
  {
    id: 'tongue_scraper',
    name: 'Stainless Steel Tongue Scraper',
    brand: 'MasterMedi',
    category: 'hygiene',
    tagline: "Your breath is out here committing war crimes and you don't even know it.",
    description: 'Medical-grade stainless steel tongue scraper. Removes bacteria and sulfur compounds that cause bad breath. Takes 10 seconds, lasts forever.',
    priority: 1,
    priceRange: { min: 7, max: 12, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B091G5CH14',
      uk: 'B091G5CH14',
      de: 'B091G5CH14',
      fr: 'B091G5CH14',
      au: 'B091G5CH14',
    }),
    isBaseStack: true,
  },
  {
    id: 'cologne_bleu',
    name: 'Bleu de Chanel EDT',
    brand: 'Chanel',
    category: 'hygiene',
    tagline: "Stop smelling like your high school gym locker. This ain't Axe bodyspray era anymore.",
    description: 'Clean, versatile, universally liked. The safe choice that works for 99% of situations. Not cheap, but compliment-to-dollar ratio is unmatched.',
    priority: 2,
    priceRange: { min: 80, max: 150, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B01N4P3WC3',
      uk: 'B01N4P3WC3',
      de: 'B01N4P3WC3',
      fr: 'B01N4P3WC3',
      au: 'B01N4P3WC3',
    }),
    isBaseStack: false,
  },
  {
    id: 'nitrile_gloves',
    name: 'Nitrile Examination Gloves',
    brand: 'Dealmed',
    category: 'hygiene',
    tagline: "For when you're touching your face with tretinoin hands. Your pillowcase will thank you.",
    description: 'Black nitrile gloves for skincare application. Prevents product waste and keeps actives off your hands.',
    priority: 3,
    priceRange: { min: 12, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B08BZNM84F',
      uk: 'B08BZNM84F',
      de: 'B08BZNM84F',
      fr: 'B08BZNM84F',
      au: 'B08BZNM84F',
    }),
    isBaseStack: false,
  },
  {
    id: 'electric_toothbrush',
    name: 'Oral-B iO Series 5',
    brand: 'Oral-B',
    category: 'hygiene',
    tagline: "Manual toothbrush in 2024 is NPC behavior. Your teeth deserve better.",
    description: 'Pressure sensor prevents gum damage, timer ensures 2-minute brushing. Objectively cleans better than manual brushing.',
    priority: 1,
    priceRange: { min: 100, max: 150, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B09LPHZ2MC',
      uk: 'B09MVKX5KV',
      de: 'B09MVKX5KV',
      fr: 'B09MVKX5KV',
      au: 'B09LPHZ2MC',
    }),
    isBaseStack: true,
  },

  // ============================================
  // GROOMING (5 products)
  // ============================================
  {
    id: 'philips_oneblade',
    name: 'Philips OneBlade Pro',
    brand: 'Philips',
    category: 'grooming',
    tagline: "The Swiss Army knife of face maintenance. Trim, edge, shave—it does everything except your taxes.",
    description: 'Trims any length, shaves close without irritation. Perfect for maintaining stubble at exact length. Replaceable blades last 4 months.',
    priority: 1,
    priceRange: { min: 50, max: 80, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B07W8ZBHSF',
      uk: 'B0B12WJBQ3',
      de: 'B0B12WJBQ3',
      fr: 'B0B12WJBQ3',
      au: 'B07W8ZBHSF',
    }),
    isBaseStack: true,
  },
  {
    id: 'oneblade_blades',
    name: 'OneBlade Replacement Blades (3-Pack)',
    brand: 'Philips',
    category: 'grooming',
    tagline: "Dull blades are giving more irritation than your ex. Stock up.",
    description: 'Genuine Philips replacement blades. Each lasts 3-4 months. Keep 2-3 on hand so you never suffer with a dull blade.',
    priority: 2,
    priceRange: { min: 25, max: 40, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B01D328BG6',
      uk: 'B01D328BG6',
      de: 'B01D328BG6',
      fr: 'B01D328BG6',
      au: 'B01D328BG6',
    }),
    isBaseStack: false,
  },
  {
    id: 'shaving_cream',
    name: 'Cremo Original Shave Cream',
    brand: 'Cremo',
    category: 'grooming',
    tagline: "If you're using canned foam, you're basically dry shaving with extra steps.",
    description: 'Concentrated cream formula provides incredible glide. A dime-size amount covers your entire face. No lather required.',
    priority: 2,
    priceRange: { min: 8, max: 12, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B00JG2URCO',
      uk: 'B00JG2URCO',
      de: 'B00JG2URCO',
      fr: 'B00JG2URCO',
      au: 'B00JG2URCO',
    }),
    isBaseStack: false,
  },
  {
    id: 'tweezers',
    name: 'Tweezerman Slant Tweezers',
    brand: 'Tweezerman',
    category: 'grooming',
    tagline: "Unibrow is not a look, chief. These tweezers are surgical precision.",
    description: "The industry standard. Perfectly aligned tips grab every hair first try. Lifetime sharpening guarantee—you'll never buy another pair.",
    priority: 2,
    priceRange: { min: 20, max: 30, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B000BNKHNG',
      uk: 'B000BNKHNG',
      de: 'B000BNKHNG',
      fr: 'B000BNKHNG',
      au: 'B000BNKHNG',
    }),
    isBaseStack: true,
  },
  {
    id: 'nose_trimmer',
    name: 'Panasonic Nose & Ear Trimmer',
    brand: 'Panasonic',
    category: 'grooming',
    tagline: "Nostril tentacles waving at people mid-conversation is an instant mog-killer.",
    description: 'Wet/dry capable, dual-edge blade gets every angle. Takes 30 seconds once a week. Non-negotiable maintenance.',
    priority: 1,
    priceRange: { min: 15, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B0049KWTOW',
      uk: 'B0049KWTOW',
      de: 'B0049KWTOW',
      fr: 'B0049KWTOW',
      au: 'B0049KWTOW',
    }),
    isBaseStack: true,
  },

  // ============================================
  // SKINCARE (5 products)
  // ============================================
  {
    id: 'cerave_cleanser',
    name: 'CeraVe Foaming Facial Cleanser',
    brand: 'CeraVe',
    category: 'skincare',
    tagline: "Skincare for people who don't want to think about skincare. Dermatologists are boring, but they're right.",
    description: 'pH-balanced, non-stripping, contains ceramides. Works for 90% of people. If it breaks you out, you might be the exception—switch to Hydrating version.',
    priority: 1,
    priceRange: { min: 12, max: 18, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B01N1LL62W',
      uk: 'B01N1LL62W',
      de: 'B07G14BL7M',
      fr: 'B07G14BL7M',
      au: 'B01N1LL62W',
    }),
    isBaseStack: true,
  },
  {
    id: 'aquaphor_lip',
    name: 'Aquaphor Lip Repair',
    brand: 'Aquaphor',
    category: 'skincare',
    tagline: "Crusty lips are sabotaging your face. This is literally 5 dollars. Lock in.",
    description: 'Occlusive healing ointment that actually works. Apply at night for overnight lip repair. Better than any flavored chapstick.',
    priority: 1,
    priceRange: { min: 4, max: 7, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B006IB5T4W',
      uk: 'B0107QP1VE',
      de: 'B0107QP1VE',
      fr: 'B0107QP1VE',
      au: 'B006IB5T4W',
    }),
    isBaseStack: true,
  },
  {
    id: 'cerave_moisturizer',
    name: 'CeraVe PM Facial Moisturizer',
    brand: 'CeraVe',
    category: 'skincare',
    tagline: "Your skin barrier is either your best friend or your worst enemy. Feed it.",
    description: 'Lightweight, non-comedogenic, contains niacinamide for barrier repair. Works AM or PM despite the name. Pairs perfectly with tretinoin.',
    priority: 1,
    priceRange: { min: 14, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B00365DABC',
      uk: 'B00365DABC',
      de: 'B01MSQDQNR',
      fr: 'B01MSQDQNR',
      au: 'B00365DABC',
    }),
    isBaseStack: true,
  },
  {
    id: 'sunscreen_elta',
    name: 'EltaMD UV Clear SPF 46',
    brand: 'EltaMD',
    category: 'skincare',
    tagline: "Sun damage is the biggest scam your skin is running on your future self. Block it.",
    description: 'Lightweight, no white cast, contains niacinamide. The gold standard for acne-prone skin. Yes, you need it even on cloudy days.',
    priority: 1,
    priceRange: { min: 35, max: 45, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B002MSN3QQ',
      uk: 'B002MSN3QQ',
      de: 'B002MSN3QQ',
      fr: 'B002MSN3QQ',
      au: 'B002MSN3QQ',
    }),
    isBaseStack: true,
  },
  {
    id: 'tretinoin_guide',
    name: 'Tretinoin 0.025% Cream',
    brand: 'Generic',
    category: 'skincare',
    tagline: "The nuclear option for skin. Start low, go slow, or enjoy looking like a molting lizard.",
    description: 'Prescription retinoid that actually reverses aging and clears acne. Requires gradual introduction—start 2x/week, work up to nightly over 3 months.',
    priority: 2,
    priceRange: { min: 20, max: 80, currency: 'USD' },
    regionLinks: {},
    directLink: 'https://www.goodrx.com/tretinoin',
    isBaseStack: false,
  },

  // ============================================
  // MISCELLANEOUS (9 products)
  // ============================================
  {
    id: 'water_jug',
    name: 'Half Gallon Water Bottle',
    brand: 'Venture Pal',
    category: 'miscellaneous',
    tagline: "You're not drinking enough water. Yes, you. Your face is literally retaining fluid to compensate.",
    description: 'Time markers keep you on track. BPA-free, leak-proof. Drink one full jug by 5pm, another by bedtime. Non-negotiable.',
    priority: 1,
    priceRange: { min: 15, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B09D3VZ79R',
      uk: 'B09D3VZ79R',
      de: 'B09D3VZ79R',
      fr: 'B09D3VZ79R',
      au: 'B09D3VZ79R',
    }),
    isBaseStack: true,
  },
  {
    id: 'jaw_exerciser',
    name: 'Jawliner Jawline Exerciser',
    brand: 'Jawliner',
    category: 'miscellaneous',
    tagline: "Listen, I need you to put down the mastic gum for a second if your jaw already looks like Minecraft Steve.",
    description: 'Silicone jaw exerciser in 3 resistance levels. Start with beginner, progress monthly. 10-15 minutes daily. Check your FWHR—if it\'s already high, skip this.',
    priority: 3,
    priceRange: { min: 15, max: 30, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B08GY61JZS',
      uk: 'B08GY61JZS',
      de: 'B08GY61JZS',
      fr: 'B08GY61JZS',
      au: 'B08GY61JZS',
    }),
    isBaseStack: false,
  },
  {
    id: 'minoxidil',
    name: 'Kirkland Minoxidil 5% Solution',
    brand: 'Kirkland',
    category: 'miscellaneous',
    tagline: "Rogaine is the same formula at 3x the price. Don't be a marketing victim.",
    description: 'Apply 1ml to scalp or beard area twice daily. Takes 3-6 months for visible results. Shedding phase is normal—push through.',
    priority: 2,
    priceRange: { min: 25, max: 50, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B0CSXVT3XZ',
      uk: 'B0CSXVT3XZ',
      de: 'B0CSXVT3XZ',
      fr: 'B0CSXVT3XZ',
      au: 'B0CSXVT3XZ',
    }),
    isBaseStack: false,
  },
  {
    id: 'dermaroller',
    name: '0.5mm Derma Roller',
    brand: 'Sdara',
    category: 'miscellaneous',
    tagline: "Stabbing your scalp to grow hair sounds insane, but the science is actually solid.",
    description: 'Use 1x per week on scalp to enhance minoxidil absorption. Replace every 3 months. Sanitize with isopropyl alcohol before each use.',
    priority: 2,
    priceRange: { min: 10, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B07Y1N4VLC',
      uk: 'B07Y1N4VLC',
      de: 'B07Y1N4VLC',
      fr: 'B07Y1N4VLC',
      au: 'B07Y1N4VLC',
    }),
    isBaseStack: false,
  },
  {
    id: 'posture_corrector',
    name: 'Posture Corrector',
    brand: 'Mercase',
    category: 'miscellaneous',
    tagline: "You're reading this with your neck at a 45-degree angle. I know because I am too.",
    description: 'Wear 30 mins daily to retrain posture. Not a permanent fix—you need to strengthen upper back. But good for building awareness.',
    priority: 3,
    priceRange: { min: 15, max: 30, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B07P6D23C2',
      uk: 'B07P6D23C2',
      de: 'B07P6D23C2',
      fr: 'B07P6D23C2',
      au: 'B07P6D23C2',
    }),
    isBaseStack: false,
  },
  {
    id: 'sleep_mask',
    name: 'Manta Sleep Mask',
    brand: 'Manta',
    category: 'miscellaneous',
    tagline: "Your sleep schedule is committing crimes against your face and you don't even know it.",
    description: 'Zero light leakage, zero pressure on eyes. Adjustable eye cups work for all face shapes. Essential for deep sleep optimization.',
    priority: 2,
    priceRange: { min: 30, max: 40, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B07GXQX1GD',
      uk: 'B07GXQX1GD',
      de: 'B07GXQX1GD',
      fr: 'B07GXQX1GD',
      au: 'B07GXQX1GD',
    }),
    isBaseStack: false,
  },
  {
    id: 'silk_pillowcase',
    name: 'Silk Pillowcase',
    brand: 'Alaska Bear',
    category: 'miscellaneous',
    tagline: "Cotton pillowcases are giving your skin friction damage while you sleep. Upgrade.",
    description: '100% mulberry silk reduces friction on skin and hair. Less sleep creases, less frizz. Wash weekly on delicate cycle.',
    priority: 3,
    priceRange: { min: 20, max: 35, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B00IJBTAG4',
      uk: 'B00IJBTAG4',
      de: 'B00IJBTAG4',
      fr: 'B00IJBTAG4',
      au: 'B00IJBTAG4',
    }),
    isBaseStack: false,
  },
  {
    id: 'blue_light_glasses',
    name: 'Blue Light Blocking Glasses',
    brand: 'ANRRI',
    category: 'miscellaneous',
    tagline: "Screen time at 11pm is telling your brain it's noon. These help, but also maybe just go to bed.",
    description: 'Wear 2 hours before bed to reduce blue light exposure. Helps with sleep quality. Looks slightly ridiculous, works anyway.',
    priority: 3,
    priceRange: { min: 15, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B07KFXBDB8',
      uk: 'B07KFXBDB8',
      de: 'B07KFXBDB8',
      fr: 'B07KFXBDB8',
      au: 'B07KFXBDB8',
    }),
    isBaseStack: false,
  },
  {
    id: 'food_scale',
    name: 'Digital Food Scale',
    brand: 'Etekcity',
    category: 'miscellaneous',
    tagline: "Eyeballing portions is why you're at 18% body fat. At 11%, you ARE the good lighting.",
    description: 'Accurate to 0.1g, tare function for easy measuring. Track protein intake properly. Essential for cutting to lean levels.',
    priority: 2,
    priceRange: { min: 10, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B0113UZJE2',
      uk: 'B0113UZJE2',
      de: 'B0113UZJE2',
      fr: 'B0113UZJE2',
      au: 'B0113UZJE2',
    }),
    isBaseStack: false,
  },

  // ============================================
  // SUPPLEMENTS (10 products)
  // ============================================
  {
    id: 'creatine_mono',
    name: 'Creatine Monohydrate',
    brand: 'Optimum Nutrition',
    category: 'supplements',
    tagline: "The only supplement that actually does what it says. You'll look slightly bigger immediately. Yes, it's water. No, nobody can tell.",
    description: '5g daily, no loading phase needed. Cognitive benefits too—studies show improved memory and processing speed. Costs $0.10/day. Lock in.',
    priority: 1,
    priceRange: { min: 20, max: 35, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B002DYIZEO',
      uk: 'B002DYIZEO',
      de: 'B002DYIZEO',
      fr: 'B002DYIZEO',
      au: 'B002DYIZEO',
    }),
    isBaseStack: true,
  },
  {
    id: 'vitamin_d3_k2',
    name: 'Vitamin D3+K2',
    brand: 'Sports Research',
    category: 'supplements',
    tagline: "Unless you work outside shirtless in summer, you're deficient. Get your levels checked, then take this.",
    description: 'D3 for bone density and immune function, K2 directs calcium to bones (not arteries). 5000 IU D3 + 100mcg K2 daily.',
    priority: 1,
    priceRange: { min: 18, max: 28, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B01N5P3E9X',
      uk: 'B01N5P3E9X',
      de: 'B01N5P3E9X',
      fr: 'B01N5P3E9X',
      au: 'B01N5P3E9X',
    }),
    isBaseStack: true,
  },
  {
    id: 'magnesium_glycinate',
    name: 'Magnesium Glycinate',
    brand: "Doctor's Best",
    category: 'supplements',
    tagline: "Most people are deficient and don't know it. Fixes sleep, reduces anxiety, stops eye twitches.",
    description: 'Glycinate form for maximum absorption and minimal gut issues. 200-400mg before bed. The best sleep upgrade under $15.',
    priority: 1,
    priceRange: { min: 12, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B000BD0RT0',
      uk: 'B000BD0RT0',
      de: 'B000BD0RT0',
      fr: 'B000BD0RT0',
      au: 'B000BD0RT0',
    }),
    isBaseStack: true,
  },
  {
    id: 'omega3_fish_oil',
    name: 'Omega-3 Fish Oil',
    brand: 'Nordic Naturals',
    category: 'supplements',
    tagline: "Your brain is 60% fat. Feed it the good stuff, not the seed oil garbage.",
    description: 'High EPA/DHA concentration. Take 2-3 capsules with food. Reduces inflammation, supports brain function, helps skin glow.',
    priority: 1,
    priceRange: { min: 25, max: 40, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B002CQU564',
      uk: 'B002CQU564',
      de: 'B002CQU564',
      fr: 'B002CQU564',
      au: 'B002CQU564',
    }),
    isBaseStack: true,
  },
  {
    id: 'collagen_peptides',
    name: 'Collagen Peptides',
    brand: 'Vital Proteins',
    category: 'supplements',
    tagline: "Your body stops making collagen at 25. After that, you're just slowly deflating unless you supplement.",
    description: 'Type I & III collagen for skin elasticity and joint health. 20g daily in coffee or smoothie. Tasteless, dissolves instantly.',
    priority: 2,
    priceRange: { min: 25, max: 45, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B00K9XZTW0',
      uk: 'B00K9XZTW0',
      de: 'B00K9XZTW0',
      fr: 'B00K9XZTW0',
      au: 'B00K9XZTW0',
    }),
    isBaseStack: true,
  },
  {
    id: 'ashwagandha_ksm66',
    name: 'Ashwagandha KSM-66',
    brand: 'NOW Foods',
    category: 'supplements',
    tagline: "Cortisol is wrecking your gains and your face. This adaptogen tells stress to calm down.",
    description: 'KSM-66 is the gold standard extract. 600mg daily reduces cortisol, improves sleep, boosts testosterone (in men). Take in evening.',
    priority: 2,
    priceRange: { min: 15, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B01D0YJAD8',
      uk: 'B01D0YJAD8',
      de: 'B01D0YJAD8',
      fr: 'B01D0YJAD8',
      au: 'B01D0YJAD8',
    }),
    isBaseStack: false,
  },
  {
    id: 'zinc_picolinate',
    name: 'Zinc Picolinate 30mg',
    brand: 'Thorne',
    category: 'supplements',
    tagline: "Low zinc = low T = low everything. Get your levels checked, most gym bros are deficient.",
    description: 'Picolinate form for superior absorption. Essential for testosterone, immune function, and skin healing. Take with food to avoid nausea.',
    priority: 2,
    priceRange: { min: 12, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B000FGWDQS',
      uk: 'B000FGWDQS',
      de: 'B000FGWDQS',
      fr: 'B000FGWDQS',
      au: 'B000FGWDQS',
    }),
    isBaseStack: false,
  },
  {
    id: 'vitamin_c_liposomal',
    name: 'Vitamin C (Liposomal)',
    brand: 'LivOn Labs',
    category: 'supplements',
    tagline: "Regular vitamin C has like 20% absorption. Liposomal goes straight into your cells.",
    description: 'Liposomal delivery system massively increases absorption. 1000mg daily for collagen synthesis and antioxidant protection.',
    priority: 2,
    priceRange: { min: 30, max: 45, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B000CD9XGC',
      uk: 'B000CD9XGC',
      de: 'B000CD9XGC',
      fr: 'B000CD9XGC',
      au: 'B000CD9XGC',
    }),
    isBaseStack: false,
  },
  {
    id: 'melatonin_lowdose',
    name: 'Melatonin 0.5mg',
    brand: 'Life Extension',
    category: 'supplements',
    tagline: "More is not better. 0.3-0.5mg works. Those 10mg pills are giving you grogginess, not sleep.",
    description: 'Low-dose melatonin is more effective than high-dose. Take 30 mins before bed. Use for resetting circadian rhythm, not every night.',
    priority: 3,
    priceRange: { min: 8, max: 15, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B001LXOHCE',
      uk: 'B001LXOHCE',
      de: 'B001LXOHCE',
      fr: 'B001LXOHCE',
      au: 'B001LXOHCE',
    }),
    isBaseStack: false,
  },
  {
    id: 'nmn_supplement',
    name: 'NMN 250mg',
    brand: 'ProHealth Longevity',
    category: 'supplements',
    tagline: "NAD+ declines 50% by age 50. This is the precursor your cells use to make more. Longevity science, not bro science.",
    description: 'Nicotinamide Mononucleotide for cellular energy and DNA repair. 250-500mg daily. More relevant after 30 when NAD+ starts declining.',
    priority: 3,
    priceRange: { min: 40, max: 70, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B08QRYWLF9',
      uk: 'B08QRYWLF9',
      de: 'B08QRYWLF9',
      fr: 'B08QRYWLF9',
      au: 'B08QRYWLF9',
    }),
    directLink: 'https://www.prohealthlongevity.com/products/nmn-pro-500?ref=looksmaxx',
    isBaseStack: false,
  },
];

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Get product by ID
 */
export function getGuideProductById(id: string): GuideProduct | undefined {
  return GUIDE_PRODUCTS.find(p => p.id === id);
}

/**
 * Get all products in a category
 */
export function getGuideProductsByCategory(category: ProductCategory): GuideProduct[] {
  return GUIDE_PRODUCTS
    .filter(p => p.category === category)
    .sort((a, b) => a.priority - b.priority);
}

/**
 * Get all base stack products (essentials for everyone)
 */
export function getBaseStackProducts(): GuideProduct[] {
  return GUIDE_PRODUCTS
    .filter(p => p.isBaseStack)
    .sort((a, b) => a.priority - b.priority);
}

/**
 * Get products by priority level
 */
export function getGuideProductsByPriority(priority: number): GuideProduct[] {
  return GUIDE_PRODUCTS.filter(p => p.priority === priority);
}

/**
 * Get all unique categories with product counts
 */
export function getProductCategories(): Array<{ category: ProductCategory; count: number }> {
  const categories: ProductCategory[] = ['hygiene', 'grooming', 'skincare', 'miscellaneous', 'supplements'];

  return categories.map(category => ({
    category,
    count: GUIDE_PRODUCTS.filter(p => p.category === category).length,
  }));
}

/**
 * Get products by array of IDs (preserves order)
 */
export function getGuideProductsByIds(ids: string[]): GuideProduct[] {
  return ids
    .map(id => getGuideProductById(id))
    .filter((p): p is GuideProduct => p !== undefined);
}

/**
 * Search products by name or description
 */
export function searchGuideProducts(query: string): GuideProduct[] {
  const lowered = query.toLowerCase();
  return GUIDE_PRODUCTS.filter(p =>
    p.name.toLowerCase().includes(lowered) ||
    p.description.toLowerCase().includes(lowered) ||
    p.tagline.toLowerCase().includes(lowered) ||
    (p.brand && p.brand.toLowerCase().includes(lowered))
  );
}

/**
 * Get total product count
 */
export function getTotalProductCount(): number {
  return GUIDE_PRODUCTS.length;
}

/**
 * Get category display info
 */
export function getCategoryDisplayInfo(category: ProductCategory): {
  name: string;
  icon: string;
  description: string;
} {
  const info: Record<ProductCategory, { name: string; icon: string; description: string }> = {
    hygiene: {
      name: 'Hygiene',
      icon: 'Sparkles',
      description: 'Fundamentals of not repelling people',
    },
    grooming: {
      name: 'Grooming',
      icon: 'Scissors',
      description: 'Tools for precision face maintenance',
    },
    skincare: {
      name: 'Skincare',
      icon: 'Droplet',
      description: 'Your skin is your face. Treat it right.',
    },
    miscellaneous: {
      name: 'Miscellaneous',
      icon: 'Package',
      description: 'The supporting cast of your glow-up',
    },
    supplements: {
      name: 'Supplements',
      icon: 'Pill',
      description: 'Fill the gaps your diet is missing',
    },
  };

  return info[category];
}
