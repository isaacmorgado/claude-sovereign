import { Achievement } from '@/types/achievements';

/**
 * All available achievements in the system
 */
export const ACHIEVEMENTS: Achievement[] = [
  // Analysis achievements
  {
    id: 'first-analysis',
    name: 'First Steps',
    description: 'Complete your first face analysis',
    icon: '🎯',
    category: 'analysis',
    tier: 'bronze',
    requirement: { type: 'count', target: 1, metric: 'analyses' },
    xpReward: 50,
  },
  {
    id: 'analysis-veteran',
    name: 'Analysis Veteran',
    description: 'Complete 5 face analyses',
    icon: '📊',
    category: 'analysis',
    tier: 'silver',
    requirement: { type: 'count', target: 5, metric: 'analyses' },
    xpReward: 150,
  },
  {
    id: 'analysis-master',
    name: 'Analysis Master',
    description: 'Complete 20 face analyses',
    icon: '🏆',
    category: 'analysis',
    tier: 'gold',
    requirement: { type: 'count', target: 20, metric: 'analyses' },
    xpReward: 500,
  },

  // Score achievements
  {
    id: 'above-average',
    name: 'Above Average',
    description: 'Achieve a PSL score of 5.0 or higher',
    icon: '⭐',
    category: 'milestone',
    tier: 'bronze',
    requirement: { type: 'score', target: 5.0, metric: 'psl' },
    xpReward: 100,
  },
  {
    id: 'top-tier',
    name: 'Top Tier',
    description: 'Achieve a PSL score of 6.0 or higher',
    icon: '🌟',
    category: 'milestone',
    tier: 'silver',
    requirement: { type: 'score', target: 6.0, metric: 'psl' },
    xpReward: 250,
  },
  {
    id: 'elite',
    name: 'Elite',
    description: 'Achieve a PSL score of 7.0 or higher',
    icon: '💎',
    category: 'milestone',
    tier: 'gold',
    requirement: { type: 'score', target: 7.0, metric: 'psl' },
    xpReward: 500,
  },
  {
    id: 'top-model',
    name: 'Top Model',
    description: 'Achieve a PSL score of 7.5 or higher',
    icon: '👑',
    category: 'milestone',
    tier: 'platinum',
    requirement: { type: 'score', target: 7.5, metric: 'psl' },
    xpReward: 1000,
  },

  // Streak achievements
  {
    id: 'streak-3',
    name: 'Getting Started',
    description: 'Maintain a 3-day streak',
    icon: '🔥',
    category: 'streak',
    tier: 'bronze',
    requirement: { type: 'streak', target: 3 },
    xpReward: 75,
  },
  {
    id: 'streak-7',
    name: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    icon: '🔥',
    category: 'streak',
    tier: 'silver',
    requirement: { type: 'streak', target: 7 },
    xpReward: 200,
  },
  {
    id: 'streak-30',
    name: 'Dedicated',
    description: 'Maintain a 30-day streak',
    icon: '🔥',
    category: 'streak',
    tier: 'gold',
    requirement: { type: 'streak', target: 30 },
    xpReward: 750,
  },
  {
    id: 'streak-100',
    name: 'Unstoppable',
    description: 'Maintain a 100-day streak',
    icon: '💪',
    category: 'streak',
    tier: 'platinum',
    requirement: { type: 'streak', target: 100 },
    xpReward: 2000,
  },

  // Community achievements
  {
    id: 'first-post',
    name: 'Voice Heard',
    description: 'Create your first forum post',
    icon: '💬',
    category: 'community',
    tier: 'bronze',
    requirement: { type: 'count', target: 1, metric: 'posts' },
    xpReward: 50,
  },
  {
    id: 'helpful',
    name: 'Helpful Member',
    description: 'Receive 10 upvotes on your posts',
    icon: '👍',
    category: 'community',
    tier: 'silver',
    requirement: { type: 'count', target: 10, metric: 'upvotes' },
    xpReward: 150,
  },
  {
    id: 'influencer',
    name: 'Influencer',
    description: 'Receive 100 upvotes on your posts',
    icon: '🌟',
    category: 'community',
    tier: 'gold',
    requirement: { type: 'count', target: 100, metric: 'upvotes' },
    xpReward: 500,
  },

  // Progress achievements
  {
    id: 'improvement-1',
    name: 'Making Progress',
    description: 'Improve your score by 0.1 points',
    icon: '📈',
    category: 'progress',
    tier: 'bronze',
    requirement: { type: 'score', target: 0.1, metric: 'improvement' },
    xpReward: 100,
  },
  {
    id: 'improvement-5',
    name: 'Significant Gains',
    description: 'Improve your score by 0.5 points',
    icon: '📈',
    category: 'progress',
    tier: 'silver',
    requirement: { type: 'score', target: 0.5, metric: 'improvement' },
    xpReward: 300,
  },
  {
    id: 'transformation',
    name: 'Transformation',
    description: 'Improve your score by 1.0 point',
    icon: '🦋',
    category: 'progress',
    tier: 'gold',
    requirement: { type: 'score', target: 1.0, metric: 'improvement' },
    xpReward: 750,
  },

  // Special achievements
  {
    id: 'physique-complete',
    name: 'Full Analysis',
    description: 'Complete both face and physique analysis',
    icon: '💪',
    category: 'analysis',
    tier: 'bronze',
    requirement: { type: 'special', target: 1 },
    xpReward: 75,
  },
  {
    id: 'leaderboard-top100',
    name: 'Top 100',
    description: 'Reach the top 100 on the leaderboard',
    icon: '🏅',
    category: 'milestone',
    tier: 'silver',
    requirement: { type: 'special', target: 100 },
    xpReward: 250,
  },
  {
    id: 'leaderboard-top10',
    name: 'Elite Few',
    description: 'Reach the top 10 on the leaderboard',
    icon: '🥇',
    category: 'milestone',
    tier: 'gold',
    requirement: { type: 'special', target: 10 },
    xpReward: 750,
  },
  {
    id: 'leaderboard-top1',
    name: 'The Champion',
    description: 'Reach #1 on the leaderboard',
    icon: '👑',
    category: 'milestone',
    tier: 'platinum',
    requirement: { type: 'special', target: 1 },
    xpReward: 2000,
  },
];

/**
 * Get achievement by ID
 */
export function getAchievementById(id: string): Achievement | undefined {
  return ACHIEVEMENTS.find((a) => a.id === id);
}

/**
 * Get achievements by category
 */
export function getAchievementsByCategory(category: string): Achievement[] {
  return ACHIEVEMENTS.filter((a) => a.category === category);
}

/**
 * Get achievements by tier
 */
export function getAchievementsByTier(tier: Achievement['tier']): Achievement[] {
  return ACHIEVEMENTS.filter((a) => a.tier === tier);
}
