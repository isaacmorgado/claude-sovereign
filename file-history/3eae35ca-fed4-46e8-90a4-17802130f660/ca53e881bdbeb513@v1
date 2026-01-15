'use client';

import { useState } from 'react';
import Link from 'next/link';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ArrowLeft,
  BookOpen,
  Ruler,
  FlaskConical,
  Sparkles,
  ChevronDown,
  Triangle,
  Layers,
  Target,
  Zap,
  Shield,
  TrendingUp,
} from 'lucide-react';

// ============================================
// TYPES
// ============================================

interface DocTopic {
  id: string;
  category: string;
  title: string;
  description: string;
  content: string[];
}

// ============================================
// DOCUMENTATION TOPICS - No proprietary math exposed
// ============================================

const DOC_TOPICS: DocTopic[] = [
  // Facial Proportions Category
  {
    id: 'golden-ratio',
    category: 'Facial Proportions',
    title: 'The Golden Ratio in Faces',
    description: 'Understanding phi and its relationship to perceived beauty',
    content: [
      'The golden ratio (phi) has been observed across art, architecture, and nature for millennia. In facial aesthetics, researchers have studied whether faces approximating certain mathematical relationships are perceived as more attractive.',
      'Our analysis examines how your facial proportions compare to population averages and aesthetic ideals documented in peer-reviewed research.',
    ],
  },
  {
    id: 'facial-thirds',
    category: 'Facial Proportions',
    title: 'Facial Thirds Division',
    description: 'Vertical segmentation of the face',
    content: [
      'Classical facial analysis divides the face into three vertical sections: the upper third (hairline to brow), middle third (brow to nose base), and lower third (nose base to chin).',
      'Harmony between these sections contributes to overall facial balance. Our system measures these proportions using advanced landmark detection.',
    ],
  },
  {
    id: 'horizontal-fifths',
    category: 'Facial Proportions',
    title: 'Horizontal Fifths',
    description: 'Lateral facial width analysis',
    content: [
      'The face can be divided into five equal vertical sections when viewed frontally. This classical canon helps assess eye positioning, nose width, and overall facial width distribution.',
      'We analyze how your features align with these traditional proportional guidelines.',
    ],
  },
  // Facial Harmony Category
  {
    id: 'symmetry',
    category: 'Facial Harmony',
    title: 'Bilateral Symmetry',
    description: 'Left-right facial balance assessment',
    content: [
      'Facial symmetry refers to how closely the left and right sides of your face mirror each other. Research consistently shows that greater symmetry correlates with perceived attractiveness.',
      'Our analysis measures multiple points across both sides of your face to calculate symmetry scores for different facial regions.',
    ],
  },
  {
    id: 'proportion',
    category: 'Facial Harmony',
    title: 'Feature Proportion',
    description: 'Size relationships between facial features',
    content: [
      'How features relate to each other in size matters as much as individual measurements. Eyes, nose, mouth, and jaw all contribute to the overall harmony of a face.',
      'We evaluate these relationships using proprietary algorithms calibrated against extensive research data.',
    ],
  },
  {
    id: 'dimorphism',
    category: 'Facial Harmony',
    title: 'Sexual Dimorphism',
    description: 'Gender-specific feature development',
    content: [
      'Male and female faces have distinct characteristics that contribute to attractiveness within each gender. Stronger jaws and brow ridges in males, softer features and larger eyes in females.',
      'Our analysis adjusts expectations based on gender to provide accurate assessments.',
    ],
  },
  // Angular Measurements Category
  {
    id: 'profile-angles',
    category: 'Angular Measurements',
    title: 'Profile Analysis',
    description: 'Side-view angular measurements',
    content: [
      'Profile view reveals critical angles that front-facing photos cannot capture. The relationship between forehead, nose, lips, and chin creates your unique profile silhouette.',
      'We measure key angles from your side profile to assess facial convexity and balance.',
    ],
  },
  {
    id: 'jaw-geometry',
    category: 'Angular Measurements',
    title: 'Jaw Structure',
    description: 'Mandibular angle and definition',
    content: [
      'The angle of your jaw (gonial angle) significantly impacts facial aesthetics. This measurement affects the perceived strength and definition of your lower face.',
      'Our system analyzes jaw geometry from both front and side views for comprehensive assessment.',
    ],
  },
  {
    id: 'eye-angles',
    category: 'Angular Measurements',
    title: 'Eye Aesthetics',
    description: 'Canthal tilt and eye shape analysis',
    content: [
      'The angle at which your eyes sit (canthal tilt) and their overall shape contribute significantly to facial expression and attractiveness.',
      'We evaluate multiple aspects of eye geometry to provide detailed insights.',
    ],
  },
  // Non-Surgical Enhancement Category
  {
    id: 'foundation',
    category: 'Non-Surgical Enhancement',
    title: 'Foundation Practices',
    description: 'Lifestyle factors affecting facial aesthetics',
    content: [
      'Body composition, posture, and overall health significantly impact facial appearance. Optimizing body fat reveals bone structure, while proper posture improves jaw positioning.',
      'These foundational changes can make noticeable improvements before considering any procedures.',
    ],
  },
  {
    id: 'skincare',
    category: 'Non-Surgical Enhancement',
    title: 'Skincare Protocols',
    description: 'Evidence-based skin improvement',
    content: [
      'Consistent skincare routines with proven ingredients improve skin quality, texture, and overall facial appearance. Cleansing, treatment, and sun protection form the foundation.',
      'We recommend personalized skincare approaches based on your specific concerns.',
    ],
  },
  {
    id: 'minimally-invasive',
    category: 'Non-Surgical Enhancement',
    title: 'Minimally Invasive Options',
    description: 'Temporary enhancement procedures',
    content: [
      'Dermal fillers, neuromodulators, and other minimally invasive treatments can enhance facial features with minimal downtime. These temporary solutions allow you to preview potential changes.',
      'Our analysis identifies which areas might benefit most from these treatments.',
    ],
  },
];

