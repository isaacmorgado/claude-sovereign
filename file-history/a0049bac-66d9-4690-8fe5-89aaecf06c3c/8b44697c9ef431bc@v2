'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Trophy, ChevronRight, Flame, Star, MessageSquare, TrendingUp, Target } from 'lucide-react';
import { AchievementBadge, AchievementCard } from './AchievementBadge';
import { ACHIEVEMENTS, getAchievementsByCategory } from '@/data/achievements';
import { AchievementCategory, getLevelFromXp } from '@/types/achievements';

interface AchievementsShowcaseProps {
  unlockedIds: string[];
  progress: Record<string, number>;
  totalXp: number;
  compact?: boolean;
}

const CATEGORY_CONFIG: Record<AchievementCategory, { label: string; icon: typeof Trophy }> = {
  analysis: { label: 'Analysis', icon: Target },
  progress: { label: 'Progress', icon: TrendingUp },
  community: { label: 'Community', icon: MessageSquare },
  streak: { label: 'Streaks', icon: Flame },
  milestone: { label: 'Milestones', icon: Star },
};

export function AchievementsShowcase({
  unlockedIds,
  progress,
  totalXp,
  compact = false,
}: AchievementsShowcaseProps) {
  const [selectedCategory, setSelectedCategory] = useState<AchievementCategory | 'all'>('all');
  const [showAllModal, setShowAllModal] = useState(false);

  const { level, currentXp, nextLevelXp } = getLevelFromXp(totalXp);
  const xpProgress = (currentXp / nextLevelXp) * 100;

  const unlockedAchievements = ACHIEVEMENTS.filter((a) => unlockedIds.includes(a.id));
  const recentUnlocked = unlockedAchievements.slice(-3);

  const filteredAchievements =
    selectedCategory === 'all'
      ? ACHIEVEMENTS
      : getAchievementsByCategory(selectedCategory);

  if (compact) {
    return (
      <div className="bg-neutral-900/60 border border-neutral-800 rounded-xl p-4">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Trophy className="w-5 h-5 text-cyan-400" />
            <h3 className="font-semibold text-white">Achievements</h3>
          </div>
          <button
            onClick={() => setShowAllModal(true)}
            className="text-sm text-cyan-400 hover:underline flex items-center gap-1"
          >
            View All
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>

        {/* Level & XP */}
        <div className="flex items-center gap-4 mb-4 p-3 bg-neutral-800/50 rounded-lg">
          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center">
            <span className="text-lg font-bold text-white">{level}</span>
          </div>
          <div className="flex-1">
            <div className="flex items-center justify-between text-sm mb-1">
              <span className="text-neutral-400">Level {level}</span>
              <span className="text-neutral-500">{currentXp} / {nextLevelXp} XP</span>
            </div>
            <div className="h-2 bg-neutral-700 rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-gradient-to-r from-cyan-500 to-blue-500 rounded-full"
                initial={{ width: 0 }}
                animate={{ width: `${xpProgress}%` }}
                transition={{ duration: 1, ease: 'easeOut' }}
              />
            </div>
          </div>
        </div>

        {/* Recent unlocked */}
        <div className="flex items-center gap-3">
          <span className="text-sm text-neutral-500">Recent:</span>
          <div className="flex items-center gap-2">
            {recentUnlocked.length > 0 ? (
              recentUnlocked.map((achievement) => (
                <AchievementBadge
                  key={achievement.id}
                  achievement={achievement}
                  isUnlocked={true}
                  size="sm"
                />
              ))
            ) : (
              <span className="text-sm text-neutral-500">No achievements yet</span>
            )}
          </div>
          <span className="ml-auto text-sm text-neutral-400">
            {unlockedIds.length} / {ACHIEVEMENTS.length}
          </span>
        </div>

        {/* Modal */}
        <AnimatePresence>
          {showAllModal && (
            <AchievementsModal
              unlockedIds={unlockedIds}
              progress={progress}
              totalXp={totalXp}
              onClose={() => setShowAllModal(false)}
            />
          )}
        </AnimatePresence>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Level Card */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-gradient-to-r from-cyan-500/20 to-blue-600/20 border border-cyan-500/30 rounded-xl p-6"
      >
        <div className="flex items-center gap-6">
          <div className="w-20 h-20 rounded-full bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center shadow-lg shadow-cyan-500/25">
            <span className="text-3xl font-bold text-white">{level}</span>
          </div>
          <div className="flex-1">
            <h3 className="text-xl font-bold text-white mb-1">Level {level}</h3>
            <p className="text-neutral-400 text-sm mb-3">
              {totalXp.toLocaleString()} total XP earned
            </p>
            <div className="flex items-center gap-3">
              <div className="flex-1 h-3 bg-neutral-800 rounded-full overflow-hidden">
                <motion.div
                  className="h-full bg-gradient-to-r from-cyan-500 to-blue-500 rounded-full"
                  initial={{ width: 0 }}
                  animate={{ width: `${xpProgress}%` }}
                  transition={{ duration: 1, ease: 'easeOut' }}
                />
              </div>
              <span className="text-sm text-neutral-400 tabular-nums">
                {currentXp} / {nextLevelXp}
              </span>
            </div>
          </div>
        </div>
      </motion.div>

      {/* Category Filter */}
      <div className="flex flex-wrap gap-2">
        <button
          onClick={() => setSelectedCategory('all')}
          className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all ${
            selectedCategory === 'all'
              ? 'bg-cyan-500/20 text-cyan-400 border border-cyan-500/30'
              : 'bg-neutral-800/50 text-neutral-400 border border-transparent hover:bg-neutral-800'
          }`}
        >
          All ({ACHIEVEMENTS.length})
        </button>
        {(Object.keys(CATEGORY_CONFIG) as AchievementCategory[]).map((cat) => {
          const config = CATEGORY_CONFIG[cat];
          const count = getAchievementsByCategory(cat).length;
          const Icon = config.icon;

          return (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all flex items-center gap-1.5 ${
                selectedCategory === cat
                  ? 'bg-cyan-500/20 text-cyan-400 border border-cyan-500/30'
                  : 'bg-neutral-800/50 text-neutral-400 border border-transparent hover:bg-neutral-800'
              }`}
            >
              <Icon className="w-4 h-4" />
              {config.label} ({count})
            </button>
          );
        })}
      </div>

      {/* Achievements Grid */}
      <div className="grid gap-4 md:grid-cols-2">
        {filteredAchievements.map((achievement) => (
          <AchievementCard
            key={achievement.id}
            achievement={achievement}
            isUnlocked={unlockedIds.includes(achievement.id)}
            progress={progress[achievement.id] || 0}
          />
        ))}
      </div>
    </div>
  );
}

interface AchievementsModalProps {
  unlockedIds: string[];
  progress: Record<string, number>;
  totalXp: number;
  onClose: () => void;
}

function AchievementsModal({ unlockedIds, progress, totalXp, onClose }: AchievementsModalProps) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4"
      onClick={onClose}
    >
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.9, opacity: 0 }}
        className="bg-neutral-900 border border-neutral-800 rounded-2xl max-w-2xl w-full max-h-[80vh] overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="p-6 border-b border-neutral-800 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Trophy className="w-6 h-6 text-cyan-400" />
            <h2 className="text-xl font-bold text-white">Achievements</h2>
          </div>
          <button
            onClick={onClose}
            className="text-neutral-400 hover:text-white transition-colors"
          >
            ✕
          </button>
        </div>
        <div className="p-6 overflow-y-auto max-h-[calc(80vh-80px)]">
          <AchievementsShowcase
            unlockedIds={unlockedIds}
            progress={progress}
            totalXp={totalXp}
            compact={false}
          />
        </div>
      </motion.div>
    </motion.div>
  );
}
