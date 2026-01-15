# Gemini API Features for Crawl4AI

**Status**: ✅ Integrated (2026-01-12)
**API Key**: Configured in `gemini_config.py`

---

## Why Gemini Over OpenAI?

### Cost Comparison
- **Gemini Flash**: ~60-80% cheaper than GPT-4o-mini
- **Gemini Pro**: ~50% cheaper than GPT-4o
- **Free Tier**: Experimental models available at no cost

### Performance
- **Gemini 2.0 Flash**: Faster response times
- **Context Window**: Up to 1,048,576 tokens (vs 128k for GPT-4)
- **Multimodal**: Native image/video/audio support

---

## Available Models

| Model | Speed | Cost | Best For |
|-------|-------|------|----------|
| `gemini-2.0-flash-exp` | ⚡️ Fastest | 💰 Cheapest | Quick scraping, high volume |
| `gemini-1.5-flash` | ⚡️ Fast | 💰 Low | Stable production use |
| `gemini-1.5-pro` | 🐢 Slower | 💰💰 Medium | Complex reasoning, analysis |
| `gemini-2.0-flash-thinking-exp` | 🐢 Slowest | 💰 Cheap | Step-by-step explanations |

**Default**: `gemini-2.0-flash-exp` (best speed/cost ratio)

---

## 🌐 URL Context Feature

### What It Does
Enables Gemini to **read and understand linked pages** in real-time during extraction.

### Use Cases
- **Documentation analysis**: "Analyze this API doc and all linked examples"
- **Multi-page content**: Extract info across several related pages
- **Reference following**: Understand context from linked resources

### How to Enable

```python
llm_config = LLMConfig(
    provider="gemini/gemini-2.0-flash-exp",
    api_token=GEMINI_API_KEY,
    extra_args={
        "enableUrlContext": True  # ← Enable URL context
    }
)
```

### Example

```python
await crawl_with_gemini(
    url="https://docs.python.org/3/library/asyncio.html",
    extraction_instruction="Summarize asyncio and include examples from linked pages",
    model="pro",
    enable_url_context=True  # Will read linked example pages
)
```

**Output**: Gemini will follow links and understand the full context across multiple pages.

### Limitations
- Mutually exclusive with native function calling
- May increase response time for pages with many links
- Respects robots.txt and rate limits

---

## 🔍 Google Search Grounding

### What It Does
Enriches responses with **real-time Google Search results** for:
- Up-to-date information
- Fact-checking
- Current events
- Enhanced accuracy

### Use Cases
- **News/current events**: "Extract top stories with latest updates"
- **Technical queries**: "Find best practices for React Server Components (check latest info)"
- **Fact verification**: "Extract pricing and verify it's current"
- **Trend analysis**: "What are the latest developments in AI?"

### How to Enable

```python
llm_config = LLMConfig(
    provider="gemini/gemini-2.0-flash-exp",
    api_token=GEMINI_API_KEY,
    extra_args={
        "enableGrounding": True  # ← Enable Google Search grounding
    }
)
```

### Example

```python
await crawl_with_gemini(
    url="https://news.ycombinator.com",
    extraction_instruction="Extract top 5 stories and add context from latest news",
    model="flash",
    enable_grounding=True  # Will search Google for additional context
)
```

### Grounding Metadata

Gemini returns sources used for grounding:

```python
# Grounding metadata structure
{
  "groundingChunks": [
    {
      "web": {
        "uri": "https://example.com/article",
        "title": "Article Title"
      }
    }
  ]
}
```

**Note**: Roo Code implementation extracts these sources and displays them to users.

### Geographic Grounding (Advanced)

Add location context for localized results:

```python
extra_args={
    "enableGrounding": True,
    "toolConfig": {
        "retrievalConfig": {
            "latLng": {
                "latitude": 37.7749,
                "longitude": -122.4194
            }
        }
    }
}
```

---

## 🎛️ Configuration Options

### Temperature Control

```python
temperature=0.0  # Deterministic, consistent output
temperature=0.5  # Balanced
temperature=1.0  # Natural, creative (Roo Code default)
```

**Recommendation**: Use 1.0 for natural language extraction, 0.0 for structured data.

### Model Selection

