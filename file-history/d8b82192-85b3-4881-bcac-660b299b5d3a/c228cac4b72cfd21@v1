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
      className="bg-neutral-800/50 rounded-lg p-4 border border-neutral-700"
    >
      <h4 className="text-sm font-medium text-white mb-3 flex items-center gap-2">
        <Sparkles className="w-4 h-4 text-cyan-400" />
        {archetypeName} Style Guide
      </h4>

      <div className="space-y-3">
        {/* Clothing */}
        {style.clothing.length > 0 && (
          <div>
            <p className="text-xs text-neutral-500 mb-1">Clothing</p>
            <div className="flex flex-wrap gap-1.5">
              {style.clothing.map((item) => (
                <span
                  key={item}
                  className="px-2 py-0.5 rounded bg-neutral-700 text-neutral-300 text-xs"
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
            <p className="text-xs text-neutral-500 mb-1">Hair</p>
            <div className="flex flex-wrap gap-1.5">
              {style.hair.map((item) => (
                <span
                  key={item}
                  className="px-2 py-0.5 rounded bg-neutral-700 text-neutral-300 text-xs"
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
            <p className="text-xs text-neutral-500 mb-1">Colors</p>
            <div className="flex flex-wrap gap-1.5">
              {style.colors.map((color) => (
                <span
                  key={color}
                  className="px-2 py-0.5 rounded bg-neutral-700 text-neutral-300 text-xs"
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
      className="p-4 rounded-lg border border-dashed border-neutral-700 bg-neutral-800/30"
    >
      <p className="text-sm text-neutral-400 mb-3">Transition Potential</p>

      <div className="flex items-center gap-3 mb-3">
        <span className="text-white font-medium">{from}</span>
        <ArrowRight className="text-neutral-600" size={16} />
        <span className="text-cyan-400 font-medium">{transitionPath.target}</span>
      </div>

      <div>
        <p className="text-xs text-neutral-500 mb-2">Requirements:</p>
        <ul className="space-y-1">
          {transitionPath.requirements.map((req, i) => (
            <li key={i} className="text-xs text-neutral-400 flex items-start gap-2">
              <span className="text-cyan-500 mt-0.5">-</span>
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
      className="p-4 rounded-lg bg-neutral-800/50 border border-neutral-700"
    >
      <div className="flex items-center justify-between mb-2">
        <p className="text-sm text-neutral-400">Secondary Match</p>
        <span
          className="text-xs px-2 py-0.5 rounded-full"
          style={{
            backgroundColor: colors.bg,
            color: colors.primary,
            border: `1px solid ${colors.border}`,
          }}
        >
          {Math.round(confidence * 100)}% match
        </span>
      </div>

      <div className="flex items-center gap-3">
        <CategoryIcon category={category} />
        <div>
          <p className="text-lg text-white font-medium">{subArchetype}</p>
          <p className="text-xs text-neutral-500">{category}</p>
        </div>
      </div>

      {traits.length > 0 && (
        <div className="mt-3">
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
      <div className="bg-neutral-900/50 rounded-lg p-4 border border-neutral-800 hover:border-neutral-700 transition-colors">
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm text-neutral-400">Archetype</span>
          <span
            className="text-xs px-2 py-0.5 rounded-full"
            style={{
              backgroundColor: colors.bg,
              color: colors.primary,
            }}
          >
            {Math.round(primary.confidence * 100)}%
          </span>
        </div>
        <div className="flex items-center gap-3">
          <CategoryIcon category={primary.category} />
          <div>
            <p className="text-xl font-bold text-white">{primary.subArchetype}</p>
            <p className="text-xs text-neutral-500">{primary.category}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-semibold text-white">Your Archetype</h2>
        <DimorphismBadge level={dimorphismLevel} size="sm" />
      </div>

      {/* Primary Archetype */}
      <div className="flex items-start gap-4 mb-6">
        <motion.div
          initial={{ scale: 0.8 }}
          animate={{ scale: 1 }}
          transition={{ type: 'spring', stiffness: 200 }}
          className="w-16 h-16 rounded-xl flex items-center justify-center"
          style={{
            background: `linear-gradient(135deg, ${colors.primary}30 0%, ${colors.primary}10 100%)`,
            border: `2px solid ${colors.primary}40`,
          }}
        >
          <User className="w-8 h-8" style={{ color: colors.primary }} />
        </motion.div>

        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-sm text-neutral-400">Primary Match</span>
          </div>
          <h3
            className="text-2xl font-bold mb-1"
            style={{ color: colors.primary }}
          >
            {primary.subArchetype}
          </h3>
          <p className="text-sm text-neutral-500">{primary.category} Category</p>
        </div>

        <div className="text-right">
          <p className="text-sm text-neutral-400 mb-1">Confidence</p>
          <p
            className="text-2xl font-bold"
            style={{ color: colors.primary }}
          >
            {Math.round(primary.confidence * 100)}%
          </p>
        </div>
      </div>

      {/* Confidence Bar */}
      <div className="mb-6">
        <ConfidenceBar
          confidence={primary.confidence}
          label="Match Strength"
          color={colors.primary}
        />
      </div>

      {/* Traits */}
      <div className="mb-6">
        <p className="text-sm text-neutral-400 mb-3">Defining Traits</p>
        <ArchetypeTraits traits={primary.traits} />
      </div>

      {/* Secondary Archetype */}
      {showSecondary && secondary && (
        <div className="mb-6">
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
        <div className="mb-6">
          <StyleGuide style={styleGuide} archetypeName={primary.subArchetype} />
        </div>
      )}

      {/* Transition Path */}
      {showTransition && transitionPath && (
        <TransitionPath from={primary.subArchetype} transitionPath={transitionPath} />
      )}

      {/* Info footer */}
      <div className="mt-4 flex items-start gap-2 text-xs text-neutral-500">
        <Info size={14} className="flex-shrink-0 mt-0.5" />
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
