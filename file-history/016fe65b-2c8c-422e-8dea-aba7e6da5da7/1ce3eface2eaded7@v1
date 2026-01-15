/**
 * Share Results Functionality
 * Uses Web Share API when available, with clipboard fallback
 */

export interface ShareData {
  title: string;
  text: string;
  url?: string;
}

export interface ShareResult {
  success: boolean;
  method: 'native' | 'clipboard' | 'failed';
  error?: string;
}

/**
 * Generate shareable text for results
 */
export function generateShareText(score: number | string, frontScore?: number | string, sideScore?: number | string): string {
  const numericScore = typeof score === 'number' ? score : 0;
  const emoji = numericScore >= 8 ? '🔥' : numericScore >= 6 ? '✨' : '📊';
  const scoreDisplay = typeof score === 'number' ? score.toFixed(1) : score;

  let text = `${emoji} My LOOKSMAXX Facial Harmony Score: ${scoreDisplay}/10`;

  if (frontScore !== undefined && sideScore !== undefined) {
    const frontDisplay = typeof frontScore === 'number' ? frontScore.toFixed(1) : frontScore;
    const sideDisplay = typeof sideScore === 'number' ? sideScore.toFixed(1) : sideScore;
    text += `\n• Front Profile: ${frontDisplay}/10`;
    text += `\n• Side Profile: ${sideDisplay}/10`;
  }

  return text;
}

/**
 * Share results using Web Share API or clipboard fallback
 */
export async function shareResults(data: ShareData): Promise<ShareResult> {
  // Check if Web Share API is available
  if (typeof navigator !== 'undefined' && 'share' in navigator) {
    try {
      await navigator.share({
        title: data.title,
        text: data.text,
        url: data.url,
      });
      return { success: true, method: 'native' };
    } catch (error) {
      // User cancelled share or error occurred
      if (error instanceof Error && error.name === 'AbortError') {
        return { success: false, method: 'failed', error: 'Share cancelled' };
      }
      // Fall through to clipboard fallback
    }
  }

  // Fallback: copy to clipboard
  try {
    const textToCopy = data.url
      ? `${data.text}\n\n${data.url}`
      : data.text;

    await navigator.clipboard.writeText(textToCopy);
    return { success: true, method: 'clipboard' };
  } catch (error) {
    return {
      success: false,
      method: 'failed',
      error: error instanceof Error ? error.message : 'Failed to copy to clipboard'
    };
  }
}

/**
 * Check if native sharing is supported
 */
export function isNativeShareSupported(): boolean {
  return typeof navigator !== 'undefined' && 'share' in navigator;
}

/**
 * Generate a shareable URL (if implemented with server-side storage)
 * For now, returns the current page URL
 */
export function getShareableUrl(): string {
  if (typeof window !== 'undefined') {
    return window.location.href;
  }
  return '';
}
