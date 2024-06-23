import bpy
import os
import mathutils
import bpy_extras.io_utils
from progress_report import ProgressReport, ProgressReportSubstep

def name_compat(name):
    if name is None:
        return 'None'
    else:
        return name.replace(' ', '_')

def mesh_triangulate(me):
    import bmesh
    bm = bmesh.new()
    bm.from_mesh(me)
    bmesh.ops.triangulate(bm, faces=bm.faces)
    bm.to_mesh(me)
    bm.free()

def write_mtl(scene, filepath, path_mode, copy_set, mtl_dict):
    from mathutils import Color, Vector
    world = scene.world
    if world:
        world_amb = world.color
    else:
        world_amb = Color((0.0, 0.0, 0.0))
    source_dir = os.path.dirname(bpy.data.filepath)
    dest_dir = os.path.dirname(filepath)
    with open(filepath, "w", encoding="utf8", newline="\n") as f:
        fw = f.write
        fw('# Blender MTL File: %r\n' % (os.path.basename(bpy.data.filepath) or "None"))
        fw('# Material Count: %i\n' % len(mtl_dict))
        mtl_dict_values = list(mtl_dict.values())
        mtl_dict_values.sort(key=lambda m: m[0])
        for mtl_mat_name, mat, face_img in mtl_dict_values:
            fw('\nnewmtl %s\n' % mtl_mat_name)
            if mat:
                use_mirror = mat.raytrace_mirror.use and mat.raytrace_mirror.reflect_factor != 0.0
                if mat.specular_shader == 'WARDISO':
                    tspec = (0.4 - mat.specular_slope) / 0.0004
                else:
                    tspec = (mat.specular_hardness - 1) / 0.51
                fw('Ns %.6f\n' % tspec)
                if use_mirror:
                    fw('Ka %.6f %.6f %.6f\n' % (mat.raytrace_mirror.reflect_factor * mat.mirror_color)[:])
                else:
                    fw('Ka %.6f %.6f %.6f\n' % (mat.ambient, mat.ambient, mat.ambient))
                fw('Kd %.6f %.6f %.6f\n' % (mat.diffuse_intensity * mat.diffuse_color)[:])
                fw('Ks %.6f %.6f %.6f\n' % (mat.specular_intensity * mat.specular_color)[:])
                fw('Ke %.6f %.6f %.6f\n' % (mat.emit * mat.diffuse_color)[:])
                if hasattr(mat, "raytrace_transparency") and hasattr(mat.raytrace_transparency, "ior"):
                    fw('Ni %.6f\n' % mat.raytrace_transparency.ior)
                else:
                    fw('Ni %.6f\n' % 1.0)
                fw('d %.6f\n' % mat.alpha)
                if mat.use_shadeless:
                    fw('illum 0\n')
                elif mat.specular_intensity == 0:
                    fw('illum 1\n')
                elif use_mirror:
                    if mat.use_transparency and mat.transparency_method == 'RAYTRACE':
                        if mat.raytrace_mirror.fresnel != 0.0:
                            fw('illum 7\n')
                        else:
                            fw('illum 6\n')
                    elif mat.raytrace_mirror.fresnel != 0.0:
                        fw('illum 5\n')
                    else:
                        fw('illum 3\n')
                elif mat.use_transparency and mat.transparency_method == 'RAYTRACE':
                    fw('illum 9\n')
                else:
                    fw('illum 2\n')
            else:
                fw('Ns 0\n')
                fw('Ka %.6f %.6f %.6f\n' % world_amb[:])
                fw('Kd 0.8 0.8 0.8\n')
                fw('Ks 0.8 0.8 0.8\n')
                fw('d 1\n')
                fw('illum 2\n')
            if face_img:
                filepath = face_img.filepath
                if filepath:
                    filepath = bpy_extras.io_utils.path_reference(filepath, source_dir, dest_dir,
                                                                  path_mode, "", copy_set, face_img.library)
                    fw('map_Kd %s\n' % filepath)
                else:
                    face_img = None
            if mat:
                image_map = {}
                for mtex in reversed(mat.texture_slots):
                    if mtex and mtex.texture and mtex.texture.type == 'IMAGE':
                        image = mtex.texture.image
                        if image:
                            if (mtex.use_map_color_diffuse and (face_img is None) and
                                (mtex.use_map_warp is False) and (mtex.texture_coords != 'REFLECTION')):
                                image_map["map_Kd"] = (mtex, image)
                            if mtex.use_map_ambient:
                                image_map["map_Ka"] = (mtex, image)
                            if mtex.use_map_color_spec:
                                image_map["map_Ks"] = (mtex, image)
                            if mtex.use_map_hardness:
                                image_map["map_Ns"] = (mtex, image)
                            if mtex.use_map_alpha:
                                image_map["map_d"] = (mtex, image)
                            if mtex.use_map_translucency:
                                image_map["map_Tr"] = (mtex, image)
                            if mtex.use_map_normal:
                                image_map["map_Bump"] = (mtex, image)
                            if mtex.use_map_displacement:
                                image_map["disp"] = (mtex, image)
                            if mtex.use_map_color_diffuse and (mtex.texture_coords == 'REFLECTION'):
                                image_map["refl"] = (mtex, image)
                            if mtex.use_map_emit:
                                image_map["map_Ke"] = (mtex, image)
                for key, (mtex, image) in sorted(image_map.items()):
                    filepath = bpy_extras.io_utils.path_reference(image.filepath, source_dir, dest_dir,
                                                                  path_mode, "", copy_set, image.library)
                    options = []
                    if key == "map_Bump":
                        if mtex.normal_factor != 1.0:
                            options.append('-bm %.6f' % mtex.normal_factor)
                    if mtex.offset != Vector((0.0, 0.0, 0.0)):
                        options.append('-o %.6f %.6f %.6f' % mtex.offset[:])
                    if mtex.scale != Vector((1.0, 1.0, 1.0)):
                        options.append('-s %.6f %.6f %.6f' % mtex.scale[:])
                    fw('%s %s %s\n' % (key, " ".join(options), repr(filepath)[1:-1]))

