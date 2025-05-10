#!/usr/bin/env python3
"""
POKEY Sound Chip Emulator Python Example
This example demonstrates how to use the POKEY C++ library from Python using CFFI.
"""

import cffi
import sounddevice as sd
import time
from pathlib import Path
import numpy as np
import wave

# Load the POKEY emulator library using CFFI
ffi = cffi.FFI()
ffi.cdef("""
    typedef struct POKEY POKEY;
    
    POKEY* pokey_create(int sample_rate);
    void pokey_destroy(POKEY* pokey);
    
    void pokey_set_audctl(POKEY* pokey, uint8_t value);
    void pokey_set_audf(POKEY* pokey, int channel, uint8_t value);
    void pokey_set_audc(POKEY* pokey, int channel, uint8_t value);
    void pokey_set_console(POKEY* pokey, uint8_t value);
    
    void pokey_feed(POKEY* pokey, const uint8_t* buffer, int buffer_size);
    void pokey_process_events(POKEY* pokey, double current_frame);
    float pokey_get_sample(POKEY* pokey);
    void pokey_generate_samples(POKEY* pokey, float* buffer, int num_samples);
""")

so_path = Path('pokey/lib/libpokey.so').resolve()
lib = ffi.dlopen(str(so_path))

SAMPLE_RATE  = 48_000      # same rate you compiled POKEY for
BUFFER_SIZE  = 512         # how many frames to pull per C-side call
TONE_SECONDS = 1.0

def write_simple_tone_wav(filename: str | Path = "pokey_tone.wav"):
    """Generate a 1-second pure tone with the POKEY emulator and save it as a WAV."""
    frames_total = int(SAMPLE_RATE * TONE_SECONDS)

    # ---- create & configure POKEY ----
    pokey = lib.pokey_create(SAMPLE_RATE)
    lib.pokey_set_audctl(pokey, 0)          # default AUDCTL
    lib.pokey_set_audf(pokey, 0, 20)        # frequency divider
    lib.pokey_set_audc(pokey, 0, 0xAA)  # volume 10, distortion 10

    # ---- generate samples ----
    samples = np.empty((frames_total, 2), dtype=np.float32)   # stereo buffer
    pulled   = 0
    c_buf    = ffi.new("float[]", BUFFER_SIZE)

    while pulled < frames_total:
        chunk = min(BUFFER_SIZE, frames_total - pulled)
        lib.pokey_generate_samples(pokey, c_buf, chunk)
        # copy CFFI buffer into NumPy array
        np_chunk = np.frombuffer(ffi.buffer(c_buf, chunk * ffi.sizeof("float")),
                                 dtype=np.float32)
        samples[pulled : pulled + chunk, 0] = np_chunk        # left
        samples[pulled : pulled + chunk, 1] = np_chunk        # right
        pulled += chunk

    lib.pokey_destroy(pokey)

    # ---- convert to 16-bit PCM and write .wav ----
    pcm16 = np.clip(samples * 32767.0, -32768, 32767).astype(np.int16)

    with wave.open(str(filename), "wb") as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)          # 16-bit
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(pcm16.tobytes())

    print(f"Wrote {filename}  ({TONE_SECONDS} s, {SAMPLE_RATE} Hz stereo)")

if __name__ == "__main__":
    write_simple_tone_wav()