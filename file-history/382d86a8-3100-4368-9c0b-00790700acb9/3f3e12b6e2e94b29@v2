'use client';

import { useMemo } from 'react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  ReferenceLine,
  ResponsiveContainer,
  Tooltip,
} from 'recharts';
import { motion } from 'framer-motion';
import { BellCurveData } from '@/lib/scoring';

interface BellCurveChartProps {
  data: BellCurveData;
  title: string;
  unit?: string;
  color?: string;
  showIdeal?: boolean;
  showPercentile?: boolean;
  height?: number;
}

export function BellCurveChart({
  data,
  title,
  unit = '',
  color = '#00f3ff',
  showIdeal = true,
  showPercentile = true,
  height = 200,
}: BellCurveChartProps) {
  const chartData = useMemo(() => {
    return data.points.map((point) => ({
      x: point.x,
      y: point.y,
      // Add fill color based on distance from user value
      isUser: Math.abs(point.x - data.userValue) < data.standardDeviation * 0.1,
    }));
  }, [data]);

  const formatValue = (value: number) => {
    if (Math.abs(value) >= 100) {
      return value.toFixed(0);
    }
    return value.toFixed(2);
  };

  const getPercentileLabel = (percentile: number): string => {
    if (percentile >= 95) return 'Top 5%';
    if (percentile >= 90) return 'Top 10%';
    if (percentile >= 75) return 'Above Average';
    if (percentile >= 50) return 'Average';
    if (percentile >= 25) return 'Below Average';
    return 'Bottom 25%';
  };

  const getPercentileColor = (percentile: number): string => {
    if (percentile >= 90) return '#10b981'; // green
    if (percentile >= 75) return '#22d3ee'; // cyan
    if (percentile >= 50) return '#fbbf24'; // yellow
    if (percentile >= 25) return '#f97316'; // orange
    return '#ef4444'; // red
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-background-secondary rounded-xl border border-border p-4"
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-semibold text-white">{title}</h3>
        {showPercentile && (
          <div className="flex items-center gap-2">
            <span
              className="text-xs font-medium px-2 py-1 rounded-full"
              style={{
                backgroundColor: `${getPercentileColor(data.userPercentile)}20`,
                color: getPercentileColor(data.userPercentile),
              }}
            >
              {getPercentileLabel(data.userPercentile)}
            </span>
            <span className="text-xs text-foreground-dim">
              {data.userPercentile.toFixed(1)}th percentile
            </span>
          </div>
        )}
      </div>

      {/* Chart */}
      <div style={{ height }}>
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart
            data={chartData}
            margin={{ top: 10, right: 10, left: 10, bottom: 20 }}
          >
            <defs>
              <linearGradient id={`gradient-${title}`} x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor={color} stopOpacity={0.3} />
                <stop offset="95%" stopColor={color} stopOpacity={0} />
              </linearGradient>
            </defs>

            <XAxis
              dataKey="x"
              type="number"
              domain={['dataMin', 'dataMax']}
              tickFormatter={(value) => formatValue(value)}
              tick={{ fill: '#71717a', fontSize: 10 }}
              axisLine={{ stroke: '#27272a' }}
              tickLine={{ stroke: '#27272a' }}
            />

            <YAxis hide />

            <Tooltip
              contentStyle={{
                backgroundColor: '#18181b',
                border: '1px solid #27272a',
                borderRadius: '8px',
              }}
              labelStyle={{ color: '#fff' }}
              formatter={(value) => {
                const numValue = typeof value === 'number' ? value : 0;
                return [numValue.toFixed(6), 'Density'];
              }}
              labelFormatter={(value) => {
                const numValue = typeof value === 'number' ? value : 0;
                return `Value: ${formatValue(numValue)}${unit}`;
              }}
            />

            <Area
              type="monotone"
              dataKey="y"
              stroke={color}
              strokeWidth={2}
              fill={`url(#gradient-${title})`}
            />

            {/* Population Mean Line */}
            <ReferenceLine
              x={data.mean}
              stroke="#71717a"
              strokeDasharray="3 3"
              label={{
                value: 'Mean',
                position: 'top',
                fill: '#71717a',
                fontSize: 10,
              }}
            />

            {/* User Value Line */}
            <ReferenceLine
              x={data.userValue}
              stroke={color}
              strokeWidth={2}
              label={{
                value: `You: ${formatValue(data.userValue)}${unit}`,
                position: 'top',
                fill: color,
                fontSize: 11,
                fontWeight: 600,
              }}
            />

            {/* Ideal Value Line (if different from user) */}
            {showIdeal && data.idealValue !== undefined && (
              <ReferenceLine
                x={data.idealValue}
                stroke="#10b981"
                strokeDasharray="5 5"
                label={{
                  value: 'Ideal',
                  position: 'insideTopRight',
                  fill: '#10b981',
                  fontSize: 10,
                }}
              />
            )}
          </AreaChart>
        </ResponsiveContainer>
      </div>

      {/* Stats Footer */}
      <div className="mt-3 grid grid-cols-3 gap-2 text-center">
        <div className="bg-black/30 rounded-lg p-2">
          <p className="text-[10px] text-foreground-dim">Your Value</p>
          <p className="text-sm font-semibold" style={{ color }}>
            {formatValue(data.userValue)}
            {unit}
          </p>
        </div>
        <div className="bg-black/30 rounded-lg p-2">
          <p className="text-[10px] text-foreground-dim">Population Mean</p>
          <p className="text-sm font-semibold text-white">
            {formatValue(data.mean)}
            {unit}
          </p>
        </div>
        {data.idealValue !== undefined && (
          <div className="bg-black/30 rounded-lg p-2">
            <p className="text-[10px] text-foreground-dim">Ideal</p>
            <p className="text-sm font-semibold text-emerald-400">
              {formatValue(data.idealValue)}
              {unit}
            </p>
          </div>
        )}
      </div>
    </motion.div>
  );
}

