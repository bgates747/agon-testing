; 0x01: mos_load
; Load a file from SD card
; Parameters:
;     HL(U): Address of filename (zero terminated)
;     DE(U): Address at which to load
;     BC(U): Maximum allowed size (bytes)
; Returns:
;     A: File error, or 0 if OK
;     F: Carry reset if no room for file, otherwise set
mos_load:			EQU	01h

	JP _init

_header:
	.ALIGN 64
	.DB "MOS"
	.DB 00h
	.DB 01h

_init:
	PUSH	AF	
	PUSH	BC
	PUSH	DE
	PUSH	IX
	PUSH	IY

	ld hl,pgrm_file
	ld de,0xB7E000
	ld bc,0x002000 ; 8KiB, max allowable in on-board fast sram
	LD	A, mos_load
	RST.LIL	08h

    CALL 0xB7E000
	; CALL _main
	
	POP		IY
	POP		IX
	POP		DE
	POP		BC
	POP		AF
    ld      hl,0
	RET

pgrm_file: db "prgm.bin",0