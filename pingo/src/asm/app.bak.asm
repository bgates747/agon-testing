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

    call main

exit:
    ld hl,str_program_end
    call printString

    pop iy 
    pop ix
    pop de
    pop bc
    pop af
    ld hl,0

    ret 

main:
    ld hl,str_hello_world
    call printString

;   145 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
sid: equ 100
mid: equ 1
oid: equ 1
bmid1: equ 101
bmid2: equ 102

;   150 scene_width%=320: scene_height%=240
scene_width: equ 320
scene_height: equ 240

;    60 camf=32767.0/256.0
;    70 camx=0.0*camf
;    72 camy=0.0*camf
;    74 camz=-4.0*camf
cam_f: equ 128 ; 32767/256
cam_distx: equ 0*cam_f
cam_disty: equ 0*cam_f
cam_distz: equ -4*cam_f

;    80 pi2=PI*2.0
;    85 camanglef=32767.0/360
;    90 camanglex=0.0*camanglef
cam_anglef: equ 91 ; 32767/360
cam_anglex: equ 0*cam_anglef

;   340 PRINT "Creating control structure"
    ld hl,str_create_control
    call printString
ccs:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   350 VDU 23,0, &A0, sid%; &49, 0, scene_width%; scene_height%; : REM Create Control Structure
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
;   360 VDU 23,0, &A0, sid%; &49, 25, distx; disty; distz; : REM Set Camera XYZ Translation Distances
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
;   380 VDU 23,0, &A0, sid%; &49, 18, anglex; : REM Set Camera X Rotation Angle
    db 23,0,$A0
    dw sid
    db $49,18
    dw cam_anglex
@end:

    ld hl,str_init_cmplt
    call printString

;    20 model_vertices%=4
;    30 model_indices%=12
;    40 model_uvs%=10
model_vertices: equ 4
model_indexes: equ 12
model_uvs: equ 10
;   100 scale=1.0*256.0
obj_scale: equ 256

;   400 PRINT "Sending vertices using factor ";factor
    ld hl,str_send_vertices
    call printString
sv:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   410 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
    db 23,0,$A0
    dw sid
    db $49,1
    dw mid, model_vertices
;   410 VDU 23,0, &A0, sid%; &49, 1, mid%; model_vertices%; : REM Define Mesh Vertices
;   420 FOR i%=0 TO total_coords%-1
;   430   val%=vertices(i%)*factor
;   440   VDU val%;
;   450   REM T%=TIME
;   460   REM IF TIME-T%<1 GOTO 390
;   470 NEXT i%
	dw 0, 0, 0
	dw 0, -32767, 0
	dw 0, 0, -32767
	dw 32767, 0, 0
@end:

;   480 PRINT "Reading and sending vertex indexes"
    ld hl,str_set_mesh_vertex_indexes
    call printString
smvi:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   490 VDU 23,0, &A0, sid%; &49, 2, mid%; model_indexes%; : REM Set Mesh Vertex Indexes
    db 23,0,$A0
    dw sid
    db $49,2
    dw mid, model_indexes
;   500 FOR i%=0 TO model_indices%-1
;   510   READ val%
;   520   VDU val%;
;   530   REM T%=TIME
;   540   REM IF TIME-T%<1 GOTO 470
;   550 NEXT i%
	dw 0, 2, 1
	dw 0, 3, 2
	dw 1, 3, 0
	dw 3, 1, 2
@end:

;   560 PRINT "Sending texture UV coordinates"
    ld hl,str_set_texture_coordinates
    call printString
stc:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   570 VDU 23,0, &A0, sid%; &49, 3, mid%; model_uvs%;
    db 23,0,$A0
    dw sid
    db $49,3
    dw mid, model_uvs
;   580 total_uvs%=model_uvs%*2
;   590 FOR i%=0 TO total_uvs%-1
;   600   READ val
;   610   val%=INT(val*65535)
;   620   VDU val%;
;   630   REM T%=TIME
;   640   REM IF TIME-T%<1 GOTO 570
;   650 NEXT i%
	dw 0, 32668
	dw 32668, 0
	dw 32668, 32668
	dw 65335, 32668
	dw 32668, 65335
	dw 32668, 32668
	dw 32668, 0
	dw 65335, 32668
	dw 32668, 32668
	dw 0, 32668
