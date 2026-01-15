/**
 * Facial Landmark Types and Default Data
 * Based on TECHNICAL_SPECS.md medical terminology
 */

export interface LandmarkPoint {
  id: string;
  label: string;
  medicalTerm: string;
  description: string;
  x: number;
  y: number;
  category: string;
}

export interface LandmarkCategory {
  name: string;
  color: string;
  landmarks: string[];
}

// ============================================
// FRONT PROFILE LANDMARKS (52 Points)
// ============================================

export const FRONT_LANDMARK_CATEGORIES: LandmarkCategory[] = [
  {
    name: 'Head',
    color: '#FF6B6B',
    landmarks: ['trichion'],
  },
  {
    name: 'Eyes - Left',
    color: '#4ECDC4',
    landmarks: [
      'left_pupila',
      'left_canthus_medialis',
      'left_canthus_lateralis',
      'left_palpebra_superior',
      'left_palpebra_inferior',
      'left_sulcus_palpebralis_lateralis',
      'left_pretarsal_skin_crease',
    ],
  },
  {
    name: 'Eyes - Right',
    color: '#45B7D1',
    landmarks: [
      'right_pupila',
      'right_canthus_medialis',
      'right_canthus_lateralis',
      'right_palpebra_superior',
      'right_palpebra_inferior',
      'right_sulcus_palpebralis_lateralis',
      'right_pretarsal_skin_crease',
    ],
  },
  {
    name: 'Eyebrows - Left',
    color: '#96CEB4',
    landmarks: [
      'left_supercilium_medialis',
      'left_supercilium_medial_corner',
      'left_supercilium_superior',
      'left_supercilium_apex',
      'left_supercilium_lateralis',
    ],
  },
  {
    name: 'Eyebrows - Right',
    color: '#88D8B0',
    landmarks: [
      'right_supercilium_medialis',
      'right_supercilium_medial_corner',
      'right_supercilium_superior',
      'right_supercilium_apex',
      'right_supercilium_lateralis',
    ],
  },
  {
    name: 'Nose',
    color: '#FFEAA7',
    landmarks: [
      'nasal_base',
      'left_dorsum_nasi',
      'right_dorsum_nasi',
      'left_ala_nasi',
      'right_ala_nasi',
      'subnasale',
    ],
  },
  {
    name: 'Mouth',
    color: '#DDA0DD',
    landmarks: [
      'labrale_superius',
      'cupids_bow',
      'mouth_middle',
      'labrale_inferius',
      'left_cheilion',
      'right_cheilion',
    ],
  },
  {
    name: 'Jaw',
    color: '#F39C12',
    landmarks: [
      'left_gonion_superior',
      'right_gonion_superior',
      'left_gonion_inferior',
      'right_gonion_inferior',
    ],
  },
  {
    name: 'Chin',
    color: '#E74C3C',
    landmarks: ['left_mentum_lateralis', 'right_mentum_lateralis', 'menton'],
  },
  {
    name: 'Face Width',
    color: '#9B59B6',
    landmarks: [
      'left_zygion',
      'right_zygion',
      'left_temporal',
      'right_temporal',
      'left_auricular_lateral',
      'right_auricular_lateral',
    ],
  },
  {
    name: 'Neck',
    color: '#1ABC9C',
    landmarks: ['left_cervical_lateralis', 'right_cervical_lateralis'],
  },
];

