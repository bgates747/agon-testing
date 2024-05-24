organ_notes_bank_4:
    ld iy,cmd0

    bit 1,(ix+12)
    jp z,@note_end0
    ld a,(bank4_volume0+1)
    ld (iy+cmd_volume),a
    ld a,0x36
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+3)
    ld (iy+cmd_volume),a
    ld a,0xA4
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+5)
    ld (iy+cmd_volume),a
    ld a,0x6D
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+7)
    ld (iy+cmd_volume),a
    ld a,0xDB
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+9)
    ld (iy+cmd_volume),a
    ld a,0x49
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+11)
    ld (iy+cmd_volume),a
    ld a,0xB7
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume0+13)
    ld (iy+cmd_volume),a
    ld a,0x25
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
    ld a,0x82
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume1+7)
    ld (iy+cmd_volume),a
    ld a,0x05
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
    ld a,0x8E
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
    ld a,0x92
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume2+7)
    ld (iy+cmd_volume),a
    ld a,0x25
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
    ld a,0xDE
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
    ld a,0x4D
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
    ld a,0x9B
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
    ld a,0x09
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume3+15)
    ld (iy+cmd_volume),a
    ld a,0xA5
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
    ld a,0xA4
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume4+7)
    ld (iy+cmd_volume),a
    ld a,0x49
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
    ld a,0x38
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume4+15)
    ld (iy+cmd_volume),a
    ld a,0xDC
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
    ld a,0x61
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+3)
    ld (iy+cmd_volume),a
    ld a,0x25
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+5)
    ld (iy+cmd_volume),a
    ld a,0xC3
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+7)
    ld (iy+cmd_volume),a
    ld a,0x87
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
    ld a,0x0F
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume5+13)
    ld (iy+cmd_volume),a
    ld a,0xD3
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
    ld a,0x6D
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+3)
    ld (iy+cmd_volume),a
    ld a,0x49
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+5)
    ld (iy+cmd_volume),a
    ld a,0xDB
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+7)
    ld (iy+cmd_volume),a
    ld a,0xB7
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
    ld a,0x6F
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+13)
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume6+15)
    ld (iy+cmd_volume),a
    ld a,0x27
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
    ld a,0x82
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
    ld a,0x05
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
    ld a,0x1C
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume7+15)
    ld (iy+cmd_volume),a
    ld a,0x21
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
    ld a,0x92
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
    ld a,0x25
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
    ld a,0x96
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume8+13)
    ld (iy+cmd_volume),a
    ld a,0xBC
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume8+15)
    ld (iy+cmd_volume),a
    ld a,0xE1
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
    ld a,0x9B
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
    ld a,0xA5
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
    ld a,0x13
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,(bank4_volume9+15)
    ld (iy+cmd_volume),a
    ld a,0x4A
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
     db 127,127
     db 104,104
     db 127,127
     db 90,90
     db 73,73
     db 63,63
     db 56,56
     db 51,51
bank4_volume1:
     db 127,127
     db 95,95
     db 116,116
     db 82,82
     db 67,67
     db 58,58
     db 52,52
     db 47,47
bank4_volume2:
     db 127,127
     db 89,89
     db 110,110
     db 77,77
     db 63,63
     db 54,54
     db 49,49
     db 44,44
bank4_volume3:
     db 127,127
     db 87,87
     db 106,106
     db 75,75
     db 61,61
     db 53,53
     db 47,47
     db 43,43
bank4_volume4:
     db 127,127
     db 84,84
     db 104,104
     db 73,73
     db 59,59
     db 51,51
     db 46,46
     db 42,42
bank4_volume5:
     db 127,127
     db 77,77
     db 95,95
     db 67,67
     db 54,54
     db 47,47
     db 42,42
     db 38,38
bank4_volume6:
     db 127,127
     db 73,73
     db 90,90
     db 63,63
     db 51,51
     db 44,44
     db 40,40
     db 36,36
bank4_volume7:
     db 116,116
     db 67,67
     db 82,82
     db 58,58
     db 47,47
     db 41,41
     db 36,36
     db 33,33
bank4_volume8:
     db 110,110
     db 63,63
     db 77,77
     db 54,54
     db 44,44
     db 38,38
     db 34,34
     db 31,31
bank4_volume9:
     db 106,106
     db 61,61
     db 75,75
     db 53,53
     db 43,43
     db 37,37
     db 33,33
     db 30,30
