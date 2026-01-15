# Splice v3 - Auto-Cutting Workflow Implementation Plan

## Overview

Update CLAUDE.md to document the complete auto-cutting workflow and implement the following pipeline:

**User Flow:**
1. User selects/highlights clips in Premiere Pro timeline
2. Plugin extracts audio from selected clips
3. Backend isolates vocals from dialogue (optional, for cleaner transcription)
4. Backend transcribes the audio
5. **LLM analyzes transcript to detect repeated takes** (similar statements)
6. Cut silences (preserving natural pauses)
7. Label and color-code takes on timeline

---

## Core Workflow Specification

### Step 1: Clip Selection
- User selects clips in Premiere Pro timeline
- Plugin calls `getSelectedClips()` to get clip IDs, timestamps, track info
- Extract audio from selected clips (via Premiere API or render to temp file)

### Step 2: Audio Processing Pipeline
```
Selected Clips → Extract Audio → Upload to S3 →
  → Vocal Isolation (optional) → Transcription →
  → LLM Take Detection → Silence Detection →
  → Apply Cuts & Labels
```

### Step 3: Take Detection (LLM-Powered)

**Approach:** Use LLM to analyze transcript and group similar statements

**Input:** Transcription segments with timestamps
```typescript
interface TranscriptionSegment {
  start: number
  end: number
  text: string
  confidence: number
}
```

**LLM Prompt Pattern:**
```
Analyze this transcript and identify repeated takes (multiple attempts at the same line/phrase).

Group similar statements together. For example:
- "Hey guys welcome back to my channel" at 0:05
- "Hey guys, welcome back" at 0:45
- "Hey guys welcome back to the channel" at 1:20

Should be grouped as:
- Take Group: "Hey Guys Welcome"
  - Take 1: 0:05 - "Hey guys welcome back to my channel"
  - Take 2: 0:45 - "Hey guys, welcome back"
  - Take 3: 1:20 - "Hey guys welcome back to the channel"

Return JSON with grouped takes and suggested short labels.
```

**Output:**
```typescript
interface TakeGroup {
  id: string
  label: string              // Short label: "Hey Guys Welcome"
  takes: {
    takeNumber: number
    startTime: number
    endTime: number
    text: string
  }[]
  color: string              // Assigned based on group count
}
```

### Step 4: Color Coding System

| Number of Takes | Color | Meaning |
|-----------------|-------|---------|
| 1 take | Green | Single take (good) |
| 2 takes | Yellow | Minor retry |
| 3 takes | Orange | Multiple attempts |
| 4+ takes | Red | Many retakes |

### Step 5: Silence Cutting (Preserve Natural Pauses)

**Thresholds (from research):**
- Natural pause to KEEP: 150ms - 500ms (breath, comma, sentence boundary)
- Silence to CUT: > 750ms (dead air, between-take gaps)
- Between-take gap: > 2000ms (definitely cut)

**Key Rule:** Cut at silences but leave ~100ms padding to avoid clipping words

### Step 6: Audio Source Options

**User Controls:**
1. **Isolate Audio** checkbox - Option to run vocal isolation on selected clips
2. **Audio Source for Timeline** dropdown:
   - `Original` (default) - Keep original audio on timeline after cuts
   - `Isolated Vocals` - Replace with isolated vocals (cleaner dialogue)

**Processing Logic:**
- Default: Keep original audio on timeline
- If user enables "Isolate Audio":
  - Backend runs vocal isolation
  - User can choose to use isolated audio on timeline OR just for transcription accuracy
- Isolated vocals are always used for transcription when available (cleaner = better accuracy)

---

## Files to Modify/Create

### 1. Update CLAUDE.md
Add new "Auto-Cutting Workflow" section documenting the complete flow

### 2. Backend: Take Detection Service
**File:** `backend/src/services/take-detection-service.ts`
- Call LLM API (Claude/OpenAI) with transcript
- Parse response into TakeGroup structures
- Return grouped takes with labels and colors

### 3. Backend: New Job Type
**File:** `backend/src/workers/take-detection-worker.ts`
- New BullMQ worker for take detection jobs
- Orchestrates: transcription → LLM analysis → return results

