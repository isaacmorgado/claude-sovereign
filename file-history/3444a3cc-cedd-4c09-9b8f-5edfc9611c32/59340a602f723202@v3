'use client';

import { motion } from 'framer-motion';
import Image from 'next/image';
import { User, ScanFace, Sparkles, ChevronRight, TrendingUp, TrendingDown, Lightbulb } from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { TabContent } from '../ResultsLayout';
import { ScoreBar, AnimatedScore, ShareButton, ExportButton } from '../shared';
import { KeyStrengthsSection, AreasOfImprovementSection } from '../cards/KeyStrengthsFlaws';
import { FacialRadarChart } from '../visualization/FacialRadarChart';
import { RatioDetailModal } from '../modals/RatioDetailModal';
import { getScoreColor, ResponsibleRatio, Ratio } from '@/types/results';
import { FaceIQScoreResult } from '@/lib/faceiq-scoring';
import { RankedMetric, getWeightTierColor } from '@/lib/looksmax-scoring';
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
            <Image
              src={photo}
              alt={title}
              width={64}
              height={64}
              className="object-cover"
              unoptimized
            />
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
// QUICK INSIGHTS - TOP/BOTTOM METRICS WITH ADVICE
// ============================================

interface MetricInsightCardProps {
  metric: RankedMetric;
  type: 'strength' | 'improvement';
  index: number;
}

function MetricInsightCard({ metric, type, index }: MetricInsightCardProps) {
  const isStrength = type === 'strength';
  const color = getScoreColor(metric.score);
  const weightTierClass = getWeightTierColor(metric.weightTier);

  return (
    <motion.div
      className={`bg-neutral-900/80 border rounded-xl p-4 ${
        isStrength ? 'border-green-500/30' : 'border-orange-500/30'
      }`}
      initial={{ opacity: 0, x: isStrength ? -20 : 20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: 0.1 * index }}
    >
      <div className="flex items-start gap-3">
        <div className={`w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ${
          isStrength ? 'bg-green-500/20' : 'bg-orange-500/20'
        }`}>
          {isStrength ? (
            <TrendingUp size={16} className="text-green-400" />
          ) : (
            <TrendingDown size={16} className="text-orange-400" />
          )}
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <h4 className="font-medium text-white text-sm truncate">{metric.name}</h4>
            <span className={`text-xs px-1.5 py-0.5 rounded border ${weightTierClass}`}>
              {metric.weightTier === 'high' ? '3x' : metric.weightTier === 'medium' ? '2x' : '1x'}
            </span>
          </div>

          <div className="flex items-center gap-3 mb-2">
            <span className="text-lg font-bold" style={{ color }}>
              {metric.score.toFixed(1)}
            </span>
            <span className="text-xs text-neutral-500">
              Ideal: {metric.idealMin.toFixed(1)} - {metric.idealMax.toFixed(1)}
            </span>
          </div>

          {/* Advice */}
          <div className="flex items-start gap-2 mt-2 p-2 bg-neutral-800/50 rounded-lg">
            <Lightbulb size={14} className={isStrength ? 'text-green-400 mt-0.5' : 'text-orange-400 mt-0.5'} />
            <p className="text-xs text-neutral-300 leading-relaxed">{metric.advice}</p>
          </div>
        </div>
      </div>
    </motion.div>
  );
}

interface QuickInsightsSectionProps {
  topMetrics: RankedMetric[];
  bottomMetrics: RankedMetric[];
}

