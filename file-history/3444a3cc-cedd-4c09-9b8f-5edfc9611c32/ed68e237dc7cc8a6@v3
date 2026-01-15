'use client';

import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, Sparkles, AlertTriangle } from 'lucide-react';
import { Strength, Flaw, ResponsibleRatio, Recommendation, getScoreColor } from '@/types/results';
import { useResults } from '@/contexts/ResultsContext';

// ============================================
// QUALITY BADGE COMPONENT (FaceIQ Light Theme Style)
// ============================================

type QualityLevel = 'ideal' | 'excellent' | 'good' | 'below_average';

interface QualityBadgeConfig {
  label: string;
  textColor: string;
  bgColor: string;
}

const QUALITY_CONFIGS: Record<QualityLevel, QualityBadgeConfig> = {
  ideal: {
    label: 'Ideal',
    textColor: 'rgb(8, 145, 178)',    // cyan-600
    bgColor: 'rgb(207, 250, 254)',    // cyan-100
  },
  excellent: {
    label: 'Excellent',
    textColor: 'rgb(4, 120, 87)',     // emerald-700
    bgColor: 'rgb(209, 250, 229)',    // emerald-100
  },
  good: {
    label: 'Good',
    textColor: 'rgb(21, 128, 61)',    // green-700
    bgColor: 'rgb(220, 252, 231)',    // green-100
  },
  below_average: {
    label: 'Average',
    textColor: 'rgb(113, 113, 122)',  // gray-500
    bgColor: 'rgb(244, 244, 245)',    // gray-100
  },
};

function QualityBadge({ quality }: { quality: QualityLevel }) {
  const config = QUALITY_CONFIGS[quality] || QUALITY_CONFIGS.good;

  return (
    <span
      className="px-2 py-0.5 sm:px-2.5 sm:py-1 rounded-md text-[10px] sm:text-xs font-medium tracking-wide whitespace-nowrap flex-shrink-0"
      style={{
        color: config.textColor,
        backgroundColor: config.bgColor,
      }}
    >
      {config.label}
    </span>
  );
}

// ============================================
// SEVERITY BADGE COMPONENT (FaceIQ Style)
// ============================================

type SeverityLevel = 'extremely_severe' | 'severe' | 'moderate' | 'minor';

interface SeverityBadgeConfig {
  label: string;
  textColor: string;
  bgColor: string;
  borderColor?: string;
}

const SEVERITY_CONFIGS: Record<SeverityLevel, SeverityBadgeConfig> = {
  extremely_severe: {
    label: 'extremely severe',
    textColor: 'rgb(127, 29, 29)',     // red-900
    bgColor: 'rgb(254, 202, 202)',     // red-200
  },
  severe: {
    label: 'severe',
    textColor: 'rgb(185, 28, 28)',     // red-700
    bgColor: 'rgb(254, 226, 226)',     // red-50
    borderColor: 'rgb(254, 202, 202)', // red-200
  },
  moderate: {
    label: 'moderate',
    textColor: 'rgb(194, 65, 12)',     // orange-700
    bgColor: 'rgb(255, 237, 213)',     // orange-50
    borderColor: 'rgb(254, 215, 170)', // orange-200
  },
  minor: {
    label: 'minor',
    textColor: 'rgb(161, 98, 7)',      // yellow-700
    bgColor: 'rgb(254, 249, 195)',     // yellow-50
    borderColor: 'rgb(254, 240, 138)', // yellow-200
  },
};

function getSeverityFromImpact(harmonyLost: number): SeverityLevel {
  // Handle edge cases: NaN, Infinity, undefined, null, negative
  if (
    typeof harmonyLost !== 'number' ||
    !Number.isFinite(harmonyLost) ||
    Number.isNaN(harmonyLost) ||
    harmonyLost < 0
  ) {
    return 'minor'; // Default to least severe for invalid values
  }
  if (harmonyLost >= 0.8) return 'extremely_severe';
  if (harmonyLost >= 0.5) return 'severe';
  if (harmonyLost >= 0.3) return 'moderate';
  return 'minor';
}

