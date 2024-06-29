import bpy
import bmesh
import os

def transform_and_export(base_filename, obj, obj_filepath, mtl_filepath=None, mirror_axis='Z', axis_forward='+Z', axis_up='+Y'):
    # Ensure we are working with mesh data
    if obj.type != 'MESH':
        raise ValueError("Object is not a mesh.")

    # Create a new mesh data block to work on
    bm = bmesh.new()
    bm.from_mesh(obj.data)

    # Triangulate faces that are not already triangles
    non_triangle_faces = [f for f in bm.faces if len(f.verts) > 3]
    bmesh.ops.triangulate(bm, faces=non_triangle_faces)

    # Apply mirror transformation
    if mirror_axis in {'X', 'Y', 'Z'}:
        axis_index = 'XYZ'.index(mirror_axis)
        mirror_matrix = [(-1 if i == axis_index else 1) for i in range(3)]
        bmesh.ops.scale(bm, vec=mirror_matrix, verts=bm.verts)

    # Mirror the UVs
    uv_layer = bm.loops.layers.uv.active
    if uv_layer:
        for face in bm.faces:
            for loop in face.loops:
                uv = loop[uv_layer].uv
                if mirror_axis == 'X':
                    uv.x = 1.0 - uv.x
                elif mirror_axis in {'Y', 'Z'}:
                    uv.y = 1.0 - uv.y

    # Apply final axis transformations
    def apply_axis_transformation(axis_forward, axis_up):
        forward_vector = {
            '+X': (1, 0, 0),
            '-X': (-1, 0, 0),
            '+Y': (0, 1, 0),
            '-Y': (0, -1, 0),
            '+Z': (0, 0, 1),
            '-Z': (0, 0, -1)
        }[axis_forward]

        up_vector = {
            '+X': (1, 0, 0),
            '-X': (-1, 0, 0),
            '+Y': (0, 1, 0),
            '-Y': (0, -1, 0),
            '+Z': (0, 0, 1),
            '-Z': (0, 0, -1)
        }[axis_up]

        forward_index = forward_vector.index(max(forward_vector, key=abs))
        up_index = up_vector.index(max(up_vector, key=abs))

        # Define rotation matrices for the required transformations
        if axis_forward == '+Z' and axis_up == '+Y':
            return  # No transformation needed, already in target orientation

        if axis_forward == '+Z' and axis_up == '+X':
            rotation_matrix = [
                (0, -1, 0),
                (1, 0, 0),
                (0, 0, 1)
            ]
        elif axis_forward == '+Y' and axis_up == '+Z':
            rotation_matrix = [
                (1, 0, 0),
                (0, 0, -1),
                (0, 1, 0)
            ]
        elif axis_forward == '+X' and axis_up == '+Z':
            rotation_matrix = [
                (0, 0, 1),
                (0, 1, 0),
                (-1, 0, 0)
            ]
        else:
            # Handle other cases as needed
            raise ValueError("Unsupported axis configuration")

        for v in bm.verts:
            co = v.co.copy()
            v.co.x = co.x * rotation_matrix[0][0] + co.y * rotation_matrix[1][0] + co.z * rotation_matrix[2][0]
            v.co.y = co.x * rotation_matrix[0][1] + co.y * rotation_matrix[1][1] + co.z * rotation_matrix[2][1]
            v.co.z = co.x * rotation_matrix[0][2] + co.y * rotation_matrix[1][2] + co.z * rotation_matrix[2][2]

    apply_axis_transformation(axis_forward, axis_up)

    # Helper function to format numbers
    def format_num(num):
        return f"{0 if abs(num) < 1e-6 else num:.6f}"

    # Write out the OBJ file
    with open(obj_filepath, 'w') as obj_file:
        # Write header information
        obj_file.write(f"mtllib {base_filename}.mtl\n")
        obj_file.write(f"o {base_filename}\n")
        # Write vertices
        for v in bm.verts:
            x, y, z = map(format_num, [v.co.x, v.co.y, v.co.z])
            obj_file.write(f"v {x} {y} {z}\n")

        # Write texture vertices (UV coordinates)
        if uv_layer:
            for face in bm.faces:
                for loop in face.loops:
                    uv = loop[uv_layer].uv
                    u, v = map(format_num, [uv.x, uv.y])
                    obj_file.write(f"vt {u} {v}\n")

        # Write faces
        for face in bm.faces:
            face_verts = []
            for loop in face.loops:
                vert_index = loop.vert.index + 1
                uv_index = loop.index + 1 if uv_layer else ""
                face_verts.append(f"{vert_index}/{uv_index}" if uv_layer else f"{vert_index}")
            obj_file.write("f " + " ".join(face_verts) + "\n")

    # Optionally write out the MTL file
    if mtl_filepath:
        with open(mtl_filepath, 'w') as mtl_file:
            mtl_file.write("newmtl Material\n")
            mtl_file.write("Ns 250.000000\n")
            mtl_file.write("Ka 1.000000 1.000000 1.000000\n")
            mtl_file.write("Ks 0.500000 0.500000 0.500000\n")
            mtl_file.write("Ke 0.000000 0.000000 0.000000\n")
            mtl_file.write("Ni 1.450000\n")
            mtl_file.write("d 1.000000\n")
            mtl_file.write("illum 2\n")
            if texture_filepath:
                mtl_file.write(f"map_Kd {os.path.basename(texture_filepath)}\n")

    bm.free()
    print(f"Object exported to '{obj_filepath}' successfully.")
    if mtl_filepath:
        print(f"Material file exported to '{mtl_filepath}'.")

# Example usage:
if bpy.context.active_object and bpy.context.active_object.type == 'MESH':
    original_obj = bpy.context.active_object
    
    # Get the directory containing the current Blender file
    blend_dir = os.path.dirname(bpy.data.filepath)
    
    # Define the output paths relative to the blend file directory
    base_filename = "heavytank3inv"
    obj_filepath = os.path.join(blend_dir, f"{base_filename}.obj")
    mtl_filepath = os.path.join(blend_dir, f"{base_filename}.mtl")  # Optional
    texture_filepath = os.path.join(blend_dir, "blenderaxes.png")  # Optional texture file

    # Export the object to OBJ format with transformations
    transform_and_export(base_filename, original_obj, obj_filepath, mtl_filepath, mirror_axis='Z', axis_forward='+Z', axis_up='+Y')

else:
    print("Please select a mesh object.")
