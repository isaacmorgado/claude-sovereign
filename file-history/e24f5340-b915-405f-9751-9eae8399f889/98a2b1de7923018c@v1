'use client';

import { motion } from 'framer-motion';
import { Trophy } from 'lucide-react';
import { useLeaderboardOptional } from '@/contexts/LeaderboardContext';

interface RankBadgeProps {
  size?: 'sm' | 'md' | 'lg';
  className?: string;
  showPercentile?: boolean;
}

export function RankBadge({ size = 'sm', className = '', showPercentile = false }: RankBadgeProps) {
  const leaderboard = useLeaderboardOptional();
  const userRank = leaderboard?.userRank;

  if (!userRank) return null;

  const sizeClasses = {
    sm: 'px-2 py-1 text-xs gap-1',
    md: 'px-3 py-1.5 text-sm gap-1.5',
    lg: 'px-4 py-2 text-base gap-2',
  };

  const iconSize = {
    sm: 12,
    md: 14,
    lg: 16,
  };

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      className={`inline-flex items-center ${sizeClasses[size]} bg-gradient-to-r from-yellow-500/20 to-amber-500/20 border border-yellow-500/30 rounded-full cursor-pointer hover:from-yellow-500/30 hover:to-amber-500/30 transition-colors ${className}`}
      title={`Top ${userRank.percentile.toFixed(1)}% of ${userRank.totalUsers.toLocaleString()} users`}
    >
      <Trophy size={iconSize[size]} className="text-yellow-400" />
      <span className="font-semibold text-yellow-400">#{userRank.globalRank}</span>
      {showPercentile && (
        <span className="text-yellow-400/70 text-[0.8em]">
          Top {userRank.percentile.toFixed(1)}%
        </span>
      )}
    </motion.div>
  );
}
