'use client';

import { motion } from 'framer-motion';
import {
  Camera,
  Download,
  MessageSquare,
  UserCog,
  AlertTriangle,
  CheckCircle,
  Infinity,
  TrendingUp,
  Sparkles,
} from 'lucide-react';
import { QuotaInfo } from '@/hooks/useQuota';

// ============================================
// QUOTA PROGRESS BAR
// ============================================

interface QuotaProgressBarProps {
  quota: QuotaInfo;
  showLabel?: boolean;
  compact?: boolean;
}

export function QuotaProgressBar({
  quota,
  showLabel = true,
  compact = false,
}: QuotaProgressBarProps) {
  const { percentage, status, formatted, isUnlimited } = quota;

  const statusColors = {
    good: 'bg-cyan-500',
    warning: 'bg-yellow-500',
    critical: 'bg-red-500',
  };

  const statusBgColors = {
    good: 'bg-cyan-500/20',
    warning: 'bg-yellow-500/20',
    critical: 'bg-red-500/20',
  };

  if (isUnlimited) {
    return (
      <div className={`flex items-center gap-2 ${compact ? 'text-xs' : 'text-sm'}`}>
        <Infinity size={compact ? 14 : 16} className="text-green-400" />
        <span className="text-green-400">Unlimited</span>
      </div>
    );
  }

  return (
    <div className="space-y-1">
      {showLabel && (
        <div className="flex items-center justify-between text-xs">
          <span className="text-neutral-400">{formatted}</span>
          <span
            className={`${
              status === 'critical'
                ? 'text-red-400'
                : status === 'warning'
                ? 'text-yellow-400'
                : 'text-neutral-500'
            }`}
          >
            {Math.round(percentage)}%
          </span>
        </div>
      )}
      <div
        className={`${compact ? 'h-1' : 'h-2'} ${
          statusBgColors[status]
        } rounded-full overflow-hidden`}
      >
        <motion.div
          className={`h-full ${statusColors[status]} rounded-full`}
          initial={{ width: 0 }}
          animate={{ width: `${percentage}%` }}
          transition={{ duration: 0.5, ease: 'easeOut' }}
        />
      </div>
    </div>
  );
}

// ============================================
// QUOTA CARD
// ============================================

interface QuotaCardProps {
  quota: QuotaInfo;
  title: string;
  description?: string;
  icon?: 'camera' | 'download' | 'message' | 'user';
}

const iconMap = {
  camera: Camera,
  download: Download,
  message: MessageSquare,
  user: UserCog,
};

export function QuotaCard({ quota, title, description, icon = 'camera' }: QuotaCardProps) {
  const Icon = iconMap[icon];
  const { status, isUnlimited, remaining } = quota;

  const statusStyles = {
    good: 'border-neutral-800 bg-neutral-900/50',
    warning: 'border-yellow-500/30 bg-yellow-500/5',
    critical: 'border-red-500/30 bg-red-500/5',
  };

  return (
    <div className={`rounded-xl border p-4 ${statusStyles[status]}`}>
      <div className="flex items-start gap-3">
        <div
          className={`p-2 rounded-lg ${
            status === 'critical'
              ? 'bg-red-500/20'
              : status === 'warning'
              ? 'bg-yellow-500/20'
              : 'bg-neutral-800'
          }`}
        >
          <Icon
            size={20}
            className={
              status === 'critical'
                ? 'text-red-400'
                : status === 'warning'
                ? 'text-yellow-400'
                : 'text-cyan-400'
            }
          />
        </div>

        <div className="flex-1">
          <div className="flex items-center justify-between mb-1">
            <h4 className="font-medium text-white">{title}</h4>
            {status === 'critical' && <AlertTriangle size={16} className="text-red-400" />}
            {status === 'good' && isUnlimited && (
              <CheckCircle size={16} className="text-green-400" />
            )}
          </div>

          {description && (
            <p className="text-xs text-neutral-500 mb-2">{description}</p>
          )}

          <QuotaProgressBar quota={quota} />

          {status === 'critical' && !isUnlimited && (
            <p className="text-xs text-red-400 mt-2">
              {remaining === 0
                ? 'Quota exhausted. Upgrade for more.'
                : `Only ${remaining} remaining`}
            </p>
          )}
        </div>
      </div>
    </div>
  );
}

// ============================================
// QUOTA SUMMARY (Dashboard Widget)
// ============================================

interface QuotaSummaryProps {
  analyses: QuotaInfo;
  downloads: QuotaInfo;
  forumPosts: QuotaInfo;
  plan: string;
  onUpgrade?: () => void;
}

