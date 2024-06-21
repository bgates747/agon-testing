; On-chip 8KB high-speed SRAM
; This on-chip memory is mapped by Quark MOS firmware to upper-byte B7, 
; effectively mapping it from 0xB7.E000 to 0xB7.FFFF. It is currently 
; unused by Quark firmware, allowing full access to the user, provided 
; the program employs 24-bit ADL address mode. If required, this memory 
; can be remapped by the user program to a different upper-byte address; 
; it will be mapped to B7 again by Quark MOS at each boot-up.
    ; org 0xB7E000
; now these includes and any code below it will be loaded into the fast SRAM
; SPRITE TABLE NEEDS TO BE HERE SO THAT IT ALIGNS WITH table_base

; 
; ###########################################
; Included from: sprites.asm
; ###########################################
; 
; ###### SPRITE TABLE FIELD INDICES ######
table_bytes_per_record: equ 38 ; 38 bytes per sprite record
sprite_id:              equ 00 ; 1 bytes unique spriteId, zero-based
sprite_type:            equ 01 ; 1 bytes type of sprite as defined in enemies.inc
sprite_base_bufferId:   equ 02 ; 3 bytes bitmap bufferId
sprite_move_program:    equ 05 ; 3 bytes address of sprite's behavior subroutine
sprite_collisions:      equ 08 ; 1 bytes low/high nibble: collision details
sprite_dim_x:           equ 09 ; 1 bytes sprite width in pixels
sprite_dim_y:           equ 10 ; 1 bytes sprite height in pixels
sprite_x:               equ 11 ; 3 bytes 16.8 fractional x position in pixels
sprite_y:               equ 14 ; 3 bytes 16.8 fractional y position in pixels
sprite_xvel:            equ 17 ; 3 bytes x-component velocity, 16.8 fixed, pixels
sprite_yvel:            equ 20 ; 3 bytes y-component velocity, 16.8 fixed, pixels
sprite_vel:             equ 23 ; 3 bytes velocity px/frame (16.8 fixed)
sprite_heading:         equ 26 ; 3 bytes sprite movement direction deg256 16.8 fixed
sprite_orientation:     equ 29 ; 3 bytes orientation bits
sprite_animation:       equ 32 ; 1 bytes current animation index, zero-based
sprite_animation_timer: equ 33 ; 1 bytes when hits zero, draw next animation
sprite_move_timer:      equ 34 ; 1 bytes when zero, go to next move program, or step
sprite_move_step:       equ 35 ; 1 bytes stage in a move program sequence, varies
sprite_points:          equ 36 ; 1 bytes points awarded for killing this sprite type, BCD
sprite_shield_damage:   equ 37 ; 1 bytes shield points deducted for collision, binary

; ###### SPRITE TABLE VARIABLES ######
; On-chip 8KB high-speed SRAM from 0xB7.E000 to 0xB7.FFFF.
; sprite table high address
table_base: equ 0xB7E000  
; maximum number of sprites
table_max_records: equ 4 ; it can handle more but this is pushing it
table_total_bytes: equ table_max_records*table_bytes_per_record

; #### THIS IS THE SPACE ALLOCATED TO THE SPRITE TABLE ####
sprite_start_variables: ds table_total_bytes, 0 ; fill with zeroes
sprite_end_variables: ; in case we want to traverse the table in reverse

; pointer to top address of current record, initialized to table_base
table_pointer: dl table_base
; how many active sprites
table_active_sprites: db 0x00
; flag indicating collision with screen edge
; uses orientation codes to specify which edge(s)
sprite_screen_edge: db #00 
; next sprite id to use
sprite_next_id: db 0

; ######### COLLISION SPRITE PARAMETERS ##########
; integer coordinates are all that are needed for collision calculations
collision_x: db 0x00 
collision_y: db 0x00
collision_dim_x: db 0x00
collision_dim_y: db 0x00

; scratch variables
x: db 0x00 ; 8-bit signed integer
y: db 0x00 ; 8-bit signed integer
x0: dl 0x000000 ; 16.8 signed fixed place
y0: dl 0x000000 ; 16.8 signed fixed place
incx1: dl 0x000000 ; 16.8 signed fixed place
incy1: dl 0x000000 ; 16.8 signed fixed place
incx2: dl 0x000000 ; 16.8 signed fixed place
incy2: dl 0x000000 ; 16.8 signed fixed place

; sprite_heading: dl 0x000000 ; signed fixed 16.8 
radius: dl 0x000000 ; signed fixed 16.8 (but should always be positive)
sin_sprite_heading: dl 0x000000 ; signed fixed 16.8
cos_sprite_heading: dl 0x000000 ; signed fixed 16.8

; gets the next available sprite id
; inputs; none
; returns: if new sprite available, a = sprite id, 
;           ix pointing to new sprite vars, carry set
;      otherwise, a = 0, carry flag reset, ix pointing to highest sprite vars
; destroys: a,b,hl,ix
; affects: bumps table_active_sprites by one
table_get_next_id:
    ld ix,table_base
    ld de,table_bytes_per_record
    ld b,table_max_records
@loop:
    ld a,(ix+sprite_type)
    and a
    jr z,@found
    add ix,de
    djnz @loop
@notfound:
    xor a ; a = 0 and reset carry flag indicating that we didn't find a free sprite
    ret
@found:
; bump number of active sprites
    ld hl,table_active_sprites
    inc (hl)
; return sprite id
    ld a,table_max_records
    sub b
    ld (sprite_next_id),a
    scf ; sets carry flag indicating we found a free sprite
    ret ; done

; deactivate the sprite with the given id
; inputs: a = sprite id
; outputs: nothing
; destroys: a,ix,de
; affects: decrements table_active_sprites by one
table_deactivate_sprite:
    push af ; save sprite id bc we need it later
    call vdu_sprite_select
    call vdu_sprite_hide
    pop af ; restore sprite id
    ld de,0 ; clear deu
    ld d,a
    ld e,table_bytes_per_record
    mlt de
    ld ix,table_base
    add ix,de
    xor a
    ld (ix+sprite_type),a
    ld ix,table_active_sprites
    dec (ix)
    ret
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 
; API includes

; 
; ###########################################
; Included from: ../agon_api/asm/mos_api.inc
; ###########################################
; 
; https://github.com/envenomator/Agon/blob/master/ez80asm%20examples%20(annotated)/mos_api.inc
; Title:	AGON MOS - API for user projects
; Author:	Dean Belfield
;			Adapted for agon-ez80asm by Jeroen Venema
;			Added MOS error codes for return in HL
; Created:	03/08/2022
; Last Updated:	10/08/2023
;
; Modinfo:
; 05/08/2022:	Added mos_feof
; 09/08/2022:	Added system variables: cursorX, cursorY
; 18/08/2022:	Added system variables: scrchar, scrpixel, audioChannel, audioSuccess, vpd_pflags
; 05/09/2022:	Added mos_ren, vdp_pflag_mode
; 24/09/2022:	Added mos_getError, mos_mkdir
; 13/10/2022:	Added mos_oscli
; 23/02/2023:	Added more sysvars, fixed typo in sysvar_audioSuccess, offsets for sysvar_scrCols, sysvar_scrRows
; 04/03/2023:	Added sysvar_scrpixelIndex
; 08/03/2023:	Renamed sysvar_keycode to sysvar_keyascii, added sysvar_vkeycode
; 15/03/2023:	Added mos_copy, mos_getrtc, mos_setrtc, rtc, vdp_pflag_rtc
; 21/03/2023:	Added mos_setintvector, sysvars for keyboard status, vdu codes for vdp
; 22/03/2023:	The VDP commands are now indexed from 0x80
; 29/03/2023:	Added mos_uopen, mos_uclose, mos_ugetc, mos_uputc
; 13/04/2023:	Added FatFS file structures (FFOBJID, FIL, DIR, FILINFO)
; 15/04/2023:	Added mos_getfil, mos_fread, mos_fwrite and mos_flseek
; 19/05/2023:	Added sysvar_scrMode
; 05/06/2023:	Added sysvar_rtcEnable
; 03/08/2023:	Added mos_setkbvector
; 10/08/2023:	Added mos_getkbmap

; VDP control (VDU 23, 0, n)
;
vdp_gp:				EQU 80h
vdp_keycode:		EQU 81h
vdp_cursor:			EQU	82h
vdp_scrchar:		EQU	83h
vdp_scrpixel:		EQU	84h
vdp_audio:			EQU	85h
vdp_mode:			EQU	86h
vdp_rtc:			EQU	87h
vdp_keystate:		EQU	88h
vdp_logicalcoords:	EQU	C0h
vdp_terminalmode:	EQU	FFh

; MOS high level functions
;
mos_getkey:			EQU	00h
mos_load:			EQU	01h
mos_save:			EQU	02h
mos_cd:				EQU	03h
mos_dir:			EQU	04h
mos_del:			EQU	05h
mos_ren:			EQU	06h
mos_mkdir:			EQU	07h
mos_sysvars:		EQU	08h
mos_editline:		EQU	09h
mos_fopen:			EQU	0Ah
mos_fclose:			EQU	0Bh
mos_fgetc:			EQU	0Ch
mos_fputc:			EQU	0Dh
mos_feof:			EQU	0Eh
mos_getError:		EQU	0Fh
mos_oscli:			EQU	10h
mos_copy:			EQU	11h
mos_getrtc:			EQU	12h
mos_setrtc:			EQU	13h
mos_setintvector:	EQU	14h
mos_uopen:			EQU	15h
mos_uclose:			EQU	16h
mos_ugetc:			EQU	17h
mos_uputc:			EQU	18h
mos_getfil:			EQU	19h
mos_fread:			EQU	1Ah
mos_fwrite:			EQU	1Bh
mos_flseek:			EQU	1Ch
mos_setkbvector:	EQU	1Dh
mos_getkbmap:		EQU	1Eh

; MOS program exit codes
;
EXIT_OK:				EQU  0;	"OK",
EXIT_ERROR_SD_ACCESS:	EQU	 1;	"Error accessing SD card",
EXIT_ERROR_ASSERTION:	EQU  2;	"Assertion failed",
EXIT_SD_CARDFAILURE:	EQU  3;	"SD card failure",
EXIT_FILENOTFOUND:		EQU  4;	"Could not find file",
EXIT_PATHNOTFOUND:		EQU  5;	"Could not find path",
EXIT_INVALIDPATHNAME:	EQU  6;	"Invalid path name",
EXIT_ACCESSDENIED_FULL:	EQU  7;	"Access denied or directory full",
EXIT_ACCESSDENIED:		EQU  8;	"Access denied",
EXIT_INVALIDOBJECT:		EQU  9;	"Invalid file/directory object",
EXIT_SD_WRITEPROTECTED:	EQU 10;	"SD card is write protected",
EXIT_INVALIDDRIVENUMBER:EQU 11;	"Logical drive number is invalid",
EXIT_NOVOLUMEWORKAREA:	EQU 12;	"Volume has no work area",
EXIT_NOVALIDFATVOLUME:	EQU 13;	"No valid FAT volume",
EXIT_ERRORMKFS:			EQU 14;	"Error occurred during mkfs",
EXIT_VOLUMETIMEOUT:		EQU 15;	"Volume timeout",
EXIT_VOLUMELOCKED:		EQU 16;	"Volume locked",
EXIT_LFNALLOCATION:		EQU 17;	"LFN working buffer could not be allocated",
EXIT_MAXOPENFILES:		EQU 18;	"Too many open files",
EXIT_INVALIDPARAMETER:	EQU 19;	"Invalid parameter",
EXIT_INVALIDCOMMAND:	EQU 20;	"Invalid command",
EXIT_INVALIDEXECUTABLE:	EQU 21;	"Invalid executable",
; FatFS file access functions
;
ffs_fopen:			EQU	80h
ffs_fclose:			EQU	81h
ffs_fread:			EQU	82h
ffs_fwrite:			EQU	83h
ffs_flseek:			EQU	84h
ffs_ftruncate:		EQU	85h
ffs_fsync:			EQU	86h
ffs_fforward:		EQU	87h
ffs_fexpand:		EQU	88h
ffs_fgets:			EQU	89h
ffs_fputc:			EQU	8Ah
ffs_fputs:			EQU	8Bh
ffs_fprintf:		EQU	8Ch
ffs_ftell:			EQU	8Dh
ffs_feof:			EQU	8Eh
ffs_fsize:			EQU	8Fh
ffs_ferror:			EQU	90h

; FatFS directory access functions
;
ffs_dopen:			EQU	91h
ffs_dclose:			EQU	92h
ffs_dread:			EQU	93h
ffs_dfindfirst:		EQU	94h
ffs_dfindnext:		EQU	95h

; FatFS file and directory management functions
;
ffs_stat:			EQU	96h
ffs_unlink:			EQU	97h
ffs_rename:			EQU	98h
ffs_chmod:			EQU	99h
ffs_utime:			EQU	9Ah
ffs_mkdir:			EQU	9Bh
ffs_chdir:			EQU	9Ch
ffs_chdrive:		EQU	9Dh
ffs_getcwd:			EQU	9Eh

; FatFS volume management and system configuration functions
;
ffs_mount:			EQU	9Fh
ffs_mkfs:			EQU	A0h
ffs_fdisk:			EQU	A1h
ffs_getfree:		EQU	A2h
ffs_getlabel:		EQU	A3h
ffs_setlabel:		EQU	A4h
ffs_setcp:			EQU	A5h
	
; File access modes
;
fa_read:			EQU	01h
fa_write:			EQU	02h
fa_open_existing:	EQU	00h
fa_create_new:		EQU	04h
fa_create_always:	EQU	08h
fa_open_always:		EQU	10h
fa_open_append:		EQU	30h
	
; System variable indexes for api_sysvars
; Index into _sysvars in globals.asm
;
sysvar_time:			EQU	00h	; 4: Clock timer in centiseconds (incremented by 2 every VBLANK)
sysvar_vpd_pflags:		EQU	04h	; 1: Flags to indicate completion of VDP commands
sysvar_keyascii:		EQU	05h	; 1: ASCII keycode, or 0 if no key is pressed
sysvar_keymods:			EQU	06h	; 1: Keycode modifiers
sysvar_cursorX:			EQU	07h	; 1: Cursor X position
sysvar_cursorY:			EQU	08h	; 1: Cursor Y position
sysvar_scrchar:			EQU	09h	; 1: Character read from screen
sysvar_scrpixel:		EQU	0Ah	; 3: Pixel data read from screen (R,B,G)
sysvar_audioChannel:	EQU	0Dh	; 1: Audio channel 
sysvar_audioSuccess:	EQU	0Eh	; 1: Audio channel note queued (0 = no, 1 = yes)
sysvar_scrWidth:		EQU	0Fh	; 2: Screen width in pixels
sysvar_scrHeight:		EQU	11h	; 2: Screen height in pixels
sysvar_scrCols:			EQU	13h	; 1: Screen columns in characters
sysvar_scrRows:			EQU	14h	; 1: Screen rows in characters
sysvar_scrColours:		EQU	15h	; 1: Number of colours displayed
sysvar_scrpixelIndex:	EQU	16h	; 1: Index of pixel data read from screen
sysvar_vkeycode:		EQU	17h	; 1: Virtual key code from FabGL
sysvar_vkeydown:		EQU	18h	; 1: Virtual key state from FabGL (0=up, 1=down)
sysvar_vkeycount:		EQU	19h	; 1: Incremented every time a key packet is received
sysvar_rtc:				EQU	1Ah	; 6: Real time clock data
sysvar_spare:			EQU	20h	; 2: Spare, previously used by rtc
sysvar_keydelay:		EQU	22h	; 2: Keyboard repeat delay
sysvar_keyrate:			EQU	24h	; 2: Keyboard repeat reat
sysvar_keyled:			EQU	26h	; 1: Keyboard LED status
sysvar_scrMode:			EQU	27h	; 1: Screen mode
sysvar_rtcEnable:		EQU	28h	; 1: RTC enable flag (0: disabled, 1: use ESP32 RTC)
	
; Flags for the VPD protocol
;
vdp_pflag_cursor:		EQU	00000001b
vdp_pflag_scrchar:		EQU	00000010b
vdp_pflag_point:		EQU	00000100b
vdp_pflag_audio:		EQU	00001000b
vdp_pflag_mode:			EQU	00010000b
vdp_pflag_rtc:			EQU	00100000b

;
; FatFS structures
; These mirror the structures contained in src_fatfs/ff.h in the MOS project
;
; Object ID and allocation information (FFOBJID)
;
; Indexes into FFOBJID structure
ffobjid_fs:			EQU	0	; 3: Pointer to the hosting volume of this object
ffobjid_id:			EQU	3	; 2: Hosting volume mount ID
ffobjid_attr:		EQU	5	; 1: Object attribute
ffobjid_stat:		EQU	6	; 1: Object chain status (b1-0: =0:not contiguous, =2:contiguous, =3:fragmented in this session, b2:sub-directory stretched)
ffobjid_sclust:		EQU	7	; 4: Object data start cluster (0:no cluster or root directory)
ffobjid_objsize:	EQU	11	; 4: Object size (valid when sclust != 0)
;
; File object structure (FIL)
;
; Indexes into FIL structure
fil_obj:		EQU 0	; 15: Object identifier
fil_flag:		EQU	15 	;  1: File status flags
fil_err:		EQU	16	;  1: Abort flag (error code)
fil_fptr:		EQU	17	;  4: File read/write pointer (Zeroed on file open)
fil_clust:		EQU	21	;  4: Current cluster of fpter (invalid when fptr is 0)
fil_sect:		EQU	25	;  4: Sector number appearing in buf[] (0:invalid)
fil_dir_sect:	EQU	29	;  4: Sector number containing the directory entry
fil_dir_ptr:	EQU	33	;  3: Pointer to the directory entry in the win[]
;
; Directory object structure (DIR)
; Indexes into DIR structure
dir_obj:		EQU  0	; 15: Object identifier
dir_dptr:		EQU	15	;  4: Current read/write offset
dir_clust:		EQU	19	;  4: Current cluster
dir_sect:		EQU	23	;  4: Current sector (0:Read operation has terminated)
dir_dir:		EQU	27	;  3: Pointer to the directory item in the win[]
dir_fn:			EQU	30	; 12: SFN (in/out) {body[8],ext[3],status[1]}
dir_blk_ofs:	EQU	42	;  4: Offset of current entry block being processed (0xFFFFFFFF:Invalid)
;
; File information structure (FILINFO)
;
; Indexes into FILINFO structure
filinfo_fsize:		EQU 0	;   4: File size
filinfo_fdate:		EQU	4	;   2: Modified date
filinfo_ftime:		EQU	6	;   2: Modified time
filinfo_fattrib:	EQU	8	;   1: File attribute
filinfo_altname:	EQU	9	;  13: Alternative file name
filinfo_fname:		EQU	22	; 256: Primary file name
;
; Macro for calling the API
; Parameters:
; - function: One of the function numbers listed above
;
	MACRO	MOSCALL	function
			LD	A, function
			RST.LIL	08h
	ENDMACRO 	
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 

; 
; ###########################################
; Included from: ../agon_api/asm/functions.inc
; ###########################################
; 
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

; Print a 0x HEX prefix
DisplayHexPrefix:
	LD	A, '0'
	RST.LIL 10h
	LD	A, 'x'
	RST.LIL 10h
	RET

; Prints the decimal value in HL without leading zeroes
; HL : Value to print
printDec:
	LD	 DE, _printDecBuffer
	CALL Num2String
	LD	 HL, _printDecBuffer
	CALL printString
	RET
_printDecBuffer:
	DS 9
; This routine converts the value from HL into it's ASCII representation, 
; starting to memory location pointing by DE, in decimal form and with trailing zeroes 
; so it will allways be 5 characters length
; HL : Value to convert to string
; DE : pointer to buffer, at least 8 byte + 0
Num2String:
	PUSH DE
	CALL Num2String_worker
	LD	 A, 0
	LD	 (DE), A	; terminate string
	POP  DE
	PUSH DE
@findfirstzero:
	LD	 A, (DE)
	CP	 '0'
	JR	 NZ, @done
	INC  DE
	JR	 @findfirstzero
@done:
	OR	 A	; end-of-string reached / was the value 0?
	JR	 NZ, @removezeroes
	DEC  DE
@removezeroes:
	POP	 HL	; start of string, DE == start of first number
@copydigit:
	LD	A, (DE)
	LD	(HL), A
	OR  A
	RET	Z
	INC	HL
	INC DE
	JR	@copydigit

Num2String_worker:
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


; #### new functions added by Brandon R. Gates ####

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
    ; call vdu_home_cursor

; print each register
    ld hl,@str_afu
    call printString
    ld hl,(uaf)
    call printHex24
    call printNewline

    ld hl,@str_hlu
    call printString
    ld hl,(uhl)
    call printHex24
    call printNewline

    ld hl,@str_bcu
    call printString
    ld hl,(ubc)
    call printHex24
    call printNewline

    ld hl,@str_deu
    call printString
    ld hl,(ude)
    call printHex24
    call printNewline

    ld hl,@str_ixu
    call printString
    ld hl,(uix)
    call printHex24
    call printNewline

    ld hl,@str_iyu
    call printString
    ld hl,(uiy)
    call printHex24
    call printNewline

    ; call vsync

    call printNewline
; restore everything
    ld hl, (uhl)
    ld bc, (ubc)
    ld de, (ude)
    ld ix, (uix)
    ld iy, (uiy)
    pop af
; all done
    ret

@str_afu: db "af=",0
@str_hlu: db "hl=",0
@str_bcu: db "bc=",0
@str_deu: db "de=",0
@str_ixu: db "ix=",0
@str_iyu: db "iy=",0

; print udeuhl to screen in hexidecimal format
; inputs: none
; outputs: concatenated hexidecimal udeuhl 
; destroys: nothing
dumpUDEUHLHex:
; store everything in scratch
    ld (uhl),hl
    ld (ubc),bc
    ld (ude),de
    ld (uix),ix
    ld (uiy),iy
    push af

; print each register

    ld hl,@str_udeuhl
    call printString
    ld hl,(ude)
    call printHex24
	ld a,'.'	; print a dot to separate the values
	rst.lil 10h
    ld hl,(uhl)
    call printHex24
    call printNewline

; restore everything
    ld hl, (uhl)
    ld bc, (ubc)
    ld de, (ude)
    ld ix, (uix)
    ld iy, (uiy)
    pop af
; all done
    ret

@str_udeuhl: db "ude.uhl=",0

; ; global scratch memory for registers
; uaf: dl 0
; uhl: dl 0
; ubc: dl 0
; ude: dl 0
; uix: dl 0
; uiy: dl 0
; usp: dl 0
; upc: dl 0

; inputs: whatever is in the flags register
; outputs: binary representation of flags
;          with a header so we know which is what
; destroys: hl
; preserves: af
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

; set all the bits in the flag register
; more of an academic exercise than anything useful
; inputs; none
; outputs; a=0,f=255
; destroys: flags, hl
; preserves: a, because why not
setAllFlags:
    ld hl,255
    ld h,a ; four cycles to preserve a is cheap
    push hl
    pop af
    ret

; reset all the bits in the flag register
; unlike its inverse counterpart, this may actually be useful
; inputs; none
; outputs; a=0,f=0
; destroys: flags, hl
; preserves: a, because why not
resetAllFlags:
    ld hl,0
    ld h,a ; four cycles to preserve a is cheap
    push hl
    pop af
    ret

; ------------------
; delay routine
; Author: Richard Turrnidge
; https://github.com/richardturnnidge/lessons/blob/main/slowdown.asm
; routine waits a fixed time, then returns
; arrive with A =  the delay byte. One bit to be set only.
; eg. ld A, 00000100b

multiPurposeDelay:                      
    push bc                 
    ld b, a 
    ld a,$08
    RST.LIL	08h                 ; get IX pointer to sysvars               

waitLoop:

    ld a, (ix + 0)              ; ix+0h is lowest byte of clock timer

                                ;   we check if bit set is same as last time we checked.
                                ;   bit 0 - don't use
                                ;   bit 1 - changes 64 times per second
                                ;   bit 2 - changes 32 times per second
                                ;   bit 3 - changes 16 times per second

                                ;   bit 4 - changes 8 times per second
                                ;   bit 5 - changes 4 times per second
                                ;   bit 6 - changes 2 times per second
                                ;   bit 7 - changes 1 times per second
    and b 
    ld c,a 
    ld a, (oldTimeStamp)
    cp c                        ; is A same as last value?
    jr z, waitLoop              ; loop here if it is
    ld a, c 
    ld (oldTimeStamp), a        ; set new value

    pop bc
    ret

oldTimeStamp:   .db 00h
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 

; 
; ###########################################
; Included from: ../agon_api/asm/vdu.inc
; ###########################################
; 
; The following is a high-level list of the VDU sequences that are supported:
; VDU 0: Null (no operation)
; VDU 1: Send next character to “printer” (if “printer” is enabled) §§
; VDU 2: Enable “printer” §§
; VDU 3: Disable “printer” §§
; VDU 4: Write text at text cursor
; VDU 5: Write text at graphics cursor
; VDU 6: Enable screen (opposite of VDU 21) §§
; VDU 7: Make a short beep (BEL)
; VDU 8: Move cursor back one character
; VDU 9: Move cursor forward one character
; VDU 10: Move cursor down one line
; VDU 11: Move cursor up one line
; VDU 12: Clear text area (CLS)
; VDU 13: Carriage return
; VDU 14: Page mode On *
; VDU 15: Page mode Off *
; VDU 16: Clear graphics area (CLG)
; VDU 17, colour: Define text colour (COLOUR)
; VDU 18, mode, colour: Define graphics colour (GCOL mode, colour)
; VDU 19, l, p, r, g, b: Define logical colour (COLOUR l, p / COLOUR l, r, g, b)
; VDU 20: Reset palette and text/graphics colours and drawing modes §§
; VDU 21: Disable screen (turns of VDU command processing, except for VDU 1 and VDU 6) §§
; VDU 22, n: Select screen mode (MODE n)
; VDU 23, n: Re-program display character / System Commands
; VDU 24, left; bottom; right; top;: Set graphics viewport **
; VDU 25, mode, x; y;: PLOT command
; VDU 26: Reset graphics and text viewports **
; VDU 27, char: Output character to screen §
; VDU 28, left, bottom, right, top: Set text viewport **
; VDU 29, x; y;: Set graphics origin
; VDU 30: Home cursor
; VDU 31, x, y: Move text cursor to x, y text position (TAB(x, y))
; VDU 127: Backspace

; VDU 0: Null (no operation)
;     On encountering a VDU 0 command, the VDP will do nothing. 
;     This may be useful for padding out a VDU command sequence, 
;     or for inserting a placeholder for a command that will be added later.
; inputs: none
; outputs: an empty byte somewhere in VDU
; destroys: a
vdu_null:
    xor a
	rst.lil $10
	ret

; VDU 1: Send next character to “printer” (if “printer” is enabled) §§
;     Ensures that the next character received by the VDP is sent through to 
;     the “printer”, and not to the screen. This is useful for sending control 
;     codes to the “printer”, or for sending data to the “printer” that is not 
;     intended to be displayed on the screen. It allows characters that would 
;     not otherwise normally be sent through to the “printer” to be sent.
;     If the “printer” has not been enabled then this command will just discard 
;     the next byte sent to the VDP.
; inputs: a is the ascii code of the character to send
; prerequisites: "printer" must first be activated with VDU 2 (see below)
; outputs: a character on the serial terminal connected to the USB port
;           and the same character on the screen at the current text cursor location
; QUESTION: does it also advance the text cursor?
; destroys: hl, bc
vdu_char_to_printer:
	ld (@arg),a        
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 1
@arg: db 0 
@end:

; VDU 2: Enable “printer” §§
;     Enables the “printer”.
;     In the context of the Agon platform, the “printer” is a serial 
;     terminal that is connected to the VDP’s USB port. Typically 
;     this port is used for power, but it can also be used to send and 
;     receive data to and from the VDP.
;     When the “printer” is enabled, the VDP will send characters it receives 
;     to the “printer” as well as to the screen. It will additionally send 
;     through control codes 8-13. To send other control codes to the “printer”, 
;     use the VDU 1 command.
;     The VDP will not send through other control codes to the printer, 
;     and will will not send through data it receives as part of other commands.
vdu_enable_printer:
    ld a,2
	rst.lil $10  
	ret

