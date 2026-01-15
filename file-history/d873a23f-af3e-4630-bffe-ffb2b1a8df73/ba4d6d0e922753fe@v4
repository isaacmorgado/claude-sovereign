'use client';

import { useState, useMemo, useRef, useEffect, useCallback } from 'react';
import { createPortal } from 'react-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { X, ChevronLeft, ChevronRight, AlertTriangle, Sparkles, Info, BarChart3 } from 'lucide-react';
import { FaceIQScoreResult, Gender, Ethnicity, FACEIQ_METRICS } from '@/lib/faceiq-scoring';
import { generateAIDescription, getSeverityFromScore } from '@/lib/aiDescriptions';
import { getScoreColor } from '@/types/results';
import { GradientRangeBar } from '../visualization/GradientRangeBar';

// ============================================
// TYPES
// ============================================

interface RatioDetailModalProps {
  isOpen: boolean;
  onClose: () => void;
  ratio: FaceIQScoreResult | null;
  onPrevious?: () => void;
  onNext?: () => void;
  hasPrevious?: boolean;
  hasNext?: boolean;
  facePhoto?: string;
  gender?: Gender;
  ethnicity?: Ethnicity;
}

// ============================================
// STAT CARD (FaceIQ Style)
// ============================================

interface StatCardProps {
  label: string;
  value: string;
  subtext?: string;
  variant?: 'default' | 'ideal' | 'score';
  scoreColor?: string;
  subtextColor?: string;
}

function StatCard({ label, value, subtext, variant = 'default', scoreColor, subtextColor }: StatCardProps) {
  const variants = {
    default: 'bg-neutral-800/80 border-neutral-700',
    ideal: 'bg-cyan-500/10 border-cyan-500/30',
    score: 'bg-blue-500/10 border-blue-500/30',
  };

  const labelColors = {
    default: 'text-neutral-500',
    ideal: 'text-cyan-400',
    score: 'text-neutral-500',
  };

  return (
    <div className={`rounded-xl border p-3 md:p-4 ${variants[variant]}`}>
      <div className={`text-[10px] font-medium uppercase tracking-wider mb-1 ${labelColors[variant]}`}>
        {label}
      </div>
      <div
        className="text-lg md:text-xl font-semibold"
        style={scoreColor ? { color: scoreColor } : { color: variant === 'ideal' ? 'rgb(34, 211, 238)' : 'white' }}
      >
        {value}
      </div>
      {subtext && (
        <div
          className="text-[10px] mt-0.5 md:mt-1"
          style={{ color: subtextColor || 'rgb(115, 115, 115)' }}
        >
          {subtext}
        </div>
      )}
    </div>
  );
}

// ============================================
// SCORING METHODOLOGY CHART (FaceIQ Style)
// ============================================

interface ScoringMethodologyChartProps {
  value: number;
  score: number;
  idealMin: number;
  idealMax: number;
  rangeMin: number;
  rangeMax: number;
  unit: string;
  decayRate?: number;
}

interface HoverState {
  visible: boolean;
  x: number;
  y: number;
  value: number;
  score: number;
}

