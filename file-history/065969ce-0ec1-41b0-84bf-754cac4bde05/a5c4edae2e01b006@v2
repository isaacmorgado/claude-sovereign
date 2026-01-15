#!/usr/bin/env python3
"""
Automated Monitoring Workflow with Gemini
Demonstrates continuous website monitoring, change detection, and alerting
"""

import asyncio
import json
import hashlib
from datetime import datetime
from pathlib import Path
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

GEMINI_API_KEY = "AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"

# Storage for monitoring state
MONITORING_DIR = Path("monitoring_data")
MONITORING_DIR.mkdir(exist_ok=True)


def get_content_hash(content: str) -> str:
    """Generate hash of content for change detection"""
    return hashlib.sha256(content.encode()).hexdigest()


def save_monitoring_state(url: str, content: str, extracted: str):
    """Save monitoring state to disk"""
    timestamp = datetime.now().isoformat()
    content_hash = get_content_hash(content)

    state = {
        "url": url,
        "timestamp": timestamp,
        "content_hash": content_hash,
        "content_length": len(content),
        "extracted_data": extracted,
    }

    # Save to file named by URL hash
    url_hash = hashlib.sha256(url.encode()).hexdigest()[:16]
    state_file = MONITORING_DIR / f"{url_hash}_latest.json"

    with open(state_file, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2)

    # Also save to history
    history_file = MONITORING_DIR / f"{url_hash}_history.jsonl"
    with open(history_file, "a", encoding="utf-8") as f:
        f.write(json.dumps(state) + "\n")

    return state, state_file


def load_monitoring_state(url: str):
    """Load previous monitoring state"""
    url_hash = hashlib.sha256(url.encode()).hexdigest()[:16]
    state_file = MONITORING_DIR / f"{url_hash}_latest.json"

    if state_file.exists():
        with open(state_file, "r", encoding="utf-8") as f:
            return json.load(f)
    return None


async def monitor_website(
    url: str, extraction_instruction: str, check_interval: int = 300
):
    """
    Monitor a website for changes

    Args:
        url: Website to monitor
        extraction_instruction: What to extract with Gemini
        check_interval: Seconds between checks (default 5 minutes)
    """
    print("=" * 60)
    print(f"MONITORING: {url}")
    print("=" * 60)
    print(f"Extraction: {extraction_instruction}")
    print(f"Check interval: {check_interval} seconds")
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=0.0,  # Deterministic for consistent comparisons
    )

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction=extraction_instruction,
    )

    async with AsyncWebCrawler(verbose=True) as crawler:
        while True:
            try:
                print(
                    f"\n[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Checking {url}..."
                )

                result = await crawler.arun(
                    url=url,
                    config=CrawlerRunConfig(
                        extraction_strategy=extraction,
                        wait_for="networkidle",
                    ),
                )

                # Check for changes
                previous_state = load_monitoring_state(url)
                current_hash = get_content_hash(result.markdown)

                if previous_state:
                    if previous_state["content_hash"] != current_hash:
                        print("🔔 CHANGE DETECTED!")
                        print(
                            f"   Previous hash: {previous_state['content_hash'][:16]}..."
                        )
                        print(f"   Current hash: {current_hash[:16]}...")
                        print(
                            f"   Length change: {previous_state['content_length']} → {len(result.markdown)}"
                        )
                        print()
                        print("--- New Content ---")
                        print(result.markdown[:500])
                        print("--- End ---")
                    else:
                        print("✅ No changes detected")
                else:
                    print("📝 First check - baseline saved")

                # Save state
                state, state_file = save_monitoring_state(
                    url, result.markdown, result.markdown
                )
                print(f"💾 State saved to: {state_file}")

                # Wait before next check
                print(f"⏰ Next check in {check_interval} seconds...")
                await asyncio.sleep(check_interval)

            except KeyboardInterrupt:
                print("\n⏹️  Monitoring stopped by user")
                break
            except Exception as e:
                print(f"❌ Error: {e}")
                print(f"⏰ Retrying in {check_interval} seconds...")
                await asyncio.sleep(check_interval)


