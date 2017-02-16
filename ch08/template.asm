	SECTION .data


	SECTION .text
        global  _start

_start:




	
end:
        xor     rdi,rdi
        push    0x3c
        pop     rax
        syscall
