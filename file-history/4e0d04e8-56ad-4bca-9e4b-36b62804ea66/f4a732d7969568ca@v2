/**
 * Unified Face Detection Service
 * Uses MediaPipe Tasks Vision for optimal performance
 * Singleton pattern with preloading and warmup support
 *
 * Performance optimizations:
 * - GPU delegation for WASM acceleration
 * - Image downsampling before inference (reduces computation 4x)
 * - Preloading and warmup for instant detection
 */

import { FaceLandmarker, FilesetResolver, FaceLandmarkerResult } from '@mediapipe/tasks-vision';

const CONFIG = {
  // Self-hosted for better reliability
  MODEL_URL: '/wasm/face_landmarker.task',
  WASM_URL: '/wasm',
  // Maximum image dimension for detection (larger images are downsampled)
  // 640px gives good accuracy while reducing computation by 4x for 1280px images
  MAX_DETECTION_SIZE: 640,
};

class FaceDetectionService {
  private landmarker: FaceLandmarker | null = null;
  private initPromise: Promise<FaceLandmarker> | null = null;
  private isWarmedUp = false;

  async initialize(): Promise<FaceLandmarker> {
    if (this.landmarker) return this.landmarker;
    if (this.initPromise) return this.initPromise;

    this.initPromise = this.createLandmarker();
    this.landmarker = await this.initPromise;
    this.initPromise = null;
    return this.landmarker;
  }

  private async createLandmarker(): Promise<FaceLandmarker> {
    const vision = await FilesetResolver.forVisionTasks(CONFIG.WASM_URL);
    return FaceLandmarker.createFromOptions(vision, {
      baseOptions: {
        modelAssetPath: CONFIG.MODEL_URL,
        delegate: 'GPU',
      },
      runningMode: 'IMAGE',
      numFaces: 1,
      outputFaceBlendshapes: false,
      outputFacialTransformationMatrixes: false,
    });
  }

  async warmup(): Promise<void> {
    if (this.isWarmedUp) return;
    const landmarker = await this.initialize();

    // Create dummy image for warmup (forces GPU shader compilation)
    const canvas = document.createElement('canvas');
    canvas.width = 224;
    canvas.height = 224;
    const ctx = canvas.getContext('2d');
    if (ctx) {
      ctx.fillStyle = '#888888';
      ctx.fillRect(0, 0, 224, 224);
      landmarker.detect(canvas);
    }
    this.isWarmedUp = true;
  }

  async detect(image: HTMLImageElement | HTMLCanvasElement): Promise<FaceLandmarkerResult> {
    const landmarker = await this.initialize();

    // Downsample large images for faster detection
    const processedImage = this.downsampleImage(image);

    return landmarker.detect(processedImage);
  }

  /**
   * Downsample image if it exceeds MAX_DETECTION_SIZE
   * Reduces computation time significantly for high-resolution images
   * Landmarks are returned in normalized 0-1 coordinates, so no rescaling needed
   */
  private downsampleImage(image: HTMLImageElement | HTMLCanvasElement): HTMLCanvasElement | HTMLImageElement {
    const width = image instanceof HTMLImageElement ? image.naturalWidth : image.width;
    const height = image instanceof HTMLImageElement ? image.naturalHeight : image.height;

    // If image is already small enough, return as-is
    const maxDim = Math.max(width, height);
    if (maxDim <= CONFIG.MAX_DETECTION_SIZE) {
      return image;
    }

    // Calculate scale factor
    const scale = CONFIG.MAX_DETECTION_SIZE / maxDim;
    const newWidth = Math.round(width * scale);
    const newHeight = Math.round(height * scale);

    // Create downsampled canvas
    const canvas = document.createElement('canvas');
    canvas.width = newWidth;
    canvas.height = newHeight;

    const ctx = canvas.getContext('2d');
    if (!ctx) return image;

    // Use high-quality downsampling
    ctx.imageSmoothingEnabled = true;
    ctx.imageSmoothingQuality = 'high';
    ctx.drawImage(image, 0, 0, newWidth, newHeight);

    return canvas;
  }

  isReady(): boolean {
    return this.landmarker !== null;
  }

  dispose(): void {
    if (this.landmarker) {
      this.landmarker.close();
      this.landmarker = null;
      this.isWarmedUp = false;
    }
  }
}

// Export singleton instance
export const faceDetectionService = new FaceDetectionService();

// Convenience exports
export async function preloadFaceDetection(): Promise<void> {
  await faceDetectionService.initialize();
  await faceDetectionService.warmup();
}

export function isFaceDetectionReady(): boolean {
  return faceDetectionService.isReady();
}