async def monitor_multiple_sites(sites: list, check_interval: int = 300):
    """
    Monitor multiple websites in parallel

    Args:
        sites: List of dicts with 'url' and 'instruction' keys
        check_interval: Seconds between checks
    """
    print("=" * 60)
    print(f"MONITORING {len(sites)} SITES")
    print("=" * 60)
    print()

    for i, site in enumerate(sites, 1):
        print(f"{i}. {site['url']}")
        print(f"   Extract: {site['instruction']}")
    print()

    # Create monitoring tasks for each site
    tasks = [
        monitor_website(site["url"], site["instruction"], check_interval)
        for site in sites
    ]

    # Run all monitors in parallel
    await asyncio.gather(*tasks)


async def example_price_monitor():
    """Example: Monitor product prices"""
    print("\n" + "=" * 60)
    print("Example: Product Price Monitoring")
    print("=" * 60)
    print()

    sites = [
        {
            "url": "https://example.com/product1",
            "instruction": "Extract product name, current price, and availability status",
        },
        {
            "url": "https://example.com/product2",
            "instruction": "Extract product name, current price, and availability status",
        },
    ]

    # Monitor every 5 minutes (300 seconds)
    await monitor_multiple_sites(sites, check_interval=300)


async def example_news_monitor():
    """Example: Monitor news headlines"""
    print("\n" + "=" * 60)
    print("Example: News Headlines Monitoring")
    print("=" * 60)
    print()

    sites = [
        {
            "url": "https://news.ycombinator.com",
            "instruction": "Extract the top 10 story titles and their scores",
        },
        {
            "url": "https://example.com/news",
            "instruction": "Extract breaking news headlines and timestamps",
        },
    ]

    # Monitor every 10 minutes (600 seconds)
    await monitor_multiple_sites(sites, check_interval=600)


async def example_competitor_monitor():
    """Example: Monitor competitor websites"""
    print("\n" + "=" * 60)
    print("Example: Competitor Monitoring")
    print("=" * 60)
    print()

    sites = [
        {
            "url": "https://competitor1.com/pricing",
            "instruction": "Extract all pricing tiers, features, and any promotional offers",
        },
        {
            "url": "https://competitor2.com/features",
            "instruction": "Extract all listed features and their descriptions",
        },
        {
            "url": "https://competitor3.com/blog",
            "instruction": "Extract the 5 most recent blog post titles and publication dates",
        },
    ]

    # Monitor every 4 hours (14400 seconds)
    await monitor_multiple_sites(sites, check_interval=14400)


async def example_single_page_monitor():
    """Example: Monitor a single page with detailed tracking"""
    print("\n" + "=" * 60)
    print("Example: Single Page Detailed Monitoring")
    print("=" * 60)
    print()

    # Monitor Hacker News front page every 60 seconds for demo
    await monitor_website(
        url="https://news.ycombinator.com",
        extraction_instruction="Extract top 5 story titles with their scores",
        check_interval=60,  # Check every minute
    )


async def main():
    """
    Run monitoring workflow examples
    """
    print("\n" + "=" * 70)
    print("AUTOMATED MONITORING WORKFLOW WITH GEMINI")
    print("=" * 70)
    print()
    print("This script demonstrates automated website monitoring:")
    print("  - Continuous scraping at set intervals")
    print("  - Change detection with content hashing")
    print("  - Parallel monitoring of multiple sites")
    print("  - Persistent state storage")
    print("  - Historical tracking")
    print()
    print("Available examples:")
    print("  1. Single page monitor (detailed tracking)")
    print("  2. Price monitoring (multiple products)")
    print("  3. News monitoring (multiple sources)")
    print("  4. Competitor monitoring (pricing, features, content)")
    print()
    print("Running Example 1: Single Page Monitor")
    print("Monitoring Hacker News every 60 seconds (Ctrl+C to stop)")
    print()

    try:
        # Run single page monitor
        await example_single_page_monitor()

    except KeyboardInterrupt:
        print("\n✅ Monitoring stopped")
        print()
        print(f"📁 Monitoring data saved in: {MONITORING_DIR}")
        print("   View *_latest.json for current state")
        print("   View *_history.jsonl for complete history")
        print()
        print("To run other examples:")
        print("  - Uncomment example functions in main()")
        print("  - Update URLs with real sites to monitor")
        print("  - Adjust check_interval based on your needs")
        print()
        print("💡 Tips:")
        print("  - Use longer intervals (300-3600s) for production")
        print("  - Set temperature=0.0 for consistent extractions")
        print("  - Monitor rate limits (wait 60s between requests)")
        print("  - Set up alerts based on change detection")


if __name__ == "__main__":
    asyncio.run(main())
