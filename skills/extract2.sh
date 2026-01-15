#!/bin/bash
#
# /extract2 - High Quality Vocal Extraction
# Studio-grade processing (~6 min) using BS-Roformer + MelBand Roformer
#

set -e

TOOLS_DIR="$HOME/Desktop/tools"
SCRIPT="$TOOLS_DIR/separate_hq.sh"

# Check if script exists
if [ ! -f "$SCRIPT" ]; then
    echo "Error: separate_hq.sh not found at $TOOLS_DIR"
    exit 1
fi

# Get input from arguments
INPUT="${1:-}"
SONG_NAME="${2:-}"

if [ -z "$INPUT" ]; then
    cat << 'EOF'
╔════════════════════════════════════════════════╗
║   /extract2 - High Quality Extraction         ║
║   Studio-Grade with BS-Roformer + MelBand     ║
╚════════════════════════════════════════════════╝

Usage: /extract2 <audio_file|youtube_url> [song_name]

Examples:
  /extract2 https://youtu.be/VIDEO_ID
  /extract2 https://youtu.be/VIDEO_ID "Artist - Song Title"
  /extract2 ~/Music/song.mp3
  /extract2 ~/Music/song.mp3 "Custom Name"

Features:
  ⏱️  Slower: ~6 minutes for 3-4 min songs
  🎯 Quality: MAXIMUM (SDR 12.1-12.6 vocals, 16.3 instrumental)
  💾 Output: ~/Desktop/MediaVault_v2/separated_vocals_HQ/
  🤖 Models: BS-Roformer-Viperx-1296 + MelBand Roformer

Output Files:
  • [Song Name] - Vocals (BS-Roformer).wav - Best balanced
  • [Song Name] - Vocals (MelBand).wav - Maximum clarity
  • [Song Name] - Instrumental (BS-Roformer).wav
  • [Song Name] - Original.wav
  • info.txt (metadata)

Note: First run downloads ~1.3GB of AI models (one-time)

For FASTER processing, use /extract1 instead.
EOF
    exit 0
fi

# Execute the script
echo "🎯 Launching high quality extraction..."
echo "⏱️  This will take 5-10 minutes for best results..."
echo ""

if [ -n "$SONG_NAME" ]; then
    "$SCRIPT" "$INPUT" "$SONG_NAME"
else
    "$SCRIPT" "$INPUT"
fi
