'use client';

import { motion } from 'framer-motion';
import { ChevronDown, AlertTriangle, CheckCircle } from 'lucide-react';
import { Ratio, getScoreColor, formatValue } from '@/types/results';
import { QualityBadge, SeverityBadge, CategoryTag, ExpandableSection } from '../shared';
import { IdealRangeBar, CompactIdealRangeBar } from '../visualization/IdealRangeBar';
import { SeverityLevel } from '@/lib/faceiq-scoring';

// Get severity indicator icon and color for header display
function getSeverityIndicator(severity: SeverityLevel): {
  icon: 'check' | 'alert' | 'warning';
  color: string;
  showBadge: boolean;
} {
  switch (severity) {
    case 'optimal':
      return { icon: 'check', color: '#67e8f9', showBadge: false };
    case 'minor':
      return { icon: 'check', color: '#22c55e', showBadge: false };
    case 'moderate':
      return { icon: 'warning', color: '#fbbf24', showBadge: true };
    case 'major':
      return { icon: 'warning', color: '#f97316', showBadge: true };
    case 'severe':
      return { icon: 'alert', color: '#ef4444', showBadge: true };
    case 'extremely_severe':
      return { icon: 'alert', color: '#dc2626', showBadge: true };
    default:
      return { icon: 'check', color: '#6b7280', showBadge: false };
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
  const scoreColor = getScoreColor(ratio.score);
  const severityIndicator = getSeverityIndicator(ratio.severity);

  return (
    <motion.div
      layout
      className={`bg-neutral-900/80 border rounded-xl overflow-hidden transition-all ${
        isExpanded ? 'border-cyan-500/50' : 'border-neutral-800 hover:border-neutral-700'
      }`}
    >
      {/* Collapsed Header */}
      <button
        onClick={onToggle}
        className="w-full p-4 flex items-center gap-4 text-left"
      >
        {/* Score indicator with severity ring */}
        <div className="relative flex-shrink-0">
          <div
            className="w-12 h-12 rounded-lg flex items-center justify-center font-bold text-lg"
            style={{
              backgroundColor: `${scoreColor}15`,
              color: scoreColor,
              border: severityIndicator.showBadge ? `2px solid ${severityIndicator.color}40` : 'none',
            }}
          >
            {ratio.score.toFixed(1)}
          </div>
          {/* Severity indicator dot for non-optimal metrics */}
          {severityIndicator.showBadge && (
            <div
              className="absolute -top-1 -right-1 w-3 h-3 rounded-full border-2 border-neutral-900"
              style={{ backgroundColor: severityIndicator.color }}
              title={`${ratio.severity.replace('_', ' ')} issue`}
            />
          )}
        </div>

        {/* Main info */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1 flex-wrap">
            <h3 className="font-semibold text-white truncate">{ratio.name}</h3>
            <CategoryTag category={ratio.category} />
            {/* Show compact severity badge for moderate and above */}
            {severityIndicator.showBadge && (
              <SeverityBadge severity={ratio.severity} size="sm" />
            )}
          </div>
          <div className="flex items-center gap-3">
            <span className="text-lg font-medium text-white">
              {formatValue(ratio.value, ratio.unit)}
            </span>
            <span className="text-xs text-neutral-500">
              Ideal: {formatValue(ratio.idealMin, ratio.unit)} - {formatValue(ratio.idealMax, ratio.unit)}
            </span>
          </div>
          {/* Compact range bar */}
          <div className="mt-2">
            <CompactIdealRangeBar
              value={ratio.value}
              idealMin={ratio.idealMin}
              idealMax={ratio.idealMax}
              rangeMin={ratio.rangeMin}
              rangeMax={ratio.rangeMax}
              score={ratio.score}
            />
          </div>
        </div>

        {/* Expand indicator */}
        <motion.div
          animate={{ rotate: isExpanded ? 180 : 0 }}
          transition={{ duration: 0.2 }}
          className="flex-shrink-0"
        >
          <ChevronDown size={20} className="text-neutral-500" />
        </motion.div>
      </button>

      {/* Expanded Content */}
      <ExpandableSection isExpanded={isExpanded}>
        <div className="px-4 pb-4 space-y-4 border-t border-neutral-800 pt-4">
          {/* Full range visualization */}
          <div className="bg-neutral-800/50 rounded-lg p-4">
            <IdealRangeBar
              value={ratio.value}
              idealMin={ratio.idealMin}
              idealMax={ratio.idealMax}
              rangeMin={ratio.rangeMin}
              rangeMax={ratio.rangeMax}
              score={ratio.score}
              unit={ratio.unit}
            />
          </div>

          {/* Quality and Severity badges */}
          <div className="flex items-center gap-2">
            <QualityBadge quality={ratio.qualityLevel} />
            <SeverityBadge severity={ratio.severity} />
          </div>

          {/* May indicate sections */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {/* Strengths */}
            {ratio.mayIndicateStrengths.length > 0 && (
              <div className="bg-green-500/10 border border-green-500/20 rounded-lg p-3">
                <div className="flex items-center gap-2 mb-2">
                  <CheckCircle size={14} className="text-green-400" />
                  <span className="text-xs font-medium text-green-400">May Indicate Strengths</span>
                </div>
                <ul className="space-y-1">
                  {ratio.mayIndicateStrengths.map((strength, i) => (
                    <li key={i} className="text-sm text-neutral-300">
                      {strength}
                    </li>
                  ))}
                </ul>
              </div>
            )}

            {/* Flaws */}
            {ratio.mayIndicateFlaws.length > 0 && (
              <div className="bg-red-500/10 border border-red-500/20 rounded-lg p-3">
                <div className="flex items-center gap-2 mb-2">
                  <AlertTriangle size={14} className="text-red-400" />
                  <span className="text-xs font-medium text-red-400">May Indicate Flaws</span>
                </div>
                <ul className="space-y-1">
                  {ratio.mayIndicateFlaws.map((flaw, i) => (
                    <li key={i} className="text-sm text-neutral-300">
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
  const scoreColor = getScoreColor(ratio.score);
  const severityIndicator = getSeverityIndicator(ratio.severity);

  return (
    <button
      onClick={onClick}
      className="w-full p-3 bg-neutral-900/60 border border-neutral-800 rounded-lg hover:border-neutral-700 transition-all text-left flex items-center gap-3"
    >
      {/* Score with severity indicator */}
      <div className="relative flex-shrink-0">
        <div
          className="w-10 h-10 rounded-lg flex items-center justify-center font-bold"
          style={{
            backgroundColor: `${scoreColor}15`,
            color: scoreColor,
            border: severityIndicator.showBadge ? `1.5px solid ${severityIndicator.color}30` : 'none',
          }}
        >
          {ratio.score.toFixed(1)}
        </div>
        {/* Severity dot */}
        {showSeverity && severityIndicator.showBadge && (
          <div
            className="absolute -top-0.5 -right-0.5 w-2.5 h-2.5 rounded-full border border-neutral-900"
            style={{ backgroundColor: severityIndicator.color }}
          />
        )}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-1.5">
          <h4 className="font-medium text-white truncate text-sm">{ratio.name}</h4>
          {/* Compact severity badge for severe/extremely severe */}
          {showSeverity && (ratio.severity === 'severe' || ratio.severity === 'extremely_severe') && (
            <span
              className="px-1 py-0.5 text-[9px] font-medium rounded"
              style={{
                color: severityIndicator.color,
                backgroundColor: `${severityIndicator.color}20`,
              }}
            >
              {ratio.severity === 'extremely_severe' ? 'Critical' : 'Severe'}
            </span>
          )}
        </div>
        <p className="text-xs text-neutral-500">
          {formatValue(ratio.value, ratio.unit)}
        </p>
      </div>
      <ChevronDown size={16} className="text-neutral-500 flex-shrink-0" />
    </button>
  );
}
