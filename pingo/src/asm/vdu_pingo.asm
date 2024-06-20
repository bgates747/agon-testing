; sid: equ -2

; Create Control Structure
; VDU 23, 0, &A0, sid; &49, 0, w; h; : Create Control Structure
; This command initializes a control structure used to do 3D rendering. The structure is housed inside the designated buffer. The buffer referred to by the scene ID (sid) is created, if it does not already exist.
; The given width and height determine the size of the final rendered scene.
; inputs: bc = w; de = h;
vdu_3d_crt_ctl_str:
    ld (@w),bc
    ld (@h),de
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 0 ; command 0: create control structure
@w:   dw 0x0000
@h:   dw 0x0000
@end: db 0x00 ; padding

; Define Mesh Vertices
; VDU 23, 0, &A0, sid; &49, 1, mid; n; x0; y0; z0; ... : Define Mesh Vertices
; This command establishes the list of mesh coordinates to be used to define a surface structure. The mesh may be referenced by multiple objects.
; The "n" parameter is the number of vertices, so the total number of coordinates specified equals n*3.
; inputs: hl = mid; bc = n; de = pointer to list of coordinates
vdu_3d_def_msh_verts:
    push bc ; save n
    ld (@mid),hl
    ld (@n),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    pop hl ; restore n
    push hl ; save n
    add hl,hl ; n*2
    pop bc ; restore n
    add hl,bc ; n*2+n = n*3 = total number of bytes in list of coordinates
    ld b,h
    ld c,l ; bc = number of bytes
    ex de,hl ; hl is pointer to list of coordinates
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 1 ; command 1: define mesh vertices
@mid: dw 0x0000
@n:   dw 0x0000
@end: db 0x00 ; padding

; Set Mesh Vertex Indexes
; VDU 23, 0, &A0, sid; &49, 2, mid; n; i0; ... : Set Mesh Vertex Indexes
; This command lists the indexes of the vertices that define a 3D mesh. 
; Individual vertices are often referenced multiple times within a mesh, because they are often part of multiple surface triangles. 
; Each index value ranges from 0 to the number of defined mesh vertices.
; The "n" parameter is the number of indexes, and must match the "n" in subcommand 4 (Set Texture Coordinate Indexes).
; inputs: hl = mid; bc = n; de = pointer to list of indexes
vdu_3d_set_msh_vert_idxs:
    push bc ; save n
    ld (@mid),hl
    ld (@n),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    pop bc ; restore n
    ex de,hl ; hl is pointer to list of indexes
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 2 ; command 2: set mesh vertex indexes
@mid: dw 0x0000
@n:   dw 0x0000
@end: db 0x00 ; padding

; Define Texture Coordinates
; VDU 23, 0, &A0, sid; &49, 3, mid; n; u0; v0; ... : Define Texture Coordinates
; This command establishes the list of U/V texture coordinates that define texturing for a mesh.
; The "n" parameter is the number of coordinate pairs, so the total number of coordinates specified equals n*2.
; inputs: hl = mid; bc = n; de = pointer to list of coordinates
vdu_3d_def_tex_coords:
    push bc ; save n
    ld (@mid),hl
    ld (@n),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    pop hl ; restore n
    add hl,hl ; n*2
    ld b,h
    ld c,l ; bc = number of bytes
    ex de,hl ; hl is pointer to list of coordinates
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 3 ; command 3: define texture coordinates
@mid: dw 0x0000
@n:   dw 0x0000
@end: db 0x00 ; padding

; Set Texture Coordinate Indexes
; VDU 23, 0, &A0, sid; &49, 4, mid; n; i0; ... : Set Texture Coordinate Indexes
; This command lists the indexes of the coordinates that define a 3D texture for a mesh. Individual coordinates may be referenced multiple times within a texture, but that is not required. 
; The number of indexes passed in this command must match the number of mesh indexes defining the mesh. 
; Thus, each mesh vertex has texture coordinates associated with it.
; The "n" parameter is the number of indexes, and must match the "n" in subcommand 2 (Set Mesh Vertex Indexes).
; inputs: hl = mid; bc = n; de = pointer to list of indexes
vdu_3d_set_tex_coord_idxs:
    push bc ; save n
    ld (@mid),hl
    ld (@n),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    pop bc ; restore n
    ex de,hl ; hl is pointer to list of indexes
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 4 ; command 4: set texture coordinate indexes
@mid: dw 0x0000
@n:   dw 0x0000
@end: db 0x00 ; padding

