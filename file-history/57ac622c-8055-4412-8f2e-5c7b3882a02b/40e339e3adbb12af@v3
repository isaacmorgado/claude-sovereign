# FaceIQ Technical Specifications

## Overview

This document contains the complete technical specifications for facial landmark detection and analysis, including the standardized medical terminology for all facial landmarks and the mathematical formulas used for scoring.

---

## Landmark Data Dictionary

### Front Profile Landmarks (52 Points)

| UI Label | Medical Term | Key ID | Description |
|----------|--------------|--------|-------------|
| Hairline | Trichion (frontal view) | `trichion` | Anterior hairline at midline |
| Left Pupil | Left Pupila | `left_pupila` | Center of left pupil |
| Right Pupil | Right Pupila | `right_pupila` | Center of right pupil |
| Left Nose Side | Left Ala Nasi | `left_ala_nasi` | Lateral aspect of left nasal ala |
| Right Nose Side | Right Ala Nasi | `right_ala_nasi` | Lateral aspect of right nasal ala |
| Lower Lip Center | Labrale Inferius | `labrale_inferius` | Midpoint of lower lip vermilion border |
| Chin Bottom | Menton | `menton` | Lowest point of chin in midline |
| Left Outer Ear | Left Auricular Lateral Point | `left_auricular_lateral` | Lateral-most point of left ear |
| Right Outer Ear | Right Auricular Lateral Point | `right_auricular_lateral` | Lateral-most point of right ear |
| Left Temple | Left Temporal Point | `left_temporal` | Left temporal region |
| Right Temple | Right Temporal Point | `right_temporal` | Right temporal region |
| Left Medial Canthus | Left Canthus Medialis | `left_canthus_medialis` | Inner corner of left eye |
| Right Lateral Canthus | Left Canthus Lateralis | `left_canthus_lateralis` | Outer corner of left eye |
| Left Upper Eye Lid | Left Palpebra Superior | `left_palpebra_superior` | Upper eyelid of left eye |
| Left Lower Eyelid | Left Palpebra Inferior | `left_palpebra_inferior` | Lower eyelid of left eye |
| Left Eyelid Hood End | Left Sulcus Palpebralis Lateralis | `left_sulcus_palpebralis_lateralis` | Lateral end of left upper eyelid crease |
| Left Brow Head | Left Supercilium Medialis | `left_supercilium_medialis` | Medial start of left eyebrow |
| Left Brow Inner Corner | Left Supercilium Medial Corner | `left_supercilium_medial_corner` | Inner corner of left eyebrow |
| Left Brow Arch | Left Supercilium Superior | `left_supercilium_superior` | Superior arc of left eyebrow |
| Left Brow Peak | Left Supercilium Apex | `left_supercilium_apex` | Highest point of left eyebrow |
| Left Brow Tail | Left Supercilium Lateralis | `left_supercilium_lateralis` | Lateral end of left eyebrow |
| Left Upper Eyelid Crease | Left Pretarsal Skin Crease | `left_pretarsal_skin_crease` | Left upper eyelid crease |
| Right Medial Canthus | Right Canthus Medialis | `right_canthus_medialis` | Inner corner of right eye |
| Right Lateral Canthus | Right Canthus Lateralis | `right_canthus_lateralis` | Outer corner of right eye |
| Right Upper Eyelid | Right Palpebra Superior | `right_palpebra_superior` | Upper eyelid of right eye |
| Right Lower Eyelid | Right Palpebra Inferior | `right_palpebra_inferior` | Lower eyelid of right eye |
| Right Eyelid Hood End | Right Sulcus Palpebralis Lateralis | `right_sulcus_palpebralis_lateralis` | Lateral end of right upper eyelid crease |
| Right Brow End | Right Supercilium Medialis | `right_supercilium_medialis` | Medial start of right eyebrow |
| Right Brow Inner Corner | Right Supercilium Medial Corner | `right_supercilium_medial_corner` | Inner corner of right eyebrow |
| Right Brow Arch | Right Supercilium Superior | `right_supercilium_superior` | Superior arc of right eyebrow |
| Right Brow Peak | Right Supercilium Apex | `right_supercilium_apex` | Highest point of right eyebrow |
| Right Brow Tail | Right Supercilium Lateralis | `right_supercilium_lateralis` | Lateral end of right eyebrow |
| Right Upper Eyelid Crease | Right Pretarsal Skin Crease | `right_pretarsal_skin_crease` | Right upper eyelid crease |
| Nasal Base | Nasal Base | `nasal_base` | Base of nasal dorsum |
| Nose Bottom | Subnasale | `subnasale` | Junction of columella and upper lip |
| Left Nose Bridge | Left Dorsum Nasi | `left_dorsum_nasi` | Left side of nasal bridge |
| Right Nose Bridge | Right Dorsum Nasi | `right_dorsum_nasi` | Right side of nasal bridge |
| Left Mouth Corner | Left Cheilion | `left_cheilion` | Left oral commissure |
| Right Mouth Corner | Right Cheilion | `right_cheilion` | Right oral commissure |
| Cupid's Bow | Labrale Superius | `labrale_superius` | Midpoint of upper lip vermilion |
| Inner Cupid's Bow | Cupid's Bow | `cupids_bow` | Central peak of upper lip |
| Mouth Middle | Mouth Middle | `mouth_middle` | Center of mouth opening |
| Left Upper Jaw Angle | Left Gonion Superior | `left_gonion_superior` | Superior aspect of left mandibular angle |
| Right Upper Jaw Angle | Right Gonion Superior | `right_gonion_superior` | Superior aspect of right mandibular angle |
| Left Lower Jaw Angle | Left Gonion Inferior | `left_gonion_inferior` | Inferior aspect of left mandibular angle |
| Right Lower Jaw Angle | Right Gonion Inferior | `right_gonion_inferior` | Inferior aspect of right mandibular angle |
| Left Chin | Left Mentum Lateralis | `left_mentum_lateralis` | Left lateral chin |
| Right Chin | Right Mentum Lateralis | `right_mentum_lateralis` | Right lateral chin |
| Left Neck Point | Left Cervical Lateralis | `left_cervical_lateralis` | Left cervical point |
| Right Neck Point | Right Cervical Lateralis | `right_cervical_lateralis` | Right cervical point |
| Left Cheekbone | Left Zygion | `left_zygion` | Most lateral point of left zygomatic arch |
| Right Cheekbone | Right Zygion | `right_zygion` | Most lateral point of right zygomatic arch |

