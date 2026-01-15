/**
 * API Client for LOOKSMAXX Backend
 *
 * Handles all authenticated requests to the Railway-hosted API
 */

import type { UserRank, LeaderboardEntry, LeaderboardData, UserProfile } from '@/types/results';
import type {
  Category,
  SubForum,
  Post,
  PostListItem,
  PostListResponse,
  PostCreate,
  PostUpdate,
  Comment,
  CommentCreate,
  VoteType,
  VoteResponse,
  ReportCreate,
  Report,
  GuideSection,
  RecommendedForum,
  SortOrder,
  CategoryListItem,
  PostAuthor,
} from '@/types/forum';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

// API Response types (snake_case from backend)
interface LeaderboardApiResponse {
  user_id: string;
  score: number;
  global_rank: number;
  gender_rank: number;
  percentile: number;
  total_users: number;
  gender_total: number;
  anonymous_name: string;
  updated_at: string;
}

interface LeaderboardEntryResponse {
  user_id: string;
  rank: number;
  score: number;
  anonymous_name: string;
  gender: 'male' | 'female';
  face_photo_url: string | null;
  is_current_user: boolean;
}

interface LeaderboardListResponse {
  entries: LeaderboardEntryResponse[];
  total_count: number;
  user_rank: LeaderboardApiResponse | null;
}

interface UserProfileResponse {
  user_id: string;
  rank: number;
  score: number;
  anonymous_name: string;
  gender: 'male' | 'female';
  face_photo_url: string | null;
  top_strengths: string[];
  top_improvements: string[];
}

// Transform functions (snake_case -> camelCase)
function transformUserRank(data: LeaderboardApiResponse): UserRank {
  return {
    userId: data.user_id,
    score: data.score,
    globalRank: data.global_rank,
    genderRank: data.gender_rank,
    percentile: data.percentile,
    totalUsers: data.total_users,
    genderTotal: data.gender_total,
    anonymousName: data.anonymous_name,
    updatedAt: data.updated_at,
  };
}

function transformLeaderboardEntry(data: LeaderboardEntryResponse): LeaderboardEntry {
  return {
    userId: data.user_id,
    rank: data.rank,
    score: data.score,
    anonymousName: data.anonymous_name,
    gender: data.gender,
    facePhotoUrl: data.face_photo_url,
    isCurrentUser: data.is_current_user,
  };
}

function transformLeaderboardData(data: LeaderboardListResponse): LeaderboardData {
  return {
    entries: data.entries.map(transformLeaderboardEntry),
    totalCount: data.total_count,
    userRank: data.user_rank ? transformUserRank(data.user_rank) : null,
  };
}

function transformUserProfile(data: UserProfileResponse): UserProfile {
  return {
    userId: data.user_id,
    rank: data.rank,
    score: data.score,
    anonymousName: data.anonymous_name,
    gender: data.gender,
    facePhotoUrl: data.face_photo_url,
    topStrengths: data.top_strengths,
    topImprovements: data.top_improvements,
  };
}

// === FORUM API RESPONSE TYPES ===

interface SubForumApiResponse {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  icon: string | null;
  display_order: number;
  post_count: number;
}

interface CategoryApiResponse {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  icon: string | null;
  display_order: number;
  post_count: number;
  sub_forums: SubForumApiResponse[];
}

interface CategoryListApiResponse {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  icon: string | null;
  display_order: number;
  post_count: number;
}

interface PostAuthorApiResponse {
  id: string;
  username: string;
}

interface PostApiResponse {
  id: string;
  title: string;
  content: string;
  sub_forum_id: string;
  sub_forum_slug: string;
  category_slug: string;
  author: PostAuthorApiResponse;
  is_pinned: boolean;
  is_guide: boolean;
  vote_count: number;
  comment_count: number;
  user_vote: VoteType | null;
  created_at: string;
  updated_at: string;
}

interface PostListItemApiResponse {
  id: string;
  title: string;
  content_preview: string;
  sub_forum_slug: string;
  category_slug: string;
  author: PostAuthorApiResponse;
  is_pinned: boolean;
  is_guide: boolean;
  vote_count: number;
  comment_count: number;
  user_vote: VoteType | null;
  created_at: string;
}

interface PostListApiResponse {
  posts: PostListItemApiResponse[];
  total_count: number;
  has_more: boolean;
}

interface CommentApiResponse {
  id: string;
  content: string;
  post_id: string;
  author: PostAuthorApiResponse;
  parent_id: string | null;
  vote_count: number;
  user_vote: VoteType | null;
  depth: number;
  replies: CommentApiResponse[];
  created_at: string;
  updated_at: string;
}

interface VoteApiResponse {
  success: boolean;
  new_vote_count: number;
  user_vote: VoteType | null;
}

