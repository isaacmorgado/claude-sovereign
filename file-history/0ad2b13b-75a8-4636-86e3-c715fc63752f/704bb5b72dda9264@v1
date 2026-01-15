'use client';

import CountUp from 'react-countup';
import confetti from 'canvas-confetti';
import { useEffect, useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { getScoreColor } from '@/types/results';

interface AnimatedScoreProps {
  score: number;
  duration?: number;
  delay?: number;
  showConfetti?: boolean;
  confettiThreshold?: number;
  size?: 'md' | 'lg' | 'xl';
  suffix?: string;
  onComplete?: () => void;
}

export function AnimatedScore({
  score,
  duration = 2,
  delay = 0.3,
  showConfetti = true,
  confettiThreshold = 7.5,
  size = 'xl',
  suffix = '/10',
  onComplete,
}: AnimatedScoreProps) {
  const color = getScoreColor(score);
  const hasTriggeredConfetti = useRef(false);
  const [isComplete, setIsComplete] = useState(false);

  const sizeClasses = {
    md: 'text-3xl',
    lg: 'text-5xl',
    xl: 'text-6xl md:text-7xl',
  };

  useEffect(() => {
    // Trigger confetti for high scores after animation
    if (showConfetti && score >= confettiThreshold && !hasTriggeredConfetti.current && isComplete) {
      hasTriggeredConfetti.current = true;

      // Launch confetti from both sides
      const duration = 2000;
      const end = Date.now() + duration;

      const colors = ['#00f3ff', '#a78bfa', '#22c55e', '#fbbf24'];

      (function frame() {
        confetti({
          particleCount: 3,
          angle: 60,
          spread: 55,
          origin: { x: 0, y: 0.7 },
          colors,
        });
        confetti({
          particleCount: 3,
          angle: 120,
          spread: 55,
          origin: { x: 1, y: 0.7 },
          colors,
        });

        if (Date.now() < end) {
          requestAnimationFrame(frame);
        }
      })();
    }
  }, [score, confettiThreshold, showConfetti, isComplete]);

  const handleComplete = () => {
    setIsComplete(true);
    onComplete?.();
  };

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.5 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{
        duration: 0.5,
        delay,
        type: 'spring',
        stiffness: 200,
        damping: 15,
      }}
      className="relative"
    >
      <span
        className={`font-bold ${sizeClasses[size]} tabular-nums`}
        style={{ color }}
      >
        <CountUp
          end={score}
          decimals={1}
          duration={duration}
          delay={delay}
          onEnd={handleComplete}
          preserveValue
        />
        <span className="text-neutral-500 text-xl md:text-2xl ml-1">{suffix}</span>
      </span>

      {/* Glow effect for high scores */}
      {score >= 8 && (
        <motion.div
          className="absolute inset-0 rounded-full blur-xl opacity-30 pointer-events-none"
          style={{ backgroundColor: color }}
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1.2, opacity: 0.3 }}
          transition={{ duration: 1, delay: delay + duration }}
        />
      )}
    </motion.div>
  );
}
