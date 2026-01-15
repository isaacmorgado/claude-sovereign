'use client';

import { useState, useRef, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Camera,
  Upload,
  TrendingUp,
  TrendingDown,
  Minus,
  RefreshCw,
  X,
  CheckCircle,
  ArrowRight,
} from 'lucide-react';
import Image from 'next/image';

interface ProgressAnalysis {
  date: string;
  overallScore: number;
  bodyFatPercent?: number;
  frontPhotoUrl?: string;
}

interface ProgressComparisonCardProps {
  currentAnalysis: ProgressAnalysis;
  previousAnalysis?: ProgressAnalysis | null;
  onUploadNewPhoto: (file: File) => Promise<void>;
  isAnalyzing?: boolean;
}

export function ProgressComparisonCard({
  currentAnalysis,
  previousAnalysis,
  onUploadNewPhoto,
  isAnalyzing = false,
}: ProgressComparisonCardProps) {
  const [showUpload, setShowUpload] = useState(false);
  const [uploadPreview, setUploadPreview] = useState<string | null>(null);
  const [uploadFile, setUploadFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setUploadFile(file);
      const reader = new FileReader();
      reader.onload = () => {
        setUploadPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  }, []);

  const handleUpload = async () => {
    if (!uploadFile) return;

    setIsUploading(true);
    try {
      await onUploadNewPhoto(uploadFile);
      setShowUpload(false);
      setUploadPreview(null);
      setUploadFile(null);
    } catch (error) {
      console.error('Upload failed:', error);
    } finally {
      setIsUploading(false);
    }
  };

  const cancelUpload = () => {
    setShowUpload(false);
    setUploadPreview(null);
    setUploadFile(null);
  };

  // Calculate improvement
  const scoreDiff = previousAnalysis
    ? currentAnalysis.overallScore - previousAnalysis.overallScore
    : 0;

  const bodyFatDiff = previousAnalysis?.bodyFatPercent && currentAnalysis.bodyFatPercent
    ? currentAnalysis.bodyFatPercent - previousAnalysis.bodyFatPercent
    : 0;

  const hasImproved = scoreDiff > 0;
  const hasDeclined = scoreDiff < 0;

  return (
    <motion.div
      className="bg-gradient-to-br from-neutral-900 to-neutral-950 border border-neutral-800 rounded-2xl p-6 overflow-hidden"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Camera size={20} className="text-cyan-400" />
          <h3 className="font-semibold text-white">Track Your Progress</h3>
        </div>
        {!showUpload && (
          <button
            onClick={() => setShowUpload(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-cyan-500/10 text-cyan-400 text-sm font-medium rounded-lg hover:bg-cyan-500/20 transition-colors"
          >
            <Upload size={14} />
            New Photo
          </button>
        )}
      </div>

      {/* Upload Mode */}
      <AnimatePresence>
        {showUpload && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="space-y-4"
          >
            {!uploadPreview ? (
              <div
                onClick={() => fileInputRef.current?.click()}
                className="border-2 border-dashed border-neutral-700 rounded-xl p-8 text-center cursor-pointer hover:border-cyan-500/50 transition-colors"
              >
                <Camera size={32} className="mx-auto text-neutral-500 mb-3" />
                <p className="text-neutral-400 text-sm mb-1">
                  Upload a new photo to compare
                </p>
                <p className="text-neutral-600 text-xs">
                  JPG, PNG or HEIC - Max 10MB
                </p>
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleFileSelect}
                  className="hidden"
                />
              </div>
            ) : (
              <div className="space-y-4">
                <div className="relative aspect-square max-w-[200px] mx-auto rounded-xl overflow-hidden">
                  <Image
                    src={uploadPreview}
                    alt="Upload preview"
                    fill
                    className="object-cover"
                  />
                  <button
                    onClick={cancelUpload}
                    className="absolute top-2 right-2 p-1.5 bg-black/50 rounded-full hover:bg-black/70 transition-colors"
                  >
                    <X size={14} className="text-white" />
                  </button>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={cancelUpload}
                    className="flex-1 py-2.5 bg-neutral-800 text-neutral-300 text-sm font-medium rounded-lg hover:bg-neutral-700 transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleUpload}
                    disabled={isUploading}
                    className="flex-1 flex items-center justify-center gap-2 py-2.5 bg-cyan-500 text-black text-sm font-medium rounded-lg hover:bg-cyan-400 transition-colors disabled:opacity-50"
                  >
                    {isUploading ? (
                      <>
                        <RefreshCw size={14} className="animate-spin" />
                        Analyzing...
                      </>
                    ) : (
                      <>
                        <CheckCircle size={14} />
                        Analyze
                      </>
                    )}
                  </button>
                </div>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Comparison View */}
      {!showUpload && (
        <div className="space-y-4">
          {previousAnalysis ? (
            <>
              {/* Side by Side Photos */}
              <div className="grid grid-cols-2 gap-4">
                {/* Previous */}
                <div className="space-y-2">
                  <p className="text-xs text-neutral-500 text-center">Previous</p>
                  <div className="relative aspect-square rounded-xl overflow-hidden bg-neutral-800">
                    {previousAnalysis.frontPhotoUrl ? (
                      <Image
                        src={previousAnalysis.frontPhotoUrl}
                        alt="Previous analysis"
                        fill
                        className="object-cover opacity-80"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Camera size={24} className="text-neutral-600" />
                      </div>
                    )}
                    <div className="absolute bottom-2 left-1/2 -translate-x-1/2 px-2 py-1 bg-black/70 rounded-lg">
                      <span className="text-sm font-semibold text-white">
                        {previousAnalysis.overallScore.toFixed(1)}
                      </span>
                    </div>
                  </div>
                  <p className="text-xs text-neutral-500 text-center">
                    {new Date(previousAnalysis.date).toLocaleDateString()}
                  </p>
                </div>

                {/* Current */}
                <div className="space-y-2">
                  <p className="text-xs text-neutral-500 text-center">Current</p>
                  <div className="relative aspect-square rounded-xl overflow-hidden bg-neutral-800 ring-2 ring-cyan-500/50">
                    {currentAnalysis.frontPhotoUrl ? (
                      <Image
                        src={currentAnalysis.frontPhotoUrl}
                        alt="Current analysis"
                        fill
                        className="object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Camera size={24} className="text-neutral-600" />
                      </div>
                    )}
                    <div className="absolute bottom-2 left-1/2 -translate-x-1/2 px-2 py-1 bg-cyan-500/90 rounded-lg">
                      <span className="text-sm font-semibold text-black">
                        {currentAnalysis.overallScore.toFixed(1)}
                      </span>
                    </div>
                  </div>
                  <p className="text-xs text-neutral-500 text-center">
                    {new Date(currentAnalysis.date).toLocaleDateString()}
                  </p>
                </div>
              </div>

              {/* Improvement Stats */}
              <div className="grid grid-cols-2 gap-3 pt-2 border-t border-neutral-800">
                {/* Score Change */}
                <div className={`p-3 rounded-lg ${
                  hasImproved
                    ? 'bg-green-500/10 border border-green-500/20'
                    : hasDeclined
                      ? 'bg-red-500/10 border border-red-500/20'
                      : 'bg-neutral-800/50'
                }`}>
                  <div className="flex items-center gap-1.5 mb-1">
                    {hasImproved ? (
                      <TrendingUp size={14} className="text-green-400" />
                    ) : hasDeclined ? (
                      <TrendingDown size={14} className="text-red-400" />
                    ) : (
                      <Minus size={14} className="text-neutral-400" />
                    )}
                    <span className="text-xs text-neutral-400">Score</span>
                  </div>
                  <span className={`text-lg font-bold ${
                    hasImproved
                      ? 'text-green-400'
                      : hasDeclined
                        ? 'text-red-400'
                        : 'text-neutral-400'
                  }`}>
                    {scoreDiff > 0 ? '+' : ''}{scoreDiff.toFixed(1)}
                  </span>
                </div>

                {/* Body Fat Change */}
                {currentAnalysis.bodyFatPercent && (
                  <div className={`p-3 rounded-lg ${
                    bodyFatDiff < 0
                      ? 'bg-green-500/10 border border-green-500/20'
                      : bodyFatDiff > 0
                        ? 'bg-red-500/10 border border-red-500/20'
                        : 'bg-neutral-800/50'
                  }`}>
                    <div className="flex items-center gap-1.5 mb-1">
                      {bodyFatDiff < 0 ? (
                        <TrendingDown size={14} className="text-green-400" />
                      ) : bodyFatDiff > 0 ? (
                        <TrendingUp size={14} className="text-red-400" />
                      ) : (
                        <Minus size={14} className="text-neutral-400" />
                      )}
                      <span className="text-xs text-neutral-400">Body Fat</span>
                    </div>
                    <span className={`text-lg font-bold ${
                      bodyFatDiff < 0
                        ? 'text-green-400'
                        : bodyFatDiff > 0
                          ? 'text-red-400'
                          : 'text-neutral-400'
                    }`}>
                      {bodyFatDiff > 0 ? '+' : ''}{bodyFatDiff.toFixed(1)}%
                    </span>
                  </div>
                )}
              </div>

              {/* Improvement Message */}
              {hasImproved && (
                <div className="p-3 bg-green-500/10 border border-green-500/20 rounded-lg">
                  <p className="text-sm text-green-400 text-center">
                    {scoreDiff >= 0.5
                      ? 'Great progress! Your efforts are paying off.'
                      : 'Small but steady improvement. Keep going!'}
                  </p>
                </div>
              )}
            </>
          ) : (
            /* No Previous Analysis */
            <div className="text-center py-6">
              <div className="w-16 h-16 mx-auto mb-4 rounded-2xl bg-neutral-800/50 flex items-center justify-center">
                <Camera size={28} className="text-neutral-500" />
              </div>
              <h4 className="text-white font-medium mb-1">Start Tracking Progress</h4>
              <p className="text-sm text-neutral-400 mb-4">
                Upload a new photo after making changes to see your improvement over time.
              </p>
              <button
                onClick={() => setShowUpload(true)}
                className="inline-flex items-center gap-2 px-4 py-2 bg-cyan-500 text-black text-sm font-medium rounded-lg hover:bg-cyan-400 transition-colors"
              >
                <Upload size={16} />
                Upload Progress Photo
              </button>
            </div>
          )}

          {/* Tips */}
          {previousAnalysis && (
            <div className="pt-3 border-t border-neutral-800">
              <p className="text-xs text-neutral-500 flex items-center gap-1.5">
                <ArrowRight size={12} />
                Tip: Take photos in the same lighting and angle for accurate comparisons
              </p>
            </div>
          )}
        </div>
      )}

      {/* Loading Overlay */}
      <AnimatePresence>
        {isAnalyzing && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-neutral-900/90 flex items-center justify-center"
          >
            <div className="text-center">
              <RefreshCw size={32} className="mx-auto text-cyan-400 animate-spin mb-3" />
              <p className="text-white font-medium">Analyzing your progress...</p>
              <p className="text-sm text-neutral-400">This may take a moment</p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
