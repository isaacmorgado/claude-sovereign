'use client';

import { useMemo, useState, useRef, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, Play, Pause, RotateCcw, ChevronRight } from 'lucide-react';
import { LandmarkPoint } from '@/lib/landmarks';
import { Recommendation } from '@/types/results';

interface FaceMorphingProps {
  photo: string;
  frontLandmarks: LandmarkPoint[];
  currentScore: number;
  potentialScore: number;
  recommendations: Recommendation[];
  className?: string;
}

// Treatment to landmark shift mappings
const TREATMENT_LANDMARK_SHIFTS: Record<string, { landmarks: string[]; dx: number; dy: number }[]> = {
  // Jaw treatments
  jaw: [
    { landmarks: ['left_gonion_inferior', 'right_gonion_inferior'], dx: 0.02, dy: 0 },
    { landmarks: ['left_mentum_lateralis', 'right_mentum_lateralis'], dx: 0.01, dy: 0 },
  ],
  chin: [
    { landmarks: ['menton', 'pogonion'], dx: 0, dy: 0.015 },
    { landmarks: ['labrale_inferius'], dx: 0, dy: 0.005 },
  ],
  nose: [
    { landmarks: ['pronasale', 'subnasale'], dx: 0, dy: -0.01 },
    { landmarks: ['left_ala_nasi', 'right_ala_nasi'], dx: -0.005, dy: 0 },
  ],
  eyes: [
    { landmarks: ['left_canthus_lateralis', 'right_canthus_lateralis'], dx: 0.005, dy: -0.008 },
    { landmarks: ['left_palpebra_superior', 'right_palpebra_superior'], dx: 0, dy: -0.005 },
  ],
  lips: [
    { landmarks: ['labrale_superius', 'labrale_inferius'], dx: 0, dy: 0.003 },
    { landmarks: ['left_cheilion', 'right_cheilion'], dx: 0.005, dy: 0 },
  ],
  cheeks: [
    { landmarks: ['left_zygion', 'right_zygion'], dx: 0.015, dy: -0.005 },
  ],
  forehead: [
    { landmarks: ['glabella', 'trichion'], dx: 0, dy: -0.01 },
  ],
};

// Map recommendation regions to treatment types
function getRegionFromRecommendation(refId: string): string {
  const name = refId.toLowerCase();
  if (name.includes('jaw') || name.includes('gonial') || name.includes('mandib')) return 'jaw';
  if (name.includes('nose') || name.includes('rhino') || name.includes('nasal')) return 'nose';
  if (name.includes('eye') || name.includes('cantho') || name.includes('blephar')) return 'eyes';
  if (name.includes('chin') || name.includes('genio') || name.includes('menton')) return 'chin';
  if (name.includes('lip') || name.includes('philtrum')) return 'lips';
  if (name.includes('cheek') || name.includes('zygo') || name.includes('malar')) return 'cheeks';
  if (name.includes('forehead') || name.includes('brow')) return 'forehead';
  return '';
}

// Calculate morphed landmarks based on recommendations
function calculateMorphedLandmarks(
  landmarks: LandmarkPoint[],
  recommendations: Recommendation[],
  morphProgress: number // 0-1
): LandmarkPoint[] {
  // Build shift map from recommendations
  const shiftMap = new Map<string, { dx: number; dy: number }>();

  recommendations.forEach(rec => {
    const region = getRegionFromRecommendation(rec.ref_id);
    const shifts = TREATMENT_LANDMARK_SHIFTS[region];
    if (!shifts) return;

    // Scale shift by impact (normalized to ~0.5 for typical impacts)
    const impactScale = Math.min(rec.impact / 2, 1);

    shifts.forEach(shift => {
      shift.landmarks.forEach(landmarkId => {
        const existing = shiftMap.get(landmarkId) || { dx: 0, dy: 0 };
        shiftMap.set(landmarkId, {
          dx: existing.dx + shift.dx * impactScale,
          dy: existing.dy + shift.dy * impactScale,
        });
      });
    });
  });

  // Apply shifts with easing
  const eased = easeInOutCubic(morphProgress);

  return landmarks.map(landmark => {
    const shift = shiftMap.get(landmark.id);
    if (!shift) return landmark;

    return {
      ...landmark,
      x: landmark.x + shift.dx * eased,
      y: landmark.y + shift.dy * eased,
    };
  });
}

