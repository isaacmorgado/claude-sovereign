# E-Commerce Funnel Transformation Plan

**Objective**: Transform the LOOKSMAXX advice system from a diagnostic tool into an e-commerce funnel that recommends products for BOTH flaws AND ideal features (preventative/maintenance messaging).

---

## Current State Analysis

### Existing Architecture
1. **advice-engine.ts**: 10 hardcoded procedural plans (surgical/minimally invasive/foundational)
   - Uses trigger rules (metrics + thresholds)
   - Only fires when metrics are NOT ideal (flaw-based)
   - Returns `Plan[]` with cost, timeline, risks, citations

2. **recommendations/** directory: Advanced supplement system exists!
   - `supplements.ts`: 26 products across 5 categories (skin/hair/bone/hormonal/general)
   - `types.ts`: Comprehensive type system for Treatment/Surgery/Supplement
   - `engine.ts`: Recommendation matching logic based on severity
   - **Already has affiliate-ready structure** (costPerMonth, effectiveness scores)

3. **UI Integration**:
   - `PlanTab.tsx`: Displays recommendations grouped by phase
   - `EnhancedRecommendationCard.tsx`: Research citations, cost, timeline display
   - NO product display currently active

### Gap Identification
- **recommendations/supplements.ts EXISTS but is NOT integrated into UI**
- No affiliate links in supplement database
- No "Base Stack" / "Daily Stack" concept
- Advice engine doesn't reference supplements
- No dual-state logic (flaw vs ideal maintenance)

---

## PHASE 1: Product Database Enhancement

### File: `src/lib/product_db.ts` (NEW)

**Purpose**: Create a curated product catalog with affiliate links that maps to the existing supplement database.

```typescript
interface Product {
  id: string;
  name: string;
  brand: string;
  affiliateLink: string;
  amazonASIN?: string;
  
  // Maps to existing Supplement
  supplementId: string;  // Links to supplements.ts
  
  // Categorization
  category: 'skin' | 'bone' | 'hair' | 'hormonal';
  subcategory?: string; // e.g., 'collagen', 'vitamin', 'adaptogen'
  
  // E-Commerce Fields
  price: { amount: number; currency: string };
  pricePerServing?: number;
  servingsPerContainer?: number;
  
  // Marketing
  tagline: string;  // "Skin-Firming Collagen"
  usp: string;      // "Type I & III Marine Collagen"
  
  // Targeting
  targetMetrics: string[];  // Which facial metrics it helps
  targetFlaws: string[];    // Which flaws it addresses
  targetStrengths: string[];  // Which ideal features it maintains
  
  // Specificity
  gender?: 'male' | 'female' | 'both';
  ethnicity?: Ethnicity[];
  
  // Display priority
  priority: number;  // 1-10, for "Base Stack" inclusion
  isBaseStack: boolean;  // Always recommend to everyone
}
```

**Starter Product List** (10-20 products):

| Category | Product | Brand Example | Supplement Link | Price | Base Stack? |
|----------|---------|---------------|-----------------|-------|-------------|
| **Skin** | Marine Collagen | Vital Proteins | `collagen_peptides` | $35 | YES |
| **Skin** | Vitamin C | NOW Foods | `vitamin_c_oral` | $12 | YES |
| **Skin** | Astaxanthin | Sports Research | `astaxanthin` | $25 | NO |
| **Skin** | Hyaluronic Acid | NOW Foods | `hyaluronic_acid_oral` | $18 | NO |
| **Hair** | Biotin Complex | Nature's Bounty | `biotin` | $10 | NO |
| **Hair** | Iron (if deficient) | Thorne Ferrous | `iron` | $12 | NO |
| **Hair** | Vitamin D3+K2 | Sports Research | `vitamin_d3` + `vitamin_k2` | $20 | YES |
| **Bone** | Magnesium Glycinate | Doctor's Best | `magnesium` | $15 | YES |
| **Bone** | MSM | Jarrow Formulas | `msm` | $18 | NO |
| **Hormonal** | Ashwagandha KSM-66 | NOW Foods | `ashwagandha` | $20 | NO (Male) |
| **Hormonal** | Tongkat Ali | Double Wood | `tongkat_ali` | $35 | NO (Male) |
| **General** | Omega-3 DHA/EPA | Nordic Naturals | `omega_3` | $30 | YES |
| **General** | Creatine | Optimum Nutrition | `creatine` | $10 | NO (Optional) |
| **General** | Glycine Powder | BulkSupplements | `glycine` | $15 | NO |

**Base Stack Criteria**:
- Collagen + Vitamin C (skin)
- Vitamin D3+K2 (bone/hair)
- Magnesium Glycinate (stress/sleep)
- Omega-3 (inflammation)

**Design Decisions**:
- Products reference `supplementId` to inherit descriptions, dosages, research from supplements.ts
- Can have multiple products per supplement (brand variations)
- Priority score determines "Base Stack" inclusion
- Gender/ethnicity filters for relevance

---

## PHASE 2: Dual-State Recommendation Logic

### File: `src/lib/advice-engine.ts` (MODIFY)

**Current Behavior**:
```typescript
// Lines 354-366: Only triggers if NOT ideal
if (isTriggered && severityDict) {
  const hasActualFlaw = triggeredMetrics.some(tm => {
    const severity = severityDict[tm.metric];
    return severity && severity !== 'ideal';
  });
  if (!hasActualFlaw) continue; // SKIP if ideal
}
```

**New Behavior**: Always-Sell Logic

```typescript
export interface ProductRecommendation {
  product: Product;
  trigger: 'flaw' | 'ideal';  // State A or B
  priority: number;
  messaging: {
    hook: string;      // "Your [Feature] needs help" vs "Protect your elite [Feature]"
    tone: 'corrective' | 'preventative';
    urgency: 'high' | 'medium' | 'low';
  };
  targetMetric: string;
  metricValue: number;
  metricSeverity: 'ideal' | 'good' | 'moderate' | 'severe';
}

function getProductRecommendations(
  metricsDict: Record<string, number>,
  severityDict: Record<string, string>,
  gender: Gender,
  ethnicity: Ethnicity
): ProductRecommendation[] {
  const recommendations: ProductRecommendation[] = [];
  
  for (const [metricName, severity] of Object.entries(severityDict)) {
    const metricValue = metricsDict[metricName];
    
    // STATE A: FLAW (Red/Yellow Badge)
    if (severity === 'moderate' || severity === 'severe') {
      const products = findProductsForFlaw(metricName, gender, ethnicity);
      recommendations.push(...products.map(p => ({
        product: p,
        trigger: 'flaw',
        priority: severity === 'severe' ? 10 : 7,
        messaging: {
          hook: `Your ${metricName} is weak. Use ${p.name} to IMPROVE it.`,
          tone: 'corrective',
          urgency: severity === 'severe' ? 'high' : 'medium'
        },
        targetMetric: metricName,
        metricValue,
        metricSeverity: severity
      })));
    }
    
    // STATE B: IDEAL (Green Badge)  
    if (severity === 'ideal') {
      const products = findProductsForMaintenance(metricName, gender, ethnicity);
      recommendations.push(...products.map(p => ({
        product: p,
        trigger: 'ideal',
        priority: 5,
        messaging: {
          hook: `Your ${metricName} is elite. Use ${p.name} to MAINTAIN and PROTECT it.`,
          tone: 'preventative',
          urgency: 'low'
        },
        targetMetric: metricName,
        metricValue,
        metricSeverity: severity
      })));
    }
  }
  
  return recommendations.sort((a, b) => b.priority - a.priority);
}
```

**Product Mapping Logic**:
```typescript
function findProductsForFlaw(metric: string, gender: Gender, ethnicity: Ethnicity): Product[] {
  return PRODUCTS.filter(p => 
    p.targetFlaws.includes(metric) &&
    (p.gender === 'both' || p.gender === gender) &&
    (!p.ethnicity || p.ethnicity.includes(ethnicity))
  );
}

function findProductsForMaintenance(metric: string, gender: Gender, ethnicity: Ethnicity): Product[] {
  return PRODUCTS.filter(p => 
    p.targetStrengths.includes(metric) &&
    (p.gender === 'both' || p.gender === gender)
  );
}
```

**Keep Existing Plan Logic**: Surgical/minimally invasive recommendations stay as-is. Products are additive, not replacement.

---

## PHASE 3: Daily Stack Generation

### File: `src/lib/daily-stack.ts` (NEW)

**Purpose**: Generate a "Base Stack" recommended to ALL users regardless of metrics.

```typescript
export interface DailyStack {
  name: string;
  description: string;
  totalCostPerMonth: number;
  products: Product[];
  benefits: string[];
  timing: {
    morning: Product[];
    evening: Product[];
    anytime: Product[];
  };
}

export function generateDailyStack(gender: Gender, ethnicity: Ethnicity): DailyStack {
  // Filter base stack products
  const baseProducts = PRODUCTS.filter(p => 
    p.isBaseStack &&
    (p.gender === 'both' || p.gender === gender)
  );
  
  // Add gender-specific boosters
  if (gender === 'male') {
    const maleBooster = PRODUCTS.find(p => p.supplementId === 'ashwagandha');
    if (maleBooster) baseProducts.push(maleBooster);
  }
  
  return {
    name: "Foundation Stack",
    description: "Universal supplements for skin, bone, and longevity",
    totalCostPerMonth: baseProducts.reduce((sum, p) => sum + p.price.amount, 0),
    products: baseProducts,
    benefits: [
      "Collagen synthesis support",
      "Bone & jaw structure maintenance",
      "Systemic anti-inflammation",
      "Sleep quality optimization"
    ],
    timing: {
      morning: baseProducts.filter(p => 
        ['vitamin_d3', 'vitamin_c_oral', 'omega_3'].includes(p.supplementId)
      ),
      evening: baseProducts.filter(p => 
        ['magnesium', 'glycine'].includes(p.supplementId)
      ),
      anytime: baseProducts.filter(p => 
        p.supplementId === 'collagen_peptides'
      )
    }
  };
}
```

**UI Integration Point**: Display in PlanTab.tsx as a separate "Daily Stack" card above personalized recommendations.

---

## PHASE 4: Type System Updates

### File: `src/types/results.ts` (MODIFY)

Add new types:
```typescript
export interface ProductRecommendation {
  product: Product;
  trigger: 'flaw' | 'ideal' | 'base_stack';
  priority: number;
  messaging: {
    hook: string;
    tone: 'corrective' | 'preventative' | 'foundational';
    urgency: 'high' | 'medium' | 'low';
  };
  targetMetric?: string;
  metricValue?: number;
  metricSeverity?: SeverityLevel;
}

// Extend existing Recommendation interface
export interface Recommendation {
  // ... existing fields
  relatedProducts?: ProductRecommendation[];  // Products that complement this procedure
}
```

---

## PHASE 5: UI Integration

### 5.1 ResultsContext.tsx Updates

```typescript
interface ResultsContextType {
  // ... existing fields
  
  // NEW: Product recommendations
  productRecommendations: ProductRecommendation[];
  dailyStack: DailyStack | null;
  
  // Actions
  setProductRecommendations: (products: ProductRecommendation[]) => void;
}
```

### 5.2 PlanTab.tsx Enhancements

**New Sections**:
1. **Daily Stack Card** (top priority)
   - Title: "Your Foundation Stack"
   - Shows 4-6 base products
   - Total monthly cost
   - "Add All to Cart" CTA

2. **Flaw-Based Products** (State A)
   - Red/yellow badge
   - "Fix your weak [Feature]"
   - Urgency messaging

3. **Maintenance Products** (State B)  
   - Green badge
   - "Protect your elite [Feature]"
   - Elite/preventative messaging

4. **Existing Procedural Plans**
   - Keep as-is below products

**Component Structure**:
```tsx
<PlanTab>
  <DailyStackCard stack={dailyStack} />
  
  <ProductRecommendationsSection 
    recommendations={flawProducts} 
    title="Targeted Solutions"
    subtitle="Address your weak points"
  />
  
  <ProductRecommendationsSection 
    recommendations={maintenanceProducts}
    title="Elite Maintenance"  
    subtitle="Preserve your strengths"
  />
  
  <ProceduralRecommendations 
    plans={plans}
    title="Advanced Options"
  />
</PlanTab>
```

### 5.3 New Component: ProductCard.tsx

```tsx
interface ProductCardProps {
  recommendation: ProductRecommendation;
  isExpanded?: boolean;
  onToggle?: () => void;
}

export function ProductCard({ recommendation, isExpanded, onToggle }: ProductCardProps) {
  const { product, messaging, trigger } = recommendation;
  
  return (
    <div className="bg-neutral-900 rounded-xl border border-neutral-800">
      {/* Header */}
      <div className="p-4">
        <div className="flex justify-between items-start">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <h3 className="text-base font-semibold text-white">{product.name}</h3>
              <TriggerBadge trigger={trigger} />
            </div>
            <p className="text-xs text-neutral-400">{product.brand} • {product.tagline}</p>
          </div>
          
          <div className="text-right">
            <div className="text-lg font-bold text-white">${product.price.amount}</div>
            <div className="text-xs text-neutral-500">/month</div>
          </div>
        </div>
        
        {/* Hook */}
        <div className={`mt-3 p-3 rounded-lg ${
          messaging.tone === 'corrective' 
            ? 'bg-red-500/10 border border-red-500/30' 
            : 'bg-cyan-500/10 border border-cyan-500/30'
        }`}>
          <p className="text-sm text-white">{messaging.hook}</p>
        </div>
        
        {/* CTA */}
        <div className="mt-4 flex gap-2">
          <a 
            href={product.affiliateLink}
            target="_blank"
            className="flex-1 bg-cyan-500 text-black font-semibold px-4 py-2 rounded-lg hover:bg-cyan-400"
          >
            Buy Now
          </a>
          <button 
            onClick={onToggle}
            className="px-4 py-2 border border-neutral-700 rounded-lg"
          >
            Details
          </button>
        </div>
      </div>
      
      {/* Expandable Details */}
      {isExpanded && (
        <div className="border-t border-neutral-800 p-4">
          {/* Research, dosage, benefits from supplements.ts */}
        </div>
      )}
    </div>
  );
}
```

---

## PHASE 6: Data Flow Integration

### Flow Diagram
```
User uploads photo
  ↓
