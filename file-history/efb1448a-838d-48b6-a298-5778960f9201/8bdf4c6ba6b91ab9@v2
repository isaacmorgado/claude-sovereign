'use client';

import { useState, useRef, useCallback, useEffect } from 'react';
import Image from 'next/image';
import { motion } from 'framer-motion';
import {
  ChevronLeft,
  ChevronRight,
  ChevronUp,
  ChevronDown,
  Check,
  Info,
  Scan,
  Loader2,
  Move,
  Focus,
  AlertTriangle,
  X,
} from 'lucide-react';
import {
  LandmarkPoint,
  FRONT_PROFILE_LANDMARKS,
  SIDE_PROFILE_LANDMARKS,
  getLandmarkColor,
  FRONT_LANDMARK_CATEGORIES,
  SIDE_LANDMARK_CATEGORIES,
} from '@/lib/landmarks';
import { getLandmarkImagePath, getLandmarkPlacementGuide } from '@/lib/landmarkImages';
import { detectFromImageUrl } from '@/lib/mediapipeDetection';

interface LandmarkAnalysisToolProps {
  imageUrl: string;
  mode: 'front' | 'side';
  initialLandmarks?: LandmarkPoint[];
  onLandmarksChange?: (landmarks: LandmarkPoint[]) => void;
  onComplete?: (landmarks: LandmarkPoint[]) => void;
  onBack?: () => void;
}

function getOrderedLandmarks(mode: 'front' | 'side'): string[] {
  const landmarks = mode === 'front' ? FRONT_PROFILE_LANDMARKS : SIDE_PROFILE_LANDMARKS;
  return landmarks.map(lm => lm.id);
}

