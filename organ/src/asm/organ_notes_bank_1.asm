organ_notes_bank_1:
    ld iy,cmd0

    bit 0,(ix+6)
    jp z,@note_end0
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
    jp z,organ_notes_bank_1_end

@note_end0:

    bit 1,(ix+6)
    jp z,@note_end1
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
    jp z,organ_notes_bank_1_end

@note_end1:

    bit 1,(ix+2)
    jp z,@note_end2
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
    jp z,organ_notes_bank_1_end

@note_end2:

    bit 2,(ix+2)
    jp z,@note_end3
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
    jp z,organ_notes_bank_1_end

@note_end3:

    bit 3,(ix+2)
    jp z,@note_end4
    ld a,19
    ld (iy+cmd_volume),a
    ld a,0x93
    ld (iy+cmd_frequency),a
    ld a,0x02
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,8
    ld (iy+cmd_volume),a
    ld a,0xB9
    ld (iy+cmd_frequency),a
    ld a,0x07
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,11
    ld (iy+cmd_volume),a
    ld a,0x26
    ld (iy+cmd_frequency),a
    ld a,0x05
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0x4D
    ld (iy+cmd_frequency),a
    ld a,0x0A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x73
    ld (iy+cmd_frequency),a
    ld a,0x0F
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0x9A
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0xC0
    ld (iy+cmd_frequency),a
    ld a,0x19
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0xE7
    ld (iy+cmd_frequency),a
    ld a,0x1E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end4:

    bit 4,(ix+6)
    jp z,@note_end5
    ld a,17
    ld (iy+cmd_volume),a
    ld a,0x0F
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,7
    ld (iy+cmd_volume),a
    ld a,0x2F
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0x1F
    ld (iy+cmd_frequency),a
    ld a,0x06
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
    ld a,0x5F
    ld (iy+cmd_frequency),a
    ld a,0x12
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0x7F
    ld (iy+cmd_frequency),a
    ld a,0x18
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0x9F
    ld (iy+cmd_frequency),a
    ld a,0x1E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0xBF
    ld (iy+cmd_frequency),a
    ld a,0x24
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end5:

    bit 4,(ix+4)
    jp z,@note_end6
    ld a,15
    ld (iy+cmd_volume),a
    ld a,0x70
    ld (iy+cmd_frequency),a
    ld a,0x03
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0x50
    ld (iy+cmd_frequency),a
    ld a,0x0A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,9
    ld (iy+cmd_volume),a
    ld a,0xE0
    ld (iy+cmd_frequency),a
    ld a,0x06
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0xC0
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0xA0
    ld (iy+cmd_frequency),a
    ld a,0x14
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0x80
    ld (iy+cmd_frequency),a
    ld a,0x1B
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0x60
    ld (iy+cmd_frequency),a
    ld a,0x22
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0x40
    ld (iy+cmd_frequency),a
    ld a,0x29
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end6:

    bit 5,(ix+2)
    jp z,@note_end7
    ld a,13
    ld (iy+cmd_volume),a
    ld a,0x16
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0x43
    ld (iy+cmd_frequency),a
    ld a,0x0C
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,7
    ld (iy+cmd_volume),a
    ld a,0x2D
    ld (iy+cmd_frequency),a
    ld a,0x08
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
    ld a,0x87
    ld (iy+cmd_frequency),a
    ld a,0x18
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0xB4
    ld (iy+cmd_frequency),a
    ld a,0x20
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0xE1
    ld (iy+cmd_frequency),a
    ld a,0x28
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,1
    ld (iy+cmd_volume),a
    ld a,0x0E
    ld (iy+cmd_frequency),a
    ld a,0x31
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end7:

    bit 6,(ix+4)
    jp z,@note_end8
    ld a,12
    ld (iy+cmd_volume),a
    ld a,0x96
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,5
    ld (iy+cmd_volume),a
    ld a,0xC3
    ld (iy+cmd_frequency),a
    ld a,0x0D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,7
    ld (iy+cmd_volume),a
    ld a,0x2D
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x5A
    ld (iy+cmd_frequency),a
    ld a,0x12
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0x87
    ld (iy+cmd_frequency),a
    ld a,0x1B
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0xB5
    ld (iy+cmd_frequency),a
    ld a,0x24
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,1
    ld (iy+cmd_volume),a
    ld a,0xE2
    ld (iy+cmd_frequency),a
    ld a,0x2D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,1
    ld (iy+cmd_volume),a
    ld a,0x0F
    ld (iy+cmd_frequency),a
    ld a,0x37
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end8:

    bit 7,(ix+4)
    jp z,@note_end9
    ld a,11
    ld (iy+cmd_volume),a
    ld a,0xDC
    ld (iy+cmd_frequency),a
    ld a,0x04
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,4
    ld (iy+cmd_volume),a
    ld a,0x95
    ld (iy+cmd_frequency),a
    ld a,0x0E
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,6
    ld (iy+cmd_volume),a
    ld a,0xB9
    ld (iy+cmd_frequency),a
    ld a,0x09
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,3
    ld (iy+cmd_volume),a
    ld a,0x72
    ld (iy+cmd_frequency),a
    ld a,0x13
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0x2B
    ld (iy+cmd_frequency),a
    ld a,0x1D
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,2
    ld (iy+cmd_volume),a
    ld a,0xE4
    ld (iy+cmd_frequency),a
    ld a,0x26
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,1
    ld (iy+cmd_volume),a
    ld a,0x9D
    ld (iy+cmd_frequency),a
    ld a,0x30
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld a,1
    ld (iy+cmd_volume),a
    ld a,0x56
    ld (iy+cmd_frequency),a
    ld a,0x3A
    ld (iy+cmd_frequency+1),a
    lea iy,iy+cmd_bytes

    ld hl,notes_played
    dec (hl)
    jp z,organ_notes_bank_1_end

@note_end9:

organ_notes_bank_1_end:
