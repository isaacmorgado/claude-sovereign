# LOOKSMAXX Personal Coach Feature - Implementation Plan

## Overview

Add a personal looksmaxxing coach with **minimal user friction**:
1. **Short Questionnaire** (4-5 questions only) - Height, goals, budget, hair color
2. **Auto-Analysis** - Claude Vision + MediaPipe Pose derive everything else from photos
3. **LLM Coach** (Claude) - Personalized advice using harmony score + auto-derived data
4. **Visual Mockups** (Google Nano Banana) - Hairstyle, archetype, style visualizations
5. **Archetype Classification** - Prompt-engineered rules based on existing 70+ metrics

---

## Design Principle: Minimal Friction

**User provides only (4-5 questions):**
- Height (can't derive accurately from photos)
- Goals (what they want to improve)
- Budget level (for recommendations)
- Hair color (if dyed)
- Timeline preference

**Auto-derived from FACE photo (existing landmarks):**
- Eye shape, eye color, eyebrow shape
- Nose shape, jawline, cheek hollows
- Face shape, midface length, hairline
- Skin tone, skin clarity
- Facial forward growth
- All 70+ existing metrics

**Auto-derived from BODY photo (new):**
- Shoulder-to-waist ratio (MediaPipe Pose landmarks)
- Frame size, body proportions
- Muscularity level (Claude Vision)
- Leanness estimate (Claude Vision)

---

## Phase 1: Minimal Questionnaire + Body Photo

### Database Changes

**New file:** `/Users/imorgado/LOOKSMAXX/looksmaxx-api/app/models/user_profile.py`
```python
class UserProfile(Base):
    __tablename__ = "user_profiles"

    id: UUID
    user_id: UUID (FK -> users.id, unique)

    # User-provided (minimal)
    height_cm: int
    hair_color: str  # if dyed
    goals: JSONB  # list of improvement goals
    budget_level: str  # low, medium, high
    timeline: str  # 3mo, 6mo, 1yr

    # Auto-derived from face (populated after analysis)
    face_metrics_summary: JSONB  # key metrics from analysis
    eye_color_detected: str
    skin_tone_detected: str
    face_shape_detected: str

    # Auto-derived from body photo
    body_photo_url: str
    body_landmarks: JSONB  # MediaPipe Pose 33 keypoints
    shoulder_waist_ratio: float
    frame_classification: str  # narrow, average, broad
    muscularity_level: str  # Claude Vision assessment
    leanness_level: str  # Claude Vision assessment

    # Archetype (computed)
    primary_archetype: str
    secondary_archetype: str
    archetype_scores: JSONB

    created_at, updated_at: datetime
```

### API Endpoints

**New file:** `/Users/imorgado/LOOKSMAXX/looksmaxx-api/app/routers/profile.py`

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/profile/me` | GET | Get user profile with all data |
| `/profile/setup` | POST | Submit minimal questionnaire |
| `/profile/body-photo` | POST | Upload body photo for analysis |
| `/profile/auto-analyze` | POST | Run auto-analysis on photos |

### Frontend Components

**New files:**
- `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/app/profile-setup/page.tsx` (short form)
- `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/components/BodyPhotoUpload.tsx`

**User Flow Update:**
```
Signup → Gender → Ethnicity → [NEW: 5-Question Setup] → Upload (face + body) → Analysis → Results + Coach
```

---

## Phase 2: Complete PSL Scoring Engine

### 2.1 Core Philosophy: Halos and Failos

**The Chain Theory:** Attractiveness is like a chain; the weakest link limits the whole.
- Failos typically matter MORE than Halos
- Removing a major flaw increases SMV more than adding a good trait

**Prioritization:**
1. Eliminate high-impact failos (penalties)
2. Stack halos for compounding effect (bonuses)

### 2.2 Claude Vision Feature Extraction

**Run on face photo (auto during analysis):**

```python
CLAUDE_VISION_PROMPT = """
Analyze this face photo and extract features for PSL rating:

HALOS TO DETECT:
- Hunter blue eyes, positive canthal tilt, deep-set eyes
- Straight hairline (Norwood 0), youthful dense hair
- Chiseled jawline, strong bone structure, hollow cheeks
- Clear glowing skin, golden tan
- Heavy brow ridge, high dimorphism

FAILOS TO DETECT:
- Bug eyes, negative canthal tilt, prey eyes
- Receding hairline (Norwood 2+), thinning hair
- Receding chin, weak jaw, asymmetry
- Acne, scarring, pale/unhealthy complexion
- Weak brow ridge, lack of definition

Return structured JSON with:
- halos_detected: [{feature, confidence, description}]
- failos_detected: [{feature, severity: major|minor, description}]
- skin_clarity: 1-10
- skin_tone: classification
- hairline_norwood: 0-7
- eye_color: classification
- cheek_hollowness: 1-10
"""
```

### 2.3 The Mogger Calculation Formula

**Base Formula (75/20/5 Split):**
```
Score_Base = (Face × 0.75) + (Height × 0.20) + (Physique × 0.05)
```

**Component Definitions:**
- **Face (75%)**: Primary driver. First thing noticed, dictates majority of score.
- **Height (20%)**: Shapes perception of presence/status. Instantly obvious.
- **Physique (5%)**: Multiplier. Cannot compensate for weak face/height, but poor physique drags face down.

**Complete Calculation:**
```python
def calculate_psl_score(face: float, height: float, body: float) -> dict:
    # Step 1: Base weighted average
    base_score = (face * 0.75) + (height * 0.20) + (body * 0.05)

    # Step 2: Single trait bonuses (8.5+ in one category)
    bonuses = 0
    if face >= 8.5: bonuses += 0.30
    if height >= 8.5: bonuses += 0.20
    if body >= 8.5: bonuses += 0.10

    # Step 3: Synergy bonuses (8.5+ in two categories)
    synergy = 0
    if face >= 8.5 and height >= 8.5 and body >= 8.5:
        # Triple synergy overrides pair bonuses
        synergy = 0.35
    else:
        if face >= 8.5 and height >= 8.5: synergy += 0.15
        if face >= 8.5 and body >= 8.5: synergy += 0.10
        if height >= 8.5 and body >= 8.5: synergy += 0.05

    # Step 4: Final score (capped at 10)
    final_score = min(base_score + bonuses + synergy, 10.0)

    # Step 5: Determine tier
    tier = get_tier_from_score(final_score)

    return {
        "base_score": base_score,
        "bonuses": bonuses,
        "synergy": synergy,
        "final_score": final_score,
        "tier": tier
    }
```

**Example Calculation (Triple Mogger):**
```
Input: Face=8.5, Height=8.5, Body=8.5

Base = (8.5 × 0.75) + (8.5 × 0.20) + (8.5 × 0.05)
     = 6.375 + 1.70 + 0.425 = 8.5

Bonuses = +0.30 (face) + +0.20 (height) + +0.10 (body) = +0.60
Synergy = +0.35 (triple synergy, overrides pairs)

Final = 8.5 + 0.60 + 0.35 = 9.45 → GIGACHAD tier
```

### 2.4 Bonus System

```python
PSL_BONUSES = {
    # Single Trait Bonuses (8.5+ in one category)
    "face_elite": {"threshold": 8.5, "bonus": 0.30},
    "height_elite": {"threshold": 8.5, "bonus": 0.20},
    "body_elite": {"threshold": 8.5, "bonus": 0.10},

    # Synergies (8.5+ in two categories)
    "face_height_synergy": {"bonus": 0.15},
    "face_body_synergy": {"bonus": 0.10},
    "height_body_synergy": {"bonus": 0.05},

    # Triple Synergy (8.5+ in ALL THREE)
    "true_mogger": {
        "bonus": 0.35,
        "overrides_pair_bonuses": True,
        "description": "Pushes into True Mogger range"
    }
}
```

### 2.5 Constraint Logic (Failo Rules)

```python
FAILO_RULES = {
    # Failo Dominance Rule
    "major_failo_cap": {
        "triggers": ["receding_chin", "deformity", "severe_asymmetry", "bug_eyes"],
        "effect": "max_tier = LTN regardless of other Halos"
    },

    # Physique Perception Rule
    "body_penalty": {
        "condition": "physique_score < 5.0",
        "effect": "Negatively impacts face_score PERCEPTION (not just average)"
    },

    # Height Gatekeeper
    "height_gatekeeper": {
        "threshold": "5'5\"",
        "effect": "Creates massive deficit, drags to MTN even with high face",
        "example": "Josh Hutcherson (5'5\") - Face is HTN but height drags to MTN"
    }
}
```

### 2.6 Halo/Failo Taxonomy

```python
HALOS = {
    "eyes": [
        "hunter_blue_eyes",
        "positive_canthal_tilt",
        "deep_set_eyes",
        "hollow_under_eyes"
    ],
    "hair": [
        "straight_hairline",
        "norwood_0",
        "youthful_dense_hair"
    ],
    "jaw": [
        "chiseled_jawline",
        "superman_jaw",
        "strong_bone_structure",
        "soft_rounded_jaw"  # contextual
    ],
    "skin": [
        "clear_glowing_skin",
        "golden_tan_skin"
    ],
    "body": [
        "capped_delts",
        "sub_10_bodyfat",
        "aesthetic_physique",
        "broad_shoulders"
    ],
    "height": ["6'0\" - 6'4\""],  # The "Sweet Spot"
    "other": [
        "high_sexual_dimorphism",
        "masculine_features"
    ]
}

FAILOS = {
    "eyes": [
        "bug_eyes",
        "negative_canthal_tilt",
        "prey_eyes"
    ],
    "hair": [
        "receding_hairline",
        "low_effort_hairstyle",
        "norwood_3_plus"
    ],
    "jaw": [
        "receding_chin",  # MAJOR FAILO
        "weak_retrusive_bite",
        "undefined_jaw"
    ],
    "skin": [
        "bad_acne",
        "pale_unhealthy_complexion",
        "scarring"
    ],
    "body": [
        "skinny_neck",
        "high_bodyfat",
        "sloppy_posture",
        "narrow_shoulders"
    ],
    "height": ["< 5'7\""],  # Western standards
    "other": [
        "disfigurements",
        "burn_scars",
        "mouth_breathing_indicators"
    ]
}
```

### 2.7 Complete Tier System (Bell Curve)

| Tier | PSL Range | Percentile | Social Dynamic | Examples |
|------|-----------|------------|----------------|----------|
| **Cursed** | -0.5 | ~0% | "Never Began" | Adam Pearson |
| **Deformity** | 0.5-1.0 | 0.01% | "No Go Zone" - requires medical intervention | Quasimodo, severe burns |
| **Subhuman** | 1.25-1.75 | 0.1% | "Very Unattractive" - danger zone, genetic outliers | Sloth (Goonies) |
| **Incel** | 2.0-3.0 | 2.5% | "Involuntary Celibate" - money/status can't compensate | Danny DeVito (4'10"), Chris Farley |
| **LTN** | 3.5-4.5 | 13.59% | "Invisible Majority" - not ugly enough to be pitied, not attractive enough to be noticed. Gets bad advice ("just be confident") | Michael Cera (5'9"), Mark Zuckerberg |
| **MTN** | 4.75-5.25 | 68.26% | "Human equivalent of plain yogurt" - invisible but not repulsive. Dating depends on personality/social circle | Joseph Gordon-Levitt, Josh Hutcherson |
| **HTN** | 5.5-6.5 | 13.59% | "The Switch Flip" - become visible to women. Positive feedback loop begins. Halo Effect unlocks. | Ryan Gosling (6'0"), Tom Hardy |
| **Chadlite** | 7.0-8.0 | 2.5% | "Looks Become Subjective" - best looking guy in school/gym. Arrogance = confidence, shyness = mystery. Modeling attention. | Cristiano Ronaldo (6'1"), Zac Efron (5'8") |
| **Chad** | 8.25-8.75 | 0.1% | "Life on Easy Mode" - best looking in state. Can live off looks. Never truly rejected. | Henry Cavill (6'0.5"), Brad Pitt |
| **Gigachad** | 9.0-9.5 | 0.01% | "Near mythical status" - Pissor God in prime | Sean O'Pry (6'0"), Dolph Lundgren |
| **True Mogger** | 9.5+ | Apex | "Unmoggable" - effectively does not exist | Theoretical |

### 2.8 Height Score Lookup (Western Male)

```python
HEIGHT_SCORES = {
    "< 5'3\"": 1.0,    # Deformity/Subhuman range
    "5'3\" - 5'4\"": 2.0,
    "5'5\" - 5'7\"": 3.5,    # Incel/LTN range
    "5'8\"": 4.5,
    "5'9\" - 5'10\"": 5.5,   # MTN (Average Western Male ~5'9.5")
    "5'11\"": 6.5,
    "5'11.5\" - 6'0.5\"": 7.5,  # HTN range
    "6'1\" - 6'2.5\"": 8.5,  # Chad/Chadlite "Sweet Spot" - ideal for dating
    "6'3\" - 6'4\"": 8.0,    # Gigachad territory
    "> 6'4\"": 7.5,    # Diminishing returns if proportions fail
}
```

### 2.9 Physique Score Criteria

```python
PHYSIQUE_SCORES = {
    "deformity_subhuman": {
        "range": "0.5-1.75",
        "criteria": ["morbidly_obese", "untreated_natural", "severe_skeletal_issues"]
    },
    "incel": {
        "range": "2.0-3.0",
        "criteria": ["skinny_fat", "poor_frame", "bad_insertions"]
    },
    "ltn": {
        "range": "3.5-4.5",
        "criteria": ["soft", "no_muscle_definition", "poor_posture"]
    },
    "mtn": {
        "range": "4.75-5.25",
        "criteria": ["average_frame", "barely_trained_natural"]
    },
    "htn": {
        "range": "5.5-6.5",
        "criteria": ["good_frame", "decent_insertions", "trained_natural", "model_physique"]
    },
    "chadlite": {
        "range": "7.0-8.0",
        "criteria": ["great_frame", "high_ffmi", "aesthetic", "sub_12_bf"]
    },
    "chad_gigachad": {
        "range": "8.25-9.5",
        "criteria": ["perfect_frame", "elite_ffmi", "genetic_outlier_or_enhanced", "sub_10_bf"]
    }
}
```

### 2.10 Face Score Criteria

```python
FACE_SCORES = {
    "subhuman_incel": {
        "range": "1.0-3.0",
        "criteria": ["severe_asymmetry", "weak_chin", "bug_eyes", "poor_skin_health"]
    },
    "mtn": {
        "range": "4.75-5.25",
        "criteria": ["average_harmony", "lack_of_definition", "no_standout_features"]
    },
    "htn": {
        "range": "5.5-6.5",
        "criteria": ["good_harmony", "some_definition", "minor_failos_only"]
    },
    "chadlite": {
        "range": "7.0-8.0",
        "criteria": ["strong_features", "clear_skin", "positive_canthal_tilt", "defined_jaw"]
    },
    "chad_gigachad": {
        "range": "8.25-9.5",
        "criteria": ["ideally_masculine_dimorphism", "hollow_cheeks", "hunter_eyes", "heavy_brow_ridge"]
    }
}
```

### 2.11 Transformation Potential

```python
TRANSFORMATION_RULES = {
    "max_natural_improvement": 4.0,  # Most men can improve ~4 points naturally
    "diminishing_returns": "Harder to go Chad→Gigachad than Subhuman→Normie",
    "purpose": "Identify specific Failos to fix to unlock next tier",
    "examples": [
        {"failo": "protruding_ears", "fix": "otoplasty", "tier_unlock": "+0.5-1.0"},
        {"failo": "receding_chin", "fix": "genioplasty", "tier_unlock": "+1.0-2.0"},
        {"failo": "weak_jaw", "fix": "jaw_fillers", "tier_unlock": "+0.5-1.0"},
    ]
}
```

---

## Phase 3: Archetype Classification System

### 3.1 Complete Archetype Taxonomy

```python
ARCHETYPES = {
    # ═══════════════════════════════════════════════════════════
    # SOFTBOY CATEGORY - Youthful, delicate, neotenous features
    # ═══════════════════════════════════════════════════════════
    "Softboy": {
        "description": "Youthful, delicate features with neotenous appeal",
        "sub_archetypes": {
            "K-POP Idol": {
                "traits": ["flawless_skin", "soft_jaw", "large_eyes", "slim_build"],
                "style": "Trendy, colorful, experimental fashion",
                "examples": ["Jungkook", "V (BTS)", "Cha Eun-woo"]
            },
            "Softboy": {
                "traits": ["gentle_features", "artistic_vibe", "sensitive_look"],
                "style": "Vintage, thrifted, layered looks",
                "examples": ["Timothée Chalamet", "Young Leonardo DiCaprio"]
            },
            "Academic": {
                "traits": ["intellectual_look", "refined", "understated"],
                "style": "Preppy, glasses, sweaters, blazers",
                "examples": ["Eddie Redmayne", "Tom Hiddleston"]
            }
        },
        "criteria": {
            "gonial_angle": ">= 125°",  # Softer jaw
            "eye_area": ">= 7.5",        # Large, expressive eyes
            "facial_harmony": ">= 70%",
            "facial_leanness": "moderate",
            "dimorphism": "low_to_moderate"
        }
    },

    # ═══════════════════════════════════════════════════════════
    # PRETTYBOY CATEGORY - Symmetrical, harmonious, effortless cool
    # ═══════════════════════════════════════════════════════════
    "Prettyboy": {
        "description": "Effortlessly attractive with perfect harmony",
        "sub_archetypes": {
            "Skater": {
                "traits": ["casual_cool", "athletic_lean", "relaxed_vibe"],
                "style": "Streetwear, baggy pants, sneakers",
                "examples": ["Young Heath Ledger"]
            },
            "Prettyboy": {
                "traits": ["symmetrical", "harmonious", "classic_beauty"],
                "style": "Clean, fitted, minimal",
                "examples": ["Francisco Lachowski", "Sean O'Pry"]
            },
            "Surfer": {
                "traits": ["sun-kissed", "athletic", "carefree"],
                "style": "Beach casual, natural fabrics",
                "examples": ["Chris Hemsworth (young)"]
            }
        },
        "criteria": {
            "harmony_score": ">= 75%",
            "facial_symmetry": ">= 8.5",
            "eye_area": ">= 7.0",
            "positive_canthal_tilt": True,
            "clear_skin": ">= 8.0"
        }
    },

    # ═══════════════════════════════════════════════════════════
    # ROBUST PRETTYBOY - Pretty features with edge/intensity
    # ═══════════════════════════════════════════════════════════
    "Robust_Prettyboy": {
        "description": "Pretty boy features with masculine edge or intensity",
        "sub_archetypes": {
            "Fallen Angel": {
                "traits": ["ethereal", "intense", "mysterious"],
                "style": "Dark romantic, leather, black",
                "examples": ["Young Jared Leto", "Jordan Barrett"]
            },
            "Prince": {
                "traits": ["regal", "refined", "elegant"],
                "style": "Tailored suits, classic elegance",
                "examples": ["Young Alain Delon", "Matt Bomer"]
            },
            "Bad Boy": {
                "traits": ["rebellious", "smoldering", "dangerous_appeal"],
                "style": "Leather jackets, boots, rough edges",
                "examples": ["James Dean", "Young Johnny Depp"]
            },
            "Artist": {
                "traits": ["creative", "unconventional", "magnetic"],
                "style": "Eclectic, statement pieces",
                "examples": ["Harry Styles", "Zayn Malik"]
            }
        },
        "criteria": {
            "harmony_score": ">= 70%",
            "eye_intensity": ">= 7.5",
            "gonial_angle": "115-125°",  # Defined but not extreme
            "cheekbone_prominence": ">= 7.0",
            "hunter_eyes": True
        }
    },

    # ═══════════════════════════════════════════════════════════
    # CHAD CATEGORY - Strong masculine features, high dimorphism
    # ═══════════════════════════════════════════════════════════
    "Chad": {
        "description": "Strong masculine features with high sexual dimorphism",
        "sub_archetypes": {
            "Vampire": {
                "traits": ["sharp_features", "pale", "mysterious", "hollow_cheeks"],
                "style": "Dark, sophisticated, elegant",
                "examples": ["Robert Pattinson", "Ian Somerhalder"]
            },
            "Superman": {
                "traits": ["heroic", "strong_jaw", "broad_build", "classic_handsome"],
                "style": "Classic American, clean-cut",
                "examples": ["Henry Cavill", "Tyler Hoechlin", "David Gandy"]
            },
            "Jock": {
                "traits": ["athletic", "confident", "dominant_presence"],
                "style": "Athletic wear, casual sporty",
                "examples": ["Chris Evans", "Michael B. Jordan"]
            },
            "Casanova": {
                "traits": ["charming", "seductive", "smooth"],
                "style": "Tailored, sophisticated, European",
                "examples": ["George Clooney", "Pierce Brosnan"]
            },
            "Executive": {
                "traits": ["powerful", "authoritative", "successful_look"],
                "style": "Power suits, luxury watches",
                "examples": ["Jon Hamm", "Gabriel Macht"]
            },
            "Pharaoh": {
                "traits": ["exotic", "regal", "chiseled", "middle_eastern_features"],
                "style": "Luxurious, gold accents, designer",
                "examples": ["Egyptian models", "Fares Fares"]
            }
        },
        "criteria": {
            "gonial_angle": "<= 120°",     # Strong jaw
            "bigonial_width": ">= 7.5",
            "brow_ridge": "prominent",
            "dimorphism": "high",
            "physique_score": ">= 7.0"
        }
    },

    # ═══════════════════════════════════════════════════════════
    # HYPERMASCULINE - Extreme masculine features
    # ═══════════════════════════════════════════════════════════
    "Hypermasculine": {
        "description": "Extreme masculine features, rugged and powerful",
        "sub_archetypes": {
            "Aquaman": {
                "traits": ["tall", "muscular", "long_hair", "rugged_handsome"],
                "style": "Relaxed, bohemian, natural fabrics",
                "examples": ["Jason Momoa", "Chris Hemsworth"]
            },
            "Hypermasculine": {
                "traits": ["extreme_bone_structure", "heavy_brow", "dominant"],
                "style": "Minimalist, masculine basics",
                "examples": ["Dolph Lundgren (prime)", "Michael Fassbender"]
            },
            "Outlaw": {
                "traits": ["rough", "weathered", "dangerous"],
                "style": "Leather, denim, boots, rugged",
                "examples": ["Clint Eastwood (young)", "Josh Brolin"]
            },
            "Countryman": {
                "traits": ["rugged", "outdoorsy", "strong_silent"],
                "style": "Workwear, flannel, boots",
                "examples": ["Yellowstone cast", "Sam Elliott (young)"]
            }
        },
        "criteria": {
            "gonial_angle": "<= 115°",    # Extremely strong jaw
            "brow_ridge": "very_prominent",
            "facial_width": ">= 8.0",
            "height": ">= 6'1\"",
            "physique": ">= 8.0"
        }
    },

    # ═══════════════════════════════════════════════════════════
    # OGRE - Maximum size and mass, intimidating presence
    # ═══════════════════════════════════════════════════════════
    "Ogre": {
        "description": "Maximum size and mass, intimidating physical presence",
        "sub_archetypes": {
            "Viking": {
                "traits": ["massive", "bearded", "warrior_look", "norse_features"],
                "style": "Rugged, fur, leather, minimalist",
                "examples": ["Hafþór Björnsson", "Alexander Skarsgård (Northman)"]
            },
            "Bodybuilder": {
                "traits": ["extreme_muscle", "massive_frame", "imposing"],
                "style": "Fitted to show physique, tank tops",
                "examples": ["Arnold Schwarzenegger (prime)", "Dwayne Johnson"]
            }
        },
        "criteria": {
            "height": ">= 6'2\"",
            "physique": ">= 9.0",
            "frame_size": "very_large",
            "facial_width": ">= 8.5",
            "intimidation_factor": "high"
        }
    }
}
```

### 3.2 Classification Flow

```python
class ArchetypeClassifier:
    def classify(self, face_metrics: dict, body_metrics: dict, height: float) -> ArchetypeResult:

        # Step 1: Determine main category based on key metrics
        category_scores = {}

        # Softboy indicators
        category_scores["Softboy"] = self._score_softboy(face_metrics)

        # Prettyboy indicators
        category_scores["Prettyboy"] = self._score_prettyboy(face_metrics)

        # Robust Prettyboy indicators
        category_scores["Robust_Prettyboy"] = self._score_robust_prettyboy(face_metrics)

        # Chad indicators
        category_scores["Chad"] = self._score_chad(face_metrics, body_metrics)

        # Hypermasculine indicators
        category_scores["Hypermasculine"] = self._score_hypermasculine(face_metrics, body_metrics, height)

        # Ogre indicators
        category_scores["Ogre"] = self._score_ogre(body_metrics, height)

        # Step 2: Get top category
        main_category = max(category_scores, key=category_scores.get)

        # Step 3: Determine sub-archetype within category
        sub_archetype = self._classify_sub_archetype(main_category, face_metrics, body_metrics)

        # Step 4: Use Claude for edge cases and final refinement
        if self._needs_llm_refinement(category_scores):
            return self._claude_refine(face_metrics, body_metrics, category_scores)

        return ArchetypeResult(
            main_category=main_category,
            sub_archetype=sub_archetype,
            category_scores=category_scores,
            style_recommendations=ARCHETYPES[main_category]["sub_archetypes"][sub_archetype]["style"],
            celebrity_examples=ARCHETYPES[main_category]["sub_archetypes"][sub_archetype]["examples"]
        )

    def _score_softboy(self, face_metrics: dict) -> float:
        score = 0
        if face_metrics.get("gonial_angle", 0) >= 125: score += 2
        if face_metrics.get("eye_area_score", 0) >= 7.5: score += 2
        if face_metrics.get("harmony_score", 0) >= 70: score += 1
        if face_metrics.get("dimorphism", "") == "low": score += 2
        return score / 7  # Normalize

    def _score_chad(self, face_metrics: dict, body_metrics: dict) -> float:
        score = 0
        if face_metrics.get("gonial_angle", 180) <= 120: score += 2
        if face_metrics.get("brow_ridge", "") == "prominent": score += 1
        if face_metrics.get("dimorphism", "") == "high": score += 2
        if body_metrics.get("physique_score", 0) >= 7: score += 2
        return score / 7
```

### 3.3 Complete Training Data for Classification

```python
ARCHETYPE_TRAINING_DATA = {
    # ═══════════════════════════════════════════════════════════
    # SOFTBOY CATEGORY
    # ═══════════════════════════════════════════════════════════
    "K-POP Idol": {
        "genetic_precursors": {
            "ethnicity": ["East Asian", "SE Asian"],
            "dimorphism": "low",
            "body_type": "ectomorphic",
            "midface": "flat_or_soft"
        },
        "required_styling": {
            "hair": ["straight", "layered"],
            "facial_hair": "clean_shaven",
            "fit": "slim_tailored",
            "colors": "high_contrast"
        }
    },
    "Softboy": {
        "genetic_precursors": {
            "body_type": "ectomorphic",
            "dimorphism": "low",
            "height": "below_average"
        },
        "required_styling": {
            "hair": "long",
            "facial_hair": "clean_shaven",
            "colors": "light",
            "fit": "oversized"
        }
    },
    "Academic": {
        "genetic_precursors": {
            "body_type": "ectomorphic",
            "dimorphism": "low",
            "hair_texture": "good"
        },
        "required_styling": {
            "hair": "medium_long",
            "facial_hair": "clean_shaven",
            "accessories": "subtle",
            "grooming": "pristine"
        }
    },

    # ═══════════════════════════════════════════════════════════
    # PRETTYBOY CATEGORY
    # ═══════════════════════════════════════════════════════════
    "Skater": {
        "genetic_precursors": {
            "dimorphism": "low_balanced",
            "soft_features": "good",
            "skin_quality": "good",
            "body_type": "ectomorphic"
        },
        "required_styling": {
            "hair": "messy",
            "fit": "loose_thrift_streetwear",
            "facial_hair": "clean_shaven",
            "colors": "dark",
            "jewelry": "optional"
        }
    },
    "Prettyboy": {
        "genetic_precursors": {
            "dimorphism": "low_balanced",
            "soft_features": "good",
            "skin_quality": "good",
            "body_type": "ectomorphic"
        },
        "required_styling": {
            "hair": ["clean", "voluminous"],
            "facial_hair": "clean_shaven",
            "fit": ["slim", "oversized"],
            "grooming": "pristine"
        }
    },
    "Surfer": {
        "genetic_precursors": {
            "dimorphism": "balanced",
            "coloring": "light_hair_eyes_skin",
            "body_type": "ecto_mesomorphic",
            "soft_features": "good"
        },
        "required_styling": {
            "skin": "tanned",
            "hair": "long_tousled",
            "fit": "loose_casual"
        }
    },

    # ═══════════════════════════════════════════════════════════
    # ROBUST PRETTYBOY CATEGORY
    # ═══════════════════════════════════════════════════════════
    "Fallen Angel": {
        "genetic_precursors": {
            "hair_texture": "good",
            "body_type": "ecto_mesomorphic",
            "soft_features": "good",
            "dimorphism": "balanced"
        },
        "required_styling": {
            "hair": "long_tousled",
            "facial_hair": "clean_shaven",
            "colors": "high_contrast"
        }
    },
    "Prince": {
        "genetic_precursors": {
            "hair_texture": "good",
            "body_type": "ecto_mesomorphic",
            "soft_features": "good",
            "dimorphism": "balanced_above_average"
        },
        "required_styling": {
            "hair": "long_structured",
            "fit": "old_money",
            "aesthetic": "polished",
            "grooming": "pristine"
        }
    },
    "Bad Boy": {
        "genetic_precursors": {
            "coloring": "dark_hair_features",
            "dimorphism": "balanced_above_average",
            "body_type": "ecto_mesomorphic"
        },
        "required_styling": {
            "colors": "dark_high_contrast",
            "jacket": "leather",
            "facial_hair": ["clean_shaven", "light_stubble"],
            "hair": "tousled"
        }
    },
    "Artist": {
        "genetic_precursors": {
            "ethnicity": "African",
            "dimorphism": "balanced",
            "body_type": "ecto_mesomorphic"
        },
        "required_styling": {
            "fit": "layered",
            "hair": ["medium_long_braided", "dreadlocks"],
            "accessories": "jewelry",
            "tattoos": True
        }
    },

    # ═══════════════════════════════════════════════════════════
    # CHAD CATEGORY
    # ═══════════════════════════════════════════════════════════
    "Vampire": {
        "genetic_precursors": {
            "skin": "pale_light_baseline",
            "bone_structure": "angular",
            "facial_contrast": "high",
            "coloring": "dark_hair_features",
            "body_type": "ecto_mesomorphic"
        },
        "required_styling": {
            "colors": "dark",
            "fit": ["tailored", "suits"],
            "hair": "tousled",
            "facial_hair": "clean_shaven"
        }
    },
    "Superman": {
        "genetic_precursors": {
            "skin": "light_baseline",
            "dimorphism": "high",
            "facial_contrast": "high",
            "coloring": "dark_hair_features",
            "body_type": "mesomorphic"
        },
        "required_styling": {
            "fit": "tight_structured",
            "hair": "clean",
            "colors": "understated",
            "facial_hair": "clean_shaven"
        }
    },
    "Casanova": {
        "genetic_precursors": {
            "ethnicity": "Mediterranean",
            "skin": "olive_tanned",
            "dimorphism": "balanced",
            "body_type": "ecto_mesomorphic"
        },
        "required_styling": {
            "hair": "medium_long",
            "colors": "dark_relaxed_understated",
            "facial_hair": ["light_stubble", "heavy_stubble"]
        }
    },
    "Executive": {
        "genetic_precursors": {
            "skin_quality": "great",
            "dimorphism": "balanced_high",
            "body_type": "ecto_mesomorphic"
        },
        "required_styling": {
            "fit": ["suits", "structured"],
            "hair": ["slicked", "clean"],
            "facial_hair": ["clean_shaven", "light_stubble"]
        }
    },
    "Pharaoh": {
        "genetic_precursors": {
            "ethnicity": "Middle Eastern",
            "skin_quality": "great",
            "dimorphism": "balanced_high",
            "soft_features": "good"
        },
        "required_styling": {
            "grooming": "pristine",
            "hair": "short",
            "facial_hair": ["light_stubble", "beard"]
        }
    },
    "Jock": {
        "genetic_precursors": {
            "skin": "light_baseline",
            "coloring": "light_hair_eyes",
            "dimorphism": "high",
            "body_type": "mesomorphic"
        },
        "required_styling": {
            "fit": "tight_structured",
            "hair": "clean",
            "style": "athletic",
            "facial_hair": "clean_shaven"
        }
    },

    # ═══════════════════════════════════════════════════════════
    # HYPERMASCULINE CATEGORY
    # ═══════════════════════════════════════════════════════════
    "Hypermasculine": {
        "genetic_precursors": {
            "frame": "large",
            "body_type": "meso_endomorphic",
            "dimorphism": "very_high",
            "androgen_markers": "high",
            "lower_third": "strong"
        },
        "required_styling": {
            "hair": ["buzzcut", "short"],
            "fit": "tight_fitted",
            "tattoos": "optional"
        }
    },
    "Aquaman": {
        "genetic_precursors": {
            "frame": "large",
            "body_type": "endo_mesomorphic",
            "dimorphism": "high",
            "coloring": "dark_hair_features",
            "ethnicity": "Pacific Islander"
        },
        "required_styling": {
            "hair": "long",
            "facial_hair": ["heavy_stubble", "beard"],
            "tattoos": "traditional",
            "fit": ["loose", "tight_fitted"]
        }
    },
    "Outlaw": {
        "genetic_precursors": {
            "frame": "large",
            "body_type": "ecto_mesomorphic",
            "dimorphism": "balanced",
            "skin": "light_baseline",
            "height": "tall"
        },
        "required_styling": {
            "hair": ["bleached", "long"],
            "facial_hair": "clean_shaven",
            "style": "grunge",
            "accessories": "jewelry",
            "tattoos": True
        }
    },
    "Countryman": {
        "genetic_precursors": {
            "ethnicity": "European",
            "frame": "large",
            "body_type": "mesomorphic",
            "dimorphism": "balanced"
        },
        "required_styling": {
            "style": "rugged",
            "facial_hair": ["stubble", "beard"],
            "clothing": ["boots", "denim", "tanks"],
            "accessories": "jewelry"
        }
    },

    # ═══════════════════════════════════════════════════════════
    # OGRE CATEGORY
    # ═══════════════════════════════════════════════════════════
    "Viking": {
        "genetic_precursors": {
            "frame": "very_large",
            "dimorphism": "high",
            "body_type": "endo_mesomorphic",
            "size_acquisition": "efficient",
            "skin": "light_baseline"
        },
        "required_styling": {
            "hair": ["very_short", "long"],
            "facial_hair": ["heavy_beard", "long_stubble"],
            "tattoos": "optional"
        }
    },
    "Bodybuilder": {
        "genetic_precursors": {
            "frame": "very_large",
            "dimorphism": "high",
            "body_type": "endo_mesomorphic",
            "size_acquisition": "efficient"
        },
        "required_styling": {
            "fit": "tight_fitted",
            "tattoos": "optional"
        }
    }
}
```

### 3.4 Archetype Classification Algorithm

```python
def classify_archetype(
    face_metrics: dict,
    body_metrics: dict,
    ethnicity: str,
    height_cm: int,
    skin_tone: str
) -> ArchetypeResult:

    # Extract key features
    dimorphism = calculate_dimorphism(face_metrics)
    body_type = classify_body_type(body_metrics)
    frame_size = body_metrics.get("frame_size")
    soft_features = face_metrics.get("soft_feature_score")
    skin_quality = face_metrics.get("skin_clarity")

    # Score each archetype based on genetic precursor match
    scores = {}
    for archetype, data in ARCHETYPE_TRAINING_DATA.items():
        precursors = data["genetic_precursors"]
        score = 0
        max_score = 0

        # Ethnicity match
        if "ethnicity" in precursors:
            max_score += 2
            if ethnicity in precursors["ethnicity"]:
                score += 2

        # Dimorphism match
        if "dimorphism" in precursors:
            max_score += 3
            if matches_dimorphism(dimorphism, precursors["dimorphism"]):
                score += 3

        # Body type match
        if "body_type" in precursors:
            max_score += 2
            if body_type == precursors["body_type"]:
                score += 2

        # Frame size match
        if "frame" in precursors:
            max_score += 2
            if matches_frame(frame_size, precursors["frame"]):
                score += 2

        # Soft features match
        if "soft_features" in precursors:
            max_score += 1
            if soft_features >= 7:
                score += 1

        scores[archetype] = score / max_score if max_score > 0 else 0

    # Get top matches
    sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)

    return ArchetypeResult(
        primary_archetype=sorted_scores[0][0],
        primary_confidence=sorted_scores[0][1],
        secondary_archetype=sorted_scores[1][0],
        secondary_confidence=sorted_scores[1][1],
        styling_recommendations=ARCHETYPE_TRAINING_DATA[sorted_scores[0][0]]["required_styling"],
        all_scores=dict(sorted_scores[:5])
    )
