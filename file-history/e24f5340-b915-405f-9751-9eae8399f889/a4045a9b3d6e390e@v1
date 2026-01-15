'use client';

import { ReactNode } from 'react';
import { GenderProvider } from '@/contexts/GenderContext';
import { EthnicityProvider } from '@/contexts/EthnicityContext';
import { UploadProvider } from '@/contexts/UploadContext';
import { LeaderboardProvider } from '@/contexts/LeaderboardContext';

export function Providers({ children }: { children: ReactNode }) {
  return (
    <GenderProvider>
      <EthnicityProvider>
        <UploadProvider>
          <LeaderboardProvider>
            {children}
          </LeaderboardProvider>
        </UploadProvider>
      </EthnicityProvider>
    </GenderProvider>
  );
}
