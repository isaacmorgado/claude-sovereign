'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Download, FileImage, FileText, Loader2, Check, X } from 'lucide-react';
import { exportToImage, exportToPDF, generateFilename } from '@/lib/exportReport';

interface ExportButtonProps {
  elementId?: string;
  variant?: 'button' | 'icon';
  className?: string;
}

// Default to the PDF report container which has the full analysis report
const DEFAULT_ELEMENT_ID = 'pdf-report-container-layout';

export function ExportButton({
  elementId = DEFAULT_ELEMENT_ID,
  variant = 'button',
  className = '',
}: ExportButtonProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [isExporting, setIsExporting] = useState<'image' | 'pdf' | null>(null);
  const [status, setStatus] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  const handleExport = async (format: 'image' | 'pdf') => {
    setIsExporting(format);
    setStatus(null);

    const filename = generateFilename('looksmaxx-results');

    try {
      const result = format === 'image'
        ? await exportToImage(elementId, { filename })
        : await exportToPDF(elementId, { filename });

      if (result.success) {
        setStatus({ type: 'success', message: `Exported as ${format.toUpperCase()}!` });
        setTimeout(() => {
          setStatus(null);
          setIsOpen(false);
        }, 1500);
      } else {
        setStatus({ type: 'error', message: result.error || 'Export failed' });
      }
    } catch {
      setStatus({ type: 'error', message: 'Export failed' });
    } finally {
      setIsExporting(null);
    }
  };

  if (variant === 'icon') {
    return (
      <button
        onClick={() => setIsOpen(true)}
        className={`p-2 rounded-lg bg-neutral-800 hover:bg-neutral-700 transition-colors ${className}`}
        title="Export results"
      >
        <Download size={18} className="text-neutral-300" />
      </button>
    );
  }

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(true)}
        className={`flex items-center gap-2 px-4 py-2 bg-neutral-800 hover:bg-neutral-700 rounded-lg transition-colors text-sm font-medium text-neutral-200 ${className}`}
      >
        <Download size={16} />
        <span>Export</span>
      </button>

      {/* Export modal */}
      <AnimatePresence>
        {isOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/50 z-40"
              onClick={() => !isExporting && setIsOpen(false)}
            />
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="absolute top-full mt-2 right-0 w-64 bg-neutral-900 border border-neutral-700 rounded-xl shadow-2xl z-50 overflow-hidden"
            >
              <div className="flex items-center justify-between p-4 border-b border-neutral-800">
                <h3 className="font-semibold text-white">Export Results</h3>
                <button
                  onClick={() => !isExporting && setIsOpen(false)}
                  className="p-1 hover:bg-neutral-800 rounded-lg transition-colors disabled:opacity-50"
                  disabled={!!isExporting}
                >
                  <X size={16} className="text-neutral-400" />
                </button>
              </div>

              <div className="p-4 space-y-3">
                {/* Status message */}
                <AnimatePresence>
                  {status && (
                    <motion.div
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      exit={{ opacity: 0, height: 0 }}
                      className={`flex items-center gap-2 p-2 rounded-lg text-sm ${
                        status.type === 'success'
                          ? 'bg-green-500/20 text-green-400'
                          : 'bg-red-500/20 text-red-400'
                      }`}
                    >
                      {status.type === 'success' ? (
                        <Check size={14} />
                      ) : (
                        <X size={14} />
                      )}
                      {status.message}
                    </motion.div>
                  )}
                </AnimatePresence>

                {/* Export options */}
                <button
                  onClick={() => handleExport('image')}
                  disabled={!!isExporting}
                  className="w-full flex items-center gap-3 p-3 bg-neutral-800 hover:bg-neutral-700 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isExporting === 'image' ? (
                    <Loader2 size={20} className="text-cyan-400 animate-spin" />
                  ) : (
                    <FileImage size={20} className="text-cyan-400" />
                  )}
                  <div className="text-left">
                    <p className="font-medium text-neutral-200">Save as Image</p>
                    <p className="text-xs text-neutral-500">PNG format, high quality</p>
                  </div>
                </button>

                <button
                  onClick={() => handleExport('pdf')}
                  disabled={!!isExporting}
                  className="w-full flex items-center gap-3 p-3 bg-neutral-800 hover:bg-neutral-700 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isExporting === 'pdf' ? (
                    <Loader2 size={20} className="text-purple-400 animate-spin" />
                  ) : (
                    <FileText size={20} className="text-purple-400" />
                  )}
                  <div className="text-left">
                    <p className="font-medium text-neutral-200">Save as PDF</p>
                    <p className="text-xs text-neutral-500">Printable document</p>
                  </div>
                </button>

                <p className="text-xs text-neutral-500 text-center pt-2">
                  Exports the current results view
                </p>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}