; VDU 3: Disable “printer” §§
; inputs: none
; outputs: a USB port bereft of communication with the VDP
; destroys: a
vdu_disable_printer:
    ld a,3
	rst.lil $10  
	ret

; VDU 4: Write text at text cursor
;     This causes text to be written at the current text cursor position. 
;     This is the default mode for text display.
;     Text is written using the current text foreground and background colours.
; inputs: a is the character to write to the screen
; prerequisites: the text cursor at the intended position on screen
; outputs: prints the character and moves text cursor right one position
; destroys: a, hl, bc
vdu_char_to_text_cursor:
	ld (@arg),a        
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 4
@arg: db 0 
@end:

; VDU 5: Write text at graphics cursor
;     This causes text to be written at the current graphics cursor position.
;     Using this, characters may be positioned at any graphics coordinate within 
;     the graphics viewport. This is useful for positioning text over graphics, 
;     or for positioning text at a specific location on the screen.
;     Characters are plotted using the current graphics foreground colour, 
;     using the current graphics foreground plotting mode (see VDU 18).
;     The character background is transparent, and will not overwrite any 
;     graphics that are already present at the character’s location. 
;     The exception to this is VDU 27, the “delete” character, which backspaces 
;     and deletes as per its usual behaviour, but will erase using the current 
;     graphics background colour.
; inputs: a is the character to write to the screen
; prerequisites: the graphics cursor at the intended position on screen
; outputs: see the name of the function
; destroys: a, hl, bc
vdu_char_to_gfx_cursor:
	ld (@arg),a        
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 5
@arg: db 0 
@end:

; VDU 6: Enable screen (opposite of VDU 21) §§
;     This enables the screen, and re-enables VDU command processing, 
;     reversing the effect of VDU 21.
; inputs: none
; outputs: a functioning screen and VDU
; destroys: a
vdu_enable_screen:
    ld a,6
	rst.lil $10  
	ret

; PASSES
; VDU 7: Make a short beep (BEL)
;     Plays a short beep sound on audio channel 0. If the audio channel 
;     is already in use, or has been disabled, then this command will have no effect.
; inputs: none
; outputs: an unpleasant but thankfully short-lived audio tone
; destroys: a
vdu_beep:
    ld a,7
	rst.lil $10  
	ret

; VDU 8: Move cursor back one character
;     Moves the text cursor one character in the negative “X” direction. 
;     By default, when at the start of a line it will move to the end of 
;     the previous line (as defined by the current text viewport). 
;     If the cursor is also at the top of the screen then the viewport will scroll down. 
;     The cursor remains constrained to the current text viewport.
;     When in VDU 5 mode and the graphics cursor is active, the viewport will not scroll. 
;     The cursor is just moved left by one character width.
;     Further behaviour of the cursor can be controlled using the VDU 23,16 command.
;     It should be noted that as of Console8 VDP 2.5.0, the cursor system does not 
;     support adjusting the direction of the cursor’s X axis, so this command 
;     will move the cursor to the left. This is likely to change in the future.
vdu_cursor_back:
    ld a,8
	rst.lil $10  
	ret

; VDU 9: Move cursor forward one character
vdu_cursor_forward:
    ld a,9
	rst.lil $10  
	ret

; VDU 10: Move cursor down one line
vdu_cursor_down:
    ld a,10
	rst.lil $10  
	ret

; VDU 11: Move cursor up one line
vdu_cursor_up:
    ld a,11
	rst.lil $10  
	ret

; VDU 12: Clear text area (CLS)
vdu_cls:
    ld a,12
	rst.lil $10  
	ret

; VDU 13: Carriage return
vdu_cr:
    ld a,13
	rst.lil $10  
	ret

; VDU 14: Page mode On *
vdu_page_on:
    ld a,14
	rst.lil $10  
	ret

; VDU 15: Page mode Off *
vdu_page_off:
    ld a,15
	rst.lil $10  
	ret

; VDU 16: Clear graphics area (CLG)
vdu_clg:
    ld a,16
	rst.lil $10  
	ret

; VDU 17, colour: Define text colour (COLOUR)
vdu_colour_text:
	ld (@arg),a        
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 17
@arg: db 0 
@end:

; VDU 18, mode, colour: Set graphics colour (GCOL mode, colour)
; inputs: a is the plotting mode, c is the colour
; outputs: a VDU set to put pixels on the screen with the selected mode/colour
vdu_gcol_fg:
; This command will set both the current graphics colour, 
; and the current graphics plotting mode.
; As with VDU 17 the colour number will set the foreground colour 
; if it is in the range 0-127, or the background colour if it is 
; in the range 128-255, and will be interpreted in the same manner.
; Support for different plotting modes on Agon is currently very limited. 
; The only fully supported mode is mode 0, which is the default mode. 
; This mode will plot the given colour at the given graphics coordinate, 
; and will overwrite any existing graphics at that coordinate. There is 
; very limited support for mode 4, which will invert the colour of any 
; existing graphics at the given coordinate, but this is not fully supported 
; and may not work as expected.
; Support for other plotting modes, matching those provided by Acorn’s 
; original VDU system, may be added in the future.
; This command is identical to the BASIC GCOL keyword.
	ld (@mode),a
    ld a,c
    ld (@col),a   
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 18
@mode: db 0
@col: db 0 
@end:

vdu_gcol_bg:
	ld (@mode),a
    ld a,c
    add a,128 
    ld (@col),a   
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd:  db 18
@mode: db 0
@col:  db 0 
@end:

; VDU 19, l, p, r, g, b: Define logical colour (COLOUR l, p / COLOUR l, r, g, b)
;     This command sets the colour palette, by mapping a logical colour 
;     to a physical colour. This is useful for defining custom colours, 
;     or for redefining the default colours.
;     If the physical colour number is given as 255 then the colour will 
;     be defined using the red, green, and blue values given. If the physical 
;     colour number is given as any other value then the colour will be defined 
;     using the colour palette entry given by that number, up to colour number 63.
;     If the physical colour is not 255 then the red, green, and blue values 
;     must still be provided, but will be ignored.
;     The values for red, green and blue must be given in the range 0-255. 
;     You should note that the physical Agon hardware only supports 64 colours, 
;     so the actual colour displayed may not be exactly the same as the colour 
;     requested. The nearest colour will be chosen.
;     This command is equivalent to the BASIC COLOUR keyword.
; inputs: a=physcial colour, b=logical colour, chl=r,g,b
vdu_def_log_colour:
	ld (@physical),a
    ld b,a
    ld (@logical),a
    ld a,c
    ld (@red),a
    ld a,h
    ld (@green),a
    ld a,l
    ld (@blue),a
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 19
@logical: db 0 
@physical: db 0
@red: db 0
@green: db 0
@blue: db 0
@end:

; VDU 20: Reset palette and text/graphics colours and drawing modes §§
vdu_reset_gfx:
    ld a,20
	rst.lil $10  
	ret

; VDU 21: Disable screen (turns off VDU command processing, 
; except for VDU 1 and VDU 6) §§
vdu_disable_screen:
    ld a,21
	rst.lil $10  
	ret

; VDU 22, n: Select screen mode (MODE n)
; Inputs: a, screen mode (8-bit unsigned integer), in the following list:
; https://agonconsole8.github.io/agon-docs/VDP---Screen-Modes.html
; Screen modes
; Modes over 128 are double-buffered
; From Version 1.04 or greater
; Mode 	Horz 	Vert 	Cols 	Refresh
; 0 	640 	480 	16 	    60hz
; * 1 	640 	480 	4 	    60hz
; 2 	640 	480 	2 	    60hz
; 3 	640 	240 	64 	    60hz
; 4 	640 	240 	16 	    60hz
; 5 	640 	240 	4 	    60hz
; 6 	640 	240 	2 	    60hz
; ** 7 	n/a 	n/a 	16 	    60hz
; 8 	320 	240 	64 	    60hz
; 9 	320 	240 	16 	    60hz
; 10 	320 	240 	4 	    60hz
; 11 	320 	240 	2 	    60hz
; 12 	320 	200 	64 	    70hz
; 13 	320 	200 	16 	    70hz
; 14 	320 	200 	4 	    70hz
; 15 	320 	200 	2 	    70hz
; 16 	800 	600 	4 	    60hz
; 17 	800 	600 	2 	    60hz
; 18 	1024 	768 	2 	    60hz
; 129 	640 	480 	4 	    60hz
; 130 	640 	480 	2 	    60hz
; 132 	640 	240 	16 	    60hz
; 133 	640 	240 	4 	    60hz
; 134 	640 	240 	2 	    60hz
; 136 	320 	240 	64 	    60hz
; 137 	320 	240 	16 	    60hz
; 138 	320 	240 	4 	    60hz
; 139 	320 	240 	2 	    60hz
; 140 	320 	200 	64 	    70hz
; 141 	320 	200 	16 	    70hz
; 142 	320 	200 	4 	    70hz
; 143 	320 	200 	2 	    70hz
; * Mode 1 is the “default” mode, and is the mode that the system will use on startup. 
; It is also the mode that the system will fall back to use if it was not possible to 
; change to the requested mode.
; ** Mode 7 is the “Teletext” mode, and essentially works in a very similar manner to 
; the BBC Micro’s Teletext mode, which was also mode 7.
vdu_set_screen_mode:
	ld (@arg),a        
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 22 ; set screen mode
@arg: db 0  ; screen mode parameter
@end:

; VDU 23, n: Re-program display character / System Commands
; inputs: a, ascii code; hl, pointer to bitmask data
vdu_define_character:
	ld (@ascii),a
	ld de,@data
	ld b,8 ; loop counter for 8 bytes of data
@loop:
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	djnz @loop
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd:   db 23 
@ascii: db 0 
@data:  ds 8
@end: 

; VDU 24, left; bottom; right; top;: Set graphics viewport 
; NOTE: the order of the y-coordinate parameters are inverted
; 	because we have turned off logical screen scaling
; inputs: bc=x0,de=y0,ix=x1,iy=y1
; outputs; nothing
; destroys: a might make it out alive
vdu_set_gfx_viewport:
    ld (@x0),bc
    ld (@y1),iy
	ld (@x1),ix
	ld (@y0),de
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd:   db 24 ; set graphics viewport command
@x0: 	dw 0x0000 ; set by bc
@y1: 	dw 0x0000 ; set by iy
@x1: 	dw 0x0000 ; set by ix
@y0: 	dw 0x0000 ; set by de
@end:   db 0x00	  ; padding

; VDU 25, mode, x; y;: PLOT command
; Implemented in vdu_plot.inc

; VDU 26: Reset graphics and text viewports **
vdu_reset_txt_gfx_view:
    ld a,26
	rst.lil $10  
	ret

; PASSES
; VDU 27, char: Output character to screen §
; inputs: a is the ascii code of the character to draw
vdu_draw_char:
	ld (@arg),a        
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 27 
@arg: db 0  ; ascii code of character to draw
@end:

; VDU 28, left, bottom, right, top: Set text viewport **
; MIND THE LITTLE-ENDIANESS
; inputs: c=left,b=bottom,e=right,d=top
; outputs; nothing
; destroys: a might make it out alive
vdu_set_txt_viewport:
    ld (@lb),bc
	ld (@rt),de
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd:   db 28 ; set text viewport command
@lb: 	dw 0x0000 ; set by bc
@rt: 	dw 0x0000 ; set by de
@end:   db 0x00	  ; padding

; PASSES
; VDU 29, x; y;: Set graphics origin
; inputs: bc,de x,y coordinates
vdu_set_gfx_origin:
    ld (@x0),bc
    ld (@y0),de
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd:	db 29
@x0: 	dw 0 
@y0: 	dw 0
@end: 	db 0 ; padding

; PASSES
; VDU 30: Home cursor
vdu_home_cursor:
    ld a,30
	rst.lil $10  
	ret

; PASSES
; VDU 31, x, y: Move text cursor to x, y text position (TAB(x, y))
; inputs: c=x, b=y 8-bit unsigned integers
vdu_move_cursor:
    ld (@x0),bc
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: 	db 31
@x0:	db 0
@y0: 	db 0
@end: 	db 0 ; padding


; VDU 127: Backspace
vdu_bksp:
    ld a,127
	rst.lil $10  
	ret

; activate a bitmap in preparation to draw it
; inputs: a holding the bitmap index 
vdu_bmp_select:
	ld (@bmp),a
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd: db 23,27,0 
@bmp: db 0 
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

; Draw a bitmap on the screen
; inputs: bc, x-coordinate; de, y-coordinate
; prerequisite: bitmap index set by e.g. vdu_bmp_select
vdu_bmp_draw:
    ld (@x0),bc
    ld (@y0),de
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd: db 23,27,3
@x0:  dw 0x0000
@y0:  dw 0x0000
@end: db 0x00 ; padding

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

; VDU 23, 0, &C3: Swap the screen buffer and/or wait for VSYNC **
; 	Swap the screen buffer (double-buffered modes only) or wait for VSYNC 
; 	(all modes).

; 	This command will swap the screen buffer, if the current screen mode 
; 	is double-buffered, doing so at the next VSYNC. If the current screen 
; 	mode is not double-buffered then this command will wait for the next 
; 	VSYNC signal before returning. This can be used to synchronise the 
; 	screen with the vertical refresh rate of the monitor.

; 	Waiting for VSYNC can be useful for ensuring smooth graphical animation, 
; 	as it will prevent tearing of the screen.
; inputs: none
; outputs: none
; destroys: hl, bc
vdu_flip:       
	ld hl,@cmd         
	ld bc,@end-@cmd    
	rst.lil $18         
	ret
@cmd: db 23,0,0xC3
@end:

; Command 64: Compress a buffer
; VDU 23, 0, &A0, targetBufferId; 64, sourceBufferId;
; This command will compress the contents of a buffer, replacing the target buffer with the compressed data. Unless the target buffer is the same as the source, the source buffer will be left unchanged.


; Command 65: Decompress a buffer
; VDU 23, 0, &A0, targetBufferId; 65, sourceBufferId;
; This command will decompress the contents of a buffer, replacing the target buffer with the decompressed data. Unless the target buffer is the same as the source, the source buffer will be left unchanged.
; inputs: hl=sourceBufferId, de=targetBufferId
vdu_decompress_buffer:
	ld (@targetBufferId),de
	ld (@sourceBufferId),hl
	ld a,65
	ld (@cmd1),a ; restore the part of command that got stomped on
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd: 	db 23,0,0xA0
@targetBufferId: dw 0x0000
@cmd1:	db 65
@sourceBufferId: dw 0x0000
@end: 	db 0x00 ; padding

; #### from vdp.inc ####

; https://github.com/breakintoprogram/agon-docs/wiki/VDP
; VDU 23, 7: Scrolling
;     VDU 23, 7, extent, direction, speed: Scroll the screen
; inputs: a, extent; l, direction; h; speed
vdu_scroll_down:
	ld (@extent),a
	ld (@dir),hl ; implicitly populates @speed
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18     ;; Sending command to VDP
	ret
@cmd:       db 23,7
@extent:    db 0x00 ; 0 current text window, 1 entire screen, 2 curr gfx viewport
@dir:       db 0x00 ; 0 right, 1 left, 2 down, 3 up
@speed:     db 0x00 ; pixels
@end:		db 0x00 ; padding

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

; #### from vdu_bmp.inc ####
; =========================================================================
; Bitmaps
; -------------------------------------------------------------------------
; VDU 23, 27, 0, n: Select bitmap n
; VDU 23, 27, &20, bufferId;: Select bitmap using a 16-bit buffer ID *
; VDU 23, 27, 1, w; h; b1, b2 ... bn: Load colour bitmap data into current bitmap

; VDU 23, 27, 1, n, 0, 0;: Capture screen data into bitmap n *
; VDU 23, 27, &21, bitmapId; 0; : same, but to 16-bit buffer ID *
; Any PLOT, or VDU 25, style command will push the graphics cursor position - 
; typically "move" style plot commands are used to define the rectangle.
; To be clear, this command should be performed after two "move" style PLOT commands.
; inputs: hl; target bufferId
; all the following are in 16.8 fixed point format
;   ub.c; top-left x coordinate
;   ud.e; top-left y coordinate
;   ui.x; width
;   ui.y; height
vdu_buff_screen_capture168:
        ld (@y0-1),de
        ld (@x0-1),bc
        ld a,0x44 ; plot_pt+mv_abs
        ld (@x0-1),a

        ld (@x1),ix
        ld (@y1),iy
        ld a,23
        ld (@y1+2),a

        ld (@bufId),hl
        xor a
        ld (@bufId+2),a

        ld hl,@begin
        ld bc,@end-@begin
        rst.lil $18
        ret
@begin:
; absolute move gfx cursor to top-left screen coordinate
; VDU 25, mode, x; y;: PLOT command
        db 25,0x44 ; plot_pt+mv_abs
@x0: 	dw 64
@y0: 	dw 64
; relative move gfx cursor to bottom-right screen coordinate
; VDU 25, mode, x; y;: PLOT command
        db 25,0x40 ; plot_pt+mv_rel
@x1: 	dw 15
@y1: 	dw 15
; now the main event
; VDU 23, 27, &21, bitmapId; 0;
        db 23,27,0x21
@bufId: dw 0x2000,0x0000
@end: ; no padding required

vdu_buff_screen_capture_full:
        ld hl,@begin
        ld bc,@end-@begin
        rst.lil $18
        ret
@begin:
; absolute move gfx cursor to top-left screen coordinate
; VDU 25, mode, x; y;: PLOT command
        db 25,0x44 ; plot_pt+mv_abs
@x0: 	dw 0
@y0: 	dw 0
; relative move gfx cursor to bottom-right screen coordinate
; VDU 25, mode, x; y;: PLOT command
        db 25,0x40 ; plot_pt+mv_rel
@x1: 	dw 319
@y1: 	dw 239
; now the main event
; VDU 23, 27, &21, bitmapId; 0;
        db 23,27,0x21
@bufId: dw 0x2000,0x0000
@end: ; no padding required

vdu_buff_screen_paste_full:
        ld hl,@begin
        ld bc,@end-@begin
        rst.lil $18
        ret
; VDU 23, 27, &20, bufferId; : Select bitmap (using a buffer ID)
@begin:    db 23,27,0x20
@bufferId: dw 0x2000
; VDU 25, mode, x; y;: PLOT command
           db 25,0xED ; plot_bmp+dr_abs_fg
           dw 0x0000,0x0000
@end: ; no padding required

vdu_buff_screen_capture_tiles:
        ld hl,@begin
        ld bc,@end-@begin
        rst.lil $18
        ret
@begin:
; absolute move gfx cursor to top-left screen coordinate
; VDU 25, mode, x; y;: PLOT command
        db 25,0x44 ; plot_pt+mv_abs
@x0: 	dw 0
@y0: 	dw 0
; relative move gfx cursor to bottom-right screen coordinate
; VDU 25, mode, x; y;: PLOT command
        db 25,0x40 ; plot_pt+mv_rel
@x1: 	dw 319-64
@y1: 	dw 239
; now the main event
; VDU 23, 27, &21, bitmapId; 0;
        db 23,27,0x21
@bufId: dw 0x2000,0x0000
@end: ; no padding required

vdu_buff_screen_paste_tiles:
        ld hl,@begin
        ld bc,@end-@begin
        rst.lil $18
        ret
; VDU 23, 27, &20, bufferId; : Select bitmap (using a buffer ID)
@begin:    db 23,27,0x20
@bufferId: dw 0x2000
; VDU 25, mode, x; y;: PLOT command
           db 25,0xED ; plot_bmp+dr_abs_fg
           dw 0x0000,0x0001
@end: ; no padding required

; VDU 23, 27, 2, w; h; col1; col2;: Create a solid colour rectangular bitmap
; VDU 23, 27, 3, x; y;: Draw current bitmap on screen at pixel position x, y
; VDU 23, 27, &21, w; h; format: Create bitmap from selected buffer *
; Value	Meaning
; 0	RGBA8888 (4-bytes per pixel)
; 1	RGBA2222 (1-bytes per pixel)
; 2	Mono/Mask (1-bit per pixel)
; 3	Reserved for internal use by VDP ("native" format)VDP. 
;     They have some significant limitations, and are not intended for general use.

