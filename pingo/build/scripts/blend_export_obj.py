import bpy
import os

# Ensure OBJ export add-on is enabled
if not bpy.context.preferences.addons.get('io_scene_obj'):
    bpy.ops.preferences.addon_enable(module='io_scene_obj')

# Ensure we're in object mode
if bpy.context.object.mode != 'OBJECT':
    bpy.ops.object.mode_set(mode='OBJECT')

# Directory to save the exported OBJ files
output_dir = '/Users/bgates/Agon/mystuff/agon-testing/pingo/src/blender'

# Loop through all mesh objects in the current scene
for obj in bpy.context.scene.objects:
    if obj.type == 'MESH':
        # Duplicate the object
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        bpy.ops.object.duplicate()
        temp_obj = bpy.context.selected_objects[0]
        bpy.context.view_layer.objects.active = temp_obj

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

        # Export the object as an OBJ file
        output_file_path = os.path.join(output_dir, f'{temp_obj.name}.obj')
        bpy.ops.export_scene.obj(filepath=output_file_path, use_selection=True)
        
        # Delete the temporary object
        bpy.ops.object.delete()

        print(f"Model exported to {output_file_path}")

print("All mesh objects have been processed and exported.")
