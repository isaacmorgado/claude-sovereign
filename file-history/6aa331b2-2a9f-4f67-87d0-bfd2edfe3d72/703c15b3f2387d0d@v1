'use client';

import { useEffect, useRef, useCallback, useState } from 'react';

/**
 * HeroBackground.tsx
 * Extracted from faceiqlabs.com HAR file (animation.js)
 *
 * This component implements the mouse-following parallax effect
 * from the original FaceIQ Labs homepage.
 *
 * Original Logic:
 * - Tracks pointer position within the hero container
 * - Normalizes coordinates to -1 to 1 range
 * - Applies linear interpolation (lerp) for smooth transitions
 * - Applies transforms to background elements
 */

interface PointerPosition {
  x: number;
  y: number;
}

interface HeroBackgroundProps {
  children?: React.ReactNode;
  className?: string;
}

// Linear interpolation helper - exact logic from original
const lerp = (current: number, target: number, factor: number): number => {
  return current + (target - current) * factor;
};

export default function HeroBackground({ children, className = '' }: HeroBackgroundProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const backgroundRef = useRef<HTMLDivElement>(null);
  const animationRef = useRef<number | null>(null);

  // Pointer position state - matches original variable names
  const pointerTarget = useRef<PointerPosition>({ x: 0, y: 0 });
  const pointer = useRef<PointerPosition>({ x: 0, y: 0 });

  // Track if animation should run
  const [isVisible, setIsVisible] = useState(true);
  const [isSectionVisible, setIsSectionVisible] = useState(true);

  /**
   * Pointer move handler
   * Exact logic from original initPointerHandlers():
   *
   * const nx = ((e.clientX - rect.left) / rect.width) * 2 - 1;
   * const ny = ((e.clientY - rect.top) / rect.height) * 2 - 1;
   * pointerTarget.x = Math.max(-1, Math.min(1, nx));
   * pointerTarget.y = Math.max(-1, Math.min(1, ny));
   */
  const handlePointerMove = useCallback((e: PointerEvent) => {
    const container = containerRef.current;
    if (!container) return;

    const rect = container.getBoundingClientRect();

    // Normalize to -1 to 1 range (original math)
    const nx = ((e.clientX - rect.left) / rect.width) * 2 - 1;
    const ny = ((e.clientY - rect.top) / rect.height) * 2 - 1;

    // Clamp values (original logic)
    pointerTarget.current.x = Math.max(-1, Math.min(1, nx));
    pointerTarget.current.y = Math.max(-1, Math.min(1, ny));
  }, []);

  /**
   * Pointer leave handler
   * Resets target to center when mouse leaves
   */
  const handlePointerLeave = useCallback(() => {
    pointerTarget.current.x = 0;
    pointerTarget.current.y = 0;
  }, []);

  /**
   * Animation loop
   * Exact lerp factor from original: 0.08
   *
   * Original logic:
   * pointer.x += (pointerTarget.x - pointer.x) * 0.08;
   * pointer.y += (pointerTarget.y - pointer.y) * 0.08;
   */
  const animate = useCallback(() => {
    if (!isVisible || !isSectionVisible) {
      animationRef.current = requestAnimationFrame(animate);
      return;
    }

    // Apply lerp smoothing (exact factor from original: 0.08)
    pointer.current.x = lerp(pointer.current.x, pointerTarget.current.x, 0.08);
    pointer.current.y = lerp(pointer.current.y, pointerTarget.current.y, 0.08);

    // Cursor movement animation removed - background stays static

    animationRef.current = requestAnimationFrame(animate);
  }, [isVisible, isSectionVisible]);

  // Set up event listeners and animation loop
  useEffect(() => {
    // Visibility change handler (from original)
    const handleVisibilityChange = () => {
      setIsVisible(!document.hidden);
    };

    // Intersection observer for section visibility (from original initSectionObserver)
    const sectionObserver = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          setIsSectionVisible(entry.isIntersecting);
        }
      },
      { threshold: 0.1 }
    );

    // Add event listeners
    window.addEventListener('pointermove', handlePointerMove);
    window.addEventListener('pointerleave', handlePointerLeave);
    document.addEventListener('visibilitychange', handleVisibilityChange);

    // Observe this section
    if (containerRef.current) {
      sectionObserver.observe(containerRef.current);
    }

    // Start animation loop
    animationRef.current = requestAnimationFrame(animate);

    // Cleanup
    return () => {
      window.removeEventListener('pointermove', handlePointerMove);
      window.removeEventListener('pointerleave', handlePointerLeave);
      document.removeEventListener('visibilitychange', handleVisibilityChange);
      sectionObserver.disconnect();

      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, [handlePointerMove, handlePointerLeave, animate]);

  return (
    <div
      ref={containerRef}
      className={`hero-background-container relative overflow-hidden ${className}`}
      style={{ minHeight: 'max(100vh, 720px)' }}
    >
      {/* Animated background layer */}
      <div
        ref={backgroundRef}
        className="hero-background-layer absolute inset-0 will-change-transform"
        style={{
          transformStyle: 'preserve-3d',
          backfaceVisibility: 'hidden',
        }}
      >
        {/* Vignette overlay - exact gradients from original CSS */}
        <div
          className="vignette-overlay absolute inset-0 pointer-events-none z-[2]"
          style={{
            opacity: 0.8,
            background: `
              linear-gradient(to right, rgba(0, 0, 0, 0.65) 0%, rgba(0, 0, 0, 0.5) 20%, rgba(0, 0, 0, 0.35) 35%, transparent 55%),
              linear-gradient(to top, #000000 0%, transparent 40%),
              linear-gradient(to bottom, rgba(0, 0, 0, 0.2) 0%, transparent 30%),
              radial-gradient(ellipse at 55% 50%, transparent 35%, rgba(0, 0, 0, 0.18) 60%, rgba(0, 0, 0, 0.35) 82%, rgba(0, 0, 0, 0.5) 100%)
            `,
          }}
        />
      </div>

      {/* Content layer */}
      <div className="relative z-10">{children}</div>
    </div>
  );
}

/**
 * RotatingText component
 * Implements the word rotation animation from the original site
 *
 * Original logic from animation.js:
 * const rotatingWords = ['proportions', 'symmetry', 'harmony', 'ratios', 'measurements', 'balance'];
 *
 * if (t - lastWordChange > 2.5) {
 *     currentWordIndex = (currentWordIndex + 1) % rotatingWords.length;
 *     const textEl = document.getElementById('rotatingText');
 *     if (textEl) {
 *         textEl.style.opacity = '0';
 *         textEl.style.transform = 'translateY(10px)';
 *         setTimeout(() => {
 *             textEl.textContent = rotatingWords[currentWordIndex];
 *             textEl.style.opacity = '1';
 *             textEl.style.transform = 'translateY(0)';
 *         }, 300);
 *     }
 *     lastWordChange = t;
 * }
 */
interface RotatingTextProps {
  words?: string[];
  interval?: number; // in milliseconds
  className?: string;
}

export function RotatingText({
  words = ['proportions', 'symmetry', 'harmony', 'ratios', 'measurements', 'balance'],
  interval = 2500, // 2.5 seconds from original
  className = '',
}: RotatingTextProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isAnimating, setIsAnimating] = useState(false);

  useEffect(() => {
    const timer = setInterval(() => {
      setIsAnimating(true);

      // After fade out (300ms), change word and fade in
      setTimeout(() => {
        setCurrentIndex((prev) => (prev + 1) % words.length);
        setIsAnimating(false);
      }, 300);
    }, interval);

    return () => clearInterval(timer);
  }, [words.length, interval]);

  return (
    <span
      className={`inline-block text-blue-400 ${className}`}
      style={{
        minWidth: '280px',
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        opacity: isAnimating ? 0 : 1,
        transform: isAnimating ? 'translateY(10px)' : 'translateY(0)',
      }}
    >
      {words[currentIndex]}
    </span>
  );
}
