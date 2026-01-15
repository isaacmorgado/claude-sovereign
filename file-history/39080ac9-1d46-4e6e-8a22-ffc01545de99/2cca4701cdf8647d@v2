#!/usr/bin/env python3
"""
Ken Kai Course Crawler - Extracts all course content from kenkais.com
Handles PIN authentication and crawls multiple course pages.
"""

import asyncio
import sys
import json
import re
from pathlib import Path
from typing import List, Dict, Optional

try:
    from playwright.async_api import async_playwright, Page, BrowserContext
except ImportError:
    import subprocess
    subprocess.run([sys.executable, "-m", "pip", "install", "playwright"], check=True)
    subprocess.run([sys.executable, "-m", "playwright", "install", "chromium"], check=True)
    from playwright.async_api import async_playwright, Page, BrowserContext

try:
    from markdownify import markdownify as md
except ImportError:
    import subprocess
    subprocess.run([sys.executable, "-m", "pip", "install", "markdownify"], check=True)
    from markdownify import markdownify as md


# Course definitions by section
COURSES = {
    "hacker": {
        "name": "Hacker / Reverse Engineering",
        "courses": [
            {"slug": "extract-chrome-extensions", "title": "Extract Chrome Extensions"},
            {"slug": "extract-electron-apps", "title": "Extract Electron Apps"},
            {"slug": "javascript-deobfuscation", "title": "JavaScript Deobfuscation"},
            {"slug": "extract-macos-apps", "title": "Extract macOS Apps"},
            {"slug": "reverse-engineering-tools", "title": "Reverse Engineering Tools"},
            {"slug": "terminal-scripts-hacks", "title": "Terminal Scripts & Hacks"},
            {"slug": "web-scraping-data-extraction", "title": "Web Scraping & Data Extraction"},
            {"slug": "api-reverse-engineering", "title": "API Reverse Engineering"},
            {"slug": "browser-automation", "title": "Browser Automation"},
        ]
    },
    "getting-started": {
        "name": "Getting Started",
        "courses": [
            {"slug": "why-learn-this", "title": "Why Learn This"},
            {"slug": "what-you-can-build", "title": "What You Can Build"},
            {"slug": "github-repositories", "title": "GitHub & Repositories"},
            {"slug": "terminal-basics", "title": "Terminal Basics"},
            {"slug": "complete-mac-setup", "title": "Complete Mac Setup"},
            {"slug": "complete-windows-setup-wsl", "title": "Complete Windows Setup (WSL)"},
            {"slug": "iterm2-oh-my-zsh", "title": "iTerm2 + Oh My Zsh"},
            {"slug": "terminal-customization", "title": "Terminal Customization"},
        ]
    },
    "security": {
        "name": "Security",
        "courses": [
            {"slug": "security-pre-production-checklist", "title": "Security Pre-Production Checklist"},
            {"slug": "environment-variables-secrets", "title": "Environment Variables & Secrets"},
            {"slug": "api-security-basics", "title": "API Security Basics"},
            {"slug": "input-validation-sanitization", "title": "Input Validation & Sanitization"},
        ]
    },
    "backend": {
        "name": "Backend",
        "courses": [
            {"slug": "database-setup", "title": "Database Setup"},
            {"slug": "authentication-setup", "title": "Authentication Setup"},
            {"slug": "api-integrations", "title": "API Integrations"},
            {"slug": "automations", "title": "Automations"},
        ]
    },
    "boilerplates": {
        "name": "Boilerplates",
        "courses": [
            {"slug": "welcome-to-boilerplates", "title": "Welcome to Boilerplates"},
            {"slug": "kens-ios-boilerplate", "title": "Ken's iOS Boilerplate"},
            {"slug": "kens-chrome-extension-boilerplate", "title": "Ken's Chrome Extension Boilerplate"},
            {"slug": "kens-discord-boilerplate", "title": "Ken's Discord Boilerplate"},
            {"slug": "kens-links-boilerplate", "title": "Ken's Links Boilerplate"},
        ]
    },
}

AUTH_STATE_FILE = Path.home() / ".claude" / "tools" / ".kenkai-auth.json"


async def dismiss_modals(page: Page):
    """Dismiss any modal overlays."""
    try:
        for _ in range(3):
            await page.keyboard.press("Escape")
            await asyncio.sleep(0.2)

        # Try clicking close buttons
        close_selectors = [
            '[class*="close"]',
            'button[aria-label*="close"]',
            '.modal-close',
            '[data-dismiss]',
            'button:has-text("Close")',
            'button:has-text("Got it")',
            'button:has-text("Dismiss")',
        ]
        for sel in close_selectors:
            try:
                btn = await page.query_selector(sel)
                if btn:
                    await btn.click()
                    await asyncio.sleep(0.2)
            except:
                pass

        # Click outside modal
        await page.mouse.click(10, 10)
        await asyncio.sleep(0.3)
    except:
        pass


