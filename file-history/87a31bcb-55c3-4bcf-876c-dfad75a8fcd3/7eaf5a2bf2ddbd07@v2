'use client';

import { useMemo, useState } from 'react';
import { motion } from 'framer-motion';
import {
  Ruler,
  Scale,
  TrendingUp,
  Calculator,
  Dumbbell,
  Camera,
  Percent,
  BookOpen,
  Clock,
  ArrowRight,
  Brain,
  Wrench,
  TrendingDown,
  Calendar,
  Target,
  Heart,
  Utensils,
  Droplet,
  ChevronDown,
} from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { Guide } from '@/types/guides';
import { getGuideById } from '@/data/guides';
import { useHeightOptional } from '@/contexts/HeightContext';
import { useWeightOptional } from '@/contexts/WeightContext';
import { usePhysiqueOptional } from '@/contexts/PhysiqueContext';
import { TabContent } from '../ResultsLayout';
import { PSLScoreCard } from '@/components/psl/PSLScoreCard';
import { PSLTierBadge } from '@/components/psl/PSLTierBadge';
import { calculatePSL, getHeightRating, cmToFeetInches } from '@/lib/psl-calculator';
import { getFFMICategoryColor, getFFMICategoryDescription } from '@/lib/ffmi-calculator';
import { TIER_DEFINITIONS, PSLResult, MuscleLevel, FFMIData } from '@/types/psl';
import Link from 'next/link';

// Height input form for users who skipped height entry
function HeightInputPrompt({ onHeightSet }: { onHeightSet: (cm: number) => void }) {
  const [feet, setFeet] = useState(5);
  const [inches, setInches] = useState(9);

  const handleSubmit = () => {
    const totalInches = feet * 12 + inches;
    const cm = Math.round(totalInches * 2.54);
    onHeightSet(cm);
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-6 hover:border-white/10 transition-colors"
    >
      <div className="flex items-center gap-4 mb-6">
        <div className="w-12 h-12 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
          <Ruler className="w-5 h-5 text-cyan-400" />
        </div>
        <div>
          <h3 className="text-lg font-black italic uppercase text-white">Enter Height</h3>
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">Required for PSL calculation</p>
        </div>
      </div>

      <div className="flex items-center gap-4 mb-6">
        <div className="flex-1">
          <label className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2 block">Feet</label>
          <select
            value={feet}
            onChange={(e) => setFeet(Number(e.target.value))}
            className="w-full bg-neutral-900/50 border border-white/5 rounded-xl px-4 py-3 text-white font-medium hover:border-white/10 transition-colors focus:outline-none focus:border-cyan-500/50"
          >
            {[4, 5, 6, 7].map((f) => (
              <option key={f} value={f}>{f}&apos;</option>
            ))}
          </select>
        </div>
        <div className="flex-1">
          <label className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2 block">Inches</label>
          <select
            value={inches}
            onChange={(e) => setInches(Number(e.target.value))}
            className="w-full bg-neutral-900/50 border border-white/5 rounded-xl px-4 py-3 text-white font-medium hover:border-white/10 transition-colors focus:outline-none focus:border-cyan-500/50"
          >
            {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((i) => (
              <option key={i} value={i}>{i}&quot;</option>
            ))}
          </select>
        </div>
      </div>

      <button
        onClick={handleSubmit}
        className="w-full py-3 bg-cyan-500 text-black font-black uppercase tracking-wider rounded-xl hover:bg-cyan-400 transition-colors"
      >
        Calculate PSL
      </button>
    </motion.div>
  );
}

