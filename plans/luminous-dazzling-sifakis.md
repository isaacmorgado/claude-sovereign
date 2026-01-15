# E-Commerce Funnel Build Guide: Complete Product Recommendation System

## Overview
Transform the LOOKSMAXX advice system from diagnostic-only to a comprehensive e-commerce funnel with product recommendations, analytics tracking, backend API integration, and email capture.

## Build Scope
- ✅ **Product Recommendations**: Daily Stack + Corrective (State A) + Maintenance (State B)
- ✅ **Analytics & Tracking**: Click tracking, conversion metrics, A/B testing
- ✅ **Backend API**: Endpoints for tracking clicks, user stacks, recommendation analytics
- ✅ **Email Capture**: Users can email their Daily Stack to themselves
- ✅ **Mixed Affiliates**: Amazon Associates + direct brand links
- ✅ **UI Integration**: Hero element (Daily Stack) + product sections in PlanTab

## Architecture Decision
Keep both products AND procedures. Products are additive monetization layer.

---

## Existing Documentation & Resources

### Implementation Guides (Already Written)
1. **`/Users/imorgado/LOOKSMAXX/looksmaxx-app/supplement_implementation.md`** (1100+ lines)
   - Complete 7-phase implementation guide
   - Copy-paste ready code for all product features
   - Includes: types, product_db.ts, daily-stack.ts, ProductCard, DailyStackCard, integration steps
   - **Use this as the primary reference for Phases 1-4**

2. **`/Users/imorgado/LOOKSMAXX/looksmaxx-app/docs/SUPPLEMENTS_GUIDE.md`**
   - Research-backed supplement guide with 26+ products
   - Includes evidence levels, dosages, costs, timelines
   - **Already implemented in `src/lib/recommendations/supplements.ts`**

3. **`/Users/imorgado/LOOKSMAXX/TECHNICAL_SPECS.md`**
   - Complete tech stack documentation
   - Backend: FastAPI, PostgreSQL, InsightFace
   - Frontend: Next.js 14, TypeScript, Tailwind, Framer Motion

### Key Source Files (Already Exist - DO NOT Rebuild)
- `src/lib/recommendations/supplements.ts` (699 lines) - 26 products database
- `src/lib/faceiq-scoring.ts` (123KB) - Scoring engine
- `src/lib/insights-engine.ts` (64KB) - Insights generation
- `src/contexts/ResultsContext.tsx` - Results state management
- `src/components/results/tabs/PlanTab.tsx` - Where we'll add product sections
- `src/types/results.ts` (299 lines) - Where we'll add Product types

