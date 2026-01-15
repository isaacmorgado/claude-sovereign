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
    if (isInitialMount.current) {
      isInitialMount.current = false;
      return;
    }
    fetchPosts(categorySlug, undefined, true);
  }, [sortOrder, categorySlug, fetchPosts]);

  const handleCreatePost = async (title: string, content: string, subForumId: string) => {
    try {
      const post = await createPost(title, content, subForumId);
      setShowCreateForm(false);
      router.push(`/forum/post/${post.id}`);
    } catch {
      // Error handled in context
    }
  };

  const handleSubForumClick = (subForumSlug: string) => {
    setSelectedSubForum(subForumSlug === selectedSubForum ? null : subForumSlug);
    fetchPosts(categorySlug, subForumSlug === selectedSubForum ? undefined : subForumSlug, true);
  };

  return (
    <div className="min-h-screen bg-[#030303]">
      {/* Banner */}
      <div className="h-20 bg-gradient-to-r from-[#ff4500] to-[#ff6f00]" />

      {/* Subreddit header */}
      <div className="bg-[#1a1a1b] border-b border-[#343536]">
        <div className="max-w-5xl mx-auto px-4">
          <div className="flex items-end gap-4 -mt-4 pb-3">
            <div className="w-20 h-20 rounded-full bg-[#1a1a1b] border-4 border-[#1a1a1b] flex items-center justify-center text-3xl">
              {currentCategory?.icon || '📂'}
            </div>
            <div className="flex-1 min-w-0 pb-1">
              <div className="flex items-center gap-4">
                <h1 className="text-2xl font-bold text-[#d7dadc]">
                  {currentCategory?.name || 'Loading...'}
                </h1>
                <button className="px-4 py-1.5 text-sm font-bold bg-[#d7dadc] text-[#1a1a1b] rounded-full hover:bg-white transition-colors">
                  Joined
                </button>
              </div>
              <p className="text-sm text-[#818384]">r/{categorySlug}</p>
            </div>
          </div>

          {/* Navigation tabs */}
          <div className="flex gap-2 -mb-px">
            {[
              { id: 'posts', label: 'Posts', icon: '📝' },
            ].map((tab) => (
              <button
                key={tab.id}
                className="px-4 py-2 text-sm font-medium text-[#d7dadc] border-b-2 border-[#d7dadc] bg-transparent"
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Content */}
      <main className="max-w-5xl mx-auto px-4 py-4">
        <div className="flex gap-6">
          {/* Main feed */}
          <div className="flex-1 min-w-0">
            {/* Create post bar */}
            {showCreateForm && currentCategory ? (
              <div className="bg-[#1a1a1b] border border-[#343536] rounded p-4 mb-4">
                <h2 className="text-lg font-medium text-[#d7dadc] mb-4">Create a post</h2>
                <CreatePostForm
                  subForums={currentCategory.subForums}
                  onSubmit={handleCreatePost}
                  onCancel={() => setShowCreateForm(false)}
                />
              </div>
            ) : (
              <div
                onClick={() => setShowCreateForm(true)}
                className="bg-[#1a1a1b] border border-[#343536] rounded p-2 mb-4 flex items-center gap-3 cursor-pointer hover:border-[#818384] transition-colors"
              >
                <div className="w-10 h-10 rounded-full bg-[#272729] border border-[#343536]" />
                <input
                  type="text"
                  placeholder="Create Post"
                  className="flex-1 bg-[#272729] border border-[#343536] rounded px-4 py-2 text-sm text-[#d7dadc] placeholder-[#818384] focus:outline-none focus:border-[#d7dadc]"
                  onFocus={() => setShowCreateForm(true)}
                  readOnly
                />
                <button className="p-2 text-[#818384] hover:bg-[#272729] rounded">
                  <ImageIcon className="w-6 h-6" />
                </button>
                <button className="p-2 text-[#818384] hover:bg-[#272729] rounded">
                  <LinkIcon className="w-6 h-6" />
                </button>
              </div>
            )}

            {/* Sort bar */}
            <div className="bg-[#1a1a1b] border border-[#343536] rounded px-3 py-2 mb-4 flex items-center gap-2">
              {(['hot', 'new', 'top'] as SortOrder[]).map((sort) => (
                <button
                  key={sort}
                  onClick={() => setSortOrder(sort)}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium transition-colors ${
                    sortOrder === sort
                      ? 'bg-[#272729] text-[#d7dadc]'
                      : 'text-[#818384] hover:bg-[#272729]'
                  }`}
                >
                  {sort === 'hot' && <HotIcon className="w-5 h-5" />}
                  {sort === 'new' && <NewIcon className="w-5 h-5" />}
                  {sort === 'top' && <TopIcon className="w-5 h-5" />}
                  {sort.charAt(0).toUpperCase() + sort.slice(1)}
                </button>
              ))}
            </div>

            {/* Topic filter pills */}
            {currentCategory && currentCategory.subForums.length > 0 && (
              <div className="flex flex-wrap gap-2 mb-4">
                {currentCategory.subForums.map((sf) => (
                  <button
                    key={sf.id}
                    onClick={() => handleSubForumClick(sf.slug)}
                    className={`px-3 py-1 text-xs font-medium rounded-full transition-colors ${
                      selectedSubForum === sf.slug
                        ? 'bg-[#ff4500] text-white'
                        : 'bg-[#272729] text-[#d7dadc] hover:bg-[#343536]'
                    }`}
                  >
                    {sf.name}
                    {sf.postCount > 0 && (
                      <span className="ml-1 opacity-60">{sf.postCount}</span>
                    )}
                  </button>
                ))}
              </div>
            )}

            {/* Error */}
            {error && (
              <div className="bg-red-500/10 border border-red-500/20 rounded p-4 mb-4">
                <p className="text-red-400 text-sm">{error}</p>
              </div>
            )}

            {/* Posts */}
            <div className="space-y-3">
              {isLoadingPosts && posts.length === 0 ? (
                [1, 2, 3].map((i) => (
                  <div key={i} className="bg-[#1a1a1b] border border-[#343536] rounded p-4 animate-pulse">
                    <div className="flex gap-3">
                      <div className="w-10 space-y-2">
                        <div className="h-4 bg-[#343536] rounded" />
                        <div className="h-4 bg-[#343536] rounded" />
                      </div>
                      <div className="flex-1">
                        <div className="h-3 bg-[#343536] rounded w-1/4 mb-2" />
                        <div className="h-5 bg-[#343536] rounded w-3/4 mb-2" />
                        <div className="h-3 bg-[#343536] rounded w-full" />
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
                  {hasMorePosts && (
                    <button
                      onClick={() => loadMorePosts(categorySlug, selectedSubForum || undefined)}
                      disabled={isLoadingPosts}
                      className="w-full py-3 text-sm font-medium text-[#ff4500] hover:text-[#ff6f00] disabled:opacity-50"
                    >
                      {isLoadingPosts ? 'Loading...' : 'Load More'}
                    </button>
                  )}
                </>
              ) : (
                <div className="bg-[#1a1a1b] border border-[#343536] rounded p-12 text-center">
                  <div className="text-5xl mb-4">🌱</div>
                  <p className="text-[#d7dadc] font-medium mb-2">No posts yet</p>
                  <p className="text-[#818384] text-sm">Be the first to share something!</p>
                </div>
              )}
            </div>
          </div>

          {/* Sidebar */}
          <aside className="hidden lg:block w-80 space-y-4">
            {/* About Community */}
            <div className="bg-[#1a1a1b] border border-[#343536] rounded overflow-hidden">
              <div className="bg-[#ff4500] px-4 py-2">
                <h3 className="text-xs font-bold text-white">About Community</h3>
              </div>
              <div className="p-4">
                <p className="text-sm text-[#d7dadc] mb-4">
                  {currentCategory?.description || 'Loading...'}
                </p>
                <div className="flex gap-4 text-sm border-b border-[#343536] pb-4 mb-4">
                  <div>
                    <div className="font-bold text-[#d7dadc]">{currentCategory?.postCount || 0}</div>
                    <div className="text-xs text-[#818384]">Posts</div>
                  </div>
                  <div>
                    <div className="font-bold text-[#d7dadc]">{currentCategory?.subForums.length || 0}</div>
                    <div className="text-xs text-[#818384]">Topics</div>
                  </div>
                </div>
                <button
                  onClick={() => setShowCreateForm(true)}
                  className="w-full py-2 text-sm font-bold bg-[#d7dadc] text-[#1a1a1b] rounded-full hover:bg-white transition-colors"
                >
                  Create Post
                </button>
              </div>
            </div>

            {/* Topics */}
            {currentCategory && currentCategory.subForums.length > 0 && (
              <div className="bg-[#1a1a1b] border border-[#343536] rounded overflow-hidden">
                <div className="px-4 py-3 border-b border-[#343536]">
                  <h3 className="text-xs font-bold text-[#818384] uppercase tracking-wide">Topics</h3>
                </div>
                <div className="p-2">
                  {currentCategory.subForums.map((sf) => (
                    <button
                      key={sf.id}
                      onClick={() => handleSubForumClick(sf.slug)}
                      className={`w-full text-left px-3 py-2 rounded text-sm transition-colors flex justify-between ${
                        selectedSubForum === sf.slug
                          ? 'bg-[#ff4500]/10 text-[#ff4500]'
                          : 'text-[#d7dadc] hover:bg-[#272729]'
                      }`}
                    >
                      <span>{sf.name}</span>
                      <span className="text-[#818384]">{sf.postCount}</span>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Rules */}
            <div className="bg-[#1a1a1b] border border-[#343536] rounded overflow-hidden">
              <div className="px-4 py-3 border-b border-[#343536]">
                <h3 className="text-xs font-bold text-[#818384] uppercase tracking-wide">Rules</h3>
              </div>
              <div className="p-4 text-sm text-[#d7dadc] space-y-3">
                <div className="flex gap-2">
                  <span className="text-[#818384]">1.</span>
                  <span>Be respectful to others</span>
                </div>
                <div className="flex gap-2">
                  <span className="text-[#818384]">2.</span>
                  <span>No medical advice</span>
                </div>
                <div className="flex gap-2">
                  <span className="text-[#818384]">3.</span>
                  <span>Share evidence-based info</span>
                </div>
              </div>
            </div>

            {/* Back link */}
            <Link
              href="/forum"
              className="block text-sm text-[#818384] hover:text-[#d7dadc] text-center py-2"
            >
              ← Back to all communities
            </Link>
          </aside>
        </div>
      </main>
    </div>
  );
}

function HotIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path fillRule="evenodd" d="M12.395 2.553a1 1 0 00-1.45-.385c-.345.23-.614.558-.822.88-.214.33-.403.713-.57 1.116-.334.804-.614 1.768-.84 2.734a31.365 31.365 0 00-.613 3.58 2.64 2.64 0 01-.945-1.067c-.328-.68-.398-1.534-.398-2.654A1 1 0 005.05 6.05 6.981 6.981 0 003 11a7 7 0 1011.95-4.95c-.592-.591-.98-.985-1.348-1.467-.363-.476-.724-1.063-1.207-2.03zM12.12 15.12A3 3 0 017 13s.879.5 2.5.5c0-1 .5-4 1.25-4.5.5 1 .786 1.293 1.371 1.879A2.99 2.99 0 0113 13a2.99 2.99 0 01-.879 2.121z" clipRule="evenodd" />
    </svg>
  );
}

function NewIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clipRule="evenodd" />
    </svg>
  );
}

function TopIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path fillRule="evenodd" d="M12 7a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0V8.414l-4.293 4.293a1 1 0 01-1.414 0L8 10.414l-4.293 4.293a1 1 0 01-1.414-1.414l5-5a1 1 0 011.414 0L11 10.586 14.586 7H12z" clipRule="evenodd" />
    </svg>
  );
}

function ImageIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path fillRule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clipRule="evenodd" />
    </svg>
  );
}

function LinkIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 20 20" fill="currentColor">
      <path fillRule="evenodd" d="M12.586 4.586a2 2 0 112.828 2.828l-3 3a2 2 0 01-2.828 0 1 1 0 00-1.414 1.414 4 4 0 005.656 0l3-3a4 4 0 00-5.656-5.656l-1.5 1.5a1 1 0 101.414 1.414l1.5-1.5zm-5 5a2 2 0 012.828 0 1 1 0 101.414-1.414 4 4 0 00-5.656 0l-3 3a4 4 0 105.656 5.656l1.5-1.5a1 1 0 10-1.414-1.414l-1.5 1.5a2 2 0 11-2.828-2.828l3-3z" clipRule="evenodd" />
    </svg>
  );
}
