import bpy
import os

# Ensure we're in object mode
if bpy.context.object.mode != 'OBJECT':
    bpy.ops.object.mode_set(mode='OBJECT')

# Get the default cube
cube = bpy.data.objects['Cube']

# Apply the Triangulate modifier
bpy.ops.object.modifier_add(type='TRIANGULATE')
bpy.ops.object.modifier_apply(modifier="Triangulate")

# Generate a list of all vertices
vertices = [list(vert.co) for vert in cube.data.vertices]

# Generate a list of face definitions (triangulated)
faces = [[vert for vert in poly.vertices] for poly in cube.data.polygons]

# Determine the output file path
output_file_path = os.path.join('/Users/bgates/Agon/mystuff/agon-testing/pingo/src/blender', 'vertices.py')

# Write to vertices.py in the home directory
with open(output_file_path, 'w') as file:
    file.write("vertices = [\n")
    for vertex in vertices:
        file.write(f"    {vertex},\n")
    file.write("]\n\n")

    file.write("faces = [\n")
    for face in faces:
        file.write(f"    {face},\n")
    file.write("]\n")

print(f"Vertex and face data written to {output_file_path}")
