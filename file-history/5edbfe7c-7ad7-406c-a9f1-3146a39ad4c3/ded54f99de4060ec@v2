/**
 * Rate Limiting Library
 * Pattern from content-cat: Redis-backed with in-memory fallback
 * Implements plan-based quotas for LOOKSMAXX
 */

// ============================================
// TYPES
// ============================================

export interface RateLimitConfig {
  limit: number;
  windowMs: number;
  name?: string;
}

export interface RateLimitResult {
  success: boolean;
  limit: number;
  remaining: number;
  resetTime: number; // Unix timestamp
}

export interface PlanQuotas {
  analysesPerMonth: number;
  resultsDownloads: number;
  forumPosts: number;
  profileUpdates: number;
}

// ============================================
// PLAN CONFIGURATIONS
// ============================================

export const PLAN_QUOTAS: Record<string, PlanQuotas> = {
  free: {
    analysesPerMonth: 3,
    resultsDownloads: 1,
    forumPosts: 5,
    profileUpdates: 2,
  },
  basic: {
    analysesPerMonth: 30,
    resultsDownloads: 10,
    forumPosts: 50,
    profileUpdates: 10,
  },
  pro: {
    analysesPerMonth: 100,
    resultsDownloads: 50,
    forumPosts: 200,
    profileUpdates: 50,
  },
  plus: {
    analysesPerMonth: -1, // Unlimited
    resultsDownloads: -1,
    forumPosts: -1,
    profileUpdates: -1,
  },
};

export const RATE_LIMITS: Record<string, RateLimitConfig> = {
  // API rate limits (requests per minute)
  analysis: { limit: 10, windowMs: 60000, name: 'analysis' },
  standard: { limit: 100, windowMs: 60000, name: 'standard' },
  read: { limit: 200, windowMs: 60000, name: 'read' },
  sensitive: { limit: 20, windowMs: 60000, name: 'sensitive' },

  // Feature-specific limits
  forumPost: { limit: 10, windowMs: 3600000, name: 'forum_post' }, // 10 per hour
  download: { limit: 5, windowMs: 3600000, name: 'download' }, // 5 per hour
};

// ============================================
// IN-MEMORY RATE LIMITER (Fallback)
// ============================================

interface RateLimitEntry {
  count: number;
  resetTime: number;
}

const rateLimitStore = new Map<string, RateLimitEntry>();
const MAX_ENTRIES = 10000;

// Cleanup old entries every minute
let cleanupInterval: NodeJS.Timer | null = null;

function initCleanup() {
  if (cleanupInterval) return;

  if (typeof setInterval !== 'undefined') {
    cleanupInterval = setInterval(() => {
      const now = Date.now();
      let deleted = 0;

      const entries = Array.from(rateLimitStore.entries());
      for (let i = 0; i < entries.length; i++) {
        const [key, entry] = entries[i];
        if (entry.resetTime < now) {
          rateLimitStore.delete(key);
          deleted++;
        }
        // LRU eviction if too many entries
        if (rateLimitStore.size > MAX_ENTRIES && deleted < 100) {
          rateLimitStore.delete(key);
          deleted++;
        }
      }
    }, 60000);
  }
}

export function checkRateLimitMemory(
  identifier: string,
  config: RateLimitConfig
): RateLimitResult {
  initCleanup();

  const key = `ratelimit:${config.name || 'default'}:${identifier}`;
  const now = Date.now();
  const entry = rateLimitStore.get(key);

  // If no entry or window expired, create new one
  if (!entry || entry.resetTime < now) {
    const newEntry: RateLimitEntry = {
      count: 1,
      resetTime: now + config.windowMs,
    };
    rateLimitStore.set(key, newEntry);

    return {
      success: true,
      limit: config.limit,
      remaining: config.limit - 1,
      resetTime: newEntry.resetTime,
    };
  }

  // Check if limit exceeded
  if (entry.count >= config.limit) {
    return {
      success: false,
      limit: config.limit,
      remaining: 0,
      resetTime: entry.resetTime,
    };
  }

  // Increment count
  entry.count++;
  rateLimitStore.set(key, entry);

  return {
    success: true,
    limit: config.limit,
    remaining: config.limit - entry.count,
    resetTime: entry.resetTime,
  };
}

// ============================================
// QUOTA TRACKING
// ============================================

interface QuotaEntry {
  used: number;
  limit: number;
  resetDate: string; // YYYY-MM format for monthly reset
}

const quotaStore = new Map<string, QuotaEntry>();

function getCurrentMonth(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
}

export function checkQuota(
  userId: string,
  quotaType: keyof PlanQuotas,
  plan: string = 'free'
): { allowed: boolean; used: number; limit: number; remaining: number } {
  const planQuotas = PLAN_QUOTAS[plan] || PLAN_QUOTAS.free;
  const limit = planQuotas[quotaType];

  // Unlimited
  if (limit === -1) {
    return { allowed: true, used: 0, limit: -1, remaining: -1 };
  }

  const key = `quota:${userId}:${quotaType}`;
  const currentMonth = getCurrentMonth();
  const entry = quotaStore.get(key);

  // Reset if new month
  if (!entry || entry.resetDate !== currentMonth) {
    quotaStore.set(key, {
      used: 0,
      limit,
      resetDate: currentMonth,
    });
    return { allowed: true, used: 0, limit, remaining: limit };
  }

  const remaining = limit - entry.used;

  return {
    allowed: remaining > 0,
    used: entry.used,
    limit,
    remaining: Math.max(0, remaining),
  };
}

export function incrementQuota(
  userId: string,
  quotaType: keyof PlanQuotas,
  plan: string = 'free'
): void {
  const key = `quota:${userId}:${quotaType}`;
  const currentMonth = getCurrentMonth();
  const entry = quotaStore.get(key);

  if (!entry || entry.resetDate !== currentMonth) {
    const planQuotas = PLAN_QUOTAS[plan] || PLAN_QUOTAS.free;
    quotaStore.set(key, {
      used: 1,
      limit: planQuotas[quotaType],
      resetDate: currentMonth,
    });
  } else {
    entry.used++;
    quotaStore.set(key, entry);
  }
}

// ============================================
// RATE LIMIT HEADERS
// ============================================

export function createRateLimitHeaders(result: RateLimitResult): Record<string, string> {
  return {
    'X-RateLimit-Limit': String(result.limit),
    'X-RateLimit-Remaining': String(result.remaining),
    'X-RateLimit-Reset': String(Math.ceil(result.resetTime / 1000)),
  };
}

// ============================================
// MAIN CHECK FUNCTION
// ============================================

export async function checkRateLimit(
  identifier: string,
  config: RateLimitConfig
): Promise<RateLimitResult> {
  // For now, use in-memory. In production, this would check Redis first
  // and fall back to in-memory if Redis is unavailable
  return checkRateLimitMemory(identifier, config);
}

// ============================================
// HELPERS
// ============================================

export function getQuotaPercentage(used: number, limit: number): number {
  if (limit === -1) return 0; // Unlimited
  return Math.min(100, (used / limit) * 100);
}

export function formatQuotaRemaining(remaining: number, limit: number): string {
  if (limit === -1) return 'Unlimited';
  return `${remaining} of ${limit}`;
}

export function getQuotaStatus(percentage: number): 'good' | 'warning' | 'critical' {
  if (percentage >= 90) return 'critical';
  if (percentage >= 70) return 'warning';
  return 'good';
}
