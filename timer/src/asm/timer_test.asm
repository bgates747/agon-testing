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


; Table 32. Timer Control Registers
; this constant is the base address of the timer control registers
; each timer takes three bytes:
;   0: control register
;   1: low byte of timer reset value
;   2: high byte of timer reset value
; note that the value is only 8-bits, so we use in0/out0 i/o calls,
; which correctly force the high and upper bytes of the address bus to zero
TMR_CTL:     equ 80h

; Timer Control Register Bit Definitions
PRT_IRQ_0:    equ %00000000 ; The timer does not reach its end-of-count value. 
                            ; This bit is reset to 0 every time the TMRx_CTL register is read.
PRT_IRQ_1:    equ %10000000 ; The timer reaches its end-of-count value. If IRQ_EN is set to 1, 
                            ; an interrupt signal is sent to the CPU. This bit remains 1 until 
                            ; the TMRx_CTL register is read.

IRQ_EN_0:     equ %00000000 ; Timer interrupt requests are disabled.
IRQ_EN_1:     equ %01000000 ; Timer interrupt requests are enabled.

PRT_MODE_0:   equ %00000000 ; The timer operates in SINGLE PASS mode. PRT_EN (bit 0) is reset to
                            ;  0, and counting stops when the end-of-count value is reached.
PRT_MODE_1:   equ %00010000 ; The timer operates in CONTINUOUS mode. The timer reload value is
                            ; written to the counter when the end-of-count value is reached.

; CLK_DIV is a 2-bit mask that sets the timer input source clock divider
CLK_DIV_256:  equ %00001100 ; 
CLK_DIV_64:   equ %00001000 ; 
CLK_DIV_16:   equ %00000100 ;
CLK_DIV_4:    equ %00000000 ;

RST_EN_0:     equ %00000000 ; The reload and restart function is disabled. 
RST_EN_1:     equ %00000010 ; The reload and restart function is enabled. 
                            ; When a 1 is written to this bit, the values in the reload registers
                            ;  are loaded into the downcounter when the timer restarts. The 
                            ; programmer must ensure that this bit is set to 1 each time 
                            ; SINGLE-PASS mode is used.

; disable/enable the programmable reload timer
PRT_EN_0:     equ %00000000 ;
PRT_EN_1:     equ %00000001 ;

; Table 37. Timer Input Source Select Register
; Each of the 4 timers are allocated two bits of the 8-bit register
; in little-endian order, with TMR0 using bits 0 and 1, TMR1 using bits 2 and 3, etc.
;   00: System clock / CLK_DIV
;   01: RTC / CLK_DIV
;   NOTE: these are the values given in the manual, but it may be a typo
;   10: GPIO port B pin 1.
;   11: GPIO port B pin 1.
TMR_ISS:   equ 92h ; register address

; Table 51. Real-Time Clock Control Register
RTC_CTRL: equ EDh ; register address

; alarm interrupt disable/enable
RTC_ALARM_0:    equ %00000000
RTC_ALARM_1:    equ %10000000

; interrupt on alarm disable/enable
RTC_INT_ENT_0:  equ %00000000
RTC_INT_ENT_1:  equ %01000000

RTC_BCD_EN_0:   equ %00000000   ; RTC count and alarm registers are binary
RTC_BCD_EN_1:   equ %00100000   ; RTC count and alarm registers are BCD

RTC_CLK_SEL_0:  equ %00000000   ; RTC clock source is crystal oscillator output (32768 Hz). 
                                ; On-chip 32768 Hz oscillator is enabled.
RTC_CLK_SEL_1:  equ %00010000   ; RTC clock source is power line frequency input as set by FREQ_SEL.
                                ; On-chip 32768 Hz oscillator is disabled.

RTC_FREQ_SEL_0: equ %00000000   ; 60 Hz power line frequency.
RTC_FREQ_SEL_1: equ %00001000   ; 50 Hz power line frequency.

RTC_SLP_WAKE_0: equ %00000000   ; RTC does not generate a sleep-mode recovery reset.
RTC_SLP_WAKE_1: equ %00000010   ; RTC generates a sleep-mode recovery reset.

RTC_UNLOCK_0:   equ %00000000   ; RTC count registers are locked to prevent Write access.
                                ; RTC counter is enabled.
RTC_UNLOCK_1:   equ %00000001   ; RTC count registers are unlocked to allow Write access. 
                                ; RTC counter is disabled.

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
    call timer_irq_init
    ld hl,0
    ld (irq_counter),hl
    ret

; ===============================================
; Main program
; -----------------------------------------------
main:
; wait for VBLANK
    call vdu_vblank

; set a MOS timer for lead in
    ld hl,120*2
    ld iy,timer_test
    call timer_set
@lead_in:
    call timer_get
    jp z,@set_main
    jp m,@set_main
    jp @lead_in

@set_main:
; set a MOS timer for main loop
    ld hl,120*10
    ld iy,timer_test
    call timer_set


; set PRT timer
    ; reset value
    ld hl, 16384 
    out0 ($84), l
	out0 ($85), h
; enable timer, with interrupt and CONTINUOUS mode, clock divider 4
    ld a,PRT_IRQ_0 | IRQ_EN_1 | PRT_MODE_1 | CLK_DIV_4 | RST_EN_1 | PRT_EN_1 ; 0x53
	out0 ($83), a

main_loop:
; wait for VBLANK
    ; call vdu_vblank

    call vdu_home_cursor

; check time remaining on MOS timer
    ld iy,timer_test        ; iy points to timer data buffer
    call timer_get          ; grab time remaining (past expiration) and status flags

; get irq_counter
    push af
    call printDec
    call printNewline
    ld hl,(irq_counter)
    call printDec
    call printNewline
    call get_prt
    call printDec
    pop af

; branch on the status of the MOS timer
    jp z,main_end ; time expired, so quit
    jp m,main_end ; time past expiration (negative), so quit

; quit if escape key pressed
    MOSCALL mos_getkbmap
; 113 Escape
    bit 0,(ix+14)
    jr z,main_loop

main_end:
; print final loop count
    call printNewline
    call printNewline
    ld iy,timer_test        ; iy points to timer data buffer
    call timer_get          ; grab time remaining (past expiration) and status flags
    call printDec
    call printNewline
    ld hl,(irq_counter)
    call printDec
    call printNewline
    call get_prt
    call printDec
    call printNewline
    ret

prt_last: dl 0
prt_curr: dl 0

get_prt:
    ld de,0
    ld hl,0
    in0 a,($84)
    ld (prt_curr),a
    in0 a,($85)
    ld (prt_curr+1),a
    ld hl,(prt_last)
    ld de,(prt_curr)
    ld (prt_last),hl
    xor a
    sbc hl,de
    ex de,hl
    ld hl,0
    sbc hl,de
    ret

; ===============================================
; PRT Timer Interrupt Handling
; https://github.com/tomm/agon-cpu-emulator/blob/main/sdcard/regression_suite/timerirq.asm
; -----------------------------------------------
timer_irq_init:
    ; set up interrupt vector table 2
	ld hl, 0
	ld a,($10c)
	ld l, a
	ld a,($10d)
	ld h, a

	; skip over CALL ($c3)
	inc hl
	; load address of jump into vector table 2 (in ram)
	ld hl,(hl)

	; write CALL timer_irq_handler to vector table 2
	ld a, $c3
	ld (hl), a
	inc hl
	ld de, timer_irq_handler
	ld (hl), de

    ret

timer_irq_handler:
	di
	push af
    push hl
	in0 a,($83)
	ld (got_irq),a
	ld hl,(irq_counter)
	inc hl
	ld (irq_counter),hl
    pop hl
	pop af
	ei
	reti.l

got_irq:
	.db 0
irq_counter:
	.dl 0

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