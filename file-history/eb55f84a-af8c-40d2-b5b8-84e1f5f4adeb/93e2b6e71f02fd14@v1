'use client';

import { useState, useCallback } from 'react';

interface UseZoomPanOptions {
  /** Initial zoom level (default: 1) */
  initialZoom?: number;
  /** Minimum zoom level (default: 1) */
  minZoom?: number;
  /** Maximum zoom level (default: 4) */
  maxZoom?: number;
  /** Available zoom levels for quick selection (default: [1, 2, 4]) */
  zoomLevels?: number[];
}

interface UseZoomPanReturn {
  /** Current zoom level */
  zoomLevel: number;
  /** Set zoom level directly */
  setZoomLevel: (level: number) => void;
  /** Current pan offset */
  pan: { x: number; y: number };
  /** Set pan offset directly */
  setPan: (pan: { x: number; y: number }) => void;
  /** Whether user is currently dragging to pan */
  isDragging: boolean;
  /** Reset zoom and pan to initial state */
  resetZoom: () => void;
  /** Mouse down handler for drag initiation */
  handleMouseDown: (e: React.MouseEvent) => void;
  /** Mouse move handler for panning */
  handleMouseMove: (e: React.MouseEvent) => void;
  /** Mouse up handler to end drag */
  handleMouseUp: () => void;
  /** Get cursor style based on current state */
  getCursor: () => string;
  /** Inverse scale for landmark sizing (1/zoomLevel) */
  inverseScale: number;
  /** Available zoom levels */
  zoomLevels: number[];
  /** Zoom to center on a specific point */
  zoomToPoint: (
    normalizedX: number,
    normalizedY: number,
    bounds: {
      offsetX: number;
      offsetY: number;
      renderedWidth: number;
      renderedHeight: number;
      containerWidth: number;
      containerHeight: number;
    },
    targetZoom?: number
  ) => void;
}

/**
 * Custom hook for zoom and pan functionality.
 * Extracts common zoom/pan logic used across landmark tools.
 */
export function useZoomPan(options: UseZoomPanOptions = {}): UseZoomPanReturn {
  const {
    initialZoom = 1,
    minZoom = 1,
    maxZoom = 4,
    zoomLevels = [1, 2, 4],
  } = options;

  const [zoomLevel, setZoomLevelState] = useState(initialZoom);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);

  const setZoomLevel = useCallback(
    (level: number, containerCenter?: { x: number; y: number }) => {
      const clampedLevel = Math.max(minZoom, Math.min(maxZoom, level));

      // Reset pan when zooming to 1x
      if (clampedLevel === 1) {
        setZoomLevelState(1);
        setPan({ x: 0, y: 0 });
        return;
      }

      // If container center is provided, adjust pan to keep the same point centered
      if (containerCenter) {
        setPan(prevPan => {
          // Current center in image space: imageCenter = (containerCenter - pan) / oldZoom
          // New pan to show same center: newPan = containerCenter - imageCenter * newZoom
          const imageCenterX = (containerCenter.x - prevPan.x) / zoomLevel;
          const imageCenterY = (containerCenter.y - prevPan.y) / zoomLevel;
          return {
            x: containerCenter.x - imageCenterX * clampedLevel,
            y: containerCenter.y - imageCenterY * clampedLevel,
          };
        });
      }

      setZoomLevelState(clampedLevel);
    },
    [minZoom, maxZoom, zoomLevel]
  );

  const resetZoom = useCallback(() => {
    setZoomLevelState(initialZoom);
    setPan({ x: 0, y: 0 });
  }, [initialZoom]);

  const handleMouseDown = useCallback(
    (e: React.MouseEvent) => {
      if (e.button === 0 && zoomLevel > 1) {
        setIsDragging(true);
      }
    },
    [zoomLevel]
  );

  const handleMouseMove = useCallback(
    (e: React.MouseEvent) => {
      if (isDragging && zoomLevel > 1) {
        setPan((prev) => ({
          x: prev.x + e.movementX,
          y: prev.y + e.movementY,
        }));
      }
    },
    [isDragging, zoomLevel]
  );

  const handleMouseUp = useCallback(() => {
    setIsDragging(false);
  }, []);

  const getCursor = useCallback(() => {
    if (zoomLevel > 1 && isDragging) return 'grabbing';
    if (zoomLevel > 1) return 'grab';
    return 'crosshair';
  }, [zoomLevel, isDragging]);

  const zoomToPoint = useCallback(
    (
      normalizedX: number,
      normalizedY: number,
      bounds: {
        offsetX: number;
        offsetY: number;
        renderedWidth: number;
        renderedHeight: number;
        containerWidth: number;
        containerHeight: number;
      },
      targetZoom = 2
    ) => {
      setZoomLevelState(targetZoom);

      // Calculate pan to center the point
      const centerX = bounds.containerWidth / 2;
      const centerY = bounds.containerHeight / 2;
      const pointX = bounds.offsetX + normalizedX * bounds.renderedWidth;
      const pointY = bounds.offsetY + normalizedY * bounds.renderedHeight;

      setPan({
        x: (centerX - pointX) * targetZoom,
        y: (centerY - pointY) * targetZoom,
      });
    },
    []
  );

  return {
    zoomLevel,
    setZoomLevel,
    pan,
    setPan,
    isDragging,
    resetZoom,
    handleMouseDown,
    handleMouseMove,
    handleMouseUp,
    getCursor,
    inverseScale: 1 / zoomLevel,
    zoomLevels,
    zoomToPoint,
  };
}
