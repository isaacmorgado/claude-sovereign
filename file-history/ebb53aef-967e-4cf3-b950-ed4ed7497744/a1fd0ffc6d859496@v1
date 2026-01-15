'use client';

import Link from 'next/link';
import { ArrowLeft, Lock, Fingerprint, EyeOff, ShieldCheck } from 'lucide-react';

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
                Privacy <span className="text-cyan-400">Protocol</span>
              </h1>
              <p className="text-neutral-500 font-medium max-w-md uppercase text-xs tracking-[0.2em]">
                Data Governance & Biometric Security Standards
              </p>
            </div>
            <div className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-700 border border-neutral-900 px-3 py-1 rounded-full">
              EST. READ TIME: 3m
            </div>
          </div>
        </header>

        <section className="mb-16 p-8 rounded-3xl bg-neutral-900/60 border border-white/5">
          <h2 className="text-[10px] font-black uppercase tracking-widest text-cyan-500 mb-4">Executive Summary (TL;DR)</h2>
          <ul className="grid md:grid-cols-3 gap-6">
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">NO SELLING</span> Your face is not a product. We never sell data to third parties.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">ENCRYPTED</span> All biometric analysis occurs in defense-grade silos.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">SOVEREIGNTY</span> You own your data. Trigger a &ldquo;Hard Clear&rdquo; any time.
            </li>
          </ul>
        </section>

        <div className="space-y-16">
          <section className="grid lg:grid-cols-2 gap-12 items-start">
            <div className="p-10 rounded-[2.5rem] bg-cyan-950/10 border border-cyan-500/20">
              <div className="w-12 h-12 rounded-2xl bg-cyan-500/10 flex items-center justify-center mb-6">
                <Lock className="text-cyan-400" size={24} />
              </div>
              <h2 className="text-xl font-black italic uppercase mb-4">Biometric Integrity</h2>
              <p className="text-sm text-neutral-400 font-medium leading-relaxed">
                At LOOKSMAXX LABS, we treat your facial data with the same security protocols used in defense-grade authentication. Your biometric markers are processed within isolated, encrypted environments.
              </p>
            </div>

            <div className="space-y-12 py-6">
              <div className="flex gap-4">
                <div className="mt-1"><Fingerprint size={16} className="text-cyan-400" /></div>
                <div>
                  <h3 className="text-xs font-black uppercase tracking-widest text-white mb-2">01. Collection Mode</h3>
                  <p className="text-xs text-neutral-500 font-bold">We only capture data necessary for morphometric calculation. We do not scrape background metadata or location telemetry.</p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="mt-1"><EyeOff size={16} className="text-cyan-400" /></div>
                <div>
                  <h3 className="text-xs font-black uppercase tracking-widest text-white mb-2">02. De-Identification</h3>
                  <p className="text-xs text-neutral-500 font-bold">Research data used to improve our AI models is strictly de-identified. Your results are tied to your unique ID, never your real-world identity unless you provide it.</p>
                </div>
              </div>
              <div className="flex gap-4">
                <div className="mt-1"><ShieldCheck size={16} className="text-cyan-400" /></div>
                <div>
                  <h3 className="text-xs font-black uppercase tracking-widest text-white mb-2">03. Zero Third-Party Sharing</h3>
                  <p className="text-xs text-neutral-500 font-bold">Your face is not a product. We never sell biometric or usage data to ad networks or data brokers.</p>
                </div>
              </div>
            </div>
          </section>

          <div className="h-px bg-neutral-900" />

          <section className="space-y-12">
            <div>
              <h3 className="text-lg font-black italic uppercase text-white mb-6">User Sovereignty Options</h3>
              <div className="grid md:grid-cols-2 gap-8 font-medium">
                <div className="space-y-2">
                  <h4 className="text-xs font-black uppercase tracking-widest text-neutral-400">Ephemeral Photo Mode</h4>
                  <p className="text-xs text-neutral-600 leading-relaxed">Photos can be set to delete immediately after the landmark detection phase. Only the resultant coordinates are saved for your reports.</p>
                </div>
                <div className="space-y-2">
                  <h4 className="text-xs font-black uppercase tracking-widest text-neutral-400">Hard Clear Command</h4>
                  <p className="text-xs text-neutral-600 leading-relaxed">A single command in your Account Portal allows for the immediate, irreversible destruction of all associated data records.</p>
                </div>
              </div>
            </div>
          </section>
        </div>

        <footer className="mt-32 pt-12 border-t border-neutral-900 flex flex-col items-center gap-6">
          <p className="text-neutral-700 text-[10px] font-mono uppercase tracking-[0.2em]">
            Protocol: AES-256-GCM | Encrypted in Flight & At Rest
          </p>
          <Link href="mailto:privacy@looksmaxx.app" className="text-cyan-400 text-[10px] font-black uppercase tracking-widest hover:underline">
            Contact Data Protection Officer (DPO)
          </Link>
        </footer>
      </div>
    </main>
  );
}
