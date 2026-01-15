'use client';

import { motion } from 'framer-motion';

export type OnboardingStep = 'gender' | 'ethnicity' | 'height' | 'weight' | 'physique' | 'photos' | 'analysis';

const STEPS: { key: OnboardingStep; label: string }[] = [
  { key: 'gender', label: 'Gender' },
  { key: 'ethnicity', label: 'Ethnicity' },
  { key: 'height', label: 'Height' },
  { key: 'weight', label: 'Weight' },
  { key: 'physique', label: 'Physique' },
  { key: 'photos', label: 'Photos' },
  { key: 'analysis', label: 'Analysis' },
];

interface OnboardingProgressProps {
  currentStep: OnboardingStep;
  className?: string;
}

export function OnboardingProgress({ currentStep, className = '' }: OnboardingProgressProps) {
  const currentIndex = STEPS.findIndex(s => s.key === currentStep);
  const progress = ((currentIndex + 1) / STEPS.length) * 100;

  return (
    <div className={`w-full max-w-lg mx-auto ${className}`}>
      {/* Progress bar */}
      <div className="relative h-1 bg-neutral-800 rounded-full overflow-hidden mb-3">
        <motion.div
          className="absolute inset-y-0 left-0 bg-gradient-to-r from-cyan-400 to-cyan-300 rounded-full"
          initial={{ width: 0 }}
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.4, ease: 'easeOut' }}
        />
      </div>

      {/* Step indicators */}
      <div className="flex justify-between items-center">
        {STEPS.map((step, index) => {
          const isCompleted = index < currentIndex;
          const isCurrent = index === currentIndex;

          return (
            <div
              key={step.key}
              className="flex flex-col items-center"
            >
              {/* Dot indicator */}
              <motion.div
                className={`w-2 h-2 rounded-full transition-colors duration-200 ${
                  isCompleted
                    ? 'bg-cyan-400'
                    : isCurrent
                    ? 'bg-cyan-400'
                    : 'bg-neutral-700'
                }`}
                initial={false}
                animate={{
                  scale: isCurrent ? 1.5 : 1,
                }}
                transition={{ duration: 0.2 }}
              />
              {/* Label (only show on larger screens) */}
              <span
                className={`text-[10px] mt-1.5 hidden sm:block transition-colors duration-200 ${
                  isCurrent
                    ? 'text-cyan-400 font-medium'
                    : isCompleted
                    ? 'text-neutral-400'
                    : 'text-neutral-600'
                }`}
              >
                {step.label}
              </span>
            </div>
          );
        })}
      </div>

      {/* Mobile: Current step label */}
      <div className="sm:hidden text-center mt-2">
        <span className="text-xs text-neutral-400">
          Step {currentIndex + 1} of {STEPS.length}:
        </span>
        <span className="text-xs text-cyan-400 ml-1 font-medium">
          {STEPS[currentIndex]?.label}
        </span>
      </div>
    </div>
  );
}

// Compact version for tight spaces
export function OnboardingProgressCompact({ currentStep, className = '' }: OnboardingProgressProps) {
  const currentIndex = STEPS.findIndex(s => s.key === currentStep);
  const progress = ((currentIndex + 1) / STEPS.length) * 100;

  return (
    <div className={`w-full ${className}`}>
      <div className="flex items-center gap-2">
        <div className="flex-1 h-1 bg-neutral-800 rounded-full overflow-hidden">
          <motion.div
            className="h-full bg-cyan-400 rounded-full"
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.4, ease: 'easeOut' }}
          />
        </div>
        <span className="text-xs text-neutral-500 tabular-nums">
          {currentIndex + 1}/{STEPS.length}
        </span>
      </div>
    </div>
  );
}
