'use client';

import { motion } from 'framer-motion';
import { User, ScanFace, Sparkles, ChevronRight } from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { TabContent } from '../ResultsLayout';
import { ScoreBar, AnimatedScore, ShareButton, ExportButton } from '../shared';
import { KeyStrengthsSection, AreasOfImprovementSection } from '../cards/KeyStrengthsFlaws';
import { FacialRadarChart } from '../visualization/FacialRadarChart';
import { RatioDetailModal } from '../modals/RatioDetailModal';
import { getScoreColor, ResponsibleRatio, Ratio } from '@/types/results';
import { FaceIQScoreResult } from '@/lib/faceiq-scoring';
import { useState, useCallback, useMemo } from 'react';

// ============================================
// SCORE SUMMARY CARDS
// ============================================

interface ProfileScoreCardProps {
  title: string;
  score: number;
  icon: React.ReactNode;
  photo?: string;
  ratioCount: number;
  onClick?: () => void;
}

function ProfileScoreCard({ title, score, icon, photo, ratioCount, onClick }: ProfileScoreCardProps) {
  const color = getScoreColor(score);

  return (
    <motion.button
      onClick={onClick}
      className="bg-neutral-900/80 border border-neutral-800 rounded-xl p-4 hover:border-neutral-700 transition-all text-left w-full"
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
    >
      <div className="flex items-center gap-4">
        {/* Photo or icon */}
        <div className="relative w-16 h-16 rounded-lg overflow-hidden bg-neutral-800 flex-shrink-0">
          {photo ? (
            <img src={photo} alt={title} className="w-full h-full object-cover" />
          ) : (
            <div className="w-full h-full flex items-center justify-center">
              {icon}
            </div>
          )}
        </div>

        {/* Info */}
        <div className="flex-1">
          <h3 className="text-sm font-medium text-neutral-400 mb-1">{title}</h3>
          <div className="flex items-baseline gap-2">
            <span className="text-2xl font-bold" style={{ color }}>
              {score.toFixed(2)}
            </span>
            <span className="text-sm text-neutral-500">/ 10</span>
          </div>
          <p className="text-xs text-neutral-500 mt-1">{ratioCount} measurements</p>
        </div>

        {/* Arrow */}
        <ChevronRight size={20} className="text-neutral-600" />
      </div>

      {/* Score bar */}
      <div className="mt-3">
        <ScoreBar score={score} height={6} />
      </div>
    </motion.button>
  );
}

// ============================================
// HARMONY SCORE DISPLAY (with AnimatedScore and Radar Chart)
// ============================================

function HarmonyScoreDisplay() {
  const { overallScore, frontScore, sideScore } = useResults();
  const [showRadar, setShowRadar] = useState(true);

  return (
    <motion.div
      className="bg-gradient-to-br from-neutral-900 to-neutral-950 border border-neutral-800 rounded-2xl p-6 md:p-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
    >
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Left: Score Display */}
        <div className="text-center flex flex-col justify-center">
          <h2 className="text-lg font-medium text-neutral-400 mb-6">Overall Harmony Score</h2>

          {/* Animated Score */}
          <div className="flex justify-center mb-6">
            <AnimatedScore
              score={overallScore}
              duration={2.5}
              delay={0.5}
              showConfetti={true}
              confettiThreshold={7.5}
            />
          </div>

          {/* Profile Breakdowns */}
          <div className="flex justify-center gap-8 mb-4">
            <div className="text-center">
              <p className="text-xs text-neutral-500 mb-1">Front Profile</p>
              <p className="text-xl font-bold" style={{ color: getScoreColor(frontScore) }}>
                {frontScore.toFixed(2)}
              </p>
            </div>
            <div className="w-px bg-neutral-800" />
            <div className="text-center">
              <p className="text-xs text-neutral-500 mb-1">Side Profile</p>
              <p className="text-xl font-bold" style={{ color: getScoreColor(sideScore) }}>
                {sideScore.toFixed(2)}
              </p>
            </div>
          </div>

          <p className="text-sm text-neutral-400 max-w-md mx-auto">
            {overallScore >= 8 ? 'Exceptional facial harmony. Your features are well-balanced and proportioned.' :
              overallScore >= 6 ? 'Good facial harmony with some areas that could be optimized.' :
                overallScore >= 4 ? 'Average facial harmony. Several areas have room for improvement.' :
                  'Below average facial harmony. Multiple areas could benefit from attention.'}
          </p>
        </div>

        {/* Right: Radar Chart */}
        <div className="flex flex-col">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-sm font-medium text-neutral-400">Category Breakdown</h3>
            <button
              onClick={() => setShowRadar(!showRadar)}
              className="text-xs text-cyan-400 hover:text-cyan-300 transition-colors"
            >
              {showRadar ? 'Hide' : 'Show'}
            </button>
          </div>
          {showRadar && (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, delay: 0.3 }}
              className="flex-1 min-h-[280px]"
            >
              <FacialRadarChart height={280} />
            </motion.div>
          )}
        </div>
      </div>
    </motion.div>
  );
}

