# Crawl4AI Web Scraping Toolkit

AI-powered web scraper with authentication support, built on Crawl4AI.

## Quick Start

### Prerequisites

✅ Already installed:
- Python 3.x
- crawl4ai (v0.7.8)
- playwright with chromium
- All dependencies

### Environment Setup

Set your OpenAI API key (required for LLM extraction):

```bash
export OPENAI_API_KEY="your-api-key-here"
```

Or create a `.env` file in this directory:
```
OPENAI_API_KEY=your-api-key-here
```

## Using the /crawl Command

From anywhere in Claude Code, run:

```
/crawl <url>
Extract: <what you want to extract>
Auth: <optional login details>
```

### Examples

#### 1. Simple Scraping (No Login)
```
/crawl https://example.com/products
Extract: all product names, prices, and descriptions
```

#### 2. Form-Based Login
```
/crawl https://app.example.com/dashboard
Extract: list of all projects and their status
Auth: Login form at https://app.example.com/login with username=user@example.com password=mypass123
```

#### 3. Cookie Authentication
```
/crawl https://members.example.com/content
Extract: all premium articles
Auth: Cookie session_id=abc123xyz domain=.example.com
```

#### 4. API Token
```
/crawl https://api.example.com/users
Extract: user list with emails and join dates
Auth: Header Authorization=Bearer token123
```

## Manual Usage

You can also run Python scripts directly:

```bash
cd ~/Desktop/Tools/crawl4ai-scripts
python3 simple_scrape.py
```

### Example: Simple Scrape Script

```python
import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

async def scrape():
    llm_config = LLMConfig(provider="openai/gpt-4o-mini")

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="Extract all product names and prices"
    )

    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(
            url="https://example.com",
            config=CrawlerRunConfig(extraction_strategy=extraction)
        )

        print(result.markdown)

asyncio.run(scrape())
```

## Authentication Methods Supported

### ✅ Form-Based Login
- Automates username/password forms
- Handles multi-step login flows
- Session persistence

### ✅ Cookie Authentication
- Inject cookies before navigation
- Domain and path configuration
- Session management

### ✅ Token/API Key Authentication
- Custom headers (Authorization, API-Key, etc.)
- Bearer tokens
- Basic auth

### ✅ OAuth/SSO
- Manual login with visible browser
- Browser state persistence
- Profile saving for reuse

### ✅ 2FA/MFA
- Manual intervention support
- Wait for user to complete 2FA
- Session continuation

## Documentation

This folder contains comprehensive research and examples:

1. **README_CRAWL4AI_AUTH_RESEARCH.md** - Master index
2. **CRAWL4AI_AUTH_SUMMARY.txt** - Quick 5-minute overview
3. **crawl4ai_authentication_research.md** - Complete technical reference (20 min read)
4. **crawl4ai_authentication_quick_reference.md** - Practical scenarios guide
5. **crawl4ai_authentication_examples.py** - 15 production-ready code examples

## Output Files

All scraped content is saved as markdown in this directory:
- `scraped_[website]_[timestamp].md`
- Custom filenames as specified
- Clean, readable markdown format

## Advanced Features

### Multi-Page Crawling
```python
config = CrawlerRunConfig(
    max_depth=3,  # Follow links 3 levels deep
    link_filter=".*article.*",  # Only follow article links
    extraction_strategy=extraction
)
```

### JavaScript Execution
```python
config = CrawlerRunConfig(
    js_code="""
    // Click "Load More" button
    document.querySelector('.load-more').click();
    """,
    wait_for=2000  # Wait 2 seconds after execution
)
```

### Custom Selectors
```python
config = CrawlerRunConfig(
    css_selector=".content-area",  # Only scrape specific section
    extraction_strategy=extraction
)
```

### Stealth Mode
Already enabled by default - bypasses most bot detection.

## Troubleshooting

### "No API key found"
Set OPENAI_API_KEY environment variable:
```bash
export OPENAI_API_KEY="sk-..."
```

### "Element not found"
Check the CSS selectors match the actual page structure. Use browser DevTools to inspect elements.

### "Timeout waiting for selector"
Increase timeout or use a better selector:
```python
wait_for=5000  # Wait 5 seconds
```

### "Login failed"
- Verify credentials are correct
- Check if site has CAPTCHA (requires manual intervention)
- Use headless=False to see what's happening

### "Empty or incomplete content"
- Site may block scrapers (stealth should help)
- Try headless=False
- Check if content loads via AJAX (increase wait time)

## Performance Tips

1. **Use CSS selectors** to narrow down scraping area
2. **Set word_count_threshold** to filter out noise
3. **Use caching** for repeated requests
4. **Parallelize** multiple URLs with asyncio.gather()
5. **Limit depth** for multi-page crawls

## Security Best Practices

- ⚠️ Never commit scripts with credentials
- ✅ Use environment variables for secrets
- ✅ Review generated scripts before running
- ✅ Use .gitignore for output files with sensitive data
- ✅ Rotate API keys and tokens regularly

## Examples Scripts

Check `crawl4ai_authentication_examples.py` for 15 ready-to-use examples covering:
- Simple GET requests
- Form login
- Cookie injection
- API authentication
- Multi-page crawling
- Custom JavaScript execution
- Session management
- And more!

## Need Help?

1. Check the authentication research docs in this folder
2. Review the examples in `crawl4ai_authentication_examples.py`
3. Use `/crawl` command in Claude Code for guided setup
4. Refer to official Crawl4AI docs: https://github.com/unclecode/crawl4ai

## Version Info

- **Crawl4AI**: v0.7.8
- **Playwright**: v1.57.0
- **Python**: 3.14+
- **Installation Date**: 2026-01-12

---

**Created by Claude Code's /crawl command**
