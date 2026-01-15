'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { useForum } from '@/contexts/ForumContext';
import { VoteButtons, CommentThread, ForumHeader, ForumBreadcrumb } from '@/components/forum';
import { formatDistanceToNow } from '@/lib/utils';
import {
  MessageSquare,
  Share2,
  Bookmark,
  Flag,
  Trash2,
  Pin,
  Sparkles,
  Send
} from 'lucide-react';

// ============================================
// COMMENT SKELETON
// ============================================
function CommentSkeleton() {
  return (
    <div className="flex gap-4 animate-pulse">
      <div className="w-8 space-y-2">
        <div className="h-5 w-5 bg-neutral-800 rounded mx-auto" />
        <div className="h-4 w-4 bg-neutral-800 rounded mx-auto" />
        <div className="h-5 w-5 bg-neutral-800 rounded mx-auto" />
      </div>
      <div className="flex-1 space-y-2">
        <div className="h-3 w-32 bg-neutral-800 rounded" />
        <div className="h-4 w-full bg-neutral-800 rounded" />
        <div className="h-4 w-2/3 bg-neutral-800 rounded" />
      </div>
    </div>
  );
}

// ============================================
// POST SKELETON
// ============================================
function PostSkeleton() {
  return (
    <div className="rounded-2xl bg-neutral-900/30 border border-white/5 p-6 animate-pulse">
      <div className="flex gap-6">
        <div className="w-10 space-y-2">
          <div className="h-6 w-6 bg-neutral-800 rounded mx-auto" />
          <div className="h-4 w-4 bg-neutral-800 rounded mx-auto" />
          <div className="h-6 w-6 bg-neutral-800 rounded mx-auto" />
        </div>
        <div className="flex-1 space-y-4">
          <div className="h-4 w-48 bg-neutral-800 rounded" />
          <div className="h-6 w-3/4 bg-neutral-800 rounded" />
          <div className="space-y-2">
            <div className="h-4 w-full bg-neutral-800 rounded" />
            <div className="h-4 w-full bg-neutral-800 rounded" />
            <div className="h-4 w-2/3 bg-neutral-800 rounded" />
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================
// MAIN PAGE
// ============================================
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
    <div className="min-h-screen bg-black selection:bg-cyan-500/30">
      <ForumHeader />
      <ForumBreadcrumb items={[
        { label: 'Community', href: '/forum' },
        ...(currentPost ? [{ label: currentPost.categorySlug.replace(/-/g, ' '), href: `/forum/${currentPost.categorySlug}` }] : []),
        { label: 'Post' }
      ]} />

      {/* Content */}
      <div className="max-w-4xl mx-auto px-6 py-10">
        {/* Error */}
        {error && (
          <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/20 mb-6">
            <p className="text-red-400 text-sm">{error}</p>
          </div>
        )}

        {/* Loading */}
        {isLoadingPosts && !currentPost && <PostSkeleton />}

        {/* Post */}
        {currentPost && (
          <article className="rounded-2xl bg-neutral-900/30 border border-white/5 p-6 mb-8">
            <div className="flex gap-6">
              {/* Vote buttons */}
              <div className="flex-shrink-0">
                <VoteButtons
                  voteCount={currentPost.voteCount}
                  userVote={currentPost.userVote}
                  onVote={(voteType) => votePost(postId, voteType)}
                />
              </div>

              {/* Post content */}
              <div className="flex-1 min-w-0">
                {/* Meta */}
                <div className="flex items-center flex-wrap gap-2 mb-4">
                  {currentPost.isPinned && (
                    <span className="flex items-center gap-1 px-2 py-0.5 rounded-md bg-cyan-500/10 border border-cyan-500/20 text-[9px] font-black uppercase tracking-wider text-cyan-400">
                      <Pin size={10} />
                      Pinned
                    </span>
                  )}
                  {currentPost.isGuide && (
                    <span className="flex items-center gap-1 px-2 py-0.5 rounded-md bg-green-500/10 border border-green-500/20 text-[9px] font-black uppercase tracking-wider text-green-400">
                      <Sparkles size={10} />
                      Guide
                    </span>
                  )}
                  <span className="text-[10px] text-neutral-500">
                    Posted by <span className="text-cyan-400 font-bold">u/{currentPost.author.username}</span>
                  </span>
                  <span className="text-neutral-700">•</span>
                  <span className="text-[10px] text-neutral-600">{formatDistanceToNow(currentPost.createdAt)}</span>
                  {currentPost.updatedAt !== currentPost.createdAt && (
                    <>
                      <span className="text-neutral-700">•</span>
                      <span className="text-[10px] text-neutral-600 italic">edited</span>
                    </>
                  )}
                </div>

                {/* Title */}
                <h1 className="text-2xl font-black tracking-tight text-white mb-5">
                  {currentPost.title}
                </h1>

                {/* Content */}
                <div className="text-neutral-300 text-sm leading-relaxed whitespace-pre-wrap mb-6">
                  {currentPost.content}
                </div>

                {/* Actions */}
                <div className="flex items-center gap-2 pt-5 border-t border-white/5">
                  <span className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-500">
                    <MessageSquare size={14} />
                    {currentPost.commentCount} Comments
                  </span>
                  <button className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-500 hover:bg-white/5 hover:text-white transition-all">
                    <Share2 size={14} />
                    Share
                  </button>
                  <button className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-500 hover:bg-white/5 hover:text-white transition-all">
                    <Bookmark size={14} />
                    Save
                  </button>
                  <button className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-500 hover:bg-white/5 hover:text-white transition-all">
                    <Flag size={14} />
                    Report
                  </button>
                  {isPostOwner && (
                    <button
                      onClick={handleDeletePost}
                      className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider text-neutral-500 hover:bg-red-500/10 hover:text-red-400 transition-all"
                    >
                      <Trash2 size={14} />
                      Delete
                    </button>
                  )}
                </div>
              </div>
            </div>
          </article>
        )}

        {/* Comment Section */}
        {currentPost && (
          <section>
            <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-6 flex items-center gap-4">
              Comments ({currentPost.commentCount})
              <div className="flex-1 h-px bg-neutral-900" />
            </h2>

            {/* Comment Input */}
            <div className="rounded-2xl bg-neutral-900/30 border border-white/5 p-5 mb-8">
              <textarea
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
                placeholder="What are your thoughts?"
                rows={4}
                className="w-full bg-transparent text-white placeholder-neutral-600 text-sm resize-none focus:outline-none leading-relaxed"
              />
              <div className="flex justify-end mt-3 pt-3 border-t border-white/5">
                <button
                  onClick={handleSubmitComment}
                  disabled={isSubmitting || !newComment.trim()}
                  className="flex items-center gap-2 px-5 py-2.5 bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest rounded-xl hover:bg-cyan-400 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg shadow-cyan-500/20"
                >
                  <Send size={12} />
                  {isSubmitting ? 'Posting...' : 'Comment'}
                </button>
              </div>
            </div>

            {/* Comments List */}
            {isLoadingComments && comments.length === 0 ? (
              <div className="space-y-6">
                {[1, 2].map((i) => (
                  <CommentSkeleton key={i} />
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
              <div className="text-center py-12 rounded-2xl bg-neutral-900/30 border border-white/5">
                <MessageSquare size={32} className="mx-auto text-neutral-700 mb-3" />
                <p className="text-neutral-400">No comments yet. Be the first to comment!</p>
              </div>
            )}
          </section>
        )}

        {/* Post not found */}
        {!isLoadingPosts && !currentPost && !error && (
          <div className="text-center py-16 rounded-2xl bg-neutral-900/30 border border-white/5">
            <h2 className="text-xl font-black text-white mb-3">Post not found</h2>
            <p className="text-neutral-400 mb-6">
              The post you&apos;re looking for doesn&apos;t exist or has been deleted.
            </p>
            <Link
              href="/forum"
              className="inline-flex items-center gap-2 px-6 py-3 bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest rounded-xl hover:bg-cyan-400 transition-all"
            >
              Go back to forum
            </Link>
          </div>
        )}
      </div>
    </div>
  );
}
