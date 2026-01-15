#!/usr/bin/env python3
"""
Authenticated scraping examples with Gemini API
Demonstrates various authentication methods with crawl4ai
"""

import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig
from crawl4ai.async_configs import BrowserConfig, CrawlerRunConfig

GEMINI_API_KEY = "AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"


async def example_1_form_login():
    """
    Example 1: Form-based login authentication
    Demonstrates logging into a website with username/password
    """
    print("\n" + "=" * 60)
    print("Example 1: Form-Based Login Authentication")
    print("=" * 60)
    print()

    # Configure Gemini
    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=1.0,
    )

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="Extract user profile information including name, email, and account details",
    )

    # Browser config
    browser_config = BrowserConfig(
        headless=True,
        viewport_width=1920,
        viewport_height=1080,
    )

    print("🔐 Logging into account...")
    print("📍 Login URL: https://example.com/login")
    print("📍 Target URL: https://example.com/dashboard")
    print()

    async with AsyncWebCrawler(config=browser_config, verbose=True) as crawler:
        # Step 1: Navigate to login page
        print("Step 1: Navigating to login page...")
        login_result = await crawler.arun(
            url="https://example.com/login",
            config=CrawlerRunConfig(
                js_code=[
                    # Fill username field
                    "document.querySelector('input[name=\"username\"]').value = 'user@example.com';",
                    # Fill password field
                    "document.querySelector('input[name=\"password\"]').value = 'secure-password';",
                    # Submit form
                    "document.querySelector('form').submit();",
                ],
                wait_for="networkidle",  # Wait for navigation to complete
            ),
        )

        print("✅ Login completed")
        print()

        # Step 2: Navigate to protected page and extract data
        print("Step 2: Accessing protected dashboard...")
        dashboard_result = await crawler.arun(
            url="https://example.com/dashboard",
            config=CrawlerRunConfig(
                extraction_strategy=extraction,
                wait_for="networkidle",
            ),
        )

        print("✅ Dashboard data extracted")
        print(f"📊 Content length: {len(dashboard_result.markdown)} characters")
        print()
        print("--- Extracted Dashboard Content ---")
        print(dashboard_result.markdown[:500])  # Show first 500 chars
        print("--- End ---")


async def example_2_cookie_authentication():
    """
    Example 2: Cookie-based authentication
    Demonstrates using existing cookies to access protected content
    """
    print("\n" + "=" * 60)
    print("Example 2: Cookie-Based Authentication")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=1.0,
    )

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="Extract all available user data and preferences",
    )

    # Browser config with pre-set cookies
    browser_config = BrowserConfig(
        headless=True,
        cookies=[
            {
                "name": "session_token",
                "value": "your-session-token-here",
                "domain": ".example.com",
                "path": "/",
                "secure": True,
                "httpOnly": True,
            },
            {
                "name": "user_id",
                "value": "12345",
                "domain": ".example.com",
                "path": "/",
            },
        ],
    )

    print("🍪 Using cookie authentication...")
    print("📍 URL: https://example.com/account")
    print()

    async with AsyncWebCrawler(config=browser_config, verbose=True) as crawler:
        result = await crawler.arun(
            url="https://example.com/account",
            config=CrawlerRunConfig(
                extraction_strategy=extraction,
                wait_for="networkidle",
            ),
        )

        print("✅ Data extracted with cookie auth")
        print(f"📊 Content length: {len(result.markdown)} characters")
        print()
        print("--- Extracted Account Content ---")
        print(result.markdown[:500])
        print("--- End ---")


async def example_3_bearer_token_authentication():
    """
    Example 3: Bearer token authentication (API-style)
    Demonstrates using authorization headers for API endpoints
    """
    print("\n" + "=" * 60)
    print("Example 3: Bearer Token Authentication")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=1.0,
    )

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="Extract API response data and format it as a structured summary",
    )

    # Browser config with custom headers
    # Note: Headers should be set via CrawlerRunConfig headers parameter
    browser_config = BrowserConfig(
        headless=True,
    )

    print("🔑 Using Bearer token authentication...")
    print("📍 URL: https://api.example.com/user/profile")
    print()

    async with AsyncWebCrawler(config=browser_config, verbose=True) as crawler:
        result = await crawler.arun(
            url="https://api.example.com/user/profile",
            config=CrawlerRunConfig(
                extraction_strategy=extraction,
                wait_for="networkidle",
                headers={
                    "Authorization": "Bearer your-api-token-here",
                    "X-API-Key": "your-api-key-here",
                },
            ),
        )

        print("✅ API data extracted")
        print(f"📊 Content length: {len(result.markdown)} characters")
        print()
        print("--- Extracted API Data ---")
        print(result.markdown[:500])
        print("--- End ---")


