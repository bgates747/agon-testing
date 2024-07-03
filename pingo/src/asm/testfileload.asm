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
image_buffer: equ 1024
image_width: equ 256
image_height: equ 184
image_size: equ image_width*image_height*4

main:
    ld a,8 ; 320x240x64 single-buffered
    call vdu_set_screen_mode
    xor a ; scaling off
    call vdu_set_scaling

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
    jp z,@lastchunk
    jp m,@lastchunk
    call @loadchunk ; load the next chunk
    jp @loop ; loop back to load the next chunk
@lastchunk:
    ex de,hl ; put remaining bytes in de
    ld hl,256
    sbc hl,de ; subtract remaining bytes from 256
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
    ld a,'.'
    rst.lil 10h
    ret
@filesize: dl 0 ; file size in bytes
@chunkpointer: dl 0 ; pointer to current chunk




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


; print the binary representation of the 8-bit value in a
; destroys a, hl, bc
printBin8:
    ld b,8      ; loop counter for 8 bits
    ld hl,@cmd  ; set hl to the low byte of the output string
                ; (which will be the high bit of the value in a)
@loop:
    rlca ; put the next highest bit into carry
    jr c,@one
    ld (hl),'0'
    jr @next_bit
@one:
    ld (hl),'1'
@next_bit:
    inc hl
    djnz @loop
; print it
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: ds 8 ; eight bytes for eight bits
@end:

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


; inputs: whatever is in the flags register
; outputs: binary representation of flags
;          with a header so we know which is what
; destroys: nothing
; preserves: everything
dumpFlags:
; first we curse zilog for not giving direct access to flags
    push af ; this is so we can send it back unharmed
    push af ; this is so we can pop it to hl
; store everything in scratch
    ld (uhl),hl
    ld (ubc),bc
    ld (ude),de
    ld (uix),ix
    ld (uiy),iy
; next we print the header 
    ld hl,@header
    call printString
    pop hl ; flags are now in l
    ld a,l ; flags are now in a
    call printBin8
	call printNewLine
; restore everything
    ld hl, (uhl)
    ld bc, (ubc)
    ld de, (ude)
    ld ix, (uix)
    ld iy, (uiy)
    pop af ; send her home the way she came
    ret
; Bit 7 (S): Sign flag
; Bit 6 (Z): Zero flag
; Bit 5 (5): Reserved (copy of bit 5 of the result)
; Bit 4 (H): Half Carry flag
; Bit 3 (3): Reserved (copy of bit 3 of the result)
; Bit 2 (PV): Parity/Overflow flag
; Bit 1 (N): Subtract flag
; Bit 0 (C): Carry flag
@header: db "SZxHxPNC\r\n",0 ; cr/lf and 0 terminator


; print registers to screen in hexidecimal format
; inputs: none
; outputs: values of every register printed to screen
;    values of each register in global scratch memory
; destroys: nothing
dumpRegistersHex:
; store everything in scratch
    ld (uhl),hl
    ld (ubc),bc
    ld (ude),de
    ld (uix),ix
    ld (uiy),iy
    push af ; fml
    pop hl  ; thanks, zilog
    ld (uaf),hl
    push af ; dammit

; home the cursor
    call vdu_home_cursor

; print each register
    ld hl,str_afu
    call printString
    ld hl,(uaf)
    call printHex24
    call printNewLine

    ld hl,str_hlu
    call printString
    ld hl,(uhl)
    call printHex24
    call printNewLine

    ld hl,str_bcu
    call printString
    ld hl,(ubc)
    call printHex24
    call printNewLine

    ld hl,str_deu
    call printString
    ld hl,(ude)
    call printHex24
    call printNewLine

    ld hl,str_ixu
    call printString
    ld hl,(uix)
    call printHex24
    call printNewLine

    ld hl,str_iyu
    call printString
    ld hl,(uiy)
    call printHex24
    call printNewLine

    call printNewLine
; restore everything
    ld hl, (uhl)
    ld bc, (ubc)
    ld de, (ude)
    ld ix, (uix)
    ld iy, (uiy)
    pop af
; all done
    ret

; global scratch memory for registers
uaf: dl 0
uhl: dl 0
ubc: dl 0
ude: dl 0
uix: dl 0
uiy: dl 0
usp: dl 0
upc: dl 0

str_afu: db "af=",0
str_hlu: db "hl=",0
str_bcu: db "bc=",0
str_deu: db "de=",0
str_ixu: db "ix=",0
str_iyu: db "iy=",0

; VDU 30: Home cursor
vdu_home_cursor:
    ld a,30
	rst.lil $10  
	ret

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

filedata: ; no need to allocate space here if this is the final address label