export const FRONT_PROFILE_LANDMARKS: LandmarkPoint[] = [
  // Head/Hair
  {
    id: 'trichion',
    label: 'Hairline',
    medicalTerm: 'Trichion (frontal view)',
    description: 'Anterior hairline at midline',
    x: 0.5,
    y: 0.08,
    category: 'Head',
  },

  // Eyes - Left
  {
    id: 'left_pupila',
    label: 'Left Pupil',
    medicalTerm: 'Left Pupila',
    description: 'Center of left pupil',
    x: 0.38,
    y: 0.35,
    category: 'Eyes - Left',
  },
  {
    id: 'left_canthus_medialis',
    label: 'Left Medial Canthus',
    medicalTerm: 'Left Canthus Medialis',
    description: 'Inner corner of left eye',
    x: 0.42,
    y: 0.35,
    category: 'Eyes - Left',
  },
  {
    id: 'left_canthus_lateralis',
    label: 'Left Lateral Canthus',
    medicalTerm: 'Left Canthus Lateralis',
    description: 'Outer corner of left eye',
    x: 0.32,
    y: 0.34,
    category: 'Eyes - Left',
  },
  {
    id: 'left_palpebra_superior',
    label: 'Left Upper Eyelid',
    medicalTerm: 'Left Palpebra Superior',
    description: 'Upper eyelid of left eye',
    x: 0.37,
    y: 0.33,
    category: 'Eyes - Left',
  },
  {
    id: 'left_palpebra_inferior',
    label: 'Left Lower Eyelid',
    medicalTerm: 'Left Palpebra Inferior',
    description: 'Lower eyelid of left eye',
    x: 0.37,
    y: 0.37,
    category: 'Eyes - Left',
  },
  {
    id: 'left_sulcus_palpebralis_lateralis',
    label: 'Left Eyelid Hood End',
    medicalTerm: 'Left Sulcus Palpebralis Lateralis',
    description: 'Lateral end of left upper eyelid crease',
    x: 0.31,
    y: 0.33,
    category: 'Eyes - Left',
  },
  {
    id: 'left_pretarsal_skin_crease',
    label: 'Left Upper Eyelid Crease',
    medicalTerm: 'Left Pretarsal Skin Crease',
    description: 'Left upper eyelid crease',
    x: 0.37,
    y: 0.32,
    category: 'Eyes - Left',
  },

  // Eyes - Right
  {
    id: 'right_pupila',
    label: 'Right Pupil',
    medicalTerm: 'Right Pupila',
    description: 'Center of right pupil',
    x: 0.62,
    y: 0.35,
    category: 'Eyes - Right',
  },
  {
    id: 'right_canthus_medialis',
    label: 'Right Medial Canthus',
    medicalTerm: 'Right Canthus Medialis',
    description: 'Inner corner of right eye',
    x: 0.58,
    y: 0.35,
    category: 'Eyes - Right',
  },
  {
    id: 'right_canthus_lateralis',
    label: 'Right Lateral Canthus',
    medicalTerm: 'Right Canthus Lateralis',
    description: 'Outer corner of right eye',
    x: 0.68,
    y: 0.34,
    category: 'Eyes - Right',
  },
  {
    id: 'right_palpebra_superior',
    label: 'Right Upper Eyelid',
    medicalTerm: 'Right Palpebra Superior',
    description: 'Upper eyelid of right eye',
    x: 0.63,
    y: 0.33,
    category: 'Eyes - Right',
  },
  {
    id: 'right_palpebra_inferior',
    label: 'Right Lower Eyelid',
    medicalTerm: 'Right Palpebra Inferior',
    description: 'Lower eyelid of right eye',
    x: 0.63,
    y: 0.37,
    category: 'Eyes - Right',
  },
  {
    id: 'right_sulcus_palpebralis_lateralis',
    label: 'Right Eyelid Hood End',
    medicalTerm: 'Right Sulcus Palpebralis Lateralis',
    description: 'Lateral end of right upper eyelid crease',
    x: 0.69,
    y: 0.33,
    category: 'Eyes - Right',
  },
  {
    id: 'right_pretarsal_skin_crease',
    label: 'Right Upper Eyelid Crease',
    medicalTerm: 'Right Pretarsal Skin Crease',
    description: 'Right upper eyelid crease',
    x: 0.63,
    y: 0.32,
    category: 'Eyes - Right',
  },

  // Eyebrows - Left
  {
    id: 'left_supercilium_medialis',
    label: 'Left Brow Head',
    medicalTerm: 'Left Supercilium Medialis',
    description: 'Medial start of left eyebrow',
    x: 0.43,
    y: 0.28,
    category: 'Eyebrows - Left',
  },
  {
    id: 'left_supercilium_medial_corner',
    label: 'Left Brow Inner Corner',
    medicalTerm: 'Left Supercilium Medial Corner',
    description: 'Inner corner of left eyebrow',
    x: 0.41,
    y: 0.27,
    category: 'Eyebrows - Left',
  },
  {
    id: 'left_supercilium_superior',
    label: 'Left Brow Arch',
    medicalTerm: 'Left Supercilium Superior',
    description: 'Superior arc of left eyebrow',
    x: 0.36,
    y: 0.26,
    category: 'Eyebrows - Left',
  },
  {
    id: 'left_supercilium_apex',
    label: 'Left Brow Peak',
    medicalTerm: 'Left Supercilium Apex',
    description: 'Highest point of left eyebrow',
    x: 0.34,
    y: 0.26,
    category: 'Eyebrows - Left',
  },
  {
    id: 'left_supercilium_lateralis',
    label: 'Left Brow Tail',
    medicalTerm: 'Left Supercilium Lateralis',
    description: 'Lateral end of left eyebrow',
    x: 0.29,
    y: 0.28,
    category: 'Eyebrows - Left',
  },

  // Eyebrows - Right
  {
    id: 'right_supercilium_medialis',
    label: 'Right Brow Head',
    medicalTerm: 'Right Supercilium Medialis',
    description: 'Medial start of right eyebrow',
    x: 0.57,
    y: 0.28,
    category: 'Eyebrows - Right',
  },
  {
    id: 'right_supercilium_medial_corner',
    label: 'Right Brow Inner Corner',
    medicalTerm: 'Right Supercilium Medial Corner',
    description: 'Inner corner of right eyebrow',
    x: 0.59,
    y: 0.27,
    category: 'Eyebrows - Right',
  },
  {
    id: 'right_supercilium_superior',
    label: 'Right Brow Arch',
    medicalTerm: 'Right Supercilium Superior',
    description: 'Superior arc of right eyebrow',
    x: 0.64,
    y: 0.26,
    category: 'Eyebrows - Right',
  },
  {
    id: 'right_supercilium_apex',
    label: 'Right Brow Peak',
    medicalTerm: 'Right Supercilium Apex',
    description: 'Highest point of right eyebrow',
    x: 0.66,
    y: 0.26,
    category: 'Eyebrows - Right',
  },
  {
    id: 'right_supercilium_lateralis',
    label: 'Right Brow Tail',
    medicalTerm: 'Right Supercilium Lateralis',
    description: 'Lateral end of right eyebrow',
    x: 0.71,
    y: 0.28,
    category: 'Eyebrows - Right',
  },

  // Nose
  {
    id: 'nasal_base',
    label: 'Nasal Base',
    medicalTerm: 'Nasal Base',
    description: 'Base of nasal dorsum',
    x: 0.5,
    y: 0.38,
    category: 'Nose',
  },
  {
    id: 'left_dorsum_nasi',
    label: 'Left Nose Bridge',
    medicalTerm: 'Left Dorsum Nasi',
    description: 'Left side of nasal bridge',
    x: 0.47,
    y: 0.42,
    category: 'Nose',
  },
  {
    id: 'right_dorsum_nasi',
    label: 'Right Nose Bridge',
    medicalTerm: 'Right Dorsum Nasi',
    description: 'Right side of nasal bridge',
    x: 0.53,
    y: 0.42,
    category: 'Nose',
  },
  {
    id: 'left_ala_nasi',
    label: 'Left Nose Side',
    medicalTerm: 'Left Ala Nasi',
    description: 'Lateral aspect of left nasal ala',
    x: 0.44,
    y: 0.5,
    category: 'Nose',
  },
  {
    id: 'right_ala_nasi',
    label: 'Right Nose Side',
    medicalTerm: 'Right Ala Nasi',
    description: 'Lateral aspect of right nasal ala',
    x: 0.56,
    y: 0.5,
    category: 'Nose',
  },
  {
    id: 'subnasale',
    label: 'Nose Bottom',
    medicalTerm: 'Subnasale',
    description: 'Junction of columella and upper lip',
    x: 0.5,
    y: 0.52,
    category: 'Nose',
  },

  // Mouth
  {
    id: 'labrale_superius',
    label: "Cupid's Bow",
    medicalTerm: 'Labrale Superius',
    description: 'Midpoint of upper lip vermilion',
    x: 0.5,
    y: 0.58,
    category: 'Mouth',
  },
  {
    id: 'cupids_bow',
    label: "Inner Cupid's Bow",
    medicalTerm: "Cupid's Bow",
    description: 'Central peak of upper lip',
    x: 0.5,
    y: 0.57,
    category: 'Mouth',
  },
  {
    id: 'mouth_middle',
    label: 'Mouth Middle',
    medicalTerm: 'Mouth Middle',
    description: 'Center of mouth opening',
    x: 0.5,
    y: 0.62,
    category: 'Mouth',
  },
  {
    id: 'labrale_inferius',
    label: 'Lower Lip Center',
    medicalTerm: 'Labrale Inferius',
    description: 'Midpoint of lower lip vermilion border',
    x: 0.5,
    y: 0.66,
    category: 'Mouth',
  },
  {
    id: 'left_cheilion',
    label: 'Left Mouth Corner',
    medicalTerm: 'Left Cheilion',
    description: 'Left oral commissure',
    x: 0.42,
    y: 0.62,
    category: 'Mouth',
  },
  {
    id: 'right_cheilion',
    label: 'Right Mouth Corner',
    medicalTerm: 'Right Cheilion',
    description: 'Right oral commissure',
    x: 0.58,
    y: 0.62,
    category: 'Mouth',
  },

  // Jaw
  {
    id: 'left_gonion_superior',
    label: 'Left Upper Jaw Angle',
    medicalTerm: 'Left Gonion Superior',
    description: 'Superior aspect of left mandibular angle',
    x: 0.22,
    y: 0.55,
    category: 'Jaw',
  },
  {
    id: 'right_gonion_superior',
    label: 'Right Upper Jaw Angle',
    medicalTerm: 'Right Gonion Superior',
    description: 'Superior aspect of right mandibular angle',
    x: 0.78,
    y: 0.55,
    category: 'Jaw',
  },
  {
    id: 'left_gonion_inferior',
    label: 'Left Lower Jaw Angle',
    medicalTerm: 'Left Gonion Inferior',
    description: 'Inferior aspect of left mandibular angle',
    x: 0.24,
    y: 0.7,
    category: 'Jaw',
  },
  {
    id: 'right_gonion_inferior',
    label: 'Right Lower Jaw Angle',
    medicalTerm: 'Right Gonion Inferior',
    description: 'Inferior aspect of right mandibular angle',
    x: 0.76,
    y: 0.7,
    category: 'Jaw',
  },

  // Chin
  {
    id: 'left_mentum_lateralis',
    label: 'Left Chin',
    medicalTerm: 'Left Mentum Lateralis',
    description: 'Left lateral chin',
    x: 0.42,
    y: 0.8,
    category: 'Chin',
  },
  {
    id: 'right_mentum_lateralis',
    label: 'Right Chin',
    medicalTerm: 'Right Mentum Lateralis',
    description: 'Right lateral chin',
    x: 0.58,
    y: 0.8,
    category: 'Chin',
  },
  {
    id: 'menton',
    label: 'Chin Bottom',
    medicalTerm: 'Menton',
    description: 'Lowest point of chin in midline',
    x: 0.5,
    y: 0.88,
    category: 'Chin',
  },

  // Face Width
  {
    id: 'left_zygion',
    label: 'Left Cheekbone',
    medicalTerm: 'Left Zygion',
    description: 'Most lateral point of left zygomatic arch',
    x: 0.18,
    y: 0.42,
    category: 'Face Width',
  },
  {
    id: 'right_zygion',
    label: 'Right Cheekbone',
    medicalTerm: 'Right Zygion',
    description: 'Most lateral point of right zygomatic arch',
    x: 0.82,
    y: 0.42,
    category: 'Face Width',
  },
  {
    id: 'left_temporal',
    label: 'Left Temple',
    medicalTerm: 'Left Temporal Point',
    description: 'Left temporal region',
    x: 0.2,
    y: 0.3,
    category: 'Face Width',
  },
  {
    id: 'right_temporal',
    label: 'Right Temple',
    medicalTerm: 'Right Temporal Point',
    description: 'Right temporal region',
    x: 0.8,
    y: 0.3,
    category: 'Face Width',
  },
  {
    id: 'left_auricular_lateral',
    label: 'Left Outer Ear',
    medicalTerm: 'Left Auricular Lateral Point',
    description: 'Lateral-most point of left ear',
    x: 0.12,
    y: 0.4,
    category: 'Face Width',
  },
  {
    id: 'right_auricular_lateral',
    label: 'Right Outer Ear',
    medicalTerm: 'Right Auricular Lateral Point',
    description: 'Lateral-most point of right ear',
    x: 0.88,
    y: 0.4,
    category: 'Face Width',
  },

  // Neck
  {
    id: 'left_cervical_lateralis',
    label: 'Left Neck Point',
    medicalTerm: 'Left Cervical Lateralis',
    description: 'Left cervical point',
    x: 0.35,
    y: 0.95,
    category: 'Neck',
  },
  {
    id: 'right_cervical_lateralis',
    label: 'Right Neck Point',
    medicalTerm: 'Right Cervical Lateralis',
    description: 'Right cervical point',
    x: 0.65,
    y: 0.95,
    category: 'Neck',
  },
];

