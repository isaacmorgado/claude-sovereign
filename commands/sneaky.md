---
description: Process audio to isolate vocals, remove fingerprints, and re-synthesize.
---

# Sneaky Audio Processor

This command processes an audio file to isolate vocals or instrumentals, remove AI fingerprints, and optionally re-synthesize the vocals.

## Usage

```bash
/sneaky <input_audio_path> [--target-voice <reference_audio>] [--output <output_path>] [--extract-instrumental] [--skip-vc]
```

## Implementation

The command delegates to a python wrapper script that manages the pipeline.

```python
import sys
import subprocess
from pathlib import Path

# Path to the wrapper script
WRAPPER_SCRIPT = Path.home() / ".claude/tools/sneaky_wrapper.py"
TOOLS_DIR = Path.home() / ".claude/tools"
VENV_PYTHON = TOOLS_DIR / "sneaky_venv/bin/python"

def main():
    # Pass all arguments to the wrapper
    cmd = [str(VENV_PYTHON), str(WRAPPER_SCRIPT)] + sys.argv[1:]
    
    try:
        subprocess.check_call(cmd)
    except subprocess.CalledProcessError:
        sys.exit(1)

if __name__ == "__main__":
    main()
```