// Tier comparison - compact horizontal
function TierComparisonChart({ currentTier, currentScore }: { currentTier: string; currentScore: number }) {
  const [expanded, setExpanded] = useState(false);
  const visibleTiers = expanded ? TIER_DEFINITIONS.slice().reverse() : TIER_DEFINITIONS.slice().reverse().slice(0, 4);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.2 }}
      className="rounded-2xl bg-neutral-900/40 border border-white/5 overflow-hidden"
    >
      <div className="flex items-center justify-between p-5 border-b border-white/5">
        <h3 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 flex items-center gap-4">
          Tier Ladder
          <div className="flex-1 h-px bg-neutral-800" />
        </h3>
        <button
          onClick={() => setExpanded(!expanded)}
          className="flex items-center gap-2 text-[10px] font-black uppercase tracking-wider text-neutral-500 hover:text-cyan-400 transition-colors"
        >
          {expanded ? 'LESS' : 'ALL'}
          <ChevronDown className={`w-3 h-3 transition-transform ${expanded ? 'rotate-180' : ''}`} />
        </button>
      </div>

      <div className="p-5 space-y-2">
        {visibleTiers.map((tier) => {
          const isCurrentTier = tier.name === currentTier;
          const isPassed = currentScore >= tier.minScore;

          return (
            <div
              key={tier.name}
              className={`flex items-center gap-3 p-3 rounded-xl transition-all ${
                isCurrentTier
                  ? 'bg-neutral-800/50 border border-white/10'
                  : 'hover:bg-neutral-800/20'
              }`}
            >
              <div
                className="w-2.5 h-2.5 rounded-full flex-shrink-0"
                style={{ backgroundColor: isPassed ? tier.color : `${tier.color}40` }}
              />
              <div className={`flex-1 text-xs font-black uppercase tracking-wider ${isCurrentTier ? 'text-white' : 'text-neutral-600'}`}>
                {tier.name}
              </div>
              <div className="flex-1 h-1.5 bg-neutral-800 rounded-full overflow-hidden">
                <div
                  className="h-full rounded-full transition-all"
                  style={{
                    width: `${Math.max(0, Math.min(100, ((currentScore - tier.minScore) / (tier.maxScore - tier.minScore)) * 100))}%`,
                    backgroundColor: isCurrentTier ? tier.color : 'transparent',
                  }}
                />
              </div>
              <div className={`text-[10px] font-black uppercase tracking-wider w-16 text-right ${isCurrentTier ? 'text-white' : 'text-neutral-700'}`}>
                {tier.minScore.toFixed(1)}-{tier.maxScore.toFixed(1)}
              </div>
            </div>
          );
        })}
      </div>
    </motion.div>
  );
}

// PSL Formula explanation - collapsible
// eslint-disable-next-line @typescript-eslint/no-unused-vars
function PSLFormulaExplainer({ bodyMethod: _bodyMethod }: { bodyMethod?: 'ffmi' | 'table' | 'default' }) {
  const [expanded, setExpanded] = useState(false);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.3 }}
      className="rounded-2xl bg-neutral-900/40 border border-white/5 overflow-hidden"
    >
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full flex items-center justify-between p-5 hover:bg-neutral-800/20 transition-colors"
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
            <Calculator className="w-4 h-4 text-cyan-400" />
          </div>
          <span className="text-sm font-black uppercase tracking-wider text-white">How PSL is Calculated</span>
        </div>
        <motion.div
          animate={{ rotate: expanded ? 180 : 0 }}
          transition={{ duration: 0.2 }}
        >
          <ChevronDown className={`w-4 h-4 ${expanded ? 'text-cyan-400' : 'text-neutral-500'}`} />
        </motion.div>
      </button>

      {expanded && (
        <motion.div
          initial={{ height: 0, opacity: 0 }}
          animate={{ height: 'auto', opacity: 1 }}
          className="px-5 pb-5"
        >
          {/* Formula */}
          <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4 mb-4 font-mono text-sm">
            <span className="text-cyan-400 font-black">PSL</span>
            <span className="text-neutral-500"> = </span>
            <span className="text-purple-400">FACE x 0.75</span>
            <span className="text-neutral-500"> + </span>
            <span className="text-green-400">HEIGHT x 0.20</span>
            <span className="text-neutral-500"> + </span>
            <span className="text-orange-400">BODY x 0.05</span>
          </div>

          {/* Quick explanation */}
          <div className="grid grid-cols-3 gap-3">
            <div className="p-3 rounded-xl bg-purple-500/10 border border-purple-500/20 text-center">
              <div className="text-purple-400 font-black text-lg">75%</div>
              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Face</div>
            </div>
            <div className="p-3 rounded-xl bg-green-500/10 border border-green-500/20 text-center">
              <div className="text-green-400 font-black text-lg">20%</div>
              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Height</div>
            </div>
            <div className="p-3 rounded-xl bg-orange-500/10 border border-orange-500/20 text-center">
              <div className="text-orange-400 font-black text-lg">5%</div>
              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Body</div>
            </div>
          </div>

          <p className="mt-4 text-xs text-neutral-500 font-medium">
            Elite scores (8.5+) earn bonuses. Height 8.0+ required for top tiers.
          </p>
        </motion.div>
      )}
    </motion.div>
  );
}

