'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useUpload } from '@/contexts/UploadContext';
import { useGender } from '@/contexts/GenderContext';
import { LandmarkAnalysisTool } from '@/components/LandmarkAnalysisTool';
import { ResultsDashboard } from '@/components/ResultsDashboard';
import { LandmarkPoint } from '@/lib/landmarks';

type AnalysisStep = 'front' | 'side' | 'results';

export default function AnalysisPage() {
  const router = useRouter();
  const { frontPhoto, sidePhoto } = useUpload();
  const { gender } = useGender();
  const [currentStep, setCurrentStep] = useState<AnalysisStep>('front');
  const [frontLandmarks, setFrontLandmarks] = useState<LandmarkPoint[]>([]);
  const [sideLandmarks, setSideLandmarks] = useState<LandmarkPoint[]>([]);

  // Redirect if no photos uploaded
  if (!frontPhoto && !sidePhoto) {
    return (
      <main className="min-h-screen bg-black flex flex-col items-center justify-center px-4">
        <div className="text-center">
          <h1 className="text-2xl font-semibold text-white mb-4">No Photos Found</h1>
          <p className="text-neutral-400 mb-8">
            Please upload your photos first to begin the analysis.
          </p>
          <button
            onClick={() => router.push('/upload')}
            className="h-12 px-8 rounded-xl bg-[#00f3ff] text-black font-medium hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] transition-all"
          >
            Go to Upload
          </button>
        </div>
      </main>
    );
  }

  const handleFrontComplete = (landmarks: LandmarkPoint[]) => {
    setFrontLandmarks(landmarks);
    if (sidePhoto) {
      setCurrentStep('side');
    } else {
      setCurrentStep('results');
    }
  };

  const handleSideComplete = (landmarks: LandmarkPoint[]) => {
    setSideLandmarks(landmarks);
    setCurrentStep('results');
  };

  const handleBackFromFront = () => {
    router.push('/upload');
  };

  const handleBackFromSide = () => {
    setCurrentStep('front');
  };

  const handleBackFromResults = () => {
    setCurrentStep(sidePhoto ? 'side' : 'front');
  };

  // Front Profile Analysis
  if (currentStep === 'front' && frontPhoto) {
    return (
      <LandmarkAnalysisTool
        imageUrl={frontPhoto.preview}
        mode="front"
        onLandmarksChange={setFrontLandmarks}
        onComplete={handleFrontComplete}
        onBack={handleBackFromFront}
      />
    );
  }

  // Side Profile Analysis
  if (currentStep === 'side' && sidePhoto) {
    return (
      <LandmarkAnalysisTool
        imageUrl={sidePhoto.preview}
        mode="side"
        onLandmarksChange={setSideLandmarks}
        onComplete={handleSideComplete}
        onBack={handleBackFromSide}
      />
    );
  }

  // Results Dashboard
  if (currentStep === 'results') {
    return (
      <main className="min-h-screen bg-black">
        <div className="max-w-6xl mx-auto px-4 py-8">
          <button
            onClick={handleBackFromResults}
            className="flex items-center gap-2 text-neutral-400 hover:text-white transition-colors text-sm mb-6"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
            Back to Analysis
          </button>
          <ResultsDashboard
            frontLandmarks={frontLandmarks}
            sideLandmarks={sideLandmarks}
            gender={gender || 'male'}
          />
        </div>
      </main>
    );
  }

  return null;
}
