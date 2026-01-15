#!/usr/bin/env python3
"""
ZhipuAI GLM Model Examples
Demonstrates web scraping with GLM-4 models via Crawl4AI

GLM Models:
- GLM-4-Long: 1M token context (best for large pages)
- GLM-4-Plus: Enhanced reasoning (best for complex extraction)
- GLM-4-Flash: Fast and cheap (best for simple tasks)
- GLM-4: Balanced performance

Cost: Starting at $3/month with Z.ai subscription
"""

import asyncio
import os
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

# Get API key from environment
ZHIPUAI_API_KEY = os.getenv("ZHIPUAI_API_KEY", "")

if not ZHIPUAI_API_KEY:
    print("⚠️  ZHIPUAI_API_KEY environment variable not set!")
    print()
    print("To use ZhipuAI GLM models, set your API key:")
    print("  export ZHIPUAI_API_KEY='your-api-key-here'")
    print()
    print("Get your API key from: https://open.bigmodel.cn/")
    print()
    exit(1)

# GLM Model configurations
GLM_MODELS = {
    "glm-4-long": {
        "name": "zhipu/glm-4-long",
        "context": "1M tokens",
        "best_for": "Large pages, comprehensive extraction",
        "speed": "Medium",
        "cost": "$$",
    },
    "glm-4-plus": {
        "name": "zhipu/glm-4-plus",
        "context": "200K tokens",
        "best_for": "Complex reasoning, analysis",
        "speed": "Medium",
        "cost": "$$$",
    },
    "glm-4-flash": {
        "name": "zhipu/glm-4-flash",
        "context": "200K tokens",
        "best_for": "Fast extraction, simple tasks",
        "speed": "Fast",
        "cost": "$",
    },
    "glm-4": {
        "name": "zhipu/glm-4",
        "context": "200K tokens",
        "best_for": "Balanced performance",
        "speed": "Medium",
        "cost": "$$",
    },
    "glm-4-air": {
        "name": "zhipu/glm-4-air",
        "context": "200K tokens",
        "best_for": "Lightweight tasks",
        "speed": "Fast",
        "cost": "$",
    },
}


async def scrape_with_glm(
    url: str, extraction_instruction: str, model: str = "glm-4-long"
):
    """
    Scrape a website using GLM models

    Args:
        url: Website URL
        extraction_instruction: What to extract
        model: GLM model (glm-4-long, glm-4-plus, glm-4-flash, glm-4, glm-4-air)
    """

    model_info = GLM_MODELS[model]

    print(f"🚀 Starting scrape with {model.upper()}")
    print(f"📍 URL: {url}")
    print(f"🎯 Extract: {extraction_instruction}")
    print()
    print("Model Info:")
    print(f"  - Context: {model_info['context']}")
    print(f"  - Best for: {model_info['best_for']}")
    print(f"  - Speed: {model_info['speed']}")
    print(f"  - Cost: {model_info['cost']}")
    print()

    # Configure GLM
    llm_config = LLMConfig(
        provider=model_info["name"],
        api_token=ZHIPUAI_API_KEY,
        temperature=0.7,
    )

    extraction = LLMExtractionStrategy(
        llm_config=llm_config, instruction=extraction_instruction
    )

    async with AsyncWebCrawler(verbose=True) as crawler:
        result = await crawler.arun(
            url=url, config=CrawlerRunConfig(extraction_strategy=extraction)
        )

        # Save output
        filename = f"{model}_output.md"
        with open(filename, "w", encoding="utf-8") as f:
            f.write(f"# {url}\n\n")
            f.write(f"**Model**: {model.upper()}\n")
            f.write(f"**Extraction**: {extraction_instruction}\n\n")
            f.write("---\n\n")
            f.write(result.markdown)

        print("\n✅ Scraping complete!")
        print(f"📊 Extracted: {len(result.markdown)} characters")
        print(f"💾 Saved to: {filename}")
        print()

        return result


async def example_1_large_page():
    """Example 1: Scrape large documentation page with GLM-4-Long"""
    print("=" * 60)
    print("Example 1: Large Page Scraping (GLM-4-Long)")
    print("=" * 60)
    print()

    await scrape_with_glm(
        url="https://example.com",
        extraction_instruction="Extract all content and organize into sections with summaries",
        model="glm-4-long",  # 1M context for large pages
    )