function SeverityBadge({ severity }: { severity: SeverityLevel }) {
  const config = SEVERITY_CONFIGS[severity] || SEVERITY_CONFIGS.moderate;

  return (
    <span
      className="px-2 py-0.5 sm:px-2.5 sm:py-1 rounded-md text-[10px] sm:text-xs font-medium tracking-wide whitespace-nowrap flex-shrink-0"
      style={{
        color: config.textColor,
        backgroundColor: config.bgColor,
        border: config.borderColor ? `1px solid ${config.borderColor}` : undefined,
      }}
    >
      {config.label}
    </span>
  );
}

// ============================================
// PROCEDURE PHASE BADGE
// ============================================

type ProcedurePhase = 'Foundational' | 'Non-Invasive' | 'Minimally Invasive' | 'Surgical';

interface PhaseConfig {
  textColor: string;
  bgColor: string;
}

const PHASE_CONFIGS: Record<ProcedurePhase, PhaseConfig> = {
  Foundational: {
    textColor: 'rgb(4, 120, 87)',     // emerald-700
    bgColor: 'rgb(209, 250, 229)',    // emerald-50
  },
  'Non-Invasive': {
    textColor: 'rgb(29, 78, 216)',    // blue-700
    bgColor: 'rgb(219, 234, 254)',    // blue-50
  },
  'Minimally Invasive': {
    textColor: 'rgb(109, 40, 217)',   // violet-700
    bgColor: 'rgb(237, 233, 254)',    // violet-50
  },
  Surgical: {
    textColor: 'rgb(126, 34, 206)',   // purple-700
    bgColor: 'rgb(243, 232, 255)',    // purple-50
  },
};

function PhaseBadge({ phase }: { phase: ProcedurePhase }) {
  const config = PHASE_CONFIGS[phase] || PHASE_CONFIGS['Non-Invasive'];

  return (
    <span
      className="px-1.5 py-0.5 rounded text-[9px] sm:text-[10px] font-medium"
      style={{
        color: config.textColor,
        backgroundColor: config.bgColor,
      }}
    >
      {phase}
    </span>
  );
}

// ============================================
// CONTRIBUTING RATIO BUTTON (FaceIQ Style - Dark Theme)
// ============================================

interface ContributingRatioButtonProps {
  ratioName: string;
  score: number;
  onClick: () => void;
  animationDelay?: number;
}

function ContributingRatioButton({
  ratioName,
  score,
  onClick,
  animationDelay = 0,
}: ContributingRatioButtonProps) {
  const color = getScoreColor(score);

  return (
    <motion.button
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.2, delay: animationDelay }}
      onClick={onClick}
      className="w-full flex items-center justify-between py-2 sm:py-2.5 px-2.5 sm:px-3 rounded-lg border transition-all text-left cursor-pointer group bg-neutral-900/80 border-neutral-800 hover:border-neutral-700 hover:bg-neutral-800/50"
    >
      <span className="text-xs sm:text-sm font-medium transition-colors text-neutral-200 group-hover:text-white">
        {ratioName}
      </span>
      <div className="flex items-baseline gap-0.5 sm:gap-1">
        <span className="text-xs sm:text-sm font-semibold" style={{ color }}>
          {score.toFixed(1)}
        </span>
        <span className="text-[10px] sm:text-xs text-neutral-500">/10</span>
      </div>
    </motion.button>
  );
}

// ============================================
// PLAN ITEM (Recommendation in "Your Plan" section)
// ============================================

interface PlanItemProps {
  name: string;
  phase: ProcedurePhase;
  animationDelay?: number;
}

