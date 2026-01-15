/**
 * Rate Limiter - Token Bucket Algorithm
 *
 * Implements per-provider rate limiting with automatic token refill
 * Based on clauded project's rate-limiter.js
 */

export interface RateLimiterConfig {
  [provider: string]: number; // requests per minute
}

export class RateLimiter {
  private limits: Map<string, number>;
  private buckets: Map<string, number>;
  private lastRefill: Map<string, number>;
  private queues: Map<string, Array<() => void>>;

  constructor(config: RateLimiterConfig = {}) {
    this.limits = new Map([
      ['anthropic', config.anthropic || 50],
      ['google', config.google || 60],
      ['glm', config.glm || 60],
      ['featherless', config.featherless || 100],
      ['mcp', config.mcp || 100]
    ]);

    this.buckets = new Map();
    this.lastRefill = new Map();
    this.queues = new Map();

    // Initialize buckets with full capacity
    for (const [provider, limit] of this.limits.entries()) {
      this.buckets.set(provider, limit);
      this.lastRefill.set(provider, Date.now());
      this.queues.set(provider, []);
    }
  }

  /**
   * Refill tokens based on elapsed time
   */
  private refillTokens(provider: string): void {
    const now = Date.now();
    const lastRefillTime = this.lastRefill.get(provider) || now;
    const elapsedSeconds = (now - lastRefillTime) / 1000;

    const limit = this.limits.get(provider) || 50;
    const tokensPerSecond = limit / 60;
    const tokensToAdd = elapsedSeconds * tokensPerSecond;

    const currentBucket = this.buckets.get(provider) || limit;
    const newBucket = Math.min(limit, currentBucket + tokensToAdd);

    this.buckets.set(provider, newBucket);
    this.lastRefill.set(provider, now);
  }

  /**
   * Check if a token is available for the provider
   */
  canProceed(provider: string): boolean {
    this.refillTokens(provider);
    const bucket = this.buckets.get(provider) || 0;
    return bucket >= 1;
  }

  /**
   * Consume a token for the provider
   */
  private consumeToken(provider: string): void {
    const current = this.buckets.get(provider) || 0;
    this.buckets.set(provider, Math.max(0, current - 1));
  }

  /**
   * Wait for a token to be available
   * Blocks until token available or timeout
   */
  async waitForToken(provider: string, timeoutMs: number = 60000): Promise<void> {
    const startTime = Date.now();

    while (!this.canProceed(provider)) {
      // Check timeout
      if (Date.now() - startTime > timeoutMs) {
        throw new Error(`Rate limit timeout for provider: ${provider}`);
      }

      // Calculate wait time based on token refill rate
      const limit = this.limits.get(provider) || 50;
      const tokensPerMs = limit / 60000;
      const waitTime = Math.ceil(1 / tokensPerMs);

      await new Promise(resolve => setTimeout(resolve, Math.min(waitTime, 1000)));
    }

    this.consumeToken(provider);
  }

  /**
   * Get current status for a provider
   */
  getStatus(provider: string): {
    available: number;
    limit: number;
    percentage: number;
  } {
    this.refillTokens(provider);

    const available = this.buckets.get(provider) || 0;
    const limit = this.limits.get(provider) || 50;
    const percentage = (available / limit) * 100;

    return { available, limit, percentage };
  }

  /**
   * Reset bucket for a provider (useful for testing)
   */
  reset(provider: string): void {
    const limit = this.limits.get(provider) || 50;
    this.buckets.set(provider, limit);
    this.lastRefill.set(provider, Date.now());
  }

  /**
   * Update limit for a provider
   */
  setLimit(provider: string, limit: number): void {
    this.limits.set(provider, limit);
    // Reset bucket to new limit
    this.buckets.set(provider, limit);
    this.lastRefill.set(provider, Date.now());
  }
}
