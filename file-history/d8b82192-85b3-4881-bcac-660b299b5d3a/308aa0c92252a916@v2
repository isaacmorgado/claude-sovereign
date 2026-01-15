'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Image from 'next/image';
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
  { id: 'overview', label: 'Overview', icon: <LayoutDashboard size={18} /> },
  { id: 'front-ratios', label: 'Front Ratios', icon: <User size={18} /> },
  { id: 'side-ratios', label: 'Side Ratios', icon: <ScanFace size={18} /> },
  { id: 'leaderboard', label: 'Leaderboard', icon: <Trophy size={18} /> },
  { id: 'psl', label: 'PSL Rating', icon: <Gauge size={18} /> },
  { id: 'archetype', label: 'Archetype', icon: <Shapes size={18} /> },
  { id: 'plan', label: 'Your Plan', icon: <Sparkles size={18} /> },
  { id: 'community', label: 'Community', icon: <Users size={18} /> },
  { id: 'options', label: 'Options', icon: <Settings size={18} /> },
  { id: 'support', label: 'Support', icon: <HelpCircle size={18} /> },
];

// ============================================
// SIDEBAR
// ============================================

interface SidebarProps {
  onClose?: () => void;
}

function Sidebar({ onClose }: SidebarProps) {
  const { activeTab, setActiveTab, overallScore, frontPhoto } = useResults();

  return (
    <div className="flex flex-col h-full bg-neutral-950 border-r border-neutral-800">
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b border-neutral-800">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-cyan-500 to-blue-600 flex items-center justify-center">
            <ScanFace size={18} className="text-white" />
          </div>
          <span className="font-semibold text-white">LOOKSMAXX</span>
        </div>
        {onClose && (
          <button
            onClick={onClose}
            className="p-2 hover:bg-neutral-800 rounded-lg transition-colors md:hidden"
          >
            <X size={20} className="text-neutral-400" />
          </button>
        )}
      </div>

      {/* Profile Photo & Score */}
      <div className="p-4 border-b border-neutral-800">
        <div className="relative aspect-square rounded-xl overflow-hidden bg-neutral-900 mb-3">
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
              <User size={48} className="text-neutral-700" />
            </div>
          )}
          {/* Score badge */}
          <div className="absolute bottom-2 right-2">
            <ScoreCircle score={overallScore} size="sm" animate={false} />
          </div>
        </div>
        <div className="text-center">
          <p className="text-sm text-neutral-400">Harmony Score</p>
          <p className="text-2xl font-bold text-white">{overallScore.toFixed(2)}</p>
          <div className="mt-2">
            <RankBadge size="md" alwaysShow showPercentile />
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-2 overflow-y-auto">
        {TABS.map((tab) => (
          <button
            key={tab.id}
            onClick={() => {
              setActiveTab(tab.id);
              onClose?.();
            }}
            className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg mb-1 transition-all ${
              activeTab === tab.id
                ? 'bg-cyan-500/20 text-cyan-400'
                : 'text-neutral-400 hover:bg-neutral-800 hover:text-white'
            }`}
          >
            {tab.icon}
            <span className="font-medium">{tab.label}</span>
            {activeTab === tab.id && (
              <ChevronRight size={16} className="ml-auto" />
            )}
          </button>
        ))}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-neutral-800">
        <button className="w-full py-2.5 px-4 bg-gradient-to-r from-cyan-500 to-blue-600 text-white font-medium rounded-lg hover:from-cyan-400 hover:to-blue-500 transition-all">
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
      className="flex items-center gap-3 px-4 py-3 bg-neutral-900/95 backdrop-blur-sm border border-neutral-800 rounded-xl shadow-lg hover:border-yellow-500/30 transition-all group"
    >
      {userRank ? (
        <>
          <div className="flex items-center justify-center w-10 h-10 rounded-lg bg-gradient-to-br from-yellow-500/20 to-amber-500/20 border border-yellow-500/30">
            <Trophy size={20} className="text-yellow-400" />
          </div>
          <div className="text-left">
            <p className="text-xs text-neutral-500 uppercase tracking-wide">Your Rank</p>
            <div className="flex items-baseline gap-2">
              <span className="text-xl font-bold text-yellow-400">#{userRank.genderRank}</span>
              <span className="text-xs text-neutral-500">Top {userRank.percentile.toFixed(1)}%</span>
            </div>
          </div>
          <ChevronRight size={16} className="text-neutral-600 group-hover:text-yellow-400 transition-colors ml-1" />
        </>
      ) : (
        <>
          <div className="flex items-center justify-center w-10 h-10 rounded-lg bg-neutral-800 border border-neutral-700">
            <Trophy size={20} className="text-neutral-500" />
          </div>
          <div className="text-left">
            <p className="text-xs text-neutral-500 uppercase tracking-wide">Your Rank</p>
            <span className="text-sm text-neutral-400">
              {isAuthenticated ? 'Not ranked yet' : 'Sign in to rank'}
            </span>
          </div>
          <ChevronRight size={16} className="text-neutral-600 group-hover:text-neutral-400 transition-colors ml-1" />
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
    <header className="flex items-center justify-between px-4 py-3 bg-neutral-950 border-b border-neutral-800">
      <button
        onClick={onMenuClick}
        className="p-2 hover:bg-neutral-800 rounded-lg transition-colors"
      >
        <Menu size={20} className="text-neutral-400" />
      </button>
      <div className="flex items-center gap-2">
        {currentTab?.icon}
        <span className="font-medium text-white">{currentTab?.label}</span>
      </div>
      <div className="flex items-center gap-2">
        <RankBadge size="sm" alwaysShow />
        <div className="w-6 h-6 rounded-full bg-cyan-500/20 flex items-center justify-center">
          <span className="text-xs text-cyan-400 font-bold">{Math.round(overallScore)}</span>
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
              className="fixed inset-0 bg-black/60 z-40 md:hidden"
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
        <div className="hidden md:block fixed top-4 right-4 z-30">
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
}

export function TabContent({ title, subtitle, children, rightContent }: TabContentProps) {
  return (
    <div className="p-4 md:p-6 lg:p-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-6">
        <div>
          <h1 className="text-2xl md:text-3xl font-bold text-white">{title}</h1>
          {subtitle && (
            <p className="text-neutral-400 mt-1">{subtitle}</p>
          )}
        </div>
        {rightContent && (
          <div className="mt-4 md:mt-0">{rightContent}</div>
        )}
      </div>

      {/* Content */}
      {children}
    </div>
  );
}