---

### Side Profile Landmarks (38 Points)

| UI Label | Medical Term | Key ID | Description |
|----------|--------------|--------|-------------|
| Top of Head | Vertex | `vertex` | Highest point of cranium |
| Occiput | External Occipital Region | `external_occipital_region` | Back of skull |
| Nose Tip | Pronasale | `pronasale` | Most anterior point of nasal tip |
| Neck Point | Anterior Cervical Landmark | `anterior_cervical_landmark` | Anterior neck landmark |
| Porion | Porion (soft tissue) | `porion` | Superior aspect of external auditory meatus |
| Orbitale | Orbitale | `orbitale` | Lowest point of infraorbital margin |
| Tragus | Tragion (soft tissue) | `tragion` | Superior margin of tragus |
| Intertragic Notch | Incisura Intertragica | `incisura_intertragica` | Notch between tragus and antitragus |
| Corneal Apex | Corneal Apex | `corneal_apex` | Most anterior point of cornea |
| Cheekbone | Zygion (soft tissue over zygoma) | `zygion_soft_tissue` | Soft tissue over zygomatic arch |
| Eyelid End | Lateral Eyelid | `lateral_eyelid` | Lateral extent of palpebral fissure |
| Lower Eyelid | Left Palpebra Inferior | `palpebra_inferior_side` | Lower eyelid margin (profile view) |
| Hairline (profile) | Trichion | `trichion_profile` | Anterior hairline (profile view) |
| Glabella | Glabella | `glabella` | Most prominent point between eyebrows |
| Forehead | Frontalis | `frontalis` | Forehead region |
| Nasal Bridge Front | Nasion | `nasion` | Deepest point of nasal root |
| Rhinion | Rhinion | `rhinion` | Junction of bony and cartilaginous nose |
| Supratip | Supratip Break | `supratip_break` | Depression above nasal tip |
| Infratip | Infratip Lobule | `infratip_lobule` | Area below nasal tip |
| Columella | Columella Nasi | `columella_nasi` | Fleshy external end of nasal septum |
| Subnasale | Subnasale | `subnasale_side` | Junction of columella and upper lip |
| Subalare | Subalare | `subalare` | Junction of alar base and upper lip |
| Upper Lip | Labrale Superius | `labrale_superius_side` | Upper lip vermilion border |
| Mouth Corner | Cheilion | `cheilion_side` | Oral commissure (profile view) |
| Lower Lip | Labrale Inferius | `labrale_inferius_side` | Lower lip vermilion border |
| Labiomental Fold | Sublabiale | `sublabiale` | Deepest point of labiomental sulcus |
| Chin Point | Pogonion (soft tissue) | `pogonion` | Most anterior point of chin |
| Chin Bottom | Menton (soft tissue) | `menton_side` | Lowest point of chin |
| Cervical Point | Cervicale (soft tissue reference) | `cervicale` | Cervical point for profile analysis |
| Upper Jaw Angle | Gonion Superior | `gonion_superior_side` | Superior mandibular angle |
| Lower Jaw Angle | Gonion Inferior | `gonion_inferior_side` | Inferior mandibular angle |

