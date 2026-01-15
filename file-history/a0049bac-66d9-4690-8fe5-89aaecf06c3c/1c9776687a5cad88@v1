'use client';

import React from 'react';
import { X, Check, Flame, Crown, Zap, Loader2 } from 'lucide-react';

interface PricingModalProps {
    isOpen: boolean;
    onClose: () => void;
}

const PricingModal: React.FC<PricingModalProps> = ({ isOpen, onClose }) => {
    const [selectedPlan, setSelectedPlan] = React.useState<'weekly' | 'pro' | 'action'>('weekly');
    const [isProcessing, setIsProcessing] = React.useState(false);

    if (!isOpen) return null;

    const handlePayment = async () => {
        setIsProcessing(true);
        // Simulate API call for checkout
        try {
            // In a real app, we'd call api.createCheckout(selectedPlan === 'weekly' ? 'basic' : 'pro')
            await new Promise(resolve => setTimeout(resolve, 1500));
            alert(`Redirecting to payment for ${selectedPlan} plan... (Simulated)`);
            onClose();
        } catch (error) {
            console.error('Payment error:', error);
        } finally {
            setIsProcessing(false);
        }
    };

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
            <div className="relative w-full max-w-2xl bg-[#0a0a0a] border border-white/10 rounded-2xl overflow-hidden shadow-2xl animate-in fade-in zoom-in duration-300">
                {/* Close Button */}
                <button
                    onClick={onClose}
                    className="absolute top-4 right-4 p-2 text-white/50 hover:text-white transition-colors"
                >
                    <X size={24} />
                </button>

                <div className="flex flex-col md:flex-row">
                    {/* Left Side: Benefits */}
                    <div className="flex-1 p-8 bg-gradient-to-b from-blue-600/10 to-transparent">
                        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/20 border border-blue-500/30 text-blue-400 text-xs font-bold mb-6">
                            <Crown size={12} />
                            SYMMETRY PRO
                        </div>

                        <h2 className="text-3xl font-black text-white mb-4 leading-none">
                            UNLOCK YOUR <br />
                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-indigo-500">
                                FULL POTENTIAL
                            </span>
                        </h2>

                        <ul className="space-y-4 mb-8">
                            {[
                                "Detailed AI Skin & Hair Analysis",
                                "PSL God-Tier Rank Calculation",
                                "Unlock All Hidden Ratios",
                                "Custom 12-Week Glow Up Plan",
                                "Ad-Free Premium Experience"
                            ].map((benefit, i) => (
                                <li key={i} className="flex items-start gap-3 text-white/70">
                                    <div className="mt-1 p-0.5 rounded-full bg-green-500/20 text-green-400">
                                        <Check size={14} />
                                    </div>
                                    <span className="text-sm">{benefit}</span>
                                </li>
                            ))}
                        </ul>

                        <div className="p-4 rounded-xl bg-white/5 border border-white/10">
                            <div className="flex items-center gap-3 mb-2">
                                <Flame className="text-orange-500" size={20} />
                                <span className="text-sm font-bold text-white">Join 45,000+ Moggers</span>
                            </div>
                            <p className="text-xs text-white/40 italic">&ldquo;The analysis was frighteningly accurate. It pointed out flaws I never even noticed.&rdquo;</p>
                        </div>
                    </div>

                    {/* Right Side: Plans */}
                    <div className="w-full md:w-[320px] p-8 border-t md:border-t-0 md:border-l border-white/10 bg-white/[0.02]">
                        <h3 className="text-sm font-bold text-white/60 mb-6 uppercase tracking-widest">Select Plan</h3>

                        <div className="space-y-4">
                            {/* Weekly Plan */}
                            <button
                                onClick={() => setSelectedPlan('weekly')}
                                className={`relative w-full p-4 rounded-xl border-2 transition-all text-left group ${selectedPlan === 'weekly' ? 'border-blue-500 bg-blue-500/5' : 'border-white/10 bg-white/5 hover:bg-white/10 hover:border-white/20'
                                    }`}
                            >
                                {selectedPlan === 'weekly' && (
                                    <div className="absolute -top-3 left-4 px-2 py-0.5 bg-blue-500 text-[10px] font-black text-white rounded uppercase">
                                        Best Value
                                    </div>
                                )}
                                <div className="flex justify-between items-center mb-1">
                                    <span className="text-sm font-bold text-white">Weekly Access</span>
                                    <span className="text-xl font-black text-white">$6.99</span>
                                </div>
                                <div className="text-[10px] text-white/50 uppercase font-bold">Billed weekly. Cancel anytime.</div>
                            </button>

                            {/* Monthly Plan */}
                            <button
                                onClick={() => setSelectedPlan('pro')}
                                className={`w-full p-4 rounded-xl border transition-all text-left ${selectedPlan === 'pro' ? 'border-blue-500 bg-blue-500/5' : 'border-white/10 bg-white/5 hover:bg-white/10 hover:border-white/20'
                                    }`}
                            >
                                <div className="flex justify-between items-center mb-1">
                                    <span className="text-sm font-bold text-white">Pro Pass</span>
                                    <span className="text-xl font-black text-white">$19.99</span>
                                </div>
                                <div className="text-[10px] text-white/50 uppercase font-bold">One month of full access.</div>
                            </button>

                            {/* Lifetime / Pro Action Plan */}
                            <button
                                onClick={() => setSelectedPlan('action')}
                                className={`w-full p-4 rounded-xl border transition-all text-left ${selectedPlan === 'action' ? 'border-blue-500 bg-blue-500/5' : 'border-white/10 bg-white/5 hover:bg-white/10 hover:border-white/20'
                                    }`}
                            >
                                <div className="flex justify-between items-center mb-1">
                                    <span className="text-sm font-bold text-white">Pro Action Plan</span>
                                    <span className="text-xl font-black text-white">$49.99</span>
                                </div>
                                <div className="text-[10px] text-white/50 uppercase font-bold">Full unlock + Course + VIP Support.</div>
                            </button>
                        </div>

                        <button
                            onClick={handlePayment}
                            disabled={isProcessing}
                            className="w-full mt-8 py-4 px-6 bg-white text-black font-black rounded-xl hover:bg-blue-50 transition-all flex items-center justify-center gap-2 group shadow-[0_0_20px_rgba(255,255,255,0.1)] disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {isProcessing ? (
                                <Loader2 className="animate-spin" size={18} />
                            ) : (
                                <>
                                    CONTINUE TO PAYMENT
                                    <Zap size={18} className="fill-current" />
                                </>
                            )}
                        </button>

                        <p className="mt-4 text-[10px] text-center text-white/30 uppercase font-bold">
                            Secure Checkout · Encrypted Payment
                        </p>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default PricingModal;
