---
description: Standard quality vocal extraction (fast, ~2 min)
argument-hint: "<audio_file|youtube_url> [song_name]"
allowed-tools: ["Bash"]
---

# /extract1 - Standard Quality Vocal Extraction

Fast vocal extraction using Demucs AI. Good quality in ~2 minutes.

## Quick Usage

```
/extract1 https://youtu.be/VIDEO_ID
/extract1 https://youtu.be/VIDEO_ID "Artist - Song Title"
/extract1 ~/Music/song.mp3
/extract1 ~/Music/song.mp3 "Custom Name"
```

## Features

- ⚡ **Fast**: ~2 minutes for 3-4 min songs
- 🎵 **Quality**: Good (SDR ~8.0 vocals, ~11.0 instrumental)
- 💾 **Output**: ~/Desktop/MediaVault_v2/separated_vocals/
- 📦 **Model**: Demucs htdemucs
- 🎛️  **Auto-Muffle**: Instrumental automatically muffled (lo-fi effect)

## Instructions

Parse the arguments from: $ARGUMENTS

### Execute the Extraction

```bash
# Get the input and optional song name from arguments
~/.claude/skills/extract1.sh $ARGUMENTS
```

The script will:
1. Accept audio file or YouTube URL
2. Download if needed (YouTube)
3. Separate vocals and instrumentals using Demucs
4. Apply muffling/muddling effects to instrumental (auto)
5. Save to MediaVault_v2/separated_vocals/

### Output Files

After completion, you'll find:
- [Song Name] - Vocals.wav (44.1kHz, pristine)
- [Song Name] - Instrumental.wav (32kHz, muffled/muddled)
- [Song Name] - Original.wav
- info.txt (metadata)

### Post-Processing Applied

The instrumental is automatically processed with:
- Lowpass filter at 3kHz (removes high frequencies)
- Highpass filter at 100Hz (removes rumble)
- Downsampled to 32kHz (reduced clarity)
- 5% random noise (muddling effect)
- 80% volume (softer sound)

### When to Use

Use `/extract1` when:
- You need quick results
- Good quality is sufficient
- Processing time matters

For maximum quality (slower), use `/extract2` instead.
