/**
 * Forum Types - Matches backend Pydantic schemas
 */

// === ENUMS ===

export type VoteType = 'up' | 'down';

export type TargetType = 'post' | 'comment';

export type ReportReason =
  | 'spam'
  | 'harassment'
  | 'misinformation'
  | 'off_topic'
  | 'inappropriate'
  | 'other';

export type SortOrder = 'hot' | 'new' | 'top';

// === SUB-FORUM ===

export interface SubForum {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  icon: string | null;
  displayOrder: number;
  postCount: number;
}

// === CATEGORY ===

export interface Category {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  icon: string | null;
  displayOrder: number;
  postCount: number;
  subForums: SubForum[];
}

export interface CategoryListItem {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  icon: string | null;
  displayOrder: number;
  postCount: number;
}

// === POST ===

export interface PostAuthor {
  id: string;
  username: string;
}

export interface Post {
  id: string;
  title: string;
  content: string;
  subForumId: string;
  subForumSlug: string;
  categorySlug: string;
  author: PostAuthor;
  isPinned: boolean;
  isGuide: boolean;
  voteCount: number;
  commentCount: number;
  userVote: VoteType | null;
  createdAt: string;
  updatedAt: string;
}

export interface PostListItem {
  id: string;
  title: string;
  contentPreview: string;
  subForumSlug: string;
  categorySlug: string;
  author: PostAuthor;
  isPinned: boolean;
  isGuide: boolean;
  voteCount: number;
  commentCount: number;
  userVote: VoteType | null;
  createdAt: string;
}

export interface PostListResponse {
  posts: PostListItem[];
  totalCount: number;
  hasMore: boolean;
}

export interface PostCreate {
  title: string;
  content: string;
  subForumId: string;
}

export interface PostUpdate {
  title?: string;
  content?: string;
}

// === COMMENT ===

export interface Comment {
  id: string;
  content: string;
  postId: string;
  author: PostAuthor;
  parentId: string | null;
  voteCount: number;
  userVote: VoteType | null;
  depth: number;
  replies: Comment[];
  createdAt: string;
  updatedAt: string;
}

export interface CommentCreate {
  content: string;
  parentId?: string;
}

export interface CommentUpdate {
  content: string;
}

// === VOTE ===

export interface VoteRequest {
  voteType: VoteType;
}

export interface VoteResponse {
  success: boolean;
  newVoteCount: number;
  userVote: VoteType | null;
}

// === REPORT ===

export interface ReportCreate {
  targetType: TargetType;
  targetId: string;
  reason: ReportReason;
  details?: string;
}

export interface Report {
  id: string;
  targetType: TargetType;
  targetId: string;
  reason: ReportReason;
  status: string;
  createdAt: string;
}

// === GUIDES SECTION ===

export interface GuideSection {
  category: CategoryListItem;
  guides: PostListItem[];
}

// === RECOMMENDED FORUMS ===

export interface RecommendedForum {
  category: CategoryListItem;
  matchedFlaws: string[];
  priority: number;
}
