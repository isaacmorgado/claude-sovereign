'use client';

import { useEffect, useRef, useState, useCallback } from 'react';
import {
  FaceLandmarker,
  FilesetResolver,
  FaceLandmarkerResult,
} from '@mediapipe/tasks-vision';

// Self-hosted for better reliability
const MODEL_URL = '/wasm/face_landmarker.task';
const VISION_WASM_URL = '/wasm';

export interface FaceLandmark {
  x: number;
  y: number;
  z: number;
}

export interface DetectionResult {
  landmarks: FaceLandmark[][];
  faceLandmarkerResult: FaceLandmarkerResult;
}

export interface UseFaceLandmarkerReturn {
  isLoading: boolean;
  isReady: boolean;
  error: Error | null;
  detect: (
    image: HTMLImageElement | HTMLVideoElement | HTMLCanvasElement
  ) => Promise<DetectionResult | null>;
}

export function useFaceLandmarker(): UseFaceLandmarkerReturn {
  const faceLandmarkerRef = useRef<FaceLandmarker | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isReady, setIsReady] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function initializeFaceLandmarker() {
      try {
        setIsLoading(true);
        setError(null);

        const vision = await FilesetResolver.forVisionTasks(VISION_WASM_URL);

        const landmarker = await FaceLandmarker.createFromOptions(vision, {
          baseOptions: {
            modelAssetPath: MODEL_URL,
            delegate: 'GPU',
          },
          runningMode: 'IMAGE',
          numFaces: 1,
          outputFaceBlendshapes: false,
          outputFacialTransformationMatrixes: false,
        });

        if (isMounted) {
          faceLandmarkerRef.current = landmarker;
          setIsReady(true);
          setIsLoading(false);
        } else {
          landmarker.close();
        }
      } catch (err) {
        if (isMounted) {
          const errorMessage =
            err instanceof Error ? err.message : 'Failed to initialize FaceLandmarker';
          setError(new Error(errorMessage));
          setIsLoading(false);
          setIsReady(false);
        }
      }
    }

    initializeFaceLandmarker();

    return () => {
      isMounted = false;
      if (faceLandmarkerRef.current) {
        faceLandmarkerRef.current.close();
        faceLandmarkerRef.current = null;
      }
    };
  }, []);

  const detect = useCallback(
    async (
      image: HTMLImageElement | HTMLVideoElement | HTMLCanvasElement
    ): Promise<DetectionResult | null> => {
      if (!faceLandmarkerRef.current) {
        throw new Error('FaceLandmarker is not initialized');
      }

      if (!isReady) {
        throw new Error('FaceLandmarker is not ready');
      }

      try {
        const result = faceLandmarkerRef.current.detect(image);

        if (!result.faceLandmarks || result.faceLandmarks.length === 0) {
          return null;
        }

        const landmarks: FaceLandmark[][] = result.faceLandmarks.map((face) =>
          face.map((point) => ({
            x: point.x,
            y: point.y,
            z: point.z,
          }))
        );

        return {
          landmarks,
          faceLandmarkerResult: result,
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