; Define Object
; VDU 23, 0, &A0, sid; &49, 5, oid; mid; bmid; : Create Object
; This command defines a renderable object in terms of its already-defined mesh, plus a reference to an existing bitmap that provides its coloring, via the texture coordinates used by the mesh.
; The same mesh can be used multiple times, with the same or different bitmaps for coloring. The bitmap must be in the RGBA8888 format (4 bytes per pixel).
; inputs: hl = oid; de = mid; bc = bmid;
vdu_3d_def_obj:
    ld (@oid),hl
    ld (@mid),de
    ld (@bmid),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 5 ; command 5: define object
@oid: dw 0x0000
@mid: dw 0x0000
@bmid: dw 0x0000
@end: db 0x00 ; padding

; Set Object X Scale Factor
; VDU 23, 0, &A0, sid; &49, 6, oid; scalex; : Set Object X Scale Factor
; This command sets the X scale factor for an object.
; inputs: hl = oid; bc = scalex;
vdu_3d_set_obj_x_scl:
    ld (@oid),hl
    ld (@scalex),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 6 ; command 6: set object x scale factor
@oid: dw 0x0000
@scalex: dw 0x0000
@end: db 0x00 ; padding

; Set Object Y Scale Factor
; VDU 23, 0, &A0, sid; &49, 7, oid; scaley; : Set Object Y Scale Factor
; This command sets the Y scale factor for an object.
; inputs: hl = oid; bc = scaley;
vdu_3d_set_obj_y_scl:
    ld (@oid),hl
    ld (@scaley),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 7 ; command 7: set object y scale factor
@oid: dw 0x0000
@scaley: dw 0x0000
@end: db 0x00 ; padding

; Set Object Z Scale Factor
; VDU 23, 0, &A0, sid; &49, 8, oid; scalez; : Set Object Z Scale Factor
; This command sets the Z scale factor for an object.
; inputs: hl = oid; bc = scalez;
vdu_3d_set_obj_z_scl:
    ld (@oid),hl
    ld (@scalez),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 8 ; command 8: set object z scale factor
@oid: dw 0x0000
@scalez: dw 0x0000
@end: db 0x00 ; padding

; Set Object XYZ Scale Factors
; VDU 23, 0, &A0, sid; &49, 9, oid; scalex; scaley; scalez; : Set Object XYZ Scale Factors
; This command sets the X, Y, and Z scale factors for an object.
; inputs: hl = oid; ix = scalex; iy = scaley; bc = scalez;
vdu_3d_set_obj_xyz_scl:
    ld (@oid),hl
    ld (@scalex),ix
    ld (@scaley),iy
    ld (@scalez),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 9 ; command 9: set object xyz scale factors
@oid: dw 0x0000
@scalex: dw 0x0000
@scaley: dw 0x0000
@scalez: dw 0x0000
@end: db 0x00 ; padding

; Set Object X Rotation Angle
; VDU 23, 0, &A0, sid; &49, 10, oid; anglex; : Set Object X Rotation Angle
; This command sets the X rotation angle for an object.
; inputs: hl = oid; bc = anglex;
vdu_3d_set_obj_x_rot:
    ld (@oid),hl
    ld (@anglex),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 10 ; command 10: set object x rotation angle
@oid: dw 0x0000
@anglex: dw 0x0000
@end: db 0x00 ; padding

; Set Object Y Rotation Angle
; VDU 23, 0, &A0, sid; &49, 11, oid; angley; : Set Object Y Rotation Angle
; This command sets the Y rotation angle for an object.
; inputs: hl = oid; bc = angley;
vdu_3d_set_obj_y_rot:
    ld (@oid),hl
    ld (@angley),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 11 ; command 11: set object y rotation angle
@oid: dw 0x0000
@angley: dw 0x0000
@end: db 0x00 ; padding

; Set Object Z Rotation Angle
; VDU 23, 0, &A0, sid; &49, 12, oid; anglez; : Set Object Z Rotation Angle
; This command sets the Z rotation angle for an object.
; inputs: hl = oid; bc = anglez;
vdu_3d_set_obj_z_rot:
    ld (@oid),hl
    ld (@anglez),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 12 ; command 12: set object z rotation angle
@oid: dw 0x0000
@anglez: dw 0x0000
@end: db 0x00 ; padding

