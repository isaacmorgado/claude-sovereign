---
description: High quality vocal extraction (studio-grade, ~6 min)
argument-hint: "<audio_file|youtube_url> [song_name]"
allowed-tools: ["Bash"]
---

# /extract2 - High Quality Vocal Extraction

Studio-grade vocal extraction using BS-Roformer + MelBand Roformer. Maximum quality in ~6 minutes.

## Quick Usage

```
/extract2 https://youtu.be/VIDEO_ID
/extract2 https://youtu.be/VIDEO_ID "Artist - Song Title"
/extract2 ~/Music/song.mp3
/extract2 ~/Music/song.mp3 "Custom Name"
```

## Features

- ⏱️  **Slower**: ~6 minutes for 3-4 min songs
- 🎯 **Quality**: MAXIMUM (SDR 12.1-12.6 vocals, 16.3 instrumental)
- 💾 **Output**: ~/Desktop/MediaVault_v2/separated_vocals_HQ/
- 🤖 **Models**: BS-Roformer-Viperx-1296 + MelBand Roformer

## Instructions

Parse the arguments from: $ARGUMENTS

### Execute the Extraction

```bash
# Get the input and optional song name from arguments
~/.claude/skills/extract2.sh $ARGUMENTS
```

The script will:
1. Accept audio file or YouTube URL
2. Download if needed (YouTube)
3. Separate vocals using TWO state-of-the-art models
4. Save to MediaVault_v2/separated_vocals_HQ/

### Output Files

After completion, you'll find:
- [Song Name] - Vocals (BS-Roformer).wav - Best balanced
- [Song Name] - Vocals (MelBand).wav - Maximum clarity
- [Song Name] - Instrumental (BS-Roformer).wav
- [Song Name] - Original.wav
- info.txt (metadata)

### First Run Note

First run downloads ~1.3GB of AI models (one-time).

### When to Use

Use `/extract2` when:
- You need studio-grade quality
- Processing time is not a concern
- You're working on professional projects
- You want the best possible separation

For faster processing, use `/extract1` instead.
