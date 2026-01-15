'use client';

import { motion } from 'framer-motion';
import Image from 'next/image';
import { User, ScanFace, ChevronRight, TrendingUp, TrendingDown, Eye, Zap } from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { useHeightOptional } from '@/contexts/HeightContext';
import { TabContent } from '../ResultsLayout';
import { AnimatedScore, ShareButton, ExportButton } from '../shared';
import { FacialRadarChart } from '../visualization/FacialRadarChart';
import { RatioDetailModal } from '../modals/RatioDetailModal';
import { getScoreColor, ResponsibleRatio, Ratio } from '@/types/results';
import { MetricScoreResult } from '@/lib/harmony-scoring';
import { RankedMetric } from '@/lib/looksmax-scoring';
import { calculatePSL, getTierColor } from '@/lib/psl-calculator';
import { useState, useCallback, useMemo } from 'react';
import { usePricing } from '@/contexts/PricingContext';

// ============================================
// BENTO GRID CARDS - Clean, hierarchical design
// ============================================

interface ProfileScoreCardProps {
  title: string;
  score: number | string;
  icon: React.ReactNode;
  photo?: string;
  ratioCount: number;
  onClick?: () => void;
}

function ProfileScoreCard({ title, score, icon, photo, ratioCount, onClick }: ProfileScoreCardProps) {
  const numericScore = typeof score === 'number' ? score : 0;
  const color = getScoreColor(numericScore);

  return (
    <motion.button
      onClick={onClick}
      className="group rounded-[1.5rem] bg-neutral-900/40 border border-white/5 p-5 hover:border-white/10 transition-all text-left w-full"
      whileHover={{ y: -2 }}
      whileTap={{ scale: 0.98 }}
    >
      <div className="flex items-center gap-4">
        {/* Photo */}
        <div className="relative w-14 h-14 rounded-xl overflow-hidden bg-neutral-900 border border-white/10 flex-shrink-0">
          {photo ? (
            <Image src={photo} alt={title} width={56} height={56} className="object-cover" unoptimized />
          ) : (
            <div className="w-full h-full flex items-center justify-center">{icon}</div>
          )}
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          <h3 className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-600 mb-1">{title} Profile</h3>
          <div className="flex items-baseline gap-2">
            <span className="text-2xl font-black" style={{ color }}>
              {typeof score === 'number' ? score.toFixed(1) : score}
            </span>
            <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">/10</span>
          </div>
        </div>

        {/* Arrow + Count */}
        <div className="flex items-center gap-3">
          <span className="text-[10px] font-black uppercase tracking-wider text-neutral-700">{ratioCount} metrics</span>
          <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/5 flex items-center justify-center group-hover:border-cyan-500/30 group-hover:bg-cyan-500/10 transition-all">
            <ChevronRight size={14} className="text-neutral-600 group-hover:text-cyan-400 transition-colors" />
          </div>
        </div>
      </div>
    </motion.button>
  );
}

// ============================================
// QUICK STATS ROW - Condensed horizontal display
// ============================================

interface QuickStatsRowProps {
  topMetrics: RankedMetric[];
  bottomMetrics: RankedMetric[];
  onViewDetails: () => void;
}

