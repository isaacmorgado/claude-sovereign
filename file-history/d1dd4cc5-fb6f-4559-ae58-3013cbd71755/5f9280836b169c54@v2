'use client';

import { useEffect, useRef } from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { useForum } from '@/contexts/ForumContext';
import { ForumHeader } from '@/components/forum';
import {
  ArrowRight,
  Users,
  MessageSquare,
  Flame,
  Clock,
  Star,
  Zap,
  ChevronRight,
  BookOpen,
  ShieldCheck
} from 'lucide-react';

// ============================================
// SECTION HEADER
// ============================================
function SectionHeader({ title }: { title: string }) {
  return (
    <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-8 flex items-center gap-4">
      {title}
      <div className="flex-1 h-px bg-neutral-900" />
    </h2>
  );
}

// ============================================
// STAT CARD
// ============================================
function StatCard({ value, label, icon: Icon }: {
  value: number;
  label: string;
  icon: React.ElementType;
}) {
  return (
    <div className="p-5 rounded-2xl bg-neutral-900/30 border border-white/5 text-center">
      <div className="w-10 h-10 rounded-xl bg-cyan-500/10 flex items-center justify-center mx-auto mb-3">
        <Icon size={18} className="text-cyan-400" />
      </div>
      <p className="text-2xl font-black italic text-white mb-1">{value}</p>
      <p className="text-[9px] font-black uppercase tracking-widest text-neutral-600">{label}</p>
    </div>
  );
}

