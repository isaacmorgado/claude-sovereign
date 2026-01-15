'use client';

import React, { createContext, useContext, useState, ReactNode } from 'react';

export interface UploadedImage {
  file: File;
  preview: string;
}

interface UploadContextType {
  frontPhoto: UploadedImage | null;
  sidePhoto: UploadedImage | null;
  setFrontPhoto: (image: UploadedImage | null) => void;
  setSidePhoto: (image: UploadedImage | null) => void;
  clearAll: () => void;
}

const UploadContext = createContext<UploadContextType | undefined>(undefined);

export function UploadProvider({ children }: { children: ReactNode }) {
  const [frontPhoto, setFrontPhoto] = useState<UploadedImage | null>(null);
  const [sidePhoto, setSidePhoto] = useState<UploadedImage | null>(null);

  const clearAll = () => {
    if (frontPhoto?.preview) URL.revokeObjectURL(frontPhoto.preview);
    if (sidePhoto?.preview) URL.revokeObjectURL(sidePhoto.preview);
    setFrontPhoto(null);
    setSidePhoto(null);
  };

  return (
    <UploadContext.Provider value={{ frontPhoto, sidePhoto, setFrontPhoto, setSidePhoto, clearAll }}>
      {children}
    </UploadContext.Provider>
  );
}

export function useUpload() {
  const context = useContext(UploadContext);
  if (context === undefined) {
    throw new Error('useUpload must be used within an UploadProvider');
  }
  return context;
}
