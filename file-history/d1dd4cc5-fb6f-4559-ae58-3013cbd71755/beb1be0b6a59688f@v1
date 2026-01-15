'use client';

import { useState } from 'react';
import { ChevronUp, ChevronDown } from 'lucide-react';
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
  const iconSize = size === 'sm' ? 16 : 20;
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
        className={`${buttonPadding} rounded-lg hover:bg-cyan-500/10 transition-all ${
          userVote === 'up' ? 'text-cyan-400 bg-cyan-500/10' : 'text-neutral-600 hover:text-cyan-400'
        } disabled:cursor-not-allowed`}
        title="Upvote"
        aria-label="Upvote"
      >
        <ChevronUp size={iconSize} strokeWidth={userVote === 'up' ? 3 : 2} />
      </button>

      <span
        className={`text-xs font-black min-w-[2ch] text-center ${
          userVote === 'up'
            ? 'text-cyan-400'
            : userVote === 'down'
            ? 'text-neutral-600'
            : 'text-neutral-400'
        }`}
      >
        {formatCount(voteCount)}
      </span>

      <button
        onClick={() => handleVote('down')}
        disabled={isVoting}
        className={`${buttonPadding} rounded-lg hover:bg-neutral-900 transition-all ${
          userVote === 'down' ? 'text-neutral-500 bg-neutral-900' : 'text-neutral-600 hover:text-neutral-400'
        } disabled:cursor-not-allowed`}
        title="Downvote"
        aria-label="Downvote"
      >
        <ChevronDown size={iconSize} strokeWidth={userVote === 'down' ? 3 : 2} />
      </button>
    </div>
  );
}
