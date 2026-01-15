'use client';

import { useMemo, useState } from 'react';
import { motion } from 'framer-motion';
import {
  Ruler,
  Scale,
  Info,
  TrendingUp,
  Calculator,
  AlertCircle,
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
      className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
    >
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-lg bg-cyan-500/20 flex items-center justify-center">
          <Ruler className="w-5 h-5 text-cyan-400" />
        </div>
        <div>
          <h3 className="font-semibold text-white">Enter Your Height</h3>
          <p className="text-sm text-neutral-400">Required for PSL calculation</p>
        </div>
      </div>

      <div className="flex items-center gap-4 mb-4">
        <div className="flex-1">
          <label className="text-xs text-neutral-500 mb-1 block">Feet</label>
          <select
            value={feet}
            onChange={(e) => setFeet(Number(e.target.value))}
            className="w-full bg-neutral-800 border border-neutral-700 rounded-lg px-3 py-2 text-white"
          >
            {[4, 5, 6, 7].map((f) => (
              <option key={f} value={f}>{f}&apos;</option>
            ))}
          </select>
        </div>
        <div className="flex-1">
          <label className="text-xs text-neutral-500 mb-1 block">Inches</label>
          <select
            value={inches}
            onChange={(e) => setInches(Number(e.target.value))}
            className="w-full bg-neutral-800 border border-neutral-700 rounded-lg px-3 py-2 text-white"
          >
            {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((i) => (
              <option key={i} value={i}>{i}&quot;</option>
            ))}
          </select>
        </div>
      </div>

      <button
        onClick={handleSubmit}
        className="w-full py-2.5 bg-cyan-500 text-black font-medium rounded-lg hover:bg-cyan-400 transition-colors"
      >
        Calculate PSL
      </button>
    </motion.div>
  );
}

// Tier comparison visualization
function TierComparisonChart({ currentTier, currentScore }: { currentTier: string; currentScore: number }) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.2 }}
      className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
    >
      <h3 className="font-semibold text-white mb-4">Tier Distribution</h3>

      <div className="space-y-3">
        {TIER_DEFINITIONS.slice().reverse().map((tier) => {
          const isCurrentTier = tier.name === currentTier;
          const isPassed = currentScore >= tier.minScore;

          return (
            <div key={tier.name} className="flex items-center gap-3">
              <div
                className={`w-24 text-xs font-medium truncate ${
                  isCurrentTier ? 'text-white' : 'text-neutral-500'
                }`}
              >
                {tier.name}
              </div>

              <div className="flex-1 h-3 bg-neutral-800 rounded-full overflow-hidden relative">
                {/* Tier range */}
                <div
                  className="absolute inset-y-0 rounded-full transition-all"
                  style={{
                    left: `${(tier.minScore / 10) * 100}%`,
                    right: `${100 - (tier.maxScore / 10) * 100}%`,
                    backgroundColor: isPassed ? tier.color : `${tier.color}40`,
                  }}
                />

                {/* Current score marker */}
                {isCurrentTier && (
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    className="absolute top-1/2 -translate-y-1/2 w-4 h-4 rounded-full bg-white border-2 shadow-lg"
                    style={{
                      left: `${(currentScore / 10) * 100}%`,
                      borderColor: tier.color,
                      transform: 'translateX(-50%) translateY(-50%)',
                    }}
                  />
                )}
              </div>

              <div className={`w-16 text-right text-xs ${
                isCurrentTier ? 'text-white font-semibold' : 'text-neutral-500'
              }`}>
                {tier.minScore.toFixed(1)} - {tier.maxScore.toFixed(1)}
              </div>
            </div>
          );
        })}
      </div>

      {/* Score scale */}
      <div className="flex justify-between mt-4 text-xs text-neutral-500">
        <span>0</span>
        <span>2</span>
        <span>4</span>
        <span>6</span>
        <span>8</span>
        <span>10</span>
      </div>
    </motion.div>
  );
}

