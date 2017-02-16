        segment .data
a       dq      100
b       dq      200
diff    dq      0
        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16
        mov     rax, 10
        sub     [a], rax    ; subtract 10 from a
        sub     [b], rax    ; subtract 10 from b
        mov     rax, [b]    ; move b into rax
        sub     rax, [a]    ; set rax to b-a
        mov     [diff], rax ; move the difference to diff
        xor     rax, rax    ; was "mov   rax, 0"
        leave
        ret