```

### 3.5 Body Type Classification

```python
BODY_TYPES = {
    "ectomorphic": {
        "criteria": ["slim_frame", "low_muscle_mass", "fast_metabolism"],
        "shoulder_waist_ratio": "< 1.35"
    },
    "mesomorphic": {
        "criteria": ["athletic_build", "moderate_muscle", "balanced"],
        "shoulder_waist_ratio": "1.35-1.50"
    },
    "endomorphic": {
        "criteria": ["larger_frame", "higher_bodyfat", "slower_metabolism"],
        "shoulder_waist_ratio": "> 1.50 or high bf%"
    },
    "ecto_mesomorphic": {
        "criteria": ["lean_athletic", "visible_muscle", "low_bodyfat"],
        "shoulder_waist_ratio": "1.40-1.55"
    },
    "endo_mesomorphic": {
        "criteria": ["muscular_large", "powerful_build", "high_mass"],
        "shoulder_waist_ratio": "> 1.50 with high muscle"
    },
    "meso_endomorphic": {
        "criteria": ["thick_build", "strong", "higher_bodyfat"],
        "shoulder_waist_ratio": "> 1.45 with moderate bf%"
    }
}

def classify_body_type(body_metrics: dict) -> str:
    sw_ratio = body_metrics.get("shoulder_waist_ratio", 1.4)
    bf_percent = body_metrics.get("body_fat_percent", 15)
    muscle_mass = body_metrics.get("muscularity_score", 5)

    if sw_ratio < 1.35 and bf_percent < 15:
        return "ectomorphic"
    elif sw_ratio >= 1.50 and muscle_mass >= 8 and bf_percent < 12:
        return "endo_mesomorphic"
    elif sw_ratio >= 1.45 and muscle_mass >= 7:
        return "meso_endomorphic"
    elif sw_ratio >= 1.40 and muscle_mass >= 6 and bf_percent < 15:
        return "ecto_mesomorphic"
    elif sw_ratio >= 1.35 and bf_percent < 18:
        return "mesomorphic"
    else:
        return "endomorphic"
