teapot_init:
; 6280 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
sid: equ 100
mid: equ 1
oid: equ 1
bmid1: equ 101
bmid2: equ 102

; 6290 PRINT "Creating control structure"
    ld hl,str_create_control
    call printString
    jp ccs
str_create_control: db "Creating control structure.\r\n",0
; 6300 scene_width%=96: scene_height%=96
scene_width: equ 96
scene_height: equ 96
; 6310 VDU 23,0,$A0,sid%; $49,0,scene_width%; scene_height%; : REM Create Control Structure
ccs:
    ld hl,@ccs_beg
    ld bc,@ccs_end-@ccs_beg
    rst.lil $18
    jp @ccs_end
@ccs_beg:
    db 23,0,$A0
    dw sid 
    db $49,0
    dw scene_width
    dw scene_height
@ccs_end:
    ld a,%01000000
    call multiPurposeDelay

; 6320 f=32767.0/256.0
; 6330 distx=0*f: disty=2*f: distz=-20*f
cam_f: equ 32767/256
cam_distx: equ 0*cam_f
cam_disty: equ 2*cam_f
cam_distz: equ -20*cam_f
    ld hl,str_set_camera_distance
    call printString
    jp scd
str_set_camera_distance: db "Setting camera distance.\r\n",0
; 6340 VDU 23,0,$A0,sid%; $49,25,distx; disty; distz; : REM Set Camera XYZ Translation Distances
scd:
    ld hl,@scd_beg
    ld bc,@scd_end-@scd_beg
    rst.lil $18
    jp @scd_end
@scd_beg:
    db 23,0,$A0
    dw sid
    db $49,25
    dw cam_distx
    dw cam_disty
    dw cam_distz
@scd_end:
        ld a,%01000000
        call multiPurposeDelay

; 6350 pi2=PI*2.0: f=32767.0/pi2
; 6360 anglex=-0.4*f
cam_anglex: equ -2086
    ld hl,str_set_camera_x_rotation
    call printString
    jp scxr
str_set_camera_x_rotation: db "Setting camera X rotation.\r\n",0
; 6370 VDU 23,0,$A0,sid%; $49,18,anglex; : REM Set Camera X Rotation Angle
scxr:
    ld hl,@scxr_beg
    ld bc,@scxr_end-@scxr_beg
    rst.lil $18
    jp @scxr_end
@scxr_beg:
    db 23,0,$A0
    dw sid
    db $49,18
    dw cam_anglex
@scxr_end:
    ld a,%01000000
    call multiPurposeDelay

; 6380 PRINT "Sending vertices using factor ";factor
    ld hl,str_send_vertices
    call printString
    jp sv
str_send_vertices: db "Sending vertices.\r\n",0
; 6390 VDU 23,0,$A0,sid%; $49,1,mid%; teapot_vertices%; : REM Define Mesh Vertices
sv:
    ld hl,@sv_beg
    ld bc,@sv_end-@sv_beg
    rst.lil $18
    ld hl,teapot_vertices
    ld bc,teapot_num_vertices*6 ; 2 bytes per vertex,3 vertices per triangle
    rst.lil $18
    jp @sv_done
@sv_beg:
    db 23,0,$A0
    dw sid
    db $49,1
    dw mid
@sv_end:
@sv_done:
    ld a,%01000000
    call multiPurposeDelay

; 6460 PRINT "Reading and sending vertex indexes"
    ld hl,str_set_mesh_vertex_indexes
    call printString
    jp smvi
str_set_mesh_vertex_indexes: db "Sending vertex indexes.\r\n",0
; 6470 VDU 23,0,$A0,sid%; $49,2,mid%; teapot_vertices%; : REM Set Mesh Vertex Indexes
smvi:
    ld hl,@smvi_beg
    ld bc,@smvi_end-@smvi_beg
    rst.lil $18
    ld hl,teapot_vertex_indices
    ld bc,teapot_num_vertices*2 ; 2 bytes per index
    rst.lil $18
    jp @smvi_end
@smvi_beg:
    db 23,0,$A0
    dw sid
    db $49,2
    dw mid
@smvi_end:
@smvi_done:
    ld a,%01000000
    call multiPurposeDelay

; 6540 PRINT "Sending texture coordinate indexes"
    ld hl,str_set_texture_coordinates
    call printString
    jp stc
str_set_texture_coordinates: db "Sending texture coordinates.\r\n",0
; 6550 VDU 23,0,$A0,sid%; $49,3,mid%; 1; 32768; 32768; : REM Define Texture Coordinates
stc:
    ld hl,@stc_beg
    ld bc,@stc_end-@stc_beg
    rst.lil $18
    jp @stc_end
@stc_beg:
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

; 6540 PRINT "Sending texture coordinate indexes"
    ld hl,str_set_tex_coord_idxs
    call printString
    jp stci
str_set_tex_coord_idxs: db "Setting texture coordinate indices.\r\n",0
stci:
    ld hl,@stci_beg
    ld bc,@stci_end-@stci_beg
    rst.lil $18
    ld hl,teapot_vertex_indices
    ld bc,teapot_num_vertices*2 ; 2 bytes per index
    rst.lil $18
    jp @stci_end
