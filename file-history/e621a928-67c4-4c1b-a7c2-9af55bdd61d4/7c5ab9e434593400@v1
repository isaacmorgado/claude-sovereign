'use client';

import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  ReactNode,
} from 'react';
import {
  Region,
  RegionConfig,
  ProductRegionLinks,
} from '@/types/guides';
import {
  detectRegion,
  saveRegionPreference,
  isRegionAutoDetected,
  getRegionConfig,
  getProductLink,
  getAllRegions,
  formatPrice,
  formatPriceRange,
} from '@/lib/region';

interface RegionContextType {
  region: Region;
  regionConfig: RegionConfig;
  isAutoDetected: boolean;
  isLoading: boolean;
  setRegion: (region: Region) => void;
  resetToAutoDetect: () => void;
  getLink: (regionLinks: ProductRegionLinks, directLink?: string) => string;
  formatAmount: (amount: number) => string;
  formatRange: (min: number, max: number) => string;
  allRegions: RegionConfig[];
}

const RegionContext = createContext<RegionContextType | undefined>(undefined);

export function RegionProvider({ children }: { children: ReactNode }) {
  const [region, setRegionState] = useState<Region>('us');
  const [isAutoDetected, setIsAutoDetected] = useState<boolean>(true);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Initialize region on mount
  useEffect(() => {
    const detected = detectRegion();
    setRegionState(detected);
    setIsAutoDetected(isRegionAutoDetected());
    setIsLoading(false);
  }, []);

  // Update region and save preference
  const setRegion = useCallback((newRegion: Region) => {
    setRegionState(newRegion);
    saveRegionPreference(newRegion);
    setIsAutoDetected(false);
  }, []);

  // Reset to auto-detected region
  const resetToAutoDetect = useCallback(() => {
    if (typeof window !== 'undefined') {
      try {
        localStorage.removeItem('looksmaxx_user_region');
      } catch {
        // Ignore
      }
    }
    const detected = detectRegion();
    setRegionState(detected);
    setIsAutoDetected(true);
  }, []);

  // Get product link for current region
  const getLink = useCallback(
    (regionLinks: ProductRegionLinks, directLink?: string) => {
      return getProductLink(regionLinks, region, directLink);
    },
    [region]
  );

  // Format price for current region
  const formatAmount = useCallback(
    (amount: number) => {
      return formatPrice(amount, region);
    },
    [region]
  );

  // Format price range for current region
  const formatRange = useCallback(
    (min: number, max: number) => {
      return formatPriceRange(min, max, region);
    },
    [region]
  );

  const regionConfig = getRegionConfig(region);
  const allRegions = getAllRegions();

  return (
    <RegionContext.Provider
      value={{
        region,
        regionConfig,
        isAutoDetected,
        isLoading,
        setRegion,
        resetToAutoDetect,
        getLink,
        formatAmount,
        formatRange,
        allRegions,
      }}
    >
      {children}
    </RegionContext.Provider>
  );
}

export function useRegion(): RegionContextType {
  const context = useContext(RegionContext);
  if (context === undefined) {
    throw new Error('useRegion must be used within a RegionProvider');
  }
  return context;
}

// Optional hook for components that might not be in the provider
export function useRegionOptional(): RegionContextType | undefined {
  return useContext(RegionContext);
}
