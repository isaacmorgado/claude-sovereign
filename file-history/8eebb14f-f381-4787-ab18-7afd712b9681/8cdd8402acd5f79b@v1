/**
 * Error Handler - Classification and Recovery
 *
 * Provides error classification, retry strategies, and exponential backoff
 * Based on clauded project's error handling patterns
 */

export type ErrorType =
  | 'rate_limit'
  | 'authentication'
  | 'timeout'
  | 'network'
  | 'invalid_request'
  | 'server_error'
  | 'unknown';

export interface RetryOptions {
  maxRetries?: number;
  initialDelay?: number;
  maxDelay?: number;
  factor?: number;
  onRetry?: (attempt: number, delay: number, error: Error) => void;
}

export interface ClassifiedError {
  type: ErrorType;
  message: string;
  isRetryable: boolean;
  suggestedDelay?: number;
  originalError: Error;
}

export class ErrorHandler {
  /**
   * Classify an error based on message and properties
   */
  classify(error: Error | any): ClassifiedError {
    const message = error.message || String(error);
    const statusCode = error.status || error.statusCode;

    // Rate limit errors (429)
    if (
      statusCode === 429 ||
      message.includes('429') ||
      message.includes('rate limit') ||
      message.includes('quota exceeded') ||
      message.includes('too many requests')
    ) {
      return {
        type: 'rate_limit',
        message: 'Rate limit exceeded. Please wait before retrying.',
        isRetryable: true,
        suggestedDelay: this.parseRetryAfter(error),
        originalError: error
      };
    }

    // Authentication errors (401, 403)
    if (
      statusCode === 401 ||
      statusCode === 403 ||
      message.includes('401') ||
      message.includes('403') ||
      message.includes('authentication') ||
      message.includes('unauthorized') ||
      message.includes('invalid api key') ||
      message.includes('invalid bearer token')
    ) {
      return {
        type: 'authentication',
        message: 'Authentication failed. Check your API key.',
        isRetryable: false,
        originalError: error
      };
    }

    // Timeout errors
    if (
      message.includes('timeout') ||
      message.includes('ETIMEDOUT') ||
      message.includes('ECONNRESET') ||
      message.includes('ESOCKETTIMEDOUT') ||
      error.code === 'ETIMEDOUT'
    ) {
      return {
        type: 'timeout',
        message: 'Request timeout. The provider may be slow or unavailable.',
        isRetryable: true,
        suggestedDelay: 2000,
        originalError: error
      };
    }

    // Network errors
    if (
      message.includes('ECONNREFUSED') ||
      message.includes('ENOTFOUND') ||
      message.includes('ENETUNREACH') ||
      message.includes('network') ||
      error.code === 'ECONNREFUSED' ||
      error.code === 'ENOTFOUND'
    ) {
      return {
        type: 'network',
        message: 'Network error. Check your internet connection.',
        isRetryable: true,
        suggestedDelay: 1000,
        originalError: error
      };
    }

    // Invalid request errors (400)
    if (
      statusCode === 400 ||
      message.includes('400') ||
      message.includes('invalid request') ||
      message.includes('bad request')
    ) {
      return {
        type: 'invalid_request',
        message: 'Invalid request. Check your input parameters.',
        isRetryable: false,
        originalError: error
      };
    }

    // Server errors (500+)
    if (
      statusCode >= 500 ||
      message.includes('500') ||
      message.includes('502') ||
      message.includes('503') ||
      message.includes('504') ||
      message.includes('server error') ||
      message.includes('internal error')
    ) {
      return {
        type: 'server_error',
        message: 'Server error. The provider may be experiencing issues.',
        isRetryable: true,
        suggestedDelay: 5000,
        originalError: error
      };
    }

    // Unknown error
    return {
      type: 'unknown',
      message: message || 'An unknown error occurred.',
      isRetryable: false,
      originalError: error
    };
  }

