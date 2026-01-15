'use client';

import { motion } from 'framer-motion';
import { Sparkles, Zap, Eye, Crown, Shield, Flame } from 'lucide-react';
import { ArchetypeCategory, DimorphismLevel } from '@/lib/archetype-classifier';

// ============================================
// TYPES
// ============================================

interface ArchetypeTraitsProps {
  traits: string[];
  dimorphismLevel?: DimorphismLevel;
  compact?: boolean;
}

interface DimorphismBadgeProps {
  level: DimorphismLevel;
  size?: 'sm' | 'md';
}

// ============================================
// CATEGORY ICONS
// ============================================

const CATEGORY_ICONS: Record<ArchetypeCategory, React.ReactNode> = {
  Softboy: <Sparkles className="w-4 h-4" />,
  Prettyboy: <Crown className="w-4 h-4" />,
  RobustPrettyboy: <Zap className="w-4 h-4" />,
  Chad: <Shield className="w-4 h-4" />,
  Hypermasculine: <Flame className="w-4 h-4" />,
  Exotic: <Eye className="w-4 h-4" />,
};

// ============================================
// CATEGORY COLORS
// ============================================

export const ARCHETYPE_COLORS: Record<ArchetypeCategory, { primary: string; bg: string; border: string }> = {
  Softboy: {
    primary: '#a78bfa',  // Purple
    bg: 'rgba(167, 139, 250, 0.1)',
    border: 'rgba(167, 139, 250, 0.3)',
  },
  Prettyboy: {
    primary: '#67e8f9',  // Cyan
    bg: 'rgba(103, 232, 249, 0.1)',
    border: 'rgba(103, 232, 249, 0.3)',
  },
  RobustPrettyboy: {
    primary: '#22c55e',  // Green
    bg: 'rgba(34, 197, 94, 0.1)',
    border: 'rgba(34, 197, 94, 0.3)',
  },
  Chad: {
    primary: '#f97316',  // Orange
    bg: 'rgba(249, 115, 22, 0.1)',
    border: 'rgba(249, 115, 22, 0.3)',
  },
  Hypermasculine: {
    primary: '#ef4444',  // Red
    bg: 'rgba(239, 68, 68, 0.1)',
    border: 'rgba(239, 68, 68, 0.3)',
  },
  Exotic: {
    primary: '#fbbf24',  // Yellow
    bg: 'rgba(251, 191, 36, 0.1)',
    border: 'rgba(251, 191, 36, 0.3)',
  },
};

// ============================================
// DIMORPHISM COLORS
// ============================================

const DIMORPHISM_COLORS: Record<DimorphismLevel, { label: string; color: string }> = {
  'low': { label: 'Low', color: '#a78bfa' },
  'low-balanced': { label: 'Low-Balanced', color: '#8b5cf6' },
  'balanced': { label: 'Balanced', color: '#67e8f9' },
  'above-average': { label: 'Above Average', color: '#22c55e' },
  'high': { label: 'High', color: '#f97316' },
  'very-high': { label: 'Very High', color: '#ef4444' },
};

// ============================================
// COMPONENTS
// ============================================

/**
 * Dimorphism level badge
 */
export function DimorphismBadge({ level, size = 'md' }: DimorphismBadgeProps) {
  const config = DIMORPHISM_COLORS[level];
  const sizeClasses = size === 'sm' ? 'text-[10px] font-black uppercase tracking-wider px-3 py-1.5' : 'text-xs font-black uppercase tracking-wider px-4 py-2';

  return (
    <span
      className={`${sizeClasses} rounded-xl`}
      style={{
        backgroundColor: `${config.color}15`,
        color: config.color,
        border: `1px solid ${config.color}30`,
      }}
    >
      {config.label} Dimorphism
    </span>
  );
}

/**
 * Single trait badge
 */
function TraitBadge({ trait, index }: { trait: string; index: number }) {
  return (
    <motion.span
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay: index * 0.05 }}
      className="px-4 py-2 rounded-xl bg-neutral-900 text-neutral-300 text-sm font-medium border border-white/10 hover:border-white/20 transition-colors"
    >
      {trait}
    </motion.span>
  );
}

/**
 * Category icon with color
 */
export function CategoryIcon({ category }: { category: ArchetypeCategory }) {
  const colors = ARCHETYPE_COLORS[category];

  return (
    <div
      className="w-12 h-12 rounded-xl flex items-center justify-center"
      style={{
        background: `linear-gradient(135deg, ${colors.primary}20 0%, ${colors.primary}05 100%)`,
        border: `1px solid ${colors.border}`,
        color: colors.primary,
      }}
    >
      {CATEGORY_ICONS[category]}
    </div>
  );
}

/**
 * Archetype traits display
 */
export function ArchetypeTraits({ traits, dimorphismLevel, compact = false }: ArchetypeTraitsProps) {
  if (compact) {
    return (
      <div className="flex flex-wrap gap-1.5">
        {traits.slice(0, 4).map((trait) => (
          <span
            key={trait}
            className="px-2 py-0.5 rounded-full bg-neutral-800 text-neutral-400 text-xs border border-neutral-700"
          >
            {trait}
          </span>
        ))}
        {traits.length > 4 && (
          <span className="px-2 py-0.5 rounded-full bg-neutral-800 text-neutral-500 text-xs">
            +{traits.length - 4} more
          </span>
        )}
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {/* Dimorphism badge */}
      {dimorphismLevel && (
        <div className="mb-3">
          <DimorphismBadge level={dimorphismLevel} />
        </div>
      )}

      {/* Traits */}
      <div className="flex flex-wrap gap-2">
        {traits.map((trait, i) => (
          <TraitBadge key={trait} trait={trait} index={i} />
        ))}
      </div>
    </div>
  );
}

/**
 * Confidence indicator bar
 */
export function ConfidenceBar({
  confidence,
  label,
  color,
}: {
  confidence: number;
  label?: string;
  color?: string;
}) {
  const percentage = Math.round(confidence * 100);

  return (
    <div className="space-y-1">
      {label && (
        <div className="flex justify-between text-xs">
          <span className="text-neutral-400">{label}</span>
          <span className="text-neutral-300">{percentage}%</span>
        </div>
      )}
      <div className="h-2 bg-neutral-800 rounded-full overflow-hidden">
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${percentage}%` }}
          transition={{ duration: 0.5, ease: 'easeOut' }}
          className="h-full rounded-full"
          style={{ backgroundColor: color || '#67e8f9' }}
        />
      </div>
    </div>
  );
}

export default ArchetypeTraits;
