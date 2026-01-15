'use client';

import { motion } from 'framer-motion';
import {
  ChevronDown,
  Clock,
  DollarSign,
  AlertCircle,
  TrendingUp,
  Zap,
  Target,
} from 'lucide-react';
import { Recommendation } from '@/types/results';
import { PhaseBadge, ExpandableSection } from '../shared';

interface RecommendationCardProps {
  recommendation: Recommendation;
  isExpanded?: boolean;
  onToggle?: () => void;
  rank?: number;
}

export function RecommendationCard({
  recommendation,
  isExpanded = false,
  onToggle,
  rank,
}: RecommendationCardProps) {
  const impactPercent = recommendation.impact * 100;
  const impactColor = recommendation.impact >= 0.7 ? '#22c55e' :
    recommendation.impact >= 0.4 ? '#fbbf24' : '#6b7280';

  return (
    <motion.div
      layout
      className={`bg-neutral-900/80 border rounded-xl overflow-hidden transition-all ${
        isExpanded ? 'border-cyan-500/50' : 'border-neutral-800 hover:border-neutral-700'
      }`}
    >
      {/* Header */}
      <button
        onClick={onToggle}
        className="w-full p-4 flex items-start gap-4 text-left"
      >
        {/* Rank / Impact indicator */}
        <div className="flex flex-col items-center gap-1 flex-shrink-0">
          {rank !== undefined && (
            <span className="text-xs text-neutral-500">#{rank}</span>
          )}
          <div
            className="w-12 h-12 rounded-lg flex items-center justify-center font-bold"
            style={{
              backgroundColor: `${impactColor}15`,
              color: impactColor,
            }}
          >
            {(recommendation.impact * 10).toFixed(1)}
          </div>
        </div>

        {/* Main content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1 flex-wrap">
            <h3 className="font-semibold text-white">{recommendation.name}</h3>
            <PhaseBadge phase={recommendation.phase} size="sm" />
          </div>
          <p className="text-sm text-neutral-400 line-clamp-2 mb-2">
            {recommendation.description}
          </p>

          {/* Quick stats */}
          <div className="flex items-center gap-4 flex-wrap">
            <div className="flex items-center gap-1.5">
              <Target size={14} className="text-cyan-400" />
              <span className="text-xs text-neutral-300">
                {recommendation.coverage} metrics
              </span>
            </div>
            <div className="flex items-center gap-1.5">
              <TrendingUp size={14} className="text-green-400" />
              <span className="text-xs text-neutral-300">
                {recommendation.percentage} improvement
              </span>
            </div>
            <div className="flex items-center gap-1.5">
              <DollarSign size={14} className="text-yellow-400" />
              <span className="text-xs text-neutral-300">
                ${recommendation.cost.min.toLocaleString()} - ${recommendation.cost.max.toLocaleString()}
              </span>
            </div>
          </div>

          {/* Impact bar */}
          <div className="mt-3">
            <div className="flex items-center justify-between text-xs mb-1">
              <span className="text-neutral-500">Impact Score</span>
              <span style={{ color: impactColor }}>{impactPercent.toFixed(0)}%</span>
            </div>
            <div className="h-1.5 bg-neutral-800 rounded-full overflow-hidden">
              <motion.div
                className="h-full rounded-full"
                style={{ backgroundColor: impactColor }}
                initial={{ width: 0 }}
                animate={{ width: `${impactPercent}%` }}
                transition={{ duration: 0.5 }}
              />
            </div>
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
          {/* Matched flaws */}
          {recommendation.matchedFlaws.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-neutral-300 mb-2 flex items-center gap-2">
                <AlertCircle size={14} className="text-red-400" />
                Addresses These Issues
              </h4>
              <div className="flex flex-wrap gap-2">
                {recommendation.matchedFlaws.map((flaw, i) => (
                  <span
                    key={i}
                    className="px-2 py-1 bg-red-500/10 border border-red-500/20 rounded text-xs text-red-300"
                  >
                    {flaw}
                  </span>
                ))}
              </div>
            </div>
          )}

          {/* Matched ratios */}
          {recommendation.matchedRatios.length > 0 && (
            <div>
              <h4 className="text-sm font-medium text-neutral-300 mb-2 flex items-center gap-2">
                <Target size={14} className="text-cyan-400" />
                Improves These Metrics
              </h4>
              <div className="flex flex-wrap gap-2">
                {recommendation.matchedRatios.map((ratio, i) => (
                  <span
                    key={i}
                    className="px-2 py-1 bg-cyan-500/10 border border-cyan-500/20 rounded text-xs text-cyan-300"
                  >
                    {ratio}
                  </span>
                ))}
              </div>
            </div>
          )}

          {/* Timeline */}
          <div className="bg-neutral-800/50 rounded-lg p-3">
            <h4 className="text-sm font-medium text-neutral-300 mb-2 flex items-center gap-2">
              <Clock size={14} className="text-blue-400" />
              Timeline
            </h4>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <p className="text-xs text-neutral-500">Effect Starts</p>
                <p className="text-sm text-white capitalize">
                  {recommendation.timeline.effect_start}
                </p>
              </div>
              <div>
                <p className="text-xs text-neutral-500">Full Results</p>
                <p className="text-sm text-white">
                  {recommendation.timeline.full_results_weeks} weeks
                  {recommendation.timeline.full_results_weeks_max &&
                    ` - ${recommendation.timeline.full_results_weeks_max} weeks`}
                </p>
              </div>
            </div>
          </div>

          {/* Cost */}
          <div className="bg-neutral-800/50 rounded-lg p-3">
            <h4 className="text-sm font-medium text-neutral-300 mb-2 flex items-center gap-2">
              <DollarSign size={14} className="text-yellow-400" />
              Cost Estimate
            </h4>
            <p className="text-lg font-bold text-white">
              ${recommendation.cost.min.toLocaleString()} - ${recommendation.cost.max.toLocaleString()}
              <span className="text-sm font-normal text-neutral-500 ml-2">
                {recommendation.cost.currency}
              </span>
            </p>
            <p className="text-xs text-neutral-500 capitalize">
              {recommendation.cost.type.replace('_', ' ')}
            </p>
          </div>

          {/* Risks */}
          {recommendation.risks_side_effects && (
            <div className="bg-orange-500/10 border border-orange-500/20 rounded-lg p-3">
              <h4 className="text-sm font-medium text-orange-300 mb-2 flex items-center gap-2">
                <AlertCircle size={14} />
                Risks & Side Effects
              </h4>
              <p className="text-sm text-neutral-300">{recommendation.risks_side_effects}</p>
            </div>
          )}

          {/* Warnings */}
          {recommendation.warnings.length > 0 && (
            <div className="space-y-2">
              {recommendation.warnings.map((warning, i) => (
                <div
                  key={i}
                  className="flex items-start gap-2 p-2 bg-yellow-500/10 border border-yellow-500/20 rounded-lg"
                >
                  <AlertCircle size={14} className="text-yellow-400 mt-0.5 flex-shrink-0" />
                  <p className="text-xs text-yellow-200">{warning}</p>
                </div>
              ))}
            </div>
          )}

          {/* Action button */}
          <button className="w-full py-2.5 px-4 bg-gradient-to-r from-cyan-500 to-blue-600 text-white font-medium rounded-lg hover:from-cyan-400 hover:to-blue-500 transition-all flex items-center justify-center gap-2">
            <Zap size={16} />
            Add to My Plan
          </button>
        </div>
      </ExpandableSection>
    </motion.div>
  );
}

// ============================================
// COMPACT RECOMMENDATION CARD
// ============================================

interface CompactRecommendationCardProps {
  recommendation: Recommendation;
  onClick?: () => void;
}

export function CompactRecommendationCard({
  recommendation,
  onClick,
}: CompactRecommendationCardProps) {
  const impactColor = recommendation.impact >= 0.7 ? '#22c55e' :
    recommendation.impact >= 0.4 ? '#fbbf24' : '#6b7280';

  return (
    <button
      onClick={onClick}
      className="w-full p-3 bg-neutral-900/60 border border-neutral-800 rounded-lg hover:border-neutral-700 transition-all text-left flex items-center gap-3"
    >
      <div
        className="w-10 h-10 rounded-lg flex items-center justify-center font-bold flex-shrink-0"
        style={{
          backgroundColor: `${impactColor}15`,
          color: impactColor,
        }}
      >
        {(recommendation.impact * 10).toFixed(0)}
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <h4 className="font-medium text-white truncate text-sm">{recommendation.name}</h4>
          <PhaseBadge phase={recommendation.phase} size="sm" />
        </div>
        <p className="text-xs text-neutral-500 truncate">
          {recommendation.percentage} improvement potential
        </p>
      </div>
      <ChevronDown size={16} className="text-neutral-500 flex-shrink-0" />
    </button>
  );
}
