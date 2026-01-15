'use client';

import { useMemo, useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import Link from 'next/link';
import { Info, Target, Palette, TrendingUp, Users, ArrowRight } from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { TabContent } from '../ResultsLayout';
import { ArchetypeCard } from '@/components/psl/archetype/ArchetypeCard';
import {
  ARCHETYPE_COLORS,
  ConfidenceBar,
} from '@/components/psl/archetype/ArchetypeTraits';
import {
  classifyFromRatios,
  ArchetypeClassification,
  ArchetypeCategory,
} from '@/lib/archetype-classifier';
import { api, ArchetypeForumRecommendation } from '@/lib/api';

// ============================================
// ALL SCORES BREAKDOWN
// ============================================

function AllArchetypeScores({
  classification,
}: {
  classification: ArchetypeClassification;
}) {
  const sortedScores = [...classification.allScores].sort((a, b) => b.score - a.score);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.2 }}
      className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
    >
      <div className="flex items-center gap-2 mb-4">
        <Target className="w-5 h-5 text-cyan-400" />
        <h3 className="font-semibold text-white">All Category Scores</h3>
      </div>

      <p className="text-sm text-neutral-400 mb-4">
        Your match percentage across all archetype categories
      </p>

      <div className="space-y-4">
        {sortedScores.map((score, index) => {
          const colors = ARCHETYPE_COLORS[score.category as ArchetypeCategory];
          const isPrimary = index === 0;

          return (
            <div key={score.category} className="space-y-2">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  {isPrimary && (
                    <span className="text-xs px-2 py-0.5 rounded bg-cyan-500/20 text-cyan-400 border border-cyan-500/30">
                      Primary
                    </span>
                  )}
                  <span className={`font-medium ${isPrimary ? 'text-white' : 'text-neutral-400'}`}>
                    {score.category}
                  </span>
                </div>
                <span
                  className="text-sm font-medium"
                  style={{ color: colors?.primary || '#6b7280' }}
                >
                  {score.score}%
                </span>
              </div>
              <ConfidenceBar
                confidence={score.confidence}
                color={colors?.primary}
              />
            </div>
          );
        })}
      </div>
    </motion.div>
  );
}

// ============================================
// STYLE RECOMMENDATIONS
// ============================================

function StyleRecommendations({
  classification,
}: {
  classification: ArchetypeClassification;
}) {
  const { styleGuide, primary } = classification;
  const colors = ARCHETYPE_COLORS[primary.category];

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.3 }}
      className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
    >
      <div className="flex items-center gap-2 mb-4">
        <Palette className="w-5 h-5 text-purple-400" />
        <h3 className="font-semibold text-white">{primary.subArchetype} Style Guide</h3>
      </div>

      <p className="text-sm text-neutral-400 mb-6">
        Recommended style elements based on your archetype classification
      </p>

      <div className="grid md:grid-cols-3 gap-6">
        {/* Clothing */}
        <div>
          <h4
            className="text-sm font-medium mb-3 flex items-center gap-2"
            style={{ color: colors.primary }}
          >
            <span className="w-2 h-2 rounded-full" style={{ backgroundColor: colors.primary }} />
            Clothing
          </h4>
          <ul className="space-y-2">
            {styleGuide.clothing.map((item) => (
              <li key={item} className="text-sm text-neutral-300 flex items-start gap-2">
                <span className="text-neutral-600 mt-1">-</span>
                {item}
              </li>
            ))}
          </ul>
        </div>

        {/* Hair */}
        <div>
          <h4
            className="text-sm font-medium mb-3 flex items-center gap-2"
            style={{ color: colors.primary }}
          >
            <span className="w-2 h-2 rounded-full" style={{ backgroundColor: colors.primary }} />
            Hair
          </h4>
          <ul className="space-y-2">
            {styleGuide.hair.map((item) => (
              <li key={item} className="text-sm text-neutral-300 flex items-start gap-2">
                <span className="text-neutral-600 mt-1">-</span>
                {item}
              </li>
            ))}
          </ul>
        </div>

        {/* Colors */}
        <div>
          <h4
            className="text-sm font-medium mb-3 flex items-center gap-2"
            style={{ color: colors.primary }}
          >
            <span className="w-2 h-2 rounded-full" style={{ backgroundColor: colors.primary }} />
            Color Palette
          </h4>
          <div className="flex flex-wrap gap-2">
            {styleGuide.colors.map((color) => (
              <span
                key={color}
                className="px-3 py-1 rounded-full bg-neutral-800 text-neutral-300 text-sm border border-neutral-700"
              >
                {color}
              </span>
            ))}
          </div>
        </div>
      </div>
    </motion.div>
  );
}

