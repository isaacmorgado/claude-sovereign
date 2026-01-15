#!/bin/bash
#
# /extract1 - Standard Quality Vocal Extraction
# Fast processing (~2 min) using Demucs AI
#

set -e

TOOLS_DIR="$HOME/Desktop/tools"
SCRIPT="$TOOLS_DIR/separate.sh"

# Check if script exists
if [ ! -f "$SCRIPT" ]; then
    echo "Error: separate.sh not found at $TOOLS_DIR"
    exit 1
fi

# Get input from arguments
INPUT="${1:-}"
SONG_NAME="${2:-}"

if [ -z "$INPUT" ]; then
    cat << 'EOF'
╔════════════════════════════════════════════════╗
║   /extract1 - Standard Quality Extraction     ║
║   Fast Processing with Demucs AI              ║
╚════════════════════════════════════════════════╝

Usage: /extract1 <audio_file|youtube_url> [song_name]

Examples:
  /extract1 https://youtu.be/VIDEO_ID
  /extract1 https://youtu.be/VIDEO_ID "Artist - Song Title"
  /extract1 ~/Music/song.mp3
  /extract1 ~/Music/song.mp3 "Custom Name"

Features:
  ⚡ Fast: ~2 minutes for 3-4 min songs
  🎵 Quality: Good (SDR ~8.0 vocals, ~11.0 instrumental)
  💾 Output: ~/Desktop/MediaVault_v2/separated_vocals/
  📦 Model: Demucs htdemucs
  🎛️  Auto-Muffle: Instrumental automatically muffled (lo-fi effect)

Output Files:
  • [Song Name] - Vocals.wav (44.1kHz, pristine)
  • [Song Name] - Instrumental.wav (32kHz, muffled/muddled)
  • [Song Name] - Original.wav
  • info.txt (metadata)

Post-Processing:
  The instrumental is automatically processed with:
  - Lowpass filter at 3kHz (removes high frequencies)
  - Highpass filter at 100Hz (removes rumble)
  - Downsampled to 32kHz (reduced clarity)
  - 5% random noise (muddling effect)
  - 80% volume (softer sound)

For MAXIMUM quality (slower), use /extract2 instead.
EOF
    exit 0
fi

# Execute the script
echo "🎵 Launching standard quality extraction..."
echo ""

if [ -n "$SONG_NAME" ]; then
    "$SCRIPT" "$INPUT" "$SONG_NAME"
else
    "$SCRIPT" "$INPUT"
fi
