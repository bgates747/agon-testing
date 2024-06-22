def parse_obj_file(filepath):
    vertices = []
    faces = []
    texture_coords = []
    texture_vertex_indices = []

    with open(filepath, 'r') as file:
        for line in file:
            parts = line.split()
            if not parts:
                continue
            if parts[0] == 'v':
                vertices.append(parts[1:])
            elif parts[0] == 'f':
                face = [int(part.split('/')[0]) - 1 for part in parts[1:]]
                faces.append(face)
                texture_vertex_indices.append([int(part.split('/')[1]) - 1 for part in parts[1:]])
            elif parts[0] == 'vt':
                texture_coords.append(parts[1:])

    return vertices, faces, texture_coords, texture_vertex_indices


def write_bbc_basic_data(vertices, faces, texture_coords, texture_vertex_indices, tgt_filepath):
    line_number = 2000
    with open(tgt_filepath, 'w') as file:
        file.write(f"{line_number} REM -- VERTICES --\n")
        line_number += 10
        for vertex in vertices:
            file.write(f"{line_number} DATA {', '.join(vertex)}\n")
            line_number += 10

        file.write(f"{line_number} REM -- FACE VERTEX INDICES --\n")
        line_number += 10
        for face in faces:
            file.write(f"{line_number} DATA {', '.join(map(str, face))}\n")
            line_number += 10

        file.write(f"{line_number} REM -- TEXTURE UV COORDINATES --\n")
        line_number += 10
        for coord in texture_coords:
            file.write(f"{line_number} DATA {', '.join(coord)}\n")
            line_number += 10

        file.write(f"{line_number} REM -- TEXTURE VERTEX INDICES --\n")
        line_number += 10
        for indices in texture_vertex_indices:
            file.write(f"{line_number} DATA {', '.join(map(str, indices))}\n")
            line_number += 10


if __name__ == '__main__':
    src_filepath = 'pingo/src/blender/plane.obj'
    tgt_filepath = 'pingo/src/bas/plane.bas'

    vertices, faces, texture_coords, texture_vertex_indices = parse_obj_file(src_filepath)
    write_bbc_basic_data(vertices, faces, texture_coords, texture_vertex_indices, tgt_filepath)
