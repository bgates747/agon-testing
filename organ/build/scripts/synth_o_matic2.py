import numpy as np
import soundfile as sf
from pydub import AudioSegment
from pydub.playback import play
from scipy.fft import fft, fftfreq
import os

# Function to load an audio file and convert to numpy array
def load_audio(input_dir, input_file, sample_rate):
    file_path = f"{input_dir}/{input_file}"
    audio = AudioSegment.from_file(file_path)
    audio = audio.set_frame_rate(sample_rate).set_channels(1)
    samples = np.array(audio.get_array_of_samples())
    return samples, sample_rate

# Function to perform FFT and extract prominent frequencies
def extract_frequencies(samples, sample_rate, num_frequencies):
    N = len(samples)
    yf = fft(samples)
    xf = fftfreq(N, 1 / sample_rate)
    magnitudes = np.abs(yf)

    # keep only non-negative freqs
    pos_idxs = np.where(xf >= 0)
    xf = xf[pos_idxs]
    magnitudes = magnitudes[pos_idxs]

    # pick top-N by magnitude
    top_idxs = np.argsort(magnitudes)[::-1][:num_frequencies]
    return xf[top_idxs], magnitudes[top_idxs]

# Function to generate a sine wave
def generate_sine_wave(frequency, duration, sample_rate):
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    return np.sin(2 * np.pi * frequency * t)

# Function to save the waveform as a WAV file
def save_waveform(waveform, sample_rate, filename):
    sf.write(filename, waveform, sample_rate)

# Convert numpy array to AudioSegment
def numpy_to_audio_segment(waveform, sample_rate):
    waveform = np.int16(waveform * 32767)
    return AudioSegment(
        waveform.tobytes(),
        frame_rate=sample_rate,
        sample_width=waveform.dtype.itemsize,
        channels=1
    )

def generate_and_combine_waveforms(channels, sample_rate, duration, output_dir, input_file):
    combined = np.zeros(int(sample_rate * duration), dtype=np.float32)
    base = os.path.splitext(input_file)[0]
    temp_files = []

    for i, (vol_pct, _, freq) in enumerate(channels):
        wave = generate_sine_wave(freq, duration, sample_rate) * (vol_pct / 100.0)
        tf = f"{output_dir}/{base}_{i}.wav"
        save_waveform(wave, sample_rate, tf)
        temp_files.append(tf)
        combined += wave

    combined /= len(channels)
    out_file = f"{output_dir}/{base}_synth.wav"
    save_waveform(combined, sample_rate, out_file)

    play(numpy_to_audio_segment(combined, sample_rate))

    for tf in temp_files:
        try: os.remove(tf)
        except OSError as e: print(f"Error deleting {tf}: {e}")

    print(f"Created combined wave file: {out_file}")

def do_all_the_things(input_dir, input_file, sample_rate, duration, output_dir, num_frequencies):
    samples, sr = load_audio(input_dir, input_file, sample_rate)
    freqs, mags = extract_frequencies(samples, sr, num_frequencies)

    # Sort by magnitude descending to find base
    order = np.argsort(mags)[::-1]
    freqs = freqs[order]
    mags = mags[order]

    base_freq = freqs[0]
    base_mag  = mags[0]
    print(f"Base Frequency: {base_freq:.6f} Hz")

    # build channels with exact frequencies
    channels = [
        ((m / base_mag) * 100, 'sine', f)
        for f, m in zip(freqs, mags)
    ]
    channels.sort(key=lambda x: x[2])

    print(f"\nbase_frequency = {base_freq:.6f}")
    print("synth_notes = [")
    for vol, _, freq in channels:
        mult = freq / base_freq
        print(f"    [{mult:.6f}, {vol:.2f}],")
    print("]")

    generate_and_combine_waveforms(channels, sr, duration, output_dir, input_file)

if __name__ == "__main__":
    sample_rate    = 44100
    duration       = 2.0
    input_dir      = "organ/src/samples"
    output_dir     = "organ/build/samples"
    input_file     = "piano_A4.wav"
    num_frequencies = 100

    do_all_the_things(input_dir, input_file, sample_rate, duration, output_dir, num_frequencies)