async def example_2_fast_scraping():
    """Example 2: Fast scraping with GLM-4-Flash"""
    print("=" * 60)
    print("Example 2: Fast Scraping (GLM-4-Flash)")
    print("=" * 60)
    print()

    await scrape_with_glm(
        url="https://example.com",
        extraction_instruction="Extract the main heading and brief description",
        model="glm-4-flash",  # Fastest and cheapest
    )


async def example_3_complex_reasoning():
    """Example 3: Complex analysis with GLM-4-Plus"""
    print("=" * 60)
    print("Example 3: Complex Reasoning (GLM-4-Plus)")
    print("=" * 60)
    print()

    await scrape_with_glm(
        url="https://example.com",
        extraction_instruction="""
        Analyze this page and provide:
        1. Main topics covered
        2. Key insights and takeaways
        3. Target audience
        4. Content quality assessment
        5. Recommendations for improvements
        """,
        model="glm-4-plus",  # Best reasoning
    )


async def example_4_news_monitoring():
    """Example 4: News extraction with GLM-4"""
    print("=" * 60)
    print("Example 4: News Monitoring (GLM-4)")
    print("=" * 60)
    print()

    await scrape_with_glm(
        url="https://news.ycombinator.com",
        extraction_instruction="Extract top 10 story titles with scores and brief summaries",
        model="glm-4",  # Balanced
    )


async def example_5_product_analysis():
    """Example 5: E-commerce product analysis"""
    print("=" * 60)
    print("Example 5: Product Analysis (GLM-4-Plus)")
    print("=" * 60)
    print()

    await scrape_with_glm(
        url="https://example.com/product",
        extraction_instruction="""
        Extract product information:
        - Product name and description
        - Price and availability
        - Key features (bulleted list)
        - Customer reviews summary
        - Competitor comparison
        """,
        model="glm-4-plus",
    )


async def compare_models():
    """Compare all GLM models on the same page"""
    print("=" * 70)
    print("Model Comparison: All GLM Models on Same Page")
    print("=" * 70)
    print()

    url = "https://example.com"
    instruction = "Extract the main content and provide a summary"

    models_to_test = ["glm-4-flash", "glm-4", "glm-4-plus", "glm-4-long"]

    for model in models_to_test:
        print(f"\nTesting {model.upper()}...")
        print("-" * 60)
        await scrape_with_glm(url=url, extraction_instruction=instruction, model=model)
        print()
        await asyncio.sleep(2)  # Rate limit safety


async def main():
    """Run GLM examples"""
    print("\n" + "=" * 70)
    print("ZhipuAI GLM Model Examples for Web Scraping")
    print("=" * 70)
    print()
    print("Available Models:")
    for model, info in GLM_MODELS.items():
        print(f"  {model.upper()}")
        print(f"    Context: {info['context']}")
        print(f"    Best for: {info['best_for']}")
        print(f"    Speed: {info['speed']}, Cost: {info['cost']}")
        print()

    print("Running Example 1: Large Page Scraping...")
    print("(Using example.com for demonstration)")
    print()

    try:
        # Run a single example by default
        await example_1_large_page()

        print("\n" + "=" * 70)
        print("✅ Example completed!")
        print("=" * 70)
        print()
        print("To run other examples:")
        print("  1. Fast scraping: example_2_fast_scraping()")
        print("  2. Complex reasoning: example_3_complex_reasoning()")
        print("  3. News monitoring: example_4_news_monitoring()")
        print("  4. Product analysis: example_5_product_analysis()")
        print("  5. Compare all models: compare_models()")
        print()
        print("Uncomment the example calls in main() to run them.")
        print()
        print("💡 Best Practices:")
        print("  - Use GLM-4-Long for large documentation pages")
        print("  - Use GLM-4-Flash for simple, fast extraction")
        print("  - Use GLM-4-Plus for complex analysis and reasoning")
        print("  - Use GLM-4 for balanced performance")
        print()
        print("💰 Pricing:")
        print("  - Z.ai subscription: Starting at $3/month")
        print("  - Input: ~$0.44-0.60 per 1M tokens")
        print("  - Output: ~$1.74-2.20 per 1M tokens")
        print()
        print("📚 Documentation:")
        print("  - ZhipuAI: https://open.bigmodel.cn/")
        print("  - API Docs: https://apidog.com/blog/glm-4-7-api/")
        print("  - GitHub SDK: https://github.com/MetaGLM/zhipuai-sdk-python-v4")

    except Exception as e:
        print(f"❌ Error: {e}")
        print()
        print("This is expected with example.com (no real content).")
        print("Try with real URLs for actual scraping.")


if __name__ == "__main__":
    asyncio.run(main())
