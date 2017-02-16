segment .data
	switch: dq      case0
        	dq      case1
        	dq      case2
        	dq      case3

	i:      dq      2

segment .text
        global  _start

_start:
        mov     rax, [i]
        lea     rdx, [switch]
        jmp     [rdx+rax*8]
case0:
        mov     rbx, 100
        jmp     end
case1:
        mov     rbx, 101
        jmp     end
case2:
        mov     rbx, 102
        jmp     end
case3:
        mov     rbx, 103
        jmp     end
end:
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscall
