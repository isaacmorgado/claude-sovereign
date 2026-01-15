'use client';

import { useState } from 'react';
import { X, Flag, AlertTriangle, Loader2 } from 'lucide-react';
import { ReportReason } from '@/types/forum';
import { api } from '@/lib/api';

interface ReportModalProps {
  isOpen: boolean;
  onClose: () => void;
  targetType: 'post' | 'comment';
  targetId: string;
}

const REPORT_REASONS: { value: ReportReason; label: string; description: string }[] = [
  { value: 'spam', label: 'Spam', description: 'Promotional content or repetitive messages' },
  { value: 'harassment', label: 'Harassment', description: 'Bullying, threats, or personal attacks' },
  { value: 'misinformation', label: 'Misinformation', description: 'False or misleading information' },
  { value: 'off_topic', label: 'Off Topic', description: 'Content unrelated to the discussion' },
  { value: 'inappropriate', label: 'Inappropriate', description: 'Offensive or explicit content' },
  { value: 'other', label: 'Other', description: 'Something else not listed above' },
];

export function ReportModal({ isOpen, onClose, targetType, targetId }: ReportModalProps) {
  const [selectedReason, setSelectedReason] = useState<ReportReason | null>(null);
  const [details, setDetails] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = async () => {
    if (!selectedReason) {
      setError('Please select a reason');
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      await api.createForumReport({
        targetType,
        targetId,
        reason: selectedReason,
        details: details.trim() || undefined,
      });
      setSuccess(true);
      setTimeout(() => {
        onClose();
        // Reset state after closing
        setSelectedReason(null);
        setDetails('');
        setSuccess(false);
      }, 1500);
    } catch (err) {
      if (err instanceof Error) {
        if (err.message.includes('already reported')) {
          setError('You have already reported this content');
        } else if (err.message.includes('Not authenticated')) {
          setError('Please log in to report content');
        } else {
          setError(err.message);
        }
      } else {
        setError('Failed to submit report');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleClose = () => {
    if (!isSubmitting) {
      onClose();
      setSelectedReason(null);
      setDetails('');
      setError(null);
      setSuccess(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/80 backdrop-blur-sm"
        onClick={handleClose}
      />

      {/* Modal */}
      <div className="relative w-full max-w-md rounded-2xl bg-neutral-900 border border-white/10 shadow-2xl overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-white/5">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-red-500/10 border border-red-500/20 flex items-center justify-center">
              <Flag className="w-5 h-5 text-red-400" />
            </div>
            <div>
              <h2 className="text-base font-bold text-white">Report {targetType === 'post' ? 'Post' : 'Comment'}</h2>
              <p className="text-[10px] text-neutral-500 uppercase tracking-wider">Help us maintain community standards</p>
            </div>
          </div>
          <button
            onClick={handleClose}
            disabled={isSubmitting}
            className="p-2 rounded-lg text-neutral-500 hover:bg-white/5 hover:text-white transition-all disabled:opacity-50"
          >
            <X size={18} />
          </button>
        </div>

        {/* Content */}
        <div className="p-5">
          {success ? (
            <div className="flex flex-col items-center py-8">
              <div className="w-16 h-16 rounded-full bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center mb-4">
                <Flag className="w-8 h-8 text-emerald-400" />
              </div>
              <h3 className="text-lg font-bold text-white mb-2">Report Submitted</h3>
              <p className="text-neutral-500 text-sm text-center">Thank you for helping keep our community safe.</p>
            </div>
          ) : (
            <>
              {/* Reason Selection */}
              <div className="space-y-2 mb-5">
                <label className="text-[10px] font-black uppercase tracking-widest text-neutral-500">
                  Reason for Report
                </label>
                <div className="grid gap-2">
                  {REPORT_REASONS.map((reason) => (
                    <button
                      key={reason.value}
                      onClick={() => setSelectedReason(reason.value)}
                      className={`w-full text-left p-3 rounded-xl border transition-all ${
                        selectedReason === reason.value
                          ? 'bg-cyan-500/10 border-cyan-500/30 text-white'
                          : 'bg-neutral-800/50 border-white/5 text-neutral-400 hover:border-white/10 hover:text-white'
                      }`}
                    >
                      <div className="text-sm font-medium">{reason.label}</div>
                      <div className="text-[10px] text-neutral-500 mt-0.5">{reason.description}</div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Additional Details */}
              <div className="mb-5">
                <label className="text-[10px] font-black uppercase tracking-widest text-neutral-500 block mb-2">
                  Additional Details (Optional)
                </label>
                <textarea
                  value={details}
                  onChange={(e) => setDetails(e.target.value)}
                  placeholder="Provide more context about this report..."
                  rows={3}
                  className="w-full bg-neutral-800/50 border border-white/5 rounded-xl p-3 text-sm text-white placeholder-neutral-600 resize-none focus:outline-none focus:border-cyan-500/30"
                />
              </div>

              {/* Error */}
              {error && (
                <div className="flex items-center gap-2 p-3 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400 text-sm mb-5">
                  <AlertTriangle size={16} />
                  {error}
                </div>
              )}

              {/* Actions */}
              <div className="flex gap-3">
                <button
                  onClick={handleClose}
                  disabled={isSubmitting}
                  className="flex-1 px-4 py-2.5 rounded-xl border border-white/10 text-neutral-400 text-[10px] font-black uppercase tracking-widest hover:bg-white/5 hover:text-white transition-all disabled:opacity-50"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSubmit}
                  disabled={isSubmitting || !selectedReason}
                  className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-red-500 text-white text-[10px] font-black uppercase tracking-widest hover:bg-red-400 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isSubmitting ? (
                    <>
                      <Loader2 size={14} className="animate-spin" />
                      Submitting...
                    </>
                  ) : (
                    <>
                      <Flag size={14} />
                      Submit Report
                    </>
                  )}
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
