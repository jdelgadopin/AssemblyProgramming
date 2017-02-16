        segment .data
a       dq      100
b       dq      200
c       dq      300
result  dq      0
        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        mov     rax, [a]
        mov     rbx, [b]
        cmp     rax, rbx
        jnl     else_if
        mov     qword [result], 1
else_if mov     rcx, [c]
        cmp     rax, rcx
        jng     else
        mov     qword [result], 2
        jmp     endif
else:   mov     qword [result], 3
endif:  xor     eax, eax
        leave
        ret
