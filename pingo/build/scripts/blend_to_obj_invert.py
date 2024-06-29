import bpy
import bmesh
import os

def ensure_mesh_data(obj):
    if obj.type != 'MESH':
        raise ValueError("Object is not a mesh.")
    return obj

def create_bmesh(obj):
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    return bm

def duplicate_object(obj):
    new_obj = obj.copy()
    new_obj.data = obj.data.copy()
    bpy.context.collection.objects.link(new_obj)
    return new_obj

def triangulate_faces(bm):
    non_triangle_faces = [f for f in bm.faces if len(f.verts) > 3]
    bmesh.ops.triangulate(bm, faces=non_triangle_faces)
    return bm

def apply_mirror(bm, mirror_axis):
    if mirror_axis in {'X', 'Y', 'Z'}:
        axis_index = 'XYZ'.index(mirror_axis)
        mirror_matrix = [-1 if i == axis_index else 1 for i in range(3)]
        bmesh.ops.scale(bm, vec=mirror_matrix, verts=bm.verts)
    return bm

def mirror_uvs(bm, mirror_axis):
    uv_layer = bm.loops.layers.uv.active
    if uv_layer:
        for face in bm.faces:
            for loop in face.loops:
                uv = loop[uv_layer].uv
                if mirror_axis == 'X':
                    uv.x = 1.0 - uv.x
                elif mirror_axis in {'Y', 'Z'}:
                    uv.y = 1.0 - uv.y
    return bm

def apply_axis_transformation(bm, axis_forward, axis_up):
    # Default Blender orientation is +Y forward, +Z up
    if axis_forward == '+Y' and axis_up == '+Z':
        return bm  # No transformation needed, already in target orientation

    rotation_matrix = None

    if axis_forward == '+Z' and axis_up == '+Y':
        rotation_matrix = [
            (0, 0, 1),
            (0, 1, 0),
            (-1, 0, 0)
        ]
    elif axis_forward == '+X' and axis_up == '+Y':
        rotation_matrix = [
            (0, 1, 0),
            (0, 0, -1),
            (-1, 0, 0)
        ]
    elif axis_forward == '-X' and axis_up == '+Y':
        rotation_matrix = [
            (0, 1, 0),
            (0, 0, 1),
            (1, 0, 0)
        ]
    elif axis_forward == '-Y' and axis_up == '+Z':
        rotation_matrix = [
            (-1, 0, 0),
            (0, 0, 1),
            (0, 1, 0)
        ]
    elif axis_forward == '+Y' and axis_up == '-Z':
        rotation_matrix = [
            (-1, 0, 0),
            (0, 0, -1),
            (0, 1, 0)
        ]
    elif axis_forward == '+Z' and axis_up == '-Y':
        rotation_matrix = [
            (1, 0, 0),
            (0, 0, -1),
            (0, -1, 0)
        ]
    else:
        raise ValueError("Unsupported axis configuration")

    for v in bm.verts:
        co = v.co.copy()
        v.co.x = co.x * rotation_matrix[0][0] + co.y * rotation_matrix[1][0] + co.z * rotation_matrix[2][0]
        v.co.y = co.x * rotation_matrix[0][1] + co.y * rotation_matrix[1][1] + co.z * rotation_matrix[2][1]
        v.co.z = co.x * rotation_matrix[0][2] + co.y * rotation_matrix[1][2] + co.z * rotation_matrix[2][2]

    return bm

def format_num(num):
    return f"{0 if abs(num) < 1e-6 else num:.6f}"

def write_obj_file(bm, base_filename, obj_filepath, uv_layer):
    with open(obj_filepath, 'w') as obj_file:
        # Write header information
        obj_file.write(f"mtllib {base_filename}.mtl\n")
        obj_file.write(f"o {base_filename}\n")
        # Write vertices
        for v in bm.verts:
            x, y, z = map(format_num, [v.co.x, v.co.y, v.co.z])
            obj_file.write(f"v {x} {y} {z}\n")

        # Collect unique UVs and their indices
        unique_uvs = []
        uv_indices = {}
        if uv_layer:
            for face in bm.faces:
                for loop in face.loops:
                    uv = loop[uv_layer].uv
                    uv_key = (format_num(uv.x), format_num(uv.y))
                    if uv_key not in uv_indices:
                        uv_indices[uv_key] = len(unique_uvs) + 1
                        unique_uvs.append(uv_key)
        
            # Write unique UVs
            for uv in unique_uvs:
                obj_file.write(f"vt {uv[0]} {uv[1]}\n")

        # Add shading and material information
        obj_file.write("s 0\n")
        obj_file.write("usemtl Material\n")

        # Write faces
        for face in bm.faces:
            face_verts = []
            for loop in face.loops:
                vert_index = loop.vert.index + 1
                uv_key = (format_num(loop[uv_layer].uv.x), format_num(loop[uv_layer].uv.y)) if uv_layer else ""
                uv_index = uv_indices[uv_key] if uv_layer else ""
                face_verts.append(f"{vert_index}/{uv_index}" if uv_layer else f"{vert_index}")
            obj_file.write("f " + " ".join(face_verts) + "\n")

def write_mtl_file(mtl_filepath, texture_filepath):
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

def transform_and_export(base_filename, obj, obj_filepath, mtl_filepath=None, texture_filepath=None, mirror_axis='Z', axis_forward='+Z', axis_up='+Y'):
    obj = ensure_mesh_data(obj)
    obj_copy = duplicate_object(obj)
    bm = create_bmesh(obj_copy)
    bm = triangulate_faces(bm)
    bm = apply_mirror(bm, mirror_axis)
    bm = mirror_uvs(bm, mirror_axis)
    bm = apply_axis_transformation(bm, axis_forward, axis_up)

    # Write the updated mesh data back to the copied object
    bm.to_mesh(obj_copy.data)

    # Write out the OBJ file
    write_obj_file(bm, base_filename, obj_filepath, bm.loops.layers.uv.active)

    # Optionally write out the MTL file
    if mtl_filepath:
        write_mtl_file(mtl_filepath, texture_filepath)

    bm.free()
    print(f"Object exported to '{obj_filepath}' successfully.")
    if mtl_filepath:
        print(f"Material file exported to '{mtl_filepath}'.")

    # Delete the copied object to clean up
    bpy.data.objects.remove(obj_copy)

if __name__ == "__main__":
    if bpy.context.active_object and bpy.context.active_object.type == 'MESH':
        original_obj = bpy.context.active_object
        
        # Get the directory containing the current Blender file
        blend_dir = os.path.dirname(bpy.data.filepath)
        
        # Define the output paths relative to the blend file directory
        base_filename = "sliced1inv"
        obj_filepath = os.path.join(blend_dir, f"{base_filename}.obj")
        mtl_filepath = os.path.join(blend_dir, f"{base_filename}.mtl")  # Optional
        texture_filepath = os.path.join(blend_dir, "2x2.png")  # Optional texture file

        # Export the object to OBJ format with transformations
        transform_and_export(base_filename, original_obj, obj_filepath, mtl_filepath, texture_filepath, mirror_axis='Z', axis_forward='+Z', axis_up='+Y')

    else:
        print("Please select a mesh object.")
