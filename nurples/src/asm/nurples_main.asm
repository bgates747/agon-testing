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
	include "sprites.asm"
; API includes
    include "../agon_api/asm/mos_api.inc"
    include "../agon_api/asm/functions.inc"
    include "../agon_api/asm/vdu.inc"
    include "../agon_api/asm/vdu_buff.inc"
    ; include "../agon_api/asm/vdu_plot.inc"
	; include "../agon_api/asm/vdu_sprites.inc"
	; include "../agon_api/asm/vdp.inc"
	include "../agon_api/asm/div_168_signed.inc"
	include "../agon_api/asm/maths24.inc"
; App-specific includes
	include "player.asm"
	include "tiles.asm"
	include "enemies.asm"
	include "laser.asm"
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