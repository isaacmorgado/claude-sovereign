#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
import shutil
from pathlib import Path
import numpy as np
import scipy.signal
import soundfile as sf
import librosa

# Configuration
TOOLS_DIR = Path.home() / ".claude/tools"
SNEAKY_LIBS = TOOLS_DIR / "sneaky_libs"
VENV_PYTHON = TOOLS_DIR / "sneaky_venv/bin/python"

def run_command(command, cwd=None, env=None):
    """Run a shell command."""
    print(f"Executing: {' '.join(str(c) for c in command)}")
    if env is None:
        env = os.environ.copy()
    subprocess.check_call(command, cwd=cwd, env=env)

def isolate_vocals(input_file, output_dir, extract_instrumental=False):
    """Isolate vocals (and instrumental) using torchaudio HDemucs."""
    import torch
    import torchaudio
    from torchaudio.pipelines import HDEMUCS_HIGH_MUSDB_PLUS
    
    device = "mps" if torch.backends.mps.is_available() else "cpu"
    print(f"Using {device.upper()} acceleration.")
    
    bundle = HDEMUCS_HIGH_MUSDB_PLUS
    model = bundle.get_model()
    model.to(device)
    
    # Load audio using soundfile to avoid TorchCodec issues
    print(f"Loading audio: {input_file}")
    wav, sr = sf.read(input_file)
    wav = torch.from_numpy(wav).float()
    if wav.ndim == 1:
        wav = wav.unsqueeze(0) # (1, samples)
    else:
        wav = wav.t() # (channels, samples)
    
    sample_rate = bundle.sample_rate
    if sr != sample_rate:
        print(f"Resampling from {sr} to {sample_rate}...")
        resampler = torchaudio.transforms.Resample(sr, sample_rate).to(wav.device)
        # Move wav to device if needed, or keeping on CPU is fine for resample
        wav = resampler(wav)

    wav = wav.to(device)
    # Normalize
    ref = wav.mean(0)
    wav = (wav - ref.mean()) / ref.std()
    
    # Separate
    print("Running separation (this may take a while)...")
    sources = model(wav[None]) # (batch, sources, channels, time)
    sources = sources[0] # (sources, channels, time)
    
    # Sources map: starts with drums, bass, other, vocals
    # HDemucs sources: ["drums", "bass", "other", "vocals"]
    
    vocals = sources[3]
    vocals_path = output_dir / "vocals.wav"
    sf.write(vocals_path, vocals.detach().cpu().numpy().T, sample_rate)
    
    instrumental_path = None
    if extract_instrumental:
        # Instrumental = Mix - Vocals OR Sum(others)
        # Summing others is safer to avoid artifacts
        instrumental = sources[0] + sources[1] + sources[2]
        instrumental_path = output_dir / "instrumental.wav"
        sf.write(instrumental_path, instrumental.detach().cpu().numpy().T, sample_rate)
        
    return vocals_path, instrumental_path

def remove_fingerprints(input_file, output_file):
    """Run the AI fingerprint remover tool."""
    script = SNEAKY_LIBS / "ai-audio-fingerprint-remover/ai_audio_fingerprint_remover.py"
    # Use aggressive mode
    cmd = [VENV_PYTHON, script, input_file, output_file, "--aggressive"]
    
    # Config env to ensure dependencies are found
    env = os.environ.copy()
    env["PYTHONPATH"] = str(SNEAKY_LIBS / "ai-audio-fingerprint-remover")
    
    run_command(cmd, cwd=SNEAKY_LIBS / "ai-audio-fingerprint-remover", env=env)
    return output_file

def apply_spectral_notching(y, sr):
    """Apply random spectral notching to break frequency-based hashes."""
    # Create 3-5 random notch filters
    num_notches = np.random.randint(3, 6)
    for _ in range(num_notches):
        # Target typical vocal/music frequencies (200Hz - 8kHz)
        freq = np.random.uniform(200, 8000)
        # Narrow bandwidth (high Q) to be imperceptible
        Q = 30.0 
        b, a = scipy.signal.iirnotch(freq, Q, sr)
        y = scipy.signal.filtfilt(b, a, y)
    return y

def apply_stereo_remap(y):
    """Slightly alter Stereo image (Mid/Side processing)."""
    # y shape: (channels, samples)
    if y.ndim < 2 or y.shape[0] < 2:
        return y
        
    # Convert to Mid-Side
    mid = (y[0] + y[1]) * 0.5
    side = (y[0] - y[1]) * 0.5
    
    # Alter balance slightly (imperceptible widening/narrowing)
    # 95-105% width
    width_factor = np.random.uniform(0.95, 1.05)
    side *= width_factor
    
    # Back to L/R
    l = mid + side
    r = mid - side
    
    return np.stack([l, r])

def apply_saturation(y, drive=0.5):
    """Apply soft-clipping saturation to add harmonics."""
    # Tanh distortion
    return np.tanh(y * (1 + drive))

def perturb_audio(input_file, output_file, pitch_shift=0.0, speed_rate=1.0, severe=False):
    """Apply subtle signal perturbations (Notching, Stereo, Saturation). Optional Geometric."""
    print(f"--- Applying Advanced Perturbation (Pitch: {pitch_shift}, Speed: {speed_rate}) ---")
    
    # Load
    y, sr = librosa.load(input_file, sr=None, mono=False)
    
    # Ensure 2D for consistent processing
    if y.ndim == 1:
        y = y[np.newaxis, :]

    # 1. Spectral Notching (Destroys peaks)
    y_notched = []
    for c in range(y.shape[0]):
        y_notched.append(apply_spectral_notching(y[c], sr))
    y = np.stack(y_notched)

    # 2. Stereo Remap (Changes spatial hash)
    y = apply_stereo_remap(y)
    
    # 3. Saturation (Adds harmonics)
    # Subtle drive for vibe preservation
    y = apply_saturation(y, drive=0.1)

    # 4. Geometric (Pitch/Time) - Only if requested
    y_final = []
    has_geometric = (pitch_shift != 0.0 or abs(speed_rate - 1.0) > 0.001)
    
    if has_geometric:
        for c in range(y.shape[0]):
            tr = y[c]
            # Pitch
            if pitch_shift != 0.0:
                tr = librosa.effects.pitch_shift(tr, sr=sr, n_steps=pitch_shift)
            # Time
            if abs(speed_rate - 1.0) > 0.001:
                tr = librosa.effects.time_stretch(tr, rate=speed_rate)
            y_final.append(tr)
        y = np.stack(y_final)

    sf.write(output_file, y.T, sr)
    return output_file

def convert_voice(source_file, target_voice, output_dir):
    """Run Seed-VC inference."""
    # Setup paths
    seed_vc_dir = SNEAKY_LIBS / "Seed-VC"
    inference_script = seed_vc_dir / "inference.py"
    
    # If no target provided, use a default from examples (OR use the source itself for Self-VC)
    if target_voice is None:
        target_voice = seed_vc_dir / "examples/reference/s1p1.wav"
    
    # Define cmd
    cmd = [
        VENV_PYTHON, inference_script,
        "--source", source_file,
        "--target", target_voice,
        "--output", output_dir,
        "--f0-condition", "True", # Enable F0 for 44.1kHz and better melody preservation
        "--diffusion-steps", "30",
        "--length-adjust", "1.0",
        "--inference-cfg-rate", "0.7",
        "--auto-f0-adjust", "False"  # Keep original key strictly
    ]
    
    # Seed-VC needs PYTHONPATH
    env = os.environ.copy()
    env["PYTHONPATH"] = str(seed_vc_dir)
    
    print("Executing Seed-VC...")
    run_command(cmd, cwd=seed_vc_dir, env=env)
    
    # Find output
    files = list(output_dir.glob("*.wav"))
    files.sort(key=os.path.getmtime)
    return files[-1]

def mix_tracks(vocals, instrumental, output_file):
    """Mix vocals and instrumental back together."""
    print("--- Step 4: Mixing Tracks ---")

    # Load as mono=False to get (channels, samples)
    v, sr_v = librosa.load(vocals, sr=None, mono=False)
    i, sr_i = librosa.load(instrumental, sr=None, mono=False)
    
    # Resample vocals if needed to match instrumental (Master Clock)
    if sr_v != sr_i:
        print(f"Resampling vocabls from {sr_v} to {sr_i}...")
        v_resampled = []
        # Handle multi-channel
        if v.ndim == 1:
            v_resampled = librosa.resample(v, orig_sr=sr_v, target_sr=sr_i)
            v = v_resampled
        else:
            v_list = []
            for c in range(v.shape[0]):
                v_list.append(librosa.resample(v[c], orig_sr=sr_v, target_sr=sr_i))
            v = np.stack(v_list)
        sr_v = sr_i
    
    # Ensure 2D (channels, samples)
    if v.ndim == 1: v = v[np.newaxis, :]
    if i.ndim == 1: i = i[np.newaxis, :]
    
    # Ensure same number of channels
    if v.shape[0] != i.shape[0]:
        if v.shape[0] == 1: v = np.repeat(v, i.shape[0], axis=0)
        elif i.shape[0] == 1: i = np.repeat(i, v.shape[0], axis=0)

    # Ensure same length
    min_len = min(v.shape[1], i.shape[1])
    v = v[:, :min_len]
    i = i[:, :min_len]
    
    # Mix
    mix = v + i
    
    # Prevent clipping (Soft Limit instead of Hard Clip)
    max_val = np.max(np.abs(mix))
    if max_val > 0.99:
        print(f"Normalizing mix (Peak: {max_val:.2f})...")
        mix = mix / max_val * 0.99
    
    print(f"Saving mix to {output_file} ({sr_i} Hz)...")
    sf.write(output_file, mix.T, sr_i)
    return output_file

