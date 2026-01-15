'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Share2, Copy, Check, X, Twitter, Link2 } from 'lucide-react';
import {
  shareResults,
  generateShareText,
  isNativeShareSupported,
  getShareableUrl
} from '@/lib/shareResults';

interface ShareButtonProps {
  score: number;
  frontScore?: number;
  sideScore?: number;
  variant?: 'button' | 'icon';
  className?: string;
}

export function ShareButton({
  score,
  frontScore,
  sideScore,
  variant = 'button',
  className = '',
}: ShareButtonProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [copied, setCopied] = useState(false);
  const [shareStatus, setShareStatus] = useState<string | null>(null);

  const shareText = generateShareText(score, frontScore, sideScore);
  const shareUrl = getShareableUrl();
  const hasNativeShare = isNativeShareSupported();

  const handleShare = async () => {
    if (hasNativeShare) {
      const result = await shareResults({
        title: 'My LOOKSMAXX Results',
        text: shareText,
        url: shareUrl,
      });

      if (result.success) {
        if (result.method === 'clipboard') {
          setShareStatus('Copied to clipboard!');
          setTimeout(() => setShareStatus(null), 2000);
        }
      }
    } else {
      setIsOpen(true);
    }
  };

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(`${shareText}\n\n${shareUrl}`);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      setShareStatus('Failed to copy');
      setTimeout(() => setShareStatus(null), 2000);
    }
  };

  const handleTwitterShare = () => {
    const tweetText = encodeURIComponent(shareText);
    const tweetUrl = encodeURIComponent(shareUrl);
    window.open(
      `https://twitter.com/intent/tweet?text=${tweetText}&url=${tweetUrl}`,
      '_blank',
      'noopener,noreferrer'
    );
    setIsOpen(false);
  };

  if (variant === 'icon') {
    return (
      <button
        onClick={handleShare}
        className={`p-2 rounded-lg bg-neutral-800 hover:bg-neutral-700 transition-colors ${className}`}
        title="Share results"
      >
        <Share2 size={18} className="text-neutral-300" />
      </button>
    );
  }

  return (
    <div className="relative">
      <button
        onClick={handleShare}
        className={`flex items-center gap-2 px-4 py-2 bg-neutral-800 hover:bg-neutral-700 rounded-lg transition-colors text-sm font-medium text-neutral-200 ${className}`}
      >
        <Share2 size={16} />
        <span>Share</span>
      </button>

      {/* Status toast */}
      <AnimatePresence>
        {shareStatus && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 10 }}
            className="absolute top-full mt-2 left-1/2 -translate-x-1/2 px-3 py-1.5 bg-green-500/20 border border-green-500/30 rounded-lg text-green-400 text-xs whitespace-nowrap"
          >
            {shareStatus}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Share modal for non-native share */}
      <AnimatePresence>
        {isOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/50 z-40"
              onClick={() => setIsOpen(false)}
            />
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="absolute top-full mt-2 right-0 w-72 bg-neutral-900 border border-neutral-700 rounded-xl shadow-2xl z-50 overflow-hidden"
            >
              <div className="flex items-center justify-between p-4 border-b border-neutral-800">
                <h3 className="font-semibold text-white">Share Results</h3>
                <button
                  onClick={() => setIsOpen(false)}
                  className="p-1 hover:bg-neutral-800 rounded-lg transition-colors"
                >
                  <X size={16} className="text-neutral-400" />
                </button>
              </div>

              <div className="p-4 space-y-3">
                {/* Preview */}
                <div className="p-3 bg-neutral-800 rounded-lg text-sm text-neutral-300 whitespace-pre-line">
                  {shareText}
                </div>

                {/* Share options */}
                <div className="grid grid-cols-2 gap-2">
                  <button
                    onClick={handleCopyLink}
                    className="flex items-center justify-center gap-2 px-3 py-2.5 bg-neutral-800 hover:bg-neutral-700 rounded-lg transition-colors"
                  >
                    {copied ? (
                      <Check size={16} className="text-green-400" />
                    ) : (
                      <Copy size={16} className="text-neutral-300" />
                    )}
                    <span className="text-sm text-neutral-200">
                      {copied ? 'Copied!' : 'Copy'}
                    </span>
                  </button>

                  <button
                    onClick={handleTwitterShare}
                    className="flex items-center justify-center gap-2 px-3 py-2.5 bg-neutral-800 hover:bg-neutral-700 rounded-lg transition-colors"
                  >
                    <Twitter size={16} className="text-neutral-300" />
                    <span className="text-sm text-neutral-200">Twitter</span>
                  </button>
                </div>

                {/* Direct link copy */}
                <button
                  onClick={handleCopyLink}
                  className="w-full flex items-center gap-2 px-3 py-2 bg-cyan-500/20 hover:bg-cyan-500/30 border border-cyan-500/30 rounded-lg transition-colors"
                >
                  <Link2 size={16} className="text-cyan-400" />
                  <span className="text-sm text-cyan-400 truncate flex-1 text-left">
                    {shareUrl}
                  </span>
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}