interface ReportApiResponse {
  id: string;
  target_type: 'post' | 'comment';
  target_id: string;
  reason: string;
  status: string;
  created_at: string;
}

interface GuideSectionApiResponse {
  category: CategoryListApiResponse;
  guides: PostListItemApiResponse[];
}

interface RecommendedForumApiResponse {
  category: CategoryListApiResponse;
  matched_flaws: string[];
  priority: number;
}

// === FORUM TRANSFORM FUNCTIONS ===

function transformSubForum(data: SubForumApiResponse): SubForum {
  return {
    id: data.id,
    name: data.name,
    slug: data.slug,
    description: data.description,
    icon: data.icon,
    displayOrder: data.display_order,
    postCount: data.post_count,
  };
}

function transformCategory(data: CategoryApiResponse): Category {
  return {
    id: data.id,
    name: data.name,
    slug: data.slug,
    description: data.description,
    icon: data.icon,
    displayOrder: data.display_order,
    postCount: data.post_count,
    subForums: data.sub_forums.map(transformSubForum),
  };
}

function transformCategoryListItem(data: CategoryListApiResponse): CategoryListItem {
  return {
    id: data.id,
    name: data.name,
    slug: data.slug,
    description: data.description,
    icon: data.icon,
    displayOrder: data.display_order,
    postCount: data.post_count,
  };
}

function transformPostAuthor(data: PostAuthorApiResponse): PostAuthor {
  return {
    id: data.id,
    username: data.username,
  };
}

function transformPost(data: PostApiResponse): Post {
  return {
    id: data.id,
    title: data.title,
    content: data.content,
    subForumId: data.sub_forum_id,
    subForumSlug: data.sub_forum_slug,
    categorySlug: data.category_slug,
    author: transformPostAuthor(data.author),
    isPinned: data.is_pinned,
    isGuide: data.is_guide,
    voteCount: data.vote_count,
    commentCount: data.comment_count,
    userVote: data.user_vote,
    createdAt: data.created_at,
    updatedAt: data.updated_at,
  };
}

function transformPostListItem(data: PostListItemApiResponse): PostListItem {
  return {
    id: data.id,
    title: data.title,
    contentPreview: data.content_preview,
    subForumSlug: data.sub_forum_slug,
    categorySlug: data.category_slug,
    author: transformPostAuthor(data.author),
    isPinned: data.is_pinned,
    isGuide: data.is_guide,
    voteCount: data.vote_count,
    commentCount: data.comment_count,
    userVote: data.user_vote,
    createdAt: data.created_at,
  };
}

function transformPostListResponse(data: PostListApiResponse): PostListResponse {
  return {
    posts: data.posts.map(transformPostListItem),
    totalCount: data.total_count,
    hasMore: data.has_more,
  };
}

function transformComment(data: CommentApiResponse): Comment {
  return {
    id: data.id,
    content: data.content,
    postId: data.post_id,
    author: transformPostAuthor(data.author),
    parentId: data.parent_id,
    voteCount: data.vote_count,
    userVote: data.user_vote,
    depth: data.depth,
    replies: data.replies.map(transformComment),
    createdAt: data.created_at,
    updatedAt: data.updated_at,
  };
}

function transformVoteResponse(data: VoteApiResponse): VoteResponse {
  return {
    success: data.success,
    newVoteCount: data.new_vote_count,
    userVote: data.user_vote,
  };
}

function transformReport(data: ReportApiResponse): Report {
  return {
    id: data.id,
    targetType: data.target_type,
    targetId: data.target_id,
    reason: data.reason as Report['reason'],
    status: data.status,
    createdAt: data.created_at,
  };
}

function transformGuideSection(data: GuideSectionApiResponse): GuideSection {
  return {
    category: transformCategoryListItem(data.category),
    guides: data.guides.map(transformPostListItem),
  };
}

function transformRecommendedForum(data: RecommendedForumApiResponse): RecommendedForum {
  return {
    category: transformCategoryListItem(data.category),
    matchedFlaws: data.matched_flaws,
    priority: data.priority,
  };
}

interface ApiOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  body?: unknown;
  token?: string;
}

interface Analysis {
  id: string;
  front_image_url: string | null;
  side_image_url: string | null;
  front_landmarks: Record<string, unknown> | null;
  side_landmarks: Record<string, unknown> | null;
  scores: Record<string, unknown> | null;
  gender: string | null;
  ethnicity: string | null;
  created_at: string;
}

class ApiClient {
  private token: string | null = null;

  setToken(token: string | null) {
    this.token = token;
  }

  getToken(): string | null {
    if (typeof window !== 'undefined') {
      return this.token || localStorage.getItem('auth_token');
    }
    return this.token;
  }