function PlanItem({ name, phase, animationDelay = 0 }: PlanItemProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.2, delay: animationDelay }}
      className="flex items-center justify-between py-2 sm:py-2.5 px-2.5 sm:px-3 rounded-lg bg-neutral-900/80 border border-neutral-800"
    >
      <span className="text-xs sm:text-sm text-neutral-200 font-medium">{name}</span>
      <div className="flex items-center gap-2">
        <span className="text-[9px] sm:text-[10px] px-1.5 py-0.5 rounded bg-emerald-500/20 text-emerald-400 font-medium">
          In Plan
        </span>
        <PhaseBadge phase={phase} />
      </div>
    </motion.div>
  );
}

// ============================================
// KEY STRENGTH CARD (FaceIQ Style)
// ============================================

interface KeyStrengthCardProps {
  strength: Strength;
  isExpanded: boolean;
  onToggle: () => void;
  onRatioClick: (ratio: ResponsibleRatio) => void;
  animationDelay?: number;
}

function KeyStrengthCard({
  strength,
  isExpanded,
  onToggle,
  onRatioClick,
  animationDelay = 0,
}: KeyStrengthCardProps) {
  const color = getScoreColor(strength.avgScore);

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, delay: animationDelay }}
      className={`rounded-xl bg-neutral-900/80 border overflow-hidden transition-all duration-200 ${
        isExpanded ? 'border-cyan-500/30' : 'border-neutral-800 hover:border-neutral-700'
      }`}
    >
      {/* Header Button */}
      <button
        onClick={onToggle}
        className="w-full p-4 sm:p-5 hover:bg-neutral-800/30 transition-colors duration-200 text-left"
      >
        <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3 sm:gap-4">
          {/* Left: Badge + Content */}
          <div className="flex items-start gap-2 sm:gap-3 flex-1 min-w-0">
            <QualityBadge quality={strength.qualityLevel} />
            <div className="flex-1 min-w-0">
              <h4 className="text-sm sm:text-base font-semibold text-white mb-1 sm:mb-1.5 leading-snug">
                {strength.strengthName}
              </h4>
              <p className="text-xs sm:text-sm text-neutral-400 leading-relaxed line-clamp-2">
                {strength.summary}
              </p>
            </div>
          </div>

          {/* Right: Score + Chevron */}
          <div className="flex items-center justify-between sm:justify-end gap-3 sm:gap-4 flex-shrink-0 sm:flex-col sm:items-end sm:gap-1.5">
            <div className="text-right">
              <div
                className="text-lg sm:text-xl font-semibold tracking-tight"
                style={{ color }}
              >
                {strength.avgScore.toFixed(2)}
              </div>
              <div className="text-[10px] sm:text-xs text-neutral-500 font-medium mt-0.5">avg /10</div>
            </div>
            <motion.div
              animate={{ rotate: isExpanded ? 180 : 0 }}
              transition={{ duration: 0.3 }}
            >
              <ChevronDown className="w-4 h-4 text-neutral-400" />
            </motion.div>
          </div>
        </div>
      </button>

      {/* Expanded Content */}
      <AnimatePresence initial={false}>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="overflow-hidden"
          >
            <div className="border-t border-neutral-800 bg-neutral-800/30 px-4 sm:px-5 py-3 sm:py-4">
              <div className="text-[10px] sm:text-xs font-medium text-neutral-500 uppercase tracking-wider mb-2 sm:mb-3">
                Contributing Ratios
              </div>
              <div className="space-y-2">
                {strength.responsibleRatios.map((ratio, i) => (
                  <ContributingRatioButton
                    key={ratio.ratioId}
                    ratioName={ratio.ratioName}
                    score={ratio.score}
                    onClick={() => onRatioClick(ratio)}
                    animationDelay={i * 0.05}
                  />
                ))}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

// ============================================
// AREA OF IMPROVEMENT CARD (FaceIQ Style with Your Plan)
// ============================================

interface AreaOfImprovementCardProps {
  flaw: Flaw;
  isExpanded: boolean;
  onToggle: () => void;
  onRatioClick: (ratio: ResponsibleRatio) => void;
  recommendations?: Recommendation[];
  animationDelay?: number;
}

