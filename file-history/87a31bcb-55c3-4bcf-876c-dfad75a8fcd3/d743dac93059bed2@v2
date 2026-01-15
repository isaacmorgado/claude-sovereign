'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { DailyStack } from '@/types/results';
import { Sparkles, ChevronDown, ChevronUp, Sun, Moon, Clock } from 'lucide-react';
import { getSupplementDetails } from '@/lib/daily-stack';

interface DailyStackCardProps {
  dailyStack: DailyStack;
}

export function DailyStackCard({ dailyStack }: DailyStackCardProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  // Safe access to cost values
  const minCost = dailyStack?.totalCostPerMonth?.min ?? 0;
  const maxCost = dailyStack?.totalCostPerMonth?.max ?? 0;

  if (!dailyStack) return null;

  return (
    <motion.div
      className="bg-gradient-to-br from-cyan-600 to-blue-700 rounded-2xl p-6 shadow-xl"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      {/* Header */}
      <div className="flex items-center gap-3 mb-4">
        <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center">
          <Sparkles size={24} className="text-white" />
        </div>
        <div className="flex-1">
          <h2 className="text-xl font-bold text-white">Your Foundation Stack</h2>
          <p className="text-cyan-100 text-sm">
            ${minCost}-${maxCost}/month
          </p>
        </div>
      </div>

      {/* Rationale */}
      <p className="text-white/90 text-sm mb-4 leading-relaxed">
        {dailyStack.rationale}
      </p>

      {/* Product Pills */}
      <div className="flex flex-wrap gap-2 mb-4">
        {(dailyStack.products || []).slice(0, 6).map(product => (
          <div
            key={product.id}
            className="px-3 py-1.5 bg-white/20 rounded-full text-white text-sm font-medium"
          >
            {product.name}
          </div>
        ))}
      </div>

      {/* Expand/Collapse Button */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full bg-white/20 hover:bg-white/30 text-white font-medium py-2.5 px-4 rounded-lg transition-colors flex items-center justify-center gap-2"
      >
        {isExpanded ? 'Hide Details' : 'View Complete Stack'}
        {isExpanded ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
      </button>

      {/* Expanded Details */}
      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="mt-4 space-y-4 overflow-hidden"
          >
            {/* Morning */}
            {(dailyStack.timing?.morning?.length ?? 0) > 0 && (
              <div className="bg-white/10 rounded-xl p-4">
                <div className="flex items-center gap-2 text-white font-medium mb-3">
                  <Sun size={18} />
                  <span>Morning</span>
                </div>
                <div className="space-y-2">
                  {dailyStack.timing.morning.map(product => {
                    const supplement = getSupplementDetails(product.supplementId);
                    return (
                      <div key={product.id} className="flex items-center justify-between text-sm">
                        <span className="text-white">{product.name}</span>
                        <span className="text-cyan-100">{supplement?.dosage}</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Evening */}
            {(dailyStack.timing?.evening?.length ?? 0) > 0 && (
              <div className="bg-white/10 rounded-xl p-4">
                <div className="flex items-center gap-2 text-white font-medium mb-3">
                  <Moon size={18} />
                  <span>Evening</span>
                </div>
                <div className="space-y-2">
                  {dailyStack.timing.evening.map(product => {
                    const supplement = getSupplementDetails(product.supplementId);
                    return (
                      <div key={product.id} className="flex items-center justify-between text-sm">
                        <span className="text-white">{product.name}</span>
                        <span className="text-cyan-100">{supplement?.dosage}</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Anytime */}
            {(dailyStack.timing?.anytime?.length ?? 0) > 0 && (
              <div className="bg-white/10 rounded-xl p-4">
                <div className="flex items-center gap-2 text-white font-medium mb-3">
                  <Clock size={18} />
                  <span>Anytime</span>
                </div>
                <div className="space-y-2">
                  {dailyStack.timing.anytime.map(product => {
                    const supplement = getSupplementDetails(product.supplementId);
                    return (
                      <div key={product.id} className="flex items-center justify-between text-sm">
                        <span className="text-white">{product.name}</span>
                        <span className="text-cyan-100">{supplement?.dosage}</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
