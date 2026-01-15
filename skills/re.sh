#!/bin/bash
# Reverse Engineering Skill - Automated RE Operations
# Executable skill that performs actual RE tasks, not just documentation
#
# Usage:
#   re.sh chrome <path.crx>           - Extract and analyze Chrome extension
#   re.sh electron <app.app>          - Extract Electron app source
#   re.sh deobfuscate <file.js>       - Beautify/deobfuscate JavaScript
#   re.sh macos <app.app>             - Explore macOS app bundle
#   re.sh api <url>                   - Start API reverse engineering
#   re.sh analyze <path>              - Auto-detect target type and analyze

set -uo pipefail

# Configuration
RE_OUTPUT_DIR="${RE_OUTPUT_DIR:-${HOME}/Desktop/re-output}"
RE_LOG_FILE="${HOME}/.claude/logs/re-skill.log"
RE_CACHE_DIR="${HOME}/.claude/.re-cache"

# Colors for output (optional, falls back gracefully)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    local level="${2:-INFO}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" >> "$RE_LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log "$1" "INFO"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
    log "$1" "SUCCESS"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    log "$1" "WARN"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    log "$1" "ERROR"
}

# Initialize directories
init() {
    mkdir -p "$RE_OUTPUT_DIR" "$RE_CACHE_DIR" "$(dirname "$RE_LOG_FILE")"
    log "RE Skill initialized" "INIT"
}

# =============================================================================
# CHROME EXTENSION EXTRACTION
# =============================================================================

extract_chrome_extension() {
    local source="$1"
    local output_name="${2:-}"

    # Validate input
    if [[ ! -e "$source" ]]; then
        error "Source not found: $source"
        return 1
    fi

    # Determine source type and set output name
    local ext_id=""
    local output_dir=""

    if [[ -f "$source" && "$source" == *.crx ]]; then
        # CRX file
        local basename
        basename=$(basename "$source" .crx)
        output_name="${output_name:-$basename}"
        output_dir="$RE_OUTPUT_DIR/chrome-extensions/$output_name"

        info "Extracting CRX file: $source"
        extract_crx_file "$source" "$output_dir"

    elif [[ -d "$source" ]]; then
        # Already extracted extension directory
        output_name="${output_name:-$(basename "$source")}"
        output_dir="$RE_OUTPUT_DIR/chrome-extensions/$output_name"

        info "Copying extension directory: $source"
        mkdir -p "$output_dir"
        cp -R "$source/"* "$output_dir/"

    elif [[ "$source" =~ ^[a-z]{32}$ ]]; then
        # Extension ID - find in Chrome directory
        ext_id="$source"
        local chrome_ext_dir="${HOME}/Library/Application Support/Google/Chrome/Default/Extensions"

        if [[ -d "$chrome_ext_dir/$ext_id" ]]; then
            # Find latest version
            local latest_version
            latest_version=$(ls -1 "$chrome_ext_dir/$ext_id" | sort -V | tail -1)
            source="$chrome_ext_dir/$ext_id/$latest_version"
            output_name="${output_name:-ext-$ext_id}"
            output_dir="$RE_OUTPUT_DIR/chrome-extensions/$output_name"

            info "Found installed extension: $ext_id (version $latest_version)"
            mkdir -p "$output_dir"
            cp -R "$source/"* "$output_dir/"
        else
            error "Extension not found: $ext_id"
            echo "Available extensions:"
            ls -1 "$chrome_ext_dir" 2>/dev/null | head -10
            return 1
        fi
    else
        error "Unknown source type: $source"
        echo "Supported: .crx file, extension directory, or 32-char extension ID"
        return 1
    fi

    # Analyze the extension
    analyze_chrome_extension "$output_dir"
}

