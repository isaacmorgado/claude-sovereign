/**
 * Advice Engine - Client-side implementation matching the Python AdviceEngine
 * Processes plans.json trigger rules against user metrics
 */

import { Plan } from '@/components/results/cards/PlanActionCard';

// ============================================
// TYPES
// ============================================

interface Threshold {
  operator: '<' | '>';
  value: number;
}

interface TriggerRules {
  metrics: string[];
  condition: 'OR' | 'AND';
  thresholds: Record<string, Threshold>;
}

// FaceIQ-style effectiveness rating
interface Effectiveness {
  level: 'high' | 'medium' | 'low';
  score: number;  // 1-5
  confidence: number;  // 0-1
}

// How a treatment impacts a specific ratio
interface RatioImpact {
  direction: 'increase' | 'decrease';
  percentage: number;  // Expected % change
}

interface PlanContent {
  description: string;
  cost_min: number;
  cost_max: number;
  time_min?: string;
  time_max?: string;
  risks?: string;
  citations?: string[];
  tags?: string[];
  // FaceIQ parity - new metadata fields
  priority_score?: number;  // 1-5, higher = more important
  effectiveness?: Effectiveness;
  ratios_impacted?: Record<string, RatioImpact>;
  pillars?: string[];  // e.g., ['angularity', 'harmony', 'symmetry']
}

interface RawPlan {
  id: string;
  title: string;
  trigger_rules: TriggerRules;
  content: PlanContent;
}

interface TriggerResult {
  metric: string;
  value: number;
  threshold: number;
  operator: '<' | '>';
}

// ============================================
// PLANS DATA (from plans.json)
// ============================================

