'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { useUpload } from '@/contexts/UploadContext';
import { useGender } from '@/contexts/GenderContext';
import { useEthnicity, EthnicityOption } from '@/contexts/EthnicityContext';
import { usePhysique } from '@/contexts/PhysiqueContext';
import { LandmarkAnalysisTool } from '@/components/LandmarkAnalysisTool';
import { LandmarkPoint } from '@/lib/landmarks';
import { Ethnicity } from '@/lib/harmony-scoring';
import { api } from '@/lib/api';

// Map EthnicityContext options to harmony-scoring Ethnicity type
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

type AnalysisStep = 'front' | 'side' | 'physique';

export default function AnalysisPage() {
  const router = useRouter();
  const { frontPhoto, sidePhoto } = useUpload();
  const { gender } = useGender();
  const { ethnicities } = useEthnicity();
  const {
    frontPhoto: physiqueFront,
    sidePhoto: physiqueSide,
    backPhoto: physiqueBack,
    hasAnyPhotos: hasPhysiquePhotos,
    skipped: physiqueSkipped,
    setPhysiqueAnalysis,
    setIsAnalyzing,
  } = usePhysique();
  const [currentStep, setCurrentStep] = useState<AnalysisStep>('front');
  const [frontLandmarks, setFrontLandmarks] = useState<LandmarkPoint[]>([]);
  const [sideLandmarks, setSideLandmarks] = useState<LandmarkPoint[]>([]);
  const [physiqueStatus, setPhysiqueStatus] = useState<'idle' | 'uploading' | 'analyzing' | 'done' | 'error'>('idle');
  const [physiqueError, setPhysiqueError] = useState<string | null>(null);
  const physiqueAnalysisStarted = useRef(false);

  // Get primary ethnicity for scoring (first selected, or 'other' if none/mixed)
  const primaryEthnicity: Ethnicity = ethnicities.length === 1
    ? mapEthnicityOption(ethnicities[0])
    : ethnicities.length > 1
      ? 'other'  // Mixed ethnicity
      : 'other'; // None selected

  // Handle physique analysis when entering physique step
  useEffect(() => {
    let isMounted = true;

    const runAnalysis = async () => {
      if (!hasPhysiquePhotos || physiqueSkipped) {
        if (isMounted) setPhysiqueStatus('done');
        return;
      }

      setIsAnalyzing(true);
      if (isMounted) setPhysiqueStatus('uploading');

      try {
        await api.uploadPhysiquePhotos(
          physiqueFront?.file,
          physiqueSide?.file,
          physiqueBack?.file
        );

        if (!isMounted) return;
        setPhysiqueStatus('analyzing');

        const genderValue = (gender || 'male') as 'male' | 'female';
        const result = await api.analyzePhysique(genderValue);

        if (!isMounted) return;

        setPhysiqueAnalysis({
          bodyFatPercent: result.estimated_body_fat,
          muscleMass: result.muscle_mass,
          frameSize: result.frame_size,
          shoulderWidth: result.shoulder_width,
          waistDefinition: result.waist_definition,
          posture: result.posture,
          confidence: result.confidence,
          notes: result.notes || undefined,
        });

        setPhysiqueStatus('done');
      } catch (error) {
        console.error('Physique analysis error:', error);
        if (isMounted) {
          setPhysiqueError(error instanceof Error ? error.message : 'Analysis failed');
          setPhysiqueStatus('error');
        }
      } finally {
        if (isMounted) setIsAnalyzing(false);
      }
    };

    if (currentStep === 'physique' && !physiqueAnalysisStarted.current) {
      physiqueAnalysisStarted.current = true;
      runAnalysis();
    }

    return () => {
      isMounted = false;
    };
  }, [currentStep, hasPhysiquePhotos, physiqueSkipped, physiqueFront, physiqueSide, physiqueBack, gender, setIsAnalyzing, setPhysiqueAnalysis]);

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
    } else if (hasPhysiquePhotos && !physiqueSkipped) {
      // Has physique photos, go to physique analysis step
      setCurrentStep('physique');
    } else {
      // No side photo, no physique - go directly to results
      navigateToResults(landmarks, []);
    }
  };

  const handleSideComplete = (landmarks: LandmarkPoint[]) => {
    setSideLandmarks(landmarks);
    if (hasPhysiquePhotos && !physiqueSkipped) {
      // Has physique photos, go to physique analysis step
      setCurrentStep('physique');
    } else {
      // No physique photos - go to results
      navigateToResults(frontLandmarks, landmarks);
    }
  };

  const handleBackFromFront = () => {
    router.push('/upload');
  };

  const handleBackFromSide = () => {
    setCurrentStep('front');
  };

  // Physique Analysis Step
  if (currentStep === 'physique') {
    return (
      <main className="min-h-screen bg-black flex flex-col items-center justify-center px-4">
        <div className="max-w-md w-full text-center">
          <h1 className="text-2xl font-semibold text-white mb-4">
            {physiqueStatus === 'uploading' && 'Uploading Body Photos...'}
            {physiqueStatus === 'analyzing' && 'Analyzing Body Composition...'}
            {physiqueStatus === 'done' && 'Analysis Complete!'}
            {physiqueStatus === 'error' && 'Analysis Error'}
            {physiqueStatus === 'idle' && 'Preparing Analysis...'}
          </h1>

          {(physiqueStatus === 'uploading' || physiqueStatus === 'analyzing' || physiqueStatus === 'idle') && (
            <div className="flex flex-col items-center gap-4">
              <div className="w-16 h-16 border-4 border-[#00f3ff] border-t-transparent rounded-full animate-spin" />
              <p className="text-neutral-400">
                {physiqueStatus === 'uploading' && 'Uploading your physique photos...'}
                {physiqueStatus === 'analyzing' && 'AI is analyzing your body composition...'}
                {physiqueStatus === 'idle' && 'Starting analysis...'}
              </p>
            </div>
          )}

          {physiqueStatus === 'done' && (
            <div className="flex flex-col items-center gap-4">
              <div className="w-16 h-16 bg-green-500/20 rounded-full flex items-center justify-center">
                <svg className="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <p className="text-neutral-400">Body composition analysis complete!</p>
              <button
                onClick={() => navigateToResults(frontLandmarks, sideLandmarks)}
                className="h-12 px-8 rounded-xl bg-[#00f3ff] text-black font-medium hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] transition-all"
              >
                View Results
              </button>
            </div>
          )}

          {physiqueStatus === 'error' && (
            <div className="flex flex-col items-center gap-4">
              <div className="w-16 h-16 bg-red-500/20 rounded-full flex items-center justify-center">
                <svg className="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </div>
              <p className="text-red-400">{physiqueError}</p>
              <p className="text-neutral-500 text-sm">Body analysis failed, but you can still see your face analysis results.</p>
              <button
                onClick={() => navigateToResults(frontLandmarks, sideLandmarks)}
                className="h-12 px-8 rounded-xl bg-[#00f3ff] text-black font-medium hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] transition-all"
              >
                Continue to Results
              </button>
            </div>
          )}
        </div>
      </main>
    );
  }

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
