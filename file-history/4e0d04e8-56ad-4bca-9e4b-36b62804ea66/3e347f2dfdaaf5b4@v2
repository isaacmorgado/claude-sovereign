/**
 * Diet & Nutrition Guide
 * Humor Level: Medium (15%)
 */

import { Guide } from '@/types/guides';

export const dietGuide: Guide = {
  id: 'diet',
  slug: 'diet-nutrition',
  title: 'Diet & Nutrition',
  subtitle: "You can't out-train a bad diet",
  description: "The fundamentals of eating for aesthetics. Protein, calories, and what actually matters vs what doesn't.",
  icon: 'Utensils',
  humorLevel: 'medium',
  estimatedReadTime: 15,
  order: 8,
  tags: ['nutrition', 'diet', 'protein', 'calories', 'macros'],
  relatedGuides: ['body-fat', 'training', 'v-taper'],
  productIds: ['food_scale', 'creatine_mono', 'omega3_fish_oil', 'collagen_peptides', 'vitamin_d3_k2', 'magnesium_glycinate'],
  forumCategory: 'body-composition',
  heroMedia: {
    id: 'diet-hero',
    type: 'image',
    url: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=1200&q=80',
    alt: 'Healthy meal prep and nutrition',
    placement: 'hero',
  },
  sections: [
    {
      id: 'intro',
      title: 'The Foundation of Everything',
      humorLevel: 'medium',
      content: `Your physique is built in the kitchen, revealed in the gym.

You can train perfectly, but if your nutrition is garbage:
- You won't build muscle efficiently
- You won't lose fat predictably
- You'll look the same in 6 months

**The Good News:**
Nutrition is simpler than the internet makes it seem. Most of the complexity is unnecessary.

**What Actually Matters (80% of results):**
1. Total calories (energy balance)
2. Protein intake
3. Food quality (mostly)
4. Consistency

**What Barely Matters (20% optimization):**
- Meal timing
- Specific food choices within reason
- Supplement stacks beyond basics
- Nutrient timing around workouts

Let's cover the 80% first.`,
      media: [
        {
          id: 'diet-intro',
          type: 'image',
          url: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800&q=80',
          alt: 'Healthy food and nutrition',
          caption: 'Your physique is built in the kitchen',
          placement: 'inline',
        },
      ],
    },
    {
      id: 'calories',
      title: 'Calories: The Master Variable',
      humorLevel: 'medium',
      content: `Everything else is secondary to energy balance.

**The Basic Math:**
- Calories In > Calories Out = Weight Gain
- Calories In < Calories Out = Weight Loss
- Calories In = Calories Out = Maintenance

**Finding Your Maintenance:**
Method 1: Calculator estimate
- TDEE calculator gives starting point
- Typically 14-17 x bodyweight (in lbs)
- Active people higher, sedentary lower

Method 2: Track and observe
- Eat the same for 2 weeks
- Track weight daily, average weekly
- Stable = maintenance. Rising = surplus. Dropping = deficit.

**Setting Your Target:**

| Goal | Calorie Target |
|------|---------------|
| Fat Loss | Maintenance - 300-500 |
| Maintenance | TDEE |
| Lean Bulk | Maintenance + 200-300 |
| Standard Bulk | Maintenance + 400-500 |

**The Mistake:**
Going too aggressive. A 1000 calorie deficit sounds fast but leads to muscle loss, metabolic adaptation, and binges. Slow and steady wins.`,
      products: ['food_scale'],
      tips: [
        'Use a food scale for accuracy—eyeballing is notoriously wrong',
        'Track for 2-4 weeks to learn your foods, then you can estimate',
        'Weekly average matters more than daily fluctuations'
      ],
    },
    {
      id: 'protein',
      title: 'Protein: The King of Macros',
      humorLevel: 'medium',
      content: `If you remember one thing from this guide: hit your protein.

**Why Protein Is King:**
- Builds and preserves muscle
- Most satiating macro (keeps you full)
- Highest thermic effect (burns calories to digest)
- Hardest to store as fat

**How Much:**
- Minimum: 0.7g per pound of bodyweight
- Optimal: 0.8-1g per pound of bodyweight
- Upper limit: More than 1.2g/lb has no additional benefit

**For a 180lb Guy:**
- Minimum: 126g daily
- Optimal: 144-180g daily

**Best Protein Sources:**

| Source | Protein per 100g |
|--------|-----------------|
| Chicken breast | 31g |
| Lean beef | 26g |
| Salmon | 25g |
| Greek yogurt | 10g |
| Eggs | 13g |
| Cottage cheese | 11g |
| Whey protein | 80g |

**Hitting It Daily:**
- Each meal should have a protein source
- 30-50g per meal, 3-4 meals
- Fill gaps with protein shakes if needed
- Front-load protein earlier in day for satiety`,
    },
    {
      id: 'carbs-fats',
      title: 'Carbs and Fats: The Flexible Macros',
      humorLevel: 'medium',
      content: `After calories and protein, carbs and fats are flexible. Here's how to think about them:

**Fats: The Minimum**
- Never go below 0.3g/lb bodyweight
- Fats are essential for hormones (testosterone)
- Too low = hormone problems, brain fog, bad skin
- For 180lb: minimum 54g fat daily

**Carbs: The Performance Fuel**
- Not "essential" but highly beneficial for training
- Fill remaining calories after protein and fat
- More carbs = better gym performance
- Lower carbs = some people do better for fat loss

**Setting Macros (Example: 180lb guy, 2500 calories)**

Option 1: Moderate carb (recommended)
- Protein: 180g (720 cal)
- Fat: 80g (720 cal)
- Carbs: 265g (1060 cal)

Option 2: Lower carb
- Protein: 180g (720 cal)
- Fat: 100g (900 cal)
- Carbs: 220g (880 cal)

Option 3: Higher carb (athletic)
- Protein: 180g (720 cal)
- Fat: 60g (540 cal)
- Carbs: 310g (1240 cal)

**The Truth:**
For most people, the exact ratio doesn't matter much. Hit protein, stay in your calorie range, and adjust carbs/fats based on preference and how you feel.`,
    },
    {
      id: 'food-quality',
      title: 'Food Quality: What to Actually Eat',
      humorLevel: 'medium-high',
      content: `Here's where things get simpler than the internet suggests:

**The 80/20 Rule:**
- 80% whole, minimally processed foods
- 20% whatever you want

This keeps you sane while getting results.

**Whole Foods (Prioritize These):**

**Proteins:**
- Chicken, turkey, lean beef, fish
- Eggs, Greek yogurt, cottage cheese
- Whey/casein protein powder

**Carbs:**
- Rice, potatoes, oats
- Fruits, vegetables
- Whole grain bread/pasta

**Fats:**
- Olive oil, avocados
- Nuts, seeds
- Fatty fish (salmon)
- Eggs

**Minimize (Not Eliminate):**
- Fried foods
- Sugary snacks and drinks
- Processed meats regularly
- Alcohol (empty calories + lowers testosterone + disrupts sleep)

**The Why:**
Whole foods are more filling per calorie, have more micronutrients, and are harder to overeat. You can lose weight on junk food (calories are calories), but you'll be hungrier and less healthy.`,
      media: [
        {
          id: 'whole-foods',
          type: 'image',
          url: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80',
          alt: 'Whole foods and vegetables',
          caption: '80% whole foods, 20% whatever you want',
          placement: 'inline',
        },
      ],
    },
    {
      id: 'meal-structure',
      title: 'Meal Structure and Timing',
      humorLevel: 'medium',
      content: `Meal timing is overrated for results but matters for adherence and performance.

**The Basics:**
- Total daily intake matters more than timing
- 3-5 meals per day works for most people
- Don't overthink it

**What Slightly Matters:**

1. **Pre-Workout (1-2 hours before)**
   - Carbs + protein = better performance
   - Don't train completely fasted if you can help it
   - Something > nothing

2. **Post-Workout (within 2-3 hours)**
   - Protein helps start recovery
   - The "anabolic window" is way longer than old bro-science claimed
   - Just eat normally, don't stress

3. **Before Bed**
   - Casein or slow protein can help overnight recovery
   - Not essential, just nice

**A Simple Day Structure:**

- Breakfast: Protein + carbs + fats
- Lunch: Protein + carbs + vegetables
- Pre-workout: Light carbs + protein if needed
- Dinner: Protein + carbs + vegetables
- Optional snack: Protein if needed to hit target

**Intermittent Fasting:**
Some people like it. It doesn't burn more fat, but it can help control calories if you're bad at small meals. Personal preference.`,
    },
    {
      id: 'cutting',
      title: 'Eating for Fat Loss',
      humorLevel: 'medium',
      content: `When cutting, everything matters a bit more:

**The Setup:**
1. Calculate maintenance calories
2. Subtract 300-500 calories
3. Set protein at 1g/lb (higher end when cutting)
4. Fill remaining with carbs and fats

**Maximizing Satiety:**
- High volume, low calorie foods (vegetables, lean proteins)
- More protein = more fullness
- High fiber foods
- Drink water before meals
- Eat slowly

**Volume Eating Foods:**
| Food | Calories per 100g |
|------|------------------|
| Lettuce | 5 |
| Cucumber | 16 |
| Egg whites | 52 |
| Chicken breast | 165 |
| Potatoes (boiled) | 77 |
| Greek yogurt (0%) | 59 |

You can eat 500g of potatoes for the same calories as 50g of chips. Volume matters.

**Cutting Mistakes:**
1. Going too aggressive (muscle loss, rebound)
2. Cutting protein (preserves muscle)
3. Eliminating carbs entirely (tanks performance)
4. Weekend binges (erases weekly deficit)
5. Not tracking (guessing incorrectly)`,
      tips: [
        'Weigh daily, average weekly—weight fluctuates',
        "0.5-1% of bodyweight loss per week is optimal",
        'Hunger is normal but not unbearable—adjust if miserable'
      ],
    },
    {
      id: 'bulking',
      title: 'Eating for Muscle Gain',
      humorLevel: 'medium',
      content: `Bulking done right builds muscle. Bulking done wrong just makes you fat.

**The Setup:**
1. Calculate maintenance
2. Add 200-300 calories (lean bulk) or 400-500 (standard bulk)
3. Set protein at 0.8-1g/lb
4. Distribute remaining to carbs and fats (favor carbs for training)

**Lean Bulk vs Dirty Bulk:**

| Approach | Surplus | Result |
|----------|---------|--------|
| Lean bulk | +200-300 | Slow muscle gain, minimal fat |
| Standard bulk | +400-500 | Good muscle gain, some fat |
| Dirty bulk | +1000+ | Some muscle, lots of fat |

**Recommendation:**
Lean bulk unless you're very underweight. Gaining fat doesn't build muscle faster, it just means a longer cut later.

**Weight Gain Rate:**
- Beginners: 2-4 lbs/month possible
- Intermediate: 1-2 lbs/month realistic
- Advanced: 0.5-1 lb/month if lucky

**If weight isn't going up:**
You're not eating enough. Track more accurately and add 100-200 calories.

**Bulking Mistakes:**
1. Gaining too fast ("I'll cut later" → never cuts)
2. Dirty bulking (just makes you fat)
3. Not tracking (surplus might actually be deficit)
4. Using bulk as excuse to eat garbage`,
    },
    {
      id: 'supplements',
      title: 'Supplements That Actually Work',
      humorLevel: 'medium-high',
      content: `Most supplements are garbage. Here's what's worth your money:

**Tier 1: Actually Works**

1. **Creatine Monohydrate**
   - 5g daily, any time
   - Strength, size, cognition
   - Costs $0.10/day
   - No loading needed

2. **Protein Powder**
   - Convenient protein source
   - Whey, casein, or plant-based
   - Not magic, just food in powder form

3. **Vitamin D3**
   - Most people are deficient
   - 2000-5000 IU daily
   - Get blood work to confirm

4. **Omega-3 (Fish Oil)**
   - Anti-inflammatory
   - Brain and heart health
   - 2-3g EPA/DHA daily

**Tier 2: Situationally Useful**

5. **Caffeine** — Performance boost (from coffee is fine)
6. **Magnesium** — Most people are deficient, helps sleep
7. **Collagen** — May help joints and skin
8. **Zinc** — If deficient (many are)

**Tier 3: Probably Wasting Money**

- BCAAs (get protein instead)
- Fat burners (mostly caffeine + fillers)
- Testosterone boosters (don't work)
- Most pre-workouts (caffeine + expensive pixie dust)

**The Rule:**
Get 95% of results from food. Use supplements to fill gaps, not replace meals.`,
      products: ['creatine_mono', 'omega3_fish_oil', 'vitamin_d3_k2', 'magnesium_glycinate', 'collagen_peptides'],
    },
    {
      id: 'practical',
      title: 'Practical Meal Prep',
      humorLevel: 'medium',
      content: `Knowing what to eat is useless if you don't actually do it. Here's how:

**The Basics of Meal Prep:**
1. Pick 2-3 protein sources
2. Pick 2-3 carb sources
3. Pick vegetables
4. Cook in bulk
5. Store in containers
6. Eat throughout week

**Simple Prep (Sunday, 2 hours):**

**Proteins:**
- 2 lbs chicken breast (baked or grilled)
- 1 lb ground turkey or lean beef
- 1 dozen hard boiled eggs

**Carbs:**
- Big batch of rice (rice cooker)
- Bag of potatoes (roasted or boiled)
- Oats (just need measuring)

**Vegetables:**
- Pre-washed salad bags
- Broccoli/green beans (steam or roast)
- Frozen vegetables (microwave)

**Assembly:**
Each meal: 6-8oz protein + 1 cup carbs + vegetables

**If You Hate Meal Prep:**
- Buy pre-cooked rotisserie chicken
- Microwave rice packets
- Pre-cut vegetables
- More expensive but still works

**Eating Out:**
- Prioritize protein (grilled chicken, fish, steak)
- Ask for dressing on side
- Skip the bread basket
- Don't drink calories
- It's not that complicated`,
      media: [
        {
          id: 'meal-prep',
          type: 'image',
          url: 'https://images.unsplash.com/photo-1532768778661-1b2b2df1d79d?w=800&q=80',
          alt: 'Meal prep containers',
          caption: 'Meal prep: 2 hours saves you all week',
          placement: 'inline',
        },
      ],
    },
    {
      id: 'common-mistakes',
      title: 'Common Nutrition Mistakes',
      humorLevel: 'medium-high',
      content: `Don't be this guy:

**Mistake 1: Not Tracking**
"I eat healthy but can't lose weight."
You're eating more than you think. Track for 2 weeks. I promise.

**Mistake 2: Drinking Calories**
Soda, juice, alcohol, fancy coffee drinks. 500+ invisible calories daily. Switch to water, black coffee, diet drinks.

**Mistake 3: Weekend Destruction**
5 days of deficit, 2 days of surplus = maintenance. The weekend counts.

**Mistake 4: All-or-Nothing**
One bad meal doesn't ruin the week. Just get back on track. Don't spiral into "I already messed up so..."

**Mistake 5: Avoiding Carbs**
Carbs aren't the enemy. Excess calories are. Low carb works by reducing calories, not magic.

**Mistake 6: Not Eating Enough Protein**
"I think I get enough." You probably don't. Track it. 0.8-1g/lb is more than most people think.

**Mistake 7: Relying on Supplements**
No supplement will fix a bad diet. Food first, supplements for gaps.

**Mistake 8: Overcomplicating**
Meal timing, food combining, "clean eating" obsession. Hit calories and protein. That's 80% of it.`,
    },
    {
      id: 'action-plan',
      title: 'Your Action Plan',
      humorLevel: 'medium',
      content: `Here's exactly what to do:

**Week 1: Baseline**
- Download a tracking app (MyFitnessPal, Cronometer)
- Get a food scale
- Track everything you eat for 7 days (no changes)
- See where you actually are

**Week 2: Adjust**
- Calculate your calorie target based on goal
- Set protein target (0.8-1g/lb)
- Start hitting these targets

**Week 3-4: Dial In**
- Monitor weight trends
- Adjust calories if needed (not losing? Reduce by 100-200)
- Find meals that work for you
- Build a rotation of go-to meals

**Ongoing: Optimize**
- Track until you can estimate accurately
- Meal prep to stay consistent
- Weigh weekly, adjust as needed
- Don't overcomplicate

**The Truth:**
Most of your results come from:
1. Eating in the right calorie range
2. Hitting protein consistently
3. Doing this for months/years

Everything else is optimization. Master these three first.`,
      products: ['food_scale'],
    },
  ],
};
