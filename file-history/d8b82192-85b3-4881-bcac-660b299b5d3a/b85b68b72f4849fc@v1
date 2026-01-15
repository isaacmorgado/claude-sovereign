'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Ruler, ChevronUp, ChevronDown } from 'lucide-react';
import { useHeight } from '@/contexts/HeightContext';
import { useGender } from '@/contexts/GenderContext';
import { getHeightRating, cmToFeetInches, feetInchesToCm } from '@/lib/psl-calculator';

export default function HeightPage() {
  const router = useRouter();
  const { heightCm, setHeightCm, inputMode, setInputMode } = useHeight();
  const { gender } = useGender();

  // Local state for input
  const [localFeet, setLocalFeet] = useState<number>(5);
  const [localInches, setLocalInches] = useState<number>(9);
  const [localCm, setLocalCm] = useState<number>(175);

  // Sync from context on mount
  useEffect(() => {
    if (heightCm) {
      setLocalCm(heightCm);
      const { feet, inches } = cmToFeetInches(heightCm);
      setLocalFeet(feet);
      setLocalInches(inches);
    }
  }, [heightCm]);

  // Update height when inputs change
  useEffect(() => {
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
    let newInches = localInches + delta;
    let newFeet = localFeet;

    if (newInches < 0) {
      newInches = 11;
      newFeet = Math.max(4, localFeet - 1);
    } else if (newInches > 11) {
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

  // Number spinner component
  const NumberSpinner = ({
    value,
    onIncrease,
    onDecrease,
    label,
    suffix,
  }: {
    value: number;
    onIncrease: () => void;
    onDecrease: () => void;
    label: string;
    suffix: string;
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
          <span className="text-4xl font-bold text-white tabular-nums">{value}</span>
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
      {/* Back button */}
      <button
        onClick={handleBack}
        className="absolute top-6 left-6 flex items-center gap-2 text-neutral-400 hover:text-white transition-colors text-sm"
      >
        <ArrowLeft className="w-4 h-4" />
        Back
      </button>

      <div className="w-full max-w-sm">
        {/* Header */}
        <div className="mb-8">
          <div className="flex justify-center mb-6">
            <div className="h-12 w-12 rounded-xl bg-[#00f3ff]/20 flex items-center justify-center">
              <Ruler className="w-6 h-6 text-[#00f3ff]" />
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
                  ? 'bg-[#00f3ff] text-black'
                  : 'text-neutral-400 hover:text-white'
              }`}
            >
              ft / in
            </button>
            <button
              onClick={() => setInputMode('metric')}
              className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
                inputMode === 'metric'
                  ? 'bg-[#00f3ff] text-black'
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
                ? `${localFeet}'${localInches}" (${currentHeightCm}cm)`
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

        {/* Continue Button */}
        <button
          onClick={handleContinue}
          disabled={!heightCm}
          className={`
            w-full h-12 rounded-xl font-medium text-sm
            transition-all duration-200
            ${heightCm
              ? 'bg-[#00f3ff] text-black hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] cursor-pointer'
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