```

### 3.6 Dimorphism Classification

```python
DIMORPHISM_LEVELS = {
    "low": {
        "gonial_angle": ">= 130°",
        "brow_ridge": "minimal",
        "jawline": "soft_undefined"
    },
    "low_balanced": {
        "gonial_angle": "125-130°",
        "features": "harmonious_soft"
    },
    "balanced": {
        "gonial_angle": "118-125°",
        "features": "neutral"
    },
    "balanced_above_average": {
        "gonial_angle": "115-120°",
        "jawline": "defined"
    },
    "high": {
        "gonial_angle": "110-118°",
        "brow_ridge": "prominent",
        "jawline": "very_defined"
    },
    "very_high": {
        "gonial_angle": "< 110°",
        "brow_ridge": "heavy",
        "jawline": "extremely_defined",
        "androgen_markers": "high"
    }
}
```

---

## Phase 3: LLM Coach (Claude)

### Backend Service

**New file:** `/Users/imorgado/LOOKSMAXX/looksmaxx-api/app/services/llm_coach.py`

```python
class LLMCoachService:
    def __init__(self):
        self.client = anthropic.Anthropic()
        self.archetype_classifier = ArchetypeClassifier()

    async def analyze_and_coach(self, context: CoachContext) -> CoachResult:
        """Main entry point - combines all analysis"""
        return CoachResult(
            archetype=self.archetype_classifier.classify(context.face_metrics),
            hairstyle_recs=await self._get_hairstyle_recs(context),
            skincare_routine=await self._get_skincare(context),
            action_plan=await self._get_action_plan(context)
        )

    async def _get_hairstyle_recs(self, ctx) -> HairstyleRecs:
        """Use face shape + archetype to recommend hairstyles"""
        prompt = f"""
        Face shape: {ctx.face_shape_detected}
        Archetype: {ctx.archetype.primary}
        Hairline: {ctx.hairline_status}
        Hair color: {ctx.hair_color}

        Recommend 3 hairstyles that would:
        1. Complement their face shape
        2. Enhance their archetype
        3. Work with their hairline
        """
        # Claude generates personalized recommendations

    async def chat_response(self, messages, context) -> AsyncIterator[str]:
        """Streaming chat with full context"""
        async with self.client.messages.stream(...) as stream:
            async for text in stream.text_stream:
                yield text
