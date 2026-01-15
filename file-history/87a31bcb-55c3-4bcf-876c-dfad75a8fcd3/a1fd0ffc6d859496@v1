'use client';

import Link from 'next/link';
import { ArrowLeft, Lock, Fingerprint, EyeOff, ShieldCheck, Database, Globe, Trash2, Cookie, Users, Mail } from 'lucide-react';

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-black text-white selection:bg-cyan-500/30">
      <div className="max-w-4xl mx-auto px-6 pt-32 pb-20">
        <Link href="/" className="inline-flex items-center gap-2 text-neutral-500 hover:text-cyan-400 text-xs font-black uppercase tracking-widest mb-12 transition-colors">
          <ArrowLeft size={14} />
          Back to Labs
        </Link>

        <header className="mb-12">
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 mb-4">
            <div>
              <h1 className="text-5xl font-black tracking-tighter italic uppercase mb-2">
                Privacy <span className="text-cyan-400">Policy</span>
              </h1>
              <p className="text-neutral-500 font-medium max-w-md uppercase text-xs tracking-[0.2em]">
                Data Governance & Protection Standards
              </p>
            </div>
            <div className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-700 border border-neutral-900 px-3 py-1 rounded-full">
              Last Updated: December 26, 2025
            </div>
          </div>
        </header>

        {/* Overview */}
        <section className="mb-16 p-8 rounded-3xl bg-cyan-950/10 border border-cyan-500/20">
          <p className="text-sm text-neutral-300 leading-relaxed">
            This Privacy Policy governs how LooxsmaxxLabs collects, uses, and protects your personal information.
            Our facial analysis service is provided for <strong className="text-white">entertainment and informational purposes only</strong>.
            By using our service, you consent to the data practices described in this policy.
          </p>
        </section>

        {/* TL;DR Summary */}
        <section className="mb-16 p-8 rounded-3xl bg-neutral-900/60 border border-white/5">
          <h2 className="text-[10px] font-black uppercase tracking-widest text-cyan-500 mb-4">Executive Summary (TL;DR)</h2>
          <ul className="grid md:grid-cols-3 gap-6">
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">NO SELLING</span> We never sell your personal information or facial images to third parties.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">ENCRYPTED</span> All data is protected with industry-standard encryption in transit and at rest.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">YOUR CONTROL</span> You can request deletion of your data within 30 days.
            </li>
          </ul>
        </section>

        <div className="space-y-16">
          {/* Data Collection */}
          <section className="grid lg:grid-cols-2 gap-12 items-start">
            <div className="p-10 rounded-[2.5rem] bg-cyan-950/10 border border-cyan-500/20">
              <div className="w-12 h-12 rounded-2xl bg-cyan-500/10 flex items-center justify-center mb-6">
                <Database className="text-cyan-400" size={24} />
              </div>
              <h2 className="text-xl font-black italic uppercase mb-4">Information We Collect</h2>
              <p className="text-sm text-neutral-400 font-medium leading-relaxed">
                We collect information necessary to provide our facial analysis service and maintain your account.
              </p>
            </div>

            <div className="space-y-8 py-6">
              <div className="flex gap-4">
                <div className="mt-1"><Fingerprint size={16} className="text-cyan-400" /></div>
                <div>
                  <h3 className="text-xs font-black uppercase tracking-widest text-white mb-2">Personal Information</h3>
                  <p className="text-xs text-neutral-500 font-bold">Email address, account credentials, payment information (processed via Stripe), and profile details you provide.</p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="mt-1"><EyeOff size={16} className="text-cyan-400" /></div>
                <div>
                  <h3 className="text-xs font-black uppercase tracking-widest text-white mb-2">Uploaded Content</h3>
                  <p className="text-xs text-neutral-500 font-bold">Facial photographs, measurement data, analysis results, symmetry scores, and progress tracking information.</p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="mt-1"><Globe size={16} className="text-cyan-400" /></div>
                <div>
                  <h3 className="text-xs font-black uppercase tracking-widest text-white mb-2">Technical Data</h3>
                  <p className="text-xs text-neutral-500 font-bold">Authentication session data, subscription status, and device/browser information for service optimization.</p>
                </div>
              </div>
            </div>
          </section>

          <div className="h-px bg-neutral-900" />

          {/* How We Use Data */}
          <section>
            <h3 className="text-lg font-black italic uppercase text-white mb-6 flex items-center gap-3">
              <Lock size={20} className="text-cyan-400" />
              How We Use Your Information
            </h3>
            <div className="grid md:grid-cols-2 gap-8">
              <div className="p-6 rounded-2xl bg-neutral-900/40 border border-white/5">
                <h4 className="text-xs font-black uppercase tracking-widest text-white mb-3">Service Delivery</h4>
                <ul className="text-xs text-neutral-500 font-bold space-y-2">
                  <li>• Facial analysis calculations and scoring</li>
                  <li>• Account management and authentication</li>
                  <li>• Progress tracking and history</li>
                  <li>• Personalized recommendations</li>
                </ul>
              </div>
              <div className="p-6 rounded-2xl bg-neutral-900/40 border border-white/5">
                <h4 className="text-xs font-black uppercase tracking-widest text-white mb-3">Operations</h4>
                <ul className="text-xs text-neutral-500 font-bold space-y-2">
                  <li>• Payment processing via Stripe</li>
                  <li>• Customer support communications</li>
                  <li>• Service improvement and debugging</li>
                  <li>• Algorithm enhancement (de-identified)</li>
                </ul>
              </div>
            </div>
          </section>

          {/* Cookies & Analytics */}
          <section className="p-8 rounded-2xl bg-neutral-900/40 border border-white/5">
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <Cookie size={14} className="text-cyan-400" />
              Cookies & Analytics
            </h3>
            <p className="text-sm text-neutral-400 mb-4">
              If you consent to analytics cookies, we may collect usage statistics through the following services:
            </p>
            <ul className="text-sm text-neutral-500 space-y-2 mb-4">
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span><strong className="text-white">Google Analytics</strong> - Website traffic and usage patterns</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span><strong className="text-white">Microsoft Clarity</strong> - User experience optimization</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span><strong className="text-white">Meta Pixel</strong> - Marketing attribution (if enabled)</span>
              </li>
            </ul>
            <p className="text-xs text-neutral-600">
              You can manage cookie preferences through your browser settings. Essential cookies required for service functionality cannot be disabled.
            </p>
          </section>

          <div className="h-px bg-neutral-900" />

          {/* Third Party Services */}
          <section>
            <h3 className="text-lg font-black italic uppercase text-white mb-6 flex items-center gap-3">
              <Users size={20} className="text-cyan-400" />
              Third-Party Services
            </h3>
            <p className="text-sm text-neutral-400 mb-6">
              We integrate with the following third-party services to provide our platform. Each has their own privacy policy:
            </p>
            <div className="grid md:grid-cols-3 gap-4">
              <div className="p-4 rounded-xl bg-neutral-900/40 border border-white/5">
                <h4 className="text-xs font-black uppercase text-white mb-2">Stripe</h4>
                <p className="text-[10px] text-neutral-600">Payment processing</p>
              </div>
              <div className="p-4 rounded-xl bg-neutral-900/40 border border-white/5">
                <h4 className="text-xs font-black uppercase text-white mb-2">AWS / Vercel</h4>
                <p className="text-[10px] text-neutral-600">Cloud infrastructure</p>
              </div>
              <div className="p-4 rounded-xl bg-neutral-900/40 border border-white/5">
                <h4 className="text-xs font-black uppercase text-white mb-2">SendGrid</h4>
                <p className="text-[10px] text-neutral-600">Transactional emails</p>
              </div>
            </div>
          </section>

          {/* Data Security */}
          <section className="p-8 rounded-2xl bg-green-950/10 border border-green-500/20">
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <ShieldCheck size={14} className="text-green-400" />
              Data Security & Storage
            </h3>
            <p className="text-sm text-neutral-400 mb-4">
              We implement industry-standard security measures to protect your data:
            </p>
            <ul className="text-sm text-neutral-500 space-y-2 mb-4">
              <li className="flex items-start gap-2">
                <span className="text-green-400 mt-1">•</span>
                <span>AES-256 encryption for data at rest</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-green-400 mt-1">•</span>
                <span>TLS 1.3 encryption for data in transit</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-green-400 mt-1">•</span>
                <span>Regular security audits and penetration testing</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-green-400 mt-1">•</span>
                <span>Access controls and authentication protocols</span>
              </li>
            </ul>
            <p className="text-xs text-neutral-600">
              <strong className="text-yellow-400">Disclaimer:</strong> While we implement robust security measures, we cannot guarantee absolute security of your data. No method of transmission over the Internet is 100% secure.
            </p>
          </section>

          {/* User Rights */}
          <section>
            <h3 className="text-lg font-black italic uppercase text-white mb-6 flex items-center gap-3">
              <Trash2 size={20} className="text-cyan-400" />
              Your Rights & Data Control
            </h3>
            <p className="text-sm text-neutral-400 mb-6">
              You have the following rights regarding your personal data:
            </p>
            <div className="grid md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <div className="p-4 rounded-xl bg-neutral-900/40 border border-white/5">
                  <h4 className="text-xs font-black uppercase text-white mb-2">Access</h4>
                  <p className="text-[10px] text-neutral-600">Request a copy of your personal data we hold.</p>
                </div>
                <div className="p-4 rounded-xl bg-neutral-900/40 border border-white/5">
                  <h4 className="text-xs font-black uppercase text-white mb-2">Correction</h4>
                  <p className="text-[10px] text-neutral-600">Request correction of inaccurate personal data.</p>
                </div>
              </div>
              <div className="space-y-4">
                <div className="p-4 rounded-xl bg-neutral-900/40 border border-white/5">
                  <h4 className="text-xs font-black uppercase text-white mb-2">Deletion</h4>
                  <p className="text-[10px] text-neutral-600">Request deletion of your account and data within 30 days.</p>
                </div>
                <div className="p-4 rounded-xl bg-neutral-900/40 border border-white/5">
                  <h4 className="text-xs font-black uppercase text-white mb-2">Portability</h4>
                  <p className="text-[10px] text-neutral-600">Request export of your data in a portable format.</p>
                </div>
              </div>
            </div>
            <p className="text-xs text-neutral-600 mt-6">
              We acknowledge and respect GDPR (EU), CCPA (California), and other applicable data protection regulations. You may withdraw consent at any time where consent is the basis for processing.
            </p>
          </section>

          {/* Data We Don't Collect */}
          <section className="p-8 rounded-2xl bg-neutral-900/40 border border-white/5">
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <EyeOff size={14} className="text-cyan-400" />
              What We Don&apos;t Do
            </h3>
            <ul className="text-sm text-neutral-400 space-y-3">
              <li className="flex items-start gap-3">
                <span className="text-green-400 text-lg">✓</span>
                <span>We do <strong className="text-white">NOT sell</strong> your personal information or facial images</span>
              </li>
              <li className="flex items-start gap-3">
                <span className="text-green-400 text-lg">✓</span>
                <span>We do <strong className="text-white">NOT share</strong> data with advertising networks</span>
              </li>
              <li className="flex items-start gap-3">
                <span className="text-green-400 text-lg">✓</span>
                <span>We do <strong className="text-white">NOT use</strong> your photos for training AI without consent</span>
              </li>
              <li className="flex items-start gap-3">
                <span className="text-green-400 text-lg">✓</span>
                <span>We do <strong className="text-white">NOT collect</strong> unnecessary location or background metadata</span>
              </li>
            </ul>
          </section>

          {/* Data Retention */}
          <section>
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6">
              Data Retention
            </h3>
            <p className="text-sm text-neutral-400 mb-4">
              We retain your data for as long as your account is active or as needed to provide services. After account deletion request:
            </p>
            <ul className="text-sm text-neutral-500 space-y-2">
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span>Photos and analysis data: Deleted within 30 days</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span>Account information: Deleted within 30 days</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span>Payment records: Retained for 7 years (legal requirement)</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span>De-identified analytics: May be retained indefinitely</span>
              </li>
            </ul>
          </section>

          {/* Contact */}
          <section className="p-8 rounded-2xl bg-cyan-950/10 border border-cyan-500/20">
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <Mail size={14} className="text-cyan-400" />
              Contact Us
            </h3>
            <p className="text-sm text-neutral-400 mb-4">
              For questions about this Privacy Policy or to exercise your data rights, contact us:
            </p>
            <div className="space-y-2">
              <p className="text-sm">
                Email: <a href="mailto:privacy@looxsmaxxlabs.com" className="text-cyan-400 hover:underline">privacy@looxsmaxxlabs.com</a>
              </p>
            </div>
          </section>
        </div>

        <footer className="mt-32 pt-12 border-t border-neutral-900 flex flex-col items-center gap-6">
          <p className="text-neutral-700 text-[10px] font-mono uppercase tracking-[0.2em]">
            Protocol: AES-256-GCM | Encrypted in Flight & At Rest
          </p>
          <p className="text-neutral-800 text-[10px] font-mono">
            LAST UPDATED: DECEMBER 26, 2025 // LOOXSMAXXLABS
          </p>
        </footer>
      </div>
    </main>
  );
}
