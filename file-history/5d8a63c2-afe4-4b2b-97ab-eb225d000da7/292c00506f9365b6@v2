'use client';

import React, { createContext, useContext, useState, useCallback, useRef, ReactNode } from 'react';
import { api } from '@/lib/api';
import type {
  Category,
  Post,
  PostListItem,
  Comment,
  SortOrder,
  VoteType,
  GuideSection,
  RecommendedForum,
} from '@/types/forum';

interface ForumContextType {
  // Categories
  categories: Category[];
  currentCategory: Category | null;
  isLoadingCategories: boolean;
  fetchCategories: () => Promise<void>;
  fetchCategory: (slug: string) => Promise<void>;

  // Posts
  posts: PostListItem[];
  currentPost: Post | null;
  totalPosts: number;
  hasMorePosts: boolean;
  isLoadingPosts: boolean;
  sortOrder: SortOrder;
  setSortOrder: (sort: SortOrder) => void;
  fetchPosts: (categorySlug: string, subForumSlug?: string, reset?: boolean) => Promise<void>;
  loadMorePosts: (categorySlug: string, subForumSlug?: string) => Promise<void>;
  fetchPost: (postId: string) => Promise<void>;
  createPost: (title: string, content: string, subForumId: string) => Promise<Post>;
  updatePost: (postId: string, title?: string, content?: string) => Promise<void>;
  deletePost: (postId: string) => Promise<void>;

  // Comments
  comments: Comment[];
  isLoadingComments: boolean;
  fetchComments: (postId: string) => Promise<void>;
  createComment: (postId: string, content: string, parentId?: string) => Promise<Comment>;
  updateComment: (commentId: string, content: string) => Promise<void>;
  deleteComment: (commentId: string) => Promise<void>;

  // Voting
  votePost: (postId: string, voteType: VoteType) => Promise<void>;
  voteComment: (commentId: string, voteType: VoteType) => Promise<void>;

  // Guides & Recommendations
  guideSections: GuideSection[];
  recommendedForums: RecommendedForum[];
  isLoadingGuides: boolean;
  fetchGuides: () => Promise<void>;
  fetchRecommended: (flaws: string[]) => Promise<void>;

  // Error state
  error: string | null;
  clearError: () => void;
}

const ForumContext = createContext<ForumContextType | null>(null);

export function useForum(): ForumContextType {
  const context = useContext(ForumContext);
  if (!context) {
    throw new Error('useForum must be used within a ForumProvider');
  }
  return context;
}

export function useForumOptional(): ForumContextType | null {
  return useContext(ForumContext);
}

const PAGE_SIZE = 20;