```

### Context Object

```python
@dataclass
class CoachContext:
    # From existing analysis
    harmony_score: float
    face_metrics: dict  # All 70+ metrics
    strengths: List[str]
    flaws: List[str]
    face_shape_detected: str

    # From body analysis
    body_metrics: dict  # MediaPipe Pose results
    muscularity_level: str
    leanness_level: str

    # From minimal questionnaire
    height_cm: int
    goals: List[str]
    budget_level: str
    timeline: str
    hair_color: str

    # Computed
    archetype: ArchetypeResult
```

### API Endpoints

**New file:** `/Users/imorgado/LOOKSMAXX/looksmaxx-api/app/routers/coach.py`

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/coach/analyze` | POST | Full analysis (archetype + all recommendations) |
| `/coach/hairstyle` | GET | Hairstyle recommendations |
| `/coach/skincare` | GET | Skincare routine |
| `/coach/action-plan` | GET | Personalized action plan |
| `/coach/chat` | POST | Chat message |
| `/coach/chat/stream` | POST | Streaming chat responses |

### Frontend Integration

**New file:** `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/components/results/tabs/CoachTab.tsx`

Layout:
```
┌─────────────────────────────────────────────────────────┐
│  YOUR ARCHETYPE                                          │
│  ┌─────────────┐  Primary: RUGGED MASCULINE (78%)       │
│  │  [Avatar]   │  Secondary: Classic (15%)              │
│  │             │  "Strong bone structure with           │
│  └─────────────┘   masculine edge"                      │
├─────────────────────────────────────────────────────────┤
│  HAIRSTYLE RECOMMENDATIONS          SKINCARE ROUTINE     │
│  ┌───┐ ┌───┐ ┌───┐                  Morning:            │
│  │ 1 │ │ 2 │ │ 3 │ ←swipe          • Cleanser           │
│  └───┘ └───┘ └───┘                  • SPF 50             │
│  [Try This Look] button             Evening:             │
│                                      • Retinol            │
├─────────────────────────────────────────────────────────┤
│  ACTION PLAN                                             │
│  Phase 1: Foundational → Phase 2: Enhancement → ...     │
├─────────────────────────────────────────────────────────┤
│  💬 ASK YOUR COACH                                       │
│  "What hairstyle would work best for my face shape?"    │
│  [Send]                                                  │
└─────────────────────────────────────────────────────────┘
```

