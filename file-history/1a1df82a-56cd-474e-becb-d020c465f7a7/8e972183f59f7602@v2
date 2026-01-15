'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useUpload } from '@/contexts/UploadContext';
import { useGender } from '@/contexts/GenderContext';
import { useEthnicity, EthnicityOption } from '@/contexts/EthnicityContext';
import { LandmarkAnalysisTool } from '@/components/LandmarkAnalysisTool';
import { LandmarkPoint } from '@/lib/landmarks';
import { Ethnicity } from '@/lib/faceiq-scoring';

// Map EthnicityContext options to faceiq-scoring Ethnicity type
function mapEthnicityOption(option: EthnicityOption): Ethnicity {
  const mapping: Record<EthnicityOption, Ethnicity> = {
    'white': 'white',
    'black': 'black',
    'asian': 'east_asian',
    'south-asian': 'south_asian',
    'hispanic': 'hispanic',
    'middle-eastern': 'middle_eastern',
    'pacific-islander': 'pacific_islander',
    'native-american': 'native_american',
    'mixed': 'other',
  };
  return mapping[option] || 'other';
}

type AnalysisStep = 'front' | 'side';

export default function AnalysisPage() {
  const router = useRouter();
  const { frontPhoto, sidePhoto } = useUpload();
  const { gender } = useGender();
  const { ethnicities } = useEthnicity();
  const [currentStep, setCurrentStep] = useState<AnalysisStep>('front');
  const [frontLandmarks, setFrontLandmarks] = useState<LandmarkPoint[]>([]);
  // Side landmarks are passed directly through handlers, no need to store in state
  const [, setSideLandmarks] = useState<LandmarkPoint[]>([]);

  // Get primary ethnicity for scoring (first selected, or 'other' if none/mixed)
  const primaryEthnicity: Ethnicity = ethnicities.length === 1
    ? mapEthnicityOption(ethnicities[0])
    : ethnicities.length > 1
      ? 'other'  // Mixed ethnicity
      : 'other'; // None selected

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

  // Navigate to results page with stored data
  const navigateToResults = (front: LandmarkPoint[], side: LandmarkPoint[]) => {
    // Store analysis data in sessionStorage for the results page
    const analysisResults = {
      frontLandmarks: front,
      sideLandmarks: side,
      frontPhoto: frontPhoto?.preview || '',
      sidePhoto: sidePhoto?.preview,
      gender: gender || 'male',
      ethnicity: primaryEthnicity,
    };

    sessionStorage.setItem('analysisResults', JSON.stringify(analysisResults));
    router.push('/results');
  };

  const handleFrontComplete = (landmarks: LandmarkPoint[]) => {
    setFrontLandmarks(landmarks);
    if (sidePhoto) {
      setCurrentStep('side');
    } else {
      // No side photo - go directly to results
      navigateToResults(landmarks, []);
    }
  };

  const handleSideComplete = (landmarks: LandmarkPoint[]) => {
    setSideLandmarks(landmarks);
    // Both front and side complete - go to results
    navigateToResults(frontLandmarks, landmarks);
  };

  const handleBackFromFront = () => {
    router.push('/upload');
  };

  const handleBackFromSide = () => {
    setCurrentStep('front');
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

  return null;
}
