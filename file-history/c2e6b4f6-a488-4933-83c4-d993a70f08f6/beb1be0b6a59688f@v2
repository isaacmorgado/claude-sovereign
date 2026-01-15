'use client';

import { useState } from 'react';
import { ChevronUp, ChevronDown, LogIn } from 'lucide-react';
import { VoteType } from '@/types/forum';
import { useAuth } from '@/contexts/AuthContext';
import Link from 'next/link';

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
  const [showLoginPrompt, setShowLoginPrompt] = useState(false);
  const { isAuthenticated } = useAuth();
  const iconSize = size === 'sm' ? 16 : 20;
  const buttonPadding = size === 'sm' ? 'p-1' : 'p-1.5';

  const handleVote = async (voteType: VoteType) => {
    if (isVoting) return;

    // Show login prompt if not authenticated
    if (!isAuthenticated) {
      setShowLoginPrompt(true);
      return;
    }

    setIsVoting(true);
    try {
      await onVote(voteType);
    } catch (error) {
      // Handle auth errors specifically
      if (error instanceof Error && error.message.includes('Not authenticated')) {
        setShowLoginPrompt(true);
      }
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
    <div className="relative">
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
          title={isAuthenticated ? 'Upvote' : 'Login to vote'}
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
          title={isAuthenticated ? 'Downvote' : 'Login to vote'}
          aria-label="Downvote"
        >
          <ChevronDown size={iconSize} strokeWidth={userVote === 'down' ? 3 : 2} />
        </button>
      </div>

      {/* Login Prompt Popup */}
      {showLoginPrompt && (
        <div className="absolute left-full ml-2 top-1/2 -translate-y-1/2 z-50 bg-neutral-900 border border-neutral-800 rounded-xl p-3 shadow-xl min-w-[180px]">
          <button
            onClick={() => setShowLoginPrompt(false)}
            className="absolute top-1 right-1 text-neutral-600 hover:text-neutral-400 text-xs"
            aria-label="Close"
          >
            ×
          </button>
          <div className="flex items-center gap-2 mb-2">
            <LogIn size={14} className="text-cyan-400" />
            <span className="text-xs font-bold text-white">Login to vote</span>
          </div>
          <p className="text-[10px] text-neutral-500 mb-3">
            Join the community to upvote and downvote posts.
          </p>
          <div className="flex gap-2">
            <Link
              href="/login"
              className="flex-1 text-center text-[10px] font-bold bg-cyan-500 hover:bg-cyan-600 text-black px-2 py-1.5 rounded-lg transition-colors"
            >
              Login
            </Link>
            <Link
              href="/signup"
              className="flex-1 text-center text-[10px] font-bold border border-neutral-700 hover:border-neutral-600 text-white px-2 py-1.5 rounded-lg transition-colors"
            >
              Sign Up
            </Link>
          </div>
        </div>
      )}
    </div>
  );
}
