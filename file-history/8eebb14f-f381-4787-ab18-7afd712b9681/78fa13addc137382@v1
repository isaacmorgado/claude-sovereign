/**
 * Endpoint Manager - Multi-Endpoint Fallback
 *
 * Manages multiple API endpoints with automatic failover
 * Based on clauded project's multi-endpoint patterns
 */

export interface Endpoint {
  url: string;
  priority: number;  // Lower = higher priority (0 is highest)
  weight?: number;   // For load balancing (higher = more requests)
  maxRetries?: number;
}

export interface EndpointHealth {
  url: string;
  isHealthy: boolean;
  consecutiveFailures: number;
  lastFailure?: Date;
  lastSuccess?: Date;
  avgLatency?: number;  // milliseconds
}

export interface EndpointManagerConfig {
  endpoints: Endpoint[];
  maxConsecutiveFailures: number;  // Mark unhealthy after N failures
  recoveryTimeout: number;  // Milliseconds before retrying failed endpoint
  defaultTimeout: number;  // Request timeout in milliseconds
}

/**
 * Endpoint Manager for multi-endpoint failover
 */
export class EndpointManager {
  private config: EndpointManagerConfig;
  private health: Map<string, EndpointHealth>;

  constructor(config: Partial<EndpointManagerConfig> = {}) {
    this.config = {
      endpoints: config.endpoints || [],
      maxConsecutiveFailures: config.maxConsecutiveFailures || 3,
      recoveryTimeout: config.recoveryTimeout || 60000,  // 1 minute
      defaultTimeout: config.defaultTimeout || 30000  // 30 seconds
    };

    this.health = new Map();

    // Initialize health tracking
    for (const endpoint of this.config.endpoints) {
      this.health.set(endpoint.url, {
        url: endpoint.url,
        isHealthy: true,
        consecutiveFailures: 0
      });
    }
  }

  /**
   * Get next available endpoint in priority order
   */
  getNextEndpoint(): string | null {
    // Sort endpoints by priority
    const sortedEndpoints = [...this.config.endpoints]
      .sort((a, b) => a.priority - b.priority);

    // Find first healthy endpoint
    for (const endpoint of sortedEndpoints) {
      const health = this.health.get(endpoint.url);

      if (!health) continue;

      // Check if endpoint is healthy or ready to recover
      if (health.isHealthy) {
        return endpoint.url;
      }

      // Check recovery timeout
      if (health.lastFailure) {
        const timeSinceFailure = Date.now() - health.lastFailure.getTime();
        if (timeSinceFailure >= this.config.recoveryTimeout) {
          // Try again - mark as healthy for retry
          health.isHealthy = true;
          health.consecutiveFailures = 0;
          return endpoint.url;
        }
      }
    }

    // No healthy endpoints - return highest priority anyway (desperation fallback)
    return sortedEndpoints[0]?.url || null;
  }

  /**
   * Get all available (healthy) endpoints
   */
  getAvailableEndpoints(): string[] {
    return this.config.endpoints
      .filter(endpoint => {
        const health = this.health.get(endpoint.url);
        return health?.isHealthy ?? true;
      })
      .sort((a, b) => a.priority - b.priority)
      .map(e => e.url);
  }

  /**
   * Record successful request
   */
  recordSuccess(url: string, latency?: number): void {
    const health = this.health.get(url);
    if (!health) return;

    health.isHealthy = true;
    health.consecutiveFailures = 0;
    health.lastSuccess = new Date();

    // Update average latency (exponential moving average)
    if (latency !== undefined) {
      if (health.avgLatency === undefined) {
        health.avgLatency = latency;
      } else {
        health.avgLatency = 0.7 * health.avgLatency + 0.3 * latency;
      }
    }
  }

  /**
   * Record failed request
   */
  recordFailure(url: string): void {
    const health = this.health.get(url);
    if (!health) return;

    health.consecutiveFailures++;
    health.lastFailure = new Date();

    // Mark unhealthy if too many consecutive failures
    if (health.consecutiveFailures >= this.config.maxConsecutiveFailures) {
      health.isHealthy = false;
    }
  }

  /**
   * Execute request with automatic failover
   */
  async executeWithFailover<T>(
    requestFn: (url: string) => Promise<T>,
    maxAttempts: number = 3
  ): Promise<T> {
    let lastError: Error | null = null;
    let attemptCount = 0;

    while (attemptCount < maxAttempts) {
      const endpoint = this.getNextEndpoint();

      if (!endpoint) {
        throw new Error('No available endpoints');
      }

      attemptCount++;

      try {
        const startTime = Date.now();
        const result = await requestFn(endpoint);
        const latency = Date.now() - startTime;

        this.recordSuccess(endpoint, latency);
        return result;
      } catch (error) {
        lastError = error as Error;
        this.recordFailure(endpoint);

        // If this was the last attempt or a non-retryable error, throw
        if (attemptCount >= maxAttempts || !this.isRetryableError(error)) {
          throw error;
        }

        // Otherwise, wait a bit before trying next endpoint
        await this.delay(Math.min(1000 * attemptCount, 5000));
      }
    }

    throw lastError || new Error('All endpoints failed');
  }

  /**
   * Check if error is retryable (network/timeout errors)
   */
  private isRetryableError(error: any): boolean {
    const retryablePatterns = [
      'ECONNREFUSED',
      'ENOTFOUND',
      'ETIMEDOUT',
      'ECONNRESET',
      '500',
      '502',
      '503',
      '504'
    ];

    const errorString = String(error).toLowerCase();
    return retryablePatterns.some(pattern =>
      errorString.includes(pattern.toLowerCase())
    );
  }

  /**
   * Delay helper
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Get health status for all endpoints
   */
  getHealthStatus(): EndpointHealth[] {
    return Array.from(this.health.values());
  }

  /**
   * Get health status for specific endpoint
   */
  getEndpointHealth(url: string): EndpointHealth | undefined {
    return this.health.get(url);
  }

  /**
   * Manually mark endpoint as healthy
   */
  markHealthy(url: string): void {
    const health = this.health.get(url);
    if (health) {
      health.isHealthy = true;
      health.consecutiveFailures = 0;
    }
  }

  /**
   * Manually mark endpoint as unhealthy
   */
  markUnhealthy(url: string): void {
    const health = this.health.get(url);
    if (health) {
      health.isHealthy = false;
      health.lastFailure = new Date();
    }
  }

  /**
   * Add new endpoint
   */
  addEndpoint(endpoint: Endpoint): void {
    this.config.endpoints.push(endpoint);
    this.health.set(endpoint.url, {
      url: endpoint.url,
      isHealthy: true,
      consecutiveFailures: 0
    });
  }

  /**
   * Remove endpoint
   */
  removeEndpoint(url: string): void {
    this.config.endpoints = this.config.endpoints.filter(e => e.url !== url);
    this.health.delete(url);
  }

  /**
   * Get configuration
   */
  getConfig(): EndpointManagerConfig {
    return { ...this.config };
  }
}