// ============================================
// TRANSITION OPPORTUNITIES
// ============================================

function TransitionOpportunities({
  classification,
}: {
  classification: ArchetypeClassification;
}) {
  const { transitionPath, primary, allScores } = classification;

  if (!transitionPath) return null;

  // Find the target score
  const targetScore = allScores.find((s) => s.category === transitionPath.target);
  const primaryColors = ARCHETYPE_COLORS[primary.category];
  const targetColors = ARCHETYPE_COLORS[transitionPath.target as ArchetypeCategory];

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.4 }}
      className="bg-gradient-to-r from-cyan-500/10 to-purple-500/10 rounded-xl p-6 border border-cyan-500/20"
    >
      <div className="flex items-center gap-2 mb-4">
        <TrendingUp className="w-5 h-5 text-green-400" />
        <h3 className="font-semibold text-white">Archetype Transition Potential</h3>
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        {/* Current */}
        <div className="bg-neutral-900/50 rounded-lg p-4">
          <p className="text-xs text-neutral-500 mb-2">Current Archetype</p>
          <p
            className="text-xl font-bold mb-1"
            style={{ color: primaryColors.primary }}
          >
            {primary.subArchetype}
          </p>
          <p className="text-sm text-neutral-400">{primary.category}</p>
          <div className="mt-3">
            <ConfidenceBar
              confidence={primary.confidence}
              label="Match"
              color={primaryColors.primary}
            />
          </div>
        </div>

        {/* Target */}
        <div className="bg-neutral-900/50 rounded-lg p-4">
          <p className="text-xs text-neutral-500 mb-2">Transition Target</p>
          <p
            className="text-xl font-bold mb-1"
            style={{ color: targetColors?.primary || '#67e8f9' }}
          >
            {transitionPath.target}
          </p>
          <p className="text-sm text-neutral-400">
            {targetScore ? `${targetScore.score}% current match` : 'New category'}
          </p>
          {targetScore && (
            <div className="mt-3">
              <ConfidenceBar
                confidence={targetScore.confidence}
                label="Current Match"
                color={targetColors?.primary}
              />
            </div>
          )}
        </div>
      </div>

      {/* Requirements */}
      <div className="mt-6">
        <p className="text-sm text-neutral-400 mb-3">To achieve this transition:</p>
        <ul className="grid md:grid-cols-2 gap-2">
          {transitionPath.requirements.map((req, i) => (
            <li
              key={i}
              className="flex items-center gap-2 p-3 bg-neutral-900/50 rounded-lg text-sm text-neutral-300"
            >
              <span className="w-5 h-5 rounded-full bg-cyan-500/20 text-cyan-400 flex items-center justify-center text-xs">
                {i + 1}
              </span>
              {req}
            </li>
          ))}
        </ul>
      </div>
    </motion.div>
  );
}

// ============================================
// RECOMMENDED FORUMS SECTION
// ============================================