**Modify:** `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/types/results.ts` - Add 'coach' to ResultsTab

---

## Phase 3: Visual Mockups (Nano Banana)

### Technology

Use **Google Nano Banana (Gemini 2.5 Flash Image)** via Vertex AI or AI Studio:
- Best-in-class identity preservation
- Native hairstyle editing support
- 8x faster than alternatives
- Up to 4K output

### Backend Service

**New file:** `/Users/imorgado/LOOKSMAXX/looksmaxx-api/app/services/mockup_generator.py`

```python
class MockupGenerator:
    async def generate_hairstyle(user_photo, hairstyle_prompt) -> MockupResult
    async def generate_archetype_visualization(user_photo, archetype) -> MockupResult
    async def generate_style_mockup(user_photo, style_category) -> MockupResult
    async def generate_transformation_preview(user_photo, procedures) -> MockupResult
```

### API Endpoints

**New file:** `/Users/imorgado/LOOKSMAXX/looksmaxx-api/app/routers/mockups.py`

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/mockups/hairstyle` | POST | Generate hairstyle mockup |
| `/mockups/archetype` | POST | Generate archetype visualization |
| `/mockups/style` | POST | Generate outfit/style mockup |
| `/mockups/transformation` | POST | Generate before/after preview |
| `/mockups/presets` | GET | Get available presets |
| `/mockups/{id}` | GET | Retrieve cached mockup |

### Storage

- S3 bucket for generated mockups
- 30-day retention for user mockups
- CloudFront CDN for delivery

### Frontend Components

**New files:**
- `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/components/mockups/MockupViewer.tsx`
- `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/components/mockups/HairstyleCarousel.tsx`
- `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/components/mockups/TransformationPreview.tsx`
- `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/contexts/MockupContext.tsx`

---

## Phase 4: Body Photo Analysis

### Implementation

Add optional body photo upload to questionnaire flow:
1. User uploads front-facing body photo
2. Nano Banana + Claude analyze for:
   - Shoulder-to-waist ratio estimation
   - Body type classification (ecto/meso/endo)
   - Muscularity level
   - Overall physique assessment
3. Auto-fill relevant questionnaire fields
4. Store analysis with user profile

### API Endpoint

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/coach/analyze-physique` | POST | Analyze body photo |

