---
description: Media download and organization (YouTube, audio/video)
argument-hint: "[command] [url] [format]"
allowed-tools: ["Bash", "Read", "Write", "Glob"]
---

# Media Command

Download and organize media from YouTube and other sources. Supports MP3 audio extraction and MP4 video downloads.

## Prerequisites

The command requires `yt-dlp` to be installed. If not present, install it:

```bash
# macOS
brew install yt-dlp

# Linux
pip3 install yt-dlp

# Or via pipx
pipx install yt-dlp
```

## Instructions

### Command Format

```
/media [subcommand] [url] [format]
```

### Available Subcommands

#### 1. `download` - Download media from URL

**MP3 (Audio only):**
```
/media download [youtube-url] mp3
```

Downloads best audio quality and converts to MP3.

**MP4 (Video with audio):**
```
/media download [youtube-url] mp4
```

Downloads best video+audio quality in MP4 format.

**Implementation:**

For MP3:
```bash
yt-dlp -x --audio-format mp3 --audio-quality 0 \
  --output "~/Downloads/%(title)s.%(ext)s" \
  "[url]"
```

For MP4:
```bash
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
  --merge-output-format mp4 \
  --output "~/Downloads/%(title)s.%(ext)s" \
  "[url]"
```

#### 2. `playlist` - Download entire playlist

**MP3:**
```
/media playlist [youtube-playlist-url] mp3
```

**MP4:**
```
/media playlist [youtube-playlist-url] mp4
```

**Implementation:**

Same as download but with `--yes-playlist` flag:
```bash
yt-dlp --yes-playlist [other-options] "[url]"
```

#### 3. `info` - Get media information without downloading

```
/media info [youtube-url]
```

**Implementation:**
```bash
yt-dlp --print "%(title)s|%(duration_string)s|%(filesize_approx)s" \
  --no-download "[url]"
```

Shows: title, duration, approximate file size

#### 4. `organize` - Organize downloaded media

```
/media organize [directory]
```

Organizes files in the specified directory (default: ~/Downloads) by:
- Moving MP3 files to `~/Music/Downloads/`
- Moving MP4 files to `~/Videos/Downloads/`
- Creating dated subdirectories (YYYY-MM-DD)

**Implementation:**
```bash
# Create directories if needed
mkdir -p ~/Music/Downloads/$(date +%Y-%m-%d)
mkdir -p ~/Videos/Downloads/$(date +%Y-%m-%d)

# Move MP3 files
find [directory] -maxdepth 1 -name "*.mp3" -mtime -1 \
  -exec mv {} ~/Music/Downloads/$(date +%Y-%m-%d)/ \;

# Move MP4 files
find [directory] -maxdepth 1 -name "*.mp4" -mtime -1 \
  -exec mv {} ~/Videos/Downloads/$(date +%Y-%m-%d)/ \;
```

#### 5. `list` - List recent downloads

```
/media list [type]
```

Types: `audio`, `video`, or `all` (default)

Shows recently downloaded files with:
- Filename
- Size
- Download date

**Implementation:**
```bash
# Audio
ls -lht ~/Music/Downloads/*/*.mp3 2>/dev/null | head -10

# Video
ls -lht ~/Videos/Downloads/*/*.mp4 2>/dev/null | head -10

# All
ls -lht ~/Downloads/*.{mp3,mp4} 2>/dev/null | head -10
```

## Usage Examples

### Example 1: Download song as MP3
```
User: /media download https://youtube.com/watch?v=dQw4w9WgXcQ mp3

Claude:
[Checks if yt-dlp is installed]
[Runs yt-dlp command to download audio as MP3]

Downloaded: Never Gonna Give You Up.mp3
Location: ~/Downloads/
Size: 3.4 MB

Would you like me to organize this file? Run: /media organize
```

### Example 2: Download video as MP4
```
User: /media download https://youtube.com/watch?v=dQw4w9WgXcQ mp4

Claude:
[Downloads video with audio in MP4 format]

Downloaded: Never Gonna Give You Up.mp4
Location: ~/Downloads/
Resolution: 1920x1080
Size: 45.2 MB
```

### Example 3: Get info before downloading
```
User: /media info https://youtube.com/watch?v=dQw4w9WgXcQ

Claude:
Title: Rick Astley - Never Gonna Give You Up
Duration: 3:33
Approximate size (MP4): 45 MB
Approximate size (MP3): 3.4 MB

Ready to download? Specify:
/media download [url] mp3  (audio only)
/media download [url] mp4  (video)
```

### Example 4: Download playlist
```
User: /media playlist https://youtube.com/playlist?list=PLx... mp3

Claude:
[Downloads entire playlist as MP3 files]

Downloaded 24 tracks:
- Track 1.mp3 (3.2 MB)
- Track 2.mp3 (4.1 MB)
...

Total size: 89.4 MB
Location: ~/Downloads/
```

### Example 5: Organize downloads
```
User: /media organize

Claude:
Organizing media files...

Moved to ~/Music/Downloads/2026-01-13/:
- Never Gonna Give You Up.mp3
- Song Title 2.mp3
(2 files, 7.5 MB)

Moved to ~/Videos/Downloads/2026-01-13/:
- Video Title.mp4
(1 file, 45.2 MB)

Done!
```

## Error Handling

### If yt-dlp is not installed:
```
yt-dlp is not installed. Install it with:

macOS: brew install yt-dlp
Linux: pip3 install yt-dlp

Then try again.
```

### If URL is invalid:
```
Could not download from URL. Please check:
- URL is accessible
- Video is not private or restricted
- You have internet connection

Try running: /media info [url] to test the URL first.
```

### If download fails:
```
Download failed. Common issues:
- Video might be region-restricted
- Age-restricted content (requires login)
- Copyright claim or removed video

Try a different video or check the URL.
```

## Advanced Options

### Custom output directory:
```bash
yt-dlp --output "/path/to/dir/%(title)s.%(ext)s" [other-options] "[url]"
```

### Download subtitles:
```bash
yt-dlp --write-auto-sub --sub-lang en [other-options] "[url]"
```

### Limit download speed:
```bash
yt-dlp --limit-rate 1M [other-options] "[url]"
```

## Guidelines

1. **Always check yt-dlp installation first** - Run `which yt-dlp` to verify
2. **Show download progress** - Display what's happening during download
3. **Provide file information** - After download, show filename, size, location
4. **Suggest organization** - Remind user they can run `/media organize`
5. **Validate URLs** - Check URL format before attempting download
6. **Handle errors gracefully** - Provide clear error messages and solutions
7. **Respect user's bandwidth** - For large files/playlists, confirm before downloading
8. **Default to ~/Downloads/** - Use standard Downloads directory unless specified

## Integration with Other Commands

- After downloading: Suggest `/media organize` to sort files
- Before large downloads: Use `/media info` to check size
- After organization: Use `/media list` to view organized files

## Notes

- Audio quality for MP3: Uses highest available (320kbps when possible)
- Video quality for MP4: Downloads best available up to 1080p by default
- Playlist downloads show progress for each item
- Organization is optional - files stay in ~/Downloads/ until organized
- Organize command only moves files from last 24 hours by default
