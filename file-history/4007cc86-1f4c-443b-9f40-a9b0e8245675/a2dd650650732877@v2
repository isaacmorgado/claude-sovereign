'use client';

import { useState, useMemo, forwardRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ShoppingBag,
  Package,
  ExternalLink,
  Search,
  Sparkles,
  Zap,
  Shield,
  Clock,
  TrendingUp,
  CheckCircle,
  Scissors,
  Droplet,
  Pill,
  Dumbbell,
  Eye,
  Smile,
} from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { useRegion } from '@/contexts/RegionContext';
import { TabContent } from '../ResultsLayout';
import { GUIDE_PRODUCTS } from '@/data/guides/products-registry';
import { GuideProduct } from '@/types/guides';

// ============================================
// SECTION HEADER
// ============================================

function SectionHeader({ title, children }: { title: string; children?: React.ReactNode }) {
  return (
    <div className="flex items-center gap-4 mb-6">
      <h2 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 whitespace-nowrap">
        {title}
      </h2>
      <div className="flex-1 h-px bg-neutral-800" />
      {children}
    </div>
  );
}

// ============================================
// CATEGORY DEFINITIONS
// ============================================

type ProductCategory = 'all' | 'supplements' | 'skincare' | 'tools' | 'grooming' | 'hygiene' | 'hair' | 'teeth';

const CATEGORIES: { id: ProductCategory; label: string; icon: React.ReactNode }[] = [
  { id: 'all', label: 'All Products', icon: <Package size={14} /> },
  { id: 'supplements', label: 'Supplements', icon: <Pill size={14} /> },
  { id: 'skincare', label: 'Skincare', icon: <Droplet size={14} /> },
  { id: 'tools', label: 'Tools', icon: <Scissors size={14} /> },
  { id: 'grooming', label: 'Grooming', icon: <Dumbbell size={14} /> },
  { id: 'hygiene', label: 'Hygiene', icon: <Sparkles size={14} /> },
  { id: 'hair', label: 'Hair', icon: <Eye size={14} /> },
  { id: 'teeth', label: 'Teeth', icon: <Smile size={14} /> },
];

// Map guide product categories to our categories
function mapCategory(cat: string): ProductCategory {
  const mapping: Record<string, ProductCategory> = {
    supplements: 'supplements',
    skincare: 'skincare',
    miscellaneous: 'tools',
    grooming: 'grooming',
    hygiene: 'hygiene',
    hair: 'hair',
    beard: 'grooming',
    teeth: 'teeth',
    kbeauty: 'skincare',
    hormonal: 'supplements',
    surgery: 'tools',
  };
  return mapping[cat] || 'all';
}

// ============================================
// HERO BUNDLE CARD
// ============================================

interface HeroBundleProps {
  title: string;
  subtitle: string;
  products: GuideProduct[];
  savings: number;
  gradient: string;
  icon: React.ReactNode;
  bundleUrl?: string;
}

