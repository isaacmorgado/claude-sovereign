# Plan: Replace BUILD SEQUENCE Section in main.js

## Overview
Replace the BUILD SEQUENCE (v3.5) section in `splice-plugin/js/main.js` with improved code that includes:
- Local ProjectItemType constants to fix 'undefined' errors
- Enhanced error handling and function robustness
- Global function exposure for testing

## Current State
**File:** `splice-plugin/js/main.js`
- Current BUILD SEQUENCE section: Lines 1089-1233
- Replacement starts at: Line 1090 (comment: `// BUILD SEQUENCE (v3.5 - Direct DOM Reconstruction)`)
- Replacement ends before: Line 1235 (comment: `// TIMELINE SEEK`)

## Changes Summary

### 1. Add ProjectItemType Constants (New)
Define local constants to avoid UXP API version inconsistencies:
```javascript
const ProjectItemType = {
    CLIP: 1,
    BIN: 2,
    ROOT: 3,
    FILE: 4
};
```

### 2. Improve findFirstMediaItem()
- Add JSDoc comments
- Use local ProjectItemType constant instead of `ppro.Constants.ProjectItemType.CLIP`
- Better error handling

### 3. Enhance buildSequenceV35()
- More robust error checking
- Better logging for debugging
- Uses local constants

### 4. Improve buildSequenceWithCutList()
- Fallback to localhost if BACKEND_URL undefined
- Check for showProgress function before calling
- Better error messages
- Improved validation

### 5. Global Function Exposure (New)
Add at end of section:
```javascript
if (typeof window !== 'undefined') {
    window.buildSequenceV35 = buildSequenceV35;
    window.buildSequenceWithCutList = buildSequenceWithCutList;
    window.findFirstMediaItem = findFirstMediaItem;
}
```

## Implementation Steps

1. **Read current file** (already done)
   - Verified line numbers match
   - Confirmed TIMELINE SEEK section starts at line 1235

2. **Perform replacement**
   - Extract lines 1089-1233 as old_string
   - Replace with provided new code
   - Preserve all code before line 1089
   - Preserve all code from line 1235 onwards (TIMELINE SEEK, AUDIO EXPORT sections)

3. **Verify**
   - Check that file structure is intact
   - Ensure no code from other sections was affected

## Critical Files
- `splice-plugin/js/main.js` (lines 1089-1233)

## Risk Assessment
- **Low risk**: Direct code replacement with clear boundaries
- **No breaking changes**: Functions have same signatures
- **Improvement**: Better error handling and constants definition
