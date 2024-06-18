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

    return vertices, faces

# Function to format and print vertices and faces in BBC BASIC code format
def print_bbc_basic(vertices, faces, precision=8):
    vertex_format = f"{{:.{precision}f}}, {{:.{precision}f}}, {{:.{precision}f}}"
    
    print("40 REM -- VERTICES --")
    print(f"50 teapot_vertices%={len(vertices)}")
    print(f"60 teapot_indexes%={len(faces) * len(faces[0])}")
    
    for i, vertex in enumerate(vertices):
        formatted_vertex = vertex_format.format(*vertex)
        print(f"{100 + 10 * i} DATA {formatted_vertex}")
    
    print("240 REM")
    print("290 REM -- INDEXES --")
    
    index_counter = 300
    for face in faces:
        for i in range(len(face)):
            formatted_index = f"{face[i]}, {face[(i+1) % len(face)]}, {face[(i+2) % len(face)]}"
            print(f"{index_counter} DATA {formatted_index}")
            index_counter += 10

# Generate the vertices and faces
vertices, faces = generate_dodecahedron()

# Print the vertices and faces in BBC BASIC code format with the desired precision
print_bbc_basic(vertices, faces, precision=8)
