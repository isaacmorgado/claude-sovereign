# ZhipuAI GLM Integration Guide

Complete guide for using ZhipuAI's GLM models with Gemini Web Miner for cost-effective web scraping.

---

## 🎯 Why GLM Models?

ZhipuAI's GLM-4 series offers compelling advantages for web scraping:

### Key Benefits

| Feature | GLM-4 Series | Alternatives |
|---------|-------------|-------------|
| **Context Window** | Up to 1M tokens (GLM-4-Long) | 128K-200K typical |
| **Cost** | $3/month subscription | $20+/month |
| **Performance** | 73.8% on SWE-bench | Competitive |
| **Language Support** | Bilingual (EN/CN) | Varies |
| **Integration** | OpenAI-compatible API | Standard |

### Cost Comparison

| Provider | Monthly Subscription | Per 1M Input Tokens | Per 1M Output Tokens |
|----------|---------------------|-------------------|---------------------|
| **Z.ai GLM** | **$3** | **$0.44-0.60** | **$1.74-2.20** |
| Google Gemini | Free tier limited | ~$0.35-1.25 | ~$1.05-5.00 |
| OpenAI GPT-4 | $20+ | $2.50-10.00 | $7.50-30.00 |

**Savings**: 70-85% compared to OpenAI, 40-60% compared to Gemini Pro

---

## 📋 Prerequisites

### 1. Get Z.ai Account

