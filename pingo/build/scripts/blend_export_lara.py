import bpy
import os

# Ensure we're in object mode
if bpy.context.object.mode != 'OBJECT':
    bpy.ops.object.mode_set(mode='OBJECT')

# Initialize lists for vertices and faces
all_vertices = []
all_faces = []
vertex_offset = 0

# Iterate through all mesh objects starting with 'M0'
for obj in bpy.data.objects:
    if obj.type == 'MESH' and obj.name.startswith('M0'):
        # Duplicate the object
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        bpy.ops.object.duplicate()
        temp_obj = bpy.context.selected_objects[0]

        # Apply any rotation transformations
        bpy.context.view_layer.objects.active = temp_obj
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)

        # Apply the Triangulate modifier to the duplicate
        bpy.ops.object.modifier_add(type='TRIANGULATE')
        bpy.ops.object.modifier_apply(modifier="Triangulate")

        # Switch to edit mode to remove doubles
        bpy.ops.object.mode_set(mode='EDIT')
        bpy.ops.mesh.select_all(action='SELECT')
        bpy.ops.mesh.remove_doubles()
        bpy.ops.object.mode_set(mode='OBJECT')

        # Add vertices to the all_vertices list, transforming to Pingo conventions
        vertices = [[vert.co.x, -vert.co.z, vert.co.y] for vert in temp_obj.data.vertices]
        all_vertices.extend(vertices)

        # Add faces to the all_faces list, adjusting for the vertex offset
        faces = [[vert + vertex_offset for vert in poly.vertices] for poly in temp_obj.data.polygons]
        all_faces.extend(faces)

        # Update the vertex offset
        vertex_offset += len(temp_obj.data.vertices)

        # Delete the temporary object
        bpy.ops.object.delete()

# Determine the output file path
output_file_path = os.path.join('/Users/bgates/Agon/mystuff/agon-testing/pingo/src/blender', 'vertices.py')

# Write to vertices.py in the specified directory
with open(output_file_path, 'w') as file:
    file.write("vertices = [\n")
    for vertex in all_vertices:
        file.write(f"    {vertex},\n")
    file.write("]\n\n")

    file.write("faces = [\n")
    for face in all_faces:
        file.write(f"    {face},\n")
    file.write("]\n")

print(f"Vertex and face data written to {output_file_path}")
