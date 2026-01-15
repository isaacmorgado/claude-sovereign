'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import { useForum } from '@/contexts/ForumContext';
import { CategoryCard, CategoryCardCompact } from '@/components/forum';

export default function ForumPage() {
  const { categories, isLoadingCategories, fetchCategories, error } = useForum();

  useEffect(() => {
    fetchCategories();
  }, [fetchCategories]);

  // Split categories for different sections
  const topCategories = categories.slice(0, 5);
  const allCategories = categories;

  return (
    <div className="min-h-screen bg-[#030303]">
      {/* Header */}
      <header className="sticky top-0 z-50 bg-[#1a1a1b] border-b border-[#343536]">
        <div className="max-w-5xl mx-auto px-4 h-12 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Link href="/" className="text-[#d7dadc] hover:text-white text-sm">
              ← LOOKSMAXX
            </Link>
            <div className="h-5 w-px bg-[#343536]" />
            <Link href="/forum" className="flex items-center gap-2">
              <RedditIcon className="w-8 h-8 text-[#ff4500]" />
              <span className="text-xl font-bold text-[#d7dadc]">Community</span>
            </Link>
          </div>

          <div className="flex items-center gap-2">
            <Link
              href="/login"
              className="px-4 py-1.5 text-sm font-bold text-[#d7dadc] border border-[#d7dadc] rounded-full hover:bg-[#d7dadc]/10 transition-colors"
            >
              Log In
            </Link>
          </div>
        </div>
      </header>

      {/* Main content */}
      <main className="max-w-5xl mx-auto px-4 py-6">
        <div className="flex gap-6">
          {/* Main feed */}
          <div className="flex-1">
            {/* Hero banner */}
            <div className="bg-gradient-to-r from-[#ff4500] to-[#ff6f00] rounded-lg p-6 mb-6">
              <h1 className="text-2xl font-bold text-white mb-2">
                Welcome to the LOOKSMAXX Community
              </h1>
              <p className="text-white/80 text-sm">
                Discuss treatments, share experiences, and get advice from others on their self-improvement journey.
              </p>
            </div>

            {/* Error state */}
            {error && (
              <div className="bg-red-500/10 border border-red-500/20 rounded p-4 mb-4">
                <p className="text-red-400 text-sm">{error}</p>
              </div>
            )}

            {/* Top Communities */}
            <div className="bg-[#1a1a1b] border border-[#343536] rounded-lg overflow-hidden mb-6">
              <div className="bg-gradient-to-r from-[#ff4500]/20 to-transparent px-4 py-3 border-b border-[#343536]">
                <h2 className="text-sm font-bold text-[#d7dadc]">Top Communities</h2>
              </div>

              {isLoadingCategories && categories.length === 0 ? (
                <div className="p-4 space-y-3">
                  {[1, 2, 3, 4, 5].map((i) => (
                    <div key={i} className="flex items-center gap-3 animate-pulse">
                      <div className="w-8 h-8 rounded-full bg-[#343536]" />
                      <div className="flex-1">
                        <div className="h-4 bg-[#343536] rounded w-32 mb-1" />
                        <div className="h-3 bg-[#343536] rounded w-24" />
                      </div>
                    </div>
                  ))}
                </div>
              ) : topCategories.length > 0 ? (
                <div>
                  {topCategories.map((category, index) => (
                    <CategoryCard key={category.id} category={category} rank={index + 1} />
                  ))}
                </div>
              ) : (
                <div className="p-8 text-center">
                  <p className="text-[#818384]">No communities yet.</p>
                </div>
              )}

              {categories.length > 5 && (
                <Link
                  href="#all-communities"
                  className="block px-4 py-3 text-sm font-medium text-[#ff4500] hover:bg-[#1a1a1b] border-t border-[#343536]"
                >
                  View All Communities
                </Link>
              )}
            </div>

            {/* All Communities */}
            <div id="all-communities" className="bg-[#1a1a1b] border border-[#343536] rounded-lg overflow-hidden">
              <div className="px-4 py-3 border-b border-[#343536]">
                <h2 className="text-sm font-bold text-[#d7dadc]">All Communities</h2>
              </div>

              {!isLoadingCategories && allCategories.length > 0 && (
                <div className="grid gap-px bg-[#343536]">
                  {allCategories.map((category) => (
                    <Link
                      key={category.id}
                      href={`/forum/${category.slug}`}
                      className="bg-[#1a1a1b] p-4 hover:bg-[#272729] transition-colors"
                    >
                      <div className="flex items-start gap-3">
                        <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#ff4500] to-[#ff6f00] flex items-center justify-center text-white text-xl flex-shrink-0">
                          {category.icon || category.name.charAt(0)}
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className="font-medium text-[#d7dadc] mb-0.5">
                            r/{category.slug}
                          </h3>
                          <p className="text-sm text-[#818384] mb-2 line-clamp-2">
                            {category.description}
                          </p>
                          <div className="flex flex-wrap gap-2">
                            {category.subForums.slice(0, 4).map((sf) => (
                              <span
                                key={sf.id}
                                className="text-xs bg-[#272729] text-[#818384] px-2 py-0.5 rounded"
                              >
                                {sf.name}
                              </span>
                            ))}
                            {category.subForums.length > 4 && (
                              <span className="text-xs text-[#818384]">
                                +{category.subForums.length - 4} more
                              </span>
                            )}
                          </div>
                        </div>
                        <div className="text-right text-xs text-[#818384]">
                          <div>{category.postCount} posts</div>
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Sidebar */}
          <aside className="hidden lg:block w-80">
            {/* About */}
            <div className="bg-[#1a1a1b] border border-[#343536] rounded-lg overflow-hidden mb-4">
              <div className="bg-[#ff4500] h-8" />
              <div className="p-4 -mt-4">
                <div className="flex items-end gap-2 mb-3">
                  <div className="w-14 h-14 rounded-full bg-[#1a1a1b] border-4 border-[#1a1a1b] flex items-center justify-center">
                    <RedditIcon className="w-10 h-10 text-[#ff4500]" />
                  </div>
                  <h2 className="font-bold text-[#d7dadc]">About Community</h2>
                </div>
                <p className="text-sm text-[#d7dadc] mb-4">
                  The LOOKSMAXX community is dedicated to self-improvement through evidence-based treatments and lifestyle changes.
                </p>
                <div className="flex gap-4 text-sm mb-4">
                  <div>
                    <div className="font-bold text-[#d7dadc]">{categories.length}</div>
                    <div className="text-xs text-[#818384]">Communities</div>
                  </div>
                  <div>
                    <div className="font-bold text-[#d7dadc]">
                      {categories.reduce((sum, c) => sum + c.postCount, 0)}
                    </div>
                    <div className="text-xs text-[#818384]">Posts</div>
                  </div>
                </div>
                <div className="text-xs text-[#818384] border-t border-[#343536] pt-3">
                  Created Dec 2025
                </div>
              </div>
            </div>

            {/* Quick Links */}
            <div className="bg-[#1a1a1b] border border-[#343536] rounded-lg p-4">
              <h3 className="text-xs font-bold text-[#818384] uppercase tracking-wide mb-3">
                Quick Links
              </h3>
              <div className="space-y-1">
                {categories.slice(0, 6).map((category) => (
                  <CategoryCardCompact key={category.id} category={category} />
                ))}
              </div>
            </div>
          </aside>
        </div>
      </main>
    </div>
  );
}

function RedditIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10zm6.67-10a1.46 1.46 0 00-2.47-1 7.12 7.12 0 00-3.85-1.23l.65-3.06 2.12.45a1 1 0 101.1-.92l-2.38-.5a.56.56 0 00-.65.42l-.73 3.41a7.14 7.14 0 00-3.9 1.23 1.46 1.46 0 10-1.61 2.39 2.87 2.87 0 000 .44c0 2.24 2.61 4.06 5.83 4.06s5.83-1.82 5.83-4.06a2.87 2.87 0 000-.44 1.46 1.46 0 00.86-1.19zm-9.78 1.13a1 1 0 111-1 1 1 0 01-1 1zm5.48 2.73c-.67.44-1.71.52-2.37.52s-1.7-.08-2.37-.52a.26.26 0 01.37-.37c.5.34 1.25.4 2 .4s1.5-.06 2-.4a.26.26 0 01.37.37zm-.37-1.73a1 1 0 111-1 1 1 0 01-1 1z" />
    </svg>
  );
}