MediaPipe detects landmarks
  ↓
faceiq-scoring.ts calculates metrics + severity
  ↓
ResultsContext receives:
  - metricsDict (raw values)
  - severityDict (ideal/good/moderate/severe)
  - gender, ethnicity
  ↓
[NEW] advice-engine.ts generates:
  - productRecommendations (dual-state logic)
  - dailyStack (base products)
  - plans (existing surgical/procedural)
  ↓
PlanTab.tsx displays:
  1. Daily Stack Card
  2. Flaw Products (State A)
  3. Maintenance Products (State B)
  4. Surgical Plans
```

### Integration Points

**1. ResultsContext.tsx** (lines 340-390)
```typescript
// After calculating harmonyAnalysis
const productRecs = getProductRecommendations(
  metricsDict,
  severityDict,
  gender,
  ethnicity
);

const stack = generateDailyStack(gender, ethnicity);

setProductRecommendations(productRecs);
setDailyStack(stack);
```

**2. advice-engine.ts** (export new functions)
```typescript
export { 
  getProductRecommendations,  // NEW
  generateDailyStack,         // NEW
  AdviceEngine,               // EXISTING
  PLANS                       // EXISTING
};
```

---

## PHASE 7: Migration Strategy

### Backward Compatibility
- Keep existing `Plan[]` structure intact
- `ProductRecommendation[]` is additive, not replacement
- UI conditionally renders products if available
- If no products, show only surgical plans (current behavior)

### Feature Flags (Optional)
```typescript
const FEATURE_FLAGS = {
  enableProductRecommendations: true,
  enableDailyStack: true,
  enableMaintenanceProducts: true  // State B
};
```

### Testing Checklist
- [ ] Female user with ideal cheekbones → gets maintenance collagen
- [ ] Male user with weak jaw → gets corrective creatine + magnesium
- [ ] User with all ideal metrics → gets full Daily Stack
- [ ] User with no flaws → sees "Elite Maintenance" section
- [ ] Affiliate links open in new tab
- [ ] Cost calculations accurate

---

## PHASE 8: Affiliate Link Management

### Considerations
- **Amazon Associates**: ASIN-based links
- **Direct Brand Affiliates**: Unique tracking codes
- **Link Rotation**: A/B test different brands for same supplement

### File: `src/lib/affiliate-config.ts` (NEW)
```typescript
interface AffiliateConfig {
  platform: 'amazon' | 'brand' | 'aggregator';
  trackingId: string;
  commissionRate?: number;
}

