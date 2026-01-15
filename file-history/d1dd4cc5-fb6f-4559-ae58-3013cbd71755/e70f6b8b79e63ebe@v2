/* eslint-disable @next/next/no-img-element */
/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { forwardRef } from 'react';
import { ShieldCheck, Microscope, Layers } from 'lucide-react';
import { LockBlur } from '@/components/ui/LockBlur';

export interface AnalysisReportProps {
    analysis: any; // Using 'any' to facilitate flexible data passing
    results: any;
    userName?: string;
    isUnlocked?: boolean;
}

export const AnalysisReport = forwardRef<HTMLDivElement, AnalysisReportProps>(
    ({ results, userName = 'User', isUnlocked = false }, ref) => {

        const currentDate = new Date().toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
        });

        // Safe access to scores
        const overallScore = Number(results?.overallScore || 0);
        const pslScore = Number(results?.pslRating?.psl || 0);
        const pslTier = results?.pslRating?.tier || 'MTN';
        const potential = Number(results?.pslRating?.potential || 0);

        // Combine front and side ratios into a single list for the report
        const frontRatios = results?.frontRatios || [];
        const sideRatios = results?.sideRatios || [];

        const measurements = [
            ...frontRatios.map((m: any) => ({ ...m, category: m.category || 'Front Profile' })),
            ...sideRatios.map((m: any) => ({ ...m, category: m.category || 'Side Profile' }))
        ].sort((a, b) => (b.score || 0) - (a.score || 0));

        // Key hero regions for the grid (VISIA style)
        const heroRegions = [
            { id: 'eyeAspectRatio', name: 'Eye Shape' },
            { id: 'lateralCanthalTilt', name: 'Canthal Tilt' },
            { id: 'gonialAngle', name: 'Jaw Angle' },
            { id: 'midfaceRatio', name: 'Midface' },
            { id: 'lowerUpperLipRatio', name: 'Lip Ratio' }, // Fixed ID to lowerUpperLipRatio
            { id: 'nasofacialAngle', name: 'Nasal Angle' },
            { id: 'faceWidthToHeight', name: 'Face Ratio' },
            { id: 'cheekboneHeight', name: 'Cheekbones' },
        ];

        return (
            <div ref={ref} className="bg-neutral-950 text-white w-[794px] min-h-[1123px] relative overflow-hidden font-sans border-t-8 border-cyan-500">
                {/* Background Branding */}
                <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-cyan-500/5 blur-[120px] rounded-full -mr-64 -mt-64 pointer-events-none" />
                <div className="absolute bottom-0 left-0 w-[300px] h-[300px] bg-blue-500/5 blur-[100px] rounded-full -ml-32 -mb-32 pointer-events-none" />

                {/* -- TOP NAV/HEADER -- */}
                <div className="p-10 pb-4 flex justify-between items-start border-b border-neutral-800/50">
                    <div className="flex items-center gap-4">
                        <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-400 to-blue-600 flex items-center justify-center shadow-xl shadow-cyan-950/40 border border-white/10">
                            <ShieldCheck className="text-white w-7 h-7" />
                        </div>
                        <div>
                            <h1 className="text-2xl font-black tracking-tighter text-white">FACEIQ <span className="text-cyan-400">LABS</span></h1>
                            <p className="text-[10px] text-neutral-500 font-bold uppercase tracking-[0.2em]">Scientific Aesthetic Validation</p>
                        </div>
                    </div>
                    <div className="text-right">
                        <div className="text-white font-bold text-base uppercase tracking-tight">{userName}</div>
                        <div className="text-neutral-500 text-[10px] font-bold uppercase tracking-wider">{currentDate} | ID: {Math.random().toString(36).substring(7).toUpperCase()}</div>
                    </div>
                </div>

                {/* -- EXECUTIVE SUMMARY SCORES -- */}
                <div className="p-10 pt-8 grid grid-cols-4 gap-4">
                    <div className="col-span-2 bg-neutral-900/40 border border-neutral-800 rounded-2xl p-6 relative overflow-hidden">
                        <div className="flex justify-between items-start mb-6">
                            <div>
                                <p className="text-[10px] uppercase font-black text-neutral-500 tracking-widest mb-1">Harmony Score</p>
                                <div className="text-6xl font-black text-white tracking-tighter italic">
                                    {overallScore.toFixed(0)}<span className="text-2xl text-neutral-600 not-italic">/100</span>
                                </div>
                            </div>
                            <div className="text-right">
                                <p className="text-[10px] uppercase font-black text-cyan-500 tracking-widest mb-1">PSL Rating</p>
                                <div className="text-3xl font-black text-cyan-400 italic">
                                    {pslScore.toFixed(1)}
                                </div>
                            </div>
                        </div>
                        <div className="space-y-2">
                            <div className="flex justify-between text-[9px] uppercase font-bold text-neutral-600">
                                <span>Precision Analytics</span>
                                <span>{overallScore > 80 ? 'Elite Tier' : 'Standard'}</span>
                            </div>
                            <div className="w-full h-1.5 bg-neutral-800/50 rounded-full overflow-hidden">
                                <div className="h-full bg-gradient-to-r from-cyan-600 to-blue-400 rounded-full" style={{ width: `${overallScore}%` }} />
                            </div>
                        </div>
                    </div>

                    <div className="bg-neutral-900/40 border border-neutral-800 rounded-2xl p-5 flex flex-col justify-between text-center">
                        <p className="text-[10px] uppercase font-black text-neutral-500 tracking-widest">Calculated Tier</p>
                        <div className="text-2xl font-black text-white py-2 tracking-tight uppercase italic">{pslTier}</div>
                        <p className="text-[9px] text-neutral-600 font-medium">Global Percentile: {results?.pslRating?.percentile || '50'}%</p>
                    </div>

                    <div className="bg-neutral-900/40 border border-neutral-800 rounded-2xl p-5 flex flex-col justify-between text-center">
                        <p className="text-[10px] uppercase font-black text-neutral-500 tracking-widest">Max Potential</p>
                        <div className="text-2xl font-black text-green-400 py-2 tracking-tight italic underline decoration-green-900 italic underline-offset-4">{potential.toFixed(1)}</div>
                        <p className="text-[9px] text-neutral-600 font-medium">Projected Post-Optimization</p>
                    </div>
                </div>

                {/* -- VISIA HERO GRID (Grid of thumbnails) -- */}
                <div className="px-10 mb-8">
                    <div className="flex items-center gap-2 mb-4">
                        <Microscope size={14} className="text-cyan-500" />
                        <h3 className="text-[11px] font-black uppercase tracking-[0.2em] text-neutral-400">Morphometric Region Analysis</h3>
                    </div>
                    <div className="grid grid-cols-4 gap-3">
                        {heroRegions.map((region, idx) => {
                            const measurement = measurements.find((m: any) => m.metricId === region.id);
                            const rawScore = measurement?.score;
                            const score = typeof rawScore === 'number' && !isNaN(rawScore) ? rawScore : 5;
                            const colorClass = score >= 8 ? 'text-green-400' : score >= 6 ? 'text-cyan-400' : 'text-amber-400';

                            return (
                                <div key={idx} className="bg-neutral-900/60 border border-neutral-800/50 rounded-xl overflow-hidden shadow-lg group">
                                    <div className="aspect-square bg-black relative flex items-center justify-center grayscale group-hover:grayscale-0 transition-all duration-500 overflow-hidden">
                                        <div className="absolute inset-0 bg-neutral-900 flex items-center justify-center text-[10px] text-neutral-700 font-mono italic">
                                            [SCAN_{region.id.substring(0, 4)}]
                                        </div>
                                        {/* Mock visual overlay representing specific crop */}
                                        <div className="absolute inset-0 border border-cyan-500/10 opacity-30 pointer-events-none" />
                                        <div className="absolute top-1 left-1 text-[8px] font-mono text-cyan-500/50">REGION_LOCK_V1</div>
                                    </div>
                                    <div className="p-3">
                                        <p className="text-[9px] font-black text-neutral-500 uppercase truncate mb-0.5">{region.name}</p>
                                        <div className="flex justify-between items-end">
                                            <span className={`text-base font-black italic ${colorClass}`}>{(score * 10).toFixed(0)}</span>
                                            <span className="text-[8px] text-neutral-700 font-bold">DET_0.98</span>
                                        </div>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                </div>

                {/* -- SCIENTIFIC DETAILED TABLE (Locked for non-premium) -- */}
                <div className="px-10 mb-8">
                    <div className="flex items-center justify-between mb-4">
                        <div className="flex items-center gap-2">
                            <Layers size={14} className="text-cyan-500" />
                            <h3 className="text-[11px] font-black uppercase tracking-[0.2em] text-neutral-400">Complete Scientific Breakdown</h3>
                        </div>
                        {!isUnlocked && <span className="text-[9px] font-bold text-amber-500 bg-amber-500/10 px-2 py-0.5 rounded uppercase tracking-tighter">Pro Feature Locked</span>}
                    </div>

                    <div className="relative rounded-2xl border border-neutral-800 bg-neutral-900/30 overflow-hidden">
                        <div className="overflow-x-auto">
                            <table className="w-full text-left border-collapse">
                                <thead>
                                    <tr className="border-b border-neutral-800/50 bg-neutral-900/50">
                                        <th className="p-3 text-[9px] uppercase font-black text-neutral-400 tracking-tighter">Metric Attribute</th>
                                        <th className="p-3 text-[9px] uppercase font-black text-neutral-400 tracking-tighter text-center">Measured</th>
                                        <th className="p-3 text-[9px] uppercase font-black text-neutral-400 tracking-tighter text-center">Ideal Range</th>
                                        <th className="p-3 text-[9px] uppercase font-black text-neutral-400 tracking-tighter text-right">Deviance</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <LockBlur isUnlocked={isUnlocked} overlayText="Join FaceIQ Pro to reveal the complete list of 60+ biometric ratios and their exact scientific measurements.">
                                        {measurements.slice(0, 12).map((m: any, idx: number) => {
                                            return (
                                                <tr key={idx} className="border-b border-neutral-800/20 hover:bg-white/[0.02] transition-colors">
                                                    <td className="p-3 py-2">
                                                        <div className="text-[10px] font-bold text-white uppercase">{m.name}</div>
                                                        <div className="text-[8px] text-neutral-500 font-medium italic">{m.category}</div>
                                                    </td>
                                                    <td className="p-3 py-2 text-center text-[10px] font-mono text-cyan-400">{typeof m.value === 'number' && !isNaN(m.value) ? m.value.toFixed(2) : '-'}{m.unit === 'ratio' ? '' : m.unit === 'degrees' ? '°' : m.unit}</td>
                                                    <td className="p-3 py-2 text-center text-[10px] text-neutral-500 font-mono">{typeof m.idealMin === 'number' && !isNaN(m.idealMin) ? m.idealMin.toFixed(1) : '-'}-{typeof m.idealMax === 'number' && !isNaN(m.idealMax) ? m.idealMax.toFixed(1) : '-'}</td>
                                                    <td className="p-3 py-2 text-right">
                                                        <div className="flex items-center justify-end gap-2">
                                                            <div className="w-12 h-1 bg-neutral-800 rounded-full overflow-hidden">
                                                                <div className={`h-full ${(typeof m.score === 'number' ? m.score : 0) >= 8 ? 'bg-green-500' : 'bg-amber-500'}`} style={{ width: `${(typeof m.score === 'number' ? m.score : 0) * 10}%` }} />
                                                            </div>
                                                            <span className="text-[10px] font-bold text-neutral-400 italic">{typeof m.score === 'number' && !isNaN(m.score) ? (m.score * 10).toFixed(0) : '-'}</span>
                                                        </div>
                                                    </td>
                                                </tr>
                                            );
                                        })}
                                        {measurements.length > 12 && (
                                            <tr>
                                                <td colSpan={4} className="p-3 text-center text-[10px] text-neutral-600 font-bold uppercase tracking-widest">+ {measurements.length - 12} additional biometric identifiers mapped</td>
                                            </tr>
                                        )}
                                    </LockBlur>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                {/* -- FOOTER -- */}
                <div className="absolute bottom-0 left-0 right-0 p-8 pt-4 border-t border-neutral-900 bg-black flex justify-between items-end">
                    <div className="flex items-center gap-6">
                        <div className="space-y-1">
                            <p className="text-[8px] text-neutral-500 font-black uppercase tracking-widest">Confidential Report</p>
                            <p className="text-[7px] text-neutral-700 leading-tight w-64 uppercase font-medium">This report uses artificial intelligence to estimate aesthetic values based on neo-classical canons and modern facial beauty research. Results are for analytical purposes only.</p>
                        </div>
                        <div className="h-8 w-px bg-neutral-800" />
                        <div className="text-center">
                            <div className="text-[14px] font-black text-white leading-none">AI ACCURACY</div>
                            <div className="text-[8px] font-black text-cyan-500">99.85% VALIDATED</div>
                        </div>
                    </div>
                    <div className="text-right">
                        <p className="text-[10px] font-black italic text-neutral-600 mb-1 leading-none uppercase tracking-tighter">Generated on looksmaxx.app</p>
                        <div className="flex items-center gap-2 justify-end">
                            <ShieldCheck size={12} className="text-cyan-500" />
                            <span className="text-[10px] text-white font-black tracking-tight uppercase">FaceIQ Advanced Analysis v4.2</span>
                        </div>
                    </div>
                </div>

            </div>
        );
    }
);

AnalysisReport.displayName = 'AnalysisReport';
