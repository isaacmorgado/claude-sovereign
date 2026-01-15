# Plan: Update SPLICE Docs with Speed-First Architecture

## Summary
Update `Concept_Clarification.md` to reflect the speed-first, cloud-optimized architecture using:
- **Replicate** for Demucs vocal isolation (MVP approach)
- **Groq Whisper** for transcription (10x faster, 6x cheaper than OpenAI)
- Target: 83%+ profit margins with fastest possible processing

## Files to Modify

| File | Action |
|------|--------|
| `/Users/imorgado/SPLICE/Concept_Clarification.md` | Update architecture and costs |

## Changes to Make

### 1. Update Technical Decisions Table
Change transcription provider from Whisper to Groq Whisper, add Replicate for vocal isolation:

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Transcription | Groq Whisper | 10x faster, 6x cheaper than OpenAI |
| Vocal Isolation | Replicate (Demucs) | Zero infrastructure, pre-built API |

### 2. Update Technical Architecture Diagram
Replace self-hosted Demucs GPU cluster with Replicate API:
```
Audio → Replicate (Demucs) → Groq Whisper → GPT-4o-mini → Results
```

Remove the "Demucs GPU Infrastructure" section (no longer self-hosted).

### 3. Update Infrastructure Cost Analysis
Replace self-hosted GPU costs with Replicate pricing:

| Component | Cost |
|-----------|------|
| Groq Whisper | $0.001/min |
| Replicate Demucs | ~$0.015/min |
| GPT-4o-mini | ~$0.0001/job |

Update margin calculations:
- Creator: 83.6% margin
- Pro: 85%+ margin

### 4. Update Processing Speed Section
Add speed benchmarks showing cloud advantage:
- 10 min footage → ~60 seconds total processing
- Groq transcription: 8 seconds (vs 30-60 sec local)
- Replicate Demucs: 40 seconds

### 5. Update Open Items
Replace self-hosted GPU tasks with Replicate integration:
- [ ] Set up Replicate API integration for Demucs
- [ ] Set up Groq API integration for Whisper
- [ ] Implement progress tracking for multi-step pipeline

## Implementation Order
1. Update Technical Decisions table (add Groq, Replicate)
2. Update Technical Architecture diagram (remove self-hosted GPU)
3. Update Infrastructure Cost Analysis (Replicate pricing)
4. Add speed benchmarks section
5. Update Open Items checklist
