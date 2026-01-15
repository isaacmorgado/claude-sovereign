'use client';

import { motion } from 'framer-motion';
import { TrendingUp, Info } from 'lucide-react';
import { PSLResult } from '@/types/psl';
import { getTierColor } from '@/lib/psl-calculator';
import { PSLTierBadge } from './PSLTierBadge';
import { PSLBreakdown } from './PSLBreakdown';

interface PSLScoreCardProps {
  psl: PSLResult;
  showBreakdown?: boolean;
  showPotential?: boolean;
  compact?: boolean;
}

export function PSLScoreCard({
  psl,
  showBreakdown = true,
  showPotential = true,
  compact = false,
}: PSLScoreCardProps) {
  const tierColor = getTierColor(psl.tier);
  const potentialGain = psl.potential - psl.score;

  if (compact) {
    return (
      <div className="bg-neutral-900 rounded-xl p-4 border border-neutral-800">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div
              className="text-4xl font-bold"
              style={{ color: tierColor }}
            >
              {psl.score.toFixed(2)}
            </div>
            <div>
              <PSLTierBadge tier={psl.tier} size="sm" />
              <p className="text-xs text-neutral-500 mt-1">
                Top {(100 - psl.percentile).toFixed(1)}%
              </p>
            </div>
          </div>
          {showPotential && potentialGain > 0 && (
            <div className="flex items-center gap-1 text-green-400 text-sm">
              <TrendingUp size={14} />
              <span>+{potentialGain.toFixed(2)}</span>
            </div>
          )}
        </div>
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-semibold text-white">PSL Rating</h2>
        <PSLTierBadge tier={psl.tier} showDescription />
      </div>

      {/* Main Score Display */}
      <div className="flex items-center gap-6 mb-6">
        <motion.div
          initial={{ scale: 0.8 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', stiffness: 200 }}
          className="relative"
        >
          {/* Circular background */}
          <div
            className="w-28 h-28 rounded-full flex items-center justify-center"
            style={{
              background: `radial-gradient(circle, ${tierColor}15 0%, transparent 70%)`,
              border: `3px solid ${tierColor}40`,
            }}
          >
            <div className="text-center">
              <span
                className="text-4xl font-bold"
                style={{ color: tierColor }}
              >
                {psl.score.toFixed(2)}
              </span>
              <p className="text-xs text-neutral-500 mt-1">/10</p>
            </div>
          </div>

          {/* Glowing ring */}
          <div
            className="absolute inset-0 rounded-full opacity-30 blur-md"
            style={{ backgroundColor: tierColor }}
          />
        </motion.div>

        <div className="flex-1">
          <div className="mb-2">
            <span className="text-neutral-400 text-sm">Tier</span>
            <p className="text-2xl font-bold text-white">{psl.tier}</p>
          </div>
          <div>
            <span className="text-neutral-400 text-sm">Percentile</span>
            <p className="text-lg text-white">
              Top <span className="text-cyan-400 font-semibold">{(100 - psl.percentile).toFixed(2)}%</span>
            </p>
          </div>
        </div>
      </div>

      {/* Breakdown */}
      {showBreakdown && (
        <div className="mb-6">
          <PSLBreakdown breakdown={psl.breakdown} />
        </div>
      )}

      {/* Potential */}
      {showPotential && potentialGain > 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.3 }}
          className="p-4 rounded-lg bg-gradient-to-r from-green-500/10 to-cyan-500/10 border border-green-500/20"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-green-400" />
              <span className="text-neutral-300">Potential with improvements</span>
            </div>
            <div className="text-right">
              <span className="text-2xl font-bold text-green-400">
                {psl.potential.toFixed(2)}
              </span>
              <span className="text-green-400/70 text-sm ml-2">
                (+{potentialGain.toFixed(2)})
              </span>
            </div>
          </div>
          <p className="text-xs text-neutral-500 mt-2">
            Based on achievable improvements to body composition and soft tissue optimization
          </p>
        </motion.div>
      )}

      {/* Info tooltip */}
      <div className="mt-4 flex items-start gap-2 text-xs text-neutral-500">
        <Info size={14} className="flex-shrink-0 mt-0.5" />
        <p>
          PSL = (Face x 0.75) + (Height x 0.20) + (Body x 0.05) + Bonuses.
          Bonuses apply when components exceed 8.5.
        </p>
      </div>
    </motion.div>
  );
}

// Preview card for overview tab
export function PSLScorePreview({ psl }: { psl: PSLResult }) {
  const tierColor = getTierColor(psl.tier);

  return (
    <div className="bg-neutral-900/50 rounded-lg p-4 border border-neutral-800 hover:border-neutral-700 transition-colors">
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm text-neutral-400">PSL Rating</span>
        <PSLTierBadge tier={psl.tier} size="sm" />
      </div>
      <div className="flex items-baseline gap-2">
        <span
          className="text-3xl font-bold"
          style={{ color: tierColor }}
        >
          {psl.score.toFixed(2)}
        </span>
        <span className="text-neutral-500 text-sm">/10</span>
      </div>
      <p className="text-xs text-neutral-500 mt-1">
        Top {(100 - psl.percentile).toFixed(1)}% of population
      </p>
    </div>
  );
}
