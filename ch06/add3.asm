        segment .data
a       dq      151
b       dq      310
sum     dq      0
        segment .text
        global  main
main:
        push    rbp         ; establish a stack frame
        mov     rbp, rsp
        sub     rsp, 16
        mov     rax, 9      ; set rax to 9
        add     [a], rax    ; add rax to a
        mov     rax, [b]    ; get b into rax
        add     rax, 10     ; add 10 to rax
        add     rax, [a]    ; add the contents of a
        mov     [sum], rax  ; save the sum in sum
        mov     rax, 0      ; would be better as "xor eax, eax"
        leave               ; restore the previous stack frame
        ret                 ; return