// BMI category helper
function getBMIInfo(bmi: number): { category: string; color: string } {
  if (bmi < 18.5) return { category: 'Underweight', color: 'text-yellow-400' };
  if (bmi < 25) return { category: 'Normal', color: 'text-green-400' };
  if (bmi < 30) return { category: 'Overweight', color: 'text-orange-400' };
  return { category: 'Obese', color: 'text-red-400' };
}

// Body Composition Card - shows FFMI, body fat %, and muscle level
function BodyCompositionCard({
  ffmiData,
  bodyFatPercent,
  muscleLevel,
  bodyScoreMethod,
  bodyRating,
  gender,
  weightInputMode = 'imperial',
}: {
  ffmiData?: FFMIData;
  bodyFatPercent?: number;
  muscleLevel?: string;
  bodyScoreMethod: 'ffmi' | 'table' | 'default';
  bodyRating: number;
  gender: 'male' | 'female';
  weightInputMode?: 'metric' | 'imperial';
}) {
  if (bodyScoreMethod === 'default') return null;

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.15 }}
      className="rounded-2xl bg-neutral-900/40 border border-white/5 overflow-hidden hover:border-white/10 transition-colors"
    >
      <div className="flex items-center gap-3 p-5 border-b border-white/5">
        <div className="w-10 h-10 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
          <Dumbbell className="w-5 h-5 text-orange-400" />
        </div>
        <h3 className="font-black uppercase tracking-wider text-white">Body Composition</h3>
        {bodyScoreMethod === 'ffmi' && (
          <span className="ml-auto px-3 py-1 text-[10px] font-black uppercase tracking-wider rounded-lg bg-orange-500/20 text-orange-400 border border-orange-500/30">
            FFMI
          </span>
        )}
      </div>

      <div className="p-5">
        <div className="grid grid-cols-2 gap-4">
          {/* Body Score */}
          <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4 text-center">
            <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2">Body Score</p>
            <p className="text-2xl font-black text-orange-400">{bodyRating.toFixed(1)}<span className="text-sm text-neutral-500">/10</span></p>
            <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mt-1">5% OF PSL</p>
          </div>

          {/* FFMI */}
          {ffmiData && (
            <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4 text-center">
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2">FFMI</p>
              <p className="text-2xl font-black" style={{ color: getFFMICategoryColor(ffmiData.category as 'Below Average' | 'Average' | 'Above Average' | 'Excellent' | 'Elite') }}>
                {ffmiData.normalizedFFMI.toFixed(1)}
              </p>
              <p className="text-[10px] font-black uppercase tracking-wider" style={{ color: getFFMICategoryColor(ffmiData.category as 'Below Average' | 'Average' | 'Above Average' | 'Excellent' | 'Elite') }}>
                {ffmiData.category}
              </p>
            </div>
          )}

          {/* Body Fat */}
          {bodyFatPercent !== undefined && (
            <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4 text-center">
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2">Body Fat</p>
              <p className="text-2xl font-black text-cyan-400">{bodyFatPercent}%</p>
              <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600 mt-1">
                {bodyFatPercent < 10 ? 'VERY LEAN' :
                 bodyFatPercent < 15 ? 'LEAN' :
                 bodyFatPercent < 20 ? 'ATHLETIC' :
                 bodyFatPercent < 25 ? 'AVERAGE' : 'ABOVE AVG'}
              </p>
            </div>
          )}

          {/* Lean Mass */}
          {ffmiData && (
            <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4 text-center">
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2">Lean Mass</p>
              <p className="text-2xl font-black text-green-400">
                {weightInputMode === 'imperial'
                  ? `${Math.round(ffmiData.leanMassKg * 2.20462)}`
                  : ffmiData.leanMassKg.toFixed(1)}
              </p>
              <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600 mt-1">
                {weightInputMode === 'imperial' ? 'LBS' : 'KG'}
              </p>
            </div>
          )}

          {/* Muscle Level (if no FFMI) */}
          {!ffmiData && muscleLevel && (
            <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4 text-center">
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2">Muscle Level</p>
              <p className="text-lg font-black text-purple-400 uppercase">{muscleLevel}</p>
            </div>
          )}
        </div>

        {/* FFMI Description */}
        {ffmiData && (
          <p className="mt-4 text-xs text-neutral-500 font-medium">
            {getFFMICategoryDescription(ffmiData.category as 'Below Average' | 'Average' | 'Above Average' | 'Excellent' | 'Elite', gender)}
          </p>
        )}
      </div>
    </motion.div>
  );
}

