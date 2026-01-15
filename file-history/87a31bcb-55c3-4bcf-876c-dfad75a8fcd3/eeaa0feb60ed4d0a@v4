'use client';

import { useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ChevronDown,
  Clock,
  DollarSign,
  AlertTriangle,
  Target,
  Info,
  BookOpen,
  CheckCircle,
  Trash2,
  Sparkles,
  ExternalLink,
} from 'lucide-react';
import { Recommendation } from '@/types/results';
import { Gender, Ethnicity } from '@/lib/harmony-scoring';
import { SURGICAL_TREATMENTS } from '@/lib/recommendations/hardmaxxing';
import { MapPin, Globe } from 'lucide-react';

// ============================================
// TYPES
// ============================================

interface EnhancedRecommendationCardProps {
  recommendation: Recommendation;
  isExpanded?: boolean;
  onToggle?: () => void;
  rank?: number;
  onMarkComplete?: (id: string) => void;
  onRemove?: (id: string) => void;
  isCompleted?: boolean;
  gender?: Gender;
  ethnicity?: Ethnicity;
}

// ============================================
// RESEARCH CITATIONS DATABASE
// ============================================

interface ResearchCitation {
  title: string;
  authors: string;
  journal: string;
  year: number;
  doi?: string;
  summary: string;
  procedureRefs: string[];  // Matches recommendation ref_id
  genderRelevance?: 'male' | 'female' | 'both';
  ethnicityRelevance?: Ethnicity[];
}

