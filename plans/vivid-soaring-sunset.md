# SPLICE Firecut Feature Parity Plan

## Architecture Decision
**Keep UXP** - Research confirms UXP supports all cutting operations:
- `SequenceEditor.createRemoveItemsAction()` - Delete clips
- `SequenceEditor.createInsertProjectItemAction()` - Insert clips
- `TrackItem` in/out point actions - Trim clips

Sources: [Adobe UXP API](https://developer.adobe.com/premiere-pro/uxp/), [SequenceEditor Docs](https://developer.adobe.com/premiere-pro/uxp/ppro_reference/classes/sequenceeditor/)

---

## 11 Features to Implement

| # | Feature | Files | Effort |
|---|---------|-------|--------|
| 1 | J-Cut Full Implementation | builder.js, main.js | 3h |
| 2 | Word-Level Timestamps | server.js, transcription.js | 2h |
| 3 | Bleep Sound Insertion | builder.js, profanityDetection.js | 4h |
| 4 | Chapter Titles Generation | chapterDetection.js, server.js | 2h |
| 5 | Profanity Custom Lists UI | index.html, settings.js, main.js | 3h |
| 6 | Filler Words Accuracy | server.js, new fillerDetection.js | 3h |
| 7 | Advanced Multitrack Balancing | multitrackAnalysis.js | 4h |
| 8 | Repetition Phrase Highlighting | main.js, index.html | 2h |
| 9 | Waveform Visualization | new waveform.js, index.html | 5h |
| 10 | MOGRT/Section Clips | builder.js, settings.js | 6h |
| 11 | Turbo XML Cutting (10k+) | builder.js, cutListGenerator.js | 3h |

---

## Process Per Feature

```
1. Implement feature
2. Create tests/feature-name.test.js
3. Run: node tests/feature-name.test.js
4. If bugs → fix → re-run test
5. Test passes → next feature
```

---

## Feature 1: J-Cut Full Implementation

**Current State:** UI exists, audio offsets in cut list, but not applied to timeline

**Fix:**
- `builder.js:566-630` - Fix `setTrackItemInOutPoints()` to apply different audio in/out
- `main.js` - Wire J-Cut sliders to `/cut-list` endpoint params

**Test:** `tests/jcut-full.test.js`
```javascript
test('builder.js applies audioInOffset/audioOutOffset', () => {
  assert(builderCode.includes('audioInPoint'));
  assert(builderCode.includes('createSetInPointAction'));
});
```

---

## Feature 2: Word-Level Timestamps

**Current State:** `transcription.js:225-236` has `timestamp_granularities: ['word', 'segment']`

**Add:**
- `server.js` - New endpoint `POST /transcribe/word-level`
- Frame alignment using `alignToFrame()` from cutListGenerator.js

**Test:** `tests/word-level-timestamps.test.js`

---

## Feature 3: Bleep Sound Insertion

**Current State:** `profanityDetection.js:437-531` generates WAV, doesn't insert

**Add:**
- `builder.js` - `insertBleepAudio(sequence, bleepPath, startTime)`
- Use `createInsertProjectItemAction()` on audio track

**Test:** `tests/bleep-insertion.test.js`

---

## Feature 4: Chapter Titles Generation

**Current State:** `chapterDetection.js` returns basic titles

**Add:**
- Enhance `buildChapterPrompt()` for YouTube-optimized titles
- Add `titleStyle: 'youtube' | 'shorts'` parameter

**Test:** `tests/chapter-titles.test.js`

---

## Feature 5: Profanity Custom Lists UI

**Current State:** Backend accepts `customBlocklist`/`customAllowlist`, no UI

**Add to `index.html`:**
```html
<div id="profanitySettings" class="options-panel">
  <textarea id="profanityBlocklist" placeholder="word1, word2"></textarea>
  <textarea id="profanityAllowlist" placeholder="allowed1, allowed2"></textarea>
</div>
```

**Add to `settings.js`:** `getProfanitySettings()`, `saveProfanitySettings()`

**Test:** `tests/profanity-custom-lists.test.js`

---

## Feature 6: Filler Words Accuracy

**Current State:** Segment-level detection

**Add:**
- Use word-level timestamps from Feature 2
- Match against FILLER_WORDS array with precise boundaries

**Test:** `tests/filler-words-accuracy.test.js`

---

## Feature 7: Advanced Multitrack Balancing

**Current State:** `multitrackAnalysis.js:729-798` basic balancing

**Add:**
- Genetic algorithm optimization
- Constraints: maxConsecutiveSeconds, momentumFactor
- New endpoint `POST /multitrack/advanced-balance`

**Test:** `tests/advanced-multitrack.test.js`

---

## Feature 8: Repetition Phrase Highlighting

**Current State:** Detection exists, no UI highlighting

**Add to `main.js`:**
```javascript
const COLORS = ['#ff6b6b', '#4ecdc4', '#ffe66d', '#95e1d3'];
function renderRepetitionPreview(repetitions) { ... }
```

**Add to `index.html`:** `<div id="repetitionPreview"></div>`

**Test:** `tests/repetition-highlighting.test.js`

---

## Feature 9: Waveform Visualization

**Add:**
- New file `splice-plugin/js/waveform.js`
- Canvas element in `index.html`
- Endpoint `GET /waveform/:jobId` returning RMS data

**Test:** `tests/waveform.test.js`

---

## Feature 10: MOGRT/Section Clips

**Add:**
- `builder.js` - `insertChapterDividers()` with marker-based approach
- Settings for MOGRT template path

**Test:** `tests/mogrt-chapters.test.js`

---

## Feature 11: Turbo XML Cutting

**Add to `builder.js`:**
```javascript
async function buildSequenceOptimal(cutList) {
  if (cutList.segments.length > 5000) {
    return buildSequenceTurboXML(cutList); // Chunked XML
  }
  return buildSequenceFromCutList(cutList); // DOM API
}
```

**Test:** `tests/turbo-xml.test.js`

---

## Final E2E Test

After all features: `tests/firecut-features-e2e.test.js`

Validates:
- All 11 features implemented
- UI wiring correct
- API endpoints working
- No performance bottlenecks
- Builder integration functional

---

## Documentation Update

After completion, update `CLAUDE.md`:

```markdown
### Firecut Parity Features (v4.0)
- Word-Level Timestamps - Frame-aligned word boundaries
- Bleep Sound Insertion - Auto-insert bleeps
- Chapter Titles - YouTube-optimized AI titles
- Profanity Custom Lists - Blocklist/allowlist UI
- Filler Words Accuracy - Word-level detection
- Advanced Multitrack - Genetic algorithm balancing
- Turbo XML Cutting - 10k+ cut batch processing
- Waveform Visualization - RMS waveform display
- Repetition Highlighting - Color-coded phrases
- MOGRT/Section Clips - Chapter divider templates
- J-Cut Full - Audio lead-in/lead-out working
```

---

## Key Files

| File | Changes |
|------|---------|
| `splice-plugin/js/builder.js` | J-Cut fix, bleep insertion, turbo XML |
| `splice-plugin/js/main.js` | UI wiring, repetition preview |
| `splice-plugin/index.html` | Profanity settings, waveform canvas |
| `splice-plugin/js/settings.js` | Profanity lists, MOGRT paths |
| `splice-backend/server.js` | New endpoints |
| `splice-backend/services/profanityDetection.js` | Custom lists |
| `splice-backend/services/chapterDetection.js` | Title optimization |
| `splice-backend/services/multitrackAnalysis.js` | Advanced balancing |
| `splice-backend/services/transcription.js` | Word-level enhancement |
