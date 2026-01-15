'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useForum } from '@/contexts/ForumContext';
import { ArrowRight, TrendingUp, Users, MessageSquare, Flame, Clock, Star } from 'lucide-react';

export default function ForumPage() {
  const { categories, isLoadingCategories, fetchCategories, error } = useForum();
  const [activeFilter, setActiveFilter] = useState<'all' | 'trending' | 'new'>('all');

  useEffect(() => {
    fetchCategories();
  }, [fetchCategories]);

  // Sort categories based on filter
  const sortedCategories = [...categories].sort((a, b) => {
    if (activeFilter === 'trending') return b.postCount - a.postCount;
    if (activeFilter === 'new') return 0; // Keep original order
    return a.displayOrder - b.displayOrder;
  });

  const totalPosts = categories.reduce((sum, c) => sum + c.postCount, 0);
  const totalTopics = categories.reduce((sum, c) => sum + c.subForums.length, 0);

  return (
    <div className="min-h-screen bg-black">
      {/* Header */}
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
            <Link
              href="/results"
              className="text-sm text-neutral-400 hover:text-white transition-colors"
            >
              My Results
            </Link>
            <Link
              href="/login"
              className="h-9 px-4 rounded-lg bg-[#00f3ff] text-black text-sm font-medium flex items-center gap-2 hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] transition-all"
            >
              Get Started
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative overflow-hidden border-b border-neutral-800">
        <div className="absolute inset-0 bg-gradient-to-br from-[#00f3ff]/10 via-transparent to-purple-500/5" />
        <div className="relative max-w-6xl mx-auto px-4 py-12 md:py-16">
          <div className="max-w-2xl">
            <h1 className="text-3xl md:text-4xl font-bold text-white mb-4">
              Join the Self-Improvement Community
            </h1>
            <p className="text-lg text-neutral-400 mb-6">
              Connect with thousands of others on their journey. Share experiences, get advice, and discover proven treatments that work.
            </p>
            <div className="flex flex-wrap gap-4">
              <Link
                href="/signup"
                className="h-11 px-6 rounded-lg bg-[#00f3ff] text-black font-medium flex items-center gap-2 hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] transition-all"
              >
                Join Community
                <ArrowRight className="w-4 h-4" />
              </Link>
              <Link
                href="/results"
                className="h-11 px-6 rounded-lg border border-neutral-700 text-white font-medium flex items-center gap-2 hover:bg-neutral-900 transition-all"
              >
                Get My Analysis First
              </Link>
            </div>
          </div>

          {/* Stats */}
          <div className="flex flex-wrap gap-6 mt-10">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-[#00f3ff]/10 flex items-center justify-center">
                <Users className="w-5 h-5 text-[#00f3ff]" />
              </div>
              <div>
                <p className="text-xl font-bold text-white">{categories.length}</p>
                <p className="text-sm text-neutral-500">Communities</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-purple-500/10 flex items-center justify-center">
                <MessageSquare className="w-5 h-5 text-purple-400" />
              </div>
              <div>
                <p className="text-xl font-bold text-white">{totalPosts}</p>
                <p className="text-sm text-neutral-500">Discussions</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-orange-500/10 flex items-center justify-center">
                <TrendingUp className="w-5 h-5 text-orange-400" />
              </div>
              <div>
                <p className="text-xl font-bold text-white">{totalTopics}</p>
                <p className="text-sm text-neutral-500">Topics</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-4 py-8">
        <div className="flex flex-col lg:flex-row gap-8">
          {/* Communities List */}
          <div className="flex-1">
            {/* Filter Tabs */}
            <div className="flex items-center gap-2 mb-6">
              <span className="text-sm text-neutral-500 mr-2">Sort by:</span>
              {[
                { id: 'all', label: 'All', icon: Star },
                { id: 'trending', label: 'Trending', icon: Flame },
                { id: 'new', label: 'Recent', icon: Clock },
              ].map((filter) => (
                <button
                  key={filter.id}
                  onClick={() => setActiveFilter(filter.id as typeof activeFilter)}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-all ${
                    activeFilter === filter.id
                      ? 'bg-[#00f3ff]/10 text-[#00f3ff]'
                      : 'text-neutral-400 hover:text-white hover:bg-neutral-900'
                  }`}
                >
                  <filter.icon className="w-4 h-4" />
                  {filter.label}
                </button>
              ))}
            </div>

            {/* Error State */}
            {error && (
              <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-4 mb-6">
                <p className="text-red-400 text-sm">{error}</p>
              </div>
            )}

            {/* Loading State */}
            {isLoadingCategories && categories.length === 0 && (
              <div className="space-y-4">
                {[1, 2, 3, 4, 5, 6].map((i) => (
                  <div key={i} className="bg-neutral-900 border border-neutral-800 rounded-xl p-5 animate-pulse">
                    <div className="flex items-start gap-4">
                      <div className="w-12 h-12 rounded-xl bg-neutral-800" />
                      <div className="flex-1">
                        <div className="h-5 bg-neutral-800 rounded w-1/3 mb-2" />
                        <div className="h-4 bg-neutral-800 rounded w-2/3 mb-3" />
                        <div className="flex gap-2">
                          <div className="h-6 bg-neutral-800 rounded w-16" />
                          <div className="h-6 bg-neutral-800 rounded w-20" />
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Communities */}
            {!isLoadingCategories && sortedCategories.length > 0 && (
              <div className="space-y-3">
                {sortedCategories.map((category, index) => (
                  <Link key={category.id} href={`/forum/${category.slug}`}>
                    <div className="group bg-neutral-900/50 border border-neutral-800 hover:border-[#00f3ff]/30 rounded-xl p-5 transition-all hover:shadow-[0_0_30px_rgba(0,243,255,0.05)]">
                      <div className="flex items-start gap-4">
                        {/* Icon */}
                        <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-[#00f3ff]/20 to-purple-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                          {category.icon || '💬'}
                        </div>

                        {/* Content */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            <h3 className="font-semibold text-white group-hover:text-[#00f3ff] transition-colors">
                              {category.name}
                            </h3>
                            {index < 3 && activeFilter === 'trending' && (
                              <span className="px-2 py-0.5 text-[10px] font-bold bg-orange-500/20 text-orange-400 rounded">
                                HOT
                              </span>
                            )}
                          </div>
                          <p className="text-sm text-neutral-400 line-clamp-2 mb-3">
                            {category.description}
                          </p>

                          {/* Sub-forums as pills */}
                          <div className="flex flex-wrap gap-2">
                            {category.subForums.slice(0, 4).map((sf) => (
                              <span
                                key={sf.id}
                                className="px-2.5 py-1 text-xs bg-neutral-800 text-neutral-300 rounded-lg"
                              >
                                {sf.name}
                              </span>
                            ))}
                            {category.subForums.length > 4 && (
                              <span className="px-2.5 py-1 text-xs text-neutral-500">
                                +{category.subForums.length - 4} more
                              </span>
                            )}
                          </div>
                        </div>

                        {/* Stats */}
                        <div className="text-right hidden sm:block">
                          <p className="text-lg font-bold text-white">{category.postCount}</p>
                          <p className="text-xs text-neutral-500">posts</p>
                        </div>

                        {/* Arrow */}
                        <ArrowRight className="w-5 h-5 text-neutral-600 group-hover:text-[#00f3ff] transition-colors" />
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            )}

            {/* Empty State */}
            {!isLoadingCategories && categories.length === 0 && !error && (
              <div className="text-center py-16">
                <div className="w-16 h-16 rounded-2xl bg-neutral-900 flex items-center justify-center mx-auto mb-4">
                  <MessageSquare className="w-8 h-8 text-neutral-600" />
                </div>
                <p className="text-neutral-400 mb-4">No communities available yet.</p>
                <Link
                  href="/signup"
                  className="text-[#00f3ff] hover:underline"
                >
                  Be the first to start a discussion
                </Link>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <aside className="lg:w-80 space-y-6">
            {/* CTA Card */}
            <div className="bg-gradient-to-br from-[#00f3ff]/10 to-purple-500/10 border border-[#00f3ff]/20 rounded-xl p-5">
              <h3 className="font-semibold text-white mb-2">Get Personalized Recommendations</h3>
              <p className="text-sm text-neutral-400 mb-4">
                Take our AI face analysis to discover which communities and treatments are most relevant to you.
              </p>
              <Link
                href="/upload"
                className="block w-full py-2.5 bg-[#00f3ff] text-black text-sm font-medium rounded-lg text-center hover:shadow-[0_0_20px_rgba(0,243,255,0.3)] transition-all"
              >
                Start Free Analysis
              </Link>
            </div>

            {/* Popular Topics */}
            <div className="bg-neutral-900/50 border border-neutral-800 rounded-xl p-5">
              <h3 className="font-semibold text-white mb-4 flex items-center gap-2">
                <Flame className="w-4 h-4 text-orange-400" />
                Popular Topics
              </h3>
              <div className="space-y-3">
                {categories.slice(0, 5).flatMap(c => c.subForums.slice(0, 1)).slice(0, 5).map((sf, i) => (
                  <div key={sf.id} className="flex items-center gap-3">
                    <span className="w-5 h-5 rounded bg-neutral-800 flex items-center justify-center text-xs text-neutral-500">
                      {i + 1}
                    </span>
                    <span className="text-sm text-neutral-300 hover:text-white cursor-pointer transition-colors">
                      {sf.name}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Community Guidelines */}
            <div className="bg-neutral-900/50 border border-neutral-800 rounded-xl p-5">
              <h3 className="font-semibold text-white mb-3">Community Guidelines</h3>
              <ul className="space-y-2 text-sm text-neutral-400">
                <li className="flex items-start gap-2">
                  <span className="text-[#00f3ff]">1.</span>
                  Be respectful and supportive
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-[#00f3ff]">2.</span>
                  Share evidence-based information
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-[#00f3ff]">3.</span>
                  No medical advice without disclaimers
                </li>
                <li className="flex items-start gap-2">
                  <span className="text-[#00f3ff]">4.</span>
                  Respect privacy and consent
                </li>
              </ul>
            </div>
          </aside>
        </div>
      </main>
    </div>
  );
}
