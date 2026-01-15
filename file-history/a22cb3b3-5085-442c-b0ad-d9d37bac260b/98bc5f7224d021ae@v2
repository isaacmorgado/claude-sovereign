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
    sm: 'px-2 py-1 text-xs',
    md: 'px-3 py-1.5 text-sm',
    lg: 'px-4 py-2 text-base',
  };

  const iconSizes = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
  };

  return (
    <div className="inline-flex flex-col items-center gap-1">
      <div
        className={`
          inline-flex items-center gap-1.5 rounded-full font-semibold
          ${sizeClasses[size]}
          ${animate ? 'animate-pulse-slow' : ''}
        `}
        style={{
          backgroundColor: `${color}20`,
          color: color,
          border: `1px solid ${color}40`,
        }}
      >
        <span className={iconSizes[size]}>{icon}</span>
        <span>{tier}</span>
      </div>
      {showDescription && (
        <span className="text-xs text-neutral-500">{description}</span>
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
      className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium"
      style={{
        backgroundColor: `${color}15`,
        color: color,
      }}
    >
      {icon} {tier}
    </span>
  );
}
