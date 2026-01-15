'use client';

import { useState, useMemo, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Sparkles,
  TrendingUp,
  Target,
  Zap,
  ChevronRight,
  Lock,
  CheckCircle,
  Scale,
  Dumbbell,
  Salad,
  ArrowDown,
  ArrowUp,
  Minus,
  Package,
  ShoppingCart,
} from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { useAuth } from '@/contexts/AuthContext';
import { usePricing } from '@/contexts/PricingContext';
import { usePhysiqueOptional } from '@/contexts/PhysiqueContext';
import { TabContent } from '../ResultsLayout';
import { EnhancedRecommendationCard } from '../cards/EnhancedRecommendationCard';
import { ScoreCircle, PhaseBadge } from '../shared';
import { BeforeAfterPreview } from '../visualization/BeforeAfterPreview';
import { FaceMorphing } from '../visualization/FaceMorphing';
import { TreatmentTimeline } from '../visualization/TreatmentTimeline';
import { RecommendationPhase, ProductRecommendation } from '@/types/results';
import { DailyStackCard } from '../cards/DailyStackCard';
import { ProductCard } from '../cards/ProductCard';
import { WeakPointCard } from '../cards/WeakPointCard';
import { ProgressComparisonCard } from '../cards/ProgressComparisonCard';
import { MedicalPrescriptionCard } from '../cards/MedicalPrescriptionCard';
import { generateDailyStack } from '@/lib/daily-stack';
import { getProductRecommendations } from '@/lib/product-recommendations';
import { SUPPLEMENTS } from '@/lib/recommendations/supplements';
import {
  TreatmentConflictList,
  SelectionWarningModal,
} from '../cards/TreatmentConflictWarning';
import {
  findTreatmentConflicts,
  type TreatmentConflict,
} from '@/lib/recommendations/engine';

// ============================================
// SECTION HEADER COMPONENT
// ============================================

function SectionHeader({ title, children }: { title: string; children?: React.ReactNode }) {
  return (
    <div className="flex items-center gap-4 mb-6">
      <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 whitespace-nowrap">
        {title}
      </h2>
      <div className="flex-1 h-px bg-neutral-800" />
      {children}
    </div>
  );
}

// ============================================
// POTENTIAL SCORE CARD
// ============================================

function PotentialScoreCard() {
  const { overallScore, recommendations } = useResults();
  const numericScore = typeof overallScore === 'number' ? overallScore : 0;

  // Calculate potential improvement
  const potentialImprovement = useMemo(() => {
    if (recommendations.length === 0) return 0;
    const totalImpact = recommendations.slice(0, 5).reduce((sum, r) => sum + (r.impact || 0), 0);
    return Math.min(totalImpact * 1.5, 10 - numericScore);
  }, [recommendations, numericScore]);

  const potentialScore = Math.min(10, numericScore + potentialImprovement);

  return (
    <motion.div
      className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-6 md:p-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="flex items-center gap-3 mb-6">
        <div className="w-10 h-10 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
          <Sparkles size={18} className="text-cyan-400" />
        </div>
        <div>
          <h3 className="text-sm font-black uppercase tracking-wider text-white">Your Potential</h3>
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">Maximum Achievable Score</p>
        </div>
      </div>

      <div className="flex items-center justify-center gap-6 md:gap-10 mb-6">
        {/* Current */}
        <div className="text-center">
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-3">Current</p>
          <ScoreCircle score={overallScore} size="lg" animate={false} />
        </div>

        {/* Arrow */}
        <div className="flex flex-col items-center gap-2">
          <ChevronRight size={28} className="text-cyan-400" />
          <span className="px-2 py-1 rounded-lg bg-green-500/20 border border-green-500/30 text-xs font-black uppercase tracking-wider text-green-400">
            +{potentialImprovement.toFixed(1)}
          </span>
        </div>

        {/* Potential */}
        <div className="text-center">
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-3">Potential</p>
          <div className="relative">
            <ScoreCircle score={potentialScore} size="lg" animate={false} />
            <div className="absolute -top-1 -right-1 w-6 h-6 bg-green-500 rounded-lg flex items-center justify-center shadow-lg shadow-green-500/30">
              <TrendingUp size={14} className="text-black" />
            </div>
          </div>
        </div>
      </div>

      <p className="text-sm text-neutral-400 text-center leading-relaxed">
        Following our recommendations could improve your harmony score by up to{' '}
        <span className="text-green-400 font-black">+{potentialImprovement.toFixed(1)} points</span>
      </p>
    </motion.div>
  );
}

