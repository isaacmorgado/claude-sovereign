'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { useForum } from '@/contexts/ForumContext';
import { VoteButtons, CommentThread, ForumHeader } from '@/components/forum';
import { formatDistanceToNow } from '@/lib/utils';

export default function PostDetailPage() {
  const params = useParams();
  const router = useRouter();
  const postId = params.postId as string;

  const {
    currentPost,
    comments,
    isLoadingPosts,
    isLoadingComments,
    fetchPost,
    fetchComments,
    votePost,
    voteComment,
    createComment,
    updateComment,
    deleteComment,
    deletePost,
    error,
  } = useForum();

  const [newComment, setNewComment] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    fetchPost(postId);
    fetchComments(postId);
  }, [postId, fetchPost, fetchComments]);

  const handleSubmitComment = async () => {
    if (!newComment.trim()) return;

    setIsSubmitting(true);
    try {
      await createComment(postId, newComment.trim());
      setNewComment('');
    } catch {
      // Error is handled in context
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleReply = async (parentId: string, content: string) => {
    try {
      await createComment(postId, content, parentId);
      // Refetch to get updated comment tree
      fetchComments(postId);
    } catch {
      // Error handled in context
    }
  };

  const handleDeletePost = async () => {
    if (!confirm('Are you sure you want to delete this post?')) return;

    try {
      await deletePost(postId);
      router.push('/forum');
    } catch {
      // Error handled in context
    }
  };

  // Get current user ID from localStorage (if logged in)
  const getCurrentUserId = (): string | undefined => {
    if (typeof window === 'undefined') return undefined;
    const token = localStorage.getItem('auth_token');
    if (!token) return undefined;
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      return payload.sub;
    } catch {
      return undefined;
    }
  };

  const currentUserId = getCurrentUserId();
  const isPostOwner = currentUserId && currentPost?.author.id === currentUserId;

  return (
    <div className="min-h-screen bg-black">
      <ForumHeader />

      {/* Breadcrumb */}
      <div className="border-b border-neutral-800">
        <div className="max-w-4xl mx-auto px-4 py-4">
          {currentPost ? (
            <Link
              href={`/forum/${currentPost.categorySlug}`}
              className="text-[#00f3ff] text-sm hover:underline"
            >
              &larr; Back to {currentPost.categorySlug.replace(/-/g, ' ')}
            </Link>
          ) : (
            <Link href="/forum" className="text-[#00f3ff] text-sm hover:underline">
              &larr; Back to Forum
            </Link>
          )}
        </div>
      </div>

      {/* Content */}
      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Error */}
        {error && (
          <div className="bg-red-400/10 border border-red-400/20 rounded-lg p-4 mb-4">
            <p className="text-red-400 text-sm">{error}</p>
          </div>
        )}

        {/* Loading */}
        {isLoadingPosts && !currentPost && (
          <div className="bg-neutral-900 border border-neutral-800 rounded-lg p-6 animate-pulse">
            <div className="flex gap-4">
              <div className="w-8 space-y-2">
                <div className="h-4 bg-neutral-800 rounded" />
                <div className="h-4 bg-neutral-800 rounded" />
                <div className="h-4 bg-neutral-800 rounded" />
              </div>
              <div className="flex-1">
                <div className="h-4 bg-neutral-800 rounded w-1/4 mb-2" />
                <div className="h-6 bg-neutral-800 rounded w-3/4 mb-4" />
                <div className="h-4 bg-neutral-800 rounded w-full mb-2" />
                <div className="h-4 bg-neutral-800 rounded w-full mb-2" />
                <div className="h-4 bg-neutral-800 rounded w-2/3" />
              </div>
            </div>
          </div>
        )}

        {/* Post */}
        {currentPost && (
          <div className="bg-neutral-900 border border-neutral-800 rounded-lg p-6">
            <div className="flex gap-4">
              {/* Vote buttons */}
              <VoteButtons
                voteCount={currentPost.voteCount}
                userVote={currentPost.userVote}
                onVote={(voteType) => votePost(postId, voteType)}
              />

              {/* Post content */}
              <div className="flex-1 min-w-0">
                {/* Meta */}
                <div className="flex items-center gap-2 text-xs text-neutral-500 mb-2">
                  {currentPost.isPinned && (
                    <span className="bg-[#00f3ff]/10 text-[#00f3ff] px-1.5 py-0.5 rounded text-[10px] font-medium">
                      PINNED
                    </span>
                  )}
                  {currentPost.isGuide && (
                    <span className="bg-green-500/10 text-green-400 px-1.5 py-0.5 rounded text-[10px] font-medium">
                      GUIDE
                    </span>
                  )}
                  <span>Posted by u/{currentPost.author.username}</span>
                  <span>·</span>
                  <span>{formatDistanceToNow(currentPost.createdAt)}</span>
                  {currentPost.updatedAt !== currentPost.createdAt && (
                    <>
                      <span>·</span>
                      <span className="italic">edited</span>
                    </>
                  )}
                </div>

                {/* Title */}
                <h1 className="text-xl font-semibold text-white mb-4">
                  {currentPost.title}
                </h1>

                {/* Content */}
                <div className="text-neutral-300 whitespace-pre-wrap leading-relaxed">
                  {currentPost.content}
                </div>

                {/* Actions */}
                <div className="flex items-center gap-4 mt-4 pt-4 border-t border-neutral-800 text-xs text-neutral-500">
                  <span>{currentPost.commentCount} comments</span>
                  <button className="hover:text-neutral-300">Share</button>
                  <button className="hover:text-neutral-300">Save</button>
                  <button className="hover:text-neutral-300">Report</button>
                  {isPostOwner && (
                    <button
                      onClick={handleDeletePost}
                      className="hover:text-red-400"
                    >
                      Delete
                    </button>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Comment input */}
        {currentPost && (
          <div className="mt-6">
            <h2 className="text-lg font-medium text-white mb-4">
              Comments ({currentPost.commentCount})
            </h2>

            <div className="bg-neutral-900 border border-neutral-800 rounded-lg p-4 mb-6">
              <textarea
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
                placeholder="What are your thoughts?"
                rows={4}
                className="w-full bg-transparent text-white placeholder-neutral-500 text-sm resize-none focus:outline-none"
              />
              <div className="flex justify-end mt-2">
                <button
                  onClick={handleSubmitComment}
                  disabled={isSubmitting || !newComment.trim()}
                  className="px-4 py-2 bg-[#00f3ff] text-black text-sm font-medium rounded hover:bg-[#00f3ff]/90 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isSubmitting ? 'Posting...' : 'Comment'}
                </button>
              </div>
            </div>

            {/* Comments list */}
            {isLoadingComments && comments.length === 0 ? (
              <div className="space-y-4">
                {[1, 2].map((i) => (
                  <div key={i} className="animate-pulse">
                    <div className="flex gap-3">
                      <div className="w-6 space-y-2">
                        <div className="h-4 bg-neutral-800 rounded" />
                        <div className="h-4 bg-neutral-800 rounded" />
                      </div>
                      <div className="flex-1">
                        <div className="h-3 bg-neutral-800 rounded w-1/4 mb-2" />
                        <div className="h-4 bg-neutral-800 rounded w-full mb-1" />
                        <div className="h-4 bg-neutral-800 rounded w-2/3" />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : comments.length > 0 ? (
              <CommentThread
                comments={comments}
                onVote={(commentId, voteType) => voteComment(commentId, voteType)}
                onReply={handleReply}
                onEdit={(commentId, content) => updateComment(commentId, content)}
                onDelete={(commentId) => deleteComment(commentId)}
                currentUserId={currentUserId}
              />
            ) : (
              <div className="text-center py-8 text-neutral-400">
                <p>No comments yet. Be the first to comment!</p>
              </div>
            )}
          </div>
        )}

        {/* Post not found */}
        {!isLoadingPosts && !currentPost && !error && (
          <div className="text-center py-12">
            <h2 className="text-xl font-medium text-white mb-2">Post not found</h2>
            <p className="text-neutral-400 mb-4">
              The post you&apos;re looking for doesn&apos;t exist or has been deleted.
            </p>
            <Link href="/forum" className="text-[#00f3ff] hover:underline">
              Go back to forum
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
