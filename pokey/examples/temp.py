import wave
import numpy as np
from pathlib import Path

# Constants
SAMPLE_RATE = 8192
VOLUME = 1  # 0–10 scale
OUT_DIR = Path("poly_lfsr_waves")
OUT_DIR.mkdir(exist_ok=True)

# LFSR implementations
def poly4_next(v):
    feedback_bit = ((v << 4) ^ (v << 1)) & 0x10
    return (v >> 1) | feedback_bit

def poly5_next(v):
    feedback_bit = (~((v >> 2) ^ (v >> 4)) & 1)
    return ((v << 1) | feedback_bit) & 0x1F

def poly9_next(v):
    feedback_bit = ((v << 8) ^ (v << 3)) & 0x100
    return ((v >> 1) | feedback_bit) & 0x1FF

def poly17_next(v):
    feedback_bit = ((v << 16) ^ (v << 11)) & 0x10000
    return (v >> 1) | feedback_bit

# General waveform generator
def generate_poly_waveform(lfsr_func, period, num_periods=1, volume=10):
    v = 1
    scale = np.clip(volume / 10.0, 0.0, 1.0)
    length = period * num_periods
    samples = np.empty(length, dtype=np.uint8)

    for i in range(length):
        raw = 1.0 if (v & 1) else -1.0
        normalized = (raw * scale + 1.0) * 127.5
        samples[i] = int(normalized)
        v = lfsr_func(v)

    return samples

# Save to WAV
def save_to_wav_8bit(samples: np.ndarray, filename: Path, samplerate: int):
    with wave.open(str(filename), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(1)
        wf.setframerate(samplerate)
        wf.writeframes(samples.tobytes())
    print(f"Wrote {filename}  ({len(samples)/samplerate:.3f} sec, 8-bit unsigned)")

# LFSR configs
poly17_period = (1 << 17) - 1
lfsrs = {
    "poly4":  (poly4_next,  (1 << 4) - 1),
    "poly5":  (poly5_next,  (1 << 5) - 1),
    "poly9":  (poly9_next,  (1 << 9) - 1),
    "poly17": (poly17_next, poly17_period),
}

# Generate and export each
for name, (func, period) in lfsrs.items():
    num_periods = poly17_period // period
    samples = generate_poly_waveform(func, period, num_periods=num_periods, volume=VOLUME)
    save_to_wav_8bit(samples, OUT_DIR / f"{name}.wav", SAMPLE_RATE)