// ============================================
// PHASE FILTER
// ============================================

interface PhaseFilterProps {
  selectedPhase: RecommendationPhase | null;
  onSelect: (phase: RecommendationPhase | null) => void;
  counts: Record<RecommendationPhase, number>;
}

function PhaseFilter({ selectedPhase, onSelect, counts }: PhaseFilterProps) {
  const phases: RecommendationPhase[] = ['Foundational', 'Minimally Invasive', 'Surgical'];

  return (
    <div className="flex flex-wrap gap-2">
      <button
        onClick={() => onSelect(null)}
        className={`px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider transition-all border ${selectedPhase === null
          ? 'bg-cyan-500 text-black border-cyan-400'
          : 'bg-neutral-900/50 text-neutral-400 border-white/5 hover:border-white/10 hover:text-white'
          }`}
      >
        All ({Object.values(counts).reduce((a, b) => a + b, 0)})
      </button>
      {phases.map(phase => (
        <button
          key={phase}
          onClick={() => onSelect(phase)}
          className={`px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider transition-all flex items-center gap-2 border ${selectedPhase === phase
            ? 'bg-neutral-800 text-white border-white/10'
            : 'bg-neutral-900/50 text-neutral-400 border-white/5 hover:border-white/10 hover:text-white'
            }`}
        >
          <PhaseBadge phase={phase} size="sm" />
          ({counts[phase] || 0})
        </button>
      ))}
    </div>
  );
}

// ============================================
// BEFORE/AFTER PREVIEW SECTION WITH MORPHING
// ============================================

type PreviewMode = 'static' | 'morphing';

