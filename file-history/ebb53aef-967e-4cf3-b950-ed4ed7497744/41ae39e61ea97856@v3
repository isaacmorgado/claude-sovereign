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
        <div className="relative rounded-2xl overflow-hidden bg-gradient-to-br from-neutral-900 to-neutral-950 border border-neutral-800">
          <div className="aspect-video flex items-center justify-center p-8">
            <div className="text-center max-w-sm">
              <div className="w-16 h-16 bg-gradient-to-br from-cyan-500/20 to-blue-500/20 rounded-2xl flex items-center justify-center mx-auto mb-4 border border-cyan-500/20">
                {isGif ? (
                  <div className="w-6 h-6 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" />
                ) : (
                  <Sparkles size={28} className="text-cyan-400" />
                )}
              </div>
              <p className="text-neutral-300 font-medium mb-2">{media.alt}</p>
              {media.caption && (
                <p className="text-neutral-500 text-sm">{media.caption}</p>
              )}
            </div>
          </div>
        </div>
      </figure>
    );
  }

  return (
    <figure className={`my-10 ${placementClasses[media.placement || 'inline']}`}>
      <div className="relative rounded-2xl overflow-hidden bg-neutral-900 border border-neutral-800">
        {/* Loading skeleton */}
        {isLoading && (
          <div className="absolute inset-0 bg-neutral-900 animate-pulse flex items-center justify-center">
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
        <figcaption className="mt-4 text-center text-sm text-neutral-500 italic">
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

  if (!product) return null;

  const link = getLink(product.regionLinks, product.directLink);

  return (
    <div className="my-6 p-4 bg-gradient-to-r from-cyan-500/10 to-blue-500/10 border border-cyan-500/20 rounded-xl">
      <div className="flex items-center gap-4">
        {/* Product Image */}
        {product.imageUrl && (
          <div className="w-16 h-16 bg-neutral-800 rounded-lg overflow-hidden flex-shrink-0">
            <Image
              src={product.imageUrl}
              alt={product.name}
              width={64}
              height={64}
              className="w-full h-full object-cover"
            />
          </div>
        )}

        {/* Product Info */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <h4 className="font-semibold text-white truncate">{product.name}</h4>
            {product.brand && (
              <span className="text-xs text-neutral-500">{product.brand}</span>
            )}
          </div>
          <p className="text-sm text-cyan-300 italic">&ldquo;{product.tagline}&rdquo;</p>
        </div>

        {/* CTA Button */}
        <a
          href={link}
          target="_blank"
          rel="noopener noreferrer"
          className="flex-shrink-0 flex items-center gap-2 px-4 py-2 bg-cyan-500 hover:bg-cyan-400 text-black font-medium rounded-lg transition-colors"
        >
          <ShoppingCart size={16} />
          <span className="hidden sm:inline">Buy Now</span>
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
    <div className="mt-8 p-6 bg-neutral-900/50 border border-neutral-800 rounded-xl">
      <div className="flex items-center gap-3 mb-3">
        <div className="w-10 h-10 bg-purple-500/10 rounded-xl flex items-center justify-center">
          <MessageSquare size={20} className="text-purple-400" />
        </div>
        <div>
          <h3 className="font-semibold text-white">Discuss This Guide</h3>
          <p className="text-sm text-neutral-400">Join the community conversation</p>
        </div>
      </div>

      <p className="text-sm text-neutral-400 mb-4">
        Have questions about {guideTitle.toLowerCase()}? Want to share your experience?
        Join the discussion in our community forum.
      </p>

      <Link
        href={`/forum/${forumCategory}`}
        className="inline-flex items-center gap-2 px-4 py-2 bg-purple-500/10 hover:bg-purple-500/20 text-purple-400 border border-purple-500/30 rounded-lg transition-colors"
      >
        <MessageSquare size={16} />
        Go to Forum
        <ExternalLink size={14} />
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
      className="bg-gradient-to-br from-neutral-900 to-neutral-950 border border-neutral-800 rounded-2xl p-6 mb-6"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="flex items-center gap-3 mb-4">
        <div className="w-10 h-10 bg-cyan-500/10 rounded-xl flex items-center justify-center">
          <BookOpen size={20} className="text-cyan-400" />
        </div>
        <div>
          <h2 className="font-semibold text-white">Product Guides</h2>
          <p className="text-sm text-neutral-400">Evidence-based looksmaxxing resources</p>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div className="bg-neutral-900/50 rounded-xl p-4">
          <div className="text-2xl font-bold text-white mb-1">{totalGuides}</div>
          <div className="text-xs text-neutral-500">Total Guides</div>
        </div>
        <div className="bg-neutral-900/50 rounded-xl p-4">
          <div className="flex items-center gap-1.5 mb-1">
            <Clock size={16} className="text-cyan-400" />
            <div className="text-2xl font-bold text-white">{totalMinutes}</div>
          </div>
          <div className="text-xs text-neutral-500">Minutes of Content</div>
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
}

function GuideViewer({ guide, onClose }: GuideViewerProps) {
  const [currentSection, setCurrentSection] = useState(0);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const section = guide.sections[currentSection];

  if (!section) return null;

  // Calculate reading progress (0% at start, 100% at last section)
  const progress = guide.sections.length > 1
    ? (currentSection / (guide.sections.length - 1)) * 100
    : 100;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 bg-neutral-950"
    >
      {/* Header */}
      <div className="sticky top-0 z-20 bg-neutral-950/95 backdrop-blur-md border-b border-neutral-900">
        <div className="flex items-center justify-between px-4 lg:px-8 py-3">
          <button
            onClick={onClose}
            className="flex items-center gap-2 text-neutral-400 hover:text-white transition-colors"
          >
            <ArrowLeft size={20} />
            <span className="hidden sm:inline text-sm">Back to Guides</span>
          </button>

          {/* Progress bar */}
          <div className="hidden md:flex items-center gap-4 flex-1 max-w-md mx-8">
            <div className="flex-1 h-1 bg-neutral-800 rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-gradient-to-r from-cyan-500 to-blue-500"
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.3 }}
              />
            </div>
            <span className="text-xs text-neutral-500 whitespace-nowrap">
              {currentSection + 1} / {guide.sections.length}
            </span>
          </div>

          <div className="flex items-center gap-3">
            {/* Mobile menu button */}
            <button
              onClick={() => setIsSidebarOpen(!isSidebarOpen)}
              className="lg:hidden p-2 hover:bg-neutral-900 rounded-lg transition-colors"
            >
              <BookOpen size={20} className="text-neutral-400" />
            </button>
            <button
              onClick={onClose}
              className="p-2 hover:bg-neutral-900 rounded-lg transition-colors"
            >
              <X size={20} className="text-neutral-400" />
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
            w-72 lg:w-80 bg-neutral-950 lg:bg-neutral-950/50
            border-r border-neutral-900
            transform transition-transform duration-300 ease-in-out
            ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
            flex flex-col
          `}
        >
          {/* Sidebar Header */}
          <div className="p-6 border-b border-neutral-900">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 bg-gradient-to-br from-cyan-500/20 to-blue-500/20 rounded-xl flex items-center justify-center text-cyan-400">
                {getIconComponent(guide.icon, 20)}
              </div>
              <div className="flex-1 min-w-0">
                <h2 className="font-semibold text-white truncate">{guide.title}</h2>
                <div className="flex items-center gap-2 text-xs text-neutral-500">
                  <Clock size={12} />
                  <span>{guide.estimatedReadTime} min</span>
                </div>
              </div>
            </div>
            {guide.subtitle && (
              <p className="text-sm text-neutral-500 italic">{guide.subtitle}</p>
            )}
          </div>

          {/* Section List */}
          <nav className="flex-1 overflow-y-auto p-4">
            <div className="text-xs font-semibold text-neutral-600 uppercase tracking-wider mb-3 px-2">
              Sections
            </div>
            <ul className="space-y-1">
              {guide.sections.map((s, idx) => (
                <li key={s.id}>
                  <button
                    onClick={() => {
                      setCurrentSection(idx);
                      setIsSidebarOpen(false);
                    }}
                    className={`
                      w-full text-left px-3 py-3 rounded-xl transition-all
                      flex items-start gap-3 group
                      ${currentSection === idx
                        ? 'bg-gradient-to-r from-cyan-500/10 to-blue-500/10 border border-cyan-500/20'
                        : 'hover:bg-neutral-900 border border-transparent'
                      }
                    `}
                  >
                    {/* Section number */}
                    <span
                      className={`
                        flex-shrink-0 w-6 h-6 rounded-lg text-xs font-bold
                        flex items-center justify-center transition-colors
                        ${currentSection === idx
                          ? 'bg-cyan-500 text-black'
                          : idx < currentSection
                            ? 'bg-green-500/20 text-green-400'
                            : 'bg-neutral-800 text-neutral-500 group-hover:bg-neutral-700'
                        }
                      `}
                    >
                      {idx < currentSection ? (
                        <CheckCircle2 size={14} />
                      ) : (
                        idx + 1
                      )}
                    </span>

                    {/* Section info */}
                    <div className="flex-1 min-w-0">
                      <p
                        className={`text-sm font-medium truncate ${currentSection === idx ? 'text-white' : 'text-neutral-400 group-hover:text-neutral-200'
                          }`}
                      >
                        {s.title}
                      </p>
                      {/* Show media indicator if section has media */}
                      {s.media && s.media.length > 0 && (
                        <div className="flex items-center gap-1 mt-1">
                          <Sparkles size={10} className="text-amber-400" />
                          <span className="text-xs text-neutral-600">
                            {s.media.length} visual{s.media.length > 1 ? 's' : ''}
                          </span>
                        </div>
                      )}
                    </div>
                  </button>
                </li>
              ))}
            </ul>
          </nav>

          {/* Sidebar Footer */}
          <div className="p-4 border-t border-neutral-900">
            <div className="flex items-center justify-between text-xs text-neutral-600 mb-2">
              <span>Progress</span>
              <span>{Math.round(progress)}%</span>
            </div>
            <div className="h-1.5 bg-neutral-800 rounded-full overflow-hidden">
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
            className="fixed inset-0 bg-black/60 z-20 lg:hidden"
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
                <div className="inline-flex items-center gap-2 px-3 py-1.5 bg-cyan-500/10 text-cyan-400 rounded-full text-xs font-medium mb-4">
                  {getIconComponent(guide.icon, 14)}
                  <span className="uppercase tracking-wider">Guide</span>
                </div>

                <h1 className="text-3xl md:text-4xl font-bold text-white mb-4 leading-tight">
                  {guide.title}
                </h1>

                <p className="text-neutral-300 text-lg leading-relaxed">
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
                <h2 className="text-3xl md:text-4xl font-bold text-white mb-8 pb-4 border-b border-neutral-900">
                  {section.title}
                </h2>

                {/* Tips Callout */}
                {section.tips && section.tips.length > 0 && (
                  <aside className="mb-10 p-6 bg-gradient-to-br from-cyan-500/5 to-cyan-600/5 border-l-4 border-cyan-500 rounded-r-xl">
                    <h4 className="text-sm font-semibold text-cyan-400 uppercase tracking-wider mb-4">
                      Quick Tips
                    </h4>
                    <ul className="space-y-3">
                      {section.tips.map((tip, i) => (
                        <li key={i} className="flex items-start gap-3 text-neutral-300">
                          <span className="flex-shrink-0 w-5 h-5 bg-cyan-500/20 rounded-full flex items-center justify-center mt-0.5">
                            <span className="text-cyan-400 text-xs font-bold">{i + 1}</span>
                          </span>
                          <span className="leading-relaxed">{tip}</span>
                        </li>
                      ))}
                    </ul>
                  </aside>
                )}

                {/* Warnings Callout */}
                {section.warnings && section.warnings.length > 0 && (
                  <aside className="mb-10 p-6 bg-gradient-to-br from-amber-500/5 to-amber-600/5 border-l-4 border-amber-500 rounded-r-xl">
                    <h4 className="text-sm font-semibold text-amber-400 uppercase tracking-wider mb-4">
                      ⚠️ Important
                    </h4>
                    <ul className="space-y-3">
                      {section.warnings.map((warning, i) => (
                        <li key={i} className="flex items-start gap-3 text-neutral-300">
                          <span className="text-amber-400 mt-1">•</span>
                          <span className="leading-relaxed">{warning}</span>
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
                        <p className="text-neutral-300 text-lg leading-[1.8] mb-6">
                          {children}
                        </p>
                      ),
                      // Headers with clear hierarchy (smaller than section title)
                      h1: ({ children }) => (
                        <h3 className="text-2xl md:text-3xl font-bold text-white mt-12 mb-6">
                          {children}
                        </h3>
                      ),
                      h2: ({ children }) => (
                        <h4 className="text-xl md:text-2xl font-bold text-white mt-10 mb-5 pb-3 border-b border-neutral-800">
                          {children}
                        </h4>
                      ),
                      h3: ({ children }) => (
                        <h5 className="text-lg md:text-xl font-semibold text-white mt-8 mb-4">
                          {children}
                        </h5>
                      ),
                      // Strong text
                      strong: ({ children }) => (
                        <strong className="font-semibold text-white">
                          {children}
                        </strong>
                      ),
                      // Emphasis
                      em: ({ children }) => (
                        <em className="text-neutral-400 not-italic">
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
                        <li className="text-neutral-300 text-lg leading-[1.8] flex items-start gap-3">
                          <span className="text-cyan-500 mt-1.5 flex-shrink-0">•</span>
                          <span>{children}</span>
                        </li>
                      ),
                      // Tables - styled beautifully
                      table: ({ children }) => (
                        <div className="my-8 overflow-x-auto rounded-xl border border-neutral-800">
                          <table className="w-full text-left">
                            {children}
                          </table>
                        </div>
                      ),
                      thead: ({ children }) => (
                        <thead className="bg-neutral-900/80 border-b border-neutral-800">
                          {children}
                        </thead>
                      ),
                      tbody: ({ children }) => (
                        <tbody className="divide-y divide-neutral-800/50">
                          {children}
                        </tbody>
                      ),
                      tr: ({ children }) => (
                        <tr className="hover:bg-neutral-900/50 transition-colors">
                          {children}
                        </tr>
                      ),
                      th: ({ children }) => (
                        <th className="px-4 py-3 text-sm font-semibold text-cyan-400 uppercase tracking-wider">
                          {children}
                        </th>
                      ),
                      td: ({ children }) => (
                        <td className="px-4 py-3 text-neutral-300">
                          {children}
                        </td>
                      ),
                      // Blockquotes
                      blockquote: ({ children }) => (
                        <blockquote className="my-8 pl-6 border-l-4 border-cyan-500 bg-neutral-900/50 py-4 pr-6 rounded-r-lg">
                          {children}
                        </blockquote>
                      ),
                      // Code
                      code: ({ children }) => (
                        <code className="text-cyan-400 bg-neutral-900 px-2 py-1 rounded text-base">
                          {children}
                        </code>
                      ),
                      // Links
                      a: ({ href, children }) => (
                        <a
                          href={href}
                          className="text-cyan-400 hover:text-cyan-300 underline underline-offset-4 decoration-cyan-500/30 hover:decoration-cyan-400 transition-colors"
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          {children}
                        </a>
                      ),
                      // Horizontal rule
                      hr: () => (
                        <hr className="my-10 border-neutral-800" />
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
                    <h4 className="text-sm font-semibold text-neutral-400 uppercase tracking-wider mb-6">
                      Recommended Products
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
                      ? 'text-neutral-700 cursor-not-allowed'
                      : 'text-neutral-400 hover:text-white'
                      }`}
                  >
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center transition-colors ${currentSection === 0 ? 'bg-neutral-900' : 'bg-neutral-900 group-hover:bg-neutral-800'
                      }`}>
                      <ArrowLeft size={20} />
                    </div>
                    <div className="hidden sm:block text-left">
                      <div className="text-xs text-neutral-600 uppercase tracking-wider mb-1">Previous</div>
                      {currentSection > 0 && (
                        <div className="text-sm font-medium text-neutral-300">{guide.sections[currentSection - 1].title}</div>
                      )}
                    </div>
                  </button>

                  <button
                    onClick={() => setCurrentSection(Math.min(guide.sections.length - 1, currentSection + 1))}
                    disabled={currentSection === guide.sections.length - 1}
                    className={`flex items-center gap-3 group transition-all ${currentSection === guide.sections.length - 1
                      ? 'text-neutral-700 cursor-not-allowed'
                      : 'text-neutral-400 hover:text-white'
                      }`}
                  >
                    <div className="hidden sm:block text-right">
                      <div className="text-xs text-neutral-600 uppercase tracking-wider mb-1">Next</div>
                      {currentSection < guide.sections.length - 1 && (
                        <div className="text-sm font-medium text-neutral-300">{guide.sections[currentSection + 1].title}</div>
                      )}
                    </div>
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center transition-colors ${currentSection === guide.sections.length - 1
                      ? 'bg-neutral-900'
                      : 'bg-gradient-to-r from-cyan-500/20 to-blue-500/20 group-hover:from-cyan-500/30 group-hover:to-blue-500/30'
                      }`}>
                      <ChevronRight size={20} className={currentSection === guide.sections.length - 1 ? '' : 'text-cyan-400'} />
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
    };
    return colorMap[category.color] || 'cyan';
  };

  const color = getCategoryColor(guide.id);

  const colorClasses = {
    cyan: 'from-cyan-500/10 to-cyan-600/10 border-cyan-500/20 text-cyan-400',
    purple: 'from-purple-500/10 to-purple-600/10 border-purple-500/20 text-purple-400',
    amber: 'from-amber-500/10 to-amber-600/10 border-amber-500/20 text-amber-400',
  };

  const iconColorClasses = {
    cyan: 'bg-cyan-500/10 text-cyan-400',
    purple: 'bg-purple-500/10 text-purple-400',
    amber: 'bg-amber-500/10 text-amber-400',
  };

  return (
    <motion.div
      onClick={() => onOpen(guide)}
      className={`bg-gradient-to-br ${colorClasses[color as keyof typeof colorClasses]} border rounded-xl p-5 hover:border-opacity-50 transition-all cursor-pointer group`}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
      whileHover={{ y: -2 }}
    >
      <div className="flex items-start justify-between mb-3">
        <div className={`w-10 h-10 ${iconColorClasses[color as keyof typeof iconColorClasses]} rounded-xl flex items-center justify-center`}>
          {getIconComponent(guide.icon)}
        </div>
        <div className="flex items-center gap-1 text-neutral-500 text-xs">
          <Clock size={12} />
          <span>{guide.estimatedReadTime} min</span>
        </div>
      </div>

      <h3 className="font-semibold text-white mb-1 group-hover:text-cyan-300 transition-colors">
        {guide.title}
      </h3>

      {guide.subtitle && (
        <p className="text-xs text-neutral-400 mb-2 italic">{guide.subtitle}</p>
      )}

      <p className="text-sm text-neutral-400 mb-3 line-clamp-2">{guide.description}</p>

      <div className="flex items-center justify-between">
        <div className="flex items-center gap-1 text-xs text-neutral-500">
          <span>{guide.sections.length} sections</span>
          {guide.productIds && guide.productIds.length > 0 && (
            <>
              <span>-</span>
              <span>{guide.productIds.length} products</span>
            </>
          )}
        </div>
        <ChevronRight size={16} className="text-neutral-600 group-hover:text-cyan-400 transition-colors" />
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

  const colorClasses: Record<string, string> = {
    blue: 'text-cyan-400 bg-cyan-500/10',
    purple: 'text-purple-400 bg-purple-500/10',
    pink: 'text-pink-400 bg-pink-500/10',
    cyan: 'text-cyan-400 bg-cyan-500/10',
    emerald: 'text-emerald-400 bg-emerald-500/10',
    red: 'text-red-400 bg-red-500/10',
    amber: 'text-amber-400 bg-amber-500/10',
  };

  return (
    <div className="mb-8">
      <div className="flex items-center gap-3 mb-4">
        <div className={`w-8 h-8 ${colorClasses[category.color as keyof typeof colorClasses]} rounded-lg flex items-center justify-center`}>
          {getIconComponent(category.icon)}
        </div>
        <div>
          <h3 className="font-semibold text-white">{category.name}</h3>
          <p className="text-xs text-neutral-500">{category.description}</p>
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
    <div className="relative mb-6">
      <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-neutral-500" />
      <input
        type="text"
        placeholder="Search guides..."
        value={query}
        onChange={(e) => onQueryChange(e.target.value)}
        className="w-full bg-neutral-900 border border-neutral-800 rounded-xl pl-11 pr-4 py-3 text-white placeholder:text-neutral-500 focus:outline-none focus:border-cyan-500/50 transition-colors"
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
              <p className="text-sm text-neutral-400 mb-4">
                Found {filteredGuides.length} guide{filteredGuides.length !== 1 ? 's' : ''} matching &ldquo;{searchQuery}&rdquo;
              </p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {filteredGuides.map((guide, idx) => (
                  <GuideCard key={guide.id} guide={guide} index={idx} onOpen={handleOpenGuide} />
                ))}
              </div>
              {filteredGuides.length === 0 && (
                <div className="text-center py-12">
                  <div className="w-16 h-16 bg-neutral-900 rounded-full flex items-center justify-center mx-auto mb-4">
                    <Search size={24} className="text-neutral-600" />
                  </div>
                  <p className="text-neutral-500">No guides found matching your search</p>
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
          <GuideViewer guide={selectedGuide} onClose={handleCloseGuide} />
        )}
      </AnimatePresence>
    </>
  );
}
