/**
 * Face Landmark Detection using MediaPipe Tasks Vision
 * Maps detected landmarks to our custom facial landmarks
 *
 * Uses the shared singleton service for optimal performance
 */

import { faceDetectionService } from './faceDetectionService';

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
// For side profile photos, uses MediaPipe LEFT indices (appearing on left side of image)
export const MEDIAPIPE_SIDE_MAPPING: Record<string, number> = {
  // Cranium (center/top landmarks)
  vertex: 10,
  external_occipital_region: 10,
  trichion_profile: 10,

  // Forehead (center landmarks)
  frontalis: 151,
  glabella: 9,

  // Eye Region - uses LEFT eye indices
  corneal_apex: 468,
  lateral_eyelid: 33,
  palpebra_inferior_side: 145,
  orbitale: 145,

  // Nose (center/midline landmarks)
  nasion: 6,
  rhinion: 4,
  supratip_break: 4,
  pronasale: 1,
  infratip_lobule: 2,
  columella_nasi: 2,
  subnasale_side: 2,
  subalare: 129,

  // Lips (mostly center landmarks)
  labrale_superius_side: 0,
  cheilion_side: 61,
  labrale_inferius_side: 17,
  sublabiale: 18,

  // Chin (center landmarks)
  pogonion: 152,
  menton_side: 152,

  // Jaw - uses LEFT jaw indices
  gonion_superior_side: 116,
  gonion_inferior_side: 172,

  // Cheek - uses LEFT cheekbone
  zygion_soft_tissue: 234,

  // Ear - uses LEFT ear area
  porion: 127,
  tragion: 127,
  incisura_intertragica: 127,

  // Neck
  cervicale: 152,
  anterior_cervical_landmark: 152,
};

export interface DetectedLandmarks {
  landmarks: Array<{ id: string; x: number; y: number }>;
  confidence: number;
  faceBox: { x: number; y: number; width: number; height: number };
}

/**
 * Detect facial landmarks from an image URL
 * Uses the singleton FaceDetectionService for optimal performance
 */
export async function detectFromImageUrl(
  imageUrl: string,
  mode: 'front' | 'side'
): Promise<DetectedLandmarks | null> {
  try {
    // Load the image
    const img = await loadImage(imageUrl);

    // Use the singleton service
    const result = await faceDetectionService.detect(img);

    if (!result.faceLandmarks || result.faceLandmarks.length === 0) {
      console.log('No faces detected');
      return null;
    }

    const faceLandmarks = result.faceLandmarks[0];

    // Select mapping based on mode
    const mapping = mode === 'front' ? MEDIAPIPE_FRONT_MAPPING : MEDIAPIPE_SIDE_MAPPING;

    // Map keypoints to our landmarks
    const landmarks = Object.entries(mapping).map(([id, index]) => {
      // Handle index bounds
      const safeIndex = Math.min(index, faceLandmarks.length - 1);
      const landmark = faceLandmarks[safeIndex];

      return {
        id,
        // MediaPipe returns normalized coordinates (0-1)
        x: landmark ? landmark.x : 0.5,
        y: landmark ? landmark.y : 0.5,
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
