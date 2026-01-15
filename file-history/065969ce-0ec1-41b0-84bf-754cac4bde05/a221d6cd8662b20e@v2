---
description: AI-powered web crawler with authentication support
allowed-tools: ["Bash", "Write", "Read"]
---

# Crawl - AI Web Scraping with Authentication

Intelligent web scraping using Crawl4AI with LLM-powered content extraction and authentication support.

## What This Command Does

The `/crawl` command:
- Scrapes websites with natural language instructions
- Logs into accounts (form-based, OAuth, token-based)
- Extracts specific information using AI
- Outputs clean markdown files
- Handles JavaScript-heavy sites with stealth mode

## Usage Pattern

```
/crawl <url> [options]
Extract: <natural language description of what to extract>
Auth: <optional authentication details>
Model: <gemini model: flash/pro/thinking> (default: flash)
Features: <url_context, grounding> (optional Gemini features)
```

## New Features (Gemini API)

**🆕 Now using Google Gemini API** (cheaper and faster than OpenAI)

- **URL Context**: Read and understand linked web pages in real-time
- **Google Search Grounding**: Up-to-date information with fact-checking
- **Multiple Models**: Flash (fast/cheap), Pro (complex reasoning), Thinking (step-by-step)

## Instructions

Parse the user's request to extract:
1. **URL**: The website to scrape
2. **Extract instruction**: Natural language description (e.g., "all pricing info", "product features", "customer testimonials")
3. **Authentication** (optional): Login credentials, cookies, or API tokens
4. **Output filename** (optional): Where to save the markdown (default: `scraped_content.md`)

### Step 1: Analyze the Request

Determine what the user wants:
- Simple scraping (no login needed)
- Authenticated scraping (needs login)
- Multi-page crawling (follow links)
- API scraping (needs headers/tokens)

### Step 2: Create Python Script

Generate a Python script in `~/Desktop/Tools/crawl4ai-scripts/` based on the scenario:

#### Scenario A: Simple Scraping with Gemini (No Auth)

```python
import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

GEMINI_API_KEY = "AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"

async def crawl_simple():
    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",  # Fast & cheap Gemini model
        api_token=GEMINI_API_KEY,
        temperature=1.0,  # 0.0 = deterministic, 1.0 = natural
        extra_args={
            "enableUrlContext": False,    # Enable to read linked pages
            "enableGrounding": False,      # Enable for Google Search fact-checking
        }
    )

    extraction_strategy = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="EXTRACTION_INSTRUCTION"
    )

    async with AsyncWebCrawler() as crawler:
        result = await crawler.arun(
            url="TARGET_URL",
            config=CrawlerRunConfig(
                extraction_strategy=extraction_strategy,
                word_count_threshold=10,
                verbose=True
            )
        )

        # Save to markdown
        with open("OUTPUT_FILE", 'w', encoding='utf-8') as f:
            f.write(f"# Scraped from TARGET_URL\n\n")
            f.write(result.markdown)

        print(f"✅ Saved to OUTPUT_FILE")
        print(f"📊 Extracted {len(result.markdown)} characters")

asyncio.run(crawl_simple())
```

#### Scenario B: Form-Based Login with Gemini

```python
import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

GEMINI_API_KEY = "AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"

async def crawl_with_login():
    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=1.0
    )

    extraction_strategy = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="EXTRACTION_INSTRUCTION"
    )

    async with AsyncWebCrawler(headless=False, verbose=True) as crawler:
        # Step 1: Navigate to login page
        login_result = await crawler.arun(
            url="LOGIN_URL",
            config=CrawlerRunConfig(
                js_code="""
                // Fill login form
                document.querySelector('input[name="username"]').value = 'USERNAME';
                document.querySelector('input[name="password"]').value = 'PASSWORD';
                document.querySelector('form').submit();
                """,
                wait_for="WAIT_SELECTOR",  # e.g., ".dashboard" or 3000 (ms)
                verbose=True
            )
        )

        # Step 2: Navigate to target page (cookies are preserved)
        result = await crawler.arun(
            url="TARGET_URL",
            config=CrawlerRunConfig(
                extraction_strategy=extraction_strategy,
                wait_for="WAIT_SELECTOR",
                verbose=True
            )
        )

        # Save to markdown
        with open("OUTPUT_FILE", 'w', encoding='utf-8') as f:
            f.write(f"# Scraped from TARGET_URL (Authenticated)\n\n")
            f.write(result.markdown)

        print(f"✅ Saved to OUTPUT_FILE")

asyncio.run(crawl_with_login())
```

