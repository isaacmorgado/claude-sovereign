'use client';

import { ResponsiveContainer, RadarChart, PolarGrid, PolarAngleAxis, Radar, Tooltip } from 'recharts';
import { useResults } from '@/contexts/ResultsContext';
import { useMemo } from 'react';

interface RadarDataPoint {
  category: string;
  score: number;
  fullMark: number;
}

// Map metrics to their display categories
const CATEGORY_MAPPING: Record<string, string> = {
  'Midface/Face Shape': 'Face Shape',
  'Occlusion/Jaw Growth': 'Jaw',
  'Jaw Shape': 'Jaw',
  'Upper Third': 'Forehead',
  'Eyes': 'Eyes',
  'Nose': 'Nose',
  'Lips': 'Lips',
  'Chin': 'Chin',
  'Neck': 'Neck',
};

// Custom tooltip component
function CustomTooltip({ active, payload }: { active?: boolean; payload?: Array<{ payload: RadarDataPoint }> }) {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    return (
      <div className="bg-neutral-900 border border-neutral-700 rounded-lg px-3 py-2 shadow-xl">
        <p className="text-neutral-300 text-xs mb-1">{data.category}</p>
        <p className="text-cyan-400 font-bold text-lg">
          {data.score.toFixed(1)}<span className="text-neutral-500 text-sm">/10</span>
        </p>
      </div>
    );
  }
  return null;
}

interface FacialRadarChartProps {
  height?: number;
  showLabels?: boolean;
  fillOpacity?: number;
}

export function FacialRadarChart({
  height = 280,
  showLabels = true,
  fillOpacity = 0.3
}: FacialRadarChartProps) {
  const { frontRatios, sideRatios } = useResults();

  const data = useMemo<RadarDataPoint[]>(() => {
    // Handle empty or undefined ratios
    if (!frontRatios?.length && !sideRatios?.length) {
      return [];
    }

    const allRatios = [...(frontRatios || []), ...(sideRatios || [])];

    // Group ratios by display category and calculate average scores
    const categoryScores: Record<string, { total: number; count: number }> = {};

    allRatios.forEach(ratio => {
      if (!ratio || typeof ratio.score !== 'number' || isNaN(ratio.score)) return;
      const displayCategory = CATEGORY_MAPPING[ratio.category] || ratio.category;
      if (!categoryScores[displayCategory]) {
        categoryScores[displayCategory] = { total: 0, count: 0 };
      }
      categoryScores[displayCategory].total += ratio.score;
      categoryScores[displayCategory].count += 1;
    });

    // Convert to array format for Recharts
    const categories = ['Eyes', 'Nose', 'Lips', 'Jaw', 'Chin', 'Face Shape', 'Forehead', 'Neck'];

    return categories
      .filter(cat => categoryScores[cat] && categoryScores[cat].count > 0)
      .map(category => ({
        category,
        score: Math.round((categoryScores[category].total / categoryScores[category].count) * 10) / 10 || 0,
        fullMark: 10,
      }));
  }, [frontRatios, sideRatios]);

  if (data.length === 0) {
    return (
      <div className="flex items-center justify-center h-[280px] text-neutral-500">
        No data available
      </div>
    );
  }

  return (
    <div className="w-full" style={{ height, minHeight: height }}>
      <ResponsiveContainer width="100%" height="100%" minWidth={200} minHeight={200}>
        <RadarChart cx="50%" cy="50%" outerRadius="75%" data={data}>
          <PolarGrid
            stroke="#374151"
            strokeOpacity={0.5}
            gridType="polygon"
          />
          <PolarAngleAxis
            dataKey="category"
            stroke="#9ca3af"
            tick={{
              fill: showLabels ? '#9ca3af' : 'transparent',
              fontSize: 11,
              fontWeight: 500,
            }}
            tickLine={false}
          />
          <Radar
            name="Score"
            dataKey="score"
            stroke="#00f3ff"
            strokeWidth={2}
            fill="#00f3ff"
            fillOpacity={fillOpacity}
            dot={{
              r: 4,
              fill: '#00f3ff',
              stroke: '#0a0a0a',
              strokeWidth: 2,
            }}
            activeDot={{
              r: 6,
              fill: '#00f3ff',
              stroke: '#ffffff',
              strokeWidth: 2,
            }}
          />
          <Tooltip content={<CustomTooltip />} />
        </RadarChart>
      </ResponsiveContainer>
    </div>
  );
}
