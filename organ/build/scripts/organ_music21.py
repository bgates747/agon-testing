from music21 import roman, pitch
import subprocess
from math import floor

# Mapping of chord numbers to key press (bit, register offset)
key_mappings = {
    # BANK 1
    1:  {'bit': 0, 'register_offset': 6},  # '1' key maps to bit 0, register bit 0,(ix+6)
    2:  {'bit': 1, 'register_offset': 6},  # '2' key maps to bit 1, register bit 1,(ix+6)
    3:  {'bit': 1, 'register_offset': 2},  # '3' key maps to bit 1, register bit 1,(ix+2)
    4:  {'bit': 2, 'register_offset': 2},  # '4' key maps to bit 2, register bit 2,(ix+2)
    5:  {'bit': 3, 'register_offset': 2},  # '5' key maps to bit 3, register bit 3,(ix+2)
    6:  {'bit': 4, 'register_offset': 6},  # '6' key maps to bit 4, register bit 4,(ix+6)
    7:  {'bit': 4, 'register_offset': 4},  # '7' key maps to bit 4, register bit 4,(ix+4)
    8:  {'bit': 5, 'register_offset': 2},  # '8' key maps to bit 5, register bit 5,(ix+2)
    9:  {'bit': 6, 'register_offset': 4},  # '9' key maps to bit 5, register bit 6,(ix+4)
    10: {'bit': 7, 'register_offset': 4},  # '0' key maps to bit 6, register bit 7,(ix+4)

    # BANK 2
    11: {'bit': 0, 'register_offset': 2},  # 'Q' key maps to bit 5, register bit 0,(ix+2)
    12: {'bit': 1, 'register_offset': 4},  # 'W' key maps to bit 6, register bit 1,(ix+4)
    13: {'bit': 2, 'register_offset': 4},  # 'E' key maps to bit 6, register bit 2,(ix+4)
    14: {'bit': 3, 'register_offset': 6},  # 'R' key maps to bit 7, register bit 3,(ix+6)
    15: {'bit': 3, 'register_offset': 4},  # 'T' key maps to bit 7, register bit 3,(ix+4)
    16: {'bit': 4, 'register_offset': 8},  # 'Y' key maps to bit 0, register bit 4,(ix+8)
    17: {'bit': 5, 'register_offset': 6},  # 'U' key maps to bit 1, register bit 5,(ix+6)
    18: {'bit': 5, 'register_offset': 4},  # 'I' key maps to bit 2, register bit 5,(ix+4)
    19: {'bit': 6, 'register_offset': 6},  # 'O' key maps to bit 3, register bit 6,(ix+6)
    20: {'bit': 7, 'register_offset': 6},  # 'P' key maps to bit 4, register bit 7,(ix+6)

    # BANK 3
    21: {'bit': 1, 'register_offset': 8},  # 'A' key maps to bit 3, register bit 1,(ix+8)
    22: {'bit': 1, 'register_offset': 10}, # 'S' key maps to bit 4, register bit 1,(ix+10)
    23: {'bit': 2, 'register_offset': 6},  # 'D' key maps to bit 4, register bit 2,(ix+6)
    24: {'bit': 3, 'register_offset': 8},  # 'F' key maps to bit 5, register bit 3,(ix+8)
    25: {'bit': 3, 'register_offset': 10}, # 'G' key maps to bit 5, register bit 3,(ix+10)
    26: {'bit': 4, 'register_offset': 10}, # 'H' key maps to bit 6, register bit 4,(ix+10)
    27: {'bit': 5, 'register_offset': 8},  # 'J' key maps to bit 7, register bit 5,(ix+8)
    28: {'bit': 6, 'register_offset': 8},  # 'K' key maps to bit 7, register bit 6,(ix+8)
    29: {'bit': 6, 'register_offset': 10}, # 'L' key maps to bit 0, register bit 6,(ix+10)
    30: {'bit': 7, 'register_offset': 10}, # ';' key maps to bit 1, register bit 7,(ix+10)

    # BANK 4
    31: {'bit': 1, 'register_offset': 12}, # 'Z' key maps to bit 0, register bit 1,(ix+12)
    32: {'bit': 2, 'register_offset': 8},  # 'X' key maps to bit 1, register bit 2,(ix+8)
    33: {'bit': 2, 'register_offset': 10}, # 'C' key maps to bit 1, register bit 2,(ix+10)
    34: {'bit': 3, 'register_offset': 12}, # 'V' key maps to bit 2, register bit 3,(ix+12)
    35: {'bit': 4, 'register_offset': 12}, # 'B' key maps to bit 3, register bit 4,(ix+12)
    36: {'bit': 5, 'register_offset': 10}, # 'N' key maps to bit 3, register bit 5,(ix+10)
    37: {'bit': 5, 'register_offset': 12}, # 'M' key maps to bit 2, register bit 5,(ix+12)
    38: {'bit': 6, 'register_offset': 12}, # ',' key maps to bit 3, register bit 6,(ix+12)
    39: {'bit': 7, 'register_offset': 12}, # '.' key maps to bit 4, register bit 7,(ix+12)
    40: {'bit': 0, 'register_offset': 13}, # '/' key maps to bit 5, register bit 0,(ix+13)
}

