'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Scale, ChevronUp, ChevronDown } from 'lucide-react';
import { useWeight } from '@/contexts/WeightContext';

// Convert kg to lbs
function kgToLbs(kg: number): number {
  return Math.round(kg * 2.20462);
}

// Convert lbs to kg
function lbsToKg(lbs: number): number {
  return Math.round(lbs / 2.20462 * 10) / 10;
}

export default function WeightPage() {
  const router = useRouter();
  const { weightKg, setWeightKg, setWeightLbs, inputMode, setInputMode } = useWeight();
  const hasInitialized = useRef(false);

  // Local state for input - initialize from context if available
  const [localKg, setLocalKg] = useState<number>(() => weightKg ?? 75);
  const [localLbs, setLocalLbs] = useState<number>(() => weightKg ? kgToLbs(weightKg) : 165);

  // Sync from context only on initial mount (hydration)
  useEffect(() => {
    if (!hasInitialized.current && weightKg) {
      setLocalKg(weightKg);
      setLocalLbs(kgToLbs(weightKg));
      hasInitialized.current = true;
    }
  }, [weightKg]);

  const handleKgChange = (delta: number) => {
    const newKg = Math.min(200, Math.max(40, localKg + delta));
    setLocalKg(newKg);
    setLocalLbs(kgToLbs(newKg));
    // Update context directly in handler
    setWeightKg(newKg);
  };

  const handleLbsChange = (delta: number) => {
    const newLbs = Math.min(440, Math.max(88, localLbs + delta));
    setLocalLbs(newLbs);
    setLocalKg(lbsToKg(newLbs));
    // Update context directly in handler
    setWeightLbs(newLbs);
  };

  const handleContinue = () => {
    if (weightKg) {
      router.push('/physique');
    }
  };

  const handleBack = () => {
    router.push('/height');
  };

  // Number spinner component
  const NumberSpinner = ({
    value,
    onIncrease,
    onDecrease,
    onIncrease5,
    onDecrease5,
    label,
    suffix,
  }: {
    value: number;
    onIncrease: () => void;
    onDecrease: () => void;
    onIncrease5: () => void;
    onDecrease5: () => void;
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
      <div className="flex gap-2 mt-2">
        <button
          onClick={onDecrease5}
          className="px-2 py-1 text-xs text-neutral-500 hover:text-white hover:bg-neutral-800 rounded transition-colors"
        >
          -5
        </button>
        <button
          onClick={onIncrease5}
          className="px-2 py-1 text-xs text-neutral-500 hover:text-white hover:bg-neutral-800 rounded transition-colors"
        >
          +5
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
              <Scale className="w-6 h-6 text-[#00f3ff]" />
            </div>
          </div>
          <h1 className="text-2xl font-semibold tracking-tight text-center text-white mb-2">
            Enter Your Weight
          </h1>
          <p className="text-sm text-neutral-400 text-center">
            Used for body composition analysis
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
              lbs
            </button>
            <button
              onClick={() => setInputMode('metric')}
              className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
                inputMode === 'metric'
                  ? 'bg-[#00f3ff] text-black'
                  : 'text-neutral-400 hover:text-white'
              }`}
            >
              kg
            </button>
          </div>
        </div>

        {/* Weight Input */}
        <div className="flex justify-center gap-4 mb-8">
          {inputMode === 'imperial' ? (
            <NumberSpinner
              value={localLbs}
              onIncrease={() => handleLbsChange(1)}
              onDecrease={() => handleLbsChange(-1)}
              onIncrease5={() => handleLbsChange(5)}
              onDecrease5={() => handleLbsChange(-5)}
              label="POUNDS"
              suffix="lbs"
            />
          ) : (
            <NumberSpinner
              value={localKg}
              onIncrease={() => handleKgChange(1)}
              onDecrease={() => handleKgChange(-1)}
              onIncrease5={() => handleKgChange(5)}
              onDecrease5={() => handleKgChange(-5)}
              label="KILOGRAMS"
              suffix="kg"
            />
          )}
        </div>

        {/* Continue Button */}
        <button
          onClick={handleContinue}
          disabled={!weightKg}
          className={`
            w-full h-12 rounded-xl font-medium text-sm
            transition-all duration-200
            ${weightKg
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