export const PLANS: RawPlan[] = [
  {
    id: "jaw_fillers",
    title: "Jaw Fillers",
    trigger_rules: {
      metrics: ["Gonial Angle", "Bigonial Width", "Ramus to Mandible Ratio"],
      condition: "OR",
      thresholds: {
        "Gonial Angle": { operator: ">", value: 128.0 },
        "Bigonial Width": { operator: "<", value: 90.0 },
        "Ramus to Mandible Ratio": { operator: "<", value: 0.5 }
      }
    },
    content: {
      description: "Injectable dermal fillers (hyaluronic acid or hydroxyapatite) to enhance jawline definition, gonial angle sharpness, and mandibular border projection. Common products: Radiesse, Sculptra, Juvederm Voluma. Targets masseter hollow, prejowl sulcus, and mandibular angle.",
      cost_min: 600,
      cost_max: 2500,
      time_min: "6 months",
      time_max: "18 months",
      risks: "Vascular occlusion, asymmetry, swelling.",
      citations: ["Al-Khafaji et al., 2023"],
      tags: ["Minimally Invasive"],
      priority_score: 4,
      effectiveness: { level: 'high', score: 4, confidence: 0.85 },
      ratios_impacted: {
        "Gonial Angle": { direction: "decrease", percentage: 3 },
        "Bigonial Width": { direction: "increase", percentage: 4 },
        "Ramus to Mandible Ratio": { direction: "increase", percentage: 2 }
      },
      pillars: ["angularity", "masculinity", "bone_structure"]
    }
  },
  {
    id: "cheekbone_fillers",
    title: "Cheekbone Fillers",
    trigger_rules: {
      metrics: ["Cheekbone Height", "Face Width to Height Ratio"],
      condition: "OR",
      thresholds: {
        "Cheekbone Height": { operator: "<", value: 60.0 },
        "Face Width to Height Ratio": { operator: "<", value: 1.75 }
      }
    },
    content: {
      description: "Malar augmentation via hyaluronic acid fillers placed at the zygomatic arch and submalar region. Products: Juvederm Voluma, Restylane Lyft. Enhances ogee curve, anterior cheek projection, and lateral zygomatic width for improved facial angularity.",
      cost_min: 650,
      cost_max: 2500,
      time_min: "6 months",
      time_max: "18 months",
      risks: "Asymmetry, filler migration.",
      citations: ["Trinh & Gupta, 2021"],
      tags: ["Minimally Invasive"],
      priority_score: 4,
      effectiveness: { level: 'high', score: 5, confidence: 0.85 },
      ratios_impacted: {
        "Cheekbone Height": { direction: "increase", percentage: 4 },
        "Face Width to Height Ratio": { direction: "increase", percentage: 2 },
        "Midface Ratio": { direction: "decrease", percentage: 2 }
      },
      pillars: ["angularity", "harmony", "youthfulness"]
    }
  },
  {
    id: "beard_growth",
    title: "Beard / Stubble Growth",
    trigger_rules: {
      metrics: ["Chin to Philtrum Ratio", "Gonial Angle"],
      condition: "OR",
      thresholds: {
        "Chin to Philtrum Ratio": { operator: "<", value: 1.8 },
        "Gonial Angle": { operator: ">", value: 126.0 }
      }
    },
    content: {
      description: "Strategic facial hair growth (5-10mm stubble or full beard) to optically enhance jawline definition, camouflage gonial angle softness, and create visual chin projection. Consider minoxidil 5% foam if low coverage. Trim to maintain sharp mandibular border.",
      cost_min: 0,
      cost_max: 20,
      time_min: "1 month",
      time_max: "3 months",
      risks: "None",
      citations: ["Dixson et al., 2016"],
      tags: ["Foundational", "Free"],
      priority_score: 2,
      effectiveness: { level: 'medium', score: 3, confidence: 0.70 },
      ratios_impacted: {
        "Chin to Philtrum Ratio": { direction: "increase", percentage: 5 },
        "Gonial Angle": { direction: "decrease", percentage: 3 }
      },
      pillars: ["masculinity", "camouflage"]
    }
  },
  {
    id: "lip_filler",
    title: "Lip Filler",
    trigger_rules: {
      metrics: ["Lower Lip to Upper Lip Ratio"],
      condition: "OR",
      thresholds: {
        "Lower Lip to Upper Lip Ratio": { operator: "<", value: 1.0 }
      }
    },
    content: {
      description: "Lip augmentation via hyaluronic acid fillers (Restylane, Juvederm) to enhance vermillion border, cupid's bow definition, and lip ratio balance. Can target vermillion height, philtral columns, or tubercles. Alternative: surgical lip lift (bullhorn or corner lift) for permanent results.",
      cost_min: 500,
      cost_max: 1200,
      time_min: "6 months",
      time_max: "12 months",
      risks: "Migration, bruising.",
      citations: ["Hernandez et al., 2023"],
      tags: ["Minimally Invasive"],
      priority_score: 3,
      effectiveness: { level: 'high', score: 4, confidence: 0.80 },
      ratios_impacted: {
        "Lower Lip to Upper Lip Ratio": { direction: "increase", percentage: 15 }
      },
      pillars: ["harmony", "femininity", "youthfulness"]
    }
  },
  {
    id: "weight_loss_protocol",
    title: "Fat Loss Protocol (High Protein + Cardio)",
    trigger_rules: {
      metrics: ["Cheekbone Height", "Jaw Slope"],
      condition: "OR",
      thresholds: {
        "Cheekbone Height": { operator: "<", value: 65.0 },
        "Jaw Slope": { operator: ">", value: 140.0 }
      }
    },
    content: {
      description: "Caloric deficit protocol targeting 8-12% body fat to debloat buccal fat pads and reveal zygomatic, mandibular, and maxillary bone structure. High-protein intake (1.6-2.2g/kg), fasted cardio, and sodium/water management. Consider buccal fat removal surgery if structure remains obscured at low body fat.",
      cost_min: 200,
      cost_max: 1000,
      time_min: "3 months",
      time_max: "12 months",
      risks: "None",
      citations: ["Moon & Koh, 2020"],
      tags: ["Foundational"],
      priority_score: 5,
      effectiveness: { level: 'high', score: 4, confidence: 0.90 },
      ratios_impacted: {
        "Cheekbone Height": { direction: "increase", percentage: 8 },
        "Jaw Slope": { direction: "decrease", percentage: 5 },
        "Bigonial Width": { direction: "increase", percentage: 3 }
      },
      pillars: ["angularity", "bone_structure", "definition"]
    }
  },
  {
    id: "mewing_posture",
    title: "Mewing & Posture Correction",
    trigger_rules: {
      metrics: ["Midface Ratio", "Nasolabial Angle"],
      condition: "OR",
      thresholds: {
        "Midface Ratio": { operator: ">", value: 1.05 },
        "Nasolabial Angle": { operator: "<", value: 90.0 }
      }
    },
    content: {
      description: "Orthotropic tongue posture: entire tongue (posterior third critical) pressed against palate, teeth in light contact, nasal breathing. Aims to stimulate maxillary protraction, improve mandibular posture, and enhance gonial angle over time. Combine with proper head/neck alignment and chin tucks.",
      cost_min: 0,
      cost_max: 0,
      time_min: "12 months",
      time_max: "Lifetime",
      risks: "None if performed correctly.",
      citations: ["Mew J. et al., 2014"],
      tags: ["Foundational", "Free"],
      priority_score: 3,
      effectiveness: { level: 'low', score: 2, confidence: 0.50 },
      ratios_impacted: {
        "Midface Ratio": { direction: "decrease", percentage: 2 },
        "Nasolabial Angle": { direction: "increase", percentage: 3 },
        "Gonial Angle": { direction: "decrease", percentage: 2 }
      },
      pillars: ["bone_structure", "posture", "long_term"]
    }
  },
  {
    id: "rhinoplasty",
    title: "Rhinoplasty",
    trigger_rules: {
      metrics: ["Nasal Projection", "Nasal W to H Ratio", "Nasolabial Angle"],
      condition: "OR",
      thresholds: {
        "Nasal Projection": { operator: ">", value: 0.75 },
        "Nasal W to H Ratio": { operator: ">", value: 0.85 },
        "Nasolabial Angle": { operator: "<", value: 85.0 }
      }
    },
    content: {
      description: "Comprehensive nasal surgery: dorsal hump reduction, osteotomies for width correction, tip plasty for bulbous refinement, alarplasty for alar base narrowing, cephalic trim for tip rotation, septoplasty for deviation. Can address nasal index, nasolabial angle, nasofrontal angle, and tip projection.",
      cost_min: 5000,
      cost_max: 15000,
      time_min: "6 months",
      time_max: "12 months",
      risks: "Infection, asymmetry, breathing issues, revision surgery.",
      citations: ["Rohrich RJ et al., 2010", "Foda HM, 2008"],
      tags: ["Surgical"],
      priority_score: 5,
      effectiveness: { level: 'high', score: 5, confidence: 0.90 },
      ratios_impacted: {
        "Nasal Projection": { direction: "decrease", percentage: 10 },
        "Nasal W to H Ratio": { direction: "decrease", percentage: 8 },
        "Nasolabial Angle": { direction: "increase", percentage: 12 },
        "Nasal Index": { direction: "decrease", percentage: 6 }
      },
      pillars: ["harmony", "profile", "ethnicity_specific"]
    }
  },
  {
    id: "genioplasty",
    title: "Sliding Genioplasty (Chin Surgery)",
    trigger_rules: {
      metrics: ["Chin to Philtrum Ratio", "Recession Relative to Frankfort Plane"],
      condition: "OR",
      thresholds: {
        "Chin to Philtrum Ratio": { operator: "<", value: 1.5 },
        "Recession Relative to Frankfort Plane": { operator: ">", value: 15.0 }
      }
    },
    content: {
      description: "Osseous genioplasty: horizontal advancement or setback of the chin via osteotomy and titanium plate fixation. Can also adjust vertical height (reduction/augmentation) and transverse width. Alternative: alloplastic chin implant (silicone/Medpor) for pure augmentation. Improves chin-philtrum ratio and profile convexity.",
      cost_min: 4000,
      cost_max: 12000,
      time_min: "3 months",
      time_max: "12 months",
      risks: "Numbness, infection, asymmetry.",
      citations: ["Park JH et al., 2018"],
      tags: ["Surgical"],
      priority_score: 5,
      effectiveness: { level: 'high', score: 5, confidence: 0.92 },
      ratios_impacted: {
        "Chin to Philtrum Ratio": { direction: "increase", percentage: 20 },
        "Recession Relative to Frankfort Plane": { direction: "decrease", percentage: 15 },
        "Facial Convexity (Nasion)": { direction: "increase", percentage: 5 }
      },
      pillars: ["profile", "masculinity", "bone_structure"]
    }
  },
  {
    id: "canthoplasty",
    title: "Canthoplasty (Eye Corner Surgery)",
    trigger_rules: {
      metrics: ["Lateral Canthal Tilt", "Eye Aspect Ratio"],
      condition: "AND",
      thresholds: {
        "Lateral Canthal Tilt": { operator: "<", value: 4.0 },
        "Eye Aspect Ratio": { operator: "<", value: 2.8 }
      }
    },
    content: {
      description: "Lateral canthoplasty or canthopexy: surgical elevation and fixation of the lateral canthal tendon to increase positive canthal tilt angle. Techniques include tarsal strip, lateral canthal suspension, or almond eye surgery. Can be combined with lower blepharoplasty. Addresses negative canthal tilt and downturned eye appearance.",
      cost_min: 3000,
      cost_max: 8000,
      time_min: "2 months",
      time_max: "6 months",
      risks: "Scarring, asymmetry, dry eyes.",
      citations: ["Rhee SC et al., 2017", "Chen WP, 2016"],
      tags: ["Surgical"],
      priority_score: 4,
      effectiveness: { level: 'high', score: 4, confidence: 0.80 },
      ratios_impacted: {
        "Lateral Canthal Tilt": { direction: "increase", percentage: 40 },
        "Eye Aspect Ratio": { direction: "increase", percentage: 10 }
      },
      pillars: ["youthfulness", "alertness", "femininity"]
    }
  },
  {
    id: "brow_lift",
    title: "Brow Lift / Browridge Enhancement",
    trigger_rules: {
      metrics: ["Eyebrow Low Setedness", "Browridge Inclination Angle"],
      condition: "OR",
      thresholds: {
        "Eyebrow Low Setedness": { operator: ">", value: 2.0 },
        "Browridge Inclination Angle": { operator: "<", value: 10.0 }
      }
    },
    content: {
      description: "Brow elevation via endoscopic browlift, temporal lift, or direct browplasty to reduce hooding and increase eyebrow height. For browridge: supraorbital rim augmentation with PMMA, hydroxyapatite paste, or custom implants. Botox for brow arch shaping. Addresses low-set brows and flat browridge inclination.",
      cost_min: 1500,
      cost_max: 10000,
      time_min: "1 month",
      time_max: "6 months",
      risks: "Asymmetry, numbness, unnatural appearance.",
      citations: ["Mendelson B et al., 2015"],
      tags: ["Surgical", "Minimally Invasive"],
      priority_score: 3,
      effectiveness: { level: 'medium', score: 4, confidence: 0.75 },
      ratios_impacted: {
        "Eyebrow Low Setedness": { direction: "decrease", percentage: 30 },
        "Browridge Inclination Angle": { direction: "increase", percentage: 20 }
      },
      pillars: ["youthfulness", "masculinity", "upper_third"]
    }
  },
  // ============================================
  // NEW PROCEDURES FROM FACEIQ PARITY
  // ============================================
  {
    id: "kybella",
    title: "Kybella (Double Chin Removal)",
    trigger_rules: {
      metrics: ["Submental Cervical Angle", "Neck Width"],
      condition: "OR",
      thresholds: {
        "Submental Cervical Angle": { operator: ">", value: 130.0 },
        "Neck Width": { operator: ">", value: 95.0 }
      }
    },
    content: {
      description: "Injectable deoxycholic acid (Kybella/ATX-101) to permanently dissolve submental fat. Multiple sessions required (2-6 treatments, 4-6 weeks apart). Destroys fat cell membranes, eliminating double chin without surgery. FDA-approved for moderate-to-severe submental fullness.",
      cost_min: 1200,
      cost_max: 3000,
      time_min: "2 months",
      time_max: "6 months",
      risks: "Swelling, bruising, numbness, pain, nerve injury causing asymmetric smile, asymmetry, difficulty swallowing.",
      citations: ["Jones DH et al., 2016", "Ascher B et al., 2017"],
      tags: ["Minimally Invasive"],
      priority_score: 3,
      effectiveness: { level: 'medium', score: 3, confidence: 0.75 },
      ratios_impacted: {
        "Submental Cervical Angle": { direction: "decrease", percentage: 15 },
        "Neck Width": { direction: "decrease", percentage: 10 }
      },
      pillars: ["definition", "youthfulness", "neck"]
    }
  },
  {
    id: "cryolipolysis",
    title: "Cryolipolysis (Fat Freezing)",
    trigger_rules: {
      metrics: ["Submental Cervical Angle", "Neck Width"],
      condition: "OR",
      thresholds: {
        "Submental Cervical Angle": { operator: ">", value: 125.0 },
        "Neck Width": { operator: ">", value: 90.0 }
      }
    },
    content: {
      description: "Non-invasive fat reduction via controlled cooling (CoolSculpting). Targets stubborn subcutaneous fat without surgery by crystallizing fat cells which are then naturally eliminated. FDA-cleared for submental area, flanks, abdomen. Results visible in 2-4 months.",
      cost_min: 750,
      cost_max: 2500,
      time_min: "2 months",
      time_max: "4 months",
      risks: "Temporary erythema/swelling, bruising, numbness/paresthesia, pain, paradoxical adipose hyperplasia (rare), frostbite, hyperpigmentation.",
      citations: ["Ingargiola MJ et al., 2015", "Kilmer SL et al., 2017"],
      tags: ["Minimally Invasive"],
      priority_score: 2,
      effectiveness: { level: 'medium', score: 3, confidence: 0.70 },
      ratios_impacted: {
        "Submental Cervical Angle": { direction: "decrease", percentage: 12 },
        "Neck Width": { direction: "decrease", percentage: 8 }
      },
      pillars: ["definition", "non_invasive", "neck"]
    }
  },
  {
    id: "chin_implant",
    title: "Chin Implant (Mentoplasty)",
    trigger_rules: {
      metrics: ["Chin to Philtrum Ratio", "Recession Relative to Frankfort Plane", "Facial Convexity"],
      condition: "OR",
      thresholds: {
        "Chin to Philtrum Ratio": { operator: "<", value: 1.6 },
        "Recession Relative to Frankfort Plane": { operator: ">", value: 12.0 },
        "Facial Convexity": { operator: "<", value: 165.0 }
      }
    },
    content: {
      description: "Alloplastic chin augmentation using silicone or Medpor implants placed through submental or intraoral incision. Provides permanent chin projection and width enhancement. Alternative to sliding genioplasty for pure augmentation without bone cutting. Custom implants available for precise contouring.",
      cost_min: 3000,
      cost_max: 8000,
      time_min: "2 weeks",
      time_max: "3 months",
      risks: "Infection, implant migration, bone erosion, asymmetry, numbness, capsular contracture, implant extrusion.",
      citations: ["Yaremchuk MJ, 2013", "Binder WJ et al., 2008"],
      tags: ["Surgical"],
      priority_score: 4,
      effectiveness: { level: 'high', score: 4, confidence: 0.88 },
      ratios_impacted: {
        "Chin to Philtrum Ratio": { direction: "increase", percentage: 18 },
        "Recession Relative to Frankfort Plane": { direction: "decrease", percentage: 12 },
        "Facial Convexity (Nasion)": { direction: "increase", percentage: 4 }
      },
      pillars: ["profile", "masculinity", "bone_structure"]
    }
  },
  {
    id: "buccal_fat_removal",
    title: "Buccal Fat Removal (Bichectomy)",
    trigger_rules: {
      metrics: ["Cheekbone Height", "Face Width to Height Ratio"],
      condition: "AND",
      thresholds: {
        "Cheekbone Height": { operator: "<", value: 70.0 },
        "Face Width to Height Ratio": { operator: ">", value: 1.55 }
      }
    },
    content: {
      description: "Surgical excision of buccal fat pads through intraoral incision to slim the lower cheeks and enhance facial angularity. Creates more defined cheekbone-to-jaw contour. Best for patients with naturally round faces at low body fat. Results are permanent and irreversible.",
      cost_min: 2500,
      cost_max: 6000,
      time_min: "2 weeks",
      time_max: "6 months",
      risks: "Facial nerve damage, asymmetry, over-resection causing gaunt appearance, infection, hematoma, parotid duct injury.",
      citations: ["Tarallo M et al., 2018", "Moura LB et al., 2018"],
      tags: ["Surgical"],
      priority_score: 3,
      effectiveness: { level: 'high', score: 4, confidence: 0.80 },
      ratios_impacted: {
        "Cheekbone Height": { direction: "increase", percentage: 6 },
        "Face Width to Height Ratio": { direction: "decrease", percentage: 3 }
      },
      pillars: ["angularity", "definition", "bone_structure"]
    }
  },
  {
    id: "alarplasty",
    title: "Alarplasty (Alar Base Reduction)",
    trigger_rules: {
      metrics: ["Nasal W to H Ratio", "Alar Base Width"],
      condition: "OR",
      thresholds: {
        "Nasal W to H Ratio": { operator: ">", value: 0.80 },
        "Alar Base Width": { operator: ">", value: 35.0 }
      }
    },
    content: {
      description: "Surgical narrowing of the nasal alar base through wedge excision. Reduces nostril width and alar flare. Can be performed alone or combined with rhinoplasty. Weir excision for nostril sill, alar wedge for flaring. Hidden incision placement minimizes visible scarring.",
      cost_min: 2000,
      cost_max: 5000,
      time_min: "2 weeks",
      time_max: "3 months",
      risks: "Visible scarring, asymmetry, over-narrowing, nostril distortion, poor wound healing.",
      citations: ["Rohrich RJ et al., 2009", "Ingels K et al., 2015"],
      tags: ["Surgical"],
      priority_score: 3,
      effectiveness: { level: 'high', score: 4, confidence: 0.85 },
      ratios_impacted: {
        "Nasal W to H Ratio": { direction: "decrease", percentage: 12 },
        "Nasal Index": { direction: "decrease", percentage: 8 }
      },
      pillars: ["harmony", "profile", "ethnicity_specific"]
    }
  },
  {
    id: "canthopexy",
    title: "Canthopexy (Lateral Canthal Suspension)",
    trigger_rules: {
      metrics: ["Lateral Canthal Tilt", "Lower Eyelid Position"],
      condition: "OR",
      thresholds: {
        "Lateral Canthal Tilt": { operator: "<", value: 3.0 },
        "Lower Eyelid Position": { operator: ">", value: 1.5 }
      }
    },
    content: {
      description: "Suture suspension of the lateral canthal tendon to tighten lower eyelid and prevent sagging. Less invasive than canthoplasty (no tendon cutting). Supports eye shape, prevents scleral show, and can provide subtle upward tilt. Often combined with blepharoplasty.",
      cost_min: 2500,
      cost_max: 6000,
      time_min: "2 weeks",
      time_max: "3 months",
      risks: "Asymmetry, under/overcorrection, dry eyes, ectropion, scarring, temporary swelling.",
      citations: ["Hester TR et al., 2000", "Codner MA et al., 2008"],
      tags: ["Surgical"],
      priority_score: 3,
      effectiveness: { level: 'medium', score: 3, confidence: 0.75 },
      ratios_impacted: {
        "Lateral Canthal Tilt": { direction: "increase", percentage: 20 }
      },
      pillars: ["youthfulness", "alertness", "eye_area"]
    }
  },
  {
    id: "neck_lift",
    title: "Neck Lift (Platysmaplasty)",
    trigger_rules: {
      metrics: ["Submental Cervical Angle", "Neck Width"],
      condition: "OR",
      thresholds: {
        "Submental Cervical Angle": { operator: ">", value: 135.0 },
        "Neck Width": { operator: ">", value: 100.0 }
      }
    },
    content: {
      description: "Comprehensive neck rejuvenation: platysma muscle tightening (platysmaplasty), submental liposuction, excess skin removal, and possible digastric muscle reduction. Addresses turkey neck, platysmal banding, submental fullness, and skin laxity. Can include submental tuck or deep plane techniques.",
      cost_min: 5000,
      cost_max: 15000,
      time_min: "3 weeks",
      time_max: "6 months",
      risks: "Hematoma, nerve injury, skin necrosis, asymmetry, visible scarring, skin irregularities, prolonged swelling.",
      citations: ["Feldman JJ, 2006", "Ellenbogen R et al., 2014"],
      tags: ["Surgical"],
      priority_score: 4,
      effectiveness: { level: 'high', score: 5, confidence: 0.90 },
      ratios_impacted: {
        "Submental Cervical Angle": { direction: "decrease", percentage: 25 },
        "Neck Width": { direction: "decrease", percentage: 15 }
      },
      pillars: ["definition", "youthfulness", "neck"]
    }
  },
  {
    id: "septoplasty",
    title: "Septoplasty (Deviated Septum Correction)",
    trigger_rules: {
      metrics: ["Nasal Deviation", "Nasal Symmetry"],
      condition: "OR",
      thresholds: {
        "Nasal Deviation": { operator: ">", value: 5.0 },
        "Nasal Symmetry": { operator: "<", value: 0.90 }
      }
    },
    content: {
      description: "Surgical correction of deviated nasal septum to improve nasal airflow and symmetry. Performed through closed endonasal approach. Can be functional (breathing) or cosmetic (straightening). Often combined with rhinoplasty (septorhinoplasty) for comprehensive nasal reshaping.",
      cost_min: 3000,
      cost_max: 10000,
      time_min: "1 week",
      time_max: "3 months",
      risks: "Septal perforation, persistent deviation, saddle nose, numbness, infection, bleeding, CSF leak (rare).",
      citations: ["Rohrich RJ et al., 2011", "Fettman N et al., 2009"],
      tags: ["Surgical"],
      priority_score: 2,
      effectiveness: { level: 'medium', score: 3, confidence: 0.75 },
      ratios_impacted: {
        "Nasal Deviation": { direction: "decrease", percentage: 80 },
        "Nasal Symmetry": { direction: "increase", percentage: 10 }
      },
      pillars: ["symmetry", "function", "breathing"]
    }
  },
  {
    id: "lip_lift",
    title: "Lip Lift (Bullhorn/Subnasal Lip Lift)",
    trigger_rules: {
      metrics: ["Philtrum Length", "Upper Lip Vermilion Height", "Midface Ratio"],
      condition: "OR",
      thresholds: {
        "Philtrum Length": { operator: ">", value: 15.0 },
        "Upper Lip Vermilion Height": { operator: "<", value: 7.0 },
        "Midface Ratio": { operator: ">", value: 1.1 }
      }
    },
    content: {
      description: "Surgical shortening of the philtrum by removing skin at the base of the nose (bullhorn excision). Permanently increases upper lip vermilion show and reduces long upper lip appearance. Alternative to filler for long philtrum correction. Scar hidden in nasal base crease.",
      cost_min: 3500,
      cost_max: 8000,
      time_min: "2 weeks",
      time_max: "6 months",
      risks: "Visible scarring, asymmetry, over-shortening, distorted nostril base, wound dehiscence, prolonged swelling.",
      citations: ["Austin HW, 1986", "Santanché P et al., 2014"],
      tags: ["Surgical"],
      priority_score: 4,
      effectiveness: { level: 'high', score: 5, confidence: 0.88 },
      ratios_impacted: {
        "Chin to Philtrum Ratio": { direction: "increase", percentage: 25 },
        "Midface Ratio": { direction: "decrease", percentage: 8 }
      },
      pillars: ["youthfulness", "harmony", "lip_area"]
    }
  },
  {
    id: "jaw_implants",
    title: "Jaw Implants (Mandibular Augmentation)",
    trigger_rules: {
      metrics: ["Bigonial Width", "Gonial Angle", "Ramus to Mandible Ratio"],
      condition: "OR",
      thresholds: {
        "Bigonial Width": { operator: "<", value: 85.0 },
        "Gonial Angle": { operator: ">", value: 130.0 },
        "Ramus to Mandible Ratio": { operator: "<", value: 0.45 }
      }
    },
    content: {
      description: "Alloplastic mandibular augmentation using silicone, Medpor, or custom PEEK implants. Enhances jaw width (bigonial), gonial angle definition, and mandibular border projection. Placed through intraoral incision. Custom wraparound implants available for comprehensive jaw enhancement.",
      cost_min: 6000,
      cost_max: 20000,
      time_min: "3 weeks",
      time_max: "6 months",
      risks: "Infection, implant migration, bone erosion, asymmetry, mental nerve injury, capsular contracture, masseter atrophy.",
      citations: ["Yaremchuk MJ, 2006", "Rao LK et al., 2011"],
      tags: ["Surgical"],
      priority_score: 5,
      effectiveness: { level: 'high', score: 5, confidence: 0.90 },
      ratios_impacted: {
        "Bigonial Width": { direction: "increase", percentage: 12 },
        "Gonial Angle": { direction: "decrease", percentage: 8 },
        "Ramus to Mandible Ratio": { direction: "increase", percentage: 6 }
      },
      pillars: ["angularity", "masculinity", "bone_structure"]
    }
  },
  {
    id: "midface_implants",
    title: "Midface Implants (Malar/Submalar)",
    trigger_rules: {
      metrics: ["Cheekbone Height", "Midface Ratio", "Face Width to Height Ratio"],
      condition: "OR",
      thresholds: {
        "Cheekbone Height": { operator: "<", value: 55.0 },
        "Midface Ratio": { operator: ">", value: 1.15 },
        "Face Width to Height Ratio": { operator: "<", value: 1.65 }
      }
    },
    content: {
      description: "Alloplastic augmentation of the malar (cheekbone) and/or submalar region using silicone or Medpor implants. Enhances midface projection, cheekbone prominence, and overall facial width. Custom implants available. Alternative to fat grafting for permanent midface volume.",
      cost_min: 5000,
      cost_max: 15000,
      time_min: "3 weeks",
      time_max: "6 months",
      risks: "Infection, implant migration, asymmetry, nerve injury (infraorbital), bone erosion, capsular contracture, visibility.",
      citations: ["Terino EO, 2000", "Binder WJ et al., 2007"],
      tags: ["Surgical"],
      priority_score: 4,
      effectiveness: { level: 'high', score: 5, confidence: 0.88 },
      ratios_impacted: {
        "Cheekbone Height": { direction: "increase", percentage: 10 },
        "Midface Ratio": { direction: "decrease", percentage: 6 },
        "Face Width to Height Ratio": { direction: "increase", percentage: 4 }
      },
      pillars: ["angularity", "harmony", "bone_structure"]
    }
  },
  {
    id: "submental_liposuction",
    title: "Submental Liposuction",
    trigger_rules: {
      metrics: ["Submental Cervical Angle", "Neck Width"],
      condition: "AND",
      thresholds: {
        "Submental Cervical Angle": { operator: ">", value: 120.0 },
        "Neck Width": { operator: ">", value: 85.0 }
      }
    },
    content: {
      description: "Surgical removal of excess fat beneath the chin via small cannula through submental incision. Refines jawline contour and improves neck definition. Can be combined with skin tightening or platysmaplasty. Best for younger patients with good skin elasticity.",
      cost_min: 2000,
      cost_max: 5000,
      time_min: "1 week",
      time_max: "3 months",
      risks: "Contour irregularities, asymmetry, nerve injury, skin laxity, hematoma, seroma, prolonged swelling.",
      citations: ["Rohrich RJ et al., 2007", "Giampapa VC et al., 2000"],
      tags: ["Surgical"],
      priority_score: 3,
      effectiveness: { level: 'medium', score: 4, confidence: 0.82 },
      ratios_impacted: {
        "Submental Cervical Angle": { direction: "decrease", percentage: 15 },
        "Neck Width": { direction: "decrease", percentage: 10 }
      },
      pillars: ["definition", "youthfulness", "neck"]
    }
  },
  {
    id: "submentoplasty",
    title: "Submentoplasty (Submental Tuck)",
    trigger_rules: {
      metrics: ["Submental Cervical Angle", "Neck Width"],
      condition: "OR",
      thresholds: {
        "Submental Cervical Angle": { operator: ">", value: 140.0 },
        "Neck Width": { operator: ">", value: 105.0 }
      }
    },
    content: {
      description: "Direct excision of submental skin/fat with platysma muscle plication through small chin incision. Tightens central neck muscles and removes excess tissue. More aggressive than liposuction alone, less extensive than full neck lift. Also called cervicoplasty.",
      cost_min: 3500,
      cost_max: 8000,
      time_min: "2 weeks",
      time_max: "4 months",
      risks: "Visible scarring, hematoma, nerve injury, skin necrosis, asymmetry, contour irregularities.",
      citations: ["Giampapa VC et al., 2000", "Ellenbogen R et al., 2014"],
      tags: ["Surgical"],
      priority_score: 4,
      effectiveness: { level: 'high', score: 4, confidence: 0.85 },
      ratios_impacted: {
        "Submental Cervical Angle": { direction: "decrease", percentage: 20 },
        "Neck Width": { direction: "decrease", percentage: 12 }
      },
      pillars: ["definition", "youthfulness", "neck"]
    }
  },
  {
    id: "fat_grafting",
    title: "Fat Grafting (Facial Lipofilling)",
    trigger_rules: {
      metrics: ["Cheekbone Height", "Under-Eye Hollowness", "Temple Volume"],
      condition: "OR",
      thresholds: {
        "Cheekbone Height": { operator: "<", value: 60.0 },
        "Under-Eye Hollowness": { operator: ">", value: 3.0 },
        "Temple Volume": { operator: "<", value: 0.8 }
      }
    },
    content: {
      description: "Autologous fat transfer: fat harvested from body (abdomen, thighs), processed, and injected for facial volumization. Microfat for volume (cheeks, temples, jawline), nanofat for skin rejuvenation. Natural permanent filler with 40-60% long-term retention. Multiple sessions may be needed.",
      cost_min: 4000,
      cost_max: 12000,
      time_min: "1 month",
      time_max: "6 months",
      risks: "Fat resorption, asymmetry, lumpiness, oil cysts, infection, embolism (rare), over/under-correction.",
      citations: ["Coleman SR, 2006", "Khouri RK et al., 2014"],
      tags: ["Surgical"],
      priority_score: 3,
      effectiveness: { level: 'medium', score: 3, confidence: 0.70 },
      ratios_impacted: {
        "Cheekbone Height": { direction: "increase", percentage: 5 },
        "Tear Trough Depth": { direction: "decrease", percentage: 40 }
      },
      pillars: ["youthfulness", "volume", "natural"]
    }
  },
  {
    id: "supraorbital_implants",
    title: "Supraorbital Rim Implants (Browridge)",
    trigger_rules: {
      metrics: ["Browridge Inclination Angle", "Supraorbital Projection"],
      condition: "OR",
      thresholds: {
        "Browridge Inclination Angle": { operator: "<", value: 8.0 },
        "Supraorbital Projection": { operator: "<", value: 0.85 }
      }
    },
    content: {
      description: "Custom or standard implants placed along the supraorbital rim to enhance browridge projection and definition. Creates more prominent brow bone for masculine appearance. Often custom-designed from CT scans. Placed through coronal or endoscopic approach.",
      cost_min: 8000,
      cost_max: 25000,
      time_min: "3 weeks",
      time_max: "6 months",
      risks: "Infection, implant migration, asymmetry, nerve injury, frontal sinus violation, visible/palpable implant, bone erosion.",
      citations: ["Yaremchuk MJ, 2003", "Spiegel JH, 2011"],
      tags: ["Surgical"],
      priority_score: 3,
      effectiveness: { level: 'high', score: 4, confidence: 0.80 },
      ratios_impacted: {
        "Browridge Inclination Angle": { direction: "increase", percentage: 30 }
      },
      pillars: ["masculinity", "bone_structure", "upper_third"]
    }
  },
  {
    id: "lip_reduction",
    title: "Lip Reduction Surgery (Reduction Cheiloplasty)",
    trigger_rules: {
      metrics: ["Lip Thickness", "Lower Lip to Upper Lip Ratio"],
      condition: "OR",
      thresholds: {
        "Lip Thickness": { operator: ">", value: 18.0 },
        "Lower Lip to Upper Lip Ratio": { operator: ">", value: 2.2 }
      }
    },
    content: {
      description: "Surgical removal of excess lip tissue through incision along wet-dry border to reduce lip volume and projection. Improves proportion between lips and surrounding features. Separate procedures for upper and lower lips. Permanent alternative to reversible fillers.",
      cost_min: 2500,
      cost_max: 6000,
      time_min: "2 weeks",
      time_max: "3 months",
      risks: "Visible scarring, asymmetry, over-reduction, numbness, altered sensation, wound dehiscence.",
      citations: ["Fanous N, 2007", "Garcia RM et al., 2016"],
      tags: ["Surgical"],
      priority_score: 2,
      effectiveness: { level: 'high', score: 4, confidence: 0.85 },
      ratios_impacted: {
        "Lower Lip to Upper Lip Ratio": { direction: "decrease", percentage: 20 }
      },
      pillars: ["harmony", "balance", "lip_area"]
    }
  },
  {
    id: "jaw_reduction",
    title: "Jaw Reduction Surgery (V-Line Surgery)",
    trigger_rules: {
      metrics: ["Bigonial Width", "Gonial Angle", "Face Width to Height Ratio"],
      condition: "AND",
      thresholds: {
        "Bigonial Width": { operator: ">", value: 120.0 },
        "Gonial Angle": { operator: "<", value: 115.0 },
        "Face Width to Height Ratio": { operator: ">", value: 1.65 }
      }
    },
    content: {
      description: "Mandibular angle resection and contouring to slim and feminize the lower face, creating V-line effect. Osteotomy of mandibular angle, possible chin tapering (T-osteotomy), and masseter reduction. Popular in East Asian aesthetic surgery. Performed through intraoral approach.",
      cost_min: 8000,
      cost_max: 25000,
      time_min: "1 month",
      time_max: "6 months",
      risks: "Facial nerve injury, asymmetry, over-reduction, bone necrosis, infection, prolonged swelling, numbness.",
      citations: ["Yang DB et al., 2014", "Jin H et al., 2013"],
      tags: ["Surgical"],
      priority_score: 4,
      effectiveness: { level: 'high', score: 5, confidence: 0.90 },
      ratios_impacted: {
        "Bigonial Width": { direction: "decrease", percentage: 15 },
        "Gonial Angle": { direction: "increase", percentage: 10 },
        "Face Width to Height Ratio": { direction: "decrease", percentage: 8 }
      },
      pillars: ["femininity", "harmony", "bone_structure"]
    }
  },
  {
    id: "bimaxillary_osteotomy",
    title: "Bimaxillary Osteotomy (Double Jaw Surgery)",
    trigger_rules: {
      metrics: ["Facial Convexity", "Recession Relative to Frankfort Plane", "Midface Ratio"],
      condition: "AND",
      thresholds: {
        "Facial Convexity": { operator: "<", value: 160.0 },
        "Recession Relative to Frankfort Plane": { operator: ">", value: 18.0 },
        "Midface Ratio": { operator: ">", value: 1.2 }
      }
    },
    content: {
      description: "Simultaneous repositioning of both maxilla (Le Fort I) and mandible (BSSO) to correct facial disharmony and skeletal malocclusion. Addresses severe class II/III relationships, facial asymmetry, and vertical excess. Requires orthodontic preparation. Most comprehensive facial skeletal surgery.",
      cost_min: 20000,
      cost_max: 60000,
      time_min: "3 months",
      time_max: "12 months",
      risks: "Nerve injury, infection, relapse, TMJ dysfunction, malocclusion, bleeding, airway compromise, need for revision.",
      citations: ["Proffit WR et al., 2013", "Wolford LM et al., 2003"],
      tags: ["Surgical"],
      priority_score: 5,
      effectiveness: { level: 'high', score: 5, confidence: 0.92 },
      ratios_impacted: {
        "Facial Convexity (Nasion)": { direction: "increase", percentage: 15 },
        "Recession Relative to Frankfort Plane": { direction: "decrease", percentage: 20 },
        "Midface Ratio": { direction: "decrease", percentage: 10 }
      },
      pillars: ["profile", "bone_structure", "comprehensive"]
    }
  }
];

