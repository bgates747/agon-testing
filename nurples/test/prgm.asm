    org 0xB7E000 

_main:
    ld hl,str_hello
    call printString
    ret

printString:
	PUSH	BC
	LD		BC,0
	LD 	 	A,0
	RST.LIL 18h
	POP		BC
	RET

str_hello: db "hello world!",0