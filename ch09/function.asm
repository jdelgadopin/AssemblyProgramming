        segment .text
        global main

doit:   mov  eax, 1
        ret

main:   call doit
        xor  eax, eax
        ret
