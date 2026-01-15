'use client';

import { useEffect, useState } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { CheckCircle, ArrowRight, Sparkles } from 'lucide-react';
import { motion } from 'framer-motion';

export default function PaymentSuccessPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const [countdown, setCountdown] = useState(5);
  const sessionId = searchParams.get('session_id');

  useEffect(() => {
    // Auto-redirect to results after countdown
    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          router.push('/results');
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [router]);

  return (
    <main className="min-h-screen bg-black flex items-center justify-center px-4">
      <motion.div
        className="max-w-md w-full text-center"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        {/* Success Icon */}
        <motion.div
          className="w-20 h-20 mx-auto mb-6 rounded-full bg-green-500/20 flex items-center justify-center"
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
        >
          <CheckCircle className="w-10 h-10 text-green-400" />
        </motion.div>

        {/* Title */}
        <h1 className="text-3xl font-bold text-white mb-3">
          Payment Successful!
        </h1>

        <p className="text-neutral-400 mb-8">
          Your account has been upgraded. You now have access to all premium features.
        </p>

        {/* Features unlocked */}
        <div className="bg-neutral-900/50 border border-neutral-800 rounded-xl p-6 mb-8">
          <div className="flex items-center gap-2 mb-4">
            <Sparkles className="w-5 h-5 text-cyan-400" />
            <span className="text-sm font-medium text-white">Features Unlocked</span>
          </div>
          <ul className="space-y-2 text-left text-sm text-neutral-300">
            <li className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4 text-green-400 flex-shrink-0" />
              60+ Facial Ratio Analysis
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4 text-green-400 flex-shrink-0" />
              Complete Harmony Score
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4 text-green-400 flex-shrink-0" />
              Personalized Improvement Plan
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4 text-green-400 flex-shrink-0" />
              Treatment Recommendations
            </li>
          </ul>
        </div>

        {/* CTA */}
        <Link
          href="/results"
          className="inline-flex items-center gap-2 px-6 py-3 bg-cyan-500 text-black font-medium rounded-xl hover:bg-cyan-400 transition-colors"
        >
          View Your Results
          <ArrowRight className="w-4 h-4" />
        </Link>

        <p className="text-neutral-500 text-sm mt-4">
          Redirecting in {countdown}s...
        </p>

        {sessionId && (
          <p className="text-neutral-600 text-xs mt-6">
            Session: {sessionId.slice(0, 20)}...
          </p>
        )}
      </motion.div>
    </main>
  );
}
