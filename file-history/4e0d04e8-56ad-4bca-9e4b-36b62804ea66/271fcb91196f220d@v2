/**
 * Side Profile Detection using Image Processing
 *
 * Since MediaPipe doesn't work well with side profiles, this module uses
 * edge detection and contour analysis to find the profile silhouette
 * and estimate landmark positions.
 *
 * Performance optimizations:
 * - Image downsampling before edge detection (reduces computation 4-9x)
 */

import { SIDE_PROFILE_LANDMARKS } from './landmarks';

// Maximum dimension for edge detection processing
const MAX_PROCESSING_SIZE = 480;

interface Point {
  x: number;
  y: number;
}

interface ProfileContour {
  points: Point[];
  boundingBox: { x: number; y: number; width: number; height: number };
  orientation: 'left' | 'right'; // Which direction the face is pointing
}

interface SideProfileResult {
  landmarks: Array<{ id: string; x: number; y: number }>;
  confidence: number;
  contour: Point[];
  orientation: 'left' | 'right';
}

/**
 * Detect side profile landmarks from an image
 */
export async function detectSideProfile(
  imageUrl: string
): Promise<SideProfileResult | null> {
  try {
    const img = await loadImage(imageUrl);
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    if (!ctx) return null;

    // Downsample large images for faster edge detection
    const { width, height } = downsampleDimensions(img.width, img.height, MAX_PROCESSING_SIZE);
    canvas.width = width;
    canvas.height = height;
    ctx.imageSmoothingEnabled = true;
    ctx.imageSmoothingQuality = 'high';
    ctx.drawImage(img, 0, 0, width, height);

    // Get image data (landmarks use normalized 0-1 coordinates, so no rescaling needed)
    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);

    // Step 1: Convert to grayscale
    const grayscale = toGrayscale(imageData);

    // Step 2: Apply Gaussian blur to reduce noise
    const blurred = gaussianBlur(grayscale, canvas.width, canvas.height);

    // Step 3: Edge detection (Sobel operator)
    const edges = sobelEdgeDetection(blurred, canvas.width, canvas.height);

    // Step 4: Find the profile contour
    const contour = extractProfileContour(edges, canvas.width, canvas.height);

    if (!contour || contour.points.length < 10) {
      console.log('[SideProfile] Could not extract sufficient contour points');
      return null;
    }

    // Step 5: Analyze contour to find key anchor points
    const anchors = findAnchorPoints(contour);

    // Step 6: Map anchors to our 28 landmarks
    const landmarks = mapToLandmarks(anchors, contour);

    return {
      landmarks,
      confidence: 0.7, // Lower confidence than MediaPipe frontal
      contour: contour.points,
      orientation: contour.orientation,
    };
  } catch (error) {
    console.error('[SideProfile] Detection error:', error);
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
    img.onerror = reject;
    img.src = url;
  });
}

/**
 * Calculate downsampled dimensions while maintaining aspect ratio
 */
function downsampleDimensions(
  width: number,
  height: number,
  maxSize: number
): { width: number; height: number } {
  const maxDim = Math.max(width, height);
  if (maxDim <= maxSize) {
    return { width, height };
  }

  const scale = maxSize / maxDim;
  return {
    width: Math.round(width * scale),
    height: Math.round(height * scale),
  };
}

/**
 * Convert image data to grayscale array
 */
function toGrayscale(imageData: ImageData): Uint8Array {
  const data = imageData.data;
  const gray = new Uint8Array(data.length / 4);

  for (let i = 0; i < gray.length; i++) {
    const idx = i * 4;
    // Luminosity method for grayscale
    gray[i] = Math.round(0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2]);
  }

  return gray;
}

/**
 * Apply 3x3 Gaussian blur
 */
function gaussianBlur(gray: Uint8Array, width: number, height: number): Uint8Array {
  const kernel = [
    1/16, 2/16, 1/16,
    2/16, 4/16, 2/16,
    1/16, 2/16, 1/16
  ];

  const result = new Uint8Array(gray.length);

  for (let y = 1; y < height - 1; y++) {
    for (let x = 1; x < width - 1; x++) {
      let sum = 0;
      let k = 0;
      for (let ky = -1; ky <= 1; ky++) {
        for (let kx = -1; kx <= 1; kx++) {
          sum += gray[(y + ky) * width + (x + kx)] * kernel[k++];
        }
      }
      result[y * width + x] = sum;
    }
  }

  return result;
}