def test_nurbs_compat(ob):
    if ob.type != 'CURVE':
        return False
    for nu in ob.data.splines:
        if nu.point_count_v == 1 and nu.type != 'BEZIER':
            return True
    return False

def write_nurb(fw, ob, ob_mat):
    tot_verts = 0
    cu = ob.data
    for nu in cu.splines:
        if nu.type == 'POLY':
            DEG_ORDER_U = 1
        else:
            DEG_ORDER_U = nu.order_u - 1
        if nu.type == 'BEZIER':
            print("\tWarning, bezier curve:", ob.name, "only poly and nurbs curves supported")
            continue
        if nu.point_count_v > 1:
            print("\tWarning, surface:", ob.name, "only poly and nurbs curves supported")
            continue
        if len(nu.points) <= DEG_ORDER_U:
            print("\tWarning, order_u is lower then vert count, skipping:", ob.name)
            continue
        pt_num = 0
        do_closed = nu.use_cyclic_u
        do_endpoints = (do_closed == 0) and nu.use_endpoint_u
        for pt in nu.points:
            fw('v %.6f %.6f %.6f\n' % (ob_mat @ pt.co.to_3d())[:])
            pt_num += 1
        tot_verts += pt_num
        fw('g %s\n' % (name_compat(ob.name)))
        fw('cstype bspline\n')
        fw('deg %d\n' % DEG_ORDER_U)
        curve_ls = [-(i + 1) for i in range(pt_num)]
        if do_closed:
            if DEG_ORDER_U == 1:
                pt_num += 1
                curve_ls.append(-1)
            else:
                pt_num += DEG_ORDER_U
                curve_ls = curve_ls + curve_ls[0:DEG_ORDER_U]
        fw('curv 0.0 1.0 %s\n' % (" ".join([str(i) for i in curve_ls])))
        tot_parm = (DEG_ORDER_U + 1) + pt_num
        tot_parm_div = float(tot_parm - 1)
        parm_ls = [(i / tot_parm_div) for i in range(tot_parm)]
        if do_endpoints:
            for i in range(DEG_ORDER_U + 1):
                parm_ls[i] = 0.0
                parm_ls[-(1 + i)] = 1.0
        fw("parm u %s\n" % " ".join(["%.6f" % i for i in parm_ls]))
        fw('end\n')
    return tot_verts

