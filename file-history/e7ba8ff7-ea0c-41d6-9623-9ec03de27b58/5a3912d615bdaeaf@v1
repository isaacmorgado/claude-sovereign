'use client';

import { useCallback, useState } from 'react';
import { useFaceLandmarker, FaceLandmark } from './useFaceLandmarker';
import { useFaceApi, FaceApiLandmark } from './useFaceApi';
import {
  LandmarkPoint,
  FRONT_PROFILE_LANDMARKS,
  SIDE_PROFILE_LANDMARKS,
} from '@/lib/landmarks';
import { MEDIAPIPE_FRONT_MAPPING } from '@/lib/mediapipeDetection';

export interface AutoDetectionResult {
  landmarks: LandmarkPoint[];
  confidence: number;
  detectionMethod: 'mediapipe' | 'faceapi' | 'manual';
}

export interface UseAutoDetectionReturn {
  // MediaPipe for front face
  frontDetector: {
    isLoading: boolean;
    isReady: boolean;
    error: Error | null;
    detect: (image: HTMLImageElement) => Promise<AutoDetectionResult | null>;
  };
  // face-api.js for side profile
  sideDetector: {
    isLoading: boolean;
    isReady: boolean;
    error: Error | null;
    detect: (image: HTMLImageElement) => Promise<AutoDetectionResult | null>;
  };
}

/**
 * Maps MediaPipe 478-point landmarks to our front profile structure
 */
function mapMediaPipeToFrontLandmarks(
  mediaPipeLandmarks: FaceLandmark[]
): LandmarkPoint[] {
  return FRONT_PROFILE_LANDMARKS.map((landmark) => {
    const mediaPipeIndex = MEDIAPIPE_FRONT_MAPPING[landmark.id];

    if (mediaPipeIndex !== undefined && mediaPipeLandmarks[mediaPipeIndex]) {
      const mp = mediaPipeLandmarks[mediaPipeIndex];
      return {
        ...landmark,
        x: mp.x, // MediaPipe returns normalized 0-1
        y: mp.y,
      };
    }

    // Return default position if no mapping exists
    return landmark;
  });
}

/**
 * Maps face-api.js 68-point landmarks to our side profile structure
 * Uses intelligent estimation for landmarks not directly available
 */
