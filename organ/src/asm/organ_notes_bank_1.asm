organ_notes_bank_1:
    ld iy,cmd0

    bit 0,(ix+6)
    jp z,@note_end0
    ld a,(bank1_volume0+1)
    ld (iy+cmd_volume),a
    ld a,0xB8
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume0+3)
    ld (iy+cmd_volume),a
    ld a,0x26
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume0+5)
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume0+7)
    ld (iy+cmd_volume),a
    ld a,0xE0
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume0+9)
    ld (iy+cmd_volume),a
    ld a,0x4D
    ld (iy+cmd_frequency),a
    ld a,0x0A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume0+11)
    ld (iy+cmd_volume),a
    ld a,0xC0
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume0+13)
    ld (iy+cmd_volume),a
    ld a,0x58
    ld (iy+cmd_frequency),a
    ld a,0x11
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume0+15)
    ld (iy+cmd_volume),a
    ld a,0xA0
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end0:

    bit 1,(ix+6)
    jp z,@note_end1
    ld a,(bank1_volume1+1)
    ld (iy+cmd_volume),a
    ld a,0x0B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume1+3)
    ld (iy+cmd_volume),a
    ld a,0x20
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume1+5)
    ld (iy+cmd_volume),a
    ld a,0x16
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume1+7)
    ld (iy+cmd_volume),a
    ld a,0x2C
    ld (iy+cmd_frequency),a
    ld a,0x08
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume1+9)
    ld (iy+cmd_volume),a
    ld a,0x42
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume1+11)
    ld (iy+cmd_volume),a
    ld a,0x5D
    ld (iy+cmd_frequency),a
    ld a,0x10
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume1+13)
    ld (iy+cmd_volume),a
    ld a,0xA0
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume1+15)
    ld (iy+cmd_volume),a
    ld a,0x42
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end1:

    bit 1,(ix+2)
    jp z,@note_end2
    ld a,(bank1_volume2+1)
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume2+3)
    ld (iy+cmd_volume),a
    ld a,0xE0
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume2+5)
    ld (iy+cmd_volume),a
    ld a,0x97
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume2+7)
    ld (iy+cmd_volume),a
    ld a,0x2E
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume2+9)
    ld (iy+cmd_volume),a
    ld a,0xC4
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume2+11)
    ld (iy+cmd_volume),a
    ld a,0x60
    ld (iy+cmd_frequency),a
    ld a,0x12
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume2+13)
    ld (iy+cmd_volume),a
    ld a,0x25
    ld (iy+cmd_frequency),a
    ld a,0x17
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume2+15)
    ld (iy+cmd_volume),a
    ld a,0xC4
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end2:

    bit 2,(ix+2)
    jp z,@note_end3
    ld a,(bank1_volume3+1)
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume3+3)
    ld (iy+cmd_volume),a
    ld a,0x48
    ld (iy+cmd_frequency),a
    ld a,0x07
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume3+5)
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume3+7)
    ld (iy+cmd_volume),a
    ld a,0xB9
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume3+9)
    ld (iy+cmd_volume),a
    ld a,0x95
    ld (iy+cmd_frequency),a
    ld a,0x0E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume3+11)
    ld (iy+cmd_volume),a
    ld a,0x76
    ld (iy+cmd_frequency),a
    ld a,0x13
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume3+13)
    ld (iy+cmd_volume),a
    ld a,0x40
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume3+15)
    ld (iy+cmd_volume),a
    ld a,0x95
    ld (iy+cmd_frequency),a
    ld a,0x0E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end3:

    bit 3,(ix+2)
    jp z,@note_end4
    ld a,(bank1_volume4+1)
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume4+3)
    ld (iy+cmd_volume),a
    ld a,0xB7
    ld (iy+cmd_frequency),a
    ld a,0x07
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume4+5)
    ld (iy+cmd_volume),a
    ld a,0x26
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume4+7)
    ld (iy+cmd_volume),a
    ld a,0x4D
    ld (iy+cmd_frequency),a
    ld a,0x0A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume4+9)
    ld (iy+cmd_volume),a
    ld a,0x73
    ld (iy+cmd_frequency),a
    ld a,0x0F
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume4+11)
    ld (iy+cmd_volume),a
    ld a,0xA0
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume4+13)
    ld (iy+cmd_volume),a
    ld a,0xF9
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume4+15)
    ld (iy+cmd_volume),a
    ld a,0x73
    ld (iy+cmd_frequency),a
    ld a,0x0F
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end4:

    bit 4,(ix+6)
    jp z,@note_end5
    ld a,(bank1_volume5+1)
    ld (iy+cmd_volume),a
    ld a,0x10
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume5+3)
    ld (iy+cmd_volume),a
    ld a,0x2E
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume5+5)
    ld (iy+cmd_volume),a
    ld a,0x20
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume5+7)
    ld (iy+cmd_volume),a
    ld a,0x40
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume5+9)
    ld (iy+cmd_volume),a
    ld a,0x60
    ld (iy+cmd_frequency),a
    ld a,0x12
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume5+11)
    ld (iy+cmd_volume),a
    ld a,0x40
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume5+13)
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x0F
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume5+15)
    ld (iy+cmd_volume),a
    ld a,0x60
    ld (iy+cmd_frequency),a
    ld a,0x12
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end5:

    bit 4,(ix+4)
    jp z,@note_end6
    ld a,(bank1_volume6+1)
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume6+3)
    ld (iy+cmd_volume),a
    ld a,0x4D
    ld (iy+cmd_frequency),a
    ld a,0x0A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume6+5)
    ld (iy+cmd_volume),a
    ld a,0xE0
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume6+7)
    ld (iy+cmd_volume),a
    ld a,0xC0
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume6+9)
    ld (iy+cmd_volume),a
    ld a,0xA0
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume6+11)
    ld (iy+cmd_volume),a
    ld a,0xC0
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume6+13)
    ld (iy+cmd_volume),a
    ld a,0x58
    ld (iy+cmd_frequency),a
    ld a,0x11
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume6+15)
    ld (iy+cmd_volume),a
    ld a,0xA0
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end6:

    bit 5,(ix+2)
    jp z,@note_end7
    ld a,(bank1_volume7+1)
    ld (iy+cmd_volume),a
    ld a,0x16
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume7+3)
    ld (iy+cmd_volume),a
    ld a,0x42
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume7+5)
    ld (iy+cmd_volume),a
    ld a,0x2C
    ld (iy+cmd_frequency),a
    ld a,0x08
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume7+7)
    ld (iy+cmd_volume),a
    ld a,0x5D
    ld (iy+cmd_frequency),a
    ld a,0x10
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume7+9)
    ld (iy+cmd_volume),a
    ld a,0x42
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume7+11)
    ld (iy+cmd_volume),a
    ld a,0x5D
    ld (iy+cmd_frequency),a
    ld a,0x10
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume7+13)
    ld (iy+cmd_volume),a
    ld a,0xA0
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume7+15)
    ld (iy+cmd_volume),a
    ld a,0x42
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end7:

    bit 6,(ix+4)
    jp z,@note_end8
    ld a,(bank1_volume8+1)
    ld (iy+cmd_volume),a
    ld a,0x97
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume8+3)
    ld (iy+cmd_volume),a
    ld a,0xC4
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume8+5)
    ld (iy+cmd_volume),a
    ld a,0x2E
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume8+7)
    ld (iy+cmd_volume),a
    ld a,0x60
    ld (iy+cmd_frequency),a
    ld a,0x12
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume8+9)
    ld (iy+cmd_volume),a
    ld a,0xC4
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume8+11)
    ld (iy+cmd_volume),a
    ld a,0x60
    ld (iy+cmd_frequency),a
    ld a,0x12
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume8+13)
    ld (iy+cmd_volume),a
    ld a,0x25
    ld (iy+cmd_frequency),a
    ld a,0x17
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume8+15)
    ld (iy+cmd_volume),a
    ld a,0xC4
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end8:

    bit 7,(ix+4)
    jp z,@note_end9
    ld a,(bank1_volume9+1)
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume9+3)
    ld (iy+cmd_volume),a
    ld a,0x95
    ld (iy+cmd_frequency),a
    ld a,0x0E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume9+5)
    ld (iy+cmd_volume),a
    ld a,0xB9
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume9+7)
    ld (iy+cmd_volume),a
    ld a,0x76
    ld (iy+cmd_frequency),a
    ld a,0x13
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume9+9)
    ld (iy+cmd_volume),a
    ld a,0x95
    ld (iy+cmd_frequency),a
    ld a,0x0E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume9+11)
    ld (iy+cmd_volume),a
    ld a,0x76
    ld (iy+cmd_frequency),a
    ld a,0x13
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume9+13)
    ld (iy+cmd_volume),a
    ld a,0x40
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank1_volume9+15)
    ld (iy+cmd_volume),a
    ld a,0x95
    ld (iy+cmd_frequency),a
    ld a,0x0E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end9:

