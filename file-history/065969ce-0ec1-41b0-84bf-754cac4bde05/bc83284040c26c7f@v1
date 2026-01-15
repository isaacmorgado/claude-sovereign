# Contributing to Gemini Web Miner

Thank you for your interest in contributing to Gemini Web Miner! This guide will help you get started.

---

## 🤝 How to Contribute

There are many ways to contribute to this project:

1. **Report bugs** - Found an issue? Let us know
2. **Suggest features** - Have an idea? We'd love to hear it
3. **Improve documentation** - Help make guides clearer
4. **Submit code** - Fix bugs or add features
5. **Share examples** - Show how you're using the tool

---

## 📋 Before You Start

### Prerequisites

- Python 3.8 or higher
- Git installed locally
- GitHub account
- Gemini API key (get one at https://ai.google.dev/)

### Setup Development Environment

```bash
# 1. Fork the repository on GitHub
#    Click "Fork" button at https://github.com/isaacmorgado/gemini-web-miner

# 2. Clone your fork
git clone https://github.com/YOUR-USERNAME/gemini-web-miner.git
cd gemini-web-miner

# 3. Add upstream remote
git remote add upstream https://github.com/isaacmorgado/gemini-web-miner.git

# 4. Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 5. Install dependencies
pip install crawl4ai playwright
playwright install chromium

# 6. Create .env file (optional)
echo "GEMINI_API_KEY=your-api-key-here" > .env
```

---

## 🐛 Reporting Bugs

Found a bug? Help us fix it!

### Before Reporting

1. **Search existing issues** - Someone may have already reported it
2. **Try latest version** - Bug might be fixed in newer version
3. **Reproduce the issue** - Make sure it's consistent

### Bug Report Template

```markdown
**Description**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Run '...'
3. See error

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- OS: [e.g., macOS 13.0]
- Python version: [e.g., 3.11.5]
- crawl4ai version: [e.g., 0.7.8]
- Gemini model: [e.g., gemini-2.0-flash-exp]

**Additional Context**
- Error messages
- Screenshots
- Related code
```

**Submit at**: https://github.com/isaacmorgado/gemini-web-miner/issues/new

---

## 💡 Suggesting Features

Have an idea for improvement? We want to hear it!

### Feature Request Template

```markdown
**Problem**
What problem does this solve?

**Proposed Solution**
How would you solve it?

**Alternatives Considered**
Other solutions you thought about

**Use Case**
Real-world example of how this would be used

**Additional Context**
- Similar features in other tools
- Mockups or diagrams
- Code examples
```

**Submit at**: https://github.com/isaacmorgado/gemini-web-miner/issues/new

---

## 📝 Contributing Code

Ready to submit code? Follow these steps:

### 1. Create a Branch

```bash
# Update your fork
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### 2. Make Your Changes

**Code Style**:
- Follow PEP 8 for Python code
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small

**Best Practices**:
- Write clear commit messages
- Test your changes thoroughly
- Update documentation if needed
- Add examples for new features

### 3. Test Your Changes

```bash
# Run basic tests
python3 quick_test.py

# Test with Gemini
python3 test_gemini.py

# Test your specific changes
python3 your_new_feature.py
```

### 4. Commit Your Changes

```bash
# Stage changes
git add .

# Commit with clear message
git commit -m "Add: Brief description of what you added"
# or
git commit -m "Fix: Brief description of what you fixed"
```

**Commit Message Format**:
```
Type: Brief description (50 chars max)

More detailed explanation if needed (72 chars per line)

- Bullet points for multiple changes
- Reference issues: Fixes #123
```

**Types**:
- `Add:` New features
- `Fix:` Bug fixes
- `Update:` Changes to existing features
- `Docs:` Documentation changes
- `Test:` Test additions or changes
- `Refactor:` Code restructuring

### 5. Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name

# Then on GitHub:
# 1. Go to your fork
# 2. Click "Pull Request"
# 3. Fill out PR template
# 4. Submit!
```

### Pull Request Template

```markdown
**Description**
What does this PR do?

**Related Issue**
Fixes #123

**Changes Made**
- Added X feature
- Fixed Y bug
- Updated Z documentation

**Testing**
How was this tested?

**Screenshots** (if applicable)
[Add screenshots]

**Checklist**
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added to complex code
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests passing
```

---

## 📚 Improving Documentation

Documentation is crucial! Here's how to help:

### What to Document

1. **Usage examples** - Show how to use features
2. **Common issues** - Solutions to frequent problems
3. **Best practices** - Tips for effective use
4. **API reference** - Explain functions and parameters
5. **Tutorials** - Step-by-step guides

### Documentation Files

- `README.md` - Project overview
- `GETTING_STARTED.md` - Quick start guide
- `GEMINI_FEATURES.md` - Feature documentation
- `ROO_CODE_INTEGRATION.md` - Integration guide
- `CONTRIBUTING.md` - This file!

### Documentation Style

- Use clear, simple language
- Include code examples
- Add screenshots when helpful
- Test all code examples
- Keep it up-to-date

---

## 🎯 Good First Issues

New to contributing? Look for issues labeled:
- `good first issue` - Easy to get started
- `help wanted` - Extra attention needed
- `documentation` - Documentation improvements
- `enhancement` - New features to add

**Browse issues**: https://github.com/isaacmorgado/gemini-web-miner/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22

---

## 🏆 Contribution Ideas

Not sure what to work on? Here are some ideas:

### Code Contributions

- **New authentication methods**
  - Add support for API key auth
  - Implement SAML authentication
  - Add certificate-based auth

- **Enhanced extraction**
  - Add image extraction
  - Implement table parsing
  - Add PDF extraction support

- **Performance improvements**
  - Optimize parallel scraping
  - Implement caching
  - Add connection pooling

- **Error handling**
  - Better retry logic
  - Rate limit handling
  - Timeout management

### Documentation Contributions

- **Real-world examples**
  - E-commerce scraping
  - News aggregation
  - Price monitoring
  - Social media analysis

- **Video tutorials**
  - Getting started video
  - Feature demonstrations
  - Use case walkthroughs

- **Translations**
  - Translate documentation
  - Add language-specific examples

### Community Contributions

- **Answer questions**
  - Help in GitHub Discussions
  - Answer issues
  - Provide support

- **Write blog posts**
  - Share your use cases
  - Write tutorials
  - Create case studies

- **Spread the word**
  - Star the repository ⭐
  - Share on social media
  - Present at meetups

---

## 📖 Code Examples

### Adding a New Feature

```python
# Example: Adding a new extraction strategy

async def new_extraction_strategy(url: str, custom_param: str):
    """
    New extraction strategy with custom parameter

    Args:
        url: Website URL
        custom_param: Your custom parameter

    Returns:
        Extracted data
    """
    llm_config = LLMConfig(
        provider="gemini/gemini-2.0-flash-exp",
        api_token=GEMINI_API_KEY,
        temperature=0.0,
    )

    extraction = LLMExtractionStrategy(
        llm_config=llm_config,
        instruction=f"Extract data using {custom_param}",
    )

    async with AsyncWebCrawler(verbose=True) as crawler:
        result = await crawler.arun(
            url=url,
            config=CrawlerRunConfig(extraction_strategy=extraction)
        )

        return result.markdown

# Add tests
async def test_new_strategy():
    result = await new_extraction_strategy(
        "https://example.com",
        "test-param"
    )
    assert len(result) > 0
    print("✅ New strategy test passed")

# Add example usage
if __name__ == "__main__":
    asyncio.run(test_new_strategy())
```

### Fixing a Bug

```python
# Before (bug):
def parse_price(price_str):
    return float(price_str)  # Fails with "$19.99"

# After (fixed):
def parse_price(price_str: str) -> float:
    """
    Parse price string to float

    Args:
        price_str: Price as string (e.g., "$19.99", "19.99", "19,99")

    Returns:
        Price as float

    Raises:
        ValueError: If price cannot be parsed
    """
    # Remove currency symbols and commas
    cleaned = price_str.replace('$', '').replace(',', '').strip()

    try:
        return float(cleaned)
    except ValueError as e:
        raise ValueError(f"Cannot parse price: {price_str}") from e

# Add test
def test_parse_price():
    assert parse_price("$19.99") == 19.99
    assert parse_price("19.99") == 19.99
    assert parse_price("19,99") == 19.99
    print("✅ Parse price tests passed")
```

---

## ✅ Review Process

After submitting a PR:

1. **Automated checks** run (if configured)
2. **Maintainer review** - We'll review your code
3. **Feedback** - We may suggest changes
4. **Approval** - Once approved, we'll merge!

### What We Look For

- **Functionality** - Does it work as intended?
- **Code quality** - Is it well-written?
- **Tests** - Are there tests?
- **Documentation** - Is it documented?
- **Compatibility** - Does it break anything?

### Response Time

- We aim to respond within **7 days**
- For urgent issues, mention in the PR description
- Feel free to ping if no response after a week

---

## 🎉 Recognition

Contributors are recognized in:
- **README.md** - Contributors section
- **CHANGELOG.md** - Version history
- **GitHub** - Contributor graph

Thank you for making Gemini Web Miner better! 🚀

---

## 📞 Questions?

- **GitHub Issues**: https://github.com/isaacmorgado/gemini-web-miner/issues
- **GitHub Discussions**: https://github.com/isaacmorgado/gemini-web-miner/discussions

---

**Last Updated**: 2026-01-12
**Version**: 1.0.0
