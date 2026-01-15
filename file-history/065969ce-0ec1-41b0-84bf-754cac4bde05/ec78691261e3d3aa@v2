#!/usr/bin/env python3
"""
Custom Extraction Strategies with Gemini
Demonstrates advanced extraction patterns and structured output
"""

import asyncio
import json
from pydantic import BaseModel, Field
from typing import List, Optional
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

GEMINI_API_KEY = "AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"


# Define structured data models using Pydantic
class Product(BaseModel):
    """Product information schema"""

    name: str = Field(description="Product name")
    price: float = Field(description="Price in USD")
    currency: str = Field(default="USD", description="Currency code")
    in_stock: bool = Field(description="Availability status")
    rating: Optional[float] = Field(None, description="Rating out of 5")
    review_count: Optional[int] = Field(None, description="Number of reviews")


class Article(BaseModel):
    """Article/blog post schema"""

    title: str = Field(description="Article title")
    author: str = Field(description="Author name")
    published_date: str = Field(description="Publication date")
    summary: str = Field(description="Brief summary")
    tags: List[str] = Field(default_factory=list, description="Article tags/categories")
    read_time: Optional[int] = Field(None, description="Estimated read time in minutes")


class CompanyInfo(BaseModel):
    """Company information schema"""

    name: str = Field(description="Company name")
    industry: str = Field(description="Industry/sector")
    description: str = Field(description="Company description")
    headquarters: str = Field(description="Location of headquarters")
    founded: str = Field(description="Year founded")
    employee_count: Optional[str] = Field(None, description="Number of employees")


async def strategy_1_structured_extraction():
    """
    Strategy 1: Structured data extraction with Pydantic schema
    Extracts data into well-defined data structures
    """
    print("\n" + "=" * 60)
    print("Strategy 1: Structured Data Extraction")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=0.0,  # Deterministic for structured data
    )

    # Define schema for extraction
    schema = {
        "type": "object",
        "properties": {
            "products": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "name": {"type": "string"},
                        "price": {"type": "number"},
                        "in_stock": {"type": "boolean"},
                        "rating": {"type": "number"},
                    },
                },
            }
        },
    }

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="""
        Extract all products from this page with the following structure:
        - name: Product name
        - price: Price as a number (just the numeric value)
        - in_stock: true if available, false if out of stock
        - rating: Rating out of 5 stars as a number

        Return as JSON array under 'products' key.
        """,
    )

    print("🎯 Extracting structured product data...")
    print("📍 URL: https://example.com")
    print()

    async with AsyncWebCrawler(verbose=True) as crawler:
        result = await crawler.arun(
            url="https://example.com",
            config=CrawlerRunConfig(
                extraction_strategy=extraction,
            ),
        )

        print("✅ Extraction complete")
        print("\n--- Structured Output ---")
        print(result.markdown)
        print("--- End ---")


async def strategy_2_comparative_analysis():
    """
    Strategy 2: Comparative analysis across multiple pages
    Compares and contrasts information from different sources
    """
    print("\n" + "=" * 60)
    print("Strategy 2: Comparative Analysis")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=0.3,  # Slightly creative for analysis
    )

    urls = [
        "https://example.com/product-a",
        "https://example.com/product-b",
        "https://example.com/product-c",
    ]

    results = []

    print(f"📊 Analyzing {len(urls)} products...")
    print()

    async with AsyncWebCrawler(verbose=True) as crawler:
        for url in urls:
            extraction = LLMExtractionStrategy(
                llm_config=llm_config,
                instruction="""
                Extract:
                - Product name
                - Key features (list)
                - Price
                - Pros and cons
                - Target audience

                Format as structured data.
                """,
            )

            result = await crawler.arun(
                url=url, config=CrawlerRunConfig(extraction_strategy=extraction)
            )

            results.append({"url": url, "data": result.markdown})

        # Now create comparative analysis
        print("\n🔍 Creating comparative analysis...")

        comparison_prompt = f"""
        Based on these product pages, create a comparison table:

        {json.dumps(results, indent=2)}

        Create a markdown table comparing:
        - Features
        - Pricing
        - Best use cases
        - Recommendations
        """

        comparison_extraction = LLMExtractionStrategy(
            llm_config=llm_config,
            instruction=comparison_prompt,
        )

        # Use a simple page to get the comparison
        comparison_result = await crawler.arun(
            url="https://example.com",
            config=CrawlerRunConfig(extraction_strategy=comparison_extraction),
        )

        print("✅ Comparison complete")
        print("\n--- Comparative Analysis ---")
        print(comparison_result.markdown)
        print("--- End ---")


async def strategy_3_multi_step_extraction():
    """
    Strategy 3: Multi-step extraction with refinement
    First extracts raw data, then processes and enriches it
    """
    print("\n" + "=" * 60)
    print("Strategy 3: Multi-Step Extraction")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=0.0,
    )

    print("Step 1: Initial data extraction...")

    # Step 1: Extract raw data
    step1_extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="Extract all article titles, authors, and dates from this page.",
    )

    async with AsyncWebCrawler(verbose=True) as crawler:
        step1_result = await crawler.arun(
            url="https://example.com",
            config=CrawlerRunConfig(extraction_strategy=step1_extraction),
        )

        print("✅ Step 1 complete")
        print(f"📊 Extracted {len(step1_result.markdown)} characters")
        print()

        # Step 2: Categorize and summarize
        print("Step 2: Categorization and enrichment...")

        step2_extraction = LLMExtractionStrategy(
            llm_config=llm_config,
            instruction=f"""
            Given this extracted data:

            {step1_result.markdown}

            Categorize the articles into:
            - Technology
            - Business
            - Science
            - Other

            For each category, list the articles and provide a one-sentence summary.
            """,
        )

        step2_result = await crawler.arun(
            url="https://example.com",
            config=CrawlerRunConfig(extraction_strategy=step2_extraction),
        )

        print("✅ Step 2 complete")
        print("\n--- Categorized Output ---")
        print(step2_result.markdown)
        print("--- End ---")


async def strategy_4_sentiment_analysis():
    """
    Strategy 4: Sentiment and tone analysis
    Analyzes sentiment and extracts opinions
    """
    print("\n" + "=" * 60)
    print("Strategy 4: Sentiment Analysis")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=0.0,
    )

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="""
        Analyze this content and extract:

        1. Overall sentiment (positive/negative/neutral)
        2. Sentiment score (-1 to 1)
        3. Key positive points
        4. Key negative points
        5. Main topics discussed
        6. Recommended action (buy/hold/avoid/research more)

        Format as structured JSON.
        """,
    )

    print("😊 Analyzing sentiment...")
    print("📍 URL: https://example.com")
    print()

    async with AsyncWebCrawler(verbose=True) as crawler:
        result = await crawler.arun(
            url="https://example.com",
            config=CrawlerRunConfig(extraction_strategy=extraction),
        )

        print("✅ Sentiment analysis complete")
        print("\n--- Sentiment Report ---")
        print(result.markdown)
        print("--- End ---")


async def strategy_5_data_validation():
    """
    Strategy 5: Extraction with validation
    Extracts data and validates it against rules
    """
    print("\n" + "=" * 60)
    print("Strategy 5: Extraction with Validation")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=0.0,
    )

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="""
        Extract contact information and validate:

        Required fields:
        - email (must be valid email format)
        - phone (must be valid phone number)
        - address (must include street, city, zip)

        For each field, indicate:
        - value: extracted value
        - valid: true/false
        - issue: validation error if invalid

        Return as JSON with validation status.
        """,
    )

    print("✔️ Extracting and validating data...")
    print("📍 URL: https://example.com")
    print()

    async with AsyncWebCrawler(verbose=True) as crawler:
        result = await crawler.arun(
            url="https://example.com",
            config=CrawlerRunConfig(extraction_strategy=extraction),
        )

        print("✅ Validation complete")
        print("\n--- Validated Data ---")
        print(result.markdown)
        print("--- End ---")


async def strategy_6_incremental_scraping():
    """
    Strategy 6: Incremental/paginated scraping
    Handles pagination and combines results
    """
    print("\n" + "=" * 60)
    print("Strategy 6: Incremental Scraping")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=0.0,
    )

    base_url = "https://example.com/products?page="
    pages_to_scrape = 3
    all_products = []

    print(f"📚 Scraping {pages_to_scrape} pages...")
    print()

    async with AsyncWebCrawler(verbose=True) as crawler:
        for page in range(1, pages_to_scrape + 1):
            url = f"{base_url}{page}"
            print(f"Page {page}/{pages_to_scrape}: {url}")

            extraction = LLMExtractionStrategy(
                llm_config=llm_config,
                instruction="Extract all product names and prices from this page as JSON array.",
            )

            result = await crawler.arun(
                url=url, config=CrawlerRunConfig(extraction_strategy=extraction)
            )

            try:
                # Try to parse as JSON
                page_products = json.loads(result.markdown)
                all_products.extend(page_products)
            except:
                print(f"⚠️  Could not parse page {page} as JSON")

            print(f"✅ Page {page} complete")
            print()

        print(f"✅ Scraped {len(all_products)} total products")
        print("\n--- Combined Results ---")
        print(json.dumps(all_products[:10], indent=2))  # Show first 10
        print("--- End ---")


async def main():
    """
    Run custom strategy examples
    """
    print("\n" + "=" * 70)
    print("CUSTOM EXTRACTION STRATEGIES WITH GEMINI")
    print("=" * 70)
    print()
    print("Demonstration of advanced extraction patterns:")
    print("  1. Structured data extraction (Pydantic schemas)")
    print("  2. Comparative analysis (multiple sources)")
    print("  3. Multi-step extraction (refinement)")
    print("  4. Sentiment analysis (opinions and tone)")
    print("  5. Data validation (quality checks)")
    print("  6. Incremental scraping (pagination)")
    print()
    print("💡 These strategies can be combined and customized")
    print("   for your specific use cases")
    print()
    print("Running demonstrations with example.com...")
    print("(Replace URLs with real sites for actual use)")
    print()

    try:
        # Run strategy 1 as demonstration
        await strategy_1_structured_extraction()

        print("\n" + "=" * 70)
        print("✅ Demonstration complete!")
        print()
        print("To run other strategies:")
        print("  - Uncomment strategy functions in main()")
        print("  - Update URLs with real sites")
        print("  - Customize extraction instructions")
        print()
        print("Best practices:")
        print("  - Use temperature=0.0 for structured data")
        print("  - Use temperature=0.3-0.7 for creative analysis")
        print("  - Validate extracted data before using")
        print("  - Handle pagination carefully (rate limits)")
        print("  - Save intermediate results for long processes")

    except Exception as e:
        print(f"❌ Error: {e}")
        print()
        print("This is expected with example.com.")
        print("Update examples with real URLs for actual extraction.")


if __name__ == "__main__":
    asyncio.run(main())