function HeroBundleCard({ title, subtitle, products, savings, gradient, icon, bundleUrl }: HeroBundleProps) {
  const { formatAmount, getLink } = useRegion();

  const totalPrice = useMemo(() => {
    return products.reduce((sum, p) => sum + (p.priceRange?.max || 0), 0);
  }, [products]);

  const bundlePrice = Math.round(totalPrice * (1 - savings / 100));

  // Generate Amazon add-to-cart URL for multiple items
  const generateBundleLink = () => {
    if (bundleUrl) return bundleUrl;

    // Build Amazon add-to-cart URL with multiple ASINs
    // Format: https://www.amazon.com/gp/aws/cart/add.html?ASIN.1=XXX&Quantity.1=1&ASIN.2=YYY&Quantity.2=1...
    const baseUrl = 'https://www.amazon.com/gp/aws/cart/add.html?';
    const params = products
      .slice(0, 4)
      .map((p, idx) => {
        // Extract ASIN from regionLinks.us URL
        const usLink = p.regionLinks?.['us'] || '';
        const asinMatch = usLink.match(/\/dp\/([A-Z0-9]{10})/);
        const asin = asinMatch ? asinMatch[1] : '';
        if (!asin) return '';
        return `ASIN.${idx + 1}=${asin}&Quantity.${idx + 1}=1`;
      })
      .filter(Boolean)
      .join('&');

    return params ? `${baseUrl}${params}&tag=looksmaxx-20` : '#';
  };

  const handleBundleClick = () => {
    const link = generateBundleLink();
    if (link !== '#') {
      window.open(link, '_blank', 'noopener,noreferrer');
    }
  };

  return (
    <motion.div
      className={`rounded-[2rem] ${gradient} border border-white/10 p-6 md:p-8 relative overflow-hidden`}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
    >
      {/* Decorative blur */}
      <div className="absolute top-0 right-0 w-64 h-64 rounded-full bg-white/10 blur-[100px] -translate-y-1/2 translate-x-1/2" />

      <div className="relative z-10">
        <div className="flex items-start justify-between gap-4 mb-6">
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-white/20 border border-white/20 flex items-center justify-center shadow-xl">
              {icon}
            </div>
            <div>
              <h3 className="text-xl font-black uppercase tracking-wider text-white">{title}</h3>
              <p className="text-sm text-white/70">{subtitle}</p>
            </div>
          </div>
          <div className="px-3 py-1.5 bg-white/20 border border-white/20 rounded-lg">
            <span className="text-sm font-black text-white">Save {savings}%</span>
          </div>
        </div>

        {/* Products grid */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
          {products.slice(0, 4).map((product, idx) => {
            const productLink = product.regionLinks ? getLink(product.regionLinks) : '#';
            return (
              <a
                key={product.id}
                href={productLink}
                target="_blank"
                rel="noopener noreferrer"
                className="bg-black/30 rounded-xl p-3 border border-white/10 overflow-hidden hover:border-white/30 transition-colors group"
              >
                <div className="flex items-center gap-2 mb-2 min-w-0">
                  <div className="w-6 h-6 rounded-lg bg-white/10 flex items-center justify-center flex-shrink-0">
                    <span className="text-xs font-black text-white/80">{idx + 1}</span>
                  </div>
                  <span className="text-[10px] font-bold uppercase tracking-wider text-white/60 truncate">{product.brand}</span>
                </div>
                <p className="text-sm font-bold text-white group-hover:text-cyan-300 transition-colors line-clamp-2 leading-tight">{product.name}</p>
                {product.priceRange && (
                  <p className="text-[10px] font-bold text-white/50 mt-1">${product.priceRange.min}-${product.priceRange.max}</p>
                )}
              </a>
            );
          })}
        </div>

        {/* Pricing & CTA */}
        <div className="flex items-center justify-between gap-4 pt-4 border-t border-white/10">
          <div>
            <p className="text-[10px] font-bold uppercase tracking-wider text-white/60 mb-1">Bundle Total</p>
            <div className="flex items-baseline gap-2">
              <span className="text-2xl font-black text-white">{formatAmount(bundlePrice)}</span>
              <span className="text-sm font-bold text-white/50 line-through">{formatAmount(totalPrice)}</span>
            </div>
          </div>
          <button
            onClick={handleBundleClick}
            className="px-6 py-3 bg-white text-black text-xs font-black uppercase tracking-wider rounded-xl hover:bg-white/90 transition-colors flex items-center gap-2"
          >
            <ShoppingBag size={16} />
            Add All to Cart
          </button>
        </div>
      </div>
    </motion.div>
  );
}

// ============================================
// PRODUCT CARD
// ============================================

interface ProductCardProps {
  product: GuideProduct;
  rank?: number;
  isRecommended?: boolean;
}

const ProductCard = forwardRef<HTMLDivElement, ProductCardProps>(
  function ProductCard({ product, rank, isRecommended }, ref) {
    const { getLink, formatAmount, region } = useRegion();
    const link = product.regionLinks ? getLink(product.regionLinks) : '#';

    return (
      <motion.div
        ref={ref}
        className={`rounded-2xl bg-neutral-900/40 border ${isRecommended ? 'border-cyan-500/30' : 'border-white/5'} p-5 hover:border-white/10 transition-all group`}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
      <div className="flex items-start gap-4 mb-4">
        {rank && (
          <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/10 flex items-center justify-center flex-shrink-0">
            <span className="text-xs font-black text-neutral-400">#{rank}</span>
          </div>
        )}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-[9px] font-black uppercase tracking-wider text-neutral-500">{product.brand || 'Brand'}</span>
            {isRecommended && (
              <span className="px-1.5 py-0.5 bg-cyan-500/20 border border-cyan-500/30 rounded text-[8px] font-black uppercase tracking-wider text-cyan-400">
                Recommended
              </span>
            )}
            {product.isBaseStack && (
              <span className="px-1.5 py-0.5 bg-green-500/20 border border-green-500/30 rounded text-[8px] font-black uppercase tracking-wider text-green-400">
                Essential
              </span>
            )}
          </div>
          <h4 className="text-sm font-black uppercase tracking-wider text-white group-hover:text-cyan-400 transition-colors leading-tight">
            {product.name}
          </h4>
        </div>
        {product.priceRange && (
          <div className="text-right flex-shrink-0">
            <p className="text-sm font-black text-white">
              {formatAmount(product.priceRange.min)}
              {product.priceRange.max !== product.priceRange.min && (
                <span className="text-neutral-500">-{formatAmount(product.priceRange.max)}</span>
              )}
            </p>
          </div>
        )}
      </div>

      {product.tagline && (
        <p className="text-xs text-neutral-400 mb-4 leading-relaxed line-clamp-2 italic">
          &ldquo;{product.tagline}&rdquo;
        </p>
      )}

      {product.description && !product.tagline && (
        <p className="text-xs text-neutral-500 mb-4 leading-relaxed line-clamp-2">
          {product.description}
        </p>
      )}

      <a
        href={link}
        target="_blank"
        rel="noopener noreferrer"
        className="flex items-center justify-center gap-2 w-full py-2.5 bg-neutral-800 hover:bg-neutral-700 border border-white/5 rounded-xl text-[10px] font-black uppercase tracking-wider text-white transition-colors"
      >
        <ExternalLink size={12} />
        Buy on {region === 'asia' ? 'Amazon' : region.toUpperCase()}
      </a>
      </motion.div>
    );
  }
);

// ============================================
// STATS CARD
// ============================================

function StatsCard({ products }: { products: GuideProduct[] }) {
  const essentialCount = products.filter(p => p.isBaseStack).length;
  const categories = new Set(products.map(p => p.category)).size;

  return (
    <div className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-6">
      <div className="grid grid-cols-3 gap-4">
        <div className="text-center">
          <p className="text-3xl font-black text-cyan-400">{products.length}</p>
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Products</p>
        </div>
        <div className="text-center border-x border-white/5">
          <p className="text-3xl font-black text-green-400">{essentialCount}</p>
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Essential</p>
        </div>
        <div className="text-center">
          <p className="text-3xl font-black text-purple-400">{categories}</p>
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">Categories</p>
        </div>
      </div>
    </div>
  );
}

// ============================================
// SHOP TAB
// ============================================

export function ShopTab() {
  const { gender } = useResults();
  const [selectedCategory, setSelectedCategory] = useState<ProductCategory>('all');
  const [searchQuery, setSearchQuery] = useState('');

  // Get all products
  const allProducts = useMemo(() => {
    // Guide products are more complete, use those
    return GUIDE_PRODUCTS.sort((a, b) => {
      // Base stack items first
      if (a.isBaseStack && !b.isBaseStack) return -1;
      if (!a.isBaseStack && b.isBaseStack) return 1;
      // Then by priority
      return a.priority - b.priority;
    });
  }, []);

  // Filter products
  const filteredProducts = useMemo(() => {
    let products = allProducts;

    if (selectedCategory !== 'all') {
      products = products.filter(p => mapCategory(p.category) === selectedCategory);
    }

    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      products = products.filter(p =>
        p.name.toLowerCase().includes(query) ||
        p.brand?.toLowerCase().includes(query) ||
        p.tagline?.toLowerCase().includes(query) ||
        p.description?.toLowerCase().includes(query)
      );
    }

    return products;
  }, [allProducts, selectedCategory, searchQuery]);

  // Get products for hero bundles
  const starterBundle = useMemo(() => {
    return allProducts.filter(p => p.isBaseStack).slice(0, 4);
  }, [allProducts]);

  const skinBundle = useMemo(() => {
    return allProducts.filter(p => p.category === 'skincare' || p.category === 'kbeauty').slice(0, 4);
  }, [allProducts]);

  const maleBundle = useMemo(() => {
    return allProducts.filter(p =>
      p.category === 'grooming' ||
      p.category === 'beard' ||
      p.category === 'hair'
    ).slice(0, 4);
  }, [allProducts]);

  // Supplements bundle
  const supplementBundle = useMemo(() => {
    return allProducts.filter(p => p.category === 'supplements').slice(0, 4);
  }, [allProducts]);

  // Hair growth bundle (minoxidil, dermaroller, etc)
  const hairBundle = useMemo(() => {
    return allProducts.filter(p =>
      p.category === 'hair' ||
      p.name.toLowerCase().includes('minox') ||
      p.name.toLowerCase().includes('derma')
    ).slice(0, 4);
  }, [allProducts]);

  // Teeth/smile bundle
  const teethBundle = useMemo(() => {
    return allProducts.filter(p =>
      p.category === 'teeth' ||
      p.name.toLowerCase().includes('whiten') ||
      p.name.toLowerCase().includes('tooth') ||
      p.name.toLowerCase().includes('dental')
    ).slice(0, 4);
  }, [allProducts]);

  return (
    <TabContent
      title="Shop"
      subtitle="Curated products to optimize your potential"
    >
      <div className="space-y-10">
        {/* Stats */}
        <StatsCard products={allProducts} />

        {/* Hero Bundles */}
        <section>
          <SectionHeader title="Featured Bundles">
            <span className="px-3 py-1.5 bg-purple-500/20 border border-purple-500/30 text-purple-400 text-[10px] font-black uppercase tracking-wider rounded-lg">
              Save Up to 20%
            </span>
          </SectionHeader>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <HeroBundleCard
              title="Starter Stack"
              subtitle="The essentials every looksmaxxer needs"
              products={starterBundle}
              savings={15}
              gradient="bg-gradient-to-br from-cyan-600 to-blue-700"
              icon={<Zap size={24} className="text-white" />}
            />
            <HeroBundleCard
              title="Skin Protocol"
              subtitle="Complete skincare routine for clear skin"
              products={skinBundle}
              savings={20}
              gradient="bg-gradient-to-br from-rose-600 to-pink-700"
              icon={<Droplet size={24} className="text-white" />}
            />
          </div>

          {/* Second row of bundles */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
            {supplementBundle.length >= 4 && (
              <HeroBundleCard
                title="Supplement Stack"
                subtitle="Optimize hormones, skin, and recovery"
                products={supplementBundle}
                savings={15}
                gradient="bg-gradient-to-br from-green-600 to-emerald-700"
                icon={<Pill size={24} className="text-white" />}
              />
            )}
            {hairBundle.length >= 3 && (
              <HeroBundleCard
                title="Hair Growth Protocol"
                subtitle="Combat hair loss and boost density"
                products={hairBundle}
                savings={18}
                gradient="bg-gradient-to-br from-amber-600 to-orange-700"
                icon={<TrendingUp size={24} className="text-white" />}
              />
            )}
          </div>

          {/* Third row - gender specific */}
          {gender === 'male' && maleBundle.length >= 4 && (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
              <HeroBundleCard
                title="Male Grooming Kit"
                subtitle="Essential grooming for peak appearance"
                products={maleBundle}
                savings={15}
                gradient="bg-gradient-to-br from-neutral-700 to-neutral-900"
                icon={<Scissors size={24} className="text-white" />}
              />
              {teethBundle.length >= 2 && (
                <HeroBundleCard
                  title="Smile Makeover"
                  subtitle="Whiten and perfect your smile"
                  products={teethBundle}
                  savings={12}
                  gradient="bg-gradient-to-br from-violet-600 to-purple-700"
                  icon={<Smile size={24} className="text-white" />}
                />
              )}
            </div>
          )}
        </section>

        {/* Why These Products */}
        <section className="rounded-[2rem] bg-neutral-900/40 border border-white/5 p-6 md:p-8">
          <h3 className="text-sm font-black uppercase tracking-wider text-white mb-6 flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center">
              <Shield size={18} className="text-cyan-400" />
            </div>
            Why We Recommend These Products
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="flex items-start gap-4">
              <div className="w-8 h-8 rounded-lg bg-green-500/20 border border-green-500/30 flex items-center justify-center flex-shrink-0">
                <CheckCircle size={14} className="text-green-400" />
              </div>
              <div>
                <p className="text-sm font-bold text-white mb-1">Evidence-Based</p>
                <p className="text-xs text-neutral-500">Every product is backed by clinical research and real results</p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="w-8 h-8 rounded-lg bg-cyan-500/20 border border-cyan-500/30 flex items-center justify-center flex-shrink-0">
                <TrendingUp size={14} className="text-cyan-400" />
              </div>
              <div>
                <p className="text-sm font-bold text-white mb-1">Results-Focused</p>
                <p className="text-xs text-neutral-500">Selected for maximum impact on your facial aesthetics</p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="w-8 h-8 rounded-lg bg-purple-500/20 border border-purple-500/30 flex items-center justify-center flex-shrink-0">
                <Clock size={14} className="text-purple-400" />
              </div>
              <div>
                <p className="text-sm font-bold text-white mb-1">Time-Tested</p>
                <p className="text-xs text-neutral-500">Community-verified products with proven track records</p>
              </div>
            </div>
          </div>
        </section>

        {/* Category Filter & Search */}
        <section>
          <SectionHeader title="Browse All Products" />

          {/* Category Pills */}
          <div className="flex flex-wrap gap-2 mb-6">
            {CATEGORIES.map(cat => (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id)}
                className={`px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-wider transition-all border flex items-center gap-2 ${
                  selectedCategory === cat.id
                    ? 'bg-cyan-500 text-black border-cyan-400'
                    : 'bg-neutral-900/50 text-neutral-400 border-white/5 hover:border-white/10 hover:text-white'
                }`}
              >
                {cat.icon}
                {cat.label}
              </button>
            ))}
          </div>

          {/* Search */}
          <div className="relative mb-8">
            <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-neutral-500" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search products..."
              className="w-full pl-11 pr-4 py-3 bg-neutral-900/50 border border-white/5 rounded-xl text-sm text-white placeholder:text-neutral-600 focus:outline-none focus:border-cyan-500/30"
            />
          </div>

          {/* Results Count */}
          <div className="flex items-center justify-between mb-6">
            <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
              {filteredProducts.length} Products
            </p>
          </div>

          {/* Products Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <AnimatePresence mode="popLayout">
              {filteredProducts.map((product, idx) => (
                <ProductCard
                  key={product.id}
                  product={product}
                  rank={selectedCategory === 'all' ? undefined : idx + 1}
                  isRecommended={product.isBaseStack}
                />
              ))}
            </AnimatePresence>
          </div>

          {filteredProducts.length === 0 && (
            <div className="text-center py-16">
              <div className="w-16 h-16 rounded-2xl bg-neutral-900 border border-white/10 flex items-center justify-center mx-auto mb-5">
                <Search size={28} className="text-neutral-600" />
              </div>
              <h3 className="text-lg font-black uppercase tracking-wider text-white mb-2">No Products Found</h3>
              <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600">
                Try adjusting your search or category filter
              </p>
            </div>
          )}
        </section>

        {/* Affiliate Disclosure */}
        <section className="p-6 rounded-2xl bg-neutral-900/40 border border-white/5">
          <p className="text-xs text-neutral-500 leading-relaxed">
            <strong className="text-neutral-400">Affiliate Disclosure:</strong> We may earn a commission when you purchase through our links. This helps support LOOXSMAXXLABS at no extra cost to you. We only recommend products we believe in and have thoroughly researched.
          </p>
        </section>
      </div>
    </TabContent>
  );
}
