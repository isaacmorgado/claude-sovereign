'use client';

import { useRouter } from 'next/navigation';
import { useGender, Gender } from '@/contexts/GenderContext';
import { OnboardingProgress } from '@/components/onboarding/OnboardingProgress';

export default function GenderPage() {
  const router = useRouter();
  const { gender, setGender } = useGender();

  const handleSelect = (selectedGender: Gender) => {
    setGender(selectedGender);
  };

  const handleContinue = () => {
    if (gender) {
      router.push('/ethnicity');
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-black px-4">
      {/* Global Progress Bar */}
      <div className="fixed top-0 left-0 right-0 pt-4 px-4 bg-gradient-to-b from-black via-black/80 to-transparent pb-8 z-10">
        <OnboardingProgress currentStep="gender" />
      </div>

      <div className="w-full max-w-sm">
        {/* Header */}
        <div className="mb-10">
          <div className="flex justify-center mb-6">
            {/* Logo */}
            <div className="h-8 w-8 rounded bg-cyan-400/20 flex items-center justify-center">
              <span className="text-cyan-400 text-sm font-bold">L</span>
            </div>
          </div>
          <h1 className="text-2xl font-semibold tracking-tight text-center text-white mb-2">
            Select Gender
          </h1>
          <p className="text-sm text-neutral-400 text-center">
            Help us personalize your analysis
          </p>
        </div>

        {/* Gender Options */}
        <div className="space-y-3">
          {/* Male Button */}
          <button
            onClick={() => handleSelect('male')}
            className={`
              w-full h-14 rounded-xl border-2
              flex items-center justify-between px-5
              transition-all duration-200 cursor-pointer
              ${gender === 'male'
                ? 'border-cyan-400 bg-cyan-400/5'
                : 'border-neutral-800 bg-black hover:border-neutral-700'
              }
            `}
          >
            <span className={`
              font-medium transition-colors duration-200
              ${gender === 'male' ? 'text-white' : 'text-neutral-300'}
            `}>
              Male
            </span>
            {/* Radio indicator */}
            <div className={`
              w-5 h-5 rounded-full border-2 flex items-center justify-center
              transition-all duration-200
              ${gender === 'male'
                ? 'border-cyan-400 bg-cyan-400'
                : 'border-neutral-600 bg-transparent'
              }
            `}>
              {gender === 'male' && (
                <div className="w-2 h-2 rounded-full bg-black" />
              )}
            </div>
          </button>

          {/* Female Button */}
          <button
            onClick={() => handleSelect('female')}
            className={`
              w-full h-14 rounded-xl border-2
              flex items-center justify-between px-5
              transition-all duration-200 cursor-pointer
              ${gender === 'female'
                ? 'border-cyan-400 bg-cyan-400/5'
                : 'border-neutral-800 bg-black hover:border-neutral-700'
              }
            `}
          >
            <span className={`
              font-medium transition-colors duration-200
              ${gender === 'female' ? 'text-white' : 'text-neutral-300'}
            `}>
              Female
            </span>
            {/* Radio indicator */}
            <div className={`
              w-5 h-5 rounded-full border-2 flex items-center justify-center
              transition-all duration-200
              ${gender === 'female'
                ? 'border-cyan-400 bg-cyan-400'
                : 'border-neutral-600 bg-transparent'
              }
            `}>
              {gender === 'female' && (
                <div className="w-2 h-2 rounded-full bg-black" />
              )}
            </div>
          </button>
        </div>

        {/* Continue Button - Desktop */}
        <button
          onClick={handleContinue}
          disabled={!gender}
          className={`
            hidden md:block w-full h-12 mt-6 rounded-xl font-medium text-sm
            transition-all duration-200
            ${gender
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
          disabled={!gender}
          className={`
            w-full h-12 rounded-xl font-medium text-sm
            transition-all duration-200
            ${gender
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