async def example_4_oauth_flow():
    """
    Example 4: OAuth/SSO authentication flow
    Demonstrates handling OAuth redirects and token exchange
    """
    print("\n" + "=" * 60)
    print("Example 4: OAuth/SSO Authentication")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=1.0,
    )

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="Extract user profile and connected services information",
    )

    browser_config = BrowserConfig(
        headless=True,
        viewport_width=1920,
        viewport_height=1080,
    )

    print("🔗 Handling OAuth flow...")
    print("📍 Start URL: https://example.com/login")
    print("📍 OAuth Provider: Google/GitHub/etc.")
    print()

    async with AsyncWebCrawler(config=browser_config, verbose=True) as crawler:
        # Step 1: Click "Login with Google" button
        print("Step 1: Initiating OAuth flow...")
        oauth_start = await crawler.arun(
            url="https://example.com/login",
            config=CrawlerRunConfig(
                js_code=[
                    # Click OAuth button
                    "document.querySelector('button[data-oauth=\"google\"]').click();",
                ],
                wait_for="networkidle",
            ),
        )

        print("Step 2: OAuth redirect (would handle authorization here)...")
        print("Note: In real scenario, handle OAuth provider login here")
        print()

        # Step 3: After OAuth callback, access protected resource
        print("Step 3: Accessing protected resource after OAuth...")
        result = await crawler.arun(
            url="https://example.com/profile",
            config=CrawlerRunConfig(
                extraction_strategy=extraction,
                wait_for="networkidle",
            ),
        )

        print("✅ Profile data extracted after OAuth")
        print(f"📊 Content length: {len(result.markdown)} characters")


async def example_5_session_persistence():
    """
    Example 5: Session persistence across multiple pages
    Demonstrates maintaining login state while crawling multiple pages
    """
    print("\n" + "=" * 60)
    print("Example 5: Session Persistence Across Pages")
    print("=" * 60)
    print()

    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=1.0,
    )

    browser_config = BrowserConfig(
        headless=True,
        stealth_mode=True,
    )

    urls_to_scrape = [
        "https://example.com/dashboard",
        "https://example.com/settings",
        "https://example.com/billing",
        "https://example.com/reports",
    ]

    print("🔄 Maintaining session across multiple pages...")
    print(f"📍 Pages to scrape: {len(urls_to_scrape)}")
    print()

    async with AsyncWebCrawler(config=browser_config, verbose=True) as crawler:
        # Login once
        print("Logging in...")
        await crawler.arun(
            url="https://example.com/login",
            config=CrawlerRunConfig(
                js_code=[
                    "document.querySelector('input[name=\"username\"]').value = 'user@example.com';",
                    "document.querySelector('input[name=\"password\"]').value = 'password';",
                    "document.querySelector('form').submit();",
                ],
                wait_for="networkidle",
            ),
        )

        print("✅ Logged in")
        print()

        # Scrape all pages with same session
        for i, url in enumerate(urls_to_scrape, 1):
            print(f"Scraping page {i}/{len(urls_to_scrape)}: {url}")

            extraction = LLMExtractionStrategy(
                llm_config=llm_config,
                instruction="Extract key information from this page",
            )

            result = await crawler.arun(
                url=url,
                config=CrawlerRunConfig(
                    extraction_strategy=extraction,
                    wait_for="networkidle",
                ),
            )

            print(f"✅ Extracted {len(result.markdown)} characters")
            print()

            # Save each page result
            filename = url.split("/")[-1] + "_output.md"
            with open(filename, "w", encoding="utf-8") as f:
                f.write(f"# {url}\n\n")
                f.write(result.markdown)
            print(f"💾 Saved to: {filename}")
            print()

        print("✅ All pages scraped with persistent session")


async def main():
    """
    Run all authentication examples
    NOTE: These are demonstration examples using example.com
    Replace URLs, credentials, and selectors with real values for actual use
    """
    print("\n" + "=" * 70)
    print("AUTHENTICATED SCRAPING EXAMPLES WITH GEMINI")
    print("=" * 70)
    print()
    print("⚠️  IMPORTANT: These are demonstration examples")
    print("   Replace example.com URLs with real sites you have permission to access")
    print("   Update credentials, tokens, and CSS selectors for your target sites")
    print()
    print("Available examples:")
    print("  1. Form-based login (username/password)")
    print("  2. Cookie-based authentication")
    print("  3. Bearer token authentication (API)")
    print("  4. OAuth/SSO flow")
    print("  5. Session persistence across pages")
    print()

    # Run example 1 only by default (others would fail with example.com)
    try:
        print("Running Example 1 (others require real credentials)...")
        print()
        await example_1_form_login()
        print()
        print("🎉 Example complete!")
        print()
        print("To run other examples:")
        print("  - Update URLs, credentials, and selectors in this file")
        print("  - Uncomment the example functions in main()")
        print("  - Ensure you have permission to scrape the target sites")
        print()

    except Exception as e:
        print(f"⚠️  Example encountered an error (expected with example.com): {e}")
        print()
        print("This is normal - example.com doesn't have login functionality.")
        print("Update the examples with real sites you have permission to access.")


if __name__ == "__main__":
    asyncio.run(main())