const CATEGORIES = [
  { name: 'All', icon: <BookOpen size={14} />, count: DOC_TOPICS.length },
  { name: 'Facial Proportions', icon: <Ruler size={14} />, count: DOC_TOPICS.filter(t => t.category === 'Facial Proportions').length },
  { name: 'Facial Harmony', icon: <Layers size={14} />, count: DOC_TOPICS.filter(t => t.category === 'Facial Harmony').length },
  { name: 'Angular Measurements', icon: <Triangle size={14} />, count: DOC_TOPICS.filter(t => t.category === 'Angular Measurements').length },
  { name: 'Non-Surgical Enhancement', icon: <Sparkles size={14} />, count: DOC_TOPICS.filter(t => t.category === 'Non-Surgical Enhancement').length },
];

// ============================================
// COMPONENTS
// ============================================

function TopicCard({ topic, isExpanded, onToggle }: { topic: DocTopic; isExpanded: boolean; onToggle: () => void }) {
  const categoryColors: Record<string, string> = {
    'Facial Proportions': 'bg-cyan-500/20 text-cyan-400 border-cyan-500/30',
    'Facial Harmony': 'bg-purple-500/20 text-purple-400 border-purple-500/30',
    'Angular Measurements': 'bg-orange-500/20 text-orange-400 border-orange-500/30',
    'Non-Surgical Enhancement': 'bg-green-500/20 text-green-400 border-green-500/30',
  };

  return (
    <motion.div
      layout
      className="bg-neutral-900/60 border border-white/5 rounded-2xl overflow-hidden hover:border-white/10 transition-colors"
    >
      <button
        onClick={onToggle}
        className="w-full p-6 flex items-start gap-4 text-left"
      >
        <div className="w-12 h-12 rounded-xl bg-neutral-800 border border-white/5 flex items-center justify-center flex-shrink-0">
          <BookOpen size={20} className="text-neutral-500" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-3 mb-2">
            <span className={`px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider rounded-full border ${categoryColors[topic.category]}`}>
              {topic.category}
            </span>
          </div>
          <h3 className="text-base font-black uppercase tracking-wide text-white mb-1">
            {topic.title}
          </h3>
          <p className="text-sm text-neutral-500">{topic.description}</p>
        </div>
        <ChevronDown
          size={20}
          className={`text-neutral-500 transition-transform flex-shrink-0 ${isExpanded ? 'rotate-180' : ''}`}
        />
      </button>

      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="overflow-hidden"
          >
            <div className="px-6 pb-6 pt-0">
              <div className="pl-16 space-y-4 border-t border-white/5 pt-4">
                {topic.content.map((paragraph, idx) => (
                  <p key={idx} className="text-sm text-neutral-400 leading-relaxed">
                    {paragraph}
                  </p>
                ))}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

// ============================================
// DOCS PAGE
// ============================================

export default function DocsPage() {
  const [activeCategory, setActiveCategory] = useState('All');
  const [expandedTopic, setExpandedTopic] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const filteredTopics = DOC_TOPICS.filter(topic => {
    const matchesCategory = activeCategory === 'All' || topic.category === activeCategory;
    const matchesSearch = searchQuery === '' ||
      topic.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      topic.description.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  return (
    <main className="min-h-screen bg-neutral-950 text-white">
      {/* Header */}
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 pb-4">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm text-neutral-500 hover:text-white transition-colors"
        >
          <ArrowLeft size={16} />
          <span className="font-medium uppercase tracking-wider">Back to Labs</span>
        </Link>
      </div>

      {/* Hero Section */}
      <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex items-start justify-between gap-8">
          <div>
            <h1 className="text-4xl md:text-5xl font-black tracking-tight mb-4">
              <span className="text-white italic">ANALYSIS </span>
              <span className="text-cyan-400 italic">METHODOLOGY</span>
            </h1>
            <p className="text-sm font-bold uppercase tracking-wider text-neutral-500">
              Understanding our facial analysis framework
            </p>
          </div>
          <div className="hidden md:flex items-center gap-3 bg-neutral-900 border border-cyan-500/30 rounded-xl px-5 py-3">
            <span className="text-2xl font-black text-white">12</span>
            <span className="text-[10px] font-bold uppercase tracking-wider text-neutral-400">Topics</span>
          </div>
        </div>
      </section>

      {/* Our Approach Section */}
      <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-12">
        <div className="bg-neutral-900/60 border border-white/5 rounded-3xl p-8 relative overflow-hidden">
          {/* Background Icon */}
          <div className="absolute right-8 top-1/2 -translate-y-1/2 opacity-5">
            <FlaskConical size={160} strokeWidth={1} />
          </div>

          <div className="relative z-10">
            <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-cyan-400 mb-4">
              Our Approach
            </p>
            <p className="text-xl md:text-2xl font-black italic text-white mb-6 max-w-3xl">
              &ldquo;Facial harmony is not subjective—it is a biometric equilibrium.&rdquo;
            </p>
            <p className="text-sm text-neutral-400 leading-relaxed max-w-3xl mb-8">
              Our analysis is grounded in decades of peer-reviewed research spanning anthropometry,
              maxillofacial surgery, and aesthetic medicine. We use computer vision to identify facial
              landmarks with high precision, then evaluate proportions against established aesthetic canons.
            </p>

            {/* Stats Grid */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {[
                { value: '478', label: 'Facial Landmarks' },
                { value: '70+', label: 'Measurements' },
                { value: '16', label: 'Demographics' },
                { value: '35+', label: 'Research Papers' },
              ].map((stat, idx) => (
                <div key={idx} className="bg-neutral-900/80 border border-white/5 rounded-xl p-4">
                  <span className="text-2xl font-black text-white">{stat.value}</span>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-500 mt-1">
                    {stat.label}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Filter by Category */}
      <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-6">
        <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-neutral-500 mb-4">
          Filter by Category
        </p>
        <div className="flex flex-wrap gap-2">
          {CATEGORIES.map((cat) => (
            <button
              key={cat.name}
              onClick={() => setActiveCategory(cat.name)}
              className={`inline-flex items-center gap-2 px-4 py-2 rounded-full text-xs font-bold uppercase tracking-wider transition-all ${
                activeCategory === cat.name
                  ? 'bg-cyan-500 text-black'
                  : 'bg-neutral-900 border border-white/10 text-neutral-400 hover:border-white/20'
              }`}
            >
              {cat.icon}
              <span>{cat.name}</span>
              <span className={activeCategory === cat.name ? 'text-black/60' : 'text-neutral-600'}>
                ({cat.count})
              </span>
            </button>
          ))}
        </div>
      </section>

      {/* Search */}
      <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-8">
        <div className="relative">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search topics..."
            className="w-full bg-neutral-900/60 border border-white/5 rounded-xl px-5 py-4 text-sm text-white placeholder-neutral-600 focus:outline-none focus:border-cyan-500/30"
          />
        </div>
      </section>

      {/* Topics List */}
      <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <div className="flex items-center justify-between mb-6">
          <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-neutral-500">
            Documentation Topics
          </p>
          <span className="text-xs text-neutral-600">{filteredTopics.length} results</span>
        </div>

        <div className="space-y-3">
          {filteredTopics.map((topic) => (
            <TopicCard
              key={topic.id}
              topic={topic}
              isExpanded={expandedTopic === topic.id}
              onToggle={() => setExpandedTopic(expandedTopic === topic.id ? null : topic.id)}
            />
          ))}
        </div>

        {filteredTopics.length === 0 && (
          <div className="text-center py-16">
            <p className="text-neutral-500">No topics found matching your criteria.</p>
          </div>
        )}
      </section>

      {/* Key Principles Section */}
      <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-neutral-500 mb-6">
          Key Principles
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {[
            {
              icon: <Target size={24} />,
              title: 'Precision',
              description: 'Advanced computer vision identifies facial landmarks with sub-pixel accuracy across diverse lighting conditions.',
              color: 'cyan',
            },
            {
              icon: <Shield size={24} />,
              title: 'Privacy',
              description: 'Your photos are processed locally and never stored. Analysis results are encrypted and belong only to you.',
              color: 'purple',
            },
            {
              icon: <TrendingUp size={24} />,
              title: 'Actionable',
              description: 'Every analysis includes personalized recommendations based on your unique facial geometry and goals.',
              color: 'green',
            },
          ].map((principle, idx) => (
            <div
              key={idx}
              className="bg-neutral-900/60 border border-white/5 rounded-2xl p-6 hover:border-white/10 transition-colors"
            >
              <div className={`w-12 h-12 rounded-xl bg-${principle.color}-500/20 border border-${principle.color}-500/30 flex items-center justify-center mb-4 text-${principle.color}-400`}>
                {principle.icon}
              </div>
              <h3 className="text-sm font-black uppercase tracking-wider text-white mb-2">
                {principle.title}
              </h3>
              <p className="text-xs text-neutral-500 leading-relaxed">
                {principle.description}
              </p>
            </div>
          ))}
        </div>
      </section>

      {/* Disclaimer */}
      <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <div className="bg-amber-500/10 border border-amber-500/20 rounded-2xl p-6">
          <div className="flex items-start gap-4">
            <div className="w-10 h-10 rounded-xl bg-amber-500/20 border border-amber-500/30 flex items-center justify-center flex-shrink-0">
              <Zap size={18} className="text-amber-400" />
            </div>
            <div>
              <h4 className="text-sm font-black uppercase tracking-wider text-white mb-2">
                Important Disclaimer
              </h4>
              <p className="text-xs text-neutral-400 leading-relaxed">
                This documentation is for educational purposes only. Our analysis provides insights based on
                established research but should not be considered medical advice. Always consult qualified
                healthcare professionals before making decisions about cosmetic procedures. Individual results
                vary significantly based on genetics, age, and other factors.
              </p>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
