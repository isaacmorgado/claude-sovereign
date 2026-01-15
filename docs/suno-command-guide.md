# Suno AI Prompt Generator - Command Guide

## Overview

The `/suno` command analyzes songs and generates optimized prompts for Suno AI music generation. It extracts musical attributes, analyzes structure, and creates both style and lyrics prompts.

## Command Syntax

```bash
/suno <youtube-url|file-path> [topic]
```

### Parameters

- **youtube-url|file-path**: YouTube URL or path to audio file (required)
- **topic**: What the new song should be about (optional, defaults to "similar theme")

## What It Does

The command generates TWO prompts for Suno AI:

### 1. Style Prompt (<1000 characters)
- Musical attributes (BPM, key, genre)
- Instrumentation details
- Beat/rhythm description
- Mood and atmosphere
- Section-by-section breakdown (intro, verse, chorus, etc.)

### 2. Lyrics Prompt (<5000 characters)
- Original lyrics in similar style/structure
- Matches the vibe and essence of the source song
- Follows same structure (verse/chorus/bridge)
- Uses similar rhyme schemes and patterns
- Based on your specified topic

## Usage Examples

### Example 1: Analyze a YouTube Video

```bash
/suno https://www.youtube.com/watch?v=RjKKOqHyD34
```

This analyzes "Free Fall" by Tems and creates prompts for a similar song.

### Example 2: Custom Topic

```bash
/suno https://www.youtube.com/watch?v=RjKKOqHyD34 "a song about chasing dreams"
```

Analyzes the style of "Free Fall" but creates lyrics about chasing dreams instead.

### Example 3: Local Audio File

```bash
/suno ~/Music/my-song.mp3 "a song about heartbreak"
```

Analyzes a local audio file and creates heartbreak-themed lyrics.

## Process Flow

### For Style Prompt:

1. **Fetch Song Metadata**
   - Gets title, artist, duration from YouTube/file

2. **Research Musical Attributes**
   - Searches for BPM, key, genre in music databases
   - Looks for production analysis and instrumentation details

3. **Analyze Beat/Rhythm**
   - Identifies rhythm patterns and groove
   - Notes percussion elements and texture

4. **Create Structured Prompt**
   - Formats with section descriptions
   - Keeps under 1000 characters

### For Lyrics Prompt:

1. **Get Original Lyrics**
   - Searches for and retrieves lyrics

2. **Analyze Structure**
   - Maps verse/chorus/bridge layout
   - Notes rhyme schemes and patterns

3. **Extract Vibe/Essence**
   - Identifies themes, tone, imagery
   - Understands emotional quality

4. **Generate New Lyrics**
   - Creates ORIGINAL content (not copied)
   - Matches structure and flow
   - Captures vibe based on your topic
   - Keeps under 5000 characters

## Output Format

```
═══════════════════════════════════════════════════════
SUNO AI PROMPTS FOR: [Song Title]
═══════════════════════════════════════════════════════

📊 SONG ANALYSIS
─────────────────────────────────────────────────────
Title: Free Fall
Artist: Tems ft. J. Cole
Genre: Afro-R&B, Alternative R&B
BPM: 100
Key: A Minor
Mood: Dreamy, nostalgic, emotional

🎹 STYLE PROMPT (for Suno "Style of Music" field)
─────────────────────────────────────────────────────
[Character count: 487/1000]

A dreamy Afro-R&B song at 100 bpm in the key of A Minor. Features a deep thumping bassline, soft piano chords, intricate percussion with cowbells and shakers, and a clean electric guitar loop. The mood is emotional, nostalgic, and atmospheric with soulful vocals.

[Intro] Ethereal synth pads, soft electric guitar plucks, deep humming vocals, no drums.

[Verse] Beat drops, thumping sub-bass, steady Afrobeat rimshot rhythm, subtle shakers, smooth deep vocals.

[Chorus] Rich vocal harmonies, emotional melody, consistent laid-back groove, melodic guitar loop.

[Bridge] Spacious, dreamy atmosphere, bass fades out, focus on vocals.

[Outro] Soft guitar riffs, fading beat, gentle vocal ad-libs, ambient decay.

✍️ LYRICS PROMPT (for Suno "Lyrics" field)
─────────────────────────────────────────────────────
[Character count: 892/5000]

[Intro]
(Soft humming, atmospheric)

[Verse 1]
Standing on the edge, looking down below
Heart racing fast but my mind moves slow
Gravity calling, pulling me close
Into the unknown, that's where I'll go

[Pre-Chorus]
No safety net, no turning back
Lost in the moment, fading to black

[Chorus]
I'm in free fall, free fall
Nothing holding me at all
Let the wind carry my soul
I'm in free fall, free fall
Breaking through these walls
Finding freedom as I go

[Verse 2]
Used to fear the drop, the loss of control
Now I'm diving deep, making myself whole
Every second counts when you're in the air
Learning how to fly from a whispered prayer

[Chorus]
I'm in free fall, free fall
Nothing holding me at all
Let the wind carry my soul
I'm in free fall, free fall
Breaking through these walls
Finding freedom as I go

[Bridge]
Weightless, boundless
Nothing can stop this
I'm finally free

[Outro]
(Vocals fade, soft guitar, ambient decay)
Free fall... free fall...

═══════════════════════════════════════════════════════
```

