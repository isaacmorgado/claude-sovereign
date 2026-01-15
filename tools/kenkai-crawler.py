#!/usr/bin/env python3
"""
Specialized crawler for Ken Kai's site with PIN code auth.
"""

import asyncio
import sys
from pathlib import Path

try:
    from playwright.async_api import async_playwright
except ImportError:
    import subprocess
    subprocess.run([sys.executable, "-m", "pip", "install", "playwright"], check=True)
    subprocess.run([sys.executable, "-m", "playwright", "install", "chromium"], check=True)
    from playwright.async_api import async_playwright

try:
    from markdownify import markdownify as md
except ImportError:
    import subprocess
    subprocess.run([sys.executable, "-m", "pip", "install", "markdownify"], check=True)
    from markdownify import markdownify as md


async def crawl_kenkai(password: str = "9111", output_file: str = None):
    """Crawl Ken Kai's exclusive content."""

    async with async_playwright() as p:
        # Launch with persistent context to maintain auth
        browser = await p.chromium.launch(headless=False, slow_mo=100)
        context = await browser.new_context(
            viewport={'width': 1920, 'height': 1080},
        )
        page = await context.new_page()

        print("Navigating to Ken Kai's exclusive page...")
        await page.goto("https://www.kenkais.com/exclusive", wait_until='networkidle')
        await asyncio.sleep(2)

        # Check if we're on the restricted page
        content = await page.content()
        if 'Restricted Access' in content:
            print(f"Found restricted access page. Entering code: {password}")

            # Wait for page to fully initialize
            await asyncio.sleep(2)

            # Dismiss any modals/overlays first (like "What's New")
            print("Dismissing any modals...")
            try:
                # Try clicking outside the modal or pressing Escape multiple times
                for _ in range(3):
                    await page.keyboard.press("Escape")
                    await asyncio.sleep(0.3)

                # Try clicking a close button if present
                close_btns = await page.query_selector_all('[class*="close"], button[aria-label*="close"], .modal-close, [data-dismiss]')
                for btn in close_btns:
                    try:
                        await btn.click()
                        await asyncio.sleep(0.3)
                    except:
                        pass

                # Click outside any modal (top-left corner)
                await page.mouse.click(10, 10)
                await asyncio.sleep(0.5)

            except Exception as e:
                print(f"  Modal dismiss: {e}")

            await asyncio.sleep(1)

            # Method 1: Click first input box and type digits sequentially
            print("Method 1: Click input boxes and type...")
            try:
                # Find all input boxes (they may be hidden inputs or divs)
                inputs = await page.query_selector_all('input')
                if inputs and len(inputs) >= 4:
                    for i, digit in enumerate(password[:4]):
                        await inputs[i].click()
                        await inputs[i].fill(digit)
                        await asyncio.sleep(0.2)
                    await asyncio.sleep(2)
            except Exception as e:
                print(f"  Input method failed: {e}")

            # Check if auth worked
            content = await page.content()
            if 'Restricted Access' not in content and 'Incorrect code' not in content:
                print("Successfully authenticated!")
            else:
                # Method 2: Focus window and use keyboard (site listens globally)
                print("Method 2: Global keyboard input...")

                # Click somewhere neutral first
                await page.click('body')
                await asyncio.sleep(0.5)

                # Press Escape to clear any state
                await page.keyboard.press("Escape")
                await asyncio.sleep(0.3)

                # Type digits slowly
                for digit in password:
                    await page.keyboard.press(f"Digit{digit}")
                    print(f"  Pressed Digit{digit}")
                    await asyncio.sleep(0.5)

                await asyncio.sleep(3)
                content = await page.content()

                if 'Restricted Access' not in content and 'Incorrect code' not in content:
                    print("Successfully authenticated!")
                else:
                    # Method 3: Use keyboard.type with numpad
                    print("Method 3: Keyboard type...")
                    await page.keyboard.press("Escape")
                    await asyncio.sleep(0.3)

                    for digit in password:
                        await page.keyboard.type(digit)
                        await asyncio.sleep(0.4)

                    await asyncio.sleep(3)
                    content = await page.content()

                    if 'Restricted Access' not in content and 'Incorrect code' not in content:
                        print("Successfully authenticated!")
                    else:
                        # Method 4: Try clicking on the actual PIN input squares
                        print("Method 4: Click PIN squares...")
                        # The squares appear to be at specific positions based on screenshot
                        # They're centered around x=728 with spacing
                        square_positions = [
                            {'x': 618, 'y': 397},
                            {'x': 691, 'y': 397},
                            {'x': 764, 'y': 397},
                            {'x': 837, 'y': 397},
                        ]

                        for i, digit in enumerate(password[:4]):
                            await page.click('body', position=square_positions[i])
                            await asyncio.sleep(0.2)
                            await page.keyboard.type(digit)
                            await asyncio.sleep(0.3)

                        await asyncio.sleep(3)
                        content = await page.content()

                        if 'Restricted Access' not in content and 'Incorrect code' not in content:
                            print("Successfully authenticated!")
                        else:
                            print("Authentication failed. Taking screenshot...")
                            await page.screenshot(path='/tmp/kenkai-auth-fail.png')
                            print("Screenshot saved to /tmp/kenkai-auth-fail.png")

                            # Try one more time with simple approach after refresh
                            print("Method 5: Refresh and simple keyboard...")
                            await page.reload(wait_until='networkidle')
                            await asyncio.sleep(2)

                            for digit in password:
                                await page.keyboard.press(digit)
                                await asyncio.sleep(0.5)

                            await asyncio.sleep(3)

        # Now crawl the content
        print("\nExtracting page content...")

        # Get the main content
        main_content = await page.evaluate('''() => {
            // Remove navigation elements
            const nav = document.querySelector('nav');
            if (nav) nav.remove();

            const sidebar = document.querySelector('.sidebar, [class*="sidebar"]');
            if (sidebar) sidebar.remove();

            // Get main content
            const main = document.querySelector('main') || document.body;
            return main.innerHTML;
        }''')

        title = await page.title()
        url = page.url

        # Convert to markdown
        markdown_content = md(main_content, heading_style="ATX", strip=['script', 'style'])

        # Clean up
        import re
        markdown_content = re.sub(r'\n{3,}', '\n\n', markdown_content)

        result = f"# {title}\n\n**Source:** {url}\n\n{markdown_content}"

        if output_file:
            Path(output_file).write_text(result)
            print(f"\nSaved to: {output_file}")
        else:
            print(result)

        # Get list of course links for further crawling
        links = await page.evaluate('''() => {
            return Array.from(document.querySelectorAll('a[href*="/exclusive/"]'))
                .map(a => ({href: a.href, text: a.innerText}))
                .filter((v, i, a) => a.findIndex(t => t.href === v.href) === i);
        }''')

        print(f"\nFound {len(links)} course links:")
        for link in links[:20]:
            print(f"  - {link.get('text', '').strip()[:50]}: {link.get('href', '')}")

        # Auto-close after extraction
        await asyncio.sleep(2)
        await browser.close()

        return result


if __name__ == '__main__':
    password = sys.argv[1] if len(sys.argv) > 1 else "9111"
    output = sys.argv[2] if len(sys.argv) > 2 else "/Users/imorgado/.claude/docs/kenkai-exclusive.md"

    asyncio.run(crawl_kenkai(password, output))
