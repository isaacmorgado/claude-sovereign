# Plan: Smart SPLICE with Take-Aware Silence Removal

## Goal
Single unified workflow that detects BOTH silences AND takes automatically. Uses colored markers to visualize, and intelligently prevents removing silences that overlap with takes (protecting speech content).

## User Requirements
- Single "SPLICE" card (no separate takes card)
- Both detection types run automatically together
- Blue markers = takes (speech segments)
- Red markers = silences to be removed
- Smart filtering: silences overlapping takes are NOT removed (protects speech)
- Settings for takes options in Settings modal

---

## Architecture: Take-Aware Silence Removal

```
Audio Timeline:
|----SILENCE----|---TAKE 1---|--SILENCE--|---TAKE 2---|--SILENCE--|

After Analysis:
|====RED====|---BLUE---|==RED==|---BLUE---|====RED====|
  (remove)    (keep)   (KEEP!)   (keep)     (remove)
                         ↑
              Overlap with take boundary - PROTECTED
```

**Logic:**
1. Detect all silences
2. Detect all takes (via transcription)
3. Filter silences: remove any that overlap with take time ranges
4. Only the "safe" silences (between takes) are marked for removal

---

## Changes

### 1. HTML Changes (index.html)

**Remove:**
- Entire "Detect Takes" action card
- Separate takes options panel

**Single SPLICE card:**
```html
<div class="action-cards">
  <div class="action-card">
    <h2>SPLICE</h2>
    <button id="goBtn" class="go-btn">GO</button>
    <button id="optionsToggle" class="options-toggle">More options</button>
    <div id="optionsPanel" class="options-panel collapsed">
      <div class="slider-container">
        <sp-slider id="sensitivitySlider" min="0" max="100" value="50">
          <sp-label slot="label">Sensitivity</sp-label>
        </sp-slider>
      </div>
      <div class="audio-source-group">
        <sp-label>Audio Source</sp-label>
        <sp-checkbox id="sourceOriginal" checked>Original</sp-checkbox>
        <sp-checkbox id="sourceIsolated">Isolated</sp-checkbox>
      </div>
    </div>
  </div>
</div>
```

**Update preview to show markers with colors:**
```html
<div class="preview-item silence-marker">  <!-- Red styling -->
<div class="preview-item take-marker">     <!-- Blue styling -->
```

**Settings modal - add takes options:**
```html
<div class="setting-group">
  <label>Takes Detection</label>
  <sp-checkbox id="autoMarkBest" checked>Auto-mark best takes</sp-checkbox>
</div>
```

### 2. CSS Changes

**Add marker colors:**
```css
.preview-item.silence-marker {
  border-left-color: #dc3545;  /* Red */
}
.preview-item.take-marker {
  border-left-color: #4a9eff;  /* Blue */
}
.preview-item.protected-silence {
  border-left-color: #ffc107;  /* Yellow - overlaps take */
  opacity: 0.5;
}
```

### 3. JS Changes (main.js)

**Unified workflow:**
```javascript
async function initMainWorkflow() {
  ui.goBtn.addEventListener('click', async () => {
    // 1. Export audio
    await exportAudioInternal();

    // 2. Run BOTH detections in parallel
    const [silences, transcriptResult] = await Promise.all([
      detectSilences(audioPath, params),
      transcribeAudio()
    ]);

    // 3. Extract takes
    const takes = transcriptResult.takes || [];

    // 4. Smart filter: remove silences that overlap with takes
    const safeSilences = filterSilencesByTakes(silences, takes);

    // 5. Show combined preview with colored markers
    showCombinedPreview(safeSilences, takes);
  });
}

function filterSilencesByTakes(silences, takes) {
  return silences.filter(silence => {
    // Check if silence overlaps with any take
    const overlaps = takes.some(take =>
      silence.start < take.endTime && silence.end > take.startTime
    );
    return !overlaps; // Only keep non-overlapping silences
  });
}
```

**Combined preview:**
```javascript
function showCombinedPreview(silences, takes) {
  // Merge and sort by time
  const items = [
    ...silences.map(s => ({ type: 'silence', ...s })),
    ...takes.map(t => ({ type: 'take', start: t.startTime, end: t.endTime, ...t }))
  ].sort((a, b) => a.start - b.start);

  // Render with appropriate colors
  // Red = silence (to remove)
  // Blue = take (to keep)
}
```

### 4. Workflow Flow

```
User clicks GO
    ↓
Export audio
    ↓
┌─────────────────────────────────┐
│  Parallel Detection             │
│  ├─ Detect silences             │
│  └─ Transcribe + detect takes   │
└─────────────────────────────────┘
    ↓
Filter silences (remove those overlapping takes)
    ↓
Show combined preview:
  - Red items = safe silences (will be removed)
  - Blue items = takes (for reference)
    ↓
User reviews and applies
    ↓
Only red-marked silences are removed
Takes are preserved
```

---

## Files to Modify

| File | Changes |
|------|---------|
| `index.html` | Remove takes card, single SPLICE card, add marker CSS, update settings |
| `js/main.js` | Merge workflows, parallel detection, smart filtering, combined preview |
| `js/settings.js` | Add autoMarkBest to settings |

---

## Implementation Order

1. Update HTML - single SPLICE card, remove takes card
2. Add CSS for colored markers (red/blue)
3. Refactor main.js:
   - Parallel detection (Promise.all)
   - `filterSilencesByTakes()` function
   - `showCombinedPreview()` function
4. Update settings modal
5. Test: verify takes protect nearby silences
