---
description: Suno AI prompt generation from songs
argument-hint: "<youtube-url|file-path> [topic]"
allowed-tools: ["Bash", "WebSearch", "WebFetch", "Read"]
---

# Suno AI Prompt Generator

Analyzes songs and generates optimized prompts for Suno AI music generation. Creates both style and lyrics prompts that capture the essence of a song.

## Prerequisites

The command requires `yt-dlp` to be installed for YouTube URLs:

```bash
# macOS
brew install yt-dlp

# Linux
pip3 install yt-dlp
```

## Instructions

### Command Format

```bash
/suno <youtube-url|file-path> [topic]
```

**Parameters:**
- `youtube-url|file-path`: YouTube URL or path to audio file (required)
- `topic`: What the new song should be about (optional, defaults to "similar theme")

### What This Command Does

The `/suno` command generates TWO optimized prompts for Suno AI:

#### 1. Style Prompt (<1000 characters)
- Musical attributes (BPM, key, genre)
- Instrumentation details
- Beat/rhythm description
- Mood and atmosphere
- Section-by-section breakdown (intro, verse, chorus, etc.)

#### 2. Lyrics Prompt (<5000 characters)
- Original lyrics inspired by the source
- Matches the vibe and essence
- Follows same structure (verse/chorus/bridge)
- Uses similar rhyme schemes and patterns
- Based on your specified topic

### Examples

**Example 1: Analyze a YouTube video**
```bash
/suno https://www.youtube.com/watch?v=RjKKOqHyD34
```

**Example 2: Custom topic**
```bash
/suno https://www.youtube.com/watch?v=RjKKOqHyD34 "a song about chasing dreams"
```

**Example 3: Local audio file**
```bash
/suno ~/Music/my-song.mp3 "a song about heartbreak"
```

## Implementation Steps

When this command is invoked:

1. **Execute the skill script**
   ```bash
   ~/.claude/skills/suno.sh "$1" "$2"
   ```
   This will output the analysis instructions.

2. **Research Song Details**
   - Search for: "[Song Title] [Artist] BPM key genre"
   - Look for music databases (MusicStax, Tunebat, Song BPM, etc.)
   - Find: BPM, Key, Genre, Mood

3. **Analyze Instrumentation**
   - Search for: "[Song Title] instrumental breakdown" or "production analysis"
   - Identify: bass style, drums/percussion, melodic elements
   - Note: texture and layering

4. **Get Original Lyrics**
   - Search for: "[Song Title] [Artist] lyrics"
   - Analyze structure: verse/chorus/bridge layout
   - Note: rhyme schemes, line patterns

5. **Extract Vibe/Essence**
   - Theme: What is the song about?
   - Tone: Emotional quality
   - Imagery: Visual/sensory language
   - Voice: Perspective (first person, storytelling, etc.)

6. **Generate New Lyrics**
   - DO NOT copy original lyrics
   - CAPTURE the vibe, tone, and emotional essence
   - MATCH the structure (verse/chorus/bridge layout)
   - USE similar rhyme schemes and line patterns
   - KEEP total under 5000 characters

7. **Create Style Prompt**
   Format:
   ```
   A [mood] [genre] song at [BPM] bpm in the key of [Key]. Features [instrumentation].
   The mood is [emotional description] with [vocal style].

   [Intro] [description]
   [Verse] [description]
   [Chorus] [description]
   [Bridge] [description]
   [Outro] [description]
   ```
   **CRITICAL: Keep under 1000 characters**

8. **Output Format**
   Present both prompts with character counts:
   ```
   ═══════════════════════════════════════════════════════
   SUNO AI PROMPTS FOR: [Song Title]
   ═══════════════════════════════════════════════════════

   📊 SONG ANALYSIS
   ─────────────────────────────────────────────────────
   Title: [title]
   Artist: [artist]
   Genre: [genre]
   BPM: [bpm]
   Key: [key]
   Mood: [mood description]

   🎹 STYLE PROMPT (for Suno "Style of Music" field)
   ─────────────────────────────────────────────────────
   [Character count: XXX/1000]

   [Full style prompt here]

   ✍️ LYRICS PROMPT (for Suno "Lyrics" field)
   ─────────────────────────────────────────────────────
   [Character count: XXXX/5000]

   [Full structured lyrics here]

   ═══════════════════════════════════════════════════════
   ```

## Important Reminders

- Style prompt MUST be <1000 characters (strictly enforce)
- Lyrics prompt MUST be <5000 characters (strictly enforce)
- Show character counts for both
- Lyrics must be ORIGINAL, not copied
- Capture the VIBE/ESSENCE, not literal content
- Match the STRUCTURE and FLOW of the original

## Integration with Other Commands

```bash
# Download, analyze, create prompt
/media https://youtube.com/watch?v=... mp3
/suno https://youtube.com/watch?v=... "my custom topic"
```

## Reference Documentation

For detailed usage guide, see:
- `~/.claude/docs/suno-command-guide.md`
