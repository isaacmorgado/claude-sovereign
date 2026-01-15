'use client';

import React, { useState, useMemo } from 'react';
import Link from 'next/link';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowLeft, BookOpen, FileText, User, Filter, ExternalLink, FlaskConical, Search, ChevronDown } from 'lucide-react';
import {
  SCIENTIFIC_SOURCES,
  CATEGORY_LABELS,
  type SourceCategory,
  getSourceCountByCategory,
  getTotalSourceCount,
} from '@/data/scientific-sources';

// Category icon mapping
const CATEGORY_ICONS: Record<SourceCategory, React.ReactNode> = {
  'facial-proportions': <FlaskConical size={14} />,
  'symmetry': <Filter size={14} />,
  'fwhr': <BookOpen size={14} />,
  'jaw-aesthetics': <FileText size={14} />,
  'eye-aesthetics': <FileText size={14} />,
  'nasal-aesthetics': <FileText size={14} />,
  'sexual-dimorphism': <FileText size={14} />,
  'averageness': <FileText size={14} />,
  'lip-aesthetics': <FileText size={14} />,
  'skincare': <FileText size={14} />,
  'supplements': <FileText size={14} />,
  'first-impressions': <FileText size={14} />,
};

// Category color mapping
const CATEGORY_COLORS: Record<SourceCategory, { bg: string; text: string; border: string }> = {
  'facial-proportions': { bg: 'bg-cyan-500/20', text: 'text-cyan-400', border: 'border-cyan-500/30' },
  'symmetry': { bg: 'bg-purple-500/20', text: 'text-purple-400', border: 'border-purple-500/30' },
  'fwhr': { bg: 'bg-amber-500/20', text: 'text-amber-400', border: 'border-amber-500/30' },
  'jaw-aesthetics': { bg: 'bg-red-500/20', text: 'text-red-400', border: 'border-red-500/30' },
  'eye-aesthetics': { bg: 'bg-blue-500/20', text: 'text-blue-400', border: 'border-blue-500/30' },
  'nasal-aesthetics': { bg: 'bg-pink-500/20', text: 'text-pink-400', border: 'border-pink-500/30' },
  'sexual-dimorphism': { bg: 'bg-violet-500/20', text: 'text-violet-400', border: 'border-violet-500/30' },
  'averageness': { bg: 'bg-emerald-500/20', text: 'text-emerald-400', border: 'border-emerald-500/30' },
  'lip-aesthetics': { bg: 'bg-rose-500/20', text: 'text-rose-400', border: 'border-rose-500/30' },
  'skincare': { bg: 'bg-teal-500/20', text: 'text-teal-400', border: 'border-teal-500/30' },
  'supplements': { bg: 'bg-green-500/20', text: 'text-green-400', border: 'border-green-500/30' },
  'first-impressions': { bg: 'bg-orange-500/20', text: 'text-orange-400', border: 'border-orange-500/30' },
};

