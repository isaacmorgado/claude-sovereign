'use client';

import { useEffect } from 'react';
import { motion } from 'framer-motion';
import { Trophy, Loader2 } from 'lucide-react';
import { useLeaderboardOptional } from '@/contexts/LeaderboardContext';
import { api } from '@/lib/api';

interface RankBadgeProps {
  size?: 'sm' | 'md' | 'lg';
  className?: string;
  showPercentile?: boolean;
  alwaysShow?: boolean; // Show placeholder when no rank
}

export function RankBadge({ size = 'sm', className = '', showPercentile = false, alwaysShow = false }: RankBadgeProps) {
  const leaderboard = useLeaderboardOptional();
  const userRank = leaderboard?.userRank;
  const isLoading = leaderboard?.isLoading;
  const isAuthenticated = !!api.getToken();

  // Auto-fetch user's rank on mount if authenticated and not already loaded
  useEffect(() => {
    if (isAuthenticated && !userRank && leaderboard?.fetchMyRank) {
      leaderboard.fetchMyRank();
    }
  }, [isAuthenticated, userRank, leaderboard]);

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

  // Show loading state
  if (isLoading && alwaysShow) {
    return (
      <div className={`inline-flex items-center ${sizeClasses[size]} bg-neutral-800/50 border border-neutral-700 rounded-full ${className}`}>
        <Loader2 size={iconSize[size]} className="text-neutral-500 animate-spin" />
        <span className="text-neutral-500">Loading...</span>
      </div>
    );
  }

  // Show "Not ranked" state if alwaysShow is true
  if (!userRank) {
    if (!alwaysShow) return null;

    return (
      <div
        className={`inline-flex items-center ${sizeClasses[size]} bg-neutral-800/50 border border-neutral-700 rounded-full ${className}`}
        title={isAuthenticated ? "Complete an analysis to get ranked" : "Sign in to get ranked"}
      >
        <Trophy size={iconSize[size]} className="text-neutral-500" />
        <span className="text-neutral-500">
          {isAuthenticated ? 'Not ranked' : 'Sign in'}
        </span>
      </div>
    );
  }

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
