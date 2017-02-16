	segment .data
	
f1  	dd	23.45678	; 0x41BBA77C
f2	dd	2356.1111	; 0x451341C7
rs	dd	0		; should be 0x4757E2C7 (not rounding)

sgnf1	db	0
expf1	db	0
mntf1	dd	0

sgnf2	db	0
expf2	db	0
mntf2	dd	0

sgnr	db	0
expr	db	0
mntr    dd      0
	
        segment .text
        global  _start
_start:	
	;; f1 decomposition
	mov 	eax, [f1]
	mov 	[mntf1], eax
	shr	eax, 23
	mov 	[expf1], al
	sub	byte [expf1], 0x7F
	shr 	eax, 8
	mov	[sgnf1], al
	and	dword [mntf1], 0x7FFFFF
	bts	dword [mntf1], 23

	;; f2 decomposition
	mov 	eax, [f2]
	mov 	[mntf2], eax
	shr	eax, 23
	mov 	[expf2], al
	sub	byte [expf2], 0x7F
	shr 	eax, 8
	mov	[sgnf2], al
	and	dword [mntf2], 0x7FFFFF
	bts	dword [mntf2], 23

	;; product f1 x f2
	mov 	al, [sgnf1]	; sign bit
	add	al, byte [sgnf2]
	and	al, 0x1
	mov	byte [sgnr], al
	mov 	al, [expf1]	; exponent
	add	al, [expf2]
	mov	byte [expr], al
	mov 	eax, [mntf1]	; mantissa
	mul	dword [mntf2]
	shl	rdx, 32
	or	rax, rdx	; rax has the mantissa + 1 bit
	xor 	rcx, rcx	; should I increment the exponent?
	mov 	rcx, rax	
	shr	rcx, 47
	add	byte [expr], cl
	shr	rax, 23		; prepare the mantissa...
	shr	rax, cl
	mov 	dword [mntr], eax
	btr	rax, 23

	;; Now we code the float -  mantissa already in eax
	xor 	ebx, ebx	; sign bit
	mov	bl, [sgnr]
	shl	ebx, 31
	xor 	ecx, ecx	; exponent
	mov	cl, [expr]
	add	cl, 0x7F	; add 127
	shl	ecx, 23
	or	eax, ebx
	or	eax, ecx
	mov 	dword [rs], eax
	
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscall
