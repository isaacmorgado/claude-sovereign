'use client';

import { useState, useEffect, useCallback, useMemo } from 'react';

// ============================================
// TYPES
// ============================================

export interface AnalysisSnapshot {
  id: string;
  createdAt: string;

  // Scores
  overallScore: number;
  frontScore: number;
  sideScore: number;
  pslRating: number;
  pslTier: string;

  // Photos (base64 or URLs)
  frontPhotoUrl?: string;
  sidePhotoUrl?: string;

  // Demographics
  gender: 'male' | 'female';
  ethnicity: string;

  // Key metrics for comparison
  keyMetrics: {
    name: string;
    value: number;
    score: number;
  }[];

  // Top strengths and flaws
  topStrengths: string[];
  topFlaws: string[];

  // Body composition (if available)
  bodyFatPercent?: number;

  // Archetype
  archetype?: string;

  // Notes (user-added)
  notes?: string;

  // Version tag
  version: number;
}

export interface AnalysisComparison {
  current: AnalysisSnapshot;
  previous: AnalysisSnapshot;
  changes: {
    overallScore: number;
    pslRating: number;
    metricChanges: {
      name: string;
      before: number;
      after: number;
      change: number;
      improved: boolean;
    }[];
    newStrengths: string[];
    resolvedFlaws: string[];
    daysBetween: number;
  };
}

export interface UseAnalysisHistoryReturn {
  // Data
  history: AnalysisSnapshot[];
  latestAnalysis: AnalysisSnapshot | null;
  previousAnalysis: AnalysisSnapshot | null;

  // Actions
  saveAnalysis: (analysis: Omit<AnalysisSnapshot, 'id' | 'createdAt' | 'version'>) => void;
  deleteAnalysis: (id: string) => void;
  clearHistory: () => void;
  updateNotes: (id: string, notes: string) => void;

  // Comparison
  compareAnalyses: (currentId: string, previousId: string) => AnalysisComparison | null;
  getProgressSummary: () => {
    totalAnalyses: number;
    firstAnalysisDate: string | null;
    bestPslRating: number;
    averageImprovement: number;
    streakDays: number;
  };

  // State
  isLoading: boolean;
}

// ============================================
// STORAGE
// ============================================

const HISTORY_STORAGE_KEY = 'looksmaxx_analysis_history';
const MAX_HISTORY_ENTRIES = 50;