function QuickStatsRow({ topMetrics, bottomMetrics, onViewDetails }: QuickStatsRowProps) {
  const topMetric = topMetrics[0];
  const bottomMetric = bottomMetrics[0];

  if (!topMetric && !bottomMetric) return null;

  return (
    <div className="flex flex-wrap items-center gap-3">
      {topMetric && (
        <div className="flex items-center gap-3 px-4 py-2.5 bg-emerald-500/10 border border-emerald-500/20 rounded-xl">
          <div className="w-7 h-7 rounded-lg bg-emerald-500/20 flex items-center justify-center">
            <TrendingUp size={14} className="text-emerald-400" />
          </div>
          <div>
            <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-500 block">Top Strength</span>
            <span className="text-sm font-black text-emerald-400">{topMetric.name}</span>
          </div>
          <span className="text-lg font-black text-emerald-400 ml-2">
            {typeof topMetric.score === 'number' ? topMetric.score.toFixed(1) : topMetric.score}
          </span>
        </div>
      )}
      {bottomMetric && (
        <div className="flex items-center gap-3 px-4 py-2.5 bg-orange-500/10 border border-orange-500/20 rounded-xl">
          <div className="w-7 h-7 rounded-lg bg-orange-500/20 flex items-center justify-center">
            <TrendingDown size={14} className="text-orange-400" />
          </div>
          <div>
            <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-500 block">Focus Area</span>
            <span className="text-sm font-black text-orange-400">{bottomMetric.name}</span>
          </div>
          <span className="text-lg font-black text-orange-400 ml-2">
            {typeof bottomMetric.score === 'number' ? bottomMetric.score.toFixed(1) : bottomMetric.score}
          </span>
        </div>
      )}
      <button
        onClick={onViewDetails}
        className="ml-auto flex items-center gap-2 px-4 py-2.5 rounded-xl bg-neutral-900 border border-white/5 hover:border-cyan-500/30 transition-all group"
      >
        <span className="text-[10px] font-black uppercase tracking-wider text-neutral-500 group-hover:text-cyan-400 transition-colors">All Metrics</span>
        <ChevronRight size={14} className="text-neutral-600 group-hover:text-cyan-400 transition-colors" />
      </button>
    </div>
  );
}

// ============================================
// HERO SCORE CARD - Clean bento-style main score
// ============================================

function HeroScoreCard() {
  const { overallScore, harmonyPercentage, pslRating } = useResults();

  const safeOverallScore = typeof overallScore === 'number' && Number.isFinite(overallScore) ? overallScore : 0;
  const safeHarmonyPercentage = typeof harmonyPercentage === 'number' && Number.isFinite(harmonyPercentage) ? harmonyPercentage : 0;
  const safePsl = typeof pslRating?.psl === 'number' && Number.isFinite(pslRating.psl) ? pslRating.psl : 3.0;
  const safeTier = pslRating?.tier || 'MTN';
  const safePercentile = typeof pslRating?.percentile === 'number' && Number.isFinite(pslRating.percentile) ? pslRating.percentile : 50;

  const getPslColor = (psl: number) => {
    if (psl >= 7.0) return '#a855f7';
    if (psl >= 6.0) return '#22d3ee';
    if (psl >= 5.0) return '#22c55e';
    if (psl >= 4.0) return '#eab308';
    return '#f97316';
  };

  return (
    <motion.div
      className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-8 relative overflow-hidden"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      {/* Background decoration */}
      <div className="absolute top-0 right-0 w-48 h-48 bg-gradient-to-bl from-cyan-500/5 to-transparent rounded-full blur-3xl" />

      {/* Header */}
      <p className="text-[10px] font-black uppercase tracking-[0.3em] text-neutral-600 mb-6 relative z-10">Facial Harmony Score</p>

      {/* PSL + Tier Badge */}
      <div className="flex items-center gap-4 mb-6 relative z-10">
        <div className="px-5 py-3 bg-neutral-900/60 border border-white/10 rounded-2xl">
          <div className="flex items-center gap-3">
            <span className="text-3xl font-black" style={{ color: getPslColor(safePsl) }}>
              {safePsl.toFixed(1)}
            </span>
            <div className="flex flex-col">
              <span className="text-[10px] font-black uppercase tracking-wider text-neutral-500">PSL</span>
              <span className="text-sm font-black" style={{ color: getPslColor(safePsl) }}>
                {safeTier}
              </span>
            </div>
            <div className="h-8 w-px bg-white/10 mx-2" />
            <div className="flex flex-col items-center">
              <span className="text-[10px] font-black uppercase tracking-wider text-neutral-500">Rank</span>
              <span className="text-sm font-black text-white">Top {(100 - safePercentile).toFixed(0)}%</span>
            </div>
          </div>
        </div>

        {/* Harmony Badge */}
        <div className="px-4 py-3 bg-gradient-to-r from-purple-500/10 to-cyan-500/10 border border-purple-500/20 rounded-2xl">
          <div className="flex items-center gap-2">
            <span className="text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-cyan-400">
              {safeHarmonyPercentage.toFixed(0)}%
            </span>
            <span className="text-[10px] font-black uppercase tracking-wider text-neutral-500">Harmony</span>
          </div>
        </div>
      </div>

      {/* Main Score */}
      <div className="flex justify-center relative z-10">
        <AnimatedScore
          score={safeOverallScore}
          duration={2}
          delay={0.3}
          showConfetti={true}
          confettiThreshold={7.5}
        />
      </div>
    </motion.div>
  );
}

