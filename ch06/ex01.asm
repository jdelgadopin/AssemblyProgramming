	;; compute (x1-x2)^2 + (y1-y2)^2
        segment .data
x1      dq      1
y1      dq      1
x2    	dq      2
y2	dq	2
result	dq	0
	
        segment .text
        global  _start
_start:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16

	mov 	rax, [x1]	; compute (x1-x2)^2
	sub 	rax, [x2]
	imul	rax, rax
	
	mov 	[result], rax	; save it in result

	mov 	rax, [y1]	; compute (y1-y2)^2
	sub 	rax, [y2]
	imul	rax, rax

	add 	[result], rax	

	xor     rax, rax    ; was "mov   rax, 0"
        leave
        ret