async def authenticate(page: Page, password: str) -> bool:
    """Authenticate with PIN code - uses same method as working kenkai-crawler.py"""
    content = await page.content()

    if 'Restricted Access' not in content:
        return True  # Already authenticated

    print(f"  Authenticating with code {password}...")

    # Wait for page to fully load
    await asyncio.sleep(2)

    # Dismiss any modals (like "What's New")
    print("  Dismissing modals...")
    for _ in range(3):
        await page.keyboard.press("Escape")
        await asyncio.sleep(0.3)

    # Try clicking close buttons
    close_btns = await page.query_selector_all('[class*="close"], button[aria-label*="close"], .modal-close, [data-dismiss]')
    for btn in close_btns:
        try:
            await btn.click()
            await asyncio.sleep(0.3)
        except:
            pass

    # Click outside modal
    await page.mouse.click(10, 10)
    await asyncio.sleep(0.5)

    await asyncio.sleep(1)

    # Method 1: Click input boxes and type (same as working crawler)
    print("  Method 1: Click input boxes and type...")
    try:
        inputs = await page.query_selector_all('input')
        if inputs and len(inputs) >= 4:
            for i, digit in enumerate(password[:4]):
                await inputs[i].click()
                await inputs[i].fill(digit)
                await asyncio.sleep(0.2)
            await asyncio.sleep(2)

            content = await page.content()
            if 'Restricted Access' not in content and 'Incorrect code' not in content:
                print("  Authentication successful!")
                return True
    except Exception as e:
        print(f"  Input method: {e}")

    # Method 2: Global keyboard (site listens globally)
    print("  Method 2: Global keyboard input...")
    await page.click('body')
    await asyncio.sleep(0.5)
    await page.keyboard.press("Escape")
    await asyncio.sleep(0.3)

    for digit in password:
        await page.keyboard.press(f"Digit{digit}")
        print(f"    Pressed Digit{digit}")
        await asyncio.sleep(0.5)

    await asyncio.sleep(3)

    content = await page.content()
    if 'Restricted Access' not in content and 'Incorrect code' not in content:
        print("  Authentication successful!")
        return True

    # Method 3: Keyboard type
    print("  Method 3: Keyboard type...")
    await page.keyboard.press("Escape")
    await asyncio.sleep(0.3)

    for digit in password:
        await page.keyboard.type(digit)
        await asyncio.sleep(0.4)

    await asyncio.sleep(3)

    content = await page.content()
    if 'Restricted Access' not in content and 'Incorrect code' not in content:
        print("  Authentication successful!")
        return True

    # Method 4: Simple keyboard press after refresh
    print("  Method 4: Refresh and simple keyboard...")
    await page.reload(wait_until='networkidle')
    await asyncio.sleep(2)

    for digit in password:
        await page.keyboard.press(digit)
        await asyncio.sleep(0.5)

    await asyncio.sleep(3)

    content = await page.content()
    if 'Restricted Access' not in content and 'Incorrect code' not in content:
        print("  Authentication successful!")
        return True

    # Take debug screenshot
    print("  Taking debug screenshot...")
    await page.screenshot(path='/tmp/kenkai-auth-debug.png')
    print("  Saved to /tmp/kenkai-auth-debug.png")

    print("  Authentication failed!")
    return False


async def save_auth_state(context: BrowserContext):
    """Save authentication state for reuse."""
    await context.storage_state(path=str(AUTH_STATE_FILE))
    print(f"  Saved auth state to {AUTH_STATE_FILE}")


async def extract_course_content(page: Page) -> Dict:
    """Extract course content from page."""
    title = await page.title()
    url = page.url

    # Wait for content to load
    await asyncio.sleep(1)

    # Extract main content
    content_html = await page.evaluate('''() => {
        // Remove nav, sidebars, modals
        const toRemove = ['nav', 'header', '.sidebar', '[class*="modal"]', '[class*="overlay"]', 'script', 'style'];
        toRemove.forEach(sel => {
            document.querySelectorAll(sel).forEach(el => el.remove());
        });

        // Find main content area
        const selectors = ['main', 'article', '.content', '.course-content', '.lesson-content', '#content'];
        for (const sel of selectors) {
            const el = document.querySelector(sel);
            if (el && el.innerHTML.length > 100) return el.innerHTML;
        }
        return document.body.innerHTML;
    }''')

    # Convert to markdown
    content_md = md(content_html, heading_style="ATX", strip=['script', 'style'])
    content_md = re.sub(r'\n{3,}', '\n\n', content_md)

    return {
        'title': title,
        'url': url,
        'content': content_md
    }


