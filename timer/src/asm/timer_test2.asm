; ===============================================
; Selected mos_api.inc stuff
; -----------------------------------------------
; MOS System Variables
; -----------------------------------------------
sysvar_time:		EQU	00h	; Starts at zero on power-up

; -----------------------------------------------
; MOS functions
; -----------------------------------------------
mos_sysvars:		EQU	08h
mos_getkbmap:		EQU	1Eh

; -----------------------------------------------
; MOS program exit codes
; -----------------------------------------------
EXIT_OK:				EQU  0;	"OK",

; -----------------------------------------------
; Macro for calling the MOS API
; -----------------------------------------------
; Parameters:
; - function: One of the function numbers listed above
;
	MACRO	MOSCALL	function
			LD	A, function
			RST.LIL	08h
	ENDMACRO 

; ===============================================
; MOS INITIALIATION 
; -----------------------------------------------
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

; ===============================================
; calls to actual program code
; -----------------------------------------------
	call	init 
	call 	main

; ===============================================
;  program exit and cleanup
; -----------------------------------------------
exit:
    call cursor_on

    pop iy 
    pop ix
    pop de
    pop bc
    pop af
    ld hl,EXIT_OK
    ret

; ===============================================
; Initialization
; -----------------------------------------------
init:
    call vdu_cls
    call cursor_off
    ld hl,60*10
    ld (timer_counter),hl
    call vdu_vblank
    ld hl,120*10
    ld iy,timer_test
    call timer_set
    ret

timer_counter: dl 0

; ===============================================
; Main program
; -----------------------------------------------
main:

main_loop:
    call vdu_home_cursor
    call vdu_vblank
    ld hl,(timer_counter)
    dec hl
    ld (timer_counter),hl
    ld de,0
    xor a
    sbc hl,de
    jp z, main_end
    call printDec
    call printNewline
    ld iy,timer_test
    call timer_get
    call printDec
    call printNewline
    jp main_loop

main_end:
    call printDec
    call printNewline
    ld iy,timer_test
    call timer_get
    call printDec
    call printNewline

    ret

; ===============================================
; Timer functions
; -----------------------------------------------
; set a countdown timer
; inputs: hl = time to set in 1/120ths of a second; iy = pointer to 3-byte buffer holding start time, iy+3 = pointer to 3-byte buffer holding timer set value
; returns: hl = current time 
timer_set:
    ld (iy+3),hl            ; set time remaining
    MOSCALL mos_sysvars     ; ix points to syvars table
    ld hl,(ix+sysvar_time)  ; get current time
    ld (iy+0),hl            ; set start time
    ret

; gets time remaining on a countdown timer
; inputs: iy = pointer to 3-byte buffer holding start time, iy+3 = pointer to 3-byte buffer holding timer set value
; returns: hl pos = time remaining in 1/120ths of a second, hl neg = time past expiration
;          sign flags: pos = time not expired, zero or neg = time expired
timer_get:
    MOSCALL mos_sysvars     ; ix points to syvars table
    ld de,(ix+sysvar_time)  ; get current time
    ld hl,(iy+0)            ; get start time
    xor a                   ; clear carry
    sbc hl,de               ; hl = time elapsed (will always be zero or negative)
    ld de,(iy+3)            ; get timer set value
    xor a                   ; clear carry
    adc hl,de               ; hl = time remaining 
                            ; (we do adc because add hl,rr doesn't set sign or zero flags)
    ret

timer_test: ds 6 ; example of a buffer to hold timer data

; ===============================================
; Helper functions
; -----------------------------------------------
; vdu.asm
; -----------------------------------------------

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

vdu_vblank:		PUSH 	IX			; Wait for VBLANK interrupt
			MOSCALL	mos_sysvars		; Fetch pointer to system variables
			LD	A, (IX + sysvar_time + 0)
@wait:			CP 	A, (IX + sysvar_time + 0)
			JR	Z, @wait
			POP	IX
			RET

; VDU 12: Clear text area (CLS)
vdu_cls:
    ld a,12
	rst.lil $10  
	ret

; VDU 30: Home cursor
vdu_home_cursor:
    ld a,30
	rst.lil $10  
	ret

; -----------------------------------------------
; functions.asm
; -----------------------------------------------
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
	call printNewline
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


; global scratch memory for registers
uaf: dl 0
uhl: dl 0
ubc: dl 0
ude: dl 0
uix: dl 0
uiy: dl 0
usp: dl 0
upc: dl 0

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

; print each register
    ; ld hl,str_afu
    ; call printString
    ; ld hl,(uaf)
    ; call printHex24
    ; call printNewline

    ld hl,str_hlu
    call printString
    ld hl,(uhl)
    call printHex24
    call printNewline

    ld hl,str_bcu
    call printString
    ld hl,(ubc)
    call printHex24
    call printNewline

    ; ld hl,str_deu
    ; call printString
    ; ld hl,(ude)
    ; call printHex24
    ; call printNewline

    ; ld hl,str_ixu
    ; call printString
    ; ld hl,(uix)
    ; call printHex24
    ; call printNewline

    ; ld hl,str_iyu
    ; call printString
    ; ld hl,(uiy)
    ; call printHex24
    ; call printNewline

; restore everything
    ld hl, (uhl)
    ld bc, (ubc)
    ld de, (ude)
    ld ix, (uix)
    ld iy, (uiy)
    pop af
; all done
    ret

str_afu: db "af=",0
str_hlu: db "hl=",0
str_bcu: db "bc=",0
str_deu: db "de=",0
str_ixu: db "ix=",0
str_iyu: db "iy=",0

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
printNewline:
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


; Prints the decimal value in HL without leading zeroes
; HL : Value to print
printDec:
	LD	 DE, _printDecBuffer
	CALL Num2String
	LD	 HL, _printDecBuffer
	CALL printString
	RET
_printDecBuffer: blkb 9,0 ; nine bytes full of zeroes

; This routine converts the value from HL into it's ASCII representation, 
; starting to memory location pointing by DE, in decimal form and with trailing zeroes 
; so it will allways be 5 characters length
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