interface BellCurveComparisonProps {
  measurements: Array<{
    key: string;
    title: string;
    data: BellCurveData;
    unit?: string;
  }>;
}

export function BellCurveComparison({ measurements }: BellCurveComparisonProps) {
  const colors = [
    '#00f3ff', // cyan
    '#10b981', // green
    '#f59e0b', // amber
    '#8b5cf6', // purple
    '#ec4899', // pink
    '#3b82f6', // blue
  ];

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold text-white">Percentile Rankings</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {measurements.map((measurement, index) => (
          <BellCurveChart
            key={measurement.key}
            data={measurement.data}
            title={measurement.title}
            unit={measurement.unit}
            color={colors[index % colors.length]}
            height={180}
          />
        ))}
      </div>
    </div>
  );
}

interface ScoreGaugeProps {
  score: number;
  label: string;
  maxScore?: number;
}

export function ScoreGauge({ score, label, maxScore = 100 }: ScoreGaugeProps) {
  const percentage = (score / maxScore) * 100;
  const circumference = 2 * Math.PI * 45;
  const strokeDashoffset = circumference - (percentage / 100) * circumference;

  const getScoreColor = (score: number): string => {
    if (score >= 90) return '#10b981';
    if (score >= 75) return '#22d3ee';
    if (score >= 50) return '#fbbf24';
    if (score >= 25) return '#f97316';
    return '#ef4444';
  };

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      className="flex flex-col items-center"
    >
      <div className="relative w-28 h-28">
        <svg className="w-full h-full transform -rotate-90">
          {/* Background circle */}
          <circle
            cx="56"
            cy="56"
            r="45"
            stroke="#27272a"
            strokeWidth="8"
            fill="none"
          />
          {/* Progress circle */}
          <motion.circle
            cx="56"
            cy="56"
            r="45"
            stroke={getScoreColor(score)}
            strokeWidth="8"
            fill="none"
            strokeLinecap="round"
            strokeDasharray={circumference}
            initial={{ strokeDashoffset: circumference }}
            animate={{ strokeDashoffset }}
            transition={{ duration: 1, ease: 'easeOut' }}
          />
        </svg>
        <div className="absolute inset-0 flex items-center justify-center">
          <span
            className="text-2xl font-bold"
            style={{ color: getScoreColor(score) }}
          >
            {score.toFixed(0)}
          </span>
        </div>
      </div>
      <p className="mt-2 text-sm text-foreground-dim text-center">{label}</p>
    </motion.div>
  );
}

interface HarmonyScoreDisplayProps {
  harmonyScore: number;
  individualScores: Record<string, number>;
}

export function HarmonyScoreDisplay({
  harmonyScore,
  individualScores,
}: HarmonyScoreDisplayProps) {
  const scoreLabels: Record<string, string> = {
    fwhr: 'Face Ratio',
    canthalTilt: 'Eye Tilt',
    facialThirds: 'Proportions',
    nasolabialAngle: 'Nose-Lip',
    gonialAngle: 'Jaw Angle',
    overallSymmetry: 'Symmetry',
    goldenRatio: 'Golden Ratio',
    nasalIndex: 'Nose Shape',
    lipRatio: 'Lip Ratio',
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-background-secondary rounded-xl border border-border p-6"
    >
      <div className="flex flex-col md:flex-row items-center gap-6">
        {/* Main Harmony Score */}
        <div className="flex-shrink-0">
          <ScoreGauge score={harmonyScore} label="Harmony Score" />
        </div>

        {/* Individual Scores */}
        <div className="flex-1 w-full">
          <h3 className="text-sm font-semibold text-white mb-3">
            Individual Scores
          </h3>
          <div className="space-y-2">
            {Object.entries(individualScores).map(([key, score]) => (
              <div key={key} className="flex items-center gap-3">
                <span className="text-xs text-foreground-dim w-24 truncate">
                  {scoreLabels[key] || key}
                </span>
                <div className="flex-1 h-2 bg-black/30 rounded-full overflow-hidden">
                  <motion.div
                    className="h-full rounded-full"
                    style={{
                      backgroundColor:
                        score >= 75
                          ? '#10b981'
                          : score >= 50
                            ? '#fbbf24'
                            : '#ef4444',
                    }}
                    initial={{ width: 0 }}
                    animate={{ width: `${score}%` }}
                    transition={{ duration: 0.8, delay: 0.1 }}
                  />
                </div>
                <span className="text-xs font-medium text-white w-8 text-right">
                  {score.toFixed(0)}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </motion.div>
  );
}
