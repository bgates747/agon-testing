import numpy as np
import soundfile as sf
from pydub import AudioSegment
from pydub.playback import play
from scipy.fft import fft, fftfreq
import matplotlib.pyplot as plt
from collections import defaultdict
import os

# Function to load an audio file and convert to numpy array
def load_audio(input_dir,input_file, sample_rate):
    file_path = f"{input_dir}/{input_file}"
    audio = AudioSegment.from_file(file_path)
    audio = audio.set_frame_rate(sample_rate).set_channels(1)
    samples = np.array(audio.get_array_of_samples())
    return samples, sample_rate

# Function to perform FFT and extract prominent frequencies
def extract_frequencies(samples, sample_rate, num_frequencies=10):
    # Number of samples in the signal
    N = len(samples)
    
    # Perform FFT
    yf = fft(samples)
    
    # Compute the corresponding frequencies
    xf = fftfreq(N, 1 / sample_rate)
    
    # Compute the magnitudes
    magnitudes = np.abs(yf)
    
    # Filter out negative frequencies
    positive_indices = np.where(xf >= 0)
    xf = xf[positive_indices]
    magnitudes = magnitudes[positive_indices]
    
    # Sort the magnitudes and corresponding frequencies
    indices = np.argsort(magnitudes)[::-1]
    
    prominent_frequencies = xf[indices[:num_frequencies]]
    prominent_magnitudes = magnitudes[indices[:num_frequencies]]
    
    return prominent_frequencies, prominent_magnitudes

# Function to generate a sine wave
def generate_sine_wave(frequency, duration, sample_rate):
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    waveform = np.sin(2 * np.pi * frequency * t)
    return waveform

# Function to save the waveform as a WAV file
def save_waveform(waveform, sample_rate, filename):
    sf.write(filename, waveform, sample_rate)

# Function to convert numpy array to AudioSegment
def numpy_to_audio_segment(waveform, sample_rate):
    # Convert float32 numpy array to int16
    waveform = np.int16(waveform * 32767)
    # Create an AudioSegment
    audio_segment = AudioSegment(
        waveform.tobytes(),
        frame_rate=sample_rate,
        sample_width=waveform.dtype.itemsize,
        channels=1
    )
    return audio_segment

# Plot the frequencies for visualization
def plot_frequencies(frequencies, magnitudes):
    plt.bar(frequencies, magnitudes, width=10)
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude')
    plt.title('Prominent Frequencies')
    plt.show()

# Function to generate and combine waveforms
def generate_and_combine_waveforms(channels, sample_rate, duration, output_dir, input_file):
    combined_waveform = np.zeros(int(sample_rate * duration), dtype=np.float32)
    base_filename = os.path.splitext(input_file)[0]

    for i, (volume, waveform_type, frequency) in enumerate(channels):
        waveform = generate_sine_wave(frequency, duration, sample_rate)
        waveform *= (volume / 100.0)  # Apply volume as percentage

        # Save individual waveform file
        save_waveform(waveform, sample_rate, f"{output_dir}/{base_filename}_{i}.wav")

        # Add to combined waveform
        combined_waveform += waveform

    # Normalize the combined waveform to prevent clipping
    combined_waveform /= len(channels)

    # Save the combined waveform to a WAV file
    save_waveform(combined_waveform, sample_rate, f"{output_dir}/{base_filename}_synth.wav")

    # Convert the combined waveform to an AudioSegment and play it
    combined_audio_segment = numpy_to_audio_segment(combined_waveform, sample_rate)
    play(combined_audio_segment)

def do_all_the_things(input_dir, input_file, sample_rate, duration, output_dir):
    # Load the audio file
    # samples, sample_rate = load_audio(f"{input_dir}/hammond_C1.wav", sample_rate)
    samples, sample_rate = load_audio(input_dir,input_file, sample_rate)

    # Extract the prominent frequencies
    frequencies, magnitudes = extract_frequencies(samples, sample_rate)

    # # Plot the prominent frequencies
    # plot_frequencies(frequencies, magnitudes)

    # Round frequencies to nearest integer and group by frequency, averaging magnitude
    freq_to_magnitudes = defaultdict(list)
    for frequency, magnitude in zip(frequencies, magnitudes):
        rounded_freq = int(np.round(frequency))
        freq_to_magnitudes[rounded_freq].append(magnitude)

    # Calculate the average magnitude for each frequency group
    averaged_magnitudes = {freq: np.mean(mags) for freq, mags in freq_to_magnitudes.items()}

    # Select the frequency with the largest average magnitude as the base frequency
    base_frequency = max(averaged_magnitudes, key=averaged_magnitudes.get)
    print(f"Base Frequency: {base_frequency:.2f} Hz")

    # Dynamically create the channels list based on extracted frequencies and magnitudes
    channels = []
    for freq, avg_magnitude in averaged_magnitudes.items():
        volume = (avg_magnitude / averaged_magnitudes[base_frequency]) * 100  # Normalize magnitude to volume percentage relative to base frequency
        channels.append((volume, 'sine', freq))

    # Sort channels by frequency in ascending order and magnitude in descending order
    channels = sorted(channels, key=lambda x: (x[2], -x[0]))

    print(f"\nbase_frequency = {int(base_frequency)}")
    print("synth_notes = [")
    for volume, waveform_type, frequency in channels:
        frequency = int(frequency)
        multiplier = frequency / base_frequency
        print(f"    [{multiplier:.6f}, {volume:.0f}],")
    print("]")

    # Generate and combine waveforms
    generate_and_combine_waveforms(channels, sample_rate, duration, output_dir, input_file)


if __name__ == "__main__":
    sample_rate = 16384  # Sample rate in Hz
    duration = 2.0  # Duration in seconds
    input_dir = "organ/src/samples"
    output_dir = "organ/build/samples"
    input_file = f"piano_C4.wav"
    input_file = f"hammond_C1.wav"
    input_file = f"Drawbar_C_Chord.ogg"

    do_all_the_things(input_dir, input_file, sample_rate, duration, output_dir)