// ============================================
// ADVICE ENGINE CLASS
// ============================================

export class AdviceEngine {
  private plans: RawPlan[];

  constructor(customPlans?: RawPlan[]) {
    this.plans = customPlans || PLANS;
  }

  /**
   * Check if a single threshold condition is met
   */
  private checkThreshold(userValue: number, operator: '<' | '>', thresholdValue: number): boolean {
    if (operator === '<') {
      return userValue < thresholdValue;
    }
    return userValue > thresholdValue;
  }

  /**
   * Evaluate trigger rules against user metrics
   */
  private evaluateTriggerRules(
    triggerRules: TriggerRules,
    metricsDict: Record<string, number>
  ): { isTriggered: boolean; triggeredMetrics: TriggerResult[] } {
    const { metrics, thresholds, condition } = triggerRules;
    const triggeredMetrics: TriggerResult[] = [];
    const results: boolean[] = [];

    for (const metricName of metrics) {
      if (!(metricName in metricsDict)) continue;
      if (!(metricName in thresholds)) continue;

      const userValue = metricsDict[metricName];
      const { operator, value: thresholdValue } = thresholds[metricName];
      const isMet = this.checkThreshold(userValue, operator, thresholdValue);

      if (isMet) {
        triggeredMetrics.push({
          metric: metricName,
          value: userValue,
          threshold: thresholdValue,
          operator
        });
      }

      results.push(isMet);
    }

    const isTriggered = condition === 'AND'
      ? results.length > 0 && results.every(r => r)
      : results.some(r => r);

    return { isTriggered, triggeredMetrics };
  }

