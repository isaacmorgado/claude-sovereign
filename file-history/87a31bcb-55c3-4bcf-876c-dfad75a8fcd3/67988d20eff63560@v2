'use client';

import { User, Ruler, Dumbbell, Sparkles, Link2, AlertTriangle } from 'lucide-react';
import { PSLBreakdown as PSLBreakdownType, PSL_WEIGHTS } from '@/types/psl';

interface PSLBreakdownProps {
  breakdown: PSLBreakdownType;
  showDetails?: boolean;
}

// Score color based on value (0-10)
function getScoreColor(score: number): string {
  if (score >= 8.5) return '#06b6d4'; // Cyan - exceptional
  if (score >= 7.0) return '#22c55e'; // Green - good
  if (score >= 5.5) return '#84cc16'; // Lime - above average
  if (score >= 4.0) return '#f59e0b'; // Amber - average
  return '#ef4444'; // Red - below average
}

interface BreakdownBarProps {
  label: string;
  rawScore: number;
  weightedScore: number;
  weight: number;
  icon: React.ReactNode;
  color: string;
}

function BreakdownBar({ label, rawScore, weightedScore, weight, icon, color }: BreakdownBarProps) {
  const barColor = getScoreColor(rawScore);
  const weightPercent = Math.round(weight * 100);

  return (
    <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4 hover:border-white/10 transition-colors">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-3">
          <div
            className="w-10 h-10 rounded-xl flex items-center justify-center border"
            style={{
              background: `linear-gradient(135deg, ${color}20 0%, ${color}05 100%)`,
              borderColor: `${color}30`,
            }}
          >
            <span style={{ color }}>{icon}</span>
          </div>
          <div>
            <span className="text-white font-black uppercase tracking-wider text-sm">{label}</span>
            <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 ml-2">({weightPercent}%)</span>
          </div>
        </div>
        <div className="text-right">
          <span className="text-lg font-black" style={{ color: barColor }}>
            {rawScore.toFixed(1)}
          </span>
          <span className="text-neutral-600 font-bold text-xs ml-1">/10</span>
        </div>
      </div>
      <div className="flex items-center gap-3">
        <div className="flex-1 h-2 bg-neutral-800 rounded-full overflow-hidden">
          <div
            className="h-full rounded-full transition-all duration-500"
            style={{
              width: `${(rawScore / 10) * 100}%`,
              backgroundColor: barColor,
            }}
          />
        </div>
        <span className="text-xs font-black text-neutral-500 w-14 text-right">
          +{weightedScore.toFixed(2)}
        </span>
      </div>
    </div>
  );
}

export function PSLBreakdown({ breakdown, showDetails = true }: PSLBreakdownProps) {
  const { face, height, body, bonuses, penalties } = breakdown;

  // Calculate base total
  const baseTotal = face.weighted + height.weighted + body.weighted;
  const finalTotal = baseTotal + bonuses.total - penalties;

  return (
    <div className="space-y-6">
      {/* Section header */}
      <div className="flex items-center gap-4">
        <span className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600">Score Breakdown</span>
        <div className="flex-1 h-px bg-neutral-800" />
      </div>

      {/* Component Scores */}
      <div className="space-y-3">
        <BreakdownBar
          label="Face"
          rawScore={face.raw}
          weightedScore={face.weighted}
          weight={PSL_WEIGHTS.face}
          icon={<User size={18} />}
          color="#a78bfa"
        />
        <BreakdownBar
          label="Height"
          rawScore={height.raw}
          weightedScore={height.weighted}
          weight={PSL_WEIGHTS.height}
          icon={<Ruler size={18} />}
          color="#22c55e"
        />
        <BreakdownBar
          label="Body"
          rawScore={body.raw}
          weightedScore={body.weighted}
          weight={PSL_WEIGHTS.body}
          icon={<Dumbbell size={18} />}
          color="#f97316"
        />
      </div>

      {/* Bonuses & Penalties */}
      {showDetails && (bonuses.total > 0 || penalties > 0) && (
        <div className="rounded-xl bg-neutral-900/30 border border-white/5 p-4 space-y-3">
          {bonuses.threshold > 0 && (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-green-500/15 border border-green-500/20 flex items-center justify-center">
                  <Sparkles size={14} className="text-green-400" />
                </div>
                <span className="text-sm font-bold text-neutral-400">Threshold Bonus</span>
              </div>
              <span className="font-black text-green-400">+{bonuses.threshold.toFixed(2)}</span>
            </div>
          )}

          {bonuses.synergy > 0 && (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-purple-500/15 border border-purple-500/20 flex items-center justify-center">
                  <Link2 size={14} className="text-purple-400" />
                </div>
                <span className="text-sm font-bold text-neutral-400">Synergy Bonus</span>
              </div>
              <span className="font-black text-purple-400">+{bonuses.synergy.toFixed(2)}</span>
            </div>
          )}

          {penalties > 0 && (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-red-500/15 border border-red-500/20 flex items-center justify-center">
                  <AlertTriangle size={14} className="text-red-400" />
                </div>
                <span className="text-sm font-bold text-neutral-400">Penalties</span>
              </div>
              <span className="font-black text-red-400">-{penalties.toFixed(2)}</span>
            </div>
          )}
        </div>
      )}

      {/* Summary */}
      <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-5">
        <div className="flex items-center justify-between mb-3">
          <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">Base Score</span>
          <span className="text-white font-black">{baseTotal.toFixed(2)}</span>
        </div>
        {bonuses.total > 0 && (
          <div className="flex items-center justify-between mb-3">
            <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">Total Bonuses</span>
            <span className="text-green-400 font-black">+{bonuses.total.toFixed(2)}</span>
          </div>
        )}
        {penalties > 0 && (
          <div className="flex items-center justify-between mb-3">
            <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">Penalties</span>
            <span className="text-red-400 font-black">-{penalties.toFixed(2)}</span>
          </div>
        )}
        <div className="h-px bg-neutral-800 my-4" />
        <div className="flex items-center justify-between">
          <span className="text-white font-black uppercase tracking-wider">Final PSL</span>
          <span className="text-2xl font-black italic text-cyan-400">{finalTotal.toFixed(2)}</span>
        </div>
      </div>
    </div>
  );
}

// Compact version for smaller displays
export function PSLBreakdownCompact({ breakdown }: { breakdown: PSLBreakdownType }) {
  const { face, height, body, bonuses, penalties } = breakdown;

  const items = [
    { label: 'Face', value: face.weighted, icon: '👤' },
    { label: 'Height', value: height.weighted, icon: '📏' },
    { label: 'Body', value: body.weighted, icon: '💪' },
  ];

  if (bonuses.total > 0) {
    items.push({ label: 'Bonus', value: bonuses.total, icon: '✨' });
  }

  return (
    <div className="flex items-center gap-4 flex-wrap">
      {items.map((item) => (
        <div key={item.label} className="flex items-center gap-1 text-sm">
          <span>{item.icon}</span>
          <span className="text-neutral-400">{item.label}:</span>
          <span className="text-white font-medium">+{item.value.toFixed(2)}</span>
        </div>
      ))}
      {penalties > 0 && (
        <div className="flex items-center gap-1 text-sm">
          <span>⚠️</span>
          <span className="text-red-400">-{penalties.toFixed(2)}</span>
        </div>
      )}
    </div>
  );
}