; Set Object XYZ Rotation Angles
; VDU 23, 0, &A0, sid; &49, 13, oid; anglex; angley; anglez; : Set Object XYZ Rotation Angles
; This command sets the X, Y, and Z rotation angles for an object.
; inputs: hl = oid; ix = anglex; iy = angley; bc = anglez;
vdu_3d_set_obj_xyz_rot:
    ld (@oid),hl
    ld (@anglex),ix
    ld (@angley),iy
    ld (@anglez),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 13 ; command 13: set object xyz rotation angles
@oid: dw 0x0000
@anglex: dw 0x0000
@angley: dw 0x0000
@anglez: dw 0x0000
@end: db 0x00 ; padding

; Set Object X Translation Distance
; VDU 23, 0, &A0, sid; &49, 14, oid; distx; : Set Object X Translation Distance
; This command sets the X translation distance for an object. Note that 3D translation of an object is independent of 2D translation of the the rendered bitmap.
; inputs: hl = oid; bc = distx;
vdu_3d_set_obj_x_trans:
    ld (@oid),hl
    ld (@distx),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 14 ; command 14: set object x translation distance
@oid: dw 0x0000
@distx: dw 0x0000
@end: db 0x00 ; padding

; Set Object Y Translation Distance
; VDU 23, 0, &A0, sid; &49, 15, oid; disty; : Set Object Y Translation Distance
; This command sets the Y translation distance for an object. Note that 3D translation of an object is independent of 2D translation of the the rendered bitmap.
; inputs: hl = oid; bc = disty;
vdu_3d_set_obj_y_trans:
    ld (@oid),hl
    ld (@disty),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 15 ; command 15: set object y translation distance
@oid: dw 0x0000
@disty: dw 0x0000
@end: db 0x00 ; padding

; Set Object Z Translation Distance
; VDU 23, 0, &A0, sid; &49, 16, oid; distz; : Set Object Z Translation Distance
; This command sets the Z translation distance for an object. Note that 3D translation of an object is independent of 2D translation of the the rendered bitmap.
; inputs: hl = oid; bc = distz;
vdu_3d_set_obj_z_trans:
    ld (@oid),hl
    ld (@distz),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 16 ; command 16: set object z translation distance
@oid: dw 0x0000
@distz: dw 0x0000
@end: db 0x00 ; padding

; Set Object XYZ Translation Distances
; VDU 23, 0, &A0, sid; &49, 17, oid; distx; disty; distz; : Set Object XYZ Translation Distances
; This command sets the X, Y, and Z translation distances for an object. Note that 3D translation of an object is independent of 2D translation of the the rendered bitmap.
; inputs: hl = oid; ix = distx; iy = disty; bc = distz;
vdu_3d_set_obj_xyz_trans:
    ld (@oid),hl
    ld (@distx),ix
    ld (@disty),iy
    ld (@distz),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 17 ; command 17: set object xyz translation distances
@oid: dw 0x0000
@distx: dw 0x0000
@disty: dw 0x0000
@distz: dw 0x0000
@end: db 0x00 ; padding

; Set Camera X Rotation Angle
; VDU 23, 0, &A0, sid; &49, 18, anglex; : Set Camera X Rotation Angle
; This command sets the X rotation angle for the camera.
; inputs: hl = anglex;
vdu_3d_set_cam_x_rot:
    ld (@anglex),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 18 ; command 18: set camera x rotation angle
@anglex: dw 0x0000
@end: db 0x00 ; padding

; Set Camera Y Rotation Angle
; VDU 23, 0, &A0, sid; &49, 19, angley; : Set Camera Y Rotation Angle
; This command sets the Y rotation angle for the camera.
; inputs: hl = angley;
vdu_3d_set_cam_y_rot:
    ld (@angley),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 19 ; command 19: set camera y rotation angle
@angley: dw 0x0000
@end: db 0x00 ; padding

; Set Camera Z Rotation Angle
; VDU 23, 0, &A0, sid; &49, 20, anglez; : Set Camera Z Rotation Angle
; This command sets the Z rotation angle for the camera.
; inputs: hl = anglez;
vdu_3d_set_cam_z_rot:
    ld (@anglez),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 20 ; command 20: set camera z rotation angle
@anglez: dw 0x0000
@end: db 0x00 ; padding

; Set Camera XYZ Rotation Angles
; VDU 23, 0, &A0, sid; &49, 21, anglex; angley; anglez; : Set Camera XYZ Rotation Angles
; This command sets the X, Y, and Z rotation angles for the camera.
; inputs: ix = anglex; iy = angley; hl = anglez;
vdu_3d_set_cam_xyz_rot:
    ld (@anglex),ix
    ld (@angley),iy
    ld (@anglez),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 21 ; command 21: set camera xyz rotation angles