  /**
   * Parse Retry-After header value (seconds or HTTP date)
   */
  private parseRetryAfter(error: any): number {
    const retryAfter = error.response?.headers?.['retry-after'] ||
                       error.headers?.['retry-after'];

    if (!retryAfter) return 60000; // Default 60s

    // If it's a number (seconds)
    const seconds = parseInt(retryAfter, 10);
    if (!isNaN(seconds)) {
      return seconds * 1000;
    }

    // If it's a date
    try {
      const retryDate = new Date(retryAfter);
      const now = new Date();
      return Math.max(0, retryDate.getTime() - now.getTime());
    } catch {
      return 60000;
    }
  }

  /**
   * Determine if error should be retried
   */
  shouldRetry(classified: ClassifiedError, attempt: number, maxRetries: number): boolean {
    if (!classified.isRetryable) return false;
    if (attempt >= maxRetries) return false;
    return true;
  }

  /**
   * Calculate retry delay with exponential backoff
   */
  calculateDelay(classified: ClassifiedError, attempt: number, options: RetryOptions = {}): number {
    const initialDelay = options.initialDelay || 1000;
    const maxDelay = options.maxDelay || 60000;
    const factor = options.factor || 2;

    // Use suggested delay if available (e.g., from Retry-After header)
    if (classified.suggestedDelay) {
      return Math.min(classified.suggestedDelay, maxDelay);
    }

    // Rate limits get 2x longer backoff
    const multiplier = classified.type === 'rate_limit' ? 2 : 1;

    // Exponential backoff: delay * (factor ^ attempt) * multiplier
    const delay = initialDelay * Math.pow(factor, attempt) * multiplier;

    return Math.min(delay, maxDelay);
  }

  /**
   * Retry a function with exponential backoff
   */
  async retryWithBackoff<T>(
    fn: (attempt: number) => Promise<T>,
    options: RetryOptions = {}
  ): Promise<T> {
    const maxRetries = options.maxRetries || 3;
    const onRetry = options.onRetry;

    let lastError: Error | any;

    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await fn(attempt);
      } catch (error) {
        lastError = error;

        const classified = this.classify(error);

        // Don't retry if not retryable or max attempts reached
        if (!this.shouldRetry(classified, attempt, maxRetries)) {
          throw error;
        }

        // Calculate delay
        const delay = this.calculateDelay(classified, attempt, options);

        // Call retry callback if provided
        if (onRetry) {
          onRetry(attempt + 1, delay, error as Error);
        }

        // Wait before retry
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }

    throw lastError;
  }

  /**
   * Create a user-friendly error message
   */
  formatError(classified: ClassifiedError): string {
    const prefix = this.getErrorPrefix(classified.type);
    return `${prefix} ${classified.message}`;
  }

  private getErrorPrefix(type: ErrorType): string {
    switch (type) {
      case 'rate_limit': return '[RATE LIMIT]';
      case 'authentication': return '[AUTH ERROR]';
      case 'timeout': return '[TIMEOUT]';
      case 'network': return '[NETWORK ERROR]';
      case 'invalid_request': return '[INVALID REQUEST]';
      case 'server_error': return '[SERVER ERROR]';
      default: return '[ERROR]';
    }
  }

  /**
   * Get remediation suggestions for error types
   */
  getRemediation(type: ErrorType): string[] {
    switch (type) {
      case 'rate_limit':
        return [
          'Wait for the rate limit to reset',
          'Reduce the number of concurrent requests',
          'Consider upgrading your API plan'
        ];
      case 'authentication':
        return [
          'Check that ANTHROPIC_API_KEY is set correctly',
          'Verify your API key is valid at console.anthropic.com',
          'Ensure the API key has not been revoked'
        ];
      case 'timeout':
        return [
          'Increase the request timeout value',
          'Try again in a few moments',
          'Check if the provider is experiencing issues'
        ];
      case 'network':
        return [
          'Check your internet connection',
          'Verify firewall settings',
          'Try using a different network'
        ];
      case 'invalid_request':
        return [
          'Check your input parameters',
          'Verify the model name is correct',
          'Review the API documentation for valid inputs'
        ];
      case 'server_error':
        return [
          'Wait a few minutes and try again',
          'Check provider status page',
          'Consider using a fallback provider'
        ];
      default:
        return ['Review the error message for details'];
    }
  }
}
