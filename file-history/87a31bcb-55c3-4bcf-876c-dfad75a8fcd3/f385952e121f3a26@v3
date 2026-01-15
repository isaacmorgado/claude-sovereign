'use client';

import { motion } from 'framer-motion';
import { TrendingUp } from 'lucide-react';
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
      <div className="rounded-2xl bg-neutral-900/40 border border-white/5 p-5 hover:border-white/10 transition-colors">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div
              className="text-4xl font-black italic"
              style={{ color: tierColor }}
            >
              {psl.score.toFixed(2)}
            </div>
            <div>
              <PSLTierBadge tier={psl.tier} size="sm" />
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mt-2">
                Top {(100 - psl.percentile).toFixed(1)}%
              </p>
            </div>
          </div>
          {showPotential && potentialGain > 0 && (
            <div className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-green-500/15 border border-green-500/20">
              <TrendingUp size={14} className="text-green-400" />
              <span className="text-green-400 text-xs font-black">+{potentialGain.toFixed(2)}</span>
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
      className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-8 relative overflow-hidden"
    >
      {/* Background decoration */}
      <div
        className="absolute top-0 right-0 w-64 h-64 rounded-full blur-[100px] opacity-20 pointer-events-none"
        style={{ backgroundColor: tierColor }}
      />

      {/* Header */}
      <div className="flex items-center justify-between mb-8 relative z-10">
        <h2 className="text-xl font-black italic uppercase text-white">PSL Rating</h2>
        <PSLTierBadge tier={psl.tier} showDescription />
      </div>

      {/* Main Score Display */}
      <div className="flex items-center gap-8 mb-8 relative z-10">
        <motion.div
          initial={{ scale: 0.8 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', stiffness: 200 }}
          className="relative"
        >
          {/* Circular background */}
          <div
            className="w-32 h-32 rounded-full flex items-center justify-center border-2"
            style={{
              background: `linear-gradient(135deg, ${tierColor}20 0%, ${tierColor}05 100%)`,
              borderColor: `${tierColor}40`,
            }}
          >
            <div className="text-center">
              <span
                className="text-5xl font-black italic"
                style={{ color: tierColor }}
              >
                {psl.score.toFixed(2)}
              </span>
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mt-1">/10</p>
            </div>
          </div>

          {/* Glowing ring */}
          <div
            className="absolute inset-0 rounded-full opacity-20 blur-xl"
            style={{ backgroundColor: tierColor }}
          />
        </motion.div>

        <div className="flex-1 space-y-4">
          <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4">
            <p className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-2">Tier</p>
            <p className="text-2xl font-black italic uppercase text-white">{psl.tier}</p>
          </div>
          <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4">
            <p className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-2">Percentile</p>
            <p className="text-lg font-black text-white">
              Top <span className="text-cyan-400">{(100 - psl.percentile).toFixed(2)}%</span>
            </p>
          </div>
        </div>
      </div>

      {/* Breakdown */}
      {showBreakdown && (
        <div className="mb-8 relative z-10">
          <PSLBreakdown breakdown={psl.breakdown} />
        </div>
      )}

      {/* Potential */}
      {showPotential && potentialGain > 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.3 }}
          className="rounded-2xl bg-gradient-to-r from-green-500/10 to-cyan-500/10 border border-green-500/20 p-6 relative z-10"
        >
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-neutral-900 border border-green-500/30 flex items-center justify-center">
                <TrendingUp className="w-5 h-5 text-green-400" />
              </div>
              <span className="text-white font-black uppercase tracking-wider">Potential</span>
            </div>
            <div className="text-right">
              <span className="text-3xl font-black italic text-green-400">
                {psl.potential.toFixed(2)}
              </span>
              <span className="text-green-400/70 text-sm font-black ml-2">
                (+{potentialGain.toFixed(2)})
              </span>
            </div>
          </div>
          <p className="text-xs text-neutral-500 font-medium">
            Based on achievable improvements to body composition and soft tissue optimization
          </p>
        </motion.div>
      )}

    </motion.div>
  );
}

// Preview card for overview tab
export function PSLScorePreview({ psl }: { psl: PSLResult }) {
  const tierColor = getTierColor(psl.tier);

  return (
    <div className="rounded-2xl bg-neutral-900/40 border border-white/5 p-5 hover:border-white/10 transition-colors">
      <div className="flex items-center justify-between mb-4">
        <span className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600">PSL Rating</span>
        <PSLTierBadge tier={psl.tier} size="sm" />
      </div>
      <div className="flex items-baseline gap-2">
        <span
          className="text-4xl font-black italic"
          style={{ color: tierColor }}
        >
          {psl.score.toFixed(2)}
        </span>
        <span className="text-neutral-600 text-sm font-bold">/10</span>
      </div>
      <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mt-3">
        Top {(100 - psl.percentile).toFixed(1)}% of population
      </p>
    </div>
  );
}