export function QuotaSummary({
  analyses,
  downloads,
  forumPosts,
  plan,
  onUpgrade,
}: QuotaSummaryProps) {
  const hasIssues =
    analyses.status === 'critical' ||
    downloads.status === 'critical' ||
    forumPosts.status === 'critical';

  const isPremium = plan === 'pro' || plan === 'plus';

  return (
    <div className="bg-black/60 backdrop-blur-xl border border-white/10 rounded-2xl p-5">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <TrendingUp size={18} className="text-cyan-400" />
          <h3 className="font-semibold text-white">Monthly Usage</h3>
        </div>
        <span
          className={`text-xs px-2 py-1 rounded-full ${
            isPremium
              ? 'bg-green-500/20 text-green-400 border border-green-500/30'
              : 'bg-neutral-800 text-neutral-400'
          }`}
        >
          {plan.charAt(0).toUpperCase() + plan.slice(1)} Plan
        </span>
      </div>

      <div className="space-y-4">
        {/* Analyses */}
        <div className="flex items-center gap-3">
          <Camera size={16} className="text-neutral-500" />
          <div className="flex-1">
            <div className="flex items-center justify-between text-xs mb-1">
              <span className="text-neutral-400">Analyses</span>
              <span className="text-white">{analyses.formatted}</span>
            </div>
            <QuotaProgressBar quota={analyses} showLabel={false} compact />
          </div>
        </div>

        {/* Downloads */}
        <div className="flex items-center gap-3">
          <Download size={16} className="text-neutral-500" />
          <div className="flex-1">
            <div className="flex items-center justify-between text-xs mb-1">
              <span className="text-neutral-400">Downloads</span>
              <span className="text-white">{downloads.formatted}</span>
            </div>
            <QuotaProgressBar quota={downloads} showLabel={false} compact />
          </div>
        </div>

        {/* Forum Posts */}
        <div className="flex items-center gap-3">
          <MessageSquare size={16} className="text-neutral-500" />
          <div className="flex-1">
            <div className="flex items-center justify-between text-xs mb-1">
              <span className="text-neutral-400">Forum Posts</span>
              <span className="text-white">{forumPosts.formatted}</span>
            </div>
            <QuotaProgressBar quota={forumPosts} showLabel={false} compact />
          </div>
        </div>
      </div>

      {/* Upgrade CTA */}
      {(hasIssues || plan === 'free') && onUpgrade && (
        <button
          onClick={onUpgrade}
          className="w-full mt-4 py-2 px-4 rounded-lg bg-gradient-to-r from-cyan-500 to-blue-500 hover:from-cyan-400 hover:to-blue-400 text-white text-sm font-medium transition-all flex items-center justify-center gap-2"
        >
          <Sparkles size={16} />
          {hasIssues ? 'Upgrade for More' : 'Upgrade Plan'}
        </button>
      )}
    </div>
  );
}

// ============================================
// QUOTA WARNING BANNER
// ============================================

interface QuotaWarningBannerProps {
  quota: QuotaInfo;
  resourceName: string;
  onUpgrade?: () => void;
}

export function QuotaWarningBanner({
  quota,
  resourceName,
  onUpgrade,
}: QuotaWarningBannerProps) {
  if (quota.status === 'good' || quota.isUnlimited) return null;

  const isCritical = quota.status === 'critical';

  return (
    <motion.div
      className={`rounded-xl border p-4 ${
        isCritical
          ? 'bg-red-500/10 border-red-500/30'
          : 'bg-yellow-500/10 border-yellow-500/30'
      }`}
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="flex items-start gap-3">
        <AlertTriangle
          size={20}
          className={isCritical ? 'text-red-400' : 'text-yellow-400'}
        />
        <div className="flex-1">
          <p
            className={`text-sm font-medium ${
              isCritical ? 'text-red-400' : 'text-yellow-400'
            }`}
          >
            {isCritical
              ? `You've reached your ${resourceName} limit`
              : `Running low on ${resourceName}`}
          </p>
          <p className="text-xs text-neutral-400 mt-1">
            {quota.remaining === 0
              ? 'Upgrade your plan to continue using this feature.'
              : `Only ${quota.remaining} remaining this month.`}
          </p>
        </div>
        {onUpgrade && (
          <button
            onClick={onUpgrade}
            className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-all ${
              isCritical
                ? 'bg-red-500 hover:bg-red-400 text-white'
                : 'bg-yellow-500 hover:bg-yellow-400 text-black'
            }`}
          >
            Upgrade
          </button>
        )}
      </div>
    </motion.div>
  );
}

// ============================================
// QUOTA GATE (Blocks content if quota exceeded)
// ============================================

interface QuotaGateProps {
  quota: QuotaInfo;
  children: React.ReactNode;
  resourceName: string;
  onUpgrade?: () => void;
}

export function QuotaGate({
  quota,
  children,
  resourceName,
  onUpgrade,
}: QuotaGateProps) {
  if (quota.remaining > 0 || quota.isUnlimited) {
    return <>{children}</>;
  }

  return (
    <div className="relative">
      {/* Blurred content */}
      <div className="blur-sm pointer-events-none select-none">{children}</div>

      {/* Overlay */}
      <div className="absolute inset-0 flex items-center justify-center bg-black/60 backdrop-blur-sm rounded-xl">
        <div className="text-center p-6 max-w-sm">
          <div className="w-12 h-12 mx-auto mb-4 rounded-full bg-red-500/20 flex items-center justify-center">
            <AlertTriangle size={24} className="text-red-400" />
          </div>
          <h3 className="text-lg font-semibold text-white mb-2">
            {resourceName} Limit Reached
          </h3>
          <p className="text-sm text-neutral-400 mb-4">
            You&apos;ve used all your monthly {resourceName.toLowerCase()}. Upgrade your
            plan for unlimited access.
          </p>
          {onUpgrade && (
            <button
              onClick={onUpgrade}
              className="px-6 py-2 rounded-lg bg-gradient-to-r from-cyan-500 to-blue-500 hover:from-cyan-400 hover:to-blue-400 text-white font-medium transition-all flex items-center gap-2 mx-auto"
            >
              <Sparkles size={16} />
              Upgrade Now
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
