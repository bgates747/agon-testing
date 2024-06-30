    include "pingo/src/asm/mos_api.asm"

    .assume adl=1   
    .org 0x040000    

    jp start       

    .align 64      
    .db "MOS"       
    .db 00h         
    .db 01h

start:              
    push af
    push bc
    push de
    push ix
    push iy

    call init
    call main

exit:

    pop iy 
    pop ix
    pop de
    pop bc
    pop af
    ld hl,0

    ret 

init:
    xor a
    call vdu_set_scaling
    ld hl,str_hello_world
    call printString
    call sliced_init

    ret

;   210 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
sid: equ 100
mid: equ 1
oid: equ 1
bmid1: equ 101
bmid2: equ 102

;   230 scene_width%=320: scene_height%=240
scene_width: equ 96
scene_height: equ 96

;   250 f=32767.0/256.0
;   260 distx=0*f: disty=0*f: distz=-25*f
cam_f: equ 128 ; 32767/256
cam_distx: equ 0*cam_f
cam_disty: equ 0*cam_f
cam_distz: equ -4*cam_f

;   280 pi2=PI*2.0: f=32767.0/pi2
;   290 anglex=0.0*f
cam_anglex: equ 0

scene_init:

;   220 PRINT "Creating control structure"
    ld hl,str_create_control
    call printString
ccs:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   240 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
    db 23,0,$A0
    dw sid 
    db $49,0
    dw scene_width
    dw scene_height
@end:

; set camera distance
    ld hl,str_set_camera_distance
    call printString
scd:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   270 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
    db 23,0,$A0
    dw sid
    db $49,25
    dw cam_distx
    dw cam_disty
    dw cam_distz
@end:

; set camera x rotation
    ld hl,str_set_camera_x_rotation
    call printString
scxr:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   300 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
    db 23,0,$A0
    dw sid
    db $49,18
    dw cam_anglex
@end:

;   620 PRINT "Create target bitmap"
    ld hl,str_create_target_bitmap
    call printString
ctb2:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   630 VDU 23, 27, 0, bmid2% : REM Select output bitmap
    db 23,27,0
    dw bmid2
;   640 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
    db 23,27,2
    dw scene_width
    dw scene_height
    dw $0000
    dw $00C0
@end:

    ld hl,str_init_cmplt
    call printString
    ld a,%01000000
    call multiPurposeDelay
    ret

sliced_init:
model_vertices: equ 8
model_indexes: equ 36
obj_scale: equ 1*256

;   310 PRINT "Sending vertices using factor ";factor
    ld hl,str_send_vertices
    call printString
sv:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   320 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
    db 23,0,$A0
    dw sid
    db $49,1
    dw mid, model_vertices
    dw 32767, -32767, 32767
    dw 32767, 32767, 32767
    dw 32767, -32767, -32767
    dw 32767, 32767, -32767
    dw -32767, -32767, 32767
    dw -32767, 32767, 32767
    dw -32767, -32767, -32767
    dw -32767, 32767, -32767
@end:

;   390 PRINT "Reading and sending vertex indexes"
    ld hl,str_set_mesh_vertex_indexes
    call printString
smvi:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
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
@end:

;   470 PRINT "Sending texture coordinate indexes"
    ld hl,str_set_texture_coordinates
    call printString
stc:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   480 VDU 23,0, &A0, sid%; &49, 3, mid%; 1; 32767; 32767; : REM Define Texture Coordinates
    db 23,0,$A0
    dw sid
    db $49,3
    dw mid
    dw 1
    dw 32767
    dw 32767
@end:

    ld hl,str_set_tex_coord_idxs
    call printString
stci:
    ld hl,@beg
    ld bc,@end-@beg
    jp @end
@beg:
;   490 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indexes%; : REM Set Texture Coordinate Indexes
    db 23,0,$A0
    dw sid
    db $49,4
    dw mid, model_indexes
;   500 FOR i%=0 TO model_indexes%-1
;   510   VDU 0;
;   520 NEXT i%
    blkw model_indexes, 0
@end:

;   530 PRINT "Creating texture bitmap"
    ld hl,str_create_texture_bitmap
    call printString
ctb:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   540 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
    db 23,27,0
    dw bmid1
@end:

;   550 PRINT "Setting texture pixel"
    ld hl,str_set_texture_pixel
    call printString
stp:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   560 VDU 23, 27, 1, 1; 1; &55, &AA, &FF, &C0 : REM Set a pixel in the bitmap
    db 23,27,1
    dw 1,1
    db $55,$AA,$FF,$C0
@end:

;   570 PRINT "Create 3D object"
    ld hl,str_create_object
    call printString
co:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   580 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
    db 23,0,$A0
    dw sid
    db $49,5
    dw oid
    dw mid
    dw bmid1+64000
@end:

;   590 PRINT "Scale object"
    ld hl,str_scale_object
    call printString
so:
;   600 scale=1.0*256.0
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   610 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
    db 23,0,$A0
    dw sid
    db $49,9
    dw oid
    dw obj_scale
    dw obj_scale
    dw obj_scale
@end:
    ret

main:
    ld hl,str_render_to_bitmap
    call printString
    ld a,%01000000
    call multiPurposeDelay
; draw the cube
rendbmp:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
; 6800 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
    db 23, 0, $A0 ; Render To Bitmap
    dw sid
    db $49, 38
    dw bmid2+64000
@end:

    ld hl,str_display_output_bitmap
    call printString
    ld a,%01000000
    call multiPurposeDelay

dispbmp:
; 6810 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
    db 23, 27, 3 ; Display output bitmap
    dw 16, 16
@end:

    ret

    include "pingo/src/asm/vdu.asm"
    include "pingo/src/asm/vdu_pingo.asm"
    include "pingo/src/asm/functions.asm"
    include "pingo/src/asm/timer.asm"

str_hello_world: db "Welcome to the Pingo 3D Demo!\r\n",0
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
str_init_cmplt: db "Initialization complete.\r\n",0
str_render_to_bitmap: db "Rendering to bitmap.\r\n",0
str_display_output_bitmap: db "Displaying output bitmap.\r\n",0