function mapFaceApiToSideLandmarks(
  faceApiLandmarks: FaceApiLandmark[],
  imageWidth: number,
  imageHeight: number
): LandmarkPoint[] {
  // Normalize face-api.js landmarks (they come in pixel coordinates)
  const normalized = faceApiLandmarks.map((lm) => ({
    x: lm.x / imageWidth,
    y: lm.y / imageHeight,
  }));

  // face-api.js 68-point model indices:
  // 0-16: Jaw contour
  // 17-21: Left eyebrow
  // 22-26: Right eyebrow
  // 27-30: Nose bridge
  // 31-35: Lower nose
  // 36-41: Left eye
  // 42-47: Right eye
  // 48-59: Outer lip
  // 60-67: Inner lip

  // Determine if this is a left or right side profile
  // by checking which side has more visible landmarks
  const leftEyeCenter = {
    x: (normalized[36].x + normalized[39].x) / 2,
    y: (normalized[36].y + normalized[39].y) / 2,
  };
  const rightEyeCenter = {
    x: (normalized[42].x + normalized[45].x) / 2,
    y: (normalized[42].y + normalized[45].y) / 2,
  };
  const noseCenter = normalized[30];

  // If right eye is closer to center than left, it's a left-facing profile
  const isLeftProfile = Math.abs(rightEyeCenter.x - noseCenter.x) < Math.abs(leftEyeCenter.x - noseCenter.x);

  return SIDE_PROFILE_LANDMARKS.map((landmark) => {
    let x = landmark.x;
    let y = landmark.y;

    switch (landmark.id) {
      // Cranium - estimate from jaw and nose
      case 'vertex':
        y = Math.min(normalized[19].y, normalized[24].y) - 0.15;
        x = (normalized[27].x + normalized[0].x) / 2;
        break;
      case 'trichion_profile':
        y = Math.min(normalized[19].y, normalized[24].y) - 0.08;
        x = normalized[27].x;
        break;
      case 'external_occipital_region':
        x = isLeftProfile ? normalized[16].x + 0.05 : normalized[0].x - 0.05;
        y = normalized[27].y - 0.1;
        break;

      // Forehead
      case 'frontalis':
        x = normalized[27].x - 0.02;
        y = normalized[27].y - 0.08;
        break;
      case 'glabella':
        x = normalized[27].x;
        y = normalized[27].y;
        break;

      // Eye region - use visible eye
      case 'corneal_apex':
        if (isLeftProfile) {
          x = normalized[42].x - 0.02;
          y = (normalized[43].y + normalized[47].y) / 2;
        } else {
          x = normalized[36].x + 0.02;
          y = (normalized[37].y + normalized[41].y) / 2;
        }
        break;
      case 'lateral_eyelid':
        if (isLeftProfile) {
          x = normalized[45].x;
          y = normalized[45].y;
        } else {
          x = normalized[36].x;
          y = normalized[36].y;
        }
        break;
      case 'palpebra_inferior_side':
        if (isLeftProfile) {
          x = (normalized[46].x + normalized[47].x) / 2;
          y = (normalized[46].y + normalized[47].y) / 2;
        } else {
          x = (normalized[40].x + normalized[41].x) / 2;
          y = (normalized[40].y + normalized[41].y) / 2;
        }
        break;
      case 'orbitale':
        if (isLeftProfile) {
          x = normalized[47].x;
          y = normalized[47].y + 0.02;
        } else {
          x = normalized[41].x;
          y = normalized[41].y + 0.02;
        }
        break;

      // Nose - well supported by 68-point model
      case 'nasion':
        x = normalized[27].x;
        y = normalized[27].y;
        break;
      case 'rhinion':
        x = normalized[28].x;
        y = normalized[28].y;
        break;
      case 'supratip_break':
        x = normalized[29].x;
        y = normalized[29].y;
        break;
      case 'pronasale':
        x = normalized[30].x;
        y = normalized[30].y;
        break;
      case 'infratip_lobule':
        x = (normalized[30].x + normalized[33].x) / 2;
        y = (normalized[30].y + normalized[33].y) / 2;
        break;
      case 'columella_nasi':
        x = normalized[33].x;
        y = (normalized[30].y + normalized[33].y) / 2;
        break;
      case 'subnasale_side':
        x = normalized[33].x;
        y = normalized[33].y;
        break;
      case 'subalare':
        x = isLeftProfile ? normalized[35].x : normalized[31].x;
        y = isLeftProfile ? normalized[35].y : normalized[31].y;
        break;

      // Lips - well supported
      case 'labrale_superius_side':
        x = normalized[51].x;
        y = normalized[51].y;
        break;
      case 'cheilion_side':
        x = isLeftProfile ? normalized[54].x : normalized[48].x;
        y = isLeftProfile ? normalized[54].y : normalized[48].y;
        break;
      case 'labrale_inferius_side':
        x = normalized[57].x;
        y = normalized[57].y;
        break;
      case 'sublabiale':
        x = normalized[57].x;
        y = normalized[57].y + 0.03;
        break;

      // Chin
      case 'pogonion':
        x = normalized[8].x;
        y = normalized[8].y - 0.02;
        break;
      case 'menton_side':
        x = normalized[8].x;
        y = normalized[8].y;
        break;

      // Jaw
      case 'gonion_superior_side':
        if (isLeftProfile) {
          x = normalized[12].x;
          y = normalized[12].y;
        } else {
          x = normalized[4].x;
          y = normalized[4].y;
        }
        break;
      case 'gonion_inferior_side':
        if (isLeftProfile) {
          x = (normalized[10].x + normalized[11].x) / 2;
          y = (normalized[10].y + normalized[11].y) / 2;
        } else {
          x = (normalized[5].x + normalized[6].x) / 2;
          y = (normalized[5].y + normalized[6].y) / 2;
        }
        break;

      // Cheek
      case 'zygion_soft_tissue':
        if (isLeftProfile) {
          x = normalized[15].x;
          y = (normalized[45].y + normalized[12].y) / 2;
        } else {
          x = normalized[1].x;
          y = (normalized[36].y + normalized[4].y) / 2;
        }
        break;

      // Ear - estimate from jaw contour
      case 'porion':
        if (isLeftProfile) {
          x = normalized[16].x;
          y = normalized[27].y;
        } else {
          x = normalized[0].x;
          y = normalized[27].y;
        }
        break;
      case 'tragion':
        if (isLeftProfile) {
          x = normalized[16].x - 0.01;
          y = (normalized[27].y + normalized[36].y) / 2;
        } else {
          x = normalized[0].x + 0.01;
          y = (normalized[27].y + normalized[36].y) / 2;
        }
        break;
      case 'incisura_intertragica':
        if (isLeftProfile) {
          x = normalized[16].x - 0.02;
          y = (normalized[27].y + normalized[12].y) / 2;
        } else {
          x = normalized[0].x + 0.02;
          y = (normalized[27].y + normalized[4].y) / 2;
        }
        break;

      // Neck - estimate from chin
      case 'cervicale':
        x = normalized[8].x + 0.1;
        y = normalized[8].y + 0.08;
        break;
      case 'anterior_cervical_landmark':
        x = normalized[8].x;
        y = normalized[8].y + 0.06;
        break;
    }

    return {
      ...landmark,
      x: Math.max(0, Math.min(1, x)),
      y: Math.max(0, Math.min(1, y)),
    };
  });
}