organ_notes_bank_1_end:
    ret

bank1_volume0:
     db 127,127 ; 440 Hz, TW 33 
     db 127,127 ; 1318 Hz, TW 52 
     db 127,127 ; 880 Hz, TW 45 
     db 127,127 ; 1760 Hz, TW 57 
     db 127,127 ; 2637 Hz, TW 64 
     db 127,127 ; 3520 Hz, TW 69 
     db 127,127 ; 4440 Hz, TW 78 
     db 127,127 ; 5280 Hz, TW 81 
bank1_volume1:
     db 127,127 ; 523 Hz, TW 36 
     db 127,127 ; 1568 Hz, TW 55 
     db 127,127 ; 1046 Hz, TW 48 
     db 127,127 ; 2092 Hz, TW 60 
     db 127,127 ; 3138 Hz, TW 72 
     db 127,127 ; 4189 Hz, TW 77 
     db 127,127 ; 5280 Hz, TW 81 
     db 127,127 ; 3138 Hz, TW 72 
bank1_volume2:
     db 127,127 ; 587 Hz, TW 38 
     db 127,127 ; 1760 Hz, TW 57 
     db 127,127 ; 1175 Hz, TW 50 
     db 127,127 ; 2350 Hz, TW 62 
     db 127,127 ; 3524 Hz, TW 74 
     db 127,127 ; 4704 Hz, TW 79 
     db 127,127 ; 5925 Hz, TW 83 
     db 127,127 ; 3524 Hz, TW 74 
