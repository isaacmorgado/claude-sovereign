'use client';

import { useMemo } from 'react';

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
  const formatUnit = (v: number) => {
    const formatted = v.toFixed(unit === 'percent' || unit === '%' ? 1 : 2);
    const suffix = unit === 'percent' ? ' %' : unit === 'degrees' ? '°' : unit === 'x' || unit === 'ratio' ? ' x' : unit === 'mm' ? ' mm' : '';
    return `${formatted}${suffix}`;
  };

  return (
    <div className="rounded-xl bg-neutral-800/50 border border-neutral-700 p-4">
      <div className="relative mb-4 px-2">
        {/* Gradient bar */}
        <div className="relative h-6 rounded-lg overflow-hidden mt-4">
          <div
            className="absolute inset-0 h-6"
            style={{ background: gradient }}
          />
        </div>

        {/* Value marker with tooltip */}
        <div
          className="absolute top-1/2 transform -translate-y-1/2 -translate-x-1/2 z-10 pointer-events-none"
          style={{ left: `${markerPos}%`, top: 'calc(50% + 8px)' }}
        >
          <div className="relative">
            {/* Marker dot */}
            <div className="w-4 h-4 rounded-full bg-white shadow-lg ring-2 ring-neutral-900/30 flex items-center justify-center">
              <div className="w-1.5 h-1.5 rounded-full bg-neutral-900" />
            </div>

            {/* Tooltip above */}
            <div className="absolute -top-12 left-1/2 transform -translate-x-1/2 whitespace-nowrap">
              <div className="px-3 py-1.5 rounded-lg shadow-lg bg-white border border-neutral-200">
                <div className="text-sm font-semibold text-neutral-900">{formatUnit(value)}</div>
              </div>
              {/* Triangle pointer */}
              <div className="absolute top-full left-1/2 transform -translate-x-1/2 -mt-px">
                <div className="w-0 h-0 border-l-[6px] border-r-[6px] border-t-[6px] border-transparent border-t-white" />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Range labels */}
      <div className="flex justify-between items-center text-xs text-neutral-500 px-2">
        <span>{formatUnit(rangeMin)}</span>
        <span className="text-cyan-400 font-medium">
          Ideal: {formatUnit(idealMin)} - {formatUnit(idealMax)}
        </span>
        <span>{formatUnit(rangeMax)}</span>
      </div>
    </div>
  );
}