function ScoringMethodologyChart({
  value,
  score,
  idealMin,
  idealMax,
  rangeMin,
  rangeMax,
  unit,
  decayRate = 4,
}: ScoringMethodologyChartProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const [hover, setHover] = useState<HoverState>({ visible: false, x: 0, y: 0, value: 0, score: 0 });
  const paddingRef = useRef({ top: 20, right: 20, bottom: 35, left: 35 });
  const chartDimensionsRef = useRef({ width: 0, height: 0, chartWidth: 0, chartHeight: 0 });

  // Calculate score for any x value using exponential decay
  const calculateScore = useCallback((x: number): number => {
    const idealRangeHalf = (idealMax - idealMin) / 2;
    if (idealRangeHalf === 0) return x === idealMin ? 10 : 1;

    if (x >= idealMin && x <= idealMax) {
      return 10;
    }

    const deviation = x < idealMin
      ? (idealMin - x) / idealRangeHalf
      : (x - idealMax) / idealRangeHalf;

    return Math.max(1, 10 * Math.exp(-decayRate * Math.pow(deviation, 2)));
  }, [idealMin, idealMax, decayRate]);

  // Get color for a score value (FaceIQ gradient)
  const getColorForScore = (s: number): string => {
    if (s >= 9) return 'rgb(34, 197, 94)';   // Green - Excellent
    if (s >= 7) return 'rgb(6, 182, 212)';   // Cyan - Good
    if (s >= 5) return 'rgb(250, 204, 21)';  // Yellow - Average
    if (s >= 3) return 'rgb(249, 115, 22)';  // Orange - Below average
    return 'rgb(239, 68, 68)';                // Red - Poor
  };

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    ctx.scale(dpr, dpr);

    const width = rect.width;
    const height = rect.height;
    const padding = paddingRef.current;
    const chartWidth = width - padding.left - padding.right;
    const chartHeight = height - padding.top - padding.bottom;

    // Store dimensions for mouse handler
    chartDimensionsRef.current = { width, height, chartWidth, chartHeight };

    // Clear canvas
    ctx.clearRect(0, 0, width, height);

    // X-axis scale
    const xScale = (val: number) => padding.left + ((val - rangeMin) / (rangeMax - rangeMin)) * chartWidth;
    const yScale = (val: number) => padding.top + (1 - val / 10) * chartHeight;

    // Calculate positions for gradient
    const idealMinPos = Math.max(0, Math.min(1, (idealMin - rangeMin) / (rangeMax - rangeMin)));
    const idealMaxPos = Math.max(0, Math.min(1, (idealMax - rangeMin) / (rangeMax - rangeMin)));

    // Draw horizontal grid lines (FaceIQ style - subtle)
    ctx.strokeStyle = 'rgba(64, 64, 64, 0.5)';
    ctx.lineWidth = 1;
    for (let i = 0; i <= 10; i += 2) {
      const y = yScale(i);
      ctx.beginPath();
      ctx.moveTo(padding.left, y);
      ctx.lineTo(padding.left + chartWidth, y);
      ctx.stroke();
    }

    // Draw ideal range highlight zone
    const idealLeftX = xScale(idealMin);
    const idealRightX = xScale(idealMax);
    ctx.fillStyle = 'rgba(34, 197, 94, 0.08)';
    ctx.fillRect(idealLeftX, padding.top, idealRightX - idealLeftX, chartHeight);

    // Draw ideal range border lines
    ctx.strokeStyle = 'rgba(34, 197, 94, 0.3)';
    ctx.lineWidth = 1;
    ctx.setLineDash([4, 4]);
    ctx.beginPath();
    ctx.moveTo(idealLeftX, padding.top);
    ctx.lineTo(idealLeftX, padding.top + chartHeight);
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(idealRightX, padding.top);
    ctx.lineTo(idealRightX, padding.top + chartHeight);
    ctx.stroke();
    ctx.setLineDash([]);

    // Draw gradient fill under curve
    // Colors: Red (1-3) → Orange (3-5) → Yellow (5-7) → Cyan (7-9) → Green (9-10)
    const fillGradient = ctx.createLinearGradient(padding.left, 0, padding.left + chartWidth, 0);
    fillGradient.addColorStop(0, 'rgba(239, 68, 68, 0.15)');                              // Red - Poor
    fillGradient.addColorStop(Math.max(0, idealMinPos - 0.20), 'rgba(249, 115, 22, 0.15)'); // Orange - Below avg
    fillGradient.addColorStop(Math.max(0, idealMinPos - 0.10), 'rgba(250, 204, 21, 0.15)'); // Yellow - Average
    fillGradient.addColorStop(Math.max(0, idealMinPos - 0.03), 'rgba(6, 182, 212, 0.18)');  // Cyan - Good
    fillGradient.addColorStop(idealMinPos, 'rgba(34, 197, 94, 0.2)');                      // Green - Ideal
    fillGradient.addColorStop(idealMaxPos, 'rgba(34, 197, 94, 0.2)');                      // Green - Ideal
    fillGradient.addColorStop(Math.min(1, idealMaxPos + 0.03), 'rgba(6, 182, 212, 0.18)');  // Cyan - Good
    fillGradient.addColorStop(Math.min(1, idealMaxPos + 0.10), 'rgba(250, 204, 21, 0.15)'); // Yellow - Average
    fillGradient.addColorStop(Math.min(1, idealMaxPos + 0.20), 'rgba(249, 115, 22, 0.15)'); // Orange - Below avg
    fillGradient.addColorStop(1, 'rgba(239, 68, 68, 0.15)');                              // Red - Poor

    // Draw fill
    ctx.beginPath();
    ctx.moveTo(xScale(rangeMin), yScale(0));
    for (let i = 0; i <= 200; i++) {
      const x = rangeMin + (rangeMax - rangeMin) * (i / 200);
      const y = calculateScore(x);
      ctx.lineTo(xScale(x), yScale(y));
    }
    ctx.lineTo(xScale(rangeMax), yScale(0));
    ctx.closePath();
    ctx.fillStyle = fillGradient;
    ctx.fill();

    // Draw curve with gradient stroke
    // Colors: Red (1-3) → Orange (3-5) → Yellow (5-7) → Cyan (7-9) → Green (9-10)
    const lineGradient = ctx.createLinearGradient(padding.left, 0, padding.left + chartWidth, 0);
    lineGradient.addColorStop(0, 'rgb(239, 68, 68)');                              // Red - Poor
    lineGradient.addColorStop(Math.max(0, idealMinPos - 0.20), 'rgb(249, 115, 22)'); // Orange - Below avg
    lineGradient.addColorStop(Math.max(0, idealMinPos - 0.10), 'rgb(250, 204, 21)'); // Yellow - Average
    lineGradient.addColorStop(Math.max(0, idealMinPos - 0.03), 'rgb(6, 182, 212)');  // Cyan - Good
    lineGradient.addColorStop(idealMinPos, 'rgb(34, 197, 94)');                      // Green - Ideal
    lineGradient.addColorStop(idealMaxPos, 'rgb(34, 197, 94)');                      // Green - Ideal
    lineGradient.addColorStop(Math.min(1, idealMaxPos + 0.03), 'rgb(6, 182, 212)');  // Cyan - Good
    lineGradient.addColorStop(Math.min(1, idealMaxPos + 0.10), 'rgb(250, 204, 21)'); // Yellow - Average
    lineGradient.addColorStop(Math.min(1, idealMaxPos + 0.20), 'rgb(249, 115, 22)'); // Orange - Below avg
    lineGradient.addColorStop(1, 'rgb(239, 68, 68)');                              // Red - Poor

    ctx.beginPath();
    for (let i = 0; i <= 200; i++) {
      const x = rangeMin + (rangeMax - rangeMin) * (i / 200);
      const y = calculateScore(x);
      if (i === 0) {
        ctx.moveTo(xScale(x), yScale(y));
      } else {
        ctx.lineTo(xScale(x), yScale(y));
      }
    }
    ctx.strokeStyle = lineGradient;
    ctx.lineWidth = 2.5;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke();

    // Draw axes
    ctx.strokeStyle = 'rgb(82, 82, 82)';
    ctx.lineWidth = 1;

    // Y-axis
    ctx.beginPath();
    ctx.moveTo(padding.left, padding.top);
    ctx.lineTo(padding.left, padding.top + chartHeight);
    ctx.stroke();

    // X-axis
    ctx.beginPath();
    ctx.moveTo(padding.left, padding.top + chartHeight);
    ctx.lineTo(padding.left + chartWidth, padding.top + chartHeight);
    ctx.stroke();

    // Y-axis labels
    ctx.fillStyle = 'rgb(115, 115, 115)';
    ctx.font = '10px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'right';
    ctx.textBaseline = 'middle';
    for (let i = 0; i <= 10; i += 2) {
      ctx.fillText(i.toString(), padding.left - 8, yScale(i));
    }

    // X-axis labels
    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    const steps = 5;
    for (let i = 0; i <= steps; i++) {
      const val = rangeMin + (rangeMax - rangeMin) * (i / steps);
      let formatted: string;
      if (unit === 'percent' || unit === '%') {
        formatted = val.toFixed(0) + '%';
      } else if (unit === 'degrees') {
        formatted = val.toFixed(0) + '°';
      } else {
        formatted = val.toFixed(2);
      }
      ctx.fillText(formatted, xScale(val), padding.top + chartHeight + 8);
    }

    // Draw "Ideal" label in the ideal zone
    if (idealRightX - idealLeftX > 40) {
      ctx.fillStyle = 'rgba(34, 197, 94, 0.6)';
      ctx.font = '9px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'top';
      ctx.fillText('IDEAL', (idealLeftX + idealRightX) / 2, padding.top + 4);
    }

    // Draw current value marker
    // Use calculateScore to ensure marker sits ON the curve
    const currentX = xScale(value);
    const curveScore = calculateScore(value);
    const currentY = yScale(curveScore);

    // Vertical dashed line from point to x-axis
    ctx.setLineDash([3, 3]);
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(currentX, currentY);
    ctx.lineTo(currentX, padding.top + chartHeight);
    ctx.stroke();
    ctx.setLineDash([]);

    // Outer glow circle
    const markerColor = getColorForScore(curveScore);
    ctx.beginPath();
    ctx.arc(currentX, currentY, 10, 0, Math.PI * 2);
    ctx.fillStyle = markerColor.replace('rgb', 'rgba').replace(')', ', 0.2)');
    ctx.fill();

    // Main marker circle
    ctx.beginPath();
    ctx.arc(currentX, currentY, 6, 0, Math.PI * 2);
    ctx.fillStyle = '#ffffff';
    ctx.fill();
    ctx.strokeStyle = markerColor;
    ctx.lineWidth = 2.5;
    ctx.stroke();

    // Inner dot
    ctx.beginPath();
    ctx.arc(currentX, currentY, 2, 0, Math.PI * 2);
    ctx.fillStyle = markerColor;
    ctx.fill();

  }, [value, score, idealMin, idealMax, rangeMin, rangeMax, unit, decayRate, calculateScore]);

  // Mouse move handler for hover tooltip
  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;

    const padding = paddingRef.current;
    const { chartWidth, chartHeight } = chartDimensionsRef.current;

    // Check if mouse is within chart area
    if (
      mouseX >= padding.left &&
      mouseX <= padding.left + chartWidth &&
      mouseY >= padding.top &&
      mouseY <= padding.top + chartHeight
    ) {
      // Convert mouse X to data value
      const dataX = rangeMin + ((mouseX - padding.left) / chartWidth) * (rangeMax - rangeMin);
      const dataScore = calculateScore(dataX);

      setHover({
        visible: true,
        x: mouseX,
        y: padding.top + (1 - dataScore / 10) * chartHeight,
        value: dataX,
        score: dataScore,
      });
    } else {
      setHover(prev => ({ ...prev, visible: false }));
    }
  };

  const handleMouseLeave = () => {
    setHover(prev => ({ ...prev, visible: false }));
  };

  // Calculate the curve score (what the chart's formula gives for this value)
  const curveScore = useMemo(() => calculateScore(value), [calculateScore, value]);

  // Format value with unit
  const formatWithUnit = (val: number): string => {
    if (unit === 'percent' || unit === '%') {
      return val.toFixed(1) + '%';
    } else if (unit === 'degrees') {
      return val.toFixed(1) + '°';
    } else if (unit === 'mm') {
      return val.toFixed(1) + 'mm';
    }
    return val.toFixed(2);
  };

  return (
    <div className="rounded-xl bg-neutral-800/50 border border-neutral-700 p-4">
      <div className="mb-3">
        <div className="flex items-start justify-between">
          <div>
            <div className="flex items-center gap-1.5 mb-1">
              <BarChart3 size={14} className="text-neutral-400" />
              <span className="text-[10px] font-medium text-neutral-400 uppercase tracking-wider">
                Scoring Methodology
              </span>
            </div>
            <div className="text-[10px] text-neutral-500">Hover to explore the curve</div>
          </div>
          <div className="text-right bg-neutral-900/80 px-3 py-1.5 rounded-lg border border-neutral-700">
            <div className="text-[10px] text-neutral-500 mb-0.5">Your Value</div>
            <div className="text-xs font-medium" style={{ color: getColorForScore(curveScore) }}>
              {formatWithUnit(value)} = {curveScore.toFixed(1)}/10
            </div>
          </div>
        </div>
      </div>
      <div ref={containerRef} className="relative h-56 sm:h-64">
        <canvas
          ref={canvasRef}
          className="w-full h-full cursor-crosshair"
          style={{ display: 'block' }}
          onMouseMove={handleMouseMove}
          onMouseLeave={handleMouseLeave}
        />

        {/* Hover Tooltip */}
        <AnimatePresence>
          {hover.visible && (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              transition={{ duration: 0.1 }}
              className="absolute pointer-events-none z-10"
              style={{
                left: hover.x,
                top: hover.y - 50,
                transform: 'translateX(-50%)',
              }}
            >
              <div
                className="px-3 py-2 rounded-lg shadow-xl border backdrop-blur-sm"
                style={{
                  backgroundColor: 'rgba(23, 23, 23, 0.95)',
                  borderColor: getColorForScore(hover.score),
                }}
              >
                <div className="text-[10px] text-neutral-400 mb-0.5">Value</div>
                <div className="text-sm font-semibold text-white">
                  {formatWithUnit(hover.value)}
                </div>
                <div className="mt-1 pt-1 border-t border-neutral-700">
                  <div className="text-[10px] text-neutral-400 mb-0.5">Score</div>
                  <div
                    className="text-sm font-bold"
                    style={{ color: getColorForScore(hover.score) }}
                  >
                    {hover.score.toFixed(1)}/10
                  </div>
                </div>
              </div>
              {/* Tooltip arrow */}
              <div
                className="absolute left-1/2 -translate-x-1/2 -bottom-1.5 w-3 h-3 rotate-45"
                style={{
                  backgroundColor: 'rgba(23, 23, 23, 0.95)',
                  borderRight: `1px solid ${getColorForScore(hover.score)}`,
                  borderBottom: `1px solid ${getColorForScore(hover.score)}`,
                }}
              />
            </motion.div>
          )}
        </AnimatePresence>

        {/* Hover vertical line indicator */}
        {hover.visible && (
          <div
            className="absolute top-5 pointer-events-none"
            style={{
              left: hover.x,
              height: chartDimensionsRef.current.chartHeight,
              width: 1,
              background: `linear-gradient(to bottom, ${getColorForScore(hover.score)}40, transparent)`,
            }}
          />
        )}

        {/* Hover point indicator */}
        {hover.visible && (
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            className="absolute pointer-events-none"
            style={{
              left: hover.x - 5,
              top: hover.y - 5,
              width: 10,
              height: 10,
              borderRadius: '50%',
              backgroundColor: getColorForScore(hover.score),
              boxShadow: `0 0 10px ${getColorForScore(hover.score)}`,
            }}
          />
        )}
      </div>

      {/* Legend - Responsive */}
      <div className="mt-3 flex flex-wrap items-center justify-center gap-x-4 gap-y-2 text-[10px]">
        <div className="flex items-center gap-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-green-500" />
          <span className="text-neutral-400">Ideal (9-10)</span>
        </div>
        <div className="flex items-center gap-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-cyan-500" />
          <span className="text-neutral-400">Good (7-9)</span>
        </div>
        <div className="flex items-center gap-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-yellow-400" />
          <span className="text-neutral-400">Average (5-7)</span>
        </div>
        <div className="flex items-center gap-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-orange-500" />
          <span className="text-neutral-400">Below (3-5)</span>
        </div>
        <div className="flex items-center gap-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-red-500" />
          <span className="text-neutral-400">Poor (1-3)</span>
        </div>
      </div>
    </div>
  );
}