// ============================================
// SIDE PROFILE LANDMARKS (28 Points)
// Matches FaceIQ Labs exact naming and order
// ============================================

export const SIDE_LANDMARK_CATEGORIES: LandmarkCategory[] = [
  {
    name: 'Cranium',
    color: '#FF6B6B',
    landmarks: ['vertex', 'occiput', 'trichion'],
  },
  {
    name: 'Forehead',
    color: '#4ECDC4',
    landmarks: ['glabella'],
  },
  {
    name: 'Eye Region',
    color: '#45B7D1',
    landmarks: ['cornealApex', 'orbitale'],
  },
  {
    name: 'Nose',
    color: '#FFEAA7',
    landmarks: [
      'nasion',
      'rhinion',
      'supratip',
      'pronasale',
      'infratip',
      'columella',
      'subnasale',
      'subalare',
    ],
  },
  {
    name: 'Lips',
    color: '#DDA0DD',
    landmarks: ['labraleSuperius', 'cheilion', 'labraleInferius', 'sublabiale'],
  },
  {
    name: 'Chin',
    color: '#E74C3C',
    landmarks: ['pogonion', 'menton'],
  },
  {
    name: 'Jaw',
    color: '#F39C12',
    landmarks: ['gonionTop', 'gonionBottom'],
  },
  {
    name: 'Cheek',
    color: '#9B59B6',
    landmarks: ['cheekbone'],
  },
  {
    name: 'Ear',
    color: '#3498DB',
    landmarks: ['porion', 'tragus', 'intertragicNotch'],
  },
  {
    name: 'Neck',
    color: '#1ABC9C',
    landmarks: ['cervicalPoint', 'neckPoint'],
  },
];

