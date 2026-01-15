#!/usr/bin/env python3
"""
Quick test script for Crawl4AI installation
Tests basic scraping without authentication
"""

import asyncio
import os
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig


async def test_basic_scrape():
    """Test basic scraping of example.com"""
    print("🔄 Testing Crawl4AI basic scraping...")
    print("📍 URL: https://example.com")

    try:
        async with AsyncWebCrawler(verbose=True) as crawler:
            result = await crawler.arun(
                url="https://example.com",
                config=CrawlerRunConfig(word_count_threshold=1, verbose=True),
            )

            print("\n✅ Scraping successful!")
            print(f"📊 Content length: {len(result.markdown)} characters")
            print(f"📄 Title: {result.metadata.get('title', 'N/A')}")
            print("\n--- First 500 characters of markdown ---")
            print(result.markdown[:500])
            print("\n--- End preview ---")

            # Save to file
            output_file = "test_output.md"
            with open(output_file, "w", encoding="utf-8") as f:
                f.write("# Test Scrape: example.com\n\n")
                f.write(result.markdown)

            print(f"\n💾 Saved to: {output_file}")
            print("\n🎉 Test completed successfully!")
            return True

    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        return False


async def test_llm_extraction():
    """Test LLM-powered extraction (requires API key)"""
    if not os.getenv("OPENAI_API_KEY"):
        print("\n⚠️  Skipping LLM test - OPENAI_API_KEY not set")
        print("   To test LLM extraction, run:")
        print("   export OPENAI_API_KEY='your-key-here'")
        return None

    print("\n🔄 Testing LLM-powered extraction...")

    try:
        from crawl4ai import LLMExtractionStrategy, LLMConfig

        llm_config = LLMConfig(provider="openai/gpt-4o-mini")
        extraction = LLMExtractionStrategy(
            llm_config=llm_config,
            instruction="Extract the main heading and summarize the page purpose in one sentence",
        )

        async with AsyncWebCrawler(verbose=True) as crawler:
            result = await crawler.arun(
                url="https://example.com",
                config=CrawlerRunConfig(extraction_strategy=extraction, verbose=True),
            )

            print("\n✅ LLM extraction successful!")
            print("\n--- Extracted content ---")
            print(
                result.extracted_content
                if hasattr(result, "extracted_content")
                else result.markdown[:300]
            )
            print("\n--- End extraction ---")

            return True

    except Exception as e:
        print(f"\n❌ LLM test failed: {e}")
        return False


async def main():
    print("=" * 60)
    print("Crawl4AI Installation Test")
    print("=" * 60)

    # Test 1: Basic scraping
    basic_test = await test_basic_scrape()

    # Test 2: LLM extraction
    llm_test = await test_llm_extraction()

    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    print(f"Basic Scraping: {'✅ PASSED' if basic_test else '❌ FAILED'}")
    if llm_test is not None:
        print(f"LLM Extraction: {'✅ PASSED' if llm_test else '❌ FAILED'}")
    else:
        print("LLM Extraction: ⏭️  SKIPPED (no API key)")
    print("=" * 60)

    if basic_test:
        print("\n✨ Crawl4AI is ready to use!")
        print("   Try: /crawl <url> in Claude Code")
    else:
        print("\n⚠️  Basic test failed. Check installation.")


if __name__ == "__main__":
    asyncio.run(main())
