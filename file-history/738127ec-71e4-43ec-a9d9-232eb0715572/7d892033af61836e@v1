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
      setError('Please select a topic');
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
      {/* Topic selector */}
      <div>
        <label className="block text-xs font-bold text-[#818384] uppercase tracking-wide mb-2">
          Choose a topic
        </label>
        {subForums.length === 0 ? (
          <p className="text-[#ff4500] text-sm bg-[#ff4500]/10 border border-[#ff4500]/20 rounded px-4 py-2">
            No topics available for this community.
          </p>
        ) : (
          <select
            value={subForumId}
            onChange={(e) => setSubForumId(e.target.value)}
            className="w-full bg-[#272729] border border-[#343536] rounded px-4 py-2.5 text-[#d7dadc] text-sm focus:border-[#d7dadc] focus:outline-none appearance-none cursor-pointer"
            style={{
              backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%23818384'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E")`,
              backgroundRepeat: 'no-repeat',
              backgroundPosition: 'right 12px center',
              backgroundSize: '16px',
            }}
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
        <label className="block text-xs font-bold text-[#818384] uppercase tracking-wide mb-2">
          Title
        </label>
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="An interesting title"
          maxLength={200}
          className="w-full bg-[#272729] border border-[#343536] rounded px-4 py-2.5 text-[#d7dadc] text-sm placeholder-[#818384] focus:border-[#d7dadc] focus:outline-none"
        />
        <div className="text-xs text-[#818384] mt-1 text-right">
          {title.length}/200
        </div>
      </div>

      {/* Content */}
      <div>
        <label className="block text-xs font-bold text-[#818384] uppercase tracking-wide mb-2">
          Text
        </label>
        <textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Share your experience, ask a question, or start a discussion..."
          rows={8}
          maxLength={10000}
          className="w-full bg-[#272729] border border-[#343536] rounded px-4 py-3 text-[#d7dadc] text-sm placeholder-[#818384] focus:border-[#d7dadc] focus:outline-none resize-y min-h-[120px]"
        />
        <div className="text-xs text-[#818384] mt-1 text-right">
          {content.length}/10000
        </div>
      </div>

      {/* Error */}
      {error && (
        <div className="text-[#ff4500] text-sm bg-[#ff4500]/10 border border-[#ff4500]/20 rounded px-4 py-2">
          {error}
        </div>
      )}

      {/* Actions */}
      <div className="flex justify-end gap-3 pt-2 border-t border-[#343536]">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-1.5 text-sm font-bold text-[#ff4500] border border-[#ff4500] rounded-full hover:bg-[#ff4500]/10 transition-colors"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={isSubmitting || !title.trim() || !content.trim() || !subForumId}
          className="px-6 py-1.5 bg-[#ff4500] text-white text-sm font-bold rounded-full hover:bg-[#ff5722] disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {isSubmitting ? 'Posting...' : 'Post'}
        </button>
      </div>
    </form>
  );
}