def parse_degree(degree):
    # Handles degrees with accidentals and returns the semitone shift from the major scale root
    major_scale_intervals = {
        '1': 0, '2': 2, '3': 4, '4': 5, '5': 7, '6': 9, '7': 11
    }
    accidental = 0
    if 'b' in degree:
        accidental = -1
        degree = degree.replace('b', '')
    elif '#' in degree:
        accidental = 1
        degree = degree.replace('#', '')
    degree_num = degree
    return major_scale_intervals[degree_num] + accidental

def make_scale(scale_root, scale_name):
    if scale_name not in scale_degrees_lookup:
        print(f"Scale '{scale_name}' not found in the lookup.")
        return []

    degrees = scale_degrees_lookup[scale_name]
    scale_notes = []
    root_pitch = pitch.Pitch(scale_root)
    last_semitone = -1  # Initializing to -1 ensures the first note does not trigger octave adjustment
    octave_shift = 0
    
    for degree in degrees:
        semitone_shift = parse_degree(degree)
        if semitone_shift <= last_semitone:
            octave_shift += 12  # Increase octave by 12 semitones
        note = root_pitch.transpose(semitone_shift + octave_shift)
        scale_notes.append(note)
        last_semitone = semitone_shift

    frequencies = [note.frequency for note in scale_notes]
    print(f"{scale_name} scale notes: {[n.nameWithOctave for n in scale_notes]}")
    return frequencies

def make_progression(key_signature, progression):
    chords = []
    for chord_symbol in progression:
        rn = roman.RomanNumeral(chord_symbol, key_signature)
        chords.append([p for p in rn.pitches])
        print(f"Chord {chord_symbol}: {[p.nameWithOctave for p in rn.pitches]}")
    return chords

def generate_chord_variations(progression_chords, scale_notes):
    banks = []
    # Each bank corresponds to a chord in the progression
    for chord in progression_chords:
        bank_chords = []
        # bank_chords = [chord]  # Start with the base chord
        i = 0
        for note in scale_notes:
            variation = chord + [note]
            bank_chords.append(variation)
            i += 1
            if i == 10: break
        banks.append(bank_chords)
    return banks

def note_to_index(note_obj):
    reference_pitch = pitch.Pitch('C0')
    return note_obj.midi - reference_pitch.midi


def adjust_volume(base_frequency, raw_volume, reference_frequency, alpha):
    """
    Adjusts the volume based on the frequency relative to a reference frequency.
    
    :param base_frequency: The frequency of the tone to adjust.
    :param raw_volume: The raw volume level (0-100).
    :param reference_frequency: The reference frequency (default is 440 Hz).
    :param alpha: The exponent for the power law (default is 0.75). Lowering the value decreases the volume of higher frequencies.
    :return: The adjusted volume level.
    """
    adjusted_volume = raw_volume * (reference_frequency / base_frequency) ** alpha
    # Normalize to hardware scale (0-127)
    normalized_volume = min(int(adjusted_volume * 1.27), 127)
    return normalized_volume

def generate_vibrato_synth_notes(base_frequency, vibrato_amplitude, harmonics, base_multiplier, base_level):
    # Generate vibrato-modified notes for a single base multiplier and level
    synth_notes = []
    if harmonics == 0:
        synth_notes.append([base_multiplier, base_level])
        return synth_notes
    
    for k in range(1, harmonics + 1):
        multiplier_pos = base_multiplier * (1 + k * vibrato_amplitude / base_frequency)
        multiplier_neg = base_multiplier * (1 - k * vibrato_amplitude / base_frequency)
        level = max(base_level - k * 10, 0)  # Decrease level for higher harmonics
        synth_notes.append([multiplier_neg, level])
        synth_notes.append([multiplier_pos, level])
    return synth_notes

