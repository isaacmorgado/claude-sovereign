/**
 * Face Landmark Detection using MediaPipe Tasks Vision
 * Maps detected landmarks to our custom facial landmarks
 *
 * Detection hierarchy:
 * - Front profile: MediaPipe Face Mesh (478 landmarks)
 * - Side profile: Server-side InsightFace (106 landmarks) → Edge-based fallback
 */

import { faceDetectionService } from './faceDetectionService';
import { detectSideProfile } from './sideProfileDetection';
import { detectSideProfileServer } from './serverSideDetection';

// MediaPipe Face Mesh landmark indices (478 landmarks total)
// Reference: https://github.com/google/mediapipe/blob/master/mediapipe/modules/face_geometry/data/canonical_face_model_uv_visualization.png

// Front profile landmark mapping
// Based on the reference website's exact MediaPipe indices
// Uses SUBJECT's perspective: "left" = subject's left (appears on RIGHT side of image)
export const MEDIAPIPE_FRONT_MAPPING: Record<string, number> = {
  // Head
  trichion: 10, // hairline

  // Left Eye (subject's LEFT eye - appears on RIGHT of image)
  left_pupila: 468,
  left_canthus_medialis: 133,
  left_canthus_lateralis: 33,
  left_palpebra_superior: 470,
  left_palpebra_inferior: 472,
  left_sulcus_palpebralis_lateralis: 247,
  left_pretarsal_skin_crease: 470,

  // Right Eye (subject's RIGHT eye - appears on LEFT of image)
  right_pupila: 473,
  right_canthus_medialis: 362,
  right_canthus_lateralis: 263,
  right_palpebra_superior: 475,
  right_palpebra_inferior: 374,
  right_sulcus_palpebralis_lateralis: 467,
  right_pretarsal_skin_crease: 475,

  // Left Brow (subject's LEFT brow - appears on RIGHT of image)
  left_supercilium_medialis: 107,
  left_supercilium_medial_corner: 55,
  left_supercilium_superior: 52,
  left_supercilium_apex: 105,
  left_supercilium_lateralis: 70,

  // Right Brow (subject's RIGHT brow - appears on LEFT of image)
  right_supercilium_medialis: 336,
  right_supercilium_medial_corner: 285,
  right_supercilium_superior: 282,
  right_supercilium_apex: 334,
  right_supercilium_lateralis: 276,

  // Nose
  nasal_base: 290, // Base of nose (per landmarkers.js)
  left_dorsum_nasi: 174,
  right_dorsum_nasi: 399,
  left_ala_nasi: 48,
  right_ala_nasi: 278,
  subnasale: 2, // noseBottom in landmarkers.js

  // Mouth
  labrale_superius: 267, // cupidsBow - peak of cupid's bow
  cupids_bow: 0, // innerCupidsBow - center dip of upper lip
  mouth_middle: 14,
  labrale_inferius: 17,
  left_cheilion: 61,
  right_cheilion: 306,

  // Jaw
  left_gonion_superior: 58,
  right_gonion_superior: 288,
  left_gonion_inferior: 172,
  right_gonion_inferior: 397,

  // Chin
  left_mentum_lateralis: 176,
  right_mentum_lateralis: 400,
  menton: 152,

  // Cheeks
  left_zygion: 234,
  right_zygion: 454,
  left_malar: 205,        // Cheek center point for fullness calculation
  right_malar: 425,       // Cheek center point for fullness calculation
  left_temporal: 54,
  right_temporal: 284,

  // Ears
  left_auricular_lateral: 127,
  right_auricular_lateral: 356,

  // Neck (same as bottom gonion indices, but apply +5% yOffset when rendering)
  // Per landmarkers.js: neckLeft: 172 with yOffset: 0.05, neckRight: 397 with yOffset: 0.05
  left_cervical_lateralis: 172,
  right_cervical_lateralis: 397,
};

