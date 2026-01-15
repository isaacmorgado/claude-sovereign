'use client';

import { useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Eye, ZoomIn, ZoomOut } from 'lucide-react';
import { LandmarkPoint } from '@/lib/landmarks';
import { Ratio, getScoreColor, getCategoryColor } from '@/types/results';

interface FaceOverlayProps {
  photo: string;
  landmarks: LandmarkPoint[];
  selectedRatio: Ratio | null;
  profileType: 'front' | 'side';
  showAllLandmarks?: boolean;
}

export function FaceOverlay({
  photo,
  landmarks,
  selectedRatio,
  profileType,
  showAllLandmarks = false,
}: FaceOverlayProps) {
  // Get landmark positions by ID
  const landmarkMap = useMemo(() => {
    const map: Record<string, LandmarkPoint> = {};
    landmarks.forEach(l => {
      map[l.id] = l;
    });
    return map;
  }, [landmarks]);

  // Get lines and points to draw for selected ratio
  const visualizationData = useMemo(() => {
    if (!selectedRatio?.illustration) return null;

    const points: Array<{ x: number; y: number; id: string; label?: string }> = [];
    const lines: Array<{ x1: number; y1: number; x2: number; y2: number; color: string }> = [];

    // Process points
    Object.entries(selectedRatio.illustration.points).forEach(([key, point]) => {
      if (point.type === 'landmark' && point.landmarkId) {
        const landmark = landmarkMap[point.landmarkId];
        if (landmark) {
          points.push({
            x: landmark.x * 100,
            y: landmark.y * 100,
            id: point.landmarkId,
            label: landmark.label,
          });
        }
      } else if (point.x !== undefined && point.y !== undefined) {
        points.push({
          x: point.x * 100,
          y: point.y * 100,
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
          x1: fromLandmark.x * 100,
          y1: fromLandmark.y * 100,
          x2: toLandmark.x * 100,
          y2: toLandmark.y * 100,
          color: line.color || getCategoryColor(selectedRatio.category),
        });
      }
    });

    return { points, lines };
  }, [selectedRatio, landmarkMap]);

  return (
    <div className="bg-neutral-900/80 border border-neutral-800 rounded-xl overflow-hidden">
      {/* Header */}
      <div className="p-3 border-b border-neutral-800 flex items-center justify-between">
        <h4 className="text-sm font-medium text-white">
          {profileType === 'front' ? 'Front' : 'Side'} Profile
        </h4>
        <div className="flex items-center gap-2">
          <button className="p-1.5 hover:bg-neutral-800 rounded transition-colors">
            <ZoomIn size={16} className="text-neutral-500" />
          </button>
          <button className="p-1.5 hover:bg-neutral-800 rounded transition-colors">
            <ZoomOut size={16} className="text-neutral-500" />
          </button>
        </div>
      </div>

      {/* Image container */}
      <div className="relative aspect-[3/4] bg-neutral-950">
        {/* Photo */}
        <img
          src={photo}
          alt={`${profileType} profile`}
          className="w-full h-full object-cover"
        />

        {/* SVG Overlay */}
        <svg
          className="absolute inset-0 w-full h-full"
          viewBox="0 0 100 100"
          preserveAspectRatio="none"
        >
          {/* All landmarks (optional) */}
          {showAllLandmarks && landmarks.map((landmark) => (
            <circle
              key={landmark.id}
              cx={landmark.x * 100}
              cy={landmark.y * 100}
              r="0.5"
              fill="#67e8f9"
              opacity="0.3"
            />
          ))}

          {/* Selected ratio visualization */}
          <AnimatePresence>
            {visualizationData && (
              <g>
                {/* Lines */}
                {visualizationData.lines.map((line, i) => (
                  <motion.line
                    key={`line-${i}`}
                    x1={line.x1}
                    y1={line.y1}
                    x2={line.x2}
                    y2={line.y2}
                    stroke={line.color}
                    strokeWidth="0.4"
                    strokeLinecap="round"
                    initial={{ pathLength: 0, opacity: 0 }}
                    animate={{ pathLength: 1, opacity: 1 }}
                    exit={{ pathLength: 0, opacity: 0 }}
                    transition={{ duration: 0.5 }}
                  />
                ))}

                {/* Points */}
                {visualizationData.points.map((point, i) => (
                  <motion.g
                    key={`point-${i}`}
                    initial={{ scale: 0, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    exit={{ scale: 0, opacity: 0 }}
                    transition={{ duration: 0.3, delay: i * 0.1 }}
                  >
                    {/* Outer glow */}
                    <circle
                      cx={point.x}
                      cy={point.y}
                      r="1.5"
                      fill={getCategoryColor(selectedRatio?.category || '')}
                      opacity="0.3"
                    />
                    {/* Inner dot */}
                    <circle
                      cx={point.x}
                      cy={point.y}
                      r="0.8"
                      fill="#fff"
                      stroke={getCategoryColor(selectedRatio?.category || '')}
                      strokeWidth="0.2"
                    />
                  </motion.g>
                ))}
              </g>
            )}
          </AnimatePresence>
        </svg>

        {/* No selection message */}
        {!selectedRatio && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/40">
            <div className="text-center p-4">
              <Eye size={32} className="mx-auto text-neutral-600 mb-2" />
              <p className="text-sm text-neutral-500">
                Expand a measurement card<br />to see it visualized here
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Selected ratio info */}
      {selectedRatio && (
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
          {selectedRatio.usedLandmarks.length > 0 && (
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
    </div>
  );
}
