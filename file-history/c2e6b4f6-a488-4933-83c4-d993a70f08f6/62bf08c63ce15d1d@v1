'use client';

import { useEffect, useState, useMemo } from 'react';
import Link from 'next/link';
import { useResults } from '@/contexts/ResultsContext';
import { TabContent } from '../ResultsLayout';
import { api, ArchetypeForumRecommendation } from '@/lib/api';
import { RecommendedForum, Category, SubForum } from '@/types/forum';
import { classifyFromRatios } from '@/lib/archetype-classifier';
import { Ethnicity, Gender } from '@/lib/harmony-scoring';
import {
  Users,
  ArrowRight,
  Flame,
  Target,
  Sparkles,
  Crown,
  ChevronDown,
} from 'lucide-react';

export function CommunityTab() {
  const { flaws, frontRatios, sideRatios, gender, ethnicity } = useResults();
  const [recommendedForums, setRecommendedForums] = useState<RecommendedForum[]>([]);
  const [archetypeForums, setArchetypeForums] = useState<ArchetypeForumRecommendation[]>([]);
  const [allCategories, setAllCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Classify archetype from ratios
  const archetypeClassification = useMemo(() => {
    if (!frontRatios || frontRatios.length === 0 || !gender || !ethnicity) {
      return null;
    }
    try {
      return classifyFromRatios(
        frontRatios,
        sideRatios || [],
        gender as Gender,
        ethnicity as Ethnicity
      );
    } catch {
      return null;
    }
  }, [frontRatios, sideRatios, gender, ethnicity]);

  useEffect(() => {
    let isMounted = true;
    const controller = new AbortController();

    async function fetchData() {
      setIsLoading(true);
      setError(null);

      try {
        // Convert flaw IDs to snake_case format for API
        // flaw.id format: "insight_flaw_narrow_jaw" -> extract "narrow_jaw"
        const flawIds = flaws.map(f => {
          const id = f.id.replace('insight_flaw_', '');
          return id;
        });

        // Get archetype category for recommendations
        const archetypeCategory = archetypeClassification?.primary?.category;

        const [recommended, archetype, all] = await Promise.all([
          flawIds.length > 0 ? api.getRecommendedForums(flawIds) : Promise.resolve([]),
          archetypeCategory ? api.getArchetypeForumRecommendations(archetypeCategory) : Promise.resolve([]),
          api.getForumCategories(),
        ]);

        if (isMounted) {
          setRecommendedForums(recommended);
          setArchetypeForums(archetype);
          setAllCategories(all);
        }
      } catch (err) {
        if (isMounted && err instanceof Error && err.name !== 'AbortError') {
          setError(err.message || 'Failed to load communities');
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    }

    fetchData();

    return () => {
      isMounted = false;
      controller.abort();
    };
  }, [flaws, archetypeClassification]);

  return (
    <TabContent
      title="Community"
      subtitle="Connect with others on your self-improvement journey"
    >
      <div className="space-y-10">
        {/* Hero CTA */}
        <div className="rounded-[2rem] bg-gradient-to-br from-cyan-500/10 via-blue-500/5 to-purple-500/10 border border-cyan-500/20 p-8 relative overflow-hidden">
          {/* Background decoration */}
          <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-cyan-500/10 to-transparent rounded-full blur-3xl" />

          <div className="flex flex-col md:flex-row md:items-center gap-6 relative z-10">
            <div className="flex-1">
              <span className="text-[10px] font-black uppercase tracking-[0.3em] text-cyan-400 block mb-3">
                Personalized For You
              </span>
              <h2 className="text-2xl md:text-3xl font-black tracking-tight text-white mb-3">
                Your Communities
              </h2>
              <p className="text-neutral-400 text-sm max-w-lg">
                Based on your analysis results, we&apos;ve identified communities where you can
                learn from others with similar goals.
              </p>
            </div>
            <Link
              href="/forum"
              className="flex items-center justify-center gap-3 px-7 py-4 bg-cyan-500 text-black font-black uppercase tracking-wider rounded-xl hover:bg-cyan-400 transition-colors whitespace-nowrap"
            >
              Explore All
              <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
        </div>

        {/* Loading State */}
        {isLoading && (
          <div className="grid gap-4 md:grid-cols-2">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="rounded-2xl bg-neutral-900/40 border border-white/5 p-6 animate-pulse">
                <div className="flex items-start gap-4">
                  <div className="w-14 h-14 rounded-xl bg-neutral-800" />
                  <div className="flex-1">
                    <div className="h-5 bg-neutral-800 rounded w-2/3 mb-3" />
                    <div className="h-4 bg-neutral-800 rounded w-full mb-4" />
                    <div className="flex gap-2">
                      <div className="h-6 bg-neutral-800 rounded-lg w-24" />
                      <div className="h-6 bg-neutral-800 rounded-lg w-20" />
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Error State */}
        {error && (
          <div className="rounded-2xl bg-red-500/10 border border-red-500/20 p-6">
            <p className="text-red-400 font-bold mb-2">{error}</p>
            <p className="text-sm text-neutral-400">
              Unable to load community data. You can still{' '}
              <Link href="/forum" className="text-cyan-400 hover:underline font-medium">
                browse the forum directly
              </Link>.
            </p>
          </div>
        )}

        {/* Archetype-Based Recommendations */}
        {!isLoading && !error && archetypeForums.length > 0 && archetypeClassification && (
          <section>
            <div className="flex items-center gap-4 mb-6">
              <div className="w-10 h-10 rounded-xl bg-amber-500/15 border border-amber-500/20 flex items-center justify-center">
                <Crown className="w-5 h-5 text-amber-400" />
              </div>
              <div>
                <h3 className="text-lg font-black text-white">Based on Your Archetype</h3>
                <span className="text-[10px] font-black uppercase tracking-wider text-amber-400">
                  {archetypeClassification.primary.category}
                </span>
              </div>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              {archetypeForums.map((af) => {
                // Filter out duplicates from flaw-based recommendations
                const isDuplicate = recommendedForums.some(rf => rf.category.id === af.category.id);
                if (isDuplicate) return null;

                return (
                  <Link key={af.category.id} href={`/forum/${af.category.slug}`}>
                    <div className="group rounded-2xl bg-neutral-900/40 border border-white/5 hover:border-amber-500/30 p-6 transition-all">
                      <div className="flex items-start gap-4">
                        {/* Icon */}
                        <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-amber-500/20 to-orange-500/10 border border-amber-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                          {af.category.icon || '💬'}
                        </div>

                        {/* Content */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-2">
                            <h4 className="font-black text-white group-hover:text-amber-400 transition-colors">
                              {af.category.name}
                            </h4>
                            <Crown className="w-4 h-4 text-amber-400" />
                          </div>
                          <p className="text-sm text-neutral-500 line-clamp-2 mb-4">
                            {af.reason || af.category.description}
                          </p>

                          {/* Archetype tag */}
                          <div className="flex flex-wrap gap-2">
                            <span className="px-3 py-1 text-[10px] font-black uppercase tracking-wider bg-amber-500/10 text-amber-400 rounded-lg border border-amber-500/20">
                              {af.archetype} archetype
                            </span>
                          </div>
                        </div>

                        {/* Arrow */}
                        <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/5 flex items-center justify-center group-hover:border-amber-500/30 group-hover:bg-amber-500/10 transition-all flex-shrink-0">
                          <ArrowRight className="w-4 h-4 text-neutral-600 group-hover:text-amber-400 transition-colors" />
                        </div>
                      </div>
                    </div>
                  </Link>
                );
              })}
            </div>
          </section>
        )}

        {/* Recommended Forums */}
        {!isLoading && !error && recommendedForums.length > 0 && (
          <section>
            <div className="flex items-center gap-4 mb-6">
              <div className="w-10 h-10 rounded-xl bg-cyan-500/15 border border-cyan-500/20 flex items-center justify-center">
                <Target className="w-5 h-5 text-cyan-400" />
              </div>
              <div>
                <h3 className="text-lg font-black text-white">Recommended For You</h3>
                <span className="text-[10px] font-black uppercase tracking-wider text-cyan-400">
                  Based on your results
                </span>
              </div>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              {recommendedForums.map((rf) => (
                <Link key={rf.category.id} href={`/forum/${rf.category.slug}`}>
                  <div className="group rounded-2xl bg-neutral-900/40 border border-white/5 hover:border-cyan-500/30 p-6 transition-all">
                    <div className="flex items-start gap-4">
                      {/* Icon */}
                      <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-cyan-500/20 to-purple-500/10 border border-cyan-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                        {rf.category.icon || '💬'}
                      </div>

                      {/* Content */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-2">
                          <h4 className="font-black text-white group-hover:text-cyan-400 transition-colors">
                            {rf.category.name}
                          </h4>
                          <Sparkles className="w-4 h-4 text-cyan-400" />
                        </div>
                        <p className="text-sm text-neutral-500 line-clamp-2 mb-4">
                          {rf.category.description}
                        </p>

                        {/* Matched flaws */}
                        <div className="flex flex-wrap gap-2">
                          {rf.matchedFlaws.slice(0, 3).map((flaw) => (
                            <span
                              key={flaw}
                              className="px-3 py-1 text-[10px] font-black uppercase tracking-wider bg-cyan-500/10 text-cyan-400 rounded-lg border border-cyan-500/20"
                            >
                              {flaw}
                            </span>
                          ))}
                          {rf.matchedFlaws.length > 3 && (
                            <span className="px-3 py-1 text-[10px] font-bold text-neutral-600">
                              +{rf.matchedFlaws.length - 3} more
                            </span>
                          )}
                        </div>
                      </div>

                      {/* Arrow */}
                      <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/5 flex items-center justify-center group-hover:border-cyan-500/30 group-hover:bg-cyan-500/10 transition-all flex-shrink-0">
                        <ArrowRight className="w-4 h-4 text-neutral-600 group-hover:text-cyan-400 transition-colors" />
                      </div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </section>
        )}

        {/* All Communities - Organized by Category */}
        {!isLoading && !error && allCategories.length > 0 && (
          <section>
            <div className="flex items-center gap-4 mb-6">
              <div className="w-10 h-10 rounded-xl bg-purple-500/15 border border-purple-500/20 flex items-center justify-center">
                <Users className="w-5 h-5 text-purple-400" />
              </div>
              <h3 className="text-lg font-black text-white">All Communities</h3>
            </div>

            <div className="space-y-4">
              {allCategories.map((category) => (
                <div key={category.id} className="rounded-2xl bg-neutral-900/40 border border-white/5 overflow-hidden">
                  {/* Category Header */}
                  <Link href={`/forum/${category.slug}`}>
                    <div className="group flex items-center gap-4 p-5 hover:bg-white/5 transition-all border-b border-white/5">
                      {/* Icon */}
                      <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-500/20 to-blue-500/10 border border-cyan-500/20 flex items-center justify-center text-xl flex-shrink-0">
                        {category.icon || '💬'}
                      </div>

                      {/* Category Info */}
                      <div className="flex-1 min-w-0">
                        <h4 className="font-black text-white group-hover:text-cyan-400 transition-colors">
                          {category.name}
                        </h4>
                        <p className="text-[11px] text-neutral-500 line-clamp-1">
                          {category.description || 'Join the discussion'}
                        </p>
                      </div>

                      {/* Stats + Arrow */}
                      <div className="flex items-center gap-4 flex-shrink-0">
                        <div className="text-right hidden sm:block">
                          <p className="text-sm font-black text-white">{category.postCount}</p>
                          <p className="text-[9px] font-bold text-neutral-600 uppercase tracking-wider">posts</p>
                        </div>
                        <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/5 flex items-center justify-center group-hover:border-cyan-500/30 group-hover:bg-cyan-500/10 transition-all">
                          <ChevronDown size={14} className="text-neutral-600 group-hover:text-cyan-400 transition-colors" />
                        </div>
                      </div>
                    </div>
                  </Link>

                  {/* Sub-forums (Topics) */}
                  {category.subForums.length > 0 && (
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-px bg-white/5">
                      {category.subForums.map((subForum: SubForum) => (
                        <Link
                          key={subForum.id}
                          href={`/forum/${category.slug}?sub=${subForum.slug}`}
                        >
                          <div className="group bg-neutral-900/60 p-3 hover:bg-cyan-500/10 transition-all">
                            <div className="flex items-center gap-2">
                              <span className="text-sm">{subForum.icon || '💬'}</span>
                              <span className="text-xs font-bold text-neutral-400 group-hover:text-cyan-400 transition-colors truncate">
                                r/{subForum.slug}
                              </span>
                            </div>
                            <p className="text-[10px] text-neutral-600 mt-1 line-clamp-1">
                              {subForum.postCount} posts
                            </p>
                          </div>
                        </Link>
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </section>
        )}

        {/* Empty State */}
        {!isLoading && !error && allCategories.length === 0 && (
          <div className="text-center py-16">
            <div className="w-20 h-20 rounded-2xl bg-neutral-900/40 border border-white/5 flex items-center justify-center mx-auto mb-6">
              <Users className="w-10 h-10 text-neutral-700" />
            </div>
            <p className="text-neutral-500 mb-4 font-medium">No communities available yet.</p>
            <Link
              href="/forum"
              className="text-cyan-400 hover:text-cyan-300 font-black uppercase tracking-wider text-sm"
            >
              Check back soon
            </Link>
          </div>
        )}

        {/* Bottom CTA */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-6">
          <Link
            href="/forum"
            className="flex items-center gap-3 px-7 py-4 rounded-xl bg-neutral-900/60 border border-white/5 hover:border-white/10 transition-all group"
          >
            <Flame className="w-5 h-5 text-orange-400" />
            <span className="font-black uppercase tracking-wider text-white">Browse Trending</span>
          </Link>
          <Link
            href="/forum"
            className="flex items-center gap-3 px-7 py-4 rounded-xl border border-white/10 hover:border-cyan-500/30 hover:bg-cyan-500/5 transition-all group"
          >
            <span className="font-black uppercase tracking-wider text-neutral-400 group-hover:text-cyan-400 transition-colors">All Communities</span>
            <ArrowRight className="w-4 h-4 text-neutral-600 group-hover:text-cyan-400 transition-colors" />
          </Link>
        </div>
      </div>
    </TabContent>
  );
}