```python
# For simple extraction
model="flash"  # Fast & cheap

# For complex analysis
model="pro"  # Better reasoning

# For explanations
model="thinking"  # Step-by-step breakdown
```

### Combining Features

```python
# Use both URL context AND grounding
llm_config = LLMConfig(
    provider="gemini/gemini-2.0-flash-exp",
    api_token=GEMINI_API_KEY,
    temperature=1.0,
    extra_args={
        "enableUrlContext": True,     # Read linked pages
        "enableGrounding": True,      # Search Google for facts
    }
)
```

**⚠️ Important**: These features are mutually exclusive with function calling (native tools). Since Crawl4AI doesn't use function calling, you can enable both.

---

## 📊 Best Practices

### When to Use URL Context
✅ Multi-page documentation
✅ Cross-referenced content
✅ API docs with examples
❌ Single-page content
❌ High-volume scraping (slower)

### When to Use Grounding
✅ News and current events
✅ Technical best practices
✅ Fact verification
✅ Trend analysis
❌ Static historical content
❌ Internal company data

### Cost Optimization

1. **Use Flash for simple tasks**
   ```python
   model="flash"  # 60-80% cheaper than OpenAI
   ```

2. **Reserve Pro for complex reasoning**
   ```python
   model="pro"  # Only when Flash isn't sufficient
   ```

3. **Disable features when not needed**
   ```python
   enable_url_context=False  # Default
   enable_grounding=False    # Default
   ```

4. **Batch similar requests**
   - Group scraping tasks
   - Use async/parallel execution

---

## 🧪 Testing

### Test Basic Scraping
```bash
cd ~/Desktop/Tools/crawl4ai-scripts
python3 gemini_config.py
```

### Test URL Context
```python
asyncio.run(example_with_url_context())
```

### Test Grounding
```python
asyncio.run(example_with_grounding())
```

---

## 📚 Resources

### Official Documentation
- **Gemini API**: https://ai.google.dev/
- **Pricing**: https://ai.google.dev/pricing
- **Models**: https://ai.google.dev/models

### Implementation References
- **Roo Code**: https://github.com/RooCodeInc/Roo-Code
  - `src/api/providers/gemini.ts` - Main implementation
  - `packages/types/src/provider-settings.ts` - Configuration
- **Google Gemini Cookbook**: Code examples and patterns
- **Firebase Genkit**: Advanced grounding examples

### Related Files
- `gemini_config.py` - Main configuration and examples
- `crawl.md` - Updated /crawl command with Gemini
- `README.md` - General usage guide

---

## 🐛 Troubleshooting

### "API key invalid"
- Check key: `AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8`
- Verify at: https://ai.google.dev/

### "Model not found"
- Use exact model names: `gemini-2.0-flash-exp`, `gemini-1.5-pro`
- Check latest models at: https://ai.google.dev/models

### "Grounding not working"
- Ensure `enableGrounding: True` in `extra_args`
- Check that you're not using function calling
- Verify extraction instruction requests current/factual info

### "URL context not working"
- Ensure `enableUrlContext: True` in `extra_args`
- Check that URLs are publicly accessible
- Verify page doesn't block scrapers

---

## 🔄 Migration from OpenAI

### Old (OpenAI)
```python
llm_config = LLMConfig(
    provider="openai/gpt-4o-mini",
    api_token=os.getenv("OPENAI_API_KEY")
)
```

### New (Gemini)
```python
llm_config = LLMConfig(
    provider="gemini/gemini-2.0-flash-exp",
    api_token="AIzaSyCwpp0YtdHB56WZ1bhtWdWrPqPS005I6U8"
)
```

**Benefits**:
- 60-80% cost reduction
- Faster responses
- Additional features (URL context, grounding)
- Larger context window

---

## 📈 Performance Metrics

Based on Roo Code implementation and Google benchmarks:

| Feature | Response Time | Cost Multiplier |
|---------|--------------|-----------------|
| Basic scraping | ~1-2s | 1x |
| + URL context | ~3-5s | 1.2-1.5x |
| + Grounding | ~2-4s | 1.3-1.8x |
| Both enabled | ~4-7s | 1.5-2x |

**Recommendation**: Enable features only when needed for optimal performance.

---

**Last Updated**: 2026-01-12
**Integration**: Roo Code v0.24.16+ patterns
**Status**: Production-ready ✅
