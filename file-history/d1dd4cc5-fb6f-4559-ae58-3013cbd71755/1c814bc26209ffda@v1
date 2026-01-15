'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import { Trophy, ShieldCheck, ArrowLeft } from 'lucide-react';
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
    <header className="sticky top-0 z-50 bg-black/95 backdrop-blur-xl border-b border-white/5">
      <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
        <div className="flex items-center gap-6">
          <Link href="/" className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-cyan-400 to-blue-600 flex items-center justify-center shadow-lg shadow-cyan-500/20">
              <ShieldCheck size={18} className="text-white" />
            </div>
            <span className="text-xs font-black uppercase tracking-widest text-white hidden sm:block">LOOKSMAXX</span>
          </Link>
          <div className="h-6 w-px bg-white/10 hidden sm:block" />
          <Link
            href="/forum"
            className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500 hover:text-cyan-400 transition-colors hidden sm:flex items-center gap-2"
          >
            Community
          </Link>
        </div>

        <div className="flex items-center gap-4">
          {/* Rank Badge */}
          <Link
            href="/results?tab=leaderboard"
            className="flex items-center gap-3 px-4 py-2 rounded-xl bg-neutral-900/50 border border-white/5 hover:border-cyan-500/30 transition-all"
          >
            {userRank ? (
              <>
                <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-gradient-to-br from-yellow-500/20 to-amber-500/20 border border-yellow-500/30">
                  <Trophy size={14} className="text-yellow-400" />
                </div>
                <div className="hidden sm:block">
                  <p className="text-[9px] font-black uppercase tracking-widest text-neutral-600">Your Rank</p>
                  <div className="flex items-baseline gap-2">
                    <span className="text-sm font-black italic text-yellow-400">#{userRank.genderRank}</span>
                    <span className="text-[10px] text-neutral-600">Top {userRank.percentile.toFixed(1)}%</span>
                  </div>
                </div>
                <span className="sm:hidden text-sm font-black italic text-yellow-400">#{userRank.genderRank}</span>
              </>
            ) : (
              <>
                <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-neutral-900 border border-white/10">
                  <Trophy size={14} className="text-neutral-600" />
                </div>
                <span className="text-[10px] font-black uppercase tracking-widest text-neutral-600 hidden sm:block">
                  {isAuthenticated ? 'Not Ranked' : 'Sign In'}
                </span>
              </>
            )}
          </Link>

          {isAuthenticated ? (
            <Link
              href="/results"
              className="h-10 px-5 rounded-xl bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest flex items-center gap-2 hover:bg-cyan-400 transition-all shadow-lg shadow-cyan-500/20"
            >
              Dashboard
            </Link>
          ) : (
            <Link
              href="/login"
              className="h-10 px-5 rounded-xl bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest flex items-center gap-2 hover:bg-cyan-400 transition-all shadow-lg shadow-cyan-500/20"
            >
              Get Started
            </Link>
          )}
        </div>
      </div>
    </header>
  );
}

interface ForumBreadcrumbProps {
  items: { label: string; href?: string }[];
}

export function ForumBreadcrumb({ items }: ForumBreadcrumbProps) {
  return (
    <div className="border-b border-white/5">
      <div className="max-w-6xl mx-auto px-6 py-5">
        <div className="flex items-center gap-3">
          {items.map((item, idx) => (
            <div key={idx} className="flex items-center gap-3">
              {idx === 0 && (
                <ArrowLeft size={14} className="text-neutral-600" />
              )}
              {item.href ? (
                <Link
                  href={item.href}
                  className="text-[10px] font-black uppercase tracking-[0.2em] text-cyan-400 hover:text-cyan-300 transition-colors"
                >
                  {item.label}
                </Link>
              ) : (
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500">
                  {item.label}
                </span>
              )}
              {idx < items.length - 1 && (
                <span className="text-neutral-700">/</span>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
