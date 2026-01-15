'use client';

import { useState, useCallback, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { useDropzone } from 'react-dropzone';
import { Upload, X, Image as ImageIcon, ArrowRight, ArrowLeft, User, UserCircle, Check } from 'lucide-react';
import { useUpload } from '@/contexts/UploadContext';
import { preloadFaceDetection } from '@/lib/faceDetectionService';
import { OnboardingProgress } from '@/components/onboarding/OnboardingProgress';

type UploadStep = 'front' | 'side';

export default function UploadPage() {
  const router = useRouter();
  const { frontPhoto, sidePhoto, setFrontPhoto, setSidePhoto } = useUpload();
  const [currentStep, setCurrentStep] = useState<UploadStep>('front');

  // Preload face detection model while user is uploading photos
  useEffect(() => {
    preloadFaceDetection().catch(console.error);
  }, []);

  const currentPhoto = currentStep === 'front' ? frontPhoto : sidePhoto;
  const setCurrentPhoto = currentStep === 'front' ? setFrontPhoto : setSidePhoto;

  const onDrop = useCallback((acceptedFiles: File[]) => {
    const selectedFile = acceptedFiles[0];
    if (selectedFile) {
      // Revoke old URL to prevent memory leak
      if (currentPhoto?.preview) {
        URL.revokeObjectURL(currentPhoto.preview);
      }
      const objectUrl = URL.createObjectURL(selectedFile);
      setCurrentPhoto({ file: selectedFile, preview: objectUrl });
    }
  }, [setCurrentPhoto, currentPhoto]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.webp']
    },
    maxFiles: 1,
    multiple: false
  });

  const removeImage = () => {
    if (currentPhoto?.preview) {
      URL.revokeObjectURL(currentPhoto.preview);
    }
    setCurrentPhoto(null);
  };

  const handleNext = () => {
    if (currentStep === 'front' && frontPhoto) {
      setCurrentStep('side');
    } else if (currentStep === 'side' && sidePhoto) {
      router.push('/analysis');
    }
  };

  const handleBack = () => {
    if (currentStep === 'side') {
      setCurrentStep('front');
    } else {
      router.push('/physique');
    }
  };

  const stepConfig = {
    front: {
      title: 'Upload Front-Facing Photo',
      subtitle: 'Upload a clear, front-facing photo looking straight at the camera',
      icon: User,
    },
    side: {
      title: 'Upload Side Profile Photo',
      subtitle: 'Upload a clear side profile photo showing your facial structure',
      icon: UserCircle,
    },
  };

  const config = stepConfig[currentStep];
  const StepIcon = config.icon;

  return (
    <main className="min-h-screen bg-black flex flex-col items-center justify-center px-4 py-12">
      {/* Global Progress Bar */}
      <div className="fixed top-0 left-0 right-0 pt-4 px-4 bg-gradient-to-b from-black via-black/80 to-transparent pb-8 z-10">
        <OnboardingProgress currentStep="photos" />
      </div>

      {/* Back button */}
      <button
        onClick={handleBack}
        className="fixed top-16 left-6 flex items-center gap-2 text-neutral-400 hover:text-white transition-colors text-sm z-20"
      >
        <ArrowLeft className="w-4 h-4" />
        Back
      </button>

      {/* Logo */}
      <div className="flex justify-center mb-8">
        <div className="h-8 w-8 rounded bg-cyan-400/20 flex items-center justify-center">
          <span className="text-cyan-400 text-sm font-bold">L</span>
        </div>
      </div>

      {/* Progress Steps */}
      <div className="flex items-center gap-4 mb-8">
        {/* Step 1 */}
        <div className="flex items-center gap-2">
          <div className={`
            w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold
            transition-all duration-200
            ${currentStep === 'front' || frontPhoto
              ? 'bg-cyan-400 text-black'
              : 'bg-neutral-800 text-neutral-500'
            }
          `}>
            {frontPhoto ? <Check className="w-4 h-4" /> : '1'}
          </div>
          <span className={`text-sm hidden sm:block ${currentStep === 'front' ? 'text-white font-medium' : 'text-neutral-500'}`}>
            Front Photo
          </span>
        </div>

        {/* Connector */}
        <div className={`w-12 h-0.5 ${frontPhoto ? 'bg-cyan-400' : 'bg-neutral-800'} transition-colors duration-200`} />

        {/* Step 2 */}
        <div className="flex items-center gap-2">
          <div className={`
            w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold
            transition-all duration-200
            ${currentStep === 'side'
              ? 'bg-cyan-400 text-black'
              : sidePhoto
                ? 'bg-cyan-400 text-black'
                : 'bg-neutral-800 text-neutral-500'
            }
          `}>
            {sidePhoto ? <Check className="w-4 h-4" /> : '2'}
          </div>
          <span className={`text-sm hidden sm:block ${currentStep === 'side' ? 'text-white font-medium' : 'text-neutral-500'}`}>
            Side Profile
          </span>
        </div>
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
      </div>

      {/* Upload Container */}
      <div className="w-full max-w-xl">
        {!currentPhoto ? (
          <div
            {...getRootProps()}
            className={`
              relative w-full aspect-[4/3] rounded-xl border-2 border-dashed
              flex flex-col items-center justify-center gap-4
              cursor-pointer transition-all duration-200
              ${isDragActive
                ? 'border-cyan-400 bg-cyan-400/5'
                : 'border-neutral-700 bg-neutral-900/50 hover:border-neutral-600 hover:bg-neutral-900'
              }
            `}
          >
            <input {...getInputProps()} />

            {/* Upload Icon */}
            <div className={`
              p-5 rounded-full transition-colors duration-200
              ${isDragActive ? 'bg-cyan-400/20' : 'bg-neutral-800'}
            `}>
              <Upload className={`
                w-10 h-10 transition-colors duration-200
                ${isDragActive ? 'text-cyan-400' : 'text-neutral-500'}
              `} />
            </div>

            {/* Text */}
            <div className="text-center px-4">
              <p className={`
                text-base font-medium transition-colors duration-200
                ${isDragActive ? 'text-cyan-400' : 'text-neutral-300'}
              `}>
                {isDragActive ? 'Drop your image here' : 'Drag & drop your image here'}
              </p>
              <p className="text-neutral-500 mt-1.5 text-sm">
                or <span className="text-neutral-300 underline underline-offset-2">browse</span> to upload
              </p>
            </div>

            {/* Supported formats */}
            <div className="flex items-center gap-2 text-xs text-neutral-500 mt-2">
              <ImageIcon className="w-4 h-4" />
              <span>JPG, PNG, WEBP supported</span>
            </div>

            {/* Photo guide hint */}
            <div className="absolute bottom-4 left-4 right-4 text-center">
              <p className="text-xs text-neutral-500">
                {currentStep === 'front'
                  ? 'Tip: Face the camera directly with neutral expression'
                  : 'Tip: Turn 90° to show your side profile clearly'
                }
              </p>
            </div>
          </div>
        ) : (
          /* Preview */
          <div className="relative w-full aspect-[4/3] rounded-xl overflow-hidden bg-neutral-900 border border-neutral-800">
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
                {currentStep === 'front' ? 'Front Photo' : 'Side Profile'}
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
                Ready for analysis
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

        {/* Next Button */}
        <button
          onClick={handleNext}
          disabled={!currentPhoto}
          className={`
            h-12 px-8 rounded-xl font-medium text-base
            flex items-center gap-2
            transition-all duration-200
            ${currentPhoto
              ? 'bg-cyan-400 text-black hover:shadow-[0_0_20px_rgba(34,211,238,0.3)] cursor-pointer'
              : 'bg-neutral-800 text-neutral-500 cursor-not-allowed'
            }
          `}
        >
          {currentStep === 'front' ? 'Next: Side Profile' : 'Start Analysis'}
          <ArrowRight className="w-4 h-4" />
        </button>
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
          <button
            onClick={handleNext}
            disabled={!currentPhoto}
            className={`
              flex-1 h-12 rounded-xl font-medium text-sm
              flex items-center justify-center gap-2
              transition-all duration-200
              ${currentPhoto
                ? 'bg-cyan-400 text-black'
                : 'bg-neutral-800 text-neutral-500'
              }
            `}
          >
            {currentStep === 'front' ? 'Next: Side Profile' : 'Start Analysis'}
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Thumbnails for both photos when on step 2 */}
      {currentStep === 'side' && frontPhoto && (
        <div className="mt-8 flex items-center gap-4">
          <span className="text-neutral-500 text-sm">Uploaded:</span>
          <button
            className="relative w-16 h-16 rounded-lg overflow-hidden border-2 border-cyan-400 cursor-pointer hover:opacity-90 transition-opacity"
            onClick={() => setCurrentStep('front')}
          >
            <Image
              src={frontPhoto.preview}
              alt="Front photo thumbnail"
              fill
              className="object-cover"
              unoptimized
            />
            <div className="absolute inset-0 bg-black/30 flex items-center justify-center">
              <User className="w-5 h-5 text-white" />
            </div>
          </button>
          {sidePhoto && (
            <div className="relative w-16 h-16 rounded-lg overflow-hidden border-2 border-cyan-400">
              <Image
                src={sidePhoto.preview}
                alt="Side photo thumbnail"
                fill
                className="object-cover"
                unoptimized
              />
              <div className="absolute inset-0 bg-black/30 flex items-center justify-center">
                <UserCircle className="w-5 h-5 text-white" />
              </div>
            </div>
          )}
        </div>
      )}
    </main>
  );
}
