'use client';

import Link from 'next/link';
import { Category } from '@/types/forum';

interface CategoryCardProps {
  category: Category;
  rank?: number;
}

export function CategoryCard({ category, rank }: CategoryCardProps) {
  return (
    <Link href={`/forum/${category.slug}`}>
      <div className="flex items-center gap-3 p-3 hover:bg-[#1a1a1b] rounded transition-colors group">
        {/* Rank number */}
        {rank !== undefined && (
          <span className="text-sm font-medium text-[#818384] w-5">{rank}</span>
        )}

        {/* Community icon */}
        <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#ff4500] to-[#ff6f00] flex items-center justify-center text-white text-lg flex-shrink-0">
          {category.icon || category.name.charAt(0)}
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <h3 className="text-sm font-medium text-[#d7dadc] group-hover:text-white truncate">
            r/{category.slug}
          </h3>
          <p className="text-xs text-[#818384] truncate">
            {category.postCount} posts • {category.subForums.length} topics
          </p>
        </div>

        {/* Join button placeholder */}
        <button
          className="px-4 py-1 text-xs font-bold bg-[#d7dadc] text-[#1a1a1b] rounded-full hover:bg-white transition-colors"
          onClick={(e) => e.preventDefault()}
        >
          View
        </button>
      </div>
    </Link>
  );
}

// Compact version for sidebar
export function CategoryCardCompact({ category }: { category: Category }) {
  return (
    <Link href={`/forum/${category.slug}`}>
      <div className="flex items-center gap-2 py-2 px-2 hover:bg-[#343536] rounded transition-colors group">
        <div className="w-6 h-6 rounded-full bg-gradient-to-br from-[#ff4500] to-[#ff6f00] flex items-center justify-center text-white text-xs flex-shrink-0">
          {category.icon || category.name.charAt(0)}
        </div>
        <span className="text-sm text-[#d7dadc] group-hover:text-white truncate">
          r/{category.slug}
        </span>
      </div>
    </Link>
  );
}
