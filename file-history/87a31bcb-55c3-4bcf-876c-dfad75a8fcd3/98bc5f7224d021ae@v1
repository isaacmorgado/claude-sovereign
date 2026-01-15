'use client';

import { PSLTier } from '@/types/psl';
import { getTierColor, getTierDescription } from '@/lib/psl-calculator';

interface PSLTierBadgeProps {
  tier: PSLTier;
  size?: 'sm' | 'md' | 'lg';
  showDescription?: boolean;
  animate?: boolean;
}

const TIER_ICONS: Record<PSLTier, string> = {
  'Deformity': '💀',
  'Subhuman': '😢',
  'Incel': '😔',
  'LTN': '😐',
  'MTN': '🙂',
  'HTN': '😊',
  'Chadlite': '😎',
  'Chad': '🔥',
  'Gigachad': '⚡',
  'True Mogger': '👑',
};

export function PSLTierBadge({
  tier,
  size = 'md',
  showDescription = false,
  animate = true,
}: PSLTierBadgeProps) {
  const color = getTierColor(tier);
  const description = getTierDescription(tier);
  const icon = TIER_ICONS[tier];

  const sizeClasses = {
    sm: 'px-3 py-1.5 text-[10px] font-black uppercase tracking-wider',
    md: 'px-4 py-2 text-xs font-black uppercase tracking-wider',
    lg: 'px-5 py-2.5 text-sm font-black uppercase tracking-wider',
  };

  const iconSizes = {
    sm: 'text-xs',
    md: 'text-sm',
    lg: 'text-base',
  };

  return (
    <div className="inline-flex flex-col items-center gap-1.5">
      <div
        className={`
          inline-flex items-center gap-2 rounded-xl
          ${sizeClasses[size]}
          ${animate ? 'animate-pulse-slow' : ''}
        `}
        style={{
          backgroundColor: `${color}15`,
          color: color,
          border: `1px solid ${color}30`,
        }}
      >
        <span className={iconSizes[size]}>{icon}</span>
        <span>{tier}</span>
      </div>
      {showDescription && (
        <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">{description}</span>
      )}
    </div>
  );
}

// Compact version for inline use
export function PSLTierBadgeCompact({ tier }: { tier: PSLTier }) {
  const color = getTierColor(tier);
  const icon = TIER_ICONS[tier];

  return (
    <span
      className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg text-[10px] font-black uppercase tracking-wider"
      style={{
        backgroundColor: `${color}15`,
        color: color,
        border: `1px solid ${color}20`,
      }}
    >
      {icon} {tier}
    </span>
  );
}
