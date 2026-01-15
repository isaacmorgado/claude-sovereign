'use client';

import React, { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';
import { useHeightOptional } from './HeightContext';

type InputMode = 'metric' | 'imperial';

interface WeightContextType {
  // State
  weightKg: number | null;
  inputMode: InputMode;

  // Derived values
  weightLbs: number | null;
  bmi: number | null;

  // Actions
  setWeightKg: (weight: number | null) => void;
  setWeightLbs: (weight: number) => void;
  setInputMode: (mode: InputMode) => void;
  clearWeight: () => void;

  // Display helpers
  getDisplayWeight: () => string;
  getBMICategory: () => string | null;
}

const WeightContext = createContext<WeightContextType | undefined>(undefined);

const STORAGE_KEY = 'looksmaxx_weight';

// Convert kg to lbs
function kgToLbs(kg: number): number {
  return Math.round(kg * 2.20462 * 10) / 10;
}

// Convert lbs to kg
function lbsToKg(lbs: number): number {
  return Math.round(lbs / 2.20462 * 10) / 10;
}

// Calculate BMI
function calculateBMI(weightKg: number, heightCm: number): number {
  const heightM = heightCm / 100;
  return Math.round((weightKg / (heightM * heightM)) * 10) / 10;
}

// Get BMI category
function getBMICategoryFromValue(bmi: number): string {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
}

// Format display string
function formatWeight(kg: number, mode: InputMode): string {
  if (mode === 'metric') {
    return `${kg} kg`;
  }
  return `${kgToLbs(kg)} lbs`;
}

export function WeightProvider({ children }: { children: ReactNode }) {
  const [weightKg, setWeightKgState] = useState<number | null>(null);
  const [inputMode, setInputModeState] = useState<InputMode>('imperial');
  const [isHydrated, setIsHydrated] = useState(false);

  // Get height from HeightContext if available
  const heightContext = useHeightOptional();
  const heightCm = heightContext?.heightCm ?? null;

  // Load from localStorage on mount
  useEffect(() => {
    if (typeof window !== 'undefined') {
      try {
        const stored = localStorage.getItem(STORAGE_KEY);
        if (stored) {
          const parsed = JSON.parse(stored);
          if (parsed.weightKg && typeof parsed.weightKg === 'number') {
            setWeightKgState(parsed.weightKg);
          }
          if (parsed.inputMode && (parsed.inputMode === 'metric' || parsed.inputMode === 'imperial')) {
            setInputModeState(parsed.inputMode);
          }
        }
      } catch (e) {
        console.error('Failed to load weight from storage:', e);
      }
      setIsHydrated(true);
    }
  }, []);

  // Persist to localStorage when state changes
  useEffect(() => {
    if (isHydrated && typeof window !== 'undefined') {
      const data = { weightKg, inputMode };
      localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    }
  }, [weightKg, inputMode, isHydrated]);

  // Set weight in kg
  const setWeightKg = useCallback((weight: number | null) => {
    if (weight !== null) {
      // Clamp to reasonable range (30kg - 300kg)
      const clamped = Math.min(300, Math.max(30, Math.round(weight * 10) / 10));
      setWeightKgState(clamped);
    } else {
      setWeightKgState(null);
    }
  }, []);

  // Set weight in lbs
  const setWeightLbs = useCallback((lbs: number) => {
    const kg = lbsToKg(lbs);
    setWeightKg(kg);
  }, [setWeightKg]);

  // Set input mode
  const setInputMode = useCallback((mode: InputMode) => {
    setInputModeState(mode);
  }, []);

  // Clear weight
  const clearWeight = useCallback(() => {
    setWeightKgState(null);
  }, []);

  // Get display string
  const getDisplayWeight = useCallback(() => {
    if (weightKg === null) return '';
    return formatWeight(weightKg, inputMode);
  }, [weightKg, inputMode]);

  // Calculate derived values
  const weightLbs = weightKg !== null ? kgToLbs(weightKg) : null;
  const bmi = weightKg !== null && heightCm !== null ? calculateBMI(weightKg, heightCm) : null;

  // Get BMI category
  const getBMICategory = useCallback(() => {
    if (bmi === null) return null;
    return getBMICategoryFromValue(bmi);
  }, [bmi]);

  return (
    <WeightContext.Provider
      value={{
        weightKg,
        inputMode,
        weightLbs,
        bmi,
        setWeightKg,
        setWeightLbs,
        setInputMode,
        clearWeight,
        getDisplayWeight,
        getBMICategory,
      }}
    >
      {children}
    </WeightContext.Provider>
  );
}

export function useWeight() {
  const context = useContext(WeightContext);
  if (context === undefined) {
    throw new Error('useWeight must be used within a WeightProvider');
  }
  return context;
}

// Optional hook for components that might not be in the provider
export function useWeightOptional() {
  return useContext(WeightContext);
}
