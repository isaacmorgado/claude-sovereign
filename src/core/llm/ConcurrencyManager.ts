/**
 * Concurrency Manager - Token bucket + semaphore for LLM API rate limits
 *
 * Based on 2025 best practices from:
 * - Bottleneck library patterns (TypeScript concurrency control)
 * - Token bucket model (burst handling with average rate)
 * - Multi-provider semaphores (per-provider limits)
 *
 * Sources:
 * - https://dev.to/arifszn/prevent-api-overload-a-comprehensive-guide-to-rate-limiting-with-bottleneck-c2p
 * - https://www.requesty.ai/blog/rate-limits-for-llm-providers-openai-anthropic-and-deepseek
 */

export interface ConcurrencyConfig {
  maxConcurrent: number;      // Max concurrent requests
  minTimeBetween?: number;    // Min ms between requests
  reservoir?: number;         // Token bucket size
  reservoirRefresh?: number;  // Refresh interval (ms)
}

export interface ProviderLimits {
  [provider: string]: ConcurrencyConfig;
}

/**
 * Concurrency Manager using token bucket + semaphore pattern
 */
export class ConcurrencyManager {
  private semaphores: Map<string, Semaphore>;
  private tokenBuckets: Map<string, TokenBucket>;

  constructor(private limits: ProviderLimits) {
    this.semaphores = new Map();
    this.tokenBuckets = new Map();

    // Initialize semaphores and token buckets for each provider
    for (const [provider, config] of Object.entries(limits)) {
      this.semaphores.set(provider, new Semaphore(config.maxConcurrent));

      if (config.reservoir && config.reservoirRefresh) {
        this.tokenBuckets.set(
          provider,
          new TokenBucket(config.reservoir, config.reservoirRefresh)
        );
      }
    }
  }

  /**
   * Acquire permission to make a request
   * Returns a release function to call when done
   */
  async acquire(provider: string): Promise<() => void> {
    const semaphore = this.semaphores.get(provider);
    if (!semaphore) {
      throw new Error(`No concurrency limits configured for provider: ${provider}`);
    }

    // Check token bucket first (if configured)
    const tokenBucket = this.tokenBuckets.get(provider);
    if (tokenBucket) {
      await tokenBucket.consume();
    }

    // Acquire semaphore
    const release = await semaphore.acquire();

    // Apply minTimeBetween delay if configured
    const config = this.limits[provider];
    if (config.minTimeBetween) {
      await this.delay(config.minTimeBetween);
    }

    return release;
  }

  /**
   * Get current concurrency status for a provider
   */
  getStatus(provider: string): {
    available: number;
    max: number;
    waiting: number;
  } {
    const semaphore = this.semaphores.get(provider);
    if (!semaphore) {
      throw new Error(`No concurrency limits configured for provider: ${provider}`);
    }

    return semaphore.getStatus();
  }

  /**
   * Update limits for a provider (hot reload)
   */
  updateLimits(provider: string, config: ConcurrencyConfig): void {
    this.limits[provider] = config;
    this.semaphores.set(provider, new Semaphore(config.maxConcurrent));

    if (config.reservoir && config.reservoirRefresh) {
      this.tokenBuckets.set(
        provider,
        new TokenBucket(config.reservoir, config.reservoirRefresh)
      );
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/**
 * Semaphore implementation for concurrency control
 */
class Semaphore {
  private permits: number;
  private queue: Array<() => void> = [];

  constructor(private maxPermits: number) {
    this.permits = maxPermits;
  }

  async acquire(): Promise<() => void> {
    if (this.permits > 0) {
      this.permits--;
      return () => this.release();
    }

    // Wait in queue
    return new Promise<() => void>((resolve) => {
      this.queue.push(() => {
        this.permits--;
        resolve(() => this.release());
      });
    });
  }

  private release(): void {
    if (this.queue.length > 0) {
      const next = this.queue.shift()!;
      next();
    } else {
      this.permits++;
    }
  }

  getStatus() {
    return {
      available: this.permits,
      max: this.maxPermits,
      waiting: this.queue.length
    };
  }
}

/**
 * Token Bucket implementation for burst rate limiting
 */
class TokenBucket {
  private tokens: number;
  private lastRefresh: number;

  constructor(
    private capacity: number,
    private refreshInterval: number
  ) {
    this.tokens = capacity;
    this.lastRefresh = Date.now();
  }

  async consume(): Promise<void> {
    this.refill();

    if (this.tokens > 0) {
      this.tokens--;
      return;
    }

    // Wait for refill
    const waitTime = this.refreshInterval - (Date.now() - this.lastRefresh);
    if (waitTime > 0) {
      await new Promise(resolve => setTimeout(resolve, waitTime));
      await this.consume(); // Try again after wait
    }
  }

  private refill(): void {
    const now = Date.now();
    const elapsed = now - this.lastRefresh;

    if (elapsed >= this.refreshInterval) {
      this.tokens = this.capacity;
      this.lastRefresh = now;
    }
  }
}

/**
 * Default provider limits (based on known API limits)
 */
export const DEFAULT_PROVIDER_LIMITS: ProviderLimits = {
  // Kimi-K2: 4-unit concurrency (critical constraint discovered)
  'mcp': {
    maxConcurrent: 1,           // Conservative: 1 at a time
    minTimeBetween: 1000,       // 1s between requests
    reservoir: 4,               // 4 tokens per minute
    reservoirRefresh: 60000     // Refill every minute
  },

  // GLM-4.7: No concurrency limits (fallback)
  'glm': {
    maxConcurrent: 10,          // Liberal: no provider limit
    minTimeBetween: 100
  },

  // Featherless (Llama, Dolphin, etc): Moderate limits
  'featherless': {
    maxConcurrent: 5,
    minTimeBetween: 200,
    reservoir: 20,
    reservoirRefresh: 60000
  },

  // Anthropic: High limits for reference
  'anthropic': {
    maxConcurrent: 50,
    minTimeBetween: 50,
    reservoir: 100,
    reservoirRefresh: 60000
  }
};
