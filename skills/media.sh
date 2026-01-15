#!/bin/bash
# Media Download and Organization Tool
# Downloads media from URLs and organizes them in ~/Desktop/MediaVault_v2

set -euo pipefail

VAULT_DIR="$HOME/Desktop/MediaVault_v2"
MUSIC_DIR="$VAULT_DIR/Music"
VIDEOS_DIR="$VAULT_DIR/Videos"
PODCASTS_DIR="$VAULT_DIR/Podcasts"
AUDIOBOOKS_DIR="$VAULT_DIR/Audiobooks"

# Ensure directory structure exists
mkdir -p "$MUSIC_DIR" "$VIDEOS_DIR" "$PODCASTS_DIR" "$AUDIOBOOKS_DIR"

# Function to clean filename (remove special characters)
clean_filename() {
    echo "$1" | sed 's/[<>:"|?*]//g' | sed 's/  */ /g'
}

# Function to get video metadata
get_metadata() {
    local url="$1"
    yt-dlp --print "%(title)s|%(uploader)s|%(duration)s|%(categories)s|%(description)s" "$url" 2>/dev/null || echo "Unknown|Unknown|0||"
}

# Function to determine media type and organize
organize_media() {
    local url="$1"
    local metadata
    metadata=$(get_metadata "$url")

    local title uploader duration categories description
    IFS='|' read -r title uploader duration categories description <<< "$metadata"

    title=$(clean_filename "$title")
    uploader=$(clean_filename "$uploader")

    # Determine type based on metadata
    local type="music"
    local target_dir="$MUSIC_DIR"

    # Check if it's a video (longer than 15 minutes or has video keywords)
    if [[ "$duration" -gt 900 ]] || echo "$description $title $categories" | grep -iE "(video|vlog|tutorial|gameplay|review|movie|film)" > /dev/null; then
        type="video"
        target_dir="$VIDEOS_DIR"
    fi

    # Check if it's a podcast
    if echo "$description $title $categories $uploader" | grep -iE "(podcast|episode|interview)" > /dev/null; then
        type="podcast"
        target_dir="$PODCASTS_DIR/$uploader"
        mkdir -p "$target_dir"
    fi

    # Check if it's an audiobook
    if echo "$description $title $categories" | grep -iE "(audiobook|chapter|narrated)" > /dev/null; then
        type="audiobook"
        target_dir="$AUDIOBOOKS_DIR"
    fi

    # For music, organize by uploader/artist
    if [[ "$type" == "music" ]]; then
        target_dir="$MUSIC_DIR/$uploader"
        mkdir -p "$target_dir"
    fi

    echo "$type|$target_dir|$title"
}

# Function to download media
download_media() {
    local url="$1"
    local format="${2:-mp3}"

    echo "📥 Analyzing URL and getting metadata..."

    # Get title and uploader
    local title uploader
    title=$(yt-dlp --print "%(title)s" "$url" 2>/dev/null || echo "Unknown")
    uploader=$(yt-dlp --print "%(uploader)s" "$url" 2>/dev/null || echo "Unknown")

    # Clean filenames
    title=$(clean_filename "$title")
    uploader=$(clean_filename "$uploader")

    # Create date-based folder name: YYYY-MM-DD - ARTIST - TITLE
    local today
    today=$(date +%Y-%m-%d)
    local folder_name="$today - $uploader - $title"
    local target_dir="$MUSIC_DIR/$folder_name"

    echo "📂 Creating folder: $folder_name"
    mkdir -p "$target_dir"

    echo "🎵 Downloading audio as $format..."
    yt-dlp -x --audio-format "$format" --audio-quality 0 -o "$target_dir/%(title)s.%(ext)s" "$url"

    echo "✅ Downloaded and organized in: $target_dir"
}

# Function to organize an existing file
organize_existing() {
    local filepath="$1"
    local filename
    filename=$(basename "$filepath")

    # Try to guess the type from filename
    local target_dir="$MUSIC_DIR/Singles"

    if echo "$filename" | grep -iE "(podcast|episode)" > /dev/null; then
        target_dir="$PODCASTS_DIR/Unknown"
    elif echo "$filename" | grep -iE "(audiobook|chapter)" > /dev/null; then
        target_dir="$AUDIOBOOKS_DIR"
    elif echo "$filename" | grep -iE "\.(mp4|mkv|avi|mov)$" > /dev/null; then
        target_dir="$VIDEOS_DIR/Unsorted"
    fi

    mkdir -p "$target_dir"
    mv "$filepath" "$target_dir/"
    echo "✅ Moved to: $target_dir/$filename"
}

