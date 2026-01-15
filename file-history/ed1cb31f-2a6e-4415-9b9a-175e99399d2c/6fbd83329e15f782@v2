'use client';

import { useMemo, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Image from 'next/image';
import {
  ArrowRight,
  Sparkles,
  Eye,
  EyeOff,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';
import { Recommendation } from '@/types/results';

interface BeforeAfterPreviewProps {
  photo: string;
  currentScore: number;
  potentialScore: number;
  recommendations: Recommendation[];
  className?: string;
}

interface ImprovementIndicator {
  id: string;
  name: string;
  region: 'jaw' | 'nose' | 'eyes' | 'chin' | 'lips' | 'cheeks' | 'forehead' | 'other';
  impact: number;
  x: number; // percentage position
  y: number;
}

// Map treatment areas to face regions with approximate positions
function getImprovementIndicators(
  recommendations: Recommendation[]
): ImprovementIndicator[] {
  const indicators: ImprovementIndicator[] = [];
  const regionPositions: Record<string, { x: number; y: number }> = {
    jaw: { x: 75, y: 72 },
    chin: { x: 50, y: 85 },
    nose: { x: 50, y: 50 },
    eyes: { x: 35, y: 35 },
    lips: { x: 50, y: 68 },
    cheeks: { x: 25, y: 55 },
    forehead: { x: 50, y: 18 },
    other: { x: 50, y: 50 },
  };

  // Deduplicate by region and aggregate impact
  const regionImpacts = new Map<string, { name: string; impact: number }>();

  recommendations.slice(0, 6).forEach((rec) => {
    // Determine region from treatment name
    const name = rec.ref_id.toLowerCase();
    let region: ImprovementIndicator['region'] = 'other';

    if (name.includes('jaw') || name.includes('gonial') || name.includes('mandib')) {
      region = 'jaw';
    } else if (name.includes('nose') || name.includes('rhino') || name.includes('nasal')) {
      region = 'nose';
    } else if (name.includes('eye') || name.includes('cantho') || name.includes('blephar')) {
      region = 'eyes';
    } else if (name.includes('chin') || name.includes('genio') || name.includes('menton')) {
      region = 'chin';
    } else if (name.includes('lip') || name.includes('philtrum')) {
      region = 'lips';
    } else if (name.includes('cheek') || name.includes('zygo') || name.includes('malar')) {
      region = 'cheeks';
    } else if (name.includes('forehead') || name.includes('brow')) {
      region = 'forehead';
    }

    const existing = regionImpacts.get(region);
    if (existing) {
      existing.impact += rec.impact;
    } else {
      regionImpacts.set(region, {
        name: rec.name,
        impact: rec.impact,
      });
    }
  });

  regionImpacts.forEach((data, region) => {
    const pos = regionPositions[region];
    indicators.push({
      id: region,
      name: data.name,
      region: region as ImprovementIndicator['region'],
      impact: data.impact,
      x: pos.x,
      y: pos.y,
    });
  });

  return indicators;
}

export function BeforeAfterPreview({
  photo,
  currentScore,
  potentialScore,
  recommendations,
  className = '',
}: BeforeAfterPreviewProps) {
  const [showOverlays, setShowOverlays] = useState(true);
  const [selectedIndicator, setSelectedIndicator] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'before' | 'after'>('after');

  const improvement = potentialScore - currentScore;
  const indicators = useMemo(
    () => getImprovementIndicators(recommendations),
    [recommendations]
  );

  return (
    <div className={`bg-neutral-900 border border-neutral-800 rounded-2xl overflow-hidden ${className}`}>
      {/* Header */}
      <div className="p-4 border-b border-neutral-800">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sparkles size={18} className="text-cyan-400" />
            <h3 className="font-semibold text-white">Improvement Preview</h3>
          </div>
          <button
            onClick={() => setShowOverlays(!showOverlays)}
            className={`p-2 rounded-lg transition-colors ${
              showOverlays
                ? 'bg-cyan-500/20 text-cyan-400'
                : 'bg-neutral-800 text-neutral-500'
            }`}
            title={showOverlays ? 'Hide improvement areas' : 'Show improvement areas'}
          >
            {showOverlays ? <Eye size={16} /> : <EyeOff size={16} />}
          </button>
        </div>
      </div>

      {/* View Toggle */}
      <div className="flex items-center justify-center gap-4 p-3 bg-neutral-950">
        <button
          onClick={() => setViewMode('before')}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${
            viewMode === 'before'
              ? 'bg-neutral-700 text-white'
              : 'text-neutral-500 hover:text-white'
          }`}
        >
          <ChevronLeft size={16} />
          <span className="text-sm font-medium">Current</span>
        </button>
        <div className="flex items-center gap-2 text-neutral-600">
          <span className="text-lg font-bold" style={{ color: getScoreColor(currentScore) }}>
            {currentScore.toFixed(1)}
          </span>
          <ArrowRight size={16} />
          <span className="text-lg font-bold text-green-400">
            {potentialScore.toFixed(1)}
          </span>
        </div>
        <button
          onClick={() => setViewMode('after')}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${
            viewMode === 'after'
              ? 'bg-cyan-500/20 text-cyan-400'
              : 'text-neutral-500 hover:text-white'
          }`}
        >
          <span className="text-sm font-medium">Potential</span>
          <ChevronRight size={16} />
        </button>
      </div>

      {/* Image Container */}
      <div className="relative aspect-[3/4] bg-neutral-950">
        <Image
          src={photo}
          alt="Face preview"
          fill
          className="object-contain"
          unoptimized
        />

        {/* Improvement Overlay */}
        <AnimatePresence>
          {showOverlays && viewMode === 'after' && (
            <motion.div
              className="absolute inset-0"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
            >
              {/* Subtle glow effect on improved areas */}
              <svg className="absolute inset-0 w-full h-full pointer-events-none">
                <defs>
                  <filter id="improvement-glow" x="-50%" y="-50%" width="200%" height="200%">
                    <feGaussianBlur stdDeviation="8" result="blur" />
                    <feMerge>
                      <feMergeNode in="blur" />
                      <feMergeNode in="SourceGraphic" />
                    </feMerge>
                  </filter>
                  <radialGradient id="improvement-gradient" cx="50%" cy="50%" r="50%">
                    <stop offset="0%" stopColor="rgb(34, 197, 94)" stopOpacity="0.3" />
                    <stop offset="100%" stopColor="rgb(34, 197, 94)" stopOpacity="0" />
                  </radialGradient>
                </defs>

                {indicators.map((indicator) => (
                  <motion.circle
                    key={indicator.id}
                    cx={`${indicator.x}%`}
                    cy={`${indicator.y}%`}
                    r={Math.min(15 + indicator.impact * 3, 30)}
                    fill="url(#improvement-gradient)"
                    initial={{ scale: 0, opacity: 0 }}
                    animate={{
                      scale: [1, 1.2, 1],
                      opacity: selectedIndicator === indicator.id ? 0.8 : 0.5,
                    }}
                    transition={{
                      scale: { duration: 2, repeat: Infinity, ease: 'easeInOut' },
                      opacity: { duration: 0.3 },
                    }}
                  />
                ))}
              </svg>

              {/* Indicator Points */}
              {indicators.map((indicator, index) => (
                <motion.div
                  key={indicator.id}
                  className="absolute"
                  style={{
                    left: `${indicator.x}%`,
                    top: `${indicator.y}%`,
                    transform: 'translate(-50%, -50%)',
                  }}
                  initial={{ scale: 0, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ delay: index * 0.1 }}
                >
                  <button
                    onClick={() =>
                      setSelectedIndicator(
                        selectedIndicator === indicator.id ? null : indicator.id
                      )
                    }
                    className={`group relative w-8 h-8 rounded-full flex items-center justify-center transition-all ${
                      selectedIndicator === indicator.id
                        ? 'bg-green-500 scale-125'
                        : 'bg-green-500/50 hover:bg-green-500/80'
                    }`}
                  >
                    <span className="text-xs font-bold text-white">
                      +{indicator.impact.toFixed(1)}
                    </span>

                    {/* Ripple effect */}
                    <motion.div
                      className="absolute inset-0 rounded-full border-2 border-green-400"
                      animate={{ scale: [1, 1.5, 1], opacity: [0.5, 0, 0.5] }}
                      transition={{ duration: 2, repeat: Infinity }}
                    />
                  </button>

                  {/* Tooltip */}
                  <AnimatePresence>
                    {selectedIndicator === indicator.id && (
                      <motion.div
                        className="absolute left-1/2 -translate-x-1/2 bottom-full mb-2 z-10"
                        initial={{ opacity: 0, y: 5 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: 5 }}
                      >
                        <div className="bg-neutral-800 border border-neutral-700 rounded-lg p-2 shadow-xl min-w-[140px]">
                          <p className="text-xs font-medium text-white truncate">
                            {indicator.name}
                          </p>
                          <p className="text-xs text-green-400">
                            +{indicator.impact.toFixed(2)} points
                          </p>
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>
              ))}
            </motion.div>
          )}
        </AnimatePresence>

        {/* Before Mode - Neutral overlay */}
        <AnimatePresence>
          {viewMode === 'before' && (
            <motion.div
              className="absolute inset-0 bg-black/20"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
            />
          )}
        </AnimatePresence>
      </div>

      {/* Footer Stats */}
      <div className="p-4 border-t border-neutral-800 bg-neutral-950/50">
        <div className="grid grid-cols-3 gap-4 text-center">
          <div>
            <p className="text-xs text-neutral-500 mb-1">Current Score</p>
            <p className="text-lg font-bold" style={{ color: getScoreColor(currentScore) }}>
              {currentScore.toFixed(1)}
            </p>
          </div>
          <div>
            <p className="text-xs text-neutral-500 mb-1">Improvement</p>
            <p className="text-lg font-bold text-green-400">+{improvement.toFixed(1)}</p>
          </div>
          <div>
            <p className="text-xs text-neutral-500 mb-1">Potential</p>
            <p className="text-lg font-bold text-cyan-400">{potentialScore.toFixed(1)}</p>
          </div>
        </div>

        {/* Active improvements summary */}
        {indicators.length > 0 && (
          <div className="mt-4 pt-4 border-t border-neutral-800">
            <p className="text-xs text-neutral-500 mb-2">
              {indicators.length} improvement area{indicators.length > 1 ? 's' : ''} identified
            </p>
            <div className="flex flex-wrap gap-2">
              {indicators.map((ind) => (
                <span
                  key={ind.id}
                  className={`text-xs px-2 py-1 rounded-full transition-colors cursor-pointer ${
                    selectedIndicator === ind.id
                      ? 'bg-green-500/30 text-green-400'
                      : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
                  }`}
                  onClick={() =>
                    setSelectedIndicator(selectedIndicator === ind.id ? null : ind.id)
                  }
                >
                  {ind.region.charAt(0).toUpperCase() + ind.region.slice(1)}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Disclaimer */}
        <p className="text-[10px] text-neutral-600 mt-4 text-center">
          This visualization represents potential improvements based on recommended treatments.
          Actual results may vary.
        </p>
      </div>
    </div>
  );
}

// Score color helper
function getScoreColor(score: number): string {
  if (score >= 8.5) return '#22c55e';
  if (score >= 7) return '#84cc16';
  if (score >= 5.5) return '#fbbf24';
  if (score >= 4) return '#f97316';
  return '#ef4444';
}
