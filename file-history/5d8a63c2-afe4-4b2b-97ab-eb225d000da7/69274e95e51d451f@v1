'use client';

import Link from 'next/link';
import { Category } from '@/types/forum';

interface CategoryCardProps {
  category: Category;
}

export function CategoryCard({ category }: CategoryCardProps) {
  return (
    <Link href={`/forum/${category.slug}`}>
      <div className="bg-neutral-900 border border-neutral-800 rounded-lg p-4 hover:border-[#00f3ff]/30 transition-colors">
        <div className="flex items-start gap-3">
          {category.icon && (
            <span className="text-2xl">{category.icon}</span>
          )}
          <div className="flex-1 min-w-0">
            <h3 className="text-white font-medium truncate">{category.name}</h3>
            {category.description && (
              <p className="text-neutral-400 text-sm mt-1 line-clamp-2">
                {category.description}
              </p>
            )}
            <div className="flex items-center gap-4 mt-2 text-xs text-neutral-500">
              <span>{category.postCount} posts</span>
              <span>{category.subForums.length} sub-forums</span>
            </div>
          </div>
        </div>

        {category.subForums.length > 0 && (
          <div className="mt-3 pt-3 border-t border-neutral-800">
            <div className="flex flex-wrap gap-2">
              {category.subForums.slice(0, 4).map((sf) => (
                <span
                  key={sf.id}
                  className="inline-flex items-center px-2 py-0.5 text-xs bg-neutral-800 text-neutral-300 rounded"
                >
                  {sf.name}
                </span>
              ))}
              {category.subForums.length > 4 && (
                <span className="text-xs text-neutral-500">
                  +{category.subForums.length - 4} more
                </span>
              )}
            </div>
          </div>
        )}
      </div>
    </Link>
  );
}