// ============================================
// ABOUT DESCRIPTIONS
// ============================================

// eslint-disable-next-line @typescript-eslint/no-unused-vars
function getAboutDescription(name: string, category: string, gender?: Gender, ethnicity?: Ethnicity): string {
  const descriptions: Record<string, string> = {
    'Face Width to Height Ratio': 'Facial Width-to-Height Ratio evaluates midface compactness by comparing its width to height. Balanced proportions suit most faces; higher ratios (shorter midfaces) are preferred for males.',
    'Lower Third': 'Facial thirds assess the vertical height of facial thirds relative to total facial height, favoring a balanced proportion with a slightly taller Lower Third in males.',
    'Middle Third': 'The middle third spans from the brow line to the base of the nose. A balanced middle third contributes to overall facial harmony.',
    'Upper Third': 'The upper third spans from the hairline to the brow line. Its proportion affects forehead prominence and hairline positioning.',
    'Lateral Canthal Tilt': 'Canthal tilt measures the angle of the eye from inner to outer corner. A positive tilt (outer corner higher) is generally considered more attractive and youthful.',
    'Gonial Angle': 'The gonial angle measures the angle at the jaw corner. A well-defined angle contributes to jaw prominence and facial structure.',
    'Bigonial Width': 'Bigonial width measures the distance between the jaw angles. It contributes to the perception of jaw strength and facial width.',
    'Eye Aspect Ratio': 'Eye aspect ratio compares eye height to width. Almond-shaped eyes with balanced proportions are often considered ideal.',
    'Nasal Index': 'The nasal index compares nose width to height. Balanced proportions contribute to facial harmony.',
    'Chin Philtrum Ratio': 'This ratio compares chin height to philtrum length. Proper balance contributes to lower face harmony.',
    'Submental Cervical Angle': 'This angle measures the definition between chin and neck. A well-defined angle creates a clean jawline profile.',
    'Nose Bridge Width': 'Compares nose bridge width to the overall nose width. Ideal proportions create a refined nasal appearance.',
    'Eyebrow Tilt': 'Measures the angle of the eyebrows. Balanced tilt contributes to a harmonious eye region.',
    'Brow Length Ratio': 'Compares eyebrow length to face width. Appropriately proportioned eyebrows create better facial framing.',
  };

  let baseDescription = descriptions[name] ||
    `This measurement evaluates your ${category.toLowerCase()} proportions and contributes to overall facial harmony.`;

  // Add gender-specific context if available
  if (gender) {
    const genderContext = gender === 'male'
      ? ' Ideal ranges for males tend to favor more angular and defined features.'
      : ' Ideal ranges for females tend to favor softer, more balanced proportions.';
    baseDescription += genderContext;
  }

  return baseDescription;
}

