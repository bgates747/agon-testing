; change drawbar settings based on keypresses and set bank volumes accordingly
; inputs: ix pointing to virtual keys table
; outputs: drawbar settings changed
; destroys: everything
set_drawbars:
    ld hl,drawbar_mask
; 114 F1
    bit 1,(ix+14)
    jr z,@F1
    set 0,(hl)
@F1:
; 115 F2
    bit 2,(ix+14)
    jr z,@F2
    set 1,(hl)
@F2:
; 116 F3
    bit 3,(ix+14)
    jr z,@F3
    set 2,(hl)
@F3:
; 21 F4
    bit 4,(ix+2)
    jr z,@F4
    set 3,(hl)
@F4:
; 117 F5
    bit 4,(ix+14)
    jr z,@F5
    set 4,(hl)
@F5:
; 118 F6
    bit 5,(ix+14)
    jr z,@F6
    set 5,(hl)
@F6:
; 23 F7
    bit 6,(ix+2)
    jr z,@F7
    set 6,(hl)
@F7:
; 119 F8
    bit 6,(ix+14)
    jr z,@F8
    set 7,(hl)
@F8:

; cycle through drawbar mask
    ld c,8 ; number of drawbars
    push ix ; save pointer to virtual keys table
    ld ix,bank1_volume0 ; point to bank 1 volume
    ld iy,drawbar0 ; point to top of drawbar variables table
@loop_drawbar:
    ld (@current_key),ix
    rrc (hl) ; next loweest bit to carry
    push hl ; save pointer to drawbar mask
    jr nc,@next_drawbar
    call timer_get
    jp p,@next_drawbar
    ld hl,120/4 ; 1/4 of a second
    call timer_set
    ld a,(iy+drawbar_value)
    inc a ; bump drawbar value
    cp 9 ; 8 is max
    jp z,@set_zero ; wrap around to zero
    cp 8 
    jp z,@set_8 ; multiplier is 1 for 8
    ld (iy+drawbar_value),a
    ; this is fewer cycles than an mlt
    add a,a ; x2
    add a,a ; x4
    add a,a ; x8
    add a,a ; x16
    add a,a ; x32
    ld b,key_positions
    ld ix,(@current_key)
@loop_keys:
; adjust bank 1 volumes
    ld d,(ix) ; base volume
    ld e,a ; volume multiplier
    mlt de ; d contains integer portion of result
    ld (ix+1),d ; store modified volume

; adjust bank 2 volumes
    ld de,(bank2_volume) ; de is offset between bank 1 and bank 2 volumes
    add ix,de ; point to bank 2 volume
    ld d,(ix) ; base volume
    ld e,a ; volume multiplier
    mlt de ; d contains integer portion of result
    ld (ix+1),d ; store modified volume

; adjust bank 3 volumes
    ld de,(bank3_volume) ; de is offset between bank 2 and bank 3 volumes
    add ix,de ; point to bank 3 volume
    ld d,(ix) ; base volume
    ld e,a ; volume multiplier
    mlt de ; d contains integer portion of result
    ld (ix+1),d ; store modified volume

; adjust bank 4 volumes
    ld de,(bank4_volume) ; de is offset between bank 3 and bank 4 volumes
    add ix,de ; point to bank 4 volume
    ld d,(ix) ; base volume
    ld e,a ; volume multiplier
    mlt de ; d contains integer portion of result
    ld (ix+1),d ; store modified volume

    ld ix,(@current_key)
    lea ix,ix+16 ; bump ix to next key 
    ld (@current_key),ix
    djnz @loop_keys

@next_drawbar:
    pop hl ; restore pointer to drawbar mask
    lea iy,iy+drawbar_bytes ; bump iy to next drawbar variables
    ld ix,(@current_key)
    lea ix,ix+2 ; bump current_key to next drawbar
    dec c
    jp nz,@loop_drawbar
    xor a
    ld (hl),a ; drawbar mask reset

; debug print channel volumes
    ld hl,bank4_volume0
    ld a,10*2*8
    call dumpMemoryHex

    pop ix ; restore pointer to virtual keys table
    ret

@set_zero:
    xor a
    ld (iy+drawbar_value),a
    ld b,key_positions
    ld ix,(@current_key)
@loop_keys0:

; adjust bank 1 volumes
    ld (ix+1),a ; store modified volume

; adjust bank 2 volumes
    ld de,(bank2_volume) ; de is offset between bank 1 and bank 2 volumes
    add ix,de ; point to bank 2 volume
    ld (ix+1),a ; store modified volume

; adjust bank 3 volumes
    ld de,(bank3_volume) ; de is offset between bank 2 and bank 3 volumes
    add ix,de ; point to bank 3 volume
    ld (ix+1),a ; store modified volume

; adjust bank 4 volumes
    ld de,(bank4_volume) ; de is offset between bank 3 and bank 4 volumes
    add ix,de ; point to bank 4 volume
    ld (ix+1),a ; store modified volume

    ld ix,(@current_key)
    lea ix,ix+16 ; bump ix to next key 
    ld (@current_key),ix
    djnz @loop_keys0

    jp @next_drawbar

@set_8:
    ld (iy+drawbar_value),a
    ld b,key_positions
    ld ix,(@current_key)
@loop_keys8:

; adjust bank 1 volumes
    ld a,(ix) ; base volume
    ld (ix+1),a ; store modified volume

; adjust bank 2 volumes
    ld de,(bank2_volume) ; de is offset between bank 1 and bank 2 volumes
    add ix,de ; point to bank 2 volume
    ld a,(ix) ; base volume
    ld (ix+1),a ; store modified volume

; adjust bank 3 volumes
    ld de,(bank3_volume) ; de is offset between bank 2 and bank 3 volumes
    add ix,de ; point to bank 3 volume
    ld a,(ix) ; base volume
    ld (ix+1),a ; store modified volume

; adjust bank 4 volumes
    ld de,(bank4_volume) ; de is offset between bank 3 and bank 4 volumes
    add ix,de ; point to bank 4 volume
    ld a,(ix) ; base volume
    ld (ix+1),a ; store modified volume

    ld ix,(@current_key)
    lea ix,ix+16 ; bump ix to next key 
    ld (@current_key),ix
    djnz @loop_keys8

    jp @next_drawbar

@current_key: ds 3

volume_bytes: dl bank1_volume1 - bank1_volume0
bank2_volume: dl bank2_volume0 - bank1_volume0
bank3_volume: dl bank3_volume0 - bank2_volume0
bank4_volume: dl bank4_volume0 - bank3_volume0

; drawbar variables table
; byte 7 is unused
drawbar_value: equ 6
drawbar_timer: equ 0
drawbar_bytes: equ 8
drawbar0: ds drawbar_bytes
drawbar1: ds drawbar_bytes
drawbar2: ds drawbar_bytes
drawbar3: ds drawbar_bytes
drawbar4: ds drawbar_bytes
drawbar5: ds drawbar_bytes
drawbar6: ds drawbar_bytes
drawbar7: ds drawbar_bytes

drawbar_mask: db 0