import numpy as np
from vertices import vertices, faces

# Function to format and print vertices and faces in BBC BASIC code format
def print_bbc_basic(vertices, faces, precision=8):
    vertex_format = f"{{:.{precision}f}}, {{:.{precision}f}}, {{:.{precision}f}}"
    
    vertex_lines = 40
    index_lines = vertex_lines + len(vertices) * 10 + 20  # Adding 20 to give space for a comment line
    
    print(f"{vertex_lines} REM -- VERTICES --")
    print(f"{vertex_lines + 10} model_vertices%={len(vertices)}")
    print(f"{vertex_lines + 20} model_indexes%={len(faces) * 3}")
    
    for i, vertex in enumerate(vertices):
        formatted_vertex = vertex_format.format(*vertex)
        print(f"{vertex_lines + 30 + 10 * i} DATA {formatted_vertex}")
    
    index_start_line = vertex_lines + 30 + 10 * len(vertices) + 10
    print(f"{index_start_line} REM")
    print(f"{index_start_line + 10} REM -- INDEXES --")
    
    index_counter = index_start_line + 20
    for face in faces:
        formatted_face = ", ".join(map(str, face))
        print(f"{index_counter} DATA {formatted_face}")
        index_counter += 10

# Print the vertices and faces in BBC BASIC code format with the desired precision
print_bbc_basic(vertices, faces, precision=8)