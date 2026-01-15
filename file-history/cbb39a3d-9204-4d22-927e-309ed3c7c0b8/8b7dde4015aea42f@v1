'use client';

import { useRouter } from 'next/navigation';
import { ArrowLeft, Check } from 'lucide-react';
import { useEthnicity, EthnicityOption, ethnicityLabels } from '@/contexts/EthnicityContext';

const ethnicityOptions: EthnicityOption[] = [
  'white',
  'black',
  'asian',
  'south-asian',
  'hispanic',
  'middle-eastern',
  'pacific-islander',
  'native-american',
  'mixed',
];

export default function EthnicityPage() {
  const router = useRouter();
  const { ethnicities, toggleEthnicity } = useEthnicity();

  const handleToggle = (option: EthnicityOption) => {
    toggleEthnicity(option);
  };

  const handleContinue = () => {
    if (ethnicities.length > 0) {
      router.push('/height');
    }
  };

  const handleBack = () => {
    router.push('/gender');
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
      {/* Back button - absolute positioned */}
      <button
        onClick={handleBack}
        className="absolute top-6 left-6 flex items-center gap-2 text-neutral-400 hover:text-white transition-colors text-sm"
      >
        <ArrowLeft className="w-4 h-4" />
        Back
      </button>

      <div className="w-full max-w-sm">
        {/* Header */}
        <div className="mb-10">
          <div className="flex justify-center mb-6">
            {/* Logo */}
            <div className="h-8 w-8 rounded bg-[#00f3ff]/20 flex items-center justify-center">
              <span className="text-[#00f3ff] text-sm font-bold">L</span>
            </div>
          </div>
          <h1 className="text-2xl font-semibold tracking-tight text-center text-white mb-2">
            Select Ethnicity
          </h1>
          <p className="text-sm text-neutral-400 text-center">
            This helps us provide accurate analysis
          </p>
        </div>

        {/* Ethnicity Options */}
        <div className="space-y-3">
          {ethnicityOptions.map((option) => {
            const isSelected = ethnicities.includes(option);
            return (
              <button
                key={option}
                onClick={() => handleToggle(option)}
                className={`
                  w-full h-14 rounded-xl border-2
                  flex items-center justify-between px-5
                  transition-all duration-200 cursor-pointer
                  ${isSelected
                    ? 'border-[#00f3ff] bg-[#00f3ff]/5'
                    : 'border-neutral-800 bg-black hover:border-neutral-700'
                  }
                `}
              >
                <span className={`
                  font-medium transition-colors duration-200
                  ${isSelected ? 'text-white' : 'text-neutral-300'}
                `}>
                  {ethnicityLabels[option]}
                </span>

                {/* Checkbox indicator */}
                <div className={`
                  w-5 h-5 rounded border-2 flex items-center justify-center
                  transition-all duration-200
                  ${isSelected
                    ? 'bg-[#00f3ff] border-[#00f3ff]'
                    : 'bg-transparent border-neutral-600'
                  }
                `}>
                  {isSelected && (
                    <Check className="w-3 h-3 text-black" strokeWidth={3} />
                  )}
                </div>
              </button>
            );
          })}
        </div>

        {/* Continue Button */}
        <button
          onClick={handleContinue}
          disabled={ethnicities.length === 0}
          className={`
            w-full h-12 mt-6 rounded-xl font-medium text-sm
            transition-all duration-200
            ${ethnicities.length > 0
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
