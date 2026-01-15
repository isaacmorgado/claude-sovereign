'use client';

import Link from 'next/link';
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
    <article className="bg-[#1a1a1b] border border-[#343536] rounded hover:border-[#818384] transition-colors flex">
      {/* Vote column */}
      <div className="w-10 bg-[#161617] rounded-l flex flex-col items-center py-2">
        <VoteButtons
          voteCount={post.voteCount}
          userVote={post.userVote}
          onVote={(voteType) => onVote?.(post.id, voteType)}
          size="sm"
        />
      </div>

      {/* Content */}
      <div className="flex-1 py-2 px-2 min-w-0">
        {/* Meta line */}
        <div className="flex items-center flex-wrap gap-x-1 text-xs text-[#818384] mb-1">
          {post.isPinned && (
            <span className="text-[#46d160] font-medium mr-1">
              <PinIcon className="w-3 h-3 inline mr-0.5" />
              Pinned
            </span>
          )}
          {post.isGuide && (
            <span className="bg-[#00f3ff]/10 text-[#00f3ff] px-1.5 py-0.5 rounded text-[10px] font-medium mr-1">
              GUIDE
            </span>
          )}
          {showSubForum && (
            <>
              <Link
                href={`/forum/${post.categorySlug}`}
                className="font-medium text-[#d7dadc] hover:underline"
              >
                r/{post.subForumSlug}
              </Link>
              <span>•</span>
            </>
          )}
          <span>Posted by</span>
          <Link href="#" className="hover:underline">u/{post.author.username}</Link>
          <span>{formatDistanceToNow(post.createdAt)}</span>
        </div>

        {/* Title */}
        <Link href={`/forum/post/${post.id}`}>
          <h3 className="text-lg font-medium text-[#d7dadc] hover:text-white leading-tight mb-1">
            {post.title}
          </h3>
        </Link>

        {/* Preview text */}
        {post.contentPreview && (
          <p className="text-[#818384] text-sm line-clamp-2 mb-2">
            {post.contentPreview}
          </p>
        )}

        {/* Action bar */}
        <div className="flex items-center gap-1 text-xs text-[#818384] font-medium">
          <Link
            href={`/forum/post/${post.id}`}
            className="flex items-center gap-1.5 px-2 py-1.5 rounded hover:bg-[#343536] transition-colors"
          >
            <CommentIcon className="w-4 h-4" />
            <span>{post.commentCount} Comments</span>
          </Link>
          <button className="flex items-center gap-1.5 px-2 py-1.5 rounded hover:bg-[#343536] transition-colors">
            <ShareIcon className="w-4 h-4" />
            <span>Share</span>
          </button>
          <button className="flex items-center gap-1.5 px-2 py-1.5 rounded hover:bg-[#343536] transition-colors">
            <BookmarkIcon className="w-4 h-4" />
            <span>Save</span>
          </button>
          <button className="flex items-center gap-1.5 p-1.5 rounded hover:bg-[#343536] transition-colors">
            <MoreIcon className="w-4 h-4" />
          </button>
        </div>
      </div>
    </article>
  );
}

function CommentIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path d="M2 5a2 2 0 012-2h12a2 2 0 012 2v8a2 2 0 01-2 2h-2.5l-2.5 3-2.5-3H4a2 2 0 01-2-2V5zm3.5 2a.5.5 0 000 1h9a.5.5 0 000-1h-9zm0 3a.5.5 0 000 1h6a.5.5 0 000-1h-6z" />
    </svg>
  );
}

function ShareIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path d="M15 8a3 3 0 10-2.977-2.63l-4.94 2.47a3 3 0 100 4.319l4.94 2.47a3 3 0 10.895-1.789l-4.94-2.47a3.027 3.027 0 000-.74l4.94-2.47C13.456 7.68 14.19 8 15 8z" />
    </svg>
  );
}

function BookmarkIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path d="M5 4a2 2 0 012-2h6a2 2 0 012 2v14l-5-2.5L5 18V4z" />
    </svg>
  );
}

function MoreIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path d="M6 10a2 2 0 11-4 0 2 2 0 014 0zM12 10a2 2 0 11-4 0 2 2 0 014 0zM16 12a2 2 0 100-4 2 2 0 000 4z" />
    </svg>
  );
}

function PinIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
    </svg>
  );
}
