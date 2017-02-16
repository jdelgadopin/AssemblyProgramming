        segment .data
a       dq      0xA
b       dq      20
na	dq 	-10
nb 	dq 	-21
	
        segment .text
        global  _start
_start:
        mov     rax, [a]    ; mov  a into rax
        mov     rbx, [b]    ; mov  b into rbx
        mov     rcx, [na]   ; mov na into rcx
        mov     rdx, [nb]   ; mov nb into rdx
	add 	rax, rbx
	add	rax, rcx
	add	rax, rdx
	xor 	rax, rax
        ret
