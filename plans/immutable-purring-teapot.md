# SPLICE Plugin Implementation Plan

## Overview
Fork and modify SPLICE_PLEASE to create an intelligent video editing plugin for Adobe Premiere Pro that:
- Detects selected clips and offers cut/vocal isolation options
- Transcribes dialogue, detects repeated takes, cuts silences
- Color codes clips by take count (Blue=2, Red=3+)
- Renames clips ("take 1 - Hey guys") and organizes timeline

## Tech Stack

| Component | Technology | Fallback |
|-----------|------------|----------|
| **Vocal Isolation** | Demucs v4 (local) | LALAL.AI API |
| **Transcription** | Whisper large-v3 (local) | Deepgram/Whisper API |
| **Silence Detection** | FFmpeg + Silero VAD | - |
| **Take Detection** | Sentence Transformers (all-MiniLM-L6-v2) | - |
| **LLM Analysis** | Claude API (disambiguation, pause analysis) | - |
| **Video Editor** | UXP API (existing) | - |

## Repository Setup

```bash
# Fork to Desktop
cp -r /path/to/SPLICE_PLEASE /Users/imorgado/Desktop/SPLICE/plugin
cd /Users/imorgado/Desktop/SPLICE/plugin
git init && git add . && git commit -m "Fork from SPLICE_PLEASE"
```

## New Directory Structure

```
/Users/imorgado/Desktop/SPLICE/
├── build.md                    # Architecture documentation (CREATE)
└── plugin/
    ├── src/
    │   ├── components/
    │   │   ├── panels/
    │   │   │   └── PluginApp.ts        # MODIFY: Add tabs
    │   │   └── common/
    │   │       ├── ProcessingPanel.ts   # NEW: Progress UI
    │   │       ├── ResultsPanel.ts      # NEW: Takes/silence display
    │   │       └── SettingsPanel.ts     # MODIFY: Add options
    │   ├── services/
    │   │   ├── pipeline/
    │   │   │   └── ProcessingPipeline.ts  # NEW: Main orchestrator
    │   │   ├── audio/
    │   │   │   ├── AudioExtractor.ts      # NEW: FFmpeg wrapper
    │   │   │   ├── VoiceIsolator.ts       # NEW: Demucs integration
    │   │   │   └── SilenceDetector.ts     # NEW: VAD integration
    │   │   ├── transcription/
    │   │   │   └── Transcriber.ts         # NEW: Whisper wrapper
    │   │   ├── analysis/
    │   │   │   ├── TakeDetector.ts        # NEW: Embedding + clustering
    │   │   │   └── LLMAnalyzer.ts         # NEW: Claude integration
    │   │   └── premiere/
    │   │       ├── TimelineService.ts     # NEW: Razor, ripple delete, actual cuts
    │   │       ├── ClipService.ts         # NEW: Color, rename, audio replace
    │   │       └── BinService.ts          # NEW: Bin organization
    │   ├── types/
    │   │   ├── pipeline.ts                # NEW
    │   │   ├── takes.ts                   # NEW
    │   │   └── silence.ts                 # NEW
    │   └── utils/native/
    │       ├── ffmpeg.ts                  # NEW: Binary wrapper
    │       └── whisper.ts                 # NEW: Binary wrapper
    ├── bin/
    │   ├── mac/                           # FFmpeg, Whisper, Demucs binaries
    │   └── win/
    └── models/
        ├── whisper-large-v3.bin
        └── all-MiniLM-L6-v2/
```

## Processing Pipeline

```
User Selects Clips
       │
       ▼
[1] Audio Extraction (FFmpeg) ─────────────────────────────────┐
       │                                                        │
       ▼                                                        │
[2] Voice Isolation (Demucs) ──────────────────────────────────│
       │                                                        │
       ├─► ISOLATED AUDIO (for silence detection)              │
       │                                                        │
       └─► ORIGINAL AUDIO (preserved for final output)         │
       │                                                        │
       ▼                                                     Pipeline
[3] Transcription (Whisper on ISOLATED audio) ─────────────────│
       │                                                        │
       ▼                                                        │
[4] Silence Detection (on ISOLATED audio - cleaner signal) ────│
       │                                                        │
       ▼                                                        │
[5] Sentence Segmentation ─────────────────────────────────────│
       │                                                        │
       ▼                                                        │
[6] Embedding Generation (all-MiniLM-L6-v2) ───────────────────│
       │                                                        │
       ▼                                                        │
[7] Similarity Clustering (cosine sim > 0.85) ─────────────────│
       │                                                        │
       ▼                                                        │
[8] LLM Pause Analysis (Natural vs Unnatural) ─────────────────┘
       │
       ▼
[9] Timeline Editing (ACTUAL CUTS)
     ├─ RAZOR clips at silence boundaries
     ├─ DELETE silent segments from timeline
     ├─ KEEP original audio on remaining clips
     ├─ Color code clips (None=1, Blue=2, Red=3+)
     ├─ Rename clips ("take 1 - Hey guys")
     ├─ Create bins (SPLICE Takes/)
     └─ [Optional] Replace audio with isolated vocals
```

## Audio Handling

**Key Principle**: Vocal isolation is a DETECTION TOOL, not the output.

```
ORIGINAL CLIP (video + original audio)
       │
       ├──► Extract audio ──► Demucs ──► ISOLATED VOCALS
       │                                      │
       │                                      ▼
       │                           Use for silence detection
       │                           Use for transcription
       │                           (cleaner signal = better accuracy)
       │
       ▼
FINAL OUTPUT: Original clip with original audio
              (unless user opts for vocal replacement)
```

