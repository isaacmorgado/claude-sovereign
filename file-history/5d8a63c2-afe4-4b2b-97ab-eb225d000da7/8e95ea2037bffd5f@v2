'use client';

import { useEffect, useState, useRef } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { useForum } from '@/contexts/ForumContext';
import { PostCard, CreatePostForm } from '@/components/forum';
import { SortOrder } from '@/types/forum';

export default function CategoryPage() {
  const params = useParams();
  const router = useRouter();
  const categorySlug = params.categorySlug as string;
  const isInitialMount = useRef(true);

  const {
    currentCategory,
    posts,
    hasMorePosts,
    isLoadingCategories,
    isLoadingPosts,
    sortOrder,
    setSortOrder,
    fetchCategory,
    fetchPosts,
    loadMorePosts,
    votePost,
    createPost,
    error,
  } = useForum();

  const [showCreateForm, setShowCreateForm] = useState(false);
  const [selectedSubForum, setSelectedSubForum] = useState<string | null>(null);

  useEffect(() => {
    fetchCategory(categorySlug);
    fetchPosts(categorySlug);
  }, [categorySlug, fetchCategory, fetchPosts]);

  useEffect(() => {
    // Skip on initial mount to avoid duplicate API call
    if (isInitialMount.current) {
      isInitialMount.current = false;
      return;
    }
    // Refetch posts when sort order changes
    fetchPosts(categorySlug, undefined, true);
  }, [sortOrder, categorySlug, fetchPosts]);

  const handleCreatePost = async (title: string, content: string, subForumId: string) => {
    try {
      const post = await createPost(title, content, subForumId);
      setShowCreateForm(false);
      router.push(`/forum/post/${post.id}`);
    } catch {
      // Error is already set in context, form stays open for retry
    }
  };

  const handleSubForumClick = (subForumSlug: string) => {
    setSelectedSubForum(subForumSlug);
    fetchPosts(categorySlug, subForumSlug, true);
  };

  const handleClearSubForum = () => {
    setSelectedSubForum(null);
    fetchPosts(categorySlug, undefined, true);
  };

  return (
    <div className="min-h-screen bg-black">
      {/* Header */}
      <div className="border-b border-neutral-800">
        <div className="max-w-4xl mx-auto px-4 py-6">
          <Link href="/forum" className="text-[#00f3ff] text-sm mb-2 block hover:underline">
            &larr; Back to Forum
          </Link>

          {isLoadingCategories && !currentCategory ? (
            <div className="animate-pulse">
              <div className="h-7 bg-neutral-800 rounded w-1/3 mb-2" />
              <div className="h-4 bg-neutral-800 rounded w-2/3" />
            </div>
          ) : currentCategory ? (
            <>
              <div className="flex items-center gap-3 mb-1">
                {currentCategory.icon && (
                  <span className="text-2xl">{currentCategory.icon}</span>
                )}
                <h1 className="text-2xl font-bold text-white">{currentCategory.name}</h1>
              </div>
              {currentCategory.description && (
                <p className="text-neutral-400 text-sm">{currentCategory.description}</p>
              )}
            </>
          ) : (
            <h1 className="text-2xl font-bold text-white">Category not found</h1>
          )}
        </div>
      </div>

      {/* Content */}
      <div className="max-w-4xl mx-auto px-4 py-6">
        <div className="flex flex-col lg:flex-row gap-6">
          {/* Main content */}
          <div className="flex-1">
            {/* Create post button / form */}
            {showCreateForm && currentCategory ? (
              <div className="bg-neutral-900 border border-neutral-800 rounded-lg p-4 mb-6">
                <h2 className="text-lg font-medium text-white mb-4">Create a post</h2>
                <CreatePostForm
                  subForums={currentCategory.subForums}
                  onSubmit={handleCreatePost}
                  onCancel={() => setShowCreateForm(false)}
                />
              </div>
            ) : (
              <button
                onClick={() => setShowCreateForm(true)}
                className="w-full bg-neutral-900 border border-neutral-800 rounded-lg p-4 mb-6 text-left hover:border-neutral-700 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-neutral-800" />
                  <span className="text-neutral-400 text-sm">Create a post...</span>
                </div>
              </button>
            )}

            {/* Sort controls */}
            <div className="flex items-center gap-2 mb-4">
              <span className="text-neutral-500 text-sm">Sort by:</span>
              {(['hot', 'new', 'top'] as SortOrder[]).map((sort) => (
                <button
                  key={sort}
                  onClick={() => setSortOrder(sort)}
                  className={`px-3 py-1 text-sm rounded-full transition-colors ${
                    sortOrder === sort
                      ? 'bg-[#00f3ff]/10 text-[#00f3ff]'
                      : 'text-neutral-400 hover:text-white'
                  }`}
                >
                  {sort.charAt(0).toUpperCase() + sort.slice(1)}
                </button>
              ))}
            </div>

            {/* Active sub-forum filter */}
            {selectedSubForum && (
              <div className="flex items-center gap-2 mb-4 text-sm">
                <span className="text-neutral-400">Filtered by:</span>
                <span className="bg-neutral-800 text-white px-2 py-1 rounded flex items-center gap-2">
                  {selectedSubForum.replace(/-/g, ' ')}
                  <button
                    onClick={handleClearSubForum}
                    className="text-neutral-400 hover:text-white"
                  >
                    &times;
                  </button>
                </span>
              </div>
            )}

            {/* Error */}
            {error && (
              <div className="bg-red-400/10 border border-red-400/20 rounded-lg p-4 mb-4">
                <p className="text-red-400 text-sm">{error}</p>
              </div>
            )}

            {/* Posts */}
            <div className="space-y-4">
              {isLoadingPosts && posts.length === 0 ? (
                // Loading skeleton
                [1, 2, 3].map((i) => (
                  <div
                    key={i}
                    className="bg-neutral-900 border border-neutral-800 rounded-lg p-4 animate-pulse"
                  >
                    <div className="flex gap-3">
                      <div className="w-6 space-y-2">
                        <div className="h-4 bg-neutral-800 rounded" />
                        <div className="h-4 bg-neutral-800 rounded" />
                        <div className="h-4 bg-neutral-800 rounded" />
                      </div>
                      <div className="flex-1">
                        <div className="h-4 bg-neutral-800 rounded w-1/4 mb-2" />
                        <div className="h-5 bg-neutral-800 rounded w-3/4 mb-2" />
                        <div className="h-4 bg-neutral-800 rounded w-full" />
                      </div>
                    </div>
                  </div>
                ))
              ) : posts.length > 0 ? (
                <>
                  {posts.map((post) => (
                    <PostCard
                      key={post.id}
                      post={post}
                      onVote={(postId, voteType) => votePost(postId, voteType)}
                    />
                  ))}

                  {/* Load more */}
                  {hasMorePosts && (
                    <button
                      onClick={() => loadMorePosts(categorySlug, selectedSubForum || undefined)}
                      disabled={isLoadingPosts}
                      className="w-full py-3 text-sm text-[#00f3ff] hover:underline disabled:opacity-50"
                    >
                      {isLoadingPosts ? 'Loading...' : 'Load more posts'}
                    </button>
                  )}
                </>
              ) : (
                <div className="text-center py-12 text-neutral-400">
                  <p>No posts yet. Be the first to post!</p>
                </div>
              )}
            </div>
          </div>

          {/* Sidebar - Sub-forums */}
          {currentCategory && currentCategory.subForums.length > 0 && (
            <div className="lg:w-64">
              <div className="bg-neutral-900 border border-neutral-800 rounded-lg p-4 sticky top-4">
                <h3 className="text-white font-medium mb-3">Sub-forums</h3>
                <div className="space-y-1">
                  {currentCategory.subForums.map((sf) => (
                    <button
                      key={sf.id}
                      onClick={() => handleSubForumClick(sf.slug)}
                      className={`w-full text-left px-3 py-2 rounded text-sm transition-colors ${
                        selectedSubForum === sf.slug
                          ? 'bg-[#00f3ff]/10 text-[#00f3ff]'
                          : 'text-neutral-300 hover:bg-neutral-800'
                      }`}
                    >
                      <div className="flex justify-between">
                        <span>{sf.name}</span>
                        <span className="text-neutral-500">{sf.postCount}</span>
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
