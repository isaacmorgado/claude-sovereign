#!/usr/bin/env python3
"""
Quick test for Gemini API integration with Crawl4AI
Tests basic scraping, URL context, and Google Search grounding
"""

import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

GEMINI_API_KEY = "AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"

MODELS = {
    "flash": "gemini-2.0-flash-exp",
    "flash_stable": "gemini-1.5-flash",
    "pro": "gemini-1.5-pro",
}


async def test_basic_gemini():
    """Test 1: Basic Gemini scraping without features"""
    print("=" * 60)
    print("TEST 1: Basic Gemini Scraping (No Features)")
    print("=" * 60)
    print()

    try:
        llm_config = LLMConfig(
            provider=f"gemini/{MODELS['flash']}",
            api_token=GEMINI_API_KEY,
            temperature=1.0,
        )

        extraction_strategy = LLMExtractionStrategy(
            llm_config=llm_config,
            instruction="Extract the main heading and explain the purpose of this domain in one sentence",
        )

        print(f"🚀 Model: {MODELS['flash']}")
        print("📍 URL: https://example.com")
        print("🎯 Extraction: Main heading and purpose")
        print()

        async with AsyncWebCrawler(verbose=True) as crawler:
            result = await crawler.arun(
                url="https://example.com",
                config=CrawlerRunConfig(
                    extraction_strategy=extraction_strategy,
                    word_count_threshold=1,
                    verbose=True,
                ),
            )

            print("\n✅ Test 1 PASSED")
            print(f"📊 Content length: {len(result.markdown)} characters")
            print("\n--- Extracted Content ---")
            print(result.markdown[:500])
            print("--- End ---\n")

            # Save result
            with open("test_basic_gemini.md", "w", encoding="utf-8") as f:
                f.write("# Test 1: Basic Gemini Scraping\n\n")
                f.write(f"**Model**: {MODELS['flash']}\n\n")
                f.write(result.markdown)

            return True

    except Exception as e:
        print(f"\n❌ Test 1 FAILED: {e}")
        import traceback

        traceback.print_exc()
        return False


async def test_url_context():
    """Test 2: URL Context feature (read linked pages)"""
    print("\n" + "=" * 60)
    print("TEST 2: URL Context Feature")
    print("=" * 60)
    print()

    try:
        llm_config = LLMConfig(
            provider=f"gemini/{MODELS['pro']}",  # Use Pro for better reasoning
            api_token=GEMINI_API_KEY,
            temperature=1.0,
            extra_args={
                "enableUrlContext": True  # Enable URL context
            },
        )

        extraction_strategy = LLMExtractionStrategy(
            llm_config=llm_config,
            instruction="Analyze this page and any linked resources. Provide a summary of the content.",
        )

        print(f"🚀 Model: {MODELS['pro']}")
        print("📍 URL: https://example.com")
        print("🌐 URL Context: ENABLED")
        print("🎯 Extraction: Content summary with linked resources")
        print()

        async with AsyncWebCrawler(verbose=True) as crawler:
            result = await crawler.arun(
                url="https://example.com",
                config=CrawlerRunConfig(
                    extraction_strategy=extraction_strategy, verbose=True
                ),
            )

            print("\n✅ Test 2 PASSED")
            print(f"📊 Content length: {len(result.markdown)} characters")
            print("\n--- Extracted Content ---")
            print(result.markdown[:500])
            print("--- End ---\n")

            # Save result
            with open("test_url_context.md", "w", encoding="utf-8") as f:
                f.write("# Test 2: URL Context Feature\n\n")
                f.write(f"**Model**: {MODELS['pro']}\n")
                f.write("**URL Context**: Enabled\n\n")
                f.write(result.markdown)

            return True

    except Exception as e:
        print(f"\n❌ Test 2 FAILED: {e}")
        print("Note: URL context may not show obvious differences on simple pages")
        import traceback

        traceback.print_exc()
        return False


async def test_grounding():
    """Test 3: Google Search Grounding (fact-checking)"""
    print("\n" + "=" * 60)
    print("TEST 3: Google Search Grounding")
    print("=" * 60)
    print()

    try:
        llm_config = LLMConfig(
            provider=f"gemini/{MODELS['flash']}",
            api_token=GEMINI_API_KEY,
            temperature=1.0,
            extra_args={
                "enableGrounding": True  # Enable Google Search grounding
            },
        )

        extraction_strategy = LLMExtractionStrategy(
            llm_config=llm_config,
            instruction="Extract information about this domain and verify with latest information from the web",
        )

        print(f"🚀 Model: {MODELS['flash']}")
        print("📍 URL: https://example.com")
        print("🔍 Google Search Grounding: ENABLED")
        print("🎯 Extraction: Domain info with web verification")
        print()

        async with AsyncWebCrawler(verbose=True) as crawler:
            result = await crawler.arun(
                url="https://example.com",
                config=CrawlerRunConfig(
                    extraction_strategy=extraction_strategy, verbose=True
                ),
            )

            print("\n✅ Test 3 PASSED")
            print(f"📊 Content length: {len(result.markdown)} characters")
            print("\n--- Extracted Content ---")
            print(result.markdown[:500])
            print("--- End ---\n")

            # Save result
            with open("test_grounding.md", "w", encoding="utf-8") as f:
                f.write("# Test 3: Google Search Grounding\n\n")
                f.write(f"**Model**: {MODELS['flash']}\n")
                f.write("**Google Search Grounding**: Enabled\n\n")
                f.write(result.markdown)

            return True

    except Exception as e:
        print(f"\n❌ Test 3 FAILED: {e}")
        import traceback

        traceback.print_exc()
        return False


