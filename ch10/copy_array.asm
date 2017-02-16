        segment .data
a:      dd      1, 2, 3, 4, 5
        segment .bss
b:      resd    10
        segment .text
        global  main, copy_array
main:
        push    rbp
        mov     rbp, rsp
        lea     rdi, [b]
        lea     rsi, [a]
        mov     edx, 5
        call    copy_array
        xor     eax, eax
        leave
        ret
copy_array:
        xor     ecx, ecx
more:   mov     eax, [rsi+4*rcx]
        mov     [rdi+4*rcx], eax
        add     rcx, 1
        cmp     rcx, rdx
        jne     more
        xor     eax, eax
        ret
