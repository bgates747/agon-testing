; 24-bit integer and 16.8 fixed point division routines
; by Brandon R. Gates (BeeGee747)
; have undergone cursory testing and seem to be generating
; correct resutlts (assuming no overflows) but seem very inefficient,
; so they have been published for review and improvement
; see: https://discord.com/channels/1158535358624039014/1158536711148675072/1212136741608099910
;
; ---------------------------------------------------------
; GLOBAL SCRATCH VARIABLES
; ---------------------------------------------------------
uaf: dl 0
uhl: dl 0
ubc: dl 0
ude: dl 0
uix: dl 0
uiy: dl 0
usp: dl 0
upc: dl 0

; ---------------------------------------------------------
; BEGIN DIVISION ROUTINES
; ---------------------------------------------------------
;
; perform signed division 16.8 fixed place values
; with a signed 16.8 fixed place result
; inputs: ub.c as dividend,ud.e as divisor
; note: for reasons i forget, uses carry flag to
;       distinguish sign of operands and result
;       which can be confusing and should perhaps be changed
div_168_signed:
; make everything positive and save signs
    push bc ; get bc to hl
    pop hl ; for the next call
    call abs_hlu ; sets carry if hlu was negative
    push af ; save sign of bc
    push hl ; now put abs(hl)
    pop bc ; to bc = abs(bc)
    ex de,hl ; now we do de same way
    call abs_hlu
    ex de,hl ; de = abs(de)
; determine sign of result
    jr nc,@de_pos ; carry=0,de is positive
    pop af ; get back sign of bc
    jr c,@both_neg ; bc and de negative, result is positive
    scf ; set carry flag indicating result negative
    jr @do_div
@de_pos:
    pop af ; get back sign of bc
    jr nc,@do_div ; bc and de are both positive so result is positive
    scf ; set carry flag indicating result negative
    jr @do_div
@both_neg:
    xor a ; reset carry flag indicating result positive
    ; fall through
@do_div:
    push af ; save sign of result
    call div_168
    pop af ; get back sign of result
    ret nc ; result is positive so nothing to do
    call neg_hlu ; result is negative so negate it
    ret


; Divide 16.8 unsigned fixed point values 
; with 16.8 fixed point result
; In: Divide UB.C by UD.E
; Out: uh.l is the unsigned 16.8 fixed point result
; Note: we do two 24-bit divisions in this routine
;       the second one to compute the fractional portion
;       of the result from the accumulated remainder
;       which seems wildly inefficient, but it does work
div_168:
; get the 16-bit integer part of the quotient
; and save the result to scratch
    call div_24
    ld (div_168_out),bc
; now put the remainder into scratch
    ld (uhl),hl
; multiply remainder by 256
    ld bc,(uhl-1)
    ld c,0 
; and divide the shifted remainder by
; the original divisor
    call div_24
; now load uhl annd h with the lower two bytes
; of the first division (throwing away the upper byte)
    ld hl,(div_168_out-1)
; now load l with the fractional result
; of the second division
    ld l,c
    ret
div_168_out: ds 6

; this is an adaptation of Div16 extended to 24 bits
; from https://map.grauw.nl/articles/mult_div_shifts.php
; it works by shifting each byte of the dividend left into carry 8 times
; and adding the dividend into hl if the carry is set
; thus hl accumulates a remainder depending on the result of each iteration
; ---------------------------------------------------------
; Divide 24-bit unsigned values (with 24-bit unsigned result)
; In: Divide BCU by DEU
; Out: BCU = result, HLU = remainder
div_24:
    ld hl,0
    ld (ubc),bc
    ld a,(ubc+2)
    ld b,8
@loop0:
    rla
    adc hl,hl
    sbc hl,de
    jr nc,@noadd0
    add hl,de
@noadd0:
    djnz @loop0
    rla
    cpl
    ld (ubc+2),a
    ld a,(ubc+1)
    ld b,8
@loop1:
    rla
    adc hl,hl
    sbc hl,de
    jr nc,@noadd1
    add hl,de
@noadd1:
    djnz @loop1
    rla
    cpl
    ld (ubc+1),a
    ld a,(ubc)
    ld b,8
@loop2:
    rla
    adc hl,hl
    sbc hl,de
    jr nc,@noadd2
    add hl,de
@noadd2:
    djnz @loop2
    rla
    cpl
    ld (ubc),a
    ld bc,(ubc)
    ret

; absolute value of hlu
; destroys: a,hlu
; carry set if result negative, reset if positive or zero
abs_hlu:
    xor a ; reset carry
    ld (uhl),hl
    ld a,(uhl+2) ; upper byte of hlu
    rla ; shift the sign bit into the carry flag
    ret nc ; if positive,we're done
    call neg_hlu_1 ; otherwise negate hlu
    scf ; set carry flag indicating hlu was negative
    ret

; flip the sign of hlu
; destroys a,hlu
; carry set if result negative, otherwise reset
neg_hlu:
; test hl for zero otherwise it returns 0xFF0000 :-/
    add hl,de
    or a
    sbc hl,de ; 30 t-states
    ret z ; if zero,we're done
; write hl to scratch so we can get at all its bytes
    ld (uhl),hl
neg_hlu_1:
    ld hl,uhl
    xor a
    sub (hl)
    ld (hl),a
    inc hl

    sbc a,a
    sub (hl)
    ld (hl),a
    inc hl

    ld a,-1
    xor (hl)
    ld (hl),a

    ld hl,(uhl)
    ld a,(uhl+2) ; upper byte of hlu
    rla ; shift the sign bit into the carry flag
    ret
