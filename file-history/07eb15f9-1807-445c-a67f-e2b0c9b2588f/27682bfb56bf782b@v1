'use client';

import { motion } from 'framer-motion';
import { ChevronDown, TrendingUp, TrendingDown } from 'lucide-react';
import { Ratio, getScoreColor, formatValue } from '@/types/results';
import { QualityBadge, SeverityBadge, ExpandableSection } from '../shared';
import { IdealRangeBar, CompactIdealRangeBar } from '../visualization/IdealRangeBar';
import { SeverityLevel } from '@/lib/harmony-scoring';

// Get severity indicator icon and color for header display
function getSeverityIndicator(severity: SeverityLevel): {
  icon: 'check' | 'alert' | 'warning';
  color: string;
  bgColor: string;
  showBadge: boolean;
} {
  switch (severity) {
    case 'optimal':
      return { icon: 'check', color: '#22d3ee', bgColor: 'rgba(34, 211, 238, 0.1)', showBadge: false };
    case 'minor':
      return { icon: 'check', color: '#22c55e', bgColor: 'rgba(34, 197, 94, 0.1)', showBadge: false };
    case 'moderate':
      return { icon: 'warning', color: '#fbbf24', bgColor: 'rgba(251, 191, 36, 0.1)', showBadge: true };
    case 'major':
      return { icon: 'warning', color: '#f97316', bgColor: 'rgba(249, 115, 22, 0.1)', showBadge: true };
    case 'severe':
      return { icon: 'alert', color: '#ef4444', bgColor: 'rgba(239, 68, 68, 0.1)', showBadge: true };
    case 'extremely_severe':
      return { icon: 'alert', color: '#dc2626', bgColor: 'rgba(220, 38, 38, 0.1)', showBadge: true };
    default:
      return { icon: 'check', color: '#6b7280', bgColor: 'rgba(107, 114, 128, 0.1)', showBadge: false };
  }
}

interface MeasurementCardProps {
  ratio: Ratio;
  isExpanded?: boolean;
  onToggle?: () => void;
}

export function MeasurementCard({
  ratio,
  isExpanded = false,
  onToggle,
}: MeasurementCardProps) {
  // Handle string values for obfuscated data
  const numericScore = typeof ratio.score === 'number' ? ratio.score : 0;
  const numericValue = typeof ratio.value === 'number' ? ratio.value : 0;

  const scoreColor = getScoreColor(numericScore);
  const severityIndicator = getSeverityIndicator(ratio.severity);

  return (
    <motion.div
      layout
      className={`rounded-2xl bg-neutral-900/30 border overflow-hidden transition-all ${
        isExpanded ? 'border-cyan-500/30' : 'border-white/5 hover:border-white/10'
      }`}
    >
      {/* Collapsed Header */}
      <button
        onClick={onToggle}
        className="w-full p-5 flex items-center gap-5 text-left"
      >
        {/* Score indicator with severity ring */}
        <div className="relative flex-shrink-0">
          <div
            className="w-14 h-14 rounded-xl flex items-center justify-center font-black text-xl italic"
            style={{
              backgroundColor: typeof ratio.score === 'string' ? 'rgba(38, 38, 38, 0.5)' : severityIndicator.bgColor,
              color: typeof ratio.score === 'string' ? '#a3a3a3' : scoreColor,
              border: `2px solid ${severityIndicator.showBadge ? `${severityIndicator.color}30` : 'rgba(255,255,255,0.05)'}`,
            }}
          >
            {typeof ratio.score === 'number' ? ratio.score.toFixed(1) : ratio.score}
          </div>
          {/* Severity indicator dot for non-optimal metrics */}
          {severityIndicator.showBadge && (
            <div
              className="absolute -top-1 -right-1 w-4 h-4 rounded-full border-2 border-black flex items-center justify-center"
              style={{ backgroundColor: severityIndicator.color }}
              title={`${ratio.severity.replace('_', ' ')} issue`}
            >
              {severityIndicator.icon === 'alert' && (
                <span className="text-white text-[8px] font-black">!</span>
              )}
            </div>
          )}
        </div>

        {/* Main info */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-2 flex-wrap">
            <h3 className="text-sm font-black uppercase tracking-wider text-white truncate">{ratio.name}</h3>
            <span
              className="px-2 py-0.5 rounded-md text-[9px] font-black uppercase tracking-widest"
              style={{
                color: '#84cc16',
                backgroundColor: 'rgba(132, 204, 22, 0.1)',
              }}
            >
              {ratio.category}
            </span>
            {/* Show compact severity badge for moderate and above */}
            {severityIndicator.showBadge && (
              <span
                className="px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-wider border"
                style={{
                  color: severityIndicator.color,
                  backgroundColor: severityIndicator.bgColor,
                  borderColor: `${severityIndicator.color}30`,
                }}
              >
                {ratio.severity.replace('_', ' ')}
              </span>
            )}
          </div>
          <div className="flex items-center gap-4">
            <span className="text-lg font-black italic text-white">
              {typeof ratio.value === 'number' ? formatValue(ratio.value, ratio.unit) : ratio.value}
            </span>
            <span className="text-[10px] font-medium text-neutral-600">
              Ideal: {formatValue(ratio.idealMin, ratio.unit)} - {formatValue(ratio.idealMax, ratio.unit)}
            </span>
          </div>
          {/* Compact range bar */}
          <div className="mt-3">
            <CompactIdealRangeBar
              value={numericValue}
              idealMin={ratio.idealMin}
              idealMax={ratio.idealMax}
              rangeMin={ratio.rangeMin}
              rangeMax={ratio.rangeMax}
              score={numericScore}
            />
          </div>
        </div>

        {/* Expand indicator */}
        <motion.div
          animate={{ rotate: isExpanded ? 180 : 0 }}
          transition={{ duration: 0.2 }}
          className="flex-shrink-0"
        >
          <ChevronDown size={20} className="text-neutral-600" />
        </motion.div>
      </button>

      {/* Expanded Content */}
      <ExpandableSection isExpanded={isExpanded}>
        <div className="px-5 pb-5 space-y-5 border-t border-white/5 pt-5">
          {/* Full range visualization */}
          <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-5">
            <IdealRangeBar
              value={numericValue}
              idealMin={ratio.idealMin}
              idealMax={ratio.idealMax}
              rangeMin={ratio.rangeMin}
              rangeMax={ratio.rangeMax}
              score={numericScore}
              unit={ratio.unit}
            />
          </div>

          {/* Quality and Severity badges */}
          <div className="flex items-center gap-3">
            <QualityBadge quality={ratio.qualityLevel} />
            <SeverityBadge severity={ratio.severity} />
          </div>

          {/* May indicate sections */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Strengths */}
            {ratio.mayIndicateStrengths.length > 0 && (
              <div className="rounded-xl bg-green-500/5 border border-green-500/20 p-4">
                <div className="flex items-center gap-2 mb-3">
                  <div className="w-6 h-6 rounded-lg bg-green-500/20 flex items-center justify-center">
                    <TrendingUp size={12} className="text-green-400" />
                  </div>
                  <span className="text-[10px] font-black uppercase tracking-widest text-green-400">Strengths</span>
                </div>
                <ul className="space-y-2">
                  {ratio.mayIndicateStrengths.map((strength, i) => (
                    <li key={i} className="text-sm text-neutral-300 pl-3 border-l-2 border-green-500/30">
                      {strength}
                    </li>
                  ))}
                </ul>
              </div>
            )}

            {/* Flaws */}
            {ratio.mayIndicateFlaws.length > 0 && (
              <div className="rounded-xl bg-red-500/5 border border-red-500/20 p-4">
                <div className="flex items-center gap-2 mb-3">
                  <div className="w-6 h-6 rounded-lg bg-red-500/20 flex items-center justify-center">
                    <TrendingDown size={12} className="text-red-400" />
                  </div>
                  <span className="text-[10px] font-black uppercase tracking-widest text-red-400">Areas to Improve</span>
                </div>
                <ul className="space-y-2">
                  {ratio.mayIndicateFlaws.map((flaw, i) => (
                    <li key={i} className="text-sm text-neutral-300 pl-3 border-l-2 border-red-500/30">
                      {flaw}
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>

        </div>
      </ExpandableSection>
    </motion.div>
  );
}

// ============================================
// COMPACT MEASUREMENT CARD (for lists)
// ============================================

interface CompactMeasurementCardProps {
  ratio: Ratio;
  onClick?: () => void;
  showSeverity?: boolean;
}

export function CompactMeasurementCard({ ratio, onClick, showSeverity = true }: CompactMeasurementCardProps) {
  // Handle string values for obfuscated data
  const numericScore = typeof ratio.score === 'number' ? ratio.score : 0;

  const scoreColor = getScoreColor(numericScore);
  const severityIndicator = getSeverityIndicator(ratio.severity);

  return (
    <button
      onClick={onClick}
      className="w-full p-4 rounded-xl bg-neutral-900/30 border border-white/5 hover:border-cyan-500/20 transition-all text-left flex items-center gap-4"
    >
      {/* Score with severity indicator */}
      <div className="relative flex-shrink-0">
        <div
          className="w-11 h-11 rounded-lg flex items-center justify-center font-black italic"
          style={{
            backgroundColor: typeof ratio.score === 'string' ? 'rgba(38, 38, 38, 0.5)' : severityIndicator.bgColor,
            color: typeof ratio.score === 'string' ? '#a3a3a3' : scoreColor,
            border: severityIndicator.showBadge ? `1.5px solid ${severityIndicator.color}30` : '1px solid rgba(255,255,255,0.05)',
          }}
        >
          {typeof ratio.score === 'number' ? ratio.score.toFixed(1) : ratio.score}
        </div>
        {/* Severity dot */}
        {showSeverity && severityIndicator.showBadge && (
          <div
            className="absolute -top-0.5 -right-0.5 w-3 h-3 rounded-full border-2 border-black"
            style={{ backgroundColor: severityIndicator.color }}
          />
        )}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <h4 className="font-black uppercase tracking-wider text-white truncate text-xs">{ratio.name}</h4>
          {/* Compact severity badge for severe/extremely severe */}
          {showSeverity && (ratio.severity === 'severe' || ratio.severity === 'extremely_severe') && (
            <span
              className="px-1.5 py-0.5 text-[8px] font-black uppercase tracking-wider rounded"
              style={{
                color: severityIndicator.color,
                backgroundColor: severityIndicator.bgColor,
              }}
            >
              {ratio.severity === 'extremely_severe' ? 'Critical' : 'Severe'}
            </span>
          )}
        </div>
        <p className="text-[10px] text-neutral-500 font-medium">
          {typeof ratio.value === 'number' ? formatValue(ratio.value, ratio.unit) : ratio.value}
        </p>
      </div>
      <ChevronDown size={16} className="text-neutral-600 flex-shrink-0" />
    </button>
  );
}