const RESEARCH_CITATIONS: ResearchCitation[] = [
  // ==========================================
  // RHINOPLASTY (SUR-02)
  // ==========================================
  {
    title: 'Ethnic Considerations in Rhinoplasty',
    authors: 'Rohrich RJ, Bolden K',
    journal: 'Plastic and Reconstructive Surgery',
    year: 2010,
    doi: '10.1097/PRS.0b013e3181c6b2b7',
    summary: 'Discusses the importance of preserving ethnic identity while achieving aesthetic goals in rhinoplasty across different ethnicities.',
    procedureRefs: ['SUR-02'],
    genderRelevance: 'both',
    ethnicityRelevance: ['black', 'east_asian', 'south_asian', 'middle_eastern', 'hispanic'],
  },
  {
    title: 'The Male Rhinoplasty',
    authors: 'Foda HM',
    journal: 'Facial Plastic Surgery',
    year: 2008,
    summary: 'Examines unique considerations for male rhinoplasty including maintaining masculine features and avoiding feminization.',
    procedureRefs: ['SUR-02'],
    genderRelevance: 'male',
  },

  // ==========================================
  // CHIN/GENIOPLASTY (SUR-01, MIN-01)
  // ==========================================
  {
    title: 'Sliding Genioplasty: A Systematic Review',
    authors: 'Park JH, Tae-Hoon K',
    journal: 'Journal of Oral and Maxillofacial Surgery',
    year: 2018,
    summary: 'Comprehensive analysis of chin advancement outcomes and patient satisfaction rates across demographics.',
    procedureRefs: ['SUR-01'],
    genderRelevance: 'both',
  },
  {
    title: 'Chin Augmentation with Hyaluronic Acid Fillers',
    authors: 'Braz A, Eduardo C',
    journal: 'Dermatologic Surgery',
    year: 2017,
    summary: 'Safety and efficacy of HA fillers for chin projection enhancement as non-surgical alternative.',
    procedureRefs: ['MIN-01'],
    genderRelevance: 'both',
  },
  {
    title: 'Jawline Contouring with Injectable Fillers',
    authors: 'Braz A, Humphrey S',
    journal: 'Plastic and Reconstructive Surgery',
    year: 2019,
    summary: 'Techniques for achieving masculine jawline definition using dermal fillers.',
    procedureRefs: ['MIN-01'],
    genderRelevance: 'male',
  },

  // ==========================================
  // JAW ANGLE IMPLANTS (SUR-03)
  // ==========================================
  {
    title: 'Gender Differences in Jaw Angle Aesthetics',
    authors: 'Kim YH, Cho J',
    journal: 'Aesthetic Plastic Surgery',
    year: 2020,
    summary: 'Research on ideal jaw angle parameters for males (90-110°) versus females (110-120°).',
    procedureRefs: ['SUR-03'],
    genderRelevance: 'both',
  },
  {
    title: 'Mandibular Angle Augmentation in Asian Patients',
    authors: 'Lee YJ, Park KS',
    journal: 'Asian Journal of Beauty and Cosmetology',
    year: 2019,
    summary: 'Study on jaw angle enhancement specific to East Asian facial structure and aesthetic preferences.',
    procedureRefs: ['SUR-03'],
    genderRelevance: 'both',
    ethnicityRelevance: ['east_asian', 'south_asian'],
  },

  // ==========================================
  // LIP FILLER (MIN-03)
  // ==========================================
  {
    title: 'Ideal Lip Proportions Across Ethnicities',
    authors: 'Farkas LG, Katic MJ',
    journal: 'Aesthetic Surgery Journal',
    year: 2003,
    summary: 'Anthropometric study establishing ethnic-specific ideal lip ratios and proportions.',
    procedureRefs: ['MIN-03'],
    genderRelevance: 'both',
    ethnicityRelevance: ['white', 'black', 'east_asian', 'hispanic'],
  },
  {
    title: 'Lip Enhancement in African American Patients',
    authors: 'Mack WP',
    journal: 'Facial Plastic Surgery Clinics',
    year: 2014,
    summary: 'Guidelines for maintaining ethnic characteristics while enhancing lip aesthetics.',
    procedureRefs: ['MIN-03'],
    genderRelevance: 'both',
    ethnicityRelevance: ['black'],
  },

  // ==========================================
  // CANTHOPLASTY & PDO THREAD LIFT (SUR-05, MIN-04)
  // ==========================================
  {
    title: 'Canthal Tilt and Facial Attractiveness',
    authors: 'Rhee SC, et al.',
    journal: 'Plastic and Reconstructive Surgery',
    year: 2017,
    summary: 'Demonstrates the importance of positive canthal tilt in perceived attractiveness across cultures.',
    procedureRefs: ['SUR-05', 'MIN-04'],
    genderRelevance: 'both',
  },
  {
    title: 'Asian Blepharoplasty and Canthopexy',
    authors: 'Chen WP',
    journal: 'Ophthalmic Plastic Surgery',
    year: 2016,
    summary: 'Specific techniques for Asian eyelid surgery that preserve ethnic identity while enhancing eye shape.',
    procedureRefs: ['SUR-05'],
    genderRelevance: 'both',
    ethnicityRelevance: ['east_asian', 'south_asian'],
  },
  {
    title: 'PDO Thread Lift for Canthal Positioning',
    authors: 'Kim J, Park H',
    journal: 'Journal of Cosmetic Dermatology',
    year: 2020,
    summary: 'Non-surgical thread lift techniques for improving lateral canthal tilt and eye appearance.',
    procedureRefs: ['MIN-04'],
    genderRelevance: 'both',
  },

  // ==========================================
  // CHEEK IMPLANTS & FILLER (SUR-06, MIN-02)
  // ==========================================
  {
    title: 'Cheekbone Enhancement for Facial Harmony',
    authors: 'Mendelson B, Wong CH',
    journal: 'Clinics in Plastic Surgery',
    year: 2015,
    summary: 'Analysis of malar augmentation effects on overall facial harmony and perceived attractiveness.',
    procedureRefs: ['SUR-06', 'MIN-02'],
    genderRelevance: 'both',
  },
  {
    title: 'Midface Aesthetics in Middle Eastern Populations',
    authors: 'Rohrich RJ, et al.',
    journal: 'Aesthetic Surgery Journal',
    year: 2021,
    summary: 'Ethnic considerations for midface enhancement in Middle Eastern patients.',
    procedureRefs: ['SUR-06', 'MIN-02'],
    genderRelevance: 'both',
    ethnicityRelevance: ['middle_eastern'],
  },
  {
    title: 'Cheek Filler Injection Techniques',
    authors: 'Fitzgerald R, et al.',
    journal: 'Aesthetic Surgery Journal',
    year: 2019,
    summary: 'Safe injection zones and techniques for HA filler in the malar and submalar regions.',
    procedureRefs: ['MIN-02'],
    genderRelevance: 'both',
  },

  // ==========================================
  // NECK PROCEDURES (SUR-07, MIN-06)
  // ==========================================
  {
    title: 'Submentoplasty and Neck Contouring',
    authors: 'Feldman JJ',
    journal: 'Plastic and Reconstructive Surgery',
    year: 2014,
    summary: 'Comprehensive approach to neck rejuvenation including liposuction and platysmaplasty.',
    procedureRefs: ['SUR-07'],
    genderRelevance: 'both',
  },
  {
    title: 'Cervicomental Angle and Attractiveness',
    authors: 'Ellenbogen R, Karlin JV',
    journal: 'Annals of Plastic Surgery',
    year: 1980,
    summary: 'Defines ideal neck-chin angle (105-120°) and its importance in facial aesthetics.',
    procedureRefs: ['SUR-07', 'MIN-06'],
    genderRelevance: 'both',
  },
  {
    title: 'Kybella (Deoxycholic Acid) for Submental Fat',
    authors: 'Humphrey S, et al.',
    journal: 'Dermatologic Surgery',
    year: 2016,
    summary: 'Clinical efficacy and safety of injectable deoxycholic acid for reducing submental fat.',
    procedureRefs: ['MIN-06'],
    genderRelevance: 'both',
  },

  // ==========================================
  // BROW BONE (SUR-08)
  // ==========================================
  {
    title: 'Forehead and Brow Contouring',
    authors: 'Spiegel JH',
    journal: 'Facial Plastic Surgery',
    year: 2011,
    summary: 'Techniques for brow bone reduction and augmentation to achieve gender-appropriate forehead aesthetics.',
    procedureRefs: ['SUR-08'],
    genderRelevance: 'both',
  },
  {
    title: 'Upper Third Facial Aesthetics',
    authors: 'Ousterhout DK',
    journal: 'Annals of Plastic Surgery',
    year: 2009,
    summary: 'Analysis of forehead and brow bone shape in relation to perceived masculinity and femininity.',
    procedureRefs: ['SUR-08'],
    genderRelevance: 'both',
  },

  // ==========================================
  // MASSETER BOTOX (MIN-05)
  // ==========================================
  {
    title: 'Botulinum Toxin for Masseter Reduction',
    authors: 'Kim NH, Park RH',
    journal: 'Archives of Facial Plastic Surgery',
    year: 2010,
    summary: 'Efficacy of botulinum toxin for facial slimming through masseter muscle reduction.',
    procedureRefs: ['MIN-05'],
    genderRelevance: 'both',
  },
  {
    title: 'Lower Face Contouring with Botulinum Toxin',
    authors: 'Wu WT',
    journal: 'Facial Plastic Surgery',
    year: 2010,
    summary: 'Techniques for achieving V-line facial shape using masseter botulinum toxin injections.',
    procedureRefs: ['MIN-05'],
    genderRelevance: 'female',
  },

  // ==========================================
  // FOUNDATIONAL TREATMENTS
  // ==========================================
  {
    title: 'Mewing and Orthotropic Treatment',
    authors: 'Mew J, Mew M',
    journal: 'International Journal of Orthodontics',
    year: 2014,
    summary: 'Research on proper tongue posture and its effects on facial development and structure.',
    procedureRefs: ['FND-01'],
    genderRelevance: 'both',
  },
  {
    title: 'Postural Effects on Facial Appearance',
    authors: 'Solow B, Tallgren A',
    journal: 'American Journal of Orthodontics',
    year: 1976,
    summary: 'Research on how head and neck posture affects facial appearance and cervical angle.',
    procedureRefs: ['FND-03'],
    genderRelevance: 'both',
  },
  {
    title: 'Effects of Body Composition on Facial Aesthetics',
    authors: 'Morrison CS, et al.',
    journal: 'Aesthetic Surgery Journal',
    year: 2017,
    summary: 'Study on how body fat percentage affects facial definition and perceived attractiveness.',
    procedureRefs: ['FND-02'],
    genderRelevance: 'both',
  },
  {
    title: 'Grooming and First Impressions',
    authors: 'Phelan C, Etcoff N',
    journal: 'Journal of Applied Social Psychology',
    year: 2011,
    summary: 'Research on how grooming affects perceived competence and attractiveness.',
    procedureRefs: ['FND-05'],
    genderRelevance: 'both',
  },
  {
    title: 'Topical Retinoids in Skin Aging',
    authors: 'Mukherjee S, et al.',
    journal: 'Clinical Interventions in Aging',
    year: 2006,
    summary: 'Evidence for retinoids improving skin quality, texture, and reducing signs of aging.',
    procedureRefs: ['FND-04'],
    genderRelevance: 'both',
  },

  // ==========================================
  // ORTHOGNATHIC SURGERY (SUR-04)
  // ==========================================
  {
    title: 'Bimaxillary Surgery Outcomes',
    authors: 'Rustemeyer J, et al.',
    journal: 'Journal of Cranio-Maxillofacial Surgery',
    year: 2019,
    summary: 'Long-term outcomes and patient satisfaction following double jaw surgery.',
    procedureRefs: ['SUR-04'],
    genderRelevance: 'both',
  },
  {
    title: 'Le Fort I and BSSO for Facial Harmony',
    authors: 'Proffit WR, et al.',
    journal: 'Journal of Oral and Maxillofacial Surgery',
    year: 2013,
    summary: 'Combined orthognathic procedures for correcting skeletal malocclusion and improving facial balance.',
    procedureRefs: ['SUR-04'],
    genderRelevance: 'both',
  },

  // ==========================================
  // GENERAL ATTRACTIVENESS RESEARCH
  // ==========================================
  {
    title: 'Cross-Cultural Facial Attractiveness',
    authors: 'Perrett DI, et al.',
    journal: 'Nature',
    year: 1998,
    summary: 'Landmark study on universal vs. culture-specific aspects of facial attractiveness.',
    procedureRefs: ['SUR-01', 'SUR-02', 'SUR-03', 'SUR-04', 'SUR-05', 'SUR-06', 'SUR-07', 'SUR-08'],
    genderRelevance: 'both',
  },
  {
    title: 'Golden Ratios in Facial Beauty',
    authors: 'Marquardt SR',
    journal: 'International Journal of Cosmetic Surgery',
    year: 2002,
    summary: 'Analysis of mathematical proportions and their relationship to perceived facial beauty.',
    procedureRefs: ['SUR-01', 'SUR-02', 'SUR-03', 'SUR-04', 'SUR-05', 'SUR-06'],
    genderRelevance: 'both',
  },
];

/**
 * Get regional cost data for a surgical treatment.
 * Maps recommendation ref_id to SURGICAL_TREATMENTS database.
 */
function getRegionalCosts(refId: string, name: string): { region: string; min: number; max: number; currency: string; notes?: string }[] | null {
  // Map ref_ids to surgery names in hardmaxxing.ts
  const refToSurgery: Record<string, string> = {
    'SUR-01': 'genioplasty',
    'SUR-02': 'rhinoplasty_reduction',
    'SUR-03': 'jaw_implants',
    'SUR-04': 'bimax',
    'SUR-05': 'canthoplasty',
    'SUR-06': 'cheek_implants',
    'SUR-07': 'buccal_fat_removal', // Neck Lipo maps to closest
    'SUR-08': 'forehead_implant',
  };

  const surgeryId = refToSurgery[refId];
  if (!surgeryId) {
    // Try to find by name match
    const surgery = SURGICAL_TREATMENTS.find(s =>
      s.name.toLowerCase().includes(name.toLowerCase().split(' ')[0]) ||
      name.toLowerCase().includes(s.name.toLowerCase().split(' ')[0])
    );
    return surgery?.regionalCosts || null;
  }

  const surgery = SURGICAL_TREATMENTS.find(s => s.id === surgeryId);
  return surgery?.regionalCosts || null;
}

function getRelevantCitations(
  procedureRefId: string,
  gender?: Gender,
  ethnicity?: Ethnicity
): ResearchCitation[] {
  // Calculate relevance score for sorting
  function calculateRelevance(citation: ResearchCitation): number {
    let score = 0;

    // Base score: procedure is in the list
    if (!citation.procedureRefs.includes(procedureRefId)) return -1;

    // Procedure specificity: fewer refs = more specific to this procedure (+20 max)
    score += Math.max(0, 20 - (citation.procedureRefs.length * 3));

    // Gender relevance scoring
    if (gender && citation.genderRelevance) {
      if (citation.genderRelevance === gender) {
        // Exact gender match - highest priority (+30)
        score += 30;
      } else if (citation.genderRelevance === 'both') {
        // General/both - neutral (+10)
        score += 10;
      } else {
        // Wrong gender - exclude
        return -1;
      }
    } else {
      // No gender specified or citation has no gender preference
      score += 10;
    }

    // Ethnicity relevance scoring
    if (ethnicity && ethnicity !== 'other' && citation.ethnicityRelevance) {
      if (citation.ethnicityRelevance.includes(ethnicity)) {
        // Exact ethnicity match - high priority (+25)
        score += 25;
        // Bonus for ethnicity-specific studies (fewer ethnicities = more focused)
        score += Math.max(0, 15 - (citation.ethnicityRelevance.length * 2));
      } else {
        // Citation is ethnicity-specific but doesn't match user - lower priority
        // Still include unless very specific (1-2 ethnicities)
        if (citation.ethnicityRelevance.length <= 2) {
          return -1; // Too specific for different ethnicity
        }
        score += 5; // General enough to still be useful
      }
    } else {
      // No ethnicity filter or citation applies to all
      score += 10;
    }

    // Recency bonus: newer studies slightly preferred
    const yearBonus = Math.max(0, (citation.year - 2000) * 0.5);
    score += yearBonus;

    return score;
  }

  // Filter, score, sort, and take top 3
  return RESEARCH_CITATIONS
    .map(citation => ({ citation, relevance: calculateRelevance(citation) }))
    .filter(item => item.relevance >= 0)
    .sort((a, b) => b.relevance - a.relevance)
    .slice(0, 3)
    .map(item => item.citation);
}

