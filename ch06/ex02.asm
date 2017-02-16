	;; compute 
        segment .data
x1      dq      1
y1      dq      4
x2    	dq      1
y2	dq     -5
diffx	dq	0
diffy	dq	0
one	dq	1
	
        segment .text
        global  _start
_start:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16

	mov 	rbx, [y1]	; compute (y1-y2)
	sub 	rbx, [y2]
	mov 	[diffy], rbx

	xor 	rax, rax	; rax := 0
	mov 	rbx, [x1]	; compute (x1-x2)
	sub 	rbx, [x2]
	cmovz	rax, [one]	; rax := 1 if (x1-x2)==0
	mov 	[diffx], rbx

	xor     rax, rax    ; was "mov   rax, 0"
        leave
        ret
