        segment .data
a       dq      100
b       dq      200
max     dq      0
        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        mov     rax, [a]
        mov     rbx, [b]
        cmp     rax, rbx
        jnl     else
        mov     [max], rbx
        jmp     endif
else:   mov     [max], rax
endif:  xor     eax, eax
        leave
        ret
