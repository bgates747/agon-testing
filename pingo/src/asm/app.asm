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
    ; ld hl,str_program_end
    ; call printString

    pop iy 
    pop ix
    pop de
    pop bc
    pop af
    ld hl,0

    ret 

main:
    ld a,8+128 ; 320x240x64 double-buffered
    call vdu_set_screen_mode
    
    ; ld hl,str_hello_world
    ; call printString

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
cam_disty: equ 64-16-8
cam_distz: equ -2*cam_f

;    80 pi2=PI*2.0
;    85 camanglef=32767.0/360
;    90 camanglex=0.0*camanglef
cam_anglef: equ 91 ; 32767/360
cam_anglex: equ 0*cam_anglef

; ;   340 PRINT "Creating control structure"
;     ld hl,str_create_control
;     call printString
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

; ; set camera distance
;     ld hl,str_set_camera_distance
;     call printString
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

; ; set camera x rotation
;     ld hl,str_set_camera_x_rotation
;     call printString
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

    ; ld hl,str_init_cmplt
    ; call printString

;    20 Lara5_vertices%=4
;    30 Lara5_indices%=12
;    40 Lara5_uvs%=10
; Lara5_vertices: equ 4
; Lara5_indices: equ 12
; Lara5_uvs: equ 10
;   100 scale=1.0*256.0
obj_scale: equ 256

; ;   400 PRINT "Sending vertices using factor ";factor
;     ld hl,str_send_vertices
;     call printString
sv:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   410 VDU 23,0, &A0, sid%; &49, 1, mid%; Lara5_vertices%; : REM Define Mesh Vertices
    db 23,0,$A0
    dw sid
    db $49,1
    dw mid, Lara5_vertices_n
@end:
;   410 VDU 23,0, &A0, sid%; &49, 1, mid%; Lara5_vertices%; : REM Define Mesh Vertices
;   420 FOR i%=0 TO total_coords%-1
;   430   val%=vertices(i%)*factor
;   440   VDU val%;
;   450   REM T%=TIME
;   460   REM IF TIME-T%<1 GOTO 390
;   470 NEXT i%
    ld hl,Lara5_vertices
    ld bc,Lara5_vertex_indices-Lara5_vertices
    rst.lil $18

; ;   480 PRINT "Reading and sending vertex indices"
;     ld hl,str_set_mesh_vertex_indices
;     call printString
smvi:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   490 VDU 23,0, &A0, sid%; &49, 2, mid%; Lara5_indices%; : REM Set Mesh Vertex indices
    db 23,0,$A0
    dw sid
    db $49,2
    dw mid, Lara5_indices_n
@end:
;   500 FOR i%=0 TO Lara5_indices%-1
;   510   READ val%
;   520   VDU val%;
;   530   REM T%=TIME
;   540   REM IF TIME-T%<1 GOTO 470
;   550 NEXT i%
    ld hl,Lara5_vertex_indices
    ld bc,Lara5_uvs-Lara5_vertex_indices
    rst.lil $18

; ;   560 PRINT "Sending texture UV coordinates"
;     ld hl,str_set_texture_coordinates
;     call printString
stc:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   570 VDU 23,0, &A0, sid%; &49, 3, mid%; Lara5_uvs%;
    db 23,0,$A0
    dw sid
    db $49,3
    dw mid, Lara5_uvs_n
@end:
;   580 total_uvs%=Lara5_uvs%*2
;   590 FOR i%=0 TO total_uvs%-1
;   600   READ val
;   610   val%=INT(val*65535)
;   620   VDU val%;
;   630   REM T%=TIME
;   640   REM IF TIME-T%<1 GOTO 570
;   650 NEXT i%
    ld hl,Lara5_uvs
    ld bc,Lara5_uv_indices-Lara5_uvs
    rst.lil $18

; ;   660 PRINT "Sending Texture Coordinate indices"
;     ld hl,str_set_tex_coord_idxs
;     call printString
stci:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   670 VDU 23,0, &A0, sid%; &49, 4, mid%; Lara5_indices%; 
    db 23,0,$A0
    dw sid
    db $49,4
    dw mid, Lara5_indices_n
@end:
;   680 FOR i%=0 TO Lara5_indices%-1
;   690   READ val%
;   700   VDU val%;
;   710   REM T%=TIME
;   720   REM IF TIME-T%<1 GOTO 650
;   730 NEXT i%
    ld hl,Lara5_uv_indices
    ld bc,Lara5_texture-Lara5_uv_indices
    rst.lil $18

; ;   740 PRINT "Creating texture bitmap"
;     ld hl,str_create_texture_bitmap
;     call printString
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

; ;   760 PRINT "Sending texture pixel data"
;     ld hl,str_set_texture_pixel
;     call printString
stp:
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
;   770 VDU 23, 27, 1, Lara5_texture_width%; Lara5_texture_height%; 
    db 23,27,1
@texture_width: dw Lara5_texture_width
@texture_height: dw Lara5_texture_height
@end:
;   780 FOR i%=0 TO Lara5_texture_width%*Lara5_texture_height%*4-1
;   790   READ val%
;   800   VDU val% : REM 8-bit integers for pixel data
;   810   REM T%=TIME
;   820   REM IF TIME-T%<1 GOTO 750
;   830 NEXT i%
    ld hl,Lara5_texture
    ld bc,Lara5_texture_width*Lara5_texture_height*4
    rst.lil $18

; ;   840 PRINT "Create 3D object"
;     ld hl,str_create_object
;     call printString
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

