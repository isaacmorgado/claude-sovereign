'use client';

import { useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  BookOpen,
  Dumbbell,
  Sparkles,
  Clock,
  ChevronRight,
  Search,
  Brain,
  Wrench,
  TrendingDown,
  Calendar,
  Target,
  Heart,
  Utensils,
  Droplet,
  X,
  ArrowLeft,
  MessageSquare,
  ExternalLink,
  ShoppingCart,
  CheckCircle2,
} from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { TabContent } from '../ResultsLayout';
import {
  GUIDE_CATEGORIES,
  getGuidesByCategory,
  getTotalGuideCount,
  getTotalReadTime,
  getGuideProductById,
  getGuidesByGender,
} from '@/data/guides';
import { Guide, GuideCategory, GuideMedia } from '@/types/guides';
import { useRegion } from '@/contexts/RegionContext';
import { useResults } from '@/contexts/ResultsContext';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';

// ============================================
// ICON MAPPING
// ============================================

const ICON_MAP: Record<string, React.ReactNode> = {
  BookOpen: <BookOpen size={20} />,
  Dumbbell: <Dumbbell size={20} />,
  Sparkles: <Sparkles size={20} />,
  Brain: <Brain size={20} />,
  Wrench: <Wrench size={20} />,
  TrendingDown: <TrendingDown size={20} />,
  Calendar: <Calendar size={20} />,
  Target: <Target size={20} />,
  Heart: <Heart size={20} />,
  Utensils: <Utensils size={20} />,
  Droplet: <Droplet size={20} />,
};

function getIconComponent(iconName: string, size = 20): React.ReactNode {
  // Check icon map first
  const mappedIcon = ICON_MAP[iconName];
  if (mappedIcon) return mappedIcon;

  // Fallback to BookOpen
  return <BookOpen size={size} />;
}

// ============================================
// MEDIA RENDERER
// ============================================

interface MediaRendererProps {
  media: GuideMedia;
}

function MediaRenderer({ media }: MediaRendererProps) {
  const [hasError, setHasError] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const handleError = useCallback(() => {
    setHasError(true);
    setIsLoading(false);
  }, []);

  const handleLoad = useCallback(() => {
    setIsLoading(false);
  }, []);

  const placementClasses = {
    inline: 'max-w-lg mx-auto',
    hero: 'w-full',
    'full-width': 'w-full',
  };

  const isGif = media.type === 'gif' || media.url.endsWith('.gif');

  // Show styled placeholder if image failed to load or doesn't exist
  if (hasError) {
    return (
      <figure className={`my-10 ${placementClasses[media.placement || 'inline']}`}>
        <div className="relative rounded-2xl overflow-hidden bg-neutral-900/40 border border-white/5">
          <div className="aspect-video flex items-center justify-center p-8">
            <div className="text-center max-w-sm">
              <div className="w-16 h-16 bg-cyan-500/10 rounded-2xl flex items-center justify-center mx-auto mb-4 border border-cyan-500/20">
                {isGif ? (
                  <div className="w-6 h-6 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" />
                ) : (
                  <Sparkles size={28} className="text-cyan-400" />
                )}
              </div>
              <p className="text-neutral-300 font-black uppercase tracking-wider text-sm mb-2">{media.alt}</p>
              {media.caption && (
                <p className="text-neutral-600 text-xs">{media.caption}</p>
              )}
            </div>
          </div>
        </div>
      </figure>
    );
  }

  return (
    <figure className={`my-10 ${placementClasses[media.placement || 'inline']}`}>
      <div className="relative rounded-2xl overflow-hidden bg-neutral-900/40 border border-white/5">
        {/* Loading skeleton */}
        {isLoading && (
          <div className="absolute inset-0 bg-neutral-900/40 animate-pulse flex items-center justify-center">
            <div className="w-8 h-8 border-2 border-cyan-500 border-t-transparent rounded-full animate-spin" />
          </div>
        )}

        {isGif ? (
          // Use img for GIFs to preserve animation
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={media.url}
            alt={media.alt}
            className={`w-full h-auto max-h-[400px] object-contain transition-opacity duration-300 ${isLoading ? 'opacity-0' : 'opacity-100'}`}
            loading="lazy"
            onError={handleError}
            onLoad={handleLoad}
          />
        ) : (
          <Image
            src={media.url}
            alt={media.alt}
            width={media.width || 800}
            height={media.height || 450}
            className={`w-full h-auto max-h-[400px] object-contain transition-opacity duration-300 ${isLoading ? 'opacity-0' : 'opacity-100'}`}
            onError={handleError}
            onLoad={handleLoad}
          />
        )}
      </div>
      {media.caption && (
        <figcaption className="mt-4 text-center text-[10px] font-black uppercase tracking-widest text-neutral-600">
          {media.caption}
        </figcaption>
      )}
    </figure>
  );
}

// ============================================
// PRODUCT CALLOUT (CONVERSION OPTIMIZED)
// ============================================

interface ProductCalloutProps {
  productId: string;
}

function ProductCallout({ productId }: ProductCalloutProps) {
  const { getLink } = useRegion();
  const product = getGuideProductById(productId);
  const [hasError, setHasError] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  if (!product) return null;

  const link = getLink(product.regionLinks, product.directLink);

  return (
    <div className="my-6 p-5 rounded-2xl bg-neutral-900/40 border border-white/5 hover:border-cyan-500/20 transition-all">
      <div className="flex items-center gap-4">
        {/* Product Image */}
        <div className="w-16 h-16 rounded-xl bg-neutral-900 border border-white/10 overflow-hidden flex-shrink-0 relative">
          {isLoading && !hasError && product.imageUrl && (
            <div className="absolute inset-0 bg-neutral-900/60 animate-pulse flex items-center justify-center z-10">
              <div className="w-4 h-4 border-2 border-cyan-500 border-t-transparent rounded-full animate-spin" />
            </div>
          )}
          {hasError || !product.imageUrl ? (
            <div className="w-full h-full flex items-center justify-center bg-neutral-900">
              <ShoppingCart size={20} className="text-neutral-600" />
            </div>
          ) : (
            <Image
              src={product.imageUrl}
              alt={product.name}
              width={64}
              height={64}
              className={`w-full h-full object-cover transition-opacity ${isLoading ? 'opacity-0' : 'opacity-100'}`}
              onLoad={() => setIsLoading(false)}
              onError={() => { setHasError(true); setIsLoading(false); }}
              unoptimized
            />
          )}
        </div>

        {/* Product Info */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <h4 className="font-black uppercase tracking-wide text-white truncate">{product.name}</h4>
            {product.brand && (
              <span className="text-[10px] font-black uppercase tracking-widest text-neutral-600">{product.brand}</span>
            )}
          </div>
          <p className="text-sm text-cyan-400 italic">&ldquo;{product.tagline}&rdquo;</p>
        </div>

        {/* CTA Button */}
        <a
          href={link}
          target="_blank"
          rel="noopener noreferrer"
          className="flex-shrink-0 flex items-center gap-2 px-5 py-2.5 rounded-xl bg-cyan-500 hover:bg-cyan-400 text-black font-black uppercase tracking-wider text-xs transition-colors"
        >
          <ShoppingCart size={14} />
          <span className="hidden sm:inline">BUY</span>
        </a>
      </div>
    </div>
  );
}

// ============================================
// FORUM DISCUSSION LINK
// ============================================

interface ForumDiscussionLinkProps {
  forumCategory?: string;
  guideTitle: string;
}

function ForumDiscussionLink({ forumCategory, guideTitle }: ForumDiscussionLinkProps) {
  if (!forumCategory) return null;

  return (
    <div className="mt-8 p-6 rounded-2xl bg-neutral-900/40 border border-white/5">
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 rounded-xl bg-purple-500/10 border border-purple-500/20 flex items-center justify-center">
          <MessageSquare size={20} className="text-purple-400" />
        </div>
        <div>
          <h3 className="font-black uppercase tracking-wide text-white">DISCUSS THIS GUIDE</h3>
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">Join the community conversation</p>
        </div>
      </div>

      <p className="text-sm text-neutral-400 mb-5">
        Have questions about {guideTitle.toLowerCase()}? Want to share your experience?
        Join the discussion in our community forum.
      </p>

      <Link
        href={`/forum/${forumCategory}`}
        className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-neutral-900/50 border border-white/5 hover:border-purple-500/30 text-purple-400 font-black uppercase tracking-wider text-xs transition-all"
      >
        <MessageSquare size={14} />
        GO TO FORUM
        <ExternalLink size={12} />
      </Link>
    </div>
  );
}

// ============================================
// GUIDE STATS CARD
// ============================================

function GuideStatsCard() {
  const totalGuides = getTotalGuideCount();
  const totalMinutes = getTotalReadTime();

  return (
    <motion.div
      className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-6 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="flex items-center gap-4 mb-6">
        <div className="w-12 h-12 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
          <BookOpen size={22} className="text-cyan-400" />
        </div>
        <div>
          <h2 className="text-xl font-black italic uppercase tracking-tight text-white">PRODUCT <span className="text-cyan-400">GUIDES</span></h2>
          <p className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-600">EVIDENCE-BASED LOOKSMAXXING RESOURCES</p>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4">
          <div className="text-3xl font-black text-white mb-1">{totalGuides}</div>
          <div className="text-[10px] font-black uppercase tracking-widest text-neutral-600">TOTAL GUIDES</div>
        </div>
        <div className="rounded-xl bg-neutral-900/50 border border-white/5 p-4">
          <div className="flex items-center gap-2 mb-1">
            <Clock size={18} className="text-cyan-400" />
            <div className="text-3xl font-black text-white">{totalMinutes}</div>
          </div>
          <div className="text-[10px] font-black uppercase tracking-widest text-neutral-600">MINUTES OF CONTENT</div>
        </div>
      </div>
    </motion.div>
  );
}

// ============================================
// GUIDE VIEWER MODAL
// ============================================

interface GuideViewerProps {
  guide: Guide;
  onClose: () => void;
  onSwitchGuide: (guide: Guide) => void;
  allGuides: Guide[];
  gender: 'male' | 'female';
}

function GuideViewer({ guide, onClose, onSwitchGuide, allGuides, gender }: GuideViewerProps) {
  const [currentSection, setCurrentSection] = useState(0);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [expandedCategories, setExpandedCategories] = useState<string[]>(() => {
    // Find the category of the current guide and expand it by default
    const currentCategory = GUIDE_CATEGORIES.find(c => c.guideIds.includes(guide.id));
    return currentCategory ? [currentCategory.id] : [];
  });

  const section = guide.sections[currentSection];

  if (!section) return null;

  // Calculate reading progress (0% at start, 100% at last section)
  const progress = guide.sections.length > 1
    ? (currentSection / (guide.sections.length - 1)) * 100
    : 100;

  const toggleCategory = (categoryId: string) => {
    setExpandedCategories(prev =>
      prev.includes(categoryId)
        ? prev.filter(id => id !== categoryId)
        : [...prev, categoryId]
    );
  };

  // Filter categories by gender
  const filteredCategories = GUIDE_CATEGORIES.filter(cat => {
    if (cat.id === 'male' && gender === 'female') return false;
    if (cat.id === 'female' && gender === 'male') return false;
    return true;
  });

  const colorClasses: Record<string, { text: string; bg: string; border: string }> = {
    blue: { text: 'text-cyan-400', bg: 'bg-cyan-500/10', border: 'border-cyan-500/20' },
    purple: { text: 'text-purple-400', bg: 'bg-purple-500/10', border: 'border-purple-500/20' },
    amber: { text: 'text-amber-400', bg: 'bg-amber-500/10', border: 'border-amber-500/20' },
    pink: { text: 'text-pink-400', bg: 'bg-pink-500/10', border: 'border-pink-500/20' },
    emerald: { text: 'text-emerald-400', bg: 'bg-emerald-500/10', border: 'border-emerald-500/20' },
    red: { text: 'text-red-400', bg: 'bg-red-500/10', border: 'border-red-500/20' },
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 bg-black"
    >
      {/* Header */}
      <div className="sticky top-0 z-20 bg-black/95 backdrop-blur-md border-b border-neutral-900">
        <div className="flex items-center justify-between px-4 lg:px-8 py-3">
          <button
            onClick={onClose}
            className="flex items-center gap-2 text-neutral-500 hover:text-cyan-400 text-xs font-black uppercase tracking-widest transition-colors"
          >
            <ArrowLeft size={14} />
            <span className="hidden sm:inline">BACK TO GUIDES</span>
          </button>

          {/* Progress bar */}
          <div className="hidden md:flex items-center gap-4 flex-1 max-w-md mx-8">
            <div className="flex-1 h-1 bg-neutral-900 rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-gradient-to-r from-cyan-500 to-cyan-400"
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.3 }}
              />
            </div>
            <span className="text-[10px] font-black uppercase tracking-widest text-neutral-600 whitespace-nowrap">
              {currentSection + 1} / {guide.sections.length}
            </span>
          </div>

          <div className="flex items-center gap-3">
            {/* Mobile menu button */}
            <button
              onClick={() => setIsSidebarOpen(!isSidebarOpen)}
              className="lg:hidden p-2 rounded-xl bg-neutral-900/50 border border-white/5 hover:border-white/10 transition-colors"
            >
              <BookOpen size={18} className="text-neutral-400" />
            </button>
            <button
              onClick={onClose}
              className="p-2 rounded-xl bg-neutral-900/50 border border-white/5 hover:border-white/10 transition-colors"
            >
              <X size={18} className="text-neutral-400" />
            </button>
          </div>
        </div>
      </div>

      {/* Main Layout: Sidebar + Content */}
      <div className="flex h-[calc(100vh-57px)]">
        {/* Sidebar Navigation */}
        <aside
          className={`
            fixed lg:relative inset-y-0 left-0 z-30 lg:z-0
            w-72 lg:w-80 bg-black lg:bg-neutral-950/50
            border-r border-neutral-900
            transform transition-transform duration-300 ease-in-out
            ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
            flex flex-col
          `}
        >
          {/* Sidebar Header */}
          <div className="p-4 border-b border-neutral-900">
            <div className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-2">
              ALL GUIDES
            </div>
            <p className="text-xs text-neutral-500">Select a lesson below</p>
          </div>

          {/* Categories & Guides List */}
          <nav className="flex-1 overflow-y-auto p-3">
            {filteredCategories.map(category => {
              const categoryGuides = allGuides.filter(g => category.guideIds.includes(g.id));
              if (categoryGuides.length === 0) return null;

              const isExpanded = expandedCategories.includes(category.id);
              const styles = colorClasses[category.color] || colorClasses.blue;
              const hasCurrentGuide = categoryGuides.some(g => g.id === guide.id);

              return (
                <div key={category.id} className="mb-2">
                  {/* Category Header */}
                  <button
                    onClick={() => toggleCategory(category.id)}
                    className={`
                      w-full text-left px-3 py-3 rounded-xl transition-all
                      flex items-center gap-3 group
                      ${hasCurrentGuide ? `${styles.bg} border ${styles.border}` : 'hover:bg-neutral-900/50 border border-transparent'}
                    `}
                  >
                    <div className={`w-8 h-8 rounded-xl ${styles.bg} border ${styles.border} flex items-center justify-center ${styles.text} flex-shrink-0`}>
                      {getIconComponent(category.icon, 16)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <span className={`text-xs font-black uppercase tracking-wide block ${hasCurrentGuide ? 'text-white' : 'text-neutral-400 group-hover:text-white'}`}>
                        {category.name}
                      </span>
                      <span className="text-[10px] text-neutral-600">
                        {categoryGuides.length} guide{categoryGuides.length !== 1 ? 's' : ''}
                      </span>
                    </div>
                    <ChevronRight
                      size={14}
                      className={`${styles.text} transition-transform ${isExpanded ? 'rotate-90' : ''}`}
                    />
                  </button>

                  {/* Guides List (collapsible) */}
                  <AnimatePresence>
                    {isExpanded && (
                      <motion.ul
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.2 }}
                        className="overflow-hidden ml-4 mt-1 space-y-0.5"
                      >
                        {categoryGuides.map(g => {
                          const isCurrentGuide = g.id === guide.id;
                          return (
                            <li key={g.id}>
                              <button
                                onClick={() => {
                                  if (isCurrentGuide) {
                                    // Already on this guide, just close sidebar on mobile
                                    setIsSidebarOpen(false);
                                  } else {
                                    onSwitchGuide(g);
                                    setIsSidebarOpen(false);
                                  }
                                }}
                                className={`
                                  w-full text-left px-3 py-2 rounded-lg transition-all
                                  flex items-center gap-2 group
                                  ${isCurrentGuide
                                    ? `${styles.bg} border ${styles.border}`
                                    : 'hover:bg-neutral-900/30 border border-transparent'
                                  }
                                `}
                              >
                                <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${isCurrentGuide ? styles.text.replace('text-', 'bg-') : 'bg-neutral-700'}`} />
                                <span className={`text-xs font-medium truncate ${isCurrentGuide ? 'text-white' : 'text-neutral-500 group-hover:text-neutral-300'}`}>
                                  {g.title}
                                </span>
                                {isCurrentGuide && (
                                  <span className="ml-auto text-[8px] font-black uppercase tracking-wider text-neutral-600">
                                    VIEWING
                                  </span>
                                )}
                              </button>
                            </li>
                          );
                        })}
                      </motion.ul>
                    )}
                  </AnimatePresence>
                </div>
              );
            })}
          </nav>

          {/* Current Guide Sections */}
          <div className="border-t border-neutral-900">
            <div className="p-3">
              <div className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-3 px-2 flex items-center gap-2">
                <BookOpen size={10} />
                SECTIONS
              </div>
              <ul className="space-y-0.5 max-h-48 overflow-y-auto">
                {guide.sections.map((s, idx) => (
                  <li key={s.id}>
                    <button
                      onClick={() => {
                        setCurrentSection(idx);
                        setIsSidebarOpen(false);
                      }}
                      className={`
                        w-full text-left px-3 py-2 rounded-lg transition-all
                        flex items-center gap-2 group
                        ${currentSection === idx
                          ? 'bg-cyan-500/10 border border-cyan-500/20'
                          : 'hover:bg-neutral-900/30 border border-transparent'
                        }
                      `}
                    >
                      <span
                        className={`
                          flex-shrink-0 w-5 h-5 rounded text-[9px] font-black
                          flex items-center justify-center transition-colors
                          ${currentSection === idx
                            ? 'bg-cyan-500 text-black'
                            : idx < currentSection
                              ? 'bg-green-500/20 text-green-400'
                              : 'bg-neutral-900 border border-white/10 text-neutral-600'
                          }
                        `}
                      >
                        {idx < currentSection ? <CheckCircle2 size={10} /> : idx + 1}
                      </span>
                      <span className={`text-[10px] font-bold uppercase tracking-wide truncate ${currentSection === idx ? 'text-white' : 'text-neutral-500'}`}>
                        {s.title}
                      </span>
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          </div>

          {/* Sidebar Footer */}
          <div className="p-4 border-t border-neutral-900">
            <div className="flex items-center justify-between text-[10px] font-black uppercase tracking-widest text-neutral-600 mb-2">
              <span>PROGRESS</span>
              <span>{Math.round(progress)}%</span>
            </div>
            <div className="h-1.5 bg-neutral-900 rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-gradient-to-r from-cyan-500 to-green-500"
                animate={{ width: `${progress}%` }}
              />
            </div>
          </div>
        </aside>

        {/* Mobile sidebar overlay */}
        {isSidebarOpen && (
          <div
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-20 lg:hidden"
            onClick={() => setIsSidebarOpen(false)}
          />
        )}

        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto">
          <article className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-10 lg:py-16">
            {/* Hero Media (only on first section) */}
            {guide.heroMedia && currentSection === 0 && (
              <div className="mb-10">
                <MediaRenderer media={guide.heroMedia} />
              </div>
            )}

            {/* Article Header (only on first section) */}
            {currentSection === 0 && (
              <header className="mb-12">
                <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-cyan-500/10 border border-cyan-500/20 text-[10px] font-black uppercase tracking-widest text-cyan-400 mb-6">
                  {getIconComponent(guide.icon, 12)}
                  <span>GUIDE</span>
                </div>

                <h1 className="text-3xl md:text-4xl font-black tracking-tighter italic uppercase text-white mb-4 leading-tight">
                  {guide.title.split(' ').slice(0, -1).join(' ')} <span className="text-cyan-400">{guide.title.split(' ').slice(-1)}</span>
                </h1>

                <p className="text-neutral-400 text-base leading-relaxed">
                  {guide.description}
                </p>
              </header>
            )}

            {/* Section Content */}
            <AnimatePresence mode="wait">
              <motion.section
                key={section.id}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.3 }}
              >
                {/* Section Title - Largest heading in section content */}
                <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-8 flex items-center gap-4">
                  {section.title}
                  <div className="flex-1 h-px bg-neutral-800" />
                </h2>

                {/* Tips Callout */}
                {section.tips && section.tips.length > 0 && (
                  <aside className="mb-10 p-6 rounded-2xl bg-cyan-500/5 border border-cyan-500/10">
                    <h4 className="text-[10px] font-black uppercase tracking-[0.3em] text-cyan-400 mb-4">
                      QUICK TIPS
                    </h4>
                    <ul className="space-y-3">
                      {section.tips.map((tip, i) => (
                        <li key={i} className="flex items-start gap-3 text-neutral-300">
                          <span className="flex-shrink-0 w-5 h-5 bg-cyan-500/20 rounded-lg flex items-center justify-center mt-0.5">
                            <span className="text-cyan-400 text-[10px] font-black">{i + 1}</span>
                          </span>
                          <span className="leading-relaxed text-sm">{tip}</span>
                        </li>
                      ))}
                    </ul>
                  </aside>
                )}

                {/* Warnings Callout */}
                {section.warnings && section.warnings.length > 0 && (
                  <aside className="mb-10 p-6 rounded-2xl bg-amber-500/5 border border-amber-500/10">
                    <h4 className="text-[10px] font-black uppercase tracking-[0.3em] text-amber-400 mb-4">
                      IMPORTANT
                    </h4>
                    <ul className="space-y-3">
                      {section.warnings.map((warning, i) => (
                        <li key={i} className="flex items-start gap-3 text-neutral-300">
                          <span className="text-amber-400 mt-1">*</span>
                          <span className="leading-relaxed text-sm">{warning}</span>
                        </li>
                      ))}
                    </ul>
                  </aside>
                )}

                {/* Hero Media for Section */}
                {section.media && section.media.filter(m => m.placement === 'hero').map(media => (
                  <div key={media.id} className="mb-10">
                    <MediaRenderer media={media} />
                  </div>
                ))}

                {/* Article Body - Custom Markdown Rendering */}
                <div className="article-content">
                  <ReactMarkdown
                    remarkPlugins={[remarkGfm]}
                    components={{
                      // Paragraphs with generous spacing
                      p: ({ children }) => (
                        <p className="text-neutral-400 text-base leading-[1.8] mb-6 font-medium">
                          {children}
                        </p>
                      ),
                      // Headers with clear hierarchy (smaller than section title)
                      h1: ({ children }) => (
                        <h3 className="text-xl font-black italic uppercase text-white mt-12 mb-6 tracking-tight flex items-center gap-3">
                          <span className="w-1.5 h-8 bg-cyan-500 rounded-full" />
                          {children}
                        </h3>
                      ),
                      h2: ({ children }) => (
                        <div className="mt-10 mb-6 p-4 rounded-xl bg-neutral-900/60 border border-white/5">
                          <h4 className="text-base font-black uppercase text-cyan-400 tracking-wide flex items-center gap-2">
                            <span className="w-2 h-2 bg-cyan-400 rounded-full" />
                            {children}
                          </h4>
                        </div>
                      ),
                      h3: ({ children }) => (
                        <h5 className="text-sm font-black uppercase text-white mt-8 mb-4 tracking-wide pl-4 border-l-2 border-purple-500/50">
                          {children}
                        </h5>
                      ),
                      // Strong text
                      strong: ({ children }) => (
                        <strong className="font-black text-white">
                          {children}
                        </strong>
                      ),
                      // Emphasis
                      em: ({ children }) => (
                        <em className="text-neutral-500 not-italic">
                          {children}
                        </em>
                      ),
                      // Lists with proper spacing
                      ul: ({ children }) => (
                        <ul className="my-6 ml-0 space-y-3">
                          {children}
                        </ul>
                      ),
                      ol: ({ children }) => (
                        <ol className="my-6 ml-0 space-y-3 list-decimal list-inside">
                          {children}
                        </ol>
                      ),
                      li: ({ children }) => (
                        <li className="text-neutral-400 text-base leading-[1.8] flex items-start gap-3 font-medium">
                          <span className="text-cyan-500 mt-1.5 flex-shrink-0">*</span>
                          <span>{children}</span>
                        </li>
                      ),
                      // Tables - styled beautifully
                      table: ({ children }) => (
                        <div className="my-8 overflow-x-auto rounded-2xl border border-white/5">
                          <table className="w-full text-left">
                            {children}
                          </table>
                        </div>
                      ),
                      thead: ({ children }) => (
                        <thead className="bg-neutral-900/80 border-b border-white/5">
                          {children}
                        </thead>
                      ),
                      tbody: ({ children }) => (
                        <tbody className="divide-y divide-white/5">
                          {children}
                        </tbody>
                      ),
                      tr: ({ children }) => (
                        <tr className="hover:bg-neutral-900/50 transition-colors">
                          {children}
                        </tr>
                      ),
                      th: ({ children }) => (
                        <th className="px-4 py-3 text-[10px] font-black uppercase tracking-widest text-cyan-400">
                          {children}
                        </th>
                      ),
                      td: ({ children }) => (
                        <td className="px-4 py-3 text-neutral-400 text-sm font-medium">
                          {children}
                        </td>
                      ),
                      // Blockquotes
                      blockquote: ({ children }) => (
                        <blockquote className="my-8 pl-6 border-l-2 border-cyan-500 bg-neutral-900/30 py-4 pr-6 rounded-r-xl">
                          {children}
                        </blockquote>
                      ),
                      // Code
                      code: ({ children }) => (
                        <code className="text-cyan-400 bg-neutral-900 px-2 py-1 rounded-lg text-sm font-mono">
                          {children}
                        </code>
                      ),
                      // Links
                      a: ({ href, children }) => (
                        <a
                          href={href}
                          className="text-cyan-400 hover:text-cyan-300 underline underline-offset-4 decoration-cyan-500/30 hover:decoration-cyan-400 transition-colors font-bold"
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          {children}
                        </a>
                      ),
                      // Horizontal rule
                      hr: () => (
                        <hr className="my-10 border-neutral-900" />
                      ),
                    }}
                  >
                    {section.content}
                  </ReactMarkdown>
                </div>

                {/* Inline Media */}
                {section.media && section.media.filter(m => m.placement !== 'hero').map(media => (
                  <div key={media.id} className="my-10">
                    <MediaRenderer media={media} />
                  </div>
                ))}

                {/* Product Recommendations */}
                {section.products && section.products.length > 0 && (
                  <div className="mt-12 pt-8 border-t border-neutral-900">
                    <h4 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-6 flex items-center gap-4">
                      RECOMMENDED PRODUCTS
                      <div className="flex-1 h-px bg-neutral-800" />
                    </h4>
                    <div className="space-y-4">
                      {section.products.map(productId => (
                        <ProductCallout key={productId} productId={productId} />
                      ))}
                    </div>
                  </div>
                )}

                {/* Section Navigation */}
                <nav className="flex items-center justify-between mt-16 pt-8 border-t border-neutral-900">
                  <button
                    onClick={() => setCurrentSection(Math.max(0, currentSection - 1))}
                    disabled={currentSection === 0}
                    className={`flex items-center gap-3 group transition-all ${currentSection === 0
                      ? 'text-neutral-800 cursor-not-allowed'
                      : 'text-neutral-500 hover:text-white'
                      }`}
                  >
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center transition-colors ${currentSection === 0 ? 'bg-neutral-900/30' : 'bg-neutral-900/50 border border-white/5 group-hover:border-white/10'
                      }`}>
                      <ArrowLeft size={18} />
                    </div>
                    <div className="hidden sm:block text-left">
                      <div className="text-[10px] font-black uppercase tracking-widest text-neutral-700 mb-1">PREVIOUS</div>
                      {currentSection > 0 && (
                        <div className="text-xs font-bold uppercase tracking-wide text-neutral-400">{guide.sections[currentSection - 1].title}</div>
                      )}
                    </div>
                  </button>

                  <button
                    onClick={() => setCurrentSection(Math.min(guide.sections.length - 1, currentSection + 1))}
                    disabled={currentSection === guide.sections.length - 1}
                    className={`flex items-center gap-3 group transition-all ${currentSection === guide.sections.length - 1
                      ? 'text-neutral-800 cursor-not-allowed'
                      : 'text-neutral-500 hover:text-white'
                      }`}
                  >
                    <div className="hidden sm:block text-right">
                      <div className="text-[10px] font-black uppercase tracking-widest text-neutral-700 mb-1">NEXT</div>
                      {currentSection < guide.sections.length - 1 && (
                        <div className="text-xs font-bold uppercase tracking-wide text-neutral-400">{guide.sections[currentSection + 1].title}</div>
                      )}
                    </div>
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center transition-colors ${currentSection === guide.sections.length - 1
                      ? 'bg-neutral-900/30'
                      : 'bg-cyan-500/10 border border-cyan-500/20 group-hover:bg-cyan-500/20'
                      }`}>
                      <ChevronRight size={18} className={currentSection === guide.sections.length - 1 ? '' : 'text-cyan-400'} />
                    </div>
                  </button>
                </nav>
              </motion.section>
            </AnimatePresence>

            {/* Forum Discussion Link (after last section) */}
            {currentSection === guide.sections.length - 1 && (
              <div className="mt-16">
                <ForumDiscussionLink
                  forumCategory={guide.forumCategory}
                  guideTitle={guide.title}
                />
              </div>
            )}
          </article>
        </main>
      </div>
    </motion.div>
  );
}

// ============================================
// GUIDE CARD
// ============================================

interface GuideCardProps {
  guide: Guide;
  index: number;
  onOpen: (guide: Guide) => void;
}

function GuideCard({ guide, index, onOpen }: GuideCardProps) {
  const getCategoryColor = (guideId: string) => {
    const category = GUIDE_CATEGORIES.find(c => c.guideIds.includes(guideId));
    if (!category) return 'cyan';
    const colorMap: Record<string, string> = {
      blue: 'cyan',
      purple: 'purple',
      amber: 'amber',
      pink: 'pink',
      emerald: 'emerald',
      red: 'red',
    };
    return colorMap[category.color] || 'cyan';
  };

  const color = getCategoryColor(guide.id);

  const colorClasses: Record<string, { bg: string; border: string; text: string; iconBg: string }> = {
    cyan: {
      bg: 'bg-neutral-900/40',
      border: 'border-white/5 hover:border-cyan-500/20',
      text: 'text-cyan-400',
      iconBg: 'bg-neutral-900 border border-white/10',
    },
    purple: {
      bg: 'bg-neutral-900/40',
      border: 'border-white/5 hover:border-purple-500/20',
      text: 'text-purple-400',
      iconBg: 'bg-neutral-900 border border-white/10',
    },
    amber: {
      bg: 'bg-neutral-900/40',
      border: 'border-white/5 hover:border-amber-500/20',
      text: 'text-amber-400',
      iconBg: 'bg-neutral-900 border border-white/10',
    },
    pink: {
      bg: 'bg-neutral-900/40',
      border: 'border-white/5 hover:border-pink-500/20',
      text: 'text-pink-400',
      iconBg: 'bg-neutral-900 border border-white/10',
    },
    emerald: {
      bg: 'bg-neutral-900/40',
      border: 'border-white/5 hover:border-emerald-500/20',
      text: 'text-emerald-400',
      iconBg: 'bg-neutral-900 border border-white/10',
    },
    red: {
      bg: 'bg-neutral-900/40',
      border: 'border-white/5 hover:border-red-500/20',
      text: 'text-red-400',
      iconBg: 'bg-neutral-900 border border-white/10',
    },
  };

  const styles = colorClasses[color] || colorClasses.cyan;

  return (
    <motion.div
      onClick={() => onOpen(guide)}
      className={`${styles.bg} ${styles.border} border rounded-2xl p-5 transition-all cursor-pointer group`}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
      whileHover={{ y: -2 }}
    >
      <div className="flex items-start justify-between mb-4">
        <div className={`w-10 h-10 ${styles.iconBg} rounded-xl flex items-center justify-center ${styles.text}`}>
          {getIconComponent(guide.icon)}
        </div>
        <div className="flex items-center gap-1.5 px-2 py-1 rounded-lg bg-neutral-900/50 border border-white/5">
          <Clock size={10} className="text-neutral-600" />
          <span className="text-[10px] font-black uppercase tracking-wider text-neutral-500">{guide.estimatedReadTime} MIN</span>
        </div>
      </div>

      <h3 className="font-black uppercase tracking-tight text-white mb-1 group-hover:text-cyan-400 transition-colors">
        {guide.title}
      </h3>

      {guide.subtitle && (
        <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mb-2">{guide.subtitle}</p>
      )}

      <p className="text-sm text-neutral-500 mb-4 line-clamp-2 font-medium">{guide.description}</p>

      <div className="flex items-center justify-between pt-3 border-t border-white/5">
        <div className="flex items-center gap-2">
          <span className="text-[10px] font-black uppercase tracking-widest text-neutral-600">
            {guide.sections.length} SECTIONS
          </span>
          {guide.productIds && guide.productIds.length > 0 && (
            <>
              <span className="w-1 h-1 rounded-full bg-neutral-800" />
              <span className="text-[10px] font-black uppercase tracking-widest text-neutral-600">
                {guide.productIds.length} PRODUCTS
              </span>
            </>
          )}
        </div>
        <ChevronRight size={16} className="text-neutral-700 group-hover:text-cyan-400 transition-colors" />
      </div>
    </motion.div>
  );
}

// ============================================
// CATEGORY SECTION
// ============================================

interface CategorySectionProps {
  category: GuideCategory;
  onOpenGuide: (guide: Guide) => void;
  gender: 'male' | 'female';
}

function CategorySection({ category, onOpenGuide, gender }: CategorySectionProps) {
  // Skip gender-specific categories for the opposite gender
  if (category.id === 'male' && gender === 'female') return null;
  if (category.id === 'female' && gender === 'male') return null;

  const guides = getGuidesByCategory(category.id);

  if (guides.length === 0) return null;

  const colorClasses: Record<string, { text: string; iconBg: string }> = {
    blue: { text: 'text-cyan-400', iconBg: 'bg-neutral-900 border border-white/10' },
    purple: { text: 'text-purple-400', iconBg: 'bg-neutral-900 border border-white/10' },
    pink: { text: 'text-pink-400', iconBg: 'bg-neutral-900 border border-white/10' },
    cyan: { text: 'text-cyan-400', iconBg: 'bg-neutral-900 border border-white/10' },
    emerald: { text: 'text-emerald-400', iconBg: 'bg-neutral-900 border border-white/10' },
    red: { text: 'text-red-400', iconBg: 'bg-neutral-900 border border-white/10' },
    amber: { text: 'text-amber-400', iconBg: 'bg-neutral-900 border border-white/10' },
  };

  const styles = colorClasses[category.color] || colorClasses.cyan;

  return (
    <div className="mb-12">
      {/* Category Header */}
      <div className="flex items-center gap-4 mb-6">
        <div className={`w-10 h-10 ${styles.iconBg} rounded-xl flex items-center justify-center ${styles.text}`}>
          {getIconComponent(category.icon)}
        </div>
        <div className="flex-1">
          <h3 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 flex items-center gap-4">
            {category.name}
            <div className="flex-1 h-px bg-neutral-800" />
          </h3>
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-700 mt-1">{category.description}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {guides.map((guide, idx) => (
          <GuideCard key={guide.id} guide={guide} index={idx} onOpen={onOpenGuide} />
        ))}
      </div>
    </div>
  );
}

// ============================================
// SEARCH BAR
// ============================================

interface SearchBarProps {
  query: string;
  onQueryChange: (query: string) => void;
}

function SearchBar({ query, onQueryChange }: SearchBarProps) {
  return (
    <div className="relative mb-8">
      <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-neutral-600" />
      <input
        type="text"
        placeholder="SEARCH GUIDES..."
        value={query}
        onChange={(e) => onQueryChange(e.target.value)}
        className="w-full bg-neutral-900/40 border border-white/5 rounded-xl pl-11 pr-4 py-3.5 text-white placeholder:text-neutral-600 placeholder:font-black placeholder:uppercase placeholder:tracking-widest placeholder:text-xs focus:outline-none focus:border-cyan-500/30 transition-colors font-medium text-sm"
      />
    </div>
  );
}

// ============================================
// MAIN TAB COMPONENT
// ============================================

export function GuidesTab() {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedGuide, setSelectedGuide] = useState<Guide | null>(null);
  const { gender } = useResults();

  // Filter guides by gender (excludes opposite gender's specific guides)
  const genderFilteredGuides = getGuidesByGender(gender);

  const filteredGuides = searchQuery.trim()
    ? genderFilteredGuides.filter(g =>
        g.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        g.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (g.subtitle && g.subtitle.toLowerCase().includes(searchQuery.toLowerCase())) ||
        (g.tags && g.tags.some(tag => tag.toLowerCase().includes(searchQuery.toLowerCase())))
      )
    : null;

  const handleOpenGuide = (guide: Guide) => {
    setSelectedGuide(guide);
  };

  const handleCloseGuide = () => {
    setSelectedGuide(null);
  };

  const handleSwitchGuide = (guide: Guide) => {
    setSelectedGuide(guide);
  };

  return (
    <>
      <TabContent
        title="Product Guides"
        subtitle="Evidence-based guides for optimal results"
      >
        <div className="max-w-5xl mx-auto">
          <GuideStatsCard />

          <SearchBar query={searchQuery} onQueryChange={setSearchQuery} />

          {filteredGuides ? (
            // Search Results
            <div>
              <p className="text-[10px] font-black uppercase tracking-widest text-neutral-600 mb-6">
                FOUND {filteredGuides.length} GUIDE{filteredGuides.length !== 1 ? 'S' : ''} MATCHING &ldquo;{searchQuery.toUpperCase()}&rdquo;
              </p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {filteredGuides.map((guide, idx) => (
                  <GuideCard key={guide.id} guide={guide} index={idx} onOpen={handleOpenGuide} />
                ))}
              </div>
              {filteredGuides.length === 0 && (
                <div className="text-center py-16">
                  <div className="w-16 h-16 rounded-2xl bg-neutral-900 border border-white/10 flex items-center justify-center mx-auto mb-4">
                    <Search size={24} className="text-neutral-700" />
                  </div>
                  <p className="text-[10px] font-black uppercase tracking-widest text-neutral-600">NO GUIDES FOUND MATCHING YOUR SEARCH</p>
                </div>
              )}
            </div>
          ) : (
            // Category View
            <div>
              {GUIDE_CATEGORIES.map(category => (
                <CategorySection key={category.id} category={category} onOpenGuide={handleOpenGuide} gender={gender} />
              ))}
            </div>
          )}
        </div>
      </TabContent>

      {/* Guide Viewer Modal */}
      <AnimatePresence>
        {selectedGuide && (
          <GuideViewer
            guide={selectedGuide}
            onClose={handleCloseGuide}
            onSwitchGuide={handleSwitchGuide}
            allGuides={genderFilteredGuides}
            gender={gender}
          />
        )}
      </AnimatePresence>
    </>
  );
}
