'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import {
  PLAN_QUOTAS,
  PlanQuotas,
  getQuotaPercentage,
  formatQuotaRemaining,
  getQuotaStatus,
} from '@/lib/rate-limit';

// ============================================
// TYPES
// ============================================

export interface QuotaInfo {
  type: keyof PlanQuotas;
  used: number;
  limit: number;
  remaining: number;
  percentage: number;
  status: 'good' | 'warning' | 'critical';
  formatted: string;
  isUnlimited: boolean;
}

export interface UseQuotaReturn {
  // Individual quotas
  analyses: QuotaInfo;
  downloads: QuotaInfo;
  forumPosts: QuotaInfo;
  profileUpdates: QuotaInfo;

  // Actions
  checkQuota: (type: keyof PlanQuotas) => boolean;
  useQuota: (type: keyof PlanQuotas) => Promise<boolean>;
  refreshQuotas: () => Promise<void>;

  // State
  isLoading: boolean;
  plan: string;
  canAnalyze: boolean;
  canDownload: boolean;
  canPost: boolean;
}

// ============================================
// LOCAL STORAGE KEYS
// ============================================

const QUOTA_STORAGE_KEY = 'looksmaxx_quotas';

interface StoredQuotas {
  analyses: number;
  downloads: number;
  forumPosts: number;
  profileUpdates: number;
  month: string; // YYYY-MM
}

function getCurrentMonth(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
}

function getStoredQuotas(): StoredQuotas {
  if (typeof window === 'undefined') {
    return {
      analyses: 0,
      downloads: 0,
      forumPosts: 0,
      profileUpdates: 0,
      month: getCurrentMonth(),
    };
  }

  try {
    const stored = localStorage.getItem(QUOTA_STORAGE_KEY);
    if (stored) {
      const parsed = JSON.parse(stored) as StoredQuotas;

      // Reset if new month
      if (parsed.month !== getCurrentMonth()) {
        return {
          analyses: 0,
          downloads: 0,
          forumPosts: 0,
          profileUpdates: 0,
          month: getCurrentMonth(),
        };
      }

      return parsed;
    }
  } catch {
    // Ignore parse errors
  }

  return {
    analyses: 0,
    downloads: 0,
    forumPosts: 0,
    profileUpdates: 0,
    month: getCurrentMonth(),
  };
}

function saveQuotas(quotas: StoredQuotas): void {
  if (typeof window === 'undefined') return;

  try {
    localStorage.setItem(QUOTA_STORAGE_KEY, JSON.stringify(quotas));
  } catch {
    // Ignore storage errors
  }
}

// ============================================
// HOOK
// ============================================

export function useQuota(): UseQuotaReturn {
  const { user } = useAuth();
  const [quotas, setQuotas] = useState<StoredQuotas>(getStoredQuotas);
  const [isLoading, setIsLoading] = useState(false);

  const plan = user?.plan || 'free';
  const planLimits = PLAN_QUOTAS[plan] || PLAN_QUOTAS.free;

  // Build quota info for each type
  const buildQuotaInfo = useCallback(
    (type: keyof PlanQuotas, used: number): QuotaInfo => {
      const limit = planLimits[type];
      const isUnlimited = limit === -1;
      const remaining = isUnlimited ? -1 : Math.max(0, limit - used);
      const percentage = getQuotaPercentage(used, limit);
      const status = isUnlimited ? 'good' : getQuotaStatus(percentage);
      const formatted = formatQuotaRemaining(remaining, limit);

      return {
        type,
        used,
        limit,
        remaining,
        percentage,
        status,
        formatted,
        isUnlimited,
      };
    },
    [planLimits]
  );

  const analyses = useMemo(
    () => buildQuotaInfo('analysesPerMonth', quotas.analyses),
    [buildQuotaInfo, quotas.analyses]
  );

  const downloads = useMemo(
    () => buildQuotaInfo('resultsDownloads', quotas.downloads),
    [buildQuotaInfo, quotas.downloads]
  );

  const forumPosts = useMemo(
    () => buildQuotaInfo('forumPosts', quotas.forumPosts),
    [buildQuotaInfo, quotas.forumPosts]
  );

  const profileUpdates = useMemo(
    () => buildQuotaInfo('profileUpdates', quotas.profileUpdates),
    [buildQuotaInfo, quotas.profileUpdates]
  );

  // Check if quota is available
  const checkQuota = useCallback(
    (type: keyof PlanQuotas): boolean => {
      const limit = planLimits[type];
      if (limit === -1) return true; // Unlimited

      const used = (() => {
        switch (type) {
          case 'analysesPerMonth':
            return quotas.analyses;
          case 'resultsDownloads':
            return quotas.downloads;
          case 'forumPosts':
            return quotas.forumPosts;
          case 'profileUpdates':
            return quotas.profileUpdates;
          default:
            return 0;
        }
      })();

      return used < limit;
    },
    [planLimits, quotas]
  );

  // Use quota (increment)
  const useQuota = useCallback(
    async (type: keyof PlanQuotas): Promise<boolean> => {
      if (!checkQuota(type)) {
        return false;
      }

      setQuotas((prev) => {
        const newQuotas = { ...prev };

        switch (type) {
          case 'analysesPerMonth':
            newQuotas.analyses++;
            break;
          case 'resultsDownloads':
            newQuotas.downloads++;
            break;
          case 'forumPosts':
            newQuotas.forumPosts++;
            break;
          case 'profileUpdates':
            newQuotas.profileUpdates++;
            break;
        }

        saveQuotas(newQuotas);
        return newQuotas;
      });

      return true;
    },
    [checkQuota]
  );

  // Refresh quotas from server (if we had server-side tracking)
  const refreshQuotas = useCallback(async () => {
    setIsLoading(true);

    try {
      // In a full implementation, this would fetch from the server
      // For now, just refresh from localStorage
      const stored = getStoredQuotas();
      setQuotas(stored);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Reset quotas on month change
  useEffect(() => {
    const stored = getStoredQuotas();
    if (stored.month !== getCurrentMonth()) {
      const resetQuotas: StoredQuotas = {
        analyses: 0,
        downloads: 0,
        forumPosts: 0,
        profileUpdates: 0,
        month: getCurrentMonth(),
      };
      setQuotas(resetQuotas);
      saveQuotas(resetQuotas);
    }
  }, []);

  // Save quotas when they change
  useEffect(() => {
    saveQuotas(quotas);
  }, [quotas]);

  return {
    analyses,
    downloads,
    forumPosts,
    profileUpdates,
    checkQuota,
    useQuota,
    refreshQuotas,
    isLoading,
    plan,
    canAnalyze: checkQuota('analysesPerMonth'),
    canDownload: checkQuota('resultsDownloads'),
    canPost: checkQuota('forumPosts'),
  };
}
