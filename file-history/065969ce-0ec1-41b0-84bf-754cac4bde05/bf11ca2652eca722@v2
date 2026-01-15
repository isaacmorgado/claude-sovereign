#!/usr/bin/env python3
"""
Basic scrape example with Gemini API
Demonstrates simple web scraping with natural language extraction
"""

import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

GEMINI_API_KEY = "AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"


async def basic_scrape_example():
    """Simple example: Scrape and extract with Gemini"""
    print("=" * 60)
    print("Basic Scrape Example with Gemini AI")
    print("=" * 60)
    print()

    # Configure Gemini
    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=1.0,
    )

    # Create extraction strategy
    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="Extract the main heading and explain the purpose of this domain",
    )

    print("🚀 Starting scrape...")
    print("📍 URL: https://example.com")
    print("🤖 Model: gemini-2.0-flash-exp")
    print()

    # Scrape
    async with AsyncWebCrawler(verbose=True) as crawler:
        result = await crawler.arun(
            url="https://example.com",
            config=CrawlerRunConfig(extraction_strategy=extraction, verbose=True),
        )

        print("\n✅ Scraping complete!")
        print(f"📊 Content length: {len(result.markdown)} characters")
        print()
        print("--- Extracted Content ---")
        print(result.markdown)
        print("--- End ---")
        print()

        # Save result
        with open("example_scrape_output.md", "w", encoding="utf-8") as f:
            f.write("# Example Scrape with Gemini\n\n")
            f.write("**URL**: https://example.com\n")
            f.write("**Model**: gemini-2.0-flash-exp\n\n")
            f.write("---\n\n")
            f.write(result.markdown)

        print("💾 Saved to: example_scrape_output.md")
        print()
        print("🎉 Example complete!")


if __name__ == "__main__":
    asyncio.run(basic_scrape_example())