async def crawl_courses(
    sections: List[str] = None,
    password: str = "9111",
    output_dir: str = None,
    headless: bool = False
):
    """Crawl specified course sections."""

    if sections is None:
        sections = ["hacker"]  # Default to RE courses

    output_path = Path(output_dir) if output_dir else Path.home() / ".claude" / "docs"
    output_path.mkdir(parents=True, exist_ok=True)

    all_results = []

    async with async_playwright() as p:
        # IMPORTANT: headless=False required for Ken Kai auth to work
        browser_args = {
            'headless': False,  # Must be False for PIN auth
            'slow_mo': 100
        }

        browser = await p.chromium.launch(**browser_args)

        context_args = {'viewport': {'width': 1920, 'height': 1080}}
        if AUTH_STATE_FILE.exists():
            print(f"Using saved auth state from {AUTH_STATE_FILE}")
            context_args['storage_state'] = str(AUTH_STATE_FILE)

        context = await browser.new_context(**context_args)
        page = await context.new_page()

        # Initial authentication
        print("Checking authentication...")
        await page.goto("https://www.kenkais.com/exclusive", wait_until='networkidle')
        await asyncio.sleep(2)

        if not await authenticate(page, password):
            print("ERROR: Could not authenticate. Check password.")
            await browser.close()
            return []

        # Save auth state for future runs
        await save_auth_state(context)

        # Crawl each section
        for section_key in sections:
            if section_key not in COURSES:
                print(f"Unknown section: {section_key}")
                continue

            section = COURSES[section_key]
            print(f"\n{'='*60}")
            print(f"Crawling section: {section['name']}")
            print(f"{'='*60}")

            section_results = []

            for course in section['courses']:
                url = f"https://www.kenkais.com/exclusive/{section_key}/{course['slug']}"
                print(f"\n  Crawling: {course['title']}")
                print(f"  URL: {url}")

                try:
                    await page.goto(url, wait_until='networkidle', timeout=30000)
                    await asyncio.sleep(1)

                    # Check if still authenticated
                    content = await page.content()
                    if 'Restricted Access' in content:
                        print("  Re-authenticating...")
                        if not await authenticate(page, password):
                            print("  Failed to re-authenticate, skipping...")
                            continue

                    result = await extract_course_content(page)
                    result['section'] = section['name']
                    result['course_title'] = course['title']
                    section_results.append(result)
                    print(f"  Extracted {len(result['content'])} chars")

                except Exception as e:
                    print(f"  Error: {e}")
                    continue

            all_results.extend(section_results)

            # Save section output
            if section_results:
                section_file = output_path / f"kenkai-{section_key}.md"
                section_md = f"# Ken Kai - {section['name']}\n\n"
                section_md += f"**Source:** https://www.kenkais.com/exclusive\n\n"
                section_md += f"---\n\n"

                for r in section_results:
                    section_md += f"## {r['course_title']}\n\n"
                    section_md += f"**URL:** {r['url']}\n\n"
                    section_md += r['content']
                    section_md += f"\n\n---\n\n"

                section_file.write_text(section_md)
                print(f"\nSaved: {section_file}")

        await browser.close()

    # Save combined output
    if all_results:
        combined_file = output_path / "kenkai-all-courses.md"
        combined_md = "# Ken Kai - All Courses\n\n"
        combined_md += f"**Crawled:** {len(all_results)} courses\n\n"
        combined_md += "---\n\n"

        current_section = None
        for r in all_results:
            if r['section'] != current_section:
                current_section = r['section']
                combined_md += f"# {current_section}\n\n"

            combined_md += f"## {r['course_title']}\n\n"
            combined_md += f"**URL:** {r['url']}\n\n"
            combined_md += r['content']
            combined_md += f"\n\n---\n\n"

        combined_file.write_text(combined_md)
        print(f"\nSaved combined: {combined_file}")

    return all_results


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Ken Kai Course Crawler')
    parser.add_argument('--sections', '-s', nargs='+',
                        choices=list(COURSES.keys()) + ['all'],
                        default=['hacker'],
                        help='Sections to crawl (default: hacker)')
    parser.add_argument('--password', '-p', default='9111',
                        help='PIN code (default: 9111)')
    parser.add_argument('--output', '-o',
                        help='Output directory')
    parser.add_argument('--headless', action='store_true',
                        help='Run in headless mode')
    parser.add_argument('--list', '-l', action='store_true',
                        help='List available sections and courses')

    args = parser.parse_args()

    if args.list:
        print("Available sections and courses:\n")
        for key, section in COURSES.items():
            print(f"[{key}] {section['name']}")
            for course in section['courses']:
                print(f"  - {course['title']}")
            print()
        return

    sections = list(COURSES.keys()) if 'all' in args.sections else args.sections

    asyncio.run(crawl_courses(
        sections=sections,
        password=args.password,
        output_dir=args.output,
        headless=args.headless
    ))


if __name__ == '__main__':
    main()
