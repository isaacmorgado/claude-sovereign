# SPLICE Enhancement: Custom Razor API via XML Workflow

## Problem Statement

Current SPLICE Slice 8 limitations:
1. **Only detects speech gaps** - Uses Whisper segments, not actual audio silence
2. **Can only DISABLE clips** - Cannot split clips that span speech+silence
3. **Requires pre-cut timeline** - Status shows: "Try cutting timeline first"

**Goal:** Add actual razor/split capability using the XML export/modify/import workflow proven by commercial tools (TimeBolt, Recut, AutoPod).

---

## Existing SPLICE Architecture

```
SPLICE/
├── splice-plugin/                    # UXP Plugin
│   ├── manifest.json                # Already configured for PPro 25.6+
│   ├── index.html                   # UI with silence section
│   └── js/
│       ├── config.js                # BACKEND_URL, WAV_PATH, TICKS_PER_SECOND
│       ├── utils.js                 # formatTime(), getActiveSequence(), setStatus()
│       ├── slice1-timeline.js       # Read clips
│       ├── slice3-export.js         # Export WAV
│       ├── slice6-analyze.js        # Transcription + takes
│       ├── slice7-apply.js          # Label + disable
│       ├── slice8-silence.js        # Current silence (gap detection only)
│       └── main.js                  # Initialize all slices
│
└── splice-backend/                  # Node.js HTTPS Server (port 3847)
    ├── server.js                    # Express routes
    └── services/
        ├── transcription.js         # Groq Whisper
        ├── takeDetection.js         # GPT-4o-mini
        └── silenceDetection.js      # Gap analysis (segments only)
```

---

## Integration Plan

### New Components to Add

```
splice-backend/services/
├── ffprobeSilence.js          # NEW: FFprobe silencedetect (actual audio analysis)
└── xmlProcessor.js            # NEW: FCP XML manipulation

splice-plugin/js/
└── slice9-razor.js            # NEW: XML-based razor workflow
```

---

## Implementation Steps

### Phase 1: Backend - FFprobe Silence Detection

**File:** `splice-backend/services/ffprobeSilence.js`

Add true audio-based silence detection using FFprobe:

```javascript
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

async function detectAudioSilences(wavPath, options = {}) {
  const {
    threshold = -30,      // dB threshold (recommended: -30 to -40)
    minDuration = 0.5,    // Minimum silence duration in seconds
    padding = 0.1         // Buffer around detected silences
  } = options;

  const cmd = `ffprobe -v quiet -f lavfi -i "amovie='${wavPath}',silencedetect=n=${threshold}dB:d=${minDuration}" -show_entries frame_tags -of json 2>&1`;

  const { stdout, stderr } = await execAsync(cmd);

  // Parse silencedetect output
  const silences = parseFFprobeOutput(stderr, padding);
  return silences;
}
```

**New endpoint in server.js:**
```javascript
POST /silences-audio
{ wavPath, threshold: -30, minDuration: 0.5, padding: 0.1 }
→ { silences: [{start, end, duration}], count, totalDuration }
```

### Phase 2: Backend - XML Processor

**File:** `splice-backend/services/xmlProcessor.js`

FCP XML manipulation using fast-xml-parser:

```javascript
const { XMLParser, XMLBuilder } = require('fast-xml-parser');

class FCPXMLProcessor {
  constructor() {
    this.parserOptions = {
      ignoreAttributes: false,
      attributeNamePrefix: "@_",
      parseAttributeValue: false
    };
    this.parser = new XMLParser(this.parserOptions);
    this.builder = new XMLBuilder(this.parserOptions);
  }

  parse(xmlString) { ... }

  splitClipsAtSilences(silences) { ... }

  removeGaps() { ... }

  serialize() { ... }
}
```

**New endpoint:**
```javascript
POST /process-xml
{ xmlPath, silences, removeGaps: true }
→ { outputPath, clipsCreated, gapsRemoved }
```

### Phase 3: Plugin - XML Export/Import

**File:** `splice-plugin/js/slice9-razor.js`

```javascript
/**
 * Slice 9: XML-Based Razor (Custom Razor API)
 *
 * Workflow:
 * 1. Export sequence to FCP XML
 * 2. Send XML + silences to backend for processing
 * 3. Import processed XML as new sequence
 */

async function exportSequenceXML() {
  // Uses ExtendScript bridge or UXP export API
  // Saves to /tmp/splice_export.xml
}

async function processAndImport() {
  // 1. Get silences (from current detection or new FFprobe analysis)
  // 2. POST /process-xml with XML path and silences
  // 3. Import processed XML as new sequence
}
```

### Phase 4: UI Enhancement

**File:** `splice-plugin/index.html`