def write_file(filepath, objects, scene,
               EXPORT_TRI=False,
               EXPORT_EDGES=False,
               EXPORT_SMOOTH_GROUPS=False,
               EXPORT_SMOOTH_GROUPS_BITFLAGS=False,
               EXPORT_NORMALS=False,
               EXPORT_UV=True,
               EXPORT_MTL=True,
               EXPORT_APPLY_MODIFIERS=True,
               EXPORT_BLEN_OBS=True,
               EXPORT_GROUP_BY_OB=False,
               EXPORT_GROUP_BY_MAT=False,
               EXPORT_KEEP_VERT_ORDER=False,
               EXPORT_POLYGROUPS=False,
               EXPORT_CURVE_AS_NURBS=True,
               EXPORT_GLOBAL_MATRIX=None,
               EXPORT_PATH_MODE='AUTO',
               progress=ProgressReport(),
               ):
    if EXPORT_GLOBAL_MATRIX is None:
        EXPORT_GLOBAL_MATRIX = mathutils.Matrix()
    def veckey3d(v):
        return round(v.x, 4), round(v.y, 4), round(v.z, 4)
    def veckey2d(v):
        return round(v[0], 4), round(v[1], 4)
    def findVertexGroupName(face, vWeightMap):
        weightDict = {}
        for vert_index in face.vertices:
            vWeights = vWeightMap[vert_index]
            for vGroupName, weight in vWeights:
                weightDict[vGroupName] = weightDict.get(vGroupName, 0.0) + weight
        if weightDict:
            return max((weight, vGroupName) for vGroupName, weight in weightDict.items())[1]
        else:
            return '(null)'
    with ProgressReportSubstep(progress, 2, "OBJ Export path: %r" % filepath, "OBJ Export Finished") as subprogress1:
        with open(filepath, "w", encoding="utf8", newline="\n") as f:
            fw = f.write
            fw('# Blender v%s OBJ File: %r\n' % (bpy.app.version_string, os.path.basename(bpy.data.filepath)))
            fw('# www.blender.org\n')
            if EXPORT_MTL:
                mtlfilepath = os.path.splitext(filepath)[0] + ".mtl"
                fw('mtllib %s\n' % repr(os.path.basename(mtlfilepath))[1:-1])
            totverts = totuvco = totno = 1
            face_vert_index = 1
            mtl_dict = {}
            mtl_rev_dict = {}
            copy_set = set()
            subprogress1.enter_substeps(len(objects))
            for i, ob_main in enumerate(objects):
                if ob_main.parent and ob_main.parent.instance_type in {'VERTS', 'FACES'}:
                    subprogress1.step("Ignoring %s, dupli child..." % ob_main.name)
                    continue
                obs = [(ob_main, ob_main.matrix_world)]
                if ob_main.instance_type != 'NONE':
                    ob_main.instance_collection_clear()
                    obs += [(dob.object, dob.matrix) for dob in ob_main.instance_collection.objects]
                    print(ob_main.name, 'has', len(obs) - 1, 'dupli children')
                subprogress1.enter_substeps(len(obs))
                for ob, ob_mat in obs:
                    with ProgressReportSubstep(subprogress1, 6) as subprogress2:
                        uv_unique_count = no_unique_count = 0
                        if EXPORT_CURVE_AS_NURBS and test_nurbs_compat(ob):
                            ob_mat = EXPORT_GLOBAL_MATRIX @ ob_mat
                            totverts += write_nurb(fw, ob, ob_mat)
                            continue
                        try:
                            me = ob.to_mesh(preserve_all_data_layers=True, depsgraph=bpy.context.evaluated_depsgraph_get())
                        except RuntimeError:
                            me = None
                        if me is None:
                            continue
                        me.transform(EXPORT_GLOBAL_MATRIX @ ob_mat)
                        if EXPORT_TRI:
                            mesh_triangulate(me)
                        if EXPORT_UV:
                            faceuv = len(me.uv_layers) > 0
                            if faceuv:
                                uv_layer = me.uv_layers.active.data[:]
                        else:
                            faceuv = False
                        me_verts = me.vertices[:]
                        face_index_pairs = [(face, index) for index, face in enumerate(me.polygons)]
                        if EXPORT_EDGES:
                            edges = me.edges
                        else:
                            edges = []
                        if not (len(face_index_pairs) + len(edges) + len(me.vertices)):
                            bpy.data.meshes.remove(me)
                            continue
                        if EXPORT_NORMALS and face_index_pairs:
                            me.calc_normals_split()
                        loops = me.loops
                        if (EXPORT_SMOOTH_GROUPS or EXPORT_SMOOTH_GROUPS_BITFLAGS) and face_index_pairs:
                            smooth_groups, smooth_groups_tot = me.calc_smooth_groups(EXPORT_SMOOTH_GROUPS_BITFLAGS)
                            if smooth_groups_tot <= 1:
                                smooth_groups, smooth_groups_tot = (), 0
                        else:
                            smooth_groups, smooth_groups_tot = (), 0
                        materials = me.materials[:]
                        material_names = [m.name if m else None for m in materials]
                        if not materials:
                            materials = [None]
                            material_names = [name_compat(None)]
                        if EXPORT_KEEP_VERT_ORDER:
                            pass
                        else:
                            if faceuv:
                                if smooth_groups:
                                    sort_func = lambda a: (a[0].material_index,
                                                           hash(uv_layer[a[1]].image),
                                                           smooth_groups[a[1]] if a[0].use_smooth else False)
                                else:
                                    sort_func = lambda a: (a[0].material_index,
                                                           hash(uv_layer[a[1]].image),
                                                           a[0].use_smooth)
                            elif len(materials) > 1:
                                if smooth_groups:
                                    sort_func = lambda a: (a[0].material_index,
                                                           smooth_groups[a[1]] if a[0].use_smooth else False)
                                else:
                                    sort_func = lambda a: (a[0].material_index,
                                                           a[0].use_smooth)
                            else:
                                if smooth_groups:
                                    sort_func = lambda a: smooth_groups[a[1] if a[0].use_smooth else False]
                                else:
                                    sort_func = lambda a: a[0].use_smooth
                            face_index_pairs.sort(key=sort_func)
                            del sort_func
                        contextMat = 0, 0
                        contextSmooth = None
                        if EXPORT_BLEN_OBS or EXPORT_GROUP_BY_OB:
                            name1 = ob.name
                            name2 = ob.data.name
                            if name1 == name2:
                                obnamestring = name_compat(name1)
                            else:
                                obnamestring = '%s_%s' % (name_compat(name1), name_compat(name2))
                            if EXPORT_BLEN_OBS:
                                fw('o %s\n' % obnamestring)
                            else:
                                fw('g %s\n' % obnamestring)
                        subprogress2.step()
                        for v in me_verts:
                            fw('v %.6f %.6f %.6f\n' % v.co[:])
                        subprogress2.step()
                        if faceuv:
                            uv = f_index = uv_index = uv_key = uv_val = uv_ls = None
                            uv_face_mapping = [None] * len(face_index_pairs)
                            uv_dict = {}
                            uv_get = uv_dict.get
                            for f, f_index in face_index_pairs:
                                uv_ls = uv_face_mapping[f_index] = []
                                for uv_index, l_index in enumerate(f.loop_indices):
                                    uv = uv_layer[l_index].uv
                                    uv_key = loops[l_index].vertex_index, veckey2d(uv)
                                    uv_val = uv_get(uv_key)
                                    if uv_val is None:
                                        uv_val = uv_dict[uv_key] = uv_unique_count
                                        fw('vt %.6f %.6f\n' % uv[:])
                                        uv_unique_count += 1
                                    uv_ls.append(uv_val)
                            del uv_dict, uv, f_index, uv_index, uv_ls, uv_get, uv_key, uv_val
                        subprogress2.step()
                        if EXPORT_NORMALS:
                            no_key = no_val = None
                            normals_to_idx = {}
                            no_get = normals_to_idx.get
                            loops_to_normals = [0] * len(loops)
                            for f, f_index in face_index_pairs:
                                for l_idx in f.loop_indices:
                                    no_key = veckey3d(loops[l_idx].normal)
                                    no_val = no_get(no_key)
                                    if no_val is None:
                                        no_val = normals_to_idx[no_key] = no_unique_count
                                        fw('vn %.6f %.6f %.6f\n' % no_key)
                                        no_unique_count += 1
                                    loops_to_normals[l_idx] = no_val
                            del normals_to_idx, no_get, no_key, no_val
                        else:
                            loops_to_normals = []
                        if not faceuv:
                            f_image = None
                        subprogress2.step()
                        if EXPORT_POLYGROUPS:
                            vertGroupNames = ob.vertex_groups.keys()
                            if vertGroupNames:
                                currentVGroup = ''
                                vgroupsMap = [[] for _i in range(len(me_verts))]
                                for v_idx, v_ls in enumerate(vgroupsMap):
                                    v_ls[:] = [(vertGroupNames[g.group], g.weight) for g in me_verts[v_idx].groups]
                        for f, f_index in face_index_pairs:
                            f_smooth = f.use_smooth
                            if f_smooth and smooth_groups:
                                f_smooth = smooth_groups[f_index]
                            f_mat = min(f.material_index, len(materials) - 1)
                            if faceuv:
                                tface = uv_texture[f_index]
                                f_image = tface.image
                            if faceuv and f_image:
                                key = material_names[f_mat], f_image.name
                            else:
                                key = material_names[f_mat], None
                            if EXPORT_POLYGROUPS:
                                if vertGroupNames:
                                    vgroup_of_face = findVertexGroupName(f, vgroupsMap)
                                    if vgroup_of_face != currentVGroup:
                                        currentVGroup = vgroup_of_face
                                        fw('g %s\n' % vgroup_of_face)
                            if key == contextMat:
                                pass
                            else:
                                if key[0] is None and key[1] is None:
                                    if EXPORT_GROUP_BY_MAT:
                                        fw("g %s_%s\n" % (name_compat(ob.name), name_compat(ob.data.name)))
                                    if EXPORT_MTL:
                                        fw("usemtl (null)\n")
                                else:
                                    mat_data = mtl_dict.get(key)
                                    if not mat_data:
                                        mtl_name = "%s" % name_compat(key[0])
                                        if mtl_rev_dict.get(mtl_name, None) not in {key, None}:
                                            if key[1] is None:
                                                tmp_ext = "_NONE"
                                            else:
                                                tmp_ext = "_%s" % name_compat(key[1])
                                            i = 0
                                            while mtl_rev_dict.get(mtl_name + tmp_ext, None) not in {key, None}:
                                                i += 1
                                                tmp_ext = "_%3d" % i
                                            mtl_name += tmp_ext
                                        mat_data = mtl_dict[key] = mtl_name, materials[f_mat], f_image
                                        mtl_rev_dict[mtl_name] = key
                                    if EXPORT_GROUP_BY_MAT:
                                        fw("g %s_%s_%s\n" % (name_compat(ob.name), name_compat(ob.data.name), mat_data[0]))
                                    if EXPORT_MTL:
                                        fw("usemtl %s\n" % mat_data[0])
                            contextMat = key
                            if f_smooth != contextSmooth:
                                if f_smooth:
                                    if smooth_groups:
                                        f_smooth = smooth_groups[f_index]
                                        fw('s %d\n' % f_smooth)
                                    else:
                                        fw('s 1\n')
                                else:
                                    fw('s off\n')
                                contextSmooth = f_smooth
                            f_v = [(vi, me_verts[v_idx], l_idx)
                                   for vi, (v_idx, l_idx) in enumerate(zip(f.vertices, f.loop_indices))]
                            fw('f')
                            if faceuv:
                                if EXPORT_NORMALS:
                                    for vi, v, li in f_v:
                                        fw(" %d/%d/%d" % (totverts + v.index,
                                                          totuvco + uv_face_mapping[f_index][vi],
                                                          totno + loops_to_normals[li],
                                                          ))
                                else:
                                    for vi, v, li in f_v:
                                        fw(" %d/%d" % (totverts + v.index,
                                                       totuvco + uv_face_mapping[f_index][vi],
                                                       ))
                                face_vert_index += len(f_v)
                            else:
                                if EXPORT_NORMALS:
                                    for vi, v, li in f_v:
                                        fw(" %d//%d" % (totverts + v.index, totno + loops_to_normals[li]))
                                else:
                                    for vi, v, li in f_v:
                                        fw(" %d" % (totverts + v.index))
                            fw('\n')
                        subprogress2.step()
                        if EXPORT_EDGES:
                            for ed in edges:
                                if ed.is_loose:
                                    fw('l %d %d\n' % (totverts + ed.vertices[0], totverts + ed.vertices[1]))
                        totverts += len(me_verts)
                        totuvco += uv_unique_count
                        totno += no_unique_count
                        bpy.data.meshes.remove(me)
                if ob_main.instance_type != 'NONE':
                    ob_main.instance_collection_clear()
                subprogress1.leave_substeps("Finished writing geometry of '%s'." % ob_main.name)
            subprogress1.leave_substeps()
        subprogress1.step("Finished exporting geometry, now exporting materials")
        if EXPORT_MTL:
            write_mtl(scene, mtlfilepath, EXPORT_PATH_MODE, copy_set, mtl_dict)
        bpy_extras.io_utils.path_reference_copy(copy_set)

