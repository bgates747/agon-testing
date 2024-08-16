mos_load:			    EQU	01h
mos_sysvars:		    EQU	08h
mos_getkbmap:		    EQU	1Eh
sysvar_time:			EQU	00h	; 4: Clock timer in centiseconds (incremented by 2 every VBLANK)
sysvar_keyascii:		EQU	05h	; 1: ASCII keycode, or 0 if no key is pressed

	MACRO	MOSCALL	function
			LD	A, function
			RST.LIL	08h
	ENDMACRO 	

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

    include "pingo/src/asm/Lara.asm"

main:
    ld a,8+128 ; 320x240x64 double-buffered
    call vdu_set_screen_mode
    
    ; ld hl,str_hello_world
    ; call printString

;   145 sid%=100: mid%=1: oid%=1: bmid1%=101: bmid2%=102
sid: equ 100
mid: equ 1
oid: equ 1
bmid1: equ 256
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
cam_disty: equ 0 ; 64-16-8
cam_distz: equ -4*cam_f

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

;    20 Lara_vertices%=4
;    30 Lara_indices%=12
;    40 Lara_uvs%=10
; Lara_vertices: equ 4
; Lara_indices: equ 12
; Lara_uvs: equ 10
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
;   410 VDU 23,0, &A0, sid%; &49, 1, mid%; Lara_vertices%; : REM Define Mesh Vertices
    db 23,0,$A0
    dw sid
    db $49,1
    dw mid, Lara_vertices_n
@end:
;   410 VDU 23,0, &A0, sid%; &49, 1, mid%; Lara_vertices%; : REM Define Mesh Vertices
;   420 FOR i%=0 TO total_coords%-1
;   430   val%=vertices(i%)*factor
;   440   VDU val%;
;   450   REM T%=TIME
;   460   REM IF TIME-T%<1 GOTO 390
;   470 NEXT i%
    ld hl,Lara_vertices
    ld bc,Lara_vertex_indices-Lara_vertices
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
;   490 VDU 23,0, &A0, sid%; &49, 2, mid%; Lara_indices%; : REM Set Mesh Vertex indices
    db 23,0,$A0
    dw sid
    db $49,2
    dw mid, Lara_indices_n
@end:
;   500 FOR i%=0 TO Lara_indices%-1
;   510   READ val%
;   520   VDU val%;
;   530   REM T%=TIME
;   540   REM IF TIME-T%<1 GOTO 470
;   550 NEXT i%
    ld hl,Lara_vertex_indices
    ld bc,Lara_uvs-Lara_vertex_indices
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
;   570 VDU 23,0, &A0, sid%; &49, 3, mid%; Lara_uvs%;
    db 23,0,$A0
    dw sid
    db $49,3
    dw mid, Lara_uvs_n
@end:
;   580 total_uvs%=Lara_uvs%*2
;   590 FOR i%=0 TO total_uvs%-1
;   600   READ val
;   610   val%=INT(val*65535)
;   620   VDU val%;
;   630   REM T%=TIME
;   640   REM IF TIME-T%<1 GOTO 570
;   650 NEXT i%
    ld hl,Lara_uvs
    ld bc,Lara_uv_indices-Lara_uvs
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
;   670 VDU 23,0, &A0, sid%; &49, 4, mid%; Lara_indices%; 
    db 23,0,$A0
    dw sid
    db $49,4
    dw mid, Lara_indices_n
@end:
;   680 FOR i%=0 TO Lara_indices%-1
;   690   READ val%
;   700   VDU val%;
;   710   REM T%=TIME
;   720   REM IF TIME-T%<1 GOTO 650
;   730 NEXT i%
    ld hl,Lara_uv_indices
    ld bc,Lara_texture-Lara_uv_indices
    rst.lil $18

image_buffer: equ bmid1
image_width: equ Lara_texture_width
image_height: equ Lara_texture_height

filetype: equ 0 ; rgba8
image_size: equ image_width*image_height*4 ; rgba8
image_filename: equ Lara_texture

; filetype: equ 1 ; rgba2
; image_size: equ image_width*image_height ; rgba2
; image_filename: db "pingo/src/blender/Laracrop.rgba2",0

; load image file to a buffer and make it a bitmap
    ld a,filetype
    ld bc,image_width
    ld de,image_height
    ld hl,image_buffer
    ld ix,image_size
    ld iy,image_filename
    call vdu_load_img

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
    dw bmid1 ; bmid1+64000
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

; check for escape key and quit if pressed
	MOSCALL mos_getkbmap