function RecommendedForumsSection({
  classification,
}: {
  classification: ArchetypeClassification;
}) {
  const [forums, setForums] = useState<ArchetypeForumRecommendation[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const archetype = classification.primary.category;
  const colors = ARCHETYPE_COLORS[archetype];

  useEffect(() => {
    async function fetchForums() {
      setIsLoading(true);
      try {
        const recommendations = await api.getArchetypeForumRecommendations(archetype);
        setForums(recommendations.slice(0, 3)); // Show top 3
      } catch (error) {
        console.error('[ArchetypeTab] Failed to fetch forum recommendations:', error);
      } finally {
        setIsLoading(false);
      }
    }

    fetchForums();
  }, [archetype]);

  if (isLoading) {
    return (
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.35 }}
        className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
      >
        <div className="flex items-center gap-2 mb-4">
          <Users className="w-5 h-5 text-amber-400" />
          <h3 className="font-semibold text-white">Recommended Forums</h3>
        </div>
        <div className="grid gap-3 md:grid-cols-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="animate-pulse bg-neutral-800 rounded-lg h-24" />
          ))}
        </div>
      </motion.div>
    );
  }

  if (forums.length === 0) return null;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ delay: 0.35 }}
      className="bg-neutral-900 rounded-xl p-6 border border-neutral-800"
    >
      <div className="flex items-center gap-2 mb-4">
        <Users className="w-5 h-5 text-amber-400" />
        <h3 className="font-semibold text-white">Recommended Forums</h3>
        <span
          className="px-2 py-0.5 text-xs font-medium rounded border"
          style={{
            backgroundColor: `${colors.primary}20`,
            color: colors.primary,
            borderColor: `${colors.primary}40`,
          }}
        >
          {archetype}
        </span>
      </div>

      <p className="text-sm text-neutral-400 mb-4">
        Forums tailored to your archetype to help you maximize your aesthetic potential
      </p>

      <div className="grid gap-3 md:grid-cols-3">
        {forums.map((forum) => (
          <Link key={forum.category.id} href={`/forum/${forum.category.slug}`}>
            <div className="group bg-neutral-800/50 hover:bg-neutral-800 rounded-lg p-4 border border-neutral-700 hover:border-amber-500/30 transition-all cursor-pointer">
              <div className="flex items-center gap-3 mb-2">
                <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-amber-500/20 to-orange-500/20 flex items-center justify-center text-xl flex-shrink-0">
                  {forum.category.icon || '💬'}
                </div>
                <h4 className="font-medium text-white group-hover:text-amber-400 transition-colors text-sm line-clamp-1">
                  {forum.category.name}
                </h4>
              </div>
              <p className="text-xs text-neutral-400 line-clamp-2 mb-2">
                {forum.reason || forum.category.description}
              </p>
              <div className="flex items-center justify-end">
                <span className="text-xs text-amber-400 opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-1">
                  Visit
                  <ArrowRight className="w-3 h-3" />
                </span>
              </div>
            </div>
          </Link>
        ))}
      </div>

      <Link href="/forum" className="block mt-4">
        <div className="flex items-center justify-center gap-2 py-2 text-sm text-neutral-400 hover:text-white transition-colors">
          <span>Explore all forums</span>
          <ArrowRight className="w-4 h-4" />
        </div>
      </Link>
    </motion.div>
  );
}

// ============================================
// MAIN ARCHETYPE TAB
// ============================================

export function ArchetypeTab() {
  const { frontRatios, sideRatios, gender, ethnicity } = useResults();

  // Classify archetype from ratios
  const classification = useMemo((): ArchetypeClassification | null => {
    if (!frontRatios || frontRatios.length === 0) return null;

    try {
      return classifyFromRatios(frontRatios, sideRatios || [], gender, ethnicity);
    } catch (error) {
      console.error('[ArchetypeTab] Classification error:', error);
      return null;
    }
  }, [frontRatios, sideRatios, gender, ethnicity]);

  if (!classification) {
    return (
      <TabContent
        title="Archetype Classification"
        subtitle="Determining your facial archetype based on your metrics"
      >
        <div className="bg-neutral-900 rounded-xl p-8 border border-neutral-800 text-center">
          <p className="text-neutral-400">
            Unable to classify archetype. Please ensure your analysis is complete.
          </p>
        </div>
      </TabContent>
    );
  }

  return (
    <TabContent
      title="Archetype Classification"
      subtitle="Your facial aesthetic archetype based on bone structure and proportions"
    >
      <div className="space-y-6">
        {/* Main Archetype Card */}
        <ArchetypeCard
          classification={classification}
          showSecondary
          showTransition={false}
        />

        {/* All Scores Breakdown */}
        <AllArchetypeScores classification={classification} />

        {/* Style Recommendations */}
        <StyleRecommendations classification={classification} />

        {/* Recommended Forums */}
        <RecommendedForumsSection classification={classification} />

        {/* Transition Opportunities */}
        <TransitionOpportunities classification={classification} />

        {/* Info footer */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="p-4 bg-neutral-900/50 rounded-lg border border-neutral-800"
        >
          <div className="flex items-start gap-2">
            <Info className="w-4 h-4 text-neutral-500 flex-shrink-0 mt-0.5" />
            <p className="text-xs text-neutral-500">
              Archetype classification analyzes your facial structure including gonial angle,
              face width-height ratio, canthal tilt, and cheekbone position. Your primary archetype
              represents your dominant aesthetic, while your secondary shows traits you also exhibit.
              Style recommendations are tailored to complement your natural features.
            </p>
          </div>
        </motion.div>
      </div>
    </TabContent>
  );
}