// FaceIQ order: vertex, occiput, pronasale, neckPoint, porion, orbitale, tragus,
// intertragicNotch, cornealApex, cheekbone, trichion, glabella, nasion, rhinion,
// supratip, infratip, columella, subnasale, subalare, labraleSuperius, cheilion,
// labraleInferius, sublabiale, pogonion, menton, cervicalPoint, gonionTop, gonionBottom
export const SIDE_PROFILE_LANDMARKS: LandmarkPoint[] = [
  // 1. vertex
  {
    id: 'vertex',
    label: 'Top of Head',
    medicalTerm: 'Vertex',
    description: 'Highest point on the head in profile',
    x: 0.45,
    y: 0.02,
    category: 'Cranium',
  },
  // 2. occiput
  {
    id: 'occiput',
    label: 'Occiput',
    medicalTerm: 'External Occipital Region',
    description: 'Back-of-head prominence',
    x: 0.85,
    y: 0.15,
    category: 'Cranium',
  },
  // 3. pronasale
  {
    id: 'pronasale',
    label: 'Nose Tip',
    medicalTerm: 'Pronasale',
    description: 'Most forward point of the nose tip',
    x: 0.18,
    y: 0.48,
    category: 'Nose',
  },
  // 4. neckPoint
  {
    id: 'neckPoint',
    label: 'Neck Point',
    medicalTerm: 'Anterior Cervical Landmark',
    description: 'Lower neck inflection on the front border',
    x: 0.4,
    y: 0.88,
    category: 'Neck',
  },
  // 5. porion
  {
    id: 'porion',
    label: 'Porion',
    medicalTerm: 'Porion (soft tissue)',
    description: 'Upper margin of ear canal opening, used for Frankfort horizontal plane',
    x: 0.75,
    y: 0.35,
    category: 'Ear',
  },
  // 6. orbitale
  {
    id: 'orbitale',
    label: 'Orbitale',
    medicalTerm: 'Orbitale',
    description: 'Lowest point on the orbital rim',
    x: 0.35,
    y: 0.38,
    category: 'Eye Region',
  },
  // 7. tragus
  {
    id: 'tragus',
    label: 'Tragus',
    medicalTerm: 'Tragion (soft tissue)',
    description: 'Cartilage nub in front of the ear canal',
    x: 0.72,
    y: 0.42,
    category: 'Ear',
  },
  // 8. intertragicNotch
  {
    id: 'intertragicNotch',
    label: 'Intertragic Notch',
    medicalTerm: 'Incisura Intertragica',
    description: 'Notch between tragus and antitragus cartilages',
    x: 0.73,
    y: 0.45,
    category: 'Ear',
  },
  // 9. cornealApex
  {
    id: 'cornealApex',
    label: 'Corneal Apex',
    medicalTerm: 'Corneal Apex',
    description: 'Most forward point of the eye (cornea)',
    x: 0.28,
    y: 0.34,
    category: 'Eye Region',
  },
  // 10. cheekbone
  {
    id: 'cheekbone',
    label: 'Cheekbone',
    medicalTerm: 'Zygion (soft-tissue over zygoma)',
    description: 'Zygomatic prominence',
    x: 0.45,
    y: 0.42,
    category: 'Cheek',
  },
  // 11. trichion
  {
    id: 'trichion',
    label: 'Hairline (Profile)',
    medicalTerm: 'Trichion',
    description: 'Forehead hairline point',
    x: 0.35,
    y: 0.1,
    category: 'Cranium',
  },
  // 12. glabella
  {
    id: 'glabella',
    label: 'Glabella',
    medicalTerm: 'Glabella',
    description: 'Mid-forehead point between brows',
    x: 0.32,
    y: 0.28,
    category: 'Forehead',
  },
  // 13. nasion
  {
    id: 'nasion',
    label: 'Nasal Bridge Root',
    medicalTerm: 'Nasion',
    description: 'Nasal root depression',
    x: 0.35,
    y: 0.32,
    category: 'Nose',
  },
  // 14. rhinion
  {
    id: 'rhinion',
    label: 'Rhinion',
    medicalTerm: 'Rhinion',
    description: 'Dorsal point of the nose',
    x: 0.28,
    y: 0.4,
    category: 'Nose',
  },
  // 15. supratip
  {
    id: 'supratip',
    label: 'Supratip',
    medicalTerm: 'Supratip Break',
    description: 'Dorsal point just above the tip',
    x: 0.22,
    y: 0.46,
    category: 'Nose',
  },
  // 16. infratip
  {
    id: 'infratip',
    label: 'Infratip',
    medicalTerm: 'Infratip Lobule',
    description: 'Point between nose tip and columella',
    x: 0.2,
    y: 0.5,
    category: 'Nose',
  },
  // 17. columella
  {
    id: 'columella',
    label: 'Columella',
    medicalTerm: 'Columella Nasi',
    description: 'Inferior border of the nasal septum between nostrils',
    x: 0.24,
    y: 0.52,
    category: 'Nose',
  },
  // 18. subnasale
  {
    id: 'subnasale',
    label: 'Subnasale',
    medicalTerm: 'Subnasale',
    description: 'Where nose base meets upper lip',
    x: 0.3,
    y: 0.54,
    category: 'Nose',
  },
  // 19. subalare
  {
    id: 'subalare',
    label: 'Subalare',
    medicalTerm: 'Subalare',
    description: 'Lowest point of the nostril wing on the visible side',
    x: 0.28,
    y: 0.53,
    category: 'Nose',
  },
  // 20. labraleSuperius
  {
    id: 'labraleSuperius',
    label: 'Upper Lip',
    medicalTerm: 'Labrale Superius',
    description: 'Most forward point of the upper lip vermilion',
    x: 0.28,
    y: 0.58,
    category: 'Lips',
  },
  // 21. cheilion
  {
    id: 'cheilion',
    label: 'Mouth Corner',
    medicalTerm: 'Cheilion',
    description: 'Mouth corner where the lips meet',
    x: 0.35,
    y: 0.62,
    category: 'Lips',
  },
  // 22. labraleInferius
  {
    id: 'labraleInferius',
    label: 'Lower Lip',
    medicalTerm: 'Labrale Inferius',
    description: 'Most forward point of the lower lip vermilion',
    x: 0.3,
    y: 0.66,
    category: 'Lips',
  },
  // 23. sublabiale
  {
    id: 'sublabiale',
    label: 'Labiomental Fold',
    medicalTerm: 'Sublabiale',
    description: 'Deepest point of the crease between lower lip and chin',
    x: 0.32,
    y: 0.7,
    category: 'Lips',
  },
  // 24. pogonion
  {
    id: 'pogonion',
    label: 'Chin Point',
    medicalTerm: 'Pogonion (soft tissue)',
    description: 'Most forward point on the soft-tissue chin',
    x: 0.3,
    y: 0.76,
    category: 'Chin',
  },
  // 25. menton
  {
    id: 'menton',
    label: 'Chin Bottom',
    medicalTerm: 'Menton (soft tissue)',
    description: 'Lowest point on the soft-tissue chin',
    x: 0.35,
    y: 0.82,
    category: 'Chin',
  },
  // 26. cervicalPoint
  {
    id: 'cervicalPoint',
    label: 'Cervical Point',
    medicalTerm: 'Cervicale (soft-tissue reference)',
    description: 'High neck point just under the jaw',
    x: 0.5,
    y: 0.9,
    category: 'Neck',
  },
  // 27. gonionTop
  {
    id: 'gonionTop',
    label: 'Upper Jaw Angle',
    medicalTerm: 'Gonion Superior',
    description: 'Upper angle point of the jaw from side profile',
    x: 0.7,
    y: 0.6,
    category: 'Jaw',
  },
  // 28. gonionBottom
  {
    id: 'gonionBottom',
    label: 'Lower Jaw Angle',
    medicalTerm: 'Gonion Inferior',
    description: 'Lower angle point of the jaw from side profile',
    x: 0.65,
    y: 0.72,
    category: 'Jaw',
  },
];

