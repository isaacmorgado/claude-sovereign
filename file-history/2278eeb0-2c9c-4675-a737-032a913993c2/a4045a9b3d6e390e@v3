'use client';

import { ReactNode } from 'react';
import { GenderProvider } from '@/contexts/GenderContext';
import { EthnicityProvider } from '@/contexts/EthnicityContext';
import { UploadProvider } from '@/contexts/UploadContext';

export function Providers({ children }: { children: ReactNode }) {
  return (
    <GenderProvider>
      <EthnicityProvider>
        <UploadProvider>
          {children}
        </UploadProvider>
      </EthnicityProvider>
    </GenderProvider>
  );
}
