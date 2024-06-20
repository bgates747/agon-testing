import numpy as np
from agonImages import img_to_rgba8, convert_to_agon_palette
import PIL.Image as pil

# Import the vertices and faces from the vertices.py file
from vertices import vertices, faces

def modify_template(template_path, output_path, vertices, faces, texture_size, precision=8):
    vertex_format = f"{{:.{precision}f}}, {{:.{precision}f}}, {{:.{precision}f}}"

    # Read the template file
    with open(template_path, 'r') as file:
        lines = file.readlines()

    # Modify the lines for model_vertices% and model_indexes%
    for i, line in enumerate(lines):
        if line.strip().startswith("20 model_vertices%="):
            lines[i] = f"20 model_vertices%={len(vertices)}\n"
        elif line.strip().startswith("30 model_indexes%="):
            lines[i] = f"30 model_indexes%={len(faces) * 3}\n"

    # Add the vertex data starting at line 1000
    index_lines = []
    index_counter = 2000

    index_lines.append(f"{index_counter} REM -- VERTICES --\n")
    index_counter += 10
    for i, vertex in enumerate(vertices):
        formatted_vertex = vertex_format.format(*vertex)
        index_lines.append(f"{index_counter} DATA {formatted_vertex}\n")
        index_counter += 10

    index_lines.append(f"{index_counter} REM\n")
    index_counter += 10
    index_lines.append(f"{index_counter} REM -- INDEXES --\n")
    index_counter += 10
    for face in faces:
        formatted_face = ", ".join(map(str, face))
        index_lines.append(f"{index_counter} DATA {formatted_face}\n")
        index_counter += 10

    # Append the new lines to the original lines
    lines.extend(index_lines)

    # Write the result to the output file
    with open(output_path, 'w') as file:
        file.writelines(lines)

def make_texture_rgba(uv_texture_png, uv_texture_rgba8):
    img = pil.open(uv_texture_png)
    img_size = img.size
    img = convert_to_agon_palette(img, 64, 'HSV', transparent_color=None)
    img_to_rgba8(img, uv_texture_rgba8)
    return img_size

# Define the paths and call the function
template_path = 'pingo/src/bas/template.bas'
output_path = 'pingo/src/bas/fighter.bas'  # Modify this path as needed
uv_texture_png = 'pingo/src/blender/CubeObj/colorcube.png'  # Modify this path as needed
uv_texture_rgba8 = 'pingo/src/blender/' + uv_texture_png.split('/')[-1].replace('.png', 'rgba8')

# Modify the template and save the output
texture_size = make_texture_rgba(uv_texture_png, uv_texture_rgba8)
modify_template(template_path, output_path, vertices, faces, texture_size, precision=8)

print(f"Modified BASIC code has been written to {output_path}")