bank1_volume3:
     db 127,127 ; 622 Hz, TW 39 
     db 127,127 ; 1864 Hz, TW 58 
     db 127,127 ; 1244 Hz, TW 51 
     db 127,127 ; 2489 Hz, TW 63 
     db 127,127 ; 3733 Hz, TW 75 
     db 127,127 ; 4982 Hz, TW 80 
     db 127,127 ; 3136 Hz, TW 67 
     db 127,127 ; 3733 Hz, TW 75 
bank1_volume4:
     db 127,127 ; 659 Hz, TW 40 
     db 127,127 ; 1975 Hz, TW 59 
     db 127,127 ; 1318 Hz, TW 52 
     db 127,127 ; 2637 Hz, TW 64 
     db 127,127 ; 3955 Hz, TW 76 
     db 127,127 ; 5280 Hz, TW 81 
     db 127,127 ; 3321 Hz, TW 68 
     db 127,127 ; 3955 Hz, TW 76 
bank1_volume5:
     db 127,127 ; 784 Hz, TW 43 
     db 127,127 ; 2350 Hz, TW 62 
     db 127,127 ; 1568 Hz, TW 55 
     db 127,127 ; 3136 Hz, TW 67 
     db 127,127 ; 4704 Hz, TW 79 
     db 127,127 ; 3136 Hz, TW 67 
     db 127,127 ; 3950 Hz, TW 71 
     db 127,127 ; 4704 Hz, TW 79 
bank1_volume6:
     db 127,127 ; 880 Hz, TW 45 
     db 127,127 ; 2637 Hz, TW 64 
     db 127,127 ; 1760 Hz, TW 57 
     db 127,127 ; 3520 Hz, TW 69 
     db 127,127 ; 5280 Hz, TW 81 
     db 127,127 ; 3520 Hz, TW 69 
     db 127,127 ; 4440 Hz, TW 78 
     db 127,127 ; 5280 Hz, TW 81 
bank1_volume7:
     db 127,127 ; 1046 Hz, TW 48 
     db 127,127 ; 3138 Hz, TW 72 
     db 127,127 ; 2092 Hz, TW 60 
     db 127,127 ; 4189 Hz, TW 77 
     db 127,127 ; 3138 Hz, TW 72 
     db 127,127 ; 4189 Hz, TW 77 
     db 127,127 ; 5280 Hz, TW 81 
     db 127,127 ; 3138 Hz, TW 72 
bank1_volume8:
     db 127,127 ; 1175 Hz, TW 50 
     db 127,127 ; 3524 Hz, TW 74 
     db 127,127 ; 2350 Hz, TW 62 
     db 127,127 ; 4704 Hz, TW 79 
     db 127,127 ; 3524 Hz, TW 74 
     db 127,127 ; 4704 Hz, TW 79 
     db 127,127 ; 5925 Hz, TW 83 
     db 127,127 ; 3524 Hz, TW 74 
bank1_volume9:
     db 127,127 ; 1244 Hz, TW 51 
     db 127,127 ; 3733 Hz, TW 75 
     db 127,127 ; 2489 Hz, TW 63 
     db 127,127 ; 4982 Hz, TW 80 
     db 127,127 ; 3733 Hz, TW 75 
     db 127,127 ; 4982 Hz, TW 80 
     db 127,127 ; 3136 Hz, TW 67 
     db 127,127 ; 3733 Hz, TW 75 
