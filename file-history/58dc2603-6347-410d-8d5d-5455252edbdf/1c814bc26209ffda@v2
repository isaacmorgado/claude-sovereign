'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import { Trophy } from 'lucide-react';
import { useLeaderboardOptional } from '@/contexts/LeaderboardContext';
import { api } from '@/lib/api';

export function ForumHeader() {
  const leaderboard = useLeaderboardOptional();
  const userRank = leaderboard?.userRank;
  const isAuthenticated = !!api.getToken();

  // Auto-fetch user's rank on mount if authenticated
  useEffect(() => {
    if (isAuthenticated && !userRank && leaderboard?.fetchMyRank) {
      leaderboard.fetchMyRank();
    }
  }, [isAuthenticated, userRank, leaderboard]);

  return (
    <header className="sticky top-0 z-50 bg-black/90 backdrop-blur-sm border-b border-neutral-800">
      <div className="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link href="/" className="flex items-center gap-2">
            <div className="h-8 w-8 rounded bg-[#00f3ff]/20 flex items-center justify-center">
              <span className="text-[#00f3ff] text-sm font-bold">L</span>
            </div>
            <span className="text-lg font-semibold text-white hidden sm:block">LOOKSMAXX</span>
          </Link>
          <div className="h-5 w-px bg-neutral-700 hidden sm:block" />
          <span className="text-neutral-400 text-sm hidden sm:block">Community</span>
        </div>

        <div className="flex items-center gap-3">
          {/* Rank Badge */}
          <Link
            href="/results?tab=leaderboard"
            className="flex items-center gap-2 px-3 py-1.5 rounded-lg transition-all hover:bg-neutral-800"
          >
            {userRank ? (
              <>
                <div className="flex items-center justify-center w-6 h-6 rounded bg-gradient-to-br from-yellow-500/20 to-amber-500/20 border border-yellow-500/30">
                  <Trophy size={14} className="text-yellow-400" />
                </div>
                <div className="hidden sm:flex items-baseline gap-1.5">
                  <span className="text-sm font-semibold text-yellow-400">#{userRank.genderRank}</span>
                  <span className="text-xs text-neutral-500">Top {userRank.percentile.toFixed(1)}%</span>
                </div>
                <span className="sm:hidden text-sm font-semibold text-yellow-400">#{userRank.genderRank}</span>
              </>
            ) : (
              <>
                <div className="flex items-center justify-center w-6 h-6 rounded bg-neutral-800 border border-neutral-700">
                  <Trophy size={14} className="text-neutral-500" />
                </div>
                <span className="text-xs text-neutral-500 hidden sm:block">
                  {isAuthenticated ? 'Not ranked' : 'Sign in'}
                </span>
              </>
            )}
          </Link>

          <Link
            href="/results"
            className="text-sm text-neutral-400 hover:text-white transition-colors hidden sm:block"
          >
            My Results
          </Link>

          {isAuthenticated ? (
            <Link
              href="/results"
              className="h-9 px-4 rounded-lg bg-[#00f3ff] text-black text-sm font-medium flex items-center gap-2 hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] transition-all"
            >
              Dashboard
            </Link>
          ) : (
            <Link
              href="/login"
              className="h-9 px-4 rounded-lg bg-[#00f3ff] text-black text-sm font-medium flex items-center gap-2 hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] transition-all"
            >
              Get Started
            </Link>
          )}
        </div>
      </div>
    </header>
  );
}
