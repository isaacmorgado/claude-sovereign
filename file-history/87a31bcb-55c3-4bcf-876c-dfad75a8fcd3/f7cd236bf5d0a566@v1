'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { ShoppingCart } from 'lucide-react';

interface StickyMobileCTAProps {
    price: number;
    originalPrice: number;
    itemCount: number;
    onAddToCart: () => void;
    isVisible: boolean;
}

export function StickyMobileCTA({ price, originalPrice, itemCount, onAddToCart, isVisible }: StickyMobileCTAProps) {
    // Only show on mobile breakpoints usually, handled by parent CSS or media queries in JS
    // For now, we'll let parent control visibility logic (e.g. scroll past hero)

    if (!isVisible) return null;

    return (
        <AnimatePresence>
            <motion.div
                className="fixed bottom-6 left-4 right-4 z-50 md:hidden"
                initial={{ y: 100, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                exit={{ y: 100, opacity: 0 }}
                transition={{ type: "spring", stiffness: 300, damping: 30 }}
            >
                <div className="bg-neutral-900/95 backdrop-blur-xl border border-white/10 rounded-2xl p-4 shadow-2xl shadow-black/50 ring-1 ring-white/5">
                    <div className="flex items-center justify-between gap-4">
                        <div>
                            <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-400 mb-0.5">
                                Total ({itemCount} items)
                            </p>
                            <div className="flex items-baseline gap-2">
                                <span className="text-xl font-black text-white">${price}</span>
                                <span className="text-xs text-neutral-500 line-through">${originalPrice}</span>
                            </div>
                        </div>

                        <button
                            onClick={onAddToCart}
                            className="flex-1 py-3 bg-white text-black rounded-lg font-black uppercase tracking-wider text-xs flex items-center justify-center gap-2 shadow-lg hover:bg-neutral-200 transition-colors"
                        >
                            <ShoppingCart size={14} />
                            Get It Now
                        </button>
                    </div>
                </div>
            </motion.div>
        </AnimatePresence>
    );
}