/**
 * Sobel edge detection
 */
function sobelEdgeDetection(gray: Uint8Array, width: number, height: number): Uint8Array {
  const sobelX = [-1, 0, 1, -2, 0, 2, -1, 0, 1];
  const sobelY = [-1, -2, -1, 0, 0, 0, 1, 2, 1];

  const edges = new Uint8Array(gray.length);

  for (let y = 1; y < height - 1; y++) {
    for (let x = 1; x < width - 1; x++) {
      let gx = 0, gy = 0;
      let k = 0;

      for (let ky = -1; ky <= 1; ky++) {
        for (let kx = -1; kx <= 1; kx++) {
          const pixel = gray[(y + ky) * width + (x + kx)];
          gx += pixel * sobelX[k];
          gy += pixel * sobelY[k];
          k++;
        }
      }

      // Magnitude
      edges[y * width + x] = Math.min(255, Math.sqrt(gx * gx + gy * gy));
    }
  }

  return edges;
}

/**
 * Extract the profile contour from edge image
 * Looks for the strongest vertical edge on each side
 */
function extractProfileContour(
  edges: Uint8Array,
  width: number,
  height: number
): ProfileContour | null {
  // Determine if face is on left or right side of image
  let leftEdgeSum = 0;
  let rightEdgeSum = 0;

  const midX = width / 2;

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const val = edges[y * width + x];
      if (x < midX) {
        leftEdgeSum += val;
      } else {
        rightEdgeSum += val;
      }
    }
  }

  // Face is likely on the side with more edge activity
  const faceOnLeft = leftEdgeSum > rightEdgeSum;
  const orientation: 'left' | 'right' = faceOnLeft ? 'left' : 'right'; // profile edge direction

  // Find the profile edge - scan from the face side inward
  const contourPoints: Point[] = [];
  const threshold = 30; // Edge threshold

  // Scan each row to find the profile edge
  for (let y = Math.floor(height * 0.1); y < Math.floor(height * 0.95); y++) {
    let edgeX = -1;
    let maxEdge = threshold;

    if (faceOnLeft) {
      // Scan from left, find rightmost strong edge in left half
      for (let x = 0; x < midX; x++) {
        if (edges[y * width + x] > maxEdge) {
          maxEdge = edges[y * width + x];
          edgeX = x;
        }
      }
    } else {
      // Scan from right, find leftmost strong edge in right half
      for (let x = width - 1; x >= midX; x--) {
        if (edges[y * width + x] > maxEdge) {
          maxEdge = edges[y * width + x];
          edgeX = x;
        }
      }
    }

    if (edgeX !== -1) {
      contourPoints.push({ x: edgeX / width, y: y / height });
    }
  }

  if (contourPoints.length < 10) return null;

  // Smooth the contour using moving average
  const smoothedPoints = smoothContour(contourPoints, 5);

  // Calculate bounding box
  let minX = 1, minY = 1, maxX = 0, maxY = 0;
  smoothedPoints.forEach(p => {
    minX = Math.min(minX, p.x);
    minY = Math.min(minY, p.y);
    maxX = Math.max(maxX, p.x);
    maxY = Math.max(maxY, p.y);
  });

  return {
    points: smoothedPoints,
    boundingBox: { x: minX, y: minY, width: maxX - minX, height: maxY - minY },
    orientation,
  };
}

/**
 * Smooth contour points using moving average
 */
function smoothContour(points: Point[], windowSize: number): Point[] {
  const smoothed: Point[] = [];
  const half = Math.floor(windowSize / 2);

  for (let i = 0; i < points.length; i++) {
    let sumX = 0, sumY = 0, count = 0;

    for (let j = -half; j <= half; j++) {
      const idx = i + j;
      if (idx >= 0 && idx < points.length) {
        sumX += points[idx].x;
        sumY += points[idx].y;
        count++;
      }
    }

    smoothed.push({ x: sumX / count, y: sumY / count });
  }

  return smoothed;
}

interface AnchorPoints {
  vertex: Point;      // Top of head
  forehead: Point;    // Forehead profile
  glabella: Point;    // Between brows
  nasion: Point;      // Nasal root
  noseTip: Point;     // Pronasale
  subnasale: Point;   // Base of nose
  upperLip: Point;    // Labrale superius
  lowerLip: Point;    // Labrale inferius
  chin: Point;        // Pogonion
  menton: Point;      // Bottom of chin
  neckPoint: Point;   // Neck
  jawAngle: Point;    // Gonion
}