---

## Scoring Formulas

> **Implementation Note:** All scoring functions are implemented in `src/lib/scoring.ts`.
> Side profile landmarks use the `_side` suffix (e.g., `menton_side`, `labrale_superius_side`).

### 1. Gonial Angle (Side Profile)

The Gonial Angle measures the angle of the mandible, important for jaw definition assessment.

```typescript
/**
 * Calculate Gonial Angle
 * Uses: tragion, gonion_inferior_side, menton_side
 * Ideal range: 120° - 130° (male), 125° - 135° (female)
 */
function calculateGonialAngle(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female'
): ScoreResult {
  const tragion = getLandmark(sideLandmarks, 'tragion');
  const gonion_inferior = getLandmark(sideLandmarks, 'gonion_inferior_side');
  const menton = getLandmark(sideLandmarks, 'menton_side');

  return calculateAngle(tragion, gonion_inferior, menton);
}

// Score calculation
function scoreGonialAngle(angle: number, gender: 'male' | 'female'): number {
  const idealMin = gender === 'male' ? 120 : 125;
  const idealMax = gender === 'male' ? 130 : 135;

  if (angle >= idealMin && angle <= idealMax) {
    return 100; // Perfect score
  }

  const deviation = angle < idealMin
    ? idealMin - angle
    : angle - idealMax;

  // Deduct 5 points per degree of deviation, minimum score of 0
  return Math.max(0, 100 - (deviation * 5));
}
```

### 2. Nasolabial Angle (Side Profile)

The Nasolabial Angle measures the angle between the columella and the upper lip.

```typescript
/**
 * Calculate Nasolabial Angle
 * Uses: columella_nasi, subnasale_side, labrale_superius_side
 * Ideal range: 90° - 105° (male), 95° - 115° (female)
 */
function calculateNasolabialAngle(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female'
): ScoreResult {
  const columella = getLandmark(sideLandmarks, 'columella_nasi');
  const subnasale = getLandmark(sideLandmarks, 'subnasale_side');
  const labrale_superius = getLandmark(sideLandmarks, 'labrale_superius_side');

  return calculateAngle(columella, subnasale, labrale_superius);
}

// Score calculation
function scoreNasolabialAngle(angle: number, gender: 'male' | 'female'): number {
  const idealMin = gender === 'male' ? 90 : 95;
  const idealMax = gender === 'male' ? 105 : 115;

  if (angle >= idealMin && angle <= idealMax) {
    return 100;
  }

  const deviation = angle < idealMin
    ? idealMin - angle
    : angle - idealMax;

  return Math.max(0, 100 - (deviation * 4));
}
```

### 3. E-Line (Ricketts' Esthetic Line) (Side Profile)

The E-Line measures lip protrusion relative to the nose and chin profile.

