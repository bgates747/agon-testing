import numpy as np
from agonImages import img_to_rgba8, convert_to_agon_palette
import PIL.Image as pil
import os

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

def make_texture_rgba(uv_texture_png):
    uv_texture_rgba8 = uv_texture_png.replace('.png', '.rgba8')
    img = pil.open(uv_texture_png)
    img_size = img.size
    if not os.path.exists(uv_texture_rgba8):
        img_to_rgba8(img, uv_texture_rgba8)
    return img_size, uv_texture_rgba8

def parse_obj_file(filepath):
    vertices = []
    faces = []
    texture_coords = []
    texture_vertex_indices = []

    def sanitize_coord(coord):
        coord = round(coord, 3)
        if coord < 0:
            coord = 0.0
        return coord

    with open(filepath, 'r') as file:
        for line in file:
            parts = line.strip().split()
            if not parts:
                continue
            if parts[0] == 'v':
                vertices.append([float(parts[1]), float(parts[2]), float(parts[3])])
            elif parts[0] == 'vt':
                texture_coords.append([sanitize_coord(float(parts[1])), sanitize_coord(float(parts[2]))])
            elif parts[0] == 'f':
                face = []
                tex_indices = []
                for part in parts[1:]:
                    v, vt, _ = (part.split('/') + [None, None])[:3]
                    face.append(int(v) - 1)
                    if vt:
                        tex_indices.append(int(vt) - 1)
                faces.append(face)
                if tex_indices:
                    texture_vertex_indices.append(tex_indices)

    return vertices, faces, texture_coords, texture_vertex_indices

if __name__ == '__main__':
    src_dir = 'pingo/src/blender'
    tgt_dir = 'pingo/src/bas'
    blender_executable = "/Applications/Blender.app/Contents/MacOS/Blender"
    blender_local_prefs_path = None

    # base_filename, mesh_name, blender_filename, uv_texture_png
    do_these_things = [
        ['cube', 'Cube', 'colors64HSV.png'],
        ['cube1', 'Cube', '2x2.png'],
        ['earth', 'Sphere', 'earth160x80.png'],
        ['HeavyTank', 'HeavyTank', 'colorcube.png'],
        ['wolf', 'Cube', 'thumb_16.png'],
        ['wolf1', 'Cube', 'thumb_16.png'],
        ['cube2+y+z', 'Cube', 'cubeuv32x32.png'],
        ['cube2+z-y', 'Cube', 'cubeuv32x32.png'],
        ['cube2+z+y', 'Cube', 'cubeuv32x32.png'],
        ['cube2-z+y', 'Cube', 'cubeuv32x32.png'], # default
        ['cube2+x-y', 'Cube', 'cubeuv32x32.png'], # should be the way
        ['pyr-x-y', 'Cube', '2x2.png'], # left-right flipped
        ['pyr-x-z', 'Cube', '2x2.png'],
        ['pyr-x+y', 'Cube', '2x2.png'],
        ['pyr-x+z', 'Cube', '2x2.png'],
        ['pyr-y-x', 'Cube', '2x2.png'],
        ['pyr-y-z', 'Cube', '2x2.png'],
        ['pyr-y+x', 'Cube', '2x2.png'],
        ['pyr-y+z', 'Cube', '2x2.png'],
        ['pyr-z-y', 'Cube', '2x2.png'],
        ['pyr-z-x', 'Cube', '2x2.png'],
        ['pyr-z+y', 'Cube', '2x2.png'],
        ['pyr-z+x', 'Cube', '2x2.png'],
        ['pyr+x-y', 'Cube', '2x2.png'], # this is the way
        ['pyr+x-z', 'Cube', '2x2.png'],
        ['pyr+x+y', 'Cube', '2x2.png'],
        ['pyr+x+z', 'Cube', '2x2.png'],
        ['pyr+y-x', 'Cube', '2x2.png'],
        ['pyr+y-z', 'Cube', '2x2.png'],
        ['pyr+y+x', 'Cube', '2x2.png'],
        ['pyr+y+z', 'Cube', '2x2.png'],
        ['pyr+z-y', 'Cube', '2x2.png'],
        ['pyr+z-x', 'Cube', '2x2.png'],
        ['pyr+z+y', 'Cube', '2x2.png'],
        ['pyr+z+x', 'Cube', '2x2.png'],
    ]

    for thing in do_these_things:
        base_filename, mesh_name, uv_texture_png = thing
        template_filepath = f'{tgt_dir}/template.bas'
        tgt_filepath = f'{tgt_dir}/{base_filename}.bas'
        img_size, uv_texture_rgba8 = make_texture_rgba(f'{src_dir}/{uv_texture_png}')
        obj_filepath = f'{src_dir}/{base_filename}.obj'
        
        # Export the .obj file manually from Blender GUI

        # Parse the .obj file
        vertices, faces, texture_coords, texture_vertex_indices = parse_obj_file(obj_filepath)

        write_bbc_basic_data(vertices, faces, texture_coords, texture_vertex_indices, template_filepath, tgt_filepath, uv_texture_rgba8, img_size)

        print(f"Modified BASIC code has been written to {tgt_filepath}")