### Backend Structure (Already Built)
- `looksmaxx-api/app/routers/` - API routes (detection, analyses, auth, payments)
- `looksmaxx-api/app/services/` - Business logic (detection, insights_engine)
- `looksmaxx-api/app/models/` - Database models (User, Analysis, Payment)
- Database: PostgreSQL on Railway (https://api-production-6148.up.railway.app)

**Important:** Backend is production-ready. We'll ADD new routes (product_analytics.py, email_service.py) without touching existing code.

---

## What's Already Built (Foundation Complete - 80%)

### ✅ Fully Implemented
- **Scoring System**: FaceIQ-compatible with 70+ metrics, exponential decay curves
- **Results UI**: All tabs (Overview, Front Ratios, Side Ratios, Plan, Options, Support)
- **Components**: EnhancedRecommendationCard, KeyStrengthsFlaws, all modals, visualizations
- **Backend**: FastAPI with detection, analysis, auth endpoints; InsightFace integration
- **Supplement Database**: `src/lib/recommendations/supplements.ts` with 26 products (dosages, costs, evidence levels, sources)
- **Procedure Recommendations**: Surgical, minimally invasive, foundational plans with trigger logic
- **ResultsContext**: Complete state management with strengths/flaws groupings
- **Documentation**: `supplement_implementation.md` (1100+ lines) - complete 7-phase blueprint

### ❌ Not Yet Built (Product E-Commerce Layer - 0%)
**This is what we're building:**
- **No Product types** - Product, ProductRecommendation, DailyStack interfaces missing
- **No product_db.ts** - Affiliate link mapping doesn't exist
- **No daily-stack.ts** - Stack generation logic not implemented
- **No ProductCard/DailyStackCard** - UI components don't exist
- **No product state in ResultsContext** - No integration with existing context
- **No getProductRecommendations()** - Logic to recommend products not in advice-engine.ts
- **No PlanTab product sections** - Still only shows procedures
- **No backend analytics** - No click tracking, email capture, or conversion metrics

### Key Finding
We have a **complete implementation blueprint** in `supplement_implementation.md` but **zero code implementation**. The foundation (supplements.ts, types system, context pattern, UI structure) is rock solid - we just need to build the product layer on top.

### Target State (After This Build)
```
PlanTab.tsx
├─ DailyStackCard (NEW - top hero element)
│  └─ 4-6 universal products for all users
├─ PotentialScoreCard (existing)
├─ Targeted Product Recommendations (NEW)
│  ├─ State A: Corrective Products (flaw metrics)
│  └─ State B: Maintenance Products (ideal metrics)
└─ Procedure Plans (existing - surgical/minimally invasive/foundational)
```

---

## Files to Create

### 1. `src/lib/product_db.ts`
Product catalog with affiliate links, extending existing supplements.ts data.

**Schema:**
```typescript
export interface Product {
  id: string;                          // Maps to supplement ID
  name: string;                        // Product name
  brand: string;                       // "Vital Proteins", "NOW Foods", etc.
  category: "skin" | "hair" | "anti-aging" | "hormonal" | "bone" | "general";
  affiliateLink: string;               // Amazon or direct brand URL
  affiliateType: "amazon" | "direct";  // For tracking
  supplementId: string;                // Reference to supplements.ts
  priority: number;                    // 1-10 (higher = more likely in Daily Stack)
  baseStackItem?: boolean;             // True if part of universal Daily Stack

  // Inherited from supplements.ts via supplementId:
  // - dosage, frequency, timing
  // - effectiveness, evidenceLevel
  // - costPerMonth, timelineToResults
  // - targetBenefits, sources
}
```

**Contents:**
- 10-15 starter products with affiliate links
- Map to existing supplements.ts via `supplementId`
- Define 4-6 products as `baseStackItem: true` for Daily Stack
- Priority scores for recommendation ranking

**Example Entry:**
```typescript
{
  id: "collagen_vital_proteins",
  name: "Collagen Peptides",
  brand: "Vital Proteins",
  category: "skin",
  affiliateLink: "https://amazon.com/dp/B00K9XZTW0?tag=PLACEHOLDER-20",
  affiliateType: "amazon",
  supplementId: "collagen_peptides",  // Links to supplements.ts
  priority: 10,
  baseStackItem: true
}
```

### 2. `src/lib/daily-stack.ts`
Generates universal "Daily Stack" shown to ALL users.

**Function Signature:**
```typescript
export function generateDailyStack(
  gender: 'male' | 'female',
  age?: number
): DailyStack;
```

**Logic:**
- Returns 4-6 base products (marked `baseStackItem: true`)
- Gender-specific boosters (e.g., Ashwagandha for males)
- Optional age-based additions (NAD+ precursors for 30+)
- Total cost calculation
- Timing recommendations (morning/evening/anytime)

**Output Structure:**
```typescript
interface DailyStack {
  products: Product[];
  totalCostPerMonth: { min: number; max: number };
  timing: {
    morning: Product[];
    evening: Product[];
    anytime: Product[];
  };
  rationale: string;  // "Foundation for skin, bone, and hormonal health"
}
```

### 3. `src/components/results/cards/ProductCard.tsx`
Individual product recommendation card.

**Features:**
- **Dual-state messaging**:
  - State A (FLAW): "Your [Feature] is weak. Use [Product] to IMPROVE it."
  - State B (IDEAL): "Your [Feature] is elite. Use [Product] to MAINTAIN and PROTECT it."
- Affiliate link CTA button ("View on Amazon" or "Shop Direct")
- Expandable research section (inherited from supplements.ts)
- Quick stats: cost, dosage, timeline
- Badge indicating state (Corrective vs Maintenance)

### 4. `src/components/results/cards/DailyStackCard.tsx`
Hero card showing universal Daily Stack.

**Features:**
- Eye-catching gradient background
- "Your Foundation Stack" heading
- 4-6 product pills with icons
- Total cost per month
- Timing breakdown (AM/PM/Anytime)
- Single CTA: "View Complete Stack" (expands to show all products)
- Rationale text explaining why everyone needs it

---

## Files to Modify

### 1. `src/lib/advice-engine.ts`
Add dual-state product recommendation logic.

**Key Changes:**

#### A. Add New Function: `getProductRecommendations()`
```typescript
export function getProductRecommendations(
  metricsDict: Record<string, number>,
  severityDict: Record<string, string>,
  gender: 'male' | 'female',
  ethnicity: Ethnicity
): ProductRecommendation[]
```

**Logic:**
1. Iterate through all metrics in metricsDict
2. For each metric, check severity:
   - **State A (Flaw)**: severity = "moderate" or "severe"
     - Find products targeting that metric
     - Message: "Your [Metric] is weak. Use [Product] to IMPROVE it."
     - Tone: Urgent, corrective
   - **State B (Ideal)**: severity = "ideal"
     - Find maintenance products for that area
     - Message: "Your [Metric] is elite. Use [Product] to MAINTAIN and PROTECT it."
     - Tone: Preventative, elite
3. Deduplicate products (same product may target multiple metrics)
4. Sort by priority score
5. Return top 10-15 product recommendations

#### B. Remove Severity Filter (Lines ~354-366)
Current code filters out ideal metrics. **Remove this filter** so recommendations fire for ALL metrics.

#### C. Add Metric-to-Product Mapping
Define which products target which metrics:
```typescript
const METRIC_TO_PRODUCTS: Record<string, string[]> = {
  // Skin metrics → skin products
  "Skin Texture Score": ["collagen_peptides", "vitamin_c_oral", "astaxanthin"],
  "Under Eye Area": ["collagen_peptides", "hyaluronic_acid_oral", "vitamin_e"],

  // Bone/structure metrics → bone products
  "Gonial Angle": ["creatine", "vitamin_k2", "vitamin_d3", "magnesium"],
  "Bigonial Width": ["creatine", "vitamin_d3"],
  "Cheekbone Height": ["collagen_peptides", "vitamin_k2", "silica"],

  // Hair metrics → hair products
  "Hairline Recession": ["biotin", "iron", "saw_palmetto", "vitamin_d3"],

  // General facial harmony → general optimization
  "Overall Facial Harmony": ["omega_3", "coq10", "nad_precursor"],

  // ... (map all relevant metrics)
};
```

### 2. `src/contexts/ResultsContext.tsx`
Add product recommendation state and generation.

**Changes:**
1. Add to context state:
   ```typescript
   productRecommendations: ProductRecommendation[];
   dailyStack: DailyStack | null;
   ```

2. Generate products after metrics calculation:
   ```typescript
   // After existing generateFlawsFromAnalysis()
   const productRecs = AdviceEngine.getProductRecommendations(
     metricsDict,
     severityDict,
     gender,
     ethnicity
   );

   const stack = generateDailyStack(gender);
   ```

3. Expose in context:
   ```typescript
   return (
     <ResultsContext.Provider value={{
       // ... existing
       productRecommendations: productRecs,
       dailyStack: stack,
     }}>
   ```

### 3. `src/components/results/tabs/PlanTab.tsx`
Integrate product sections into UI.

**New Layout:**
```tsx
<TabContent>
  <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div className="lg:col-span-2 space-y-6">
      {/* NEW: Daily Stack Card - TOP HERO */}
      <DailyStackCard />

      {/* Existing: Potential Score */}
      <PotentialScoreCard />

      {/* NEW: Targeted Product Recommendations */}
      <ProductRecommendationsSection />

      {/* Phase Filter */}
      <PhaseFilter />

      {/* Existing: Procedure Recommendations */}
      <RecommendationsList />
    </div>

    {/* Sidebar - unchanged */}
  </div>
</TabContent>
```

**ProductRecommendationsSection Structure:**
```tsx
<div className="space-y-6">
  {/* State A: Corrective Products */}
  {flawProducts.length > 0 && (
    <Section title="Targeted Improvements" badge="Corrective">
      {flawProducts.map(product => (
        <ProductCard product={product} state="flaw" />
      ))}
    </Section>
  )}

  {/* State B: Maintenance Products */}
  {idealProducts.length > 0 && (
    <Section title="Maintain Your Strengths" badge="Maintenance">
      {idealProducts.map(product => (
        <ProductCard product={product} state="ideal" />
      ))}
    </Section>
  )}
</div>
```

### 4. `src/types/results.ts`
Add new type definitions.

**New Types:**
```typescript
export interface Product {
  id: string;
  name: string;
  brand: string;
  category: "skin" | "hair" | "anti-aging" | "hormonal" | "bone" | "general";
  affiliateLink: string;
  affiliateType: "amazon" | "direct";
  supplementId: string;
  priority: number;
  baseStackItem?: boolean;
}

export interface ProductRecommendation {
  product: Product;
  state: "flaw" | "ideal";  // State A or State B
  targetMetric: string;      // Which metric triggered it
  message: string;           // Personalized hook
  urgency: "high" | "medium" | "low";
  matchedMetrics: string[];  // All metrics this product addresses
}

export interface DailyStack {
  products: Product[];
  totalCostPerMonth: { min: number; max: number };
  timing: {
    morning: Product[];
    evening: Product[];
    anytime: Product[];
  };
  rationale: string;
}
```

---

## Implementation Details

### Dual-State Logic Examples

**State A (FLAW) - Corrective:**
```
Metric: Gonial Angle = 132° (severe)
Severity: "severe"
Product: Creatine Monohydrate
Message: "Your jaw definition is WEAK (bottom 10%). Use Creatine to IMPROVE muscle mass and jaw appearance."
Tone: Urgent
Urgency: High
CTA: "Fix This Now - Shop Creatine →"
```

**State B (IDEAL) - Maintenance:**
```
Metric: Cheekbone Height = 68mm (ideal, top 5%)
Severity: "ideal"
Product: Marine Collagen + Vitamin K2
Message: "Your cheekbones are ELITE (top 5%). Use Marine Collagen + K2 to MAINTAIN and PROTECT this strength as you age."
Tone: Preventative, aspirational
Urgency: Low
CTA: "Maintain Your Edge - Shop Stack →"
```

### Daily Stack Example Output
```
Foundation Stack ($95-$135/month)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Morning:
• Vital Proteins Collagen (5g) + NOW Vitamin C (1000mg)
• Sports Research D3+K2 (5000 IU / 100mcg)

Evening:
• Doctor's Best Magnesium Glycinate (200mg)
• Nordic Naturals Omega-3 (2g EPA/DHA)

Anytime:
• Optimum Nutrition Creatine (5g)

Why This Stack?
This foundation supports skin elasticity, bone structure, hormonal balance, and inflammation control - the pillars of facial aesthetics and long-term appearance preservation.
```

### Metric-to-Product Mapping Strategy

**1. Direct Mapping** (specific metrics → specific products)
- Weak jaw → Creatine, Vitamin D3+K2, Magnesium
- Weak cheekbones → Collagen, Silica, Vitamin K2
- Skin issues → Collagen, Vitamin C, Astaxanthin
- Hair loss → Biotin, Iron (if deficient), Saw Palmetto

**2. Category Mapping** (metric categories → product categories)
- Bone/structure metrics → bone category products
- Skin quality metrics → skin category products
- Hair metrics → hair category products

**3. Universal Products** (shown to EVERYONE in Daily Stack)
- Collagen Peptides (skin)
- Vitamin C (collagen synthesis)
- Vitamin D3 + K2 (bone health)
- Magnesium (stress, sleep, muscle)
- Omega-3 (inflammation)

---

## Starter Product List (15 Products)

| # | Product | Brand | Category | Base Stack? | Affiliate Type | Priority |
|---|---------|-------|----------|-------------|----------------|----------|
| 1 | Collagen Peptides | Vital Proteins | skin | ✅ YES | Amazon | 10 |
| 2 | Vitamin C 1000mg | NOW Foods | skin | ✅ YES | Amazon | 9 |
| 3 | D3+K2 5000 IU | Sports Research | bone | ✅ YES | Amazon | 9 |
| 4 | Magnesium Glycinate | Doctor's Best | general | ✅ YES | Amazon | 8 |
| 5 | Omega-3 Fish Oil | Nordic Naturals | anti-aging | ✅ YES | Direct Brand | 8 |
| 6 | Creatine Monohydrate | Optimum Nutrition | general | ✅ YES | Amazon | 9 |
| 7 | Ashwagandha KSM-66 | NOW Foods | hormonal | NO | Amazon | 7 |
| 8 | Astaxanthin 12mg | Sports Research | skin | NO | Amazon | 7 |
| 9 | Biotin 5000mcg | Sports Research | hair | NO | Amazon | 5 |
| 10 | Iron Bisglycinate | Thorne | hair | NO | Direct Brand | 6 |
| 11 | Saw Palmetto | NOW Foods | hair | NO | Amazon | 5 |
| 12 | CoQ10 Ubiquinol | Jarrow Formulas | anti-aging | NO | Amazon | 6 |
| 13 | NMN 250mg | ProHealth Longevity | anti-aging | NO | Direct Brand | 6 |
| 14 | Tongkat Ali | Double Wood | hormonal | NO | Amazon | 6 |
| 15 | MSM 1000mg | NOW Foods | bone | NO | Amazon | 5 |

**Base Stack = 6 products:** Collagen, Vitamin C, D3+K2, Magnesium, Omega-3, Creatine
**Total Base Stack Cost:** $95-$135/month

---

## UI Mockup Flow

### User Journey
1. User completes facial analysis
2. Results load, user clicks "Plan" tab
3. **First thing they see:** DailyStackCard (hero element)
   - "Your Foundation Stack - $95-$135/month"
   - 6 products with icons
   - "Everyone needs these 6 essentials to maintain facial aesthetics"
4. Scroll down: PotentialScoreCard (existing)
5. Scroll down: **Targeted Product Recommendations**
   - Section 1: "Fix These Areas" (RED badge - corrective products)
     - 3-5 products for flaw metrics
   - Section 2: "Protect Your Strengths" (GREEN badge - maintenance products)
     - 3-5 products for ideal metrics
6. Scroll down: Phase filter + Procedure recommendations (existing)

### Visual Hierarchy
```
┌─────────────────────────────────────────────┐
│ 🏆 YOUR FOUNDATION STACK ($95-$135/mo)     │  ← HERO (new)
│ [6 product pills] View Complete Stack →    │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ ⚡ YOUR POTENTIAL: 6.8 → 8.2 (+1.4)        │  ← Existing
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ 🔴 FIX THESE AREAS (Corrective)             │  ← NEW
│ • Creatine - Weak Jaw ($10/mo) →           │
│ • Astaxanthin - UV Damage ($25/mo) →       │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ 🟢 PROTECT YOUR STRENGTHS (Maintenance)     │  ← NEW
│ • Collagen - Elite Cheekbones ($35/mo) →   │
│ • K2 - Strong Bone Structure ($20/mo) →    │
└─────────────────────────────────────────────┘

[Phase Filter: Foundational | Minimally Invasive | Surgical]  ← Existing

[Procedure Recommendations List...]  ← Existing
```

---

## Critical Files

### Files to Create (4)
1. `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/lib/product_db.ts`
2. `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/lib/daily-stack.ts`
3. `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/components/results/cards/ProductCard.tsx`
4. `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/components/results/cards/DailyStackCard.tsx`

### Files to Modify (4)
1. `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/lib/advice-engine.ts` (add getProductRecommendations(), metric mapping)
2. `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/contexts/ResultsContext.tsx` (add product state, generate products)
3. `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/components/results/tabs/PlanTab.tsx` (add DailyStackCard, ProductRecommendationsSection)
4. `/Users/imorgado/LOOKSMAXX/looksmaxx-app/src/types/results.ts` (add Product, ProductRecommendation, DailyStack types)

---

## Implementation Order

### Phase 1: Data Layer (2-3 hours)
1. Create `product_db.ts` with 15 starter products
2. Create `daily-stack.ts` with base stack logic
3. Add new types to `types/results.ts`

### Phase 2: Logic Layer (3-4 hours)
1. Add `getProductRecommendations()` to `advice-engine.ts`
2. Add metric-to-product mapping
3. Update `ResultsContext.tsx` to generate products

### Phase 3: UI Layer (4-5 hours)
1. Create `ProductCard.tsx` component
2. Create `DailyStackCard.tsx` component
3. Update `PlanTab.tsx` to integrate new sections

### Phase 4: Testing & Polish (2-3 hours)
1. Test dual-state logic (flaw vs ideal)
2. Verify Daily Stack appears for all users
3. Test affiliate links
4. Responsive design check
5. Add FTC disclosure for affiliate links

**Total Estimated Time:** 11-15 hours

---

## Risk Mitigation

### Low Risk
- Existing supplement data is well-structured
- Products are additive, not replacement
- Backward compatible (procedures still work)

### Medium Risk
- UI complexity (now 4 sections: Daily Stack + Products + Procedures + Sidebar)
- Mobile responsive layout with new sections
- Affiliate compliance (need FTC disclosure)

### Mitigation Strategies
- Progressive disclosure (collapse sections by default)
- Add "Affiliate Disclosure" footer to each product card
- Test on mobile viewport before deploying

---

## Success Metrics

### Technical Success
- ✅ Daily Stack appears for 100% of users
- ✅ State A products show for flaw metrics
- ✅ State B products show for ideal metrics
- ✅ Affiliate links are clickable and properly formatted
- ✅ No breaking changes to existing procedure recommendations

### Business Success (Post-Launch)
- Click-through rate on affiliate links
- Conversion rate on Daily Stack vs targeted products
- Average order value per user session
- Retention: do users come back to check product recommendations?

---

## Notes

### Affiliate Link Format
**Amazon:**
```
https://amazon.com/dp/{ASIN}?tag=looksmaxx-20
```
Replace `looksmaxx-20` with actual Amazon Associates ID.

**Direct Brand (example):**
```
https://vitaminexpress.org/us/collagen-peptides?ref=looksmaxx
```

### FTC Disclosure
Add to every product card:
```
"We may earn a commission from purchases made through links on this page."
```

---

## Phase 5: Backend API Integration (4-6 hours)

### Overview
Create FastAPI endpoints to track user interactions, product clicks, and recommendation analytics.

### Files to Create

#### 1. Backend: `app/routes/product_analytics.py`
**Endpoints:**
```python
POST /api/product-clicks
  - Track when user clicks affiliate link
  - Body: { userId, productId, recommendationType: 'daily-stack'|'corrective'|'maintenance', timestamp }

POST /api/save-stack
  - Save user's Daily Stack preferences
  - Body: { userId, stackProducts: Product[], gender, age }

GET /api/analytics/conversion-rates
  - Get conversion metrics by product, category, state
  - Query: ?timeRange=7d|30d|90d

POST /api/email-stack
  - Send Daily Stack to user's email
  - Body: { email, dailyStack: DailyStack, userId? }
```

**Database Schema (Prisma):**
```prisma
model ProductClick {
  id                String   @id @default(uuid())
  userId            String?  // Optional - track anon users too
  productId         String
  recommendationType String  // 'daily-stack' | 'corrective' | 'maintenance'
  affiliateType     String  // 'amazon' | 'direct'
  clicked           Boolean @default(false)
  purchased         Boolean @default(false) // Track later via webhooks
  clickedAt         DateTime @default(now())
}

model UserStack {
  id        String   @id @default(uuid())
  userId    String
  gender    String
  age       Int?
  products  Json     // Array of Product objects
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model EmailCapture {
  id          String   @id @default(uuid())
  email       String
  userId      String?
  dailyStack  Json
  sentAt      DateTime @default(now())
}
```

#### 2. Frontend: `src/lib/api/product-analytics.ts`
**Client API wrapper:**
```typescript
export async function trackProductClick(
  productId: string,
  recommendationType: 'daily-stack' | 'corrective' | 'maintenance',
  affiliateType: 'amazon' | 'direct',
  userId?: string
): Promise<void>

export async function saveUserStack(
  stackProducts: Product[],
  gender: 'male' | 'female',
  age?: number,
  userId?: string
): Promise<void>

export async function emailStack(
  email: string,
  dailyStack: DailyStack,
  userId?: string
): Promise<{ success: boolean; message: string }>

export async function getConversionRates(
  timeRange: '7d' | '30d' | '90d'
): Promise<ConversionMetrics>
```

### Implementation Steps
1. Add Prisma schema models
2. Run migration: `npx prisma migrate dev --name add-product-analytics`
3. Create FastAPI routes in `app/routes/product_analytics.py`
4. Create frontend API client in `src/lib/api/product-analytics.ts`
5. Add tracking to ProductCard click handlers
6. Add tracking to DailyStackCard expand/click handlers

---

## Phase 6: Analytics & A/B Testing (3-4 hours)

### Overview
Implement click tracking, conversion metrics, and A/B testing framework for product recommendations.

### Files to Create

#### 1. `src/lib/analytics/product-tracker.ts`
**Analytics event tracker:**
```typescript
// Track all product interactions
export function trackEvent(
  eventType: 'product_view' | 'product_click' | 'stack_expand' | 'email_sent',
  data: {
    productId?: string;
    recommendationType?: 'daily-stack' | 'corrective' | 'maintenance';
    variant?: 'A' | 'B';  // For A/B testing
    userId?: string;
  }
): void

// A/B test assignment
export function getMessageVariant(userId?: string): 'A' | 'B'
  - Variant A: "Your [Feature] is WEAK. Use [Product] to IMPROVE it."
  - Variant B: "Your [Feature] needs optimization. Use [Product] to enhance it."
  - Consistent per user (hash-based assignment)
```

#### 2. `src/components/analytics/ConversionDashboard.tsx`
**Admin analytics dashboard component:**
- Product performance table (clicks, CTR, revenue estimates)
- Daily Stack conversion rate
- State A vs State B performance
- A/B test results (variant A vs B conversion rates)
- Time-series charts (7d, 30d, 90d)

### Files to Modify

#### 1. `ProductCard.tsx` - Add click tracking
```typescript
const handleAffiliateClick = async () => {
  // Track click before opening link
  await trackProductClick(
    product.id,
    recommendation.state === 'flaw' ? 'corrective' : 'maintenance',
    product.affiliateType,
    userId
  );

  trackEvent('product_click', {
    productId: product.id,
    recommendationType: recommendation.state === 'flaw' ? 'corrective' : 'maintenance',
    variant: messageVariant,
  });

  // Open affiliate link
  window.open(product.affiliateLink, '_blank');
};
```

#### 2. `DailyStackCard.tsx` - Add expand/click tracking
```typescript
const handleExpand = () => {
  setIsExpanded(!isExpanded);

  if (!isExpanded) {
    trackEvent('stack_expand', {
      recommendationType: 'daily-stack',
      userId,
    });
  }
};
```

### Analytics Metrics to Track
- **Click-through rate (CTR)**: Clicks / Views
- **Conversion by state**: State A (corrective) vs State B (maintenance) CTR
- **Conversion by category**: skin vs bone vs hair vs hormonal
- **Daily Stack adoption**: % users who expand vs scroll past
- **Email capture rate**: Emails sent / Daily Stack views
- **A/B test results**: Variant A CTR vs Variant B CTR

---

## Phase 7: Email Capture System (2-3 hours)

### Overview
Allow users to email their personalized Daily Stack to themselves, building lead list and increasing engagement.

### Files to Create

#### 1. `src/components/results/modals/EmailStackModal.tsx`
**Email capture modal component:**
```typescript
interface EmailStackModalProps {
  isOpen: boolean;
  onClose: () => void;
  dailyStack: DailyStack;
  userId?: string;
}

// Features:
// - Email input field with validation
// - Preview of Daily Stack content
// - "Send to Email" CTA button
// - Success/error toast notifications
// - Privacy note: "We'll only use this to send your stack"
```

#### 2. Backend: `app/services/email_service.py`
**Email sending service:**
```python
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

async def send_daily_stack_email(
    email: str,
    daily_stack: dict,
    user_id: str = None
) -> bool:
    """
    Send personalized Daily Stack email
    Template includes:
    - Greeting with user's stack
    - Morning/Evening/Anytime product breakdown
    - Dosage instructions
    - Total cost per month
    - Affiliate links for each product
    - FTC disclosure
    """
```

**Email Template Structure:**
```html
Subject: Your Personalized Daily Stack ($95-$135/month)

Body:
━━━━━━━━━━━━━━━━━━━━━━━━
YOUR FOUNDATION STACK
━━━━━━━━━━━━━━━━━━━━━━━━

Based on your facial analysis, here's your personalized supplement stack
to support skin elasticity, bone structure, and long-term appearance.

MORNING ROUTINE
• Vital Proteins Collagen Peptides (5g)
  → [Shop on Amazon]($35/mo)
• NOW Vitamin C 1000mg
  → [Shop on Amazon]($12/mo)
• Sports Research D3+K2 (5000 IU)
  → [Shop on Amazon]($20/mo)

EVENING ROUTINE
• Doctor's Best Magnesium Glycinate (200mg)
  → [Shop on Amazon]($15/mo)
• Nordic Naturals Omega-3 (2g EPA/DHA)
  → [Shop Direct]($30/mo)

ANYTIME
• Optimum Nutrition Creatine (5g)
  → [Shop on Amazon]($10/mo)

━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL COST: $95-$135/month
━━━━━━━━━━━━━━━━━━━━━━━━

[Button: View Full Analysis on LooksMaxx →]

Disclosure: We may earn a commission from purchases through these links.
```

### Files to Modify

#### 1. `DailyStackCard.tsx` - Add email CTA button
```typescript
const [emailModalOpen, setEmailModalOpen] = useState(false);

// Add button below "View Complete Stack"
<button onClick={() => setEmailModalOpen(true)}>
  Email My Stack
</button>

<EmailStackModal
  isOpen={emailModalOpen}
  onClose={() => setEmailModalOpen(false)}
  dailyStack={dailyStack}
  userId={userId}
/>
```

### Email Service Setup
1. **Sign up for SendGrid** (free tier: 100 emails/day)
2. **Create API key** in SendGrid dashboard
3. **Add to environment variables:**
   ```
   SENDGRID_API_KEY=SG.xxx
   SENDGRID_FROM_EMAIL=noreply@looksmaxx.app
   ```
4. **Create email template** in SendGrid with dynamic content
5. **Test email delivery** before going live

### Lead Capture Strategy
- **Store all emails** in EmailCapture table
- **Track engagement**: email open rates, link clicks (SendGrid analytics)
- **Follow-up sequences** (optional):
  - Day 1: Daily Stack email
  - Day 3: "Have you started your stack?" reminder
  - Day 7: "Share your results" + referral offer
  - Day 30: "Restock reminder" with direct product links

---

## Implementation Roadmap (Quick Reference)

**All code is in `supplement_implementation.md` - just copy and adapt. Focus on Phases 1-5 first (frontend only), then add backend later.**

### MVP Timeline (Frontend Only - Phases 1-5)
**Estimated: 12-16 hours over 2-3 days**

### Phase 1: Data Layer (2-3 hours) ⭐ START HERE
**Reference: `supplement_implementation.md` sections "Phase 1", "Phase 2", "Phase 3"**
- [ ] Add Product, ProductRecommendation, DailyStack types to `types/results.ts`
- [ ] Create `product_db.ts` with 15 starter products + affiliate links
- [ ] Create `daily-stack.ts` with base stack generation logic

### Phase 2: Logic Layer (3-4 hours)
- [ ] Add `getProductRecommendations()` to `advice-engine.ts`
- [ ] Add metric-to-product mapping (30+ metrics)
- [ ] Update `ResultsContext.tsx` to generate product recommendations + daily stack

### Phase 3: UI Layer (4-5 hours)
- [ ] Create `ProductCard.tsx` component (dual-state messaging)
- [ ] Create `DailyStackCard.tsx` component (hero element)
- [ ] Update `PlanTab.tsx` to integrate Daily Stack + Product sections
- [ ] Add FTC disclosure to all product cards

### Phase 4: Testing Frontend (2 hours)
- [ ] Test dual-state logic (flaw vs ideal products)
- [ ] Verify Daily Stack appears for 100% of users
- [ ] Test affiliate links (Amazon + direct)
- [ ] Mobile responsive design check

### Phase 5: Backend API (4-6 hours)
- [ ] Add Prisma schema: ProductClick, UserStack, EmailCapture models
- [ ] Run migration: `npx prisma migrate dev`
- [ ] Create FastAPI routes: `product_analytics.py`
- [ ] Create frontend API client: `product-analytics.ts`
- [ ] Add click tracking to ProductCard + DailyStackCard

### Phase 6: Analytics (3-4 hours)
- [ ] Create `product-tracker.ts` analytics event tracker
- [ ] Implement A/B test variant assignment (hash-based)
- [ ] Create `ConversionDashboard.tsx` admin component
- [ ] Add tracking to all product interactions
- [ ] Test analytics data flow (frontend → backend → database)

### Phase 7: Email Capture (2-3 hours)
- [ ] Sign up for SendGrid, get API key
- [ ] Create email template with Daily Stack format
- [ ] Create `EmailStackModal.tsx` component
- [ ] Create backend `email_service.py`
- [ ] Add "Email My Stack" button to DailyStackCard
- [ ] Test email delivery end-to-end

### Phase 8: Testing & Polish (3-4 hours)
- [ ] End-to-end test: analysis → products → click → analytics logged
- [ ] Test email capture flow
- [ ] Verify analytics dashboard shows correct data
- [ ] Test A/B variant assignment consistency
- [ ] Performance check (bundle size, API latency)
- [ ] Add loading states to all async operations

---

**Total Estimated Time:** 23-31 hours (3-4 days)

---

## Critical Files Summary

### Files to Create (13 new files)

**Frontend (8 files):**
1. `src/lib/product_db.ts` - Product catalog with affiliate links
2. `src/lib/daily-stack.ts` - Daily Stack generator
3. `src/components/results/cards/ProductCard.tsx` - Product card component
4. `src/components/results/cards/DailyStackCard.tsx` - Daily Stack hero card
5. `src/lib/api/product-analytics.ts` - API client for analytics
6. `src/lib/analytics/product-tracker.ts` - Analytics event tracker
7. `src/components/analytics/ConversionDashboard.tsx` - Admin analytics dashboard
8. `src/components/results/modals/EmailStackModal.tsx` - Email capture modal

**Backend (5 files):**
9. `app/routes/product_analytics.py` - Analytics API endpoints
10. `app/services/email_service.py` - SendGrid email service
11. `prisma/migrations/XXX_add_product_analytics.sql` - Database migration
12. Database models in schema.prisma: ProductClick, UserStack, EmailCapture

### Files to Modify (4 files)
1. `src/lib/advice-engine.ts` - Add getProductRecommendations()
2. `src/contexts/ResultsContext.tsx` - Add product state
3. `src/components/results/tabs/PlanTab.tsx` - Integrate product sections
4. `src/types/results.ts` - Add Product, ProductRecommendation, DailyStack types

---

## Risk Assessment

### Low Risk
- Products are additive (procedures still work)
- Type-safe implementation (TypeScript)
- Existing supplement data is well-structured

### Medium Risk
- UI complexity (4 sections now: Daily Stack + Products + Procedures + Sidebar)
- Mobile responsive layout
- Analytics data volume (track every click)

### High Risk
- Email deliverability (SendGrid reputation, spam filters)
- GDPR compliance (storing emails, user consent)
- Affiliate compliance (FTC disclosure required)

### Mitigation Strategies
- Progressive disclosure (collapse sections by default)
- Add loading spinners to async operations
- Rate limit email sending (max 3 emails per user per day)
- Add cookie consent banner for analytics tracking
- Include unsubscribe link in all emails
- Test email templates in spam checkers

---

## Success Metrics

### Technical Success (MVP)
- ✅ Daily Stack appears for 100% of users
- ✅ State A products show for flaw metrics
- ✅ State B products show for ideal metrics
- ✅ All clicks tracked to database
- ✅ Email delivery >95% success rate
- ✅ Analytics dashboard loads <2 seconds
- ✅ No breaking changes to existing features

### Business Success (Post-Launch)
- **Week 1 Targets:**
  - Daily Stack CTR: >15%
  - Email capture rate: >8%
  - Product click CTR: >5%

- **Month 1 Targets:**
  - 1000+ product clicks logged
  - 500+ emails captured
  - Conversion rate: 2-5% (estimated based on affiliate averages)
  - A/B test: Determine winning message variant

- **Quarter 1 Targets:**
  - $X in affiliate revenue (set based on traffic)
  - Email list: 5000+ subscribers
  - Top 3 converting products identified
  - Optimize product recommendations based on conversion data

---

## Future Enhancements (Post-MVP)

### Short-term (Month 2-3)
- **Bundles**: "Buy Complete Daily Stack" single checkout link
- **User accounts**: Save product lists, track purchase history
- **Referral program**: Users earn $ for referring friends
- **Advanced A/B tests**: Test urgency levels, pricing display, CTA copy

### Long-term (Quarter 2+)
- **Subscription service**: Monthly product deliveries partnership
- **Quiz funnel**: "Find your perfect stack" alternative entry point
- **Video content**: Product reviews, user testimonials
- **Influencer partnerships**: Sponsored content, affiliate JV deals
- **Private label products**: LooksMaxx branded supplements
