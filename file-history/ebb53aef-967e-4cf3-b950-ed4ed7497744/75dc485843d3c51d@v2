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
  height = 24,
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

  return (
    <div className="w-full">
      {/* Range labels */}
      {showLabels && (
        <div className="flex justify-between text-xs text-neutral-500 mb-1">
          <span>{formatValue(rangeMin)}{unit === 'x' ? '' : unit}</span>
          <span className="text-cyan-400">
            Ideal: {formatValue(idealMin)} - {formatValue(idealMax)}
          </span>
          <span>{formatValue(rangeMax)}{unit === 'x' ? '' : unit}</span>
        </div>
      )}

      {/* Bar container */}
      <div
        className="relative w-full bg-neutral-800 rounded-full overflow-visible"
        style={{ height }}
      >
        {/* Transition zones (gradient from ideal to poor) */}
        <div
          className="absolute h-full rounded-l-full"
          style={{
            left: 0,
            width: `${idealStartPercent}%`,
            background: 'linear-gradient(to right, rgba(239,68,68,0.3), rgba(251,191,36,0.3))',
          }}
        />
        <div
          className="absolute h-full rounded-r-full"
          style={{
            left: `${idealEndPercent}%`,
            width: `${100 - idealEndPercent}%`,
            background: 'linear-gradient(to left, rgba(239,68,68,0.3), rgba(251,191,36,0.3))',
          }}
        />

        {/* Ideal range zone */}
        <motion.div
          className="absolute h-full"
          style={{
            left: `${idealStartPercent}%`,
            width: `${idealWidthPercent}%`,
            background: 'linear-gradient(to right, rgba(103,232,249,0.4), rgba(34,197,94,0.4))',
          }}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        />

        {/* Ideal range markers */}
        <div
          className="absolute top-0 w-0.5 h-full bg-cyan-500/50"
          style={{ left: `${idealStartPercent}%` }}
        />
        <div
          className="absolute top-0 w-0.5 h-full bg-cyan-500/50"
          style={{ left: `${idealEndPercent}%` }}
        />

        {/* Value marker */}
        <motion.div
          className="absolute top-1/2 -translate-y-1/2 flex flex-col items-center"
          style={{ left: `${valuePercent}%` }}
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          {/* Marker line */}
          <div
            className="w-1 rounded-full"
            style={{
              height: height + 8,
              backgroundColor: markerColor,
              boxShadow: `0 0 8px ${markerColor}`,
            }}
          />
          {/* Value label */}
          <motion.div
            className="absolute -top-6 px-1.5 py-0.5 rounded text-xs font-semibold whitespace-nowrap"
            style={{
              backgroundColor: markerColor,
              color: score >= 6 ? '#000' : '#fff',
            }}
            initial={{ y: 10, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ duration: 0.3, delay: 0.5 }}
          >
            {formatValue(value)}{unit === 'x' ? '' : unit}
          </motion.div>
        </motion.div>
      </div>

      {/* Score indicator below */}
      <div className="flex justify-center mt-2">
        <span
          className="text-sm font-medium"
          style={{ color: markerColor }}
        >
          Score: {typeof score === 'number' ? score.toFixed(2) : score}/10
          {isInIdealRange && (
            <span className="ml-2 text-cyan-400">In ideal range</span>
          )}
        </span>
      </div>
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
  const idealEndPercent = ((idealMax - rangeMin) / totalRange) * 100;
  const idealWidthPercent = idealEndPercent - idealStartPercent;
  const valuePercent = Math.max(0, Math.min(100, ((value - rangeMin) / totalRange) * 100));
  const markerColor = getScoreColor(score);

  return (
    <div className="relative w-full h-2 bg-neutral-800 rounded-full overflow-visible">
      {/* Ideal range zone */}
      <div
        className="absolute h-full bg-cyan-500/30"
        style={{
          left: `${idealStartPercent}%`,
          width: `${idealWidthPercent}%`,
        }}
      />
      {/* Value marker */}
      <motion.div
        className="absolute top-1/2 -translate-y-1/2 w-2 h-2 rounded-full"
        style={{
          left: `calc(${valuePercent}% - 4px)`,
          backgroundColor: markerColor,
          boxShadow: `0 0 6px ${markerColor}`,
        }}
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{ duration: 0.3 }}
      />
    </div>
  );
}
