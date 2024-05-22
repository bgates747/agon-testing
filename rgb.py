import numpy as np
import matplotlib.pyplot as plt

def plot_rgb_color_mix_adjusted(hex_color):
    # Convert hex to RGB values and shift range from [0, 255] to [-128, 127]
    r, g, b = tuple(int(hex_color[i:i+2], 16) / 2 for i in (0, 2, 4))
    print(f"Red: {r}, Green: {g}, Blue: {b}")

    # Define the wavelength properties for red, green, blue
    # Approximate central wavelengths (nm) from the visible spectrum
    wavelength_red = .700  # nm for red
    wavelength_green = .530  # nm for green
    wavelength_blue = .470  # nm for blue

    # Convert wavelengths to frequencies for plotting
    # Frequency calculations (not real physical frequencies but scaled for visual representation)
    x_degrees = np.linspace(0, 360, 1000)  # x-axis from 0 to 360 degrees
    x_radians = np.deg2rad(x_degrees)  # conversion to radians for the sin function

    # Generate waves based on wavelength
    red_wave = r * np.sin(2 * np.pi * x_radians / wavelength_red)
    green_wave = g * np.sin(2 * np.pi * x_radians / wavelength_green)
    blue_wave = b * np.sin(2 * np.pi * x_radians / wavelength_blue)

    # Synthetic final color output
    final_color_wave = red_wave + green_wave + blue_wave

    # Plotting the waves
    plt.figure(figsize=(12, 8))
    plt.style.use('dark_background')
    plt.plot(x_degrees, red_wave, label='Red Light', color='red')
    plt.plot(x_degrees, green_wave, label='Green Light', color='green')
    if b != 0:
        plt.plot(x_degrees, blue_wave, label='Blue Light', color='blue')
    plt.plot(x_degrees, final_color_wave, label='Final Synthetic Output', color=f'#{hex_color}', linestyle='--')
    plt.title('Visual Representation of Additive RGB Color Synthesis')
    plt.xlabel('Phase (degrees)')
    plt.ylabel('Intensity')
    plt.legend()
    plt.grid(True, which='both', color='white', linestyle='-', linewidth=0.5)
    plt.gca().set_facecolor('#404040')  # 25% gray for plot background
    plt.gcf().set_facecolor('#202020')  # Darker gray for figure background
    plt.yticks(np.arange(-256, 257, 32))  # Setting grid spacing at powers of two (intensity levels)

    plt.show()

# Example Usage: Specify the hex color value for the RGB input
plot_rgb_color_mix_adjusted('60A0FF')  # Using pure red for demonstration
