drawbar_volumes: blkb 9,8 ; 9 drawbars, default volume 8
drawbar_timers: blkb 9*6,0 ; 9 drawbars, 6 bytes per timer, default 0

set_drawbar:
    push hl
    call timer_get
    pop hl
    ret p
    push hl
    ld hl,120/4 ; 1/4 second
    call timer_set
    pop hl
    inc (hl)
    ld a,9
    cp (hl)
    ret nz
    xor a
    ld (hl),a
    ret

; change drawbar settings based on keypresses and set bank volumes accordingly
; inputs: ix pointing to virtual keys table
; outputs: drawbar settings changed
; destroys: everything
set_drawbars:
    ld hl,drawbar_volumes
    ld iy,drawbar_timers
; 114 F1
    bit 1,(ix+14)
    jr z,@F1
    push ix
    call set_drawbar
    pop ix
@F1:
    inc hl
    lea iy,iy+6
; 115 F2
    bit 2,(ix+14)
    jr z,@F2
    push ix
    call set_drawbar
    pop ix
@F2:
    inc hl
    lea iy,iy+6
; 116 F3
    bit 3,(ix+14)
    jr z,@F3
    push ix
    call set_drawbar
    pop ix
@F3:
    inc hl
    lea iy,iy+6
; 21 F4
    bit 4,(ix+2)
    jr z,@F4
    push ix
    call set_drawbar
    pop ix
@F4:
    inc hl
    lea iy,iy+6
; 117 F5
    bit 4,(ix+14)
    jr z,@F5
    push ix
    call set_drawbar
    pop ix
@F5:
    inc hl
    lea iy,iy+6
; 118 F6
    bit 5,(ix+14)
    jr z,@F6
    push ix
    call set_drawbar
    pop ix
@F6:
    inc hl
    lea iy,iy+6
; 23 F7
    bit 6,(ix+2)
    jr z,@F7
    push ix
    call set_drawbar
    pop ix
@F7:
    inc hl
    lea iy,iy+6
; 119 F8
    bit 6,(ix+14)
    jr z,@F8
    push ix
    call set_drawbar
    pop ix
@F8:
    inc hl
    lea iy,iy+6
; 120 F9
    bit 7,(ix+14)
    jr z,@F9
    push ix
    call set_drawbar
    pop ix
@F9:
    ld hl,@str_drawbars
    call printString
    ld hl,drawbar_volumes
    ld a,9
    call dumpMemoryHex
    ret
@str_drawbars: db "Drawbars:\r\n 1  2  3  4  5  6  7  8  9\r\n",0

set_volumes:
    ld c,32 ; 32 channels
    ld b,84 ; 84 tonewheels
    ld ix,play_notes_cmd
    ld iy,tonewheel_frequencies
@loop:
    ld de,(iy+2) ; e = drawbar setting, d = tonewheel base volume
    ld a,e
    and a
    jr z,@next_tonewheel
    ld hl,(iy) ; hl = tonewheel frequency
    cp 8
    jr z,@set_volume
    add a,a ; x 2
    add a,a ; x 4
    add a,a ; x 8
    add a,a ; x 16
    add a,a ; x 32
    ld e,a
    mlt de
@set_volume:
    ld (ix+volume0-play_notes_cmd),d
    ld (ix+frequency0-play_notes_cmd),l
    ld (ix+frequency0-play_notes_cmd+1),h
    lea ix,ix+cmd1-cmd0
    dec c
    jr nz,@next_tonewheel
    ret
@next_tonewheel:
    lea iy,iy+4
    djnz @loop
    ret