export function LandmarkAnalysisTool({
  imageUrl,
  mode,
  initialLandmarks,
  onLandmarksChange,
  onComplete,
  onBack,
}: LandmarkAnalysisToolProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [imageDimensions, setImageDimensions] = useState<{ width: number; height: number } | null>(null);
  const [containerSize, setContainerSize] = useState<{ width: number; height: number } | null>(null);
  const defaultLandmarks = mode === 'front' ? FRONT_PROFILE_LANDMARKS : SIDE_PROFILE_LANDMARKS;
  const categories = mode === 'front' ? FRONT_LANDMARK_CATEGORIES : SIDE_LANDMARK_CATEGORIES;
  const orderedIds = getOrderedLandmarks(mode);

  const [landmarks, setLandmarks] = useState<LandmarkPoint[]>(
    initialLandmarks || defaultLandmarks
  );
  const [currentStepIndex, setCurrentStepIndex] = useState(0);
  const [zoomLevel, setZoomLevel] = useState(2); // FaceIQ parity: 2x/4x/8x discrete levels

  // Reset state when mode changes (fixes side profile starting at step 52)
  useEffect(() => {
    const newLandmarks = mode === 'front' ? FRONT_PROFILE_LANDMARKS : SIDE_PROFILE_LANDMARKS;
    setCurrentStepIndex(0);
    setPlacedLandmarks(new Set());
    setHasAutoDetected(false);
    setDetectionFailed(false);
    setLandmarks(newLandmarks);
    setPan({ x: 0, y: 0 });
    setZoomLevel(2); // FaceIQ parity: start at 2x
  }, [mode]);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [pressedKeys, setPressedKeys] = useState<Set<string>>(new Set());
  const [activeTab, setActiveTab] = useState<'info' | 'reference'>('info');
  const [isDetecting, setIsDetecting] = useState(true);
  const [hasAutoDetected, setHasAutoDetected] = useState(false);
  const [autoZoomEnabled, setAutoZoomEnabled] = useState(true);
  const [detectionFailed, setDetectionFailed] = useState(false);
  const [placedLandmarks, setPlacedLandmarks] = useState<Set<string>>(new Set());
  // Frankfort Plane for side profile visualization (from server detection)
  const [frankfortPlane, setFrankfortPlane] = useState<{
    angle: number;
    orbitale: { x: number; y: number };
    porion: { x: number; y: number };
  } | null>(null);

  const currentLandmarkId = orderedIds[currentStepIndex];
  const currentLandmark = landmarks.find((lm) => lm.id === currentLandmarkId);
  const totalSteps = orderedIds.length;
  const progress = ((currentStepIndex + 1) / totalSteps) * 100;

  const color = currentLandmark
    ? getLandmarkColor(currentLandmark.id, categories)
    : '#00f3ff';

  // Load image dimensions on mount
  useEffect(() => {
    const img = new window.Image();
    img.onload = () => {
      setImageDimensions({ width: img.naturalWidth, height: img.naturalHeight });
    };
    img.src = imageUrl;
  }, [imageUrl]);

  // Track container size changes with ResizeObserver
  useEffect(() => {
    if (!containerRef.current) return;

    const observer = new ResizeObserver((entries) => {
      const { width, height } = entries[0].contentRect;
      setContainerSize({ width, height });
    });

    observer.observe(containerRef.current);
    return () => observer.disconnect();
  }, []);

  // Calculate the rendered image bounds within the container (accounting for object-contain)
  const getImageBounds = useCallback(() => {
    if (!containerRef.current || !imageDimensions || !containerSize) {
      return { offsetX: 0, offsetY: 0, renderedWidth: 1, renderedHeight: 1, containerWidth: 1, containerHeight: 1 };
    }

    const containerWidth = containerSize.width;
    const containerHeight = containerSize.height;
    const imageAspect = imageDimensions.width / imageDimensions.height;
    const containerAspect = containerWidth / containerHeight;

    let renderedWidth: number;
    let renderedHeight: number;
    let offsetX = 0;
    let offsetY = 0;

    if (imageAspect > containerAspect) {
      renderedWidth = containerWidth;
      renderedHeight = containerWidth / imageAspect;
      offsetY = (containerHeight - renderedHeight) / 2;
    } else {
      renderedHeight = containerHeight;
      renderedWidth = containerHeight * imageAspect;
      offsetX = (containerWidth - renderedWidth) / 2;
    }

    return { offsetX, offsetY, renderedWidth, renderedHeight, containerWidth, containerHeight };
  }, [imageDimensions, containerSize]);

  // Get what normalized coordinates the center orb points to on the image
  const getCrosshairNormalizedPosition = useCallback(() => {
    const bounds = getImageBounds();
    if (!bounds.renderedWidth || !bounds.renderedHeight) {
      return { x: 0.5, y: 0.5 };
    }

    // The container center (where the orb is) in screen coordinates
    const containerCenterX = bounds.containerWidth / 2;
    const containerCenterY = bounds.containerHeight / 2;

    // The transform is: translate(pan.x, pan.y) scale(zoomLevel)
    // To find what image point is at container center, we reverse this:
    // 1. The point at container center after transform comes from:
    //    screenPos = imagePos * zoomLevel + pan
    // 2. Solving for imagePos:
    //    imagePos = (screenPos - pan) / zoomLevel
    const imageX = (containerCenterX - pan.x) / zoomLevel;
    const imageY = (containerCenterY - pan.y) / zoomLevel;

    // Convert to normalized (0-1) coordinates within the image
    const normalizedX = (imageX - bounds.offsetX) / bounds.renderedWidth;
    const normalizedY = (imageY - bounds.offsetY) / bounds.renderedHeight;

    return {
      x: Math.max(0, Math.min(1, normalizedX)),
      y: Math.max(0, Math.min(1, normalizedY)),
    };
  }, [getImageBounds, pan, zoomLevel]);

  // Convert normalized image coordinates (0-1) to pixel position within the container
  // Note: This is used for landmarks INSIDE the transformed container, so no zoom/pan needed
  const getLandmarkPixelPosition = useCallback((x: number, y: number) => {
    const bounds = getImageBounds();
    // Position relative to container (the parent transform handles zoom/pan)
    const pixelX = bounds.offsetX + x * bounds.renderedWidth;
    const pixelY = bounds.offsetY + y * bounds.renderedHeight;
    return { left: pixelX, top: pixelY };
  }, [getImageBounds]);

  useEffect(() => {
    onLandmarksChange?.(landmarks);
  }, [landmarks, onLandmarksChange]);

  // Confirm placement: set current landmark to where crosshair points
  const confirmPlacement = useCallback(() => {
    const pos = getCrosshairNormalizedPosition();
    setLandmarks((prev) =>
      prev.map((lm) =>
        lm.id === currentLandmarkId ? { ...lm, x: pos.x, y: pos.y } : lm
      )
    );
    setPlacedLandmarks((prev) => new Set(prev).add(currentLandmarkId));
  }, [currentLandmarkId, getCrosshairNormalizedPosition]);

  // Handle click - confirms placement at crosshair position
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const handleContainerClick = useCallback(() => {
    if (isDragging) return;
    confirmPlacement();
  }, [isDragging, confirmPlacement]);

  // Mouse down - start dragging to pan
  const handleMouseDown = useCallback(
    (e: React.MouseEvent) => {
      if (e.button === 0) {
        setIsDragging(true);
        setDragStart({ x: e.clientX - pan.x, y: e.clientY - pan.y });
      }
    },
    [pan]
  );

  // Mouse move - pan the image
  const handleMouseMove = useCallback(
    (e: React.MouseEvent) => {
      if (isDragging) {
        setPan({
          x: e.clientX - dragStart.x,
          y: e.clientY - dragStart.y,
        });
      }
    },
    [isDragging, dragStart]
  );

  const handleMouseUp = useCallback(() => {
    setIsDragging(false);
  }, []);

  const handleResetZoom = useCallback(() => {
    setZoomLevel(2); // FaceIQ parity: reset to 2x
    setPan({ x: 0, y: 0 });
  }, []);

  // Pan the image using arrow keys (moves the crosshair target point on the image)
  const panImage = useCallback((direction: 'up' | 'down' | 'left' | 'right') => {
    const step = 20; // pixels to pan per keypress
    setPan((prev) => {
      switch (direction) {
        case 'up': return { ...prev, y: prev.y + step };
        case 'down': return { ...prev, y: prev.y - step };
        case 'left': return { ...prev, x: prev.x + step };
        case 'right': return { ...prev, x: prev.x - step };
        default: return prev;
      }
    });
  }, []);

  const handleNext = useCallback(() => {
    // Confirm placement at current crosshair position before moving to next
    confirmPlacement();

    if (currentStepIndex < totalSteps - 1) {
      setCurrentStepIndex((prev) => prev + 1);
      // Don't reset zoom - let zoomToLandmark handle it
    } else {
      onComplete?.(landmarks);
    }
  }, [currentStepIndex, totalSteps, landmarks, onComplete, confirmPlacement]);

  const handlePrevious = useCallback(() => {
    if (currentStepIndex > 0) {
      setCurrentStepIndex((prev) => prev - 1);
      handleResetZoom();
    } else {
      onBack?.();
    }
  }, [currentStepIndex, handleResetZoom, onBack]);

  // Auto-zoom to the current landmark's region - centers the landmark under the fixed orb
  const zoomToLandmark = useCallback((landmarkId: string) => {
    if (!autoZoomEnabled || !containerRef.current || !containerSize || !imageDimensions) return;

    const landmark = landmarks.find(lm => lm.id === landmarkId);
    if (!landmark) return;

    const bounds = getImageBounds();
    if (bounds.renderedWidth <= 1 || bounds.renderedHeight <= 1) return; // Bounds not ready

    // FaceIQ parity: Zoom to 2x for good precision
    const newZoom = 2;
    setZoomLevel(newZoom);

    // Calculate pan so the landmark appears at container center (under the fixed orb)
    const containerCenterX = bounds.containerWidth / 2;
    const containerCenterY = bounds.containerHeight / 2;

    // Where the landmark is in unzoomed image space
    const landmarkX = bounds.offsetX + landmark.x * bounds.renderedWidth;
    const landmarkY = bounds.offsetY + landmark.y * bounds.renderedHeight;

    // Pan needed: after zoom, landmark should be at container center
    // Transform is: translate(pan) scale(zoom) with origin at 0,0
    // A point at landmarkPos ends up at: landmarkPos * zoom + pan
    // We want it at containerCenter, so: pan = containerCenter - landmarkPos * zoom
    setPan({
      x: containerCenterX - landmarkX * newZoom,
      y: containerCenterY - landmarkY * newZoom,
    });
  }, [autoZoomEnabled, landmarks, getImageBounds, containerSize, imageDimensions]);

  // Auto-detect landmarks using Human.js/MediaPipe
  const handleAutoDetect = useCallback(async () => {
    setIsDetecting(true);
    setDetectionFailed(false);
    setFrankfortPlane(null);
    try {
      const result = await detectFromImageUrl(imageUrl, mode);
      console.log('[DEBUG] Detection result:', result);
      console.log('[DEBUG] Sample landmarks:', result?.landmarks.slice(0, 5));
      if (result && result.landmarks.length > 0) {
        // Update landmarks with detected positions
        setLandmarks(prev =>
          prev.map(lm => {
            const detected = result.landmarks.find(d => d.id === lm.id);
            if (detected) {
              return { ...lm, x: detected.x, y: detected.y };
            }
            return lm;
          })
        );
        setHasAutoDetected(true);
        setDetectionFailed(false);

        // Capture Frankfort Plane for side profile (from server-side detection)
        if (mode === 'side' && result.frankfortPlane) {
          console.log('[DEBUG] Frankfort Plane:', result.frankfortPlane);
          setFrankfortPlane(result.frankfortPlane);
        }

        // Zoom to first landmark after detection
        zoomToLandmark(orderedIds[0]);
      } else {
        // Detection returned no results - common for side profile
        console.log('[DEBUG] No landmarks detected - manual placement required');
        setDetectionFailed(true);
        setHasAutoDetected(false);
      }
    } catch (error) {
      console.error('Auto-detection failed:', error);
      setDetectionFailed(true);
    } finally {
      setIsDetecting(false);
    }
  }, [imageUrl, mode, orderedIds, zoomToLandmark]);

  // Auto-detect after image dimensions are loaded (prevents race condition)
  useEffect(() => {
    if (imageDimensions) {
      handleAutoDetect();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [imageDimensions]); // Run after dimensions are loaded

  // Auto-zoom when step changes or container size becomes available
  useEffect(() => {
    if (hasAutoDetected && autoZoomEnabled && currentLandmarkId && containerSize) {
      zoomToLandmark(currentLandmarkId);
    }
  }, [currentStepIndex, currentLandmarkId, hasAutoDetected, autoZoomEnabled, zoomToLandmark, containerSize]);

  // Keyboard handlers with proper state tracking
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'Enter', 'Backspace', 'r', 'R'].includes(e.key)) {
        e.preventDefault();
      }

      setPressedKeys((prev) => new Set(prev).add(e.key));

      switch (e.key) {
        case 'ArrowUp': panImage('up'); break;
        case 'ArrowDown': panImage('down'); break;
        case 'ArrowLeft': panImage('left'); break;
        case 'ArrowRight': panImage('right'); break;
        case 'Enter': handleNext(); break;
        case 'Backspace': handlePrevious(); break;
        case 'r':
        case 'R': handleResetZoom(); break;
      }
    };

    const handleKeyUp = (e: KeyboardEvent) => {
      setPressedKeys((prev) => {
        const next = new Set(prev);
        next.delete(e.key);
        return next;
      });
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
    };
  }, [panImage, handleNext, handlePrevious, handleResetZoom]);

  const isKeyPressed = (key: string) => pressedKeys.has(key);

  return (
    <div className="fixed inset-0 bg-black">
      <div className="flex flex-col md:flex-row h-full gap-3 p-3 md:p-4">
        {/* Sidebar - Right on desktop */}
        <div className="w-full md:w-80 flex-shrink-0 flex flex-col gap-3 md:order-2 overflow-hidden md:overflow-y-auto">
          {/* Progress Card */}
          <div className="bg-neutral-900 rounded-xl border border-neutral-800 overflow-hidden flex-shrink-0">
            <div className="p-4">
              <div className="flex items-center justify-between text-xs text-neutral-400 mb-2">
                <span>Step {currentStepIndex + 1} of {totalSteps}</span>
                <span>{Math.round(progress)}%</span>
              </div>
              <div className="h-1.5 bg-neutral-800 rounded-full overflow-hidden mb-3">
                <motion.div
                  className="h-full rounded-full"
                  style={{ width: `${progress}%`, backgroundColor: '#00f3ff' }}
                  transition={{ duration: 0.3 }}
                />
              </div>
              <div className="flex items-center gap-2">
                <div className="w-6 h-6 bg-[#00f3ff] rounded-full flex items-center justify-center flex-shrink-0">
                  <Check className="w-3.5 h-3.5 text-black" />
                </div>
                <span className="text-sm font-medium text-white">
                  {currentStepIndex} placed
                </span>
              </div>
            </div>

            {/* View Tabs */}
            <div className="flex border-t border-neutral-800">
              <button
                onClick={() => setActiveTab('info')}
                className={`flex-1 py-2.5 text-xs font-medium transition-colors ${
                  activeTab === 'info'
                    ? 'text-[#00f3ff] border-b-2 border-[#00f3ff]'
                    : 'text-neutral-500 hover:text-neutral-300'
                }`}
              >
                Current Point
              </button>
              <button
                onClick={() => setActiveTab('reference')}
                className={`flex-1 py-2.5 text-xs font-medium transition-colors ${
                  activeTab === 'reference'
                    ? 'text-[#00f3ff] border-b-2 border-[#00f3ff]'
                    : 'text-neutral-500 hover:text-neutral-300'
                }`}
              >
                Reference
              </button>
            </div>

            {/* Info/Reference Content */}
            <div className="bg-neutral-900/50">
              {activeTab === 'info' ? (
                <div>
                  {/* Photo Reference Image */}
                  {currentLandmark && getLandmarkImagePath(currentLandmark.id, mode, 'photo') ? (
                    <div className="relative w-full aspect-square bg-neutral-800">
                      <Image
                        src={getLandmarkImagePath(currentLandmark.id, mode, 'photo')!}
                        alt={currentLandmark.label}
                        fill
                        className="object-contain"
                        unoptimized
                      />
                    </div>
                  ) : (
                    <div className="w-full aspect-square bg-neutral-800 flex items-center justify-center">
                      <div
                        className="w-14 h-14 rounded-full flex items-center justify-center"
                        style={{ backgroundColor: `${color}20`, border: `2px solid ${color}` }}
                      >
                        <div className="w-4 h-4 rounded-full" style={{ backgroundColor: color }} />
                      </div>
                    </div>
                  )}
                  <div className="p-3 text-center border-t border-neutral-800">
                    <p className="text-sm font-semibold text-white">{currentLandmark?.label}</p>
                    <p className="text-xs text-[#00f3ff] mt-0.5 font-mono">{currentLandmark?.medicalTerm}</p>
                  </div>
                </div>
              ) : (
                <div>
                  {/* Infographic Reference Image */}
                  {currentLandmark && getLandmarkImagePath(currentLandmark.id, mode, 'infographic') ? (
                    <div className="relative w-full aspect-square bg-neutral-800">
                      <Image
                        src={getLandmarkImagePath(currentLandmark.id, mode, 'infographic')!}
                        alt={`${currentLandmark.label} infographic`}
                        fill
                        className="object-contain"
                        unoptimized
                      />
                    </div>
                  ) : (
                    <div className="w-full aspect-square bg-neutral-800 flex items-center justify-center">
                      <Info className="w-12 h-12 text-neutral-600" />
                    </div>
                  )}
                  <div className="p-3 text-center border-t border-neutral-800">
                    <p className="text-sm text-neutral-300">
                      {currentLandmark ? getLandmarkPlacementGuide(currentLandmark.id, mode) : ''}
                    </p>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Keyboard Shortcuts - Desktop only */}
          <div className="hidden md:flex flex-col gap-3">
            <div className="bg-neutral-900 rounded-xl border border-neutral-800 p-4">
              <p className="text-xs text-neutral-500 font-medium uppercase tracking-wide mb-3 text-center">
                Keyboard Controls
              </p>
              <div className="flex justify-center mb-4">
                <div className="flex flex-col gap-1 items-center">
                  {/* Arrow Up */}
                  <div
                    className={`w-10 h-10 rounded-lg flex items-center justify-center transition-all duration-100 ${
                      isKeyPressed('ArrowUp')
                        ? 'bg-[#00f3ff] text-black shadow-[0_0_15px_rgba(0,243,255,0.5)]'
                        : 'bg-neutral-800 text-neutral-400 border border-neutral-700'
                    }`}
                  >
                    <ChevronUp className="w-5 h-5" />
                  </div>
                  {/* Arrow Row */}
                  <div className="flex gap-1">
                    {[
                      { key: 'ArrowLeft', icon: ChevronLeft },
                      { key: 'ArrowDown', icon: ChevronDown },
                      { key: 'ArrowRight', icon: ChevronRight },
                    ].map(({ key, icon: Icon }) => (
                      <div
                        key={key}
                        className={`w-10 h-10 rounded-lg flex items-center justify-center transition-all duration-100 ${
                          isKeyPressed(key)
                            ? 'bg-[#00f3ff] text-black shadow-[0_0_15px_rgba(0,243,255,0.5)]'
                            : 'bg-neutral-800 text-neutral-400 border border-neutral-700'
                        }`}
                      >
                        <Icon className="w-5 h-5" />
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              <div className="space-y-2 text-sm">
                <div className="flex items-center justify-between">
                  <span
                    className={`px-2 py-1 rounded font-mono text-xs transition-all duration-100 ${
                      isKeyPressed('Enter')
                        ? 'bg-[#00f3ff] text-black'
                        : 'bg-neutral-800 text-neutral-400'
                    }`}
                  >
                    Enter
                  </span>
                  <span className="text-neutral-500">Next point</span>
                </div>
                <div className="flex items-center justify-between">
                  <span
                    className={`px-2 py-1 rounded font-mono text-xs transition-all duration-100 ${
                      isKeyPressed('Backspace')
                        ? 'bg-[#00f3ff] text-black'
                        : 'bg-neutral-800 text-neutral-400'
                    }`}
                  >
                    Backspace
                  </span>
                  <span className="text-neutral-500">Previous</span>
                </div>
                <div className="flex items-center justify-between">
                  <span
                    className={`px-2 py-1 rounded font-mono text-xs transition-all duration-100 ${
                      isKeyPressed('r') || isKeyPressed('R')
                        ? 'bg-[#00f3ff] text-black'
                        : 'bg-neutral-800 text-neutral-400'
                    }`}
                  >
                    R
                  </span>
                  <span className="text-neutral-500">Reset zoom</span>
                </div>
              </div>
            </div>

            {/* Zoom Controls */}
            <div className="bg-neutral-900 rounded-xl border border-neutral-800 p-4">
              <p className="text-xs text-neutral-500 font-medium uppercase tracking-wide mb-3">
                Zoom Level
              </p>
              <div className="flex gap-2">
                {/* FaceIQ parity: 2x/4x/8x discrete zoom levels */}
                {[2, 4, 8].map((level) => (
                  <button
                    key={level}
                    onClick={() => {
                      if (containerSize) {
                        // Adjust pan to keep the same center point visible when zoom changes
                        // Current center in image space: imageCenter = (containerCenter - pan) / oldZoom
                        // New pan to show same center: newPan = containerCenter - imageCenter * newZoom
                        const containerCenterX = containerSize.width / 2;
                        const containerCenterY = containerSize.height / 2;
                        const imageCenterX = (containerCenterX - pan.x) / zoomLevel;
                        const imageCenterY = (containerCenterY - pan.y) / zoomLevel;
                        const newPanX = containerCenterX - imageCenterX * level;
                        const newPanY = containerCenterY - imageCenterY * level;
                        setZoomLevel(level);
                        setPan({ x: newPanX, y: newPanY });
                      } else {
                        setZoomLevel(level);
                      }
                    }}
                    className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
                      zoomLevel === level
                        ? 'bg-[#00f3ff] text-black'
                        : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
                    }`}
                  >
                    {level}x
                  </button>
                ))}
              </div>
            </div>

            {/* Auto-Detect Button */}
            <button
              onClick={handleAutoDetect}
              disabled={isDetecting}
              className={`w-full py-3 rounded-lg text-sm font-medium transition-all flex items-center justify-center gap-2 ${
                hasAutoDetected
                  ? 'bg-green-500/20 text-green-400 border border-green-500/30'
                  : 'bg-gradient-to-r from-[#00f3ff] to-[#00c4cc] text-black hover:shadow-[0_0_20px_rgba(0,243,255,0.3)]'
              } disabled:opacity-50 disabled:cursor-not-allowed`}
            >
              {isDetecting ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Detecting...
                </>
              ) : hasAutoDetected ? (
                <>
                  <Check className="w-4 h-4" />
                  Detected - Adjust if needed
                </>
              ) : (
                <>
                  <Scan className="w-4 h-4" />
                  Auto-Detect Landmarks
                </>
              )}
            </button>

            {/* Auto-Zoom Toggle */}
            <button
              onClick={() => setAutoZoomEnabled(!autoZoomEnabled)}
              className={`w-full py-2.5 rounded-lg text-xs font-medium transition-all flex items-center justify-center gap-2 ${
                autoZoomEnabled
                  ? 'bg-[#00f3ff] text-black'
                  : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
              }`}
            >
              <Focus className="w-4 h-4" />
              {autoZoomEnabled ? 'Auto-Zoom: ON' : 'Auto-Zoom: OFF'}
            </button>

          </div>
        </div>

        {/* Main Image Area */}
        <div className="flex-1 min-h-0 relative md:order-1 flex flex-col">
          <div
            ref={containerRef}
            className="relative flex-1 bg-neutral-900 overflow-hidden rounded-xl border border-neutral-800 select-none"
            onMouseDown={handleMouseDown}
            onMouseMove={handleMouseMove}
            onMouseUp={handleMouseUp}
            onMouseLeave={handleMouseUp}
            style={{
              cursor: isDragging ? 'grabbing' : 'grab',
            }}
          >
            {/* Transformed Content - Image and placed landmarks move together */}
            <div
              className="absolute inset-0"
              style={{
                transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoomLevel})`,
                transformOrigin: '0 0',
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

              {/* Placed landmarks - always visible as they're placed */}
              {landmarks.filter(lm => placedLandmarks.has(lm.id) && lm.id !== currentLandmarkId).map((landmark) => {
                const lmColor = getLandmarkColor(landmark.id, categories);
                const pos = getLandmarkPixelPosition(landmark.x, landmark.y);

                return (
                  <div
                    key={landmark.id}
                    className="absolute pointer-events-none"
                    style={{
                      left: pos.left,
                      top: pos.top,
                      transform: `translate(-50%, -50%) scale(${1 / zoomLevel})`,
                      transformOrigin: 'center center',
                    }}
                  >
                    {/* Small persistent dot - matches Harmony style */}
                    <div
                      className="absolute rounded-full"
                      style={{
                        width: 8,
                        height: 8,
                        left: -4,
                        top: -4,
                        backgroundColor: lmColor,
                        boxShadow: `0 0 4px ${lmColor}, 0 0 8px ${lmColor}60`,
                        border: '1px solid rgba(255,255,255,0.5)',
                      }}
                    />
                  </div>
                );
              })}

              {/* Frankfort Horizontal Plane - green reference line for side profiles */}
              {mode === 'side' && frankfortPlane && (
                <svg
                  className="absolute inset-0 pointer-events-none"
                  style={{ width: '100%', height: '100%' }}
                >
                  {(() => {
                    const bounds = getImageBounds();
                    const orbitaleX = bounds.offsetX + frankfortPlane.orbitale.x * bounds.renderedWidth;
                    const orbitaleY = bounds.offsetY + frankfortPlane.orbitale.y * bounds.renderedHeight;
                    const porionX = bounds.offsetX + frankfortPlane.porion.x * bounds.renderedWidth;
                    const porionY = bounds.offsetY + frankfortPlane.porion.y * bounds.renderedHeight;

                    // Extend the line beyond the points for visibility
                    const dx = porionX - orbitaleX;
                    const dy = porionY - orbitaleY;
                    const length = Math.sqrt(dx * dx + dy * dy);
                    const extendFactor = length > 0 ? 0.3 : 0;
                    const startX = orbitaleX - (dx / length) * bounds.renderedWidth * extendFactor;
                    const startY = orbitaleY - (dy / length) * bounds.renderedWidth * extendFactor;
                    const endX = porionX + (dx / length) * bounds.renderedWidth * extendFactor;
                    const endY = porionY + (dy / length) * bounds.renderedWidth * extendFactor;

                    return (
                      <>
                        {/* Main Frankfort line */}
                        <line
                          x1={startX}
                          y1={startY}
                          x2={endX}
                          y2={endY}
                          stroke="#22c55e"
                          strokeWidth={2 / zoomLevel}
                          strokeDasharray={`${6 / zoomLevel} ${4 / zoomLevel}`}
                          opacity={0.8}
                        />
                        {/* Orbitale point marker */}
                        <circle
                          cx={orbitaleX}
                          cy={orbitaleY}
                          r={4 / zoomLevel}
                          fill="#22c55e"
                          stroke="white"
                          strokeWidth={1 / zoomLevel}
                        />
                        {/* Porion point marker */}
                        <circle
                          cx={porionX}
                          cy={porionY}
                          r={4 / zoomLevel}
                          fill="#22c55e"
                          stroke="white"
                          strokeWidth={1 / zoomLevel}
                        />
                        {/* Angle indicator */}
                        <text
                          x={startX}
                          y={startY - 10 / zoomLevel}
                          fill="#22c55e"
                          fontSize={12 / zoomLevel}
                          fontWeight="bold"
                        >
                          FH: {frankfortPlane.angle.toFixed(1)}°
                        </text>
                      </>
                    );
                  })()}
                </svg>
              )}
            </div>

            {/* FIXED CENTER TARGETING DOT - small precise point for accurate placement */}
            <div className="absolute inset-0 pointer-events-none flex items-center justify-center z-20">
              {/* Crosshair lines for precision */}
              <div
                className="absolute"
                style={{
                  width: 20,
                  height: 1,
                  backgroundColor: '#00f3ff',
                  opacity: 0.6,
                }}
              />
              <div
                className="absolute"
                style={{
                  width: 1,
                  height: 20,
                  backgroundColor: '#00f3ff',
                  opacity: 0.6,
                }}
              />
              {/* Subtle glow ring */}
              <div
                className="absolute rounded-full"
                style={{
                  width: 12,
                  height: 12,
                  background: 'radial-gradient(circle, #00f3ff33 0%, transparent 70%)',
                }}
              />
              {/* Center dot - small and precise */}
              <div
                className="relative rounded-full"
                style={{
                  width: 4,
                  height: 4,
                  backgroundColor: '#00f3ff',
                  boxShadow: '0 0 6px #00f3ff, 0 0 12px #00f3ff80',
                }}
              />
            </div>

            {/* Loading Overlay */}
            {isDetecting && (
              <div className="absolute inset-0 bg-black/70 flex flex-col items-center justify-center z-50">
                <Loader2 className="w-12 h-12 text-[#00f3ff] animate-spin mb-4" />
                <p className="text-white text-lg font-medium">Detecting landmarks...</p>
                <p className="text-neutral-400 text-sm mt-2">This may take a few seconds</p>
              </div>
            )}

            {/* Detection Failed Banner */}
            {detectionFailed && !isDetecting && (
              <motion.div
                initial={{ opacity: 0, y: -20 }}
                animate={{ opacity: 1, y: 0 }}
                className="absolute top-12 left-3 right-3 z-30"
              >
                <div className="bg-amber-500/20 border border-amber-500/50 rounded-lg px-3 py-2 flex items-center gap-2">
                  <AlertTriangle className="w-4 h-4 text-amber-400 flex-shrink-0" />
                  <p className="text-amber-200 text-xs flex-1">
                    {mode === 'side'
                      ? 'Auto-detection could not find profile. Please place landmarks manually for best accuracy.'
                      : 'Could not detect face. Please place landmarks manually.'}
                  </p>
                  <button
                    onClick={() => setDetectionFailed(false)}
                    className="text-amber-400 hover:text-amber-200 transition-colors"
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>
              </motion.div>
            )}

            {/* Zoom indicator */}
            <div className="absolute top-3 left-3 px-3 py-1.5 rounded-lg bg-black/80 border border-neutral-700 text-white text-xs flex items-center gap-2">
              <Move className="w-3 h-3" />
              {zoomLevel.toFixed(1)}x - Drag to align
            </div>

            {/* Current landmark label overlay */}
            <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black via-black/80 to-transparent p-4 pointer-events-none">
              <p className="text-center text-white text-sm font-medium">
                Drag image to align:{' '}
                <span className="font-semibold" style={{ color }}>{currentLandmark?.label}</span>
              </p>
              <p className="text-center text-neutral-400 text-xs mt-1">
                Press Enter or click Next to confirm
              </p>
            </div>
          </div>

          {/* Navigation Bar - Fixed at bottom of image area */}
          <div className="mt-3 flex items-center justify-center gap-3">
            <button
              onClick={handlePrevious}
              className="p-2.5 rounded-xl bg-neutral-800 text-neutral-300 hover:bg-neutral-700 border border-neutral-700 transition-all"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>

            {/* Step dots - show current position indicator */}
            <div className="flex items-center gap-2 px-4 py-2 bg-neutral-900 rounded-xl border border-neutral-800">
              <span className="text-xs text-neutral-400 font-mono min-w-[4ch]">
                {currentStepIndex + 1}
              </span>
              <div className="w-32 h-1.5 bg-neutral-800 rounded-full overflow-hidden">
                <div
                  className="h-full bg-[#00f3ff] rounded-full transition-all duration-200"
                  style={{ width: `${((currentStepIndex + 1) / totalSteps) * 100}%` }}
                />
              </div>
              <span className="text-xs text-neutral-400 font-mono min-w-[4ch] text-right">
                {totalSteps}
              </span>
            </div>

            <button
              onClick={handleNext}
              className={`flex items-center gap-2 px-5 py-2.5 rounded-xl font-medium text-sm transition-all ${
                currentStepIndex === totalSteps - 1
                  ? 'bg-green-500 text-white hover:bg-green-600'
                  : 'bg-[#00f3ff] text-black hover:shadow-[0_0_20px_rgba(0,243,255,0.4)]'
              }`}
            >
              {currentStepIndex === totalSteps - 1 ? (
                <>
                  <Check className="w-4 h-4" />
                  Complete
                </>
              ) : (
                <>
                  Next
                  <ChevronRight className="w-4 h-4" />
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
