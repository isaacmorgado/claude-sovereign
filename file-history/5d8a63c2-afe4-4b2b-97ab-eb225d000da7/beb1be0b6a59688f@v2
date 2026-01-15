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
  const iconSize = size === 'sm' ? 'w-4 h-4' : 'w-5 h-5';
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

  return (
    <div
      className={`flex items-center gap-1 ${
        horizontal ? 'flex-row' : 'flex-col'
      } ${isVoting ? 'opacity-50 pointer-events-none' : ''}`}
    >
      <button
        onClick={() => handleVote('up')}
        disabled={isVoting}
        className={`${buttonPadding} rounded hover:bg-neutral-800 transition-colors ${
          userVote === 'up' ? 'text-[#00f3ff]' : 'text-neutral-500 hover:text-neutral-300'
        } disabled:cursor-not-allowed`}
        title="Upvote"
      >
        <UpvoteIcon className={iconSize} filled={userVote === 'up'} />
      </button>

      <span
        className={`text-sm font-medium ${
          userVote === 'up'
            ? 'text-[#00f3ff]'
            : userVote === 'down'
            ? 'text-red-400'
            : 'text-neutral-400'
        }`}
      >
        {voteCount}
      </span>

      <button
        onClick={() => handleVote('down')}
        disabled={isVoting}
        className={`${buttonPadding} rounded hover:bg-neutral-800 transition-colors ${
          userVote === 'down' ? 'text-red-400' : 'text-neutral-500 hover:text-neutral-300'
        } disabled:cursor-not-allowed`}
        title="Downvote"
      >
        <DownvoteIcon className={iconSize} filled={userVote === 'down'} />
      </button>
    </div>
  );
}

function UpvoteIcon({ className, filled }: { className?: string; filled?: boolean }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill={filled ? 'currentColor' : 'none'} stroke="currentColor">
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={1.5}
        d="M5 15l7-7 7 7"
      />
    </svg>
  );
}

function DownvoteIcon({ className, filled }: { className?: string; filled?: boolean }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill={filled ? 'currentColor' : 'none'} stroke="currentColor">
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={1.5}
        d="M19 9l-7 7-7-7"
      />
    </svg>
  );
}