function generateId(): string {
  return `analysis_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

function loadHistory(): AnalysisSnapshot[] {
  if (typeof window === 'undefined') return [];

  try {
    const stored = localStorage.getItem(HISTORY_STORAGE_KEY);
    if (stored) {
      return JSON.parse(stored) as AnalysisSnapshot[];
    }
  } catch {
    console.error('[AnalysisHistory] Failed to load history');
  }

  return [];
}

function saveHistory(history: AnalysisSnapshot[]): void {
  if (typeof window === 'undefined') return;

  try {
    // Limit to MAX_HISTORY_ENTRIES (keep most recent)
    const limited = history.slice(0, MAX_HISTORY_ENTRIES);
    localStorage.setItem(HISTORY_STORAGE_KEY, JSON.stringify(limited));
  } catch (e) {
    console.error('[AnalysisHistory] Failed to save history:', e);
  }
}

// ============================================
// HOOK
// ============================================

export function useAnalysisHistory(): UseAnalysisHistoryReturn {
  const [history, setHistory] = useState<AnalysisSnapshot[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Load history on mount
  useEffect(() => {
    const loaded = loadHistory();
    setHistory(loaded);
    setIsLoading(false);
  }, []);

  // Derived values
  const latestAnalysis = useMemo(() => {
    return history.length > 0 ? history[0] : null;
  }, [history]);

  const previousAnalysis = useMemo(() => {
    return history.length > 1 ? history[1] : null;
  }, [history]);

  // Save new analysis
  const saveAnalysis = useCallback((analysis: Omit<AnalysisSnapshot, 'id' | 'createdAt' | 'version'>) => {
    const newEntry: AnalysisSnapshot = {
      ...analysis,
      id: generateId(),
      createdAt: new Date().toISOString(),
      version: (history[0]?.version || 0) + 1,
    };

    setHistory(prev => {
      const updated = [newEntry, ...prev];
      saveHistory(updated);
      return updated;
    });
  }, [history]);

  // Delete analysis
  const deleteAnalysis = useCallback((id: string) => {
    setHistory(prev => {
      const updated = prev.filter(a => a.id !== id);
      saveHistory(updated);
      return updated;
    });
  }, []);

  // Clear all history
  const clearHistory = useCallback(() => {
    setHistory([]);
    saveHistory([]);
  }, []);

  // Update notes
  const updateNotes = useCallback((id: string, notes: string) => {
    setHistory(prev => {
      const updated = prev.map(a =>
        a.id === id ? { ...a, notes } : a
      );
      saveHistory(updated);
      return updated;
    });
  }, []);

  // Compare two analyses
  const compareAnalyses = useCallback((currentId: string, previousId: string): AnalysisComparison | null => {
    const current = history.find(a => a.id === currentId);
    const previous = history.find(a => a.id === previousId);

    if (!current || !previous) return null;

    // Calculate metric changes
    const metricChanges = current.keyMetrics.map(metric => {
      const prevMetric = previous.keyMetrics.find(m => m.name === metric.name);
      const before = prevMetric?.score || 0;
      const after = metric.score;
      const change = after - before;

      return {
        name: metric.name,
        before,
        after,
        change,
        improved: change > 0,
      };
    });

    // Find new strengths
    const newStrengths = current.topStrengths.filter(
      s => !previous.topStrengths.includes(s)
    );

    // Find resolved flaws
    const resolvedFlaws = previous.topFlaws.filter(
      f => !current.topFlaws.includes(f)
    );

    // Calculate days between
    const daysBetween = Math.round(
      (new Date(current.createdAt).getTime() - new Date(previous.createdAt).getTime()) /
      (1000 * 60 * 60 * 24)
    );

    return {
      current,
      previous,
      changes: {
        overallScore: current.overallScore - previous.overallScore,
        pslRating: current.pslRating - previous.pslRating,
        metricChanges,
        newStrengths,
        resolvedFlaws,
        daysBetween,
      },
    };
  }, [history]);

  // Get progress summary
  const getProgressSummary = useCallback(() => {
    if (history.length === 0) {
      return {
        totalAnalyses: 0,
        firstAnalysisDate: null,
        bestPslRating: 0,
        averageImprovement: 0,
        streakDays: 0,
      };
    }

    const sortedByDate = [...history].sort(
      (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
    );

    const firstAnalysisDate = sortedByDate[0].createdAt;
    const bestPslRating = Math.max(...history.map(a => a.pslRating));

    // Calculate average improvement
    let totalImprovement = 0;
    let improvementCount = 0;

    for (let i = 1; i < sortedByDate.length; i++) {
      const diff = sortedByDate[i].pslRating - sortedByDate[i - 1].pslRating;
      if (diff > 0) {
        totalImprovement += diff;
        improvementCount++;
      }
    }

    const averageImprovement = improvementCount > 0
      ? totalImprovement / improvementCount
      : 0;

    // Calculate streak
    let streakDays = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    for (const analysis of history) {
      const analysisDate = new Date(analysis.createdAt);
      analysisDate.setHours(0, 0, 0, 0);

      const diffDays = Math.round(
        (today.getTime() - analysisDate.getTime()) / (1000 * 60 * 60 * 24)
      );

      if (diffDays === streakDays) {
        streakDays++;
      } else {
        break;
      }
    }

    return {
      totalAnalyses: history.length,
      firstAnalysisDate,
      bestPslRating,
      averageImprovement,
      streakDays,
    };
  }, [history]);

  return {
    history,
    latestAnalysis,
    previousAnalysis,
    saveAnalysis,
    deleteAnalysis,
    clearHistory,
    updateNotes,
    compareAnalyses,
    getProgressSummary,
    isLoading,
  };
}

export default useAnalysisHistory;
