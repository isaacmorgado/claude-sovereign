/**
 * E2E Test Endpoint for Guides System
 * GET /api/test-guides
 */

import { NextResponse } from 'next/server';
import {
  GUIDE_PRODUCTS,
  getBaseStackProducts,
  getTotalProductCount,
  getProductCategories,
  getCategoryDisplayInfo,
  getGuideProductById,
  ALL_GUIDES,
  GUIDE_CATEGORIES,
  getGuideById,
  getGuideBySlug,
  getGuidesByCategory,
  getRelatedGuides,
  searchGuides,
  getTotalGuideCount,
  getTotalReadTime,
  getAllGuideProductIds,
} from '@/data/guides';

interface TestResult {
  name: string;
  passed: boolean;
  details: string;
}

export async function GET() {
  const tests: TestResult[] = [];

  // ============================================
  // PRODUCT TESTS
  // ============================================

  // Test 1: Total product count
  const totalCount = getTotalProductCount();
  tests.push({
    name: 'Products: Total = 33',
    passed: totalCount === 33,
    details: `Got: ${totalCount}`,
  });

  // Test 2: Category counts
  const categories = getProductCategories();
  const expectedCounts: Record<string, number> = {
    hygiene: 4,
    grooming: 5,
    skincare: 5,
    miscellaneous: 9,
    supplements: 10,
  };

  let categoryPassed = true;
  const categoryDetails: string[] = [];
  categories.forEach(({ category, count }) => {
    const expected = expectedCounts[category];
    if (count !== expected) {
      categoryPassed = false;
      categoryDetails.push(`${category}: expected ${expected}, got ${count}`);
    } else {
      categoryDetails.push(`${category}: ${count} ✓`);
    }
  });

  tests.push({
    name: 'Products: Category Counts',
    passed: categoryPassed,
    details: categoryDetails.join(', '),
  });

  // Test 3: Base stack products exist
  const baseStack = getBaseStackProducts();
  tests.push({
    name: 'Products: Base Stack',
    passed: baseStack.length > 0,
    details: `${baseStack.length} products in base stack`,
  });

  // Test 4: All products have region links
  const productsWithRegions = GUIDE_PRODUCTS.filter(
    p => Object.keys(p.regionLinks).length >= 5 || p.directLink
  );
  tests.push({
    name: 'Products: Region Links',
    passed: productsWithRegions.length === GUIDE_PRODUCTS.length,
    details: `${productsWithRegions.length}/${GUIDE_PRODUCTS.length} have 5+ regions`,
  });

  // Test 5: All products have taglines
  const productsWithTaglines = GUIDE_PRODUCTS.filter(
    p => p.tagline && p.tagline.length >= 10
  );
  tests.push({
    name: 'Products: Taglines',
    passed: productsWithTaglines.length === GUIDE_PRODUCTS.length,
    details: `${productsWithTaglines.length}/${GUIDE_PRODUCTS.length} have taglines`,
  });

  // Test 6: Get product by ID
  const testProduct = getGuideProductById('creatine_mono');
  tests.push({
    name: 'Products: Get By ID',
    passed: testProduct !== undefined && testProduct.name === 'Creatine Monohydrate',
    details: testProduct ? `Found: ${testProduct.name}` : 'Not found',
  });

  // Test 7: Category display info
  const hygieneInfo = getCategoryDisplayInfo('hygiene');
  tests.push({
    name: 'Products: Category Display Info',
    passed: hygieneInfo.name === 'Hygiene' && hygieneInfo.icon !== undefined,
    details: `name: ${hygieneInfo.name}, icon: ${hygieneInfo.icon}`,
  });

  // Test 8: Region links contain affiliate tags
  const firstProduct = GUIDE_PRODUCTS[0];
  const usLink = firstProduct.regionLinks.us || '';
  tests.push({
    name: 'Products: Affiliate Tags',
    passed: usLink.includes('tag=looksmaxx-20'),
    details: usLink.substring(0, 80) + '...',
  });

  // ============================================
  // GUIDE TESTS
  // ============================================

  // Test 9: Total guide count
  const guideCount = getTotalGuideCount();
  tests.push({
    name: 'Guides: Total = 9',
    passed: guideCount === 9,
    details: `Got: ${guideCount}`,
  });

  // Test 10: All guides have required fields
  const guidesWithRequiredFields = ALL_GUIDES.filter(
    g =>
      g.id &&
      g.slug &&
      g.title &&
      g.description &&
      g.icon &&
      g.humorLevel &&
      g.sections &&
      g.sections.length > 0
  );
  tests.push({
    name: 'Guides: Required Fields',
    passed: guidesWithRequiredFields.length === guideCount,
    details: `${guidesWithRequiredFields.length}/${guideCount} have all required fields`,
  });

  // Test 11: Guide sections have content
  const guidesWithContent = ALL_GUIDES.filter(
    g => g.sections.every(s => s.id && s.title && s.content && s.content.length > 50)
  );
  tests.push({
    name: 'Guides: Section Content',
    passed: guidesWithContent.length === guideCount,
    details: `${guidesWithContent.length}/${guideCount} have complete sections`,
  });

  // Test 12: Get guide by ID
  const mindsetGuide = getGuideById('mindset');
  tests.push({
    name: 'Guides: Get By ID',
    passed: mindsetGuide !== undefined && mindsetGuide.title === 'Mindset & Beginner Mistakes',
    details: mindsetGuide ? `Found: ${mindsetGuide.title}` : 'Not found',
  });

  // Test 13: Get guide by slug
  const bodyFatGuide = getGuideBySlug('body-fat-mastery');
  tests.push({
    name: 'Guides: Get By Slug',
    passed: bodyFatGuide !== undefined && bodyFatGuide.id === 'body-fat',
    details: bodyFatGuide ? `Found: ${bodyFatGuide.id}` : 'Not found',
  });

  // Test 14: Guide categories
  tests.push({
    name: 'Guides: Categories = 3',
    passed: GUIDE_CATEGORIES.length === 3,
    details: `Categories: ${GUIDE_CATEGORIES.map(c => c.name).join(', ')}`,
  });

  // Test 15: Get guides by category
  const fundamentalsGuides = getGuidesByCategory('fundamentals');
  tests.push({
    name: 'Guides: Get By Category',
    passed: fundamentalsGuides.length === 3,
    details: `Fundamentals: ${fundamentalsGuides.map(g => g.id).join(', ')}`,
  });

  // Test 16: Related guides work
  const relatedToMindset = getRelatedGuides('mindset');
  tests.push({
    name: 'Guides: Related Guides',
    passed: relatedToMindset.length > 0,
    details: `Related to mindset: ${relatedToMindset.map(g => g.id).join(', ')}`,
  });

  // Test 17: Search guides
  const searchResults = searchGuides('body fat');
  tests.push({
    name: 'Guides: Search',
    passed: searchResults.length > 0 && searchResults.some(g => g.id === 'body-fat'),
    details: `Found: ${searchResults.map(g => g.id).join(', ')}`,
  });

  // Test 18: Total read time
  const readTime = getTotalReadTime();
  tests.push({
    name: 'Guides: Total Read Time',
    passed: readTime > 50, // Should be ~95 minutes total
    details: `${readTime} minutes total`,
  });

  // Test 19: Product IDs in guides
  const productIdsInGuides = getAllGuideProductIds();
  tests.push({
    name: 'Guides: Product References',
    passed: productIdsInGuides.length > 10,
    details: `${productIdsInGuides.length} unique product references`,
  });

  // Test 20: All referenced products exist
  const invalidProductIds = productIdsInGuides.filter(id => !getGuideProductById(id));
  tests.push({
    name: 'Guides: Valid Product References',
    passed: invalidProductIds.length === 0,
    details: invalidProductIds.length === 0
      ? 'All product references valid'
      : `Invalid: ${invalidProductIds.join(', ')}`,
  });

  // ============================================
  // GUIDE ORDER TEST
  // ============================================

  // Test 21: Guides are in correct order
  const expectedOrder = ['mindset', 'maintenance', 'body-fat', 'v-taper', 'training', 'core-neck', 'cardio', 'diet', 'skincare'];
  const actualOrder = ALL_GUIDES.map(g => g.id);
  tests.push({
    name: 'Guides: Order',
    passed: JSON.stringify(expectedOrder) === JSON.stringify(actualOrder),
    details: `Order: ${actualOrder.join(' → ')}`,
  });

  // ============================================
  // SUMMARY
  // ============================================

  const passedCount = tests.filter(t => t.passed).length;
  const allPassed = passedCount === tests.length;

  return NextResponse.json({
    status: allPassed ? 'PASS' : 'FAIL',
    summary: `${passedCount}/${tests.length} tests passed`,
    tests,
    stats: {
      products: {
        total: totalCount,
        baseStack: baseStack.length,
        categories: categories.map(c => `${c.category}: ${c.count}`),
      },
      guides: {
        total: guideCount,
        categories: GUIDE_CATEGORIES.length,
        totalReadTime: readTime,
        productReferences: productIdsInGuides.length,
      },
    },
  });
}
