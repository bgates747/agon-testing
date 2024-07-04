mos_load:			    EQU	01h
mos_sysvars:		    EQU	08h
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
    pop iy 
    pop ix
    pop de
    pop bc
    pop af
    ld hl,0

    ret 

image_buffer: equ 256
image_width: equ 256
image_height: equ 184

; filetype: equ 0 ; rgba8
; image_size: equ image_width*image_height*4 ; rgba8
; image_filename: db "pingo/src/blender/earth640x320x16.rgba8",0

filetype: equ 1 ; rgba2
image_size: equ image_width*image_height ; rgba2
image_filename: db "pingo/src/blender/Lara.rgba2",0

main:
    ld a,8 ; 320x240x64 single-buffered
    call vdu_set_screen_mode
    xor a ; scaling off
    call vdu_set_scaling
    call cursor_off

; load image file to a buffer and make it a bitmap
    ld a,filetype
    ld bc,image_width
    ld de,image_height
    ld hl,image_buffer
    ld ix,image_size
    ld iy,image_filename
    call vdu_load_img
    ; call vdu_load_img_rgba2_to_8

; clear the screen
    call vdu_cls

; plot the bitmap
    ld hl,image_buffer
    call vdu_buff_select
    ld bc,0
    ld de,0
    call vdu_plot_bmp

    call waitKeypress

    xor a ; 640x480x16 single-buffered
    call vdu_set_screen_mode
    ld a,1 ; scaling on
    call vdu_set_scaling
    call cursor_on

    ret

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

; VDU 12: Clear text area (CLS)
vdu_cls:
    ld a,12
	rst.lil $10  
	ret

; load an rgba2222 image file to a working buffer and make it an rgba8888 bitmap in a target buffer
; inputs: bc,de image width,height ; hl = targetBufferId ; ix = file size ; iy = pointer to filename
vdu_load_img_rgba2_to_8:
    ld (@width),bc
    ld (@height),de
    ld (@bufferId),hl
    ld a,23
    ld (@bufferId+2),a
    xor a
    ld (@height+2),a
; load the rgba2 image to working buffer 65534
    ld hl,65534
	call vdu_load_buffer_from_file
; expand the rgba2 data into the target buffer and make it an rgba8 bitmap
    ld hl,(@bufferId)
    ld de,65534 ; working buffer id
    call vdu_rgba2_to_8
; convert the expanded to an rgba8888 bitmap
; VDU 23,27,&20,targetBufferID%;
    db 23,27,0x20 ; select bitmap
@bufferId: dw 0x0000 ; targetBufferId
; VDU 23,27,&21,width%;height%;0
    db 23,27,0x21 ; create bitmap from buffer
@width: dw 0x0000
@height: dw 0x0000
    db 0x00 ; rgba8888 format
@end:


; inputs: hl = targetBufferId, de = sourceBufferId
; prerequisites: rgba2 image data loaded into sourceBufferId
vdu_rgba2_to_8:
    ld (@targetBufferId),hl
    ld (@sourceBufferId),de
; clean up bytes that got stomped on by the ID loads
    ld a,0x48
    ld (@targetBufferId+2),a
    ld hl,@beg
    ld bc,@end-@beg
    rst.lil $18
    ret
@beg:
; VDU 23, 0, &A0, targetBufferId; &48, sourceBufferId;
    db 23,0,0xA0
@targetBufferId: dw 0x0000 ; targetBufferId
    db 0x48 ; expand bitmap
@sourceBufferId: dw 0x0000 ; sourceBufferId
@end: db 0x00 ; padding

; ; https://discord.com/channels/1158535358624039014/1158536711148675072/1257757461729771771
; ; ok, so the "expand bitmap" can be used, when coupled with a "reverse" - the expanded bitmap _doesn't_ come out "right" otherwise, cos of endian-ness
; ; the "expand bitmap" command is:
; ; VDU 23,0,&A0,targetBufferID%;&48,2,sourceBufferId%;0,&7F,&BF,&FF
; ; and then to reverse the byte order to fix endian-ness:
; ; VDU 23,0,&A0,targetBufferID%;24,4,4;
; ; finally you'd need to set that buffer to be an RGBA8888 format bitmap:
; ; VDU 23,27,&20,targetBufferID%;
; ; VDU 23,27,&21,width%;height%;0
; ; -------------------------------------------------------------------
; ; inputs: bc,de image width,height ; hl = targetBufferId
; ; prerequisites: rgba2 image data loaded into workingBufferId 65534
; vdu_rgba2_to_8:
; ; load the image dimensions and buffer id parameters
;     ld (@width),bc
;     ld (@height),de
;     ld (@bufferId0),hl
;     ld (@bufferId2),hl
;     ld (@bufferId1),hl
; ; clean up bytes that got stomped on by the ID loads
;     ld a,0x48
;     ld (@bufferId0+2),a
;     ld a,23
;     ld (@bufferId1+2),a
;     ld a,24
;     ld (@bufferId2+2),a
;     xor a
;     ld (@height+2),a
; ; send the vdu command strings
;     ld hl,@beg
;     ld bc,@end-@beg
;     rst.lil $18
;     ret
; @beg:
; ; Command 14: Consolidate blocks in a buffer
; ; VDU 23, 0, &A0, bufferId; 14
;     db 23,0,0xA0
;     dw 65534 ; workingBufferId
;     db 14 ; consolidate blocks
; ; the "expand bitmap" command is:
; ; VDU 23,0,&A0,targetBufferID%;&48,2,sourceBufferId%;0,&7F,&BF,&FF
;     db 23,0,0xA0
; @bufferId0: dw 0x0000 ; targetBufferId
;     db 0x48 ; given as decimal command 72 in the docs
;     db 2 ; options mask: %00000011 is the number of bits per pixel in the source bitmap
;     dw 65534 ; sourceBufferId
;     db 0x00,0x7F,0xBF,0xFF ; expanding to bytes by bit-shifting?
; ; reverse the byte order to fix endian-ness:
; ; Command 24: Reverse the order of data of blocks within a buffer
; ; VDU 23, 0, &A0, bufferId; 24, options, [valueSize;] [chunkSize;]
; ; VDU 23,0,&A0,targetBufferID%;24,4,4;
;     db 23,0,0xA0
; @bufferId2:    dw 0x0000 ; targetBufferId
;     db 24 ; reverse byte order
;     db 4 ; option: Reverse data of the value size within chunk of data of the specified size
;     dw 4 ; size (4 bytes)
; ; finally you'd need to set that buffer to be an RGBA8888 format bitmap:
; ; VDU 23,27,&20,targetBufferID%;
;     db 23,27,0x20 ; select bitmap
; @bufferId1: dw 0x0000 ; targetBufferId
; ; VDU 23,27,&21,width%;height%;0
;     db 23,27,0x21 ; create bitmap from buffer
; @width: dw 0x0000
; @height: dw 0x0000
;     db 0x00 ; rgba8888 format
; @end:

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
