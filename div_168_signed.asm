; 24-bit integer and 16.8 fixed point division routines
; by Brandon R. Gates (BeeGee747)
; have undergone cursory testing and seem to be generating
; correct results (assuming no overflows) but seem very inefficient,
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
; perform signed division of 16.8 fixed place values
; with an signed 16.8 fixed place result
; inputs: ub.c is dividend,ud.e is divisor
; outputs: ub.c is quotient
; destroys: a,hl,bc
; note: uses carry flag to test for sign of operands and result
;       which can be confusing and should perhaps be changed
; note2: helper functions abs_hlu and neg_hlu have been modified
;       to return accurate flags according to the origional signs 
;       (or zero) of this function's inputs
div_168_signed:
; make everything positive and save signs
    push bc         ; get bc to hl
    pop hl          ; for the next call
    call abs_hlu    ; sets sign flag if hlu was negative, zero if zero
    jp z,@is_zero   ; if bc is zero, answer is zero and we're done
    push af         ; save sign of bc
    push hl         ; now put abs(hl)
    pop bc          ; back into bc = abs(bc)
    ex de,hl        ; now we do de same way
    call abs_hlu
    jp z,@div_by_zero  ; if de was zero, answer is undefined and we're done
    ex de,hl        ; hl back to de = abs(de)
; determine sign of result
    jp p,@de_pos    ; carry=0,de is positive
    pop af          ; get back sign of bc
    jp m,@result_pos  ; bc and de negative, result is positive
    jr @result_neg
@de_pos:
    pop af          ; get back sign of bc
    jp p,@result_pos   ; bc and de are both positive so result is positive
                    ; fall through to result_neg
@result_neg:
    xor a           ; zero a and clear carry 
    dec a           ; set sign flag to negative
    jr @do_div      
@result_pos:
    xor a           ; zero a and clear carry 
    inc a           ; set sign flag to negative
                    ; fall through to do_div
@do_div:
    push af         ; save sign of result
    call div_168
    pop af          ; get back sign of result
    ret p           ; result is positive so nothing to do
    call neg_hlu    ; result is negative so negate it
    ret
@is_zero:           ; result is zero
    xor a           ; sets zero flag, which we want, 
                    ; sets pv flag which we might not (zero is parity even)
                    ; resets all others which is okay
    ret
@div_by_zero:       ; result is undefined, which isn't defined in binary
                    ; so we'll just return zero until i can think of something better
    pop af          ; dummy pop
    xor a           ; sets zero flag, which is ok, 
                    ; sets pv flag which could be interpreted as overflow, which is good
                    ; resets all others which is okay
    ret

; perform unsigned division of 16.8 fixed place values
; with an unsigned 16.8 fixed place result
; inputs: ub.c is dividend,ud.e is divisor
; outputs: ub.c is quotient
; destroys: a,hl,bc
div_168:
; get the 16-bit integer part of the quotient
    call div_24
    ; call udiv24
; load quotient to upper three bytes of output
    ld (div_168_out+1),bc
; check remainder for zero, and if it is 
; we can skip calculating the fractional part
    add hl,de
    or a
    sbc hl,de 
    jr nz,@div256
    xor a
    jr @write_frac
@div256:
; divide divisor by 256
    push hl ; save remainder
; TODO: it feels like this could be more efficient
    ld (ude),de
    ld a,d
    ld (ude),a
    ld a,(ude+2)
    ld (ude+1),a
    xor a
    ld (ude+2),a
    ld hl,(ude) ; (just for now, we want it in de eventually)
; now we check the shifted divisor for zero, and if it is
; we again set the fractional part to zero
    add hl,de
    or a
    sbc hl,de 
    ex de,hl ; now de is where it's supposed to be
    pop hl ; get remainder back
    jr nz,@div_frac
    xor a
    jr @write_frac
; now divide the remainder by the shifted divisor
@div_frac:
    push hl ; my kingdom for ld bc,hl
    pop bc  ; or even ex bc,hl
    call div_24
    ; call udiv24
; load low byte of quotient to low byte of output
    ld a,c
@write_frac:
    ld (div_168_out),a
; load hl with return value
    ld hl,(div_168_out)
; load a with any overflow
    ld a,(div_168_out+3)
    ret ; uh.l is the 16.8 result
div_168_out: ds 4 ; the extra byte is for overflow

; this is an adaptation of Div16 extended to 24 bits
; from https://map.grauw.nl/articles/mult_div_shifts.php
; it works by shifting each byte of the dividend left into carry 8 times
; and adding the dividend into hl if the carry is set
; thus hl accumulates a remainder depending on the result of each iteration
; ---------------------------------------------------------
; Divide 24-bit unsigned values 
;   with 24-bit unsigned result
;   and 24-bit remainder
; In: Divide ubc by ude
; Out: ubc = result, uhl = remainder
; Destroys: a,hl,bc
div_24:
    ld hl,0     ; Clear accumulator for remainder
