'use client';

import { useState, useRef, useCallback, useEffect } from 'react';
import Image from 'next/image';
import { motion } from 'framer-motion';
import {
  ChevronLeft,
  ChevronRight,
  ChevronUp,
  ChevronDown,
  ZoomIn,
  ZoomOut,
  RotateCcw,
  Check,
  Circle,
  Info,
  Maximize2,
  Minimize2,
} from 'lucide-react';
import {
  LandmarkPoint,
  FRONT_PROFILE_LANDMARKS,
  getLandmarkColor,
  FRONT_LANDMARK_CATEGORIES,
} from '@/lib/landmarks';
import {
  getLandmarkImagePath,
  getLandmarkPlacementGuide,
} from '@/lib/landmarkImages';

interface GuidedLandmarkPlacementProps {
  imageUrl: string;
  initialLandmarks?: LandmarkPoint[];
  onLandmarksChange?: (landmarks: LandmarkPoint[]) => void;
  onComplete?: (landmarks: LandmarkPoint[]) => void;
}

// Keyboard key component with 3D effect
function KeyboardKey({ isPressed, icon }: { isPressed: boolean; icon: React.ReactNode }) {
  return (
    <div className="relative w-9 h-9">
      <div
        className={`absolute inset-0 rounded-md transition-colors duration-75 ${
          isPressed ? 'bg-accent/50' : 'bg-white/20'
        }`}
        style={{ transform: 'translateY(3px)' }}
      />
      <div
        className={`relative w-full h-full rounded-md border flex items-center justify-center transition-colors duration-75 ${
          isPressed
            ? 'bg-accent border-accent text-black'
            : 'bg-background-secondary border-border text-foreground-dim'
        }`}
        style={{
          boxShadow: isPressed
            ? 'none'
            : 'rgba(0, 0, 0, 0.2) 0px -1px 0px inset, rgba(0, 0, 0, 0.1) 0px 1px 2px',
          transform: isPressed ? 'translateY(2px)' : 'none',
        }}
      >
        {icon}
      </div>
    </div>
  );
}