// Side profile landmark mapping (IDs must match SIDE_PROFILE_LANDMARKS in landmarks.ts)
// Matches FaceIQ's 28 side profile landmarks exactly
// For side profile photos, uses MediaPipe LEFT indices (appearing on left side of image)
// Note: FaceIQ uses a custom server-side model for side detection; this is our MediaPipe fallback
export const MEDIAPIPE_SIDE_MAPPING: Record<string, number> = {
  // 1. vertex - top of head
  vertex: 10,
  // 2. occiput - back of head (no good MediaPipe equivalent, use top)
  occiput: 10,
  // 3. pronasale - nose tip
  pronasale: 1,
  // 4. neckPoint - lower neck (no good equivalent, use chin)
  neckPoint: 152,
  // 5. porion - ear canal opening (use ear area)
  porion: 127,
  // 6. orbitale - lowest point of orbital rim (index 33 per FaceIQ landmarkers.js)
  orbitale: 33,
  // 7. tragus - ear cartilage
  tragus: 127,
  // 8. intertragicNotch - notch in ear
  intertragicNotch: 127,
  // 9. cornealApex - forward point of cornea
  cornealApex: 468,
  // 10. cheekbone - zygomatic prominence
  cheekbone: 234,
  // 11. trichion - hairline
  trichion: 10,
  // 12. glabella - between brows
  glabella: 9,
  // 13. nasion - nasal root depression
  nasion: 6,
  // 14. rhinion - dorsal nose point
  rhinion: 4,
  // 15. supratip - above nose tip
  supratip: 4,
  // 16. infratip - below nose tip
  infratip: 2,
  // 17. columella - nasal septum
  columella: 2,
  // 18. subnasale - nose base meets upper lip
  subnasale: 2,
  // 19. subalare - nostril wing
  subalare: 129,
  // 20. labraleSuperius - upper lip
  labraleSuperius: 0,
  // 21. cheilion - mouth corner
  cheilion: 61,
  // 22. labraleInferius - lower lip
  labraleInferius: 17,
  // 23. sublabiale - below lower lip
  sublabiale: 18,
  // 24. pogonion - chin point
  pogonion: 152,
  // 25. menton - chin bottom
  menton: 152,
  // 26. cervicalPoint - high neck point
  cervicalPoint: 152,
  // 27. gonionTop - upper jaw angle
  gonionTop: 116,
  // 28. gonionBottom - lower jaw angle
  gonionBottom: 172,
};

export interface DetectedLandmarks {
  landmarks: Array<{ id: string; x: number; y: number }>;
  confidence: number;
  faceBox: { x: number; y: number; width: number; height: number };
  frankfortPlane?: {
    angle: number;
    orbitale: { x: number; y: number };
    porion: { x: number; y: number };
  };
}

/**
 * Detect facial landmarks from an image URL
 *
 * Detection hierarchy:
 * - Front profile: MediaPipe Face Mesh (478 landmarks) - unchanged
 * - Side profile: Server-side InsightFace → Edge-based fallback → Manual placement
 */