// Easing function for smooth animation
function easeInOutCubic(t: number): number {
  return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
}

export function FaceMorphing({
  photo,
  frontLandmarks,
  currentScore,
  potentialScore,
  recommendations,
  className = '',
}: FaceMorphingProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const imageRef = useRef<HTMLImageElement | null>(null);
  const animationRef = useRef<number | null>(null);

  const [morphProgress, setMorphProgress] = useState(0);
  const [isAnimating, setIsAnimating] = useState(false);
  const [viewMode, setViewMode] = useState<'before' | 'morphing' | 'after'>('before');
  const [imageLoaded, setImageLoaded] = useState(false);

  const improvement = potentialScore - currentScore;

  // Morphed landmarks calculation
  const morphedLandmarks = useMemo(() => {
    return calculateMorphedLandmarks(frontLandmarks, recommendations, morphProgress);
  }, [frontLandmarks, recommendations, morphProgress]);

  // Load image
  useEffect(() => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => {
      imageRef.current = img;
      setImageLoaded(true);
    };
    img.src = photo;
  }, [photo]);

  // Canvas rendering with morphing
  const renderMorphedFace = useCallback(() => {
    const canvas = canvasRef.current;
    const img = imageRef.current;
    if (!canvas || !img || !imageLoaded) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Set canvas size
    canvas.width = img.width;
    canvas.height = img.height;

    // Clear canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw base image
    ctx.drawImage(img, 0, 0);

    // If morphing, apply displacement effect
    if (morphProgress > 0 && frontLandmarks.length > 0) {
      // Create displacement visualization
      ctx.save();

      // Get image data for manipulation
      const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
      const data = imageData.data;

      // Build landmark position map (before -> after)
      const shiftMap = new Map<string, { dx: number; dy: number }>();
      frontLandmarks.forEach((orig, i) => {
        const morphed = morphedLandmarks[i];
        if (morphed) {
          shiftMap.set(orig.id, {
            dx: (morphed.x - orig.x) * canvas.width,
            dy: (morphed.y - orig.y) * canvas.height,
          });
        }
      });

      // Apply subtle radial warp around each shifted landmark
      const tempCanvas = document.createElement('canvas');
      tempCanvas.width = canvas.width;
      tempCanvas.height = canvas.height;
      const tempCtx = tempCanvas.getContext('2d');
      if (tempCtx) {
        tempCtx.drawImage(img, 0, 0);

        // For each landmark with shift, warp surrounding pixels
        frontLandmarks.forEach(landmark => {
          const shift = shiftMap.get(landmark.id);
          if (!shift || (Math.abs(shift.dx) < 1 && Math.abs(shift.dy) < 1)) return;

          const cx = landmark.x * canvas.width;
          const cy = landmark.y * canvas.height;
          const radius = Math.min(canvas.width, canvas.height) * 0.08;

          // Sample and shift pixels in radius
          for (let py = Math.max(0, cy - radius); py < Math.min(canvas.height, cy + radius); py++) {
            for (let px = Math.max(0, cx - radius); px < Math.min(canvas.width, cx + radius); px++) {
              const dist = Math.sqrt((px - cx) ** 2 + (py - cy) ** 2);
              if (dist > radius) continue;

              // Falloff based on distance
              const falloff = 1 - (dist / radius);
              const eased = falloff * falloff; // Quadratic falloff

              // Source coordinates (shift backwards to pull pixels)
              const srcX = Math.round(px - shift.dx * eased);
              const srcY = Math.round(py - shift.dy * eased);

              if (srcX >= 0 && srcX < canvas.width && srcY >= 0 && srcY < canvas.height) {
                const srcIdx = (srcY * canvas.width + srcX) * 4;
                const dstIdx = (Math.round(py) * canvas.width + Math.round(px)) * 4;

                // Copy pixel with blend
                const blend = eased * 0.7;
                data[dstIdx] = data[dstIdx] * (1 - blend) + data[srcIdx] * blend;
                data[dstIdx + 1] = data[dstIdx + 1] * (1 - blend) + data[srcIdx + 1] * blend;
                data[dstIdx + 2] = data[dstIdx + 2] * (1 - blend) + data[srcIdx + 2] * blend;
              }
            }
          }
        });

        ctx.putImageData(imageData, 0, 0);
      }

      ctx.restore();

      // Draw improvement highlights
      ctx.globalAlpha = 0.3 * morphProgress;
      recommendations.slice(0, 6).forEach(rec => {
        const region = getRegionFromRecommendation(rec.ref_id);
        const shifts = TREATMENT_LANDMARK_SHIFTS[region];
        if (!shifts) return;

        shifts.forEach(shift => {
          shift.landmarks.forEach(landmarkId => {
            const landmark = frontLandmarks.find(l => l.id === landmarkId);
            if (!landmark) return;

            const x = landmark.x * canvas.width;
            const y = landmark.y * canvas.height;
            const radius = Math.min(canvas.width, canvas.height) * 0.05;

            // Green glow for improvements
            const gradient = ctx.createRadialGradient(x, y, 0, x, y, radius);
            gradient.addColorStop(0, 'rgba(34, 197, 94, 0.6)');
            gradient.addColorStop(1, 'rgba(34, 197, 94, 0)');

            ctx.beginPath();
            ctx.arc(x, y, radius, 0, Math.PI * 2);
            ctx.fillStyle = gradient;
            ctx.fill();
          });
        });
      });
      ctx.globalAlpha = 1;
    }
  }, [imageLoaded, morphProgress, frontLandmarks, morphedLandmarks, recommendations]);

  // Render on changes
  useEffect(() => {
    renderMorphedFace();
  }, [renderMorphedFace]);

  // Animation loop
  const startAnimation = useCallback(() => {
    if (isAnimating) return;

    setIsAnimating(true);
    setViewMode('morphing');

    const duration = 2000; // 2 seconds
    const startTime = performance.now();
    const startProgress = morphProgress;
    const targetProgress = 1;

    const animate = (currentTime: number) => {
      const elapsed = currentTime - startTime;
      const t = Math.min(elapsed / duration, 1);

      setMorphProgress(startProgress + (targetProgress - startProgress) * t);

      if (t < 1) {
        animationRef.current = requestAnimationFrame(animate);
      } else {
        setIsAnimating(false);
        setViewMode('after');
      }
    };

    animationRef.current = requestAnimationFrame(animate);
  }, [isAnimating, morphProgress]);

  const stopAnimation = useCallback(() => {
    if (animationRef.current) {
      cancelAnimationFrame(animationRef.current);
      animationRef.current = null;
    }
    setIsAnimating(false);
  }, []);

  const resetMorph = useCallback(() => {
    stopAnimation();
    setMorphProgress(0);
    setViewMode('before');
  }, [stopAnimation]);

  const skipToEnd = useCallback(() => {
    stopAnimation();
    setMorphProgress(1);
    setViewMode('after');
  }, [stopAnimation]);

  // Cleanup
  useEffect(() => {
    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, []);

  return (
    <div className={`bg-black/60 backdrop-blur-xl border border-white/10 rounded-2xl overflow-hidden ${className}`}>
      {/* Header */}
      <div className="p-4 border-b border-white/10">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sparkles size={18} className="text-cyan-400" />
            <h3 className="font-semibold text-white">Face Morphing Preview</h3>
          </div>
          <div className="flex items-center gap-1 text-xs">
            <span className={`px-2 py-1 rounded-full ${viewMode === 'before' ? 'bg-neutral-700 text-white' : 'text-neutral-500'}`}>
              Before
            </span>
            <span className={`px-2 py-1 rounded-full ${viewMode === 'morphing' ? 'bg-cyan-500/20 text-cyan-400' : 'text-neutral-500'}`}>
              Morphing
            </span>
            <span className={`px-2 py-1 rounded-full ${viewMode === 'after' ? 'bg-green-500/20 text-green-400' : 'text-neutral-500'}`}>
              After
            </span>
          </div>
        </div>
      </div>

      {/* Score Display */}
      <div className="flex items-center justify-center gap-6 p-3 bg-black/40">
        <div className="text-center">
          <p className="text-xs text-neutral-500">Current</p>
          <p className="text-xl font-bold text-white">{currentScore.toFixed(1)}</p>
        </div>
        <motion.div
          className="text-2xl text-cyan-400"
          animate={{ x: [0, 5, 0] }}
          transition={{ duration: 1, repeat: Infinity }}
        >
          →
        </motion.div>
        <div className="text-center">
          <p className="text-xs text-neutral-500">Potential</p>
          <p className="text-xl font-bold text-green-400">{potentialScore.toFixed(1)}</p>
        </div>
        <div className="text-center ml-4 pl-4 border-l border-white/10">
          <p className="text-xs text-neutral-500">Improvement</p>
          <p className="text-xl font-bold text-cyan-400">+{improvement.toFixed(1)}</p>
        </div>
      </div>

      {/* Canvas Container */}
      <div className="relative aspect-[3/4] bg-black">
        {/* Loading skeleton */}
        <AnimatePresence>
          {!imageLoaded && (
            <motion.div
              className="absolute inset-0 bg-neutral-900 animate-pulse flex items-center justify-center"
              initial={{ opacity: 1 }}
              exit={{ opacity: 0 }}
            >
              <div className="w-8 h-8 border-2 border-neutral-600 border-t-cyan-400 rounded-full animate-spin" />
            </motion.div>
          )}
        </AnimatePresence>

        {/* Morphing Canvas */}
        <canvas
          ref={canvasRef}
          className="absolute inset-0 w-full h-full object-contain"
        />

        {/* Progress indicator */}
        {viewMode === 'morphing' && (
          <div className="absolute bottom-4 left-4 right-4">
            <div className="h-1 bg-white/20 rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-gradient-to-r from-cyan-400 to-green-400"
                style={{ width: `${morphProgress * 100}%` }}
              />
            </div>
          </div>
        )}
      </div>

      {/* Controls */}
      <div className="p-4 border-t border-white/10 bg-black/40">
        <div className="flex items-center justify-center gap-3">
          <button
            onClick={resetMorph}
            className="p-2 rounded-lg bg-neutral-800 hover:bg-neutral-700 text-neutral-400 hover:text-white transition-colors"
            title="Reset"
          >
            <RotateCcw size={18} />
          </button>

          <button
            onClick={() => {
              if (viewMode === 'before') {
                startAnimation();
              } else if (viewMode === 'after') {
                resetMorph();
              }
            }}
            className="flex items-center gap-2 px-6 py-2 rounded-lg bg-gradient-to-r from-cyan-500 to-green-500 hover:from-cyan-400 hover:to-green-400 text-white font-medium transition-all"
            disabled={isAnimating}
          >
            {viewMode === 'before' ? (
              <>
                <Play size={18} />
                <span>Start Morphing</span>
              </>
            ) : viewMode === 'after' ? (
              <>
                <RotateCcw size={18} />
                <span>Watch Again</span>
              </>
            ) : (
              <>
                <Pause size={18} />
                <span>Morphing...</span>
              </>
            )}
          </button>

          <button
            onClick={skipToEnd}
            className="p-2 rounded-lg bg-neutral-800 hover:bg-neutral-700 text-neutral-400 hover:text-white transition-colors"
            title="Skip to end"
          >
            <ChevronRight size={18} />
          </button>
        </div>

        {/* Improvements summary */}
        {recommendations.length > 0 && (
          <div className="mt-4 pt-4 border-t border-white/10">
            <p className="text-xs text-neutral-500 mb-2">
              Improvements applied ({recommendations.length})
            </p>
            <div className="flex flex-wrap gap-2">
              {recommendations.slice(0, 5).map((rec, i) => (
                <span
                  key={i}
                  className="text-xs px-2 py-1 rounded-full bg-green-500/20 text-green-400"
                >
                  {rec.name}
                </span>
              ))}
              {recommendations.length > 5 && (
                <span className="text-xs px-2 py-1 rounded-full bg-neutral-800 text-neutral-400">
                  +{recommendations.length - 5} more
                </span>
              )}
            </div>
          </div>
        )}

        {/* Disclaimer */}
        <p className="text-[10px] text-neutral-600 mt-4 text-center">
          This is a simulated visualization. Actual treatment results may vary.
          Consult a professional before any procedure.
        </p>
      </div>
    </div>
  );
}

export default FaceMorphing;