const AFFILIATE_LINKS: Record<string, AffiliateConfig> = {
  'collagen_vital_proteins': {
    platform: 'amazon',
    trackingId: 'looksmaxx-20',
    commissionRate: 0.04
  },
  // ...
};
```

---

## Files to Create

### Priority 1 (MVP)
1. **`src/lib/product_db.ts`** - Product catalog with affiliate links
2. **`src/lib/daily-stack.ts`** - Base stack generation
3. **`src/components/results/cards/ProductCard.tsx`** - Product display component
4. **`src/components/results/cards/DailyStackCard.tsx`** - Stack display

### Priority 2 (Enhancements)
5. **`src/lib/affiliate-config.ts`** - Centralized affiliate management
6. **`src/components/results/sections/ProductRecommendationsSection.tsx`** - Grid layout for products

---

## Files to Modify

### Critical Path
1. **`src/lib/advice-engine.ts`**
   - Add `getProductRecommendations()` function
   - Add dual-state logic (flaw vs ideal)
   - Export product types

2. **`src/types/results.ts`**  
   - Add `ProductRecommendation` interface
   - Add `Product` interface
   - Add `DailyStack` interface

3. **`src/contexts/ResultsContext.tsx`**
   - Add `productRecommendations` state
   - Add `dailyStack` state
   - Call new advice engine functions

4. **`src/components/results/tabs/PlanTab.tsx`**
   - Add Daily Stack section (top)
   - Add Product Recommendations sections (middle)
   - Keep existing surgical plans (bottom)

### Reference/Support
5. **`src/lib/recommendations/supplements.ts`** - Reference for data, NO changes needed
6. **`src/lib/recommendations/types.ts`** - Reference for types, possible minor additions

---

## Risk Assessment

### Low Risk
- Products are additive layer, don't break existing functionality
- Supplements database already exists and is well-structured
- Type system is already comprehensive

### Medium Risk
- UI complexity increases (3 recommendation types instead of 1)
- Mobile responsiveness needs careful handling
- Affiliate link compliance (FTC disclosure)

### High Risk
- None identified - architecture supports this cleanly

---

## Success Metrics

### Technical
- [ ] All products have affiliate links
- [ ] Daily Stack generates for all users
- [ ] Dual-state logic fires correctly (flaw vs ideal)
- [ ] No console errors in production
- [ ] Mobile responsive at 375px width

### Business
- [ ] Average products recommended per user: 6-10
- [ ] Click-through rate on affiliate links: measure
- [ ] Daily Stack adoption: % of users who see it

---

## Timeline Estimate

- **Phase 1-2** (Product DB + Logic): 6-8 hours
- **Phase 3-4** (Daily Stack + Types): 3-4 hours  
- **Phase 5-6** (UI + Integration): 8-10 hours
- **Phase 7-8** (Testing + Affiliate): 4-6 hours

**Total**: 21-28 hours (3-4 days at 8 hrs/day)

---

## Open Questions

1. **Should products have gender-specific dosages?**
   - Example: Creatine 5g for males, 3g for females
   - Recommendation: Yes, add `dosageByGender` field

2. **How many products per metric?**
   - Current plan: 1-2 per flaw, 1 per ideal
   - Recommendation: Cap at 2 per to avoid overwhelming UI

3. **Should Base Stack be configurable by user?**
   - Current plan: Fixed 4-6 products
   - Recommendation: Start fixed, add customization later

4. **Multi-product bundles?**
   - Example: "Skin Stack" (Collagen + Vitamin C + Astaxanthin)
   - Recommendation: Phase 2 feature, not MVP

---

## Next Steps

1. Review this plan with stakeholders
2. Confirm affiliate partner integrations
3. Get legal approval for FTC disclosures
4. Implement Phase 1 (Product DB)
5. A/B test messaging (corrective vs preventative)

