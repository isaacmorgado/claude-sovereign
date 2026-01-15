'use client';

import Link from 'next/link';
import { ArrowLeft, ShieldAlert, Scale, Gavel } from 'lucide-react';

export default function TermsPage() {
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
                Terms of <span className="text-cyan-400">Operation</span>
              </h1>
              <p className="text-neutral-500 font-medium max-w-md uppercase text-xs tracking-[0.2em]">
                Legal Framework & User Agreement • Version 2025.A
              </p>
            </div>
            <div className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-700 border border-neutral-900 px-3 py-1 rounded-full">
              EST. READ TIME: 4m
            </div>
          </div>
        </header>

        <section className="mb-16 p-8 rounded-3xl bg-neutral-900/60 border border-white/5">
          <h2 className="text-[10px] font-black uppercase tracking-widest text-cyan-500 mb-4">Executive Summary (TL;DR)</h2>
          <ul className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">NOT MEDICAL</span> Educational analysis only. Consult pros before surgery.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">AGE 18+</span> Restricted to adults. No minor usage permitted.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">OWNERSHIP</span> You own your data. We provide the processing tools.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">LIABILITY</span> Use at your own risk. Scores are based on AI models.
            </li>
          </ul>
        </section>

        <div className="space-y-12 text-neutral-400 font-medium leading-relaxed">
          <section className="p-10 rounded-[2.5rem] bg-red-950/10 border border-red-500/20 mb-16">
            <div className="flex items-center gap-3 text-red-400 mb-6">
              <ShieldAlert size={24} />
              <h2 className="text-xl font-black italic uppercase">Critical Disclaimer: NOT MEDICAL ADVICE</h2>
            </div>
            <p className="text-sm leading-relaxed mb-4">
              LOOKSMAXX LABS IS A BIOMETRIC SOFTWARE SUITE FOR AESTHETIC ANALYSIS. IT IS NOT A MEDICAL DEVICE.
            </p>
            <p className="text-xs opacity-70">
              All analysis results, scores, potential vectors, and treatment simulations are strictly for educational and entertainment purposes. We do not provide medical diagnoses or surgical recommendations. Consult with a board-certified plastic surgeon before any physical intervention.
            </p>
          </section>

          <div className="grid md:grid-cols-2 gap-12">
            <section>
              <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
                <Scale size={14} className="text-cyan-400" />
                01. Acceptance
              </h3>
              <p className="text-sm">
                Accessing our portal constitutes a binding agreement to these terms. If you do not agree to the quantum of these protocols, immediate cessation of service use is required.
              </p>
            </section>

            <section>
              <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
                <Gavel size={14} className="text-cyan-400" />
                02. Eligibility
              </h3>
              <p className="text-sm">
                The platform is restricted to individuals aged 18 and older. Use by minors is strictly prohibited due to the psychological nature of aesthetic validation.
              </p>
            </section>
          </div>

          <div className="h-px bg-neutral-900 my-12" />

          <section className="space-y-8">
            <div>
              <h3 className="text-white font-black italic uppercase mb-4">03. AI Analysis Limitations</h3>
              <p className="text-sm">
                Our AI models generate scores based on pixel data and probabilistic archetypes. These scores reflect mathematical symmetry, not absolute beauty or personal worth. Accuracy is contingent on lighting, camera focal length, and landmark detection precision.
              </p>
            </div>

            <div>
              <h3 className="text-white font-black italic uppercase mb-4">04. Limitation of Liability</h3>
              <p className="text-sm">
                LOOKSMAXX LABS assumes zero liability for emotional responses, financial expenditures on recommended treatments, or surgical outcomes. Your aesthetic evolution is your own sovereign responsibility.
              </p>
            </div>

            <div>
              <h3 className="text-white font-black italic uppercase mb-4">05. Data Sovereignty</h3>
              <p className="text-sm">
                You grant us a license to process your biometric data for the purpose of analysis. We do not own your face. You may trigger a &ldquo;Hard Clear&rdquo; command in settings to remove all files from our active buffers at any time.
              </p>
            </div>
          </section>

          <footer className="mt-32 pt-12 border-t border-neutral-900 text-center font-mono text-[10px] text-neutral-700">
            LAST LOG UPDATE: 2025.12.23 // LOC: GLOBAL_FEDERATION
          </footer>
        </div>
      </div>
    </main>
  );
}
