'use client';

import React, { createContext, useContext, useState, ReactNode } from 'react';

export type EthnicityOption =
  | 'white'
  | 'black'
  | 'asian'
  | 'south-asian'
  | 'hispanic'
  | 'middle-eastern'
  | 'pacific-islander'
  | 'native-american'
  | 'mixed';

export const ethnicityLabels: Record<EthnicityOption, string> = {
  'white': 'White / Caucasian',
  'black': 'Black / African descent',
  'asian': 'Asian / East Asian',
  'south-asian': 'Indian / South Asian',
  'hispanic': 'Hispanic / Latino',
  'middle-eastern': 'Middle Eastern / North African',
  'pacific-islander': 'Pacific Islander',
  'native-american': 'Native American',
  'mixed': 'Other',
};

interface EthnicityContextType {
  ethnicities: EthnicityOption[];
  toggleEthnicity: (ethnicity: EthnicityOption) => void;
  clearEthnicities: () => void;
}

const EthnicityContext = createContext<EthnicityContextType | undefined>(undefined);

export function EthnicityProvider({ children }: { children: ReactNode }) {
  const [ethnicities, setEthnicities] = useState<EthnicityOption[]>([]);

  const toggleEthnicity = (ethnicity: EthnicityOption) => {
    setEthnicities(prev =>
      prev.includes(ethnicity)
        ? prev.filter(e => e !== ethnicity)
        : [...prev, ethnicity]
    );
  };

  const clearEthnicities = () => {
    setEthnicities([]);
  };

  return (
    <EthnicityContext.Provider value={{ ethnicities, toggleEthnicity, clearEthnicities }}>
      {children}
    </EthnicityContext.Provider>
  );
}

export function useEthnicity() {
  const context = useContext(EthnicityContext);
  if (context === undefined) {
    throw new Error('useEthnicity must be used within an EthnicityProvider');
  }
  return context;
}