def _write(context, filepath,
           EXPORT_TRI,
           EXPORT_EDGES,
           EXPORT_SMOOTH_GROUPS,
           EXPORT_SMOOTH_GROUPS_BITFLAGS,
           EXPORT_NORMALS,
           EXPORT_UV,
           EXPORT_MTL,
           EXPORT_APPLY_MODIFIERS,
           EXPORT_BLEN_OBS,
           EXPORT_GROUP_BY_OB,
           EXPORT_GROUP_BY_MAT,
           EXPORT_KEEP_VERT_ORDER,
           EXPORT_POLYGROUPS,
           EXPORT_CURVE_AS_NURBS,
           EXPORT_SEL_ONLY,
           EXPORT_ANIMATION,
           EXPORT_GLOBAL_MATRIX,
           EXPORT_PATH_MODE,
           ):
    with ProgressReport(context.window_manager) as progress:
        base_name, ext = os.path.splitext(filepath)
        context_name = [base_name, '', '', ext]
        scene = context.scene
        if bpy.ops.object.mode_set.poll():
            bpy.ops.object.mode_set(mode='OBJECT')
        orig_frame = scene.frame_current
        if EXPORT_ANIMATION:
            scene_frames = range(scene.frame_start, scene.frame_end + 1)
        else:
            scene_frames = [orig_frame]
        progress.enter_substeps(len(scene_frames))
        for frame in scene_frames:
            if EXPORT_ANIMATION:
                context_name[2] = '_%.6d' % frame
            scene.frame_set(frame, 0.0)
            if EXPORT_SEL_ONLY:
                objects = context.selected_objects
            else:
                objects = scene.objects
            
            full_path = ''.join(context_name)
            write_file(full_path, objects, scene,
                       EXPORT_TRI,
                       EXPORT_EDGES,
                       EXPORT_SMOOTH_GROUPS,
                       EXPORT_SMOOTH_GROUPS_BITFLAGS,
                       EXPORT_NORMALS,
                       EXPORT_UV,
                       EXPORT_MTL,
                       EXPORT_APPLY_MODIFIERS,
                       EXPORT_BLEN_OBS,
                       EXPORT_GROUP_BY_OB,
                       EXPORT_GROUP_BY_MAT,
                       EXPORT_KEEP_VERT_ORDER,
                       EXPORT_POLYGROUPS,
                       EXPORT_CURVE_AS_NURBS,
                       EXPORT_GLOBAL_MATRIX,
                       EXPORT_PATH_MODE,
                       progress,
                       )
        scene.frame_set(orig_frame, 0.0)
        progress.leave_substeps()

