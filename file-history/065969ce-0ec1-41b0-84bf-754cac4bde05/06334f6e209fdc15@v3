#!/usr/bin/env python3
"""
Multi-Provider AI Configuration for Crawl4AI
Supports Google Gemini and ZhipuAI GLM models for cost-effective operation

Providers:
- Gemini: Google's models with URL context and grounding
- GLM: ZhipuAI's models with 200K context and strong reasoning

Features:
- URL Context (Gemini): Read and understand web pages in real-time
- Google Search Grounding (Gemini): Up-to-date information with fact-checking
- Long Context (GLM): 200K token context window
- Multiple models: Flash, Pro, Thinking, GLM-4, GLM-4.7
"""

import asyncio
import os
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

# API Keys
GEMINI_API_KEY = "AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"
ZHIPUAI_API_KEY = os.getenv("ZHIPUAI_API_KEY", "")  # Set via environment variable

# Gemini Models (ranked by speed/cost)
GEMINI_MODELS = {
    "flash": "gemini-2.0-flash-exp",  # Fastest, cheapest (experimental)
    "flash_stable": "gemini-1.5-flash",  # Stable flash model
    "pro": "gemini-1.5-pro",  # Best for complex reasoning
    "thinking": "gemini-2.0-flash-thinking-exp",  # Step-by-step analysis
}

# ZhipuAI GLM Models (via LiteLLM)
GLM_MODELS = {
    "glm-4": "zhipu/glm-4",  # Standard chat model, good balance
    "glm-4-flash": "zhipu/glm-4-flash",  # Faster, cheaper
    "glm-4-plus": "zhipu/glm-4-plus",  # Enhanced reasoning
    "glm-4-long": "zhipu/glm-4-long",  # Long context (1M tokens)
    "glm-4-airx": "zhipu/glm-4-airx",  # Air model variant
    "glm-4-air": "zhipu/glm-4-air",  # Lightweight model
}

# Combined models for easy access
MODELS = {
    # Gemini models
    "flash": "gemini-2.0-flash-exp",
    "flash_stable": "gemini-1.5-flash",
    "pro": "gemini-1.5-pro",
    "thinking": "gemini-2.0-flash-thinking-exp",
    # GLM models
    "glm-4": "zhipu/glm-4",
    "glm-4-flash": "zhipu/glm-4-flash",
    "glm-4-plus": "zhipu/glm-4-plus",
    "glm-4-long": "zhipu/glm-4-long",
    "glm-4-airx": "zhipu/glm-4-airx",
    "glm-4-air": "zhipu/glm-4-air",
}

# Model recommendations for different use cases
RECOMMENDED_MODELS = {
    "scraping": "glm-4-long",  # Best for large pages (1M context)
    "fast": "glm-4-flash",  # Fastest, cheapest
    "reasoning": "glm-4-plus",  # Best for complex extraction
    "gemini_fast": "flash",  # Gemini fastest
    "gemini_smart": "pro",  # Gemini smartest
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
    model_name = GEMINI_MODELS.get(model, MODELS.get(model, model))

    # If it's a Gemini model, use gemini/ prefix
    if not model_name.startswith("gemini/"):
        model_name = f"gemini/{model_name}"

    llm_config = LLMConfig(
        provider=model_name,
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


async def crawl_with_glm(
    url: str,
    extraction_instruction: str,
    model: str = "glm-4-long",
    output_file: str = None,
):
    """
    Crawl a website using ZhipuAI GLM models

    Args:
        url: Target URL to scrape
        extraction_instruction: Natural language description of what to extract
        model: GLM model to use (glm-4, glm-4-flash, glm-4-plus, glm-4-long, glm-4-air, glm-4-airx)
        output_file: Output markdown file path

    Returns:
        Result object with markdown content

    Note:
        - glm-4-long: Best for large pages (1M token context)
        - glm-4-plus: Best for complex reasoning
        - glm-4-flash: Fastest and cheapest
        - glm-4: Balanced performance
    """

    if not ZHIPUAI_API_KEY:
        raise ValueError(
            "ZHIPUAI_API_KEY not set. Please set it via environment variable:\n"
            "export ZHIPUAI_API_KEY='your-api-key'"
        )

    # Get model name from GLM_MODELS or MODELS dict
    model_name = GLM_MODELS.get(model, MODELS.get(model, model))

    # Configure GLM LLM via LiteLLM
    llm_config = LLMConfig(
        provider=model_name,  # e.g., "zhipu/glm-4-long"
        api_token=ZHIPUAI_API_KEY,
        temperature=0.7,  # GLM works well with 0.7 for extraction
    )

    # Create extraction strategy
    extraction_strategy = LLMExtractionStrategy(
        llm_config=llm_config, instruction=extraction_instruction
    )

    print(f"🚀 Starting crawl with ZhipuAI GLM ({model_name})...")
    print(f"📍 URL: {url}")
    print(f"🎯 Extraction: {extraction_instruction}")
    if model == "glm-4-long":
        print("📚 Using 1M token context model (best for large pages)")
    elif model == "glm-4-plus":
        print("🧠 Using enhanced reasoning model")
    elif model == "glm-4-flash":
        print("⚡ Using fast model (cheapest)")
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
            output_file = f"glm_scraped_{url.replace('https://', '').replace('http://', '').replace('/', '_')[:50]}.md"

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(f"# Scraped from {url}\n\n")
            f.write(f"**Extraction**: {extraction_instruction}\n\n")
            f.write(f"**Model**: {model_name}\n")
            f.write("**Provider**: ZhipuAI GLM\n")
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


async def example_glm_long_context():
    """Example: Scrape large page with GLM-4-Long (1M context)"""
    await crawl_with_glm(
        url="https://example.com",
        extraction_instruction="Extract all key information from this page",
        model="glm-4-long",  # Best for large pages
    )


async def example_glm_fast():
    """Example: Fast scraping with GLM-4-Flash"""
    await crawl_with_glm(
        url="https://example.com",
        extraction_instruction="Extract the main heading and purpose",
        model="glm-4-flash",  # Fastest, cheapest
    )


async def example_glm_reasoning():
    """Example: Complex extraction with GLM-4-Plus"""
    await crawl_with_glm(
        url="https://example.com",
        extraction_instruction="Analyze this page and provide a detailed summary with key insights",
        model="glm-4-plus",  # Best reasoning
    )


if __name__ == "__main__":
    # Run example
    print("=" * 70)
    print("Multi-Provider AI Test for Crawl4AI")
    print("=" * 70)
    print()
    print("Available providers:")
    print("  - Gemini: Google's models (URL context, grounding)")
    print("  - GLM: ZhipuAI models (long context, strong reasoning)")
    print()
    print("Running Gemini example (Gemini API key is set)...")
    print()

    # Simple Gemini example
    asyncio.run(example_simple())

    # To test GLM models, set ZHIPUAI_API_KEY environment variable
    if ZHIPUAI_API_KEY:
        print("\n" + "=" * 70)
        print("Testing GLM models...")
        print("=" * 70)
        asyncio.run(example_glm_fast())

    # Uncomment to test other features:
    # asyncio.run(example_with_grounding())
    # asyncio.run(example_with_url_context())
    # asyncio.run(example_authenticated())
    # asyncio.run(example_glm_long_context())
    # asyncio.run(example_glm_reasoning())
