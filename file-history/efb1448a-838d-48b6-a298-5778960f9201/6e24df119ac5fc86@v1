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
// QUALITY BADGE - Premium Style
// ============================================

interface QualityBadgeProps {
  quality: QualityTier;
  size?: 'sm' | 'md' | 'lg';
}

export function QualityBadge({ quality, size = 'md' }: QualityBadgeProps) {
  const color = getQualityColor(quality);
  const sizeClasses = {
    sm: 'px-2 py-0.5 text-[9px]',
    md: 'px-2.5 py-1 text-[10px]',
    lg: 'px-3 py-1.5 text-xs',
  };

  const labels: Record<QualityTier, string> = {
    ideal: 'IDEAL',
    excellent: 'EXCELLENT',
    good: 'GOOD',
    below_average: 'BELOW AVG',
  };

  return (
    <span
      className={`inline-flex items-center font-black uppercase tracking-wider rounded-lg ${sizeClasses[size]}`}
      style={{
        color,
        backgroundColor: `${color}12`,
        border: `1px solid ${color}20`,
      }}
    >
      {labels[quality]}
    </span>
  );
}

// ============================================
// SEVERITY BADGE - Premium Style
// ============================================

interface SeverityBadgeProps {
  severity: SeverityLevel;
  size?: 'sm' | 'md' | 'lg';
}

export function SeverityBadge({ severity, size = 'md' }: SeverityBadgeProps) {
  const color = getSeverityColor(severity);
  const sizeClasses = {
    sm: 'px-2 py-0.5 text-[9px]',
    md: 'px-2.5 py-1 text-[10px]',
    lg: 'px-3 py-1.5 text-xs',
  };

  const labels: Record<SeverityLevel, string> = {
    optimal: 'OPTIMAL',
    minor: 'MINOR',
    moderate: 'MODERATE',
    major: 'MAJOR',
    severe: 'SEVERE',
    extremely_severe: 'CRITICAL',
  };

  return (
    <span
      className={`inline-flex items-center font-black uppercase tracking-wider rounded-lg ${sizeClasses[size]}`}
      style={{
        color,
        backgroundColor: `${color}12`,
        border: `1px solid ${color}20`,
      }}
    >
      {labels[severity]}
    </span>
  );
}

// ============================================
// PHASE BADGE - Premium Style
// ============================================

interface PhaseBadgeProps {
  phase: RecommendationPhase;
  size?: 'sm' | 'md' | 'lg';
}

export function PhaseBadge({ phase, size = 'md' }: PhaseBadgeProps) {
  const configs: Record<RecommendationPhase, { color: string }> = {
    'Surgical': { color: '#ef4444' },
    'Minimally Invasive': { color: '#fbbf24' },
    'Foundational': { color: '#22c55e' },
  };

  const config = configs[phase];
  const sizeClasses = {
    sm: 'px-2 py-0.5 text-[9px]',
    md: 'px-2.5 py-1 text-[10px]',
    lg: 'px-3 py-1.5 text-xs',
  };

  const labels: Record<RecommendationPhase, string> = {
    'Surgical': 'SURGICAL',
    'Minimally Invasive': 'MINI-INVASIVE',
    'Foundational': 'FOUNDATIONAL',
  };

  return (
    <span
      className={`inline-flex items-center font-black uppercase tracking-wider rounded-lg ${sizeClasses[size]}`}
      style={{
        color: config.color,
        backgroundColor: `${config.color}12`,
        border: `1px solid ${config.color}20`,
      }}
    >
      {labels[phase]}
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
// RISK PERCENTAGE BADGE
// ============================================

interface RiskPercentageBadgeProps {
  percentage: number;
  size?: 'sm' | 'md' | 'lg';
  showBar?: boolean;
}

/**
 * Displays risk percentage with color coding
 * - 0-10%: Green (Minimal)
 * - 10-20%: Blue (Low)
 * - 20-35%: Yellow (Moderate)
 * - 35-50%: Orange (High)
 * - 50-60%: Red (Very High)
 */
export function RiskPercentageBadge({ percentage, size = 'md', showBar = false }: RiskPercentageBadgeProps) {
  const getRiskConfig = (pct: number) => {
    if (pct <= 10) return { color: '#22c55e', label: 'Minimal', bg: 'bg-green-500/10', border: 'border-green-500/20' };
    if (pct <= 20) return { color: '#3b82f6', label: 'Low', bg: 'bg-blue-500/10', border: 'border-blue-500/20' };
    if (pct <= 35) return { color: '#eab308', label: 'Moderate', bg: 'bg-yellow-500/10', border: 'border-yellow-500/20' };
    if (pct <= 50) return { color: '#f97316', label: 'High', bg: 'bg-orange-500/10', border: 'border-orange-500/20' };
    return { color: '#ef4444', label: 'Very High', bg: 'bg-red-500/10', border: 'border-red-500/20' };
  };

  const config = getRiskConfig(percentage);
  const sizeClasses = {
    sm: 'px-1.5 py-0.5 text-[9px] gap-1',
    md: 'px-2 py-0.5 text-[10px] gap-1.5',
    lg: 'px-2.5 py-1 text-xs gap-2',
  };

  return (
    <div className="flex items-center gap-2">
      <span
        className={`inline-flex items-center font-bold uppercase tracking-wider rounded-md ${sizeClasses[size]} ${config.bg} ${config.border} border`}
        style={{ color: config.color }}
      >
        <span>{percentage}%</span>
        <span className="opacity-70">Risk</span>
      </span>
      {showBar && (
        <div className="flex-1 max-w-24 h-1.5 bg-neutral-800 rounded-full overflow-hidden">
          <motion.div
            className="h-full rounded-full"
            style={{ backgroundColor: config.color }}
            initial={{ width: 0 }}
            animate={{ width: `${Math.min(percentage, 60) / 60 * 100}%` }}
            transition={{ duration: 0.5, ease: 'easeOut' }}
          />
        </div>
      )}
    </div>
  );
}

// ============================================
// CATEGORY TAG - Premium Style
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
  const sizeClasses = size === 'sm' ? 'px-2 py-0.5 text-[9px]' : 'px-2.5 py-1 text-[10px]';

  return (
    <span
      className={`inline-flex items-center font-bold uppercase tracking-wider rounded-md ${sizeClasses}`}
      style={{
        color: tagColor,
        backgroundColor: `${tagColor}10`,
        border: `1px solid ${tagColor}15`,
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