extract_crx_file() {
    local crx_file="$1"
    local output_dir="$2"

    mkdir -p "$output_dir"

    # Try direct unzip first (works for CRX3)
    if unzip -q "$crx_file" -d "$output_dir" 2>/dev/null; then
        success "Extracted via direct unzip"
        return 0
    fi

    # CRX files have a header - try stripping it
    # CRX2: 16 bytes + public key + signature
    # CRX3: 12 bytes + header length + header

    local temp_zip
    temp_zip=$(mktemp)

    # Try CRX3 format first (most common now)
    # Magic (4) + Version (4) + Header length (4) + Header
    local magic
    magic=$(xxd -l 4 -p "$crx_file")

    if [[ "$magic" == "43723234" ]]; then  # "Cr24"
        # Read header length (little-endian uint32 at offset 8)
        local header_len
        header_len=$(xxd -s 8 -l 4 -e "$crx_file" 2>/dev/null | awk '{print $2}')
        header_len=$((16#${header_len:-0}))

        # Skip: magic(4) + version(4) + header_len(4) + header
        local skip=$((12 + header_len))

        tail -c "+$((skip + 1))" "$crx_file" > "$temp_zip"

        if unzip -q "$temp_zip" -d "$output_dir" 2>/dev/null; then
            rm -f "$temp_zip"
            success "Extracted CRX3 format"
            return 0
        fi
    fi

    # Try CRX2 format
    # Magic (4) + Version (4) + Public key length (4) + Signature length (4)
    local pubkey_len sig_len
    pubkey_len=$(xxd -s 8 -l 4 -e "$crx_file" 2>/dev/null | awk '{print $2}')
    sig_len=$(xxd -s 12 -l 4 -e "$crx_file" 2>/dev/null | awk '{print $2}')
    pubkey_len=$((16#${pubkey_len:-0}))
    sig_len=$((16#${sig_len:-0}))

    local skip=$((16 + pubkey_len + sig_len))
    tail -c "+$((skip + 1))" "$crx_file" > "$temp_zip"

    if unzip -q "$temp_zip" -d "$output_dir" 2>/dev/null; then
        rm -f "$temp_zip"
        success "Extracted CRX2 format"
        return 0
    fi

    rm -f "$temp_zip"

    # Last resort: try renaming to .zip
    local zip_copy
    zip_copy=$(mktemp).zip
    cp "$crx_file" "$zip_copy"

    if unzip -q "$zip_copy" -d "$output_dir" 2>/dev/null; then
        rm -f "$zip_copy"
        success "Extracted by renaming to .zip"
        return 0
    fi

    rm -f "$zip_copy"
    error "Failed to extract CRX file"
    return 1
}

analyze_chrome_extension() {
    local ext_dir="$1"

    info "Analyzing Chrome extension at: $ext_dir"

    local manifest="$ext_dir/manifest.json"
    local analysis_file="$ext_dir/_RE_ANALYSIS.json"

    if [[ ! -f "$manifest" ]]; then
        error "No manifest.json found in $ext_dir"
        return 1
    fi

    # Parse manifest
    local ext_name ext_version ext_description permissions background_scripts content_scripts
    ext_name=$(jq -r '.name // "Unknown"' "$manifest")
    ext_version=$(jq -r '.version // "Unknown"' "$manifest")
    ext_description=$(jq -r '.description // ""' "$manifest")
    permissions=$(jq -c '.permissions // []' "$manifest")

    # Get background scripts (MV2 vs MV3)
    local manifest_version
    manifest_version=$(jq -r '.manifest_version // 2' "$manifest")

    if [[ "$manifest_version" == "3" ]]; then
        background_scripts=$(jq -c '.background.service_worker // ""' "$manifest")
    else
        background_scripts=$(jq -c '.background.scripts // []' "$manifest")
    fi

    content_scripts=$(jq -c '[.content_scripts[]?.js[]?] // []' "$manifest")

    # List all files
    local all_files
    all_files=$(find "$ext_dir" -type f -name "*.js" -o -name "*.html" -o -name "*.css" | sort)
    local file_count
    file_count=$(echo "$all_files" | wc -l | tr -d ' ')

    # Count JS files and estimate lines
    local js_files js_loc
    js_files=$(find "$ext_dir" -name "*.js" | wc -l | tr -d ' ')
    js_loc=$(find "$ext_dir" -name "*.js" -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')

    # Check for suspicious patterns
    local suspicious_patterns=""
    if grep -rq "eval(" "$ext_dir" 2>/dev/null; then
        suspicious_patterns="$suspicious_patterns,eval"
    fi
    if grep -rq "Function(" "$ext_dir" 2>/dev/null; then
        suspicious_patterns="$suspicious_patterns,Function"
    fi
    if grep -rq "chrome.webRequest" "$ext_dir" 2>/dev/null; then
        suspicious_patterns="$suspicious_patterns,webRequest"
    fi
    suspicious_patterns="${suspicious_patterns#,}"

    # Generate analysis JSON
    cat > "$analysis_file" << EOF
{
  "extension": {
    "name": "$ext_name",
    "version": "$ext_version",
    "description": "$ext_description",
    "manifestVersion": $manifest_version
  },
  "permissions": $permissions,
  "scripts": {
    "background": $background_scripts,
    "contentScripts": $content_scripts
  },
  "stats": {
    "totalFiles": $file_count,
    "jsFiles": $js_files,
    "estimatedLoc": $js_loc
  },
  "security": {
    "suspiciousPatterns": "$(echo "$suspicious_patterns" | tr ',' ', ')"
  },
  "outputDir": "$ext_dir",
  "analyzedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    success "Extension extracted and analyzed"
    echo ""
    echo "=== CHROME EXTENSION ANALYSIS ==="
    echo "Name: $ext_name (v$ext_version)"
    echo "Manifest Version: $manifest_version"
    echo "Permissions: $(echo "$permissions" | jq -r 'join(", ")')"
    echo "JS Files: $js_files ($js_loc lines)"
    [[ -n "$suspicious_patterns" ]] && warn "Suspicious patterns: $suspicious_patterns"
    echo ""
    echo "Output: $ext_dir"
    echo "Analysis: $analysis_file"
    echo ""

    # Output JSON for programmatic consumption
    cat "$analysis_file"
}

# =============================================================================
# ELECTRON APP EXTRACTION
# =============================================================================

extract_electron_app() {
    local app_path="$1"
    local output_name="${2:-}"

    # Validate input
    if [[ ! -d "$app_path" ]]; then
        error "App not found: $app_path"
        return 1
    fi

    # Determine app name
    local app_name
    app_name=$(basename "$app_path" .app)
    output_name="${output_name:-$app_name}"
    local output_dir="$RE_OUTPUT_DIR/electron-apps/$output_name"

    info "Extracting Electron app: $app_name"

    # Find ASAR file
    local resources_dir="$app_path/Contents/Resources"
    local asar_file=""

    if [[ -f "$resources_dir/app.asar" ]]; then
        asar_file="$resources_dir/app.asar"
    elif [[ -f "$resources_dir/app.asar.unpacked" ]]; then
        # Already unpacked
        output_dir="$RE_OUTPUT_DIR/electron-apps/$output_name"
        mkdir -p "$output_dir"
        cp -R "$resources_dir/app.asar.unpacked/"* "$output_dir/"
        info "Copied unpacked ASAR"
    elif [[ -d "$resources_dir/app" ]]; then
        # No ASAR, direct app folder
        output_dir="$RE_OUTPUT_DIR/electron-apps/$output_name"
        mkdir -p "$output_dir"
        cp -R "$resources_dir/app/"* "$output_dir/"
        info "Copied direct app folder"
    else
        error "No app.asar or app folder found in $resources_dir"
        echo "Contents of Resources:"
        ls -la "$resources_dir" 2>/dev/null | head -20
        return 1
    fi

    # Extract ASAR if found
    if [[ -n "$asar_file" && -f "$asar_file" ]]; then
        mkdir -p "$output_dir"

        # Check if asar CLI is available
        if command -v asar &>/dev/null; then
            info "Extracting with asar CLI..."
            asar extract "$asar_file" "$output_dir"
        elif command -v npx &>/dev/null; then
            info "Extracting with npx @electron/asar..."
            npx @electron/asar extract "$asar_file" "$output_dir" 2>/dev/null
        else
            error "ASAR extraction requires 'asar' CLI or npx"
            echo "Install with: npm install -g @electron/asar"
            return 1
        fi
    fi

    # Analyze the extracted app
    analyze_electron_app "$output_dir" "$app_path"
}

analyze_electron_app() {
    local app_dir="$1"
    local original_path="$2"

    info "Analyzing Electron app at: $app_dir"

    local package_json="$app_dir/package.json"
    local analysis_file="$app_dir/_RE_ANALYSIS.json"

    if [[ ! -f "$package_json" ]]; then
        warn "No package.json found - limited analysis available"
        # Create minimal analysis
        cat > "$analysis_file" << EOF
{
  "app": {
    "name": "$(basename "$app_dir")",
    "main": "unknown"
  },
  "stats": {
    "jsFiles": $(find "$app_dir" -name "*.js" 2>/dev/null | wc -l | tr -d ' ')
  },
  "outputDir": "$app_dir",
  "analyzedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
        cat "$analysis_file"
        return 0
    fi

    # Parse package.json
    local app_name app_version main_entry electron_version
    app_name=$(jq -r '.name // "Unknown"' "$package_json")
    app_version=$(jq -r '.version // "Unknown"' "$package_json")
    main_entry=$(jq -r '.main // "index.js"' "$package_json")
    electron_version=$(jq -r '.devDependencies.electron // .dependencies.electron // "Unknown"' "$package_json")

    # Get dependencies
    local deps
    deps=$(jq -c '.dependencies // {}' "$package_json")
    local dep_count
    dep_count=$(echo "$deps" | jq 'keys | length')

    # File stats
    local js_files js_loc
    js_files=$(find "$app_dir" -name "*.js" 2>/dev/null | wc -l | tr -d ' ')
    js_loc=$(find "$app_dir" -name "*.js" -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')

    # Check for interesting patterns
    local has_preload has_ipc
    has_preload=$(grep -rq "preload" "$package_json" 2>/dev/null && echo "true" || echo "false")
    has_ipc=$(grep -rql "ipcMain\|ipcRenderer" "$app_dir" 2>/dev/null && echo "true" || echo "false")

    # Get main entry content summary
    local main_file="$app_dir/$main_entry"
    local main_summary=""
    if [[ -f "$main_file" ]]; then
        main_summary=$(head -50 "$main_file" | grep -E "(BrowserWindow|app\.|ipc)" | head -5 | tr '\n' ' ')
    fi

    # Generate analysis
    cat > "$analysis_file" << EOF
{
  "app": {
    "name": "$app_name",
    "version": "$app_version",
    "electronVersion": "$electron_version",
    "mainEntry": "$main_entry"
  },
  "dependencies": {
    "count": $dep_count,
    "list": $deps
  },
  "stats": {
    "jsFiles": $js_files,
    "estimatedLoc": $js_loc
  },
  "security": {
    "hasPreload": $has_preload,
    "usesIPC": $has_ipc
  },
  "originalPath": "$original_path",
  "outputDir": "$app_dir",
  "analyzedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    success "Electron app extracted and analyzed"
    echo ""
    echo "=== ELECTRON APP ANALYSIS ==="
    echo "Name: $app_name (v$app_version)"
    echo "Electron: $electron_version"
    echo "Main Entry: $main_entry"
    echo "Dependencies: $dep_count packages"
    echo "JS Files: $js_files ($js_loc lines)"
    echo "IPC Usage: $has_ipc | Preload: $has_preload"
    echo ""
    echo "Output: $app_dir"
    echo "Analysis: $analysis_file"
    echo ""

    cat "$analysis_file"
}

# =============================================================================
# JAVASCRIPT DEOBFUSCATION
# =============================================================================

deobfuscate_js() {
    local input_file="$1"
    local output_file="${2:-}"

    if [[ ! -f "$input_file" ]]; then
        error "File not found: $input_file"
        return 1
    fi

    local basename
    basename=$(basename "$input_file" .js)
    basename=$(basename "$basename" .min)
    output_file="${output_file:-$RE_OUTPUT_DIR/deobfuscated/${basename}.beautified.js}"

    mkdir -p "$(dirname "$output_file")"

    info "Deobfuscating: $input_file"

    # Try js-beautify first
    if command -v js-beautify &>/dev/null; then
        js-beautify -f "$input_file" -o "$output_file" 2>/dev/null
        if [[ -f "$output_file" ]]; then
            success "Beautified with js-beautify"
        fi
    elif command -v npx &>/dev/null; then
        npx js-beautify -f "$input_file" -o "$output_file" 2>/dev/null
        if [[ -f "$output_file" ]]; then
            success "Beautified with npx js-beautify"
        fi
    else
        # Fallback: basic formatting with sed
        warn "js-beautify not found, using basic formatting"
        # Basic beautification
        cat "$input_file" | \
            sed 's/;/;\n/g' | \
            sed 's/{/{\n/g' | \
            sed 's/}/\n}\n/g' > "$output_file"
    fi

    if [[ ! -f "$output_file" ]]; then
        error "Deobfuscation failed"
        return 1
    fi

    # Analyze the code
    local analysis_file="${output_file%.js}.analysis.json"
    analyze_js_file "$input_file" "$output_file" "$analysis_file"

    echo ""
    echo "=== DEOBFUSCATION COMPLETE ==="
    echo "Input: $input_file"
    echo "Output: $output_file"
    echo "Analysis: $analysis_file"
    echo ""

    cat "$analysis_file"
}

analyze_js_file() {
    local original="$1"
    local beautified="$2"
    local analysis_file="$3"

    local orig_size=$(wc -c < "$original" | tr -d ' ')
    local orig_lines=$(wc -l < "$original" | tr -d ' ')
    local new_lines=$(wc -l < "$beautified" | tr -d ' ')

    # Find patterns
    local has_eval has_function_ctor urls_found api_endpoints
    has_eval=$(grep -c "eval(" "$beautified" 2>/dev/null || echo 0)
    has_function_ctor=$(grep -c "Function(" "$beautified" 2>/dev/null || echo 0)
    urls_found=$(grep -oE 'https?://[^"'"'"' ]+' "$beautified" 2>/dev/null | sort -u | head -20 || echo "")
    api_endpoints=$(grep -oE '/api/[^"'"'"' ]+' "$beautified" 2>/dev/null | sort -u | head -20 || echo "")

    # Build URL array
    local urls_json="[]"
    if [[ -n "$urls_found" ]]; then
        urls_json=$(echo "$urls_found" | jq -R -s 'split("\n") | map(select(length > 0))')
    fi

    local apis_json="[]"
    if [[ -n "$api_endpoints" ]]; then
        apis_json=$(echo "$api_endpoints" | jq -R -s 'split("\n") | map(select(length > 0))')
    fi

    cat > "$analysis_file" << EOF
{
  "file": {
    "original": "$original",
    "beautified": "$beautified"
  },
  "stats": {
    "originalSize": $orig_size,
    "originalLines": $orig_lines,
    "beautifiedLines": $new_lines,
    "expansionRatio": $(echo "scale=2; $new_lines / ($orig_lines + 1)" | bc 2>/dev/null || echo "0")
  },
  "patterns": {
    "evalCalls": $has_eval,
    "functionConstructor": $has_function_ctor,
    "urlsFound": $urls_json,
    "apiEndpoints": $apis_json
  },
  "analyzedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

# =============================================================================
# MACOS APP EXPLORATION
# =============================================================================

explore_macos_app() {
    local app_path="$1"
    local output_name="${2:-}"

    if [[ ! -d "$app_path" ]]; then
        error "App not found: $app_path"
        return 1
    fi

    local app_name
    app_name=$(basename "$app_path" .app)
    output_name="${output_name:-$app_name}"
    local output_dir="$RE_OUTPUT_DIR/macos-apps/$output_name"

    mkdir -p "$output_dir"

    info "Exploring macOS app: $app_name"

    local contents_dir="$app_path/Contents"
    local info_plist="$contents_dir/Info.plist"
    local analysis_file="$output_dir/_RE_ANALYSIS.json"

    # Parse Info.plist
    local bundle_id bundle_version bundle_name executable
    if [[ -f "$info_plist" ]]; then
        bundle_id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$info_plist" 2>/dev/null || echo "Unknown")
        bundle_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$info_plist" 2>/dev/null || echo "Unknown")
        bundle_name=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "$info_plist" 2>/dev/null || echo "$app_name")
        executable=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$info_plist" 2>/dev/null || echo "")

        # Copy Info.plist for analysis
        cp "$info_plist" "$output_dir/Info.plist"
        # Convert to JSON for easier parsing
        plutil -convert json -o "$output_dir/Info.json" "$info_plist" 2>/dev/null || true
    else
        bundle_id="Unknown"
        bundle_version="Unknown"
        bundle_name="$app_name"
        executable=""
    fi

    # List resources
    local resources_dir="$contents_dir/Resources"
    local resource_count=0
    local resource_types=""
    if [[ -d "$resources_dir" ]]; then
        resource_count=$(find "$resources_dir" -type f | wc -l | tr -d ' ')
        resource_types=$(find "$resources_dir" -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10 | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
    fi

    # List frameworks
    local frameworks_dir="$contents_dir/Frameworks"
    local frameworks="[]"
    if [[ -d "$frameworks_dir" ]]; then
        frameworks=$(ls -1 "$frameworks_dir" 2>/dev/null | jq -R -s 'split("\n") | map(select(length > 0))')
    fi

    # Check for Electron
    local is_electron="false"
    if [[ -f "$resources_dir/app.asar" ]] || [[ -d "$resources_dir/app" ]] || ls "$frameworks_dir" 2>/dev/null | grep -q "Electron"; then
        is_electron="true"
    fi

    # Get executable info
    local exec_path="$contents_dir/MacOS/$executable"
    local exec_type=""
    local exec_arch=""
    if [[ -f "$exec_path" ]]; then
        exec_type=$(file "$exec_path" | cut -d: -f2 | xargs)
        exec_arch=$(file "$exec_path" | grep -oE "(arm64|x86_64)" | head -1 || echo "unknown")
    fi

    # Get URL schemes
    local url_schemes="[]"
    if [[ -f "$info_plist" ]]; then
        url_schemes=$(/usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes" "$info_plist" 2>/dev/null | grep -A1 "CFBundleURLSchemes" | tail -1 | tr -d ' ' | jq -R 'split(",") | map(select(length > 0))' 2>/dev/null || echo '[]')
    fi

    # Generate analysis
    cat > "$analysis_file" << EOF
{
  "app": {
    "name": "$bundle_name",
    "bundleId": "$bundle_id",
    "version": "$bundle_version",
    "executable": "$executable",
    "isElectron": $is_electron
  },
  "binary": {
    "path": "$exec_path",
    "type": "$exec_type",
    "architecture": "$exec_arch"
  },
  "resources": {
    "count": $resource_count,
    "types": "$(echo "$resource_types" | tr ',' ', ')"
  },
  "frameworks": $frameworks,
  "urlSchemes": $url_schemes,
  "originalPath": "$app_path",
  "outputDir": "$output_dir",
  "analyzedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    # Create directory structure overview
    echo "=== DIRECTORY STRUCTURE ===" > "$output_dir/STRUCTURE.txt"
    find "$app_path" -type d -maxdepth 4 2>/dev/null >> "$output_dir/STRUCTURE.txt"

    success "macOS app explored"
    echo ""
    echo "=== MACOS APP ANALYSIS ==="
    echo "Name: $bundle_name (v$bundle_version)"
    echo "Bundle ID: $bundle_id"
    echo "Executable: $executable ($exec_arch)"
    echo "Is Electron: $is_electron"
    echo "Resources: $resource_count files ($resource_types)"
    echo "Frameworks: $(echo "$frameworks" | jq -r '. | length') loaded"
    echo ""
    echo "Output: $output_dir"
    echo "Analysis: $analysis_file"
    echo ""

    # Suggest next steps
    if [[ "$is_electron" == "true" ]]; then
        warn "This is an Electron app! Consider running: /re electron $app_path"
    fi

    cat "$analysis_file"
}

# =============================================================================
# API REVERSE ENGINEERING (Starter)
# =============================================================================

start_api_research() {
    local target_url="$1"
    local output_name="${2:-}"

    # Extract domain for output name
    local domain
    domain=$(echo "$target_url" | sed -E 's|https?://||' | cut -d/ -f1)
    output_name="${output_name:-$domain}"
    local output_dir="$RE_OUTPUT_DIR/api-research/$output_name"

    mkdir -p "$output_dir"

    info "Starting API research for: $target_url"

    # Create research template
    local research_file="$output_dir/research.md"
    local config_file="$output_dir/config.json"

    cat > "$research_file" << EOF
# API Research: $domain

## Target
- URL: $target_url
- Date: $(date '+%Y-%m-%d %H:%M:%S')

## Endpoints Discovered
<!-- Add discovered endpoints here -->

| Method | Endpoint | Auth | Notes |
|--------|----------|------|-------|

## Authentication
<!-- Document auth mechanism -->

## Rate Limits
<!-- Document observed rate limits -->

## Request/Response Schemas
<!-- Document data structures -->

## Tools Used
- [ ] mitmproxy
- [ ] DevTools Network tab
- [ ] Postman
- [ ] curl

## Notes

EOF

    cat > "$config_file" << EOF
{
  "target": "$target_url",
  "domain": "$domain",
  "research": {
    "status": "started",
    "endpoints": [],
    "auth": null,
    "rateLimits": null
  },
  "tools": {
    "mitmproxyPort": 8080,
    "proxyConfigured": false
  },
  "outputDir": "$output_dir",
  "startedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

    success "API research initialized"
    echo ""
    echo "=== API RESEARCH STARTED ==="
    echo "Target: $target_url"
    echo "Output: $output_dir"
    echo ""
    echo "Next steps:"
    echo "1. Start proxy: mitmproxy -p 8080"
    echo "2. Configure browser/app to use proxy"
    echo "3. Interact with the target"
    echo "4. Analyze captured traffic"
    echo ""
    echo "Useful commands:"
    echo "  mitmproxy -p 8080 --mode regular"
    echo "  curl -x localhost:8080 -k $target_url"
    echo ""

    cat "$config_file"
}

# =============================================================================
# AUTO-DETECT AND ANALYZE
# =============================================================================

auto_analyze() {
    local path="$1"

    if [[ ! -e "$path" ]]; then
        error "Path not found: $path"
        return 1
    fi

    info "Auto-detecting target type: $path"

    # Check file extension / directory type
    if [[ "$path" == *.crx ]]; then
        extract_chrome_extension "$path"
    elif [[ "$path" == *.app && -d "$path" ]]; then
        # Check if Electron first
        if [[ -f "$path/Contents/Resources/app.asar" ]] || [[ -d "$path/Contents/Resources/app" ]]; then
            info "Detected Electron app"
            extract_electron_app "$path"
        else
            explore_macos_app "$path"
        fi
    elif [[ "$path" == *.js ]]; then
        deobfuscate_js "$path"
    elif [[ "$path" == *.asar ]]; then
        # Direct ASAR file
        local output_dir="$RE_OUTPUT_DIR/electron-apps/$(basename "$path" .asar)"
        mkdir -p "$output_dir"
        if command -v asar &>/dev/null; then
            asar extract "$path" "$output_dir"
        else
            npx @electron/asar extract "$path" "$output_dir"
        fi
        analyze_electron_app "$output_dir" "$path"
    elif [[ -d "$path" ]]; then
        # Check for manifest.json (Chrome extension)
        if [[ -f "$path/manifest.json" ]]; then
            analyze_chrome_extension "$path"
        # Check for package.json (Electron/Node)
        elif [[ -f "$path/package.json" ]]; then
            analyze_electron_app "$path" "$path"
        else
            warn "Unknown directory type"
            echo "Contents:"
            ls -la "$path" | head -20
        fi
    else
        warn "Unknown target type: $path"
        echo "Supported types: .crx, .app, .js, .asar, directories"
    fi
}

# =============================================================================
# HELP / USAGE
# =============================================================================

show_help() {
    cat << 'EOF'
RE Skill - Automated Reverse Engineering

USAGE:
    re.sh <command> <target> [options]

COMMANDS:
    chrome <path>        Extract and analyze Chrome extension
                         Accepts: .crx file, extension directory, or 32-char ID

    electron <app>       Extract Electron app source code
                         Accepts: .app bundle path

    deobfuscate <file>   Beautify/deobfuscate JavaScript file
                         Accepts: .js file path

    macos <app>          Explore macOS application bundle
                         Accepts: .app bundle path

    api <url>            Start API reverse engineering research
                         Creates research template and config

    analyze <path>       Auto-detect target type and analyze
                         Automatically determines extraction method

EXAMPLES:
    re.sh chrome ~/Downloads/extension.crx
    re.sh chrome abcdefghijklmnopqrstuvwxyzabcdef
    re.sh electron /Applications/Discord.app
    re.sh deobfuscate ./bundle.min.js
    re.sh macos /Applications/Slack.app
    re.sh api https://api.example.com/v1
    re.sh analyze ./unknown-target

OUTPUT:
    All output goes to: $RE_OUTPUT_DIR
    Logs: $RE_LOG_FILE

ENVIRONMENT:
    RE_OUTPUT_DIR    Output directory (default: ~/Desktop/re-output)

EOF
}

# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

init

case "${1:-help}" in
    chrome)
        extract_chrome_extension "${2:-}" "${3:-}"
        ;;
    electron)
        extract_electron_app "${2:-}" "${3:-}"
        ;;
    deobfuscate|deobf)
        deobfuscate_js "${2:-}" "${3:-}"
        ;;
    macos)
        explore_macos_app "${2:-}" "${3:-}"
        ;;
    api)
        start_api_research "${2:-}" "${3:-}"
        ;;
    analyze|auto)
        auto_analyze "${2:-}"
        ;;
    help|--help|-h|*)
        show_help
        ;;
esac