### 4. Plugin: Audio Extraction
**File:** `src/utils/api/premiere.ts`
- Add `extractAudioFromClips(clips)` - render selected clips to audio file
- Add `getClipMediaPath(clip)` - get source media path

### 5. Plugin: Clip Colors & Labels
**File:** `src/utils/api/premiere.ts`
- Add `setClipColor(clipId, labelColor)` - change clip's label color on timeline
- Add `setClipName(clipId, name)` - rename clip (e.g., "Take 1 - Hey Guys")
- Add `applyTakeGroupColors(takeGroups)` - apply colors & names to all take clips

**Premiere Pro Label Colors (0-15):**
- 0: Violet, 1: Iris, 2: Caribbean, 3: Lavender
- 4: Cerulean, 5: Forest, 6: Rose, 7: Mango
- 8: Purple, 9: Blue, 10: Teal, 11: Magenta
- 12: Tan, 13: Green, 14: Brown, 15: Yellow

**Color Mapping for Takes:**
| Takes | Label Index | Color Name |
|-------|-------------|------------|
| 1     | 13 (Green)  | Single take ✓ |
| 2     | 15 (Yellow) | Minor retry |
| 3     | 7 (Mango)   | Multiple attempts |
| 4+    | 11 (Magenta)| Many retakes |

### 6. Types
**File:** `src/types/auto-cutting.ts` (already created by config agent)
- Add TakeGroup, TakeDetectionResult interfaces

### 7. UI: Enhanced CuttingPanel
**File:** `src/components/common/CuttingPanel.ts`
- **Audio Options Section:**
  - "Isolate Audio" checkbox - enable vocal isolation
  - "Timeline Audio Source" dropdown: Original | Isolated Vocals
- **Take Groups Section:**
  - List of detected take groups with color preview
  - Each group shows: label, take count, color swatch
  - Expandable to show individual takes with timestamps
- **Preview before applying**
- **Silence threshold controls** (existing)

---

## Configuration Defaults

```typescript
const autoCuttingDefaults = {
  // Audio options (user-selectable)
  isolateAudio: false,               // Run vocal isolation on clips
  timelineAudioSource: 'original',   // 'original' | 'isolated' - what goes on timeline after cuts
  useIsolatedForTranscription: true, // Use isolated audio for better transcription accuracy

  // Silence detection
  silenceMinDuration: 0.75,          // seconds - cut gaps longer than this
  naturalPauseMax: 0.5,              // seconds - preserve pauses under this
  paddingMs: 100,                    // buffer to avoid clipping words

  // Take detection
  enableTakeDetection: true,
  llmModel: 'claude-3-haiku',        // Fast, cheap for this task
  similarityThreshold: 0.7,          // For fallback text matching

  // Clip colors (Premiere Pro label indices)
  labelFormat: 'Take {n} - "{label}"',
  clipLabelColors: {
    1: 13,  // Green - single take
    2: 15,  // Yellow - minor retry
    3: 7,   // Mango/Orange - multiple attempts
    4: 11,  // Magenta/Red - many retakes (4+)
  }
}
```

---

## Implementation Order

1. **Update CLAUDE.md** with workflow documentation
2. **Add types** for TakeGroup, TakeDetectionResult, AudioSourceOption
3. **Backend: Take detection service** with LLM integration
4. **Backend: Take detection worker** (new job type)
5. **Plugin: Audio extraction** from selected clips
6. **Plugin: Clip color & naming** - set label colors and rename clips for takes
7. **UI: Update CuttingPanel** with audio options and take groups preview
8. **Integration: Wire everything together**

---

## Questions Resolved

- **Audio isolation:** User option to isolate audio if needed (checkbox)
- **Timeline audio source:** User can choose original (default) OR isolated vocals
- **Transcription source:** Always use isolated vocals when available for better accuracy
- **Visual feedback:** Colored CLIPS (not markers) - change clip label color on timeline
- **Take detection:** LLM-powered analysis of transcript similarity
- **Color coding:** Based on number of takes per group (green→yellow→orange→red)
- **Natural pauses:** Preserve 150-500ms, cut >750ms
- **Labeling:** "Take 1 - Hey Guys", "Take 2 - Hey Guys" format with clip rename