**User Options**:
1. **Keep Original** (default) - Cuts applied, original audio preserved
2. **Replace with Isolated** - Cuts applied, audio swapped to isolated vocals

## Key Type Definitions

```typescript
interface ProcessingJob {
  id: string;
  clips: ClipInfo[];
  status: JobStatus;
  progress: number;
  options: ProcessingOptions;
}

interface ProcessingOptions {
  transcriptionProvider: 'whisper-local' | 'deepgram' | 'whisper-api';
  similarityThreshold: number;       // 0.75-0.95
  silenceThreshold: number;          // 0.5s, 1.0s, 1.5s, 2.0s
  preserveNaturalPauses: boolean;    // Uses LLM
  autoColorCode: boolean;
  useIsolatedAudio: boolean;         // Replace original with isolated vocals
}

interface TakeGroup {
  id: string;
  canonicalText: string;
  takes: Take[];
  suggestedBestTakeIndex: number;
}

interface SilenceSegment {
  startTime: number;
  endTime: number;
  type: 'dead_space' | 'natural_pause' | 'breath';
  shouldCut: boolean;
}
```

## Color Coding

```typescript
const TAKE_COLORS = {
  1: null,        // No color (unique)
  2: 'CERULEAN',  // Blue
  3: 'ROSE'       // Red (3+ takes)
};
```

## Implementation Phases

### Phase 1: Core Infrastructure (Week 1-2)
- [ ] Set up fork and directory structure
- [ ] Implement FFmpeg wrapper (`/src/utils/native/ffmpeg.ts`)
- [ ] Implement Whisper wrapper (`/src/utils/native/whisper.ts`)
- [ ] Create ProcessingPipeline skeleton
- [ ] Add new TypeScript types

### Phase 2: Take Detection (Week 3-4)
- [ ] Integrate ONNX Runtime for embeddings
- [ ] Implement sentence segmentation
- [ ] Implement similarity matrix + clustering
- [ ] Add Claude API for disambiguation
- [ ] Build ResultsPanel UI

### Phase 3: Silence Detection (Week 5-6)
- [ ] Implement FFmpeg silencedetect parsing
- [ ] Implement transcript-gap detection
- [ ] Add LLM pause analysis (natural vs unnatural)
- [ ] User-adjustable threshold (0.5s-2.0s)

### Phase 4: Premiere Integration (Week 7-8)
- [ ] Implement TimelineService (razor, ripple delete)
- [ ] Implement ClipService (color, rename, audio replace)
- [ ] Implement BinService
- [ ] Implement silence removal (razor → ripple delete flow)
- [ ] Implement audio replacement for isolated vocals option

### Phase 5: Voice Isolation (Week 9-10)
- [ ] Integrate Demucs binary
- [ ] Add LALAL.AI API fallback
- [ ] Provider selection UI

### Phase 6: Polish (Week 11-12)
- [ ] End-to-end testing
- [ ] Error handling + fallbacks
- [ ] Performance optimization
- [ ] Update build.md documentation

## Critical Files to Modify

1. **`/src/utils/api/premiere.ts`** - Replace placeholders with real UXP API calls
2. **`/src/components/panels/PluginApp.ts`** - Add new tabs (Processing, Results)
3. **`/src/components/common/SettingsPanel.ts`** - Add processing options
4. **`/src/types/`** - Add pipeline, takes, silence types

## Deliverables

1. **Forked plugin** at `/Users/imorgado/Desktop/SPLICE/plugin/`
2. **build.md** at `/Users/imorgado/Desktop/SPLICE/build.md` - Full architecture docs
3. **Working pipeline** - Transcription → Take Detection → Silence Cutting → Organization

## Settings UI Structure

```
Settings Panel
├── Processing Options
│   ├── Transcription Provider (Whisper Local/Deepgram/API)
│   └── Silence Threshold (0.5s/1.0s/1.5s/2.0s slider)
├── Take Detection
│   ├── Similarity Threshold (70%-95% slider)
│   └── Use LLM Analysis (checkbox)
├── Audio Options
│   └── Use isolated vocals (checkbox) - Replace original audio with cleaned vocals
└── Timeline Organization
    ├── Auto color-code by take count (checkbox)
    └── Create organized bins (checkbox)
```

## Timeline Editing Operations

The plugin performs **actual timeline edits** (not markers):

```typescript
// TimelineService operations
interface TimelineService {
  // Cut clip at specific timecode
  razorClip(clipId: string, time: number): Promise<void>;

  // Delete segment between two timecodes (silence removal)
  deleteSegment(clipId: string, startTime: number, endTime: number): Promise<void>;

  // Ripple delete (closes gap after removal)
  rippleDelete(clipId: string, startTime: number, endTime: number): Promise<void>;

  // Set clip label color
  setClipColor(clipId: string, colorIndex: number): Promise<void>;

  // Rename clip
  renameClip(clipId: string, newName: string): Promise<void>;

  // Replace audio track with isolated vocals
  replaceAudio(clipId: string, newAudioPath: string): Promise<void>;
}
```

**Silence Removal Flow**:
1. Identify silence segments from isolated audio analysis
2. For each silence segment (longest first, to preserve timecodes):
   - Razor at silence start
   - Razor at silence end
   - Ripple delete the silent portion
3. Remaining clips retain original audio (unless user selected isolated)
