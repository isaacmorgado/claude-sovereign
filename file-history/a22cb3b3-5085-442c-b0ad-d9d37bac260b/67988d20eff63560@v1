'use client';

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
  icon: string;
}

function BreakdownBar({ label, rawScore, weightedScore, weight, icon }: BreakdownBarProps) {
  const color = getScoreColor(rawScore);
  const weightPercent = Math.round(weight * 100);

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between text-sm">
        <div className="flex items-center gap-2">
          <span className="text-lg">{icon}</span>
          <span className="text-neutral-300 font-medium">{label}</span>
          <span className="text-neutral-500 text-xs">({weightPercent}%)</span>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-neutral-400 text-xs">
            {rawScore.toFixed(1)} x {weight}
          </span>
          <span className="font-semibold text-white">
            +{weightedScore.toFixed(2)}
          </span>
        </div>
      </div>
      <div className="relative h-2 bg-neutral-800 rounded-full overflow-hidden">
        <div
          className="absolute inset-y-0 left-0 rounded-full transition-all duration-500"
          style={{
            width: `${(rawScore / 10) * 100}%`,
            backgroundColor: color,
          }}
        />
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
      {/* Component Scores */}
      <div className="space-y-4">
        <BreakdownBar
          label="Face"
          rawScore={face.raw}
          weightedScore={face.weighted}
          weight={PSL_WEIGHTS.face}
          icon="👤"
        />
        <BreakdownBar
          label="Height"
          rawScore={height.raw}
          weightedScore={height.weighted}
          weight={PSL_WEIGHTS.height}
          icon="📏"
        />
        <BreakdownBar
          label="Body"
          rawScore={body.raw}
          weightedScore={body.weighted}
          weight={PSL_WEIGHTS.body}
          icon="💪"
        />
      </div>

      {/* Divider */}
      <div className="h-px bg-neutral-800" />

      {/* Bonuses & Penalties */}
      {showDetails && (bonuses.total > 0 || penalties > 0) && (
        <div className="space-y-3">
          {bonuses.threshold > 0 && (
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-2">
                <span className="text-green-400">✨</span>
                <span className="text-neutral-400">Threshold Bonus</span>
              </div>
              <span className="font-medium text-green-400">+{bonuses.threshold.toFixed(2)}</span>
            </div>
          )}

          {bonuses.synergy > 0 && (
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-2">
                <span className="text-purple-400">🔗</span>
                <span className="text-neutral-400">Synergy Bonus</span>
              </div>
              <span className="font-medium text-purple-400">+{bonuses.synergy.toFixed(2)}</span>
            </div>
          )}

          {penalties > 0 && (
            <div className="flex items-center justify-between text-sm">
              <div className="flex items-center gap-2">
                <span className="text-red-400">⚠️</span>
                <span className="text-neutral-400">Penalties</span>
              </div>
              <span className="font-medium text-red-400">-{penalties.toFixed(2)}</span>
            </div>
          )}
        </div>
      )}

      {/* Summary */}
      <div className="bg-neutral-900/50 rounded-lg p-4">
        <div className="flex items-center justify-between mb-2">
          <span className="text-neutral-400 text-sm">Base Score</span>
          <span className="text-white font-medium">{baseTotal.toFixed(2)}</span>
        </div>
        {bonuses.total > 0 && (
          <div className="flex items-center justify-between mb-2">
            <span className="text-neutral-400 text-sm">Total Bonuses</span>
            <span className="text-green-400 font-medium">+{bonuses.total.toFixed(2)}</span>
          </div>
        )}
        {penalties > 0 && (
          <div className="flex items-center justify-between mb-2">
            <span className="text-neutral-400 text-sm">Penalties</span>
            <span className="text-red-400 font-medium">-{penalties.toFixed(2)}</span>
          </div>
        )}
        <div className="h-px bg-neutral-800 my-2" />
        <div className="flex items-center justify-between">
          <span className="text-white font-semibold">Final PSL</span>
          <span className="text-xl font-bold text-cyan-400">{finalTotal.toFixed(2)}</span>
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
