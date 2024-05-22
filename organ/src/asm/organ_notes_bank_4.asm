organ_notes_bank_4:
    ld iy,cmd0

    bit 1,(ix+12)
    jp z,@note_end30
    ld a,127
    ld (iy+cmd_volume),a
    ld a,0x36
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,60
    ld (iy+cmd_volume),a
    ld a,0xA4
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,83
    ld (iy+cmd_volume),a
    ld a,0x6D
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,48
    ld (iy+cmd_volume),a
    ld a,0xDB
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,34
    ld (iy+cmd_volume),a
    ld a,0x49
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,27
    ld (iy+cmd_volume),a
    ld a,0xB7
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,23
    ld (iy+cmd_volume),a
    ld a,0x25
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,19
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end30:

    bit 2,(ix+8)
    jp z,@note_end31
    ld a,127
    ld (iy+cmd_volume),a
    ld a,0x41
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,52
    ld (iy+cmd_volume),a
    ld a,0xC4
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,72
    ld (iy+cmd_volume),a
    ld a,0x82
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,41
    ld (iy+cmd_volume),a
    ld a,0x05
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,30
    ld (iy+cmd_volume),a
    ld a,0x88
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,23
    ld (iy+cmd_volume),a
    ld a,0x0B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,20
    ld (iy+cmd_volume),a
    ld a,0x8E
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,17
    ld (iy+cmd_volume),a
    ld a,0x10
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end31:

    bit 2,(ix+10)
    jp z,@note_end32
    ld a,115
    ld (iy+cmd_volume),a
    ld a,0x49
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,47
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,66
    ld (iy+cmd_volume),a
    ld a,0x92
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,38
    ld (iy+cmd_volume),a
    ld a,0x25
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,27
    ld (iy+cmd_volume),a
    ld a,0xB8
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,21
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,18
    ld (iy+cmd_volume),a
    ld a,0xDE
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,15
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end32:

    bit 3,(ix+12)
    jp z,@note_end33
    ld a,110
    ld (iy+cmd_volume),a
    ld a,0x4D
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,45
    ld (iy+cmd_volume),a
    ld a,0xE9
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,63
    ld (iy+cmd_volume),a
    ld a,0x9B
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,36
    ld (iy+cmd_volume),a
    ld a,0x37
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,26
    ld (iy+cmd_volume),a
    ld a,0xD2
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,20
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,17
    ld (iy+cmd_volume),a
    ld a,0x09
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,15
    ld (iy+cmd_volume),a
    ld a,0xA5
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end33:

    bit 4,(ix+12)
    jp z,@note_end34
    ld a,105
    ld (iy+cmd_volume),a
    ld a,0x52
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,43
    ld (iy+cmd_volume),a
    ld a,0xF7
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,60
    ld (iy+cmd_volume),a
    ld a,0xA4
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,34
    ld (iy+cmd_volume),a
    ld a,0x49
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,25
    ld (iy+cmd_volume),a
    ld a,0xEE
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,19
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,16
    ld (iy+cmd_volume),a
    ld a,0x38
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,14
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end34:

    bit 5,(ix+10)
    jp z,@note_end35
    ld a,92
    ld (iy+cmd_volume),a
    ld a,0x61
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,38
    ld (iy+cmd_volume),a
    ld a,0x25
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,52
    ld (iy+cmd_volume),a
    ld a,0xC3
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,30
    ld (iy+cmd_volume),a
    ld a,0x87
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,21
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,17
    ld (iy+cmd_volume),a
    ld a,0x0F
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,14
    ld (iy+cmd_volume),a
    ld a,0xD3
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,12
    ld (iy+cmd_volume),a
    ld a,0x97
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end35:

    bit 5,(ix+12)
    jp z,@note_end36
    ld a,83
    ld (iy+cmd_volume),a
    ld a,0x6D
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,34
    ld (iy+cmd_volume),a
    ld a,0x49
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,48
    ld (iy+cmd_volume),a
    ld a,0xDB
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,27
    ld (iy+cmd_volume),a
    ld a,0xB7
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,19
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,15
    ld (iy+cmd_volume),a
    ld a,0x6F
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,13
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,11
    ld (iy+cmd_volume),a
    ld a,0x27
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end36:

    bit 6,(ix+12)
    jp z,@note_end37
    ld a,72
    ld (iy+cmd_volume),a
    ld a,0x82
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,30
    ld (iy+cmd_volume),a
    ld a,0x88
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,41
    ld (iy+cmd_volume),a
    ld a,0x05
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,23
    ld (iy+cmd_volume),a
    ld a,0x0B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,17
    ld (iy+cmd_volume),a
    ld a,0x10
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,13
    ld (iy+cmd_volume),a
    ld a,0x16
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,11
    ld (iy+cmd_volume),a
    ld a,0x1C
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0x21
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end37:

    bit 7,(ix+12)
    jp z,@note_end38
    ld a,66
    ld (iy+cmd_volume),a
    ld a,0x92
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,27
    ld (iy+cmd_volume),a
    ld a,0xB8
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,38
    ld (iy+cmd_volume),a
    ld a,0x25
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,21
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,15
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,12
    ld (iy+cmd_volume),a
    ld a,0x96
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,10
    ld (iy+cmd_volume),a
    ld a,0xBC
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0xE1
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end38:

    bit 0,(ix+13)
    jp z,@note_end39
    ld a,63
    ld (iy+cmd_volume),a
    ld a,0x9B
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,26
    ld (iy+cmd_volume),a
    ld a,0xD2
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,36
    ld (iy+cmd_volume),a
    ld a,0x37
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,20
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,15
    ld (iy+cmd_volume),a
    ld a,0xA5
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,11
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,10
    ld (iy+cmd_volume),a
    ld a,0x13
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,8
    ld (iy+cmd_volume),a
    ld a,0x4A
    ld (iy+cmd_frequency),a
    ld a,0x07
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_4_end

@note_end39:

organ_notes_bank_4_end:
