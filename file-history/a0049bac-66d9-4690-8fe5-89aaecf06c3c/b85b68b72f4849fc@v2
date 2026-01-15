'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Ruler, ChevronUp, ChevronDown } from 'lucide-react';
import { useHeight } from '@/contexts/HeightContext';
import { useGender } from '@/contexts/GenderContext';
import { getHeightRating, cmToFeetInches, feetInchesToCm } from '@/lib/psl-calculator';
import { OnboardingProgress } from '@/components/onboarding/OnboardingProgress';

export default function HeightPage() {
  const router = useRouter();
  const { heightCm, setHeightCm, inputMode, setInputMode } = useHeight();
  const { gender } = useGender();

  // Local state for input
  const [localFeet, setLocalFeet] = useState<number>(5);
  const [localInches, setLocalInches] = useState<number>(9);
  const [localCm, setLocalCm] = useState<number>(175);

  // Track initialization to prevent circular updates
  const isInitialMount = useRef(true);

  // Sync from context on initial mount only
  useEffect(() => {
    if (isInitialMount.current && heightCm) {
      setLocalCm(heightCm);
      const { feet, inches } = cmToFeetInches(heightCm);
      setLocalFeet(feet);
      setLocalInches(inches);
    }
    isInitialMount.current = false;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // Empty dependency - intentionally only run on mount

  // Update context when local state changes (skip on initial mount)
  useEffect(() => {
    if (isInitialMount.current) return;

    if (inputMode === 'imperial') {
      const cm = feetInchesToCm(localFeet, localInches);
      setHeightCm(cm);
    } else {
      setHeightCm(localCm);
    }
  }, [localFeet, localInches, localCm, inputMode, setHeightCm]);

  const handleFeetChange = (delta: number) => {
    const newFeet = Math.min(7, Math.max(4, localFeet + delta));
    setLocalFeet(newFeet);
  };

  const handleInchesChange = (delta: number) => {
    // Use 0.5 inch increments with proper rounding to avoid floating point issues
    let newInches = Math.round((localInches + delta * 0.5) * 2) / 2;
    let newFeet = localFeet;

    if (newInches < 0) {
      newInches = 11.5;
      newFeet = Math.max(4, localFeet - 1);
    } else if (newInches >= 12) {
      newInches = 0;
      newFeet = Math.min(7, localFeet + 1);
    }

    setLocalFeet(newFeet);
    setLocalInches(newInches);
  };

  const handleCmChange = (delta: number) => {
    const newCm = Math.min(230, Math.max(140, localCm + delta));
    setLocalCm(newCm);
  };

  const handleContinue = () => {
    if (heightCm) {
      router.push('/weight');
    }
  };

  const handleBack = () => {
    router.push('/ethnicity');
  };

  // Get height rating preview
  const currentGender = gender || 'male';
  const currentHeightCm = inputMode === 'imperial' ? feetInchesToCm(localFeet, localInches) : localCm;
  const heightRating = getHeightRating(currentHeightCm, currentGender);

  // Get percentile description
  const getPercentileDescription = (rating: number): string => {
    if (rating >= 9.0) return 'Exceptional';
    if (rating >= 8.0) return 'Very Tall';
    if (rating >= 7.0) return 'Tall';
    if (rating >= 6.0) return 'Above Average';
    if (rating >= 5.0) return 'Average';
    if (rating >= 4.0) return 'Below Average';
    if (rating >= 3.0) return 'Short';
    return 'Very Short';
  };

  // Format inches display (show .5 for half inches, otherwise whole number)
  const formatInchesDisplay = (inches: number): string => {
    return Number.isInteger(inches) ? inches.toString() : inches.toFixed(1);
  };

  // Number spinner component
  const NumberSpinner = ({
    value,
    onIncrease,
    onDecrease,
    label,
    suffix,
    isDecimal = false,
  }: {
    value: number;
    onIncrease: () => void;
    onDecrease: () => void;
    label: string;
    suffix: string;
    isDecimal?: boolean;
  }) => (
    <div className="flex flex-col items-center">
      <span className="text-xs text-neutral-500 mb-2">{label}</span>
      <div className="flex flex-col items-center bg-neutral-900 rounded-xl border border-neutral-800 p-2">
        <button
          onClick={onIncrease}
          className="p-2 hover:bg-neutral-800 rounded-lg transition-colors"
        >
          <ChevronUp className="w-6 h-6 text-neutral-400" />
        </button>
        <div className="flex items-baseline py-3">
          <span className="text-4xl font-bold text-white tabular-nums">
            {isDecimal ? formatInchesDisplay(value) : value}
          </span>
          <span className="text-lg text-neutral-500 ml-1">{suffix}</span>
        </div>
        <button
          onClick={onDecrease}
          className="p-2 hover:bg-neutral-800 rounded-lg transition-colors"
        >
          <ChevronDown className="w-6 h-6 text-neutral-400" />
        </button>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
      {/* Global Progress Bar */}
      <div className="fixed top-0 left-0 right-0 pt-4 px-4 bg-gradient-to-b from-black via-black/80 to-transparent pb-8 z-10">
        <OnboardingProgress currentStep="height" />
      </div>

      {/* Back button */}
      <button
        onClick={handleBack}
        className="fixed top-16 left-6 flex items-center gap-2 text-neutral-400 hover:text-white transition-colors text-sm z-20"
      >
        <ArrowLeft className="w-4 h-4" />
        Back
      </button>

      <div className="w-full max-w-sm">
        {/* Header */}
        <div className="mb-8">
          <div className="flex justify-center mb-6">
            <div className="h-12 w-12 rounded-xl bg-cyan-400/20 flex items-center justify-center">
              <Ruler className="w-6 h-6 text-cyan-400" />
            </div>
          </div>
          <h1 className="text-2xl font-semibold tracking-tight text-center text-white mb-2">
            Enter Your Height
          </h1>
          <p className="text-sm text-neutral-400 text-center">
            Height contributes 20% to your PSL score
          </p>
        </div>

        {/* Unit Toggle */}
        <div className="flex justify-center mb-6">
          <div className="flex bg-neutral-900 rounded-lg p-1 border border-neutral-800">
            <button
              onClick={() => setInputMode('imperial')}
              className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
                inputMode === 'imperial'
                  ? 'bg-cyan-400 text-black'
                  : 'text-neutral-400 hover:text-white'
              }`}
            >
              ft / in
            </button>
            <button
              onClick={() => setInputMode('metric')}
              className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
                inputMode === 'metric'
                  ? 'bg-cyan-400 text-black'
                  : 'text-neutral-400 hover:text-white'
              }`}
            >
              cm
            </button>
          </div>
        </div>

        {/* Height Input */}
        <div className="flex justify-center gap-4 mb-8">
          {inputMode === 'imperial' ? (
            <>
              <NumberSpinner
                value={localFeet}
                onIncrease={() => handleFeetChange(1)}
                onDecrease={() => handleFeetChange(-1)}
                label="FEET"
                suffix="'"
              />
              <NumberSpinner
                value={localInches}
                onIncrease={() => handleInchesChange(1)}
                onDecrease={() => handleInchesChange(-1)}
                label="INCHES"
                suffix='"'
                isDecimal={true}
              />
            </>
          ) : (
            <NumberSpinner
              value={localCm}
              onIncrease={() => handleCmChange(1)}
              onDecrease={() => handleCmChange(-1)}
              label="CENTIMETERS"
              suffix="cm"
            />
          )}
        </div>

        {/* Height Rating Preview */}
        <div className="bg-neutral-900/50 rounded-xl border border-neutral-800 p-4 mb-6">
          <div className="flex items-center justify-between mb-3">
            <span className="text-sm text-neutral-400">Height Rating</span>
            <span className="text-sm text-neutral-500">
              {inputMode === 'imperial'
                ? `${localFeet}'${formatInchesDisplay(localInches)}" (${currentHeightCm}cm)`
                : `${localCm}cm`}
            </span>
          </div>

          {/* Rating bar */}
          <div className="relative h-3 bg-neutral-800 rounded-full overflow-hidden mb-2">
            <div
              className="absolute inset-y-0 left-0 rounded-full transition-all duration-300"
              style={{
                width: `${(heightRating / 10) * 100}%`,
                background:
                  heightRating >= 8
                    ? 'linear-gradient(90deg, #22c55e, #06b6d4)'
                    : heightRating >= 6
                    ? 'linear-gradient(90deg, #84cc16, #22c55e)'
                    : heightRating >= 5
                    ? 'linear-gradient(90deg, #f59e0b, #84cc16)'
                    : 'linear-gradient(90deg, #ef4444, #f59e0b)',
              }}
            />
          </div>

          <div className="flex items-center justify-between">
            <span className="text-lg font-bold text-white">{heightRating.toFixed(1)}/10</span>
            <span
              className={`text-sm font-medium ${
                heightRating >= 8
                  ? 'text-cyan-400'
                  : heightRating >= 6
                  ? 'text-green-400'
                  : heightRating >= 5
                  ? 'text-yellow-400'
                  : 'text-red-400'
              }`}
            >
              {getPercentileDescription(heightRating)}
            </span>
          </div>
        </div>

        {/* Reference heights */}
        <div className="bg-neutral-900/30 rounded-lg p-3 mb-6">
          <p className="text-xs text-neutral-500 text-center mb-2">
            {currentGender === 'male' ? 'Male' : 'Female'} height reference
          </p>
          <div className="flex justify-between text-xs text-neutral-400">
            <span>Avg: {currentGender === 'male' ? "5'9\"" : "5'4\""}</span>
            <span>Top 1%: {currentGender === 'male' ? "6'3\"+" : "5'10\"+"}</span>
          </div>
        </div>

        {/* Continue Button - Desktop */}
        <button
          onClick={handleContinue}
          disabled={!heightCm}
          className={`
            hidden md:block w-full h-12 rounded-xl font-medium text-sm
            transition-all duration-200
            ${heightCm
              ? 'bg-cyan-400 text-black hover:shadow-[0_0_20px_rgba(34,211,238,0.3)] cursor-pointer'
              : 'bg-neutral-800 text-neutral-500 cursor-not-allowed'
            }
          `}
        >
          Continue
        </button>

        {/* Spacer for mobile bottom CTA */}
        <div className="h-24 md:hidden" />
      </div>

      {/* Fixed Bottom CTA - Mobile Only */}
      <div className="fixed bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black via-black/95 to-transparent md:hidden z-30">
        <button
          onClick={handleContinue}
          disabled={!heightCm}
          className={`
            w-full h-12 rounded-xl font-medium text-sm
            transition-all duration-200
            ${heightCm
              ? 'bg-cyan-400 text-black hover:shadow-[0_0_20px_rgba(34,211,238,0.3)] cursor-pointer'
              : 'bg-neutral-800 text-neutral-500 cursor-not-allowed'
            }
          `}
        >
          Continue
        </button>
      </div>
    </div>
  );
}
