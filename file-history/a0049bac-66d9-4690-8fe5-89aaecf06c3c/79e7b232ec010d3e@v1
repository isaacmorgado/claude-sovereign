'use client';

import { motion } from 'framer-motion';
import { Lock } from 'lucide-react';
import { Achievement, TIER_COLORS } from '@/types/achievements';

interface AchievementBadgeProps {
  achievement: Achievement;
  isUnlocked: boolean;
  progress?: number;
  size?: 'sm' | 'md' | 'lg';
  showProgress?: boolean;
  onClick?: () => void;
}

export function AchievementBadge({
  achievement,
  isUnlocked,
  progress = 0,
  size = 'md',
  showProgress = false,
  onClick,
}: AchievementBadgeProps) {
  const tierColors = TIER_COLORS[achievement.tier];

  const sizeClasses = {
    sm: 'w-12 h-12 text-lg',
    md: 'w-16 h-16 text-2xl',
    lg: 'w-20 h-20 text-3xl',
  };

  const progressPercent = Math.min(100, (progress / achievement.requirement.target) * 100);

  return (
    <motion.button
      onClick={onClick}
      className={`
        relative rounded-xl border-2 flex items-center justify-center
        ${sizeClasses[size]}
        ${isUnlocked ? tierColors.bg : 'bg-neutral-900/50'}
        ${isUnlocked ? tierColors.border : 'border-neutral-800'}
        ${isUnlocked ? `shadow-lg ${tierColors.glow}` : ''}
        ${onClick ? 'cursor-pointer hover:scale-105 transition-transform' : 'cursor-default'}
      `}
      whileHover={onClick ? { scale: 1.05 } : {}}
      whileTap={onClick ? { scale: 0.95 } : {}}
      title={`${achievement.name}${isUnlocked ? '' : ' (Locked)'}`}
    >
      {isUnlocked ? (
        <span className="relative z-10">{achievement.icon}</span>
      ) : (
        <Lock className="w-5 h-5 text-neutral-600" />
      )}

      {/* Progress ring for locked achievements */}
      {!isUnlocked && showProgress && progressPercent > 0 && (
        <svg
          className="absolute inset-0 w-full h-full -rotate-90"
          viewBox="0 0 100 100"
        >
          <circle
            cx="50"
            cy="50"
            r="46"
            fill="none"
            stroke="currentColor"
            strokeWidth="4"
            className="text-neutral-800"
          />
          <circle
            cx="50"
            cy="50"
            r="46"
            fill="none"
            stroke="currentColor"
            strokeWidth="4"
            strokeDasharray={`${progressPercent * 2.89} 289`}
            className="text-cyan-500"
          />
        </svg>
      )}

      {/* Tier indicator dot */}
      {isUnlocked && (
        <div
          className={`absolute -bottom-1 -right-1 w-3 h-3 rounded-full border border-black ${
            achievement.tier === 'bronze'
              ? 'bg-amber-700'
              : achievement.tier === 'silver'
              ? 'bg-slate-400'
              : achievement.tier === 'gold'
              ? 'bg-yellow-400'
              : 'bg-cyan-400'
          }`}
        />
      )}
    </motion.button>
  );
}

interface AchievementCardProps {
  achievement: Achievement;
  isUnlocked: boolean;
  progress?: number;
}

export function AchievementCard({ achievement, isUnlocked, progress = 0 }: AchievementCardProps) {
  const tierColors = TIER_COLORS[achievement.tier];
  const progressPercent = Math.min(100, (progress / achievement.requirement.target) * 100);

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      className={`
        p-4 rounded-xl border-2 transition-all
        ${isUnlocked ? tierColors.bg : 'bg-neutral-900/50'}
        ${isUnlocked ? tierColors.border : 'border-neutral-800'}
        ${isUnlocked ? `shadow-lg ${tierColors.glow}` : ''}
      `}
    >
      <div className="flex items-center gap-4">
        <AchievementBadge achievement={achievement} isUnlocked={isUnlocked} size="md" />

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <h4 className={`font-semibold truncate ${isUnlocked ? 'text-white' : 'text-neutral-400'}`}>
              {achievement.name}
            </h4>
            <span
              className={`text-xs px-1.5 py-0.5 rounded capitalize ${
                isUnlocked ? tierColors.bg : 'bg-neutral-800'
              } ${isUnlocked ? tierColors.text : 'text-neutral-500'}`}
            >
              {achievement.tier}
            </span>
          </div>
          <p className={`text-sm ${isUnlocked ? 'text-neutral-300' : 'text-neutral-500'}`}>
            {achievement.description}
          </p>

          {/* Progress bar for locked achievements */}
          {!isUnlocked && (
            <div className="mt-2">
              <div className="flex items-center justify-between text-xs text-neutral-500 mb-1">
                <span>Progress</span>
                <span>
                  {progress} / {achievement.requirement.target}
                </span>
              </div>
              <div className="h-1.5 bg-neutral-800 rounded-full overflow-hidden">
                <div
                  className="h-full bg-cyan-500 rounded-full transition-all duration-500"
                  style={{ width: `${progressPercent}%` }}
                />
              </div>
            </div>
          )}

          {/* XP reward */}
          {isUnlocked && (
            <p className="text-xs text-cyan-400 mt-1">+{achievement.xpReward} XP</p>
          )}
        </div>
      </div>
    </motion.div>
  );
}