; ;   860 PRINT "Scale object"
;     ld hl,str_scale_object
;     call printString
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

; ;   880 PRINT "Create target bitmap"
;     ld hl,str_create_target_bitmap
;     call printString
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
;   960 VDU 17,20+128 : REM set text background color to lighter azure
    db 17,7+128
;   970 VDU 18, 0, 20+128 : REM set gfx background color to lighter azure
    db 18,0,7+128
@end:

mainloop:
    ; ld hl,str_render_to_bitmap
    ; call printString
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

    call vdu_cls

    ; ld hl,str_display_output_bitmap
    ; call printString
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

animate:
;  1080 rotatex=rotatex+incx: IF rotatex>=pi2 THEN rotatex=rotatex-pi2
    ld hl,(rotatex)
    ld de,(incx)
    add hl,de
    ld (@rx),hl
    ld (rotatex),hl
    call printDec
;  1090 rotatey=rotatey+incy: IF rotatey>=pi2 THEN rotatey=rotatey-pi2
    ld hl,(rotatey)
    ld de,(incy)
    add hl,de
    ld (@ry),hl
    ld (rotatey),hl
    call printDec
;  1100 rotatez=rotatez+incz: IF rotatez>=pi2 THEN rotatez=rotatez-pi2
    ld hl,(rotatez)
    ld de,(incz)
    add hl,de
    ld (@rz),hl
    ld (rotatez),hl
    call printDec

    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @done
@beg:
;  1120 VDU 23, 0, &A0, sid%; &49, 13, oid%; rx; ry; rz; : REM Set Object XYZ Rotation Angles
        db 23, 0, $A0
        dw sid
        db $49, 13
        dw oid
@rx:    dw 0
@ry:    dw 0
@rz:    dw 0
@end:   db 0 ; padding
@done:

    call vdu_vblank
    call vdu_flip
    jp mainloop

    ret

incx: dl 0
incy: dl 91*5 ; 32767/360*foo
incz: dl 0

rotatex: dl 0
rotatey: dl 0
rotatez: dl 0

    include "pingo/src/asm/vdu.asm"
    include "pingo/src/asm/Lara5.asm"

; str_hello_world: db "Welcome to the Pingo 3D Demo!\r\n",0
; str_create_object: db "Creating 3D object.\r\n",0
; str_scale_object: db "Scaling object.\r\n",0
; str_create_target_bitmap: db "Creating target bitmap.\r\n",0
; str_set_texture_pixel: db "Setting texture pixel.\r\n",0
; str_create_texture_bitmap: db "Creating texture bitmap.\r\n",0
; str_zeroes: db "Sending some magic zeroes.\r\n",0
; str_set_tex_coord_idxs: db "Setting texture coordinate indices.\r\n",0
; str_set_texture_coordinates: db "Sending texture coordinates.\r\n",0
; str_set_mesh_vertex_indices: db "Sending vertex indices.\r\n",0
; str_send_vertices: db "Sending vertices.\r\n",0
; str_set_camera_x_rotation: db "Setting camera X rotation.\r\n",0
; str_set_camera_distance: db "Setting camera distance.\r\n",0
; str_create_control: db "Creating control structure.\r\n",0
; str_init_cmplt: db "Initialization complete.\r\n",0
; str_render_to_bitmap: db "Rendering to bitmap.\r\n",0
; str_display_output_bitmap: db "Displaying output bitmap.\r\n",0
; str_program_end: db "Program end.\r\n",0


; Print a zero-terminated string
; HL: Pointer to string
printString:
	PUSH	BC
	LD		BC,0
	LD 	 	A,0
	RST.LIL 18h
	POP		BC
	RET


; Prints the right justified decimal value in HL without leading zeroes
; HL : Value to print
printDec:
	LD	 DE, _printDecBuffer
	CALL Num2String
; BEGIN MY CODE
; replace leading zeroes with spaces
    LD	 HL, _printDecBuffer
    ld   B, 7 ; if HL was 0, we want to keep the final zero 
@loop:
    LD	 A, (HL)
    CP	 '0'
    JP	 NZ, @done
    LD   A, ' '
    LD	 (HL), A
    INC	 HL
    CALL vdu_cursor_forward
    DJNZ @loop
@done:
; END MY CODE
	; LD	 HL, _printDecBuffer
	CALL printString
; Print Newline sequence to VDP
	LD	A, '\r'
	RST.LIL 10h
	LD	A, '\n'
	RST.LIL 10h
	RET
_printDecBuffer: blkb 9,0 ; nine bytes full of zeroes

; This routine converts the value from HL into it's ASCII representation, 
; starting to memory location pointing by DE, in decimal form and with leading zeroes 
; so it will allways be 8 characters length
; HL : Value to convert to string
; DE : pointer to buffer, at least 8 byte + 0
Num2String:
	LD	 BC,-10000000
	CALL OneDigit
	LD	 BC,-1000000
	CALL OneDigit
	LD	 BC,-100000
	CALL OneDigit
	LD   BC,-10000
	CALL OneDigit
	LD   BC,-1000
	CALL OneDigit
	LD   BC,-100
	CALL OneDigit
	LD   C,-10
	CALL OneDigit
	LD   C,B
OneDigit:
	LD   A,'0'-1
DivideMe:
	INC  A
	ADD  HL,BC
	JR   C,DivideMe
	SBC  HL,BC
	LD   (DE),A
	INC  DE
	RET
