'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Image from 'next/image';
import Link from 'next/link';
import {
  LayoutDashboard,
  User,
  ScanFace,
  Sparkles,
  Settings,
  HelpCircle,
  Menu,
  X,
  ChevronRight,
  Trophy,
  Users,
  Gauge,
  Shapes,
  BookOpen,
  Gift,
  Share2,
  Download,
  ShieldCheck,
} from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { useLeaderboardOptional } from '@/contexts/LeaderboardContext';
import { ResultsTab } from '@/types/results';
import { ScoreCircle, RankBadge } from './shared';
import { api } from '@/lib/api';

// ============================================
// TAB NAVIGATION
// ============================================

interface TabConfig {
  id: ResultsTab;
  label: string;
  icon: React.ReactNode;
}

const TABS: TabConfig[] = [
  { id: 'overview', label: 'Overview', icon: <LayoutDashboard size={16} /> },
  { id: 'front-ratios', label: 'Front Ratios', icon: <User size={16} /> },
  { id: 'side-ratios', label: 'Side Ratios', icon: <ScanFace size={16} /> },
  { id: 'leaderboard', label: 'Leaderboard', icon: <Trophy size={16} /> },
  { id: 'psl', label: 'PSL Rating', icon: <Gauge size={16} /> },
  { id: 'archetype', label: 'Archetype', icon: <Shapes size={16} /> },
  { id: 'plan', label: 'Your Plan', icon: <Sparkles size={16} /> },
  { id: 'guides', label: 'Guides', icon: <BookOpen size={16} /> },
  { id: 'community', label: 'Community', icon: <Users size={16} /> },
  { id: 'referrals', label: 'Referrals', icon: <Gift size={16} /> },
  { id: 'options', label: 'Options', icon: <Settings size={16} /> },
  { id: 'support', label: 'Support', icon: <HelpCircle size={16} /> },
];

// ============================================
// SIDEBAR
// ============================================

interface SidebarProps {
  onClose?: () => void;
}