/**
 * Find anchor points along the profile contour
 */
function findAnchorPoints(
  contour: ProfileContour
): AnchorPoints {
  const points = contour.points;

  // Helper to find point at approximate Y position
  const findPointAtY = (targetY: number): Point => {
    let closest = points[0];
    let minDist = Math.abs(points[0].y - targetY);

    for (const p of points) {
      const dist = Math.abs(p.y - targetY);
      if (dist < minDist) {
        minDist = dist;
        closest = p;
      }
    }
    return closest;
  };

  // Helper to find the most protruding point in a Y range
  const findProtrudingPoint = (yStart: number, yEnd: number, direction: 'left' | 'right'): Point => {
    let best = points[0];

    for (const p of points) {
      if (p.y >= yStart && p.y <= yEnd) {
        if (direction === 'left' && p.x < best.x) best = p;
        if (direction === 'right' && p.x > best.x) best = p;
      }
    }
    return best;
  };

  // Find key inflection points based on profile geometry
  const isLeftFacing = contour.orientation === 'left';
  const protrusion = isLeftFacing ? 'left' : 'right';

  // Divide face into regions based on typical proportions
  const vertex = findPointAtY(0.05);
  const forehead = findPointAtY(0.15);
  const glabella = findPointAtY(0.28);
  const nasion = findPointAtY(0.32);

  // Nose tip is usually the most protruding point between y=0.35 and y=0.55
  const noseTip = findProtrudingPoint(0.35, 0.55, protrusion);

  const subnasale = findPointAtY(0.58);
  const upperLip = findPointAtY(0.62);
  const lowerLip = findPointAtY(0.68);

  // Chin (pogonion) is often protruding
  const chin = findProtrudingPoint(0.75, 0.85, protrusion);

  const menton = findPointAtY(0.88);
  const neckPoint = findPointAtY(0.95);

  // Jaw angle - find where contour curves from vertical to horizontal
  // This is typically around y=0.7-0.8, and set back from the chin
  const jawAngle = findPointAtY(0.75);

  return {
    vertex,
    forehead,
    glabella,
    nasion,
    noseTip,
    subnasale,
    upperLip,
    lowerLip,
    chin,
    menton,
    neckPoint,
    jawAngle,
  };
}

/**
 * Map anchor points to our 28 side profile landmarks
 */
