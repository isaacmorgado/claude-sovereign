'use client';

import { useEffect, useRef, useState, useCallback } from 'react';

// face-api.js types
type FaceDetection = {
  box: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
};

type FaceLandmarks68 = {
  positions: Array<{ x: number; y: number }>;
};

type WithFaceLandmarks<T> = T & {
  landmarks: FaceLandmarks68;
  detection: FaceDetection;
};

export interface FaceApiLandmark {
  x: number;
  y: number;
}

export interface FaceApiDetectionResult {
  landmarks: FaceApiLandmark[];
  boundingBox: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

export interface UseFaceApiReturn {
  isLoading: boolean;
  isReady: boolean;
  error: Error | null;
  detect: (
    image: HTMLImageElement | HTMLVideoElement | HTMLCanvasElement
  ) => Promise<FaceApiDetectionResult | null>;
}

// Cache the loaded models
let modelsLoaded = false;
let faceapi: typeof import('face-api.js') | null = null;

export function useFaceApi(): UseFaceApiReturn {
  const [isLoading, setIsLoading] = useState(true);
  const [isReady, setIsReady] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const initializingRef = useRef(false);

  useEffect(() => {
    if (initializingRef.current || modelsLoaded) {
      if (modelsLoaded) {
        setIsReady(true);
        setIsLoading(false);
      }
      return;
    }

    initializingRef.current = true;

    async function loadModels() {
      try {
        setIsLoading(true);
        setError(null);

        // Dynamic import of face-api.js
        const faceApiModule = await import('face-api.js');
        faceapi = faceApiModule;

        // Load models from public/models directory
        const MODEL_URL = '/models';

        await Promise.all([
          faceapi.nets.ssdMobilenetv1.loadFromUri(MODEL_URL),
          faceapi.nets.faceLandmark68Net.loadFromUri(MODEL_URL),
          faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
          faceapi.nets.faceLandmark68TinyNet.loadFromUri(MODEL_URL),
        ]);

        modelsLoaded = true;
        setIsReady(true);
        setIsLoading(false);
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : 'Failed to load face-api.js models';
        setError(new Error(errorMessage));
        setIsLoading(false);
        initializingRef.current = false;
      }
    }

    loadModels();
  }, []);

  const detect = useCallback(
    async (
      image: HTMLImageElement | HTMLVideoElement | HTMLCanvasElement
    ): Promise<FaceApiDetectionResult | null> => {
      if (!faceapi || !isReady) {
        throw new Error('face-api.js is not initialized');
      }

      try {
        // Detect faces with landmarks using SSD MobileNet (better for side profiles)
        const detectionWithLandmarks = await faceapi
          .detectSingleFace(image, new faceapi.SsdMobilenetv1Options({ minConfidence: 0.3 }))
          .withFaceLandmarks() as WithFaceLandmarks<FaceDetection> | undefined;

        if (!detectionWithLandmarks) {
          // Try with tiny face detector as fallback
          const tinyDetection = await faceapi
            .detectSingleFace(image, new faceapi.TinyFaceDetectorOptions({ inputSize: 512, scoreThreshold: 0.3 }))
            .withFaceLandmarks(true) as WithFaceLandmarks<FaceDetection> | undefined;

          if (!tinyDetection) {
            return null;
          }

          const landmarks = tinyDetection.landmarks.positions.map((point) => ({
            x: point.x,
            y: point.y,
          }));

          return {
            landmarks,
            boundingBox: {
              x: tinyDetection.detection.box.x,
              y: tinyDetection.detection.box.y,
              width: tinyDetection.detection.box.width,
              height: tinyDetection.detection.box.height,
            },
          };
        }

        // Extract 68-point landmarks
        const landmarks = detectionWithLandmarks.landmarks.positions.map((point) => ({
          x: point.x,
          y: point.y,
        }));

        return {
          landmarks,
          boundingBox: {
            x: detectionWithLandmarks.detection.box.x,
            y: detectionWithLandmarks.detection.box.y,
            width: detectionWithLandmarks.detection.box.width,
            height: detectionWithLandmarks.detection.box.height,
          },
        };
      } catch (err) {
        const errorMessage =
          err instanceof Error ? err.message : 'Face detection failed';
        throw new Error(errorMessage);
      }
    },
    [isReady]
  );

  return {
    isLoading,
    isReady,
    error,
    detect,
  };
}

/**
 * Maps the 68-point landmarks from face-api.js to our side profile landmark structure
 * The 68-point model landmarks:
 * 0-16: Jaw contour
 * 17-21: Left eyebrow
 * 22-26: Right eyebrow
 * 27-30: Nose bridge
 * 31-35: Lower nose
 * 36-41: Left eye
 * 42-47: Right eye
 * 48-59: Outer lip
 * 60-67: Inner lip
 */
export const FACE_API_LANDMARK_MAPPING = {
  // Jaw contour (for side profile)
  JAW_CONTOUR: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
  MENTON: 8, // Chin center
  GNATHION: 8, // Same as menton for 68-point model

  // Nose
  NOSE_BRIDGE: [27, 28, 29, 30],
  NASION: 27, // Bridge of nose
  PRONASALE: 30, // Nose tip
  NOSE_TIP: 30,
  LEFT_NOSTRIL: 31,
  RIGHT_NOSTRIL: 35,
  NOSE_BOTTOM: [31, 32, 33, 34, 35],

  // Eyes
  LEFT_EYE: [36, 37, 38, 39, 40, 41],
  RIGHT_EYE: [42, 43, 44, 45, 46, 47],
  LEFT_EYE_INNER: 39,
  LEFT_EYE_OUTER: 36,
  RIGHT_EYE_INNER: 42,
  RIGHT_EYE_OUTER: 45,

  // Eyebrows
  LEFT_EYEBROW: [17, 18, 19, 20, 21],
  RIGHT_EYEBROW: [22, 23, 24, 25, 26],
  LEFT_BROW_INNER: 21,
  LEFT_BROW_OUTER: 17,
  RIGHT_BROW_INNER: 22,
  RIGHT_BROW_OUTER: 26,

  // Lips
  OUTER_LIP: [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59],
  INNER_LIP: [60, 61, 62, 63, 64, 65, 66, 67],
  UPPER_LIP_TOP: 51,
  LOWER_LIP_BOTTOM: 57,
  LEFT_MOUTH_CORNER: 48,
  RIGHT_MOUTH_CORNER: 54,
  LIP_CENTER_TOP: 62,
  LIP_CENTER_BOTTOM: 66,
};

/**
 * Convert normalized landmarks (0-1) to pixel coordinates
 */
export function normalizeToPixels(
  landmarks: FaceApiLandmark[],
  imageWidth: number,
  imageHeight: number
): FaceApiLandmark[] {
  return landmarks.map((lm) => ({
    x: lm.x / imageWidth,
    y: lm.y / imageHeight,
  }));
}

/**
 * Get specific landmark group for side profile analysis
 */
export function getSideProfileLandmarks(landmarks: FaceApiLandmark[]): {
  jawContour: FaceApiLandmark[];
  noseBridge: FaceApiLandmark[];
  chin: FaceApiLandmark;
  noseTip: FaceApiLandmark;
  nasion: FaceApiLandmark;
  upperLip: FaceApiLandmark;
  lowerLip: FaceApiLandmark;
} {
  return {
    jawContour: FACE_API_LANDMARK_MAPPING.JAW_CONTOUR.map((i) => landmarks[i]),
    noseBridge: FACE_API_LANDMARK_MAPPING.NOSE_BRIDGE.map((i) => landmarks[i]),
    chin: landmarks[FACE_API_LANDMARK_MAPPING.MENTON],
    noseTip: landmarks[FACE_API_LANDMARK_MAPPING.PRONASALE],
    nasion: landmarks[FACE_API_LANDMARK_MAPPING.NASION],
    upperLip: landmarks[FACE_API_LANDMARK_MAPPING.UPPER_LIP_TOP],
    lowerLip: landmarks[FACE_API_LANDMARK_MAPPING.LOWER_LIP_BOTTOM],
  };
}
