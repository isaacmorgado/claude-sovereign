'use client';

import { useState, useRef, useCallback, useEffect } from 'react';
import Image from 'next/image';
import { motion, AnimatePresence } from 'framer-motion';
import { RotateCcw, ChevronLeft, ChevronRight, Wand2, Loader2, ZoomIn, ZoomOut } from 'lucide-react';
import {
  LandmarkPoint,
  SIDE_PROFILE_LANDMARKS,
  SIDE_LANDMARK_CATEGORIES,
  getLandmarkColor,
} from '@/lib/landmarks';
import { useFaceApi, FACE_API_LANDMARK_MAPPING } from '@/hooks/useFaceApi';

// Re-export types for backwards compatibility
export type { LandmarkPoint } from '@/lib/landmarks';

interface SideProfileManualToolProps {
  imageUrl: string;
  onLandmarksChange?: (landmarks: LandmarkPoint[]) => void;
  onComplete?: (landmarks: LandmarkPoint[]) => void;
}

export function SideProfileManualTool({
  imageUrl,
  onLandmarksChange,
  onComplete,
}: SideProfileManualToolProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const imageRef = useRef<HTMLImageElement>(null);
  const [landmarks, setLandmarks] = useState<LandmarkPoint[]>(SIDE_PROFILE_LANDMARKS);
  const [activeLandmark, setActiveLandmark] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [currentStepIndex, setCurrentStepIndex] = useState(0);
  const [isGuided, setIsGuided] = useState(true);
  const [zoom, setZoom] = useState(1);
  const [isDetecting, setIsDetecting] = useState(false);
  const [detectionError, setDetectionError] = useState<string | null>(null);

  // Face API hook for auto-detection
  const { isLoading: faceApiLoading, isReady: faceApiReady, error: faceApiError, detect } = useFaceApi();

  useEffect(() => {
    onLandmarksChange?.(landmarks);
  }, [landmarks, onLandmarksChange]);

  // Auto-detect landmarks using face-api.js
  const handleAutoDetect = useCallback(async () => {
    if (!faceApiReady || !imageRef.current) {
      setDetectionError('Face detection not ready. Please wait...');
      return;
    }

    setIsDetecting(true);
    setDetectionError(null);

    try {
      const result = await detect(imageRef.current);

      if (!result) {
        setDetectionError('No face detected. Please ensure your side profile is clearly visible.');
        setIsDetecting(false);
        return;
      }

      // Get image dimensions
      const imgWidth = imageRef.current.naturalWidth;
      const imgHeight = imageRef.current.naturalHeight;

      // Map face-api.js 68-point landmarks to our side profile landmarks
      const detectedLandmarks = result.landmarks;

      setLandmarks((prev) =>
        prev.map((lm) => {
          // Map our landmark IDs to face-api indices
          let detectedPoint = null;

          // FaceIQ landmark IDs: vertex, occiput, pronasale, neckPoint, porion, orbitale,
          // tragus, intertragicNotch, cornealApex, cheekbone, trichion, glabella, nasion,
          // rhinion, supratip, infratip, columella, subnasale, subalare, labraleSuperius,
          // cheilion, labraleInferius, sublabiale, pogonion, menton, cervicalPoint, gonionTop, gonionBottom
          switch (lm.id) {
            // Chin/Jaw landmarks
            case 'menton':
              detectedPoint = detectedLandmarks[FACE_API_LANDMARK_MAPPING.MENTON];
              break;
            case 'pogonion':
              detectedPoint = detectedLandmarks[FACE_API_LANDMARK_MAPPING.MENTON];
              break;
            case 'gonionBottom':
              detectedPoint = detectedLandmarks[4]; // Jaw contour point
              break;
            case 'gonionTop':
              detectedPoint = detectedLandmarks[3]; // Higher jaw point
              break;

            // Nose landmarks
            case 'nasion':
              detectedPoint = detectedLandmarks[FACE_API_LANDMARK_MAPPING.NASION];
              break;
            case 'pronasale':
              detectedPoint = detectedLandmarks[FACE_API_LANDMARK_MAPPING.PRONASALE];
              break;
            case 'rhinion':
              detectedPoint = detectedLandmarks[28]; // Mid nose bridge
              break;
            case 'subnasale':
              detectedPoint = detectedLandmarks[33]; // Nose bottom center
              break;
            case 'columella':
              detectedPoint = detectedLandmarks[33];
              break;

            // Lip landmarks
            case 'labraleSuperius':
              detectedPoint = detectedLandmarks[FACE_API_LANDMARK_MAPPING.UPPER_LIP_TOP];
              break;
            case 'labraleInferius':
              detectedPoint = detectedLandmarks[FACE_API_LANDMARK_MAPPING.LOWER_LIP_BOTTOM];
              break;
            case 'cheilion':
              detectedPoint = detectedLandmarks[FACE_API_LANDMARK_MAPPING.LEFT_MOUTH_CORNER];
              break;
            case 'sublabiale':
              // Approximate from lower lip and chin
              const lowerLip = detectedLandmarks[57];
              const chin = detectedLandmarks[8];
              if (lowerLip && chin) {
                detectedPoint = {
                  x: (lowerLip.x + chin.x) / 2,
                  y: lowerLip.y + (chin.y - lowerLip.y) * 0.3,
                };
              }
              break;

            // Eye region
            case 'cornealApex':
              detectedPoint = detectedLandmarks[FACE_API_LANDMARK_MAPPING.LEFT_EYE_OUTER];
              break;
            case 'orbitale':
              detectedPoint = detectedLandmarks[41]; // Lower eye socket
              break;

            // Forehead
            case 'glabella':
              // Approximate from brow points
              const leftBrow = detectedLandmarks[21];
              const rightBrow = detectedLandmarks[22];
              if (leftBrow && rightBrow) {
                detectedPoint = {
                  x: (leftBrow.x + rightBrow.x) / 2,
                  y: (leftBrow.y + rightBrow.y) / 2,
                };
              }
              break;

            // Ear landmarks (use jaw contour as proxy)
            case 'tragus':
              detectedPoint = detectedLandmarks[1]; // Upper jaw near ear
              break;
            case 'porion':
              detectedPoint = detectedLandmarks[0]; // Near ear
              break;

            default:
              break;
          }

          if (detectedPoint) {
            return {
              ...lm,
              x: detectedPoint.x / imgWidth,
              y: detectedPoint.y / imgHeight,
            };
          }

          return lm;
        })
      );

      setIsDetecting(false);
    } catch (err) {
      setDetectionError(err instanceof Error ? err.message : 'Detection failed');
      setIsDetecting(false);
    }
  }, [faceApiReady, detect]);

  // Zoom controls
  const handleZoomIn = () => setZoom((prev) => Math.min(prev + 0.25, 3));
  const handleZoomOut = () => setZoom((prev) => Math.max(prev - 0.25, 0.5));

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

  const resetLandmarks = () => {
    setLandmarks(SIDE_PROFILE_LANDMARKS);
  };

  // Guided mode - step through categories
  const currentCategory = isGuided ? SIDE_LANDMARK_CATEGORIES[currentStepIndex] : null;

  const filteredLandmarks = selectedCategory
    ? landmarks.filter((lm) => lm.category === selectedCategory)
    : isGuided && currentCategory
      ? landmarks.filter((lm) => lm.category === currentCategory.name)
      : landmarks;

  const visibleLandmarkIds = isGuided && currentCategory
    ? new Set(currentCategory.landmarks)
    : selectedCategory
      ? new Set(filteredLandmarks.map((lm) => lm.id))
      : new Set(landmarks.map((lm) => lm.id));

  const nextStep = () => {
    if (currentStepIndex < SIDE_LANDMARK_CATEGORIES.length - 1) {
      setCurrentStepIndex(currentStepIndex + 1);
    }
  };

  const prevStep = () => {
    if (currentStepIndex > 0) {
      setCurrentStepIndex(currentStepIndex - 1);
    }
  };

  return (
    <div className="w-full max-w-4xl mx-auto">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6 text-center"
      >
        <h2 className="text-xl font-semibold text-white mb-2">
          Side Profile Manual Adjustment
        </h2>
        <p className="text-neutral-400">
          Drag each marker to match the facial landmarks on your profile photo
        </p>
      </motion.div>

      {/* Mode Toggle and Controls */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-4 flex flex-wrap justify-center gap-2"
      >
        {/* Auto-Detect Button */}
        <button
          onClick={handleAutoDetect}
          disabled={!faceApiReady || isDetecting}
          className={`px-4 py-2 rounded-lg text-sm font-medium transition-all flex items-center gap-2 ${
            faceApiReady && !isDetecting
              ? 'bg-green-500/20 text-green-400 hover:bg-green-500/30 border border-green-500/30'
              : 'bg-neutral-800 text-neutral-500 cursor-not-allowed'
          }`}
        >
          {isDetecting ? (
            <Loader2 className="w-4 h-4 animate-spin" />
          ) : faceApiLoading ? (
            <Loader2 className="w-4 h-4 animate-spin" />
          ) : (
            <Wand2 className="w-4 h-4" />
          )}
          {isDetecting ? 'Detecting...' : faceApiLoading ? 'Loading AI...' : 'Auto-Detect'}
        </button>

        <div className="w-px h-8 bg-neutral-800" />

        <button
          onClick={() => {
            setIsGuided(true);
            setSelectedCategory(null);
          }}
          className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
            isGuided
              ? 'bg-[#00f3ff] text-black'
              : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
          }`}
        >
          Guided Mode
        </button>
        <button
          onClick={() => {
            setIsGuided(false);
            setSelectedCategory(null);
          }}
          className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
            !isGuided
              ? 'bg-[#00f3ff] text-black'
              : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
          }`}
        >
          Free Edit
        </button>

        <div className="w-px h-8 bg-neutral-800" />

        {/* Zoom Controls */}
        <div className="flex items-center gap-1">
          <button
            onClick={handleZoomOut}
            disabled={zoom <= 0.5}
            className="p-2 rounded-lg bg-neutral-800 text-neutral-400 hover:bg-neutral-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ZoomOut className="w-4 h-4" />
          </button>
          <span className="text-xs text-neutral-400 w-12 text-center">
            {(zoom * 100).toFixed(0)}%
          </span>
          <button
            onClick={handleZoomIn}
            disabled={zoom >= 3}
            className="p-2 rounded-lg bg-neutral-800 text-neutral-400 hover:bg-neutral-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ZoomIn className="w-4 h-4" />
          </button>
        </div>

        <div className="w-px h-8 bg-neutral-800" />

        <button
          onClick={resetLandmarks}
          className="px-4 py-2 rounded-lg text-sm font-medium bg-neutral-800 text-neutral-400 hover:bg-neutral-700 transition-all flex items-center gap-2"
        >
          <RotateCcw className="w-4 h-4" />
          Reset
        </button>
      </motion.div>

      {/* Detection Error/Status */}
      <AnimatePresence>
        {(detectionError || faceApiError) && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="mb-4 p-3 rounded-lg bg-red-500/10 border border-red-500/30 text-red-400 text-sm text-center"
          >
            {detectionError || faceApiError?.message}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Guided Mode Step Indicator */}
      {isGuided && currentCategory && (
        <motion.div
          key={currentStepIndex}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          className="mb-4"
        >
          <div className="flex items-center justify-between mb-2">
            <button
              onClick={prevStep}
              disabled={currentStepIndex === 0}
              className={`p-2 rounded-lg transition-all ${
                currentStepIndex === 0
                  ? 'text-neutral-700 cursor-not-allowed'
                  : 'text-neutral-400 hover:text-white hover:bg-neutral-800'
              }`}
            >
              <ChevronLeft className="w-5 h-5" />
            </button>

            <div className="text-center">
              <div className="flex items-center justify-center gap-2 mb-1">
                <span
                  className="w-3 h-3 rounded-full"
                  style={{ backgroundColor: currentCategory.color }}
                />
                <span className="text-white font-medium">{currentCategory.name}</span>
              </div>
              <span className="text-xs text-neutral-400">
                Step {currentStepIndex + 1} of {SIDE_LANDMARK_CATEGORIES.length} •{' '}
                {currentCategory.landmarks.length} points
              </span>
            </div>

            <button
              onClick={nextStep}
              disabled={currentStepIndex === SIDE_LANDMARK_CATEGORIES.length - 1}
              className={`p-2 rounded-lg transition-all ${
                currentStepIndex === SIDE_LANDMARK_CATEGORIES.length - 1
                  ? 'text-neutral-700 cursor-not-allowed'
                  : 'text-neutral-400 hover:text-white hover:bg-neutral-800'
              }`}
            >
              <ChevronRight className="w-5 h-5" />
            </button>
          </div>

          {/* Progress bar */}
          <div className="w-full h-1 bg-neutral-800 rounded-full overflow-hidden">
            <motion.div
              className="h-full rounded-full"
              style={{ backgroundColor: currentCategory.color }}
              initial={{ width: 0 }}
              animate={{
                width: `${((currentStepIndex + 1) / SIDE_LANDMARK_CATEGORIES.length) * 100}%`,
              }}
              transition={{ duration: 0.3 }}
            />
          </div>
        </motion.div>
      )}

      {/* Category Filter (Free Edit Mode) */}
      {!isGuided && (
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
          {SIDE_LANDMARK_CATEGORIES.map((category) => (
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
      )}

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
          {/* User's uploaded image with zoom */}
          <div
            style={{
              transform: `scale(${zoom})`,
              transformOrigin: 'center center',
            }}
            className="absolute inset-0 transition-transform duration-200"
          >
            <Image
              ref={imageRef as React.RefObject<HTMLImageElement>}
              src={imageUrl}
              alt="Side profile"
              fill
              className="object-contain pointer-events-none"
              unoptimized
              draggable={false}
              onLoadingComplete={(img) => {
                // Store reference for face detection
                if (imageRef.current !== img) {
                  (imageRef as React.MutableRefObject<HTMLImageElement>).current = img;
                }
              }}
            />
          </div>

          {/* Connection lines between sequential landmarks in category */}
          {isGuided && currentCategory && (
            <svg
              className="absolute inset-0 w-full h-full pointer-events-none"
              viewBox="0 0 100 100"
              preserveAspectRatio="none"
            >
              {currentCategory.landmarks.map((landmarkId, index) => {
                if (index === currentCategory.landmarks.length - 1) return null;
                const current = landmarks.find((lm) => lm.id === landmarkId);
                const next = landmarks.find(
                  (lm) => lm.id === currentCategory.landmarks[index + 1]
                );
                if (!current || !next) return null;

                return (
                  <line
                    key={`line-${landmarkId}`}
                    x1={current.x * 100}
                    y1={current.y * 100}
                    x2={next.x * 100}
                    y2={next.y * 100}
                    stroke={`${currentCategory.color}66`}
                    strokeWidth="0.3"
                    strokeDasharray="1,1"
                  />
                );
              })}
            </svg>
          )}

          {/* Landmark Points */}
          {landmarks.map((landmark) => {
            const isVisible = visibleLandmarkIds.has(landmark.id);
            const color = getLandmarkColor(landmark.id, SIDE_LANDMARK_CATEGORIES);

            return (
              <div
                key={landmark.id}
                className={`
                  absolute w-5 h-5 -translate-x-1/2 -translate-y-1/2 cursor-grab
                  transition-all duration-200
                  ${activeLandmark === landmark.id ? 'cursor-grabbing z-30' : 'z-10'}
                  ${isVisible ? 'opacity-100 scale-100' : 'opacity-10 scale-75 pointer-events-none'}
                `}
                style={{
                  left: `${landmark.x * 100}%`,
                  top: `${landmark.y * 100}%`,
                }}
                onMouseDown={() => isVisible && handleMouseDown(landmark.id)}
                onTouchStart={() => isVisible && handleTouchStart(landmark.id)}
              >
                {/* Outer glow ring */}
                <div
                  className={`
                    absolute inset-0 rounded-full
                    transition-all duration-200
                    ${activeLandmark === landmark.id ? 'scale-150' : ''}
                  `}
                  style={{
                    backgroundColor: `${color}33`,
                    boxShadow:
                      activeLandmark === landmark.id
                        ? `0 0 25px ${color}`
                        : `0 0 10px ${color}`,
                  }}
                />

                {/* Main handle */}
                <div
                  className={`
                    absolute inset-1 rounded-full border-2 border-white
                    transition-all duration-200
                    ${activeLandmark === landmark.id ? 'scale-125' : ''}
                  `}
                  style={{
                    backgroundColor: color,
                    boxShadow: `0 0 10px ${color}, 0 0 20px ${color}`,
                  }}
                />

                {/* Label tooltip */}
                <div
                  className={`
                    absolute left-6 top-1/2 -translate-y-1/2 whitespace-nowrap
                    px-2 py-1 rounded bg-black/95 border
                    text-xs font-medium z-50
                    pointer-events-none transition-opacity duration-200
                    ${activeLandmark === landmark.id ? 'opacity-100' : 'opacity-0'}
                  `}
                  style={{
                    borderColor: `${color}80`,
                    color: color,
                  }}
                >
                  <div>{landmark.label}</div>
                  <div className="text-[10px] opacity-70">{landmark.medicalTerm}</div>
                </div>
              </div>
            );
          })}
        </div>
      </motion.div>

      {/* Landmark Legend for Current Category */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="mt-6 grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2"
      >
        {filteredLandmarks.map((landmark) => {
          const color = getLandmarkColor(landmark.id, SIDE_LANDMARK_CATEGORIES);
          return (
            <div
              key={landmark.id}
              className={`
                flex items-center gap-2 px-3 py-2 rounded-lg
                border transition-all duration-200 cursor-pointer
                ${
                  activeLandmark === landmark.id
                    ? 'border-neutral-600 bg-neutral-800'
                    : 'border-neutral-800 bg-black hover:bg-neutral-900'
                }
              `}
              onMouseEnter={() => setActiveLandmark(landmark.id)}
              onMouseLeave={() => setActiveLandmark(null)}
            >
              <div
                className="w-3 h-3 rounded-full flex-shrink-0"
                style={{
                  backgroundColor: color,
                }}
              />
              <div className="min-w-0">
                <p className="text-sm font-medium text-white truncate">
                  {landmark.label}
                </p>
                <p className="text-xs text-neutral-500 truncate">
                  {landmark.description}
                </p>
              </div>
            </div>
          );
        })}
      </motion.div>

      {/* Navigation/Complete Buttons */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="mt-8 flex justify-center gap-4"
      >
        {isGuided && currentStepIndex < SIDE_LANDMARK_CATEGORIES.length - 1 ? (
          <button
            onClick={nextStep}
            className="
              px-8 py-4 rounded-xl font-semibold text-lg
              bg-[#00f3ff] text-black
              hover:shadow-[0_0_20px_rgba(0,243,255,0.3)]
              transition-all duration-300
            "
          >
            Next: {SIDE_LANDMARK_CATEGORIES[currentStepIndex + 1]?.name}
          </button>
        ) : (
          <button
            onClick={handleComplete}
            className="
              px-8 py-4 rounded-xl font-semibold text-lg
              bg-[#00f3ff] text-black
              hover:shadow-[0_0_20px_rgba(0,243,255,0.3)]
              transition-all duration-300
            "
          >
            Confirm Side Landmarks
          </button>
        )}
      </motion.div>

      {/* Total Progress */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.4 }}
        className="mt-4 text-center text-sm text-neutral-500"
      >
        {landmarks.length} landmarks • Drag markers to adjust positions
      </motion.div>
    </div>
  );
}
