def generate_bbc_basic_data(source_file, target_file, start_line):
    with open(source_file, 'rb') as f:
        data = f.read()
    
    lines = []
    line_number = start_line

    for i in range(0, len(data), 16):
        line_data = data[i:i + 16]
        hex_values = ' '.join(f"&{byte:02X}" for byte in line_data)
        lines.append(f"{line_number} DATA {hex_values}")
        line_number += 10

    with open(target_file, 'w') as f:
        f.write('\n'.join(lines))

if __name__ == '__main__':
    import sys

    # if len(sys.argv) != 4:
    #     print("Usage: python script.py <source_file> <target_file> <start_line>")
    #     sys.exit(1)

    source_file = 'pingo/src/blender/2x2.rgba8' 
    target_file = 'pingo/src/bas/bmp.txt'
    start_line = 10000 
    generate_bbc_basic_data(source_file, target_file, start_line)
