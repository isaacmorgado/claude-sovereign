'use client';

import { motion } from 'framer-motion';

interface LandmarkDotProps {
  /** CSS left position (e.g., "50%") */
  left: string;
  /** CSS top position (e.g., "50%") */
  top: string;
  /** Dot color */
  color: string;
  /** Whether this is the currently active/highlighted landmark */
  isActive?: boolean;
  /** Whether to show the dot (for dimmed/inactive landmarks) */
  isVisible?: boolean;
  /** Opacity for non-active landmarks */
  opacity?: number;
  /** Scale factor to counteract parent zoom (1/zoomLevel) */
  inverseScale?: number;
  /** Optional label to display */
  label?: string;
  /** Whether to show the label */
  showLabel?: boolean;
  /** Click handler */
  onClick?: () => void;
  /** Whether pointer events are enabled */
  interactive?: boolean;
}

/**
 * Reusable landmark dot component with consistent styling across the app.
 * Supports both active (highlighted with glow) and inactive (dimmed) states.
 */
export function LandmarkDot({
  left,
  top,
  color,
  isActive = false,
  isVisible = true,
  opacity = 0.4,
  inverseScale = 1,
  label,
  showLabel = false,
  onClick,
  interactive = false,
}: LandmarkDotProps) {
  if (!isVisible) return null;

  const baseTransform = `translate(-50%, -50%) scale(${inverseScale})`;

  if (isActive) {
    return (
      <div
        className="absolute pointer-events-none"
        style={{
          left,
          top,
          transform: `scale(${inverseScale})`,
        }}
      >
        {/* Pulsing glow */}
        <motion.div
          className="absolute rounded-full"
          style={{
            width: 48,
            height: 48,
            left: -24,
            top: -24,
            background: `radial-gradient(circle, ${color}40 0%, transparent 70%)`,
          }}
          animate={{
            scale: [1, 1.5, 1],
            opacity: [0.8, 0.3, 0.8],
          }}
          transition={{
            duration: 1.5,
            repeat: Infinity,
            ease: 'easeInOut',
          }}
        />

        {/* Main dot */}
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          className="absolute rounded-full border-2 border-white"
          style={{
            width: 14,
            height: 14,
            left: -7,
            top: -7,
            backgroundColor: color,
            boxShadow: `0 0 12px ${color}, 0 0 24px ${color}50`,
          }}
        />

        {/* Optional label */}
        {showLabel && label && (
          <div
            className="absolute left-5 top-1/2 -translate-y-1/2 px-2 py-1 rounded bg-black/80 text-white text-xs whitespace-nowrap"
            style={{ transform: `translateY(-50%) scale(${inverseScale})` }}
          >
            {label}
          </div>
        )}
      </div>
    );
  }

  // Inactive/dimmed landmark
  return (
    <div
      className={`absolute w-2.5 h-2.5 ${interactive ? 'cursor-pointer' : 'pointer-events-none'}`}
      style={{
        left,
        top,
        opacity,
        transform: baseTransform,
      }}
      onClick={interactive ? onClick : undefined}
    >
      <div
        className="w-full h-full rounded-full border border-black/50"
        style={{ backgroundColor: color }}
      />
      {showLabel && label && (
        <div className="absolute left-4 top-1/2 -translate-y-1/2 px-2 py-0.5 rounded bg-black/70 text-white text-xs whitespace-nowrap">
          {label}
        </div>
      )}
    </div>
  );
}

/**
 * Calculate landmark position accounting for object-contain letterboxing.
 * Returns CSS percentage values for left/top positioning.
 */
export function calculateLandmarkPosition(
  normalizedX: number,
  normalizedY: number,
  bounds: {
    offsetX: number;
    offsetY: number;
    renderedWidth: number;
    renderedHeight: number;
    containerWidth: number;
    containerHeight: number;
  }
): { left: string; top: string } {
  const pixelX = bounds.offsetX + normalizedX * bounds.renderedWidth;
  const pixelY = bounds.offsetY + normalizedY * bounds.renderedHeight;

  return {
    left: `${(pixelX / bounds.containerWidth) * 100}%`,
    top: `${(pixelY / bounds.containerHeight) * 100}%`,
  };
}
