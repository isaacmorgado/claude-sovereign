/**
 * API Client for LOOKSMAXX Backend
 *
 * Handles all authenticated requests to the Railway-hosted API
 */

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

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
}

// Export singleton instance
export const api = new ApiClient();

// Export types
export type { Analysis };
