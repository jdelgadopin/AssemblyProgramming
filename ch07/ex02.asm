        segment .data
	
a  	dq	0xABCDEF
b  	dq      0xFEDCBA
	
        segment .text
        global  _start
_start:	
        push    rbp
        mov     rbp, rsp

	mov 	rax, [a]	; No puc fer xor m1 m2, així que moc un a un registre
	xor 	rax, [b]
	xor	[b], rax
	xor	rax, [b]
	mov 	[a], rax
	
	xor     rax, rax
        leave
        ret