@anglex: dw 0x0000
@angley: dw 0x0000
@anglez: dw 0x0000
@end: db 0x00 ; padding

; Set Camera X Translation Distance
; VDU 23, 0, &A0, sid; &49, 22, distx; : Set Camera X Translation Distance
; This command sets the X translation distance for the camera. Note that 3D translation of the camera is independent of 2D translation of the the rendered bitmap.
; inputs: hl = distx;
vdu_3d_set_cam_x_trans:
    ld (@distx),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 22 ; command 22: set camera x translation distance
@distx: dw 0x0000
@end: db 0x00 ; padding

; Set Camera Y Translation Distance
; VDU 23, 0, &A0, sid; &49, 23, disty; : Set Camera Y Translation Distance
; This command sets the Y translation distance for the camera. Note that 3D translation of the camera is independent of 2D translation of the the rendered bitmap.
; inputs: hl = disty;
vdu_3d_set_cam_y_trans:
    ld (@disty),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 23 ; command 23: set camera y translation distance
@disty: dw 0x0000
@end: db 0x00 ; padding

; Set Camera Z Translation Distance
; VDU 23, 0, &A0, sid; &49, 24, distz; : Set Camera Z Translation Distance
; This command sets the Z translation distance for the camera. Note that 3D translation of the camera is independent of 2D translation of the the rendered bitmap.
; inputs: hl = distz;
vdu_3d_set_cam_z_trans:
    ld (@distz),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 24 ; command 24: set camera z translation distance
@distz: dw 0x0000
@end: db 0x00 ; padding

; Set Camera XYZ Translation Distances
; VDU 23, 0, &A0, sid; &49, 25, distx; disty; distz; : Set Camera XYZ Translation Distances
; This command sets the X, Y, and Z translation distances for the camera. Note that 3D translation of the camera is independent of 2D translation of the the rendered bitmap.
; inputs: ix = distx; iy = disty; hl = distz;
vdu_3d_set_cam_xyz_trans:
    ld (@distx),ix
    ld (@disty),iy
    ld (@distz),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 25 ; command 25: set camera xyz translation distances
@distx: dw 0x0000
@disty: dw 0x0000
@distz: dw 0x0000
@end: db 0x00 ; padding

; Set Scene X Scale Factor
; VDU 23, 0, &A0, sid; &49, 26, scalex; : Set Scene X Scale Factor
; This command sets the X scale factor for the scene.
; inputs: hl = scalex;
vdu_3d_set_scn_x_scl:
    ld (@scalex),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 26 ; command 26: set scene x scale factor
@scalex: dw 0x0000
@end: db 0x00 ; padding

; Set Scene Y Scale Factor
; VDU 23, 0, &A0, sid; &49, 27, scaley; : Set Scene Y Scale Factor
; This command sets the Y scale factor for the scene.
; inputs: hl = scaley;
vdu_3d_set_scn_y_scl:
    ld (@scaley),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 27 ; command 27: set scene y scale factor
@scaley: dw 0x0000
@end: db 0x00 ; padding

; Set Scene Z Scale Factor
; VDU 23, 0, &A0, sid; &49, 28, scalez; : Set Scene Z Scale Factor
; This command sets the Z scale factor for the scene.
; inputs: hl = scalez;
vdu_3d_set_scn_z_scl:
    ld (@scalez),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 28 ; command 28: set scene z scale factor
@scalez: dw 0x0000
@end: db 0x00 ; padding

; Set Scene XYZ Scale Factors
; VDU 23, 0, &A0, sid; &49, 29, scalex; scaley; scalez; : Set Scene XYZ Scale Factors
; This command sets the X, Y, and Z scale factors for the scene.
; inputs: ix = scalex; iy = scaley; hl = scalez;
vdu_3d_set_scn_xyz_scl:
    ld (@scalex),ix
    ld (@scaley),iy
    ld (@scalez),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 29 ; command 29: set scene xyz scale factors
@scalex: dw 0x0000
@scaley: dw 0x0000
@scalez: dw 0x0000
@end: db 0x00 ; padding
; Set Scene X Rotation Angle
; VDU 23, 0, &A0, sid; &49, 30, anglex; : Set Scene X Rotation Angle
; This command sets the X rotation angle for the scene.
; inputs: hl = anglex;
vdu_3d_set_scn_x_rot:
    ld (@anglex),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 30 ; command 30: set scene x rotation angle
@anglex: dw 0x0000
@end: db 0x00 ; padding

