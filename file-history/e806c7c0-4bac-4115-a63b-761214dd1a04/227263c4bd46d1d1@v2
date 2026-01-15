import { NextRequest, NextResponse } from 'next/server';

/**
 * Proxy route for side profile landmark detection
 * Forwards requests to the Railway-hosted InsightFace API
 */

const DETECTION_API_URL = process.env.DETECTION_API_URL || 'http://localhost:8000';

export interface SideLandmarkResponse {
  success: boolean;
  message: string;
  direction?: 'left' | 'right';
  rotation_angle?: number;
  raw_landmarks?: Array<{ x: number; y: number }>;
  mapped_landmarks?: Record<string, { x: number; y: number }>;
  face_box?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
  frankfort_plane?: {
    angle: number;
    orbitale: { x: number; y: number };
    porion: { x: number; y: number };
  };
}

export async function POST(request: NextRequest) {
  try {
    // Handle JSON request with base64 image
    const body = await request.json();

    const response = await fetch(`${DETECTION_API_URL}/detection/side`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('[Side Landmarks API] Error from detection server:', errorText);
      return NextResponse.json(
        { success: false, message: 'Detection server error' },
        { status: response.status }
      );
    }

    const data: SideLandmarkResponse = await response.json();
    return NextResponse.json(data);
  } catch (error) {
    console.error('[Side Landmarks API] Error:', error);

    // Check if it's a connection error (server not running)
    if (error instanceof Error && error.message.includes('fetch failed')) {
      return NextResponse.json(
        {
          success: false,
          message: 'Detection server unavailable. Please try again later.',
        },
        { status: 503 }
      );
    }

    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}
