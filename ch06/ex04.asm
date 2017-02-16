	;; compute [ctfee + costkwh * Theta(kwhused - 1000)] div 100

        segment .data
costkwh	dq	1567		; cost (pennies) per kilowatt hour
kwhused	dq	1866		; kilowatt hours used
ctfee	dq	 500 		; $5 = 500 pennies
dollars	dq	   0
pennies	dq	   0

	;; useful constants needed because immediate operands can't be used
ct100	dq	 100	
zero	dq	   0
	
        segment .text
        global  _start
_start:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16

	;; compute ctfee + costkwh * Theta(kwhused - 1000)
	mov 	rbx, qword [kwhused] 
	sub	rbx, 1000
	cmovl	rbx, [zero]
	mov 	qword [kwhused], rbx
	mov 	rax, [costkwh]
	imul	qword [kwhused]
	add	rax, [ctfee]
	;; rdx:rax := ctfee + costkwh * Theta(kwhused - 1000)

	idiv qword [ct100]
	mov [dollars], rax
	mov [pennies], rdx
	
	;; With these numbers, the results should be:
	;; dollars = 13575 / 0x3507
	;; pennies =    22 /   0x16
	
	xor     rax, rax    ; was "mov   rax, 0"
        leave
        ret
