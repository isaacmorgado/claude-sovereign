'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import { useForum } from '@/contexts/ForumContext';
import { CategoryCard } from '@/components/forum';

export default function ForumPage() {
  const { categories, isLoadingCategories, fetchCategories, error } = useForum();

  useEffect(() => {
    fetchCategories();
  }, [fetchCategories]);

  return (
    <div className="min-h-screen bg-black">
      {/* Header */}
      <div className="border-b border-neutral-800">
        <div className="max-w-4xl mx-auto px-4 py-6">
          <div className="flex items-center justify-between">
            <div>
              <Link href="/" className="text-[#00f3ff] text-sm mb-2 block hover:underline">
                &larr; Back to LOOKSMAXX
              </Link>
              <h1 className="text-2xl font-bold text-white">Community Forum</h1>
              <p className="text-neutral-400 text-sm mt-1">
                Discuss treatments, share experiences, and get advice from the community
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Error state */}
        {error && (
          <div className="bg-red-400/10 border border-red-400/20 rounded-lg p-4 mb-6">
            <p className="text-red-400 text-sm">{error}</p>
          </div>
        )}

        {/* Loading state */}
        {isLoadingCategories && categories.length === 0 && (
          <div className="space-y-4">
            {[1, 2, 3, 4].map((i) => (
              <div
                key={i}
                className="bg-neutral-900 border border-neutral-800 rounded-lg p-4 animate-pulse"
              >
                <div className="flex items-start gap-3">
                  <div className="w-8 h-8 bg-neutral-800 rounded" />
                  <div className="flex-1">
                    <div className="h-5 bg-neutral-800 rounded w-1/3 mb-2" />
                    <div className="h-4 bg-neutral-800 rounded w-2/3" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Categories grid */}
        {!isLoadingCategories && categories.length > 0 && (
          <div className="grid gap-4 sm:grid-cols-2">
            {categories.map((category) => (
              <CategoryCard key={category.id} category={category} />
            ))}
          </div>
        )}

        {/* Empty state */}
        {!isLoadingCategories && categories.length === 0 && !error && (
          <div className="text-center py-12">
            <p className="text-neutral-400">No categories available yet.</p>
          </div>
        )}
      </div>
    </div>
  );
}