## Tips for Best Results

### For Style Prompts:
- Be specific about instrumentation
- Include mood/atmosphere descriptors
- Specify BPM and key when known
- Break down by song sections
- Use vivid production terms (thumping, dreamy, crisp, etc.)

### For Lyrics Prompts:
- Match syllable counts of original
- Use similar rhyme schemes
- Capture emotional tone, not literal meaning
- Include section markers clearly
- Keep imagery consistent with mood
- Don't copy - create inspired-by content

## Character Limits

**CRITICAL**: Suno has strict character limits:
- **Style Prompt**: 1000 characters maximum
- **Lyrics Prompt**: 5000 characters maximum

The command will show character counts for both prompts. If you exceed limits, you'll need to trim content.

## Common Use Cases

### 1. Creating a Cover-Style Song
```bash
/suno https://youtube.com/watch?v=... "similar vibe"
```

### 2. Genre-Inspired Original
```bash
/suno https://youtube.com/watch?v=... "a song about my journey"
```

### 3. Studying Song Structure
Use the analysis to understand how professional songs are structured, then apply those patterns to your own work.

### 4. Quick Suno Templates
Generate ready-to-use prompts that you can paste directly into Suno.

## Integration with Other Commands

```bash
# Download, analyze, create prompt
/media https://youtube.com/watch?v=... mp3
/suno https://youtube.com/watch?v=... "my custom topic"

# Organize after creating your Suno song
/media organize
```

## Troubleshooting

### "Could not fetch video information"
- Check that the URL is valid and accessible
- Ensure you have internet connection
- Try a different video

### "Unknown artist/title"
- For local files, rename them with artist and title
- Or manually specify when using Suno

### Character count too high
- Remove less important instrumentation details
- Condense section descriptions
- Simplify lyrics while maintaining structure

## Advanced Usage

### Multiple Iterations
```bash
# Try different topics for the same style
/suno URL "topic 1"
/suno URL "topic 2"
/suno URL "topic 3"
```

### Combining Styles
Analyze multiple songs, then manually combine elements from their style prompts in Suno.

### Genre Exploration
```bash
# Study different genres
/suno <afrobeat-song-url>
/suno <jazz-song-url>
/suno <rock-song-url>
```

## Notes

- The analysis uses web search to find BPM, key, and other attributes
- If exact values aren't found, it will estimate based on genre conventions
- Lyrics are AI-generated to match vibe, not copied from source
- Always respect copyright - this is for creating inspired-by content, not copies
- The prompts are optimized for Suno v4's format and capabilities

## Support

For issues or feature requests, check:
- `~/.claude/skills/suno.sh` - The skill script
- `~/.claude/docs/suno-command-guide.md` - This guide

## Version History

- **v1.0** (2026-01-13): Initial release
  - Style prompt generation (<1000 chars)
  - Lyrics prompt generation (<5000 chars)
  - YouTube URL and file support
  - Custom topic support