// ============================================
// MediaPipe Face Mesh Index Mapping
// ============================================
// NOTE: MEDIAPIPE_FRONT_MAPPING is defined in mediapipeDetection.ts (single source of truth)
// Import from there if needed: import { MEDIAPIPE_FRONT_MAPPING } from './mediapipeDetection';

// Helper to get category color for a landmark
export function getLandmarkColor(
  landmarkId: string,
  categories: LandmarkCategory[]
): string {
  for (const category of categories) {
    if (category.landmarks.includes(landmarkId)) {
      return category.color;
    }
  }
  return '#00f3ff'; // Default cyan
}

// ============================================
// FaceIQ Side Profile Landmark Indices (106 points)
// Reverse-engineered from FaceIQ Labs API
// ============================================

export const FACEIQ_SIDE_LANDMARKS = {
  // Face Contour (0-16) - Jaw/Chin outline
  MENTON: 0, // Chin bottom (lowest point)
  POGONION: 2, // Chin prominence
  GNATHION: 3, // Chin point
  MANDIBLE_CONTOUR: [2, 3, 4, 5, 6, 7, 8], // Jaw line

  // Posterior Points (1, 9-16) - Ear/Back of head
  TRAGION: 1, // Ear point
  EAR_CONTOUR: [9, 10, 11, 12, 13, 14, 15, 16],

  // Forehead/Hairline (17)
  TRICHION: 17, // Hairline

  // Nose Profile (18-32)
  NASION: 25, // Bridge of nose (deepest point)
  PRONASALE: 32, // Nose tip
  SUBNASALE: 52, // Base of nose
  COLUMELLA: 53, // Nose columella
  NOSE_BRIDGE: [25, 26, 27, 28, 29, 30, 31, 32],
  NOSE_TIP_CONTOUR: [52, 53, 54, 55, 56, 57, 58, 59, 60],

  // Eye Region (33-51)
  EYE_LATERAL_CANTHUS: 33, // Outer eye corner
  EYE_MEDIAL_CANTHUS: 35, // Inner eye corner
  UPPER_EYELID: [37, 38, 39],
  LOWER_EYELID: [40, 41, 42],
  PUPIL: 34,
  BROW_HEAD: 44, // Inner brow
  BROW_ARCH: 45, // Brow peak
  BROW_TAIL: 46, // Outer brow

  // Lip Region (52-75)
  LABRALE_SUPERIUS: 63, // Upper lip top
  LABRALE_INFERIUS: 66, // Lower lip bottom
  STOMION: 65, // Lip meeting point
  UPPER_LIP_CONTOUR: [63, 64, 65],
  LOWER_LIP_CONTOUR: [66, 67, 68],

  // Additional Profile Points (76-105)
  GLABELLA: 76, // Between eyebrows
  SELLION: 77, // Deepest point of nasal bridge
  SOFT_TISSUE_NASION: 78,
  ORBITALE: 79, // Lowest point of eye socket
  GONION: 85, // Jaw angle
  CONDYLION: 86, // Top of jaw joint
};

