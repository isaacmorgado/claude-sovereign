'use client';

import { useState, useEffect, useCallback, RefObject } from 'react';

interface ImageBounds {
  /** Horizontal offset for object-contain letterboxing */
  offsetX: number;
  /** Vertical offset for object-contain letterboxing */
  offsetY: number;
  /** Rendered width of the image within container */
  renderedWidth: number;
  /** Rendered height of the image within container */
  renderedHeight: number;
  /** Container's width */
  containerWidth: number;
  /** Container's height */
  containerHeight: number;
}

interface UseContainerBoundsOptions {
  /** URL of the image to load dimensions for */
  imageUrl: string;
  /** Ref to the container element */
  containerRef: RefObject<HTMLDivElement>;
}

interface UseContainerBoundsReturn {
  /** Image natural dimensions */
  imageDimensions: { width: number; height: number } | null;
  /** Container dimensions (tracked via ResizeObserver) */
  containerSize: { width: number; height: number } | null;
  /** Calculated bounds for object-contain positioning */
  getImageBounds: () => ImageBounds;
  /** Convert normalized coords (0-1) to CSS position */
  getLandmarkPosition: (x: number, y: number) => { left: string; top: string };
  /** Whether dimensions are ready for use */
  isReady: boolean;
}

const DEFAULT_BOUNDS: ImageBounds = {
  offsetX: 0,
  offsetY: 0,
  renderedWidth: 1,
  renderedHeight: 1,
  containerWidth: 1,
  containerHeight: 1,
};

/**
 * Custom hook for tracking container and image dimensions.
 * Handles object-contain letterboxing calculations for accurate landmark positioning.
 */
export function useContainerBounds({
  imageUrl,
  containerRef,
}: UseContainerBoundsOptions): UseContainerBoundsReturn {
  const [imageDimensions, setImageDimensions] = useState<{
    width: number;
    height: number;
  } | null>(null);
  const [containerSize, setContainerSize] = useState<{
    width: number;
    height: number;
  } | null>(null);

  // Load image dimensions
  useEffect(() => {
    const img = new window.Image();
    img.onload = () => {
      setImageDimensions({ width: img.naturalWidth, height: img.naturalHeight });
    };
    img.src = imageUrl;
  }, [imageUrl]);

  // Track container size with ResizeObserver
  useEffect(() => {
    if (!containerRef.current) return;

    const observer = new ResizeObserver((entries) => {
      const { width, height } = entries[0].contentRect;
      setContainerSize({ width, height });
    });

    observer.observe(containerRef.current);
    return () => observer.disconnect();
  }, [containerRef]);

  // Calculate rendered image bounds within container (object-contain)
  const getImageBounds = useCallback((): ImageBounds => {
    if (!containerRef.current || !imageDimensions || !containerSize) {
      return DEFAULT_BOUNDS;
    }

    const containerWidth = containerSize.width;
    const containerHeight = containerSize.height;
    const imageAspect = imageDimensions.width / imageDimensions.height;
    const containerAspect = containerWidth / containerHeight;

    let renderedWidth: number;
    let renderedHeight: number;
    let offsetX = 0;
    let offsetY = 0;

    if (imageAspect > containerAspect) {
      // Image is wider - letterboxing top/bottom
      renderedWidth = containerWidth;
      renderedHeight = containerWidth / imageAspect;
      offsetY = (containerHeight - renderedHeight) / 2;
    } else {
      // Image is taller - letterboxing left/right
      renderedHeight = containerHeight;
      renderedWidth = containerHeight * imageAspect;
      offsetX = (containerWidth - renderedWidth) / 2;
    }

    return {
      offsetX,
      offsetY,
      renderedWidth,
      renderedHeight,
      containerWidth,
      containerHeight,
    };
  }, [imageDimensions, containerSize, containerRef]);

  // Convert normalized coordinates to CSS position
  const getLandmarkPosition = useCallback(
    (x: number, y: number): { left: string; top: string } => {
      const bounds = getImageBounds();
      const pixelX = bounds.offsetX + x * bounds.renderedWidth;
      const pixelY = bounds.offsetY + y * bounds.renderedHeight;

      return {
        left: `${(pixelX / bounds.containerWidth) * 100}%`,
        top: `${(pixelY / bounds.containerHeight) * 100}%`,
      };
    },
    [getImageBounds]
  );

  const isReady = imageDimensions !== null && containerSize !== null;

  return {
    imageDimensions,
    containerSize,
    getImageBounds,
    getLandmarkPosition,
    isReady,
  };
}