function mapToLandmarks(
  anchors: AnchorPoints,
  contour: ProfileContour
): Array<{ id: string; x: number; y: number }> {
  const isLeft = contour.orientation === 'left';

  // Helper to interpolate between two points
  const lerp = (p1: Point, p2: Point, t: number): Point => ({
    x: p1.x + (p2.x - p1.x) * t,
    y: p1.y + (p2.y - p1.y) * t,
  });

  // Helper to offset a point horizontally (for ear/back of head estimation)
  const offsetX = (p: Point, offset: number): Point => ({
    x: p.x + (isLeft ? offset : -offset),
    y: p.y,
  });

  // Map each of our 28 landmarks
  // Standard cephalometric order: vertex, occiput, pronasale, neckPoint, porion, orbitale,
  // tragus, intertragicNotch, cornealApex, cheekbone, trichion, glabella, nasion,
  // rhinion, supratip, infratip, columella, subnasale, subalare, labraleSuperius,
  // cheilion, labraleInferius, sublabiale, pogonion, menton, cervicalPoint, gonionTop, gonionBottom

  const landmarkPositions: Record<string, Point> = {
    // 1. vertex - top of head
    vertex: anchors.vertex,

    // 2. occiput - back of head (estimate based on vertex, offset back)
    occiput: offsetX(anchors.vertex, 0.15),

    // 3. pronasale - nose tip
    pronasale: anchors.noseTip,

    // 4. neckPoint - lower neck
    neckPoint: anchors.neckPoint,

    // 5. porion - ear canal (estimate based on jaw angle, offset back)
    porion: offsetX({ x: anchors.jawAngle.x, y: anchors.nasion.y }, 0.08),

    // 6. orbitale - lowest orbital rim (between glabella and nasion level)
    orbitale: { x: lerp(anchors.glabella, anchors.nasion, 0.5).x, y: anchors.nasion.y - 0.02 },

    // 7. tragus - ear cartilage
    tragus: offsetX({ x: anchors.jawAngle.x, y: lerp(anchors.nasion, anchors.jawAngle, 0.3).y }, 0.06),

    // 8. intertragicNotch - notch in ear
    intertragicNotch: offsetX({ x: anchors.jawAngle.x, y: lerp(anchors.nasion, anchors.jawAngle, 0.5).y }, 0.07),

    // 9. cornealApex - forward point of cornea
    cornealApex: { x: anchors.glabella.x + (isLeft ? -0.02 : 0.02), y: anchors.glabella.y + 0.02 },

    // 10. cheekbone - zygomatic prominence
    cheekbone: lerp(anchors.nasion, anchors.jawAngle, 0.4),

    // 11. trichion - hairline
    trichion: anchors.forehead,

    // 12. glabella - between brows
    glabella: anchors.glabella,

    // 13. nasion - nasal root
    nasion: anchors.nasion,

    // 14. rhinion - mid-dorsum of nose
    rhinion: lerp(anchors.nasion, anchors.noseTip, 0.4),

    // 15. supratip - above nose tip
    supratip: lerp(anchors.nasion, anchors.noseTip, 0.75),

    // 16. infratip - below nose tip
    infratip: lerp(anchors.noseTip, anchors.subnasale, 0.3),

    // 17. columella - nasal septum
    columella: lerp(anchors.noseTip, anchors.subnasale, 0.5),

    // 18. subnasale - base of nose
    subnasale: anchors.subnasale,

    // 19. subalare - nostril wing
    subalare: { x: anchors.subnasale.x + (isLeft ? -0.02 : 0.02), y: anchors.subnasale.y - 0.01 },

    // 20. labraleSuperius - upper lip
    labraleSuperius: anchors.upperLip,

    // 21. cheilion - mouth corner
    cheilion: { x: lerp(anchors.upperLip, anchors.jawAngle, 0.3).x, y: lerp(anchors.upperLip, anchors.lowerLip, 0.5).y },

    // 22. labraleInferius - lower lip
    labraleInferius: anchors.lowerLip,

    // 23. sublabiale - below lower lip
    sublabiale: lerp(anchors.lowerLip, anchors.chin, 0.3),

    // 24. pogonion - chin prominence
    pogonion: anchors.chin,

    // 25. menton - bottom of chin
    menton: anchors.menton,

    // 26. cervicalPoint - high neck point
    cervicalPoint: lerp(anchors.menton, anchors.neckPoint, 0.5),

    // 27. gonionTop - upper jaw angle
    gonionTop: { x: anchors.jawAngle.x, y: anchors.jawAngle.y - 0.03 },

    // 28. gonionBottom - lower jaw angle
    gonionBottom: anchors.jawAngle,
  };

  // Convert to array matching SIDE_PROFILE_LANDMARKS order
  return SIDE_PROFILE_LANDMARKS.map(lm => {
    const pos = landmarkPositions[lm.id] || { x: 0.5, y: 0.5 };
    return {
      id: lm.id,
      x: Math.max(0, Math.min(1, pos.x)),
      y: Math.max(0, Math.min(1, pos.y)),
    };
  });
}

/**
 * Debug: Draw the detected contour on a canvas
 */
export function debugDrawContour(
  canvas: HTMLCanvasElement,
  contour: Point[],
  landmarks: Array<{ id: string; x: number; y: number }>
): void {
  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  const width = canvas.width;
  const height = canvas.height;

  // Draw contour
  ctx.strokeStyle = '#00ff00';
  ctx.lineWidth = 2;
  ctx.beginPath();
  contour.forEach((p, i) => {
    const x = p.x * width;
    const y = p.y * height;
    if (i === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  });
  ctx.stroke();

  // Draw landmarks
  landmarks.forEach(lm => {
    ctx.fillStyle = '#ff0000';
    ctx.beginPath();
    ctx.arc(lm.x * width, lm.y * height, 4, 0, Math.PI * 2);
    ctx.fill();

    ctx.fillStyle = '#ffffff';
    ctx.font = '10px sans-serif';
    ctx.fillText(lm.id, lm.x * width + 6, lm.y * height);
  });
}
