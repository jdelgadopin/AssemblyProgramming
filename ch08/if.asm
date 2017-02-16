        segment .data
a       dq      100
b       dq      200
        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        mov     rax, [a]
        mov     rbx, [b]
        cmp     rax, rbx
        jge     in_order
        mov     [a], rbx
        mov     [b], rax
in_order:
        xor     eax, eax
        leave
        ret
