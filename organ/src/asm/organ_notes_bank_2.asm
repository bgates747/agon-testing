organ_notes_bank_2:
    ld iy,cmd0

    bit 0,(ix+2)
    jp z,@note_end10
    ld a,47
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x00
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,19
    ld (iy+cmd_volume),a
    ld a,0x94
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,27
    ld (iy+cmd_volume),a
    ld a,0xB8
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,15
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,11
    ld (iy+cmd_volume),a
    ld a,0x28
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0xE0
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,7
    ld (iy+cmd_volume),a
    ld a,0x98
    ld (iy+cmd_frequency),a
    ld a,0x08
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0x50
    ld (iy+cmd_frequency),a
    ld a,0x0A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end10:

    bit 1,(ix+4)
    jp z,@note_end11
    ld a,41
    ld (iy+cmd_volume),a
    ld a,0x05
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,17
    ld (iy+cmd_volume),a
    ld a,0x10
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,23
    ld (iy+cmd_volume),a
    ld a,0x0B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,13
    ld (iy+cmd_volume),a
    ld a,0x16
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0x21
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,7
    ld (iy+cmd_volume),a
    ld a,0x2D
    ld (iy+cmd_frequency),a
    ld a,0x08
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0x38
    ld (iy+cmd_frequency),a
    ld a,0x0A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0x43
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end11:

    bit 2,(ix+4)
    jp z,@note_end12
    ld a,38
    ld (iy+cmd_volume),a
    ld a,0x25
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,15
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,21
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,12
    ld (iy+cmd_volume),a
    ld a,0x96
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0xE1
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,7
    ld (iy+cmd_volume),a
    ld a,0x2D
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0x78
    ld (iy+cmd_frequency),a
    ld a,0x0B
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0xC3
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end12:

    bit 3,(ix+6)
    jp z,@note_end13
    ld a,36
    ld (iy+cmd_volume),a
    ld a,0x37
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,15
    ld (iy+cmd_volume),a
    ld a,0xA5
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,20
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,11
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,8
    ld (iy+cmd_volume),a
    ld a,0x4A
    ld (iy+cmd_frequency),a
    ld a,0x07
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0xB9
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0x27
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x95
    ld (iy+cmd_frequency),a
    ld a,0x0E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end13:

    bit 3,(ix+4)
    jp z,@note_end14
    ld a,34
    ld (iy+cmd_volume),a
    ld a,0x49
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,14
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,19
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,11
    ld (iy+cmd_volume),a
    ld a,0x26
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,8
    ld (iy+cmd_volume),a
    ld a,0xB9
    ld (iy+cmd_frequency),a
    ld a,0x07
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0x4D
    ld (iy+cmd_frequency),a
    ld a,0x0A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0xE0
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x73
    ld (iy+cmd_frequency),a
    ld a,0x0F
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end14:

    bit 4,(ix+8)
    jp z,@note_end15
    ld a,30
    ld (iy+cmd_volume),a
    ld a,0x87
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,12
    ld (iy+cmd_volume),a
    ld a,0x97
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,17
    ld (iy+cmd_volume),a
    ld a,0x0F
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0x1F
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,7
    ld (iy+cmd_volume),a
    ld a,0x2F
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0x3F
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x4F
    ld (iy+cmd_frequency),a
    ld a,0x0F
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x5F
    ld (iy+cmd_frequency),a
    ld a,0x12
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end15:

    bit 5,(ix+6)
    jp z,@note_end16
    ld a,27
    ld (iy+cmd_volume),a
    ld a,0xB8
    ld (iy+cmd_frequency),a
    ld a,0x01
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,11
    ld (iy+cmd_volume),a
    ld a,0x28
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,15
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0xE0
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0x50
    ld (iy+cmd_frequency),a
    ld a,0x0A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0xC0
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x30
    ld (iy+cmd_frequency),a
    ld a,0x11
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0xA0
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end16:

    bit 5,(ix+4)
    jp z,@note_end17
    ld a,23
    ld (iy+cmd_volume),a
    ld a,0x0B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0x21
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,13
    ld (iy+cmd_volume),a
    ld a,0x16
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,7
    ld (iy+cmd_volume),a
    ld a,0x2D
    ld (iy+cmd_frequency),a
    ld a,0x08
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0x43
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x5A
    ld (iy+cmd_frequency),a
    ld a,0x10
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0x87
    ld (iy+cmd_frequency),a
    ld a,0x18
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end17:

    bit 6,(ix+6)
    jp z,@note_end18
    ld a,21
    ld (iy+cmd_volume),a
    ld a,0x4B
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0xE1
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,12
    ld (iy+cmd_volume),a
    ld a,0x96
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,7
    ld (iy+cmd_volume),a
    ld a,0x2D
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0xC3
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x5A
    ld (iy+cmd_frequency),a
    ld a,0x12
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0xF1
    ld (iy+cmd_frequency),a
    ld a,0x16
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0x87
    ld (iy+cmd_frequency),a
    ld a,0x1B
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end18:

    bit 7,(ix+6)
    jp z,@note_end19
    ld a,20
    ld (iy+cmd_volume),a
    ld a,0x6E
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,8
    ld (iy+cmd_volume),a
    ld a,0x4A
    ld (iy+cmd_frequency),a
    ld a,0x07
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,11
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0xB9
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x95
    ld (iy+cmd_frequency),a
    ld a,0x0E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0x72
    ld (iy+cmd_frequency),a
    ld a,0x13
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0x4E
    ld (iy+cmd_frequency),a
    ld a,0x18
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0x2B
    ld (iy+cmd_frequency),a
    ld a,0x1D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_2_end

@note_end19:

organ_notes_bank_2_end:
