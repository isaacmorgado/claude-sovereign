'use client';

import { useState, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useDropzone } from 'react-dropzone';
import {
  Upload,
  X,
  Image as ImageIcon,
  ArrowRight,
  ArrowLeft,
  User,
  UserCircle,
  Check,
  SkipForward,
} from 'lucide-react';
import { usePhysique, PhysiqueAngle } from '@/contexts/PhysiqueContext';
import { OnboardingProgress } from '@/components/onboarding/OnboardingProgress';

const stepConfig: Record<
  PhysiqueAngle,
  { title: string; subtitle: string; icon: typeof User; tip: string }
> = {
  front: {
    title: 'Front Body Photo',
    subtitle: 'Stand facing the camera with arms relaxed at your sides',
    icon: User,
    tip: 'Tip: Wear fitted clothing, stand straight with good posture',
  },
  side: {
    title: 'Side Body Photo',
    subtitle: 'Turn 90° to show your side profile',
    icon: UserCircle,
    tip: 'Tip: Stand naturally, keep arms at sides or slightly behind',
  },
  back: {
    title: 'Back Body Photo',
    subtitle: 'Face away from the camera showing your back',
    icon: User,
    tip: 'Tip: Stand straight, let arms hang naturally',
  },
};

const stepOrder: PhysiqueAngle[] = ['front', 'side', 'back'];

export default function PhysiquePage() {
  const router = useRouter();
  const {
    frontPhoto,
    sidePhoto,
    backPhoto,
    setFrontPhoto,
    setSidePhoto,
    setBackPhoto,
    setSkipped,
  } = usePhysique();
  const [currentStep, setCurrentStep] = useState<PhysiqueAngle>('front');

  const getPhotoForStep = (step: PhysiqueAngle) => {
    switch (step) {
      case 'front':
        return frontPhoto;
      case 'side':
        return sidePhoto;
      case 'back':
        return backPhoto;
    }
  };

  const setPhotoForStep = (step: PhysiqueAngle) => {
    switch (step) {
      case 'front':
        return setFrontPhoto;
      case 'side':
        return setSidePhoto;
      case 'back':
        return setBackPhoto;
    }
  };

  const currentPhoto = getPhotoForStep(currentStep);
  const setCurrentPhoto = setPhotoForStep(currentStep);

  const onDrop = useCallback(
    (acceptedFiles: File[]) => {
      const selectedFile = acceptedFiles[0];
      if (selectedFile) {
        // Revoke old URL to prevent memory leak
        if (currentPhoto?.preview) {
          URL.revokeObjectURL(currentPhoto.preview);
        }
        const objectUrl = URL.createObjectURL(selectedFile);
        setCurrentPhoto({ file: selectedFile, preview: objectUrl });
      }
    },
    [setCurrentPhoto, currentPhoto]
  );

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.webp'],
    },
    maxFiles: 1,
    multiple: false,
  });

  const removeImage = () => {
    if (currentPhoto?.preview) {
      URL.revokeObjectURL(currentPhoto.preview);
    }
    setCurrentPhoto(null);
  };

  const currentStepIndex = stepOrder.indexOf(currentStep);

  const handleNext = () => {
    if (currentStepIndex < stepOrder.length - 1) {
      setCurrentStep(stepOrder[currentStepIndex + 1]);
    } else {
      // All done, go to face upload
      router.push('/upload');
    }
  };

  const handleBack = () => {
    if (currentStepIndex > 0) {
      setCurrentStep(stepOrder[currentStepIndex - 1]);
    } else {
      router.push('/weight');
    }
  };

  const handleSkip = () => {
    setSkipped(true);
    router.push('/upload');
  };

  const config = stepConfig[currentStep];
  const StepIcon = config.icon;

  const canProceed = currentPhoto !== null;
  const hasAnyPhoto = !!(frontPhoto || sidePhoto || backPhoto);

  return (
    <main className="min-h-screen bg-black flex flex-col items-center justify-center px-4 py-12">
      {/* Global Progress Bar */}
      <div className="fixed top-0 left-0 right-0 pt-4 px-4 bg-gradient-to-b from-black via-black/80 to-transparent pb-8 z-10">
        <OnboardingProgress currentStep="physique" />
      </div>

      {/* Back button */}
      <button
        onClick={handleBack}
        className="fixed top-16 left-6 flex items-center gap-2 text-neutral-400 hover:text-white transition-colors text-sm z-20"
      >
        <ArrowLeft className="w-4 h-4" />
        Back
      </button>

      {/* Skip button */}
      <button
        onClick={handleSkip}
        className="fixed top-16 right-6 flex items-center gap-2 text-neutral-400 hover:text-white transition-colors text-sm z-20"
      >
        Skip
        <SkipForward className="w-4 h-4" />
      </button>

      {/* Logo */}
      <div className="flex justify-center mb-8">
        <div className="h-8 w-8 rounded bg-cyan-400/20 flex items-center justify-center">
          <span className="text-cyan-400 text-sm font-bold">L</span>
        </div>
      </div>

      {/* Progress Steps */}
      <div className="flex items-center gap-3 mb-8">
        {stepOrder.map((step, index) => (
          <div key={step} className="flex items-center gap-3">
            <div className="flex items-center gap-2">
              <div
                className={`
                  w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold
                  transition-all duration-200
                  ${
                    currentStep === step || getPhotoForStep(step)
                      ? 'bg-cyan-400 text-black'
                      : 'bg-neutral-800 text-neutral-500'
                  }
                `}
              >
                {getPhotoForStep(step) ? (
                  <Check className="w-4 h-4" />
                ) : (
                  index + 1
                )}
              </div>
              <span
                className={`text-sm hidden sm:block ${
                  currentStep === step
                    ? 'text-white font-medium'
                    : 'text-neutral-500'
                }`}
              >
                {step.charAt(0).toUpperCase() + step.slice(1)}
              </span>
            </div>
            {index < stepOrder.length - 1 && (
              <div
                className={`w-8 h-0.5 ${
                  getPhotoForStep(step) ? 'bg-cyan-400' : 'bg-neutral-800'
                } transition-colors duration-200`}
              />
            )}
          </div>
        ))}
      </div>

      {/* Header */}
      <div className="text-center mb-8">
        <div className="flex items-center justify-center gap-3 mb-3">
          <StepIcon className="w-6 h-6 text-cyan-400" />
          <h1 className="text-2xl md:text-3xl font-semibold tracking-tight text-white">
            {config.title}
          </h1>
        </div>
        <p className="text-neutral-400 text-sm md:text-base max-w-md mx-auto">
          {config.subtitle}
        </p>
        <p className="text-neutral-500 text-xs mt-2">
          Body photos are optional but improve scoring accuracy
        </p>
      </div>

      {/* Upload Container */}
      <div className="w-full max-w-xl">
        {!currentPhoto ? (
          <div
            {...getRootProps()}
            className={`
              relative w-full aspect-[3/4] rounded-xl border-2 border-dashed
              flex flex-col items-center justify-center gap-4
              cursor-pointer transition-all duration-200
              ${
                isDragActive
                  ? 'border-cyan-400 bg-cyan-400/5'
                  : 'border-neutral-700 bg-neutral-900/50 hover:border-neutral-600 hover:bg-neutral-900'
              }
            `}
          >
            <input {...getInputProps()} />

            {/* Upload Icon */}
            <div
              className={`
                p-5 rounded-full transition-colors duration-200
                ${isDragActive ? 'bg-cyan-400/20' : 'bg-neutral-800'}
              `}
            >
              <Upload
                className={`
                  w-10 h-10 transition-colors duration-200
                  ${isDragActive ? 'text-cyan-400' : 'text-neutral-500'}
                `}
              />
            </div>

            {/* Text */}
            <div className="text-center px-4">
              <p
                className={`
                  text-base font-medium transition-colors duration-200
                  ${isDragActive ? 'text-cyan-400' : 'text-neutral-300'}
                `}
              >
                {isDragActive
                  ? 'Drop your image here'
                  : 'Drag & drop your image here'}
              </p>
              <p className="text-neutral-500 mt-1.5 text-sm">
                or{' '}
                <span className="text-neutral-300 underline underline-offset-2">
                  browse
                </span>{' '}
                to upload
              </p>
            </div>

            {/* Supported formats */}
            <div className="flex items-center gap-2 text-xs text-neutral-500 mt-2">
              <ImageIcon className="w-4 h-4" />
              <span>JPG, PNG, WEBP supported</span>
            </div>

            {/* Photo guide hint */}
            <div className="absolute bottom-4 left-4 right-4 text-center">
              <p className="text-xs text-neutral-500">{config.tip}</p>
            </div>
          </div>
        ) : (
          /* Preview */
          <div className="relative w-full aspect-[3/4] rounded-xl overflow-hidden bg-neutral-900 border border-neutral-800">
            {/* Image */}
            <Image
              src={currentPhoto.preview}
              alt={`${currentStep} preview`}
              fill
              className="object-contain"
              unoptimized
            />

            {/* Photo type badge */}
            <div className="absolute top-4 left-4 px-3 py-1.5 rounded-full bg-black/80 border border-neutral-700 z-10">
              <span className="text-white text-sm font-medium flex items-center gap-2">
                <StepIcon className="w-4 h-4 text-cyan-400" />
                {config.title}
              </span>
            </div>

            {/* Remove button */}
            <button
              onClick={removeImage}
              className="
                absolute top-4 right-4 p-2 rounded-full
                bg-black/80 border border-neutral-700
                text-neutral-400 hover:text-white hover:border-neutral-600
                transition-all duration-200 z-10
              "
            >
              <X className="w-5 h-5" />
            </button>

            {/* Upload status */}
            <div className="absolute bottom-4 left-4 right-4 px-4 py-3 rounded-lg bg-black/80 border border-neutral-700 z-10">
              <p className="text-white font-medium text-sm flex items-center gap-2">
                <Check className="w-4 h-4 text-cyan-400" />
                Photo uploaded successfully
              </p>
              <p className="text-neutral-500 text-xs mt-0.5">
                Ready for next step
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Navigation Buttons - Desktop */}
      <div className="hidden md:flex items-center gap-4 mt-8">
        {/* Back Button */}
        <button
          onClick={handleBack}
          className="h-12 px-6 rounded-xl font-medium flex items-center gap-2 border border-neutral-700 bg-black text-white hover:bg-white/5 hover:border-neutral-600 transition-all duration-200"
        >
          <ArrowLeft className="w-4 h-4" />
          Back
        </button>

        {/* Next/Skip Button */}
        {canProceed ? (
          <button
            onClick={handleNext}
            className="h-12 px-8 rounded-xl font-medium text-base flex items-center gap-2 transition-all duration-200 bg-cyan-400 text-black hover:shadow-[0_0_20px_rgba(34,211,238,0.3)] cursor-pointer"
          >
            {currentStepIndex < stepOrder.length - 1
              ? `Next: ${stepOrder[currentStepIndex + 1].charAt(0).toUpperCase() + stepOrder[currentStepIndex + 1].slice(1)}`
              : 'Continue to Face Photos'}
            <ArrowRight className="w-4 h-4" />
          </button>
        ) : (
          <button
            onClick={handleNext}
            className="h-12 px-8 rounded-xl font-medium text-base flex items-center gap-2 transition-all duration-200 border border-neutral-700 text-neutral-400 hover:text-white hover:border-neutral-600 cursor-pointer"
          >
            Skip This Step
            <SkipForward className="w-4 h-4" />
          </button>
        )}
      </div>

      {/* Fixed Bottom Navigation - Mobile Only */}
      <div className="fixed bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black via-black/95 to-transparent md:hidden z-30">
        <div className="flex items-center gap-3">
          <button
            onClick={handleBack}
            className="h-12 px-4 rounded-xl font-medium flex items-center gap-2 border border-neutral-700 bg-black text-white transition-all duration-200"
          >
            <ArrowLeft className="w-4 h-4" />
          </button>
          {canProceed ? (
            <button
              onClick={handleNext}
              className="flex-1 h-12 rounded-xl font-medium text-sm flex items-center justify-center gap-2 bg-cyan-400 text-black transition-all duration-200"
            >
              {currentStepIndex < stepOrder.length - 1
                ? `Next: ${stepOrder[currentStepIndex + 1].charAt(0).toUpperCase() + stepOrder[currentStepIndex + 1].slice(1)}`
                : 'Continue to Face Photos'}
              <ArrowRight className="w-4 h-4" />
            </button>
          ) : (
            <button
              onClick={handleNext}
              className="flex-1 h-12 rounded-xl font-medium text-sm flex items-center justify-center gap-2 border border-neutral-700 text-neutral-400 transition-all duration-200"
            >
              Skip This Step
              <SkipForward className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>

      {/* Thumbnails for uploaded photos */}
      {hasAnyPhoto && (
        <div className="mt-8 flex items-center gap-4">
          <span className="text-neutral-500 text-sm">Uploaded:</span>
          {stepOrder.map((step) => {
            const photo = getPhotoForStep(step);
            if (!photo) return null;
            return (
              <button
                key={step}
                className={`relative w-14 h-18 rounded-lg overflow-hidden border-2 ${
                  currentStep === step ? 'border-cyan-400' : 'border-neutral-700'
                } cursor-pointer hover:opacity-90 transition-opacity`}
                onClick={() => setCurrentStep(step)}
              >
                <Image
                  src={photo.preview}
                  alt={`${step} photo thumbnail`}
                  fill
                  className="object-cover"
                  unoptimized
                />
                <div className="absolute inset-0 bg-black/30 flex items-center justify-center">
                  <span className="text-white text-xs font-medium">
                    {step.charAt(0).toUpperCase()}
                  </span>
                </div>
              </button>
            );
          })}
        </div>
      )}
    </main>
  );
}
