/**
 * Unified Face Detection Service
 * Uses MediaPipe Tasks Vision for optimal performance
 * Singleton pattern with preloading and warmup support
 */

import { FaceLandmarker, FilesetResolver, FaceLandmarkerResult } from '@mediapipe/tasks-vision';

const CONFIG = {
  // Self-hosted for better reliability
  MODEL_URL: '/wasm/face_landmarker.task',
  WASM_URL: '/wasm',
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
    return landmarker.detect(image);
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