function AreaOfImprovementCard({
  flaw,
  isExpanded,
  onToggle,
  onRatioClick,
  recommendations = [],
  animationDelay = 0,
}: AreaOfImprovementCardProps) {
  const severity = getSeverityFromImpact(flaw.harmonyPercentageLost);

  // Find matching recommendations for this flaw
  const matchedRecommendations = useMemo(() => {
    const flawRatioIds = new Set(flaw.responsibleRatios.map(r => r.ratioId));
    return recommendations.filter(rec =>
      rec.matchedFlaws?.some(f => f.toLowerCase().includes(flaw.flawName.toLowerCase())) ||
      rec.matchedRatios?.some(r => flawRatioIds.has(r))
    ).slice(0, 3);
  }, [flaw, recommendations]);

  // Map phase names
  const mapPhase = (phase: string): ProcedurePhase => {
    if (phase === 'Foundational') return 'Foundational';
    if (phase === 'Non-Invasive' || phase === 'Minimally Invasive') return phase as ProcedurePhase;
    if (phase === 'Surgical') return 'Surgical';
    return 'Non-Invasive';
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, delay: animationDelay }}
      className={`rounded-xl bg-neutral-900/80 border overflow-hidden transition-all duration-200 ${
        isExpanded ? 'border-red-500/30' : 'border-neutral-800 hover:border-neutral-700'
      }`}
    >
      {/* Header Button */}
      <button
        onClick={onToggle}
        className="w-full p-4 sm:p-5 hover:bg-neutral-800/30 transition-colors duration-200 text-left"
      >
        <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3 sm:gap-4">
          {/* Left: Badge + Content */}
          <div className="flex items-start gap-2 sm:gap-3 flex-1 min-w-0">
            <SeverityBadge severity={severity} />
            <div className="flex-1 min-w-0">
              <h4 className="text-sm sm:text-base font-semibold text-white mb-1 sm:mb-1.5 leading-snug">
                {flaw.flawName}
              </h4>
              <p className="text-xs sm:text-sm text-neutral-400 leading-relaxed line-clamp-2">
                {flaw.summary}
              </p>
            </div>
          </div>

          {/* Right: Points impact + Chevron */}
          <div className="flex items-center justify-between sm:justify-end gap-3 sm:gap-4 flex-shrink-0 sm:flex-col sm:items-end sm:gap-1.5">
            <div className="text-right space-y-1">
              <div className="text-lg sm:text-xl font-semibold tracking-tight text-red-500">
                -{(typeof flaw.harmonyPercentageLost === 'number' && Number.isFinite(flaw.harmonyPercentageLost)
                  ? flaw.harmonyPercentageLost
                  : 0
                ).toFixed(2)}
              </div>
              <div className="text-[10px] sm:text-xs text-neutral-500 font-medium">points</div>
              {flaw.rollingHarmonyPercentageLost !== undefined &&
                typeof flaw.rollingHarmonyPercentageLost === 'number' &&
                Number.isFinite(flaw.rollingHarmonyPercentageLost) && (
                <div className="text-[10px] text-neutral-600 font-medium pt-0.5 border-t border-neutral-700 mt-1">
                  Rolling: -{flaw.rollingHarmonyPercentageLost.toFixed(2)}
                </div>
              )}
            </div>
            <motion.div
              animate={{ rotate: isExpanded ? 180 : 0 }}
              transition={{ duration: 0.3 }}
            >
              <ChevronDown className="w-4 h-4 text-neutral-400" />
            </motion.div>
          </div>
        </div>
      </button>

      {/* Expanded Content */}
      <AnimatePresence initial={false}>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="overflow-hidden"
          >
            {/* Affected Ratios Section */}
            <div className="border-t border-neutral-800 bg-neutral-800/30 px-4 sm:px-5 py-3 sm:py-4">
              <div className="text-[10px] sm:text-xs font-medium text-neutral-500 uppercase tracking-wider mb-2 sm:mb-3">
                Affected Ratios
              </div>
              <div className="space-y-2">
                {flaw.responsibleRatios.map((ratio, i) => (
                  <ContributingRatioButton
                    key={ratio.ratioId}
                    ratioName={ratio.ratioName}
                    score={ratio.score}
                    onClick={() => onRatioClick(ratio)}
                    animationDelay={i * 0.05}
                  />
                ))}
              </div>
            </div>

            {/* Your Plan Section (if there are matched recommendations) */}
            {matchedRecommendations.length > 0 && (
              <div className="border-t border-neutral-800 bg-emerald-900/10 px-4 sm:px-5 py-3 sm:py-4">
                <div className="flex items-center gap-1.5 mb-2 sm:mb-3">
                  <Sparkles className="w-3 h-3 text-emerald-400" />
                  <span className="text-[10px] sm:text-xs font-medium text-emerald-400 uppercase tracking-wider">
                    Your Plan
                  </span>
                </div>
                <div className="space-y-2">
                  {matchedRecommendations.map((rec, i) => (
                    <PlanItem
                      key={rec.ref_id}
                      name={rec.name}
                      phase={mapPhase(rec.phase)}
                      animationDelay={i * 0.05}
                    />
                  ))}
                </div>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

// ============================================
// KEY STRENGTHS SECTION (FaceIQ Style)
// ============================================

interface KeyStrengthsSectionProps {
  strengths: Strength[];
  onRatioClick: (ratio: ResponsibleRatio, categoryName: string) => void;
  initialShowCount?: number;
}

export function KeyStrengthsSection({
  strengths,
  onRatioClick,
  initialShowCount = 3,
}: KeyStrengthsSectionProps) {
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [showAll, setShowAll] = useState(false);

  const displayedStrengths = showAll ? strengths : strengths.slice(0, initialShowCount);
  const remainingCount = Math.max(0, strengths.length - initialShowCount);

  // Calculate average strength contribution (handle invalid values)
  const avgScore = useMemo(() => {
    if (!strengths || strengths.length === 0) return 0;
    const validScores = strengths.filter(
      (s) => typeof s.avgScore === 'number' && Number.isFinite(s.avgScore)
    );
    if (validScores.length === 0) return 0;
    return validScores.reduce((sum, s) => sum + s.avgScore, 0) / validScores.length;
  }, [strengths]);

  return (
    <div className="rounded-xl bg-neutral-900/50 border border-neutral-800 p-4 sm:p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-4 sm:mb-5">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-cyan-500/20 flex items-center justify-center">
            <Sparkles className="w-4 h-4 text-cyan-400" />
          </div>
          <h3 className="text-base sm:text-lg font-semibold tracking-tight text-white">
            Key Strengths
          </h3>
        </div>
        <div className="text-right">
          <span className="text-sm text-neutral-500">
            {strengths.length} total
          </span>
          {strengths.length > 0 && (
            <p className="text-xs text-green-400 font-medium">
              Avg: {avgScore.toFixed(1)}/10
            </p>
          )}
        </div>
      </div>

      {/* Cards */}
      <div className="space-y-3">
        {displayedStrengths.length > 0 ? (
          displayedStrengths.map((strength, i) => (
            <KeyStrengthCard
              key={strength.id}
              strength={strength}
              isExpanded={expandedId === strength.id}
              onToggle={() => setExpandedId(expandedId === strength.id ? null : strength.id)}
              onRatioClick={(ratio) => onRatioClick(ratio, strength.categoryName)}
              animationDelay={i * 0.04}
            />
          ))
        ) : (
          <div className="rounded-xl bg-neutral-800/50 border border-neutral-700 p-6 text-center">
            <p className="text-neutral-500">No significant strengths detected</p>
          </div>
        )}
      </div>

      {/* Show More Button */}
      {remainingCount > 0 && (
        <button
          onClick={() => setShowAll(!showAll)}
          className="w-full mt-4 py-3 rounded-lg bg-neutral-800/50 border border-neutral-700 hover:border-neutral-600 hover:bg-neutral-800 transition-all duration-200 text-sm font-medium text-white"
        >
          <span className="flex items-center justify-center gap-2">
            <span>{showAll ? 'Show Less' : `Show ${remainingCount} More`}</span>
            <motion.div animate={{ rotate: showAll ? 180 : 0 }} transition={{ duration: 0.2 }}>
              <ChevronDown className="w-4 h-4 text-neutral-400" />
            </motion.div>
          </span>
        </button>
      )}
    </div>
  );
}

// ============================================
// AREAS OF IMPROVEMENT SECTION (FaceIQ Style with Your Plan)
// ============================================

interface AreasOfImprovementSectionProps {
  flaws: Flaw[];
  onRatioClick: (ratio: ResponsibleRatio, categoryName: string) => void;
  initialShowCount?: number;
}

export function AreasOfImprovementSection({
  flaws,
  onRatioClick,
  initialShowCount = 3,
}: AreasOfImprovementSectionProps) {
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [showAll, setShowAll] = useState(false);

  // Get recommendations from context
  const { recommendations } = useResults();

  const displayedFlaws = showAll ? flaws : flaws.slice(0, initialShowCount);
  const remainingCount = Math.max(0, flaws.length - initialShowCount);

  // Calculate total impact from all flaws (handle invalid values)
  const totalImpact = flaws.reduce((sum, f) => {
    const impact = typeof f.harmonyPercentageLost === 'number' && Number.isFinite(f.harmonyPercentageLost)
      ? f.harmonyPercentageLost
      : 0;
    return sum + impact;
  }, 0);

  return (
    <div className="rounded-xl bg-neutral-900/50 border border-neutral-800 p-4 sm:p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-4 sm:mb-5">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-amber-500/20 flex items-center justify-center">
            <AlertTriangle className="w-4 h-4 text-amber-400" />
          </div>
          <h3 className="text-base sm:text-lg font-semibold tracking-tight text-white">
            Areas of Improvement
          </h3>
        </div>
        <div className="text-right">
          <span className="text-sm text-neutral-500">
            {flaws.length} total
          </span>
          {flaws.length > 0 && (
            <p className="text-xs text-red-400 font-medium">
              Impact: -{totalImpact.toFixed(1)} pts
            </p>
          )}
        </div>
      </div>

      {/* Cards */}
      <div className="space-y-3">
        {displayedFlaws.length > 0 ? (
          displayedFlaws.map((flaw, i) => (
            <AreaOfImprovementCard
              key={flaw.id}
              flaw={flaw}
              isExpanded={expandedId === flaw.id}
              onToggle={() => setExpandedId(expandedId === flaw.id ? null : flaw.id)}
              onRatioClick={(ratio) => onRatioClick(ratio, flaw.categoryName)}
              recommendations={recommendations}
              animationDelay={i * 0.04}
            />
          ))
        ) : (
          <div className="rounded-xl bg-neutral-800/50 border border-neutral-700 p-6 text-center">
            <p className="text-neutral-500">No significant areas for improvement detected</p>
          </div>
        )}
      </div>

      {/* Show More Button */}
      {remainingCount > 0 && (
        <button
          onClick={() => setShowAll(!showAll)}
          className="w-full mt-4 py-3 rounded-lg bg-neutral-800/50 border border-neutral-700 hover:border-neutral-600 hover:bg-neutral-800 transition-all duration-200 text-sm font-medium text-white"
        >
          <span className="flex items-center justify-center gap-2">
            <span>{showAll ? 'Show Less' : `Show ${remainingCount} More`}</span>
            <motion.div animate={{ rotate: showAll ? 180 : 0 }} transition={{ duration: 0.2 }}>
              <ChevronDown className="w-4 h-4 text-neutral-400" />
            </motion.div>
          </span>
        </button>
      )}
    </div>
  );
}
