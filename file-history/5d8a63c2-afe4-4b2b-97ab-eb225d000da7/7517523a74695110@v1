'use client';

import Link from 'next/link';
import { PostListItem, VoteType } from '@/types/forum';
import { formatDistanceToNow } from '@/lib/utils';
import { VoteButtons } from './VoteButtons';

interface PostCardProps {
  post: PostListItem;
  onVote?: (postId: string, voteType: VoteType) => void;
}

export function PostCard({ post, onVote }: PostCardProps) {
  return (
    <div className="bg-neutral-900 border border-neutral-800 rounded-lg p-4 hover:border-neutral-700 transition-colors">
      <div className="flex gap-3">
        {/* Vote buttons */}
        <VoteButtons
          voteCount={post.voteCount}
          userVote={post.userVote}
          onVote={(voteType) => onVote?.(post.id, voteType)}
          size="sm"
        />

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 text-xs text-neutral-500 mb-1">
            {post.isPinned && (
              <span className="bg-[#00f3ff]/10 text-[#00f3ff] px-1.5 py-0.5 rounded text-[10px] font-medium">
                PINNED
              </span>
            )}
            {post.isGuide && (
              <span className="bg-green-500/10 text-green-400 px-1.5 py-0.5 rounded text-[10px] font-medium">
                GUIDE
              </span>
            )}
            <span>Posted by u/{post.author.username}</span>
            <span>·</span>
            <span>{formatDistanceToNow(post.createdAt)}</span>
          </div>

          <Link href={`/forum/post/${post.id}`}>
            <h3 className="text-white font-medium hover:text-[#00f3ff] transition-colors line-clamp-2">
              {post.title}
            </h3>
          </Link>

          <p className="text-neutral-400 text-sm mt-1 line-clamp-2">
            {post.contentPreview}
          </p>

          <div className="flex items-center gap-4 mt-2 text-xs text-neutral-500">
            <Link
              href={`/forum/post/${post.id}`}
              className="flex items-center gap-1 hover:text-neutral-300"
            >
              <CommentIcon className="w-4 h-4" />
              <span>{post.commentCount} comments</span>
            </Link>
            <button className="flex items-center gap-1 hover:text-neutral-300">
              <ShareIcon className="w-4 h-4" />
              <span>Share</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function CommentIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={1.5}
        d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
      />
    </svg>
  );
}

function ShareIcon({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth={1.5}
        d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z"
      />
    </svg>
  );
}