// ============================================
// MAIN MODAL COMPONENT
// ============================================

export function RatioDetailModal({
  isOpen,
  onClose,
  ratio,
  onPrevious,
  onNext,
  hasPrevious = false,
  hasNext = false,
  facePhoto,
  gender,
  ethnicity,
}: RatioDetailModalProps) {
  // Handle client-side mounting for portal
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  // Generate AI description from ratio data
  const flawDetail = useMemo(() => {
    if (!ratio) return null;

    return generateAIDescription(
      ratio.metricId.toLowerCase().replace(/\s+/g, ''),
      ratio.name,
      ratio.value,
      ratio.idealMin,
      ratio.idealMax,
      ratio.score,
      ratio.unit,
      ratio.category
    );
  }, [ratio]);

  // Early returns
  if (!mounted) return null;
  if (!ratio || !flawDetail) return null;

  const scoreColor = getScoreColor(ratio.score);
  const isWithinIdeal = ratio.value >= ratio.idealMin && ratio.value <= ratio.idealMax;
  const severity = getSeverityFromScore(ratio.score);

  // Get metric config for decay rate
  const metricConfig = FACEIQ_METRICS[ratio.metricId];
  const decayRate = metricConfig?.decayRate || 4;

  // Format values with units
  const formatUnit = (v: number) => {
    const formatted = v.toFixed(ratio.unit === 'percent' ? 1 : 2);
    let suffix = '';
    switch (ratio.unit) {
      case 'percent':
        suffix = ' %';
        break;
      case 'degrees':
        suffix = '\u00B0';
        break;
      case 'mm':
        suffix = ' mm';
        break;
      case 'ratio':
      default:
        suffix = '';
    }
    return `${formatted}${suffix}`;
  };

  // Calculate range for visualization
  const idealRange = ratio.idealMax - ratio.idealMin;
  const rangeMin = ratio.idealMin - idealRange * 1.5;
  const rangeMax = ratio.idealMax + idealRange * 1.5;

  // Use portal to render modal at document body level
  const modalContent = (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[9998]"
          />

          {/* Navigation Arrows - Desktop */}
          {hasPrevious && onPrevious && (
            <motion.button
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -10 }}
              onClick={onPrevious}
              className="hidden lg:flex fixed left-4 xl:left-8 top-1/2 -translate-y-1/2 z-[10001] w-12 h-12 rounded-full bg-neutral-800 border border-neutral-600 shadow-xl hover:bg-neutral-700 hover:border-neutral-500 transition-all items-center justify-center group"
              aria-label="Previous measurement"
            >
              <ChevronLeft className="w-6 h-6 text-neutral-300 group-hover:text-white" />
            </motion.button>
          )}

          {hasNext && onNext && (
            <motion.button
              initial={{ opacity: 0, x: 10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 10 }}
              onClick={onNext}
              className="hidden lg:flex fixed right-4 xl:right-8 top-1/2 -translate-y-1/2 z-[10001] w-12 h-12 rounded-full bg-neutral-800 border border-neutral-600 shadow-xl hover:bg-neutral-700 hover:border-neutral-500 transition-all items-center justify-center group"
              aria-label="Next measurement"
            >
              <ChevronRight className="w-6 h-6 text-neutral-300 group-hover:text-white" />
            </motion.button>
          )}

          {/* Modal Container - Full screen flex centering */}
          <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4 pointer-events-none">
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              className="relative w-full max-w-5xl max-h-[90vh] overflow-hidden bg-neutral-900 border border-neutral-700 rounded-2xl shadow-2xl pointer-events-auto"
            >
            {/* Header */}
            <div className="sticky top-0 bg-neutral-900/95 backdrop-blur-sm border-b border-neutral-800 px-4 py-4 md:px-6 z-10">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3 flex-1 min-w-0">
                  {/* Mobile nav */}
                  {hasPrevious && onPrevious && (
                    <button
                      onClick={onPrevious}
                      className="lg:hidden flex-shrink-0 p-1.5 rounded-lg hover:bg-neutral-800 transition-colors text-neutral-400"
                      aria-label="Previous measurement"
                    >
                      <ChevronLeft className="w-5 h-5" />
                    </button>
                  )}

                  <h2 className="text-lg md:text-xl font-semibold text-white truncate">
                    {ratio.name}
                  </h2>

                  {hasNext && onNext && (
                    <button
                      onClick={onNext}
                      className="lg:hidden flex-shrink-0 p-1.5 rounded-lg hover:bg-neutral-800 transition-colors text-neutral-400"
                      aria-label="Next measurement"
                    >
                      <ChevronRight className="w-5 h-5" />
                    </button>
                  )}
                </div>

                <button
                  onClick={onClose}
                  className="flex-shrink-0 ml-4 p-2 rounded-lg hover:bg-neutral-800 transition-colors text-neutral-400 hover:text-white"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            </div>

            {/* Content */}
            <div className="p-4 md:p-6 space-y-4 overflow-y-auto max-h-[calc(90vh-72px)]">
              {/* Stats Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <StatCard
                  label="Your Value"
                  value={formatUnit(ratio.value)}
                  subtext={isWithinIdeal ? 'Within ideal' : 'Outside ideal'}
                  variant="default"
                  subtextColor={isWithinIdeal ? 'rgb(34, 197, 94)' : 'rgb(239, 68, 68)'}
                />
                <StatCard
                  label="Ideal Range"
                  value={`${formatUnit(ratio.idealMin)} - ${formatUnit(ratio.idealMax)}`}
                  subtext="Target range"
                  variant="ideal"
                />
                <StatCard
                  label="Score"
                  value={`${ratio.score.toFixed(2)}/10`}
                  subtext="Normalized score (1-10)"
                  variant="score"
                  scoreColor={scoreColor}
                />
              </div>

              {/* Gradient Range Bar */}
              <GradientRangeBar
                value={ratio.value}
                idealMin={ratio.idealMin}
                idealMax={ratio.idealMax}
                rangeMin={rangeMin}
                rangeMax={rangeMax}
                unit={ratio.unit}
              />

              {/* Two Column Layout */}
              <div className="grid lg:grid-cols-2 gap-4">
                {/* Face Image (if available) */}
                {facePhoto && (
                  <div>
                    <div className="relative rounded-xl overflow-hidden border border-neutral-700 bg-neutral-800">
                      <div className="relative w-full" style={{ aspectRatio: '1/1' }}>
                        <img
                          src={facePhoto}
                          alt="Face"
                          className="w-full h-full object-contain"
                        />
                      </div>
                    </div>
                  </div>
                )}

                {/* Info Sections */}
                <div className={`space-y-4 ${!facePhoto ? 'lg:col-span-2' : ''}`}>
                  {/* May Indicate Strengths - Only show if score is >= 7 */}
                  {ratio.score >= 7 && (
                    <div className="rounded-xl bg-cyan-500/10 border border-cyan-500/30 p-4">
                      <div className="flex items-center gap-2 mb-3">
                        <Sparkles size={14} className="text-cyan-400" />
                        <span className="text-[10px] font-medium text-cyan-400 uppercase tracking-wider">
                          May Indicate Strengths
                        </span>
                      </div>
                      <div className="space-y-3">
                        <div className="pb-3 last:border-0 last:pb-0">
                          <div className="text-sm font-semibold text-white mb-1">
                            {ratio.score >= 9 ? 'Ideal ' : 'Good '}{ratio.name.toLowerCase()}
                          </div>
                          <div className="text-xs text-neutral-300 leading-relaxed">
                            The {ratio.name} measurement is {isWithinIdeal ? 'within' : 'close to'} the ideal range.
                            This contributes to a harmonious {ratio.category.toLowerCase()} appearance.
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* May Indicate Flaws - Only show if score is below 7 */}
                  {ratio.score < 7 && (
                    <div className="rounded-xl bg-amber-500/10 border border-amber-500/30 p-4">
                      <div className="flex items-center gap-2 mb-3">
                        <AlertTriangle size={14} className="text-amber-400" />
                        <span className="text-[10px] font-medium text-amber-400 uppercase tracking-wider">
                          May Indicate Flaws
                        </span>
                      </div>
                      <div className="space-y-3">
                        <div className="pb-3 last:border-0 last:pb-0">
                          <div className="text-sm font-semibold text-white mb-1">
                            {flawDetail.flawName}
                          </div>
                          <div className="text-xs text-neutral-300 leading-relaxed">
                            {flawDetail.reasoning}
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* About This Ratio */}
                  <div className="rounded-xl bg-neutral-800/50 border border-neutral-700 p-4">
                    <div className="flex items-center gap-2 mb-3">
                      <Info size={14} className="text-neutral-400" />
                      <span className="text-[10px] font-medium text-neutral-400 uppercase tracking-wider">
                        About This Ratio
                      </span>
                    </div>
                    <div className="text-sm text-neutral-300 leading-relaxed">
                      {getAboutDescription(ratio.name, ratio.category, gender, ethnicity)}
                    </div>
                  </div>

                  {/* Scoring Methodology Chart */}
                  <ScoringMethodologyChart
                    value={ratio.value}
                    score={ratio.score}
                    idealMin={ratio.idealMin}
                    idealMax={ratio.idealMax}
                    rangeMin={rangeMin}
                    rangeMax={rangeMax}
                    unit={ratio.unit}
                    decayRate={decayRate}
                  />

                  {/* Category Badge */}
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="px-3 py-1.5 rounded-lg bg-neutral-800 border border-neutral-700 text-xs font-medium text-neutral-300">
                      {ratio.category}
                    </span>
                    <span
                      className="px-3 py-1.5 rounded-lg text-xs font-medium capitalize"
                      style={{
                        backgroundColor: `${scoreColor}20`,
                        color: scoreColor,
                        border: `1px solid ${scoreColor}40`,
                      }}
                    >
                      {severity.replace('_', ' ')}
                    </span>
                    {gender && (
                      <span className="px-3 py-1.5 rounded-lg bg-neutral-800 border border-neutral-700 text-xs font-medium text-neutral-300 capitalize">
                        {gender}
                      </span>
                    )}
                    {ethnicity && ethnicity !== 'other' && (
                      <span className="px-3 py-1.5 rounded-lg bg-neutral-800 border border-neutral-700 text-xs font-medium text-neutral-300 capitalize">
                        {ethnicity.replace('_', ' ')}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            </div>
            </motion.div>
          </div>
        </>
      )}
    </AnimatePresence>
  );

  return createPortal(modalContent, document.body);
}

export default RatioDetailModal;
