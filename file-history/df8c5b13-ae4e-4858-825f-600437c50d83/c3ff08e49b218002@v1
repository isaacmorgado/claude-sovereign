'use client';

import { useState, useEffect } from 'react';
import { Copy, Users, DollarSign, Share2, CheckCircle, Gift } from 'lucide-react';
import { TabContent } from '../ResultsLayout';
import { api } from '@/lib/api';

interface StatsState {
    code: string;
    referral_link: string;
    total_invites: number;
    earnings: number;
    discount_percent: number;
    loading: boolean;
    error: string | null;
}

export function ReferralsTab() {
    const [copied, setCopied] = useState(false);
    const [stats, setStats] = useState<StatsState>({
        code: '',
        referral_link: '',
        total_invites: 0,
        earnings: 0,
        discount_percent: 10,
        loading: true,
        error: null
    });

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const data = await api.getReferralStats();
                setStats({
                    code: data.code,
                    referral_link: data.referral_link,
                    total_invites: data.total_invites,
                    earnings: data.earnings,
                    discount_percent: data.discount_percent,
                    loading: false,
                    error: null
                });
            } catch (err) {
                // Fallback or error handling
                console.error("Failed to fetch referral stats", err);
                // We set loading false so UI shows something (maybe empty state)
                // But for better UX, we could try to derive default from user if possible or just show empty
                setStats(prev => ({ ...prev, loading: false, error: 'Failed to load referral stats' }));
            }
        };

        fetchStats();
    }, []);

    const handleCopy = () => {
        if (stats.referral_link) {
            navigator.clipboard.writeText(stats.referral_link);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        }
    };

    const handleShare = async () => {
        if (navigator.share && stats.referral_link) {
            try {
                await navigator.share({
                    title: 'Join me on LooksMaxx AI',
                    text: `Get your facial analysis! Use my code ${stats.code} for ${stats.discount_percent}% off.`,
                    url: stats.referral_link,
                });
            } catch (err) {
                console.error('Error sharing:', err);
            }
        } else {
            handleCopy();
        }
    };

    return (
        <TabContent
            title="Referral Program"
            subtitle="Invite friends and earn rewards"
        >
            <div className="max-w-4xl mx-auto space-y-8">

                {/* Main Card - Your Code */}
                <div className="bg-gradient-to-br from-neutral-900 to-neutral-800 border border-neutral-700 rounded-2xl p-6 md:p-8 relative overflow-hidden">
                    {/* Background decoration */}
                    <div className="absolute top-0 right-0 w-64 h-64 bg-cyan-500/10 rounded-full blur-[80px] -mr-16 -mt-16 pointer-events-none" />

                    <div className="relative z-10 flex flex-col md:flex-row gap-8 items-center">
                        <div className="flex-1 text-center md:text-left">
                            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-cyan-500/20 border border-cyan-500/30 text-cyan-400 text-xs font-semibold uppercase tracking-wider mb-4">
                                <Gift size={12} />
                                <span>Earn Cash</span>
                            </div>
                            <h2 className="text-3xl font-bold text-white mb-2">
                                Give {stats.discount_percent}%, Get $10
                            </h2>
                            <p className="text-neutral-400 mb-6">
                                Share your unique referral code with friends. They get a discount on their first analysis, and you earn cash for every signup.
                            </p>

                            <div className="flex flex-col sm:flex-row gap-3">
                                <button
                                    onClick={handleShare}
                                    className="px-6 py-3 bg-cyan-500 hover:bg-cyan-400 text-black font-bold rounded-xl transition-colors flex items-center justify-center gap-2"
                                >
                                    <Share2 size={18} />
                                    <span>Share Link</span>
                                </button>
                            </div>
                        </div>

                        {/* Code Box */}
                        <div className="w-full md:w-auto min-w-[300px]">
                            <div className="bg-black/40 backdrop-blur-sm border border-neutral-700 rounded-xl p-6">
                                <p className="text-neutral-500 text-sm mb-2 text-center">Your Referral Code</p>
                                <div
                                    onClick={handleCopy}
                                    className="flex items-center justify-between gap-4 bg-neutral-800 border border-neutral-700 rounded-lg p-3 cursor-pointer hover:border-cyan-500/50 transition-colors group"
                                >
                                    {stats.loading ? (
                                        <div className="h-8 w-full animate-pulse bg-neutral-700 rounded"></div>
                                    ) : (
                                        <code className="text-2xl font-mono font-bold text-white tracking-wider">
                                            {stats.code || '...'}
                                        </code>
                                    )}
                                    <div className="p-2 rounded-md bg-neutral-700 group-hover:bg-neutral-600 transition-colors">
                                        {copied ? <CheckCircle size={18} className="text-green-400" /> : <Copy size={18} className="text-neutral-400" />}
                                    </div>
                                </div>
                                <p className="text-center text-xs text-neutral-500 mt-3">
                                    {stats.loading ? 'Generating code...' : 'Tap to copy code'}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Stats Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {/* Total Invites */}
                    <div className="bg-neutral-900 border border-neutral-800 rounded-xl p-6 flex items-center gap-4">
                        <div className="w-12 h-12 rounded-full bg-blue-500/20 flex items-center justify-center">
                            <Users size={24} className="text-blue-400" />
                        </div>
                        <div>
                            <p className="text-sm text-neutral-500">Total Invites</p>
                            {stats.loading ? (
                                <div className="h-8 w-16 animate-pulse bg-neutral-800 rounded mt-1"></div>
                            ) : (
                                <h3 className="text-2xl font-bold text-white">{stats.total_invites}</h3>
                            )}
                        </div>
                    </div>

                    {/* Earnings */}
                    <div className="bg-neutral-900 border border-neutral-800 rounded-xl p-6 flex items-center gap-4">
                        <div className="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center">
                            <DollarSign size={24} className="text-green-400" />
                        </div>
                        <div>
                            <p className="text-sm text-neutral-500">Total Earnings</p>
                            {stats.loading ? (
                                <div className="h-8 w-16 animate-pulse bg-neutral-800 rounded mt-1"></div>
                            ) : (
                                <h3 className="text-2xl font-bold text-white">${stats.earnings}</h3>
                            )}
                        </div>
                    </div>
                </div>

                {/* How it works */}
                <div>
                    <h3 className="text-lg font-bold text-white mb-4">How it works</h3>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div className="relative pl-8 border-l border-neutral-800">
                            <div className="absolute -left-[5px] top-0 w-2.5 h-2.5 rounded-full bg-cyan-500" />
                            <h4 className="text-white font-medium mb-2">1. Share your code</h4>
                            <p className="text-sm text-neutral-400">Send your unique referral link to friends or share it on social media.</p>
                        </div>
                        <div className="relative pl-8 border-l border-neutral-800">
                            <div className="absolute -left-[5px] top-0 w-2.5 h-2.5 rounded-full bg-purple-500" />
                            <h4 className="text-white font-medium mb-2">2. They get a discount</h4>
                            <p className="text-sm text-neutral-400">Your friends get {stats.discount_percent}% off their first facial analysis when they use your code.</p>
                        </div>
                        <div className="relative pl-8 border-l border-neutral-800">
                            <div className="absolute -left-[5px] top-0 w-2.5 h-2.5 rounded-full bg-green-500" />
                            <h4 className="text-white font-medium mb-2">3. You earn cash</h4>
                            <p className="text-sm text-neutral-400">For every friend that purchases a plan, you receive $10 directly.</p>
                        </div>
                    </div>
                </div>

            </div>
        </TabContent>
    );
}
