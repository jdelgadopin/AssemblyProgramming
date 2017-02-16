        segment .data
n       dq      5
a       dq      1, 2, 3, 4, 5
b       dq      10, 20, 30, 40, 50
c       dq      0, 0, 0, 0, 0
        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        mov     rdx, [n]
        xor     ecx, ecx
        lea     r8, [a]
        lea     r9, [b]
        lea     r10, [c]
for:    cmp     rcx, rdx
        je      end_for
        mov     rax, [r8+rcx*8]
        add     rax, [r9+rcx*8]
        mov     [r10+rcx*8], rax
        inc     rcx
        jmp for
end_for:
        xor eax, eax
        leave
        ret