export function GuidedLandmarkPlacement({
  imageUrl,
  initialLandmarks,
  onLandmarksChange,
  onComplete,
}: GuidedLandmarkPlacementProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [landmarks, setLandmarks] = useState<LandmarkPoint[]>(
    initialLandmarks || FRONT_PROFILE_LANDMARKS
  );
  const [currentStepIndex, setCurrentStepIndex] = useState(0);
  const [zoomLevel, setZoomLevel] = useState<1 | 2 | 3>(1); // 1=2x, 2=4x, 3=8x
  const zoom = zoomLevel === 1 ? 2 : zoomLevel === 2 ? 4 : 8;
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [showAllPoints, setShowAllPoints] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [referenceImageError, setReferenceImageError] = useState(false);
  const [activeTab, setActiveTab] = useState<'photo' | 'diagram' | 'howToFind'>('photo');
  const [pressedKey, setPressedKey] = useState<string | null>(null);

  // Use landmark order from FRONT_PROFILE_LANDMARKS
  const landmarkOrder = FRONT_PROFILE_LANDMARKS.map(lm => lm.id);
  const currentLandmarkId = landmarkOrder[currentStepIndex];
  const currentLandmark = landmarks.find((lm) => lm.id === currentLandmarkId);
  const totalSteps = landmarkOrder.length;
  const progress = ((currentStepIndex + 1) / totalSteps) * 100;

  useEffect(() => {
    onLandmarksChange?.(landmarks);
  }, [landmarks, onLandmarksChange]);

  useEffect(() => {
    // Reset reference image error when step changes
    setReferenceImageError(false);
  }, [currentStepIndex]);

  const updateLandmarkPosition = useCallback(
    (x: number, y: number) => {
      setLandmarks((prev) =>
        prev.map((lm) =>
          lm.id === currentLandmarkId ? { ...lm, x, y } : lm
        )
      );
    },
    [currentLandmarkId]
  );

  const handleContainerClick = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      if (!containerRef.current || isDragging) return;

      const rect = containerRef.current.getBoundingClientRect();
      const rawX = (e.clientX - rect.left - rect.width / 2 - pan.x) / zoom + rect.width / 2;
      const rawY = (e.clientY - rect.top - rect.height / 2 - pan.y) / zoom + rect.height / 2;

      const x = Math.max(0, Math.min(1, rawX / rect.width));
      const y = Math.max(0, Math.min(1, rawY / rect.height));

      updateLandmarkPosition(x, y);
    },
    [isDragging, pan, zoom, updateLandmarkPosition]
  );

  const handleMouseDown = useCallback(
    (e: React.MouseEvent) => {
      if (e.button === 0 && zoom > 1) {
        // Only allow panning when zoomed in
        setIsDragging(true);
      }
    },
    [zoom]
  );

  const handleMouseMove = useCallback(
    (e: React.MouseEvent) => {
      if (isDragging && zoom > 1) {
        setPan((prev) => ({
          x: prev.x + e.movementX,
          y: prev.y + e.movementY,
        }));
      }
    },
    [isDragging, zoom]
  );

  const handleMouseUp = useCallback(() => {
    setIsDragging(false);
  }, []);

  const handleZoomIn = () => {
    setZoomLevel((prev) => Math.min(prev + 1, 3) as 1 | 2 | 3);
  };

  const handleZoomOut = () => {
    setZoomLevel((prev) => {
      const newLevel = Math.max(prev - 1, 1) as 1 | 2 | 3;
      if (newLevel === 1) {
        setPan({ x: 0, y: 0 });
      }
      return newLevel;
    });
  };

  const handleResetZoom = () => {
    setZoomLevel(1);
    setPan({ x: 0, y: 0 });
  };

  const handleSetZoomLevel = useCallback((level: 1 | 2 | 3) => {
    setZoomLevel(level);
    if (level === 1) {
      setPan({ x: 0, y: 0 });
    }
  }, []);

  // Arrow key movement for fine landmark adjustment
  const moveLandmark = useCallback((direction: 'up' | 'down' | 'left' | 'right') => {
    const step = 0.002; // Small step for fine adjustment
    setLandmarks((prev) =>
      prev.map((lm) => {
        if (lm.id !== currentLandmarkId) return lm;
        let newX = lm.x;
        let newY = lm.y;
        switch (direction) {
          case 'up': newY = Math.max(0, lm.y - step); break;
          case 'down': newY = Math.min(1, lm.y + step); break;
          case 'left': newX = Math.max(0, lm.x - step); break;
          case 'right': newX = Math.min(1, lm.x + step); break;
        }
        return { ...lm, x: newX, y: newY };
      })
    );
  }, [currentLandmarkId]);

  const handleNext = useCallback(() => {
    if (currentStepIndex < totalSteps - 1) {
      setCurrentStepIndex((prev) => prev + 1);
      handleResetZoom();
    } else {
      onComplete?.(landmarks);
    }
  }, [currentStepIndex, totalSteps, landmarks, onComplete]);

  const handlePrevious = useCallback(() => {
    if (currentStepIndex > 0) {
      setCurrentStepIndex((prev) => prev - 1);
      handleResetZoom();
    }
  }, [currentStepIndex]);

  const handleSkipToEnd = useCallback(() => {
    onComplete?.(landmarks);
  }, [landmarks, onComplete]);

  // Keyboard event handler
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Prevent default for our shortcuts
      if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'Enter', 'Backspace', 'r', 'R', '1', '2', '3'].includes(e.key)) {
        e.preventDefault();
      }

      setPressedKey(e.key);

      switch (e.key) {
        case 'ArrowUp':
          moveLandmark('up');
          break;
        case 'ArrowDown':
          moveLandmark('down');
          break;
        case 'ArrowLeft':
          moveLandmark('left');
          break;
        case 'ArrowRight':
          moveLandmark('right');
          break;
        case 'Enter':
          handleNext();
          break;
        case 'Backspace':
          handlePrevious();
          break;
        case 'r':
        case 'R':
          handleResetZoom();
          break;
        case '1':
          handleSetZoomLevel(1);
          break;
        case '2':
          handleSetZoomLevel(2);
          break;
        case '3':
          handleSetZoomLevel(3);
          break;
      }
    };

    const handleKeyUp = () => {
      setPressedKey(null);
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
    };
  }, [moveLandmark, handleNext, handlePrevious, handleSetZoomLevel]);

  const referenceImageUrl = currentLandmarkId
    ? getLandmarkImagePath(currentLandmarkId, 'front', 'infographic')
    : null;

  const placementGuide = currentLandmarkId
    ? getLandmarkPlacementGuide(currentLandmarkId, 'front')
    : '';

  const color = currentLandmark
    ? getLandmarkColor(currentLandmark.id, FRONT_LANDMARK_CATEGORIES)
    : '#00f3ff';

  return (
    <div className="w-full max-w-6xl mx-auto">
      {/* Progress Bar */}
      <div className="mb-4">
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm text-foreground-dim">
            Step {currentStepIndex + 1} of {totalSteps}
          </span>
          <span className="text-sm text-foreground-dim">
            {Math.round(progress)}% Complete
          </span>
        </div>
        <div className="h-2 bg-background-tertiary rounded-full overflow-hidden">
          <motion.div
            className="h-full bg-accent"
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.3 }}
          />
        </div>
      </div>

      {/* Main Content Grid */}
      <div className="grid lg:grid-cols-3 gap-6">
        {/* Left Panel - Reference Image and Instructions */}
        <div className="lg:col-span-1 space-y-4">
          {/* Current Landmark Info Card */}
          <motion.div
            key={currentLandmarkId}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-background-secondary rounded-xl border border-border p-4"
          >
            <div className="flex items-center gap-3 mb-3">
              <div
                className="w-4 h-4 rounded-full border-2 border-white"
                style={{ backgroundColor: color }}
              />
              <div>
                <h3 className="text-lg font-semibold text-white">
                  {currentLandmark?.label}
                </h3>
                <p className="text-xs text-accent">{currentLandmark?.medicalTerm}</p>
              </div>
            </div>

            <div className="flex items-start gap-2 text-sm text-foreground-dim">
              <Info className="w-4 h-4 mt-0.5 flex-shrink-0" />
              <p>{currentLandmark?.description}</p>
            </div>
          </motion.div>

          {/* Reference with Tabs */}
          <motion.div
            key={`ref-${currentLandmarkId}`}
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-background-secondary rounded-xl border border-border overflow-hidden"
          >
            {/* Tab Navigation */}
            <div className="flex border-b border-border">
              <button
                onClick={() => setActiveTab('photo')}
                className={`flex-1 px-3 py-2.5 text-xs font-medium transition-colors ${
                  activeTab === 'photo'
                    ? 'text-white border-b-2 border-accent'
                    : 'text-foreground-dim hover:text-white'
                }`}
              >
                Photo
              </button>
              <button
                onClick={() => setActiveTab('diagram')}
                className={`flex-1 px-3 py-2.5 text-xs font-medium transition-colors ${
                  activeTab === 'diagram'
                    ? 'text-white border-b-2 border-accent'
                    : 'text-foreground-dim hover:text-white'
                }`}
              >
                Diagram
              </button>
              <button
                onClick={() => setActiveTab('howToFind')}
                className={`flex-1 px-3 py-2.5 text-xs font-medium transition-colors ${
                  activeTab === 'howToFind'
                    ? 'text-white border-b-2 border-accent'
                    : 'text-foreground-dim hover:text-white'
                }`}
              >
                How to Find
              </button>
            </div>

            {/* Tab Content */}
            <div className="relative aspect-square bg-black/50">
              {activeTab === 'photo' && (
                <>
                  {referenceImageUrl && !referenceImageError ? (
                    <Image
                      src={referenceImageUrl}
                      alt={`Reference for ${currentLandmark?.label}`}
                      fill
                      className="object-contain p-4"
                      unoptimized
                      onError={() => setReferenceImageError(true)}
                    />
                  ) : (
                    <div className="absolute inset-0 flex items-center justify-center p-4 text-center">
                      <div>
                        <div
                          className="w-16 h-16 rounded-full mx-auto mb-3 border-4 border-dashed flex items-center justify-center"
                          style={{ borderColor: color }}
                        >
                          <Circle className="w-6 h-6" style={{ color: color }} />
                        </div>
                        <p className="text-foreground-dim text-sm">Reference photo</p>
                      </div>
                    </div>
                  )}
                </>
              )}

              {activeTab === 'diagram' && (
                <div className="absolute inset-0 flex items-center justify-center p-4 text-center">
                  <div>
                    <div
                      className="w-16 h-16 rounded-full mx-auto mb-3 border-4 border-dashed flex items-center justify-center"
                      style={{ borderColor: color }}
                    >
                      <Circle className="w-6 h-6" style={{ color: color }} />
                    </div>
                    <p className="text-foreground-dim text-sm">Anatomical diagram</p>
                  </div>
                </div>
              )}

              {activeTab === 'howToFind' && (
                <div className="absolute inset-0 flex items-center justify-center p-6">
                  <div className="text-center">
                    <Info className="w-8 h-8 mx-auto mb-3" style={{ color: color }} />
                    <p className="text-white text-sm">{placementGuide}</p>
                  </div>
                </div>
              )}
            </div>
          </motion.div>

          {/* Placement Guide Text */}
          <div className="bg-accent/10 rounded-xl border border-accent/30 p-4">
            <p className="text-sm text-accent">{placementGuide}</p>
          </div>

          {/* Quick Actions */}
          <div className="flex gap-2">
            <button
              onClick={() => setShowAllPoints(!showAllPoints)}
              className={`flex-1 py-2 px-3 rounded-lg text-sm font-medium transition-colors ${
                showAllPoints
                  ? 'bg-accent text-black'
                  : 'bg-white/10 text-foreground-dim hover:bg-white/20'
              }`}
            >
              {showAllPoints ? 'Hide Other Points' : 'Show All Points'}
            </button>
            <button
              onClick={handleSkipToEnd}
              className="py-2 px-4 rounded-lg text-sm font-medium bg-white/10 text-foreground-dim hover:bg-white/20 transition-colors"
            >
              Skip to End
            </button>
          </div>

          {/* Keyboard Shortcuts Panel */}
          <div className="hidden lg:block bg-background-secondary rounded-xl border border-border p-4">
            <p className="text-xs text-foreground-dim font-medium uppercase tracking-wide mb-3">
              Keyboard Shortcuts
            </p>

            {/* Arrow Keys Visual */}
            <div className="flex justify-center mb-4">
              <div className="flex flex-col gap-1 items-center">
                <KeyboardKey
                  isPressed={pressedKey === 'ArrowUp'}
                  icon={<ChevronUp className="w-4 h-4" />}
                />
                <div className="flex gap-1">
                  <KeyboardKey
                    isPressed={pressedKey === 'ArrowLeft'}
                    icon={<ChevronLeft className="w-4 h-4" />}
                  />
                  <KeyboardKey
                    isPressed={pressedKey === 'ArrowDown'}
                    icon={<ChevronDown className="w-4 h-4" />}
                  />
                  <KeyboardKey
                    isPressed={pressedKey === 'ArrowRight'}
                    icon={<ChevronRight className="w-4 h-4" />}
                  />
                </div>
              </div>
            </div>

            {/* Shortcut List */}
            <div className="space-y-2">
              <div className="flex items-center gap-3">
                <span className={`px-2 py-1 text-xs font-mono rounded border transition-colors ${
                  pressedKey === 'Enter'
                    ? 'bg-accent border-accent text-black'
                    : 'bg-white/10 border-border text-foreground-dim'
                }`}>
                  Enter
                </span>
                <span className="text-xs text-foreground-dim">Next / Confirm</span>
              </div>
              <div className="flex items-center gap-3">
                <span className={`px-2 py-1 text-xs font-mono rounded border transition-colors ${
                  pressedKey === 'Backspace'
                    ? 'bg-accent border-accent text-black'
                    : 'bg-white/10 border-border text-foreground-dim'
                }`}>
                  Backspace
                </span>
                <span className="text-xs text-foreground-dim">Previous</span>
              </div>
              <div className="flex items-center gap-3">
                <span className={`px-2 py-1 text-xs font-mono rounded border transition-colors ${
                  pressedKey === 'r' || pressedKey === 'R'
                    ? 'bg-accent border-accent text-black'
                    : 'bg-white/10 border-border text-foreground-dim'
                }`}>
                  R
                </span>
                <span className="text-xs text-foreground-dim">Reset</span>
              </div>
            </div>
          </div>

          {/* Zoom Level Panel */}
          <div className="hidden lg:block bg-background-secondary rounded-xl border border-border p-4">
            <p className="text-xs text-foreground-dim font-medium uppercase tracking-wide mb-3">
              Zoom Level
            </p>
            <div className="flex gap-2">
              {([1, 2, 3] as const).map((level) => (
                <button
                  key={level}
                  onClick={() => handleSetZoomLevel(level)}
                  className={`flex-1 flex flex-col items-center gap-1 py-2 px-3 rounded-lg border transition-colors ${
                    zoomLevel === level
                      ? 'bg-accent border-accent text-black'
                      : 'bg-white/10 border-border text-foreground-dim hover:bg-white/20'
                  }`}
                >
                  <span className="text-xs font-mono">{level}</span>
                  <span className="text-[10px]">{level === 1 ? '2x' : level === 2 ? '4x' : '8x'}</span>
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Right Panel - Image Canvas */}
        <div className="lg:col-span-2">
          {/* Zoom Controls */}
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <button
                onClick={handleZoomOut}
                disabled={zoomLevel <= 1}
                className="p-2 rounded-lg bg-white/10 text-white hover:bg-white/20 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <ZoomOut className="w-5 h-5" />
              </button>
              <span className="text-sm text-foreground-dim min-w-[4rem] text-center">
                {Math.round(zoom * 100)}%
              </span>
              <button
                onClick={handleZoomIn}
                disabled={zoomLevel >= 3}
                className="p-2 rounded-lg bg-white/10 text-white hover:bg-white/20 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <ZoomIn className="w-5 h-5" />
              </button>
              <button
                onClick={handleResetZoom}
                disabled={zoomLevel === 1}
                className="p-2 rounded-lg bg-white/10 text-white hover:bg-white/20 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <RotateCcw className="w-5 h-5" />
              </button>
            </div>

            <button
              onClick={() => setIsFullscreen(!isFullscreen)}
              className="p-2 rounded-lg bg-white/10 text-white hover:bg-white/20 transition-colors"
            >
              {isFullscreen ? (
                <Minimize2 className="w-5 h-5" />
              ) : (
                <Maximize2 className="w-5 h-5" />
              )}
            </button>
          </div>

          {/* Image Canvas */}
          <motion.div
            layout
            className={`relative rounded-2xl overflow-hidden bg-black border border-border ${
              isFullscreen ? 'fixed inset-4 z-50' : 'aspect-[3/4]'
            }`}
          >
            {/* Fullscreen overlay background */}
            {isFullscreen && (
              <div
                className="fixed inset-0 bg-black/90 -z-10"
                onClick={() => setIsFullscreen(false)}
              />
            )}

            <div
              ref={containerRef}
              className="absolute inset-0 cursor-crosshair overflow-hidden"
              onClick={handleContainerClick}
              onMouseDown={handleMouseDown}
              onMouseMove={handleMouseMove}
              onMouseUp={handleMouseUp}
              onMouseLeave={handleMouseUp}
              style={{
                cursor: zoom > 1 && isDragging ? 'grabbing' : zoom > 1 ? 'grab' : 'crosshair',
              }}
            >
              {/* Transformed Image Container */}
              <div
                className="absolute inset-0 transition-transform duration-100"
                style={{
                  transform: `scale(${zoom}) translate(${pan.x / zoom}px, ${pan.y / zoom}px)`,
                  transformOrigin: 'center center',
                }}
              >
                {/* User's Image */}
                <Image
                  src={imageUrl}
                  alt="Your photo"
                  fill
                  className="object-contain pointer-events-none select-none"
                  unoptimized
                  draggable={false}
                />

                {/* All Landmarks (dimmed) */}
                {showAllPoints &&
                  landmarks.map((landmark) => {
                    if (landmark.id === currentLandmarkId) return null;
                    const lmColor = getLandmarkColor(landmark.id, FRONT_LANDMARK_CATEGORIES);
                    return (
                      <div
                        key={landmark.id}
                        className="absolute w-3 h-3 -translate-x-1/2 -translate-y-1/2 pointer-events-none"
                        style={{
                          left: `${landmark.x * 100}%`,
                          top: `${landmark.y * 100}%`,
                          opacity: 0.3,
                        }}
                      >
                        <div
                          className="w-full h-full rounded-full border border-white/50"
                          style={{ backgroundColor: lmColor }}
                        />
                      </div>
                    );
                  })}

                {/* Current Landmark (highlighted) */}
                {currentLandmark && (
                  <motion.div
                    key={currentLandmarkId}
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    className="absolute w-6 h-6 -translate-x-1/2 -translate-y-1/2 z-20"
                    style={{
                      left: `${currentLandmark.x * 100}%`,
                      top: `${currentLandmark.y * 100}%`,
                    }}
                  >
                    {/* Pulsing ring */}
                    <motion.div
                      className="absolute inset-0 rounded-full"
                      style={{ borderColor: color }}
                      animate={{
                        scale: [1, 1.5, 1],
                        opacity: [0.8, 0, 0.8],
                      }}
                      transition={{
                        duration: 2,
                        repeat: Infinity,
                        ease: 'easeInOut',
                      }}
                    >
                      <div
                        className="w-full h-full rounded-full border-2"
                        style={{ borderColor: color }}
                      />
                    </motion.div>

                    {/* Main dot */}
                    <div
                      className="absolute inset-1 rounded-full border-2 border-white shadow-lg"
                      style={{
                        backgroundColor: color,
                        boxShadow: `0 0 20px ${color}`,
                      }}
                    />

                    {/* Crosshair */}
                    <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                      <div
                        className="absolute w-8 h-[2px] -translate-x-1/2 left-1/2"
                        style={{ backgroundColor: `${color}80` }}
                      />
                      <div
                        className="absolute h-8 w-[2px] -translate-y-1/2 top-1/2"
                        style={{ backgroundColor: `${color}80` }}
                      />
                    </div>
                  </motion.div>
                )}
              </div>

              {/* Zoom indicator in corner */}
              {zoom > 1 && (
                <div className="absolute top-3 left-3 px-2 py-1 rounded bg-black/70 text-white text-xs">
                  {Math.round(zoom * 100)}% - Drag to pan
                </div>
              )}
            </div>

            {/* Instructions overlay */}
            <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-4">
              <p className="text-center text-white text-sm">
                Click on the image to place the{' '}
                <span style={{ color: color }}>{currentLandmark?.label}</span> landmark
              </p>
            </div>
          </motion.div>

          {/* Navigation Buttons */}
          <div className="flex items-center justify-between mt-4">
            <button
              onClick={handlePrevious}
              disabled={currentStepIndex === 0}
              className="flex items-center gap-2 px-4 py-3 rounded-lg bg-white/10 text-white hover:bg-white/20 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronLeft className="w-5 h-5" />
              Previous
            </button>

            <div className="flex items-center gap-1">
              {/* Step indicators - show subset around current */}
              {Array.from({ length: Math.min(7, totalSteps) }).map((_, i) => {
                let stepIndex: number;
                if (totalSteps <= 7) {
                  stepIndex = i;
                } else if (currentStepIndex < 3) {
                  stepIndex = i;
                } else if (currentStepIndex > totalSteps - 4) {
                  stepIndex = totalSteps - 7 + i;
                } else {
                  stepIndex = currentStepIndex - 3 + i;
                }

                const isCompleted = stepIndex < currentStepIndex;
                const isCurrent = stepIndex === currentStepIndex;

                return (
                  <button
                    key={stepIndex}
                    onClick={() => {
                      setCurrentStepIndex(stepIndex);
                      handleResetZoom();
                    }}
                    className={`w-2 h-2 rounded-full transition-all ${
                      isCurrent
                        ? 'w-6 bg-accent'
                        : isCompleted
                          ? 'bg-green-500'
                          : 'bg-white/20'
                    }`}
                  />
                );
              })}
            </div>

            <button
              onClick={handleNext}
              className="flex items-center gap-2 px-6 py-3 rounded-lg bg-accent text-black font-semibold hover:shadow-[0_0_20px_rgba(0,243,255,0.5)] transition-all"
            >
              {currentStepIndex === totalSteps - 1 ? (
                <>
                  <Check className="w-5 h-5" />
                  Complete
                </>
              ) : (
                <>
                  Next
                  <ChevronRight className="w-5 h-5" />
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
