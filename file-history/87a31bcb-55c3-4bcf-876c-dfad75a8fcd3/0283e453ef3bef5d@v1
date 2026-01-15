/**
 * Product Registry for Guides System
 * 73 products with multi-region affiliate links and Ross-style taglines
 * Categories: hygiene, grooming, skincare, miscellaneous, supplements, hair, beard, teeth, kbeauty, hormonal, surgery
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
    imageUrl: 'https://images.unsplash.com/photo-1609587312208-cea54be969e7?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1559467234-f7c94a27c96c?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1621607505837-2456a9e7b4e7?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1572635196243-4dd75fbdbd7f?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1619451334792-150fd785ee74?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1556229012-50dd2016dbfb?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'gum_mastic',
    name: 'Mastic Gum (Greek Chios)',
    brand: 'Chios Mastiha',
    category: 'miscellaneous',
    tagline: "The OG jaw workout. Greeks have been doing this for centuries. Your masseter will hate you.",
    description: 'Natural tree resin from Chios island, Greece. Harder than regular gum—forces masseter development. 30-60 minutes daily. Jaw pump is real.',
    priority: 3,
    priceRange: { min: 15, max: 35, currency: 'USD' },
    regionLinks: buildRegionLinks({
      us: 'B07V5CTTRB',
      uk: 'B07V5CTTRB',
      de: 'B07V5CTTRB',
      fr: 'B07V5CTTRB',
      au: 'B07V5CTTRB',
    }),
    imageUrl: 'https://images.unsplash.com/photo-1571844307880-751c6d86f3f3?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1585751119414-ef2636f8aede?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1531353826977-0941b4779a1c?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1574258495973-f010dfbb5371?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1606917945122-6ea0c8f3bf1f?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1579722820308-d74e571900a9?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1559757175-7cb056fba93d?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1607004468138-e7e23ea26947?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1587049352847-49f9a74abdd3?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1585435557343-3b348031d6c9?w=200&h=200&fit=crop',
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
    imageUrl: 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=200&h=200&fit=crop',
    isBaseStack: false,
  },

  // ============================================
  // HAIR (8 products) - New
  // ============================================
  {
    id: 'kirkland_minoxidil',
    name: 'Kirkland Minoxidil 5%',
    brand: 'Kirkland',
    category: 'hair',
    tagline: "The Big 3 starts here. At $4/month, there's no excuse not to try it if you're receding.",
    description: '6-month supply of topical minoxidil. Apply to scalp 2x daily. Results in 4-6 months. The cost-effective gold standard.',
    priority: 1,
    priceRange: { min: 25, max: 40, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00NWQB0UM', uk: 'B00NWQB0UM', de: 'B00NWQB0UM' }),
    imageUrl: 'https://images.unsplash.com/photo-1585232004423-244e0e6904e3?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'nizoral_shampoo',
    name: 'Nizoral 2% Ketoconazole Shampoo',
    brand: 'Nizoral',
    category: 'hair',
    tagline: "Part of the Big 3. This isn't just dandruff shampoo—it's a mild DHT blocker for your scalp.",
    description: 'Use 2-3x per week. Leave on scalp 3-5 mins before rinsing. Reduces scalp inflammation and DHT at the follicle level.',
    priority: 1,
    priceRange: { min: 15, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00AINMFAC', uk: 'B00AINMFAC', de: 'B00AINMFAC' }),
    imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'scalp_dermaroller',
    name: 'Scalp Derma Roller 1.5mm',
    brand: 'Koi Beauty',
    category: 'hair',
    tagline: "Microneedling for your scalp. Sounds brutal, boosts minoxidil absorption by 4x.",
    description: 'Use once weekly on thinning areas. Creates microchannels that enhance topical absorption. Replace every 2-3 months.',
    priority: 1,
    priceRange: { min: 12, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B07B3QPMRY', uk: 'B07B3QPMRY', de: 'B07B3QPMRY' }),
    imageUrl: 'https://images.unsplash.com/photo-1576426863848-c21f53c60b19?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'biotin_10000',
    name: 'Biotin 10,000mcg',
    brand: 'Sports Research',
    category: 'hair',
    tagline: "The most overhyped hair supplement. Won't regrow hair, but deficiency causes shedding.",
    description: 'Take daily with food. Supports keratin production. More useful for nails than hair honestly, but cheap insurance.',
    priority: 2,
    priceRange: { min: 15, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00K0PQB0E', uk: 'B00K0PQB0E', de: 'B00K0PQB0E' }),
    imageUrl: 'https://images.unsplash.com/photo-1550572017-4e8f0b0c0f7b?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'rosemary_oil',
    name: 'Rosemary Essential Oil',
    brand: 'Handcraft',
    category: 'hair',
    tagline: "Studies show it's as effective as minoxidil for some people. Mix with carrier oil, massage into scalp.",
    description: 'Mix 5 drops with 1 tbsp carrier oil. Massage into scalp, leave 30+ mins or overnight. Cheaper natural alternative.',
    priority: 2,
    priceRange: { min: 10, max: 18, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B08Y8M2V6S', uk: 'B08Y8M2V6S', de: 'B08Y8M2V6S' }),
    imageUrl: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'rogaine_foam',
    name: 'Rogaine Foam 5%',
    brand: 'Rogaine',
    category: 'hair',
    tagline: "Brand name minoxidil. Same active ingredient, easier foam application, 3x the price.",
    description: 'Foam dries faster, less greasy than liquid. Worth it if liquid irritates your scalp or you hate the dripping.',
    priority: 2,
    priceRange: { min: 40, max: 60, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00ITTO2YU', uk: 'B00ITTO2YU', de: 'B00ITTO2YU' }),
    imageUrl: 'https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'laser_hair_cap',
    name: 'Laser Hair Growth Cap',
    brand: 'iRestore',
    category: 'hair',
    tagline: "LLLT for your head. FDA-cleared, questionable ROI. Rich guy addition to the stack.",
    description: 'Low-level laser therapy stimulates follicles. Use 25 mins every other day. Evidence is decent but pricey.',
    priority: 3,
    priceRange: { min: 600, max: 800, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B01M0QQPPT', uk: 'B01M0QQPPT' }),
    imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'scalp_massager',
    name: 'Scalp Massager Shampoo Brush',
    brand: 'MAXSOFT',
    category: 'hair',
    tagline: "Feels amazing, increases blood flow to scalp. Won't regrow hair but might slow loss.",
    description: 'Use during shampoo. Soft silicone bristles, exfoliates scalp, removes buildup. $8 for scalp tingles.',
    priority: 2,
    priceRange: { min: 8, max: 12, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B074ZDXFL6', uk: 'B074ZDXFL6', de: 'B074ZDXFL6' }),
    imageUrl: 'https://images.unsplash.com/photo-1522338242042-2d1c59e088a4?w=200&h=200&fit=crop',
    isBaseStack: false,
  },

  // ============================================
  // BEARD (5 products) - New
  // ============================================
  {
    id: 'beard_dermaroller',
    name: 'Beard Derma Roller 0.5mm',
    brand: 'Sdara',
    category: 'beard',
    tagline: "Roll tiny needles on your face for beard gains. Yes it works. No it doesn't hurt that much.",
    description: 'Use 1-2x weekly before minoxidil application. 0.5mm depth is the sweet spot for facial hair stimulation.',
    priority: 1,
    priceRange: { min: 12, max: 18, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B076Q4HJD5', uk: 'B076Q4HJD5', de: 'B076Q4HJD5' }),
    imageUrl: 'https://images.unsplash.com/photo-1621607505837-2456a9e7b4e7?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'beard_oil_honest',
    name: 'Beard Growth Oil',
    brand: 'Honest Amish',
    category: 'beard',
    tagline: "For when you actually have a beard to maintain. Keeps it soft, smells like a lumberjack.",
    description: 'Apply a few drops after showering. Works into skin and hair. Organic oils nourish both beard and skin underneath.',
    priority: 2,
    priceRange: { min: 15, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00F9QBGZI', uk: 'B00F9QBGZI', de: 'B00F9QBGZI' }),
    imageUrl: 'https://images.unsplash.com/photo-1621607505837-2456a9e7b4e7?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'beard_balm',
    name: 'Beard Balm',
    brand: 'Viking Revolution',
    category: 'beard',
    tagline: "Oil for moisture, balm for control. Tames wild beard hairs, adds light hold.",
    description: 'Use after oil for styling hold. Natural ingredients, subtle scent. Works best on beards 1+ inch long.',
    priority: 2,
    priceRange: { min: 12, max: 18, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B071GGXWJK', uk: 'B071GGXWJK', de: 'B071GGXWJK' }),
    imageUrl: 'https://images.unsplash.com/photo-1594852279555-c7b6f2fa4c90?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'beard_trimmer_philips',
    name: 'Beard Trimmer',
    brand: 'Philips Norelco',
    category: 'beard',
    tagline: "Precision guards for that perfect stubble length. 0.4mm increments so you're not guessing.",
    description: 'Cordless, 20 length settings, self-sharpening blades. The workhorse of stubble maintenance.',
    priority: 2,
    priceRange: { min: 50, max: 80, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B07H4QRMQJ', uk: 'B07H4QRMQJ', de: 'B07H4QRMQJ' }),
    imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'jawline_exerciser_pro',
    name: 'Jawline Exerciser',
    brand: 'JawlineMe',
    category: 'beard',
    tagline: "Chew your way to a bigger masseter. Results vary, TMJ risk if you overdo it.",
    description: 'Resistance training for your jaw. Start with lighter resistance, progress slowly. Not a substitute for low body fat.',
    priority: 3,
    priceRange: { min: 15, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B08R5ZQFR7', uk: 'B08R5ZQFR7' }),
    imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
    isBaseStack: false,
  },

  // ============================================
  // TEETH (6 products) - New
  // ============================================
  {
    id: 'crest_whitestrips',
    name: 'Crest 3D Whitestrips Pro',
    brand: 'Crest',
    category: 'teeth',
    tagline: "Yellow teeth are costing you more than you think. $40 for a smile upgrade is a no-brainer.",
    description: '20 treatments, 30 min each. Same peroxide as dentist whitening, fraction of the cost. Manage sensitivity with breaks.',
    priority: 1,
    priceRange: { min: 40, max: 55, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00336EUTK', uk: 'B00336EUTK', de: 'B00336EUTK' }),
    imageUrl: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'waterpik_flosser',
    name: 'Waterpik Water Flosser',
    brand: 'Waterpik',
    category: 'teeth',
    tagline: "Flossing is non-negotiable but string floss sucks. This makes it actually happen.",
    description: 'Pressurized water removes what brushing misses. Use daily after brushing. Your gums will stop bleeding in a week.',
    priority: 1,
    priceRange: { min: 50, max: 80, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B002QAFJMA', uk: 'B002QAFJMA', de: 'B002QAFJMA' }),
    imageUrl: 'https://images.unsplash.com/photo-1571942676516-bcab84649e44?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'retainer_cleaner',
    name: 'Retainer Cleaner Tablets',
    brand: 'Retainer Brite',
    category: 'teeth',
    tagline: "Your retainer is growing bacteria colonies. Drop a tablet, soak 15 min, crisis averted.",
    description: 'Works on retainers, night guards, and aligners. Daily use prevents buildup and keeps them from smelling like death.',
    priority: 2,
    priceRange: { min: 15, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B003Z66O22', uk: 'B003Z66O22', de: 'B003Z66O22' }),
    imageUrl: 'https://images.unsplash.com/photo-1609840114035-3c981b782dfe?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'whitening_pen',
    name: 'Whitening Pen',
    brand: 'AuraGlow',
    category: 'teeth',
    tagline: "Touch-up whitening for between strip sessions. Keep in your bag for emergencies.",
    description: 'Brush-on gel, leave 1 hour. Lower concentration than strips, good for maintenance. Travel-friendly.',
    priority: 2,
    priceRange: { min: 20, max: 30, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B07L4GFJ7T', uk: 'B07L4GFJ7T' }),
    imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'copper_tongue_scraper',
    name: 'Copper Tongue Scraper',
    brand: 'MasterMedi',
    category: 'teeth',
    tagline: "Copper is naturally antimicrobial. Kills bacteria while scraping. Ancient Ayurvedic move.",
    description: 'Use before brushing, morning routine. Copper version lasts forever and has antibacterial properties.',
    priority: 2,
    priceRange: { min: 8, max: 12, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B07D37GTWS', uk: 'B07D37GTWS', de: 'B07D37GTWS' }),
    imageUrl: 'https://images.unsplash.com/photo-1609587312208-cea54be969e7?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'oralb_electric_pro',
    name: 'Oral-B iO Series 9',
    brand: 'Oral-B',
    category: 'teeth',
    tagline: "The premium electric toothbrush. AI tracking, pressure sensor, 7 modes. Overkill but nice.",
    description: 'Top-tier Oral-B with app connectivity. Tracks brushing zones, optimizes technique. For teeth obsessives.',
    priority: 3,
    priceRange: { min: 200, max: 300, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B07RBYQ6FC', uk: 'B07RBYQ6FC', de: 'B07RBYQ6FC' }),
    imageUrl: 'https://images.unsplash.com/photo-1559467234-f7c94a27c96c?w=200&h=200&fit=crop',
    isBaseStack: false,
  },

  // ============================================
  // K-BEAUTY (8 products) - New
  // ============================================
  {
    id: 'cosrx_snail_mucin',
    name: 'COSRX Snail Mucin Essence',
    brand: 'COSRX',
    category: 'kbeauty',
    tagline: "Yes, it's snail slime. Yes, it works. Your skin will glow like a K-drama star.",
    description: '96% snail mucin for hydration and repair. Apply after cleansing, before moisturizer. Plumps and heals.',
    priority: 1,
    priceRange: { min: 20, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00PBX3L7K', uk: 'B00PBX3L7K', de: 'B00PBX3L7K' }),
    imageUrl: 'https://images.unsplash.com/photo-1570194065650-d99fb4b38b17?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'klairs_toner',
    name: 'Klairs Supple Preparation Toner',
    brand: 'Klairs',
    category: 'kbeauty',
    tagline: "The 7-skin method starts here. Layer this toner for that 'chok chok' hydrated look.",
    description: 'Hydrating toner with amino acids. Pat 3-7 layers for maximum effect. The K-beauty glass skin secret.',
    priority: 1,
    priceRange: { min: 22, max: 28, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B07BTJLLZY', uk: 'B07BTJLLZY', de: 'B07BTJLLZY' }),
    imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'hada_labo_premium',
    name: 'Hada Labo Premium Lotion',
    brand: 'Hada Labo',
    category: 'kbeauty',
    tagline: "5 types of hyaluronic acid in one bottle. Japanese skincare perfection for $15.",
    description: 'Multi-weight HA pulls water into skin at different depths. Apply to damp skin, seal with moisturizer.',
    priority: 1,
    priceRange: { min: 15, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B074GX619Q', uk: 'B074GX619Q', de: 'B074GX619Q' }),
    imageUrl: 'https://images.unsplash.com/photo-1617897903246-719242758050?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'banila_cleansing_balm',
    name: 'Banila Co Clean It Zero',
    brand: 'Banila Co',
    category: 'kbeauty',
    tagline: "Double cleansing step 1. This balm melts off sunscreen and makeup like nothing else.",
    description: 'Massage onto dry skin, emulsifies with water. Removes everything including stubborn SPF. Follow with water-based cleanser.',
    priority: 2,
    priceRange: { min: 20, max: 25, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00LNQ8SZO', uk: 'B00LNQ8SZO', de: 'B00LNQ8SZO' }),
    imageUrl: 'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'cosrx_aha_bha_toner',
    name: 'COSRX AHA/BHA Clarifying Toner',
    brand: 'COSRX',
    category: 'kbeauty',
    tagline: "Low-percentage exfoliating toner for daily use. Preps skin for actives, unclogs pores.",
    description: 'Use after cleansing to balance pH. Contains natural AHA/BHA for gentle exfoliation. Daily use safe.',
    priority: 2,
    priceRange: { min: 15, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00OZ9WOD8', uk: 'B00OZ9WOD8', de: 'B00OZ9WOD8' }),
    imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'boj_glow_serum',
    name: 'Beauty of Joseon Glow Serum',
    brand: 'Beauty of Joseon',
    category: 'kbeauty',
    tagline: "Propolis + niacinamide = instant glow. The Instagram filter in a bottle.",
    description: 'Propolis for glow and healing, niacinamide for pores. Use morning and night. Affordable glow serum.',
    priority: 2,
    priceRange: { min: 15, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B08WRWP8JY', uk: 'B08WRWP8JY', de: 'B08WRWP8JY' }),
    imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'laneige_cream_skin',
    name: 'Laneige Cream Skin Refiner',
    brand: 'Laneige',
    category: 'kbeauty',
    tagline: "Toner + moisturizer hybrid. For when you want the K-beauty routine in one step.",
    description: 'Creamy toner that hydrates like a moisturizer. Great for minimal routines or layering. Dewy finish.',
    priority: 2,
    priceRange: { min: 30, max: 40, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B07QX44VYZ', uk: 'B07QX44VYZ', de: 'B07QX44VYZ' }),
    imageUrl: 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'missha_bb_cream',
    name: 'Missha M Perfect Cover BB Cream',
    brand: 'Missha',
    category: 'kbeauty',
    tagline: "The OG K-beauty BB cream. Evens tone without looking like makeup. SPF 42 included.",
    description: 'Light coverage, natural finish, sun protection. Multiple shades. The daily driver for good skin days.',
    priority: 3,
    priceRange: { min: 15, max: 20, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B004ALXQSO', uk: 'B004ALXQSO', de: 'B004ALXQSO' }),
    imageUrl: 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=200&h=200&fit=crop',
    isBaseStack: false,
  },

  // ============================================
  // HORMONAL/PCOS (5 products) - New
  // ============================================
  {
    id: 'spearmint_tea',
    name: 'Spearmint Tea',
    brand: 'Traditional Medicinals',
    category: 'hormonal',
    tagline: "Natural anti-androgen. 2 cups daily reduces hormonal acne and excess facial hair.",
    description: 'Studies show spearmint lowers testosterone in women. Gentle, tasty, evidence-based. For hormonal skin issues.',
    priority: 1,
    priceRange: { min: 5, max: 8, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B0009F3POO', uk: 'B0009F3POO', de: 'B0009F3POO' }),
    imageUrl: 'https://images.unsplash.com/photo-1597318181409-cf64d0b5d8a2?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'inositol_ovasitol',
    name: 'Inositol (Myo + D-Chiro)',
    brand: 'Ovasitol',
    category: 'hormonal',
    tagline: "The PCOS supplement with actual research behind it. Improves insulin sensitivity and hormone balance.",
    description: '40:1 ratio myo-inositol to D-chiro-inositol. Take 2x daily. Shown to improve acne, hair, and cycles in PCOS.',
    priority: 1,
    priceRange: { min: 40, max: 60, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B074KJ6RJW', uk: 'B074KJ6RJW' }),
    imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'azelaic_acid',
    name: 'Azelaic Acid 10%',
    brand: "Paula's Choice",
    category: 'hormonal',
    tagline: "Pregnancy-safe retinol alternative. Anti-inflammatory, kills acne bacteria, fades dark spots.",
    description: 'Use morning or night. Safe during pregnancy/breastfeeding. Treats rosacea and hormonal acne effectively.',
    priority: 1,
    priceRange: { min: 35, max: 45, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B06VT315YJ', uk: 'B06VT315YJ', de: 'B06VT315YJ' }),
    imageUrl: 'https://images.unsplash.com/photo-1617897903246-719242758050?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'dim_supplement',
    name: 'DIM Supplement',
    brand: 'Smoky Mountain',
    category: 'hormonal',
    tagline: "Diindolylmethane—the broccoli extract that helps metabolize estrogen. Balances hormones naturally.",
    description: 'Take 100-200mg daily. Supports estrogen metabolism. Can help with hormonal acne and mood. Derived from cruciferous veggies.',
    priority: 2,
    priceRange: { min: 20, max: 30, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00K8JI3V4', uk: 'B00K8JI3V4' }),
    imageUrl: 'https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'braun_ipl',
    name: 'IPL Hair Removal Device',
    brand: 'Braun',
    category: 'hormonal',
    tagline: "Permanent-ish hair reduction at home. For hirsutism from PCOS or just general hair removal.",
    description: 'Intense pulsed light for at-home laser-like hair removal. 6-12 weeks for results. Works best on light skin/dark hair.',
    priority: 3,
    priceRange: { min: 300, max: 400, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B07YR7G8LS', uk: 'B07YR7G8LS', de: 'B07YR7G8LS' }),
    imageUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200&h=200&fit=crop',
    isBaseStack: false,
  },

  // ============================================
  // SURGERY RECOVERY (3 products) - New
  // ============================================
  {
    id: 'arnica_gel',
    name: 'Arnica Montana Gel',
    brand: 'Boiron',
    category: 'surgery',
    tagline: "Pre and post-procedure essential. Reduces bruising, swelling, and speeds healing.",
    description: 'Apply to bruised areas 2-3x daily. Start 3 days before procedure, continue 1-2 weeks after. Homeopathic but works.',
    priority: 1,
    priceRange: { min: 10, max: 15, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B000GP0168', uk: 'B000GP0168', de: 'B000GP0168' }),
    imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'compression_garment',
    name: 'Compression Garment',
    brand: 'Marena',
    category: 'surgery',
    tagline: "Post-lipo essential. Reduces swelling, shapes results, speeds recovery. Wear 24/7 for weeks.",
    description: 'Medical-grade compression for body surgery recovery. Multiple styles for different procedures. Get fitted properly.',
    priority: 1,
    priceRange: { min: 80, max: 120, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B07M6MPJDN', uk: 'B07M6MPJDN' }),
    imageUrl: 'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'scar_gel',
    name: 'Scar Treatment Gel',
    brand: 'Mederma',
    category: 'surgery',
    tagline: "Start using once incisions close. Silicone-based, reduces scar visibility over months.",
    description: 'Apply 3-4x daily for 8 weeks on new scars, 3-6 months on old scars. Clinically proven to improve scar appearance.',
    priority: 2,
    priceRange: { min: 20, max: 30, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00EAFZUPU', uk: 'B00EAFZUPU', de: 'B00EAFZUPU' }),
    imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=200&h=200&fit=crop',
    isBaseStack: false,
  },

  // ============================================
  // ANTI-AGING (5 more products) - New
  // ============================================
  {
    id: 'lrp_spf50',
    name: 'La Roche-Posay Anthelios SPF 50',
    brand: 'La Roche-Posay',
    category: 'skincare',
    tagline: "The Euro SPF gold standard. Invisible finish, high UVA protection. Worth the premium.",
    description: 'Superior UVA filters (Mexoryl). Lightweight, no white cast. The skincare enthusiast SPF choice.',
    priority: 1,
    priceRange: { min: 25, max: 35, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B002CML1XE', uk: 'B002CML1XE', de: 'B002CML1XE', fr: 'B002CML1XE' }),
    imageUrl: 'https://images.unsplash.com/photo-1556227702-d1e4e7b5c232?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'timeless_vitamin_c',
    name: 'Vitamin C 20% Serum',
    brand: 'Timeless',
    category: 'skincare',
    tagline: "L-ascorbic acid at the right pH. Brightens, protects, boosts collagen. The $25 Skinceuticals dupe.",
    description: 'Apply morning before moisturizer and SPF. Store in fridge to preserve potency. Goes orange = time to replace.',
    priority: 1,
    priceRange: { min: 20, max: 30, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B0036BI56G', uk: 'B0036BI56G' }),
    imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'paulas_retinol',
    name: 'Clinical 1% Retinol',
    brand: "Paula's Choice",
    category: 'skincare',
    tagline: "OTC retinol that actually works. Good stepping stone to prescription tretinoin.",
    description: 'Start 2-3x weekly, build to nightly. Contains peptides and antioxidants to buffer irritation.',
    priority: 2,
    priceRange: { min: 35, max: 45, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B00949CO3Y', uk: 'B00949CO3Y', de: 'B00949CO3Y' }),
    imageUrl: 'https://images.unsplash.com/photo-1617897903246-719242758050?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'ordinary_niacinamide',
    name: 'Niacinamide 10% + Zinc 1%',
    brand: 'The Ordinary',
    category: 'skincare',
    tagline: "The $6 pore minimizer. Regulates sebum, reduces inflammation. Everyone should have this.",
    description: 'Use morning or night. Helps with oily skin, large pores, acne. Layer under moisturizer.',
    priority: 2,
    priceRange: { min: 6, max: 12, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B06WGPT9LR', uk: 'B06WGPT9LR', de: 'B06WGPT9LR' }),
    imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=200&h=200&fit=crop',
    isBaseStack: false,
  },
  {
    id: 'vichy_ha',
    name: 'Hyaluronic Acid Serum',
    brand: 'Vichy',
    category: 'skincare',
    tagline: "Pharmacy-grade hydration. Multi-weight HA plumps skin and holds 1000x its weight in water.",
    description: 'Apply to damp skin, layer under moisturizer. Multiple HA weights for surface and deep hydration.',
    priority: 2,
    priceRange: { min: 30, max: 40, currency: 'USD' },
    regionLinks: buildRegionLinks({ us: 'B01N7T8L4H', uk: 'B01N7T8L4H', de: 'B01N7T8L4H', fr: 'B01N7T8L4H' }),
    imageUrl: 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=200&h=200&fit=crop',
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
  const categories: ProductCategory[] = [
    'hygiene',
    'grooming',
    'skincare',
    'miscellaneous',
    'supplements',
    'hair',
    'beard',
    'teeth',
    'kbeauty',
    'hormonal',
    'surgery',
  ];

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
    hair: {
      name: 'Hair',
      icon: 'Wind',
      description: 'The Big 3 and beyond—save what you have',
    },
    beard: {
      name: 'Beard',
      icon: 'User',
      description: 'Grow it, groom it, own it',
    },
    teeth: {
      name: 'Teeth',
      icon: 'Smile',
      description: 'Your smile is worth more than you think',
    },
    kbeauty: {
      name: 'K-Beauty',
      icon: 'Sparkle',
      description: 'Glass skin protocols from Seoul',
    },
    hormonal: {
      name: 'Hormonal',
      icon: 'Heart',
      description: 'PCOS, hormonal acne, and balance',
    },
    surgery: {
      name: 'Surgery',
      icon: 'Stethoscope',
      description: 'Post-op recovery essentials',
    },
  };

  return info[category];
}
