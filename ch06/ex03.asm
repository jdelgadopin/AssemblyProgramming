	;; compute (g1+g2+g3+g4)/4
        segment .data
g1      dq      25		; 0 <= gi <= 100 --  i=1,2,3,4
g2      dq      76
g3      dq      12
g4      dq      88		; g1+g2+g3+g4 = 201 / C9
q	dq	0		; q should be 50
r	dq	0		; r should be  1
	
        segment .text
        global  _start
_start:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16

	mov 	rax, [g1]	; rax := g1+g2+g3+g4
	add	rax, [g2]
	add	rax, [g3]
	add	rax, [g4]
	xor 	rdx, rdx	; rdx := 0
	;; dividend is rdx:rax

	mov	rbx, 4		; rbx := 4
	;; divisor is rbx
	
	idiv 	rbx
	mov 	[q], rax
	mov 	[r], rdx
	
	xor     rax, rax    ; was "mov   rax, 0"
        leave
        ret
