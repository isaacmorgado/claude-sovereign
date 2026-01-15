'use client';

import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Trophy, User, TrendingUp, TrendingDown, CheckCircle, AlertCircle } from 'lucide-react';
import { useLeaderboard } from '@/contexts/LeaderboardContext';
import { ScoreCircle } from '../shared';

interface UserProfileModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function UserProfileModal({ isOpen, onClose }: UserProfileModalProps) {
  const { selectedProfile, setSelectedUserId } = useLeaderboard();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    return () => setMounted(false);
  }, []);

  // Handle escape key
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = 'auto';
    };
  }, [isOpen, onClose]);

  const handleClose = () => {
    setSelectedUserId(null);
    onClose();
  };

  if (!mounted) return null;

  const isLoading = isOpen && !selectedProfile;

  const modalContent = (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-50 flex items-center justify-center p-4"
          onClick={handleClose}
        >
          {/* Backdrop */}
          <div className="absolute inset-0 bg-black/80 backdrop-blur-sm" />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            transition={{ type: 'spring', duration: 0.3 }}
            className="relative w-full max-w-md bg-neutral-900 border border-neutral-800 rounded-2xl overflow-hidden"
            onClick={(e) => e.stopPropagation()}
          >
            {isLoading ? (
              /* Loading State */
              <div className="p-8 flex flex-col items-center justify-center">
                <div className="w-10 h-10 border-2 border-cyan-500 border-t-transparent rounded-full animate-spin mb-4" />
                <p className="text-neutral-400">Loading profile...</p>
              </div>
            ) : selectedProfile ? (
              <>
                {/* Header */}
                <div className="flex items-center justify-between p-4 border-b border-neutral-800">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-yellow-500/20 to-amber-500/20 border border-yellow-500/30 flex items-center justify-center">
                      <Trophy size={18} className="text-yellow-400" />
                    </div>
                    <div>
                      <h2 className="font-semibold text-white">{selectedProfile.anonymousName}</h2>
                      <p className="text-xs text-neutral-500 capitalize">{selectedProfile.gender}</p>
                    </div>
                  </div>
                  <button
                    onClick={handleClose}
                    className="p-2 hover:bg-neutral-800 rounded-lg transition-colors"
                  >
                    <X size={20} className="text-neutral-400" />
                  </button>
                </div>

            {/* Profile Content */}
            <div className="p-6 space-y-6">
              {/* Face Photo + Score */}
              <div className="flex items-center gap-6">
                {/* Face Photo */}
                <div className="relative w-24 h-24 rounded-xl overflow-hidden bg-neutral-800 border border-neutral-700 flex-shrink-0">
                  {selectedProfile.facePhotoUrl ? (
                    <img
                      src={selectedProfile.facePhotoUrl}
                      alt={selectedProfile.anonymousName}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center">
                      <User size={40} className="text-neutral-600" />
                    </div>
                  )}
                </div>

                {/* Stats */}
                <div className="flex-1 space-y-3">
                  <div className="flex items-center gap-4">
                    <ScoreCircle score={selectedProfile.score} size="md" animate={false} />
                    <div>
                      <div className="flex items-center gap-2">
                        <Trophy size={16} className="text-yellow-400" />
                        <span className="text-xl font-bold text-white">#{selectedProfile.rank}</span>
                      </div>
                      <p className="text-sm text-neutral-500">Global Rank</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Strengths */}
              {selectedProfile.topStrengths.length > 0 && (
                <div>
                  <div className="flex items-center gap-2 mb-3">
                    <TrendingUp size={16} className="text-green-400" />
                    <h3 className="font-medium text-white">Top Strengths</h3>
                  </div>
                  <div className="space-y-2">
                    {selectedProfile.topStrengths.map((strength, index) => (
                      <div
                        key={index}
                        className="flex items-center gap-3 px-3 py-2 bg-green-500/10 border border-green-500/20 rounded-lg"
                      >
                        <CheckCircle size={14} className="text-green-400 flex-shrink-0" />
                        <span className="text-sm text-green-300">{strength}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Areas to Improve */}
              {selectedProfile.topImprovements.length > 0 && (
                <div>
                  <div className="flex items-center gap-2 mb-3">
                    <TrendingDown size={16} className="text-amber-400" />
                    <h3 className="font-medium text-white">Areas to Improve</h3>
                  </div>
                  <div className="space-y-2">
                    {selectedProfile.topImprovements.map((improvement, index) => (
                      <div
                        key={index}
                        className="flex items-center gap-3 px-3 py-2 bg-amber-500/10 border border-amber-500/20 rounded-lg"
                      >
                        <AlertCircle size={14} className="text-amber-400 flex-shrink-0" />
                        <span className="text-sm text-amber-300">{improvement}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
              </>
            ) : null}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );

  return createPortal(modalContent, document.body);
}
