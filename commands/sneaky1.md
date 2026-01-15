---
description: Process audio to preserve style while evading detection (Self-VC + Remix).
---

# Sneaky 1 (Style Preservation)

Transforms audio to evade copyright detection while maintaining the original singer's style and instrumental backing.

## Usage

```bash
/sneaky1 <input_audio_path> [--output <output_path>]
```

## Implementation

This command wraps the `sneaky_wrapper.py` script with the `--sneaky1` flag.

1.  **Isolate:** Separates vocals and instrumentals.
2.  **Perturb:** Shifts pitch/speed of *both* tracks identically to evade matching.
3.  **Sanitize:** Removes fingerprints from vocals.
4.  **Self-VC:** Re-synthesizes vocals using the perturbed original as a reference (Zero-shot VC).
5.  **Remix:** Combines the new vocals with the perturbed instrumental.

## Script

```python
import sys
import os
import subprocess

# Path to the wrapper script
WRAPPER_SCRIPT = os.path.expanduser("~/.claude/tools/sneaky_wrapper.py")
VENV_PYTHON = os.path.expanduser("~/.claude/tools/sneaky_venv/bin/python")

def main():
    if len(sys.argv) < 2:
        print("Usage: /sneaky1 <input_audio> [--output <path>]")
        sys.exit(1)

    # Pass all arguments to the wrapper, appending --sneaky1
    args = [VENV_PYTHON, WRAPPER_SCRIPT] + sys.argv[1:] + ["--sneaky1"]
    
    try:
        subprocess.check_call(args)
    except subprocess.CalledProcessError as e:
        sys.exit(e.returncode)

if __name__ == "__main__":
    main()
```
