'use client';

import { useState } from 'react';
import { SubForum } from '@/types/forum';

interface CreatePostFormProps {
  subForums: SubForum[];
  selectedSubForumId?: string;
  onSubmit: (title: string, content: string, subForumId: string) => Promise<void>;
  onCancel: () => void;
}

export function CreatePostForm({
  subForums,
  selectedSubForumId,
  onSubmit,
  onCancel,
}: CreatePostFormProps) {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [subForumId, setSubForumId] = useState(selectedSubForumId || (subForums[0]?.id ?? ''));
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!title.trim() || title.length < 5) {
      setError('Title must be at least 5 characters');
      return;
    }

    if (!content.trim() || content.length < 10) {
      setError('Content must be at least 10 characters');
      return;
    }

    if (!subForumId) {
      setError('Please select a sub-forum');
      return;
    }

    setIsSubmitting(true);
    try {
      await onSubmit(title.trim(), content.trim(), subForumId);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create post');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {/* Sub-forum selector */}
      <div>
        <label className="block text-sm text-neutral-400 mb-1.5">
          Choose a community
        </label>
        {subForums.length === 0 ? (
          <p className="text-yellow-400 text-sm bg-yellow-400/10 border border-yellow-400/20 rounded-lg px-4 py-2">
            No sub-forums available for this category.
          </p>
        ) : (
          <select
            value={subForumId}
            onChange={(e) => setSubForumId(e.target.value)}
            className="w-full bg-neutral-900 border border-neutral-700 rounded-lg px-4 py-2.5 text-white text-sm focus:border-[#00f3ff] focus:outline-none"
          >
            {subForums.map((sf) => (
              <option key={sf.id} value={sf.id}>
                {sf.name}
              </option>
            ))}
          </select>
        )}
      </div>

      {/* Title */}
      <div>
        <label className="block text-sm text-neutral-400 mb-1.5">
          Title
        </label>
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="An interesting title"
          maxLength={200}
          className="w-full bg-neutral-900 border border-neutral-700 rounded-lg px-4 py-2.5 text-white text-sm placeholder-neutral-500 focus:border-[#00f3ff] focus:outline-none"
        />
        <div className="text-xs text-neutral-500 mt-1 text-right">
          {title.length}/200
        </div>
      </div>

      {/* Content */}
      <div>
        <label className="block text-sm text-neutral-400 mb-1.5">
          Text
        </label>
        <textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Share your experience, ask a question, or start a discussion..."
          rows={8}
          maxLength={10000}
          className="w-full bg-neutral-900 border border-neutral-700 rounded-lg px-4 py-3 text-white text-sm placeholder-neutral-500 focus:border-[#00f3ff] focus:outline-none resize-none"
        />
        <div className="text-xs text-neutral-500 mt-1 text-right">
          {content.length}/10000
        </div>
      </div>

      {/* Error */}
      {error && (
        <div className="text-red-400 text-sm bg-red-400/10 border border-red-400/20 rounded-lg px-4 py-2">
          {error}
        </div>
      )}

      {/* Actions */}
      <div className="flex justify-end gap-3 pt-2">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 text-neutral-400 text-sm hover:text-white transition-colors"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={isSubmitting || !title.trim() || !content.trim()}
          className="px-6 py-2 bg-[#00f3ff] text-black text-sm font-medium rounded-lg hover:bg-[#00f3ff]/90 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {isSubmitting ? 'Posting...' : 'Post'}
        </button>
      </div>
    </form>
  );
}
