/**
 * Guide System Type Definitions
 * Product guides with multi-region affiliate links
 */

// ============================================
// REGION TYPES
// ============================================

export type Region = 'us' | 'uk' | 'de' | 'fr' | 'au' | 'asia';

export interface RegionConfig {
  code: Region;
  name: string;
  flag: string;
  amazonDomain: string;
  affiliateTag: string;
  currency: string;
  currencySymbol: string;
}

export const REGION_CONFIGS: Record<Region, RegionConfig> = {
  us: {
    code: 'us',
    name: 'United States',
    flag: '🇺🇸',
    amazonDomain: 'amazon.com',
    affiliateTag: 'looksmaxx-20',
    currency: 'USD',
    currencySymbol: '$',
  },
  uk: {
    code: 'uk',
    name: 'United Kingdom',
    flag: '🇬🇧',
    amazonDomain: 'amazon.co.uk',
    affiliateTag: 'looksmaxx-21',
    currency: 'GBP',
    currencySymbol: '£',
  },
  de: {
    code: 'de',
    name: 'Germany',
    flag: '🇩🇪',
    amazonDomain: 'amazon.de',
    affiliateTag: 'looksmaxx-21',
    currency: 'EUR',
    currencySymbol: '€',
  },
  fr: {
    code: 'fr',
    name: 'France',
    flag: '🇫🇷',
    amazonDomain: 'amazon.fr',
    affiliateTag: 'looksmaxx-21',
    currency: 'EUR',
    currencySymbol: '€',
  },
  au: {
    code: 'au',
    name: 'Australia',
    flag: '🇦🇺',
    amazonDomain: 'amazon.com.au',
    affiliateTag: 'looksmaxx-22',
    currency: 'AUD',
    currencySymbol: 'A$',
  },
  asia: {
    code: 'asia',
    name: 'Asia',
    flag: '🌏',
    amazonDomain: 'amzn.asia',
    affiliateTag: 'looksmaxx-22',
    currency: 'USD',
    currencySymbol: '$',
  },
};

// ============================================
// PRODUCT TYPES
// ============================================

export type ProductCategory =
  | 'hygiene'
  | 'grooming'
  | 'skincare'
  | 'miscellaneous'
  | 'supplements';

export interface ProductRegionLinks {
  us?: string;
  uk?: string;
  de?: string;
  fr?: string;
  au?: string;
  asia?: string;
}

export interface GuideProduct {
  id: string;
  name: string;
  brand?: string;
  category: ProductCategory;
  tagline: string;  // Funny Ross-style tagline
  description: string;
  priority: number;  // 1 = essential, 2 = recommended, 3 = optional
  priceRange?: {
    min: number;
    max: number;
    currency: string;
  };
  regionLinks: ProductRegionLinks;
  directLink?: string;  // Non-Amazon link if available
  imageUrl?: string;
  isBaseStack?: boolean;  // Part of universal stack
}

// ============================================
// GUIDE CONTENT TYPES
// ============================================

export type HumorLevel = 'low' | 'medium' | 'medium-high' | 'high';

// ============================================
// MEDIA TYPES
// ============================================

export type MediaType = 'gif' | 'image' | 'video';
export type MediaPlacement = 'inline' | 'hero' | 'full-width';

export interface GuideMedia {
  id: string;
  type: MediaType;
  url: string;
  alt: string;
  caption?: string;
  placement?: MediaPlacement;
  width?: number;
  height?: number;
}

export interface GuideSection {
  id: string;
  title: string;
  content: string;  // Markdown content
  humorLevel?: HumorLevel;
  products?: string[];  // Product IDs referenced in this section
  tips?: string[];  // Quick tip callouts
  warnings?: string[];  // Important warnings
  media?: GuideMedia[];  // GIFs, images, videos for this section
}

export interface Guide {
  id: string;
  slug: string;
  title: string;
  subtitle?: string;  // Funny subtitle
  description: string;
  icon: string;  // Icon name or emoji
  humorLevel: HumorLevel;
  estimatedReadTime: number;  // minutes
  sections: GuideSection[];
  relatedGuides?: string[];  // Related guide IDs
  productIds?: string[];  // All products mentioned
  tags?: string[];
  order: number;  // Display order
  heroMedia?: GuideMedia;  // Hero image/GIF for the guide
  forumCategory?: string;  // Forum category slug for "Discuss in Forum"
}

// ============================================
// GUIDE CATEGORY TYPES
// ============================================

export interface GuideCategory {
  id: string;
  name: string;
  description: string;
  icon: string;
  color: string;
  guideIds: string[];
}

// ============================================
// CONTEXT STATE TYPES
// ============================================

export interface RegionState {
  region: Region;
  isAutoDetected: boolean;
  isLoading: boolean;
}

// ============================================
// LOCALE MAPPINGS
// ============================================

export const LOCALE_TO_REGION: Record<string, Region> = {
  'en-US': 'us',
  'en-GB': 'uk',
  'en-AU': 'au',
  'de-DE': 'de',
  'de-AT': 'de',
  'de-CH': 'de',
  'fr-FR': 'fr',
  'fr-CA': 'us',  // Ships from US
  'fr-BE': 'fr',
  'ja-JP': 'asia',
  'ko-KR': 'asia',
  'zh-CN': 'asia',
  'zh-TW': 'asia',
  'zh-HK': 'asia',
};

export const TIMEZONE_TO_REGION: Record<string, Region> = {
  // Americas
  'America/New_York': 'us',
  'America/Los_Angeles': 'us',
  'America/Chicago': 'us',
  'America/Denver': 'us',
  'America/Toronto': 'us',
  // Europe
  'Europe/London': 'uk',
  'Europe/Berlin': 'de',
  'Europe/Paris': 'fr',
  'Europe/Vienna': 'de',
  'Europe/Zurich': 'de',
  // Asia Pacific
  'Australia/Sydney': 'au',
  'Australia/Melbourne': 'au',
  'Australia/Brisbane': 'au',
  'Asia/Tokyo': 'asia',
  'Asia/Seoul': 'asia',
  'Asia/Shanghai': 'asia',
  'Asia/Hong_Kong': 'asia',
  'Asia/Singapore': 'asia',
};

// ============================================
// HELPER TYPES
// ============================================

export interface ProductClick {
  productId: string;
  region: Region;
  guideId?: string;
  sectionId?: string;
  timestamp: number;
}

export interface GuideView {
  guideId: string;
  region: Region;
  scrollDepth: number;  // 0-100
  timeSpentSeconds: number;
  timestamp: number;
}
