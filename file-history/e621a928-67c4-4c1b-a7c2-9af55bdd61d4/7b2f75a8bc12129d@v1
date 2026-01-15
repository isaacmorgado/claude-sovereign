/**
 * Region Detection & Link Resolution Utility
 * Handles auto-detection and multi-region affiliate links
 */

import {
  Region,
  RegionConfig,
  REGION_CONFIGS,
  LOCALE_TO_REGION,
  TIMEZONE_TO_REGION,
  ProductRegionLinks,
} from '@/types/guides';

const STORAGE_KEY = 'looksmaxx_user_region';
const DEFAULT_REGION: Region = 'us';

/**
 * Detection Priority:
 * 1. localStorage (user preference - highest priority)
 * 2. navigator.language (browser locale)
 * 3. Intl.DateTimeFormat timezone (fallback)
 * 4. 'us' (default fallback)
 */
export function detectRegion(): Region {
  if (typeof window === 'undefined') {
    return DEFAULT_REGION;
  }

  // 1. Check localStorage for user preference
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored && isValidRegion(stored)) {
      return stored as Region;
    }
  } catch {
    // localStorage not available
  }

  // 2. Check browser locale
  const locale = navigator.language;
  if (locale && LOCALE_TO_REGION[locale]) {
    return LOCALE_TO_REGION[locale];
  }

  // Try partial match (e.g., 'en' -> 'us')
  const langCode = locale?.split('-')[0];
  if (langCode) {
    const partialMatch = Object.keys(LOCALE_TO_REGION).find(
      (key) => key.startsWith(langCode + '-')
    );
    if (partialMatch) {
      return LOCALE_TO_REGION[partialMatch];
    }
  }

  // 3. Check timezone
  try {
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    if (timezone && TIMEZONE_TO_REGION[timezone]) {
      return TIMEZONE_TO_REGION[timezone];
    }

    // Try continent-based fallback
    if (timezone) {
      if (timezone.startsWith('America/')) return 'us';
      if (timezone.startsWith('Europe/')) {
        if (timezone.includes('London')) return 'uk';
        if (timezone.includes('Paris')) return 'fr';
        if (timezone.includes('Berlin')) return 'de';
        return 'uk'; // Default European
      }
      if (timezone.startsWith('Australia/')) return 'au';
      if (timezone.startsWith('Asia/')) return 'asia';
    }
  } catch {
    // Intl not available
  }

  // 4. Default fallback
  return DEFAULT_REGION;
}

/**
 * Check if a region code is valid
 */
export function isValidRegion(region: string): region is Region {
  return region in REGION_CONFIGS;
}

/**
 * Get region configuration
 */
export function getRegionConfig(region: Region): RegionConfig {
  return REGION_CONFIGS[region];
}

/**
 * Save user's region preference to localStorage
 */
export function saveRegionPreference(region: Region): void {
  if (typeof window === 'undefined') return;

  try {
    localStorage.setItem(STORAGE_KEY, region);
  } catch {
    // localStorage not available
  }
}

/**
 * Clear saved region preference
 */
export function clearRegionPreference(): void {
  if (typeof window === 'undefined') return;

  try {
    localStorage.removeItem(STORAGE_KEY);
  } catch {
    // localStorage not available
  }
}

/**
 * Check if region was auto-detected vs user-selected
 */
export function isRegionAutoDetected(): boolean {
  if (typeof window === 'undefined') return true;

  try {
    return !localStorage.getItem(STORAGE_KEY);
  } catch {
    return true;
  }
}

/**
 * Get affiliate link for a product based on region
 * Falls back to US or direct link if region unavailable
 */
export function getProductLink(
  regionLinks: ProductRegionLinks,
  region: Region,
  directLink?: string
): string {
  // Try requested region first
  const regionLink = regionLinks[region];
  if (regionLink) return regionLink;

  // Fallback to AU (widest availability)
  if (regionLinks.au) return regionLinks.au;

  // Fallback to US
  if (regionLinks.us) return regionLinks.us;

  // Use direct link if available
  if (directLink) return directLink;

  // Last resort: return first available link
  const firstAvailable = Object.values(regionLinks).find(Boolean);
  return firstAvailable || '#';
}

/**
 * Build Amazon affiliate URL with proper tag
 */
export function buildAmazonUrl(
  asin: string,
  region: Region
): string {
  const config = REGION_CONFIGS[region];
  return `https://www.${config.amazonDomain}/dp/${asin}?tag=${config.affiliateTag}`;
}

/**
 * Check if a product is available in a specific region
 */
export function isProductAvailableInRegion(
  regionLinks: ProductRegionLinks,
  region: Region
): boolean {
  return !!regionLinks[region];
}

/**
 * Get all available regions for a product
 */
export function getAvailableRegions(
  regionLinks: ProductRegionLinks
): Region[] {
  return Object.entries(regionLinks)
    .filter(([, link]) => !!link)
    .map(([region]) => region as Region);
}

/**
 * Get region display info (name + flag)
 */
export function getRegionDisplayInfo(region: Region): {
  name: string;
  flag: string;
  fullName: string;
} {
  const config = REGION_CONFIGS[region];
  return {
    name: config.name,
    flag: config.flag,
    fullName: `${config.flag} ${config.name}`,
  };
}

/**
 * Get all regions for dropdown
 */
export function getAllRegions(): RegionConfig[] {
  return Object.values(REGION_CONFIGS);
}

/**
 * Format price for region
 */
export function formatPrice(
  amount: number,
  region: Region
): string {
  const config = REGION_CONFIGS[region];
  return `${config.currencySymbol}${amount.toFixed(2)}`;
}

/**
 * Format price range for region
 */
export function formatPriceRange(
  min: number,
  max: number,
  region: Region
): string {
  const config = REGION_CONFIGS[region];
  if (min === max) {
    return `${config.currencySymbol}${min.toFixed(2)}`;
  }
  return `${config.currencySymbol}${min.toFixed(2)} - ${config.currencySymbol}${max.toFixed(2)}`;
}
