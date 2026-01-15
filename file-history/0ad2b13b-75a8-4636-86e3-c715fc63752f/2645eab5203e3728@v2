'use client';

import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, Grid, List } from 'lucide-react';
import { useResults } from '@/contexts/ResultsContext';
import { TabContent } from '../ResultsLayout';
import { MeasurementCard } from '../cards/MeasurementCard';
import { ScoreCircle } from '../shared';
import { FaceOverlay } from '../visualization/FaceOverlay';
import { Ratio, MEASUREMENT_CATEGORIES } from '@/types/results';

// ============================================
// CATEGORY FILTER
// ============================================

interface CategoryFilterProps {
  selectedCategory: string | null;
  onSelect: (category: string | null) => void;
  ratios: Ratio[];
}

function CategoryFilter({ selectedCategory, onSelect, ratios }: CategoryFilterProps) {
  // Get unique categories from ratios
  const categories = useMemo(() => {
    const cats = new Set(ratios.map(r => r.category));
    return Array.from(cats);
  }, [ratios]);

  // Count ratios per category
  const categoryCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    ratios.forEach(r => {
      counts[r.category] = (counts[r.category] || 0) + 1;
    });
    return counts;
  }, [ratios]);

  return (
    <div className="flex flex-wrap gap-2">
      <button
        onClick={() => onSelect(null)}
        className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all ${
          selectedCategory === null
            ? 'bg-cyan-500 text-black'
            : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
        }`}
      >
        All ({ratios.length})
      </button>
      {categories.map(cat => {
        const catConfig = MEASUREMENT_CATEGORIES.find(c =>
          c.name.toLowerCase().includes(cat.toLowerCase()) ||
          cat.toLowerCase().includes(c.name.toLowerCase())
        );
        return (
          <button
            key={cat}
            onClick={() => onSelect(cat)}
            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all ${
              selectedCategory === cat
                ? 'text-black'
                : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
            }`}
            style={selectedCategory === cat ? { backgroundColor: catConfig?.color || '#67e8f9' } : {}}
          >
            {cat} ({categoryCounts[cat] || 0})
          </button>
        );
      })}
    </div>
  );
}

// ============================================
// SEARCH BAR
// ============================================

interface SearchBarProps {
  value: string;
  onChange: (value: string) => void;
}

function SearchBar({ value, onChange }: SearchBarProps) {
  return (
    <div className="relative">
      <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-neutral-500" />
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Search measurements..."
        className="w-full pl-10 pr-4 py-2 bg-neutral-800 border border-neutral-700 rounded-lg text-white placeholder-neutral-500 focus:outline-none focus:border-cyan-500 transition-colors"
      />
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
  const [categoryFilter, setCategoryFilter] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'list' | 'grid'>('list');

  // Select data based on profile type
  const ratios = profileType === 'front' ? frontRatios : sideRatios;
  const score = profileType === 'front' ? frontScore : sideScore;
  const photo = profileType === 'front' ? frontPhoto : sidePhoto;
  const landmarks = profileType === 'front' ? frontLandmarks : sideLandmarks;

  // Filter ratios
  const filteredRatios = useMemo(() => {
    let filtered = ratios;

    if (categoryFilter) {
      filtered = filtered.filter(r => r.category === categoryFilter);
    }

    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(r =>
        r.name.toLowerCase().includes(query) ||
        r.category.toLowerCase().includes(query)
      );
    }

    return filtered;
  }, [ratios, categoryFilter, searchQuery]);

  // Get selected ratio for visualization
  const selectedRatio = ratios.find(r => r.id === selectedVisualizationMetric);

  return (
    <TabContent
      title={`${profileType === 'front' ? 'Front' : 'Side'} Profile Ratios`}
      subtitle={`${ratios.length} measurements analyzed`}
      rightContent={
        <div className="flex items-center gap-3">
          <ScoreCircle score={score} size="md" animate={false} />
        </div>
      }
    >
      <div className="flex flex-col lg:flex-row gap-6">
        {/* Main Content */}
        <div className="flex-1 min-w-0">
          {/* Filters */}
          <div className="mb-6 space-y-4">
            <div className="flex flex-col sm:flex-row gap-4">
              <div className="flex-1">
                <SearchBar value={searchQuery} onChange={setSearchQuery} />
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => setViewMode('list')}
                  className={`p-2 rounded-lg transition-colors ${
                    viewMode === 'list'
                      ? 'bg-cyan-500 text-black'
                      : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
                  }`}
                >
                  <List size={18} />
                </button>
                <button
                  onClick={() => setViewMode('grid')}
                  className={`p-2 rounded-lg transition-colors ${
                    viewMode === 'grid'
                      ? 'bg-cyan-500 text-black'
                      : 'bg-neutral-800 text-neutral-400 hover:bg-neutral-700'
                  }`}
                >
                  <Grid size={18} />
                </button>
              </div>
            </div>

            <CategoryFilter
              selectedCategory={categoryFilter}
              onSelect={setCategoryFilter}
              ratios={ratios}
            />
          </div>

          {/* Results count */}
          <p className="text-sm text-neutral-500 mb-4">
            Showing {filteredRatios.length} of {ratios.length} measurements
          </p>

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
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.95 }}
                  transition={{ duration: 0.2 }}
                >
                  <MeasurementCard
                    ratio={ratio}
                    isExpanded={expandedMeasurementId === ratio.id}
                    onToggle={() => {
                      const isExpanding = expandedMeasurementId !== ratio.id;
                      setExpandedMeasurementId(isExpanding ? ratio.id : null);
                      // Auto-update face preview when expanding
                      if (isExpanding) {
                        setSelectedVisualizationMetric(ratio.id);
                      }
                    }}
                  />
                </motion.div>
              ))}
            </AnimatePresence>
          </motion.div>

          {filteredRatios.length === 0 && (
            <div className="text-center py-12">
              <Search size={48} className="mx-auto text-neutral-700 mb-4" />
              <p className="text-neutral-500">No measurements found matching your criteria</p>
            </div>
          )}
        </div>

        {/* Face Visualization Panel (sticky on desktop) */}
        {photo && (
          <div className="lg:w-[380px] lg:flex-shrink-0">
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
