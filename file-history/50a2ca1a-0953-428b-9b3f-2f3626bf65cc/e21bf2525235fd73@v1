/**
 * API Client for LOOKSMAXX Backend
 *
 * Handles all authenticated requests to the Railway-hosted API
 */

import type { UserRank, LeaderboardEntry, LeaderboardData, UserProfile } from '@/types/results';

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
  }): Promise<{ access_token: string; token_type: string; user: { id: string; email: string; username: string; plan: string } }> {
    return this.request('/auth/register', {
      method: 'POST',
      body: {
        email: data.email,
        password: data.password,
        username: data.username,
        terms_accepted: data.termsAccepted,
      },
    });
  }

  async login(data: { email: string; password: string }): Promise<{ access_token: string; token_type: string; user: { id: string; email: string; username: string; plan: string } }> {
    return this.request('/auth/login', {
      method: 'POST',
      body: data,
    });
  }
}

// Export singleton instance
export const api = new ApiClient();

// Export types
export type { Analysis };