def write_note_bit_settings(asm_filepath, base_frequencies, bank_number, initial_synth_notes, vibrato_amplitude, harmonics):
    with open(asm_filepath, 'w') as fw:
        file_name = asm_filepath.split('/')[-1]
        procedure_name = file_name.replace('.asm', '')
        fw.write(f"{procedure_name}:\n")
        keypress_index = (bank_number - 1) * 10

        fw.write("    ld iy,cmd0\n\n")

        channel = 0

        for base_frequency in base_frequencies:
            extended_synth_notes = []
            for base_multiplier, base_level in initial_synth_notes:
                # Generate vibrato notes for each initial synthetic tone
                vibrato_notes = generate_vibrato_synth_notes(base_frequency, vibrato_amplitude, harmonics, base_multiplier, base_level)
                extended_synth_notes.extend(vibrato_notes)

            bit, register_offset = key_mappings[keypress_index + 1]['bit'], key_mappings[keypress_index + 1]['register_offset']
            fw.write(f"    bit {bit},(ix+{register_offset})\n")
            fw.write(f"    jp z,@note_end{keypress_index}\n")

            for note in extended_synth_notes:
                frequency_multiplier, volume = note
                frequency = int(base_frequency * frequency_multiplier)

                volume = adjust_volume(frequency, volume, reference_frequency=65, alpha=0.80)

                frequency_hex = f"{frequency:04X}"
                frequency_hex_low = frequency_hex[-2:]
                frequency_hex_high = frequency_hex[:2]

                fw.write(f"    ld a,{volume}\n")
                fw.write(f"    ld (iy+cmd_volume),a\n")
                fw.write(f"    ld a,0x{frequency_hex_low}\n")
                fw.write(f"    ld (iy+cmd_frequency),a\n")
                fw.write(f"    ld a,0x{frequency_hex_high}\n")
                fw.write(f"    ld (iy+cmd_frequency+1),a\n")
                fw.write(f"    lea iy,iy+cmd_bytes\n\n")
                channel += 1

            fw.write(f"    ld hl,notes_played\n")
            fw.write(f"    dec (hl)\n")
            fw.write(f"    jp z,{procedure_name}_end\n\n")

            fw.write(f"@note_end{keypress_index}:\n\n")

            keypress_index += 1

        fw.write(f"{procedure_name}_end:\n")

def write_asm_play_notes(asm_file, max_notes):
    with open(asm_file, 'w') as fw:
        fw.write(f"max_notes: equ {max_notes}\n")
        fw.write(f"play_notes:\n")

        fw.write(f"\n    ld hl,play_notes_cmd\n")
        fw.write(f"    ld bc,play_notes_end-play_notes_cmd\n")
        fw.write(f"    rst.lil $18\n")
        fw.write(f"    ret\n")
        fw.write(f"play_notes_cmd:\n\n")

        for i in range(32):
            # Command 3: Set frequency
            # VDU 23, 0, &85, channel, 3, frequency;
            fw.write(f"cmd{i}:         db 23, 0, $85, {i}, 3\n")
            fw.write(f"frequency{i}:   dw 0 \n")

            # Command 2: Set volume
            # VDU 23, 0, &85, channel, 2, volume
            fw.write(f"              db 23, 0, $85, {i}, 2\n")
            fw.write(f"volume{i}:      db 0\n\n")

        fw.write(f"\nplay_notes_end:")

scale_degrees_lookup = {
    'MinorPentatonic': ['1',  'b3', '4',  '5',  'b7', '1',  'b3', '4',  '5',  'b7'],
    'MajorPentatonic': ['1',  '2',  '3',  '5',  '6',  '1',  '2',  '3',  '5',  '6'],
    'MajorBlues':      ['1',  '2',  'b3', '3',  '5',  '6',  '1',  '2',  'b3', '3'],
    'MinorBlues':      ['1',  'b3', '4',  'b5', '5',  'b7', '1',  'b3', '4',  'b5'],
    'Grapevine':       ['1',  '2',  'b3', '4',  '5',  'b6', 'b7', '1',  '2',  'b3'],
    # 'Grapevine': ['1', '#1', '2', 'b3', '3', '4', '#4', '5', '6', '7'],
    'Aeolian':         ['1',  '2',  'b3', '4',  '5',  'b6', 'b7', '1',  '2',  'b3'],
    'Dorian':          ['1',  '2',  'b3', '4',  '5',  '6',  'b7', '1',  '2',  'b3'],
    'Mixolydian':      ['1',  '2',  '3',  '4',  '5',  '6',  'b7', '1',  '2',  '3'],
    'Ionian':          ['1',  '2',  '3',  '4',  '5',  '6',  '7',  '1',  '2',  '3'],
    'Phrygian':        ['1',  'b2', 'b3', '4',  '5',  'b6', 'b7', '1',  'b2', 'b3'],
    'Locrian':         ['1',  'b2', 'b3', '4',  'b5', 'b6', 'b7', '1',  'b2', 'b3'],
}