  private async request<T>(endpoint: string, options: ApiOptions = {}): Promise<T> {
    const { method = 'GET', body, token } = options;
    const authToken = token || this.getToken();

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (authToken) {
      headers['Authorization'] = `Bearer ${authToken}`;
    }

    const response = await fetch(`${API_URL}${endpoint}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({ detail: 'Request failed' }));
      throw new Error(error.detail || `HTTP ${response.status}`);
    }

    // Handle empty responses (204 No Content)
    if (response.status === 204) {
      return undefined as T;
    }

    return response.json();
  }

  // Health check
  async health(): Promise<{ status: string; detection_ready: boolean }> {
    return this.request('/health');
  }

  // Analyses CRUD
  async listAnalyses(limit = 50, offset = 0): Promise<Analysis[]> {
    return this.request(`/analyses?limit=${limit}&offset=${offset}`);
  }

  async createAnalysis(data: {
    front_image_url?: string;
    side_image_url?: string;
    front_landmarks?: Record<string, unknown>;
    side_landmarks?: Record<string, unknown>;
    scores?: Record<string, unknown>;
    gender?: string;
    ethnicity?: string;
  }): Promise<Analysis> {
    return this.request('/analyses', { method: 'POST', body: data });
  }

  async getAnalysis(id: string): Promise<Analysis> {
    return this.request(`/analyses/${id}`);
  }

  async deleteAnalysis(id: string): Promise<void> {
    return this.request(`/analyses/${id}`, { method: 'DELETE' });
  }

  // Payments
  async createCheckout(plan: 'basic' | 'pro'): Promise<{ checkout_url: string; session_id: string }> {
    return this.request(`/payments/checkout?plan=${plan}`, { method: 'POST' });
  }

  async getPaymentHistory(): Promise<Array<{
    id: string;
    amount: number;
    currency: string;
    status: string;
    created_at: string;
  }>> {
    return this.request('/payments/history');
  }

  // Leaderboard
  async submitScore(data: {
    score: number;
    analysis_id?: string;
    gender: 'male' | 'female';
    ethnicity?: string;
    face_photo_url?: string;
    top_strengths?: string[];
    top_improvements?: string[];
  }): Promise<UserRank> {
    const response = await this.request<LeaderboardApiResponse>('/leaderboard/score', {
      method: 'POST',
      body: data,
    });
    return transformUserRank(response);
  }

  async getMyRank(): Promise<UserRank> {
    const response = await this.request<LeaderboardApiResponse>('/leaderboard/rank');
    return transformUserRank(response);
  }

  async getLeaderboard(options?: {
    gender?: 'male' | 'female';
    limit?: number;
    offset?: number;
  }): Promise<LeaderboardData> {
    const params = new URLSearchParams();
    if (options?.gender) params.set('gender', options.gender);
    if (options?.limit) params.set('limit', String(options.limit));
    if (options?.offset) params.set('offset', String(options.offset));
    const query = params.toString() ? `?${params}` : '';
    const response = await this.request<LeaderboardListResponse>(`/leaderboard${query}`);
    return transformLeaderboardData(response);
  }

  async getLeaderboardAroundMe(rangeSize?: number): Promise<LeaderboardData> {
    const query = rangeSize ? `?range_size=${rangeSize}` : '';
    const response = await this.request<LeaderboardListResponse>(`/leaderboard/around-me${query}`);
    return transformLeaderboardData(response);
  }

  async getUserProfile(userId: string): Promise<UserProfile> {
    const response = await this.request<UserProfileResponse>(`/leaderboard/user/${userId}`);
    return transformUserProfile(response);
  }

  // Auth
  async checkUsername(username: string): Promise<{ available: boolean; reason: string | null }> {
    return this.request(`/auth/check-username/${encodeURIComponent(username)}`);
  }

  async register(data: {
    email: string;
    password: string;
    username: string;
    termsAccepted: boolean;
    referralCode?: string;
  }): Promise<{ access_token: string; token_type: string; user: { id: string; email: string; username: string; plan: string } }> {
    return this.request('/auth/register', {
      method: 'POST',
      body: {
        email: data.email,
        password: data.password,
        username: data.username,
        terms_accepted: data.termsAccepted,
        referral_code: data.referralCode,
      },
    });
  }

  async login(data: { email: string; password: string }): Promise<{ access_token: string; token_type: string; user: { id: string; email: string; username: string; plan: string } }> {
    return this.request('/auth/login', {
      method: 'POST',
      body: data,
    });
  }

  async validateReferralCode(code: string): Promise<{ valid: boolean; message: string | null }> {
    return this.request(`/auth/validate-referral/${encodeURIComponent(code)}`);
  }

  async requestPasswordReset(email: string): Promise<{ message: string }> {
    return this.request('/auth/forgot-password', {
      method: 'POST',
      body: { email },
    });
  }

  async resetPassword(token: string, newPassword: string): Promise<{ message: string }> {
    return this.request('/auth/reset-password', {
      method: 'POST',
      body: { token, new_password: newPassword },
    });
  }

  // === FORUM ===

  // Categories
  async getForumCategories(): Promise<Category[]> {
    const response = await this.request<CategoryApiResponse[]>('/forum/categories');
    return response.map(transformCategory);
  }

  async getForumCategory(slug: string): Promise<Category> {
    const response = await this.request<CategoryApiResponse>(`/forum/categories/${slug}`);
    return transformCategory(response);
  }

  // Guides
  async getForumGuides(): Promise<GuideSection[]> {
    const response = await this.request<GuideSectionApiResponse[]>('/forum/guides');
    return response.map(transformGuideSection);
  }

  // Recommended forums based on flaws
  async getRecommendedForums(flaws: string[]): Promise<RecommendedForum[]> {
    const params = new URLSearchParams();
    params.set('flaws', flaws.join(','));
    const response = await this.request<RecommendedForumApiResponse[]>(`/forum/recommended?${params}`);
    return response.map(transformRecommendedForum);
  }

  // Posts
  async getForumPosts(
    categorySlug: string,
    options?: {
      subForumSlug?: string;
      sort?: SortOrder;
      limit?: number;
      offset?: number;
    }
  ): Promise<PostListResponse> {
    const params = new URLSearchParams();
    if (options?.sort) params.set('sort', options.sort);
    if (options?.limit) params.set('limit', String(options.limit));
    if (options?.offset) params.set('offset', String(options.offset));
    const query = params.toString() ? `?${params}` : '';

    const endpoint = options?.subForumSlug
      ? `/forum/categories/${categorySlug}/${options.subForumSlug}/posts${query}`
      : `/forum/categories/${categorySlug}/posts${query}`;

    const response = await this.request<PostListApiResponse>(endpoint);
    return transformPostListResponse(response);
  }

  async getForumPost(postId: string): Promise<Post> {
    const response = await this.request<PostApiResponse>(`/forum/posts/${postId}`);
    return transformPost(response);
  }

  async createForumPost(data: PostCreate): Promise<Post> {
    const response = await this.request<PostApiResponse>('/forum/posts', {
      method: 'POST',
      body: {
        title: data.title,
        content: data.content,
        sub_forum_id: data.subForumId,
      },
    });
    return transformPost(response);
  }

  async updateForumPost(postId: string, data: PostUpdate): Promise<Post> {
    const response = await this.request<PostApiResponse>(`/forum/posts/${postId}`, {
      method: 'PUT',
      body: data,
    });
    return transformPost(response);
  }

  async deleteForumPost(postId: string): Promise<void> {
    await this.request(`/forum/posts/${postId}`, { method: 'DELETE' });
  }

  // Comments
  async getForumComments(postId: string): Promise<Comment[]> {
    const response = await this.request<CommentApiResponse[]>(`/forum/posts/${postId}/comments`);
    return response.map(transformComment);
  }

  async createForumComment(postId: string, data: CommentCreate): Promise<Comment> {
    const response = await this.request<CommentApiResponse>(`/forum/posts/${postId}/comments`, {
      method: 'POST',
      body: {
        content: data.content,
        parent_id: data.parentId,
      },
    });
    return transformComment(response);
  }

  async updateForumComment(commentId: string, content: string): Promise<Comment> {
    const response = await this.request<CommentApiResponse>(`/forum/comments/${commentId}`, {
      method: 'PUT',
      body: { content },
    });
    return transformComment(response);
  }

  async deleteForumComment(commentId: string): Promise<void> {
    await this.request(`/forum/comments/${commentId}`, { method: 'DELETE' });
  }

  // Voting
  async voteForumPost(postId: string, voteType: VoteType): Promise<VoteResponse> {
    const response = await this.request<VoteApiResponse>(`/forum/posts/${postId}/vote`, {
      method: 'POST',
      body: { vote_type: voteType },
    });
    return transformVoteResponse(response);
  }

  async voteForumComment(commentId: string, voteType: VoteType): Promise<VoteResponse> {
    const response = await this.request<VoteApiResponse>(`/forum/comments/${commentId}/vote`, {
      method: 'POST',
      body: { vote_type: voteType },
    });
    return transformVoteResponse(response);
  }

  // Reports
  async createForumReport(data: ReportCreate): Promise<Report> {
    const response = await this.request<ReportApiResponse>('/forum/reports', {
      method: 'POST',
      body: {
        target_type: data.targetType,
        target_id: data.targetId,
        reason: data.reason,
        details: data.details,
      },
    });
    return transformReport(response);
  }
}

// Export singleton instance
export const api = new ApiClient();

// Export types
export type { Analysis };