---

## Critical Files to Modify

### Backend (looksmaxx-api)
| File | Changes |
|------|---------|
| `app/models/user.py` | Add questionnaire relationship |
| `app/routers/__init__.py` | Register new routers (questionnaire, coach, mockups) |
| `app/main.py` | Include new routers |
| `requirements.txt` | Add `anthropic`, `google-cloud-aiplatform` |

### Frontend (looksmaxx-app)
| File | Changes |
|------|---------|
| `src/components/Providers.tsx` | Add QuestionnaireProvider, MockupProvider |
| `src/app/ethnicity/page.tsx` | Change navigation to /questionnaire |
| `src/types/results.ts` | Add 'coach' and 'mockups' to ResultsTab |
| `src/lib/api.ts` | Add coach and mockup API methods |
| `src/contexts/ResultsContext.tsx` | Add coach context integration |

---

## Environment Variables Required

### Backend
```
ANTHROPIC_API_KEY=sk-...
GOOGLE_CLOUD_PROJECT=...
GOOGLE_APPLICATION_CREDENTIALS=...
```

### Frontend
```
NEXT_PUBLIC_COACH_ENABLED=true
```

---

## Implementation Order

### Phase 1: Foundation + Profile Setup (Days 1-3)
- [ ] Create `UserProfile` model + migration
- [ ] Create `/profile/setup` endpoint (height, goals, budget, timeline)
- [ ] Create profile setup page (minimal questionnaire)
- [ ] Update user flow navigation

