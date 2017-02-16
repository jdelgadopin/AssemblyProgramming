	segment .data
	
A  	dq	0
B  	dq      0
C	dq	0
	
        segment .text
        global  _start
_start:	
        push    rbp
        mov     rbp, rsp

	bts	qword [A], 0
	bts	qword [A], 1
	bts	qword [A], 7
	bts	qword [A], 13

	bts	qword [B], 1
	bts	qword [B], 3
	bts	qword [B], 12

	xor 	eax, eax	; C <- A U B
	mov	rax, [A]
	or 	rax, [B]
	mov	[C], rax

	xor 	eax, eax	; C <- A intersection B
	mov	rax, [A]
	and 	rax, [B]
	mov	[C], rax

	xor 	eax, eax	; C <- A - B
	mov	rax, [A]
	xor 	rax, [B]
	mov	[C], rax

	btr	qword [C], 7
	
	xor     rax, rax
        leave
        ret