@stci_beg:
; 6560 VDU 23,0, &A0, sid%; &49, 4, mid%; teapot_vertices%; : REM Set Texture Coordinate Indexes
    db 23,0,$A0
    dw sid
    db $49,4
    dw mid
@stci_end:
@stci_done:
    ld a,%01000000
    call multiPurposeDelay

    ld hl,str_zeroes
    call printString
    jp zeroes
str_zeroes: db "Sending some magic zeroes.\r\n",0
; 6570 FOR i%=0 TO teapot_vertices%-1
; 6580   VDU 0;
; 6590 NEXT i%
zeroes:
    ld hl,teapot_num_vertices
    xor a
@zeroes_loop:
    rst.lil $10
    dec hl
    add hl,de
    or a
    sbc hl,de
    jr nz,@zeroes_loop
    ld a,%01000000
    call multiPurposeDelay

; 6600 PRINT "Creating texture bitmap"
    ld hl,str_create_texture_bitmap
    call printString
    jp ctb
str_create_texture_bitmap: db "Creating texture bitmap.\r\n",0
; 6610 VDU 23,27,0,bmid1%: REM Create a bitmap for a texture
ctb:
    ld hl,@ctb_beg
    ld bc,@ctb_end-@ctb_beg
    rst.lil $18
    jp @ctb_end
@ctb_beg:
    db 23,27,0
    dw bmid1
@ctb_end:
    ld a,%01000000
    call multiPurposeDelay

; 6620 PRINT "Setting texture pixel"
    ld hl,str_set_texture_pixel
    call printString
    jp stp
str_set_texture_pixel: db "Setting texture pixel.\r\n",0
; 6630 VDU 23,27,1,1; 1; $55,$AA,$FF,$C0 : REM Set a pixel in the bitmap
stp:
    ld hl,@stp_beg
    ld bc,@stp_end-@stp_beg
    rst.lil $18
    jp @stp_end
@stp_beg:
    db 23,27,1
    dw 1
    dw 1
    db $55,$AA,$FF,$C0
@stp_end:
    ld a,%01000000
    call multiPurposeDelay

; 6640 PRINT "Create 3D object"
    ld hl,str_create_object
    call printString
    jp co
str_create_object: db "Creating 3D object.\r\n",0
; 6650 VDU 23,0,$A0,sid%; $49,5,oid%; mid%; bmid1%+64000; : REM Create Object
co:
    ld hl,@co_beg
    ld bc,@co_end-@co_beg
    rst.lil $18
    jp @co_end
@co_beg:
    db 23,0,$A0
    dw sid
    db $49,5
    dw oid
    dw mid
    dw bmid1+64000
@co_end:
    ld a,%01000000
    call multiPurposeDelay

; 6660 PRINT "Scale object"
    ld hl,str_scale_object
    call printString
    jp so
str_scale_object: db "Scaling object.\r\n",0
; 6670 scale=6.0*256.0
obj_scale: equ 6*256
; 6680 VDU 23,0,$A0,sid%; $49,9,oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
so:
    ld hl,@so_beg
    ld bc,@so_end-@so_beg
    rst.lil $18
    jp @so_end
@so_beg:
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

; 6690 PRINT "Create target bitmap"
    ld hl,str_create_target_bitmap
    call printString
    jp ctb2
str_create_target_bitmap: db "Creating target bitmap.\r\n",0
; 6700 VDU 23,27,0,bmid2% : REM Select output bitmap
; 6710 VDU 23,27,2,scene_width%; scene_height%; $0000; $00C0; : REM Create solid color bitmap
ctb2:
    ld hl,@ctb2_beg
    ld bc,@ctb2_end-@ctb2_beg
    rst.lil $18
    jp @ctb2_end
@ctb2_beg:
    db 23,27,0
    dw bmid2
    db 23,27,2
    dw scene_width
    dw scene_height
    dw 0
    db $C0
@ctb2_end:
    ld a,%01000000
    call multiPurposeDelay

    ret

; 6720 PRINT "Render 3D object"
; 6730 VDU 23,0,$C3: REM Flip buffer
; 6740 rotatex=0.0: rotatey=0.0: rotatez=0.0
; 6750 incx=PI/16.0: incy=PI/32.0: incz=PI/64.0
; 6760 factor=32767.0/pi2
; 6770 VDU 22,136: REM 320x240x64
; 6780 VDU 23,0,$C0,0: REM Normal coordinates
; 6790 CLG
; 6800 VDU 23,0,$A0,sid%; $49,38,bmid2%+64000; : REM Render To Bitmap
; 6810 VDU 23,27,3,50; 50; : REM Display output bitmap
; 6820 VDU 23,0,$C3: REM Flip buffer
; 6830 *FX 19
; 6840 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
; 6850 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
; 6860 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
; 6870 rx=rotatex*factor: ry=rotatey*factor: rz=rotatez*factor
; 6880 VDU 23,0,$A0,sid%; $49,13,oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
; 6890 GOTO 6790
