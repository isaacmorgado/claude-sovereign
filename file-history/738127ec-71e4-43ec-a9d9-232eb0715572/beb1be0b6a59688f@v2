'use client';

import { useState } from 'react';
import { VoteType } from '@/types/forum';

interface VoteButtonsProps {
  voteCount: number;
  userVote: VoteType | null;
  onVote: (voteType: VoteType) => void | Promise<void>;
  size?: 'sm' | 'md';
  horizontal?: boolean;
}

export function VoteButtons({
  voteCount,
  userVote,
  onVote,
  size = 'md',
  horizontal = false,
}: VoteButtonsProps) {
  const [isVoting, setIsVoting] = useState(false);
  const iconSize = size === 'sm' ? 'w-5 h-5' : 'w-6 h-6';
  const buttonPadding = size === 'sm' ? 'p-1' : 'p-1.5';

  const handleVote = async (voteType: VoteType) => {
    if (isVoting) return;
    setIsVoting(true);
    try {
      await onVote(voteType);
    } finally {
      setIsVoting(false);
    }
  };

  const formatCount = (count: number) => {
    if (count >= 1000) {
      return (count / 1000).toFixed(1).replace(/\.0$/, '') + 'k';
    }
    return count.toString();
  };

  return (
    <div
      className={`flex items-center ${
        horizontal ? 'flex-row gap-1' : 'flex-col'
      } ${isVoting ? 'opacity-50 pointer-events-none' : ''}`}
    >
      <button
        onClick={() => handleVote('up')}
        disabled={isVoting}
        className={`${buttonPadding} rounded-sm hover:bg-white/10 transition-colors ${
          userVote === 'up' ? 'text-[#00f3ff]' : 'text-[#818384] hover:text-[#00f3ff]'
        } disabled:cursor-not-allowed`}
        title="Upvote"
        aria-label="Upvote"
      >
        <UpvoteIcon className={iconSize} filled={userVote === 'up'} />
      </button>

      <span
        className={`text-xs font-bold min-w-[2ch] text-center ${
          userVote === 'up'
            ? 'text-[#00f3ff]'
            : userVote === 'down'
            ? 'text-neutral-500'
            : 'text-[#d7dadc]'
        }`}
      >
        {formatCount(voteCount)}
      </span>

      <button
        onClick={() => handleVote('down')}
        disabled={isVoting}
        className={`${buttonPadding} rounded-sm hover:bg-white/10 transition-colors ${
          userVote === 'down' ? 'text-neutral-500' : 'text-[#818384] hover:text-neutral-500'
        } disabled:cursor-not-allowed`}
        title="Downvote"
        aria-label="Downvote"
      >
        <DownvoteIcon className={iconSize} filled={userVote === 'down'} />
      </button>
    </div>
  );
}

function UpvoteIcon({ className, filled }: { className?: string; filled?: boolean }) {
  if (filled) {
    return (
      <svg className={className} viewBox="0 0 20 20" fill="currentColor">
        <path d="M10 3l-7 7h4v7h6v-7h4l-7-7z" />
      </svg>
    );
  }
  return (
    <svg className={className} viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth={1.5}>
      <path d="M10 3l-7 7h4v7h6v-7h4l-7-7z" strokeLinejoin="round" />
    </svg>
  );
}

function DownvoteIcon({ className, filled }: { className?: string; filled?: boolean }) {
  if (filled) {
    return (
      <svg className={className} viewBox="0 0 20 20" fill="currentColor">
        <path d="M10 17l7-7h-4V3H7v7H3l7 7z" />
      </svg>
    );
  }
  return (
    <svg className={className} viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth={1.5}>
      <path d="M10 17l7-7h-4V3H7v7H3l7 7z" strokeLinejoin="round" />
    </svg>
  );
}
