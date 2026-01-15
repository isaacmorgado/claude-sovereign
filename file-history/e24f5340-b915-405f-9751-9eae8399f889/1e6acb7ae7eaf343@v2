'use client';

import React, { createContext, useContext, useState, useCallback, useEffect, ReactNode } from 'react';
import { api } from '@/lib/api';
import type { UserRank, LeaderboardEntry, UserProfile } from '@/types/results';

interface LeaderboardContextType {
  // State
  userRank: UserRank | null;
  leaderboard: LeaderboardEntry[];
  totalCount: number;
  isLoading: boolean;
  error: string | null;

  // Filter state
  genderFilter: 'all' | 'male' | 'female';
  setGenderFilter: (filter: 'all' | 'male' | 'female') => void;

  // Selected user for profile modal
  selectedUserId: string | null;
  selectedProfile: UserProfile | null;
  setSelectedUserId: (userId: string | null) => void;

  // Actions
  fetchMyRank: () => Promise<void>;
  fetchLeaderboard: (offset?: number) => Promise<void>;
  fetchAroundMe: () => Promise<void>;
  submitScore: (score: number, gender: 'male' | 'female', options?: {
    analysisId?: string;
    ethnicity?: string;
    facePhotoUrl?: string;
    topStrengths?: string[];
    topImprovements?: string[];
  }) => Promise<void>;

  // Pagination
  currentPage: number;
  hasMore: boolean;
  loadMore: () => Promise<void>;
}

const LeaderboardContext = createContext<LeaderboardContextType | null>(null);

export function useLeaderboard(): LeaderboardContextType {
  const context = useContext(LeaderboardContext);
  if (!context) {
    throw new Error('useLeaderboard must be used within a LeaderboardProvider');
  }
  return context;
}

// Hook that returns null instead of throwing if not in provider
export function useLeaderboardOptional(): LeaderboardContextType | null {
  return useContext(LeaderboardContext);
}

const PAGE_SIZE = 50;

export function LeaderboardProvider({ children }: { children: ReactNode }) {
  const [userRank, setUserRank] = useState<UserRank | null>(null);
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [genderFilter, setGenderFilter] = useState<'all' | 'male' | 'female'>('all');
  const [currentPage, setCurrentPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [selectedProfile, setSelectedProfile] = useState<UserProfile | null>(null);

  const fetchMyRank = useCallback(async () => {
    try {
      const rank = await api.getMyRank();
      setUserRank(rank);
    } catch (err) {
      // User may not have submitted score yet - this is expected
      console.log('[Leaderboard] No rank yet:', err);
    }
  }, []);

  const fetchLeaderboard = useCallback(async (offset = 0) => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await api.getLeaderboard({
        gender: genderFilter === 'all' ? undefined : genderFilter,
        limit: PAGE_SIZE,
        offset,
      });

      if (offset === 0) {
        setLeaderboard(data.entries);
      } else {
        setLeaderboard(prev => [...prev, ...data.entries]);
      }

      setTotalCount(data.totalCount);
      setHasMore(data.entries.length === PAGE_SIZE);
      setCurrentPage(Math.floor(offset / PAGE_SIZE));

      if (data.userRank) {
        setUserRank(data.userRank);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch leaderboard');
    } finally {
      setIsLoading(false);
    }
  }, [genderFilter]);

  const fetchAroundMe = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await api.getLeaderboardAroundMe(10);
      setLeaderboard(data.entries);
      setTotalCount(data.totalCount);
      if (data.userRank) {
        setUserRank(data.userRank);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch leaderboard');
    } finally {
      setIsLoading(false);
    }
  }, []);

  const submitScore = useCallback(async (
    score: number,
    gender: 'male' | 'female',
    options?: {
      analysisId?: string;
      ethnicity?: string;
      facePhotoUrl?: string;
      topStrengths?: string[];
      topImprovements?: string[];
    }
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const rank = await api.submitScore({
        score,
        gender,
        analysis_id: options?.analysisId,
        ethnicity: options?.ethnicity,
        face_photo_url: options?.facePhotoUrl,
        top_strengths: options?.topStrengths,
        top_improvements: options?.topImprovements,
      });
      setUserRank(rank);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to submit score');
      throw err;
    } finally {
      setIsLoading(false);
    }
  }, []);

  const loadMore = useCallback(async () => {
    if (!hasMore || isLoading) return;
    await fetchLeaderboard((currentPage + 1) * PAGE_SIZE);
  }, [fetchLeaderboard, currentPage, hasMore, isLoading]);

  // Fetch user profile when selectedUserId changes
  useEffect(() => {
    if (!selectedUserId) {
      setSelectedProfile(null);
      return;
    }

    const fetchProfile = async () => {
      try {
        const profile = await api.getUserProfile(selectedUserId);
        setSelectedProfile(profile);
      } catch (err) {
        console.error('[Leaderboard] Failed to fetch profile:', err);
        setSelectedProfile(null);
      }
    };

    fetchProfile();
  }, [selectedUserId]);

  // Refetch when filter changes
  useEffect(() => {
    // Only fetch if we have a token (user is authenticated)
    const token = api.getToken();
    if (token) {
      fetchLeaderboard(0);
    }
  }, [genderFilter, fetchLeaderboard]);

  return (
    <LeaderboardContext.Provider
      value={{
        userRank,
        leaderboard,
        totalCount,
        isLoading,
        error,
        genderFilter,
        setGenderFilter,
        selectedUserId,
        selectedProfile,
        setSelectedUserId,
        fetchMyRank,
        fetchLeaderboard,
        fetchAroundMe,
        submitScore,
        currentPage,
        hasMore,
        loadMore,
      }}
    >
      {children}
    </LeaderboardContext.Provider>
  );
}
