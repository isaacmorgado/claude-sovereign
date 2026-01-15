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

// Side profile landmark images (28 landmarks)
// Matches FaceIQ Labs exact naming - IDs must match SIDE_PROFILE_LANDMARKS in landmarks.ts
export const SIDE_LANDMARK_IMAGES: Record<string, LandmarkImageConfig> = {
  // 1. vertex
  vertex: {
    imageName: 'vertex',
    fallbackDescription: 'Mark the highest point of the head\'s curve',
  },
  // 2. occiput
  occiput: {
    imageName: 'occiput',
    fallbackDescription: 'Mark the most prominent point on the back of the head\'s curve',
  },
  // 3. pronasale
  pronasale: {
    imageName: 'pronasale',
    fallbackDescription: 'Mark the farthest projecting point of the nose tip',
  },
  // 4. neckPoint
  neckPoint: {
    imageName: 'neckPoint',
    fallbackDescription: 'Follow the neck contour down to the Adam\'s apple area',
  },
  // 5. porion
  porion: {
    imageName: 'porion',
    fallbackDescription: 'Mark the uppermost point of the ear canal opening, above the tragus',
  },
  // 6. orbitale
  orbitale: {
    imageName: 'orbitale',
    fallbackDescription: 'Trace the undereye contour and mark the most prominent part of the orbital rim',
  },
  // 7. tragus
  tragus: {
    imageName: 'tragus',
    fallbackDescription: 'Mark the back part of the small flap in front of the ear canal',
  },
  // 8. intertragicNotch
  intertragicNotch: {
    imageName: 'intertragicNotch',
    fallbackDescription: 'Locate the small groove between the tragus and antitragus',
  },
  // 9. cornealApex
  cornealApex: {
    imageName: 'cornealApex',
    fallbackDescription: 'Mark the most prominent and forward point of the eye',
  },
  // 10. cheekbone
  cheekbone: {
    imageName: 'cheekbone',
    fallbackDescription: 'From the side, mark the bump of the cheekbone below/behind the eye',
  },
  // 11. trichion
  trichion: {
    imageName: 'trichion',
    fallbackDescription: 'Mark the highest point of the hairline, where the forehead ends',
  },
  // 12. glabella
  glabella: {
    imageName: 'glabella',
    fallbackDescription: 'Locate the most prominent point of the brow ridge between the eyebrows',
  },
  // 13. nasion
  nasion: {
    imageName: 'nasion',
    fallbackDescription: 'Mark the small dip between the brow ridge and nose bridge, around eye level',
  },
  // 14. rhinion
  rhinion: {
    imageName: 'rhinion',
    fallbackDescription: 'Mark the dorsal point of the nose, the most prominent point of the nose bridge',
  },
  // 15. supratip
  supratip: {
    imageName: 'supratip',
    fallbackDescription: 'Follow the bridge toward the tip and mark the highest point right before the nose tip',
  },
  // 16. infratip
  infratip: {
    imageName: 'infratip',
    fallbackDescription: 'Follow the nose contour down from the tip and mark the lowest point before the nostrils',
  },
  // 17. columella
  columella: {
    imageName: 'columella',
    fallbackDescription: 'Mark the part of the nose that connects the nostrils, to the left of the infratip',
  },
  // 18. subnasale
  subnasale: {
    imageName: 'subnasale',
    fallbackDescription: 'Mark the crease point at the base of the nose, where the nose creates an angle with the upper lip',
  },
  // 19. subalare
  subalare: {
    imageName: 'subalare',
    fallbackDescription: 'Mark the most prominent edge of the nose wing, near the cheek closest to the eyes',
  },
  // 20. labraleSuperius
  labraleSuperius: {
    imageName: 'labraleSuperius',
    fallbackDescription: 'Find the most prominent point of the upper lip, typically the highest point of the lip\'s natural curve',
  },
  // 21. cheilion
  cheilion: {
    imageName: 'cheilion',
    fallbackDescription: 'Mark the rearmost lip corner where the upper and lower lips touch in profile',
  },
  // 22. labraleInferius
  labraleInferius: {
    imageName: 'labraleInferius',
    fallbackDescription: 'Find the most prominent point of the lower lip, typically the lowest point of the lip\'s natural curve',
  },
  // 23. sublabiale
  sublabiale: {
    imageName: 'sublabiale',
    fallbackDescription: 'From profile, mark the deepest spot between the lower lip and chin',
  },
  // 24. pogonion
  pogonion: {
    imageName: 'pogonion',
    fallbackDescription: 'Mark the most prominent and forward point of the chin',
  },
  // 25. menton
  menton: {
    imageName: 'menton',
    fallbackDescription: 'Trace the chin contour downward and mark its lowest point',
  },
  // 26. cervicalPoint
  cervicalPoint: {
    imageName: 'cervicalPoint',
    fallbackDescription: 'Mark the most indented point where the underside of the jaw turns into the neck',
  },
  // 27. gonionTop
  gonionTop: {
    imageName: 'gonionTop',
    fallbackDescription: 'Locate the upper part of the jaw angle where the ramus forms an angle with the mandible',
  },
  // 28. gonionBottom
  gonionBottom: {
    imageName: 'gonionBottom',
    fallbackDescription: 'Locate the lower part of the jaw angle, where the jaw begins to curve towards the chin',
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
