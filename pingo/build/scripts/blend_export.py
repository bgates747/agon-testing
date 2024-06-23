import bpy
import os

# Ensure we're in object mode
if bpy.context.object.mode != 'OBJECT':
    bpy.ops.object.mode_set(mode='OBJECT')

# Get the default cube
cube = bpy.data.objects['Cube']

# Duplicate the cube
bpy.ops.object.select_all(action='DESELECT')
cube.select_set(True)
bpy.ops.object.duplicate()
temp_cube = bpy.context.selected_objects[0]
bpy.context.view_layer.objects.active = temp_cube

# Apply any rotation transformation
bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)

# Switch to edit mode to remove doubles
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.remove_doubles()
bpy.ops.object.mode_set(mode='OBJECT')

# Apply the Triangulate modifier to the duplicate
bpy.ops.object.modifier_add(type='TRIANGULATE')
bpy.ops.object.modifier_apply(modifier="Triangulate")

# Generate a list of all vertices, transformed to Pingo conventions
vertices = [[vert.co.x, -vert.co.z, vert.co.y] for vert in temp_cube.data.vertices]

# Generate a list of face definitions (triangulated)
faces = [[vert for vert in poly.vertices] for poly in temp_cube.data.polygons]

# Delete the temporary cube
bpy.ops.object.delete()

# Determine the output file path
output_file_path = os.path.join('/Users/bgates/Agon/mystuff/agon-testing/pingo/src/blender', 'vertices.py')

# Write to vertices.py in the specified directory
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