@end:

;   660 PRINT "Sending Texture Coordinate indices"
    ld hl,str_set_tex_coord_idxs
    call printString
stci:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   670 VDU 23,0, &A0, sid%; &49, 4, mid%; model_indices%; 
    db 23,0,$A0
    dw sid
    db $49,4
    dw mid, model_indexes
;   680 FOR i%=0 TO model_indices%-1
;   690   READ val%
;   700   VDU val%;
;   710   REM T%=TIME
;   720   REM IF TIME-T%<1 GOTO 650
;   730 NEXT i%
	dw 0, 1, 2
	dw 3, 4, 5
	dw 6, 7, 8
	dw 4, 9, 5
@end:

;   740 PRINT "Creating texture bitmap"
    ld hl,str_create_texture_bitmap
    call printString
ctb:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   750 VDU 23, 27, 0, bmid1%: REM Create a bitmap for a texture
    db 23,27,0
    dw bmid1
@end:

;   760 PRINT "Sending texture pixel data"
    ld hl,str_set_texture_pixel
    call printString
stp:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   770 VDU 23, 27, 1, texture_width%; texture_height%; 
    db 23,27,1
@texture_width: dw 2
@texture_height: dw 2
;   780 FOR i%=0 TO texture_width%*texture_height%*4-1
;   790   READ val%
;   800   VDU val% : REM 8-bit integers for pixel data
;   810   REM T%=TIME
;   820   REM IF TIME-T%<1 GOTO 750
;   830 NEXT i%
	db 255,0,0,255,0,0,255,255,255,255,0,255,0,255,0,255
@end:

;   840 PRINT "Create 3D object"
    ld hl,str_create_object
    call printString
co:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   850 VDU 23,0, &A0, sid%; &49, 5, oid%; mid%; bmid1%+64000; : REM Create Object
    db 23,0,$A0
    dw sid
    db $49,5
    dw oid
    dw mid
    dw bmid1+64000
@end:

;   860 PRINT "Scale object"
    ld hl,str_scale_object
    call printString
so:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   870 VDU 23, 0, &A0, sid%; &49, 9, oid%; scale; scale; scale; : REM Set Object XYZ Scale Factors
    db 23,0,$A0
    dw sid
    db $49,9
    dw oid
    dw obj_scale
    dw obj_scale
    dw obj_scale
@end:

;   880 PRINT "Create target bitmap"
    ld hl,str_create_target_bitmap
    call printString
ctb2:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   890 VDU 23, 27, 0, bmid2% : REM Select output bitmap
    db 23,27,0
    dw bmid2
;   900 VDU 23, 27, 2, scene_width%; scene_height%; &0000; &00C0; : REM Create solid color bitmap
    db 23,27,2
    dw scene_width
    dw scene_height
    dw $0000
    dw $00C0
@end:

preloop:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   920 VDU 23, 0, &C3: REM Flip buffer
    db 23,0,$C3
;   930 REM VDU 22, 136: REM 320x240x64 double-buffered
    ; db 22,136
;   940 VDU 23, 0, &C0, 0: REM Normal coordinates
    db 23,0,$C0,0
;   950 REM VDU 23, 0, &C0, 1: REM Abnormal coordinates
    ; db 23,0,$C0,1
;   960 VDU 17,7+128 : REM set text background color to light gray
    db 17,7+128
;   970 VDU 18, 0, 7+128 : REM set gfx background color to light gray
    db 18,0,7+128
@end:

mainloop:

    ld hl,str_render_to_bitmap
    call printString
rendbmp:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;  1040 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
    db 23, 0, $A0
    dw sid
    db $49, 38
    dw bmid2+64000
@end:

    ld hl,str_display_output_bitmap
    call printString
dispbmp:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;  1050 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
    db 23, 27, 3 
    dw 0, 0
@end:

    ret

    include "pingo/src/asm/vdu.asm"

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
str_program_end: db "Program end.\r\n",0


; Print a zero-terminated string
; HL: Pointer to string
printString:
	PUSH	BC
	LD		BC,0
	LD 	 	A,0
	RST.LIL 18h
	POP		BC
	RET
