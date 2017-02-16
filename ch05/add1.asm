        segment .data
a       dq      175
b       dq      4097
        segment .text
        global  main
main:
        lea     rax, [a]    ; mov address of a into rax
        mov     rax, [a]    ; mov a (175) into rax
        add     rax, [b]    ; add b to rax
        xor     rax, rax
        ret
