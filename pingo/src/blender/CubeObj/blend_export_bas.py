import bpy
import os
import numpy as np
import PIL.Image as pil

def img_to_rgba8(image, filepath):
    """
    Save the RGBA values of each pixel in the given Pillow image to a file.

    Args:
    - image: A Pillow Image object.
    - filepath: Full path and file name where to save the pixel data.
    """
    # Ensure the image is in RGBA mode
    if image.mode != 'RGBA':
        image = image.convert('RGBA')
    
    width, height = image.size
    with open(filepath, 'wb') as file:
        # Iterate over each pixel
        for y in range(height):
            for x in range(width):
                r, g, b, a = image.getpixel((x, y))
                # Write the RGBA values sequentially
                file.write(struct.pack('4B', r, g, b, a))

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
    # img = convert_to_agon_palette(img, 64, 'HSV', transparent_color=None)
    img_to_rgba8(img, uv_texture_rgba8)
    return img_size

def parse_blender_data():
    vertices = []
    faces = []
    texture_coords = []
    texture_vertex_indices = []
    texture_file_name = None

    for obj in bpy.context.scene.objects:
        if obj.type == 'MESH':
            mesh = obj.data

            for vert in mesh.vertices:
                vertices.append((vert.co.x, vert.co.y, vert.co.z))

            for poly in mesh.polygons:
                face = [poly.vertices[0], poly.vertices[1], poly.vertices[2]]
                faces.append(face)

            for loop in mesh.loops:
                uv_layer = mesh.uv_layers.active.data
                if uv_layer:
                    u, v = uv_layer[loop.index].uv
                    texture_coords.append((u, v))
                    texture_vertex_indices.append(loop.vertex_index)

    for material in bpy.data.materials:
        if material.node_tree:
            for node in material.node_tree.nodes:
                if node.type == 'TEX_IMAGE':
                    texture_file_name = node.image.filepath

    return vertices, faces, texture_coords, texture_vertex_indices, texture_file_name

if __name__ == '__main__':
    src_dir = 'pingo/src/blender'
    tgt_dir = 'pingo/src/bas'
    base_filename = 'color_cube'
    template_filepath = f'{tgt_dir}/template_fastload.bas'
    tgt_filepath = f'{tgt_dir}/{base_filename}.bas'

    vertices, faces, texture_coords, texture_vertex_indices, texture_file_name = parse_blender_data()

    uv_texture_png = f'{src_dir}/{texture_file_name}'
    uv_texture_rgba8 = f'{tgt_dir}/{base_filename}.rgba8'
    img_size = make_texture_rgba(uv_texture_png, uv_texture_rgba8)

    write_bbc_basic_data(vertices, faces, texture_coords, texture_vertex_indices, template_filepath, tgt_filepath, uv_texture_rgba8, img_size)

    print(f"Modified BASIC code has been written to {tgt_filepath}")