def main():
    parser = argparse.ArgumentParser(description="Sneaky Audio Processor")
    parser.add_argument("input_file", help="Path to input audio file")
    parser.add_argument("--output", help="Path to output file", default=None)
    parser.add_argument("--extract-instrumental", action="store_true", help="Extract instrumental track")
    parser.add_argument("--skip-vc", action="store_true", help="Skip voice conversion (isolation only)")
    parser.add_argument("--perturb", action="store_true", default=True, help="Apply perturbation")
    parser.add_argument("--sneaky1", action="store_true", help="Preserve style (Self-VC + Remix)")
    
    args = parser.parse_args()
    
    input_path = os.path.abspath(args.input_file)
    if not os.path.exists(input_path):
        print(f"Error: Input file {input_path} not found.")
        sys.exit(1)
        
    # Setup work dir
    work_dir = Path("/tmp/sneaky_work")
    if work_dir.exists():
        shutil.rmtree(work_dir)
    work_dir.mkdir(parents=True, exist_ok=True)
    
    # Define output paths
    if args.output:
        output_path = os.path.abspath(args.output)
    else:
        base = os.path.splitext(os.path.basename(input_path))[0]
        output_path = os.path.join(os.path.expanduser("~/Desktop"), f"{base}_sneaky.wav")

    # 1. Isolate
    print(f"--- Step 1: Isolating Tracks with Torchaudio HDemucs ---")
    vocals_path, instrumental_path = isolate_vocals(input_path, work_dir, extract_instrumental=True)

    if args.extract_instrumental:
        inst_final = output_path.replace(".wav", "_instrumental.wav")
        shutil.copy(instrumental_path, inst_final)
        print(f"Instrumental saved to: {inst_final}")

    if args.sneaky1:
        print("\n>>> Running /sneaky1 Mode: Styled Vibe Preservation <<<")
        
        # A. Instrumental: "Clean" but with invisible evasion
        p_instrumental = work_dir / "perturbed_instrumental.wav"
        print("--- Processing Instrumental (Vibe Safe) ---")
        perturb_audio(instrumental_path, p_instrumental, pitch_shift=0.0, speed_rate=1.0)
        
        # B. Vocals: Clean -> Self-VC (Rewrite) -> Invisible Evasion
        cleaned_vocals = work_dir / "cleaned_vocals.wav"
        print("--- Processing Vocals: Fingerprint Removal ---")
        remove_fingerprints(vocals_path, cleaned_vocals)
        
        print("--- Processing Vocals: Self-VC (Style Preservation) ---")
        # Use cleaned vocals as source AND target for style preservation
        final_vocals_raw = convert_voice(cleaned_vocals, cleaned_vocals, work_dir)
        
        # Apply invisible perturbation to result
        final_vocals = work_dir / "final_vocals_perturbed.wav"
        perturb_audio(final_vocals_raw, final_vocals, pitch_shift=0.0, speed_rate=1.0)

        # C. Mix
        mix_tracks(final_vocals, p_instrumental, output_path)
        print(f"\n✅ Sneaky1 Complete! Output saved to: {output_path}")
        return

    # Standard Sneaky Pipeline
    current_vocals = vocals_path
    if args.perturb:
        p_vocals = work_dir / "perturbed_vocals.wav"
        # Standard evasion (0.5 pitch / 1.02 speed)
        perturb_audio(current_vocals, p_vocals, pitch_shift=0.5, speed_rate=1.02)
        current_vocals = p_vocals
        
    cleaned_vocals = work_dir / "cleaned_vocals.wav"
    print("--- Step 2: Removing AI Fingerprints ---")
    remove_fingerprints(current_vocals, cleaned_vocals)
    
    if args.skip_vc:
        shutil.copy(cleaned_vocals, output_path)
        print(f"Skipped VC. Output saved to: {output_path}")
    else:
        print("--- Step 3: converting Voice with Seed-VC ---")
        final_output = convert_voice(cleaned_vocals, None, work_dir)
        shutil.copy(final_output, output_path)
        print(f"Output saved to: {output_path}")

if __name__ == "__main__":
    main()