// PSL Formula explanation
function PSLFormulaExplainer({ bodyMethod }: { bodyMethod?: 'ffmi' | 'table' | 'default' }) {
  const bodyDescription = bodyMethod === 'ffmi'
    ? 'Body composition via FFMI (5% weight) - calculated from your height, weight, and body fat'
    : bodyMethod === 'table'
    ? 'Body composition (5% weight) - based on body fat % and muscle level'
    : 'Body composition (5% weight) - defaults to 5/10 without physique data';

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.3 }}
      className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
    >
      <div className="flex items-center gap-2 mb-4">
        <Calculator className="w-5 h-5 text-cyan-400" />
        <h3 className="font-semibold text-white">How PSL is Calculated</h3>
      </div>

      <div className="bg-neutral-800/50 rounded-lg p-4 mb-4 font-mono text-sm">
        <span className="text-cyan-400">PSL</span>
        <span className="text-neutral-400"> = </span>
        <span className="text-purple-400">(Face × 0.75)</span>
        <span className="text-neutral-400"> + </span>
        <span className="text-green-400">(Height × 0.20)</span>
        <span className="text-neutral-400"> + </span>
        <span className="text-orange-400">(Body × 0.05)</span>
        <span className="text-neutral-400"> + </span>
        <span className="text-yellow-400">Bonuses</span>
      </div>

      <div className="space-y-3 text-sm">
        <div className="flex items-start gap-2">
          <span className="text-purple-400 font-semibold w-16">Face</span>
          <span className="text-neutral-400">
            Your facial harmony score (75% weight) - the primary driver of attractiveness
          </span>
        </div>
        <div className="flex items-start gap-2">
          <span className="text-green-400 font-semibold w-16">Height</span>
          <span className="text-neutral-400">
            Your height rating (20% weight) - varies by gender
          </span>
        </div>
        <div className="flex items-start gap-2">
          <span className="text-orange-400 font-semibold w-16">Body</span>
          <span className="text-neutral-400">
            {bodyDescription}
          </span>
        </div>
        <div className="flex items-start gap-2">
          <span className="text-yellow-400 font-semibold w-16">Bonuses</span>
          <span className="text-neutral-400">
            Threshold (+0.1-0.3) and synergy (+0.05-0.35) bonuses for elite scores (≥8.5)
          </span>
        </div>
      </div>

      <div className="mt-4 p-3 bg-amber-500/10 border border-amber-500/30 rounded-lg flex items-start gap-2">
        <AlertCircle className="w-4 h-4 text-amber-400 flex-shrink-0 mt-0.5" />
        <p className="text-xs text-amber-200">
          Height ≥8.0 rating is required to reach Gigachad tier. Major facial flaws cap your tier regardless of score.
        </p>
      </div>
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
      className="bg-neutral-900 rounded-xl p-4 border border-neutral-800"
    >
      <div className="flex items-center gap-2 mb-4">
        <Dumbbell className="w-5 h-5 text-orange-400" />
        <h3 className="font-semibold text-white">Body Composition</h3>
        {bodyScoreMethod === 'ffmi' && (
          <span className="ml-auto text-xs bg-orange-500/20 text-orange-400 px-2 py-0.5 rounded-full">
            FFMI
          </span>
        )}
      </div>

      <div className="grid grid-cols-2 gap-4">
        {/* Body Score */}
        <div className="bg-neutral-800/50 rounded-lg p-3 text-center">
          <p className="text-xs text-neutral-400 mb-1">Body Score</p>
          <p className="text-xl font-bold text-orange-400">{bodyRating.toFixed(1)}/10</p>
          <p className="text-xs text-neutral-500 mt-1">5% of PSL</p>
        </div>

        {/* FFMI */}
        {ffmiData && (
          <div className="bg-neutral-800/50 rounded-lg p-3 text-center">
            <p className="text-xs text-neutral-400 mb-1">FFMI</p>
            <p className="text-xl font-bold" style={{ color: getFFMICategoryColor(ffmiData.category as 'Below Average' | 'Average' | 'Above Average' | 'Excellent' | 'Elite') }}>
              {ffmiData.normalizedFFMI.toFixed(1)}
            </p>
            <p className="text-xs" style={{ color: getFFMICategoryColor(ffmiData.category as 'Below Average' | 'Average' | 'Above Average' | 'Excellent' | 'Elite') }}>
              {ffmiData.category}
            </p>
          </div>
        )}

        {/* Body Fat */}
        {bodyFatPercent !== undefined && (
          <div className="bg-neutral-800/50 rounded-lg p-3 text-center">
            <p className="text-xs text-neutral-400 mb-1">Body Fat</p>
            <p className="text-xl font-bold text-cyan-400">{bodyFatPercent}%</p>
            <p className="text-xs text-neutral-500 mt-1">
              {bodyFatPercent < 10 ? 'Very Lean' :
               bodyFatPercent < 15 ? 'Lean' :
               bodyFatPercent < 20 ? 'Athletic' :
               bodyFatPercent < 25 ? 'Average' : 'Above Average'}
            </p>
          </div>
        )}

        {/* Lean Mass */}
        {ffmiData && (
          <div className="bg-neutral-800/50 rounded-lg p-3 text-center">
            <p className="text-xs text-neutral-400 mb-1">Lean Mass</p>
            <p className="text-xl font-bold text-green-400">
              {weightInputMode === 'imperial'
                ? `${Math.round(ffmiData.leanMassKg * 2.20462)} lbs`
                : `${ffmiData.leanMassKg.toFixed(1)} kg`}
            </p>
            <p className="text-xs text-neutral-500 mt-1">
              {weightInputMode === 'imperial'
                ? `${ffmiData.leanMassKg.toFixed(1)} kg`
                : `${Math.round(ffmiData.leanMassKg * 2.20462)} lbs`}
            </p>
          </div>
        )}

        {/* Muscle Level (if no FFMI) */}
        {!ffmiData && muscleLevel && (
          <div className="bg-neutral-800/50 rounded-lg p-3 text-center">
            <p className="text-xs text-neutral-400 mb-1">Muscle Level</p>
            <p className="text-lg font-bold text-purple-400 capitalize">{muscleLevel}</p>
          </div>
        )}
      </div>

      {/* FFMI Description */}
      {ffmiData && (
        <p className="mt-3 text-xs text-neutral-400">
          {getFFMICategoryDescription(ffmiData.category as 'Below Average' | 'Average' | 'Above Average' | 'Excellent' | 'Elite', gender)}
        </p>
      )}
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
      className="bg-neutral-900 rounded-xl p-4 border border-neutral-800 border-dashed"
    >
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-lg bg-orange-500/20 flex items-center justify-center">
          <Camera className="w-5 h-5 text-orange-400" />
        </div>
        <div className="flex-1">
          <h3 className="font-semibold text-white">Add Body Photos</h3>
          <p className="text-sm text-neutral-400">
            Get accurate FFMI-based body scoring with physique photos
          </p>
        </div>
        <Link
          href="/physique"
          className="px-4 py-2 bg-orange-500/20 text-orange-400 rounded-lg text-sm font-medium hover:bg-orange-500/30 transition-colors"
        >
          Add Photos
        </Link>
      </div>
      <div className="mt-3 flex items-center gap-2 text-xs text-neutral-500">
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
      className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
    >
      <div className="flex items-center gap-2 mb-4">
        <BookOpen className="w-5 h-5 text-cyan-400" />
        <h3 className="font-semibold text-white">Improvement Guides</h3>
        <span className="px-2 py-0.5 text-xs font-medium rounded border bg-green-500/20 text-green-400 border-green-500/40">
          PSL Boost
        </span>
      </div>

      <p className="text-sm text-neutral-400 mb-4">
        Optimize your body composition and physique to maximize your PSL score
      </p>

      <div className="grid gap-3 md:grid-cols-3">
        {guides.map((guide) => (
          <div
            key={guide.id}
            onClick={onOpenGuide}
            className="group bg-neutral-800/50 hover:bg-neutral-800 rounded-lg p-4 border border-neutral-700 hover:border-green-500/30 transition-all cursor-pointer"
          >
            <div className="flex items-center gap-3 mb-2">
              <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-green-500/20 to-cyan-500/20 flex items-center justify-center text-green-400 flex-shrink-0">
                {GUIDE_ICON_MAP[guide.icon] || <BookOpen size={18} />}
              </div>
              <h4 className="font-medium text-white group-hover:text-green-400 transition-colors text-sm line-clamp-1">
                {guide.title}
              </h4>
            </div>
            <p className="text-xs text-neutral-400 line-clamp-2 mb-2">
              {guide.description}
            </p>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-1 text-xs text-neutral-500">
                <Clock size={12} />
                <span>{guide.estimatedReadTime} min</span>
              </div>
              <span className="text-xs text-green-400 opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-1">
                Read
                <ArrowRight className="w-3 h-3" />
              </span>
            </div>
          </div>
        ))}
      </div>

      <button
        onClick={onOpenGuide}
        className="w-full mt-4 flex items-center justify-center gap-2 py-2 text-sm text-neutral-400 hover:text-white transition-colors"
      >
        <span>View all guides</span>
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
        <div className="mb-6">
          <HeightInputPrompt onHeightSet={setHeightCm} />
        </div>
      )}

      {/* PSL Results */}
      {pslResult && (
        <div className="space-y-6">
          {/* Main score card */}
          <PSLScoreCard psl={pslResult} showBreakdown showPotential />

          {/* Height & Weight info */}
          {(heightDisplay || weightKg) && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-neutral-900 rounded-xl p-4 border border-neutral-800 space-y-4"
            >
              {/* Height */}
              {heightDisplay && (
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-green-500/20 flex items-center justify-center">
                      <Ruler className="w-5 h-5 text-green-400" />
                    </div>
                    <div>
                      <p className="text-sm text-neutral-400">Your Height</p>
                      <p className="text-lg font-semibold text-white">
                        {heightInputMode === 'imperial'
                          ? `${heightDisplay.feet}'${formatInches(heightDisplay.inches)}" (${heightCm}cm)`
                          : `${heightCm}cm (${heightDisplay.feet}'${formatInches(heightDisplay.inches)}")`}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-neutral-400">Height Rating</p>
                    <p className="text-lg font-bold text-green-400">
                      {heightRating?.toFixed(1)}/10
                    </p>
                  </div>
                </div>
              )}

              {/* Divider */}
              {heightDisplay && weightKg && (
                <div className="border-t border-neutral-800" />
              )}

              {/* Weight & BMI */}
              {weightKg && (
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-purple-500/20 flex items-center justify-center">
                      <Scale className="w-5 h-5 text-purple-400" />
                    </div>
                    <div>
                      <p className="text-sm text-neutral-400">Your Weight</p>
                      <p className="text-lg font-semibold text-white">
                        {weightInputMode === 'imperial'
                          ? `${Math.round(weightKg * 2.20462)} lbs (${weightKg} kg)`
                          : `${weightKg} kg (${Math.round(weightKg * 2.20462)} lbs)`}
                      </p>
                    </div>
                  </div>
                  {bmi && (
                    <div className="text-right">
                      <p className="text-sm text-neutral-400">BMI</p>
                      <p className={`text-lg font-bold ${getBMIInfo(bmi).color}`}>
                        {bmi.toFixed(1)}
                      </p>
                      <p className={`text-xs ${getBMIInfo(bmi).color}`}>
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

          {/* Formula explainer */}
          <PSLFormulaExplainer bodyMethod={pslResult.breakdown.bodyInfo?.method} />

          {/* Potential improvements */}
          {pslResult.potential > pslResult.score && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.4 }}
              className="bg-gradient-to-r from-green-500/10 to-cyan-500/10 rounded-xl p-6 border border-green-500/20"
            >
              <div className="flex items-center gap-3 mb-4">
                <TrendingUp className="w-6 h-6 text-green-400" />
                <h3 className="font-semibold text-white">Improvement Potential</h3>
              </div>

              <div className="grid grid-cols-2 gap-4 mb-4">
                <div className="bg-neutral-900/50 rounded-lg p-4 text-center">
                  <p className="text-sm text-neutral-400 mb-1">Current</p>
                  <p className="text-2xl font-bold text-white">{pslResult.score.toFixed(2)}</p>
                  <PSLTierBadge tier={pslResult.tier} size="sm" />
                </div>
                <div className="bg-neutral-900/50 rounded-lg p-4 text-center">
                  <p className="text-sm text-neutral-400 mb-1">Potential</p>
                  <p className="text-2xl font-bold text-green-400">{pslResult.potential.toFixed(2)}</p>
                  <p className="text-xs text-green-400 mt-1">
                    +{(pslResult.potential - pslResult.score).toFixed(2)} gain
                  </p>
                </div>
              </div>

              <div className="space-y-2 text-sm text-neutral-400">
                <p>To reach your potential:</p>
                <ul className="list-disc list-inside space-y-1 text-neutral-300">
                  <li>Optimize body composition (target 12-15% body fat)</li>
                  <li>Follow personalized skincare and grooming</li>
                  <li>Address soft tissue improvements from your plan</li>
                </ul>
              </div>
            </motion.div>
          )}
        </div>
      )}

      {/* Info section */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
        className="mt-6 p-4 bg-neutral-900/50 rounded-lg border border-neutral-800"
      >
        <div className="flex items-start gap-2">
          <Info className="w-4 h-4 text-neutral-500 flex-shrink-0 mt-0.5" />
          <p className="text-xs text-neutral-500">
            PSL (Pretty Scale Level) is a comprehensive attractiveness rating that combines
            facial harmony (75%), height (20%), and body composition (5%). Bonuses are applied
            for exceptional scores (≥8.5) in any category, with synergy bonuses for multiple
            high-scoring areas.
          </p>
        </div>
      </motion.div>
    </TabContent>
  );
}