; 113 Escape
    bit 0,(ix+14)
	jp z,mainloop
    xor a ; 640x480x16 single-buffered
    call vdu_set_screen_mode
    ld a,1 ; scaling on
    call vdu_set_scaling
    call cursor_on
    ret

incx: dl 0
incy: dl 91*5 ; 32767/360*foo
incz: dl 0

rotatex: dl 0
rotatey: dl 0
rotatez: dl 0

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

; https://github.com/envenomator/Agon/blob/master/ez80asm%20examples%20(annotated)/functions.s
; Print a zero-terminated string
; HL: Pointer to string
printString:
	PUSH	BC
	LD		BC,0
	LD 	 	A,0
	RST.LIL 18h
	POP		BC
	RET
; print a VDU sequence
; HL: Pointer to VDU sequence - <1 byte length> <data>
sendVDUsequence:
	PUSH	BC
	LD		BC, 0
	LD		C, (HL)
	RST.LIL	18h
	POP		BC
	RET
; Print Newline sequence to VDP
printNewLine:
	LD	A, '\r'
	RST.LIL 10h
	LD	A, '\n'
	RST.LIL 10h
	RET
; Print a 24-bit HEX number
; HLU: Number to print
printHex24:
	PUSH	HL
	LD		HL, 2
	ADD		HL, SP
	LD		A, (HL)
	POP		HL
	CALL	printHex8
; Print a 16-bit HEX number
; HL: Number to print
printHex16:
	LD		A,H
	CALL	printHex8
	LD		A,L
; Print an 8-bit HEX number
; A: Number to print
printHex8:
	LD		C,A
	RRA 
	RRA 
	RRA 
	RRA 
	CALL	@F
	LD		A,C
@@:
	AND		0Fh
	ADD		A,90h
	DAA
	ADC		A,40h
	DAA
	RST.LIL	10h
	RET

; Print a 0x HEX prefix
DisplayHexPrefix:
	LD	A, '0'
	RST.LIL 10h
	LD	A, 'x'
	RST.LIL 10h
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

; wait until user presses a key
; inputs: none
; outputs: none
; destroys: af,hl,ix
waitKeypress:
    ; ld hl,str_press_shift
    ; call printString
    MOSCALL mos_sysvars
    xor a ; zero out any prior keypresses
    ld (ix+sysvar_keyascii),a
@loop:
    ld a,(ix+sysvar_keyascii)
    and a
    ret nz
    jr @loop

cursor_on:
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd:
	db 23,1,1
@end:

cursor_off:	
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd:
	db 23,1,0
@end:

; VDU 9: Move cursor forward one character
vdu_cursor_forward:
    ld a,9
	rst.lil $10  
	ret


; VDU 12: Clear text area (CLS)
vdu_cls:
    ld a,12
	rst.lil $10  
	ret

vdu_flip:       
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 23,0,0xC3
@end:

vdu_vblank:		PUSH 	IX			; Wait for VBLANK interrupt
			MOSCALL	mos_sysvars		; Fetch pointer to system variables
			LD	A, (IX + sysvar_time + 0)
@wait:			CP 	A, (IX + sysvar_time + 0)
			JR	Z, @wait
			POP	IX
			RET

; load an image file to a buffer and make it a bitmap
; inputs: a = image type ; bc,de image width,height ; hl = bufferId ; ix = file size ; iy = pointer to filename
vdu_load_img:
; back up image type and dimension parameters
    push af
	push bc
	push de
; load the image
	call vdu_load_buffer_from_file
; now make it a bitmap
; Command 14: Consolidate blocks in a buffer
; VDU 23, 0, &A0, bufferId; 14
    ld hl,image_buffer
    ld (@bufferId),hl
    ld a,14
    ld (@bufferId+2),a
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    jp @end
@beg:
    db 23,0,0xA0
@bufferId: dw 0x0000
        db 14
@end:
    ld hl,image_buffer
    call vdu_buff_select
	pop de ; image height
	pop bc ; image width
	pop af ; image type
	jp vdu_bmp_create ; will return to caller from there

vdu_set_screen_mode:
	ld (@arg),a        
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 22 ; set screen mode
@arg: db 0  ; screen mode parameter
@end:

; VDU 23, 0, &C0, n: Turn logical screen scaling on and off *
; inputs: a is scaling mode, 1=on, 0=off
; note: default setting on boot is scaling ON
vdu_set_scaling:
	ld (@arg),a        
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 23,0,0xC0
@arg: db 0  ; scaling on/off
@end: 

