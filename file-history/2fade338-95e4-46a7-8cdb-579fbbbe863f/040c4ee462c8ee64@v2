'use client';

import { useMemo, useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Image from 'next/image';
import { Eye, ZoomIn, ZoomOut, Maximize2, Crosshair } from 'lucide-react';
import { LandmarkPoint } from '@/lib/landmarks';
import { Ratio, getScoreColor, getCategoryColor } from '@/types/results';

interface FaceOverlayProps {
  photo: string;
  landmarks: LandmarkPoint[];
  selectedRatio: Ratio | null;
  profileType: 'front' | 'side';
  showAllLandmarks?: boolean;
  compact?: boolean; // For smaller inline previews
}

interface ImageDimensions {
  naturalWidth: number;
  naturalHeight: number;
  aspectRatio: number;
}

// Calculate label position along a line
function getLabelPosition(
  x1: number, y1: number, x2: number, y2: number,
  position: 'start' | 'middle' | 'end' = 'middle'
): { x: number; y: number; anchor: string } {
  const t = position === 'start' ? 0.15 : position === 'end' ? 0.85 : 0.5;
  const x = x1 + (x2 - x1) * t;
  const y = y1 + (y2 - y1) * t;

  // Calculate perpendicular offset for label
  const dx = x2 - x1;
  const dy = y2 - y1;
  const len = Math.sqrt(dx * dx + dy * dy);
  const offsetX = len > 0 ? (-dy / len) * 2.5 : 0;
  const offsetY = len > 0 ? (dx / len) * 2.5 : 0;

  return {
    x: x + offsetX,
    y: y + offsetY,
    anchor: dx > 0 ? 'start' : 'end'
  };
}

// Calculate angle between three points (in degrees)
function calculateAngle(p1: { x: number; y: number }, vertex: { x: number; y: number }, p3: { x: number; y: number }): number {
  const v1 = { x: p1.x - vertex.x, y: p1.y - vertex.y };
  const v2 = { x: p3.x - vertex.x, y: p3.y - vertex.y };

  const dot = v1.x * v2.x + v1.y * v2.y;
  const cross = v1.x * v2.y - v1.y * v2.x;

  return Math.atan2(Math.abs(cross), dot) * (180 / Math.PI);
}

export function FaceOverlay({
  photo,
  landmarks,
  selectedRatio,
  profileType,
  showAllLandmarks: initialShowAllLandmarks = false,
  compact = false,
}: FaceOverlayProps) {
  const [zoom, setZoom] = useState(1);
  const [showAllLandmarks, setShowAllLandmarks] = useState(initialShowAllLandmarks);
  const [imageDimensions, setImageDimensions] = useState<ImageDimensions | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  // Load image dimensions for proper aspect ratio handling
  useEffect(() => {
    const img = new window.Image();
    img.onload = () => {
      setImageDimensions({
        naturalWidth: img.naturalWidth,
        naturalHeight: img.naturalHeight,
        aspectRatio: img.naturalWidth / img.naturalHeight,
      });
    };
    img.src = photo;
  }, [photo]);

  // Get landmark positions by ID
  const landmarkMap = useMemo(() => {
    const map: Record<string, LandmarkPoint> = {};
    landmarks.forEach(l => {
      map[l.id] = l;
    });
    return map;
  }, [landmarks]);

  // Compute viewBox dimensions based on image aspect ratio
  const viewBoxDimensions = useMemo(() => {
    if (!imageDimensions) {
      // Default 3:4 portrait aspect ratio
      return { width: 75, height: 100, viewBox: '0 0 75 100' };
    }
    const ar = imageDimensions.aspectRatio;
    if (ar >= 1) {
      // Landscape or square: width = 100, height = 100/ar
      const width = 100;
      const height = 100 / ar;
      return { width, height, viewBox: `0 0 ${width} ${height}` };
    } else {
      // Portrait: width = 100*ar, height = 100
      const width = 100 * ar;
      const height = 100;
      return { width, height, viewBox: `0 0 ${width} ${height}` };
    }
  }, [imageDimensions]);

  // Get lines, points, and labels to draw for selected ratio
  const visualizationData = useMemo(() => {
    if (!selectedRatio?.illustration) return null;

    const { width: vbW, height: vbH } = viewBoxDimensions;

    const points: Array<{ x: number; y: number; id: string; label?: string }> = [];
    const lines: Array<{
      x1: number; y1: number; x2: number; y2: number;
      color: string; label?: string; labelPosition?: 'start' | 'middle' | 'end'
    }> = [];
    const angles: Array<{
      vertex: { x: number; y: number };
      p1: { x: number; y: number };
      p2: { x: number; y: number };
      color: string;
      angle: number;
    }> = [];

    // Process points
    Object.entries(selectedRatio.illustration.points).forEach(([key, point]) => {
      if (point.type === 'landmark' && point.landmarkId) {
        const landmark = landmarkMap[point.landmarkId];
        if (landmark) {
          points.push({
            x: landmark.x * vbW,
            y: landmark.y * vbH,
            id: point.landmarkId,
            label: landmark.label,
          });
        }
      } else if (point.x !== undefined && point.y !== undefined) {
        points.push({
          x: point.x * vbW,
          y: point.y * vbH,
          id: key,
          label: point.label,
        });
      }
    });

    // Process lines
    Object.entries(selectedRatio.illustration.lines).forEach(([, line]) => {
      const fromLandmark = landmarkMap[line.from];
      const toLandmark = landmarkMap[line.to];

      if (fromLandmark && toLandmark) {
        lines.push({
          x1: fromLandmark.x * vbW,
          y1: fromLandmark.y * vbH,
          x2: toLandmark.x * vbW,
          y2: toLandmark.y * vbH,
          color: line.color || getCategoryColor(selectedRatio.category),
          label: line.label,
          labelPosition: line.labelPosition,
        });
      }
    });

    // Detect if this is an angle measurement (3 connected points forming an angle)
    // Look for patterns like: line1 ends where line2 starts (shared vertex)
    // Use relative tolerance based on viewBox size
    const tolerance = Math.max(vbW, vbH) * 0.01;

    if (lines.length === 2) {
      const l1 = lines[0];
      const l2 = lines[1];

      // Check for shared vertex
      let sharedVertex: { x: number; y: number } | null = null;
      let p1: { x: number; y: number } | null = null;
      let p2: { x: number; y: number } | null = null;

      // l1 end connects to l2 start
      if (Math.abs(l1.x2 - l2.x1) < tolerance && Math.abs(l1.y2 - l2.y1) < tolerance) {
        sharedVertex = { x: l1.x2, y: l1.y2 };
        p1 = { x: l1.x1, y: l1.y1 };
        p2 = { x: l2.x2, y: l2.y2 };
      }
      // l1 start connects to l2 start
      else if (Math.abs(l1.x1 - l2.x1) < tolerance && Math.abs(l1.y1 - l2.y1) < tolerance) {
        sharedVertex = { x: l1.x1, y: l1.y1 };
        p1 = { x: l1.x2, y: l1.y2 };
        p2 = { x: l2.x2, y: l2.y2 };
      }
      // l1 end connects to l2 end
      else if (Math.abs(l1.x2 - l2.x2) < tolerance && Math.abs(l1.y2 - l2.y2) < tolerance) {
        sharedVertex = { x: l1.x2, y: l1.y2 };
        p1 = { x: l1.x1, y: l1.y1 };
        p2 = { x: l2.x1, y: l2.y1 };
      }
      // l1 start connects to l2 end
      else if (Math.abs(l1.x1 - l2.x2) < tolerance && Math.abs(l1.y1 - l2.y2) < tolerance) {
        sharedVertex = { x: l1.x1, y: l1.y1 };
        p1 = { x: l1.x2, y: l1.y2 };
        p2 = { x: l2.x1, y: l2.y1 };
      }

      if (sharedVertex && p1 && p2) {
        const angle = calculateAngle(p1, sharedVertex, p2);
        angles.push({
          vertex: sharedVertex,
          p1,
          p2,
          color: l1.color,
          angle,
        });
      }
    }

    return { points, lines, angles };
  }, [selectedRatio, landmarkMap, viewBoxDimensions]);

  // Generate arc path for angle visualization
  const generateArcPath = (
    vertex: { x: number; y: number },
    p1: { x: number; y: number },
    p2: { x: number; y: number },
    radius: number = 4
  ): string => {
    // Calculate angles for the arc
    const angle1 = Math.atan2(p1.y - vertex.y, p1.x - vertex.x);
    const angle2 = Math.atan2(p2.y - vertex.y, p2.x - vertex.x);

    // Arc endpoints
    const x1 = vertex.x + radius * Math.cos(angle1);
    const y1 = vertex.y + radius * Math.sin(angle1);
    const x2 = vertex.x + radius * Math.cos(angle2);
    const y2 = vertex.y + radius * Math.sin(angle2);

    // Determine if we should use the large arc
    let angleDiff = angle2 - angle1;
    if (angleDiff < 0) angleDiff += 2 * Math.PI;
    const largeArc = angleDiff > Math.PI ? 1 : 0;

    return `M ${x1} ${y1} A ${radius} ${radius} 0 ${largeArc} 1 ${x2} ${y2}`;
  };

  return (
    <div className={`bg-neutral-900/80 border border-neutral-800 rounded-xl overflow-hidden ${compact ? 'text-xs' : ''}`}>
      {/* Header */}
      {!compact && (
        <div className="p-3 border-b border-neutral-800 flex items-center justify-between">
          <h4 className="text-sm font-medium text-white">
            {profileType === 'front' ? 'Front' : 'Side'} Profile
          </h4>
          <div className="flex items-center gap-1">
            {/* Landmark toggle */}
            <button
              onClick={() => setShowAllLandmarks(!showAllLandmarks)}
              className={`p-1.5 rounded transition-colors ${
                showAllLandmarks
                  ? 'bg-cyan-500/20 text-cyan-400'
                  : 'hover:bg-neutral-800 text-neutral-500'
              }`}
              title={showAllLandmarks ? 'Hide all landmarks' : 'Show all landmarks'}
            >
              <Crosshair size={16} />
            </button>

            <div className="w-px h-4 bg-neutral-700 mx-1" />

            <button
              onClick={() => setZoom(z => Math.max(1, z - 0.25))}
              className="p-1.5 hover:bg-neutral-800 rounded transition-colors"
              disabled={zoom <= 1}
            >
              <ZoomOut size={16} className={zoom <= 1 ? 'text-neutral-700' : 'text-neutral-500'} />
            </button>
            <span className="text-xs text-neutral-500 w-10 text-center">{Math.round(zoom * 100)}%</span>
            <button
              onClick={() => setZoom(z => Math.min(2, z + 0.25))}
              className="p-1.5 hover:bg-neutral-800 rounded transition-colors"
              disabled={zoom >= 2}
            >
              <ZoomIn size={16} className={zoom >= 2 ? 'text-neutral-700' : 'text-neutral-500'} />
            </button>
            {zoom !== 1 && (
              <button
                onClick={() => setZoom(1)}
                className="p-1.5 hover:bg-neutral-800 rounded transition-colors ml-1"
              >
                <Maximize2 size={16} className="text-neutral-500" />
              </button>
            )}
          </div>
        </div>
      )}

      {/* Image container */}
      <div
        ref={containerRef}
        className={`relative ${compact ? 'aspect-square' : 'aspect-[3/4]'} bg-neutral-950 overflow-hidden`}
      >
        {/* Photo with zoom */}
        <div
          className="absolute inset-0 transition-transform duration-200 ease-out"
          style={{
            transform: `scale(${zoom})`,
            transformOrigin: 'center center'
          }}
        >
          <Image
            src={photo}
            alt={`${profileType} profile`}
            fill
            className="object-contain"
            unoptimized
          />

          {/* SVG Overlay - matches object-contain positioning */}
          <svg
            className="absolute inset-0 w-full h-full pointer-events-none"
            viewBox={viewBoxDimensions.viewBox}
            preserveAspectRatio="xMidYMid meet"
          >
            {/* Defs for filters and gradients */}
            <defs>
              <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
                <feGaussianBlur stdDeviation="0.5" result="coloredBlur"/>
                <feMerge>
                  <feMergeNode in="coloredBlur"/>
                  <feMergeNode in="SourceGraphic"/>
                </feMerge>
              </filter>
              <filter id="dropShadow" x="-50%" y="-50%" width="200%" height="200%">
                <feDropShadow dx="0" dy="0" stdDeviation="0.3" floodOpacity="0.8"/>
              </filter>
            </defs>

            {/* All landmarks (optional) */}
            {showAllLandmarks && landmarks.map((landmark) => {
              const { width: vbW, height: vbH } = viewBoxDimensions;
              const baseSize = Math.max(vbW, vbH);

              return (
                <g key={landmark.id}>
                  {/* Outer glow */}
                  <circle
                    cx={landmark.x * vbW}
                    cy={landmark.y * vbH}
                    r={baseSize * 0.012}
                    fill="#67e8f9"
                    opacity="0.25"
                  />
                  {/* Main point */}
                  <circle
                    cx={landmark.x * vbW}
                    cy={landmark.y * vbH}
                    r={baseSize * 0.005}
                    fill="#67e8f9"
                    stroke="#0e7490"
                    strokeWidth={baseSize * 0.002}
                  />
                </g>
              );
            })}

            {/* Selected ratio visualization */}
            <AnimatePresence>
              {visualizationData && (() => {
                // Calculate relative sizes based on viewBox
                const { width: vbW, height: vbH } = viewBoxDimensions;
                const baseSize = Math.max(vbW, vbH);
                const strokeGlow = baseSize * 0.012;
                const strokeMain = baseSize * 0.005;
                const fontSize = baseSize * 0.02;
                const pointRadiusOuter = baseSize * 0.02;
                const pointRadiusRing = baseSize * 0.012;
                const pointRadiusInner = baseSize * 0.006;
                const arcRadius = baseSize * 0.05;

                return (
                  <g filter="url(#glow)">
                    {/* Lines with glow effect */}
                    {visualizationData.lines.map((line, i) => (
                      <g key={`line-group-${i}`}>
                        {/* Glow/shadow line */}
                        <motion.line
                          x1={line.x1}
                          y1={line.y1}
                          x2={line.x2}
                          y2={line.y2}
                          stroke={line.color}
                          strokeWidth={strokeGlow}
                          strokeLinecap="round"
                          opacity="0.3"
                          initial={{ pathLength: 0 }}
                          animate={{ pathLength: 1 }}
                          exit={{ pathLength: 0 }}
                          transition={{ duration: 0.5 }}
                        />
                        {/* Main line */}
                        <motion.line
                          x1={line.x1}
                          y1={line.y1}
                          x2={line.x2}
                          y2={line.y2}
                          stroke={line.color}
                          strokeWidth={strokeMain}
                          strokeLinecap="round"
                          initial={{ pathLength: 0, opacity: 0 }}
                          animate={{ pathLength: 1, opacity: 1 }}
                          exit={{ pathLength: 0, opacity: 0 }}
                          transition={{ duration: 0.5 }}
                        />
                        {/* Line label */}
                        {line.label && !compact && (
                          <motion.g
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            transition={{ delay: 0.3 }}
                          >
                            {(() => {
                              const labelPos = getLabelPosition(
                                line.x1, line.y1, line.x2, line.y2,
                                line.labelPosition || 'middle'
                              );
                              const labelPadding = fontSize * 0.5;
                              return (
                                <>
                                  {/* Label background */}
                                  <rect
                                    x={labelPos.x - labelPadding}
                                    y={labelPos.y - fontSize * 0.7}
                                    width={line.label.length * fontSize * 0.65 + labelPadding * 2}
                                    height={fontSize * 1.4}
                                    fill="rgba(0,0,0,0.75)"
                                    rx={fontSize * 0.2}
                                  />
                                  {/* Label text */}
                                  <text
                                    x={labelPos.x}
                                    y={labelPos.y}
                                    fill={line.color}
                                    fontSize={fontSize}
                                    fontWeight="600"
                                    fontFamily="system-ui, sans-serif"
                                    dominantBaseline="middle"
                                    textAnchor="start"
                                  >
                                    {line.label}
                                  </text>
                                </>
                              );
                            })()}
                          </motion.g>
                        )}
                      </g>
                    ))}

                    {/* Angle arcs */}
                    {visualizationData.angles.map((angle, i) => (
                      <motion.g key={`angle-${i}`}>
                        {/* Arc */}
                        <motion.path
                          d={generateArcPath(angle.vertex, angle.p1, angle.p2, arcRadius)}
                          fill="none"
                          stroke={angle.color}
                          strokeWidth={strokeMain * 0.8}
                          strokeDasharray={`${baseSize * 0.01} ${baseSize * 0.005}`}
                          initial={{ pathLength: 0, opacity: 0 }}
                          animate={{ pathLength: 1, opacity: 0.8 }}
                          exit={{ pathLength: 0, opacity: 0 }}
                          transition={{ duration: 0.5, delay: 0.2 }}
                        />
                        {/* Angle value label */}
                        {!compact && (
                          <motion.g
                            initial={{ opacity: 0, scale: 0 }}
                            animate={{ opacity: 1, scale: 1 }}
                            exit={{ opacity: 0, scale: 0 }}
                            transition={{ delay: 0.5 }}
                          >
                            <rect
                              x={angle.vertex.x + fontSize}
                              y={angle.vertex.y - fontSize * 1.5}
                              width={fontSize * 2.8}
                              height={fontSize * 1.4}
                              fill="rgba(0,0,0,0.8)"
                              rx={fontSize * 0.2}
                            />
                            <text
                              x={angle.vertex.x + fontSize * 2.4}
                              y={angle.vertex.y - fontSize * 0.8}
                              fill={angle.color}
                              fontSize={fontSize}
                              fontWeight="bold"
                              fontFamily="system-ui, sans-serif"
                              textAnchor="middle"
                              dominantBaseline="middle"
                            >
                              {Math.round(angle.angle)}°
                            </text>
                          </motion.g>
                        )}
                      </motion.g>
                    ))}

                    {/* Points with enhanced styling */}
                    {visualizationData.points.map((point, i) => (
                      <motion.g
                        key={`point-${i}`}
                        initial={{ scale: 0, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        exit={{ scale: 0, opacity: 0 }}
                        transition={{ duration: 0.3, delay: i * 0.05 }}
                      >
                        {/* Outer glow pulse */}
                        <motion.circle
                          cx={point.x}
                          cy={point.y}
                          r={pointRadiusOuter}
                          fill={getCategoryColor(selectedRatio?.category || '')}
                          opacity="0.15"
                          animate={{
                            r: [pointRadiusOuter, pointRadiusOuter * 1.25, pointRadiusOuter],
                            opacity: [0.15, 0.25, 0.15]
                          }}
                          transition={{
                            duration: 2,
                            repeat: Infinity,
                            ease: "easeInOut"
                          }}
                        />
                        {/* Outer ring */}
                        <circle
                          cx={point.x}
                          cy={point.y}
                          r={pointRadiusRing}
                          fill="none"
                          stroke={getCategoryColor(selectedRatio?.category || '')}
                          strokeWidth={pointRadiusInner * 0.3}
                          opacity="0.5"
                        />
                        {/* Inner dot */}
                        <circle
                          cx={point.x}
                          cy={point.y}
                          r={pointRadiusInner}
                          fill="#fff"
                          stroke={getCategoryColor(selectedRatio?.category || '')}
                          strokeWidth={pointRadiusInner * 0.25}
                        />
                      </motion.g>
                    ))}
                  </g>
                );
              })()}
            </AnimatePresence>
          </svg>
        </div>

        {/* No selection message */}
        {!selectedRatio && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/40">
            <div className="text-center p-4">
              <Eye size={compact ? 24 : 32} className="mx-auto text-neutral-600 mb-2" />
              <p className={`text-neutral-500 ${compact ? 'text-xs' : 'text-sm'}`}>
                {compact ? 'Click a ratio to visualize' : 'Expand a measurement card\nto see it visualized here'}
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Selected ratio info */}
      {selectedRatio && !compact && (
        <motion.div
          className="p-3 border-t border-neutral-800"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <div className="flex items-center justify-between">
            <div>
              <h5 className="text-sm font-medium text-white">{selectedRatio.name}</h5>
              <p className="text-xs text-neutral-500">{selectedRatio.category}</p>
            </div>
            <div
              className="px-2 py-1 rounded text-sm font-bold"
              style={{
                backgroundColor: `${getScoreColor(selectedRatio.score)}15`,
                color: getScoreColor(selectedRatio.score),
              }}
            >
              {selectedRatio.score.toFixed(1)}
            </div>
          </div>

          {/* Landmarks used */}
          {selectedRatio.usedLandmarks && selectedRatio.usedLandmarks.length > 0 && (
            <div className="mt-2">
              <p className="text-xs text-neutral-500 mb-1">Landmarks used:</p>
              <div className="flex flex-wrap gap-1">
                {selectedRatio.usedLandmarks.slice(0, 4).map(id => {
                  const landmark = landmarkMap[id];
                  return (
                    <span
                      key={id}
                      className="px-1.5 py-0.5 bg-neutral-800 rounded text-[10px] text-neutral-400"
                    >
                      {landmark?.label || id}
                    </span>
                  );
                })}
                {selectedRatio.usedLandmarks.length > 4 && (
                  <span className="px-1.5 py-0.5 text-[10px] text-neutral-500">
                    +{selectedRatio.usedLandmarks.length - 4} more
                  </span>
                )}
              </div>
            </div>
          )}
        </motion.div>
      )}

      {/* Compact info bar */}
      {selectedRatio && compact && (
        <div className="px-2 py-1.5 border-t border-neutral-800 flex items-center justify-between">
          <span className="text-xs text-white truncate">{selectedRatio.name}</span>
          <span
            className="text-xs font-bold ml-2"
            style={{ color: getScoreColor(selectedRatio.score) }}
          >
            {selectedRatio.score.toFixed(1)}
          </span>
        </div>
      )}
    </div>
  );
}
