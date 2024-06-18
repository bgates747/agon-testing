import numpy as np

# Function to generate the vertices of a dodecahedron
def generate_dodecahedron():
    # Golden ratio
    phi = (1 + np.sqrt(5)) / 2
    
    # Vertices of a dodecahedron
    vertices = [
        # (±1, ±1, ±1)
        [-1, -1, -1],
        [-1, -1,  1],
        [-1,  1, -1],
        [-1,  1,  1],
        [ 1, -1, -1],
        [ 1, -1,  1],
        [ 1,  1, -1],
        [ 1,  1,  1],
        # (0, ±1/φ, ±φ)
        [ 0, -1/phi, -phi],
        [ 0, -1/phi,  phi],
        [ 0,  1/phi, -phi],
        [ 0,  1/phi,  phi],
        # (±1/φ, ±φ, 0)
        [-1/phi, -phi,  0],
        [-1/phi,  phi,  0],
        [ 1/phi, -phi,  0],
        [ 1/phi,  phi,  0],
        # (±φ, 0, ±1/φ)
        [-phi,  0, -1/phi],
        [ phi,  0, -1/phi],
        [-phi,  0,  1/phi],
        [ phi,  0,  1/phi]
    ]
    
    # Faces of a dodecahedron (defined by indices of the vertices)
    faces = [
        [0, 8, 10, 2, 16],
        [0, 16, 18, 4, 12],
        [0, 12, 13, 1, 8],
        [1, 9, 11, 3, 13],
        [1, 13, 12, 4, 9],
        [2, 10, 11, 3, 14],
        [2, 14, 15, 6, 16],
        [3, 11, 9, 5, 15],
        [4, 18, 17, 6, 12],
        [5, 9, 4, 18, 19],
        [5, 19, 17, 6, 15],
        [6, 17, 18, 4, 16]
    ]
    
    # Convert each face into triangles
    triangles = []
    for face in faces:
        for i in range(1, len(face) - 1):
            triangles.append([face[0], face[i], face[i + 1]])
    
    return vertices, triangles

# Function to format and print vertices and faces in BBC BASIC code format
def print_bbc_basic(vertices, faces, precision=8):
    vertex_format = f"{{:.{precision}f}}, {{:.{precision}f}}, {{:.{precision}f}}"
    
    vertex_lines = 40
    index_lines = vertex_lines + len(vertices) * 10 + 20  # Adding 20 to give space for a comment line
    
    print(f"{vertex_lines} REM -- VERTICES --")
    print(f"{vertex_lines + 10} teapot_vertices%={len(vertices)}")
    print(f"{vertex_lines + 20} teapot_indexes%={len(faces) * 3}")
    
    for i, vertex in enumerate(vertices):
        formatted_vertex = vertex_format.format(*vertex)
        print(f"{vertex_lines + 30 + 10 * i} DATA {formatted_vertex}")
    
    print(f"{vertex_lines + 30 + 10 * len(vertices)} REM")
    print(f"{index_lines} REM -- INDEXES --")
    
    index_counter = index_lines + 10
    for face in faces:
        formatted_face = ", ".join(map(str, face))
        print(f"{index_counter} DATA {formatted_face}")
        index_counter += 10

# Generate the vertices and faces
vertices, faces = generate_dodecahedron()

# Print the vertices and faces in BBC BASIC code format with the desired precision
print_bbc_basic(vertices, faces, precision=8)
