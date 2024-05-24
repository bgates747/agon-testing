def generate_hammond_frequencies():
    motor_speed = 20  # revolutions per second

    # Gear ratios for one octave (C to B)
    gear_ratios = [
        0.817307692, # C
        0.865853659, # C#
        0.917808219, # D
        0.972222222, # D#
        1.030000000, # E
        1.090909091, # F
        1.156250000, # F#
        1.225000000, # G
        1.297297297, # G#
        1.375000000, # A
        1.456521739, # A#
        1.542857143, # B
    ]
    
    # Number of teeth for different octaves, assume 12 tonewheels for each set
    teeth_counts = [2, 4, 8, 16, 32, 64, 128, 256]  # Last uses 192 for missing 256 teeth
    
    frequencies = []

    num_wheels = 0
    # Calculate frequencies for each tonewheel
    for teeth_count in teeth_counts:
        for ratio in gear_ratios:
            frequency = int(round(motor_speed * teeth_count * ratio,0)) 
            frequencies.append(frequency)
            num_wheels += 1
            # if num_wheels == 91:
            #     break
    
    return frequencies

# Generate and print frequencies
tonewheel_frequencies = generate_hammond_frequencies()
print(tonewheel_frequencies)