#### Scenario C: Cookie/Token Authentication

```python
import asyncio
from crawl4ai import AsyncWebCrawler, CrawlerRunConfig, LLMExtractionStrategy, LLMConfig

async def crawl_with_cookies():
    llm_config = LLMConfig(
        provider="openai/gpt-4o-mini",
        api_token="YOUR_API_KEY"
    )

    extraction_strategy = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction="EXTRACTION_INSTRUCTION"
    )

    # Define cookies or headers
    cookies = [
        {"name": "session_id", "value": "SESSION_VALUE", "domain": ".example.com", "path": "/"}
    ]

    headers = {
        "Authorization": "Bearer TOKEN",
        "User-Agent": "Mozilla/5.0"
    }

    async with AsyncWebCrawler(headers=headers, verbose=True) as crawler:
        # Inject cookies before navigating
        result = await crawler.arun(
            url="TARGET_URL",
            config=CrawlerRunConfig(
                extraction_strategy=extraction_strategy,
                cookies=cookies,
                verbose=True
            )
        )

        # Save to markdown
        with open("OUTPUT_FILE", 'w', encoding='utf-8') as f:
            f.write(f"# Scraped from TARGET_URL (Token Auth)\n\n")
            f.write(result.markdown)

        print(f"✅ Saved to OUTPUT_FILE")

asyncio.run(crawl_with_cookies())
```

### Step 3: Execute the Script

Run the generated Python script:

```bash
cd ~/Desktop/Tools/crawl4ai-scripts
python3 crawl_[timestamp].py
```

### Step 4: Report Results

Tell the user:
- ✅ Scraping completed
- 📁 Output file location
- 📊 Content statistics (characters, sections, etc.)
- ⚠️ Any errors or warnings

## Authentication Patterns

### Form Login
Ask user for:
- Login URL
- Username field selector (default: `input[name="username"]`)
- Password field selector (default: `input[name="password"]`)
- Submit button selector (default: `form` + `.submit()`)
- Wait condition after login (selector or timeout)

### Cookie/Session Auth
Ask user for:
- Cookie name and value
- Domain (e.g., `.example.com`)
- Path (default: `/`)

### API Token Auth
Ask user for:
- Header name (e.g., `Authorization`)
- Token value (e.g., `Bearer xyz123`)

### OAuth/SSO
- Use headless=False to show browser
- Let user manually log in
- Save browser state for future use

## Environment Variables

The script will use these environment variables if available:
- `OPENAI_API_KEY` - For LLM extraction
- `ANTHROPIC_API_KEY` - Alternative LLM provider
- `CRAWL_OUTPUT_DIR` - Default output directory (defaults to Desktop/Tools/crawl4ai-scripts)

## Advanced Features

### Multi-Page Crawling
For crawling multiple pages, use:
```python
max_depth=2  # Follow links 2 levels deep
link_filter=".*product.*"  # Only follow links matching pattern
```

### Custom Extraction
For structured data:
```python
instruction="""
Extract and return JSON with:
- title: Product title
- price: Product price
- features: List of features
- reviews: Customer reviews
"""
```

### Stealth Mode
Already enabled by default via `tf-playwright-stealth` package.

## Error Handling

Common issues:
- **No API key**: Set OPENAI_API_KEY environment variable
- **Login failed**: Check selectors match the actual form
- **Timeout**: Increase wait_for timeout or use better selector
- **Empty content**: Check if site requires JavaScript rendering

## Examples

### Example 1: Simple Product Scraping
```
/crawl https://example.com/product
Extract: product name, price, description, and customer reviews
```

### Example 2: Authenticated Dashboard
```
/crawl https://app.example.com/dashboard
Extract: all project names and their status
Auth: Login with username=user@example.com password=secret123
```

### Example 3: API Data
```
/crawl https://api.example.com/data
Extract: all user records
Auth: Token=Bearer abc123xyz
```

## Files Created

All scripts and outputs are saved to:
- Scripts: `~/Desktop/Tools/crawl4ai-scripts/crawl_[timestamp].py`
- Outputs: `~/Desktop/Tools/crawl4ai-scripts/[filename].md`
- Research docs: `~/Desktop/Tools/crawl4ai-scripts/crawl4ai_authentication_*.md`

## Security Notes

- Never commit scripts containing credentials to git
- Use environment variables for sensitive data
- Review generated scripts before running
- Cookies and sessions are temporary and not saved by default
