'use client';

import { motion } from 'framer-motion';
import { QualityTier, SeverityLevel } from '@/lib/harmony-scoring';
import { RecommendationPhase, getScoreColor, getQualityColor, getSeverityColor } from '@/types/results';

// Re-export new components
export { AnimatedScore } from './AnimatedScore';
export { ShareButton } from './ShareButton';
export { ExportButton } from './ExportButton';
export { RankBadge } from './RankBadge';

// ============================================
// QUALITY BADGE
// ============================================

interface QualityBadgeProps {
  quality: QualityTier;
  size?: 'sm' | 'md' | 'lg';
}

export function QualityBadge({ quality, size = 'md' }: QualityBadgeProps) {
  const color = getQualityColor(quality);
  const sizeClasses = {
    sm: 'px-1.5 py-0.5 text-[10px]',
    md: 'px-2 py-1 text-xs',
    lg: 'px-3 py-1.5 text-sm',
  };

  const labels: Record<QualityTier, string> = {
    ideal: 'Ideal',
    excellent: 'Excellent',
    good: 'Good',
    below_average: 'Below Avg',
  };

  return (
    <span
      className={`inline-flex items-center font-medium rounded-full border ${sizeClasses[size]}`}
      style={{
        color,
        backgroundColor: `${color}15`,
        borderColor: `${color}30`,
      }}
    >
      {labels[quality]}
    </span>
  );
}

// ============================================
// SEVERITY BADGE
// ============================================

interface SeverityBadgeProps {
  severity: SeverityLevel;
  size?: 'sm' | 'md' | 'lg';
}

export function SeverityBadge({ severity, size = 'md' }: SeverityBadgeProps) {
  const color = getSeverityColor(severity);
  const sizeClasses = {
    sm: 'px-1.5 py-0.5 text-[10px]',
    md: 'px-2 py-1 text-xs',
    lg: 'px-3 py-1.5 text-sm',
  };

  const labels: Record<SeverityLevel, string> = {
    optimal: 'Optimal',
    minor: 'Minor',
    moderate: 'Moderate',
    major: 'Major',
    severe: 'Severe',
    extremely_severe: 'Critical',
  };

  return (
    <span
      className={`inline-flex items-center font-medium rounded-full border ${sizeClasses[size]}`}
      style={{
        color,
        backgroundColor: `${color}15`,
        borderColor: `${color}30`,
      }}
    >
      {labels[severity]}
    </span>
  );
}

// ============================================
// PHASE BADGE
// ============================================

interface PhaseBadgeProps {
  phase: RecommendationPhase;
  size?: 'sm' | 'md' | 'lg';
}

export function PhaseBadge({ phase, size = 'md' }: PhaseBadgeProps) {
  const configs: Record<RecommendationPhase, { color: string; bg: string; border: string }> = {
    'Surgical': { color: '#ef4444', bg: '#ef444420', border: '#ef444430' },
    'Minimally Invasive': { color: '#fbbf24', bg: '#fbbf2420', border: '#fbbf2430' },
    'Foundational': { color: '#22c55e', bg: '#22c55e20', border: '#22c55e30' },
  };

  const config = configs[phase];
  const sizeClasses = {
    sm: 'px-1.5 py-0.5 text-[10px]',
    md: 'px-2 py-1 text-xs',
    lg: 'px-3 py-1.5 text-sm',
  };

  return (
    <span
      className={`inline-flex items-center font-medium rounded-full border ${sizeClasses[size]}`}
      style={{
        color: config.color,
        backgroundColor: config.bg,
        borderColor: config.border,
      }}
    >
      {phase}
    </span>
  );
}

// ============================================
// SCORE CIRCLE
// ============================================

interface ScoreCircleProps {
  score: number | string;
  maxScore?: number;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  showLabel?: boolean;
  animate?: boolean;
}