```typescript
/**
 * Calculate E-Line Distance
 * Uses: pronasale, pogonion, labrale_superius_side, labrale_inferius_side
 *
 * The E-Line is drawn from pronasale to pogonion.
 * Measures the perpendicular distance of lips from this line.
 *
 * Ideal: Upper lip 4mm behind, Lower lip 2mm behind (±2mm tolerance)
 */
function calculateELine(
  sideLandmarks: LandmarkPoint[],
  gender: 'male' | 'female'
): { upperLip: ScoreResult; lowerLip: ScoreResult; combined: ScoreResult } {
  const pronasale = getLandmark(sideLandmarks, 'pronasale');
  const pogonion = getLandmark(sideLandmarks, 'pogonion');
  const labrale_superius = getLandmark(sideLandmarks, 'labrale_superius_side');
  const labrale_inferius = getLandmark(sideLandmarks, 'labrale_inferius_side');

  // Calculate perpendicular distance from point to line
  const upperLipDistance = perpendicularDistance(
    labrale_superius,
    pronasale,
    pogonion
  );

  const lowerLipDistance = perpendicularDistance(
    labrale_inferius,
    pronasale,
    pogonion
  );

  return { upperLipDistance, lowerLipDistance };
}

// Score calculation
function scoreELine(
  upperLipDistance: number,
  lowerLipDistance: number,
  gender: 'male' | 'female'
): number {
  // Ideal values (negative = behind the line)
  const idealUpperLip = gender === 'male' ? -4 : -2;
  const idealLowerLip = gender === 'male' ? -2 : 0;
  const tolerance = 2;

  const upperDeviation = Math.abs(upperLipDistance - idealUpperLip);
  const lowerDeviation = Math.abs(lowerLipDistance - idealLowerLip);

  const upperScore = upperDeviation <= tolerance
    ? 100
    : Math.max(0, 100 - ((upperDeviation - tolerance) * 10));

  const lowerScore = lowerDeviation <= tolerance
    ? 100
    : Math.max(0, 100 - ((lowerDeviation - tolerance) * 10));

  return (upperScore + lowerScore) / 2;
}
```

### 4. Facial Thirds (Front Profile)

```typescript
/**
 * Calculate Facial Thirds
 * Uses: trichion, nasal_base (as glabella proxy), subnasale, menton
 * Ideal: Each third should be approximately 33% of total face height
 */
function calculateFacialThirds(
  frontLandmarks: LandmarkPoint[]
): { upper: ScoreResult; middle: ScoreResult; lower: ScoreResult; overall: ScoreResult } {
  const trichion = getLandmark(frontLandmarks, 'trichion');
  const nasal_base = getLandmark(frontLandmarks, 'nasal_base');
  const subnasale = getLandmark(frontLandmarks, 'subnasale');
  const menton = getLandmark(frontLandmarks, 'menton');

  const totalHeight = distance(trichion, menton);

  const upperThird = distance(trichion, nasal_base) / totalHeight * 100;
  const middleThird = distance(nasal_base, subnasale) / totalHeight * 100;
  const lowerThird = distance(subnasale, menton) / totalHeight * 100;

  return { upper: upperThird, middle: middleThird, lower: lowerThird };
}

function scoreFacialThirds(thirds: { upper: number; middle: number; lower: number }): number {
  const ideal = 33.33;
  const tolerance = 3; // ±3% tolerance

  const deviations = [
    Math.abs(thirds.upper - ideal),
    Math.abs(thirds.middle - ideal),
    Math.abs(thirds.lower - ideal)
  ];

  const avgDeviation = deviations.reduce((a, b) => a + b, 0) / 3;

  if (avgDeviation <= tolerance) {
    return 100;
  }

  return Math.max(0, 100 - ((avgDeviation - tolerance) * 8));
}
```

### 5. Facial Width-to-Height Ratio (Front Profile)

```typescript
/**
 * Calculate Facial Width-to-Height Ratio
 * Uses: left_zygion, right_zygion, nasal_base, labrale_superius
 * Ideal range: 1.8 - 2.0 (considered most attractive)
 */
function calculateFWHR(
  frontLandmarks: LandmarkPoint[]
): ScoreResult {
  const left_zygion = getLandmark(frontLandmarks, 'left_zygion');
  const right_zygion = getLandmark(frontLandmarks, 'right_zygion');
  const nasal_base = getLandmark(frontLandmarks, 'nasal_base');
  const labrale_superius = getLandmark(frontLandmarks, 'labrale_superius');

  const bizygomatic_width = distance(left_zygion, right_zygion);
  const upper_face_height = distance(nasal_base, labrale_superius);

  return bizygomatic_width / upper_face_height;
}

function scoreFWHR(ratio: number): number {
  const idealMin = 1.8;
  const idealMax = 2.0;

  if (ratio >= idealMin && ratio <= idealMax) {
    return 100;
  }

  const deviation = ratio < idealMin
    ? idealMin - ratio
    : ratio - idealMax;

  return Math.max(0, 100 - (deviation * 50));
}
```

### 6. Interpupillary Distance Ratio (Front Profile)

