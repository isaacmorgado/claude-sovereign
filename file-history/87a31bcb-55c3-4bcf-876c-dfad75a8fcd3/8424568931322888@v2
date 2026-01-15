'use client';

import { useEffect, useRef } from 'react';
import { useResults } from '@/contexts/ResultsContext';
import { useLeaderboardOptional } from '@/contexts/LeaderboardContext';
import { ResultsLayout } from './ResultsLayout';
import { OverviewTab } from './tabs/OverviewTab';
import { FrontRatiosTab, SideRatiosTab } from './tabs/RatiosTab';
import { PlanTab } from './tabs/PlanTab';
import { GuidesTab } from './tabs/GuidesTab';
import { ShopTab } from './tabs/ShopTab';
import { OptionsTab } from './tabs/OptionsTab';
import { SupportTab } from './tabs/SupportTab';
import { LeaderboardTab } from './tabs/LeaderboardTab';
import { CommunityTab } from './tabs/CommunityTab';
import { ReferralsTab } from './tabs/ReferralsTab';
import { PSLTab } from './tabs/PSLTab';
import { ArchetypeTab } from './tabs/ArchetypeTab';
import { api } from '@/lib/api';

export function Results() {
  const { activeTab, overallScore, gender, ethnicity, frontPhoto, strengths, flaws } = useResults();
  const leaderboard = useLeaderboardOptional();
  const hasSubmittedRef = useRef(false);

  // Auto-submit score to leaderboard on first render when score is available
  useEffect(() => {
    // Only submit once, when we have a valid score and haven't submitted yet
    const numericScore = typeof overallScore === 'number' ? overallScore : 0;
    if (hasSubmittedRef.current || numericScore <= 0 || !leaderboard) return;

    // Check if user is authenticated
    const token = api.getToken();
    if (!token) return;

    // Mark as submitted to prevent duplicate submissions
    hasSubmittedRef.current = true;

    // Extract top 3 strengths and improvements
    const topStrengths = strengths.slice(0, 3).map(s => s.strengthName);
    const topImprovements = flaws.slice(0, 3).map(f => f.flawName);

    // Submit to leaderboard
    leaderboard.submitScore(numericScore, gender, {
      ethnicity,
      facePhotoUrl: frontPhoto,
      topStrengths,
      topImprovements,
    }).catch(err => {
      // Reset flag on error so user can retry
      hasSubmittedRef.current = false;
      console.error('[Leaderboard] Auto-submit failed:', err);
    });
  }, [overallScore, gender, ethnicity, frontPhoto, strengths, flaws, leaderboard]);

  const renderTabContent = () => {
    switch (activeTab) {
      case 'overview':
        return <OverviewTab />;
      case 'front-ratios':
        return <FrontRatiosTab />;
      case 'side-ratios':
        return <SideRatiosTab />;
      case 'leaderboard':
        return <LeaderboardTab />;
      case 'psl':
        return <PSLTab />;
      case 'archetype':
        return <ArchetypeTab />;
      case 'plan':
        return <PlanTab />;
      case 'guides':
        return <GuidesTab />;
      case 'shop':
        return <ShopTab />;
      case 'community':
        return <CommunityTab />;
      case 'referrals':
        return <ReferralsTab />;
      case 'options':
        return <OptionsTab />;
      case 'support':
        return <SupportTab />;
      default:
        return <OverviewTab />;
    }
  };

  return (
    <ResultsLayout>
      {renderTabContent()}
    </ResultsLayout>
  );
}
