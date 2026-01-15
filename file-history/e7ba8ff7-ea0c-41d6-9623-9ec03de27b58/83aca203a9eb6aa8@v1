'use client';

import { useState, useRef, useCallback, useEffect } from 'react';
import Image from 'next/image';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Loader2,
  RefreshCw,
  Check,
  AlertCircle,
  Wand2,
  Hand,
  ArrowRight,
} from 'lucide-react';
import {
  LandmarkPoint,
  FRONT_PROFILE_LANDMARKS,
  FRONT_LANDMARK_CATEGORIES,
  getLandmarkColor,
} from '@/lib/landmarks';
import { MEDIAPIPE_FRONT_MAPPING } from '@/lib/mediapipeDetection';
import { GuidedLandmarkPlacement } from './GuidedLandmarkPlacement';

interface FrontProfileLandmarksProps {
  imageUrl: string;
  onLandmarksChange?: (landmarks: LandmarkPoint[]) => void;
  onComplete?: (landmarks: LandmarkPoint[]) => void;
}

type DetectionStatus = 'idle' | 'loading' | 'detecting' | 'success' | 'error';
type Mode = 'choose' | 'auto' | 'guided';

export function FrontProfileLandmarks({
  imageUrl,
  onLandmarksChange,
  onComplete,
}: FrontProfileLandmarksProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const imageRef = useRef<HTMLImageElement>(null);
  const [landmarks, setLandmarks] = useState<LandmarkPoint[]>(FRONT_PROFILE_LANDMARKS);
  const [activeLandmark, setActiveLandmark] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [detectionStatus, setDetectionStatus] = useState<DetectionStatus>('idle');
  const [errorMessage, setErrorMessage] = useState<string>('');
  const [mode, setMode] = useState<Mode>('choose');

  useEffect(() => {
    onLandmarksChange?.(landmarks);
  }, [landmarks, onLandmarksChange]);

  const detectLandmarks = async () => {
    setDetectionStatus('loading');
    setErrorMessage('');

    try {
      // Dynamically import MediaPipe
      const vision = await import('@mediapipe/tasks-vision');
      const { FaceLandmarker, FilesetResolver } = vision;

      setDetectionStatus('detecting');

      // Initialize MediaPipe Face Landmarker
      const filesetResolver = await FilesetResolver.forVisionTasks(
        'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@latest/wasm'
      );

      const faceLandmarker = await FaceLandmarker.createFromOptions(filesetResolver, {
        baseOptions: {
          modelAssetPath:
            'https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task',
          delegate: 'GPU',
        },
        runningMode: 'IMAGE',
        numFaces: 1,
        outputFaceBlendshapes: false,
        outputFacialTransformationMatrixes: false,
      });

      // Create image element for detection
      const img = new window.Image();
      img.crossOrigin = 'anonymous';

      await new Promise<void>((resolve, reject) => {
        img.onload = () => resolve();
        img.onerror = () => reject(new Error('Failed to load image'));
        img.src = imageUrl;
      });

      // Detect landmarks
      const results = faceLandmarker.detect(img);

      if (!results.faceLandmarks || results.faceLandmarks.length === 0) {
        throw new Error('No face detected in the image');
      }

      const faceMesh = results.faceLandmarks[0];

      // Map MediaPipe landmarks to our landmark system
      const mappedLandmarks = landmarks.map((landmark) => {
        const mediapipeIndex = MEDIAPIPE_FRONT_MAPPING[landmark.id];

        if (mediapipeIndex !== undefined && faceMesh[mediapipeIndex]) {
          const point = faceMesh[mediapipeIndex];
          return {
            ...landmark,
            x: point.x,
            y: point.y,
          };
        }

        // Keep default position for unmapped landmarks
        return landmark;
      });

      setLandmarks(mappedLandmarks);
      setDetectionStatus('success');

      // Cleanup
      faceLandmarker.close();
    } catch (error) {
      console.error('Face detection error:', error);
      setDetectionStatus('error');
      setErrorMessage(
        error instanceof Error ? error.message : 'Failed to detect face landmarks'
      );
    }
  };

  const handleStartAutoMode = () => {
    setMode('auto');
    detectLandmarks();
  };

  const handleStartGuidedMode = () => {
    setMode('guided');
  };

  const handleMouseDown = useCallback((id: string) => {
    setActiveLandmark(id);
  }, []);

  const handleMouseMove = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      if (!activeLandmark || !containerRef.current) return;

      const rect = containerRef.current.getBoundingClientRect();
      const x = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
      const y = Math.max(0, Math.min(1, (e.clientY - rect.top) / rect.height));

      setLandmarks((prev) =>
        prev.map((lm) => (lm.id === activeLandmark ? { ...lm, x, y } : lm))
      );
    },
    [activeLandmark]
  );

  const handleMouseUp = useCallback(() => {
    setActiveLandmark(null);
  }, []);

  const handleTouchStart = useCallback((id: string) => {
    setActiveLandmark(id);
  }, []);

  const handleTouchMove = useCallback(
    (e: React.TouchEvent<HTMLDivElement>) => {
      if (!activeLandmark || !containerRef.current) return;

      const touch = e.touches[0];
      const rect = containerRef.current.getBoundingClientRect();
      const x = Math.max(0, Math.min(1, (touch.clientX - rect.left) / rect.width));
      const y = Math.max(0, Math.min(1, (touch.clientY - rect.top) / rect.height));

      setLandmarks((prev) =>
        prev.map((lm) => (lm.id === activeLandmark ? { ...lm, x, y } : lm))
      );
    },
    [activeLandmark]
  );

  const handleTouchEnd = useCallback(() => {
    setActiveLandmark(null);
  }, []);

  const handleComplete = () => {
    onComplete?.(landmarks);
  };

  const handleGuidedComplete = (guidedLandmarks: LandmarkPoint[]) => {
    setLandmarks(guidedLandmarks);
    onComplete?.(guidedLandmarks);
  };

  const filteredLandmarks = selectedCategory
    ? landmarks.filter((lm) => lm.category === selectedCategory)
    : landmarks;

  const visibleLandmarkIds = new Set(filteredLandmarks.map((lm) => lm.id));

  // Mode Selection Screen
  if (mode === 'choose') {
    return (
      <div className="w-full max-w-4xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <h2 className="text-2xl font-semibold text-white mb-2">
            Choose Your Landmark Placement Method
          </h2>
          <p className="text-neutral-400">
            Select how you&apos;d like to place the facial landmarks on your photo
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 gap-6">
          {/* Auto-Detect Option */}
          <motion.button
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.1 }}
            onClick={handleStartAutoMode}
            className="group relative bg-black rounded-2xl border-2 border-neutral-800 p-6 text-left hover:border-neutral-700 transition-all"
          >
            <div className="relative">
              <div className="w-14 h-14 rounded-xl bg-neutral-900 flex items-center justify-center mb-4">
                <Wand2 className="w-7 h-7 text-[#00f3ff]" />
              </div>

              <h3 className="text-xl font-semibold text-white mb-2">
                Auto-Detect
              </h3>
              <p className="text-neutral-400 text-sm mb-4">
                AI-powered face detection automatically places landmarks using MediaPipe.
                You can adjust positions afterwards.
              </p>

              <ul className="space-y-2 text-sm text-neutral-400 mb-4">
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-green-500" />
                  Fast and automatic
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-green-500" />
                  Good for clear, well-lit photos
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-green-500" />
                  Adjustable after detection
                </li>
              </ul>

              <span className="inline-flex items-center gap-2 text-[#00f3ff] font-medium group-hover:gap-3 transition-all">
                Start Auto-Detect
                <ArrowRight className="w-4 h-4" />
              </span>
            </div>
          </motion.button>

          {/* Guided Manual Option */}
          <motion.button
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
            onClick={handleStartGuidedMode}
            className="group relative bg-black rounded-2xl border-2 border-neutral-800 p-6 text-left hover:border-neutral-700 transition-all"
          >
            <div className="relative">
              <div className="w-14 h-14 rounded-xl bg-neutral-900 flex items-center justify-center mb-4">
                <Hand className="w-7 h-7 text-[#00f3ff]" />
              </div>

              <h3 className="text-xl font-semibold text-white mb-2">
                Guided Manual
              </h3>
              <p className="text-neutral-400 text-sm mb-4">
                Step-by-step placement with reference images showing exactly where each
                point should go. Includes zoom for precision.
              </p>

              <ul className="space-y-2 text-sm text-neutral-400 mb-4">
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-green-500" />
                  Reference images for each point
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-green-500" />
                  Zoom feature for precision
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 text-green-500" />
                  More accurate results
                </li>
              </ul>

              <span className="inline-flex items-center gap-2 text-[#00f3ff] font-medium group-hover:gap-3 transition-all">
                Start Guided Mode
                <ArrowRight className="w-4 h-4" />
              </span>
            </div>
          </motion.button>
        </div>

        {/* Preview Image */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mt-8"
        >
          <div className="relative w-full max-w-md mx-auto aspect-[3/4] rounded-2xl overflow-hidden border border-neutral-800 bg-neutral-900">
            <Image
              src={imageUrl}
              alt="Your photo preview"
              fill
              className="object-contain"
              unoptimized
            />
          </div>
        </motion.div>
      </div>
    );
  }

  // Guided Mode
  if (mode === 'guided') {
    return (
      <GuidedLandmarkPlacement
        imageUrl={imageUrl}
        initialLandmarks={landmarks}
        onLandmarksChange={setLandmarks}
        onComplete={handleGuidedComplete}
      />
    );
  }

  // Auto-Detect Mode (existing implementation)
  return (
    <div className="w-full max-w-4xl mx-auto">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6"
      >
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-xl font-semibold text-white mb-1">
              Front Profile Landmarks
            </h2>
            <p className="text-neutral-400 text-sm">
              {detectionStatus === 'success'
                ? 'Landmarks auto-detected. Drag to adjust if needed.'
                : 'Detecting facial landmarks...'}
            </p>
          </div>
          <button
            onClick={() => setMode('choose')}
            className="px-4 py-2 rounded-lg border border-neutral-700 text-neutral-300 hover:bg-white/5 transition-colors text-sm"
          >
            Switch Mode
          </button>
        </div>
      </motion.div>

      {/* Detection Status */}
      <AnimatePresence>
        {(detectionStatus === 'loading' || detectionStatus === 'detecting') && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="mb-4 flex items-center justify-center gap-2 text-neutral-400"
          >
            <Loader2 className="w-5 h-5 animate-spin" />
            <span>
              {detectionStatus === 'loading'
                ? 'Loading face detection model...'
                : 'Analyzing facial features...'}
            </span>
          </motion.div>
        )}

        {detectionStatus === 'error' && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="mb-4 p-4 rounded-lg bg-red-500/10 border border-red-500/30"
          >
            <div className="flex items-center gap-2 text-red-400 mb-2">
              <AlertCircle className="w-5 h-5" />
              <span className="font-medium">Detection Failed</span>
            </div>
            <p className="text-sm text-red-400/80">{errorMessage}</p>
            <div className="mt-3 flex gap-3">
              <button
                onClick={detectLandmarks}
                className="flex items-center gap-2 px-4 py-2 rounded-lg bg-red-500/20 text-red-400 hover:bg-red-500/30 transition-colors"
              >
                <RefreshCw className="w-4 h-4" />
                Retry Detection
              </button>
              <button
                onClick={() => setMode('guided')}
                className="flex items-center gap-2 px-4 py-2 rounded-lg bg-neutral-800 text-neutral-300 hover:bg-neutral-700 transition-colors"
              >
                <Hand className="w-4 h-4" />
                Try Guided Mode
              </button>
            </div>
          </motion.div>
        )}

        {detectionStatus === 'success' && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="mb-4 flex items-center justify-center gap-2 text-green-400"
          >
            <Check className="w-5 h-5" />
            <span>{landmarks.length} landmarks detected</span>
            <button
              onClick={detectLandmarks}
              className="ml-4 flex items-center gap-1 px-3 py-1 rounded-lg border border-neutral-700 text-neutral-400 hover:text-white transition-colors"
            >
              <RefreshCw className="w-4 h-4" />
              Re-detect
            </button>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Category Filter */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-4 flex flex-wrap gap-2 justify-center"
      >
        <button
          onClick={() => setSelectedCategory(null)}
          className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all ${
            selectedCategory === null
              ? 'bg-[#00f3ff] text-black'
              : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
          }`}
        >
          All ({landmarks.length})
        </button>
        {FRONT_LANDMARK_CATEGORIES.map((category) => (
          <button
            key={category.name}
            onClick={() =>
              setSelectedCategory(
                selectedCategory === category.name ? null : category.name
              )
            }
            className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all flex items-center gap-1.5 ${
              selectedCategory === category.name
                ? 'bg-[#00f3ff] text-black'
                : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
            }`}
          >
            <span
              className="w-2 h-2 rounded-full"
              style={{ backgroundColor: category.color }}
            />
            {category.name}
          </button>
        ))}
      </motion.div>

      {/* Image Container with Landmarks */}
      <motion.div
        initial={{ opacity: 0, scale: 0.98 }}
        animate={{ opacity: 1, scale: 1 }}
        className="relative"
      >
        <div
          ref={containerRef}
          className="relative w-full aspect-[3/4] rounded-2xl overflow-hidden bg-neutral-900 border border-neutral-800 select-none"
          onMouseMove={handleMouseMove}
          onMouseUp={handleMouseUp}
          onMouseLeave={handleMouseUp}
          onTouchMove={handleTouchMove}
          onTouchEnd={handleTouchEnd}
        >
          {/* User's uploaded image */}
          <Image
            ref={imageRef}
            src={imageUrl}
            alt="Front profile"
            fill
            className="object-contain pointer-events-none"
            unoptimized
            draggable={false}
          />

          {/* Landmark Points */}
          {landmarks.map((landmark) => {
            const isVisible = visibleLandmarkIds.has(landmark.id);
            const color = getLandmarkColor(landmark.id, FRONT_LANDMARK_CATEGORIES);

            return (
              <div
                key={landmark.id}
                className={`
                  absolute w-4 h-4 -translate-x-1/2 -translate-y-1/2 cursor-grab
                  transition-opacity duration-200
                  ${activeLandmark === landmark.id ? 'cursor-grabbing z-30' : 'z-10'}
                  ${isVisible ? 'opacity-100' : 'opacity-20 pointer-events-none'}
                `}
                style={{
                  left: `${landmark.x * 100}%`,
                  top: `${landmark.y * 100}%`,
                }}
                onMouseDown={() => isVisible && handleMouseDown(landmark.id)}
                onTouchStart={() => isVisible && handleTouchStart(landmark.id)}
              >
                {/* Outer glow */}
                <div
                  className={`
                    absolute inset-0 rounded-full
                    transition-all duration-200
                    ${activeLandmark === landmark.id ? 'scale-200' : ''}
                  `}
                  style={{
                    backgroundColor: `${color}33`,
                    boxShadow:
                      activeLandmark === landmark.id
                        ? `0 0 20px ${color}`
                        : `0 0 8px ${color}`,
                  }}
                />

                {/* Inner dot */}
                <div
                  className={`
                    absolute inset-1 rounded-full border-2 border-white
                    transition-all duration-200
                    ${activeLandmark === landmark.id ? 'scale-125' : ''}
                  `}
                  style={{
                    backgroundColor: color,
                    boxShadow: `0 0 10px ${color}`,
                  }}
                />

                {/* Label tooltip on hover/active */}
                <div
                  className={`
                    absolute left-5 top-1/2 -translate-y-1/2 whitespace-nowrap
                    px-2 py-1 rounded bg-black/95 border
                    text-xs font-medium z-50
                    transition-opacity duration-200
                    ${activeLandmark === landmark.id ? 'opacity-100' : 'opacity-0 pointer-events-none'}
                  `}
                  style={{
                    borderColor: `${color}80`,
                    color: color,
                  }}
                >
                  {landmark.label}
                </div>
              </div>
            );
          })}
        </div>
      </motion.div>

      {/* Landmark List */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="mt-6 max-h-48 overflow-y-auto rounded-xl border border-neutral-800 bg-black p-3"
      >
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
          {filteredLandmarks.map((landmark) => {
            const color = getLandmarkColor(landmark.id, FRONT_LANDMARK_CATEGORIES);
            return (
              <div
                key={landmark.id}
                className={`
                  flex items-center gap-2 px-2 py-1.5 rounded-lg text-xs
                  cursor-pointer transition-all duration-200
                  ${
                    activeLandmark === landmark.id
                      ? 'bg-neutral-800'
                      : 'bg-neutral-900 hover:bg-neutral-800'
                  }
                `}
                onMouseEnter={() => setActiveLandmark(landmark.id)}
                onMouseLeave={() => setActiveLandmark(null)}
              >
                <div
                  className="w-2.5 h-2.5 rounded-full flex-shrink-0"
                  style={{ backgroundColor: color }}
                />
                <span className="text-neutral-400 truncate">{landmark.label}</span>
              </div>
            );
          })}
        </div>
      </motion.div>

      {/* Complete Button */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="mt-8 flex justify-center"
      >
        <button
          onClick={handleComplete}
          disabled={detectionStatus !== 'success' && detectionStatus !== 'error'}
          className={`
            px-8 py-4 rounded-xl font-semibold text-lg
            transition-all duration-300
            ${
              detectionStatus === 'success' || detectionStatus === 'error'
                ? 'bg-[#00f3ff] text-black hover:shadow-[0_0_20px_rgba(0,243,255,0.3)]'
                : 'bg-neutral-800 text-neutral-500 cursor-not-allowed'
            }
          `}
        >
          Confirm Front Landmarks
        </button>
      </motion.div>
    </div>
  );
}
