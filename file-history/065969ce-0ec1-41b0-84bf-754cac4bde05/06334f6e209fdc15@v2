#!/usr/bin/env python3
"""
Gemini API Configuration for Crawl4AI
Replaces OpenAI with Google's Gemini for cheaper operation

Features:
- URL Context: Read and understand web pages in real-time
- Google Search Grounding: Up-to-date information with fact-checking
- Multiple models: Flash, Pro, Thinking, Experimental
"""

import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

# Your Gemini API Key
GEMINI_API_KEY = "AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"

# Gemini Models (ranked by speed/cost)
MODELS = {
    "flash": "gemini-2.0-flash-exp",  # Fastest, cheapest (experimental)
    "flash_stable": "gemini-1.5-flash",  # Stable flash model
    "pro": "gemini-1.5-pro",  # Best for complex reasoning
    "thinking": "gemini-2.0-flash-thinking-exp",  # Step-by-step analysis
}


async def crawl_with_gemini(
    url: str,
    extraction_instruction: str,
    model: str = "flash",
    enable_url_context: bool = False,
    enable_grounding: bool = False,
    output_file: str = None,
):
    """
    Crawl a website using Gemini API

    Args:
        url: Target URL to scrape
        extraction_instruction: Natural language description of what to extract
        model: Gemini model to use (flash, flash_stable, pro, thinking)
        enable_url_context: Enable real-time URL reading
        enable_grounding: Enable Google Search grounding for up-to-date info
        output_file: Output markdown file path

    Returns:
        Result object with markdown content
    """

    # Configure Gemini LLM
    llm_config = LLMConfig(
        provider=f"gemini/{MODELS[model]}",
        api_token=GEMINI_API_KEY,
        temperature=1.0,  # More natural suggestions (0.0 = deterministic)
        extra_args={
            # Note: URL context and grounding are mutually exclusive with function calling
            # Crawl4AI doesn't use function calling, so we can enable these
            "enableUrlContext": enable_url_context,
            "enableGrounding": enable_grounding,
        },
    )

    # Create extraction strategy
    extraction_strategy = LLMExtractionStrategy(
        llm_config=llm_config, instruction=extraction_instruction
    )

    print(f"🚀 Starting crawl with Gemini ({MODELS[model]})...")
    print(f"📍 URL: {url}")
    print(f"🎯 Extraction: {extraction_instruction}")
    if enable_url_context:
        print("🌐 URL Context: ENABLED")
    if enable_grounding:
        print("🔍 Google Search Grounding: ENABLED")
    print()

    async with AsyncWebCrawler(verbose=True) as crawler:
        result = await crawler.arun(
            url=url,
            config=CrawlerRunConfig(
                extraction_strategy=extraction_strategy,
                word_count_threshold=10,
                verbose=True,
            ),
        )

        # Save to file
        if not output_file:
            output_file = f"scraped_{url.replace('https://', '').replace('http://', '').replace('/', '_')[:50]}.md"

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(f"# Scraped from {url}\n\n")
            f.write(f"**Extraction**: {extraction_instruction}\n\n")
            f.write(f"**Model**: {MODELS[model]}\n")
            if enable_url_context:
                f.write("**URL Context**: Enabled\n")
            if enable_grounding:
                f.write("**Google Search Grounding**: Enabled\n")
            f.write("\n---\n\n")
            f.write(result.markdown)

        print("\n✅ Scraping complete!")
        print(f"📊 Extracted {len(result.markdown)} characters")
        print(f"💾 Saved to: {output_file}")

        return result


async def crawl_with_login_gemini(
    login_url: str,
    target_url: str,
    username: str,
    password: str,
    extraction_instruction: str,
    model: str = "flash",
    enable_grounding: bool = False,
    output_file: str = None,
):
    """
    Crawl with form-based authentication using Gemini

    Args:
        login_url: Login page URL
        target_url: Target page to scrape after login
        username: Login username
        password: Login password
        extraction_instruction: What to extract
        model: Gemini model
        enable_grounding: Enable Google Search grounding
        output_file: Output file path
    """

    llm_config = LLMConfig(
        provider=f"gemini/{MODELS[model]}",
        api_token=GEMINI_API_KEY,
        temperature=1.0,
        extra_args={"enableGrounding": enable_grounding},
    )

    extraction_strategy = LLMExtractionStrategy(
        llm_config=llm_config, instruction=extraction_instruction
    )

    print("🔐 Starting authenticated crawl with Gemini...")
    print(f"📍 Login URL: {login_url}")
    print(f"📍 Target URL: {target_url}")
    print()

    async with AsyncWebCrawler(headless=False, verbose=True) as crawler:
        # Step 1: Login
        print("🔑 Logging in...")
        await crawler.arun(
            url=login_url,
            config=CrawlerRunConfig(
                js_code=f"""
                // Fill login form
                document.querySelector('input[name="username"]').value = '{username}';
                document.querySelector('input[name="password"]').value = '{password}';
                document.querySelector('form').submit();
                """,
                wait_for=3000,  # Wait 3 seconds for login
                verbose=True,
            ),
        )

        # Step 2: Navigate to target and extract
        print("📄 Extracting content from target page...")
        result = await crawler.arun(
            url=target_url,
            config=CrawlerRunConfig(
                extraction_strategy=extraction_strategy, verbose=True
            ),
        )

        # Save
        if not output_file:
            output_file = "authenticated_scrape.md"

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(f"# Authenticated Scrape from {target_url}\n\n")
            f.write(f"**Extraction**: {extraction_instruction}\n")
            f.write(f"**Model**: {MODELS[model]}\n\n")
            f.write("---\n\n")
            f.write(result.markdown)

        print("\n✅ Authenticated scraping complete!")
        print(f"💾 Saved to: {output_file}")

        return result


# Example Usage Functions


async def example_simple():
    """Example: Simple scraping with Gemini Flash"""
    await crawl_with_gemini(
        url="https://example.com",
        extraction_instruction="Extract the main heading and purpose of this domain",
        model="flash",
    )


async def example_with_grounding():
    """Example: Scrape with Google Search grounding for up-to-date info"""
    await crawl_with_gemini(
        url="https://news.ycombinator.com",
        extraction_instruction="Extract the top 5 stories and summarize each with current context",
        model="flash",
        enable_grounding=True,  # Uses Google Search for fact-checking
    )


async def example_with_url_context():
    """Example: Analyze documentation with URL context"""
    await crawl_with_gemini(
        url="https://docs.python.org/3/library/asyncio.html",
        extraction_instruction="Summarize the key asyncio concepts and provide code examples",
        model="pro",  # Use Pro for complex reasoning
        enable_url_context=True,  # Can read linked pages
    )


async def example_authenticated():
    """Example: Login and scrape dashboard"""
    await crawl_with_login_gemini(
        login_url="https://example.com/login",
        target_url="https://example.com/dashboard",
        username="user@example.com",
        password="password123",
        extraction_instruction="Extract all project names and their status",
        model="flash",
        enable_grounding=False,
    )


if __name__ == "__main__":
    # Run example
    print("=" * 60)
    print("Gemini API Test for Crawl4AI")
    print("=" * 60)
    print()

    # Simple example
    asyncio.run(example_simple())

    # Uncomment to test other features:
    # asyncio.run(example_with_grounding())
    # asyncio.run(example_with_url_context())
    # asyncio.run(example_authenticated())
