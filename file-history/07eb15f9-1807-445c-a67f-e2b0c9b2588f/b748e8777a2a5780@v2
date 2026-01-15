'use client';

import { useMemo } from 'react';
import { motion } from 'framer-motion';

interface GradientRangeBarProps {
  value: number;
  idealMin: number;
  idealMax: number;
  rangeMin: number;
  rangeMax: number;
  unit?: string;
}

// Generate a color gradient from red -> yellow -> cyan -> yellow -> red
function generateGradient(idealMin: number, idealMax: number, rangeMin: number, rangeMax: number): string {
  const totalRange = rangeMax - rangeMin;

  // Calculate positions as percentages
  const idealMinPos = ((idealMin - rangeMin) / totalRange) * 100;
  const idealMaxPos = ((idealMax - rangeMin) / totalRange) * 100;

  // Build gradient stops
  const stops: string[] = [];

  for (let i = 0; i <= 100; i++) {
    let color: string;

    if (i < idealMinPos - 15) {
      // Far below ideal - deep red
      color = 'rgb(185, 28, 28)';
    } else if (i < idealMinPos - 5) {
      // Approaching ideal from below - transition red to orange to yellow
      const t = (i - (idealMinPos - 15)) / 10;
      color = interpolateColor([185, 28, 28], [249, 115, 22], t);
    } else if (i < idealMinPos) {
      // Close to ideal min - yellow to cyan
      const t = (i - (idealMinPos - 5)) / 5;
      color = interpolateColor([249, 115, 22], [34, 211, 238], t);
    } else if (i <= idealMaxPos) {
      // Within ideal range - cyan
      color = 'rgb(6, 182, 212)';
    } else if (i < idealMaxPos + 5) {
      // Just above ideal - cyan to yellow
      const t = (i - idealMaxPos) / 5;
      color = interpolateColor([6, 182, 212], [249, 115, 22], t);
    } else if (i < idealMaxPos + 15) {
      // Above ideal - orange to red
      const t = (i - (idealMaxPos + 5)) / 10;
      color = interpolateColor([249, 115, 22], [185, 28, 28], t);
    } else {
      // Far above ideal - deep red
      color = 'rgb(185, 28, 28)';
    }

    stops.push(`${color} ${i}%`);
  }

  return `linear-gradient(to right, ${stops.join(', ')})`;
}

function interpolateColor(c1: number[], c2: number[], t: number): string {
  const r = Math.round(c1[0] + (c2[0] - c1[0]) * t);
  const g = Math.round(c1[1] + (c2[1] - c1[1]) * t);
  const b = Math.round(c1[2] + (c2[2] - c1[2]) * t);
  return `rgb(${r}, ${g}, ${b})`;
}

export function GradientRangeBar({
  value,
  idealMin,
  idealMax,
  rangeMin,
  rangeMax,
  unit = '',
}: GradientRangeBarProps) {
  const gradient = useMemo(
    () => generateGradient(idealMin, idealMax, rangeMin, rangeMax),
    [idealMin, idealMax, rangeMin, rangeMax]
  );

  // Calculate marker position
  const totalRange = rangeMax - rangeMin;
  const markerPos = Math.max(0, Math.min(100, ((value - rangeMin) / totalRange) * 100));

  // Format value with unit
  const formatUnit = (v: number | string | undefined) => {
    if (typeof v !== 'number' || isNaN(v)) return '-';
    const formatted = v.toFixed(unit === 'percent' || unit === '%' ? 1 : 2);
    const suffix = unit === 'percent' ? '%' : unit === 'degrees' ? '°' : unit === 'x' || unit === 'ratio' ? '' : unit === 'mm' ? 'mm' : '';
    return `${formatted}${suffix}`;
  };

  return (
    <div className="rounded-2xl bg-neutral-900/40 border border-white/5 p-5">
      {/* Header Labels - Premium style */}
      <div className="flex justify-between items-center mb-4">
        <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
          {formatUnit(rangeMin)}
        </span>
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-cyan-500/50" />
          <span className="text-[10px] font-black uppercase tracking-widest text-cyan-400">
            {formatUnit(idealMin)} – {formatUnit(idealMax)}
          </span>
          <div className="w-2 h-2 rounded-full bg-cyan-500/50" />
        </div>
        <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
          {formatUnit(rangeMax)}
        </span>
      </div>

      {/* Gradient bar container */}
      <div className="relative h-3 rounded-full overflow-visible">
        {/* Background gradient */}
        <div
          className="absolute inset-0 rounded-full"
          style={{ background: gradient }}
        />

        {/* Value marker - CENTERED properly with wrapper */}
        <div
          className="absolute top-1/2 -translate-y-1/2 -translate-x-1/2 z-10"
          style={{ left: `${markerPos}%` }}
        >
          <motion.div
            initial={{ scale: 0, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.4, delay: 0.2 }}
          >
            {/* Marker dot with ring */}
            <div className="w-5 h-5 rounded-full bg-white shadow-lg border-2 border-neutral-900 flex items-center justify-center">
              <div className="w-2 h-2 rounded-full bg-neutral-900" />
            </div>
          </motion.div>
        </div>
      </div>

      {/* Value display below - Premium style */}
      <motion.div
        className="flex justify-center mt-4"
        initial={{ opacity: 0, y: -5 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: 0.4 }}
      >
        <div className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10">
          <span className="text-sm font-black text-white">
            {formatUnit(value)}
          </span>
        </div>
      </motion.div>
    </div>
  );
}