export function ForumProvider({ children }: { children: ReactNode }) {
  // Categories
  const [categories, setCategories] = useState<Category[]>([]);
  const [currentCategory, setCurrentCategory] = useState<Category | null>(null);
  const [isLoadingCategories, setIsLoadingCategories] = useState(false);

  // Posts
  const [posts, setPosts] = useState<PostListItem[]>([]);
  const [currentPost, setCurrentPost] = useState<Post | null>(null);
  const [totalPosts, setTotalPosts] = useState(0);
  const [hasMorePosts, setHasMorePosts] = useState(true);
  const [isLoadingPosts, setIsLoadingPosts] = useState(false);
  const [sortOrder, setSortOrder] = useState<SortOrder>('hot');
  const offsetRef = useRef(0);

  // Comments
  const [comments, setComments] = useState<Comment[]>([]);
  const [isLoadingComments, setIsLoadingComments] = useState(false);

  // Guides & Recommendations
  const [guideSections, setGuideSections] = useState<GuideSection[]>([]);
  const [recommendedForums, setRecommendedForums] = useState<RecommendedForum[]>([]);
  const [isLoadingGuides, setIsLoadingGuides] = useState(false);

  // Error state
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => setError(null), []);

  // === CATEGORIES ===

  const fetchCategories = useCallback(async () => {
    setIsLoadingCategories(true);
    setError(null);
    try {
      const data = await api.getForumCategories();
      setCategories(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch categories');
    } finally {
      setIsLoadingCategories(false);
    }
  }, []);

  const fetchCategory = useCallback(async (slug: string) => {
    setIsLoadingCategories(true);
    setError(null);
    try {
      const data = await api.getForumCategory(slug);
      setCurrentCategory(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch category');
    } finally {
      setIsLoadingCategories(false);
    }
  }, []);

  // === POSTS ===

  const fetchPosts = useCallback(async (
    categorySlug: string,
    subForumSlug?: string,
    reset = true
  ) => {
    setIsLoadingPosts(true);
    setError(null);
    try {
      const offset = reset ? 0 : offsetRef.current;
      const data = await api.getForumPosts(categorySlug, {
        subForumSlug,
        sort: sortOrder,
        limit: PAGE_SIZE,
        offset,
      });

      if (reset) {
        setPosts(data.posts);
        offsetRef.current = PAGE_SIZE;
      } else {
        setPosts(prev => [...prev, ...data.posts]);
        offsetRef.current += PAGE_SIZE;
      }

      setTotalPosts(data.totalCount);
      setHasMorePosts(data.hasMore);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch posts');
    } finally {
      setIsLoadingPosts(false);
    }
  }, [sortOrder]);

  const loadMorePosts = useCallback(async (
    categorySlug: string,
    subForumSlug?: string
  ) => {
    if (!hasMorePosts || isLoadingPosts) return;
    await fetchPosts(categorySlug, subForumSlug, false);
  }, [fetchPosts, hasMorePosts, isLoadingPosts]);

  const fetchPost = useCallback(async (postId: string) => {
    setIsLoadingPosts(true);
    setError(null);
    try {
      const data = await api.getForumPost(postId);
      setCurrentPost(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch post');
    } finally {
      setIsLoadingPosts(false);
    }
  }, []);

  const createPost = useCallback(async (
    title: string,
    content: string,
    subForumId: string
  ): Promise<Post> => {
    setError(null);
    try {
      const post = await api.createForumPost({ title, content, subForumId });
      return post;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to create post';
      setError(message);
      throw err;
    }
  }, []);

  const updatePost = useCallback(async (
    postId: string,
    title?: string,
    content?: string
  ) => {
    setError(null);
    try {
      const updated = await api.updateForumPost(postId, { title, content });
      setCurrentPost(updated);
      // Update in posts list if present
      setPosts(prev => prev.map(p =>
        p.id === postId
          ? { ...p, title: title ?? p.title }
          : p
      ));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update post');
      throw err;
    }
  }, []);

  const deletePost = useCallback(async (postId: string) => {
    setError(null);
    try {
      await api.deleteForumPost(postId);
      setPosts(prev => prev.filter(p => p.id !== postId));
      if (currentPost?.id === postId) {
        setCurrentPost(null);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete post');
      throw err;
    }
  }, [currentPost?.id]);

  // === COMMENTS ===

  const fetchComments = useCallback(async (postId: string) => {
    setIsLoadingComments(true);
    setError(null);
    try {
      const data = await api.getForumComments(postId);
      setComments(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch comments');
    } finally {
      setIsLoadingComments(false);
    }
  }, []);

  const createComment = useCallback(async (
    postId: string,
    content: string,
    parentId?: string
  ): Promise<Comment> => {
    setError(null);
    try {
      const comment = await api.createForumComment(postId, { content, parentId });
      // Add to comments list (append for top-level, insert in replies for nested)
      if (!parentId) {
        setComments(prev => [...prev, comment]);
      }
      // Update comment count in current post
      if (currentPost?.id === postId) {
        setCurrentPost(prev => prev ? { ...prev, commentCount: prev.commentCount + 1 } : null);
      }
      return comment;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to create comment';
      setError(message);
      throw err;
    }
  }, [currentPost?.id]);

  const updateComment = useCallback(async (commentId: string, content: string) => {
    setError(null);
    try {
      const updated = await api.updateForumComment(commentId, content);
      // Update in comments list
      const updateInList = (list: Comment[]): Comment[] =>
        list.map(c => c.id === commentId
          ? { ...c, content: updated.content, updatedAt: updated.updatedAt }
          : { ...c, replies: updateInList(c.replies) }
        );
      setComments(prev => updateInList(prev));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update comment');
      throw err;
    }
  }, []);

  const deleteComment = useCallback(async (commentId: string) => {
    setError(null);
    try {
      await api.deleteForumComment(commentId);
      // Remove from comments list
      const removeFromList = (list: Comment[]): Comment[] =>
        list.filter(c => c.id !== commentId).map(c => ({
          ...c,
          replies: removeFromList(c.replies),
        }));
      setComments(prev => removeFromList(prev));
      // Update comment count
      if (currentPost) {
        setCurrentPost(prev => prev ? { ...prev, commentCount: Math.max(0, prev.commentCount - 1) } : null);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete comment');
      throw err;
    }
  }, [currentPost]);

  // === VOTING ===

  const votePost = useCallback(async (postId: string, voteType: VoteType) => {
    setError(null);
    try {
      const result = await api.voteForumPost(postId, voteType);
      // Update in current post
      if (currentPost?.id === postId) {
        setCurrentPost(prev => prev ? {
          ...prev,
          voteCount: result.newVoteCount,
          userVote: result.userVote,
        } : null);
      }
      // Update in posts list
      setPosts(prev => prev.map(p =>
        p.id === postId
          ? { ...p, voteCount: result.newVoteCount, userVote: result.userVote }
          : p
      ));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to vote');
      throw err;
    }
  }, [currentPost?.id]);

  const voteComment = useCallback(async (commentId: string, voteType: VoteType) => {
    setError(null);
    try {
      const result = await api.voteForumComment(commentId, voteType);
      // Update in comments list
      const updateVote = (list: Comment[]): Comment[] =>
        list.map(c => c.id === commentId
          ? { ...c, voteCount: result.newVoteCount, userVote: result.userVote }
          : { ...c, replies: updateVote(c.replies) }
        );
      setComments(prev => updateVote(prev));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to vote');
      throw err;
    }
  }, []);

  // === GUIDES & RECOMMENDATIONS ===

  const fetchGuides = useCallback(async () => {
    setIsLoadingGuides(true);
    setError(null);
    try {
      const data = await api.getForumGuides();
      setGuideSections(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch guides');
    } finally {
      setIsLoadingGuides(false);
    }
  }, []);

  const fetchRecommended = useCallback(async (flaws: string[]) => {
    setError(null);
    try {
      const data = await api.getRecommendedForums(flaws);
      setRecommendedForums(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch recommendations');
    }
  }, []);

  return (
    <ForumContext.Provider
      value={{
        // Categories
        categories,
        currentCategory,
        isLoadingCategories,
        fetchCategories,
        fetchCategory,

        // Posts
        posts,
        currentPost,
        totalPosts,
        hasMorePosts,
        isLoadingPosts,
        sortOrder,
        setSortOrder,
        fetchPosts,
        loadMorePosts,
        fetchPost,
        createPost,
        updatePost,
        deletePost,

        // Comments
        comments,
        isLoadingComments,
        fetchComments,
        createComment,
        updateComment,
        deleteComment,

        // Voting
        votePost,
        voteComment,

        // Guides & Recommendations
        guideSections,
        recommendedForums,
        isLoadingGuides,
        fetchGuides,
        fetchRecommended,

        // Error
        error,
        clearError,
      }}
    >
      {children}
    </ForumContext.Provider>
  );
}
