'use client';

import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  History,
  TrendingUp,
  TrendingDown,
  Minus,
  Calendar,
  ChevronRight,
  Trash2,
  Eye,
  X,
  Award,
  Target,
} from 'lucide-react';
import { useAnalysisHistory, AnalysisSnapshot, AnalysisComparison } from '@/hooks/useAnalysisHistory';

// ============================================
// HISTORY ENTRY CARD
// ============================================

interface HistoryEntryProps {
  analysis: AnalysisSnapshot;
  isLatest?: boolean;
  onView?: () => void;
  onCompare?: () => void;
  onDelete?: () => void;
  previousScore?: number;
}

function HistoryEntry({
  analysis,
  isLatest,
  onView,
  onCompare,
  onDelete,
  previousScore,
}: HistoryEntryProps) {
  const scoreDiff = previousScore !== undefined ? analysis.pslRating - previousScore : null;
  const date = new Date(analysis.createdAt);
  const formattedDate = date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: date.getFullYear() !== new Date().getFullYear() ? 'numeric' : undefined,
  });

  return (
    <motion.div
      className={`relative p-4 rounded-xl border transition-all ${
        isLatest
          ? 'bg-cyan-500/10 border-cyan-500/30'
          : 'bg-neutral-900/60 border-neutral-800 hover:border-neutral-700'
      }`}
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      whileHover={{ scale: 1.01 }}
    >
      <div className="flex items-start gap-4">
        {/* Photo Thumbnail */}
        {analysis.frontPhotoUrl ? (
          <div className="w-12 h-12 rounded-lg overflow-hidden flex-shrink-0 bg-neutral-800">
            <img
              src={analysis.frontPhotoUrl}
              alt="Analysis"
              className="w-full h-full object-cover"
            />
          </div>
        ) : (
          <div className="w-12 h-12 rounded-lg bg-neutral-800 flex items-center justify-center flex-shrink-0">
            <History size={20} className="text-neutral-600" />
          </div>
        )}

        {/* Info */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-lg font-bold text-white">
              {analysis.pslRating.toFixed(1)}
            </span>
            <span className="text-xs text-neutral-500">{analysis.pslTier}</span>
            {isLatest && (
              <span className="text-[10px] px-1.5 py-0.5 bg-cyan-500/20 text-cyan-400 rounded-full border border-cyan-500/30">
                Current
              </span>
            )}
          </div>

          <div className="flex items-center gap-2 text-xs text-neutral-500">
            <Calendar size={12} />
            <span>{formattedDate}</span>
            {scoreDiff !== null && (
              <span
                className={`flex items-center gap-0.5 ${
                  scoreDiff > 0
                    ? 'text-green-400'
                    : scoreDiff < 0
                    ? 'text-red-400'
                    : 'text-neutral-500'
                }`}
              >
                {scoreDiff > 0 ? (
                  <TrendingUp size={12} />
                ) : scoreDiff < 0 ? (
                  <TrendingDown size={12} />
                ) : (
                  <Minus size={12} />
                )}
                {scoreDiff > 0 ? '+' : ''}
                {scoreDiff.toFixed(1)}
              </span>
            )}
          </div>

          {/* Archetype */}
          {analysis.archetype && (
            <div className="mt-1 text-xs text-neutral-400">
              {analysis.archetype}
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex items-center gap-1">
          {onView && (
            <button
              onClick={onView}
              className="p-2 rounded-lg text-neutral-500 hover:text-white hover:bg-neutral-800 transition-colors"
              title="View details"
            >
              <Eye size={16} />
            </button>
          )}
          {onCompare && !isLatest && (
            <button
              onClick={onCompare}
              className="p-2 rounded-lg text-neutral-500 hover:text-cyan-400 hover:bg-cyan-500/10 transition-colors"
              title="Compare with current"
            >
              <ChevronRight size={16} />
            </button>
          )}
          {onDelete && !isLatest && (
            <button
              onClick={onDelete}
              className="p-2 rounded-lg text-neutral-500 hover:text-red-400 hover:bg-red-500/10 transition-colors"
              title="Delete"
            >
              <Trash2 size={16} />
            </button>
          )}
        </div>
      </div>
    </motion.div>
  );
}

// ============================================
// COMPARISON MODAL
// ============================================

interface ComparisonModalProps {
  comparison: AnalysisComparison;
  onClose: () => void;
}

function ComparisonModal({ comparison, onClose }: ComparisonModalProps) {
  const { current, previous, changes } = comparison;

  return (
    <motion.div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      onClick={onClose}
    >
      <motion.div
        className="bg-neutral-900 border border-neutral-800 rounded-2xl w-full max-w-lg max-h-[80vh] overflow-y-auto"
        initial={{ scale: 0.95, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.95, opacity: 0 }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-neutral-800">
          <h3 className="font-semibold text-white">Progress Comparison</h3>
          <button
            onClick={onClose}
            className="p-2 rounded-lg text-neutral-500 hover:text-white hover:bg-neutral-800"
          >
            <X size={18} />
          </button>
        </div>

        {/* Score Comparison */}
        <div className="p-6 border-b border-neutral-800">
          <div className="flex items-center justify-center gap-8">
            <div className="text-center">
              <p className="text-xs text-neutral-500 mb-1">Before</p>
              <p className="text-2xl font-bold text-neutral-400">
                {previous.pslRating.toFixed(1)}
              </p>
              <p className="text-xs text-neutral-600">{previous.pslTier}</p>
            </div>

            <div className="flex flex-col items-center">
              <div
                className={`text-2xl font-bold ${
                  changes.pslRating > 0
                    ? 'text-green-400'
                    : changes.pslRating < 0
                    ? 'text-red-400'
                    : 'text-neutral-500'
                }`}
              >
                {changes.pslRating > 0 ? '+' : ''}
                {changes.pslRating.toFixed(1)}
              </div>
              <p className="text-xs text-neutral-500">
                in {changes.daysBetween} days
              </p>
            </div>

            <div className="text-center">
              <p className="text-xs text-neutral-500 mb-1">After</p>
              <p className="text-2xl font-bold text-white">
                {current.pslRating.toFixed(1)}
              </p>
              <p className="text-xs text-cyan-400">{current.pslTier}</p>
            </div>
          </div>
        </div>

        {/* Metric Changes */}
        <div className="p-4 space-y-3">
          <h4 className="text-sm font-medium text-neutral-400">Key Changes</h4>

          {changes.metricChanges
            .filter((m) => Math.abs(m.change) >= 0.1)
            .sort((a, b) => Math.abs(b.change) - Math.abs(a.change))
            .slice(0, 5)
            .map((metric) => (
              <div
                key={metric.name}
                className="flex items-center justify-between p-2 rounded-lg bg-neutral-800/50"
              >
                <span className="text-sm text-neutral-300">{metric.name}</span>
                <div className="flex items-center gap-2">
                  <span className="text-xs text-neutral-500">
                    {metric.before.toFixed(1)}
                  </span>
                  <span className="text-neutral-600">→</span>
                  <span
                    className={`text-sm font-medium ${
                      metric.improved ? 'text-green-400' : 'text-red-400'
                    }`}
                  >
                    {metric.after.toFixed(1)}
                  </span>
                </div>
              </div>
            ))}
        </div>

        {/* Improvements */}
        {(changes.newStrengths.length > 0 || changes.resolvedFlaws.length > 0) && (
          <div className="p-4 border-t border-neutral-800 space-y-3">
            {changes.newStrengths.length > 0 && (
              <div>
                <h4 className="text-sm font-medium text-green-400 mb-2 flex items-center gap-2">
                  <Award size={14} />
                  New Strengths
                </h4>
                <div className="flex flex-wrap gap-2">
                  {changes.newStrengths.map((s) => (
                    <span
                      key={s}
                      className="text-xs px-2 py-1 rounded-full bg-green-500/20 text-green-400 border border-green-500/30"
                    >
                      {s}
                    </span>
                  ))}
                </div>
              </div>
            )}

            {changes.resolvedFlaws.length > 0 && (
              <div>
                <h4 className="text-sm font-medium text-cyan-400 mb-2 flex items-center gap-2">
                  <Target size={14} />
                  Resolved Issues
                </h4>
                <div className="flex flex-wrap gap-2">
                  {changes.resolvedFlaws.map((f) => (
                    <span
                      key={f}
                      className="text-xs px-2 py-1 rounded-full bg-cyan-500/20 text-cyan-400 border border-cyan-500/30"
                    >
                      {f}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </motion.div>
    </motion.div>
  );
}

// ============================================
// MAIN HISTORY CARD
// ============================================

interface AnalysisHistoryCardProps {
  maxEntries?: number;
  compact?: boolean;
}

export function AnalysisHistoryCard({
  maxEntries = 5,
  compact = false,
}: AnalysisHistoryCardProps) {
  const {
    history,
    latestAnalysis,
    deleteAnalysis,
    compareAnalyses,
    getProgressSummary,
  } = useAnalysisHistory();

  const [selectedComparison, setSelectedComparison] = useState<AnalysisComparison | null>(null);

  const summary = useMemo(() => getProgressSummary(), [getProgressSummary]);

  const handleCompare = (analysisId: string) => {
    if (!latestAnalysis) return;
    const comparison = compareAnalyses(latestAnalysis.id, analysisId);
    if (comparison) {
      setSelectedComparison(comparison);
    }
  };

  if (history.length === 0) {
    return (
      <div className="bg-neutral-900/60 border border-neutral-800 rounded-xl p-6 text-center">
        <History size={40} className="mx-auto text-neutral-700 mb-3" />
        <h3 className="font-medium text-white mb-1">No Analysis History</h3>
        <p className="text-sm text-neutral-500">
          Complete your first analysis to start tracking progress
        </p>
      </div>
    );
  }

  return (
    <>
      <div className="bg-black/60 backdrop-blur-xl border border-white/10 rounded-2xl overflow-hidden">
        {/* Header */}
        <div className="p-4 border-b border-white/10">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <History size={18} className="text-cyan-400" />
              <h3 className="font-semibold text-white">Analysis History</h3>
            </div>
            <span className="text-xs text-neutral-500">
              {history.length} {history.length === 1 ? 'entry' : 'entries'}
            </span>
          </div>

          {/* Progress Summary */}
          {!compact && summary.totalAnalyses > 1 && (
            <div className="mt-3 grid grid-cols-3 gap-3 text-center">
              <div className="p-2 rounded-lg bg-neutral-800/50">
                <p className="text-lg font-bold text-green-400">
                  +{summary.averageImprovement.toFixed(2)}
                </p>
                <p className="text-[10px] text-neutral-500">Avg Improvement</p>
              </div>
              <div className="p-2 rounded-lg bg-neutral-800/50">
                <p className="text-lg font-bold text-cyan-400">
                  {summary.bestPslRating.toFixed(1)}
                </p>
                <p className="text-[10px] text-neutral-500">Best Score</p>
              </div>
              <div className="p-2 rounded-lg bg-neutral-800/50">
                <p className="text-lg font-bold text-white">
                  {summary.streakDays}
                </p>
                <p className="text-[10px] text-neutral-500">Day Streak</p>
              </div>
            </div>
          )}
        </div>

        {/* History List */}
        <div className="p-4 space-y-3">
          {history.slice(0, maxEntries).map((analysis, index) => (
            <HistoryEntry
              key={analysis.id}
              analysis={analysis}
              isLatest={index === 0}
              previousScore={index < history.length - 1 ? history[index + 1]?.pslRating : undefined}
              onCompare={() => handleCompare(analysis.id)}
              onDelete={() => deleteAnalysis(analysis.id)}
            />
          ))}

          {history.length > maxEntries && (
            <button className="w-full py-2 text-sm text-neutral-500 hover:text-white transition-colors">
              View all {history.length} entries
            </button>
          )}
        </div>
      </div>

      {/* Comparison Modal */}
      <AnimatePresence>
        {selectedComparison && (
          <ComparisonModal
            comparison={selectedComparison}
            onClose={() => setSelectedComparison(null)}
          />
        )}
      </AnimatePresence>
    </>
  );
}

export default AnalysisHistoryCard;
