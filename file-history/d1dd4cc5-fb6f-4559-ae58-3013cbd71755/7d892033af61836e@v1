'use client';

import { useState } from 'react';
import { ChevronDown, AlertCircle } from 'lucide-react';
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
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Topic selector */}
      <div>
        <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500 mb-3">
          Choose a Topic
        </label>
        {subForums.length === 0 ? (
          <div className="flex items-center gap-3 p-4 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400 text-sm">
            <AlertCircle size={16} />
            No topics available for this community.
          </div>
        ) : (
          <div className="relative">
            <select
              value={subForumId}
              onChange={(e) => setSubForumId(e.target.value)}
              className="w-full bg-neutral-900/50 border border-white/10 rounded-xl px-5 py-3.5 text-white text-sm focus:border-cyan-500/50 focus:outline-none appearance-none cursor-pointer hover:border-white/20 transition-colors"
            >
              {subForums.map((sf) => (
                <option key={sf.id} value={sf.id} className="bg-neutral-900">
                  {sf.name}
                </option>
              ))}
            </select>
            <ChevronDown size={16} className="absolute right-4 top-1/2 -translate-y-1/2 text-neutral-500 pointer-events-none" />
          </div>
        )}
      </div>

      {/* Title */}
      <div>
        <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500 mb-3">
          Title
        </label>
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="An interesting title"
          maxLength={200}
          className="w-full bg-neutral-900/50 border border-white/10 rounded-xl px-5 py-3.5 text-white text-sm placeholder-neutral-600 focus:border-cyan-500/50 focus:outline-none hover:border-white/20 transition-colors"
        />
        <div className="text-[10px] text-neutral-600 mt-2 text-right font-medium">
          {title.length}/200
        </div>
      </div>

      {/* Content */}
      <div>
        <label className="block text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500 mb-3">
          Content
        </label>
        <textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Share your experience, ask a question, or start a discussion..."
          rows={8}
          maxLength={10000}
          className="w-full bg-neutral-900/50 border border-white/10 rounded-xl px-5 py-4 text-white text-sm placeholder-neutral-600 focus:border-cyan-500/50 focus:outline-none resize-y min-h-[150px] hover:border-white/20 transition-colors"
        />
        <div className="text-[10px] text-neutral-600 mt-2 text-right font-medium">
          {content.length}/10000
        </div>
      </div>

      {/* Error */}
      {error && (
        <div className="flex items-center gap-3 p-4 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400 text-sm">
          <AlertCircle size={16} />
          {error}
        </div>
      )}

      {/* Actions */}
      <div className="flex justify-end gap-4 pt-4 border-t border-white/5">
        <button
          type="button"
          onClick={onCancel}
          className="px-6 py-2.5 text-[10px] font-black uppercase tracking-widest text-neutral-500 border border-white/10 rounded-xl hover:bg-white/5 hover:text-white transition-all"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={isSubmitting || !title.trim() || !content.trim() || !subForumId}
          className="px-8 py-2.5 bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest rounded-xl hover:bg-cyan-400 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg shadow-cyan-500/20"
        >
          {isSubmitting ? 'Posting...' : 'Post'}
        </button>
      </div>
    </form>
  );
}
