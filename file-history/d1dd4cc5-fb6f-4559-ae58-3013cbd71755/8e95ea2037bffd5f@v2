'use client';

import { useEffect, useState, useRef } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { useForum } from '@/contexts/ForumContext';
import { PostCard, CreatePostForm, ForumHeader, ForumBreadcrumb } from '@/components/forum';
import { SortOrder } from '@/types/forum';
import {
  Flame,
  Clock,
  TrendingUp,
  X,
  Image as ImageIcon,
  LinkIcon,
  Hash,
  ShieldCheck,
  ArrowLeft,
  PenSquare
} from 'lucide-react';

// ============================================
// SORT TABS
// ============================================
function SortTabs({ sortOrder, setSortOrder }: { sortOrder: SortOrder; setSortOrder: (s: SortOrder) => void }) {
  const sorts = [
    { id: 'hot' as const, label: 'Hot', icon: Flame },
    { id: 'new' as const, label: 'New', icon: Clock },
    { id: 'top' as const, label: 'Top', icon: TrendingUp },
  ];

  return (
    <div className="flex items-center gap-1 p-1.5 bg-neutral-900/30 border border-white/5 rounded-xl">
      {sorts.map((sort) => (
        <button
          key={sort.id}
          onClick={() => setSortOrder(sort.id)}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-[10px] font-black uppercase tracking-widest transition-all ${
            sortOrder === sort.id
              ? 'bg-cyan-500/10 text-cyan-400 border border-cyan-500/20'
              : 'text-neutral-600 hover:text-white border border-transparent'
          }`}
        >
          <sort.icon size={12} />
          {sort.label}
        </button>
      ))}
    </div>
  );
}

// ============================================
// TOPIC PILLS
// ============================================
function TopicPills({
  subForums,
  selected,
  onSelect
}: {
  subForums: { id: string; name: string; slug: string; postCount: number }[];
  selected: string | null;
  onSelect: (slug: string) => void;
}) {
  return (
    <div className="flex flex-wrap gap-2">
      {subForums.map((sf) => (
        <button
          key={sf.id}
          onClick={() => onSelect(sf.slug)}
          className={`px-3 py-1.5 rounded-lg text-[10px] font-black uppercase tracking-wider transition-all ${
            selected === sf.slug
              ? 'bg-cyan-500 text-black'
              : 'bg-neutral-900/50 border border-white/5 text-neutral-400 hover:border-cyan-500/30 hover:text-cyan-400'
          }`}
        >
          {sf.name}
          {sf.postCount > 0 && (
            <span className="ml-1.5 opacity-60">{sf.postCount}</span>
          )}
        </button>
      ))}
    </div>
  );
}

// ============================================
// POST SKELETON
// ============================================
function PostSkeleton() {
  return (
    <div className="rounded-2xl bg-neutral-900/30 border border-white/5 overflow-hidden animate-pulse">
      <div className="flex">
        <div className="w-12 bg-neutral-900/50 py-4 flex flex-col items-center gap-2">
          <div className="w-6 h-6 bg-neutral-800 rounded" />
          <div className="w-4 h-4 bg-neutral-800 rounded" />
          <div className="w-6 h-6 bg-neutral-800 rounded" />
        </div>
        <div className="flex-1 p-4 space-y-3">
          <div className="flex gap-2">
            <div className="h-4 w-16 bg-neutral-800 rounded" />
            <div className="h-4 w-24 bg-neutral-800 rounded" />
          </div>
          <div className="h-5 w-3/4 bg-neutral-800 rounded" />
          <div className="h-4 w-full bg-neutral-800 rounded" />
          <div className="flex gap-2">
            <div className="h-6 w-20 bg-neutral-800 rounded" />
            <div className="h-6 w-16 bg-neutral-800 rounded" />
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================
// MAIN PAGE
// ============================================
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
    <div className="min-h-screen bg-black selection:bg-cyan-500/30">
      <ForumHeader />
      <ForumBreadcrumb items={[
        { label: 'Community', href: '/forum' },
        { label: currentCategory?.name || categorySlug }
      ]} />

      {/* Category Header */}
      <section className="border-b border-white/5">
        <div className="max-w-6xl mx-auto px-6 py-10">
          <div className="flex items-start gap-6">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-cyan-500/20 to-blue-500/20 border border-white/10 flex items-center justify-center text-3xl flex-shrink-0">
              {currentCategory?.icon || '📂'}
            </div>
            <div className="flex-1 min-w-0">
              <h1 className="text-4xl md:text-5xl font-black tracking-tighter italic uppercase mb-3">
                {currentCategory?.name || 'Loading...'}
              </h1>
              <p className="text-neutral-500 text-sm max-w-2xl leading-relaxed">
                {currentCategory?.description}
              </p>
            </div>
            <button
              onClick={() => setShowCreateForm(true)}
              className="hidden md:flex h-11 px-6 rounded-xl bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest items-center gap-2 hover:bg-cyan-400 transition-all shadow-lg shadow-cyan-500/20"
            >
              <PenSquare size={14} />
              New Post
            </button>
          </div>
        </div>
      </section>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-6 py-10">
        <div className="flex flex-col lg:flex-row gap-10">
          {/* Main Feed */}
          <div className="flex-1 min-w-0">
            {/* Create Post Form */}
            {showCreateForm && currentCategory ? (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="p-6 rounded-2xl bg-neutral-900/30 border border-white/5 mb-6"
              >
                <div className="flex items-center justify-between mb-6">
                  <h2 className="text-sm font-black uppercase tracking-wider text-white">Create a Post</h2>
                  <button
                    onClick={() => setShowCreateForm(false)}
                    className="p-2 rounded-lg hover:bg-white/5 text-neutral-500 hover:text-white transition-all"
                  >
                    <X size={16} />
                  </button>
                </div>
                <CreatePostForm
                  subForums={currentCategory.subForums}
                  onSubmit={handleCreatePost}
                  onCancel={() => setShowCreateForm(false)}
                />
              </motion.div>
            ) : (
              <div
                onClick={() => setShowCreateForm(true)}
                className="flex items-center gap-4 p-4 rounded-2xl bg-neutral-900/30 border border-white/5 hover:border-cyan-500/20 cursor-pointer transition-all mb-6"
              >
                <div className="w-10 h-10 rounded-xl bg-neutral-900 border border-white/5" />
                <div className="flex-1 px-4 py-2.5 rounded-xl bg-neutral-900/50 border border-white/5 text-neutral-600 text-sm">
                  Create Post
                </div>
                <button className="p-2 rounded-lg hover:bg-white/5 text-neutral-600 hover:text-cyan-400 transition-all">
                  <ImageIcon size={18} />
                </button>
                <button className="p-2 rounded-lg hover:bg-white/5 text-neutral-600 hover:text-cyan-400 transition-all">
                  <LinkIcon size={18} />
                </button>
              </div>
            )}

            {/* Sort & Filter */}
            <div className="flex flex-col sm:flex-row sm:items-center gap-4 mb-6">
              <SortTabs sortOrder={sortOrder} setSortOrder={setSortOrder} />
            </div>

            {/* Topic Filter */}
            {currentCategory && currentCategory.subForums.length > 0 && (
              <div className="mb-6">
                <TopicPills
                  subForums={currentCategory.subForums}
                  selected={selectedSubForum}
                  onSelect={handleSubForumClick}
                />
              </div>
            )}

            {/* Error */}
            {error && (
              <div className="p-4 rounded-xl bg-red-500/10 border border-red-500/20 mb-6">
                <p className="text-red-400 text-sm">{error}</p>
              </div>
            )}

            {/* Posts */}
            <div className="space-y-4">
              {isLoadingPosts && posts.length === 0 ? (
                [1, 2, 3].map((i) => <PostSkeleton key={i} />)
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
                      className="w-full py-4 text-[10px] font-black uppercase tracking-widest text-cyan-400 hover:text-cyan-300 disabled:opacity-50 transition-colors"
                    >
                      {isLoadingPosts ? 'Loading...' : 'Load More Posts'}
                    </button>
                  )}
                </>
              ) : (
                <div className="text-center py-16 rounded-2xl bg-neutral-900/30 border border-white/5">
                  <div className="text-5xl mb-4">🌱</div>
                  <p className="text-white font-bold mb-2">No posts yet</p>
                  <p className="text-neutral-500 text-sm">Be the first to share something!</p>
                </div>
              )}
            </div>
          </div>

          {/* Sidebar */}
          <aside className="lg:w-80 space-y-6">
            {/* About */}
            <div className="rounded-2xl bg-neutral-900/30 border border-white/5 overflow-hidden">
              <div className="px-5 py-3 bg-cyan-500/10 border-b border-white/5">
                <h3 className="text-[10px] font-black uppercase tracking-[0.2em] text-cyan-400">About Community</h3>
              </div>
              <div className="p-5">
                <p className="text-sm text-neutral-400 mb-5 leading-relaxed">
                  {currentCategory?.description || 'Loading...'}
                </p>
                <div className="grid grid-cols-2 gap-4 pb-5 border-b border-white/5 mb-5">
                  <div>
                    <p className="text-lg font-black italic text-white">{currentCategory?.postCount || 0}</p>
                    <p className="text-[9px] font-black uppercase tracking-widest text-neutral-600">Posts</p>
                  </div>
                  <div>
                    <p className="text-lg font-black italic text-white">{currentCategory?.subForums.length || 0}</p>
                    <p className="text-[9px] font-black uppercase tracking-widest text-neutral-600">Topics</p>
                  </div>
                </div>
                <button
                  onClick={() => setShowCreateForm(true)}
                  className="w-full py-3 bg-cyan-500 text-black text-[10px] font-black uppercase tracking-widest rounded-xl hover:bg-cyan-400 transition-all"
                >
                  Create Post
                </button>
              </div>
            </div>

            {/* Topics */}
            {currentCategory && currentCategory.subForums.length > 0 && (
              <div className="rounded-2xl bg-neutral-900/30 border border-white/5 overflow-hidden">
                <div className="px-5 py-3 border-b border-white/5">
                  <div className="flex items-center gap-2">
                    <Hash size={12} className="text-cyan-400" />
                    <h3 className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500">Topics</h3>
                  </div>
                </div>
                <div className="p-3">
                  {currentCategory.subForums.map((sf) => (
                    <button
                      key={sf.id}
                      onClick={() => handleSubForumClick(sf.slug)}
                      className={`w-full text-left px-4 py-2.5 rounded-lg text-sm transition-all flex justify-between items-center ${
                        selectedSubForum === sf.slug
                          ? 'bg-cyan-500/10 text-cyan-400'
                          : 'text-neutral-400 hover:bg-white/5 hover:text-white'
                      }`}
                    >
                      <span>{sf.name}</span>
                      <span className="text-[10px] text-neutral-600">{sf.postCount}</span>
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Rules */}
            <div className="rounded-2xl bg-neutral-900/30 border border-white/5 overflow-hidden">
              <div className="px-5 py-3 border-b border-white/5">
                <div className="flex items-center gap-2">
                  <ShieldCheck size={12} className="text-cyan-400" />
                  <h3 className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500">Rules</h3>
                </div>
              </div>
              <div className="p-5 space-y-3 text-sm text-neutral-400">
                <div className="flex gap-3">
                  <span className="text-cyan-400 font-black">1.</span>
                  <span>Be respectful to others</span>
                </div>
                <div className="flex gap-3">
                  <span className="text-cyan-400 font-black">2.</span>
                  <span>No medical advice</span>
                </div>
                <div className="flex gap-3">
                  <span className="text-cyan-400 font-black">3.</span>
                  <span>Share evidence-based info</span>
                </div>
              </div>
            </div>

            {/* Back link */}
            <Link
              href="/forum"
              className="flex items-center justify-center gap-2 py-3 text-[10px] font-black uppercase tracking-widest text-neutral-600 hover:text-cyan-400 transition-colors"
            >
              <ArrowLeft size={12} />
              Back to all communities
            </Link>
          </aside>
        </div>
      </main>
    </div>
  );
}
