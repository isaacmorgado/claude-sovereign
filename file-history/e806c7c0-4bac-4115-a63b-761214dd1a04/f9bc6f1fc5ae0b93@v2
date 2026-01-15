/**
 * Server-Side Detection Service for Side Profiles
 *
 * Calls the Railway-hosted InsightFace API for accurate side profile detection.
 * Returns 106 raw landmarks mapped to our 28 cephalometric landmarks.
 */

import { SideLandmarkResponse } from '@/app/api/side-landmarks/route';

export interface ServerDetectionResult {
  landmarks: Array<{ id: string; x: number; y: number }>;
  confidence: number;
  faceBox: { x: number; y: number; width: number; height: number };
  direction?: 'left' | 'right';
  rotationAngle?: number;
  frankfortPlane?: {
    angle: number;
    orbitale: { x: number; y: number };
    porion: { x: number; y: number };
  };
}

/**
 * Convert image URL to base64
 */
async function imageUrlToBase64(imageUrl: string): Promise<string> {
  // If it's already a data URL, extract the base64 part
  if (imageUrl.startsWith('data:')) {
    return imageUrl;
  }

  // If it's a blob URL or regular URL, fetch and convert
  const response = await fetch(imageUrl);
  const blob = await response.blob();

  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => {
      if (typeof reader.result === 'string') {
        resolve(reader.result);
      } else {
        reject(new Error('Failed to convert to base64'));
      }
    };
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

/**
 * Calculate Frankfort Horizontal Plane from orbitale and porion landmarks
 */
function calculateFrankfortPlane(
  orbitale: { x: number; y: number },
  porion: { x: number; y: number }
): { angle: number; orbitale: { x: number; y: number }; porion: { x: number; y: number } } {
  // Calculate angle from horizontal (in degrees)
  const dx = porion.x - orbitale.x;
  const dy = porion.y - orbitale.y;
  const angle = Math.atan2(dy, dx) * (180 / Math.PI);

  return {
    angle,
    orbitale,
    porion,
  };
}

/**
 * Detect side profile landmarks using server-side InsightFace API
 */
export async function detectSideProfileServer(
  imageUrl: string
): Promise<ServerDetectionResult | null> {
  try {
    console.log('[ServerDetection] Starting server-side detection...');

    // Convert image to base64
    const base64Image = await imageUrlToBase64(imageUrl);

    // Call our API proxy
    const response = await fetch('/api/side-landmarks', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ image: base64Image }),
    });

    if (!response.ok) {
      console.error('[ServerDetection] API error:', response.status);
      return null;
    }

    const data: SideLandmarkResponse = await response.json();

    if (!data.success || !data.mapped_landmarks) {
      console.log('[ServerDetection] Detection failed:', data.message);
      return null;
    }

    console.log('[ServerDetection] Detection successful:', data.message);

    // Convert mapped_landmarks object to array format matching our system
    const landmarks = Object.entries(data.mapped_landmarks).map(([id, point]) => ({
      id,
      x: point.x,
      y: point.y,
    }));

    // Use Frankfort Plane from server if available, otherwise calculate locally
    let frankfortPlane: ServerDetectionResult['frankfortPlane'];
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const serverFrankfort = (data as any).frankfort_plane;
    if (serverFrankfort) {
      frankfortPlane = serverFrankfort;
      console.log('[ServerDetection] Frankfort Plane angle (from server):', serverFrankfort.angle.toFixed(2), 'degrees');
    } else if (data.mapped_landmarks.orbitale && data.mapped_landmarks.porion) {
      frankfortPlane = calculateFrankfortPlane(
        data.mapped_landmarks.orbitale,
        data.mapped_landmarks.porion
      );
      console.log('[ServerDetection] Frankfort Plane angle (calculated):', frankfortPlane.angle.toFixed(2), 'degrees');
    }

    return {
      landmarks,
      confidence: 0.95, // InsightFace is generally high confidence
      faceBox: data.face_box || { x: 0, y: 0, width: 1, height: 1 },
      direction: data.direction,
      rotationAngle: data.rotation_angle,
      frankfortPlane,
    };
  } catch (error) {
    console.error('[ServerDetection] Error:', error);
    return null;
  }
}
