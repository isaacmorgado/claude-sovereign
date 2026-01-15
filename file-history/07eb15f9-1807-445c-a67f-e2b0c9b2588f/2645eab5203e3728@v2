'use client';

import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, LayoutGrid, LayoutList, Layers, ChevronDown, SlidersHorizontal } from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { TabContent } from '../ResultsLayout';
import { MeasurementCard } from '../cards/MeasurementCard';
import { ScoreCircle } from '../shared';
import { FaceOverlay } from '../visualization/FaceOverlay';
import { Ratio } from '@/types/results';
import { PRIMARY_CATEGORIES, getPrimaryCategory } from '@/lib/taxonomy';

// ============================================
// CATEGORY PILLS (Premium Style)
// ============================================

interface CategoryPillsProps {
  selectedPrimary: string | null;
  selectedSecondary: string | null;
  onSelectPrimary: (primary: string | null) => void;
  onSelectSecondary: (secondary: string | null) => void;
  ratios: Ratio[];
}

function CategoryPills({
  selectedPrimary,
  selectedSecondary,
  onSelectPrimary,
  onSelectSecondary,
  ratios
}: CategoryPillsProps) {
  const primaryCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    PRIMARY_CATEGORIES.forEach(cat => {
      counts[cat.id] = ratios.filter(r => r.taxonomyPrimary === cat.id).length;
    });
    return counts;
  }, [ratios]);

  const secondaryCounts = useMemo(() => {
    if (!selectedPrimary) return {};
    const counts: Record<string, number> = {};
    const primary = getPrimaryCategory(selectedPrimary);
    if (primary?.subcategories) {
      primary.subcategories.forEach(sub => {
        counts[sub.id] = ratios.filter(r =>
          r.taxonomyPrimary === selectedPrimary && r.taxonomySecondary === sub.id
        ).length;
      });
    }
    return counts;
  }, [ratios, selectedPrimary]);

  const primaryCategory = selectedPrimary ? getPrimaryCategory(selectedPrimary) : null;

  const categoryStyles: Record<string, { bg: string; text: string; border: string }> = {
    harmony: { bg: 'bg-cyan-500/15', text: 'text-cyan-400', border: 'border-cyan-500/30' },
    dimorphism: { bg: 'bg-pink-500/15', text: 'text-pink-400', border: 'border-pink-500/30' },
    angularity: { bg: 'bg-orange-500/15', text: 'text-orange-400', border: 'border-orange-500/30' },
    features: { bg: 'bg-violet-500/15', text: 'text-violet-400', border: 'border-violet-500/30' },
  };

  return (
    <div className="space-y-4">
      {/* Primary Categories */}
      <div className="flex flex-wrap gap-2">
        <button
          onClick={() => {
            onSelectPrimary(null);
            onSelectSecondary(null);
          }}
          className={`px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider transition-all ${
            selectedPrimary === null
              ? 'bg-white text-black'
              : 'bg-neutral-900/50 border border-white/5 text-neutral-400 hover:border-white/10'
          }`}
        >
          All <span className="opacity-60 ml-1">{ratios.length}</span>
        </button>
        {PRIMARY_CATEGORIES.map(cat => {
          const count = primaryCounts[cat.id] || 0;
          const isSelected = selectedPrimary === cat.id;
          const style = categoryStyles[cat.id];
          return (
            <button
              key={cat.id}
              onClick={() => {
                onSelectPrimary(isSelected ? null : cat.id);
                onSelectSecondary(null);
              }}
              className={`px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider transition-all ${
                isSelected
                  ? `${style.bg} ${style.text} border ${style.border}`
                  : 'bg-neutral-900/50 border border-white/5 text-neutral-400 hover:border-white/10'
              }`}
              title={cat.description}
            >
              {cat.name} <span className="opacity-60 ml-1">{count}</span>
            </button>
          );
        })}
      </div>

      {/* Subcategories */}
      <AnimatePresence>
        {selectedPrimary && primaryCategory?.subcategories && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="overflow-hidden"
          >
            <div className="flex flex-wrap gap-2 pl-4 border-l-2 border-neutral-800">
              {primaryCategory.subcategories.map(sub => {
                const count = secondaryCounts[sub.id] || 0;
                if (count === 0) return null;
                const isSelected = selectedSecondary === sub.id;
                return (
                  <button
                    key={sub.id}
                    onClick={() => onSelectSecondary(isSelected ? null : sub.id)}
                    className={`px-3 py-1.5 rounded-lg text-[10px] font-bold uppercase tracking-wider transition-all ${
                      isSelected
                        ? 'bg-neutral-700 text-white'
                        : 'bg-neutral-900/30 border border-white/5 text-neutral-500 hover:text-neutral-300'
                    }`}
                    title={sub.description}
                  >
                    {sub.name} <span className="opacity-50">{count}</span>
                  </button>
                );
              })}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

// ============================================
// SEARCH INPUT (Premium Style)
// ============================================

interface SearchInputProps {
  value: string;
  onChange: (value: string) => void;
}

function SearchInput({ value, onChange }: SearchInputProps) {
  return (
    <div className="relative">
      <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-neutral-500" />
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Search measurements..."
        className="w-full pl-11 pr-4 py-3 bg-neutral-900/50 border border-white/5 rounded-2xl text-sm text-white placeholder-neutral-600 focus:outline-none focus:border-cyan-500/50 transition-all font-medium"
      />
    </div>
  );
}

// ============================================
// VIEW TOGGLE (Premium Style)
// ============================================

interface ViewToggleProps {
  view: 'list' | 'grid';
  onChange: (view: 'list' | 'grid') => void;
}

function ViewToggle({ view, onChange }: ViewToggleProps) {
  return (
    <div className="flex bg-neutral-900/50 border border-white/5 rounded-xl p-1">
      <button
        onClick={() => onChange('list')}
        className={`p-2 rounded-lg transition-all ${
          view === 'list'
            ? 'bg-cyan-500 text-black'
            : 'text-neutral-500 hover:text-white'
        }`}
        title="List view"
      >
        <LayoutList size={16} />
      </button>
      <button
        onClick={() => onChange('grid')}
        className={`p-2 rounded-lg transition-all ${
          view === 'grid'
            ? 'bg-cyan-500 text-black'
            : 'text-neutral-500 hover:text-white'
        }`}
        title="Grid view"
      >
        <LayoutGrid size={16} />
      </button>
    </div>
  );
}

// ============================================
// STATS HEADER
// ============================================

interface StatsHeaderProps {
  total: number;
  filtered: number;
  profileType: 'front' | 'side';
}

function StatsHeader({ total, filtered, profileType }: StatsHeaderProps) {
  return (
    <div className="flex items-center gap-3 text-[10px] font-black uppercase tracking-[0.3em] text-neutral-600">
      <span>
        {profileType === 'front' ? 'Frontal' : 'Lateral'} Analysis
      </span>
      <span className="flex-1 h-px bg-neutral-800" />
      <span className="text-neutral-500">
        {filtered === total ? `${total} metrics` : `${filtered} of ${total}`}
      </span>
    </div>
  );
}

// ============================================
// RATIOS TAB (SHARED FOR FRONT/SIDE)
// ============================================

interface RatiosTabProps {
  profileType: 'front' | 'side';
}

export function RatiosTab({ profileType }: RatiosTabProps) {
  const {
    frontRatios,
    sideRatios,
    frontScore,
    sideScore,
    frontPhoto,
    sidePhoto,
    frontLandmarks,
    sideLandmarks,
    expandedMeasurementId,
    setExpandedMeasurementId,
    selectedVisualizationMetric,
    setSelectedVisualizationMetric,
  } = useResults();

  const [searchQuery, setSearchQuery] = useState('');
  const [primaryFilter, setPrimaryFilter] = useState<string | null>(null);
  const [secondaryFilter, setSecondaryFilter] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'list' | 'grid'>('list');
  const [showFilters, setShowFilters] = useState(true);

  const ratios = profileType === 'front' ? frontRatios : sideRatios;
  const score = profileType === 'front' ? frontScore : sideScore;
  const photo = profileType === 'front' ? frontPhoto : sidePhoto;
  const landmarks = profileType === 'front' ? frontLandmarks : sideLandmarks;

  const filteredRatios = useMemo(() => {
    let filtered = ratios;

    if (primaryFilter) {
      filtered = filtered.filter(r => r.taxonomyPrimary === primaryFilter);
    }

    if (secondaryFilter) {
      filtered = filtered.filter(r => r.taxonomySecondary === secondaryFilter);
    }

    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(r =>
        r.name.toLowerCase().includes(query) ||
        r.category.toLowerCase().includes(query)
      );
    }

    return filtered;
  }, [ratios, primaryFilter, secondaryFilter, searchQuery]);

  const selectedRatio = ratios.find(r => r.id === selectedVisualizationMetric);

  return (
    <TabContent
      title={`${profileType === 'front' ? 'Frontal' : 'Lateral'} Ratios`}
      subtitle={`${ratios.length} morphometric measurements analyzed`}
      rightContent={
        <div className="flex items-center gap-4">
          <div className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-xl bg-neutral-900/50 border border-white/5">
            <Layers size={14} className="text-cyan-400" />
            <span className="text-[10px] font-black uppercase tracking-wider text-neutral-400">
              {profileType === 'front' ? 'Front' : 'Side'}
            </span>
          </div>
          <ScoreCircle score={score} size="md" animate={false} />
        </div>
      }
    >
      <div className="flex flex-col lg:flex-row gap-8">
        {/* Main Content */}
        <div className="flex-1 min-w-0 space-y-6">
          {/* Search & View Toggle */}
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <SearchInput value={searchQuery} onChange={setSearchQuery} />
            </div>
            <div className="flex gap-2">
              <button
                onClick={() => setShowFilters(!showFilters)}
                className={`px-4 py-2 rounded-xl text-xs font-bold uppercase tracking-wider transition-all flex items-center gap-2 ${
                  showFilters
                    ? 'bg-cyan-500/15 text-cyan-400 border border-cyan-500/30'
                    : 'bg-neutral-900/50 border border-white/5 text-neutral-400 hover:border-white/10'
                }`}
              >
                <SlidersHorizontal size={14} />
                <span className="hidden sm:inline">Filters</span>
                <ChevronDown size={12} className={`transition-transform ${showFilters ? 'rotate-180' : ''}`} />
              </button>
              <ViewToggle view={viewMode} onChange={setViewMode} />
            </div>
          </div>

          {/* Category Filters */}
          <AnimatePresence>
            {showFilters && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="overflow-hidden"
              >
                <div className="p-6 rounded-2xl bg-neutral-900/30 border border-white/5">
                  <CategoryPills
                    selectedPrimary={primaryFilter}
                    selectedSecondary={secondaryFilter}
                    onSelectPrimary={setPrimaryFilter}
                    onSelectSecondary={setSecondaryFilter}
                    ratios={ratios}
                  />
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Stats Header */}
          <StatsHeader
            total={ratios.length}
            filtered={filteredRatios.length}
            profileType={profileType}
          />

          {/* Ratios List */}
          <motion.div
            className={viewMode === 'grid' ? 'grid grid-cols-1 md:grid-cols-2 gap-4' : 'space-y-3'}
            layout
          >
            <AnimatePresence mode="popLayout">
              {filteredRatios.map((ratio) => (
                <motion.div
                  key={ratio.id}
                  layout
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  transition={{ duration: 0.2 }}
                >
                  <MeasurementCard
                    ratio={ratio}
                    isExpanded={expandedMeasurementId === ratio.id}
                    onToggle={() => {
                      const isExpanding = expandedMeasurementId !== ratio.id;
                      setExpandedMeasurementId(isExpanding ? ratio.id : null);
                      if (isExpanding) {
                        setSelectedVisualizationMetric(ratio.id);
                      }
                    }}
                  />
                </motion.div>
              ))}
            </AnimatePresence>
          </motion.div>

          {/* Empty State */}
          {filteredRatios.length === 0 && (
            <div className="text-center py-20">
              <div className="w-20 h-20 rounded-2xl bg-neutral-900 border border-white/10 flex items-center justify-center mx-auto mb-6">
                <Search size={32} className="text-neutral-700" />
              </div>
              <p className="text-[10px] font-black uppercase tracking-[0.2em] text-neutral-600 mb-2">
                No Results Found
              </p>
              <p className="text-sm text-neutral-500">
                Try adjusting your filters or search query
              </p>
            </div>
          )}
        </div>

        {/* Face Visualization Panel */}
        {photo && (
          <div className="lg:w-[400px] lg:flex-shrink-0">
            <div className="lg:sticky lg:top-6 lg:max-h-[calc(100vh-3rem)]">
              <FaceOverlay
                photo={photo}
                landmarks={landmarks}
                selectedRatio={selectedRatio || null}
                profileType={profileType}
              />
            </div>
          </div>
        )}
      </div>
    </TabContent>
  );
}

// ============================================
// FRONT RATIOS TAB
// ============================================

export function FrontRatiosTab() {
  return <RatiosTab profileType="front" />;
}

// ============================================
// SIDE RATIOS TAB
// ============================================

export function SideRatiosTab() {
  return <RatiosTab profileType="side" />;
}
