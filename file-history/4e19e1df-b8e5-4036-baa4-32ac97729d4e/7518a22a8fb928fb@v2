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
} from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { useAuth } from '@/contexts/AuthContext';
import { TabContent } from '../ResultsLayout';
import { EnhancedRecommendationCard } from '../cards/EnhancedRecommendationCard';
import { ScoreCircle, PhaseBadge } from '../shared';
import { RecommendationPhase } from '@/types/results';

// ============================================
// POTENTIAL SCORE CARD
// ============================================

function PotentialScoreCard() {
  const { overallScore, recommendations } = useResults();

  // Calculate potential improvement
  const potentialImprovement = useMemo(() => {
    if (recommendations.length === 0) return 0;
    const totalImpact = recommendations.slice(0, 5).reduce((sum, r) => sum + r.impact, 0);
    return Math.min(totalImpact * 1.5, 10 - overallScore);
  }, [recommendations, overallScore]);

  const potentialScore = Math.min(10, overallScore + potentialImprovement);

  return (
    <motion.div
      className="bg-gradient-to-br from-neutral-900 to-neutral-950 border border-neutral-800 rounded-2xl p-6"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="flex items-center gap-2 mb-4">
        <Sparkles size={20} className="text-cyan-400" />
        <h3 className="font-semibold text-white">Your Potential</h3>
      </div>

      <div className="flex items-center justify-center gap-8 mb-6">
        {/* Current */}
        <div className="text-center">
          <p className="text-xs text-neutral-500 mb-2">Current</p>
          <ScoreCircle score={overallScore} size="lg" animate={false} />
        </div>

        {/* Arrow */}
        <div className="flex flex-col items-center gap-1">
          <ChevronRight size={24} className="text-cyan-400" />
          <span className="text-xs text-green-400">+{potentialImprovement.toFixed(1)}</span>
        </div>

        {/* Potential */}
        <div className="text-center">
          <p className="text-xs text-neutral-500 mb-2">Potential</p>
          <div className="relative">
            <ScoreCircle score={potentialScore} size="lg" animate={false} />
            <div className="absolute -top-1 -right-1 w-5 h-5 bg-green-500 rounded-full flex items-center justify-center">
              <TrendingUp size={12} className="text-black" />
            </div>
          </div>
        </div>
      </div>

      <p className="text-sm text-neutral-400 text-center">
        Following our recommendations could improve your harmony score by up to{' '}
        <span className="text-green-400 font-medium">+{potentialImprovement.toFixed(1)} points</span>
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
        className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all ${
          selectedPhase === null
            ? 'bg-cyan-500 text-black'
            : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
        }`}
      >
        All ({Object.values(counts).reduce((a, b) => a + b, 0)})
      </button>
      {phases.map(phase => (
        <button
          key={phase}
          onClick={() => onSelect(phase)}
          className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all flex items-center gap-2 ${
            selectedPhase === phase
              ? 'bg-neutral-700 text-white'
              : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
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
// ORDER OF OPERATIONS
// ============================================

function OrderOfOperations() {
  return (
    <div className="bg-neutral-900/50 border border-neutral-800 rounded-xl p-4">
      <h4 className="font-medium text-white mb-3 flex items-center gap-2">
        <Target size={16} className="text-cyan-400" />
        Recommended Order
      </h4>
      <div className="space-y-3">
        <div className="flex items-start gap-3">
          <div className="w-6 h-6 rounded-full bg-green-500/20 flex items-center justify-center flex-shrink-0 mt-0.5">
            <span className="text-xs font-bold text-green-400">1</span>
          </div>
          <div>
            <p className="text-sm font-medium text-white">Start with Foundational</p>
            <p className="text-xs text-neutral-500">Low-cost, no-risk improvements that anyone can do</p>
          </div>
        </div>
        <div className="flex items-start gap-3">
          <div className="w-6 h-6 rounded-full bg-yellow-500/20 flex items-center justify-center flex-shrink-0 mt-0.5">
            <span className="text-xs font-bold text-yellow-400">2</span>
          </div>
          <div>
            <p className="text-sm font-medium text-white">Consider Minimally Invasive</p>
            <p className="text-xs text-neutral-500">Temporary or reversible options with moderate impact</p>
          </div>
        </div>
        <div className="flex items-start gap-3">
          <div className="w-6 h-6 rounded-full bg-red-500/20 flex items-center justify-center flex-shrink-0 mt-0.5">
            <span className="text-xs font-bold text-red-400">3</span>
          </div>
          <div>
            <p className="text-sm font-medium text-white">Evaluate Surgical Options</p>
            <p className="text-xs text-neutral-500">Permanent solutions for significant improvements</p>
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================
// PLAN TAB
// ============================================

export function PlanTab() {
  const { recommendations, flaws, gender, ethnicity } = useResults();
  const { user } = useAuth();
  const [selectedPhase, setSelectedPhase] = useState<RecommendationPhase | null>(null);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [completedIds, setCompletedIds] = useState<Set<string>>(new Set());
  const [removedIds, setRemovedIds] = useState<Set<string>>(new Set());

  // Check if user has a paid plan
  const hasPaidPlan = user?.plan === 'basic' || user?.plan === 'pro';

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
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Potential Score */}
          <PotentialScoreCard />

          {/* Phase Filter */}
          <PhaseFilter
            selectedPhase={selectedPhase}
            onSelect={setSelectedPhase}
            counts={phaseCounts}
          />

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
            <div className="bg-neutral-900/50 border border-neutral-800 rounded-xl p-8 text-center">
              <Sparkles size={48} className="mx-auto text-neutral-700 mb-4" />
              <h3 className="text-lg font-medium text-white mb-2">No Recommendations Yet</h3>
              <p className="text-neutral-500 mb-4">
                Complete a facial analysis to get personalized recommendations
              </p>
            </div>
          )}
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Order of Operations */}
          <OrderOfOperations />

          {/* My Plan Summary */}
          <div className="bg-neutral-900/50 border border-neutral-800 rounded-xl p-4">
            <h4 className="font-medium text-white mb-3 flex items-center gap-2">
              <Zap size={16} className="text-yellow-400" />
              My Plan
            </h4>
            <div className="text-center py-6">
              <div className="w-12 h-12 mx-auto mb-3 rounded-xl bg-neutral-800 flex items-center justify-center">
                <Lock size={20} className="text-neutral-600" />
              </div>
              <p className="text-sm text-neutral-500 mb-3">
                Add recommendations to build your personalized plan
              </p>
              <p className="text-xs text-neutral-600">
                0 items selected
              </p>
            </div>
          </div>

          {/* Issues Summary */}
          <div className="bg-neutral-900/50 border border-neutral-800 rounded-xl p-4">
            <h4 className="font-medium text-white mb-3">Detected Issues</h4>
            <div className="space-y-2">
              {flaws.slice(0, 5).map(flaw => (
                <div
                  key={flaw.id}
                  className="flex items-center justify-between p-2 bg-neutral-800/50 rounded-lg"
                >
                  <span className="text-sm text-neutral-300 truncate">{flaw.flawName}</span>
                  <span className="text-xs text-red-400 flex-shrink-0">
                    -{flaw.harmonyPercentageLost.toFixed(1)}%
                  </span>
                </div>
              ))}
              {flaws.length === 0 && (
                <p className="text-sm text-neutral-500 text-center py-4">
                  No issues detected
                </p>
              )}
            </div>
          </div>

          {/* Upgrade CTA or Premium Badge */}
          {hasPaidPlan ? (
            <motion.div
              className="bg-gradient-to-br from-green-500/10 to-emerald-600/10 border border-green-500/30 rounded-xl p-4"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
            >
              <div className="flex items-center gap-2 mb-2">
                <CheckCircle size={16} className="text-green-400" />
                <span className="text-sm font-medium text-white">
                  {user?.plan === 'pro' ? 'Pro Plan' : 'Basic Plan'} Active
                </span>
              </div>
              <p className="text-xs text-neutral-400">
                You have full access to all {user?.plan === 'pro' ? 'features' : 'non-surgical recommendations'}.
              </p>
            </motion.div>
          ) : (
            <motion.div
              className="bg-gradient-to-br from-cyan-500/10 to-blue-600/10 border border-cyan-500/30 rounded-xl p-4"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
            >
              <div className="flex items-center gap-2 mb-2">
                <Sparkles size={16} className="text-cyan-400" />
                <span className="text-sm font-medium text-white">Unlock Full Plan</span>
              </div>
              <p className="text-xs text-neutral-400 mb-3">
                Get detailed treatment guides, cost estimates, and provider recommendations.
              </p>
              <a
                href="/pricing"
                className="block w-full py-2 bg-cyan-500 text-black text-sm font-medium rounded-lg text-center hover:bg-cyan-400 transition-colors"
              >
                Upgrade Now
              </a>
            </motion.div>
          )}
        </div>
      </div>
    </TabContent>
  );
}
