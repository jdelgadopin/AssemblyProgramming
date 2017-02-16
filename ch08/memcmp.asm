        segment .data
a:      db      "This is fun"
b:      db      "This is not"
        segment .text
        global  main
        global  memcmp
memcmp:
        mov     rcx, rdx
        repe    cmpsb
        cmp     rcx, 0
        jz      equal
        movzx   eax, byte [rdi-1]
        movzx   ecx, byte [rsi-1]
        sub     rax, rcx
        ret
equal:  xor     eax, eax
        ret

main:
        push    rbp
        mov     rbp, rsp
        lea     rdi, [a]
        lea     rsi, [b]
        mov     edx, 11
        call    memcmp
        xor     eax, eax
        leave
        ret