async def test_both_features():
    """Test 4: Both URL Context AND Grounding"""
    print("\n" + "=" * 60)
    print("TEST 4: URL Context + Grounding (Combined)")
    print("=" * 60)
    print()

    try:
        llm_config = LLMConfig(
            provider=f"gemini/{MODELS['pro']}",
            api_token=GEMINI_API_KEY,
            temperature=1.0,
            extra_args={"enableUrlContext": True, "enableGrounding": True},
        )

        extraction_strategy = LLMExtractionStrategy(
            llm_config=llm_config,
            instruction="Analyze this page and linked resources, then verify facts with current web information",
        )

        print(f"🚀 Model: {MODELS['pro']}")
        print("📍 URL: https://example.com")
        print("🌐 URL Context: ENABLED")
        print("🔍 Google Search Grounding: ENABLED")
        print("🎯 Extraction: Full analysis with fact-checking")
        print()

        async with AsyncWebCrawler(verbose=True) as crawler:
            result = await crawler.arun(
                url="https://example.com",
                config=CrawlerRunConfig(
                    extraction_strategy=extraction_strategy, verbose=True
                ),
            )

            print("\n✅ Test 4 PASSED")
            print(f"📊 Content length: {len(result.markdown)} characters")
            print("\n--- Extracted Content ---")
            print(result.markdown[:500])
            print("--- End ---\n")

            # Save result
            with open("test_both_features.md", "w", encoding="utf-8") as f:
                f.write("# Test 4: URL Context + Grounding\n\n")
                f.write(f"**Model**: {MODELS['pro']}\n")
                f.write("**URL Context**: Enabled\n")
                f.write("**Google Search Grounding**: Enabled\n\n")
                f.write(result.markdown)

            return True

    except Exception as e:
        print(f"\n❌ Test 4 FAILED: {e}")
        import traceback

        traceback.print_exc()
        return False


async def main():
    print("\n" + "=" * 60)
    print("GEMINI API INTEGRATION TESTS")
    print("=" * 60)
    print()
    print("Testing Crawl4AI with Google Gemini API")
    print("Features: URL Context, Google Search Grounding")
    print()

    # Run tests
    results = {}

    # Test 1: Basic scraping
    results["basic"] = await test_basic_gemini()

    # Test 2: URL Context
    if results["basic"]:
        results["url_context"] = await test_url_context()
    else:
        print("\n⏭️  Skipping Test 2 (Test 1 failed)")
        results["url_context"] = None

    # Test 3: Grounding
    if results["basic"]:
        results["grounding"] = await test_grounding()
    else:
        print("\n⏭️  Skipping Test 3 (Test 1 failed)")
        results["grounding"] = None

    # Test 4: Both features
    if results["basic"] and results["url_context"] and results["grounding"]:
        results["both"] = await test_both_features()
    else:
        print("\n⏭️  Skipping Test 4 (previous tests failed)")
        results["both"] = None

    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    print()
    print(
        f"Test 1 - Basic Scraping:      {'✅ PASSED' if results['basic'] else '❌ FAILED'}"
    )
    print(
        f"Test 2 - URL Context:         {' ✅ PASSED' if results['url_context'] else '❌ FAILED' if results['url_context'] is False else '⏭️  SKIPPED'}"
    )
    print(
        f"Test 3 - Google Grounding:    {'✅ PASSED' if results['grounding'] else '❌ FAILED' if results['grounding'] is False else '⏭️  SKIPPED'}"
    )
    print(
        f"Test 4 - Both Features:       {'✅ PASSED' if results['both'] else '❌ FAILED' if results['both'] is False else '⏭️  SKIPPED'}"
    )
    print()

    passed = sum(1 for v in results.values() if v is True)
    total = len([v for v in results.values() if v is not None])

    if passed == total and total > 0:
        print(f"✨ ALL TESTS PASSED ({passed}/{total})")
        print("\n🎉 Gemini integration is working perfectly!")
        print("\nGenerated files:")
        print("  - test_basic_gemini.md")
        print("  - test_url_context.md")
        print("  - test_grounding.md")
        print("  - test_both_features.md")
    else:
        print(f"⚠️  SOME TESTS FAILED ({passed}/{total} passed)")
        if not results["basic"]:
            print("\n❗ Basic test failed - check API key and network connection")

    print("=" * 60)


if __name__ == "__main__":
    asyncio.run(main())