  /**
   * Get all recommendations that match the user's metrics
   *
   * @param metricsDict - Raw metric values
   * @param severityDict - Severity classifications (ideal/good/moderate/severe) for each metric
   *                       If a metric is 'ideal', it will NOT trigger remediation plans
   */
  getRecommendations(
    metricsDict: Record<string, number>,
    severityDict?: Record<string, string>
  ): Plan[] {
    const recommendations: Plan[] = [];

    for (const rawPlan of this.plans) {
      const { isTriggered, triggeredMetrics } = this.evaluateTriggerRules(
        rawPlan.trigger_rules,
        metricsDict
      );

      // If severity data is provided, filter out metrics that are already ideal
      if (isTriggered && severityDict) {
        // Check if ALL triggered metrics are outside ideal range
        const hasActualFlaw = triggeredMetrics.some(tm => {
          const severity = severityDict[tm.metric];
          // Only trigger if severity is NOT ideal (i.e., it's good/moderate/severe)
          return severity && severity !== 'ideal';
        });

        // Skip this plan if all triggered metrics are already ideal
        if (!hasActualFlaw) {
          continue;
        }
      }

      if (isTriggered) {
        recommendations.push({
          id: rawPlan.id,
          title: rawPlan.title,
          content: {
            description: rawPlan.content.description,
            cost_min: rawPlan.content.cost_min,
            cost_max: rawPlan.content.cost_max,
            time_min: rawPlan.content.time_min || 'Unknown',
            time_max: rawPlan.content.time_max || 'Unknown',
            risks: rawPlan.content.risks || 'Consult a professional.',
            citations: rawPlan.content.citations || [],
            tags: rawPlan.content.tags
          },
          trigger_reason: triggeredMetrics
        });
      }
    }

    return recommendations;
  }

