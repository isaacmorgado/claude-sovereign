'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import {
  Trophy,
  Medal,
  Crown,
  User as UserIcon,
  TrendingUp,
  TrendingDown,
} from 'lucide-react';
import { TabContent } from '../ResultsLayout';
import { useLeaderboard } from '@/contexts/LeaderboardContext';
import { useResults } from '@/contexts/ResultsContext';
import { ScoreCircle } from '../shared';
import { getScoreColor } from '@/types/results';
import { UserProfileModal } from '../modals/UserProfileModal';
import { api } from '@/lib/api';
import { Skeleton } from '@/components/ui/Skeleton';

// ============================================
// LEADERBOARD SKELETON
// ============================================

function LeaderboardSkeleton() {
  return (
    <div className="divide-y divide-neutral-800">
      {[1, 2, 3, 4, 5, 6].map((i) => (
        <div key={i} className="p-4">
          <div className="flex items-start gap-4">
            {/* Rank */}
            <div className="w-12 flex items-center justify-center">
              <Skeleton className="h-6 w-8 rounded" />
            </div>
            {/* Photo */}
            <Skeleton className="w-16 h-16 rounded-xl" />
            {/* Content */}
            <div className="flex-1 space-y-2">
              <div className="flex items-center gap-2">
                <Skeleton className="h-5 w-24" />
                <Skeleton className="h-5 w-12" />
              </div>
              <div className="flex gap-1.5">
                <Skeleton className="h-5 w-16 rounded" />
                <Skeleton className="h-5 w-20 rounded" />
                <Skeleton className="h-5 w-14 rounded" />
              </div>
              <div className="flex gap-1.5">
                <Skeleton className="h-5 w-14 rounded" />
                <Skeleton className="h-5 w-18 rounded" />
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

// ============================================
// RANK DISPLAY HELPERS
// ============================================

function getRankIcon(rank: number) {
  if (rank === 1) return <Crown size={20} className="text-yellow-400" />;
  if (rank === 2) return <Medal size={20} className="text-gray-300" />;
  if (rank === 3) return <Medal size={20} className="text-amber-600" />;
  return null;
}

function getRankBgClass(rank: number, isCurrentUser: boolean) {
  if (isCurrentUser) return 'bg-cyan-500/20 border-cyan-500/40';
  if (rank === 1) return 'bg-yellow-500/10 border-yellow-500/30';
  if (rank === 2) return 'bg-gray-500/10 border-gray-500/30';
  if (rank === 3) return 'bg-amber-500/10 border-amber-500/30';
  return 'bg-neutral-900/60 border-neutral-800';
}

// ============================================
// LEADERBOARD TAB
// ============================================

export function LeaderboardTab() {
  const {
    userRank,
    leaderboard,
    totalCount,
    isLoading,
    error,
    setGenderFilter,
    fetchLeaderboard,
    hasMore,
    loadMore,
    setSelectedUserId,
  } = useLeaderboard();

  const { gender } = useResults();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const isAuthenticated = !!api.getToken();

  // Auto-set gender filter to user's gender (males see male leaderboard, females see female)
  useEffect(() => {
    setGenderFilter(gender);
  }, [gender, setGenderFilter]);

  // Fetch leaderboard if empty (first visit or after gender filter is set)
  // Only fetch if user is authenticated (API requires auth)
  useEffect(() => {
    const token = api.getToken();
    if (leaderboard.length === 0 && !isLoading && !error && token) {
      fetchLeaderboard(0);
    }
  }, [leaderboard.length, isLoading, error, fetchLeaderboard]);

  const handleUserClick = (entry: { userId: string }) => {
    setSelectedUserId(entry.userId);
    setIsModalOpen(true);
  };

  const genderLabel = gender === 'male' ? 'Males' : 'Females';

  return (
    <>
      <TabContent
        title={`${genderLabel} Leaderboard`}
        subtitle={`See how you compare among ${genderLabel.toLowerCase()}`}
      >
        <div className="space-y-6">
          {/* Your Rank Card */}
          {userRank && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-gradient-to-r from-cyan-500/20 to-blue-600/20 border border-cyan-500/30 rounded-xl p-6"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-neutral-400 mb-1">Your Rank ({genderLabel})</p>
                  <div className="flex items-center gap-3">
                    <span className="text-4xl font-bold text-white">#{userRank.genderRank}</span>
                    <div className="text-sm text-neutral-400">
                      <p>Top {userRank.percentile.toFixed(1)}%</p>
                      <p>of {userRank.genderTotal.toLocaleString()} {genderLabel.toLowerCase()}</p>
                    </div>
                  </div>
                </div>
                <ScoreCircle score={userRank.score} size="lg" animate={false} />
              </div>
            </motion.div>
          )}

          {/* Leaderboard List */}
          <div className="bg-neutral-900/60 border border-neutral-800 rounded-xl overflow-hidden">
            <div className="p-4 border-b border-neutral-800 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Trophy size={20} className="text-cyan-400" />
                <h3 className="font-semibold text-white">Top {genderLabel}</h3>
              </div>
              <span className="text-sm text-neutral-400">{totalCount.toLocaleString()} {genderLabel.toLowerCase()}</span>
            </div>

            {isLoading && leaderboard.length === 0 ? (
              <LeaderboardSkeleton />
            ) : error ? (
              <div className="p-8 text-center text-red-400">{error}</div>
            ) : leaderboard.length === 0 ? (
              <div className="p-8 text-center">
                <Trophy size={48} className="mx-auto text-neutral-600 mb-4" />
                {isAuthenticated ? (
                  <p className="text-neutral-400">No entries yet. Be the first!</p>
                ) : (
                  <>
                    <p className="text-neutral-400 mb-4">Sign in to view the leaderboard and compete with others</p>
                    <a
                      href="/login"
                      className="inline-flex items-center gap-2 px-4 py-2 bg-cyan-500 hover:bg-cyan-400 text-black font-medium rounded-lg transition-colors"
                    >
                      Sign In
                    </a>
                  </>
                )}
              </div>
            ) : (
              <div className="divide-y divide-neutral-800">
                {leaderboard.map((entry, index) => (
                  <motion.div
                    key={`${entry.rank}-${index}`}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.03 }}
                    className={`${getRankBgClass(entry.rank, entry.isCurrentUser)} border-l-2 ${
                      entry.isCurrentUser ? 'border-l-cyan-500' : 'border-l-transparent'
                    }`}
                  >
                    <button
                      onClick={() => !entry.isCurrentUser && handleUserClick(entry)}
                      className="w-full p-4 hover:bg-neutral-800/50 transition-colors text-left"
                      disabled={entry.isCurrentUser}
                    >
                      <div className="flex items-start gap-4">
                        {/* Rank */}
                        <div className="w-12 flex items-center justify-center pt-1">
                          {getRankIcon(entry.rank) || (
                            <span className="text-lg font-bold text-neutral-400">#{entry.rank}</span>
                          )}
                        </div>

                        {/* Photo - larger for leaderboard */}
                        <div className="w-16 h-16 rounded-xl overflow-hidden bg-neutral-800 flex items-center justify-center flex-shrink-0 border border-neutral-700">
                          {entry.facePhotoUrl ? (
                            <img
                              src={entry.facePhotoUrl}
                              alt={entry.anonymousName}
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            <UserIcon size={28} className="text-neutral-500" />
                          )}
                        </div>

                        {/* User info + Strengths/Improvements */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            <p className={`font-semibold ${entry.isCurrentUser ? 'text-cyan-400' : 'text-white'}`}>
                              {entry.isCurrentUser ? 'You' : entry.anonymousName}
                            </p>
                            <span
                              className="text-lg font-bold"
                              style={{ color: getScoreColor(entry.score) }}
                            >
                              {entry.score.toFixed(2)}
                            </span>
                          </div>

                          {/* Strengths */}
                          {entry.topStrengths && entry.topStrengths.length > 0 && (
                            <div className="flex items-center gap-1.5 mb-1">
                              <TrendingUp size={12} className="text-green-400 flex-shrink-0" />
                              <div className="flex flex-wrap gap-1">
                                {entry.topStrengths.slice(0, 3).map((strength, i) => (
                                  <span
                                    key={i}
                                    className="text-xs px-1.5 py-0.5 bg-green-500/10 text-green-400 rounded border border-green-500/20"
                                  >
                                    {strength}
                                  </span>
                                ))}
                              </div>
                            </div>
                          )}

                          {/* Improvements */}
                          {entry.topImprovements && entry.topImprovements.length > 0 && (
                            <div className="flex items-center gap-1.5">
                              <TrendingDown size={12} className="text-amber-400 flex-shrink-0" />
                              <div className="flex flex-wrap gap-1">
                                {entry.topImprovements.slice(0, 3).map((improvement, i) => (
                                  <span
                                    key={i}
                                    className="text-xs px-1.5 py-0.5 bg-amber-500/10 text-amber-400 rounded border border-amber-500/20"
                                  >
                                    {improvement}
                                  </span>
                                ))}
                              </div>
                            </div>
                          )}

                          {/* Show placeholder if no data */}
                          {(!entry.topStrengths || entry.topStrengths.length === 0) &&
                           (!entry.topImprovements || entry.topImprovements.length === 0) && (
                            <p className="text-xs text-neutral-500 capitalize">{entry.gender}</p>
                          )}
                        </div>
                      </div>
                    </button>
                  </motion.div>
                ))}
              </div>
            )}

            {/* Load More */}
            {hasMore && leaderboard.length > 0 && (
              <button
                onClick={loadMore}
                disabled={isLoading}
                className="w-full p-4 text-center text-cyan-400 hover:bg-neutral-800/50 transition-colors disabled:opacity-50 border-t border-neutral-800"
              >
                {isLoading ? 'Loading...' : 'Load More'}
              </button>
            )}
          </div>
        </div>
      </TabContent>

      {/* User Profile Modal */}
      <UserProfileModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
    </>
  );
}
