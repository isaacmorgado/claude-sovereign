# Media Download & Organization Command

The `/media` command downloads and automatically organizes media files from YouTube and other sources into your `~/Desktop/mediavault` folder.

## Quick Start

```bash
# Download a YouTube video as MP3
/media download https://youtube.com/watch?v=...

# Download in different format
/media download https://youtube.com/watch?v=... flac

# Organize an existing file
/media organize ~/Downloads/song.mp3

# List your media vault
/media list
```

## Organization System

The media vault uses intelligent auto-organization based on metadata:

### Folder Structure
```
~/Desktop/mediavault/
├── Music/
│   ├── [Artist Name]/        # Organized by uploader/artist
│   └── Singles/               # Unknown or single tracks
├── Videos/
│   └── Unsorted/             # Video content
├── Podcasts/
│   └── [Podcast Name]/       # Organized by show/uploader
└── Audiobooks/               # Audiobook content
```

### Auto-Detection Rules

The command analyzes metadata to determine the correct location:

**Music** (default):
- Short duration (< 15 minutes)
- Music-related keywords
- Organized by artist/uploader name

**Videos**:
- Duration > 15 minutes
- Keywords: video, vlog, tutorial, gameplay, review, movie, film
- Stored in Videos/Unsorted

**Podcasts**:
- Keywords: podcast, episode, interview
- Organized by show/uploader name in Podcasts/[Show Name]/

**Audiobooks**:
- Keywords: audiobook, chapter, narrated
- Stored in Audiobooks/

## Commands

### download
Downloads and organizes media from a URL.

```bash
/media download <url> [format]
```

**Supported formats:**
- `mp3` (default) - Most compatible
- `m4a` - High quality, Apple devices
- `flac` - Lossless quality
- `wav` - Uncompressed

**Examples:**
```bash
# Download as MP3 (default)
/media download https://youtube.com/watch?v=NKXSkW1HJ8I

# Download as FLAC for high quality
/media download https://youtube.com/watch?v=... flac

# Download as video (auto-detected if duration > 15 min)
/media download https://youtube.com/watch?v=...
```

### organize
Moves an existing file into the media vault with proper organization.

```bash
/media organize <filepath>
```

**Examples:**
```bash
# Organize a downloaded file
/media organize ~/Downloads/song.mp3

# Organize from current directory
/media organize "Just For the Night.mp3"
```

### list
Shows a summary of your media vault contents.

```bash
/media list
```

**Output:**
```
📚 Media Vault Contents:

🎵 Music:
  Files: 42

🎬 Videos:
  Files: 5

🎙️ Podcasts:
  Files: 12

📖 Audiobooks:
  Files: 3
```

## Features

### Intelligent Organization
- Analyzes video metadata (title, uploader, duration, categories, description)
- Automatically categorizes content
- Creates artist/show folders automatically
- Cleans filenames (removes special characters)

### Format Support
- Audio: MP3, M4A, FLAC, WAV
- Video: MP4, MKV, AVI, MOV (auto-detected)

### Safe Operations
- Creates directory structure automatically
- Cleans filenames for filesystem compatibility
- Preserves original quality when possible

## Examples

### Music Download
```bash
# Download a song
/media download https://youtube.com/watch?v=NKXSkW1HJ8I

# Result:
# 📥 Analyzing URL and determining organization...
# 📂 Type: music
# 📁 Destination: ~/Desktop/mediavault/Music/[Artist]
# 🎵 Title: Just For the Night
# 🎵 Downloading audio as mp3...
# ✅ Downloaded and organized in: ~/Desktop/mediavault/Music/[Artist]
```

### Podcast Download
```bash
# Download a podcast episode
/media download https://youtube.com/watch?v=podcast-episode

# Auto-organized to:
# ~/Desktop/mediavault/Podcasts/[Podcast Name]/episode.mp3
```

### Video Download
```bash
# Long video (auto-detected as video)
/media download https://youtube.com/watch?v=long-tutorial

# Auto-organized to:
# ~/Desktop/mediavault/Videos/Unsorted/tutorial.mp4
```

### Batch Organization
```bash
# Organize multiple downloaded files
cd ~/Downloads
/media organize song1.mp3
/media organize song2.mp3
/media organize podcast.mp3
```

## Technical Details

### Dependencies
- `yt-dlp` - Media downloader
- `ffmpeg` - Audio conversion (installed with yt-dlp)

### Location
- Script: `~/.claude/skills/media.sh`
- Vault: `~/Desktop/mediavault/`

### Metadata Analysis
The command extracts and analyzes:
- Title
- Uploader/Artist name
- Duration
- Categories
- Description

Uses this information to intelligently determine:
- Content type (music/video/podcast/audiobook)
- Target folder
- Organization structure

## Troubleshooting

### yt-dlp not found
Install yt-dlp:
```bash
brew install yt-dlp
# or
pip install yt-dlp
```

### Wrong organization
Manually move files:
```bash
mv ~/Desktop/mediavault/Music/Artist/file.mp3 ~/Desktop/mediavault/Podcasts/Show/
```

### File already exists
The command will not overwrite existing files. Rename or remove the existing file first.

## Future Enhancements

Potential improvements:
- Playlist support (download entire playlists)
- Metadata editing (ID3 tags)
- Duplicate detection
- Custom organization rules
- Batch operations
- Integration with music libraries (iTunes, Music.app)
