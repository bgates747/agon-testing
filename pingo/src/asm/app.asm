    .assume adl=1   
    .org 0x040000    

    jp start       

    .align 64      
    .db "MOS"       
    .db 00h         
    .db 01h

	include "pingo/src/asm/mos_api.asm" ; wants to be first include b/c it has macros
	; include "pingo/src/asm/vdu_sound.asm" ; also has macros
	include "pingo/src/asm/vdu.asm"
    include "pingo/src/asm/vdu_pingo.asm"
    include "pingo/src/asm/functions.asm"
	include "pingo/src/asm/maths.asm"
	include "pingo/src/asm/timer.asm"
    ; include "pingo/src/asm/def3d_teapot.asm"
    include "pingo/src/asm/cube.asm"


start:              
    push af
    push bc
    push de
    push ix
    push iy

	call init ; Initialization code
    call main ; Call the main function

exit:

    pop iy 
    pop ix
    pop de
    pop bc
    pop af
    ld hl,0

    ret 

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

init:
; clear all buffers
    call vdu_clear_all_buffers

; ; set up the display
;     ld a,8;+128 ; 320x240x64 double-buffered
;     call vdu_set_screen_mode
;     xor a
;     call vdu_set_scaling
	
; enable additional audio channels
	; call vdu_enable_channels

; set the cursor off
	call cursor_off

; set text background color
	ld a,4 + 128
	call vdu_colour_text

; set text foreground color
	ld a,47 ; aaaaff lavenderish
	call vdu_colour_text

; set gfx bg color
	xor a ; plotting mode 0
	ld c,4 ; dark blue
	call vdu_gcol_bg
	; call vdu_cls

; set the cursor off again since we changed screen modes
	call cursor_off

; ; VDU 28, left, bottom, right, top: Set text viewport **
; ; MIND THE LITTLE-ENDIANESS
; ; inputs: c=left,b=bottom,e=right,d=top
; 	ld c,0 ; left
; 	ld d,20 ; top
; 	ld e,39 ; right
; 	ld b,29; bottom
; ;	call vdu_set_txt_viewport
	
	; call vdu_cls
	ld hl,str_hello_world
	call printString
	; call vdu_flip
    ; call waitReturn

    call cube_init

; initialization done
	ret
main:

main_loop:
; wait for the next vblank
    call vdu_vblank

; clear the screen
    ; call vdu_cls

; draw the cube
; 6800 VDU 23, 0, &A0, sid%; &49, 38, bmid2%+64000; : REM Render To Bitmap
; inputs: bc = bmid;
    ld hl,@bmpbeg
    ld bc,@bmpend-@bmpbeg
    rst.lil $18
    jp @bmpend
@bmpbeg:
    db 23, 0, $A0 ; Render To Bitmap
    dw sid
    db $49, 38
    dw bmid2+64000
@bmpend:
  
; 6810 VDU 23, 27, 3, 0; 0; : REM Display output bitmap
    ld hl,@bmpdispbeg
    ld bc,@bmpdispend-@bmpdispbeg
    rst.lil $18
    jp @bmpend
@bmpdispbeg:
    db 23, 27, 3 ; Display output bitmap
    dw 0, 0
@bmpdispend:

; flip the screen
    ; call vdu_flip

; check for escape key and quit if pressed
	MOSCALL mos_getkbmap
; 113 Escape
    bit 0,(ix+14)
	jr nz,main_end
@Escape:
	jr main_loop

main_end:
	; call do_outro

    call vdu_clear_all_buffers
	; call vdu_disable_channels

; restore screen to something normalish
	xor a
	call vdu_set_screen_mode
	call cursor_on
	ret


; files.asm must go here so that filedata doesn't stomp on program data
	include "pingo/src/asm/files.asm"