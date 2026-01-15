'use client';

import React from 'react';
import { X, Check, Zap, Loader2, Sparkles, ShieldCheck } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface PricingModalProps {
    isOpen: boolean;
    onClose: () => void;
}

type PlanId = 'weekly' | 'action';

const plans: { id: PlanId; name: string; price: string; period: string; description: string; tag: string; features: string[] }[] = [
    {
        id: 'weekly',
        name: 'FaceIQ Pro',
        price: '6.99',
        period: 'Weekly',
        description: 'Billed weekly. Cancel anytime.',
        tag: 'Scientific Choice',
        features: [
            "PSL God-Tier Rank Calculation",
            "Unlock 60+ Hidden Ratios",
            "Detailed Analysis PDF",
            "Growth Potential Mapping"
        ]
    },
    {
        id: 'action',
        name: 'Advanced Plus',
        price: '49.99',
        period: 'One-Time',
        description: 'Lifetime Priority Access',
        tag: 'Maximum Value',
        features: [
            "Universal Metric Access",
            "12-Week Aesthetic Strategy",
            "VIP Operational Support",
            "Early Access to Lab Tools"
        ]
    }
];

const PricingModal: React.FC<PricingModalProps> = ({ isOpen, onClose }) => {
    const [selectedPlan, setSelectedPlan] = React.useState<PlanId>('weekly');
    const [isProcessing, setIsProcessing] = React.useState(false);

    const handlePayment = async () => {
        setIsProcessing(true);
        try {
            await new Promise(resolve => setTimeout(resolve, 1500));
            // Simulated redirect
            window.location.href = `/checkout?plan=${selectedPlan}`;
        } catch (error) {
            console.error('Payment error:', error);
        } finally {
            setIsProcessing(false);
        }
    };

    return (
        <AnimatePresence>
            {isOpen && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        className="absolute inset-0 bg-black/80 backdrop-blur-xl"
                    />

                    <motion.div
                        initial={{ opacity: 0, scale: 0.95, y: 20 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        exit={{ opacity: 0, scale: 0.95, y: 20 }}
                        className="relative w-full max-w-4xl bg-[#050505] border border-white/5 rounded-[2.5rem] overflow-hidden shadow-[0_0_50px_rgba(0,0,0,0.5)] flex flex-col md:flex-row"
                    >
                        {/* Decorative background glow */}
                        <div className="absolute top-0 left-0 w-full h-full pointer-events-none opacity-20">
                            <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-cyan-500/20 blur-[120px] rounded-full" />
                            <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-indigo-500/20 blur-[120px] rounded-full" />
                        </div>

                        {/* Left Side: Cinematic Promo */}
                        <div className="flex-1 p-12 relative overflow-hidden flex flex-col">
                            <button
                                onClick={onClose}
                                className="md:hidden absolute top-6 right-6 p-2 text-white/30 hover:text-white transition-colors"
                            >
                                <X size={20} />
                            </button>

                            <div className="mb-auto">
                                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-cyan-500/10 border border-cyan-500/20 text-cyan-400 text-[10px] font-black uppercase tracking-[0.2em] mb-8">
                                    <Sparkles size={10} />
                                    Phase 2: Ascension
                                </div>

                                <h2 className="text-4xl md:text-5xl font-black text-white italic uppercase tracking-tighter leading-[0.9] mb-6">
                                    Evolve Beyond <br />
                                    <span className="text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 via-white to-indigo-400">
                                        The Average
                                    </span>
                                </h2>

                                <div className="space-y-6">
                                    {plans.find(p => p.id === selectedPlan)?.features.map((feature, i) => (
                                        <motion.div
                                            key={i}
                                            initial={{ opacity: 0, x: -10 }}
                                            animate={{ opacity: 1, x: 0 }}
                                            transition={{ delay: i * 0.1 }}
                                            className="flex items-center gap-4 group"
                                        >
                                            <div className="w-6 h-6 rounded-lg bg-neutral-900 border border-white/5 flex items-center justify-center shrink-0 group-hover:border-cyan-500/50 transition-colors">
                                                <Check size={12} className="text-cyan-400" />
                                            </div>
                                            <span className="text-sm font-bold text-neutral-400 tracking-tight group-hover:text-neutral-200 transition-colors">{feature}</span>
                                        </motion.div>
                                    ))}
                                </div>
                            </div>

                            <div className="mt-12 pt-8 border-t border-white/5">
                                <div className="flex items-center gap-4">
                                    <div className="flex -space-x-2">
                                        {[1, 2, 3].map(i => (
                                            <div key={i} className="w-8 h-8 rounded-full border-2 border-black bg-neutral-800" />
                                        ))}
                                    </div>
                                    <div className="text-[10px] font-black uppercase tracking-widest text-neutral-500">
                                        <span className="text-white">45,000+</span> Analyses Completed
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Right Side: Selection & Checkout */}
                        <div className="w-full md:w-[380px] p-8 md:p-12 bg-white/[0.01] border-t md:border-t-0 md:border-l border-white/5 relative flex flex-col">
                            <button
                                onClick={onClose}
                                className="hidden md:block absolute top-6 right-6 p-2 text-white/20 hover:text-white transition-colors"
                            >
                                <X size={20} />
                            </button>

                            <h3 className="text-[10px] font-black text-neutral-500 mb-8 uppercase tracking-[0.3em]">Operational Access</h3>

                            <div className="space-y-4 mb-8">
                                {plans.map((plan) => (
                                    <button
                                        key={plan.id}
                                        onClick={() => setSelectedPlan(plan.id)}
                                        className={`relative w-full p-6 rounded-[2rem] border-2 transition-all text-left ${selectedPlan === plan.id
                                                ? 'border-cyan-500 bg-cyan-500/5'
                                                : 'border-white/5 bg-transparent hover:border-white/10'
                                            }`}
                                    >
                                        {plan.id === 'weekly' && (
                                            <div className="absolute -top-3 right-8 px-3 py-1 bg-cyan-500 text-[8px] font-black text-black uppercase tracking-widest rounded-full">
                                                Most Popular
                                            </div>
                                        )}
                                        <div className="flex justify-between items-start mb-2">
                                            <div>
                                                <div className="text-[10px] font-black uppercase tracking-widest text-neutral-500 mb-1">
                                                    {plan.tag}
                                                </div>
                                                <div className="text-lg font-black text-white italic uppercase">{plan.name}</div>
                                            </div>
                                            <div className="text-right">
                                                <div className="text-2xl font-black text-white">${plan.price}</div>
                                                <div className="text-[10px] font-bold text-neutral-500 uppercase">{plan.period}</div>
                                            </div>
                                        </div>
                                    </button>
                                ))}
                            </div>

                            <div className="mt-auto space-y-4">
                                <button
                                    onClick={handlePayment}
                                    disabled={isProcessing}
                                    className="w-full py-5 bg-white text-black font-black italic uppercase tracking-widest rounded-2xl hover:bg-cyan-400 transition-all flex items-center justify-center gap-3 disabled:opacity-50"
                                >
                                    {isProcessing ? (
                                        <Loader2 className="animate-spin" size={20} />
                                    ) : (
                                        <>
                                            Execute Upgrade
                                            <Zap size={18} className="fill-current" />
                                        </>
                                    )}
                                </button>

                                <div className="space-y-3">
                                    <div className="flex items-center justify-center gap-4 opacity-40 grayscale contrast-200">
                                        {/* Mock security icons */}
                                        <ShieldCheck size={14} className="text-white" />
                                        <div className="text-[8px] font-black uppercase tracking-widest text-white">SSL SECURE PORTAL</div>
                                        <div className="w-4 h-4 rounded bg-white/20" />
                                        <div className="w-4 h-4 rounded-full bg-white/20" />
                                    </div>
                                    <p className="text-[8px] text-center font-bold text-neutral-500 uppercase tracking-widest">
                                        7-Day Satisfaction Guarantee • Cancel Anytime
                                    </p>
                                </div>
                            </div>
                        </div>
                    </motion.div>
                </div>
            )}
        </AnimatePresence>
    );
};

export default PricingModal;