1. Visit [Z.ai Platform](https://open.bigmodel.cn/)
2. Create account (supports email/phone)
3. Subscribe to coding plan ($3/month)
4. Generate API key from dashboard

### 2. Install Dependencies

```bash
# Already installed if you have Crawl4AI
pip install crawl4ai playwright zhipuai

# Or install zhipuai SDK separately
pip install zhipuai
```

### 3. Set API Key

```bash
# Add to ~/.zshrc or ~/.bashrc
export ZHIPUAI_API_KEY="your-api-key-here"

# Or create .env file
echo "ZHIPUAI_API_KEY=your-api-key-here" >> .env
```

---

## 🚀 Quick Start

### Basic Usage

```python
from gemini_config import crawl_with_glm
import asyncio

async def main():
    await crawl_with_glm(
        url="https://example.com",
        extraction_instruction="Extract main content and summarize",
        model="glm-4-long"  # Best for large pages
    )

asyncio.run(main())
```

### Command Line

```bash
# Using the example script
python3 example_glm_scraping.py

# Or via Python directly
python3 -c "
from gemini_config import crawl_with_glm
import asyncio
asyncio.run(crawl_with_glm('https://example.com', 'Extract all text', 'glm-4-flash'))
"
```

---

## 🎨 Available Models

### GLM-4-Long (Recommended for Scraping)

**Best for**: Large documentation pages, comprehensive extraction

```python
await crawl_with_glm(
    url="https://docs.example.com",
    extraction_instruction="Extract all API endpoints with parameters",
    model="glm-4-long"
)
```

**Features**:
- 📚 **1M token context** (handles massive pages)
- 💰 Competitive pricing
- 🎯 Best for comprehensive documentation scraping
- ⚡ Good balance of speed and capability

**Use cases**:
- Full documentation sites
- Long articles and research papers
- Comprehensive product catalogs
- Multi-page content aggregation

### GLM-4-Plus

**Best for**: Complex reasoning, analytical extraction

```python
await crawl_with_glm(
    url="https://example.com/article",
    extraction_instruction="""
    Analyze this article and provide:
    1. Main arguments
    2. Supporting evidence
    3. Counterarguments
    4. Conclusion assessment
    """,
    model="glm-4-plus"
)
```

**Features**:
- 🧠 **Enhanced reasoning** capabilities
- 📊 Better analytical extraction
- 🎯 Superior multi-step processing
- 200K token context

**Use cases**:
- Complex analytical tasks
- Multi-step extraction
- Sentiment analysis
- Competitive intelligence

### GLM-4-Flash

**Best for**: Fast, simple extraction

```python
await crawl_with_glm(
    url="https://example.com/product",
    extraction_instruction="Extract product name, price, and availability",
    model="glm-4-flash"
)
```

**Features**:
- ⚡ **Fastest** model
- 💵 **Cheapest** option
- 🎯 Good for simple tasks
- 200K token context

**Use cases**:
- Price monitoring
- Simple data extraction
- High-volume scraping
- Real-time updates

### GLM-4 (Standard)

**Best for**: Balanced performance

```python
await crawl_with_glm(
    url="https://example.com",
    extraction_instruction="Extract main content",
    model="glm-4"
)
```

**Features**:
- ⚖️ Balanced speed and capability
- 📊 Good general-purpose model
- 💰 Moderate pricing
- 200K token context

**Use cases**:
- General web scraping
- Mixed complexity tasks
- Daily monitoring
- Standard extraction

### GLM-4-Air / GLM-4-AirX

**Best for**: Lightweight tasks

```python
await crawl_with_glm(
    url="https://example.com",
    extraction_instruction="Extract headlines",
    model="glm-4-air"
)
```

**Features**:
- 🪶 Lightweight and efficient
- ⚡ Very fast
- 💰 Lowest cost
- 200K token context

**Use cases**:
- Simple text extraction
- Headline collection
- Basic monitoring
- Budget-conscious projects

---

## 💻 Code Examples

### Example 1: Large Page Scraping

```python
import asyncio
from gemini_config import crawl_with_glm

async def scrape_documentation():
    """Scrape comprehensive documentation with GLM-4-Long"""
    result = await crawl_with_glm(
        url="https://docs.python.org/3/library/asyncio.html",
        extraction_instruction="""
        Extract all asyncio functions and methods with:
        - Function name
        - Parameters
        - Return type
        - Brief description
        - Code examples if available

        Organize by category.
        """,
        model="glm-4-long",  # 1M context for full page
        output_file="asyncio_docs.md"
    )

    print(f"Extracted {len(result.markdown)} characters")

asyncio.run(scrape_documentation())
```

### Example 2: News Monitoring

```python
async def monitor_news():
    """Monitor news site with GLM-4-Flash for speed"""
    result = await crawl_with_glm(
        url="https://news.ycombinator.com",
        extraction_instruction="Extract top 10 stories with titles, scores, and links",
        model="glm-4-flash",  # Fast for frequent checks
        output_file="hn_top_stories.md"
    )

    return result

# Run every hour
while True:
    asyncio.run(monitor_news())
    await asyncio.sleep(3600)
```

### Example 3: Competitive Analysis

```python
async def analyze_competitors():
    """Analyze competitor websites with GLM-4-Plus"""
    competitors = [
        "https://competitor1.com",
        "https://competitor2.com",
        "https://competitor3.com"
    ]

    for url in competitors:
        await crawl_with_glm(
            url=url,
            extraction_instruction="""
            Analyze this company's offering:
            1. Main products/services
            2. Pricing strategy
            3. Key features
            4. Target market
            5. Competitive advantages
            6. Weaknesses/gaps
            """,
            model="glm-4-plus",  # Best for analysis
            output_file=f"analysis_{url.split('//')[1].split('.')[0]}.md"
        )

        await asyncio.sleep(60)  # Rate limit safety

asyncio.run(analyze_competitors())
```

### Example 4: E-commerce Scraping

```python
async def scrape_products():
    """Scrape product catalogs with GLM-4"""
    base_url = "https://shop.example.com/products?page="

    for page in range(1, 11):  # First 10 pages
        await crawl_with_glm(
            url=f"{base_url}{page}",
            extraction_instruction="""
            Extract all products:
            - Name
            - Price (USD)
            - Rating (out of 5)
            - In stock (yes/no)
            - Key features (list)

            Return as JSON array.
            """,
            model="glm-4",  # Balanced for structured data
            output_file=f"products_page_{page}.md"
        )

        await asyncio.sleep(5)  # Rate limit

asyncio.run(scrape_products())
```

---

## 🔧 Advanced Configuration

### Custom Temperature

```python
# For deterministic extraction
llm_config = LLMConfig(
    provider="zhipu/glm-4-long",
    api_token=ZHIPUAI_API_KEY,
    temperature=0.0  # Completely deterministic
)

# For creative extraction
llm_config = LLMConfig(
    provider="zhipu/glm-4-plus",
    api_token=ZHIPUAI_API_KEY,
    temperature=1.0  # More creative
)
```

### Streaming Responses

```python
from zhipuai import ZhipuAI

client = ZhipuAI(api_key=ZHIPUAI_API_KEY)

response = client.chat.completions.create(
    model="glm-4",
    messages=[{"role": "user", "content": extracted_content}],
    stream=True
)

for chunk in response:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="")
```

### Error Handling

```python
import zhipuai

async def safe_scrape():
    try:
        result = await crawl_with_glm(
            url="https://example.com",
            extraction_instruction="Extract content",
            model="glm-4-long"
        )
    except zhipuai.APIAuthenticationError:
        print("❌ Invalid API key")
    except zhipuai.APIReachLimitError:
        print("⏸️  Rate limit reached, waiting...")
        await asyncio.sleep(60)
    except zhipuai.APITimeoutError:
        print("⏱️  Request timed out")
    except Exception as e:
        print(f"❌ Error: {e}")
```

---

## 📊 Performance Tips

### 1. Choose the Right Model

```python
# Large pages (>10K words) → GLM-4-Long
if page_size > 10000:
    model = "glm-4-long"

# Complex analysis → GLM-4-Plus
elif complexity == "high":
    model = "glm-4-plus"

# Simple/fast extraction → GLM-4-Flash
elif speed_priority:
    model = "glm-4-flash"

# Default → GLM-4
else:
    model = "glm-4"
```

### 2. Optimize Instructions

```python
# ❌ Bad: Too vague
instruction = "Get all information"

# ✅ Good: Specific and structured
instruction = """
Extract:
1. Article title
2. Author name
3. Publication date
4. Main topics (list)
5. Key takeaways (3-5 bullet points)
"""
```

### 3. Batch Processing

```python
async def batch_scrape(urls: list, model="glm-4-flash"):
    """Process multiple URLs efficiently"""
    tasks = []

    for url in urls:
        task = crawl_with_glm(
            url=url,
            extraction_instruction="Extract main content",
            model=model
        )
        tasks.append(task)

        # Avoid overwhelming API
        if len(tasks) >= 5:
            await asyncio.gather(*tasks)
            tasks = []
            await asyncio.sleep(10)  # Rate limit safety

    # Process remaining
    if tasks:
        await asyncio.gather(*tasks)
```

### 4. Caching Results

```python
import hashlib
import json
from pathlib import Path

CACHE_DIR = Path("glm_cache")
CACHE_DIR.mkdir(exist_ok=True)

async def cached_scrape(url: str, instruction: str, model: str):
    """Cache scraping results to avoid re-processing"""
    cache_key = hashlib.sha256(
        f"{url}:{instruction}:{model}".encode()
    ).hexdigest()

    cache_file = CACHE_DIR / f"{cache_key}.json"

    # Check cache
    if cache_file.exists():
        print("📦 Loading from cache...")
        return json.loads(cache_file.read_text())

    # Scrape if not cached
    result = await crawl_with_glm(url, instruction, model)

    # Save to cache
    cache_file.write_text(json.dumps({
        "url": url,
        "content": result.markdown,
        "timestamp": datetime.now().isoformat()
    }))

    return result
```

---

## ⚠️ Rate Limits

### Z.ai Limits

- **Free tier**: Limited requests per day
- **Subscription ($3/month)**: Higher limits with 3× multiplier
- **Rate**: Respect API rate limits (typically 60 RPM)

### Best Practices

```python
import time

async def rate_limited_scrape(urls: list, delay=1.0):
    """Scrape with rate limiting"""
    results = []

    for i, url in enumerate(urls):
        print(f"Processing {i+1}/{len(urls)}: {url}")

        result = await crawl_with_glm(
            url=url,
            extraction_instruction="Extract content",
            model="glm-4-flash"
        )

        results.append(result)

        # Wait between requests
        if i < len(urls) - 1:
            await asyncio.sleep(delay)

    return results
```

---

## 🐛 Troubleshooting

### Issue: "ZHIPUAI_API_KEY not set"

**Solution**:
```bash
export ZHIPUAI_API_KEY="your-api-key"
# Or add to ~/.zshrc for persistence
echo 'export ZHIPUAI_API_KEY="your-api-key"' >> ~/.zshrc
source ~/.zshrc
```

### Issue: "Rate limit exceeded"

**Solution**:
```python
# Add delays between requests
await asyncio.sleep(60)  # Wait 1 minute

# Or upgrade to paid tier at Z.ai
```

### Issue: "API authentication failed"

**Solution**:
1. Verify API key is correct
2. Check Z.ai dashboard for key status
3. Ensure subscription is active
4. Regenerate API key if needed

### Issue: "Context length exceeded"

**Solution**:
```python
# Use GLM-4-Long for large pages
model = "glm-4-long"  # 1M context

# Or split into chunks
from crawl4ai import ChunkedExtractionStrategy
```

---

## 📈 Comparison with Gemini

| Feature | GLM-4-Long | Gemini 2.0 Flash | Winner |
|---------|-----------|------------------|--------|
| Context Window | 1M tokens | 128K tokens | **GLM** |
| Cost (subscription) | $3/month | Free tier limited | **GLM** |
| Speed | Medium | Fast | Gemini |
| URL Context | No | Yes | Gemini |
| Grounding | No | Yes (Google Search) | Gemini |
| Bilingual | Yes (EN/CN) | Limited | **GLM** |
| Best for | Large pages | Fast extraction | Depends |

### When to Use GLM

- ✅ Large documentation pages
- ✅ Budget-conscious projects
- ✅ Chinese language content
- ✅ Comprehensive extraction
- ✅ High-volume scraping

### When to Use Gemini

- ✅ Need URL context feature
- ✅ Need Google Search grounding
- ✅ Speed is critical
- ✅ Free tier is sufficient
- ✅ Simple extraction tasks

---

## 📚 Resources

### Official Documentation
- [Z.ai Platform](https://open.bigmodel.cn/)
- [GLM-4.7 API Guide](https://apidog.com/blog/glm-4-7-api/)
- [GitHub SDK](https://github.com/MetaGLM/zhipuai-sdk-python-v4)
- [LangChain Integration](https://docs.langchain.com/oss/python/integrations/chat/zhipuai)

### Community
- [GitHub Discussions](https://github.com/isaacmorgado/gemini-web-miner/discussions)
- [GitHub Issues](https://github.com/isaacmorgado/gemini-web-miner/issues)

### Research Papers
- [GLM-4 Technical Report](https://huggingface.co/zai-org/GLM-4.7)
- [MoE Architecture](https://arxiv.org/abs/2001.08361)

---

## 🎯 Next Steps

1. **Get API Key**: Sign up at [Z.ai](https://open.bigmodel.cn/)
2. **Run Examples**: Try `python3 example_glm_scraping.py`
3. **Test Models**: Compare GLM-4-Flash vs GLM-4-Long
4. **Monitor Costs**: Track usage in Z.ai dashboard
5. **Scale Up**: Implement batch processing and caching

---

**Last Updated**: 2026-01-12
**Version**: 1.0.0
**Tested with**: crawl4ai 0.7.8, zhipuai SDK latest

## Sources

Research for this integration came from:
- [ZhipuAI PyPI Package](https://pypi.org/project/zhipuai/)
- [LangChain ZhipuAI Docs](https://docs.langchain.com/oss/python/integrations/chat/zhipuai)
- [GLM-4.7 API Guide (2026)](https://apidog.com/blog/glm-4-7-api/)
- [AI/ML API Documentation](https://docs.aimlapi.com/api-references/text-models-llm/zhipu/glm-4.7)
- [GitHub SDK Repository](https://github.com/MetaGLM/zhipuai-sdk-python-v4)
- [Hugging Face GLM-4.7](https://huggingface.co/zai-org/GLM-4.7)