; =========================================================================
; Sprites
; -------------------------------------------------------------------------
; VDU 23, 27, 4, n: Select sprite n
; VDU 23, 27, 5: Clear frames in current sprite
; VDU 23, 27, 6, n: Add bitmap n as a frame to current sprite (where bitmap's buffer ID is 64000+n)
; VDU 23, 27, &26, n;: Add bitmap n as a frame to current sprite using a 16-bit buffer ID
; VDU 23, 27, 7, n: Activate n sprites
; VDU 23, 27, 8: Select next frame of current sprite
; VDU 23, 27, 9: Select previous frame of current sprite
; VDU 23, 27, 10, n: Select the nth frame of current sprite
; VDU 23, 27, 11: Show current sprite
; VDU 23, 27, 12: Hide current sprite
; VDU 23, 27, 13, x; y;: Move current sprite to pixel position x, y
; VDU 23, 27, 14, x; y;: Move current sprite by x, y pixels
; VDU 23, 27, 15: Update the sprites in the GPU
; VDU 23, 27, 16: Reset bitmaps and sprites and clear all data
; VDU 23, 27, 17: Reset sprites (only) and clear all data
; VDU 23, 27, 18, n: Set the current sprite GCOL paint mode to n **

; =========================================================================
; Mouse cursor
; -------------------------------------------------------------------------
; VDU 23, 27, &40, hotX, hotY: Setup a mouse cursor with a hot spot at hotX, hotY

; #### from vdu_plot.inc ####
; https://agonconsole8.github.io/agon-docs/VDP---PLOT-Commands.html
; PLOT code 	(Decimal) 	Effect
; &00-&07 	0-7 	Solid line, includes both ends
plot_sl_both: equ 0x00

; &08-&0F 	8-15 	Solid line, final point omitted
plot_sl_first: equ 0x08

; &10-&17 	16-23 	Not supported (Dot-dash line, includes both ends, pattern restarted)
; &18-&1F 	24-31 	Not supported (Dot-dash line, first point omitted, pattern restarted)

; &20-&27 	32-39 	Solid line, first point omitted
plot_sl_last: equ 0x20

; &28-&2F 	40-47 	Solid line, both points omitted
plot_sl_none: equ 0x28

; &30-&37 	48-55 	Not supported (Dot-dash line, first point omitted, pattern continued)
; &38-&3F 	56-63 	Not supported (Dot-dash line, both points omitted, pattern continued)

; &40-&47 	64-71 	Point plot
plot_pt: equ 0x40

; &48-&4F 	72-79 	Line fill left and right to non-background §§
plot_lf_lr_non_bg: equ 0x48

; &50-&57 	80-87 	Triangle fill
plot_tf: equ 0x50

; &58-&5F 	88-95 	Line fill right to background §§
plot_lf_r_bg: equ 0x58

; &60-&67 	96-103 	Rectangle fill
plot_rf: equ 0x60

; &68-&6F 	104-111 	Line fill left and right to foreground §§
plot_lf_lr_fg: equ 0x60

; &70-&77 	112-119 	Parallelogram fill
plot_pf: equ 0x70

; &78-&7F 	120-127 	Line fill right to non-foreground §§
plot_lf_r_non_fg: equ 0x78

; &80-&87 	128-135 	Not supported (Flood until non-background)
; &88-&8F 	136-143 	Not supported (Flood until foreground)

; &90-&97 	144-151 	Circle outline
plot_co: equ 0x90

; &98-&9F 	152-159 	Circle fill
plot_cf: equ 0x98

; &A0-&A7 	160-167 	Not supported (Circular arc)
; &A8-&AF 	168-175 	Not supported (Circular segment)
; &B0-&B7 	176-183 	Not supported (Circular sector)

; &B8-&BF 	184-191 	Rectangle copy/move
plot_rcm: equ 0xB8

; &C0-&C7 	192-199 	Not supported (Ellipse outline)
; &C8-&CF 	200-207 	Not supported (Ellipse fill)
; &D0-&D7 	208-215 	Not defined
; &D8-&DF 	216-223 	Not defined
; &E0-&E7 	224-231 	Not defined

; &E8-&EF 	232-239 	Bitmap plot §
plot_bmp: equ 0xE8

; &F0-&F7 	240-247 	Not defined
; &F8-&FF 	248-255 	Not defined

; § Support added in Agon Console8 VDP 2.1.0 §§ Support added in 
; Agon Console8 VDP 2.2.0

; Within each group of eight plot codes, the effects are as follows:
; Plot code 	Effect
; 0 	Move relative
mv_rel: equ 0

; 1 	Plot relative in current foreground colour
dr_rel_fg: equ 1

; 2 	Not supported (Plot relative in logical inverse colour)
; 3 	Plot relative in current background colour
dr_rel_bg: equ 3

; 4 	Move absolute
mv_abs: equ 4

; 5 	Plot absolute in current foreground colour
dr_abs_fg: equ 5

; 6 	Not supported (Plot absolute in logical inverse colour)
; 7 	Plot absolute in current background colour
dr_abs_bg: equ 7

; Codes 0-3 use the position data provided as part of the command 
; as a relative position, adding the position given to the current 
; graphical cursor position. Codes 4-7 use the position data provided 
; as part of the command as an absolute position, setting the current 
; graphical cursor position to the position given.

; Codes 2 and 6 on Acorn systems plot using a logical inverse of the 
; current pixel colour. These operations cannot currently be supported 
; by the graphics system the Agon VDP uses, so these codes are not 
; supported. Support for these codes may be added in a future version 
; of the VDP firmware.

; 16 colour palette constants
c_black: equ 0
c_red_dk: equ 1
c_green_dk: equ 2
c_yellow_dk: equ 3
c_blue_dk: equ 4
c_magenta_dk: equ 5
c_cyan_dk: equ 6
c_grey: equ 7
c_grey_dk: equ 8
c_red: equ 9
c_green: equ 10
c_yellow: equ 11
c_blue: equ 12
c_magenta: equ 13
c_cyan: equ 14
c_white: equ 15

; VDU 25, mode, x; y;: PLOT command
; inputs: a=mode, bc=x0, de=y0
vdu_plot:
    ld (@mode),a
    ld (@x0),bc
    ld (@y0),de
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd:   db 25
@mode:  db 0
@x0: 	dw 0
@y0: 	dw 0
@end:   db 0 ; extra byte to soak up deu

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

; https://agonconsole8.github.io/agon-docs/VDP---PLOT-Commands.html
; &E8-&EF 	232-239 	Bitmap plot §
; VDU 25, mode, x; y;: PLOT command
; inputs: bc=x0, de=y0
; USING 16.8 FIXED POINT COORDINATES
; inputs: ub.c is x coordinate, ud.e is y coordinate
;   the fractional portiion of the inputs are truncated
;   leaving only the 16-bit integer portion
; prerequisites: vdu_buff_select
vdu_plot_bmp168:
; populate in the reverse of normal to keep the 
; inputs from stomping on each other
    ld (@y0-1),de
    ld (@x0-1),bc
    ld a,plot_bmp+dr_abs_fg ; 0xED
    ld (@mode),a ; restore the mode byte that got stomped on by bcu
	ld hl,@cmd
	ld bc,@end-@cmd
	rst.lil $18
	ret
@cmd:   db 25
@mode:  db plot_bmp+dr_abs_fg ; 0xED
@x0: 	dw 0x0000
@y0: 	dw 0x0000
@end:  ; no padding required b/c we shifted de right

; draw a filled rectangle
vdu_plot_rf:
    ld (@x0),bc
    ld (@y0),de
    ld (@x1),ix
    ld (@y1),iy
    ld a,25 ; we have to reload the 2nd plot command
    ld (@cmd1),a ; because the 24-bit y0 load stomped on it
	ld hl,@cmd0 
	ld bc,@end-@cmd0 
	rst.lil $18
    ret
@cmd0:  db 25 ; plot
@arg0:  db plot_sl_both+mv_abs
@x0:    dw 0x0000
@y0:    dw 0x0000
@cmd1:  db 25 ; plot
@arg1:  db plot_rf+dr_abs_fg
@x1:    dw 0x0000
@y1:    dw 0x0000
@end:   db 0x00 ; padding

; draw a filled circle
vdu_plot_cf:
    ld (@x0),bc
    ld (@y0),de
    ld (@x1),ix
    ld (@y1),iy
    ld a,25 ; we have to reload the 2nd plot command
    ld (@cmd1),a ; because the 24-bit y0 load stomped on it
	ld hl,@cmd0 
	ld bc,@end-@cmd0 
	rst.lil $18
    ret
@cmd0:  db 25 ; plot
@arg0:  db plot_sl_both+mv_abs
@x0:    dw 0x0000
@y0:    dw 0x0000
@cmd1:  db 25 ; plot
@arg1:  db plot_cf+dr_abs_fg
@x1:    dw 0x0000
@y1:    dw 0x0000
@end:   db 0x00 ; padding

; #### from vdu_sprites.inc ####
; ; https://github.com/AgonConsole8/agon-docs/blob/main/VDP---Bitmaps-API.md
; the VDP can support up to 256 sprites. They must be defined 
; contiguously, and so the first sprite is sprite 0. 
; (In contrast, bitmaps can have any ID from 0 to 65534.) 
; Once a selection of sprites have been defined, you can activate 
; them using the VDU 23, 27, 7, n command, where n is the number 
; of sprites to activate. This will activate the first n sprites, 
; starting with sprite 0. All sprites from 0 to n-1 must be defined.

; A single sprite can have multiple "frames", referring to 
; different bitmaps. 
; (These bitmaps do not need to be the same size.) 
; This allows a sprite to include an animation sequence, 
; which can be stepped through one frame at a time, or picked 
; in any order.

; Any format of bitmap can be used as a sprite frame. It should 
; be noted however that "native" format bitmaps are not 
; recommended for use as sprite frames, as they cannot get 
; erased from the screen. (As noted above, the "native" bitmap 
; format is not really intended for general use.) This is part 
; of why from Agon Console8 VDP 2.6.0 bitmaps captured from the 
; screen are now stored in RGBA2222 format.

; An "active" sprite can be hidden, so it will stop being drawn, 
; and then later shown again.

; Moving sprites around the screen is done by changing the 
; position of the sprite. This can be done either by setting 
; the absolute position of the sprite, or by moving the sprite 
; by a given number of pixels. (Sprites are positioned using 
; pixel coordinates, and not by the logical OS coordinate system.) 
; In the current sprite system, sprites will not update their 
; position on-screen until either another drawing operation is 
; performed or an explicit VDU 23, 27, 15 command is performed.

; Here are the sprite commands:
;
; VDU 23, 27, 4,  n: Select sprite n
; inputs: a is the 8-bit sprite id
; vdu_sprite_select:

; VDU 23, 27, 5:  Clear frames in current sprite
; inputs: none
; prerequisites: vdu_sprite_select
; vdu_sprite_clear_frames:

; VDU 23, 27, 6,  n: Add bitmap n as a frame to current sprite (where bitmap's buffer ID is 64000+n)
; inputs: a is the 8-bit bitmap number
; prerequisites: vdu_sprite_select
; vdu_sprite_add_bmp:

; VDU 23, 27, 7,  n: Activate n sprites
; inputs: a is the number of sprites to activate
; vdu_sprite_activate:

; VDU 23, 27, 8:  Select next frame of current sprite
; inputs: none
; prerequisites: vdu_sprite_select
; vdu_sprite_next_frame:

; VDU 23, 27, 9:  Select previous frame of current sprite
; inputs: none
; prerequisites: vdu_sprite_select
; vdu_sprite_prev_frame:

; VDU 23, 27, 10, n: Select the nth frame of current sprite
; inputs: a is frame number to select
; prerequisites: vdu_sprite_select
; vdu_sprite_select_frame:

; VDU 23, 27, 11: Show current sprite
; inputs: none
; prerequisites: vdu_sprite_select
; vdu_sprite_show:

; VDU 23, 27, 12: Hide current sprite
; inputs: none
; prerequisites: vdu_sprite_select
; vdu_sprite_hide:

; VDU 23, 27, 13, x; y;: Move current sprite to pixel position x, y
; inputs: bc is x coordinate, de is y coordinate
; prerequisites: vdu_sprite_select
; vdu_sprite_move_abs:
;
; USING 16.8 FIXED POINT COORDINATES
; inputs: ub.c is x coordinate, ud.e is y coordinate
;   the fractional portiion of the inputs are truncated
;   leaving only the 16-bit integer portion
; prerequisites: vdu_sprite_select
; vdu_sprite_move_abs168:

; VDU 23, 27, 14, x; y;: Move current sprite by x, y pixels
; inputs: bc is x coordinate, de is y coordinate
; prerequisites: vdu_sprite_select
; vdu_sprite_move_rel:
;
; USING 16.8 FIXED POINT COORDINATES
; inputs: ub.c is dx, ud.e is dy
;   the fractional portiion of the inputs are truncated
;   leaving only the 16-bit integer portion
; prerequisites: vdu_sprite_select
; vdu_sprite_move_rel168:

; VDU 23, 27, 15: Update the sprites in the GPU
; inputs: none
; vdu_sprite_update:

; VDU 23, 27, 16: Reset bitmaps and sprites and clear all data
; inputs: none
; vdu_sprite_bmp_reset:

; VDU 23, 27, 17: Reset sprites (only) and clear all data
; inputs: none
; vdu_sprite_reset:

; VDU 23, 27, 18, n: Set the current sprite GCOL paint mode to n **
; inputs: a is the GCOL paint mode
; prerequisites: vdu_sprite_select
; vdu_sprite_set_gcol:

; VDU 23, 27, &26, n;: Add bitmap n as a frame to current sprite using a 16-bit buffer ID
; inputs: hl=bufferId
; prerequisites: vdu_sprite_select
; vdu_sprite_add_buff:

@dummy_label: ; dummy label to serve as a break from the above comments and the below code

; VDU 23, 27, 4, n: Select sprite n
; inputs: a is the 8-bit sprite id
vdu_sprite_select:
    ld (@sprite),a        
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd:    db 23,27,4
@sprite: db 0x00
@end:

; VDU 23, 27, 5: Clear frames in current sprite
; inputs: none
; prerequisites: vdu_sprite_select
vdu_sprite_clear_frames:
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,5
@end:

; VDU 23, 27, 6, n: Add bitmap n as a frame to current sprite (where bitmap's buffer ID is 64000+n)
; inputs: a is the 8-bit bitmap number
; prerequisites: vdu_sprite_select
vdu_sprite_add_bmp:
    ld (@bmp),a        
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,6
@bmp: db 0x00
@end:

; VDU 23, 27, 7, n: Activate n sprites
; inputs: a is the number of sprites to activate
vdu_sprite_activate:
    ld (@num),a        
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,7
@num: db 0x00
@end:

; VDU 23, 27, 8: Select next frame of current sprite
; inputs: none
; prerequisites: vdu_sprite_select
vdu_sprite_next_frame:
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,8
@end:

; VDU 23, 27, 9: Select previous frame of current sprite
; inputs: none
; prerequisites: vdu_sprite_select
vdu_sprite_prev_frame:
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,9
@end:

; VDU 23, 27, 10, n: Select the nth frame of current sprite
; inputs: a is frame number to select
; prerequisites: vdu_sprite_select
vdu_sprite_select_frame:
    ld (@frame),a        
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd:    db 23,27,10
@frame:  db 0x00
@end:

; VDU 23, 27, 11: Show current sprite
; inputs: none
; prerequisites: vdu_sprite_select
vdu_sprite_show:
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,11
@end:

; VDU 23, 27, 12: Hide current sprite
; inputs: none
; prerequisites: vdu_sprite_select
vdu_sprite_hide:
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,12
@end:

; VDU 23, 27, 13, x; y;: Move current sprite to pixel position x, y
; inputs: bc is x coordinate, de is y coordinate
; prerequisites: vdu_sprite_select
vdu_sprite_move_abs:
    ld (@xpos),bc
    ld (@ypos),de
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd:  db 23,27,13
@xpos: dw 0x0000
@ypos: dw 0x0000
@end:  db 0x00 ; padding

; VDU 23, 27, 14, x; y;: Move current sprite by x, y pixels
; inputs: bc is x coordinate, de is y coordinate
; prerequisites: vdu_sprite_select
vdu_sprite_move_rel:
    ld (@dx),bc
    ld (@dy),de
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,14
@dx:  dw 0x0000
@dy:  dw 0x0000
@end: db 0x00 ; padding

; VDU 23, 27, 13, x; y;: Move current sprite to pixel position x, y
; USING 16.8 FIXED POINT COORDINATES
; inputs: ub.c is x coordinate, ud.e is y coordinate
;   the fractional portiion of the inputs are truncated
;   leaving only the 16-bit integer portion
; prerequisites: vdu_sprite_select
vdu_sprite_move_abs168:
; populate in the reverse of normal to keep the 
; inputs from stomping on each other
    ld (@ypos-1),de
    ld (@xpos-1),bc
    ld a,13       ; restore the final byte of the command
    ld (@cmd+2),a ; string that got stomped on by bcu
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd:  db 23,27,13
@xpos: dw 0x0000
@ypos: dw 0x0000
@end:  ; no padding required b/c we shifted de right

; VDU 23, 27, 14, x; y;: Move current sprite by x, y pixels
; USING 16.8 FIXED POINT COORDINATES
; inputs: ub.c is dx, ud.e is dy
;   the fractional portiion of the inputs are truncated
;   leaving only the 16-bit integer portion
; prerequisites: vdu_sprite_select
vdu_sprite_move_rel168:
; populate in the reverse of normal to keep the 
; inputs from stomping on each other
    ld (@dy-1),de
    ld (@dx-1),bc
    ld a,14       ; restore the final byte of the command
    ld (@cmd+2),a ; string that got stomped on by bcu
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd:  db 23,27,14
@dx: dw 0x0000
@dy: dw 0x0000
@end:  ; no padding required b/c we shifted de right

; VDU 23, 27, 15: Update the sprites in the GPU
; inputs: none
vdu_sprite_update:
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,15
@end:

; VDU 23, 27, 16: Reset bitmaps and sprites and clear all data
; inputs: none
vdu_sprite_bmp_reset:
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,16
@end:

; VDU 23, 27, 17: Reset sprites (only) and clear all data
; inputs: none
vdu_sprite_reset:
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd: db 23,27,17
@end:

; VDU 23, 27, 18, n: Set the current sprite GCOL paint mode to n **
; inputs: a is the GCOL paint mode
; prerequisites: vdu_sprite_select
vdu_sprite_set_gcol:
    ld (@mode),a        
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd:  db 23,27,18
@mode: db 0x00 
@end:

; VDU 23, 27, &26, n;: Add bitmap bufferId 
;     as a frame to current sprite using a 16-bit buffer ID
; inputs: hl=bufferId
; prerequisites: vdu_sprite_select
vdu_sprite_add_buff:
    ld (@bufferId),hl
    ld hl,@cmd         
    ld bc,@end-@cmd    
    rst.lil $18         
    ret
@cmd:      db 23,27,0x26
@bufferId: dw 0x0000
@end:      db 0x00 ; padding
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 

; 
; ###########################################
; Included from: ../agon_api/asm/vdu_buff.inc
; ###########################################
; 
; VDP Buffered Commands API
; https://agonconsole8.github.io/agon-docs/VDP---Buffered-Commands-API.html

; VDU 23, 0 &A0, bufferId; 0, length; <buffer-data>
; This command is used to store a data block (a sequence of bytes) 
; in a buffer on the VDP. The exact nature of this data may vary. 
; It could be a sequence of VDU commands which can be executed 
; later, a bitmap, a sound sample, or just a sequence of bytes. 
; When used for a sequence of VDU commands, this effectively 
; allows for functions or stored procedures to be created.

; This is the most common command to use to send data to the VDP. 
; Typically you will call command 2 first to ensure that the 
; buffer is empty, and then make a series of calls to this command 
; to send data to the buffer.

; The bufferId is a 16-bit integer that identifies the buffer to 
; write to. Writing to the same buffer ID multiple times will add 
; new blocks to that buffer. This allows a buffer to be built up 
; over time, essentially allowing for a command to be sent across 
; to the VDP in multiple separate packets.

; Whilst the length of an individual block added using this command 
; is restricted to 65535 bytes (as the largest value that can be 
; sent in a 16-bit number) the total size of a buffer is not 
; restricted to this size, as multiple blocks can be added to a 
; buffer. Given how long it takes to send data to the VDP it is 
; advisable to send data across in smaller chunks, such as 1kb of 
; data or less at a time.

; As writing to a single buffer ID is cumulative with this command, 
; care should be taken to ensure that the buffer is cleared out 
; before writing to it.

; When building up a complex sequence of commands it is often 
; advisable to use multiple blocks within a buffer. Typically 
; this is easier to code, as otherwise working out exactly how 
; many bytes long a command sequence is can be can be onerously 
; difficult. It is also easier to modify a command sequences that 
; are broken up into multiple blocks.

; As mentioned above it is advisable to send large pieces of data, 
; such as bitmaps or sound samples, in smaller chunks. In between 
; each packet of data sent to a buffer, the user can then perform 
; other operations, such as updating the screen to indicate 
; progress. This allows for long-running operations to be performed 
; without blocking the screen, and larger amounts of data to be 
; transferred over to the VDP than may otherwise be practical given 
; the limitations of the eZ80.

; If a buffer ID of 65535 is used then this command will be 
; ignored, and the data discarded. This is because this buffer ID 
; is reserved for special functions.

; Using buffers for bitmaps

; Whilst it is advisable to send bitmaps over in multiple blocks, 
; they cannot be used if they are spread over multiple blocks. 
; To use a bitmap its data must be in a single contiguous block, 
; and this is achieved by using the “consolidate” command &0E.

; Once you have a block that is ready to be used for a bitmap, 
; the buffer must be selected, and then a bitmap created for that 
; buffer using the bitmap and sprites API. This is done with the 
; following commands:

; VDU 23, 27, &20, bufferId;              : REM Select bitmap (using a buffer ID)
; VDU 23, 27, &21, width; height; format  : REM Create bitmap from buffer

; Until the “create bitmap” call has been made the buffer cannot 
; be used as a bitmap. That is because the system needs to 
; understand the dimensions of the bitmap, as well as the format 
; of the data. Usually this only needs to be done once. The format 
; is given as an 8-bit value, with the following values supported:
; Value 	Type 	Description
; 0 	RGBA8888 	RGBA, 8-bits per channel, with bytes ordered sequentially for red, green, blue and alpha
; 1 	RGBA2222 	RGBA, 2-bits per channel, with bits ordered from highest bits as alpha, blue, green and red
; 2 	Mono 	Monochrome, 1-bit per pixel

; The existing bitmap API uses an 8-bit number to select bitmaps, 
; and these are automatically stored in buffers numbered 64000-64255 
; (&FA00-&FAFF). Working out the buffer number for a bitmap is 
; simply a matter of adding 64000. All bitmaps created with that 
; API will be RGBA8888 format.

; There is one other additional call added to the bitmap and 
; sprites API, which allows for bitmaps referenced with a 
; buffer ID to be added to sprites. This is done with the 
; following command:

; VDU 23, 27, &26, bufferId;              : REM Add bitmap to the current sprite

; This command otherwise works identically to VDU 23, 27, 6.

; It should be noted that it is possible to modify the buffer 
; that a bitmap is stored in using the “adjust buffer contents” 
; and “reverse contents” commands (5 and 24 respectively). This 
; can allow you to do things such as changing colours in a bitmap,
; or flipping an image horizontally or vertically. This will even 
; work on bitmaps that are being used inside sprites.

; Using commands targetting a buffer that create new blocks, 
; such as “consolidate” or “split”, will invalidate the bitmap 
; and remove it from use.

; Using buffers for sound samples

; Much like with bitmaps, it is advisable to send samples over 
; to the VDP in multiple blocks for the same reasons.

; In contrast to bitmaps, the sound system can play back samples 
; that are spread over multiple blocks, so there is no need to 
; consolidate buffers. As a result of this, the sample playback 
; system is also more tolerant of modifications being made to 
; the buffer after a sample has been created from it, even if 
; the sample is currently playing. It should be noted that 
; splitting a buffer may result in unexpected behaviour if 
; the sample is currently playing, such as skipping to other 
; parts of the sample.

; Once you have a buffer that contains block(s) that are ready 
; to be used for a sound sample, the following command must be 
; used to indicate that a sample should be created from that buffer:

; VDU 23, 0, &85, 0, 5, 2, bufferId; format

; The format parameter is an 8-bit value that indicates the 
; format of the sample data. The following values are supported:
; Value 	Description
; 0 	8-bit signed, 16KHz
; 1 	8-bit unsigned, 16KHz

; Once a sample has been created in this way, the sample can 
; be selected for use on a channel using the following command:

; VDU 23, 0, &85, channel, 4, 8, bufferId;

; Samples uploaded using the existing “load sample” command 
; (VDU 23, 0, &85, sampleNumber, 5, 0, length; lengthHighByte, <sample data>) 
; are also stored in buffers automatically. A sample number using this system is in 
; the range of -1 to -128, but these are stored in the range 64256-64383 (&FB00-&FB7F). 
; To map a number to a buffer range, you need to negate it, subtract 1, and then add 
; it to 64256. This means sample number -1 is stored in buffer 64256, -2 is stored in 
; buffer 64257, and so on.
; Command 1: Call a buffer

; VDU 23, 0 &A0, bufferId; 1

; This command will attempt to execute all of the commands 
; stored in the buffer with the given ID. If the buffer does 
; not exist, or is empty, then this command will do nothing.

; Essentially, this command passes the contents of the buffer 
; to the VDP’s VDU command processor system, and executes them 
; as if they were sent directly to the VDP.

; As noted against command 0, it is possible to build up a 
; buffer over time by sending across multiple commands to write 
; to the same buffer ID. When calling a buffer with multiple 
; blocks, the blocks are executed in order.

; Care should be taken when using this command within a buffer, 
; as it is possible to create an infinite loop. For instance, 
; if a buffer contains a command to call itself, then this will 
; result in an infinite loop. This will cause the VDP to hang, 
; and the only way to recover from this is to reset the VDP.

; Using a bufferId of -1 (65535) will cause the current buffer 
; to be executed. This can be useful for creating loops within 
; a buffer. It will be ignored if used outside of a buffered 
; command sequence.

; Command 2: Clear a buffer
; VDU 23, 0 &A0, bufferId; 2

; This command will clear the buffer with the given ID. If 
; the buffer does not exist then this command will do nothing.

; Please note that this clears out all of the blocks sent to 
; a buffer via command 0, not just the last one. i.e. if you 
; have built up a buffer over time by sending multiple commands 
; to write to the same buffer ID, this command will clear out 
; all of those commands.

; Calling this command with a bufferId value of -1 (65535) will 
; clear out all buffers.

; Command 3: Create a writeable buffer
; VDU 23, 0 &A0, bufferId; 3, length;
; This command will create a new writeable buffer with the given 
; ID. If a buffer with the given ID already exists then this 
; command will do nothing. This command is primarily intended 
; for use to create a buffer that can be used to capture output 
; using the “set output stream” command (see below), or to store 
; data that can be used for other commands.

; It is generally quite rare that you will want to use this 
; command. Typically you will instead want to use command 0 
; to write data to a buffer. It is not necessary to use this 
; command before using command 0, and indeed doing so will 
; lead to errors as you will end up with two blocks in the 
; buffer, the first of which will be empty. If you do wish 
; to use this command to create a buffer for data and then 
; write to it, you would need to use operation 2 of command 5, 
; the “set” operation in the “buffer adjust” command, to set a 
; sequence of bytes in the buffer to the data you want to write. 
; This is not recommended, as it is much easier to just use 
; command 0 to write a data block to a buffer.

; This new buffer will be a single empty single block upon 
; creation, containing zeros.

; The length parameter is a 16-bit integer that specifies 
; the maximum size of the buffer. This is the maximum number 
; of bytes that can be stored in the buffer. If the buffer 
; is full then no more data can be written to it, and subsequent 
; writes will be ignored.

; After creating a buffer with this command it is possible to 
; use command 0 to write further blocks to the buffer, however 
; this is probably not advisable.

; A bufferId of -1 (65535) and 0 will be ignored, as these 
; values have special meanings for writable buffers. See command 4.

; Command 4: Set output stream to a buffer
; VDU 23, 0 &A0, bufferId; 4

; Sets then current output stream to the buffer with the given ID. 
; With two exceptions, noted below, this needs to be a writable 
; buffer created with command 3. If the buffer does not exist, 
; or the first block within the buffer is not writable, then 
; this command will do nothing.

; Following this command, any subsequent VDU commands that send 
; response packets will have those packets written to the specified 
; output buffer. This allows the user to capture the response 
; packets from a command sent to the VDP.

; By default, the output stream (for the main VDU command processor)
; is the communications channel from the VDP to MOS running on the 
; eZ80.

; Passing a buffer ID of -1 (65535) to this command will 
; remove/detach the output buffer. From that point onwards, 
; any subsequent VDU commands that send response packets will 
; have those responses discarded/ignored.

; Passing a buffer ID of 0 to this command will set the output 
; buffer back to its original value for the current command stream. 
; Typically that will be the communications channel from the VDP to 
; MOS running on the eZ80, but this may not be the case if a nested 
; call has been made.

; When used inside a buffered command sequence, this command will 
; only affect the output stream for that sequence of commands, and 
; any other buffered command sequences that are called from within 
; that sequence. Once the buffered command sequence has completed, 
; the output stream will effectively be reset to its original value.

; It is strongly recommended to only use this command from within a 
; buffered command sequence. Whilst it is possible to use this 
; command from within a normal VDU command sequence, it is not 
; recommended as it may cause unexpected behaviour. If you do use 
; it in that context, it is very important to remember to restore 
; the original output channel using VDU 23, 0, &A0, 0; 4. (In the 
; future, this command may be disabled from being used outside of 
; a buffered command sequence.)

; At present, writable buffers can only be written to until the end 
; of the buffer has been reached; once that happens no more data 
; will be written to the buffer. It is not currently possible to 
; “rewind” an output stream. It is therefore advisable to ensure 
; that the buffer is large enough to capture all of the data that
; is expected to be written to it. The only current way to “rewind” 
; an output stream would be to clear the buffer and create a new 
; one, and then call set output stream again with the newly created 
; buffer.

; Command 5: Adjust buffer contents
; VDU 23, 0, &A0, bufferId; 5, operation, offset; [count;] <operand>, [arguments]

; This command will adjust the contents of a buffer, at a given 
; offset. The exact nature of the adjustment will depend on the 
; operation used.

; Passing a bufferId of -1 (65535) to this command will adjust 
; the contents of the current buffer. This will only work if this 
; command is used within a buffered command sequence, otherwise the 
; command will not do anything.

; The basic set of adjustment operations are as follows:
; Operation 	Description
; 0 	NOT
; 1 	Negate
; 2 	Set value
; 3 	Add
; 4 	Add with carry
; 5 	AND
; 6 	OR
; 7 	XOR

; All of these operations will modify a byte found at the given 
; offset in the buffer. The only exception to that is the “Add with 
; carry” operation, which will also store the “carry” value in the 
; byte at the next offset. With the exception of NOT and Negate, 
; each command requires an operand value to be specified.

; To flip the bits of a byte at offset 12 in buffer 3, you would 
; need to use the NOT operation, and so the following command would 
; be used:

; VDU 23, 0, &A0, 3; 5, 0, 12;

; To add 42 to the byte at offset 12 in buffer 3, you would need 
; to use the Add operation, and so the following command would be 
; used:

; VDU 23, 0, &A0, 3; 5, 3, 12; 42

; When using add with carry, the carry value is stored in the byte 
; at the next offset. So to add 42 to the byte at offset 12 in 
; buffer 3, and store the carry value in the byte at offset 13, 
; you would need to use the Add with carry operation, and so the 
; following command would be used:

; VDU 23, 0, &A0, 3; 5, 4, 12; 42

; Advanced operations

; Whilst these operations are useful, they are not particularly 
; powerful as they only operate one one byte at a time, with a 
; fixed operand value, and potentially cannot reach all bytes in 
; a buffer. To address this, the API supports a number of advanced 
; operations.

; The operation value used is an 8-bit value that can have bits 
; set to modify the behaviour of the operation. The following bits 
; are defined:
; Bit 	Description
; &10 	Use “advanced” offsets
; &20 	Operand is a buffer-fetched value (buffer ID and an offset)
; &40 	Multiple target values should be adjusted
; &80 	Multiple operand values should be used

; These bits can be combined together to modify the behaviour of 
; the operation.

; Fundamentally, this command adjusts values of a buffer at a given 
; offset one byte at a time. When either of the “multiple” variants 
; are used, a 16-bit count must be provided to indicate how many 
; bytes should be altered.

; Advanced offsets are sent as a 24-bit value in little-endian 
; order, which can allow for buffers that are larger than 64kb 
; to be adjusted. If the top-bit of this 24-bit value is set, then 
; the 16-bit value immediately following the offset is used as a 
; block index number, and the remaining 23-bits of the offset value 
; are used as an offset within that block. When the “advanced” 
; offset mode bit has been set then all offsets associated with 
; this command must be sent as advanced offsets.

; The “buffer-fetched value” mode allows for the operand value to 
; be fetched from a buffer. The operand sent as part of the 
; command in this case is a pair of 16-bit values giving the 
; buffer ID and offset to indicate where the actual operand value 
; should be fetched from. An operand buffer ID of -1 (65535) will 
; be interpretted as meaning “this buffer”, and thus can only be 
; used inside a buffered command sequence. If the advanced offset 
; mode is used, then the operand value is an advanced offset value.

; The “multiple target values” mode allows for multiple bytes to 
; be adjusted at once. When this mode is used, the count value 
; must be provided to indicate how many bytes should be adjusted. 
; Unless the “multiple operand values” mode is also used, the 
; operand value is used for all bytes adjusted.

; The “multiple operand values” mode allows for multiple operand 
; values to be used. When this mode is used, the count value must 
; be provided to indicate how many operand values should be used. 
; This can allow, for instance, to add together several bytes in a 
; buffer. When this mode is used in conjunction with the “multiple 
; target values” mode, the number of operand values must match the 
; number of target values, and the operation happens one byte at a 
; time.

; Some examples of advanced operations are as follows:

; Flip the bits of 7 bytes in buffer 3 starting at offset 12:

; VDU 23, 0, &A0, 3; 5, &40, 12; 7;

; This uses operation 0 (NOT) with the “multiple target values” 
; modifier (&40).

; Add 42 to each of the 7 bytes in buffer 3 starting at offset 12:

; VDU 23, 0, &A0, 3; 5, &43, 12; 7; 42

; Set the byte at offset 12 in the fourth block of buffer 3 to 42:

; VDU 23, 0, &A0, 3; 5, &12, 12; &80, 4; 42

; This is using operation 2 (Set) with the “advanced offsets” 
; modifier (&10). As BBC BASIC doesn’t natively understand how 
; to send 24-bit values it is sent as the 16-bit value 12; followed 
; by a byte with its top bit set &80 to complete the 24-bit offset 
; in little-endian order. As the top bit of the offset is set, this 
; indicates that the next 16-bit value will be a block index, 4;. 
; Finally the value to write is sent, 42.

; An operation like this could be used to set the position as part 
; of a draw command.

; Set the value in buffer 3 at offset 12 to the sum of the five 
; values 1, 2, 3, 4, 5:

; VDU 23, 0, &A0, 3; 5, 2, 12; 0  : REM clear out the value at 
; offset 12 (set it to 0)
; VDU 23, 0, &A0, 3; 5, &83, 12; 5; 1, 2, 3, 4, 5

; AND together 7 bytes in buffer 3 starting at offset 12 with the 
; 7 bytes in buffer 4 starting at offset 42:

; VDU 23, 0, &A0, 3; 5, &E5, 12; 7; 4; 42;

; As we are working on a little-endian system, integers longer 
; than one byte are sent with their least significant byte first. 
; This means that the add with carry operation can be used to add 
; together integers of any size, so long as they are the same size. 
; To do this, both the “multiple target values” and “multiple 
; operand values” modes must be used.

; The following commands will add together a 16-bit, 24-bit, 
; 32-bit, and 40-bit integers, all targetting the value stored 
; in buffer 3 starting at offset 12, and all using the operand 
; value of 42:

; VDU 23, 0, &A0, 3; 5, &C4, 12; 2; 42;  : REM 2 bytes; a 16-bit integer
; VDU 23, 0, &A0, 3; 5, &C4, 12; 3; 42; 0  : REM 3 bytes; a 24-bit integer
; VDU 23, 0, &A0, 3; 5, &C4, 12; 4; 42; 0;  : REM 4 bytes; a 32-bit integer
; VDU 23, 0, &A0, 3; 5, &C4, 12; 5; 42; 0; 0  : REM 5 bytes; a 40-bit integer

; Take note of how the operand value is padded out with zeros 
; to match the size of the target value. 42; is used as a base 
; to send a 16-bit value, with zeros added of either 8-bit or 
; 16-bits to pad it out to the required size. The “carry” value 
; will be stored at the next offset in the target buffer after 
; the complete target value. So for a 16-bit value, the carry 
; will be stored at offset 14, for a 24-bit value it will be stored 
; at offset 15, and so on.

; Command 6: Conditionally call a buffer

; VDU 23, 0, &A0, bufferId; 6, operation, checkBufferId; checkOffset; [arguments]

; This command will conditionally call a buffer if the condition 
; operation passes. This command works in a similar manner to the 
; “Adjust buffer contents” command.

; With this command a buffer ID of 65535 (-1) is always 
; interpretted as “current buffer”, and so can only be used 
; within a buffered command sequence. If used outside of a 
; buffered command sequence then this command will do nothing.

; The basic set of condition operations are as follows:
; Operation 	Description
; 0 	Exists (value is non-zero)
; 1 	Not exists (value is zero)
; 2 	Equal
; 3 	Not equal
; 4 	Less than
; 5 	Greater than
; 6 	Less than or equal
; 7 	Greater than or equal
; 8 	AND
; 9 	OR

; The value that is being checked is fetched from the specified 
; check buffer ID and offset. With the exception of “Exists” and 
; “Not exists”, each command requires an operand value to be 
; specified to check against.

; The operation value used is an 8-bit value that can have bits 
; set to modify the behaviour of the operation. The following bits 
; are defined:
; Bit value 	Description
; &10 	Use advanced offsets
; &20 	Operand is a buffer-fetched value (buffer ID and an offset)

; These modifiers can be combined together to modify the behaviour 
; of the operation.

; At this time, unlike with the “adjust” command, multiple target 
; values and multiple operand values are not supported. All 
; comparisons are therefore only conducted on single 8-bit values. 
; (If comparisons of 16-bit values are required, multiple calls 
; can be combined.) Support for them may be added in the future.

; The AND and OR operations are logical operations, and so the 
; operand value is used as a boolean value. Any non-zero value is 
; considered to be true, and zero is considered to be false. These 
; operations therefore are most useful when used with buffer-fetched 
; operand values (operations &28, &29, &38 and &39).

; Some examples of condition operations are as follows:

; Call buffer 7 if the value in buffer 12 at offset 5 exists 
; (is non-zero):

; VDU 23, 0, &A0, 7; 6, 0, 12; 5;

; Call buffer 8 if the value in buffer 12 at offset 5 does not 
; exist (is zero):

; VDU 23, 0, &A0, 8; 6, 1, 12; 5;

; Combining the above two examples is effectively equivalent to 
; “if the value exists, call buffer 7, otherwise call buffer 8”:

; VDU 23, 0, &A0, 7; 6, 0, 12; 5;
; VDU 23, 0, &A0, 8; 6, 1, 12; 5;

; Call buffer 3 if the value in buffer 4 at offset 12 is equal to 42:

; VDU 23, 0, &A0, 3; 6, 2, 4; 12; 42

; Call buffer 5 if the value in buffer 2 at offset 7 is less than 
; the value in buffer 2 at offset 8:

; VDU 23, 0, &A0, 5; 6, &24, 2; 7; 2; 8;

; Command 7: Jump to a buffer

; VDU 23, 0, &A0, bufferId; 7

; This command will jump to the buffer with the given ID. If 
; the buffer does not exist, or is empty, then this command will 
; do nothing.

; This essentially works the same as the call command (command 1),
;  except that it does not return to the caller. This command is 
;  therefore useful for creating loops.

; Using this command to jump to buffer 65535 (buffer ID -1) is 
; treated as a “jump to end of current buffer”. This will return 
; execution to the caller, and can be useful for exiting a loop.

; ## Command 8: Conditional Jump to a buffer

; VDU 23, 0, &A0, bufferId; 8, operation, checkBufferId; checkOffset; [arguments]

; This command operates in a similar manner to the “Conditionally 
; call a buffer” command (command 6), except that it will jump to 
; the buffer if the condition operation passes.

; As with the “Jump to a buffer” command (command 7), a jump to 
; buffer 65535 is treated as a “jump to end of current buffer”.
; Command 9: Jump to an offset in a buffer

; VDU 23, 0, &A0, bufferId; 9, offset; offsetHighByte, [blockNumber;]

; This command will jump to the given offset in the buffer with the 
; given ID. If the buffer does not exist, or is empty, then this 
; command will do nothing.

; The offset in this command is always an “advanced” offset, given 
; as a 24-bit value in little-endian order. As with other uses of 
; advanced offsets, if the top-bit is set in the high byte of the 
; offset value, a block number must also be provided.

; When jumping to an offset, using buffer ID 65535 is treated as 
; meaning “jump within current buffer”. This can be useful for 
; creating loops within a buffer, or when building up command 
; sequences that may be copied across multiple buffers.

; Jumping to an offset that is beyond the end of the buffer is 
; equivalent to jumping to the end of the buffer.
; Command 10: Conditional jump to an offset in a buffer

; VDU 23, 0, &A0, bufferId; 10, offset; offsetHighByte, [blockNumber;] [arguments]

; A conditional jump with an offset works in a similar manner to 
; the “Conditional call a buffer” command (command 6), except that 
; it will jump to the given offset in the buffer if the condition 
; operation passes.

; As with the “Jump to an offset in a buffer” command (command 9), 
; the offset in this command is always an “advanced” offset, given 
; as a 24-bit value in little-endian order, and the usual advanced 
; offset rules apply. And similarly, using buffer ID 65535 is 
; treated as meaning “jump within current buffer”.
; Command 11: Call buffer with an offset

; VDU 23, 0, &A0, bufferId; 11, offset; offsetHighByte, [blockNumber;]

; Works just like “Call a buffer” (command 1), except that it also 
; accepts an advanced offset.

; Command 12: Conditional call buffer with an offset

; VDU 23, 0, &A0, bufferId; 12, offset; offsetHighByte, [blockNumber;] [arguments]

; Works just like the “Conditional call a buffer” command 
; (command 6), except that it also accepts an advanced offset.

; Command 13: Copy blocks from multiple buffers into a single buffer

; VDU 23, 0, &A0, targetBufferId; 13, sourceBufferId1; sourceBufferId2; ... 65535;

; This command will copy the contents of multiple buffers into a 
; single buffer. The buffers to copy from are specified as a list 
; of buffer IDs, terminated by a buffer ID of -1 (65535). The 
; buffers are copied in the order they are specified.

; This is a block-wise copy, so the blocks from the source buffers 
; are copied into the target buffer. The blocks are copied in the 
; order they are found in the source buffers.

; The target buffer will be overwritten with the contents of the 
; source buffers. This will not be done however until after all the 
; data has been gathered and copied. The target buffer can therefore
; included in the list of the source buffers.

; If a source buffer that does not exist is specified, or a source 
; buffer that is empty is specified, then that buffer will be ignored. If no source buffers are specified, or all of the source buffers are empty, then the target buffer will be cleared out.

; The list of source buffers can contain repeated buffer IDs. If a 
; buffer ID is repeated, then the blocks from that buffer will be 
; copied multiple times into the target buffer.

; If there is insufficient memory available on the VDP to complete 
; this command then it will fail, and the target buffer will be 
; left unchanged.


; Command 14: Consolidate blocks in a buffer

; VDU 23, 0, &A0, bufferId; 14

; Takes all the blocks in a buffer and consolidates them into a 
; single block. This is useful for bitmaps, as it allows for a 
; bitmap to be built up over time in multiple blocks, and then 
; consolidated into a single block for use as a bitmap.

; If there is insufficient memory available on the VDP to complete 
; this command then it will fail, and the buffer will be left 
; unchanged.

; Command 15: Split a buffer into multiple blocks

; VDU 23, 0, &A0, bufferId; 15, blockSize;

; Splits a buffer into multiple blocks. The blockSize parameter 
; is a 16-bit integer that specifies the target size of each block. 
; If the source data is not a multiple of the block size then the 
; last block will be smaller than the specified block size.

; If this command is used on a buffer that is already split into 
; multiple blocks, then the blocks will be consolidated first, 
; and then re-split into the new block size.

; If there is insufficient memory available on the VDP to complete 
; this command then it will fail, and the buffer will be left 
; unchanged.
; Command 16: Split a buffer into multiple blocks and spread across 
; multiple buffers

; VDU 23, 0, &A0, bufferId; 16, blockSize; [targetBufferId1;] [targetBufferId2;] ... 65535;

; Splits a buffer into multiple blocks, as per command 15, but 
; then spreads the resultant blocks across the target buffers. 
; The target buffers are specified as a list of buffer IDs, 
; terminated by a buffer ID of -1 (65535).

; The blocks are spread across the target buffers in the order 
; they are specified, and the spread will loop around the buffers 
; until all the blocks have been distributed. The target buffers 
; will be cleared out before the blocks are spread across them.

; What this means is that if the source buffer is, let’s say, 
; 100 bytes in size and we split using a block size of 10 bytes 
; then we will end up with 10 blocks. If we then spread those 
; blocks across 3 target buffers, then the first buffer will 
; contain blocks 1, 4, 7 and 10, the second buffer will contain 
; blocks 2, 5 and 8, and the third buffer will contain 
; blocks 3, 6 and 9.

; This command attempts to ensure that, in the event of 
; insufficient memory being available on the VDP to complete 
; the command, it will leave the targets as they were before 
; the command was executed. However this may not always be 
; possible. The first step of this command is to consolidate 
; the source buffer into a single block, and this may fail from 
; insufficient memory. If that happens then all the buffers will 
; be left as they were. After this however the target buffers 
; will be cleared. If there is insufficient memory to successfully 
; split the buffer into multiple blocks then the call will exit, 
; and the target buffers will be left empty.
; Command 17: Split a buffer and spread across blocks, starting 
; at target buffer ID

; VDU 23, 0, &A0, bufferId; 17, blockSize; targetBufferId;

; As per the above two commands, this will split a buffer into 
; multiple blocks. It will then spread the blocks across buffers 
; starting at the target buffer ID, incrementing the target buffer 
; ID until all the blocks have been distributed.

; Target blocks will be cleared before a block is stored in them. 
; Each target will contain a single block. The exception to this 
; is if the target buffer ID reaches 65534, as it is not possible 
; to store a block in buffer 65535. In this case, multiple blocks 
; will be placed into buffer 65534.

; With this command if there is insufficient memory available on 
; the VDP to complete the command then it will fail, and the target 
; buffers will be left unchanged.

; Command 18: Split a buffer into blocks by width

; VDU 23, 0, &A0, bufferId; 18, width; blockCount;

; This command splits a buffer into a given number of blocks by 
; first of all splitting the buffer into blocks of a given width 
; (number of bytes), and then consolidating those blocks into the 
; given number of blocks.

; This is useful for splitting a bitmap into a number of separate 
; columns, which can then be manipulated individually. This can be 
; useful for dealing with sprite sheets.
; Command 19: Split by width into blocks and spread across target 
; buffers

; VDU 23, 0, &A0, bufferId; 19, width; [targetBufferId1;] [targetBufferId2;] ... 65535;

; This command essentially operates the same as command 18, but the 
; block count is determined by the number of target buffers specified. The blocks are spread across the target buffers in the order they are specified, with one block placed in each target.

; Command 20: Split by width into blocks and spread across blocks 
; starting at target buffer ID

; VDU 23, 0, &A0, bufferId; 20, width; blockCount; targetBufferId;

; This command essentially operates the same as command 18, but 
; the generated blocks are spread across blocks starting at the 
; target buffer ID, as per command 17.

; Command 21: Spread blocks from a buffer across multiple target 
; buffers

; VDU 23, 0, &A0, bufferId; 21, [targetBufferId1;] [targetBufferId2;] ... 65535;

; Spreads the blocks from a buffer across multiple target buffers. 
; The target buffers are specified as a list of buffer IDs, 
; terminated by a buffer ID of -1 (65535). The blocks are spread 
; across the target buffers in the order they are specified, and 
; the spread will loop around the buffers until all the blocks have 
; been distributed.

; It should be noted that this command does not copy the blocks, 
; and nor does it move them. Unless the source buffer has been 
; included in the list of targets, it will remain completely 
; intact. The blocks distributed across the target buffers will 
; point to the same memory as the blocks in the source buffer. 
; Operations to modify data in the source buffer will also modify 
; the data in the target buffers. Clearing the source buffer 
; however will not clear the target buffers.

; Command 22: Spread blocks from a buffer across blocks starting 
; at target buffer ID

; VDU 23, 0, &A0, bufferId; 22, targetBufferId;

; Spreads the blocks from a buffer across blocks starting at 
; the target buffer ID.

; This essentially works the same as command 21, and the same 
; notes about copying and moving blocks apply. Blocks are spread 
; in the same manner as commands 17 and 20.

; Command 23: Reverse the order of blocks in a buffer

; VDU 23, 0, &A0, bufferId; 23

; Reverses the order of the blocks in a buffer.
; Command 24: Reverse the order of data of blocks within a buffer

; VDU 23, 0, &A0, bufferId; 24, options, [valueSize;] [chunkSize;]

; Reverses the order of the data within the blocks of a buffer. 
; The options parameter is an 8-bit value that can have bits set 
; to modify the behaviour of the operation. The following bits 
; are defined:
; Bit value 	Description
; 1 	Values are 16-bits in size
; 2 	Values are 32-bits in size
; 3 (1+2) 	If both value size bits are set, then the value size is sent as a 16-bit value
; 4 	Reverse data of the value size within chunk of data of the specified size, sent as a 16-bit value
; 8 	Reverse blocks

; These modifiers can be combined together to modify the behaviour 
; of the operation.

; If no value size is set in the options (i.e. the value of the 
; bottom two bits of the options is zero) then the value size is 
; assumed to be 8-bits.

; It is probably easiest to understand what this operation is 
; capable of by going through some examples of how it can be used 
; to manipulate bitmaps. The VDP supports two different formats 
; of color bitmap, either RGBA8888 which uses 4-bytes per pixel, 
; i.e. 32-bit values, or RGBA2222 which uses a single byte per 
; pixel.

; The simplest example is rotating an RGBA2222 bitmap by 180 
; degrees, which can be done by just reversing the order of 
; bytes in the buffer:

; VDU 23, 0, &A0, bufferId; 24, 0

; Rotating an RGBA8888 bitmap by 180 degrees is in principle a 
; little more complex, as each pixel is made up of 4 bytes. 
; However with this command it is still a simple operation, as 
; we can just reverse the order of the 32-bit values that make 
; up the bitmap by using an options value of 2:

; VDU 23, 0, &A0, bufferId; 24, 2

; Mirroring a bitmap around the x-axis is a matter of reversing 
; the order of rows of pixels. To do this we can set a custom 
; value size that corresponds to our bitmap width. For an RGBA2222 
; bitmap we can just set a custom value size to our bitmap width:

; VDU 23, 0, &A0, bufferId; 24, 3, width

; As an RGBA8888 bitmap uses 4 bytes per pixel we need to multiply 
; our width by 4:

; VDU 23, 0, &A0, bufferId; 24, 3, width * 4

; To mirror a bitmap around the y-axis, we need to reverse the 
; order of pixels within each row. For an RGBA2222 bitmap we can 
; just set a custom chunk size to our bitmap width:

; VDU 23, 0, &A0, bufferId; 24, 4, width

; For an RGBA8888 bitmap we need to set our options to indicate 
; 32-bit values as well as a custom chunk size:

; VDU 23, 0, &A0, bufferId; 24, 6, width * 4

; Command 25: Copy blocks from multiple buffers by reference

; VDU 23, 0, &A0, targetBufferId; 25, sourceBufferId1; sourceBufferId2; ...; 65535;

; This command is essentially a version of command 13 that copies 
; blocks by reference rather than by value. The parameters for 
; this command are the same as for command 13, and the same rules 
; apply.

; If the target buffer is included in the list of source buffers 
; then it will be skipped to prevent a reference loop.

; Copying by reference means that the blocks in the target buffer 
; will point to the same memory as the blocks in the source 
; buffers. Operations to modify data blocks in the source buffers 
; will therefore also modify those blocks in the target buffer. 
; Clearing the source buffers will not clear the target buffer - 
; it will still point to the original data blocks. Data blocks 
; are only freed from memory when no buffers are left with any 
; references to them.

; Buffers that get consolidated become new blocks, so will lose 
; their links to the original blocks, thus after a “consolidate” 
; operation modifications to the original blocks will no longer be 
; reflected in the consolidated buffer.

; This command is useful to construct a single buffer from multiple 
; sources without the copy overhead, which can be costly. For 
; example, this can be useful for constructing a bitmap from 
; multiple constituent parts before consolidating it into a 
; single block. In such an example, using command 13 instead 
; would first make a copy of the contents of the source buffers, 
; and then consolidate them into a single block. Using this 
; command does not make that first copy, and so would be faster.

; This command is also useful for creating multiple buffers that 
; all point to the same data.

; Command 26: Copy blocks from multiple buffers and consolidate

; VDU 23, 0, &A0, targetBufferId; 26, sourceBufferId1; sourceBufferId2; ...; 65535;
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 
    ; include "../agon_api/asm/vdu_plot.inc"
	; include "../agon_api/asm/vdu_sprites.inc"
	; include "../agon_api/asm/vdp.inc"

; 
; ###########################################
; Included from: ../agon_api/asm/div_168_signed.inc
; ###########################################
; 
; 24-bit integer and 16.8 fixed point division routines
; by Brandon R. Gates (BeeGee747)
; have undergone cursory testing and seem to be generating
; correct results (assuming no overflows) but seem very inefficient,
; so they have been published for review and improvement
; see: https://discord.com/channels/1158535358624039014/1158536711148675072/1212136741608099910
;
; ---------------------------------------------------------
; GLOBAL SCRATCH VARIABLES
; ---------------------------------------------------------
uaf: ds 4 ; 32-bit scratch
uhl: ds 4 ; the extra byte at the end
ubc: ds 4 ; is padding for overflow
ude: ds 4 ; when shifting up registers
uix: ds 4
uiy: ds 4
usp: ds 4
upc: ds 4

; ---------------------------------------------------------
; BEGIN DIVISION ROUTINES
; ---------------------------------------------------------
;
; perform signed division of 16.8 fixed place values
; with an signed 16.8 fixed place result
; inputs: ub.c is dividend,ud.e is divisor
; outputs: uh.l is quotient
; destroys: a,bc
; note: uses carry flag to test for sign of operands and result
;       which can be confusing and should perhaps be changed
; note2: helper functions abs_hlu and neg_hlu have been modified
;       to return accurate flags according to the origional signs 
;       (or zero) of this function's inputs
sdiv168:
; make everything positive and save signs
    push bc         ; get bc to hl
    pop hl          ; for the next call
    call abs_hlu    ; sets sign flag if hlu was negative, zero if zero
    jp z,@is_zero   ; if bc is zero, answer is zero and we're done
    push af         ; save sign of bc
    push hl         ; now put abs(hl)
    pop bc          ; back into bc = abs(bc)
    ex de,hl        ; now we do de same way
    call abs_hlu
    jp z,@div_by_zero  ; if de was zero, answer is undefined and we're done
    ex de,hl        ; hl back to de = abs(de)
; determine sign of result
    jp p,@de_pos    ; sign positive,de is positive
    pop af          ; get back sign of bc
    jp m,@result_pos  ; bc and de negative, result is positive
    jr @result_neg
@de_pos:
    pop af          ; get back sign of bc
    jp p,@result_pos   ; bc and de are both positive so result is positive
                    ; fall through to result_neg
@result_neg:
    xor a           ; zero a and clear carry 
    dec a           ; set sign flag to negative
    jr @do_div      
@result_pos:
    xor a           ; zero a and clear carry 
    inc a           ; set sign flag to negative
                    ; fall through to do_div
@do_div:
    push af         ; save sign of result
    call udiv168
    pop af          ; get back sign of result
    ret p           ; result is positive so nothing to do
    call neg_hlu    ; result is negative so negate it
    ret
@is_zero:           ; result is zero
    xor a           ; sets zero flag, which we want, 
                    ; sets pv flag which we might not (zero is parity even)
                    ; resets all others which is okay
    ret
@div_by_zero:       ; result is undefined, which isn't defined in binary
                    ; so we'll just return zero until i can think of something better
    pop af          ; dummy pop
    xor a           ; sets zero flag, which is ok, 
                    ; sets pv flag which could be interpreted as overflow, which is good
                    ; resets all others which is okay
    ret

; ; perform unsigned division of 16.8 fixed place values
; ; with an unsigned 16.8 fixed place result
; ; inputs: ub.c is dividend,ud.e is divisor
; ; outputs: uh.l is quotient
; ; destroys: a,bc
; udiv168:
; ; get the 16-bit integer part of the quotient
;     ; call div_24
;     call udiv24
;     ; call dumpRegistersHex
; ; load quotient to upper three bytes of output
;     ld (div168_out+1),bc
; ; TODO: THIS MAY BE BUGGED
; ; check remainder for zero, and if it is 
; ; we can skip calculating the fractional part
;     add hl,de
;     or a
;     sbc hl,de 
;     jr nz,@div256
;     xor a
;     jr @write_frac
; ; END TODO
; @div256:
; ; divide divisor by 256
;     push hl ; save remainder
; ; TODO: it feels like this could be more efficient
;     ld (ude),de
;     ld a,d
;     ld (ude),a
;     ld a,(ude+2)
;     ld (ude+1),a
;     xor a
;     ld (ude+2),a
;     ld hl,(ude) ; (just for now, we want it in de eventually)
; ; TODO: THIS MAY BE BUGGED
; ; now we check the shifted divisor for zero, and if it is
; ; we again set the fractional part to zero
;     add hl,de
;     or a
;     sbc hl,de 
;     ex de,hl ; now de is where it's supposed to be
;     pop hl ; get remainder back
; ; TODO: THIS MAY BE BUGGED
;     jr nz,@div_frac
;     xor a
;     jr @write_frac
; ; END TODO
; ; now divide the remainder by the shifted divisor
; @div_frac:
;     push hl ; my kingdom for ld bc,hl
;     pop bc  ; or even ex bc,hl
;     ; call div_24
;     call udiv24
; ; load low byte of quotient to low byte of output
;     ld a,c
; @write_frac:
;     ld (div168_out),a
; ; load hl with return value
;     ld hl,(div168_out)
; ; load a with any overflow
;     ld a,(div168_out+3)
;     ret ; uh.l is the 16.8 result
; div168_out: ds 4 ; the extra byte is for overflow

; perform unsigned division of fixed place values
; with an unsigned 16.8 fixed place result
; inputs: b.c is 8.8 dividend, ud.e is 16.8 divisor
; outputs: uh.l is the 16.8 quotient ub.c is the 16.8 remainder
; destroys: a,bc
udiv168:
; shift dividend left 8 bits
    ld (ubc+1),bc
    xor a
    ld (ubc),a
    ld bc,(ubc)
    call udiv24
; flip-flop outptuts to satisfy downstream consumers
; TODO: this is a hack and should be fixed
; (so says copilot ... but it's not wrong)
    push hl 
    push bc
    pop hl 
    pop bc 
    ret

; this is an adaptation of Div16 extended to 24 bits
; from https://map.grauw.nl/articles/mult_div_shifts.php
; it works by shifting each byte of the dividend left into carry 8 times
; and adding the dividend into hl if the carry is set
; thus hl accumulates a remainder depending on the result of each iteration
; ---------------------------------------------------------
; Divide 24-bit unsigned values 
;   with 24-bit unsigned result
;   and 24-bit remainder
; In: Divide ubc by ude
; Out: ubc = result, uhl = remainder
; Destroys: a,hl,bc
div_24:
    ld hl,0     ; Clear accumulator for remainder
; put dividend in scratch so we can get at all its bytes
    ld (ubc),bc ; scratch ubc also accumulates the quotient
    ld a,(ubc+2); grab the upper byte of the dividend
    ld b,8      ; loop counter for 8 bits in a byte
@loop0:
    rla         ; shift the next bit of dividend into the carry flag
    adc hl,hl   ; shift the remainder left one bit and add carry if any
    sbc hl,de   ; subtract divisor from remainder
    jr nc,@noadd0   ; if no carry,remainder is <= divisor
                ; meaning remainder is divisible by divisor
    add hl,de   ; otherwise add divisor back to remainder
                ; reversing the previous subtraction
@noadd0:
    djnz @loop0 ; repeat for all 8 bits
    rla         ; now we shift a left one more time
    cpl         ; then flip its bits for some reason
    ld (ubc+2),a; magically this is the upper byte of the quotient
    ld a,(ubc+1); now we pick up the middle byte of the dividend
    ld b,8      ; set up the next loop and do it all again ...
@loop1:
    rla
    adc hl,hl
    sbc hl,de
    jr nc,@noadd1
    add hl,de
@noadd1:
    djnz @loop1
    rla
    cpl
    ld (ubc+1),a ; writing the middle byte of quotient
    ld a,(ubc)
    ld b,8
@loop2:          ; compute low byte of quotient
    rla
    adc hl,hl
    sbc hl,de
    jr nc,@noadd2
    add hl,de
@noadd2:
    djnz @loop2
    rla
    cpl
    ld (ubc),a  ; ... write low byte of quotient
    ld bc,(ubc) ; load quotient into bc for return
    ret         ; hl already contains remainder so we're done

; ---------------------------------------------------------
; BEGIN HELPER ROUTINES
; ---------------------------------------------------------
;
; absolute value of hlu
; returns: abs(hlu), flags set according to the incoming sign of hlu:
;         s1,z0,pv0,n1,c0 if hlu was negative
;         s0,z1,pv0,n1,c0 if hlu was zero
;         s0,z0,pv0,n1,c0 if hlu was positive
; destroys: a
abs_hlu:
    add hl,de
    or a
    sbc hl,de 
    jp m,@is_neg
    ret         ; hlu is positive or zero so we're done
@is_neg:
    push af     ; otherwise, save current flags for return
    call neg_hlu ; negate hlu
    pop af      ; get back flags
    ret

; flip the sign of hlu
; inputs: hlu
; returns: 0-hlu, flags set appropriately for the result:
;         s1,z0,pv0,n1,c1 if result is negative
;         s0,z1,pv0,n1,c0 if result is zero
;         s0,z0,pv0,n1,c1 if result is positive
; destroys a
neg_hlu:
    push de     ; save de
    ex de,hl    ; put hl into de
    ld hl,0     ; clear hl
    xor a       ; clear carry
    sbc hl,de   ; 0-hlu = -hlu
    pop de      ; get de back
    ret         ; easy peasy

; -----------------------------------------------------------------------
; https://github.com/sijnstra/agon-projects/blob/main/calc24/arith24.asm
;------------------------------------------------------------------------
;  arith24.asm 
;  24-bit ez80 arithmetic routines
;  Copyright (c) Shawn Sijnstra 2024
;  MIT license
;
;  This library was created as a tool to help make ez80
;  24-bit native assembly routines for simple mathematical problems
;  more widely available.
;  
;------------------------------------------------------------------------

;------------------------------------------------------------------------
; umul24:	HLU = BCU*DEU (unsigned)
; Preserves AF, BCU, DEU
; Uses a fast multiply routine.
;------------------------------------------------------------------------
; modified to take BCU as multiplier instead of HLU
umul24:
	; push	DE 
	; push	BC
	; push	AF	
	; push	HL
	; pop		BC
    ld	 	a,24 ; No. of bits to process 
    ld	 	hl,0 ; Result
umul24_lp:
	add	hl,hl
	ex	de,hl
	add	hl,hl
	ex	de,hl
	jr	nc,umul24_nc
	add	hl,bc
umul24_nc: 
	dec	a
	jr	nz,umul24_lp
    dec bc ; debug
	; pop	af
	; pop	bc
	; pop	de
	ret


;------------------------------------------------------------------------
; udiv24
; Unsigned 24-bit division
; Divides BCU by DEU. Gives result in BCU, remainder in HLU.
; 
; Uses AF BC DE HL
; Uses Restoring Division algorithm
;------------------------------------------------------------------------
; modified to take BCU as dividend instead of HLU
; and give BCU as quotient instead of DEU
; -----------------------------------------------------------------------
udiv24:
	; push	hl
	; pop		bc	;move dividend to BCU
	ld		hl,0	;result
	and		a
	sbc		hl,de	;test for div by 0
	ret		z		;it's zero, carry flag is clear
	add		hl,de	;HL is 0 again
	ld		a,24	;number of loops through.
udiv1:
	push	bc	;complicated way of doing this because of lack of access to top bits
	ex		(sp),hl
	scf
	adc	hl,hl
	ex	(sp),hl
	pop	bc		;we now have bc = (bc * 2) + 1

	adc	hl,hl
	and	a		;is this the bug
	sbc	hl,de
	jr	nc,udiv2
	add	hl,de
;	dec	c
	dec	bc
udiv2:
	dec	a
	jr	nz,udiv1
	scf		;flag used for div0 error
	; push	bc
	; pop		de	;remainder
	ret



;------------------------------------------------------------------------
; neg24
; Returns: HLU = 0-HLU
; preserves all other registers
;------------------------------------------------------------------------
neg24:
	push	de
	ex		de,hl
	ld		hl,0
	or		a
	sbc		hl,de
	pop		de
	ret

;------------------------------------------------------------------------
; or_hlu_deu: 24 bit bitwise OR
; Returns: hlu = hlu OR deu
; preserves all other registers
;------------------------------------------------------------------------
or_hlu_deu:
	ld	(bitbuf1),hl
	ld	(bitbuf2),de
	push	de	;preserve DEU
	push	bc	;preserve BCU
	ld		b,3
	ld	hl,bitbuf1
	ld	de,bitbuf1
orloop_24:
	ld	a,(de)
	or	(hl)
	ld	(de),a
	inc	de
	inc	hl
	djnz	orloop_24
	ld	hl,(bitbuf2)
	pop		bc	;restore BC
	pop		de	;restore DE

;------------------------------------------------------------------------
; and_hlu_deu: 24 bit bitwise AND
; Returns: hlu = hlu AND deu
; preserves all other registers
;------------------------------------------------------------------------
and_hlu_deu:
	ld	(bitbuf1),hl
	ld	(bitbuf2),de
	push	de	;preserve DEU
	push	bc	;preserve BCU
	ld		b,3
	ld	hl,bitbuf1
	ld	de,bitbuf1
andloop_24:
	ld	a,(de)
	and	(hl)
	ld	(de),a
	inc	de
	inc	hl
	djnz	andloop_24
	ld	hl,(bitbuf2)
	pop		bc	;restore BC
	pop		de	;restore DE

;------------------------------------------------------------------------
; xor_hlu_deu: 24 bit bitwise XOR
; Returns: hlu = hlu XOR deu
; preserves all other registers
;------------------------------------------------------------------------
xor_hlu_deu:
	ld	(bitbuf1),hl
	ld	(bitbuf2),de
	push	de	;preserve DEU
	push	bc	;preserve BCU
	ld		b,3
	ld	hl,bitbuf1
	ld	de,bitbuf1
xorloop_24:
	ld	a,(de)
	xor	(hl)
	ld	(de),a
	inc	de
	inc	hl
	djnz	xorloop_24
	ld	hl,(bitbuf2)
	pop		bc	;restore BC
	pop		de	;restore DE

;------------------------------------------------------------------------
; shl_hlu: 24 bit shift left hlu by deu positions
; Returns: hlu = hlu << deu
;		   de = 0
; NOTE: only considers deu up to 16 bits. 
; preserves all other registers
;------------------------------------------------------------------------
shl_hlu:
	ld		a,d		;up to 16 bit.
	or		e
	ret		z		;we're done
	add		hl,hl	;shift HLU left
	dec		de
	jr		shl_hlu

;------------------------------------------------------------------------
; shr_hlu: 24 bit shift right hlu by deu positions
; Returns: hlu = hlu >> deu
;		   de = 0
; NOTE: only considers deu up to 16 bits. 
; preserves all other registers
;------------------------------------------------------------------------
shr_hlu:
	ld		(bitbuf1),hl
	ld		hl,bitbuf1+2
shr_loop:
	ld		a,d		;up to 16 bit.
	or		e
	jr		z,shr_done		;we're done
;carry is clear from or instruction
	rr		(hl)
	dec		hl
	rr		(hl)
	dec		hl
	rr		(hl)
	inc		hl
	inc		hl
	dec		de
	jr		shr_loop
shr_done:
	ld		hl,(bitbuf1)	;collect result
	ret

;------------------------------------------------------------------------
; divide hlu by 2, inspired by above
;------------------------------------------------------------------------
hlu_div2:
	ld		(bitbuf1),hl
	ld		hl,bitbuf1+2
	rr		(hl)
	dec		hl
	rr		(hl)
	dec		hl
	rr		(hl)
	inc		hl
	inc		hl
    ld hl,(bitbuf1)
    ret

; this is my little hack to divide by 16
hlu_div16:
    xor a
    add hl,hl
    rla
    add hl,hl
    rla
    add hl,hl
    rla
    add hl,hl
    rla
    ld (@scratch),hl
    ld (@scratch+3),a
    ld hl,(@scratch+1) 
    ret
@scratch: ds 4

;------------------------------------------------------------------------
; Scratch area for calculations
;------------------------------------------------------------------------
bitbuf1:	dw24	0	;bit manipulation buffer 1
bitbuf2:	dw24	0	;bit manipulation buffer 2


; -----------------------------------------------------------------------
; EEMES TUTORIALS
; -----------------------------------------------------------------------
; https://tutorials.eeems.ca/Z80ASM/part4.htm
; DEHL=BC*DE
Mul16:                           
    ld hl,0
    ld a,16
Mul16Loop:
    add hl,hl
    rl e
    rl d
    jp nc,NoMul16
    add hl,bc
    jp nc,NoMul16
    inc de
NoMul16:
    dec a
    jp nz,Mul16Loop
    ret

; DEUHLU=BCU*DEU
umul2448:                           
    ld hl,0
    ld a,24
umul2448Loop:
    add hl,hl
    ex de,hl
    adc hl,hl
    ex de,hl
    jp nc,Noumul2448
    add hl,bc
    jp nc,Noumul2448
    inc de
Noumul2448:
    dec a
    jp nz,umul2448Loop
    ret

umul168:
    call umul2448

    ; call dumpUDEUHLHex

; UDEU.HL is the 32.16 fixed result
; we want UH.L to be the 16.8 fixed result
; so we divide by 256 by shiftng down a byte
; easiest way is to write deu and hlu to scratch
    ld (umul168out+3),de
    ld (umul168out),hl
; then load hlu from scratch shfited forward a byte
    ld hl,(umul168out+1)
    ld a,(umul168out+5) ; send a back with any overflow
    ret
umul168out: ds 6

; perform signed multiplication of 16.8 fixed place values
; with an signed 16.8 fixed place result
; inputs: ub.c and ud.e are the operands
; outputs: uh.l is the product
; destroys: a,bc
; TODO: make flags appropriate to the sign of the result
smul168:
; make everything positive and save signs
    push bc         ; get bc to hl
    pop hl          ; for the next call
    call abs_hlu    ; sets sign flag if ubc was negative, zero if zero

    ; call dumpFlags ; passes

    jp z,@is_zero   ; if bc is zero, answer is zero and we're done
    push af         ; save sign of bc
    push hl         ; now put abs(hl)
    pop bc          ; back into bc = abs(bc)
    ex de,hl        ; now we do de same way
    call abs_hlu    ; sets sign flag if ude was negative, zero if zero

    ; call dumpFlags ; passes

    jp z,@is_zero  ; if de was zero, answer is zero and we're done
    ex de,hl        ; hl back to de = abs(de)
; determine sign of result
    jp p,@de_pos    ; sign positive,de is positive

    ; call dumpFlags ; correctly doesnt make it here

    pop af          ; get back sign of bc

    ; call dumpFlags ; correctly doesn't make it here

    jp m,@result_pos  ; bc and de negative, result is positive

    ; call dumpFlags  ; corectly doesn't make it here

    jr @result_neg
@de_pos:
    pop af          ; get back sign of bc

    ; call dumpFlags  ; passes

    jp p,@result_pos   ; bc and de are both positive so result is positive

    ; call dumpFlags ; correctly makes it here

                    ; fall through to result_neg
@result_neg:
    xor a           ; zero a and clear carry 
    dec a           ; set sign flag to negative

    ; call dumpFlags ; passes

    jr @do_mul      
@result_pos:
    xor a           ; zero a and clear carry 
    inc a           ; set sign flag to positive
                    ; fall through to do_mul

    ; call dumpFlags ; correctly doesn't make it here

@do_mul:
    push af         ; save sign of result
    call umul168
    pop af          ; get back sign of result

    ; call dumpFlags ; passes

    ret p           ; result is positive so nothing to do

    ; call dumpRegistersHex ; passes

    call neg_hlu    ; result is negative so negate it

    ; call dumpRegistersHex ; passes
    ret
@is_zero:           ; result is zero
    xor a           ; sets zero flag, which we want, 
                    ; sets pv flag which we might not (zero is parity even)
                    ; resets all others which is okay
    ret
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 

; 
; ###########################################
; Included from: ../agon_api/asm/maths24.inc
; ###########################################
; 
; http://www.z80.info/pseudo-random.txt
rand_8:
    push bc
    ld a,(r_seed)
    ld c,a 

    rrca ; multiply by 32
    rrca
    rrca
    xor 0x1f

    add a,c
    sbc a,255 ; carry

    ld (r_seed),a
    pop bc
    ret
r_seed: defb $50

; tests the sign of 24-bit register hlu
; returns: a in [-1,0,1]
;   sign and zero flags as expected
;   hl is untouched
; GPT-4 wrote most of this. the or l was inspired. it did bit 7,a instead of h
; and it left the zero flag set after ld a,1,which i fixed by anding it
get_sign_hlu:
    ; Load the upper byte of HLU into A
    push hl
    ld ix,0
    add ix,sp
    ld a,(ix+2)
    pop hl
    
    or l                ; OR with the low byte to check if HL is zero
    ret z               ; Return if HL is zero

    ld a,-1             ; Send A back as -1 if the sign flag is set
    bit 7,h            ; Test the sign bit (7th bit) of the high byte
    ret nz              ; If set,HL is negative,return with the sign flag set

    ld a,1             ; Otherwise,HL is positive
    and a               ; Reset the zero flag
    ret                 ; Return with A set to 1

; 16.8 fixed inputs / outputs
; takes: uh.l as angle in degrees 256
;        ud.e as radius
; returns ub.c as dx, ud.e as dy 
;        displacements from origin (0,0)
; destroys: everything except indexes
polar_to_cartesian:
; back up input parameters
    ld (uhl),hl
    ld (ude),de
; compute dx = sin(uh.l) * ud.e
    call sin168
    push hl
    pop bc ; ub.c = sin(uh.l)
	ld de,(ude) ; get radius back
	call smul168 ; uh.l = ub.c * ud.e = dx
    push hl ; store dx for output
; compute dy = -cos(uh.l) * ud.e
    ld hl,(uhl)
    call cos168 
	call neg_hlu ; invert dy for screen coords convention
    push hl 
    pop bc ; ub.c = -cos(uh.l)
    ld de,(ude) ; get radius back
    call smul168 ; uh.l = ub.c * ud.e = dy
    ex de,hl    ; de = dy for output
    pop bc      ; bc = dx for output
; and out
    ret

; fixed 16.8 routine
; cos(uh.l) --> uh.l
; destroys: de
cos168:
; for cos we simply increment the angle by 90 degrees
; or 0x004000 in 16.8 degrees256
; which makes it a sin problem
    ld de,0x004000
    add hl,de ; modulo 256 happens below
; fall through to sin168
; ---------------------
; fixed 16.8 routine
; sin(uh.l) --> uh.l
; destroys: de
sin168:
; h contains the integer portion of our angle
; we multiply it by three to get our lookup table index
    ld l,3
    mlt hl ; gosh that is handy
    ld de,0 ; clear deu
    ld d,h ; copy hl to de
    ld e,l ; de contains our index
    ld hl,sin_lut_168 ; grab the lut address
    add hl,de ; bump hl by the index
    ld hl,(hl) ; don't try this on a z80!
    ret ; and out

; inputs: ub.c and ud.e are x0 and y0 in 16.8 fixed format
;         ui.x and ui.y are x1 and y1 in 16.8 fixed format
; output: ub.c and ud.e are dx and dy in 16.8 fixed format
;         also populates scratch locations dx168 and dy168
; destroys: a,hl,bc,de
dxy168:
; compute dx = x1-x0
    xor a ; clear carry
    push ix ; move ix to hl via the stack
    pop hl ; hl = x1
    sbc hl,bc ; hl = dx
    ld (dx168),hl ; dx to scratch
; compute dy = y1-y0
    xor a ; clear carry
    push iy ; move iy to hl via the stack
    pop hl ; hl = y1
    sbc hl,de ; hl = dy
    ld (dy168),hl ; dy to scratch
; populate output registers and return
    ex de,hl        ; ud.e = dy
    ld bc,(dx168)   ; ub.c = dx
    ret

; compute the euclidian distance between two cartesian coordinates
; using the formula d = sqrt(dx^2+dy^2
; inputs: ub.c and ud.e are x0 and y0 in 16.8 fixed format
;         ui.x and ui.y are x1 and y1 in 16.8 fixed format
; output; uh.l is the 16.8 fixed format distance
;       dx168/y are the 16.8 fixed format dx and dy
; destroys: a,hl,bc,de
distance168:
; compute dx = x1-x0
    xor a ; clear carry
    push ix ; move ix to hl via the stack
    pop hl ; hl = x1
    sbc hl,bc ; hl = dx
    ld (dx168),hl ; dx to scratch
; ; test dx for overflow
; 	ld de,0x007F00 ; max positive 16.8 value we can square without overflow
; 	ex de,hl
; 	sbc hl,de ; test for overflow
; 	push af ; carry indicates overflow
; compute dy = y1-y0
    xor a ; clear carry
    push iy ; move iy to hl via the stack
    pop hl ; hl = y1
    sbc hl,de ; hl = dy
    ld (dy168),hl ; dy to scratch
; ; test dy for overflow
; 	ld de,0x007F00 ; max positive 16.8 value we can square without overflow
; 	ex de,hl
; 	sbc hl,de ; test for overflow
; 	push af ; carry indicates overflow
; compute dy^2
	ld hl,(dy168)
    call abs_hlu  ; make dy positive so we can use unsigned multiply
    ; call hlu_div2 ; divide hlu by 2 to give us some headroom
    push hl ; load hl/2 to bc via the stack
    pop bc ; bc = dy/2
    ex de,hl ; de = dy/2
    call umul168 ; uh.l = dy^2/2
    push hl ; dy^2/2 to the stack
; compute dx^2
    ld hl,(dx168) ; get back dx
    call abs_hlu  ; make dx positive so we can use unsigned multiply
    ; call hlu_div2 ; divide hlu by 2 to give us some headroom
    push hl ; load hl/2 to bc via the stack
    pop bc ; bc = dx/2
    ex de,hl ; de = dx/2
    call umul168 ; uh.l = dx^2/2
; commpute dy^2+dx^2
    pop de ; get back dx^2/2
    add hl,de ; hl = dx^2/2+dy^2/2
; compute sqrt(dx^2/2+dy^2/2)
    call sqrt168 ; uh.l = distance/2
    ; add hl,hl ; hl = distance
; ; check for overflow
; 	pop af ; get back the overflow flags
; 	sbc a,a ; will be -1 if overflow, 0 if not
; 	ld b,a ; save the overflow flag
; 	pop af ; get back the overflow flags
; 	sbc a,a ; will be -1 if overflow, 0 if not
; 	add a,b ; if a != 0 then we had overflow
;     ret z ; no overflow we're done
; @overflow:
; 	ld hl,0x7FFFFF ; max positive 16.8 fixed value indicates overflow
	ret
@scratch: ds 6
dx168: ds 6
dy168: ds 6

; atan2(ub.c,ud.e) --> uh.l
; inputs: ub.c and ud.e are dx and dy in 16.8 fixed format
;   whether inputs are integers or fractional doesn't matter
;   so long as the sign bit of the upper byte is correct
; output: uh.l is the 16.8 fixed angle in degrees 256
; angles are COMPASS HEADINGS based on
; screen coordinate conventions,where the y axis is flipped
; #E0 315      0       45 #20
;        -x,-y | +x,-y
; #C0 270------+------ 90 #40
;        -x,+y | +x,+y
; #A0 225   180 #80   135 #60
atan2_168game:
; get signs and make everything positive
; get abs(x) and store its original sign
    push bc
    pop hl
    call abs_hlu ; if x was negative this also sets the sign flag
    push hl ; store abs(x)
    pop bc ; bc = abs(x)
    push af ; store sign of x
; get abs(y) and store its original sign
    ex de,hl ; hl = y
    call abs_hlu ; if y was negative this also sets the sign flag
    ex de,hl ; de = abs(y)
    push af ; store sign of y
; if abs(bc) < abs(de),then we do bc/de,otherwise de/bc
; this ensures that our lookup value is between 0 and 1 inclusive
    xor a ; clear the carry flag
    push de
    pop hl
    sbc hl,bc
    push af ; save sign of de - bc
    jp p,@1 ; bc <= de, so we skip ahead
; otherwise we swap bc and de
    push bc
    pop hl
    ex de,hl
    push hl
    pop bc
@1:
; now we're ready to snag our preliminary result
    call atan_168game ; uh.l comes back with prelim result
; now we adjust uh.l based on sign of de - bc
    pop af
    jp p,@2 ; bc <= de,so we skip ahead
    ex de,hl
    ld hl,0x004000 ; 90 degrees
    xor a ; clear the carry flag
    sbc hl,de ; subtract result from 90 degrees
    ; ld de,0 ; prep to clear hlu
    ; ld d,h
    ; ld e,l
    ; ex de,hl ; now we have 0 <= uh.l < 256 in 16.8 fixed format
    ; fall through
@2:
; now the fun part of adjusting the result
; based on which quadrant (x,y) is in
; #E0 315      0       45 #20
;        -x,-y | +x,-y
; #C0 270------+------ 90 #40
;        -x,+y | +x,+y
; #A0 225   180 #80   135 #60
    pop af ; sign of y
    jp z,@y_zero
    jp p,@y_pos
; y neg,check x
    pop af ; sign of x
    jp z,@y_neg_x_zero
    jp p,@y_neg_x_pos
; y neg,x neg
; angle is 270-360
; negating the intermediate does the trick
    call neg_hlu
    jr @zero_hlu

@y_neg_x_zero:
; y neg,x zero
; angle is 0
    ld hl,0
    ret
@y_neg_x_pos:
; y neg,x pos
; angle is 0 to 90
; so we're good
    ret

@y_pos:
    pop af ; sign of x
    jp z,@y_pos_x_zero
    jp p,@y_pos_x_pos
; y pos,x neg
; angle is 180-270
; so we add 180 to intermediate
    ld de,0x008000
    add hl,de
    jr @zero_hlu
@y_pos_x_zero:
; y pos,x zero
; angle is 180
    ld hl,0x008000
    ret
@y_pos_x_pos:
; y pos,x pos
; angle is 90-180
; neg the intermediate and add 180 degrees
    call neg_hlu
    ld de,0x008000
    add hl,de
    jr @zero_hlu

@y_zero:
    pop af ; sign of x
    jp m,@y_zero_x_neg
; y zero,x pos
; angle is 90,nothing to do
    ret
@y_zero_x_neg:
; y zero ,x neg
; angle is 270
    ld hl,0x00C000
    ret
@zero_hlu:
    xor a
    ld (@scratch),hl
    ld (@scratch+2),a
    ld hl,(@scratch)
    ret
@scratch: ds 6

; inputs: ub.c and ud.e are dx and dy in 16.8 fixed format
; output: uh.l is the 16.8 fixed format angle
; destroys: a,hl,bc,de
; the following note was written by github copilot:
; note: this routine is a bit of a hack
;      but it works
;      and it's fast
;      and it's small
;      and it's accurate
;      and it's easy to understand
;      and it's easy to modify
;      and it's easy to use
;      and it's easy to remember
;      and it's easy to love
;      and it's easy to hate
;      and it's easy to ignore
;      and it's easy to forget
;      and it's easy to remember
;      and it's easy to forget
;      and it's easy to remember
;      (ok the bot is stuck in a loop)
; REAL NOTE: only works for angles from 0 to 45 degrees
;   use atan2_168 (which calls this proc) to handle the full 360 degrees
atan_168game:
; because we use compass headings instead of geometric angles
; we compute dx/dy which is 1/tan(theta) in the maths world
; we can do faster unsigned division here because we know dx and dy are positive
	call udiv168 ; uh.l = dx/dy	
; ; TODO: IMPLEMENT THIS, RIGHT NOW IS IS BUGGED
; ; test uh.l for 0
;     add hl,de
;     or a
;     sbc hl,de 
;     jr z,@is_zero
; ; test uh.l for 1
;     xor a ; clear carry
;     ex de,hl
;     ld hl,0x000100 ; 1 in 16.8 fixed format
;     sbc hl,de
;     jr z,@is_45
; ; END TODO

; no special cases so we move on
; l contains the fractional portion of tan(uh.l)
; we multiply it by three to get our lookup table index
    ld h,3
    mlt hl ; gosh that is handy
    ld de,0 ; clear deu
    ld d,h ; copy hl to de
    ld e,l ; de contains our index
    ld hl,atan_lut_168 ; grab the lut address
    add hl,de ; bump hl by the index
    ld hl,(hl) ; don't try this on a z80!
    ret ; and out
@is_45:
    ld hl,0x002000 ; 45 degrees decimal
    ret
; for the case tan(0)
@is_zero:
    ld hl,0x000000
    ret

; Expects  ADL mode
; Inputs:  UH.L
; Outputs: UH.L is the 16.8 square root
;          UD.E is the difference inputHL-DE^2
;          c flag reset  
sqrt168:
    call sqrt24
    ex de,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ret

; Expects  ADL mode
; Inputs:  HL
; Outputs: DE is the integer square root
;          HL is the difference inputHL-DE^2
;          c flag reset 
sqrt24:
    xor a
    ld b,l
    push bc
    ld b,a
    ld d,a
    ld c,a
    ld l,a
    ld e,a

    ;Iteration 1
    add hl,hl
    rl c
    add hl,hl
    rl c
    sub c
    jr nc,$+6
    inc e
    inc e
    cpl
    ld c,a

    ;Iteration 2
    add hl,hl
    rl c
    add hl,hl
    rl c
    rl e
    ld a,e
    sub c
    jr nc,$+6
    inc e
    inc e
    cpl
    ld c,a

    ;Iteration 3
    add hl,hl
    rl c
    add hl,hl
    rl c
    rl e
    ld a,e
    sub c
    jr nc,$+6
    inc e
    inc e
    cpl
    ld c,a

    ;Iteration 4
    add hl,hl
    rl c
    add hl,hl
    rl c
    rl e
    ld a,e
    sub c
    jr nc,$+6
    inc e
    inc e
    cpl
    ld c,a

    ;Iteration 5
    add hl,hl
    rl c
    add hl,hl
    rl c
    rl e
    ld a,e
    sub c
    jr nc,$+6
    inc e
    inc e
    cpl
    ld c,a

    ;Iteration 6
    add hl,hl
    rl c
    add hl,hl
    rl c
    rl e
    ld a,e
    sub c
    jr nc,$+6
    inc e
    inc e
    cpl
    ld c,a

    ;Iteration 7
    add hl,hl
    rl c
    add hl,hl
    rl c
    rl b
    ex de,hl
    add hl,hl
    push hl
    sbc hl,bc
    jr nc,$+8
    ld a,h
    cpl
    ld b,a
    ld a,l
    cpl
    ld c,a
    pop hl
    jr nc,$+4
    inc hl
    inc hl
    ex de,hl

    ;Iteration 8
    add hl,hl
    ld l,c
    ld h,b
    adc hl,hl
    adc hl,hl
    ex de,hl
    add hl,hl
    sbc hl,de
    add hl,de
    ex de,hl
    jr nc,$+6
    sbc hl,de
    inc de
    inc de

    ;Iteration 9
    pop af
    rla
    adc hl,hl
    rla
    adc hl,hl
    ex de,hl
    add hl,hl
    sbc hl,de
    add hl,de
    ex de,hl
    jr nc,$+6
    sbc hl,de
    inc de
    inc de

    ;Iteration 10
    rla
    adc hl,hl
    rla
    adc hl,hl
    ex de,hl
    add hl,hl
    sbc hl,de
    add hl,de
    ex de,hl
    jr nc,$+6
    sbc hl,de
    inc de
    inc de

    ;Iteration 11
    rla
    adc hl,hl
    rla
    adc hl,hl
    ex de,hl
    add hl,hl
    sbc hl,de
    add hl,de
    ex de,hl
    jr nc,$+6
    sbc hl,de
    inc de
    inc de

    ;Iteration 11
    rla
    adc hl,hl
    rla
    adc hl,hl
    ex de,hl
    add hl,hl
    sbc hl,de
    add hl,de
    ex de,hl
    jr nc,$+6
    sbc hl,de
    inc de
    inc de

    rr d
    rr e
    ret

sin_lut_168:
	dl 0x000000 ; 0.000 00, 0.000
	dl 0x000006 ; 1.406 01, 0.025
	dl 0x00000C ; 2.813 02, 0.049
	dl 0x000012 ; 4.219 03, 0.074
	dl 0x000019 ; 5.625 04, 0.098
	dl 0x00001F ; 7.031 05, 0.122
	dl 0x000025 ; 8.438 06, 0.147
	dl 0x00002B ; 9.844 07, 0.171
	dl 0x000031 ; 11.250 08, 0.195
	dl 0x000038 ; 12.656 09, 0.219
	dl 0x00003E ; 14.063 0A, 0.243
	dl 0x000044 ; 15.469 0B, 0.267
	dl 0x00004A ; 16.875 0C, 0.290
	dl 0x000050 ; 18.281 0D, 0.314
	dl 0x000056 ; 19.688 0E, 0.337
	dl 0x00005C ; 21.094 0F, 0.360
	dl 0x000061 ; 22.500 10, 0.383
	dl 0x000067 ; 23.906 11, 0.405
	dl 0x00006D ; 25.313 12, 0.428
	dl 0x000073 ; 26.719 13, 0.450
	dl 0x000078 ; 28.125 14, 0.471
	dl 0x00007E ; 29.531 15, 0.493
	dl 0x000083 ; 30.938 16, 0.514
	dl 0x000088 ; 32.344 17, 0.535
	dl 0x00008E ; 33.750 18, 0.556
	dl 0x000093 ; 35.156 19, 0.576
	dl 0x000098 ; 36.563 1A, 0.596
	dl 0x00009D ; 37.969 1B, 0.615
	dl 0x0000A2 ; 39.375 1C, 0.634
	dl 0x0000A7 ; 40.781 1D, 0.653
	dl 0x0000AB ; 42.188 1E, 0.672
	dl 0x0000B0 ; 43.594 1F, 0.690
	dl 0x0000B5 ; 45.000 20, 0.707
	dl 0x0000B9 ; 46.406 21, 0.724
	dl 0x0000BD ; 47.813 22, 0.741
	dl 0x0000C1 ; 49.219 23, 0.757
	dl 0x0000C5 ; 50.625 24, 0.773
	dl 0x0000C9 ; 52.031 25, 0.788
	dl 0x0000CD ; 53.438 26, 0.803
	dl 0x0000D1 ; 54.844 27, 0.818
	dl 0x0000D4 ; 56.250 28, 0.831
	dl 0x0000D8 ; 57.656 29, 0.845
	dl 0x0000DB ; 59.063 2A, 0.858
	dl 0x0000DE ; 60.469 2B, 0.870
	dl 0x0000E1 ; 61.875 2C, 0.882
	dl 0x0000E4 ; 63.281 2D, 0.893
	dl 0x0000E7 ; 64.688 2E, 0.904
	dl 0x0000EA ; 66.094 2F, 0.914
	dl 0x0000EC ; 67.500 30, 0.924
	dl 0x0000EE ; 68.906 31, 0.933
	dl 0x0000F1 ; 70.313 32, 0.942
	dl 0x0000F3 ; 71.719 33, 0.950
	dl 0x0000F4 ; 73.125 34, 0.957
	dl 0x0000F6 ; 74.531 35, 0.964
	dl 0x0000F8 ; 75.938 36, 0.970
	dl 0x0000F9 ; 77.344 37, 0.976
	dl 0x0000FB ; 78.750 38, 0.981
	dl 0x0000FC ; 80.156 39, 0.985
	dl 0x0000FD ; 81.563 3A, 0.989
	dl 0x0000FE ; 82.969 3B, 0.992
	dl 0x0000FE ; 84.375 3C, 0.995
	dl 0x0000FF ; 85.781 3D, 0.997
	dl 0x0000FF ; 87.188 3E, 0.999
	dl 0x0000FF ; 88.594 3F, 1.000
	dl 0x000100 ; 90.000 40, 1.000
	dl 0x0000FF ; 91.406 41, 1.000
	dl 0x0000FF ; 92.813 42, 0.999
	dl 0x0000FF ; 94.219 43, 0.997
	dl 0x0000FE ; 95.625 44, 0.995
	dl 0x0000FE ; 97.031 45, 0.992
	dl 0x0000FD ; 98.438 46, 0.989
	dl 0x0000FC ; 99.844 47, 0.985
	dl 0x0000FB ; 101.250 48, 0.981
	dl 0x0000F9 ; 102.656 49, 0.976
	dl 0x0000F8 ; 104.063 4A, 0.970
	dl 0x0000F6 ; 105.469 4B, 0.964
	dl 0x0000F4 ; 106.875 4C, 0.957
	dl 0x0000F3 ; 108.281 4D, 0.950
	dl 0x0000F1 ; 109.688 4E, 0.942
	dl 0x0000EE ; 111.094 4F, 0.933
	dl 0x0000EC ; 112.500 50, 0.924
	dl 0x0000EA ; 113.906 51, 0.914
	dl 0x0000E7 ; 115.313 52, 0.904
	dl 0x0000E4 ; 116.719 53, 0.893
	dl 0x0000E1 ; 118.125 54, 0.882
	dl 0x0000DE ; 119.531 55, 0.870
	dl 0x0000DB ; 120.938 56, 0.858
	dl 0x0000D8 ; 122.344 57, 0.845
	dl 0x0000D4 ; 123.750 58, 0.831
	dl 0x0000D1 ; 125.156 59, 0.818
	dl 0x0000CD ; 126.563 5A, 0.803
	dl 0x0000C9 ; 127.969 5B, 0.788
	dl 0x0000C5 ; 129.375 5C, 0.773
	dl 0x0000C1 ; 130.781 5D, 0.757
	dl 0x0000BD ; 132.188 5E, 0.741
	dl 0x0000B9 ; 133.594 5F, 0.724
	dl 0x0000B5 ; 135.000 60, 0.707
	dl 0x0000B0 ; 136.406 61, 0.690
	dl 0x0000AB ; 137.813 62, 0.672
	dl 0x0000A7 ; 139.219 63, 0.653
	dl 0x0000A2 ; 140.625 64, 0.634
	dl 0x00009D ; 142.031 65, 0.615
	dl 0x000098 ; 143.438 66, 0.596
	dl 0x000093 ; 144.844 67, 0.576
	dl 0x00008E ; 146.250 68, 0.556
	dl 0x000088 ; 147.656 69, 0.535
	dl 0x000083 ; 149.063 6A, 0.514
	dl 0x00007E ; 150.469 6B, 0.493
	dl 0x000078 ; 151.875 6C, 0.471
	dl 0x000073 ; 153.281 6D, 0.450
	dl 0x00006D ; 154.688 6E, 0.428
	dl 0x000067 ; 156.094 6F, 0.405
	dl 0x000061 ; 157.500 70, 0.383
	dl 0x00005C ; 158.906 71, 0.360
	dl 0x000056 ; 160.313 72, 0.337
	dl 0x000050 ; 161.719 73, 0.314
	dl 0x00004A ; 163.125 74, 0.290
	dl 0x000044 ; 164.531 75, 0.267
	dl 0x00003E ; 165.938 76, 0.243
	dl 0x000038 ; 167.344 77, 0.219
	dl 0x000031 ; 168.750 78, 0.195
	dl 0x00002B ; 170.156 79, 0.171
	dl 0x000025 ; 171.563 7A, 0.147
	dl 0x00001F ; 172.969 7B, 0.122
	dl 0x000019 ; 174.375 7C, 0.098
	dl 0x000012 ; 175.781 7D, 0.074
	dl 0x00000C ; 177.188 7E, 0.049
	dl 0x000006 ; 178.594 7F, 0.025
	dl 0x000000 ; 180.000 80, 0.000
	dl 0xFFFFFA ; 181.406 81, -0.025
	dl 0xFFFFF4 ; 182.813 82, -0.049
	dl 0xFFFFEE ; 184.219 83, -0.074
	dl 0xFFFFE7 ; 185.625 84, -0.098
	dl 0xFFFFE1 ; 187.031 85, -0.122
	dl 0xFFFFDB ; 188.438 86, -0.147
	dl 0xFFFFD5 ; 189.844 87, -0.171
	dl 0xFFFFCF ; 191.250 88, -0.195
	dl 0xFFFFC8 ; 192.656 89, -0.219
	dl 0xFFFFC2 ; 194.063 8A, -0.243
	dl 0xFFFFBC ; 195.469 8B, -0.267
	dl 0xFFFFB6 ; 196.875 8C, -0.290
	dl 0xFFFFB0 ; 198.281 8D, -0.314
	dl 0xFFFFAA ; 199.688 8E, -0.337
	dl 0xFFFFA4 ; 201.094 8F, -0.360
	dl 0xFFFF9F ; 202.500 90, -0.383
	dl 0xFFFF99 ; 203.906 91, -0.405
	dl 0xFFFF93 ; 205.313 92, -0.428
	dl 0xFFFF8D ; 206.719 93, -0.450
	dl 0xFFFF88 ; 208.125 94, -0.471
	dl 0xFFFF82 ; 209.531 95, -0.493
	dl 0xFFFF7D ; 210.938 96, -0.514
	dl 0xFFFF78 ; 212.344 97, -0.535
	dl 0xFFFF72 ; 213.750 98, -0.556
	dl 0xFFFF6D ; 215.156 99, -0.576
	dl 0xFFFF68 ; 216.563 9A, -0.596
	dl 0xFFFF63 ; 217.969 9B, -0.615
	dl 0xFFFF5E ; 219.375 9C, -0.634
	dl 0xFFFF59 ; 220.781 9D, -0.653
	dl 0xFFFF55 ; 222.188 9E, -0.672
	dl 0xFFFF50 ; 223.594 9F, -0.690
	dl 0xFFFF4B ; 225.000 A0, -0.707
	dl 0xFFFF47 ; 226.406 A1, -0.724
	dl 0xFFFF43 ; 227.813 A2, -0.741
	dl 0xFFFF3F ; 229.219 A3, -0.757
	dl 0xFFFF3B ; 230.625 A4, -0.773
	dl 0xFFFF37 ; 232.031 A5, -0.788
	dl 0xFFFF33 ; 233.438 A6, -0.803
	dl 0xFFFF2F ; 234.844 A7, -0.818
	dl 0xFFFF2C ; 236.250 A8, -0.831
	dl 0xFFFF28 ; 237.656 A9, -0.845
	dl 0xFFFF25 ; 239.063 AA, -0.858
	dl 0xFFFF22 ; 240.469 AB, -0.870
	dl 0xFFFF1F ; 241.875 AC, -0.882
	dl 0xFFFF1C ; 243.281 AD, -0.893
	dl 0xFFFF19 ; 244.688 AE, -0.904
	dl 0xFFFF16 ; 246.094 AF, -0.914
	dl 0xFFFF14 ; 247.500 B0, -0.924
	dl 0xFFFF12 ; 248.906 B1, -0.933
	dl 0xFFFF0F ; 250.313 B2, -0.942
	dl 0xFFFF0D ; 251.719 B3, -0.950
	dl 0xFFFF0C ; 253.125 B4, -0.957
	dl 0xFFFF0A ; 254.531 B5, -0.964
	dl 0xFFFF08 ; 255.938 B6, -0.970
	dl 0xFFFF07 ; 257.344 B7, -0.976
	dl 0xFFFF05 ; 258.750 B8, -0.981
	dl 0xFFFF04 ; 260.156 B9, -0.985
	dl 0xFFFF03 ; 261.563 BA, -0.989
	dl 0xFFFF02 ; 262.969 BB, -0.992
	dl 0xFFFF02 ; 264.375 BC, -0.995
	dl 0xFFFF01 ; 265.781 BD, -0.997
	dl 0xFFFF01 ; 267.188 BE, -0.999
	dl 0xFFFF01 ; 268.594 BF, -1.000
	dl 0xFFFF00 ; 270.000 C0, -1.000
	dl 0xFFFF01 ; 271.406 C1, -1.000
	dl 0xFFFF01 ; 272.813 C2, -0.999
	dl 0xFFFF01 ; 274.219 C3, -0.997
	dl 0xFFFF02 ; 275.625 C4, -0.995
	dl 0xFFFF02 ; 277.031 C5, -0.992
	dl 0xFFFF03 ; 278.438 C6, -0.989
	dl 0xFFFF04 ; 279.844 C7, -0.985
	dl 0xFFFF05 ; 281.250 C8, -0.981
	dl 0xFFFF07 ; 282.656 C9, -0.976
	dl 0xFFFF08 ; 284.063 CA, -0.970
	dl 0xFFFF0A ; 285.469 CB, -0.964
	dl 0xFFFF0C ; 286.875 CC, -0.957
	dl 0xFFFF0D ; 288.281 CD, -0.950
	dl 0xFFFF0F ; 289.688 CE, -0.942
	dl 0xFFFF12 ; 291.094 CF, -0.933
	dl 0xFFFF14 ; 292.500 D0, -0.924
	dl 0xFFFF16 ; 293.906 D1, -0.914
	dl 0xFFFF19 ; 295.313 D2, -0.904
	dl 0xFFFF1C ; 296.719 D3, -0.893
	dl 0xFFFF1F ; 298.125 D4, -0.882
	dl 0xFFFF22 ; 299.531 D5, -0.870
	dl 0xFFFF25 ; 300.938 D6, -0.858
	dl 0xFFFF28 ; 302.344 D7, -0.845
	dl 0xFFFF2C ; 303.750 D8, -0.831
	dl 0xFFFF2F ; 305.156 D9, -0.818
	dl 0xFFFF33 ; 306.563 DA, -0.803
	dl 0xFFFF37 ; 307.969 DB, -0.788
	dl 0xFFFF3B ; 309.375 DC, -0.773
	dl 0xFFFF3F ; 310.781 DD, -0.757
	dl 0xFFFF43 ; 312.188 DE, -0.741
	dl 0xFFFF47 ; 313.594 DF, -0.724
	dl 0xFFFF4B ; 315.000 E0, -0.707
	dl 0xFFFF50 ; 316.406 E1, -0.690
	dl 0xFFFF55 ; 317.813 E2, -0.672
	dl 0xFFFF59 ; 319.219 E3, -0.653
	dl 0xFFFF5E ; 320.625 E4, -0.634
	dl 0xFFFF63 ; 322.031 E5, -0.615
	dl 0xFFFF68 ; 323.438 E6, -0.596
	dl 0xFFFF6D ; 324.844 E7, -0.576
	dl 0xFFFF72 ; 326.250 E8, -0.556
	dl 0xFFFF78 ; 327.656 E9, -0.535
	dl 0xFFFF7D ; 329.063 EA, -0.514
	dl 0xFFFF82 ; 330.469 EB, -0.493
	dl 0xFFFF88 ; 331.875 EC, -0.471
	dl 0xFFFF8D ; 333.281 ED, -0.450
	dl 0xFFFF93 ; 334.688 EE, -0.428
	dl 0xFFFF99 ; 336.094 EF, -0.405
	dl 0xFFFF9F ; 337.500 F0, -0.383
	dl 0xFFFFA4 ; 338.906 F1, -0.360
	dl 0xFFFFAA ; 340.313 F2, -0.337
	dl 0xFFFFB0 ; 341.719 F3, -0.314
	dl 0xFFFFB6 ; 343.125 F4, -0.290
	dl 0xFFFFBC ; 344.531 F5, -0.267
	dl 0xFFFFC2 ; 345.938 F6, -0.243
	dl 0xFFFFC8 ; 347.344 F7, -0.219
	dl 0xFFFFCF ; 348.750 F8, -0.195
	dl 0xFFFFD5 ; 350.156 F9, -0.171
	dl 0xFFFFDB ; 351.563 FA, -0.147
	dl 0xFFFFE1 ; 352.969 FB, -0.122
	dl 0xFFFFE7 ; 354.375 FC, -0.098
	dl 0xFFFFEE ; 355.781 FD, -0.074
	dl 0xFFFFF4 ; 357.188 FE, -0.049
	dl 0xFFFFFA ; 358.594 FF, -0.025

atan_lut_168:
	dl 0x000000 ; 000000, 0.000
	dl 0x000028 ; 000001, 0.224
	dl 0x000051 ; 000002, 0.448
	dl 0x00007A ; 000003, 0.671
	dl 0x0000A2 ; 000004, 0.895
	dl 0x0000CB ; 000005, 1.119
	dl 0x0000F4 ; 000006, 1.343
	dl 0x00011D ; 000007, 1.566
	dl 0x000145 ; 000008, 1.790
	dl 0x00016E ; 000009, 2.013
	dl 0x000197 ; 00000A, 2.237
	dl 0x0001BF ; 00000B, 2.460
	dl 0x0001E8 ; 00000C, 2.684
	dl 0x000211 ; 00000D, 2.907
	dl 0x000239 ; 00000E, 3.130
	dl 0x000262 ; 00000F, 3.353
	dl 0x00028B ; 000010, 3.576
	dl 0x0002B3 ; 000011, 3.799
	dl 0x0002DC ; 000012, 4.022
	dl 0x000304 ; 000013, 4.245
	dl 0x00032D ; 000014, 4.467
	dl 0x000355 ; 000015, 4.690
	dl 0x00037E ; 000016, 4.912
	dl 0x0003A6 ; 000017, 5.134
	dl 0x0003CE ; 000018, 5.356
	dl 0x0003F7 ; 000019, 5.578
	dl 0x00041F ; 00001A, 5.799
	dl 0x000448 ; 00001B, 6.021
	dl 0x000470 ; 00001C, 6.242
	dl 0x000498 ; 00001D, 6.463
	dl 0x0004C0 ; 00001E, 6.684
	dl 0x0004E8 ; 00001F, 6.905
	dl 0x000511 ; 000020, 7.125
	dl 0x000539 ; 000021, 7.345
	dl 0x000561 ; 000022, 7.565
	dl 0x000589 ; 000023, 7.785
	dl 0x0005B1 ; 000024, 8.005
	dl 0x0005D9 ; 000025, 8.224
	dl 0x000601 ; 000026, 8.443
	dl 0x000628 ; 000027, 8.662
	dl 0x000650 ; 000028, 8.881
	dl 0x000678 ; 000029, 9.099
	dl 0x0006A0 ; 00002A, 9.317
	dl 0x0006C7 ; 00002B, 9.535
	dl 0x0006EF ; 00002C, 9.752
	dl 0x000716 ; 00002D, 9.970
	dl 0x00073E ; 00002E, 10.187
	dl 0x000765 ; 00002F, 10.403
	dl 0x00078D ; 000030, 10.620
	dl 0x0007B4 ; 000031, 10.836
	dl 0x0007DB ; 000032, 11.051
	dl 0x000803 ; 000033, 11.267
	dl 0x00082A ; 000034, 11.482
	dl 0x000851 ; 000035, 11.697
	dl 0x000878 ; 000036, 11.911
	dl 0x00089F ; 000037, 12.125
	dl 0x0008C6 ; 000038, 12.339
	dl 0x0008ED ; 000039, 12.553
	dl 0x000913 ; 00003A, 12.766
	dl 0x00093A ; 00003B, 12.978
	dl 0x000961 ; 00003C, 13.191
	dl 0x000987 ; 00003D, 13.403
	dl 0x0009AE ; 00003E, 13.614
	dl 0x0009D4 ; 00003F, 13.825
	dl 0x0009FB ; 000040, 14.036
	dl 0x000A21 ; 000041, 14.247
	dl 0x000A47 ; 000042, 14.457
	dl 0x000A6D ; 000043, 14.666
	dl 0x000A94 ; 000044, 14.876
	dl 0x000ABA ; 000045, 15.085
	dl 0x000AE0 ; 000046, 15.293
	dl 0x000B05 ; 000047, 15.501
	dl 0x000B2B ; 000048, 15.709
	dl 0x000B51 ; 000049, 15.916
	dl 0x000B77 ; 00004A, 16.123
	dl 0x000B9C ; 00004B, 16.329
	dl 0x000BC2 ; 00004C, 16.535
	dl 0x000BE7 ; 00004D, 16.740
	dl 0x000C0C ; 00004E, 16.945
	dl 0x000C32 ; 00004F, 17.150
	dl 0x000C57 ; 000050, 17.354
	dl 0x000C7C ; 000051, 17.558
	dl 0x000CA1 ; 000052, 17.761
	dl 0x000CC6 ; 000053, 17.964
	dl 0x000CEB ; 000054, 18.166
	dl 0x000D0F ; 000055, 18.368
	dl 0x000D34 ; 000056, 18.569
	dl 0x000D58 ; 000057, 18.770
	dl 0x000D7D ; 000058, 18.970
	dl 0x000DA1 ; 000059, 19.170
	dl 0x000DC6 ; 00005A, 19.370
	dl 0x000DEA ; 00005B, 19.569
	dl 0x000E0E ; 00005C, 19.767
	dl 0x000E32 ; 00005D, 19.965
	dl 0x000E56 ; 00005E, 20.163
	dl 0x000E7A ; 00005F, 20.360
	dl 0x000E9E ; 000060, 20.556
	dl 0x000EC1 ; 000061, 20.752
	dl 0x000EE5 ; 000062, 20.947
	dl 0x000F08 ; 000063, 21.142
	dl 0x000F2C ; 000064, 21.337
	dl 0x000F4F ; 000065, 21.531
	dl 0x000F72 ; 000066, 21.724
	dl 0x000F95 ; 000067, 21.917
	dl 0x000FB8 ; 000068, 22.109
	dl 0x000FDB ; 000069, 22.301
	dl 0x000FFE ; 00006A, 22.493
	dl 0x001021 ; 00006B, 22.683
	dl 0x001044 ; 00006C, 22.874
	dl 0x001066 ; 00006D, 23.063
	dl 0x001089 ; 00006E, 23.253
	dl 0x0010AB ; 00006F, 23.441
	dl 0x0010CD ; 000070, 23.629
	dl 0x0010EF ; 000071, 23.817
	dl 0x001111 ; 000072, 24.004
	dl 0x001133 ; 000073, 24.191
	dl 0x001155 ; 000074, 24.376
	dl 0x001177 ; 000075, 24.562
	dl 0x001199 ; 000076, 24.747
	dl 0x0011BA ; 000077, 24.931
	dl 0x0011DC ; 000078, 25.115
	dl 0x0011FD ; 000079, 25.298
	dl 0x00121E ; 00007A, 25.481
	dl 0x00123F ; 00007B, 25.663
	dl 0x001260 ; 00007C, 25.844
	dl 0x001281 ; 00007D, 26.025
	dl 0x0012A2 ; 00007E, 26.206
	dl 0x0012C3 ; 00007F, 26.386
	dl 0x0012E4 ; 000080, 26.565
	dl 0x001304 ; 000081, 26.744
	dl 0x001325 ; 000082, 26.922
	dl 0x001345 ; 000083, 27.100
	dl 0x001365 ; 000084, 27.277
	dl 0x001385 ; 000085, 27.453
	dl 0x0013A5 ; 000086, 27.629
	dl 0x0013C5 ; 000087, 27.805
	dl 0x0013E5 ; 000088, 27.979
	dl 0x001405 ; 000089, 28.154
	dl 0x001424 ; 00008A, 28.327
	dl 0x001444 ; 00008B, 28.501
	dl 0x001463 ; 00008C, 28.673
	dl 0x001483 ; 00008D, 28.845
	dl 0x0014A2 ; 00008E, 29.017
	dl 0x0014C1 ; 00008F, 29.187
	dl 0x0014E0 ; 000090, 29.358
	dl 0x0014FF ; 000091, 29.527
	dl 0x00151E ; 000092, 29.697
	dl 0x00153C ; 000093, 29.865
	dl 0x00155B ; 000094, 30.033
	dl 0x001579 ; 000095, 30.201
	dl 0x001598 ; 000096, 30.368
	dl 0x0015B6 ; 000097, 30.534
	dl 0x0015D4 ; 000098, 30.700
	dl 0x0015F2 ; 000099, 30.865
	dl 0x001610 ; 00009A, 31.030
	dl 0x00162E ; 00009B, 31.194
	dl 0x00164C ; 00009C, 31.357
	dl 0x00166A ; 00009D, 31.520
	dl 0x001687 ; 00009E, 31.682
	dl 0x0016A5 ; 00009F, 31.844
	dl 0x0016C2 ; 0000A0, 32.005
	dl 0x0016DF ; 0000A1, 32.166
	dl 0x0016FC ; 0000A2, 32.326
	dl 0x001719 ; 0000A3, 32.486
	dl 0x001736 ; 0000A4, 32.645
	dl 0x001753 ; 0000A5, 32.803
	dl 0x001770 ; 0000A6, 32.961
	dl 0x00178C ; 0000A7, 33.118
	dl 0x0017A9 ; 0000A8, 33.275
	dl 0x0017C5 ; 0000A9, 33.431
	dl 0x0017E2 ; 0000AA, 33.587
	dl 0x0017FE ; 0000AB, 33.742
	dl 0x00181A ; 0000AC, 33.896
	dl 0x001836 ; 0000AD, 34.050
	dl 0x001852 ; 0000AE, 34.203
	dl 0x00186E ; 0000AF, 34.356
	dl 0x00188A ; 0000B0, 34.509
	dl 0x0018A5 ; 0000B1, 34.660
	dl 0x0018C1 ; 0000B2, 34.811
	dl 0x0018DC ; 0000B3, 34.962
	dl 0x0018F7 ; 0000B4, 35.112
	dl 0x001913 ; 0000B5, 35.262
	dl 0x00192E ; 0000B6, 35.410
	dl 0x001949 ; 0000B7, 35.559
	dl 0x001964 ; 0000B8, 35.707
	dl 0x00197F ; 0000B9, 35.854
	dl 0x001999 ; 0000BA, 36.001
	dl 0x0019B4 ; 0000BB, 36.147
	dl 0x0019CE ; 0000BC, 36.293
	dl 0x0019E9 ; 0000BD, 36.438
	dl 0x001A03 ; 0000BE, 36.582
	dl 0x001A1D ; 0000BF, 36.726
	dl 0x001A37 ; 0000C0, 36.870
	dl 0x001A51 ; 0000C1, 37.013
	dl 0x001A6B ; 0000C2, 37.155
	dl 0x001A85 ; 0000C3, 37.297
	dl 0x001A9F ; 0000C4, 37.439
	dl 0x001AB9 ; 0000C5, 37.579
	dl 0x001AD2 ; 0000C6, 37.720
	dl 0x001AEC ; 0000C7, 37.859
	dl 0x001B05 ; 0000C8, 37.999
	dl 0x001B1E ; 0000C9, 38.137
	dl 0x001B37 ; 0000CA, 38.276
	dl 0x001B50 ; 0000CB, 38.413
	dl 0x001B69 ; 0000CC, 38.550
	dl 0x001B82 ; 0000CD, 38.687
	dl 0x001B9B ; 0000CE, 38.823
	dl 0x001BB4 ; 0000CF, 38.959
	dl 0x001BCC ; 0000D0, 39.094
	dl 0x001BE5 ; 0000D1, 39.228
	dl 0x001BFD ; 0000D2, 39.362
	dl 0x001C16 ; 0000D3, 39.496
	dl 0x001C2E ; 0000D4, 39.629
	dl 0x001C46 ; 0000D5, 39.762
	dl 0x001C5E ; 0000D6, 39.894
	dl 0x001C76 ; 0000D7, 40.025
	dl 0x001C8E ; 0000D8, 40.156
	dl 0x001CA5 ; 0000D9, 40.286
	dl 0x001CBD ; 0000DA, 40.416
	dl 0x001CD5 ; 0000DB, 40.546
	dl 0x001CEC ; 0000DC, 40.675
	dl 0x001D04 ; 0000DD, 40.803
	dl 0x001D1B ; 0000DE, 40.931
	dl 0x001D32 ; 0000DF, 41.059
	dl 0x001D49 ; 0000E0, 41.186
	dl 0x001D60 ; 0000E1, 41.312
	dl 0x001D77 ; 0000E2, 41.438
	dl 0x001D8E ; 0000E3, 41.564
	dl 0x001DA5 ; 0000E4, 41.689
	dl 0x001DBB ; 0000E5, 41.814
	dl 0x001DD2 ; 0000E6, 41.938
	dl 0x001DE9 ; 0000E7, 42.061
	dl 0x001DFF ; 0000E8, 42.184
	dl 0x001E15 ; 0000E9, 42.307
	dl 0x001E2C ; 0000EA, 42.429
	dl 0x001E42 ; 0000EB, 42.551
	dl 0x001E58 ; 0000EC, 42.672
	dl 0x001E6E ; 0000ED, 42.793
	dl 0x001E84 ; 0000EE, 42.913
	dl 0x001E99 ; 0000EF, 43.033
	dl 0x001EAF ; 0000F0, 43.152
	dl 0x001EC5 ; 0000F1, 43.271
	dl 0x001EDA ; 0000F2, 43.390
	dl 0x001EF0 ; 0000F3, 43.508
	dl 0x001F05 ; 0000F4, 43.625
	dl 0x001F1B ; 0000F5, 43.742
	dl 0x001F30 ; 0000F6, 43.859
	dl 0x001F45 ; 0000F7, 43.975
	dl 0x001F5A ; 0000F8, 44.091
	dl 0x001F6F ; 0000F9, 44.206
	dl 0x001F84 ; 0000FA, 44.321
	dl 0x001F99 ; 0000FB, 44.435
	dl 0x001FAD ; 0000FC, 44.549
	dl 0x001FC2 ; 0000FD, 44.662
	dl 0x001FD7 ; 0000FE, 44.775
	dl 0x001FEB ; 0000FF, 44.888
	dl 0x002000 ; 000100, 45.000 only needed for interpolation
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 
; App-specific includes

; 
; ###########################################
; Included from: player.asm
; ###########################################
; 
; ######## GAME STATE VARIABLES #######
; THESE MUST BE IN THIS ORDER FOR new_game TO WORK PROPERLY
player_score: db 0x00,#00,#00 ; bcd
; player current shields,binary
; when < 0 player splodes
; restores to player_max_shields when new ship spawns
player_shields: db 16 ; binary
; max player shields,binary
; can increase with power-ups (todo)
player_max_shields: db 16 ; binary
; when reaches zero,game ends
; can increase based on TODO
player_ships: db 0x03 ; binary

; ######### PLAYER SPRITE PARAMETERS ##########
; uses the same offsets from its table base as the main sprite table:
player_start_variables: ; label marking beginning of table
player_id:               db table_max_records
player_type:             db     0x00 ; 1 bytes currently not used
player_base_bufferId:    dl BUF_SHIP_0L ; 3 bytes bitmap bufferId
player_move_program:     dl 0x000000 ; 3 bytes not currently used
player_collisions:       db     0x00 ; 1 bytes bit 0 set=alive, otherwise dead, bit 1 set=just died
player_dim_x:            db     0x00 ; 1 bytes sprite width in pixels
player_dim_y:            db     0x00 ; 1 bytes sprite height in pixels
player_x:                dl 0x000000 ; 3 bytes 16.8 fractional x position in pixels
player_y:                dl 0x000000 ; 3 bytes 16.8 fractional y position in pixels
player_xvel:             dl 0x000000 ; 3 bytes x-component velocity, 16.8 fixed, pixels
player_yvel:             dl 0x000000 ; 3 bytes y-component velocity, 16.8 fixed, pixels
player_vel:              dl 0x000000 ; 3 bytes velocity px/frame (16.8 fixed)
player_heading:          dl 0x000000 ; 3 bytes sprite movement direction deg256 16.8 fixed
player_orientation:      dl 0x000000 ; 3 bytes not currently used
player_animation:        db     0x00 ; 1 bytes not currently used
player_animation_timer:  db     0x00 ; 1 bytes not currently used
player_move_timer:       db     0x00 ; 1 bytes not currently used
player_move_step:        db     0x00 ; 1 bytes not currently used
player_points:           db     0x00 ; 1 bytes not currently used
player_shield_damage:    db     0x00 ; 1 bytes not currently used
player_end_variables: ; for when we want to traverse this table in reverse

; set initial player position
; inputs: none,everything is hardcoded
; outputs: player_x/y set to bottom-left corner of screen
; destroys: a
player_init:
	ld a,table_max_records ; this is always player spriteId
	call vdu_sprite_select
    call vdu_sprite_clear_frames
    ld hl,BUF_SHIP_0L
    call vdu_sprite_add_buff
    ld hl,BUF_SHIP_1C
    call vdu_sprite_add_buff
    ld hl,BUF_SHIP_2R
    call vdu_sprite_add_buff
    ld bc,0
    ld (player_x),bc
    ld de,0x00DF00
    ld (player_y),de
    call vdu_sprite_move_abs168
    call vdu_sprite_show
    ret

; process player keyboard input, set player bitmap
; velocities and draw player bitmap at updated coordinates
; Inputs: player_x/y set at desired position
; Returns: player bitmap drawn at updated position
; Destroys: probably everything except maybe iy
; NOTE: in mode 9 we draw the ship as a sprite, not a bitmap
; TODO: requires sprite implementation
player_input:
; reset player component velocities to zero as the default
	ld hl,0
	ld (player_xvel),hl
	ld (player_yvel),hl
; make ship the active sprite
    ld a,table_max_records ; this is always player spriteId
    call vdu_sprite_select
; check for keypresses and branch accordingly
; for how this works,see: https://github.com/breakintoprogram/agon-docs/wiki/MOS-API-%E2%80%90-Virtual-Keyboard
    MOSCALL	mos_getkbmap ;ix = pointer to MOS virtual keys table
; we test all four arrow keys and add/subract velocities accordingly
; this handles the case where two opposing movement keys
; are down simultaneously (velocities will net to zero)
; and allows diagonal movement when a vertical and horizontal key are down
; it also allows movement and action keys to be detected simultaneously
; so we can walk and chew gum at the same time
    ld a,1 ; set ship's default animation to center
        ; if left and right are both down a will net to 

@left:
    bit 1,(ix+3) ; keycode 26
    jr z,@right
    ld hl,(player_xvel)
    ld bc,-speed_player
    add hl,bc
    ld (player_xvel),hl
    dec a ; set ship's animation to left
@right:
    bit 1,(ix+15) ; keycode 122
	jr z,@up
    ld hl,(player_xvel)
    ld bc,speed_player
    add hl,bc
    ld (player_xvel),hl
    inc a ; set ship's animation to right
@up:
    bit 1,(ix+7) ; keycode 58
	jr z,@down
    ld hl,(player_yvel)
    ld bc,-speed_player
    add hl,bc
    ld (player_yvel),hl
@down:
    bit 1,(ix+5) ; keycode 42
	jr z,@done_keyboard
    ld hl,(player_yvel)
    ld bc,speed_player
    add hl,bc
    ld (player_yvel),hl
@done_keyboard:
; move player sprite according to velocities set by keypresses
    ld hl,(player_xvel)
; compute new x position
    ld de,(player_x)
    add hl,de ; hl = player_x + player_xvel
    ; check for horizontal screen edge collisions
    ; and adjust coordinate as necessary
; TODO: make this work using 24-bit registers
    ; cp 8 ; 0 + 1/2 bitmap dim_x
    ; jr nc,@check_right ; x >= 8, no adjustment necessary
    ; ld a,8 ; set x to leftmost allowable position
; @check_right:
;     cp 248 ; 256 - 1/2 bitmap dim_x
;     jr c,@x_ok ; x < 248, no adjustment necessary
;     ld a,248 ; set x to rightmost allowable position
@x_ok:
; save the updated drawing coordinate
    ld (player_x),hl
;compute new y position
    ld hl,(player_y)
    ld de,(player_yvel)
    add hl,de ; hl = player_y + player_yvel
; TODO: make this work using 24-bit registers
;     ; check for vertical screen edge collisions
;     ; and adjust coordinate as necessary
;     cp 8 ; 0 + 1/2 bitmap dim_y
;     jr nc,@check_top ; y >= 8, no adjustment necessary
;     ld a,8 ; set y to topmost allowable position
; @check_top:
;     cp 232 ; 240 - 1/2 bitmap dim_y
;     jr c,@y_ok ; y < 248, no adjustment necessary
;     ld a,232 ; set y to bottommost allowable position
@y_ok:
    ld (player_y),hl ; do this here b/c next call destroys hl
; a should land here loaded with the correct frame
    call vdu_sprite_select_frame
; draw player at updated position
    ld bc,(player_x)
	ld de,(player_y)

    ; call dumpRegistersHex

	call vdu_sprite_move_abs168
    
; end player_input
	ret

; ; THE BELOW WORKS WITH THE AGON BUT USES INTEGER COORDINATES 
; ; INSTEAD OF FRACTIONAL
; ; ----------------------------------------------------------------
; ; process player keyboard input, set player bitmap
; ; velocities and draw player bitmap at updated coordinates
; ; Inputs: player_x/y set at desired position
; ; Returns: player bitmap drawn at updated position
; ; Destroys: probably everything except maybe iy
; ; NOTE: in mode 9 we draw the ship as a sprite, not a bitmap
; ; TODO: requires sprite implementation
; player_input:
; ; reset player component velocities to zero as the default
; 	ld hl,0
; 	ld (player_xvel),hl
; 	ld (player_yvel),hl
; ; check for keypresses and branch accordingly
; ; for how this works,see: https://github.com/breakintoprogram/agon-docs/wiki/MOS-API-%E2%80%90-Virtual-Keyboard
;     MOSCALL	mos_getkbmap ;ix = pointer to MOS virtual keys table
; ; we test all four arrow keys and add/subract velocities accordingly
; ; this handles the case where two opposing movement keys
; ; are down simultaneously (velocities will net to zero)
; ; and allows diagonal movement when a vertical and horizontal key are down
; ; it also allows movement and action keys to be detected simultaneously
; ; so we can walk and chew gum at the same time
; @left:
;     bit 1,(ix+3) ; keycode 26
;     jr z,@right
;     ld hl,(player_xvel)
;     ld bc,-3
;     add hl,bc
;     ld (player_xvel),hl
; @right:
;     bit 1,(ix+15) ; keycode 122
; 	jr z,@up
;     ld hl,(player_xvel)
;     ld bc,3
;     add hl,bc
;     ld (player_xvel),hl
; @up:
;     bit 1,(ix+7) ; keycode 58
; 	jr z,@down
;     ld hl,(player_yvel)
;     ld bc,-3
;     add hl,bc
;     ld (player_yvel),hl
; @down:
;     bit 1,(ix+5) ; keycode 42
; 	jr z,@done_keyboard
;     ld hl,(player_yvel)
;     ld bc,3
;     add hl,bc
;     ld (player_yvel),hl
; @done_keyboard:
; ; move player sprite according to velocities set by keypresses
;     ld hl,(player_xvel)
; ; compute new x position
;     ld de,(player_x)
;     add hl,de ; hl = player_x + player_xvel
;     ; check for horizontal screen edge collisions
;     ; and adjust coordinate as necessary
; ; TODO: make this work using 24-bit registers
;     ; cp 8 ; 0 + 1/2 bitmap dim_x
;     ; jr nc,@check_right ; x >= 8, no adjustment necessary
;     ; ld a,8 ; set x to leftmost allowable position
; ; @check_right:
; ;     cp 248 ; 256 - 1/2 bitmap dim_x
; ;     jr c,@x_ok ; x < 248, no adjustment necessary
; ;     ld a,248 ; set x to rightmost allowable position
; @x_ok:
;     ; save the updated drawing coordinate
;     ld (player_x),hl
; ;compute new y position
;     ld hl,(player_y)
;     ld de,(player_yvel)
;     add hl,de ; hl = player_y + player_yvel
; ; TODO: make this work using 24-bit registers
; ;     ; check for vertical screen edge collisions
; ;     ; and adjust coordinate as necessary
; ;     cp 8 ; 0 + 1/2 bitmap dim_y
; ;     jr nc,@check_top ; y >= 8, no adjustment necessary
; ;     ld a,8 ; set y to topmost allowable position
; ; @check_top:
; ;     cp 232 ; 240 - 1/2 bitmap dim_y
; ;     jr c,@y_ok ; y < 248, no adjustment necessary
; ;     ld a,232 ; set y to bottommost allowable position
; @y_ok:
;     ld (player_y),hl
; ; draw player at updated position
;     ld a,table_max_records ; this is always player spriteId
;     call vdu_sprite_select
;     ld hl,(player_xvel) ; we do a cheeky little hack
;     call get_sign_hlu ; to set the proper animation
;     add a,1 ; ...
;     call vdu_sprite_select_frame
;     ld bc,(player_x)
; 	ld de,(player_y) 
; 	call vdu_sprite_move_abs
; ; end player_input
; 	ret


; ###################################################################
; TODO: the below is all stuff from the original code we need to port
; ###################################################################

; kill_player:
; ; set player status to dead
;     xor a; sets all player flags to zero
;     ld (player_collisions),a
; ; deduct a ship from the inventory
;     ld a,(player_ships)
;     dec a
;     ld (player_ships),a
; ; are we out of ships?
;     jp z,game_over
; ; wait a few ticks
;     ld a,32 ; 32-cycle timer ~1/2 second at 60fps
;     ld (player_move_timer),a
; kill_player_loop:
;     call vsync
;     ld a,(player_move_timer)
;     dec a
;     ld (player_move_timer),a
;     jr nz,kill_player_loop 
;     call player_init ; player respawn if timer zero
;     ret ; and out


; player_move:
; ; begin setting player to active sprite
;     ld hl,player
;     ld (sprite_base_bufferId),hl
;     ld hl,0 ; north
;     ld (sprite_heading),hl
;     ld a,#01 ; animation 1 is center,which we set here as a default
;     ld (sprite_animation),a
;     ; we set position here for the time being as a default
;     ; in case the player doesn't move,or is flagged for deletion
;     ld hl,(player_x)
;     ld (sprite_x),hl
;     ld hl,(player_y)
;     ld (sprite_y),hl
; ; did we just die?
;     ld a,(player_collisions)
;     and %00000010 ; zero flag will be set if not dead
;     jr z,player_not_dead
; ; yes we died
;     call kill_player  
;     ret ; done
; ; yay we didn't die
; player_not_dead:
; ; set player movements to zero by default
;     ld hl,0
;     ld (player_xvel),hl
;     ld (player_yvel),hl
; ; do we move it?
;     in a,(#82) ; keyboard
;     or a ; if zero,don't move
;     jr z,player_draw
; ; move it
;     call player_move_calc
; player_draw:
;     call vdu_bmp_select
;     call vdu_bmp_draw
; player_move_done:
;     ; write updated x,y coordinates back to player table
;     ld hl,(sprite_x)
;     ld (player_x),hl
;     ld hl,(sprite_y)
;     ld (player_y),hl
;     ret
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 

; 
; ###########################################
; Included from: tiles.asm
; ###########################################
; 
; ######### TILES ######### 
; TODO: implement buffering of tiles here when there isn't other stuff to do
; tiles_defs: ds 256*16 ; 256 rows of 16 tiles, each tile is a byte
tiles_row_defs: dl 0x000000 ; pointer to current row tiles definitions
tiles_row: db 0 ; decrements each time a row is drawn. level is over when hits zero
                        ; initialize to zero for a maximum of 256 rows in a level
cur_level: db 0
num_levels: equ 2 ; number of levels,duh

; lookup table for level definitions
tiles_levels: dl tiles_level_00,tiles_level_01

; tiles_bufferId: dl 0
tiles_x_plot: dl 0
tiles_y_plot: dl -15


tiles_plot:
; ; NOTE: this is bugged. y1 should be zero to get a 1px-tall viewport
; ;       as written it gves a 2px-tall window which is what we'd expect, 
; ;       but don't want
; ; https://discord.com/channels/1158535358624039014/1158536809916149831/1209571014514712637
; ; set gfx viewport to one scanline to optimise plotting tiles
; 	ld bc,0 ; leftmost x-coord
; 	ld de,0 ; topmost y-coord
; 	ld ix,255 ; rightmost x-coord
; 	ld iy,1 ; bottommost y-coord
; 	call vdu_set_gfx_viewport

    ld hl,0 ; init plotting x-coordinate
    ld (tiles_x_plot),hl
    ld hl,(tiles_row_defs)
	ld b,16 ; loop counter
@loop:
	push bc ; save the loop counter
; read the tile defintion for the current column
    ld a,(hl) ; a has tile definition
    push hl  ; save pointer to tile definition
    ld hl,0 ; hlu is non-zero
    ld l,a ; l is tile defintion
    ld h,0x01 ; hl = 256 + tile index = the tile's bitmapId
    call vdu_buff_select ; tile bitmap buffer is now active

; plot the active bitmap
    ld bc,(tiles_x_plot)
    ld de,(tiles_y_plot)
    call vdu_plot_bmp

; bump x-coords the width of one tile and save it
    ld hl,(tiles_x_plot)
    ld bc,16
    add hl,bc
    ld (tiles_x_plot),hl

; prepare to loop to next column
    pop hl ; get back pointer to tile def
    inc hl ; bump it to the next column
	pop bc ; snag our loop counter
    djnz @loop

; increment tiles plotting y-coordinate
; when it hits zero, we go to next row of tiles in the map
; (we use ix b/c we want to preserve hl for the next step)
	ld ix,tiles_y_plot
	inc (ix)
	ret nz

; time to bump tiles_row_defs to next row
; (hl was already there at the end of the loop)
    ld (tiles_row_defs),hl

; reset coords to plot next row of tiles
    ld hl,0
    ld (tiles_x_plot),hl
    ld hl,-15
    ld (tiles_y_plot),hl

; decrement tiles row counter
    ld hl,tiles_row
    dec (hl)
    ret nz

; queue up next level
    ld a,(cur_level)
    cp num_levels-1
    jr nz,@inc_level
    ld a,-1 ; will wrap around to zero when we fall through

@inc_level:
    inc a
    ld (cur_level),a

; increase the number of enemy sprites
    ld a,(max_enemy_sprites)
    inc a
    cp table_max_records ; if we're at the global limit,skip ahead at max level
    jr z,init_level
    ld (max_enemy_sprites),a ; otherwise save the updated number
; fall through to init_level

init_level:
; look up address of level's tile defintion
    ld hl,tiles_levels
    ld a,(cur_level)
    ld de,0 ; just in case deu is non-zero
    ld d,a
    ld e,3
    mlt de 
    add hl,de
    ld ix,(hl)
    ld (tiles_row_defs),ix

; set tiles_row counter
    ld a,(ix)
    ld (tiles_row),a
    inc ix ; now ix points first element of first row tile def
    ld (tiles_row_defs),ix ; ... so we save it
    ret


; ###### TODO: NEW CODE TO IMPLEMENT ######
; dt_is_active:
; ; a lands here containing a tile index in the low nibble
; ; we test the values for the tiles which are active
;     cp #07
;     call z,ld_act_landing_pad
;     cp #08
;     call z,ld_act_laser_turret
;     ; fall through
;     ret

; ; some tiles become active sprites,so we load those here
; ; sprite_x/y have already been loaded
; ; sprite_dim_x/y are loaded by table_add_record
; ; we don't want sprite drawn to background like other tiles
; ; so this routine only adds them to the sprite table
; dt_ld_act:
;     ld a,#48 ; top of screen + 1/2 tile height
;     ld (sprite_y+1),a ; just the integer part
;     ld (sprite_base_bufferId),hl
;     call vdu_bmp_select
;     call table_add_record
;     call sprite_variables_from_stack
;     ld a,#FF ; lets calling proc know we loaded an active tile
;     ret ; and back

; ld_act_landing_pad:
;     call sprite_variables_to_stack

;     ld hl,move_landing_pad
;     ld (sprite_move_program),hl

;     xor a 
;     ld (sprite_animation),a ; animation 0

;     call rand_8     ; snag a random number
;     and %00011111   ; keep only 5 lowest bits (max 31)
;     add a,64 ; range is now 64-127
;     ld (sprite_move_timer),a ; when this hits zero,will spawn an enemy

;     ld a,%10 ; collides with laser but not player
;     ld (iy+sprite_collisions),a 

;     ld a,#05 ; BCD
;     ld (sprite_points),a
;     ld a,0 ; binary
;     ld (sprite_shield_damage),a

;     ld hl,landing_pad ; dt_ld_act loads this to sprite_base_bufferId
;     jr dt_ld_act

; ld_act_laser_turret:
;     call sprite_variables_to_stack

;     ld hl,move_laser_turret
;     ld (sprite_move_program),hl

;     xor a 
;     ld (sprite_animation),a
;     ld (sprite_move_step),a

;     call rand_8     ; snag a random number
;     and %00011111   ; keep only 5 lowest bits (max 31)
;     add a,64 ; range is now 64-127
;     ld (sprite_move_timer),a ; when this hits zero,will spawn a fireball

;     ld a,%10 ; collides with laser but not player
;     ld (iy+sprite_collisions),a 

;     ld a,#10 ; BCD
;     ld (sprite_points),a
;     ld a,0 ; binary
;     ld (sprite_shield_damage),a

;     ld hl,laser_turret ; dt_ld_act loads this to sprite_base_bufferId
;     jp dt_ld_act


; moves active tile sprites down one pixel in sync with tiles movement
; deletes sprites from table when they wrap around to top of screen
move_active_tiles:
; get current position
    ld a,(sprite_y+1) ; we only need the integer part
    inc a 
; are we at the bottom of the screen?
    jr nz,move_active_tiles_draw_sprite ; nope
; otherwise kill sprite
    ld a,%10000000 ; any bit set in high nibble means sprite will die
    ld (iy+sprite_collisions),a
    ret ; debug
move_active_tiles_draw_sprite:
    ld (sprite_y+1),a ; update tile y position integer part
    call vdu_bmp_select
    call vdu_bmp_draw ; draw it
    ret ; and done
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 

; 
; ###########################################
; Included from: enemies.asm
; ###########################################
; 
max_enemy_sprites: db 16 

; sprite_type
enemy_dead: equ 0
enemy_small: equ 1
enemy_medium: equ 2
enemy_large: equ 3
landing_pad: equ 4
laser_turret: equ 5
fireballs: equ 6
explosion: equ 7


respawn_countdown:
    ld hl,(respawn_timer)
    dec hl
    ld (respawn_timer),hl
; check hl for zero
    add hl,de
    or a
    sbc hl,de 
    ret nz
    ld b,table_max_records
@respawn_loop:
    push bc
    call enemy_init_from_landing_pad
    pop bc
    djnz @respawn_loop
    ld hl,1*60 ; 1 second
    ld (respawn_timer),hl
    ret 
respawn_timer: dl 1*60

move_enemies:
; are there any active enemies or explosions?
    ld hl,0
    ld a,(table_active_sprites)
    ld l,a
    call dumpRegistersHex
    and a ; will be zero if no alive enemies or explosions
    ; ret z ; so nothing to do but go back
    ; ld hl,(respawn_timer)
    ; call dumpRegistersHex
    jr nz,move_enemies_do
    call respawn_countdown
    ret
move_enemies_do:
; initialize pointers and loop counter
    ld iy,table_base ; set iy to first record in table
    ld b,table_max_records ; loop counter
move_enemies_loop:
    ld (table_pointer),iy ; update table pointer
    push bc ; backup loop counter
; check sprite_type to see if sprite is active
    ld a,(iy+sprite_type)
    and a ; if zero, sprite is dead 
    jr z,move_enemies_next_record ; ... and we skip to next record
; otherwise we prepare to move the sprite
    ld a,(iy+sprite_id) ; get spriteId
    call vdu_sprite_select ; select sprite 
    ld hl,(iy+sprite_move_program) ; load the behavior subroutine address
    jp (hl)  ; ... and jump to it
; we always jp back here from behavior subroutines
move_enemies_loop_return:
    ld iy,(table_pointer) ; get back table pointer
; now we check results of all the moves
    ld a,(iy+sprite_collisions)
    and %11110000 ; any bits set in high nibble means we died
    ld a,(iy+sprite_id) ; get spriteId for the deactivate_sprite call if needed
    jr z,move_enemies_draw_sprite ; if not dead,draw sprite
    call table_deactivate_sprite ; otherwise we ded
    xor a ; zero a so that we can ...
    ld (iy+sprite_collisions),a ; ... clear collision flags
    jr move_enemies_next_record ; and to the next record
move_enemies_draw_sprite:
; if we got here sprite will have already been activated
; so all we need to do is set its coordinates and draw it
    ld bc,(iy+sprite_x)
    ld de,(iy+sprite_y)
    call vdu_sprite_move_abs168
; fall through to next record
move_enemies_next_record:
    ld de,table_bytes_per_record
    add iy,de ; point to next record
    xor a ; clears carry flag
    ld (sprite_screen_edge),a ; clear screen edge collision flag
    pop bc ; get back our loop counter
    djnz move_enemies_loop ; loop until we've checked all the records
    ret ; and we're out

en_nav_zigzag_start:
    ld iy,(table_pointer) ; TODO: see if we can get IY to land here with the proper value
    call rand_8
    and %00111111 ; limit it to 64
    set 3,a ; make sure it's at least 8
    ld (iy+sprite_move_timer),a ; store it
    ; fall through to en_nav_zigzag
en_nav_zigzag:
    ld a,(iy+sprite_move_timer)
    dec a
    ld (iy+sprite_move_timer),a
    jr nz,en_nav_zigzag_no_switch
    ; otherwise flip direction and restart timer
    ld a,(iy+sprite_move_step)
    xor %1 ; flips bit one
    ld (iy+sprite_move_step),a ; store it
    jr nz,en_nav_zigzag_right
;otherwise zag left
    ld hl,0x00A000; southwest heading
    ld (iy+sprite_heading),hl ; save sprite heading
    jr en_nav_zigzag_start
en_nav_zigzag_right:
    ld hl,0x006000; southeast heading
    ld (iy+sprite_heading),hl ; save sprite heading
    jr en_nav_zigzag_start
en_nav_zigzag_no_switch:
    ; ld a,(sprite_orientation)
    ld hl,(iy+sprite_heading)
    jr en_nav_computevelocities

; contains the logic for how to move the enemy
; and then does the moving
; inputs: a fully-populated active sprite table
;         player position variables
; destroys: everything except index registers
; outputs: moving enemies
en_nav:
; set velocity and orientation by player's relative location
; move enemies y-axis
; where is player relative to us?
    call orientation_to_player
;    h.l 16.8 fixed angle256 to player
;    ub.c and ud.e as 16.8 signed fixed point numbers
; is player above or below us?
    ld (ude),de ; dy
    ld a,(ude+2) ; deu
    rla ; shift sign bit into carry
    jr nc,en_nav_zigzag ; player is below,evade
; player is even or above,so home in on current heading
    ld (iy+sprite_heading),hl ; save sprite heading

; we land here from zig-zag program so as not to 
; redundantly save orientation and heading
en_nav_computevelocities:
; set x/y component velocities based on bearing to player
    ld iy,(table_pointer) ; TODO: see if we can get IY to land here with the proper value
    push hl ; we need it back to set rotation frame
    ld de,(iy+sprite_vel) 
    call polar_to_cartesian
    ld (iy+sprite_xvel),bc ; save x-velocity component
    ld (iy+sprite_yvel),de ; save y-velocity component 
; change the animation frame to match heading
; by dividng the heading by 8
    pop hl ; get back Heading
    ld a,h
    srl a
    srl a
    srl a
    call vdu_sprite_select_frame
; update sprite position
move_enemy_sprite:
    ld hl,(iy+sprite_x)
    ld de,(iy+sprite_xvel)
    add hl,de
    ld (iy+sprite_x),hl

    ld hl,(iy+sprite_y)
    ld de,(iy+sprite_yvel)
    add hl,de
    ld (iy+sprite_y),hl
    ret

; ; TODO: IMPLEMENT THIS PROPERLY
; move_enemy_sprite:
; ; x-axis movement first
;     ld hl,(iy+sprite_x)
;     push hl ; save pre-move position
;     pop bc ; to detect screen edge collision
;     ld de,(iy+sprite_xvel)
;     add hl,de ;compute new x position
;     ld (iy+sprite_x),hl ; store it
;     and a ; clear the carry flag
;     sbc hl,bc ; test which direction was our movement
;     jr z,@move_y ; zero flag means no horizontal movement
;     jp p,@move_right ; sign positive means moved right
; @move_left: ; otherwise we moved left
;     jr c,@move_y ; move left,no wraparound |C1 N1 PV1 H1 Z0 S1|A=00 HL=FF00 BC=0100 DE=FF00
;     ld hl,0x000000   ; move left,with wraparound |C0 N1 PV0 H0 Z0 S1|A=00 HL=FF00 BC=0000 DE=FF00
;     ld (iy+sprite_x),hl ; set x position to left edge of screen
;     ld a,#20 ; west
;     ld (sprite_screen_edge),a ; set screen edge collision flag
;     jr @move_y
; @move_right:
;     jr nc,@move_y ; move right,no wraparound |C0 N1 PV1 H0 Z0 S0|A=00 HL=0100 BC=FE00 DE=0100
;     ; move right,with wraparound |C1 N1 PV0 H1 Z0 S0|A=00 HL=0100 BC=FF00 DE=0100
;     ld l,0x00
;     ld a,(iy+sprite_dim_x)
;     ld h,a
;     ld a,0x00
;     sub h
;     ld h,a
;     ld (iy+sprite_x),hl ; set x position to right edge of screen
;     ld a,0x02 ; east
;     ld (sprite_screen_edge),a ; set screen edge collision flag
; @move_y:
;     ld hl,(iy+sprite_y)
;     ld b,h ; save pre-move position
;     ld c,l ; to detect screen edge collision
;     ld de,(iy+sprite_yvel)
;     add hl,de ;compute new y position
;     ld (iy+sprite_y),hl ; store it
;     and a ; clear the carry flag
;     sbc hl,bc ; test which direction was our movement
;     jr z,@move_ret ; zero flag means no vertical movement
;     jp p,@move_dn ; sign positive means moved down
; @move_up:
;     add hl,bc ; get back new y position
;     ld de,0x5000 ; top edge of visible screen
;     and a ; clear the carry flag
;     sbc hl,de
;     jr nc,@move_ret ; move up,no wraparound |C0 N1 PV0 H0 Z1 S0|A=00 HL=0000 BC=5100 DE=5000
;     ; move up,with wraparound |C1 N1 PV1 H0 Z0 S1|A=00 HL=FF00 BC=5000 DE=5000
;     ld (iy+sprite_y),de ; set y position flush with top of screen
;     ld a,(sprite_screen_edge) ; load any vertical edge collision
;     or 0x80 ; north
;     ld (sprite_screen_edge),a ; set screen edge collision flag
;     jr @move_ret
; @move_dn:
;     jr nc,@move_ret ; move down,no wraparound |C0 N1 PV0 H0 Z0 S0|A=00 HL=0100 BC=5100 DE=0100
;     ; move down,with wraparound |C1 N1 PV0 H1 Z0 S0|A=00 HL=0100 BC=FF00 DE=0100
;     ld l,0x00
;     ld a,(iy+sprite_dim_y)
;     ld h,a
;     ld a,0x00
;     sub h
;     ld h,a
;     ld (iy+sprite_y),hl ; set y position flush with bottom of screen
;     ld a,(sprite_screen_edge) ; load any vertical edge collision
;     or 0x08 ; south
;     ld (sprite_screen_edge),a ; set screen edge collision flag
; @move_ret:
;     ret

; ; ######### SPRITE BEHAVIOR ROUTINES #########
; ; each sprite in the table must have one of these defined
; ; but they need not be unique to a particular sprite
; ; these are jumped to from move_enemies_do_program,but could come from other places
; ; and have the option but not obligation to go back to move_enemies_loop_return
; ; but they can call anything they want between those two endpoints
; move_programs: ; bookmark in case we want to know the first address of the first subroutine

; move_nop: ; does nothing but burn a few cycles changing the PC
;     jp move_enemies_loop_return

; move_explosion:
;     call animate_explosion 
;     jp move_enemies_loop_return

move_enemy_small:
    call en_nav
    call check_collisions
    jp move_enemies_loop_return

; move_enemy_medium:
;     call en_nav
;     call check_collisions
;     jp move_enemies_loop_return

; move_enemy_large:
;     call en_nav
;     call check_collisions
;     jp move_enemies_loop_return

; move_landing_pad:
;     call move_active_tiles
;     call check_collisions
; ; is it time to launch an enemy?
;     ld hl,sprite_move_timer
;     dec (hl)
;     jp nz,move_enemies_loop_return
;     call enemy_init_from_landing_pad
;     ; reset move timer so can spawn again if player doesn't take us out
;     call rand_8     ; snag a random number
;     and %00011111   ; keep only 5 lowest bits (max 31)
;     add a,64 ; range is now 64-127
;     ld (sprite_move_timer),a ; when this hits zero,will spawn an enemy
;     jp move_enemies_loop_return

enemy_init_from_landing_pad:
; get next available spriteId
    call table_get_next_id
    ret nc ; no carry means no free sprite slots, so we go home
; ix comes back with the pointer to the new sprite variables
    push ix ; de picks it up when we're ready for the copy to the table
; a comes back with the spriteId of the new sprite
    ld (@id),a
; initialize the new sprite
    call vdu_sprite_select
    call vdu_sprite_clear_frames
    ld hl,BUF_SEEKER_000
    ld b,32
@load_frames:
    push bc
    push hl
    call vdu_sprite_add_buff
    pop hl
    inc hl
    pop bc
    djnz @load_frames
; copy coordinates of active sprite to new sprite
    ld iy,(table_pointer) ; TODO: see if we can get IY to land here with the proper value
    ; ld hl,(iy+sprite_x)
	; ld hl,0x008000 ; debug
    
    call rand_8
    ld hl,0
    ld h,a

    ld (@x),hl
    ; ld hl,(iy+sprite_y)
    ; ld hl,0x002000 ; debug

    call rand_8
    ld hl,0
    ld h,a

    ld (@y),hl
    call rand_8
    and %00000001 ; 50/50 chance of moving left or right on spanw
    ld (@move_step),a 
; now copy to the table
    ld hl,@id ; address to copy from
    pop de ; address to copy to (was ix)
    ld bc,table_bytes_per_record ; number of bytes to copy
    ldir ; copy the records from local scratch to sprite table
; finally, make the new sprite visible
    call vdu_sprite_show
    ret
@id:               db     0x00 ; 1 bytes unique spriteId, zero-based
@type:             db enemy_small ; 1 bytes type of sprite as defined in enemies.inc
@base_bufferId:    dl BUF_SEEKER_000 ; 3 bytes bitmap bufferId
@move_program:     dl move_enemy_small ; 3 bytes address of sprite's behavior subroutine
@collisions:       db %00000011 ; 3 bytes collides with enemy and laser
@dim_x:            db     0x10 ; 1 bytes sprite width in pixels
@dim_y:            db     0x10 ; 1 bytes sprite height in pixels
@x:                dl 0x000000 ; 1 bytes 16.8 fractional x position in pixels
@y:                dl 0x000000 ; 3 bytes 16.8 fractional y position in pixels
@xvel:             dl 0x000000 ; 3 bytes x-component velocity, 16.8 fixed, pixels
@yvel:             dl 0x000000 ; 3 bytes y-component velocity, 16.8 fixed, pixels
@vel:              dl speed_seeker ; 3 bytes velocity, 16.8 fixed, pixels 
@heading:          dl 0x008000 ; 3 bytes sprite movement direction deg256 16.8 fixed
@orientation:      dl 0x008000 ; 3 bytes orientation bits
@animation:        db     0x00 ; 1 bytes current animation index, zero-based
@animation_timer:  db     0x00 ; 1 bytes when hits zero, draw next animation
@move_timer:       db     0x01 ; 1 bytes when zero, go to next move program, or step
@move_step:        db     0x00 ; 1 bytes stage in a move program sequence, varies
@points:           db     0x20 ; 1 bytes points awarded for killing this sprite type, BCD
@shield_damage:    db     0x02 ; 1 bytes shield points deducted for collision, binary

; move_laser_turret:
; ; compute orientation to player
;     call orientation_to_player
; ; h.l 8.8 fixed angle256 to player
; ; bc and de as signed 16-bit integers
; ; representing delta-x/y *to* target respectively
;     ld (Bearing_t),hl
;     ld hl,0x0400
;     ld (Vp),hl
;     call targeting_computer
;     ld (sprite_heading),hl ; store bearing to player
; ; is it time to launch a fireball?
;     ld hl,sprite_move_timer
;     dec (hl)
;     jp nz,move_laser_turret_boilerplate
;     call fireballs_init
;     ; reset move timer so can fire again if player doesn't take us out
;     call rand_8     ; snag a random number
;     and %00011111   ; keep only 5 lowest bits (max 31)
;     add a,64 ; range is now 64-127
;     ld (sprite_move_timer),a ; when this hits zero,will spawn a fireball
; move_laser_turret_boilerplate:
;     call move_active_tiles
;     call check_collisions
;     jp move_enemies_loop_return

; fireballs_init:
;     call sprite_variables_to_stack

;     ld hl,fireballs
;     ld (sprite_base_bufferId),hl

;     ld hl,move_fireballs
;     ld (sprite_move_program),hl 

;     ld a,%11 ; collides with laser and player
;     ; ld a,%10 ; collides with laser DEBUG
;     ld (iy+sprite_collisions),a

;     ld hl,(Vp)
;     ld (sprite_vel),hl
;     ld hl,(Vp_x)
;     ld (sprite_xvel),hl
;     ld hl,(Vp_y)
;     inc h ; account for ground movement
;     ld (sprite_yvel),hl

;     xor a ; zero a
;     ld (sprite_animation),a
;     ld (sprite_move_step),a
;     ld (sprite_move_timer),a

;     ld a,6 ; 1/10th of a second timer
;     ld (sprite_animation_timer),a

;     ld a,0x00 ; BCD
;     ld (sprite_points),a
;     ld a,1 ; binary
;     ld (sprite_shield_damage),a

;     call table_add_record ; plops that on the sprite stack for later
;     call sprite_variables_from_stack ; come back to where we started
;     ret

; move_fireballs:
;     call move_enemy_sprite ; move sprite 
;     ld a,(sprite_screen_edge) ; check for collision with screen edge
;     and a ; if zero we're still within screen bounds
;     jr z,move_fireballs_alive
; ; otherwise kill sprite
;     ld a,%10000000 ; any bit set in high nibble means sprite will die
;     ld (iy+sprite_collisions),a
;     jp move_enemies_loop_return
; move_fireballs_alive:
;     ld a,(sprite_animation_timer)
;     dec a
;     ld (sprite_animation_timer),a
;     jr nz,move_fireballs_draw
;     ld a,(sprite_animation)
;     xor %1
;     ld (sprite_animation),a
;     ld a,6 ; 1/10th of a second timer
;     ld (sprite_animation_timer),a
;     ; fall through

; move_fireballs_draw:
;     call vdu_bmp_select
;     call vdu_bmp_draw
;     call check_collisions
;     jp move_enemies_loop_return

; compute orientation to player 
; based on relative positions
; returns: h.l 16.8 fixed angle256 to player
;    ub.c and ud.e as 16.8 signed fixed point numbers
;    representing delta-x/y *to* target respectively
orientation_to_player:
    ld iy,(table_pointer) ; TODO: see if we can get IY to land here with the proper value
    push iy ; so we can send it back intact
    ld bc,(iy+sprite_x)
    ld de,(iy+sprite_y)
    ld ix,(player_x)
    ld iy,(player_y)
    call dxy168
    call atan2_168game
    ld bc,(dx168)
    ld de,(dy168)
    pop iy ; restore table pointer
    ret


; targeting_computer scratch variables
Bearing_t: dw #0000 ; 8.8 fixed
Heading_t: dw #0000 ; 8.8 fixed
Vp: dw #0000 ; 8.8 fixed
Vp_x: dw #0000 ; 8.8 fixed
Vp_y: dw #0000 ; 8.8 fixed
Vt: dw #0000 ; 8.8 fixed
Vt_x: dw #0000 ; 8.8 fixed
Vt_y: dw #0000 ; 8.8 fixed


; ; Inputs:   see scratch variables
; ; Note:     a call to orientation_to_player provides these inputs
; ; Outputs:  h.l is the 16.8 fixed firing angle256
; ;           b.c and d.e are the 16.8 fixed x,y component projectile velocities
; ; https://old.robowiki.net/cgi-bin/robowiki?LinearTargeting
; targeting_computer:
; ; compute target velocity from x,y component velocities
;     ld bc,(player_xvel) 
;     ld de,(player_yvel)
;     dec d ; account for vertical ground movement: b.c=player_xvel,d.e=player_yvel-1

;     call cartesian_to_polar ; b.c=Heading_t, d.e=Vt
;     ld (Heading_t),bc
;     ld (Vt),de

; ; compute Heading_t-Bearing_t
;     ld h,b
;     ld l,c
;     ld bc,(Bearing_t)
;     and a ; clear carry
;     sbc hl,bc ; h.l=Heading_t-Bearing_t

; ; compute sin(Heading_t-Bearing_t)
;     ld b,h
;     ld c,l
;     call sin_bc ; h.l=sin(Heading_t-Bearing_t)

; ; compute (Vt*sin(Heading_t-Bearing_t))
;     ex de,hl
;     ld bc,(Vt)
;     call BC_Mul_DE_88 ; h.l=(Vt*sin(Heading_t-Bearing_t))

; ; compute (Vt * sin(Heading_t-Bearing_t)) / Vp
;     ld b,h
;     ld c,l
;     ld de,(Vp)
;     call div_88 ; h.l=(Vt*sin(Heading_t-Bearing_t)) / Vp
; ; answer is in radians, convert to degrees256
;     ex de,hl
;     ld bc,#28BE ; 40.74=57.29578*256/360
;     call BC_Mul_DE_88 

; ; add lead angle to target bearing
;     ld de,(Bearing_t)
;     add hl,de ; h.l=lead angle+target bearing
;     push hl

; ; compute component projectile velocities
;     ld b,h
;     ld c,l
;     ld de,(Vp)
;     call polar_to_cartesian ; b.c=Vp_x, d.e=Vp_y

;     ld (Vp_x),bc
;     ld (Vp_y),de
;     pop hl ; h.l=lead angle+target bearing
;     ret

; this routine vanquishes the enemy sprite
; and replaces it with an animated explosion
; we jump here instead of call because
; we want to return to differing locations in the loop
; depending on whether we're still sploding
; destroys: everything except index registers
; returns: an incandescent ball of debris and gas
kill_nurple:
; ; tally up points
;     ld bc,0
;     ld a,(sprite_points)
;     ld e,a
;     ld d,0
;     ld hl,add_bcd_arg2
;     call set_bcd
;     ld hl,player_score
;     ld de,add_bcd_arg2
;     ld a,3 ; number of bytes to add
;     call add_bcd
; ; initialize explosion
; init_explosion:
;     ld hl,explosion
;     ld (sprite_base_bufferId),hl
;     ld hl,move_explosion
;     ld (sprite_move_program),hl
;     ld a,%00000000 ; collides with nothing
;     ld (iy+sprite_collisions),a
;     ld hl,0 ; north
;     ld (sprite_heading),hl
;     ld a,0x04 ; will decrement to 03
;     ld (sprite_animation),a
;     ld a,0x07 ; 7/60th of a second timer
;     ld (sprite_animation_timer),a
;     xor a
;     ld (sprite_move_timer),a
;     call vdu_bmp_select
; ; fall through to next_explosion
; next_explosion:
;     ld a,(sprite_animation)
;     dec a ; if rolled negative from zero,we're done sploding
;     jp m,done_explosion
;     ld (sprite_animation),a
;     ld a,0x7 ; 7/60th of a second timer
;     ld (sprite_animation_timer),a
; ; fall through to animate_explosion
; animate_explosion:
;     ld hl,sprite_y+1
;     inc (hl) ; move explosion down 1 pixel
;     jr z, done_explosion ; if wraparound to top of screen, kill explosion
;     ld hl,sprite_animation_timer
;     dec (hl) ; if timer is zero,we do next animation
;     jr z,next_explosion
;     ;otherwise we fall through to draw the current one
;     call vdu_bmp_select
;     call vdu_bmp_draw
;     ret ; now we go back to caller
; done_explosion:
    ld a,%10000000 ; high bit set is non-specific kill-me flag
    ld iy,(table_pointer); TODO: see if we can get IY to land here with the proper value
    ld (iy+sprite_collisions),a
    ret ; now we go back to caller

; game_over:
;     jp new_game

; it's presumed we've already checked that laser is alive
collision_enemy_with_laser:
    ld ix,(laser_x)
    ld iy,(laser_y)
    ld a,(laser_dim_x)
    sra a ; divide by 2
    push af ; we need this later
    ; ld de,0
    ; ld d,a
    ; add ix,de
    ; add iy,de
    jr collision_enemy

; it's presumed we've already checked that player is alive
collision_enemy_with_player:
    ld ix,(player_x)
    ld iy,(player_y)
    ld a,(player_dim_x)

    ; call dumpRegistersHex

    sra a ; divide by 2
    push af ; we need this later
    ; ld de,0
    ; ld d,a
    ; add ix,de
    ; add iy,de
    ; fall through to collision_enemy

; compute the distance between the two sprites' centers
; inputs: bc and de as y0,x0 and y1,x1 respectively
collision_enemy:
; back up iy because we need it as the sprite table pointer
    push iy
    ld iy,(table_pointer)
    ld hl,(iy+sprite_x)
    ld a,(iy+sprite_dim_x)
    sra a
    push af ; we need this later
    ; ld de,0
    ; ld d,a
    ; add hl,de
    push hl
    pop bc ; bc = x0
    ld hl,(iy+sprite_y)
    ld a,(iy+sprite_dim_y)
    ; sra a
    ; ld de,0
    ; ld d,a
    ; add hl,de
    ex de,hl ; de = y0
    pop af ; TODO: srsly, this is the best way to do this?
    pop iy
    push af 

    ; call dumpRegistersHex

    call distance168
    ; CALL dumpRegistersHex
; ; subtract sum of radii from distance between centers
;     ld de,0
;     pop af ; radius of enemy sprite
;     ld e,a
;     pop af ; radius of player or laser sprite
;     add a,e
;     ld e,a
;     and a ; clear carry
;     sbc hl,de
;     jr c,collision_enemy_is
;     xor a
;     ret
; temp fix TODO: remove this
    pop af
    pop af
    ld de,16*256
    and a
    sbc hl,de
    jr c,collision_enemy_is
    xor a
    ; call dumpRegistersHex
    ret
collision_enemy_is:
    xor a
    inc a
    ; call dumpRegistersHex
    ret

; ; looks up what enemy sprite collides with
; ; detects collisions
; ; and sets things to sploding accordingly
; check_collisions:
;     ld a,(iy+sprite_collisions) ; snag what we collide with
;     and a ; if this is zero,
;     ret z ; there's nothing to do
;     and %01 ; do we collide with player?
;     jr z,move_enemies_laser ; if not,check laser collision
;     call collision_enemy_with_player ; otherwise see if we hit player
;     and a ; was there a collision?
;     jr z,move_enemies_laser ; if not,see if laser smacked us
; ; yes collision with player
;     ; deduct shield damage
;     ld hl,sprite_shield_damage 
;     ld a,(player_shields) 
;     sub (hl)
;     ld (player_shields),a 
; ; if shields >= 0,player survives
;     jp p,check_collisions_kill_nurple
; ; otherwise update player status so it will die
;     ld a,(player_collisions)
;     or %10 ; sets bit 1,meaning player just died
;     ld (player_collisions),a
;     ; fall through
; check_collisions_kill_nurple:
; ; kill enemy and replace with explosion
;     call kill_nurple
;     ret ; and out

check_collisions:
    call collision_enemy_with_player ; did we hit the player?
    and a ; was there a collision?
    ret z ; if not,we're done
    call kill_nurple ; otherwise kill enemy
    ret

; did we hit the laser?
move_enemies_laser:
    ld a,(iy+sprite_collisions) ; snag what we collide with again
    and %10 ; do we even collide with laser?
    ret z ; if not,we're out
    ld a,(laser_collisions) ; is laser alive?
    and %1 ; if bit 0 is not set laser is dead
    ret z ; so we're out
    call collision_enemy_with_laser ; otherwise check for collision
    and a ; was there a collision?
    ret z ; if not,we're done
; otherwise we mark laser for termination and kill enemy
; update laser status so it will die
    ld a,(laser_collisions)
    or %10 ; bit 1 set means laser just died
    ld (laser_collisions),a
    call kill_nurple ; yes there was a collision,so kill enemy
    ret ; we're outta' here
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 

; 
; ###########################################
; Included from: laser.asm
; ###########################################
; 
; ##### LASER SPRITE PARAMETERS #####
; uses the same offsets from its table base as the main sprite table:
laser_start_variables: ; label marking beginning of table
laser_id:               db table_max_records+1
laser_type:             db     0x00 ; 1 bytes currently not used
laser_base_bufferId:    dl BUF_LASER_A ; 3 bytes bitmap bufferId
laser_move_program:     dl 0x000000 ; 3 bytes not currently used
laser_collisions:       db     0x00 ; 1 bytes bit 0 set=alive, otherwise dead, bit 1 set=just died
laser_dim_x:            db     0x00 ; 1 bytes sprite width in pixels
laser_dim_y:            db     0x00 ; 1 bytes sprite height in pixels
laser_x:                dl 0x000000 ; 3 bytes 16.8 fractional x position in pixels
laser_y:                dl 0x000000 ; 3 bytes 16.8 fractional y position in pixels
laser_xvel:             dl 0x000000 ; 3 bytes x-component velocity, 16.8 fixed, pixels
laser_yvel:             dl 0xFFF800 ; 3 bytes y-component velocity, 16.8 fixed, pixels
laser_vel:              dl 0x000000 ; 3 bytes not currently used
laser_heading:          dl 0x000000 ; 3 bytes sprite movement direction deg256 16.8 fixed
laser_orientation:      dl 0x000000 ; 3 bytes not currently used
laser_animation:        db     0x00 ; 1 bytes current sprite animation frame
laser_animation_timer:  db     0x00 ; 1 bytes decremented every frame, when zero, advance animation
laser_move_timer:       db     0x00 ; 1 bytes not currently used
laser_move_step:        db     0x00 ; 1 bytes not currently used
laser_points:           db     0x00 ; 1 bytes not currently used
laser_shield_damage:    db     0x00 ; 1 bytes not currently used
laser_end_variables: ; for when we want to traverse this table in reverse

; laser_control:
; ; is laser already active?
;     ld a,(laser_collisions)
;     and %00000001 ; bit zero is lit if laser is active
;     jr nz,laser_move ; move laser if not zero
; ; otherwise check if laser fired
;     in a,(#82) ; keyboard
;     and %00010000 ; bit 4 is lit if space bar pressed
;     ret z ; go back if laser not fired
; ; otherwise,FIRE ZEE LASER!!1111
; ; set laser status to active (set bit 0)
;     ld a,%1
;     ld (laser_collisions),a
; ; initialize laser position
;     ld a,(player_x+1) ; we only need the integer part
;     ; add a,6 ; horizontal center with player sprite
;     ld (laser_x+1),a ; store laser x coordinate
;     ld a,(player_y+1) ; we only need the integer part
;     add a,-6 ; set laser y a few pixels above player
;     ld (laser_y+1),a ; store laser y coordinate
;     ; fall through to laser_move

; laser_move:
; ; begin setting laser to active sprite
;     ld hl,lasers
;     ld (sprite_base_bufferId),hl
;     ld hl,0 ; north
;     ld (sprite_heading),hl
;     xor a ; laser has no animations yet :-(
;     ld (sprite_animation),a
;     ; we set position here for the time being as a default
;     ; in case the laser is flagged for deletion
;     ; load sprite_x with laser x position (we do y further down)
;     ld hl,(laser_x)
;     ld (sprite_x),hl
; ; did laser just die?
;     ld a,(laser_collisions)
;     bit 1,a ; z if laser didn't just die
;     jr z,laser_not_dead_yet
; ; yes laser died
;     call kill_laser
;     ret ; done
; laser_not_dead_yet:
; ; draw it
; ; update laser y position
;     ld hl,(laser_y) ; grab laser y position
;     ld de,(laser_yvel) ; snag laser y velocity
;     add hl,de ; add y velocity to y pos 
;     ld (sprite_y),hl ; update laser y position
;     ld (laser_y),hl ; update laser y position
; ; are we at top of screen?
;     ld a,#51 ; top of visible screen plus a pixel
;     sub h ; no carry if above threshold
;     jr c,finally_draw_the_frikken_laser
;     ; if at top of screen,laser dies
;     call kill_laser
;     ret
; ; otherwise,finally draw the frikken laser
; finally_draw_the_frikken_laser:
;     call vdu_bmp_select
;     call vdu_bmp_draw
; ; all done
;     ret

; kill_laser:
; ; update status to inactive
;     xor a ; zero out a
;     ld (laser_collisions),a
;     ret
; 
; ###########################################
; Continuing nurples_main.asm
; ###########################################
; 
	; include "temp.asm"

; ; #### BEGIN GAME VARIABLES ####
speed_seeker: equ 0x000280 ; 2.5 pixels per frame
speed_player: equ 0x000300 ; 3 pixels per frame

main:
; move the background down one pixel
	ld a,2 ; current gfx viewport
	ld l,2 ; direction=down
	ld h,1 ; speed=1 px
	call vdu_scroll_down

; scroll tiles
	call tiles_plot

; get player input and update sprite position
	call player_input

; move enemies
	call move_enemies

; wait for the next vsync
	call vsync

; poll keyboard
    ld a, $08                           ; code to send to MOS
    rst.lil $08                         ; get IX pointer to System Variables
    
    ld a, (ix + $05)                    ; get ASCII code of key pressed
    cp 27                               ; check if 27 (ascii code for ESC)   
    jp z, main_end                     ; if pressed, jump to exit

    jp main

main_end:
    call cursor_on
	ret


; ; #### BEGIN GAME MAIN LOOP ####
; main_loop:
; ; ; debug: start execution counter 
; ;     ld a,1
; ;     out (#e0),a ; start counting instructions
    
; ; refresh background from frame buffer
;     ld a,#02
;     out (81h),a
;     call move_background ; now move it
;     ld a,#01
;     out (81h),a ; save it back to buffer
; ; do all the things
;     call move_enemies
;     call player_move
;     call laser_control
;     call print_score
;     call draw_shields
;     call draw_lives
; ; ; debug: stop execution counter and print results
; ;     ld a,0
; ;     out (#e0),a ; stop counting instructions

; ; ; debug: start execution counter 
; ;     ld a,1
; ;     out (#e0),a ; start counting instructions

;     call vsync
; ; ; debug: stop execution counter and print results
; ;     ld a,0
; ;     out (#e0),a ; stop counting instructions

;     jr main_loop
; #### END GAME MAIN LOOP ####

; draws the player's shields level
; draw_shields:
; TODO: Agonize this routine
; ; prep the loop to draw the bars
;     ld a,(player_shields) ; snag shields
;     and a 
;     ret z ; don't draw if zero shields
; ; set loop counter and drawing position
;     ld b,a ; loop counter
;     ld hl,#5300+48+12
; ; set color based on bars remaining
;     ld c,103 ; bright green 28fe0a
;     cp 9
;     jp p,draw_shields_loop
;     ld c,74 ; bright yellow eafe5b 
;     cp 3
;     jp p,draw_shields_loop
;     ld c,28 ; bright red fe0a0a 
; draw_shields_loop:
;     push bc ; yup,outta
;     push hl ; registers again
;     ; ld a,#A8 ; ▀,168 
;     ld a,10 ; ▀,168 ; we renumber because we don't use the full charset
;     ; call draw_char
;     call draw_num ; we nuked draw_char for the time being
;     pop hl
;     ld a,8
;     add a,l
;     ld l,a
;     pop bc
;     djnz draw_shields_loop
    ; ret

; prints the player's score
; print_score:
; TODO: Agonize this
; ; draw score (we do it twice for a totally unecessary drop-shadow effect)
;     ld c,42 ; dark orange b74400
;     ld hl,#5200+1+8+6*6
;     ld a,3 ; print 6 bdc digits
;     ld de,player_score
;     call print_num

;     ld c,58 ; golden yellow fec10a
;     ld hl,#5100+8+6*6
;     ld a,3 ; print 6 bdc digits
;     ld de,player_score
;     call print_num
    ; ret

; draw_lives:
;     ld hl,player_small ; make small yellow ship the active sprite
;     ld (sprite_base_bufferId),hl
;     ; ld a,#80 ; northern orientation
;     ; ld (sprite_orientation),a
;     ld hl,0 ; north
;     ld (sprite_heading),hl
;     xor a
;     ld (sprite_animation),a
;     ld a,#56 ; top of visible screen
;     ld (sprite_y+1),a
;     call vdu_bmp_select
;     ld a,(player_ships)
;     dec a ; we draw one fewer ships than lives
;     ret z ; nothing to draw here, move along
;     ld b,a ; loop counter
;     ld a,256-16 ; initial x position
; draw_lives_loop:
;     ld (sprite_x+1),a
;     push af
;     push bc
;     call vdu_bmp_draw
;     pop bc
;     pop af
;     sub 10
;     djnz draw_lives_loop
;     ret 