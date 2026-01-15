'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Check, X, Sparkles, Zap, ArrowLeft, Loader2, Tag } from 'lucide-react';
import { motion } from 'framer-motion';
import { api } from '@/lib/api';

interface Plan {
  id: 'basic' | 'pro';
  name: string;
  price: number;
  period: string;
  description: string;
  features: { text: string; included: boolean }[];
  highlighted: boolean;
  badge?: string;
}

const plans: Plan[] = [
  {
    id: 'basic',
    name: 'Basic',
    price: 24.99,
    period: 'one-time',
    description: 'Perfect for non-surgical improvements',
    features: [
      { text: '60+ Facial Ratios', included: true },
      { text: 'Overall Harmony Score', included: true },
      { text: 'Full Strength & Flaws Analysis', included: true },
      { text: 'Non-Surgical Treatment Plan', included: true },
      { text: 'Surgical Treatment Options', included: false },
    ],
    highlighted: false,
  },
  {
    id: 'pro',
    name: 'Pro',
    price: 49.99,
    period: 'one-time',
    description: 'Complete transformation roadmap',
    features: [
      { text: '60+ Facial Ratios', included: true },
      { text: 'Overall Harmony Score', included: true },
      { text: 'Full Strength & Flaws Analysis', included: true },
      { text: 'Personalized Treatment Plan', included: true },
      { text: 'Surgical Treatment Options', included: true },
    ],
    highlighted: true,
    badge: 'Best Value',
  },
];

export default function PricingPage() {
  const router = useRouter();
  const [loadingPlan, setLoadingPlan] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [discount, setDiscount] = useState<number | null>(null);

  useEffect(() => {
    // Check if user is authenticated
    const token = api.getToken();
    setIsAuthenticated(!!token);

    // Check for referral discount in localStorage (set during signup)
    const referralDiscount = localStorage.getItem('referral_discount');
    if (referralDiscount) {
      setDiscount(parseInt(referralDiscount, 10));
    }
  }, []);

  const handleCheckout = async (planId: 'basic' | 'pro') => {
    if (!isAuthenticated) {
      // Redirect to signup
      router.push('/signup');
      return;
    }

    setLoadingPlan(planId);
    setError(null);

    try {
      const result = await api.createCheckout(planId);
      // Redirect to Stripe checkout
      window.location.href = result.checkout_url;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to start checkout');
      setLoadingPlan(null);
    }
  };

  const getDiscountedPrice = (price: number) => {
    if (!discount) return price;
    return price * (1 - discount / 100);
  };

  return (
    <main className="min-h-screen bg-black">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 bg-black/80 backdrop-blur-sm border-b border-neutral-800 z-50">
        <div className="max-w-5xl mx-auto px-4 h-16 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-2">
            <div className="h-8 w-8 rounded bg-[#00f3ff]/20 flex items-center justify-center">
              <span className="text-[#00f3ff] text-sm font-bold">L</span>
            </div>
            <span className="text-lg font-semibold text-white">LOOKSMAXX</span>
          </Link>
          <Link
            href="/results"
            className="flex items-center gap-2 text-sm text-neutral-400 hover:text-white transition-colors"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Results
          </Link>
        </div>
      </header>

      {/* Content */}
      <div className="pt-24 pb-16 px-4">
        <div className="max-w-4xl mx-auto">
          {/* Title */}
          <motion.div
            className="text-center mb-12"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <h1 className="text-4xl font-bold text-white mb-4">
              Unlock Your Full Potential
            </h1>
            <p className="text-neutral-400 text-lg max-w-xl mx-auto">
              Get personalized recommendations and a complete roadmap to maximize your facial harmony.
            </p>

            {/* Discount Banner */}
            {discount && (
              <motion.div
                className="mt-6 inline-flex items-center gap-2 px-4 py-2 bg-green-500/20 border border-green-500/30 rounded-full"
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.3, type: 'spring' }}
              >
                <Tag className="w-4 h-4 text-green-400" />
                <span className="text-green-400 font-medium">
                  {discount}% discount applied!
                </span>
              </motion.div>
            )}
          </motion.div>

          {/* Error */}
          {error && (
            <div className="max-w-md mx-auto mb-8 p-4 bg-red-500/20 border border-red-500/30 rounded-xl text-center">
              <p className="text-red-400 text-sm">{error}</p>
            </div>
          )}

          {/* Plans */}
          <div className="grid md:grid-cols-2 gap-6 max-w-3xl mx-auto">
            {plans.map((plan, index) => (
              <motion.div
                key={plan.id}
                className={`relative rounded-2xl p-6 ${
                  plan.highlighted
                    ? 'bg-gradient-to-br from-cyan-500/10 to-blue-600/10 border-2 border-cyan-500/50'
                    : 'bg-neutral-900/50 border border-neutral-800'
                }`}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 * index }}
              >
                {/* Badge */}
                {plan.badge && (
                  <div className="absolute -top-3 left-1/2 -translate-x-1/2 px-3 py-1 bg-cyan-500 text-black text-xs font-bold rounded-full">
                    {plan.badge}
                  </div>
                )}

                {/* Plan Header */}
                <div className="text-center mb-6">
                  <h2 className="text-xl font-bold text-white mb-2">{plan.name}</h2>
                  <p className="text-neutral-400 text-sm mb-4">{plan.description}</p>

                  {/* Price */}
                  <div className="flex items-baseline justify-center gap-1">
                    {discount ? (
                      <>
                        <span className="text-2xl text-neutral-500 line-through">
                          ${plan.price}
                        </span>
                        <span className="text-4xl font-bold text-white">
                          ${getDiscountedPrice(plan.price).toFixed(2)}
                        </span>
                      </>
                    ) : (
                      <span className="text-4xl font-bold text-white">
                        ${plan.price}
                      </span>
                    )}
                    <span className="text-neutral-500 ml-1">{plan.period}</span>
                  </div>
                </div>

                {/* Features */}
                <ul className="space-y-3 mb-6">
                  {plan.features.map((feature, featureIndex) => (
                    <li
                      key={featureIndex}
                      className="flex items-center gap-3 text-sm"
                    >
                      {feature.included ? (
                        <Check className="w-5 h-5 text-green-400 flex-shrink-0" />
                      ) : (
                        <X className="w-5 h-5 text-neutral-600 flex-shrink-0" />
                      )}
                      <span className={feature.included ? 'text-white' : 'text-neutral-500'}>
                        {feature.text}
                      </span>
                    </li>
                  ))}
                </ul>

                {/* CTA Button */}
                <button
                  onClick={() => handleCheckout(plan.id)}
                  disabled={loadingPlan !== null}
                  className={`w-full py-3 rounded-xl font-medium flex items-center justify-center gap-2 transition-all ${
                    plan.highlighted
                      ? 'bg-cyan-500 text-black hover:bg-cyan-400 disabled:bg-cyan-500/50'
                      : 'bg-neutral-800 text-white hover:bg-neutral-700 disabled:bg-neutral-800/50'
                  } disabled:cursor-not-allowed`}
                >
                  {loadingPlan === plan.id ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Processing...
                    </>
                  ) : (
                    <>
                      {plan.highlighted ? (
                        <Sparkles className="w-4 h-4" />
                      ) : (
                        <Zap className="w-4 h-4" />
                      )}
                      {isAuthenticated ? 'Get Started' : 'Sign Up to Purchase'}
                    </>
                  )}
                </button>
              </motion.div>
            ))}
          </div>

          {/* Trust indicators */}
          <div className="mt-12 text-center">
            <p className="text-neutral-500 text-sm">
              Secure payment powered by Stripe. 30-day money-back guarantee.
            </p>
          </div>
        </div>
      </div>
    </main>
  );
}
