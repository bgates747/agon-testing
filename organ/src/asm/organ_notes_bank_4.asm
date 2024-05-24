organ_notes_bank_4:
    ld iy,cmd0

    bit 1,(ix+12)
    jp z,@note_end0
    ld a,(bank4_volume0+1)
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+3)
    ld (iy+cmd_volume),a
    ld a,0xA5
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+5)
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+7)
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+9)
    ld (iy+cmd_volume),a
    ld a,0x4A
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+11)
    ld (iy+cmd_volume),a
    ld a,0xB8
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+13)
    ld (iy+cmd_volume),a
    ld a,0x2A
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+15)
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end0:

    bit 2,(ix+8)
    jp z,@note_end1
    ld a,(bank4_volume1+1)
    ld (iy+cmd_volume),a
    ld a,0x41
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume1+3)
    ld (iy+cmd_volume),a
    ld a,0xC4
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume1+5)
    ld (iy+cmd_volume),a
    ld a,0x83
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume1+7)
    ld (iy+cmd_volume),a
    ld a,0x06
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume1+9)
    ld (iy+cmd_volume),a
    ld a,0x88
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume1+11)
    ld (iy+cmd_volume),a
    ld a,0x0B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume1+13)
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume1+15)
    ld (iy+cmd_volume),a
    ld a,0x10
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end1:

    bit 2,(ix+10)
    jp z,@note_end2
    ld a,(bank4_volume2+1)
    ld (iy+cmd_volume),a
    ld a,0x49
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume2+3)
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume2+5)
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume2+7)
    ld (iy+cmd_volume),a
    ld a,0x26
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume2+9)
    ld (iy+cmd_volume),a
    ld a,0xB8
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume2+11)
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume2+13)
    ld (iy+cmd_volume),a
    ld a,0xE4
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume2+15)
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end2:

    bit 3,(ix+12)
    jp z,@note_end3
    ld a,(bank4_volume3+1)
    ld (iy+cmd_volume),a
    ld a,0x4E
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume3+3)
    ld (iy+cmd_volume),a
    ld a,0xE9
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume3+5)
    ld (iy+cmd_volume),a
    ld a,0x9C
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume3+7)
    ld (iy+cmd_volume),a
    ld a,0x37
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume3+9)
    ld (iy+cmd_volume),a
    ld a,0xD2
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume3+11)
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume3+13)
    ld (iy+cmd_volume),a
    ld a,0x10
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume3+15)
    ld (iy+cmd_volume),a
    ld a,0xA4
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end3:

    bit 4,(ix+12)
    jp z,@note_end4
    ld a,(bank4_volume4+1)
    ld (iy+cmd_volume),a
    ld a,0x52
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume4+3)
    ld (iy+cmd_volume),a
    ld a,0xF7
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume4+5)
    ld (iy+cmd_volume),a
    ld a,0xA5
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume4+7)
    ld (iy+cmd_volume),a
    ld a,0x4A
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume4+9)
    ld (iy+cmd_volume),a
    ld a,0xEE
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume4+11)
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume4+13)
    ld (iy+cmd_volume),a
    ld a,0x3E
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume4+15)
    ld (iy+cmd_volume),a
    ld a,0xDB
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end4:

    bit 5,(ix+10)
    jp z,@note_end5
    ld a,(bank4_volume5+1)
    ld (iy+cmd_volume),a
    ld a,0x62
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+3)
    ld (iy+cmd_volume),a
    ld a,0x26
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+5)
    ld (iy+cmd_volume),a
    ld a,0xC4
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+7)
    ld (iy+cmd_volume),a
    ld a,0x88
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+9)
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+11)
    ld (iy+cmd_volume),a
    ld a,0x10
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+13)
    ld (iy+cmd_volume),a
    ld a,0xDB
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+15)
    ld (iy+cmd_volume),a
    ld a,0x97
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end5:

    bit 5,(ix+12)
    jp z,@note_end6
    ld a,(bank4_volume6+1)
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+3)
    ld (iy+cmd_volume),a
    ld a,0x4A
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+5)
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+7)
    ld (iy+cmd_volume),a
    ld a,0xB8
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+9)
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+11)
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+13)
    ld (iy+cmd_volume),a
    ld a,0x54
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+15)
    ld (iy+cmd_volume),a
    ld a,0x26
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end6:

    bit 6,(ix+12)
    jp z,@note_end7
    ld a,(bank4_volume7+1)
    ld (iy+cmd_volume),a
    ld a,0x83
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume7+3)
    ld (iy+cmd_volume),a
    ld a,0x88
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume7+5)
    ld (iy+cmd_volume),a
    ld a,0x06
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume7+7)
    ld (iy+cmd_volume),a
    ld a,0x0B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume7+9)
    ld (iy+cmd_volume),a
    ld a,0x10
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume7+11)
    ld (iy+cmd_volume),a
    ld a,0x16
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume7+13)
    ld (iy+cmd_volume),a
    ld a,0x26
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume7+15)
    ld (iy+cmd_volume),a
    ld a,0x20
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end7:

    bit 7,(ix+12)
    jp z,@note_end8
    ld a,(bank4_volume8+1)
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume8+3)
    ld (iy+cmd_volume),a
    ld a,0xB8
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume8+5)
    ld (iy+cmd_volume),a
    ld a,0x26
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume8+7)
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume8+9)
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume8+11)
    ld (iy+cmd_volume),a
    ld a,0x97
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume8+13)
    ld (iy+cmd_volume),a
    ld a,0xC8
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume8+15)
    ld (iy+cmd_volume),a
    ld a,0xE0
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end8:

    bit 0,(ix+13)
    jp z,@note_end9
    ld a,(bank4_volume9+1)
    ld (iy+cmd_volume),a
    ld a,0x9C
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume9+3)
    ld (iy+cmd_volume),a
    ld a,0xD2
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume9+5)
    ld (iy+cmd_volume),a
    ld a,0x37
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume9+7)
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume9+9)
    ld (iy+cmd_volume),a
    ld a,0xA4
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume9+11)
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume9+13)
    ld (iy+cmd_volume),a
    ld a,0x20
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume9+15)
    ld (iy+cmd_volume),a
    ld a,0x48
    ld (iy+cmd_frequency),a
    ld a,0x07
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end9:

organ_notes_bank_4_end:
    ret

bank4_volume0:
     db 127,127 ; 110 Hz, TW 9 
     db 127,127 ; 165 Hz, TW 16 
     db 127,127 ; 110 Hz, TW 9 
     db 127,127 ; 220 Hz, TW 21 
     db 127,127 ; 330 Hz, TW 28 
     db 127,127 ; 440 Hz, TW 33 
     db 127,127 ; 554 Hz, TW 37 
     db 127,127 ; 659 Hz, TW 40 
bank4_volume1:
     db 127,127 ; 65 Hz, TW 0 
     db 127,127 ; 196 Hz, TW 19 
     db 127,127 ; 131 Hz, TW 12 
     db 127,127 ; 262 Hz, TW 24 
     db 127,127 ; 392 Hz, TW 31 
     db 127,127 ; 523 Hz, TW 36 
     db 127,127 ; 659 Hz, TW 40 
     db 127,127 ; 784 Hz, TW 43 
bank4_volume2:
     db 127,127 ; 73 Hz, TW 2 
     db 127,127 ; 220 Hz, TW 21 
     db 127,127 ; 147 Hz, TW 14 
     db 127,127 ; 294 Hz, TW 26 
     db 127,127 ; 440 Hz, TW 33 
     db 127,127 ; 587 Hz, TW 38 
     db 127,127 ; 740 Hz, TW 42 
     db 127,127 ; 880 Hz, TW 45 
bank4_volume3:
     db 127,127 ; 78 Hz, TW 3 
     db 127,127 ; 233 Hz, TW 22 
     db 127,127 ; 156 Hz, TW 15 
     db 127,127 ; 311 Hz, TW 27 
     db 127,127 ; 466 Hz, TW 34 
     db 127,127 ; 622 Hz, TW 39 
     db 127,127 ; 784 Hz, TW 43 
     db 127,127 ; 932 Hz, TW 46 
bank4_volume4:
     db 127,127 ; 82 Hz, TW 4 
     db 127,127 ; 247 Hz, TW 23 
     db 127,127 ; 165 Hz, TW 16 
     db 127,127 ; 330 Hz, TW 28 
     db 127,127 ; 494 Hz, TW 35 
     db 127,127 ; 659 Hz, TW 40 
     db 127,127 ; 830 Hz, TW 44 
     db 127,127 ; 987 Hz, TW 47 
bank4_volume5:
     db 127,127 ; 98 Hz, TW 7 
     db 127,127 ; 294 Hz, TW 26 
     db 127,127 ; 196 Hz, TW 19 
     db 127,127 ; 392 Hz, TW 31 
     db 127,127 ; 587 Hz, TW 38 
     db 127,127 ; 784 Hz, TW 43 
     db 127,127 ; 987 Hz, TW 47 
     db 127,127 ; 1175 Hz, TW 50 
bank4_volume6:
     db 127,127 ; 110 Hz, TW 9 
     db 127,127 ; 330 Hz, TW 28 
     db 127,127 ; 220 Hz, TW 21 
     db 127,127 ; 440 Hz, TW 33 
     db 127,127 ; 659 Hz, TW 40 
     db 127,127 ; 880 Hz, TW 45 
     db 127,127 ; 1108 Hz, TW 49 
     db 127,127 ; 1318 Hz, TW 52 
bank4_volume7:
     db 127,127 ; 131 Hz, TW 12 
     db 127,127 ; 392 Hz, TW 31 
     db 127,127 ; 262 Hz, TW 24 
     db 127,127 ; 523 Hz, TW 36 
     db 127,127 ; 784 Hz, TW 43 
     db 127,127 ; 1046 Hz, TW 48 
     db 127,127 ; 1318 Hz, TW 52 
     db 127,127 ; 1568 Hz, TW 55 
bank4_volume8:
     db 127,127 ; 147 Hz, TW 14 
     db 127,127 ; 440 Hz, TW 33 
     db 127,127 ; 294 Hz, TW 26 
     db 127,127 ; 587 Hz, TW 38 
     db 127,127 ; 880 Hz, TW 45 
     db 127,127 ; 1175 Hz, TW 50 
     db 127,127 ; 1480 Hz, TW 54 
     db 127,127 ; 1760 Hz, TW 57 
bank4_volume9:
     db 127,127 ; 156 Hz, TW 15 
     db 127,127 ; 466 Hz, TW 34 
     db 127,127 ; 311 Hz, TW 27 
     db 127,127 ; 622 Hz, TW 39 
     db 127,127 ; 932 Hz, TW 46 
     db 127,127 ; 1244 Hz, TW 51 
     db 127,127 ; 1568 Hz, TW 55 
     db 127,127 ; 1864 Hz, TW 58 
