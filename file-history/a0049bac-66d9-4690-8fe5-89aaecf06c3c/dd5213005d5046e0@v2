'use client';

import Link from 'next/link';
import { ArrowRight, Scan, BarChart3, Zap, Check, X, MessageSquare, Users } from 'lucide-react';

export default function HomePage() {
  const features = [
    {
      icon: Scan,
      title: 'Upload Photos',
      description: 'Upload your front and side profile photos for comprehensive analysis.',
    },
    {
      icon: Zap,
      title: 'AI Analysis',
      description: 'Our AI automatically detects facial landmarks and calculates precise metrics.',
    },
    {
      icon: BarChart3,
      title: 'Get Results',
      description: 'Receive detailed scores and insights about your facial proportions.',
    },
  ];

  const plans = [
    {
      name: 'Free',
      price: '$0',
      period: 'forever',
      features: [
        { text: '10 Facial Ratios', included: true },
        { text: '2 Strengths & Flaws', included: true },
        { text: 'Side Profile Score', included: true },
        { text: 'Overall Harmony Score', included: false },
        { text: 'Your Plan', included: false },
      ],
      highlighted: false,
    },
    {
      name: 'Pro',
      price: '$49.99',
      period: '/month',
      badge: 'Best value',
      features: [
        { text: '60+ Facial Ratios', included: true },
        { text: 'Overall Harmony Score', included: true },
        { text: 'Full Strength & Flaws Analysis', included: true },
        { text: 'Your Personalized Plan', included: true },
        { text: 'Surgical Treatment Options', included: true },
      ],
      highlighted: true,
    },
    {
      name: 'Basic',
      price: '$24.99',
      period: '/month',
      features: [
        { text: '60+ Facial Ratios', included: true },
        { text: 'Overall Harmony Score', included: true },
        { text: 'Full Strength & Flaws Analysis', included: true },
        { text: 'Your Plan (Non-Surgical)', included: true },
        { text: 'Surgical Treatment Options', included: false },
      ],
      highlighted: false,
    },
  ];

  return (
    <main className="min-h-screen bg-black">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 bg-black/80 backdrop-blur-sm border-b border-neutral-800 z-50">
        <div className="max-w-5xl mx-auto px-4 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded bg-cyan-400/20 flex items-center justify-center">
              <span className="text-cyan-400 text-sm font-bold">L</span>
            </div>
            <span className="text-lg font-semibold text-white">LOOKSMAXX</span>
          </div>
          <div className="flex items-center gap-4">
            <Link
              href="/forum"
              className="flex items-center gap-2 text-neutral-400 hover:text-white text-sm font-medium transition-colors"
            >
              <MessageSquare className="w-4 h-4" />
              Community
            </Link>
            <Link
              href="/login"
              className="h-10 px-5 rounded-lg bg-cyan-400 text-black text-sm font-medium flex items-center gap-2 hover:shadow-[0_0_20px_rgba(34,211,238,0.3)] transition-all"
            >
              Get Started
              <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="pt-36 pb-24 px-4">
        <div className="max-w-3xl mx-auto text-center">
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-semibold tracking-tight text-white mb-6">
            Discover Your True<br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-cyan-300">Facial Score</span> in 60 Seconds
          </h1>
          <p className="text-lg md:text-xl text-neutral-400 mb-10 max-w-2xl mx-auto">
            Professional-grade facial metrics analysis powered by AI. Get detailed insights about your facial structure and proportions.
          </p>
          <div className="flex flex-col items-center gap-6">
            <Link
              href="/login"
              className="inline-flex items-center gap-2 h-12 px-8 rounded-xl bg-cyan-400 text-black font-medium hover:shadow-[0_0_30px_rgba(34,211,238,0.4)] transition-all"
            >
              Start Free Analysis
              <ArrowRight className="w-5 h-5" />
            </Link>

            {/* Social Proof */}
            <div className="flex items-center gap-3">
              {/* Avatar cluster */}
              <div className="flex -space-x-2">
                {[1, 2, 3, 4, 5].map((i) => (
                  <div
                    key={i}
                    className="w-8 h-8 rounded-full bg-gradient-to-br from-neutral-700 to-neutral-800 border-2 border-black flex items-center justify-center"
                  >
                    <Users className="w-4 h-4 text-neutral-500" />
                  </div>
                ))}
              </div>
              <div className="flex flex-col items-start">
                <span className="text-white font-semibold text-sm">47,832+</span>
                <span className="text-neutral-500 text-xs">faces analyzed this week</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="py-20 px-4 bg-neutral-900/50">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-2xl md:text-3xl font-semibold text-white text-center mb-12">
            How It Works
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            {features.map((feature, index) => (
              <div key={index} className="bg-black rounded-xl border border-neutral-800 p-6 hover:border-neutral-700 transition-colors">
                <div className="w-12 h-12 rounded-lg bg-cyan-400/10 flex items-center justify-center mb-4">
                  <feature.icon className="w-6 h-6 text-cyan-400" />
                </div>
                <h3 className="text-lg font-semibold text-white mb-2">{feature.title}</h3>
                <p className="text-neutral-400 text-sm">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section className="py-20 px-4">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-2xl md:text-3xl font-semibold text-white text-center mb-4">
            Pricing
          </h2>
          <p className="text-neutral-400 text-center mb-12">
            Choose the plan that works for you. Change or cancel anytime.
          </p>
          <div className="grid md:grid-cols-3 gap-6">
            {plans.map((plan, index) => (
              <div
                key={index}
                className={`relative rounded-xl p-6 flex flex-col ${
                  plan.highlighted
                    ? 'border-2 border-cyan-400 bg-black shadow-[0_0_30px_rgba(34,211,238,0.15)]'
                    : 'border border-neutral-800 bg-black'
                }`}
              >
                {plan.badge && (
                  <div className="absolute top-0 right-6 -mt-3 bg-cyan-400 text-black text-xs font-medium px-3 py-1 rounded-full">
                    {plan.badge}
                  </div>
                )}
                <h3 className="text-lg font-semibold text-white mb-2">{plan.name}</h3>
                <div className="mb-6">
                  <span className="text-3xl font-bold text-white">{plan.price}</span>
                  <span className="text-neutral-500 ml-1">{plan.period}</span>
                </div>
                <ul className="space-y-3 mb-6 flex-grow">
                  {plan.features.map((feature, featureIndex) => (
                    <li key={featureIndex} className="flex items-start gap-2 text-sm">
                      {feature.included ? (
                        <Check className="w-5 h-5 text-cyan-400 flex-shrink-0" />
                      ) : (
                        <X className="w-5 h-5 text-neutral-600 flex-shrink-0" />
                      )}
                      <span className={feature.included ? 'text-neutral-300' : 'text-neutral-600'}>
                        {feature.text}
                      </span>
                    </li>
                  ))}
                </ul>
                <Link
                  href="/login"
                  className={`w-full h-11 rounded-lg text-sm font-medium flex items-center justify-center transition-all ${
                    plan.highlighted
                      ? 'bg-cyan-400 text-black hover:shadow-[0_0_20px_rgba(34,211,238,0.3)]'
                      : 'border border-neutral-700 text-white hover:bg-white/5'
                  }`}
                >
                  Get started
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4 bg-neutral-900/50">
        <div className="max-w-3xl mx-auto text-center">
          <h2 className="text-2xl md:text-3xl font-semibold text-white mb-4">
            Ready to Start?
          </h2>
          <p className="text-neutral-400 mb-8">
            Join thousands of users who have discovered insights about their facial structure.
          </p>
          <Link
            href="/login"
            className="inline-flex items-center gap-2 h-12 px-8 rounded-xl bg-cyan-400 text-black font-medium hover:shadow-[0_0_30px_rgba(34,211,238,0.4)] transition-all"
          >
            Get Started Free
            <ArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 px-4 border-t border-neutral-800">
        <div className="max-w-5xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <div className="h-6 w-6 rounded bg-cyan-400/20 flex items-center justify-center">
              <span className="text-cyan-400 text-xs font-bold">L</span>
            </div>
            <span className="text-sm text-neutral-400">LOOKSMAXX</span>
          </div>
          <div className="flex items-center gap-6 text-sm text-neutral-500">
            <Link href="/terms" className="hover:text-white transition-colors">Terms</Link>
            <Link href="/privacy" className="hover:text-white transition-colors">Privacy</Link>
          </div>
          <div className="text-sm text-neutral-600">© 2025 LOOKSMAXX</div>
        </div>
      </footer>
    </main>
  );
}
