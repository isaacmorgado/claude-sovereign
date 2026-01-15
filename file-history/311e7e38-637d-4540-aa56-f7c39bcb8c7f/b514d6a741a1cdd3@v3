# SPLICE v3 - Full Implementation Plan

## Overview
Transform SPLICE from a local-first AI analysis tool into a cloud-powered SaaS with auto-cutting, take detection, and subscription billing.

## Priority Order (Per User Request)
1. **Phase 1**: Full Authentication & Billing Infrastructure
2. **Phase 2**: Silence Detection & Auto-Cut
3. **Phase 3**: Take Detection with Semantic Grouping

---

## Phase 1: Backend & Authentication (Build First)

### 1.1 Backend Setup (Node.js + PostgreSQL)
**New project: `backend/`**

```
backend/
├── src/
│   ├── routes/          # auth, billing, jobs, audio, usage
│   ├── controllers/     # Route handlers
│   ├── services/        # Business logic
│   ├── workers/         # BullMQ job processors
│   ├── db/
│   │   ├── migrations/  # SQL schema
│   │   └── repositories/
│   ├── middleware/      # auth, rate-limit, usage-limit
│   └── config/
├── docker-compose.yml   # PostgreSQL, Redis
└── package.json
```

### 1.2 Database Schema (Core Tables)
- `users` - id, email, password_hash, auth_provider, created_at
- `subscriptions` - user_id, stripe_customer_id, plan_tier (free_trial/pro/enterprise), status
- `usage` - user_id, operation_type, credits_used, created_at
- `jobs` - user_id, type, status, input_file_url, output_data, progress

### 1.3 API Endpoints
```
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
GET  /api/v1/auth/me

POST /api/v1/billing/checkout      # Create Stripe session
POST /api/v1/billing/portal        # Manage subscription
POST /api/v1/webhook/stripe        # Handle webhooks

POST /api/v1/jobs                  # Create processing job
GET  /api/v1/jobs/:id/status       # Poll job status
POST /api/v1/audio/upload          # Get presigned URL
```

### 1.4 Stripe Integration
- Products: Pro ($29.99/mo), Enterprise ($69.99/mo)
- Free trial: 10 minutes of audio processing (no credit card required)
- Webhooks: checkout.completed, subscription.updated, invoice.paid

### 1.5 Web Dashboard (Next.js)
```
dashboard/
├── app/
│   ├── page.tsx          # Home/landing
│   ├── login/
│   ├── signup/
│   ├── dashboard/
│   │   ├── page.tsx      # Usage stats
│   │   ├── billing/      # Subscription management
│   │   └── settings/
```

---

## Phase 2: Silence Detection & Auto-Cut

### 2.1 Audio Processing Pipeline (Cloud)

**Tiered Services (80%+ Margins):**
| Tier | Transcription | Vocal Isolation | Cost/min | Limit |
|------|--------------|-----------------|----------|-------|
| Free Trial | Whisper API | Skip | ~$0.007 | 10 min total |
| Pro ($29.99) | Deepgram Nova-2 | Demucs via Replicate | ~$0.015 | 300 min/mo |
| Enterprise ($69.99) | Deepgram + Diarization | Dolby.io | ~$0.025 | 500 min/mo |

### 2.2 Silence Detection Algorithm
```typescript
interface SilenceConfig {
  silenceThreshold: -40,        // dB below peak
  minSilenceDuration: 500,      // ms
  preserveBreathingPauses: true,
  breathingPauseMax: 300,       // Keep pauses < 300ms
  prePadding: 100,              // ms before speech
  postPadding: 150,             // ms after speech
}
```

**Challenging Audio Handling:**
- High wind: High-pass filter (150Hz cutoff)
- Loud music: MUST use vocal isolation
- Background talking: Speaker diarization
- Low voice: Adaptive threshold + vocal isolation

### 2.3 Premiere Pro Editing Operations (RESEARCH COMPLETE)

**Current state**: `src/utils/api/premiere.ts` has stubbed functions.

