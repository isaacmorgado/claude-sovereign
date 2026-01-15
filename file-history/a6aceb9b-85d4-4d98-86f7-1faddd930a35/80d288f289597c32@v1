'use client';

import { useRouter } from 'next/navigation';
import { useGender, Gender } from '@/contexts/GenderContext';

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
                ? 'border-[#00f3ff] bg-[#00f3ff]/5'
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
                ? 'border-[#00f3ff] bg-[#00f3ff]'
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
                ? 'border-[#00f3ff] bg-[#00f3ff]/5'
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
                ? 'border-[#00f3ff] bg-[#00f3ff]'
                : 'border-neutral-600 bg-transparent'
              }
            `}>
              {gender === 'female' && (
                <div className="w-2 h-2 rounded-full bg-black" />
              )}
            </div>
          </button>
        </div>

        {/* Continue Button */}
        <button
          onClick={handleContinue}
          disabled={!gender}
          className={`
            w-full h-12 mt-6 rounded-xl font-medium text-sm
            transition-all duration-200
            ${gender
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