# Generate scale notes
scale_key = 'A'
scale_base_octave = 2

scale_name = 'MinorBlues' 
# published to discord: https://discord.com/channels/1158535358624039014/1158536809916149831/1241528343568978033
# Smooth and mellow progression with adjusted V chord:
# I knew a 7 would work soemwhere. and in the V slot is a good choice, classic sound.
progression = ['I', 'IV', 'V7', 'bVII6']

num_harmonics = 0
vibrato_amplitude = 3  # Hz


synth_notes = [
    [8/16,      8/8*100],   # 16' Drawbar - Subharmonic, one octave below the fundamental
    [8/(5+1/3), 8/8*100],   # 5 1/3' Drawbar - Subharmonic, a perfect fifth below two octaves
    [8/8,       8/8*100],   # 8' Drawbar - Fundamental frequency
    [8/4,       8/8*100],   # 4' Drawbar - One octave above the fundamental
    [8/(2+2/3), 8/8*100],   # 2 2/3' Drawbar - A perfect fifth above one octave
    [8/2,       8/8*100],   # 2' Drawbar - Two octaves above the fundamental
    [8/(1+3/5), 8/8*100],   # 1 3/5' Drawbar - A major third above two octaves
    [8/(1+1/3), 8/8*100],   # 1 1/3' Drawbar - A perfect fifth above two octaves
]


if num_harmonics == 0:
    max_notes = floor(32 / len(synth_notes))
else:
    max_notes = floor(32 / (len(synth_notes) * 2 * num_harmonics))

if num_harmonics == 0:
    max_notes = floor(32 / len(synth_notes))
else:
    max_notes = floor(32 / (len(synth_notes) * 2 * num_harmonics))

bank_number = 1
scale_root = f"{scale_key}{4-bank_number+scale_base_octave}"
# scale_root = f"{scale_key}{scale_base_octave}"
scale_notes = make_scale(scale_root, scale_name)
print(scale_notes)
asm_file = f"organ/src/asm/organ_notes_bank_{bank_number}.asm"
write_note_bit_settings(asm_file, scale_notes, bank_number, synth_notes, vibrato_amplitude, num_harmonics)



bank_number = 2
scale_root = f"{scale_key}{4-bank_number+scale_base_octave}"
# scale_root = f"{scale_key}{scale_base_octave}"
scale_notes = make_scale(scale_root, scale_name)
print(scale_notes)
asm_file = f"organ/src/asm/organ_notes_bank_{bank_number}.asm"
write_note_bit_settings(asm_file, scale_notes, bank_number, synth_notes, vibrato_amplitude, num_harmonics)


bank_number = 3
scale_root = f"{scale_key}{4-bank_number+scale_base_octave}"
# scale_root = f"{scale_key}{scale_base_octave}"
scale_notes = make_scale(scale_root, scale_name)
print(scale_notes)
asm_file = f"organ/src/asm/organ_notes_bank_{bank_number}.asm"
write_note_bit_settings(asm_file, scale_notes, bank_number, synth_notes, vibrato_amplitude, num_harmonics)


bank_number = 4
scale_root = f"{scale_key}{4-bank_number+scale_base_octave}"
# scale_root = f"{scale_key}{scale_base_octave}"
scale_notes = make_scale(scale_root, scale_name)
print(scale_notes)
asm_file = f"organ/src/asm/organ_notes_bank_{bank_number}.asm"
write_note_bit_settings(asm_file, scale_notes, bank_number, synth_notes, vibrato_amplitude, num_harmonics)

# # Generate chord variations
# banks = generate_chord_variations(progression_chords, scale_notes)

# Generate chord progressionsion
# progression_chords = make_progression(key_signature, progression)

write_asm_play_notes("organ/src/asm/organ_channels.asm", max_notes)

command = "ez80asm -l organ/src/asm/organ.asm organ/tgt/organ.bin"
subprocess.run(command, shell=True)