Add to silence section:
```html
<!-- After existing silence controls -->
<div id="razorSection" style="display: none; margin-top: 10px;">
  <p style="font-size: 11px; color: #888; margin-bottom: 8px;">
    Advanced: Split clips at silence boundaries
  </p>
  <button id="razorSilencesBtn" style="background: #6f42c1; width: 100%;">
    Razor & Remove Silences
  </button>
</div>
```

---

## Data Flow

```
Current Flow (Slice 8):
Timeline → Whisper → Gap Detection → Disable Clips (limited)

New Flow (Slice 9):
Timeline → WAV Export → FFprobe silencedetect → Actual silence timestamps
                ↓
        Export FCP XML → XML Processor → Split clips in XML → Remove gaps
                                                ↓
                                    Import as New Sequence (clean cuts)
```

---

## Files to Modify

| File | Changes |
|------|---------|
| `splice-backend/package.json` | Add `fast-xml-parser` dependency |
| `splice-backend/server.js` | Add `/silences-audio` and `/process-xml` routes |
| `splice-backend/services/ffprobeSilence.js` | **NEW** - FFprobe silence detection |
| `splice-backend/services/xmlProcessor.js` | **NEW** - FCP XML manipulation |
| `splice-plugin/js/slice9-razor.js` | **NEW** - XML export/import workflow |
| `splice-plugin/js/main.js` | Initialize Slice 9 |
| `splice-plugin/index.html` | Add Razor button to silence section |
| `splice-plugin/js/config.js` | Add XML_PATH constant |

---

## Technical Details

### FCP XML Time Format
```javascript
// Premiere exports rational time: "1001/30000s" for 29.97fps
function toSeconds(timeStr) {
  const match = timeStr.match(/^(\d+)\/(\d+)s$/);
  return match ? parseInt(match[1]) / parseInt(match[2]) : 0;
}

// Convert back for XML output
function fromSeconds(seconds, fps = 29.97) {
  if (fps === 29.97) {
    const frames = Math.round(seconds * 30000 / 1001);
    return `${frames * 1001}/30000s`;
  }
  // Handle other frame rates...
}
```

### FFprobe Silence Output
```
[silencedetect @ 0x...] silence_start: 1.234
[silencedetect @ 0x...] silence_end: 2.567 | silence_duration: 1.333
```

### Clip Splitting Algorithm
```
Original clip: [========SILENCE========]
               0s       2s     4s      6s

After split:   [====]         [========]
               0-2s           4-6s

Gap removed:   [====][========]
               0-2s  2-4s
```

---

## Dependencies

**Backend (add to package.json):**
```json
{
  "dependencies": {
    "fast-xml-parser": "^4.3.0"
  }
}
```

**System Requirements:**
- FFprobe installed (part of FFmpeg) - `brew install ffmpeg`
- Premiere Pro 25.6+ (for UXP)

---

## User Workflow

1. Open sequence in Premiere Pro
2. **Read Clips** → **Export Audio** → **Analyze** (existing flow)
3. **Detect Silences** (now using FFprobe for actual audio analysis)
4. Adjust threshold with slider
5. Click **"Razor & Remove Silences"** (new button)
6. New sequence created with:
   - Clips split at silence boundaries
   - Silent portions removed
   - Timeline collapsed (no gaps)
7. Original sequence preserved for undo

---

## Comparison: Current vs New

| Feature | Current (Slice 8) | New (Slice 9) |
|---------|-------------------|---------------|
| Detection method | Whisper segment gaps | FFprobe silencedetect |
| Detects actual silence | No (only speech gaps) | Yes (audio level) |
| Can split clips | No | Yes (via XML) |
| Removes silence | Disables clips | Creates new sequence |
| Works on any clip | Only pre-cut clips | Any clip |
| Preserves original | Yes (just disables) | Yes (new sequence) |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| FFprobe not installed | Check at startup, show install instructions |
| XML export fails | Fallback to ExtendScript bridge |
| Large files slow | Progress indicator, chunk processing |
| Time precision loss | Use rational numbers, test with 29.97fps |

---

## Future Enhancements

- [ ] Preview mode (show cuts before applying)
- [ ] Undo within plugin (track original sequence)
- [ ] Batch process multiple sequences
- [ ] Custom dB threshold per frequency range
- [ ] Keep audio below threshold (for background music)

---

## Sources

- [FFmpeg silencedetect](https://ffmpeg.org/ffmpeg-filters.html#silencedetect)
- [fast-xml-parser](https://github.com/NaturalIntelligence/fast-xml-parser)
- [FCPXML Reference](https://developer.apple.com/documentation/professional-video-applications/fcpxml-reference)
- [Adobe UXP API](https://developer.adobe.com/premiere-pro/uxp/)
- Research from agents: a34d36e, a2d738f, ae201b1, ac75ba2, a763956, aca7df6, aeb6549