function Sidebar({ onClose }: SidebarProps) {
  const { activeTab, setActiveTab, overallScore, frontPhoto, pslRating } = useResults();

  return (
    <div className="flex flex-col h-full bg-black border-r border-white/5">
      {/* Header */}
      <div className="flex items-center justify-between p-5 border-b border-white/5">
        <Link href="/" className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-cyan-400 to-blue-600 flex items-center justify-center shadow-lg shadow-cyan-500/20">
            <ShieldCheck size={16} className="text-white" />
          </div>
          <span className="text-xs font-black uppercase tracking-widest text-white">LOOKSMAXX</span>
        </Link>
        {onClose && (
          <button
            onClick={onClose}
            className="p-2 hover:bg-white/5 rounded-xl transition-colors md:hidden"
          >
            <X size={18} className="text-neutral-500" />
          </button>
        )}
      </div>

      {/* Profile Photo & Score */}
      <div className="p-5 border-b border-white/5">
        <div className="relative aspect-square rounded-2xl overflow-hidden bg-neutral-900/50 border border-white/5 mb-5">
          {frontPhoto ? (
            <Image
              src={frontPhoto}
              alt="Your face"
              fill
              className="object-cover"
              unoptimized
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center">
              <User size={48} className="text-neutral-800" />
            </div>
          )}
          {/* Score badge */}
          <div className="absolute bottom-3 right-3">
            <ScoreCircle score={overallScore} size="sm" animate={false} />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-3 mb-4">
          <div className="text-center p-3 rounded-xl bg-neutral-900/30 border border-white/5">
            <p className="text-[9px] font-black uppercase tracking-widest text-neutral-600 mb-1">Harmony</p>
            <p className="text-xl font-black italic text-white">
              {typeof overallScore === 'number' ? overallScore.toFixed(1) : overallScore}
            </p>
          </div>
          <div className="text-center p-3 rounded-xl bg-neutral-900/30 border border-white/5">
            <p className="text-[9px] font-black uppercase tracking-widest text-neutral-600 mb-1">PSL</p>
            <p className="text-xl font-black italic text-cyan-400">
              {pslRating?.psl ? Number(pslRating.psl).toFixed(1) : '-'}
            </p>
          </div>
        </div>

        <div className="text-center">
          <RankBadge size="md" alwaysShow showPercentile />
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-3 overflow-y-auto">
        <div className="space-y-1">
          {TABS.map((tab) => (
            <button
              key={tab.id}
              onClick={() => {
                setActiveTab(tab.id);
                onClose?.();
              }}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${
                activeTab === tab.id
                  ? 'bg-cyan-500/10 text-cyan-400 border border-cyan-500/20'
                  : 'text-neutral-500 hover:bg-white/5 hover:text-white border border-transparent'
              }`}
            >
              {tab.icon}
              <span className="text-xs font-black uppercase tracking-widest">{tab.label}</span>
              {activeTab === tab.id && (
                <ChevronRight size={14} className="ml-auto" />
              )}
            </button>
          ))}
        </div>
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-white/5">
        <button
          onClick={() => window.location.href = '/gender'}
          className="w-full py-3 px-4 bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest rounded-xl hover:bg-cyan-400 transition-all shadow-lg shadow-cyan-500/20"
        >
          New Analysis
        </button>
      </div>
    </div>
  );
}

// ============================================
// FLOATING RANK CARD (Desktop)
// ============================================

function FloatingRankCard() {
  const { setActiveTab } = useResults();
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
    <motion.button
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      onClick={() => setActiveTab('leaderboard')}
      className="flex items-center gap-4 px-5 py-4 bg-neutral-900/90 backdrop-blur-xl border border-white/5 rounded-2xl shadow-2xl hover:border-yellow-500/30 transition-all group"
    >
      {userRank ? (
        <>
          <div className="flex items-center justify-center w-11 h-11 rounded-xl bg-gradient-to-br from-yellow-500/20 to-amber-500/20 border border-yellow-500/30">
            <Trophy size={20} className="text-yellow-400" />
          </div>
          <div className="text-left">
            <p className="text-[9px] font-black uppercase tracking-widest text-neutral-600">Your Rank</p>
            <div className="flex items-baseline gap-2">
              <span className="text-2xl font-black italic text-yellow-400">#{userRank.genderRank}</span>
              <span className="text-[10px] font-black uppercase tracking-widest text-neutral-600">Top {userRank.percentile.toFixed(1)}%</span>
            </div>
          </div>
          <ChevronRight size={16} className="text-neutral-700 group-hover:text-yellow-400 transition-colors ml-1" />
        </>
      ) : (
        <>
          <div className="flex items-center justify-center w-11 h-11 rounded-xl bg-neutral-900 border border-white/10">
            <Trophy size={20} className="text-neutral-600" />
          </div>
          <div className="text-left">
            <p className="text-[9px] font-black uppercase tracking-widest text-neutral-600">Your Rank</p>
            <span className="text-xs font-medium text-neutral-500">
              {isAuthenticated ? 'Not ranked yet' : 'Sign in to rank'}
            </span>
          </div>
          <ChevronRight size={16} className="text-neutral-700 group-hover:text-neutral-500 transition-colors ml-1" />
        </>
      )}
    </motion.button>
  );
}

// ============================================
// MOBILE HEADER
// ============================================

interface MobileHeaderProps {
  onMenuClick: () => void;
}

function MobileHeader({ onMenuClick }: MobileHeaderProps) {
  const { activeTab, overallScore } = useResults();
  const currentTab = TABS.find((t) => t.id === activeTab);

  return (
    <header className="flex items-center justify-between px-4 py-4 bg-black border-b border-white/5">
      <button
        onClick={onMenuClick}
        className="p-2 hover:bg-white/5 rounded-xl transition-colors"
      >
        <Menu size={18} className="text-neutral-500" />
      </button>
      <div className="flex items-center gap-2">
        {currentTab?.icon}
        <span className="text-xs font-black uppercase tracking-widest text-white">{currentTab?.label}</span>
      </div>
      <div className="flex items-center gap-2">
        <RankBadge size="sm" alwaysShow />
        <div className="w-7 h-7 rounded-lg bg-cyan-500/20 flex items-center justify-center">
          <span className="text-[10px] text-cyan-400 font-black">{typeof overallScore === 'number' ? Math.round(overallScore) : overallScore}</span>
        </div>
      </div>
    </header>
  );
}

// ============================================
// MAIN LAYOUT
// ============================================

interface ResultsLayoutProps {
  children: React.ReactNode;
}

export function ResultsLayout({ children }: ResultsLayoutProps) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { activeTab } = useResults();

  return (
    <div className="flex min-h-screen bg-black">
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex md:w-[280px] md:flex-col md:fixed md:inset-y-0 z-40">
        <Sidebar />
      </aside>

      {/* Mobile Menu Overlay */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setMobileMenuOpen(false)}
              className="fixed inset-0 bg-black/80 backdrop-blur-sm z-40 md:hidden"
            />
            <motion.aside
              initial={{ x: -280 }}
              animate={{ x: 0 }}
              exit={{ x: -280 }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed inset-y-0 left-0 w-[280px] z-50 md:hidden"
            >
              <Sidebar onClose={() => setMobileMenuOpen(false)} />
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      {/* Main Content */}
      <div className="flex-1 md:pl-[280px] flex flex-col min-h-screen">
        {/* Mobile Header */}
        <div className="md:hidden">
          <MobileHeader onMenuClick={() => setMobileMenuOpen(true)} />
        </div>

        {/* Desktop Floating Rank Indicator */}
        <div className="hidden md:block fixed top-5 right-5 z-30">
          <FloatingRankCard />
        </div>

        {/* Content Area - no overflow so sticky works */}
        <main className="flex-1">
          <AnimatePresence mode="wait">
            <motion.div
              key={activeTab}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.2 }}
            >
              {children}
            </motion.div>
          </AnimatePresence>
        </main>
      </div>
    </div>
  );
}

// ============================================
// TAB CONTENT WRAPPER
// ============================================

interface TabContentProps {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  rightContent?: React.ReactNode;
  actions?: React.ReactNode;
}

export function TabContent({ title, subtitle, children, rightContent, actions }: TabContentProps) {
  // Split title to highlight last word in cyan
  const titleWords = title.split(' ');
  const lastWord = titleWords.pop();
  const firstWords = titleWords.join(' ');

  return (
    <div className="p-6 md:p-10 lg:p-12 max-w-6xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-start md:justify-between mb-10 md:mb-14">
        <div>
          <h1 className="text-4xl md:text-5xl font-black tracking-tighter italic uppercase mb-3">
            {firstWords} <span className="text-cyan-400">{lastWord}</span>
          </h1>
          {subtitle && (
            <p className="text-neutral-500 font-medium uppercase text-xs tracking-[0.2em] max-w-lg">
              {subtitle}
            </p>
          )}
        </div>
        {(rightContent || actions) && (
          <div className="mt-6 md:mt-0 flex items-center gap-3">
            {actions && (
              <div className="flex items-center gap-2">
                <button className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/5 border border-white/10 text-neutral-400 text-[10px] font-black uppercase tracking-widest hover:bg-white/10 transition-all">
                  <Share2 size={14} />
                  Share
                </button>
                <button className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/5 border border-white/10 text-neutral-400 text-[10px] font-black uppercase tracking-widest hover:bg-white/10 transition-all">
                  <Download size={14} />
                  Export
                </button>
              </div>
            )}
            {rightContent}
          </div>
        )}
      </div>

      {/* Content */}
      {children}
    </div>
  );
}

// ============================================
// SECTION HEADER (For use in tab content)
// ============================================

interface SectionHeaderProps {
  title: string;
  className?: string;
}

export function SectionHeader({ title, className = '' }: SectionHeaderProps) {
  return (
    <h2 className={`text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-8 flex items-center gap-4 ${className}`}>
      {title}
      <div className="flex-1 h-px bg-neutral-900" />
    </h2>
  );
}
