# SPLICE: Simplified 3-Click Workflow Implementation

## Goal
Transform the current 2-4 click silence detection workflow into a streamlined 3-click experience:
1. **SELECT** - Choose audio processing method (Original / Isolated)
2. **ADJUST** - Set sensitivity via single slider
3. **EXECUTE** - Click "Detect & Remove Silences"

## Decisions
- **Audio sources**: Original and Isolated only (no "Both" option)
- **Progress UI**: Indeterminate progress bar
- **Backend**: Chain existing endpoints (`/isolate-vocals` → `/silences-audio`) - no new endpoint

---

## Files to Modify

| File | Changes |
|------|---------|
| `splice-plugin/index.html` | Add audio source checkboxes, update sensitivity slider, add unified button |
| `splice-plugin/js/slice8-silence.js` | Implement unified detection logic with vocal isolation chain |

---

## Implementation Plan

### Step 1: Update Plugin UI (`index.html`)

**Replace lines 211-234** (current silence + razor sections) with unified UI:

```html
<!-- Unified Silence Detection UI -->
<div class="results-section" id="silenceSection" style="display: none;">
  <h2>Silence Removal</h2>

  <!-- Audio Source Selection -->
  <div class="audio-source-container">
    <sp-label>Audio Processing</sp-label>
    <sp-checkbox id="sourceOriginal" checked>Original Audio</sp-checkbox>
    <sp-checkbox id="sourceIsolated">Isolated Vocals <span class="tier-badge">Creator+</span></sp-checkbox>
  </div>

  <!-- Unified Sensitivity Slider -->
  <div class="slider-container">
    <sp-slider id="sensitivitySlider" min="0" max="100" step="5" value="50"
               variant="filled" editable>
      <sp-label slot="label">Sensitivity</sp-label>
    </sp-slider>
    <div class="slider-labels">
      <span>Less (keep pauses)</span>
      <span>More (remove more)</span>
    </div>
  </div>

  <!-- Results Display -->
  <div id="silenceResults"></div>

  <!-- Unified Action Button -->
  <button id="detectRemoveBtn" class="primary-btn">Detect & Remove Silences</button>

  <!-- Progress Indicator (for vocal isolation) -->
  <div id="isolationProgress" style="display: none;">
    <sp-progressbar indeterminate></sp-progressbar>
    <span>Isolating vocals...</span>
  </div>
</div>
```

### Step 2: Add Sensitivity Mapping (`slice8-silence.js`)

**Add mapping function** at top of file:

```javascript
// Maps 0-100 slider to detection parameters
function mapSensitivity(value) {
  // Linear interpolation between extremes
  const t = value / 100;

  return {
    dbThreshold: Math.round(-50 + (30 * t)),      // -50dB → -20dB
    minDuration: parseFloat((2.0 - (1.7 * t)).toFixed(2)),  // 2.0s → 0.3s
    padding: parseFloat((0.2 - (0.15 * t)).toFixed(2))      // 0.2s → 0.05s
  };
}

// Example outputs:
// 0%:   { dbThreshold: -50, minDuration: 2.0, padding: 0.20 }
// 50%:  { dbThreshold: -35, minDuration: 1.15, padding: 0.125 }
// 100%: { dbThreshold: -20, minDuration: 0.3, padding: 0.05 }
```

### Step 3: Implement Unified Detection Flow (`slice8-silence.js`)

**Replace/update click handler** for unified button:

```javascript
document.getElementById('detectRemoveBtn').addEventListener('click', async () => {
  const btn = document.getElementById('detectRemoveBtn');
  const resultsDiv = document.getElementById('silenceResults');
  const progressDiv = document.getElementById('isolationProgress');

  const useOriginal = document.getElementById('sourceOriginal').checked;
  const useIsolated = document.getElementById('sourceIsolated').checked;
  const sensitivity = parseInt(document.getElementById('sensitivitySlider').value);

  if (!useOriginal && !useIsolated) {
    setStatus('Please select at least one audio source');
    return;
  }

  btn.disabled = true;
  btn.textContent = 'Processing...';
  resultsDiv.innerHTML = '';

  try {
    const params = mapSensitivity(sensitivity);
    let audioPath = WAV_PATH;

    // Step 1: Vocal isolation if selected
    if (useIsolated) {
      progressDiv.style.display = 'block';
      progressDiv.querySelector('span').textContent = 'Isolating vocals (this may take a few minutes)...';

      const isolateResponse = await fetch(`${BACKEND_URL}/isolate-vocals`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ audioPath: WAV_PATH })
      });

      const isolateData = await isolateResponse.json();
      if (!isolateData.success) throw new Error(isolateData.error);

      audioPath = isolateData.outputPath;
      progressDiv.style.display = 'none';
    }

    // Step 2: Detect silences
    progressDiv.style.display = 'block';
    progressDiv.querySelector('span').textContent = 'Detecting silences...';

    const detectResponse = await fetch(`${BACKEND_URL}/silences-audio`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        wavPath: audioPath,
        threshold: params.dbThreshold,
        minDuration: params.minDuration,
        padding: params.padding
      })
    });

    const detectData = await detectResponse.json();
    if (!detectData.success) throw new Error(detectData.error);

    currentSilences = detectData.silences;
    progressDiv.style.display = 'none';

    // Display results
    resultsDiv.innerHTML = `
      <p><strong>${detectData.count}</strong> silence(s) found</p>
      <p style="color: #888;">Total: ${detectData.totalSilenceDuration}s of silence</p>
      <p style="color: #666; font-size: 12px;">
        Settings: ${params.dbThreshold}dB, ${params.minDuration}s min, ${params.padding}s padding
      </p>
    `;

    // Step 3: Apply to timeline
    if (detectData.count > 0) {
      progressDiv.style.display = 'block';
      progressDiv.querySelector('span').textContent = 'Applying to timeline...';

      await removeSilencesFromTimeline();

      progressDiv.style.display = 'none';
      setStatus(`Removed ${detectData.count} silences from timeline`);
    } else {
      setStatus('No silences detected with current sensitivity');
    }

  } catch (err) {
    progressDiv.style.display = 'none';
    resultsDiv.innerHTML = `<p style="color: #f66;">Error: ${err.message}</p>`;
    setStatus('Error: ' + err.message);
  } finally {
    btn.disabled = false;
    btn.textContent = 'Detect & Remove Silences';
  }
});
```

### Step 4: Add CSS Styling (`index.html`)

**Add to `<style>` section:**

```css
.audio-source-container {
  margin-bottom: 16px;
  padding: 12px;
  background: rgba(255,255,255,0.05);
  border-radius: 8px;
}

.audio-source-container sp-checkbox {
  display: block;
  margin: 8px 0;
}

.tier-badge {
  font-size: 10px;
  background: #4a9eff;
  color: white;
  padding: 2px 6px;
  border-radius: 4px;
  margin-left: 8px;
}

.slider-labels {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: #888;
  margin-top: 4px;
}

.primary-btn {
  width: 100%;
  padding: 14px;
  font-size: 14px;
  font-weight: 600;
  background: linear-gradient(135deg, #4a9eff, #2d7dd2);
  border: none;
  border-radius: 8px;
  color: white;
  cursor: pointer;
  margin-top: 16px;
}

.primary-btn:hover {
  background: linear-gradient(135deg, #5aa8ff, #3d8de2);
}

.primary-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

#isolationProgress {
  text-align: center;
  padding: 16px;
  color: #888;
}

#isolationProgress sp-progressbar {
  width: 100%;
  margin-bottom: 8px;
}
```

---

## Testing Checklist

1. [ ] Verify sensitivity slider maps correctly (0% = keep more, 100% = remove more)
2. [ ] Test Original Audio detection works
3. [ ] Test Isolated Vocals detection works (requires Replicate billing credit)
4. [ ] Verify silences are correctly applied to timeline
5. [ ] Test error handling for network failures
6. [ ] Test progress indicator appears during vocal isolation

---

## Notes

- Vocal isolation takes 2-5 minutes - indeterminate progress bar will show
- Keep existing slice9-razor.js for advanced users who want XML workflow
- Rate limiting will be added in a future iteration (requires auth first)
- No backend changes required - chains existing `/isolate-vocals` → `/silences-audio` endpoints