// Prompt to add physique photos
function AddPhysiquePrompt() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.15 }}
      className="rounded-2xl bg-neutral-900/40 border border-dashed border-white/10 p-5 hover:border-white/20 transition-colors"
    >
      <div className="flex items-center gap-4">
        <div className="w-12 h-12 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
          <Camera className="w-5 h-5 text-orange-400" />
        </div>
        <div className="flex-1">
          <h3 className="font-black uppercase tracking-wider text-white">Add Body Photos</h3>
          <p className="text-xs text-neutral-500 font-medium mt-1">
            Get accurate FFMI-based body scoring with physique photos
          </p>
        </div>
        <Link
          href="/physique"
          className="px-5 py-2.5 rounded-xl bg-orange-500/20 text-orange-400 text-[10px] font-black uppercase tracking-wider hover:bg-orange-500/30 border border-orange-500/30 transition-colors"
        >
          Add Photos
        </Link>
      </div>
      <div className="mt-4 flex items-center gap-2 text-[10px] font-bold uppercase tracking-wider text-neutral-600">
        <Percent className="w-3 h-3" />
        <span>Currently using default body score (5.0/10)</span>
      </div>
    </motion.div>
  );
}

// ============================================
// RECOMMENDED GUIDES SECTION (PSL-specific)
// ============================================

// Icon mapping for guides
const GUIDE_ICON_MAP: Record<string, React.ReactNode> = {
  BookOpen: <BookOpen size={18} />,
  Dumbbell: <Dumbbell size={18} />,
  Brain: <Brain size={18} />,
  Wrench: <Wrench size={18} />,
  TrendingDown: <TrendingDown size={18} />,
  Calendar: <Calendar size={18} />,
  Target: <Target size={18} />,
  Heart: <Heart size={18} />,
  Utensils: <Utensils size={18} />,
  Droplet: <Droplet size={18} />,
};

// PSL improvement guides - focused on body composition and physique
const PSL_GUIDE_IDS = ['body-fat', 'v-taper', 'training', 'diet', 'cardio', 'skincare'];

function PSLRecommendedGuides({ onOpenGuide }: { onOpenGuide: () => void }) {
  const guides = PSL_GUIDE_IDS
    .map((id) => getGuideById(id))
    .filter((g): g is Guide => g !== undefined)
    .slice(0, 3);

  if (guides.length === 0) return null;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.35 }}
      className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-6"
    >
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
          <BookOpen className="w-5 h-5 text-cyan-400" />
        </div>
        <h3 className="font-black uppercase tracking-wider text-white">Improvement Guides</h3>
        <span className="ml-auto px-3 py-1 text-[10px] font-black uppercase tracking-wider rounded-lg bg-green-500/20 text-green-400 border border-green-500/30">
          PSL BOOST
        </span>
      </div>

      <p className="text-sm text-neutral-500 font-medium mb-5">
        Optimize your body composition and physique to maximize your PSL score
      </p>

      <div className="grid gap-4 md:grid-cols-3">
        {guides.map((guide) => (
          <div
            key={guide.id}
            onClick={onOpenGuide}
            className="group rounded-xl bg-neutral-900/50 hover:bg-neutral-800/50 p-4 border border-white/5 hover:border-green-500/30 transition-all cursor-pointer"
          >
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-green-500/20 to-cyan-500/20 border border-white/10 flex items-center justify-center text-green-400 flex-shrink-0">
                {GUIDE_ICON_MAP[guide.icon] || <BookOpen size={18} />}
              </div>
              <h4 className="font-black uppercase tracking-wide text-white group-hover:text-green-400 transition-colors text-xs line-clamp-1">
                {guide.title}
              </h4>
            </div>
            <p className="text-[11px] text-neutral-500 line-clamp-2 mb-3">
              {guide.description}
            </p>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-neutral-600">
                <Clock size={10} />
                <span>{guide.estimatedReadTime} MIN</span>
              </div>
              <span className="text-[10px] font-black uppercase tracking-wider text-green-400 opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-1">
                READ
                <ArrowRight className="w-3 h-3" />
              </span>
            </div>
          </div>
        ))}
      </div>

      <button
        onClick={onOpenGuide}
        className="w-full mt-5 flex items-center justify-center gap-2 py-3 rounded-xl bg-neutral-900/50 border border-white/5 text-[10px] font-black uppercase tracking-wider text-neutral-500 hover:text-cyan-400 hover:border-white/10 transition-all"
      >
        <span>View All Guides</span>
        <ArrowRight className="w-4 h-4" />
      </button>
    </motion.div>
  );
}

