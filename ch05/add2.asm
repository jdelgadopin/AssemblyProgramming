        segment .data
a       dq      175
b       dq      4097
sum     dq      0
        segment .text
        global  main
main:
        mov     rax, [a]    ; mov a (175) into rax
        add     rax, [b]    ; add b to rax
        mov     [sum], rax  ; save the sum
        xor     rax, rax
        ret