/**
 * Combined hook for face detection
 * Uses MediaPipe for front face (478 points) and face-api.js for side profile (68 points)
 */
export function useAutoDetection(): UseAutoDetectionReturn {
  const mediaPipe = useFaceLandmarker();
  const faceApi = useFaceApi();
  const [isDetecting, setIsDetecting] = useState(false);

  const detectFront = useCallback(
    async (image: HTMLImageElement): Promise<AutoDetectionResult | null> => {
      if (!mediaPipe.isReady) {
        throw new Error('MediaPipe Face Landmarker not ready');
      }

      setIsDetecting(true);
      try {
        const result = await mediaPipe.detect(image);

        if (!result || result.landmarks.length === 0) {
          return null;
        }

        const firstFace = result.landmarks[0];
        const mappedLandmarks = mapMediaPipeToFrontLandmarks(firstFace);

        return {
          landmarks: mappedLandmarks,
          confidence: 0.95, // MediaPipe is generally very accurate
          detectionMethod: 'mediapipe',
        };
      } finally {
        setIsDetecting(false);
      }
    },
    [mediaPipe]
  );

  const detectSide = useCallback(
    async (image: HTMLImageElement): Promise<AutoDetectionResult | null> => {
      if (!faceApi.isReady) {
        throw new Error('face-api.js not ready');
      }

      setIsDetecting(true);
      try {
        const result = await faceApi.detect(image);

        if (!result || result.landmarks.length === 0) {
          return null;
        }

        const mappedLandmarks = mapFaceApiToSideLandmarks(
          result.landmarks,
          image.naturalWidth,
          image.naturalHeight
        );

        return {
          landmarks: mappedLandmarks,
          confidence: 0.75, // Side profile detection is less accurate
          detectionMethod: 'faceapi',
        };
      } finally {
        setIsDetecting(false);
      }
    },
    [faceApi]
  );

  return {
    frontDetector: {
      isLoading: mediaPipe.isLoading || isDetecting,
      isReady: mediaPipe.isReady,
      error: mediaPipe.error,
      detect: detectFront,
    },
    sideDetector: {
      isLoading: faceApi.isLoading || isDetecting,
      isReady: faceApi.isReady,
      error: faceApi.error,
      detect: detectSide,
    },
  };
}
