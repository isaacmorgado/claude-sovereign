'use client';

import { useEffect, useState } from 'react';
import { ResultsProvider } from '@/contexts/ResultsContext';
import { Results } from '@/components/results/Results';
import { LandmarkPoint, FRONT_PROFILE_LANDMARKS, SIDE_PROFILE_LANDMARKS } from '@/lib/landmarks';
import { Ethnicity, Gender } from '@/lib/faceiq-scoring';

// Note: Metadata cannot be exported from client components
// The page title is set in the root layout

// Demo data for testing - in production this would come from the analysis flow
const generateDemoLandmarks = (baseLandmarks: LandmarkPoint[]): LandmarkPoint[] => {
  return baseLandmarks.map(landmark => ({
    ...landmark,
    // Add slight randomization to simulate real placement
    x: landmark.x + (Math.random() - 0.5) * 0.02,
    y: landmark.y + (Math.random() - 0.5) * 0.02,
  }));
};

// Generate demo data outside component to avoid closure issues
const createDemoData = () => ({
  frontLandmarks: generateDemoLandmarks(FRONT_PROFILE_LANDMARKS),
  sideLandmarks: generateDemoLandmarks(SIDE_PROFILE_LANDMARKS),
  frontPhoto: '/demo-front.jpg',
  sidePhoto: '/demo-side.jpg',
  gender: 'male' as Gender,
  ethnicity: 'white' as Ethnicity,
});

export default function ResultsPage() {
  const [mounted, setMounted] = useState(false);
  const [initialData, setInitialData] = useState<{
    frontLandmarks: LandmarkPoint[];
    sideLandmarks: LandmarkPoint[];
    frontPhoto: string;
    sidePhoto?: string;
    gender: Gender;
    ethnicity?: Ethnicity;
  } | null>(null);

  useEffect(() => {
    // Mark as mounted (client-side only)
    setMounted(true);

    try {
      // Try to get data from sessionStorage (set by analysis page)
      const storedData = typeof window !== 'undefined'
        ? sessionStorage.getItem('analysisResults')
        : null;

      if (storedData) {
        const parsed = JSON.parse(storedData);
        setInitialData(parsed);
      } else {
        // No stored data - use demo data
        setInitialData(createDemoData());
      }
    } catch (e) {
      console.error('Failed to load analysis results:', e);
      // Use demo data as fallback
      setInitialData(createDemoData());
    }
  }, []);

  // Show loading state until mounted and data is ready
  if (!mounted || !initialData) {
    return (
      <div className="min-h-screen bg-black flex items-center justify-center">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-cyan-500 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-neutral-400">Loading your analysis...</p>
        </div>
      </div>
    );
  }

  return (
    <ResultsProvider initialData={initialData}>
      <Results />
    </ResultsProvider>
  );
}
