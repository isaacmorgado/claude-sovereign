'use client';

import Link from 'next/link';
import { ArrowLeft, ShieldAlert, Scale, Gavel, AlertTriangle, CreditCard, Database, UserX, FileWarning, MapPin } from 'lucide-react';

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
                Terms of <span className="text-cyan-400">Service</span>
              </h1>
              <p className="text-neutral-500 font-medium max-w-md uppercase text-xs tracking-[0.2em]">
                Legal Framework & User Agreement
              </p>
            </div>
            <div className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-700 border border-neutral-900 px-3 py-1 rounded-full">
              Last Updated: December 26, 2025
            </div>
          </div>
        </header>

        {/* TL;DR Summary */}
        <section className="mb-16 p-8 rounded-3xl bg-neutral-900/60 border border-white/5">
          <h2 className="text-[10px] font-black uppercase tracking-widest text-cyan-500 mb-4">Executive Summary (TL;DR)</h2>
          <ul className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">NOT MEDICAL</span> Educational analysis only. Consult professionals before any procedures.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">AGE 18+</span> Restricted to adults. No minor usage permitted.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">REFUNDS</span> 14-day refund if no analysis generated. After that, all sales final.
            </li>
            <li className="text-[10px] font-bold text-neutral-400 uppercase leading-relaxed">
              <span className="text-white block mb-1">LIABILITY</span> Use at your own risk. We assume no liability for outcomes.
            </li>
          </ul>
        </section>

        <div className="space-y-12 text-neutral-400 font-medium leading-relaxed">
          {/* Critical Medical Disclaimer */}
          <section className="p-10 rounded-[2.5rem] bg-red-950/10 border border-red-500/20 mb-16">
            <div className="flex items-center gap-3 text-red-400 mb-6">
              <ShieldAlert size={24} />
              <h2 className="text-xl font-black italic uppercase">Critical Disclaimer: NOT MEDICAL ADVICE</h2>
            </div>
            <p className="text-sm leading-relaxed mb-4">
              LOOXSMAXXLABS IS A FACIAL ANALYSIS TOOL PROVIDED FOR ENTERTAINMENT AND INFORMATIONAL PURPOSES ONLY. IT IS NOT A MEDICAL DEVICE AND DOES NOT PROVIDE MEDICAL ADVICE.
            </p>
            <p className="text-xs opacity-70 mb-4">
              Beauty inherently contains subjective elements, and our analysis results should be viewed as informational guidance rather than absolute truth. All analysis results, scores, potential improvements, and treatment simulations are strictly for educational purposes.
            </p>
            <p className="text-xs opacity-70">
              We do not provide medical diagnoses or surgical recommendations. You must consult with a board-certified plastic surgeon or qualified medical professional before undertaking any physical intervention or procedure.
            </p>
          </section>

          {/* Service Description */}
          <section>
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <Scale size={14} className="text-cyan-400" />
              01. Service Description
            </h3>
            <p className="text-sm mb-4">
              LooxsmaxxLabs is a facial analysis platform currently in beta that calculates ratios, proportions, and aesthetic metrics from user-uploaded photographs. Our service uses AI and computer vision technology to provide analysis of facial features.
            </p>
            <p className="text-sm">
              The platform provides scores, comparisons, and potential improvement vectors based on mathematical calculations and established aesthetic research. However, these are estimates and may not reflect actual results from any procedures or interventions.
            </p>
          </section>

          {/* Acceptance */}
          <section>
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <Gavel size={14} className="text-cyan-400" />
              02. Acceptance of Terms
            </h3>
            <p className="text-sm">
              By accessing or using LooxsmaxxLabs, you agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree to these terms, you must immediately cease using the service. We reserve the right to modify these terms at any time, and your continued use constitutes acceptance of any changes.
            </p>
          </section>

          {/* Eligibility */}
          <section>
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <UserX size={14} className="text-cyan-400" />
              03. Eligibility Requirements
            </h3>
            <p className="text-sm mb-4">
              The platform is restricted to individuals aged 18 years and older. Use by minors is strictly prohibited due to the psychological nature of aesthetic analysis and self-image assessment.
            </p>
            <p className="text-sm">
              By using LooxsmaxxLabs, you represent and warrant that you are at least 18 years of age and have the legal capacity to enter into this agreement.
            </p>
          </section>

          <div className="h-px bg-neutral-900 my-12" />

          {/* Landmark Accuracy */}
          <section>
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <AlertTriangle size={14} className="text-yellow-400" />
              04. Analysis Accuracy & Limitations
            </h3>
            <p className="text-sm mb-4">
              All analysis depends entirely on the quality of uploaded photographs and the accuracy of facial landmark detection. Factors that affect accuracy include:
            </p>
            <ul className="text-sm space-y-2 mb-4 ml-4">
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span>Lighting conditions and shadows</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span>Camera focal length and lens distortion</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span>Face angle and positioning</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-cyan-400 mt-1">•</span>
                <span>Image resolution and quality</span>
              </li>
            </ul>
            <p className="text-sm">
              All potential scores and improvement estimates are approximations and may not reflect actual results from any treatments or procedures. Different photographs of the same person may produce varying results.
            </p>
          </section>

          {/* Refund Policy */}
          <section className="p-8 rounded-2xl bg-neutral-900/40 border border-white/5">
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <CreditCard size={14} className="text-cyan-400" />
              05. Payment & Refund Policy
            </h3>
            <p className="text-sm mb-4">
              <strong className="text-white">14-Day Refund Window:</strong> Refunds are available within 14 days of purchase only if no facial analysis has been generated on your account.
            </p>
            <p className="text-sm mb-4">
              <strong className="text-white">Non-Refundable After Use:</strong> Once you have generated your first facial analysis, or after 14 days from purchase (whichever comes first), all payments are final and non-refundable.
            </p>
            <p className="text-sm">
              <strong className="text-white">Technical Issues:</strong> Bugs, service interruptions, or technical issues do not qualify for refunds. We will work to resolve any technical problems but cannot guarantee compensation for service disruptions.
            </p>
          </section>

          {/* User Data */}
          <section>
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <Database size={14} className="text-cyan-400" />
              06. User Data & Content
            </h3>
            <p className="text-sm mb-4">
              LooxsmaxxLabs stores uploaded photographs, analysis results, and account information necessary to provide the service. You retain ownership of your images.
            </p>
            <p className="text-sm mb-4">
              By uploading content, you grant us a limited, non-exclusive license to process your photographs solely for the purpose of providing facial analysis services. We do not claim ownership of your images or use them for purposes beyond service delivery.
            </p>
            <p className="text-sm">
              You may request deletion of your data at any time through your account settings. See our Privacy Policy for full details on data handling.
            </p>
          </section>

          {/* Account Termination */}
          <section>
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <UserX size={14} className="text-red-400" />
              07. Account Termination
            </h3>
            <p className="text-sm mb-4">
              We reserve the right to suspend or terminate your account at any time, for any reason or no reason, with or without notice. This includes, but is not limited to:
            </p>
            <ul className="text-sm space-y-2 mb-4 ml-4">
              <li className="flex items-start gap-2">
                <span className="text-red-400 mt-1">•</span>
                <span>Violation of these Terms of Service</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-red-400 mt-1">•</span>
                <span>Uploading inappropriate or illegal content</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-red-400 mt-1">•</span>
                <span>Abusive behavior toward staff or other users</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-red-400 mt-1">•</span>
                <span>Attempting to circumvent payment or access controls</span>
              </li>
            </ul>
            <p className="text-sm">
              Account termination does not entitle you to a refund of any fees paid.
            </p>
          </section>

          <div className="h-px bg-neutral-900 my-12" />

          {/* Limitation of Liability */}
          <section className="p-8 rounded-2xl bg-yellow-950/10 border border-yellow-500/20">
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <FileWarning size={14} className="text-yellow-400" />
              08. Limitation of Liability
            </h3>
            <p className="text-sm mb-4">
              TO THE MAXIMUM EXTENT PERMITTED BY LAW, LOOXSMAXXLABS AND ITS AFFILIATES ASSUME NO LIABILITY FOR:
            </p>
            <ul className="text-sm space-y-2 mb-4 ml-4">
              <li className="flex items-start gap-2">
                <span className="text-yellow-400 mt-1">•</span>
                <span>Decisions made based on analysis results</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-yellow-400 mt-1">•</span>
                <span>Outcomes of any medical or cosmetic procedures</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-yellow-400 mt-1">•</span>
                <span>Financial expenditures on recommended treatments</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-yellow-400 mt-1">•</span>
                <span>Emotional or psychological responses to analysis</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-yellow-400 mt-1">•</span>
                <span>Any indirect, incidental, or consequential damages</span>
              </li>
            </ul>
            <p className="text-sm">
              Your aesthetic evolution is your own sovereign responsibility. Use of this service is entirely at your own risk.
            </p>
          </section>

          {/* Governing Law */}
          <section>
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6 flex items-center gap-3">
              <MapPin size={14} className="text-cyan-400" />
              09. Governing Law & Disputes
            </h3>
            <p className="text-sm mb-4">
              These Terms of Service shall be governed by and construed in accordance with the laws of the State of Delaware, United States, without regard to its conflict of law provisions.
            </p>
            <p className="text-sm">
              Any disputes arising from or relating to these terms or your use of LooxsmaxxLabs shall be resolved through binding arbitration in Wilmington, Delaware. You agree to waive any right to a jury trial or to participate in a class action lawsuit.
            </p>
          </section>

          {/* Contact */}
          <section className="p-8 rounded-2xl bg-neutral-900/40 border border-white/5">
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-white mb-6">
              10. Contact Information
            </h3>
            <p className="text-sm mb-4">
              For questions about these Terms of Service, please contact us:
            </p>
            <p className="text-sm">
              Email: <a href="mailto:legal@looxsmaxxlabs.com" className="text-cyan-400 hover:underline">legal@looxsmaxxlabs.com</a>
            </p>
          </section>

          <footer className="mt-32 pt-12 border-t border-neutral-900 text-center font-mono text-[10px] text-neutral-700">
            LAST UPDATED: DECEMBER 26, 2025 // LOOXSMAXXLABS
          </footer>
        </div>
      </div>
    </main>
  );
}