```typescript
/**
 * Calculate Interpupillary to Face Width Ratio
 * Uses: left_pupila, right_pupila, left_zygion, right_zygion
 * Ideal: IPD should be approximately 46% of bizygomatic width
 */
function calculateIPDRatio(
  frontLandmarks: LandmarkPoint[]
): ScoreResult {
  const left_pupila = getLandmark(frontLandmarks, 'left_pupila');
  const right_pupila = getLandmark(frontLandmarks, 'right_pupila');
  const left_zygion = getLandmark(frontLandmarks, 'left_zygion');
  const right_zygion = getLandmark(frontLandmarks, 'right_zygion');

  const ipd = distance(left_pupila, right_pupila);
  const bizygomatic_width = distance(left_zygion, right_zygion);

  return (ipd / bizygomatic_width) * 100;
}

function scoreIPDRatio(ratio: number): number {
  const ideal = 46;
  const tolerance = 2;

  const deviation = Math.abs(ratio - ideal);

  if (deviation <= tolerance) {
    return 100;
  }

  return Math.max(0, 100 - ((deviation - tolerance) * 8));
}
```

### 7. Nasal Index (Front Profile)

```typescript
/**
 * Calculate Nasal Index
 * Uses: left_ala_nasi, right_ala_nasi, nasal_base, subnasale
 * Ideal varies by ethnicity (see classification below)
 */
function calculateNasalIndex(
  frontLandmarks: LandmarkPoint[]
): ScoreResult {
  const left_ala_nasi = getLandmark(frontLandmarks, 'left_ala_nasi');
  const right_ala_nasi = getLandmark(frontLandmarks, 'right_ala_nasi');
  const nasal_base = getLandmark(frontLandmarks, 'nasal_base');
  const subnasale = getLandmark(frontLandmarks, 'subnasale');

  const nasal_width = distance(left_ala_nasi, right_ala_nasi);
  const nasal_height = distance(nasal_base, subnasale);

  return (nasal_width / nasal_height) * 100;
}

// Classification:
// Leptorrhine (narrow): < 70
// Mesorrhine (medium): 70 - 85
// Platyrrhine (broad): > 85
```

### 8. Eye Canthal Tilt (Front Profile)

```typescript
/**
 * Calculate Canthal Tilt
 * Uses: left_canthus_medialis, left_canthus_lateralis (or right equivalents)
 * Positive tilt = lateral canthus higher than medial (desirable)
 * Ideal: 4° - 8° positive tilt
 */
function calculateCanthalTilt(
  frontLandmarks: LandmarkPoint[],
  side: 'left' | 'right'
): ScoreResult {
  const medialId = side === 'left' ? 'left_canthus_medialis' : 'right_canthus_medialis';
  const lateralId = side === 'left' ? 'left_canthus_lateralis' : 'right_canthus_lateralis';

  const canthus_medialis = getLandmark(frontLandmarks, medialId);
  const canthus_lateralis = getLandmark(frontLandmarks, lateralId);

  const deltaY = canthus_medialis.y - canthus_lateralis.y; // Inverted for screen coords
  const deltaX = canthus_lateralis.x - canthus_medialis.x;

  return Math.atan2(deltaY, deltaX) * (180 / Math.PI);
}

function scoreCanthalTilt(angle: number): number {
  const idealMin = 4;
  const idealMax = 8;

  if (angle >= idealMin && angle <= idealMax) {
    return 100;
  }

  // Negative tilt is worse than excessive positive tilt
  if (angle < 0) {
    return Math.max(0, 50 + (angle * 5)); // Harsh penalty for negative
  }

  const deviation = angle < idealMin
    ? idealMin - angle
    : angle - idealMax;

  return Math.max(0, 100 - (deviation * 10));
}
```

---

## Utility Functions

