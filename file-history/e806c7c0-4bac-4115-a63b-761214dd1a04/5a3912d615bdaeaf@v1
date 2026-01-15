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

    // FaceIQ landmark order: vertex, occiput, pronasale, neckPoint, porion, orbitale,
    // tragus, intertragicNotch, cornealApex, cheekbone, trichion, glabella, nasion,
    // rhinion, supratip, infratip, columella, subnasale, subalare, labraleSuperius,
    // cheilion, labraleInferius, sublabiale, pogonion, menton, cervicalPoint, gonionTop, gonionBottom
    switch (landmark.id) {
      // 1. vertex - top of head
      case 'vertex':
        y = Math.min(normalized[19].y, normalized[24].y) - 0.15;
        x = (normalized[27].x + normalized[0].x) / 2;
        break;
      // 2. occiput - back of head
      case 'occiput':
        x = isLeftProfile ? normalized[16].x + 0.05 : normalized[0].x - 0.05;
        y = normalized[27].y - 0.1;
        break;
      // 3. pronasale - nose tip
      case 'pronasale':
        x = normalized[30].x;
        y = normalized[30].y;
        break;
      // 4. neckPoint - lower neck
      case 'neckPoint':
        x = normalized[8].x;
        y = normalized[8].y + 0.06;
        break;
      // 5. porion - ear canal opening
      case 'porion':
        if (isLeftProfile) {
          x = normalized[16].x;
          y = normalized[27].y;
        } else {
          x = normalized[0].x;
          y = normalized[27].y;
        }
        break;
      // 6. orbitale - lowest orbital rim
      case 'orbitale':
        if (isLeftProfile) {
          x = normalized[47].x;
          y = normalized[47].y + 0.02;
        } else {
          x = normalized[41].x;
          y = normalized[41].y + 0.02;
        }
        break;
      // 7. tragus - ear cartilage
      case 'tragus':
        if (isLeftProfile) {
          x = normalized[16].x - 0.01;
          y = (normalized[27].y + normalized[36].y) / 2;
        } else {
          x = normalized[0].x + 0.01;
          y = (normalized[27].y + normalized[36].y) / 2;
        }
        break;
      // 8. intertragicNotch - notch in ear
      case 'intertragicNotch':
        if (isLeftProfile) {
          x = normalized[16].x - 0.02;
          y = (normalized[27].y + normalized[12].y) / 2;
        } else {
          x = normalized[0].x + 0.02;
          y = (normalized[27].y + normalized[4].y) / 2;
        }
        break;
      // 9. cornealApex - forward point of cornea
      case 'cornealApex':
        if (isLeftProfile) {
          x = normalized[42].x - 0.02;
          y = (normalized[43].y + normalized[47].y) / 2;
        } else {
          x = normalized[36].x + 0.02;
          y = (normalized[37].y + normalized[41].y) / 2;
        }
        break;
      // 10. cheekbone - zygomatic prominence
      case 'cheekbone':
        if (isLeftProfile) {
          x = normalized[15].x;
          y = (normalized[45].y + normalized[12].y) / 2;
        } else {
          x = normalized[1].x;
          y = (normalized[36].y + normalized[4].y) / 2;
        }
        break;
      // 11. trichion - hairline
      case 'trichion':
        y = Math.min(normalized[19].y, normalized[24].y) - 0.08;
        x = normalized[27].x;
        break;
      // 12. glabella - between brows
      case 'glabella':
        x = normalized[27].x;
        y = normalized[27].y;
        break;
      // 13. nasion - nasal root depression
      case 'nasion':
        x = normalized[27].x;
        y = normalized[27].y;
        break;
      // 14. rhinion - dorsal nose point
      case 'rhinion':
        x = normalized[28].x;
        y = normalized[28].y;
        break;
      // 15. supratip - above nose tip
      case 'supratip':
        x = normalized[29].x;
        y = normalized[29].y;
        break;
      // 16. infratip - below nose tip
      case 'infratip':
        x = (normalized[30].x + normalized[33].x) / 2;
        y = (normalized[30].y + normalized[33].y) / 2;
        break;
      // 17. columella - nasal septum
      case 'columella':
        x = normalized[33].x;
        y = (normalized[30].y + normalized[33].y) / 2;
        break;
      // 18. subnasale - nose base meets upper lip
      case 'subnasale':
        x = normalized[33].x;
        y = normalized[33].y;
        break;
      // 19. subalare - nostril wing
      case 'subalare':
        x = isLeftProfile ? normalized[35].x : normalized[31].x;
        y = isLeftProfile ? normalized[35].y : normalized[31].y;
        break;
      // 20. labraleSuperius - upper lip
      case 'labraleSuperius':
        x = normalized[51].x;
        y = normalized[51].y;
        break;
      // 21. cheilion - mouth corner
      case 'cheilion':
        x = isLeftProfile ? normalized[54].x : normalized[48].x;
        y = isLeftProfile ? normalized[54].y : normalized[48].y;
        break;
      // 22. labraleInferius - lower lip
      case 'labraleInferius':
        x = normalized[57].x;
        y = normalized[57].y;
        break;
      // 23. sublabiale - below lower lip
      case 'sublabiale':
        x = normalized[57].x;
        y = normalized[57].y + 0.03;
        break;
      // 24. pogonion - chin point
      case 'pogonion':
        x = normalized[8].x;
        y = normalized[8].y - 0.02;
        break;
      // 25. menton - chin bottom
      case 'menton':
        x = normalized[8].x;
        y = normalized[8].y;
        break;
      // 26. cervicalPoint - high neck point
      case 'cervicalPoint':
        x = normalized[8].x + 0.1;
        y = normalized[8].y + 0.08;
        break;
      // 27. gonionTop - upper jaw angle
      case 'gonionTop':
        if (isLeftProfile) {
          x = normalized[12].x;
          y = normalized[12].y;
        } else {
          x = normalized[4].x;
          y = normalized[4].y;
        }
        break;
      // 28. gonionBottom - lower jaw angle
      case 'gonionBottom':
        if (isLeftProfile) {
          x = (normalized[10].x + normalized[11].x) / 2;
          y = (normalized[10].y + normalized[11].y) / 2;
        } else {
          x = (normalized[5].x + normalized[6].x) / 2;
          y = (normalized[5].y + normalized[6].y) / 2;
        }
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
