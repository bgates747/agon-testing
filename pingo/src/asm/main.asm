main:

main_loop:
; wait for the next vblank
    call vdu_vblank

; clear the screen
    ; call vdu_cls

; draw the teapot
; 6800 VDU 23, 0, &A0, sid%; &48, 38, bmid2%+64000; : REM Render To Bitmap
; inputs: bc = bmid;
    ld bc,bmid2+64000
    call vdu_3d_render_to_bitmap

; 6810 VDU 23, 27, 3, 50; 50; : REM Display output bitmap
    ld hl,@bmpdisp
    ld bc,@bmpend-@bmpdisp
    rst.lil $18
    jp @bmpend
@bmpdisp:
    db 23, 27, 3 ; Display output bitmap
    dw 50, 50
@bmpend:

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
