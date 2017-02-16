        segment .data
a       dq      175
b       dq      4097
sum     dq      0
diff    dq      0
        segment .text
        global  main
main:
        mov     rax, [a]    ; mov a (175) into rax
        mov     rbx, rax    ; mov rax to rbx
        add     rax, [b]    ; add b to rax
        mov     [sum], rax  ; save the sum
        sub     rbx, [b]    ; subtract b from rax
        mov     [diff], rbx
        xor     rax, rax
        ret
