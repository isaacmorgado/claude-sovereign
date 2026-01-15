'use client';

import { useEffect, useState, useMemo } from 'react';
import Link from 'next/link';
import { useResults } from '@/contexts/ResultsContext';
import { TabContent } from '../ResultsLayout';
import { api, ArchetypeForumRecommendation } from '@/lib/api';
import { RecommendedForum, Category } from '@/types/forum';
import { classifyFromRatios } from '@/lib/archetype-classifier';
import { Ethnicity, Gender } from '@/lib/harmony-scoring';
import {
  Users,
  ArrowRight,
  MessageSquare,
  Flame,
  Target,
  TrendingUp,
  Sparkles,
  Crown,
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
      <div className="space-y-8">
        {/* Hero CTA */}
        <div className="bg-gradient-to-br from-cyan-500/10 via-blue-500/5 to-purple-500/10 border border-cyan-500/20 rounded-2xl p-6 md:p-8">
          <div className="flex flex-col md:flex-row md:items-center gap-6">
            <div className="flex-1">
              <h2 className="text-xl md:text-2xl font-bold text-white mb-2">
                Your Personalized Communities
              </h2>
              <p className="text-neutral-400">
                Based on your analysis results, we&apos;ve identified communities where you can
                learn from others with similar goals and share your journey.
              </p>
            </div>
            <Link
              href="/forum"
              className="flex items-center justify-center gap-2 px-6 py-3 bg-cyan-500 text-black font-semibold rounded-xl hover:bg-cyan-400 transition-colors whitespace-nowrap"
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
              <div key={i} className="bg-neutral-900 border border-neutral-800 rounded-xl p-5 animate-pulse">
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-neutral-800" />
                  <div className="flex-1">
                    <div className="h-5 bg-neutral-800 rounded w-2/3 mb-2" />
                    <div className="h-4 bg-neutral-800 rounded w-full mb-3" />
                    <div className="flex gap-2">
                      <div className="h-6 bg-neutral-800 rounded w-20" />
                      <div className="h-6 bg-neutral-800 rounded w-16" />
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Error State */}
        {error && (
          <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-4">
            <p className="text-red-400 mb-2">{error}</p>
            <p className="text-sm text-neutral-400">
              Unable to load community data. You can still{' '}
              <Link href="/forum" className="text-cyan-400 hover:underline">
                browse the forum directly
              </Link>.
            </p>
          </div>
        )}

        {/* Archetype-Based Recommendations */}
        {!isLoading && !error && archetypeForums.length > 0 && archetypeClassification && (
          <section>
            <div className="flex items-center gap-2 mb-4">
              <Crown className="w-5 h-5 text-amber-400" />
              <h3 className="text-lg font-semibold text-white">Based on Your Archetype</h3>
              <span className="px-2 py-0.5 text-xs font-medium bg-amber-500/20 text-amber-400 rounded">
                {archetypeClassification.primary.category}
              </span>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              {archetypeForums.map((af) => {
                // Filter out duplicates from flaw-based recommendations
                const isDuplicate = recommendedForums.some(rf => rf.category.id === af.category.id);
                if (isDuplicate) return null;

                return (
                  <Link key={af.category.id} href={`/forum/${af.category.slug}`}>
                    <div className="group bg-neutral-900/50 border border-neutral-800 hover:border-amber-500/30 rounded-xl p-5 transition-all hover:shadow-[0_0_30px_rgba(245,158,11,0.05)]">
                      <div className="flex items-start gap-4">
                        {/* Icon */}
                        <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-amber-500/20 to-orange-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                          {af.category.icon || '💬'}
                        </div>

                        {/* Content */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            <h4 className="font-semibold text-white group-hover:text-amber-400 transition-colors">
                              {af.category.name}
                            </h4>
                            <Crown className="w-4 h-4 text-amber-400" />
                          </div>
                          <p className="text-sm text-neutral-400 line-clamp-2 mb-3">
                            {af.reason || af.category.description}
                          </p>

                          {/* Archetype tag */}
                          <div className="flex flex-wrap gap-1.5">
                            <span className="px-2 py-0.5 text-xs bg-amber-500/10 text-amber-400 rounded">
                              {af.archetype} archetype
                            </span>
                          </div>
                        </div>

                        {/* Arrow */}
                        <ArrowRight className="w-5 h-5 text-neutral-600 group-hover:text-amber-400 transition-colors flex-shrink-0" />
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
            <div className="flex items-center gap-2 mb-4">
              <Target className="w-5 h-5 text-cyan-400" />
              <h3 className="text-lg font-semibold text-white">Recommended For You</h3>
              <span className="px-2 py-0.5 text-xs font-medium bg-cyan-500/20 text-cyan-400 rounded">
                Based on your results
              </span>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              {recommendedForums.map((rf) => (
                <Link key={rf.category.id} href={`/forum/${rf.category.slug}`}>
                  <div className="group bg-neutral-900/50 border border-neutral-800 hover:border-cyan-500/30 rounded-xl p-5 transition-all hover:shadow-[0_0_30px_rgba(0,243,255,0.05)]">
                    <div className="flex items-start gap-4">
                      {/* Icon */}
                      <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-500/20 to-purple-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                        {rf.category.icon || '💬'}
                      </div>

                      {/* Content */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <h4 className="font-semibold text-white group-hover:text-cyan-400 transition-colors">
                            {rf.category.name}
                          </h4>
                          <Sparkles className="w-4 h-4 text-cyan-400" />
                        </div>
                        <p className="text-sm text-neutral-400 line-clamp-2 mb-3">
                          {rf.category.description}
                        </p>

                        {/* Matched flaws */}
                        <div className="flex flex-wrap gap-1.5">
                          {rf.matchedFlaws.slice(0, 3).map((flaw) => (
                            <span
                              key={flaw}
                              className="px-2 py-0.5 text-xs bg-cyan-500/10 text-cyan-400 rounded"
                            >
                              {flaw}
                            </span>
                          ))}
                          {rf.matchedFlaws.length > 3 && (
                            <span className="px-2 py-0.5 text-xs text-neutral-500">
                              +{rf.matchedFlaws.length - 3} more
                            </span>
                          )}
                        </div>
                      </div>

                      {/* Arrow */}
                      <ArrowRight className="w-5 h-5 text-neutral-600 group-hover:text-cyan-400 transition-colors flex-shrink-0" />
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </section>
        )}

        {/* All Communities */}
        {!isLoading && !error && allCategories.length > 0 && (
          <section>
            <div className="flex items-center gap-2 mb-4">
              <Users className="w-5 h-5 text-purple-400" />
              <h3 className="text-lg font-semibold text-white">All Communities</h3>
            </div>

            <div className="grid gap-3 md:grid-cols-2 lg:grid-cols-3">
              {allCategories.map((category) => (
                <Link key={category.id} href={`/forum/${category.slug}`}>
                  <div className="group bg-neutral-900/30 border border-neutral-800 hover:border-neutral-700 rounded-xl p-4 transition-all">
                    <div className="flex items-center gap-3">
                      {/* Icon */}
                      <div className="w-10 h-10 rounded-lg bg-neutral-800 flex items-center justify-center text-lg flex-shrink-0">
                        {category.icon || '💬'}
                      </div>

                      {/* Content */}
                      <div className="flex-1 min-w-0">
                        <h4 className="font-medium text-white group-hover:text-cyan-400 transition-colors truncate">
                          {category.name}
                        </h4>
                        <div className="flex items-center gap-3 text-xs text-neutral-500">
                          <span className="flex items-center gap-1">
                            <MessageSquare className="w-3 h-3" />
                            {category.postCount} posts
                          </span>
                          <span className="flex items-center gap-1">
                            <TrendingUp className="w-3 h-3" />
                            {category.subForums.length} topics
                          </span>
                        </div>
                      </div>

                      <ArrowRight className="w-4 h-4 text-neutral-600 group-hover:text-white transition-colors" />
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </section>
        )}

        {/* Empty State */}
        {!isLoading && !error && allCategories.length === 0 && (
          <div className="text-center py-12">
            <div className="w-16 h-16 rounded-2xl bg-neutral-900 flex items-center justify-center mx-auto mb-4">
              <Users className="w-8 h-8 text-neutral-600" />
            </div>
            <p className="text-neutral-400 mb-4">No communities available yet.</p>
            <Link
              href="/forum"
              className="text-cyan-400 hover:text-cyan-300 font-medium"
            >
              Check back soon
            </Link>
          </div>
        )}

        {/* Bottom CTA */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
          <Link
            href="/forum"
            className="flex items-center gap-2 px-6 py-3 bg-neutral-800 text-white font-medium rounded-xl hover:bg-neutral-700 transition-colors"
          >
            <Flame className="w-4 h-4 text-orange-400" />
            Browse Trending Posts
          </Link>
          <Link
            href="/forum"
            className="flex items-center gap-2 px-6 py-3 border border-neutral-700 text-neutral-300 font-medium rounded-xl hover:bg-neutral-900 transition-colors"
          >
            View All Communities
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </div>
    </TabContent>
  );
}
