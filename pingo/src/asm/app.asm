    .assume adl=1   
    .org 0x040000    

    jp start       

    .align 64      
    .db "MOS"       
    .db 00h         
    .db 01h

	include "src/asm/mos_api.asm" ; wants to be first include b/c it has macros
	; include "src/asm/vdu_sound.asm" ; also has macros
    include "src/asm/main.asm"
	include "src/asm/vdu.asm"
    include "src/asm/vdu_pingo.asm"
    include "src/asm/functions.asm"
	include "src/asm/maths.asm"
	include "src/asm/timer.asm"
    include "src/asm/def3d_teapot.asm"
    include "src/asm/teapot_bas.asm"


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

str_hello_world: db "Welocome to the Pingo 3D Teapot Demo!\r\n",0

; files.asm must go here so that filedata doesn't stomp on program data
	include "src/asm/files.asm"