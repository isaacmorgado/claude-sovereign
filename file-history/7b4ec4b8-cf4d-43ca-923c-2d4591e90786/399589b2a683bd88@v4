'use client';

import React, { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';

export interface PhysiqueImage {
  file: File;
  preview: string;
}

export type PhysiqueAngle = 'front' | 'side' | 'back';

export interface PhysiqueAnalysisResult {
  bodyFatPercent: number;
  muscleMass: string;  // low|medium|medium-high|high|very-high
  frameSize: string;   // small|medium|large|very-large
  shoulderWidth: string;  // narrow|average|broad|very-broad
  waistDefinition: string;  // undefined|slight|defined|very-defined
  posture: string;  // poor|fair|good|excellent
  confidence: number;
  notes?: string;
}

interface PhysiqueContextType {
  frontPhoto: PhysiqueImage | null;
  sidePhoto: PhysiqueImage | null;
  backPhoto: PhysiqueImage | null;
  setFrontPhoto: (image: PhysiqueImage | null) => void;
  setSidePhoto: (image: PhysiqueImage | null) => void;
  setBackPhoto: (image: PhysiqueImage | null) => void;
  skipped: boolean;
  setSkipped: (skipped: boolean) => void;
  clearAll: () => void;
  hasAnyPhotos: boolean;
  // Analysis results
  physiqueAnalysis: PhysiqueAnalysisResult | null;
  setPhysiqueAnalysis: (result: PhysiqueAnalysisResult | null) => void;
  isAnalyzing: boolean;
  setIsAnalyzing: (analyzing: boolean) => void;
}

const PhysiqueContext = createContext<PhysiqueContextType | undefined>(undefined);

const STORAGE_KEY = 'looksmaxx_physique_analysis';

export function PhysiqueProvider({ children }: { children: ReactNode }) {
  const [frontPhoto, setFrontPhoto] = useState<PhysiqueImage | null>(null);
  const [sidePhoto, setSidePhoto] = useState<PhysiqueImage | null>(null);
  const [backPhoto, setBackPhoto] = useState<PhysiqueImage | null>(null);
  const [skipped, setSkipped] = useState<boolean>(false);
  const [physiqueAnalysis, setPhysiqueAnalysisState] = useState<PhysiqueAnalysisResult | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState<boolean>(false);
  const [isHydrated, setIsHydrated] = useState(false);

  // Load analysis from localStorage on mount (photos are not persisted - they're blobs)
  useEffect(() => {
    if (typeof window !== 'undefined') {
      try {
        const stored = localStorage.getItem(STORAGE_KEY);
        if (stored) {
          const parsed = JSON.parse(stored);
          if (parsed.physiqueAnalysis) {
            setPhysiqueAnalysisState(parsed.physiqueAnalysis);
          }
          if (typeof parsed.skipped === 'boolean') {
            setSkipped(parsed.skipped);
          }
        }
      } catch (e) {
        console.error('Failed to load physique analysis from storage:', e);
      }
      setIsHydrated(true);
    }
  }, []);

  // Persist analysis to localStorage when it changes
  useEffect(() => {
    if (isHydrated && typeof window !== 'undefined') {
      const data = { physiqueAnalysis, skipped };
      localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    }
  }, [physiqueAnalysis, skipped, isHydrated]);

  // Wrapped setter to update state
  const setPhysiqueAnalysis = useCallback((result: PhysiqueAnalysisResult | null) => {
    setPhysiqueAnalysisState(result);
  }, []);

  const clearAll = useCallback(() => {
    if (frontPhoto?.preview) URL.revokeObjectURL(frontPhoto.preview);
    if (sidePhoto?.preview) URL.revokeObjectURL(sidePhoto.preview);
    if (backPhoto?.preview) URL.revokeObjectURL(backPhoto.preview);
    setFrontPhoto(null);
    setSidePhoto(null);
    setBackPhoto(null);
    setSkipped(false);
    setPhysiqueAnalysisState(null);
    setIsAnalyzing(false);
    // Clear from localStorage
    if (typeof window !== 'undefined') {
      localStorage.removeItem(STORAGE_KEY);
    }
  }, [frontPhoto, sidePhoto, backPhoto]);

  const hasAnyPhotos = !!(frontPhoto || sidePhoto || backPhoto);

  return (
    <PhysiqueContext.Provider
      value={{
        frontPhoto,
        sidePhoto,
        backPhoto,
        setFrontPhoto,
        setSidePhoto,
        setBackPhoto,
        skipped,
        setSkipped,
        clearAll,
        hasAnyPhotos,
        physiqueAnalysis,
        setPhysiqueAnalysis,
        isAnalyzing,
        setIsAnalyzing,
      }}
    >
      {children}
    </PhysiqueContext.Provider>
  );
}

export function usePhysique() {
  const context = useContext(PhysiqueContext);
  if (context === undefined) {
    throw new Error('usePhysique must be used within a PhysiqueProvider');
  }
  return context;
}

// Optional hook for components that might not be in the provider
export function usePhysiqueOptional() {
  return useContext(PhysiqueContext);
}