; put dividend in scratch so we can get at all its bytes
    ld (ubc),bc ; scratch ubc also accumulates the quotient
    ld a,(ubc+2); grab the upper byte of the dividend
    ld b,8      ; loop counter for 8 bits in a byte
@loop0:
    rla         ; shift the next bit of dividend into the carry flag
    adc hl,hl   ; shift the remainder left one bit and add carry if any
    sbc hl,de   ; subtract divisor from remainder
    jr nc,@noadd0   ; if no carry,remainder is <= divisor
                ; meaning remainder is divisible by divisor
    add hl,de   ; otherwise add divisor back to remainder
                ; reversing the previous subtraction
@noadd0:
    djnz @loop0 ; repeat for all 8 bits
    rla         ; now we shift a left one more time
    cpl         ; then flip its bits for some reason
    ld (ubc+2),a; magically this is the upper byte of the quotient
    ld a,(ubc+1); now we pick up the middle byte of the dividend
    ld b,8      ; set up the next loop and do it all again ...
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
    ld (ubc+1),a ; writing the middle byte of quotient
    ld a,(ubc)
    ld b,8
@loop2:          ; compute low byte of quotient
    rla
    adc hl,hl
    sbc hl,de
    jr nc,@noadd2
    add hl,de
@noadd2:
    djnz @loop2
    rla
    cpl
    ld (ubc),a  ; ... write low byte of quotient
    ld bc,(ubc) ; load quotient into bc for return
    ret         ; hl already contains remainder so we're done

; ---------------------------------------------------------
; BEGIN HELPER ROUTINES
; ---------------------------------------------------------
;
; absolute value of hlu
; returns: abs(hlu),
;       carry set if hlu was negative, reset if positive or zero
;       zero set if hlu was 0x7FFFFF, reset otherwise
;       overflow and sign set if hl was 0x800000 or 0x7FFFFF
; destroys: a
abs_hlu:
; test the sign of hlu
	; ld hl,0 ; s0,z1,pv0,n1,c0
	; ld hl,1 ; s0,z0,pv0,n1,c0
	; ld hl,-1 ; s1,z0,pv0,n1,c0
    add hl,de
    or a
    sbc hl,de 
    ret z       ; if hlu was zero, we're done
    ret p      ; if hlu was positive, we're done
    push af     ; otherwise, save current flags for return
    call neg_hlu ; negate hlu
    pop af      ; get back flags
    scf         ; set carry flag indicating hlu was negative
    ret

; flip the sign of hlu
; inputs: hlu
; returns: -hlu, flags should be set appropriately for the result
; destroys a
neg_hlu:
    push de     ; save de
    ex de,hl    ; put hl into de
    ld hl,0     ; clear hl
    xor a       ; clear carry
    sbc hl,de   ; 0-hl = -hl
    pop de      ; get de back
    ret         ; easy peasy

; -----------------------------------------------------------------------
; https://github.com/sijnstra/agon-projects/blob/main/calc24/arith24.asm
;------------------------------------------------------------------------
;  arith24.asm 
;  24-bit ez80 arithmetic routines
;  Copyright (c) Shawn Sijnstra 2024
;  MIT license
;
;  This library was created as a tool to help make ez80
;  24-bit native assembly routines for simple mathematical problems
;  more widely available.
;  
;------------------------------------------------------------------------

;------------------------------------------------------------------------
; umul24:	HL = HL*DE (unsigned)
; Preserves AF, BC, DE
; Uses a fast multiply routine.
;------------------------------------------------------------------------
umul24:
	push	DE 
	push	BC
	push	AF	
	push	HL
	pop		BC
    ld	 	a, 24 ; No. of bits to process 
    ld	 	hl, 0 ; Result
umul24_lp:
	add	hl,hl
	ex	de,hl
	add	hl,hl
	ex	de,hl
	jr	nc,umul24_nc
	add	hl,bc
umul24_nc: 
	dec	a
	jr	nz,umul24_lp
	pop	af
	pop	bc
	pop	de
	ret


;------------------------------------------------------------------------
; udiv24
; Unsigned 24-bit division
; Divides BCU by DEU. Gives result in BCU, remainder in HLU.
; 
; Uses AF BC DE HL
; Uses Restoring Division algorithm
;------------------------------------------------------------------------
; modified to take BCU as dividend instead of HLU
; and give BCU as quotient instead of DEU
; -----------------------------------------------------------------------
udiv24:
	; push	hl
	; pop		bc	;move dividend to BCU
	ld		hl,0	;result
	and		a
	sbc		hl,de	;test for div by 0
	ret		z		;it's zero, carry flag is clear
	add		hl,de	;HL is 0 again
	ld		a,24	;number of loops through.