# Function to organize downloads folder
organize_downloads() {
    local today
    today=$(date +%Y-%m-%d)

    local music_target="$HOME/Music/Downloads/$today"
    local video_target="$HOME/Videos/Downloads/$today"

    mkdir -p "$music_target" "$video_target"

    local mp3_count=0
    local mp4_count=0
    local mp3_size=0
    local mp4_size=0

    echo "📂 Organizing media from ~/Downloads..."
    echo ""

    # Move MP3 files
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            local filename
            filename=$(basename "$file")
            mv "$file" "$music_target/"
            ((mp3_count++))
            local size
            size=$(stat -f%z "$music_target/$filename" 2>/dev/null || echo 0)
            ((mp3_size+=size))
            echo "  🎵 $filename → Music/Downloads/$today/"
        fi
    done < <(find "$HOME/Downloads" -maxdepth 1 -name "*.mp3" -mtime -1 -print0 2>/dev/null)

    # Move MP4 files
    while IFS= read -r -d '' file; do
        if [[ -f "$file" ]]; then
            local filename
            filename=$(basename "$file")
            mv "$file" "$video_target/"
            ((mp4_count++))
            local size
            size=$(stat -f%z "$video_target/$filename" 2>/dev/null || echo 0)
            ((mp4_size+=size))
            echo "  🎬 $filename → Videos/Downloads/$today/"
        fi
    done < <(find "$HOME/Downloads" -maxdepth 1 -name "*.mp4" -mtime -1 -print0 2>/dev/null)

    echo ""
    if [[ $mp3_count -gt 0 ]] || [[ $mp4_count -gt 0 ]]; then
        echo "✅ Organization complete!"
        echo ""
        [[ $mp3_count -gt 0 ]] && echo "  🎵 Music: $mp3_count files ($(numfmt --to=iec $mp3_size 2>/dev/null || echo "$mp3_size bytes"))"
        [[ $mp4_count -gt 0 ]] && echo "  🎬 Videos: $mp4_count files ($(numfmt --to=iec $mp4_size 2>/dev/null || echo "$mp4_size bytes"))"
        echo ""
        [[ $mp3_count -gt 0 ]] && echo "  📁 Music location: ~/Music/Downloads/$today/"
        [[ $mp4_count -gt 0 ]] && echo "  📁 Video location: ~/Videos/Downloads/$today/"
    else
        echo "ℹ️  No recent MP3 or MP4 files found in ~/Downloads"
    fi
}

# Main logic
case "${1:-}" in
    download)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: media download <url> [format]"
            echo "Format options: mp3 (default), m4a, flac, wav"
            exit 1
        fi
        download_media "$2" "${3:-mp3}"
        ;;
    organize)
        if [[ -z "${2:-}" ]]; then
            # No filepath provided - organize Downloads folder
            organize_downloads
        else
            # Filepath provided - organize specific file
            organize_existing "$2"
        fi
        ;;
    list)
        echo "📚 Media Vault Contents:"
        echo ""
        echo "🎵 Music:"
        find "$MUSIC_DIR" -type f -name "*.mp3" -o -name "*.m4a" -o -name "*.flac" 2>/dev/null | wc -l | xargs echo "  Files:"
        echo ""
        echo "🎬 Videos:"
        find "$VIDEOS_DIR" -type f 2>/dev/null | wc -l | xargs echo "  Files:"
        echo ""
        echo "🎙️ Podcasts:"
        find "$PODCASTS_DIR" -type f 2>/dev/null | wc -l | xargs echo "  Files:"
        echo ""
        echo "📖 Audiobooks:"
        find "$AUDIOBOOKS_DIR" -type f 2>/dev/null | wc -l | xargs echo "  Files:"
        ;;
    *)
        echo "Media Download & Organization Tool"
        echo ""
        echo "Usage:"
        echo "  media download <url> [format]  - Download and organize media"
        echo "  media organize                 - Organize recent downloads (MP3→Music, MP4→Videos)"
        echo "  media organize <filepath>      - Organize a specific file to MediaVault"
        echo "  media list                     - List vault contents"
        echo ""
        echo "Examples:"
        echo "  media download https://youtube.com/watch?v=... mp3"
        echo "  media organize"
        echo "  media organize ~/Downloads/song.mp3"
        ;;
esac