```typescript
interface Point {
  x: number;
  y: number;
}

/**
 * Calculate distance between two points
 */
function distance(p1: Point, p2: Point): number {
  return Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2));
}

/**
 * Calculate angle at vertex point (in degrees)
 * Angle is formed by points: p1 -> vertex -> p2
 */
function calculateAngle(p1: Point, vertex: Point, p2: Point): number {
  const v1 = { x: p1.x - vertex.x, y: p1.y - vertex.y };
  const v2 = { x: p2.x - vertex.x, y: p2.y - vertex.y };

  const dot = v1.x * v2.x + v1.y * v2.y;
  const cross = v1.x * v2.y - v1.y * v2.x;

  const angle = Math.atan2(cross, dot) * (180 / Math.PI);
  return Math.abs(angle);
}

/**
 * Calculate perpendicular distance from point to line
 * Line defined by two points: lineStart and lineEnd
 */
function perpendicularDistance(
  point: Point,
  lineStart: Point,
  lineEnd: Point
): number {
  const A = point.x - lineStart.x;
  const B = point.y - lineStart.y;
  const C = lineEnd.x - lineStart.x;
  const D = lineEnd.y - lineStart.y;

  const dot = A * C + B * D;
  const lenSq = C * C + D * D;
  const param = lenSq !== 0 ? dot / lenSq : -1;

  let xx: number, yy: number;

  if (param < 0) {
    xx = lineStart.x;
    yy = lineStart.y;
  } else if (param > 1) {
    xx = lineEnd.x;
    yy = lineEnd.y;
  } else {
    xx = lineStart.x + param * C;
    yy = lineStart.y + param * D;
  }

  const dx = point.x - xx;
  const dy = point.y - yy;

  // Determine sign (positive = in front of line, negative = behind)
  const sign = ((lineEnd.y - lineStart.y) * point.x -
                (lineEnd.x - lineStart.x) * point.y +
                lineEnd.x * lineStart.y -
                lineEnd.y * lineStart.x) >= 0 ? 1 : -1;

  return sign * Math.sqrt(dx * dx + dy * dy);
}
```

---

## Default Starting Positions

### Front Profile Default Positions (Normalized 0-1)

These are default landmark positions for an average frontal photo, used as initial placement before auto-detection or manual adjustment.

```typescript
export const FRONT_PROFILE_DEFAULTS: Record<string, { x: number; y: number }> = {
  // Head/Hair
  trichion: { x: 0.50, y: 0.08 },

  // Eyes - Left
  left_pupila: { x: 0.38, y: 0.35 },
  left_canthus_medialis: { x: 0.42, y: 0.35 },
  left_canthus_lateralis: { x: 0.32, y: 0.34 },
  left_palpebra_superior: { x: 0.37, y: 0.33 },
  left_palpebra_inferior: { x: 0.37, y: 0.37 },
  left_sulcus_palpebralis_lateralis: { x: 0.31, y: 0.33 },
  left_pretarsal_skin_crease: { x: 0.37, y: 0.32 },

  // Eyes - Right
  right_pupila: { x: 0.62, y: 0.35 },
  right_canthus_medialis: { x: 0.58, y: 0.35 },
  right_canthus_lateralis: { x: 0.68, y: 0.34 },
  right_palpebra_superior: { x: 0.63, y: 0.33 },
  right_palpebra_inferior: { x: 0.63, y: 0.37 },
  right_sulcus_palpebralis_lateralis: { x: 0.69, y: 0.33 },
  right_pretarsal_skin_crease: { x: 0.63, y: 0.32 },

  // Eyebrows - Left
  left_supercilium_medialis: { x: 0.43, y: 0.28 },
  left_supercilium_medial_corner: { x: 0.41, y: 0.27 },
  left_supercilium_superior: { x: 0.36, y: 0.26 },
  left_supercilium_apex: { x: 0.34, y: 0.26 },
  left_supercilium_lateralis: { x: 0.29, y: 0.28 },

  // Eyebrows - Right
  right_supercilium_medialis: { x: 0.57, y: 0.28 },
  right_supercilium_medial_corner: { x: 0.59, y: 0.27 },
  right_supercilium_superior: { x: 0.64, y: 0.26 },
  right_supercilium_apex: { x: 0.66, y: 0.26 },
  right_supercilium_lateralis: { x: 0.71, y: 0.28 },

  // Nose
  nasal_base: { x: 0.50, y: 0.38 },
  left_dorsum_nasi: { x: 0.47, y: 0.42 },
  right_dorsum_nasi: { x: 0.53, y: 0.42 },
  left_ala_nasi: { x: 0.44, y: 0.50 },
  right_ala_nasi: { x: 0.56, y: 0.50 },
  subnasale: { x: 0.50, y: 0.52 },

  // Mouth
  labrale_superius: { x: 0.50, y: 0.58 },
  cupids_bow: { x: 0.50, y: 0.57 },
  mouth_middle: { x: 0.50, y: 0.62 },
  labrale_inferius: { x: 0.50, y: 0.66 },
  left_cheilion: { x: 0.42, y: 0.62 },
  right_cheilion: { x: 0.58, y: 0.62 },

  // Jaw
  left_gonion_superior: { x: 0.22, y: 0.55 },
  right_gonion_superior: { x: 0.78, y: 0.55 },
  left_gonion_inferior: { x: 0.24, y: 0.70 },
  right_gonion_inferior: { x: 0.76, y: 0.70 },

  // Chin
  left_mentum_lateralis: { x: 0.42, y: 0.80 },
  right_mentum_lateralis: { x: 0.58, y: 0.80 },
  menton: { x: 0.50, y: 0.88 },

  // Face Width
  left_zygion: { x: 0.18, y: 0.42 },
  right_zygion: { x: 0.82, y: 0.42 },
  left_temporal: { x: 0.20, y: 0.30 },
  right_temporal: { x: 0.80, y: 0.30 },

  // Ears
  left_auricular_lateral: { x: 0.12, y: 0.40 },
  right_auricular_lateral: { x: 0.88, y: 0.40 },

  // Neck
  left_cervical_lateralis: { x: 0.35, y: 0.95 },
  right_cervical_lateralis: { x: 0.65, y: 0.95 },
};
```