export async function detectFromImageUrl(
  imageUrl: string,
  mode: 'front' | 'side'
): Promise<DetectedLandmarks | null> {
  try {
    // ============================================
    // SIDE PROFILE: Use server-side detection
    // ============================================
    if (mode === 'side') {
      console.log('[Detection] Side profile mode - trying server-side detection...');

      // Try server-side InsightFace first (best accuracy)
      const serverResult = await detectSideProfileServer(imageUrl);
      if (serverResult) {
        console.log('[Detection] Server-side detection succeeded');
        return {
          landmarks: serverResult.landmarks,
          confidence: serverResult.confidence,
          faceBox: serverResult.faceBox,
          frankfortPlane: serverResult.frankfortPlane,
        };
      }

      console.log('[Detection] Server-side failed, trying edge-based detection...');

      // Fallback to edge-based detection
      const sideResult = await detectSideProfile(imageUrl);
      if (sideResult) {
        console.log('[Detection] Edge-based side profile detection succeeded');
        return {
          landmarks: sideResult.landmarks,
          confidence: sideResult.confidence,
          faceBox: {
            x: 0,
            y: 0,
            width: 1,
            height: 1,
          },
        };
      }

      console.log('[Detection] All side profile detection methods failed - manual placement required');
      return null;
    }

    // ============================================
    // FRONT PROFILE: Use MediaPipe (UNCHANGED)
    // ============================================
    // Load the image
    const img = await loadImage(imageUrl);

    // Use the singleton service
    const result = await faceDetectionService.detect(img);

    // Check if MediaPipe detected a face
    const mediaPipeSucceeded = result.faceLandmarks && result.faceLandmarks.length > 0;

    if (!mediaPipeSucceeded) {
      console.log('No faces detected');
      return null;
    }

    const faceLandmarks = result.faceLandmarks[0];

    // Front profile uses MediaPipe mapping
    const mapping = MEDIAPIPE_FRONT_MAPPING;

    // Neck landmarks need +5% yOffset per FaceIQ landmarkers.js
    const NECK_Y_OFFSET = 0.05;
    const NECK_LANDMARKS = ['left_cervical_lateralis', 'right_cervical_lateralis'];

    // Map keypoints to our landmarks
    const landmarks = Object.entries(mapping).map(([id, index]) => {
      // Handle index bounds
      const safeIndex = Math.min(index, faceLandmarks.length - 1);
      const landmark = faceLandmarks[safeIndex];

      // Apply yOffset for neck landmarks
      const yOffset = NECK_LANDMARKS.includes(id) ? NECK_Y_OFFSET : 0;

      return {
        id,
        // MediaPipe returns normalized coordinates (0-1)
        x: landmark ? landmark.x : 0.5,
        y: landmark ? Math.min(landmark.y + yOffset, 1) : 0.5,
      };
    });

    // Calculate face bounding box from all landmarks
    let minX = 1, minY = 1, maxX = 0, maxY = 0;
    faceLandmarks.forEach((lm) => {
      minX = Math.min(minX, lm.x);
      minY = Math.min(minY, lm.y);
      maxX = Math.max(maxX, lm.x);
      maxY = Math.max(maxY, lm.y);
    });

    return {
      landmarks,
      confidence: 0.95, // MediaPipe doesn't return confidence per landmark
      faceBox: {
        x: minX,
        y: minY,
        width: maxX - minX,
        height: maxY - minY,
      },
    };
  } catch (error) {
    console.error('Face detection error:', error);
    return null;
  }
}

/**
 * Load an image from URL
 */
function loadImage(url: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => resolve(img);
    img.onerror = (e) => reject(e);
    img.src = url;
  });
}

/**
 * Get the region to zoom into for a specific landmark
 */
export function getLandmarkZoomRegion(
  landmarkId: string
): { centerX: number; centerY: number; zoomLevel: number } {
  const regions: Record<string, { centerX: number; centerY: number; zoomLevel: number }> = {
    // Eyes - zoom in close
    left_pupila: { centerX: 0.35, centerY: 0.35, zoomLevel: 3 },
    left_canthus_medialis: { centerX: 0.4, centerY: 0.35, zoomLevel: 3 },
    left_canthus_lateralis: { centerX: 0.3, centerY: 0.35, zoomLevel: 3 },
    right_pupila: { centerX: 0.65, centerY: 0.35, zoomLevel: 3 },
    right_canthus_medialis: { centerX: 0.6, centerY: 0.35, zoomLevel: 3 },
    right_canthus_lateralis: { centerX: 0.7, centerY: 0.35, zoomLevel: 3 },

    // Brows
    left_supercilium_apex: { centerX: 0.35, centerY: 0.28, zoomLevel: 2.5 },
    right_supercilium_apex: { centerX: 0.65, centerY: 0.28, zoomLevel: 2.5 },

    // Nose
    nasal_base: { centerX: 0.5, centerY: 0.4, zoomLevel: 2 },
    subnasale: { centerX: 0.5, centerY: 0.55, zoomLevel: 2.5 },

    // Mouth
    labrale_superius: { centerX: 0.5, centerY: 0.6, zoomLevel: 2.5 },
    mouth_middle: { centerX: 0.5, centerY: 0.65, zoomLevel: 2 },

    // Chin
    menton: { centerX: 0.5, centerY: 0.85, zoomLevel: 2 },

    // Default for other landmarks
    default: { centerX: 0.5, centerY: 0.5, zoomLevel: 1.5 },
  };

  return regions[landmarkId] || regions.default;
}
