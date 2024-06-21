;   210 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
sid: equ 100
mid: equ 1
oid: equ 1
bmid1: equ 101
bmid2: equ 102
model_vertices: equ 8
model_indexes: equ 36

obj_scale: equ 6*256

;   230 scene_width%=320: scene_height%=240
scene_width: equ 320
scene_height: equ 240

;   250 f=32767.0/256.0
;   260 distx=0*f: disty=0*f: distz=-25*f
cam_f: equ 32767/256
cam_distx: equ 0*cam_f
cam_disty: equ 2*cam_f
cam_distz: equ -25*cam_f

;   280 pi2=PI*2.0: f=32767.0/pi2
;   290 anglex=0.0*f
cam_anglex: equ -2086

str_create_object: db "Creating 3D object.\r\n",0
str_scale_object: db "Scaling object.\r\n",0
str_create_target_bitmap: db "Creating target bitmap.\r\n",0
str_set_texture_pixel: db "Setting texture pixel.\r\n",0
str_create_texture_bitmap: db "Creating texture bitmap.\r\n",0
str_zeroes: db "Sending some magic zeroes.\r\n",0
str_set_tex_coord_idxs: db "Setting texture coordinate indices.\r\n",0
str_set_texture_coordinates: db "Sending texture coordinates.\r\n",0
str_set_mesh_vertex_indexes: db "Sending vertex indexes.\r\n",0
str_send_vertices: db "Sending vertices.\r\n",0
str_set_camera_x_rotation: db "Setting camera X rotation.\r\n",0
str_set_camera_distance: db "Setting camera distance.\r\n",0
str_create_control: db "Creating control structure.\r\n",0

cube_init:
;   220 PRINT "Creating control structure"
    ld hl,str_create_control
    call printString
    ld hl,@ccs_beg
    ld bc,@ccs_end-@ccs_beg
    rst.lil $18
    jp @ccs_end
@ccs_beg:
;   240 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
    db 23,0,$A0
    dw sid 
    db $49,0
    dw scene_width
    dw scene_height
@ccs_end:
    ld a,%01000000
    call multiPurposeDelay

; set camera distance
    ld hl,str_set_camera_distance
    call printString
    ld hl,@scd_beg
    ld bc,@scd_end-@scd_beg
    rst.lil $18
    jp @scd_end
@scd_beg:
;   270 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
    db 23,0,$A0
    dw sid
    db $49,25
    dw cam_distx
    dw cam_disty
    dw cam_distz
@scd_end:
    ld a,%01000000
    call multiPurposeDelay

; set camera x rotation
    ld hl,str_set_camera_x_rotation
    call printString
    ld hl,@scxr_beg
    ld bc,@scxr_end-@scxr_beg
    rst.lil $18
    jp @scxr_end
@scxr_beg:
;   300 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
    db 23,0,$A0
    dw sid
    db $49,18
    dw cam_anglex
@scxr_end:
    ld a,%01000000
    call multiPurposeDelay

;   310 PRINT "Sending vertices using factor ";factor
    ld hl,str_send_vertices
    call printString
    ld hl,@sv_beg
    ld bc,@sv_end-@sv_beg
    rst.lil $18
    jp @sv_end
@sv_beg:
;   320 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
    db 23,0,$A0
    dw sid
    db $49,1
    dw mid, model_vertices
    dw 16384, -16384, 16384
    dw 16384, 16384, 16384
    dw 16384, -16384, -16384
    dw 16384, 16384, -16384
    dw -16384, -16384, 16384
    dw -16384, 16384, 16384
    dw -16384, -16384, -16384
    dw -16384, 16384, -16384
@sv_end:
    ld a,%01000000
    call multiPurposeDelay

;   390 PRINT "Reading and sending vertex indexes"
    ld hl,str_set_mesh_vertex_indexes
    call printString
    ld hl,@smvi_beg
    ld bc,@smvi_end-@smvi_beg
    rst.lil $18
    jp @smvi_done
@smvi_beg:
;   400 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indexes%; : REM Set Mesh Vertex Indexes
    db 23,0,$A0
    dw sid
    db $49,2
    dw mid, model_indexes
    dw 4, 2, 0
    dw 2, 7, 3
    dw 6, 5, 7
    dw 1, 7, 5
    dw 0, 3, 1
    dw 4, 1, 5
    dw 4, 6, 2
    dw 2, 6, 7
    dw 6, 4, 5
    dw 1, 3, 7
    dw 0, 2, 3
    dw 4, 0, 1