  /**
   * Get recommendations sorted by cost (cheapest first)
   */
  getRecommendationsByCost(
    metricsDict: Record<string, number>,
    severityDict?: Record<string, string>
  ): Plan[] {
    return this.getRecommendations(metricsDict, severityDict).sort(
      (a, b) => a.content.cost_min - b.content.cost_min
    );
  }

  /**
   * Get recommendations grouped by phase/tag
   */
  getRecommendationsByPhase(
    metricsDict: Record<string, number>,
    severityDict?: Record<string, string>
  ): Record<string, Plan[]> {
    const recommendations = this.getRecommendations(metricsDict, severityDict);
    const grouped: Record<string, Plan[]> = {
      'Foundational': [],
      'Minimally Invasive': [],
      'Surgical': []
    };

    for (const rec of recommendations) {
      const tags = rec.content.tags || [];
      if (tags.includes('Foundational')) {
        grouped['Foundational'].push(rec);
      } else if (tags.includes('Surgical')) {
        grouped['Surgical'].push(rec);
      } else if (tags.includes('Minimally Invasive')) {
        grouped['Minimally Invasive'].push(rec);
      } else {
        grouped['Minimally Invasive'].push(rec); // Default
      }
    }

    return grouped;
  }
}

// ============================================
// SINGLETON INSTANCE
// ============================================

export const adviceEngine = new AdviceEngine();
