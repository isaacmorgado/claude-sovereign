'use client';

import Link from 'next/link';
import { XCircle, ArrowLeft, RefreshCw } from 'lucide-react';
import { motion } from 'framer-motion';

export default function PaymentCancelPage() {
  return (
    <main className="min-h-screen bg-black flex items-center justify-center px-4">
      <motion.div
        className="max-w-md w-full text-center"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        {/* Cancel Icon */}
        <motion.div
          className="w-20 h-20 mx-auto mb-6 rounded-full bg-orange-500/20 flex items-center justify-center"
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
        >
          <XCircle className="w-10 h-10 text-orange-400" />
        </motion.div>

        {/* Title */}
        <h1 className="text-3xl font-bold text-white mb-3">
          Payment Cancelled
        </h1>

        <p className="text-neutral-400 mb-8">
          Your payment was not completed. No charges were made to your account.
        </p>

        {/* Info box */}
        <div className="bg-neutral-900/50 border border-neutral-800 rounded-xl p-6 mb-8">
          <p className="text-sm text-neutral-300">
            If you experienced any issues during checkout, please try again or contact support. Your referral discount will still be applied.
          </p>
        </div>

        {/* Actions */}
        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <Link
            href="/results"
            className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-neutral-800 text-white font-medium rounded-xl hover:bg-neutral-700 transition-colors"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Results
          </Link>

          <Link
            href="/pricing"
            className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-cyan-500 text-black font-medium rounded-xl hover:bg-cyan-400 transition-colors"
          >
            <RefreshCw className="w-4 h-4" />
            Try Again
          </Link>
        </div>
      </motion.div>
    </main>
  );
}