function QuickInsightsSection({ topMetrics, bottomMetrics }: QuickInsightsSectionProps) {
  if (topMetrics.length === 0 && bottomMetrics.length === 0) return null;

  return (
    <div className="mb-8">
      <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
        <Lightbulb size={20} className="text-cyan-400" />
        Quick Insights
      </h3>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Top 3 Strengths */}
        <div>
          <h4 className="text-sm font-medium text-green-400 mb-3 flex items-center gap-2">
            <TrendingUp size={14} />
            Top Strengths
          </h4>
          <div className="space-y-3">
            {topMetrics.map((metric, index) => (
              <MetricInsightCard
                key={metric.metricId}
                metric={metric}
                type="strength"
                index={index}
              />
            ))}
          </div>
        </div>

        {/* Bottom 3 - Areas to Improve */}
        <div>
          <h4 className="text-sm font-medium text-orange-400 mb-3 flex items-center gap-2">
            <TrendingDown size={14} />
            Areas to Improve
          </h4>
          <div className="space-y-3">
            {bottomMetrics.map((metric, index) => (
              <MetricInsightCard
                key={metric.metricId}
                metric={metric}
                type="improvement"
                index={index}
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================
// HARMONY SCORE DISPLAY (with AnimatedScore and Radar Chart)
// ============================================

function HarmonyScoreDisplay() {
  const { overallScore, frontScore, sideScore, harmonyPercentage, harmonyScoreResult, pslRating } = useResults();
  const [showRadar, setShowRadar] = useState(true);

  // Get tier color based on PSL
  const getTierColor = (psl: number) => {
    // Handle invalid PSL values
    if (typeof psl !== 'number' || !Number.isFinite(psl)) {
      return 'text-orange-400';
    }
    if (psl >= 7.0) return 'text-purple-400';
    if (psl >= 6.0) return 'text-cyan-400';
    if (psl >= 5.0) return 'text-green-400';
    if (psl >= 4.0) return 'text-yellow-400';
    return 'text-orange-400';
  };

  // Safe values for display with fallbacks
  const safePslRating = useMemo(() => ({
    psl: typeof pslRating?.psl === 'number' && Number.isFinite(pslRating.psl) ? pslRating.psl : 3.0,
    tier: pslRating?.tier || 'Unknown',
    percentile: typeof pslRating?.percentile === 'number' && Number.isFinite(pslRating.percentile) ? pslRating.percentile : 50,
    description: pslRating?.description || 'Analysis pending',
  }), [pslRating]);

  const safeHarmonyPercentage = typeof harmonyPercentage === 'number' && Number.isFinite(harmonyPercentage)
    ? harmonyPercentage
    : 0;

  const safeFrontScore = typeof frontScore === 'number' && Number.isFinite(frontScore) ? frontScore : 0;
  const safeSideScore = typeof sideScore === 'number' && Number.isFinite(sideScore) ? sideScore : 0;
  const safeOverallScore = typeof overallScore === 'number' && Number.isFinite(overallScore) ? overallScore : 0;

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
          <h2 className="text-lg font-medium text-neutral-400 mb-2">Weighted Harmony Score</h2>

          {/* PSL Rating Badge */}
          <motion.div
            className="flex justify-center mb-3"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.2, type: 'spring' }}
          >
            <div className="px-5 py-2 bg-gradient-to-r from-neutral-800 to-neutral-900 border border-neutral-700 rounded-xl">
              <div className="flex items-center gap-3">
                <div className="text-center">
                  <span className={`text-3xl font-bold ${getTierColor(safePslRating.psl)}`}>
                    {safePslRating.psl.toFixed(1)}
                  </span>
                  <span className="text-sm text-neutral-500 ml-1">PSL</span>
                </div>
                <div className="h-8 w-px bg-neutral-700" />
                <div className="text-left">
                  <p className={`text-sm font-semibold ${getTierColor(safePslRating.psl)}`}>
                    {safePslRating.tier}
                  </p>
                  <p className="text-xs text-neutral-500">
                    Top {(100 - safePslRating.percentile).toFixed(1)}%
                  </p>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Harmony Percentage Badge */}
          <motion.div
            className="flex justify-center mb-4"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.3, type: 'spring' }}
          >
            <div className="px-4 py-1 bg-gradient-to-r from-purple-500/20 to-cyan-500/20 border border-purple-500/30 rounded-full">
              <span className="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-cyan-400">
                {safeHarmonyPercentage.toFixed(1)}%
              </span>
              <span className="text-xs text-neutral-500 ml-2">Harmony</span>
            </div>
          </motion.div>

          {/* Animated Score */}
          <div className="flex justify-center mb-4">
            <AnimatedScore
              score={safeOverallScore}
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
              <p className="text-xl font-bold" style={{ color: getScoreColor(safeFrontScore) }}>
                {safeFrontScore.toFixed(2)}
              </p>
            </div>
            <div className="w-px bg-neutral-800" />
            <div className="text-center">
              <p className="text-xs text-neutral-500 mb-1">Side Profile</p>
              <p className="text-xl font-bold" style={{ color: getScoreColor(safeSideScore) }}>
                {safeSideScore.toFixed(2)}
              </p>
            </div>
          </div>

          {/* Weight Distribution */}
          {harmonyScoreResult && (
            <div className="flex justify-center gap-3 mb-4 text-xs">
              <span className="px-2 py-1 rounded bg-purple-500/20 text-purple-400 border border-purple-500/30">
                High Impact: {harmonyScoreResult.weightDistribution.highImpact.count}
              </span>
              <span className="px-2 py-1 rounded bg-blue-500/20 text-blue-400 border border-blue-500/30">
                Medium: {harmonyScoreResult.weightDistribution.mediumImpact.count}
              </span>
              <span className="px-2 py-1 rounded bg-gray-500/20 text-gray-400 border border-gray-500/30">
                Standard: {harmonyScoreResult.weightDistribution.standard.count}
              </span>
            </div>
          )}

          <p className="text-sm text-neutral-400 max-w-md mx-auto">
            {safeHarmonyPercentage >= 80 ? 'Exceptional facial harmony. Your features are well-balanced and proportioned.' :
              safeHarmonyPercentage >= 60 ? 'Good facial harmony with some areas that could be optimized.' :
                safeHarmonyPercentage >= 40 ? 'Average facial harmony. Several areas have room for improvement.' :
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
    frontLandmarks,
    sideLandmarks,
    gender,
    ethnicity,
    setActiveTab,
    topMetrics,
    bottomMetrics,
    setSelectedVisualizationMetric,
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

    // Update the visualization first (shows on face image)
    if (fullRatio) {
      setSelectedVisualizationMetric(fullRatio.id);
      setSelectedRatio(ratioToFaceIQResult(fullRatio));
    } else {
      // Create a minimal FaceIQScoreResult from ResponsibleRatio
      setSelectedVisualizationMetric(ratio.ratioId);
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
  }, [allRatios, ratioToFaceIQResult, setSelectedVisualizationMetric]);

  // Navigate to previous/next ratio in modal
  const handlePreviousRatio = useCallback(() => {
    if (currentRatioIndex > 0) {
      const prevRatio = allRatios[currentRatioIndex - 1];
      setSelectedRatio(ratioToFaceIQResult(prevRatio));
      setSelectedVisualizationMetric(prevRatio.id);
    }
  }, [currentRatioIndex, allRatios, ratioToFaceIQResult, setSelectedVisualizationMetric]);

  const handleNextRatio = useCallback(() => {
    if (currentRatioIndex < allRatios.length - 1) {
      const nextRatio = allRatios[currentRatioIndex + 1];
      setSelectedRatio(ratioToFaceIQResult(nextRatio));
      setSelectedVisualizationMetric(nextRatio.id);
    }
  }, [currentRatioIndex, allRatios, ratioToFaceIQResult, setSelectedVisualizationMetric]);

  // Determine if selected ratio is from side profile
  const isSideRatio = useMemo(() => {
    if (!selectedRatio) return false;
    const sideMetricIds = sideRatios.map(r => r.id);
    return sideMetricIds.includes(selectedRatio.metricId);
  }, [selectedRatio, sideRatios]);

  // Memoized modal values (useMemo instead of useCallback for computed values)
  const modalPhoto = useMemo(() => {
    if (!selectedRatio) return frontPhoto;
    return isSideRatio ? (sidePhoto || frontPhoto) : frontPhoto;
  }, [selectedRatio, isSideRatio, frontPhoto, sidePhoto]);

  const modalLandmarks = useMemo(() => {
    return isSideRatio ? (sideLandmarks || []) : (frontLandmarks || []);
  }, [isSideRatio, frontLandmarks, sideLandmarks]);

  const modalProfileType = useMemo((): 'front' | 'side' => {
    return isSideRatio ? 'side' : 'front';
  }, [isSideRatio]);

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

        {/* Quick Insights - Top/Bottom Metrics with Advice (from looksmax_engine.py) */}
        <QuickInsightsSection topMetrics={topMetrics} bottomMetrics={bottomMetrics} />

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
        facePhoto={modalPhoto}
        landmarks={modalLandmarks}
        allRatios={allRatios}
        profileType={modalProfileType}
        gender={gender}
        ethnicity={ethnicity}
      />
    </TabContent>
  );
}
