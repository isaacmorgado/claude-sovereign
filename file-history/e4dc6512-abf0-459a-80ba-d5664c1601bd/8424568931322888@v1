'use client';

import { useResults } from '@/contexts/ResultsContext';
import { ResultsLayout } from './ResultsLayout';
import { OverviewTab } from './tabs/OverviewTab';
import { FrontRatiosTab, SideRatiosTab } from './tabs/RatiosTab';
import { PlanTab } from './tabs/PlanTab';
import { OptionsTab } from './tabs/OptionsTab';
import { SupportTab } from './tabs/SupportTab';

export function Results() {
  const { activeTab } = useResults();

  const renderTabContent = () => {
    switch (activeTab) {
      case 'overview':
        return <OverviewTab />;
      case 'front-ratios':
        return <FrontRatiosTab />;
      case 'side-ratios':
        return <SideRatiosTab />;
      case 'plan':
        return <PlanTab />;
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