def save(context,
         filepath,
         *,
         use_triangles=False,
         use_edges=True,
         use_normals=False,
         use_smooth_groups=False,
         use_smooth_groups_bitflags=False,
         use_uvs=True,
         use_materials=True,
         use_mesh_modifiers=True,
         use_blen_objects=True,
         group_by_object=False,
         group_by_material=False,
         keep_vertex_order=False,
         use_vertex_groups=False,
         use_nurbs=True,
         use_selection=True,
         use_animation=False,
         global_matrix=None,
         path_mode='AUTO'
         ):
    _write(context, filepath,
           EXPORT_TRI=use_triangles,
           EXPORT_EDGES=use_edges,
           EXPORT_SMOOTH_GROUPS=use_smooth_groups,
           EXPORT_SMOOTH_GROUPS_BITFLAGS=use_smooth_groups_bitflags,
           EXPORT_NORMALS=use_normals,
           EXPORT_UV=use_uvs,
           EXPORT_MTL=use_materials,
           EXPORT_APPLY_MODIFIERS=use_mesh_modifiers,
           EXPORT_BLEN_OBS=use_blen_objects,
           EXPORT_GROUP_BY_OB=group_by_object,
           EXPORT_GROUP_BY_MAT=group_by_material,
           EXPORT_KEEP_VERT_ORDER=keep_vertex_order,
           EXPORT_POLYGROUPS=use_vertex_groups,
           EXPORT_CURVE_AS_NURBS=use_nurbs,
           EXPORT_SEL_ONLY=use_selection,
           EXPORT_ANIMATION=use_animation,
           EXPORT_GLOBAL_MATRIX=global_matrix,
           EXPORT_PATH_MODE=path_mode,
           )

    return {'FINISHED'}

def main():
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
            save(bpy.context, output_file_path, use_selection=True, use_triangles=True)
            
            # Delete the temporary object
            bpy.ops.object.delete()

            print(f"Model exported to {output_file_path}")

    print("All mesh objects have been processed and exported.")

if __name__ == "__main__":
    main()
