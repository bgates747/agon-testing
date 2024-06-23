import numpy as np
from agonImages import img_to_rgba8, convert_to_agon_palette
import PIL.Image as pil
from blender_headless import do_blender

def write_bbc_basic_data(vertices, faces, texture_coords, texture_vertex_indices, template_filepath, tgt_filepath, uv_texture_rgba8, img_size):
    # Read the template file
    with open(template_filepath, 'r') as file:
        lines = file.readlines()

    # Write the template file to the target file
    with open(tgt_filepath, 'w') as file:
        for i, line in enumerate(lines):
            if line.strip().startswith("20 model_vertices%="):
                lines[i] = f"   20 model_vertices%={len(vertices)}\n"
            elif line.strip().startswith("30 model_indices%="):
                lines[i] = f"   30 model_indices%={len(faces) * 3}\n"
            elif line.strip().startswith("40 model_uvs%="):
                lines[i] = f"   40 model_uvs%={len(texture_coords)}\n"
            elif line.strip().startswith("50 texture_width%="):
                lines[i] = f"   50 texture_width%={img_size[0]} : texture_height%={img_size[1]}\n"
        file.writelines(lines)

        # Write the model vertices
        line_number = 2000
        file.write(f"\n{line_number} REM -- VERTICES --\n")
        line_number += 2
        for vertex in vertices:
            file.write(f"{line_number} DATA {', '.join(map(str, vertex))}\n")
            line_number += 2

        # Write the face vertex indices
        file.write(f"{line_number} REM -- FACE VERTEX INDICES --\n")
        line_number += 2
        for face in faces:
            file.write(f"{line_number} DATA {', '.join(map(str, face))}\n")
            line_number += 2

        # Write the texture UV coordinates
        file.write(f"{line_number} REM -- TEXTURE UV COORDINATES --\n")
        line_number += 2
        for coord in texture_coords:
            file.write(f"{line_number} DATA {', '.join(map(str, coord))}\n")
            line_number += 2

        # Write the texture vertex indices
        file.write(f"{line_number} REM -- TEXTURE VERTEX INDICES --\n")
        line_number += 2
        for indices in texture_vertex_indices:
            file.write(f"{line_number} DATA {', '.join(map(str, indices))}\n")
            line_number += 2

        # Write the texture data
        file.write(f"{line_number} REM -- TEXTURE BITMAP --\n")
        line_number += 2
        with open(uv_texture_rgba8, 'rb') as img_file:
            img_data = img_file.read()
            filesize = len(img_data)
            linesize = 16
            for i, byte in enumerate(img_data):
                if i % linesize == 0:
                    file.write(f"{line_number} DATA ")
                    line_number += 2
                if (i + 1) % linesize == 0 or i == filesize - 1:
                    file.write(f"{byte}\n")
                else:
                    file.write(f"{byte},")

def make_texture_rgba(uv_texture_png, uv_texture_rgba8):
    img = pil.open(uv_texture_png)
    img_size = img.size
    img_to_rgba8(img, uv_texture_rgba8)
    return img_size

if __name__ == '__main__':
    src_dir = 'pingo/src/blender'
    tgt_dir = 'pingo/src/bas'
    base_filename = 'plane'
    template_filepath = f'{tgt_dir}/template.bas'
    tgt_filepath = f'{tgt_dir}/{base_filename}.bas'

    uv_texture_png = f'{src_dir}/colors64HSV.png'
    uv_texture_rgba8 = f'{tgt_dir}/{base_filename}.rgba8'
    img_size = make_texture_rgba(uv_texture_png, uv_texture_rgba8)

    blender_executable = None
    blender_local_prefs_path = None

    blender_file_path = f'{src_dir}/{base_filename}.blend'
    blender_script_path = "pingo/build/scripts/blend_export.py"
    output_file = 'pingo/build/scripts/vertices_from_blender.py'
    do_blender(blender_file_path, blender_script_path, blender_executable, None, output_file)

    # Import the vertices, faces, texture_coords, and texture_vertex_indices from vertices_from_blender.py
    from vertices_from_blender import vertices, faces, texture_coords, texture_vertex_indices

    write_bbc_basic_data(vertices, faces, texture_coords, texture_vertex_indices, template_filepath, tgt_filepath, uv_texture_rgba8, img_size)

    print(f"Modified BASIC code has been written to {tgt_filepath}")