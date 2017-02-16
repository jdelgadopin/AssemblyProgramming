        segment .data
	
strd  	db	01100111b
rslt  	dd      0
	
        segment .text
        global  _start
_start:	
        push    rbp
        mov     rbp, rsp

	xor	rax, rax
	
	mov	rax, 0x1	; bit 0
	and 	rax, [strd]
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 1
	and 	rax, [strd]
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 2
	and 	rax, [strd]
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 3
	and 	rax, [strd]
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 4
	and 	rax, [strd]
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 5
	and 	rax, [strd]
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 6
	and 	rax, [strd]
	add 	[rslt], rax
	shr	byte [strd], 1
	mov	rax, 0x1	; bit 7
	and 	rax, [strd]
	add 	[rslt], rax
	shr	byte [strd], 1

	xor     rax, rax
        leave
        ret
