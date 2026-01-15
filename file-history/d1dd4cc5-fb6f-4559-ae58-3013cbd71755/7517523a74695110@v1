'use client';

import Link from 'next/link';
import { MessageSquare, Share2, Bookmark, MoreHorizontal, Pin, Sparkles } from 'lucide-react';
import { PostListItem, VoteType } from '@/types/forum';
import { formatDistanceToNow } from '@/lib/utils';
import { VoteButtons } from './VoteButtons';

interface PostCardProps {
  post: PostListItem;
  onVote?: (postId: string, voteType: VoteType) => void;
  showSubForum?: boolean;
}

export function PostCard({ post, onVote, showSubForum = false }: PostCardProps) {
  return (
    <article className="group relative rounded-2xl bg-neutral-900/30 border border-white/5 hover:border-cyan-500/20 transition-all overflow-hidden">
      <div className="flex">
        {/* Vote column */}
        <div className="w-12 bg-neutral-900/50 border-r border-white/5 flex flex-col items-center py-4">
          <VoteButtons
            voteCount={post.voteCount}
            userVote={post.userVote}
            onVote={(voteType) => onVote?.(post.id, voteType)}
            size="sm"
          />
        </div>

        {/* Content */}
        <div className="flex-1 p-4 min-w-0">
          {/* Meta line */}
          <div className="flex items-center flex-wrap gap-2 mb-3">
            {post.isPinned && (
              <span className="flex items-center gap-1 px-2 py-0.5 rounded-md bg-cyan-500/10 border border-cyan-500/20 text-[9px] font-black uppercase tracking-wider text-cyan-400">
                <Pin size={10} />
                Pinned
              </span>
            )}
            {post.isGuide && (
              <span className="flex items-center gap-1 px-2 py-0.5 rounded-md bg-green-500/10 border border-green-500/20 text-[9px] font-black uppercase tracking-wider text-green-400">
                <Sparkles size={10} />
                Guide
              </span>
            )}
            {showSubForum && (
              <Link
                href={`/forum/${post.categorySlug}`}
                className="text-[10px] font-black uppercase tracking-widest text-cyan-400 hover:text-cyan-300"
              >
                {post.subForumSlug}
              </Link>
            )}
            <span className="text-[10px] font-medium text-neutral-600">
              by <span className="text-neutral-400">u/{post.author.username}</span>
            </span>
            <span className="text-[10px] text-neutral-700">•</span>
            <span className="text-[10px] text-neutral-600">{formatDistanceToNow(post.createdAt)}</span>
          </div>

          {/* Title */}
          <Link href={`/forum/post/${post.id}`}>
            <h3 className="text-base font-bold text-white group-hover:text-cyan-400 transition-colors leading-snug mb-2">
              {post.title}
            </h3>
          </Link>

          {/* Preview text */}
          {post.contentPreview && (
            <p className="text-neutral-500 text-sm line-clamp-2 mb-4 leading-relaxed">
              {post.contentPreview}
            </p>
          )}

          {/* Action bar */}
          <div className="flex items-center gap-1">
            <Link
              href={`/forum/post/${post.id}`}
              className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-500 hover:bg-white/5 hover:text-cyan-400 transition-all"
            >
              <MessageSquare size={14} />
              <span>{post.commentCount} Comments</span>
            </Link>
            <button className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-500 hover:bg-white/5 hover:text-white transition-all">
              <Share2 size={14} />
              <span className="hidden sm:inline">Share</span>
            </button>
            <button className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-500 hover:bg-white/5 hover:text-white transition-all">
              <Bookmark size={14} />
              <span className="hidden sm:inline">Save</span>
            </button>
            <button className="flex items-center gap-2 p-1.5 rounded-lg text-neutral-500 hover:bg-white/5 hover:text-white transition-all">
              <MoreHorizontal size={14} />
            </button>
          </div>
        </div>
      </div>
    </article>
  );
}
