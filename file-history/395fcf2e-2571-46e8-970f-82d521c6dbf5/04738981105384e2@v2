# Custom Presets and Custom Bleep Audio

## Summary
Add two features to SPLICE:
1. **Custom Presets** - Editors can create, save, edit, and delete named presets for silence detection
2. **Custom Bleep Audio** - Users can upload their own WAV/MP3 files for profanity bleeping

Both features use **local storage only** (localStorage + UXP persistent tokens).

---

## Part 1: Custom Presets

### Data Structure (localStorage key: `spliceCustomPresets`)
```javascript
{
  "version": 1,
  "presets": {
    "my-podcast-tight": {
      "id": "my-podcast-tight",
      "name": "My Podcast (Tight)",
      "description": "Tighter cuts for my style",
      "icon": "mic",
      "createdAt": "2025-01-15T10:30:00Z",
      "settings": {
        "sensitivity": 45,
        "threshold": -32,
        "minSilenceLength": 0.6,
        "paddingStart": 0.1,
        "paddingEnd": 0.08,
        "autoMarkBest": true,
        "enableTakesDetection": true
      }
    }
  },
  "order": ["my-podcast-tight"]
}
```

### Functions to Add (settings.js)
- `loadCustomPresets()` / `saveCustomPresets()`
- `createCustomPreset(preset)` - returns new ID
- `updateCustomPreset(id, updates)`
- `deleteCustomPreset(id)`
- `getAllPresets()` - merges built-in + custom
- `isBuiltInPreset(id)` - returns true for hardcoded presets

### UI Components (index.html)
1. Enhance preset selector with "+" save button and "..." manage button
2. Add preset modal for create/edit:
   - Name input, description input
   - Icon picker (mic, people, bolt, school, videocam, settings)
   - Settings preview showing current values
   - Save/Cancel buttons
3. Manage view: list custom presets with edit/delete buttons
4. Built-in presets show lock icon (cannot delete)

---

## Part 2: Custom Bleep Audio

### Data Structure (localStorage key: `spliceCustomBleeps`)
```javascript
{
  "version": 1,
  "bleepFolderToken": "uxp_persistent_token",
  "bleepFolderPath": "/Users/editor/SPLICE Bleeps",
  "bleeps": {
    "my-horn": {
      "id": "my-horn",
      "name": "Air Horn",
      "filename": "airhorn.wav",
      "format": "wav",
      "duration": 0.8,
      "addedAt": "2025-01-15T10:30:00Z"
    }
  },
  "activeBleep": "standard",
  "bleepVolume": 0.7
}
```

### New File: bleepManager.js
- `setupBleepFolder()` - prompt user to select folder, create persistent token
- `addCustomBleep(file)` - copy file to bleep folder, add to registry
- `removeCustomBleep(id)` - delete file and remove from registry
- `getAllBleeps()` - returns built-in + custom bleeps
- `getActiveBleep()` / `setActiveBleep(id)`
- `previewBleep(id)` - play audio preview

### UI Components (index.html - in Settings modal)
1. Bleep selector dropdown with optgroups (Built-in / Custom)
2. Preview button to test selected bleep
3. Volume slider (0-100%)
4. "Set Folder" button for bleep storage location
5. "Add Bleep" button to add new audio file
6. Custom bleeps list with preview/delete buttons

### Backend Changes (profanityDetection.js)
Extend `generateBleepAudio()` to accept `customAudioBuffer` parameter:
```javascript
if (customAudioBuffer) {
  return processCustomBleepAudio(customAudioBuffer, duration, volume, outputPath);
}
```

---

## Files to Modify

| File | Changes |
|------|---------|
| `splice-plugin/js/settings.js` | Add custom preset CRUD functions |
| `splice-plugin/js/bleepManager.js` | **NEW** - Custom bleep management |
| `splice-plugin/index.html` | Preset modal, bleep selector UI |
| `splice-plugin/js/main.js` | Initialize bleepManager, wire UI handlers |
| `splice-backend/services/profanityDetection.js` | Add custom audio buffer support |

---

## Testing Protocol

Each feature implementation follows this workflow:
1. **Implement** - Add the code for the feature
2. **Test** - Run E2E test on that specific feature
3. **Analyze** - Look for bottlenecks, errors, edge cases
4. **Fix** - If issues found, fix them
5. **Retest** - Verify the fix works
6. **Move On** - Proceed to next feature

At phase end: Run comprehensive E2E test for all phase features.

---

## Implementation Order

### Phase 1: Custom Presets Foundation

**Feature 1.1: localStorage Schema**
- Add `CUSTOM_PRESETS_KEY = 'spliceCustomPresets'` constant
- Add `loadCustomPresets()` function
- Add `saveCustomPresets(data)` function
- **E2E Test**: Verify save/load round-trip, handle empty/corrupt data

**Feature 1.2: Create Preset Function**
- Add `createCustomPreset(preset)` function
- Generate slugified ID from name
- Handle duplicate name collision
- Add validation (name required, settings valid)
- **E2E Test**: Create preset, verify storage, test duplicate handling

**Feature 1.3: Update Preset Function**
- Add `updateCustomPreset(id, updates)` function
- Preserve fields not being updated
- Validate preset exists before update
- **E2E Test**: Update name, settings, verify persistence

**Feature 1.4: Delete Preset Function**
- Add `deleteCustomPreset(id)` function
- Remove from presets object and order array
- Handle non-existent ID gracefully
- **E2E Test**: Delete preset, verify removal, test missing ID

**Feature 1.5: Merge Built-in + Custom**
- Add `isBuiltInPreset(id)` function
- Update `getAllPresets()` to merge arrays
- Custom presets appear after built-in
- Built-in presets marked with `isBuiltIn: true`
- **E2E Test**: Verify merge order, built-in protection, list integrity

**Phase 1 Final Test**: Run all 5 feature tests together, verify:
- No localStorage corruption between operations
- Performance (all operations < 5ms)
- No memory leaks in repeated operations
- Backward compatibility with existing settings

---

### Phase 2: Custom Presets UI
4. Add "+" and "..." buttons to preset selector
5. Create preset modal (create/edit form)
6. Add manage view with preset list
7. Wire up create/edit/delete handlers

### Phase 3: Custom Bleeps Foundation
8. Create `bleepManager.js` module
9. Implement folder setup with persistent token
10. Implement add/remove bleep functions

### Phase 4: Custom Bleeps UI
11. Add bleep selector to settings modal
12. Add folder configuration UI
13. Add custom bleep list with preview/delete
14. Wire up audio preview

### Phase 5: Backend Integration
15. Extend `generateBleepAudio()` for custom audio
16. Handle format conversion (MP3 to WAV if needed)

### Phase 6: Final Integration Testing
17. Test preset create/edit/delete flows
18. Test bleep file handling and preview
19. Verify backward compatibility
20. Comprehensive E2E test of all features

---

## Continuation Prompt Template

After completing each phase, generate a continuation prompt:

```
# SPLICE Phase [N+1] Continuation

## Context
Phase [N] completed successfully with [X] tests passing.

## Completed Features
- [List features from Phase N]

## Phase [N+1] Tasks
[Detailed task list with testing protocol]

## Key Files
- [File paths to modify]

## Testing Protocol
After each feature: E2E test → fix bottlenecks → retest → proceed
```

---

## Backward Compatibility

- Built-in presets remain locked (cannot edit/delete)
- Custom preset IDs use slugified names to avoid collision
- Default bleep remains 'standard' (1kHz sine wave)
- Missing custom bleep files fall back to 'standard'
- Existing settings preserved during upgrade