// ============================================
// FaceIQ Front Face Landmark Indices (MediaPipe 478 points)
// ============================================

export const FACEIQ_FRONT_LANDMARKS = {
  // Key points from MediaPipe Face Mesh
  NOSE_TIP: 1,
  LEFT_EYE_INNER: 133,
  LEFT_EYE_OUTER: 33,
  RIGHT_EYE_INNER: 362,
  RIGHT_EYE_OUTER: 263,
  LEFT_CHEEK: 234,
  RIGHT_CHEEK: 454,
  UPPER_LIP: 13,
  LOWER_LIP: 14,
  CHIN: 152,
  FOREHEAD: 10,
  LEFT_EAR: 234,
  RIGHT_EAR: 454,
  LEFT_BROW_INNER: 107,
  LEFT_BROW_OUTER: 70,
  RIGHT_BROW_INNER: 336,
  RIGHT_BROW_OUTER: 300,
  NOSE_BRIDGE: 6,
  LEFT_NOSTRIL: 129,
  RIGHT_NOSTRIL: 358,
};

// ============================================
// Scoring Configuration Types
// ============================================

export interface ScoringConfig {
  idealValue: number;
  standardDeviation: number;
  minScore: number;
  maxScore: number;
  weight: number;
}

export interface GenderSpecificValues {
  male: { ideal: number; range: [number, number] };
  female: { ideal: number; range: [number, number] };
}

