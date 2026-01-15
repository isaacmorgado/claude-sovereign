'use client';

import React from 'react';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';

const faqs = [
    {
        category: "General",
        items: [
            { q: "What is LooksMaxx AI?", a: "LooksMaxx AI is a premium facial morphometric engine that uses artificial intelligence to analyze facial landmarks, symmetry, and proportions based on established aesthetic scientific canons." },
            { q: "Is this medically accurate?", a: "While our algorithms are based on anthropometric research and neo-classical canons, this is an aesthetic validation tool, not a medical diagnosis device. Always consult with a board-certified plastic surgeon for medical advice." },
        ]
    },
    {
        category: "Analysis & Metrics",
        items: [
            { q: "How many ratios do you track?", a: "Our Pro engine tracks over 60 distinct facial ratios, including the golden ratio, canthal tilt, gonial angle, midface height, and more." },
            { q: "What is the PSL scale?", a: "The 'Pretty Scale Level' (PSL) is a standardized aesthetic metric used in high-fashion and modeling industries to quantify facial attractiveness on a 1-10 scale based on developmental stability and harmony." },
        ]
    },
    {
        category: "Privacy & Security",
        items: [
            { q: "Are my photos private?", a: "Yes. Your photos are processed securely and are never shared with third parties. You have the right to delete your data at any time from your settings." },
            { q: "Do you store my biometric data?", a: "We only store the landmark coordinates and resultant scores to provide your analysis history. Raw images can be deleted immediately after processing." },
        ]
    }
];

export default function FAQPage() {
    return (
        <main className="min-h-screen bg-black text-white selection:bg-cyan-500/30">
            <div className="max-w-4xl mx-auto px-6 pt-32 pb-20">
                <Link href="/" className="inline-flex items-center gap-2 text-neutral-500 hover:text-cyan-400 text-xs font-black uppercase tracking-widest mb-12 transition-colors">
                    <ArrowLeft size={14} />
                    Back to Labs
                </Link>

                <header className="mb-20">
                    <h1 className="text-5xl font-black tracking-tighter italic uppercase mb-4">
                        Knowledge <span className="text-cyan-400">Base</span>
                    </h1>
                    <p className="text-neutral-500 font-medium max-w-md uppercase text-xs tracking-[0.2em]">
                        Frequently Asked Questions & Technical Documentation
                    </p>
                </header>

                <div className="space-y-16">
                    {faqs.map((cat, idx) => (
                        <section key={idx}>
                            <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-8 flex items-center gap-4">
                                {cat.category}
                                <div className="flex-1 h-px bg-neutral-900" />
                            </h2>
                            <div className="space-y-4">
                                {cat.items.map((item, iIdx) => (
                                    <div key={iIdx} className="p-8 rounded-3xl bg-neutral-900/30 border border-white/5 hover:border-white/10 transition-colors">
                                        <h3 className="text-lg font-black italic uppercase text-white mb-4">{item.q}</h3>
                                        <p className="text-neutral-400 text-sm font-medium leading-relaxed">{item.a}</p>
                                    </div>
                                ))}
                            </div>
                        </section>
                    ))}
                </div>

                <footer className="mt-20 pt-12 border-t border-neutral-900 flex flex-col items-center gap-6">
                    <p className="text-neutral-600 text-[10px] font-black uppercase tracking-widest">Still have technical queries?</p>
                    <Link href="mailto:support@looksmaxx.app" className="h-12 px-8 rounded-2xl bg-white/5 border border-white/10 text-white font-black uppercase tracking-widest text-xs flex items-center hover:bg-white/10 transition-all">
                        Contact Ops
                    </Link>
                </footer>
            </div>
        </main>
    );
}
