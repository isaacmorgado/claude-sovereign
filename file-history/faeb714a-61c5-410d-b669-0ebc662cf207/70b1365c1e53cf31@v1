/**
 * Mapping of landmark IDs to reference image names
 * Images are stored locally in /public/landmarks/front/ and /public/landmarks/side/
 *
 * Two image types available per landmark:
 * - male_white_*.webp: Photo reference showing landmark on a face
 * - infographic_*.webp: Diagram/infographic showing landmark placement
 */

export interface LandmarkImageConfig {
  imageName: string;
  fallbackDescription: string;
}

// Front profile landmark images (52 landmarks)
export const FRONT_LANDMARK_IMAGES: Record<string, LandmarkImageConfig> = {
  // Head
  trichion: {
    imageName: 'hairline',
    fallbackDescription: 'Place at the center of your hairline where it meets your forehead',
  },

  // Eyes - Left
  left_pupila: {
    imageName: 'leftEyePupil',
    fallbackDescription: 'Place at the exact center of your left pupil',
  },
  left_canthus_medialis: {
    imageName: 'leftEyeMedialCanthus',
    fallbackDescription: 'Place at the inner corner where your left eyelids meet',
  },
  left_canthus_lateralis: {
    imageName: 'leftEyeLateralCanthus',
    fallbackDescription: 'Place at the outer corner where your left eyelids meet',
  },
  left_palpebra_superior: {
    imageName: 'leftEyeUpperEyelid',
    fallbackDescription: 'Place at the center of your left upper eyelid margin',
  },
  left_palpebra_inferior: {
    imageName: 'leftEyeLowerEyelid',
    fallbackDescription: 'Place at the center of your left lower eyelid margin',
  },
  left_sulcus_palpebralis_lateralis: {
    imageName: 'leftEyelidHoodEnd',
    fallbackDescription: 'Place where your left upper eyelid crease ends laterally',
  },
  left_pretarsal_skin_crease: {
    imageName: 'leftUpperEyelidCrease',
    fallbackDescription: 'Place at the center of your left upper eyelid crease',
  },

  // Eyes - Right
  right_pupila: {
    imageName: 'rightEyePupil',
    fallbackDescription: 'Place at the exact center of your right pupil',
  },
  right_canthus_medialis: {
    imageName: 'rightEyeMedialCanthus',
    fallbackDescription: 'Place at the inner corner where your right eyelids meet',
  },
  right_canthus_lateralis: {
    imageName: 'rightEyeLateralCanthus',
    fallbackDescription: 'Place at the outer corner where your right eyelids meet',
  },
  right_palpebra_superior: {
    imageName: 'rightEyeUpperEyelid',
    fallbackDescription: 'Place at the center of your right upper eyelid margin',
  },
  right_palpebra_inferior: {
    imageName: 'rightEyeLowerEyelid',
    fallbackDescription: 'Place at the center of your right lower eyelid margin',
  },
  right_sulcus_palpebralis_lateralis: {
    imageName: 'rightEyelidHoodEnd',
    fallbackDescription: 'Place where your right upper eyelid crease ends laterally',
  },
  right_pretarsal_skin_crease: {
    imageName: 'rightUpperEyelidCrease',
    fallbackDescription: 'Place at the center of your right upper eyelid crease',
  },

  // Eyebrows - Left
  left_supercilium_medialis: {
    imageName: 'leftBrowHead',
    fallbackDescription: 'Place at the innermost point where your left eyebrow starts',
  },
  left_supercilium_medial_corner: {
    imageName: 'leftBrowInnerCorner',
    fallbackDescription: 'Place at the inner corner of your left eyebrow',
  },
  left_supercilium_superior: {
    imageName: 'leftBrowArch',
    fallbackDescription: 'Place at the highest point of your left eyebrow arch',
  },
  left_supercilium_apex: {
    imageName: 'leftBrowPeak',
    fallbackDescription: 'Place at the peak of your left eyebrow curve',
  },
  left_supercilium_lateralis: {
    imageName: 'leftBrowTail',
    fallbackDescription: 'Place at the outer end of your left eyebrow',
  },

  // Eyebrows - Right
  right_supercilium_medialis: {
    imageName: 'rightBrowHead',
    fallbackDescription: 'Place at the innermost point where your right eyebrow starts',
  },
  right_supercilium_medial_corner: {
    imageName: 'rightBrowInnerCorner',
    fallbackDescription: 'Place at the inner corner of your right eyebrow',
  },
  right_supercilium_superior: {
    imageName: 'rightBrowArch',
    fallbackDescription: 'Place at the highest point of your right eyebrow arch',
  },
  right_supercilium_apex: {
    imageName: 'rightBrowPeak',
    fallbackDescription: 'Place at the peak of your right eyebrow curve',
  },
  right_supercilium_lateralis: {
    imageName: 'rightBrowTail',
    fallbackDescription: 'Place at the outer end of your right eyebrow',
  },

  // Nose
  nasal_base: {
    imageName: 'nasalBase',
    fallbackDescription: 'Place at the bridge of your nose between your eyes',
  },
  left_dorsum_nasi: {
    imageName: 'leftNoseBridge',
    fallbackDescription: 'Place on the left side of your nose bridge',
  },
  right_dorsum_nasi: {
    imageName: 'rightNoseBridge',
    fallbackDescription: 'Place on the right side of your nose bridge',
  },
  left_ala_nasi: {
    imageName: 'noseLeft',
    fallbackDescription: 'Place at the widest point of your left nostril',
  },
  right_ala_nasi: {
    imageName: 'noseRight',
    fallbackDescription: 'Place at the widest point of your right nostril',
  },
  subnasale: {
    imageName: 'noseBottom',
    fallbackDescription: 'Place at the base of your nose where it meets your upper lip',
  },

  // Mouth
  labrale_superius: {
    imageName: 'cupidsBow',
    fallbackDescription: 'Place at the center peak of your upper lip',
  },
  cupids_bow: {
    imageName: 'innerCupidsBow',
    fallbackDescription: 'Place at the inner center of your Cupid\'s bow',
  },
  mouth_middle: {
    imageName: 'mouthMiddle',
    fallbackDescription: 'Place at the center of your mouth opening',
  },
  labrale_inferius: {
    imageName: 'lowerLip',
    fallbackDescription: 'Place at the center of your lower lip border',
  },
  left_cheilion: {
    imageName: 'mouthLeft',
    fallbackDescription: 'Place at the left corner of your mouth',
  },
  right_cheilion: {
    imageName: 'mouthRight',
    fallbackDescription: 'Place at the right corner of your mouth',
  },

  // Jaw
  left_gonion_superior: {
    imageName: 'leftTopGonion',
    fallbackDescription: 'Place at the upper angle of your left jaw',
  },
  right_gonion_superior: {
    imageName: 'rightTopGonion',
    fallbackDescription: 'Place at the upper angle of your right jaw',
  },
  left_gonion_inferior: {
    imageName: 'leftBottomGonion',
    fallbackDescription: 'Place at the lower angle of your left jaw',
  },
  right_gonion_inferior: {
    imageName: 'rightBottomGonion',
    fallbackDescription: 'Place at the lower angle of your right jaw',
  },

  // Chin
  left_mentum_lateralis: {
    imageName: 'chinLeft',
    fallbackDescription: 'Place on the left side of your chin',
  },
  right_mentum_lateralis: {
    imageName: 'chinRight',
    fallbackDescription: 'Place on the right side of your chin',
  },
  menton: {
    imageName: 'chinBottom',
    fallbackDescription: 'Place at the lowest point of your chin',
  },

  // Face Width
  left_zygion: {
    imageName: 'leftCheek',
    fallbackDescription: 'Place at the widest point of your left cheekbone',
  },
  right_zygion: {
    imageName: 'rightCheek',
    fallbackDescription: 'Place at the widest point of your right cheekbone',
  },
  left_temporal: {
    imageName: 'leftTemple',
    fallbackDescription: 'Place at your left temple',
  },
  right_temporal: {
    imageName: 'rightTemple',
    fallbackDescription: 'Place at your right temple',
  },
  left_auricular_lateral: {
    imageName: 'leftOuterEar',
    fallbackDescription: 'Place at the outermost point of your left ear',
  },
  right_auricular_lateral: {
    imageName: 'rightOuterEar',
    fallbackDescription: 'Place at the outermost point of your right ear',
  },

  // Neck
  left_cervical_lateralis: {
    imageName: 'neckLeft',
    fallbackDescription: 'Place on the left side of your neck',
  },
  right_cervical_lateralis: {
    imageName: 'neckRight',
    fallbackDescription: 'Place on the right side of your neck',
  },
};

