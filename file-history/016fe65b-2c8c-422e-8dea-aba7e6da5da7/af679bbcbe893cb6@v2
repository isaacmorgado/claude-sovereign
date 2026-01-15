'use client';

import { motion } from 'framer-motion';
import { ProductRecommendation } from '@/types/results';
import { ExternalLink, TrendingUp, Shield, DollarSign, Clock } from 'lucide-react';
import { getSupplementDetails } from '@/lib/daily-stack';

interface ProductCardProps {
  recommendation: ProductRecommendation;
  rank?: number;
  compact?: boolean;
}

export function ProductCard({ recommendation, rank, compact = false }: ProductCardProps) {
  const { product, state, message } = recommendation;
  const supplement = getSupplementDetails(product.supplementId);

  // State-based styling
  const isCorrectiveState = state === 'flaw';
  const stateBadgeColor = isCorrectiveState
    ? 'bg-red-500/20 text-red-400 border-red-500/30'
    : 'bg-green-500/20 text-green-400 border-green-500/30';
  const stateBadgeText = isCorrectiveState ? 'Corrective' : 'Maintenance';
  const StateIcon = isCorrectiveState ? TrendingUp : Shield;

  // CTA text
  const ctaText = product.affiliateType === 'amazon' ? 'View on Amazon' : 'Shop Direct';

  // Compact mode for embedded use in WeakPointCard
  if (compact) {
    return (
      <motion.a
        href={product.affiliateLink}
        target="_blank"
        rel="noopener noreferrer"
        className="flex items-center gap-3 p-3 bg-neutral-800/50 rounded-lg hover:bg-neutral-800 transition-colors group"
        whileHover={{ scale: 1.02 }}
      >
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <h4 className="text-sm font-medium text-white truncate">{product.name}</h4>
            <div className={`px-1.5 py-0.5 rounded text-xs font-medium ${stateBadgeColor}`}>
              {isCorrectiveState ? 'Fix' : 'Protect'}
            </div>
          </div>
          <p className="text-xs text-neutral-400 truncate">{product.brand}</p>
        </div>
        {supplement && (
          <div className="text-right flex-shrink-0">
            <p className="text-sm font-medium text-white">
              ${supplement.costPerMonth.min}/mo
            </p>
          </div>
        )}
        <ExternalLink size={14} className="text-neutral-500 group-hover:text-cyan-400 transition-colors flex-shrink-0" />
      </motion.a>
    );
  }

  return (
    <motion.div
      className="bg-gradient-to-br from-neutral-900 to-neutral-950 border border-neutral-800 rounded-xl p-5 hover:border-neutral-700 transition-all"
      whileHover={{ y: -2 }}
    >
      {/* Header */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            {rank && (
              <div className="w-6 h-6 rounded-full bg-cyan-500/20 flex items-center justify-center flex-shrink-0">
                <span className="text-xs font-bold text-cyan-400">{rank}</span>
              </div>
            )}
            <h3 className="font-semibold text-white">{product.name}</h3>
          </div>
          <p className="text-sm text-neutral-400">{product.brand}</p>
        </div>

        <div className={`px-2 py-1 rounded-lg border text-xs font-medium flex items-center gap-1 ${stateBadgeColor}`}>
          <StateIcon size={12} />
          {stateBadgeText}
        </div>
      </div>

      {/* Message */}
      <div className="mb-4">
        <p className="text-sm text-neutral-300">{message}</p>
        <p className="text-xs text-neutral-500 mt-1">
          Targets: {recommendation.matchedMetrics.slice(0, 3).join(', ')}
          {recommendation.matchedMetrics.length > 3 && ` +${recommendation.matchedMetrics.length - 3} more`}
        </p>
      </div>

      {/* Quick Stats */}
      {supplement && (
        <div className="grid grid-cols-3 gap-3 mb-4">
          <div className="bg-neutral-800/50 rounded-lg p-2">
            <div className="flex items-center gap-1 text-neutral-400 mb-1">
              <DollarSign size={12} />
              <span className="text-xs">Cost</span>
            </div>
            <p className="text-sm font-medium text-white">
              ${supplement.costPerMonth.min}-${supplement.costPerMonth.max}/mo
            </p>
          </div>

          <div className="bg-neutral-800/50 rounded-lg p-2">
            <div className="flex items-center gap-1 text-neutral-400 mb-1">
              <Clock size={12} />
              <span className="text-xs">Timeline</span>
            </div>
            <p className="text-sm font-medium text-white">{supplement.timelineToResults}</p>
          </div>

          <div className="bg-neutral-800/50 rounded-lg p-2">
            <div className="text-neutral-400 mb-1 text-xs">Dosage</div>
            <p className="text-sm font-medium text-white">{supplement.dosage}</p>
          </div>
        </div>
      )}

      {/* CTA Button */}
      <a
        href={product.affiliateLink}
        target="_blank"
        rel="noopener noreferrer"
        className="block w-full bg-cyan-500 hover:bg-cyan-400 text-black font-medium py-2.5 px-4 rounded-lg transition-colors text-center"
      >
        <span className="flex items-center justify-center gap-2">
          {ctaText}
          <ExternalLink size={16} />
        </span>
      </a>

      {/* Affiliate Disclosure */}
      <p className="text-xs text-neutral-600 text-center mt-2">
        We may earn a commission from purchases made through this link.
      </p>
    </motion.div>
  );
}