function BeforeAfterPreviewSection() {
  const { frontPhoto, overallScore, recommendations, frontLandmarks } = useResults();
  const [previewMode, setPreviewMode] = useState<PreviewMode>('morphing');
  const numericScore = typeof overallScore === 'number' ? overallScore : 0;

  // Calculate potential improvement
  const potentialImprovement = useMemo(() => {
    if (recommendations.length === 0) return 0;
    const totalImpact = recommendations.slice(0, 5).reduce((sum, r) => sum + r.impact, 0);
    return Math.min(totalImpact * 1.5, 10 - numericScore);
  }, [recommendations, numericScore]);

  const potentialScore = Math.min(10, numericScore + potentialImprovement);

  if (!frontPhoto) return null;

  return (
    <div className="space-y-4">
      {/* Mode Toggle */}
      <div className="flex items-center justify-center gap-1 p-1 bg-neutral-900/50 rounded-xl border border-white/5">
        <button
          onClick={() => setPreviewMode('morphing')}
          className={`flex-1 px-4 py-2 rounded-lg text-[10px] font-black uppercase tracking-wider transition-all ${
            previewMode === 'morphing'
              ? 'bg-cyan-500/20 text-cyan-400 border border-cyan-500/30'
              : 'text-neutral-500 hover:text-white border border-transparent'
          }`}
        >
          Face Morphing
        </button>
        <button
          onClick={() => setPreviewMode('static')}
          className={`flex-1 px-4 py-2 rounded-lg text-[10px] font-black uppercase tracking-wider transition-all ${
            previewMode === 'static'
              ? 'bg-neutral-800 text-white border border-white/10'
              : 'text-neutral-500 hover:text-white border border-transparent'
          }`}
        >
          Static Preview
        </button>
      </div>

      {/* Preview Component */}
      <AnimatePresence mode="wait">
        {previewMode === 'morphing' && frontLandmarks.length > 0 ? (
          <motion.div
            key="morphing"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            transition={{ duration: 0.2 }}
          >
            <FaceMorphing
              photo={frontPhoto}
              frontLandmarks={frontLandmarks}
              currentScore={numericScore}
              potentialScore={potentialScore}
              recommendations={recommendations}
            />
          </motion.div>
        ) : (
          <motion.div
            key="static"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.2 }}
          >
            <BeforeAfterPreview
              photo={frontPhoto}
              currentScore={numericScore}
              potentialScore={potentialScore}
              recommendations={recommendations}
            />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

// ============================================
// ORDER OF OPERATIONS
// ============================================

function OrderOfOperations() {
  return (
    <div className="rounded-2xl bg-neutral-900/40 border border-white/5 p-5">
      <h4 className="text-xs font-black uppercase tracking-wider text-white mb-4 flex items-center gap-3">
        <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/10 flex items-center justify-center">
          <Target size={14} className="text-cyan-400" />
        </div>
        Recommended Order
      </h4>
      <div className="space-y-4">
        <div className="flex items-start gap-4">
          <div className="w-7 h-7 rounded-lg bg-green-500/20 border border-green-500/30 flex items-center justify-center flex-shrink-0 mt-0.5">
            <span className="text-xs font-black text-green-400">1</span>
          </div>
          <div>
            <p className="text-sm font-black uppercase tracking-wider text-white">Start with Foundational</p>
            <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mt-1">Low-cost, no-risk improvements</p>
          </div>
        </div>
        <div className="flex items-start gap-4">
          <div className="w-7 h-7 rounded-lg bg-yellow-500/20 border border-yellow-500/30 flex items-center justify-center flex-shrink-0 mt-0.5">
            <span className="text-xs font-black text-yellow-400">2</span>
          </div>
          <div>
            <p className="text-sm font-black uppercase tracking-wider text-white">Consider Minimally Invasive</p>
            <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mt-1">Temporary or reversible options</p>
          </div>
        </div>
        <div className="flex items-start gap-4">
          <div className="w-7 h-7 rounded-lg bg-red-500/20 border border-red-500/30 flex items-center justify-center flex-shrink-0 mt-0.5">
            <span className="text-xs font-black text-red-400">3</span>
          </div>
          <div>
            <p className="text-sm font-black uppercase tracking-wider text-white">Evaluate Surgical Options</p>
            <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mt-1">Permanent solutions for significant improvements</p>
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================
// YOUR PHASE CARD (Body Composition Phase)
// ============================================

type BodyPhase = 'bulk' | 'cut' | 'maintain';

interface YourPhaseCardProps {
  bodyFatPercent?: number;
  gender: 'male' | 'female';
}

function YourPhaseCard({ bodyFatPercent, gender }: YourPhaseCardProps) {
  // Determine phase based on body fat and gender
  const getPhase = (): { phase: BodyPhase; message: string; color: string; icon: React.ReactNode } => {
    if (!bodyFatPercent) {
      return {
        phase: 'maintain',
        message: 'Complete your physique analysis to get personalized phase recommendations.',
        color: 'from-neutral-800 to-neutral-900',
        icon: <Scale size={24} className="text-neutral-400" />,
      };
    }

    // Male thresholds: <12% = bulk, 12-18% = maintain, >18% = cut
    // Female thresholds: <18% = bulk, 18-25% = maintain, >25% = cut
    const bulkThreshold = gender === 'male' ? 12 : 18;
    const cutThreshold = gender === 'male' ? 18 : 25;

    if (bodyFatPercent < bulkThreshold) {
      return {
        phase: 'bulk',
        message: `At ${bodyFatPercent.toFixed(1)}% body fat, you're lean enough to build muscle. Focus on a slight caloric surplus with progressive overload.`,
        color: 'from-green-600 to-emerald-700',
        icon: <Dumbbell size={24} className="text-white" />,
      };
    } else if (bodyFatPercent > cutThreshold) {
      return {
        phase: 'cut',
        message: `At ${bodyFatPercent.toFixed(1)}% body fat, prioritize fat loss. A moderate caloric deficit with high protein will reveal your facial structure.`,
        color: 'from-orange-600 to-red-700',
        icon: <Salad size={24} className="text-white" />,
      };
    } else {
      return {
        phase: 'maintain',
        message: `At ${bodyFatPercent.toFixed(1)}% body fat, you're in the optimal range. Focus on body recomposition to build muscle while staying lean.`,
        color: 'from-blue-600 to-cyan-700',
        icon: <Scale size={24} className="text-white" />,
      };
    }
  };

  const { phase, message, color, icon } = getPhase();
  const phaseLabels: Record<BodyPhase, string> = {
    bulk: 'Lean Bulk Phase',
    cut: 'Cutting Phase',
    maintain: 'Maintenance Phase',
  };

  return (
    <motion.div
      className={`bg-gradient-to-br ${color} rounded-[2rem] p-6 md:p-8 border border-white/10`}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="flex items-start gap-5">
        <div className="w-14 h-14 rounded-2xl bg-white/20 border border-white/20 flex items-center justify-center flex-shrink-0 shadow-xl">
          {icon}
        </div>
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-2">
            <h3 className="text-lg font-black uppercase tracking-wider text-white">Your Phase</h3>
            <div className="px-3 py-1 bg-white/20 border border-white/20 rounded-lg text-[10px] font-black uppercase tracking-wider text-white">
              {phaseLabels[phase]}
            </div>
          </div>
          <p className="text-sm text-white/80 leading-relaxed mb-5">{message}</p>

          {/* Phase-specific tips */}
          <div className="grid grid-cols-3 gap-3">
            <div className="bg-black/20 rounded-xl p-3 text-center border border-white/10">
              <div className="flex items-center justify-center gap-1.5 mb-1">
                {phase === 'bulk' ? (
                  <ArrowUp size={12} className="text-green-300" />
                ) : phase === 'cut' ? (
                  <ArrowDown size={12} className="text-orange-300" />
                ) : (
                  <Minus size={12} className="text-blue-300" />
                )}
                <span className="text-[10px] font-bold uppercase tracking-wider text-white/60">Calories</span>
              </div>
              <span className="text-sm font-black uppercase text-white">
                {phase === 'bulk' ? '+300' : phase === 'cut' ? '-500' : '+/-0'}
              </span>
            </div>
            <div className="bg-black/20 rounded-xl p-3 text-center border border-white/10">
              <span className="text-[10px] font-bold uppercase tracking-wider text-white/60 block mb-1">Protein</span>
              <span className="text-sm font-black uppercase text-white">
                {phase === 'cut' ? '1.2g/lb' : '1g/lb'}
              </span>
            </div>
            <div className="bg-black/20 rounded-xl p-3 text-center border border-white/10">
              <span className="text-[10px] font-bold uppercase tracking-wider text-white/60 block mb-1">Cardio</span>
              <span className="text-sm font-black uppercase text-white">
                {phase === 'bulk' ? 'Minimal' : phase === 'cut' ? '4-5x/wk' : '2-3x/wk'}
              </span>
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  );
}

// ============================================
// PRODUCT BUNDLE CTA
// ============================================

interface ProductBundleCardProps {
  products: ProductRecommendation[];
  title?: string;
}

function ProductBundleCard({ products, title = 'Recommended Bundle' }: ProductBundleCardProps) {
  // Get top 3 most important products
  const bundleProducts = products.slice(0, 3);

  // Calculate total cost
  const totalCost = bundleProducts.reduce((sum, rec) => {
    const supplement = SUPPLEMENTS.find(s => s.id === rec.product.supplementId);
    return sum + (supplement?.costPerMonth.min || 0);
  }, 0);

  if (bundleProducts.length === 0) return null;

  return (
    <motion.div
      className="rounded-[2rem] bg-gradient-to-br from-purple-900/50 to-violet-950/50 border border-purple-500/30 p-6"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="flex items-center gap-3 mb-5">
        <div className="w-10 h-10 rounded-xl bg-purple-500/20 border border-purple-500/30 flex items-center justify-center">
          <Package size={18} className="text-purple-400" />
        </div>
        <div className="flex-1">
          <h3 className="text-sm font-black uppercase tracking-wider text-white">{title}</h3>
        </div>
        <div className="px-3 py-1.5 bg-purple-500/20 border border-purple-500/30 text-purple-300 text-[10px] font-black uppercase tracking-wider rounded-lg">
          Save 15%
        </div>
      </div>

      <p className="text-sm text-neutral-300 mb-5 leading-relaxed">
        Your analysis recommends these {bundleProducts.length} supplements - optimized for your specific weak points.
      </p>

      {/* Bundle Items */}
      <div className="space-y-2 mb-5">
        {bundleProducts.map((rec, index) => (
          <div
            key={rec.product.id}
            className="flex items-center gap-4 p-3 bg-black/30 rounded-xl border border-white/5"
          >
            <div className="w-7 h-7 rounded-lg bg-purple-500/30 border border-purple-500/30 flex items-center justify-center flex-shrink-0">
              <span className="text-xs font-black text-purple-300">{index + 1}</span>
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-black uppercase tracking-wider text-white truncate">{rec.product.name}</p>
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500 truncate">Targets: {rec.targetMetric}</p>
            </div>
            <div className="text-right flex-shrink-0">
              <p className="text-sm font-black text-white">
                ${SUPPLEMENTS.find(s => s.id === rec.product.supplementId)?.costPerMonth.min || 0}/mo
              </p>
            </div>
          </div>
        ))}
      </div>

      {/* Total & CTA */}
      <div className="border-t border-purple-500/20 pt-5">
        <div className="flex items-center justify-between mb-4">
          <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-400">Bundle Total</span>
          <div className="text-right">
            <span className="text-xl font-black text-white">${totalCost}/mo</span>
            <span className="text-xs font-bold text-neutral-500 ml-2 line-through">${Math.round(totalCost * 1.15)}/mo</span>
          </div>
        </div>
        <button
          className="w-full flex items-center justify-center gap-3 py-3.5 bg-gradient-to-r from-purple-500 to-violet-600 text-white text-xs font-black uppercase tracking-wider rounded-xl hover:opacity-90 transition-opacity border border-purple-400/30"
        >
          <ShoppingCart size={16} />
          Get Your Bundle
        </button>
      </div>
    </motion.div>
  );
}

// ============================================
// PLAN TAB
// ============================================

export function PlanTab() {
  const { recommendations, flaws, gender, ethnicity, frontRatios, sideRatios, overallScore, frontPhoto, vision, isUnlocked } = useResults();
  const { user } = useAuth();
  const physiqueContext = usePhysiqueOptional();
  const [selectedPhase, setSelectedPhase] = useState<RecommendationPhase | null>(null);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [completedIds, setCompletedIds] = useState<Set<string>>(new Set());
  const [removedIds, setRemovedIds] = useState<Set<string>>(new Set());
  const [previousAnalysis, setPreviousAnalysis] = useState<{
    date: string;
    overallScore: number;
    bodyFatPercent?: number;
    frontPhotoUrl?: string;
  } | null>(null);

  // Treatment conflict state
  const [dismissedConflicts, setDismissedConflicts] = useState<Set<string>>(new Set());
  const [conflictModal, setConflictModal] = useState<{
    isOpen: boolean;
    conflict: TreatmentConflict | null;
    newTreatmentId: string;
  }>({ isOpen: false, conflict: null, newTreatmentId: '' });

  const { openPricingModal } = usePricing();

  // Convert to number for arithmetic operations
  const numericOverallScore = typeof overallScore === 'number' ? overallScore : 0;

  // Check if user has a paid plan
  const hasPaidPlan = user?.plan === 'basic' || user?.plan === 'pro';

  // Get body fat from physique analysis
  const bodyFatPercent = physiqueContext?.physiqueAnalysis?.bodyFatPercent;

  // Generate Daily Stack for all users
  const dailyStack = useMemo(() => {
    return generateDailyStack(gender);
  }, [gender]);

  // Generate Product Recommendations based on metrics
  const productRecommendations = useMemo(() => {
    // Build metrics and severity dictionaries from ratios
    const metricsDict: Record<string, number> = {};
    const severityDict: Record<string, string> = {};

    [...frontRatios, ...sideRatios].forEach(ratio => {
      metricsDict[ratio.name] = typeof ratio.value === 'number' ? ratio.value : 0;
      severityDict[ratio.name] = ratio.severity;
    });

    return getProductRecommendations(metricsDict, severityDict, gender, ethnicity);
  }, [frontRatios, sideRatios, gender, ethnicity]);

  // Split product recommendations by state
  const { flawProducts, idealProducts } = useMemo(() => {
    const flaw = productRecommendations.filter(r => r.state === 'flaw');
    const ideal = productRecommendations.filter(r => r.state === 'ideal');
    return { flawProducts: flaw, idealProducts: ideal };
  }, [productRecommendations]);

  // Map flaws to products and treatments
  const flawsWithProducts = useMemo(() => {
    return flaws.slice(0, 5).map(flaw => {
      // Find products that target metrics related to this flaw
      const relatedProducts = productRecommendations.filter(rec =>
        flaw && flaw.responsibleRatios && flaw.responsibleRatios.some(ratio =>
          rec.matchedMetrics.some(metric =>
            metric.toLowerCase().includes(ratio.ratioName.toLowerCase()) ||
            ratio.ratioName.toLowerCase().includes(metric.toLowerCase())
          )
        )
      );

      // Find treatments that match this flaw
      const relatedTreatments = recommendations.filter(rec =>
        rec.matchedFlaws.some(f => f.toLowerCase().includes(flaw.flawName.toLowerCase()))
      );

      return {
        flaw,
        products: relatedProducts.slice(0, 2),
        treatments: relatedTreatments.slice(0, 3),
      };
    });
  }, [flaws, productRecommendations, recommendations]);

  // Handle progress photo upload
  const handleProgressPhotoUpload = useCallback(async (file: File) => {
    // Store current analysis as previous before re-analyzing
    const numScore = typeof overallScore === 'number' ? overallScore : 0;
    setPreviousAnalysis({
      date: new Date().toISOString(),
      overallScore: numScore,
      bodyFatPercent,
      frontPhotoUrl: frontPhoto || undefined,
    });

    // In a real implementation, this would upload to API and trigger re-analysis
    console.log('Progress photo uploaded:', file.name);
  }, [overallScore, bodyFatPercent, frontPhoto]);

  // Count recommendations by phase
  const phaseCounts = useMemo(() => {
    const counts: Record<RecommendationPhase, number> = {
      'Foundational': 0,
      'Minimally Invasive': 0,
      'Surgical': 0,
    };
    recommendations.forEach(r => {
      if (!removedIds.has(r.ref_id)) {
        counts[r.phase]++;
      }
    });
    return counts;
  }, [recommendations, removedIds]);

  // Filter recommendations
  const filteredRecommendations = useMemo(() => {
    let filtered = recommendations.filter(r => !removedIds.has(r.ref_id));
    if (selectedPhase) {
      filtered = filtered.filter(r => r.phase === selectedPhase);
    }
    return filtered;
  }, [recommendations, selectedPhase, removedIds]);

  const hasRecommendations = filteredRecommendations.length > 0;

  // Detect treatment conflicts in current recommendations
  const treatmentConflicts = useMemo(() => {
    const selectedIds = filteredRecommendations.map(r => r.ref_id);
    const nameMap = Object.fromEntries(
      filteredRecommendations.map(r => [r.ref_id, r.name])
    );
    const conflicts = findTreatmentConflicts(selectedIds, nameMap);

    // Filter out dismissed conflicts
    return conflicts.filter(c => {
      const conflictKey = `${c.treatment1Id}-${c.treatment2Id}`;
      return !dismissedConflicts.has(conflictKey);
    });
  }, [filteredRecommendations, dismissedConflicts]);

  // Handle dismissing a conflict
  const handleDismissConflict = useCallback((conflict: TreatmentConflict) => {
    const conflictKey = `${conflict.treatment1Id}-${conflict.treatment2Id}`;
    setDismissedConflicts(prev => new Set(Array.from(prev).concat(conflictKey)));
  }, []);

  // Handle dismissing all conflicts
  const handleDismissAllConflicts = useCallback(() => {
    const allKeys = treatmentConflicts.map(
      c => `${c.treatment1Id}-${c.treatment2Id}`
    );
    setDismissedConflicts(prev => new Set(Array.from(prev).concat(allKeys)));
  }, [treatmentConflicts]);

  // Handle conflict modal actions
  const handleConflictProceed = useCallback(() => {
    if (conflictModal.conflict) {
      // Remove the lower priority (existing) treatment
      setRemovedIds(prev => new Set(Array.from(prev).concat(conflictModal.conflict!.treatment1Id)));
    }
    setConflictModal({ isOpen: false, conflict: null, newTreatmentId: '' });
  }, [conflictModal.conflict]);

  const handleConflictCancel = useCallback(() => {
    setConflictModal({ isOpen: false, conflict: null, newTreatmentId: '' });
  }, []);

  // Handle mark complete
  const handleMarkComplete = useCallback((id: string) => {
    setCompletedIds(prev => {
      const newSet = new Set(prev);
      if (newSet.has(id)) {
        newSet.delete(id);
      } else {
        newSet.add(id);
      }
      return newSet;
    });
  }, []);

  // Handle remove
  const handleRemove = useCallback((id: string) => {
    setRemovedIds(prev => {
      const newSet = new Set(prev);
      newSet.add(id);
      return newSet;
    });
    if (expandedId === id) {
      setExpandedId(null);
    }
  }, [expandedId]);

  return (
    <TabContent
      title="Your Plan & Potential"
      subtitle="Personalized recommendations based on your analysis"
    >
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-10">
          {/* Your Phase Card - Body Composition Phase */}
          <YourPhaseCard bodyFatPercent={bodyFatPercent} gender={gender} />

          {/* Daily Stack Card - Hero Element for ALL users */}
          {dailyStack && <DailyStackCard dailyStack={dailyStack} />}

          {/* Potential Score */}
          <PotentialScoreCard />

          {/* Fix Your Weak Points Section */}
          {flawsWithProducts.length > 0 && (
            <section>
              <SectionHeader title="Fix Your Weak Points">
                <span className="px-3 py-1.5 bg-red-500/20 border border-red-500/30 text-red-400 text-[10px] font-black uppercase tracking-wider rounded-lg">
                  {flawsWithProducts.length} Issues
                </span>
              </SectionHeader>
              <div className="space-y-4">
                {flawsWithProducts.map((item, index) => (
                  <WeakPointCard
                    key={item.flaw.id}
                    flaw={item.flaw}
                    rank={index + 1}
                    products={item.products}
                    treatments={item.treatments}
                    onViewTreatment={(treatment) => setExpandedId(treatment.ref_id)}
                  />
                ))}
              </div>
            </section>
          )}

          {/* Targeted Product Recommendations - Corrective */}
          {flawProducts.length > 0 && (
            <section>
              <SectionHeader title="Recommended Products">
                <span className="px-3 py-1.5 bg-cyan-500/20 border border-cyan-500/30 text-cyan-400 text-[10px] font-black uppercase tracking-wider rounded-lg">
                  Corrective
                </span>
              </SectionHeader>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {flawProducts.slice(0, 6).map((rec, index) => (
                  <ProductCard key={rec.product.id} recommendation={rec} rank={index + 1} />
                ))}
              </div>
            </section>
          )}

          {/* Targeted Product Recommendations - Maintenance */}
          {idealProducts.length > 0 && (
            <section>
              <SectionHeader title="Protect Your Strengths">
                <span className="px-3 py-1.5 bg-green-500/20 border border-green-500/30 text-green-400 text-[10px] font-black uppercase tracking-wider rounded-lg">
                  Maintenance
                </span>
              </SectionHeader>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {idealProducts.slice(0, 4).map((rec) => (
                  <ProductCard key={rec.product.id} recommendation={rec} />
                ))}
              </div>
            </section>
          )}

          {/* Treatment Timeline */}
          {recommendations.length > 0 && (
            <section>
              <SectionHeader title="Treatment Timeline" />
              <TreatmentTimeline recommendations={recommendations.filter(r => !removedIds.has(r.ref_id))} />
            </section>
          )}

          {/* Treatment Conflict Warnings */}
          {treatmentConflicts.length > 0 && (
            <TreatmentConflictList
              conflicts={treatmentConflicts}
              onDismiss={handleDismissConflict}
              onDismissAll={handleDismissAllConflicts}
            />
          )}

          {/* Phase Filter Section */}
          <section>
            <SectionHeader title="Treatment Options" />
            <PhaseFilter
              selectedPhase={selectedPhase}
              onSelect={setSelectedPhase}
              counts={phaseCounts}
            />
          </section>

          {/* Recommendations List */}
          {hasRecommendations ? (
            <motion.div className="space-y-4" layout>
              <AnimatePresence mode="popLayout">
                {filteredRecommendations.map((rec, index) => (
                  <motion.div
                    key={rec.ref_id}
                    layout
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ duration: 0.2, delay: index * 0.05 }}
                  >
                    <EnhancedRecommendationCard
                      recommendation={rec}
                      rank={index + 1}
                      isExpanded={expandedId === rec.ref_id}
                      onToggle={() => setExpandedId(
                        expandedId === rec.ref_id ? null : rec.ref_id
                      )}
                      onMarkComplete={handleMarkComplete}
                      onRemove={handleRemove}
                      isCompleted={completedIds.has(rec.ref_id)}
                      gender={gender}
                      ethnicity={ethnicity}
                    />
                  </motion.div>
                ))}
              </AnimatePresence>
            </motion.div>
          ) : (
            <div className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-10 text-center">
              <div className="w-16 h-16 rounded-2xl bg-neutral-900 border border-white/10 flex items-center justify-center mx-auto mb-5">
                <Sparkles size={28} className="text-neutral-600" />
              </div>
              <h3 className="text-lg font-black uppercase tracking-wider text-white mb-2">No Recommendations Yet</h3>
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
                Complete a facial analysis to get personalized recommendations
              </p>
            </div>
          )}
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Medical Prescription Card (Dental) */}
          {vision?.teeth && (
            <MedicalPrescriptionCard vision={vision} isUnlocked={isUnlocked} />
          )}

          {/* Progress Comparison Card */}
          <ProgressComparisonCard
            currentAnalysis={{
              date: new Date().toISOString(),
              overallScore: numericOverallScore,
              bodyFatPercent,
              frontPhotoUrl: frontPhoto || undefined,
            }}
            previousAnalysis={previousAnalysis}
            onUploadNewPhoto={handleProgressPhotoUpload}
          />

          {/* Product Bundle CTA */}
          {flawProducts.length >= 3 && (
            <ProductBundleCard
              products={flawProducts}
              title="Your Fix Bundle"
            />
          )}

          {/* Before/After Preview */}
          <BeforeAfterPreviewSection />

          {/* Order of Operations */}
          <OrderOfOperations />

          {/* My Plan Summary */}
          <div className="rounded-2xl bg-neutral-900/40 border border-white/5 p-5">
            <h4 className="text-xs font-black uppercase tracking-wider text-white mb-4 flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/10 flex items-center justify-center">
                <Zap size={14} className="text-yellow-400" />
              </div>
              My Plan
            </h4>
            <div className="text-center py-8">
              <div className="w-14 h-14 mx-auto mb-4 rounded-2xl bg-neutral-900 border border-white/10 flex items-center justify-center">
                <Lock size={20} className="text-neutral-600" />
              </div>
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2">
                Add recommendations to build your personalized plan
              </p>
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-700">
                0 items selected
              </p>
            </div>
          </div>

          {/* Issues Summary */}
          <div className="rounded-2xl bg-neutral-900/40 border border-white/5 p-5">
            <h4 className="text-xs font-black uppercase tracking-wider text-white mb-4">Detected Issues</h4>
            <div className="space-y-2">
              {flaws.slice(0, 5).map(flaw => (
                <div
                  key={flaw.id}
                  className="flex items-center justify-between p-3 bg-neutral-900/50 border border-white/5 rounded-xl hover:border-white/10 transition-colors"
                >
                  <span className="text-sm font-bold text-neutral-300 truncate">{flaw.flawName}</span>
                  <span className="text-[10px] font-black uppercase tracking-wider text-red-400 flex-shrink-0 px-2 py-1 bg-red-500/20 border border-red-500/30 rounded-lg">
                    -{flaw.harmonyPercentageLost.toFixed(1)}%
                  </span>
                </div>
              ))}
              {flaws.length === 0 && (
                <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 text-center py-6">
                  No issues detected
                </p>
              )}
            </div>
          </div>

          {/* Upgrade CTA or Premium Badge */}
          {hasPaidPlan ? (
            <motion.div
              className="rounded-2xl bg-gradient-to-br from-green-500/10 to-emerald-600/10 border border-green-500/30 p-5"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
            >
              <div className="flex items-center gap-3 mb-3">
                <div className="w-8 h-8 rounded-lg bg-green-500/20 border border-green-500/30 flex items-center justify-center">
                  <CheckCircle size={14} className="text-green-400" />
                </div>
                <span className="text-xs font-black uppercase tracking-wider text-white">
                  {user?.plan === 'pro' ? 'Pro Plan' : 'Basic Plan'} Active
                </span>
              </div>
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                You have full access to all {user?.plan === 'pro' ? 'features' : 'non-surgical recommendations'}.
              </p>
            </motion.div>
          ) : (
            <motion.div
              className="rounded-2xl bg-gradient-to-br from-cyan-500/10 to-blue-600/10 border border-cyan-500/30 p-5"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
            >
              <div className="flex items-center gap-3 mb-3">
                <div className="w-8 h-8 rounded-lg bg-cyan-500/20 border border-cyan-500/30 flex items-center justify-center">
                  <Sparkles size={14} className="text-cyan-400" />
                </div>
                <span className="text-xs font-black uppercase tracking-wider text-white">Unlock Full Plan</span>
              </div>
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500 mb-4">
                Get detailed treatment guides, cost estimates, and provider recommendations.
              </p>
              <button
                onClick={() => openPricingModal('plan_sidebar')}
                className="block w-full py-3 bg-cyan-500 text-black text-xs font-black uppercase tracking-wider rounded-xl text-center hover:bg-cyan-400 transition-colors"
              >
                Upgrade Now
              </button>
            </motion.div>
          )}
        </div>
      </div>

      {/* Treatment Conflict Modal */}
      <SelectionWarningModal
        isOpen={conflictModal.isOpen}
        onClose={handleConflictCancel}
        conflict={conflictModal.conflict || {
          treatment1Id: '',
          treatment1Name: '',
          treatment2Id: '',
          treatment2Name: '',
          reason: '',
        }}
        onProceed={handleConflictProceed}
        onCancel={handleConflictCancel}
      />
    </TabContent>
  );
}
