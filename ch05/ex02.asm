        segment .data
n1     	db      0x12
n2      dw      0x12AB
n4	dd 	0x12AB34CD
n8 	dq 	0x12AB34CD56CD78EF
r	dq 	0
	
        segment .text
        global  _start
_start:
        movsx   rax, byte  [n1]    ; mov n1 into rax w sign extension
        movsx   rbx, word  [n2]    ; mov n2 into rbx w sign extension
        movsxd  rcx, dword [n4]    ; mov n4 into rcx w sign extension
        mov     rdx, [n8]    	   ; mov n8 into rdx
	add 	[r], rax     ; add (the content of) rax to r
	add 	[r], rbx     ; add (the content of) rbx to r
	add 	[r], rcx     ; add (the content of) rcx to r
	add 	[r], rdx     ; add (the content of) rdx to r
	xor 	rax, rax     ; what for?
        ret