### Phase 2: Claude Vision Feature Extraction (Days 4-6)
- [ ] Create `ClaudeVisionService` for face photo analysis
- [ ] Extract: skin clarity, skin tone, hairline quality, eye color, cheek hollowness
- [ ] Store extracted features in `UserProfile`
- [ ] Run auto-analysis after face photo upload

### Phase 3: PSL Scoring Engine (Days 7-10)
- [ ] Create `PSLScoringEngine` with base formula
- [ ] Implement bonus system (single, synergy, triple mogger)
- [ ] Implement Failo constraint logic (dominance, body penalty, height gatekeeper)
- [ ] Create Halo/Failo taxonomy classification
- [ ] Implement tier classification (Subhuman → Gigachad)
- [ ] Create height score lookup table

### Phase 4: Body Photo Analysis (Days 11-13)
- [ ] Add MediaPipe Pose to backend (body landmarks)
- [ ] Create body photo upload endpoint
- [ ] Integrate Claude Vision for muscularity/leanness/body fat
- [ ] Calculate shoulder-waist ratio from pose landmarks
- [ ] Feed body score into PSL formula

### Phase 5: Archetype Classification (Days 14-16)
- [ ] Create `ArchetypeClassifier` service with rules
- [ ] Map existing metrics to archetype criteria
- [ ] Add Claude fallback for edge cases
- [ ] Store archetype results in UserProfile

