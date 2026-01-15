'use client';

import { motion } from 'framer-motion';
import { ArrowRight, Sparkles, User, Info } from 'lucide-react';
import {
  ArchetypeClassification,
  ArchetypeCategory,
  SubArchetypeStyle,
} from '@/lib/archetype-classifier';
import {
  ArchetypeTraits,
  CategoryIcon,
  ConfidenceBar,
  DimorphismBadge,
  ARCHETYPE_COLORS,
} from './ArchetypeTraits';

// ============================================
// TYPES
// ============================================

interface ArchetypeCardProps {
  classification: ArchetypeClassification;
  showSecondary?: boolean;
  showTransition?: boolean;
  showStyleGuide?: boolean;
  compact?: boolean;
}

interface StyleGuideProps {
  style: SubArchetypeStyle;
  archetypeName: string;
}

// ============================================
// STYLE GUIDE COMPONENT
// ============================================

function StyleGuide({ style, archetypeName }: StyleGuideProps) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.2 }}
      className="rounded-2xl bg-neutral-900/40 border border-white/5 p-6"
    >
      <h4 className="text-sm font-black text-white mb-4 flex items-center gap-3">
        <div className="w-8 h-8 rounded-lg bg-cyan-500/15 border border-cyan-500/20 flex items-center justify-center">
          <Sparkles className="w-4 h-4 text-cyan-400" />
        </div>
        {archetypeName} Style Guide
      </h4>

      <div className="space-y-4">
        {/* Clothing */}
        {style.clothing.length > 0 && (
          <div>
            <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600 mb-2">Clothing</p>
            <div className="flex flex-wrap gap-2">
              {style.clothing.map((item) => (
                <span
                  key={item}
                  className="px-3 py-1.5 rounded-lg bg-neutral-900 border border-white/10 text-neutral-300 text-xs font-medium"
                >
                  {item}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Hair */}
        {style.hair.length > 0 && (
          <div>
            <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600 mb-2">Hair</p>
            <div className="flex flex-wrap gap-2">
              {style.hair.map((item) => (
                <span
                  key={item}
                  className="px-3 py-1.5 rounded-lg bg-neutral-900 border border-white/10 text-neutral-300 text-xs font-medium"
                >
                  {item}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Colors */}
        {style.colors.length > 0 && (
          <div>
            <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600 mb-2">Colors</p>
            <div className="flex flex-wrap gap-2">
              {style.colors.map((color) => (
                <span
                  key={color}
                  className="px-3 py-1.5 rounded-lg bg-neutral-900 border border-white/10 text-neutral-300 text-xs font-medium"
                >
                  {color}
                </span>
              ))}
            </div>
          </div>
        )}
      </div>
    </motion.div>
  );
}

// ============================================
// TRANSITION PATH COMPONENT
// ============================================

function TransitionPath({
  from,
  transitionPath,
}: {
  from: string;
  transitionPath: { target: string; requirements: string[] };
}) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.3 }}
      className="rounded-2xl border border-dashed border-white/10 bg-neutral-900/30 p-6"
    >
      <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600 mb-4">Transition Potential</p>

      <div className="flex items-center gap-4 mb-5">
        <span className="text-white font-black">{from}</span>
        <div className="w-8 h-8 rounded-lg bg-cyan-500/15 border border-cyan-500/20 flex items-center justify-center">
          <ArrowRight className="text-cyan-400" size={14} />
        </div>
        <span className="text-cyan-400 font-black">{transitionPath.target}</span>
      </div>

      <div>
        <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600 mb-3">Requirements:</p>
        <ul className="space-y-2">
          {transitionPath.requirements.map((req, i) => (
            <li key={i} className="text-sm text-neutral-400 flex items-start gap-3">
              <span className="text-cyan-500 mt-1">•</span>
              {req}
            </li>
          ))}
        </ul>
      </div>
    </motion.div>
  );
}

// ============================================
// SECONDARY ARCHETYPE
// ============================================

function SecondaryArchetype({
  category,
  subArchetype,
  confidence,
  traits,
}: {
  category: ArchetypeCategory;
  subArchetype: string;
  confidence: number;
  traits: string[];
}) {
  const colors = ARCHETYPE_COLORS[category];

  return (
    <motion.div
      initial={{ opacity: 0, x: -10 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: 0.15 }}
      className="rounded-2xl bg-neutral-900/50 border border-white/5 p-5"
    >
      <div className="flex items-center justify-between mb-4">
        <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600">Secondary Match</p>
        <span
          className="text-[10px] font-black uppercase tracking-wider px-3 py-1 rounded-lg"
          style={{
            backgroundColor: colors.bg,
            color: colors.primary,
            border: `1px solid ${colors.border}`,
          }}
        >
          {Math.round(confidence * 100)}%
        </span>
      </div>

      <div className="flex items-center gap-4">
        <CategoryIcon category={category} />
        <div>
          <p className="text-xl text-white font-black">{subArchetype}</p>
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">{category}</p>
        </div>
      </div>

      {traits.length > 0 && (
        <div className="mt-4">
          <ArchetypeTraits traits={traits} compact />
        </div>
      )}
    </motion.div>
  );
}

// ============================================
// MAIN ARCHETYPE CARD
// ============================================

export function ArchetypeCard({
  classification,
  showSecondary = true,
  showTransition = true,
  showStyleGuide = false,
  compact = false,
}: ArchetypeCardProps) {
  const { primary, secondary, dimorphismLevel, styleGuide, transitionPath } = classification;
  const colors = ARCHETYPE_COLORS[primary.category];

  // Compact version for overview tab
  if (compact) {
    return (
      <div className="rounded-2xl bg-neutral-900/40 border border-white/5 p-5 hover:border-white/10 transition-colors">
        <div className="flex items-center justify-between mb-3">
          <span className="text-[10px] font-black uppercase tracking-wider text-neutral-600">Archetype</span>
          <span
            className="text-[10px] font-black uppercase tracking-wider px-3 py-1 rounded-lg"
            style={{
              backgroundColor: colors.bg,
              color: colors.primary,
            }}
          >
            {Math.round(primary.confidence * 100)}%
          </span>
        </div>
        <div className="flex items-center gap-4">
          <CategoryIcon category={primary.category} />
          <div>
            <p className="text-xl font-black text-white">{primary.subArchetype}</p>
            <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">{primary.category}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-8"
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <h2 className="text-xl font-black text-white">Your Archetype</h2>
        <DimorphismBadge level={dimorphismLevel} size="sm" />
      </div>

      {/* Primary Archetype */}
      <div className="flex items-start gap-5 mb-8">
        <motion.div
          initial={{ scale: 0.8 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', stiffness: 200 }}
          className="w-16 h-16 rounded-2xl flex items-center justify-center border"
          style={{
            background: `linear-gradient(135deg, ${colors.primary}20 0%, ${colors.primary}05 100%)`,
            borderColor: `${colors.primary}30`,
          }}
        >
          <User className="w-8 h-8" style={{ color: colors.primary }} />
        </motion.div>

        <div className="flex-1">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-[10px] font-black uppercase tracking-wider text-neutral-600">Primary Match</span>
          </div>
          <h3
            className="text-3xl font-black mb-1"
            style={{ color: colors.primary }}
          >
            {primary.subArchetype}
          </h3>
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">{primary.category} Category</p>
        </div>

        <div className="text-right">
          <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600 mb-2">Confidence</p>
          <p
            className="text-3xl font-black"
            style={{ color: colors.primary }}
          >
            {Math.round(primary.confidence * 100)}%
          </p>
        </div>
      </div>

      {/* Confidence Bar */}
      <div className="mb-8">
        <ConfidenceBar
          confidence={primary.confidence}
          label="MATCH STRENGTH"
          color={colors.primary}
        />
      </div>

      {/* Traits */}
      <div className="mb-8">
        <p className="text-[10px] font-black uppercase tracking-wider text-neutral-600 mb-4">Defining Traits</p>
        <ArchetypeTraits traits={primary.traits} />
      </div>

      {/* Secondary Archetype */}
      {showSecondary && secondary && (
        <div className="mb-8">
          <SecondaryArchetype
            category={secondary.category}
            subArchetype={secondary.subArchetype}
            confidence={secondary.confidence}
            traits={secondary.traits}
          />
        </div>
      )}

      {/* Style Guide */}
      {showStyleGuide && (
        <div className="mb-8">
          <StyleGuide style={styleGuide} archetypeName={primary.subArchetype} />
        </div>
      )}

      {/* Transition Path */}
      {showTransition && transitionPath && (
        <TransitionPath from={primary.subArchetype} transitionPath={transitionPath} />
      )}

      {/* Info footer */}
      <div className="mt-6 flex items-start gap-3 text-xs text-neutral-500 p-4 rounded-xl bg-neutral-900/30 border border-white/5">
        <Info size={14} className="flex-shrink-0 mt-0.5 text-neutral-600" />
        <p>
          Archetype classification is based on your facial metrics including gonial angle,
          face width-height ratio, and canthal tilt. Your secondary archetype represents
          traits you also exhibit.
        </p>
      </div>
    </motion.div>
  );
}

/**
 * Preview card for overview tab
 */
export function ArchetypePreview({
  classification,
}: {
  classification: ArchetypeClassification;
}) {
  return <ArchetypeCard classification={classification} compact />;
}

export default ArchetypeCard;
