'use client';

import { ReactNode } from 'react';
import { AuthProvider } from '@/contexts/AuthContext';
import { GenderProvider } from '@/contexts/GenderContext';
import { EthnicityProvider } from '@/contexts/EthnicityContext';
import { HeightProvider } from '@/contexts/HeightContext';
import { WeightProvider } from '@/contexts/WeightContext';
import { UploadProvider } from '@/contexts/UploadContext';
import { PhysiqueProvider } from '@/contexts/PhysiqueContext';
import { LeaderboardProvider } from '@/contexts/LeaderboardContext';
import { ForumProvider } from '@/contexts/ForumContext';
import { RegionProvider } from '@/contexts/RegionContext';

export function Providers({ children }: { children: ReactNode }) {
  return (
    <AuthProvider>
      <RegionProvider>
        <GenderProvider>
          <EthnicityProvider>
            <HeightProvider>
              <WeightProvider>
                <UploadProvider>
                  <PhysiqueProvider>
                    <LeaderboardProvider>
                      <ForumProvider>
                        {children}
                      </ForumProvider>
                    </LeaderboardProvider>
                  </PhysiqueProvider>
                </UploadProvider>
              </WeightProvider>
            </HeightProvider>
          </EthnicityProvider>
        </GenderProvider>
      </RegionProvider>
    </AuthProvider>
  );
}