export function ScoreCircle({
  score,
  maxScore = 10,
  size = 'md',
  showLabel = true,
  animate = true,
}: ScoreCircleProps) {
  const numericScore = typeof score === 'number' ? score : 0;
  const color = getScoreColor(numericScore);
  const percentage = (numericScore / maxScore) * 100;

  const sizeConfigs = {
    sm: { size: 48, stroke: 4, fontSize: 'text-sm' },
    md: { size: 64, stroke: 5, fontSize: 'text-lg' },
    lg: { size: 96, stroke: 6, fontSize: 'text-2xl' },
    xl: { size: 140, stroke: 8, fontSize: 'text-4xl' },
  };

  const config = sizeConfigs[size];
  const radius = (config.size - config.stroke) / 2;
  const circumference = radius * 2 * Math.PI;
  const offset = circumference - (percentage / 100) * circumference;

  return (
    <div className="relative inline-flex items-center justify-center">
      <svg
        width={config.size}
        height={config.size}
        className="transform -rotate-90"
      >
        {/* Background circle */}
        <circle
          cx={config.size / 2}
          cy={config.size / 2}
          r={radius}
          fill="none"
          stroke="currentColor"
          strokeWidth={config.stroke}
          className="text-neutral-800"
        />
        {/* Progress circle */}
        <motion.circle
          cx={config.size / 2}
          cy={config.size / 2}
          r={radius}
          fill="none"
          stroke={color}
          strokeWidth={config.stroke}
          strokeLinecap="round"
          strokeDasharray={circumference}
          initial={animate ? { strokeDashoffset: circumference } : { strokeDashoffset: offset }}
          animate={{ strokeDashoffset: offset }}
          transition={{ duration: 1, ease: 'easeOut' }}
        />
      </svg>
      {showLabel && (
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <motion.span
            className={`font-bold ${config.fontSize}`}
            style={{ color }}
            initial={animate ? { opacity: 0, scale: 0.5 } : { opacity: 1, scale: 1 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5, delay: 0.5 }}
          >
            {typeof score === 'number' ? score.toFixed(1) : score}
          </motion.span>
          {size !== 'sm' && (
            <span className="text-xs text-neutral-500">/ {maxScore}</span>
          )}
        </div>
      )}
    </div>
  );
}

// ============================================
// SCORE BAR
// ============================================

interface ScoreBarProps {
  score: number;
  maxScore?: number;
  height?: number;
  showValue?: boolean;
  animate?: boolean;
}

export function ScoreBar({
  score,
  maxScore = 10,
  height = 8,
  showValue = false,
  animate = true,
}: ScoreBarProps) {
  const color = getScoreColor(score);
  const percentage = (score / maxScore) * 100;

  return (
    <div className="w-full">
      <div
        className="w-full bg-neutral-800 rounded-full overflow-hidden"
        style={{ height }}
      >
        <motion.div
          className="h-full rounded-full"
          style={{ backgroundColor: color }}
          initial={animate ? { width: 0 } : { width: `${percentage}%` }}
          animate={{ width: `${percentage}%` }}
          transition={{ duration: 0.8, ease: 'easeOut' }}
        />
      </div>
      {showValue && (
        <div className="flex justify-between mt-1">
          <span className="text-xs text-neutral-500">0</span>
          <span className="text-xs font-medium" style={{ color }}>
            {score.toFixed(2)}
          </span>
          <span className="text-xs text-neutral-500">{maxScore}</span>
        </div>
      )}
    </div>
  );
}

// ============================================
// EXPANDABLE SECTION
// ============================================

interface ExpandableSectionProps {
  isExpanded: boolean;
  children: React.ReactNode;
}

export function ExpandableSection({ isExpanded, children }: ExpandableSectionProps) {
  return (
    <motion.div
      initial={false}
      animate={{
        height: isExpanded ? 'auto' : 0,
        opacity: isExpanded ? 1 : 0,
      }}
      transition={{ duration: 0.3, ease: 'easeInOut' }}
      className="overflow-hidden"
    >
      {children}
    </motion.div>
  );
}

// ============================================
// CATEGORY TAG
// ============================================

interface CategoryTagProps {
  category: string;
  color?: string;
  size?: 'sm' | 'md';
}

export function CategoryTag({ category, color, size = 'sm' }: CategoryTagProps) {
  const categoryColors: Record<string, string> = {
    'Midface/Face Shape': '#67e8f9',
    'Occlusion/Jaw Growth': '#a78bfa',
    'Jaw Shape': '#f97316',
    'Upper Third': '#84cc16',
    'Eyes': '#06b6d4',
    'Nose': '#fbbf24',
    'Lips': '#ec4899',
    'Chin': '#ef4444',
    'Neck': '#14b8a6',
  };

  const tagColor = color || categoryColors[category] || '#6b7280';
  const sizeClasses = size === 'sm' ? 'px-1.5 py-0.5 text-[10px]' : 'px-2 py-1 text-xs';

  return (
    <span
      className={`inline-flex items-center font-medium rounded ${sizeClasses}`}
      style={{
        color: tagColor,
        backgroundColor: `${tagColor}15`,
      }}
    >
      {category}
    </span>
  );
}

// ============================================
// METRIC VALUE DISPLAY
// ============================================

interface MetricValueProps {
  value: number;
  unit: 'x' | 'mm' | '%' | '°';
  size?: 'sm' | 'md' | 'lg';
}

export function MetricValue({ value, unit, size = 'md' }: MetricValueProps) {
  const sizeClasses = {
    sm: 'text-sm',
    md: 'text-lg',
    lg: 'text-2xl',
  };

  const formatValue = () => {
    if (unit === '%') return value.toFixed(1);
    if (unit === '°') return value.toFixed(1);
    return value.toFixed(2);
  };

  const unitSymbol = unit === 'x' ? '' : unit;

  return (
    <span className={`font-semibold text-white ${sizeClasses[size]}`}>
      {formatValue()}
      <span className="text-neutral-400 ml-0.5">{unitSymbol}</span>
    </span>
  );
}
