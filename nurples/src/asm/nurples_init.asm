; after this we can put includes in any order we wish, even in between
; code blocks if there is any program-dependent or asethetic reason to do so
	include "images2.asm"
	include "fonts.asm"
	include "levels.asm"

hello_world: defb "Hello, World!\n\r",0

init:
; ; set fonts
; 	ld hl,font_nurples
; 	ld b,144 ; loop counter for 96 chars
; 	ld a,32 ; first char to define (space)
; @loop:
; 	push bc
; 	push hl
; 	push af
; 	call vdu_define_character
; 	pop af
; 	inc a
; 	pop hl
; 	ld de,8
; 	add hl,de
; 	pop bc
; 	djnz @loop

; set up the display
    ld a,8
    call vdu_set_screen_mode
    xor a
    call vdu_set_scaling
	ld bc,32
	ld de,16
	call vdu_set_gfx_origin

	call vdu_init ; grab a bunch of sysvars and stuff
	call cursor_off

; ; TESTING SOME MATHS
; 	ld bc,0x00A000 ; 160
; 	ld de,0x007800 ; 120
; 	ld ix,0x011F80 ; 287.5
; 	ld iy,0xFF9B2A ; -100.836
; 	;  hl=0x00FF00 255
; 	call distance168
; 	call dumpRegistersHex
; 	halt
; ; END TESTING SOME MATHS

; ; print a hello message
; 	ld hl,hello_world
; 	call printString

; load the bitmaps
	call bmp2_init

; initialize the first level
	xor a
	ld (cur_level),a
	call init_level

; set gfx viewport to scrolling window
	ld bc,0
	ld de,0
	ld ix,255
	ld iy,239-16
	call vdu_set_gfx_viewport

; initialize sprites
	call vdu_sprite_reset ; out of an abundance of caution (copilot: and paranoia)
	xor a
@sprite_loop:
	push af
	call vdu_sprite_select
	ld hl,BUF_0TILE_EMPTY ; can be anything, but why not blank?
	call vdu_sprite_add_buff
	pop af
	inc a
	cp table_max_records+1 ; tack on sprites for player and laser
	jr nz,@sprite_loop
	inc a
	call vdu_sprite_activate

; define player sprite
	ld a,16
	call vdu_sprite_select
	call vdu_sprite_clear_frames
	ld hl,BUF_SHIP_0L
	ld bc,3 ; three bitmaps for player ship
@sprite_player_loop:
	push bc
	push hl
	call vdu_sprite_add_buff
	pop hl
	inc hl
	pop bc
	djnz @sprite_player_loop
	call vdu_sprite_show

; initialize player
	call player_init

; spawn an enemy sprite
	ld b,table_max_records
@spawn_enemy_loop:
	push bc
	call enemy_init_from_landing_pad
	pop bc
	djnz @spawn_enemy_loop

	ret

; new_game:
; ; ###### INITIALIZE GAME #######
; ; clear the screen
;     ld a,3
;     out (81h),a

; ; reset the sprite table
;     xor a
;     ld (table_active_sprites),a
;     ld hl,table_limit
;     ld (table_base),hl
;     ld (table_pointer),hl

; ; draw a starfield over the entire screen
;     ld b,#50 ; first row of visible screen
; new_game_draw_stars_loop:
;     push bc
;     call draw_stars
;     pop bc
;     ld a,#10
;     add a,b
;     ld b,a
;     jr nz,new_game_draw_stars_loop

; ; ; print a welcome message
; ;     ld de,msg_welcome
; ;     ld hl,#581C
; ;     ld c,218 ; a bright pastel purple d677e3
; ;     call print_string

; ; push all that to frame buffer
;     ld a,#01 ; send video to frame buffer
;     out (81h),a

; ; reset score, lives, shields
;     xor a
;     ld hl,player_score
;     ld (hl),a ; player_score 0
;     inc hl
;     ld (hl),a ; player_score 1
;     inc hl
;     ld (hl),a ; player_score 3
;     inc hl
;     ld a,16
;     ld (hl),a ; player_shields
;     inc hl
;     ld (hl),a ; player_max_shields
;     inc hl
;     ld a,3
;     ld (hl),a ; player_ships
;     inc hl

; ; initialize first level
;     ld a,1 ; levels are zero-based, so this will wrap around
;     ld (cur_level),a
;     ld a,3 ; set max enemy sprites to easy street
;     ; ld a,64 ; DEBUG: BRING IT
;     ld (max_enemy_sprites),a 
;     call dt_next_level
;     call dt

; ; spawn our intrepid hero
;     call player_init