### Side Profile Default Positions (Normalized 0-1)

```typescript
export const SIDE_PROFILE_DEFAULTS: Record<string, { x: number; y: number }> = {
  // Cranium
  vertex: { x: 0.45, y: 0.02 },
  external_occipital_region: { x: 0.85, y: 0.15 },
  trichion_profile: { x: 0.35, y: 0.10 },

  // Forehead/Brow
  frontalis: { x: 0.30, y: 0.18 },
  glabella: { x: 0.32, y: 0.28 },

  // Eye Region
  corneal_apex: { x: 0.28, y: 0.34 },
  lateral_eyelid: { x: 0.35, y: 0.34 },
  palpebra_inferior_side: { x: 0.30, y: 0.36 },
  orbitale: { x: 0.35, y: 0.38 },

  // Nose
  nasion: { x: 0.35, y: 0.32 },
  rhinion: { x: 0.28, y: 0.40 },
  supratip_break: { x: 0.22, y: 0.46 },
  pronasale: { x: 0.18, y: 0.48 },
  infratip_lobule: { x: 0.20, y: 0.50 },
  columella_nasi: { x: 0.24, y: 0.52 },
  subnasale_side: { x: 0.30, y: 0.54 },
  subalare: { x: 0.28, y: 0.53 },

  // Mouth/Lips
  labrale_superius_side: { x: 0.28, y: 0.58 },
  cheilion_side: { x: 0.35, y: 0.62 },
  labrale_inferius_side: { x: 0.30, y: 0.66 },
  sublabiale: { x: 0.32, y: 0.70 },

  // Chin
  pogonion: { x: 0.30, y: 0.76 },
  menton_side: { x: 0.35, y: 0.82 },

  // Jaw
  gonion_superior_side: { x: 0.70, y: 0.60 },
  gonion_inferior_side: { x: 0.65, y: 0.72 },

  // Cheek
  zygion_soft_tissue: { x: 0.45, y: 0.42 },

  // Ear
  porion: { x: 0.75, y: 0.35 },
  tragion: { x: 0.72, y: 0.42 },
  incisura_intertragica: { x: 0.73, y: 0.45 },

  // Neck
  cervicale: { x: 0.50, y: 0.90 },
  anterior_cervical_landmark: { x: 0.40, y: 0.88 },
};
```

---

## Implementation Notes

### Auto-Detection (Front Profile)

The front profile auto-detection should use face-api.js or MediaPipe Face Mesh to detect the 68/478 facial landmarks, then map them to our medical landmark keys.

### Manual Adjustment (Side Profile)

Since side profile auto-detection is limited, the Manual Adjustment tool should:
1. Load default positions from `SIDE_PROFILE_DEFAULTS`
2. Allow users to drag each point to the correct location
3. Provide visual guides and labels for each landmark
4. Save adjusted positions for analysis

### Coordinate System

All positions are normalized to 0-1 range:
- `x: 0` = left edge of image
- `x: 1` = right edge of image
- `y: 0` = top edge of image
- `y: 1` = bottom edge of image

This ensures landmarks work regardless of image resolution.
