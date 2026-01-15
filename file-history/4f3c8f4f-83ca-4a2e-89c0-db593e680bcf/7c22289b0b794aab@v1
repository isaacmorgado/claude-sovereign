#!/bin/bash
# Test script for enhanced /suno command with audio analysis

set -euo pipefail

echo "════════════════════════════════════════════════════════"
echo "Testing Enhanced /suno Command with Audio Analysis"
echo "════════════════════════════════════════════════════════"
echo ""

# Test 1: Check if scripts exist
echo "Test 1: Checking script files..."
if [[ -f "$HOME/.claude/skills/suno.sh" ]]; then
    echo "  ✅ suno.sh exists"
else
    echo "  ❌ suno.sh not found"
    exit 1
fi

if [[ -x "$HOME/.claude/scripts/analyze-audio.py" ]]; then
    echo "  ✅ analyze-audio.py exists and is executable"
else
    echo "  ❌ analyze-audio.py not found or not executable"
    exit 1
fi
echo ""

# Test 2: Check Python dependencies
echo "Test 2: Checking Python dependencies..."
ESSENTIA_INSTALLED=false
LIBROSA_INSTALLED=false

if python3 -c "import essentia.standard" 2>/dev/null; then
    echo "  ✅ Essentia installed"
    ESSENTIA_INSTALLED=true
else
    echo "  ⚠️  Essentia not installed (will use fallback)"
fi

if python3 -c "import librosa" 2>/dev/null; then
    echo "  ✅ Librosa installed"
    LIBROSA_INSTALLED=true
else
    echo "  ⚠️  Librosa not installed (will use fallback)"
fi

if [[ "$ESSENTIA_INSTALLED" == "false" && "$LIBROSA_INSTALLED" == "false" ]]; then
    echo "  ⚠️  No audio analysis libraries installed"
    echo "  ℹ️  /suno will fall back to web search method"
    echo "  ℹ️  To enable audio analysis, run:"
    echo "      pip install essentia-tensorflow"
    echo "      OR"
    echo "      pip install librosa numpy"
fi
echo ""

# Test 3: Test analyze-audio.py error handling
echo "Test 3: Testing analyze-audio.py error handling..."
ERROR_OUTPUT=$(python3 "$HOME/.claude/scripts/analyze-audio.py" 2>&1 || true)
if echo "$ERROR_OUTPUT" | grep -q '"error": "no_input"'; then
    echo "  ✅ Correctly handles missing input"
else
    echo "  ❌ Unexpected error output"
    echo "$ERROR_OUTPUT"
fi

ERROR_OUTPUT=$(python3 "$HOME/.claude/scripts/analyze-audio.py" /nonexistent/file.mp3 2>&1 || true)
if echo "$ERROR_OUTPUT" | grep -q '"error": "file_not_found"'; then
    echo "  ✅ Correctly handles missing file"
else
    echo "  ❌ Unexpected error for missing file"
    echo "$ERROR_OUTPUT"
fi
echo ""

# Test 4: Test /suno help output
echo "Test 4: Testing /suno help output..."
HELP_OUTPUT=$("$HOME/.claude/skills/suno.sh" 2>&1 || true)
if echo "$HELP_OUTPUT" | grep -q "Usage: /suno"; then
    echo "  ✅ Help output displays correctly"
else
    echo "  ❌ Help output missing or incorrect"
    echo "$HELP_OUTPUT"
fi
echo ""

# Test 5: Check if yt-dlp is available
echo "Test 5: Checking YouTube download capability..."
if command -v yt-dlp &> /dev/null; then
    echo "  ✅ yt-dlp installed (YouTube support enabled)"
else
    echo "  ⚠️  yt-dlp not installed (YouTube URLs won't work)"
    echo "  ℹ️  Install with: pip install yt-dlp"
fi
echo ""

# Test 6: Integration test summary
echo "Test 6: Integration test summary..."
echo ""
echo "Component Status:"
echo "  - Suno skill script: ✅ Ready"
echo "  - Audio analysis script: ✅ Ready"
if [[ "$ESSENTIA_INSTALLED" == "true" ]]; then
    echo "  - Audio analysis (Essentia): ✅ Available"
elif [[ "$LIBROSA_INSTALLED" == "true" ]]; then
    echo "  - Audio analysis (Librosa): ✅ Available"
else
    echo "  - Audio analysis: ⚠️  Not available (web search fallback)"
fi
echo ""

echo "════════════════════════════════════════════════════════"
echo "Expected Behavior:"
echo "════════════════════════════════════════════════════════"
echo ""
if [[ "$ESSENTIA_INSTALLED" == "true" || "$LIBROSA_INSTALLED" == "true" ]]; then
    echo "When you run /suno:"
    echo "  1. Downloads/loads audio file"
    echo "  2. Runs audio analysis (Essentia or Librosa)"
    echo "  3. Provides accurate BPM, key, and mood data to Claude"
    echo "  4. Claude generates Suno prompts using analysis data"
    echo "  5. Only searches web for genre/instrumentation details"
    echo ""
    echo "✅ ENHANCED MODE: Audio analysis is available!"
else
    echo "When you run /suno:"
    echo "  1. Loads audio metadata"
    echo "  2. Skips audio analysis (libraries not installed)"
    echo "  3. Falls back to web search method"
    echo "  4. Claude searches for BPM, key, genre manually"
    echo ""
    echo "⚠️  FALLBACK MODE: Install audio libraries for best results"
    echo ""
    echo "To enable enhanced mode:"
    echo "  pip install essentia-tensorflow  (recommended)"
    echo "  OR"
    echo "  pip install librosa numpy  (good alternative)"
fi
echo ""

echo "════════════════════════════════════════════════════════"
echo "Test Complete!"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Install audio analysis libraries (if desired)"
echo "  2. Test with a real song: /suno <youtube-url>"
echo "  3. Review generated prompts for accuracy"
echo ""