@smvi_end:
@smvi_done:
    ld a,%01000000
    call multiPurposeDelay

;   470 PRINT "Sending texture coordinate indexes"
    ld hl,str_set_texture_coordinates
    call printString
    ld hl,@stc_beg
    ld bc,@stc_end-@stc_beg
    rst.lil $18
    jp @stc_end
@stc_beg:
;   480 VDU 23,0, &A0, sid%; &49, 3, mid%; 1; 32768; 32768; : REM Define Texture Coordinates
    db 23,0,$A0
    dw sid
    db $49,3
    dw mid
    dw 1
    dw 32768
    dw 32768
@stc_end:
    ld a,%01000000
    call multiPurposeDelay

    ld hl,str_set_tex_coord_idxs
    call printString
    ld hl,@stci_beg
    ld bc,@stci_end-@stci_beg
    jp @stci_end
@stci_beg:
;   490 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indexes%; : REM Set Texture Coordinate Indexes
    db 23,0,$A0
    dw sid
    db $49,4
    dw mid, model_indexes
@stci_end:
@stci_done:
    ld a,%01000000
    call multiPurposeDelay

    ld hl,str_zeroes
    call printString
;   500 FOR i%=0 TO model_indexes%-1
;   510   VDU 0;
;   520 NEXT i%
    ld hl,model_indexes
@zeroes_loop:
    xor a
    rst.lil $10
    dec hl
    add hl,de
    or a
    sbc hl,de
    jr nz,@zeroes_loop
    ld a,%01000000
    call multiPurposeDelay

;   530 PRINT "Creating texture bitmap"
    ld hl,str_create_texture_bitmap
    call printString
    ld hl,@ctb_beg
    ld bc,@ctb_end-@ctb_beg
    rst.lil $18
    jp @ctb_end
@ctb_beg:
;   540 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
    db 23,27,0
    dw bmid1
@ctb_end:
    ld a,%01000000
    call multiPurposeDelay

;   550 PRINT "Setting texture pixel"
    ld hl,str_set_texture_pixel
    call printString
    ld hl,@stp_beg
    ld bc,@stp_end-@stp_beg
    rst.lil $18
    jp @stp_end
@stp_beg:
;   560 VDU 23, 27, 1, 1; 1; &55, &AA, &FF, &C0 : REM Set a pixel in the bitmap
    db 23,27,1
    dw 1
    dw 1
    db $55,$AA,$FF,$C0
@stp_end:
    ld a,%01000000
    call multiPurposeDelay

;   570 PRINT "Create 3D object"
    ld hl,str_create_object
    call printString
    ld hl,@co_beg
    ld bc,@co_end-@co_beg
    rst.lil $18
    jp @co_end
@co_beg:
;   580 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
    db 23,0,$A0
    dw sid
    db $49,5
    dw oid
    dw mid
    dw bmid1+64000
@co_end:
    ld a,%01000000
    call multiPurposeDelay

;   590 PRINT "Scale object"
    ld hl,str_scale_object
    call printString
;   600 scale=6.0*256.0
    ld hl,@so_beg
    ld bc,@so_end-@so_beg
    rst.lil $18
    jp @so_end
@so_beg:
;   610 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
    db 23,0,$A0
    dw sid
    db $49,9
    dw oid
    dw obj_scale
    dw obj_scale
    dw obj_scale
@so_end:
    ld a,%01000000
    call multiPurposeDelay

;   620 PRINT "Create target bitmap"
    ld hl,str_create_target_bitmap
    call printString
    ld hl,@ctb2_beg
    ld bc,@ctb2_end-@ctb2_beg
    rst.lil $18
    jp @ctb2_end
@ctb2_beg:
;   630 VDU 23, 27, 0, bmid2% : REM Select output bitmap
    db 23,27,0
    dw bmid2
;   640 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
    db 23,27,2
    dw scene_width
    dw scene_height
    dw 0
    db $C0
@ctb2_end:
    ld a,%01000000
    call multiPurposeDelay

    ret