udiv1:
	push	bc	;complicated way of doing this because of lack of access to top bits
	ex		(sp),hl
	scf
	adc	hl,hl
	ex	(sp),hl
	pop	bc		;we now have bc = (bc * 2) + 1

	adc	hl,hl
	and	a		;is this the bug
	sbc	hl,de
	jr	nc,udiv2
	add	hl,de
;	dec	c
	dec	bc
udiv2:
	dec	a
	jr	nz,udiv1
	scf		;flag used for div0 error
	; push	bc
	; pop		de	;remainder
	ret



;------------------------------------------------------------------------
; neg24
; Returns: HLU = 0-HLU
; preserves all other registers
;------------------------------------------------------------------------
neg24:
	push	de
	ex		de,hl
	ld		hl,0
	or		a
	sbc		hl,de
	pop		de
	ret

;------------------------------------------------------------------------
; or_hlu_deu: 24 bit bitwise OR
; Returns: hlu = hlu OR deu
; preserves all other registers
;------------------------------------------------------------------------
or_hlu_deu:
	ld	(bitbuf1),hl
	ld	(bitbuf2),de
	push	de	;preserve DEU
	push	bc	;preserve BCU
	ld		b,3
	ld	hl,bitbuf1
	ld	de,bitbuf1
orloop_24:
	ld	a,(de)
	or	(hl)
	ld	(de),a
	inc	de
	inc	hl
	djnz	orloop_24
	ld	hl,(bitbuf2)
	pop		bc	;restore BC
	pop		de	;restore DE

;------------------------------------------------------------------------
; and_hlu_deu: 24 bit bitwise AND
; Returns: hlu = hlu AND deu
; preserves all other registers
;------------------------------------------------------------------------
and_hlu_deu:
	ld	(bitbuf1),hl
	ld	(bitbuf2),de
	push	de	;preserve DEU
	push	bc	;preserve BCU
	ld		b,3
	ld	hl,bitbuf1
	ld	de,bitbuf1
andloop_24:
	ld	a,(de)
	and	(hl)
	ld	(de),a
	inc	de
	inc	hl
	djnz	andloop_24
	ld	hl,(bitbuf2)
	pop		bc	;restore BC
	pop		de	;restore DE

;------------------------------------------------------------------------
; xor_hlu_deu: 24 bit bitwise XOR
; Returns: hlu = hlu XOR deu
; preserves all other registers
;------------------------------------------------------------------------
xor_hlu_deu:
	ld	(bitbuf1),hl
	ld	(bitbuf2),de
	push	de	;preserve DEU
	push	bc	;preserve BCU
	ld		b,3
	ld	hl,bitbuf1
	ld	de,bitbuf1
xorloop_24:
	ld	a,(de)
	xor	(hl)
	ld	(de),a
	inc	de
	inc	hl
	djnz	xorloop_24
	ld	hl,(bitbuf2)
	pop		bc	;restore BC
	pop		de	;restore DE

;------------------------------------------------------------------------
; shl_hlu: 24 bit shift left hlu by deu positions
; Returns: hlu = hlu << deu
;		   de = 0
; NOTE: only considers deu up to 16 bits. 
; preserves all other registers
;------------------------------------------------------------------------
shl_hlu:
	ld		a,d		;up to 16 bit.
	or		e
	ret		z		;we're done
	add		hl,hl	;shift HLU left
	dec		de
	jr		shl_hlu

;------------------------------------------------------------------------
; shr_hlu: 24 bit shift right hlu by deu positions
; Returns: hlu = hlu >> deu
;		   de = 0
; NOTE: only considers deu up to 16 bits. 
; preserves all other registers
;------------------------------------------------------------------------
shr_hlu:
	ld		(bitbuf1),hl
	ld		hl,bitbuf1+2
shr_loop:
	ld		a,d		;up to 16 bit.
	or		e
	jr		z,shr_done		;we're done
;carry is clear from or instruction
	rr		(hl)
	dec		hl
	rr		(hl)
	dec		hl
	rr		(hl)
	inc		hl
	inc		hl
	dec		de
	jr		shr_loop
shr_done:
	ld		hl,(bitbuf1)	;collect result
	ret

;------------------------------------------------------------------------
; Scratch area for calculations
;------------------------------------------------------------------------
bitbuf1:	dw24	0	;bit manipulation buffer 1
bitbuf2:	dw24	0	;bit manipulation buffer 2