**Implementation using UXP API:**
```typescript
// NEW: premiere-editor.ts - Using confirmed UXP methods

// Cutting (workaround - no razor API exists)
export async function cutClipAtTime(
  trackItem: VideoClipTrackItem,
  cutTime: TickTime
): Promise<boolean> {
  const editor = await sequence.getSequenceEditor()
  // 1. Store original clip info
  // 2. Remove original: createRemoveItemsAction()
  // 3. Re-insert as two clips with adjusted in/out points
  // 4. Execute via lockedAccess + executeTransaction
}

// Renaming (confirmed available)
export async function renameClip(trackItem: VideoClipTrackItem, name: string) {
  const action = trackItem.createSetNameAction(name)
  // Execute action
}

// Color (workaround - must set on ProjectItem before insert)
export async function insertColoredClip(
  projectItem: ProjectItem,
  color: LabelColor,
  time: TickTime
) {
  projectItem.setColorLabel(color)  // Set color FIRST
  const action = editor.createInsertProjectItemAction(...)
}
```

**Audio extraction**: Use `clip.mediaPath` → FFmpeg (cloud backend)

### 2.4 New Plugin UI Components

**Files to create:**
- `src/components/common/CuttingPanel.ts` - Main cutting workflow UI
- `src/components/common/SilencePreview.ts` - Preview detected silences before cutting
- `src/components/common/ProcessingProgress.ts` - Job status display

**Workflow:**
1. User selects clips in timeline
2. Plugin uploads audio to cloud
3. Cloud processes (transcription + optional vocal isolation)
4. Returns cut points to plugin
5. User previews suggested cuts
6. User confirms → Plugin applies razor cuts

---

## Phase 3: Take Detection with Semantic Grouping

### 3.1 Take Detection Pipeline
```
Transcription → Sentence Segmentation → Embeddings → Clustering → Take Groups
```

### 3.2 Semantic Similarity
- Service: OpenAI `text-embedding-3-small` (Pro), `text-embedding-3-large` (Enterprise)
- Threshold: 0.85 cosine similarity = same take
- Example: "Hey guys welcome back" ≈ "Hey everyone, welcome back to my channel"

### 3.3 Color Coding & Naming
```typescript
function getColorForTakeCount(count: number): LabelColor {
  if (count === 2) return 'blue'
  if (count === 3) return 'red'
  if (count === 4) return 'purple'
  return 'orange' // 5+
}

// Clip naming: "take 1 - Hey guys"
```

### 3.4 Take Detection UI
- `src/components/common/TakeDetectionPanel.ts` - Show transcription + groupings
- `src/components/common/TakeGroupCard.ts` - Display each take group with instances
- Allow user to confirm/modify groupings before applying

---

## Files to Modify (Plugin)

### Critical Changes
| File | Change |
|------|--------|
| `src/utils/api/premiere.ts` | Implement cutting, renaming, labeling functions |
| `src/utils/api/ai-service.ts` | Replace direct AI calls → backend API calls |
| `src/utils/api/plugin.ts` | Remove local auth, add backend session management |
| `src/components/common/SettingsPanel.ts` | Replace API key input → Login/Signup |
| `src/components/common/AIToolsPanel.ts` | Add new cutting/take detection tools |
| `public/manifest.json` | Add Deepgram, Replicate, Dolby domains |

### New Files (Plugin)
```
src/
├── components/common/
│   ├── AuthPanel.ts          # Login/signup UI
│   ├── CuttingPanel.ts       # Silence cutting workflow
│   ├── TakeDetectionPanel.ts # Take grouping UI
│   └── ProcessingProgress.ts # Job status
├── utils/api/
│   ├── backend-client.ts     # API client for backend
│   └── audio-processor.ts    # Audio upload/download
├── types/
│   ├── audio.ts              # Silence, transcription types
│   └── take-detection.ts     # Take grouping types
```

---

## Manifest Updates Required

```json
{
  "requiredPermissions": {
    "network": {
      "domains": [
        "https://api.splice.com",
        "https://*.r2.cloudflarestorage.com",  // File uploads
        "https://api.stripe.com"               // Billing redirects
      ]
    }
  }
}
```

---

## Implementation Order

### Week 1-2: Backend Foundation
- [ ] Set up Node.js + Express + PostgreSQL
- [ ] Implement auth routes (register, login, refresh)
- [ ] Set up Stripe products and webhook handling
- [ ] Create job queue with BullMQ + Redis
- [ ] Deploy to Railway/Render

