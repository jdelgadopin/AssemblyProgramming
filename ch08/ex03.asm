	SECTION .data
vt	dd	23, 10, 4, 0, 13, 15, 20, 1, -3, 3
sz	dd	10
	
	SECTION .text
        global  _start

_start:
	shl	dword [sz], 2		; size <- size x 4 (double words)
	
s_do:	xor	ax, ax			; swapped = false 	(rax = swapped)

	xor 	ecx, ecx		; i = 0  		(ecx = i)
s_for:	cmp	dword [sz], ecx
	je	e_do			; jump if i == [size]

	mov 	ebx, dword [vt + ecx + 4]
	cmp	dword [vt + ecx], ebx
	jle	e_for			; jump if a[i] <= a[i+1]

	xor	ebx, dword [vt + ecx]	; swap a[i] and a[i+1]
	xor	dword [vt + ecx] , ebx
	xor	ebx, dword [vt + ecx]
	mov	dword [vt + ecx + 4], ebx

	or 	ax, 0x1			; swapped = true

e_for:	add	ecx, 4
	jmp 	s_for
	
e_do:	bt	ax, 0
	jc	s_do
	
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscall
