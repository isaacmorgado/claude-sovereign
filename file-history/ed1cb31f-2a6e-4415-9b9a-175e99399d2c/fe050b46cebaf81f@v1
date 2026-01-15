'use client';

import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Clock,
  ChevronDown,
  ChevronRight,
  Calendar,
  AlertCircle,
  CheckCircle2,
  Circle,
  Sparkles,
} from 'lucide-react';
import { Recommendation } from '@/types/results';

interface TreatmentTimelineProps {
  recommendations: Recommendation[];
  className?: string;
}

interface TimelinePhase {
  id: string;
  name: string;
  color: string;
  bgColor: string;
  borderColor: string;
  icon: 'foundation' | 'minimal' | 'surgical';
  order: number;
}

const PHASES: Record<string, TimelinePhase> = {
  Foundational: {
    id: 'foundational',
    name: 'Foundational',
    color: '#22c55e',
    bgColor: 'rgba(34, 197, 94, 0.1)',
    borderColor: 'rgba(34, 197, 94, 0.3)',
    icon: 'foundation',
    order: 1,
  },
  'Minimally Invasive': {
    id: 'minimal',
    name: 'Minimally Invasive',
    color: '#fbbf24',
    bgColor: 'rgba(251, 191, 36, 0.1)',
    borderColor: 'rgba(251, 191, 36, 0.3)',
    icon: 'minimal',
    order: 2,
  },
  Surgical: {
    id: 'surgical',
    name: 'Surgical',
    color: '#ef4444',
    bgColor: 'rgba(239, 68, 68, 0.1)',
    borderColor: 'rgba(239, 68, 68, 0.3)',
    icon: 'surgical',
    order: 3,
  },
};

interface GroupedRecommendations {
  phase: TimelinePhase;
  items: Recommendation[];
  totalWeeks: number;
}

function groupByPhase(recommendations: Recommendation[]): GroupedRecommendations[] {
  const groups = new Map<string, Recommendation[]>();

  recommendations.forEach((rec) => {
    const existing = groups.get(rec.phase) || [];
    existing.push(rec);
    groups.set(rec.phase, existing);
  });

  return Array.from(groups.entries())
    .map(([phaseName, items]) => {
      const phase = PHASES[phaseName];
      if (!phase) return null;

      // Calculate total timeline in weeks
      const totalWeeks = items.reduce((max, item) => {
        const weeks = item.timeline?.full_results_weeks || 4;
        return Math.max(max, weeks);
      }, 0);

      return { phase, items, totalWeeks };
    })
    .filter((g): g is GroupedRecommendations => g !== null)
    .sort((a, b) => a.phase.order - b.phase.order);
}

function PhaseIcon({ type, size = 16 }: { type: 'foundation' | 'minimal' | 'surgical'; size?: number }) {
  switch (type) {
    case 'foundation':
      return <Sparkles size={size} />;
    case 'minimal':
      return <Clock size={size} />;
    case 'surgical':
      return <AlertCircle size={size} />;
  }
}

function TimelineItem({
  recommendation,
  index,
  phaseColor,
  isLast,
}: {
  recommendation: Recommendation;
  index: number;
  phaseColor: string;
  isLast: boolean;
}) {
  const [isExpanded, setIsExpanded] = useState(false);

  const weeks = recommendation.timeline?.full_results_weeks || 4;
  const weeksMax = recommendation.timeline?.full_results_weeks_max;
  const timelineText = weeksMax ? `${weeks}-${weeksMax} weeks` : `${weeks} weeks`;

  const effectStart = recommendation.timeline?.effect_start || 'delayed';
  const effectLabel = effectStart === 'immediate' ? 'Immediate' : effectStart === 'gradual' ? 'Gradual' : 'Delayed';

  return (
    <motion.div
      className="relative pl-6"
      initial={{ opacity: 0, x: -10 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: index * 0.1 }}
    >
      {/* Connector line */}
      {!isLast && (
        <div
          className="absolute left-[9px] top-7 w-0.5 h-[calc(100%+8px)]"
          style={{ backgroundColor: `${phaseColor}30` }}
        />
      )}

      {/* Node */}
      <div
        className="absolute left-0 top-1.5 w-5 h-5 rounded-full border-2 flex items-center justify-center"
        style={{ borderColor: phaseColor, backgroundColor: 'rgb(23, 23, 23)' }}
      >
        <Circle size={8} fill={phaseColor} stroke="none" />
      </div>

      {/* Content */}
      <div
        className="bg-neutral-900/50 border border-neutral-800 rounded-lg p-3 hover:border-neutral-700 transition-colors cursor-pointer"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <div className="flex items-start justify-between gap-2">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <span className="text-sm font-medium text-white truncate">
                {recommendation.name}
              </span>
              <span
                className="text-xs px-1.5 py-0.5 rounded"
                style={{
                  color: phaseColor,
                  backgroundColor: `${phaseColor}15`,
                }}
              >
                +{recommendation.impact.toFixed(1)}
              </span>
            </div>
            <div className="flex items-center gap-3 mt-1">
              <span className="text-xs text-neutral-500 flex items-center gap-1">
                <Calendar size={12} />
                {timelineText}
              </span>
              <span className="text-xs text-neutral-600">
                {effectLabel}
              </span>
            </div>
          </div>
          <button className="p-1 hover:bg-neutral-800 rounded transition-colors">
            {isExpanded ? (
              <ChevronDown size={16} className="text-neutral-500" />
            ) : (
              <ChevronRight size={16} className="text-neutral-500" />
            )}
          </button>
        </div>

        <AnimatePresence>
          {isExpanded && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              className="overflow-hidden"
            >
              <div className="mt-3 pt-3 border-t border-neutral-800">
                <p className="text-xs text-neutral-400 mb-2">
                  {recommendation.description}
                </p>

                {/* Cost estimate */}
                {recommendation.cost && (
                  <div className="flex items-center gap-2 text-xs text-neutral-500 mb-2">
                    <span>Cost:</span>
                    <span className="text-white">
                      ${recommendation.cost.min.toLocaleString()} - ${recommendation.cost.max.toLocaleString()}
                    </span>
                    {recommendation.cost.type !== 'flat' && (
                      <span className="text-neutral-600">
                        ({recommendation.cost.type.replace('_', ' ')})
                      </span>
                    )}
                  </div>
                )}

                {/* Matched issues */}
                {recommendation.matchedFlaws && recommendation.matchedFlaws.length > 0 && (
                  <div className="flex flex-wrap gap-1 mt-2">
                    {recommendation.matchedFlaws.slice(0, 3).map((flaw, i) => (
                      <span
                        key={i}
                        className="text-[10px] px-1.5 py-0.5 bg-neutral-800 text-neutral-400 rounded"
                      >
                        {flaw}
                      </span>
                    ))}
                  </div>
                )}

                {/* Warnings */}
                {recommendation.warnings && recommendation.warnings.length > 0 && (
                  <div className="mt-2 flex items-start gap-1.5 text-xs text-yellow-500/80">
                    <AlertCircle size={12} className="flex-shrink-0 mt-0.5" />
                    <span>{recommendation.warnings[0]}</span>
                  </div>
                )}
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </motion.div>
  );
}

function PhaseGroup({ group, index }: { group: GroupedRecommendations; index: number }) {
  const [isCollapsed, setIsCollapsed] = useState(false);

  return (
    <motion.div
      className="relative"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.15 }}
    >
      {/* Phase Header */}
      <button
        onClick={() => setIsCollapsed(!isCollapsed)}
        className="w-full flex items-center justify-between p-3 rounded-lg border transition-all"
        style={{
          backgroundColor: group.phase.bgColor,
          borderColor: group.phase.borderColor,
        }}
      >
        <div className="flex items-center gap-3">
          <div
            className="w-8 h-8 rounded-full flex items-center justify-center"
            style={{ backgroundColor: `${group.phase.color}20` }}
          >
            <PhaseIcon type={group.phase.icon} size={16} />
          </div>
          <div className="text-left">
            <h4 className="font-medium text-white text-sm">
              Phase {group.phase.order}: {group.phase.name}
            </h4>
            <p className="text-xs text-neutral-500">
              {group.items.length} treatment{group.items.length > 1 ? 's' : ''} &bull; ~{group.totalWeeks} weeks total
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <span
            className="text-xs font-medium px-2 py-1 rounded"
            style={{ color: group.phase.color, backgroundColor: `${group.phase.color}15` }}
          >
            +{group.items.reduce((sum, r) => sum + r.impact, 0).toFixed(1)} pts
          </span>
          {isCollapsed ? (
            <ChevronRight size={18} className="text-neutral-500" />
          ) : (
            <ChevronDown size={18} className="text-neutral-500" />
          )}
        </div>
      </button>

      {/* Phase Items */}
      <AnimatePresence>
        {!isCollapsed && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="overflow-hidden"
          >
            <div className="pt-4 pb-2 space-y-3">
              {group.items.map((rec, i) => (
                <TimelineItem
                  key={rec.ref_id}
                  recommendation={rec}
                  index={i}
                  phaseColor={group.phase.color}
                  isLast={i === group.items.length - 1}
                />
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Connection to next phase */}
      {index < 2 && (
        <div className="flex justify-center py-2">
          <div className="flex flex-col items-center text-neutral-600">
            <div className="w-0.5 h-4 bg-neutral-800" />
            <ChevronDown size={16} />
          </div>
        </div>
      )}
    </motion.div>
  );
}

export function TreatmentTimeline({
  recommendations,
  className = '',
}: TreatmentTimelineProps) {
  const groups = useMemo(() => groupByPhase(recommendations), [recommendations]);

  const totalImprovement = recommendations.reduce((sum, r) => sum + r.impact, 0);
  const totalWeeks = groups.reduce((sum, g) => sum + g.totalWeeks, 0);

  if (groups.length === 0) {
    return (
      <div className={`bg-neutral-900/50 border border-neutral-800 rounded-xl p-6 text-center ${className}`}>
        <Clock size={32} className="mx-auto text-neutral-700 mb-3" />
        <p className="text-neutral-500 text-sm">No treatments to display</p>
      </div>
    );
  }

  return (
    <div className={`bg-neutral-900 border border-neutral-800 rounded-2xl overflow-hidden ${className}`}>
      {/* Header */}
      <div className="p-4 border-b border-neutral-800">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Calendar size={18} className="text-cyan-400" />
            <h3 className="font-semibold text-white">Treatment Timeline</h3>
          </div>
          <div className="flex items-center gap-4 text-xs">
            <span className="text-neutral-500">
              <span className="text-white font-medium">{recommendations.length}</span> treatments
            </span>
            <span className="text-neutral-500">
              <span className="text-white font-medium">~{totalWeeks}</span> weeks
            </span>
          </div>
        </div>
      </div>

      {/* Summary Bar */}
      <div className="p-4 bg-neutral-950/50 border-b border-neutral-800">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs text-neutral-500">Expected improvement</span>
          <span className="text-sm font-medium text-green-400">+{totalImprovement.toFixed(1)} points</span>
        </div>
        <div className="h-2 bg-neutral-800 rounded-full overflow-hidden">
          <motion.div
            className="h-full bg-gradient-to-r from-green-500 via-yellow-500 to-red-500 rounded-full"
            initial={{ width: 0 }}
            animate={{ width: '100%' }}
            transition={{ duration: 1, ease: 'easeOut' }}
          />
        </div>
        <div className="flex justify-between mt-1.5">
          {groups.map((g) => (
            <div key={g.phase.id} className="flex items-center gap-1">
              <div
                className="w-2 h-2 rounded-full"
                style={{ backgroundColor: g.phase.color }}
              />
              <span className="text-[10px] text-neutral-500">{g.phase.name}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Timeline Content */}
      <div className="p-4 space-y-2">
        {groups.map((group, index) => (
          <PhaseGroup key={group.phase.id} group={group} index={index} />
        ))}
      </div>

      {/* Footer */}
      <div className="p-4 border-t border-neutral-800 bg-neutral-950/50">
        <div className="flex items-start gap-2">
          <CheckCircle2 size={16} className="text-green-500 flex-shrink-0 mt-0.5" />
          <p className="text-xs text-neutral-500">
            Start with foundational treatments first. They&apos;re low-risk and can enhance results from later procedures.
          </p>
        </div>
      </div>
    </div>
  );
}