// ============================================
// FaceIQ Ideal Values (Gender-Specific)
// ============================================

export const FACEIQ_IDEAL_VALUES: Record<string, GenderSpecificValues> = {
  fwhr: {
    male: { ideal: 1.9, range: [1.8, 2.1] },
    female: { ideal: 1.75, range: [1.6, 1.9] },
  },
  canthalTilt: {
    male: { ideal: 4, range: [2, 7] },
    female: { ideal: 6, range: [4, 10] },
  },
  nasolabialAngle: {
    male: { ideal: 95, range: [90, 100] },
    female: { ideal: 105, range: [100, 115] },
  },
  gonialAngle: {
    male: { ideal: 125, range: [120, 130] },
    female: { ideal: 128, range: [125, 135] },
  },
  nasalIndex: {
    male: { ideal: 0.7, range: [0.65, 0.75] },
    female: { ideal: 0.65, range: [0.6, 0.7] },
  },
  lipRatio: {
    male: { ideal: 0.5, range: [0.4, 0.6] },
    female: { ideal: 0.5, range: [0.45, 0.55] },
  },
  facialConvexity: {
    male: { ideal: 170, range: [165, 175] },
    female: { ideal: 168, range: [163, 173] },
  },
  chinProjection: {
    male: { ideal: 0, range: [-3, 3] },
    female: { ideal: -2, range: [-5, 1] },
  },
};

