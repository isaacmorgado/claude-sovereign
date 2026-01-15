'use client';

import { ReactNode } from 'react';
import { AuthProvider } from '@/contexts/AuthContext';
import { GenderProvider } from '@/contexts/GenderContext';
import { EthnicityProvider } from '@/contexts/EthnicityContext';
import { UploadProvider } from '@/contexts/UploadContext';
import { LeaderboardProvider } from '@/contexts/LeaderboardContext';
import { ForumProvider } from '@/contexts/ForumContext';

export function Providers({ children }: { children: ReactNode }) {
  return (
    <AuthProvider>
      <GenderProvider>
        <EthnicityProvider>
          <UploadProvider>
            <LeaderboardProvider>
              <ForumProvider>
                {children}
              </ForumProvider>
            </LeaderboardProvider>
          </UploadProvider>
        </EthnicityProvider>
      </GenderProvider>
    </AuthProvider>
  );
}
