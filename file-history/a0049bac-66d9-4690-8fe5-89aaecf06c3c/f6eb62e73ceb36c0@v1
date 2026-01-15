/**
 * Achievement badge types for gamification
 */

export type AchievementCategory = 'analysis' | 'progress' | 'community' | 'streak' | 'milestone';

export interface Achievement {
  id: string;
  name: string;
  description: string;
  icon: string; // Emoji or icon name
  category: AchievementCategory;
  tier: 'bronze' | 'silver' | 'gold' | 'platinum';
  requirement: {
    type: 'count' | 'score' | 'streak' | 'special';
    target: number;
    metric?: string;
  };
  xpReward: number;
  unlockedAt?: Date;
}

export interface UserAchievements {
  unlocked: string[]; // Achievement IDs
  progress: Record<string, number>; // Achievement ID -> current progress
  totalXp: number;
  level: number;
}

// Badge tier colors
export const TIER_COLORS = {
  bronze: {
    bg: 'bg-amber-900/20',
    border: 'border-amber-700/50',
    text: 'text-amber-600',
    glow: 'shadow-amber-900/30',
  },
  silver: {
    bg: 'bg-slate-400/20',
    border: 'border-slate-500/50',
    text: 'text-slate-400',
    glow: 'shadow-slate-500/30',
  },
  gold: {
    bg: 'bg-yellow-500/20',
    border: 'border-yellow-500/50',
    text: 'text-yellow-400',
    glow: 'shadow-yellow-500/30',
  },
  platinum: {
    bg: 'bg-cyan-400/20',
    border: 'border-cyan-400/50',
    text: 'text-cyan-400',
    glow: 'shadow-cyan-400/30',
  },
} as const;

// XP required for each level
export function getXpForLevel(level: number): number {
  return Math.floor(100 * Math.pow(1.5, level - 1));
}

export function getLevelFromXp(xp: number): { level: number; currentXp: number; nextLevelXp: number } {
  let level = 1;
  let totalXpNeeded = 0;

  while (totalXpNeeded + getXpForLevel(level) <= xp) {
    totalXpNeeded += getXpForLevel(level);
    level++;
  }

  return {
    level,
    currentXp: xp - totalXpNeeded,
    nextLevelXp: getXpForLevel(level),
  };
}