// Map physique muscle mass string to MuscleLevel type
function mapMuscleLevel(muscleMass: string | undefined): MuscleLevel | undefined {
  if (!muscleMass) return undefined;
  const mapping: Record<string, MuscleLevel> = {
    'low': 'low',
    'medium': 'medium',
    'medium-high': 'medium-high',
    'high': 'high',
    'very-high': 'very-high',
    'extreme': 'extreme',
  };
  return mapping[muscleMass] || 'medium';
}

// Main PSL Tab component
export function PSLTab() {
  const { overallScore, gender, setActiveTab } = useResults();
  const heightContext = useHeightOptional();
  const weightContext = useWeightOptional();
  const physiqueContext = usePhysiqueOptional();

  // Local state for height if context not available
  const [localHeightCm, setLocalHeightCm] = useState<number | null>(null);

  // Handle guide opening - navigate to guides tab
  const handleOpenGuide = () => {
    setActiveTab('guides');
  };

  // Get height and weight from context or local state
  const heightCm = heightContext?.heightCm ?? localHeightCm;
  const setHeightCm = heightContext?.setHeightCm ?? setLocalHeightCm;
  const heightInputMode = heightContext?.inputMode ?? 'imperial';
  const weightKg = weightContext?.weightKg ?? null;
  const weightInputMode = weightContext?.inputMode ?? 'imperial';
  const bmi = weightContext?.bmi ?? null;

  // Get physique analysis from context
  const physiqueAnalysis = physiqueContext?.physiqueAnalysis ?? null;

  // Calculate PSL using the face score, height, and body analysis
  const pslResult: PSLResult | null = useMemo(() => {
    if (!heightCm || !overallScore) return null;

    // Use the overall harmony score as the face score
    const faceScore = typeof overallScore === 'number' ? overallScore : 0;
    const currentGender = gender || 'male';

    // Build body analysis if physique data is available
    const bodyAnalysis = physiqueAnalysis ? {
      bodyFatPercent: physiqueAnalysis.bodyFatPercent,
      muscleLevel: mapMuscleLevel(physiqueAnalysis.muscleMass) || 'medium',
      weightKg: weightKg ?? undefined,
    } : undefined;

    return calculatePSL({
      faceScore,
      heightCm,
      gender: currentGender,
      bodyAnalysis,
      weightKg: weightKg ?? undefined, // Pass weight for FFMI calculation
    });
  }, [heightCm, overallScore, gender, physiqueAnalysis, weightKg]);

  // Get height rating for display
  const heightRating = heightCm ? getHeightRating(heightCm, gender || 'male') : null;
  const heightDisplay = heightCm ? cmToFeetInches(heightCm) : null;

  // Format inches for display (show .5 for half inches, otherwise whole number)
  const formatInches = (inches: number): string => {
    return Number.isInteger(inches) ? inches.toString() : inches.toFixed(1);
  };

  return (
    <TabContent
      title="PSL Rating"
      subtitle="Your Pretty Scale Level score based on face, height, and body"
    >
      {/* Height prompt if not set */}
      {!heightCm && (
        <div className="mb-8">
          <HeightInputPrompt onHeightSet={setHeightCm} />
        </div>
      )}

      {/* PSL Results */}
      {pslResult && (
        <div className="space-y-8">
          {/* Main score card */}
          <PSLScoreCard psl={pslResult} showBreakdown showPotential />

          {/* Height & Weight info */}
          {(heightDisplay || weightKg) && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="rounded-2xl bg-neutral-900/40 border border-white/5 overflow-hidden"
            >
              {/* Height */}
              {heightDisplay && (
                <div className="flex items-center justify-between p-5 border-b border-white/5">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
                      <Ruler className="w-5 h-5 text-green-400" />
                    </div>
                    <div>
                      <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-1">Your Height</p>
                      <p className="text-lg font-black text-white">
                        {heightInputMode === 'imperial'
                          ? `${heightDisplay.feet}'${formatInches(heightDisplay.inches)}"`
                          : `${heightCm}cm`}
                        <span className="text-neutral-500 font-medium text-sm ml-2">
                          ({heightInputMode === 'imperial' ? `${heightCm}cm` : `${heightDisplay.feet}'${formatInches(heightDisplay.inches)}"`})
                        </span>
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-1">Height Rating</p>
                    <p className="text-xl font-black text-green-400">
                      {heightRating?.toFixed(1)}<span className="text-sm text-neutral-500">/10</span>
                    </p>
                  </div>
                </div>
              )}

              {/* Weight & BMI */}
              {weightKg && (
                <div className="flex items-center justify-between p-5">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
                      <Scale className="w-5 h-5 text-purple-400" />
                    </div>
                    <div>
                      <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-1">Your Weight</p>
                      <p className="text-lg font-black text-white">
                        {weightInputMode === 'imperial'
                          ? `${Math.round(weightKg * 2.20462)} lbs`
                          : `${weightKg} kg`}
                        <span className="text-neutral-500 font-medium text-sm ml-2">
                          ({weightInputMode === 'imperial' ? `${weightKg} kg` : `${Math.round(weightKg * 2.20462)} lbs`})
                        </span>
                      </p>
                    </div>
                  </div>
                  {bmi && (
                    <div className="text-right">
                      <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-1">BMI</p>
                      <p className={`text-xl font-black ${getBMIInfo(bmi).color}`}>
                        {bmi.toFixed(1)}
                      </p>
                      <p className={`text-[10px] font-black uppercase tracking-wider ${getBMIInfo(bmi).color}`}>
                        {getBMIInfo(bmi).category}
                      </p>
                    </div>
                  )}
                </div>
              )}
            </motion.div>
          )}

          {/* Body Composition - FFMI based scoring */}
          {pslResult.breakdown.bodyInfo?.method !== 'default' ? (
            <BodyCompositionCard
              ffmiData={pslResult.breakdown.bodyInfo?.ffmiData}
              bodyFatPercent={physiqueAnalysis?.bodyFatPercent}
              muscleLevel={physiqueAnalysis?.muscleMass}
              bodyScoreMethod={pslResult.breakdown.bodyInfo?.method || 'default'}
              bodyRating={pslResult.breakdown.body.raw}
              gender={gender || 'male'}
              weightInputMode={weightInputMode}
            />
          ) : (
            <AddPhysiquePrompt />
          )}

          {/* Recommended Guides for PSL improvement */}
          <PSLRecommendedGuides onOpenGuide={handleOpenGuide} />

          {/* Tier comparison */}
          <TierComparisonChart
            currentTier={pslResult.tier}
            currentScore={pslResult.score}
          />

          {/* Potential improvements */}
          {pslResult.potential > pslResult.score && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.4 }}
              className="rounded-[2rem] bg-gradient-to-r from-green-500/10 to-cyan-500/10 border border-green-500/20 p-6"
            >
              <div className="flex items-center gap-3 mb-6">
                <div className="w-12 h-12 rounded-xl bg-neutral-900 border border-green-500/30 flex items-center justify-center">
                  <TrendingUp className="w-6 h-6 text-green-400" />
                </div>
                <h3 className="font-black uppercase tracking-wider text-white">Improvement Potential</h3>
              </div>

              <div className="grid grid-cols-2 gap-4 mb-6">
                <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-5 text-center">
                  <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2">Current</p>
                  <p className="text-3xl font-black text-white">{pslResult.score.toFixed(2)}</p>
                  <div className="mt-2">
                    <PSLTierBadge tier={pslResult.tier} size="sm" />
                  </div>
                </div>
                <div className="rounded-xl bg-neutral-900/50 border border-green-500/20 p-5 text-center">
                  <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2">Potential</p>
                  <p className="text-3xl font-black text-green-400">{pslResult.potential.toFixed(2)}</p>
                  <p className="text-[10px] font-black uppercase tracking-wider text-green-400 mt-2">
                    +{(pslResult.potential - pslResult.score).toFixed(2)} GAIN
                  </p>
                </div>
              </div>

              <div className="space-y-3">
                <p className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 flex items-center gap-4">
                  To Reach Your Potential
                  <div className="flex-1 h-px bg-neutral-800" />
                </p>
                <ul className="space-y-2 text-sm text-neutral-400 font-medium">
                  <li className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 rounded-full bg-green-400" />
                    Optimize body composition (target 12-15% body fat)
                  </li>
                  <li className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 rounded-full bg-green-400" />
                    Follow personalized skincare and grooming
                  </li>
                  <li className="flex items-center gap-2">
                    <div className="w-1.5 h-1.5 rounded-full bg-green-400" />
                    Address soft tissue improvements from your plan
                  </li>
                </ul>
              </div>
            </motion.div>
          )}
        </div>
      )}

    </TabContent>
  );
}