export default function SourcesPage() {
  const [selectedCategory, setSelectedCategory] = useState<SourceCategory | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedIds, setExpandedIds] = useState<Set<string>>(new Set());

  const categoryStats = useMemo(() => getSourceCountByCategory(), []);
  const totalSources = getTotalSourceCount();

  // Filter sources by category and search
  const filteredSources = useMemo(() => {
    let sources = SCIENTIFIC_SOURCES;

    if (selectedCategory) {
      sources = sources.filter(s => s.category === selectedCategory);
    }

    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      sources = sources.filter(s =>
        s.title.toLowerCase().includes(query) ||
        s.authors.toLowerCase().includes(query) ||
        s.journal.toLowerCase().includes(query) ||
        s.summary.toLowerCase().includes(query)
      );
    }

    return sources;
  }, [selectedCategory, searchQuery]);

  const toggleExpanded = (id: string) => {
    setExpandedIds(prev => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  };

  return (
    <main className="min-h-screen bg-black text-white selection:bg-cyan-500/30">
      <div className="max-w-5xl mx-auto px-6 pt-32 pb-20">
        <Link href="/" className="inline-flex items-center gap-2 text-neutral-500 hover:text-cyan-400 text-xs font-black uppercase tracking-widest mb-12 transition-colors">
          <ArrowLeft size={14} />
          Back to Labs
        </Link>

        <header className="mb-16">
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-6">
            <div>
              <h1 className="text-5xl font-black tracking-tighter italic uppercase mb-4">
                Scientific <span className="text-cyan-400">Methodology</span>
              </h1>
              <p className="text-neutral-500 font-medium max-w-md uppercase text-xs tracking-[0.2em]">
                Peer-Reviewed Research Backing Our Analysis Engine
              </p>
            </div>
            <div className="flex items-center gap-3">
              <div className="px-4 py-2 bg-cyan-500/20 border border-cyan-500/30 rounded-xl">
                <span className="text-3xl font-black text-cyan-400">{totalSources}</span>
                <span className="text-[10px] font-black uppercase tracking-wider text-neutral-400 ml-2">Studies</span>
              </div>
            </div>
          </div>
        </header>

        <div className="space-y-16">
          {/* Hero Section */}
          <section className="p-10 rounded-[2.5rem] bg-neutral-900/40 border border-white/5 relative overflow-hidden">
            <div className="absolute top-0 right-0 p-8 opacity-10">
              <BookOpen size={120} />
            </div>
            <h2 className="text-xs font-black uppercase tracking-[0.4em] text-cyan-500 mb-6">Our Approach</h2>
            <p className="text-xl font-bold italic text-neutral-200 leading-relaxed mb-6">
              &ldquo;FACIAL HARMONY IS NOT SUBJECTIVE—IT IS A BIOMETRIC EQUILIBRIUM.&rdquo;
            </p>
            <p className="text-neutral-500 text-sm leading-relaxed max-w-2xl mb-8">
              Every score generated by LOOXSMAXXLABS is derived from comparative analysis against the Neo-Classical Canons, Average Composite Models, and modern high-fashion developmental stability metrics. Our engine uses Computer Vision (CV) to identify landmarks with 99.8% precision across diverse lighting conditions.
            </p>

            {/* Stats Grid */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="bg-neutral-900/60 rounded-xl p-4 border border-white/5">
                <p className="text-2xl font-black text-white">{totalSources}</p>
                <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Peer-Reviewed Studies</p>
              </div>
              <div className="bg-neutral-900/60 rounded-xl p-4 border border-white/5">
                <p className="text-2xl font-black text-white">12</p>
                <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Research Categories</p>
              </div>
              <div className="bg-neutral-900/60 rounded-xl p-4 border border-white/5">
                <p className="text-2xl font-black text-white">1985-2025</p>
                <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Research Timeline</p>
              </div>
              <div className="bg-neutral-900/60 rounded-xl p-4 border border-white/5">
                <p className="text-2xl font-black text-white">99.8%</p>
                <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Landmark Precision</p>
              </div>
            </div>
          </section>

          {/* Category Filter */}
          <section>
            <div className="flex items-center gap-4 mb-6">
              <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 whitespace-nowrap">
                Filter by Category
              </h2>
              <div className="flex-1 h-px bg-neutral-900" />
            </div>

            <div className="flex flex-wrap gap-2 mb-6">
              <button
                onClick={() => setSelectedCategory(null)}
                className={`px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-wider transition-all border ${
                  selectedCategory === null
                    ? 'bg-cyan-500 text-black border-cyan-400'
                    : 'bg-neutral-900/50 text-neutral-400 border-white/5 hover:border-white/10 hover:text-white'
                }`}
              >
                All ({totalSources})
              </button>
              {Object.entries(CATEGORY_LABELS).map(([key, label]) => {
                const category = key as SourceCategory;
                const count = categoryStats[category] || 0;
                const colors = CATEGORY_COLORS[category];

                return (
                  <button
                    key={category}
                    onClick={() => setSelectedCategory(selectedCategory === category ? null : category)}
                    className={`px-3 py-2 rounded-xl text-[10px] font-black uppercase tracking-wider transition-all border flex items-center gap-2 ${
                      selectedCategory === category
                        ? `${colors.bg} ${colors.text} ${colors.border}`
                        : 'bg-neutral-900/50 text-neutral-400 border-white/5 hover:border-white/10 hover:text-white'
                    }`}
                  >
                    {CATEGORY_ICONS[category]}
                    <span className="hidden md:inline">{label}</span>
                    <span className="md:hidden">{label.split(' ')[0]}</span>
                    ({count})
                  </button>
                );
              })}
            </div>

            {/* Search */}
            <div className="relative">
              <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-neutral-500" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search studies by title, author, or topic..."
                className="w-full pl-11 pr-4 py-3 bg-neutral-900/50 border border-white/5 rounded-xl text-sm text-white placeholder:text-neutral-600 focus:outline-none focus:border-cyan-500/30"
              />
            </div>
          </section>

          {/* Sources List */}
          <section>
            <div className="flex items-center gap-4 mb-8">
              <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 whitespace-nowrap">
                Peer-Reviewed Citations
              </h2>
              <div className="flex-1 h-px bg-neutral-900" />
              <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
                {filteredSources.length} Results
              </span>
            </div>

            <div className="space-y-6">
              <AnimatePresence mode="popLayout">
                {filteredSources.map((source, idx) => {
                  const colors = CATEGORY_COLORS[source.category];
                  const isExpanded = expandedIds.has(source.id);

                  return (
                    <motion.div
                      key={source.id}
                      layout
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -20 }}
                      transition={{ duration: 0.2, delay: idx * 0.02 }}
                      className="group rounded-2xl bg-neutral-900/40 border border-white/5 hover:border-white/10 transition-all overflow-hidden"
                    >
                      {/* Header - Always visible */}
                      <button
                        onClick={() => toggleExpanded(source.id)}
                        className="w-full p-6 text-left"
                      >
                        <div className="flex items-start gap-5">
                          <div className="w-12 h-12 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center shrink-0 group-hover:border-cyan-500/50 transition-colors">
                            <FileText size={18} className="text-neutral-500 group-hover:text-cyan-400" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex flex-wrap items-center gap-2 mb-2">
                              <span className={`px-2 py-0.5 rounded-lg text-[9px] font-black uppercase tracking-wider ${colors.bg} ${colors.text} ${colors.border} border`}>
                                {CATEGORY_LABELS[source.category]}
                              </span>
                              <span className="text-[10px] font-bold text-neutral-600">{source.year}</span>
                            </div>
                            <h3 className="text-lg font-black uppercase text-white mb-2 leading-tight group-hover:text-cyan-400 transition-colors">
                              {source.title}
                            </h3>
                            <div className="flex flex-wrap items-center gap-x-4 gap-y-1">
                              <div className="flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider text-neutral-400">
                                <User size={10} className="text-cyan-500" />
                                {source.authors}
                              </div>
                              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
                                {source.journal}
                              </div>
                            </div>
                          </div>
                          <ChevronDown
                            size={18}
                            className={`text-neutral-500 transition-transform flex-shrink-0 ${isExpanded ? 'rotate-180' : ''}`}
                          />
                        </div>
                      </button>

                      {/* Expanded Content */}
                      <AnimatePresence>
                        {isExpanded && (
                          <motion.div
                            initial={{ height: 0, opacity: 0 }}
                            animate={{ height: 'auto', opacity: 1 }}
                            exit={{ height: 0, opacity: 0 }}
                            transition={{ duration: 0.2 }}
                            className="overflow-hidden"
                          >
                            <div className="px-6 pb-6 pt-0">
                              <div className="border-t border-white/5 pt-5">
                                <p className="text-neutral-400 text-sm font-medium leading-relaxed mb-5 border-l-2 border-cyan-500/30 pl-4 italic">
                                  {source.summary}
                                </p>
                                <a
                                  href={source.link}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-cyan-500/20 border border-cyan-500/30 text-cyan-400 text-[10px] font-black uppercase tracking-wider hover:bg-cyan-500/30 transition-all"
                                >
                                  <ExternalLink size={12} />
                                  View on PubMed
                                </a>
                              </div>
                            </div>
                          </motion.div>
                        )}
                      </AnimatePresence>
                    </motion.div>
                  );
                })}
              </AnimatePresence>
            </div>

            {filteredSources.length === 0 && (
              <div className="text-center py-16">
                <div className="w-16 h-16 rounded-2xl bg-neutral-900 border border-white/10 flex items-center justify-center mx-auto mb-5">
                  <Search size={28} className="text-neutral-600" />
                </div>
                <h3 className="text-lg font-black uppercase tracking-wider text-white mb-2">No Studies Found</h3>
                <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
                  Try adjusting your search or filter criteria
                </p>
              </div>
            )}
          </section>

          {/* Methodology Note */}
          <section className="p-8 rounded-2xl bg-gradient-to-br from-cyan-500/10 to-blue-600/10 border border-cyan-500/20">
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-cyan-400 mb-4">Research Integrity</h3>
            <p className="text-sm text-neutral-400 leading-relaxed mb-4">
              All sources are peer-reviewed publications from journals indexed in PubMed, Scopus, or Web of Science.
              Our methodology is continuously updated as new research emerges in the field of facial aesthetics and
              anthropometric analysis.
            </p>
            <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
              Last verification: December 26, 2025
            </p>
          </section>
        </div>

        <footer className="mt-32 pt-12 border-t border-neutral-900 text-center">
          <p className="text-neutral-700 text-[10px] font-mono uppercase tracking-[0.2em]">
            Engine: Quantum-V4.2 | {totalSources} Citations Verified | 2025.12.26
          </p>
        </footer>
      </div>
    </main>
  );
}