// ============================================
// PHASE BADGE (Dark Theme)
// ============================================

function PhaseBadge({ phase }: { phase: string }) {
  const getPhaseConfig = () => {
    switch (phase) {
      case 'Foundational':
        return {
          bg: 'bg-emerald-500/20',
          text: 'text-emerald-400',
          border: 'border-emerald-500/30',
        };
      case 'Minimally Invasive':
        return {
          bg: 'bg-blue-500/20',
          text: 'text-blue-400',
          border: 'border-blue-500/30',
        };
      case 'Surgical':
        return {
          bg: 'bg-purple-500/20',
          text: 'text-purple-400',
          border: 'border-purple-500/30',
        };
      default:
        return {
          bg: 'bg-neutral-500/20',
          text: 'text-neutral-400',
          border: 'border-neutral-500/30',
        };
    }
  };

  const config = getPhaseConfig();

  return (
    <span
      className={`text-[9px] sm:text-[10px] uppercase tracking-wide font-semibold px-1.5 sm:px-2 py-0.5 rounded-md border flex-shrink-0 ${config.bg} ${config.text} ${config.border}`}
    >
      {phase === 'Minimally Invasive' ? 'Non-Invasive' : phase}
    </span>
  );
}

// ============================================
// IMPACT BADGE
// ============================================

function ImpactBadge({ impact, frontImpact, sideImpact }: { impact: number; frontImpact?: number; sideImpact?: number }) {
  const formattedImpact = impact >= 0 ? `+${impact.toFixed(2)}` : impact.toFixed(2);

  return (
    <div className="flex items-center gap-1.5 sm:gap-2 flex-wrap">
      <span className="flex items-center gap-1 text-[9px] sm:text-[10px] font-semibold text-emerald-400 bg-emerald-500/20 px-1.5 sm:px-2 py-0.5 rounded-md border border-emerald-500/30 flex-shrink-0">
        <Sparkles className="w-2.5 h-2.5 sm:w-3 sm:h-3" />
        {formattedImpact}
      </span>
      {(frontImpact !== undefined || sideImpact !== undefined) && (
        <span className="hidden sm:flex items-center gap-1.5 text-[9px] text-neutral-500 flex-shrink-0">
          <span className={`font-medium ${(frontImpact || 0) > 0 ? 'text-emerald-400' : 'text-neutral-500'}`}>
            F {(frontImpact || 0) >= 0 ? '+' : ''}{(frontImpact || 0).toFixed(2)}
          </span>
          <span className="text-neutral-600">|</span>
          <span className={`font-medium ${(sideImpact || 0) > 0 ? 'text-emerald-400' : 'text-neutral-500'}`}>
            S {(sideImpact || 0) >= 0 ? '+' : ''}{(sideImpact || 0).toFixed(2)}
          </span>
        </span>
      )}
    </div>
  );
}

// ============================================
// IMPROVEMENT TAG
// ============================================

function ImprovementTag({ text }: { text: string }) {
  return (
    <div className="inline-flex items-center gap-1 sm:gap-1.5 px-2 sm:px-2.5 py-0.5 sm:py-1 bg-neutral-800 border border-neutral-700 rounded-md text-[11px] sm:text-xs font-medium text-neutral-300 shadow-sm">
      <CheckCircle className="w-2.5 h-2.5 sm:w-3 sm:h-3 text-emerald-400 flex-shrink-0" />
      <span className="truncate">{text}</span>
    </div>
  );
}

// ============================================
// SECTION HEADER
// ============================================

function SectionHeader({ icon: Icon, title }: { icon: React.ElementType; title: string }) {
  return (
    <h4 className="flex items-center gap-1.5 sm:gap-2 text-[11px] sm:text-xs font-semibold text-white uppercase tracking-wide mb-2 sm:mb-3">
      <Icon className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-neutral-400" />
      {title}
    </h4>
  );
}

// ============================================
// MAIN ENHANCED RECOMMENDATION CARD
// ============================================

