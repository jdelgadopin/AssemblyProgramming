	segment .data
	
dat  	dq	-0.00234	; 0xBF632B55EF1FDDEC
exp	dw	0		; -9 = 0xFFF7  (reminder, this is a gdb halfword)
sgn     db	0		;  1 = 0x1
mnt     dq	0		; 0x132B55EF1FDDEC
	
        segment .text
        global  _start
_start:	
        push    rbp
        mov     rbp, rsp
	
	mov 	rax, [dat]	; sign bit
	rol	rax, 1
	and 	rax, 0x1
	mov	[sgn], al

	mov	rax, [dat]	; exponent - 1023
	rol	rax, 12
	and	rax, 0x7FF
	sub	rax, 0x3FF
	mov 	[exp], ax

	mov	rax, [dat]	; mantissa + 1 high order bit
	shl	rax, 12
	shr	rax, 12
	bts	rax, 52
	mov	[mnt], rax
	
	xor     rax, rax
        leave
        ret
