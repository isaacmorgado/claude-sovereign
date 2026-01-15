'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { X, ChevronLeft, ChevronRight, AlertTriangle, Info } from 'lucide-react';
import { FaceIQScoreResult } from '@/lib/faceiq-scoring';
import { generateAIDescription, getSeverityFromScore } from '@/lib/aiDescriptions';
import { getScoreColor } from '@/types/results';
import { GradientRangeBar } from '../visualization/GradientRangeBar';
import { useMemo } from 'react';

// ============================================
// TYPES
// ============================================

interface MetricDetailModalProps {
  isOpen: boolean;
  onClose: () => void;
  ratio: FaceIQScoreResult | null;
  onPrevious?: () => void;
  onNext?: () => void;
  hasPrevious?: boolean;
  hasNext?: boolean;
  facePhoto?: string;
}

// ============================================
// STAT CARD
// ============================================

interface StatCardProps {
  label: string;
  value: string;
  subtext?: string;
  variant?: 'default' | 'ideal' | 'score';
  scoreColor?: string;
}

function StatCard({ label, value, subtext, variant = 'default', scoreColor }: StatCardProps) {
  const variants = {
    default: 'bg-neutral-800/80 border-neutral-700',
    ideal: 'bg-cyan-500/10 border-cyan-500/30',
    score: 'bg-blue-500/10 border-blue-500/30',
  };

  const labelColors = {
    default: 'text-neutral-500',
    ideal: 'text-cyan-400',
    score: 'text-neutral-500',
  };

  const valueColors = {
    default: 'text-white',
    ideal: 'text-cyan-400',
    score: scoreColor || 'text-white',
  };

  return (
    <div className={`rounded-xl border p-4 ${variants[variant]}`}>
      <div className={`text-[10px] font-medium uppercase tracking-wider mb-1 ${labelColors[variant]}`}>
        {label}
      </div>
      <div className={`text-xl font-semibold ${valueColors[variant]}`} style={variant === 'score' && scoreColor ? { color: scoreColor } : {}}>
        {value}
      </div>
      {subtext && (
        <div className="text-[10px] mt-1 text-neutral-500">{subtext}</div>
      )}
    </div>
  );
}

// ============================================
// MAIN MODAL COMPONENT
// ============================================

export function MetricDetailModal({
  isOpen,
  onClose,
  ratio,
  onPrevious,
  onNext,
  hasPrevious = false,
  hasNext = false,
  facePhoto,
}: MetricDetailModalProps) {
  // Generate AI description from ratio data
  const flawDetail = useMemo(() => {
    if (!ratio) return null;

    return generateAIDescription(
      ratio.metricId.toLowerCase().replace(/\\s+/g, ''),
      ratio.name,
      ratio.value,
      ratio.idealMin,
      ratio.idealMax,
      ratio.score,
      ratio.unit,
      ratio.category
    );
  }, [ratio]);

  if (!ratio || !flawDetail) return null;

  const scoreColor = getScoreColor(ratio.score);
  const isWithinIdeal = ratio.value >= ratio.idealMin && ratio.value <= ratio.idealMax;
  const severity = getSeverityFromScore(ratio.score);

  // Format values with units
  const formatUnit = (v: number) => {
    const formatted = v.toFixed(ratio.unit === 'percent' ? 1 : 2);
    const suffix = ratio.unit === 'percent' ? ' %' : ratio.unit === 'degrees' ? '°' : ratio.unit === 'ratio' ? ' x' : ratio.unit === 'mm' ? ' mm' : '';
    return `${formatted}${suffix}`;
  };

  // Calculate range for visualization
  const idealRange = ratio.idealMax - ratio.idealMin;
  const rangeMin = ratio.idealMin - idealRange * 1.5;
  const rangeMax = ratio.idealMax + idealRange * 1.5;

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50"
          />

          {/* Navigation Arrows - Desktop */}
          {hasPrevious && onPrevious && (
            <motion.button
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -10 }}
              onClick={onPrevious}
              className="hidden lg:flex fixed left-4 xl:left-8 top-1/2 -translate-y-1/2 z-[60] w-12 h-12 rounded-full bg-neutral-800 border border-neutral-600 shadow-xl hover:bg-neutral-700 hover:border-neutral-500 transition-all items-center justify-center group"
              aria-label="Previous measurement"
            >
              <ChevronLeft className="w-6 h-6 text-neutral-300 group-hover:text-white" />
            </motion.button>
          )}

          {hasNext && onNext && (
            <motion.button
              initial={{ opacity: 0, x: 10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 10 }}
              onClick={onNext}
              className="hidden lg:flex fixed right-4 xl:right-8 top-1/2 -translate-y-1/2 z-[60] w-12 h-12 rounded-full bg-neutral-800 border border-neutral-600 shadow-xl hover:bg-neutral-700 hover:border-neutral-500 transition-all items-center justify-center group"
              aria-label="Next measurement"
            >
              <ChevronRight className="w-6 h-6 text-neutral-300 group-hover:text-white" />
            </motion.button>
          )}

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            transition={{ type: 'spring', damping: 25, stiffness: 300 }}
            className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[95%] max-w-5xl max-h-[90vh] overflow-hidden bg-neutral-900 border border-neutral-700 rounded-2xl shadow-2xl z-50"
          >
            {/* Header */}
            <div className="sticky top-0 bg-neutral-900/95 backdrop-blur-sm border-b border-neutral-800 px-4 py-4 md:px-6 z-10">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3 flex-1 min-w-0">
                  {/* Mobile nav */}
                  {hasPrevious && onPrevious && (
                    <button
                      onClick={onPrevious}
                      className="lg:hidden flex-shrink-0 p-1.5 rounded-lg hover:bg-neutral-800 transition-colors text-neutral-400"
                      aria-label="Previous measurement"
                    >
                      <ChevronLeft className="w-5 h-5" />
                    </button>
                  )}

                  <h2 className="text-lg md:text-xl font-semibold text-white truncate">
                    {ratio.name}
                  </h2>

                  {hasNext && onNext && (
                    <button
                      onClick={onNext}
                      className="lg:hidden flex-shrink-0 p-1.5 rounded-lg hover:bg-neutral-800 transition-colors text-neutral-400"
                      aria-label="Next measurement"
                    >
                      <ChevronRight className="w-5 h-5" />
                    </button>
                  )}
                </div>

                <button
                  onClick={onClose}
                  className="flex-shrink-0 ml-4 p-2 rounded-lg hover:bg-neutral-800 transition-colors text-neutral-400 hover:text-white"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            </div>

            {/* Content */}
            <div className="p-4 md:p-6 space-y-4 overflow-y-auto max-h-[calc(90vh-72px)]">
              {/* Stats Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <StatCard
                  label="Your Value"
                  value={formatUnit(ratio.value)}
                  subtext={isWithinIdeal ? 'Within ideal' : 'Outside ideal'}
                  variant="default"
                />
                <StatCard
                  label="Ideal Range"
                  value={`${formatUnit(ratio.idealMin)} - ${formatUnit(ratio.idealMax)}`}
                  subtext="Target range"
                  variant="ideal"
                />
                <StatCard
                  label="Score"
                  value={`${ratio.score.toFixed(2)}/10`}
                  subtext="Normalized score (1-10)"
                  variant="score"
                  scoreColor={scoreColor}
                />
              </div>

              {/* Gradient Range Bar */}
              <GradientRangeBar
                value={ratio.value}
                idealMin={ratio.idealMin}
                idealMax={ratio.idealMax}
                rangeMin={rangeMin}
                rangeMax={rangeMax}
                unit={ratio.unit}
              />

              {/* Two Column Layout */}
              <div className="grid lg:grid-cols-2 gap-4">
                {/* Face Image (if available) */}
                {facePhoto && (
                  <div>
                    <div className="relative rounded-xl overflow-hidden border border-neutral-700 bg-neutral-800">
                      <div className="relative w-full" style={{ aspectRatio: '1/1' }}>
                        <img
                          src={facePhoto}
                          alt="Face"
                          className="w-full h-full object-contain"
                        />
                      </div>
                    </div>
                  </div>
                )}

                {/* Info Sections */}
                <div className={`space-y-4 ${!facePhoto ? 'lg:col-span-2' : ''}`}>
                  {/* May Indicate Flaws - Only show if score is below 7 */}
                  {ratio.score < 7 && (
                    <div className="rounded-xl bg-amber-500/10 border border-amber-500/30 p-4">
                      <div className="flex items-center gap-2 mb-3">
                        <AlertTriangle size={14} className="text-amber-400" />
                        <span className="text-[10px] font-medium text-amber-400 uppercase tracking-wider">
                          May Indicate Flaws
                        </span>
                      </div>
                      <div className="space-y-3">
                        <div className="pb-3 border-b border-amber-500/20 last:border-0 last:pb-0">
                          <div className="text-sm font-semibold text-white mb-1">
                            {flawDetail.flawName}
                          </div>
                          <div className="text-xs text-neutral-300 leading-relaxed">
                            {flawDetail.reasoning}
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* About This Ratio */}
                  <div className="rounded-xl bg-neutral-800/50 border border-neutral-700 p-4">
                    <div className="flex items-center gap-2 mb-3">
                      <Info size={14} className="text-neutral-400" />
                      <span className="text-[10px] font-medium text-neutral-400 uppercase tracking-wider">
                        About This Ratio
                      </span>
                    </div>
                    <div className="text-sm text-neutral-300 leading-relaxed">
                      {getAboutDescription(ratio.name, ratio.category)}
                    </div>
                  </div>

                  {/* Category Badge */}
                  <div className="flex items-center gap-2">
                    <span className="px-3 py-1.5 rounded-lg bg-neutral-800 border border-neutral-700 text-xs font-medium text-neutral-300">
                      {ratio.category}
                    </span>
                    <span
                      className="px-3 py-1.5 rounded-lg text-xs font-medium"
                      style={{
                        backgroundColor: `${scoreColor}20`,
                        color: scoreColor,
                        border: `1px solid ${scoreColor}40`,
                      }}
                    >
                      {severity.replace('_', ' ')}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

// ============================================
// ABOUT DESCRIPTIONS
// ============================================

function getAboutDescription(name: string, category: string): string {
  const descriptions: Record<string, string> = {
    'Face Width to Height Ratio': 'Facial Width-to-Height Ratio evaluates midface compactness by comparing its width to height, influenced by brow position, philtrum length, and lip fullness. Balanced proportions suit most faces; higher ratios (shorter midfaces) are preferred for males, while ethnic and structural variations in width affect overall harmony.',
    'Lower Third': 'Facial thirds assess the vertical height of facial thirds relative to total facial height, favoring a balanced proportion with a slightly taller Lower Third in males. Disproportionate thirds, such as an overly short or tall Lower Third, may indicate disharmony or occlusal issues.',
    'Middle Third': 'The middle third spans from the brow line to the base of the nose. A balanced middle third contributes to overall facial harmony and affects the perceived size of the nose and eyes.',
    'Upper Third': 'The upper third spans from the hairline to the brow line. Its proportion affects forehead prominence and hairline positioning.',
    'Lateral Canthal Tilt': 'Canthal tilt measures the angle of the eye from inner to outer corner. A positive tilt (outer corner higher) is generally considered more attractive and youthful.',
    'Gonial Angle': 'The gonial angle measures the angle at the jaw corner. A well-defined angle contributes to jaw prominence and facial structure.',
    'Bigonial Width': 'Bigonial width measures the distance between the jaw angles. It contributes to the perception of jaw strength and facial width.',
    'Eye Aspect Ratio': 'Eye aspect ratio compares eye height to width. Almond-shaped eyes with balanced proportions are often considered ideal.',
    'Nasal Index': 'The nasal index compares nose width to height. Balanced proportions contribute to facial harmony and ethnic variations are normal.',
    'Chin Philtrum Ratio': 'This ratio compares chin height to philtrum length. Proper balance contributes to lower face harmony.',
    'Submental Cervical Angle': 'This angle measures the definition between chin and neck. A well-defined angle creates a clean jawline profile.',
  };

  return descriptions[name] || `This measurement evaluates your ${category.toLowerCase()} proportions and contributes to overall facial harmony. Ideal ranges are based on established aesthetic standards.`;
}

export default MetricDetailModal;
