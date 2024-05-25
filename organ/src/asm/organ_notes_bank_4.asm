organ_notes_bank_4:
    ld iy,cmd0

    bit 1,(ix+12)
    jp z,@note_end0

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+38
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+66
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+38
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+86
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+114
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+134
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+150
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+162
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+182
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end0:

    bit 2,(ix+8)
    jp z,@note_end1

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+2
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+78
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+50
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+98
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+126
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+146
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+162
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+174
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+194
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end1:

    bit 2,(ix+10)
    jp z,@note_end2

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+10
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+86
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+58
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+106
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+134
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+154
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+170
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+182
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+202
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end2:

    bit 3,(ix+12)
    jp z,@note_end3

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+14
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+90
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+62
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+110
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+138
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+158
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+174
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+186
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+206
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end3:

    bit 4,(ix+12)
    jp z,@note_end4

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+18
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+94
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+66
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+114
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+142
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+162
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+178
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+190
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+210
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end4:

    bit 5,(ix+10)
    jp z,@note_end5

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+30
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+106
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+78
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+126
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+154
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+174
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+190
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+202
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+222
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end5:

    bit 5,(ix+12)
    jp z,@note_end6

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+38
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+114
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+86
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+134
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+162
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+182
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+198
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+210
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+230
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end6:

    bit 6,(ix+12)
    jp z,@note_end7

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+50
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+126
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+98
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+146
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+174
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+194
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+210
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+222
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+242
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end7:

    bit 7,(ix+12)
    jp z,@note_end8

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+58
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+134
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+106
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+154
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+182
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+202
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+218
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+230
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+250
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end8:

    bit 0,(ix+13)
    jp z,@note_end9

    ld a,(drawbar_volumes+0)
    ld hl,tonewheel_frequencies+62
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+1)
    ld hl,tonewheel_frequencies+138
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+2)
    ld hl,tonewheel_frequencies+110
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+3)
    ld hl,tonewheel_frequencies+158
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+4)
    ld hl,tonewheel_frequencies+186
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+5)
    ld hl,tonewheel_frequencies+206
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+6)
    ld hl,tonewheel_frequencies+222
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+7)
    ld hl,tonewheel_frequencies+234
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

    ld a,(drawbar_volumes+8)
    ld hl,tonewheel_frequencies+254
    cp (hl)
    db 0x38, 0x01 ; jr c,1
    ld (hl),a

@note_end9:

    ret