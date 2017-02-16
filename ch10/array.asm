        segment .bss
a       resb    100
b       resd    100
        align   8
c       resq    100
        segment .text
        global  main                ; let the linker know about main
main:
        push    rbp
        mov     rbp, rsp
        leave
        ret
