'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import {
  ArrowRight,
  Check,
  ShieldCheck,
  Microscope,
  Sparkles,
  Dna,
  Target,
  BarChart3,
  Users,
  Camera,
  Cpu,
  FileText,
  ChevronRight,
  Star,
  Globe,
  Zap,
} from 'lucide-react';

export default function HomePage() {
  const features = [
    {
      icon: Microscope,
      title: '120+ Landmarks',
      description: 'Sub-millimeter precision mapping of facial biometrics using MediaPipe + InsightFace dual-engine',
    },
    {
      icon: Dna,
      title: 'PSL Rating',
      description: 'Scientific attractiveness percentile ranking based on neo-classical canons',
    },
    {
      icon: Target,
      title: 'Improvement Plan',
      description: 'Personalized surgical and non-surgical roadmap with cost estimates',
    },
    {
      icon: BarChart3,
      title: 'Progress Tracking',
      description: 'Compare analyses over time and track your transformation',
    },
  ];

  const steps = [
    {
      num: '01',
      title: 'Upload Your Photos',
      description: 'Front and side profile photos for complete biometric analysis',
      icon: Camera,
    },
    {
      num: '02',
      title: 'AI Analysis Engine',
      description: '120+ landmarks mapped with 99.8% precision across diverse lighting conditions',
      icon: Cpu,
    },
    {
      num: '03',
      title: 'Receive Your Report',
      description: 'PSL rating, strengths, flaws, and personalized improvement roadmap',
      icon: FileText,
    },
  ];

  const plans = [
    {
      name: 'Free Analysis',
      price: '$0',
      period: 'Preview',
      features: [
        'Baseline Harmony Score',
        '3 Core Biometric Ratios',
        'Top Strength Analysis',
        'Limited Area Identification',
      ],
      cta: 'Start Free',
      highlighted: false,
    },
    {
      name: 'LooksMaxx Pro',
      price: '$49',
      period: 'Lifetime',
      badge: 'Recommended',
      features: [
        'Full 60+ Ratio Breakdown',
        'PSL Rating & Global Percentile',
        'Surgical & Non-Surgical Plan',
        'High-Res PDF Case Report',
        'Landmark Overlay Access',
        'Community Elite Access',
      ],
      cta: 'Unlock Everything',
      highlighted: true,
    },
    {
      name: 'Plus Access',
      price: '$25',
      period: 'One-Time',
      features: [
        'Full 60+ Ratio Breakdown',
        'Detailed Strength & Flaws',
        'Non-Surgical Plan Only',
        'Digital Export Only',
      ],
      cta: 'Go Plus',
      highlighted: false,
    },
  ];

  return (
    <main className="min-h-screen bg-black text-white selection:bg-cyan-500/30">
      {/* Subtle Background Glow */}
      <div className="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[500px] bg-cyan-500/5 blur-[150px] rounded-full" />
        <div className="absolute bottom-0 right-0 w-[600px] h-[400px] bg-blue-500/5 blur-[120px] rounded-full" />
      </div>

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 bg-black/90 backdrop-blur-xl border-b border-white/5 z-50">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-cyan-400 to-blue-600 flex items-center justify-center shadow-lg shadow-cyan-500/20">
              <ShieldCheck className="text-white w-4 h-4" />
            </div>
            <span className="text-sm font-black uppercase tracking-widest text-white">LOOKSMAXX</span>
          </Link>

          <nav className="hidden md:flex items-center gap-8">
            <Link href="/forum" className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500 hover:text-cyan-400 transition-colors">
              Community
            </Link>
            <Link href="/sources" className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500 hover:text-cyan-400 transition-colors">
              Methodology
            </Link>
            <Link href="/faq" className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500 hover:text-cyan-400 transition-colors">
              FAQ
            </Link>
          </nav>

          <div className="flex items-center gap-3">
            <Link
              href="/login"
              className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-500 hover:text-white transition-colors"
            >
              Sign In
            </Link>
            <Link
              href="/gender"
              className="h-10 px-5 rounded-xl bg-cyan-500 text-black text-[10px] font-black uppercase tracking-[0.15em] flex items-center gap-2 hover:bg-cyan-400 transition-all shadow-lg shadow-cyan-500/20"
            >
              Start Analysis <ArrowRight size={12} />
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative pt-40 pb-24 px-6 overflow-hidden">
        <div className="max-w-4xl mx-auto relative z-10">
          <div className="flex flex-col items-center text-center">
            {/* Social Proof Badge */}
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="inline-flex items-center gap-3 px-4 py-2 rounded-full bg-white/5 border border-white/10 mb-10"
            >
              <div className="flex -space-x-2">
                {[1, 2, 3, 4, 5].map(i => (
                  <div key={i} className="w-6 h-6 rounded-full border-2 border-black bg-gradient-to-br from-neutral-600 to-neutral-800" />
                ))}
              </div>
              <div className="flex items-center gap-2 text-xs">
                <Star size={12} className="text-yellow-400 fill-yellow-400" />
                <span className="text-white font-bold">45,000+</span>
                <span className="text-neutral-500">analyses completed</span>
              </div>
            </motion.div>

            {/* Main Headline */}
            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="text-5xl md:text-7xl font-black tracking-tighter italic uppercase mb-6"
            >
              Know Your <span className="text-cyan-400">Face</span>
            </motion.h1>

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="text-neutral-500 font-medium uppercase text-xs tracking-[0.2em] max-w-xl mb-12"
            >
              AI-Powered Facial Morphometric Analysis with 120+ Biometric Landmarks & Personalized Improvement Plans
            </motion.p>

            {/* CTA Buttons */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="flex flex-col sm:flex-row items-center gap-4 mb-16"
            >
              <Link
                href="/gender"
                className="group h-14 px-10 bg-cyan-500 text-black font-black uppercase tracking-widest text-xs rounded-2xl hover:bg-cyan-400 transition-all flex items-center gap-3 shadow-xl shadow-cyan-500/30"
              >
                Start Free Analysis
                <ArrowRight size={14} className="group-hover:translate-x-1 transition-transform" />
              </Link>
              <Link
                href="/forum"
                className="h-14 px-8 border border-white/10 text-neutral-400 rounded-2xl hover:bg-white/5 hover:border-white/20 transition-all flex items-center gap-2 text-xs font-black uppercase tracking-widest"
              >
                <Users size={14} />
                Join Community
              </Link>
            </motion.div>

            {/* Trust Badges */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.3 }}
              className="flex flex-wrap justify-center items-center gap-6"
            >
              <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-neutral-600">
                <ShieldCheck size={14} className="text-green-500" />
                Privacy First
              </div>
              <div className="w-1 h-1 rounded-full bg-neutral-800" />
              <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-neutral-600">
                <Sparkles size={14} className="text-cyan-400" />
                PhD Validated
              </div>
              <div className="w-1 h-1 rounded-full bg-neutral-800" />
              <div className="flex items-center gap-2 text-[10px] font-black uppercase tracking-widest text-neutral-600">
                <Zap size={14} className="text-yellow-400" />
                Instant Results
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-24 px-6 relative z-10">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-12 flex items-center gap-4">
            Core Capabilities
            <div className="flex-1 h-px bg-neutral-900" />
          </h2>

          <div className="grid md:grid-cols-2 gap-4">
            {features.map((feature, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className="group p-8 rounded-3xl bg-neutral-900/30 border border-white/5 hover:border-white/10 transition-all"
              >
                <div className="w-12 h-12 rounded-2xl bg-cyan-500/10 flex items-center justify-center mb-6 group-hover:bg-cyan-500/20 transition-colors">
                  <feature.icon size={22} className="text-cyan-400" />
                </div>
                <h3 className="text-lg font-black italic uppercase text-white mb-3">{feature.title}</h3>
                <p className="text-neutral-500 text-sm font-medium leading-relaxed">{feature.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="py-24 px-6 relative z-10">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-12 flex items-center gap-4">
            How It Works
            <div className="flex-1 h-px bg-neutral-900" />
          </h2>

          <div className="space-y-6">
            {steps.map((step, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className="group relative"
              >
                <div className="absolute -left-6 top-0 bottom-0 w-1 bg-cyan-500/0 group-hover:bg-cyan-500/50 transition-all" />
                <div className="flex gap-8 items-start p-8 rounded-3xl bg-neutral-900/30 border border-white/5 hover:border-white/10 transition-all">
                  <div className="w-14 h-14 rounded-2xl bg-neutral-900 border border-white/10 flex items-center justify-center shrink-0 group-hover:border-cyan-500/50 transition-colors">
                    <step.icon size={22} className="text-neutral-500 group-hover:text-cyan-400 transition-colors" />
                  </div>
                  <div>
                    <div className="flex items-center gap-3 mb-2">
                      <span className="text-[10px] font-black uppercase tracking-widest text-cyan-500">{step.num}</span>
                    </div>
                    <h3 className="text-xl font-black italic uppercase text-white mb-3 leading-tight group-hover:text-cyan-400 transition-colors">
                      {step.title}
                    </h3>
                    <p className="text-neutral-400 text-sm font-medium leading-relaxed max-w-xl">
                      {step.description}
                    </p>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Scientific Methodology Callout */}
      <section className="py-24 px-6 relative z-10">
        <div className="max-w-4xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="p-10 rounded-[2.5rem] bg-neutral-900/40 border border-white/5 relative overflow-hidden"
          >
            <div className="absolute top-0 right-0 p-8 opacity-10">
              <Globe size={120} />
            </div>
            <h2 className="text-xs font-black uppercase tracking-[0.4em] text-cyan-500 mb-6">Scientific Foundation</h2>
            <p className="text-xl font-bold italic text-neutral-200 leading-relaxed mb-6">
              &ldquo;FACIAL HARMONY IS NOT SUBJECTIVE—IT IS A BIOMETRIC EQUILIBRIUM.&rdquo;
            </p>
            <p className="text-neutral-500 text-sm leading-relaxed max-w-2xl mb-8">
              Every score generated by LOOKSMAXX LABS is derived from comparative analysis against the Neo-Classical Canons, Average Composite Models, and modern high-fashion developmental stability metrics. Our engine uses Computer Vision to identify 120+ landmarks with 99.8% precision.
            </p>
            <Link
              href="/sources"
              className="inline-flex items-center gap-3 px-5 py-3 rounded-xl bg-neutral-900 border border-white/5 text-cyan-400 text-[10px] font-black uppercase tracking-[0.2em] hover:bg-neutral-800 hover:border-cyan-500/30 transition-all"
            >
              View Peer-Reviewed Sources <ChevronRight size={14} />
            </Link>
          </motion.div>
        </div>
      </section>

      {/* Pricing Section */}
      <section id="pricing" className="py-24 px-6 relative z-10">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-12 flex items-center gap-4">
            Pricing Plans
            <div className="flex-1 h-px bg-neutral-900" />
          </h2>

          <div className="grid md:grid-cols-3 gap-4">
            {plans.map((plan, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className={`relative rounded-3xl p-8 flex flex-col ${
                  plan.highlighted
                    ? 'bg-neutral-900/60 border-2 border-cyan-500/50'
                    : 'bg-neutral-900/30 border border-white/5'
                }`}
              >
                {plan.badge && (
                  <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-cyan-500 text-black text-[9px] font-black uppercase tracking-widest px-4 py-1.5 rounded-full">
                    {plan.badge}
                  </div>
                )}
                <h3 className="text-sm font-black uppercase tracking-widest text-white mb-2">{plan.name}</h3>
                <div className="mb-6">
                  <span className="text-4xl font-black italic text-white">{plan.price}</span>
                  <span className="text-neutral-600 text-xs font-black uppercase tracking-widest ml-2">{plan.period}</span>
                </div>
                <ul className="space-y-3 mb-8 flex-grow">
                  {plan.features.map((feature, fIdx) => (
                    <li key={fIdx} className="flex items-start gap-3 text-sm text-neutral-400">
                      <Check size={16} className={`mt-0.5 shrink-0 ${plan.highlighted ? 'text-cyan-400' : 'text-neutral-600'}`} />
                      <span className="font-medium">{feature}</span>
                    </li>
                  ))}
                </ul>
                <Link
                  href="/gender"
                  className={`w-full h-12 rounded-xl text-[10px] font-black uppercase tracking-widest flex items-center justify-center transition-all ${
                    plan.highlighted
                      ? 'bg-cyan-500 text-black hover:bg-cyan-400'
                      : 'bg-white/5 border border-white/10 text-white hover:bg-white/10'
                  }`}
                >
                  {plan.cta}
                </Link>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-16 px-6 border-t border-neutral-900 relative z-10">
        <div className="max-w-4xl mx-auto">
          {/* Footer Grid */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-10 mb-16">
            {/* Brand */}
            <div className="col-span-2 md:col-span-1">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-8 h-8 rounded-xl bg-cyan-500/20 flex items-center justify-center">
                  <ShieldCheck className="text-cyan-400 w-4 h-4" />
                </div>
                <span className="text-sm font-black uppercase tracking-widest text-white">LOOKSMAXX</span>
              </div>
              <p className="text-xs text-neutral-600 font-medium leading-relaxed">
                AI-powered facial morphometric analysis for self-improvement
              </p>
            </div>

            {/* Product */}
            <div>
              <h4 className="text-[10px] font-black uppercase tracking-[0.3em] text-neutral-500 mb-4">Product</h4>
              <ul className="space-y-3">
                <li><Link href="/gender" className="text-xs text-neutral-600 hover:text-cyan-400 transition-colors font-medium">Start Analysis</Link></li>
                <li><Link href="/forum" className="text-xs text-neutral-600 hover:text-cyan-400 transition-colors font-medium">Community</Link></li>
                <li><Link href="#pricing" className="text-xs text-neutral-600 hover:text-cyan-400 transition-colors font-medium">Pricing</Link></li>
              </ul>
            </div>

            {/* Resources */}
            <div>
              <h4 className="text-[10px] font-black uppercase tracking-[0.3em] text-neutral-500 mb-4">Resources</h4>
              <ul className="space-y-3">
                <li><Link href="/faq" className="text-xs text-neutral-600 hover:text-cyan-400 transition-colors font-medium">Knowledge Base</Link></li>
                <li><Link href="/sources" className="text-xs text-neutral-600 hover:text-cyan-400 transition-colors font-medium">Methodology</Link></li>
              </ul>
            </div>

            {/* Legal */}
            <div>
              <h4 className="text-[10px] font-black uppercase tracking-[0.3em] text-neutral-500 mb-4">Legal</h4>
              <ul className="space-y-3">
                <li><Link href="/terms" className="text-xs text-neutral-600 hover:text-cyan-400 transition-colors font-medium">Terms of Service</Link></li>
                <li><Link href="/privacy" className="text-xs text-neutral-600 hover:text-cyan-400 transition-colors font-medium">Privacy Policy</Link></li>
              </ul>
            </div>
          </div>

          {/* Bottom Bar */}
          <div className="flex flex-col md:flex-row items-center justify-between gap-4 pt-8 border-t border-neutral-900">
            <p className="text-neutral-700 text-[10px] font-mono uppercase tracking-[0.2em]">
              © 2025 LOOKSMAXX LABS. All Rights Reserved.
            </p>
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
              <span className="text-[10px] font-black uppercase tracking-widest text-neutral-700">All Systems Operational</span>
            </div>
          </div>
        </div>
      </footer>
    </main>
  );
}