; Set Scene Y Rotation Angle
; VDU 23, 0, &A0, sid; &49, 31, angley; : Set Scene Y Rotation Angle
; This command sets the Y rotation angle for the scene.
; inputs: hl = angley;
vdu_3d_set_scn_y_rot:
    ld (@angley),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 31 ; command 31: set scene y rotation angle
@angley: dw 0x0000
@end: db 0x00 ; padding

; Set Scene Z Rotation Angle
; VDU 23, 0, &A0, sid; &49, 32, anglez; : Set Scene Z Rotation Angle
; This command sets the Z rotation angle for the scene.
; inputs: hl = anglez;
vdu_3d_set_scn_z_rot:
    ld (@anglez),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 32 ; command 32: set scene z rotation angle
@anglez: dw 0x0000
@end: db 0x00 ; padding

; Set Scene XYZ Rotation Angles
; VDU 23, 0, &A0, sid; &49, 33, anglex; angley; anglez; : Set Scene XYZ Rotation Angles
; This command sets the X, Y, and Z rotation angles for the scene.
; inputs: ix = anglex; iy = angley; hl = anglez;
vdu_3d_set_scn_xyz_rot:
    ld (@anglex),ix
    ld (@angley),iy
    ld (@anglez),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 33 ; command 33: set scene xyz rotation angles
@anglex: dw 0x0000
@angley: dw 0x0000
@anglez: dw 0x0000
@end: db 0x00 ; padding
; Set Scene X Translation Distance
; VDU 23, 0, &A0, sid; &49, 34, distx; : Set Scene X Translation Distance
; This command sets the X translation distance for the scene. Note that 3D translation of the scene is independent of 2D translation of the the rendered bitmap.
; inputs: hl = distx;
vdu_3d_set_scn_x_trans:
    ld (@distx),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 34 ; command 34: set scene x translation distance
@distx: dw 0x0000
@end: db 0x00 ; padding

; Set Scene Y Translation Distance
; VDU 23, 0, &A0, sid; &49, 35, disty; : Set Scene Y Translation Distance
; This command sets the Y translation distance for the scene. Note that 3D translation of the scene is independent of 2D translation of the the rendered bitmap.
; inputs: hl = disty;
vdu_3d_set_scn_y_trans:
    ld (@disty),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 35 ; command 35: set scene y translation distance
@disty: dw 0x0000
@end: db 0x00 ; padding

; Set Scene Z Translation Distance
; VDU 23, 0, &A0, sid; &49, 36, distz; : Set Scene Z Translation Distance
; This command sets the Z translation distance for the scene. Note that 3D translation of the scene is independent of 2D translation of the the rendered bitmap.
; inputs: hl = distz;
vdu_3d_set_scn_z_trans:
    ld (@distz),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 36 ; command 36: set scene z translation distance
@distz: dw 0x0000
@end: db 0x00 ; padding

; Set Scene XYZ Translation Distances
; VDU 23, 0, &A0, sid; &49, 37, distx; disty; distz; : Set Scene XYZ Translation Distances
; This command sets the X, Y, and Z translation distances for the scene. Note that 3D translation of the scene is independent of 2D translation of the the rendered bitmap.
; inputs: ix = distx; iy = disty; hl = distz;
vdu_3d_set_scn_xyz_trans:
    ld (@distx),ix
    ld (@disty),iy
    ld (@distz),hl
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 37 ; command 37: set scene xyz translation distances
@distx: dw 0x0000
@disty: dw 0x0000
@distz: dw 0x0000
@end: db 0x00 ; padding

; Render To Bitmap
; VDU 23, 0, &A0, sid; &49, 38, bmid; : Render To Bitmap
; This command uses information provided by the above commands to render the 3D scene onto the specified bitmap. 
; This command must be used in order to perform the render operation; it does not happen automatically when other commands change some of the render parameters.
; inputs: bc = bmid;
vdu_3d_render_to_bitmap:
    ld (@bmid),bc
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 38 ; command 38: render to bitmap
@bmid: dw 0x0000
@end: db 0x00 ; padding

; Delete Control Structure
; VDU 23, 0, &A0, sid; &49, 39 : Delete Control Structure
; This command deinitializes an existing control structure, assuming that it exists in the designated buffer. The buffer is subsequently deleted, as part of processing for this command.
; inputs: none
vdu_3d_del_ctl_str:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg: db 23, 0, $A0
@sid: dw sid
@cmd: db $49, 39 ; command 39: delete control structure
@end: 
