'use client';

import { motion } from 'framer-motion';
import { getScoreColor } from '@/types/results';

interface IdealRangeBarProps {
  value: number;
  idealMin: number;
  idealMax: number;
  rangeMin: number;
  rangeMax: number;
  score: number;
  unit: 'x' | 'mm' | '%' | '°';
  showLabels?: boolean;
  height?: number;
}

export function IdealRangeBar({
  value,
  idealMin,
  idealMax,
  rangeMin,
  rangeMax,
  score,
  unit,
  showLabels = true,
  height = 12,
}: IdealRangeBarProps) {
  const totalRange = rangeMax - rangeMin;
  const idealStartPercent = ((idealMin - rangeMin) / totalRange) * 100;
  const idealEndPercent = ((idealMax - rangeMin) / totalRange) * 100;
  const idealWidthPercent = idealEndPercent - idealStartPercent;
  const valuePercent = Math.max(0, Math.min(100, ((value - rangeMin) / totalRange) * 100));

  const markerColor = getScoreColor(score);
  const isInIdealRange = value >= idealMin && value <= idealMax;

  const formatValue = (v: number | string | undefined) => {
    if (typeof v !== 'number' || isNaN(v)) return '-';
    if (unit === '%' || unit === '°') return v.toFixed(1);
    return v.toFixed(2);
  };

  const unitDisplay = unit === 'x' ? '' : unit;

  return (
    <div className="w-full">
      {/* Range labels - Premium style */}
      {showLabels && (
        <div className="flex justify-between items-center mb-3">
          <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
            {formatValue(rangeMin)}{unitDisplay}
          </span>
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-cyan-500/50" />
            <span className="text-[10px] font-black uppercase tracking-widest text-cyan-400">
              {formatValue(idealMin)} – {formatValue(idealMax)}
            </span>
            <div className="w-2 h-2 rounded-full bg-cyan-500/50" />
          </div>
          <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
            {formatValue(rangeMax)}{unitDisplay}
          </span>
        </div>
      )}

      {/* Bar container - Premium design */}
      <div
        className="relative w-full bg-neutral-800/50 rounded-full"
        style={{ height }}
      >
        {/* Left danger zone (below ideal) */}
        <div
          className="absolute h-full rounded-l-full bg-gradient-to-r from-red-500/20 to-amber-500/20"
          style={{
            left: 0,
            width: `${idealStartPercent}%`,
          }}
        />

        {/* Right danger zone (above ideal) */}
        <div
          className="absolute h-full rounded-r-full bg-gradient-to-l from-red-500/20 to-amber-500/20"
          style={{
            left: `${idealEndPercent}%`,
            width: `${100 - idealEndPercent}%`,
          }}
        />

        {/* Ideal range zone */}
        <motion.div
          className="absolute h-full bg-gradient-to-r from-cyan-500/30 to-emerald-500/30"
          style={{
            left: `${idealStartPercent}%`,
            width: `${idealWidthPercent}%`,
          }}
          initial={{ opacity: 0, scaleX: 0 }}
          animate={{ opacity: 1, scaleX: 1 }}
          transition={{ duration: 0.5, ease: 'easeOut' }}
        />

        {/* Ideal range boundary markers */}
        <div
          className="absolute top-0 w-px h-full bg-cyan-500/60"
          style={{ left: `${idealStartPercent}%` }}
        />
        <div
          className="absolute top-0 w-px h-full bg-cyan-500/60"
          style={{ left: `${idealEndPercent}%` }}
        />

        {/* Value marker - CENTERED properly */}
        <motion.div
          className="absolute top-1/2 flex flex-col items-center"
          style={{
            left: `${valuePercent}%`,
            transform: 'translate(-50%, -50%)'
          }}
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.4, delay: 0.2 }}
        >
          {/* Marker pill */}
          <div
            className="w-1.5 rounded-full shadow-lg"
            style={{
              height: height + 10,
              backgroundColor: markerColor,
              boxShadow: `0 0 12px ${markerColor}80`,
            }}
          />
        </motion.div>
      </div>

      {/* Value badge below bar - Premium style */}
      <motion.div
        className="flex justify-center mt-3"
        initial={{ opacity: 0, y: -5 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.4 }}
      >
        <div
          className="inline-flex items-center gap-3 px-4 py-2 rounded-xl border"
          style={{
            backgroundColor: `${markerColor}10`,
            borderColor: `${markerColor}25`,
          }}
        >
          <span
            className="text-sm font-black"
            style={{ color: markerColor }}
          >
            {formatValue(value)}{unitDisplay}
          </span>
          <div className="w-px h-4 bg-neutral-700" />
          <span className="text-xs font-bold text-neutral-500">
            Score: <span style={{ color: markerColor }}>{typeof score === 'number' ? score.toFixed(1) : score}</span>
          </span>
          {isInIdealRange && (
            <>
              <div className="w-px h-4 bg-neutral-700" />
              <span className="text-[10px] font-black uppercase tracking-wider text-cyan-400">
                Ideal
              </span>
            </>
          )}
        </div>
      </motion.div>
    </div>
  );
}

// ============================================
// COMPACT VERSION
// ============================================

interface CompactIdealRangeBarProps {
  value: number;
  idealMin: number;
  idealMax: number;
  rangeMin: number;
  rangeMax: number;
  score: number;
}

export function CompactIdealRangeBar({
  value,
  idealMin,
  idealMax,
  rangeMin,
  rangeMax,
  score,
}: CompactIdealRangeBarProps) {
  const totalRange = rangeMax - rangeMin;
  const idealStartPercent = ((idealMin - rangeMin) / totalRange) * 100;
  const idealWidthPercent = ((idealMax - idealMin) / totalRange) * 100;
  const valuePercent = Math.max(0, Math.min(100, ((value - rangeMin) / totalRange) * 100));
  const markerColor = getScoreColor(score);

  return (
    <div className="relative w-full h-1.5 bg-neutral-800/50 rounded-full overflow-visible">
      {/* Ideal range zone */}
      <div
        className="absolute h-full bg-cyan-500/30 rounded-full"
        style={{
          left: `${idealStartPercent}%`,
          width: `${idealWidthPercent}%`,
        }}
      />
      {/* Value marker - CENTERED */}
      <motion.div
        className="absolute top-1/2 w-2.5 h-2.5 rounded-full border-2 border-neutral-900"
        style={{
          left: `${valuePercent}%`,
          transform: 'translate(-50%, -50%)',
          backgroundColor: markerColor,
          boxShadow: `0 0 8px ${markerColor}80`,
        }}
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{ duration: 0.3 }}
      />
    </div>
  );
}