; VDU 23, 27, &20, bufferId; : Select bitmap (using a buffer ID)
; inputs: hl=bufferId
vdu_buff_select:
	ld (@bufferId),hl
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd: db 23,27,0x20
@bufferId: dw 0x0000
@end: db 0x00 ; padding

; VDU 23, 27, &21, w; h; format: Create bitmap from selected buffer
; inputs: a=format; bc=width; de=height
; prerequisites: buffer selected by vdu_bmp_select or vdu_buff_select
; formats: https://agonconsole8.github.io/agon-docs/VDP---Bitmaps-API.html
; 0 	RGBA8888 (4-bytes per pixel)
; 1 	RGBA2222 (1-bytes per pixel)
; 2 	Mono/Mask (1-bit per pixel)
; 3 	Reserved for internal use by VDP (“native” format)
vdu_bmp_create:
    ld (@width),bc
    ld (@height),de
    ld (@fmt),a
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd:       db 23,27,0x21
@width:     dw 0x0000
@height:    dw 0x0000
@fmt:       db 0x00
@end:

; &E8-&EF 	232-239 	Bitmap plot §
plot_bmp: equ 0xE8
; 5 	Plot absolute in current foreground colour
dr_abs_fg: equ 5

; https://agonconsole8.github.io/agon-docs/VDP---PLOT-Commands.html
; &E8-&EF 	232-239 	Bitmap plot §
; VDU 25, mode, x; y;: PLOT command
; inputs: bc=x0, de=y0
; prerequisites: vdu_buff_select
vdu_plot_bmp:
    ld (@x0),bc
    ld (@y0),de
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd:   db 25
@mode:  db plot_bmp+dr_abs_fg ; 0xED
@x0: 	dw 0x0000
@y0: 	dw 0x0000
@end:   db 0x00 ; padding


; inputs: hl = bufferId, ix = file size ; iy = pointer to filename
vdu_load_buffer_from_file:
; load buffer ids
    ld (@id0),hl
    ld (@id1),hl
; clean up bytes that got stomped on by the ID loads
    ld a,2
    ld (@id0+2),a
    xor a
    ld (@id1+2),a
; load filesize from ix
    ld (@filesize),ix
    ld bc,(@filesize) ; for the mos_load call
; load the file from disk into ram
    push iy
	pop hl ; pointer to filename
	ld de,filedata
	ld a,mos_load
	RST.LIL 08h
; clear target buffer
    ld hl,@clear0
    ld bc,@clear1-@clear0
    rst.lil $18
    jp @clear1
@clear0: db 23,0,0xA0
@id0:	dw 0x0000 ; bufferId
		db 2 ; clear buffer
@clear1:
; load default chunk size of 256 bytes
    xor a
    ld (@chunksize),a
    ld a,1
    ld (@chunksize+1),a
; point hl at the start of the file data
    ld hl,filedata
    ld (@chunkpointer),hl
@loop:
    ld hl,(@filesize) ; get the remaining bytes
    ld de,256
    xor a ; clear carry
    sbc hl,de
    ld (@filesize),hl ; store remaining bytes
    jp z,@loadchunk ; jp means will return to caller from there
    jp m,@lastchunk ; ditto
    call @loadchunk ; load the next chunk and return here to loop again
    jp @loop ; loop back to load the next chunk
@lastchunk:
    ld de,256
    add hl,de
    ld a,l
    ld (@chunksize),a ; store the remaining bytes
    ld a,h
    ld (@chunksize+1),a
    ; fall through to loadchunk
@loadchunk:
    ld hl,@chunk0
    ld bc,@chunk1-@chunk0
    rst.lil $18
    jp @chunk1
@chunk0:
; Upload data :: VDU 23, 0 &A0, bufferId; 0, length; <buffer-data>
		db 23,0,0xA0
@id1:	dw 0x0000 ; bufferId
		db 0 ; load buffer
@chunksize:	dw 0x0000 ; length of data in bytes
@chunk1:
    ld hl,(@chunkpointer) ; get the file data pointer
    ld bc,0 ; make sure bcu is zero
    ld a,(@chunksize)
    ld c,a
    ld a,(@chunksize+1)
    ld b,a
    rst.lil $18
    ld hl,(@chunkpointer) ; get the file data pointer
    ld bc,256
    add hl,bc ; advance the file data pointer
    ld (@chunkpointer),hl ; store pointer to file data
    ld a,'.' ; print a progress breadcrumb
    rst.lil 10h
    ret
@filesize: dl 0 ; file size in bytes
@chunkpointer: dl 0 ; pointer to current chunk

filedata: ; no need to allocate space here if this is the final address label