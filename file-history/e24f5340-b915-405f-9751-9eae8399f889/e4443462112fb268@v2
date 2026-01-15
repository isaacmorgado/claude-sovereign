'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import {
  Trophy,
  Medal,
  Crown,
  Users,
  ChevronDown,
  User as UserIcon,
} from 'lucide-react';
import { TabContent } from '../ResultsLayout';
import { useLeaderboard } from '@/contexts/LeaderboardContext';
import { useResults } from '@/contexts/ResultsContext';
import { ScoreCircle } from '../shared';
import { getScoreColor } from '@/types/results';
import { UserProfileModal } from '../modals/UserProfileModal';

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
    genderFilter,
    setGenderFilter,
    fetchLeaderboard,
    hasMore,
    loadMore,
    setSelectedUserId,
  } = useLeaderboard();

  const { gender } = useResults();
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    fetchLeaderboard(0);
  }, [fetchLeaderboard]);

  const handleUserClick = (userId: string) => {
    setSelectedUserId(userId);
    setIsModalOpen(true);
  };

  return (
    <>
      <TabContent
        title="Leaderboard"
        subtitle="See how you compare globally"
        rightContent={
          <div className="flex items-center gap-2">
            {/* Gender Filter */}
            <div className="relative">
              <select
                value={genderFilter}
                onChange={(e) => setGenderFilter(e.target.value as 'all' | 'male' | 'female')}
                className="appearance-none bg-neutral-800 border border-neutral-700 rounded-lg px-3 py-2 pr-8 text-sm text-white focus:outline-none focus:border-cyan-500 cursor-pointer"
              >
                <option value="all">All Genders</option>
                <option value="male">Male</option>
                <option value="female">Female</option>
              </select>
              <ChevronDown size={16} className="absolute right-2 top-1/2 -translate-y-1/2 text-neutral-400 pointer-events-none" />
            </div>
          </div>
        }
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
                  <p className="text-sm text-neutral-400 mb-1">Your Global Rank</p>
                  <div className="flex items-center gap-3">
                    <span className="text-4xl font-bold text-white">#{userRank.globalRank}</span>
                    <div className="text-sm text-neutral-400">
                      <p>Top {userRank.percentile.toFixed(1)}%</p>
                      <p>of {userRank.totalUsers.toLocaleString()} users</p>
                    </div>
                  </div>
                </div>
                <ScoreCircle score={userRank.score} size="lg" animate={false} />
              </div>

              {/* Gender-specific rank */}
              <div className="mt-4 pt-4 border-t border-cyan-500/20 flex items-center gap-4">
                <div className="flex items-center gap-2">
                  <Users size={16} className="text-neutral-400" />
                  <span className="text-sm text-neutral-300">
                    #{userRank.genderRank} among {userRank.genderTotal.toLocaleString()} {gender === 'male' ? 'males' : 'females'}
                  </span>
                </div>
              </div>
            </motion.div>
          )}

          {/* Leaderboard List */}
          <div className="bg-neutral-900/60 border border-neutral-800 rounded-xl overflow-hidden">
            <div className="p-4 border-b border-neutral-800 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Trophy size={20} className="text-cyan-400" />
                <h3 className="font-semibold text-white">Top Rankings</h3>
              </div>
              <span className="text-sm text-neutral-400">{totalCount.toLocaleString()} participants</span>
            </div>

            {isLoading && leaderboard.length === 0 ? (
              <div className="p-8 text-center">
                <div className="animate-spin w-8 h-8 border-2 border-cyan-500 border-t-transparent rounded-full mx-auto" />
                <p className="mt-4 text-neutral-400">Loading leaderboard...</p>
              </div>
            ) : error ? (
              <div className="p-8 text-center text-red-400">{error}</div>
            ) : leaderboard.length === 0 ? (
              <div className="p-8 text-center">
                <Trophy size={48} className="mx-auto text-neutral-600 mb-4" />
                <p className="text-neutral-400">No entries yet. Be the first!</p>
              </div>
            ) : (
              <div className="divide-y divide-neutral-800">
                {leaderboard.map((entry, index) => (
                  <motion.button
                    key={`${entry.rank}-${index}`}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.03 }}
                    onClick={() => !entry.isCurrentUser && handleUserClick(entry.anonymousName)}
                    className={`w-full flex items-center gap-4 p-4 ${getRankBgClass(entry.rank, entry.isCurrentUser)} border-l-2 ${
                      entry.isCurrentUser ? 'border-l-cyan-500' : 'border-l-transparent'
                    } hover:bg-neutral-800/50 transition-colors text-left`}
                    disabled={entry.isCurrentUser}
                  >
                    {/* Rank */}
                    <div className="w-12 flex items-center justify-center">
                      {getRankIcon(entry.rank) || (
                        <span className="text-lg font-bold text-neutral-400">#{entry.rank}</span>
                      )}
                    </div>

                    {/* User info */}
                    <div className="flex-1 flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full overflow-hidden bg-neutral-800 flex items-center justify-center flex-shrink-0">
                        {entry.facePhotoUrl ? (
                          <img
                            src={entry.facePhotoUrl}
                            alt={entry.anonymousName}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <UserIcon size={20} className="text-neutral-500" />
                        )}
                      </div>
                      <div>
                        <p className={`font-medium ${entry.isCurrentUser ? 'text-cyan-400' : 'text-white'}`}>
                          {entry.isCurrentUser ? 'You' : entry.anonymousName}
                        </p>
                        <p className="text-xs text-neutral-500 capitalize">{entry.gender}</p>
                      </div>
                    </div>

                    {/* Score */}
                    <div className="text-right">
                      <span
                        className="text-xl font-bold"
                        style={{ color: getScoreColor(entry.score) }}
                      >
                        {entry.score.toFixed(2)}
                      </span>
                    </div>
                  </motion.button>
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