// ============================================
// OVERVIEW TAB
// ============================================

export function OverviewTab() {
  const {
    overallScore,
    frontScore,
    sideScore,
    frontRatios,
    sideRatios,
    strengths,
    flaws,
    frontPhoto,
    sidePhoto,
    gender,
    ethnicity,
    setActiveTab,
  } = useResults();

  const [selectedRatio, setSelectedRatio] = useState<FaceIQScoreResult | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  // All ratios combined for modal navigation
  const allRatios = useMemo(() => [...frontRatios, ...sideRatios], [frontRatios, sideRatios]);

  // Current ratio index for navigation
  const currentRatioIndex = useMemo(() => {
    if (!selectedRatio) return -1;
    return allRatios.findIndex(r => r.id === selectedRatio.metricId);
  }, [selectedRatio, allRatios]);

  // Convert Ratio to FaceIQScoreResult for modal
  const ratioToFaceIQResult = useCallback((ratio: Ratio): FaceIQScoreResult => {
    return {
      metricId: ratio.id,
      name: ratio.name,
      value: ratio.value,
      score: ratio.score,
      standardizedScore: ratio.standardizedScore,
      idealMin: ratio.idealMin,
      idealMax: ratio.idealMax,
      deviation: 0,
      deviationDirection: 'within',
      unit: ratio.unit === 'x' ? 'ratio' : ratio.unit === '%' ? 'percent' : ratio.unit === '°' ? 'degrees' : ratio.unit,
      category: ratio.category,
      qualityTier: ratio.qualityLevel,
      severity: ratio.severity,
    } as FaceIQScoreResult;
  }, []);

  // Handle ratio click from strengths/flaws sections
  const handleRatioClick = useCallback((ratio: ResponsibleRatio, categoryName: string) => {
    // Find the full ratio data from frontRatios or sideRatios
    const fullRatio = allRatios.find(
      (r) => r.name === ratio.ratioName || r.id === ratio.ratioId
    );

    if (fullRatio) {
      setSelectedRatio(ratioToFaceIQResult(fullRatio));
    } else {
      // Create a minimal FaceIQScoreResult from ResponsibleRatio
      setSelectedRatio({
        metricId: ratio.ratioId,
        name: ratio.ratioName,
        value: ratio.value,
        score: ratio.score,
        standardizedScore: ratio.score,
        idealMin: ratio.idealMin,
        idealMax: ratio.idealMax,
        deviation: 0,
        deviationDirection: 'within',
        unit: (ratio.unit as 'ratio' | 'percent' | 'degrees' | 'mm' | 'none') || 'ratio',
        category: ratio.category || categoryName,
        qualityTier: ratio.score >= 8 ? 'ideal' : ratio.score >= 6 ? 'excellent' : ratio.score >= 4 ? 'good' : 'below_average',
        severity: 'optimal',
      } as FaceIQScoreResult);
    }
    setIsModalOpen(true);
  }, [allRatios, ratioToFaceIQResult]);

  // Navigate to previous/next ratio in modal
  const handlePreviousRatio = useCallback(() => {
    if (currentRatioIndex > 0) {
      setSelectedRatio(ratioToFaceIQResult(allRatios[currentRatioIndex - 1]));
    }
  }, [currentRatioIndex, allRatios, ratioToFaceIQResult]);

  const handleNextRatio = useCallback(() => {
    if (currentRatioIndex < allRatios.length - 1) {
      setSelectedRatio(ratioToFaceIQResult(allRatios[currentRatioIndex + 1]));
    }
  }, [currentRatioIndex, allRatios, ratioToFaceIQResult]);

  // Get appropriate face photo for modal
  const getModalPhoto = useCallback(() => {
    if (!selectedRatio) return frontPhoto;

    // Check if this is a side profile metric
    const sideMetricIds = sideRatios.map(r => r.id);
    if (sideMetricIds.includes(selectedRatio.metricId)) {
      return sidePhoto || frontPhoto;
    }
    return frontPhoto;
  }, [selectedRatio, sideRatios, frontPhoto, sidePhoto]);

  return (
    <TabContent
      title="Overview"
      subtitle="Your complete facial harmony analysis"
      rightContent={
        <div className="flex items-center gap-2">
          <ShareButton score={overallScore} frontScore={frontScore} sideScore={sideScore} />
          <ExportButton elementId="results-overview" />
        </div>
      }
    >
      {/* Main content with ID for export */}
      <div id="results-overview">
        {/* Harmony Score */}
        <div className="mb-8">
          <HarmonyScoreDisplay />
        </div>

        {/* Profile Scores */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <ProfileScoreCard
            title="Front Profile"
            score={frontScore}
            icon={<User size={24} className="text-neutral-600" />}
            photo={frontPhoto}
            ratioCount={frontRatios.length}
            onClick={() => setActiveTab('front-ratios')}
          />
          <ProfileScoreCard
            title="Side Profile"
            score={sideScore}
            icon={<ScanFace size={24} className="text-neutral-600" />}
            photo={sidePhoto || undefined}
            ratioCount={sideRatios.length}
            onClick={() => setActiveTab('side-ratios')}
          />
        </div>

        {/* Strengths & Flaws Grid - FaceIQ Style */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* Key Strengths */}
          <KeyStrengthsSection
            strengths={strengths}
            onRatioClick={handleRatioClick}
            initialShowCount={3}
          />

          {/* Areas of Improvement */}
          <AreasOfImprovementSection
            flaws={flaws}
            onRatioClick={handleRatioClick}
            initialShowCount={3}
          />
        </div>

        {/* Call to Action */}
        <motion.div
          className="bg-gradient-to-r from-cyan-500/20 to-blue-600/20 border border-cyan-500/30 rounded-xl p-6 flex items-center justify-between"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
        >
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-cyan-500/20 flex items-center justify-center">
              <Sparkles size={24} className="text-cyan-400" />
            </div>
            <div>
              <h3 className="font-semibold text-white">Unlock Your Potential</h3>
              <p className="text-sm text-neutral-400">
                See personalized recommendations to improve your harmony score
              </p>
            </div>
          </div>
          <button
            onClick={() => setActiveTab('plan')}
            className="px-4 py-2 bg-cyan-500 text-black font-medium rounded-lg hover:bg-cyan-400 transition-colors flex items-center gap-2"
          >
            View Plan
            <ChevronRight size={16} />
          </button>
        </motion.div>
      </div>{/* End of results-overview */}

      {/* Ratio Detail Modal */}
      <RatioDetailModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        ratio={selectedRatio}
        onPrevious={handlePreviousRatio}
        onNext={handleNextRatio}
        hasPrevious={currentRatioIndex > 0}
        hasNext={currentRatioIndex < allRatios.length - 1}
        facePhoto={getModalPhoto()}
        gender={gender}
        ethnicity={ethnicity}
      />
    </TabContent>
  );
}