// ============================================
// FaceIQ Scoring Configurations
// ============================================

export const FACEIQ_SCORING_CONFIGS: Record<string, ScoringConfig> = {
  fwhr: {
    idealValue: 1.9,
    standardDeviation: 0.15,
    minScore: 0,
    maxScore: 100,
    weight: 0.15,
  },
  canthalTilt: {
    idealValue: 6,
    standardDeviation: 3,
    minScore: 0,
    maxScore: 100,
    weight: 0.1,
  },
  facialThirds: {
    idealValue: 33.33,
    standardDeviation: 3,
    minScore: 0,
    maxScore: 100,
    weight: 0.1,
  },
  nasolabialAngle: {
    idealValue: 102,
    standardDeviation: 8,
    minScore: 0,
    maxScore: 100,
    weight: 0.08,
  },
  gonialAngle: {
    idealValue: 125,
    standardDeviation: 5,
    minScore: 0,
    maxScore: 100,
    weight: 0.08,
  },
  overallSymmetry: {
    idealValue: 100,
    standardDeviation: 5,
    minScore: 0,
    maxScore: 100,
    weight: 0.15,
  },
  goldenRatio: {
    idealValue: 1.618,
    standardDeviation: 0.1,
    minScore: 0,
    maxScore: 100,
    weight: 0.12,
  },
  nasalIndex: {
    idealValue: 0.7,
    standardDeviation: 0.08,
    minScore: 0,
    maxScore: 100,
    weight: 0.06,
  },
  lipRatio: {
    idealValue: 0.5,
    standardDeviation: 0.1,
    minScore: 0,
    maxScore: 100,
    weight: 0.06,
  },
  chinProjection: {
    idealValue: 0,
    standardDeviation: 3,
    minScore: 0,
    maxScore: 100,
    weight: 0.05,
  },
  noseProjection: {
    idealValue: 0.67,
    standardDeviation: 0.05,
    minScore: 0,
    maxScore: 100,
    weight: 0.05,
  },
};

// ============================================
// Population Statistics for Percentile Ranking
// ============================================

export interface PopulationStats {
  mean: number;
  standardDeviation: number;
  sampleSize: number;
}

export const POPULATION_STATS: Record<string, PopulationStats> = {
  harmonyScore: { mean: 65, standardDeviation: 12, sampleSize: 10000 },
  fwhr: { mean: 1.85, standardDeviation: 0.2, sampleSize: 10000 },
  canthalTilt: { mean: 4, standardDeviation: 4, sampleSize: 10000 },
  symmetry: { mean: 85, standardDeviation: 8, sampleSize: 10000 },
  goldenRatioMatch: { mean: 70, standardDeviation: 15, sampleSize: 10000 },
};