### Phase 6: LLM Coach Service (Days 17-21)
- [ ] Create `LLMCoachService` with Claude integration
- [ ] Implement hairstyle recommendations based on face shape + archetype
- [ ] Implement skincare routine based on skin analysis
- [ ] Create action plan generator using PSL score + flaws
- [ ] Build streaming chat endpoint

### Phase 7: Coach UI (Days 22-26)
- [ ] Create CoachTab component
- [ ] Build PSL score display with tier badge
- [ ] Build archetype display card
- [ ] Create hairstyle carousel
- [ ] Add skincare routine display
- [ ] Implement chat interface

### Phase 8: Nano Banana Mockups (Days 27-31)
- [ ] Integrate Nano Banana API (Vertex AI)
- [ ] Implement hairstyle mockup generation
- [ ] Create MockupViewer with before/after slider
- [ ] Add "Try This Look" functionality
- [ ] Set up S3 storage for mockups

### Phase 9: Polish & Integration (Days 32-35)
- [ ] Connect all components end-to-end
- [ ] Add caching for expensive LLM calls
- [ ] Implement rate limiting by user plan
- [ ] Error handling and fallbacks
- [ ] End-to-end testing with celebrity ground truth

---

## Cost Estimates

| Service | Cost | Volume |
|---------|------|--------|
| Claude 3.5 Sonnet | ~$0.01/analysis | Per coach session |
| Nano Banana | ~$0.02/image | Per mockup |
| MediaPipe Pose | Free | Client-side processing |
| S3 Storage | ~$0.02/GB | Mockup storage |

**Estimated monthly cost for 1000 active users:** $100-200

---

## Summary

This plan achieves **minimal user friction** with **comprehensive PSL scoring**:

### Data Collection (Minimal Friction)
1. **User provides only:** Height, goals, budget, timeline (4 questions)
2. **Auto-derived from face photo:** 70+ landmark metrics + Claude Vision (skin, hairline, eye color, cheek hollowness)
3. **Auto-derived from body photo:** MediaPipe Pose + Claude Vision (physique, muscularity, leanness)

### Scoring System (Comprehensive)
1. **PSL Formula:** Face (75%) + Height (20%) + Body (5%)
2. **Bonus System:** Single category, synergy, and "True Mogger" bonuses
3. **Failo Rules:** Dominance rule, body penalty, height gatekeeper
4. **Tier Classification:** Subhuman → Gigachad (8 tiers with percentiles)

### AI Coach Features
1. **Archetype Classification:** Pretty Boy, Rugged, Classic, Hunter (rule-based + Claude fallback)
2. **Personalized Recommendations:** Hairstyle, skincare, action plan based on flaws
3. **Visual Mockups:** Nano Banana for hairstyle try-on with identity preservation
4. **Chat Interface:** Ask questions about their score and recommendations

### Celebrity Ground Truth
Plan includes validation against known celebrity ratings (Josh Hutcherson, Zac Efron, Henry Cavill, etc.) to ensure accuracy.