// ============================================
// CATEGORY CARD
// ============================================
function CategoryCard({ category, index }: {
  category: {
    id: string;
    slug: string;
    name: string;
    description: string | null;
    icon: string | null;
    postCount: number;
    subForums: { id: string; name: string; slug: string; postCount: number }[];
  };
  index: number;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
    >
      <Link href={`/forum/${category.slug}`}>
        <div className="group h-full p-6 rounded-2xl bg-neutral-900/30 border border-white/5 hover:border-cyan-500/20 transition-all">
          <div className="flex items-start gap-4">
            {/* Icon */}
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-500/20 to-blue-500/20 border border-white/5 flex items-center justify-center text-xl flex-shrink-0">
              {category.icon || '💬'}
            </div>

            {/* Content */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-3 mb-2">
                <h3 className="text-sm font-black uppercase tracking-wider text-white group-hover:text-cyan-400 transition-colors truncate">
                  {category.name}
                </h3>
                <ChevronRight size={14} className="text-neutral-700 group-hover:text-cyan-400 transition-colors" />
              </div>
              <p className="text-[11px] text-neutral-500 line-clamp-2 mb-4 leading-relaxed">
                {category.description || 'No description available'}
              </p>

              {/* Sub-forums as tags */}
              <div className="flex flex-wrap gap-2">
                {category.subForums.slice(0, 3).map((sf) => (
                  <span
                    key={sf.id}
                    className="px-2 py-1 text-[9px] font-black uppercase tracking-wider bg-neutral-900/50 border border-white/5 text-neutral-500 rounded-md"
                  >
                    {sf.name}
                  </span>
                ))}
                {category.subForums.length > 3 && (
                  <span className="px-2 py-1 text-[9px] text-neutral-600">
                    +{category.subForums.length - 3} more
                  </span>
                )}
              </div>
            </div>

            {/* Stats */}
            <div className="text-right flex-shrink-0">
              <p className="text-lg font-black italic text-white">{category.postCount}</p>
              <p className="text-[9px] font-black uppercase tracking-widest text-neutral-600">Posts</p>
            </div>
          </div>
        </div>
      </Link>
    </motion.div>
  );
}

// ============================================
// FILTER TABS
// ============================================
function FilterTabs({
  activeFilter,
  setActiveFilter
}: {
  activeFilter: 'all' | 'trending' | 'new';
  setActiveFilter: (filter: 'all' | 'trending' | 'new') => void;
}) {
  const filters = [
    { id: 'all', label: 'All', icon: Star },
    { id: 'trending', label: 'Trending', icon: Flame },
    { id: 'new', label: 'Recent', icon: Clock },
  ] as const;

  return (
    <div className="flex items-center gap-1 p-1.5 bg-neutral-900/30 border border-white/5 rounded-xl w-fit">
      {filters.map((filter) => (
        <button
          key={filter.id}
          onClick={() => setActiveFilter(filter.id)}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-[10px] font-black uppercase tracking-widest transition-all ${
            activeFilter === filter.id
              ? 'bg-cyan-500/10 text-cyan-400 border border-cyan-500/20'
              : 'text-neutral-600 hover:text-white border border-transparent'
          }`}
        >
          <filter.icon size={12} />
          {filter.label}
        </button>
      ))}
    </div>
  );
}

// ============================================
// LOADING SKELETON
// ============================================
function CategorySkeleton() {
  return (
    <div className="p-6 rounded-2xl bg-neutral-900/30 border border-white/5 animate-pulse">
      <div className="flex items-start gap-4">
        <div className="w-12 h-12 rounded-xl bg-neutral-800" />
        <div className="flex-1 space-y-3">
          <div className="h-4 w-1/3 bg-neutral-800 rounded" />
          <div className="h-3 w-2/3 bg-neutral-800 rounded" />
          <div className="flex gap-2">
            <div className="h-6 w-16 bg-neutral-800 rounded" />
            <div className="h-6 w-20 bg-neutral-800 rounded" />
          </div>
        </div>
        <div className="text-right space-y-2">
          <div className="h-5 w-8 bg-neutral-800 rounded ml-auto" />
          <div className="h-3 w-10 bg-neutral-800 rounded ml-auto" />
        </div>
      </div>
    </div>
  );
}

// ============================================
// MAIN PAGE
// ============================================
export default function ForumPage() {
  const { categories, isLoadingCategories, fetchCategories, error } = useForum();
  const [activeFilter, setActiveFilter] = React.useState<'all' | 'trending' | 'new'>('all');
  const hasFetchedRef = useRef(false);

  useEffect(() => {
    if (!hasFetchedRef.current) {
      hasFetchedRef.current = true;
      fetchCategories();
    }
  }, [fetchCategories]);

  // Sort categories based on filter
  const sortedCategories = [...categories].sort((a, b) => {
    if (activeFilter === 'trending') return b.postCount - a.postCount;
    if (activeFilter === 'new') return 0;
    return a.displayOrder - b.displayOrder;
  });

  const totalPosts = categories.reduce((sum, c) => sum + c.postCount, 0);
  const totalTopics = categories.reduce((sum, c) => sum + c.subForums.length, 0);

  return (
    <div className="min-h-screen bg-black selection:bg-cyan-500/30">
      <ForumHeader />

      {/* Hero */}
      <section className="border-b border-white/5">
        <div className="max-w-6xl mx-auto px-6 pt-16 pb-12">
          <div className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-8">
            <div>
              <h1 className="text-5xl md:text-6xl font-black tracking-tighter italic uppercase mb-4">
                Community <span className="text-cyan-400">Hub</span>
              </h1>
              <p className="text-neutral-500 font-medium uppercase text-xs tracking-[0.2em] max-w-lg mb-6">
                Connect with others, share experiences, and discover evidence-based treatments
              </p>
              <div className="flex flex-wrap gap-3">
                <Link
                  href="/signup"
                  className="h-11 px-6 rounded-xl bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest flex items-center gap-2 hover:bg-cyan-400 transition-all shadow-lg shadow-cyan-500/20"
                >
                  Join Community <ArrowRight size={14} />
                </Link>
                <Link
                  href="/upload"
                  className="h-11 px-6 rounded-xl bg-neutral-900/50 border border-white/10 text-white text-[10px] font-black uppercase tracking-widest flex items-center gap-2 hover:border-white/20 transition-all"
                >
                  <Zap size={14} className="text-cyan-400" /> Get Matched
                </Link>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-4">
              <StatCard value={categories.length} label="Communities" icon={Users} />
              <StatCard value={totalPosts} label="Discussions" icon={MessageSquare} />
              <StatCard value={totalTopics} label="Topics" icon={BookOpen} />
            </div>
          </div>
        </div>
      </section>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-6 py-12">
        <div className="flex flex-col lg:flex-row gap-10">
          {/* Communities List */}
          <div className="flex-1">
            {/* Filter + Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
              <SectionHeader title="Communities" />
              <FilterTabs activeFilter={activeFilter} setActiveFilter={setActiveFilter} />
            </div>

            {/* Error State */}
            {error && (
              <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/20 mb-6">
                <p className="text-red-400 text-sm">{error}</p>
              </div>
            )}

            {/* Loading State */}
            {isLoadingCategories && categories.length === 0 && (
              <div className="space-y-4">
                {[1, 2, 3, 4, 5].map((i) => (
                  <CategorySkeleton key={i} />
                ))}
              </div>
            )}

            {/* Categories Grid */}
            {!isLoadingCategories && sortedCategories.length > 0 && (
              <div className="space-y-4">
                {sortedCategories.map((category, index) => (
                  <CategoryCard key={category.id} category={category} index={index} />
                ))}
              </div>
            )}

            {/* Empty State */}
            {!isLoadingCategories && categories.length === 0 && !error && (
              <div className="text-center py-16 rounded-2xl bg-neutral-900/30 border border-white/5">
                <div className="w-14 h-14 rounded-2xl bg-neutral-900/50 flex items-center justify-center mx-auto mb-4">
                  <MessageSquare size={24} className="text-neutral-600" />
                </div>
                <p className="text-neutral-400 text-sm mb-4">No communities available yet.</p>
                <Link href="/signup" className="text-cyan-400 text-sm hover:text-cyan-300">
                  Be the first to start a discussion →
                </Link>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <aside className="lg:w-80 space-y-6">
            {/* CTA Card */}
            <div className="p-6 rounded-2xl bg-gradient-to-br from-cyan-500/10 to-blue-500/10 border border-cyan-500/20">
              <div className="w-10 h-10 rounded-xl bg-cyan-500/20 flex items-center justify-center mb-4">
                <Zap size={18} className="text-cyan-400" />
              </div>
              <h3 className="text-sm font-black uppercase tracking-wider text-white mb-2">Get Matched</h3>
              <p className="text-[11px] text-neutral-400 mb-4 leading-relaxed">
                AI face analysis to find your best communities based on your unique features.
              </p>
              <Link
                href="/upload"
                className="block w-full py-3 bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest rounded-xl text-center hover:bg-cyan-400 transition-all"
              >
                Start Free Analysis
              </Link>
            </div>

            {/* Popular Topics */}
            <div className="p-6 rounded-2xl bg-neutral-900/30 border border-white/5">
              <div className="flex items-center gap-2 mb-6">
                <Flame size={14} className="text-orange-400" />
                <h3 className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500">Popular Topics</h3>
              </div>
              <div className="space-y-3">
                {categories.slice(0, 5).flatMap(c => c.subForums.slice(0, 1)).slice(0, 5).map((sf, i) => (
                  <div key={sf.id} className="flex items-center gap-3 group cursor-pointer">
                    <span className="w-5 h-5 rounded-md bg-neutral-900 border border-white/5 flex items-center justify-center text-[10px] text-neutral-600 font-black">
                      {i + 1}
                    </span>
                    <span className="text-xs text-neutral-400 group-hover:text-cyan-400 transition-colors truncate">
                      {sf.name}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Guidelines */}
            <div className="p-6 rounded-2xl bg-neutral-900/30 border border-white/5">
              <div className="flex items-center gap-2 mb-6">
                <ShieldCheck size={14} className="text-cyan-400" />
                <h3 className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500">Guidelines</h3>
              </div>
              <ul className="space-y-3 text-xs text-neutral-500">
                <li className="flex items-start gap-3">
                  <span className="text-cyan-400 font-black">1.</span>
                  Be respectful to others
                </li>
                <li className="flex items-start gap-3">
                  <span className="text-cyan-400 font-black">2.</span>
                  Share evidence-based info
                </li>
                <li className="flex items-start gap-3">
                  <span className="text-cyan-400 font-black">3.</span>
                  Add medical disclaimers
                </li>
                <li className="flex items-start gap-3">
                  <span className="text-cyan-400 font-black">4.</span>
                  Respect privacy
                </li>
              </ul>
            </div>
          </aside>
        </div>
      </main>
    </div>
  );
}

import React from 'react';
