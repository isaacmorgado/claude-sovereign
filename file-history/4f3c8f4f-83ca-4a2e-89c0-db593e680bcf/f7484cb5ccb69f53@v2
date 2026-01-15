#!/usr/bin/env python3
"""
Audio Analysis Script for Suno AI Prompt Generation
Uses Essentia for accurate BPM, key, and audio feature extraction
"""

import sys
import json
import os


def analyze_with_essentia(audio_file):
    """Analyze audio file using Essentia library"""
    try:
        import essentia.standard as es
    except ImportError:
        return {
            "error": "essentia_not_installed",
            "message": "Essentia library not installed. Run: pip install essentia-tensorflow",
        }

    try:
        # Load audio file
        audio = es.MonoLoader(filename=audio_file, sampleRate=44100)()

        # BPM and Beat Detection
        rhythm_extractor = es.RhythmExtractor2013(method="multifeature")
        bpm, beats, beats_confidence, _, beats_intervals = rhythm_extractor(audio)

        # Key Detection
        key_extractor = es.KeyExtractor()
        key, scale, key_strength = key_extractor(audio)

        # Additional Audio Features
        # Spectral features
        spectral_complexity = es.SpectralComplexity()
        windowing = es.Windowing(type="blackmanharris62")
        spectrum = es.Spectrum()

        # Analyze frames for average spectral complexity
        frame_size = 2048
        hop_size = 1024
        complexities = []

        for i in range(0, len(audio) - frame_size, hop_size):
            frame = audio[i : i + frame_size]
            windowed = windowing(frame)
            spec = spectrum(windowed)
            complexity = spectral_complexity(spec)
            complexities.append(complexity)

        avg_complexity = sum(complexities) / len(complexities) if complexities else 0

        # Energy and Dynamics
        energy_extractor = es.Energy()
        dynamic_complexity = es.DynamicComplexity()

        energies = []
        for i in range(0, len(audio) - frame_size, hop_size):
            frame = audio[i : i + frame_size]
            energy = energy_extractor(frame)
            energies.append(energy)

        avg_energy = sum(energies) / len(energies) if energies else 0
        dynamics = dynamic_complexity(audio)

        # Determine mood/vibe based on features
        mood = determine_mood(bpm, key_strength, avg_energy, dynamics, avg_complexity)

        return {
            "success": True,
            "bpm": round(bpm, 1),
            "key": key,
            "scale": scale,
            "key_confidence": round(key_strength, 3),
            "beat_confidence": round(beats_confidence, 3),
            "num_beats": len(beats),
            "avg_energy": round(avg_energy, 3),
            "dynamics": round(dynamics, 3),
            "spectral_complexity": round(avg_complexity, 3),
            "mood": mood,
            "duration_seconds": round(len(audio) / 44100.0, 1),
        }

    except Exception as e:
        return {
            "error": "analysis_failed",
            "message": f"Audio analysis failed: {str(e)}",
        }


def determine_mood(bpm, key_strength, energy, dynamics, complexity):
    """Determine mood based on audio features"""
    moods = []

    # BPM-based mood
    if bpm < 80:
        moods.append("slow")
        moods.append("chill")
    elif bpm < 100:
        moods.append("laid-back")
    elif bpm < 120:
        moods.append("moderate")
    elif bpm < 140:
        moods.append("upbeat")
    else:
        moods.append("fast")
        moods.append("energetic")

    # Energy-based mood
    if energy > 0.1:
        moods.append("powerful")
    elif energy > 0.05:
        moods.append("dynamic")
    else:
        moods.append("soft")

    # Dynamics-based mood
    if dynamics > 0.5:
        moods.append("varied")
    elif dynamics < 0.2:
        moods.append("consistent")

    # Complexity-based mood
    if complexity > 0.5:
        moods.append("complex")
        moods.append("textured")
    elif complexity < 0.2:
        moods.append("clean")
        moods.append("minimal")

    # Key strength based mood
    if key_strength > 0.7:
        moods.append("tonal")
    elif key_strength < 0.4:
        moods.append("ambient")
        moods.append("atmospheric")

    return ", ".join(list(dict.fromkeys(moods[:5])))  # Return up to 5 unique moods


def analyze_with_librosa(audio_file):
    """Fallback: Analyze audio file using librosa"""
    try:
        import librosa
        import numpy as np
    except ImportError:
        return {
            "error": "librosa_not_installed",
            "message": "Librosa library not installed. Run: pip install librosa",
        }

    try:
        # Load audio
        y, sr = librosa.load(audio_file)

        # Tempo detection
        tempo, beats = librosa.beat.beat_track(y=y, sr=sr)

        # Key detection using chroma features
        chromagram = librosa.feature.chroma_cqt(y=y, sr=sr)

        # Key detection (simplified Krumhansl-Schmuckler)
        key_names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        chroma_vals = np.mean(chromagram, axis=1)
        key_idx = np.argmax(chroma_vals)
        key = key_names[key_idx]

        # Determine scale (major/minor) based on chroma pattern
        # Major has stronger 3rd and 5th, minor has stronger minor 3rd
        major_profile = [1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1]
        minor_profile = [1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0]

        # Rotate profiles to match detected key
        major_corr = np.corrcoef(chroma_vals, np.roll(major_profile, key_idx))[0, 1]
        minor_corr = np.corrcoef(chroma_vals, np.roll(minor_profile, key_idx))[0, 1]

        scale = "major" if major_corr > minor_corr else "minor"
        key_confidence = max(major_corr, minor_corr)

        # Energy calculation
        rms = librosa.feature.rms(y=y)
        avg_energy = float(np.mean(rms))

        # Duration
        duration = librosa.get_duration(y=y, sr=sr)

        # Simple mood determination
        mood_parts = []
        if tempo < 90:
            mood_parts.append("slow, chill")
        elif tempo < 120:
            mood_parts.append("moderate, groovy")
        else:
            mood_parts.append("upbeat, energetic")

        if avg_energy > 0.1:
            mood_parts.append("powerful")
        else:
            mood_parts.append("soft")

        return {
            "success": True,
            "bpm": round(float(tempo), 1),
            "key": key,
            "scale": scale,
            "key_confidence": round(float(key_confidence), 3),
            "num_beats": len(beats),
            "avg_energy": round(avg_energy, 3),
            "mood": ", ".join(mood_parts),
            "duration_seconds": round(duration, 1),
            "method": "librosa",
        }

    except Exception as e:
        return {
            "error": "analysis_failed",
            "message": f"Librosa analysis failed: {str(e)}",
        }


def main():
    if len(sys.argv) < 2:
        print(
            json.dumps(
                {"error": "no_input", "message": "Usage: analyze-audio.py <audio_file>"}
            )
        )
        sys.exit(1)

    audio_file = sys.argv[1]

    if not os.path.exists(audio_file):
        print(
            json.dumps(
                {
                    "error": "file_not_found",
                    "message": f"Audio file not found: {audio_file}",
                }
            )
        )
        sys.exit(1)

    # Try Essentia first (more accurate)
    result = analyze_with_essentia(audio_file)

    # Fall back to librosa if Essentia fails
    if "error" in result and result["error"] in [
        "essentia_not_installed",
        "analysis_failed",
    ]:
        result = analyze_with_librosa(audio_file)

    # Output JSON result
    print(json.dumps(result, indent=2))

    # Exit with error code if analysis failed
    if "error" in result:
        sys.exit(1)


if __name__ == "__main__":
    main()