// Side profile landmark images (31 landmarks)
export const SIDE_LANDMARK_IMAGES: Record<string, LandmarkImageConfig> = {
  // Skull/Head
  vertex: {
    imageName: 'vertex',
    fallbackDescription: 'Place at the highest point of your head',
  },
  external_occipital_region: {
    imageName: 'occiput',
    fallbackDescription: 'Place at the back of your head where it protrudes most',
  },
  trichion_profile: {
    imageName: 'trichion',
    fallbackDescription: 'Place at your hairline in profile view',
  },
  frontalis: {
    imageName: 'forehead',
    fallbackDescription: 'Place at the most prominent point of your forehead',
  },

  // Upper Face
  glabella: {
    imageName: 'glabella',
    fallbackDescription: 'Place between your eyebrows at the brow ridge',
  },
  corneal_apex: {
    imageName: 'cornealApex',
    fallbackDescription: 'Place at the most forward point of your cornea',
  },
  lateral_eyelid: {
    imageName: 'eyelidEnd',
    fallbackDescription: 'Place at the lateral end of your eyelid',
  },
  lower_eyelid_profile: {
    imageName: 'lowerEyelid',
    fallbackDescription: 'Place at the lower eyelid margin',
  },
  zygoma_lateralis: {
    imageName: 'cheekbone',
    fallbackDescription: 'Place at the most prominent point of your cheekbone',
  },

  // Nose
  nasion: {
    imageName: 'nasion',
    fallbackDescription: 'Place at the deepest point of your nasal bridge',
  },
  rhinion: {
    imageName: 'rhinion',
    fallbackDescription: 'Place at the junction of bone and cartilage on your nose bridge',
  },
  supratip: {
    imageName: 'supratip',
    fallbackDescription: 'Place just above your nose tip',
  },
  pronasale: {
    imageName: 'pronasale',
    fallbackDescription: 'Place at the most forward point of your nose tip',
  },
  infratip: {
    imageName: 'infratip',
    fallbackDescription: 'Place just below your nose tip',
  },
  columella: {
    imageName: 'columella',
    fallbackDescription: 'Place at the base of your columella (between nostrils)',
  },
  subnasale_profile: {
    imageName: 'subnasale',
    fallbackDescription: 'Place where your nose meets your upper lip',
  },
  subalare: {
    imageName: 'subalare',
    fallbackDescription: 'Place at the lower edge of your nostril',
  },

  // Lips
  labrale_superius_profile: {
    imageName: 'labraleSuperius',
    fallbackDescription: 'Place at the most forward point of your upper lip',
  },
  labrale_inferius_profile: {
    imageName: 'labraleInferius',
    fallbackDescription: 'Place at the most forward point of your lower lip',
  },
  cheilion_profile: {
    imageName: 'cheilion',
    fallbackDescription: 'Place at the corner of your mouth',
  },
  sublabiale: {
    imageName: 'sublabiale',
    fallbackDescription: 'Place in the groove below your lower lip',
  },

  // Jaw & Chin
  orbitale: {
    imageName: 'orbitale',
    fallbackDescription: 'Place at the lowest point of your eye socket',
  },
  gonion_superior_profile: {
    imageName: 'gonionTop',
    fallbackDescription: 'Place at the upper jaw angle',
  },
  gonion_inferior_profile: {
    imageName: 'gonionBottom',
    fallbackDescription: 'Place at the lower jaw angle',
  },
  pogonion: {
    imageName: 'pogonion',
    fallbackDescription: 'Place at the most forward point of your chin',
  },
  menton_profile: {
    imageName: 'menton',
    fallbackDescription: 'Place at the lowest point of your chin',
  },

  // Ear
  porion: {
    imageName: 'porion',
    fallbackDescription: 'Place at the top of your ear canal opening',
  },
  tragus: {
    imageName: 'tragus',
    fallbackDescription: 'Place at the small flap covering your ear canal',
  },
  intertragic_notch: {
    imageName: 'intertragicNotch',
    fallbackDescription: 'Place at the notch between tragus and antitragus',
  },

  // Neck
  cervical_point: {
    imageName: 'cervicalPoint',
    fallbackDescription: 'Place at the deepest point of your neck curve',
  },
  neckpoint: {
    imageName: 'neckPoint',
    fallbackDescription: 'Place at the neck reference point',
  },
};

/**
 * Get the local image path for a landmark
 * @param landmarkId - The landmark ID
 * @param mode - 'front' or 'side' profile
 * @param type - 'photo' for face reference, 'infographic' for diagram
 * @returns Image path or null if not found
 */
export function getLandmarkImagePath(
  landmarkId: string,
  mode: 'front' | 'side',
  type: 'photo' | 'infographic' = 'photo'
): string | null {
  const mapping = mode === 'front' ? FRONT_LANDMARK_IMAGES : SIDE_LANDMARK_IMAGES;
  const config = mapping[landmarkId];

  if (!config) {
    return null;
  }

  const prefix = type === 'photo' ? 'male_white_' : 'infographic_';
  return `/landmarks/${mode}/${prefix}${config.imageName}.webp`;
}

/**
 * Get fallback description for a landmark
 */
export function getLandmarkPlacementGuide(landmarkId: string, mode: 'front' | 'side'): string {
  const mapping = mode === 'front' ? FRONT_LANDMARK_IMAGES : SIDE_LANDMARK_IMAGES;
  const config = mapping[landmarkId];
  return config?.fallbackDescription || 'Place this landmark at the indicated position';
}