// ============================================
// RADAR CARD - Category breakdown
// ============================================

function RadarCard() {
  return (
    <motion.div
      className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-6 h-full"
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay: 0.2 }}
    >
      <div className="flex items-center justify-between mb-4">
        <p className="text-[10px] font-black uppercase tracking-[0.3em] text-neutral-600">Category Breakdown</p>
      </div>
      <div className="h-[220px]">
        <FacialRadarChart height={220} />
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
    isUnlocked,
  } = useResults();

  const { openPricingModal } = usePricing();

  const heightContext = useHeightOptional();
  const [selectedRatio, setSelectedRatio] = useState<MetricScoreResult | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Calculate PSL for the preview card (reserved for future use)
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const _pslPreviewData = useMemo(() => {
    const heightCm = heightContext?.heightCm;
    if (!heightCm || !overallScore) {
      return { hasHeight: false, score: 0, tier: 'Unknown', tierColor: '#6b7280' };
    }

    const numericScore = typeof overallScore === 'number' ? overallScore : 0;
    const pslResult = calculatePSL({
      faceScore: numericScore,
      heightCm,
      gender: gender || 'male',
    });

    return {
      hasHeight: true,
      score: pslResult.score,
      tier: pslResult.tier,
      tierColor: getTierColor(pslResult.tier),
    };
  }, [heightContext?.heightCm, overallScore, gender]);

  // All ratios combined for modal navigation
  const allRatios = useMemo(() => [...frontRatios, ...sideRatios], [frontRatios, sideRatios]);

  // Current ratio index for navigation
  const currentRatioIndex = useMemo(() => {
    if (!selectedRatio) return -1;
    return allRatios.findIndex(r => r.id === selectedRatio.metricId);
  }, [selectedRatio, allRatios]);

  // Convert Ratio to MetricScoreResult for modal
  const ratioToMetricResult = useCallback((ratio: Ratio): MetricScoreResult => {
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
    } as MetricScoreResult;
  }, []);

  // Handle ratio click from strengths/flaws sections (reserved for future use)
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const _handleRatioClick = useCallback((ratio: ResponsibleRatio, categoryName: string) => {
    // Find the full ratio data from frontRatios or sideRatios
    const fullRatio = allRatios.find(
      (r) => r.name === ratio.ratioName || r.id === ratio.ratioId
    );

    // Update the visualization first (shows on face image)
    if (fullRatio) {
      setSelectedVisualizationMetric(fullRatio.id);
      setSelectedRatio(ratioToMetricResult(fullRatio));
    } else {
      // Create a minimal MetricScoreResult from ResponsibleRatio
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
        qualityTier: (typeof ratio.score === 'number' ? ratio.score : 0) >= 8 ? 'ideal' : (typeof ratio.score === 'number' ? ratio.score : 0) >= 6 ? 'excellent' : (typeof ratio.score === 'number' ? ratio.score : 0) >= 4 ? 'good' : 'below_average',
        severity: 'optimal',
      } as MetricScoreResult);
    }
    setIsModalOpen(true);
  }, [allRatios, ratioToMetricResult, setSelectedVisualizationMetric]);

  // Navigate to previous/next ratio in modal
  const handlePreviousRatio = useCallback(() => {
    if (currentRatioIndex > 0) {
      const prevRatio = allRatios[currentRatioIndex - 1];
      setSelectedRatio(ratioToMetricResult(prevRatio));
      setSelectedVisualizationMetric(prevRatio.id);
    }
  }, [currentRatioIndex, allRatios, ratioToMetricResult, setSelectedVisualizationMetric]);

  const handleNextRatio = useCallback(() => {
    if (currentRatioIndex < allRatios.length - 1) {
      const nextRatio = allRatios[currentRatioIndex + 1];
      setSelectedRatio(ratioToMetricResult(nextRatio));
      setSelectedVisualizationMetric(nextRatio.id);
    }
  }, [currentRatioIndex, allRatios, ratioToMetricResult, setSelectedVisualizationMetric]);

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
      subtitle="Your facial harmony analysis"
      rightContent={
        <div className="flex items-center gap-2">
          <ShareButton score={overallScore} frontScore={frontScore} sideScore={sideScore} />
          <ExportButton />
        </div>
      }
    >
      {/* Bento Grid Layout */}
      <div id="results-overview" className="space-y-4">
        {/* Row 1: Hero Score + Radar Chart */}
        <div className="grid grid-cols-1 lg:grid-cols-5 gap-4">
          <div className="lg:col-span-3">
            <HeroScoreCard />
          </div>
          <div className="lg:col-span-2">
            <RadarCard />
          </div>
        </div>

        {/* Row 2: Profile Cards */}
        <div className="grid grid-cols-2 gap-3">
          <ProfileScoreCard
            title="Front"
            score={frontScore}
            icon={<User size={20} className="text-neutral-600" />}
            photo={frontPhoto}
            ratioCount={frontRatios.length}
            onClick={() => setActiveTab('front-ratios')}
          />
          <ProfileScoreCard
            title="Side"
            score={sideScore}
            icon={<ScanFace size={20} className="text-neutral-600" />}
            photo={sidePhoto || undefined}
            ratioCount={sideRatios.length}
            onClick={() => setActiveTab('side-ratios')}
          />
        </div>

        {/* Row 3: Quick Stats */}
        <div className="rounded-[1.5rem] bg-neutral-900/40 border border-white/5 p-5">
          <QuickStatsRow
            topMetrics={topMetrics}
            bottomMetrics={bottomMetrics}
            onViewDetails={() => setActiveTab('front-ratios')}
          />
        </div>

        {/* Row 4: Action Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* PSL Card */}
          <motion.button
            onClick={() => setActiveTab('psl')}
            className="group flex items-center gap-5 p-5 rounded-[1.5rem] bg-neutral-900/40 border border-white/5 hover:border-purple-500/30 transition-all text-left"
            whileHover={{ y: -2 }}
          >
            <div className="w-12 h-12 rounded-xl bg-purple-500/15 border border-purple-500/20 flex items-center justify-center">
              <Eye size={20} className="text-purple-400" />
            </div>
            <div className="flex-1">
              <p className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-600 mb-1">PSL Rating</p>
              <p className="text-sm font-black text-white">View detailed breakdown</p>
            </div>
            <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/5 flex items-center justify-center group-hover:border-purple-500/30 group-hover:bg-purple-500/10 transition-all">
              <ChevronRight size={14} className="text-neutral-600 group-hover:text-purple-400 transition-colors" />
            </div>
          </motion.button>

          {/* Plan Card */}
          <motion.button
            onClick={() => {
              if (isUnlocked) {
                setActiveTab('plan');
              } else {
                openPricingModal('overview_cta');
              }
            }}
            className="group flex items-center gap-5 p-5 rounded-[1.5rem] bg-gradient-to-r from-cyan-500/10 to-blue-500/5 border border-cyan-500/20 hover:border-cyan-500/40 transition-all text-left"
            whileHover={{ y: -2 }}
          >
            <div className="w-12 h-12 rounded-xl bg-cyan-500/15 border border-cyan-500/20 flex items-center justify-center">
              <Zap size={20} className="text-cyan-400" />
            </div>
            <div className="flex-1">
              <p className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-600 mb-1">Your Plan</p>
              <p className="text-sm font-black text-white">
                {isUnlocked ? 'View recommendations' : 'Unlock your potential'}
              </p>
            </div>
            <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/5 flex items-center justify-center group-hover:border-cyan-500/30 group-hover:bg-cyan-500/10 transition-all">
              <ChevronRight size={14} className="text-neutral-600 group-hover:text-cyan-400 transition-colors" />
            </div>
          </motion.button>
        </div>
      </div>

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
