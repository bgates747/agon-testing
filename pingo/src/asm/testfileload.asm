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
    pop iy 
    pop ix
    pop de
    pop bc
    pop af
    ld hl,0

    ret 

image_filename: db "pingo/src/blender/Lara.rgba8",0
image_buffer: equ 256
image_width: equ 256
image_height: equ 184
image_size: equ image_width*image_height*4

main:
    ld a,8 ; 320x240x64 single-buffered
    call vdu_set_screen_mode

; load image file to a buffer and make it a bitmap
    xor a ; rgba8
    ld bc,image_width
    ld de,image_height
    ld hl,image_buffer
    ld ix,image_size
    ld iy,image_filename
    call vdu_load_img

; plot the bitmap
    ld hl,image_buffer
    call vdu_buff_select
    ld bc,0
    ld de,0
    call vdu_plot_bmp
    
    ret

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

; This routine converts the value from HL into its ASCII representation, 
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


vdu_set_screen_mode:
	ld (@arg),a        
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 22 ; set screen mode
@arg: db 0  ; screen mode parameter
@end:


; VDU 9: Move cursor forward one character
vdu_cursor_forward:
    ld a,9
	rst.lil $10  
	ret



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
	pop de ; image height
	pop bc ; image width
	pop af ; image type
	jp vdu_bmp_create ; will return to caller from there

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
    ld bc,(ix) ; for the mos_load call
    ld ix,(ix+1) ; now ix is filesize / 256 and will be our main loop counter
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

; load default chunk size
    ld bc,256
    ld (@chunksize),bc
; point hl at the start of the file data
    ld hl,filedata

@loop:
    dec ix
    jp m,@lastchunk
    jp z,@lastchunk
    push hl ; store pointer to file data
    call @loadchunk ; load the next chunk
    jp @loop ; loop back to load the next chunk

@lastchunk:
    ld bc,0 ; make sure bcu is zero
    ld a,(ix) ; get the remaining bytes
    and a
    ret z ; no more to load so we're done
    ld c,a ; bc is number of final bytes to load
    ld (@chunksize),bc  
    push hl ; store pointer to file data
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
    pop hl ; get the file data pointer
    ld bc,(@chunksize)
    rst.lil $18
    add hl,bc ; advance the file data pointer
    ret

@filesize: dl 0 ; file size in bytes

filedata: ; no need to allocate space here if this is the final address label