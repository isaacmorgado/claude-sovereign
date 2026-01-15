# Slice 8: Silence Detection & Removal

## Goal
Detect silent gaps in audio and remove them from the timeline, tightening the edit automatically.

## User Requirements
- **Action**: Remove silences (delete silent sections, ripple clips together)
- **Threshold**: Configurable slider (0.3s - 2.0s), default 0.5s

## Implementation

### 1. Backend: Silence Detection Service
**File**: `splice-backend/services/silenceDetection.js` (new)

```javascript
function detectSilences(segments, threshold = 0.5) {
  const silences = [];
  for (let i = 0; i < segments.length - 1; i++) {
    const gap = segments[i + 1].start - segments[i].end;
    if (gap >= threshold) {
      silences.push({
        start: segments[i].end,
        end: segments[i + 1].start,
        duration: gap
      });
    }
  }
  return silences;
}
```

### 2. Backend: Add Endpoint
**File**: `splice-backend/server.js`

- Add `POST /silences` endpoint
- Accepts `{ wavPath, threshold }`
- Returns `{ silences: [{ start, end, duration }] }`
- Reuse existing Whisper transcription

### 3. Plugin: UI Updates
**File**: `splice-plugin/index.html`

Add to UI:
- Threshold slider: `<input type="range" min="0.3" max="2.0" step="0.1" value="0.5">`
- Label showing current value: `0.5s`
- "Remove Silences" button

### 4. Plugin: Silence Removal Logic
**File**: `splice-plugin/js/slice8-silence.js` (new)

Flow:
1. Get threshold from slider
2. Call `/silences` endpoint
3. For each silence region (process from END to START to avoid time shifts):
   - Find clips that overlap the silence region
   - Use UXP to remove/ripple delete

**Challenge**: UXP may not have ripple delete API. Fallback options:
- Disable clips in silence regions (like Keep Best Takes)
- Set in/out points to exclude silence
- Use `createRemoveAction` if available

### 5. Plugin: Wire Up
**File**: `splice-plugin/js/main.js`

- Import and init slice8-silence.js

## Files to Modify/Create
| File | Action |
|------|--------|
| `splice-backend/services/silenceDetection.js` | Create |
| `splice-backend/server.js` | Add `/silences` endpoint |
| `splice-plugin/index.html` | Add slider + button |
| `splice-plugin/js/slice8-silence.js` | Create |
| `splice-plugin/js/main.js` | Wire up slice8 |

## API Contract
```
POST https://127.0.0.1:3847/silences
Request:  { "wavPath": "/tmp/splice_audio_export.wav", "threshold": 0.5 }
Response: { "silences": [{ "start": 5.2, "end": 6.8, "duration": 1.6 }], "count": 12 }
```

## Open Question
Need to verify if UXP has a clip removal/ripple delete API. If not, we'll disable clips (same approach as Keep Best Takes). I'll check the UXP docs during implementation.