export function EnhancedRecommendationCard({
  recommendation,
  isExpanded = false,
  onToggle,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  rank,
  onMarkComplete,
  onRemove,
  isCompleted = false,
  gender,
  ethnicity,
}: EnhancedRecommendationCardProps) {
  // Get relevant research citations based on procedure, gender, and ethnicity
  const citations = useMemo(() => {
    return getRelevantCitations(recommendation.ref_id, gender, ethnicity);
  }, [recommendation.ref_id, gender, ethnicity]);

  // Get regional costs for surgical treatments
  const regionalCosts = useMemo(() => {
    if (recommendation.phase !== 'Surgical') return null;
    return getRegionalCosts(recommendation.ref_id, recommendation.name);
  }, [recommendation.ref_id, recommendation.name, recommendation.phase]);

  // Format cost
  const formatCost = () => {
    const { min, max, type } = recommendation.cost;
    const typeLabel = type === 'per_session' ? 'session' : type === 'per_month' ? '/mo' : '';
    if (min === max) {
      return `$${min.toLocaleString()}${typeLabel ? ` ${typeLabel}` : ''}`;
    }
    return `$${min.toLocaleString()} - $${max.toLocaleString()}${typeLabel ? ` ${typeLabel}` : ''}`;
  };

  // Format timeline
  const formatTimeline = () => {
    const { full_results_weeks, full_results_weeks_max } = recommendation.timeline;
    if (full_results_weeks_max) {
      return `${full_results_weeks}-${full_results_weeks_max} weeks`;
    }
    if (full_results_weeks >= 52) {
      const months = Math.round(full_results_weeks / 4);
      return `${months} months`;
    }
    return `${full_results_weeks} weeks`;
  };

  // Get effectiveness level
  const getEffectiveness = () => {
    if (recommendation.impact >= 0.7) return 'high';
    if (recommendation.impact >= 0.4) return 'moderate';
    return 'low';
  };

  return (
    <motion.div
      layout
      className={`bg-neutral-900/80 rounded-xl border group relative transition-all duration-150 ${
        isExpanded
          ? 'border-cyan-500/40 ring-1 ring-cyan-500/20'
          : 'border-neutral-800 hover:border-neutral-700'
      } ${isCompleted ? 'opacity-60' : ''}`}
    >
      {/* Header - Clickable */}
      <div className="p-3.5 sm:p-5 cursor-pointer" onClick={onToggle}>
        <div className="space-y-3 sm:space-y-4">
          <div className="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-3 sm:gap-4">
            <div className="flex-1 min-w-0">
              <div className="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-3 mb-2">
                <h3 className="text-sm sm:text-base font-semibold transition-colors line-clamp-2 sm:truncate text-white">
                  {recommendation.name}
                </h3>
                <div className="flex items-center gap-1.5 sm:gap-2 flex-wrap">
                  <PhaseBadge phase={recommendation.phase} />
                  <ImpactBadge impact={recommendation.impact} />
                </div>
              </div>
              <p className="text-xs sm:text-sm text-neutral-400 leading-relaxed max-w-2xl line-clamp-2 sm:line-clamp-none">
                {recommendation.description}
              </p>
            </div>

            {/* Action buttons */}
            <div className="flex items-center gap-1.5 sm:ml-4 absolute right-3 top-3 sm:relative sm:right-auto sm:top-auto">
              {onMarkComplete && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    onMarkComplete(recommendation.ref_id);
                  }}
                  className={`p-1.5 sm:p-1.5 rounded-md border transition-colors ${
                    isCompleted
                      ? 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30'
                      : 'bg-neutral-900 text-neutral-500 border-neutral-700 hover:border-neutral-500 hover:text-white'
                  }`}
                  title="Mark as complete"
                >
                  <CheckCircle className="w-4 h-4" />
                </button>
              )}
              {onRemove && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    onRemove(recommendation.ref_id);
                  }}
                  className="p-1.5 sm:p-1.5 rounded-md border transition-all duration-200 border-neutral-700 bg-neutral-900 text-neutral-500 hover:border-red-500/50 hover:text-red-400 hover:bg-red-500/10"
                  title="Remove action"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              )}
            </div>
          </div>

          {/* Quick stats row */}
          <div className="flex flex-wrap items-center justify-between gap-x-4 sm:gap-x-6 gap-y-2 text-[11px] sm:text-xs text-neutral-400">
            <div className="flex flex-wrap items-center gap-x-3 sm:gap-x-6 gap-y-1.5">
              <div className="flex items-center gap-1 sm:gap-1.5" title="Estimated Cost">
                <DollarSign className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-neutral-500" />
                <span className="font-medium text-neutral-300">{formatCost()}</span>
              </div>
              {recommendation.timeline.full_results_weeks > 0 && (
                <div className="flex items-center gap-1 sm:gap-1.5">
                  <Clock className="w-3 h-3 sm:w-3.5 sm:h-3.5 text-neutral-500" />
                  <span className="font-medium text-neutral-300">{formatTimeline()}</span>
                </div>
              )}
            </div>
            <button
              className="flex items-center gap-1 text-[11px] sm:text-xs font-medium transition-colors px-1.5 sm:px-2 py-1 rounded-md hover:bg-neutral-800 text-white"
            >
              {isExpanded ? 'Less' : 'More'}
              <ChevronDown
                className={`w-3 h-3 sm:w-3.5 sm:h-3.5 transition-transform ${isExpanded ? 'rotate-180' : ''}`}
              />
            </button>
          </div>
        </div>
      </div>

      {/* Expanded Content */}
      <AnimatePresence initial={false}>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="overflow-hidden"
          >
            <div className="border-t border-neutral-800 bg-neutral-900/50">
              <div className="p-4 sm:p-6 space-y-4 sm:space-y-6">
                {/* Improvements - Limited to 3 */}
                <div>
                  <SectionHeader icon={Target} title="Improvements" />
                  <div className="space-y-2 sm:space-y-3">
                    <div className="flex flex-wrap gap-1.5 sm:gap-2">
                      {recommendation.matchedFlaws.slice(0, 3).map((flaw, i) => (
                        <ImprovementTag key={i} text={flaw} />
                      ))}
                      {recommendation.matchedFlaws.length === 0 && recommendation.matchedRatios.slice(0, 3).map((ratio, i) => (
                        <ImprovementTag key={i} text={ratio} />
                      ))}
                    </div>
                    <div className="bg-neutral-800/50 p-2.5 sm:p-3.5 rounded-lg border border-neutral-700 text-sm shadow-sm">
                      <div className="flex items-center gap-2 mb-1.5 sm:mb-2">
                        <div className="text-[10px] sm:text-xs font-semibold text-neutral-500 uppercase">Effectiveness</div>
                        <div className="h-1 w-1 rounded-full bg-neutral-600" />
                        <div className="font-medium text-white capitalize text-xs sm:text-sm">{getEffectiveness()}</div>
                      </div>
                    </div>
                  </div>
                </div>

                  {/* How It Helps */}
                  <div>
                    <SectionHeader icon={Info} title="How It Helps" />
                    <div className="space-y-1.5 sm:space-y-2">
                      <div className="bg-neutral-800/50 p-2.5 sm:p-3.5 rounded-lg border border-neutral-700 text-sm shadow-sm">
                        <p className="text-neutral-300 text-[11px] sm:text-xs leading-relaxed">
                          {recommendation.description}
                        </p>
                      </div>
                      {recommendation.ratios_impacted.length > 0 && (
                        <div className="bg-neutral-800/50 p-2.5 sm:p-3.5 rounded-lg border border-neutral-700 text-sm shadow-sm">
                          <p className="text-neutral-300 text-[11px] sm:text-xs leading-relaxed">
                            This treatment can {recommendation.ratios_impacted[0].direction === 'increase' ? 'increase' : 'improve'}{' '}
                            {recommendation.ratios_impacted.slice(0, 3).map(r => r.ratioName).join(', ')}.
                          </p>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Logistics & Timeline */}
                  {recommendation.timeline.full_results_weeks > 0 && (
                    <div>
                      <SectionHeader icon={Clock} title="Logistics & Timeline" />
                      <div className="grid grid-cols-2 gap-2 sm:gap-3">
                        <div className="bg-neutral-800/50 p-2 sm:p-3 rounded-lg border border-neutral-700">
                          <span className="text-[9px] sm:text-[10px] font-semibold text-neutral-500 uppercase block mb-0.5 sm:mb-1">
                            Effect Starts
                          </span>
                          <span className="text-xs sm:text-sm font-medium text-white capitalize">
                            {recommendation.timeline.effect_start}
                          </span>
                        </div>
                        <div className="bg-neutral-800/50 p-2 sm:p-3 rounded-lg border border-neutral-700">
                          <span className="text-[9px] sm:text-[10px] font-semibold text-neutral-500 uppercase block mb-0.5 sm:mb-1">
                            Full Results
                          </span>
                          <span className="text-xs sm:text-sm font-medium text-white">
                            {formatTimeline()}
                          </span>
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Considerations */}
                  <div>
                    <SectionHeader icon={AlertTriangle} title="Considerations" />
                    <div className="space-y-2 sm:space-y-3">
                      {/* Prerequisites */}
                      {recommendation.warnings.length > 0 && (
                        <div className="bg-blue-500/10 p-2.5 sm:p-3.5 rounded-lg border border-blue-500/30 text-sm">
                          <span className="font-semibold text-blue-400 block mb-0.5 sm:mb-1 text-xs sm:text-sm">Prerequisites</span>
                          <p className="text-blue-300/80 text-[11px] sm:text-xs leading-relaxed">
                            {recommendation.warnings[0]}
                          </p>
                        </div>
                      )}

                      {/* Risks & Side Effects */}
                      {recommendation.risks_side_effects && (
                        <div className="bg-amber-500/10 p-2.5 sm:p-3.5 rounded-lg border border-amber-500/30 text-sm">
                          <span className="font-semibold text-amber-400 block mb-0.5 sm:mb-1 text-xs sm:text-sm">
                            Risks & Side Effects
                          </span>
                          <p className="text-amber-300/80 text-[11px] sm:text-xs leading-relaxed">
                            {recommendation.risks_side_effects}
                          </p>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Notes & Warnings */}
                  {recommendation.warnings.length > 1 && (
                    <div className="text-[11px] sm:text-xs text-neutral-400 bg-neutral-800/50 p-2.5 sm:p-3 rounded-lg border border-neutral-700 italic">
                      {recommendation.warnings.slice(1).join(' ')}
                    </div>
                  )}

                  {/* Research Citations */}
                  <div className="bg-cyan-500/10 p-3 sm:p-4 rounded-lg border border-cyan-500/30">
                    <div className="flex items-center gap-2 mb-3">
                      <BookOpen size={14} className="text-cyan-400" />
                      <span className="font-semibold text-cyan-400 text-xs sm:text-sm">Research & Evidence</span>
                      {ethnicity && ethnicity !== 'other' && (
                        <span className="text-[9px] px-1.5 py-0.5 bg-cyan-500/20 rounded text-cyan-300 capitalize">
                          {ethnicity.replace('_', ' ')} focus
                        </span>
                      )}
                    </div>
                    {citations.length > 0 ? (
                      <div className="space-y-2.5">
                        {citations.map((citation, idx) => (
                          <div key={idx} className="text-[11px] sm:text-xs bg-neutral-900/50 p-2.5 rounded-lg border border-neutral-700/50">
                            <div className="flex items-start justify-between gap-2">
                              <div className="flex-1">
                                <div className="font-medium text-cyan-300 mb-0.5 line-clamp-2">
                                  {citation.title}
                                </div>
                                <div className="text-neutral-500 text-[10px] mb-1">
                                  {citation.authors} • {citation.journal} ({citation.year})
                                </div>
                                <div className="text-neutral-400 leading-relaxed">
                                  {citation.summary}
                                </div>
                              </div>
                              {citation.doi && (
                                <a
                                  href={`https://doi.org/${citation.doi}`}
                                  target="_blank"
                                  rel="noopener noreferrer"
                                  className="flex-shrink-0 p-1 text-cyan-400 hover:text-cyan-300 transition-colors"
                                  title="View full paper"
                                >
                                  <ExternalLink size={12} />
                                </a>
                              )}
                            </div>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <div className="text-[11px] sm:text-xs text-cyan-300/70">
                        {recommendation.matchedFlaws.length > 0
                          ? 'Based on facial analysis and established aesthetic research. More specific citations coming soon.'
                          : 'No specific research citations available for this recommendation.'}
                      </div>
                    )}
                  </div>

                  {/* Regional Costs for Surgical Treatments */}
                  {regionalCosts && regionalCosts.length > 0 && (
                    <div className="bg-purple-500/10 p-3 sm:p-4 rounded-lg border border-purple-500/30">
                      <div className="flex items-center gap-2 mb-3">
                        <Globe size={14} className="text-purple-400" />
                        <span className="font-semibold text-purple-400 text-xs sm:text-sm">Medical Tourism Costs</span>
                      </div>
                      <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                        {regionalCosts.slice(0, 6).map((cost, idx) => (
                          <div key={idx} className="bg-neutral-900/50 p-2 rounded-lg border border-neutral-700/50">
                            <div className="flex items-center gap-1 mb-1">
                              <MapPin size={10} className="text-purple-400" />
                              <span className="text-[10px] font-semibold text-white">{cost.region}</span>
                            </div>
                            <div className="text-[11px] text-purple-300 font-medium">
                              {cost.currency === 'USD' ? '$' : cost.currency === 'GBP' ? '£' : '€'}
                              {cost.min.toLocaleString()} - {cost.max.toLocaleString()}
                            </div>
                            {cost.notes && (
                              <div className="text-[9px] text-neutral-500 mt-0.5 line-clamp-1">
                                {cost.notes}
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                      {regionalCosts.length > 6 && (
                        <div className="text-[10px] text-purple-400/70 mt-2 text-center">
                          +{regionalCosts.length - 6} more destinations available
                        </div>
                      )}
                    </div>
                  )}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

export default EnhancedRecommendationCard;