### Week 2-3: Plugin Auth Integration
- [ ] Create AuthPanel component (login/signup)
- [ ] Replace local storage auth → backend sessions
- [ ] Create backend-client.ts API wrapper
- [ ] Update SettingsPanel to show account info

### Week 3-4: Dashboard MVP
- [ ] Next.js app with auth pages
- [ ] Dashboard home with usage stats
- [ ] Billing page with Stripe portal

### Week 4-5: Silence Detection
- [ ] Implement cloud audio processing workers (Whisper/Deepgram + FFmpeg)
- [ ] Create CuttingPanel UI
- [ ] Implement clip cutting using remove+re-insert workaround
- [ ] Build silence preview + confirmation flow

### Week 5-6: Take Detection
- [ ] Implement transcription → embedding → clustering pipeline
- [ ] Create TakeDetectionPanel UI
- [ ] Implement clip renaming + color labeling
- [ ] End-to-end testing

---

## Premiere Pro UXP API - Research Complete

### CONFIRMED AVAILABLE:
| Method | Purpose |
|--------|---------|
| `createSetNameAction(name)` | Rename clips on timeline |
| `createInsertProjectItemAction()` | Insert clips into sequence |
| `createOverwriteItemAction()` | Overwrite clips |
| `createRemoveItemsAction()` | Remove clips (with ripple option) |
| `createSetInPointAction/OutPointAction()` | Trim clip in/out points |
| `ProjectItem.setColorLabel()` | Set color on source items |

### CONFIRMED NOT AVAILABLE:
| Feature | Status |
|---------|--------|
| **Razor/Split clip** | NO direct method exists |
| **TrackItem.setColorLabel()** | Feature request DVAPR-4217788 - NOT in API |
| **Audio waveform data** | NOT exposed (must use external FFmpeg) |

### Cutting Workaround (Required):
Since no razor API exists, implement "cut" as:
1. Get original clip's in/out points and position
2. Remove original clip via `createRemoveItemsAction()`
3. Create first segment: adjust outPoint to cut time
4. Create second segment: adjust inPoint to cut time
5. Re-insert both via `createInsertProjectItemAction()`

### Color Coding Workaround:
- Set color on `ProjectItem` BEFORE inserting into sequence
- Existing trackItems won't update - must create new clips with pre-colored source

### Audio Processing:
- Must export audio externally (FFmpeg) - API doesn't expose waveforms
- Use `clip.mediaPath` to access source file for FFmpeg processing

**Sources:**
- [UXP SequenceEditor API](https://developer.adobe.com/premiere-pro/uxp/ppro_reference/classes/sequenceeditor/)
- [UXP VideoClipTrackItem](https://developer.adobe.com/premiere-pro/uxp/ppro_reference/classes/videocliptrackitem/)
- [Jumpcut Plugin](https://github.com/cameron-astor/jumpcut) - uses external FFmpeg
- [Adobe Community - Label Color Request](https://community.adobe.com/t5/premiere-pro-discussions/change-label-color-with-api-in-premiere/m-p/12585126)

---

## Pricing & Profit Margins (80%+ Target)

### Pricing Structure
| Plan | Price | Usage Limit | Our Cost | Margin |
|------|-------|-------------|----------|--------|
| Free Trial | $0 | 10 min total | ~$0.07 | Customer acquisition |
| Pro | $29.99/mo | 300 min/mo | $4.50 | **85%** |
| Enterprise | $69.99/mo | 500 min/mo | $12.50 | **82%** |

### Cost Breakdown per Minute
| Service | Free Trial | Pro | Enterprise |
|---------|------------|-----|------------|
| Transcription | Whisper ($0.006) | Deepgram ($0.0043) | Deepgram + Diarization ($0.007) |
| Vocal Isolation | Skip | Demucs ($0.01) | Dolby.io ($0.015) |
| Embeddings | Skip | OpenAI small ($0.0001) | OpenAI large ($0.0003) |
| **Total/min** | **$0.007** | **$0.015** | **$0.025** |

### Break-even Analysis
- **Pro**: Breaks even at 200 minutes used ($3.00 cost)
- **Enterprise**: Breaks even at 280 minutes used ($7.00 cost)
- Overage protection: Hard cap at plan limits, prompt to upgrade
