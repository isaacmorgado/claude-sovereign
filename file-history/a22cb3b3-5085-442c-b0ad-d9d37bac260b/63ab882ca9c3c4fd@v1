'use client';

import React, { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';

type InputMode = 'metric' | 'imperial';

interface HeightContextType {
  // State
  heightCm: number | null;
  inputMode: InputMode;

  // Derived values for imperial
  heightFeet: number | null;
  heightInches: number | null;

  // Actions
  setHeightCm: (height: number | null) => void;
  setHeightImperial: (feet: number, inches: number) => void;
  setInputMode: (mode: InputMode) => void;
  clearHeight: () => void;

  // Display helpers
  getDisplayHeight: () => string;
}

const HeightContext = createContext<HeightContextType | undefined>(undefined);

const STORAGE_KEY = 'looksmaxx_height';

// Convert cm to feet and inches
function cmToImperial(cm: number): { feet: number; inches: number } {
  const totalInches = cm / 2.54;
  const feet = Math.floor(totalInches / 12);
  const inches = Math.round(totalInches % 12);
  return { feet, inches: inches === 12 ? 0 : inches };
}

// Convert feet and inches to cm
function imperialToCm(feet: number, inches: number): number {
  const totalInches = feet * 12 + inches;
  return Math.round(totalInches * 2.54);
}

// Format display string
function formatHeight(cm: number, mode: InputMode): string {
  if (mode === 'metric') {
    return `${cm} cm`;
  }
  const { feet, inches } = cmToImperial(cm);
  return `${feet}'${inches}"`;
}

export function HeightProvider({ children }: { children: ReactNode }) {
  const [heightCm, setHeightCmState] = useState<number | null>(null);
  const [inputMode, setInputModeState] = useState<InputMode>('imperial');
  const [isHydrated, setIsHydrated] = useState(false);

  // Load from localStorage on mount
  useEffect(() => {
    if (typeof window !== 'undefined') {
      try {
        const stored = localStorage.getItem(STORAGE_KEY);
        if (stored) {
          const parsed = JSON.parse(stored);
          if (parsed.heightCm && typeof parsed.heightCm === 'number') {
            setHeightCmState(parsed.heightCm);
          }
          if (parsed.inputMode && (parsed.inputMode === 'metric' || parsed.inputMode === 'imperial')) {
            setInputModeState(parsed.inputMode);
          }
        }
      } catch (e) {
        console.error('Failed to load height from storage:', e);
      }
      setIsHydrated(true);
    }
  }, []);

  // Persist to localStorage when state changes
  useEffect(() => {
    if (isHydrated && typeof window !== 'undefined') {
      const data = { heightCm, inputMode };
      localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    }
  }, [heightCm, inputMode, isHydrated]);

  // Set height in cm
  const setHeightCm = useCallback((height: number | null) => {
    if (height !== null) {
      // Clamp to reasonable range (100cm - 230cm)
      const clamped = Math.min(230, Math.max(100, Math.round(height)));
      setHeightCmState(clamped);
    } else {
      setHeightCmState(null);
    }
  }, []);

  // Set height in imperial
  const setHeightImperial = useCallback((feet: number, inches: number) => {
    const cm = imperialToCm(feet, inches);
    setHeightCm(cm);
  }, [setHeightCm]);

  // Set input mode
  const setInputMode = useCallback((mode: InputMode) => {
    setInputModeState(mode);
  }, []);

  // Clear height
  const clearHeight = useCallback(() => {
    setHeightCmState(null);
  }, []);

  // Get display string
  const getDisplayHeight = useCallback(() => {
    if (heightCm === null) return '';
    return formatHeight(heightCm, inputMode);
  }, [heightCm, inputMode]);

  // Derived imperial values
  const imperialValues = heightCm !== null ? cmToImperial(heightCm) : { feet: null, inches: null };

  return (
    <HeightContext.Provider
      value={{
        heightCm,
        inputMode,
        heightFeet: imperialValues.feet,
        heightInches: imperialValues.inches,
        setHeightCm,
        setHeightImperial,
        setInputMode,
        clearHeight,
        getDisplayHeight,
      }}
    >
      {children}
    </HeightContext.Provider>
  );
}

export function useHeight() {
  const context = useContext(HeightContext);
  if (context === undefined) {
    throw new Error('useHeight must be used within a HeightProvider');
  }
  return context;
}

// Optional hook for components that might not be in the provider
export function useHeightOptional() {
  return useContext(HeightContext);
}
