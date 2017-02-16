	segment .data
	
dat  	dq	0x3D2133F5EE078A58

        segment .text
        global  _start
_start:	
        push    rbp
        mov     rbp, rsp
	
	mov 	rax, [dat]
	mov 	rbx, [dat]	; rbx will contain the desired result

	ror 	rax, 8		; byte 2
	xor	rbx, rax
	ror 	rax, 8		; byte 3
	xor	rbx, rax
	ror 	rax, 8		; byte 4
	xor	rbx, rax
	ror 	rax, 8		; byte 5
	xor	rbx, rax
	ror 	rax, 8		; byte 6
	xor	rbx, rax
	ror 	rax, 8		; byte 7
	xor	rbx, rax
	ror 	rax, 8		; byte 8
	xor	rbx, rax

	and 	rbx, 0xFF	; result in rbx
	
	xor     rax, rax
        leave
        ret
